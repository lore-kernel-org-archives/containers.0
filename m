From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 16/20] io-controller: Per cgroup request descriptor support
Date: Fri, 19 Jun 2009 16:37:34 -0400
Message-ID: <1245443858-8487-17-git-send-email-vgoyal__27014.7692216144$1245445184$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245443858-8487-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o Currently a request queue has got fixed number of request descriptors for
  sync and async requests. Once the request descriptors are consumed, new
  processes are put to sleep and they effectively become serialized. Because
  sync and async queues are separate, async requests don't impact sync ones
  but if one is looking for fairness between async requests, that is not
  achievable if request queue descriptors become bottleneck.

o Make request descriptor's per io group so that if there is lots of IO
  going on in one cgroup, it does not impact the IO of other group.

o This is just one relatively simple way of doing things. This patch will
  probably change after the feedback. Folks have raised concerns that in
  hierchical setup, child's request descriptors should be capped by parent's
  request descriptors. May be we need to have per cgroup per device files
  in cgroups where one can specify the upper limit of request descriptors
  and whenever a cgroup is created one needs to assign request descritor
  limit making sure total sum of child's request descriptor is not more than
  of parent.

  I guess something like memory controller. Anyway, that would be the next
  step. For the time being, we have implemented something simpler as follows.

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
 block/blk-core.c       |  305 +++++++++++++++++++++++++++++++++++++----------
 block/blk-settings.c   |    1 +
 block/blk-sysfs.c      |   58 +++++++--
 block/elevator-fq.c    |   14 +++
 block/elevator-fq.h    |    5 +
 block/elevator.c       |    6 +-
 include/linux/blkdev.h |   87 +++++++++++++-
 7 files changed, 394 insertions(+), 82 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index c77b5b2..35e3725 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -480,20 +480,30 @@ void blk_cleanup_queue(struct request_queue *q)
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
+	/*
+	 * Initialize the queue request list in case there are non-hiearchical
+	 * io schedulers not making use of fair queuing infrastructure.
+	 *
+	 * For ioschedulers making use of fair queuing infrastructure, request
+	 * list is inside the associated group and when that group is
+	 * instanciated, it takes care of initializing the request list also.
+	 */
+	blk_init_request_list(&q->rq);
+	q->rq_data.rq_pool = mempool_create_node(BLKDEV_MIN_RQ,
+				mempool_alloc_slab, mempool_free_slab,
+				request_cachep, q->node);
 
-	if (!rl->rq_pool)
+	if (!q->rq_data.rq_pool)
 		return -ENOMEM;
 
 	return 0;
@@ -590,6 +600,9 @@ blk_init_queue_node(request_fn_proc *rfn, spinlock_t *lock, int node_id)
 		return NULL;
 	}
 
+	/* init starved waiter wait queue */
+	init_waitqueue_head(&q->rq_data.starved_wait);
+
 	/*
 	 * if caller didn't supply a lock, they get per-queue locking with
 	 * our embedded lock
@@ -639,14 +652,14 @@ static inline void blk_free_request(struct request_queue *q, struct request *rq)
 {
 	if (rq->cmd_flags & REQ_ELVPRIV)
 		elv_put_request(q, rq);
-	mempool_free(rq, q->rq.rq_pool);
+	mempool_free(rq, q->rq_data.rq_pool);
 }
 
 static struct request *
 blk_alloc_request(struct request_queue *q, struct bio *bio, int flags, int priv,
 					gfp_t gfp_mask)
 {
-	struct request *rq = mempool_alloc(q->rq.rq_pool, gfp_mask);
+	struct request *rq = mempool_alloc(q->rq_data.rq_pool, gfp_mask);
 
 	if (!rq)
 		return NULL;
@@ -657,7 +670,7 @@ blk_alloc_request(struct request_queue *q, struct bio *bio, int flags, int priv,
 
 	if (priv) {
 		if (unlikely(elv_set_request(q, rq, bio, gfp_mask))) {
-			mempool_free(rq, q->rq.rq_pool);
+			mempool_free(rq, q->rq_data.rq_pool);
 			return NULL;
 		}
 		rq->cmd_flags |= REQ_ELVPRIV;
@@ -700,18 +713,18 @@ static void ioc_set_batching(struct request_queue *q, struct io_context *ioc)
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
 
@@ -719,63 +732,133 @@ static void __freed_request(struct request_queue *q, int sync)
  * A request has just been released.  Account for it, update the full and
  * congestion status, wake up any waiters.   Called under q->queue_lock.
  */
