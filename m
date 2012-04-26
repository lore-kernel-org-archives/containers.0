From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/11] block: prepare for multiple request_lists
Date: Thu, 26 Apr 2012 14:59:20 -0700
Message-ID: <1335477561-11131-11-git-send-email-tj@kernel.org>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1335477561-11131-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Request allocation is about to be made per-blkg meaning that there'll
be multiple request lists.

* Make queue full state per request_list.  blk_*queue_full() functions
  are renamed to blk_*rl_full() and takes @rl instead of @q.

* Rename blk_init_free_list() to blk_init_rl() and make it take @rl
  instead of @q.  Also add @gfp_mask parameter.

* Add blk_exit_rl() instead of destroying rl directly from
  blk_release_queue().

* Add request_list->q and make request alloc/free functions -
  blk_free_request(), [__]freed_request(), __get_request() - take @rl
  instead of @q.

This patch doesn't introduce any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-core.c       |   56 ++++++++++++++++++++++++++---------------------
 block/blk-sysfs.c      |   12 ++++------
 block/blk.h            |    3 ++
 include/linux/blkdev.h |   32 +++++++++++++++------------
 4 files changed, 57 insertions(+), 46 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 7377eb6..38b6d3d 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -504,13 +504,13 @@ void blk_cleanup_queue(struct request_queue *q)
 }
 EXPORT_SYMBOL(blk_cleanup_queue);
 
-static int blk_init_free_list(struct request_queue *q)
+int blk_init_rl(struct request_list *rl, struct request_queue *q,
+		gfp_t gfp_mask)
 {
-	struct request_list *rl = &q->rq;
-
 	if (unlikely(rl->rq_pool))
 		return 0;
 
+	rl->q = q;
 	rl->count[BLK_RW_SYNC] = rl->count[BLK_RW_ASYNC] = 0;
 	rl->starved[BLK_RW_SYNC] = rl->starved[BLK_RW_ASYNC] = 0;
 	init_waitqueue_head(&rl->wait[BLK_RW_SYNC]);
@@ -518,13 +518,19 @@ static int blk_init_free_list(struct request_queue *q)
 
 	rl->rq_pool = mempool_create_node(BLKDEV_MIN_RQ, mempool_alloc_slab,
 					  mempool_free_slab, request_cachep,
-					  GFP_KERNEL, q->node);
+					  gfp_mask, q->node);
 	if (!rl->rq_pool)
 		return -ENOMEM;
 
 	return 0;
 }
 
