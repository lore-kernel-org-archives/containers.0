From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 01/12] define a new set of functions for error and debug
	logging
Date: Mon,  2 Nov 2009 16:23:29 -0600
Message-ID: <1257200620-15499-2-git-send-email-serue@us.ibm.com>
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

The checkpoint context now includes buffers for an expanded
format and for messages to be written out.  A mutex protects
these buffers as they are being built up and written out.
ckpt_msg() will write general informative (debug) messages to
syslog and an optional user-provided logfile.  ckpt_err() will
write errors to the same places, and, if it is a checkpoint
operation, also to the checkpoint image.

(This is intended to implement Oren's suggestion verbatim)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c                 |  175 ++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h       |   74 ++++++++++++++++
 include/linux/checkpoint_types.h |    5 +
 3 files changed, 254 insertions(+), 0 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 260a1ee..f50167a 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -248,6 +248,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->task_status);
 	spin_lock_init(&ctx->lock);
 #endif
+	
+	mutex_init(&ctx->msg_mutex);
 
 	err = -EBADF;
 	ctx->file = fget(fd);
@@ -339,6 +341,179 @@ int walk_task_subtree(struct task_struct *root,
 	return (ret < 0 ? ret : total);
 }
 
+void ckpt_msg_lock(struct ckpt_ctx *ctx)
+{
+	if (!ctx)
+		return;
+	mutex_lock(&ctx->msg_mutex);
+	ctx->msg[0] = '\0';
+	ctx->msglen = 1;
+}
+
+void ckpt_msg_unlock(struct ckpt_ctx *ctx)
+{
+	if (!ctx)
+		return;
+	mutex_unlock(&ctx->msg_mutex);
+}
+
+static inline int is_special_flag(char *s)
+{
+	if (*s == '%' && s[1] == '(' && s[2] != '\0' && s[3] == ')')
+		return 1;
+	return 0;
+}
+
+/*
+ * _ckpt_generate_fmt - handle the special flags in the enhanced format
+ * strings used by checkpoint/restart error messages.
+ * @ctx: checkpoint context
+ * @fmt: message format
+ *
+ * The special flags are surrounded by %() to help them visually stand
+ * out.  For instance, %(O) means an objref.  The following special
+ * flags are recognized:
+ *	E: error
+ *	O: objref
+ *	P: pointer
+ *	T: task
+ *	S: string
+ *	V: variable
+ *
+ * %(E) will be expanded to "[err %d]".  Likewise O, P, S, and V, will
+ * also expand to format flags requiring an argument to the subsequent
+ * sprintf or printk.  T will be expanded to a string with no flags,
+ * requiring no further arguments.
+ *
+ * These do not accept any extra flags (i.e. min field width, precision,
+ * etc).
+ *
+ * The caller of ckpt_write_err() and _ckpt_write_err() must provide
+ * the additional variabes, in order, to match the @fmt (except for
+ * the T key), e.g.:
+ *
+ *	ckpt_write_err(ctx, "%(T)FILE flags %d %O %E\n", flags, objref, err);
+ *
+ * Must be called with ctx->fmt_buf_lock held.  The expanded format
+ * will be placed in ctx->fmt_buf.
+ */
+void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
+{
+	char *s = ctx->fmt;
+	int len = 0;
+	int first = 1;
+
+	for (; *fmt && len < CKPT_MSG_LEN; fmt++) {
+		if (!is_special_flag(fmt)) {
+			s[len++] = *fmt;
+			continue;
+		}
+		if (!first)
+			s[len++] = ' ';
+		else
+			first = 0;
+		switch (fmt[2]) {
+		case 'E':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[err %%d]");
+			break;
+		case 'O':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[obj %%d]");
+			break;
+		case 'P':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[ptr %%p]");
+			break;
+		case 'V':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[sym %%pS]");
+			break;
+		case 'S':
+			len += snprintf(s+len, CKPT_MSG_LEN-len, "[str %%s]");
+			break;
+		case 'T':
+			if (ctx->tsk)
+				len += snprintf(s+len, CKPT_MSG_LEN-len,
+					"[pid %d tsk %s]",
+					task_pid_vnr(ctx->tsk), ctx->tsk->comm);
+			else
+				len += snprintf(s+len, CKPT_MSG_LEN-len,
+					"[pid -1 tsk NULL]");
+			break;
+		default:
+			printk(KERN_ERR "c/r: bad format specifier %c\n",
+					fmt[2]);
+			BUG();
+		}
+		fmt += 3;
+	}
+}
+
+static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, char *fmt, va_list ap)
+{
+	int len = ctx->msglen;
+
+	len += vsnprintf(&ctx->msg[len], CKPT_MSG_LEN-len, fmt, ap);
+	if (len > CKPT_MSG_LEN) {
+		len = CKPT_MSG_LEN;
+		ctx->msg[CKPT_MSG_LEN-1] = '\0';
+	}
+	ctx->msglen = len;
+}
+
+void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	_ckpt_msg_appendv(ctx, fmt, ap);
+	va_end(ap);
+}
+
+void _ckpt_msg_complete(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	if (ctx->kflags & CKPT_CTX_CHECKPOINT) {
+		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
+		if (!ret)
+			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
+		if (ret < 0)
+			printk(KERN_NOTICE "c/r: error string unsaved (%d): %s\n",
+			       ret, ctx->msg+1);
+	}
+#if 0
+	if (ctx->logfile) {
+		mm_segment_t fs = get_fs();
+		set_fs(KERNEL_DS);
+		ret = _ckpt_kwrite(ctx->logfile, ctx->msg+1, ctx->msglen-1);
+		set_fs(fs);
+	}
+#endif
+#ifdef CONFIG_CHECKPOINT_DEBUG
+	printk(KERN_DEBUG "%s", ctx->msg+1);
+#endif
+}
+
+#define __do_ckpt_msg(ctx, fmt) do {		\
+	va_list ap;				\
+	_ckpt_generate_fmt(ctx, fmt);		\
+	va_start(ap, fmt);			\
+	_ckpt_msg_appendv(ctx, ctx->fmt, ap);	\
+	va_end(ap);				\
+} while (0)
+
+void _do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	__do_ckpt_msg(ctx, fmt);
+}
+
+void do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	if (!ctx) return;
+
+	ckpt_msg_lock(ctx);
+	__do_ckpt_msg(ctx, fmt);
+	_ckpt_msg_complete(ctx);
+	ckpt_msg_unlock(ctx);
+}
 
 /**
  * sys_checkpoint - checkpoint a container
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index dfcb59b..3083e06 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -74,6 +74,9 @@ extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
  * form: "[PREFMT]: @fmt", where PREFMT is constructed from @fmt0. See
  * checkpoint/checkpoint.c:__ckpt_generate_fmt() for details.
  */
