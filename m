From: "Satoshi UCHIDA" <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>
Subject: [PATCH][cfq-cgroups][02/12] Introduce "cfq_driver_data" structure.
Date: Wed, 12 Nov 2008 17:24:38 +0900
Message-ID: <000f01c944a0$1ab670f0$502352d0$__17373.1199269698$1226479409$gmane$org@jp.nec.com>
References: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <000c01c9449e$c5bcdc20$51369460$@jp.nec.com>
Content-Language: ja
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, 'Ryo Tsuruta' <ryov@valin>
Cc: 'Andrew Morton' <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, 'SUGAWARA Tomoyoshi' <tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


  This patch introduces "cfq_driver_Data" structure.
  This structure extract driver unique data from "cfq_data" structure.


    Signed-off-by: Satoshi UCHIDA <s-uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org>

---
 block/cfq-iosched.c         |  218 ++++++++++++++++++++++++++-----------------
 include/linux/cfq-iosched.h |   32 ++++---
 2 files changed, 151 insertions(+), 99 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 024d392..b726e85 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -144,9 +144,10 @@ CFQ_CFQQ_FNS(sync);
 #undef CFQ_CFQQ_FNS
 
 #define cfq_log_cfqq(cfqd, cfqq, fmt, args...)	\
-	blk_add_trace_msg((cfqd)->queue, "cfq%d " fmt, (cfqq)->pid, ##args)
+	blk_add_trace_msg((cfqd)->cfqdd->queue,	\
+			  "cfq%d " fmt, (cfqq)->pid, ##args)
 #define cfq_log(cfqd, fmt, args...)	\
-	blk_add_trace_msg((cfqd)->queue, "cfq " fmt, ##args)
+	blk_add_trace_msg((cfqd)->cfqdd->queue, "cfq " fmt, ##args)
 
 static void cfq_dispatch_insert(struct request_queue *, struct request *);
 static struct cfq_queue *cfq_get_queue(struct cfq_data *, int,
@@ -184,9 +185,11 @@ static inline int cfq_bio_sync(struct bio *bio)
  */
 static inline void cfq_schedule_dispatch(struct cfq_data *cfqd)
 {
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	if (cfqd->busy_queues) {
 		cfq_log(cfqd, "schedule dispatch");
-		kblockd_schedule_work(cfqd->queue, &cfqd->unplug_work);
+		kblockd_schedule_work(cfqdd->queue,
+				      &cfqdd->unplug_work);
 	}
 }
 
@@ -271,7 +274,7 @@ cfq_choose_req(struct cfq_data *cfqd, struct request *rq1, struct request *rq2)
 	s1 = rq1->sector;
 	s2 = rq2->sector;
 
-	last = cfqd->last_position;
+	last = cfqd->cfqdd->last_position;
 
 	/*
 	 * by definition, 1KiB is 2 sectors
@@ -548,7 +551,7 @@ static void cfq_add_rq_rb(struct request *rq)
 	 * if that happens, put the alias on the dispatch list
 	 */
 	while ((__alias = elv_rb_add(&cfqq->sort_list, rq)) != NULL)
-		cfq_dispatch_insert(cfqd->queue, __alias);
+		cfq_dispatch_insert(cfqd->cfqdd->queue, __alias);
 
 	if (!cfq_cfqq_on_rr(cfqq))
 		cfq_add_cfqq_rr(cfqd, cfqq);
@@ -591,22 +594,24 @@ cfq_find_rq_fmerge(struct cfq_data *cfqd, struct bio *bio)
 static void cfq_activate_request(struct request_queue *q, struct request *rq)
 {
 	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 
-	cfqd->rq_in_driver++;
+	cfqdd->rq_in_driver++;
 	cfq_log_cfqq(cfqd, RQ_CFQQ(rq), "activate rq, drv=%d",
-						cfqd->rq_in_driver);
+						cfqdd->rq_in_driver);
 
-	cfqd->last_position = rq->hard_sector + rq->hard_nr_sectors;
+	cfqdd->last_position = rq->hard_sector + rq->hard_nr_sectors;
 }
 
 static void cfq_deactivate_request(struct request_queue *q, struct request *rq)
 {
 	struct cfq_data *cfqd = q->elevator->elevator_data;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 
-	WARN_ON(!cfqd->rq_in_driver);
-	cfqd->rq_in_driver--;
+	WARN_ON(!cfqdd->rq_in_driver);
+	cfqdd->rq_in_driver--;
 	cfq_log_cfqq(cfqd, RQ_CFQQ(rq), "deactivate rq, drv=%d",
-						cfqd->rq_in_driver);
+						cfqdd->rq_in_driver);
 }
 
 static void cfq_remove_request(struct request *rq)
@@ -619,7 +624,7 @@ static void cfq_remove_request(struct request *rq)
 	list_del_init(&rq->queuelist);
 	cfq_del_rq_rb(rq);
 
-	cfqq->cfqd->rq_queued--;
+	cfqq->cfqd->cfqdd->rq_queued--;
 	if (rq_is_meta(rq)) {
 		WARN_ON(!cfqq->meta_pending);
 		cfqq->meta_pending--;
@@ -715,10 +720,12 @@ static void
 __cfq_slice_expired(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		    int timed_out)
 {
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+
 	cfq_log_cfqq(cfqd, cfqq, "slice expired t=%d", timed_out);
 
 	if (cfq_cfqq_wait_request(cfqq))
-		del_timer(&cfqd->idle_slice_timer);
+		del_timer(&cfqdd->idle_slice_timer);
 
 	cfq_clear_cfqq_must_dispatch(cfqq);
 	cfq_clear_cfqq_wait_request(cfqq);
@@ -736,9 +743,9 @@ __cfq_slice_expired(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	if (cfqq == cfqd->active_queue)
 		cfqd->active_queue = NULL;
 
-	if (cfqd->active_cic) {
-		put_io_context(cfqd->active_cic->ioc);
-		cfqd->active_cic = NULL;
+	if (cfqdd->active_cic) {
+		put_io_context(cfqdd->active_cic->ioc);
+		cfqdd->active_cic = NULL;
 	}
 }
 
@@ -777,15 +784,17 @@ static struct cfq_queue *cfq_set_active_queue(struct cfq_data *cfqd)
 static inline sector_t cfq_dist_from_last(struct cfq_data *cfqd,
 					  struct request *rq)
 {
-	if (rq->sector >= cfqd->last_position)
-		return rq->sector - cfqd->last_position;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+
+	if (rq->sector >= cfqdd->last_position)
+		return rq->sector - cfqdd->last_position;
 	else
-		return cfqd->last_position - rq->sector;
+		return cfqdd->last_position - rq->sector;
 }
 
 static inline int cfq_rq_close(struct cfq_data *cfqd, struct request *rq)
 {
-	struct cfq_io_context *cic = cfqd->active_cic;
+	struct cfq_io_context *cic = cfqd->cfqdd->active_cic;
 
 	if (!sample_valid(cic->seek_samples))
 		return 0;
@@ -809,6 +818,7 @@ static int cfq_close_cooperator(struct cfq_data *cfq_data,
 static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 {
 	struct cfq_queue *cfqq = cfqd->active_queue;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	struct cfq_io_context *cic;
 	unsigned long sl;
 
@@ -817,7 +827,7 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 	 * for devices that support queuing, otherwise we still have a problem
 	 * with sync vs async workloads.
 	 */
-	if (blk_queue_nonrot(cfqd->queue) && cfqd->hw_tag)
+	if (blk_queue_nonrot(cfqdd->queue) && cfqdd->hw_tag)
 		return;
 
 	WARN_ON(!RB_EMPTY_ROOT(&cfqq->sort_list));
@@ -832,13 +842,13 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 	/*
 	 * still requests with the driver, don't idle
 	 */
-	if (cfqd->rq_in_driver)
+	if (cfqdd->rq_in_driver)
 		return;
 
 	/*
 	 * task has exited, don't wait
 	 */
-	cic = cfqd->active_cic;
+	cic = cfqdd->active_cic;
 	if (!cic || !atomic_read(&cic->ioc->nr_tasks))
 		return;
 
@@ -861,7 +871,7 @@ static void cfq_arm_slice_timer(struct cfq_data *cfqd)
 	if (sample_valid(cic->seek_samples) && CIC_SEEKY(cic))
 		sl = min(sl, msecs_to_jiffies(CFQ_MIN_TT));
 
-	mod_timer(&cfqd->idle_slice_timer, jiffies + sl);
+	mod_timer(&cfqdd->idle_slice_timer, jiffies + sl);
 	cfq_log(cfqd, "arm_idle: %lu", sl);
 }
 
@@ -880,7 +890,7 @@ static void cfq_dispatch_insert(struct request_queue *q, struct request *rq)
 	elv_dispatch_sort(q, rq);
 
 	if (cfq_cfqq_sync(cfqq))
-		cfqd->sync_flight++;
+		cfqd->cfqdd->sync_flight++;
 }
 
 /*
@@ -950,7 +960,7 @@ static struct cfq_queue *cfq_select_queue(struct cfq_data *cfqd)
 	 * flight or is idling for a new request, allow either of these
 	 * conditions to happen (or time out) before selecting a new queue.
 	 */
-	if (timer_pending(&cfqd->idle_slice_timer) ||
+	if (timer_pending(&cfqd->cfqdd->idle_slice_timer) ||
 	    (cfqq->dispatched && cfq_cfqq_idle_window(cfqq))) {
 		cfqq = NULL;
 		goto keep_queue;
@@ -972,6 +982,7 @@ static int
 __cfq_dispatch_requests(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 			int max_dispatch)
 {
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	int dispatched = 0;
 
 	BUG_ON(RB_EMPTY_ROOT(&cfqq->sort_list));
@@ -989,13 +1000,13 @@ __cfq_dispatch_requests(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		/*
 		 * finally, insert request into driver dispatch list
 		 */
-		cfq_dispatch_insert(cfqd->queue, rq);
+		cfq_dispatch_insert(cfqdd->queue, rq);
 
 		dispatched++;
 
-		if (!cfqd->active_cic) {
+		if (!cfqdd->active_cic) {
 			atomic_inc(&RQ_CIC(rq)->ioc->refcount);
-			cfqd->active_cic = RQ_CIC(rq);
+			cfqdd->active_cic = RQ_CIC(rq);
 		}
 
 		if (RB_EMPTY_ROOT(&cfqq->sort_list))
@@ -1022,7 +1033,7 @@ static int __cfq_forced_dispatch_cfqq(struct cfq_queue *cfqq)
 	int dispatched = 0;
 
 	while (cfqq->next_rq) {
-		cfq_dispatch_insert(cfqq->cfqd->queue, cfqq->next_rq);
+		cfq_dispatch_insert(cfqq->cfqd->cfqdd->queue, cfqq->next_rq);
 		dispatched++;
 	}
 
@@ -1054,6 +1065,7 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 {
 	struct cfq_data *cfqd = q->elevator->elevator_data;
 	struct cfq_queue *cfqq;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	int dispatched;
 
 	if (!cfqd->busy_queues)
@@ -1077,12 +1089,12 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 				break;
 		}
 
-		if (cfqd->sync_flight && !cfq_cfqq_sync(cfqq))
+		if (cfqdd->sync_flight && !cfq_cfqq_sync(cfqq))
 			break;
 
 		cfq_clear_cfqq_must_dispatch(cfqq);
 		cfq_clear_cfqq_wait_request(cfqq);
-		del_timer(&cfqd->idle_slice_timer);
+		del_timer(&cfqdd->idle_slice_timer);
 
 		dispatched += __cfq_dispatch_requests(cfqd, cfqq, max_dispatch);
 	}
@@ -1248,7 +1260,7 @@ static void cfq_exit_single_io_context(struct io_context *ioc,
 	struct cfq_data *cfqd = cic->key;
 
 	if (cfqd) {
-		struct request_queue *q = cfqd->queue;
+		struct request_queue *q = cfqd->cfqdd->queue;
 		unsigned long flags;
 
 		spin_lock_irqsave(q->queue_lock, flags);
@@ -1272,7 +1284,7 @@ cfq_alloc_io_context(struct cfq_data *cfqd, gfp_t gfp_mask)
 	struct cfq_io_context *cic;
 
 	cic = kmem_cache_alloc_node(cfq_ioc_pool, gfp_mask | __GFP_ZERO,
-							cfqd->queue->node);
+						cfqd->cfqdd->queue->node);
 	if (cic) {
 		cic->last_end_request = jiffies;
 		INIT_LIST_HEAD(&cic->queue_list);
@@ -1332,12 +1344,13 @@ static void changed_ioprio(struct io_context *ioc, struct cfq_io_context *cic)
 {
 	struct cfq_data *cfqd = cic->key;
 	struct cfq_queue *cfqq;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	unsigned long flags;
 
 	if (unlikely(!cfqd))
 		return;
 
-	spin_lock_irqsave(cfqd->queue->queue_lock, flags);
+	spin_lock_irqsave(cfqdd->queue->queue_lock, flags);
 
 	cfqq = cic->cfqq[ASYNC];
 	if (cfqq) {
@@ -1353,7 +1366,7 @@ static void changed_ioprio(struct io_context *ioc, struct cfq_io_context *cic)
 	if (cfqq)
 		cfq_mark_cfqq_prio_changed(cfqq);
 
-	spin_unlock_irqrestore(cfqd->queue->queue_lock, flags);
+	spin_unlock_irqrestore(cfqdd->queue->queue_lock, flags);
 }
 
 static void cfq_ioc_set_ioprio(struct io_context *ioc)
@@ -1367,6 +1380,7 @@ cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
 		     struct io_context *ioc, gfp_t gfp_mask)
 {
 	struct cfq_queue *cfqq, *new_cfqq = NULL;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	struct cfq_io_context *cic;
 
 retry:
@@ -1385,16 +1399,16 @@ retry:
 			 * the allocator to do whatever it needs to attempt to
 			 * free memory.
 			 */
-			spin_unlock_irq(cfqd->queue->queue_lock);
+			spin_unlock_irq(cfqdd->queue->queue_lock);
 			new_cfqq = kmem_cache_alloc_node(cfq_pool,
 					gfp_mask | __GFP_NOFAIL | __GFP_ZERO,
-					cfqd->queue->node);
-			spin_lock_irq(cfqd->queue->queue_lock);
+					cfqdd->queue->node);
+			spin_lock_irq(cfqdd->queue->queue_lock);
 			goto retry;
 		} else {
 			cfqq = kmem_cache_alloc_node(cfq_pool,
 					gfp_mask | __GFP_ZERO,
-					cfqd->queue->node);
+					cfqdd->queue->node);
 			if (!cfqq)
 				goto out;
 		}
@@ -1547,9 +1561,11 @@ cfq_cic_lookup(struct cfq_data *cfqd, struct io_context *ioc)
 static int cfq_cic_link(struct cfq_data *cfqd, struct io_context *ioc,
 			struct cfq_io_context *cic, gfp_t gfp_mask)
 {
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	unsigned long flags;
 	int ret;
 
+
 	ret = radix_tree_preload(gfp_mask);
 	if (!ret) {
 		cic->ioc = ioc;
@@ -1565,9 +1581,11 @@ static int cfq_cic_link(struct cfq_data *cfqd, struct io_context *ioc,
 		radix_tree_preload_end();
 
 		if (!ret) {
-			spin_lock_irqsave(cfqd->queue->queue_lock, flags);
+			spin_lock_irqsave(cfqdd->queue->queue_lock,
+						flags);
 			list_add(&cic->queue_list, &cfqd->cic_list);
-			spin_unlock_irqrestore(cfqd->queue->queue_lock, flags);
+			spin_unlock_irqrestore(cfqdd->queue->queue_lock,
+						flags);
 		}
 	}
 
@@ -1590,7 +1608,7 @@ cfq_get_io_context(struct cfq_data *cfqd, gfp_t gfp_mask)
 
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
-	ioc = get_io_context(gfp_mask, cfqd->queue->node);
+	ioc = get_io_context(gfp_mask, cfqd->cfqdd->queue->node);
 	if (!ioc)
 		return NULL;
 
@@ -1676,7 +1694,7 @@ cfq_update_idle_window(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	enable_idle = old_idle = cfq_cfqq_idle_window(cfqq);
 
 	if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
-	    (cfqd->hw_tag && CIC_SEEKY(cic)))
+	    (cfqd->cfqdd->hw_tag && CIC_SEEKY(cic)))
 		enable_idle = 0;
 	else if (sample_valid(cic->ttime_samples)) {
 		if (cic->ttime_mean > cfqd->cfq_slice_idle)
@@ -1731,7 +1749,7 @@ cfq_should_preempt(struct cfq_data *cfqd, struct cfq_queue *new_cfqq,
 	if (rq_is_meta(rq) && !cfqq->meta_pending)
 		return 1;
 
-	if (!cfqd->active_cic || !cfq_cfqq_wait_request(cfqq))
+	if (!cfqd->cfqdd->active_cic || !cfq_cfqq_wait_request(cfqq))
 		return 0;
 
 	/*
@@ -1774,8 +1792,9 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		struct request *rq)
 {
 	struct cfq_io_context *cic = RQ_CIC(rq);
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 
-	cfqd->rq_queued++;
+	cfqdd->rq_queued++;
 	if (rq_is_meta(rq))
 		cfqq->meta_pending++;
 
@@ -1793,8 +1812,8 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		 */
 		if (cfq_cfqq_wait_request(cfqq)) {
 			cfq_mark_cfqq_must_dispatch(cfqq);
-			del_timer(&cfqd->idle_slice_timer);
-			blk_start_queueing(cfqd->queue);
+			del_timer(&cfqdd->idle_slice_timer);
+			blk_start_queueing(cfqdd->queue);
 		}
 	} else if (cfq_should_preempt(cfqd, cfqq, rq)) {
 		/*
@@ -1804,7 +1823,7 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		 */
 		cfq_preempt_queue(cfqd, cfqq);
 		cfq_mark_cfqq_must_dispatch(cfqq);
-		blk_start_queueing(cfqd->queue);
+		blk_start_queueing(cfqdd->queue);
 	}
 }
 
@@ -1827,49 +1846,50 @@ static void cfq_insert_request(struct request_queue *q, struct request *rq)
  * Update hw_tag based on peak queue depth over 50 samples under
  * sufficient load.
  */
-static void cfq_update_hw_tag(struct cfq_data *cfqd)
+static void cfq_update_hw_tag(struct cfq_driver_data *cfqdd)
 {
-	if (cfqd->rq_in_driver > cfqd->rq_in_driver_peak)
-		cfqd->rq_in_driver_peak = cfqd->rq_in_driver;
+	if (cfqdd->rq_in_driver > cfqdd->rq_in_driver_peak)
+		cfqdd->rq_in_driver_peak = cfqdd->rq_in_driver;
 
-	if (cfqd->rq_queued <= CFQ_HW_QUEUE_MIN &&
-	    cfqd->rq_in_driver <= CFQ_HW_QUEUE_MIN)
+	if (cfqdd->rq_queued <= CFQ_HW_QUEUE_MIN &&
+	    cfqdd->rq_in_driver <= CFQ_HW_QUEUE_MIN)
 		return;
 
-	if (cfqd->hw_tag_samples++ < 50)
+	if (cfqdd->hw_tag_samples++ < 50)
 		return;
 
-	if (cfqd->rq_in_driver_peak >= CFQ_HW_QUEUE_MIN)
-		cfqd->hw_tag = 1;
+	if (cfqdd->rq_in_driver_peak >= CFQ_HW_QUEUE_MIN)
+		cfqdd->hw_tag = 1;
 	else
-		cfqd->hw_tag = 0;
+		cfqdd->hw_tag = 0;
 
-	cfqd->hw_tag_samples = 0;
-	cfqd->rq_in_driver_peak = 0;
+	cfqdd->hw_tag_samples = 0;
+	cfqdd->rq_in_driver_peak = 0;
 }
 
 static void cfq_completed_request(struct request_queue *q, struct request *rq)
 {
 	struct cfq_queue *cfqq = RQ_CFQQ(rq);
 	struct cfq_data *cfqd = cfqq->cfqd;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	const int sync = rq_is_sync(rq);
 	unsigned long now;
 
 	now = jiffies;
 	cfq_log_cfqq(cfqd, cfqq, "complete");
 
-	cfq_update_hw_tag(cfqd);
+	cfq_update_hw_tag(cfqdd);
 
-	WARN_ON(!cfqd->rq_in_driver);
+	WARN_ON(!cfqdd->rq_in_driver);
 	WARN_ON(!cfqq->dispatched);
-	cfqd->rq_in_driver--;
+	cfqdd->rq_in_driver--;
 	cfqq->dispatched--;
 
 	if (cfq_cfqq_sync(cfqq))
-		cfqd->sync_flight--;
+		cfqdd->sync_flight--;
 
 	if (!cfq_class_idle(cfqq))
-		cfqd->last_end_request = now;
+		cfqdd->last_end_request = now;
 
 	if (sync)
 		RQ_CIC(rq)->last_end_request = now;
@@ -1889,7 +1909,7 @@ static void cfq_completed_request(struct request_queue *q, struct request *rq)
 			cfq_arm_slice_timer(cfqd);
 	}
 
-	if (!cfqd->rq_in_driver)
+	if (!cfqdd->rq_in_driver)
 		cfq_schedule_dispatch(cfqd);
 }
 
@@ -2034,9 +2054,9 @@ queue_fail:
 
 static void cfq_kick_queue(struct work_struct *work)
 {
-	struct cfq_data *cfqd =
-		container_of(work, struct cfq_data, unplug_work);
-	struct request_queue *q = cfqd->queue;
+	struct cfq_driver_data *cfqdd =
+		container_of(work, struct cfq_driver_data, unplug_work);
+	struct request_queue *q = cfqdd->queue;
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
@@ -2051,12 +2071,13 @@ static void cfq_idle_slice_timer(unsigned long data)
 {
 	struct cfq_data *cfqd = (struct cfq_data *) data;
 	struct cfq_queue *cfqq;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
 	unsigned long flags;
 	int timed_out = 1;
 
 	cfq_log(cfqd, "idle timer fired");
 
-	spin_lock_irqsave(cfqd->queue->queue_lock, flags);
+	spin_lock_irqsave(cfqdd->queue->queue_lock, flags);
 
 	cfqq = cfqd->active_queue;
 	if (cfqq) {
@@ -2088,13 +2109,13 @@ expire:
 out_kick:
 	cfq_schedule_dispatch(cfqd);
 out_cont:
-	spin_unlock_irqrestore(cfqd->queue->queue_lock, flags);
+	spin_unlock_irqrestore(cfqdd->queue->queue_lock, flags);
 }
 
-static void cfq_shutdown_timer_wq(struct cfq_data *cfqd)
+static void cfq_shutdown_timer_wq(struct cfq_driver_data *cfqdd)
 {
-	del_timer_sync(&cfqd->idle_slice_timer);
-	kblockd_flush_work(&cfqd->unplug_work);
+	del_timer_sync(&cfqdd->idle_slice_timer);
+	kblockd_flush_work(&cfqdd->unplug_work);
 }
 
 static void cfq_put_async_queues(struct cfq_data *cfqd)
@@ -2115,9 +2136,10 @@ static void cfq_put_async_queues(struct cfq_data *cfqd)
 static void cfq_exit_queue(elevator_t *e)
 {
 	struct cfq_data *cfqd = e->elevator_data;
-	struct request_queue *q = cfqd->queue;
+	struct cfq_driver_data *cfqdd = cfqd->cfqdd;
+	struct request_queue *q = cfqdd->queue;
 
-	cfq_shutdown_timer_wq(cfqd);
+	cfq_shutdown_timer_wq(cfqdd);
 
 	spin_lock_irq(q->queue_lock);
 
@@ -2136,11 +2158,37 @@ static void cfq_exit_queue(elevator_t *e)
 
 	spin_unlock_irq(q->queue_lock);
 
-	cfq_shutdown_timer_wq(cfqd);
+	cfq_shutdown_timer_wq(cfqdd);
 
+	kfree(cfqdd);
 	kfree(cfqd);
 }
 
+static struct cfq_driver_data *
+cfq_init_driver_data(struct request_queue *q, struct cfq_data *cfqd)
+{
+	struct cfq_driver_data *cfqdd;
+
+	cfqdd = kmalloc_node(sizeof(*cfqdd),
+				   GFP_KERNEL | __GFP_ZERO, q->node);
+	if (!cfqdd)
+		return NULL;
+
+	cfqdd->queue = q;
+
+	init_timer(&cfqdd->idle_slice_timer);
+	cfqdd->idle_slice_timer.function = cfq_idle_slice_timer;
+	cfqdd->idle_slice_timer.data = (unsigned long) cfqd;
+
+	INIT_WORK(&cfqdd->unplug_work, cfq_kick_queue);
+
+	cfqdd->last_end_request = jiffies;
+
+	cfqdd->hw_tag = 1;
+
+	return cfqdd;
+}
+
 static void *cfq_init_queue(struct request_queue *q)
 {
 	struct cfq_data *cfqd;
@@ -2149,18 +2197,15 @@ static void *cfq_init_queue(struct request_queue *q)
 	if (!cfqd)
 		return NULL;
 
+	cfqd->cfqdd = cfq_init_driver_data(q, cfqd);
+	if (!cfqd->cfqdd) {
+		kfree(cfqd);
+		return NULL;
+	}
+
 	cfqd->service_tree = CFQ_RB_ROOT;
 	INIT_LIST_HEAD(&cfqd->cic_list);
 
-	cfqd->queue = q;
-
-	init_timer(&cfqd->idle_slice_timer);
-	cfqd->idle_slice_timer.function = cfq_idle_slice_timer;
-	cfqd->idle_slice_timer.data = (unsigned long) cfqd;
-
-	INIT_WORK(&cfqd->unplug_work, cfq_kick_queue);
-
-	cfqd->last_end_request = jiffies;
 	cfqd->cfq_quantum = cfq_quantum;
 	cfqd->cfq_fifo_expire[0] = cfq_fifo_expire[0];
 	cfqd->cfq_fifo_expire[1] = cfq_fifo_expire[1];
@@ -2170,7 +2215,6 @@ static void *cfq_init_queue(struct request_queue *q)
 	cfqd->cfq_slice[1] = cfq_slice_sync;
 	cfqd->cfq_slice_async_rq = cfq_slice_async_rq;
 	cfqd->cfq_slice_idle = cfq_slice_idle;
-	cfqd->hw_tag = 1;
 
 	return cfqd;
 }
diff --git a/include/linux/cfq-iosched.h b/include/linux/cfq-iosched.h
index adb2410..50003f7 100644
--- a/include/linux/cfq-iosched.h
+++ b/include/linux/cfq-iosched.h
@@ -20,17 +20,11 @@ struct cfq_rb_root {
 #define CFQ_RB_ROOT	(struct cfq_rb_root) { RB_ROOT, NULL, }
 
 /*
- * Per block device queue structure
+ * Driver unique data structure
  */
-struct cfq_data {
+struct cfq_driver_data {
 	struct request_queue *queue;
 
-	/*
-	 * rr list of queues with requests and the count of them
-	 */
-	struct cfq_rb_root service_tree;
-	unsigned int busy_queues;
-
 	int rq_in_driver;
 	int sync_flight;
 
@@ -48,18 +42,30 @@ struct cfq_data {
 	struct timer_list idle_slice_timer;
 	struct work_struct unplug_work;
 
-	struct cfq_queue *active_queue;
 	struct cfq_io_context *active_cic;
 
+	sector_t last_position;
+	unsigned long last_end_request;
+};
+
+/*
+ * Per block device queue structure
+ */
+struct cfq_data {
+	/*
+	 * rr list of queues with requests and the count of them
+	 */
+	struct cfq_rb_root service_tree;
+	unsigned int busy_queues;
+
+	struct cfq_queue *active_queue;
+
 	/*
 	 * async queue for each priority case
 	 */
 	struct cfq_queue *async_cfqq[2][IOPRIO_BE_NR];
 	struct cfq_queue *async_idle_cfqq;
 
-	sector_t last_position;
-	unsigned long last_end_request;
-
 	/*
 	 * tunables, see top of file
 	 */
@@ -72,6 +78,8 @@ struct cfq_data {
 	unsigned int cfq_slice_idle;
 
 	struct list_head cic_list;
+
+	struct cfq_driver_data *cfqdd;
 };
 
 #endif  /* _LINUX_CFQ_IOSCHED_H */
-- 
1.5.6.5
