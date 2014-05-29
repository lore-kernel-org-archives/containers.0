From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 06/12] block, bfq: improve responsiveness
Date: Thu, 29 May 2014 11:05:37 +0200
Message-ID: <1401354343-5527-7-git-send-email-paolo.valente__34335.7845246375$1401354469$gmane$org@unimore.it>
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

This patch introduces a simple heuristic to load applications quickly,
and to perform the I/O requested by interactive applications just as
quickly. To this purpose, both a newly-created queue and a queue
associated with an interactive application (we explain in a moment how
BFQ decides whether the associated application is interactive),
receive the following three special treatments:

1) The weight of the queue is raised.

2) The queue unconditionally enjoys device idling when it empties; in
fact, if the requests of a queue are sync, then performing device
idling for the queue is a necessary condition to guarantee that the
queue receives a fraction of the throughput proportional to its weight
(see [1] for details).

3) The device-idling timeout is larger for the queue. This reduces the
probability that the queue is expired because its next request does
not arrive in time.

For brevity, we call just weight-raising the combination of these
three preferential treatments. For a newly-created queue,
weight-raising starts immediately and lasts for a time interval that:
1) depends on the device speed and type (rotational or
non-rotational), and 2) is equal to the time needed to load (start up)
a large-size application on that device, with cold caches and with no
additional workload.

Finally, as for guaranteeing a fast execution to interactive,
I/O-related tasks (such as opening a file), consider that any
interactive application blocks and waits for user input both after
starting up and after executing some task. After a while, the user may
trigger new operations, after which the application stops again, and
so on. Accordingly, the low-latency heuristic weight-raises again a
queue in case it becomes backlogged after being idle for a
sufficiently long (configurable) time. The weight-raising then lasts
for the same time as for a just-created queue.

According to our experiments, the combination of this low-latency
heuristic and of the improvements described in patch 7 allows BFQ
to guarantee a high application responsiveness.

[1] P. Valente and M. Andreolini, "Improving Application
    Responsiveness with the BFQ Disk I/O Scheduler", Proceedings of
    the 5th Annual International Systems and Storage Conference
    (SYSTOR '12), June 2012.
    Slightly extended version:
http://www.algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Kconfig.iosched |   8 +-
 block/bfq-cgroup.c    |  15 +++
 block/bfq-iosched.c   | 355 ++++++++++++++++++++++++++++++++++++++++++++++----
 block/bfq-sched.c     |   5 +-
 block/bfq.h           |  33 +++++
 5 files changed, 386 insertions(+), 30 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index a3675cb..3e26f28 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -45,8 +45,9 @@ config IOSCHED_BFQ
 	---help---
 	  The BFQ I/O scheduler tries to distribute bandwidth among all
 	  processes according to their weights.
-	  It aims at distributing the bandwidth as desired, regardless
-	  of the disk parameters and with any workload. If compiled
+	  It aims at distributing the bandwidth as desired, regardless of
+	  the device parameters and with any workload. It also tries to
+	  guarantee a low latency to interactive applications. If compiled
 	  built-in (saying Y here), BFQ can be configured to support
 	  hierarchical scheduling.
 
@@ -79,7 +80,8 @@ choice
 		  used by default for all block devices.
 		  The BFQ I/O scheduler aims at distributing the bandwidth
 		  as desired, regardless of the disk parameters and with
-		  any workload.
+		  any workload. It also tries to guarantee a low latency to
+		  interactive applications.
 
 	config DEFAULT_NOOP
 		bool "No-op"
diff --git a/block/bfq-cgroup.c b/block/bfq-cgroup.c
index 805fe5e..1cb25aa 100644
--- a/block/bfq-cgroup.c
+++ b/block/bfq-cgroup.c
@@ -525,6 +525,16 @@ static void bfq_destroy_group(struct bfqio_cgroup *bgrp, struct bfq_group *bfqg)
 	kfree(bfqg);
 }
 
