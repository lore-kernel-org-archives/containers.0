From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 12/12] block,
	bfq: boost the throughput with random I/O on NCQ-capable HDDs
Date: Thu, 29 May 2014 11:05:43 +0200
Message-ID: <1401354343-5527-13-git-send-email-paolo.valente__16128.1804823831$1401355775$gmane$org@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401354343-5527-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch is basically the counterpart of patch 13 for NCQ-capable
rotational devices. Exactly as patch 13 does on flash-based devices
and for any workload, this patch disables device idling on rotational
devices, but only for random I/O. More precisely, idling is disabled
only for constantly-seeky queues (see patch 7). In fact, only with
these queues disabling idling boosts the throughput on NCQ-capable
rotational devices.

To not break service guarantees, idling is disabled for NCQ-enabled
rotational devices and constantly-seeky queues only when the same
symmetry conditions as in patch 13, plus an additional one, hold. The
additional condition is related to the fact that this patch disables
idling only for constantly-seeky queues. In fact, should idling be
disabled for a constantly-seeky queue while some other
non-constantly-seeky queue has pending requests, the latter queue
would get more requests served, after being set as in service, than
the former. This differentiated treatment would cause a deviation with
respect to the desired throughput distribution (i.e., with respect to
the throughput distribution corresponding to the weights assigned to
processes and groups of processes).  For this reason, the additional
condition for disabling idling for a constantly-seeky queue is that
all queues with pending or in-flight requests are constantly seeky.

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-iosched.c | 79 +++++++++++++++++++++++++++++++++++++++++------------
 block/bfq-sched.c   | 21 +++++++++++---
 block/bfq.h         | 29 +++++++++++++++++++-
 3 files changed, 107 insertions(+), 22 deletions(-)

diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 49856e1..b9aafa5 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -1910,8 +1910,12 @@ static void bfq_bfqq_expire(struct bfq_data *bfqd,
 
 	bfqq->service_from_backlogged += bfqq->entity.service;
 
-	if (BFQQ_SEEKY(bfqq) && reason == BFQ_BFQQ_BUDGET_TIMEOUT)
+	if (BFQQ_SEEKY(bfqq) && reason == BFQ_BFQQ_BUDGET_TIMEOUT &&
+	    !bfq_bfqq_constantly_seeky(bfqq)) {
 		bfq_mark_bfqq_constantly_seeky(bfqq);
+		if (!blk_queue_nonrot(bfqd->queue))
+			bfqd->const_seeky_busy_in_flight_queues++;
+	}
 
 	if (bfqd->low_latency && bfqq->wr_coeff == 1)
 		bfqq->last_wr_start_finish = jiffies;
@@ -2071,7 +2075,8 @@ static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
  * Even in such a scenario, sequential I/O may still receive a preferential
  * treatment, but this is not likely to be a big issue with flash-based
  * devices, because of their non-dramatic loss of throughput with random
- * I/O.
+ * I/O. Things do differ with HDDs, for which additional care is taken, as
+ * explained after completing the discussion for flash-based devices.
  *
  * Unfortunately, keeping the necessary state for evaluating exactly the
  * above symmetry conditions would be quite complex and time-consuming.
@@ -2088,17 +2093,42 @@ static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
  * compound condition evaluates to true if any of the above symmetry
  * sub-condition does not hold, or the device is not flash-based. Therefore,
  * if also the first component is true, then idling is allowed for a sync
- * queue. In contrast, if all the required symmetry sub-conditions hold and
- * the device is flash-based, then the second component, and hence the
- * whole compound condition, evaluates to false, and no idling is performed.
- * This helps to keep the drives' internal queues full on NCQ-capable
- * devices, and hence to boost the throughput, without causing 'almost' any
- * loss of service guarantees. The 'almost' follows from the fact that, if
- * the internal queue of one such device is filled while all the
- * sub-conditions hold, but at some point in time some sub-condition stops
- * to hold, then it may become impossible to let requests be served in the
- * new desired order until all the requests already queued in the device
- * have been served.
+ * queue. These are the only sub-conditions considered if the device is
+ * flash-based, as, for such a device, it is sensible to force idling only
+ * for service-guarantee issues. In fact, as for throughput, idling
+ * NCQ-capable flash-based devices would not boost the throughput even
+ * with sequential I/O; rather it would lower the throughput in proportion
+ * to how fast the device is. In the end, (only) if all the three
+ * sub-conditions hold and the device is flash-based, the compound
+ * condition evaluates to false and therefore no idling is performed.
+ *
+ * As already said, things change with a rotational device, where idling
+ * boosts the throughput with sequential I/O (even with NCQ). Hence, for
+ * such a device the second component of the compound condition evaluates
+ * to true also if the following additional sub-condition does not hold:
+ * the queue is constantly seeky. Unfortunately, this different behavior
+ * with respect to flash-based devices causes an additional asymmetry: if
+ * some sync queues enjoy idling and some other sync queues do not, then
+ * the latter get a low share of the device throughput, simply because the
+ * former get many requests served after being set as in service, whereas
+ * the latter do not. As a consequence, to guarantee the desired throughput
+ * distribution, on HDDs the compound expression evaluates to true (and
+ * hence device idling is performed) also if the following last symmetry
+ * condition does not hold: no other queue is benefiting from idling. Also
+ * this last condition is actually replaced with a simpler-to-maintain and
+ * stronger condition: there is no busy queue which is not constantly seeky
+ * (and hence may also benefit from idling).
+ *
+ * To sum up, when all the required symmetry and throughput-boosting
+ * sub-conditions hold, the second component of the compound condition
+ * evaluates to false, and hence no idling is performed. This helps to
+ * keep the drives' internal queues full on NCQ-capable devices, and hence
+ * to boost the throughput, without causing 'almost' any loss of service
+ * guarantees. The 'almost' follows from the fact that, if the internal
+ * queue of one such device is filled while all the sub-conditions hold,
+ * but at some point in time some sub-condition stops to hold, then it may
+ * become impossible to let requests be served in the new desired order
+ * until all the requests already queued in the device have been served.
  */
 static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
 {
@@ -2109,6 +2139,9 @@ static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
 #else
 #define symmetric_scenario	  (!bfq_differentiated_weights(bfqd))
 #endif
+#define cond_for_seeky_on_ncq_hdd (bfq_bfqq_constantly_seeky(bfqq) && \
+				   bfqd->busy_in_flight_queues == \
+				   bfqd->const_seeky_busy_in_flight_queues)
 /*
  * Condition for expiring a non-weight-raised queue (and hence not idling
  * the device).
@@ -2116,7 +2149,8 @@ static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
 #define cond_for_expiring_non_wr  (bfqd->hw_tag && \
 				   (bfqd->wr_busy_queues > 0 || \
 				    (symmetric_scenario && \
-				     blk_queue_nonrot(bfqd->queue))))
+				     (blk_queue_nonrot(bfqd->queue) || \
+				      cond_for_seeky_on_ncq_hdd))))
 
 	return bfq_bfqq_sync(bfqq) && (
 		bfqq->wr_coeff > 1 ||
@@ -2843,8 +2877,11 @@ static void bfq_rq_enqueued(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 
 	bfq_update_io_thinktime(bfqd, bic);
 	bfq_update_io_seektime(bfqd, bfqq, rq);
-	if (!BFQQ_SEEKY(bfqq))
+	if (!BFQQ_SEEKY(bfqq) && bfq_bfqq_constantly_seeky(bfqq)) {
 		bfq_clear_bfqq_constantly_seeky(bfqq);
+		if (!blk_queue_nonrot(bfqd->queue))
+			bfqd->const_seeky_busy_in_flight_queues--;
+	}
 	if (bfqq->entity.service > bfq_max_budget(bfqd) / 8 ||
 	    !BFQQ_SEEKY(bfqq))
 		bfq_update_idle_window(bfqd, bfqq, bic);
@@ -2996,9 +3033,15 @@ static void bfq_completed_request(struct request_queue *q, struct request *rq)
 	bfqd->rq_in_driver--;
 	bfqq->dispatched--;
 
-	if (!bfqq->dispatched && !bfq_bfqq_busy(bfqq))
+	if (!bfqq->dispatched && !bfq_bfqq_busy(bfqq)) {
 		bfq_weights_tree_remove(bfqd, &bfqq->entity,
 					&bfqd->queue_weights_tree);
+		if (!blk_queue_nonrot(bfqd->queue)) {
+			bfqd->busy_in_flight_queues--;
+			if (bfq_bfqq_constantly_seeky(bfqq))
+				bfqd->const_seeky_busy_in_flight_queues--;
+		}
+	}
 
 	if (sync) {
 		bfqd->sync_flight--;
@@ -3420,6 +3463,8 @@ static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 					      * video.
 					      */
 	bfqd->wr_busy_queues = 0;
+	bfqd->busy_in_flight_queues = 0;
+	bfqd->const_seeky_busy_in_flight_queues = 0;
 
 	/*
 	 * Begin by assuming, optimistically, that the device peak rate is
@@ -3739,7 +3784,7 @@ static int __init bfq_init(void)
 	device_speed_thresh[1] = (R_fast[1] + R_slow[1]) / 2;
 
 	elv_register(&iosched_bfq);
-	pr_info("BFQ I/O-scheduler version: v6");
+	pr_info("BFQ I/O-scheduler version: v7r4");
 
 	return 0;
 }
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
index 473b36a..afc4c23 100644
--- a/block/bfq-sched.c
+++ b/block/bfq-sched.c
@@ -1064,9 +1064,15 @@ static void bfq_del_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 
 	bfq_deactivate_bfqq(bfqd, bfqq, requeue);
 
-	if (!bfqq->dispatched)
+	if (!bfqq->dispatched) {
 		bfq_weights_tree_remove(bfqd, &bfqq->entity,
 					&bfqd->queue_weights_tree);
+		if (!blk_queue_nonrot(bfqd->queue)) {
+			bfqd->busy_in_flight_queues--;
+			if (bfq_bfqq_constantly_seeky(bfqq))
+				bfqd->const_seeky_busy_in_flight_queues--;
+		}
+	}
 	if (bfqq->wr_coeff > 1)
 		bfqd->wr_busy_queues--;
 }
@@ -1083,9 +1089,16 @@ static void bfq_add_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq)
 	bfq_mark_bfqq_busy(bfqq);
 	bfqd->busy_queues++;
 
-	if (!bfqq->dispatched && bfqq->wr_coeff == 1)
-		bfq_weights_tree_add(bfqd, &bfqq->entity,
-				     &bfqd->queue_weights_tree);
+	if (!bfqq->dispatched) {
+		if (bfqq->wr_coeff == 1)
+			bfq_weights_tree_add(bfqd, &bfqq->entity,
+					     &bfqd->queue_weights_tree);
+		if (!blk_queue_nonrot(bfqd->queue)) {
+			bfqd->busy_in_flight_queues++;
+			if (bfq_bfqq_constantly_seeky(bfqq))
+				bfqd->const_seeky_busy_in_flight_queues++;
+		}
+	}
 	if (bfqq->wr_coeff > 1)
 		bfqd->wr_busy_queues++;
 }
diff --git a/block/bfq.h b/block/bfq.h
index 83c828d..f4c702c 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -1,5 +1,5 @@
 /*
- * BFQ-v6 for 3.15.0: data structures and common functions prototypes.
+ * BFQ-v7r4 for 3.15.0: data structures and common functions prototypes.
  *
  * Based on ideas and code from CFQ:
  * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
@@ -340,6 +340,31 @@ enum bfq_device_speed {
  *                     details).
  * @busy_queues: number of bfq_queues containing requests (including the
  *		 queue in service, even if it is idling).
+ * @busy_in_flight_queues: number of @bfq_queues containing pending or
+ *                         in-flight requests, plus the @bfq_queue in
+ *                         service, even if idle but waiting for the
+ *                         possible arrival of its next sync request. This
+ *                         field is updated only if the device is rotational,
+ *                         but used only if the device is also NCQ-capable.
+ *                         The reason why the field is updated also for non-
+ *                         NCQ-capable rotational devices is related to the
+ *                         fact that the value of @hw_tag may be set also
+ *                         later than when busy_in_flight_queues may need to
+ *                         be incremented for the first time(s). Taking also
+ *                         this possibility into account, to avoid unbalanced
+ *                         increments/decrements, would imply more overhead
+ *                         than just updating busy_in_flight_queues
+ *                         regardless of the value of @hw_tag.
+ * @const_seeky_busy_in_flight_queues: number of constantly-seeky @bfq_queues
+ *                                     (that is, seeky queues that expired
+ *                                     for budget timeout at least once)
+ *                                     containing pending or in-flight
+ *                                     requests, including the in-service
+ *                                     @bfq_queue if constantly seeky. This
+ *                                     field is updated only if the device
+ *                                     is rotational, but used only if the
+ *                                     device is also NCQ-capable (see the
+ *                                     comments to @busy_in_flight_queues).
  * @wr_busy_queues: number of weight-raised busy @bfq_queues.
  * @queued: number of queued requests.
  * @rq_in_driver: number of requests dispatched and waiting for completion.
@@ -414,6 +439,8 @@ struct bfq_data {
 	struct rb_root group_weights_tree;
 
 	int busy_queues;
+	int busy_in_flight_queues;
+	int const_seeky_busy_in_flight_queues;
 	int wr_busy_queues;
 	int queued;
 	int rq_in_driver;
-- 
1.9.2
