From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 8/8] blkcg: drop stuff unused after per-queue policy
	activation update
Date: Thu, 12 Apr 2012 16:29:40 -0700
Message-ID: <1334273380-30233-9-git-send-email-tj@kernel.org>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334273380-30233-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

* All_q_list is unused.  Drop all_q_{mutex|list}.

* @for_root of blkg_lookup_create() is always %false when called from
  outside blk-cgroup.c proper.  Factor out __blkg_lookup_create() so
  that it doesn't check whether @q is bypassing and use the
  underscored version for the @for_root callsite.

* blkg_destroy_all() is used only from blkcg proper and @destroy_root
  is always %true.  Make it static and drop @destroy_root.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c   |   61 ++++++++++++++++---------------------------------
 block/blk-cgroup.h   |    6 +----
 block/blk-throttle.c |    2 +-
 block/cfq-iosched.c  |    2 +-
 4 files changed, 23 insertions(+), 48 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index a92eaf9..be72e20 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -25,8 +25,6 @@
 #define MAX_KEY_LEN 100
 
 static DEFINE_MUTEX(blkcg_pol_mutex);
-static DEFINE_MUTEX(all_q_mutex);
-static LIST_HEAD(all_q_list);
 
 struct blkio_cgroup blkio_root_cgroup = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT };
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
@@ -179,9 +177,8 @@ struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
 }
 EXPORT_SYMBOL_GPL(blkg_lookup);
 
-struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
-				       struct request_queue *q,
-				       bool for_root)
+static struct blkio_group *__blkg_lookup_create(struct blkio_cgroup *blkcg,
+						struct request_queue *q)
 	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
 	struct blkio_group *blkg;
@@ -189,13 +186,6 @@ struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 	WARN_ON_ONCE(!rcu_read_lock_held());
 	lockdep_assert_held(q->queue_lock);
 
-	/*
-	 * This could be the first entry point of blkcg implementation and
-	 * we shouldn't allow anything to go through for a bypassing queue.
-	 */
-	if (unlikely(blk_queue_bypass(q)) && !for_root)
-		return ERR_PTR(blk_queue_dead(q) ? -EINVAL : -EBUSY);
-
 	blkg = __blkg_lookup(blkcg, q);
 	if (blkg)
 		return blkg;
@@ -223,6 +213,18 @@ struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 out:
 	return blkg;
 }
+
+struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
+				       struct request_queue *q)
+{
+	/*
+	 * This could be the first entry point of blkcg implementation and
+	 * we shouldn't allow anything to go through for a bypassing queue.
+	 */
+	if (unlikely(blk_queue_bypass(q)))
+		return ERR_PTR(blk_queue_dead(q) ? -EINVAL : -EBUSY);
+	return __blkg_lookup_create(blkcg, q);
+}
 EXPORT_SYMBOL_GPL(blkg_lookup_create);
 
 static void blkg_destroy(struct blkio_group *blkg)
@@ -249,12 +251,10 @@ static void blkg_destroy(struct blkio_group *blkg)
 /**
  * blkg_destroy_all - destroy all blkgs associated with a request_queue
  * @q: request_queue of interest
- * @destroy_root: whether to destroy root blkg or not
  *
- * Destroy blkgs associated with @q.  If @destroy_root is %true, all are
- * destroyed; otherwise, root blkg is left alone.
+ * Destroy all blkgs associated with @q.
  */
