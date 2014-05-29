From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 05/12] block,
	bfq: add more fairness to boost throughput and reduce latency
Date: Thu, 29 May 2014 11:05:36 +0200
Message-ID: <1401354343-5527-6-git-send-email-paolo.valente__41794.1276486546$1401354459$gmane$org@unimore.it>
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

We have found four sources of throughput loss and higher
latencies. First, write requests tend to starve read requests,
basically because, on one side, writes are slower than reads, whereas,
on the other side, storage devices confuse schedulers by deceptively
signaling the completion of write requests immediately after receiving
them. This patch addresses this issue by just throttling writes. In
particular, after a write request is dispatched for a queue, the
budget of the queue is decremented by the number of sectors to write,
multiplied by an (over)charge coefficient.

The current value of this coefficient, as well as the values of the
constants used in the following other changes, is the result of
our tuning with different devices.

The second source of problems is that some applications generate
really few and small, yet very far, random requests at the beginning
of a new I/O-bound phase. This causes the average seek distance,
computed using a low-pass filter, to remain high for a non-negligible
amount of time, even if then the application issues only sequential
requests. Hence, for a while, the queue associated with the
application is unavoidably detected as seeky (i.e., containing random
requests). The device-idling timeout is then set to a very low value
for the queue. This often caused a loss of throughput on rotational
devices, as well as an increased latency. In contrast, this patch
allows the device-idling timeout for a seeky queue to be set to a very
low value only if the associated process has either already consumed
at least a minimum fraction (1/8) of the maximum budget B_max, or
already proved to generate random requests systematically. In
particular, in the latter case the queue is flagged as "constantly
seeky".

Finally, the following additional BFQ mechanism causes throughput loss
and increased latencies in two further situations. When the in-service
queue is expired, BFQ also controls whether the queue has been "too
slow", i.e., has consumed its last-assigned budget at such a low rate
that it would have been impossible to consume all of it within the
maximum time slice T_max (Subsec. 3.5 in [1]). In this case, the queue
is always (over)charged the whole budget, to reduce its utilization of
the device, exactly as it happens with seeky queues. The description
of both the two situations in which this behavior causes problems and
the solution provided by this patch follows.

1. If too little time has elapsed since a process started doing
sequential I/O, then the positive effect on the throughput of its
sequential accesses may not have yet prevailed on the throughput loss
caused by the fact that a random access had to be performed to get to
the first sector requested by the process. For this reason, if a slow
queue is expired after receiving very little service (at most 1/8 of
the maximum budget), now it is not charged a full budget.

2. Because of ZBR, a queue may be deemed as slow when its associated
process is performing I/O on the slowest zones of a disk. However,
unless the process is truly too slow, not reducing the disk
utilization of the queue is more profitable in terms of disk
throughput than the opposite. For this reason now a queue is never
charged the whole budget if it has consumed at least a significant
part of it (2/3).

