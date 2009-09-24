From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 22/28] io-controller: anticipatory changes for hierarchical
	fair queuing
Date: Thu, 24 Sep 2009 15:25:26 -0400
Message-ID: <1253820332-10246-23-git-send-email-vgoyal__26283.812945667$1253823484$gmane$org@redhat.com>
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

This patch changes anticipatory scheduler to use queue scheduling code from
elevator layer.  One can go back to old as by deselecting
CONFIG_IOSCHED_AS_HIER. Even with CONFIG_IOSCHED_AS_HIER=y, with-out any
other cgroup created, AS behavior should remain the same as old.

o AS is a single queue ioschduler, that means there is one AS queue per group.

o common layer code select the queue to dispatch from based on fairness, and
  then AS code selects the request with-in group.

o AS runs reads and writes batches with-in group. So common layer runs timed
  group queues and with-in group time, AS runs timed batches of reads and
  writes.

o Note: Previously AS write batch length was adjusted synamically whenever
  a W->R batch data direction took place and when first request from the
  read batch completed.

  Now write batch updation takes place when last request from the write
  batch has finished during W->R transition.

o AS runs its own anticipation logic to anticipate on reads. common layer also
  does the anticipation on the group if think time of the group is with-in
  slice_idle.

o Introduced few debugging messages in AS.

o There are cases where in case of AS, excessive queue expiration will take
  place by elevator fair queuing layer because of few reasons.
        - AS does not anticipate on a queue if there are no competing requests.
          So if only a single reader is present in a group, anticipation does
          not get turn on.

        - elevator layer does not know that As is anticipating hence initiates
          expiry requests in select_ioq() thinking queue is empty.

        - elevaotr layer tries to aggressively expire last empty queue. This
          can lead to lof of queue expiry

o This patch now starts ANITC_WAIT_NEXT anticipation if last request in the
  queue completed and associated io context is eligible to anticipate. Also
  AS lets elevatory layer know that it is anticipating (elv_ioq_wait_request())
  This solves above mentioned issues.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   12 ++
 block/as-iosched.c       |  376 +++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.c      |  107 ++++++++++++--
 include/linux/elevator.h |    2 +
 4 files changed, 477 insertions(+), 20 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index cc87c87..8ab08da 100644
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
index 6d2468b..fed579f 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -16,6 +16,8 @@
 #include <linux/compiler.h>
 #include <linux/rbtree.h>
 #include <linux/interrupt.h>
+#include <linux/blktrace_api.h>
+#include "elevator-fq.h"
 
 /*
  * See Documentation/block/as-iosched.txt
@@ -77,6 +79,7 @@ enum anticipation_status {
 };
 
 struct as_queue {
+	struct io_queue *ioq;
 	/*
 	 * requests (as_rq s) are present on both sort_list and fifo_list
 	 */
