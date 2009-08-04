From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Add a ckpt_read_string() function (v3)
Date: Tue,  4 Aug 2009 13:40:20 -0700
Message-ID: <1249418420-807-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Add a ckpt_read_string() function to allow reading of a variable-length
(but length-capped) string from the checkpoint stream.

Changes in v3:
 - Return immediately on allocation failure instead of falling through to the
   inevitable crash

Changes in v2:
 - Avoid memcpy() by reading into the allocated buffer directly

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c       |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    1 +
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 65cafd9..b1ffc54 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -285,6 +285,42 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
 	return ret;
 }
 
+/**
+ * ckpt_read_string - read a string (variable length)
+ * @ctx: checkpoint context
+ * @str: pointer to buffer to store allocated string (caller must kfree())
+ * @max: maximum acceptable length
+ *
+ * This can be used to read a variable-length string from the checkpoint
+ * stream. @max limits the size of the resulting buffer.  Returns zero on
+ * success, negative on failure.
+ */
+int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max)
+{
+	int len;
+	int ret = 0;
+
+	*str = NULL;
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_STRING);
+	if (len < 0)
+		return len;
+	else if (len > max)
+		return -EINVAL;
+
+	*str = kzalloc(len + 1, GFP_KERNEL);
+	if (!*str)
+		return -ENOMEM;
+
+	ret = ckpt_kread(ctx, *str, len);
+	if (ret < 0) {
+		kfree(*str);
+		*str = NULL;
+	}
+
+	return ret;
+}
+
 /***********************************************************************
  * Restart
  */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 87b683b..a6935b3 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -68,6 +68,7 @@ extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 extern int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
+extern int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max);
 extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
 extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
 extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
-- 
1.6.0.4
