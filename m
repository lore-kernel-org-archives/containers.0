From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: avoid crash if incoming object doesn't have .restore
Date: Mon, 15 Mar 2010 16:53:39 -0400
Message-ID: <1268686419-17329-1-git-send-email-orenl@cs.columbia.edu>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Although we are careful in restore_obj() to not invoke obj->restore()
if an incoming object doesn't have .restore, we didn't properly fail.
This patch initialized the @ptr to report an error in this case.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/objhash.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 2bfcca7..a14ad14 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -1048,7 +1048,7 @@ int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
 {
 	struct ckpt_obj_ops *ops;
 	struct ckpt_obj *obj;
-	void *ptr = NULL;
+	void *ptr = ERR_PTR(-EINVAL);
 
 	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
 	if (h->objtype >= CKPT_OBJ_MAX)
-- 
1.6.3.3
