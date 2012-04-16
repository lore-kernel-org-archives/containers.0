From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/6] blkcg: embed struct blkg_policy_data in policy specific
	data
Date: Mon, 16 Apr 2012 13:57:26 -0700
Message-ID: <1334609847-12747-6-git-send-email-tj__43848.0499586605$1334609895$gmane$org@kernel.org>
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

Currently blkg_policy_data carries policy specific data as char flex
array instead of being embedded in policy specific data.  This was
forced by oddities around blkg allocation which are all gone now.

This patch makes blkg_policy_data embedded in policy specific data -
throtl_grp and cfq_group so that it's more conventional and consistent
with how io_cq is handled.

* blkcg_policy->pdata_size is renamed to ->pd_size.

* Functions which used to take void *pdata now takes struct
  blkg_policy_data *pd.

* blkg_to_pdata/pdata_to_blkg() updated to blkg_to_pd/pd_to_blkg().

* Dummy struct blkg_policy_data definition added.  Dummy
  pdata_to_blkg() definition was unused and inconsistent with the
  non-dummy version - correct dummy pd_to_blkg() added.

* throtl and cfq updated accordingly.

* As dummy blkg_to_pd/pd_to_blkg() are provided,
  blkg_to_cfqg/cfqg_to_blkg() don't need to be ifdef'd.  Moved outside
  ifdef block.

This patch doesn't introduce any functional change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c   |   52 +++++++++++++++++++++---------------------
 block/blk-cgroup.h   |   60 ++++++++++++++++++++++++++++---------------------
 block/blk-throttle.c |   37 ++++++++++++++++++++----------
 block/cfq-iosched.c  |   46 ++++++++++++++++++++++---------------
 4 files changed, 112 insertions(+), 83 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 9975703..3d49552 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -58,11 +58,6 @@ static bool blkcg_policy_enabled(struct request_queue *q,
 	return pol && test_bit(pol->plid, q->blkcg_pols);
 }
 
-static size_t blkg_pd_size(const struct blkcg_policy *pol)
-{
-	return sizeof(struct blkg_policy_data) + pol->pdata_size;
-}
-
 /**
  * blkg_free - free a blkg
  * @blkg: blkg to free
@@ -122,7 +117,7 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q)
 			continue;
 
 		/* alloc per-policy data and attach it to blkg */
