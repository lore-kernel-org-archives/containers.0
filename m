From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Fix ckpt_obj_lookup_add() leak detection logic
Date: Thu, 17 Sep 2009 10:07:54 -0700
Message-ID: <1253207274-7563-1-git-send-email-danms@us.ibm.com>
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

Since first is a pointer, it's never NULL and thus leak detection will
always be performed (of CHECKPOINT_SUBTREE is set).  This fatally breaks
the checkpoint process when that flag is enabled because any object (with
a ref_users operation) that is added to the hash twice will be reported as
a reverse leak.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 8dfb0b0..b85aa77 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -679,7 +679,7 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 	ckpt_debug("%s objref %d first %d\n",
 		   obj->ops->obj_name, obj->objref, *first);
 
-	if (first && obj_reverse_leak(ctx, obj))
+	if (*first && obj_reverse_leak(ctx, obj))
 		return -EBUSY;
 
 	obj->flags |= CKPT_OBJ_VISITED;
-- 
1.6.2.5
