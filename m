From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/21] blkcg: cfq doesn't need per-cpu dispatch stats
Date: Wed, 28 Mar 2012 15:51:24 -0700
Message-ID: <1332975091-10950-15-git-send-email-tj@kernel.org>
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

blkio_group_stats_cpu is used to count dispatch stats using per-cpu
counters.  This is used by both blk-throtl and cfq-iosched but the
sharing is rather silly.

* cfq-iosched doesn't need per-cpu dispatch stats.  cfq always updates
  those stats while holding queue_lock.

* blk-throtl needs per-cpu dispatch stats but only service_bytes and
  serviced.  It doesn't make use of sectors.

This patch makes cfq add and use global stats for service_bytes,
serviced and sectors, removes per-cpu sectors counter and moves
per-cpu stat printing code to blk-throttle.c.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |   63 +------------------------------------------------
 block/blk-cgroup.h   |   12 ++++----
 block/blk-throttle.c |   31 +++++++++++++++++++++++-
 block/cfq-iosched.c  |   37 ++++++++---------------------
 4 files changed, 48 insertions(+), 95 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index dfa5f2c..16158e5 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -390,7 +390,6 @@ static void blkio_reset_stats_cpu(struct blkio_group *blkg, int plid)
 
 		blkg_rwstat_reset(&sc->service_bytes);
 		blkg_rwstat_reset(&sc->serviced);
-		blkg_stat_reset(&sc->sectors);
 	}
 }
 
@@ -417,6 +416,8 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 			struct blkio_group_stats *stats = &pd->stats;
 
 			/* queued stats shouldn't be cleared */
+			blkg_rwstat_reset(&stats->service_bytes);
+			blkg_rwstat_reset(&stats->serviced);
 			blkg_rwstat_reset(&stats->merged);
 			blkg_rwstat_reset(&stats->service_time);
 			blkg_rwstat_reset(&stats->wait_time);
@@ -577,66 +578,6 @@ int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
 }
 EXPORT_SYMBOL_GPL(blkcg_print_rwstat);
 
-static u64 blkg_prfill_cpu_stat(struct seq_file *sf,
-				struct blkg_policy_data *pd, int off)
-{
-	u64 v = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct blkio_group_stats_cpu *sc =
-			per_cpu_ptr(pd->stats_cpu, cpu);
-
-		v += blkg_stat_read((void *)sc + off);
-	}
-
-	return __blkg_prfill_u64(sf, pd, v);
-}
-
-static u64 blkg_prfill_cpu_rwstat(struct seq_file *sf,
-				  struct blkg_policy_data *pd, int off)
-{
-	struct blkg_rwstat rwstat = { }, tmp;
-	int i, cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct blkio_group_stats_cpu *sc =
-			per_cpu_ptr(pd->stats_cpu, cpu);
-
-		tmp = blkg_rwstat_read((void *)sc + off);
-		for (i = 0; i < BLKG_RWSTAT_NR; i++)
-			rwstat.cnt[i] += tmp.cnt[i];
-	}
-
-	return __blkg_prfill_rwstat(sf, pd, &rwstat);
-}
-
-/* print per-cpu blkg_stat specified by BLKCG_STAT_PRIV() */
-int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
-			 struct seq_file *sf)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_cpu_stat,
-			  BLKCG_STAT_POL(cft->private),
-			  BLKCG_STAT_OFF(cft->private), false);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(blkcg_print_cpu_stat);
-
-/* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
-int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
-			   struct seq_file *sf)
-{
-	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_cpu_rwstat,
-			  BLKCG_STAT_POL(cft->private),
-			  BLKCG_STAT_OFF(cft->private), true);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(blkcg_print_cpu_rwstat);
-
 /**
  * blkg_conf_prep - parse and prepare for per-blkg config update
  * @blkcg: target block cgroup
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 0b0a176..c82de47 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -65,6 +65,10 @@ struct blkg_rwstat {
 };
 
 struct blkio_group_stats {
+	/* total bytes transferred */
+	struct blkg_rwstat		service_bytes;
+	/* total IOs serviced, post merge */
+	struct blkg_rwstat		serviced;
 	/* number of ios merged */
 	struct blkg_rwstat		merged;
 	/* total time spent on device in ns, may not be accurate w/ queueing */
