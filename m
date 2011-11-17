From: Tomasz Buchert <tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
Subject: Re: [PATCH] cgroup_freezer: fix freezing groups with stopped tasks
Date: Thu, 17 Nov 2011 11:14:53 +0100
Message-ID: <4EC4DE9D.3040703@inria.fr>
References: <1321480234-29241-1-git-send-email-mhocko@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,
I'm trying to understand now why I did that change in

2d3cbf8bc (the bug itself was in the if-the-else clause in =

update_if_frozen , anyway).
Well, when I look at this now I think that there is nothing wrong with =

your patch.
You can try my testcases from 2d3cbf8bc and 0bdba580, but it should be ok.


One thing I am not sure completely of is the following situation. So the =

group is frozen
with the STOPPED task inside. There are few questions:
* if you send SIGCONT to the task now, will it wake up?
* if yes - will it get *immediately* frozen?
I im going to check it myself, but maybe you can answer faster :).


Tomek

Le 16/11/2011 22:50, Michal Hocko a =E9crit :
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
> sleep 1h&
> pid=3D$!
> kill -STOP $pid
> echo $pid>  /dev/freezer/foo/tasks
> echo FROZEN>  /dev/freezer/foo/freezer.state
> while true
> do
>          cat /dev/freezer/foo/freezer.state
>          [ "`cat /dev/freezer/foo/freezer.state`" =3D "FROZEN" ]&&  break
>          sleep 1
> done
> echo OK
>
> Signed-off-by: Michal Hocko<mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Tomasz Buchert<tomasz.buchert-MZpvjPyXg2s@public.gmane.org>
> Cc: Paul Menage<paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Andrew Morton<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Tejun Heo<htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>   kernel/cgroup_freezer.c |   11 +++++++++--
>   1 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 5e828a2..4d073dc 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -153,6 +153,13 @@ static void freezer_destroy(struct cgroup_subsys *ss,
>   	kfree(cgroup_freezer(cgroup));
>   }
>
> +/* Task is frozen or will freeze immediately when next it gets woken */
> +static bool is_task_frozen_enough(struct task_struct *task)
> +{
> +	return frozen(task) ||
> +		(task_is_stopped_or_traced(task)&&  freezing(task));
> +}
> +
>   /*
>    * The call to cgroup_lock() in the freezer.state write method prevents
>    * a write to that file racing against an attach, and hence the
> @@ -231,7 +238,7 @@ static void update_if_frozen(struct cgroup *cgroup,
>   	cgroup_iter_start(cgroup,&it);
>   	while ((task =3D cgroup_iter_next(cgroup,&it))) {
>   		ntotal++;
> -		if (frozen(task))
> +		if (is_task_frozen_enough(task))
>   			nfrozen++;
>   	}
>
> @@ -284,7 +291,7 @@ static int try_to_freeze_cgroup(struct cgroup *cgroup=
, struct freezer *freezer)
>   	while ((task =3D cgroup_iter_next(cgroup,&it))) {
>   		if (!freeze_task(task, true))
>   			continue;
> -		if (frozen(task))
> +		if (is_task_frozen_enough(task))
>   			continue;
>   		if (!freezing(task)&&  !freezer_should_skip(task))
>   			num_cant_freeze_now++;
