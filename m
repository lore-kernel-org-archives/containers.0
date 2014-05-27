From: paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC RESEND 05/14] block, bfq: improve throughput boosting
Date: Tue, 27 May 2014 14:42:29 +0200
Message-ID: <1401194558-5283-6-git-send-email-paolo.valente@unimore.it>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401194558-5283-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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

From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>

The feedback-loop algorithm used by BFQ to compute queue (process)
budgets is basically a set of three update rules, one for each of the
main reasons why a queue may be expired. If many processes suddenly
switch from sporadic I/O to greedy and sequential I/O, then these
rules are quite slow to assign large budgets to these processes, and
hence to achieve a high throughput. On the opposite side, BFQ assigns
the maximum possible budget B_max to a just-created queue. This allows
a high throughput to be achieved immediately if the associated process
is I/O-bound and performs sequential I/O from the beginning. But it
also increases the worst-case latency experienced by the first
requests issued by the process, because the larger the budget of a
queue waiting for service is, the later the queue will be served by
B-WF2Q+ (Subsec 3.3 in [1]). This is detrimental for an interactive or
soft real-time application.

To tackle these throughput and latency problems, on one hand this
patch changes the initial budget value to B_max/2. On the other hand,
it re-tunes the three rules, adopting a more aggressive,
multiplicative increase/linear decrease scheme. This scheme trades
latency for throughput more than before, and tends to assign large
budgets quickly to processes that are or become I/O-bound. For two of
the expiration reasons, the new version of the rules also contains
some more little improvements, briefly described below.

*No more backlog.* In this case, the budget was larger than the number
of sectors actually read/written by the process before it stopped
doing I/O. Hence, to reduce latency for the possible future I/O
requests of the process, the old rule simply set the next budget to
the number of sectors actually consumed by the process. However, if
there are still outstanding requests, then the process may have not
yet issued its next request just because it is still waiting for the
completion of some of the still outstanding ones. If this sub-case
holds true, then the new rule, instead of decreasing the budget,
doubles it, proactively, in the hope that: 1) a larger budget will fit
the actual needs of the process, and 2) the process is sequential and
hence a higher throughput will be achieved by serving the process
longer after granting it access to the device.

*Budget timeout*. The original rule set the new budget to the maximum
value B_max, to maximize throughput and let all processes experiencing
budget timeouts receive the same share of the device time. In our
experiments we verified that this sudden jump to B_max did not provide
sensible benefits; rather it increased the latency of processes
performing sporadic and short I/O. The new rule only doubles the
budget.

[1] P. Valente and M. Andreolini, "Improving Application
    Responsiveness with the BFQ Disk I/O Scheduler", Proceedings of
    the 5th Annual International Systems and Storage Conference
    (SYSTOR '12), June 2012.
    Slightly extended version:
http://www.algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-cgroup.c  |  2 ++
 block/bfq-ioc.c     |  2 ++
 block/bfq-iosched.c | 88 ++++++++++++++++++++++++++++-------------------------
 block/bfq-sched.c   |  2 ++
 block/bfq.h         |  2 ++
 5 files changed, 55 insertions(+), 41 deletions(-)

diff --git a/block/bfq-cgroup.c b/block/bfq-cgroup.c
index 00a7a1b..805fe5e 100644
--- a/block/bfq-cgroup.c
+++ b/block/bfq-cgroup.c
@@ -7,6 +7,8 @@
  * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
  *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
  *
+ * Copyright (C) 2010 Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
  * Licensed under the GPL-2 as detailed in the accompanying COPYING.BFQ
  * file.
  */
diff --git a/block/bfq-ioc.c b/block/bfq-ioc.c
index adfb5a1..7f6b000 100644
--- a/block/bfq-ioc.c
+++ b/block/bfq-ioc.c
@@ -6,6 +6,8 @@
  *
  * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
  *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Copyright (C) 2010 Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
  */
 
 /**
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index b2cbfce..49ff1da 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -7,6 +7,8 @@
  * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
  *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
  *
+ * Copyright (C) 2010 Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
  * Licensed under the GPL-2 as detailed in the accompanying COPYING.BFQ
  * file.
  *
@@ -101,9 +103,6 @@ struct kmem_cache *bfq_pool;
 #define BFQQ_SEEK_THR	 (sector_t)(8 * 1024)
 #define BFQQ_SEEKY(bfqq) ((bfqq)->seek_mean > BFQQ_SEEK_THR)
 
-/* Budget feedback step. */
-#define BFQ_BUDGET_STEP         128
-
 /* Min samples used for peak rate estimation (for autotuning). */
 #define BFQ_PEAK_RATE_SAMPLES	32
 
@@ -537,36 +536,6 @@ static inline unsigned long bfq_max_budget(struct bfq_data *bfqd)
 		return bfqd->bfq_max_budget;
 }
 
