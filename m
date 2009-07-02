From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 13/25] io-controller: Wait for requests to complete from last
	queue before new queue is scheduled
Date: Thu,  2 Jul 2009 16:01:45 -0400
Message-ID: <1246564917-19603-14-git-send-email-vgoyal__23258.9884348728$1246566904$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
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
  be enabled only if user sets "fairness" tunable to 2 or higher.

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
---
 block/elevator-fq.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 68be1dc..7609579 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -2038,7 +2038,7 @@ STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_sync_store);
 STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_async_store);
-STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
+STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 2, 0);
 EXPORT_SYMBOL(elv_fairness_store);
 #undef STORE_FUNCTION
 
@@ -2952,6 +2952,24 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 	}
 
 expire:
+	if (efqd->fairness >= 2 && !force && ioq && ioq->dispatched) {
+		/*
+		 * If there are request dispatched from this queue, don't
+		 * dispatch requests from new queue till all the requests from
+		 * this queue have completed.
+		 *
+		 * This helps in attributing right amount of disk time consumed
+		 * by a particular queue when hardware allows queuing.
+		 *
+		 * Set ioq = NULL so that no more requests are dispatched from
+		 * this queue.
+		 */
+		elv_log_ioq(efqd, ioq, "select: wait for requests to finish"
+				" disp=%lu", ioq->dispatched);
+		ioq = NULL;
+		goto keep_queue;
+	}
+
 	elv_ioq_slice_expired(q);
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
@@ -3109,6 +3127,17 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 				 */
 				elv_ioq_arm_slice_timer(q, 1);
 			} else {
+				/* If fairness >=2 and there are requests
+				 * dispatched from this queue, don't dispatch
+				 * new requests from a different queue till
+				 * all requests from this queue have finished.
+				 * This helps in attributing right disk time
+				 * to a queue when hardware supports queuing.
+				 */
+
+				if (efqd->fairness >= 2 && ioq->dispatched)
+					goto done;
+
 				/* Expire the queue */
 				elv_ioq_slice_expired(q);
 			}
-- 
1.6.0.6
