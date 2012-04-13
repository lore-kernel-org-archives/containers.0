From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/11] blkcg: implement per-queue policy activation
Date: Fri, 13 Apr 2012 13:11:33 -0700
Message-ID: <1334347895-6268-10-git-send-email-tj@kernel.org>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334347895-6268-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

All blkcg policies were assumed to be enabled on all request_queues.
Due to various implementation obstacles, during the recent blkcg core
updates, this was temporarily implemented as shooting down all !root
blkgs on elevator switch and policy [de]registration combined with
half-broken in-place root blkg updates.  In addition to being buggy
and racy, this meant losing all blkcg configurations across those
events.

Now that blkcg is cleaned up enough, this patch replaces the temporary
implementation with proper per-queue policy activation.  Each blkcg
policy should call the new blkcg_[de]activate_policy() to enable and
disable the policy on a specific queue.  blkcg_activate_policy()
allocates and installs policy data for the policy for all existing
blkgs.  blkcg_deactivate_policy() does the reverse.  If a policy is
not enabled for a given queue, blkg printing / config functions skip
the respective blkg for the queue.

blkcg_activate_policy() also takes care of root blkg creation, and
cfq_init_queue() and blk_throtl_init() are updated accordingly.

This replaces blkcg_bypass_{start|end}() and update_root_blkg_pd()
unnecessary.  Dropped.

v2: cfq_init_queue() was returning uninitialized @ret on root_group
    alloc failure if !CONFIG_CFQ_GROUP_IOSCHED.  Fixed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c     |  228 ++++++++++++++++++++++++++++++++----------------
 block/blk-cgroup.h     |   15 +++-
 block/blk-throttle.c   |   52 ++++-------
 block/cfq-iosched.c    |   37 ++++-----
 block/elevator.c       |    2 -
 include/linux/blkdev.h |    1 +
 6 files changed, 201 insertions(+), 134 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index d6e4555..d6d59ad 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -54,6 +54,17 @@ struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio)
 }
 EXPORT_SYMBOL_GPL(bio_blkio_cgroup);
 
+static bool blkcg_policy_enabled(struct request_queue *q,
+				 const struct blkio_policy_type *pol)
+{
+	return pol && test_bit(pol->plid, q->blkcg_pols);
+}
+
+static size_t blkg_pd_size(const struct blkio_policy_type *pol)
+{
+	return sizeof(struct blkg_policy_data) + pol->pdata_size;
+}
+
 /**
  * blkg_free - free a blkg
  * @blkg: blkg to free
@@ -111,12 +122,11 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 		struct blkio_policy_type *pol = blkio_policy[i];
 		struct blkg_policy_data *pd;
 
-		if (!pol)
+		if (!blkcg_policy_enabled(q, pol))
 			continue;
 
 		/* alloc per-policy data and attach it to blkg */
-		pd = kzalloc_node(sizeof(*pd) + pol->pdata_size, GFP_ATOMIC,
-				  q->node);
+		pd = kzalloc_node(blkg_pd_size(pol), GFP_ATOMIC, q->node);
 		if (!pd) {
 			blkg_free(blkg);
 			return NULL;
@@ -130,7 +140,7 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 	for (i = 0; i < BLKCG_MAX_POLS; i++) {
 		struct blkio_policy_type *pol = blkio_policy[i];
 
-		if (pol)
+		if (blkcg_policy_enabled(blkg->q, pol))
 			pol->ops.blkio_init_group_fn(blkg);
 	}
 
@@ -236,36 +246,6 @@ static void blkg_destroy(struct blkio_group *blkg)
 	blkg_put(blkg);
 }
 
