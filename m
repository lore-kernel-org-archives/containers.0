From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/10] anticipatory changes for hierarchical fair queuing
Date: Wed, 11 Mar 2009 21:56:55 -0400
Message-ID: <1236823015-4183-11-git-send-email-vgoyal@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236823015-4183-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch changes anticipatory scheduler to use queue scheduling code from
elevator layer.  One can go back to old as by deselecting
CONFIG_IOSCHED_AS_HIER.

TODO/Issues
===========
- AS anticipation logic does not seem to be sufficient to provide BW difference
  if two "dd" are going in two different cgroups. Needs to be looked into.

- AS write batch number of request adjustment happens upon every W->R batch
  direction switch. This automatic adjustment depends on how much time a
  read is taking after a W->R switch.

  This does not gel very well when hierarhical scheduling is enabled and
  every io group can have its separate read/write batch. Now if io group
  switching takes place it creates issues.

  Currently I have disabled write batch length adjustment in hierarchical
  mode.

- Currently performance seems to be very bad in hierarhical mode. Needs
  to be looked into.

- I think the whole idea of common layer doing time slice switching between
  queues and then queue in turn running timed batches is not very good. May
  be AS can maintain two queues (one for READS and other for WRITES) and let
  common layer do the time slice switching between these two queues.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   12 +++
 block/as-iosched.c       |  176 +++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.c      |   77 ++++++++++++++++----
 include/linux/elevator.h |   16 ++++
 4 files changed, 265 insertions(+), 16 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 3a9e7d7..77fc786 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -45,6 +45,18 @@ config IOSCHED_AS
 	  deadline I/O scheduler, it can also be slower in some cases
 	  especially some database loads.
 
+config IOSCHED_AS_HIER
+	bool "Anticipatory Hierarchical Scheduling support"
+	depends on IOSCHED_AS && CGROUPS
+	select ELV_FAIR_QUEUING
+	select GROUP_IOSCHED
+	default n
+	---help---
+	  Enable hierarhical scheduling in anticipatory. In this mode
+	  anticipatory keeps one IO queue per cgroup instead of a global
+	  queue. Elevator fair queuing logic ensures fairness among various
+	  queues.
+
 config IOSCHED_DEADLINE
 	tristate "Deadline I/O scheduler"
 	default y
