From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/6] blkcg: mass rename of blkcg API
Date: Mon, 16 Apr 2012 13:57:25 -0700
Message-ID: <1334609847-12747-5-git-send-email-tj__23342.5679420636$1334609893$gmane$org@kernel.org>
References: <1334609847-12747-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334609847-12747-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

During the recent blkcg cleanup, most of blkcg API has changed to such
extent that mass renaming wouldn't cause any noticeable pain.  Take
the chance and cleanup the naming.

* Rename blkio_cgroup to blkcg.

* Drop blkio / blkiocg prefixes and consistently use blkcg.

* Rename blkio_group to blkcg_gq, which is consistent with io_cq but
  keep the blkg prefix / variable name.

* Rename policy method type and field names to signify they're dealing
  with policy data.

* Rename blkio_policy_type to blkcg_policy.

This patch doesn't cause any functional change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c     |  202 +++++++++++++++++++++++------------------------
 block/blk-cgroup.h     |  109 +++++++++++++-------------
 block/blk-throttle.c   |   72 +++++++++---------
 block/cfq-iosched.c    |   78 +++++++++---------
 include/linux/blkdev.h |    4 +-
 5 files changed, 230 insertions(+), 235 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 6333702..9975703 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -26,39 +26,39 @@
 
 static DEFINE_MUTEX(blkcg_pol_mutex);
 
-struct blkio_cgroup blkio_root_cgroup = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT };
-EXPORT_SYMBOL_GPL(blkio_root_cgroup);
+struct blkcg blkcg_root = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT };
+EXPORT_SYMBOL_GPL(blkcg_root);
 
-static struct blkio_policy_type *blkio_policy[BLKCG_MAX_POLS];
+static struct blkcg_policy *blkcg_policy[BLKCG_MAX_POLS];
 
-struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup)
+struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup)
 {
 	return container_of(cgroup_subsys_state(cgroup, blkio_subsys_id),
-			    struct blkio_cgroup, css);
+			    struct blkcg, css);
 }
-EXPORT_SYMBOL_GPL(cgroup_to_blkio_cgroup);
+EXPORT_SYMBOL_GPL(cgroup_to_blkcg);
 
-static struct blkio_cgroup *task_blkio_cgroup(struct task_struct *tsk)
+static struct blkcg *task_blkcg(struct task_struct *tsk)
 {
 	return container_of(task_subsys_state(tsk, blkio_subsys_id),
-			    struct blkio_cgroup, css);
+			    struct blkcg, css);
 }
 
-struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio)
+struct blkcg *bio_blkcg(struct bio *bio)
 {
 	if (bio && bio->bi_css)
-		return container_of(bio->bi_css, struct blkio_cgroup, css);
-	return task_blkio_cgroup(current);
+		return container_of(bio->bi_css, struct blkcg, css);
+	return task_blkcg(current);
 }
-EXPORT_SYMBOL_GPL(bio_blkio_cgroup);
+EXPORT_SYMBOL_GPL(bio_blkcg);
 
 static bool blkcg_policy_enabled(struct request_queue *q,
-				 const struct blkio_policy_type *pol)
+				 const struct blkcg_policy *pol)
 {
 	return pol && test_bit(pol->plid, q->blkcg_pols);
 }
 
-static size_t blkg_pd_size(const struct blkio_policy_type *pol)
+static size_t blkg_pd_size(const struct blkcg_policy *pol)
 {
 	return sizeof(struct blkg_policy_data) + pol->pdata_size;
 }
@@ -69,7 +69,7 @@ static size_t blkg_pd_size(const struct blkio_policy_type *pol)
  *
  * Free @blkg which may be partially allocated.
  */
-static void blkg_free(struct blkio_group *blkg)
+static void blkg_free(struct blkcg_gq *blkg)
 {
 	int i;
 
@@ -77,14 +77,14 @@ static void blkg_free(struct blkio_group *blkg)
 		return;
 
 	for (i = 0; i < BLKCG_MAX_POLS; i++) {
-		struct blkio_policy_type *pol = blkio_policy[i];
+		struct blkcg_policy *pol = blkcg_policy[i];
 		struct blkg_policy_data *pd = blkg->pd[i];
 
 		if (!pd)
 			continue;
 
-		if (pol && pol->ops.blkio_exit_group_fn)
-			pol->ops.blkio_exit_group_fn(blkg);
+		if (pol && pol->ops.pd_exit_fn)
+			pol->ops.pd_exit_fn(blkg);
 
 		kfree(pd);
 	}
@@ -99,10 +99,9 @@ static void blkg_free(struct blkio_group *blkg)
  *
  * Allocate a new blkg assocating @blkcg and @q.
  */
-static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
-				      struct request_queue *q)
+static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q)
 {
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 	int i;
 
 	/* alloc and init base part */
@@ -116,7 +115,7 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 	blkg->refcnt = 1;
 
 	for (i = 0; i < BLKCG_MAX_POLS; i++) {
-		struct blkio_policy_type *pol = blkio_policy[i];
+		struct blkcg_policy *pol = blkcg_policy[i];
 		struct blkg_policy_data *pd;
 
 		if (!blkcg_policy_enabled(q, pol))
@@ -135,19 +134,19 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 
 	/* invoke per-policy init */
 	for (i = 0; i < BLKCG_MAX_POLS; i++) {
-		struct blkio_policy_type *pol = blkio_policy[i];
+		struct blkcg_policy *pol = blkcg_policy[i];
 
 		if (blkcg_policy_enabled(blkg->q, pol))
-			pol->ops.blkio_init_group_fn(blkg);
+			pol->ops.pd_init_fn(blkg);
 	}
 
 	return blkg;
 }
 
-static struct blkio_group *__blkg_lookup(struct blkio_cgroup *blkcg,
-					 struct request_queue *q)
+static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
+				      struct request_queue *q)
 {
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 	struct hlist_node *n;
 
 	hlist_for_each_entry_rcu(blkg, n, &blkcg->blkg_list, blkcg_node)
@@ -165,8 +164,7 @@ static struct blkio_group *__blkg_lookup(struct blkio_cgroup *blkcg,
  * under RCU read lock and is guaranteed to return %NULL if @q is bypassing
  * - see blk_queue_bypass_start() for details.
  */
-struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
-				struct request_queue *q)
+struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, struct request_queue *q)
 {
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
@@ -176,11 +174,11 @@ struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
 }
 EXPORT_SYMBOL_GPL(blkg_lookup);
 
