From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 01/17] ckpt_write_err: use single format with %(T) style
	tokens
Date: Tue, 27 Oct 2009 17:46:11 -0500
Message-ID: <1256683587-23961-2-git-send-email-serge@us.ibm.com>
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

Matt Helsley originally suggested this to avoid having two
format strings.  This is not bisect-safe and therefore not
even compile-tested.  Every call to ckpt_write_err must be
updated to use a single format.

Changelog: Oct 27: ensure %(T) has a closing paren

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c    |   96 ++++++++++++++++++++++++--------------------
 include/linux/checkpoint.h |   11 +++--
 2 files changed, 58 insertions(+), 49 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6eb8f3b..404bf08 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -128,72 +128,80 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
  * Here, T is simply passed, E expects an integer (err), O expects an
  * integer (objref), and the last argument matches the format string.
  */
-static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt0, char *fmt)
+static char *__ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 {
-	static int warn_notask = 0;
 	static int warn_prefmt = 0;
 	char *format;
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
+	int alloclen, len = 0;
+	int first = 1;
 
 	/*
 	 * 17 for "pid %d" (plus space)
 	 * 21 for "tsk %s" (tsk->comm)
 	 * up to 8 per varfmt entry
 	 */
-	format = kzalloc(37 + 8 * strlen(fmt0) + strlen(fmt), GFP_KERNEL);
+	alloclen = 37 + 8 * strlen(fmt);
+	format = kzalloc(alloclen, GFP_KERNEL);
 	if (!format)
 		return NULL;
 
-	format[len++] = '[';
-
-	if (fmt0[0] == 'T') {
-		if (ctx->tsk)
-			len = sprintf(format, "pid %d tsk %s ",
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
 				      task_pid_vnr(ctx->tsk), ctx->tsk->comm);
-		else if (warn_notask++ < 5)
-			printk(KERN_ERR "c/r: no target task set\n");
-		fmt0++;
-	}
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
+	format[len] = '\0';
 
 	return format;
 }
 
 /* see _ckpt_generate_fmt for information on @fmt0 */
-static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
-				char *fmt, va_list ap)
+static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt, va_list ap)
 {
 	va_list aq;
 	char *format;
 	char *str;
 	int len;
 
-	format = __ckpt_generate_fmt(ctx, fmt0, fmt);
+	format = __ckpt_generate_fmt(ctx, fmt);
 	va_copy(aq, ap);
 
 	/*
@@ -226,12 +234,12 @@ static void __ckpt_generate_err(struct ckpt_ctx *ctx, char *fmt0,
  * See _ckpt_generate_fmt for information on @fmt0.
  * Use this during checkpoint to report while holding a spinlock
  */
-void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
+void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
 {
 	va_list ap;
 
 	va_start(ap, fmt);
-	__ckpt_generate_err(ctx, fmt0, fmt, ap);
+	__ckpt_generate_err(ctx, fmt, ap);
 	va_end(ap);
 }
 
@@ -245,7 +253,7 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
  * See _ckpt_generate_fmt for information on @fmt0.
  * If @fmt is null, the string in the ctx->err_string will be used (and freed)
  */
-int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
+int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
 {
 	va_list ap;
 	char *str;
@@ -253,7 +261,7 @@ int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...)
 
 	if (fmt) {
 		va_start(ap, fmt);
-		__ckpt_generate_err(ctx, fmt0, fmt, ap);
+		__ckpt_generate_err(ctx,  fmt, ap);
 		va_end(ap);
 	}
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dfcb59b..224b494 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -70,12 +70,13 @@ extern int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
 
 /*
- * Generate a checkpoint error message with unified format, of the
- * form: "[PREFMT]: @fmt", where PREFMT is constructed from @fmt0. See
- * checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
+ * Generate a checkpoint error message with unified format.  Format
+ * can include tokens like %(T) for checkpoint-specific arguments,
+ * which must come before non-checkpoint-specific ones.
+ * See checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
  */
-extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
-extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
+extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
+extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
 
 extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 			       void *ptr, int len, int type);
-- 
1.6.1
