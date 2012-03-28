From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 16/21] blkcg: move blkio_group_stats to cfq-iosched.c
Date: Wed, 28 Mar 2012 15:51:26 -0700
Message-ID: <1332975091-10950-17-git-send-email-tj@kernel.org>
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

blkio_group_stats contains only fields used by cfq and has no reason
to be defined in blkcg core.

* Move blkio_group_stats to cfq-iosched.c and rename it to cfqg_stats.

* blkg_policy_data->stats is replaced with cfq_group->stats.
  blkg_prfill_[rw]stat() are updated to use offset against pd->pdata
  instead.

* All related macros / functions are renamed so that they have cfqg_
  prefix and the unnecessary @pol arguments are dropped.

* All stat functions now take cfq_group * instead of blkio_group *.

* lockdep assertion on queue lock dropped.  Elevator runs under queue
  lock by default.  There isn't much to be gained by adding lockdep
  assertions at stat function level.

* cfqg_stats_reset() implemented for blkio_reset_group_stats_fn method
  so that cfqg->stats can be reset.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c  |   23 +---
 block/blk-cgroup.h  |   41 -----
 block/cfq-iosched.c |  407 ++++++++++++++++++++++++---------------------------
 3 files changed, 193 insertions(+), 278 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index e4848ee..d7c7f17 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -417,25 +417,6 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 		struct blkio_policy_type *pol;
 
 		list_for_each_entry(pol, &blkio_list, list) {
-			struct blkg_policy_data *pd = blkg->pd[pol->plid];
-			struct blkio_group_stats *stats = &pd->stats;
-
-			/* queued stats shouldn't be cleared */
-			blkg_rwstat_reset(&stats->service_bytes);
-			blkg_rwstat_reset(&stats->serviced);
-			blkg_rwstat_reset(&stats->merged);
-			blkg_rwstat_reset(&stats->service_time);
-			blkg_rwstat_reset(&stats->wait_time);
-			blkg_stat_reset(&stats->time);
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-			blkg_stat_reset(&stats->unaccounted_time);
-			blkg_stat_reset(&stats->avg_queue_size_sum);
-			blkg_stat_reset(&stats->avg_queue_size_samples);
-			blkg_stat_reset(&stats->dequeue);
-			blkg_stat_reset(&stats->group_wait_time);
-			blkg_stat_reset(&stats->idle_time);
-			blkg_stat_reset(&stats->empty_time);
-#endif
 			blkio_reset_stats_cpu(blkg, pol->plid);
 
 			if (pol->ops.blkio_reset_group_stats_fn)
@@ -549,13 +530,13 @@ static u64 blkg_prfill_stat(struct seq_file *sf, struct blkg_policy_data *pd,
 			    int off)
 {
 	return __blkg_prfill_u64(sf, pd,
-				 blkg_stat_read((void *)&pd->stats + off));
+				 blkg_stat_read((void *)pd->pdata + off));
 }
 
 static u64 blkg_prfill_rwstat(struct seq_file *sf, struct blkg_policy_data *pd,
 			      int off)
 {
-	struct blkg_rwstat rwstat = blkg_rwstat_read((void *)&pd->stats + off);
+	struct blkg_rwstat rwstat = blkg_rwstat_read((void *)pd->pdata + off);
 
 	return __blkg_prfill_rwstat(sf, pd, &rwstat);
 }
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index d0ee649..791570394 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -64,46 +64,6 @@ struct blkg_rwstat {
 	uint64_t			cnt[BLKG_RWSTAT_NR];
 };
 