@@ -84,10 +87,24 @@ struct as_queue {
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
 	int write_batch_idled;		/* has the write batch gone idle? */
+	int nr_queued[2];
 };
 
 struct as_data {
@@ -123,6 +140,9 @@ struct as_data {
 	unsigned long fifo_expire[2];
 	unsigned long batch_expire[2];
 	unsigned long antic_expire;
+
+	/* elevator requested a queue switch. */
+	int switch_queue;
 };
 
 /*
@@ -144,12 +164,259 @@ enum arq_state {
 #define RQ_STATE(rq)	((enum arq_state)(rq)->elevator_private2)
 #define RQ_SET_STATE(rq, state)	((rq)->elevator_private2 = (void *) state)
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+#define as_log_asq(ad, asq, fmt, args...)				\
+{									\
+	blk_add_trace_msg((ad)->q, "as %s " fmt,			\
+			ioq_to_io_group((asq)->ioq)->path, ##args);	\
+}
+#else
+#define as_log_asq(ad, asq, fmt, args...) \
+	blk_add_trace_msg((ad)->q, "as " fmt, ##args)
+#endif
+
+#define as_log(ad, fmt, args...)        \
+	blk_add_trace_msg((ad)->q, "as " fmt, ##args)
+
 static DEFINE_PER_CPU(unsigned long, ioc_count);
 static struct completion *ioc_gone;
 static DEFINE_SPINLOCK(ioc_gone_lock);
 
 static void as_move_to_dispatch(struct as_data *ad, struct request *rq);
 static void as_antic_stop(struct as_data *ad);
+static inline int as_batch_expired(struct as_data *ad, struct as_queue *asq);
+
+#ifdef CONFIG_IOSCHED_AS_HIER
+static int as_can_anticipate(struct as_data *ad, struct request *rq);
+static void as_antic_waitnext(struct as_data *ad);
+
+static inline void as_mark_active_asq_wait_request(struct as_data *ad)
+{
+	struct as_queue *asq = elv_active_sched_queue(ad->q->elevator);
+
+	elv_mark_ioq_wait_request(asq->ioq);
+}
+
+static inline void as_clear_active_asq_wait_request(struct as_data *ad)
+{
+	struct as_queue *asq = elv_active_sched_queue(ad->q->elevator);
+
+	if (asq)
+		elv_clear_ioq_wait_request(asq->ioq);
+}
+
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
+		goto out;
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
+		goto out;
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
+
+	if (ad->io_context) {
+		put_io_context(ad->io_context);
+		ad->io_context = NULL;
+	}
+
+out:
+	as_log_asq(ad, asq, "save batch: dir=%c time_left=%d changed_batch=%d"
+			" new_batch=%d, antic_status=%d",
+			ad->batch_data_dir ? 'R' : 'W',
+			asq->current_batch_time_left,
+			ad->changed_batch, ad->new_batch, ad->antic_status);
+	return;
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
+	as_log_asq(ad, asq, "restore batch: dir=%c time=%d reads_q=%d"
+			" writes_q=%d ad->antic_status=%d",
+			ad->batch_data_dir ? 'R' : 'W',
+			asq->current_batch_time_left,
+			asq->nr_queued[1], asq->nr_queued[0],
+			ad->antic_status);
+}
+
+/* ioq has been set. */
+static void as_active_ioq_set(struct request_queue *q, void *sched_queue,
+				int coop)
+{
+	struct as_queue *asq = sched_queue;
+	struct as_data *ad = q->elevator->elevator_data;
+
+	as_restore_batch_context(ad, asq);
+}
+
+/*
+ * AS does not anticipate on a context if there is no other request pending.
+ * So if only a single sequential reader was running, AS will not turn on
+ * anticipation. This function turns on anticipation if an io context has
+ * think time with-in limits and there are no other requests to dispatch.
+ *
+ * With group scheduling, a queue is expired if is empty, does not have a
+ * request dispatched and we are not idling. In case of this single reader
+ * we will see a queue expiration after every request completion. Hence turn
+ * on the anticipation if an io context should ancipate and there are no
+ * other requests queued in the queue.
+ */
+static inline void
+as_hier_check_start_waitnext(struct request_queue *q, struct as_queue *asq)
+{
+	struct as_data *ad = q->elevator->elevator_data;
+
+	if (!ad->nr_dispatched && !asq->nr_queued[1] && !asq->nr_queued[0] &&
+	    as_can_anticipate(ad, NULL)) {
+		as_antic_waitnext(ad);
+	}
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
+	as_log_asq(ad, asq, "as_expire_ioq slice_expired=%d, force=%d",
+			slice_expired, force);
+
+	/* Forced expiry. We don't have a choice */
+	if (force) {
+		as_antic_stop(ad);
+		/*
+		 * antic_stop() sets antic_status to FINISHED which signifies
+		 * that either we timed out or we found a close request but
+		 * that's not the case here. Start from scratch.
+		 */
+		ad->antic_status = ANTIC_OFF;
+		as_save_batch_context(ad, asq);
+		ad->switch_queue = 0;
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
+	 * If AS anticipation is ON, wait for it to finish if queue slice
+	 * has not expired.
+	 */
+	BUG_ON(status == ANTIC_WAIT_REQ);
+
+	if (status == ANTIC_WAIT_NEXT) {
+		if (!slice_expired)
+			goto keep_queue;
+		/* Slice expired. Stop anticipating. */
+		as_antic_stop(ad);
+		ad->antic_status = ANTIC_OFF;
+	}
+
+	/* We are good to expire the queue. Save batch context */
+	as_save_batch_context(ad, asq);
+	ad->switch_queue = 0;
+	return 1;
+
+keep_queue:
+	/* Mark that elevator requested for queue switch whenever possible */
+	ad->switch_queue = 1;
+	return 0;
+}
+
+static inline void as_check_expire_active_as_queue(struct request_queue *q)
+{
+	struct as_data *ad = q->elevator->elevator_data;
+	struct as_queue *asq = elv_active_sched_queue(q->elevator);
+
+	/*
+	 * We anticpated on the queue and timer fired. If queue is empty,
+	 * expire the queue. This will make sure an idle queue does not
+	 * remain active for a very long time as later all the idle time
+	 * can be added to the queue disk usage.
+	 */
+	if (asq) {
+		if (!ad->nr_dispatched && !asq->nr_queued[1] &&
+		    !asq->nr_queued[0]) {
+			ad->switch_queue = 0;
+			elv_ioq_slice_expired(q, asq->ioq);
+		}
+	}
+}
+
+#else /* CONFIG_IOSCHED_AS_HIER */
+static inline void as_mark_active_asq_wait_request(struct as_data *ad) {}
+static inline void as_clear_active_asq_wait_request(struct as_data *ad) {}
+static inline void
+as_hier_check_start_waitnext(struct request_queue *q, struct as_queue *asq) {}
+static inline void as_check_expire_active_as_queue(struct request_queue *q) {}
+#endif
 
 /*
  * IO Context helper functions
@@ -429,6 +696,8 @@ static void as_antic_waitnext(struct as_data *ad)
 	mod_timer(&ad->antic_timer, timeout);
 
 	ad->antic_status = ANTIC_WAIT_NEXT;
+	as_mark_active_asq_wait_request(ad);
+	as_log(ad, "antic_waitnext set");
 }
 
 /*
@@ -442,8 +711,10 @@ static void as_antic_waitreq(struct as_data *ad)
 	if (ad->antic_status == ANTIC_OFF) {
 		if (!ad->io_context || ad->ioc_finished)
 			as_antic_waitnext(ad);
-		else
+		else {
 			ad->antic_status = ANTIC_WAIT_REQ;
+			as_log(ad, "antic_waitreq set");
+		}
 	}
 }
 
@@ -455,9 +726,12 @@ static void as_antic_stop(struct as_data *ad)
 {
 	int status = ad->antic_status;
 
+	as_log(ad, "as_antic_stop antic_status=%d", ad->antic_status);
+
 	if (status == ANTIC_WAIT_REQ || status == ANTIC_WAIT_NEXT) {
 		if (status == ANTIC_WAIT_NEXT)
 			del_timer(&ad->antic_timer);
+		as_clear_active_asq_wait_request(ad);
 		ad->antic_status = ANTIC_FINISHED;
 		/* see as_work_handler */
 		kblockd_schedule_work(ad->q, &ad->antic_work);
@@ -474,6 +748,7 @@ static void as_antic_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
+	as_log(ad, "as_antic_timeout. antic_status=%d", ad->antic_status);
 	if (ad->antic_status == ANTIC_WAIT_REQ
 			|| ad->antic_status == ANTIC_WAIT_NEXT) {
 		struct as_io_context *aic;
@@ -481,6 +756,8 @@ static void as_antic_timeout(unsigned long data)
 		aic = ad->io_context->aic;
 
 		ad->antic_status = ANTIC_FINISHED;
+		as_clear_active_asq_wait_request(ad);
+		as_check_expire_active_as_queue(q);
 		kblockd_schedule_work(q, &ad->antic_work);
 
 		if (aic->ttime_samples == 0) {
@@ -652,6 +929,21 @@ static int as_can_break_anticipation(struct as_data *ad, struct request *rq)
 	struct io_context *ioc;
 	struct as_io_context *aic;
 
+#ifdef CONFIG_IOSCHED_AS_HIER
+	/*
+	 * If the active asq and rq's asq are not same, then one can not
+	 * break the anticipation. This primarily becomes useful when a
+	 * request is added to a queue which is not being served currently.
+	 */
+	if (rq) {
+		struct as_queue *asq = elv_get_sched_queue(ad->q, rq);
+		struct as_queue *curr_asq =
+				elv_active_sched_queue(ad->q->elevator);
+
+		if (asq != curr_asq)
+			return 0;
+	}
+#endif
 	ioc = ad->io_context;
 	BUG_ON(!ioc);
 	spin_lock(&ioc->lock);
@@ -810,16 +1102,21 @@ static void as_update_rq(struct as_data *ad, struct request *rq)
 /*
  * Gathers timings and resizes the write batch automatically
  */
-static void update_write_batch(struct as_data *ad)
+static void update_write_batch(struct as_data *ad, struct request *rq)
 {
 	unsigned long batch = ad->batch_expire[BLK_RW_ASYNC];
 	long write_time;
-	struct as_queue *asq = elv_get_sched_queue(ad->q, NULL);
+	struct as_queue *asq = elv_get_sched_queue(ad->q, rq);
 
 	write_time = (jiffies - ad->current_batch_expires) + batch;
 	if (write_time < 0)
 		write_time = 0;
 
+	as_log_asq(ad, asq, "upd write: write_time=%d batch=%d"
+			" write_batch_idled=%d current_write_count=%d",
+			write_time, batch, asq->write_batch_idled,
+			asq->current_write_count);
+
 	if (write_time > batch && !asq->write_batch_idled) {
 		if (write_time > batch * 3)
 			asq->write_batch_count /= 2;
@@ -834,6 +1131,8 @@ static void update_write_batch(struct as_data *ad)
 
 	if (asq->write_batch_count < 1)
 		asq->write_batch_count = 1;
+
+	as_log_asq(ad, asq, "upd write count=%d", asq->write_batch_count);
 }
 
 /*
@@ -843,6 +1142,7 @@ static void update_write_batch(struct as_data *ad)
 static void as_completed_request(struct request_queue *q, struct request *rq)
 {
 	struct as_data *ad = q->elevator->elevator_data;
+	struct as_queue *asq = elv_get_sched_queue(q, rq);
 
 	WARN_ON(!list_empty(&rq->queuelist));
 
@@ -851,7 +1151,24 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 		goto out;
 	}
 
+	as_log_asq(ad, asq, "complete: reads_q=%d writes_q=%d changed_batch=%d"
+		" new_batch=%d switch_queue=%d, dir=%c",
+		asq->nr_queued[1], asq->nr_queued[0], ad->changed_batch,
+		ad->new_batch, ad->switch_queue,
+		ad->batch_data_dir ? 'R' : 'W');
+
 	if (ad->changed_batch && ad->nr_dispatched == 1) {
+		/*
+		 * If this was write batch finishing, adjust the write batch
+		 * length.
+		 *
+		 * Note, write batch length is being calculated upon completion
+		 * of last write request finished and not completion of first
+		 * read request finished in the next batch.
+		 */
+		if (ad->batch_data_dir == BLK_RW_SYNC)
+			update_write_batch(ad, rq);
+
 		ad->current_batch_expires = jiffies +
 					ad->batch_expire[ad->batch_data_dir];
 		kblockd_schedule_work(q, &ad->antic_work);
@@ -869,7 +1186,6 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 	 * and writeback caches
 	 */
 	if (ad->new_batch && ad->batch_data_dir == rq_is_sync(rq)) {
-		update_write_batch(ad);
 		ad->current_batch_expires = jiffies +
 				ad->batch_expire[BLK_RW_SYNC];
 		ad->new_batch = 0;
@@ -884,10 +1200,18 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 			 * the next one
 			 */
 			as_antic_waitnext(ad);
-		}
+		} else
+			as_hier_check_start_waitnext(q, asq);
 	}
 
 	as_put_io_context(rq);
+
+	/*
+	 * If elevator requested a queue switch, kick the queue in the
+	 * hope that this is right time for switch.
+	 */
+	if (ad->switch_queue)
+		kblockd_schedule_work(q, &ad->antic_work);
 out:
 	RQ_SET_STATE(rq, AS_RQ_POSTSCHED);
 }
@@ -908,6 +1232,9 @@ static void as_remove_queued_request(struct request_queue *q,
 
 	WARN_ON(RQ_STATE(rq) != AS_RQ_QUEUED);
 
+	BUG_ON(asq->nr_queued[data_dir] <= 0);
+	asq->nr_queued[data_dir]--;
+
 	ioc = RQ_IOC(rq);
 	if (ioc && ioc->aic) {
 		BUG_ON(!atomic_read(&ioc->aic->nr_queued));
@@ -1019,6 +1346,8 @@ static void as_move_to_dispatch(struct as_data *ad, struct request *rq)
 	if (RQ_IOC(rq) && RQ_IOC(rq)->aic)
 		atomic_inc(&RQ_IOC(rq)->aic->nr_dispatched);
 	ad->nr_dispatched++;
+	as_log_asq(ad, asq, "dispatch req dir=%c nr_dispatched = %d",
+			data_dir ? 'R' : 'W', ad->nr_dispatched);
 }
 
 /*
@@ -1066,6 +1395,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 		}
 		asq->last_check_fifo[BLK_RW_ASYNC] = jiffies;
 
+		as_log_asq(ad, asq, "forced dispatch");
 		return dispatched;
 	}
 
@@ -1078,8 +1408,14 @@ static int as_dispatch_request(struct request_queue *q, int force)
 	if (!(reads || writes)
 		|| ad->antic_status == ANTIC_WAIT_REQ
 		|| ad->antic_status == ANTIC_WAIT_NEXT
-		|| ad->changed_batch)
+		|| ad->changed_batch) {
+		as_log_asq(ad, asq, "no dispatch. read_q=%d, writes_q=%d"
+			" ad->antic_status=%d, changed_batch=%d,"
+			" switch_queue=%d new_batch=%d", asq->nr_queued[1],
+			asq->nr_queued[0], ad->antic_status, ad->changed_batch,
+			ad->switch_queue, ad->new_batch);
 		return 0;
+	}
 
 	if (!(reads && writes && as_batch_expired(ad, asq))) {
 		/*
@@ -1092,6 +1428,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 				goto fifo_expired;
 
 			if (as_can_anticipate(ad, rq)) {
+				as_log_asq(ad, asq, "can_anticipate = 1");
 				as_antic_waitreq(ad);
 				return 0;
 			}
@@ -1111,6 +1448,8 @@ static int as_dispatch_request(struct request_queue *q, int force)
 	 * data direction (read / write)
 	 */
 
+	as_log_asq(ad, asq, "select a fresh batch and request");
+
 	if (reads) {
 		BUG_ON(RB_EMPTY_ROOT(&asq->sort_list[BLK_RW_SYNC]));
 
@@ -1125,6 +1464,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 			ad->changed_batch = 1;
 		}
 		ad->batch_data_dir = BLK_RW_SYNC;
+		as_log_asq(ad, asq, "new batch dir is sync");
 		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_SYNC].next);
 		asq->last_check_fifo[ad->batch_data_dir] = jiffies;
 		goto dispatch_request;
@@ -1149,6 +1489,7 @@ dispatch_writes:
 			ad->new_batch = 0;
 		}
 		ad->batch_data_dir = BLK_RW_ASYNC;
