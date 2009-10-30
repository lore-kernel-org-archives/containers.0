From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 03/22] switch ckpt_generate_err to use ctx fields
Date: Fri, 30 Oct 2009 18:00:25 -0500
Message-ID: <1256943629-4531-4-git-send-email-serue@us.ibm.com>
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

ckpt_generate_fmt() now places the format in ctx->fmt_buf.
ckpt_fill_err_string() calls ckpt_generate_fmt() under
ctx->fmt_buf_lock, and writes its own error (under
ctx->err_string_lock) to ctx->err_string.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |   76 ++++++++++++++++++++++++++++++--------------
 checkpoint/sys.c           |   16 ++-------
 include/linux/checkpoint.h |    3 +-
 3 files changed, 58 insertions(+), 37 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index d0ffd0d..49f6e9d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -96,36 +96,52 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
 }
 
-/* see _ckpt_generate_fmt for information on @fmt0 */
-static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
+static void ckpt_fill_err_string(struct ckpt_ctx *ctx, char *fmt0,
 				char *fmt, va_list ap)
 {
 	va_list aq;
-	char *format;
-	char *str;
 	int len;
+	unsigned long flags;
 
-	format = ckpt_generate_fmt(ctx, fmt0, fmt);
+	spin_lock_irqsave(&ctx->err_string_lock, flags);
+	spin_lock(&ctx->fmt_buf_lock);
+	ckpt_generate_fmt(ctx, fmt0, fmt);
 	va_copy(aq, ap);
 
+	if (ctx->err_string_len == CKPT_MSG_BUFSZ)
+		goto out_unlock;
+
 	/*
 	 * prefix the error string with a '\0' to facilitate easy
 	 * backtrace to the beginning of the error message without
 	 * needing to parse the entire checkpoint image.
 	 */
-	ctx->err_string[0] = '\0';
-	str = &ctx->err_string[1];
-	len = vsnprintf(str, 255, format ? : fmt, ap) + 2;
+	if (ctx->err_string_len == 0) {
+		ctx->err_string[0] = '\0';
+		ctx->err_string_len = 1;
+	}
 
-	if (len > 256) {
+	len = vsnprintf(ctx->err_string + ctx->err_string_len,
+			CKPT_MSG_BUFSZ - ctx->err_string_len,
+			ctx->fmt_buf, ap);
+
+	if (len >= CKPT_MSG_BUFSZ - ctx->err_string_len) {
 		printk(KERN_NOTICE "c/r: error string truncated: ");
 		vprintk(fmt, aq);
-	}
+		ctx->err_string[CKPT_MSG_BUFSZ-1] = '\0';
+		ctx->err_string_len = CKPT_MSG_BUFSZ;
+	} else
+		/* vscnprintf did add a \0 but didn't count
+		 * it toward the len.  We want it to count
+		 * toward the len so we keep a \0 between each
+		 * error msg */
+		ctx->err_string_len += len + 1;
 
 	va_end(aq);
-	kfree(format);
 
-	ckpt_debug("c/r: checkpoint error: %s\n", str);
+out_unlock:
+	spin_unlock(&ctx->fmt_buf_lock);
+	spin_unlock_irqrestore(&ctx->err_string_lock, flags);
 }
 
 /**
@@ -143,7 +159,7 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
 	va_list ap;
 
 	va_start(ap, fmt);
-	__ckpt_generate_err(ctx, fmt0, fmt, ap);
+	ckpt_fill_err_string(ctx, fmt, ap);
 	va_end(ap);
 }
 
@@ -160,29 +176,41 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
 int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
 {
 	va_list ap;
-	char *str;
-	int len, ret = 0;
+	int i, len, ret = 0;
 
 	if (fmt) {
 		va_start(ap, fmt);
-		__ckpt_generate_err(ctx, fmt0, fmt, ap);
+		ckpt_fill_err_string(ctx,  fmt, ap);
 		va_end(ap);
 	}
 
-	str = ctx->err_string;
-	len = strlen(str + 1);
-	if (len == 0)	/* empty error string */
-		return 0;
+	mutex_lock(&ctx->msg_buf_mutex);
+	spin_lock(&ctx->err_string_lock);
+	len = ctx->err_string_len;
+	memcpy(ctx->msg_buf, ctx->err_string, len);
+	ctx->err_string_len = 0;
+	spin_unlock(&ctx->err_string_lock);
+
+	if (len == 0)
+		goto out_unlock;
 
-	len += 2; 	/* leading and trailing '\0' */
+	ctx->msg_buf_len = len;
+	/* write to the checkpoint image */
 	ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
 	if (!ret)
-		ret = ckpt_write_string(ctx, str, len);
+		ret = ckpt_write_string(ctx, ctx->msg_buf, ctx->msg_buf_len);
 	if (ret < 0)
 		printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
-		       ret, str + 1);
+		       ret, ctx->msg_buf);
+
+	/* duplicate to user log file and syslog */
+	for (i = 0; i < len-1; i++)
+		if (ctx->msg_buf[i] == '\0')
+			ctx->msg_buf[i] = '\n';
+	ckpt_do_write_msg(ctx);
 
-	str[1] = '\0';
+out_unlock:
+	mutex_unlock(&ctx->msg_buf_mutex);
 	return ret;
 }
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 0a486f0..8810576 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -375,12 +375,13 @@ int walk_task_subtree(struct task_struct *root,
  *
  * Here, T is simply passed, E expects an integer (err), O expects an
  * integer (objref), and the last argument matches the format string.
+ *
+ * Must be called with ctx->fmt_buf_lock held.  The expanded format
+ * will be placed in ctx->fmt_buf.
  */
 char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
 {
-	static int warn_notask = 0;
-	static int warn_prefmt = 0;
-	char *format;
+	char *format = ctx->fmt_buf;
 	int i, j, len = 0;
 
 	static struct {
@@ -395,15 +396,6 @@ char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
 		{ 0, "??? %pS" },
 	};
 
-	/*
-	 * 17 for "pid %d" (plus space)
-	 * 21 for "tsk %s" (tsk->comm)
-	 * up to 8 per varfmt entry
-	 */
-	format = kzalloc(37 + 8 * strlen(fmt0) + strlen(fmt), GFP_KERNEL);
-	if (!format)
-		return NULL;
-
 	format[len++] = '[';
 
 	if (fmt0[0] == 'T') {
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 541bfa8..4cfd44b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -370,7 +370,8 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
-extern char *ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt);
+extern void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt);
+static inline void ckpt_do_write_msg(struct ckpt_ctx *ctx) { }
 
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
-- 
1.6.1
