From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 11/17] define function to print error messages to
	user log
Date: Wed, 28 Oct 2009 11:14:15 -0700
Message-ID: <20091028181415.GB14023@count0.beaverton.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
	<1256683587-23961-12-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256683587-23961-12-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 27, 2009 at 05:46:21PM -0500, Serge Hallyn wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Error messages are both sent to an optional user-provided logfile,
> and, if CONFIG_CHECKPOINT_DEBUG=y, sent to syslog.
> 
> Changelog:
> 	Oct 27: add %(C) for ctx->total.
> 	Oct 26: Per Oren suggestion, return -EBADF for bad
> 		logfile in ckpt_ctx_alloc().
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/objhash.c             |    2 +
>  checkpoint/sys.c                 |   67 +++++++++++++++++++++++++++++++++++---
>  include/linux/checkpoint.h       |    5 +++
>  include/linux/checkpoint_types.h |    1 +
>  include/linux/syscalls.h         |    5 ++-
>  5 files changed, 73 insertions(+), 7 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index a152e69..25b9c10 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -858,6 +858,8 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
> 
>  	/* account for ctx->file reference (if in the table already) */
>  	ckpt_obj_users_inc(ctx, ctx->file, 1);
> +	if (ctx->logfile)
> +		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
>  	/* account for ctx->root_nsproxy reference (if in the table already) */
>  	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 38e65e4..ab0f294 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -204,6 +204,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
> 
>  	if (ctx->file)
>  		fput(ctx->file);
> +	if (ctx->logfile)
> +		fput(ctx->logfile);
> 
>  	ckpt_obj_hash_free(ctx);
>  	path_put(&ctx->fs_mnt);
> @@ -225,7 +227,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
>  }
> 
>  static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
> -				       unsigned long kflags)
> +				       unsigned long kflags, int logfd)
>  {
>  	struct ckpt_ctx *ctx;
>  	int err;
> @@ -254,6 +256,12 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
>  	if (!ctx->file)
>  		goto err;
> 
> +	if (logfd != -1) {
> +		ctx->logfile = fget(logfd);
> +		if (!ctx->logfile)
> +			goto err;
> +	}
> +
>  	err = -ENOMEM;
>  	if (ckpt_obj_hash_alloc(ctx) < 0)
>  		goto err;
> @@ -401,6 +409,9 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>  		case 'E':
>  			len += sprintf(format+len, "[%s]", "err %d");
>  			break;
> +		case 'C': /* count of bytes read/written to checkpoint image */
> +			len += sprintf(format+len, "[%s]", "pos %d");
> +			break;

Instead we could always output ckpt->total and then we wouldn't need %(C). I
suspect it's such a useful piece of information that it'll be repeated
in many/all format strings eventually.

>  		case 'O':
>  			len += sprintf(format+len, "[%s]", "obj %d");
>  			break;
> @@ -435,6 +446,51 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
>  	return format;
>  }
> 
> +void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
> +{
> +	mm_segment_t fs;
> +	struct file *file;
> +	int count;
> +	va_list ap, aq, az;
> +	char *format;
> +	char buf[200], *bufp = buf;

I believe this buffer is too big for a kernel stack -- especially
for ckpt_log_error() which might be invoked "deep" in
the kernel stack.

> +
> +	if (!ctx || !ctx->logfile)
> +		return;
> +	file = ctx->logfile;
> +
> +	va_start(ap, fmt);
> +	format = ckpt_generate_fmt(ctx, fmt);
> +	va_copy(aq, ap);
> +	va_copy(az, ap);
> +	/* I'm not clear here - can I re-use aq, or do i need
> +	 * a third copy? */

I'm no varargs expert but I have re-read the man page and
seen a purported snippet of the standard. :)

I think you need a third copy operation but you may only need
two va_lists so long as you do a va_end before the next va_copy:

	va_copy(aq, ap);
	... <use aq> ...
	va_end(aq);
	va_copy(aq, ap);
	... <use aq> ...
	va_end(aq);
	...
	va_end(ap); 

Based on my reading it sounded like some arch/ABIs require space
proportional to the number of arguments for each un-va_end-ed copy.

> +	count = vsnprintf(bufp, 200, format ? : fmt, aq);

BTW -- I think you can use snprintf() without the buffer and length
arguments if you just need the length calculated. Perhaps the same
is possible with vsnprintf():

	count = vsnprintf(NULL, 0, format ? : fmt, aq);

If that works with vsnprintf() too then you could get rid of the
stack buf and always kmalloc the space..

Cheers,
	-Matt Helsley
