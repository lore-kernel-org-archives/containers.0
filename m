From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 18/21] blkcg: move blkio_group_conf->weight to cfq
Date: Wed, 28 Mar 2012 15:51:28 -0700
Message-ID: <1332975091-10950-19-git-send-email-tj@kernel.org>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332975091-10950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

blkio_group_conf->weight is owned by cfq and has no reason to be
defined in blkcg core.  Replace it with cfq_group->dev_weight and let
conf setting functions directly set it.  If dev_weight is zero, the
cfqg doesn't have device specific weight configured.

Also, rename BLKIO_WEIGHT_* constants to CFQ_WEIGHT_* and rename
blkio_cgroup->weight to blkio_cgroup->cfq_weight.  We eventually want
per-policy storage in blkio_cgroup but just mark the ownership of the
field for now.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c  |    4 +-
 block/blk-cgroup.h  |   14 +++++----
 block/cfq-iosched.c |   77 +++++++++++++++++++++++---------------------------
 3 files changed, 45 insertions(+), 50 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 0b4b765..7688aef 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -30,7 +30,7 @@ static LIST_HEAD(blkio_list);
 static DEFINE_MUTEX(all_q_mutex);
 static LIST_HEAD(all_q_list);
 
-struct blkio_cgroup blkio_root_cgroup = { .weight = 2*BLKIO_WEIGHT_DEFAULT };
+struct blkio_cgroup blkio_root_cgroup = { .cfq_weight = 2 * CFQ_WEIGHT_DEFAULT };
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
 static struct blkio_policy_type *blkio_policy[BLKIO_NR_POLICIES];
@@ -611,7 +611,7 @@ static struct cgroup_subsys_state *blkiocg_create(struct cgroup *cgroup)
 	if (!blkcg)
 		return ERR_PTR(-ENOMEM);
 