+static void bfq_end_wr_async(struct bfq_data *bfqd)
+{
+	struct hlist_node *tmp;
+	struct bfq_group *bfqg;
+
+	hlist_for_each_entry_safe(bfqg, tmp, &bfqd->group_list, bfqd_node)
+		bfq_end_wr_async_queues(bfqd, bfqg);
+	bfq_end_wr_async_queues(bfqd, bfqd->root_group);
+}
+
 /**
  * bfq_disconnect_groups - disconnect @bfqd from all its groups.
  * @bfqd: the device descriptor being exited.
@@ -866,6 +876,11 @@ static inline void bfq_bfqq_move(struct bfq_data *bfqd,
 {
 }
 
+static void bfq_end_wr_async(struct bfq_data *bfqd)
+{
+	bfq_end_wr_async_queues(bfqd, bfqd->root_group);
+}
+
 static inline void bfq_disconnect_groups(struct bfq_data *bfqd)
 {
 	bfq_put_async_queues(bfqd, bfqd->root_group);
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 9e607a0..ace9aba 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -24,15 +24,15 @@
  * precisely, BFQ schedules queues associated to processes. Thanks to the
  * accurate policy of B-WF2Q+, BFQ can afford to assign high budgets to
  * I/O-bound processes issuing sequential requests (to boost the
- * throughput), and yet guarantee a relatively low latency to interactive
- * applications.
+ * throughput), and yet guarantee a low latency to interactive applications.
  *
  * BFQ is described in [1], where also a reference to the initial, more
  * theoretical paper on BFQ can be found. The interested reader can find
  * in the latter paper full details on the main algorithm, as well as
  * formulas of the guarantees and formal proofs of all the properties.
  * With respect to the version of BFQ presented in these papers, this
- * implementation adds a hierarchical extension based on H-WF2Q+.
+ * implementation adds a few more heuristics and a hierarchical extension
+ * based on H-WF2Q+.
  *
  * B-WF2Q+ is based on WF2Q+, that is described in [2], together with
  * H-WF2Q+, while the augmented tree used to implement B-WF2Q+ with O(log N)
@@ -116,6 +116,48 @@ struct kmem_cache *bfq_pool;
 /* Shift used for peak rate fixed precision calculations. */
 #define BFQ_RATE_SHIFT		16
 
+/*
+ * By default, BFQ computes the duration of the weight raising for
+ * interactive applications automatically, using the following formula:
+ * duration = (R / r) * T, where r is the peak rate of the device, and
+ * R and T are two reference parameters.
+ * In particular, R is the peak rate of the reference device (see below),
+ * and T is a reference time: given the systems that are likely to be
+ * installed on the reference device according to its speed class, T is
+ * about the maximum time needed, under BFQ and while reading two files in
+ * parallel, to load typical large applications on these systems.
+ * In practice, the slower/faster the device at hand is, the more/less it
+ * takes to load applications with respect to the reference device.
+ * Accordingly, the longer/shorter BFQ grants weight raising to interactive
+ * applications.
+ *
+ * BFQ uses four different reference pairs (R, T), depending on:
+ * . whether the device is rotational or non-rotational;
+ * . whether the device is slow, such as old or portable HDDs, as well as
+ *   SD cards, or fast, such as newer HDDs and SSDs.
+ *
+ * The device's speed class is dynamically (re)detected in
+ * bfq_update_peak_rate() every time the estimated peak rate is updated.
+ *
+ * In the following definitions, R_slow[0]/R_fast[0] and T_slow[0]/T_fast[0]
+ * are the reference values for a slow/fast rotational device, whereas
+ * R_slow[1]/R_fast[1] and T_slow[1]/T_fast[1] are the reference values for
+ * a slow/fast non-rotational device. Finally, device_speed_thresh are the
+ * thresholds used to switch between speed classes.
+ * Both the reference peak rates and the thresholds are measured in
+ * sectors/usec, left-shifted by BFQ_RATE_SHIFT.
+ */
+static int R_slow[2] = {1536, 10752};
+static int R_fast[2] = {17415, 34791};
+/*
+ * To improve readability, a conversion function is used to initialize the
+ * following arrays, which entails that they can be initialized only in a
+ * function.
+ */
+static int T_slow[2];
+static int T_fast[2];
+static int device_speed_thresh[2];
+
 #define BFQ_SERVICE_TREE_INIT	((struct bfq_service_tree)		\
 				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
 
