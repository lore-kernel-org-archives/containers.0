From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 20/21] blkcg: pass around pd->pdata instead of pd itself in
	prfill functions
Date: Wed, 28 Mar 2012 15:51:30 -0700
Message-ID: <1332975091-10950-21-git-send-email-tj@kernel.org>
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

Now that all conf and stat fields are moved into policy specific
blkio_policy_data->pdata areas, there's no reason to use
blkio_policy_data itself in prfill functions.  Pass around @pd->pdata
instead of @pd.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |   33 +++++++++++++++------------------
 block/blk-cgroup.h   |    6 +++---
 block/blk-throttle.c |   21 +++++++++------------
 block/cfq-iosched.c  |   14 ++++++--------
 4 files changed, 33 insertions(+), 41 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 7688aef..8f678d7 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -359,7 +359,7 @@ static const char *blkg_dev_name(struct blkio_group *blkg)
  * cftype->read_seq_string method.
  */
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
-		       u64 (*prfill)(struct seq_file *, struct blkg_policy_data *, int),
+		       u64 (*prfill)(struct seq_file *, void *, int),
 		       int pol, int data, bool show_total)
 {
 	struct blkio_group *blkg;
@@ -369,7 +369,7 @@ void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 	spin_lock_irq(&blkcg->lock);
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node)
 		if (blkg->pd[pol])
-			total += prfill(sf, blkg->pd[pol], data);
+			total += prfill(sf, blkg->pd[pol]->pdata, data);
 	spin_unlock_irq(&blkcg->lock);
 
 	if (show_total)
@@ -380,14 +380,14 @@ EXPORT_SYMBOL_GPL(blkcg_print_blkgs);
 /**
  * __blkg_prfill_u64 - prfill helper for a single u64 value
  * @sf: seq_file to print to
- * @pd: policy data of interest
+ * @pdata: policy private data of interest
  * @v: value to print
  *
- * Print @v to @sf for the device assocaited with @pd.
+ * Print @v to @sf for the device assocaited with @pdata.
  */
-u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd, u64 v)
+u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v)
 {
-	const char *dname = blkg_dev_name(pd->blkg);
+	const char *dname = blkg_dev_name(pdata_to_blkg(pdata));
 
 	if (!dname)
 		return 0;
@@ -400,12 +400,12 @@ EXPORT_SYMBOL_GPL(__blkg_prfill_u64);
 /**
  * __blkg_prfill_rwstat - prfill helper for a blkg_rwstat
  * @sf: seq_file to print to
- * @pd: policy data of interest
+ * @pdata: policy private data of interest
  * @rwstat: rwstat to print
  *
- * Print @rwstat to @sf for the device assocaited with @pd.
+ * Print @rwstat to @sf for the device assocaited with @pdata.
  */
-u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 			 const struct blkg_rwstat *rwstat)
 {
 	static const char *rwstr[] = {
@@ -414,7 +414,7 @@ u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 		[BLKG_RWSTAT_SYNC]	= "Sync",
 		[BLKG_RWSTAT_ASYNC]	= "Async",
 	};
-	const char *dname = blkg_dev_name(pd->blkg);
+	const char *dname = blkg_dev_name(pdata_to_blkg(pdata));
 	u64 v;
 	int i;
 
@@ -430,19 +430,16 @@ u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 	return v;
 }
 
-static u64 blkg_prfill_stat(struct seq_file *sf, struct blkg_policy_data *pd,
-			    int off)
+static u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off)
 {
-	return __blkg_prfill_u64(sf, pd,
-				 blkg_stat_read((void *)pd->pdata + off));
+	return __blkg_prfill_u64(sf, pdata, blkg_stat_read(pdata + off));
 }
 
-static u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
-			      int off)
+static u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off)
 {
-	struct blkg_rwstat rwstat = blkg_rwstat_read((void *)pd->pdata + off);
+	struct blkg_rwstat rwstat = blkg_rwstat_read(pdata + off);
 
-	return __blkg_prfill_rwstat(sf, pd, &rwstat);
+	return __blkg_prfill_rwstat(sf, pdata, &rwstat);
 }
 
 /* print blkg_stat specified by BLKCG_STAT_PRIV() */
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index a77ab1a..c930895 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -126,10 +126,10 @@ extern void update_root_blkg_pd(struct request_queue *q,
 				enum blkio_policy_id plid);
 
 void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