-		pd = kzalloc_node(blkg_pd_size(pol), GFP_ATOMIC, q->node);
+		pd = kzalloc_node(pol->pd_size, GFP_ATOMIC, q->node);
 		if (!pd) {
 			blkg_free(blkg);
 			return NULL;
@@ -346,7 +341,8 @@ static const char *blkg_dev_name(struct blkcg_gq *blkg)
  * cftype->read_seq_string method.
  */
 void blkcg_print_blkgs(struct seq_file *sf, struct blkcg *blkcg,
-		       u64 (*prfill)(struct seq_file *, void *, int),
+		       u64 (*prfill)(struct seq_file *,
+				     struct blkg_policy_data *, int),
 		       const struct blkcg_policy *pol, int data,
 		       bool show_total)
 {
@@ -357,7 +353,7 @@ void blkcg_print_blkgs(struct seq_file *sf, struct blkcg *blkcg,
 	spin_lock_irq(&blkcg->lock);
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node)
 		if (blkcg_policy_enabled(blkg->q, pol))
-			total += prfill(sf, blkg->pd[pol->plid]->pdata, data);
+			total += prfill(sf, blkg->pd[pol->plid], data);
 	spin_unlock_irq(&blkcg->lock);
 
 	if (show_total)
@@ -368,14 +364,14 @@ EXPORT_SYMBOL_GPL(blkcg_print_blkgs);
 /**
  * __blkg_prfill_u64 - prfill helper for a single u64 value
  * @sf: seq_file to print to
- * @pdata: policy private data of interest
+ * @pd: policy private data of interest
  * @v: value to print
  *
- * Print @v to @sf for the device assocaited with @pdata.
+ * Print @v to @sf for the device assocaited with @pd.
  */
-u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v)
+u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd, u64 v)
 {
-	const char *dname = blkg_dev_name(pdata_to_blkg(pdata));
+	const char *dname = blkg_dev_name(pd->blkg);
 
 	if (!dname)
 		return 0;
@@ -388,12 +384,12 @@ EXPORT_SYMBOL_GPL(__blkg_prfill_u64);
 /**
  * __blkg_prfill_rwstat - prfill helper for a blkg_rwstat
  * @sf: seq_file to print to
- * @pdata: policy private data of interest
+ * @pd: policy private data of interest
  * @rwstat: rwstat to print
  *
- * Print @rwstat to @sf for the device assocaited with @pdata.
+ * Print @rwstat to @sf for the device assocaited with @pd.
  */
-u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
+u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 			 const struct blkg_rwstat *rwstat)
 {
 	static const char *rwstr[] = {
@@ -402,7 +398,7 @@ u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 		[BLKG_RWSTAT_SYNC]	= "Sync",
 		[BLKG_RWSTAT_ASYNC]	= "Async",
 	};
-	const char *dname = blkg_dev_name(pdata_to_blkg(pdata));
+	const char *dname = blkg_dev_name(pd->blkg);
 	u64 v;
 	int i;
 
@@ -421,30 +417,31 @@ u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 /**
  * blkg_prfill_stat - prfill callback for blkg_stat
  * @sf: seq_file to print to
- * @pdata: policy private data of interest
- * @off: offset to the blkg_stat in @pdata
+ * @pd: policy private data of interest
+ * @off: offset to the blkg_stat in @pd
  *
  * prfill callback for printing a blkg_stat.
  */
-u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off)
+u64 blkg_prfill_stat(struct seq_file *sf, struct blkg_policy_data *pd, int off)
 {
-	return __blkg_prfill_u64(sf, pdata, blkg_stat_read(pdata + off));
+	return __blkg_prfill_u64(sf, pd, blkg_stat_read((void *)pd + off));
 }
 EXPORT_SYMBOL_GPL(blkg_prfill_stat);
 
 /**
  * blkg_prfill_rwstat - prfill callback for blkg_rwstat
  * @sf: seq_file to print to
- * @pdata: policy private data of interest
- * @off: offset to the blkg_rwstat in @pdata
+ * @pd: policy private data of interest
+ * @off: offset to the blkg_rwstat in @pd
  *
  * prfill callback for printing a blkg_rwstat.
  */
-u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off)
+u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+		       int off)
 {
-	struct blkg_rwstat rwstat = blkg_rwstat_read(pdata + off);
+	struct blkg_rwstat rwstat = blkg_rwstat_read((void *)pd + off);
 
-	return __blkg_prfill_rwstat(sf, pdata, &rwstat);
+	return __blkg_prfill_rwstat(sf, pd, &rwstat);
 }
 EXPORT_SYMBOL_GPL(blkg_prfill_rwstat);
 
