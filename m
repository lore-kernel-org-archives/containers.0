From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 13/21] blkcg: move statistics update code to policies
Date: Wed, 28 Mar 2012 15:51:23 -0700
Message-ID: <1332975091-10950-14-git-send-email-tj@kernel.org>
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

As with conf/stats file handling code, there's no reason for stat
update code to live in blkcg core with policies calling into update
them.  The current organization is both inflexible and complex.

This patch moves stat update code to specific policies.  All
blkiocg_update_*_stats() functions which deal with BLKIO_POLICY_PROP
stats are collapsed into their cfq_blkiocg_update_*_stats()
counterparts.  blkiocg_update_dispatch_stats() is used by both
policies and duplicated as throtl_update_dispatch_stats() and
cfq_blkiocg_update_dispatch_stats().  This will be cleaned up later.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c   |  245 -------------------------------------------
 block/blk-cgroup.h   |   94 -----------------
 block/blk-throttle.c |   37 ++++++--
 block/cfq-iosched.c  |  280 +++++++++++++++++++++++++++++++++++++++++---------
 4 files changed, 259 insertions(+), 397 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 96b6b5a..dfa5f2c 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -63,251 +63,6 @@ struct blkio_cgroup *bio_blkio_cgroup(struct bio *bio)
 }
 EXPORT_SYMBOL_GPL(bio_blkio_cgroup);
 
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-/* This should be called with the queue_lock held. */
-static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
-					    struct blkio_policy_type *pol,
-					    struct blkio_group *curr_blkg)
-{
-	struct blkg_policy_data *pd = blkg->pd[pol->plid];
-
-	if (blkio_blkg_waiting(&pd->stats))
-		return;
-	if (blkg == curr_blkg)
-		return;
-	pd->stats.start_group_wait_time = sched_clock();
-	blkio_mark_blkg_waiting(&pd->stats);
-}
-
-/* This should be called with the queue_lock held. */
-static void blkio_update_group_wait_time(struct blkio_group_stats *stats)
-{
-	unsigned long long now;
-
-	if (!blkio_blkg_waiting(stats))
-		return;
-
-	now = sched_clock();
-	if (time_after64(now, stats->start_group_wait_time))
-		blkg_stat_add(&stats->group_wait_time,
-			      now - stats->start_group_wait_time);
-	blkio_clear_blkg_waiting(stats);
-}
-
-/* This should be called with the queue_lock held. */
-static void blkio_end_empty_time(struct blkio_group_stats *stats)
-{
-	unsigned long long now;
-
-	if (!blkio_blkg_empty(stats))
-		return;
-
-	now = sched_clock();
-	if (time_after64(now, stats->start_empty_time))
-		blkg_stat_add(&stats->empty_time,
-			      now - stats->start_empty_time);
-	blkio_clear_blkg_empty(stats);
-}
-
-void blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-					struct blkio_policy_type *pol)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
-	BUG_ON(blkio_blkg_idling(stats));
-
-	stats->start_idle_time = sched_clock();
-	blkio_mark_blkg_idling(stats);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_set_idle_time_stats);
-
-void blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-				    struct blkio_policy_type *pol)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	if (blkio_blkg_idling(stats)) {
-		unsigned long long now = sched_clock();
-
-		if (time_after64(now, stats->start_idle_time))
-			blkg_stat_add(&stats->idle_time,
-				      now - stats->start_idle_time);
-		blkio_clear_blkg_idling(stats);
-	}
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_idle_time_stats);
-
-void blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-					 struct blkio_policy_type *pol)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_stat_add(&stats->avg_queue_size_sum,
-		      blkg_rwstat_sum(&stats->queued));
-	blkg_stat_add(&stats->avg_queue_size_samples, 1);
-	blkio_update_group_wait_time(stats);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_avg_queue_size_stats);
-
-void blkiocg_set_start_empty_time(struct blkio_group *blkg,
-				  struct blkio_policy_type *pol)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	if (blkg_rwstat_sum(&stats->queued))
-		return;
-
-	/*
-	 * group is already marked empty. This can happen if cfqq got new
-	 * request in parent group and moved to this group while being added
-	 * to service tree. Just ignore the event and move on.
-	 */
-	if (blkio_blkg_empty(stats))
-		return;
-
-	stats->start_empty_time = sched_clock();
-	blkio_mark_blkg_empty(stats);
-}
-EXPORT_SYMBOL_GPL(blkiocg_set_start_empty_time);
-
-void blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-				  struct blkio_policy_type *pol,
-				  unsigned long dequeue)
-{
-	struct blkg_policy_data *pd = blkg->pd[pol->plid];
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_stat_add(&pd->stats.dequeue, dequeue);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_dequeue_stats);
-#else
-static inline void blkio_set_start_group_wait_time(struct blkio_group *blkg,
-					struct blkio_policy_type *pol,
-					struct blkio_group *curr_blkg) { }
-static inline void blkio_end_empty_time(struct blkio_group_stats *stats) { }
-#endif
-
-void blkiocg_update_io_add_stats(struct blkio_group *blkg,
-				 struct blkio_policy_type *pol,
-				 struct blkio_group *curr_blkg, bool direction,
-				 bool sync)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_rwstat_add(&stats->queued, rw, 1);
-	blkio_end_empty_time(stats);
-	blkio_set_start_group_wait_time(blkg, pol, curr_blkg);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_io_add_stats);
-
-void blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-				    struct blkio_policy_type *pol,
-				    bool direction, bool sync)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_rwstat_add(&stats->queued, rw, -1);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_io_remove_stats);
-
-void blkiocg_update_timeslice_used(struct blkio_group *blkg,
-				   struct blkio_policy_type *pol,
-				   unsigned long time,
-				   unsigned long unaccounted_time)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_stat_add(&stats->time, time);
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-	blkg_stat_add(&stats->unaccounted_time, unaccounted_time);
-#endif
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_timeslice_used);
-
-/*
- * should be called under rcu read lock or queue lock to make sure blkg pointer
- * is valid.
- */
-void blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-				   struct blkio_policy_type *pol,
-				   uint64_t bytes, bool direction, bool sync)
-{
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-	struct blkg_policy_data *pd = blkg->pd[pol->plid];
-	struct blkio_group_stats_cpu *stats_cpu;
-	unsigned long flags;
-
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
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_dispatch_stats);
-
-void blkiocg_update_completion_stats(struct blkio_group *blkg,
-				     struct blkio_policy_type *pol,
-				     uint64_t start_time,
-				     uint64_t io_start_time, bool direction,
-				     bool sync)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	unsigned long long now = sched_clock();
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	if (time_after64(now, io_start_time))
-		blkg_rwstat_add(&stats->service_time, rw, now - io_start_time);
-	if (time_after64(io_start_time, start_time))
-		blkg_rwstat_add(&stats->wait_time, rw,
-				io_start_time - start_time);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_completion_stats);
-
-/*  Merged stats are per cpu.  */
-void blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-				    struct blkio_policy_type *pol,
-				    bool direction, bool sync)
-{
-	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
-	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
-
-	lockdep_assert_held(blkg->q->queue_lock);
-
-	blkg_rwstat_add(&stats->merged, rw, 1);
-}
-EXPORT_SYMBOL_GPL(blkiocg_update_io_merged_stats);
-
 /*
  * Worker for allocating per cpu stat for blk groups. This is scheduled on
  * the system_nrt_wq once there are some groups on the alloc_list waiting
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index ba64b28..0b0a176 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -44,13 +44,6 @@ enum blkg_rwstat_type {
 	BLKG_RWSTAT_TOTAL = BLKG_RWSTAT_NR,
 };
 
-/* blkg state flags */
-enum blkg_state_flags {
-	BLKG_waiting = 0,
-	BLKG_idling,
-	BLKG_empty,
-};
-
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
 	unsigned int weight;
