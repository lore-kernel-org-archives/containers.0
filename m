From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 15/33] blk-throttle: reorganize throtl_service_queue passed
	around as argument
Date: Mon,  6 May 2013 15:45:54 -0700
Message-ID: <1367880372-28312-16-git-send-email-tj@kernel.org>
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

throtl_service_queue will be the building block of hierarchy support
and will form a tree.  This patch updates its usages as arguments to
reduce confusion.

* When a service queue is used as the parent role - the host of the
  rbtree - use @parent_sq instead of @sq.

* For functions taking both @tg and @parent_sq, reorder them so that
  the order is (@tg, @parent_sq) not the other way around.  This makes
  the code follow the usual convention of specifying the primary
  target of the operation as the first argument.

This patch doesn't make any functional differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 100 ++++++++++++++++++++++++++-------------------------
 1 file changed, 51 insertions(+), 49 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 9660ec8..ebaaaa9 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -284,17 +284,18 @@ static struct throtl_grp *throtl_lookup_create_tg(struct throtl_data *td,
 	return tg;
 }
 
-static struct throtl_grp *throtl_rb_first(struct throtl_service_queue *sq)
+static struct throtl_grp *
+throtl_rb_first(struct throtl_service_queue *parent_sq)
 {
 	/* Service tree is empty */
-	if (!sq->nr_pending)
+	if (!parent_sq->nr_pending)
 		return NULL;
 
-	if (!sq->first_pending)
-		sq->first_pending = rb_first(&sq->pending_tree);
+	if (!parent_sq->first_pending)
+		parent_sq->first_pending = rb_first(&parent_sq->pending_tree);
 
-	if (sq->first_pending)
-		return rb_entry_tg(sq->first_pending);
+	if (parent_sq->first_pending)
+		return rb_entry_tg(parent_sq->first_pending);
 
 	return NULL;
 }
@@ -305,29 +306,30 @@ static void rb_erase_init(struct rb_node *n, struct rb_root *root)
 	RB_CLEAR_NODE(n);
 }
 
-static void throtl_rb_erase(struct rb_node *n, struct throtl_service_queue *sq)
+static void throtl_rb_erase(struct rb_node *n,
+			    struct throtl_service_queue *parent_sq)
 {
-	if (sq->first_pending == n)
-		sq->first_pending = NULL;
-	rb_erase_init(n, &sq->pending_tree);
-	--sq->nr_pending;
+	if (parent_sq->first_pending == n)
+		parent_sq->first_pending = NULL;
+	rb_erase_init(n, &parent_sq->pending_tree);
+	--parent_sq->nr_pending;
 }
 
-static void update_min_dispatch_time(struct throtl_service_queue *sq)
+static void update_min_dispatch_time(struct throtl_service_queue *parent_sq)
 {
 	struct throtl_grp *tg;
 
-	tg = throtl_rb_first(sq);
+	tg = throtl_rb_first(parent_sq);
 	if (!tg)
 		return;
 
-	sq->first_pending_disptime = tg->disptime;
+	parent_sq->first_pending_disptime = tg->disptime;
 }
 
-static void tg_service_queue_add(struct throtl_service_queue *sq,
-				 struct throtl_grp *tg)
+static void tg_service_queue_add(struct throtl_grp *tg,
+				 struct throtl_service_queue *parent_sq)
 {
-	struct rb_node **node = &sq->pending_tree.rb_node;
+	struct rb_node **node = &parent_sq->pending_tree.rb_node;
 	struct rb_node *parent = NULL;
 	struct throtl_grp *__tg;
 	unsigned long key = tg->disptime;
@@ -346,39 +348,39 @@ static void tg_service_queue_add(struct throtl_service_queue *sq,
 	}
 
 	if (left)
-		sq->first_pending = &tg->rb_node;
+		parent_sq->first_pending = &tg->rb_node;
 
 	rb_link_node(&tg->rb_node, parent, node);
-	rb_insert_color(&tg->rb_node, &sq->pending_tree);
+	rb_insert_color(&tg->rb_node, &parent_sq->pending_tree);
 }
 
-static void __throtl_enqueue_tg(struct throtl_service_queue *sq,
-				struct throtl_grp *tg)
+static void __throtl_enqueue_tg(struct throtl_grp *tg,
+				struct throtl_service_queue *parent_sq)
 {
-	tg_service_queue_add(sq, tg);
+	tg_service_queue_add(tg, parent_sq);
 	tg->flags |= THROTL_TG_PENDING;
-	sq->nr_pending++;
+	parent_sq->nr_pending++;
 }
 
-static void throtl_enqueue_tg(struct throtl_service_queue *sq,
-			      struct throtl_grp *tg)
+static void throtl_enqueue_tg(struct throtl_grp *tg,
+			      struct throtl_service_queue *parent_sq)
 {
 	if (!(tg->flags & THROTL_TG_PENDING))
-		__throtl_enqueue_tg(sq, tg);
+		__throtl_enqueue_tg(tg, parent_sq);
 }
 
-static void __throtl_dequeue_tg(struct throtl_service_queue *sq,
-				struct throtl_grp *tg)
+static void __throtl_dequeue_tg(struct throtl_grp *tg,
+				struct throtl_service_queue *parent_sq)
 {
-	throtl_rb_erase(&tg->rb_node, sq);
+	throtl_rb_erase(&tg->rb_node, parent_sq);
 	tg->flags &= ~THROTL_TG_PENDING;
 }
 
