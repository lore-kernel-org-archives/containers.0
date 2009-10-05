From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: threads sync on restart (fix regression from
	commit afbe522c...)
Date: Sun, 4 Oct 2009 22:28:11 -0500
Message-ID: <20091005032811.GA32201@us.ibm.com>
References: <1254610422-11441-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254610422-11441-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
> Initialize the new member signal->restart_count in copy_signal().
> 
> The lack of which in commit afbe522ccf6b1deb5edfc01a00becfe6ee325d0c,
> c/r: let entire thread group in sys_restart before restoring a thread,
> can cause run-pthreads1.sh test failure.
> 
> In this patch are two other small cleanups:
> 
> 1) In post_restore_task() test if current->checkpoint_data is valid,
> and return immediately if not (meaning restart failed early).
> 
> 2) Replace two instances of DECLARE_WAIT_QUEUE_HEAD(waitq) with
> DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq), to please the lockdep checked.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks,
-serge

> ---
>  checkpoint/process.c |    4 ++++
>  checkpoint/restart.c |    4 ++--
>  kernel/fork.c        |    4 ++++
>  3 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index c2832fe..424f688 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -847,6 +847,10 @@ int pre_restore_task(struct ckpt_ctx *ctx)
>  /* pre_restore_task - prepare the task for restore */
>  void post_restore_task(struct ckpt_ctx *ctx)
>  {
> +	/* can happen if restart failed early */
> +	if (!current->checkpoint_data)
> +		return;
> +
>  	/* only now is it safe to unblock the restored task's signals */
>  	sigprocmask(SIG_SETMASK, &current->checkpoint_data->blocked, NULL);
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index b2dc139..3a58a76 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -821,7 +821,7 @@ static int wait_task_sync(struct ckpt_ctx *ctx)
>  /* grabs a reference to the @ctx on success; caller should free */
>  static struct ckpt_ctx *wait_checkpoint_ctx(void)
>  {
> -	DECLARE_WAIT_QUEUE_HEAD(waitq);
> +	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
>  	struct ckpt_ctx *ctx;
>  	int ret;
> 
> @@ -912,7 +912,7 @@ static int wait_sync_threads(void)
>  			wake_up_process(p);
>  		read_unlock(&tasklist_lock);
>  	} else {
> -		DECLARE_WAIT_QUEUE_HEAD(waitq);
> +		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(waitq);
>  		ret = wait_event_interruptible(waitq, !atomic_read(count));
>  	}
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 0e226f5..04dffe9 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -865,6 +865,10 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
> 
>  	tty_audit_fork(sig);
> 
> +#ifdef CONFIG_CHECKPOINT
> +	atomic_set(&sig->restart_count, 0);
> +#endif
> +
>  	return 0;
>  }
> 
> -- 
> 1.6.0.4
