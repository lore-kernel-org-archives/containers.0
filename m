From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/20] io-controller: idle for sometime on sync queue before
	expiring it
Date: Tue, 26 May 2009 18:41:57 -0400
Message-ID: <1243377729-2176-9-git-send-email-vgoyal__10439.9340496913$1243381099$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243377729-2176-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
 block/blk-sysfs.c   |    7 ++
 block/elevator-fq.c |  165 ++++++++++++++++++++++++++++++++++++++++++++++-----
 block/elevator-fq.h |   15 +++++
 3 files changed, 171 insertions(+), 16 deletions(-)

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
index 0a99047..201785e 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -359,6 +359,7 @@ static void bfq_active_insert(struct io_service_tree *st,
 	struct rb_node *node = &entity->rb_node;
 
 	bfq_insert(&st->active, entity);
+	entity->sched_data->nr_active++;
 	if (node->rb_left != NULL)
 		node = node->rb_left;
 	else if (node->rb_right != NULL)
@@ -417,6 +418,7 @@ static void bfq_active_extract(struct io_service_tree *st,
 
 	node = bfq_find_deepest(&entity->rb_node);
 	bfq_extract(&st->active, entity);
+	entity->sched_data->nr_active--;
 	if (node != NULL)
 		bfq_update_active_tree(node);
 }
@@ -916,6 +918,21 @@ void io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
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
@@ -1759,6 +1776,44 @@ static inline int is_root_group_ioq(struct request_queue *q,
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
@@ -1999,7 +2054,7 @@ static void elv_ioq_update_idle_window(struct elevator_queue *eq,
 	 * io scheduler if it wants to disable idling based on additional
 	 * considrations like seek pattern.
 	 */
-	if (enable_idle) {
+	if (enable_idle && !efqd->fairness) {
 		if (eq->ops->elevator_update_idle_window_fn)
 			enable_idle = eq->ops->elevator_update_idle_window_fn(
 						eq, ioq->sched_queue, rq);
@@ -2181,6 +2236,7 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 
 		elv_clear_ioq_wait_request(ioq);
 		elv_clear_ioq_must_dispatch(ioq);
+		elv_clear_ioq_wait_busy_done(ioq);
 		elv_mark_ioq_slice_new(ioq);
 
 		del_timer(&efqd->idle_slice_timer);
@@ -2332,10 +2388,12 @@ void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
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
@@ -2500,7 +2558,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 		 * has other work pending, don't risk delaying until the
 		 * idle timer unplug to continue working.
 		 */
-		if (elv_ioq_wait_request(ioq)) {
+		if (elv_ioq_wait_request(ioq) && !elv_ioq_wait_busy(ioq)) {
 			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
 			    efqd->busy_queues > 1) {
 				del_timer(&efqd->idle_slice_timer);
@@ -2508,6 +2566,18 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
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
@@ -2535,6 +2605,9 @@ void elv_idle_slice_timer(unsigned long data)
 
 	if (ioq) {
 
+		if (elv_ioq_wait_busy(ioq))
+			goto expire;
+
 		/*
 		 * We saw a request before the queue expired, let it through
 		 */
@@ -2568,7 +2641,7 @@ out_cont:
 	spin_unlock_irqrestore(q->queue_lock, flags);
 }
 
-void elv_ioq_arm_slice_timer(struct request_queue *q)
+void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 {
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 	struct io_queue *ioq = elv_active_ioq(q->elevator);
@@ -2581,26 +2654,38 @@ void elv_ioq_arm_slice_timer(struct request_queue *q)
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
@@ -2643,11 +2728,38 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
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
@@ -2824,11 +2936,13 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 	const int sync = rq_is_sync(rq);
 	struct io_queue *ioq;
 	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_group *iog;
 
 	if (!elv_iosched_fair_queuing_enabled(q->elevator))
 		return;
 
 	ioq = rq->ioq;
+	iog = ioq_to_io_group(ioq);
 
 	elv_log_ioq(efqd, ioq, "complete");
 
@@ -2854,6 +2968,12 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
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
@@ -2861,13 +2981,24 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
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
@@ -2974,6 +3105,8 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->elv_slice_idle = elv_slice_idle;
 	efqd->hw_tag = 1;
 
+	/* For the time being keep fairness enabled by default */
+	efqd->fairness = 1;
 	return 0;
 }
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 3dbcf73..4f11be3 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -72,6 +72,7 @@ struct io_service_tree {
 struct io_sched_data {
 	struct io_entity *active_entity;
 	struct io_entity *next_active;
+	int nr_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
 };
 
@@ -320,6 +321,13 @@ struct elv_fq_data {
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
@@ -344,6 +352,8 @@ enum elv_queue_state_flags {
 	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
 	ELV_QUEUE_FLAG_must_dispatch,	  /* must be allowed a dispatch */
 	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
+	ELV_QUEUE_FLAG_wait_busy,	  /* wait for this queue to get busy */
+	ELV_QUEUE_FLAG_wait_busy_done,	  /* Have already waited on this queue*/
 	ELV_QUEUE_FLAG_NR,
 };
 
@@ -367,6 +377,8 @@ ELV_IO_QUEUE_FLAG_FNS(wait_request)
 ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
 ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
+ELV_IO_QUEUE_FLAG_FNS(wait_busy)
+ELV_IO_QUEUE_FLAG_FNS(wait_busy_done)
 
 static inline struct io_service_tree *
 io_entity_service_tree(struct io_entity *entity)
@@ -538,6 +550,9 @@ extern ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
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