+		as_log_asq(ad, asq, "new batch dir is async");
 		asq->current_write_count = asq->write_batch_count;
 		asq->write_batch_idled = 0;
 		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_ASYNC].next);
@@ -1184,6 +1525,9 @@ fifo_expired:
 		ad->changed_batch = 0;
 	}
 
+	if (ad->switch_queue)
+		return 0;
+
 	/*
 	 * rq is the selected appropriate request.
 	 */
@@ -1207,6 +1551,11 @@ static void as_add_request(struct request_queue *q, struct request *rq)
 
 	rq->elevator_private = as_get_io_context(q->node);
 
+	asq->nr_queued[data_dir]++;
+	as_log_asq(ad, asq, "add a %c request read_q=%d write_q=%d",
+			data_dir ? 'R' : 'W', asq->nr_queued[1],
+			asq->nr_queued[0]);
+
 	if (RQ_IOC(rq)) {
 		as_update_iohist(ad, RQ_IOC(rq)->aic, rq);
 		atomic_inc(&RQ_IOC(rq)->aic->nr_queued);
@@ -1358,6 +1707,7 @@ static void *as_alloc_as_queue(struct request_queue *q,
 
 	if (asq->write_batch_count < 2)
 		asq->write_batch_count = 2;
+	asq->ioq = ioq;
 out:
 	return asq;
 }
@@ -1408,6 +1758,7 @@ static void *as_init_queue(struct request_queue *q, struct elevator_queue *eq)
 	ad->batch_expire[BLK_RW_ASYNC] = default_write_batch_expire;
 
 	ad->current_batch_expires = jiffies + ad->batch_expire[BLK_RW_SYNC];
+	ad->switch_queue = 0;
 
 	return ad;
 }