-/*
- * XXX: This updates blkg policy data in-place for root blkg, which is
- * necessary across elevator switch and policy registration as root blkgs
- * aren't shot down.  This broken and racy implementation is temporary.
- * Eventually, blkg shoot down will be replaced by proper in-place update.
- */
-void update_root_blkg_pd(struct request_queue *q,
-			 const struct blkio_policy_type *pol)
-{
-	struct blkio_group *blkg = blkg_lookup(&blkio_root_cgroup, q);
-	struct blkg_policy_data *pd;
-
-	if (!blkg)
-		return;
-
-	kfree(blkg->pd[pol->plid]);
-	blkg->pd[pol->plid] = NULL;
-
-	if (!pol)
-		return;
-
-	pd = kzalloc(sizeof(*pd) + pol->pdata_size, GFP_KERNEL);
-	WARN_ON_ONCE(!pd);
-
-	blkg->pd[pol->plid] = pd;
-	pd->blkg = blkg;
-	pol->ops.blkio_init_group_fn(blkg);
-}
-EXPORT_SYMBOL_GPL(update_root_blkg_pd);
-
 /**
  * blkg_destroy_all - destroy all blkgs associated with a request_queue
  * @q: request_queue of interest
@@ -339,7 +319,8 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 		for (i = 0; i < BLKCG_MAX_POLS; i++) {
 			struct blkio_policy_type *pol = blkio_policy[i];
 
-			if (pol && pol->ops.blkio_reset_group_stats_fn)
+			if (blkcg_policy_enabled(blkg->q, pol) &&
+			    pol->ops.blkio_reset_group_stats_fn)
 				pol->ops.blkio_reset_group_stats_fn(blkg);
 		}
 	}
@@ -385,7 +366,7 @@ void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 
 	spin_lock_irq(&blkcg->lock);
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node)
-		if (blkg->pd[pol->plid])
+		if (blkcg_policy_enabled(blkg->q, pol))
 			total += prfill(sf, blkg->pd[pol->plid]->pdata, data);
 	spin_unlock_irq(&blkcg->lock);
 
@@ -510,7 +491,10 @@ int blkg_conf_prep(struct blkio_cgroup *blkcg,
 	rcu_read_lock();
 	spin_lock_irq(disk->queue->queue_lock);
 
-	blkg = blkg_lookup_create(blkcg, disk->queue, false);
+	if (blkcg_policy_enabled(disk->queue, pol))
+		blkg = blkg_lookup_create(blkcg, disk->queue, false);
+	else
+		blkg = ERR_PTR(-EINVAL);
 
 	if (IS_ERR(blkg)) {
 		ret = PTR_ERR(blkg);
@@ -712,30 +696,6 @@ static int blkiocg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 	return ret;
 }
 
-static void blkcg_bypass_start(void)
-	__acquires(&all_q_mutex)
-{
-	struct request_queue *q;
-
-	mutex_lock(&all_q_mutex);
-
-	list_for_each_entry(q, &all_q_list, all_q_node) {
-		blk_queue_bypass_start(q);
-		blkg_destroy_all(q, false);
-	}
-}
-
-static void blkcg_bypass_end(void)
-	__releases(&all_q_mutex)
-{
-	struct request_queue *q;
-
-	list_for_each_entry(q, &all_q_list, all_q_node)
-		blk_queue_bypass_end(q);
-
-	mutex_unlock(&all_q_mutex);
-}
-
 struct cgroup_subsys blkio_subsys = {
 	.name = "blkio",
 	.create = blkiocg_create,
@@ -749,6 +709,139 @@ struct cgroup_subsys blkio_subsys = {
 EXPORT_SYMBOL_GPL(blkio_subsys);
 
 /**
+ * blkcg_activate_policy - activate a blkcg policy on a request_queue
+ * @q: request_queue of interest
+ * @pol: blkcg policy to activate
+ *
+ * Activate @pol on @q.  Requires %GFP_KERNEL context.  @q goes through
+ * bypass mode to populate its blkgs with policy_data for @pol.
+ *
+ * Activation happens with @q bypassed, so nobody would be accessing blkgs
+ * from IO path.  Update of each blkg is protected by both queue and blkcg
+ * locks so that holding either lock and testing blkcg_policy_enabled() is
+ * always enough for dereferencing policy data.
+ *
+ * The caller is responsible for synchronizing [de]activations and policy
+ * [un]registerations.  Returns 0 on success, -errno on failure.
+ */
+int blkcg_activate_policy(struct request_queue *q,
+			  const struct blkio_policy_type *pol)
+{
+	LIST_HEAD(pds);
+	struct blkio_group *blkg;
+	struct blkg_policy_data *pd, *n;
+	int cnt = 0, ret;
+
+	if (blkcg_policy_enabled(q, pol))
+		return 0;
+
+	blk_queue_bypass_start(q);
+
+	/* make sure the root blkg exists and count the existing blkgs */
+	spin_lock_irq(q->queue_lock);
+
+	rcu_read_lock();
+	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
+	rcu_read_unlock();
+
+	if (IS_ERR(blkg)) {
+		ret = PTR_ERR(blkg);
+		goto out_unlock;
+	}
+	q->root_blkg = blkg;
+
+	list_for_each_entry(blkg, &q->blkg_list, q_node)
+		cnt++;
+
+	spin_unlock_irq(q->queue_lock);
+
+	/* allocate policy_data for all existing blkgs */
+	while (cnt--) {
+		pd = kzalloc_node(blkg_pd_size(pol), GFP_KERNEL, q->node);
+		if (!pd) {
+			ret = -ENOMEM;
+			goto out_free;
+		}
+		list_add_tail(&pd->alloc_node, &pds);
+	}
+
+	/*
+	 * Install the allocated pds.  With @q bypassing, no new blkg
+	 * should have been created while the queue lock was dropped.
+	 */
+	spin_lock_irq(q->queue_lock);
+
+	list_for_each_entry(blkg, &q->blkg_list, q_node) {
+		if (WARN_ON(list_empty(&pds))) {
+			/* umm... this shouldn't happen, just abort */
+			ret = -ENOMEM;
+			goto out_unlock;
+		}
+		pd = list_first_entry(&pds, struct blkg_policy_data, alloc_node);
+		list_del_init(&pd->alloc_node);
+
+		/* grab blkcg lock too while installing @pd on @blkg */
+		spin_lock(&blkg->blkcg->lock);
+
+		blkg->pd[pol->plid] = pd;
+		pd->blkg = blkg;
+		pol->ops.blkio_init_group_fn(blkg);
+
+		spin_unlock(&blkg->blkcg->lock);
+	}
+
+	__set_bit(pol->plid, q->blkcg_pols);
+	ret = 0;
+out_unlock:
+	spin_unlock_irq(q->queue_lock);
+out_free:
+	blk_queue_bypass_end(q);
+	list_for_each_entry_safe(pd, n, &pds, alloc_node)
+		kfree(pd);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(blkcg_activate_policy);
+
+/**
+ * blkcg_deactivate_policy - deactivate a blkcg policy on a request_queue
+ * @q: request_queue of interest
+ * @pol: blkcg policy to deactivate
+ *
+ * Deactivate @pol on @q.  Follows the same synchronization rules as
+ * blkcg_activate_policy().
+ */
+void blkcg_deactivate_policy(struct request_queue *q,
+			     const struct blkio_policy_type *pol)
+{
+	struct blkio_group *blkg;
+
+	if (!blkcg_policy_enabled(q, pol))
+		return;
+
+	blk_queue_bypass_start(q);
+	spin_lock_irq(q->queue_lock);
+
+	__clear_bit(pol->plid, q->blkcg_pols);
+
+	list_for_each_entry(blkg, &q->blkg_list, q_node) {
+		/* grab blkcg lock too while removing @pd from @blkg */
+		spin_lock(&blkg->blkcg->lock);
+
+		if (pol->ops.blkio_exit_group_fn)
+			pol->ops.blkio_exit_group_fn(blkg);
+
+		kfree(blkg->pd[pol->plid]);
+		blkg->pd[pol->plid] = NULL;
+
+		spin_unlock(&blkg->blkcg->lock);
+	}
+
+	spin_unlock_irq(q->queue_lock);
+	blk_queue_bypass_end(q);
+}
+EXPORT_SYMBOL_GPL(blkcg_deactivate_policy);
+
+/**
  * blkio_policy_register - register a blkcg policy
  * @blkiop: blkcg policy to register
  *
@@ -758,7 +851,6 @@ EXPORT_SYMBOL_GPL(blkio_subsys);
  */
 int blkio_policy_register(struct blkio_policy_type *blkiop)
 {
-	struct request_queue *q;
 	int i, ret;
 
 	mutex_lock(&blkcg_pol_mutex);
@@ -775,11 +867,6 @@ int blkio_policy_register(struct blkio_policy_type *blkiop)
 	blkiop->plid = i;
 	blkio_policy[i] = blkiop;
 
-	blkcg_bypass_start();
-	list_for_each_entry(q, &all_q_list, all_q_node)
-		update_root_blkg_pd(q, blkiop);
-	blkcg_bypass_end();
-
 	/* everything is in place, add intf files for the new policy */
 	if (blkiop->cftypes)
 		WARN_ON(cgroup_add_cftypes(&blkio_subsys, blkiop->cftypes));
@@ -798,8 +885,6 @@ EXPORT_SYMBOL_GPL(blkio_policy_register);
  */
 void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 {
-	struct request_queue *q;
-
 	mutex_lock(&blkcg_pol_mutex);
 
 	if (WARN_ON(blkio_policy[blkiop->plid] != blkiop))
@@ -811,11 +896,6 @@ void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 
 	/* unregister and update blkgs */
 	blkio_policy[blkiop->plid] = NULL;
-
-	blkcg_bypass_start();
-	list_for_each_entry(q, &all_q_list, all_q_node)
-		update_root_blkg_pd(q, blkiop);
-	blkcg_bypass_end();
 out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
 }
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index df1c7b2..66253a7 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -64,6 +64,9 @@ struct blkg_policy_data {
 	/* the blkg this per-policy data belongs to */
 	struct blkio_group *blkg;
 
+	/* used during policy activation */
+	struct list_head alloc_node;
+
 	/* pol->pdata_size bytes of private data used by policy impl */
 	char pdata[] __aligned(__alignof__(unsigned long long));
 };
@@ -108,9 +111,11 @@ extern void blkcg_exit_queue(struct request_queue *q);
 /* Blkio controller policy registration */
 extern int blkio_policy_register(struct blkio_policy_type *);
 extern void blkio_policy_unregister(struct blkio_policy_type *);
+extern int blkcg_activate_policy(struct request_queue *q,
+				 const struct blkio_policy_type *pol);
+extern void blkcg_deactivate_policy(struct request_queue *q,
+				    const struct blkio_policy_type *pol);
 extern void blkg_destroy_all(struct request_queue *q, bool destroy_root);
-extern void update_root_blkg_pd(struct request_queue *q,
-				const struct blkio_policy_type *pol);
 
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
@@ -325,10 +330,12 @@ static inline void blkcg_drain_queue(struct request_queue *q) { }
 static inline void blkcg_exit_queue(struct request_queue *q) { }
 static inline int blkio_policy_register(struct blkio_policy_type *blkiop) { return 0; }
 static inline void blkio_policy_unregister(struct blkio_policy_type *blkiop) { }
+static inline int blkcg_activate_policy(struct request_queue *q,
+					const struct blkio_policy_type *pol) { return 0; }
+static inline void blkcg_deactivate_policy(struct request_queue *q,
+					   const struct blkio_policy_type *pol) { }
 static inline void blkg_destroy_all(struct request_queue *q,
 				    bool destory_root) { }
-static inline void update_root_blkg_pd(struct request_queue *q,
-				       const struct blkio_policy_type *pol) { }
 
 static inline void *blkg_to_pdata(struct blkio_group *blkg,
 				struct blkio_policy_type *pol) { return NULL; }
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 8c520fa..2fc964e 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -995,35 +995,31 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 	struct blkg_conf_ctx ctx;
 	struct throtl_grp *tg;
+	struct throtl_data *td;
 	int ret;
 
 	ret = blkg_conf_prep(blkcg, &blkio_policy_throtl, buf, &ctx);
 	if (ret)
 		return ret;
 
-	ret = -EINVAL;
 	tg = blkg_to_tg(ctx.blkg);
-	if (tg) {
-		struct throtl_data *td = ctx.blkg->q->td;
-
-		if (!ctx.v)
-			ctx.v = -1;
+	td = ctx.blkg->q->td;
 
-		if (is_u64)
-			*(u64 *)((void *)tg + cft->private) = ctx.v;
-		else
-			*(unsigned int *)((void *)tg + cft->private) = ctx.v;
+	if (!ctx.v)
+		ctx.v = -1;
 
-		/* XXX: we don't need the following deferred processing */
-		xchg(&tg->limits_changed, true);
-		xchg(&td->limits_changed, true);
-		throtl_schedule_delayed_work(td, 0);
+	if (is_u64)
+		*(u64 *)((void *)tg + cft->private) = ctx.v;
+	else
+		*(unsigned int *)((void *)tg + cft->private) = ctx.v;
 
-		ret = 0;
-	}
+	/* XXX: we don't need the following deferred processing */
+	xchg(&tg->limits_changed, true);
+	xchg(&td->limits_changed, true);
+	throtl_schedule_delayed_work(td, 0);
 
 	blkg_conf_finish(&ctx);
-	return ret;
+	return 0;
 }
 
 static int tg_set_conf_u64(struct cgroup *cgrp, struct cftype *cft,
@@ -1230,7 +1226,7 @@ void blk_throtl_drain(struct request_queue *q)
 int blk_throtl_init(struct request_queue *q)
 {
 	struct throtl_data *td;
-	struct blkio_group *blkg;
+	int ret;
 
 	td = kzalloc_node(sizeof(*td), GFP_KERNEL, q->node);
 	if (!td)
@@ -1243,28 +1239,18 @@ int blk_throtl_init(struct request_queue *q)
 	q->td = td;
 	td->queue = q;
 
-	/* alloc and init root group. */
-	rcu_read_lock();
-	spin_lock_irq(q->queue_lock);
-
-	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
-	if (!IS_ERR(blkg))
-		q->root_blkg = blkg;
-
-	spin_unlock_irq(q->queue_lock);
-	rcu_read_unlock();
-
-	if (!q->root_blkg) {
+	/* activate policy */
+	ret = blkcg_activate_policy(q, &blkio_policy_throtl);
+	if (ret)
 		kfree(td);
-		return -ENOMEM;
-	}
-	return 0;
+	return ret;
 }
 
 void blk_throtl_exit(struct request_queue *q)
 {
 	BUG_ON(!q->td);
 	throtl_shutdown_wq(q);
+	blkcg_deactivate_policy(q, &blkio_policy_throtl);
 	kfree(q->td);
 }
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 86440e0..0203652 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1406,8 +1406,7 @@ static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 
 	ret = -EINVAL;
 	cfqg = blkg_to_cfqg(ctx.blkg);
-	if (cfqg && (!ctx.v || (ctx.v >= CFQ_WEIGHT_MIN &&
-				ctx.v <= CFQ_WEIGHT_MAX))) {
+	if (!ctx.v || (ctx.v >= CFQ_WEIGHT_MIN && ctx.v <= CFQ_WEIGHT_MAX)) {
 		cfqg->dev_weight = ctx.v;
 		cfqg->new_weight = cfqg->dev_weight ?: blkcg->cfq_weight;
 		ret = 0;
@@ -3938,7 +3937,7 @@ static void cfq_exit_queue(struct elevator_queue *e)
 #ifndef CONFIG_CFQ_GROUP_IOSCHED
 	kfree(cfqd->root_group);
 #endif
-	update_root_blkg_pd(q, &blkio_policy_cfq);
+	blkcg_deactivate_policy(q, &blkio_policy_cfq);
 	kfree(cfqd);
 }
 
@@ -3946,7 +3945,7 @@ static int cfq_init_queue(struct request_queue *q)
 {
 	struct cfq_data *cfqd;
 	struct blkio_group *blkg __maybe_unused;
-	int i;
+	int i, ret;
 
 	cfqd = kmalloc_node(sizeof(*cfqd), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (!cfqd)
@@ -3960,28 +3959,20 @@ static int cfq_init_queue(struct request_queue *q)
 
 	/* Init root group and prefer root group over other groups by default */
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
-	rcu_read_lock();
-	spin_lock_irq(q->queue_lock);
-
-	blkg = blkg_lookup_create(&blkio_root_cgroup, q, true);
-	if (!IS_ERR(blkg)) {
-		q->root_blkg = blkg;
-		cfqd->root_group = blkg_to_cfqg(blkg);
-	}
+	ret = blkcg_activate_policy(q, &blkio_policy_cfq);
+	if (ret)
+		goto out_free;
 
-	spin_unlock_irq(q->queue_lock);
-	rcu_read_unlock();
+	cfqd->root_group = blkg_to_cfqg(q->root_blkg);
 #else
+	ret = -ENOMEM;
 	cfqd->root_group = kzalloc_node(sizeof(*cfqd->root_group),
 					GFP_KERNEL, cfqd->queue->node);
-	if (cfqd->root_group)
-		cfq_init_cfqg_base(cfqd->root_group);
-#endif
-	if (!cfqd->root_group) {
-		kfree(cfqd);
-		return -ENOMEM;
-	}
+	if (!cfqd->root_group)
+		goto out_free;
 
+	cfq_init_cfqg_base(cfqd->root_group);
+#endif
 	cfqd->root_group->weight = 2 * CFQ_WEIGHT_DEFAULT;
 
 	/*
@@ -4031,6 +4022,10 @@ static int cfq_init_queue(struct request_queue *q)
 	 */
 	cfqd->last_delayed_sync = jiffies - HZ;
 	return 0;
+
+out_free:
+	kfree(cfqd);
+	return ret;
 }
 
 /*
diff --git a/block/elevator.c b/block/elevator.c
index be3ab6d..6a55d41 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -896,8 +896,6 @@ static int elevator_switch(struct request_queue *q, struct elevator_type *new_e)
 	ioc_clear_queue(q);
 	spin_unlock_irq(q->queue_lock);
 
-	blkg_destroy_all(q, false);
-
 	/* allocate, init and register new elevator */
 	err = -ENOMEM;
 	q->elevator = elevator_alloc(q, new_e);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index b01c377..68720ab 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -370,6 +370,7 @@ struct request_queue {
 
 	struct list_head	icq_list;
 #ifdef CONFIG_BLK_CGROUP
+	DECLARE_BITMAP		(blkcg_pols, BLKCG_MAX_POLS);
 	struct blkio_group	*root_blkg;
 	struct list_head	blkg_list;
 #endif
-- 
1.7.7.3