-static struct blkio_group *__blkg_lookup_create(struct blkio_cgroup *blkcg,
-						struct request_queue *q)
+static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
+					     struct request_queue *q)
 	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 	lockdep_assert_held(q->queue_lock);
@@ -213,8 +211,8 @@ out:
 	return blkg;
 }
 
-struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
-				       struct request_queue *q)
+struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
+				    struct request_queue *q)
 {
 	/*
 	 * This could be the first entry point of blkcg implementation and
@@ -226,10 +224,10 @@ struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 }
 EXPORT_SYMBOL_GPL(blkg_lookup_create);
 
-static void blkg_destroy(struct blkio_group *blkg)
+static void blkg_destroy(struct blkcg_gq *blkg)
 {
 	struct request_queue *q = blkg->q;
-	struct blkio_cgroup *blkcg = blkg->blkcg;
+	struct blkcg *blkcg = blkg->blkcg;
 
 	lockdep_assert_held(q->queue_lock);
 	lockdep_assert_held(&blkcg->lock);
@@ -255,12 +253,12 @@ static void blkg_destroy(struct blkio_group *blkg)
  */
 static void blkg_destroy_all(struct request_queue *q)
 {
-	struct blkio_group *blkg, *n;
+	struct blkcg_gq *blkg, *n;
 
 	lockdep_assert_held(q->queue_lock);
 
 	list_for_each_entry_safe(blkg, n, &q->blkg_list, q_node) {
-		struct blkio_cgroup *blkcg = blkg->blkcg;
+		struct blkcg *blkcg = blkg->blkcg;
 
 		spin_lock(&blkcg->lock);
 		blkg_destroy(blkg);
@@ -270,10 +268,10 @@ static void blkg_destroy_all(struct request_queue *q)
 
 static void blkg_rcu_free(struct rcu_head *rcu_head)
 {
-	blkg_free(container_of(rcu_head, struct blkio_group, rcu_head));
+	blkg_free(container_of(rcu_head, struct blkcg_gq, rcu_head));
 }
 
-void __blkg_release(struct blkio_group *blkg)
+void __blkg_release(struct blkcg_gq *blkg)
 {
 	/* release the extra blkcg reference this blkg has been holding */
 	css_put(&blkg->blkcg->css);
@@ -291,11 +289,11 @@ void __blkg_release(struct blkio_group *blkg)
 }
 EXPORT_SYMBOL_GPL(__blkg_release);
 
-static int
-blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
+static int blkcg_reset_stats(struct cgroup *cgroup, struct cftype *cftype,
+			     u64 val)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
-	struct blkio_group *blkg;
+	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
+	struct blkcg_gq *blkg;
 	struct hlist_node *n;
 	int i;
 
@@ -309,11 +307,11 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	 */
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
 		for (i = 0; i < BLKCG_MAX_POLS; i++) {
-			struct blkio_policy_type *pol = blkio_policy[i];
+			struct blkcg_policy *pol = blkcg_policy[i];
 
 			if (blkcg_policy_enabled(blkg->q, pol) &&
-			    pol->ops.blkio_reset_group_stats_fn)
-				pol->ops.blkio_reset_group_stats_fn(blkg);
+			    pol->ops.pd_reset_stats_fn)
+				pol->ops.pd_reset_stats_fn(blkg);
 		}
 	}
 
@@ -322,7 +320,7 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	return 0;
 }
 