@@ -1493,6 +1844,11 @@ static struct elv_fs_entry as_attrs[] = {
 	AS_ATTR(antic_expire),
 	AS_ATTR(read_batch_expire),
 	AS_ATTR(write_batch_expire),
+#ifdef CONFIG_IOSCHED_AS_HIER
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_sync),
+	ELV_ATTR(group_idle),
+#endif
 	__ATTR_NULL
 };
 
@@ -1514,8 +1870,14 @@ static struct elevator_type iosched_as = {
 		.trim =				as_trim,
 		.elevator_alloc_sched_queue_fn = as_alloc_as_queue,
 		.elevator_free_sched_queue_fn = as_free_as_queue,
+#ifdef CONFIG_IOSCHED_AS_HIER
+		.elevator_expire_ioq_fn =       as_expire_ioq,
+		.elevator_active_ioq_set_fn =   as_active_ioq_set,
 	},
-
+	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ,
+#else
+	},
+#endif
 	.elevator_attrs = as_attrs,
 	.elevator_name = "anticipatory",
 	.elevator_owner = THIS_MODULE,
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 04419cf..149a147 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -2096,6 +2096,21 @@ alloc_sched_q:
 		elv_init_ioq_io_group(ioq, iog);
 		elv_init_ioq_sched_queue(e, ioq, sched_q);
 
