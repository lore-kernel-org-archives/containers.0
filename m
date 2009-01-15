From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH/RFC] objhash.c: fix (?) invalid casts
Date: Thu, 15 Jan 2009 13:40:49 -0600
Message-ID: <20090115194049.GB4924@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

When building 64-bit powerpc:

checkpoint/objhash.c: In function 'cr_obj_find_by_objref':
checkpoint/objhash.c:121: warning: cast to pointer from integer of different size
checkpoint/objhash.c: In function 'cr_obj_new':
checkpoint/objhash.c:158: warning: cast to pointer from integer of different size

Is this the right fix or is struct cr_objref->objref the wrong type?

---
 checkpoint/objhash.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

This is on top of v12 of the C/R patches.

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 13d3e5d..cb08d3c 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -118,7 +118,8 @@ static struct cr_objref *cr_obj_find_by_objref(struct cr_ctx *ctx, int objref)
 	struct hlist_node *n;
 	struct cr_objref *obj;
 
-	h = &ctx->objhash->head[hash_ptr((void *) objref, CR_OBJHASH_NBITS)];
+	h = &ctx->objhash->head[hash_ptr((void *)(unsigned long)objref,
+					 CR_OBJHASH_NBITS)];
 	hlist_for_each_entry(obj, n, h, hash)
 		if (obj->objref == objref)
 			return obj;
@@ -155,7 +156,7 @@ static struct cr_objref *cr_obj_new(struct cr_ctx *ctx, void *ptr, int objref,
 	if (objref) {
 		/* use @objref to index (restart) */
 		obj->objref = objref;
-		i = hash_ptr((void *) objref, CR_OBJHASH_NBITS);
+		i = hash_ptr((void *)(unsigned long)objref, CR_OBJHASH_NBITS);
 	} else {
 		/* use @ptr to index, assign objref (checkpoint) */
 		obj->objref = ctx->objhash->next_free_objref++;;
-- 
1.5.5
