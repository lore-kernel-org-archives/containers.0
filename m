From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 15/22] explain locking for write_err_msg
Date: Fri, 30 Oct 2009 18:00:29 -0500
Message-ID: <1256943629-4531-8-git-send-email-serue@us.ibm.com>
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
 checkpoint/checkpoint.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 71340de..f057c7a 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -96,6 +96,13 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
 }
 
+/*
+ * ckpt_fill_err_string() can be called under spinlock and therefore
+ * must not sleep.  So we protect ctx->err_string and ->err_string_len
+ * with ctx->err_string_lock which is a spinlock.
+ * We must also take the ctx->fmt_buf_lock (also a spin_lock) for the
+ * whole time that we are writing to and reading from ctx->fmt_buf.
+ */
 static void ckpt_fill_err_string(struct ckpt_ctx *ctx, char *fmt, va_list ap)
 {
 	va_list aq;
@@ -166,6 +173,20 @@ void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
  * @fmt: error string format
  * @...: error string arguments
  *
+ * Here is the locking rationale:
+ * __ckpt_write_err() (which can be called from spinlock context)
+ * writes to ctx->err_string under ctx->err_string_lock.
+ *
+ * ckpt_write_err() in turn copies ctx->err_string to ctx->msg_buf
+ * under both ctx->msg_buf_mutex and ctx->err_string_lock, and clears
+ * out ctx->err_sring (so theoretically it can be written to again).
+ * It then drops ctx->err_string_lock (which is a spinlock) and keeps
+ * the ctx->msg_buf_mutex.
+ *
+ * It then can leisurely write out msg_buf under mutex ( by calling
+ * ckpt_do_write_msg() ), while another task could be writing new
+ * messages to ctx->err_string.
+ *
  * If @fmt is null, the string in the ctx->err_string will be used (and freed)
  */
 int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...)
-- 
1.6.1
