From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/7] move handling of err down into _ckpt_do_msg and
	_append
Date: Mon, 16 Nov 2009 14:25:47 -0500
Message-ID: <4B01A73B.9040200@cs.columbia.edu>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
	<1257465619-1777-2-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-2-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Pulled for v19-rc1.

Oren.


serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Since ckpt_err() will also be used at restart, and since at
> restart we don't want to just set ctx->err, move handling of
> the argument 'err' further down.  We only set ckpt->errno if
> err is not 0 and a checkpoint is going on.  Then we automatically
> add '[err %d] % err' if err is non-0, so that the caller has a
> choice of passing in err or passing %(E) in fmt and err as a
> vararg.
> 
> Changelog:
> 	nov 4: drop %(E) and print passed-in err instead
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/sys.c           |   51 +++++++++++++++++++++++++++----------------
>  include/linux/checkpoint.h |   16 ++++++-------
>  2 files changed, 39 insertions(+), 28 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 7d14b30..c1c4e99 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -382,14 +382,13 @@ static inline int is_special_flag(char *s)
>   * The special flags are surrounded by %() to help them visually stand
>   * out.  For instance, %(O) means an objref.  The following special
>   * flags are recognized:
> - *	E: error
>   *	O: objref
>   *	P: pointer
>   *	T: task
>   *	S: string
>   *	V: variable
>   *
> - * %(E) will be expanded to "[err %d]".  Likewise O, P, S, and V, will
> + * %(O) will be expanded to "[obj %d]".  Likewise P, S, and V, will
>   * also expand to format flags requiring an argument to the subsequent
>   * sprintf or printk.  T will be expanded to a string with no flags,
>   * requiring no further arguments.
> @@ -401,7 +400,7 @@ static inline int is_special_flag(char *s)
>   * the additional variabes, in order, to match the @fmt (except for
>   * the T key), e.g.:
>   *
> - *	ckpt_err(ctx, "%(T)FILE flags %d %(O) %(E)\n", flags, objref, err);
> + *	ckpt_err(ctx, err, "%(T)FILE flags %d %(O)\n", flags, objref);
>   *
>   * May be called under spinlock.
>   * Must be called with ctx->msg_mutex held.  The expanded format
> @@ -418,9 +417,6 @@ static void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>  			continue;
>  		}
>  		switch (fmt[2]) {
> -		case 'E':
> -			len += snprintf(s+len, CKPT_MSG_LEN-len, "[err %%d]");
> -			break;
>  		case 'O':
>  			len += snprintf(s+len, CKPT_MSG_LEN-len, "[obj %%d]");
>  			break;
> @@ -455,24 +451,41 @@ static void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>  		s[len] = '\0';
>  }
>  
> -static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, char *fmt, va_list ap)
> +static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
> +				va_list ap)
>  {
>  	int len = ctx->msglen;
>  
> +	if (err) {
> +		/* At restart we must use a more baroque helper to set
> +		 * ctx->errno, which also wakes all other waiting restarting
> +		 * tasks.  But at checkpoint we just set ctx->errno so that
> +		 * _ckpt_msg_complete() will know to write the error message
> +		 * to the checkpoint image.
> +		 */
> +		if (ctx->kflags & CKPT_CTX_CHECKPOINT && !ctx->errno)
> +			ctx->errno = err;
> +		len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[err %d]",
> +				 err);
> +		if (len > CKPT_MSG_LEN)
> +			goto full;
> +	}
> +
>  	len += vsnprintf(&ctx->msg[len], CKPT_MSG_LEN-len, fmt, ap);
>  	if (len > CKPT_MSG_LEN) {
> +full:
>  		len = CKPT_MSG_LEN;
>  		ctx->msg[CKPT_MSG_LEN-1] = '\0';
>  	}
>  	ctx->msglen = len;
>  }
>  
> -void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...)
> +void _ckpt_msg_append(struct ckpt_ctx *ctx, int err, char *fmt, ...)
>  {
>  	va_list ap;
>  
>  	va_start(ap, fmt);
> -	_ckpt_msg_appendv(ctx, fmt, ap);
> +	_ckpt_msg_appendv(ctx, err, fmt, ap);
>  	va_end(ap);
>  }
>  
> @@ -507,25 +520,25 @@ void _ckpt_msg_complete(struct ckpt_ctx *ctx)
>  	ctx->msglen = 0;
>  }
>  
> -#define __do_ckpt_msg(ctx, fmt) do {		\
> -	va_list ap;				\
> -	_ckpt_generate_fmt(ctx, fmt);		\
> -	va_start(ap, fmt);			\
> -	_ckpt_msg_appendv(ctx, ctx->fmt, ap);	\
> -	va_end(ap);				\
> +#define __do_ckpt_msg(ctx, err, fmt) do {		\
> +	va_list ap;					\
> +	_ckpt_generate_fmt(ctx, fmt);			\
> +	va_start(ap, fmt);				\
> +	_ckpt_msg_appendv(ctx, err, ctx->fmt, ap);	\
> +	va_end(ap);					\
>  } while (0)
>  
> -void _do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...)
> +void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
>  {
> -	__do_ckpt_msg(ctx, fmt);
> +	__do_ckpt_msg(ctx, err, fmt);
>  }
>  
> -void do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...)
> +void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
>  {
>  	if (!ctx) return;
>  
>  	ckpt_msg_lock(ctx);
> -	__do_ckpt_msg(ctx, fmt);
> +	__do_ckpt_msg(ctx, err, fmt);
>  	_ckpt_msg_complete(ctx);
>  	ckpt_msg_unlock(ctx);
>  }
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 89e6fb3..8fd6cba 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -384,7 +384,7 @@ extern void ckpt_msg_unlock(struct ckpt_ctx *ctx);
>   * May be called under spinlock.
>   * Must be called under ckpt_msg_lock().
>   */
> -extern void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...);
> +extern void _ckpt_msg_append(struct ckpt_ctx *ctx, int err, char *fmt, ...);
>  
>  /*
>   * Write ctx->msg to all relevant places.
> @@ -399,7 +399,7 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
>   * the caller will have to use _ckpt_msg_complete() to finish up.
>   * Must be called with ckpt_msg_lock held.
>   */
> -extern void _do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...);
> +extern void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...);
>  
>  /*
>   * Append an enhanced formatted message to ctx->msg.
> @@ -411,12 +411,11 @@ extern void _do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...);
>   *
>   * Must not be called under spinlock.
>   */
> -extern void do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...);
> +extern void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...);
>  
>  #define ckpt_err(ctx, err, fmt, args...) do {					\
> -	ctx->errno = (err);							\
> -	do_ckpt_msg(ctx, "[Error at %s:%d][err %d]" fmt, __func__, __LINE__,	\
> -			(err), ##args);						\
> +	do_ckpt_msg(ctx, (err), "[Error at %s:%d]" fmt, __func__, __LINE__,	\
> +			##args);						\
>  } while (0)
>  
>  
> @@ -427,9 +426,8 @@ extern void do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...);
>   *	must be followed by a call to _ckpt_msg_complete()
>   */
>  #define _ckpt_err(ctx, err, fmt, args...) do {					\
> -	ctx->errno = (err);							\
> -	_do_ckpt_msg(ctx, "[ error %s:%d][err %d]" fmt, __func__, __LINE__,	\
> -			(err), ##args);						\
> +	_do_ckpt_msg(ctx, (err), "[Error at %s:%d]" fmt, __func__, __LINE__,	\
> +			##args);						\
>  } while (0)
>  
>  #endif /* CONFIG_CHECKPOINT */
