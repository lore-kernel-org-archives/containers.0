From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 20/33] blk-throttle: add throtl_service_queue->parent_sq
Date: Mon,  6 May 2013 15:45:59 -0700
Message-ID: <1367880372-28312-21-git-send-email-tj@kernel.org>
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

To prepare for hierarchy support, this patch adds
throtl_service_queue->service_sq which points to the arent
service_queue.  Currently, for all service_queues embedded in
throtl_grps, it points to throtl_data->service_queue.  As
throtl_data->service_queue doesn't have a parent its parent_sq is set
to NULL.

There are a number of functions which take both throtl_grp *tg and
throtl_service_queue *parent_sq.  With this patch, the parent
service_queue can be determined from @tg and the @parent_sq arguments
are removed.

This patch doesn't make any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 81 +++++++++++++++++++++++++---------------------------
 1 file changed, 39 insertions(+), 42 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index ec9397f..00cfdd0 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -27,6 +27,8 @@ static struct blkcg_policy blkcg_policy_throtl;
 static struct workqueue_struct *kthrotld_workqueue;
 
 struct throtl_service_queue {
+	struct throtl_service_queue *parent_sq;	/* the parent service_queue */
+
 	/*
 	 * Bios queued directly to this service_queue or dispatched from
 	 * children throtl_grp's.
@@ -197,21 +199,24 @@ alloc_stats:
 }
 
 /* init a service_queue, assumes the caller zeroed it */
-static void throtl_service_queue_init(struct throtl_service_queue *sq)
+static void throtl_service_queue_init(struct throtl_service_queue *sq,
+				      struct throtl_service_queue *parent_sq)
 {
 	bio_list_init(&sq->bio_lists[0]);
 	bio_list_init(&sq->bio_lists[1]);
 	sq->pending_tree = RB_ROOT;
+	sq->parent_sq = parent_sq;
 }
 
 static void throtl_pd_init(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
+	struct throtl_data *td = blkg->q->td;
 	unsigned long flags;
 
-	throtl_service_queue_init(&tg->service_queue);
+	throtl_service_queue_init(&tg->service_queue, &td->service_queue);
 	RB_CLEAR_NODE(&tg->rb_node);
-	tg->td = blkg->q->td;
+	tg->td = td;
 
 	tg->bps[READ] = -1;
 	tg->bps[WRITE] = -1;
@@ -339,9 +344,9 @@ static void update_min_dispatch_time(struct throtl_service_queue *parent_sq)
 	parent_sq->first_pending_disptime = tg->disptime;
 }
 
-static void tg_service_queue_add(struct throtl_grp *tg,
-				 struct throtl_service_queue *parent_sq)
+static void tg_service_queue_add(struct throtl_grp *tg)
 {
+	struct throtl_service_queue *parent_sq = tg->service_queue.parent_sq;
 	struct rb_node **node = &parent_sq->pending_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct throtl_grp *__tg;
@@ -367,33 +372,29 @@ static void tg_service_queue_add(struct throtl_grp *tg,
 	rb_insert_color(&tg->rb_node, &parent_sq->pending_tree);
 }
 
-static void __throtl_enqueue_tg(struct throtl_grp *tg,
-				struct throtl_service_queue *parent_sq)
+static void __throtl_enqueue_tg(struct throtl_grp *tg)
 {
-	tg_service_queue_add(tg, parent_sq);
+	tg_service_queue_add(tg);
 	tg->flags |= THROTL_TG_PENDING;
-	parent_sq->nr_pending++;
+	tg->service_queue.parent_sq->nr_pending++;
 }
 
-static void throtl_enqueue_tg(struct throtl_grp *tg,
-			      struct throtl_service_queue *parent_sq)
+static void throtl_enqueue_tg(struct throtl_grp *tg)
 {
 	if (!(tg->flags & THROTL_TG_PENDING))
-		__throtl_enqueue_tg(tg, parent_sq);
+		__throtl_enqueue_tg(tg);
 }
 
-static void __throtl_dequeue_tg(struct throtl_grp *tg,
-				struct throtl_service_queue *parent_sq)
+static void __throtl_dequeue_tg(struct throtl_grp *tg)
 {
-	throtl_rb_erase(&tg->rb_node, parent_sq);
+	throtl_rb_erase(&tg->rb_node, tg->service_queue.parent_sq);
 	tg->flags &= ~THROTL_TG_PENDING;
 }
 
-static void throtl_dequeue_tg(struct throtl_grp *tg,
-			      struct throtl_service_queue *parent_sq)
+static void throtl_dequeue_tg(struct throtl_grp *tg)
 {
 	if (tg->flags & THROTL_TG_PENDING)
-		__throtl_dequeue_tg(tg, parent_sq);
+		__throtl_dequeue_tg(tg);
 }
 
 /* Call with queue lock held */
@@ -707,8 +708,7 @@ static void throtl_charge_bio(struct throtl_grp *tg, struct bio *bio)
 	throtl_update_dispatch_stats(tg_to_blkg(tg), bio->bi_size, bio->bi_rw);
 }
 
-static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg,
-			      struct throtl_service_queue *parent_sq)
+static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
 	bool rw = bio_data_dir(bio);
@@ -727,11 +727,10 @@ static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg,
 	blkg_get(tg_to_blkg(tg));
 	sq->nr_queued[rw]++;
 	tg->td->nr_queued[rw]++;
-	throtl_enqueue_tg(tg, parent_sq);
+	throtl_enqueue_tg(tg);
 }
 