-static const char *blkg_dev_name(struct blkio_group *blkg)
+static const char *blkg_dev_name(struct blkcg_gq *blkg)
 {
 	/* some drivers (floppy) instantiate a queue w/o disk registered */
 	if (blkg->q->backing_dev_info.dev)
@@ -347,12 +345,12 @@ static const char *blkg_dev_name(struct blkio_group *blkg)
  * This is to be used to construct print functions for
  * cftype->read_seq_string method.
  */
-void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
+void blkcg_print_blkgs(struct seq_file *sf, struct blkcg *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
-		       const struct blkio_policy_type *pol, int data,
+		       const struct blkcg_policy *pol, int data,
 		       bool show_total)
 {
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 	struct hlist_node *n;
 	u64 total = 0;
 
@@ -462,13 +460,12 @@ EXPORT_SYMBOL_GPL(blkg_prfill_rwstat);
  * value.  This function returns with RCU read lock and queue lock held and
  * must be paired with blkg_conf_finish().
  */
-int blkg_conf_prep(struct blkio_cgroup *blkcg,
-		   const struct blkio_policy_type *pol, const char *input,
-		   struct blkg_conf_ctx *ctx)
+int blkg_conf_prep(struct blkcg *blkcg, const struct blkcg_policy *pol,
+		   const char *input, struct blkg_conf_ctx *ctx)
 	__acquires(rcu) __acquires(disk->queue->queue_lock)
 {
 	struct gendisk *disk;
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 	unsigned int major, minor;
 	unsigned long long v;
 	int part, ret;
@@ -529,16 +526,16 @@ void blkg_conf_finish(struct blkg_conf_ctx *ctx)
 }
 EXPORT_SYMBOL_GPL(blkg_conf_finish);
 
-struct cftype blkio_files[] = {
+struct cftype blkcg_files[] = {
 	{
 		.name = "reset_stats",
-		.write_u64 = blkiocg_reset_stats,
+		.write_u64 = blkcg_reset_stats,
 	},
 	{ }	/* terminate */
 };
 
 /**
- * blkiocg_pre_destroy - cgroup pre_destroy callback
+ * blkcg_pre_destroy - cgroup pre_destroy callback
  * @cgroup: cgroup of interest
  *
  * This function is called when @cgroup is about to go away and responsible
@@ -548,15 +545,15 @@ struct cftype blkio_files[] = {
  *
  * This is the blkcg counterpart of ioc_release_fn().
  */
-static int blkiocg_pre_destroy(struct cgroup *cgroup)
+static int blkcg_pre_destroy(struct cgroup *cgroup)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
 
 	spin_lock_irq(&blkcg->lock);
 
 	while (!hlist_empty(&blkcg->blkg_list)) {
-		struct blkio_group *blkg = hlist_entry(blkcg->blkg_list.first,
-						struct blkio_group, blkcg_node);
+		struct blkcg_gq *blkg = hlist_entry(blkcg->blkg_list.first,
+						struct blkcg_gq, blkcg_node);
 		struct request_queue *q = blkg->q;
 
 		if (spin_trylock(q->queue_lock)) {
@@ -573,22 +570,22 @@ static int blkiocg_pre_destroy(struct cgroup *cgroup)
 	return 0;
 }
 
-static void blkiocg_destroy(struct cgroup *cgroup)
+static void blkcg_destroy(struct cgroup *cgroup)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgroup);
 
-	if (blkcg != &blkio_root_cgroup)
+	if (blkcg != &blkcg_root)
 		kfree(blkcg);
 }
 
-static struct cgroup_subsys_state *blkiocg_create(struct cgroup *cgroup)
+static struct cgroup_subsys_state *blkcg_create(struct cgroup *cgroup)
 {
 	static atomic64_t id_seq = ATOMIC64_INIT(0);
-	struct blkio_cgroup *blkcg;
+	struct blkcg *blkcg;
 	struct cgroup *parent = cgroup->parent;
 
 	if (!parent) {
-		blkcg = &blkio_root_cgroup;
+		blkcg = &blkcg_root;
 		goto done;
 	}
 
@@ -656,7 +653,7 @@ void blkcg_exit_queue(struct request_queue *q)
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkiocg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+static int blkcg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	struct task_struct *task;
 	struct io_context *ioc;
@@ -677,12 +674,12 @@ static int blkiocg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 
 struct cgroup_subsys blkio_subsys = {
 	.name = "blkio",
-	.create = blkiocg_create,
-	.can_attach = blkiocg_can_attach,
-	.pre_destroy = blkiocg_pre_destroy,
-	.destroy = blkiocg_destroy,
+	.create = blkcg_create,
+	.can_attach = blkcg_can_attach,
+	.pre_destroy = blkcg_pre_destroy,
+	.destroy = blkcg_destroy,
 	.subsys_id = blkio_subsys_id,
-	.base_cftypes = blkio_files,
+	.base_cftypes = blkcg_files,
 	.module = THIS_MODULE,
 };
 EXPORT_SYMBOL_GPL(blkio_subsys);
@@ -704,10 +701,10 @@ EXPORT_SYMBOL_GPL(blkio_subsys);
  * [un]registerations.  Returns 0 on success, -errno on failure.
  */
 int blkcg_activate_policy(struct request_queue *q,
-			  const struct blkio_policy_type *pol)
+			  const struct blkcg_policy *pol)
 {
 	LIST_HEAD(pds);
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 	struct blkg_policy_data *pd, *n;
 	int cnt = 0, ret;
 
@@ -720,7 +717,7 @@ int blkcg_activate_policy(struct request_queue *q,
 	spin_lock_irq(q->queue_lock);
 
 	rcu_read_lock();
-	blkg = __blkg_lookup_create(&blkio_root_cgroup, q);
+	blkg = __blkg_lookup_create(&blkcg_root, q);
 	rcu_read_unlock();
 
 	if (IS_ERR(blkg)) {
@@ -764,7 +761,7 @@ int blkcg_activate_policy(struct request_queue *q,
 
 		blkg->pd[pol->plid] = pd;
 		pd->blkg = blkg;
-		pol->ops.blkio_init_group_fn(blkg);
+		pol->ops.pd_init_fn(blkg);
 
 		spin_unlock(&blkg->blkcg->lock);
 	}
@@ -790,9 +787,9 @@ EXPORT_SYMBOL_GPL(blkcg_activate_policy);
  * blkcg_activate_policy().
  */
 void blkcg_deactivate_policy(struct request_queue *q,
-			     const struct blkio_policy_type *pol)
+			     const struct blkcg_policy *pol)
 {
-	struct blkio_group *blkg;
+	struct blkcg_gq *blkg;
 
 	if (!blkcg_policy_enabled(q, pol))
 		return;
@@ -810,8 +807,8 @@ void blkcg_deactivate_policy(struct request_queue *q,
 		/* grab blkcg lock too while removing @pd from @blkg */
 		spin_lock(&blkg->blkcg->lock);
 
-		if (pol->ops.blkio_exit_group_fn)
-			pol->ops.blkio_exit_group_fn(blkg);
+		if (pol->ops.pd_exit_fn)
+			pol->ops.pd_exit_fn(blkg);
 
 		kfree(blkg->pd[pol->plid]);
 		blkg->pd[pol->plid] = NULL;
@@ -825,14 +822,13 @@ void blkcg_deactivate_policy(struct request_queue *q,
 EXPORT_SYMBOL_GPL(blkcg_deactivate_policy);
 
 /**
- * blkio_policy_register - register a blkcg policy
- * @blkiop: blkcg policy to register
+ * blkcg_policy_register - register a blkcg policy
+ * @pol: blkcg policy to register
  *
- * Register @blkiop with blkcg core.  Might sleep and @blkiop may be
- * modified on successful registration.  Returns 0 on success and -errno on
- * failure.
+ * Register @pol with blkcg core.  Might sleep and @pol may be modified on
+ * successful registration.  Returns 0 on success and -errno on failure.
  */
-int blkio_policy_register(struct blkio_policy_type *blkiop)
+int blkcg_policy_register(struct blkcg_policy *pol)
 {
 	int i, ret;
 
@@ -841,45 +837,45 @@ int blkio_policy_register(struct blkio_policy_type *blkiop)
 	/* find an empty slot */
 	ret = -ENOSPC;
 	for (i = 0; i < BLKCG_MAX_POLS; i++)
-		if (!blkio_policy[i])
+		if (!blkcg_policy[i])
 			break;
 	if (i >= BLKCG_MAX_POLS)
 		goto out_unlock;
 
 	/* register and update blkgs */
-	blkiop->plid = i;
-	blkio_policy[i] = blkiop;
+	pol->plid = i;
+	blkcg_policy[i] = pol;
 
 	/* everything is in place, add intf files for the new policy */
-	if (blkiop->cftypes)
-		WARN_ON(cgroup_add_cftypes(&blkio_subsys, blkiop->cftypes));
+	if (pol->cftypes)
+		WARN_ON(cgroup_add_cftypes(&blkio_subsys, pol->cftypes));
 	ret = 0;
 out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(blkio_policy_register);
+EXPORT_SYMBOL_GPL(blkcg_policy_register);
 
 /**
- * blkiop_policy_unregister - unregister a blkcg policy
- * @blkiop: blkcg policy to unregister
+ * blkcg_policy_unregister - unregister a blkcg policy
+ * @pol: blkcg policy to unregister
  *
- * Undo blkio_policy_register(@blkiop).  Might sleep.
+ * Undo blkcg_policy_register(@pol).  Might sleep.
  */
-void blkio_policy_unregister(struct blkio_policy_type *blkiop)
+void blkcg_policy_unregister(struct blkcg_policy *pol)
 {
 	mutex_lock(&blkcg_pol_mutex);
 
-	if (WARN_ON(blkio_policy[blkiop->plid] != blkiop))
+	if (WARN_ON(blkcg_policy[pol->plid] != pol))
 		goto out_unlock;
 
 	/* kill the intf files first */
-	if (blkiop->cftypes)
-		cgroup_rm_cftypes(&blkio_subsys, blkiop->cftypes);
+	if (pol->cftypes)
+		cgroup_rm_cftypes(&blkio_subsys, pol->cftypes);
 
 	/* unregister and update blkgs */
-	blkio_policy[blkiop->plid] = NULL;
+	blkcg_policy[pol->plid] = NULL;
 out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
 }
-EXPORT_SYMBOL_GPL(blkio_policy_unregister);
+EXPORT_SYMBOL_GPL(blkcg_policy_unregister);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index b347aa0..a443b84 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -37,7 +37,7 @@ enum blkg_rwstat_type {
 	BLKG_RWSTAT_TOTAL = BLKG_RWSTAT_NR,
 };
 
-struct blkio_cgroup {
+struct blkcg {
 	struct cgroup_subsys_state	css;
 	spinlock_t			lock;
 	struct hlist_head		blkg_list;
@@ -45,7 +45,7 @@ struct blkio_cgroup {
 	/* for policies to test whether associated blkcg has changed */
 	uint64_t			id;
 
-	/* TODO: per-policy storage in blkio_cgroup */
+	/* TODO: per-policy storage in blkcg */
 	unsigned int			cfq_weight;	/* belongs to cfq */
 };
 
@@ -62,7 +62,7 @@ struct blkg_rwstat {
 /* per-blkg per-policy data */
 struct blkg_policy_data {
 	/* the blkg this per-policy data belongs to */
-	struct blkio_group		*blkg;
+	struct blkcg_gq			*blkg;
 
 	/* used during policy activation */
 	struct list_head		alloc_node;
@@ -71,12 +71,13 @@ struct blkg_policy_data {
 	char				pdata[] __aligned(__alignof__(unsigned long long));
 };
 
-struct blkio_group {
+/* association between a blk cgroup and a request queue */
+struct blkcg_gq {
 	/* Pointer to the associated request_queue */
 	struct request_queue		*q;
 	struct list_head		q_node;
 	struct hlist_node		blkcg_node;
-	struct blkio_cgroup		*blkcg;
+	struct blkcg			*blkcg;
 	/* reference count */
 	int				refcnt;
 
@@ -85,18 +86,18 @@ struct blkio_group {
 	struct rcu_head			rcu_head;
 };
 
-typedef void (blkio_init_group_fn)(struct blkio_group *blkg);
-typedef void (blkio_exit_group_fn)(struct blkio_group *blkg);
-typedef void (blkio_reset_group_stats_fn)(struct blkio_group *blkg);
+typedef void (blkcg_pol_init_pd_fn)(struct blkcg_gq *blkg);
+typedef void (blkcg_pol_exit_pd_fn)(struct blkcg_gq *blkg);
+typedef void (blkcg_pol_reset_pd_stats_fn)(struct blkcg_gq *blkg);
 
-struct blkio_policy_ops {
-	blkio_init_group_fn		*blkio_init_group_fn;
-	blkio_exit_group_fn		*blkio_exit_group_fn;
-	blkio_reset_group_stats_fn	*blkio_reset_group_stats_fn;
+struct blkcg_policy_ops {
+	blkcg_pol_init_pd_fn		*pd_init_fn;
+	blkcg_pol_exit_pd_fn		*pd_exit_fn;
+	blkcg_pol_reset_pd_stats_fn	*pd_reset_stats_fn;
 };
 
-struct blkio_policy_type {
-	struct blkio_policy_ops		ops;
+struct blkcg_policy {
+	struct blkcg_policy_ops		ops;
 	int				plid;
 	/* policy specific private data size */
 	size_t				pdata_size;
@@ -104,29 +105,28 @@ struct blkio_policy_type {
 	struct cftype			*cftypes;
 };
 
-extern struct blkio_cgroup blkio_root_cgroup;
+extern struct blkcg blkcg_root;
 
-struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
-struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio);
-struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
-				struct request_queue *q);
-struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
-				       struct request_queue *q);
+struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup);
+struct blkcg *bio_blkcg(struct bio *bio);
+struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, struct request_queue *q);
+struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
+				    struct request_queue *q);
 int blkcg_init_queue(struct request_queue *q);
 void blkcg_drain_queue(struct request_queue *q);
 void blkcg_exit_queue(struct request_queue *q);
 
 /* Blkio controller policy registration */
-int blkio_policy_register(struct blkio_policy_type *);
-void blkio_policy_unregister(struct blkio_policy_type *);
+int blkcg_policy_register(struct blkcg_policy *pol);
+void blkcg_policy_unregister(struct blkcg_policy *pol);
 int blkcg_activate_policy(struct request_queue *q,
-			  const struct blkio_policy_type *pol);
+			  const struct blkcg_policy *pol);
 void blkcg_deactivate_policy(struct request_queue *q,
-			     const struct blkio_policy_type *pol);
+			     const struct blkcg_policy *pol);
 
-void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
+void blkcg_print_blkgs(struct seq_file *sf, struct blkcg *blkcg,
 		       u64 (*prfill)(struct seq_file *, void *, int),
-		       const struct blkio_policy_type *pol, int data,
+		       const struct blkcg_policy *pol, int data,
 		       bool show_total);
 u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v);
 u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
@@ -136,13 +136,12 @@ u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off);
 
 struct blkg_conf_ctx {
 	struct gendisk			*disk;
-	struct blkio_group		*blkg;
+	struct blkcg_gq			*blkg;
 	u64				v;
 };
 
-int blkg_conf_prep(struct blkio_cgroup *blkcg,
-		   const struct blkio_policy_type *pol, const char *input,
-		   struct blkg_conf_ctx *ctx);
+int blkg_conf_prep(struct blkcg *blkcg, const struct blkcg_policy *pol,
+		   const char *input, struct blkg_conf_ctx *ctx);
 void blkg_conf_finish(struct blkg_conf_ctx *ctx);
 
 
@@ -153,8 +152,8 @@ void blkg_conf_finish(struct blkg_conf_ctx *ctx);
  *
  * Return pointer to private data associated with the @blkg-@pol pair.
  */
-static inline void *blkg_to_pdata(struct blkio_group *blkg,
-			      struct blkio_policy_type *pol)
+static inline void *blkg_to_pdata(struct blkcg_gq *blkg,
+				  struct blkcg_policy *pol)
 {
 	return blkg ? blkg->pd[pol->plid]->pdata : NULL;
 }
@@ -165,7 +164,7 @@ static inline void *blkg_to_pdata(struct blkio_group *blkg,
  *
  * @pdata is policy private data.  Determine the blkg it's associated with.
  */
-static inline struct blkio_group *pdata_to_blkg(void *pdata)
+static inline struct blkcg_gq *pdata_to_blkg(void *pdata)
 {
 	if (pdata) {
 		struct blkg_policy_data *pd =
@@ -183,7 +182,7 @@ static inline struct blkio_group *pdata_to_blkg(void *pdata)
  *
  * Format the path of the cgroup of @blkg into @buf.
  */
-static inline int blkg_path(struct blkio_group *blkg, char *buf, int buflen)
+static inline int blkg_path(struct blkcg_gq *blkg, char *buf, int buflen)
 {
 	int ret;
 
@@ -201,14 +200,14 @@ static inline int blkg_path(struct blkio_group *blkg, char *buf, int buflen)
  *
  * The caller should be holding queue_lock and an existing reference.
  */
-static inline void blkg_get(struct blkio_group *blkg)
+static inline void blkg_get(struct blkcg_gq *blkg)
 {
 	lockdep_assert_held(blkg->q->queue_lock);
 	WARN_ON_ONCE(!blkg->refcnt);
 	blkg->refcnt++;
 }
 
-void __blkg_release(struct blkio_group *blkg);
+void __blkg_release(struct blkcg_gq *blkg);
 
 /**
  * blkg_put - put a blkg reference
@@ -216,7 +215,7 @@ void __blkg_release(struct blkio_group *blkg);
  *
  * The caller should be holding queue_lock.
  */
-static inline void blkg_put(struct blkio_group *blkg)
+static inline void blkg_put(struct blkcg_gq *blkg)
 {
 	lockdep_assert_held(blkg->q->queue_lock);
 	WARN_ON_ONCE(blkg->refcnt <= 0);
@@ -343,32 +342,32 @@ static inline void blkg_rwstat_reset(struct blkg_rwstat *rwstat)
 
 struct cgroup;
 
-struct blkio_group {
+struct blkcg_gq {
 };
 
-struct blkio_policy_type {
+struct blkcg_policy {
 };
 
-static inline struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup) { return NULL; }
-static inline struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio) { return NULL; }
-static inline struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg, void *key) { return NULL; }
+static inline struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup) { return NULL; }
+static inline struct blkcg *bio_blkcg(struct bio *bio) { return NULL; }
+static inline struct blkcg_gq *blkg_lookup(struct blkcg *blkcg, void *key) { return NULL; }
 static inline int blkcg_init_queue(struct request_queue *q) { return 0; }
 static inline void blkcg_drain_queue(struct request_queue *q) { }
 static inline void blkcg_exit_queue(struct request_queue *q) { }
-static inline int blkio_policy_register(struct blkio_policy_type *blkiop) { return 0; }
-static inline void blkio_policy_unregister(struct blkio_policy_type *blkiop) { }
+static inline int blkcg_policy_register(struct blkcg_policy *pol) { return 0; }
+static inline void blkcg_policy_unregister(struct blkcg_policy *pol) { }
 static inline int blkcg_activate_policy(struct request_queue *q,
-					const struct blkio_policy_type *pol) { return 0; }
+					const struct blkcg_policy *pol) { return 0; }
 static inline void blkcg_deactivate_policy(struct request_queue *q,
-					   const struct blkio_policy_type *pol) { }
-
-static inline void *blkg_to_pdata(struct blkio_group *blkg,
-				struct blkio_policy_type *pol) { return NULL; }
-static inline struct blkio_group *pdata_to_blkg(void *pdata,
-				struct blkio_policy_type *pol) { return NULL; }
-static inline char *blkg_path(struct blkio_group *blkg) { return NULL; }
-static inline void blkg_get(struct blkio_group *blkg) { }
-static inline void blkg_put(struct blkio_group *blkg) { }
+					   const struct blkcg_policy *pol) { }
+
+static inline void *blkg_to_pdata(struct blkcg_gq *blkg,
+				  struct blkcg_policy *pol) { return NULL; }
+static inline struct blkcg_gq *pdata_to_blkg(void *pdata,
+				  struct blkcg_policy *pol) { return NULL; }
+static inline char *blkg_path(struct blkcg_gq *blkg) { return NULL; }
+static inline void blkg_get(struct blkcg_gq *blkg) { }
+static inline void blkg_put(struct blkcg_gq *blkg) { }
 
 #endif	/* CONFIG_BLK_CGROUP */
 #endif	/* _BLK_CGROUP_H */
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index e9b7a47..00c7eff 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -21,7 +21,7 @@ static int throtl_quantum = 32;
 /* Throttling is performed over 100ms slice and after that slice is renewed */
 static unsigned long throtl_slice = HZ/10;	/* 100 ms */
 
-static struct blkio_policy_type blkio_policy_throtl;
+static struct blkcg_policy blkcg_policy_throtl;
 
 /* A workqueue to queue throttle related work */
 static struct workqueue_struct *kthrotld_workqueue;
@@ -120,12 +120,12 @@ static LIST_HEAD(tg_stats_alloc_list);
 static void tg_stats_alloc_fn(struct work_struct *);
 static DECLARE_DELAYED_WORK(tg_stats_alloc_work, tg_stats_alloc_fn);
 
-static inline struct throtl_grp *blkg_to_tg(struct blkio_group *blkg)
+static inline struct throtl_grp *blkg_to_tg(struct blkcg_gq *blkg)
 {
-	return blkg_to_pdata(blkg, &blkio_policy_throtl);
+	return blkg_to_pdata(blkg, &blkcg_policy_throtl);
 }
 
-static inline struct blkio_group *tg_to_blkg(struct throtl_grp *tg)
+static inline struct blkcg_gq *tg_to_blkg(struct throtl_grp *tg)
 {
 	return pdata_to_blkg(tg);
 }
@@ -208,7 +208,7 @@ alloc_stats:
 		goto alloc_stats;
 }
 
-static void throtl_init_blkio_group(struct blkio_group *blkg)
+static void throtl_pd_init(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 
@@ -233,7 +233,7 @@ static void throtl_init_blkio_group(struct blkio_group *blkg)
 	spin_unlock(&tg_stats_alloc_lock);
 }
 
-static void throtl_exit_blkio_group(struct blkio_group *blkg)
+static void throtl_pd_exit(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 
@@ -244,7 +244,7 @@ static void throtl_exit_blkio_group(struct blkio_group *blkg)
 	free_percpu(tg->stats_cpu);
 }
 
-static void throtl_reset_group_stats(struct blkio_group *blkg)
+static void throtl_pd_reset_stats(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 	int cpu;
@@ -260,33 +260,33 @@ static void throtl_reset_group_stats(struct blkio_group *blkg)
 	}
 }
 
-static struct
-throtl_grp *throtl_lookup_tg(struct throtl_data *td, struct blkio_cgroup *blkcg)
+static struct throtl_grp *throtl_lookup_tg(struct throtl_data *td,
+					   struct blkcg *blkcg)
 {
 	/*
-	 * This is the common case when there are no blkio cgroups.
-	 * Avoid lookup in this case
+	 * This is the common case when there are no blkcgs.  Avoid lookup
+	 * in this case
 	 */
-	if (blkcg == &blkio_root_cgroup)
+	if (blkcg == &blkcg_root)
 		return td_root_tg(td);
 
 	return blkg_to_tg(blkg_lookup(blkcg, td->queue));
 }
 
 static struct throtl_grp *throtl_lookup_create_tg(struct throtl_data *td,
-						  struct blkio_cgroup *blkcg)
+						  struct blkcg *blkcg)
 {
 	struct request_queue *q = td->queue;
 	struct throtl_grp *tg = NULL;
 
 	/*
-	 * This is the common case when there are no blkio cgroups.
-	 * Avoid lookup in this case
+	 * This is the common case when there are no blkcgs.  Avoid lookup
+	 * in this case
 	 */
-	if (blkcg == &blkio_root_cgroup) {
+	if (blkcg == &blkcg_root) {
 		tg = td_root_tg(td);
 	} else {
-		struct blkio_group *blkg;
+		struct blkcg_gq *blkg;
 
 		blkg = blkg_lookup_create(blkcg, q);
 
@@ -665,7 +665,7 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 	return 0;
 }
 
-static void throtl_update_dispatch_stats(struct blkio_group *blkg, u64 bytes,
+static void throtl_update_dispatch_stats(struct blkcg_gq *blkg, u64 bytes,
 					 int rw)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
@@ -822,7 +822,7 @@ static int throtl_select_dispatch(struct throtl_data *td, struct bio_list *bl)
 static void throtl_process_limit_change(struct throtl_data *td)
 {
 	struct request_queue *q = td->queue;
-	struct blkio_group *blkg, *n;
+	struct blkcg_gq *blkg, *n;
 
 	if (!td->limits_changed)
 		return;
@@ -951,9 +951,9 @@ static u64 tg_prfill_cpu_rwstat(struct seq_file *sf, void *pdata, int off)
 static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 			       struct seq_file *sf)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, &blkio_policy_throtl,
+	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, &blkcg_policy_throtl,
 			  cft->private, true);
 	return 0;
 }
@@ -979,29 +979,29 @@ static u64 tg_prfill_conf_uint(struct seq_file *sf, void *pdata, int off)
 static int tg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
 			     struct seq_file *sf)
 {
-	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp), tg_prfill_conf_u64,
-			  &blkio_policy_throtl, cft->private, false);
+	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp), tg_prfill_conf_u64,
+			  &blkcg_policy_throtl, cft->private, false);
 	return 0;
 }
 
 static int tg_print_conf_uint(struct cgroup *cgrp, struct cftype *cft,
 			      struct seq_file *sf)
 {
-	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp), tg_prfill_conf_uint,
-			  &blkio_policy_throtl, cft->private, false);
+	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp), tg_prfill_conf_uint,
+			  &blkcg_policy_throtl, cft->private, false);
 	return 0;
 }
 
 static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 		       bool is_u64)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 	struct blkg_conf_ctx ctx;
 	struct throtl_grp *tg;
 	struct throtl_data *td;
 	int ret;
 
