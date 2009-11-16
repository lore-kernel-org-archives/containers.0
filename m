From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] [RFC] checkpoint/restart timerfd
Date: Mon, 16 Nov 2009 13:56:03 -0500
Message-ID: <4B01A043.3010001@cs.columbia.edu>
References: <96703bfb68e1626100dd5fa6ce033ec204bcb58b.1258159772.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <96703bfb68e1626100dd5fa6ce033ec204bcb58b.1258159772.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Matt Helsley wrote:
> Support checkpoint/restart of timers specified via timerfd. Checkpoint
> essentially does the timerfd_gettime() syscall and saves the expired flags
> and tick count. This ensures there will be no lost expirations/ticks
> between checkpoint restart.
> 
> This should largely work as expected since the time returned from gettime
> is always relative.
> 
> However, like any time-sensitive state, timerfds set with TFD_TIMER_ABSTIME
> may expire/tick at the "wrong time" because that time has long since passed.
> Short of introducing time namespaces there's almost nothing that can be done
> to checkpoint these uses of timerfd. Would it make more sense to mark timerfds
> which were (re)set with TFD_TIMER_ABSTIME and refuse to checkpoint them rather
> than deliver a "best-effort" expiration/tick?
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

> +
> +#ifdef CONFIG_CHECKPOINT
> +static int timerfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
> +{
> +	struct itimerspec kotmr;
> +	struct timerfd_ctx *ctx;
> +	struct ckpt_hdr_file_timerfd *h;
> +	int ret = -ENOMEM;
> +
> +	h = ckpt_hdr_get_type(ckpt_ctx, sizeof(*h), CKPT_HDR_FILE);
> +	if (!h)
> +		return -ENOMEM;
> +	h->common.f_type = CKPT_FILE_EVENTFD;
> +	ret = checkpoint_file_common(ckpt_ctx, file, &h->common);
> +	if (ret < 0)
> +		goto out;
> +
> +	ctx = file->private_data;
> +	/*
> +	 * There is no way to recover the hrtimer mode or flags
> +	 * used during create or settime. Rely on the timerfd state
> +	 * to reflect those.
> +	 */
> +	spin_lock_irq(&ctx->wqh.lock);
> +	h->expired = ctx->expired; /* must precede __timerfd_gettime() */
> +	h->ticks = ctx->ticks; /* must precede __timerfd_gettime() */
> +	h->clockid = ctx->clockid;
> +	__timerfd_gettime(ctx, &kotmr);
> +	spin_unlock_irq(&ctx->wqh.lock);

Can this have a race with the signal c/r code ?  E.g. first we
record a timer which is about to expire, then it expires, and
then we record the pending signals which include a signal from
this timer:  the restarted task will have the signal pending
and soon after the timer will expire and possibly generate a
second signal ?

> +	ckpt_copy_itimerspec(CKPT_CPT, &h->spec, &kotmr);
> +	ret = ckpt_write_obj(ckpt_ctx, &h->common.h);
> +out:
> +	ckpt_hdr_put(ckpt_ctx, h);
> +	return ret;
> +}
> +
> +struct file *timerfd_restore(struct ckpt_ctx *ckpt_ctx,
> +			     struct ckpt_hdr_file *ptr)
> +{
> +	struct itimerspec dotmr; /* dummy */
> +	struct itimerspec kitmr;
> +	struct ckpt_hdr_file_timerfd *h = (struct ckpt_hdr_file_timerfd *)ptr;
> +	struct file *file;
> +	struct timerfd_ctx *ctx;
> +	int ufd, ret;
> +
> +	/* Known: CKPT_HDR_FILE and f_type == CKPT_FILE_TIMERFD */
> +	if ((h->common.h.len != sizeof(*h)) ||
> +	    (h->common.f_flags & ~TFD_SHARED_FCNTL_FLAGS))
> +		return ERR_PTR(-EINVAL);
> +
> +	/* Fail early if the timespecs are bad */
> +	ckpt_copy_itimerspec(CKPT_RST, &h->spec, &kitmr);
> +	if (!timespec_valid(&kitmr.it_value) ||
> +	    !timespec_valid(&kitmr.it_interval))
> +		return ERR_PTR(-EINVAL);
> +
> +	ufd = sys_timerfd_create(h->clockid,
> +				 h->common.f_flags & TFD_SHARED_FCNTL_FLAGS);
> +	if (ufd < 0)
> +		return ERR_PTR(ufd);
> +	file = fget(ufd);
> +	sys_close(ufd);
> +	if (!file)
> +		return ERR_PTR(-EBUSY);
> +
> +	ret = restore_file_common(ckpt_ctx, file, &h->common);
> +	if (ret < 0) {
> +		fput(file);
> +		return ERR_PTR(ret);
> +	}
> +
> +	ctx = file->private_data;
> +#define TFD_TIMER_RELTIME 0
> +	ret = sys_timerfd_settime(ufd, TFD_TIMER_RELTIME,
> +				  &kitmr, &dotmr);
> +	/* Is there a race here between settime and spin_lock()? */
> +	spin_lock_irq(&ctx->wqh.lock);
> +	ctx->expired = h->expired;
> +	ctx->ticks = h->ticks;
> +	spin_unlock_irq(&ctx->wqh.lock);
> +	return file;
> +}
> +#else
> +#define timerfd_checkpoint NULL
> +#endif
> +
>  static const struct file_operations timerfd_fops = {
>  	.release	= timerfd_release,
>  	.poll		= timerfd_poll,
>  	.read		= timerfd_read,
> +	.checkpoint     = timerfd_checkpoint,
>  };
>  
>  static struct file *timerfd_fget(int fd)
> @@ -275,19 +377,10 @@ SYSCALL_DEFINE2(timerfd_gettime, int, ufd, struct itimerspec __user *, otmr)
>  	if (IS_ERR(file))
>  		return PTR_ERR(file);
>  	ctx = file->private_data;
> -
>  	spin_lock_irq(&ctx->wqh.lock);
> -	if (ctx->expired && ctx->tintv.tv64) {
> -		ctx->expired = 0;
> -		ctx->ticks +=
> -			hrtimer_forward_now(&ctx->tmr, ctx->tintv) - 1;
> -		hrtimer_restart(&ctx->tmr);
> -	}
> -	kotmr.it_value = ktime_to_timespec(timerfd_get_remaining(ctx));
> -	kotmr.it_interval = ktime_to_timespec(ctx->tintv);
> +	__timerfd_gettime(ctx, &kotmr);
>  	spin_unlock_irq(&ctx->wqh.lock);
>  	fput(file);
> -
>  	return copy_to_user(otmr, &kotmr, sizeof(kotmr)) ? -EFAULT: 0;
>  }
>  
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index dfcb59b..f429386 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -321,6 +321,17 @@ static inline int ckpt_validate_errno(int errno)
>  			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
>  	} while (0)
>  
> +struct ckpt_itimerspec;
> +struct itimerspec;
> +static inline void ckpt_copy_itimerspec(int op, struct ckpt_itimerspec *h,
> +					struct itimerspec *tmr)
> +{
> +	CKPT_COPY(op, h->interval.tv_sec,  tmr->it_interval.tv_sec);
> +	CKPT_COPY(op, h->interval.tv_nsec, tmr->it_interval.tv_nsec);
> +	CKPT_COPY(op, h->value.tv_sec,     tmr->it_value.tv_sec);
> +	CKPT_COPY(op, h->value.tv_nsec,    tmr->it_value.tv_nsec);
> +}
> +

Is there a reason to place this here and not in timerfd source file ?

>  /* debugging flags */
>  #define CKPT_DBASE	0x1		/* anything */
>  #define CKPT_DSYS	0x2		/* generic (system) */

[...]

Oren.
