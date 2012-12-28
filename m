From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/24] cfq-iosched: add leaf_weight
Date: Fri, 28 Dec 2012 12:35:33 -0800
Message-ID: <1356726946-26037-12-git-send-email-tj__33363.7464711957$1356727058$gmane$org@kernel.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356726946-26037-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

cfq blkcg is about to grow proper hierarchy handling, where a child
blkg's weight would nest inside the parent's.  This makes tasks in a
blkg to compete against both tasks in the sibling blkgs and the tasks
of child blkgs.

We're gonna use the existing weight as the group weight which decides
the blkg's weight against its siblings.  This patch introduces a new
weight - leaf_weight - which decides the weight of a blkg against the
child blkgs.

It's named leaf_weight because another way to look at it is that each
internal blkg nodes have a hidden child leaf node which contains all
its tasks and leaf_weight is the weight of the leaf node and handled
the same as the weight of the child blkgs.

This patch only adds leaf_weight fields and exposes it to userland.
The new weight isn't actually used anywhere yet.  Note that
cfq-iosched currently offcially supports only single level hierarchy
and root blkgs compete with the first level blkgs - ie. root weight is
basically being used as leaf_weight.  For root blkgs, the two weights
are kept in sync for backward compatibility.

v2: cfqd->root_group->leaf_weight initialization was missing from
    cfq_init_queue() causing divide by zero when
    !CONFIG_CFQ_GROUP_SCHED.  Fix it.  Reported by Fengguang.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 block/blk-cgroup.c  |   4 +-
 block/blk-cgroup.h  |   1 +
 block/cfq-iosched.c | 134 ++++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 130 insertions(+), 9 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 942f344..10e1df9 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -26,7 +26,8 @@
 
 static DEFINE_MUTEX(blkcg_pol_mutex);
 
-struct blkcg blkcg_root = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT };
+struct blkcg blkcg_root = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT,
+			    .cfq_leaf_weight = 2 * CFQ_WEIGHT_DEFAULT, };
 EXPORT_SYMBOL_GPL(blkcg_root);
 
 static struct blkcg_policy *blkcg_policy[BLKCG_MAX_POLS];
@@ -710,6 +711,7 @@ static struct cgroup_subsys_state *blkcg_css_alloc(struct cgroup *cgroup)
 		return ERR_PTR(-ENOMEM);
 
 	blkcg->cfq_weight = CFQ_WEIGHT_DEFAULT;