-struct blkio_group_stats {
-	/* total bytes transferred */
-	struct blkg_rwstat		service_bytes;
-	/* total IOs serviced, post merge */
-	struct blkg_rwstat		serviced;
-	/* number of ios merged */
-	struct blkg_rwstat		merged;
-	/* total time spent on device in ns, may not be accurate w/ queueing */
-	struct blkg_rwstat		service_time;
-	/* total time spent waiting in scheduler queue in ns */
-	struct blkg_rwstat		wait_time;
-	/* number of IOs queued up */
-	struct blkg_rwstat		queued;
-	/* total sectors transferred */
-	struct blkg_stat		sectors;
-	/* total disk time and nr sectors dispatched by this group */
-	struct blkg_stat		time;
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-	/* time not charged to this cgroup */
-	struct blkg_stat		unaccounted_time;
-	/* sum of number of ios queued across all samples */
-	struct blkg_stat		avg_queue_size_sum;
-	/* count of samples taken for average */
-	struct blkg_stat		avg_queue_size_samples;
-	/* how many times this group has been removed from service tree */
-	struct blkg_stat		dequeue;
-	/* total time spent waiting for it to be assigned a timeslice. */
-	struct blkg_stat		group_wait_time;
-	/* time spent idling for this blkio_group */
-	struct blkg_stat		idle_time;
-	/* total time with empty current active q with other requests queued */
-	struct blkg_stat		empty_time;
-	/* fields after this shouldn't be cleared on stat reset */
-	uint64_t			start_group_wait_time;
-	uint64_t			start_idle_time;
-	uint64_t			start_empty_time;
-	uint16_t			flags;
-#endif
-};
-
 /* Per cpu blkio group stats */
 struct blkio_group_stats_cpu {
 	/* total bytes transferred */
@@ -126,7 +86,6 @@ struct blkg_policy_data {
 	/* Configuration */
 	struct blkio_group_conf conf;
 
-	struct blkio_group_stats stats;
 	/* Per cpu stats pointer */
 	struct blkio_group_stats_cpu __percpu *stats_cpu;
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index effd894..a1f37df 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -173,6 +173,48 @@ enum wl_type_t {
 	SYNC_WORKLOAD = 2
 };
 
+struct cfqg_stats {
+#ifdef CONFIG_CFQ_GROUP_IOSCHED
+	/* total bytes transferred */
+	struct blkg_rwstat		service_bytes;
+	/* total IOs serviced, post merge */
+	struct blkg_rwstat		serviced;
+	/* number of ios merged */
+	struct blkg_rwstat		merged;
+	/* total time spent on device in ns, may not be accurate w/ queueing */
+	struct blkg_rwstat		service_time;
+	/* total time spent waiting in scheduler queue in ns */
+	struct blkg_rwstat		wait_time;
+	/* number of IOs queued up */
+	struct blkg_rwstat		queued;
+	/* total sectors transferred */
+	struct blkg_stat		sectors;
+	/* total disk time and nr sectors dispatched by this group */
+	struct blkg_stat		time;
+#ifdef CONFIG_DEBUG_BLK_CGROUP
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
+	/* fields after this shouldn't be cleared on stat reset */
+	uint64_t			start_group_wait_time;
+	uint64_t			start_idle_time;
+	uint64_t			start_empty_time;
+	uint16_t			flags;
+#endif	/* CONFIG_DEBUG_BLK_CGROUP */
+#endif	/* CONFIG_CFQ_GROUP_IOSCHED */
+};
+
 /* This is per cgroup per device grouping structure */
 struct cfq_group {
 	/* group service_tree member */
@@ -212,6 +254,7 @@ struct cfq_group {
 	/* number of requests that are on the dispatch list or inside driver */
 	int dispatched;
 	struct cfq_ttime ttime;
+	struct cfqg_stats stats;
 };
 
 struct cfq_io_cq {
@@ -368,96 +411,84 @@ CFQ_CFQQ_FNS(wait_busy);
 
 #if defined(CONFIG_CFQ_GROUP_IOSCHED) && defined(CONFIG_DEBUG_BLK_CGROUP)
 
-/* blkg state flags */
-enum blkg_state_flags {
-	BLKG_waiting = 0,
-	BLKG_idling,
-	BLKG_empty,
+/* cfqg stats flags */
+enum cfqg_stats_flags {
+	CFQG_stats_waiting = 0,
+	CFQG_stats_idling,
+	CFQG_stats_empty,
 };
 
-#define BLKG_FLAG_FNS(name)						\
-static inline void blkio_mark_blkg_##name(				\
-		struct blkio_group_stats *stats)			\
+#define CFQG_FLAG_FNS(name)						\
+static inline void cfqg_stats_mark_##name(struct cfqg_stats *stats)	\
 {									\
-	stats->flags |= (1 << BLKG_##name);				\
+	stats->flags |= (1 << CFQG_stats_##name);			\
 }									\
-static inline void blkio_clear_blkg_##name(				\
-		struct blkio_group_stats *stats)			\
+static inline void cfqg_stats_clear_##name(struct cfqg_stats *stats)	\
 {									\
-	stats->flags &= ~(1 << BLKG_##name);				\
+	stats->flags &= ~(1 << CFQG_stats_##name);			\
 }									\
-static inline int blkio_blkg_##name(struct blkio_group_stats *stats)	\
+static inline int cfqg_stats_##name(struct cfqg_stats *stats)		\
 {									\
-	return (stats->flags & (1 << BLKG_##name)) != 0;		\
+	return (stats->flags & (1 << CFQG_stats_##name)) != 0;		\
 }									\
 
-BLKG_FLAG_FNS(waiting)
-BLKG_FLAG_FNS(idling)
-BLKG_FLAG_FNS(empty)
-#undef BLKG_FLAG_FNS
+CFQG_FLAG_FNS(waiting)
+CFQG_FLAG_FNS(idling)
+CFQG_FLAG_FNS(empty)
+#undef CFQG_FLAG_FNS
 
 /* This should be called with the queue_lock held. */
-static void blkio_update_group_wait_time(struct blkio_group_stats *stats)
+static void cfqg_stats_update_group_wait_time(struct cfqg_stats *stats)
 {
 	unsigned long long now;
 
-	if (!blkio_blkg_waiting(stats))
+	if (!cfqg_stats_waiting(stats))
 		return;
 
 	now = sched_clock();
 	if (time_after64(now, stats->start_group_wait_time))
 		blkg_stat_add(&stats->group_wait_time,
 			      now - stats->start_group_wait_time);
-	blkio_clear_blkg_waiting(stats);
+	cfqg_stats_clear_waiting(stats);
 }
 
 /* This should be called with the queue_lock held. */
-static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
-					    struct blkio_policy_type *pol,
-					    struct blkio_group *curr_blkg)
+static void cfqg_stats_set_start_group_wait_time(struct cfq_group *cfqg,
+						 struct cfq_group *curr_cfqg)
 {
-	struct blkg_policy_data *pd = blkg->pd[pol->plid];
+	struct cfqg_stats *stats = &cfqg->stats;
 
-	if (blkio_blkg_waiting(&pd->stats))
+	if (cfqg_stats_waiting(stats))
 		return;
-	if (blkg == curr_blkg)
+	if (cfqg == curr_cfqg)
 		return;
-	pd->stats.start_group_wait_time = sched_clock();
-	blkio_mark_blkg_waiting(&pd->stats);
+	stats->start_group_wait_time = sched_clock();
+	cfqg_stats_mark_waiting(stats);
 }
 
 /* This should be called with the queue_lock held. */
-static void blkio_end_empty_time(struct blkio_group_stats *stats)
+static void cfqg_stats_end_empty_time(struct cfqg_stats *stats)
 {
 	unsigned long long now;
 
-	if (!blkio_blkg_empty(stats))
+	if (!cfqg_stats_empty(stats))
 		return;
 
 	now = sched_clock();
 	if (time_after64(now, stats->start_empty_time))
 		blkg_stat_add(&stats->empty_time,
 			      now - stats->start_empty_time);
-	blkio_clear_blkg_empty(stats);
+	cfqg_stats_clear_empty(stats);
 }
 
-static void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-					     struct blkio_policy_type *pol,
-					     unsigned long dequeue)
+static void cfqg_stats_update_dequeue(struct cfq_group *cfqg)
 {
-	struct blkg_policy_data *pd = blkg->pd[pol->plid];
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_stat_add(&pd->stats.dequeue, dequeue);
+	blkg_stat_add(&cfqg->stats.dequeue, 1);
 }
 
-static void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
-					     struct blkio_policy_type *pol)
+static void cfqg_stats_set_start_empty_time(struct cfq_group *cfqg)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
+	struct cfqg_stats *stats = &cfqg->stats;
 
 	if (blkg_rwstat_sum(&stats->queued))
 		return;
@@ -467,72 +498,57 @@ static void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
 	 * request in parent group and moved to this group while being added
 	 * to service tree. Just ignore the event and move on.
 	 */
-	if (blkio_blkg_empty(stats))
+	if (cfqg_stats_empty(stats))
 		return;
 
 	stats->start_empty_time = sched_clock();
-	blkio_mark_blkg_empty(stats);
+	cfqg_stats_mark_empty(stats);
 }
 
-static void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-					       struct blkio_policy_type *pol)
+static void cfqg_stats_update_idle_time(struct cfq_group *cfqg)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	struct cfqg_stats *stats = &cfqg->stats;
 
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	if (blkio_blkg_idling(stats)) {
+	if (cfqg_stats_idling(stats)) {
 		unsigned long long now = sched_clock();
 
 		if (time_after64(now, stats->start_idle_time))
 			blkg_stat_add(&stats->idle_time,
 				      now - stats->start_idle_time);
-		blkio_clear_blkg_idling(stats);
+		cfqg_stats_clear_idling(stats);
 	}
 }
 
-static void cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-						   struct blkio_policy_type *pol)
+static void cfqg_stats_set_start_idle_time(struct cfq_group *cfqg)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	struct cfqg_stats *stats = &cfqg->stats;
 
-	lockdep_assert_held(blkg->q->queue_lock);
-	BUG_ON(blkio_blkg_idling(stats));
+	BUG_ON(cfqg_stats_idling(stats));
 
 	stats->start_idle_time = sched_clock();
-	blkio_mark_blkg_idling(stats);
+	cfqg_stats_mark_idling(stats);
 }
 
-static void cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-						    struct blkio_policy_type *pol)
+static void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
+	struct cfqg_stats *stats = &cfqg->stats;
 
 	blkg_stat_add(&stats->avg_queue_size_sum,
 		      blkg_rwstat_sum(&stats->queued));
 	blkg_stat_add(&stats->avg_queue_size_samples, 1);
-	blkio_update_group_wait_time(stats);
+	cfqg_stats_update_group_wait_time(stats);
 }
 
 #else	/* CONFIG_CFQ_GROUP_IOSCHED && CONFIG_DEBUG_BLK_CGROUP */
 
-static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
-					    struct blkio_policy_type *pol,
-					    struct blkio_group *curr_blkg) { }
-static void blkio_end_empty_time(struct blkio_group_stats *stats) { }
-static void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-					     struct blkio_policy_type *pol,
-					     unsigned long dequeue) { }
-static void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
-					     struct blkio_policy_type *pol) { }
-static void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-					       struct blkio_policy_type *pol) { }
-static void cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-						   struct blkio_policy_type *pol) { }
-static void cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-						    struct blkio_policy_type *pol) { }
+static void cfqg_stats_set_start_group_wait_time(struct cfq_group *cfqg,
+						 struct cfq_group *curr_cfqg) { }
+static void cfqg_stats_end_empty_time(struct cfqg_stats *stats) { }
+static void cfqg_stats_update_dequeue(struct cfq_group *cfqg) { }
+static void cfqg_stats_set_start_empty_time(struct cfq_group *cfqg) { }
+static void cfqg_stats_update_idle_time(struct cfq_group *cfqg) { }
+static void cfqg_stats_set_start_idle_time(struct cfq_group *cfqg) { }
+static void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg) { }
 
 #endif	/* CONFIG_CFQ_GROUP_IOSCHED && CONFIG_DEBUG_BLK_CGROUP */
 