diff --git a/block/as-iosched.c b/block/as-iosched.c
index 6d2890c..27c14a7 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -87,6 +87,19 @@ struct as_queue {
 	struct list_head fifo_list[2];
 
 	struct request *next_rq[2];	/* next in sort order */
+
+	/*
+	 * If an as_queue is switched while a batch is running, then we
+	 * store the time left before current batch will expire
+	 */
+	long current_batch_time_left;
+
+	/*
+	 * batch data dir when queue was scheduled out. This will be used
+	 * to setup ad->batch_data_dir when queue is scheduled in.
+	 */
+	int saved_batch_data_dir;
+
 	unsigned long last_check_fifo[2];
 	int write_batch_count;		/* max # of reqs in a write batch */
 	int current_write_count;	/* how many requests left this batch */
@@ -153,6 +166,140 @@ static DEFINE_SPINLOCK(ioc_gone_lock);
 
 static void as_move_to_dispatch(struct as_data *ad, struct request *rq);
 static void as_antic_stop(struct as_data *ad);
+static inline int as_batch_expired(struct as_data *ad, struct as_queue *asq);
+
+#ifdef CONFIG_IOSCHED_AS_HIER
+static void as_save_batch_context(struct as_data *ad, struct as_queue *asq)
+{
+	/* Save batch data dir */
+	asq->saved_batch_data_dir = ad->batch_data_dir;
+
+	if (ad->changed_batch) {
+		/*
+		 * In case of force expire, we come here. Batch changeover
+		 * has been signalled but we are waiting for all the
+		 * request to finish from previous batch and then start
+		 * the new batch. Can't wait now. Mark that full batch time
+		 * needs to be allocated when this queue is scheduled again.
+		 */
+		asq->current_batch_time_left =
+				ad->batch_expire[ad->batch_data_dir];
+		ad->changed_batch = 0;
+		return;
+	}
+
+	if (ad->new_batch) {
+		/*
+		 * We should come here only when new_batch has been set
+		 * but no read request has been issued or if it is a forced
+		 * expiry.
+		 *
+		 * In both the cases, new batch has not started yet so
+		 * allocate full batch length for next scheduling opportunity.
+		 * We don't do write batch size adjustment in hierarchical
+		 * AS so that should not be an issue.
+		 */
+		asq->current_batch_time_left =
+				ad->batch_expire[ad->batch_data_dir];
+		ad->new_batch = 0;
+		return;
+	}
+
+	/* Save how much time is left before current batch expires */
+	if (as_batch_expired(ad, asq))
+		asq->current_batch_time_left = 0;
+	else {
+		asq->current_batch_time_left = ad->current_batch_expires
+							- jiffies;
+		BUG_ON((asq->current_batch_time_left) < 0);
+	}
+}
+
+/*
+ * FIXME: In original AS, read batch's time account started only after when
+ * first request had completed (if last batch was a write batch). But here
+ * we might be rescheduling a read batch right away irrespective of the fact
+ * of disk cache state.
+ */
+static void as_restore_batch_context(struct as_data *ad, struct as_queue *asq)
+{
+	/* Adjust the batch expire time */
+	if (asq->current_batch_time_left)
+		ad->current_batch_expires = jiffies +
+						asq->current_batch_time_left;
+	/* restore asq batch_data_dir info */
+	ad->batch_data_dir = asq->saved_batch_data_dir;
+}
+
+/* ioq has been set. */
+static void as_active_ioq_set(struct request_queue *q, void *sched_queue)
+{
+	struct as_queue *asq = sched_queue;
+	struct as_data *ad = q->elevator->elevator_data;
+
+	as_restore_batch_context(ad, asq);
+}
+
+/*
+ * This is a notification from common layer that it wishes to expire this
+ * io queue. AS decides whether queue can be expired, if yes, it also
+ * saves the batch context.
+ */
+static int as_expire_ioq(struct request_queue *q, void *sched_queue,
+				int slice_expired, int force)
+{
+	struct as_data *ad = q->elevator->elevator_data;
+	int status = ad->antic_status;
+	struct as_queue *asq = sched_queue;
+
+	/* Forced expiry. We don't have a choice */
+	if (force) {
+		as_antic_stop(ad);
+		as_save_batch_context(ad, asq);
+		return 1;
+	}
+
+	/*
+	 * We are waiting for requests to finish from last
+	 * batch. Don't expire the queue now
+	 */
+	if (ad->changed_batch)
+		goto keep_queue;
+
+	/*
+	 * Wait for all requests from existing batch to finish before we
+	 * switch the queue. New queue might change the batch direction
+	 * and this is to be consistent with AS philosophy of not dispatching
+	 * new requests to underlying drive till requests from requests
+	 * from previous batch are completed.
+	 */
+	if (ad->nr_dispatched)
+		goto keep_queue;
+
+	/*
+	 * If AS anticipation is ON, stop it if slice expired, otherwise
+	 * keep the queue.
+	 */
+	if (status == ANTIC_WAIT_REQ || status == ANTIC_WAIT_NEXT) {
+		if (slice_expired)
+			as_antic_stop(ad);
+		else
+			/*
+			 * We are anticipating and time slice has not expired
+			 * so I would rather prefer waiting than break the
+			 * anticipation and expire the queue.
+			 */
+			goto keep_queue;
+	}
+
+	/* We are good to expire the queue. Save batch context */
+	as_save_batch_context(ad, asq);
+	return 1;
+
+keep_queue:
+	return 0;
+}
+#endif
 
 /*
  * IO Context helper functions
@@ -808,6 +955,7 @@ static void as_update_rq(struct as_data *ad, struct request *rq)
 	}
 }
 
+#ifndef CONFIG_IOSCHED_AS_HIER
 /*
  * Gathers timings and resizes the write batch automatically
  */
@@ -836,6 +984,7 @@ static void update_write_batch(struct as_data *ad)
 	if (asq->write_batch_count < 1)
 		asq->write_batch_count = 1;
 }