@@ -281,7 +323,8 @@ static inline unsigned long bfq_serv_to_charge(struct request *rq,
 					       struct bfq_queue *bfqq)
 {
 	return blk_rq_sectors(rq) *
-		(1 + ((!bfq_bfqq_sync(bfqq)) * bfq_async_charge_factor));
+		(1 + ((!bfq_bfqq_sync(bfqq)) * (bfqq->wr_coeff == 1) *
+		bfq_async_charge_factor));
 }
 
 /**
@@ -322,12 +365,27 @@ static void bfq_updated_next_req(struct bfq_data *bfqd,
 	}
 }
 
+static inline unsigned int bfq_wr_duration(struct bfq_data *bfqd)
+{
+	u64 dur;
+
+	if (bfqd->bfq_wr_max_time > 0)
+		return bfqd->bfq_wr_max_time;
+
+	dur = bfqd->RT_prod;
+	do_div(dur, bfqd->peak_rate);
+
+	return dur;
+}
+
 static void bfq_add_request(struct request *rq)
 {
 	struct bfq_queue *bfqq = RQ_BFQQ(rq);
 	struct bfq_entity *entity = &bfqq->entity;
 	struct bfq_data *bfqd = bfqq->bfqd;
 	struct request *next_rq, *prev;
+	unsigned long old_wr_coeff = bfqq->wr_coeff;
+	int idle_for_long_time = 0;
 
 	bfq_log_bfqq(bfqd, bfqq, "add_request %d", rq_is_sync(rq));
 	bfqq->queued[rq_is_sync(rq)]++;
@@ -343,13 +401,64 @@ static void bfq_add_request(struct request *rq)
 	bfqq->next_rq = next_rq;
 
 	if (!bfq_bfqq_busy(bfqq)) {
+		idle_for_long_time = time_is_before_jiffies(
+			bfqq->budget_timeout +
+			bfqd->bfq_wr_min_idle_time);
 		entity->budget = max_t(unsigned long, bfqq->max_budget,
 				       bfq_serv_to_charge(next_rq, bfqq));
+
+		if (!bfqd->low_latency)
+			goto add_bfqq_busy;
+
+		/*
+		 * If the queue is not being boosted and has been idle for
+		 * enough time, start a weight-raising period.
+		 */
+		if (old_wr_coeff == 1 && idle_for_long_time) {
+			bfqq->wr_coeff = bfqd->bfq_wr_coeff;
+			bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
+			bfq_log_bfqq(bfqd, bfqq,
+				     "wrais starting at %lu, rais_max_time %u",
+				     jiffies,
+				     jiffies_to_msecs(bfqq->wr_cur_max_time));
+		} else if (old_wr_coeff > 1) {
+			if (idle_for_long_time)
+				bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
+			else {
+				bfqq->wr_coeff = 1;
+				bfq_log_bfqq(bfqd, bfqq,
+					"wrais ending at %lu, rais_max_time %u",
+					jiffies,
+					jiffies_to_msecs(bfqq->
+						wr_cur_max_time));
+			}
+		}
+		if (old_wr_coeff != bfqq->wr_coeff)
+			entity->ioprio_changed = 1;
+add_bfqq_busy:
 		bfq_add_bfqq_busy(bfqd, bfqq);
 	} else {
+		if (bfqd->low_latency && old_wr_coeff == 1 && !rq_is_sync(rq) &&
+		    time_is_before_jiffies(
+				bfqq->last_wr_start_finish +
+				bfqd->bfq_wr_min_inter_arr_async)) {
+			bfqq->wr_coeff = bfqd->bfq_wr_coeff;
+			bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
+
+			entity->ioprio_changed = 1;
+			bfq_log_bfqq(bfqd, bfqq,
+			    "non-idle wrais starting at %lu, rais_max_time %u",
+			    jiffies,
+			    jiffies_to_msecs(bfqq->wr_cur_max_time));
+		}
 		if (prev != bfqq->next_rq)
 			bfq_updated_next_req(bfqd, bfqq);
 	}