-		       u64 (*prfill)(struct seq_file *, struct blkg_policy_data *, int),
+		       u64 (*prfill)(struct seq_file *, void *, int),
 		       int pol, int data, bool show_total);
-u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd, u64 v);
-u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v);
+u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 			 const struct blkg_rwstat *rwstat);
 int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 		     struct seq_file *sf);
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 004964b..bd6dbfe 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -924,10 +924,9 @@ throtl_schedule_delayed_work(struct throtl_data *td, unsigned long delay)
 	}
 }
 
-static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
-				struct blkg_policy_data *pd, int off)
+static u64 tg_prfill_cpu_rwstat(struct seq_file *sf, void *pdata, int off)
 {
-	struct throtl_grp *tg = (void *)pd->pdata;
+	struct throtl_grp *tg = pdata;
 	struct blkg_rwstat rwstat = { }, tmp;
 	int i, cpu;
 
@@ -939,7 +938,7 @@ static u64 tg_prfill_cpu_rwstat(struct seq_file *sf,
 			rwstat.cnt[i] += tmp.cnt[i];
 	}
 
-	return __blkg_prfill_rwstat(sf, pd, &rwstat);
+	return __blkg_prfill_rwstat(sf, pdata, &rwstat);
 }
 
 /* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
@@ -954,24 +953,22 @@ static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
-static u64 tg_prfill_conf_u64(struct seq_file *sf, struct blkg_policy_data *pd,
-			      int off)
+static u64 tg_prfill_conf_u64(struct seq_file *sf, void *pdata, int off)
 {
-	u64 v = *(u64 *)((void *)pd->pdata + off);
+	u64 v = *(u64 *)(pdata + off);
 
 	if (v == -1)
 		return 0;
-	return __blkg_prfill_u64(sf, pd, v);
+	return __blkg_prfill_u64(sf, pdata, v);
 }
 
-static u64 tg_prfill_conf_uint(struct seq_file *sf, struct blkg_policy_data *pd,
-			       int off)
+static u64 tg_prfill_conf_uint(struct seq_file *sf, void *pdata, int off)
 {
-	unsigned int v = *(unsigned int *)((void *)pd->pdata + off);
+	unsigned int v = *(unsigned int *)(pdata + off);
 
 	if (v == -1)
 		return 0;
-	return __blkg_prfill_u64(sf, pd, v);
+	return __blkg_prfill_u64(sf, pdata, v);
 }
 
 static int tg_print_conf_u64(struct cgroup *cgrp, struct cftype *cft,
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index adab10d..fd505f7 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1368,14 +1368,13 @@ static void cfq_link_cfqq_cfqg(struct cfq_queue *cfqq, struct cfq_group *cfqg)
 	cfqg_get(cfqg);
 }
 
-static u64 cfqg_prfill_weight_device(struct seq_file *sf,
-				     struct blkg_policy_data *pd, int off)
+static u64 cfqg_prfill_weight_device(struct seq_file *sf, void *pdata, int off)
 {
-	struct cfq_group *cfqg = (void *)pd->pdata;
+	struct cfq_group *cfqg = pdata;
 
 	if (!cfqg->dev_weight)
 		return 0;
-	return __blkg_prfill_u64(sf, pd, cfqg->dev_weight);
+	return __blkg_prfill_u64(sf, pdata, cfqg->dev_weight);
 }
 
 static int cfqg_print_weight_device(struct cgroup *cgrp, struct cftype *cft,
@@ -1443,10 +1442,9 @@ static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 }
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
-				      struct blkg_policy_data *pd, int off)
+static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf, void *pdata, int off)
 {
-	struct cfq_group *cfqg = (void *)pd->pdata;
+	struct cfq_group *cfqg = pdata;
 	u64 samples = blkg_stat_read(&cfqg->stats.avg_queue_size_samples);
 	u64 v = 0;
 
@@ -1454,7 +1452,7 @@ static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
 		v = blkg_stat_read(&cfqg->stats.avg_queue_size_sum);
 		do_div(v, samples);
 	}
-	__blkg_prfill_u64(sf, pd, v);
+	__blkg_prfill_u64(sf, pdata, v);
 	return 0;
 }
 
-- 
1.7.7.3