@@ -567,80 +583,46 @@ static inline void cfqg_put(struct cfq_group *cfqg)
 	blk_add_trace_msg((cfqd)->queue, "%s " fmt,			\
 			blkg_path(cfqg_to_blkg((cfqg))), ##args)	\
 
-static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol,
-			struct blkio_group *curr_blkg,
-			bool direction, bool sync)
+static inline void cfqg_stats_update_io_add(struct cfq_group *cfqg,
+					    struct cfq_group *curr_cfqg, int rw)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_rwstat_add(&stats->queued, rw, 1);
-	blkio_end_empty_time(stats);
-	blkio_set_start_group_wait_time(blkg, pol, curr_blkg);
+	blkg_rwstat_add(&cfqg->stats.queued, rw, 1);
+	cfqg_stats_end_empty_time(&cfqg->stats);
+	cfqg_stats_set_start_group_wait_time(cfqg, curr_cfqg);
 }
 
-static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long time,
-			unsigned long unaccounted_time)
+static inline void cfqg_stats_update_timeslice_used(struct cfq_group *cfqg,
+			unsigned long time, unsigned long unaccounted_time)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_stat_add(&stats->time, time);
+	blkg_stat_add(&cfqg->stats.time, time);
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-	blkg_stat_add(&stats->unaccounted_time, unaccounted_time);
+	blkg_stat_add(&cfqg->stats.unaccounted_time, unaccounted_time);
 #endif
 }
 