+
+	if (bfqd->low_latency &&
+		(old_wr_coeff == 1 || bfqq->wr_coeff == 1 ||
+		 idle_for_long_time))
+		bfqq->last_wr_start_finish = jiffies;
 }
 
 static struct request *bfq_find_rq_fmerge(struct bfq_data *bfqd,
@@ -477,6 +586,43 @@ static void bfq_merged_requests(struct request_queue *q, struct request *rq,
 	bfq_remove_request(next);
 }
 
+/* Must be called with bfqq != NULL */
+static inline void bfq_bfqq_end_wr(struct bfq_queue *bfqq)
+{
+	bfqq->wr_coeff = 1;
+	bfqq->wr_cur_max_time = 0;
+	/* Trigger a weight change on the next activation of the queue */
+	bfqq->entity.ioprio_changed = 1;
+}
+
+static void bfq_end_wr_async_queues(struct bfq_data *bfqd,
+				    struct bfq_group *bfqg)
+{
+	int i, j;
+
+	for (i = 0; i < 2; i++)
+		for (j = 0; j < IOPRIO_BE_NR; j++)
+			if (bfqg->async_bfqq[i][j] != NULL)
+				bfq_bfqq_end_wr(bfqg->async_bfqq[i][j]);
+	if (bfqg->async_idle_bfqq != NULL)
+		bfq_bfqq_end_wr(bfqg->async_idle_bfqq);
+}
+
+static void bfq_end_wr(struct bfq_data *bfqd)
+{
+	struct bfq_queue *bfqq;
+
+	spin_lock_irq(bfqd->queue->queue_lock);
+
+	list_for_each_entry(bfqq, &bfqd->active_list, bfqq_list)
+		bfq_bfqq_end_wr(bfqq);
+	list_for_each_entry(bfqq, &bfqd->idle_list, bfqq_list)
+		bfq_bfqq_end_wr(bfqq);
+	bfq_end_wr_async(bfqd);
+
+	spin_unlock_irq(bfqd->queue->queue_lock);
+}
+
 static int bfq_allow_merge(struct request_queue *q, struct request *rq,
 			   struct bio *bio)
 {
@@ -582,14 +728,17 @@ static void bfq_arm_slice_timer(struct bfq_data *bfqd)
 	 */
 	sl = bfqd->bfq_slice_idle;
 	/*
-	 * Grant only minimum idle time if the queue either has been seeky for
-	 * long enough or has already proved to be constantly seeky.
+	 * Unless the queue is being weight-raised, grant only minimum idle
+	 * time if the queue either has been seeky for long enough or has
+	 * already proved to be constantly seeky.
 	 */
 	if (bfq_sample_valid(bfqq->seek_samples) &&
 	    ((BFQQ_SEEKY(bfqq) && bfqq->entity.service >
 				  bfq_max_budget(bfqq->bfqd) / 8) ||
-	      bfq_bfqq_constantly_seeky(bfqq)))
+	      bfq_bfqq_constantly_seeky(bfqq)) && bfqq->wr_coeff == 1)
 		sl = min(sl, msecs_to_jiffies(BFQ_MIN_TT));