+#endif /* !CONFIG_IOSCHED_AS_HIER */
 
 /*
  * as_completed_request is to be called when a request has completed and
@@ -870,7 +1019,26 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 	 * and writeback caches
 	 */
 	if (ad->new_batch && ad->batch_data_dir == rq_is_sync(rq)) {
+#ifndef CONFIG_IOSCHED_AS_HIER
+		/*
+		 * Dynamic updation of write batch length is disabled
+		 * for hierarchical scheduling. It is difficult to do
+		 * accurate accounting when queue switch can take place
+		 * in the middle of the batch.
+		 *
+		 * Say, A, B are two groups. Following is the sequence of
+		 * events.
+		 *
+		 * Servicing Write batch of A.
+		 * Queue switch takes place and write batch of B starts.
+		 * Batch switch takes place and read batch of B starts.
+		 *
+		 * In above scenario, writes issued in write batch of A
+		 * might impact the write batch length of B. Which is not
+		 * good.
+		 */
 		update_write_batch(ad);
+#endif
 		ad->current_batch_expires = jiffies +
 				ad->batch_expire[REQ_SYNC];
 		ad->new_batch = 0;
@@ -1517,8 +1685,14 @@ static struct elevator_type iosched_as = {
 		.trim =				as_trim,
 		.elevator_alloc_sched_queue_fn = as_alloc_as_queue,
 		.elevator_free_sched_queue_fn = as_free_as_queue,
+#ifdef CONFIG_IOSCHED_AS_HIER
+		.elevator_expire_ioq_fn =       as_expire_ioq,
+		.elevator_active_ioq_set_fn =   as_active_ioq_set,
 	},
-
+	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ | ELV_IOSCHED_DONT_IDLE,
+#else
+	},
+#endif
 	.elevator_attrs = as_attrs,
 	.elevator_name = "anticipatory",
 	.elevator_owner = THIS_MODULE,
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 172f9e3..df53418 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -28,6 +28,9 @@ static struct kmem_cache *elv_ioq_pool;
 				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
 
 void elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
+int elv_iosched_expire_ioq(struct request_queue *q, int slice_expired,
+					int force);
+
 /* Mainly the BFQ scheduling code Follows */
 #ifdef CONFIG_GROUP_IOSCHED
 #define for_each_entity(entity)	\
@@ -1915,6 +1918,9 @@ static void elv_ioq_update_idle_window(struct elevator_queue *eq,
 	int old_idle, enable_idle;
 	struct elv_fq_data *efqd = ioq->efqd;
 
+	/* If idling is disabled from ioscheduler, return */
+	if (!elv_gen_idling_enabled(eq))
+		return;
 	/*
 	 * Don't idle for async or idle io prio class
 	 */
@@ -1984,7 +1990,11 @@ int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
 	elv_ioq_set_ioprio(ioq, ioprio);
 	ioq->pid = current->pid;
 	ioq->sched_queue = sched_queue;
-	elv_mark_ioq_idle_window(ioq);
+
+	/* If generic idle logic is enabled, mark it */
+	if (elv_gen_idling_enabled(eq))
+		elv_mark_ioq_idle_window(ioq);
+
 	bfq_init_entity(&ioq->entity, iog);
 	return 0;
 }
@@ -2344,15 +2354,13 @@ int elv_preempt_queue(struct request_queue *q, struct io_queue *ioq)
 
 	new_ioq = elv_get_next_ioq(q, 0);
 	if (new_ioq == ioq) {
-		/*
-		 * We might need expire_ioq logic here to check with io
-		 * scheduler if queue can be preempted. This might not
-		 * be need for cfq but AS might need it.
-		 */
-		elv_ioq_slice_expired(q, 0);
-		elv_ioq_set_slice_end(ioq, 0);
-		elv_mark_ioq_slice_new(ioq);
-		return 1;
+		/* Is forced expire a too strong an action here? */
+		if (elv_iosched_expire_ioq(q, 0, 1)) {
+			elv_ioq_slice_expired(q, 0);
+			elv_ioq_set_slice_end(ioq, 0);
+			elv_mark_ioq_slice_new(ioq);
+			return 1;
+		}
 	}
 
 	return 0;
@@ -2499,12 +2507,44 @@ void elv_free_idle_ioq_list(struct elevator_queue *e)
 		elv_deactivate_ioq(efqd, ioq, 0);
 }
 
