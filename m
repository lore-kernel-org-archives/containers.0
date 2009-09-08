From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 24/23] io-controller: Don't leave a queue active when a
	disk is idle
Date: Tue, 8 Sep 2009 18:28:21 -0400
Message-ID: <20090908222821.GB3558__19701.0763608434$1252448991$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1251495072-7780-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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


o It is possible that when there is only a single queue in the system, it
  remains unexpired for a long time (because there is no IO activity on the
  disk). So when next request comes in after a long time, it might make
  scheduler think that all this while queue used the disk and it will assign
  a high vdisktime to the queue. Hence make sure queue is expired once all
  the requests have completed from the queue.

o Also avoid unnecessarily expiring a queue when it has got one request
  dispatched to the queue and waiting for it to finish and it does not have
  more requests queued to dispatch.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: linux16/block/elevator-fq.c
===================================================================
--- linux16.orig/block/elevator-fq.c	2009-09-08 15:43:36.000000000 -0400
+++ linux16/block/elevator-fq.c	2009-09-08 15:44:21.000000000 -0400
@@ -2947,6 +2947,10 @@ void *elv_select_ioq(struct request_queu
 	if (ioq == NULL)
 		goto new_queue;
 
+	/* There is only one active queue which is empty. Nothing to dispatch */
+	if (elv_nr_busy_ioq(q->elevator) == 1 && !ioq->nr_queued)
+		return NULL;
+
 	iog = ioq_to_io_group(ioq);
 
 	/*
@@ -3236,6 +3240,17 @@ void elv_ioq_completed_request(struct re
 			else
 				elv_iog_arm_slice_timer(q, iog, 0);
 		}
+
+		/*
+		 * if this is only queue and it has completed all its requests
+		 * and has nothing to dispatch, expire it. We don't want to
+		 * keep it around idle otherwise later when it is expired, all
+		 * this idle time will be added to queue's disk time used.
+		 */
+		if (efqd->busy_queues == 1 && !ioq->dispatched &&
+		   !ioq->nr_queued && !timer_pending(&efqd->idle_slice_timer)) {
+			elv_slice_expired(q);
+		}
 	}
 done:
 	if (!efqd->rq_in_driver)
