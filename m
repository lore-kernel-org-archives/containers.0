From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 01/17] ckpt_write_err: use single format with %(T)
	style tokens
Date: Thu, 29 Oct 2009 23:37:12 -0700
Message-ID: <20091030063712.GA409@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
	<1256849682-858-2-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256849682-858-2-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| 
| Matt Helsley originally suggested this to avoid having two
| format strings.  This is not bisect-safe and therefore not
| even compile-tested.  Every call to ckpt_write_err must be
| updated to use a single format.

It maybe easier to review this patch if this is broken up into smaller
patches:

	- move the code to new place
	- leave the fmt0 parameter to ckpt_generate_fmt() but ensure it
	  is unused.
	- finally remove the unused parameters from ckpt_generate_fmt()
	  and the callers. 

| 
| Changelog:
| 	Oct 29: merge with the next patch, moving ckpt_generate_fmt()
| 		into checkpoing/sys.c and making it non-static so that
| 		we can use it in ckpt_error().
| 	Oct 28: also fix comment above ckpt_generate_fmt()
| 	Oct 27: ensure %(T) has a closing paren
| 
| Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| ---
|  checkpoint/checkpoint.c    |  105 +++-----------------------------------------
|  checkpoint/sys.c           |   95 +++++++++++++++++++++++++++++++++++++++
|  include/linux/checkpoint.h |   13 +++--
|  3 files changed, 110 insertions(+), 103 deletions(-)
| 
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| index 6eb8f3b..c6be4f9 100644
| --- a/checkpoint/checkpoint.c
| +++ b/checkpoint/checkpoint.c
| @@ -96,104 +96,15 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
|  	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
|  }
| 
| -/*
| - * __ckpt_generate_fmt - generate standard checkpoint error message
| - * @ctx: checkpoint context
| - * @fmt0: c/r-format string
| - * @fmt: message format
| - *
| - * This generates a unified format of checkpoint error messages, to
| - * ease (after the failure) inspection by userspace tools. It converts
| - * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
| - *
| - * PREFMT is constructed from @fmt0 by subtituting format snippets
| - * according to the contents of @fmt0.

| - * The format characters in
| - * @fmt0 can be E (error), O (objref), P (pointer), S (string) and
| - * V (variable/symbol). For example, E will generate a "err %d" in
| - * PREFMT (see prefmt_array below).
| - *
| - * If @fmt0 begins with T, PREFMT will begin with "pid %d tsk %s"
| - * with the pid and the tsk->comm of the currently checkpointed task.
| - * The latter is taken from ctx->tsk, and is it the responsbilility of
| - * the caller to have a valid pointer there (in particular, functions
| - * that iterate on the processes: collect_objects, checkpoint_task,
| - * and tree_count_tasks).
| - *
| - * The caller of ckpt_write_err() and _ckpt_write_err() must provide
| - * the additional variabes, in order, to match the @fmt0 (except for
| - * the T key), e.g.:
| - *
| - *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);
| - *
| - * Here, T is simply passed, E expects an integer (err), O expects an
| - * integer (objref), and the last argument matches the format string.
| - */
| -static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
| -{
| -	static int warn_notask = 0;
| -	static int warn_prefmt = 0;
| -	char *format;
| -	int i, j, len = 0;
| -
| -	static struct {
| -		char key;
| -		char *fmt;
| -	} prefmt_array[] = {
| -		{ 'E', "err %d" },
| -		{ 'O', "obj %d" },
| -		{ 'P', "ptr %p" },
| -		{ 'V', "sym %pS" },
| -		{ 'S', "str %s" },
| -		{ 0, "??? %pS" },
| -	};
| -
| -	/*
| -	 * 17 for "pid %d" (plus space)
| -	 * 21 for "tsk %s" (tsk->comm)
| -	 * up to 8 per varfmt entry
| -	 */
| -	format = kzalloc(37 + 8 * strlen(fmt0) + strlen(fmt), GFP_KERNEL);
| -	if (!format)
| -		return NULL;
| -
| -	format[len++] = '[';
| -
| -	if (fmt0[0] == 'T') {
| -		if (ctx->tsk)
| -			len = sprintf(format, "pid %d tsk %s ",
| -				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
| -		else if (warn_notask++ < 5)
| -			printk(KERN_ERR "c/r: no target task set\n");
| -		fmt0++;
| -	}
| -
| -	for (i = 0; i < strlen(fmt0); i++) {
| -		for (j = 0; prefmt_array[j].key; j++)
| -			if (prefmt_array[j].key == fmt0[i])
| -				break;
| -		if (!prefmt_array[j].key && warn_prefmt++ < 5)
| -			printk(KERN_ERR "c/r: unknown prefmt %c\n", fmt0[i]);
| -		len += sprintf(&format[len], "%s ", prefmt_array[j].fmt);
| -	}
| -
| -	if (len > 1)
| -		sprintf(&format[len-1], "]: %s", fmt);  /* erase last space */
| -	else
| -		sprintf(format, "%s", fmt);
| -
| -	return format;
| -}
| -
| -/* see _ckpt_generate_fmt for information on @fmt0 */
| -static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
| -				char *fmt, va_list ap)
| +/* see ckpt_generate_fmt for information on @fmt extensions */
| +static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
|  {
|  	va_list aq;
|  	char *format;
|  	char *str;
|  	int len;
| 
| -	format = __ckpt_generate_fmt(ctx, fmt0, fmt);
| +	format = ckpt_generate_fmt(ctx, fmt);
|  	va_copy(aq, ap);
| 
|  	/*
| @@ -223,15 +134,14 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
|   * @fmt: message format
|   * @...: arguments
|   *
| - * See _ckpt_generate_fmt for information on @fmt0.
|   * Use this during checkpoint to report while holding a spinlock
|   */
| -void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
| +void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
|  {
|  	va_list ap;
| 
|  	va_start(ap, fmt);
| -	__ckpt_generate_err(ctx, fmt0, fmt, ap);
| +	__ckpt_generate_err(ctx, fmt, ap);
|  	va_end(ap);
|  }
| 
| @@ -242,10 +152,9 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
|   * @fmt: error string format
|   * @...: error string arguments
|   *
| - * See _ckpt_generate_fmt for information on @fmt0.
|   * If @fmt is null, the string in the ctx->err_string will be used (and freed)
|   */
| -int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
| +int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
|  {
|  	va_list ap;
|  	char *str;
| @@ -253,7 +162,7 @@ int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
| 
|  	if (fmt) {
|  		va_start(ap, fmt);
| -		__ckpt_generate_err(ctx, fmt0, fmt, ap);
| +		__ckpt_generate_err(ctx,  fmt, ap);
|  		va_end(ap);
|  	}
| 
| diff --git a/checkpoint/sys.c b/checkpoint/sys.c
| index 260a1ee..9b2de18 100644
| --- a/checkpoint/sys.c
| +++ b/checkpoint/sys.c
| @@ -339,6 +339,101 @@ int walk_task_subtree(struct task_struct *root,
|  	return (ret < 0 ? ret : total);
|  }
| 
| +/*
| + * ckpt_generate_fmt - generate standard checkpoint error message
| + * @ctx: checkpoint context
| + * @fmt: message format
| + *
| + * This generates a unified format of checkpoint error messages, to
| + * ease (after the failure) inspection by userspace tools. It converts
| + * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
| + *
| + * PREFMT is constructed from @fmt by subtituting format snippets
| + * according to the contents of @fmt.  The format characters in
| + * @fmt can be %(E) (error), %(O) (objref), %(P) (pointer), %(S) (string),
| + * %(C) (bytes read/written out of checkpoint image so far), * and %(V)
| + * (variable/symbol). For example, %(E) will generate a "err %d"
| + * in PREFMT.

Its a little confusing on what PREFMT is and how it differs from @fmt0.
The [] with all upper case makes it look like the P, R, E etc are the
only valid characters for fmt0. Can we s/[PREFMT]/prefmt/ ?

| + *
| + * If @fmt begins with %(T), PREFMT will begin with "pid %d tsk %s"
| + * with the pid and the tsk->comm of the currently checkpointed task.
| + * The latter is taken from ctx->tsk, and is it the responsbilility of
| + * the caller to have a valid pointer there (in particular, functions
| + * that iterate on the processes: collect_objects, checkpoint_task,
| + * and tree_count_tasks).
| + *
| + * The caller of ckpt_write_err() and _ckpt_write_err() must provide
| + * the additional variabes, in order, to match the @fmt0 (except for
| + * the T key), e.g.:
| + *
| + *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);

s/writ/write/

| + *
| + * Here, T is simply passed, E expects an integer (err), O expects an
| + * integer (objref), and the last argument matches the format string.
| + *
| + * XXX Do we want 'T' and 'C' to simply always be prepended?

I think it would make sense to.

| + */
| +char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
| +{
| +	char *format;
| +	int alloclen, len = 0;
| +	int first = 1;
| +
| +	/*
| +	 * 17 for "pid %d" (plus space)
| +	 * 21 for "tsk %s" (tsk->comm)
| +	 * up to 8 per varfmt entry
| +	 */
| +	alloclen = 37 + 8 * strlen(fmt);
| +	format = kzalloc(alloclen, GFP_KERNEL);
| +	if (!format)
| +		return NULL;
| +
| +	for (; *fmt; fmt++) {
| +		BUG_ON(len > alloclen);
| +		if (*fmt != '%' || fmt[1] != '(' || fmt[3] != ')') {
| +			format[len++] = *fmt;
| +			continue;
| +		}
| +		if (!first)
| +			format[len++] = ' ';
| +		else
| +			first = 0;
| +		switch (fmt[2]) {
| +		case 'E':
| +			len += sprintf(format+len, "[%s]", "err %d");
| +			break;
| +		case 'O':
| +			len += sprintf(format+len, "[%s]", "obj %d");
| +			break;
| +		case 'P':
| +			len += sprintf(format+len, "[%s]", "ptr %p");
| +			break;
| +		case 'V':
| +			len += sprintf(format+len, "[%s]", "sym %pS");
| +			break;
| +		case 'S':
| +			len += sprintf(format+len, "[%s]", "str %s");
| +			break;
| +		case 'T':
| +			if (ctx->tsk)
| +				len += sprintf(format+len, "[pid %d tsk %s]",
| +				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
| +			else
| +				len += sprintf(format+len, "[pid -1 tsk NULL]");
| +			break;
| +		default:
| +			printk(KERN_ERR "c/r: bad format specifier %c\n",
| +					fmt[2]);
| +			BUG();
| +		}
| +
| +		fmt += 3;
| +	}
| +	format[len] = '\0';
| +
| +	return format;
| +}
| 
|  /**
|   * sys_checkpoint - checkpoint a container
| diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
| index dfcb59b..8a1eaa7 100644
| --- a/include/linux/checkpoint.h
| +++ b/include/linux/checkpoint.h
| @@ -70,12 +70,13 @@ extern int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
|  extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
| 
|  /*
| - * Generate a checkpoint error message with unified format, of the
| - * form: "[PREFMT]: @fmt", where PREFMT is constructed from @fmt0. See
| - * checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
| + * Generate a checkpoint error message with unified format.  Format
| + * can include tokens like %(T) for checkpoint-specific arguments,
| + * which must come before non-checkpoint-specific ones.
| + * See checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
|   */
| -extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
| -extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
| +extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
| +extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
| 
|  extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
|  			       void *ptr, int len, int type);
| @@ -370,6 +371,8 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
| 
|  #endif /* CONFIG_CHECKPOINT_DEBUG */
| 
| +extern char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
| +
|  #endif /* CONFIG_CHECKPOINT */
|  #endif /* __KERNEL__ */
| 
| -- 
| 1.6.1
| 
| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
