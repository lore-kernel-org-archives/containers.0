From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 29.5/32] blk-throttle: add throtl_qnode for dispatch fairness
Date: Fri, 3 May 2013 17:50:44 -0700
Message-ID: <20130504005044.GF22860@mtj.dyndns.org>
References: <1367455189-6957-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

With flat hierarchy, there's only single level of dispatching
happening and fairness beyond that point is the responsibility of the
rest of the block layer and driver, which usually works out okay;
however, with the planned hierarchy support,
service_queue->bio_lists[] can be filled up by bios from a single
source.  While the limits would still be honored, it'd be very easy to
starve IOs from siblings or children.

To avoid such starvation, this patch implements throtl_qnode and
converts service_queue->bio_lists[] to lists of per-source qnodes
which in turn contains the bio's.  For example, when a bio is
dispatched from a child group, the bio doesn't get queued on
->bio_lists[] directly but it first gets queued on the group's qnode
which in turn gets queued on service_queue->queued[].  When
dispatching for the upper level, the ->queued[] list is consumed in
round-robing order so that the dispatch windows is consumed fairly by
all IO sources.

There are two ways a bio can come to a throtl_grp - directly queued to
the group or dispatched from a child.  For the former
throtl_grp->qnode_on_self is used.  For the latter, the child's
->qnode_on_parent.

Note that this means that the child which is contributing a bio to its
parent should stay pinned until all its bios are dispatched to its
grand-parent.  This patch moves blkg refcnting from bio add/remove
spots to qnode activation/deactivation so that the blkg containing an
active qnode is always pinned.  As child pins the parent, this is
sufficient for keeping the relevant sub-tree pinned while bios are in
flight.

The starvation issue was spotted by Vivek Goyal.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
It took some modifications but it looks good to me now.  This patch
does cause minor conflicts for the following patches but nothing
serious.  Will update the whole series after including your patch.

Thanks.

 block/blk-throttle.c |  198 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 173 insertions(+), 25 deletions(-)

