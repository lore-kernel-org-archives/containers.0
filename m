From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 01/12] block: introduce the BFQ-v0 I/O
	scheduler
Date: Thu, 29 May 2014 11:05:32 +0200
Message-ID: <1401354343-5527-2-git-send-email-paolo.valente@unimore.it>
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

From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

BFQ is a proportional-share I/O scheduler, whose general structure,
plus a lot of code, are borrowed from CFQ.

- Each process doing I/O on a device is associated with a weight and a
  (bfq_)queue.

- BFQ grants exclusive access to the device, for a while, to one queue
  (process) at a time, and implements this service model by
  associating every queue with a budget, measured in number of
  sectors.

  - After a queue is granted access to the device, the budget of the
    queue is decremented, on each request dispatch, by the size of the
    request.

  - The in-service queue is expired, i.e., its service is suspended,
    only if one of the following events occurs: 1) the queue finishes
    its budget, 2) the queue empties, 3) a "budget timeout" fires.

    - The budget timeout prevents processes doing random I/O from
      holding the device for too long and dramatically reducing
      throughput.

    - Actually, as in CFQ, a queue associated with a process issuing
      sync requests may not be expired immediately when it empties. In
      contrast, BFQ may idle the device for a short time interval,
      giving the process the chance to go on being served if it issues
      a new request in time. Device idling typically boosts the
      throughput on rotational devices, if processes do synchronous
      and sequential I/O. Besides, under BFQ, device idling is also
      instrumental in guaranteeing the desired throughput fraction to
      processes issuing sync requests (see [1] for details).

  - Queues are scheduled according to a variant of WF2Q+, named
    B-WF2Q+, and implemented using an augmented rb-tree to preserve an
    O(log N) overall complexity.  See [1] for more details. B-WF2Q+ is
    also ready for hierarchical scheduling. However, for a cleaner
    logical breakdown, the code that enables and completes
    hierarchical support is provided in patch 4, which focuses exactly
    on this feature.

  - B-WF2Q+ guarantees a tight deviation with respect to an ideal,
    perfectly fair, and smooth service. In particular, B-WF2Q+
    guarantees that each queue receives a fraction of the device
    throughput proportional to its weight, even if the throughput
    fluctuates, and regardless of: the device parameters, the current
    workload and the budgets assigned to the queue.

  - The last, budget-independence, property (although probably
    counterintuitive in the first place) is definitely beneficial, for
    the following reasons.

    - First, with any proportional-share scheduler, the maximum
      deviation with respect to an ideal service is proportional to
      the maximum budget (slice) assigned to queues. As a consequence,
      BFQ can keep this deviation tight not only because of the
      accurate service of B-WF2Q+, but also because BFQ *does not*
      need to assign a larger budget to a queue to let the queue
      receive a higher fraction of the device throughput.

    - Second, BFQ is free to choose, for every process (queue), the
      budget that best fits the needs of the process, or best
      leverages the I/O pattern of the process. In particular, BFQ
      updates queue budgets with a simple feedback-loop algorithm that
      allows a high throughput to be achieved, while still providing
      tight latency guarantees to time-sensitive applications. When
      the in-service queue expires, this algorithm computes the next
      budget of the queue so as to:

      - Let large budgets be eventually assigned to the queues
        associated with I/O-bound applications performing sequential
        I/O: in fact, the longer these applications are served once
        got access to the device, the higher the throughput is.

      - Let small budgets be eventually assigned to the queues
        associated with time-sensitive applications (which typically
        perform sporadic and short I/O), because, the smaller the
        budget assigned to a queue waiting for service is, the sooner
        B-WF2Q+ will serve that queue (Subsec 3.3 in [1]).

- Weights can be assigned to processes only indirectly, through I/O
  priorities, and according to the relation: weight = IOPRIO_BE_NR -
  ioprio. The next two patches provide instead a cgroups interface
  through which weights can be assigned explicitly.

- ioprio classes are served in strict priority order, i.e.,
  lower-priority queues are not served as long as there are
  higher-priority queues.  Among queues in the same class, the
  bandwidth is distributed in proportion to the weight of each
  queue. A very thin extra bandwidth is however guaranteed to the Idle
  class, to prevent it from starving.

[1] P. Valente and M. Andreolini, "Improving Application
    Responsiveness with the BFQ Disk I/O Scheduler", Proceedings of
    the 5th Annual International Systems and Storage Conference
    (SYSTOR '12), June 2012.
    Slightly extended version:
http://www.algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf

Signed-off-by: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/Kconfig.iosched |   19 +
 block/Makefile        |    1 +
 block/bfq-ioc.c       |   34 +
 block/bfq-iosched.c   | 2297 +++++++++++++++++++++++++++++++++++++++++++++++++
 block/bfq-sched.c     |  936 ++++++++++++++++++++
 block/bfq.h           |  467 ++++++++++
 6 files changed, 3754 insertions(+)
 create mode 100644 block/bfq-ioc.c
 create mode 100644 block/bfq-iosched.c
 create mode 100644 block/bfq-sched.c
 create mode 100644 block/bfq.h

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 421bef9..8f98cc7 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -39,6 +39,15 @@ config CFQ_GROUP_IOSCHED
 	---help---
 	  Enable group IO scheduling in CFQ.
 
+config IOSCHED_BFQ
+	tristate "BFQ I/O scheduler"
+	default n
+	---help---
+	  The BFQ I/O scheduler tries to distribute bandwidth among all
+	  processes according to their weights.
+	  It aims at distributing the bandwidth as desired, regardless
+	  of the disk parameters and with any workload.
+
 choice
 	prompt "Default I/O scheduler"
 	default DEFAULT_CFQ
@@ -52,6 +61,15 @@ choice
 	config DEFAULT_CFQ
 		bool "CFQ" if IOSCHED_CFQ=y
 
+	config DEFAULT_BFQ
+		bool "BFQ" if IOSCHED_BFQ=y
+		help
+		  Selects BFQ as the default I/O scheduler which will be
+		  used by default for all block devices.
+		  The BFQ I/O scheduler aims at distributing the bandwidth
+		  as desired, regardless of the disk parameters and with
+		  any workload.
+
 	config DEFAULT_NOOP
 		bool "No-op"
 
@@ -61,6 +79,7 @@ config DEFAULT_IOSCHED
 	string
 	default "deadline" if DEFAULT_DEADLINE
 	default "cfq" if DEFAULT_CFQ
+	default "bfq" if DEFAULT_BFQ
 	default "noop" if DEFAULT_NOOP
 
 endmenu
diff --git a/block/Makefile b/block/Makefile
index 20645e8..cbd83fb 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_BLK_DEV_THROTTLING)	+= blk-throttle.o
 obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
 obj-$(CONFIG_IOSCHED_DEADLINE)	+= deadline-iosched.o
 obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
