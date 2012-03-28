From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 21/21] blkcg: drop BLKCG_STAT_{PRIV|POL|OFF} macros
Date: Wed, 28 Mar 2012 15:51:31 -0700
Message-ID: <1332975091-10950-22-git-send-email-tj@kernel.org>
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

Now that all stat handling code lives in policy implementations,
there's no need to encode policy ID in cft->private.

* Export blkcg_prfill_[rw]stat() from blkcg, remove
  blkcg_print_[rw]stat(), and implement cfqg_print_[rw]stat() which
  use hard-code BLKIO_POLICY_PROP.

* Use cft->private for offset of the target field directly and drop
  BLKCG_STAT_{PRIV|POL|OFF}().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |   48 ++++++++++++----------------
 block/blk-cgroup.h   |   11 +-----
 block/blk-throttle.c |   12 ++-----
 block/cfq-iosched.c  |   85 +++++++++++++++++++++++++++-----------------------
 4 files changed, 72 insertions(+), 84 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 8f678d7..f762333 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -430,43 +430,35 @@ u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 	return v;
 }
 
-static u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off)
+/**
+ * blkg_prfill_stat - prfill callback for blkg_stat
+ * @sf: seq_file to print to
+ * @pdata: policy private data of interest
+ * @off: offset to the blkg_stat in @pdata
+ *
+ * prfill callback for printing a blkg_stat.
+ */
+u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off)
 {
 	return __blkg_prfill_u64(sf, pdata, blkg_stat_read(pdata + off));
 }
+EXPORT_SYMBOL_GPL(blkg_prfill_stat);
 
-static u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off)
+/**
+ * blkg_prfill_rwstat - prfill callback for blkg_rwstat
+ * @sf: seq_file to print to
+ * @pdata: policy private data of interest
+ * @off: offset to the blkg_rwstat in @pdata
+ *
+ * prfill callback for printing a blkg_rwstat.
+ */
+u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off)
 {
 	struct blkg_rwstat rwstat = blkg_rwstat_read(pdata + off);
 
 	return __blkg_prfill_rwstat(sf, pdata, &rwstat);
 }
-
-/* print blkg_stat specified by BLKCG_STAT_PRIV() */
-int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
-		     struct seq_file *sf)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat,
-			  BLKCG_STAT_POL(cft->private),
-			  BLKCG_STAT_OFF(cft->private), false);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(blkcg_print_stat);
-
-/* print blkg_rwstat specified by BLKCG_STAT_PRIV() */
-int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
-		       struct seq_file *sf)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat,
-			  BLKCG_STAT_POL(cft->private),
-			  BLKCG_STAT_OFF(cft->private), true);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(blkcg_print_rwstat);
+EXPORT_SYMBOL_GPL(blkg_prfill_rwstat);
 
 /**
  * blkg_conf_prep - parse and prepare for per-blkg config update
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index c930895..ca0ff7c 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -34,11 +34,6 @@ enum blkio_policy_id {
 #define CFQ_WEIGHT_MAX		1000
 #define CFQ_WEIGHT_DEFAULT	500
 
-/* cft->private [un]packing for stat printing */
-#define BLKCG_STAT_PRIV(pol, off)	(((unsigned)(pol) << 16) | (off))
-#define BLKCG_STAT_POL(prv)		((unsigned)(prv) >> 16)
-#define BLKCG_STAT_OFF(prv)		((unsigned)(prv) & 0xffff)
-
 enum blkg_rwstat_type {
 	BLKG_RWSTAT_READ,
 	BLKG_RWSTAT_WRITE,
@@ -131,10 +126,8 @@ void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
 u64 __blkg_prfill_u64(struct seq_file *sf, void *pdata, u64 v);
 u64 __blkg_prfill_rwstat(struct seq_file *sf, void *pdata,
 			 const struct blkg_rwstat *rwstat);
-int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
-		     struct seq_file *sf);
-int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
-		       struct seq_file *sf);
+u64 blkg_prfill_stat(struct seq_file *sf, void *pdata, int off);
+u64 blkg_prfill_rwstat(struct seq_file *sf, void *pdata, int off);
 
 struct blkg_conf_ctx {
 	struct gendisk		*disk;
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index bd6dbfe..6024014 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -941,15 +941,13 @@ static u64 tg_prfill_cpu_rwstat(struct seq_file *sf, void *pdata, int off)
 	return __blkg_prfill_rwstat(sf, pdata, &rwstat);
 }
 