--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -26,6 +26,35 @@ static struct blkcg_policy blkcg_policy_
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
+ *
+ * It's also used to track the reference counts on blkg's.  A qnode always
+ * belongs to a throtl_grp and gets queued on itself or the parent, so
+ * incrementing the reference of the associated throtl_grp when a qnode is
+ * queued and decrementing when dequeued is enough to keep the whole blkg
+ * tree pinned while bios are in flight.
+ */
+struct throtl_qnode {
+	struct list_head	node;		/* service_queue->queued[] */
+	struct bio_list		bios;		/* queued bios */
+	struct throtl_grp	*tg;		/* tg this qnode belongs to */
+};
+
 struct throtl_service_queue {
 	struct throtl_service_queue *parent_sq;	/* the parent service_queue */
 
@@ -33,7 +62,7 @@ struct throtl_service_queue {
 	 * Bios queued directly to this service_queue or dispatched from
 	 * children throtl_grp's.
 	 */
-	struct bio_list		bio_lists[2];	/* queued bios [READ/WRITE] */
+	struct list_head	queued[2];	/* throtl_qnode [READ/WRITE] */
 	unsigned int		nr_queued[2];	/* number of queued bios */
 
 	/*
@@ -76,6 +105,17 @@ struct throtl_grp {
 	struct throtl_service_queue service_queue;
 
 	/*
+	 * qnode_on_self is used when bios are directly queued to this
+	 * throtl_grp so that local bios compete fairly with bios
+	 * dispatched from children.  qnode_on_parent is used when bios are
+	 * dispatched from this throtl_grp into its parent and will compete
+	 * with the sibling qnode_on_parents and the parent's
+	 * qnode_on_self.
+	 */
+	struct throtl_qnode qnode_on_self;
+	struct throtl_qnode qnode_on_parent;
+
+	/*
 	 * Dispatch time in jiffies. This is the estimated time when group
 	 * will unthrottle and is ready to dispatch more bio. It is used as
 	 * key to sort active groups in service tree.
@@ -247,12 +287,95 @@ alloc_stats:
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
+ *
+ * Add @bio to @qn and put @qn on @queued if it's not already on.
+ * @qn->tg's reference count is bumped when @qn is activated.  See the
+ * comment on top of throtl_qnode definition for details.
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
+ * @tg_to_put: optional out argument for throtl_grp to put
+ *
+ * Pop the first bio from the qnode list @queued.  After popping, the first
+ * qnode is removed from @queued if empty or moved to the end of @queued so
+ * that the popping order is round-robin.
+ *
+ * When the first qnode is removed, its associated throtl_grp should be put
+ * too.  If @tg_to_put is NULL, this function automatically puts it;
+ * otherwise, *@tg_to_put is set to the throtl_grp to put and the caller is
+ * responsible for putting it.
+ */
+static struct bio *throtl_pop_queued(struct list_head *queued,
+				     struct throtl_grp **tg_to_put)
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
+		if (tg_to_put)
+			*tg_to_put = qn->tg;
+		else
+			blkg_put(tg_to_blkg(tg_to_put));
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
@@ -271,6 +394,9 @@ static void throtl_pd_init(struct blkcg_
 	unsigned long flags;
 
 	throtl_service_queue_init(&tg->service_queue, &td->service_queue);
+	throtl_qnode_init(&tg->qnode_on_self, tg);
+	throtl_qnode_init(&tg->qnode_on_parent, tg);
+
 	RB_CLEAR_NODE(&tg->rb_node);
 	tg->td = td;
 
@@ -712,7 +838,7 @@ static bool tg_may_dispatch(struct throt
 	 * queued.
 	 */
 	BUG_ON(tg->service_queue.nr_queued[rw] &&
-	       bio != bio_list_peek(&tg->service_queue.bio_lists[rw]));
+	       bio != throtl_peek_queued(&tg->service_queue.queued[rw]));
 
 	/* If tg->bps = -1, then BW is unlimited */
 	if (tg->bps[rw] == -1 && tg->iops[rw] == -1) {
@@ -803,11 +929,24 @@ static void throtl_charge_bio(struct thr
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
@@ -817,9 +956,8 @@ static void throtl_add_bio_tg(struct bio
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
@@ -830,10 +968,10 @@ static void tg_update_disptime(struct th
 	unsigned long read_wait = -1, write_wait = -1, min_wait = -1, disptime;
 	struct bio *bio;
 
-	if ((bio = bio_list_peek(&sq->bio_lists[READ])))
+	if ((bio = throtl_peek_queued(&sq->queued[READ])))
 		tg_may_dispatch(tg, bio, &read_wait);
 
-	if ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
+	if ((bio = throtl_peek_queued(&sq->queued[WRITE])))
 		tg_may_dispatch(tg, bio, &write_wait);
 
 	min_wait = min(read_wait, write_wait);
@@ -853,9 +991,16 @@ static void tg_dispatch_one_bio(struct t
 	struct throtl_service_queue *sq = &tg->service_queue;
 	struct throtl_service_queue *parent_sq = sq->parent_sq;
 	struct throtl_grp *parent_tg = sq_to_tg(parent_sq);
+	struct throtl_grp *tg_to_put = NULL;
 	struct bio *bio;
 
-	bio = bio_list_pop(&sq->bio_lists[rw]);
+	/*
+	 * @bio is being transferred from @tg to @parent_sq.  Popping a bio
+	 * from @tg may put its reference and @parent_sq might end up
+	 * getting released prematurely.  Remember the tg to put and put it
+	 * after @bio is transferred to @parent_sq.
+	 */
+	bio = throtl_pop_queued(&sq->queued[rw], &tg_to_put);
 	sq->nr_queued[rw]--;
 
 	throtl_charge_bio(tg, bio);
@@ -868,17 +1013,18 @@ static void tg_dispatch_one_bio(struct t
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
 
-	/* @bio is transferred to parent, drop its blkg reference */
-	blkg_put(tg_to_blkg(tg));
+	if (tg_to_put)
+		blkg_put(tg_to_blkg(tg_to_put));
 }
 
 static int throtl_dispatch_tg(struct throtl_grp *tg)
@@ -891,7 +1037,7 @@ static int throtl_dispatch_tg(struct thr
 
 	/* Try to dispatch 75% READS and 25% WRITES */
 
-	while ((bio = bio_list_peek(&sq->bio_lists[READ])) &&
+	while ((bio = throtl_peek_queued(&sq->queued[READ])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(tg, bio_data_dir(bio));
@@ -901,7 +1047,7 @@ static int throtl_dispatch_tg(struct thr
 			break;
 	}
 
-	while ((bio = bio_list_peek(&sq->bio_lists[WRITE])) &&
+	while ((bio = throtl_peek_queued(&sq->queued[WRITE])) &&
 	       tg_may_dispatch(tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(tg, bio_data_dir(bio));
@@ -1036,10 +1182,9 @@ void blk_throtl_dispatch_work_fn(struct
 	bio_list_init(&bio_list_on_stack);
 
 	spin_lock_irq(q->queue_lock);
-	for (rw = READ; rw <= WRITE; rw++) {
-		bio_list_merge(&bio_list_on_stack, &td_sq->bio_lists[rw]);
-		bio_list_init(&td_sq->bio_lists[rw]);
-	}
+	for (rw = READ; rw <= WRITE; rw++)
+		while ((bio = throtl_pop_queued(&td_sq->queued[rw], NULL)))
+			bio_list_add(&bio_list_on_stack, bio);
 	spin_unlock_irq(q->queue_lock);
 
 	if (!bio_list_empty(&bio_list_on_stack)) {
@@ -1241,6 +1386,7 @@ static struct blkcg_policy blkcg_policy_
 bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 {
 	struct throtl_data *td = q->td;
+	struct throtl_qnode *qn = NULL;
 	struct throtl_grp *tg;
 	struct throtl_service_queue *sq;
 	bool rw = bio_data_dir(bio);
@@ -1308,6 +1454,7 @@ bool blk_throtl_bio(struct request_queue
 		 * Climb up the ladder.  If we''re already at the top, it
 		 * can be executed directly.
 		 */
+		qn = &tg->qnode_on_parent;
 		sq = sq->parent_sq;
 		tg = sq_to_tg(sq);
 		if (!tg)
@@ -1323,7 +1470,7 @@ bool blk_throtl_bio(struct request_queue
 
 	bio_associate_current(bio);
 	tg->td->nr_queued[rw]++;
-	throtl_add_bio_tg(bio, tg);
+	throtl_add_bio_tg(bio, qn, tg);
 	throttled = true;
 
 	/*
@@ -1367,9 +1514,9 @@ static void tg_drain_bios(struct throtl_
 
 		throtl_dequeue_tg(tg);
 
-		while ((bio = bio_list_peek(&sq->bio_lists[READ])))
+		while ((bio = throtl_peek_queued(&sq->queued[READ])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio));
-		while ((bio = bio_list_peek(&sq->bio_lists[WRITE])))
+		while ((bio = throtl_peek_queued(&sq->queued[WRITE])))
 			tg_dispatch_one_bio(tg, bio_data_dir(bio));
 	}
 }
@@ -1411,7 +1558,8 @@ void blk_throtl_drain(struct request_que
 
 	/* all bios now should be in td->service_queue, issue them */
 	for (rw = READ; rw <= WRITE; rw++)
-		while ((bio = bio_list_pop(&td->service_queue.bio_lists[rw])))
+		while ((bio = throtl_pop_queued(&td->service_queue.queued[rw],
+						NULL)))
 			generic_make_request(bio);
 
 	spin_lock_irq(q->queue_lock);
