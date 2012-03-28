From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/21] blkcg: restructure statistics printing
Date: Wed, 28 Mar 2012 15:51:14 -0700
Message-ID: <1332975091-10950-5-git-send-email-tj@kernel.org>
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

blkcg stats handling is a mess.  None of the stats has much to do with
blkcg core but they are all implemented in blkcg core.  Code sharing
is achieved by mixing common code with hard-coded cases for each stat
counter.

This patch restructures statistics printing such that

* Common logic exists as helper functions and specific print functions
  use the helpers to implement specific cases.

* Printing functions serving multiple counters don't require hardcoded
  switching on specific counters.

* Printing uses read_seq_string callback (other methods will be phased
  out).

This change enables further cleanups and relocating stats code to the
policy implementation it belongs to.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |  557 ++++++++++++++++++++++------------------------------
 block/blk-cgroup.h |   60 +------
 2 files changed, 243 insertions(+), 374 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 153a2db..f670217 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -753,186 +753,227 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	return 0;
 }
 
-static void blkio_get_key_name(enum blkg_rwstat_type type, const char *dname,
-			       char *str, int chars_left, bool diskname_only)
-{
-	snprintf(str, chars_left, "%s", dname);
-	chars_left -= strlen(str);
-	if (chars_left <= 0) {
-		printk(KERN_WARNING
-			"Possibly incorrect cgroup stat display format");
-		return;
-	}
-	if (diskname_only)
-		return;
-	switch (type) {
-	case BLKG_RWSTAT_READ:
-		strlcat(str, " Read", chars_left);
-		break;
-	case BLKG_RWSTAT_WRITE:
-		strlcat(str, " Write", chars_left);
-		break;
-	case BLKG_RWSTAT_SYNC:
-		strlcat(str, " Sync", chars_left);
-		break;
-	case BLKG_RWSTAT_ASYNC:
-		strlcat(str, " Async", chars_left);
-		break;
-	case BLKG_RWSTAT_TOTAL:
-		strlcat(str, " Total", chars_left);
-		break;
-	default:
-		strlcat(str, " Invalid", chars_left);
-	}
+static const char *blkg_dev_name(struct blkio_group *blkg)
+{
+	/* some drivers (floppy) instantiate a queue w/o disk registered */
+	if (blkg->q->backing_dev_info.dev)
+		return dev_name(blkg->q->backing_dev_info.dev);
+	return NULL;
 }
 
-static uint64_t blkio_read_stat_cpu(struct blkio_group *blkg, int plid,
-				    enum stat_type_cpu type,
-				    enum blkg_rwstat_type sub_type)
+/**
+ * blkcg_print_blkgs - helper for printing per-blkg data
+ * @sf: seq_file to print to
+ * @blkcg: blkcg of interest
+ * @prfill: fill function to print out a blkg
+ * @pol: policy in question
+ * @data: data to be passed to @prfill
+ * @show_total: to print out sum of prfill return values or not
+ *
+ * This function invokes @prfill on each blkg of @blkcg if pd for the
+ * policy specified by @pol exists.  @prfill is invoked with @sf, the
+ * policy data and @data.  If @show_total is %true, the sum of the return
+ * values from @prfill is printed with "Total" label at the end.
+ *
+ * This is to be used to construct print functions for
+ * cftype->read_seq_string method.
+ */
+static void blkcg_print_blkgs(struct seq_file *sf, struct blkio_cgroup *blkcg,
+			      u64 (*prfill)(struct seq_file *,
+					    struct blkg_policy_data *, int),
+			      int pol, int data, bool show_total)
 {
-	struct blkg_policy_data *pd = blkg->pd[plid];
-	u64 val = 0;
-	int cpu;
+	struct blkio_group *blkg;
+	struct hlist_node *n;
+	u64 total = 0;
 
-	if (pd->stats_cpu == NULL)
-		return val;
+	spin_lock_irq(&blkcg->lock);
+	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node)
+		if (blkg->pd[pol])
+			total += prfill(sf, blkg->pd[pol], data);
+	spin_unlock_irq(&blkcg->lock);
+
+	if (show_total)
+		seq_printf(sf, "Total %llu\n", (unsigned long long)total);
+}
+
+/**
+ * __blkg_prfill_u64 - prfill helper for a single u64 value
+ * @sf: seq_file to print to
+ * @pd: policy data of interest
+ * @v: value to print
+ *
+ * Print @v to @sf for the device assocaited with @pd.
+ */
+static u64 __blkg_prfill_u64(struct seq_file *sf, struct blkg_policy_data *pd,
+			     u64 v)
+{
+	const char *dname = blkg_dev_name(pd->blkg);
+
+	if (!dname)
+		return 0;
+
+	seq_printf(sf, "%s %llu\n", dname, (unsigned long long)v);
+	return v;
+}
+
+/**
+ * __blkg_prfill_rwstat - prfill helper for a blkg_rwstat
+ * @sf: seq_file to print to
+ * @pd: policy data of interest
+ * @rwstat: rwstat to print
+ *
+ * Print @rwstat to @sf for the device assocaited with @pd.
+ */
+static u64 __blkg_prfill_rwstat(struct seq_file *sf,
+				struct blkg_policy_data *pd,
+				const struct blkg_rwstat *rwstat)
+{
+	static const char *rwstr[] = {
+		[BLKG_RWSTAT_READ]	= "Read",
+		[BLKG_RWSTAT_WRITE]	= "Write",
+		[BLKG_RWSTAT_SYNC]	= "Sync",
+		[BLKG_RWSTAT_ASYNC]	= "Async",
+	};
+	const char *dname = blkg_dev_name(pd->blkg);
+	u64 v;
+	int i;
+
+	if (!dname)
+		return 0;
+
+	for (i = 0; i < BLKG_RWSTAT_NR; i++)
+		seq_printf(sf, "%s %s %llu\n", dname, rwstr[i],
+			   (unsigned long long)rwstat->cnt[i]);
+
+	v = rwstat->cnt[BLKG_RWSTAT_READ] + rwstat->cnt[BLKG_RWSTAT_WRITE];
+	seq_printf(sf, "%s Total %llu\n", dname, (unsigned long long)v);
+	return v;
+}
+
+static u64 blkg_prfill_stat(struct seq_file *sf, struct blkg_policy_data *pd,
+			    int off)
+{
+	return __blkg_prfill_u64(sf, pd,
+				 blkg_stat_read((void *)&pd->stats + off));
+}
+
+static u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
+			      int off)
+{
+	struct blkg_rwstat rwstat = blkg_rwstat_read((void *)&pd->stats + off);
+
+	return __blkg_prfill_rwstat(sf, pd, &rwstat);
+}
+
+/* print blkg_stat specified by BLKCG_STAT_PRIV() */
+static int blkcg_print_stat(struct cgroup *cgrp, struct cftype *cft,
+			    struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_stat,
+			  BLKCG_STAT_POL(cft->private),
+			  BLKCG_STAT_OFF(cft->private), false);
+	return 0;
+}
+
+/* print blkg_rwstat specified by BLKCG_STAT_PRIV() */
+static int blkcg_print_rwstat(struct cgroup *cgrp, struct cftype *cft,
+			      struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
+
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_rwstat,
+			  BLKCG_STAT_POL(cft->private),
+			  BLKCG_STAT_OFF(cft->private), true);
+	return 0;
+}
+
+static u64 blkg_prfill_cpu_stat(struct seq_file *sf,
+				struct blkg_policy_data *pd, int off)
+{
+	u64 v = 0;
+	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		struct blkio_group_stats_cpu *stats_cpu =
+		struct blkio_group_stats_cpu *sc =
 			per_cpu_ptr(pd->stats_cpu, cpu);
-		struct blkg_rwstat rws;
 
-		switch (type) {
-		case BLKIO_STAT_CPU_SECTORS:
-			val += blkg_stat_read(&stats_cpu->sectors);
-			break;
-		case BLKIO_STAT_CPU_SERVICE_BYTES:
-			rws = blkg_rwstat_read(&stats_cpu->service_bytes);
-			val += rws.cnt[sub_type];
-			break;
-		case BLKIO_STAT_CPU_SERVICED:
-			rws = blkg_rwstat_read(&stats_cpu->serviced);
-			val += rws.cnt[sub_type];
-			break;
-		}
+		v += blkg_stat_read((void *)sc + off);
 	}
 