@@ -416,52 +409,6 @@ static inline void blkg_put(struct blkio_group *blkg) { }
 #define BLKIO_WEIGHT_MAX	1000
 #define BLKIO_WEIGHT_DEFAULT	500
 
-#ifdef CONFIG_DEBUG_BLK_CGROUP
-void blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-					 struct blkio_policy_type *pol);
-void blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-				  struct blkio_policy_type *pol,
-				  unsigned long dequeue);
-void blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-					struct blkio_policy_type *pol);
-void blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-				    struct blkio_policy_type *pol);
-void blkiocg_set_start_empty_time(struct blkio_group *blkg,
-				  struct blkio_policy_type *pol);
-
-#define BLKG_FLAG_FNS(name)						\
-static inline void blkio_mark_blkg_##name(				\
-		struct blkio_group_stats *stats)			\
-{									\
-	stats->flags |= (1 << BLKG_##name);				\
-}									\
-static inline void blkio_clear_blkg_##name(				\
-		struct blkio_group_stats *stats)			\
-{									\
-	stats->flags &= ~(1 << BLKG_##name);				\
-}									\
-static inline int blkio_blkg_##name(struct blkio_group_stats *stats)	\
-{									\
-	return (stats->flags & (1 << BLKG_##name)) != 0;		\
-}									\
-
-BLKG_FLAG_FNS(waiting)
-BLKG_FLAG_FNS(idling)
-BLKG_FLAG_FNS(empty)
-#undef BLKG_FLAG_FNS
-#else
-static inline void blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-static inline void blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long dequeue) { }
-static inline void blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-static inline void blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-static inline void blkiocg_set_start_empty_time(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-#endif
-
 #ifdef CONFIG_BLK_CGROUP
 extern struct blkio_cgroup blkio_root_cgroup;
 extern struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
@@ -471,28 +418,6 @@ extern struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
 struct blkio_group *blkg_lookup_create(struct blkio_cgroup *blkcg,
 				       struct request_queue *q,
 				       bool for_root);
-void blkiocg_update_timeslice_used(struct blkio_group *blkg,
-				   struct blkio_policy_type *pol,
-				   unsigned long time,
-				   unsigned long unaccounted_time);
-void blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-				   struct blkio_policy_type *pol,
-				   uint64_t bytes, bool direction, bool sync);
-void blkiocg_update_completion_stats(struct blkio_group *blkg,
-				     struct blkio_policy_type *pol,
-				     uint64_t start_time,
-				     uint64_t io_start_time, bool direction,
-				     bool sync);
-void blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-				    struct blkio_policy_type *pol,
-				    bool direction, bool sync);
-void blkiocg_update_io_add_stats(struct blkio_group *blkg,
-				 struct blkio_policy_type *pol,
-				 struct blkio_group *curr_blkg, bool direction,
-				 bool sync);
-void blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-				    struct blkio_policy_type *pol,
-				    bool direction, bool sync);
 #else
 struct cgroup;
 static inline struct blkio_cgroup *