+	else if (bfqq->wr_coeff > 1)
+		sl = sl * 3;
 	bfqd->last_idling_start = ktime_get();
 	mod_timer(&bfqd->idle_slice_timer, jiffies + sl);
 	bfq_log(bfqd, "arm idle: %u/%u ms",
@@ -677,9 +826,15 @@ static void __bfq_bfqq_expire(struct bfq_data *bfqd, struct bfq_queue *bfqq)
 {
 	__bfq_bfqd_reset_in_service(bfqd);
 
-	if (RB_EMPTY_ROOT(&bfqq->sort_list))
+	if (RB_EMPTY_ROOT(&bfqq->sort_list)) {
+		/*
+		 * Overloading budget_timeout field to store the time
+		 * at which the queue remains with no backlog; used by
+		 * the weight-raising mechanism.
+		 */
+		bfqq->budget_timeout = jiffies;
 		bfq_del_bfqq_busy(bfqd, bfqq, 1);
-	else
+	} else
 		bfq_activate_bfqq(bfqd, bfqq);
 }
 
@@ -896,12 +1051,26 @@ static int bfq_update_peak_rate(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 			bfqd->peak_rate_samples++;
 
 		if (bfqd->peak_rate_samples == BFQ_PEAK_RATE_SAMPLES &&
-		    update && bfqd->bfq_user_max_budget == 0) {
-			bfqd->bfq_max_budget =
-				bfq_calc_max_budget(bfqd->peak_rate,
-						    timeout);
-			bfq_log(bfqd, "new max_budget=%lu",
-				bfqd->bfq_max_budget);
+		    update) {
+			int dev_type = blk_queue_nonrot(bfqd->queue);
+			if (bfqd->bfq_user_max_budget == 0) {
+				bfqd->bfq_max_budget =
+					bfq_calc_max_budget(bfqd->peak_rate,
+							    timeout);
+				bfq_log(bfqd, "new max_budget=%lu",
+					bfqd->bfq_max_budget);
+			}
+			if (bfqd->device_speed == BFQ_BFQD_FAST &&
+			    bfqd->peak_rate < device_speed_thresh[dev_type]) {
+				bfqd->device_speed = BFQ_BFQD_SLOW;
+				bfqd->RT_prod = R_slow[dev_type] *
+						T_slow[dev_type];
+			} else if (bfqd->device_speed == BFQ_BFQD_SLOW &&
+			    bfqd->peak_rate > device_speed_thresh[dev_type]) {
+				bfqd->device_speed = BFQ_BFQD_FAST;
+				bfqd->RT_prod = R_fast[dev_type] *
+						T_fast[dev_type];
+			}
 		}
 	}
 
@@ -996,6 +1165,9 @@ static void bfq_bfqq_expire(struct bfq_data *bfqd,
 	if (BFQQ_SEEKY(bfqq) && reason == BFQ_BFQQ_BUDGET_TIMEOUT)
 		bfq_mark_bfqq_constantly_seeky(bfqq);
 
+	if (bfqd->low_latency && bfqq->wr_coeff == 1)
+		bfqq->last_wr_start_finish = jiffies;
+
 	bfq_log_bfqq(bfqd, bfqq,
 		"expire (%d, slow %d, num_disp %d, idle_win %d)", reason,
 		slow, bfqq->dispatched, bfq_bfqq_idle_window(bfqq));
@@ -1044,21 +1216,36 @@ static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
 }
 
 /*
- * Device idling is allowed only for sync queues that have a non-null
- * idle window.
+ * Device idling is allowed only for the queues for which this function
+ * returns true. For this reason, the return value of this function plays a
+ * critical role for both throughput boosting and service guarantees.
+ *
+ * The return value is computed through a logical expression, which may
+ * be true only if bfqq is sync and at least one of the following two
+ * conditions holds:
+ * - the queue has a non-null idle window;
+ * - the queue is being weight-raised.
+ * In fact, waiting for a new request for the queue, in the first case,
+ * is likely to boost the disk throughput, whereas, in the second case,
+ * is necessary to preserve fairness and latency guarantees
+ * (see [1] for details).
  */
 static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
 {
-	return bfq_bfqq_sync(bfqq) && bfq_bfqq_idle_window(bfqq);
+	return bfq_bfqq_sync(bfqq) &&
+	       (bfqq->wr_coeff > 1 || bfq_bfqq_idle_window(bfqq));
 }
 
 /*
- * If the in-service queue is empty, but it is sync and the queue has its
- * idle window set (in this case, waiting for a new request for the queue
- * is likely to boost the throughput), then:
+ * If the in-service queue is empty but sync, and the function
+ * bfq_bfqq_must_not_expire returns true, then:
  * 1) the queue must remain in service and cannot be expired, and
  * 2) the disk must be idled to wait for the possible arrival of a new
  *    request for the queue.
+ * See the comments to the function bfq_bfqq_must_not_expire for the reasons
+ * why performing device idling is the best choice to boost the throughput
+ * and preserve service guarantees when bfq_bfqq_must_not_expire itself
+ * returns true.
  */
 static inline bool bfq_bfqq_must_idle(struct bfq_queue *bfqq)
 {
@@ -1148,6 +1335,38 @@ keep_queue:
 	return bfqq;
 }
 
+static void bfq_update_wr_data(struct bfq_data *bfqd, struct bfq_queue *bfqq)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+	if (bfqq->wr_coeff > 1) { /* queue is being weight-raised */
+		bfq_log_bfqq(bfqd, bfqq,
+			"raising period dur %u/%u msec, old coeff %u, w %d(%d)",
+			jiffies_to_msecs(jiffies - bfqq->last_wr_start_finish),
+			jiffies_to_msecs(bfqq->wr_cur_max_time),
+			bfqq->wr_coeff,
+			bfqq->entity.weight, bfqq->entity.orig_weight);
+
+		/*
+		 * If too much time has elapsed from the beginning
+		 * of this weight-raising period, stop it.
+		 */
+		if (time_is_before_jiffies(bfqq->last_wr_start_finish +
+					   bfqq->wr_cur_max_time)) {
+			bfqq->last_wr_start_finish = jiffies;
+			bfq_log_bfqq(bfqd, bfqq,
+				     "wrais ending at %lu, rais_max_time %u",
+				     bfqq->last_wr_start_finish,
+				     jiffies_to_msecs(bfqq->wr_cur_max_time));
+			bfq_bfqq_end_wr(bfqq);
+		}
+	}
+	/* Update weight both if it must be raised and if it must be lowered */
+	if ((entity->weight > entity->orig_weight) != (bfqq->wr_coeff > 1))
+		__bfq_entity_update_weight_prio(
+			bfq_entity_service_tree(entity),
+			entity);
+}
+
 /*
  * Dispatch one request from bfqq, moving it to the request queue
  * dispatch list.
@@ -1194,6 +1413,8 @@ static int bfq_dispatch_request(struct bfq_data *bfqd,
 	bfq_bfqq_served(bfqq, service_to_charge);
 	bfq_dispatch_insert(bfqd->queue, rq);
 
+	bfq_update_wr_data(bfqd, bfqq);
+
 	bfq_log_bfqq(bfqd, bfqq,
 			"dispatched %u sec req (%llu), budg left %lu",
 			blk_rq_sectors(rq),
@@ -1467,6 +1688,9 @@ static void bfq_init_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 	/* Tentative initial value to trade off between thr and lat */
 	bfqq->max_budget = (2 * bfq_max_budget(bfqd)) / 3;
 	bfqq->pid = pid;
