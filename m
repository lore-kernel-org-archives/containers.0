From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/6] c/r: [objhash] add ckpt_obj_reserve()
Date: Fri,  4 Sep 2009 10:20:46 -0400
Message-ID: <1252074054-22241-2-git-send-email-orenl@librato.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252074054-22241-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

Use ckpt_obj_reserve() during checkpoint to reserve an objref that
will not be otherwise used for any other object in checkpoint. Such an
objref can be useful for restart to add objects that were not there at
checkpoint.

One use case for this is ptys (subsequent patches): when restoring a
master pty, we create a file pointer, which must be kept somewhere and
later cleaned up. The hash is a good place to store it.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/objhash.c       |   20 +++++++++++++++++++-
 include/linux/checkpoint.h |    1 +
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index a9a10d1..022b405 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -465,6 +465,11 @@ static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
 	return NULL;
 }
 
+static inline int obj_alloc_objref(struct ckpt_ctx *ctx)
+{
+	return ctx->obj_hash->next_free_objref++;
+}
+
 /**
  * ckpt_obj_new - add an object to the obj_hash
  * @ctx: checkpoint context
@@ -498,7 +503,7 @@ static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 
 	if (!objref) {
 		/* use @obj->ptr to index, assign objref (checkpoint) */
-		obj->objref = ctx->obj_hash->next_free_objref++;;
+		obj->objref = obj_alloc_objref(ctx);
 		i = hash_long((unsigned long) ptr, CKPT_OBJ_HASH_NBITS);
 	} else {
 		/* use @obj->objref to index (restart) */
@@ -637,6 +642,19 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 }
 
 /**
+ * ckpt_obj_reserve - reserve an objref
+ * @ctx: checkpoint context
+ *
+ * The reserved objref will not be used for subsequent objects. This
+ * gives an objref that can be safely used during restart without a
+ * matching object in checkpoint.  [used during checkpoint].
+ */
+int ckpt_obj_reserve(struct ckpt_ctx *ctx)
+{
+	return obj_alloc_objref(ctx);
+}
+
+/**
  * checkpoint_obj - if not already in hash, add object and checkpoint
  * @ctx: checkpoint context
  * @ptr: pointer to object
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 761cad5..1d050f8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -121,6 +121,7 @@ extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
+extern int ckpt_obj_reserve(struct ckpt_ctx *ctx);
 
 extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
-- 
1.6.0.4
