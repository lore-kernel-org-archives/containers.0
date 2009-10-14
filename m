From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/4] pre/post_restore_task: Do not pass checkpoint context
	when unused
Date: Wed, 14 Oct 2009 18:34:15 -0400
Message-ID: <4AD651E7.4020800@librato.com>
References: <1255481585-32625-3-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1255481585-32625-3-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Pulled.

Matt Helsley wrote:
> The checkpoint context is not used in these functions -- they only rely
> on current -- so it's safe to remove.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/process.c       |    4 ++--
>  checkpoint/restart.c       |   10 +++++-----
>  include/linux/checkpoint.h |    4 ++--
>  3 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index 17c08e8..4008529 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -815,7 +815,7 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
>  }
>  
>  /* prepare the task for restore */
> -int pre_restore_task(struct ckpt_ctx *ctx)
> +int pre_restore_task(void)
>  {
>  	sigset_t sigset;
>  
> @@ -844,7 +844,7 @@ int pre_restore_task(struct ckpt_ctx *ctx)
>  	return 0;
>  }
>  
> -void post_restore_task(struct ckpt_ctx *ctx)
> +void post_restore_task(void)
>  {
>  	/* can happen if restart failed early */
>  	if (!current->checkpoint_data)
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index fc94374..6679472 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -945,7 +945,7 @@ static int do_restore_task(void)
>  
>  	restore_debug_running(ctx);
>  
> -	ret = pre_restore_task(ctx);
> +	ret = pre_restore_task();
>  	if (ret < 0)
>  		goto out;
>  
> @@ -967,7 +967,7 @@ static int do_restore_task(void)
>  	 */
>  	if (zombie) {
>  		restore_debug_exit(ctx);
> -		post_restore_task(ctx);
> +		post_restore_task();
>  		ckpt_ctx_put(ctx);
>  		do_exit(current->exit_code);
>  	}
> @@ -979,7 +979,7 @@ static int do_restore_task(void)
>  	if (ret < 0)
>  		restore_notify_error(ctx, ret);
>  
> -	post_restore_task(ctx);
> +	post_restore_task();
>  	current->flags &= ~PF_RESTARTING;
>  	clear_task_ctx(current);
>  	ckpt_ctx_put(ctx);
> @@ -1196,7 +1196,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  	 */
>  
>  	if (ctx->uflags & RESTART_TASKSELF) {
> -		ret = pre_restore_task(ctx);
> +		ret = pre_restore_task();
>  		ckpt_debug("pre restore task: %d\n", ret);
>  		if (ret < 0)
>  			goto out;
> @@ -1233,7 +1233,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  	}
>   out:
>  	if (ctx->uflags & RESTART_TASKSELF)
> -		post_restore_task(ctx);
> +		post_restore_task();
>  
>  	restore_debug_error(ctx, ret);
>  	if (ret < 0) {
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index dd75bc2..4b61378 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -154,8 +154,8 @@ extern int ckpt_activate_next(struct ckpt_ctx *ctx);
>  extern int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t);
>  extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
>  extern int restore_task(struct ckpt_ctx *ctx);
> -extern int pre_restore_task(struct ckpt_ctx *ctx);
> -extern void post_restore_task(struct ckpt_ctx *ctx);
> +extern int pre_restore_task(void);
> +extern void post_restore_task(void);
>  
>  /* arch hooks */
>  extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