+		/*
+		 * For AS, also mark the group queue idle_window. This will
+		 * make sure that select_ioq() will not try to expire an
+		 * AS queue if there are dispatched request from the queue but
+		 * queue is empty. This gives a chance to asq to anticipate
+		 * after request completion, otherwise select_ioq() will
+		 * mark it must_expire and soon asq will be expired.
+		 *
+		 * Not doing it for noop and deadline yet as they don't have
+		 * any anticpation logic and this will slow down queue
+		 * switching in a NCQ supporting hardware.
+		 */
+		if (!strcmp(e->elevator_type->elevator_name, "anticipatory"))
+			elv_mark_ioq_idle_window(ioq);
+
 		elv_io_group_set_ioq(iog, ioq);
 		elv_mark_ioq_sync(ioq);
 		elv_get_iog(iog);
@@ -2387,6 +2402,46 @@ static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq)
 }
 
 /*
+ * Call iosched to let that elevator wants to expire the queue. This gives
+ * iosched like AS to say no (if it is in the middle of batch changeover or
+ * it is anticipating). it also allows iosched to do some house keeping
+ *
+ * if force = 1, it is force dispatch and iosched must clean up its state.
+ * This is useful when elevator wants to drain iosched and wants to expire
+ * currnent active queue.
+ * if slice_expired = 1, ioq slice expired hence elevator fair queuing logic
+ * wants to switch the queue. iosched should allow that until and unless
+ * necessary. Currently AS can deny the switch if in the middle of batch switch.
+ *
+ * if slice_expired = 0, time slice is still remaining. It is up to the iosched
+ * whether it wants to wait on this queue or just want to expire it and move
+ * on to next queue.
+ */
+static int
+elv_iosched_expire_ioq(struct request_queue *q, int slice_expired, int force)
+{
+	struct elevator_queue *e = q->elevator;
+	struct io_queue *ioq = elv_active_ioq(q->elevator);
+	int ret = 1;
+
+	if (e->ops->elevator_expire_ioq_fn) {
+		ret = e->ops->elevator_expire_ioq_fn(q, ioq->sched_queue,
+							slice_expired, force);
+		/*
+		 * AS denied expiration of queue right now. Mark that elevator
+		 * layer has requested ioscheduler (as) to expire this queue.
+		 * Now as will try to expire this queue as soon as it can.
+		 * Now don't try to dispatch from this queue even if we get
+		 * a new request and if time slice is left. Do expire it once.
+		 */
+		if (!ret)
+			elv_mark_ioq_must_expire(ioq);
+	}
+
+	return ret;
+}
+
+/*
  * Do the accounting. Determine how much service (in terms of time slices)
  * current queue used and adjust the start, finish time of queue and vtime
  * of the tree accordingly.
@@ -2587,16 +2642,18 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 
 static void elv_preempt_queue(struct request_queue *q, struct io_queue *ioq)
 {
-	elv_log_ioq(q->elevator->efqd, ioq, "preempt");
-	elv_slice_expired(q);
+	if (elv_iosched_expire_ioq(q, 0, 1)) {
+		elv_log_ioq(q->elevator->efqd, ioq, "preempt");
+		elv_slice_expired(q);
 
-	/*
-	 * Put the new queue at the front of the of the current list,
-	 * so we know that it will be selected next.
-	 */
+		/*
+		 * Put the new queue at the front of the of the current list,
+		 * so we know that it will be selected next.
+		 */
 
