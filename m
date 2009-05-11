From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: Add io group reference handling for request
Date: Mon, 11 May 2009 11:41:27 -0400
Message-ID: <20090511154127.GD6036__41143.2582921863$1242056790$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<4A03FF3C.4020506@cn.fujitsu.com>
	<20090508135724.GE7293@redhat.com>
	<e98e18940905081041r386e52a5q5a2b1f13f1e8c634@mail.gmail.com>
	<4A078051.5060702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A078051.5060702-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 11, 2009 at 09:33:05AM +0800, Gui Jianfeng wrote:
> Nauman Rafique wrote:
> > On Fri, May 8, 2009 at 6:57 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> On Fri, May 08, 2009 at 05:45:32PM +0800, Gui Jianfeng wrote:
> >>> Hi Vivek,
> >>>
> >>> This patch adds io group reference handling when allocating
> >>> and removing a request.
> >>>
> >> Hi Gui,
> >>
> >> Thanks for the patch. We were thinking that requests can take a reference
> >> on io queues and io queues can take a reference on io groups. That should
> >> make sure that io groups don't go away as long as active requests are
> >> present.
> >>
> >> But there seems to be a small window while allocating the new request
> >> where request gets allocated from a group first and then later it is
> >> mapped to that group and queue is created. IOW, in get_request_wait(),
> >> we allocate a request from a particular group and set rq->rl, then
> >> drop the queue lock and later call elv_set_request() which again maps
> >> the request to the group saves rq->iog and creates new queue. This window
> >> is troublesome because request can be mapped to a particular group at the
> >> time of allocation and during set_request() it can go to a different
> >> group as queue lock was dropped and group might have disappeared.
> >>
> >> In this case probably it might make sense that request also takes a
> >> reference on groups. At the same time it looks too much that request takes
> >> a reference on queue as well as group object. Ideas are welcome on how
> >> to handle it...
> > 
> > IMHO a request being allocated on the wrong cgroup should not be a big
> > problem as such. All it means is that the request descriptor was
> > accounted to the wrong cgroup in this particular corner case. Please
> > correct me if I am wrong.
> > 
> > We can also get rid of rq->iog pointer too. What that means is that
> > request is associated with ioq (rq->ioq), and we can use
> > ioq_to_io_group() function to get the io_group. So the request would
> > only be indirectly associated with an io_group i.e. the request is
> > associated with an io_queue and the io_group for the request is the
> > io_group associated with io_queue. Do you see any problems with that
> > approach?
> 
>   That sounds reasonable to get rid of rq->iog, and rq->rl is also dead.
>   Hope to see the patch soon. ;)
>

Ok, here is the patch which gets rid of rq->iog and rq->rl fields. Good to
see some code and data structures trimming. It seems to be working fine for me.


o Get rid of rq->iog field and rq->rl fields. request descriptor stores
  the pointer the the queue it belongs to (rq->ioq) and from the io queue one
  can determine the group queue belongs to hence request belongs to. Thanks
  to Nauman for the idea.

o There are couple of places where rq->ioq information is not present yet
  as request and queue are being setup. In those places "bio" is passed 
  around as function argument to determine the group rq will go into. I
  did not pass "iog" as function argument becuase when memory is scarce,
  we can release queue lock and sleep to wait for memory to become available
  and once we wake up, it is possible that io group is gone. Passing bio
  around helps that one shall have to remap bio to right group after waking
  up. 

o Got rid of io_lookup_io_group_current() function and merged it with
  io_get_io_group() to also take care of looking for group using current
  task info and not from bio.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-core.c         |   28 +++++++++-------
 block/cfq-iosched.c      |   40 ++++++++++++++++--------
 block/elevator-fq.c      |   78 ++++++++++++++++++-----------------------------
 block/elevator-fq.h      |   29 +++--------------
 block/elevator.c         |    6 +--
 include/linux/blkdev.h   |   16 ++++-----
 include/linux/elevator.h |    2 -
 7 files changed, 91 insertions(+), 108 deletions(-)

