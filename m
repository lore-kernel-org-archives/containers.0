From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/7] restart.c: use ckpt_err
Date: Mon, 16 Nov 2009 11:02:08 -0500
Message-ID: <4B017780.6080609@cs.columbia.edu>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
	<1257465619-1777-3-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-3-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Changelog:
> 	Nove 4: update restart.c ckpt_err usage
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/restart.c |   81 +++++++++++++++++++++++++++++++++++---------------
>  1 files changed, 57 insertions(+), 24 deletions(-)

Is it your intent to entirely get rid of ckpt_debug() ?

We originally discussed two levels of details: only error status
or a detailed log (and we also thought of a detailed debug, that can
be compiled out to save space). How does that fit with the patch(es) ?

To "define" what's "error status" and what's "log" (and maybe what's
"debug"), I suggest a test like:

1) error status: what conveys the most specific reason of failure,
e.g. "failed to open file to restore fd";  The caller should be able
to assume that the total message(s) length will not exceed a pipe
buffer.

2) log status: that gives status about progress, or what lead to and
what followed an error, e.g. file open failure may have happened
when restoring a file descriptor, or when restore a vma, so a log
like "failed to restore vma" would be helpful.

3) debug status: that we want to be able to compile out without having
to reintroduce it for every bug that it may help us debug.

> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 130b4b2..e1bd0ad 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -64,7 +64,7 @@ static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
>  
>  	s = kmalloc(sizeof(*s), GFP_KERNEL);
>  	if (!s) {
> -		ckpt_debug("no memory to register ?!\n");
> +		ckpt_err(ctx, 0, "no memory to register ?!\n");
>  		return -ENOMEM;

What is the purpose in passing '0' instead of -ENOMEM to ckpt_err() ?
(a few more instances below).

>  	}
>  	s->pid = current->pid;
> @@ -197,13 +197,13 @@ static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
>  	len = h->len - sizeof(*h);
>  	ptr = kzalloc(len + 1, GFP_KERNEL);
>  	if (!ptr) {
> -		ckpt_debug("insufficient memory to report image error\n");
> +		ckpt_err(ctx, 0, "insufficient memory to report image error\n");
>  		return -ENOMEM;
>  	}
>  
>  	ret = ckpt_kread(ctx, ptr, len);
>  	if (ret >= 0) {
> -		ckpt_debug("%s\n", &ptr[1]);
> +		ckpt_err(ctx, 0, "%(S)Error recorded in image\n", &ptr[1]);
>  		ret = -EIO;
>  	}
>  
> @@ -757,7 +757,8 @@ static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
>  		task->checkpoint_ctx = ckpt_ctx_get(ctx);
>  		ret = 0;
>  	} else {
> -		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
> +		ckpt_err(ctx, 0, "task %d already has checkpoint_ctx\n",
> +			 task_pid_vnr(task));
>  		ret = 1;
>  	}
>  	task_unlock(task);
> @@ -807,7 +808,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
>  		rcu_read_unlock();
>  
>  		if (!task) {
> -			ckpt_debug("could not find task %d\n", pid);
> +			ckpt_err(ctx, 0, "could not find task %d\n", pid);
>  			restore_notify_error(ctx, -ESRCH);
>  			return -ESRCH;
>  		}
> @@ -962,29 +963,38 @@ static int do_restore_task(void)
>  	current->flags |= PF_RESTARTING;
>  
>  	ret = wait_sync_threads();
> -	if (ret < 0)
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "wait_sync_threads\n");

(#3) - The only error in wait_sync_threads() can be EINTR, so this
is only necessary for our debugging.

>  		goto out;
> +	}
>  
>  	/* wait for our turn, do the restore, and tell next task in line */
>  	ret = wait_task_active(ctx);
> -	if (ret < 0)
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "wait_task_active\n");

Ditto (it could also be EBUSY - but there are ckpt_debug() statements
there).

>  		goto out;
> +	}
>  
>  	restore_debug_running(ctx);
>  
>  	ret = pre_restore_task();
> -	if (ret < 0)
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "pre_restore_task\n");
>  		goto out;
> +	}
>  
>  	zombie = restore_task(ctx);
>  	if (zombie < 0) {
>  		ret = zombie;
> +		ckpt_err(ctx, ret, "restore_task\n");

I'd assume that restore_task() will already have reported a specific
error that caused the failure. So we can save on code size but not
compiling this in when non-debug.

>  		goto out;
>  	}
>  
>  	ret = restore_activate_next(ctx);
> -	if (ret < 0)
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "restore_activate_next\n");
>  		goto out;
> +	}
>  
>  	/*
>  	 * zombie: we're done here; do_exit() will notice the @ctx on
> @@ -1025,12 +1035,12 @@ static int __prepare_descendants(struct task_struct *task, void *data)
>  	ckpt_debug("consider task %d\n", task_pid_vnr(task));
>  
>  	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
> -		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
> +		ckpt_err(ctx, 0, "stranger task %d\n", task_pid_vnr(task));

This is called with tasklist_lock taken...

>  		return -EPERM;
>  	}
>  
>  	if (task_ptrace(task) & PT_PTRACED) {
> -		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
> +		ckpt_err(ctx, 0, "ptraced task %d\n", task_pid_vnr(task));

And here too.

>  		return -EBUSY;
>  	}
>  

[...]

There are similar comments also below.

Are you still concerned about the increase in code size with c/r ?

Oren.