- /*
- * bfq_default_budget - return the default budget for @bfqq on @bfqd.
- * @bfqd: the device descriptor.
- * @bfqq: the queue to consider.
- *
- * We use 3/4 of the @bfqd maximum budget as the default value
- * for the max_budget field of the queues.  This lets the feedback
- * mechanism to start from some middle ground, then the behavior
- * of the process will drive the heuristics towards high values, if
- * it behaves as a greedy sequential reader, or towards small values
- * if it shows a more intermittent behavior.
- */
-static unsigned long bfq_default_budget(struct bfq_data *bfqd,
-					struct bfq_queue *bfqq)
-{
-	unsigned long budget;
-
-	/*
-	 * When we need an estimate of the peak rate we need to avoid
-	 * to give budgets that are too short due to previous measurements.
-	 * So, in the first 10 assignments use a ``safe'' budget value.
-	 */
-	if (bfqd->budgets_assigned < 194 && bfqd->bfq_user_max_budget == 0)
-		budget = bfq_default_max_budget;
-	else
-		budget = bfqd->bfq_max_budget;
-
-	return budget - budget / 4;
-}
-
 /*
  * Return min budget, which is a fraction of the current or default
  * max budget (trying with 1/32)
@@ -730,13 +699,51 @@ static void __bfq_bfqq_recalc_budget(struct bfq_data *bfqd,
 		 * for throughput.
 		 */
 		case BFQ_BFQQ_TOO_IDLE:
-			if (budget > min_budget + BFQ_BUDGET_STEP)
-				budget -= BFQ_BUDGET_STEP;
-			else
-				budget = min_budget;
+			/*
+			 * This is the only case where we may reduce
+			 * the budget: if there is no request of the
+			 * process still waiting for completion, then
+			 * we assume (tentatively) that the timer has
+			 * expired because the batch of requests of
+			 * the process could have been served with a
+			 * smaller budget.  Hence, betting that
+			 * process will behave in the same way when it
+			 * becomes backlogged again, we reduce its
+			 * next budget.  As long as we guess right,
+			 * this budget cut reduces the latency
+			 * experienced by the process.
+			 *
+			 * However, if there are still outstanding
+			 * requests, then the process may have not yet
+			 * issued its next request just because it is
+			 * still waiting for the completion of some of
+			 * the still outstanding ones.  So in this
+			 * subcase we do not reduce its budget, on the
+			 * contrary we increase it to possibly boost
+			 * the throughput, as discussed in the
+			 * comments to the BUDGET_TIMEOUT case.
+			 */
+			if (bfqq->dispatched > 0) /* still outstanding reqs */
+				budget = min(budget * 2, bfqd->bfq_max_budget);
+			else {
+				if (budget > 5 * min_budget)
+					budget -= 4 * min_budget;
+				else
+					budget = min_budget;
+			}
 			break;
 		case BFQ_BFQQ_BUDGET_TIMEOUT:
-			budget = bfq_default_budget(bfqd, bfqq);
+			/*
+			 * We double the budget here because: 1) it
+			 * gives the chance to boost the throughput if
+			 * this is not a seeky process (which may have
+			 * bumped into this timeout because of, e.g.,
+			 * ZBR), 2) together with charge_full_budget
+			 * it helps give seeky processes higher
+			 * timestamps, and hence be served less
+			 * frequently.
+			 */
+			budget = min(budget * 2, bfqd->bfq_max_budget);
 			break;
 		case BFQ_BFQQ_BUDGET_EXHAUSTED:
 			/*
@@ -748,8 +755,7 @@ static void __bfq_bfqq_recalc_budget(struct bfq_data *bfqd,
 			 * definitely increase the budget of this good
 			 * candidate to boost the disk throughput.
 			 */
-			budget = min(budget + 8 * BFQ_BUDGET_STEP,
-				     bfqd->bfq_max_budget);
+			budget = min(budget * 4, bfqd->bfq_max_budget);
 			break;
 		case BFQ_BFQQ_NO_MORE_REQUESTS:
 		       /*
@@ -1408,7 +1414,7 @@ static void bfq_init_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 	}
 
 	/* Tentative initial value to trade off between thr and lat */
-	bfqq->max_budget = bfq_default_budget(bfqd, bfqq);
+	bfqq->max_budget = (2 * bfq_max_budget(bfqd)) / 3;
 	bfqq->pid = pid;
 }
 
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
index 8801b6c..075e472 100644
--- a/block/bfq-sched.c
+++ b/block/bfq-sched.c
@@ -6,6 +6,8 @@
  *
  * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
  *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Copyright (C) 2010 Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
  */
 
 #ifdef CONFIG_CGROUP_BFQIO
diff --git a/block/bfq.h b/block/bfq.h
index b982567..a334eb4 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -6,6 +6,8 @@
  *
  * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
  *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Copyright (C) 2010 Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
  */
 
 #ifndef _BFQ_H
-- 
1.9.2