-	ret = blkg_conf_prep(blkcg, &blkio_policy_throtl, buf, &ctx);
+	ret = blkg_conf_prep(blkcg, &blkcg_policy_throtl, buf, &ctx);
 	if (ret)
 		return ret;
 
@@ -1086,11 +1086,11 @@ static void throtl_shutdown_wq(struct request_queue *q)
 	cancel_delayed_work_sync(&td->throtl_work);
 }
 
-static struct blkio_policy_type blkio_policy_throtl = {
+static struct blkcg_policy blkcg_policy_throtl = {
 	.ops = {
-		.blkio_init_group_fn = throtl_init_blkio_group,
-		.blkio_exit_group_fn = throtl_exit_blkio_group,
-		.blkio_reset_group_stats_fn = throtl_reset_group_stats,
+		.pd_init_fn		= throtl_pd_init,
+		.pd_exit_fn		= throtl_pd_exit,
+		.pd_reset_stats_fn	= throtl_pd_reset_stats,
 	},
 	.pdata_size = sizeof(struct throtl_grp),
 	.cftypes = throtl_files,
@@ -1101,7 +1101,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	struct throtl_data *td = q->td;
 	struct throtl_grp *tg;
 	bool rw = bio_data_dir(bio), update_disptime = true;
-	struct blkio_cgroup *blkcg;
+	struct blkcg *blkcg;
 	bool throttled = false;
 
 	if (bio->bi_rw & REQ_THROTTLED) {
@@ -1118,7 +1118,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	 * just update the dispatch stats in lockless manner and return.
 	 */
 	rcu_read_lock();
-	blkcg = bio_blkio_cgroup(bio);
+	blkcg = bio_blkcg(bio);
 	tg = throtl_lookup_tg(td, blkcg);
 	if (tg) {
 		if (tg_no_rule_group(tg, rw)) {
@@ -1243,7 +1243,7 @@ int blk_throtl_init(struct request_queue *q)
 	td->queue = q;
 
 	/* activate policy */
-	ret = blkcg_activate_policy(q, &blkio_policy_throtl);
+	ret = blkcg_activate_policy(q, &blkcg_policy_throtl);
 	if (ret)
 		kfree(td);
 	return ret;
@@ -1253,7 +1253,7 @@ void blk_throtl_exit(struct request_queue *q)
 {
 	BUG_ON(!q->td);
 	throtl_shutdown_wq(q);
-	blkcg_deactivate_policy(q, &blkio_policy_throtl);
+	blkcg_deactivate_policy(q, &blkcg_policy_throtl);
 	kfree(q->td);
 }
 
@@ -1263,7 +1263,7 @@ static int __init throtl_init(void)
 	if (!kthrotld_workqueue)
 		panic("Failed to create kthrotld\n");
 
-	return blkio_policy_register(&blkio_policy_throtl);
+	return blkcg_policy_register(&blkcg_policy_throtl);
 }
 
 module_init(throtl_init);
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 901286b..7922182 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -17,7 +17,7 @@
 #include "blk.h"
 #include "blk-cgroup.h"
 
-static struct blkio_policy_type blkio_policy_cfq __maybe_unused;
+static struct blkcg_policy blkcg_policy_cfq __maybe_unused;
 
 /*
  * tunables
@@ -202,7 +202,7 @@ struct cfqg_stats {
 	struct blkg_stat		dequeue;
 	/* total time spent waiting for it to be assigned a timeslice. */
 	struct blkg_stat		group_wait_time;
-	/* time spent idling for this blkio_group */
+	/* time spent idling for this blkcg_gq */
 	struct blkg_stat		idle_time;
 	/* total time with empty current active q with other requests queued */
 	struct blkg_stat		empty_time;
@@ -553,12 +553,12 @@ static inline void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg) { }
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
 
-static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg)
+static inline struct cfq_group *blkg_to_cfqg(struct blkcg_gq *blkg)
 {
-	return blkg_to_pdata(blkg, &blkio_policy_cfq);
+	return blkg_to_pdata(blkg, &blkcg_policy_cfq);
 }
 
-static inline struct blkio_group *cfqg_to_blkg(struct cfq_group *cfqg)
+static inline struct blkcg_gq *cfqg_to_blkg(struct cfq_group *cfqg)
 {
 	return pdata_to_blkg(cfqg);
 }
@@ -637,7 +637,7 @@ static inline void cfqg_stats_update_completion(struct cfq_group *cfqg,
 				io_start_time - start_time);
 }
 
-static void cfqg_stats_reset(struct blkio_group *blkg)
+static void cfq_pd_reset_stats(struct blkcg_gq *blkg)
 {
 	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
 	struct cfqg_stats *stats = &cfqg->stats;
@@ -662,8 +662,8 @@ static void cfqg_stats_reset(struct blkio_group *blkg)
 
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
 
-static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg) { return NULL; }
-static inline struct blkio_group *cfqg_to_blkg(struct cfq_group *cfqg) { return NULL; }
+static inline struct cfq_group *blkg_to_cfqg(struct blkcg_gq *blkg) { return NULL; }
+static inline struct blkcg_gq *cfqg_to_blkg(struct cfq_group *cfqg) { return NULL; }
 static inline void cfqg_get(struct cfq_group *cfqg) { }
 static inline void cfqg_put(struct cfq_group *cfqg) { }
 
@@ -1331,7 +1331,7 @@ static void cfq_init_cfqg_base(struct cfq_group *cfqg)
 }
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
-static void cfq_init_blkio_group(struct blkio_group *blkg)
+static void cfq_pd_init(struct blkcg_gq *blkg)
 {
 	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
 
@@ -1344,16 +1344,16 @@ static void cfq_init_blkio_group(struct blkio_group *blkg)
  * be held.
  */
 static struct cfq_group *cfq_lookup_create_cfqg(struct cfq_data *cfqd,
-						struct blkio_cgroup *blkcg)
+						struct blkcg *blkcg)
 {
 	struct request_queue *q = cfqd->queue;
 	struct cfq_group *cfqg = NULL;
 
-	/* avoid lookup for the common case where there's no blkio cgroup */
-	if (blkcg == &blkio_root_cgroup) {
+	/* avoid lookup for the common case where there's no blkcg */
+	if (blkcg == &blkcg_root) {
 		cfqg = cfqd->root_group;
 	} else {
-		struct blkio_group *blkg;
+		struct blkcg_gq *blkg;
 
 		blkg = blkg_lookup_create(blkcg, q);
 		if (!IS_ERR(blkg))
@@ -1386,8 +1386,8 @@ static u64 cfqg_prfill_weight_device(struct seq_file *sf, void *pdata, int off)
 static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
 				    struct seq_file *sf)
 {
-	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
-			  cfqg_prfill_weight_device, &blkio_policy_cfq, 0,
+	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp),
+			  cfqg_prfill_weight_device, &blkcg_policy_cfq, 0,
 			  false);
 	return 0;
 }
