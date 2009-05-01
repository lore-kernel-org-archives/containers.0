From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: IO Controller per cgroup request descriptors (Re: [PATCH 01/10]
	Documentation)
Date: Fri, 1 May 2009 18:45:06 -0400
Message-ID: <20090501224506.GC6130@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090406143556.GK7082@balbir.in.ibm.com>
	<20090413134017.GC18007@redhat.com> <49FB71F7.90309@ds.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49FB71F7.90309-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 01, 2009 at 06:04:39PM -0400, IKEDA, Munehiro wrote:
> Vivek Goyal wrote:
>>>> +TODO
>>>> +====
>>>> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking etc...
>>>> +- Convert cgroup ioprio to notion of weight.
>>>> +- Anticipatory code will need more work. It is not working properly currently
>>>> +  and needs more thought.
>>> What are the problems with the code?
>>
>> Have not got a chance to look into the issues in detail yet. Just a crude run
>> saw drop in performance. Will debug it later the moment I have got async writes
>> handled...
>>
>>>> +- Use of bio-cgroup patches.
>>> I saw these posted as well
>>>
>>>> +- Use of Nauman's per cgroup request descriptor patches.
>>>> +
>>> More details would be nice, I am not sure I understand
>>
>> Currently the number of request descriptors which can be allocated per
>> device/request queue are fixed by a sysfs tunable (q->nr_requests). So
>> if there is lots of IO going on from one cgroup then it will consume all
>> the available request descriptors and other cgroup might starve and not
>> get its fair share.
>>
>> Hence we also need to introduce the notion of request descriptor limit per
>> cgroup so that if request descriptors from one group are exhausted, then
>> it does not impact the IO of other cgroup.
>
> Unfortunately I couldn't find and I've never seen the Nauman's patches.
> So I tried to make a patch below against this todo.  The reason why
> I'm posting this despite this is just a quick and ugly hack (and it
> might be a reinvention of wheel) is that I would like to discuss how
> we should define the limitation of requests per cgroup.
> This patch should be applied on Vivek's I/O controller patches
> posted on Mar 11.

Hi IKEDA,

Sorry for the confusion here. Actually Nauman had sent a patch to select group
of people who were initially copied on the mail thread.

>
> This patch temporarily distribute q->nr_requests to each cgroup.
> I think the number should be weighted like BFQ's budget.  But in
> this case, if the hierarchy of cgroup is deep, leaf cgroups are
> allowed to allocate very few numbers of requests.  I don't think
> this is reasonable...but I don't have specific idea to solve this
> problem.  Does anyone have the good idea?
>

Thanks for the patch. Yes, ideally one would expect the request descriptor
to be allocated also in proportion to the weight but I guess that would
become very comlicated.

In terms of simpler things, two thoughts come to mind.

- First approach is to make q->nr_requests per group. So every group is
  entitled for q->nr_requests as set by the user. This is what your patch
  seems to have done.

  I had some concerns with this approach. First of all it does not seem to
  have an upper bound on number of request descriptors allocated per queue
  because if a user creates more cgroups, total number of request
  descriptors increase.

- Second approach can be that we retain the meaning of q->nr_requests
  which defines the total number of request descriptors on the queue (with
  the exception of 50% more descriptors for batching processes). And we
  define a new per group limit q->nr_group_requests which defines how many
  requests per group can be assigned. So q->nr_requests defines total pool
  size on the queue and q->nr_group_requests will define how many requests
  each group can allocate out of that pool.

  Here the issue is that a user shall have to balance the q->nr_group_requests    and q->nr_requests properly.

To experiment, I have implemented the second approach. I am attaching the
patch which is in my current tree. It probably will not apply on my march
11 posting as since then patches have changed. But posting it here so that
at least it will give an idea behind the thought process.

Ideas are welcome...

Thanks
Vivek
   
o Currently a request queue has got fixed number of request descriptors for
  sync and async requests. Once the request descriptors are consumed, new
  processes are put to sleep and they effectively become serialized. Because
  sync and async queues are separate, async requests don't impact sync ones
  but if one is looking for fairness between async requests, that is not
  achievable if request queue descriptors become bottleneck.

o Make request descriptor's per io group so that if there is lots of IO
  going on in one cgroup, it does not impact the IO of other group.

o This patch implements the per cgroup request descriptors. request pool per
  queue is still common but every group will have its own wait list and its
  own count of request descriptors allocated to that group for sync and async
  queues. So effectively request_list becomes per io group property and not a
  global request queue feature.

o Currently one can define q->nr_requests to limit request descriptors
  allocated for the queue. Now there is another tunable q->nr_group_requests
  which controls the requests descriptr limit per group. q->nr_requests
  supercedes q->nr_group_requests to make sure if there are lots of groups
  present, we don't end up allocating too many request descriptors on the
  queue.

o Issues: Currently notion of congestion is per queue. With per group request
  descriptor it is possible that queue is not congested but the group bio
  will go into is congested.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

---
 block/blk-core.c       |  216 ++++++++++++++++++++++++++++++++++---------------
 block/blk-settings.c   |    3 
 block/blk-sysfs.c      |   57 ++++++++++--
 block/elevator-fq.c    |   15 +++
 block/elevator-fq.h    |    8 +
 block/elevator.c       |    6 -
 include/linux/blkdev.h |   62 +++++++++++++-
 7 files changed, 287 insertions(+), 80 deletions(-)

Index: linux9/include/linux/blkdev.h
===================================================================
--- linux9.orig/include/linux/blkdev.h	2009-04-30 15:43:53.000000000 -0400
+++ linux9/include/linux/blkdev.h	2009-04-30 16:18:29.000000000 -0400
@@ -32,21 +32,51 @@ struct request;
 struct sg_io_hdr;
 
 #define BLKDEV_MIN_RQ	4
+
+#ifdef CONFIG_GROUP_IOSCHED
+#define BLKDEV_MAX_RQ	256	/* Default maximum */
+#define BLKDEV_MAX_GROUP_RQ    64      /* Default maximum */
+#else
 #define BLKDEV_MAX_RQ	128	/* Default maximum */
+/*
+ * This is eqivalent to case of only one group present (root group). Let
+ * it consume all the request descriptors available on the queue .
+ */
+#define BLKDEV_MAX_GROUP_RQ    BLKDEV_MAX_RQ      /* Default maximum */
+#endif
 
 struct request;
 typedef void (rq_end_io_fn)(struct request *, int);
 
 struct request_list {
 	/*
-	 * count[], starved[], and wait[] are indexed by
+	 * count[], starved and wait[] are indexed by
 	 * BLK_RW_SYNC/BLK_RW_ASYNC
 	 */
 	int count[2];
 	int starved[2];
+	wait_queue_head_t wait[2];
+};
+
+/*
+ * This data structures keeps track of mempool of requests for the queue
+ * and some overall statistics.
+ */
+struct request_data {
+	/*
+	 * Per queue request descriptor count. This is in addition to per
+	 * cgroup count
+	 */
+	int count[2];
 	int elvpriv;
 	mempool_t *rq_pool;
-	wait_queue_head_t wait[2];
+	int starved;
+	/*
+	 * Global list for starved tasks. A task will be queued here if
+	 * it could not allocate request descriptor and the associated
+	 * group request list does not have any requests pending.
+	 */
+	wait_queue_head_t starved_wait;
 };
 
 /*
@@ -251,6 +281,7 @@ struct request {
 #ifdef CONFIG_GROUP_IOSCHED
 	/* io group request belongs to */
 	struct io_group *iog;