-	return val;
+	return __blkg_prfill_u64(sf, pd, v);
 }
 
-static uint64_t blkio_get_stat_cpu(struct blkio_group *blkg, int plid,
-				   struct cgroup_map_cb *cb, const char *dname,
-				   enum stat_type_cpu type)
+static u64 blkg_prfill_cpu_rwstat(struct seq_file *sf,
+				  struct blkg_policy_data *pd, int off)
 {
-	uint64_t disk_total, val;
-	char key_str[MAX_KEY_LEN];
-	enum blkg_rwstat_type sub_type;
+	struct blkg_rwstat rwstat = { }, tmp;
+	int i, cpu;
 
-	if (type == BLKIO_STAT_CPU_SECTORS) {
-		val = blkio_read_stat_cpu(blkg, plid, type, 0);
-		blkio_get_key_name(0, dname, key_str, MAX_KEY_LEN, true);
-		cb->fill(cb, key_str, val);
-		return val;
-	}
+	for_each_possible_cpu(cpu) {
+		struct blkio_group_stats_cpu *sc =
+			per_cpu_ptr(pd->stats_cpu, cpu);
 
-	for (sub_type = BLKG_RWSTAT_READ; sub_type < BLKG_RWSTAT_NR;
-			sub_type++) {
-		blkio_get_key_name(sub_type, dname, key_str, MAX_KEY_LEN,
-				   false);
-		val = blkio_read_stat_cpu(blkg, plid, type, sub_type);
-		cb->fill(cb, key_str, val);
+		tmp = blkg_rwstat_read((void *)sc + off);
+		for (i = 0; i < BLKG_RWSTAT_NR; i++)
+			rwstat.cnt[i] += tmp.cnt[i];
 	}
 
-	disk_total = blkio_read_stat_cpu(blkg, plid, type, BLKG_RWSTAT_READ) +
-		blkio_read_stat_cpu(blkg, plid, type, BLKG_RWSTAT_WRITE);
-
-	blkio_get_key_name(BLKG_RWSTAT_TOTAL, dname, key_str, MAX_KEY_LEN,
-			   false);
-	cb->fill(cb, key_str, disk_total);
-	return disk_total;
+	return __blkg_prfill_rwstat(sf, pd, &rwstat);
 }
 
-static uint64_t blkio_get_stat(struct blkio_group *blkg, int plid,
-			       struct cgroup_map_cb *cb, const char *dname,
-			       enum stat_type type)
+/* print per-cpu blkg_stat specified by BLKCG_STAT_PRIV() */
+static int blkcg_print_cpu_stat(struct cgroup *cgrp, struct cftype *cft,
+				struct seq_file *sf)
 {
-	struct blkio_group_stats *stats = &blkg->pd[plid]->stats;
-	uint64_t v = 0, disk_total = 0;
-	char key_str[MAX_KEY_LEN];
-	struct blkg_rwstat rws = { };
-	int st;
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	if (type >= BLKIO_STAT_ARR_NR) {
-		switch (type) {
-		case BLKIO_STAT_TIME:
-			v = blkg_stat_read(&stats->time);
-			break;
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-		case BLKIO_STAT_UNACCOUNTED_TIME:
-			v = blkg_stat_read(&stats->unaccounted_time);
-			break;
-		case BLKIO_STAT_AVG_QUEUE_SIZE: {
-			uint64_t samples;
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_cpu_stat,
+			  BLKCG_STAT_POL(cft->private),
+			  BLKCG_STAT_OFF(cft->private), false);
+	return 0;
+}
 
-			samples = blkg_stat_read(&stats->avg_queue_size_samples);
-			if (samples) {
-				v = blkg_stat_read(&stats->avg_queue_size_sum);
-				do_div(v, samples);
-			}
-			break;
-		}
-		case BLKIO_STAT_IDLE_TIME:
-			v = blkg_stat_read(&stats->idle_time);
-			break;
-		case BLKIO_STAT_EMPTY_TIME:
-			v = blkg_stat_read(&stats->empty_time);
-			break;
-		case BLKIO_STAT_DEQUEUE:
-			v = blkg_stat_read(&stats->dequeue);
-			break;
-		case BLKIO_STAT_GROUP_WAIT_TIME:
-			v = blkg_stat_read(&stats->group_wait_time);
-			break;
-#endif
-		default:
-			WARN_ON_ONCE(1);
-		}
+/* print per-cpu blkg_rwstat specified by BLKCG_STAT_PRIV() */
+static int blkcg_print_cpu_rwstat(struct cgroup *cgrp, struct cftype *cft,
+				  struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-		blkio_get_key_name(0, dname, key_str, MAX_KEY_LEN, true);
-		cb->fill(cb, key_str, v);
-		return v;
-	}
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_cpu_rwstat,
+			  BLKCG_STAT_POL(cft->private),
+			  BLKCG_STAT_OFF(cft->private), true);
+	return 0;
+}
 