-static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync)
+static inline void cfqg_stats_update_io_remove(struct cfq_group *cfqg, int rw)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_rwstat_add(&stats->queued, rw, -1);
+	blkg_rwstat_add(&cfqg->stats.queued, rw, -1);
 }
 
-static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync)
+static inline void cfqg_stats_update_io_merged(struct cfq_group *cfqg, int rw)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_rwstat_add(&stats->merged, rw, 1);
+	blkg_rwstat_add(&cfqg->stats.merged, rw, 1);
 }
 
-static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t bytes,
-			bool direction, bool sync)
+static inline void cfqg_stats_update_dispatch(struct cfq_group *cfqg,
+					      uint64_t bytes, int rw)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	blkg_stat_add(&stats->sectors, bytes >> 9);
-	blkg_rwstat_add(&stats->serviced, rw, 1);
-	blkg_rwstat_add(&stats->service_bytes, rw, bytes);
+	blkg_stat_add(&cfqg->stats.sectors, bytes >> 9);
+	blkg_rwstat_add(&cfqg->stats.serviced, rw, 1);
+	blkg_rwstat_add(&cfqg->stats.service_bytes, rw, bytes);
 }
 
-static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t start_time,
-			uint64_t io_start_time, bool direction, bool sync)
+static inline void cfqg_stats_update_completion(struct cfq_group *cfqg,
+			uint64_t start_time, uint64_t io_start_time, int rw)
 {
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	struct cfqg_stats *stats = &cfqg->stats;
 	unsigned long long now = sched_clock();
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
 
 	if (time_after64(now, io_start_time))
 		blkg_rwstat_add(&stats->service_time, rw, now - io_start_time);
@@ -649,6 +631,29 @@ static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
 				io_start_time - start_time);
 }
 
