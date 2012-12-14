From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/12] blkcg: reorganize blkg_lookup_create() and friends
Date: Fri, 14 Dec 2012 14:41:15 -0800
Message-ID: <1355524885-22719-3-git-send-email-tj__365.344066131179$1355524933$gmane$org@kernel.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355524885-22719-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Reorganize such that

* __blkg_lookup() takes bool param @update_hint to determine whether
  to update hint.

* __blkg_lookup_create() no longer performs lookup before trying to
  create.  Renamed to blkg_create().

* blkg_lookup_create() now performs lookup and then invokes
  blkg_create() if lookup fails.

* root_blkg creation in blkcg_activate_policy() updated accordingly.
  Note that blkcg_activate_policy() no longer updates lookup hint if
  root_blkg already exists.

Except for the last lookup hint bit which is immaterial, this is pure
reorganization and doesn't introduce any visible behavior change.
This is to prepare for proper hierarchy support.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 75 +++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 52 insertions(+), 23 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index feda49f..ffbd237 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -126,7 +126,7 @@ err_free:
 }
 
 static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
-				      struct request_queue *q)
+				      struct request_queue *q, bool update_hint)
 {
 	struct blkcg_gq *blkg;
 
@@ -135,14 +135,19 @@ static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
 		return blkg;
 
 	/*
-	 * Hint didn't match.  Look up from the radix tree.  Note that we
-	 * may not be holding queue_lock and thus are not sure whether
-	 * @blkg from blkg_tree has already been removed or not, so we
-	 * can't update hint to the lookup result.  Leave it to the caller.
+	 * Hint didn't match.  Look up from the radix tree.  Note that the
+	 * hint can only be updated under queue_lock as otherwise @blkg
+	 * could have already been removed from blkg_tree.  The caller is
+	 * responsible for grabbing queue_lock if @update_hint.
 	 */
 	blkg = radix_tree_lookup(&blkcg->blkg_tree, q->id);
-	if (blkg && blkg->q == q)
+	if (blkg && blkg->q == q) {
+		if (update_hint) {
+			lockdep_assert_held(q->queue_lock);
+			rcu_assign_pointer(blkcg->blkg_hint, blkg);
+		}
 		return blkg;
+	}
 
 	return NULL;
 }
@@ -162,7 +167,7 @@ struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, struct request_queue *q)
 
 	if (unlikely(blk_queue_bypass(q)))
 		return NULL;
-	return __blkg_lookup(blkcg, q);
+	return __blkg_lookup(blkcg, q, false);
 }
 EXPORT_SYMBOL_GPL(blkg_lookup);
 
@@ -170,9 +175,9 @@ EXPORT_SYMBOL_GPL(blkg_lookup);
  * If @new_blkg is %NULL, this function tries to allocate a new one as
  * necessary using %GFP_ATOMIC.  @new_blkg is always consumed on return.
  */
-static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
-					     struct request_queue *q,
-					     struct blkcg_gq *new_blkg)
+static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
+				    struct request_queue *q,
+				    struct blkcg_gq *new_blkg)
 {
 	struct blkcg_gq *blkg;
 	int ret;
@@ -180,13 +185,6 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 	WARN_ON_ONCE(!rcu_read_lock_held());
 	lockdep_assert_held(q->queue_lock);
 
-	/* lookup and update hint on success, see __blkg_lookup() for details */
-	blkg = __blkg_lookup(blkcg, q);
-	if (blkg) {
-		rcu_assign_pointer(blkcg->blkg_hint, blkg);
-		goto out_free;
-	}
-
 	/* blkg holds a reference to blkcg */
 	if (!css_tryget(&blkcg->css)) {
 		blkg = ERR_PTR(-EINVAL);
@@ -223,16 +221,39 @@ out_free:
 	return blkg;
 }
 
+/**
+ * blkg_lookup_create - lookup blkg, try to create one if not there
+ * @blkcg: blkcg of interest
+ * @q: request_queue of interest
+ *
+ * Lookup blkg for the @blkcg - @q pair.  If it doesn't exist, try to
+ * create one.  This function should be called under RCU read lock and
+ * @q->queue_lock.
+ *
+ * Returns pointer to the looked up or created blkg on success, ERR_PTR()
+ * value on error.  If @q is dead, returns ERR_PTR(-EINVAL).  If @q is not
+ * dead and bypassing, returns ERR_PTR(-EBUSY).
+ */
 struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
 				    struct request_queue *q)
 {
+	struct blkcg_gq *blkg;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	lockdep_assert_held(q->queue_lock);
+
 	/*
 	 * This could be the first entry point of blkcg implementation and
 	 * we shouldn't allow anything to go through for a bypassing queue.
 	 */
 	if (unlikely(blk_queue_bypass(q)))
 		return ERR_PTR(blk_queue_dead(q) ? -EINVAL : -EBUSY);
-	return __blkg_lookup_create(blkcg, q, NULL);
+
+	blkg = __blkg_lookup(blkcg, q, true);
+	if (blkg)
+		return blkg;
+
+	return blkg_create(blkcg, q, NULL);
 }
 EXPORT_SYMBOL_GPL(blkg_lookup_create);
 
@@ -777,7 +798,7 @@ int blkcg_activate_policy(struct request_queue *q,
 			  const struct blkcg_policy *pol)
 {
 	LIST_HEAD(pds);
-	struct blkcg_gq *blkg;
+	struct blkcg_gq *blkg, *new_blkg;
 	struct blkg_policy_data *pd, *n;
 	int cnt = 0, ret;
 	bool preloaded;
@@ -786,19 +807,27 @@ int blkcg_activate_policy(struct request_queue *q,
 		return 0;
 
 	/* preallocations for root blkg */
-	blkg = blkg_alloc(&blkcg_root, q, GFP_KERNEL);
-	if (!blkg)
+	new_blkg = blkg_alloc(&blkcg_root, q, GFP_KERNEL);
+	if (!new_blkg)
 		return -ENOMEM;
 
 	preloaded = !radix_tree_preload(GFP_KERNEL);
 
 	blk_queue_bypass_start(q);
 
-	/* make sure the root blkg exists and count the existing blkgs */
+	/*
+	 * Make sure the root blkg exists and count the existing blkgs.  As
+	 * @q is bypassing at this point, blkg_lookup_create() can't be
+	 * used.  Open code it.
+	 */
 	spin_lock_irq(q->queue_lock);
 
 	rcu_read_lock();
-	blkg = __blkg_lookup_create(&blkcg_root, q, blkg);
+	blkg = __blkg_lookup(&blkcg_root, q, false);
+	if (blkg)
+		blkg_free(new_blkg);
+	else
+		blkg = blkg_create(&blkcg_root, q, new_blkg);
 	rcu_read_unlock();
 
 	if (preloaded)
-- 
1.7.11.7