+
+	bfqq->wr_coeff = 1;
+	bfqq->last_wr_start_finish = 0;
 }
 
 static struct bfq_queue *bfq_find_alloc_queue(struct bfq_data *bfqd,
@@ -1642,7 +1866,8 @@ static void bfq_update_idle_window(struct bfq_data *bfqd,
 		(bfqd->hw_tag && BFQQ_SEEKY(bfqq)))
 		enable_idle = 0;
 	else if (bfq_sample_valid(bic->ttime.ttime_samples)) {
-		if (bic->ttime.ttime_mean > bfqd->bfq_slice_idle)
+		if (bic->ttime.ttime_mean > bfqd->bfq_slice_idle &&
+			bfqq->wr_coeff == 1)
 			enable_idle = 0;
 		else
 			enable_idle = 1;
@@ -2117,6 +2342,22 @@ static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 	bfqd->bfq_timeout[BLK_RW_ASYNC] = bfq_timeout_async;
 	bfqd->bfq_timeout[BLK_RW_SYNC] = bfq_timeout_sync;
 
+	bfqd->low_latency = true;
+
+	bfqd->bfq_wr_coeff = 20;
+	bfqd->bfq_wr_max_time = 0;
+	bfqd->bfq_wr_min_idle_time = msecs_to_jiffies(2000);
+	bfqd->bfq_wr_min_inter_arr_async = msecs_to_jiffies(500);
+
+	/*
+	 * Begin by assuming, optimistically, that the device peak rate is
+	 * equal to the highest reference rate.
+	 */
+	bfqd->RT_prod = R_fast[blk_queue_nonrot(bfqd->queue)] *
+			T_fast[blk_queue_nonrot(bfqd->queue)];
+	bfqd->peak_rate = R_fast[blk_queue_nonrot(bfqd->queue)];
+	bfqd->device_speed = BFQ_BFQD_FAST;
+
 	return 0;
 }
 
@@ -2151,6 +2392,14 @@ static ssize_t bfq_var_store(unsigned long *var, const char *page,
 	return count;
 }
 
+static ssize_t bfq_wr_max_time_show(struct elevator_queue *e, char *page)
+{
+	struct bfq_data *bfqd = e->elevator_data;
+	return sprintf(page, "%d\n", bfqd->bfq_wr_max_time > 0 ?
+		       jiffies_to_msecs(bfqd->bfq_wr_max_time) :
+		       jiffies_to_msecs(bfq_wr_duration(bfqd)));
+}
+
 static ssize_t bfq_weights_show(struct elevator_queue *e, char *page)
 {
 	struct bfq_queue *bfqq;
@@ -2165,19 +2414,24 @@ static ssize_t bfq_weights_show(struct elevator_queue *e, char *page)
 	num_char += sprintf(page + num_char, "Active:\n");
 	list_for_each_entry(bfqq, &bfqd->active_list, bfqq_list) {
 	  num_char += sprintf(page + num_char,
-			      "pid%d: weight %hu, nr_queued %d %d\n",
+			      "pid%d: weight %hu, nr_queued %d %d, dur %d/%u\n",
 			      bfqq->pid,
 			      bfqq->entity.weight,
 			      bfqq->queued[0],
-			      bfqq->queued[1]);
+			      bfqq->queued[1],
+			jiffies_to_msecs(jiffies - bfqq->last_wr_start_finish),
+			jiffies_to_msecs(bfqq->wr_cur_max_time));
 	}
 
 	num_char += sprintf(page + num_char, "Idle:\n");
 	list_for_each_entry(bfqq, &bfqd->idle_list, bfqq_list) {
 			num_char += sprintf(page + num_char,
-				"pid%d: weight %hu\n",
+				"pid%d: weight %hu, dur %d/%u\n",
 				bfqq->pid,
-				bfqq->entity.weight);
+				bfqq->entity.weight,
+				jiffies_to_msecs(jiffies -
+					bfqq->last_wr_start_finish),
+				jiffies_to_msecs(bfqq->wr_cur_max_time));
 	}
 
 	spin_unlock_irq(bfqd->queue->queue_lock);