@@ -733,7 +730,7 @@ int blkcg_activate_policy(struct request_queue *q,
 
 	/* allocate policy_data for all existing blkgs */
 	while (cnt--) {
-		pd = kzalloc_node(blkg_pd_size(pol), GFP_KERNEL, q->node);
+		pd = kzalloc_node(pol->pd_size, GFP_KERNEL, q->node);
 		if (!pd) {
 			ret = -ENOMEM;
 			goto out_free;
@@ -832,6 +829,9 @@ int blkcg_policy_register(struct blkcg_policy *pol)
 {
 	int i, ret;
 
+	if (WARN_ON(pol->pd_size < sizeof(struct blkg_policy_data)))
+		return -EINVAL;
+
 	mutex_lock(&blkcg_pol_mutex);
 
 	/* find an empty slot */
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index a443b84..18b021e 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -59,16 +59,25 @@ struct blkg_rwstat {
 	uint64_t			cnt[BLKG_RWSTAT_NR];
 };
 
-/* per-blkg per-policy data */
+/*
+ * A blkcg_gq (blkg) is association between a block cgroup (blkcg) and a
+ * request_queue (q).  This is used by blkcg policies which need to track
+ * information per blkcg - q pair.
+ *
+ * There can be multiple active blkcg policies and each has its private
+ * data on each blkg, the size of which is determined by
+ * blkcg_policy->pd_size.  blkcg core allocates and frees such areas
+ * together with blkg and invokes pd_init/exit_fn() methods.
+ *
+ * Such private data must embed struct blkg_policy_data (pd) at the
+ * beginning and pd_size can't be smaller than pd.
+ */
 struct blkg_policy_data {
 	/* the blkg this per-policy data belongs to */
 	struct blkcg_gq			*blkg;
 
 	/* used during policy activation */
 	struct list_head		alloc_node;
-
-	/* pol->pdata_size bytes of private data used by policy impl */
-	char				pdata[] __aligned(__alignof__(unsigned long long));
 };
 
 /* association between a blk cgroup and a request queue */
@@ -100,7 +109,7 @@ struct blkcg_policy {
 	struct blkcg_policy_ops		ops;
 	int				plid;
 	/* policy specific private data size */
-	size_t				pdata_size;
+	size_t				pd_size;
 	/* cgroup files for the policy */
 	struct cftype			*cftypes;
 };
@@ -125,14 +134,16 @@ void blkcg_deactivate_policy(struct request_queue *q,
 			     const struct blkcg_policy *pol);
 
 void blkcg_print_blkgs(struct seq_file *sf, struct blkcg *blkcg,
-		       u64 (*prfill)(struct seq_file *, void *, int),
+		       u64 (*prfill)(struct seq_file *,
+				     struct blkg_policy_data *, int),
 		       const struct blkcg_policy *pol, int data,
 		       bool show_total);
-u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v);
-u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
+u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd, u64 v);
+u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 			 const struct blkg_rwstat *rwstat);
-u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off);
-u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off);
+u64 blkg_prfill_stat(struct seq_file *sf, struct blkg_policy_data *pd, int off);
+u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+		       int off);
 
 struct blkg_conf_ctx {
 	struct gendisk			*disk;
@@ -152,26 +163,21 @@ void blkg_conf_finish(struct blkg_conf_ctx *ctx);
  *
  * Return pointer to private data associated with the @blkg-@pol pair.
  */
-static inline void *blkg_to_pdata(struct blkcg_gq *blkg,
-				  struct blkcg_policy *pol)
+static inline struct blkg_policy_data *blkg_to_pd(struct blkcg_gq *blkg,
+						  struct blkcg_policy *pol)
 {
-	return blkg ? blkg->pd[pol->plid]->pdata : NULL;
+	return blkg ? blkg->pd[pol->plid] : NULL;
 }
 
 /**
  * pdata_to_blkg - get blkg associated with policy private data
- * @pdata: policy private data of interest
+ * @pd: policy private data of interest
  *
- * @pdata is policy private data.  Determine the blkg it's associated with.
+ * @pd is policy private data.  Determine the blkg it's associated with.
  */
-static inline struct blkcg_gq *pdata_to_blkg(void *pdata)
+static inline struct blkcg_gq *pd_to_blkg(struct blkg_policy_data *pd)
 {
-	if (pdata) {
-		struct blkg_policy_data *pd =
-			container_of(pdata, struct blkg_policy_data, pdata);
-		return pd->blkg;
-	}
-	return NULL;
+	return pd ? pd->blkg : NULL;
 }
 
 /**
@@ -342,6 +348,9 @@ static inline void blkg_rwstat_reset(struct blkg_rwstat *rwstat)
 
 struct cgroup;
 
+struct blkg_policy_data {
+};
+
 struct blkcg_gq {
 };
 
@@ -361,10 +370,9 @@ static inline int blkcg_activate_policy(struct request_queue *q,
 static inline void blkcg_deactivate_policy(struct request_queue *q,
 					   const struct blkcg_policy *pol) { }
 
-static inline void *blkg_to_pdata(struct blkcg_gq *blkg,
-				  struct blkcg_policy *pol) { return NULL; }
-static inline struct blkcg_gq *pdata_to_blkg(void *pdata,
-				  struct blkcg_policy *pol) { return NULL; }
+static inline struct blkg_policy_data *blkg_to_pd(struct blkcg_gq *blkg,
+						  struct blkcg_policy *pol) { return NULL; }
+static inline struct blkcg_gq *pd_to_blkg(struct blkg_policy_data *pd) { return NULL; }
 static inline char *blkg_path(struct blkcg_gq *blkg) { return NULL; }
 static inline void blkg_get(struct blkcg_gq *blkg) { }
 static inline void blkg_put(struct blkcg_gq *blkg) { }
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 00c7eff..6a0a17a 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -49,6 +49,9 @@ struct tg_stats_cpu {
 };
 
 struct throtl_grp {
+	/* must be the first member */
+	struct blkg_policy_data pd;
+
 	/* active throtl group service_tree member */
 	struct rb_node rb_node;
 
@@ -120,14 +123,19 @@ static LIST_HEAD(tg_stats_alloc_list);
 static void tg_stats_alloc_fn(struct work_struct *);
 static DECLARE_DELAYED_WORK(tg_stats_alloc_work, tg_stats_alloc_fn);
 
+static inline struct throtl_grp *pd_to_tg(struct blkg_policy_data *pd)
+{
+	return pd ? container_of(pd, struct throtl_grp, pd) : NULL;
+}
+
 static inline struct throtl_grp *blkg_to_tg(struct blkcg_gq *blkg)
 {
-	return blkg_to_pdata(blkg, &blkcg_policy_throtl);
+	return pd_to_tg(blkg_to_pd(blkg, &blkcg_policy_throtl));
 }
 
 static inline struct blkcg_gq *tg_to_blkg(struct throtl_grp *tg)
 {
-	return pdata_to_blkg(tg);
+	return pd_to_blkg(&tg->pd);
 }
 
 static inline struct throtl_grp *td_root_tg(struct throtl_data *td)
@@ -931,9 +939,10 @@ throtl_schedule_delayed_work(struct throtl_data *td, unsigned long delay)
 	}
 }
 
