From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 17/33] blk-throttle: move bio_lists[] and friends to
	throtl_service_queue
Date: Mon,  6 May 2013 15:45:56 -0700
Message-ID: <1367880372-28312-18-git-send-email-tj__16469.1180260435$1367880591$gmane$org@kernel.org>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367880372-28312-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

throtl_service_queues will eventually form a tree which is anchored at
throtl_data->service_queue and queue bios will climb the tree to the
top service_queue to be executed.

This patch moves bio_lists[] and nr_queued[] from throtl_grp to its
service_queue to prepare for that.  As currently only the
throtl_data->service_queue is in use, this patch just ends up moving
throtl_grp->bio_lists[] and ->nr_queued[] to
throtl_grp->service_queue.bio_lists[] and ->nr_queued[] without making
any functional differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 63 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 39 insertions(+), 24 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 7340440..6f57f94 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -27,6 +27,17 @@ static struct blkcg_policy blkcg_policy_throtl;
 static struct workqueue_struct *kthrotld_workqueue;
 
 struct throtl_service_queue {
+	/*
+	 * Bios queued directly to this service_queue or dispatched from
+	 * children throtl_grp's.
+	 */
+	struct bio_list		bio_lists[2];	/* queued bios [READ/WRITE] */
+	unsigned int		nr_queued[2];	/* number of queued bios */
+
+	/*
+	 * RB tree of active children throtl_grp's, which are sorted by
+	 * their ->disptime.
+	 */
 	struct rb_root		pending_tree;	/* RB tree of active tgs */
 	struct rb_node		*first_pending;	/* first node in the tree */
 	unsigned int		nr_pending;	/* # queued in the tree */
@@ -69,12 +80,6 @@ struct throtl_grp {
 
 	unsigned int flags;
 
-	/* Two lists for READ and WRITE */
-	struct bio_list bio_lists[2];
-
-	/* Number of queued bios on READ and WRITE lists */
-	unsigned int nr_queued[2];
-
 	/* bytes per second rate limits */
 	uint64_t bps[2];
 
@@ -193,6 +198,8 @@ alloc_stats:
 /* init a service_queue, assumes the caller zeroed it */
 static void throtl_service_queue_init(struct throtl_service_queue *sq)
 {
+	bio_list_init(&sq->bio_lists[0]);
+	bio_list_init(&sq->bio_lists[1]);
 	sq->pending_tree = RB_ROOT;
 }
 
@@ -204,8 +211,6 @@ static void throtl_pd_init(struct blkcg_gq *blkg)
 	throtl_service_queue_init(&tg->service_queue);
 	RB_CLEAR_NODE(&tg->rb_node);
 	tg->td = blkg->q->td;
-	bio_list_init(&tg->bio_lists[0]);
-	bio_list_init(&tg->bio_lists[1]);
 
 	tg->bps[READ] = -1;
 	tg->bps[WRITE] = -1;
@@ -624,7 +629,8 @@ static bool tg_may_dispatch(struct throtl_grp *tg, struct bio *bio,
 	 * this function with a different bio if there are other bios
 	 * queued.
 	 */
-	BUG_ON(tg->nr_queued[rw] && bio != bio_list_peek(&tg->bio_lists[rw]));
+	BUG_ON(tg->service_queue.nr_queued[rw] &&
+	       bio != bio_list_peek(&tg->service_queue.bio_lists[rw]));
 
 	/* If tg->bps = -1, then BW is unlimited */
 	if (tg->bps[rw] == -1 && tg->iops[rw] == -1) {
@@ -703,12 +709,13 @@ static void throtl_charge_bio(struct throtl_grp *tg, struct bio *bio)
 static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg,
 			      struct throtl_service_queue *parent_sq)
 {
+	struct throtl_service_queue *sq = &tg->service_queue;
 	bool rw = bio_data_dir(bio);
 
-	bio_list_add(&tg->bio_lists[rw], bio);
+	bio_list_add(&sq->bio_lists[rw], bio);
 	/* Take a bio reference on tg */
 	blkg_get(tg_to_blkg(tg));
-	tg->nr_queued[rw]++;
+	sq->nr_queued[rw]++;
 	tg->td->nr_queued[rw]++;
 	throtl_enqueue_tg(tg, parent_sq);
 }
@@ -716,13 +723,14 @@ static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg,
 static void tg_update_disptime(struct throtl_grp *tg,
 			       struct throtl_service_queue *parent_sq)
 {
+	struct throtl_service_queue *sq = &tg->service_queue;
 	unsigned long read_wait = -1, write_wait = -1, min_wait = -1, disptime;
 	struct bio *bio;
 
-	if ((bio = bio_list_peek(&tg->bio_lists[READ])))
+	if ((bio = bio_list_peek(&sq->bio_lists[READ])))
 		tg_may_dispatch(tg, bio, &read_wait);
 
-	if ((bio = bio_list_peek(&tg->bio_lists[WRITE])))
+	if ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
 		tg_may_dispatch(tg, bio, &write_wait);
 
 	min_wait = min(read_wait, write_wait);
@@ -737,10 +745,11 @@ static void tg_update_disptime(struct throtl_grp *tg,
 static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
 				struct bio_list *bl)
 {
+	struct throtl_service_queue *sq = &tg->service_queue;
 	struct bio *bio;
 
-	bio = bio_list_pop(&tg->bio_lists[rw]);
-	tg->nr_queued[rw]--;
+	bio = bio_list_pop(&sq->bio_lists[rw]);
+	sq->nr_queued[rw]--;
 	/* Drop bio reference on blkg */
 	blkg_put(tg_to_blkg(tg));
 
@@ -756,6 +765,7 @@ static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
 
 static int throtl_dispatch_tg(struct throtl_grp *tg, struct bio_list *bl)
 {
+	struct throtl_service_queue *sq = &tg->service_queue;
 	unsigned int nr_reads = 0, nr_writes = 0;
 	unsigned int max_nr_reads = throtl_grp_quantum*3/4;
 	unsigned int max_nr_writes = throtl_grp_quantum - max_nr_reads;
@@ -763,7 +773,7 @@ static int throtl_dispatch_tg(struct throtl_grp *tg, struct bio_list *bl)
 
 	/* Try to dispatch 75% READS and 25% WRITES */
 
-	while ((bio = bio_list_peek(&tg->bio_lists[READ])) &&
+	while ((bio = bio_list_peek(&sq->bio_lists[READ])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(tg, bio_data_dir(bio), bl);
@@ -773,7 +783,7 @@ static int throtl_dispatch_tg(struct throtl_grp *tg, struct bio_list *bl)
 			break;
 	}
 
-	while ((bio = bio_list_peek(&tg->bio_lists[WRITE])) &&
+	while ((bio = bio_list_peek(&sq->bio_lists[WRITE])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(tg, bio_data_dir(bio), bl);
@@ -790,10 +800,10 @@ static int throtl_select_dispatch(struct throtl_service_queue *parent_sq,
 				  struct bio_list *bl)
 {
 	unsigned int nr_disp = 0;
-	struct throtl_grp *tg;
 
 	while (1) {
-		tg = throtl_rb_first(parent_sq);
+		struct throtl_grp *tg = throtl_rb_first(parent_sq);
+		struct throtl_service_queue *sq = &tg->service_queue;
 
 		if (!tg)
 			break;
@@ -805,7 +815,7 @@ static int throtl_select_dispatch(struct throtl_service_queue *parent_sq,
 
 		nr_disp += throtl_dispatch_tg(tg, bl);
 
-		if (tg->nr_queued[0] || tg->nr_queued[1])
+		if (sq->nr_queued[0] || sq->nr_queued[1])
 			tg_update_disptime(tg, parent_sq);
 
 		if (nr_disp >= throtl_quantum)
@@ -1043,6 +1053,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 {
 	struct throtl_data *td = q->td;
 	struct throtl_grp *tg;
+	struct throtl_service_queue *sq;
 	bool rw = bio_data_dir(bio), update_disptime = true;
 	struct blkcg *blkcg;
 	bool throttled = false;
@@ -1077,7 +1088,9 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	if (unlikely(!tg))
 		goto out_unlock;
 
-	if (tg->nr_queued[rw]) {
+	sq = &tg->service_queue;
+
+	if (sq->nr_queued[rw]) {
 		/*
 		 * There is already another bio queued in same dir. No
 		 * need to update dispatch time.
@@ -1112,7 +1125,7 @@ queue_bio:
 			rw == READ ? 'R' : 'W',
 			tg->bytes_disp[rw], bio->bi_size, tg->bps[rw],
 			tg->io_disp[rw], tg->iops[rw],
-			tg->nr_queued[READ], tg->nr_queued[WRITE]);
+			sq->nr_queued[READ], sq->nr_queued[WRITE]);
 
 	bio_associate_current(bio);
 	throtl_add_bio_tg(bio, tg, &q->td->service_queue);
@@ -1151,11 +1164,13 @@ void blk_throtl_drain(struct request_queue *q)
 	bio_list_init(&bl);
 
 	while ((tg = throtl_rb_first(parent_sq))) {
+		struct throtl_service_queue *sq = &tg->service_queue;
+
 		throtl_dequeue_tg(tg, parent_sq);
 
-		while ((bio = bio_list_peek(&tg->bio_lists[READ])))
+		while ((bio = bio_list_peek(&sq->bio_lists[READ])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio), &bl);
-		while ((bio = bio_list_peek(&tg->bio_lists[WRITE])))
+		while ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio), &bl);
 	}
 	spin_unlock_irq(q->queue_lock);
-- 
1.8.1.4
