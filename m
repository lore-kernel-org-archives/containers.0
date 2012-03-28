From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/21] blkcg: introduce blkg_stat and blkg_rwstat
Date: Wed, 28 Mar 2012 15:51:13 -0700
Message-ID: <1332975091-10950-4-git-send-email-tj@kernel.org>
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

blkcg uses u64_stats_sync to avoid reading wrong u64 statistic values
on 32bit archs and some stat counters have subtypes to distinguish
read/writes and sync/async IOs.  The stat code paths are confusing and
involve a lot of going back and forth between blkcg core and specific
policy implementations, and synchronization and subtype handling are
open coded in blkcg core.

This patch introduces struct blkg_stat and blkg_rwstat which, with
accompanying operations, encapsulate stat updating and accessing with
proper synchronization.

blkg_stat is simple u64 counter with 64bit read-access protection.
blkg_rwstat is the one with rw and [a]sync subcounters and takes @rw
flags to distinguish IO subtypes (%REQ_WRITE and %REQ_SYNC) and
replaces stat_sub_type indexed arrays.

All counters in blkio_group_stats and blkio_group_stats_cpu are
replaced with either blkg_stat or blkg_rwstat along with all users.

This does add one u64_stats_sync per counter and increase stats_sync
operations but they're empty/noops on 64bit archs and blkcg doesn't
have too many counters, especially with DEBUG_BLK_CGROUP off.

While the currently resulting code isn't necessarily simpler at the
moment, this will enable further clean up of blkcg stats code.

- BLKIO_STAT_{READ|WRITE|SYNC|ASYNC|TOTAL} renamed to
  BLKG_RWSTAT_{READ|WRITE|SYNC|ASYNC|TOTAL}.

- blkg_stat_add() replaces blkio_add_stat() and
  blkio_check_and_dec_stat().  Note that BUG_ON() on underflow in the
  latter function no longer exists.  It's *way* better to have
  underflowed stat counters than oopsing.

- blkio_group_stats->dequeue is now a proper u64 stat counter instead
  of ulong.

- reset_stats() updated to clear each stat counters individually and
  BLKG_STATS_DEBUG_CLEAR_{START|SIZE} are removed.

- Some functions reconstruct rw flags from direction and sync
  booleans.  This will be removed by future patches.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |  289 +++++++++++++++++++++++-----------------------------
 block/blk-cgroup.h |  211 ++++++++++++++++++++++++++++++--------
 2 files changed, 293 insertions(+), 207 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index d4cf77d..153a2db 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -132,46 +132,6 @@ static inline void blkio_update_group_iops(struct blkio_group *blkg,
 	}
 }
 
-/*
- * Add to the appropriate stat variable depending on the request type.
- * This should be called with queue_lock held.
- */
-static void blkio_add_stat(uint64_t *stat, uint64_t add, bool direction,
-				bool sync)
-{
-	if (direction)
-		stat[BLKIO_STAT_WRITE] += add;
-	else
-		stat[BLKIO_STAT_READ] += add;
-	if (sync)
-		stat[BLKIO_STAT_SYNC] += add;
-	else
-		stat[BLKIO_STAT_ASYNC] += add;
-}
-
-/*
- * Decrements the appropriate stat variable if non-zero depending on the
- * request type. Panics on value being zero.
- * This should be called with the queue_lock held.
- */
-static void blkio_check_and_dec_stat(uint64_t *stat, bool direction, bool sync)
-{
-	if (direction) {
-		BUG_ON(stat[BLKIO_STAT_WRITE] == 0);
-		stat[BLKIO_STAT_WRITE]--;
-	} else {
-		BUG_ON(stat[BLKIO_STAT_READ] == 0);
-		stat[BLKIO_STAT_READ]--;
-	}
-	if (sync) {
-		BUG_ON(stat[BLKIO_STAT_SYNC] == 0);
-		stat[BLKIO_STAT_SYNC]--;
-	} else {
-		BUG_ON(stat[BLKIO_STAT_ASYNC] == 0);
-		stat[BLKIO_STAT_ASYNC]--;
-	}
-}
-
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 /* This should be called with the queue_lock held. */
 static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
