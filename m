From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/11] blkcg: remove static policy ID enums
Date: Fri, 13 Apr 2012 13:11:28 -0700
Message-ID: <1334347895-6268-5-git-send-email-tj@kernel.org>
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

Remove BLKIO_POLICY_* enums and let blkio_policy_register() allocate
@pol->plid dynamically on registration.  The maximum number of blkcg
policies which can be registered at the same time is defined by
BLKCG_MAX_POLS constant added to include/linux/blkdev.h.

Note that blkio_policy_register() now may fail.  Policy init functions
updated accordingly and unnecessary ifdefs removed from cfq_init().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c     |   59 +++++++++++++++++++++++++++++++++++------------
 block/blk-cgroup.h     |   15 +++---------
 block/blk-throttle.c   |    4 +--
 block/cfq-iosched.c    |   25 +++++++++++---------
 include/linux/blkdev.h |    7 +++++-
 5 files changed, 69 insertions(+), 41 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index b123152..2d4d7d6 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -31,7 +31,7 @@ static LIST_HEAD(all_q_list);
 struct blkio_cgroup blkio_root_cgroup = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT };
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
-static struct blkio_policy_type *blkio_policy[BLKIO_NR_POLICIES];
+static struct blkio_policy_type *blkio_policy[BLKCG_MAX_POLS];
 
 struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup)
 {
@@ -67,7 +67,7 @@ static void blkg_free(struct blkio_group *blkg)
 	if (!blkg)
 		return;
 
-	for (i = 0; i < BLKIO_NR_POLICIES; i++) {
+	for (i = 0; i < BLKCG_MAX_POLS; i++) {
 		struct blkio_policy_type *pol = blkio_policy[i];
 		struct blkg_policy_data *pd = blkg->pd[i];
 
@@ -107,7 +107,7 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 	blkg->refcnt = 1;
 	cgroup_path(blkcg->css.cgroup, blkg->path, sizeof(blkg->path));
 
-	for (i = 0; i < BLKIO_NR_POLICIES; i++) {
+	for (i = 0; i < BLKCG_MAX_POLS; i++) {
 		struct blkio_policy_type *pol = blkio_policy[i];
 		struct blkg_policy_data *pd;
 
@@ -127,7 +127,7 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
 	}
 
 	/* invoke per-policy init */
-	for (i = 0; i < BLKIO_NR_POLICIES; i++) {
+	for (i = 0; i < BLKCG_MAX_POLS; i++) {
 		struct blkio_policy_type *pol = blkio_policy[i];
 
 		if (pol)
@@ -320,7 +320,7 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	 * anyway.  If you get hit by a race, retry.
 	 */
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
-		for (i = 0; i < BLKIO_NR_POLICIES; i++) {
+		for (i = 0; i < BLKCG_MAX_POLS; i++) {
 			struct blkio_policy_type *pol = blkio_policy[i];
 
 			if (pol && pol->ops.blkio_reset_group_stats_fn)
@@ -729,46 +729,75 @@ struct cgroup_subsys blkio_subsys = {
 };
 EXPORT_SYMBOL_GPL(blkio_subsys);
 
-void blkio_policy_register(struct blkio_policy_type *blkiop)
+/**
+ * blkio_policy_register - register a blkcg policy
+ * @blkiop: blkcg policy to register
+ *
+ * Register @blkiop with blkcg core.  Might sleep and @blkiop may be
+ * modified on successful registration.  Returns 0 on success and -errno on
+ * failure.
+ */
+int blkio_policy_register(struct blkio_policy_type *blkiop)
 {
 	struct request_queue *q;
+	int i, ret;
 
 	mutex_lock(&blkcg_pol_mutex);
 
-	blkcg_bypass_start();
+	/* find an empty slot */
+	ret = -ENOSPC;
+	for (i = 0; i < BLKCG_MAX_POLS; i++)
+		if (!blkio_policy[i])
+			break;
+	if (i >= BLKCG_MAX_POLS)
+		goto out_unlock;
 
-	BUG_ON(blkio_policy[blkiop->plid]);
-	blkio_policy[blkiop->plid] = blkiop;
+	/* register and update blkgs */
+	blkiop->plid = i;
+	blkio_policy[i] = blkiop;
+
+	blkcg_bypass_start();
 	list_for_each_entry(q, &all_q_list, all_q_node)
 		update_root_blkg_pd(q, blkiop);
-
 	blkcg_bypass_end();
 
+	/* everything is in place, add intf files for the new policy */
 	if (blkiop->cftypes)
 		WARN_ON(cgroup_add_cftypes(&blkio_subsys, blkiop->cftypes));
-
+	ret = 0;
+out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(blkio_policy_register);
 
+/**
+ * blkiop_policy_unregister - unregister a blkcg policy
+ * @blkiop: blkcg policy to unregister
+ *
+ * Undo blkio_policy_register(@blkiop).  Might sleep.
+ */
 void blkio_policy_unregister(struct blkio_policy_type *blkiop)
 {
 	struct request_queue *q;
 
 	mutex_lock(&blkcg_pol_mutex);
 
+	if (WARN_ON(blkio_policy[blkiop->plid] != blkiop))
+		goto out_unlock;
+
+	/* kill the intf files first */
 	if (blkiop->cftypes)
 		cgroup_rm_cftypes(&blkio_subsys, blkiop->cftypes);
 
-	blkcg_bypass_start();
-
-	BUG_ON(blkio_policy[blkiop->plid] != blkiop);
+	/* unregister and update blkgs */
 	blkio_policy[blkiop->plid] = NULL;
 
+	blkcg_bypass_start();
 	list_for_each_entry(q, &all_q_list, all_q_node)
 		update_root_blkg_pd(q, blkiop);
 	blkcg_bypass_end();
-
+out_unlock:
 	mutex_unlock(&blkcg_pol_mutex);
 }
 EXPORT_SYMBOL_GPL(blkio_policy_unregister);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 2694973..be80d6e 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -17,13 +17,6 @@
 #include <linux/u64_stats_sync.h>
 #include <linux/seq_file.h>
 
-enum blkio_policy_id {
-	BLKIO_POLICY_PROP = 0,		/* Proportional Bandwidth division */
-	BLKIO_POLICY_THROTL,		/* Throttling */
-
-	BLKIO_NR_POLICIES,
-};
-
 /* Max limits for throttle policy */
 #define THROTL_IOPS_MAX		UINT_MAX
 
@@ -86,7 +79,7 @@ struct blkio_group {
 	/* reference count */
 	int refcnt;
 
-	struct blkg_policy_data *pd[BLKIO_NR_POLICIES];
+	struct blkg_policy_data *pd[BLKCG_MAX_POLS];
 
 	struct rcu_head rcu_head;
 };
@@ -103,7 +96,7 @@ struct blkio_policy_ops {
 
 struct blkio_policy_type {
 	struct blkio_policy_ops ops;
-	enum blkio_policy_id plid;
+	int plid;
 	size_t pdata_size;		/* policy specific private data size */
 	struct cftype *cftypes;		/* cgroup files for the policy */
 };
@@ -113,7 +106,7 @@ extern void blkcg_drain_queue(struct request_queue *q);
 extern void blkcg_exit_queue(struct request_queue *q);
 
 /* Blkio controller policy registration */
-extern void blkio_policy_register(struct blkio_policy_type *);
+extern int blkio_policy_register(struct blkio_policy_type *);
 extern void blkio_policy_unregister(struct blkio_policy_type *);
 extern void blkg_destroy_all(struct request_queue *q, bool destroy_root);
 extern void update_root_blkg_pd(struct request_queue *q,
@@ -329,7 +322,7 @@ struct blkio_policy_type {
 static inline int blkcg_init_queue(struct request_queue *q) { return 0; }
 static inline void blkcg_drain_queue(struct request_queue *q) { }
 static inline void blkcg_exit_queue(struct request_queue *q) { }
-static inline void blkio_policy_register(struct blkio_policy_type *blkiop) { }
+static inline int blkio_policy_register(struct blkio_policy_type *blkiop) { return 0; }
 static inline void blkio_policy_unregister(struct blkio_policy_type *blkiop) { }
 static inline void blkg_destroy_all(struct request_queue *q,
 				    bool destory_root) { }
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 07c17c2..0dc4645 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1089,7 +1089,6 @@ static struct blkio_policy_type blkio_policy_throtl = {
 		.blkio_exit_group_fn = throtl_exit_blkio_group,
 		.blkio_reset_group_stats_fn = throtl_reset_group_stats,
 	},
-	.plid = BLKIO_POLICY_THROTL,
 	.pdata_size = sizeof(struct throtl_grp),
 	.cftypes = throtl_files,
 };
@@ -1271,8 +1270,7 @@ static int __init throtl_init(void)
 	if (!kthrotld_workqueue)
 		panic("Failed to create kthrotld\n");
 
-	blkio_policy_register(&blkio_policy_throtl);
-	return 0;
+	return blkio_policy_register(&blkio_policy_throtl);
 }
 
 module_init(throtl_init);
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index d02f0ae..08db2fc 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -4157,7 +4157,6 @@ static struct blkio_policy_type blkio_policy_cfq = {
 		.blkio_init_group_fn =		cfq_init_blkio_group,
 		.blkio_reset_group_stats_fn =	cfqg_stats_reset,
 	},
-	.plid = BLKIO_POLICY_PROP,
 	.pdata_size = sizeof(struct cfq_group),
 	.cftypes = cfq_blkcg_files,
 };
@@ -4181,27 +4180,31 @@ static int __init cfq_init(void)
 #else
 		cfq_group_idle = 0;
 #endif
+
+	ret = blkio_policy_register(&blkio_policy_cfq);
+	if (ret)
+		return ret;
+
 	cfq_pool = KMEM_CACHE(cfq_queue, 0);
 	if (!cfq_pool)
-		return -ENOMEM;
+		goto err_pol_unreg;
 
 	ret = elv_register(&iosched_cfq);
-	if (ret) {
-		kmem_cache_destroy(cfq_pool);
-		return ret;
-	}
+	if (ret)
+		goto err_free_pool;
 
-#ifdef CONFIG_CFQ_GROUP_IOSCHED
-	blkio_policy_register(&blkio_policy_cfq);
-#endif
 	return 0;
+
+err_free_pool:
+	kmem_cache_destroy(cfq_pool);
+err_pol_unreg:
+	blkio_policy_unregister(&blkio_policy_cfq);
+	return ret;
 }
 
 static void __exit cfq_exit(void)
 {
-#ifdef CONFIG_CFQ_GROUP_IOSCHED
 	blkio_policy_unregister(&blkio_policy_cfq);
-#endif
 	elv_unregister(&iosched_cfq);
 	kmem_cache_destroy(cfq_pool);
 }
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 33f1b29..d2c69f8 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -35,6 +35,12 @@ struct bsg_job;
 #define BLKDEV_MIN_RQ	4
 #define BLKDEV_MAX_RQ	128	/* Default maximum */
 
+/*
+ * Maximum number of blkcg policies allowed to be registered concurrently.
+ * Defined here to simplify include dependency.
+ */
+#define BLKCG_MAX_POLS		2
+
 struct request;
 typedef void (rq_end_io_fn)(struct request *, int);
 
@@ -363,7 +369,6 @@ struct request_queue {
 
 	struct list_head	icq_list;
 #ifdef CONFIG_BLK_CGROUP
-	/* XXX: array size hardcoded to avoid include dependency (temporary) */
 	struct list_head	blkg_list;
 #endif
 
-- 
1.7.7.3
