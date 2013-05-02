From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/31] blk-throttle: pass around throtl_service_queue instead
	of throtl_data
Date: Wed,  1 May 2013 17:39:32 -0700
Message-ID: <1367455189-6957-15-git-send-email-tj@kernel.org>
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

throtl_service_queue will be used as the basic block to implement
hierarchy support.  Pass around throtl_service_queue *sq instead of
throtl_data *td in the following functions which will be used across
multiple levels of hierarchy.

* [__]throtl_enqueue/dequeue_tg()

* throtl_add_bio_tg()

* tg_update_disptime()

* throtl_select_dispatch()

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 53 +++++++++++++++++++++++++++-------------------------
 1 file changed, 28 insertions(+), 25 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 6aae239..a81e10b 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -352,31 +352,33 @@ static void tg_service_queue_add(struct throtl_service_queue *sq,
 	rb_insert_color(&tg->rb_node, &sq->pending_tree);
 }
 
-static void __throtl_enqueue_tg(struct throtl_data *td, struct throtl_grp *tg)
+static void __throtl_enqueue_tg(struct throtl_service_queue *sq,
+				struct throtl_grp *tg)
 {
-	struct throtl_service_queue *sq = &td->service_queue;
-
 	tg_service_queue_add(sq, tg);
 	tg->flags |= THROTL_TG_PENDING;
 	sq->nr_pending++;
 }
 
-static void throtl_enqueue_tg(struct throtl_data *td, struct throtl_grp *tg)
+static void throtl_enqueue_tg(struct throtl_service_queue *sq,
+			      struct throtl_grp *tg)
 {
 	if (!(tg->flags & THROTL_TG_PENDING))
-		__throtl_enqueue_tg(td, tg);
+		__throtl_enqueue_tg(sq, tg);
 }
 
-static void __throtl_dequeue_tg(struct throtl_data *td, struct throtl_grp *tg)
+static void __throtl_dequeue_tg(struct throtl_service_queue *sq,
+				struct throtl_grp *tg)
 {
-	throtl_rb_erase(&tg->rb_node, &td->service_queue);
+	throtl_rb_erase(&tg->rb_node, sq);
 	tg->flags &= ~THROTL_TG_PENDING;
 }
 
-static void throtl_dequeue_tg(struct throtl_data *td, struct throtl_grp *tg)
+static void throtl_dequeue_tg(struct throtl_service_queue *sq,
+			      struct throtl_grp *tg)
 {
 	if (tg->flags & THROTL_TG_PENDING)
-		__throtl_dequeue_tg(td, tg);
+		__throtl_dequeue_tg(sq, tg);
 }
 
 /* Call with queue lock held */
@@ -689,8 +691,8 @@ static void throtl_charge_bio(struct throtl_grp *tg, struct bio *bio)
 	throtl_update_dispatch_stats(tg_to_blkg(tg), bio->bi_size, bio->bi_rw);
 }
 
-static void throtl_add_bio_tg(struct throtl_data *td, struct throtl_grp *tg,
-			struct bio *bio)
+static void throtl_add_bio_tg(struct throtl_service_queue *sq,
+			      struct throtl_grp *tg, struct bio *bio)
 {
 	bool rw = bio_data_dir(bio);
 
@@ -698,11 +700,12 @@ static void throtl_add_bio_tg(struct throtl_data *td, struct throtl_grp *tg,
 	/* Take a bio reference on tg */
 	blkg_get(tg_to_blkg(tg));
 	tg->nr_queued[rw]++;
-	td->nr_queued[rw]++;
-	throtl_enqueue_tg(td, tg);
+	tg->td->nr_queued[rw]++;
+	throtl_enqueue_tg(sq, tg);
 }
 
-static void tg_update_disptime(struct throtl_data *td, struct throtl_grp *tg)
+static void tg_update_disptime(struct throtl_service_queue *sq,
+			       struct throtl_grp *tg)
 {
 	unsigned long read_wait = -1, write_wait = -1, min_wait = -1, disptime;
 	struct bio *bio;
@@ -717,9 +720,9 @@ static void tg_update_disptime(struct throtl_data *td, struct throtl_grp *tg)
 	disptime = jiffies + min_wait;
 
 	/* Update dispatch time */
-	throtl_dequeue_tg(td, tg);
+	throtl_dequeue_tg(sq, tg);
 	tg->disptime = disptime;
-	throtl_enqueue_tg(td, tg);
+	throtl_enqueue_tg(sq, tg);
 }
 
 static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
@@ -774,11 +777,11 @@ static int throtl_dispatch_tg(struct throtl_grp *tg, struct bio_list *bl)
 	return nr_reads + nr_writes;
 }
 
-static int throtl_select_dispatch(struct throtl_data *td, struct bio_list *bl)
+static int throtl_select_dispatch(struct throtl_service_queue *sq,
+				  struct bio_list *bl)
 {
 	unsigned int nr_disp = 0;
 	struct throtl_grp *tg;
-	struct throtl_service_queue *sq = &td->service_queue;
 
 	while (1) {
 		tg = throtl_rb_first(sq);
@@ -789,12 +792,12 @@ static int throtl_select_dispatch(struct throtl_data *td, struct bio_list *bl)
 		if (time_before(jiffies, tg->disptime))
 			break;
 
-		throtl_dequeue_tg(td, tg);
+		throtl_dequeue_tg(sq, tg);
 
 		nr_disp += throtl_dispatch_tg(tg, bl);
 
 		if (tg->nr_queued[0] || tg->nr_queued[1])
-			tg_update_disptime(td, tg);
+			tg_update_disptime(sq, tg);
 
 		if (nr_disp >= throtl_quantum)
 			break;
@@ -822,7 +825,7 @@ void blk_throtl_dispatch_work_fn(struct work_struct *work)
 		   td->nr_queued[READ] + td->nr_queued[WRITE],
 		   td->nr_queued[READ], td->nr_queued[WRITE]);
 
-	nr_disp = throtl_select_dispatch(td, &bio_list_on_stack);
+	nr_disp = throtl_select_dispatch(&td->service_queue, &bio_list_on_stack);
 
 	if (nr_disp)
 		throtl_log(td, "bios disp=%u", nr_disp);
@@ -949,7 +952,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	throtl_start_new_slice(tg, 1);
 
 	if (tg->flags & THROTL_TG_PENDING) {
-		tg_update_disptime(td, tg);
+		tg_update_disptime(&td->service_queue, tg);
 		throtl_schedule_next_dispatch(td);
 	}
 
@@ -1106,11 +1109,11 @@ queue_bio:
 			tg->nr_queued[READ], tg->nr_queued[WRITE]);
 
 	bio_associate_current(bio);
-	throtl_add_bio_tg(q->td, tg, bio);
+	throtl_add_bio_tg(&q->td->service_queue, tg, bio);
 	throttled = true;
 
 	if (update_disptime) {
-		tg_update_disptime(td, tg);
+		tg_update_disptime(&td->service_queue, tg);
 		throtl_schedule_next_dispatch(td);
 	}
 
@@ -1142,7 +1145,7 @@ void blk_throtl_drain(struct request_queue *q)
 	bio_list_init(&bl);
 
 	while ((tg = throtl_rb_first(sq))) {
-		throtl_dequeue_tg(td, tg);
+		throtl_dequeue_tg(sq, tg);
 
 		while ((bio = bio_list_peek(&tg->bio_lists[READ])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio), &bl);
-- 
1.8.1.4