-static void freed_request(struct request_queue *q, int sync, int priv)
-{
-	struct request_list *rl = &q->rq;
+static void freed_request(struct request_queue *q, int sync, int priv,
+					struct request_list *rl)
+{
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
+	if (priv && rl->count[sync] > 0)
+		rl->count[sync]--;
+
+	BUG_ON(!q->rq_data.count[sync]);
+	q->rq_data.count[sync]--;
 
-	rl->count[sync]--;
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
+}
+
+/*
+ * Returns whether one can sleep on this request list or not. There are
+ * cases (elevator switch) where request list might not have allocated
+ * any request descriptor but we deny request allocation due to gloabl
+ * limits. In that case one should sleep on global list as on this request
+ * list no wakeup will take place.
+ *
+ * Also sets the request list starved flag if there are no requests pending
+ * in the direction of rq.
+ *
+ * Return 1 --> sleep on request list, 0 --> sleep on global list
+ */
+static int can_sleep_on_request_list(struct request_list *rl, int is_sync)
+{
+	if (unlikely(rl->count[is_sync] == 0)) {
+		/*
+		 * If there is a request pending in other direction
+		 * in same io group, then set the starved flag of
+		 * the group request list. Otherwise, we need to
+		 * make this process sleep in global starved list
+		 * to make sure it will not sleep indefinitely.
+		 */
+		if (rl->count[is_sync ^ 1] != 0) {
+			rl->starved[is_sync] = 1;
+			return 1;
+		} else
+			return 0;
+	}
+
+	return 1;
 }
 
 /*
  * Get a free request, queue_lock must be held.
- * Returns NULL on failure, with queue_lock held.
+ * Returns NULL on failure, with queue_lock held. Also sets the "reason" field
+ * in case of failure. This reason field helps caller decide to whether sleep
+ * on per group list or global per queue list.
+ * reason = 0 sleep on per group list
+ * reason = 1 sleep on global list
+ *
  * Returns !NULL on success, with queue_lock *not held*.
  */
 static struct request *get_request(struct request_queue *q, int rw_flags,
-				   struct bio *bio, gfp_t gfp_mask)
+					struct bio *bio, gfp_t gfp_mask,
+					struct request_list *rl, int *reason)
 {
 	struct request *rq = NULL;
-	struct request_list *rl = &q->rq;
 	struct io_context *ioc = NULL;
 	const bool is_sync = rw_is_sync(rw_flags) != 0;
 	int may_queue, priv;
+	int sleep_on_global = 0;
 
 	may_queue = elv_may_queue(q, rw_flags);
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
@@ -783,21 +866,60 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 	 * limit of requests, otherwise we could have thousands of requests
 	 * allocated with any setting of ->nr_requests
 	 */
-	if (rl->count[is_sync] >= (3 * q->nr_requests / 2))
+
+	if (q->rq_data.count[is_sync] >= (3 * q->nr_requests / 2)) {
+		/*
+		 * Queue is too full for allocation. On which request queue
+		 * the task should sleep? Generally it should sleep on its
+		 * request list but if elevator switch is happening, in that
+		 * window, request descriptors are allocated from global
+		 * pool and are not accounted against any particular request
+		 * list as group is going away.
+		 *
+		 * So it might happen that request list does not have any
+		 * requests allocated at all and if process sleeps on per
+		 * group request list, it will not be woken up. In such case,
+		 * make it sleep on global starved list.
+		 */
+		if (test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags)
+		    || !can_sleep_on_request_list(rl, is_sync))
+			sleep_on_global = 1;
+		goto out;
+	}
+
+	/*
+	 * Allocation of request is allowed from queue perspective. Now check
+	 * from per group request list
+	 */
+
+	if (rl->count[is_sync] >= (3 * q->nr_group_requests / 2))
 		goto out;
 
-	rl->count[is_sync]++;
 	rl->starved[is_sync] = 0;
 