-	requeue_ioq(ioq, 1);
-	elv_mark_ioq_slice_new(ioq);
+		requeue_ioq(ioq, 1);
+		elv_mark_ioq_slice_new(ioq);
+	}
 }
 
 void elv_ioq_request_add(struct request_queue *q, struct request *rq)
@@ -2729,6 +2786,8 @@ static void elv_idle_slice_timer(unsigned long data)
 			goto out_kick;
 	}
 expire:
+	/* Force expire the queue for AS */
+	elv_iosched_expire_ioq(q, 0, 1);
 	elv_slice_expired(q);
 out_kick:
 	elv_schedule_dispatch(q);
@@ -2819,6 +2878,8 @@ void *elv_select_ioq(struct request_queue *q, int force)
 	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
 	struct io_group *iog;
 	struct elv_fq_data *efqd = q->elevator->efqd;
+	struct elevator_type *e = q->elevator->elevator_type;
+	int slice_expired = 0;
 
 	if (!elv_nr_busy_ioq(q->elevator))
 		return NULL;
@@ -2894,6 +2955,7 @@ void *elv_select_ioq(struct request_queue *q, int force)
 		 * from queue and is not proportional to group's weight, it
 		 * harms the fairness of the group.
 		 */
+		slice_expired = 1;
 		if ((elv_iog_should_idle(ioq) || elv_ioq_should_wait_busy(ioq))
 		     && !elv_iog_wait_busy_done(iog)) {
 			ioq = NULL;
@@ -2939,11 +3001,15 @@ void *elv_select_ioq(struct request_queue *q, int force)
 	}
 
 expire:
