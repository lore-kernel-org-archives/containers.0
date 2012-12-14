From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/12] cfq-iosched: implement hierarchy-ready cfq_group charge
	scaling
Date: Fri, 14 Dec 2012 14:41:20 -0800
Message-ID: <1355524885-22719-8-git-send-email-tj@kernel.org>
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

Currently, cfqg charges are scaled directly according to cfqg->weight.
Regardless of the number of active cfqgs or the amount of active
weights, a given weight value always scales charge the same way.  This
works fine as long as all cfqgs are treated equally regardless of
their positions in the hierarchy, which is what cfq currently
implements.  It can't work in hierarchical settings because the
interpretation of a given weight value depends on where the weight is
located in the hierarchy.

This patch reimplements cfqg charge scaling so that it can be used to
support hierarchy properly.  The scheme is fairly simple and
light-weight.

* When a cfqg is added to the service tree, v(disktime)weight is
  calculated.  It walks up the tree to root calculating the fraction
  it has in the hierarchy.  At each level, the fraction can be
  calculated as

    cfqg->weight / parent->level_weight

  By compounding these, the global fraction of vdisktime the cfqg has
  claim to - vfraction - can be determined.

* When the cfqg needs to be charged, the charge is scaled inversely
  proportionally to the vfraction.

The new scaling scheme uses the same CFQ_SERVICE_SHIFT for fixed point
representation as before; however, the smallest scaling factor is now
1 (ie. 1 << CFQ_SERVICE_SHIFT).  This is different from before where 1
was for CFQ_WEIGHT_DEFAULT and higher weight would result in smaller
scaling factor.

While this shifts the global scale of vdisktime a bit, it doesn't
change the relative relationships among cfqgs and the scheduling
result isn't different.

cfq_group_notify_queue_add uses fixed CFQ_IDLE_DELAY when appending
new cfqg to the service tree.  The specific value of CFQ_IDLE_DELAY
didn't have any relevance to vdisktime before and is unlikely to cause
any visible behavior difference now especially as the scale shift
isn't that large.

As the new scheme now makes proper distinction between cfqg->weight
and ->leaf_weight, reverse the weight aliasing for root cfqgs.  For
root, both weights are now mapped to ->leaf_weight instead of the
other way around.

