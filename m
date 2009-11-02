From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 05/12] checkpoint/objhash.c ckpt_write_err->ckpt_err
Date: Mon,  2 Nov 2009 16:23:33 -0600
Message-ID: <1257200620-15499-6-git-send-email-serue@us.ibm.com>
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

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 730dd82..5d72d04 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -657,7 +657,7 @@ static inline int obj_reverse_leak(struct ckpt_ctx *ctx, struct ckpt_obj *obj)
 	 * object while we were collecting, which we didn't catch.
 	 */
 	if (obj->ops->ref_users && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
-		ckpt_write_err(ctx, "OP", "leak: reverse added late (%s)",
+		ckpt_err(ctx, "%(O)%(P)Leak: reverse added late (%s)\n",
 			       obj->objref, obj->ptr, obj->ops->obj_name);
 		return -EBUSY;
 	}
@@ -774,7 +774,7 @@ int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	if (!obj) {
 		if (!(ctx->uflags & CHECKPOINT_SUBTREE)) {
 			/* if not found report reverse leak (full container) */
-			ckpt_write_err(ctx, "OP", "leak: reverse unknown (%s)",
+			ckpt_err(ctx, "%(O)%(P)Leak: reverse unknown (%s)\n",
 				       obj->objref, obj->ptr,
 				       obj->ops->obj_name);
 			return -EBUSY;
@@ -870,7 +870,7 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 
 		if (obj->ops->ref_users(obj->ptr) != obj->users) {
 			ckpt_debug("usage leak: %s\n", obj->ops->obj_name);
-			ckpt_write_err(ctx, "OP", "leak: usage (%d != %d (%s)",
+			ckpt_err(ctx, "%(O)%(P)Leak: usage (%d != %d (%s)\n",
 				       obj->objref, obj->ptr,
 				       obj->ops->ref_users(obj->ptr),
 				       obj->users, obj->ops->obj_name);
@@ -896,7 +896,7 @@ int ckpt_obj_visited(struct ckpt_ctx *ctx)
 		if (!(obj->flags & CKPT_OBJ_VISITED)) {
 			ckpt_debug("reverse leak: %s (%d)\n",
 				   obj->ops->obj_name, obj->objref);
-			ckpt_write_err(ctx, "OP", "leak: not visited (%s)",
+			ckpt_err(ctx, "%(O)%(P)Leak: not visited (%s)\n",
 				       obj->objref, obj->ptr,
 				       obj->ops->obj_name);
 			return 0;
-- 
1.6.1