@@ -1395,19 +1395,19 @@ static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
 static int cfq_print_weight(struct cgroup *cgrp, struct cftype *cft,
 			    struct seq_file *sf)
 {
-	seq_printf(sf, "%u\n", cgroup_to_blkio_cgroup(cgrp)->cfq_weight);
+	seq_printf(sf, "%u\n", cgroup_to_blkcg(cgrp)->cfq_weight);
 	return 0;
 }
 
 static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 				  const char *buf)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 	struct blkg_conf_ctx ctx;
 	struct cfq_group *cfqg;
 	int ret;
 
-	ret = blkg_conf_prep(blkcg, &blkio_policy_cfq, buf, &ctx);
+	ret = blkg_conf_prep(blkcg, &blkcg_policy_cfq, buf, &ctx);
 	if (ret)
 		return ret;
 
@@ -1425,8 +1425,8 @@ static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 
 static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	struct blkio_group *blkg;
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
+	struct blkcg_gq *blkg;
 	struct hlist_node *n;
 
 	if (val < CFQ_WEIGHT_MIN || val > CFQ_WEIGHT_MAX)
@@ -1449,9 +1449,9 @@ static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 static int cfqg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 			   struct seq_file *sf)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, &blkio_policy_cfq,
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, &blkcg_policy_cfq,
 			  cft->private, false);
 	return 0;
 }