-	switch (type) {
-	case BLKIO_STAT_MERGED:
-		rws = blkg_rwstat_read(&stats->merged);
-		break;
-	case BLKIO_STAT_SERVICE_TIME:
-		rws = blkg_rwstat_read(&stats->service_time);
-		break;
-	case BLKIO_STAT_WAIT_TIME:
-		rws = blkg_rwstat_read(&stats->wait_time);
-		break;
-	case BLKIO_STAT_QUEUED:
-		rws = blkg_rwstat_read(&stats->queued);
-		break;
-	default:
-		WARN_ON_ONCE(true);
-		break;
-	}
+#ifdef CONFIG_DEBUG_BLK_CGROUP
+static u64 blkg_prfill_avg_queue_size(struct seq_file *sf,
+				      struct blkg_policy_data *pd, int off)
+{
+	u64 samples = blkg_stat_read(&pd->stats.avg_queue_size_samples);
+	u64 v = 0;
 
-	for (st = BLKG_RWSTAT_READ; st < BLKG_RWSTAT_NR; st++) {
-		blkio_get_key_name(st, dname, key_str, MAX_KEY_LEN, false);
-		cb->fill(cb, key_str, rws.cnt[st]);
-		if (st == BLKG_RWSTAT_READ || st == BLKG_RWSTAT_WRITE)
-			disk_total += rws.cnt[st];
+	if (samples) {
+		v = blkg_stat_read(&pd->stats.avg_queue_size_sum);
+		do_div(v, samples);
 	}
+	__blkg_prfill_u64(sf, pd, v);
+	return 0;
+}
+
+/* print avg_queue_size */
+static int blkcg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
+				      struct seq_file *sf)
+{
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkio_get_key_name(BLKG_RWSTAT_TOTAL, dname, key_str, MAX_KEY_LEN,
-			   false);
-	cb->fill(cb, key_str, disk_total);
-	return disk_total;
+	blkcg_print_blkgs(sf, blkcg, blkg_prfill_avg_queue_size,
+			  BLKIO_POLICY_PROP, 0, false);
+	return 0;
 }