@@ -2205,6 +2459,11 @@ SHOW_FUNCTION(bfq_max_budget_async_rq_show,
 	      bfqd->bfq_max_budget_async_rq, 0);
 SHOW_FUNCTION(bfq_timeout_sync_show, bfqd->bfq_timeout[BLK_RW_SYNC], 1);
 SHOW_FUNCTION(bfq_timeout_async_show, bfqd->bfq_timeout[BLK_RW_ASYNC], 1);
+SHOW_FUNCTION(bfq_low_latency_show, bfqd->low_latency, 0);
+SHOW_FUNCTION(bfq_wr_coeff_show, bfqd->bfq_wr_coeff, 0);
+SHOW_FUNCTION(bfq_wr_min_idle_time_show, bfqd->bfq_wr_min_idle_time, 1);
+SHOW_FUNCTION(bfq_wr_min_inter_arr_async_show, bfqd->bfq_wr_min_inter_arr_async,
+	1);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -2237,6 +2496,12 @@ STORE_FUNCTION(bfq_max_budget_async_rq_store, &bfqd->bfq_max_budget_async_rq,
 		1, INT_MAX, 0);
 STORE_FUNCTION(bfq_timeout_async_store, &bfqd->bfq_timeout[BLK_RW_ASYNC], 0,
 		INT_MAX, 1);
+STORE_FUNCTION(bfq_wr_coeff_store, &bfqd->bfq_wr_coeff, 1, INT_MAX, 0);
+STORE_FUNCTION(bfq_wr_max_time_store, &bfqd->bfq_wr_max_time, 0, INT_MAX, 1);
+STORE_FUNCTION(bfq_wr_min_idle_time_store, &bfqd->bfq_wr_min_idle_time, 0,
+		INT_MAX, 1);
+STORE_FUNCTION(bfq_wr_min_inter_arr_async_store,
+		&bfqd->bfq_wr_min_inter_arr_async, 0, INT_MAX, 1);
 #undef STORE_FUNCTION
 
 /* do nothing for the moment */
@@ -2295,6 +2560,22 @@ static ssize_t bfq_timeout_sync_store(struct elevator_queue *e,
 	return ret;
 }
 