-void blkg_destroy_all(struct request_queue *q, bool destroy_root)
+static void blkg_destroy_all(struct request_queue *q)
 {
 	struct blkio_group *blkg, *n;
 
@@ -263,10 +263,6 @@ void blkg_destroy_all(struct request_queue *q, bool destroy_root)
 	list_for_each_entry_safe(blkg, n, &q->blkg_list, q_node) {
 		struct blkio_cgroup *blkcg = blkg->blkcg;
 
-		/* skip root? */
-		if (!destroy_root && blkg->blkcg == &blkio_root_cgroup)
-			continue;
-
 		spin_lock(&blkcg->lock);
 		blkg_destroy(blkg);
 		spin_unlock(&blkcg->lock);
@@ -274,7 +270,6 @@ void blkg_destroy_all(struct request_queue *q, bool destroy_root)
 
 	spin_unlock_irq(q->queue_lock);
 }
-EXPORT_SYMBOL_GPL(blkg_destroy_all);
 
 static void blkg_rcu_free(struct rcu_head *rcu_head)
 {
@@ -492,7 +487,7 @@ int blkg_conf_prep(struct blkio_cgroup *blkcg,
 	spin_lock_irq(disk->queue->queue_lock);
 
 	if (blkcg_policy_enabled(disk->queue, pol))
-		blkg = blkg_lookup_create(blkcg, disk->queue, false);
+		blkg = blkg_lookup_create(blkcg, disk->queue);
 	else
 		blkg = ERR_PTR(-EINVAL);
 
@@ -625,20 +620,9 @@ done:
  */
 int blkcg_init_queue(struct request_queue *q)
 {
-	int ret;
-
 	might_sleep();
 
-	ret = blk_throtl_init(q);
-	if (ret)
-		return ret;
-
-	mutex_lock(&all_q_mutex);
-	INIT_LIST_HEAD(&q->all_q_node);
-	list_add_tail(&q->all_q_node, &all_q_list);
-	mutex_unlock(&all_q_mutex);
-
-	return 0;
+	return blk_throtl_init(q);
 }
 
 /**
@@ -662,12 +646,7 @@ void blkcg_drain_queue(struct request_queue *q)
  */
 void blkcg_exit_queue(struct request_queue *q)
 {
-	mutex_lock(&all_q_mutex);
-	list_del_init(&q->all_q_node);
-	mutex_unlock(&all_q_mutex);
-
-	blkg_destroy_all(q, true);
-
+	blkg_destroy_all(q);
 	blk_throtl_exit(q);
 }
 
@@ -741,7 +720,7 @@ int blkcg_activate_policy(struct request_queue *q,
 	spin_lock_irq(q->queue_lock);
 
 	rcu_read_lock();
-	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
+	blkg = __blkg_lookup_create(&blkio_root_cgroup, q);
 	rcu_read_unlock();
 
 	if (IS_ERR(blkg)) {
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 519dc6b..1f5ebee 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -115,7 +115,6 @@ extern int blkcg_activate_policy(struct request_queue *q,
 				 const struct blkio_policy_type *pol);
 extern void blkcg_deactivate_policy(struct request_queue *q,
 				    const struct blkio_policy_type *pol);
-extern void blkg_destroy_all(struct request_queue *q, bool destroy_root);
 
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
@@ -334,8 +333,6 @@ static inline int blkcg_activate_policy(struct request_queue *q,
 					const struct blkio_policy_type *pol) { return 0; }
 static inline void blkcg_deactivate_policy(struct request_queue *q,
 					   const struct blkio_policy_type *pol) { }
-static inline void blkg_destroy_all(struct request_queue *q,
-				    bool destory_root) { }
 
 static inline void *blkg_to_pdata(struct blkio_group *blkg,
 				struct blkio_policy_type *pol) { return NULL; }
@@ -354,8 +351,7 @@ extern struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio);
 extern struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
 				       struct request_queue *q);
 struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
-				       struct request_queue *q,
-				       bool for_root);
+				       struct request_queue *q);
 #else
 struct cgroup;
 static inline struct blkio_cgroup *
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 2fc964e..e2aaf27 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -285,7 +285,7 @@ static struct throtl_grp *throtl_lookup_create_tg(struct throtl_data *td,
 	} else {
 		struct blkio_group *blkg;
 
-		blkg = blkg_lookup_create(blkcg, q, false);
+		blkg = blkg_lookup_create(blkcg, q);
 
 		/* if %NULL and @q is alive, fall back to root_tg */
 		if (!IS_ERR(blkg))
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 947db5f..79987fb 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1349,7 +1349,7 @@ static struct cfq_group *cfq_lookup_create_cfqg(struct cfq_data *cfqd,
 	} else {
 		struct blkio_group *blkg;
 
-		blkg = blkg_lookup_create(blkcg, q, false);
+		blkg = blkg_lookup_create(blkcg, q);
 		if (!IS_ERR(blkg))
 			cfqg = blkg_to_cfqg(blkg);
 	}
-- 
1.7.7.3