[1] P. Valente and M. Andreolini, "Improving Application
    Responsiveness with the BFQ Disk I/O Scheduler", Proceedings of
    the 5th Annual International Systems and Storage Conference
    (SYSTOR '12), June 2012.
    Slightly extended version:
http://www.algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-iosched.c | 50 +++++++++++++++++++++++++++++++++++++++++++++-----
 block/bfq.h         |  5 +++++
 2 files changed, 50 insertions(+), 5 deletions(-)

diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 2a4e03d..9e607a0 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -87,6 +87,13 @@ static int bfq_slice_idle = HZ / 125;
 static const int bfq_default_max_budget = 16 * 1024;
 static const int bfq_max_budget_async_rq = 4;
 
+/*
+ * Async to sync throughput distribution is controlled as follows:
+ * when an async request is served, the entity is charged the number
+ * of sectors of the request, multiplied by the factor below
+ */
+static const int bfq_async_charge_factor = 10;
+
 /* Default timeout values, in jiffies, approximating CFQ defaults. */
 static const int bfq_timeout_sync = HZ / 8;
 static int bfq_timeout_async = HZ / 25;
@@ -269,10 +276,12 @@ static struct request *bfq_find_next_rq(struct bfq_data *bfqd,
 	return bfq_choose_req(bfqd, next, prev, blk_rq_pos(last));
 }
 
+/* see the definition of bfq_async_charge_factor for details */
 static inline unsigned long bfq_serv_to_charge(struct request *rq,
 					       struct bfq_queue *bfqq)
 {
-	return blk_rq_sectors(rq);
+	return blk_rq_sectors(rq) *
+		(1 + ((!bfq_bfqq_sync(bfqq)) * bfq_async_charge_factor));
 }
 
 /**
@@ -565,13 +574,21 @@ static void bfq_arm_slice_timer(struct bfq_data *bfqd)
 	 * We don't want to idle for seeks, but we do want to allow
 	 * fair distribution of slice time for a process doing back-to-back
 	 * seeks. So allow a little bit of time for him to submit a new rq.
+	 *
+	 * To prevent processes with (partly) seeky workloads from
+	 * being too ill-treated, grant them a small fraction of the
+	 * assigned budget before reducing the waiting time to
+	 * BFQ_MIN_TT. This happened to help reduce latency.
 	 */
 	sl = bfqd->bfq_slice_idle;
 	/*
-	 * Grant only minimum idle time if the queue has been seeky for long
-	 * enough.
+	 * Grant only minimum idle time if the queue either has been seeky for
+	 * long enough or has already proved to be constantly seeky.
 	 */
-	if (bfq_sample_valid(bfqq->seek_samples) && BFQQ_SEEKY(bfqq))
+	if (bfq_sample_valid(bfqq->seek_samples) &&
+	    ((BFQQ_SEEKY(bfqq) && bfqq->entity.service >
+				  bfq_max_budget(bfqq->bfqd) / 8) ||
+	      bfq_bfqq_constantly_seeky(bfqq)))
 		sl = min(sl, msecs_to_jiffies(BFQ_MIN_TT));
 	bfqd->last_idling_start = ktime_get();
 	mod_timer(&bfqd->idle_slice_timer, jiffies + sl);
@@ -889,6 +906,16 @@ static int bfq_update_peak_rate(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 	}
 
 	/*
+	 * If the process has been served for a too short time
+	 * interval to let its possible sequential accesses prevail on
+	 * the initial seek time needed to move the disk head on the
+	 * first sector it requested, then give the process a chance
+	 * and for the moment return false.
+	 */
+	if (bfqq->entity.budget <= bfq_max_budget(bfqd) / 8)
+		return 0;
+
+	/*
 	 * A process is considered ``slow'' (i.e., seeky, so that we
 	 * cannot treat it fairly in the service domain, as it would
 	 * slow down too much the other processes) if, when a slice
@@ -954,10 +981,21 @@ static void bfq_bfqq_expire(struct bfq_data *bfqd,
 	/*
 	 * As above explained, 'punish' slow (i.e., seeky), timed-out
 	 * and async queues, to favor sequential sync workloads.
+	 *
+	 * Processes doing I/O in the slower disk zones will tend to be
+	 * slow(er) even if not seeky. Hence, since the estimated peak
+	 * rate is actually an average over the disk surface, these
+	 * processes may timeout just for bad luck. To avoid punishing
+	 * them we do not charge a full budget to a process that
+	 * succeeded in consuming at least 2/3 of its budget.
 	 */
-	if (slow || reason == BFQ_BFQQ_BUDGET_TIMEOUT)
+	if (slow || (reason == BFQ_BFQQ_BUDGET_TIMEOUT &&
+		     bfq_bfqq_budget_left(bfqq) >=  bfqq->entity.budget / 3))
 		bfq_bfqq_charge_full_budget(bfqq);
 
+	if (BFQQ_SEEKY(bfqq) && reason == BFQ_BFQQ_BUDGET_TIMEOUT)
+		bfq_mark_bfqq_constantly_seeky(bfqq);
+
 	bfq_log_bfqq(bfqd, bfqq,
 		"expire (%d, slow %d, num_disp %d, idle_win %d)", reason,
 		slow, bfqq->dispatched, bfq_bfqq_idle_window(bfqq));
@@ -1632,6 +1670,8 @@ static void bfq_rq_enqueued(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 
 	bfq_update_io_thinktime(bfqd, bic);
 	bfq_update_io_seektime(bfqd, bfqq, rq);
+	if (!BFQQ_SEEKY(bfqq))
+		bfq_clear_bfqq_constantly_seeky(bfqq);
 	if (bfqq->entity.service > bfq_max_budget(bfqd) / 8 ||
 	    !BFQQ_SEEKY(bfqq))
 		bfq_update_idle_window(bfqd, bfqq, bic);
diff --git a/block/bfq.h b/block/bfq.h
index a334eb4..ea5ecca 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -358,6 +358,10 @@ enum bfqq_state_flags {
 	BFQ_BFQQ_FLAG_prio_changed,	/* task priority has changed */
 	BFQ_BFQQ_FLAG_sync,		/* synchronous queue */
 	BFQ_BFQQ_FLAG_budget_new,	/* no completion with this budget */
+	BFQ_BFQQ_FLAG_constantly_seeky,	/*
+					 * bfqq has proved to be slow and
+					 * seeky until budget timeout
+					 */
 };
 
 #define BFQ_BFQQ_FNS(name)						\
@@ -382,6 +386,7 @@ BFQ_BFQQ_FNS(idle_window);
 BFQ_BFQQ_FNS(prio_changed);
 BFQ_BFQQ_FNS(sync);
 BFQ_BFQQ_FNS(budget_new);
+BFQ_BFQQ_FNS(constantly_seeky);
 #undef BFQ_BFQQ_FNS
 
 /* Logging facilities. */
-- 
1.9.2