-	blkcg->weight = BLKIO_WEIGHT_DEFAULT;
+	blkcg->cfq_weight = CFQ_WEIGHT_DEFAULT;
 	blkcg->id = atomic64_inc_return(&id_seq); /* root is 0, start from 1 */
 done:
 	spin_lock_init(&blkcg->lock);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index e368dd00..386db29 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -29,6 +29,11 @@ enum blkio_policy_id {
 
 #ifdef CONFIG_BLK_CGROUP
 
+/* CFQ specific, out here for blkcg->cfq_weight */
+#define CFQ_WEIGHT_MIN		10
+#define CFQ_WEIGHT_MAX		1000
+#define CFQ_WEIGHT_DEFAULT	500
+
 /* cft->private [un]packing for stat printing */
 #define BLKCG_STAT_PRIV(pol, off)	(((unsigned)(pol) << 16) | (off))
 #define BLKCG_STAT_POL(prv)		((unsigned)(prv) >> 16)
@@ -46,12 +51,14 @@ enum blkg_rwstat_type {
 
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
-	unsigned int weight;
 	spinlock_t lock;
 	struct hlist_head blkg_list;
 
 	/* for policies to test whether associated blkcg has changed */
 	uint64_t id;
+
+	/* TODO: per-policy storage in blkio_cgroup */
+	unsigned int cfq_weight;	/* belongs to cfq */
 };
 
 struct blkg_stat {
@@ -65,7 +72,6 @@ struct blkg_rwstat {
 };
 
 struct blkio_group_conf {
-	unsigned int weight;
 	u64 iops[2];
 	u64 bps[2];
 };
@@ -355,10 +361,6 @@ static inline void blkg_put(struct blkio_group *blkg) { }
 
 #endif
 
-#define BLKIO_WEIGHT_MIN	10
-#define BLKIO_WEIGHT_MAX	1000
-#define BLKIO_WEIGHT_DEFAULT	500
-
 #ifdef CONFIG_BLK_CGROUP
 extern struct blkio_cgroup blkio_root_cgroup;
 extern struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index a1f37df..adab10d 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -224,7 +224,7 @@ struct cfq_group {
 	u64 vdisktime;
 	unsigned int weight;
 	unsigned int new_weight;
-	bool needs_update;
+	unsigned int dev_weight;
 
 	/* number of cfqq currently on this group */
 	int nr_cfqq;
@@ -838,7 +838,7 @@ static inline u64 cfq_scale_slice(unsigned long delta, struct cfq_group *cfqg)
 {
 	u64 d = delta << CFQ_SERVICE_SHIFT;
 
-	d = d * BLKIO_WEIGHT_DEFAULT;
+	d = d * CFQ_WEIGHT_DEFAULT;
 	do_div(d, cfqg->weight);
 	return d;
 }
@@ -1165,9 +1165,9 @@ static void
 cfq_update_group_weight(struct cfq_group *cfqg)
 {
 	BUG_ON(!RB_EMPTY_NODE(&cfqg->rb_node));
-	if (cfqg->needs_update) {
+	if (cfqg->new_weight) {
 		cfqg->weight = cfqg->new_weight;
-		cfqg->needs_update = false;
+		cfqg->new_weight = 0;
 	}
 }
 
@@ -1325,21 +1325,12 @@ static void cfq_init_cfqg_base(struct cfq_group *cfqg)
 }
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
-static void cfq_update_blkio_group_weight(struct blkio_group *blkg,
-					  unsigned int weight)
-{
-	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
-
-	cfqg->new_weight = weight;
-	cfqg->needs_update = true;
-}
-
 static void cfq_init_blkio_group(struct blkio_group *blkg)
 {
 	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
 
 	cfq_init_cfqg_base(cfqg);
-	cfqg->weight = blkg->blkcg->weight;
+	cfqg->weight = blkg->blkcg->cfq_weight;
 }
 
 /*
@@ -1377,36 +1368,38 @@ static void cfq_link_cfqq_cfqg(struct cfq_queue *cfqq, struct cfq_group *cfqg)
 	cfqg_get(cfqg);
 }
 
-static u64 blkg_prfill_weight_device(struct seq_file *sf,
+static u64 cfqg_prfill_weight_device(struct seq_file *sf,
 				     struct blkg_policy_data *pd, int off)
 {
-	if (!pd->conf.weight)
+	struct cfq_group *cfqg = (void *)pd->pdata;
+
+	if (!cfqg->dev_weight)
 		return 0;
-	return __blkg_prfill_u64(sf, pd, pd->conf.weight);
+	return __blkg_prfill_u64(sf, pd, cfqg->dev_weight);
 }
 
-static int blkcg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
-				     struct seq_file *sf)
+static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				    struct seq_file *sf)
 {
 	blkcg_print_blkgs(sf, cgroup_to_blkio_cgroup(cgrp),
-			  blkg_prfill_weight_device, BLKIO_POLICY_PROP, 0,
+			  cfqg_prfill_weight_device, BLKIO_POLICY_PROP, 0,
 			  false);
 	return 0;
 }
 
-static int blkcg_print_weight(struct cgroup *cgrp, struct cftype *cft,
-			      struct seq_file *sf)
+static int cfq_print_weight(struct cgroup *cgrp, struct cftype *cft,
+			    struct seq_file *sf)
 {
-	seq_printf(sf, "%u\n", cgroup_to_blkio_cgroup(cgrp)->weight);
+	seq_printf(sf, "%u\n", cgroup_to_blkio_cgroup(cgrp)->cfq_weight);
 	return 0;
 }
 
-static int blkcg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
-				   const char *buf)
+static int cfqg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
+				  const char *buf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-	struct blkg_policy_data *pd;
 	struct blkg_conf_ctx ctx;
+	struct cfq_group *cfqg;
 	int ret;
 
 	ret = blkg_conf_prep(blkcg, buf, &ctx);
@@ -1414,11 +1407,11 @@ static int blkcg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 		return ret;
 
 	ret = -EINVAL;
-	pd = ctx.blkg->pd[BLKIO_POLICY_PROP];
-	if (pd && (!ctx.v || (ctx.v >= BLKIO_WEIGHT_MIN &&
-			      ctx.v <= BLKIO_WEIGHT_MAX))) {
-		pd->conf.weight = ctx.v;
-		cfq_update_blkio_group_weight(ctx.blkg, ctx.v ?: blkcg->weight);
+	cfqg = blkg_to_cfqg(ctx.blkg);
+	if (cfqg && (!ctx.v || (ctx.v >= CFQ_WEIGHT_MIN &&
+				ctx.v <= CFQ_WEIGHT_MAX))) {
+		cfqg->dev_weight = ctx.v;
+		cfqg->new_weight = cfqg->dev_weight ?: blkcg->cfq_weight;
 		ret = 0;
 	}
 
@@ -1426,23 +1419,23 @@ static int blkcg_set_weight_device(struct cgroup *cgrp, struct cftype *cft,
 	return ret;
 }
 
-static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
+static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 	struct blkio_group *blkg;
 	struct hlist_node *n;
 
-	if (val < BLKIO_WEIGHT_MIN || val > BLKIO_WEIGHT_MAX)
+	if (val < CFQ_WEIGHT_MIN || val > CFQ_WEIGHT_MAX)
 		return -EINVAL;
 
 	spin_lock_irq(&blkcg->lock);
-	blkcg->weight = (unsigned int)val;
+	blkcg->cfq_weight = (unsigned int)val;
 
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
-		struct blkg_policy_data *pd = blkg->pd[BLKIO_POLICY_PROP];
+		struct cfq_group *cfqg = blkg_to_cfqg(blkg);
 
-		if (pd && !pd->conf.weight)
-			cfq_update_blkio_group_weight(blkg, blkcg->weight);
+		if (cfqg && !cfqg->dev_weight)
+			cfqg->new_weight = blkcg->cfq_weight;
 	}
 
 	spin_unlock_irq(&blkcg->lock);
@@ -1480,14 +1473,14 @@ static int cfqg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
 static struct cftype cfq_blkcg_files[] = {
 	{
 		.name = "weight_device",
-		.read_seq_string = blkcg_print_weight_device,
-		.write_string = blkcg_set_weight_device,
+		.read_seq_string = cfqg_print_weight_device,
+		.write_string = cfqg_set_weight_device,
 		.max_write_len = 256,
 	},
 	{
 		.name = "weight",
-		.read_seq_string = blkcg_print_weight,
-		.write_u64 = blkcg_set_weight,
+		.read_seq_string = cfq_print_weight,
+		.write_u64 = cfq_set_weight,
 	},
 	{
 		.name = "time",
@@ -3983,7 +3976,7 @@ static int cfq_init_queue(struct request_queue *q)
 		return -ENOMEM;
 	}
 
-	cfqd->root_group->weight = 2*BLKIO_WEIGHT_DEFAULT;
+	cfqd->root_group->weight = 2 * CFQ_WEIGHT_DEFAULT;
 
 	/*
 	 * Not strictly needed (since RB_ROOT just clears the node and we
-- 
1.7.7.3