+static void cfqg_stats_reset(struct blkio_group *blkg)
+{
+	struct cfq_group *cfqg = blkg_to_cfqg(blkg);
+	struct cfqg_stats *stats = &cfqg->stats;
+
+	/* queued stats shouldn't be cleared */
+	blkg_rwstat_reset(&stats->service_bytes);
+	blkg_rwstat_reset(&stats->serviced);
+	blkg_rwstat_reset(&stats->merged);
+	blkg_rwstat_reset(&stats->service_time);
+	blkg_rwstat_reset(&stats->wait_time);
+	blkg_stat_reset(&stats->time);
+#ifdef CONFIG_DEBUG_BLK_CGROUP
+	blkg_stat_reset(&stats->unaccounted_time);
+	blkg_stat_reset(&stats->avg_queue_size_sum);
+	blkg_stat_reset(&stats->avg_queue_size_samples);
+	blkg_stat_reset(&stats->dequeue);
+	blkg_stat_reset(&stats->group_wait_time);
+	blkg_stat_reset(&stats->idle_time);
+	blkg_stat_reset(&stats->empty_time);
+#endif
+}
+
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
 
 static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg) { return NULL; }
@@ -660,25 +665,16 @@ static inline void cfqg_put(struct cfq_group *cfqg) { }
 	blk_add_trace_msg((cfqd)->queue, "cfq%d " fmt, (cfqq)->pid, ##args)
 #define cfq_log_cfqg(cfqd, cfqg, fmt, args...)		do {} while (0)
 
-static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol,
-			struct blkio_group *curr_blkg, bool direction,
-			bool sync) { }
-static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long time,
-			unsigned long unaccounted_time) { }
-static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync) { }
-static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync) { }
-static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t bytes,
-			bool direction, bool sync) { }
-static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t start_time,
-			uint64_t io_start_time, bool direction, bool sync) { }
+static inline void cfqg_stats_update_io_add(struct cfq_group *cfqg,
+			struct cfq_group *curr_cfqg, int rw) { }
+static inline void cfqg_stats_update_timeslice_used(struct cfq_group *cfqg,
+			unsigned long time, unsigned long unaccounted_time) { }
+static inline void cfqg_stats_update_io_remove(struct cfq_group *cfqg, int rw) { }
+static inline void cfqg_stats_update_io_merged(struct cfq_group *cfqg, int rw) { }
+static inline void cfqg_stats_update_dispatch(struct cfq_group *cfqg,
+					      uint64_t bytes, int rw) { }
+static inline void cfqg_stats_update_completion(struct cfq_group *cfqg,
+			uint64_t start_time, uint64_t io_start_time, int rw) { }
 
 #endif	/* CONFIG_CFQ_GROUP_IOSCHED */
 
