From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] [RFC] Factor out shared portion of [_]ckpt_read_obj
Date: Tue, 27 Oct 2009 23:13:55 -0700
Message-ID: <1256710435-3266-1-git-send-email-matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

It looked like a portion of one of these functions was missing
the block "dispatching" errors so I factored this section out
and called it from both functions. Was there a good reason it
was missing?

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |   49 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 9b75de8..439206b 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -238,6 +238,31 @@ static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
 	return ret;
 }
 
+/**
+ * _ckpt_read_early_dispatch - Dispatch ERRORs and OBJREFs; don't return them.
+ * @ctx: checkpoint context
+ * @h:   desired ckpt_hdr
+ *
+ * Returns -EFOO, 0 if it succeeded, 1 if h has not been dispatched yet
+ * (so it should be returned rather than ignored)
+ */
+static int _ckpt_read_early_dispatch(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	int ret;
+
+	if (h->type == CKPT_HDR_ERROR) {
+		ret = _ckpt_read_err(ctx, h);
+		if (ret < 0)
+			return ret;
+		return 0;
+	} else if (h->type == CKPT_HDR_OBJREF) {
+		ret = _ckpt_read_objref(ctx, h);
+		if (ret < 0)
+			return ret;
+		return 0;
+	}
+	return 1;
+}
 
 /**
  * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
@@ -263,17 +288,11 @@ static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
 	if (h->len < sizeof(*h))
 		return -EINVAL;
 
-	if (h->type == CKPT_HDR_ERROR) {
-		ret = _ckpt_read_err(ctx, h);
-		if (ret < 0)
-			return ret;
+	ret = _ckpt_read_early_dispatch(ctx, h);
+	if (!ret)
 		goto again;
-	} else if (h->type == CKPT_HDR_OBJREF) {
-		ret = _ckpt_read_objref(ctx, h);
-		if (ret < 0)
-			return ret;
-		goto again;
-	}
+	else if (ret < 0)
+		return ret;
 
 	/* if len specified, enforce, else if maximum specified, enforce */
 	if ((len && h->len != len) || (!len && max && h->len > max))
@@ -371,12 +390,12 @@ static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
 	if (hh.len < sizeof(*h))
 		return ERR_PTR(-EINVAL);
 
-	if (hh.type == CKPT_HDR_OBJREF) {
-		ret = _ckpt_read_objref(ctx, &hh);
-		if (ret < 0)
-			return ERR_PTR(ret);
+
+	ret = _ckpt_read_early_dispatch(ctx, &hh);
+	if (!ret)
 		goto again;
-	}
+	else if (ret < 0)
+		return ERR_PTR(ret);
 
 	/* if len specified, enforce, else if maximum specified, enforce */
 	if ((len && hh.len != len) || (!len && max && hh.len > max))
-- 
1.5.6.3