+#endif	/* CONFIG_DEBUG_BLK_CGROUP */
 
 static int blkio_policy_parse_and_set(char *buf, enum blkio_policy_id plid,
 				      int fileid, struct blkio_cgroup *blkcg)
@@ -1074,14 +1115,6 @@ static int blkiocg_file_write(struct cgroup *cgrp, struct cftype *cft,
 	return ret;
 }
 
-static const char *blkg_dev_name(struct blkio_group *blkg)
-{
-	/* some drivers (floppy) instantiate a queue w/o disk registered */
-	if (blkg->q->backing_dev_info.dev)
-		return dev_name(blkg->q->backing_dev_info.dev);
-	return NULL;
-}
-
 static void blkio_print_group_conf(struct cftype *cft, struct blkio_group *blkg,
 				   struct seq_file *m)
 {
@@ -1174,116 +1207,6 @@ static int blkiocg_file_read(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
-static int blkio_read_blkg_stats(struct blkio_cgroup *blkcg,
-		struct cftype *cft, struct cgroup_map_cb *cb,
-		enum stat_type type, bool show_total, bool pcpu)
-{
-	struct blkio_group *blkg;
-	struct hlist_node *n;
-	uint64_t cgroup_total = 0;
-
-	spin_lock_irq(&blkcg->lock);
-
-	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
-		const char *dname = blkg_dev_name(blkg);
-		int plid = BLKIOFILE_POLICY(cft->private);
-
-		if (!dname)
-			continue;
-		if (pcpu)
-			cgroup_total += blkio_get_stat_cpu(blkg, plid,
-							   cb, dname, type);
-		else
-			cgroup_total += blkio_get_stat(blkg, plid,
-						       cb, dname, type);
-	}
-	if (show_total)
-		cb->fill(cb, "Total", cgroup_total);
-
-	spin_unlock_irq(&blkcg->lock);
-	return 0;
-}
-
-/* All map kind of cgroup file get serviced by this function */
-static int blkiocg_file_read_map(struct cgroup *cgrp, struct cftype *cft,
-				struct cgroup_map_cb *cb)
-{
-	struct blkio_cgroup *blkcg;
-	enum blkio_policy_id plid = BLKIOFILE_POLICY(cft->private);
-	int name = BLKIOFILE_ATTR(cft->private);
-
-	blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	switch(plid) {
-	case BLKIO_POLICY_PROP:
-		switch(name) {
-		case BLKIO_PROP_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_TIME, 0, 0);
-		case BLKIO_PROP_sectors:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_CPU_SECTORS, 0, 1);
-		case BLKIO_PROP_io_service_bytes:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-					BLKIO_STAT_CPU_SERVICE_BYTES, 1, 1);
-		case BLKIO_PROP_io_serviced:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_CPU_SERVICED, 1, 1);
-		case BLKIO_PROP_io_service_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_SERVICE_TIME, 1, 0);
-		case BLKIO_PROP_io_wait_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_WAIT_TIME, 1, 0);
-		case BLKIO_PROP_io_merged:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_MERGED, 1, 0);
-		case BLKIO_PROP_io_queued:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_QUEUED, 1, 0);
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-		case BLKIO_PROP_unaccounted_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-					BLKIO_STAT_UNACCOUNTED_TIME, 0, 0);
-		case BLKIO_PROP_dequeue:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_DEQUEUE, 0, 0);
-		case BLKIO_PROP_avg_queue_size:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-					BLKIO_STAT_AVG_QUEUE_SIZE, 0, 0);
-		case BLKIO_PROP_group_wait_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-					BLKIO_STAT_GROUP_WAIT_TIME, 0, 0);
-		case BLKIO_PROP_idle_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_IDLE_TIME, 0, 0);
-		case BLKIO_PROP_empty_time:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_EMPTY_TIME, 0, 0);
-#endif
-		default:
-			BUG();
-		}
-		break;
-	case BLKIO_POLICY_THROTL:
-		switch(name){
-		case BLKIO_THROTL_io_service_bytes:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_CPU_SERVICE_BYTES, 1, 1);
-		case BLKIO_THROTL_io_serviced:
-			return blkio_read_blkg_stats(blkcg, cft, cb,
-						BLKIO_STAT_CPU_SERVICED, 1, 1);
-		default:
-			BUG();
-		}
-		break;
-	default:
-		BUG();
-	}
-
-	return 0;
-}
-
 static int blkio_weight_write(struct blkio_cgroup *blkcg, int plid, u64 val)
 {
 	struct blkio_group *blkg;
@@ -1369,51 +1292,51 @@ struct cftype blkio_files[] = {
 	},
 	{
 		.name = "time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, time)),
+		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "sectors",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_sectors),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats_cpu, sectors)),
+		.read_seq_string = blkcg_print_cpu_stat,
 	},
 	{
 		.name = "io_service_bytes",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_io_service_bytes),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats_cpu, service_bytes)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
 	},
 	{
 		.name = "io_serviced",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_io_serviced),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats_cpu, serviced)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
 	},
 	{
 		.name = "io_service_time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_io_service_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, service_time)),
+		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_wait_time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_io_wait_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, wait_time)),
+		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_merged",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_io_merged),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, merged)),
+		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_queued",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_io_queued),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, queued)),
+		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "reset_stats",
@@ -1457,54 +1380,52 @@ struct cftype blkio_files[] = {
 	},
 	{
 		.name = "throttle.io_service_bytes",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
-				BLKIO_THROTL_io_service_bytes),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
+				offsetof(struct blkio_group_stats_cpu, service_bytes)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
 	},
 	{
 		.name = "throttle.io_serviced",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_THROTL,
-				BLKIO_THROTL_io_serviced),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_THROTL,
+				offsetof(struct blkio_group_stats_cpu, serviced)),
+		.read_seq_string = blkcg_print_cpu_rwstat,
 	},
 #endif /* CONFIG_BLK_DEV_THROTTLING */
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 	{
 		.name = "avg_queue_size",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_avg_queue_size),
