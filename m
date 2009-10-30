From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 04/22] Change to the new enhanced error string format
Date: Fri, 30 Oct 2009 18:00:26 -0500
Message-ID: <1256943629-4531-5-git-send-email-serue@us.ibm.com>
References: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256943629-4531-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 checkpoint/checkpoint.c    |   15 ++----
 checkpoint/sys.c           |  122 ++++++++++++++++++++++----------------------
 include/linux/checkpoint.h |   12 ++--
 3 files changed, 72 insertions(+), 77 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 49f6e9d..c835d82 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -96,8 +96,7 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
 }
 
-static void ckpt_fill_err_string(struct ckpt_ctx *ctx, char *fmt0,
-				char *fmt, va_list ap)
+static void ckpt_fill_err_string(struct ckpt_ctx *ctx, char *fmt, va_list ap)
 {
 	va_list aq;
 	int len;
@@ -105,7 +104,7 @@ static void ckpt_fill_err_string(struct ckpt_ctx *ctx, char *fmt0,
 
 	spin_lock_irqsave(&ctx->err_string_lock, flags);
 	spin_lock(&ctx->fmt_buf_lock);
-	ckpt_generate_fmt(ctx, fmt0, fmt);
+	ckpt_generate_fmt(ctx, fmt);
 	va_copy(aq, ap);
 
 	if (ctx->err_string_len == CKPT_MSG_BUFSZ)
@@ -147,14 +146,12 @@ out_unlock:
 /**
  * __ckpt_write_err - save an error string on the ctx->err_string
  * @ctx: checkpoint context
- * @fmt0: error pre-format
  * @fmt: message format
  * @...: arguments
  *
- * See _ckpt_generate_fmt for information on @fmt0.
  * Use this during checkpoint to report while holding a spinlock
  */
-void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
+void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
 {
 	va_list ap;
 
@@ -166,21 +163,19 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
 /**
  * ckpt_write_err - write an object describing an error
  * @ctx: checkpoint context
- * @pre: string pre-format
  * @fmt: error string format
  * @...: error string arguments
  *
- * See _ckpt_generate_fmt for information on @fmt0.
  * If @fmt is null, the string in the ctx->err_string will be used (and freed)
  */
-int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
+int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
 {
 	va_list ap;
 	int i, len, ret = 0;
 
 	if (fmt) {
 		va_start(ap, fmt);
-		ckpt_fill_err_string(ctx,  fmt, ap);
+		ckpt_fill_err_string(ctx, fmt, ap);
 		va_end(ap);
 	}
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 8810576..e2c01df 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -345,83 +345,83 @@ int walk_task_subtree(struct task_struct *root,
 }
 
 /*
- * ckpt_generate_fmt - generate standard checkpoint error message
+ * ckpt_generate_fmt - handle the special flags in the enhanced format
+ * strings used by checkpoint/restart error messages.
  * @ctx: checkpoint context
- * @fmt0: c/r-format string
  * @fmt: message format
  *
- * This generates a unified format of checkpoint error messages, to
- * ease (after the failure) inspection by userspace tools. It converts
- * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
+ * The special flags are surrounded by %() to help them visually stand
+ * out.  For instance, %(O) means an objref.  The following special
+ * flags are recognized:
+ *	E: error
+ *	O: objref
+ *	P: pointer
+ *	T: task
+ *	S: string
+ *	V: variable
  *
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
+ * %(E) will be expanded to "[err %d]".  Likewise O, P, S, and V, will
+ * also expand to format flags requiring an argument to the subsequent
+ * sprintf or printk.  T will be expanded to a string with no flags,
+ * requiring no further arguments.
  *
  * The caller of ckpt_write_err() and _ckpt_write_err() must provide
- * the additional variabes, in order, to match the @fmt0 (except for
+ * the additional variabes, in order, to match the @fmt (except for
  * the T key), e.g.:
  *
- *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);
- *
- * Here, T is simply passed, E expects an integer (err), O expects an
- * integer (objref), and the last argument matches the format string.
+ *	ckpt_write_err(ctx, "%(T)FILE flags %d %O %E\n", flags, objref, err);
  *
  * Must be called with ctx->fmt_buf_lock held.  The expanded format
  * will be placed in ctx->fmt_buf.
  */
-char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
+void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 {
-	char *format = ctx->fmt_buf;
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
-	format[len++] = '[';
-
-	if (fmt0[0] == 'T') {
-		if (ctx->tsk)
-			len = sprintf(format, "pid %d tsk %s ",
+	char *s = ctx->fmt_buf;
+	int len = 0;
+	int first = 1;
+
+	for (; *fmt && len < CKPT_MSG_BUFSZ; fmt++) {
+		if (*fmt != '%' || fmt[1] != '(' || fmt[2] == '\0' ||
+							fmt[3] != ')') {
+			s[len++] = *fmt;
+			continue;
+		}
+		if (!first)
+			s[len++] = ' ';
+		else
+			first = 0;
+		switch (fmt[2]) {
+		case 'E':
+			len += sprintf(s+len, "[%s]", "err %d");
+			break;
+		case 'O':
+			len += sprintf(s+len, "[%s]", "obj %d");
+			break;
+		case 'P':
+			len += sprintf(s+len, "[%s]", "ptr %p");
+			break;
+		case 'V':
+			len += sprintf(s+len, "[%s]", "sym %pS");
+			break;
+		case 'S':
+			len += sprintf(s+len, "[%s]", "str %s");
+			break;
+		case 'T':
+			if (ctx->tsk)
+				len += sprintf(s+len, "[pid %d tsk %s]",
 				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
-		else if (warn_notask++ < 5)
-			printk(KERN_ERR "c/r: no target task set\n");
-		fmt0++;
-	}
+			else
+				len += sprintf(s+len, "[pid -1 tsk NULL]");
+			break;
+		default:
+			printk(KERN_ERR "c/r: bad format specifier %c\n",
+					fmt[2]);
+			BUG();
+		}
 
-	for (i = 0; i < strlen(fmt0); i++) {
-		for (j = 0; prefmt_array[j].key; j++)
-			if (prefmt_array[j].key == fmt0[i])
-				break;
-		if (!prefmt_array[j].key && warn_prefmt++ < 5)
-			printk(KERN_ERR "c/r: unknown prefmt %c\n", fmt0[i]);
-		len += sprintf(&format[len], "%s ", prefmt_array[j].fmt);
+		fmt += 3;
 	}
-
-	if (len > 1)
-		sprintf(&format[len-1], "]: %s", fmt);  /* erase last space */
-	else
-		sprintf(format, "%s", fmt);
-
-	return format;
+	s[len] = '\0';
 }
 
 /**
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 4cfd44b..6464851 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -70,12 +70,12 @@ extern int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
 
 /*
- * Generate a checkpoint error message with unified format, of the
- * form: "[PREFMT]: @fmt", where PREFMT is constructed from @fmt0. See
- * checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
+ * Generate a checkpoint error message with unified format.  Format
+ * can include tokens like %(E) for checkpoint-specific arguments,
+ * which must come before non-checkpoint-specific ones.
  */
-extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
-extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
+extern void __ckpt_write_err(struct ckpt_ctx *ctx,  char *fmt, ...);
+extern int ckpt_write_err(struct ckpt_ctx *ctx,  char *fmt, ...);
 
 extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 			       void *ptr, int len, int type);
@@ -370,7 +370,7 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
-extern void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt);
+extern void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
 static inline void ckpt_do_write_msg(struct ckpt_ctx *ctx) { }
 
 #endif /* CONFIG_CHECKPOINT */
-- 
1.6.1