-/* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
 static int tg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
 			       struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat,
-			  BLKCG_STAT_POL(cft->private),
-			  BLKCG_STAT_OFF(cft->private), true);
+	blkcg_print_blkgs(sf, blkcg, tg_prfill_cpu_rwstat, BLKIO_POLICY_THROTL,
+			  cft->private, true);
 	return 0;
 }
 
@@ -1067,14 +1065,12 @@ static struct cftype throtl_files[] = {
 	},
 	{
 		.name = "throttle.io_service_bytes",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
-				offsetof(struct tg_stats_cpu, service_bytes)),
+		.private = offsetof(struct tg_stats_cpu, service_bytes),
 		.read_seq_string = tg_print_cpu_rwstat,
 	},
 	{
 		.name = "throttle.io_serviced",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
-				offsetof(struct tg_stats_cpu, serviced)),
+		.private = offsetof(struct tg_stats_cpu, serviced),
 		.read_seq_string = tg_print_cpu_rwstat,
 	},
 	{ }	/* terminate */
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index fd505f7..cff8b5b 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1441,6 +1441,26 @@ static int cfq_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 	return 0;
 }
 
+static int cfqg_print_stat(struct cgroup *cgrp, struct cftype *cft,
+			   struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat, BLKIO_POLICY_PROP,
+			  cft->private, false);
+	return 0;
+}
+
+static int cfqg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
+			     struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat, BLKIO_POLICY_PROP,
+			  cft->private, true);
+	return 0;
+}
+
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf, void *pdata, int off)
 {
@@ -1482,51 +1502,43 @@ static struct cftype cfq_blkcg_files[] = {
 	},
 	{
 		.name = "time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.time)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.time),
+		.read_seq_string = cfqg_print_stat,
 	},
 	{
 		.name = "sectors",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.sectors)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.sectors),
+		.read_seq_string = cfqg_print_stat,
 	},
 	{
 		.name = "io_service_bytes",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.service_bytes)),
-		.read_seq_string = blkcg_print_rwstat,
+		.private = offsetof(struct cfq_group, stats.service_bytes),
+		.read_seq_string = cfqg_print_rwstat,
 	},
 	{
 		.name = "io_serviced",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.serviced)),
-		.read_seq_string = blkcg_print_rwstat,
+		.private = offsetof(struct cfq_group, stats.serviced),
+		.read_seq_string = cfqg_print_rwstat,
 	},
 	{
 		.name = "io_service_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.service_time)),
-		.read_seq_string = blkcg_print_rwstat,
+		.private = offsetof(struct cfq_group, stats.service_time),
+		.read_seq_string = cfqg_print_rwstat,
 	},
 	{
 		.name = "io_wait_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.wait_time)),
-		.read_seq_string = blkcg_print_rwstat,
+		.private = offsetof(struct cfq_group, stats.wait_time),
+		.read_seq_string = cfqg_print_rwstat,
 	},
 	{
 		.name = "io_merged",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.merged)),
-		.read_seq_string = blkcg_print_rwstat,
+		.private = offsetof(struct cfq_group, stats.merged),
+		.read_seq_string = cfqg_print_rwstat,
 	},
 	{
 		.name = "io_queued",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.queued)),
-		.read_seq_string = blkcg_print_rwstat,
+		.private = offsetof(struct cfq_group, stats.queued),
+		.read_seq_string = cfqg_print_rwstat,
 	},
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 	{
@@ -1535,33 +1547,28 @@ static struct cftype cfq_blkcg_files[] = {
 	},
 	{
 		.name = "group_wait_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.group_wait_time)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.group_wait_time),
+		.read_seq_string = cfqg_print_stat,
 	},
 	{
 		.name = "idle_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.idle_time)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.idle_time),
+		.read_seq_string = cfqg_print_stat,
 	},
 	{
 		.name = "empty_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.empty_time)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.empty_time),
+		.read_seq_string = cfqg_print_stat,
 	},
 	{
 		.name = "dequeue",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.dequeue)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.dequeue),
+		.read_seq_string = cfqg_print_stat,
 	},
 	{
 		.name = "unaccounted_time",
-		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct cfq_group, stats.unaccounted_time)),
-		.read_seq_string = blkcg_print_stat,
+		.private = offsetof(struct cfq_group, stats.unaccounted_time),
+		.read_seq_string = cfqg_print_stat,
 	},
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
 	{ }	/* terminate */
-- 
1.7.7.3