@@ -502,24 +427,5 @@ bio_blkio_cgroup(struct bio *bio) { return NULL; }
 
 static inline struct blkio_group *blkg_lookup(struct blkio_cgroup *blkcg,
 					      void *key) { return NULL; }
-static inline void blkiocg_update_timeslice_used(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long time,
-			unsigned long unaccounted_time) { }
-static inline void blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t bytes,
-			bool direction, bool sync) { }
-static inline void blkiocg_update_completion_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t start_time,
-			uint64_t io_start_time, bool direction, bool sync) { }
-static inline void blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync) { }
-static inline void blkiocg_update_io_add_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol,
-			struct blkio_group *curr_blkg, bool direction,
-			bool sync) { }
-static inline void blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync) { }
 #endif
 #endif /* _BLK_CGROUP_H */
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index fb6f257..5d647ed 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -562,17 +562,42 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 	return 0;
 }
 
+static void throtl_update_dispatch_stats(struct blkio_group *blkg, u64 bytes,
+					 int rw)
+{
+	struct blkg_policy_data *pd = blkg->pd[BLKIO_POLICY_THROTL];
+	struct blkio_group_stats_cpu *stats_cpu;
+	unsigned long flags;
+
+	/* If per cpu stats are not allocated yet, don't do any accounting. */
+	if (pd->stats_cpu == NULL)
+		return;
+
+	/*
+	 * Disabling interrupts to provide mutual exclusion between two
+	 * writes on same cpu. It probably is not needed for 64bit. Not
+	 * optimizing that case yet.
+	 */
+	local_irq_save(flags);
+
+	stats_cpu = this_cpu_ptr(pd->stats_cpu);
+
+	blkg_stat_add(&stats_cpu->sectors, bytes >> 9);
+	blkg_rwstat_add(&stats_cpu->serviced, rw, 1);
+	blkg_rwstat_add(&stats_cpu->service_bytes, rw, bytes);
+
+	local_irq_restore(flags);
+}
+
 static void throtl_charge_bio(struct throtl_grp *tg, struct bio *bio)
 {
 	bool rw = bio_data_dir(bio);
-	bool sync = rw_is_sync(bio->bi_rw);
 
 	/* Charge the bio to the group */
 	tg->bytes_disp[rw] += bio->bi_size;
 	tg->io_disp[rw]++;
 
-	blkiocg_update_dispatch_stats(tg_to_blkg(tg), &blkio_policy_throtl,
-				      bio->bi_size, rw, sync);
+	throtl_update_dispatch_stats(tg_to_blkg(tg), bio->bi_size, bio->bi_rw);
 }
 
 static void throtl_add_bio_tg(struct throtl_data *td, struct throtl_grp *tg,
@@ -1012,10 +1037,8 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	tg = throtl_lookup_tg(td, blkcg);
 	if (tg) {
 		if (tg_no_rule_group(tg, rw)) {
-			blkiocg_update_dispatch_stats(tg_to_blkg(tg),
-						      &blkio_policy_throtl,
-						      bio->bi_size, rw,
-						      rw_is_sync(bio->bi_rw));
+			throtl_update_dispatch_stats(tg_to_blkg(tg),
+						     bio->bi_size, bio->bi_rw);
 			goto out_unlock_rcu;
 		}
 	}
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 2e13e9e..4991380 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -15,6 +15,7 @@
 #include <linux/ioprio.h>
 #include <linux/blktrace_api.h>
 #include "blk.h"
+#include "blk-cgroup.h"
 
 static struct blkio_policy_type blkio_policy_cfq;
 
@@ -365,9 +366,177 @@ CFQ_CFQQ_FNS(deep);
 CFQ_CFQQ_FNS(wait_busy);
 #undef CFQ_CFQQ_FNS
 
-#ifdef CONFIG_CFQ_GROUP_IOSCHED
+#if defined(CONFIG_CFQ_GROUP_IOSCHED) && defined(CONFIG_DEBUG_BLK_CGROUP)
 
-#include "blk-cgroup.h"
+/* blkg state flags */
+enum blkg_state_flags {
+	BLKG_waiting = 0,
+	BLKG_idling,
+	BLKG_empty,
+};
+
+#define BLKG_FLAG_FNS(name)						\
+static inline void blkio_mark_blkg_##name(				\
+		struct blkio_group_stats *stats)			\
+{									\
+	stats->flags |= (1 << BLKG_##name);				\
+}									\
+static inline void blkio_clear_blkg_##name(				\
+		struct blkio_group_stats *stats)			\
+{									\
+	stats->flags &= ~(1 << BLKG_##name);				\
+}									\
+static inline int blkio_blkg_##name(struct blkio_group_stats *stats)	\
+{									\
+	return (stats->flags & (1 << BLKG_##name)) != 0;		\
+}									\
+
+BLKG_FLAG_FNS(waiting)
+BLKG_FLAG_FNS(idling)
+BLKG_FLAG_FNS(empty)
+#undef BLKG_FLAG_FNS
+
+/* This should be called with the queue_lock held. */
+static void blkio_update_group_wait_time(struct blkio_group_stats *stats)
+{
+	unsigned long long now;
+
+	if (!blkio_blkg_waiting(stats))
+		return;
+
+	now = sched_clock();
+	if (time_after64(now, stats->start_group_wait_time))
+		blkg_stat_add(&stats->group_wait_time,
+			      now - stats->start_group_wait_time);
+	blkio_clear_blkg_waiting(stats);
+}
+
+/* This should be called with the queue_lock held. */
+static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
+					    struct blkio_policy_type *pol,
+					    struct blkio_group *curr_blkg)
+{
+	struct blkg_policy_data *pd = blkg->pd[pol->plid];
+
+	if (blkio_blkg_waiting(&pd->stats))
+		return;
+	if (blkg == curr_blkg)
+		return;
+	pd->stats.start_group_wait_time = sched_clock();
+	blkio_mark_blkg_waiting(&pd->stats);
+}
+
+/* This should be called with the queue_lock held. */
+static void blkio_end_empty_time(struct blkio_group_stats *stats)
+{
+	unsigned long long now;
+
+	if (!blkio_blkg_empty(stats))
+		return;
+
+	now = sched_clock();
+	if (time_after64(now, stats->start_empty_time))
+		blkg_stat_add(&stats->empty_time,
+			      now - stats->start_empty_time);
+	blkio_clear_blkg_empty(stats);
+}
+
+static void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
+					     struct blkio_policy_type *pol,
+					     unsigned long dequeue)
+{
+	struct blkg_policy_data *pd = blkg->pd[pol->plid];
+
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	blkg_stat_add(&pd->stats.dequeue, dequeue);
+}
+
+static void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
+					     struct blkio_policy_type *pol)
+{
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	if (blkg_rwstat_sum(&stats->queued))
+		return;
+
+	/*
+	 * group is already marked empty. This can happen if cfqq got new
+	 * request in parent group and moved to this group while being added
+	 * to service tree. Just ignore the event and move on.
+	 */
+	if (blkio_blkg_empty(stats))
+		return;
+
+	stats->start_empty_time = sched_clock();
+	blkio_mark_blkg_empty(stats);
+}
+
+static void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
+					       struct blkio_policy_type *pol)
+{
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	if (blkio_blkg_idling(stats)) {
+		unsigned long long now = sched_clock();
+
+		if (time_after64(now, stats->start_idle_time))
+			blkg_stat_add(&stats->idle_time,
+				      now - stats->start_idle_time);
+		blkio_clear_blkg_idling(stats);
+	}
+}
+
+static void cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
+						   struct blkio_policy_type *pol)
+{
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+
+	lockdep_assert_held(blkg->q->queue_lock);
+	BUG_ON(blkio_blkg_idling(stats));
+
+	stats->start_idle_time = sched_clock();
+	blkio_mark_blkg_idling(stats);
+}
+
+static void cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
+						    struct blkio_policy_type *pol)
+{
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	blkg_stat_add(&stats->avg_queue_size_sum,
+		      blkg_rwstat_sum(&stats->queued));
+	blkg_stat_add(&stats->avg_queue_size_samples, 1);
+	blkio_update_group_wait_time(stats);
+}
+
+#else	/* CONFIG_CFQ_GROUP_IOSCHED && CONFIG_DEBUG_BLK_CGROUP */
+
+static void blkio_set_start_group_wait_time(struct blkio_group *blkg,
+					    struct blkio_policy_type *pol,
+					    struct blkio_group *curr_blkg) { }
+static void blkio_end_empty_time(struct blkio_group_stats *stats) { }
+static void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
+					     struct blkio_policy_type *pol,
+					     unsigned long dequeue) { }
+static void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
+					     struct blkio_policy_type *pol) { }
+static void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
+					       struct blkio_policy_type *pol) { }
+static void cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
+						   struct blkio_policy_type *pol) { }
+static void cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
+						    struct blkio_policy_type *pol) { }
+
+#endif	/* CONFIG_CFQ_GROUP_IOSCHED && CONFIG_DEBUG_BLK_CGROUP */
+
+#ifdef CONFIG_CFQ_GROUP_IOSCHED
 
 static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg)
 {
@@ -403,75 +572,98 @@ static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
 			struct blkio_group *curr_blkg,
 			bool direction, bool sync)
 {
-	blkiocg_update_io_add_stats(blkg, pol, curr_blkg, direction, sync);
-}
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 
-static inline void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long dequeue)
-{
-	blkiocg_update_dequeue_stats(blkg, pol, dequeue);
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	blkg_rwstat_add(&stats->queued, rw, 1);
+	blkio_end_empty_time(stats);
+	blkio_set_start_group_wait_time(blkg, pol, curr_blkg);
 }
 
 static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, unsigned long time,
 			unsigned long unaccounted_time)
 {
-	blkiocg_update_timeslice_used(blkg, pol, time, unaccounted_time);
-}
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
 
