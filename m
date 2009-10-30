From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 01/22] Make __ckpt_generate_fmt public
Date: Fri, 30 Oct 2009 18:00:23 -0500
Message-ID: <1256943629-4531-2-git-send-email-serue@us.ibm.com>
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

Move it to checkpoint/sys.c, call it ckpt_generate_fmt, make it
non-static.  It will be used later by ckpt_error, which is used
during restart as well as checkpoint.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |   90 +-------------------------------------------
 checkpoint/sys.c           |   87 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    2 +
 3 files changed, 90 insertions(+), 89 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6eb8f3b..d0ffd0d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -96,94 +96,6 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
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
 /* see _ckpt_generate_fmt for information on @fmt0 */
 static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
 				char *fmt, va_list ap)
@@ -193,7 +105,7 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
 	char *str;
 	int len;
 
-	format = __ckpt_generate_fmt(ctx, fmt0, fmt);
+	format = ckpt_generate_fmt(ctx, fmt0, fmt);
 	va_copy(aq, ap);
 
 	/*
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 260a1ee..c888a12 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -339,6 +339,93 @@ int walk_task_subtree(struct task_struct *root,
 	return (ret < 0 ? ret : total);
 }
 
+/*
+ * ckpt_generate_fmt - generate standard checkpoint error message
+ * @ctx: checkpoint context
+ * @fmt0: c/r-format string
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
+char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
+{
+	static int warn_notask = 0;
+	static int warn_prefmt = 0;
+	char *format;
+	int i, j, len = 0;
+
+	static struct {
+		char key;
+		char *fmt;
+	} prefmt_array[] = {
+		{ 'E', "err %d" },
+		{ 'O', "obj %d" },
+		{ 'P', "ptr %p" },
+		{ 'V', "sym %pS" },
+		{ 'S', "str %s" },
+		{ 0, "??? %pS" },
+	};
+
+	/*
+	 * 17 for "pid %d" (plus space)
+	 * 21 for "tsk %s" (tsk->comm)
+	 * up to 8 per varfmt entry
+	 */
+	format = kzalloc(37 + 8 * strlen(fmt0) + strlen(fmt), GFP_KERNEL);
+	if (!format)
+		return NULL;
+
+	format[len++] = '[';
+
+	if (fmt0[0] == 'T') {
+		if (ctx->tsk)
+			len = sprintf(format, "pid %d tsk %s ",
+				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
+		else if (warn_notask++ < 5)
+			printk(KERN_ERR "c/r: no target task set\n");
+		fmt0++;
+	}
+
+	for (i = 0; i < strlen(fmt0); i++) {
+		for (j = 0; prefmt_array[j].key; j++)
+			if (prefmt_array[j].key == fmt0[i])
+				break;
+		if (!prefmt_array[j].key && warn_prefmt++ < 5)
+			printk(KERN_ERR "c/r: unknown prefmt %c\n", fmt0[i]);
+		len += sprintf(&format[len], "%s ", prefmt_array[j].fmt);
+	}
+
+	if (len > 1)
+		sprintf(&format[len-1], "]: %s", fmt);  /* erase last space */
+	else
+		sprintf(format, "%s", fmt);
+
+	return format;
+}
 
 /**
  * sys_checkpoint - checkpoint a container
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dfcb59b..541bfa8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -370,6 +370,8 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+extern char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt);
+
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
-- 
1.6.1
