From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/18] io-controller: idle for sometime on sync queue before
	expiring it
Date: Tue,  5 May 2009 15:58:35 -0400
Message-ID: <1241553525-28095-9-git-send-email-vgoyal__48462.3447563083$1241555869$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, fer
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

o When a sync queue expires, in many cases it might be empty and then
  it will be deleted from the active tree. This will lead to a scenario
  where out of two competing queues, only one is on the tree and when a
  new queue is selected, vtime jump takes place and we don't see services
  provided in proportion to weight.

o In general this is a fundamental problem with fairness of sync queues
  where queues are not continuously backlogged. Looks like idling is
  only solution to make sure such kind of queues can get some decent amount
  of disk bandwidth in the face of competion from continusouly backlogged
  queues. But excessive idling has potential to reduce performance on SSD
  and disks with commnad queuing.

o This patch experiments with waiting for next request to come before a
  queue is expired after it has consumed its time slice. This can ensure
  more accurate fairness numbers in some cases.

o Introduced a tunable "fairness". If set, io-controller will put more
  focus on getting fairness right than getting throughput right.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-sysfs.c   |    7 +++
 block/elevator-fq.c |  117 +++++++++++++++++++++++++++++++++++++++++++++-----
 block/elevator-fq.h |   12 +++++
 3 files changed, 124 insertions(+), 12 deletions(-)

diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index 082a273..c942ddc 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -294,6 +294,12 @@ static struct queue_sysfs_entry queue_slice_async_entry = {
 	.show = elv_slice_async_show,
 	.store = elv_slice_async_store,
 };