+	struct request_list *rl;
 #endif /* GROUP_IOSCHED */
 #endif /* ELV_FAIR_QUEUING */
 };
@@ -340,6 +371,9 @@ struct request_queue
 	 */
 	struct request_list	rq;
 
+	/* Contains request pool and other data like starved data */
+	struct request_data	rq_data;
+
 	request_fn_proc		*request_fn;
 	make_request_fn		*make_request_fn;
 	prep_rq_fn		*prep_rq_fn;
@@ -402,6 +436,8 @@ struct request_queue
 	 * queue settings
 	 */
 	unsigned long		nr_requests;	/* Max # of requests */
+	/* Max # of per io group requests */
+	unsigned long		nr_group_requests;
 	unsigned int		nr_congestion_on;
 	unsigned int		nr_congestion_off;
 	unsigned int		nr_batching;
@@ -773,6 +809,28 @@ extern int scsi_cmd_ioctl(struct request
 extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmode_t,
 			 struct scsi_ioctl_command __user *);
 
+extern void blk_init_request_list(struct request_list *rl);
+
+static inline struct request_list *blk_get_request_list(struct request_queue *q,
+						struct bio *bio)
+{
+#ifdef CONFIG_GROUP_IOSCHED
+	return io_group_get_request_list(q, bio);
+#else
+	return &q->rq;
+#endif
+}
+
+static inline struct request_list *rq_rl(struct request_queue *q,
+						struct request *rq)
+{
+#ifdef CONFIG_GROUP_IOSCHED
+	return rq->rl;
+#else
+	return blk_get_request_list(q, NULL);
+#endif
+}
+
 /*
  * Temporary export, until SCSI gets fixed up.
  */
