From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 02/10] freezer: skip waking up tasks with PF_FREEZER_SKIP
	set
Date: Mon, 29 Apr 2013 14:51:57 -0700
Message-ID: <20130429215157.GA2395@htj.dyndns.org>
References: <1367271946-7239-1-git-send-email-ccross@android.com>
	<1367271946-7239-3-git-send-email-ccross@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1367271946-7239-3-git-send-email-ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Cc: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, Apr 29, 2013 at 02:45:38PM -0700, Colin Cross wrote:
> If a task has called freezer_do_not_count(), don't bother waking it
> up.  If it happens to wake up later it will call freezer_count() and
> immediately enter the refrigerator.
> 
> Signed-off-by: Colin Cross <ccross-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c | 5 ++++-
>  kernel/power/process.c  | 4 ++--
>  2 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 75dda1e..406dd71 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -331,8 +331,11 @@ static void freeze_cgroup(struct freezer *freezer)
>  	struct task_struct *task;
>  
>  	cgroup_iter_start(cgroup, &it);
> -	while ((task = cgroup_iter_next(cgroup, &it)))
> +	while ((task = cgroup_iter_next(cgroup, &it))) {
> +		if (freezer_should_skip(task))
> +			continue;
>  		freeze_task(task);
> +	}
>  	cgroup_iter_end(cgroup, &it);

I feel a bit weary of changes which try to optimize state checks for
freezer because the synchronization rules are kinda fragile and things
may not work reliably depending on who's testing the flag, and it has
been subtly broken in various ways in the past (maybe even now).  Can
you please explain the benefits of this patch (in terms of actual
overhead because not many use freezer_do_not_count()) and why this is
correct?

Thanks.

-- 
tejun
