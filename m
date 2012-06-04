From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/10] blkcg: make root blkcg allocation use %GFP_KERNEL
Date: Mon,  4 Jun 2012 00:08:09 -0700
Message-ID: <1338793697-10735-3-git-send-email-tj@kernel.org>
References: <1338793697-10735-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338793697-10735-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, blkcg_activate_policy() depends on %GFP_ATOMIC allocation
from __blkg_lookup_create() for root blkcg creation.  This could make
policy fail unnecessarily.

Make blkg_alloc() take @gfp_mask, __blkg_lookup_create() take an
optional @new_blkg for preallocated blkg, and blkcg_activate_policy()
preload radix tree and preallocate blkg with %GFP_KERNEL before trying
to create the root blkg.

v2: __blkg_lookup_create() was returning %NULL on blkg alloc failure
   instead of ERR_PTR() value.  Fixed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c |   59 +++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index af61db0..cbeeb54 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -91,16 +91,18 @@ static void blkg_free(struct blkcg_gq *blkg)
  * blkg_alloc - allocate a blkg
  * @blkcg: block cgroup the new blkg is associated with
  * @q: request_queue the new blkg is associated with
+ * @gfp_mask: allocation mask to use
  *
  * Allocate a new blkg assocating @blkcg and @q.
  */
-static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q)
+static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q,
+				   gfp_t gfp_mask)
 {
 	struct blkcg_gq *blkg;
 	int i;
 
 	/* alloc and init base part */
-	blkg = kzalloc_node(sizeof(*blkg), GFP_ATOMIC, q->node);
+	blkg = kzalloc_node(sizeof(*blkg), gfp_mask, q->node);
 	if (!blkg)
 		return NULL;
 
@@ -117,7 +119,7 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q)
 			continue;
 
 		/* alloc per-policy data and attach it to blkg */
-		pd = kzalloc_node(pol->pd_size, GFP_ATOMIC, q->node);
+		pd = kzalloc_node(pol->pd_size, gfp_mask, q->node);
 		if (!pd) {
 			blkg_free(blkg);
 			return NULL;
@@ -175,8 +177,13 @@ struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, struct request_queue *q)
 }
 EXPORT_SYMBOL_GPL(blkg_lookup);
 
+/*
+ * If @new_blkg is %NULL, this function tries to allocate a new one as
+ * necessary using %GFP_ATOMIC.  @new_blkg is always consumed on return.
+ */
 static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
-					     struct request_queue *q)
+					     struct request_queue *q,
+					     struct blkcg_gq *new_blkg)
 {
 	struct blkcg_gq *blkg;
 	int ret;
@@ -188,18 +195,24 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 	blkg = __blkg_lookup(blkcg, q);
 	if (blkg) {
 		rcu_assign_pointer(blkcg->blkg_hint, blkg);
-		return blkg;
+		goto out_free;
 	}
 
 	/* blkg holds a reference to blkcg */
-	if (!css_tryget(&blkcg->css))
-		return ERR_PTR(-EINVAL);
+	if (!css_tryget(&blkcg->css)) {
+		blkg = ERR_PTR(-EINVAL);
+		goto out_free;
+	}
 
 	/* allocate */
-	ret = -ENOMEM;
-	blkg = blkg_alloc(blkcg, q);
-	if (unlikely(!blkg))
-		goto err_put;
+	if (!new_blkg) {
+		new_blkg = blkg_alloc(blkcg, q, GFP_ATOMIC);
+		if (unlikely(!new_blkg)) {
+			blkg = ERR_PTR(-ENOMEM);
+			goto out_put;
+		}
+	}
+	blkg = new_blkg;
 
 	/* insert */
 	spin_lock(&blkcg->lock);
@@ -212,10 +225,13 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 
 	if (!ret)
 		return blkg;
-err_put:
+
+	blkg = ERR_PTR(ret);
+out_put:
 	css_put(&blkcg->css);
-	blkg_free(blkg);
-	return ERR_PTR(ret);
+out_free:
+	blkg_free(new_blkg);
+	return blkg;
 }
 
 struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
@@ -227,7 +243,7 @@ struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
 	 */
 	if (unlikely(blk_queue_bypass(q)))
 		return ERR_PTR(blk_queue_dead(q) ? -EINVAL : -EBUSY);
-	return __blkg_lookup_create(blkcg, q);
+	return __blkg_lookup_create(blkcg, q, NULL);
 }
 EXPORT_SYMBOL_GPL(blkg_lookup_create);
 
@@ -727,19 +743,30 @@ int blkcg_activate_policy(struct request_queue *q,
 	struct blkcg_gq *blkg;
 	struct blkg_policy_data *pd, *n;
 	int cnt = 0, ret;
+	bool preloaded;
 
 	if (blkcg_policy_enabled(q, pol))
 		return 0;
 
+	/* preallocations for root blkg */
+	blkg = blkg_alloc(&blkcg_root, q, GFP_KERNEL);
+	if (!blkg)
+		return -ENOMEM;
+
+	preloaded = !radix_tree_preload(GFP_KERNEL);
+
 	blk_queue_bypass_start(q);
 
 	/* make sure the root blkg exists and count the existing blkgs */
 	spin_lock_irq(q->queue_lock);
 
 	rcu_read_lock();
-	blkg = __blkg_lookup_create(&blkcg_root, q);
+	blkg = __blkg_lookup_create(&blkcg_root, q, blkg);
 	rcu_read_unlock();
 
+	if (preloaded)
+		radix_tree_preload_end();
+
 	if (IS_ERR(blkg)) {
 		ret = PTR_ERR(blkg);
 		goto out_unlock;
-- 
1.7.7.3