-static void tg_update_disptime(struct throtl_grp *tg,
-			       struct throtl_service_queue *parent_sq)
+static void tg_update_disptime(struct throtl_grp *tg)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
 	unsigned long read_wait = -1, write_wait = -1, min_wait = -1, disptime;
@@ -747,16 +746,15 @@ static void tg_update_disptime(struct throtl_grp *tg,
 	disptime = jiffies + min_wait;
 
 	/* Update dispatch time */
-	throtl_dequeue_tg(tg, parent_sq);
+	throtl_dequeue_tg(tg);
 	tg->disptime = disptime;
-	throtl_enqueue_tg(tg, parent_sq);
+	throtl_enqueue_tg(tg);
 
 	/* see throtl_add_bio_tg() */
 	tg->flags &= ~THROTL_TG_WAS_EMPTY;
 }
 
-static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
-				struct throtl_service_queue *parent_sq)
+static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
 	struct bio *bio;
@@ -770,14 +768,13 @@ static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
 	tg->td->nr_queued[rw]--;
 
 	throtl_charge_bio(tg, bio);
-	bio_list_add(&parent_sq->bio_lists[rw], bio);
+	bio_list_add(&sq->parent_sq->bio_lists[rw], bio);
 	bio->bi_rw |= REQ_THROTTLED;
 
 	throtl_trim_slice(tg, rw);
 }
 
-static int throtl_dispatch_tg(struct throtl_grp *tg,
-			      struct throtl_service_queue *parent_sq)
+static int throtl_dispatch_tg(struct throtl_grp *tg)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
 	unsigned int nr_reads = 0, nr_writes = 0;
@@ -790,7 +787,7 @@ static int throtl_dispatch_tg(struct throtl_grp *tg,
 	while ((bio = bio_list_peek(&sq->bio_lists[READ])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
-		tg_dispatch_one_bio(tg, bio_data_dir(bio), parent_sq);
+		tg_dispatch_one_bio(tg, bio_data_dir(bio));
 		nr_reads++;
 
 		if (nr_reads >= max_nr_reads)
@@ -800,7 +797,7 @@ static int throtl_dispatch_tg(struct throtl_grp *tg,
 	while ((bio = bio_list_peek(&sq->bio_lists[WRITE])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
-		tg_dispatch_one_bio(tg, bio_data_dir(bio), parent_sq);
+		tg_dispatch_one_bio(tg, bio_data_dir(bio));
 		nr_writes++;
 
 		if (nr_writes >= max_nr_writes)
@@ -824,12 +821,12 @@ static int throtl_select_dispatch(struct throtl_service_queue *parent_sq)
 		if (time_before(jiffies, tg->disptime))
 			break;
 
-		throtl_dequeue_tg(tg, parent_sq);
+		throtl_dequeue_tg(tg);
 
-		nr_disp += throtl_dispatch_tg(tg, parent_sq);
+		nr_disp += throtl_dispatch_tg(tg);
 
 		if (sq->nr_queued[0] || sq->nr_queued[1])
-			tg_update_disptime(tg, parent_sq);
+			tg_update_disptime(tg);
 
 		if (nr_disp >= throtl_quantum)
 			break;
@@ -991,7 +988,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	throtl_start_new_slice(tg, 1);
 
 	if (tg->flags & THROTL_TG_PENDING) {
-		tg_update_disptime(tg, &td->service_queue);
+		tg_update_disptime(tg);
 		throtl_schedule_next_dispatch(td);
 	}
 
@@ -1142,12 +1139,12 @@ queue_bio:
 			sq->nr_queued[READ], sq->nr_queued[WRITE]);
 
 	bio_associate_current(bio);
-	throtl_add_bio_tg(bio, tg, &q->td->service_queue);
+	throtl_add_bio_tg(bio, tg);
 	throttled = true;
 
 	/* update @tg's dispatch time if @tg was empty before @bio */
 	if (tg->flags & THROTL_TG_WAS_EMPTY) {
-		tg_update_disptime(tg, &td->service_queue);
+		tg_update_disptime(tg);
 		throtl_schedule_next_dispatch(td);
 	}
 
@@ -1179,12 +1176,12 @@ void blk_throtl_drain(struct request_queue *q)
 	while ((tg = throtl_rb_first(parent_sq))) {
 		struct throtl_service_queue *sq = &tg->service_queue;
 
-		throtl_dequeue_tg(tg, parent_sq);
+		throtl_dequeue_tg(tg);
 
 		while ((bio = bio_list_peek(&sq->bio_lists[READ])))
-			tg_dispatch_one_bio(tg, bio_data_dir(bio), parent_sq);
+			tg_dispatch_one_bio(tg, bio_data_dir(bio));
 		while ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
-			tg_dispatch_one_bio(tg, bio_data_dir(bio), parent_sq);
+			tg_dispatch_one_bio(tg, bio_data_dir(bio));
 	}
 	spin_unlock_irq(q->queue_lock);
 
@@ -1205,7 +1202,7 @@ int blk_throtl_init(struct request_queue *q)
 		return -ENOMEM;
 
 	INIT_DELAYED_WORK(&td->dispatch_work, blk_throtl_dispatch_work_fn);
-	throtl_service_queue_init(&td->service_queue);
+	throtl_service_queue_init(&td->service_queue, NULL);
 
 	q->td = td;
 	td->queue = q;
-- 
1.8.1.4