-	if (efqd->fairness && !force && ioq && ioq->dispatched) {
+	if (efqd->fairness && !force && ioq && ioq->dispatched
+	    && strcmp(e->elevator_name, "anticipatory")) {
 		/*
 		 * If there are request dispatched from this queue, don't
 		 * dispatch requests from new queue till all the requests from
 		 * this queue have completed.
+		 *
+		 * Anticipatory does not allow queue switch until requests
+		 * from previous queue have finished.
 		 */
 		elv_log_ioq(efqd, ioq, "select: wait for requests to finish"
 				" disp=%lu", ioq->dispatched);
@@ -2951,7 +3017,14 @@ expire:
 		goto keep_queue;
 	}
 
-	elv_slice_expired(q);
+	if (elv_iosched_expire_ioq(q, slice_expired, force))
+		elv_slice_expired(q);
+	else
+		/*
+		 * Not making ioq = NULL, as AS can deny queue expiration and
+		 * continue to dispatch from same queue
+		 */
+		goto keep_queue;
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
 keep_queue:
@@ -3044,8 +3117,15 @@ check_expire_last_empty_queue(struct request_queue *q, struct io_queue *ioq)
 	if (ioq_is_idling(ioq))
 		return;
 
-	elv_log_ioq(efqd, ioq, "expire last empty queue");
-	elv_slice_expired(q);
+	/*
+	 * If IO scheduler denies expiration here, it is up to io scheduler
+	 * to expire the queue when possible. Otherwise all the idle time
+	 * will be charged to the queue when queue finally expires.
+	 */
+	if (elv_iosched_expire_ioq(q, 0, 0)) {
+		elv_log_ioq(efqd, ioq, "expire last empty queue");
+		elv_slice_expired(q);
+	}
 }
 
 /* A request got completed from io_queue. Do the accounting. */
@@ -3119,7 +3199,8 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 				goto done;
 
 			/* Expire the queue */
-			elv_slice_expired(q);
+			if (elv_iosched_expire_ioq(q, 1, 0))
+				elv_slice_expired(q);
 			goto done;
 		} else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq)
 			   && sync && !rq_noidle(rq))
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 77c1fa5..3d4e31c 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -41,6 +41,7 @@ typedef int (elevator_should_preempt_fn) (struct request_queue*, void*,
 						struct request*);
 typedef struct io_queue* (elevator_close_cooperator_fn) (struct request_queue*,
 						void*);
+typedef int (elevator_expire_ioq_fn) (struct request_queue*, void *, int, int);
 #endif
 
 struct elevator_ops
@@ -79,6 +80,7 @@ struct elevator_ops
 	elevator_arm_slice_timer_fn *elevator_arm_slice_timer_fn;
 	elevator_should_preempt_fn *elevator_should_preempt_fn;
 	elevator_close_cooperator_fn *elevator_close_cooperator_fn;
+	elevator_expire_ioq_fn  *elevator_expire_ioq_fn;
 #endif
 };
 
-- 
1.6.0.6
