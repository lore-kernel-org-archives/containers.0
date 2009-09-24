From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 13/28] io-controller: Implement wait busy for io queues
Date: Thu, 24 Sep 2009 15:25:17 -0400
Message-ID: <1253820332-10246-14-git-send-email-vgoyal__49193.5139558793$1253823866$gmane$org@redhat.com>
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

o CFQ enables idling on very selective queues (sequential readers). That's why
  we implemented the concept of group idling where irrespective of workload
  in the group, one can idle on the group and provide fair share before moving
  on to next queue or group. This provides stronger isolation but also slows
  does the switching between groups.

  One can disable "group_idle" to make group switching faster but then we
  loose fairness for sequenatial readers also as once queue has consumed its
  slice we delete it and move onto next queue.

o This patch implments the concept of wait busy (simliar to groups) on queues.
  So once a CFQ queue has consumed its slice, we idle for one extra period
  for it to get busy again and then expire it and move on to next queue. This
  makes sure that sequential readers don't loose fairness (no vtime jump), even
  if group idling is disabled.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 55 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 5511256..b8862d3 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -21,6 +21,7 @@ int elv_slice_async = HZ / 25;
 const int elv_slice_async_rq = 2;
 int elv_group_idle = HZ / 125;
 static struct kmem_cache *elv_ioq_pool;
+static int elv_ioq_wait_busy = HZ / 125;
 
 /*
  * offset from end of service tree
@@ -1043,6 +1044,36 @@ static void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
 	entity->my_sd = &iog->sched_data;
 }
 
+/* If group_idling is enabled then group takes care of doing idling and wait
+ * busy on a queue. But this happens on all queues, even if we are running
+ * a random reader or random writer. This has its own advantage that group
+ * gets to run continuously for a period of time and provides strong isolation
+ * but too strong isolation can also slow down group switching.
+ *
+ * Hence provide this alternate mode where we do wait busy on the queues for
+ * which CFQ has idle_window enabled. This is useful in ensuring the fairness
+ * of sequential readers in group at the same time we don't do group idling
+ * on all the queues hence faster switching.
+ */
+int elv_ioq_should_wait_busy(struct io_queue *ioq)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+
+	/* Idle window is disabled for root group */
+	if (!elv_iog_idle_window(iog))
+		return 0;
+
+	/*
+	 * if CFQ has got idling enabled on this queue, wait for this queue
+	 * to get backlogged again.
+	 */
+	if (!ioq->nr_queued && elv_ioq_idle_window(ioq)
+	    && elv_ioq_slice_used(ioq))
+		return 1;
+
+	return 0;
+}
+
 /* Check if we plan to idle on the group associated with this queue or not */
 int elv_iog_should_idle(struct io_queue *ioq)
 {
@@ -1889,6 +1920,7 @@ static void io_free_root_group(struct elevator_queue *e)
 /* No group idling in flat mode */
 int elv_iog_should_idle(struct io_queue *ioq) { return 0; }
 EXPORT_SYMBOL(elv_iog_should_idle);
+static int elv_ioq_should_wait_busy(struct io_queue *ioq) { return 0; }
 
 #endif /* CONFIG_GROUP_IOSCHED */
 
@@ -2368,6 +2400,24 @@ static void elv_iog_arm_slice_timer(struct request_queue *q,
 	elv_log_iog(efqd, iog, "arm_idle group: %lu", sl);
 }
 
+static void
+elv_ioq_arm_wait_busy_timer(struct request_queue *q, struct io_queue *ioq)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+	struct elv_fq_data *efqd = q->elevator->efqd;
+	unsigned long sl = 8;
+
+	/*
+	 * This queue has consumed its time slice. We are waiting only for
+	 * it to become busy before we select next queue for dispatch.
+	 */
+	elv_mark_iog_wait_busy(iog);
+	sl = elv_ioq_wait_busy;
+	mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+	elv_log_ioq(efqd, ioq, "arm wait busy ioq: %lu", sl);
+	return;
+}
+
 /*
  * If io scheduler has functionality of keeping track of close cooperator, check
  * with it if it has got a closely co-operating queue.
@@ -2456,7 +2506,8 @@ void *elv_select_ioq(struct request_queue *q, int force)
 		 * from queue and is not proportional to group's weight, it
 		 * harms the fairness of the group.
 		 */
-		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog)) {
+		if ((elv_iog_should_idle(ioq) || elv_ioq_should_wait_busy(ioq))
+		     && !elv_iog_wait_busy_done(iog)) {
 			ioq = NULL;
 			goto keep_queue;
 		} else
@@ -2640,6 +2691,9 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			if (elv_iog_should_idle(ioq)) {
 				elv_iog_arm_slice_timer(q, iog, 1);
 				goto done;
+			} else if (elv_ioq_should_wait_busy(ioq)) {
+				elv_ioq_arm_wait_busy_timer(q, ioq);
+				goto done;
 			}
 
 			/* Expire the queue */
-- 
1.6.0.6
