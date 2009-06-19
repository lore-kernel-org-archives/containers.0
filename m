From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/20] io-controller: idle for sometime on sync queue before
	expiring it
Date: Fri, 19 Jun 2009 16:37:26 -0400
Message-ID: <1245443858-8487-9-git-send-email-vgoyal__9484.41259465671$1245445128$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245443858-8487-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
 block/cfq-iosched.c |    1 +
 block/elevator-fq.c |  131 ++++++++++++++++++++++++++++++++++++++++++++------
 block/elevator-fq.h |   15 ++++++
 3 files changed, 131 insertions(+), 16 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index b64c8fd..bba85b1 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2004,6 +2004,7 @@ static struct elv_fs_entry cfq_attrs[] = {
 	ELV_ATTR(slice_idle),
 	ELV_ATTR(slice_sync),
 	ELV_ATTR(slice_async),
+	ELV_ATTR(fairness),
 	__ATTR_NULL
 };
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 11a7fca..cde2155 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -431,6 +431,7 @@ static void bfq_active_insert(struct io_service_tree *st,
 	struct rb_node *node = &entity->rb_node;
 
 	bfq_insert(&st->active, entity);
+	entity->sched_data->nr_active++;
 	if (node->rb_left != NULL)
 		node = node->rb_left;
 	else if (node->rb_right != NULL)
@@ -489,6 +490,7 @@ static void bfq_active_extract(struct io_service_tree *st,
 
 	node = bfq_find_deepest(&entity->rb_node);
 	bfq_extract(&st->active, entity);
+	entity->sched_data->nr_active--;
 	if (node != NULL)
 		bfq_update_active_tree(node);
 }
@@ -1022,6 +1024,21 @@ void io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
 	elv_release_ioq(e, &iog->async_idle_queue);
 }
 
+/*
+ * Returns the number of active entities a particular io group has. This
+ * includes number of active entities on service tree as well as the active
+ * entity which is being served currently, if any.
+ */
+
+static inline int elv_iog_nr_active(struct io_group *iog)
+{
+	struct io_sched_data *sd = &iog->sched_data;
+
+	if (sd->active_entity)
+		return sd->nr_active + 1;
+	else
+		return sd->nr_active;
+}
 
 /* Mainly hierarchical grouping code */
 #ifdef CONFIG_GROUP_IOSCHED
@@ -1988,6 +2005,8 @@ SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
 EXPORT_SYMBOL(elv_slice_sync_show);
 SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
 EXPORT_SYMBOL(elv_slice_async_show);
+SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
+EXPORT_SYMBOL(elv_fairness_show);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -2012,6 +2031,8 @@ STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_sync_store);
 STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_async_store);
+STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
+EXPORT_SYMBOL(elv_fairness_store);
 #undef STORE_FUNCTION
 
 void elv_schedule_dispatch(struct request_queue *q)