@@ -1233,8 +1229,7 @@ cfq_group_notify_queue_del(struct cfq_data *cfqd, struct cfq_group *cfqg)
 	cfq_log_cfqg(cfqd, cfqg, "del_from_rr group");
 	cfq_group_service_tree_del(st, cfqg);
 	cfqg->saved_workload_slice = 0;
-	cfq_blkiocg_update_dequeue_stats(cfqg_to_blkg(cfqg),
-					 &blkio_policy_cfq, 1);
+	cfqg_stats_update_dequeue(cfqg);
 }
 
 static inline unsigned int cfq_cfqq_slice_usage(struct cfq_queue *cfqq,
@@ -1306,9 +1301,8 @@ static void cfq_group_served(struct cfq_data *cfqd, struct cfq_group *cfqg,
 		     "sl_used=%u disp=%u charge=%u iops=%u sect=%lu",
 		     used_sl, cfqq->slice_dispatch, charge,
 		     iops_mode(cfqd), cfqq->nr_sectors);
-	cfq_blkiocg_update_timeslice_used(cfqg_to_blkg(cfqg), &blkio_policy_cfq,
-					  used_sl, unaccounted_sl);
-	cfq_blkiocg_set_start_empty_time(cfqg_to_blkg(cfqg), &blkio_policy_cfq);
+	cfqg_stats_update_timeslice_used(cfqg, used_sl, unaccounted_sl);
+	cfqg_stats_set_start_empty_time(cfqg);
 }
 
 /**
@@ -1456,14 +1450,15 @@ static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 }
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
-static u64 blkg_prfill_avg_queue_size(struct seq_file *sf,
+static u64 cfqg_prfill_avg_queue_size(struct seq_file *sf,
 				      struct blkg_policy_data *pd, int off)
 {
-	u64 samples = blkg_stat_read(&pd->stats.avg_queue_size_samples);
+	struct cfq_group *cfqg = (void *)pd->pdata;
+	u64 samples = blkg_stat_read(&cfqg->stats.avg_queue_size_samples);
 	u64 v = 0;
 
 	if (samples) {
-		v = blkg_stat_read(&pd->stats.avg_queue_size_sum);
+		v = blkg_stat_read(&cfqg->stats.avg_queue_size_sum);
 		do_div(v, samples);
 	}
 	__blkg_prfill_u64(sf, pd, v);
@@ -1471,12 +1466,12 @@ static u64 blkg_prfill_avg_queue_size(struct seq_file *sf,
 }
 
 /* print avg_queue_size */
-static int blkcg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
-				      struct seq_file *sf)
+static int cfqg_print_avg_queue_size(struct cgroup *cgrp, struct cftype *cft,
+				     struct seq_file *sf)
 {
 	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 
-	blkcg_print_blkgs(sf, blkcg, blkg_prfill_avg_queue_size,
+	blkcg_print_blkgs(sf, blkcg, cfqg_prfill_avg_queue_size,
 			  BLKIO_POLICY_PROP, 0, false);
 	return 0;
 }
@@ -1497,84 +1492,84 @@ static struct cftype cfq_blkcg_files[] = {
 	{
 		.name = "time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, time)),
+				offsetof(struct cfq_group, stats.time)),
 		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "sectors",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, sectors)),
+				offsetof(struct cfq_group, stats.sectors)),
 		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "io_service_bytes",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, service_bytes)),
+				offsetof(struct cfq_group, stats.service_bytes)),
 		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_serviced",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, serviced)),
+				offsetof(struct cfq_group, stats.serviced)),
 		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_service_time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, service_time)),
+				offsetof(struct cfq_group, stats.service_time)),
 		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_wait_time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, wait_time)),
+				offsetof(struct cfq_group, stats.wait_time)),
 		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_merged",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, merged)),
+				offsetof(struct cfq_group, stats.merged)),
 		.read_seq_string = blkcg_print_rwstat,
 	},
 	{
 		.name = "io_queued",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, queued)),
+				offsetof(struct cfq_group, stats.queued)),
 		.read_seq_string = blkcg_print_rwstat,
 	},
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 	{
 		.name = "avg_queue_size",
-		.read_seq_string = blkcg_print_avg_queue_size,
+		.read_seq_string = cfqg_print_avg_queue_size,
 	},
 	{
 		.name = "group_wait_time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, group_wait_time)),
+				offsetof(struct cfq_group, stats.group_wait_time)),
 		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "idle_time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, idle_time)),
