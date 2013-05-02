From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 13/31] blk-throttle: add backlink pointer from throtl_grp to
	throtl_data
Date: Wed,  1 May 2013 17:39:31 -0700
Message-ID: <1367455189-6957-14-git-send-email-tj@kernel.org>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367455189-6957-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Add throtl_grp->td so that the td (throtl_data) a given tg
(throtl_grp) belongs to can be determined, and remove @td argument
from functions which take both @td and @tg as the former now can be
determined from the latter.

This generally simplifies the code and removes a number of cases where
@td is passed as an argument without being actually used.  This will
also help hierarchy support implementation.

While at it, in multi-line conditions, move the logical operators
leading broken lines to the end of the previous line.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 106 +++++++++++++++++++++++++--------------------------
 1 file changed, 53 insertions(+), 53 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index fc55dda..6aae239 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -57,6 +57,9 @@ struct throtl_grp {
 	/* active throtl group service_queue member */
 	struct rb_node rb_node;
 
+	/* throtl_data this group belongs to */
+	struct throtl_data *td;
+
 	/*
 	 * Dispatch time in jiffies. This is the estimated time when group
 	 * will unthrottle and is ready to dispatch more bio. It is used as
@@ -140,11 +143,11 @@ static inline struct throtl_grp *td_root_tg(struct throtl_data *td)
 	return blkg_to_tg(td->queue->root_blkg);
 }
 
-#define throtl_log_tg(td, tg, fmt, args...)	do {			\
+#define throtl_log_tg(tg, fmt, args...)	do {				\
 	char __pbuf[128];						\
 									\
 	blkg_path(tg_to_blkg(tg), __pbuf, sizeof(__pbuf));		\
-	blk_add_trace_msg((td)->queue, "throtl %s " fmt, __pbuf, ##args); \
+	blk_add_trace_msg((tg)->td->queue, "throtl %s " fmt, __pbuf, ##args); \
 } while (0)
 
 #define throtl_log(td, fmt, args...)	\
@@ -193,6 +196,7 @@ static void throtl_pd_init(struct blkcg_gq *blkg)
 	unsigned long flags;
 
 	RB_CLEAR_NODE(&tg->rb_node);
+	tg->td = blkg->q->td;
 	bio_list_init(&tg->bio_lists[0]);
 	bio_list_init(&tg->bio_lists[1]);
 
@@ -401,36 +405,34 @@ static void throtl_schedule_next_dispatch(struct throtl_data *td)
 		throtl_schedule_delayed_work(td, sq->first_pending_disptime - jiffies);
 }
 
-static inline void
-throtl_start_new_slice(struct throtl_data *td, struct throtl_grp *tg, bool rw)
+static inline void throtl_start_new_slice(struct throtl_grp *tg, bool rw)
 {
 	tg->bytes_disp[rw] = 0;
 	tg->io_disp[rw] = 0;
 	tg->slice_start[rw] = jiffies;
 	tg->slice_end[rw] = jiffies + throtl_slice;
-	throtl_log_tg(td, tg, "[%c] new slice start=%lu end=%lu jiffies=%lu",
+	throtl_log_tg(tg, "[%c] new slice start=%lu end=%lu jiffies=%lu",
 			rw == READ ? 'R' : 'W', tg->slice_start[rw],
 			tg->slice_end[rw], jiffies);
 }
 
-static inline void throtl_set_slice_end(struct throtl_data *td,
-		struct throtl_grp *tg, bool rw, unsigned long jiffy_end)
+static inline void throtl_set_slice_end(struct throtl_grp *tg, bool rw,
+					unsigned long jiffy_end)
 {
 	tg->slice_end[rw] = roundup(jiffy_end, throtl_slice);
 }
 
-static inline void throtl_extend_slice(struct throtl_data *td,
-		struct throtl_grp *tg, bool rw, unsigned long jiffy_end)
+static inline void throtl_extend_slice(struct throtl_grp *tg, bool rw,
+				       unsigned long jiffy_end)
 {
 	tg->slice_end[rw] = roundup(jiffy_end, throtl_slice);
-	throtl_log_tg(td, tg, "[%c] extend slice start=%lu end=%lu jiffies=%lu",
+	throtl_log_tg(tg, "[%c] extend slice start=%lu end=%lu jiffies=%lu",
 			rw == READ ? 'R' : 'W', tg->slice_start[rw],
 			tg->slice_end[rw], jiffies);
 }
 
 /* Determine if previously allocated or extended slice is complete or not */
-static bool
-throtl_slice_used(struct throtl_data *td, struct throtl_grp *tg, bool rw)
+static bool throtl_slice_used(struct throtl_grp *tg, bool rw)
 {
 	if (time_in_range(jiffies, tg->slice_start[rw], tg->slice_end[rw]))
 		return 0;
@@ -439,8 +441,7 @@ throtl_slice_used(struct throtl_data *td, struct throtl_grp *tg, bool rw)
 }
 
 /* Trim the used slices and adjust slice start accordingly */
-static inline void
-throtl_trim_slice(struct throtl_data *td, struct throtl_grp *tg, bool rw)
+static inline void throtl_trim_slice(struct throtl_grp *tg, bool rw)
 {
 	unsigned long nr_slices, time_elapsed, io_trim;
 	u64 bytes_trim, tmp;
@@ -452,7 +453,7 @@ throtl_trim_slice(struct throtl_data *td, struct throtl_grp *tg, bool rw)
 	 * renewed. Don't try to trim the slice if slice is used. A new
 	 * slice will start when appropriate.
 	 */
-	if (throtl_slice_used(td, tg, rw))
+	if (throtl_slice_used(tg, rw))
 		return;
 
 	/*
@@ -463,7 +464,7 @@ throtl_trim_slice(struct throtl_data *td, struct throtl_grp *tg, bool rw)
 	 * is bad because it does not allow new slice to start.
 	 */
 
-	throtl_set_slice_end(td, tg, rw, jiffies + throtl_slice);
+	throtl_set_slice_end(tg, rw, jiffies + throtl_slice);
 
 	time_elapsed = jiffies - tg->slice_start[rw];
 
@@ -492,14 +493,14 @@ throtl_trim_slice(struct throtl_data *td, struct throtl_grp *tg, bool rw)
 
 	tg->slice_start[rw] += nr_slices * throtl_slice;
 
-	throtl_log_tg(td, tg, "[%c] trim slice nr=%lu bytes=%llu io=%lu"
+	throtl_log_tg(tg, "[%c] trim slice nr=%lu bytes=%llu io=%lu"
 			" start=%lu end=%lu jiffies=%lu",
 			rw == READ ? 'R' : 'W', nr_slices, bytes_trim, io_trim,
 			tg->slice_start[rw], tg->slice_end[rw], jiffies);
 }
 
-static bool tg_with_in_iops_limit(struct throtl_data *td, struct throtl_grp *tg,
-		struct bio *bio, unsigned long *wait)
+static bool tg_with_in_iops_limit(struct throtl_grp *tg, struct bio *bio,
+				  unsigned long *wait)
 {
 	bool rw = bio_data_dir(bio);
 	unsigned int io_allowed;
@@ -548,8 +549,8 @@ static bool tg_with_in_iops_limit(struct throtl_data *td, struct throtl_grp *tg,
 	return 0;
 }
 
-static bool tg_with_in_bps_limit(struct throtl_data *td, struct throtl_grp *tg,
-		struct bio *bio, unsigned long *wait)
+static bool tg_with_in_bps_limit(struct throtl_grp *tg, struct bio *bio,
+				 unsigned long *wait)
 {
 	bool rw = bio_data_dir(bio);
 	u64 bytes_allowed, extra_bytes, tmp;
@@ -600,8 +601,8 @@ static bool tg_no_rule_group(struct throtl_grp *tg, bool rw) {
  * Returns whether one can dispatch a bio or not. Also returns approx number
  * of jiffies to wait before this bio is with-in IO rate and can be dispatched
  */
-static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
-				struct bio *bio, unsigned long *wait)
+static bool tg_may_dispatch(struct throtl_grp *tg, struct bio *bio,
+			    unsigned long *wait)
 {
 	bool rw = bio_data_dir(bio);
 	unsigned long bps_wait = 0, iops_wait = 0, max_wait = 0;
@@ -626,15 +627,15 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 	 * existing slice to make sure it is at least throtl_slice interval
 	 * long since now.
 	 */
-	if (throtl_slice_used(td, tg, rw))
-		throtl_start_new_slice(td, tg, rw);
+	if (throtl_slice_used(tg, rw))
+		throtl_start_new_slice(tg, rw);
 	else {
 		if (time_before(tg->slice_end[rw], jiffies + throtl_slice))
-			throtl_extend_slice(td, tg, rw, jiffies + throtl_slice);
+			throtl_extend_slice(tg, rw, jiffies + throtl_slice);
 	}
 
-	if (tg_with_in_bps_limit(td, tg, bio, &bps_wait)
-	    && tg_with_in_iops_limit(td, tg, bio, &iops_wait)) {
+	if (tg_with_in_bps_limit(tg, bio, &bps_wait) &&
+	    tg_with_in_iops_limit(tg, bio, &iops_wait)) {
 		if (wait)
 			*wait = 0;
 		return 1;
@@ -646,7 +647,7 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 		*wait = max_wait;
 
 	if (time_before(tg->slice_end[rw], jiffies + max_wait))
-		throtl_extend_slice(td, tg, rw, jiffies + max_wait);
+		throtl_extend_slice(tg, rw, jiffies + max_wait);
 
 	return 0;
 }
@@ -707,10 +708,10 @@ static void tg_update_disptime(struct throtl_data *td, struct throtl_grp *tg)
 	struct bio *bio;
 
 	if ((bio = bio_list_peek(&tg->bio_lists[READ])))
-		tg_may_dispatch(td, tg, bio, &read_wait);
+		tg_may_dispatch(tg, bio, &read_wait);
 
 	if ((bio = bio_list_peek(&tg->bio_lists[WRITE])))
-		tg_may_dispatch(td, tg, bio, &write_wait);
+		tg_may_dispatch(tg, bio, &write_wait);
 
 	min_wait = min(read_wait, write_wait);
 	disptime = jiffies + min_wait;
@@ -721,8 +722,8 @@ static void tg_update_disptime(struct throtl_data *td, struct throtl_grp *tg)
 	throtl_enqueue_tg(td, tg);
 }
 
-static void tg_dispatch_one_bio(struct throtl_data *td, struct throtl_grp *tg,
-				bool rw, struct bio_list *bl)
+static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
+				struct bio_list *bl)
 {
 	struct bio *bio;
 
@@ -731,18 +732,17 @@ static void tg_dispatch_one_bio(struct throtl_data *td, struct throtl_grp *tg,
 	/* Drop bio reference on blkg */
 	blkg_put(tg_to_blkg(tg));
 
-	BUG_ON(td->nr_queued[rw] <= 0);
-	td->nr_queued[rw]--;
+	BUG_ON(tg->td->nr_queued[rw] <= 0);
+	tg->td->nr_queued[rw]--;
 
 	throtl_charge_bio(tg, bio);
 	bio_list_add(bl, bio);
 	bio->bi_rw |= REQ_THROTTLED;
 
-	throtl_trim_slice(td, tg, rw);
+	throtl_trim_slice(tg, rw);
 }
 
-static int throtl_dispatch_tg(struct throtl_data *td, struct throtl_grp *tg,
-				struct bio_list *bl)
+static int throtl_dispatch_tg(struct throtl_grp *tg, struct bio_list *bl)
 {
 	unsigned int nr_reads = 0, nr_writes = 0;
 	unsigned int max_nr_reads = throtl_grp_quantum*3/4;
@@ -751,20 +751,20 @@ static int throtl_dispatch_tg(struct throtl_data *td, struct throtl_grp *tg,
 
 	/* Try to dispatch 75% READS and 25% WRITES */
 
-	while ((bio = bio_list_peek(&tg->bio_lists[READ]))
-		&& tg_may_dispatch(td, tg, bio, NULL)) {
+	while ((bio = bio_list_peek(&tg->bio_lists[READ])) &&
+	       tg_may_dispatch(tg, bio, NULL)) {
 
-		tg_dispatch_one_bio(td, tg, bio_data_dir(bio), bl);
+		tg_dispatch_one_bio(tg, bio_data_dir(bio), bl);
 		nr_reads++;
 
 		if (nr_reads >= max_nr_reads)
 			break;
 	}
 
-	while ((bio = bio_list_peek(&tg->bio_lists[WRITE]))
-		&& tg_may_dispatch(td, tg, bio, NULL)) {
+	while ((bio = bio_list_peek(&tg->bio_lists[WRITE])) &&
+	       tg_may_dispatch(tg, bio, NULL)) {
 
-		tg_dispatch_one_bio(td, tg, bio_data_dir(bio), bl);
+		tg_dispatch_one_bio(tg, bio_data_dir(bio), bl);
 		nr_writes++;
 
 		if (nr_writes >= max_nr_writes)
@@ -791,7 +791,7 @@ static int throtl_select_dispatch(struct throtl_data *td, struct bio_list *bl)
 
 		throtl_dequeue_tg(td, tg);
 
-		nr_disp += throtl_dispatch_tg(td, tg, bl);
+		nr_disp += throtl_dispatch_tg(tg, bl);
 
 		if (tg->nr_queued[0] || tg->nr_queued[1])
 			tg_update_disptime(td, tg);
@@ -933,7 +933,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	else
 		*(unsigned int *)((void *)tg + cft->private) = ctx.v;
 
-	throtl_log_tg(td, tg, "limit change rbps=%llu wbps=%llu riops=%u wiops=%u",
+	throtl_log_tg(tg, "limit change rbps=%llu wbps=%llu riops=%u wiops=%u",
 		      tg->bps[READ], tg->bps[WRITE],
 		      tg->iops[READ], tg->iops[WRITE]);
 
@@ -945,8 +945,8 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	 * that a group's limit are dropped suddenly and we don't want to
 	 * account recently dispatched IO with new low rate.
 	 */
-	throtl_start_new_slice(td, tg, 0);
-	throtl_start_new_slice(td, tg, 1);
+	throtl_start_new_slice(tg, 0);
+	throtl_start_new_slice(tg, 1);
 
 	if (tg->flags & THROTL_TG_PENDING) {
 		tg_update_disptime(td, tg);
@@ -1079,7 +1079,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	}
 
 	/* Bio is with-in rate limit of group */
-	if (tg_may_dispatch(td, tg, bio, NULL)) {
+	if (tg_may_dispatch(tg, bio, NULL)) {
 		throtl_charge_bio(tg, bio);
 
 		/*
@@ -1093,12 +1093,12 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 		 *
 		 * So keep on trimming slice even if bio is not queued.
 		 */
-		throtl_trim_slice(td, tg, rw);
+		throtl_trim_slice(tg, rw);
 		goto out_unlock;
 	}
 
 queue_bio:
-	throtl_log_tg(td, tg, "[%c] bio. bdisp=%llu sz=%u bps=%llu"
+	throtl_log_tg(tg, "[%c] bio. bdisp=%llu sz=%u bps=%llu"
 			" iodisp=%u iops=%u queued=%d/%d",
 			rw == READ ? 'R' : 'W',
 			tg->bytes_disp[rw], bio->bi_size, tg->bps[rw],
@@ -1145,9 +1145,9 @@ void blk_throtl_drain(struct request_queue *q)
 		throtl_dequeue_tg(td, tg);
 
 		while ((bio = bio_list_peek(&tg->bio_lists[READ])))
-			tg_dispatch_one_bio(td, tg, bio_data_dir(bio), &bl);
+			tg_dispatch_one_bio(tg, bio_data_dir(bio), &bl);
 		while ((bio = bio_list_peek(&tg->bio_lists[WRITE])))
-			tg_dispatch_one_bio(td, tg, bio_data_dir(bio), &bl);
+			tg_dispatch_one_bio(tg, bio_data_dir(bio), &bl);
 	}
 	spin_unlock_irq(q->queue_lock);
 
-- 
1.8.1.4