+obj-$(CONFIG_IOSCHED_BFQ)	+= bfq-iosched.o
 
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
diff --git a/block/bfq-ioc.c b/block/bfq-ioc.c
new file mode 100644
index 0000000..adfb5a1
--- /dev/null
+++ b/block/bfq-ioc.c
@@ -0,0 +1,34 @@
+/*
+ * BFQ: I/O context handling.
+ *
+ * Based on ideas and code from CFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ */
+
+/**
+ * icq_to_bic - convert iocontext queue structure to bfq_io_cq.
+ * @icq: the iocontext queue.
+ */
+static inline struct bfq_io_cq *icq_to_bic(struct io_cq *icq)
+{
+	/* bic->icq is the first member, %NULL will convert to %NULL */
+	return container_of(icq, struct bfq_io_cq, icq);
+}
+
+/**
+ * bfq_bic_lookup - search into @ioc a bic associated to @bfqd.
+ * @bfqd: the lookup key.
+ * @ioc: the io_context of the process doing I/O.
+ *
+ * Queue lock must be held.
+ */
+static inline struct bfq_io_cq *bfq_bic_lookup(struct bfq_data *bfqd,
+					       struct io_context *ioc)
+{
+	if (ioc)
+		return icq_to_bic(ioc_lookup_icq(ioc, bfqd->queue));
+	return NULL;
+}
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
new file mode 100644
index 0000000..01a98be
--- /dev/null
+++ b/block/bfq-iosched.c
@@ -0,0 +1,2297 @@
+/*
+ * Budget Fair Queueing (BFQ) disk scheduler.
+ *
+ * Based on ideas and code from CFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Licensed under the GPL-2 as detailed in the accompanying COPYING.BFQ
+ * file.
+ *
+ * BFQ is a proportional-share storage-I/O scheduling algorithm based on
+ * the slice-by-slice service scheme of CFQ. But BFQ assigns budgets,
+ * measured in number of sectors, to processes instead of time slices. The
+ * device is not granted to the in-service process for a given time slice,
+ * but until it has exhausted its assigned budget. This change from the time
+ * to the service domain allows BFQ to distribute the device throughput
+ * among processes as desired, without any distortion due to ZBR, workload
+ * fluctuations or other factors. BFQ uses an ad hoc internal scheduler,
+ * called B-WF2Q+, to schedule processes according to their budgets. More
+ * precisely, BFQ schedules queues associated to processes. Thanks to the
+ * accurate policy of B-WF2Q+, BFQ can afford to assign high budgets to
+ * I/O-bound processes issuing sequential requests (to boost the
+ * throughput), and yet guarantee a relatively low latency to interactive
+ * applications.
+ *
+ * BFQ is described in [1], where also a reference to the initial, more
+ * theoretical paper on BFQ can be found. The interested reader can find
+ * in the latter paper full details on the main algorithm, as well as
+ * formulas of the guarantees and formal proofs of all the properties.
+ * With respect to the version of BFQ presented in these papers, this
+ * implementation adds a hierarchical extension based on H-WF2Q+.
+ *
+ * B-WF2Q+ is based on WF2Q+, that is described in [2], together with
+ * H-WF2Q+, while the augmented tree used to implement B-WF2Q+ with O(log N)
+ * complexity derives from the one introduced with EEVDF in [3].
+ *
+ * [1] P. Valente and M. Andreolini, ``Improving Application Responsiveness
+ *     with the BFQ Disk I/O Scheduler'',
+ *     Proceedings of the 5th Annual International Systems and Storage
+ *     Conference (SYSTOR '12), June 2012.
+ *
+ * http://algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf
+ *
+ * [2] Jon C.R. Bennett and H. Zhang, ``Hierarchical Packet Fair Queueing
+ *     Algorithms,'' IEEE/ACM Transactions on Networking, 5(5):675-689,
+ *     Oct 1997.
+ *
+ * http://www.cs.cmu.edu/~hzhang/papers/TON-97-Oct.ps.gz
+ *
+ * [3] I. Stoica and H. Abdel-Wahab, ``Earliest Eligible Virtual Deadline
+ *     First: A Flexible and Accurate Mechanism for Proportional Share
+ *     Resource Allocation,'' technical report.
+ *
+ * http://www.cs.berkeley.edu/~istoica/papers/eevdf-tr-95.pdf
+ */
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/blkdev.h>
+#include <linux/cgroup.h>
+#include <linux/elevator.h>
+#include <linux/jiffies.h>
+#include <linux/rbtree.h>
+#include <linux/ioprio.h>
+#include "bfq.h"
+#include "blk.h"
+
+/*
+ * Array of async queues for all the processes, one queue
+ * per ioprio value per ioprio_class.
+ */
+struct bfq_queue *async_bfqq[2][IOPRIO_BE_NR];
+/* Async queue for the idle class (ioprio is ignored) */
+struct bfq_queue *async_idle_bfqq;
+
+/* Max number of dispatches in one round of service. */
+static const int bfq_quantum = 4;
+
+/* Expiration time of sync (0) and async (1) requests, in jiffies. */
+static const int bfq_fifo_expire[2] = { HZ / 4, HZ / 8 };
+
+/* Maximum backwards seek, in KiB. */
+static const int bfq_back_max = 16 * 1024;
+
+/* Penalty of a backwards seek, in number of sectors. */
+static const int bfq_back_penalty = 2;
+
+/* Idling period duration, in jiffies. */
+static int bfq_slice_idle = HZ / 125;
+
+/* Default maximum budget values, in sectors and number of requests. */
+static const int bfq_default_max_budget = 16 * 1024;
+static const int bfq_max_budget_async_rq = 4;
+
+/* Default timeout values, in jiffies, approximating CFQ defaults. */
+static const int bfq_timeout_sync = HZ / 8;
+static int bfq_timeout_async = HZ / 25;
+
+struct kmem_cache *bfq_pool;
+
+/* Below this threshold (in ms), we consider thinktime immediate. */
+#define BFQ_MIN_TT		2
+
+/* hw_tag detection: parallel requests threshold and min samples needed. */
+#define BFQ_HW_QUEUE_THRESHOLD	4
+#define BFQ_HW_QUEUE_SAMPLES	32
+
+#define BFQQ_SEEK_THR	 (sector_t)(8 * 1024)
+#define BFQQ_SEEKY(bfqq) ((bfqq)->seek_mean > BFQQ_SEEK_THR)
+
+/* Budget feedback step. */
+#define BFQ_BUDGET_STEP         128
+
+/* Min samples used for peak rate estimation (for autotuning). */
+#define BFQ_PEAK_RATE_SAMPLES	32
+
+/* Shift used for peak rate fixed precision calculations. */
+#define BFQ_RATE_SHIFT		16
+
+#define BFQ_SERVICE_TREE_INIT	((struct bfq_service_tree)		\
+				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
+
+#define RQ_BIC(rq)		((struct bfq_io_cq *) (rq)->elv.priv[0])
+#define RQ_BFQQ(rq)		((rq)->elv.priv[1])
+
+static inline void bfq_schedule_dispatch(struct bfq_data *bfqd);
+
+#include "bfq-ioc.c"
+#include "bfq-sched.c"
+
+#define bfq_class_idle(bfqq)	((bfqq)->entity.ioprio_class ==\
+				 IOPRIO_CLASS_IDLE)
+#define bfq_class_rt(bfqq)	((bfqq)->entity.ioprio_class ==\
+				 IOPRIO_CLASS_RT)
+
+#define bfq_sample_valid(samples)	((samples) > 80)
+
+/*
+ * We regard a request as SYNC, if either it's a read or has the SYNC bit
+ * set (in which case it could also be a direct WRITE).
+ */
+static inline int bfq_bio_sync(struct bio *bio)
+{
+	if (bio_data_dir(bio) == READ || (bio->bi_rw & REQ_SYNC))
+		return 1;
+
+	return 0;
+}
+
+/*
+ * Scheduler run of queue, if there are requests pending and no one in the
+ * driver that will restart queueing.
+ */
+static inline void bfq_schedule_dispatch(struct bfq_data *bfqd)
+{
+	if (bfqd->queued != 0) {
+		bfq_log(bfqd, "schedule dispatch");
+		kblockd_schedule_work(bfqd->queue, &bfqd->unplug_work);
+	}
+}
+
+/*
+ * Lifted from AS - choose which of rq1 and rq2 that is best served now.
+ * We choose the request that is closesr to the head right now.  Distance
+ * behind the head is penalized and only allowed to a certain extent.
+ */
+static struct request *bfq_choose_req(struct bfq_data *bfqd,
+				      struct request *rq1,
+				      struct request *rq2,
+				      sector_t last)
+{
+	sector_t s1, s2, d1 = 0, d2 = 0;
+	unsigned long back_max;
+#define BFQ_RQ1_WRAP	0x01 /* request 1 wraps */
+#define BFQ_RQ2_WRAP	0x02 /* request 2 wraps */
+	unsigned wrap = 0; /* bit mask: requests behind the disk head? */
+
+	if (rq1 == NULL || rq1 == rq2)
+		return rq2;
+	if (rq2 == NULL)
+		return rq1;
+
+	if (rq_is_sync(rq1) && !rq_is_sync(rq2))
+		return rq1;
+	else if (rq_is_sync(rq2) && !rq_is_sync(rq1))
+		return rq2;
+	if ((rq1->cmd_flags & REQ_META) && !(rq2->cmd_flags & REQ_META))
+		return rq1;
+	else if ((rq2->cmd_flags & REQ_META) && !(rq1->cmd_flags & REQ_META))
+		return rq2;
+
+	s1 = blk_rq_pos(rq1);
+	s2 = blk_rq_pos(rq2);
+
+	/*
+	 * By definition, 1KiB is 2 sectors.
+	 */
+	back_max = bfqd->bfq_back_max * 2;
+
+	/*
+	 * Strict one way elevator _except_ in the case where we allow
+	 * short backward seeks which are biased as twice the cost of a
+	 * similar forward seek.
+	 */
+	if (s1 >= last)
+		d1 = s1 - last;
+	else if (s1 + back_max >= last)
+		d1 = (last - s1) * bfqd->bfq_back_penalty;
+	else
+		wrap |= BFQ_RQ1_WRAP;
+
+	if (s2 >= last)
+		d2 = s2 - last;
+	else if (s2 + back_max >= last)
+		d2 = (last - s2) * bfqd->bfq_back_penalty;
+	else
+		wrap |= BFQ_RQ2_WRAP;
+
+	/* Found required data */
+
+	/*
+	 * By doing switch() on the bit mask "wrap" we avoid having to
+	 * check two variables for all permutations: --> faster!
+	 */
+	switch (wrap) {
+	case 0: /* common case for CFQ: rq1 and rq2 not wrapped */
+		if (d1 < d2)
+			return rq1;
+		else if (d2 < d1)
+			return rq2;
+		else {
+			if (s1 >= s2)
+				return rq1;
+			else
+				return rq2;
+		}
+
+	case BFQ_RQ2_WRAP:
+		return rq1;
+	case BFQ_RQ1_WRAP:
+		return rq2;
+	case (BFQ_RQ1_WRAP|BFQ_RQ2_WRAP): /* both rqs wrapped */
+	default:
+		/*
+		 * Since both rqs are wrapped,
+		 * start with the one that's further behind head
+		 * (--> only *one* back seek required),
+		 * since back seek takes more time than forward.
+		 */
+		if (s1 <= s2)
+			return rq1;
+		else
+			return rq2;
+	}
+}
+
+static struct request *bfq_find_next_rq(struct bfq_data *bfqd,
+					struct bfq_queue *bfqq,
+					struct request *last)
+{
+	struct rb_node *rbnext = rb_next(&last->rb_node);
+	struct rb_node *rbprev = rb_prev(&last->rb_node);
+	struct request *next = NULL, *prev = NULL;
+
+	if (rbprev != NULL)
+		prev = rb_entry_rq(rbprev);
+
+	if (rbnext != NULL)
+		next = rb_entry_rq(rbnext);
+	else {
+		rbnext = rb_first(&bfqq->sort_list);
+		if (rbnext && rbnext != &last->rb_node)
+			next = rb_entry_rq(rbnext);
+	}
+
+	return bfq_choose_req(bfqd, next, prev, blk_rq_pos(last));
+}
+
+static inline unsigned long bfq_serv_to_charge(struct request *rq,
+					       struct bfq_queue *bfqq)
+{
+	return blk_rq_sectors(rq);
+}
+
+/**
+ * bfq_updated_next_req - update the queue after a new next_rq selection.
+ * @bfqd: the device data the queue belongs to.
+ * @bfqq: the queue to update.
+ *
+ * If the first request of a queue changes we make sure that the queue
+ * has enough budget to serve at least its first request (if the
+ * request has grown).  We do this because if the queue has not enough
+ * budget for its first request, it has to go through two dispatch
+ * rounds to actually get it dispatched.
+ */
+static void bfq_updated_next_req(struct bfq_data *bfqd,
+				 struct bfq_queue *bfqq)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+	struct request *next_rq = bfqq->next_rq;
+	unsigned long new_budget;
+
+	if (next_rq == NULL)
+		return;
+
+	if (bfqq == bfqd->in_service_queue)
+		/*
+		 * In order not to break guarantees, budgets cannot be
+		 * changed after an entity has been selected.
+		 */
+		return;
+
+	new_budget = max_t(unsigned long, bfqq->max_budget,
+			   bfq_serv_to_charge(next_rq, bfqq));
+	if (entity->budget != new_budget) {
+		entity->budget = new_budget;
+		bfq_log_bfqq(bfqd, bfqq, "updated next rq: new budget %lu",
+					 new_budget);
+		bfq_activate_bfqq(bfqd, bfqq);
+	}
+}
+
+static void bfq_add_request(struct request *rq)
+{
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+	struct bfq_entity *entity = &bfqq->entity;
+	struct bfq_data *bfqd = bfqq->bfqd;
+	struct request *next_rq, *prev;
+
+	bfq_log_bfqq(bfqd, bfqq, "add_request %d", rq_is_sync(rq));
+	bfqq->queued[rq_is_sync(rq)]++;
+	bfqd->queued++;
+
+	elv_rb_add(&bfqq->sort_list, rq);
+
+	/*
+	 * Check if this request is a better next-serve candidate.
+	 */
+	prev = bfqq->next_rq;
+	next_rq = bfq_choose_req(bfqd, bfqq->next_rq, rq, bfqd->last_position);
+	bfqq->next_rq = next_rq;
+
+	if (!bfq_bfqq_busy(bfqq)) {
+		entity->budget = max_t(unsigned long, bfqq->max_budget,
+				       bfq_serv_to_charge(next_rq, bfqq));
+		bfq_add_bfqq_busy(bfqd, bfqq);
+	} else {
+		if (prev != bfqq->next_rq)
+			bfq_updated_next_req(bfqd, bfqq);
+	}
+}
+
+static struct request *bfq_find_rq_fmerge(struct bfq_data *bfqd,
+					  struct bio *bio)
+{
+	struct task_struct *tsk = current;
+	struct bfq_io_cq *bic;
+	struct bfq_queue *bfqq;
+
+	bic = bfq_bic_lookup(bfqd, tsk->io_context);
+	if (bic == NULL)
+		return NULL;
+
+	bfqq = bic_to_bfqq(bic, bfq_bio_sync(bio));
+	if (bfqq != NULL)
+		return elv_rb_find(&bfqq->sort_list, bio_end_sector(bio));
+
+	return NULL;
+}
+
+static void bfq_activate_request(struct request_queue *q, struct request *rq)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+
+	bfqd->rq_in_driver++;
+	bfqd->last_position = blk_rq_pos(rq) + blk_rq_sectors(rq);
+	bfq_log(bfqd, "activate_request: new bfqd->last_position %llu",
+		(long long unsigned)bfqd->last_position);
+}
+
+static inline void bfq_deactivate_request(struct request_queue *q,
+					  struct request *rq)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+
+	bfqd->rq_in_driver--;
+}
+
+static void bfq_remove_request(struct request *rq)
+{
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+	struct bfq_data *bfqd = bfqq->bfqd;
+	const int sync = rq_is_sync(rq);
+
+	if (bfqq->next_rq == rq) {
+		bfqq->next_rq = bfq_find_next_rq(bfqd, bfqq, rq);
+		bfq_updated_next_req(bfqd, bfqq);
+	}
+
+	list_del_init(&rq->queuelist);
+	bfqq->queued[sync]--;
+	bfqd->queued--;
+	elv_rb_del(&bfqq->sort_list, rq);
+
+	if (RB_EMPTY_ROOT(&bfqq->sort_list)) {
+		if (bfq_bfqq_busy(bfqq) && bfqq != bfqd->in_service_queue)
+			bfq_del_bfqq_busy(bfqd, bfqq, 1);
+	}
+
+	if (rq->cmd_flags & REQ_META)
+		bfqq->meta_pending--;
+}
+
+static int bfq_merge(struct request_queue *q, struct request **req,
+		     struct bio *bio)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct request *__rq;
+
+	__rq = bfq_find_rq_fmerge(bfqd, bio);
+	if (__rq != NULL && elv_rq_merge_ok(__rq, bio)) {
+		*req = __rq;
+		return ELEVATOR_FRONT_MERGE;
+	}
+
+	return ELEVATOR_NO_MERGE;
+}
+
+static void bfq_merged_request(struct request_queue *q, struct request *req,
+			       int type)
+{
+	if (type == ELEVATOR_FRONT_MERGE &&
+	    rb_prev(&req->rb_node) &&
+	    blk_rq_pos(req) <
+	    blk_rq_pos(container_of(rb_prev(&req->rb_node),
+				    struct request, rb_node))) {
+		struct bfq_queue *bfqq = RQ_BFQQ(req);
+		struct bfq_data *bfqd = bfqq->bfqd;
+		struct request *prev, *next_rq;
+
+		/* Reposition request in its sort_list */
+		elv_rb_del(&bfqq->sort_list, req);
+		elv_rb_add(&bfqq->sort_list, req);
+		/* Choose next request to be served for bfqq */
+		prev = bfqq->next_rq;
+		next_rq = bfq_choose_req(bfqd, bfqq->next_rq, req,
+					 bfqd->last_position);
+		bfqq->next_rq = next_rq;
+		/*
+		 * If next_rq changes, update the queue's budget to fit
+		 * the new request.
+		 */
+		if (prev != bfqq->next_rq)
+			bfq_updated_next_req(bfqd, bfqq);
+	}
+}
+
+static void bfq_merged_requests(struct request_queue *q, struct request *rq,
+				struct request *next)
+{
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+
+	/*
+	 * Reposition in fifo if next is older than rq.
+	 */
+	if (!list_empty(&rq->queuelist) && !list_empty(&next->queuelist) &&
+	    time_before(next->fifo_time, rq->fifo_time)) {
+		list_move(&rq->queuelist, &next->queuelist);
+		rq->fifo_time = next->fifo_time;
+	}
+
+	if (bfqq->next_rq == next)
+		bfqq->next_rq = rq;
+
+	bfq_remove_request(next);
+}
+
+static int bfq_allow_merge(struct request_queue *q, struct request *rq,
+			   struct bio *bio)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct bfq_io_cq *bic;
+	struct bfq_queue *bfqq;
+
+	/*
+	 * Disallow merge of a sync bio into an async request.
+	 */
+	if (bfq_bio_sync(bio) && !rq_is_sync(rq))
+		return 0;
+
+	/*
+	 * Lookup the bfqq that this bio will be queued with. Allow
+	 * merge only if rq is queued there.
+	 * Queue lock is held here.
+	 */
+	bic = bfq_bic_lookup(bfqd, current->io_context);
+	if (bic == NULL)
+		return 0;
+
+	bfqq = bic_to_bfqq(bic, bfq_bio_sync(bio));
+	return bfqq == RQ_BFQQ(rq);
+}
+
+static void __bfq_set_in_service_queue(struct bfq_data *bfqd,
+				       struct bfq_queue *bfqq)
+{
+	if (bfqq != NULL) {
+		bfq_mark_bfqq_must_alloc(bfqq);
+		bfq_mark_bfqq_budget_new(bfqq);
+		bfq_clear_bfqq_fifo_expire(bfqq);
+
+		bfqd->budgets_assigned = (bfqd->budgets_assigned*7 + 256) / 8;
+
+		bfq_log_bfqq(bfqd, bfqq,
+			     "set_in_service_queue, cur-budget = %lu",
+			     bfqq->entity.budget);
+	}
+
+	bfqd->in_service_queue = bfqq;
+}
+
+/*
+ * Get and set a new queue for service.
+ */
+static struct bfq_queue *bfq_set_in_service_queue(struct bfq_data *bfqd)
+{
+	struct bfq_queue *bfqq = bfq_get_next_queue(bfqd);
+
+	__bfq_set_in_service_queue(bfqd, bfqq);
+	return bfqq;
+}
+
+/*
+ * If enough samples have been computed, return the current max budget
+ * stored in bfqd, which is dynamically updated according to the
+ * estimated disk peak rate; otherwise return the default max budget
+ */
+static inline unsigned long bfq_max_budget(struct bfq_data *bfqd)
+{
+	if (bfqd->budgets_assigned < 194)
+		return bfq_default_max_budget;
+	else
+		return bfqd->bfq_max_budget;
+}
+
+ /*
+ * bfq_default_budget - return the default budget for @bfqq on @bfqd.
+ * @bfqd: the device descriptor.
+ * @bfqq: the queue to consider.
+ *
+ * We use 3/4 of the @bfqd maximum budget as the default value
+ * for the max_budget field of the queues.  This lets the feedback
+ * mechanism to start from some middle ground, then the behavior
+ * of the process will drive the heuristics towards high values, if
+ * it behaves as a greedy sequential reader, or towards small values
+ * if it shows a more intermittent behavior.
+ */
+static unsigned long bfq_default_budget(struct bfq_data *bfqd,
+					struct bfq_queue *bfqq)
+{
+	unsigned long budget;
+
+	/*
+	 * When we need an estimate of the peak rate we need to avoid
+	 * to give budgets that are too short due to previous measurements.
+	 * So, in the first 10 assignments use a ``safe'' budget value.
+	 */
+	if (bfqd->budgets_assigned < 194 && bfqd->bfq_user_max_budget == 0)
+		budget = bfq_default_max_budget;
+	else
+		budget = bfqd->bfq_max_budget;
+
+	return budget - budget / 4;
+}
+
+/*
+ * Return min budget, which is a fraction of the current or default
+ * max budget (trying with 1/32)
+ */
+static inline unsigned long bfq_min_budget(struct bfq_data *bfqd)
+{
+	if (bfqd->budgets_assigned < 194)
+		return bfq_default_max_budget / 32;
+	else
+		return bfqd->bfq_max_budget / 32;
+}
+
+static void bfq_arm_slice_timer(struct bfq_data *bfqd)
+{
+	struct bfq_queue *bfqq = bfqd->in_service_queue;
+	struct bfq_io_cq *bic;
+	unsigned long sl;
+
+	/* Processes have exited, don't wait. */
+	bic = bfqd->in_service_bic;
+	if (bic == NULL || atomic_read(&bic->icq.ioc->active_ref) == 0)
+		return;
+
+	bfq_mark_bfqq_wait_request(bfqq);
+
+	/*
+	 * We don't want to idle for seeks, but we do want to allow
+	 * fair distribution of slice time for a process doing back-to-back
+	 * seeks. So allow a little bit of time for him to submit a new rq.
+	 */
+	sl = bfqd->bfq_slice_idle;
+	/*
+	 * Grant only minimum idle time if the queue has been seeky for long
+	 * enough.
+	 */
+	if (bfq_sample_valid(bfqq->seek_samples) && BFQQ_SEEKY(bfqq))
+		sl = min(sl, msecs_to_jiffies(BFQ_MIN_TT));
+	bfqd->last_idling_start = ktime_get();
+	mod_timer(&bfqd->idle_slice_timer, jiffies + sl);
+	bfq_log(bfqd, "arm idle: %u/%u ms",
+		jiffies_to_msecs(sl), jiffies_to_msecs(bfqd->bfq_slice_idle));
+}
+
+/*
+ * Set the maximum time for the in-service queue to consume its
+ * budget. This prevents seeky processes from lowering the disk
+ * throughput (always guaranteed with a time slice scheme as in CFQ).
+ */
+static void bfq_set_budget_timeout(struct bfq_data *bfqd)
+{
+	struct bfq_queue *bfqq = bfqd->in_service_queue;
+	unsigned int timeout_coeff = bfqq->entity.weight /
+				     bfqq->entity.orig_weight;
+
+	bfqd->last_budget_start = ktime_get();
+
+	bfq_clear_bfqq_budget_new(bfqq);
+	bfqq->budget_timeout = jiffies +
+		bfqd->bfq_timeout[bfq_bfqq_sync(bfqq)] * timeout_coeff;
+
+	bfq_log_bfqq(bfqd, bfqq, "set budget_timeout %u",
+		jiffies_to_msecs(bfqd->bfq_timeout[bfq_bfqq_sync(bfqq)] *
+		timeout_coeff));
+}
+
+/*
+ * Move request from internal lists to the request queue dispatch list.
+ */
+static void bfq_dispatch_insert(struct request_queue *q, struct request *rq)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+
+	/*
+	 * For consistency, the next instruction should have been executed
+	 * after removing the request from the queue and dispatching it.
+	 * We execute instead this instruction before bfq_remove_request()
+	 * (and hence introduce a temporary inconsistency), for efficiency.
+	 * In fact, in a forced_dispatch, this prevents two counters related
+	 * to bfqq->dispatched to risk to be uselessly decremented if bfqq
+	 * is not in service, and then to be incremented again after
+	 * incrementing bfqq->dispatched.
+	 */
+	bfqq->dispatched++;
+	bfq_remove_request(rq);
+	elv_dispatch_sort(q, rq);
+
+	if (bfq_bfqq_sync(bfqq))
+		bfqd->sync_flight++;
+}
+
+/*
+ * Return expired entry, or NULL to just start from scratch in rbtree.
+ */
+static struct request *bfq_check_fifo(struct bfq_queue *bfqq)
+{
+	struct request *rq = NULL;
+
+	if (bfq_bfqq_fifo_expire(bfqq))
+		return NULL;
+
+	bfq_mark_bfqq_fifo_expire(bfqq);
+
+	if (list_empty(&bfqq->fifo))
+		return NULL;
+
+	rq = rq_entry_fifo(bfqq->fifo.next);
+
+	if (time_before(jiffies, rq->fifo_time))
+		return NULL;
+
+	return rq;
+}
+
+static inline unsigned long bfq_bfqq_budget_left(struct bfq_queue *bfqq)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+	return entity->budget - entity->service;
+}
+
+static void __bfq_bfqq_expire(struct bfq_data *bfqd, struct bfq_queue *bfqq)
+{
+	__bfq_bfqd_reset_in_service(bfqd);
+
+	if (RB_EMPTY_ROOT(&bfqq->sort_list))
+		bfq_del_bfqq_busy(bfqd, bfqq, 1);
+	else
+		bfq_activate_bfqq(bfqd, bfqq);
+}
+
+/**
+ * __bfq_bfqq_recalc_budget - try to adapt the budget to the @bfqq behavior.
+ * @bfqd: device data.
+ * @bfqq: queue to update.
+ * @reason: reason for expiration.
+ *
+ * Handle the feedback on @bfqq budget.  See the body for detailed
+ * comments.
+ */
+static void __bfq_bfqq_recalc_budget(struct bfq_data *bfqd,
+				     struct bfq_queue *bfqq,
+				     enum bfqq_expiration reason)
+{
+	struct request *next_rq;
+	unsigned long budget, min_budget;
+
+	budget = bfqq->max_budget;
+	min_budget = bfq_min_budget(bfqd);
+
+	bfq_log_bfqq(bfqd, bfqq, "recalc_budg: last budg %lu, budg left %lu",
+		bfqq->entity.budget, bfq_bfqq_budget_left(bfqq));
+	bfq_log_bfqq(bfqd, bfqq, "recalc_budg: last max_budg %lu, min budg %lu",
+		budget, bfq_min_budget(bfqd));
+	bfq_log_bfqq(bfqd, bfqq, "recalc_budg: sync %d, seeky %d",
+		bfq_bfqq_sync(bfqq), BFQQ_SEEKY(bfqd->in_service_queue));
+
+	if (bfq_bfqq_sync(bfqq)) {
+		switch (reason) {
+		/*
+		 * Caveat: in all the following cases we trade latency
+		 * for throughput.
+		 */
+		case BFQ_BFQQ_TOO_IDLE:
+			if (budget > min_budget + BFQ_BUDGET_STEP)
+				budget -= BFQ_BUDGET_STEP;
+			else
+				budget = min_budget;
+			break;
+		case BFQ_BFQQ_BUDGET_TIMEOUT:
+			budget = bfq_default_budget(bfqd, bfqq);
+			break;
+		case BFQ_BFQQ_BUDGET_EXHAUSTED:
+			/*
+			 * The process still has backlog, and did not
+			 * let either the budget timeout or the disk
+			 * idling timeout expire. Hence it is not
+			 * seeky, has a short thinktime and may be
+			 * happy with a higher budget too. So
+			 * definitely increase the budget of this good
+			 * candidate to boost the disk throughput.
+			 */
+			budget = min(budget + 8 * BFQ_BUDGET_STEP,
+				     bfqd->bfq_max_budget);
+			break;
+		case BFQ_BFQQ_NO_MORE_REQUESTS:
+		       /*
+			* Leave the budget unchanged.
+			*/
+		default:
+			return;
+		}
+	} else /* async queue */
+	    /* async queues get always the maximum possible budget
+	     * (their ability to dispatch is limited by
+	     * @bfqd->bfq_max_budget_async_rq).
+	     */
+		budget = bfqd->bfq_max_budget;
+
+	bfqq->max_budget = budget;
+
+	if (bfqd->budgets_assigned >= 194 && bfqd->bfq_user_max_budget == 0 &&
+	    bfqq->max_budget > bfqd->bfq_max_budget)
+		bfqq->max_budget = bfqd->bfq_max_budget;
+
+	/*
+	 * Make sure that we have enough budget for the next request.
+	 * Since the finish time of the bfqq must be kept in sync with
+	 * the budget, be sure to call __bfq_bfqq_expire() after the
+	 * update.
+	 */
+	next_rq = bfqq->next_rq;
+	if (next_rq != NULL)
+		bfqq->entity.budget = max_t(unsigned long, bfqq->max_budget,
+					    bfq_serv_to_charge(next_rq, bfqq));
+	else
+		bfqq->entity.budget = bfqq->max_budget;
+
+	bfq_log_bfqq(bfqd, bfqq, "head sect: %u, new budget %lu",
+			next_rq != NULL ? blk_rq_sectors(next_rq) : 0,
+			bfqq->entity.budget);
+}
+
+static unsigned long bfq_calc_max_budget(u64 peak_rate, u64 timeout)
+{
+	unsigned long max_budget;
+
+	/*
+	 * The max_budget calculated when autotuning is equal to the
+	 * amount of sectors transfered in timeout_sync at the
+	 * estimated peak rate.
+	 */
+	max_budget = (unsigned long)(peak_rate * 1000 *
+				     timeout >> BFQ_RATE_SHIFT);
+
+	return max_budget;
+}
+
+/*
+ * In addition to updating the peak rate, checks whether the process
+ * is "slow", and returns 1 if so. This slow flag is used, in addition
+ * to the budget timeout, to reduce the amount of service provided to
+ * seeky processes, and hence reduce their chances to lower the
+ * throughput. See the code for more details.
+ */
+static int bfq_update_peak_rate(struct bfq_data *bfqd, struct bfq_queue *bfqq,
+				int compensate)
+{
+	u64 bw, usecs, expected, timeout;
+	ktime_t delta;
+	int update = 0;
+
+	if (!bfq_bfqq_sync(bfqq) || bfq_bfqq_budget_new(bfqq))
+		return 0;
+
+	if (compensate)
+		delta = bfqd->last_idling_start;
+	else
+		delta = ktime_get();
+	delta = ktime_sub(delta, bfqd->last_budget_start);
+	usecs = ktime_to_us(delta);
+
+	/* Don't trust short/unrealistic values. */
+	if (usecs < 100 || usecs >= LONG_MAX)
+		return 0;
+
+	/*
+	 * Calculate the bandwidth for the last slice.  We use a 64 bit
+	 * value to store the peak rate, in sectors per usec in fixed
+	 * point math.  We do so to have enough precision in the estimate
+	 * and to avoid overflows.
+	 */
+	bw = (u64)bfqq->entity.service << BFQ_RATE_SHIFT;
+	do_div(bw, (unsigned long)usecs);
+
+	timeout = jiffies_to_msecs(bfqd->bfq_timeout[BLK_RW_SYNC]);
+
+	/*
+	 * Use only long (> 20ms) intervals to filter out spikes for
+	 * the peak rate estimation.
+	 */
+	if (usecs > 20000) {
+		if (bw > bfqd->peak_rate) {
+			bfqd->peak_rate = bw;
+			update = 1;
+			bfq_log(bfqd, "new peak_rate=%llu", bw);
+		}
+
+		update |= bfqd->peak_rate_samples == BFQ_PEAK_RATE_SAMPLES - 1;
+
+		if (bfqd->peak_rate_samples < BFQ_PEAK_RATE_SAMPLES)
+			bfqd->peak_rate_samples++;
+
+		if (bfqd->peak_rate_samples == BFQ_PEAK_RATE_SAMPLES &&
+		    update && bfqd->bfq_user_max_budget == 0) {
+			bfqd->bfq_max_budget =
+				bfq_calc_max_budget(bfqd->peak_rate,
+						    timeout);
+			bfq_log(bfqd, "new max_budget=%lu",
+				bfqd->bfq_max_budget);
+		}
+	}
+
+	/*
+	 * A process is considered ``slow'' (i.e., seeky, so that we
+	 * cannot treat it fairly in the service domain, as it would
+	 * slow down too much the other processes) if, when a slice
+	 * ends for whatever reason, it has received service at a
+	 * rate that would not be high enough to complete the budget
+	 * before the budget timeout expiration.
+	 */
+	expected = bw * 1000 * timeout >> BFQ_RATE_SHIFT;
+
+	/*
+	 * Caveat: processes doing IO in the slower disk zones will
+	 * tend to be slow(er) even if not seeky. And the estimated
+	 * peak rate will actually be an average over the disk
+	 * surface. Hence, to not be too harsh with unlucky processes,
+	 * we keep a budget/3 margin of safety before declaring a
+	 * process slow.
+	 */
+	return expected > (4 * bfqq->entity.budget) / 3;
+}
+
+/**
+ * bfq_bfqq_expire - expire a queue.
+ * @bfqd: device owning the queue.
+ * @bfqq: the queue to expire.
+ * @compensate: if true, compensate for the time spent idling.
+ * @reason: the reason causing the expiration.
+ *
+ *
+ * If the process associated to the queue is slow (i.e., seeky), or in
+ * case of budget timeout, or, finally, if it is async, we
+ * artificially charge it an entire budget (independently of the
+ * actual service it received). As a consequence, the queue will get
+ * higher timestamps than the correct ones upon reactivation, and
+ * hence it will be rescheduled as if it had received more service
+ * than what it actually received. In the end, this class of processes
+ * will receive less service in proportion to how slowly they consume
+ * their budgets (and hence how seriously they tend to lower the
+ * throughput).
+ *
+ * In contrast, when a queue expires because it has been idling for
+ * too much or because it exhausted its budget, we do not touch the
+ * amount of service it has received. Hence when the queue will be
+ * reactivated and its timestamps updated, the latter will be in sync
+ * with the actual service received by the queue until expiration.
+ *
+ * Charging a full budget to the first type of queues and the exact
+ * service to the others has the effect of using the WF2Q+ policy to
+ * schedule the former on a timeslice basis, without violating the
+ * service domain guarantees of the latter.
+ */
+static void bfq_bfqq_expire(struct bfq_data *bfqd,
+			    struct bfq_queue *bfqq,
+			    int compensate,
+			    enum bfqq_expiration reason)
+{
+	int slow;
+
+	/* Update disk peak rate for autotuning and check whether the
+	 * process is slow (see bfq_update_peak_rate).
+	 */
+	slow = bfq_update_peak_rate(bfqd, bfqq, compensate);
+
+	/*
+	 * As above explained, 'punish' slow (i.e., seeky), timed-out
+	 * and async queues, to favor sequential sync workloads.
+	 */
+	if (slow || reason == BFQ_BFQQ_BUDGET_TIMEOUT)
+		bfq_bfqq_charge_full_budget(bfqq);
+
+	bfq_log_bfqq(bfqd, bfqq,
+		"expire (%d, slow %d, num_disp %d, idle_win %d)", reason,
+		slow, bfqq->dispatched, bfq_bfqq_idle_window(bfqq));
+
+	/*
+	 * Increase, decrease or leave budget unchanged according to
+	 * reason.
+	 */
+	__bfq_bfqq_recalc_budget(bfqd, bfqq, reason);
+	__bfq_bfqq_expire(bfqd, bfqq);
+}
+
+/*
+ * Budget timeout is not implemented through a dedicated timer, but
+ * just checked on request arrivals and completions, as well as on
+ * idle timer expirations.
+ */
+static int bfq_bfqq_budget_timeout(struct bfq_queue *bfqq)
+{
+	if (bfq_bfqq_budget_new(bfqq) ||
+	    time_before(jiffies, bfqq->budget_timeout))
+		return 0;
+	return 1;
+}
+
+/*
+ * If we expire a queue that is waiting for the arrival of a new
+ * request, we may prevent the fictitious timestamp back-shifting that
+ * allows the guarantees of the queue to be preserved (see [1] for
+ * this tricky aspect). Hence we return true only if this condition
+ * does not hold, or if the queue is slow enough to deserve only to be
+ * kicked off for preserving a high throughput.
+*/
+static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)
+{
+	bfq_log_bfqq(bfqq->bfqd, bfqq,
+		"may_budget_timeout: wait_request %d left %d timeout %d",
+		bfq_bfqq_wait_request(bfqq),
+			bfq_bfqq_budget_left(bfqq) >=  bfqq->entity.budget / 3,
+		bfq_bfqq_budget_timeout(bfqq));
+
+	return (!bfq_bfqq_wait_request(bfqq) ||
+		bfq_bfqq_budget_left(bfqq) >=  bfqq->entity.budget / 3)
+		&&
+		bfq_bfqq_budget_timeout(bfqq);
+}
+
+/*
+ * Device idling is allowed only for sync queues that have a non-null
+ * idle window.
+ */
+static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
+{
+	return bfq_bfqq_sync(bfqq) && bfq_bfqq_idle_window(bfqq);
+}
+
+/*
+ * If the in-service queue is empty, but it is sync and the queue has its
+ * idle window set (in this case, waiting for a new request for the queue
+ * is likely to boost the throughput), then:
+ * 1) the queue must remain in service and cannot be expired, and
+ * 2) the disk must be idled to wait for the possible arrival of a new
+ *    request for the queue.
+ */
+static inline bool bfq_bfqq_must_idle(struct bfq_queue *bfqq)
+{
+	struct bfq_data *bfqd = bfqq->bfqd;
+
+	return RB_EMPTY_ROOT(&bfqq->sort_list) && bfqd->bfq_slice_idle != 0 &&
+	       bfq_bfqq_must_not_expire(bfqq);
+}
+
+/*
+ * Select a queue for service.  If we have a current queue in service,
+ * check whether to continue servicing it, or retrieve and set a new one.
+ */
+static struct bfq_queue *bfq_select_queue(struct bfq_data *bfqd)
+{
+	struct bfq_queue *bfqq;
+	struct request *next_rq;
+	enum bfqq_expiration reason = BFQ_BFQQ_BUDGET_TIMEOUT;
+
+	bfqq = bfqd->in_service_queue;
+	if (bfqq == NULL)
+		goto new_queue;
+
+	bfq_log_bfqq(bfqd, bfqq, "select_queue: already in-service queue");
+
+	if (bfq_may_expire_for_budg_timeout(bfqq) &&
+	    !timer_pending(&bfqd->idle_slice_timer) &&
+	    !bfq_bfqq_must_idle(bfqq))
+		goto expire;
+
+	next_rq = bfqq->next_rq;
+	/*
+	 * If bfqq has requests queued and it has enough budget left to
+	 * serve them, keep the queue, otherwise expire it.
+	 */
+	if (next_rq != NULL) {
+		if (bfq_serv_to_charge(next_rq, bfqq) >
+			bfq_bfqq_budget_left(bfqq)) {
+			reason = BFQ_BFQQ_BUDGET_EXHAUSTED;
+			goto expire;
+		} else {
+			/*
+			 * The idle timer may be pending because we may
+			 * not disable disk idling even when a new request
+			 * arrives.
+			 */
+			if (timer_pending(&bfqd->idle_slice_timer)) {
+				/*
+				 * If we get here: 1) at least a new request
+				 * has arrived but we have not disabled the
+				 * timer because the request was too small,
+				 * 2) then the block layer has unplugged
+				 * the device, causing the dispatch to be
+				 * invoked.
+				 *
+				 * Since the device is unplugged, now the
+				 * requests are probably large enough to
+				 * provide a reasonable throughput.
+				 * So we disable idling.
+				 */
+				bfq_clear_bfqq_wait_request(bfqq);
+				del_timer(&bfqd->idle_slice_timer);
+			}
+			goto keep_queue;
+		}
+	}
+
+	/*
+	 * No requests pending.  If the in-service queue still has requests
+	 * in flight (possibly waiting for a completion) or is idling for a
+	 * new request, then keep it.
+	 */
+	if (timer_pending(&bfqd->idle_slice_timer) ||
+	    (bfqq->dispatched != 0 && bfq_bfqq_must_not_expire(bfqq))) {
+		bfqq = NULL;
+		goto keep_queue;
+	}
+
+	reason = BFQ_BFQQ_NO_MORE_REQUESTS;
+expire:
+	bfq_bfqq_expire(bfqd, bfqq, 0, reason);
+new_queue:
+	bfqq = bfq_set_in_service_queue(bfqd);
+	bfq_log(bfqd, "select_queue: new queue %d returned",
+		bfqq != NULL ? bfqq->pid : 0);
+keep_queue:
+	return bfqq;
+}
+
+/*
+ * Dispatch one request from bfqq, moving it to the request queue
+ * dispatch list.
+ */
+static int bfq_dispatch_request(struct bfq_data *bfqd,
+				struct bfq_queue *bfqq)
+{
+	int dispatched = 0;
+	struct request *rq;
+	unsigned long service_to_charge;
+
+	/* Follow expired path, else get first next available. */
+	rq = bfq_check_fifo(bfqq);
+	if (rq == NULL)
+		rq = bfqq->next_rq;
+	service_to_charge = bfq_serv_to_charge(rq, bfqq);
+
+	if (service_to_charge > bfq_bfqq_budget_left(bfqq)) {
+		/*
+		 * This may happen if the next rq is chosen in fifo order
+		 * instead of sector order. The budget is properly
+		 * dimensioned to be always sufficient to serve the next
+		 * request only if it is chosen in sector order. The reason
+		 * is that it would be quite inefficient and little useful
+		 * to always make sure that the budget is large enough to
+		 * serve even the possible next rq in fifo order.
+		 * In fact, requests are seldom served in fifo order.
+		 *
+		 * Expire the queue for budget exhaustion, and make sure
+		 * that the next act_budget is enough to serve the next
+		 * request, even if it comes from the fifo expired path.
+		 */
+		bfqq->next_rq = rq;
+		/*
+		 * Since this dispatch is failed, make sure that
+		 * a new one will be performed
+		 */
+		if (!bfqd->rq_in_driver)
+			bfq_schedule_dispatch(bfqd);
+		goto expire;
+	}
+
+	/* Finally, insert request into driver dispatch list. */
+	bfq_bfqq_served(bfqq, service_to_charge);
+	bfq_dispatch_insert(bfqd->queue, rq);
+
+	bfq_log_bfqq(bfqd, bfqq,
+			"dispatched %u sec req (%llu), budg left %lu",
+			blk_rq_sectors(rq),
+			(long long unsigned)blk_rq_pos(rq),
+			bfq_bfqq_budget_left(bfqq));
+
+	dispatched++;
+
+	if (bfqd->in_service_bic == NULL) {
+		atomic_long_inc(&RQ_BIC(rq)->icq.ioc->refcount);
+		bfqd->in_service_bic = RQ_BIC(rq);
+	}
+
+	if (bfqd->busy_queues > 1 && ((!bfq_bfqq_sync(bfqq) &&
+	    dispatched >= bfqd->bfq_max_budget_async_rq) ||
+	    bfq_class_idle(bfqq)))
+		goto expire;
+
+	return dispatched;
+
+expire:
+	bfq_bfqq_expire(bfqd, bfqq, 0, BFQ_BFQQ_BUDGET_EXHAUSTED);
+	return dispatched;
+}
+
+static int __bfq_forced_dispatch_bfqq(struct bfq_queue *bfqq)
+{
+	int dispatched = 0;
+
+	while (bfqq->next_rq != NULL) {
+		bfq_dispatch_insert(bfqq->bfqd->queue, bfqq->next_rq);
+		dispatched++;
+	}
+
+	return dispatched;
+}
+
+/*
+ * Drain our current requests.
+ * Used for barriers and when switching io schedulers on-the-fly.
+ */
+static int bfq_forced_dispatch(struct bfq_data *bfqd)
+{
+	struct bfq_queue *bfqq, *n;
+	struct bfq_service_tree *st;
+	int dispatched = 0;
+
+	bfqq = bfqd->in_service_queue;
+	if (bfqq != NULL)
+		__bfq_bfqq_expire(bfqd, bfqq);
+
+	/*
+	 * Loop through classes, and be careful to leave the scheduler
+	 * in a consistent state, as feedback mechanisms and vtime
+	 * updates cannot be disabled during the process.
+	 */
+	list_for_each_entry_safe(bfqq, n, &bfqd->active_list, bfqq_list) {
+		st = bfq_entity_service_tree(&bfqq->entity);
+
+		dispatched += __bfq_forced_dispatch_bfqq(bfqq);
+		bfqq->max_budget = bfq_max_budget(bfqd);
+
+		bfq_forget_idle(st);
+	}
+
+	return dispatched;
+}
+
+static int bfq_dispatch_requests(struct request_queue *q, int force)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct bfq_queue *bfqq;
+	int max_dispatch;
+
+	bfq_log(bfqd, "dispatch requests: %d busy queues", bfqd->busy_queues);
+	if (bfqd->busy_queues == 0)
+		return 0;
+
+	if (unlikely(force))
+		return bfq_forced_dispatch(bfqd);
+
+	bfqq = bfq_select_queue(bfqd);
+	if (bfqq == NULL)
+		return 0;
+
+	max_dispatch = bfqd->bfq_quantum;
+	if (bfq_class_idle(bfqq))
+		max_dispatch = 1;
+
+	if (!bfq_bfqq_sync(bfqq))
+		max_dispatch = bfqd->bfq_max_budget_async_rq;
+
+	if (bfqq->dispatched >= max_dispatch) {
+		if (bfqd->busy_queues > 1)
+			return 0;
+		if (bfqq->dispatched >= 4 * max_dispatch)
+			return 0;
+	}
+
+	if (bfqd->sync_flight != 0 && !bfq_bfqq_sync(bfqq))
+		return 0;
+
+	bfq_clear_bfqq_wait_request(bfqq);
+
+	if (!bfq_dispatch_request(bfqd, bfqq))
+		return 0;
+
+	bfq_log_bfqq(bfqd, bfqq, "dispatched one request of %d (max_disp %d)",
+			bfqq->pid, max_dispatch);
+
+	return 1;
+}
+
+/*
+ * Task holds one reference to the queue, dropped when task exits.  Each rq
+ * in-flight on this queue also holds a reference, dropped when rq is freed.
+ *
+ * Queue lock must be held here.
+ */
+static void bfq_put_queue(struct bfq_queue *bfqq)
+{
+	struct bfq_data *bfqd = bfqq->bfqd;
+
+	bfq_log_bfqq(bfqd, bfqq, "put_queue: %p %d", bfqq,
+		     atomic_read(&bfqq->ref));
+	if (!atomic_dec_and_test(&bfqq->ref))
+		return;
+
+	bfq_log_bfqq(bfqd, bfqq, "put_queue: %p freed", bfqq);
+
+	kmem_cache_free(bfq_pool, bfqq);
+}
+
+static void bfq_exit_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq)
+{
+	if (bfqq == bfqd->in_service_queue) {
+		__bfq_bfqq_expire(bfqd, bfqq);
+		bfq_schedule_dispatch(bfqd);
+	}
+
+	bfq_log_bfqq(bfqd, bfqq, "exit_bfqq: %p, %d", bfqq,
+		     atomic_read(&bfqq->ref));
+
+	bfq_put_queue(bfqq);
+}
+
+static inline void bfq_init_icq(struct io_cq *icq)
+{
+	icq_to_bic(icq)->ttime.last_end_request = jiffies;
+}
+
+static void bfq_exit_icq(struct io_cq *icq)
+{
+	struct bfq_io_cq *bic = icq_to_bic(icq);
+	struct bfq_data *bfqd = bic_to_bfqd(bic);
+
+	if (bic->bfqq[BLK_RW_ASYNC]) {
+		bfq_exit_bfqq(bfqd, bic->bfqq[BLK_RW_ASYNC]);
+		bic->bfqq[BLK_RW_ASYNC] = NULL;
+	}
+
+	if (bic->bfqq[BLK_RW_SYNC]) {
+		bfq_exit_bfqq(bfqd, bic->bfqq[BLK_RW_SYNC]);
+		bic->bfqq[BLK_RW_SYNC] = NULL;
+	}
+}
+
+/*
+ * Update the entity prio values; note that the new values will not
+ * be used until the next (re)activation.
+ */
+static void bfq_init_prio_data(struct bfq_queue *bfqq, struct bfq_io_cq *bic)
+{
+	struct task_struct *tsk = current;
+	int ioprio_class;
+
+	if (!bfq_bfqq_prio_changed(bfqq))
+		return;
+
+	ioprio_class = IOPRIO_PRIO_CLASS(bic->ioprio);
+	switch (ioprio_class) {
+	default:
+		dev_err(bfqq->bfqd->queue->backing_dev_info.dev,
+			"bfq: bad prio %x\n", ioprio_class);
+	case IOPRIO_CLASS_NONE:
+		/*
+		 * No prio set, inherit CPU scheduling settings.
+		 */
+		bfqq->entity.new_ioprio = task_nice_ioprio(tsk);
+		bfqq->entity.new_ioprio_class = task_nice_ioclass(tsk);
+		break;
+	case IOPRIO_CLASS_RT:
+		bfqq->entity.new_ioprio = IOPRIO_PRIO_DATA(bic->ioprio);
+		bfqq->entity.new_ioprio_class = IOPRIO_CLASS_RT;
+		break;
+	case IOPRIO_CLASS_BE:
+		bfqq->entity.new_ioprio = IOPRIO_PRIO_DATA(bic->ioprio);
+		bfqq->entity.new_ioprio_class = IOPRIO_CLASS_BE;
+		break;
+	case IOPRIO_CLASS_IDLE:
+		bfqq->entity.new_ioprio_class = IOPRIO_CLASS_IDLE;
+		bfqq->entity.new_ioprio = 7;
+		bfq_clear_bfqq_idle_window(bfqq);
+		break;
+	}
+
+	bfqq->entity.ioprio_changed = 1;
+
+	bfq_clear_bfqq_prio_changed(bfqq);
+}
+
+static void bfq_changed_ioprio(struct bfq_io_cq *bic)
+{
+	struct bfq_data *bfqd;
+	struct bfq_queue *bfqq, *new_bfqq;
+	unsigned long uninitialized_var(flags);
+	int ioprio = bic->icq.ioc->ioprio;
+
+	bfqd = bfq_get_bfqd_locked(&(bic->icq.q->elevator->elevator_data),
+				   &flags);
+	/*
+	 * This condition may trigger on a newly created bic, be sure to
+	 * drop the lock before returning.
+	 */
+	if (unlikely(bfqd == NULL) || likely(bic->ioprio == ioprio))
+		goto out;
+
+	bfqq = bic->bfqq[BLK_RW_ASYNC];
+	if (bfqq != NULL) {
+		new_bfqq = bfq_get_queue(bfqd, BLK_RW_ASYNC, bic,
+					 GFP_ATOMIC);
+		if (new_bfqq != NULL) {
+			bic->bfqq[BLK_RW_ASYNC] = new_bfqq;
+			bfq_log_bfqq(bfqd, bfqq,
+				     "changed_ioprio: bfqq %p %d",
+				     bfqq, atomic_read(&bfqq->ref));
+			bfq_put_queue(bfqq);
+		}
+	}
+
+	bfqq = bic->bfqq[BLK_RW_SYNC];
+	if (bfqq != NULL)
+		bfq_mark_bfqq_prio_changed(bfqq);
+
+	bic->ioprio = ioprio;
+
+out:
+	bfq_put_bfqd_unlock(bfqd, &flags);
+}
+
+static void bfq_init_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq,
+			  pid_t pid, int is_sync)
+{
+	RB_CLEAR_NODE(&bfqq->entity.rb_node);
+	INIT_LIST_HEAD(&bfqq->fifo);
+
+	atomic_set(&bfqq->ref, 0);
+	bfqq->bfqd = bfqd;
+
+	bfq_mark_bfqq_prio_changed(bfqq);
+
+	if (is_sync) {
+		if (!bfq_class_idle(bfqq))
+			bfq_mark_bfqq_idle_window(bfqq);
+		bfq_mark_bfqq_sync(bfqq);
+	}
+
+	/* Tentative initial value to trade off between thr and lat */
+	bfqq->max_budget = bfq_default_budget(bfqd, bfqq);
+	bfqq->pid = pid;
+}
+
+static struct bfq_queue *bfq_find_alloc_queue(struct bfq_data *bfqd,
+					      int is_sync,
+					      struct bfq_io_cq *bic,
+					      gfp_t gfp_mask)
+{
+	struct bfq_queue *bfqq, *new_bfqq = NULL;
+
+retry:
+	/* bic always exists here */
+	bfqq = bic_to_bfqq(bic, is_sync);
+
+	/*
+	 * Always try a new alloc if we fall back to the OOM bfqq
+	 * originally, since it should just be a temporary situation.
+	 */
+	if (bfqq == NULL || bfqq == &bfqd->oom_bfqq) {
+		bfqq = NULL;
+		if (new_bfqq != NULL) {
+			bfqq = new_bfqq;
+			new_bfqq = NULL;
+		} else if (gfp_mask & __GFP_WAIT) {
+			spin_unlock_irq(bfqd->queue->queue_lock);
+			new_bfqq = kmem_cache_alloc_node(bfq_pool,
+					gfp_mask | __GFP_ZERO,
+					bfqd->queue->node);
+			spin_lock_irq(bfqd->queue->queue_lock);
+			if (new_bfqq != NULL)
+				goto retry;
+		} else {
+			bfqq = kmem_cache_alloc_node(bfq_pool,
+					gfp_mask | __GFP_ZERO,
+					bfqd->queue->node);
+		}
+
+		if (bfqq != NULL) {
+			bfq_init_bfqq(bfqd, bfqq, current->pid, is_sync);
+			bfq_log_bfqq(bfqd, bfqq, "allocated");
+		} else {
+			bfqq = &bfqd->oom_bfqq;
+			bfq_log_bfqq(bfqd, bfqq, "using oom bfqq");
+		}
+
+		bfq_init_prio_data(bfqq, bic);
+	}
+
+	if (new_bfqq != NULL)
+		kmem_cache_free(bfq_pool, new_bfqq);
+
+	return bfqq;
+}
+
+static struct bfq_queue **bfq_async_queue_prio(struct bfq_data *bfqd,
+					       int ioprio_class, int ioprio)
+{
+	switch (ioprio_class) {
+	case IOPRIO_CLASS_RT:
+		return &async_bfqq[0][ioprio];
+	case IOPRIO_CLASS_NONE:
+		ioprio = IOPRIO_NORM;
+		/* fall through */
+	case IOPRIO_CLASS_BE:
+		return &async_bfqq[1][ioprio];
+	case IOPRIO_CLASS_IDLE:
+		return &async_idle_bfqq;
+	default:
+		BUG();
+	}
+}
+
+static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd,
+				       int is_sync, struct bfq_io_cq *bic,
+				       gfp_t gfp_mask)
+{
+	const int ioprio = IOPRIO_PRIO_DATA(bic->ioprio);
+	const int ioprio_class = IOPRIO_PRIO_CLASS(bic->ioprio);
+	struct bfq_queue **async_bfqq = NULL;
+	struct bfq_queue *bfqq = NULL;
+
+	if (!is_sync) {
+		async_bfqq = bfq_async_queue_prio(bfqd, ioprio_class, ioprio);
+		bfqq = *async_bfqq;
+	}
+
+	if (bfqq == NULL)
+		bfqq = bfq_find_alloc_queue(bfqd, is_sync, bic, gfp_mask);
+
+	/*
+	 * Pin the queue now that it's allocated, scheduler exit will
+	 * prune it.
+	 */
+	if (!is_sync && *async_bfqq == NULL) {
+		atomic_inc(&bfqq->ref);
+		bfq_log_bfqq(bfqd, bfqq, "get_queue, bfqq not in async: %p, %d",
+			     bfqq, atomic_read(&bfqq->ref));
+		*async_bfqq = bfqq;
+	}
+
+	atomic_inc(&bfqq->ref);
+	bfq_log_bfqq(bfqd, bfqq, "get_queue, at end: %p, %d", bfqq,
+		     atomic_read(&bfqq->ref));
+	return bfqq;
+}
+
+static void bfq_update_io_thinktime(struct bfq_data *bfqd,
+				    struct bfq_io_cq *bic)
+{
+	unsigned long elapsed = jiffies - bic->ttime.last_end_request;
+	unsigned long ttime = min(elapsed, 2UL * bfqd->bfq_slice_idle);
+
+	bic->ttime.ttime_samples = (7*bic->ttime.ttime_samples + 256) / 8;
+	bic->ttime.ttime_total = (7*bic->ttime.ttime_total + 256*ttime) / 8;
+	bic->ttime.ttime_mean = (bic->ttime.ttime_total + 128) /
+				bic->ttime.ttime_samples;
+}
+
+static void bfq_update_io_seektime(struct bfq_data *bfqd,
+				   struct bfq_queue *bfqq,
+				   struct request *rq)
+{
+	sector_t sdist;
+	u64 total;
+
+	if (bfqq->last_request_pos < blk_rq_pos(rq))
+		sdist = blk_rq_pos(rq) - bfqq->last_request_pos;
+	else
+		sdist = bfqq->last_request_pos - blk_rq_pos(rq);
+
+	/*
+	 * Don't allow the seek distance to get too large from the
+	 * odd fragment, pagein, etc.
+	 */
+	if (bfqq->seek_samples == 0) /* first request, not really a seek */
+		sdist = 0;
+	else if (bfqq->seek_samples <= 60) /* second & third seek */
+		sdist = min(sdist, (bfqq->seek_mean * 4) + 2*1024*1024);
+	else
+		sdist = min(sdist, (bfqq->seek_mean * 4) + 2*1024*64);
+
+	bfqq->seek_samples = (7*bfqq->seek_samples + 256) / 8;
+	bfqq->seek_total = (7*bfqq->seek_total + (u64)256*sdist) / 8;
+	total = bfqq->seek_total + (bfqq->seek_samples/2);
+	do_div(total, bfqq->seek_samples);
+	bfqq->seek_mean = (sector_t)total;
+
+	bfq_log_bfqq(bfqd, bfqq, "dist=%llu mean=%llu", (u64)sdist,
+			(u64)bfqq->seek_mean);
+}
+
+/*
+ * Disable idle window if the process thinks too long or seeks so much that
+ * it doesn't matter.
+ */
+static void bfq_update_idle_window(struct bfq_data *bfqd,
+				   struct bfq_queue *bfqq,
+				   struct bfq_io_cq *bic)
+{
+	int enable_idle;
+
+	/* Don't idle for async or idle io prio class. */
+	if (!bfq_bfqq_sync(bfqq) || bfq_class_idle(bfqq))
+		return;
+
+	enable_idle = bfq_bfqq_idle_window(bfqq);
+
+	if (atomic_read(&bic->icq.ioc->active_ref) == 0 ||
+	    bfqd->bfq_slice_idle == 0 ||
+		(bfqd->hw_tag && BFQQ_SEEKY(bfqq)))
+		enable_idle = 0;
+	else if (bfq_sample_valid(bic->ttime.ttime_samples)) {
+		if (bic->ttime.ttime_mean > bfqd->bfq_slice_idle)
+			enable_idle = 0;
+		else
+			enable_idle = 1;
+	}
+	bfq_log_bfqq(bfqd, bfqq, "update_idle_window: enable_idle %d",
+		enable_idle);
+
+	if (enable_idle)
+		bfq_mark_bfqq_idle_window(bfqq);
+	else
+		bfq_clear_bfqq_idle_window(bfqq);
+}
+
+/*
+ * Called when a new fs request (rq) is added to bfqq.  Check if there's
+ * something we should do about it.
+ */
+static void bfq_rq_enqueued(struct bfq_data *bfqd, struct bfq_queue *bfqq,
+			    struct request *rq)
+{
+	struct bfq_io_cq *bic = RQ_BIC(rq);
+
+	if (rq->cmd_flags & REQ_META)
+		bfqq->meta_pending++;
+
+	bfq_update_io_thinktime(bfqd, bic);
+	bfq_update_io_seektime(bfqd, bfqq, rq);
+	if (bfqq->entity.service > bfq_max_budget(bfqd) / 8 ||
+	    !BFQQ_SEEKY(bfqq))
+		bfq_update_idle_window(bfqd, bfqq, bic);
+
+	bfq_log_bfqq(bfqd, bfqq,
+		     "rq_enqueued: idle_window=%d (seeky %d, mean %llu)",
+		     bfq_bfqq_idle_window(bfqq), BFQQ_SEEKY(bfqq),
+		     (long long unsigned)bfqq->seek_mean);
+
+	bfqq->last_request_pos = blk_rq_pos(rq) + blk_rq_sectors(rq);
+
+	if (bfqq == bfqd->in_service_queue && bfq_bfqq_wait_request(bfqq)) {
+		int small_req = bfqq->queued[rq_is_sync(rq)] == 1 &&
+				blk_rq_sectors(rq) < 32;
+		int budget_timeout = bfq_bfqq_budget_timeout(bfqq);
+
+		/*
+		 * There is just this request queued: if the request
+		 * is small and the queue is not to be expired, then
+		 * just exit.
+		 *
+		 * In this way, if the disk is being idled to wait for
+		 * a new request from the in-service queue, we avoid
+		 * unplugging the device and committing the disk to serve
+		 * just a small request. On the contrary, we wait for
+		 * the block layer to decide when to unplug the device:
+		 * hopefully, new requests will be merged to this one
+		 * quickly, then the device will be unplugged and
+		 * larger requests will be dispatched.
+		 */
+		if (small_req && !budget_timeout)
+			return;
+
+		/*
+		 * A large enough request arrived, or the queue is to
+		 * be expired: in both cases disk idling is to be
+		 * stopped, so clear wait_request flag and reset
+		 * timer.
+		 */
+		bfq_clear_bfqq_wait_request(bfqq);
+		del_timer(&bfqd->idle_slice_timer);
+
+		/*
+		 * The queue is not empty, because a new request just
+		 * arrived. Hence we can safely expire the queue, in
+		 * case of budget timeout, without risking that the
+		 * timestamps of the queue are not updated correctly.
+		 * See [1] for more details.
+		 */
+		if (budget_timeout)
+			bfq_bfqq_expire(bfqd, bfqq, 0, BFQ_BFQQ_BUDGET_TIMEOUT);
+
+		/*
+		 * Let the request rip immediately, or let a new queue be
+		 * selected if bfqq has just been expired.
+		 */
+		__blk_run_queue(bfqd->queue);
+	}
+}
+
+static void bfq_insert_request(struct request_queue *q, struct request *rq)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+
+	assert_spin_locked(bfqd->queue->queue_lock);
+
+	bfq_init_prio_data(bfqq, RQ_BIC(rq));
+
+	bfq_add_request(rq);
+
+	rq->fifo_time = jiffies + bfqd->bfq_fifo_expire[rq_is_sync(rq)];
+	list_add_tail(&rq->queuelist, &bfqq->fifo);
+
+	bfq_rq_enqueued(bfqd, bfqq, rq);
+}
+
+static void bfq_update_hw_tag(struct bfq_data *bfqd)
+{
+	bfqd->max_rq_in_driver = max(bfqd->max_rq_in_driver,
+				     bfqd->rq_in_driver);
+
+	if (bfqd->hw_tag == 1)
+		return;
+
+	/*
+	 * This sample is valid if the number of outstanding requests
+	 * is large enough to allow a queueing behavior.  Note that the
+	 * sum is not exact, as it's not taking into account deactivated
+	 * requests.
+	 */
+	if (bfqd->rq_in_driver + bfqd->queued < BFQ_HW_QUEUE_THRESHOLD)
+		return;
+
+	if (bfqd->hw_tag_samples++ < BFQ_HW_QUEUE_SAMPLES)
+		return;
+
+	bfqd->hw_tag = bfqd->max_rq_in_driver > BFQ_HW_QUEUE_THRESHOLD;
+	bfqd->max_rq_in_driver = 0;
+	bfqd->hw_tag_samples = 0;
+}
+
+static void bfq_completed_request(struct request_queue *q, struct request *rq)
+{
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+	struct bfq_data *bfqd = bfqq->bfqd;
+	bool sync = bfq_bfqq_sync(bfqq);
+
+	bfq_log_bfqq(bfqd, bfqq, "completed one req with %u sects left (%d)",
+		     blk_rq_sectors(rq), sync);
+
+	bfq_update_hw_tag(bfqd);
+
+	bfqd->rq_in_driver--;
+	bfqq->dispatched--;
+
+	if (sync) {
+		bfqd->sync_flight--;
+		RQ_BIC(rq)->ttime.last_end_request = jiffies;
+	}
+
+	/*
+	 * If this is the in-service queue, check if it needs to be expired,
+	 * or if we want to idle in case it has no pending requests.
+	 */
+	if (bfqd->in_service_queue == bfqq) {
+		if (bfq_bfqq_budget_new(bfqq))
+			bfq_set_budget_timeout(bfqd);
+
+		if (bfq_bfqq_must_idle(bfqq)) {
+			bfq_arm_slice_timer(bfqd);
+			goto out;
+		} else if (bfq_may_expire_for_budg_timeout(bfqq))
+			bfq_bfqq_expire(bfqd, bfqq, 0, BFQ_BFQQ_BUDGET_TIMEOUT);
+		else if (RB_EMPTY_ROOT(&bfqq->sort_list) &&
+			 (bfqq->dispatched == 0 ||
+			  !bfq_bfqq_must_not_expire(bfqq)))
+			bfq_bfqq_expire(bfqd, bfqq, 0,
+					BFQ_BFQQ_NO_MORE_REQUESTS);
+	}
+
+	if (!bfqd->rq_in_driver)
+		bfq_schedule_dispatch(bfqd);
+
+out:
+	return;
+}
+
+static inline int __bfq_may_queue(struct bfq_queue *bfqq)
+{
+	if (bfq_bfqq_wait_request(bfqq) && bfq_bfqq_must_alloc(bfqq)) {
+		bfq_clear_bfqq_must_alloc(bfqq);
+		return ELV_MQUEUE_MUST;
+	}
+
+	return ELV_MQUEUE_MAY;
+}
+
+static int bfq_may_queue(struct request_queue *q, int rw)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct task_struct *tsk = current;
+	struct bfq_io_cq *bic;
+	struct bfq_queue *bfqq;
+
+	/*
+	 * Don't force setup of a queue from here, as a call to may_queue
+	 * does not necessarily imply that a request actually will be
+	 * queued. So just lookup a possibly existing queue, or return
+	 * 'may queue' if that fails.
+	 */
+	bic = bfq_bic_lookup(bfqd, tsk->io_context);
+	if (bic == NULL)
+		return ELV_MQUEUE_MAY;
+
+	bfqq = bic_to_bfqq(bic, rw_is_sync(rw));
+	if (bfqq != NULL) {
+		bfq_init_prio_data(bfqq, bic);
+
+		return __bfq_may_queue(bfqq);
+	}
+
+	return ELV_MQUEUE_MAY;
+}
+
+/*
+ * Queue lock held here.
+ */
+static void bfq_put_request(struct request *rq)
+{
+	struct bfq_queue *bfqq = RQ_BFQQ(rq);
+
+	if (bfqq != NULL) {
+		const int rw = rq_data_dir(rq);
+
+		bfqq->allocated[rw]--;
+
+		rq->elv.priv[0] = NULL;
+		rq->elv.priv[1] = NULL;
+
+		bfq_log_bfqq(bfqq->bfqd, bfqq, "put_request %p, %d",
+			     bfqq, atomic_read(&bfqq->ref));
+		bfq_put_queue(bfqq);
+	}
+}
+
+/*
+ * Allocate bfq data structures associated with this request.
+ */
+static int bfq_set_request(struct request_queue *q, struct request *rq,
+			   struct bio *bio, gfp_t gfp_mask)
+{
+	struct bfq_data *bfqd = q->elevator->elevator_data;
+	struct bfq_io_cq *bic = icq_to_bic(rq->elv.icq);
+	const int rw = rq_data_dir(rq);
+	const int is_sync = rq_is_sync(rq);
+	struct bfq_queue *bfqq;
+	unsigned long flags;
+
+	might_sleep_if(gfp_mask & __GFP_WAIT);
+
+	bfq_changed_ioprio(bic);
+
+	spin_lock_irqsave(q->queue_lock, flags);
+
+	if (bic == NULL)
+		goto queue_fail;
+
+	bfqq = bic_to_bfqq(bic, is_sync);
+	if (bfqq == NULL || bfqq == &bfqd->oom_bfqq) {
+		bfqq = bfq_get_queue(bfqd, is_sync, bic, gfp_mask);
+		bic_set_bfqq(bic, bfqq, is_sync);
+	}
+
+	bfqq->allocated[rw]++;
+	atomic_inc(&bfqq->ref);
+	bfq_log_bfqq(bfqd, bfqq, "set_request: bfqq %p, %d", bfqq,
+		     atomic_read(&bfqq->ref));
+
+	rq->elv.priv[0] = bic;
+	rq->elv.priv[1] = bfqq;
+
+	spin_unlock_irqrestore(q->queue_lock, flags);
+
+	return 0;
+
+queue_fail:
+	bfq_schedule_dispatch(bfqd);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+
+	return 1;
+}
+
+static void bfq_kick_queue(struct work_struct *work)
+{
+	struct bfq_data *bfqd =
+		container_of(work, struct bfq_data, unplug_work);
+	struct request_queue *q = bfqd->queue;
+
+	spin_lock_irq(q->queue_lock);
+	__blk_run_queue(q);
+	spin_unlock_irq(q->queue_lock);
+}
+
+/*
+ * Handler of the expiration of the timer running if the in-service queue
+ * is idling inside its time slice.
+ */
+static void bfq_idle_slice_timer(unsigned long data)
+{
+	struct bfq_data *bfqd = (struct bfq_data *)data;
+	struct bfq_queue *bfqq;
+	unsigned long flags;
+	enum bfqq_expiration reason;
+
+	spin_lock_irqsave(bfqd->queue->queue_lock, flags);
+
+	bfqq = bfqd->in_service_queue;
+	/*
+	 * Theoretical race here: the in-service queue can be NULL or
+	 * different from the queue that was idling if the timer handler
+	 * spins on the queue_lock and a new request arrives for the
+	 * current queue and there is a full dispatch cycle that changes
+	 * the in-service queue.  This can hardly happen, but in the worst
+	 * case we just expire a queue too early.
+	 */
+	if (bfqq != NULL) {
+		bfq_log_bfqq(bfqd, bfqq, "slice_timer expired");
+		if (bfq_bfqq_budget_timeout(bfqq))
+			/*
+			 * Also here the queue can be safely expired
+			 * for budget timeout without wasting
+			 * guarantees
+			 */
+			reason = BFQ_BFQQ_BUDGET_TIMEOUT;
+		else if (bfqq->queued[0] == 0 && bfqq->queued[1] == 0)
+			/*
+			 * The queue may not be empty upon timer expiration,
+			 * because we may not disable the timer when the
+			 * first request of the in-service queue arrives
+			 * during disk idling.
+			 */
+			reason = BFQ_BFQQ_TOO_IDLE;
+		else
+			goto schedule_dispatch;
+
+		bfq_bfqq_expire(bfqd, bfqq, 1, reason);
+	}
+
+schedule_dispatch:
+	bfq_schedule_dispatch(bfqd);
+
+	spin_unlock_irqrestore(bfqd->queue->queue_lock, flags);
+}
+
+static void bfq_shutdown_timer_wq(struct bfq_data *bfqd)
+{
+	del_timer_sync(&bfqd->idle_slice_timer);
+	cancel_work_sync(&bfqd->unplug_work);
+}
+
+static inline void __bfq_put_async_bfqq(struct bfq_data *bfqd,
+					struct bfq_queue **bfqq_ptr)
+{
+	struct bfq_queue *bfqq = *bfqq_ptr;
+
+	bfq_log(bfqd, "put_async_bfqq: %p", bfqq);
+	if (bfqq != NULL) {
+		bfq_log_bfqq(bfqd, bfqq, "put_async_bfqq: putting %p, %d",
+			     bfqq, atomic_read(&bfqq->ref));
+		bfq_put_queue(bfqq);
+		*bfqq_ptr = NULL;
+	}
+}
+
+/*
+ * Release the extra reference of the async queues as the device
+ * goes away.
+ */
+static void bfq_put_async_queues(struct bfq_data *bfqd)
+{
+	int i, j;
+
+	for (i = 0; i < 2; i++)
+		for (j = 0; j < IOPRIO_BE_NR; j++)
+			__bfq_put_async_bfqq(bfqd, &async_bfqq[i][j]);
+
+	__bfq_put_async_bfqq(bfqd, &async_idle_bfqq);
+}
+
+static void bfq_exit_queue(struct elevator_queue *e)
+{
+	struct bfq_data *bfqd = e->elevator_data;
+	struct request_queue *q = bfqd->queue;
+	struct bfq_queue *bfqq, *n;
+
+	bfq_shutdown_timer_wq(bfqd);
+
+	spin_lock_irq(q->queue_lock);
+
+	list_for_each_entry_safe(bfqq, n, &bfqd->idle_list, bfqq_list)
+		bfq_deactivate_bfqq(bfqd, bfqq, 0);
+
+	bfq_put_async_queues(bfqd);
+	spin_unlock_irq(q->queue_lock);
+
+	bfq_shutdown_timer_wq(bfqd);
+
+	synchronize_rcu();
+
+	kfree(bfqd);
+}
+
+static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
+{
+	struct bfq_data *bfqd;
+	struct elevator_queue *eq;
+
+	eq = elevator_alloc(q, e);
+	if (eq == NULL)
+		return -ENOMEM;
+
+	bfqd = kzalloc_node(sizeof(*bfqd), GFP_KERNEL, q->node);
+	if (bfqd == NULL) {
+		kobject_put(&eq->kobj);
+		return -ENOMEM;
+	}
+	eq->elevator_data = bfqd;
+
+	/*
+	 * Our fallback bfqq if bfq_find_alloc_queue() runs into OOM issues.
+	 * Grab a permanent reference to it, so that the normal code flow
+	 * will not attempt to free it.
+	 */
+	bfq_init_bfqq(bfqd, &bfqd->oom_bfqq, 1, 0);
+	atomic_inc(&bfqd->oom_bfqq.ref);
+
+	bfqd->queue = q;
+
+	spin_lock_irq(q->queue_lock);
+	q->elevator = eq;
+	spin_unlock_irq(q->queue_lock);
+
+	init_timer(&bfqd->idle_slice_timer);
+	bfqd->idle_slice_timer.function = bfq_idle_slice_timer;
+	bfqd->idle_slice_timer.data = (unsigned long)bfqd;
+
+	INIT_WORK(&bfqd->unplug_work, bfq_kick_queue);
+
+	INIT_LIST_HEAD(&bfqd->active_list);
+	INIT_LIST_HEAD(&bfqd->idle_list);
+
+	bfqd->hw_tag = -1;
+
+	bfqd->bfq_max_budget = bfq_default_max_budget;
+
+	bfqd->bfq_quantum = bfq_quantum;
+	bfqd->bfq_fifo_expire[0] = bfq_fifo_expire[0];
+	bfqd->bfq_fifo_expire[1] = bfq_fifo_expire[1];
+	bfqd->bfq_back_max = bfq_back_max;
+	bfqd->bfq_back_penalty = bfq_back_penalty;
+	bfqd->bfq_slice_idle = bfq_slice_idle;
+	bfqd->bfq_class_idle_last_service = 0;
+	bfqd->bfq_max_budget_async_rq = bfq_max_budget_async_rq;
+	bfqd->bfq_timeout[BLK_RW_ASYNC] = bfq_timeout_async;
+	bfqd->bfq_timeout[BLK_RW_SYNC] = bfq_timeout_sync;
+
+	return 0;
+}
+
+static void bfq_slab_kill(void)
+{
+	if (bfq_pool != NULL)
+		kmem_cache_destroy(bfq_pool);
+}
+
+static int __init bfq_slab_setup(void)
+{
+	bfq_pool = KMEM_CACHE(bfq_queue, 0);
+	if (bfq_pool == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+static ssize_t bfq_var_show(unsigned int var, char *page)
+{
+	return sprintf(page, "%d\n", var);
+}
+
+static ssize_t bfq_var_store(unsigned long *var, const char *page,
+			     size_t count)
+{
+	unsigned long new_val;
+	int ret = kstrtoul(page, 10, &new_val);
+
+	if (ret == 0)
+		*var = new_val;
+
+	return count;
+}
+
+static ssize_t bfq_weights_show(struct elevator_queue *e, char *page)
+{
+	struct bfq_queue *bfqq;
+	struct bfq_data *bfqd = e->elevator_data;
+	ssize_t num_char = 0;
+
+	num_char += sprintf(page + num_char, "Tot reqs queued %d\n\n",
+			    bfqd->queued);
+
+	spin_lock_irq(bfqd->queue->queue_lock);
+
+	num_char += sprintf(page + num_char, "Active:\n");
+	list_for_each_entry(bfqq, &bfqd->active_list, bfqq_list) {
+	  num_char += sprintf(page + num_char,
+			      "pid%d: weight %hu, nr_queued %d %d\n",
+			      bfqq->pid,
+			      bfqq->entity.weight,
+			      bfqq->queued[0],
+			      bfqq->queued[1]);
+	}
+
+	num_char += sprintf(page + num_char, "Idle:\n");
+	list_for_each_entry(bfqq, &bfqd->idle_list, bfqq_list) {
+			num_char += sprintf(page + num_char,
+				"pid%d: weight %hu\n",
+				bfqq->pid,
+				bfqq->entity.weight);
+	}
+
+	spin_unlock_irq(bfqd->queue->queue_lock);
+
+	return num_char;
+}
+
+#define SHOW_FUNCTION(__FUNC, __VAR, __CONV)				\
+static ssize_t __FUNC(struct elevator_queue *e, char *page)		\
+{									\
+	struct bfq_data *bfqd = e->elevator_data;			\
+	unsigned int __data = __VAR;					\
+	if (__CONV)							\
+		__data = jiffies_to_msecs(__data);			\
+	return bfq_var_show(__data, (page));				\
+}
+SHOW_FUNCTION(bfq_quantum_show, bfqd->bfq_quantum, 0);
+SHOW_FUNCTION(bfq_fifo_expire_sync_show, bfqd->bfq_fifo_expire[1], 1);
+SHOW_FUNCTION(bfq_fifo_expire_async_show, bfqd->bfq_fifo_expire[0], 1);
+SHOW_FUNCTION(bfq_back_seek_max_show, bfqd->bfq_back_max, 0);
+SHOW_FUNCTION(bfq_back_seek_penalty_show, bfqd->bfq_back_penalty, 0);
+SHOW_FUNCTION(bfq_slice_idle_show, bfqd->bfq_slice_idle, 1);
+SHOW_FUNCTION(bfq_max_budget_show, bfqd->bfq_user_max_budget, 0);
+SHOW_FUNCTION(bfq_max_budget_async_rq_show,
+	      bfqd->bfq_max_budget_async_rq, 0);
+SHOW_FUNCTION(bfq_timeout_sync_show, bfqd->bfq_timeout[BLK_RW_SYNC], 1);
+SHOW_FUNCTION(bfq_timeout_async_show, bfqd->bfq_timeout[BLK_RW_ASYNC], 1);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
+static ssize_t								\
+__FUNC(struct elevator_queue *e, const char *page, size_t count)	\
+{									\
+	struct bfq_data *bfqd = e->elevator_data;			\
+	unsigned long uninitialized_var(__data);			\
+	int ret = bfq_var_store(&__data, (page), count);		\
+	if (__data < (MIN))						\
+		__data = (MIN);						\
+	else if (__data > (MAX))					\
+		__data = (MAX);						\
+	if (__CONV)							\
+		*(__PTR) = msecs_to_jiffies(__data);			\
+	else								\
+		*(__PTR) = __data;					\
+	return ret;							\
+}
+STORE_FUNCTION(bfq_quantum_store, &bfqd->bfq_quantum, 1, INT_MAX, 0);
+STORE_FUNCTION(bfq_fifo_expire_sync_store, &bfqd->bfq_fifo_expire[1], 1,
+		INT_MAX, 1);
+STORE_FUNCTION(bfq_fifo_expire_async_store, &bfqd->bfq_fifo_expire[0], 1,
+		INT_MAX, 1);
+STORE_FUNCTION(bfq_back_seek_max_store, &bfqd->bfq_back_max, 0, INT_MAX, 0);
+STORE_FUNCTION(bfq_back_seek_penalty_store, &bfqd->bfq_back_penalty, 1,
+		INT_MAX, 0);
+STORE_FUNCTION(bfq_slice_idle_store, &bfqd->bfq_slice_idle, 0, INT_MAX, 1);
+STORE_FUNCTION(bfq_max_budget_async_rq_store, &bfqd->bfq_max_budget_async_rq,
+		1, INT_MAX, 0);
+STORE_FUNCTION(bfq_timeout_async_store, &bfqd->bfq_timeout[BLK_RW_ASYNC], 0,
+		INT_MAX, 1);
+#undef STORE_FUNCTION
+
+/* do nothing for the moment */
+static ssize_t bfq_weights_store(struct elevator_queue *e,
+				    const char *page, size_t count)
+{
+	return count;
+}
+
+static inline unsigned long bfq_estimated_max_budget(struct bfq_data *bfqd)
+{
+	u64 timeout = jiffies_to_msecs(bfqd->bfq_timeout[BLK_RW_SYNC]);
+
+	if (bfqd->peak_rate_samples >= BFQ_PEAK_RATE_SAMPLES)
+		return bfq_calc_max_budget(bfqd->peak_rate, timeout);
+	else
+		return bfq_default_max_budget;
+}
+
+static ssize_t bfq_max_budget_store(struct elevator_queue *e,
+				    const char *page, size_t count)
+{
+	struct bfq_data *bfqd = e->elevator_data;
+	unsigned long uninitialized_var(__data);
+	int ret = bfq_var_store(&__data, (page), count);
+
+	if (__data == 0)
+		bfqd->bfq_max_budget = bfq_estimated_max_budget(bfqd);
+	else {
+		if (__data > INT_MAX)
+			__data = INT_MAX;
+		bfqd->bfq_max_budget = __data;
+	}
+
+	bfqd->bfq_user_max_budget = __data;
+
+	return ret;
+}
+
+static ssize_t bfq_timeout_sync_store(struct elevator_queue *e,
+				      const char *page, size_t count)
+{
+	struct bfq_data *bfqd = e->elevator_data;
+	unsigned long uninitialized_var(__data);
+	int ret = bfq_var_store(&__data, (page), count);
+
+	if (__data < 1)
+		__data = 1;
+	else if (__data > INT_MAX)
+		__data = INT_MAX;
+
+	bfqd->bfq_timeout[BLK_RW_SYNC] = msecs_to_jiffies(__data);
+	if (bfqd->bfq_user_max_budget == 0)
+		bfqd->bfq_max_budget = bfq_estimated_max_budget(bfqd);
+
+	return ret;
+}
+
+#define BFQ_ATTR(name) \
+	__ATTR(name, S_IRUGO|S_IWUSR, bfq_##name##_show, bfq_##name##_store)
+
+static struct elv_fs_entry bfq_attrs[] = {
+	BFQ_ATTR(quantum),
+	BFQ_ATTR(fifo_expire_sync),
+	BFQ_ATTR(fifo_expire_async),
+	BFQ_ATTR(back_seek_max),
+	BFQ_ATTR(back_seek_penalty),
+	BFQ_ATTR(slice_idle),
+	BFQ_ATTR(max_budget),
+	BFQ_ATTR(max_budget_async_rq),
+	BFQ_ATTR(timeout_sync),
+	BFQ_ATTR(timeout_async),
+	BFQ_ATTR(weights),
+	__ATTR_NULL
+};
+
+static struct elevator_type iosched_bfq = {
+	.ops = {
+		.elevator_merge_fn =		bfq_merge,
+		.elevator_merged_fn =		bfq_merged_request,
+		.elevator_merge_req_fn =	bfq_merged_requests,
+		.elevator_allow_merge_fn =	bfq_allow_merge,
+		.elevator_dispatch_fn =		bfq_dispatch_requests,
+		.elevator_add_req_fn =		bfq_insert_request,
+		.elevator_activate_req_fn =	bfq_activate_request,
+		.elevator_deactivate_req_fn =	bfq_deactivate_request,
+		.elevator_completed_req_fn =	bfq_completed_request,
+		.elevator_former_req_fn =	elv_rb_former_request,
+		.elevator_latter_req_fn =	elv_rb_latter_request,
+		.elevator_init_icq_fn =		bfq_init_icq,
+		.elevator_exit_icq_fn =		bfq_exit_icq,
+		.elevator_set_req_fn =		bfq_set_request,
+		.elevator_put_req_fn =		bfq_put_request,
+		.elevator_may_queue_fn =	bfq_may_queue,
+		.elevator_init_fn =		bfq_init_queue,
+		.elevator_exit_fn =		bfq_exit_queue,
+	},
+	.icq_size =		sizeof(struct bfq_io_cq),
+	.icq_align =		__alignof__(struct bfq_io_cq),
+	.elevator_attrs =	bfq_attrs,
+	.elevator_name =	"bfq",
+	.elevator_owner =	THIS_MODULE,
+};
+
+static int __init bfq_init(void)
+{
+	/*
+	 * Can be 0 on HZ < 1000 setups.
+	 */
+	if (bfq_slice_idle == 0)
+		bfq_slice_idle = 1;
+
+	if (bfq_timeout_async == 0)
+		bfq_timeout_async = 1;
+
+	if (bfq_slab_setup())
+		return -ENOMEM;
+
+	elv_register(&iosched_bfq);
+	pr_info("BFQ I/O-scheduler version: v0");
+
+	return 0;
+}
+
+static void __exit bfq_exit(void)
+{
+	elv_unregister(&iosched_bfq);
+	bfq_slab_kill();
+}
+
+module_init(bfq_init);
+module_exit(bfq_exit);
+
+MODULE_AUTHOR("Fabio Checconi, Paolo Valente");
+MODULE_LICENSE("GPL");
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
new file mode 100644
index 0000000..a9142f5
--- /dev/null
+++ b/block/bfq-sched.c
@@ -0,0 +1,936 @@
+/*
+ * BFQ: Hierarchical B-WF2Q+ scheduler.
+ *
+ * Based on ideas and code from CFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ */
+
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = NULL)
+
+#define for_each_entity_safe(entity, parent) \
+	for (parent = NULL; entity != NULL; entity = parent)
+
+static inline int bfq_update_next_in_service(struct bfq_sched_data *sd)
+{
+	return 0;
+}
+
+static inline void bfq_check_next_in_service(struct bfq_sched_data *sd,
+					     struct bfq_entity *entity)
+{
+}
+
+static inline void bfq_update_budget(struct bfq_entity *next_in_service)
+{
+}
+
+/*
+ * Shift for timestamp calculations.  This actually limits the maximum
+ * service allowed in one timestamp delta (small shift values increase it),
+ * the maximum total weight that can be used for the queues in the system
+ * (big shift values increase it), and the period of virtual time
+ * wraparounds.
+ */
+#define WFQ_SERVICE_SHIFT	22
+
+/**
+ * bfq_gt - compare two timestamps.
+ * @a: first ts.
+ * @b: second ts.
+ *
+ * Return @a > @b, dealing with wrapping correctly.
+ */
+static inline int bfq_gt(u64 a, u64 b)
+{
+	return (s64)(a - b) > 0;
+}
+
+static inline struct bfq_queue *bfq_entity_to_bfqq(struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = NULL;
+
+	if (entity->my_sched_data == NULL)
+		bfqq = container_of(entity, struct bfq_queue, entity);
+
+	return bfqq;
+}
+
+
+/**
+ * bfq_delta - map service into the virtual time domain.
+ * @service: amount of service.
+ * @weight: scale factor (weight of an entity or weight sum).
+ */
+static inline u64 bfq_delta(unsigned long service,
+					unsigned long weight)
+{
+	u64 d = (u64)service << WFQ_SERVICE_SHIFT;
+
+	do_div(d, weight);
+	return d;
+}
+
+/**
+ * bfq_calc_finish - assign the finish time to an entity.
+ * @entity: the entity to act upon.
+ * @service: the service to be charged to the entity.
+ */
+static inline void bfq_calc_finish(struct bfq_entity *entity,
+				   unsigned long service)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+
+	entity->finish = entity->start +
+		bfq_delta(service, entity->weight);
+
+	if (bfqq != NULL) {
+		bfq_log_bfqq(bfqq->bfqd, bfqq,
+			"calc_finish: serv %lu, w %d",
+			service, entity->weight);
+		bfq_log_bfqq(bfqq->bfqd, bfqq,
+			"calc_finish: start %llu, finish %llu, delta %llu",
+			entity->start, entity->finish,
+			bfq_delta(service, entity->weight));
+	}
+}
+
+/**
+ * bfq_entity_of - get an entity from a node.
+ * @node: the node field of the entity.
+ *
+ * Convert a node pointer to the relative entity.  This is used only
+ * to simplify the logic of some functions and not as the generic
+ * conversion mechanism because, e.g., in the tree walking functions,
+ * the check for a %NULL value would be redundant.
+ */
+static inline struct bfq_entity *bfq_entity_of(struct rb_node *node)
+{
+	struct bfq_entity *entity = NULL;
+
+	if (node != NULL)
+		entity = rb_entry(node, struct bfq_entity, rb_node);
+
+	return entity;
+}
+
+/**
+ * bfq_extract - remove an entity from a tree.
+ * @root: the tree root.
+ * @entity: the entity to remove.
+ */
+static inline void bfq_extract(struct rb_root *root,
+			       struct bfq_entity *entity)
+{
+	entity->tree = NULL;
+	rb_erase(&entity->rb_node, root);
+}
+
+/**
+ * bfq_idle_extract - extract an entity from the idle tree.
+ * @st: the service tree of the owning @entity.
+ * @entity: the entity being removed.
+ */
+static void bfq_idle_extract(struct bfq_service_tree *st,
+			     struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+	struct rb_node *next;
+
+	if (entity == st->first_idle) {
+		next = rb_next(&entity->rb_node);
+		st->first_idle = bfq_entity_of(next);
+	}
+
+	if (entity == st->last_idle) {
+		next = rb_prev(&entity->rb_node);
+		st->last_idle = bfq_entity_of(next);
+	}
+
+	bfq_extract(&st->idle, entity);
+
+	if (bfqq != NULL)
+		list_del(&bfqq->bfqq_list);
+}
+
+/**
+ * bfq_insert - generic tree insertion.
+ * @root: tree root.
+ * @entity: entity to insert.
+ *
+ * This is used for the idle and the active tree, since they are both
+ * ordered by finish time.
+ */
+static void bfq_insert(struct rb_root *root, struct bfq_entity *entity)
+{
+	struct bfq_entity *entry;
+	struct rb_node **node = &root->rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*node != NULL) {
+		parent = *node;
+		entry = rb_entry(parent, struct bfq_entity, rb_node);
+
+		if (bfq_gt(entry->finish, entity->finish))
+			node = &parent->rb_left;
+		else
+			node = &parent->rb_right;
+	}
+
+	rb_link_node(&entity->rb_node, parent, node);
+	rb_insert_color(&entity->rb_node, root);
+
+	entity->tree = root;
+}
+
+/**
+ * bfq_update_min - update the min_start field of a entity.
+ * @entity: the entity to update.
+ * @node: one of its children.
+ *
+ * This function is called when @entity may store an invalid value for
+ * min_start due to updates to the active tree.  The function  assumes
+ * that the subtree rooted at @node (which may be its left or its right
+ * child) has a valid min_start value.
+ */
+static inline void bfq_update_min(struct bfq_entity *entity,
+				  struct rb_node *node)
+{
+	struct bfq_entity *child;
+
+	if (node != NULL) {
+		child = rb_entry(node, struct bfq_entity, rb_node);
+		if (bfq_gt(entity->min_start, child->min_start))
+			entity->min_start = child->min_start;
+	}
+}
+
+/**
+ * bfq_update_active_node - recalculate min_start.
+ * @node: the node to update.
+ *
+ * @node may have changed position or one of its children may have moved,
+ * this function updates its min_start value.  The left and right subtrees
+ * are assumed to hold a correct min_start value.
+ */
+static inline void bfq_update_active_node(struct rb_node *node)
+{
+	struct bfq_entity *entity = rb_entry(node, struct bfq_entity, rb_node);
+
+	entity->min_start = entity->start;
+	bfq_update_min(entity, node->rb_right);
+	bfq_update_min(entity, node->rb_left);
+}
+
+/**
+ * bfq_update_active_tree - update min_start for the whole active tree.
+ * @node: the starting node.
+ *
+ * @node must be the deepest modified node after an update.  This function
+ * updates its min_start using the values held by its children, assuming
+ * that they did not change, and then updates all the nodes that may have
+ * changed in the path to the root.  The only nodes that may have changed
+ * are the ones in the path or their siblings.
+ */
+static void bfq_update_active_tree(struct rb_node *node)
+{
+	struct rb_node *parent;
+
+up:
+	bfq_update_active_node(node);
+
+	parent = rb_parent(node);
+	if (parent == NULL)
+		return;
+
+	if (node == parent->rb_left && parent->rb_right != NULL)
+		bfq_update_active_node(parent->rb_right);
+	else if (parent->rb_left != NULL)
+		bfq_update_active_node(parent->rb_left);
+
+	node = parent;
+	goto up;
+}
+
+/**
+ * bfq_active_insert - insert an entity in the active tree of its
+ *                     group/device.
+ * @st: the service tree of the entity.
+ * @entity: the entity being inserted.
+ *
+ * The active tree is ordered by finish time, but an extra key is kept
+ * per each node, containing the minimum value for the start times of
+ * its children (and the node itself), so it's possible to search for
+ * the eligible node with the lowest finish time in logarithmic time.
+ */
+static void bfq_active_insert(struct bfq_service_tree *st,
+			      struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+	struct rb_node *node = &entity->rb_node;
+
+	bfq_insert(&st->active, entity);
+
+	if (node->rb_left != NULL)
+		node = node->rb_left;
+	else if (node->rb_right != NULL)
+		node = node->rb_right;
+
+	bfq_update_active_tree(node);
+
+	if (bfqq != NULL)
+		list_add(&bfqq->bfqq_list, &bfqq->bfqd->active_list);
+}
+
+/**
+ * bfq_ioprio_to_weight - calc a weight from an ioprio.
+ * @ioprio: the ioprio value to convert.
+ */
+static inline unsigned short bfq_ioprio_to_weight(int ioprio)
+{
+	return IOPRIO_BE_NR - ioprio;
+}
+
+/**
+ * bfq_weight_to_ioprio - calc an ioprio from a weight.
+ * @weight: the weight value to convert.
+ *
+ * To preserve as mush as possible the old only-ioprio user interface,
+ * 0 is used as an escape ioprio value for weights (numerically) equal or
+ * larger than IOPRIO_BE_NR
+ */
+static inline unsigned short bfq_weight_to_ioprio(int weight)
+{
+	return IOPRIO_BE_NR - weight < 0 ? 0 : IOPRIO_BE_NR - weight;
+}
+
+static inline void bfq_get_entity(struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+
+	if (bfqq != NULL) {
+		atomic_inc(&bfqq->ref);
+		bfq_log_bfqq(bfqq->bfqd, bfqq, "get_entity: %p %d",
+			     bfqq, atomic_read(&bfqq->ref));
+	}
+}
+
+/**
+ * bfq_find_deepest - find the deepest node that an extraction can modify.
+ * @node: the node being removed.
+ *
+ * Do the first step of an extraction in an rb tree, looking for the
+ * node that will replace @node, and returning the deepest node that
+ * the following modifications to the tree can touch.  If @node is the
+ * last node in the tree return %NULL.
+ */
+static struct rb_node *bfq_find_deepest(struct rb_node *node)
+{
+	struct rb_node *deepest;
+
+	if (node->rb_right == NULL && node->rb_left == NULL)
+		deepest = rb_parent(node);
+	else if (node->rb_right == NULL)
+		deepest = node->rb_left;
+	else if (node->rb_left == NULL)
+		deepest = node->rb_right;
+	else {
+		deepest = rb_next(node);
+		if (deepest->rb_right != NULL)
+			deepest = deepest->rb_right;
+		else if (rb_parent(deepest) != node)
+			deepest = rb_parent(deepest);
+	}
+
+	return deepest;
+}
+
+/**
+ * bfq_active_extract - remove an entity from the active tree.
+ * @st: the service_tree containing the tree.
+ * @entity: the entity being removed.
+ */
+static void bfq_active_extract(struct bfq_service_tree *st,
+			       struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+	struct rb_node *node;
+
+	node = bfq_find_deepest(&entity->rb_node);
+	bfq_extract(&st->active, entity);
+
+	if (node != NULL)
+		bfq_update_active_tree(node);
+
+	if (bfqq != NULL)
+		list_del(&bfqq->bfqq_list);
+}
+
+/**
+ * bfq_idle_insert - insert an entity into the idle tree.
+ * @st: the service tree containing the tree.
+ * @entity: the entity to insert.
+ */
+static void bfq_idle_insert(struct bfq_service_tree *st,
+			    struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+	struct bfq_entity *first_idle = st->first_idle;
+	struct bfq_entity *last_idle = st->last_idle;
+
+	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
+		st->first_idle = entity;
+	if (last_idle == NULL || bfq_gt(entity->finish, last_idle->finish))
+		st->last_idle = entity;
+
+	bfq_insert(&st->idle, entity);
+
+	if (bfqq != NULL)
+		list_add(&bfqq->bfqq_list, &bfqq->bfqd->idle_list);
+}
+
+/**
+ * bfq_forget_entity - remove an entity from the wfq trees.
+ * @st: the service tree.
+ * @entity: the entity being removed.
+ *
+ * Update the device status and forget everything about @entity, putting
+ * the device reference to it, if it is a queue.  Entities belonging to
+ * groups are not refcounted.
+ */
+static void bfq_forget_entity(struct bfq_service_tree *st,
+			      struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+	struct bfq_sched_data *sd;
+
+	entity->on_st = 0;
+	st->wsum -= entity->weight;
+	if (bfqq != NULL) {
+		sd = entity->sched_data;
+		bfq_log_bfqq(bfqq->bfqd, bfqq, "forget_entity: %p %d",
+			     bfqq, atomic_read(&bfqq->ref));
+		bfq_put_queue(bfqq);
+	}
+}
+
+/**
+ * bfq_put_idle_entity - release the idle tree ref of an entity.
+ * @st: service tree for the entity.
+ * @entity: the entity being released.
+ */
+static void bfq_put_idle_entity(struct bfq_service_tree *st,
+				struct bfq_entity *entity)
+{
+	bfq_idle_extract(st, entity);
+	bfq_forget_entity(st, entity);
+}
+
+/**
+ * bfq_forget_idle - update the idle tree if necessary.
+ * @st: the service tree to act upon.
+ *
+ * To preserve the global O(log N) complexity we only remove one entry here;
+ * as the idle tree will not grow indefinitely this can be done safely.
+ */
+static void bfq_forget_idle(struct bfq_service_tree *st)
+{
+	struct bfq_entity *first_idle = st->first_idle;
+	struct bfq_entity *last_idle = st->last_idle;
+
+	if (RB_EMPTY_ROOT(&st->active) && last_idle != NULL &&
+	    !bfq_gt(last_idle->finish, st->vtime)) {
+		/*
+		 * Forget the whole idle tree, increasing the vtime past
+		 * the last finish time of idle entities.
+		 */
+		st->vtime = last_idle->finish;
+	}
+
+	if (first_idle != NULL && !bfq_gt(first_idle->finish, st->vtime))
+		bfq_put_idle_entity(st, first_idle);
+}
+
+static struct bfq_service_tree *
+__bfq_entity_update_weight_prio(struct bfq_service_tree *old_st,
+			 struct bfq_entity *entity)
+{
+	struct bfq_service_tree *new_st = old_st;
+
+	if (entity->ioprio_changed) {
+		old_st->wsum -= entity->weight;
+
+		if (entity->new_weight != entity->orig_weight) {
+			entity->orig_weight = entity->new_weight;
+			entity->ioprio =
+				bfq_weight_to_ioprio(entity->orig_weight);
+		} else if (entity->new_ioprio != entity->ioprio) {
+			entity->ioprio = entity->new_ioprio;
+			entity->orig_weight =
+					bfq_ioprio_to_weight(entity->ioprio);
+		} else
+			entity->new_weight = entity->orig_weight =
+				bfq_ioprio_to_weight(entity->ioprio);
+
+		entity->ioprio_class = entity->new_ioprio_class;
+		entity->ioprio_changed = 0;
+
+		/*
+		 * NOTE: here we may be changing the weight too early,
+		 * this will cause unfairness.  The correct approach
+		 * would have required additional complexity to defer
+		 * weight changes to the proper time instants (i.e.,
+		 * when entity->finish <= old_st->vtime).
+		 */
+		new_st = bfq_entity_service_tree(entity);
+		entity->weight = entity->orig_weight;
+		new_st->wsum += entity->weight;
+
+		if (new_st != old_st)
+			entity->start = new_st->vtime;
+	}
+
+	return new_st;
+}
+
+/**
+ * bfq_bfqq_served - update the scheduler status after selection for
+ *                   service.
+ * @bfqq: the queue being served.
+ * @served: bytes to transfer.
+ *
+ * NOTE: this can be optimized, as the timestamps of upper level entities
+ * are synchronized every time a new bfqq is selected for service.  By now,
+ * we keep it to better check consistency.
+ */
+static void bfq_bfqq_served(struct bfq_queue *bfqq, unsigned long served)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+	struct bfq_service_tree *st;
+
+	for_each_entity(entity) {
+		st = bfq_entity_service_tree(entity);
+
+		entity->service += served;
+
+		st->vtime += bfq_delta(served, st->wsum);
+		bfq_forget_idle(st);
+	}
+	bfq_log_bfqq(bfqq->bfqd, bfqq, "bfqq_served %lu secs", served);
+}
+
+/**
+ * bfq_bfqq_charge_full_budget - set the service to the entity budget.
+ * @bfqq: the queue that needs a service update.
+ *
+ * When it's not possible to be fair in the service domain, because
+ * a queue is not consuming its budget fast enough (the meaning of
+ * fast depends on the timeout parameter), we charge it a full
+ * budget.  In this way we should obtain a sort of time-domain
+ * fairness among all the seeky/slow queues.
+ */
+static inline void bfq_bfqq_charge_full_budget(struct bfq_queue *bfqq)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+
+	bfq_log_bfqq(bfqq->bfqd, bfqq, "charge_full_budget");
+
+	bfq_bfqq_served(bfqq, entity->budget - entity->service);
+}
+
+/**
+ * __bfq_activate_entity - activate an entity.
+ * @entity: the entity being activated.
+ *
+ * Called whenever an entity is activated, i.e., it is not active and one
+ * of its children receives a new request, or has to be reactivated due to
+ * budget exhaustion.  It uses the current budget of the entity (and the
+ * service received if @entity is active) of the queue to calculate its
+ * timestamps.
+ */
+static void __bfq_activate_entity(struct bfq_entity *entity)
+{
+	struct bfq_sched_data *sd = entity->sched_data;
+	struct bfq_service_tree *st = bfq_entity_service_tree(entity);
+
+	if (entity == sd->in_service_entity) {
+		/*
+		 * If we are requeueing the current entity we have
+		 * to take care of not charging to it service it has
+		 * not received.
+		 */
+		bfq_calc_finish(entity, entity->service);
+		entity->start = entity->finish;
+		sd->in_service_entity = NULL;
+	} else if (entity->tree == &st->active) {
+		/*
+		 * Requeueing an entity due to a change of some
+		 * next_in_service entity below it.  We reuse the
+		 * old start time.
+		 */
+		bfq_active_extract(st, entity);
+	} else if (entity->tree == &st->idle) {
+		/*
+		 * Must be on the idle tree, bfq_idle_extract() will
+		 * check for that.
+		 */
+		bfq_idle_extract(st, entity);
+		entity->start = bfq_gt(st->vtime, entity->finish) ?
+				       st->vtime : entity->finish;
+	} else {
+		/*
+		 * The finish time of the entity may be invalid, and
+		 * it is in the past for sure, otherwise the queue
+		 * would have been on the idle tree.
+		 */
+		entity->start = st->vtime;
+		st->wsum += entity->weight;
+		bfq_get_entity(entity);
+
+		entity->on_st = 1;
+	}
+
+	st = __bfq_entity_update_weight_prio(st, entity);
+	bfq_calc_finish(entity, entity->budget);
+	bfq_active_insert(st, entity);
+}
+
+/**
+ * bfq_activate_entity - activate an entity and its ancestors if necessary.
+ * @entity: the entity to activate.
+ *
+ * Activate @entity and all the entities on the path from it to the root.
+ */
+static void bfq_activate_entity(struct bfq_entity *entity)
+{
+	struct bfq_sched_data *sd;
+
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity);
+
+		sd = entity->sched_data;
+		if (!bfq_update_next_in_service(sd))
+			/*
+			 * No need to propagate the activation to the
+			 * upper entities, as they will be updated when
+			 * the in-service entity is rescheduled.
+			 */
+			break;
+	}
+}
+
+/**
+ * __bfq_deactivate_entity - deactivate an entity from its service tree.
+ * @entity: the entity to deactivate.
+ * @requeue: if false, the entity will not be put into the idle tree.
+ *
+ * Deactivate an entity, independently from its previous state.  If the
+ * entity was not on a service tree just return, otherwise if it is on
+ * any scheduler tree, extract it from that tree, and if necessary
+ * and if the caller did not specify @requeue, put it on the idle tree.
+ *
+ * Return %1 if the caller should update the entity hierarchy, i.e.,
+ * if the entity was in service or if it was the next_in_service for
+ * its sched_data; return %0 otherwise.
+ */
+static int __bfq_deactivate_entity(struct bfq_entity *entity, int requeue)
+{
+	struct bfq_sched_data *sd = entity->sched_data;
+	struct bfq_service_tree *st = bfq_entity_service_tree(entity);
+	int was_in_service = entity == sd->in_service_entity;
+	int ret = 0;
+
+	if (!entity->on_st)
+		return 0;
+
+	if (was_in_service) {
+		bfq_calc_finish(entity, entity->service);
+		sd->in_service_entity = NULL;
+	} else if (entity->tree == &st->active)
+		bfq_active_extract(st, entity);
+	else if (entity->tree == &st->idle)
+		bfq_idle_extract(st, entity);
+
+	if (was_in_service || sd->next_in_service == entity)
+		ret = bfq_update_next_in_service(sd);
+
+	if (!requeue || !bfq_gt(entity->finish, st->vtime))
+		bfq_forget_entity(st, entity);
+	else
+		bfq_idle_insert(st, entity);
+
+	return ret;
+}
+
+/**
+ * bfq_deactivate_entity - deactivate an entity.
+ * @entity: the entity to deactivate.
+ * @requeue: true if the entity can be put on the idle tree
+ */
+static void bfq_deactivate_entity(struct bfq_entity *entity, int requeue)
+{
+	struct bfq_sched_data *sd;
+	struct bfq_entity *parent;
+
+	for_each_entity_safe(entity, parent) {
+		sd = entity->sched_data;
+
+		if (!__bfq_deactivate_entity(entity, requeue))
+			/*
+			 * The parent entity is still backlogged, and
+			 * we don't need to update it as it is still
+			 * in service.
+			 */
+			break;
+
+		if (sd->next_in_service != NULL)
+			/*
+			 * The parent entity is still backlogged and
+			 * the budgets on the path towards the root
+			 * need to be updated.
+			 */
+			goto update;
+
+		/*
+		 * If we reach there the parent is no more backlogged and
+		 * we want to propagate the dequeue upwards.
+		 */
+		requeue = 1;
+	}
+
+	return;
+
+update:
+	entity = parent;
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity);
+
+		sd = entity->sched_data;
+		if (!bfq_update_next_in_service(sd))
+			break;
+	}
+}
+
+/**
+ * bfq_update_vtime - update vtime if necessary.
+ * @st: the service tree to act upon.
+ *
+ * If necessary update the service tree vtime to have at least one
+ * eligible entity, skipping to its start time.  Assumes that the
+ * active tree of the device is not empty.
+ *
+ * NOTE: this hierarchical implementation updates vtimes quite often,
+ * we may end up with reactivated processes getting timestamps after a
+ * vtime skip done because we needed a ->first_active entity on some
+ * intermediate node.
+ */
+static void bfq_update_vtime(struct bfq_service_tree *st)
+{
+	struct bfq_entity *entry;
+	struct rb_node *node = st->active.rb_node;
+
+	entry = rb_entry(node, struct bfq_entity, rb_node);
+	if (bfq_gt(entry->min_start, st->vtime)) {
+		st->vtime = entry->min_start;
+		bfq_forget_idle(st);
+	}
+}
+
+/**
+ * bfq_first_active_entity - find the eligible entity with
+ *                           the smallest finish time
+ * @st: the service tree to select from.
+ *
+ * This function searches the first schedulable entity, starting from the
+ * root of the tree and going on the left every time on this side there is
+ * a subtree with at least one eligible (start >= vtime) entity. The path on
+ * the right is followed only if a) the left subtree contains no eligible
+ * entities and b) no eligible entity has been found yet.
+ */
+static struct bfq_entity *bfq_first_active_entity(struct bfq_service_tree *st)
+{
+	struct bfq_entity *entry, *first = NULL;
+	struct rb_node *node = st->active.rb_node;
+
+	while (node != NULL) {
+		entry = rb_entry(node, struct bfq_entity, rb_node);
+left:
+		if (!bfq_gt(entry->start, st->vtime))
+			first = entry;
+
+		if (node->rb_left != NULL) {
+			entry = rb_entry(node->rb_left,
+					 struct bfq_entity, rb_node);
+			if (!bfq_gt(entry->min_start, st->vtime)) {
+				node = node->rb_left;
+				goto left;
+			}
+		}
+		if (first != NULL)
+			break;
+		node = node->rb_right;
+	}
+
+	return first;
+}
+
+/**
+ * __bfq_lookup_next_entity - return the first eligible entity in @st.
+ * @st: the service tree.
+ *
+ * Update the virtual time in @st and return the first eligible entity
+ * it contains.
+ */
+static struct bfq_entity *__bfq_lookup_next_entity(struct bfq_service_tree *st,
+						   bool force)
+{
+	struct bfq_entity *entity, *new_next_in_service = NULL;
+
+	if (RB_EMPTY_ROOT(&st->active))
+		return NULL;
+
+	bfq_update_vtime(st);
+	entity = bfq_first_active_entity(st);
+
+	/*
+	 * If the chosen entity does not match with the sched_data's
+	 * next_in_service and we are forcedly serving the IDLE priority
+	 * class tree, bubble up budget update.
+	 */
+	if (unlikely(force && entity != entity->sched_data->next_in_service)) {
+		new_next_in_service = entity;
+		for_each_entity(new_next_in_service)
+			bfq_update_budget(new_next_in_service);
+	}
+
+	return entity;
+}
+
+/**
+ * bfq_lookup_next_entity - return the first eligible entity in @sd.
+ * @sd: the sched_data.
+ * @extract: if true the returned entity will be also extracted from @sd.
+ *
+ * NOTE: since we cache the next_in_service entity at each level of the
+ * hierarchy, the complexity of the lookup can be decreased with
+ * absolutely no effort just returning the cached next_in_service value;
+ * we prefer to do full lookups to test the consistency of * the data
+ * structures.
+ */
+static struct bfq_entity *bfq_lookup_next_entity(struct bfq_sched_data *sd,
+						 int extract,
+						 struct bfq_data *bfqd)
+{
+	struct bfq_service_tree *st = sd->service_tree;
+	struct bfq_entity *entity;
+	int i = 0;
+
+	if (bfqd != NULL &&
+	    jiffies - bfqd->bfq_class_idle_last_service > BFQ_CL_IDLE_TIMEOUT) {
+		entity = __bfq_lookup_next_entity(st + BFQ_IOPRIO_CLASSES - 1,
+						  true);
+		if (entity != NULL) {
+			i = BFQ_IOPRIO_CLASSES - 1;
+			bfqd->bfq_class_idle_last_service = jiffies;
+			sd->next_in_service = entity;
+		}
+	}
+	for (; i < BFQ_IOPRIO_CLASSES; i++) {
+		entity = __bfq_lookup_next_entity(st + i, false);
+		if (entity != NULL) {
+			if (extract) {
+				bfq_check_next_in_service(sd, entity);
+				bfq_active_extract(st + i, entity);
+				sd->in_service_entity = entity;
+				sd->next_in_service = NULL;
+			}
+			break;
+		}
+	}
+
+	return entity;
+}
+
+/*
+ * Get next queue for service.
+ */
+static struct bfq_queue *bfq_get_next_queue(struct bfq_data *bfqd)
+{
+	struct bfq_entity *entity = NULL;
+	struct bfq_sched_data *sd;
+	struct bfq_queue *bfqq;
+
+	if (bfqd->busy_queues == 0)
+		return NULL;
+
+	sd = &bfqd->sched_data;
+	for (; sd != NULL; sd = entity->my_sched_data) {
+		entity = bfq_lookup_next_entity(sd, 1, bfqd);
+		entity->service = 0;
+	}
+
+	bfqq = bfq_entity_to_bfqq(entity);
+
+	return bfqq;
+}
+
+static void __bfq_bfqd_reset_in_service(struct bfq_data *bfqd)
+{
+	if (bfqd->in_service_bic != NULL) {
+		put_io_context(bfqd->in_service_bic->icq.ioc);
+		bfqd->in_service_bic = NULL;
+	}
+
+	bfqd->in_service_queue = NULL;
+	del_timer(&bfqd->idle_slice_timer);
+}
+
+static void bfq_deactivate_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq,
+				int requeue)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+
+	if (bfqq == bfqd->in_service_queue)
+		__bfq_bfqd_reset_in_service(bfqd);
+
+	bfq_deactivate_entity(entity, requeue);
+}
+
+static void bfq_activate_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq)
+{
+	struct bfq_entity *entity = &bfqq->entity;
+
+	bfq_activate_entity(entity);
+}
+
+/*
+ * Called when the bfqq no longer has requests pending, remove it from
+ * the service tree.
+ */
+static void bfq_del_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq,
+			      int requeue)
+{
+	bfq_log_bfqq(bfqd, bfqq, "del from busy");
+
+	bfq_clear_bfqq_busy(bfqq);
+
+	bfqd->busy_queues--;
+
+	bfq_deactivate_bfqq(bfqd, bfqq, requeue);
+}
+
+/*
+ * Called when an inactive queue receives a new request.
+ */
+static void bfq_add_bfqq_busy(struct bfq_data *bfqd, struct bfq_queue *bfqq)
+{
+	bfq_log_bfqq(bfqd, bfqq, "add to busy");
+
+	bfq_activate_bfqq(bfqd, bfqq);
+
+	bfq_mark_bfqq_busy(bfqq);
+	bfqd->busy_queues++;
+}
diff --git a/block/bfq.h b/block/bfq.h
new file mode 100644
index 0000000..bd146b6
--- /dev/null
+++ b/block/bfq.h
@@ -0,0 +1,467 @@
+/*
+ * BFQ-v0 for 3.15.0: data structures and common functions prototypes.
+ *
+ * Based on ideas and code from CFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ */
+
+#ifndef _BFQ_H
+#define _BFQ_H
+
+#include <linux/blktrace_api.h>
+#include <linux/hrtimer.h>
+#include <linux/ioprio.h>
+#include <linux/rbtree.h>
+
+#define BFQ_IOPRIO_CLASSES	3
+#define BFQ_CL_IDLE_TIMEOUT	(HZ/5)
+
+#define BFQ_MIN_WEIGHT	1
+#define BFQ_MAX_WEIGHT	1000
+
+#define BFQ_DEFAULT_GRP_WEIGHT	10
+#define BFQ_DEFAULT_GRP_IOPRIO	0
+#define BFQ_DEFAULT_GRP_CLASS	IOPRIO_CLASS_BE
+
+struct bfq_entity;
+
+/**
+ * struct bfq_service_tree - per ioprio_class service tree.
+ * @active: tree for active entities (i.e., those backlogged).
+ * @idle: tree for idle entities (i.e., those not backlogged, with V <= F_i).
+ * @first_idle: idle entity with minimum F_i.
+ * @last_idle: idle entity with maximum F_i.
+ * @vtime: scheduler virtual time.
+ * @wsum: scheduler weight sum; active and idle entities contribute to it.
+ *
+ * Each service tree represents a B-WF2Q+ scheduler on its own.  Each
+ * ioprio_class has its own independent scheduler, and so its own
+ * bfq_service_tree.  All the fields are protected by the queue lock
+ * of the containing bfqd.
+ */
+struct bfq_service_tree {
+	struct rb_root active;
+	struct rb_root idle;
+
+	struct bfq_entity *first_idle;
+	struct bfq_entity *last_idle;
+
+	u64 vtime;
+	unsigned long wsum;
+};
+
+/**
+ * struct bfq_sched_data - multi-class scheduler.
+ * @in_service_entity: entity in service.
+ * @next_in_service: head-of-the-line entity in the scheduler.
+ * @service_tree: array of service trees, one per ioprio_class.
+ *
+ * bfq_sched_data is the basic scheduler queue.  It supports three
+ * ioprio_classes, and can be used either as a toplevel queue or as
+ * an intermediate queue on a hierarchical setup.
+ * @next_in_service points to the active entity of the sched_data
+ * service trees that will be scheduled next.
+ *
+ * The supported ioprio_classes are the same as in CFQ, in descending
+ * priority order, IOPRIO_CLASS_RT, IOPRIO_CLASS_BE, IOPRIO_CLASS_IDLE.
+ * Requests from higher priority queues are served before all the
+ * requests from lower priority queues; among requests of the same
+ * queue requests are served according to B-WF2Q+.
+ * All the fields are protected by the queue lock of the containing bfqd.
+ */
+struct bfq_sched_data {
+	struct bfq_entity *in_service_entity;
+	struct bfq_entity *next_in_service;
+	struct bfq_service_tree service_tree[BFQ_IOPRIO_CLASSES];
+};
+
+/**
+ * struct bfq_entity - schedulable entity.
+ * @rb_node: service_tree member.
+ * @on_st: flag, true if the entity is on a tree (either the active or
+ *         the idle one of its service_tree).
+ * @finish: B-WF2Q+ finish timestamp (aka F_i).
+ * @start: B-WF2Q+ start timestamp (aka S_i).
+ * @tree: tree the entity is enqueued into; %NULL if not on a tree.
+ * @min_start: minimum start time of the (active) subtree rooted at
+ *             this entity; used for O(log N) lookups into active trees.
+ * @service: service received during the last round of service.
+ * @budget: budget used to calculate F_i; F_i = S_i + @budget / @weight.
+ * @weight: weight of the queue
+ * @parent: parent entity, for hierarchical scheduling.
+ * @my_sched_data: for non-leaf nodes in the hierarchy, the
+ *                 associated scheduler queue, %NULL on leaf nodes.
+ * @sched_data: the scheduler queue this entity belongs to.
+ * @ioprio: the ioprio in use.
+ * @new_weight: when a weight change is requested, the new weight value.
+ * @orig_weight: original weight, used to implement weight boosting
+ * @new_ioprio: when an ioprio change is requested, the new ioprio value.
+ * @ioprio_class: the ioprio_class in use.
+ * @new_ioprio_class: when an ioprio_class change is requested, the new
+ *                    ioprio_class value.
+ * @ioprio_changed: flag, true when the user requested a weight, ioprio or
+ *                  ioprio_class change.
+ *
+ * A bfq_entity is used to represent a bfq_queue (leaf node in the upper
+ * level scheduler). Each entity belongs to the sched_data of the parent
+ * group hierarchy. Non-leaf entities have also their own sched_data,
+ * stored in @my_sched_data.
+ *
+ * Each entity stores independently its priority values; this would
+ * allow different weights on different devices, but this
+ * functionality is not exported to userspace by now.  Priorities and
+ * weights are updated lazily, first storing the new values into the
+ * new_* fields, then setting the @ioprio_changed flag.  As soon as
+ * there is a transition in the entity state that allows the priority
+ * update to take place the effective and the requested priority
+ * values are synchronized.
+ *
+ * The weight value is calculated from the ioprio to export the same
+ * interface as CFQ.  When dealing with  ``well-behaved'' queues (i.e.,
+ * queues that do not spend too much time to consume their budget
+ * and have true sequential behavior, and when there are no external
+ * factors breaking anticipation) the relative weights at each level
+ * of the hierarchy should be guaranteed.  All the fields are
+ * protected by the queue lock of the containing bfqd.
+ */
+struct bfq_entity {
+	struct rb_node rb_node;
+
+	int on_st;
+
+	u64 finish;
+	u64 start;
+
+	struct rb_root *tree;
+
+	u64 min_start;
+
+	unsigned long service, budget;
+	unsigned short weight, new_weight;
+	unsigned short orig_weight;
+
+	struct bfq_entity *parent;
+
+	struct bfq_sched_data *my_sched_data;
+	struct bfq_sched_data *sched_data;
+
+	unsigned short ioprio, new_ioprio;
+	unsigned short ioprio_class, new_ioprio_class;
+
+	int ioprio_changed;
+};
+
+/**
+ * struct bfq_queue - leaf schedulable entity.
+ * @ref: reference counter.
+ * @bfqd: parent bfq_data.
+ * @sort_list: sorted list of pending requests.
+ * @next_rq: if fifo isn't expired, next request to serve.
+ * @queued: nr of requests queued in @sort_list.
+ * @allocated: currently allocated requests.
+ * @meta_pending: pending metadata requests.
+ * @fifo: fifo list of requests in sort_list.
+ * @entity: entity representing this queue in the scheduler.
+ * @max_budget: maximum budget allowed from the feedback mechanism.
+ * @budget_timeout: budget expiration (in jiffies).
+ * @dispatched: number of requests on the dispatch list or inside driver.
+ * @flags: status flags.
+ * @bfqq_list: node for active/idle bfqq list inside our bfqd.
+ * @seek_samples: number of seeks sampled
+ * @seek_total: sum of the distances of the seeks sampled
+ * @seek_mean: mean seek distance
+ * @last_request_pos: position of the last request enqueued
+ * @pid: pid of the process owning the queue, used for logging purposes.
+ *
+ * A bfq_queue is a leaf request queue; it can be associated with an
+ * io_context or more, if it is async.
+ */
+struct bfq_queue {
+	atomic_t ref;
+	struct bfq_data *bfqd;
+
+	struct rb_root sort_list;
+	struct request *next_rq;
+	int queued[2];
+	int allocated[2];
+	int meta_pending;
+	struct list_head fifo;
+
+	struct bfq_entity entity;
+
+	unsigned long max_budget;
+	unsigned long budget_timeout;
+
+	int dispatched;
+
+	unsigned int flags;
+
+	struct list_head bfqq_list;
+
+	unsigned int seek_samples;
+	u64 seek_total;
+	sector_t seek_mean;
+	sector_t last_request_pos;
+
+	pid_t pid;
+};
+
+/**
+ * struct bfq_ttime - per process thinktime stats.
+ * @ttime_total: total process thinktime
+ * @ttime_samples: number of thinktime samples
+ * @ttime_mean: average process thinktime
+ */
+struct bfq_ttime {
+	unsigned long last_end_request;
+
+	unsigned long ttime_total;
+	unsigned long ttime_samples;
+	unsigned long ttime_mean;
+};
+
+/**
+ * struct bfq_io_cq - per (request_queue, io_context) structure.
+ * @icq: associated io_cq structure
+ * @bfqq: array of two process queues, the sync and the async
+ * @ttime: associated @bfq_ttime struct
+ */
+struct bfq_io_cq {
+	struct io_cq icq; /* must be the first member */
+	struct bfq_queue *bfqq[2];
+	struct bfq_ttime ttime;
+	int ioprio;
+};
+
+enum bfq_device_speed {
+	BFQ_BFQD_FAST,
+	BFQ_BFQD_SLOW,
+};
+
+/**
+ * struct bfq_data - per device data structure.
+ * @queue: request queue for the managed device.
+ * @sched_data: root @bfq_sched_data for the device.
+ * @busy_queues: number of bfq_queues containing requests (including the
+ *		 queue in service, even if it is idling).
+ * @queued: number of queued requests.
+ * @rq_in_driver: number of requests dispatched and waiting for completion.
+ * @sync_flight: number of sync requests in the driver.
+ * @max_rq_in_driver: max number of reqs in driver in the last
+ *                    @hw_tag_samples completed requests.
+ * @hw_tag_samples: nr of samples used to calculate hw_tag.
+ * @hw_tag: flag set to one if the driver is showing a queueing behavior.
+ * @budgets_assigned: number of budgets assigned.
+ * @idle_slice_timer: timer set when idling for the next sequential request
+ *                    from the queue in service.
+ * @unplug_work: delayed work to restart dispatching on the request queue.
+ * @in_service_queue: bfq_queue in service.
+ * @in_service_bic: bfq_io_cq (bic) associated with the @in_service_queue.
+ * @last_position: on-disk position of the last served request.
+ * @last_budget_start: beginning of the last budget.
+ * @last_idling_start: beginning of the last idle slice.
+ * @peak_rate: peak transfer rate observed for a budget.
+ * @peak_rate_samples: number of samples used to calculate @peak_rate.
+ * @bfq_max_budget: maximum budget allotted to a bfq_queue before
+ *                  rescheduling.
+ * @active_list: list of all the bfq_queues active on the device.
+ * @idle_list: list of all the bfq_queues idle on the device.
+ * @bfq_quantum: max number of requests dispatched per dispatch round.
+ * @bfq_fifo_expire: timeout for async/sync requests; when it expires
+ *                   requests are served in fifo order.
+ * @bfq_back_penalty: weight of backward seeks wrt forward ones.
+ * @bfq_back_max: maximum allowed backward seek.
+ * @bfq_slice_idle: maximum idling time.
+ * @bfq_user_max_budget: user-configured max budget value
+ *                       (0 for auto-tuning).
+ * @bfq_max_budget_async_rq: maximum budget (in nr of requests) allotted to
+ *                           async queues.
+ * @bfq_timeout: timeout for bfq_queues to consume their budget; used to
+ *               to prevent seeky queues to impose long latencies to well
+ *               behaved ones (this also implies that seeky queues cannot
+ *               receive guarantees in the service domain; after a timeout
+ *               they are charged for the whole allocated budget, to try
+ *               to preserve a behavior reasonably fair among them, but
+ *               without service-domain guarantees).
+ * @oom_bfqq: fallback dummy bfqq for extreme OOM conditions
+ *
+ * All the fields are protected by the @queue lock.
+ */
+struct bfq_data {
+	struct request_queue *queue;
+
+	struct bfq_sched_data sched_data;
+
+	int busy_queues;
+	int queued;
+	int rq_in_driver;
+	int sync_flight;
+
+	int max_rq_in_driver;
+	int hw_tag_samples;
+	int hw_tag;
+
+	int budgets_assigned;
+
+	struct timer_list idle_slice_timer;
+	struct work_struct unplug_work;
+
+	struct bfq_queue *in_service_queue;
+	struct bfq_io_cq *in_service_bic;
+
+	sector_t last_position;
+
+	ktime_t last_budget_start;
+	ktime_t last_idling_start;
+	int peak_rate_samples;
+	u64 peak_rate;
+	unsigned long bfq_max_budget;
+
+	struct list_head active_list;
+	struct list_head idle_list;
+
+	unsigned int bfq_quantum;
+	unsigned int bfq_fifo_expire[2];
+	unsigned int bfq_back_penalty;
+	unsigned int bfq_back_max;
+	unsigned int bfq_slice_idle;
+	u64 bfq_class_idle_last_service;
+
+	unsigned int bfq_user_max_budget;
+	unsigned int bfq_max_budget_async_rq;
+	unsigned int bfq_timeout[2];
+
+	struct bfq_queue oom_bfqq;
+};
+
+enum bfqq_state_flags {
+	BFQ_BFQQ_FLAG_busy = 0,		/* has requests or is in service */
+	BFQ_BFQQ_FLAG_wait_request,	/* waiting for a request */
+	BFQ_BFQQ_FLAG_must_alloc,	/* must be allowed rq alloc */
+	BFQ_BFQQ_FLAG_fifo_expire,	/* FIFO checked in this slice */
+	BFQ_BFQQ_FLAG_idle_window,	/* slice idling enabled */
+	BFQ_BFQQ_FLAG_prio_changed,	/* task priority has changed */
+	BFQ_BFQQ_FLAG_sync,		/* synchronous queue */
+	BFQ_BFQQ_FLAG_budget_new,	/* no completion with this budget */
+};
+
+#define BFQ_BFQQ_FNS(name)						\
+static inline void bfq_mark_bfqq_##name(struct bfq_queue *bfqq)		\
+{									\
+	(bfqq)->flags |= (1 << BFQ_BFQQ_FLAG_##name);			\
+}									\
+static inline void bfq_clear_bfqq_##name(struct bfq_queue *bfqq)	\
+{									\
+	(bfqq)->flags &= ~(1 << BFQ_BFQQ_FLAG_##name);			\
+}									\
+static inline int bfq_bfqq_##name(const struct bfq_queue *bfqq)		\
+{									\
+	return ((bfqq)->flags & (1 << BFQ_BFQQ_FLAG_##name)) != 0;	\
+}
+
+BFQ_BFQQ_FNS(busy);
+BFQ_BFQQ_FNS(wait_request);
+BFQ_BFQQ_FNS(must_alloc);
+BFQ_BFQQ_FNS(fifo_expire);
+BFQ_BFQQ_FNS(idle_window);
+BFQ_BFQQ_FNS(prio_changed);
+BFQ_BFQQ_FNS(sync);
+BFQ_BFQQ_FNS(budget_new);
+#undef BFQ_BFQQ_FNS
+
+/* Logging facilities. */
+#define bfq_log_bfqq(bfqd, bfqq, fmt, args...) \
+	blk_add_trace_msg((bfqd)->queue, "bfq%d " fmt, (bfqq)->pid, ##args)
+
+#define bfq_log(bfqd, fmt, args...) \
+	blk_add_trace_msg((bfqd)->queue, "bfq " fmt, ##args)
+
+/* Expiration reasons. */
+enum bfqq_expiration {
+	BFQ_BFQQ_TOO_IDLE = 0,		/*
+					 * queue has been idling for
+					 * too long
+					 */
+	BFQ_BFQQ_BUDGET_TIMEOUT,	/* budget took too long to be used */
+	BFQ_BFQQ_BUDGET_EXHAUSTED,	/* budget consumed */
+	BFQ_BFQQ_NO_MORE_REQUESTS,	/* the queue has no more requests */
+};
+
+static inline struct bfq_service_tree *
+bfq_entity_service_tree(struct bfq_entity *entity)
+{
+	struct bfq_sched_data *sched_data = entity->sched_data;
+	unsigned int idx = entity->ioprio_class - 1;
+
+	return sched_data->service_tree + idx;
+}
+
+static inline struct bfq_queue *bic_to_bfqq(struct bfq_io_cq *bic,
+					    int is_sync)
+{
+	return bic->bfqq[!!is_sync];
+}
+
+static inline void bic_set_bfqq(struct bfq_io_cq *bic,
+				struct bfq_queue *bfqq, int is_sync)
+{
+	bic->bfqq[!!is_sync] = bfqq;
+}
+
+static inline struct bfq_data *bic_to_bfqd(struct bfq_io_cq *bic)
+{
+	return bic->icq.q->elevator->elevator_data;
+}
+
+/**
+ * bfq_get_bfqd_locked - get a lock to a bfqd using a RCU protected pointer.
+ * @ptr: a pointer to a bfqd.
+ * @flags: storage for the flags to be saved.
+ *
+ * This function allows bfqg->bfqd to be protected by the
+ * queue lock of the bfqd they reference; the pointer is dereferenced
+ * under RCU, so the storage for bfqd is assured to be safe as long
+ * as the RCU read side critical section does not end.  After the
+ * bfqd->queue->queue_lock is taken the pointer is rechecked, to be
+ * sure that no other writer accessed it.  If we raced with a writer,
+ * the function returns NULL, with the queue unlocked, otherwise it
+ * returns the dereferenced pointer, with the queue locked.
+ */
+static inline struct bfq_data *bfq_get_bfqd_locked(void **ptr,
+						   unsigned long *flags)
+{
+	struct bfq_data *bfqd;
+
+	rcu_read_lock();
+	bfqd = rcu_dereference(*(struct bfq_data **)ptr);
+
+	if (bfqd != NULL) {
+		spin_lock_irqsave(bfqd->queue->queue_lock, *flags);
+		if (*ptr == bfqd)
+			goto out;
+		spin_unlock_irqrestore(bfqd->queue->queue_lock, *flags);
+	}
+
+	bfqd = NULL;
+out:
+	rcu_read_unlock();
+	return bfqd;
+}
+
+static inline void bfq_put_bfqd_unlock(struct bfq_data *bfqd,
+				       unsigned long *flags)
+{
+	spin_unlock_irqrestore(bfqd->queue->queue_lock, *flags);
+}
+
+static void bfq_changed_ioprio(struct bfq_io_cq *bic);
+static void bfq_put_queue(struct bfq_queue *bfqq);
+static void bfq_dispatch_insert(struct request_queue *q, struct request *rq);
+static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd, int is_sync,
+				       struct bfq_io_cq *bic, gfp_t gfp_mask);
+static void bfq_exit_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq);
+
+#endif /* _BFQ_H */
-- 
1.9.2