@@ -1459,9 +1459,9 @@ static int cfqg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 static int cfqg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
 			     struct seq_file *sf)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, &blkio_policy_cfq,
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, &blkcg_policy_cfq,
 			  cft->private, true);
 	return 0;
 }
@@ -1485,10 +1485,10 @@ static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf, void *pdata, int off)
 static int cfqg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
 				     struct seq_file *sf)
 {
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 
 	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_avg_queue_size,
-			  &blkio_policy_cfq, 0, false);
+			  &blkcg_policy_cfq, 0, false);
 	return 0;
 }
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
@@ -1580,7 +1580,7 @@ static struct cftype cfq_blkcg_files[] = {
 };
 #else /* GROUP_IOSCHED */
 static struct cfq_group *cfq_lookup_create_cfqg(struct cfq_data *cfqd,
-						struct blkio_cgroup *blkcg)
+						struct blkcg *blkcg)
 {
 	return cfqd->root_group;
 }
@@ -3135,7 +3135,7 @@ static void check_blkcg_changed(struct cfq_io_cq *cic, struct bio *bio)
 	uint64_t id;
 
 	rcu_read_lock();
-	id = bio_blkio_cgroup(bio)->id;
+	id = bio_blkcg(bio)->id;
 	rcu_read_unlock();
 
 	/*
@@ -3166,14 +3166,14 @@ static struct cfq_queue *
 cfq_find_alloc_queue(struct cfq_data *cfqd, bool is_sync, struct cfq_io_cq *cic,
 		     struct bio *bio, gfp_t gfp_mask)
 {
-	struct blkio_cgroup *blkcg;
+	struct blkcg *blkcg;
 	struct cfq_queue *cfqq, *new_cfqq = NULL;
 	struct cfq_group *cfqg;
 
 retry:
 	rcu_read_lock();
 
-	blkcg = bio_blkio_cgroup(bio);
+	blkcg = bio_blkcg(bio);
 	cfqg = cfq_lookup_create_cfqg(cfqd, blkcg);
 	cfqq = cic_to_cfqq(cic, is_sync);
 
@@ -3944,14 +3944,14 @@ static void cfq_exit_queue(struct elevator_queue *e)
 #ifndef CONFIG_CFQ_GROUP_IOSCHED
 	kfree(cfqd->root_group);
 #endif
-	blkcg_deactivate_policy(q, &blkio_policy_cfq);
+	blkcg_deactivate_policy(q, &blkcg_policy_cfq);
 	kfree(cfqd);
 }
 
 static int cfq_init_queue(struct request_queue *q)
 {
 	struct cfq_data *cfqd;
-	struct blkio_group *blkg __maybe_unused;
+	struct blkcg_gq *blkg __maybe_unused;
 	int i, ret;
 
 	cfqd = kmalloc_node(sizeof(*cfqd), GFP_KERNEL | __GFP_ZERO, q->node);
@@ -3966,7 +3966,7 @@ static int cfq_init_queue(struct request_queue *q)
 
 	/* Init root group and prefer root group over other groups by default */
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
-	ret = blkcg_activate_policy(q, &blkio_policy_cfq);
+	ret = blkcg_activate_policy(q, &blkcg_policy_cfq);
 	if (ret)
 		goto out_free;
 
