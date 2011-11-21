From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: fix freezing groups with stopped tasks
Date: Mon, 21 Nov 2011 14:40:35 +0100
Message-ID: <20111121134035.GA16957__48431.7470495172$1321882868$gmane$org@tiehlicka.suse.cz>
References: <1321480234-29241-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1321480234-29241-1-git-send-email-mhocko-AlSwsSmVLrQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Tejun, Li Zefan,
did you have time to look at this patch? I haven't found any
cgroup_freezer maintainer so I guess it should go via generic cgroups
maintainers, right?

Anyway, this is probably not the number one urgent fix as it is broken
since .37 and nobody complained (perhaps people do not tend to freeze
groups with stopped tasks) but LTP does fail on this issue so more
people doing some QA with post .37 kernels will notice.

On Wed 16-11-11 22:50:34, Michal Hocko wrote:
> 2d3cbf8b (cgroup_freezer: update_freezer_state() does incorrect state
> transitions) removed is_task_frozen_enough and replaced it with a simple
> frozen call. This, however, breaks freezing for a group with stopped tasks
> because those cannot be frozen and so the group remains in CGROUP_FREEZING
> state (update_if_frozen doesn't count stopped tasks) and never reaches
> CGROUP_FROZEN.
> 
> Let's add is_task_frozen_enough back and use it at the original locations
> (update_if_frozen and try_to_freeze_cgroup). Semantically we consider
> stopped tasks as frozen enough so we should consider both cases when
> testing frozen tasks.
> 
> Testcase:
> mkdir /dev/freezer
> mount -t cgroup -o freezer none /dev/freezer
> mkdir /dev/freezer/foo
> sleep 1h &
> pid=$!
> kill -STOP $pid
> echo $pid > /dev/freezer/foo/tasks
> echo FROZEN > /dev/freezer/foo/freezer.state
> while true
> do
>         cat /dev/freezer/foo/freezer.state
>         [ "`cat /dev/freezer/foo/freezer.state`" = "FROZEN" ] && break
>         sleep 1
> done
> echo OK
> 
> Signed-off-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 5e828a2..4d073dc 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -153,6 +153,13 @@ static void freezer_destroy(struct cgroup_subsys *ss,
>  	kfree(cgroup_freezer(cgroup));
>  }
>  
> +/* Task is frozen or will freeze immediately when next it gets woken */
> +static bool is_task_frozen_enough(struct task_struct *task)
> +{
> +	return frozen(task) ||
> +		(task_is_stopped_or_traced(task) && freezing(task));
> +}
> +
>  /*
>   * The call to cgroup_lock() in the freezer.state write method prevents
>   * a write to that file racing against an attach, and hence the
> @@ -231,7 +238,7 @@ static void update_if_frozen(struct cgroup *cgroup,
>  	cgroup_iter_start(cgroup, &it);
>  	while ((task = cgroup_iter_next(cgroup, &it))) {
>  		ntotal++;
> -		if (frozen(task))
> +		if (is_task_frozen_enough(task))
>  			nfrozen++;
>  	}
>  
> @@ -284,7 +291,7 @@ static int try_to_freeze_cgroup(struct cgroup *cgroup, struct freezer *freezer)
>  	while ((task = cgroup_iter_next(cgroup, &it))) {
>  		if (!freeze_task(task, true))
>  			continue;
> -		if (frozen(task))
> +		if (is_task_frozen_enough(task))
>  			continue;
>  		if (!freezing(task) && !freezer_should_skip(task))
>  			num_cant_freeze_now++;
> -- 
> 1.7.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
