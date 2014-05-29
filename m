From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 07/12] block,
	bfq: reduce I/O latency for soft real-time applications
Date: Thu, 29 May 2014 11:05:38 +0200
Message-ID: <1401354343-5527-8-git-send-email-paolo.valente@unimore.it>
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

To guarantee a low latency also to the I/O requests issued by soft
real-time applications, this patch introduces a further heuristic,
which weight-raises (in the sense explained in patch 8) also the
queues associated to applications deemed as soft real-time.

To be deemed as soft real-time, an application must meet two
requirements.  First, the application must not require an average
bandwidth higher than the approximate bandwidth required to playback
or record a compressed high-definition video. Second, the request
pattern of the application must be isochronous, i.e., after issuing a
request or a batch of requests, the application must stop issuing new
requests until all its pending requests have been completed. After
that, the application may issue a new batch, and so on.

As for the second requirement, it is critical to require also that,
after all the pending requests of the application have been completed,
an adequate minimum amount of time elapses before the application
starts issuing new requests. This prevents also greedy (i.e.,
I/O-bound) applications from being incorrectly deemed, occasionally,
as soft real-time. In fact, if *any amount of time* is fine, then even
a greedy application may, paradoxically, meet both the above
requirements, if: (1) the application performs random I/O and/or the
device is slow, and (2) the CPU load is high. The reason is the
following.  First, if condition (1) is true, then, during the service
of the application, the throughput may be low enough to let the
application meet the bandwidth requirement.  Second, if condition (2)
is true as well, then the application may occasionally behave in an
apparently isochronous way, because it may simply stop issuing
requests while the CPUs are busy serving other processes.

To address this issue, the heuristic leverages the simple fact that
greedy applications issue *all* of their requests as quickly as they
can, whereas soft real-time applications spend some time processing
data after each batch of requests is completed. In particular, the
heuristic works as follows. First, according to the above isochrony
requirement, the heuristic checks whether an application may be soft
real-time (and therefore gives to the application the opportunity to
be deemed as such) only when both the following two conditions happen
to hold: 1) the queue associated with the application has expired and
is empty, 2) there is no outstanding request of the application.

Suppose that both conditions hold at time, say, t_c and that the
application issues instead its next request at time, say, t_i. At time
t_c the heuristic computes the next time instant, called
soft_rt_next_start in the code, such that, only if
t_i >= soft_rt_next_start, then both the next conditions will hold
when the application issues its next request:
1) the application will meet the above bandwidth requirement,
2) a given minimum time interval, say Delta, will have elapsed from
time t_c (so as to filter out greedy application).

The current value of Delta is a little bit higher than the value that
we have found, experimentally, to be adequate on a real,
general-purpose machine. In particular we had to increase Delta to
make the filter quite precise also in slower, embedded systems, and in
KVM/QEMU virtual machines (details in the comments to the code).

If the application actually issues its next request after time
soft_rt_next_start, then its associated queue will be weight-raised
for a relatively short time interval. If, during this time interval,
the application proves again to meet the bandwidth and isochrony
requirements, then the end of the weight-raising period for the queue
is moved forward, and so on. Note that an application whose associated
queue never happens to be empty when it expires will never have the
opportunity to be deemed as soft real-time.

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Kconfig.iosched |   8 +-
 block/bfq-iosched.c   | 231 ++++++++++++++++++++++++++++++++++++++++++++++++--
 block/bfq.h           |  24 ++++++
 3 files changed, 251 insertions(+), 12 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 3e26f28..1d64eea 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -47,9 +47,9 @@ config IOSCHED_BFQ
 	  processes according to their weights.
 	  It aims at distributing the bandwidth as desired, regardless of
 	  the device parameters and with any workload. It also tries to
-	  guarantee a low latency to interactive applications. If compiled
-	  built-in (saying Y here), BFQ can be configured to support
-	  hierarchical scheduling.
+	  guarantee low latency to interactive and soft real-time
+	  applications. If compiled built-in (saying Y here), BFQ can
+	  be configured to support hierarchical scheduling.
 
 config CGROUP_BFQIO
 	bool "BFQ hierarchical scheduling support"
@@ -81,7 +81,7 @@ choice
 		  The BFQ I/O scheduler aims at distributing the bandwidth
 		  as desired, regardless of the disk parameters and with
 		  any workload. It also tries to guarantee a low latency to
