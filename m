From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/5] Add a ckpt_read_string() function to allow reading of a
	variable-length (but length-capped) string from the checkpoint stream.
Date: Wed, 22 Jul 2009 13:41:39 -0700
Message-ID: <1248295301-30930-4-git-send-email-danms@us.ibm.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248295301-30930-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c       |   35 +++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    1 +
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 5cbe491..06fe47e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -339,6 +339,41 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
 	return ret;
 }
 
+/**
+ * ckpt_read_string - read a string (variable length)
+ * @ctx: checkpoint context
+ * @max: maximum acceptable length
+ * @str: pointer to buffer to store allocated string (caller must kfree())
+ *
+ * This can be used to read a variable-length string from the checkpoint
+ * stream. @max limits the size of the resulting buffer.  Returns zero on
+ * success, negative on failure.
+ */
+int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max)
+{
+	struct ckpt_hdr *h;
+	char *buf;
+	int len;
+	int ret = 0;
+
+	h = ckpt_read_buf_type(ctx, max, CKPT_HDR_STRING);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	buf = (char *)(h + 1);
+	len = h->len - sizeof(*h);
+
+	*str = kzalloc(len + 1, GFP_KERNEL);
+	if (!*str)
+		ret = -ENOMEM;
+	else
+		memcpy(*str, buf, len);
+
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 /***********************************************************************
  * Restart
  */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 93efa10..95940d4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -72,6 +72,7 @@ extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 extern int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
 extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
+extern int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max);
 extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
 extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
 extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
-- 
1.6.2.5
