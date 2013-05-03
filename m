From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET] blk-throttle: implement proper hierarchy support
Date: Fri, 3 May 2013 16:54:55 -0700
Message-ID: <20130503235455.GE22860@mtj.dyndns.org>
References: <20130502184953.GP19814@mtj.dyndns.org>
	<20130502190732.GK30020@redhat.com>
	<CAOS58YOk7G=dBG1v5Ed2z3biMMyKkkutp30vH5XC72z0_Z85cw@mail.gmail.com>
	<20130502193139.GL30020@redhat.com>
	<20130502231307.GT19814@mtj.dyndns.org>
	<20130503175652.GB6062@redhat.com>
	<20130503185751.GA22860@mtj.dyndns.org>
	<20130503190823.GC6062@redhat.com>
	<20130503191418.GC22860@mtj.dyndns.org>
	<20130503210513.GE6062@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130503210513.GE6062-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey,

On Fri, May 03, 2013 at 05:05:13PM -0400, Vivek Goyal wrote:
> Following inline patch implements transferring child's start time to 
> parent, if parent slice had expired at the time of bio migration.
> 
> I does seem to help a lot on my machine. Can you please give it a try.

Cool, will give it a try.  Can you please make it a proper patch with
SOB?  Please feel free to base it on top of the series.  It can
probably go right below the final patch but the rebase there should be
trivial.

> I think even this approach is flawed. If there are multiple children,
> it might happen that one child pushes up the bio early (as it is smaller
> size bio or group rate is high). And later other child pushes up the bio
> (bio was big or group limit was slow). We still lost time and effective
> rate will still be lower than anticipated.

Hmmm... I see.  Well, as long as it behaves acceptably on three level
nesting, I think it's good for now.

Here's RR dispatch patch I'm working on now.  I think it's almost
ready now.  I'll go over it one more time, split and merge it into the
patch series.

Thanks.

Index: work/block/blk-throttle.c
===================================================================
--- work.orig/block/blk-throttle.c
+++ work/block/blk-throttle.c
@@ -26,6 +26,29 @@ static struct blkcg_policy blkcg_policy_
 /* A workqueue to queue throttle related work */
 static struct workqueue_struct *kthrotld_workqueue;
 