+	q->rq_data.count[is_sync]++;
+
 	priv = !test_bit(QUEUE_FLAG_ELVSWITCH, &q->queue_flags);
-	if (priv)
-		rl->elvpriv++;
+	if (priv) {
+		q->rq_data.elvpriv++;
+		/*
+		 * Account the request to request list only if request is
+		 * going to elevator. During elevator switch, there will
+		 * be small window where group is going away and new group
+		 * will not be allocated till elevator switch is complete.
+		 * So till then instead of slowing down the application,
+		 * we will continue to allocate request from total common
+		 * pool instead of per group limit
+		 */
+		rl->count[is_sync]++;
+	}
 
 	if (blk_queue_io_stat(q))
 		rw_flags |= REQ_IO_STAT;
 	spin_unlock_irq(q->queue_lock);
 
 	rq = blk_alloc_request(q, bio, rw_flags, priv, gfp_mask);
+
 	if (unlikely(!rq)) {
 		/*
 		 * Allocation failed presumably due to memory. Undo anything
@@ -807,7 +929,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 		 * wait queue, but this is pretty rare.
 		 */
 		spin_lock_irq(q->queue_lock);
-		freed_request(q, is_sync, priv);
+		freed_request(q, is_sync, priv, rl);
 
 		/*
 		 * in the very unlikely event that allocation failed and no
@@ -817,9 +939,8 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 		 * rq mempool into READ and WRITE
 		 */
 rq_starved:
-		if (unlikely(rl->count[is_sync] == 0))
-			rl->starved[is_sync] = 1;
-
+		if (!can_sleep_on_request_list(rl, is_sync))
+			sleep_on_global = 1;
 		goto out;
 	}
 
@@ -834,6 +955,8 @@ rq_starved:
 
 	trace_block_getrq(q, bio, rw_flags & 1);
 out:
+	if (reason && sleep_on_global)
+		*reason = 1;
 	return rq;
 }
 