-		  interactive applications.
+		  interactive and soft real-time applications.
 
 	config DEFAULT_NOOP
 		bool "No-op"
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index ace9aba..661f948 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -24,15 +24,17 @@
  * precisely, BFQ schedules queues associated to processes. Thanks to the
  * accurate policy of B-WF2Q+, BFQ can afford to assign high budgets to
  * I/O-bound processes issuing sequential requests (to boost the
- * throughput), and yet guarantee a low latency to interactive applications.
+ * throughput), and yet guarantee a low latency to interactive and soft
+ * real-time applications.
  *
  * BFQ is described in [1], where also a reference to the initial, more
  * theoretical paper on BFQ can be found. The interested reader can find
  * in the latter paper full details on the main algorithm, as well as
  * formulas of the guarantees and formal proofs of all the properties.
  * With respect to the version of BFQ presented in these papers, this
- * implementation adds a few more heuristics and a hierarchical extension
- * based on H-WF2Q+.
+ * implementation adds a few more heuristics, such as the one that
+ * guarantees a low latency to soft real-time applications, and a
+ * hierarchical extension based on H-WF2Q+.
  *
  * B-WF2Q+ is based on WF2Q+, that is described in [2], together with
  * H-WF2Q+, while the augmented tree used to implement B-WF2Q+ with O(log N)