-		.read_map = blkiocg_file_read_map,
+		.read_seq_string = blkcg_print_avg_queue_size,
 	},
 	{
 		.name = "group_wait_time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_group_wait_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, group_wait_time)),
+		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "idle_time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_idle_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, idle_time)),
+		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "empty_time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_empty_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, empty_time)),
+		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "dequeue",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_dequeue),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, dequeue)),
+		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "unaccounted_time",
-		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
-				BLKIO_PROP_unaccounted_time),
-		.read_map = blkiocg_file_read_map,
+		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
+				offsetof(struct blkio_group_stats, unaccounted_time)),
+		.read_seq_string = blkcg_print_stat,
 	},
 #endif
 	{ }	/* terminate */
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 7578df3..7331d79 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -28,46 +28,10 @@ enum blkio_policy_id {
 
 #ifdef CONFIG_BLK_CGROUP
 
-enum stat_type {
-	/* Number of IOs merged */
-	BLKIO_STAT_MERGED,
-	/* Total time spent (in ns) between request dispatch to the driver and
-	 * request completion for IOs doen by this cgroup. This may not be
-	 * accurate when NCQ is turned on. */
-	BLKIO_STAT_SERVICE_TIME,
-	/* Total time spent waiting in scheduler queue in ns */
-	BLKIO_STAT_WAIT_TIME,
-	/* Number of IOs queued up */
-	BLKIO_STAT_QUEUED,
-
-	/* All the single valued stats go below this */
-	BLKIO_STAT_TIME,
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-	/* Time not charged to this cgroup */
-	BLKIO_STAT_UNACCOUNTED_TIME,
-	BLKIO_STAT_AVG_QUEUE_SIZE,
-	BLKIO_STAT_IDLE_TIME,
-	BLKIO_STAT_EMPTY_TIME,
-	BLKIO_STAT_GROUP_WAIT_TIME,
-	BLKIO_STAT_DEQUEUE
-#endif
-};
-
-/* Types lower than this live in stat_arr and have subtypes */
-#define BLKIO_STAT_ARR_NR	(BLKIO_STAT_QUEUED + 1)
-
-/* Per cpu stats */
-enum stat_type_cpu {
-	/* Total bytes transferred */
-	BLKIO_STAT_CPU_SERVICE_BYTES,
-	/* Total IOs serviced, post merge */
-	BLKIO_STAT_CPU_SERVICED,
-
-	/* All the single valued stats go below this */
-	BLKIO_STAT_CPU_SECTORS,
-};
-
-#define BLKIO_STAT_CPU_ARR_NR	(BLKIO_STAT_CPU_SERVICED + 1)
+/* cft->private [un]packing for stat printing */
+#define BLKCG_STAT_PRIV(pol, off)	(((unsigned)(pol) << 16) | (off))
+#define BLKCG_STAT_POL(prv)		((unsigned)(prv) >> 16)
+#define BLKCG_STAT_OFF(prv)		((unsigned)(prv) & 0xffff)
 
 enum blkg_rwstat_type {
 	BLKG_RWSTAT_READ,
@@ -90,20 +54,6 @@ enum blkg_state_flags {
 enum blkcg_file_name_prop {
 	BLKIO_PROP_weight = 1,
 	BLKIO_PROP_weight_device,
-	BLKIO_PROP_io_service_bytes,
-	BLKIO_PROP_io_serviced,
-	BLKIO_PROP_time,
-	BLKIO_PROP_sectors,
-	BLKIO_PROP_unaccounted_time,
-	BLKIO_PROP_io_service_time,
-	BLKIO_PROP_io_wait_time,
-	BLKIO_PROP_io_merged,
-	BLKIO_PROP_io_queued,
-	BLKIO_PROP_avg_queue_size,
-	BLKIO_PROP_group_wait_time,
-	BLKIO_PROP_idle_time,
-	BLKIO_PROP_empty_time,
-	BLKIO_PROP_dequeue,
 };
 
 /* cgroup files owned by throttle policy */
@@ -112,8 +62,6 @@ enum blkcg_file_name_throtl {
 	BLKIO_THROTL_write_bps_device,
 	BLKIO_THROTL_read_iops_device,
 	BLKIO_THROTL_write_iops_device,
-	BLKIO_THROTL_io_service_bytes,
-	BLKIO_THROTL_io_serviced,
 };
 
 struct blkio_cgroup {
-- 
1.7.7.3