Index: linux14/include/linux/blkdev.h
===================================================================
--- linux14.orig/include/linux/blkdev.h	2009-05-11 10:51:33.000000000 -0400
+++ linux14/include/linux/blkdev.h	2009-05-11 11:35:27.000000000 -0400
@@ -279,12 +279,6 @@ struct request {
 #ifdef CONFIG_ELV_FAIR_QUEUING
 	/* io queue request belongs to */
 	struct io_queue *ioq;
-
-#ifdef CONFIG_GROUP_IOSCHED
-	/* io group request belongs to */
-	struct io_group *iog;
-	struct request_list *rl;
-#endif /* GROUP_IOSCHED */
 #endif /* ELV_FAIR_QUEUING */
 };
 
@@ -828,9 +822,15 @@ static inline struct request_list *rq_rl
 						struct request *rq)
 {
 #ifdef CONFIG_GROUP_IOSCHED
-	return rq->rl;
+	struct io_group *iog;
+
+	BUG_ON(!rq->ioq);
+	iog = ioq_to_io_group(rq->ioq);
+	BUG_ON(!iog);
+
+	return &iog->rl;
 #else
-	return blk_get_request_list(q, NULL);
+	return &q->rq;
 #endif
 }
 
Index: linux14/block/elevator-fq.c
===================================================================
--- linux14.orig/block/elevator-fq.c	2009-05-11 10:52:49.000000000 -0400
+++ linux14/block/elevator-fq.c	2009-05-11 11:28:19.000000000 -0400
@@ -1006,7 +1006,7 @@ struct request_list *io_group_get_reques
 {
 	struct io_group *iog;
 
-	iog = io_get_io_group_bio(q, bio, 1);
+	iog = io_get_io_group(q, bio, 1, 0);
 	BUG_ON(!iog);
 	return &iog->rl;
 }