-static u64 tg_prfill_cpu_rwstat(struct seq_file *sf, void *pdata, int off)
+static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
+				struct blkg_policy_data *pd, int off)
 {
-	struct throtl_grp *tg = pdata;
+	struct throtl_grp *tg = pd_to_tg(pd);
 	struct blkg_rwstat rwstat = { }, tmp;
 	int i, cpu;
 
@@ -945,7 +954,7 @@ static u64 tg_prfill_cpu_rwstat(struct seq_file *sf, void *pdata, int off)
 			rwstat.cnt[i] += tmp.cnt[i];
 	}
 
-	return __blkg_prfill_rwstat(sf, pdata, &rwstat);
+	return __blkg_prfill_rwstat(sf, pd, &rwstat);
 }
 
 static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
@@ -958,22 +967,26 @@ static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
-static u64 tg_prfill_conf_u64(struct seq_file *sf, void *pdata, int off)
+static u64 tg_prfill_conf_u64(struct seq_file *sf, struct blkg_policy_data *pd,
+			      int off)
 {
-	u64 v = *(u64 *)(pdata + off);
+	struct throtl_grp *tg = pd_to_tg(pd);
+	u64 v = *(u64 *)((void *)tg + off);
 
 	if (v == -1)
 		return 0;
-	return __blkg_prfill_u64(sf, pdata, v);
+	return __blkg_prfill_u64(sf, pd, v);
 }
 
-static u64 tg_prfill_conf_uint(struct seq_file *sf, void *pdata, int off)
+static u64 tg_prfill_conf_uint(struct seq_file *sf, struct blkg_policy_data *pd,
+			       int off)
 {
-	unsigned int v = *(unsigned int *)(pdata + off);
+	struct throtl_grp *tg = pd_to_tg(pd);
+	unsigned int v = *(unsigned int *)((void *)tg + off);
 
 	if (v == -1)
 		return 0;
-	return __blkg_prfill_u64(sf, pdata, v);
+	return __blkg_prfill_u64(sf, pd, v);
 }
 
 static int tg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
@@ -1092,7 +1105,7 @@ static struct blkcg_policy blkcg_policy_throtl = {
 		.pd_exit_fn		= throtl_pd_exit,
 		.pd_reset_stats_fn	= throtl_pd_reset_stats,
 	},