+				offsetof(struct cfq_group, stats.idle_time)),
 		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "empty_time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, empty_time)),
+				offsetof(struct cfq_group, stats.empty_time)),
 		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "dequeue",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, dequeue)),
+				offsetof(struct cfq_group, stats.dequeue)),
 		.read_seq_string = blkcg_print_stat,
 	},
 	{
 		.name = "unaccounted_time",
 		.private = BLKCG_STAT_PRIV(BLKIO_POLICY_PROP,
-				offsetof(struct blkio_group_stats, unaccounted_time)),
+				offsetof(struct cfq_group, stats.unaccounted_time)),
 		.read_seq_string = blkcg_print_stat,
 	},
 #endif	/* CONFIG_DEBUG_BLK_CGROUP */
@@ -1858,14 +1853,10 @@ static void cfq_reposition_rq_rb(struct cfq_queue *cfqq, struct request *rq)
 {
 	elv_rb_del(&cfqq->sort_list, rq);
 	cfqq->queued[rq_is_sync(rq)]--;
-	cfq_blkiocg_update_io_remove_stats(cfqg_to_blkg(RQ_CFQG(rq)),
-					   &blkio_policy_cfq, rq_data_dir(rq),
-					   rq_is_sync(rq));
+	cfqg_stats_update_io_remove(RQ_CFQG(rq), rq->cmd_flags);
 	cfq_add_rq_rb(rq);
-	cfq_blkiocg_update_io_add_stats(cfqg_to_blkg(RQ_CFQG(rq)),
-					&blkio_policy_cfq,
-					cfqg_to_blkg(cfqq->cfqd->serving_group),
-					rq_data_dir(rq), rq_is_sync(rq));
+	cfqg_stats_update_io_add(RQ_CFQG(rq), cfqq->cfqd->serving_group,
+				 rq->cmd_flags);
 }
 
 static struct request *
@@ -1921,9 +1912,7 @@ static void cfq_remove_request(struct request *rq)
 	cfq_del_rq_rb(rq);
 
 	cfqq->cfqd->rq_queued--;
