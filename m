From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/5] c/r: fix restart failure due to a race with
	ghost/dead tasks
Date: Thu, 1 Oct 2009 12:21:53 -0500
Message-ID: <20091001172153.GE20565@us.ibm.com>
References: <1254361634-30076-1-git-send-email-orenl@librato.com>
	<1254361634-30076-5-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254361634-30076-5-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> Ghost (and dead) tasks exit as soon as they find their checkpoint_ctx.
> That may occur before other tasks even enter sys_restart(). If a ghost
> child dies before its child enters the syscall, the child will receive
> the death_signal which is set by userspace (in non-container restart).
> 
> This signal was supposedly skipped in reparent_thread() for restarting
> task, but the PF_RESTARTING flag was tested on the child instead of
> the parent; And the child was not in sys_restart, so .. bad luck.
> 
> This patch fixes reparent_threads() to test the parent's flag instead.
> 
> Also, if restart fails after some tasks have restore their state, then
> the death_signal of such tasks is likely to have been reset. To ensure
> proper cleanup in case of a failure, the coordinator tasks will force-
> kill all those descendants whose checkpoint_ctx matches that of the
> coordinator.
> 
> (To avoid a potential security issue here, prepare_descendants() was
> modified to only allow setting the checkpoint_task of a descendant if
> the coordinator has PTRACE_MODE_ATTACH permissions over it).
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/restart.c |   32 ++++++++++++++++++++++++++------
>  kernel/exit.c        |    2 +-
>  2 files changed, 27 insertions(+), 7 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index c021eaf..258e9eb 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -810,6 +810,11 @@ static int __prepare_descendants(struct task_struct *task, void *data)
> 
>  	ckpt_debug("consider task %d\n", task_pid_vnr(task));
> 
> +	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
> +		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
> +		return -EPERM;
> +	}
> +
>  	if (task_ptrace(task) & PT_PTRACED) {
>  		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
>  		return -EBUSY;
> @@ -935,6 +940,21 @@ static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
>  	return 0;
>  }
> 
> +static int __destroy_descendants(struct task_struct *task, void *data)
> +{
> +	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
> +
> +	if (task->checkpoint_ctx == ctx)
> +		force_sig(SIGKILL, task);
> +
> +	return 0;
> +}
> +
> +static void destroy_descendants(struct ckpt_ctx *ctx)
> +{
> +	walk_task_subtree(ctx->root_task, __destroy_descendants, ctx);
> +}
> +
>  static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  {
>  	int ret;
> @@ -972,8 +992,8 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
> 
>  	/*
>  	 * From now on we are committed to the restart. If anything
> -	 * fails, we'll wipe out the entire subtree below us, to
> -	 * ensure proper cleanup.
> +	 * fails, we'll cleanup (that is, kill) those tasks in our
> +	 * subtree that we marked for restart - see below.
>  	 */
> 
>  	if (ctx->uflags & RESTART_TASKSELF) {
> @@ -1009,13 +1029,13 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  		ckpt_debug("freezing restart tasks ... %d\n", ret);
>  	}
>   out:
> -	if (ret < 0)
> +	if (ret < 0) {
>  		ckpt_set_ctx_error(ctx, ret);
> -	else
> +		destroy_descendants(ctx);
> +	} else {
>  		ckpt_set_ctx_success(ctx);
> -
> -	if (!(ctx->uflags & RESTART_TASKSELF))
>  		wake_up_all(&ctx->waitq);
> +	}
> 
>  	set_task_ctx(current, NULL);
>  	return ret;
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 41ac4cf..cfb0f34 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -744,7 +744,7 @@ static void reparent_thread(struct task_struct *father, struct task_struct *p,
>  				struct list_head *dead)
>  {
>  	/* restarting zombie doesn't trigger signals */
> -	if (p->pdeath_signal && !(p->flags & PF_RESTARTING))
> +	if (p->pdeath_signal && !(father->flags & PF_RESTARTING))
>  		group_send_sig_info(p->pdeath_signal, SEND_SIG_NOINFO, p);
> 
>  	list_move_tail(&p->sibling, &p->real_parent->children);
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
