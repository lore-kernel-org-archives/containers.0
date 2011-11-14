From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 04/10] cgroup: always lock threadgroup during migration
Date: Mon, 14 Nov 2011 19:46:34 +0100
Message-ID: <20111114184630.GE9446@somewhere>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
	<1320191193-8110-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1320191193-8110-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Nov 01, 2011 at 04:46:27PM -0700, Tejun Heo wrote:
> Update cgroup to take advantage of the fack that threadgroup_lock()
> guarantees stable threadgroup.
> 
> * Lock threadgroup even if the target is a single task.  This
>   guarantees that when the target tasks stay stable during migration
>   regardless of the target type.
> 
> * Remove PF_EXITING early exit optimization from attach_task_by_pid()
>   and check it in cgroup_task_migrate() instead.  The optimization was
>   for rather cold path to begin with and PF_EXITING state can be
>   trusted throughout migration by checking it after locking
>   threadgroup.
> 
> * Don't add PF_EXITING tasks to target task array in
>   cgroup_attach_proc().  This ensures that task migration is performed
>   only for live tasks.
> 
> * Remove -ESRCH failure path from cgroup_task_migrate().  With the
>   above changes, it's guaranteed to be called only for live tasks.
> 
> After the changes, only live tasks are migrated and they're guaranteed
> to stay alive until migration is complete.  This removes problems
> caused by exec and exit racing against cgroup migration including
> symmetry among cgroup attach methods and different cgroup methods
> racing each other.
> 
> v2: Oleg pointed out that one more PF_EXITING check can be removed
>     from cgroup_attach_proc().  Removed.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Reviewed-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Just a little thing:

> ---
>  kernel/cgroup.c |   51 +++++++++++++++++++++++----------------------------
>  1 files changed, 23 insertions(+), 28 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index f0e099f..83e10f9 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1762,7 +1762,7 @@ EXPORT_SYMBOL_GPL(cgroup_path);
>   *
>   * 'guarantee' is set if the caller promises that a new css_set for the task
>   * will already exist. If not set, this function might sleep, and can fail with
> - * -ENOMEM. Otherwise, it can only fail with -ESRCH.
> + * -ENOMEM. Must be called with cgroup_mutex and threadgroup locked.
>   */
>  static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
>  			       struct task_struct *tsk, bool guarantee)
> @@ -1800,13 +1800,9 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
>  	}
>  	put_css_set(oldcg);
>  
> -	/* if PF_EXITING is set, the tsk->cgroups pointer is no longer safe. */
> +	/* @tsk can't exit as its threadgroup is locked */
>  	task_lock(tsk);
> -	if (tsk->flags & PF_EXITING) {
> -		task_unlock(tsk);
> -		put_css_set(newcg);
> -		return -ESRCH;
> -	}
> +	WARN_ON_ONCE(tsk->flags & PF_EXITING);

I have the feeling the task_lock is now useless given that we are synchronized
against cgroup_exit() with the threadgroup_lock.

It's probably also useless in cgroup_exit(). But that's something for a further
patch...

Thanks.
