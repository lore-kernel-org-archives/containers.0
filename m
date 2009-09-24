From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 16/28] io-controller: Wait for requests to complete from last
	queue before new queue is scheduled
Date: Thu, 24 Sep 2009 15:25:20 -0400
Message-ID: <1253820332-10246-17-git-send-email-vgoyal__6174.4888349951$1253823883$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253820332-10246-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

o Currently one can dispatch requests from multiple queues to the disk. This
  is true for hardware which supports queuing. So if a disk support queue
  depth of 31 it is possible that 20 requests are dispatched from queue 1
  and then next queue is scheduled in which dispatches more requests.

o This multiple queue dispatch introduces issues for accurate accounting of
  disk time consumed by a particular queue. For example, if one async queue
  is scheduled in, it can dispatch 31 requests to the disk and then it will
  be expired and a new sync queue might get scheduled in. These 31 requests
  might take a long time to finish but this time is never accounted to the
  async queue which dispatched these requests.

o This patch introduces the functionality where we wait for all the requests
  to finish from previous queue before next queue is scheduled in. That way
  a queue is more accurately accounted for disk time it has consumed. Note
  this still does not take care of errors introduced by disk write caching.

o Because above behavior can result in reduced throughput, this behavior will
  be enabled only if user sets "fairness" tunable to 1.

o This patch helps in achieving more isolation between reads and buffered
  writes in different cgroups. buffered writes typically utilize full queue
  depth and then expire the queue. On the contarary, sequential reads
  typicaly driver queue depth of 1. So despite the fact that writes are
  using more disk time it is never accounted to write queue because we don't
  wait for requests to finish after dispatching these. This patch helps
  do more accurate accounting of disk time, especially for buffered writes
  hence providing better fairness hence better isolation between two cgroups
  running read and write workloads.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/cfq-iosched.c |    1 +
 block/elevator-fq.c |   30 +++++++++++++++++++++++++-----
 block/elevator-fq.h |   10 +++++++++-
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 878cf76..37a4832 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2130,6 +2130,7 @@ static struct elv_fs_entry cfq_attrs[] = {
 	ELV_ATTR(slice_async),
 #ifdef CONFIG_GROUP_IOSCHED
 	ELV_ATTR(group_idle),
+	ELV_ATTR(fairness),
 #endif
 	__ATTR_NULL
 };
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 8ff8a19..bac45fe 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -893,6 +893,8 @@ static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 
 	allocated_slice = elv_prio_to_slice(ioq->efqd, ioq);
 
+	queue_charge = group_charge = served;
+
 	/*
 	 * We don't want to charge more than allocated slice otherwise this
 	 * queue can miss one dispatch round doubling max latencies. On the
@@ -900,16 +902,15 @@ static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 	 * we stick to CFQ theme of queue loosing its share if it does not
 	 * use the slice and moves to the back of service tree (almost).
 	 */
-	queue_charge = allocated_slice;
+	if (!ioq->efqd->fairness)
+		queue_charge = allocated_slice;
 
 	/*
 	 * Group is charged the real time consumed so that it does not loose
 	 * fair share.
 	 */
-	if (served > allocated_slice)
+	if (!ioq->efqd->fairness && group_charge > allocated_slice)
 		group_charge = allocated_slice;
-	else
-		group_charge = served;
 
 	entity_served(&ioq->entity, served, queue_charge, group_charge,
 			ioq->nr_sectors);
@@ -951,6 +952,8 @@ SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
 EXPORT_SYMBOL(elv_slice_sync_show);
 SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
 EXPORT_SYMBOL(elv_slice_async_show);
+SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
+EXPORT_SYMBOL(elv_fairness_show);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -975,6 +978,8 @@ STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_sync_store);
 STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_async_store);
+STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
+EXPORT_SYMBOL(elv_fairness_store);
 #undef STORE_FUNCTION
 
 void elv_schedule_dispatch(struct request_queue *q)
@@ -2687,6 +2692,17 @@ void *elv_select_ioq(struct request_queue *q, int force)
 	}
 
 expire:
+	if (efqd->fairness && !force && ioq && ioq->dispatched) {
+		/*
+		 * If there are request dispatched from this queue, don't
+		 * dispatch requests from new queue till all the requests from
+		 * this queue have completed.
+		 */
+		elv_log_ioq(efqd, ioq, "select: wait for requests to finish"
+				" disp=%lu", ioq->dispatched);
+		ioq = NULL;
+		goto keep_queue;
+	}
 	elv_slice_expired(q);
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
@@ -2839,6 +2855,10 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 				goto done;
 			}
 
+			/* Wait for requests to finish from this queue */
+			if (efqd->fairness && elv_ioq_nr_dispatched(ioq))
+				goto done;
+
 			/* Expire the queue */
 			elv_slice_expired(q);
 			goto done;
@@ -2849,7 +2869,7 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		 * If this is the last queue in the group and we did not
 		 * decide to idle on queue, idle on group.
 		 */
-		if (elv_iog_should_idle(ioq) && !ioq->dispatched
+		if (elv_iog_should_idle(ioq) && !elv_ioq_nr_dispatched(ioq)
 		    && !ioq_is_idling(ioq)) {
 			/*
 			 * If queue has used up its slice, wait for the
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 27ff5c4..68c6d16 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -192,6 +192,12 @@ struct elv_fq_data {
 
 	/* Fallback dummy ioq for extreme OOM conditions */
 	struct io_queue oom_ioq;
+
+	/*
+	 * If set to 1, waits for all request completions from current
+	 * queue before new queue is scheduled in
+	 */
+	unsigned int fairness;
 };
 
 /* Logging facilities. */
@@ -451,7 +457,9 @@ extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
 extern ssize_t elv_slice_async_show(struct elevator_queue *q, char *name);
 extern ssize_t elv_slice_async_store(struct elevator_queue *q, const char *name,
 						size_t count);
-
+extern ssize_t elv_fairness_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_fairness_store(struct elevator_queue *q, const char *name,
+					size_t count);
 /* Functions used by elevator.c */
 extern struct elv_fq_data *elv_alloc_fq_data(struct request_queue *q,
 					struct elevator_queue *e);
-- 
1.6.0.6