-static inline void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_set_start_empty_time(blkg, pol);
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	blkg_stat_add(&stats->time, time);
+#ifdef CONFIG_DEBUG_BLK_CGROUP
+	blkg_stat_add(&stats->unaccounted_time, unaccounted_time);
+#endif
 }
 
 static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, bool direction,
 			bool sync)
 {
-	blkiocg_update_io_remove_stats(blkg, pol, direction, sync);
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
+
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	blkg_rwstat_add(&stats->queued, rw, -1);
 }
 
 static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, bool direction,
 			bool sync)
 {
-	blkiocg_update_io_merged_stats(blkg, pol, direction, sync);
-}
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
 
-static inline void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_update_idle_time_stats(blkg, pol);
-}
+	lockdep_assert_held(blkg->q->queue_lock);
 
-static inline void
-cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_update_avg_queue_size_stats(blkg, pol);
-}
-
-static inline void
-cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_update_set_idle_time_stats(blkg, pol);
+	blkg_rwstat_add(&stats->merged, rw, 1);
 }
 
 static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, uint64_t bytes,
 			bool direction, bool sync)
 {
-	blkiocg_update_dispatch_stats(blkg, pol, bytes, direction, sync);
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
+	struct blkg_policy_data *pd = blkg->pd[pol->plid];
+	struct blkio_group_stats_cpu *stats_cpu;
+	unsigned long flags;
+
+	/* If per cpu stats are not allocated yet, don't do any accounting. */
+	if (pd->stats_cpu == NULL)
+		return;
+
+	/*
+	 * Disabling interrupts to provide mutual exclusion between two
+	 * writes on same cpu. It probably is not needed for 64bit. Not
+	 * optimizing that case yet.
+	 */
+	local_irq_save(flags);
+
+	stats_cpu = this_cpu_ptr(pd->stats_cpu);
+
+	blkg_stat_add(&stats_cpu->sectors, bytes >> 9);
+	blkg_rwstat_add(&stats_cpu->serviced, rw, 1);
+	blkg_rwstat_add(&stats_cpu->service_bytes, rw, bytes);
+
+	local_irq_restore(flags);
 }
 
 static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, uint64_t start_time,
 			uint64_t io_start_time, bool direction, bool sync)
 {
-	blkiocg_update_completion_stats(blkg, pol, start_time, io_start_time,
-					direction, sync);
+	struct blkio_group_stats *stats = &blkg->pd[pol->plid]->stats;
+	unsigned long long now = sched_clock();
+	int rw = (direction ? REQ_WRITE : 0) | (sync ? REQ_SYNC : 0);
+
+	lockdep_assert_held(blkg->q->queue_lock);
+
+	if (time_after64(now, io_start_time))
+		blkg_rwstat_add(&stats->service_time, rw, now - io_start_time);
+	if (time_after64(io_start_time, start_time))
+		blkg_rwstat_add(&stats->wait_time, rw,
+				io_start_time - start_time);
 }
 
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
@@ -489,29 +681,15 @@ static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol,
 			struct blkio_group *curr_blkg, bool direction,
 			bool sync) { }
-static inline void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long dequeue) { }
 static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, unsigned long time,
 			unsigned long unaccounted_time) { }
-static inline void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
 static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, bool direction,
 			bool sync) { }
 static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, bool direction,
 			bool sync) { }
-static inline void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-static inline void
-cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-					struct blkio_policy_type *pol) { }
-
-static inline void
-cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-				       struct blkio_policy_type *pol) { }
-
 static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
 			struct blkio_policy_type *pol, uint64_t bytes,
 			bool direction, bool sync) { }
-- 
1.7.7.3