@@ -2136,7 +2157,7 @@ static void elv_ioq_update_idle_window(struct elevator_queue *eq,
 	 * io scheduler if it wants to disable idling based on additional
 	 * considrations like seek pattern.
 	 */
-	if (enable_idle) {
+	if (enable_idle && !efqd->fairness) {
 		if (eq->ops->elevator_update_idle_window_fn)
 			enable_idle = eq->ops->elevator_update_idle_window_fn(
 						eq, ioq->sched_queue, rq);
@@ -2320,6 +2341,7 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 
 		elv_clear_ioq_wait_request(ioq);
 		elv_clear_ioq_must_dispatch(ioq);
+		elv_clear_ioq_wait_busy_done(ioq);
 		elv_mark_ioq_slice_new(ioq);
 
 		del_timer(&efqd->idle_slice_timer);
@@ -2473,10 +2495,12 @@ void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
 	assert_spin_locked(q->queue_lock);
 	elv_log_ioq(efqd, ioq, "slice expired");
 
-	if (elv_ioq_wait_request(ioq))
+	if (elv_ioq_wait_request(ioq) || elv_ioq_wait_busy(ioq))
 		del_timer(&efqd->idle_slice_timer);
 
 	elv_clear_ioq_wait_request(ioq);
+	elv_clear_ioq_wait_busy(ioq);
+	elv_clear_ioq_wait_busy_done(ioq);
 
 	/*
 	 * if ioq->slice_end = 0, that means a queue was expired before first
@@ -2649,7 +2673,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 		 * has other work pending, don't risk delaying until the
 		 * idle timer unplug to continue working.
 		 */
-		if (elv_ioq_wait_request(ioq)) {
+		if (elv_ioq_wait_request(ioq) && !elv_ioq_wait_busy(ioq)) {
 			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
 			    efqd->busy_queues > 1) {
 				del_timer(&efqd->idle_slice_timer);
@@ -2657,6 +2681,18 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
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
+			elv_mark_ioq_wait_busy_done(ioq);
+			elv_clear_ioq_must_dispatch(ioq);
+			elv_schedule_dispatch(q);
+		}
 	} else if (elv_should_preempt(q, ioq, rq)) {
 		/*
 		 * not the active queue - expire current slice if it is
@@ -2684,6 +2720,9 @@ void elv_idle_slice_timer(unsigned long data)
 
 	if (ioq) {
 
+		if (elv_ioq_wait_busy(ioq))
+			goto expire;
+
 		/*
 		 * We saw a request before the queue expired, let it through
 		 */
@@ -2717,7 +2756,7 @@ out_cont:
 	spin_unlock_irqrestore(q->queue_lock, flags);
 }
 
-void elv_ioq_arm_slice_timer(struct request_queue *q)
+void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 {
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 	struct io_queue *ioq = elv_active_ioq(q->elevator);
@@ -2730,26 +2769,38 @@ void elv_ioq_arm_slice_timer(struct request_queue *q)
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
+	if (wait_for_busy) {
+		elv_mark_ioq_wait_busy(ioq);
+		sl = efqd->elv_slice_idle;
+		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+		elv_log_ioq(efqd, ioq, "arm idle: %lu wait busy=1", sl);
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
@@ -2784,11 +2835,38 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
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
-	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq))
-		goto expire;
+	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq)) {
+		/*
+		 * Queue has used up its slice. Wait busy is not on otherwise
+		 * we wouldn't have been here. There is a chance that after
+		 * slice expiry no request from the queue completed hence
+		 * wait busy timer could not be turned on. If that's the case
+		 * don't expire the queue yet. Next request completion from
+		 * the queue will arm the wait busy timer.
+		 *
+		 * Don't wait if this group has other active queues. This
+		 * will make sure that we don't loose fairness at group level
+		 * at the same time in root group we will not see cfq
+		 * regressions.
+		 */
+		if (elv_ioq_sync(ioq) && !ioq->nr_queued
+		    && elv_ioq_nr_dispatched(ioq)
+		    && (elv_iog_nr_active(ioq_to_io_group(ioq)) <= 1)
+		    && !elv_ioq_wait_busy_done(ioq)) {
+			ioq = NULL;
+			goto keep_queue;
+		} else
+			goto expire;
+	}
 
 	/*
 	 * If we have a RT cfqq waiting, then we pre-empt the current non-rt
@@ -2967,11 +3045,13 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 	const int sync = rq_is_sync(rq);
 	struct io_queue *ioq;
 	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_group *iog;
 
 	if (!elv_iosched_fair_queuing_enabled(q->elevator))
 		return;
 
 	ioq = rq->ioq;
+	iog = ioq_to_io_group(ioq);
 
 	elv_log_ioq(efqd, ioq, "complete");
 
@@ -2997,6 +3077,12 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			elv_ioq_set_prio_slice(q, ioq);
 			elv_clear_ioq_slice_new(ioq);
 		}
+
+		if (elv_ioq_class_idle(ioq)) {
+			elv_ioq_slice_expired(q);
+			goto done;
+		}
+
 		/*
 		 * If there are no requests waiting in this queue, and
 		 * there are other queues ready to issue requests, AND
@@ -3004,13 +3090,24 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		 * mean seek distance, give them a chance to run instead
 		 * of idling.
 		 */
-		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
-			elv_ioq_slice_expired(q);
-		else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq, 1)
+		if (elv_ioq_slice_used(ioq)) {
+			if (sync && !ioq->nr_queued
+			    && (elv_iog_nr_active(iog) <= 1)) {
+				/*
+				 * Idle for one extra period in hierarchical
+				 * setup
+				 */
+				elv_ioq_arm_slice_timer(q, 1);
+			} else {
+				/* Expire the queue */
+				elv_ioq_slice_expired(q);
+			}
+		} else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq, 1)
 			 && sync && !rq_noidle(rq))
-			elv_ioq_arm_slice_timer(q);
+			elv_ioq_arm_slice_timer(q, 0);
 	}
 
+done:
 	if (!efqd->rq_in_driver)
 		elv_schedule_dispatch(q);
 }
@@ -3115,6 +3212,8 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->elv_slice_idle = elv_slice_idle;
 	efqd->hw_tag = 1;
 
+	/* For the time being keep fairness enabled by default */
+	efqd->fairness = 1;
 	return 0;
 }
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 9f0c9a0..e13999e 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -77,6 +77,7 @@ struct io_service_tree {
 struct io_sched_data {
 	struct io_entity *active_entity;
 	struct io_entity *next_active;
+	int nr_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
 };
 
@@ -331,6 +332,13 @@ struct elv_fq_data {
 	unsigned long long rate_sampling_start; /*sampling window start jifies*/
 	/* number of sectors finished io during current sampling window */
 	unsigned long rate_sectors_current;
+
+	/*
+	 * If set to 1, will disable many optimizations done for boost
+	 * throughput and focus more on providing fairness for sync
+	 * queues.
+	 */
+	unsigned int fairness;
 };
 
 extern int elv_slice_idle;
@@ -355,6 +363,8 @@ enum elv_queue_state_flags {
 	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
 	ELV_QUEUE_FLAG_must_dispatch,	  /* must be allowed a dispatch */
 	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
+	ELV_QUEUE_FLAG_wait_busy,	  /* wait for this queue to get busy */
+	ELV_QUEUE_FLAG_wait_busy_done,	  /* Have already waited on this queue*/
 	ELV_QUEUE_FLAG_NR,
 };
 
@@ -378,6 +388,8 @@ ELV_IO_QUEUE_FLAG_FNS(wait_request)
 ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
 ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
+ELV_IO_QUEUE_FLAG_FNS(wait_busy)
+ELV_IO_QUEUE_FLAG_FNS(wait_busy_done)
 
 static inline struct io_service_tree *
 io_entity_service_tree(struct io_entity *entity)
@@ -550,6 +562,9 @@ extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
 extern ssize_t elv_slice_async_show(struct elevator_queue *q, char *name);
 extern ssize_t elv_slice_async_store(struct elevator_queue *q, const char *name,
 						size_t count);
+extern ssize_t elv_fairness_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_fairness_store(struct elevator_queue *q, const char *name,
+						size_t count);
 
 /* Functions used by elevator.c */
 extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
-- 
1.6.0.6
