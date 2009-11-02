From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 11/12] remove ckpt_write_err
Date: Mon,  2 Nov 2009 16:23:39 -0600
Message-ID: <1257200620-15499-12-git-send-email-serue@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |  178 --------------------------------------------
 include/linux/checkpoint.h |   11 ---
 2 files changed, 0 insertions(+), 189 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 30c6637..1c67950 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -96,184 +96,6 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
 }
 
-/*
- * __ckpt_generate_fmt - generate standard checkpoint error message
- * @ctx: checkpoint context
- * @fmt0: c/r-format string
- * @fmt: message format
- *
- * This generates a unified format of checkpoint error messages, to
- * ease (after the failure) inspection by userspace tools. It converts
- * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
- *
- * PREFMT is constructed from @fmt0 by subtituting format snippets
- * according to the contents of @fmt0.  The format characters in
- * @fmt0 can be E (error), O (objref), P (pointer), S (string) and
- * V (variable/symbol). For example, E will generate a "err %d" in
- * PREFMT (see prefmt_array below).
- *
- * If @fmt0 begins with T, PREFMT will begin with "pid %d tsk %s"
- * with the pid and the tsk->comm of the currently checkpointed task.
- * The latter is taken from ctx->tsk, and is it the responsbilility of
- * the caller to have a valid pointer there (in particular, functions
- * that iterate on the processes: collect_objects, checkpoint_task,
- * and tree_count_tasks).
- *
- * The caller of ckpt_write_err() and _ckpt_write_err() must provide
- * the additional variabes, in order, to match the @fmt0 (except for
- * the T key), e.g.:
- *
- *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);
- *
- * Here, T is simply passed, E expects an integer (err), O expects an
- * integer (objref), and the last argument matches the format string.
- */
-static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
-{
-	static int warn_notask = 0;
-	static int warn_prefmt = 0;
-	char *format;
-	int i, j, len = 0;
-
-	static struct {
-		char key;
-		char *fmt;
-	} prefmt_array[] = {
-		{ 'E', "err %d" },
-		{ 'O', "obj %d" },
-		{ 'P', "ptr %p" },
-		{ 'V', "sym %pS" },
-		{ 'S', "str %s" },
-		{ 0, "??? %pS" },
-	};
-
-	/*
-	 * 17 for "pid %d" (plus space)
-	 * 21 for "tsk %s" (tsk->comm)
-	 * up to 8 per varfmt entry
-	 */
-	format = kzalloc(37 + 8 * strlen(fmt0) + strlen(fmt), GFP_KERNEL);
-	if (!format)
-		return NULL;
-
-	format[len++] = '[';
-
-	if (fmt0[0] == 'T') {
-		if (ctx->tsk)
-			len = sprintf(format, "pid %d tsk %s ",
-				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
-		else if (warn_notask++ < 5)
-			printk(KERN_ERR "c/r: no target task set\n");
-		fmt0++;
-	}
-
-	for (i = 0; i < strlen(fmt0); i++) {
-		for (j = 0; prefmt_array[j].key; j++)
-			if (prefmt_array[j].key == fmt0[i])
-				break;
-		if (!prefmt_array[j].key && warn_prefmt++ < 5)
-			printk(KERN_ERR "c/r: unknown prefmt %c\n", fmt0[i]);
-		len += sprintf(&format[len], "%s ", prefmt_array[j].fmt);
-	}
-
-	if (len > 1)
-		sprintf(&format[len-1], "]: %s", fmt);  /* erase last space */
-	else
-		sprintf(format, "%s", fmt);
-
-	return format;
-}
-
-/* see _ckpt_generate_fmt for information on @fmt0 */
-static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
-				char *fmt, va_list ap)
-{
-	va_list aq;
-	char *format;
-	char *str;
-	int len;
-
-	format = __ckpt_generate_fmt(ctx, fmt0, fmt);
-	va_copy(aq, ap);
-
-	/*
-	 * prefix the error string with a '\0' to facilitate easy
-	 * backtrace to the beginning of the error message without
-	 * needing to parse the entire checkpoint image.
-	 */
-	ctx->err_string[0] = '\0';
-	str = &ctx->err_string[1];
-	len = vsnprintf(str, 255, format ? : fmt, ap) + 2;
-
-	if (len > 256) {
-		printk(KERN_NOTICE "c/r: error string truncated: ");
-		vprintk(fmt, aq);
-	}
-
-	va_end(aq);
-	kfree(format);
-
-	ckpt_debug("c/r: checkpoint error: %s\n", str);
-}
-
-/**
- * __ckpt_write_err - save an error string on the ctx->err_string
- * @ctx: checkpoint context
- * @fmt0: error pre-format
- * @fmt: message format
- * @...: arguments
- *
- * See _ckpt_generate_fmt for information on @fmt0.
- * Use this during checkpoint to report while holding a spinlock
- */
-void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
-{
-	va_list ap;
-
-	va_start(ap, fmt);
-	__ckpt_generate_err(ctx, fmt0, fmt, ap);
-	va_end(ap);
-}
-
-/**
- * ckpt_write_err - write an object describing an error
- * @ctx: checkpoint context
- * @pre: string pre-format
- * @fmt: error string format
- * @...: error string arguments
- *
- * See _ckpt_generate_fmt for information on @fmt0.
- * If @fmt is null, the string in the ctx->err_string will be used (and freed)
- */
-int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
-{
-	va_list ap;
-	char *str;
-	int len, ret = 0;
-
-	if (fmt) {
-		va_start(ap, fmt);
-		__ckpt_generate_err(ctx, fmt0, fmt, ap);
-		va_end(ap);
-	}
-
-	str = ctx->err_string;
-	len = strlen(str + 1);
-	if (len == 0)	/* empty error string */
-		return 0;
-
-	len += 2; 	/* leading and trailing '\0' */
-	ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
-	if (!ret)
-		ret = ckpt_write_string(ctx, str, len);
-	if (ret < 0)
-		printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
-		       ret, str + 1);
-
-	str[1] = '\0';
-	return ret;
-}
-
 /***********************************************************************
  * Checkpoint
  */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3083e06..6941da0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -69,17 +69,6 @@ extern int ckpt_write_obj_type(struct ckpt_ctx *ctx,
 extern int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
 
-/*
- * Generate a checkpoint error message with unified format, of the
- * form: "[PREFMT]: @fmt", where PREFMT is constructed from @fmt0. See
- * checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
- */
-/*
- * This is deprecated, replaced by ckpt_err() and ckpt_err_locked()
- */
-extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
-extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
-
 extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 			       void *ptr, int len, int type);
 extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
-- 
1.6.1