@@ -1462,20 +1462,27 @@ struct io_cgroup *get_iocg_from_bio(stru
 /*
  * Find the io group bio belongs to.
  * If "create" is set, io group is created if it is not already present.
+ * If "curr" is set, io group is information is searched for current
+ * task and not with the help of bio.
+ *
+ * FIXME: Can we assume that if bio is NULL then lookup group for current
+ * task and not create extra function parameter ?
  *
- * Note: There is a narrow window of race where a group is being freed
- * by cgroup deletion path and some rq has slipped through in this group.
- * Fix it.
  */
-struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
-					int create)
+struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
+					int create, int curr)
 {
 	struct cgroup *cgroup;
 	struct io_group *iog;
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 
 	rcu_read_lock();
-	cgroup = get_cgroup_from_bio(bio);
+
+	if (curr)
+		cgroup = task_cgroup(current, io_subsys_id);
+	else
+		cgroup = get_cgroup_from_bio(bio);
+
 	if (!cgroup) {
 		if (create)
 			iog = efqd->root_group;
@@ -1500,7 +1507,7 @@ out:
 	rcu_read_unlock();
 	return iog;
 }
-EXPORT_SYMBOL(io_get_io_group_bio);
+EXPORT_SYMBOL(io_get_io_group);
 
 void io_free_root_group(struct elevator_queue *e)
 {
@@ -1952,7 +1959,7 @@ int io_group_allow_merge(struct request 
 		return 1;
 
 	/* Determine the io group of the bio submitting task */
-	iog = io_get_io_group_bio(q, bio, 0);
+	iog = io_get_io_group(q, bio, 0, 0);
 	if (!iog) {
 		/* May be task belongs to a differet cgroup for which io
 		 * group has not been setup yet. */
@@ -1965,25 +1972,6 @@ int io_group_allow_merge(struct request 
 	return (iog == __iog);
 }
 
-/* find/create the io group request belongs to and put that info in rq */
-void elv_fq_set_request_io_group(struct request_queue *q, struct request *rq,
-					struct bio *bio)
-{
-	struct io_group *iog;
-	unsigned long flags;
-
-	/* Make sure io group hierarchy has been setup and also set the
-	 * io group to which rq belongs. Later we should make use of
-	 * bio cgroup patches to determine the io group */
-	spin_lock_irqsave(q->queue_lock, flags);
-	iog = io_get_io_group_bio(q, bio, 1);
-	spin_unlock_irqrestore(q->queue_lock, flags);
-	BUG_ON(!iog);
-
-	/* Store iog in rq. TODO: take care of referencing */
-	rq->iog = iog;
-}
-
 /*
  * Find/Create the io queue the rq should go in. This is an optimization
  * for the io schedulers (noop, deadline and AS) which maintain only single
@@ -1995,7 +1983,7 @@ void elv_fq_set_request_io_group(struct 
  * function is not invoked.
  */
 int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
-					gfp_t gfp_mask)
+					struct bio *bio, gfp_t gfp_mask)
 {
 	struct elevator_queue *e = q->elevator;
 	unsigned long flags;
@@ -2009,11 +1997,15 @@ int elv_fq_set_request_ioq(struct reques
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 	spin_lock_irqsave(q->queue_lock, flags);
 
+retry:
 	/* Determine the io group request belongs to */
-	iog = rq->iog;
+	if (bio)
+		iog = io_get_io_group(q, bio, 1, 0);
+	else
+		iog = io_get_io_group(q, bio, 1, 1);
+
 	BUG_ON(!iog);
 
-retry:
 	/* Get the iosched queue */
 	ioq = io_group_ioq(iog);
 	if (!ioq) {
@@ -2071,7 +2063,7 @@ alloc_ioq:
 			}
 		}
 
-		elv_init_ioq(e, ioq, rq->iog, sched_q, IOPRIO_CLASS_BE, 4, 1);
+		elv_init_ioq(e, ioq, iog, sched_q, IOPRIO_CLASS_BE, 4, 1);
 		io_group_set_ioq(iog, ioq);
 		elv_mark_ioq_sync(ioq);
 		/* ioq reference on iog */
@@ -2106,7 +2098,7 @@ struct io_queue *elv_lookup_ioq_bio(stru
 	struct io_group *iog;
 
 	/* lookup the io group and io queue of the bio submitting task */
-	iog = io_get_io_group_bio(q, bio, 0);
+	iog = io_get_io_group(q, bio, 0, 0);
 	if (!iog) {
 		/* May be bio belongs to a cgroup for which io group has
 		 * not been setup yet. */
@@ -2166,12 +2158,12 @@ struct io_group *io_lookup_io_group_curr
 }
 EXPORT_SYMBOL(io_lookup_io_group_current);
 
-struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
-					int create)
+struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
+					int create, int curr)
 {
 	return q->elevator->efqd.root_group;
 }
-EXPORT_SYMBOL(io_get_io_group_bio);
+EXPORT_SYMBOL(io_get_io_group);
 
 void io_free_root_group(struct elevator_queue *e)
 {
@@ -2180,16 +2172,6 @@ void io_free_root_group(struct elevator_
 	kfree(iog);
 }
 
-struct io_group *io_get_io_group(struct request_queue *q, int create)
-{
-	return q->elevator->efqd.root_group;
-}
-
-struct io_group *rq_iog(struct request_queue *q, struct request *rq)
-{
-	return q->elevator->efqd.root_group;
-}
-
 #endif /* CONFIG_GROUP_IOSCHED*/
 
 /* Elevator fair queuing function */
@@ -3128,7 +3110,9 @@ void elv_ioq_request_add(struct request_
 #ifdef CONFIG_DEBUG_GROUP_IOSCHED
 		{
 			char path[128];
-			io_group_path(rq_iog(q, rq), path, sizeof(path));
+			struct io_group *iog = ioq_to_io_group(ioq);
+
+			io_group_path(iog, path, sizeof(path));
 			elv_log_ioq(efqd, ioq, "add rq: group path=%s "
 					"rq_queued=%d", path, ioq->nr_queued);
 		}
Index: linux14/include/linux/elevator.h
===================================================================
--- linux14.orig/include/linux/elevator.h	2009-05-11 10:51:33.000000000 -0400
+++ linux14/include/linux/elevator.h	2009-05-11 10:52:51.000000000 -0400
@@ -23,7 +23,7 @@ typedef struct request *(elevator_reques
 typedef void (elevator_completed_req_fn) (struct request_queue *, struct request *);
 typedef int (elevator_may_queue_fn) (struct request_queue *, int);
 
-typedef int (elevator_set_req_fn) (struct request_queue *, struct request *, gfp_t);
+typedef int (elevator_set_req_fn) (struct request_queue *, struct request *, struct bio *bio, gfp_t);
 typedef void (elevator_put_req_fn) (struct request *);
 typedef void (elevator_activate_req_fn) (struct request_queue *, struct request *);
 typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct request *);
Index: linux14/block/cfq-iosched.c
===================================================================
--- linux14.orig/block/cfq-iosched.c	2009-05-11 10:52:47.000000000 -0400
+++ linux14/block/cfq-iosched.c	2009-05-11 10:52:51.000000000 -0400
@@ -161,7 +161,7 @@ CFQ_CFQQ_FNS(coop);
 	blk_add_trace_msg((cfqd)->queue, "cfq " fmt, ##args)
 
 static void cfq_dispatch_insert(struct request_queue *, struct request *);
-static struct cfq_queue *cfq_get_queue(struct cfq_data *, struct io_group *iog,
+static struct cfq_queue *cfq_get_queue(struct cfq_data *, struct bio *bio,
 					int, struct io_context *, gfp_t);
 static struct cfq_io_context *cfq_cic_lookup(struct cfq_data *,
 						struct io_context *);
@@ -196,7 +196,7 @@ static struct cfq_queue *cic_bio_to_cfqq
 		 * async bio tracking is enabled and we are not caching
 		 * async queue pointer in cic.
 		 */
-		iog = io_get_io_group_bio(cfqd->queue, bio, 0);
+		iog = io_get_io_group(cfqd->queue, bio, 0, 0);
 		if (!iog) {
 			/*
 			 * May be this is first rq/bio and io group has not
@@ -1242,7 +1242,6 @@ static void changed_ioprio(struct io_con
 	cfqq = cic->cfqq[BLK_RW_ASYNC];
 
 	if (cfqq) {
-		struct io_group *iog = io_lookup_io_group_current(q);
 		struct cfq_queue *new_cfqq;
 
 		/*
@@ -1259,7 +1258,7 @@ static void changed_ioprio(struct io_con
 		 * comes? Keeping it for the time being because existing cfq
 		 * code allocates the new queue immediately upon prio change
 		 */
-		new_cfqq = cfq_get_queue(cfqd, iog, BLK_RW_ASYNC, cic->ioc,
+		new_cfqq = cfq_get_queue(cfqd, NULL, BLK_RW_ASYNC, cic->ioc,
 						GFP_ATOMIC);
 		if (new_cfqq)
 			cic_set_cfqq(cic, new_cfqq, BLK_RW_ASYNC);
@@ -1295,7 +1294,7 @@ static void changed_cgroup(struct io_con
 
 	spin_lock_irqsave(q->queue_lock, flags);
 
-	iog = io_lookup_io_group_current(q);
+	iog = io_get_io_group(q, NULL, 0, 1);
 
 	if (async_cfqq != NULL) {
 		__iog = cfqq_to_io_group(async_cfqq);
@@ -1332,14 +1331,25 @@ static void cfq_ioc_set_cgroup(struct io
 #endif  /* CONFIG_IOSCHED_CFQ_HIER */
 
 static struct cfq_queue *
-cfq_find_alloc_queue(struct cfq_data *cfqd, struct io_group *iog, int is_sync,
+cfq_find_alloc_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
 				struct io_context *ioc, gfp_t gfp_mask)
 {
 	struct cfq_queue *cfqq, *new_cfqq = NULL;
 	struct cfq_io_context *cic;
 	struct request_queue *q = cfqd->queue;
 	struct io_queue *ioq = NULL, *new_ioq = NULL;
+	struct io_group *iog = NULL;
 retry:
+	/*
+	 * Note: Finding the io group again in case io group disappeared
+	 * during the time we dropped the queue lock and acquired it
+	 * back.
+	 */
+	if (bio)
+		iog = io_get_io_group(q, bio, 1, 0);
+	else
+		iog = io_get_io_group(q, NULL, 1, 1);
+
 	cic = cfq_cic_lookup(cfqd, ioc);
 	/* cic always exists here */
 	cfqq = cic_to_cfqq(cic, is_sync);
@@ -1449,13 +1459,19 @@ out:
 }
 
 static struct cfq_queue *
-cfq_get_queue(struct cfq_data *cfqd, struct io_group *iog, int is_sync,
-			struct io_context *ioc, gfp_t gfp_mask)
+cfq_get_queue(struct cfq_data *cfqd, struct bio *bio, int is_sync,
+				struct io_context *ioc, gfp_t gfp_mask)
 {
 	const int ioprio = task_ioprio(ioc);
 	const int ioprio_class = task_ioprio_class(ioc);
 	struct cfq_queue *async_cfqq = NULL;
 	struct cfq_queue *cfqq = NULL;
+	struct io_group *iog = NULL;
+
+	if (bio)
+		iog = io_get_io_group(cfqd->queue, bio, 1, 0);
+	else
+		iog = io_get_io_group(cfqd->queue, NULL, 1, 1);
 
 	if (!is_sync) {
 		async_cfqq = io_group_async_queue_prio(iog, ioprio_class,
@@ -1464,7 +1480,7 @@ cfq_get_queue(struct cfq_data *cfqd, str
 	}
 
 	if (!cfqq) {
-		cfqq = cfq_find_alloc_queue(cfqd, iog, is_sync, ioc, gfp_mask);
+		cfqq = cfq_find_alloc_queue(cfqd, bio, is_sync, ioc, gfp_mask);
 		if (!cfqq)
 			return NULL;
 	}
@@ -1889,7 +1905,8 @@ static void cfq_put_request(struct reque
  * Allocate cfq data structures associated with this request.
  */
 static int
-cfq_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
+cfq_set_request(struct request_queue *q, struct request *rq, struct bio *bio,
+				gfp_t gfp_mask)
 {
 	struct cfq_data *cfqd = q->elevator->elevator_data;
 	struct cfq_io_context *cic;
@@ -1909,8 +1926,7 @@ cfq_set_request(struct request_queue *q,
 
 	cfqq = cic_to_cfqq(cic, is_sync);
 	if (!cfqq) {
-		cfqq = cfq_get_queue(cfqd, rq_iog(q, rq), is_sync, cic->ioc,
-						gfp_mask);
+		cfqq = cfq_get_queue(cfqd, bio, is_sync, cic->ioc, gfp_mask);
 
 		if (!cfqq)
 			goto queue_fail;
Index: linux14/block/elevator.c
===================================================================
--- linux14.orig/block/elevator.c	2009-05-11 10:51:33.000000000 -0400
+++ linux14/block/elevator.c	2009-05-11 10:52:51.000000000 -0400
@@ -972,17 +972,15 @@ int elv_set_request(struct request_queue
 {
 	struct elevator_queue *e = q->elevator;
 
-	elv_fq_set_request_io_group(q, rq, bio);
-
 	/*
 	 * Optimization for noop, deadline and AS which maintain only single
 	 * ioq per io group
 	 */
 	if (elv_iosched_single_ioq(e))
-		return elv_fq_set_request_ioq(q, rq, gfp_mask);
+		return elv_fq_set_request_ioq(q, rq, bio, gfp_mask);
 
 	if (e->ops->elevator_set_req_fn)
-		return e->ops->elevator_set_req_fn(q, rq, gfp_mask);
+		return e->ops->elevator_set_req_fn(q, rq, bio, gfp_mask);
 
 	rq->elevator_private = NULL;
 	return 0;
Index: linux14/block/elevator-fq.h
===================================================================
--- linux14.orig/block/elevator-fq.h	2009-05-11 10:52:48.000000000 -0400
+++ linux14/block/elevator-fq.h	2009-05-11 11:25:03.000000000 -0400
@@ -510,15 +510,13 @@ static inline struct io_group *ioq_to_io
 
 #ifdef CONFIG_GROUP_IOSCHED
 extern int io_group_allow_merge(struct request *rq, struct bio *bio);
-extern void elv_fq_set_request_io_group(struct request_queue *q,
-					struct request *rq, struct bio *bio);
 static inline bfq_weight_t iog_weight(struct io_group *iog)
 {
 	return iog->entity.weight;
 }
 
 extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
-					gfp_t gfp_mask);
+					struct bio *bio, gfp_t gfp_mask);
 extern void elv_fq_unset_request_ioq(struct request_queue *q,
 					struct request *rq);
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
@@ -545,12 +543,6 @@ static inline void io_group_set_ioq(stru
 	iog->ioq = ioq;
 }
 
-static inline struct io_group *rq_iog(struct request_queue *q,
-					struct request *rq)
-{
-	return rq->iog;
-}
-
 static inline void elv_get_iog(struct io_group *iog)
 {
 	atomic_inc(&iog->ref);
@@ -566,10 +558,6 @@ static inline int io_group_allow_merge(s
  * separately. Hence in case of non-hierarchical setup, nothing todo.
  */
 static inline void io_disconnect_groups(struct elevator_queue *e) {}
-static inline void elv_fq_set_request_io_group(struct request_queue *q,
-					struct request *rq, struct bio *bio)
-{
-}
 
 static inline bfq_weight_t iog_weight(struct io_group *iog)
 {
@@ -588,7 +576,7 @@ static inline void io_group_set_ioq(stru
 }
 
 static inline int elv_fq_set_request_ioq(struct request_queue *q,
-					struct request *rq, gfp_t gfp_mask)
+			struct request *rq, struct bio *bio, gfp_t gfp_mask)
 {
 	return 0;
 }
@@ -613,8 +601,6 @@ static inline void elv_get_iog(struct io
 
 static inline void elv_put_iog(struct io_group *iog) { }
 
-extern struct io_group *rq_iog(struct request_queue *q, struct request *rq);
-
 #endif /* GROUP_IOSCHED */
 
 /* Functions used by blksysfs.c */
@@ -670,8 +656,8 @@ extern void *io_group_async_queue_prio(s
 extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 					int ioprio, struct io_queue *ioq);
 extern struct io_group *io_lookup_io_group_current(struct request_queue *q);
-extern struct io_group *io_get_io_group_bio(struct request_queue *q,
-						struct bio *bio, int create);
+extern struct io_group *io_get_io_group(struct request_queue *q,
+				struct bio *bio, int create, int curr);
 extern int elv_nr_busy_ioq(struct elevator_queue *e);
 extern int elv_nr_busy_rt_ioq(struct elevator_queue *e);
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
@@ -725,18 +711,13 @@ static inline void *elv_fq_select_ioq(st
 	return NULL;
 }
 
-static inline void elv_fq_set_request_io_group(struct request_queue *q,
-					struct request *rq, struct bio *bio)
-{
-}
-
 static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
 
 {
 	return 1;
 }
 static inline int elv_fq_set_request_ioq(struct request_queue *q,
-					struct request *rq, gfp_t gfp_mask)
+			struct request *rq, struct bio *bio, gfp_t gfp_mask)
 {
 	return 0;
 }
Index: linux14/block/blk-core.c
===================================================================
--- linux14.orig/block/blk-core.c	2009-05-11 11:35:20.000000000 -0400
+++ linux14/block/blk-core.c	2009-05-11 11:35:27.000000000 -0400
@@ -736,8 +736,22 @@ static void __freed_request(struct reque
 static void freed_request(struct request_queue *q, int sync, int priv,
 					struct request_list *rl)
 {
-	BUG_ON(!rl->count[sync]);
-	rl->count[sync]--;
+	/* There is a window during request allocation where request is
+	 * mapped to one group but by the time a queue for the group is
+	 * allocated, it is possible that original cgroup/io group has been
+	 * deleted and now io queue is allocated in a different group (root)
+	 * altogether.
+	 *
+	 * One solution to the problem is that rq should take io group
+	 * reference. But it looks too much to do that to solve this issue.
+	 * The only side affect to the hard to hit issue seems to be that
+	 * we will try to decrement the rl->count for a request list which
+	 * did not allocate that request. Chcek for rl->count going less than
+	 * zero and do not decrement it if that's the case.
+	 */
+
+	if (rl->count[sync] > 0)
+		rl->count[sync]--;
 
 	BUG_ON(!q->rq_data.count[sync]);
 	q->rq_data.count[sync]--;
@@ -841,16 +855,6 @@ static struct request *get_request(struc
 
 	rq = blk_alloc_request(q, bio, rw_flags, priv, gfp_mask);
 
-#ifdef CONFIG_GROUP_IOSCHED
-	if (rq) {
-		/*
-		 * TODO. Implement group reference counting and take the
-		 * reference to the group to make sure group hence request
-		 * list does not go away till rq finishes.
-		 */
-		rq->rl = rl;
-	}
-#endif
 	if (unlikely(!rq)) {
 		/*
 		 * Allocation failed presumably due to memory. Undo anything