Because we're still using cfqg_flat_parent(), this patch shouldn't
change the scheduling behavior in any noticeable way.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c | 103 +++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 73 insertions(+), 30 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index eb290a0..663a0f0 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -237,6 +237,15 @@ struct cfq_group {
 	unsigned int level_weight;
 
 	/*
+	 * vfraction is the fraction of vdisktime that a cfqg is entitled
+	 * to.  It is in fixed point w/ CFQ_SERVICE_SHIFT and the sum of
+	 * all vfractions on a service tree is approximately 1.  The sum
+	 * may deviate a bit due to rounding errors and fluctuations caused
+	 * by cfqgs entering and leaving the service tree.
+	 */
+	unsigned int vfraction;
+
+	/*
 	 * There are two weights - (internal) weight is the weight of this
 	 * cfqg against the sibling cfqgs.  leaf_weight is the wight of
 	 * this cfqg against the child cfqgs.  For the root cfqg, both
@@ -891,13 +900,27 @@ cfq_prio_to_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 	return cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio);
 }
 
-static inline u64 cfq_scale_slice(unsigned long delta, struct cfq_group *cfqg)
+/**
+ * cfqg_scale_charge - scale disk time charge according to cfqg weight
+ * @charge: disk time being charged
+ * @vfraction: vfraction of the cfqg, fixed point w/ CFQ_SERVICE_SHIFT
+ *
+ * Scale @charge according to @vfraction, which is in range (0, 1].  The
+ * scaling is inversely proportional.
+ *
+ * scaled = charge / vfraction
+ *
+ * The result is also in fixed point w/ CFQ_SERVICE_SHIFT.
+ */
+static inline u64 cfqg_scale_charge(unsigned long charge,
+				    unsigned int vfraction)
 {
-	u64 d = delta << CFQ_SERVICE_SHIFT;
+	u64 c = charge << CFQ_SERVICE_SHIFT;	/* make it fixed point */
 
-	d = d * CFQ_WEIGHT_DEFAULT;
-	do_div(d, cfqg->weight);
-	return d;
+	/* charge / vfraction */
+	c <<= CFQ_SERVICE_SHIFT;
+	do_div(c, vfraction);
+	return c;
 }
 
 static inline u64 max_vdisktime(u64 min_vdisktime, u64 vdisktime)
@@ -1237,7 +1260,9 @@ cfq_update_group_weight(struct cfq_group *cfqg)
 static void
 cfq_group_service_tree_add(struct cfq_rb_root *st, struct cfq_group *cfqg)
 {
+	unsigned int vfr = 1 << CFQ_SERVICE_SHIFT;	/* start with 1 */
 	struct cfq_group *pos = cfqg;
+	struct cfq_group *parent;
 	bool propagate;
 
 	/* add to the service tree */
@@ -1248,22 +1273,33 @@ cfq_group_service_tree_add(struct cfq_rb_root *st, struct cfq_group *cfqg)
 	st->total_weight += cfqg->weight;
 
 	/*
-	 * Activate @cfqg and propagate activation upwards until we meet an
-	 * already activated node or reach root.
+	 * Activate @cfqg and calculate the portion of vfraction @cfqg is
+	 * entitled to.  vfraction is calculated by walking the tree
+	 * towards the root calculating the fraction it has at each level.
+	 * The compounded ratio is how much vfraction @cfqg owns.
+	 *
+	 * Start with activating and calculating vfraction for @cfqg.
 	 */
 	propagate = !pos->nr_active++;
 	pos->level_weight += pos->leaf_weight;
+	vfr = vfr * pos->leaf_weight / pos->level_weight;
 
-	while (propagate) {
-		struct cfq_group *parent = cfqg_flat_parent(pos);
-
-		if (!parent)
-			break;
-
-		propagate = !parent->nr_active++;
-		parent->level_weight += pos->weight;
+	/*
+	 * Walk up the tree.  Both activation and vfraction calculation are
+	 * done in the same loop.  Propagation stops once an already
+	 * activated node is met.  vfraction calculation should always
+	 * continue to the root.
+	 */
+	while ((parent = cfqg_flat_parent(pos))) {
+		if (propagate) {
+			propagate = !parent->nr_active++;
+			parent->level_weight += pos->weight;
+		}
+		vfr = vfr * pos->weight / parent->level_weight;
 		pos = parent;
 	}
+
+	cfqg->vfraction = max_t(unsigned, vfr, 1);
 }
 
 static void
@@ -1309,6 +1345,7 @@ cfq_group_service_tree_del(struct cfq_rb_root *st, struct cfq_group *cfqg)
 
 		/* @pos has 0 nr_active at this point */
 		WARN_ON_ONCE(pos->level_weight);
+		pos->vfraction = 0;
 
 		if (!parent)
 			break;
@@ -1381,6 +1418,7 @@ static void cfq_group_served(struct cfq_data *cfqd, struct cfq_group *cfqg,
 	unsigned int used_sl, charge, unaccounted_sl = 0;
 	int nr_sync = cfqg->nr_cfqq - cfqg_busy_async_queues(cfqd, cfqg)
 			- cfqg->service_tree_idle.count;
+	unsigned int vfr;
 
 	BUG_ON(nr_sync < 0);
 	used_sl = charge = cfq_cfqq_slice_usage(cfqq, &unaccounted_sl);
@@ -1390,10 +1428,15 @@ static void cfq_group_served(struct cfq_data *cfqd, struct cfq_group *cfqg,
 	else if (!cfq_cfqq_sync(cfqq) && !nr_sync)
 		charge = cfqq->allocated_slice;
 
-	/* Can't update vdisktime while group is on service tree */
+	/*
+	 * Can't update vdisktime while on service tree and cfqg->vfraction
+	 * is valid only while on it.  Cache vfr, leave the service tree,
+	 * update vdisktime and go back on.  The re-addition to the tree
+	 * will also update the weights as necessary.
+	 */
+	vfr = cfqg->vfraction;
 	cfq_group_service_tree_del(st, cfqg);
-	cfqg->vdisktime += cfq_scale_slice(charge, cfqg);
-	/* If a new weight was requested, update now, off tree */
+	cfqg->vdisktime += cfqg_scale_charge(charge, vfr);
 	cfq_group_service_tree_add(st, cfqg);
 
 	/* This group is being expired. Save the context */
@@ -1669,44 +1712,44 @@ static int cfqg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
 
 static struct cftype cfq_blkcg_files[] = {
+	/* on root, weight is mapped to leaf_weight */
 	{
 		.name = "weight_device",
-		.read_seq_string = cfqg_print_weight_device,
-		.write_string = cfqg_set_weight_device,
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_seq_string = cfqg_print_leaf_weight_device,
+		.write_string = cfqg_set_leaf_weight_device,
 		.max_write_len = 256,
 	},
 	{
 		.name = "weight",
-		.read_seq_string = cfq_print_weight,
-		.write_u64 = cfq_set_weight,
+		.flags = CFTYPE_ONLY_ON_ROOT,
+		.read_seq_string = cfq_print_leaf_weight,
+		.write_u64 = cfq_set_leaf_weight,
 	},
 
-	/* on root, leaf_weight is mapped to weight */
+	/* no such mapping necessary for !roots */
 	{
-		.name = "leaf_weight_device",
-		.flags = CFTYPE_ONLY_ON_ROOT,
+		.name = "weight_device",
+		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_seq_string = cfqg_print_weight_device,
 		.write_string = cfqg_set_weight_device,
 		.max_write_len = 256,
 	},
 	{
-		.name = "leaf_weight",
-		.flags = CFTYPE_ONLY_ON_ROOT,
+		.name = "weight",
+		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_seq_string = cfq_print_weight,
 		.write_u64 = cfq_set_weight,
 	},
 
-	/* no such mapping necessary for !roots */
 	{
 		.name = "leaf_weight_device",
-		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_seq_string = cfqg_print_leaf_weight_device,
 		.write_string = cfqg_set_leaf_weight_device,
 		.max_write_len = 256,
 	},
 	{
 		.name = "leaf_weight",
-		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_seq_string = cfq_print_leaf_weight,
 		.write_u64 = cfq_set_leaf_weight,
 	},
-- 
1.7.11.7