-	.pdata_size = sizeof(struct throtl_grp),
+	.pd_size = sizeof(struct throtl_grp),
 	.cftypes = throtl_files,
 };
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 7922182..7865cc3 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -217,6 +217,9 @@ struct cfqg_stats {
 
 /* This is per cgroup per device grouping structure */
 struct cfq_group {
+	/* must be the first member */
+	struct blkg_policy_data pd;
+
 	/* group service_tree member */
 	struct rb_node rb_node;
 
@@ -409,6 +412,21 @@ CFQ_CFQQ_FNS(deep);
 CFQ_CFQQ_FNS(wait_busy);
 #undef CFQ_CFQQ_FNS
 
+static inline struct cfq_group *pd_to_cfqg(struct blkg_policy_data *pd)
+{
+	return pd ? container_of(pd, struct cfq_group, pd) : NULL;
+}
+
+static inline struct cfq_group *blkg_to_cfqg(struct blkcg_gq *blkg)
+{
+	return pd_to_cfqg(blkg_to_pd(blkg, &blkcg_policy_cfq));
+}
+
+static inline struct blkcg_gq *cfqg_to_blkg(struct cfq_group *cfqg)
+{
+	return pd_to_blkg(&cfqg->pd);
+}
+
 #if defined(CONFIG_CFQ_GROUP_IOSCHED) && defined(CONFIG_DEBUG_BLK_CGROUP)
 
 /* cfqg stats flags */
@@ -553,16 +571,6 @@ static inline void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg) { }
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
 
-static inline struct cfq_group *blkg_to_cfqg(struct blkcg_gq *blkg)
-{
-	return blkg_to_pdata(blkg, &blkcg_policy_cfq);
-}
-
-static inline struct blkcg_gq *cfqg_to_blkg(struct cfq_group *cfqg)
-{
-	return pdata_to_blkg(cfqg);
-}
-
 static inline void cfqg_get(struct cfq_group *cfqg)
 {
 	return blkg_get(cfqg_to_blkg(cfqg));
@@ -662,8 +670,6 @@ static void cfq_pd_reset_stats(struct blkcg_gq *blkg)
 
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
 
-static inline struct cfq_group *blkg_to_cfqg(struct blkcg_gq *blkg) { return NULL; }
-static inline struct blkcg_gq *cfqg_to_blkg(struct cfq_group *cfqg) { return NULL; }
 static inline void cfqg_get(struct cfq_group *cfqg) { }
 static inline void cfqg_put(struct cfq_group *cfqg) { }
 
@@ -1374,13 +1380,14 @@ static void cfq_link_cfqq_cfqg(struct cfq_queue *cfqq, struct cfq_group *cfqg)
 	cfqg_get(cfqg);
 }
 
-static u64 cfqg_prfill_weight_device(struct seq_file *sf, void *pdata, int off)
+static u64 cfqg_prfill_weight_device(struct seq_file *sf,
+				     struct blkg_policy_data *pd, int off)
 {
-	struct cfq_group *cfqg = pdata;
+	struct cfq_group *cfqg = pd_to_cfqg(pd);
 
 	if (!cfqg->dev_weight)
 		return 0;
-	return __blkg_prfill_u64(sf, pdata, cfqg->dev_weight);
+	return __blkg_prfill_u64(sf, pd, cfqg->dev_weight);
 }
 
 static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
@@ -1467,9 +1474,10 @@ static int cfqg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
 }
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf, void *pdata, int off)
+static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
+				      struct blkg_policy_data *pd, int off)
 {
-	struct cfq_group *cfqg = pdata;
+	struct cfq_group *cfqg = pd_to_cfqg(pd);
 	u64 samples = blkg_stat_read(&cfqg->stats.avg_queue_size_samples);
 	u64 v = 0;
 
@@ -1477,7 +1485,7 @@ static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf, void *pdata, int off)
 		v = blkg_stat_read(&cfqg->stats.avg_queue_size_sum);
 		do_div(v, samples);
 	}
-	__blkg_prfill_u64(sf, pdata, v);
+	__blkg_prfill_u64(sf, pd, v);
 	return 0;
 }
 
@@ -4161,7 +4169,7 @@ static struct blkcg_policy blkcg_policy_cfq = {
 		.pd_init_fn		= cfq_pd_init,
 		.pd_reset_stats_fn	= cfq_pd_reset_stats,
 	},
-	.pdata_size = sizeof(struct cfq_group),
+	.pd_size = sizeof(struct cfq_group),
 	.cftypes = cfq_blkcg_files,
 };
 #endif
-- 
1.7.7.3
