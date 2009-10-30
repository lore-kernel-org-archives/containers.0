From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 14/22] define ckpt_error and implement ckpt_do_write_msg
Date: Fri, 30 Oct 2009 18:00:28 -0500
Message-ID: <1256943629-4531-7-git-send-email-serue@us.ibm.com>
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
 checkpoint/sys.c           |   64 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    6 +++-
 2 files changed, 69 insertions(+), 1 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index b959b27..94cbe57 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -433,6 +433,70 @@ void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt)
 	s[len] = '\0';
 }
 
+/*
+ * Write ctx->msg_buf to user-provided log and to syslog
+ * Called under ctx->msg_buf_mutex.
+ */
+void ckpt_do_write_msg(struct ckpt_ctx *ctx)
+{
+	struct file *file = ctx->logfile;
+	mm_segment_t fs;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	_ckpt_kwrite(file, ctx->msg_buf, ctx->msg_buf_len);
+	set_fs(fs);
+
+	ckpt_debug("%s", ctx->msg_buf);
+}
+
+static void ckpt_log_msg_v(struct ckpt_ctx *ctx, char *fmt, va_list ap)
+{
+	char *msgbuf;
+	va_list aq;
+	int count, len;
+
+	mutex_lock(&ctx->msg_buf_mutex);
+	/* expand the format into ctx->fmt_buf */
+	spin_lock(&ctx->fmt_buf_lock);
+	ckpt_generate_fmt(ctx, fmt);
+	msgbuf = ctx->msg_buf;
+
+	/* write the prefix */
+	len = snprintf(msgbuf, CKPT_MSG_BUFSZ, "[%d]=[%d]:[%lld]:[%d] ",
+			 current->pid, task_pid_vnr(current), ctx->total,
+			 ctx->errno);
+	/* fill in the message */
+	va_copy(aq, ap);
+	count = vsnprintf(msgbuf+len, CKPT_MSG_BUFSZ-len, ctx->fmt_buf, aq);
+	va_end(aq);
+
+	spin_unlock(&ctx->fmt_buf_lock);
+
+	count += len;
+	if (count > CKPT_MSG_BUFSZ) {
+		printk(KERN_WARNING "%s:%s:%d error string too long (%d)\n",
+		       __FILE__, __func__, __LINE__, count);
+		msgbuf[CKPT_MSG_BUFSZ-1] = '\0';
+	}
+
+	ctx->msg_buf_len = count;
+	ckpt_do_write_msg(ctx);
+	mutex_unlock(&ctx->msg_buf_mutex);
+}
+
+void ckpt_log_msg(struct ckpt_ctx *ctx, char *fmt, ...)
+{
+	va_list ap;
+
+	if (!ctx || !ctx->logfile)
+		return;
+
+	va_start(ap, fmt);
+	ckpt_log_msg_v(ctx, fmt, ap);
+	va_end(ap);
+}
+
 /**
  * sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6464851..0c2bb56 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -371,7 +371,11 @@ static inline void restore_debug_free(struct ckpt_ctx *ctx) {}
 #endif /* CONFIG_CHECKPOINT_DEBUG */
 
 extern void ckpt_generate_fmt(struct ckpt_ctx *ctx, char *fmt);
-static inline void ckpt_do_write_msg(struct ckpt_ctx *ctx) { }
+extern void ckpt_do_write_msg(struct ckpt_ctx *ctx);
+extern void ckpt_log_msg(struct ckpt_ctx *ctx, char *fmt, ...);
+
+#define ckpt_error(ctx, fmt, args...)					\
+	ckpt_log_msg(ctx, "%s:%d " fmt, __func__, __LINE__, ## args);
 
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
-- 
1.6.1
