From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/21] blkcg: export conf/stat helpers to prepare for
	reorganization
Date: Wed, 28 Mar 2012 15:51:19 -0700
Message-ID: <1332975091-10950-10-git-send-email-tj@kernel.org>
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

conf/stat handling is about to be moved to policy implementation from
blkcg core.  Export conf/stat helpers from blkcg core so that
blk-throttle and cfq-iosched can use them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |   52 +++++++++++++++++++++++++---------------------------
 block/blk-cgroup.h |   27 +++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 27 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 3d933b0..df1e197 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -11,7 +11,6 @@
  * 	              Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
  */
 #include <linux/ioprio.h>
-#include <linux/seq_file.h>
 #include <linux/kdev_t.h>
 #include <linux/module.h>
 #include <linux/err.h>
@@ -767,10 +766,9 @@ static const char *blkg_dev_name(struct blkio_group *blkg)
  * This is to be used to construct print functions for
  * cftype->read_seq_string method.
  */
-static void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
-			      u64 (*prfill)(struct seq_file *,
-					    struct blkg_policy_data *, int),
-			      int pol, int data, bool show_total)
+void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
+		       u64 (*prfill)(struct seq_file *, struct blkg_policy_data *, int),
+		       int pol, int data, bool show_total)
 {
 	struct blkio_group *blkg;
 	struct hlist_node *n;
@@ -785,6 +783,7 @@ static void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 	if (show_total)
 		seq_printf(sf, "Total %llu\n", (unsigned long long)total);
 }
+EXPORT_SYMBOL_GPL(blkcg_print_blkgs);
 
 /**
  * __blkg_prfill_u64 - prfill helper for a single u64 value
@@ -794,8 +793,7 @@ static void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
  *
  * Print @v to @sf for the device assocaited with @pd.
  */
-static u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd,
-			     u64 v)
+u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd, u64 v)
 {
 	const char *dname = blkg_dev_name(pd->blkg);
 
@@ -805,6 +803,7 @@ static u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd,
 	seq_printf(sf, "%s %llu\n", dname, (unsigned long long)v);
 	return v;
 }
+EXPORT_SYMBOL_GPL(__blkg_prfill_u64);
 
 /**
  * __blkg_prfill_rwstat - prfill helper for a blkg_rwstat
@@ -814,9 +813,8 @@ static u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd,
  *
  * Print @rwstat to @sf for the device assocaited with @pd.
  */
-static u64 __blkg_prfill_rwstat(struct seq_file *sf,
-				struct blkg_policy_data *pd,
-				const struct blkg_rwstat *rwstat)
+u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+			 const struct blkg_rwstat *rwstat)
 {
 	static const char *rwstr[] = {
 		[BLKG_RWSTAT_READ]	= "Read",
@@ -856,8 +854,8 @@ static u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 }
 
 /* print blkg_stat specified by BLKCG_STAT_PRIV() */
-static int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
-			    struct seq_file *sf)
+int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
+		     struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
@@ -866,10 +864,11 @@ static int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 			  BLKCG_STAT_OFF(cft->private), false);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(blkcg_print_stat);
 
 /* print blkg_rwstat specified by BLKCG_STAT_PRIV() */
-static int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
-			      struct seq_file *sf)
+int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
+		       struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
@@ -878,6 +877,7 @@ static int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
 			  BLKCG_STAT_OFF(cft->private), true);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(blkcg_print_rwstat);
 
 static u64 blkg_prfill_cpu_stat(struct seq_file *sf,
 				struct blkg_policy_data *pd, int off)
@@ -914,8 +914,8 @@ static u64 blkg_prfill_cpu_rwstat(struct seq_file *sf,
 }
 
 /* print per-cpu blkg_stat specified by BLKCG_STAT_PRIV() */
-static int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
-				struct seq_file *sf)
+int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
+			 struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
@@ -924,10 +924,11 @@ static int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
 			  BLKCG_STAT_OFF(cft->private), false);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(blkcg_print_cpu_stat);
 
 /* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
-static int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
-				  struct seq_file *sf)
+int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
+			   struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
@@ -936,6 +937,7 @@ static int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 			  BLKCG_STAT_OFF(cft->private), true);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(blkcg_print_cpu_rwstat);
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 static u64 blkg_prfill_avg_queue_size(struct seq_file *sf,
@@ -964,12 +966,6 @@ static int blkcg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
 }
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
 
-struct blkg_conf_ctx {
-	struct gendisk		*disk;
-	struct blkio_group	*blkg;
-	u64			v;
-};
-
 /**
  * blkg_conf_prep - parse and prepare for per-blkg config update
  * @blkcg: target block cgroup
@@ -981,8 +977,8 @@ struct blkg_conf_ctx {
  * value.  This function returns with RCU read locked and must be paired
  * with blkg_conf_finish().
  */
-static int blkg_conf_prep(struct blkio_cgroup *blkcg, const char *input,
-			  struct blkg_conf_ctx *ctx)
+int blkg_conf_prep(struct blkio_cgroup *blkcg, const char *input,
+		   struct blkg_conf_ctx *ctx)
 	__acquires(rcu)
 {
 	struct gendisk *disk;
@@ -1026,6 +1022,7 @@ static int blkg_conf_prep(struct blkio_cgroup *blkcg, const char *input,
 	ctx->v = v;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(blkg_conf_prep);
 
 /**
  * blkg_conf_finish - finish up per-blkg config update
@@ -1034,12 +1031,13 @@ static int blkg_conf_prep(struct blkio_cgroup *blkcg, const char *input,
  * Finish up after per-blkg config update.  This function must be paired
  * with blkg_conf_prep().
  */
-static void blkg_conf_finish(struct blkg_conf_ctx *ctx)
+void blkg_conf_finish(struct blkg_conf_ctx *ctx)
 	__releases(rcu)
 {
 	rcu_read_unlock();
 	put_disk(ctx->disk);
 }
+EXPORT_SYMBOL_GPL(blkg_conf_finish);
 
 /* for propio conf */
 static u64 blkg_prfill_weight_device(struct seq_file *sf,
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 108ffbf..361ecfa 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -15,6 +15,7 @@
 
 #include <linux/cgroup.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/seq_file.h>
 
 enum blkio_policy_id {
 	BLKIO_POLICY_PROP = 0,		/* Proportional Bandwidth division */
@@ -193,6 +194,32 @@ extern void blkg_destroy_all(struct request_queue *q, bool destroy_root);
 extern void update_root_blkg_pd(struct request_queue *q,
 				enum blkio_policy_id plid);
 
+void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
+		       u64 (*prfill)(struct seq_file *, struct blkg_policy_data *, int),
+		       int pol, int data, bool show_total);
+u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd, u64 v);
+u64 __blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+			 const struct blkg_rwstat *rwstat);
+int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
+		     struct seq_file *sf);
+int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
+		       struct seq_file *sf);
+int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
+			 struct seq_file *sf);
+int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
+			   struct seq_file *sf);
+
+struct blkg_conf_ctx {
+	struct gendisk		*disk;
+	struct blkio_group	*blkg;
+	u64			v;
+};
+
+int blkg_conf_prep(struct blkio_cgroup *blkcg, const char *input,
+		   struct blkg_conf_ctx *ctx);
+void blkg_conf_finish(struct blkg_conf_ctx *ctx);
+
+
 /**
  * blkg_to_pdata - get policy private data
  * @blkg: blkg of interest
-- 
1.7.7.3
