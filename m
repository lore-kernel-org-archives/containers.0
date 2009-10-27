From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 02/17] make ckpt_format_fmt non-static in checkpoint/sys.c
Date: Tue, 27 Oct 2009 17:46:12 -0500
Message-ID: <1256683587-23961-3-git-send-email-serge@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256683587-23961-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |  103 +-------------------------------------------
 checkpoint/sys.c           |   95 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    2 +
 3 files changed, 99 insertions(+), 101 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 404bf08..c6be4f9 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -96,104 +96,7 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
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
-static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
-{
-	static int warn_prefmt = 0;
-	char *format;
-	int alloclen, len = 0;
-	int first = 1;
-
-	/*
-	 * 17 for "pid %d" (plus space)
-	 * 21 for "tsk %s" (tsk->comm)
-	 * up to 8 per varfmt entry
-	 */
-	alloclen = 37 + 8 * strlen(fmt);
-	format = kzalloc(alloclen, GFP_KERNEL);
-	if (!format)
-		return NULL;
-
-	for (; *fmt; fmt++) {
-		BUG_ON(len > alloclen);
-		if (*fmt != '%' || fmt[1] != '(' || fmt[3] != ')') {
-			format[len++] = *fmt;
-			continue;
-		}
-		if (!first)
-			format[len++] = ' ';
-		else
-			first = 0;
-		switch(fmt[2]) {
-		case 'E':
-			len += sprintf(format+len, "[%s]", "err %d");
-			break;
-		case 'O':
-			len += sprintf(format+len, "[%s]", "obj %d");
-			break;
-		case 'P':
-			len += sprintf(format+len, "[%s]", "ptr %p");
-			break;
-		case 'V':
-			len += sprintf(format+len, "[%s]", "sym %pS");
-			break;
-		case 'S':
-			len += sprintf(format+len, "[%s]", "str %s");
-			break;
-		case 'T':
-			if (ctx->tsk)
-				len += sprintf(format+len, "[pid %d tsk %s]",
-				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
-			else 
-				len += sprintf(format+len, "[pid -1 tsk NULL]");
-			break;
-		default:
-			if (warn_prefmt++ < 5)
-				printk(KERN_ERR
-					"c/r: bad format specifier %c\n",
-					fmt[2]);
-			BUG();
-		}
-
-		fmt += 3;
-	}
-	format[len] = '\0';
-
-	return format;
-}
-
-/* see _ckpt_generate_fmt for information on @fmt0 */
+/* see ckpt_generate_fmt for information on @fmt extensions */
 static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
 {
 	va_list aq;
@@ -201,7 +104,7 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
 	char *str;
 	int len;
 
-	format = __ckpt_generate_fmt(ctx, fmt);
+	format = ckpt_generate_fmt(ctx, fmt);
 	va_copy(aq, ap);
 
 	/*
@@ -231,7 +134,6 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
  * @fmt: message format
  * @...: arguments
  *
- * See _ckpt_generate_fmt for information on @fmt0.
  * Use this during checkpoint to report while holding a spinlock
  */
 void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
@@ -250,7 +152,6 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
  * @fmt: error string format
  * @...: error string arguments
  *
- * See _ckpt_generate_fmt for information on @fmt0.
  * If @fmt is null, the string in the ctx->err_string will be used (and freed)
  */
 int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 260a1ee..38e65e4 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -339,6 +339,101 @@ int walk_task_subtree(struct task_struct *root,
 	return (ret < 0 ? ret : total);
 }
 
+/*
+ * ckpt_generate_fmt - generate standard checkpoint error message
+ * @ctx: checkpoint context
+ * @fmt: message format
+ *
+ * This generates a unified format of checkpoint error messages, to
+ * ease (after the failure) inspection by userspace tools. It converts
+ * the (printf) message @fmt into a new format: "[PREFMT]: fmt".
+ *
+ * PREFMT is constructed from @fmt0 by subtituting format snippets
+ * according to the contents of @fmt0.  The format characters in
+ * @fmt0 can be E (error), O (objref), P (pointer), S (string) and
+ * V (variable/symbol). For example, E will generate a "err %d" in
+ * PREFMT (see prefmt_array below).
+ *
+ * If @fmt0 begins with T, PREFMT will begin with "pid %d tsk %s"
+ * with the pid and the tsk->comm of the currently checkpointed task.
+ * The latter is taken from ctx->tsk, and is it the responsbilility of
+ * the caller to have a valid pointer there (in particular, functions
+ * that iterate on the processes: collect_objects, checkpoint_task,
+ * and tree_count_tasks).
+ *
+ * The caller of ckpt_write_err() and _ckpt_write_err() must provide
+ * the additional variabes, in order, to match the @fmt0 (except for
+ * the T key), e.g.:
+ *
+ *   ckpt_writ_err(ctx, "TEO", "FILE flags %d", err, objref, flags);
+ *
+ * Here, T is simply passed, E expects an integer (err), O expects an
+ * integer (objref), and the last argument matches the format string.
+ */
+char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
+{
+	static int warn_prefmt = 0;
+	char *format;
+	int alloclen, len = 0;
+	int first = 1;
+
+	/*
+	 * 17 for "pid %d" (plus space)
+	 * 21 for "tsk %s" (tsk->comm)
+	 * up to 8 per varfmt entry
+	 */
+	alloclen = 37 + 8 * strlen(fmt);
+	format = kzalloc(alloclen, GFP_KERNEL);
+	if (!format)
+		return NULL;
+
+	for (; *fmt; fmt++) {
+		BUG_ON(len > alloclen);
+		if (*fmt != '%' || fmt[1] != '(' || fmt[3] != ')') {
+			format[len++] = *fmt;
+			continue;
+		}
+		if (!first)
+			format[len++] = ' ';
+		else
+			first = 0;
+		switch(fmt[2]) {
+		case 'E':
+			len += sprintf(format+len, "[%s]", "err %d");
+			break;
+		case 'O':
+			len += sprintf(format+len, "[%s]", "obj %d");
+			break;
+		case 'P':
+			len += sprintf(format+len, "[%s]", "ptr %p");
+			break;
+		case 'V':
+			len += sprintf(format+len, "[%s]", "sym %pS");
+			break;
+		case 'S':
+			len += sprintf(format+len, "[%s]", "str %s");
+			break;
+		case 'T':
+			if (ctx->tsk)
+				len += sprintf(format+len, "[pid %d tsk %s]",
+				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
+			else 
+				len += sprintf(format+len, "[pid -1 tsk NULL]");
+			break;
+		default:
+			if (warn_prefmt++ < 5)
+				printk(KERN_ERR
+					"c/r: bad format specifier %c\n",
+					fmt[2]);
+			BUG();
+		}
+
+		fmt += 3;
+	}
+	format[len] = '\0';
+
+	return format;
+}
 
 /**
  * sys_checkpoint - checkpoint a container
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 224b494..8a1eaa7 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -371,6 +371,8 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+extern char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
+
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
-- 
1.6.1