+void blk_exit_rl(struct request_list *rl)
+{
+	if (rl->rq_pool)
+		mempool_destroy(rl->rq_pool);
+}
+
 struct request_queue *blk_alloc_queue(gfp_t gfp_mask)
 {
 	return blk_alloc_queue_node(gfp_mask, -1);
@@ -666,7 +672,7 @@ blk_init_allocated_queue(struct request_queue *q, request_fn_proc *rfn,
 	if (!q)
 		return NULL;
 
-	if (blk_init_free_list(q))
+	if (blk_init_rl(&q->rq, q, GFP_KERNEL))
 		return NULL;
 
 	q->request_fn		= rfn;
@@ -708,15 +714,15 @@ bool blk_get_queue(struct request_queue *q)
 }
 EXPORT_SYMBOL(blk_get_queue);
 
-static inline void blk_free_request(struct request_queue *q, struct request *rq)
+static inline void blk_free_request(struct request_list *rl, struct request *rq)
 {
 	if (rq->cmd_flags & REQ_ELVPRIV) {
-		elv_put_request(q, rq);
+		elv_put_request(rl->q, rq);
 		if (rq->elv.icq)
 			put_io_context(rq->elv.icq->ioc);
 	}
 
-	mempool_free(rq, q->rq.rq_pool);
+	mempool_free(rq, rl->rq_pool);
 }
 
 /*
@@ -753,9 +759,9 @@ static void ioc_set_batching(struct request_queue *q, struct io_context *ioc)
 	ioc->last_waited = jiffies;
 }
 
-static void __freed_request(struct request_queue *q, int sync)
+static void __freed_request(struct request_list *rl, int sync)
 {
-	struct request_list *rl = &q->rq;
+	struct request_queue *q = rl->q;
 
 	if (rl->count[sync] < queue_congestion_off_threshold(q))
 		blk_clear_queue_congested(q, sync);
@@ -764,7 +770,7 @@ static void __freed_request(struct request_queue *q, int sync)
 		if (waitqueue_active(&rl->wait[sync]))
 			wake_up(&rl->wait[sync]);
 
-		blk_clear_queue_full(q, sync);
+		blk_clear_rl_full(rl, sync);
 	}
 }
 
@@ -772,9 +778,9 @@ static void __freed_request(struct request_queue *q, int sync)
  * A request has just been released.  Account for it, update the full and
  * congestion status, wake up any waiters.   Called under q->queue_lock.
  */
-static void freed_request(struct request_queue *q, unsigned int flags)
+static void freed_request(struct request_list *rl, unsigned int flags)
 {
-	struct request_list *rl = &q->rq;
+	struct request_queue *q = rl->q;
 	int sync = rw_is_sync(flags);
 
 	q->nr_rqs[sync]--;
@@ -782,10 +788,10 @@ static void freed_request(struct request_queue *q, unsigned int flags)
 	if (flags & REQ_ELVPRIV)
 		q->nr_rqs_elvpriv--;
 
-	__freed_request(q, sync);
+	__freed_request(rl, sync);
 
 	if (unlikely(rl->starved[sync ^ 1]))
-		__freed_request(q, sync ^ 1);
+		__freed_request(rl, sync ^ 1);
 }
 
 /*
@@ -825,7 +831,7 @@ static struct io_context *rq_ioc(struct bio *bio)
 
 /**
  * __get_request - get a free request
- * @q: request_queue to allocate request from
+ * @rl: request list to allocate from
  * @rw_flags: RW and SYNC flags
  * @bio: bio to allocate request for (can be %NULL)
  * @gfp_mask: allocation mask
@@ -837,11 +843,11 @@ static struct io_context *rq_ioc(struct bio *bio)
  * Returns %NULL on failure, with @q->queue_lock held.
  * Returns !%NULL on success, with @q->queue_lock *not held*.
  */
-static struct request *__get_request(struct request_queue *q, int rw_flags,
+static struct request *__get_request(struct request_list *rl, int rw_flags,
 				     struct bio *bio, gfp_t gfp_mask)
 {
+	struct request_queue *q = rl->q;
 	struct request *rq;
-	struct request_list *rl = &q->rq;
 	struct elevator_type *et = q->elevator->type;
 	struct io_context *ioc = rq_ioc(bio);
 	struct io_cq *icq = NULL;
@@ -863,9 +869,9 @@ static struct request *__get_request(struct request_queue *q, int rw_flags,
 			 * This process will be allowed to complete a batch of
 			 * requests, others will be blocked.
 			 */
-			if (!blk_queue_full(q, is_sync)) {
+			if (!blk_rl_full(rl, is_sync)) {
 				ioc_set_batching(q, ioc);
-				blk_set_queue_full(q, is_sync);
+				blk_set_rl_full(rl, is_sync);
 			} else {
 				if (may_queue != ELV_MQUEUE_MUST
 						&& !ioc_batching(q, ioc)) {
@@ -915,7 +921,7 @@ static struct request *__get_request(struct request_queue *q, int rw_flags,
 	spin_unlock_irq(q->queue_lock);
 
 	/* allocate and init request */
-	rq = mempool_alloc(q->rq.rq_pool, gfp_mask);
+	rq = mempool_alloc(rl->rq_pool, gfp_mask);
 	if (!rq)
 		goto fail_alloc;
 
@@ -979,7 +985,7 @@ fail_alloc:
 	 * queue, but this is pretty rare.
 	 */
 	spin_lock_irq(q->queue_lock);
-	freed_request(q, rw_flags);
+	freed_request(rl, rw_flags);
 
 	/*
 	 * in the very unlikely event that allocation failed and no
@@ -1016,7 +1022,7 @@ static struct request *get_request(struct request_queue *q, int rw_flags,
 	struct request_list *rl = &q->rq;
 	struct request *rq;
 retry:
-	rq = __get_request(q, rw_flags, bio, gfp_mask);
+	rq = __get_request(&q->rq, rw_flags, bio, gfp_mask);
 	if (rq)
 		return rq;
 
@@ -1216,8 +1222,8 @@ void __blk_put_request(struct request_queue *q, struct request *req)
 		BUG_ON(!list_empty(&req->queuelist));
 		BUG_ON(!hlist_unhashed(&req->hash));
 
-		blk_free_request(q, req);
-		freed_request(q, flags);
+		blk_free_request(&q->rq, req);
+		freed_request(&q->rq, flags);
 	}
 }
 EXPORT_SYMBOL_GPL(__blk_put_request);
diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index aa41b47..234ce7c 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -66,16 +66,16 @@ queue_requests_store(struct request_queue *q, const char *page, size_t count)
 		blk_clear_queue_congested(q, BLK_RW_ASYNC);
 
 	if (rl->count[BLK_RW_SYNC] >= q->nr_requests) {
-		blk_set_queue_full(q, BLK_RW_SYNC);
+		blk_set_rl_full(rl, BLK_RW_SYNC);
 	} else {
-		blk_clear_queue_full(q, BLK_RW_SYNC);
+		blk_clear_rl_full(rl, BLK_RW_SYNC);
 		wake_up(&rl->wait[BLK_RW_SYNC]);
 	}
 
 	if (rl->count[BLK_RW_ASYNC] >= q->nr_requests) {
-		blk_set_queue_full(q, BLK_RW_ASYNC);
+		blk_set_rl_full(rl, BLK_RW_ASYNC);
 	} else {
-		blk_clear_queue_full(q, BLK_RW_ASYNC);
+		blk_clear_rl_full(rl, BLK_RW_ASYNC);
 		wake_up(&rl->wait[BLK_RW_ASYNC]);
 	}
 	spin_unlock_irq(q->queue_lock);
@@ -476,7 +476,6 @@ static void blk_release_queue(struct kobject *kobj)
 {
 	struct request_queue *q =
 		container_of(kobj, struct request_queue, kobj);
-	struct request_list *rl = &q->rq;
 
 	blk_sync_queue(q);
 
@@ -489,8 +488,7 @@ static void blk_release_queue(struct kobject *kobj)
 		elevator_exit(q->elevator);
 	}
 
-	if (rl->rq_pool)
-		mempool_destroy(rl->rq_pool);
+	blk_exit_rl(&q->rq);
 
 	if (q->queue_tags)
 		__blk_queue_free_tags(q);
diff --git a/block/blk.h b/block/blk.h
index 85f6ae4..a134231 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -18,6 +18,9 @@ static inline void __blk_get_queue(struct request_queue *q)
 	kobject_get(&q->kobj);
 }
 
+int blk_init_rl(struct request_list *rl, struct request_queue *q,
+		gfp_t gfp_mask);
+void blk_exit_rl(struct request_list *rl);
 void init_request_from_bio(struct request *req, struct bio *bio);
 void blk_rq_bio_prep(struct request_queue *q, struct request *rq,
 			struct bio *bio);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index b085be7..92fc25f 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -45,7 +45,12 @@ struct blkcg_gq;
 struct request;
 typedef void (rq_end_io_fn)(struct request *, int);
 
+#define BLK_RL_SYNCFULL		(1U << 0)
+#define BLK_RL_ASYNCFULL	(1U << 1)
+
 struct request_list {
+	struct request_queue	*q;	/* the queue this rl belongs to */
+
 	/*
 	 * count[], starved[], and wait[] are indexed by
 	 * BLK_RW_SYNC/BLK_RW_ASYNC
@@ -54,6 +59,7 @@ struct request_list {
 	int			starved[2];
 	mempool_t		*rq_pool;
 	wait_queue_head_t	wait[2];
+	unsigned int		flags;
 };
 
 /*
@@ -565,27 +571,25 @@ static inline bool rq_is_sync(struct request *rq)
 	return rw_is_sync(rq->cmd_flags);
 }
 
-static inline int blk_queue_full(struct request_queue *q, int sync)
+static inline bool blk_rl_full(struct request_list *rl, bool sync)
 {
-	if (sync)
-		return test_bit(QUEUE_FLAG_SYNCFULL, &q->queue_flags);
-	return test_bit(QUEUE_FLAG_ASYNCFULL, &q->queue_flags);
+	unsigned int flag = sync ? BLK_RL_SYNCFULL : BLK_RL_ASYNCFULL;
+
+	return rl->flags & flag;
 }
 
-static inline void blk_set_queue_full(struct request_queue *q, int sync)
+static inline void blk_set_rl_full(struct request_list *rl, bool sync)
 {
-	if (sync)
-		queue_flag_set(QUEUE_FLAG_SYNCFULL, q);
-	else
-		queue_flag_set(QUEUE_FLAG_ASYNCFULL, q);
+	unsigned int flag = sync ? BLK_RL_SYNCFULL : BLK_RL_ASYNCFULL;
+
+	rl->flags |= flag;
 }
 
-static inline void blk_clear_queue_full(struct request_queue *q, int sync)
+static inline void blk_clear_rl_full(struct request_list *rl, bool sync)
 {
-	if (sync)
-		queue_flag_clear(QUEUE_FLAG_SYNCFULL, q);
-	else
-		queue_flag_clear(QUEUE_FLAG_ASYNCFULL, q);
+	unsigned int flag = sync ? BLK_RL_SYNCFULL : BLK_RL_ASYNCFULL;
+
+	rl->flags &= ~flag;
 }
 
 
-- 
1.7.7.3