@@ -401,6 +403,8 @@ static void bfq_add_request(struct request *rq)
 	bfqq->next_rq = next_rq;
 
 	if (!bfq_bfqq_busy(bfqq)) {
+		int soft_rt = bfqd->bfq_wr_max_softrt_rate > 0 &&
+			time_is_before_jiffies(bfqq->soft_rt_next_start);
 		idle_for_long_time = time_is_before_jiffies(
 			bfqq->budget_timeout +
 			bfqd->bfq_wr_min_idle_time);
@@ -414,9 +418,13 @@ static void bfq_add_request(struct request *rq)
 		 * If the queue is not being boosted and has been idle for
 		 * enough time, start a weight-raising period.
 		 */
-		if (old_wr_coeff == 1 && idle_for_long_time) {
+		if (old_wr_coeff == 1 && (idle_for_long_time || soft_rt)) {
 			bfqq->wr_coeff = bfqd->bfq_wr_coeff;
-			bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
+			if (idle_for_long_time)
+				bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
+			else
+				bfqq->wr_cur_max_time =
+					bfqd->bfq_wr_rt_max_time;
 			bfq_log_bfqq(bfqd, bfqq,
 				     "wrais starting at %lu, rais_max_time %u",
 				     jiffies,
@@ -424,18 +432,76 @@ static void bfq_add_request(struct request *rq)
 		} else if (old_wr_coeff > 1) {
 			if (idle_for_long_time)
 				bfqq->wr_cur_max_time = bfq_wr_duration(bfqd);
-			else {
+			else if (bfqq->wr_cur_max_time ==
+				 bfqd->bfq_wr_rt_max_time &&
+				 !soft_rt) {
 				bfqq->wr_coeff = 1;
 				bfq_log_bfqq(bfqd, bfqq,
 					"wrais ending at %lu, rais_max_time %u",
 					jiffies,
 					jiffies_to_msecs(bfqq->
 						wr_cur_max_time));
+			} else if (time_before(
+					bfqq->last_wr_start_finish +
+					bfqq->wr_cur_max_time,
+					jiffies +
+					bfqd->bfq_wr_rt_max_time) &&
+				   soft_rt) {
+				/*
+				 *
+				 * The remaining weight-raising time is lower
+				 * than bfqd->bfq_wr_rt_max_time, which means
+				 * that the application is enjoying weight
+				 * raising either because deemed soft-rt in
+				 * the near past, or because deemed interactive
+				 * a long ago.
+				 * In both cases, resetting now the current
+				 * remaining weight-raising time for the
+				 * application to the weight-raising duration
+				 * for soft rt applications would not cause any
+				 * latency increase for the application (as the
+				 * new duration would be higher than the
+				 * remaining time).
+				 *
+				 * In addition, the application is now meeting
+				 * the requirements for being deemed soft rt.
+				 * In the end we can correctly and safely
+				 * (re)charge the weight-raising duration for
+				 * the application with the weight-raising
+				 * duration for soft rt applications.
+				 *
+				 * In particular, doing this recharge now, i.e.,
+				 * before the weight-raising period for the
+				 * application finishes, reduces the probability
+				 * of the following negative scenario:
+				 * 1) the weight of a soft rt application is
+				 *    raised at startup (as for any newly
+				 *    created application),
+				 * 2) since the application is not interactive,
+				 *    at a certain time weight-raising is
+				 *    stopped for the application,
+				 * 3) at that time the application happens to
+				 *    still have pending requests, and hence
+				 *    is destined to not have a chance to be
+				 *    deemed soft rt before these requests are
+				 *    completed (see the comments to the
+				 *    function bfq_bfqq_softrt_next_start()
+				 *    for details on soft rt detection),
+				 * 4) these pending requests experience a high
+				 *    latency because the application is not
+				 *    weight-raised while they are pending.
+				 */
+				bfqq->last_wr_start_finish = jiffies;
+				bfqq->wr_cur_max_time =
+					bfqd->bfq_wr_rt_max_time;
 			}
 		}
 		if (old_wr_coeff != bfqq->wr_coeff)
 			entity->ioprio_changed = 1;
 add_bfqq_busy:
+		bfqq->last_idle_bklogged = jiffies;
+		bfqq->service_from_backlogged = 0;
+		bfq_clear_bfqq_softrt_update(bfqq);
 		bfq_add_bfqq_busy(bfqd, bfqq);
 	} else {
 		if (bfqd->low_latency && old_wr_coeff == 1 && !rq_is_sync(rq) &&
@@ -753,8 +819,11 @@ static void bfq_arm_slice_timer(struct bfq_data *bfqd)
 static void bfq_set_budget_timeout(struct bfq_data *bfqd)
 {
 	struct bfq_queue *bfqq = bfqd->in_service_queue;
-	unsigned int timeout_coeff = bfqq->entity.weight /
-				     bfqq->entity.orig_weight;
+	unsigned int timeout_coeff;
+	if (bfqq->wr_cur_max_time == bfqd->bfq_wr_rt_max_time)
+		timeout_coeff = 1;
+	else
+		timeout_coeff = bfqq->entity.weight / bfqq->entity.orig_weight;
 
 	bfqd->last_budget_start = ktime_get();
 
@@ -1105,6 +1174,77 @@ static int bfq_update_peak_rate(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 	return expected > (4 * bfqq->entity.budget) / 3;
 }
 
+/*
+ * To be deemed as soft real-time, an application must meet two
+ * requirements. First, the application must not require an average
+ * bandwidth higher than the approximate bandwidth required to playback or
+ * record a compressed high-definition video.
+ * The next function is invoked on the completion of the last request of a
+ * batch, to compute the next-start time instant, soft_rt_next_start, such
+ * that, if the next request of the application does not arrive before
+ * soft_rt_next_start, then the above requirement on the bandwidth is met.
+ *
+ * The second requirement is that the request pattern of the application is
+ * isochronous, i.e., that, after issuing a request or a batch of requests,
+ * the application stops issuing new requests until all its pending requests
+ * have been completed. After that, the application may issue a new batch,
+ * and so on.
+ * For this reason the next function is invoked to compute
+ * soft_rt_next_start only for applications that meet this requirement,
+ * whereas soft_rt_next_start is set to infinity for applications that do
+ * not.
+ *
+ * Unfortunately, even a greedy application may happen to behave in an
+ * isochronous way if the CPU load is high. In fact, the application may
+ * stop issuing requests while the CPUs are busy serving other processes,
+ * then restart, then stop again for a while, and so on. In addition, if
+ * the disk achieves a low enough throughput with the request pattern
+ * issued by the application (e.g., because the request pattern is random
+ * and/or the device is slow), then the application may meet the above
+ * bandwidth requirement too. To prevent such a greedy application to be
+ * deemed as soft real-time, a further rule is used in the computation of
+ * soft_rt_next_start: soft_rt_next_start must be higher than the current
+ * time plus the maximum time for which the arrival of a request is waited
+ * for when a sync queue becomes idle, namely bfqd->bfq_slice_idle.
+ * This filters out greedy applications, as the latter issue instead their
+ * next request as soon as possible after the last one has been completed
+ * (in contrast, when a batch of requests is completed, a soft real-time
+ * application spends some time processing data).
+ *
+ * Unfortunately, the last filter may easily generate false positives if
+ * only bfqd->bfq_slice_idle is used as a reference time interval and one
+ * or both the following cases occur:
+ * 1) HZ is so low that the duration of a jiffy is comparable to or higher
+ *    than bfqd->bfq_slice_idle. This happens, e.g., on slow devices with
+ *    HZ=100.
+ * 2) jiffies, instead of increasing at a constant rate, may stop increasing
+ *    for a while, then suddenly 'jump' by several units to recover the lost
+ *    increments. This seems to happen, e.g., inside virtual machines.
+ * To address this issue, we do not use as a reference time interval just
+ * bfqd->bfq_slice_idle, but bfqd->bfq_slice_idle plus a few jiffies. In
+ * particular we add the minimum number of jiffies for which the filter
+ * seems to be quite precise also in embedded systems and KVM/QEMU virtual
+ * machines.
+ */
+static inline unsigned long bfq_bfqq_softrt_next_start(struct bfq_data *bfqd,
+						       struct bfq_queue *bfqq)
+{
+	return max(bfqq->last_idle_bklogged +
+		   HZ * bfqq->service_from_backlogged /
+		   bfqd->bfq_wr_max_softrt_rate,
+		   jiffies + bfqq->bfqd->bfq_slice_idle + 4);
+}
+
+/*
+ * Return the largest-possible time instant such that, for as long as possible,
+ * the current time will be lower than this time instant according to the macro
+ * time_is_before_jiffies().
+ */
+static inline unsigned long bfq_infinity_from_now(unsigned long now)
+{
+	return now + ULONG_MAX / 2;
+}
+
 /**
  * bfq_bfqq_expire - expire a queue.
  * @bfqd: device owning the queue.
@@ -1162,12 +1302,55 @@ static void bfq_bfqq_expire(struct bfq_data *bfqd,
 		     bfq_bfqq_budget_left(bfqq) >=  bfqq->entity.budget / 3))
 		bfq_bfqq_charge_full_budget(bfqq);
 
+	bfqq->service_from_backlogged += bfqq->entity.service;
+
 	if (BFQQ_SEEKY(bfqq) && reason == BFQ_BFQQ_BUDGET_TIMEOUT)
 		bfq_mark_bfqq_constantly_seeky(bfqq);
 
 	if (bfqd->low_latency && bfqq->wr_coeff == 1)
 		bfqq->last_wr_start_finish = jiffies;
 
+	if (bfqd->low_latency && bfqd->bfq_wr_max_softrt_rate > 0 &&
+	    RB_EMPTY_ROOT(&bfqq->sort_list)) {
+		/*
+		 * If we get here, and there are no outstanding requests,
+		 * then the request pattern is isochronous (see the comments
+		 * to the function bfq_bfqq_softrt_next_start()). Hence we
+		 * can compute soft_rt_next_start. If, instead, the queue
+		 * still has outstanding requests, then we have to wait
+		 * for the completion of all the outstanding requests to
+		 * discover whether the request pattern is actually
+		 * isochronous.
+		 */
+		if (bfqq->dispatched == 0)
+			bfqq->soft_rt_next_start =
+				bfq_bfqq_softrt_next_start(bfqd, bfqq);
+		else {
+			/*
+			 * The application is still waiting for the
+			 * completion of one or more requests:
+			 * prevent it from possibly being incorrectly
+			 * deemed as soft real-time by setting its
+			 * soft_rt_next_start to infinity. In fact,
+			 * without this assignment, the application
+			 * would be incorrectly deemed as soft
+			 * real-time if:
+			 * 1) it issued a new request before the
+			 *    completion of all its in-flight
+			 *    requests, and
+			 * 2) at that time, its soft_rt_next_start
+			 *    happened to be in the past.
+			 */
+			bfqq->soft_rt_next_start =
+				bfq_infinity_from_now(jiffies);
+			/*
+			 * Schedule an update of soft_rt_next_start to when
+			 * the task may be discovered to be isochronous.
+			 */
+			bfq_mark_bfqq_softrt_update(bfqq);
+		}
+	}
+
 	bfq_log_bfqq(bfqd, bfqq,
 		"expire (%d, slow %d, num_disp %d, idle_win %d)", reason,
 		slow, bfqq->dispatched, bfq_bfqq_idle_window(bfqq));
@@ -1691,6 +1874,11 @@ static void bfq_init_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 
 	bfqq->wr_coeff = 1;
 	bfqq->last_wr_start_finish = 0;
+	/*
+	 * Set to the value for which bfqq will not be deemed as
+	 * soft rt when it becomes backlogged.
+	 */
+	bfqq->soft_rt_next_start = bfq_infinity_from_now(jiffies);
 }
 
 static struct bfq_queue *bfq_find_alloc_queue(struct bfq_data *bfqd,
@@ -2019,6 +2207,18 @@ static void bfq_completed_request(struct request_queue *q, struct request *rq)
 	}
 
 	/*
+	 * If we are waiting to discover whether the request pattern of the
+	 * task associated with the queue is actually isochronous, and
+	 * both requisites for this condition to hold are satisfied, then
+	 * compute soft_rt_next_start (see the comments to the function
+	 * bfq_bfqq_softrt_next_start()).
+	 */
+	if (bfq_bfqq_softrt_update(bfqq) && bfqq->dispatched == 0 &&
+	    RB_EMPTY_ROOT(&bfqq->sort_list))
+		bfqq->soft_rt_next_start =
+			bfq_bfqq_softrt_next_start(bfqd, bfqq);
+
+	/*
 	 * If this is the in-service queue, check if it needs to be expired,
 	 * or if we want to idle in case it has no pending requests.
 	 */
@@ -2345,9 +2545,16 @@ static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 	bfqd->low_latency = true;
 
 	bfqd->bfq_wr_coeff = 20;
+	bfqd->bfq_wr_rt_max_time = msecs_to_jiffies(300);
 	bfqd->bfq_wr_max_time = 0;
 	bfqd->bfq_wr_min_idle_time = msecs_to_jiffies(2000);
 	bfqd->bfq_wr_min_inter_arr_async = msecs_to_jiffies(500);
+	bfqd->bfq_wr_max_softrt_rate = 7000; /*
+					      * Approximate rate required
+					      * to playback or record a
+					      * high-definition compressed
+					      * video.
+					      */
 
 	/*
 	 * Begin by assuming, optimistically, that the device peak rate is
@@ -2461,9 +2668,11 @@ SHOW_FUNCTION(bfq_timeout_sync_show, bfqd->bfq_timeout[BLK_RW_SYNC], 1);
 SHOW_FUNCTION(bfq_timeout_async_show, bfqd->bfq_timeout[BLK_RW_ASYNC], 1);
 SHOW_FUNCTION(bfq_low_latency_show, bfqd->low_latency, 0);
 SHOW_FUNCTION(bfq_wr_coeff_show, bfqd->bfq_wr_coeff, 0);
+SHOW_FUNCTION(bfq_wr_rt_max_time_show, bfqd->bfq_wr_rt_max_time, 1);
 SHOW_FUNCTION(bfq_wr_min_idle_time_show, bfqd->bfq_wr_min_idle_time, 1);
 SHOW_FUNCTION(bfq_wr_min_inter_arr_async_show, bfqd->bfq_wr_min_inter_arr_async,
 	1);
+SHOW_FUNCTION(bfq_wr_max_softrt_rate_show, bfqd->bfq_wr_max_softrt_rate, 0);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -2498,10 +2707,14 @@ STORE_FUNCTION(bfq_timeout_async_store, &bfqd->bfq_timeout[BLK_RW_ASYNC], 0,
 		INT_MAX, 1);
 STORE_FUNCTION(bfq_wr_coeff_store, &bfqd->bfq_wr_coeff, 1, INT_MAX, 0);
 STORE_FUNCTION(bfq_wr_max_time_store, &bfqd->bfq_wr_max_time, 0, INT_MAX, 1);
+STORE_FUNCTION(bfq_wr_rt_max_time_store, &bfqd->bfq_wr_rt_max_time, 0, INT_MAX,
+		1);
 STORE_FUNCTION(bfq_wr_min_idle_time_store, &bfqd->bfq_wr_min_idle_time, 0,
 		INT_MAX, 1);
 STORE_FUNCTION(bfq_wr_min_inter_arr_async_store,
 		&bfqd->bfq_wr_min_inter_arr_async, 0, INT_MAX, 1);
+STORE_FUNCTION(bfq_wr_max_softrt_rate_store, &bfqd->bfq_wr_max_softrt_rate, 0,
+		INT_MAX, 0);
 #undef STORE_FUNCTION
 
 /* do nothing for the moment */
@@ -2593,8 +2806,10 @@ static struct elv_fs_entry bfq_attrs[] = {
 	BFQ_ATTR(low_latency),
 	BFQ_ATTR(wr_coeff),
 	BFQ_ATTR(wr_max_time),
+	BFQ_ATTR(wr_rt_max_time),
 	BFQ_ATTR(wr_min_idle_time),
 	BFQ_ATTR(wr_min_inter_arr_async),
+	BFQ_ATTR(wr_max_softrt_rate),
 	BFQ_ATTR(weights),
 	__ATTR_NULL
 };
diff --git a/block/bfq.h b/block/bfq.h
index 3ce9100..5fa8b34 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -185,6 +185,17 @@ struct bfq_group;
  *                        the @bfq-queue is being weight-raised, otherwise
  *                        finish time of the last weight-raising period
  * @wr_cur_max_time: current max raising time for this queue
+ * @soft_rt_next_start: minimum time instant such that, only if a new
+ *                      request is enqueued after this time instant in an
+ *                      idle @bfq_queue with no outstanding requests, then
+ *                      the task associated with the queue it is deemed as
+ *                      soft real-time (see the comments to the function
+ *                      bfq_bfqq_softrt_next_start())
+ * @last_idle_bklogged: time of the last transition of the @bfq_queue from
+ *                      idle to backlogged
+ * @service_from_backlogged: cumulative service received from the @bfq_queue
+ *                           since the last transition from idle to
+ *                           backlogged
  *
  * A bfq_queue is a leaf request queue; it can be associated with an
  * io_context or more, if it is async. @cgroup holds a reference to the
@@ -224,8 +235,11 @@ struct bfq_queue {
 
 	/* weight-raising fields */
 	unsigned long wr_cur_max_time;
+	unsigned long soft_rt_next_start;
 	unsigned long last_wr_start_finish;
 	unsigned int wr_coeff;
+	unsigned long last_idle_bklogged;
+	unsigned long service_from_backlogged;
 };
 
 /**
@@ -309,12 +323,15 @@ enum bfq_device_speed {
  * @bfq_wr_coeff: Maximum factor by which the weight of a weight-raised
  *                queue is multiplied
  * @bfq_wr_max_time: maximum duration of a weight-raising period (jiffies)
+ * @bfq_wr_rt_max_time: maximum duration for soft real-time processes
  * @bfq_wr_min_idle_time: minimum idle period after which weight-raising
  *			  may be reactivated for a queue (in jiffies)
  * @bfq_wr_min_inter_arr_async: minimum period between request arrivals
  *				after which weight-raising may be
  *				reactivated for an already busy queue
  *				(in jiffies)
+ * @bfq_wr_max_softrt_rate: max service-rate for a soft real-time queue,
+ *			    sectors per seconds
  * @RT_prod: cached value of the product R*T used for computing the maximum
  *	     duration of the weight raising automatically
  * @device_speed: device-speed class for the low-latency heuristic
@@ -372,8 +389,10 @@ struct bfq_data {
 	/* parameters of the low_latency heuristics */
 	unsigned int bfq_wr_coeff;
 	unsigned int bfq_wr_max_time;
+	unsigned int bfq_wr_rt_max_time;
 	unsigned int bfq_wr_min_idle_time;
 	unsigned long bfq_wr_min_inter_arr_async;
+	unsigned int bfq_wr_max_softrt_rate;
 	u64 RT_prod;
 	enum bfq_device_speed device_speed;
 
@@ -393,6 +412,10 @@ enum bfqq_state_flags {
 					 * bfqq has proved to be slow and
 					 * seeky until budget timeout
 					 */
+	BFQ_BFQQ_FLAG_softrt_update,	/*
+					 * may need softrt-next-start
+					 * update
+					 */
 };
 
 #define BFQ_BFQQ_FNS(name)						\
@@ -418,6 +441,7 @@ BFQ_BFQQ_FNS(prio_changed);
 BFQ_BFQQ_FNS(sync);
 BFQ_BFQQ_FNS(budget_new);
 BFQ_BFQQ_FNS(constantly_seeky);
+BFQ_BFQQ_FNS(softrt_update);
 #undef BFQ_BFQQ_FNS
 
 /* Logging facilities. */
-- 
1.9.2