+	blkcg->cfq_leaf_weight = CFQ_WEIGHT_DEFAULT;
 	blkcg->id = atomic64_inc_return(&id_seq); /* root is 0, start from 1 */
 done:
 	spin_lock_init(&blkcg->lock);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index b26ed58..2446225 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -54,6 +54,7 @@ struct blkcg {
 
 	/* TODO: per-policy storage in blkcg */
 	unsigned int			cfq_weight;	/* belongs to cfq */
+	unsigned int			cfq_leaf_weight;
 };
 
 struct blkg_stat {
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index bc076f4..175218d6 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -223,10 +223,21 @@ struct cfq_group {
 
 	/* group service_tree key */
 	u64 vdisktime;
+
+	/*
+	 * There are two weights - (internal) weight is the weight of this
+	 * cfqg against the sibling cfqgs.  leaf_weight is the wight of
+	 * this cfqg against the child cfqgs.  For the root cfqg, both
+	 * weights are kept in sync for backward compatibility.
+	 */
 	unsigned int weight;
 	unsigned int new_weight;
 	unsigned int dev_weight;
 
+	unsigned int leaf_weight;
+	unsigned int new_leaf_weight;
+	unsigned int dev_leaf_weight;
+
 	/* number of cfqq currently on this group */
 	int nr_cfqq;
 
@@ -1182,10 +1193,16 @@ static void
 cfq_update_group_weight(struct cfq_group *cfqg)
 {
 	BUG_ON(!RB_EMPTY_NODE(&cfqg->rb_node));
+
 	if (cfqg->new_weight) {
 		cfqg->weight = cfqg->new_weight;
 		cfqg->new_weight = 0;
 	}
+
+	if (cfqg->new_leaf_weight) {
+		cfqg->leaf_weight = cfqg->new_leaf_weight;
+		cfqg->new_leaf_weight = 0;
+	}
 }
 
 static void
@@ -1348,6 +1365,7 @@ static void cfq_pd_init(struct blkcg_gq *blkg)
 
 	cfq_init_cfqg_base(cfqg);
 	cfqg->weight = blkg->blkcg->cfq_weight;
+	cfqg->leaf_weight = blkg->blkcg->cfq_leaf_weight;
 }
 
 /*
@@ -1404,6 +1422,26 @@ static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
+static u64 cfqg_prfill_leaf_weight_device(struct seq_file *sf,
+					  struct blkg_policy_data *pd, int off)
+{
+	struct cfq_group *cfqg = pd_to_cfqg(pd);
+
+	if (!cfqg->dev_leaf_weight)
+		return 0;
+	return __blkg_prfill_u64(sf, pd, cfqg->dev_leaf_weight);
+}
+
+static int cfqg_print_leaf_weight_device(struct cgroup *cgrp,
+					 struct cftype *cft,
+					 struct seq_file *sf)
+{
+	blkcg_print_blkgs(sf, cgroup_to_blkcg(cgrp),
+			  cfqg_prfill_leaf_weight_device, &blkcg_policy_cfq, 0,
+			  false);
+	return 0;
+}
+
 static int cfq_print_weight(struct cgroup *cgrp, struct cftype *cft,
 			    struct seq_file *sf)
 {
@@ -1411,8 +1449,16 @@ static int cfq_print_weight(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
-static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
-				  const char *buf)
+static int cfq_print_leaf_weight(struct cgroup *cgrp, struct cftype *cft,
+				 struct seq_file *sf)
+{
+	seq_printf(sf, "%u\n",
+		   cgroup_to_blkcg(cgrp)->cfq_leaf_weight);
+	return 0;
+}
+
+static int __cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				    const char *buf, bool is_leaf_weight)
 {
 	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 	struct blkg_conf_ctx ctx;
@@ -1426,8 +1472,13 @@ static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 	ret = -EINVAL;
 	cfqg = blkg_to_cfqg(ctx.blkg);
 	if (!ctx.v || (ctx.v >= CFQ_WEIGHT_MIN && ctx.v <= CFQ_WEIGHT_MAX)) {
-		cfqg->dev_weight = ctx.v;
-		cfqg->new_weight = cfqg->dev_weight ?: blkcg->cfq_weight;
+		if (!is_leaf_weight) {
+			cfqg->dev_weight = ctx.v;
+			cfqg->new_weight = ctx.v ?: blkcg->cfq_weight;
+		} else {
+			cfqg->dev_leaf_weight = ctx.v;
+			cfqg->new_leaf_weight = ctx.v ?: blkcg->cfq_leaf_weight;
+		}
 		ret = 0;
 	}
 
@@ -1435,7 +1486,20 @@ static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 	return ret;
 }
 
-static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
+static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				  const char *buf)
+{
+	return __cfqg_set_weight_device(cgrp, cft, buf, false);
+}
+
+static int cfqg_set_leaf_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				       const char *buf)
+{
+	return __cfqg_set_weight_device(cgrp, cft, buf, true);
+}
+
+static int __cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val,
+			    bool is_leaf_weight)
 {
 	struct blkcg *blkcg = cgroup_to_blkcg(cgrp);
 	struct blkcg_gq *blkg;
@@ -1445,19 +1509,41 @@ static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 		return -EINVAL;
 
 	spin_lock_irq(&blkcg->lock);
-	blkcg->cfq_weight = (unsigned int)val;
+
+	if (!is_leaf_weight)
+		blkcg->cfq_weight = val;
+	else
+		blkcg->cfq_leaf_weight = val;
 
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
 		struct cfq_group *cfqg = blkg_to_cfqg(blkg);
 
-		if (cfqg && !cfqg->dev_weight)
-			cfqg->new_weight = blkcg->cfq_weight;
+		if (!cfqg)
+			continue;
+
+		if (!is_leaf_weight) {
+			if (!cfqg->dev_weight)
+				cfqg->new_weight = blkcg->cfq_weight;
+		} else {
+			if (!cfqg->dev_leaf_weight)
+				cfqg->new_leaf_weight = blkcg->cfq_leaf_weight;
+		}
 	}
 
 	spin_unlock_irq(&blkcg->lock);
 	return 0;
 }
 
+static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	return __cfq_set_weight(cgrp, cft, val, false);
+}
+
+static int cfq_set_leaf_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
+{
+	return __cfq_set_weight(cgrp, cft, val, true);
+}
+
 static int cfqg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 			   struct seq_file *sf)
 {
@@ -1518,6 +1604,37 @@ static struct cftype cfq_blkcg_files[] = {
 		.read_seq_string = cfq_print_weight,
 		.write_u64 = cfq_set_weight,
 	},
+
+	/* on root, leaf_weight is mapped to weight */
+	{
+		.name = "leaf_weight_device",
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_seq_string = cfqg_print_weight_device,
+		.write_string = cfqg_set_weight_device,
+		.max_write_len = 256,
+	},
+	{
+		.name = "leaf_weight",
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_seq_string = cfq_print_weight,
+		.write_u64 = cfq_set_weight,
+	},
+
+	/* no such mapping necessary for !roots */
+	{
+		.name = "leaf_weight_device",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.read_seq_string = cfqg_print_leaf_weight_device,
+		.write_string = cfqg_set_leaf_weight_device,
+		.max_write_len = 256,
+	},
+	{
+		.name = "leaf_weight",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.read_seq_string = cfq_print_leaf_weight,
+		.write_u64 = cfq_set_leaf_weight,
+	},
+
 	{
 		.name = "time",
 		.private = offsetof(struct cfq_group, stats.time),
@@ -3992,6 +4109,7 @@ static int cfq_init_queue(struct request_queue *q)
 	cfq_init_cfqg_base(cfqd->root_group);
 #endif
 	cfqd->root_group->weight = 2 * CFQ_WEIGHT_DEFAULT;
+	cfqd->root_group->leaf_weight = 2 * CFQ_WEIGHT_DEFAULT;
 
 	/*
 	 * Not strictly needed (since RB_ROOT just clears the node and we
-- 
1.8.0.2
