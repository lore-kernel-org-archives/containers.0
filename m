From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 10/17] define function to print error messages to user log
Date: Thu, 29 Oct 2009 18:43:10 -0400
Message-ID: <4AEA1A7E.1050509@librato.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
	<1256849682-858-11-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-11-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Error messages are both sent to an optional user-provided logfile,
> and, if CONFIG_CHECKPOINT_DEBUG=y, sent to syslog.
> 
> Changelog:
> 	Oct 29: Split ckpt_log_error() into ckpt_log_error_v() and have
> 		ckpt_write_err() call it to duplicate the checkpoint
> 		error message into the optional user-provided log file and
> 		(if CONFIG_CHECKPOINT_DEBUG=y) syslog as well.
> 		Define a fn writing an error prefix (containing
> 		current->pid etc) for ckpt_error().
> 	Oct 28: Don't use a third va_args, and use smaller on-stack
> 		buffer (mhelsley comments).  It still might be cleaner
> 		to always kmalloc, but always using two kmallocs per
> 		ckpt_error is getting kinda gross...  (open to comments
> 		on that).
> 	Oct 26: Per Oren suggestion, return -EBADF for bad
> 		logfile in ckpt_ctx_alloc().
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c          |    8 +++-
>  checkpoint/objhash.c             |    2 +
>  checkpoint/sys.c                 |   91 ++++++++++++++++++++++++++++++++++----
>  include/linux/checkpoint.h       |    5 ++
>  include/linux/checkpoint_types.h |    5 ++
>  include/linux/syscalls.h         |    5 +-
>  6 files changed, 103 insertions(+), 13 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 35fce15..30ec622 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -123,8 +123,6 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
>  
>  	va_end(aq);
>  	kfree(format);
> -
> -	ckpt_debug("c/r: checkpoint error: %s\n", str);
>  }
>  
>  /**
> @@ -140,9 +138,15 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
>  {
>  	va_list ap;
>  
> +	/* write to checkpoint file */
>  	va_start(ap, fmt);
>  	__ckpt_generate_err(ctx, fmt, ap);
>  	va_end(ap);
> +
> +	/* write to user log and syslog */
> +	va_start(ap, fmt);
> +	ckpt_log_error_v(ctx, fmt, ap);
> +	va_end(ap);
>  }

__ckpt_write_err() can be called from spinlock context, so
it needs to remain as is.

Instead, call ckpt_log_error_v() from ckpt_write_err(), and if
the have ckpt_log_error_v() also avoid calling __ckpt_generate_err()
if the @fmt string is NULL, instead take from @ctx->err_string.

To be complete, we probably also need ckpt_log_{un,}lock(), that
are used in ckpt_log_error_v() and should also be used by whoever
uses _ckpt_write_err() directly.

Also, in light of my suggestion in the other email, maybe rename
ckpt_generate_err() to ckpt_generate_msg().

Oren.