@@ -198,7 +158,8 @@ static void blkio_update_group_wait_time(struct blkio_group_stats *stats)
 
 	now = sched_clock();
 	if (time_after64(now, stats->start_group_wait_time))
-		stats->group_wait_time += now - stats->start_group_wait_time;
+		blkg_stat_add(&stats->group_wait_time,
+			      now - stats->start_group_wait_time);
 	blkio_clear_blkg_waiting(stats);
 }
 
@@ -212,7 +173,8 @@ static void blkio_end_empty_time(struct blkio_group_stats *stats)
 
 	now = sched_clock();
 	if (time_after64(now, stats->start_empty_time))
-		stats->empty_time += now - stats->start_empty_time;
+		blkg_stat_add(&stats->empty_time,
+			      now - stats->start_empty_time);
 	blkio_clear_blkg_empty(stats);
 }
 
@@ -239,11 +201,9 @@ void blkiocg_update_idle_time_stats(struct blkio_group *blkg,
 	if (blkio_blkg_idling(stats)) {
 		unsigned long long now = sched_clock();
 
-		if (time_after64(now, stats->start_idle_time)) {
-			u64_stats_update_begin(&stats->syncp);
-			stats->idle_time += now - stats->start_idle_time;
-			u64_stats_update_end(&stats->syncp);
-		}
+		if (time_after64(now, stats->start_idle_time))
+			blkg_stat_add(&stats->idle_time,
+				      now - stats->start_idle_time);
 		blkio_clear_blkg_idling(stats);
 	}
 }
@@ -256,13 +216,10 @@ void blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	u64_stats_update_begin(&stats->syncp);
-	stats->avg_queue_size_sum +=
-			stats->stat_arr[BLKIO_STAT_QUEUED][BLKIO_STAT_READ] +
-			stats->stat_arr[BLKIO_STAT_QUEUED][BLKIO_STAT_WRITE];
-	stats->avg_queue_size_samples++;
+	blkg_stat_add(&stats->avg_queue_size_sum,
+		      blkg_rwstat_sum(&stats->queued));
+	blkg_stat_add(&stats->avg_queue_size_samples, 1);
 	blkio_update_group_wait_time(stats);
-	u64_stats_update_end(&stats->syncp);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_avg_queue_size_stats);
 