+
+static struct queue_sysfs_entry queue_fairness_entry = {
+	.attr = {.name = "fairness", .mode = S_IRUGO | S_IWUSR },
+	.show = elv_fairness_show,
+	.store = elv_fairness_store,
+};
 #endif
 
 static struct attribute *default_attrs[] = {
@@ -311,6 +317,7 @@ static struct attribute *default_attrs[] = {
 	&queue_slice_idle_entry.attr,
 	&queue_slice_sync_entry.attr,
 	&queue_slice_async_entry.attr,
+	&queue_fairness_entry.attr,
 #endif
 	NULL,
 };
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index b8dbc8b..ec01273 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1821,6 +1821,44 @@ static inline int is_root_group_ioq(struct request_queue *q,
 	return (ioq->entity.sched_data == &efqd->root_group->sched_data);
 }
 
+/* Functions to show and store fairness value through sysfs */
+ssize_t elv_fairness_show(struct request_queue *q, char *name)
+{
+	struct elv_fq_data *efqd;
+	unsigned int data;
+	unsigned long flags;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	efqd = &q->elevator->efqd;
+	data = efqd->fairness;
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return sprintf(name, "%d\n", data);
+}
+
+ssize_t elv_fairness_store(struct request_queue *q, const char *name,
+			  size_t count)
+{
+	struct elv_fq_data *efqd;
+	unsigned int data;
+	unsigned long flags;
+
+	char *p = (char *)name;
+
+	data = simple_strtoul(p, &p, 10);
+
+	if (data < 0)
+		data = 0;
+	else if (data > INT_MAX)
+		data = INT_MAX;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	efqd = &q->elevator->efqd;
+	efqd->fairness = data;
+	spin_unlock_irqrestore(q->queue_lock, flags);
+
+	return count;
+}
+
 /* Functions to show and store elv_idle_slice value through sysfs */
 ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
 {
@@ -2061,7 +2099,7 @@ static void elv_ioq_update_idle_window(struct elevator_queue *eq,
 	 * io scheduler if it wants to disable idling based on additional
 	 * considrations like seek pattern.
 	 */
-	if (enable_idle) {
+	if (enable_idle && !efqd->fairness) {
 		if (eq->ops->elevator_update_idle_window_fn)
 			enable_idle = eq->ops->elevator_update_idle_window_fn(
 						eq, ioq->sched_queue, rq);
@@ -2395,10 +2433,11 @@ void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
 	assert_spin_locked(q->queue_lock);
 	elv_log_ioq(efqd, ioq, "slice expired");
 
-	if (elv_ioq_wait_request(ioq))
+	if (elv_ioq_wait_request(ioq) || elv_ioq_wait_busy(ioq))
 		del_timer(&efqd->idle_slice_timer);
 
 	elv_clear_ioq_wait_request(ioq);
+	elv_clear_ioq_wait_busy(ioq);
 
 	/*
 	 * if ioq->slice_end = 0, that means a queue was expired before first
@@ -2563,7 +2602,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 		 * has other work pending, don't risk delaying until the
 		 * idle timer unplug to continue working.
 		 */
-		if (elv_ioq_wait_request(ioq)) {
+		if (elv_ioq_wait_request(ioq) && !elv_ioq_wait_busy(ioq)) {
 			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
 			    efqd->busy_queues > 1) {
 				del_timer(&efqd->idle_slice_timer);
@@ -2571,6 +2610,17 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 			}
 			elv_mark_ioq_must_dispatch(ioq);
 		}
+
+		/*
+		 * If we were waiting for a request on this queue, wait is
+		 * done. Schedule the next dispatch
+		 */
+		if (elv_ioq_wait_busy(ioq)) {
+			del_timer(&efqd->idle_slice_timer);
+			elv_clear_ioq_wait_busy(ioq);
+			elv_clear_ioq_must_dispatch(ioq);
+			elv_schedule_dispatch(q);
+		}
 	} else if (elv_should_preempt(q, ioq, rq)) {
 		/*
 		 * not the active queue - expire current slice if it is
@@ -2598,6 +2648,9 @@ void elv_idle_slice_timer(unsigned long data)
 
 	if (ioq) {
 
+		if (elv_ioq_wait_busy(ioq))
+			goto expire;
+
 		/*
 		 * We saw a request before the queue expired, let it through
 		 */
@@ -2631,7 +2684,7 @@ out_cont:
 	spin_unlock_irqrestore(q->queue_lock, flags);
 }
 
-void elv_ioq_arm_slice_timer(struct request_queue *q)
+void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 {
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 	struct io_queue *ioq = elv_active_ioq(q->elevator);
@@ -2644,26 +2697,38 @@ void elv_ioq_arm_slice_timer(struct request_queue *q)
 	 * for devices that support queuing, otherwise we still have a problem
 	 * with sync vs async workloads.
 	 */
-	if (blk_queue_nonrot(q) && efqd->hw_tag)
+	if (blk_queue_nonrot(q) && efqd->hw_tag && !efqd->fairness)
 		return;
 
 	/*
-	 * still requests with the driver, don't idle
+	 * idle is disabled, either manually or by past process history
 	 */
-	if (efqd->rq_in_driver)
+	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
 		return;
 
 	/*
-	 * idle is disabled, either manually or by past process history
+	 * This queue has consumed its time slice. We are waiting only for
+	 * it to become busy before we select next queue for dispatch.
 	 */
-	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
+	if (efqd->fairness && wait_for_busy && !ioq->dispatched) {
+		elv_mark_ioq_wait_busy(ioq);
+		sl = efqd->elv_slice_idle;
+		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+		elv_log(efqd, "arm idle: %lu wait busy=1", sl);
+		return;
+	}
+
+	/*
+	 * still requests with the driver, don't idle
+	 */
+	if (efqd->rq_in_driver && !efqd->fairness)
 		return;
 
 	/*
 	 * may be iosched got its own idling logic. In that case io
 	 * schduler will take care of arming the timer, if need be.
 	 */
-	if (q->elevator->ops->elevator_arm_slice_timer_fn) {
+	if (q->elevator->ops->elevator_arm_slice_timer_fn && !efqd->fairness) {
 		q->elevator->ops->elevator_arm_slice_timer_fn(q,
 						ioq->sched_queue);
 	} else {
@@ -2706,6 +2771,12 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 			goto expire;
 	}
 
+	/* We are waiting for this queue to become busy before it expires.*/
+	if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
 	/*
 	 * The active queue has run out of time, expire it and select new.
 	 */
@@ -2915,6 +2986,25 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			elv_ioq_set_prio_slice(q, ioq);
 			elv_clear_ioq_slice_new(ioq);
 		}
+
+		if (elv_ioq_class_idle(ioq)) {
+			elv_ioq_slice_expired(q);
+			goto done;
+		}
+
+		if (efqd->fairness && sync && !ioq->nr_queued) {
+			/*
+			 * If fairness is enabled, wait for one extra idle
+			 * period in the hope that this queue will get
+			 * backlogged again
+			 */
+			if (elv_ioq_slice_used(ioq))
+				elv_ioq_arm_slice_timer(q, 1);
+			else
+				elv_ioq_arm_slice_timer(q, 0);
+			goto done;
+		}
+
 		/*
 		 * If there are no requests waiting in this queue, and
 		 * there are other queues ready to issue requests, AND
@@ -2922,13 +3012,14 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		 * mean seek distance, give them a chance to run instead
 		 * of idling.
 		 */
-		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+		if (elv_ioq_slice_used(ioq))
 			elv_ioq_slice_expired(q);
 		else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq, 1)
 			 && sync && !rq_noidle(rq))
-			elv_ioq_arm_slice_timer(q);
+			elv_ioq_arm_slice_timer(q, 0);
 	}
 
+done:
 	if (!efqd->rq_in_driver)
 		elv_schedule_dispatch(q);
 }
@@ -3035,6 +3126,8 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->elv_slice_idle = elv_slice_idle;
 	efqd->hw_tag = 1;
 
+	/* For the time being keep fairness enabled by default */
+	efqd->fairness = 1;
 	return 0;
 }
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index f4c6361..7d3434b 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -316,6 +316,13 @@ struct elv_fq_data {
 	unsigned long long rate_sampling_start; /*sampling window start jifies*/
 	/* number of sectors finished io during current sampling window */
 	unsigned long rate_sectors_current;
+
+	/*
+	 * If set to 1, will disable many optimizations done for boost
+	 * throughput and focus more on providing fairness for sync
+	 * queues.
+	 */
+	int fairness;
 };
 
 extern int elv_slice_idle;
@@ -340,6 +347,7 @@ enum elv_queue_state_flags {
 	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
 	ELV_QUEUE_FLAG_must_dispatch,	  /* must be allowed a dispatch */
 	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
+	ELV_QUEUE_FLAG_wait_busy,	  /* wait for this queue to get busy */
 	ELV_QUEUE_FLAG_NR,
 };
 
@@ -363,6 +371,7 @@ ELV_IO_QUEUE_FLAG_FNS(wait_request)
 ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
 ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
+ELV_IO_QUEUE_FLAG_FNS(wait_busy)
 
 static inline struct io_service_tree *
 io_entity_service_tree(struct io_entity *entity)
@@ -541,6 +550,9 @@ extern ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
 extern ssize_t elv_slice_async_show(struct request_queue *q, char *name);
 extern ssize_t elv_slice_async_store(struct request_queue *q, const char *name,
 						size_t count);
+extern ssize_t elv_fairness_show(struct request_queue *q, char *name);
+extern ssize_t elv_fairness_store(struct request_queue *q, const char *name,
+						size_t count);
 
 /* Functions used by elevator.c */
 extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
-- 
1.6.0.1
