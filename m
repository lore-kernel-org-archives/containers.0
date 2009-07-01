From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] Add _ckpt_read_hdr_type() helper
Date: Wed,  1 Jul 2009 11:20:12 -0700
Message-ID: <1246472414-23105-1-git-send-email-danms@us.ibm.com>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This helper function gives us a way to read a header object and the
subsequent payload from the checkpoint stream directly into our own
buffer.  This is used by the net/checkpoint.c code to read skb's
without a memcpy().

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c       |   36 ++++++++++++++++++++++++++++++++++--
 include/linux/checkpoint.h |    4 ++++
 2 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 4155426..3bfee31 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -177,6 +177,38 @@ int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
 }
 
 /**
+ * _ckpt_read_hdr_type - read a header record and check the type
+ * @ctx: checkpoint context
+ * @h: provided header buffer (returned)
+ * @type: optional type, 0 to ignore
+ *
+ * Returns the size of the payload to follow or negative on error
+ */
+int _ckpt_read_hdr_type(struct ckpt_ctx *ctx, struct ckpt_hdr *h, int type)
+{
+	int ret;
+
+	ret = ckpt_kread(ctx, h, sizeof(*h));
+	if (ret < 0)
+		return ret;
+	else if (type && h->type != type)
+		return -EINVAL;
+	else
+		return h->len - sizeof(*h);
+}
+
+/**
+ * _ckpt_read_payload - read the payload associated with a recent header read
+ * @ctx: checkpoint_context
+ * @h: header returned from _ckpt_read_hdr_type()
+ * @buffer: pre-allocated buffer to store payload
+ */
+int _ckpt_read_payload(struct ckpt_ctx *ctx, struct ckpt_hdr *h, void *buffer)
+{
+	return ckpt_kread(ctx, buffer, h->len - sizeof(*h));
+}
+
+/**
  * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
  * @ctx: checkpoint context
  * @h: object descriptor
@@ -192,7 +224,7 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 	int ret;
 
  again:
-	ret = ckpt_kread(ctx, &hh, sizeof(hh));
+	ret = _ckpt_read_hdr_type(ctx, &hh, 0);
 	if (ret < 0)
 		return ERR_PTR(ret);
 	_ckpt_debug(CKPT_DRW, "type %d len %d(%d,%d)\n",
@@ -217,7 +249,7 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 
 	*h = hh;	/* yay ! */
 
-	ret = ckpt_kread(ctx, (h + 1), hh.len - sizeof(struct ckpt_hdr));
+	ret = _ckpt_read_payload(ctx, &hh, (h + 1));
 	if (ret < 0) {
 		ckpt_hdr_put(ctx, h);
 		h = ERR_PTR(ret);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 2765c33..ccc4aab 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -63,6 +63,10 @@ extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len);
 extern void __ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
 extern int ckpt_write_err(struct ckpt_ctx *ctx, char *fmt, ...);
 
+extern int _ckpt_read_payload(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
+			      void *buffer);
+extern int _ckpt_read_hdr_type(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
+			       int type);
 extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
 			       void *ptr, int len, int type);
 extern int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len);
-- 
1.6.2.2