@@ -273,8 +230,7 @@ void blkiocg_set_start_empty_time(struct blkio_group *blkg,
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	if (stats->stat_arr[BLKIO_STAT_QUEUED][BLKIO_STAT_READ] ||
-			stats->stat_arr[BLKIO_STAT_QUEUED][BLKIO_STAT_WRITE])
+	if (blkg_rwstat_sum(&stats->queued))
 		return;
 
 	/*
@@ -298,7 +254,7 @@ void blkiocg_update_dequeue_stats(struct blkio_group *blkg,
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	pd->stats.dequeue += dequeue;
+	blkg_stat_add(&pd->stats.dequeue, dequeue);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_dequeue_stats);
 #else
@@ -314,14 +270,12 @@ void blkiocg_update_io_add_stats(struct blkio_group *blkg,
 				 bool sync)
 {
 	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	u64_stats_update_begin(&stats->syncp);
-	blkio_add_stat(stats->stat_arr[BLKIO_STAT_QUEUED], 1, direction, sync);
+	blkg_rwstat_add(&stats->queued, rw, 1);
 	blkio_end_empty_time(stats);
-	u64_stats_update_end(&stats->syncp);
-
 	blkio_set_start_group_wait_time(blkg, pol, curr_blkg);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_io_add_stats);
@@ -331,13 +285,11 @@ void blkiocg_update_io_remove_stats(struct blkio_group *blkg,
 				    bool direction, bool sync)
 {
 	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	u64_stats_update_begin(&stats->syncp);
-	blkio_check_and_dec_stat(stats->stat_arr[BLKIO_STAT_QUEUED], direction,
-				 sync);
-	u64_stats_update_end(&stats->syncp);
+	blkg_rwstat_add(&stats->queued, rw, -1);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_io_remove_stats);
 
@@ -350,12 +302,10 @@ void blkiocg_update_timeslice_used(struct blkio_group *blkg,
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	u64_stats_update_begin(&stats->syncp);
-	stats->time += time;
+	blkg_stat_add(&stats->time, time);
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-	stats->unaccounted_time += unaccounted_time;
+	blkg_stat_add(&stats->unaccounted_time, unaccounted_time);
 #endif
-	u64_stats_update_end(&stats->syncp);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_timeslice_used);
 
@@ -367,6 +317,7 @@ void blkiocg_update_dispatch_stats(struct blkio_group *blkg,
 				   struct blkio_policy_type *pol,
 				   uint64_t bytes, bool direction, bool sync)
 {
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 	struct blkg_policy_data *pd = blkg->pd[pol->plid];
 	struct blkio_group_stats_cpu *stats_cpu;
 	unsigned long flags;
@@ -384,13 +335,10 @@ void blkiocg_update_dispatch_stats(struct blkio_group *blkg,
 
 	stats_cpu = this_cpu_ptr(pd->stats_cpu);
 
-	u64_stats_update_begin(&stats_cpu->syncp);
-	stats_cpu->sectors += bytes >> 9;
-	blkio_add_stat(stats_cpu->stat_arr_cpu[BLKIO_STAT_CPU_SERVICED],
-			1, direction, sync);
-	blkio_add_stat(stats_cpu->stat_arr_cpu[BLKIO_STAT_CPU_SERVICE_BYTES],
-			bytes, direction, sync);
-	u64_stats_update_end(&stats_cpu->syncp);
+	blkg_stat_add(&stats_cpu->sectors, bytes >> 9);
+	blkg_rwstat_add(&stats_cpu->serviced, rw, 1);
+	blkg_rwstat_add(&stats_cpu->service_bytes, rw, bytes);
+
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_dispatch_stats);
@@ -403,17 +351,15 @@ void blkiocg_update_completion_stats(struct blkio_group *blkg,
 {
 	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
 	unsigned long long now = sched_clock();
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	u64_stats_update_begin(&stats->syncp);
 	if (time_after64(now, io_start_time))
-		blkio_add_stat(stats->stat_arr[BLKIO_STAT_SERVICE_TIME],
-				now - io_start_time, direction, sync);
+		blkg_rwstat_add(&stats->service_time, rw, now - io_start_time);
 	if (time_after64(io_start_time, start_time))
-		blkio_add_stat(stats->stat_arr[BLKIO_STAT_WAIT_TIME],
-				io_start_time - start_time, direction, sync);
-	u64_stats_update_end(&stats->syncp);
+		blkg_rwstat_add(&stats->wait_time, rw,
+				io_start_time - start_time);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_completion_stats);
 
@@ -423,12 +369,11 @@ void blkiocg_update_io_merged_stats(struct blkio_group *blkg,
 				    bool direction, bool sync)
 {
 	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 
 	lockdep_assert_held(blkg->q->queue_lock);
 
-	u64_stats_update_begin(&stats->syncp);
-	blkio_add_stat(stats->stat_arr[BLKIO_STAT_MERGED], 1, direction, sync);
-	u64_stats_update_end(&stats->syncp);
+	blkg_rwstat_add(&stats->merged, rw, 1);
 }
 EXPORT_SYMBOL_GPL(blkiocg_update_io_merged_stats);
 
@@ -757,8 +702,9 @@ static void blkio_reset_stats_cpu(struct blkio_group *blkg, int plid)
 		struct blkio_group_stats_cpu *sc =
 			per_cpu_ptr(pd->stats_cpu, cpu);
 
-		sc->sectors = 0;
-		memset(sc->stat_arr_cpu, 0, sizeof(sc->stat_arr_cpu));
+		blkg_rwstat_reset(&sc->service_bytes);
+		blkg_rwstat_reset(&sc->serviced);
+		blkg_stat_reset(&sc->sectors);
 	}
 }
 
@@ -768,7 +714,6 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgroup);
 	struct blkio_group *blkg;
 	struct hlist_node *n;
-	int i;
 
 	spin_lock(&blkio_list_lock);
 	spin_lock_irq(&blkcg->lock);
@@ -786,14 +731,18 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 			struct blkio_group_stats *stats = &pd->stats;
 
 			/* queued stats shouldn't be cleared */
-			for (i = 0; i < ARRAY_SIZE(stats->stat_arr); i++)
-				if (i != BLKIO_STAT_QUEUED)
-					memset(stats->stat_arr[i], 0,
-					       sizeof(stats->stat_arr[i]));
-			stats->time = 0;
+			blkg_rwstat_reset(&stats->merged);
+			blkg_rwstat_reset(&stats->service_time);
+			blkg_rwstat_reset(&stats->wait_time);
+			blkg_stat_reset(&stats->time);
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-			memset((void *)stats + BLKG_STATS_DEBUG_CLEAR_START, 0,
-			       BLKG_STATS_DEBUG_CLEAR_SIZE);
+			blkg_stat_reset(&stats->unaccounted_time);
+			blkg_stat_reset(&stats->avg_queue_size_sum);
+			blkg_stat_reset(&stats->avg_queue_size_samples);
+			blkg_stat_reset(&stats->dequeue);
+			blkg_stat_reset(&stats->group_wait_time);
+			blkg_stat_reset(&stats->idle_time);
+			blkg_stat_reset(&stats->empty_time);
 #endif
 			blkio_reset_stats_cpu(blkg, pol->plid);
 		}