+/*
+ * This is deprecated, replaced by ckpt_err() and ckpt_err_locked()
+ */
 extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
 extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt0, char *fmt, ...);
 
@@ -342,6 +345,9 @@ static inline int ckpt_validate_errno(int errno)
 extern void restore_debug_free(struct ckpt_ctx *ctx);
 extern unsigned long ckpt_debug_level;
 
+/*
+ * This is deprecated
+ */
 /* use this to select a specific debug level */
 #define _ckpt_debug(level, fmt, args...)				\
 	do {								\
@@ -365,11 +371,79 @@ extern unsigned long ckpt_debug_level;
 
 static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 
+/*
+ * This is deprecated
+ */
 #define _ckpt_debug(level, fmt, args...)	do { } while (0)
 #define ckpt_debug(fmt, args...)		do { } while (0)
 
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
+/*
+ * prototypes for the new logging api
+ */
+
+extern void ckpt_msg_lock(struct ckpt_ctx *ctx);
+extern void ckpt_msg_unlock(struct ckpt_ctx *ctx);
+
+/*
+ * Expand fmt into ctx->fmt.
+ * This expands enhanced format flags such as %(T), which takes no
+ * arguments, and %(E), which will require a properly positioned
+ * int error argument.  Flags include:
+ *   T: Task
+ *   E: Errno
+ *   O: Objref
+ *   P: Pointer
+ *   S: string
+ *   V: Variable (symbol)
+ * May be called under spinlock.
+ * Must be called under ckpt_msg_lock.
+ */
+extern void _ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
+/*
+ * Append formatted msg to ctx->msg[ctx->msg_len].
+ * Must be called after expanding format.
+ * May be called under spinlock.
+ * Must be called under ckpt_msg_lock().
+ */
+extern void _ckpt_msg_append(struct ckpt_ctx *ctx, char *fmt, ...);
+
+/*
+ * Write ctx->msg to all relevant places.
+ * Must not be called under spinlock.
+ * Must be called under ckpt_msg_lock().
+ */
+extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
+
+/*
+ * Append an enhanced formatted message to ctx->msg.
+ * This will not write the message out to the applicable files, so
+ * the caller will have to use _ckpt_msg_complete() to finish up.
+ * Must be called with ckpt_msg_lock held.
+ */
+extern void _do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...);
+
+/*
+ * Append an enhanced formatted message to ctx->msg.
+ * This will take the ckpt_msg_lock and also write the message out
+ * to the applicable files by calling _ckpt_msg_complete().
+ * Must not be called under spinlock.
+ */
+extern void do_ckpt_msg(struct ckpt_ctx *ctx, char *fmt, ...);
+
+#define ckpt_err(ctx, fmt, args...) do {					\
+	do_ckpt_msg(ctx, "[Error at %s:%d]" fmt, __func__, __LINE__,  ##args);	\
+} while (0)
+
+
+#define _ckpt_err(ctx, fmt, args...) do { \
+	_do_ckpt_msg(ctx, "[ error %s:%d]" fmt, __func__, __LINE__, ##args);	\
+} while (0)
+
+/* ckpt_logmsg() or ckpt_msg() will do do_ckpt_msg with an added
+ * prefix */
+
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5cc11d9..6771b9f 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -85,6 +85,11 @@ struct ckpt_ctx {
 	struct list_head task_status;   /* list of status for each task */
 	spinlock_t lock;
 #endif
+#define CKPT_MSG_LEN 1024
+	char fmt[CKPT_MSG_LEN];
+	char msg[CKPT_MSG_LEN];
+	int msglen;
+	struct mutex msg_mutex;
 };
 
 #endif /* __KERNEL__ */
-- 
1.6.1
