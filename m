From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH UPDATED 06/11] blkcg: make sure blkg_lookup() returns %NULL
	if @q is bypassing
Date: Fri, 13 Apr 2012 14:50:53 -0700
Message-ID: <20120413215053.GK12233__6892.1614591547$1334353864$gmane$org@google.com>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
	<1334347895-6268-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1334347895-6268-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, blkg_lookup() doesn't check @q bypass state.  This patch
updates blk_queue_bypass_start() to do synchronize_rcu() before
returning and updates blkg_lookup() to check blk_queue_bypass() and
return %NULL if bypassing.  This ensures blkg_lookup() returns %NULL
if @q is bypassing.

This is to guarantee that nobody is accessing policy data while @q is
bypassing, which is necessary to allow replacing blkio_cgroup->pd[] in
place on policy [de]activation.

v2: Added more comments explaining bypass guarantees as suggested by
    Vivek.

v3: Added more comments explaining why there's no synchronize_rcu() in
    blk_cleanup_queue() as suggested by Vivek.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
This update only adds some comments.  It does cause some offset
warnings for the following patches but nothing patch(1) can't handle.
The git branch has been updated accordingly.

Thanks.

 block/blk-cgroup.c |   50 +++++++++++++++++++++++++++++++++-----------------
 block/blk-core.c   |   15 +++++++++++++--
 2 files changed, 46 insertions(+), 19 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index f6581a0..d6e4555 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -137,6 +137,38 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 	return blkg;
 }
 
+static struct blkio_group *__blkg_lookup(struct blkio_cgroup *blkcg,
+					 struct request_queue *q)
+{
+	struct blkio_group *blkg;
+	struct hlist_node *n;
+
+	hlist_for_each_entry_rcu(blkg, n, &blkcg->blkg_list, blkcg_node)
+		if (blkg->q == q)
+			return blkg;
+	return NULL;
+}
+
+/**
+ * blkg_lookup - lookup blkg for the specified blkcg - q pair
+ * @blkcg: blkcg of interest
+ * @q: request_queue of interest
+ *
+ * Lookup blkg for the @blkcg - @q pair.  This function should be called
+ * under RCU read lock and is guaranteed to return %NULL if @q is bypassing
+ * - see blk_queue_bypass_start() for details.
+ */
+struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
+				struct request_queue *q)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (unlikely(blk_queue_bypass(q)))
+		return NULL;
+	return __blkg_lookup(blkcg, q);
+}
+EXPORT_SYMBOL_GPL(blkg_lookup);
+
 struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 				       struct request_queue *q,
 				       bool for_root)
@@ -150,13 +182,11 @@ struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 	/*
 	 * This could be the first entry point of blkcg implementation and
 	 * we shouldn't allow anything to go through for a bypassing queue.
-	 * The following can be removed if blkg lookup is guaranteed to
-	 * fail on a bypassing queue.
 	 */
 	if (unlikely(blk_queue_bypass(q)) && !for_root)
 		return ERR_PTR(blk_queue_dead(q) ? -EINVAL : -EBUSY);
 
-	blkg = blkg_lookup(blkcg, q);
+	blkg = __blkg_lookup(blkcg, q);
 	if (blkg)
 		return blkg;
 
@@ -185,20 +215,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(blkg_lookup_create);
 
-/* called under rcu_read_lock(). */
-struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
-				struct request_queue *q)
-{
-	struct blkio_group *blkg;
-	struct hlist_node *n;
-
-	hlist_for_each_entry_rcu(blkg, n, &blkcg->blkg_list, blkcg_node)
-		if (blkg->q == q)
-			return blkg;
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(blkg_lookup);
-
 static void blkg_destroy(struct blkio_group *blkg)
 {
 	struct request_queue *q = blkg->q;
diff --git a/block/blk-core.c b/block/blk-core.c
index 991c1d6..f2db628 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -416,7 +416,8 @@ void blk_drain_queue(struct request_queue *q, bool drain_all)
  * In bypass mode, only the dispatch FIFO queue of @q is used.  This
  * function makes @q enter bypass mode and drains all requests which were
  * throttled or issued before.  On return, it's guaranteed that no request
- * is being throttled or has ELVPRIV set.
+ * is being throttled or has ELVPRIV set and blk_queue_bypass() %true
+ * inside queue or RCU read lock.
  */
 void blk_queue_bypass_start(struct request_queue *q)
 {
@@ -426,6 +427,8 @@ void blk_queue_bypass_start(struct request_queue *q)
 	spin_unlock_irq(q->queue_lock);
 
 	blk_drain_queue(q, false);
+	/* ensure blk_queue_bypass() is %true inside RCU read lock */
+	synchronize_rcu();
 }
 EXPORT_SYMBOL_GPL(blk_queue_bypass_start);
 
@@ -462,7 +465,15 @@ void blk_cleanup_queue(struct request_queue *q)
 
 	spin_lock_irq(lock);
 
-	/* dead queue is permanently in bypass mode till released */
+	/*
+	 * Dead queue is permanently in bypass mode till released.  Note
+	 * that, unlike blk_queue_bypass_start(), we aren't performing
+	 * synchronize_rcu() after entering bypass mode to avoid the delay
+	 * as some drivers create and destroy a lot of queues while
+	 * probing.  This is still safe because blk_release_queue() will be
+	 * called only after the queue refcnt drops to zero and nothing,
+	 * RCU or not, would be traversing the queue by then.
+	 */
 	q->bypass_depth++;
 	queue_flag_set(QUEUE_FLAG_BYPASS, q);
 
-- 
1.7.7.3