+/*
+ * Call iosched to let that elevator wants to expire the queue. This gives
+ * iosched like AS to say no (if it is in the middle of batch changeover or
+ * it is anticipating). it also allows iosched to do some house keeping
+ *
+ * force--> it is force dispatch and iosched must clean up its state. This
+ * 	     is useful when elevator wants to drain iosched and wants to
+ * 	     expire currnent active queue.
+ *
+ * slice_expired--> if 1, ioq slice expired hence elevator fair queuing logic
+ * 		    wants to switch the queue. iosched should allow that until
+ * 		    and unless necessary. Currently AS can deny the switch if
+ * 		    in the middle of batch switch.
+ *
+ * 		    if 0, time slice is still remaining. It is up to the iosched
+ * 		    whether it wants to wait on this queue or just want to
+ * 		    expire it and move on to next queue.
+ *
+ */
+int elv_iosched_expire_ioq(struct request_queue *q, int slice_expired,
+					int force)
+{
+	struct elevator_queue *e = q->elevator;
+	struct io_queue *ioq = elv_active_ioq(q->elevator);
+
+	if (e->ops->elevator_expire_ioq_fn)
+		return e->ops->elevator_expire_ioq_fn(q, ioq->sched_queue,
+							slice_expired, force);
+
+	return 1;
+}
+
 /* Common layer function to select the next queue to dispatch from */
 void *elv_fq_select_ioq(struct request_queue *q, int force)
 {
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 	struct io_queue *ioq = elv_active_ioq(q->elevator);
-	int budget_update = 1;
+	int slice_expired = 1, budget_update = 1;
 
 	if (!elv_nr_busy_ioq(q->elevator))
 		return NULL;
@@ -2571,8 +2611,14 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 		goto keep_queue;
 	}
 
+	slice_expired = 0;
 expire:
-	elv_ioq_slice_expired(q, budget_update);
+	if (elv_iosched_expire_ioq(q, slice_expired, force))
+		elv_ioq_slice_expired(q, budget_update);
+	else {
+		ioq = NULL;
+		goto keep_queue;
+	}
 new_queue:
 	ioq = elv_set_active_ioq(q);
 keep_queue:
@@ -2696,9 +2742,10 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 			elv_ioq_set_prio_slice(q, ioq);
 			elv_clear_ioq_slice_new(ioq);
 		}
-		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
-			elv_ioq_slice_expired(q, 1);
-		else if (sync && !ioq->nr_queued)
+		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq)) {
+			if (elv_iosched_expire_ioq(q, 1, 0))
+				elv_ioq_slice_expired(q, 1);
+		} else if (sync && !ioq->nr_queued)
 			elv_ioq_arm_slice_timer(q);
 	}
 
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 8cee877..9b5c9b9 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -40,6 +40,7 @@ typedef int (elevator_should_preempt_fn) (struct request_queue*, void*,
 						struct request*);
 typedef int (elevator_update_idle_window_fn) (struct elevator_queue*, void*,
 						struct request*);
+typedef int (elevator_expire_ioq_fn) (struct request_queue*, void *, int, int);
 #endif
 
 struct elevator_ops
@@ -78,6 +79,7 @@ struct elevator_ops
 	elevator_arm_slice_timer_fn *elevator_arm_slice_timer_fn;
 	elevator_should_preempt_fn *elevator_should_preempt_fn;
 	elevator_update_idle_window_fn *elevator_update_idle_window_fn;
+	elevator_expire_ioq_fn  *elevator_expire_ioq_fn;
 #endif
 };
 
@@ -248,6 +250,9 @@ enum {
 /* iosched maintains only single ioq per group.*/
 #define ELV_IOSCHED_SINGLE_IOQ        2
 
+/* iosched does not need anticipation/idling logic support from common layer */
+#define ELV_IOSCHED_DONT_IDLE	4
+
 static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
 {
 	return (e->elevator_type->elevator_features) & ELV_IOSCHED_NEED_FQ;
@@ -258,6 +263,12 @@ static inline int elv_iosched_single_ioq(struct elevator_queue *e)
 	return (e->elevator_type->elevator_features) & ELV_IOSCHED_SINGLE_IOQ;
 }
 
+/* returns 1 if elevator layer should enable its idling logic, 0 otherwise */
+static inline int elv_gen_idling_enabled(struct elevator_queue *e)
+{
+	return !((e->elevator_type->elevator_features) & ELV_IOSCHED_DONT_IDLE);
+}
+
 #else /* ELV_IOSCHED_FAIR_QUEUING */
 
 static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
@@ -270,6 +281,11 @@ static inline int elv_iosched_single_ioq(struct elevator_queue *e)
 	return 0;
 }
 
+static inline int elv_gen_idling_enabled(struct elevator_queue *e)
+{
+	return 0;
+}
+
 #endif /* ELV_IOSCHED_FAIR_QUEUING */
 extern void *elv_get_sched_queue(struct request_queue *q, struct request *rq);
 extern void *elv_select_sched_queue(struct request_queue *q, int force);
-- 
1.6.0.1