@@ -804,7 +753,7 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 	return 0;
 }
 
-static void blkio_get_key_name(enum stat_sub_type type, const char *dname,
+static void blkio_get_key_name(enum blkg_rwstat_type type, const char *dname,
 			       char *str, int chars_left, bool diskname_only)
 {
 	snprintf(str, chars_left, "%s", dname);
@@ -817,19 +766,19 @@ static void blkio_get_key_name(enum stat_sub_type type, const char *dname,
 	if (diskname_only)
 		return;
 	switch (type) {
-	case BLKIO_STAT_READ:
+	case BLKG_RWSTAT_READ:
 		strlcat(str, " Read", chars_left);
 		break;
-	case BLKIO_STAT_WRITE:
+	case BLKG_RWSTAT_WRITE:
 		strlcat(str, " Write", chars_left);
 		break;
-	case BLKIO_STAT_SYNC:
+	case BLKG_RWSTAT_SYNC:
 		strlcat(str, " Sync", chars_left);
 		break;
-	case BLKIO_STAT_ASYNC:
+	case BLKG_RWSTAT_ASYNC:
 		strlcat(str, " Async", chars_left);
 		break;
-	case BLKIO_STAT_TOTAL:
+	case BLKG_RWSTAT_TOTAL:
 		strlcat(str, " Total", chars_left);
 		break;
 	default:
@@ -838,29 +787,34 @@ static void blkio_get_key_name(enum stat_sub_type type, const char *dname,
 }
 
 static uint64_t blkio_read_stat_cpu(struct blkio_group *blkg, int plid,
-			enum stat_type_cpu type, enum stat_sub_type sub_type)
+				    enum stat_type_cpu type,
+				    enum blkg_rwstat_type sub_type)
 {
 	struct blkg_policy_data *pd = blkg->pd[plid];
+	u64 val = 0;
 	int cpu;
-	struct blkio_group_stats_cpu *stats_cpu;
-	u64 val = 0, tval;
 
 	if (pd->stats_cpu == NULL)
 		return val;
 
 	for_each_possible_cpu(cpu) {
-		unsigned int start;
-		stats_cpu = per_cpu_ptr(pd->stats_cpu, cpu);
-
-		do {
-			start = u64_stats_fetch_begin(&stats_cpu->syncp);
-			if (type == BLKIO_STAT_CPU_SECTORS)
-				tval = stats_cpu->sectors;
-			else
-				tval = stats_cpu->stat_arr_cpu[type][sub_type];
-		} while(u64_stats_fetch_retry(&stats_cpu->syncp, start));
-
-		val += tval;
+		struct blkio_group_stats_cpu *stats_cpu =
+			per_cpu_ptr(pd->stats_cpu, cpu);
+		struct blkg_rwstat rws;
+
+		switch (type) {
+		case BLKIO_STAT_CPU_SECTORS:
+			val += blkg_stat_read(&stats_cpu->sectors);
+			break;
+		case BLKIO_STAT_CPU_SERVICE_BYTES:
+			rws = blkg_rwstat_read(&stats_cpu->service_bytes);
+			val += rws.cnt[sub_type];
+			break;
+		case BLKIO_STAT_CPU_SERVICED:
+			rws = blkg_rwstat_read(&stats_cpu->serviced);
+			val += rws.cnt[sub_type];
+			break;
+		}
 	}
 
 	return val;
@@ -872,7 +826,7 @@ static uint64_t blkio_get_stat_cpu(struct blkio_group *blkg, int plid,
 {
 	uint64_t disk_total, val;
 	char key_str[MAX_KEY_LEN];
-	enum stat_sub_type sub_type;
+	enum blkg_rwstat_type sub_type;
 
 	if (type == BLKIO_STAT_CPU_SECTORS) {
 		val = blkio_read_stat_cpu(blkg, plid, type, 0);
@@ -881,7 +835,7 @@ static uint64_t blkio_get_stat_cpu(struct blkio_group *blkg, int plid,
 		return val;
 	}
 
-	for (sub_type = BLKIO_STAT_READ; sub_type < BLKIO_STAT_TOTAL;
+	for (sub_type = BLKG_RWSTAT_READ; sub_type < BLKG_RWSTAT_NR;
 			sub_type++) {
 		blkio_get_key_name(sub_type, dname, key_str, MAX_KEY_LEN,
 				   false);
@@ -889,10 +843,10 @@ static uint64_t blkio_get_stat_cpu(struct blkio_group *blkg, int plid,
 		cb->fill(cb, key_str, val);
 	}
 
-	disk_total = blkio_read_stat_cpu(blkg, plid, type, BLKIO_STAT_READ) +
-		blkio_read_stat_cpu(blkg, plid, type, BLKIO_STAT_WRITE);
+	disk_total = blkio_read_stat_cpu(blkg, plid, type, BLKG_RWSTAT_READ) +
+		blkio_read_stat_cpu(blkg, plid, type, BLKG_RWSTAT_WRITE);
 
-	blkio_get_key_name(BLKIO_STAT_TOTAL, dname, key_str, MAX_KEY_LEN,
+	blkio_get_key_name(BLKG_RWSTAT_TOTAL, dname, key_str, MAX_KEY_LEN,
 			   false);
 	cb->fill(cb, key_str, disk_total);
 	return disk_total;
@@ -905,65 +859,76 @@ static uint64_t blkio_get_stat(struct blkio_group *blkg, int plid,
 	struct blkio_group_stats *stats = &blkg->pd[plid]->stats;
 	uint64_t v = 0, disk_total = 0;
 	char key_str[MAX_KEY_LEN];
-	unsigned int sync_start;
+	struct blkg_rwstat rws = { };
 	int st;
 
 	if (type >= BLKIO_STAT_ARR_NR) {
-		do {
-			sync_start = u64_stats_fetch_begin(&stats->syncp);
-			switch (type) {
-			case BLKIO_STAT_TIME:
-				v = stats->time;
-				break;
+		switch (type) {
+		case BLKIO_STAT_TIME:
+			v = blkg_stat_read(&stats->time);
+			break;
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-			case BLKIO_STAT_UNACCOUNTED_TIME:
-				v = stats->unaccounted_time;
-				break;
-			case BLKIO_STAT_AVG_QUEUE_SIZE: {
-				uint64_t samples = stats->avg_queue_size_samples;
+		case BLKIO_STAT_UNACCOUNTED_TIME:
+			v = blkg_stat_read(&stats->unaccounted_time);
+			break;
+		case BLKIO_STAT_AVG_QUEUE_SIZE: {
+			uint64_t samples;
 
-				if (samples) {
-					v = stats->avg_queue_size_sum;
-					do_div(v, samples);
-				}
-				break;
+			samples = blkg_stat_read(&stats->avg_queue_size_samples);
+			if (samples) {
+				v = blkg_stat_read(&stats->avg_queue_size_sum);
+				do_div(v, samples);
 			}
-			case BLKIO_STAT_IDLE_TIME:
-				v = stats->idle_time;
-				break;
-			case BLKIO_STAT_EMPTY_TIME:
-				v = stats->empty_time;
-				break;
-			case BLKIO_STAT_DEQUEUE:
-				v = stats->dequeue;
-				break;
-			case BLKIO_STAT_GROUP_WAIT_TIME:
-				v = stats->group_wait_time;
-				break;
+			break;
+		}
+		case BLKIO_STAT_IDLE_TIME:
+			v = blkg_stat_read(&stats->idle_time);
+			break;
+		case BLKIO_STAT_EMPTY_TIME:
+			v = blkg_stat_read(&stats->empty_time);
+			break;
+		case BLKIO_STAT_DEQUEUE:
+			v = blkg_stat_read(&stats->dequeue);
+			break;
+		case BLKIO_STAT_GROUP_WAIT_TIME:
+			v = blkg_stat_read(&stats->group_wait_time);
+			break;
 #endif
-			default:
-				WARN_ON_ONCE(1);
-			}
-		} while (u64_stats_fetch_retry(&stats->syncp, sync_start));
+		default:
+			WARN_ON_ONCE(1);
+		}
 
 		blkio_get_key_name(0, dname, key_str, MAX_KEY_LEN, true);
 		cb->fill(cb, key_str, v);
 		return v;
 	}
 
-	for (st = BLKIO_STAT_READ; st < BLKIO_STAT_TOTAL; st++) {
-		do {
-			sync_start = u64_stats_fetch_begin(&stats->syncp);
-			v = stats->stat_arr[type][st];
-		} while (u64_stats_fetch_retry(&stats->syncp, sync_start));
+	switch (type) {
+	case BLKIO_STAT_MERGED:
+		rws = blkg_rwstat_read(&stats->merged);
+		break;
+	case BLKIO_STAT_SERVICE_TIME:
+		rws = blkg_rwstat_read(&stats->service_time);
+		break;
+	case BLKIO_STAT_WAIT_TIME:
+		rws = blkg_rwstat_read(&stats->wait_time);
+		break;
+	case BLKIO_STAT_QUEUED:
+		rws = blkg_rwstat_read(&stats->queued);
+		break;
+	default:
+		WARN_ON_ONCE(true);
+		break;
+	}
 
+	for (st = BLKG_RWSTAT_READ; st < BLKG_RWSTAT_NR; st++) {
 		blkio_get_key_name(st, dname, key_str, MAX_KEY_LEN, false);
-		cb->fill(cb, key_str, v);
-		if (st == BLKIO_STAT_READ || st == BLKIO_STAT_WRITE)
-			disk_total += v;
+		cb->fill(cb, key_str, rws.cnt[st]);
+		if (st == BLKG_RWSTAT_READ || st == BLKG_RWSTAT_WRITE)
+			disk_total += rws.cnt[st];
 	}
 
-	blkio_get_key_name(BLKIO_STAT_TOTAL, dname, key_str, MAX_KEY_LEN,
+	blkio_get_key_name(BLKG_RWSTAT_TOTAL, dname, key_str, MAX_KEY_LEN,
 			   false);
 	cb->fill(cb, key_str, disk_total);
 	return disk_total;
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 2060d81..7578df3 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -69,12 +69,14 @@ enum stat_type_cpu {
 
 #define BLKIO_STAT_CPU_ARR_NR	(BLKIO_STAT_CPU_SERVICED + 1)
 
-enum stat_sub_type {
-	BLKIO_STAT_READ = 0,
-	BLKIO_STAT_WRITE,
-	BLKIO_STAT_SYNC,
-	BLKIO_STAT_ASYNC,
-	BLKIO_STAT_TOTAL
+enum blkg_rwstat_type {
+	BLKG_RWSTAT_READ,
+	BLKG_RWSTAT_WRITE,
+	BLKG_RWSTAT_SYNC,
+	BLKG_RWSTAT_ASYNC,
+
+	BLKG_RWSTAT_NR,
+	BLKG_RWSTAT_TOTAL = BLKG_RWSTAT_NR,
 };
 
 /* blkg state flags */
@@ -124,54 +126,58 @@ struct blkio_cgroup {
 	uint64_t id;
 };
 
+struct blkg_stat {
+	struct u64_stats_sync		syncp;
+	uint64_t			cnt;
+};
+
+struct blkg_rwstat {
+	struct u64_stats_sync		syncp;
+	uint64_t			cnt[BLKG_RWSTAT_NR];
+};
+
 struct blkio_group_stats {
-	struct u64_stats_sync syncp;
+	/* number of ios merged */
+	struct blkg_rwstat		merged;
+	/* total time spent on device in ns, may not be accurate w/ queueing */
+	struct blkg_rwstat		service_time;
+	/* total time spent waiting in scheduler queue in ns */
+	struct blkg_rwstat		wait_time;
+	/* number of IOs queued up */
+	struct blkg_rwstat		queued;
 	/* total disk time and nr sectors dispatched by this group */
-	uint64_t time;
-	uint64_t stat_arr[BLKIO_STAT_ARR_NR][BLKIO_STAT_TOTAL];
+	struct blkg_stat		time;
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-	/* Time not charged to this cgroup */
-	uint64_t unaccounted_time;
-
-	/* Sum of number of IOs queued across all samples */
-	uint64_t avg_queue_size_sum;
-	/* Count of samples taken for average */
-	uint64_t avg_queue_size_samples;
-	/* How many times this group has been removed from service tree */
-	unsigned long dequeue;
-
-	/* Total time spent waiting for it to be assigned a timeslice. */
-	uint64_t group_wait_time;
-
-	/* Time spent idling for this blkio_group */
-	uint64_t idle_time;
-	/*
-	 * Total time when we have requests queued and do not contain the
-	 * current active queue.
-	 */
-	uint64_t empty_time;
-
+	/* time not charged to this cgroup */
+	struct blkg_stat		unaccounted_time;
+	/* sum of number of ios queued across all samples */
+	struct blkg_stat		avg_queue_size_sum;
+	/* count of samples taken for average */
+	struct blkg_stat		avg_queue_size_samples;
+	/* how many times this group has been removed from service tree */
+	struct blkg_stat		dequeue;
+	/* total time spent waiting for it to be assigned a timeslice. */
+	struct blkg_stat		group_wait_time;
+	/* time spent idling for this blkio_group */
+	struct blkg_stat		idle_time;
+	/* total time with empty current active q with other requests queued */
+	struct blkg_stat		empty_time;
 	/* fields after this shouldn't be cleared on stat reset */
-	uint64_t start_group_wait_time;
-	uint64_t start_idle_time;
-	uint64_t start_empty_time;
-	uint16_t flags;
+	uint64_t			start_group_wait_time;
+	uint64_t			start_idle_time;
+	uint64_t			start_empty_time;
+	uint16_t			flags;
 #endif
 };
 
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-#define BLKG_STATS_DEBUG_CLEAR_START	\
-	offsetof(struct blkio_group_stats, unaccounted_time)
-#define BLKG_STATS_DEBUG_CLEAR_SIZE	\
-	(offsetof(struct blkio_group_stats, start_group_wait_time) - \
-	 BLKG_STATS_DEBUG_CLEAR_START)
-#endif
-
 /* Per cpu blkio group stats */
 struct blkio_group_stats_cpu {
-	uint64_t sectors;
-	uint64_t stat_arr_cpu[BLKIO_STAT_CPU_ARR_NR][BLKIO_STAT_TOTAL];
-	struct u64_stats_sync syncp;
+	/* total bytes transferred */
+	struct blkg_rwstat		service_bytes;
+	/* total IOs serviced, post merge */
+	struct blkg_rwstat		serviced;
+	/* total sectors transferred */
+	struct blkg_stat		sectors;
 };
 
 struct blkio_group_conf {
@@ -316,6 +322,121 @@ static inline void blkg_put(struct blkio_group *blkg)
 		__blkg_release(blkg);
 }
 
+/**
+ * blkg_stat_add - add a value to a blkg_stat
+ * @stat: target blkg_stat
+ * @val: value to add
+ *
+ * Add @val to @stat.  The caller is responsible for synchronizing calls to
+ * this function.
+ */
+static inline void blkg_stat_add(struct blkg_stat *stat, uint64_t val)
+{
+	u64_stats_update_begin(&stat->syncp);
+	stat->cnt += val;
+	u64_stats_update_end(&stat->syncp);
+}
+
+/**
+ * blkg_stat_read - read the current value of a blkg_stat
+ * @stat: blkg_stat to read
+ *
+ * Read the current value of @stat.  This function can be called without
+ * synchroniztion and takes care of u64 atomicity.
+ */
+static inline uint64_t blkg_stat_read(struct blkg_stat *stat)
+{
+	unsigned int start;
+	uint64_t v;
+
+	do {
+		start = u64_stats_fetch_begin(&stat->syncp);
+		v = stat->cnt;
+	} while (u64_stats_fetch_retry(&stat->syncp, start));
+
+	return v;
+}
+
+/**
+ * blkg_stat_reset - reset a blkg_stat
+ * @stat: blkg_stat to reset
+ */
+static inline void blkg_stat_reset(struct blkg_stat *stat)
+{
+	stat->cnt = 0;
+}
+
+/**
+ * blkg_rwstat_add - add a value to a blkg_rwstat
+ * @rwstat: target blkg_rwstat
+ * @rw: mask of REQ_{WRITE|SYNC}
+ * @val: value to add
+ *
+ * Add @val to @rwstat.  The counters are chosen according to @rw.  The
+ * caller is responsible for synchronizing calls to this function.
+ */
+static inline void blkg_rwstat_add(struct blkg_rwstat *rwstat,
+				   int rw, uint64_t val)
+{
+	u64_stats_update_begin(&rwstat->syncp);
+
+	if (rw & REQ_WRITE)
+		rwstat->cnt[BLKG_RWSTAT_WRITE] += val;
+	else
+		rwstat->cnt[BLKG_RWSTAT_READ] += val;
+	if (rw & REQ_SYNC)
+		rwstat->cnt[BLKG_RWSTAT_SYNC] += val;
+	else
+		rwstat->cnt[BLKG_RWSTAT_ASYNC] += val;
+
+	u64_stats_update_end(&rwstat->syncp);
+}
+
+/**
+ * blkg_rwstat_read - read the current values of a blkg_rwstat
+ * @rwstat: blkg_rwstat to read
+ *
+ * Read the current snapshot of @rwstat and return it as the return value.
+ * This function can be called without synchronization and takes care of
+ * u64 atomicity.
+ */
+static struct blkg_rwstat blkg_rwstat_read(struct blkg_rwstat *rwstat)
+{
+	unsigned int start;
+	struct blkg_rwstat tmp;
+
+	do {
+		start = u64_stats_fetch_begin(&rwstat->syncp);
+		tmp = *rwstat;
+	} while (u64_stats_fetch_retry(&rwstat->syncp, start));
+
+	return tmp;
+}
+
+/**
+ * blkg_rwstat_sum - read the total count of a blkg_rwstat
+ * @rwstat: blkg_rwstat to read
+ *
+ * Return the total count of @rwstat regardless of the IO direction.  This
+ * function can be called without synchronization and takes care of u64
+ * atomicity.
+ */
+static inline uint64_t blkg_rwstat_sum(struct blkg_rwstat *rwstat)
+{
+	struct blkg_rwstat tmp = blkg_rwstat_read(rwstat);
+
+	return tmp.cnt[BLKG_RWSTAT_READ] + tmp.cnt[BLKG_RWSTAT_WRITE];
+}
+
+/**
+ * blkg_rwstat_reset - reset a blkg_rwstat
+ * @rwstat: blkg_rwstat to reset
+ */
+static inline void blkg_rwstat_reset(struct blkg_rwstat *rwstat)
+{
+	memset(rwstat->cnt, 0, sizeof(rwstat->cnt));
+}
+
 #else
 
 struct blkio_group {
-- 
1.7.7.3