-	cfq_blkiocg_update_io_remove_stats(cfqg_to_blkg(RQ_CFQG(rq)),
-					   &blkio_policy_cfq, rq_data_dir(rq),
-					   rq_is_sync(rq));
+	cfqg_stats_update_io_remove(RQ_CFQG(rq), rq->cmd_flags);
 	if (rq->cmd_flags & REQ_PRIO) {
 		WARN_ON(!cfqq->prio_pending);
 		cfqq->prio_pending--;
@@ -1958,9 +1947,7 @@ static void cfq_merged_request(struct request_queue *q, struct request *req,
 static void cfq_bio_merged(struct request_queue *q, struct request *req,
 				struct bio *bio)
 {
-	cfq_blkiocg_update_io_merged_stats(cfqg_to_blkg(RQ_CFQG(req)),
-					   &blkio_policy_cfq, bio_data_dir(bio),
-					   cfq_bio_sync(bio));
+	cfqg_stats_update_io_merged(RQ_CFQG(req), bio->bi_rw);
 }
 
 static void
@@ -1982,9 +1969,7 @@ cfq_merged_requests(struct request_queue *q, struct request *rq,
 	if (cfqq->next_rq == next)
 		cfqq->next_rq = rq;
 	cfq_remove_request(next);
-	cfq_blkiocg_update_io_merged_stats(cfqg_to_blkg(RQ_CFQG(rq)),
-					   &blkio_policy_cfq, rq_data_dir(next),
-					   rq_is_sync(next));
+	cfqg_stats_update_io_merged(RQ_CFQG(rq), next->cmd_flags);
 
 	cfqq = RQ_CFQQ(next);
 	/*
@@ -2025,8 +2010,7 @@ static int cfq_allow_merge(struct request_queue *q, struct request *rq,
 static inline void cfq_del_timer(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 {
 	del_timer(&cfqd->idle_slice_timer);
-	cfq_blkiocg_update_idle_time_stats(cfqg_to_blkg(cfqq->cfqg),
-					   &blkio_policy_cfq);
+	cfqg_stats_update_idle_time(cfqq->cfqg);
 }
 
 static void __cfq_set_active_queue(struct cfq_data *cfqd,
@@ -2035,8 +2019,7 @@ static void __cfq_set_active_queue(struct cfq_data *cfqd,
 	if (cfqq) {
 		cfq_log_cfqq(cfqd, cfqq, "set_active wl_prio:%d wl_type:%d",
 				cfqd->serving_prio, cfqd->serving_type);
-		cfq_blkiocg_update_avg_queue_size_stats(cfqg_to_blkg(cfqq->cfqg),
-							&blkio_policy_cfq);
+		cfqg_stats_update_avg_queue_size(cfqq->cfqg);
 		cfqq->slice_start = 0;
 		cfqq->dispatch_start = jiffies;
 		cfqq->allocated_slice = 0;
@@ -2384,8 +2367,7 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 		sl = cfqd->cfq_slice_idle;
 
 	mod_timer(&cfqd->idle_slice_timer, jiffies + sl);
-	cfq_blkiocg_update_set_idle_time_stats(cfqg_to_blkg(cfqq->cfqg),
-					       &blkio_policy_cfq);
+	cfqg_stats_set_start_idle_time(cfqq->cfqg);
 	cfq_log_cfqq(cfqd, cfqq, "arm_idle: %lu group_idle: %d", sl,
 			group_idle ? 1 : 0);
 }
@@ -2408,9 +2390,7 @@ static void cfq_dispatch_insert(struct request_queue *q, struct request *rq)
 
 	cfqd->rq_in_flight[cfq_cfqq_sync(cfqq)]++;
 	cfqq->nr_sectors += blk_rq_sectors(rq);
-	cfq_blkiocg_update_dispatch_stats(cfqg_to_blkg(cfqq->cfqg),
-					  &blkio_policy_cfq, blk_rq_bytes(rq),
-					  rq_data_dir(rq), rq_is_sync(rq));
+	cfqg_stats_update_dispatch(cfqq->cfqg, blk_rq_bytes(rq), rq->cmd_flags);
 }
 
 /*
@@ -3513,9 +3493,7 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 				cfq_clear_cfqq_wait_request(cfqq);
 				__blk_run_queue(cfqd->queue);
 			} else {
-				cfq_blkiocg_update_idle_time_stats(
-						cfqg_to_blkg(cfqq->cfqg),
-						&blkio_policy_cfq);
+				cfqg_stats_update_idle_time(cfqq->cfqg);
 				cfq_mark_cfqq_must_dispatch(cfqq);
 			}
 		}
@@ -3542,10 +3520,8 @@ static void cfq_insert_request(struct request_queue *q, struct request *rq)
 	rq_set_fifo_time(rq, jiffies + cfqd->cfq_fifo_expire[rq_is_sync(rq)]);
 	list_add_tail(&rq->queuelist, &cfqq->fifo);
 	cfq_add_rq_rb(rq);
-	cfq_blkiocg_update_io_add_stats(cfqg_to_blkg(RQ_CFQG(rq)),
-					&blkio_policy_cfq,
-					cfqg_to_blkg(cfqd->serving_group),
-					rq_data_dir(rq), rq_is_sync(rq));
+	cfqg_stats_update_io_add(RQ_CFQG(rq), cfqd->serving_group,
+				 rq->cmd_flags);
 	cfq_rq_enqueued(cfqd, cfqq, rq);
 }
 
@@ -3641,10 +3617,8 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 	cfqd->rq_in_driver--;
 	cfqq->dispatched--;
 	(RQ_CFQG(rq))->dispatched--;
-	cfq_blkiocg_update_completion_stats(cfqg_to_blkg(cfqq->cfqg),
-			&blkio_policy_cfq, rq_start_time_ns(rq),
-			rq_io_start_time_ns(rq), rq_data_dir(rq),
-			rq_is_sync(rq));
+	cfqg_stats_update_completion(cfqq->cfqg, rq_start_time_ns(rq),
+				     rq_io_start_time_ns(rq), rq->cmd_flags);
 
 	cfqd->rq_in_flight[cfq_cfqq_sync(cfqq)]--;
 
@@ -4184,6 +4158,7 @@ static struct elevator_type iosched_cfq = {
 static struct blkio_policy_type blkio_policy_cfq = {
 	.ops = {
 		.blkio_init_group_fn =		cfq_init_blkio_group,
+		.blkio_reset_group_stats_fn =	cfqg_stats_reset,
 	},
 	.plid = BLKIO_POLICY_PROP,
 	.pdata_size = sizeof(struct cfq_group),
-- 
1.7.7.3
