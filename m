From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: coordinator to report correct error on restart
	failure
Date: Mon, 26 Oct 2009 13:35:31 -0500
Message-ID: <20091026183531.GJ23564@us.ibm.com>
References: <1256509416-3897-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256509416-3897-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
> If restart fails it is usually due to an error for a restoring task,
> which is place in ctx->errno. Then the coordinator wakes up and sees
> an -EINTR.
> 
> This patch changes the coordinator's behavior to report the error
> value placed in ctx->errno (if an error occurred) rather than report
> a confusing -EINTR.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/restart.c |   15 +++++++++++++--
>  1 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 5daadc4..9b75de8 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -711,7 +711,7 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
>  }
> 
>  /* should not be called under write_lock_irq(&tasklist_lock) */
> -static inline void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
> +static void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
>  {
>  	/* first to fail: notify everyone (racy but harmless) */
>  	if (!ckpt_test_ctx_error(ctx)) {
> @@ -1263,9 +1263,20 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
>  		post_restore_task();
> 
>  	restore_debug_error(ctx, ret);
> -	if (ret < 0) {
> +
> +	if (ret < 0)
>  		ckpt_set_ctx_error(ctx, ret);
> +
> +	if (ckpt_test_ctx_error(ctx)) {
>  		destroy_descendants(ctx);
> +		/*
> +		 * If a restaring task (or we) reported an error, that set
> +		 * out return value to that error. (Need the unlikely loop
> +		 * because the error is recorded after the flag is set).
> +		 */
> +		while (!ctx->errno)
> +			yield();
> +		ret = ctx->errno;
>  	} else {
>  		ckpt_set_ctx_success(ctx);
>  		wake_up_all(&ctx->waitq);
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
