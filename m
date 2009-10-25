From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] define function to print error messages to user log
Date: Sun, 25 Oct 2009 13:58:35 -0400
Message-ID: <4AE491CB.60109@librato.com>
References: <20091023041325.GA2863@us.ibm.com>
	<20091023041349.GA2915@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091023041349.GA2915-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Error messages are both sent to an optional user-provided logfile,
> and, if CONFIG_CHECKPOINT_DEBUG=y, sent to syslog.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c             |    2 +
>  checkpoint/sys.c                 |   61 ++++++++++++++++++++++++++++++++++---
>  include/linux/checkpoint.h       |    2 +-
>  include/linux/checkpoint_types.h |    1 +
>  include/linux/syscalls.h         |    5 ++-
>  5 files changed, 63 insertions(+), 8 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 730dd82..c441ce6 100644
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
> index 260a1ee..1840f90 100644
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
> @@ -238,6 +240,9 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
>  	ctx->kflags = kflags;
>  	ctx->ktime_begin = ktime_get();
>  
> +	/* If logfd's a bad fd that's fine, no log output required... */
> +	ctx->logfile = fget(logfd);

Can we make it more user-friendly, e.g. f logfd==-1 then no logfile,
otherwise if fget(logfd) fails then return -EBADF ?

> +
>  	atomic_set(&ctx->refcount, 0);
>  	INIT_LIST_HEAD(&ctx->pgarr_list);
>  	INIT_LIST_HEAD(&ctx->pgarr_pool);
> @@ -339,6 +344,51 @@ int walk_task_subtree(struct task_struct *root,
>  	return (ret < 0 ? ret : total);
>  }
>  
> +/*
> + * currentpid:targetpid fmt%args
> + */
> +void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
> +{

As I commented before, I really wish not to go through this again.
Can we come up with a mechanism for error messages, that will set
a "standard" format (like I tried to do in ckpt_write_err) ?

(I like Matt's suggestion to use one format string instead of two,
and allow "%(T)" constructs for our format directives).

Also, I assume some of that code can be reused here below.

> +	mm_segment_t fs;
> +	struct file *file;
> +	int count;
> +	char buf[200], *bufp = buf;
> +	int mypid = current->pid;
> +	int tpid = current->nsproxy ? task_pid_vnr(current) : -1;
> +	va_list args;
> +
> +	if (!ctx || !ctx->logfile)
> +		return;
> +	file = ctx->logfile;
> +
> +	count = snprintf(buf, 200, "%d:%d ", mypid, tpid);
> +	if (count > 200)
> +		return; /* not possible */
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +	_ckpt_kwrite(file, bufp, count);
> +	set_fs(fs);
> +
> +	va_start(args, fmt);
> +	count = vsnprintf(bufp, 200, fmt, args);
> +	va_end(args);
> +	if (count > 200) {
> +		bufp = kmalloc(count, GFP_KERNEL);
> +		if (!bufp)
> +		       return;
> +		va_start(args, fmt);
> +		vsnprintf(bufp, count, fmt, args);
> +		va_end(args);
> +	}
> +
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +	_ckpt_kwrite(file, bufp, count);
> +	set_fs(fs);
> +
> +	if (bufp != buf)
> +		kfree(bufp);
> +}

The rest looks ok.

Oren.