@@ -4156,10 +4156,10 @@ static struct elevator_type iosched_cfq = {
 };
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
-static struct blkio_policy_type blkio_policy_cfq = {
+static struct blkcg_policy blkcg_policy_cfq = {
 	.ops = {
-		.blkio_init_group_fn =		cfq_init_blkio_group,
-		.blkio_reset_group_stats_fn =	cfqg_stats_reset,
+		.pd_init_fn		= cfq_pd_init,
+		.pd_reset_stats_fn	= cfq_pd_reset_stats,
 	},
 	.pdata_size = sizeof(struct cfq_group),
 	.cftypes = cfq_blkcg_files,
@@ -4185,7 +4185,7 @@ static int __init cfq_init(void)
 		cfq_group_idle = 0;
 #endif
 
-	ret = blkio_policy_register(&blkio_policy_cfq);
+	ret = blkcg_policy_register(&blkcg_policy_cfq);
 	if (ret)
 		return ret;
 
@@ -4202,13 +4202,13 @@ static int __init cfq_init(void)
 err_free_pool:
 	kmem_cache_destroy(cfq_pool);
 err_pol_unreg:
-	blkio_policy_unregister(&blkio_policy_cfq);
+	blkcg_policy_unregister(&blkcg_policy_cfq);
 	return ret;
 }
 
 static void __exit cfq_exit(void)
 {
-	blkio_policy_unregister(&blkio_policy_cfq);
+	blkcg_policy_unregister(&blkcg_policy_cfq);
 	elv_unregister(&iosched_cfq);
 	kmem_cache_destroy(cfq_pool);
 }
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 68720ab..af33fb1 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -31,7 +31,7 @@ struct blk_trace;
 struct request;
 struct sg_io_hdr;
 struct bsg_job;
-struct blkio_group;
+struct blkcg_gq;
 
 #define BLKDEV_MIN_RQ	4
 #define BLKDEV_MAX_RQ	128	/* Default maximum */
@@ -371,7 +371,7 @@ struct request_queue {
 	struct list_head	icq_list;
 #ifdef CONFIG_BLK_CGROUP
 	DECLARE_BITMAP		(blkcg_pols, BLKCG_MAX_POLS);
-	struct blkio_group	*root_blkg;
+	struct blkcg_gq		*root_blkg;
 	struct list_head	blkg_list;
 #endif
 
-- 
1.7.7.3
