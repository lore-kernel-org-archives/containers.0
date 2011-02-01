From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Clear the objhash before completing restart, but delay
	free (v2)
Date: Mon, 31 Jan 2011 19:31:10 -0500
Message-ID: <4D47544E.7080600@cs.columbia.edu>
References: <1287496991-18207-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287496991-18207-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


I modifed the patch a bit according to our IRC chat today:


From 9c74f82411d77cf0194a17ba99af0dd31070e88a Mon Sep 17 00:00:00 2001
From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date: Mon, 31 Jan 2011 19:01:49 -0500
Subject: [PATCH] c/r: clear the objhash before completing restart, but delay free (v3)

This patch causes the restart coordinator to drop references to
objects in the objhash before releasing the restarted tasks.  This
ensures that objects held exclusively there are released before any
task starts running again.

Keeping those references when we allow restarted tasks to return to
userspace is racy if an object's behavior depends on this reference.
One example is restarting half-closed pipes: without this patch they
temporarily (until the coordinator clears the objhash) appear fully
open on both sides. Consider a pipe with read-side closed. A write to
the write-side should produce EPIPE/SIGPIPE, however, because the
objhash contains a reference to both ends of the pipe, the read-side
at restart will not really be closed until after the cleanup, and a
process would unexpectedly not receive an error. Moving the object
hash clear prevents this race and others like it.

To avoid the overhead of actually freeing the object hash's structures
at the same time, we defer the actual memory free to until after the
restarted tasks are allowed to resume execution.

Original patch posted by Dan Smith.

Changes in v3:
 - Use a flag on ctx->kflags to indicate that "->drop" was done on
   the entire hash instead of moving elements to a "free" list
Changes in v2:
 - Avoid adding another list_head to ckpt_obj by re-using the hlist
   hash node for the free list

Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h  |    3 +++
 kernel/checkpoint/objhash.c |   17 +++++++++++++----
 kernel/checkpoint/restart.c |    8 ++++++++
 3 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index adaf6af..6c0ccfd 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -50,11 +50,13 @@ extern long do_sys_restart(pid_t pid, int fd,
 #define CKPT_CTX_RESTART_BIT		1
 #define CKPT_CTX_SUCCESS_BIT		2
 #define CKPT_CTX_ERROR_BIT		3
+#define CKPT_CTX_DROPPED_BIT		4
 
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
 #define CKPT_CTX_SUCCESS	(1 << CKPT_CTX_SUCCESS_BIT)
 #define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
+#define CKPT_CTX_DROPPED	(1 << CKPT_CTX_DROPPED_BIT)
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS \
@@ -176,6 +178,7 @@ extern void restore_notify_error(struct ckpt_ctx *ctx);
 
 /* obj_hash */
 extern void ckpt_obj_hash_free(struct ckpt_ctx *ctx);
+extern void ckpt_obj_hash_drop(struct ckpt_ctx *ctx);
 extern int ckpt_obj_hash_alloc(struct ckpt_ctx *ctx);
 
 extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
index 52062a8..40c2e9b 100644
--- a/kernel/checkpoint/objhash.c
+++ b/kernel/checkpoint/objhash.c
@@ -66,7 +66,7 @@ EXPORT_SYMBOL(register_checkpoint_obj);
 #define CKPT_OBJ_HASH_NBITS  10
 #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
 
-static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
+static void obj_hash_free(struct ckpt_obj_hash *obj_hash, int drop, int clean)
 {
 	struct hlist_head *h = obj_hash->head;
 	struct hlist_node *n, *t;
@@ -75,19 +75,28 @@ static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
 
 	for (i = 0; i < CKPT_OBJ_HASH_TOTAL; i++) {
 		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
-			if (obj->ops->ref_drop)
+			if (drop && obj->ops->ref_drop)
 				obj->ops->ref_drop(obj->ptr, 1);
-			kfree(obj);
+			if (clean)
+				kfree(obj);
 		}
 	}
+
+}
+
+void ckpt_obj_hash_drop(struct ckpt_ctx *ctx)
+{
+	obj_hash_free(ctx->obj_hash, 1, 0);
+	ckpt_set_ctx_kflag(ctx, CKPT_CTX_DROPPED);
 }
 
 void ckpt_obj_hash_free(struct ckpt_ctx *ctx)
 {
 	struct ckpt_obj_hash *obj_hash = ctx->obj_hash;
+	int dropped = ctx->kflags & CKPT_CTX_DROPPED;
 
 	if (obj_hash) {
-		obj_hash_clear(obj_hash);
+		obj_hash_free(obj_hash, !dropped, 1);
 		kfree(obj_hash->head);
 		kfree(ctx->obj_hash);
 		ctx->obj_hash = NULL;
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 2eae499..01da67f 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -1345,6 +1345,14 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		destroy_descendants(ctx);
 		ret = ckpt_get_error(ctx);
 	} else {
+		/*
+		 * Drop references to all objects in the objhash before
+		 * any task is allowed to resume: this prevents resources
+		 * whose semantics depend on the number of references from
+		 * temporarily misbehaving (e.g. a half-closed pipe may
+		 * temporarily appear to fully-open).
+		 */
+		ckpt_obj_hash_drop(ctx);
 		ckpt_set_success(ctx);
 		wake_up_all(&ctx->waitq);
 	}
-- 
1.7.1