+/*
+ * To implement hierarchical throttling, throtl_grps form a tree and bios
+ * are dispatched upwards level by level until they reach the top and get
+ * issued.  When dispatching bios from the children and local group at each
+ * level, if the bios are dispatched into a single bio_list, there's a risk
+ * of a local or child group which can queue many bios at once filling up
+ * the list starving others.
+ *
+ * To avoid such starvation, dispatched bios are queued separately
+ * according to where they came from.  When they are again dispatched to
+ * the parent, they're popped in round-robin order so that no single source
+ * hogs the dispatch window.
+ *
+ * throtl_qnode is used to keep the queued bios separated by their sources.
+ * Bios are queued to throtl_qnode which in turn is queued to
+ * throtl_service_queue and then dispatched in round-robin order.
+ */
+struct throtl_qnode {
+	struct list_head	node;		/* service_queue->queued[] */
+	struct bio_list		bios;		/* queued bios */
+	struct throtl_grp	*tg;		/* tg this qnode belongs to */
+};
+
 struct throtl_service_queue {
 	struct throtl_service_queue *parent_sq;	/* the parent service_queue */
 
@@ -33,7 +56,7 @@ struct throtl_service_queue {
 	 * Bios queued directly to this service_queue or dispatched from
 	 * children throtl_grp's.
 	 */
-	struct bio_list		bio_lists[2];	/* queued bios [READ/WRITE] */
+	struct list_head	queued[2];	/* throtl_qnode [READ/WRITE] */
 	unsigned int		nr_queued[2];	/* number of queued bios */
 
 	/*
@@ -76,6 +99,17 @@ struct throtl_grp {
 	struct throtl_service_queue service_queue;
 
 	/*
+	 * qnode_on_self is used when bios are directly queued to this
+	 * throtl_grp so that local bios compete fairly with bios
+	 * dispatched from children.  qnode_on_parent is used when bios are
+	 * dispatched from this this throtl_grp into its parent and will
+	 * compete with sibling qnode_on_parents and the parent's
+	 * qnode_on_self.
+	 */
+	struct throtl_qnode qnode_on_self;
+	struct throtl_qnode qnode_on_parent;
+
+	/*
 	 * Dispatch time in jiffies. This is the estimated time when group
 	 * will unthrottle and is ready to dispatch more bio. It is used as
 	 * key to sort active groups in service tree.
@@ -250,12 +284,81 @@ alloc_stats:
 		goto alloc_stats;
 }
 
+static void throtl_qnode_init(struct throtl_qnode *qn, struct throtl_grp *tg)
+{
+	INIT_LIST_HEAD(&qn->node);
+	bio_list_init(&qn->bios);
+	qn->tg = tg;
+}
+
+/**
+ * throtl_qnode_add_bio - add a bio to a throtl_qnode and activate it
+ * @bio: bio being added
+ * @qn: qnode to add bio to
+ * @queued: the service_queue->queued[] list @qn belongs to
+ */
+static void throtl_qnode_add_bio(struct bio *bio, struct throtl_qnode *qn,
+				 struct list_head *queued)
+{
+	bio_list_add(&qn->bios, bio);
+	if (list_empty(&qn->node)) {
+		list_add_tail(&qn->node, queued);
+		blkg_get(tg_to_blkg(qn->tg));
+	}
+}
+
+/**
+ * throtl_peek_queued - peek the first bio on a qnode list
+ * @queued: the qnode list to peek
+ */
+static struct bio *throtl_peek_queued(struct list_head *queued)
+{
+	struct throtl_qnode *qn = list_first_entry(queued, struct throtl_qnode, node);
+	struct bio *bio;
+
+	if (list_empty(queued))
+		return NULL;
+
+	bio = bio_list_peek(&qn->bios);
+	WARN_ON_ONCE(!bio);
+	return bio;
+}
+
+/**
+ * throtl_pop_queued - pop the first bio form a qnode list
+ * @queued: the qnode list to pop a bio from
+ *
+ * Pop the first bio from the qnode list @queued.  After popping, the first
+ * qnode is removed from @queued if empty or moved to the end of @queued so
+ * that the popping order is round-robin.
+ */
+static struct bio *throtl_pop_queued(struct list_head *queued)
+{
+	struct throtl_qnode *qn = list_first_entry(queued, struct throtl_qnode, node);
+	struct bio *bio;
+
+	if (list_empty(queued))
+		return NULL;
+
+	bio = bio_list_pop(&qn->bios);
+	WARN_ON_ONCE(!bio);
+
+	if (bio_list_empty(&qn->bios)) {
+		list_del_init(&qn->node);
+		blkg_put(tg_to_blkg(qn->tg));
+	} else {
+		list_move_tail(&qn->node, queued);
+	}
+
+	return bio;
+}
+
 /* init a service_queue, assumes the caller zeroed it */
 static void throtl_service_queue_init(struct throtl_service_queue *sq,
 				      struct throtl_service_queue *parent_sq)
 {
-	bio_list_init(&sq->bio_lists[0]);
-	bio_list_init(&sq->bio_lists[1]);
+	INIT_LIST_HEAD(&sq->queued[0]);
+	INIT_LIST_HEAD(&sq->queued[1]);
 	sq->pending_tree = RB_ROOT;
 	sq->parent_sq = parent_sq;
 	setup_timer(&sq->pending_timer, throtl_pending_timer_fn,
@@ -293,6 +396,9 @@ static void throtl_pd_init(struct blkcg_
 		parent_sq = &blkg_to_tg(blkg->parent)->service_queue;
 
 	throtl_service_queue_init(&tg->service_queue, parent_sq);
+	throtl_qnode_init(&tg->qnode_on_self, tg);
+	throtl_qnode_init(&tg->qnode_on_parent, tg);
+
 	RB_CLEAR_NODE(&tg->rb_node);
 	tg->td = td;
 
@@ -752,7 +858,7 @@ static bool tg_may_dispatch(struct throt
 	 * queued.
 	 */
 	BUG_ON(tg->service_queue.nr_queued[rw] &&
-	       bio != bio_list_peek(&tg->service_queue.bio_lists[rw]));
+	       bio != throtl_peek_queued(&tg->service_queue.queued[rw]));
 
 	/* If tg->bps = -1, then BW is unlimited */
 	if (tg->bps[rw] == -1 && tg->iops[rw] == -1) {
@@ -843,11 +949,24 @@ static void throtl_charge_bio(struct thr
 	}
 }
 
-static void throtl_add_bio_tg(struct bio *bio, struct throtl_grp *tg)
+/**
+ * throtl_add_bio_tg - add a bio to the specified throtl_grp
+ * @bio: bio to add
+ * @qn: qnode to use
+ * @tg: the target throtl_grp
+ *
+ * Add @bio to @tg's service_queue using @qn.  If @qn is not specified,
+ * tg->qnode_on_self is used.
+ */
+static void throtl_add_bio_tg(struct bio *bio, struct throtl_qnode *qn,
+			      struct throtl_grp *tg)
 {
 	struct throtl_service_queue *sq = &tg->service_queue;
 	bool rw = bio_data_dir(bio);
 
+	if (!qn)
+		qn = &tg->qnode_on_self;
+
 	/*
 	 * If @tg doesn't currently have any bios queued in the same
 	 * direction, queueing @bio can change when @tg should be
@@ -857,9 +976,8 @@ static void throtl_add_bio_tg(struct bio
 	if (!sq->nr_queued[rw])
 		tg->flags |= THROTL_TG_WAS_EMPTY;
 
-	bio_list_add(&sq->bio_lists[rw], bio);
-	/* Take a bio reference on tg */
-	blkg_get(tg_to_blkg(tg));
+	throtl_qnode_add_bio(bio, qn, &sq->queued[rw]);
+
 	sq->nr_queued[rw]++;
 	throtl_enqueue_tg(tg);
 }
@@ -870,10 +988,10 @@ static void tg_update_disptime(struct th
 	unsigned long read_wait = -1, write_wait = -1, min_wait = -1, disptime;
 	struct bio *bio;
 
-	if ((bio = bio_list_peek(&sq->bio_lists[READ])))
+	if ((bio = throtl_peek_queued(&sq->queued[READ])))
 		tg_may_dispatch(tg, bio, &read_wait);
 
-	if ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
+	if ((bio = throtl_peek_queued(&sq->queued[WRITE])))
 		tg_may_dispatch(tg, bio, &write_wait);
 
 	min_wait = min(read_wait, write_wait);
@@ -895,7 +1013,7 @@ static void tg_dispatch_one_bio(struct t
 	struct throtl_grp *parent_tg = sq_to_tg(parent_sq);
 	struct bio *bio;
 
-	bio = bio_list_pop(&sq->bio_lists[rw]);
+	bio = throtl_pop_queued(&sq->queued[rw]);
 	sq->nr_queued[rw]--;
 
 	throtl_charge_bio(tg, bio);
@@ -908,17 +1026,15 @@ static void tg_dispatch_one_bio(struct t
 	 * responsible for issuing these bios.
 	 */
 	if (parent_tg) {
-		throtl_add_bio_tg(bio, parent_tg);
+		throtl_add_bio_tg(bio, &tg->qnode_on_parent, parent_tg);
 	} else {
-		bio_list_add(&parent_sq->bio_lists[rw], bio);
+		throtl_qnode_add_bio(bio, &tg->qnode_on_parent,
+				     &parent_sq->queued[rw]);
 		BUG_ON(tg->td->nr_queued[rw] <= 0);
 		tg->td->nr_queued[rw]--;
 	}
 
 	throtl_trim_slice(tg, rw);
-
-	/* @bio is transferred to parent, drop its blkg reference */
-	blkg_put(tg_to_blkg(tg));
 }
 
 static int throtl_dispatch_tg(struct throtl_grp *tg)
@@ -931,7 +1047,7 @@ static int throtl_dispatch_tg(struct thr
 
 	/* Try to dispatch 75% READS and 25% WRITES */
 
-	while ((bio = bio_list_peek(&sq->bio_lists[READ])) &&
+	while ((bio = throtl_peek_queued(&sq->queued[READ])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(tg, bio_data_dir(bio));
@@ -941,7 +1057,7 @@ static int throtl_dispatch_tg(struct thr
 			break;
 	}
 
-	while ((bio = bio_list_peek(&sq->bio_lists[WRITE])) &&
+	while ((bio = throtl_peek_queued(&sq->queued[WRITE])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(tg, bio_data_dir(bio));
@@ -1076,10 +1192,9 @@ void blk_throtl_dispatch_work_fn(struct
 	bio_list_init(&bio_list_on_stack);
 
 	spin_lock_irq(q->queue_lock);
-	for (rw = READ; rw <= WRITE; rw++) {
-		bio_list_merge(&bio_list_on_stack, &td_sq->bio_lists[rw]);
-		bio_list_init(&td_sq->bio_lists[rw]);
-	}
+	for (rw = READ; rw <= WRITE; rw++)
+		while ((bio = throtl_pop_queued(&td_sq->queued[rw])))
+			bio_list_add(&bio_list_on_stack, bio);
 	spin_unlock_irq(q->queue_lock);
 
 	if (!bio_list_empty(&bio_list_on_stack)) {
@@ -1295,6 +1410,7 @@ static struct blkcg_policy blkcg_policy_
 bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 {
 	struct throtl_data *td = q->td;
+	struct throtl_qnode *qn = NULL;
 	struct throtl_grp *tg;
 	struct throtl_service_queue *sq;
 	bool rw = bio_data_dir(bio);
@@ -1362,6 +1478,7 @@ bool blk_throtl_bio(struct request_queue
 		 * Climb up the ladder.  If we''re already at the top, it
 		 * can be executed directly.
 		 */
+		qn = &tg->qnode_on_parent;
 		sq = sq->parent_sq;
 		tg = sq_to_tg(sq);
 		if (!tg)
@@ -1377,7 +1494,7 @@ bool blk_throtl_bio(struct request_queue
 
 	bio_associate_current(bio);
 	tg->td->nr_queued[rw]++;
-	throtl_add_bio_tg(bio, tg);
+	throtl_add_bio_tg(bio, qn, tg);
 	throttled = true;
 
 	/*
@@ -1421,9 +1538,9 @@ static void tg_drain_bios(struct throtl_
 
 		throtl_dequeue_tg(tg);
 
-		while ((bio = bio_list_peek(&sq->bio_lists[READ])))
+		while ((bio = throtl_peek_queued(&sq->queued[READ])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio));
-		while ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
+		while ((bio = throtl_peek_queued(&sq->queued[WRITE])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio));
 	}
 }
@@ -1465,7 +1582,7 @@ void blk_throtl_drain(struct request_que
 
 	/* all bios now should be in td->service_queue, issue them */
 	for (rw = READ; rw <= WRITE; rw++)
-		while ((bio = bio_list_pop(&td->service_queue.bio_lists[rw])))
+		while ((bio = throtl_pop_queued(&td->service_queue.queued[rw])))
 			generic_make_request(bio);
 
 	spin_lock_irq(q->queue_lock);