-static void throtl_dequeue_tg(struct throtl_service_queue *sq,
-			      struct throtl_grp *tg)
+static void throtl_dequeue_tg(struct throtl_grp *tg,
+			      struct throtl_service_queue *parent_sq)
 {
 	if (tg->flags & THROTL_TG_PENDING)
-		__throtl_dequeue_tg(sq, tg);
+		__throtl_dequeue_tg(tg, parent_sq);
 }
 
 /* Call with queue lock held */
@@ -691,8 +693,8 @@ static void throtl_charge_bio(struct throtl_grp *tg, struct bio *bio)
 	throtl_update_dispatch_stats(tg_to_blkg(tg), bio->bi_size, bio->bi_rw);
 }
 
-static void throtl_add_bio_tg(struct throtl_service_queue *sq,
-			      struct throtl_grp *tg, struct bio *bio)
+static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg,
+			      struct throtl_service_queue *parent_sq)
 {
 	bool rw = bio_data_dir(bio);
 
@@ -701,11 +703,11 @@ static void throtl_add_bio_tg(struct throtl_service_queue *sq,
 	blkg_get(tg_to_blkg(tg));
 	tg->nr_queued[rw]++;
 	tg->td->nr_queued[rw]++;
-	throtl_enqueue_tg(sq, tg);
+	throtl_enqueue_tg(tg, parent_sq);
 }
 
-static void tg_update_disptime(struct throtl_service_queue *sq,
-			       struct throtl_grp *tg)
+static void tg_update_disptime(struct throtl_grp *tg,
+			       struct throtl_service_queue *parent_sq)
 {
 	unsigned long read_wait = -1, write_wait = -1, min_wait = -1, disptime;
 	struct bio *bio;
@@ -720,9 +722,9 @@ static void tg_update_disptime(struct throtl_service_queue *sq,
 	disptime = jiffies + min_wait;
 
 	/* Update dispatch time */
-	throtl_dequeue_tg(sq, tg);
+	throtl_dequeue_tg(tg, parent_sq);
 	tg->disptime = disptime;
-	throtl_enqueue_tg(sq, tg);
+	throtl_enqueue_tg(tg, parent_sq);
 }
 
 static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw,
@@ -777,14 +779,14 @@ static int throtl_dispatch_tg(struct throtl_grp *tg, struct bio_list *bl)
 	return nr_reads + nr_writes;
 }
 
-static int throtl_select_dispatch(struct throtl_service_queue *sq,
+static int throtl_select_dispatch(struct throtl_service_queue *parent_sq,
 				  struct bio_list *bl)
 {
 	unsigned int nr_disp = 0;
 	struct throtl_grp *tg;
 
 	while (1) {
-		tg = throtl_rb_first(sq);
+		tg = throtl_rb_first(parent_sq);
 
 		if (!tg)
 			break;
@@ -792,12 +794,12 @@ static int throtl_select_dispatch(struct throtl_service_queue *sq,
 		if (time_before(jiffies, tg->disptime))
 			break;
 
-		throtl_dequeue_tg(sq, tg);
+		throtl_dequeue_tg(tg, parent_sq);
 
 		nr_disp += throtl_dispatch_tg(tg, bl);
 
 		if (tg->nr_queued[0] || tg->nr_queued[1])
-			tg_update_disptime(sq, tg);
+			tg_update_disptime(tg, parent_sq);
 
 		if (nr_disp >= throtl_quantum)
 			break;
@@ -952,7 +954,7 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	throtl_start_new_slice(tg, 1);
 
 	if (tg->flags & THROTL_TG_PENDING) {
-		tg_update_disptime(&td->service_queue, tg);
+		tg_update_disptime(tg, &td->service_queue);
 		throtl_schedule_next_dispatch(td);
 	}
 
@@ -1106,11 +1108,11 @@ queue_bio:
 			tg->nr_queued[READ], tg->nr_queued[WRITE]);
 
 	bio_associate_current(bio);
-	throtl_add_bio_tg(&q->td->service_queue, tg, bio);
+	throtl_add_bio_tg(bio, tg, &q->td->service_queue);
 	throttled = true;
 
 	if (update_disptime) {
-		tg_update_disptime(&td->service_queue, tg);
+		tg_update_disptime(tg, &td->service_queue);
 		throtl_schedule_next_dispatch(td);
 	}
 
@@ -1132,7 +1134,7 @@ void blk_throtl_drain(struct request_queue *q)
 	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
 	struct throtl_data *td = q->td;
-	struct throtl_service_queue *sq = &td->service_queue;
+	struct throtl_service_queue *parent_sq = &td->service_queue;
 	struct throtl_grp *tg;
 	struct bio_list bl;
 	struct bio *bio;
@@ -1141,8 +1143,8 @@ void blk_throtl_drain(struct request_queue *q)
 
 	bio_list_init(&bl);
 
-	while ((tg = throtl_rb_first(sq))) {
-		throtl_dequeue_tg(sq, tg);
+	while ((tg = throtl_rb_first(parent_sq))) {
+		throtl_dequeue_tg(tg, parent_sq);
 
 		while ((bio = bio_list_peek(&tg->bio_lists[READ])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio), &bl);
-- 
1.8.1.4