@@ -73,6 +77,8 @@ struct blkio_group_stats {
 	struct blkg_rwstat		wait_time;
 	/* number of IOs queued up */
 	struct blkg_rwstat		queued;
+	/* total sectors transferred */
+	struct blkg_stat		sectors;
 	/* total disk time and nr sectors dispatched by this group */
 	struct blkg_stat		time;
 #ifdef CONFIG_DEBUG_BLK_CGROUP
@@ -104,8 +110,6 @@ struct blkio_group_stats_cpu {
 	struct blkg_rwstat		service_bytes;
 	/* total IOs serviced, post merge */
 	struct blkg_rwstat		serviced;
-	/* total sectors transferred */
-	struct blkg_stat		sectors;
 };
 
 struct blkio_group_conf {
@@ -183,10 +187,6 @@ int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
 		     struct seq_file *sf);
 int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
 		       struct seq_file *sf);
-int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
-			 struct seq_file *sf);
-int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
-			   struct seq_file *sf);
 
 struct blkg_conf_ctx {
 	struct gendisk		*disk;
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 5d647ed..cb259bc 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -582,7 +582,6 @@ static void throtl_update_dispatch_stats(struct blkio_group *blkg, u64 bytes,
 
 	stats_cpu = this_cpu_ptr(pd->stats_cpu);
 
-	blkg_stat_add(&stats_cpu->sectors, bytes >> 9);
 	blkg_rwstat_add(&stats_cpu->serviced, rw, 1);
 	blkg_rwstat_add(&stats_cpu->service_bytes, rw, bytes);
 
@@ -843,6 +842,36 @@ static void throtl_update_blkio_group_common(struct throtl_data *td,
 	throtl_schedule_delayed_work(td, 0);
 }
 
+static u64 blkg_prfill_cpu_rwstat(struct seq_file *sf,
+				  struct blkg_policy_data *pd, int off)
+{
+	struct blkg_rwstat rwstat = { }, tmp;
+	int i, cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct blkio_group_stats_cpu *sc =
+			per_cpu_ptr(pd->stats_cpu, cpu);
+
+		tmp = blkg_rwstat_read((void *)sc + off);
+		for (i = 0; i < BLKG_RWSTAT_NR; i++)
+			rwstat.cnt[i] += tmp.cnt[i];
+	}
+
+	return __blkg_prfill_rwstat(sf, pd, &rwstat);
+}
+
+/* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
+static int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
+				  struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_cpu_rwstat,
+			  BLKCG_STAT_POL(cft->private),
+			  BLKCG_STAT_OFF(cft->private), true);
+	return 0;
+}
+
 static u64 blkg_prfill_conf_u64(struct seq_file *sf,
 				struct blkg_policy_data *pd, int off)
 {
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 4991380..effd894 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -624,29 +624,12 @@ static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, uint64_t bytes,
 			bool direction, bool sync)
 {
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
 	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-	struct blkg_policy_data *pd = blkg->pd[pol->plid];
-	struct blkio_group_stats_cpu *stats_cpu;
-	unsigned long flags;
 
-	/* If per cpu stats are not allocated yet, don't do any accounting. */
-	if (pd->stats_cpu == NULL)
-		return;
-
-	/*
-	 * Disabling interrupts to provide mutual exclusion between two
-	 * writes on same cpu. It probably is not needed for 64bit. Not
-	 * optimizing that case yet.
-	 */
-	local_irq_save(flags);
-
-	stats_cpu = this_cpu_ptr(pd->stats_cpu);
-
-	blkg_stat_add(&stats_cpu->sectors, bytes >> 9);
-	blkg_rwstat_add(&stats_cpu->serviced, rw, 1);
-	blkg_rwstat_add(&stats_cpu->service_bytes, rw, bytes);
-
-	local_irq_restore(flags);
+	blkg_stat_add(&stats->sectors, bytes >> 9);
+	blkg_rwstat_add(&stats->serviced, rw, 1);
+	blkg_rwstat_add(&stats->service_bytes, rw, bytes);
 }
 
 static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
@@ -1520,20 +1503,20 @@ static struct cftype cfq_blkcg_files[] = {
 	{
 		.name = "sectors",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats_cpu, sectors)),
-		.read_seq_string = blkcg_print_cpu_stat,
+				offsetof(struct blkio_group_stats, sectors)),
+		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "io_service_bytes",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats_cpu, service_bytes)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
+				offsetof(struct blkio_group_stats, service_bytes)),
+		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_serviced",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats_cpu, serviced)),
-		.read_seq_string = blkcg_print_cpu_rwstat,
+				offsetof(struct blkio_group_stats, serviced)),
+		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_service_time",
-- 
1.7.7.3