Index: linux9/block/elevator.c
===================================================================
--- linux9.orig/block/elevator.c	2009-04-30 16:17:53.000000000 -0400
+++ linux9/block/elevator.c	2009-04-30 16:18:29.000000000 -0400
@@ -664,7 +664,7 @@ void elv_quiesce_start(struct request_qu
 	 * make sure we don't have any requests in flight
 	 */
 	elv_drain_elevator(q);
-	while (q->rq.elvpriv) {
+	while (q->rq_data.elvpriv) {
 		blk_start_queueing(q);
 		spin_unlock_irq(q->queue_lock);
 		msleep(10);
@@ -764,8 +764,8 @@ void elv_insert(struct request_queue *q,
 	}
 
 	if (unplug_it && blk_queue_plugged(q)) {
-		int nrq = q->rq.count[BLK_RW_SYNC] + q->rq.count[BLK_RW_ASYNC]
-			- q->in_flight;
+		int nrq = q->rq_data.count[BLK_RW_SYNC] +
+				q->rq_data.count[BLK_RW_ASYNC] - q->in_flight;
 
 		if (nrq >= q->unplug_thresh)
 			__generic_unplug_device(q);
Index: linux9/block/blk-core.c
===================================================================
--- linux9.orig/block/blk-core.c	2009-04-30 16:17:53.000000000 -0400
+++ linux9/block/blk-core.c	2009-04-30 16:18:29.000000000 -0400
@@ -480,20 +480,31 @@ void blk_cleanup_queue(struct request_qu
 }
 EXPORT_SYMBOL(blk_cleanup_queue);
 
-static int blk_init_free_list(struct request_queue *q)
+void blk_init_request_list(struct request_list *rl)
 {
-	struct request_list *rl = &q->rq;
 
 	rl->count[BLK_RW_SYNC] = rl->count[BLK_RW_ASYNC] = 0;
-	rl->starved[BLK_RW_SYNC] = rl->starved[BLK_RW_ASYNC] = 0;
-	rl->elvpriv = 0;
 	init_waitqueue_head(&rl->wait[BLK_RW_SYNC]);
 	init_waitqueue_head(&rl->wait[BLK_RW_ASYNC]);
+}
 
-	rl->rq_pool = mempool_create_node(BLKDEV_MIN_RQ, mempool_alloc_slab,
-				mempool_free_slab, request_cachep, q->node);
+static int blk_init_free_list(struct request_queue *q)
+{
+#ifndef CONFIG_GROUP_IOSCHED
+	struct request_list *rl = blk_get_request_list(q, NULL);
+
+	/*
+	 * In case of group scheduling, request list is inside the associated
+	 * group and when that group is instanciated, it takes care of
+	 * initializing the request list also.
+	 */
+	blk_init_request_list(rl);
+#endif
+	q->rq_data.rq_pool = mempool_create_node(BLKDEV_MIN_RQ,
+				mempool_alloc_slab, mempool_free_slab,
+				request_cachep, q->node);
 
-	if (!rl->rq_pool)
+	if (!q->rq_data.rq_pool)
 		return -ENOMEM;
 
 	return 0;
@@ -590,6 +601,9 @@ blk_init_queue_node(request_fn_proc *rfn
 		return NULL;
 	}
 
+	/* init starved waiter wait queue */
+	init_waitqueue_head(&q->rq_data.starved_wait);
+
 	/*
 	 * if caller didn't supply a lock, they get per-queue locking with
 	 * our embedded lock
@@ -639,14 +653,14 @@ static inline void blk_free_request(stru
 {
 	if (rq->cmd_flags & REQ_ELVPRIV)
 		elv_put_request(q, rq);
-	mempool_free(rq, q->rq.rq_pool);
+	mempool_free(rq, q->rq_data.rq_pool);
 }
 
 static struct request *
 blk_alloc_request(struct request_queue *q, struct bio *bio, int rw, int priv,
 					gfp_t gfp_mask)
 {
-	struct request *rq = mempool_alloc(q->rq.rq_pool, gfp_mask);
+	struct request *rq = mempool_alloc(q->rq_data.rq_pool, gfp_mask);
 
 	if (!rq)
 		return NULL;
@@ -657,7 +671,7 @@ blk_alloc_request(struct request_queue *
 
 	if (priv) {
 		if (unlikely(elv_set_request(q, rq, bio, gfp_mask))) {
-			mempool_free(rq, q->rq.rq_pool);
+			mempool_free(rq, q->rq_data.rq_pool);
 			return NULL;
 		}
 		rq->cmd_flags |= REQ_ELVPRIV;
@@ -700,18 +714,18 @@ static void ioc_set_batching(struct requ
 	ioc->last_waited = jiffies;
 }
 
-static void __freed_request(struct request_queue *q, int sync)
+static void __freed_request(struct request_queue *q, int sync,
+					struct request_list *rl)
 {
-	struct request_list *rl = &q->rq;
-
-	if (rl->count[sync] < queue_congestion_off_threshold(q))
+	if (q->rq_data.count[sync] < queue_congestion_off_threshold(q))
 		blk_clear_queue_congested(q, sync);
 
-	if (rl->count[sync] + 1 <= q->nr_requests) {
+	if (q->rq_data.count[sync] + 1 <= q->nr_requests)
+		blk_clear_queue_full(q, sync);
+
+	if (rl->count[sync] + 1 <= q->nr_group_requests) {
 		if (waitqueue_active(&rl->wait[sync]))
 			wake_up(&rl->wait[sync]);
-
-		blk_clear_queue_full(q, sync);
 	}
 }
 
@@ -719,18 +733,29 @@ static void __freed_request(struct reque
  * A request has just been released.  Account for it, update the full and
  * congestion status, wake up any waiters.   Called under q->queue_lock.
  */
-static void freed_request(struct request_queue *q, int sync, int priv)
+static void freed_request(struct request_queue *q, int sync, int priv,
+					struct request_list *rl)
 {
-	struct request_list *rl = &q->rq;
-
+	BUG_ON(!rl->count[sync]);
 	rl->count[sync]--;
+
+	BUG_ON(!q->rq_data.count[sync]);
+	q->rq_data.count[sync]--;
+
 	if (priv)
-		rl->elvpriv--;
+		q->rq_data.elvpriv--;
 
-	__freed_request(q, sync);
+	__freed_request(q, sync, rl);
 
 	if (unlikely(rl->starved[sync ^ 1]))
-		__freed_request(q, sync ^ 1);
+		__freed_request(q, sync ^ 1, rl);
+
+	/* Wake up the starved process on global list, if any */
+	if (unlikely(q->rq_data.starved)) {
+		if (waitqueue_active(&q->rq_data.starved_wait))
+			wake_up(&q->rq_data.starved_wait);
+		q->rq_data.starved--;
+	}
 }
 
 /*
@@ -739,10 +764,9 @@ static void freed_request(struct request
  * Returns !NULL on success, with queue_lock *not held*.
  */
 static struct request *get_request(struct request_queue *q, int rw_flags,
-				   struct bio *bio, gfp_t gfp_mask)
+		   struct bio *bio, gfp_t gfp_mask, struct request_list *rl)
 {
 	struct request *rq = NULL;
-	struct request_list *rl = &q->rq;
 	struct io_context *ioc = NULL;
 	const bool is_sync = rw_is_sync(rw_flags) != 0;
 	int may_queue, priv;
@@ -751,31 +775,38 @@ static struct request *get_request(struc
 	if (may_queue == ELV_MQUEUE_NO)
 		goto rq_starved;
 
-	if (rl->count[is_sync]+1 >= queue_congestion_on_threshold(q)) {
-		if (rl->count[is_sync]+1 >= q->nr_requests) {
-			ioc = current_io_context(GFP_ATOMIC, q->node);
-			/*
-			 * The queue will fill after this allocation, so set
-			 * it as full, and mark this process as "batching".
-			 * This process will be allowed to complete a batch of
-			 * requests, others will be blocked.
-			 */
-			if (!blk_queue_full(q, is_sync)) {
-				ioc_set_batching(q, ioc);
-				blk_set_queue_full(q, is_sync);
-			} else {
-				if (may_queue != ELV_MQUEUE_MUST
-						&& !ioc_batching(q, ioc)) {
-					/*
-					 * The queue is full and the allocating
-					 * process is not a "batcher", and not
-					 * exempted by the IO scheduler
-					 */
-					goto out;
-				}
+	if (q->rq_data.count[is_sync]+1 >= queue_congestion_on_threshold(q))
+		blk_set_queue_congested(q, is_sync);
+
+	/*
+	 * Looks like there is no user of queue full now.
+	 * Keeping it for time being.
+	 */
+	if (q->rq_data.count[is_sync]+1 >= q->nr_requests)
+		blk_set_queue_full(q, is_sync);
+
+	if (rl->count[is_sync]+1 >= q->nr_group_requests) {
+		ioc = current_io_context(GFP_ATOMIC, q->node);
+		/*
+		 * The queue request descriptor group will fill after this
+		 * allocation, so set
+		 * it as full, and mark this process as "batching".
+		 * This process will be allowed to complete a batch of
+		 * requests, others will be blocked.
+		 */
+		if (rl->count[is_sync] <= q->nr_group_requests)
+			ioc_set_batching(q, ioc);
+		else {
+			if (may_queue != ELV_MQUEUE_MUST
+					&& !ioc_batching(q, ioc)) {
+				/*
+				 * The queue is full and the allocating
+				 * process is not a "batcher", and not
+				 * exempted by the IO scheduler
+				 */
+				goto out;
 			}
 		}
-		blk_set_queue_congested(q, is_sync);
 	}
 
 	/*
@@ -783,19 +814,41 @@ static struct request *get_request(struc
 	 * limit of requests, otherwise we could have thousands of requests
 	 * allocated with any setting of ->nr_requests
 	 */
-	if (rl->count[is_sync] >= (3 * q->nr_requests / 2))
+
+	if (q->rq_data.count[is_sync] >= (3 * q->nr_requests / 2))
+		goto out;
+
+	/*
+	 * Allocation of request is allowed from queue perspective. Now check
+	 * from per group request list
+	 */
+
+	if (rl->count[is_sync] >= (3 * q->nr_group_requests / 2))
 		goto out;
 
 	rl->count[is_sync]++;
 	rl->starved[is_sync] = 0;
 
+	q->rq_data.count[is_sync]++;
+
 	priv = !test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags);
 	if (priv)
-		rl->elvpriv++;
+		q->rq_data.elvpriv++;
 
 	spin_unlock_irq(q->queue_lock);
 
 	rq = blk_alloc_request(q, bio, rw_flags, priv, gfp_mask);
+
+#ifdef CONFIG_GROUP_IOSCHED
+	if (rq) {
+		/*
+		 * TODO. Implement group reference counting and take the
+		 * reference to the group to make sure group hence request
+		 * list does not go away till rq finishes.
+		 */
+		rq->rl = rl;
+	}
+#endif
 	if (unlikely(!rq)) {
 		/*
 		 * Allocation failed presumably due to memory. Undo anything
@@ -805,7 +858,7 @@ static struct request *get_request(struc
 		 * wait queue, but this is pretty rare.
 		 */
 		spin_lock_irq(q->queue_lock);
-		freed_request(q, is_sync, priv);
+		freed_request(q, is_sync, priv, rl);
 
 		/*
 		 * in the very unlikely event that allocation failed and no
@@ -815,10 +868,26 @@ static struct request *get_request(struc
 		 * rq mempool into READ and WRITE
 		 */
 rq_starved:
-		if (unlikely(rl->count[is_sync] == 0))
-			rl->starved[is_sync] = 1;
-
-		goto out;
+		if (unlikely(rl->count[is_sync] == 0)) {
+			/*
+			 * If there is a request pending in other direction
+			 * in same io group, then set the starved flag of
+			 * the group request list. Otherwise, we need to
+			 * make this process sleep in global starved list
+			 * to make sure it will not sleep indefinitely.
+			 */
+			if (rl->count[is_sync ^ 1] != 0) {
+				rl->starved[is_sync] = 1;
+				goto out;
+			} else {
+				/*
+				 * It indicates to calling function to put
+				 * task on global starved list. Not the best
+				 * way
+				 */
+				return ERR_PTR(-ENOMEM);
+			}
+		}
 	}
 
 	/*
@@ -846,15 +915,29 @@ static struct request *get_request_wait(
 {
 	const bool is_sync = rw_is_sync(rw_flags) != 0;
 	struct request *rq;
+	struct request_list *rl = blk_get_request_list(q, bio);
 
-	rq = get_request(q, rw_flags, bio, GFP_NOIO);
-	while (!rq) {
+	rq = get_request(q, rw_flags, bio, GFP_NOIO, rl);
+	while (!rq || (IS_ERR(rq) && PTR_ERR(rq) == -ENOMEM)) {
 		DEFINE_WAIT(wait);
 		struct io_context *ioc;
-		struct request_list *rl = &q->rq;
 
-		prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
-				TASK_UNINTERRUPTIBLE);
+		if (IS_ERR(rq) && PTR_ERR(rq) == -ENOMEM) {
+			/*
+			 * Task failed allocation and needs to wait and
+			 * try again. There are no requests pending from
+			 * the io group hence need to sleep on global
+			 * wait queue. Most likely the allocation failed
+			 * because of memory issues.
+			 */
+
+			q->rq_data.starved++;
+			prepare_to_wait_exclusive(&q->rq_data.starved_wait,
+					&wait, TASK_UNINTERRUPTIBLE);
+		} else {
+			prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
+					TASK_UNINTERRUPTIBLE);
+		}
 
 		trace_block_sleeprq(q, bio, rw_flags & 1);
 
@@ -874,7 +957,12 @@ static struct request *get_request_wait(
 		spin_lock_irq(q->queue_lock);
 		finish_wait(&rl->wait[is_sync], &wait);
 
-		rq = get_request(q, rw_flags, bio, GFP_NOIO);
+		/*
+		 * After the sleep check the rl again in case cgrop bio
+		 * belonged to is gone and it is mapped to root group now
+		 */
+		rl = blk_get_request_list(q, bio);
+		rq = get_request(q, rw_flags, bio, GFP_NOIO, rl);
 	};
 
 	return rq;
@@ -883,6 +971,7 @@ static struct request *get_request_wait(
 struct request *blk_get_request(struct request_queue *q, int rw, gfp_t gfp_mask)
 {
 	struct request *rq;
+	struct request_list *rl = blk_get_request_list(q, NULL);
 
 	BUG_ON(rw != READ && rw != WRITE);
 
@@ -890,7 +979,7 @@ struct request *blk_get_request(struct r
 	if (gfp_mask & __GFP_WAIT) {
 		rq = get_request_wait(q, rw, NULL);
 	} else {
-		rq = get_request(q, rw, NULL, gfp_mask);
+		rq = get_request(q, rw, NULL, gfp_mask, rl);
 		if (!rq)
 			spin_unlock_irq(q->queue_lock);
 	}
@@ -1073,12 +1162,13 @@ void __blk_put_request(struct request_qu
 	if (req->cmd_flags & REQ_ALLOCED) {
 		int is_sync = rq_is_sync(req) != 0;
 		int priv = req->cmd_flags & REQ_ELVPRIV;
+		struct request_list *rl = rq_rl(q, req);
 
 		BUG_ON(!list_empty(&req->queuelist));
 		BUG_ON(!hlist_unhashed(&req->hash));
 
 		blk_free_request(q, req);
-		freed_request(q, is_sync, priv);
+		freed_request(q, is_sync, priv, rl);
 	}
 }
 EXPORT_SYMBOL_GPL(__blk_put_request);
Index: linux9/block/blk-sysfs.c
===================================================================
--- linux9.orig/block/blk-sysfs.c	2009-04-30 16:18:27.000000000 -0400
+++ linux9/block/blk-sysfs.c	2009-04-30 16:18:29.000000000 -0400
@@ -38,7 +38,7 @@ static ssize_t queue_requests_show(struc
 static ssize_t
 queue_requests_store(struct request_queue *q, const char *page, size_t count)
 {
-	struct request_list *rl = &q->rq;
+	struct request_list *rl = blk_get_request_list(q, NULL);
 	unsigned long nr;
 	int ret = queue_var_store(&nr, page, count);
 	if (nr < BLKDEV_MIN_RQ)
@@ -48,32 +48,55 @@ queue_requests_store(struct request_queu
 	q->nr_requests = nr;
 	blk_queue_congestion_threshold(q);
 
-	if (rl->count[BLK_RW_SYNC] >= queue_congestion_on_threshold(q))
+	if (q->rq_data.count[BLK_RW_SYNC] >= queue_congestion_on_threshold(q))
 		blk_set_queue_congested(q, BLK_RW_SYNC);
-	else if (rl->count[BLK_RW_SYNC] < queue_congestion_off_threshold(q))
+	else if (q->rq_data.count[BLK_RW_SYNC] <
+				queue_congestion_off_threshold(q))
 		blk_clear_queue_congested(q, BLK_RW_SYNC);
 
-	if (rl->count[BLK_RW_ASYNC] >= queue_congestion_on_threshold(q))
+	if (q->rq_data.count[BLK_RW_ASYNC] >= queue_congestion_on_threshold(q))
 		blk_set_queue_congested(q, BLK_RW_ASYNC);
-	else if (rl->count[BLK_RW_ASYNC] < queue_congestion_off_threshold(q))
+	else if (q->rq_data.count[BLK_RW_ASYNC] <
+				queue_congestion_off_threshold(q))
 		blk_clear_queue_congested(q, BLK_RW_ASYNC);
 
-	if (rl->count[BLK_RW_SYNC] >= q->nr_requests) {
+	if (q->rq_data.count[BLK_RW_SYNC] >= q->nr_requests) {
 		blk_set_queue_full(q, BLK_RW_SYNC);
-	} else if (rl->count[BLK_RW_SYNC]+1 <= q->nr_requests) {
+	} else if (q->rq_data.count[BLK_RW_SYNC]+1 <= q->nr_requests) {
 		blk_clear_queue_full(q, BLK_RW_SYNC);
 		wake_up(&rl->wait[BLK_RW_SYNC]);
 	}
 
-	if (rl->count[BLK_RW_ASYNC] >= q->nr_requests) {
+	if (q->rq_data.count[BLK_RW_ASYNC] >= q->nr_requests) {
 		blk_set_queue_full(q, BLK_RW_ASYNC);
-	} else if (rl->count[BLK_RW_ASYNC]+1 <= q->nr_requests) {
+	} else if (q->rq_data.count[BLK_RW_ASYNC]+1 <= q->nr_requests) {
 		blk_clear_queue_full(q, BLK_RW_ASYNC);
 		wake_up(&rl->wait[BLK_RW_ASYNC]);
 	}
 	spin_unlock_irq(q->queue_lock);
 	return ret;
 }
+#ifdef CONFIG_GROUP_IOSCHED
+static ssize_t queue_group_requests_show(struct request_queue *q, char *page)
+{
+	return queue_var_show(q->nr_group_requests, (page));
+}
+
+static ssize_t
+queue_group_requests_store(struct request_queue *q, const char *page,
+					size_t count)
+{
+	unsigned long nr;
+	int ret = queue_var_store(&nr, page, count);
+	if (nr < BLKDEV_MIN_RQ)
+		nr = BLKDEV_MIN_RQ;
+
+	spin_lock_irq(q->queue_lock);
+	q->nr_group_requests = nr;
+	spin_unlock_irq(q->queue_lock);
+	return ret;
+}
+#endif
 
 static ssize_t queue_ra_show(struct request_queue *q, char *page)
 {
@@ -228,6 +251,14 @@ static struct queue_sysfs_entry queue_re
 	.store = queue_requests_store,
 };
 
+#ifdef CONFIG_GROUP_IOSCHED
+static struct queue_sysfs_entry queue_group_requests_entry = {
+	.attr = {.name = "nr_group_requests", .mode = S_IRUGO | S_IWUSR },
+	.show = queue_group_requests_show,
+	.store = queue_group_requests_store,
+};
+#endif
+
 static struct queue_sysfs_entry queue_ra_entry = {
 	.attr = {.name = "read_ahead_kb", .mode = S_IRUGO | S_IWUSR },
 	.show = queue_ra_show,
@@ -308,6 +339,9 @@ static struct queue_sysfs_entry queue_sl
 
 static struct attribute *default_attrs[] = {
 	&queue_requests_entry.attr,
+#ifdef CONFIG_GROUP_IOSCHED
+	&queue_group_requests_entry.attr,
+#endif
 	&queue_ra_entry.attr,
 	&queue_max_hw_sectors_entry.attr,
 	&queue_max_sectors_entry.attr,
@@ -389,12 +423,11 @@ static void blk_release_queue(struct kob
 {
 	struct request_queue *q =
 		container_of(kobj, struct request_queue, kobj);
-	struct request_list *rl = &q->rq;
 
 	blk_sync_queue(q);
 
-	if (rl->rq_pool)
-		mempool_destroy(rl->rq_pool);
+	if (q->rq_data.rq_pool)
+		mempool_destroy(q->rq_data.rq_pool);
 
 	if (q->queue_tags)
 		__blk_queue_free_tags(q);
Index: linux9/block/blk-settings.c
===================================================================
--- linux9.orig/block/blk-settings.c	2009-04-30 15:43:53.000000000 -0400
+++ linux9/block/blk-settings.c	2009-04-30 16:18:29.000000000 -0400
@@ -123,6 +123,9 @@ void blk_queue_make_request(struct reque
 	 * set defaults
 	 */
 	q->nr_requests = BLKDEV_MAX_RQ;
+#ifdef CONFIG_GROUP_IOSCHED
+	q->nr_group_requests = BLKDEV_MAX_GROUP_RQ;
+#endif
 	blk_queue_max_phys_segments(q, MAX_PHYS_SEGMENTS);
 	blk_queue_max_hw_segments(q, MAX_HW_SEGMENTS);
 	blk_queue_segment_boundary(q, BLK_SEG_BOUNDARY_MASK);
Index: linux9/block/elevator-fq.c
===================================================================
--- linux9.orig/block/elevator-fq.c	2009-04-30 16:18:27.000000000 -0400
+++ linux9/block/elevator-fq.c	2009-04-30 16:18:29.000000000 -0400
@@ -954,6 +954,17 @@ struct io_cgroup *cgroup_to_io_cgroup(st
 			    struct io_cgroup, css);
 }
 
+struct request_list *io_group_get_request_list(struct request_queue *q,
+						struct bio *bio)
+{
+	struct io_group *iog;
+
+	iog = io_get_io_group_bio(q, bio, 1);
+	BUG_ON(!iog);
+out:
+	return &iog->rl;
+}
+
 /*
  * Search the bfq_group for bfqd into the hash table (by now only a list)
  * of bgrp.  Must be called under rcu_read_lock().
@@ -1203,6 +1214,8 @@ struct io_group *io_group_chain_alloc(st
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
 
+		blk_init_request_list(&iog->rl);
+
 		if (leaf == NULL) {
 			leaf = iog;
 			prev = leaf;
@@ -1446,6 +1459,8 @@ struct io_group *io_alloc_root_group(str
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
 
+	blk_init_request_list(&iog->rl);
+
 	iocg = &io_root_cgroup;
 	spin_lock_irq(&iocg->lock);
 	rcu_assign_pointer(iog->key, key);
Index: linux9/block/elevator-fq.h
===================================================================
--- linux9.orig/block/elevator-fq.h	2009-04-30 16:18:27.000000000 -0400
+++ linux9/block/elevator-fq.h	2009-04-30 16:18:29.000000000 -0400
@@ -239,8 +239,14 @@ struct io_group {
 
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
+
+	/* request list associated with the group */
+	struct request_list rl;
 };
 
+#define IOG_FLAG_READFULL	1	/* read queue has been filled */
+#define IOG_FLAG_WRITEFULL	2	/* write queue has been filled */
+
 /**
  * struct bfqio_cgroup - bfq cgroup data structure.
  * @css: subsystem state for bfq in the containing cgroup.
@@ -517,6 +523,8 @@ extern void elv_fq_unset_request_ioq(str
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
 extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 						struct bio *bio);
+extern struct request_list *io_group_get_request_list(struct request_queue *q,
+						struct bio *bio);
 
 /* Returns single ioq associated with the io group. */
 static inline struct io_queue *io_group_ioq(struct io_group *iog)

Thanks
Vivek

> Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
> ---
> block/blk-core.c    |   36 +++++++--
> block/blk-sysfs.c   |   22 ++++--
> block/elevator-fq.c |  133 ++++++++++++++++++++++++++++++++--
> block/elevator-fq.h |  201 +++++++++++++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 371 insertions(+), 21 deletions(-)
>
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 29bcfac..21023f7 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -705,11 +705,15 @@ static void ioc_set_batching(struct request_queue *q, struct io_context *ioc)
> static void __freed_request(struct request_queue *q, int rw)
> {
> 	struct request_list *rl = &q->rq;
> -
> -	if (rl->count[rw] < queue_congestion_off_threshold(q))
> +	struct io_group *congested_iog, *full_iog;
> +	
> +	congested_iog = io_congested_io_group(q, rw);
> +	if (rl->count[rw] < queue_congestion_off_threshold(q) &&
> +	    !congested_iog)
> 		blk_clear_queue_congested(q, rw);
>
> -	if (rl->count[rw] + 1 <= q->nr_requests) {
> +	full_iog = io_full_io_group(q, rw);
> +	if (rl->count[rw] + 1 <= q->nr_requests && !full_iog) {
> 		if (waitqueue_active(&rl->wait[rw]))
> 			wake_up(&rl->wait[rw]);
>
> @@ -721,13 +725,16 @@ static void __freed_request(struct request_queue *q, int rw)
>  * A request has just been released.  Account for it, update the full and
>  * congestion status, wake up any waiters.   Called under q->queue_lock.
>  */
> -static void freed_request(struct request_queue *q, int rw, int priv)
> +static void freed_request(struct request_queue *q, struct io_group *iog,
> +			  int rw, int priv)
> {
> 	struct request_list *rl = &q->rq;
>
> 	rl->count[rw]--;
> 	if (priv)
> 		rl->elvpriv--;
> +	if (iog)
> +		io_group_dec_count(iog, rw);
>
> 	__freed_request(q, rw);
>
> @@ -746,16 +753,21 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
> {
> 	struct request *rq = NULL;
> 	struct request_list *rl = &q->rq;
> +	struct io_group *iog;
> 	struct io_context *ioc = NULL;
> 	const int rw = rw_flags & 0x01;
> 	int may_queue, priv;
>
> +	iog = __io_get_io_group(q);
> +
> 	may_queue = elv_may_queue(q, rw_flags);
> 	if (may_queue == ELV_MQUEUE_NO)
> 		goto rq_starved;
>
> -	if (rl->count[rw]+1 >= queue_congestion_on_threshold(q)) {
> -		if (rl->count[rw]+1 >= q->nr_requests) {
> +	if (rl->count[rw]+1 >= queue_congestion_on_threshold(q) ||
> +	    io_group_congestion_on(iog, rw)) {
> +		if (rl->count[rw]+1 >= q->nr_requests ||
> +		    io_group_full(iog, rw)) {
> 			ioc = current_io_context(GFP_ATOMIC, q->node);
> 			/*
> 			 * The queue will fill after this allocation, so set
> @@ -789,8 +801,15 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
> 	if (rl->count[rw] >= (3 * q->nr_requests / 2))
> 		goto out;
>
> +	if (iog)
> +		if (io_group_count(iog, rw) >=
> +		   (3 * io_group_nr_requests(iog) / 2))
> +			goto out;
> +
> 	rl->count[rw]++;
> 	rl->starved[rw] = 0;
> +	if (iog)
> +		io_group_inc_count(iog, rw);
>
> 	priv = !test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags);
> 	if (priv)
> @@ -808,7 +827,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
> 		 * wait queue, but this is pretty rare.
> 		 */
> 		spin_lock_irq(q->queue_lock);
> -		freed_request(q, rw, priv);
> +		freed_request(q, iog, rw, priv);
>
> 		/*
> 		 * in the very unlikely event that allocation failed and no
> @@ -1073,12 +1092,13 @@ void __blk_put_request(struct request_queue *q, struct request *req)
> 	if (req->cmd_flags & REQ_ALLOCED) {
> 		int rw = rq_data_dir(req);
> 		int priv = req->cmd_flags & REQ_ELVPRIV;
> +		struct io_group *iog = io_request_io_group(req);
>
> 		BUG_ON(!list_empty(&req->queuelist));
> 		BUG_ON(!hlist_unhashed(&req->hash));
>
> 		blk_free_request(q, req);
> -		freed_request(q, rw, priv);
> +		freed_request(q, iog, rw, priv);
> 	}
> }
> EXPORT_SYMBOL_GPL(__blk_put_request);
> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
> index 0d98c96..af5191c 100644
> --- a/block/blk-sysfs.c
> +++ b/block/blk-sysfs.c
> @@ -40,6 +40,7 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
> {
> 	struct request_list *rl = &q->rq;
> 	unsigned long nr;
> +	int iog_congested[2], iog_full[2];
> 	int ret = queue_var_store(&nr, page, count);
> 	if (nr < BLKDEV_MIN_RQ)
> 		nr = BLKDEV_MIN_RQ;
> @@ -47,27 +48,32 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
> 	spin_lock_irq(q->queue_lock);
> 	q->nr_requests = nr;
> 	blk_queue_congestion_threshold(q);
> +	io_group_set_nrq_all(q, nr, iog_congested, iog_full);
>
> -	if (rl->count[READ] >= queue_congestion_on_threshold(q))
> +	if (rl->count[READ] >= queue_congestion_on_threshold(q) ||
> +	    iog_congested[READ])
> 		blk_set_queue_congested(q, READ);
> -	else if (rl->count[READ] < queue_congestion_off_threshold(q))
> +	else if (rl->count[READ] < queue_congestion_off_threshold(q) &&
> +		 !iog_congested[READ])
> 		blk_clear_queue_congested(q, READ);
>
> -	if (rl->count[WRITE] >= queue_congestion_on_threshold(q))
> +	if (rl->count[WRITE] >= queue_congestion_on_threshold(q) ||
> +	    iog_congested[WRITE])
> 		blk_set_queue_congested(q, WRITE);
> -	else if (rl->count[WRITE] < queue_congestion_off_threshold(q))
> +	else if (rl->count[WRITE] < queue_congestion_off_threshold(q) &&
> +		 !iog_congested[WRITE])
> 		blk_clear_queue_congested(q, WRITE);
>
> -	if (rl->count[READ] >= q->nr_requests) {
> +	if (rl->count[READ] >= q->nr_requests || iog_full[READ]) {
> 		blk_set_queue_full(q, READ);
> -	} else if (rl->count[READ]+1 <= q->nr_requests) {
> +	} else if (rl->count[READ]+1 <= q->nr_requests && !iog_full[READ]) {
> 		blk_clear_queue_full(q, READ);
> 		wake_up(&rl->wait[READ]);
> 	}
>
> -	if (rl->count[WRITE] >= q->nr_requests) {
> +	if (rl->count[WRITE] >= q->nr_requests || iog_full[WRITE]) {
> 		blk_set_queue_full(q, WRITE);
> -	} else if (rl->count[WRITE]+1 <= q->nr_requests) {
> +	} else if (rl->count[WRITE]+1 <= q->nr_requests && !iog_full[WRITE]) {
> 		blk_clear_queue_full(q, WRITE);
> 		wake_up(&rl->wait[WRITE]);
> 	}
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index df53418..3b021f3 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -924,6 +924,111 @@ struct io_group *io_lookup_io_group_current(struct request_queue *q)
> }
> EXPORT_SYMBOL(io_lookup_io_group_current);
>
> +/*
> + * TODO
> + * This is complete dupulication of blk_queue_congestion_threshold()
> + * except for the argument type and name.  Can we merge them?
> + */
> +static void io_group_nrq_congestion_threshold(struct io_group_nrq *nrq)
> +{
> +	int nr;
> +
> +	nr = nrq->nr_requests - (nrq->nr_requests / 8) + 1;
> +	if (nr > nrq->nr_requests)
> +		nr = nrq->nr_requests;
> +	nrq->nr_congestion_on = nr;
> +
> +	nr = nrq->nr_requests - (nrq->nr_requests / 8)
> +		- (nrq->nr_requests / 16) - 1;
> +	if (nr < 1)
> +		nr = 1;
> +	nrq->nr_congestion_off = nr;
> +}
> +
> +static void io_group_set_nrq(struct io_group_nrq *nrq, int nr_requests,
> +			 int *congested, int *full)
> +{
> +	int i;
> +
> +	BUG_ON(nr_requests < 0);
> +
> +	nrq->nr_requests = nr_requests;
> +	io_group_nrq_congestion_threshold(nrq);
> +
> +	for (i=0; i<2; i++) {
> +		if (nrq->count[i] >= nrq->nr_congestion_on)
> +			congested[i] = 1;
> +		else if (nrq->count[i] < nrq->nr_congestion_off)
> +			congested[i] = 0;
> +
> +		if (nrq->count[i] >= nrq->nr_requests)
> +			full[i] = 1;
> +		else if (nrq->count[i]+1 <= nrq->nr_requests)
> +			full[i] = 0;
> +	}
> +}
> +
> +void io_group_set_nrq_all(struct request_queue *q, int nr,
> +			    int *congested, int *full)
> +{
> +	struct elv_fq_data *efqd = &q->elevator->efqd;
> +	struct hlist_head *head = &efqd->group_list;
> +	struct io_group *root = efqd->root_group;
> +	struct hlist_node *n;
> +	struct io_group *iog;
> +	struct io_group_nrq *nrq;
> +	int nrq_congested[2];
> +	int nrq_full[2];
> +	int i;
> +
> +	for (i=0; i<2; i++)
> +		*(congested + i) = *(full + i) = 0;
> +
> +	nrq = &root->nrq;
> +	io_group_set_nrq(nrq, nr, nrq_congested, nrq_full);
> +	for (i=0; i<2; i++) {
> +		*(congested + i) |= nrq_congested[i];
> +		*(full + i) |= nrq_full[i];
> +	}
> +
> +	hlist_for_each_entry(iog, n, head, elv_data_node) {
> +		nrq = &iog->nrq;
> +		io_group_set_nrq(nrq, nr, nrq_congested, nrq_full);
> +		for (i=0; i<2; i++) {
> +			*(congested + i) |= nrq_congested[i];
> +			*(full + i) |= nrq_full[i];
> +		}
> +	}
> +}
> +
> +struct io_group *io_congested_io_group(struct request_queue *q, int rw)
> +{
> +	struct hlist_head *head = &q->elevator->efqd.group_list;
> +	struct hlist_node *n;
> +	struct io_group *iog;
> +
> +	hlist_for_each_entry(iog, n, head, elv_data_node) {
> +		struct io_group_nrq *nrq = &iog->nrq;
> +		if (nrq->count[rw] >= nrq->nr_congestion_off)
> +			return iog;
> +	}
> +	return NULL;
> +}
> +
> +struct io_group *io_full_io_group(struct request_queue *q, int rw)
> +{
> +	struct hlist_head *head = &q->elevator->efqd.group_list;
> +	struct hlist_node *n;
> +	struct io_group *iog;
> +
> +	hlist_for_each_entry(iog, n, head, elv_data_node) {
> +		struct io_group_nrq *nrq = &iog->nrq;
> +		if (nrq->count[rw] >= nrq->nr_requests)
> +			return iog;
> +	}
> +	return NULL;
> +}
> +
> void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
> {
> 	struct io_entity *entity = &iog->entity;
> @@ -934,6 +1039,12 @@ void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
> 	entity->my_sched_data = &iog->sched_data;
> }
>
> +static void io_group_init_nrq(struct request_queue *q, struct io_group_nrq *nrq)
> +{
> +	nrq->nr_requests = q->nr_requests;
> +	io_group_nrq_congestion_threshold(nrq);
> +}
> +
> void io_group_set_parent(struct io_group *iog, struct io_group *parent)
> {
> 	struct io_entity *entity;
> @@ -1053,6 +1164,8 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
> 		io_group_init_entity(iocg, iog);
> 		iog->my_entity = &iog->entity;
>
> +		io_group_init_nrq(q, &iog->nrq);
> +
> 		if (leaf == NULL) {
> 			leaf = iog;
> 			prev = leaf;
> @@ -1176,7 +1289,7 @@ struct io_group *io_find_alloc_group(struct request_queue *q,
>  * Generic function to make sure cgroup hierarchy is all setup once a request
>  * from a cgroup is received by the io scheduler.
>  */
> -struct io_group *io_get_io_group(struct request_queue *q)
> +struct io_group *__io_get_io_group(struct request_queue *q)
> {
> 	struct cgroup *cgroup;
> 	struct io_group *iog;
> @@ -1192,6 +1305,19 @@ struct io_group *io_get_io_group(struct request_queue *q)
> 	return iog;
> }
>
> +struct io_group *io_get_io_group(struct request_queue *q)
> +{
> +	struct io_group *iog;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(q->queue_lock, flags);
> +	iog = __io_get_io_group(q);
> +	spin_unlock_irqrestore(q->queue_lock, flags);
> +	BUG_ON(!iog);
> +
> +	return iog;
> +}
> +
> void io_free_root_group(struct elevator_queue *e)
> {
> 	struct io_cgroup *iocg = &io_root_cgroup;
> @@ -1220,6 +1346,7 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
> 	iog->entity.parent = NULL;
> 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
> 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
> +	io_group_init_nrq(q, &iog->nrq);
>
> 	iocg = &io_root_cgroup;
> 	spin_lock_irq(&iocg->lock);
> @@ -1533,15 +1660,11 @@ void elv_fq_set_request_io_group(struct request_queue *q,
> 						struct request *rq)
> {
> 	struct io_group *iog;
> -	unsigned long flags;
>
> 	/* Make sure io group hierarchy has been setup and also set the
> 	 * io group to which rq belongs. Later we should make use of
> 	 * bio cgroup patches to determine the io group */
> -	spin_lock_irqsave(q->queue_lock, flags);
> 	iog = io_get_io_group(q);
> -	spin_unlock_irqrestore(q->queue_lock, flags);
> -	BUG_ON(!iog);
>
> 	/* Store iog in rq. TODO: take care of referencing */
> 	rq->iog = iog;
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index fc4110d..f8eabd4 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -187,6 +187,22 @@ struct io_queue {
>
> #ifdef CONFIG_GROUP_IOSCHED
> /**
> + * struct io_group_nrq - structure to store allocated requests info
> + * @nr_requests: maximun num of requests for the io_group
> + * @nr_congestion_on: threshold to determin the io_group is cogested.
> + * @nr_congestion_off: threshold to determin the io_group is not congested.
> + * @count: num of allocated requests.
> + *
> + * All fields are protected by queue_lock.
> + */
> +struct io_group_nrq {
> +	unsigned long nr_requests;
> +	unsigned int nr_congestion_on;
> +	unsigned int nr_congestion_off;
> +	int count[2];
> +};
> +
> +/**
>  * struct bfq_group - per (device, cgroup) data structure.
>  * @entity: schedulable entity to insert into the parent group sched_data.
>  * @sched_data: own sched_data, to contain child entities (they may be
> @@ -235,6 +251,8 @@ struct io_group {
>
> 	/* Single ioq per group, used for noop, deadline, anticipatory */
> 	struct io_queue *ioq;
> +
> +	struct io_group_nrq nrq;
> };
>
> /**
> @@ -469,6 +487,11 @@ extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
> extern void elv_fq_unset_request_ioq(struct request_queue *q,
> 					struct request *rq);
> extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
> +extern void io_group_set_nrq_all(struct request_queue *q, int nr,
> +			    int *congested, int *full);
> +extern struct io_group *io_congested_io_group(struct request_queue *q, int rw);
> +extern struct io_group *io_full_io_group(struct request_queue *q, int rw);
> +extern struct io_group *__io_get_io_group(struct request_queue *q);
>
> /* Returns single ioq associated with the io group. */
> static inline struct io_queue *io_group_ioq(struct io_group *iog)
> @@ -486,6 +509,52 @@ static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
> 	iog->ioq = ioq;
> }
>
> +static inline struct io_group *io_request_io_group(struct request *rq)
> +{
> +	return rq->iog;
> +}
> +
> +static inline unsigned long io_group_nr_requests(struct io_group *iog)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.nr_requests;
> +}
> +
> +static inline int io_group_inc_count(struct io_group *iog, int rw)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.count[rw]++;
> +}
> +
> +static inline int io_group_dec_count(struct io_group *iog, int rw)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.count[rw]--;
> +}
> +
> +static inline int io_group_count(struct io_group *iog, int rw)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.count[rw];
> +}
> +
> +static inline int io_group_congestion_on(struct io_group *iog, int rw)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.count[rw] + 1 >= iog->nrq.nr_congestion_on;
> +}
> +
> +static inline int io_group_congestion_off(struct io_group *iog, int rw)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.count[rw] < iog->nrq.nr_congestion_off;
> +}
> +
> +static inline int io_group_full(struct io_group *iog, int rw)
> +{
> +	BUG_ON(!iog);
> +	return iog->nrq.count[rw] + 1 >= iog->nrq.nr_requests;
> +}
> #else /* !GROUP_IOSCHED */
> /*
>  * No ioq movement is needed in case of flat setup. root io group gets cleaned
> @@ -537,6 +606,71 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
> 	return NULL;
> }
>
> +static inline void io_group_set_nrq_all(struct request_queue *q, int nr,
> +					int *congested, int *full)
> +{
> +	int i;
> +	for (i=0; i<2; i++)
> +		*(congested + i) = *(full + i) = 0;
> +}
> +
> +static inline struct io_group *
> +io_congested_io_group(struct request_queue *q, int rw)
> +{
> +	return NULL;
> +}
> +
> +static inline struct io_group *
> +io_full_io_group(struct request_queue *q, int rw)
> +{
> +	return NULL;
> +}
> +
> +static inline struct io_group *__io_get_io_group(struct request_queue *q)
> +{
> +	return NULL;
> +}
> +
> +static inline struct io_group *io_request_io_group(struct request *rq)
> +{
> +	return NULL;
> +}
> +
> +static inline unsigned long io_group_nr_requests(struct io_group *iog)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_inc_count(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_dec_count(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_count(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_congestion_on(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_congestion_off(struct io_group *iog, int rw)
> +{
> +	return 1;
> +}
> +
> +static inline int io_group_full(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> #endif /* GROUP_IOSCHED */
>
> /* Functions used by blksysfs.c */
> @@ -589,6 +723,9 @@ extern void elv_free_ioq(struct io_queue *ioq);
>
> #else /* CONFIG_ELV_FAIR_QUEUING */
>
> +struct io_group {
> +};
> +
> static inline int elv_init_fq_data(struct request_queue *q,
> 					struct elevator_queue *e)
> {
> @@ -655,5 +792,69 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
> 	return NULL;
> }
>
> +static inline void io_group_set_nrq_all(struct request_queue *q, int nr,
> +					int *congested, int *full)
> +{
> +	int i;
> +	for (i=0; i<2; i++)
> +		*(congested + i) = *(full + i) = 0;
> +}
> +
> +static inline struct io_group *
> +io_congested_io_group(struct request_queue *q, int rw)
> +{
> +	return NULL;
> +}
> +
> +static inline struct io_group *
> +io_full_io_group(struct request_queue *q, int rw)
> +{
> +	return NULL;
> +}
> +
> +static inline struct io_group *__io_get_io_group(struct request_queue *q)
> +{
> +	return NULL;
> +}
> +
> +static inline struct io_group *io_request_io_group(struct request *rq)
> +{
> +	return NULL;
> +}
> +
> +static inline unsigned long io_group_nr_requests(struct io_group *iog)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_inc_count(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_dec_count(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_count(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_congestion_on(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> +
> +static inline int io_group_congestion_off(struct io_group *iog, int rw)
> +{
> +	return 1;
> +}
> +
> +static inline int io_group_full(struct io_group *iog, int rw)
> +{
> +	return 0;
> +}
> #endif /* CONFIG_ELV_FAIR_QUEUING */
> #endif /* _BFQ_SCHED_H */
> -- 
> 1.5.4.3
>
>
> -- 
> IKEDA, Munehiro
> NEC Corporation of America
>   m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
>