@@ -847,16 +970,44 @@ static struct request *get_request_wait(struct request_queue *q, int rw_flags,
 					struct bio *bio)
 {
 	const bool is_sync = rw_is_sync(rw_flags) != 0;
+	int sleep_on_global = 0;
 	struct request *rq;
+	struct request_list *rl = blk_get_request_list(q, bio);
+	struct io_group *iog = NULL;
 
-	rq = get_request(q, rw_flags, bio, GFP_NOIO);
+	rq = get_request(q, rw_flags, bio, GFP_NOIO, rl, &sleep_on_global);
 	while (!rq) {
 		DEFINE_WAIT(wait);
 		struct io_context *ioc;
-		struct request_list *rl = &q->rq;
 
-		prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
-				TASK_UNINTERRUPTIBLE);
+		if (sleep_on_global) {
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
+			/*
+			 * We are about to sleep on a request list and we
+			 * drop queue lock. After waking up, we will do
+			 * finish_wait() on request list and in the mean
+			 * time group might be gone. Take a reference to
+			 * the group now.
+			 */
+			prepare_to_wait_exclusive(&rl->wait[is_sync], &wait,
+					TASK_UNINTERRUPTIBLE);
+#ifdef CONFIG_GROUP_IOSCHED
+			iog = rl_iog(rl);
+			if (iog)
+				elv_get_iog(iog);
+#endif
+		}
 
 		trace_block_sleeprq(q, bio, rw_flags & 1);
 
@@ -874,9 +1025,30 @@ static struct request *get_request_wait(struct request_queue *q, int rw_flags,
 		ioc_set_batching(q, ioc);
 
 		spin_lock_irq(q->queue_lock);
-		finish_wait(&rl->wait[is_sync], &wait);
 
-		rq = get_request(q, rw_flags, bio, GFP_NOIO);
+		if (sleep_on_global) {
+			finish_wait(&q->rq_data.starved_wait, &wait);
+			sleep_on_global = 0;
+		} else {
+			finish_wait(&rl->wait[is_sync], &wait);
+#ifdef CONFIG_GROUP_IOSCHED
+			/*
+			 * We had taken a reference to the rl/iog.
+			 * Put that now
+			 */
+			iog = rl_iog(rl);
+			if (iog)
+				elv_put_iog(iog);
+#endif
+		}
+
+		/*
+		 * After the sleep check the rl again in case cgrop bio
+		 * belonged to is gone and it is mapped to root group now
+		 */
+		rl = blk_get_request_list(q, bio);
+		rq = get_request(q, rw_flags, bio, GFP_NOIO, rl,
+					&sleep_on_global);
 	};
 
 	return rq;
@@ -885,14 +1057,16 @@ static struct request *get_request_wait(struct request_queue *q, int rw_flags,
 struct request *blk_get_request(struct request_queue *q, int rw, gfp_t gfp_mask)
 {
 	struct request *rq;
+	struct request_list *rl;
 
 	BUG_ON(rw != READ && rw != WRITE);
 
 	spin_lock_irq(q->queue_lock);
+	rl = blk_get_request_list(q, NULL);
 	if (gfp_mask & __GFP_WAIT) {
 		rq = get_request_wait(q, rw, NULL);
 	} else {
-		rq = get_request(q, rw, NULL, gfp_mask);
+		rq = get_request(q, rw, NULL, gfp_mask, rl, NULL);
 		if (!rq)
 			spin_unlock_irq(q->queue_lock);
 	}
@@ -1075,12 +1249,13 @@ void __blk_put_request(struct request_queue *q, struct request *req)
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
diff --git a/block/blk-settings.c b/block/blk-settings.c
index 57af728..3230d1f 100644
--- a/block/blk-settings.c
+++ b/block/blk-settings.c
@@ -123,6 +123,7 @@ void blk_queue_make_request(struct request_queue *q, make_request_fn *mfn)
 	 * set defaults
 	 */
 	q->nr_requests = BLKDEV_MAX_RQ;
+	q->nr_group_requests = BLKDEV_MAX_GROUP_RQ;
 	blk_queue_max_phys_segments(q, MAX_PHYS_SEGMENTS);
 	blk_queue_max_hw_segments(q, MAX_HW_SEGMENTS);
 	blk_queue_segment_boundary(q, BLK_SEG_BOUNDARY_MASK);
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 3ff9bba..3a108ff 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -38,42 +38,66 @@ static ssize_t queue_requests_show(struct request_queue *q, char *page)
 static ssize_t
 queue_requests_store(struct request_queue *q, const char *page, size_t count)
 {
-	struct request_list *rl = &q->rq;
+	struct request_list *rl;
 	unsigned long nr;
 	int ret = queue_var_store(&nr, page, count);
 	if (nr < BLKDEV_MIN_RQ)
 		nr = BLKDEV_MIN_RQ;
 
 	spin_lock_irq(q->queue_lock);
+	rl = blk_get_request_list(q, NULL);
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
@@ -224,6 +248,14 @@ static struct queue_sysfs_entry queue_requests_entry = {
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
@@ -278,6 +310,9 @@ static struct queue_sysfs_entry queue_iostats_entry = {
 
 static struct attribute *default_attrs[] = {
 	&queue_requests_entry.attr,
+#ifdef CONFIG_GROUP_IOSCHED
+	&queue_group_requests_entry.attr,
+#endif
 	&queue_ra_entry.attr,
 	&queue_max_hw_sectors_entry.attr,
 	&queue_max_sectors_entry.attr,
@@ -353,12 +388,11 @@ static void blk_release_queue(struct kobject *kobj)
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
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 18dbcc1..16f75ad 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1082,6 +1082,16 @@ struct io_cgroup *cgroup_to_io_cgroup(struct cgroup *cgroup)
 			    struct io_cgroup, css);
 }
 
+struct request_list *io_group_get_request_list(struct request_queue *q,
+						struct bio *bio)
+{
+	struct io_group *iog;
+
+	iog = io_get_io_group(q, bio, 1);
+	BUG_ON(!iog);
+	return &iog->rl;
+}
+
 /*
  * Search the bfq_group for bfqd into the hash table (by now only a list)
  * of bgrp.  Must be called under rcu_read_lock().
@@ -1297,6 +1307,8 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 		 */
 		elv_get_iog(iog);
 
+		blk_init_request_list(&iog->rl);
+
 		if (leaf == NULL) {
 			leaf = iog;
 			prev = leaf;
@@ -1557,6 +1569,8 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
 
+	blk_init_request_list(&iog->rl);
+
 	iocg = &io_root_cgroup;
 	spin_lock_irq(&iocg->lock);
 	rcu_assign_pointer(iog->key, key);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 6d0df21..c2f71d7 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -257,6 +257,9 @@ struct io_group {
 
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
+
+	/* request list associated with the group */
+	struct request_list rl;
 };
 
 /**
@@ -535,6 +538,8 @@ extern void elv_fq_unset_request_ioq(struct request_queue *q,
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
 extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 						struct bio *bio);
+extern struct request_list *io_group_get_request_list(struct request_queue *q,
+						struct bio *bio);
 
 /* Returns single ioq associated with the io group. */
 static inline struct io_queue *io_group_ioq(struct io_group *iog)
diff --git a/block/elevator.c b/block/elevator.c
index b49efd6..d8ceca8 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -668,7 +668,7 @@ void elv_quiesce_start(struct request_queue *q)
 	 * make sure we don't have any requests in flight
 	 */
 	elv_drain_elevator(q);
-	while (q->rq.elvpriv) {
+	while (q->rq_data.elvpriv) {
 		blk_start_queueing(q);
 		spin_unlock_irq(q->queue_lock);
 		msleep(10);
@@ -768,8 +768,8 @@ void elv_insert(struct request_queue *q, struct request *rq, int where)
 	}
 
 	if (unplug_it && blk_queue_plugged(q)) {
-		int nrq = q->rq.count[BLK_RW_SYNC] + q->rq.count[BLK_RW_ASYNC]
-			- q->in_flight;
+		int nrq = q->rq_data.count[BLK_RW_SYNC] +
+				q->rq_data.count[BLK_RW_ASYNC] - q->in_flight;
 
 		if (nrq >= q->unplug_thresh)
 			__generic_unplug_device(q);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 539cb9d..7fd7d33 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -32,21 +32,51 @@ struct request;
 struct sg_io_hdr;
 
 #define BLKDEV_MIN_RQ	4
+
+#ifdef CONFIG_GROUP_IOSCHED
+#define BLKDEV_MAX_RQ	512	/* Default maximum for queue */
+#define BLKDEV_MAX_GROUP_RQ    128      /* Default maximum per group*/
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
@@ -337,6 +367,9 @@ struct request_queue
 	 */
 	struct request_list	rq;
 
+	/* Contains request pool and other data like starved data */
+	struct request_data	rq_data;
+
 	request_fn_proc		*request_fn;
 	make_request_fn		*make_request_fn;
 	prep_rq_fn		*prep_rq_fn;
@@ -399,6 +432,8 @@ struct request_queue
 	 * queue settings
 	 */
 	unsigned long		nr_requests;	/* Max # of requests */
+	/* Max # of per io group requests */
+	unsigned long		nr_group_requests;
 	unsigned int		nr_congestion_on;
 	unsigned int		nr_congestion_off;
 	unsigned int		nr_batching;
@@ -772,6 +807,54 @@ extern int scsi_cmd_ioctl(struct request_queue *, struct gendisk *, fmode_t,
 extern int sg_scsi_ioctl(struct request_queue *, struct gendisk *, fmode_t,
 			 struct scsi_ioctl_command __user *);
 
+extern void blk_init_request_list(struct request_list *rl);
+
+static inline struct request_list *blk_get_request_list(struct request_queue *q,
+						struct bio *bio)
+{
+#ifdef CONFIG_GROUP_IOSCHED
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return &q->rq;
+
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
+	struct io_group *iog;
+	int priv = rq->cmd_flags & REQ_ELVPRIV;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return &q->rq;
+
+	BUG_ON(priv && !rq->ioq);
+
+	if (priv)
+		iog = ioq_to_io_group(rq->ioq);
+	else
+		iog = q->elevator->efqd.root_group;
+
+	BUG_ON(!iog);
+	return &iog->rl;
+#else
+	return &q->rq;
+#endif
+}
+
+static inline struct io_group *rl_iog(struct request_list *rl)
+{
+#ifdef CONFIG_GROUP_IOSCHED
+	return container_of(rl, struct io_group, rl);
+#else
+	return NULL;
+#endif
+}
+
 /*
  * Temporary export, until SCSI gets fixed up.
  */
-- 
1.6.0.6
