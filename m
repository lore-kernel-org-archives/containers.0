From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 09/12] block,
	bfq: reduce latency during request-pool saturation
Date: Thu, 29 May 2014 11:05:40 +0200
Message-ID: <1401354343-5527-10-git-send-email-paolo.valente__39484.4825765633$1401354480$gmane$org@unimore.it>
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

This patch introduces an heuristic that reduces latency when the
I/O-request pool is saturated. This goal is achieved by disabling
device idling, for non-weight-raised queues, when there are weight-
raised queues with pending or in-flight requests. In fact, as
explained in more detail in the comment to the function
bfq_bfqq_must_not_expire(), this reduces the rate at which processes
associated with non-weight-raised queues grab requests from the pool,
thereby increasing the probability that processes associated with
weight-raised queues get a request immediately (or at least soon) when
they need one.

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-iosched.c | 67 +++++++++++++++++++++++++++++++++++++++++++----------
 block/bfq-sched.c   |  6 +++++
 block/bfq.h         |  2 ++
 3 files changed, 63 insertions(+), 12 deletions(-)

diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 0b24130..5988c70 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -511,6 +511,7 @@ add_bfqq_busy:
 			bfqq->wr_coeff = bfqd->bfq_wr_coeff;
 			bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
 
+			bfqd->wr_busy_queues++;
 			entity->ioprio_changed = 1;
 			bfq_log_bfqq(bfqd, bfqq,
 			    "non-idle wrais starting at %lu, rais_max_time %u",
@@ -655,6 +656,8 @@ static void bfq_merged_requests(struct request_queue *q, struct request *rq,
 /* Must be called with bfqq != NULL */
 static inline void bfq_bfqq_end_wr(struct bfq_queue *bfqq)
 {
+	if (bfq_bfqq_busy(bfqq))
+		bfqq->bfqd->wr_busy_queues--;
 	bfqq->wr_coeff = 1;
 	bfqq->wr_cur_max_time = 0;
 	/* Trigger a weight change on the next activation of the queue */
@@ -1401,22 +1404,61 @@ static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
 /*
  * Device idling is allowed only for the queues for which this function
  * returns true. For this reason, the return value of this function plays a
- * critical role for both throughput boosting and service guarantees.
+ * critical role for both throughput boosting and service guarantees. The
+ * return value is computed through a logical expression. In this rather
+ * long comment, we try to briefly describe all the details and motivations
+ * behind the components of this logical expression.
  *
- * The return value is computed through a logical expression, which may
- * be true only if bfqq is sync and at least one of the following two
- * conditions holds:
- * - the queue has a non-null idle window;
- * - the queue is being weight-raised.
- * In fact, waiting for a new request for the queue, in the first case,
- * is likely to boost the disk throughput, whereas, in the second case,
- * is necessary to preserve fairness and latency guarantees
- * (see [1] for details).
+ * First, the expression may be true only for sync queues. Besides, if
+ * bfqq is also being weight-raised, then the expression always evaluates
+ * to true, as device idling is instrumental for preserving low-latency
+ * guarantees (see [1]). Otherwise, the expression evaluates to true only
+ * if bfqq has a non-null idle window and at least one of the following
+ * two conditions holds. The first condition is that the device is not
+ * performing NCQ, because idling the device most certainly boosts the
+ * throughput if this condition holds and bfqq has been granted a non-null
+ * idle window.
+ *
+ * The second condition is that there is no weight-raised busy queue,
+ * which guarantees that the device is not idled for a sync non-weight-
+ * raised queue when there are busy weight-raised queues. The former is
+ * then expired immediately if empty. Combined with the timestamping rules
+ * of BFQ (see [1] for details), this causes sync non-weight-raised queues
+ * to get a lower number of requests served, and hence to ask for a lower
+ * number of requests from the request pool, before the busy weight-raised
+ * queues get served again.
+ *
+ * This is beneficial for the processes associated with weight-raised
+ * queues, when the request pool is saturated (e.g., in the presence of
+ * write hogs). In fact, if the processes associated with the other queues
+ * ask for requests at a lower rate, then weight-raised processes have a
+ * higher probability to get a request from the pool immediately (or at
+ * least soon) when they need one. Hence they have a higher probability to
+ * actually get a fraction of the disk throughput proportional to their
+ * high weight. This is especially true with NCQ-capable drives, which
+ * enqueue several requests in advance and further reorder internally-
+ * queued requests.
+ *
+ * In the end, mistreating non-weight-raised queues when there are busy
+ * weight-raised queues seems to mitigate starvation problems in the
+ * presence of heavy write workloads and NCQ, and hence to guarantee a
+ * higher application and system responsiveness in these hostile scenarios.
  */
 static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
 {
-	return bfq_bfqq_sync(bfqq) &&
-	       (bfqq->wr_coeff > 1 || bfq_bfqq_idle_window(bfqq));
+	struct bfq_data *bfqd = bfqq->bfqd;
+/*
+ * Condition for expiring a non-weight-raised queue (and hence not idling
+ * the device).
+ */
+#define cond_for_expiring_non_wr  (bfqd->hw_tag && \
+				   bfqd->wr_busy_queues > 0)
+
+	return bfq_bfqq_sync(bfqq) && (
+		bfqq->wr_coeff > 1 ||
+		(bfq_bfqq_idle_window(bfqq) &&
+		 !cond_for_expiring_non_wr)
+	);
 }
 
 /*
@@ -2556,6 +2598,7 @@ static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 					      * high-definition compressed
 					      * video.
 					      */
+	bfqd->wr_busy_queues = 0;
 
 	/*
 	 * Begin by assuming, optimistically, that the device peak rate is
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
index f6491d5..73f453b 100644
--- a/block/bfq-sched.c
+++ b/block/bfq-sched.c
@@ -975,6 +975,9 @@ static void bfq_del_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 	bfqd->busy_queues--;
 
 	bfq_deactivate_bfqq(bfqd, bfqq, requeue);
+
+	if (bfqq->wr_coeff > 1)
+		bfqd->wr_busy_queues--;
 }
 
 /*
@@ -988,4 +991,7 @@ static void bfq_add_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq)
 
 	bfq_mark_bfqq_busy(bfqq);
 	bfqd->busy_queues++;
+
+	if (bfqq->wr_coeff > 1)
+		bfqd->wr_busy_queues++;
 }
diff --git a/block/bfq.h b/block/bfq.h
index 3b5763a7..7d6e4cb 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -280,6 +280,7 @@ enum bfq_device_speed {
  * @root_group: root bfq_group for the device.
  * @busy_queues: number of bfq_queues containing requests (including the
  *		 queue in service, even if it is idling).
+ * @wr_busy_queues: number of weight-raised busy @bfq_queues.
  * @queued: number of queued requests.
  * @rq_in_driver: number of requests dispatched and waiting for completion.
  * @sync_flight: number of sync requests in the driver.
@@ -345,6 +346,7 @@ struct bfq_data {
 	struct bfq_group *root_group;
 
 	int busy_queues;
+	int wr_busy_queues;
 	int queued;
 	int rq_in_driver;
 	int sync_flight;
-- 
1.9.2