+static ssize_t bfq_low_latency_store(struct elevator_queue *e,
+				     const char *page, size_t count)
+{
+	struct bfq_data *bfqd = e->elevator_data;
+	unsigned long uninitialized_var(__data);
+	int ret = bfq_var_store(&__data, (page), count);
+
+	if (__data > 1)
+		__data = 1;
+	if (__data == 0 && bfqd->low_latency != 0)
+		bfq_end_wr(bfqd);
+	bfqd->low_latency = __data;
+
+	return ret;
+}
+
 #define BFQ_ATTR(name) \
 	__ATTR(name, S_IRUGO|S_IWUSR, bfq_##name##_show, bfq_##name##_store)
 
@@ -2309,6 +2590,11 @@ static struct elv_fs_entry bfq_attrs[] = {
 	BFQ_ATTR(max_budget_async_rq),
 	BFQ_ATTR(timeout_sync),
 	BFQ_ATTR(timeout_async),
+	BFQ_ATTR(low_latency),
+	BFQ_ATTR(wr_coeff),
+	BFQ_ATTR(wr_max_time),
+	BFQ_ATTR(wr_min_idle_time),
+	BFQ_ATTR(wr_min_inter_arr_async),
 	BFQ_ATTR(weights),
 	__ATTR_NULL
 };
@@ -2355,6 +2641,23 @@ static int __init bfq_init(void)
 	if (bfq_slab_setup())
 		return -ENOMEM;
 
+	/*
+	 * Times to load large popular applications for the typical systems
+	 * installed on the reference devices (see the comments before the
+	 * definitions of the two arrays).
+	 */
+	T_slow[0] = msecs_to_jiffies(2600);
+	T_slow[1] = msecs_to_jiffies(1000);
+	T_fast[0] = msecs_to_jiffies(5500);
+	T_fast[1] = msecs_to_jiffies(2000);
+
+	/*
+	 * Thresholds that determine the switch between speed classes (see
+	 * the comments before the definition of the array).
+	 */
+	device_speed_thresh[0] = (R_fast[0] + R_slow[0]) / 2;
+	device_speed_thresh[1] = (R_fast[1] + R_slow[1]) / 2;
+
 	elv_register(&iosched_bfq);
 	pr_info("BFQ I/O-scheduler version: v1");
 
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
index 075e472..f6491d5 100644
--- a/block/bfq-sched.c
+++ b/block/bfq-sched.c
@@ -514,6 +514,8 @@ __bfq_entity_update_weight_prio(struct bfq_service_tree *old_st,
 	struct bfq_service_tree *new_st = old_st;
 
 	if (entity->ioprio_changed) {
+		struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+
 		old_st->wsum -= entity->weight;
 
 		if (entity->new_weight != entity->orig_weight) {
@@ -539,7 +541,8 @@ __bfq_entity_update_weight_prio(struct bfq_service_tree *old_st,
 		 * when entity->finish <= old_st->vtime).
 		 */
 		new_st = bfq_entity_service_tree(entity);
-		entity->weight = entity->orig_weight;
+		entity->weight = entity->orig_weight *
+				 (bfqq != NULL ? bfqq->wr_coeff : 1);
 		new_st->wsum += entity->weight;
 
 		if (new_st != old_st)
diff --git a/block/bfq.h b/block/bfq.h
index ea5ecca..3ce9100 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -181,6 +181,10 @@ struct bfq_group;
  * @seek_mean: mean seek distance
  * @last_request_pos: position of the last request enqueued
  * @pid: pid of the process owning the queue, used for logging purposes.
+ * @last_wr_start_finish: start time of the current weight-raising period if
+ *                        the @bfq-queue is being weight-raised, otherwise
+ *                        finish time of the last weight-raising period
+ * @wr_cur_max_time: current max raising time for this queue
  *
  * A bfq_queue is a leaf request queue; it can be associated with an
  * io_context or more, if it is async. @cgroup holds a reference to the
@@ -217,6 +221,11 @@ struct bfq_queue {
 	sector_t last_request_pos;
 
 	pid_t pid;
+
+	/* weight-raising fields */
+	unsigned long wr_cur_max_time;
+	unsigned long last_wr_start_finish;
+	unsigned int wr_coeff;
 };
 
 /**
@@ -297,6 +306,18 @@ enum bfq_device_speed {
  *               they are charged for the whole allocated budget, to try
  *               to preserve a behavior reasonably fair among them, but
  *               without service-domain guarantees).
+ * @bfq_wr_coeff: Maximum factor by which the weight of a weight-raised
+ *                queue is multiplied
+ * @bfq_wr_max_time: maximum duration of a weight-raising period (jiffies)
+ * @bfq_wr_min_idle_time: minimum idle period after which weight-raising
+ *			  may be reactivated for a queue (in jiffies)
+ * @bfq_wr_min_inter_arr_async: minimum period between request arrivals
+ *				after which weight-raising may be
+ *				reactivated for an already busy queue
+ *				(in jiffies)
+ * @RT_prod: cached value of the product R*T used for computing the maximum
+ *	     duration of the weight raising automatically
+ * @device_speed: device-speed class for the low-latency heuristic
  * @oom_bfqq: fallback dummy bfqq for extreme OOM conditions
  *
  * All the fields are protected by the @queue lock.
@@ -346,6 +367,16 @@ struct bfq_data {
 	unsigned int bfq_max_budget_async_rq;
 	unsigned int bfq_timeout[2];
 
+	bool low_latency;
+
+	/* parameters of the low_latency heuristics */
+	unsigned int bfq_wr_coeff;
+	unsigned int bfq_wr_max_time;
+	unsigned int bfq_wr_min_idle_time;
+	unsigned long bfq_wr_min_inter_arr_async;
+	u64 RT_prod;
+	enum bfq_device_speed device_speed;
+
 	struct bfq_queue oom_bfqq;
 };
 
@@ -556,6 +587,8 @@ static void bfq_dispatch_insert(struct request_queue *q, struct request *rq);
 static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd,
 				       struct bfq_group *bfqg, int is_sync,
 				       struct bfq_io_cq *bic, gfp_t gfp_mask);
+static void bfq_end_wr_async_queues(struct bfq_data *bfqd,
+				    struct bfq_group *bfqg);
 static void bfq_put_async_queues(struct bfq_data *bfqd, struct bfq_group *bfqg);
 static void bfq_exit_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq);
 
-- 
1.9.2
