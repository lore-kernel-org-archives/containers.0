From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 13/19] io-controller: anticipatory changes for hierarchical
	fair queuing
Date: Mon,  8 Jun 2009 22:08:56 -0400
Message-ID: <1244513342-11758-14-git-send-email-vgoyal__31992.9434256212$1244513821$gmane$org@redhat.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   12 ++
 block/as-iosched.c       |  275 +++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.c      |   86 +++++++++++++--
 include/linux/elevator.h |    2 +
 4 files changed, 358 insertions(+), 17 deletions(-)

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
index 3aa54a8..d115697 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -16,6 +16,7 @@
 #include <linux/compiler.h>
 #include <linux/rbtree.h>
 #include <linux/interrupt.h>
+#include <linux/blktrace_api.h>
 
 /*
  * See Documentation/block/as-iosched.txt
@@ -84,10 +85,24 @@ struct as_queue {
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
@@ -123,6 +138,9 @@ struct as_data {
 	unsigned long fifo_expire[2];
 	unsigned long batch_expire[2];
 	unsigned long antic_expire;
+
+	/* elevator requested a queue switch. */
+	int switch_queue;
 };
 
 /*
@@ -144,12 +162,174 @@ enum arq_state {
 #define RQ_STATE(rq)	((enum arq_state)(rq)->elevator_private2)
 #define RQ_SET_STATE(rq, state)	((rq)->elevator_private2 = (void *) state)
 
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
+	as_log(ad, "save batch: dir=%c time_left=%d changed_batch=%d"
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
+	as_log(ad, "restore batch: dir=%c time=%d reads_q=%d writes_q=%d"
+			" ad->antic_status=%d",
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
+	as_log(ad, "as_expire_ioq slice_expired=%d, force=%d", slice_expired,
+		force);
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
+	 * If AS anticipation is ON, wait for it to finish.
+	 */
+	BUG_ON(status == ANTIC_WAIT_REQ);
+
+	if (status == ANTIC_WAIT_NEXT)
+		goto keep_queue;
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
+#endif
 
 /*
  * IO Context helper functions
@@ -429,6 +609,7 @@ static void as_antic_waitnext(struct as_data *ad)
 	mod_timer(&ad->antic_timer, timeout);
 
 	ad->antic_status = ANTIC_WAIT_NEXT;
+	as_log(ad, "antic_waitnext set");
 }
 
 /*
@@ -442,8 +623,10 @@ static void as_antic_waitreq(struct as_data *ad)
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
 
@@ -455,6 +638,8 @@ static void as_antic_stop(struct as_data *ad)
 {
 	int status = ad->antic_status;
 
+	as_log(ad, "as_antic_stop antic_status=%d", ad->antic_status);
+
 	if (status == ANTIC_WAIT_REQ || status == ANTIC_WAIT_NEXT) {
 		if (status == ANTIC_WAIT_NEXT)
 			del_timer(&ad->antic_timer);
@@ -474,6 +659,7 @@ static void as_antic_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
+	as_log(ad, "as_antic_timeout");
 	if (ad->antic_status == ANTIC_WAIT_REQ
 			|| ad->antic_status == ANTIC_WAIT_NEXT) {
 		struct as_io_context *aic;
@@ -650,6 +836,21 @@ static int as_can_break_anticipation(struct as_data *ad, struct request *rq)
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
@@ -808,16 +1009,20 @@ static void as_update_rq(struct as_data *ad, struct request *rq)
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
 
+	as_log(ad, "upd write: write_time=%d batch=%d write_batch_idled=%d"
+			" current_write_count=%d", write_time, batch,
+			asq->write_batch_idled, asq->current_write_count);
+
 	if (write_time > batch && !asq->write_batch_idled) {
 		if (write_time > batch * 3)
 			asq->write_batch_count /= 2;
@@ -832,6 +1037,8 @@ static void update_write_batch(struct as_data *ad)
 
 	if (asq->write_batch_count < 1)
 		asq->write_batch_count = 1;
+
+	as_log(ad, "upd write count=%d", asq->write_batch_count);
 }
 
 /*
@@ -841,6 +1048,7 @@ static void update_write_batch(struct as_data *ad)
 static void as_completed_request(struct request_queue *q, struct request *rq)
 {
 	struct as_data *ad = q->elevator->elevator_data;
+	struct as_queue *asq = elv_get_sched_queue(q, rq);
 
 	WARN_ON(!list_empty(&rq->queuelist));
 
@@ -849,7 +1057,24 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 		goto out;
 	}
 
+	as_log(ad, "complete: reads_q=%d writes_q=%d changed_batch=%d"
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
@@ -867,7 +1092,6 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 	 * and writeback caches
 	 */
 	if (ad->new_batch && ad->batch_data_dir == rq_is_sync(rq)) {
-		update_write_batch(ad);
 		ad->current_batch_expires = jiffies +
 				ad->batch_expire[BLK_RW_SYNC];
 		ad->new_batch = 0;
@@ -886,6 +1110,13 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
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
@@ -906,6 +1137,9 @@ static void as_remove_queued_request(struct request_queue *q,
 
 	WARN_ON(RQ_STATE(rq) != AS_RQ_QUEUED);
 
+	BUG_ON(asq->nr_queued[data_dir] <= 0);
+	asq->nr_queued[data_dir]--;
+
 	ioc = RQ_IOC(rq);
 	if (ioc && ioc->aic) {
 		BUG_ON(!atomic_read(&ioc->aic->nr_queued));
@@ -1017,6 +1251,8 @@ static void as_move_to_dispatch(struct as_data *ad, struct request *rq)
 	if (RQ_IOC(rq) && RQ_IOC(rq)->aic)
 		atomic_inc(&RQ_IOC(rq)->aic->nr_dispatched);
 	ad->nr_dispatched++;
+	as_log(ad, "dispatch req dir=%c nr_dispatched = %d",
+			data_dir ? 'R' : 'W', ad->nr_dispatched);
 }
 
 /*
@@ -1064,6 +1300,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 		}
 		asq->last_check_fifo[BLK_RW_ASYNC] = jiffies;
 
+		as_log(ad, "forced dispatch");
 		return dispatched;
 	}
 
@@ -1076,8 +1313,14 @@ static int as_dispatch_request(struct request_queue *q, int force)
 	if (!(reads || writes)
 		|| ad->antic_status == ANTIC_WAIT_REQ
 		|| ad->antic_status == ANTIC_WAIT_NEXT
-		|| ad->changed_batch)
+		|| ad->changed_batch) {
+		as_log(ad, "no dispatch. read_q=%d, writes_q=%d"
+			" ad->antic_status=%d, changed_batch=%d,"
+			" switch_queue=%d new_batch=%d", asq->nr_queued[1],
+			asq->nr_queued[0], ad->antic_status, ad->changed_batch,
+			ad->switch_queue, ad->new_batch);
 		return 0;
+	}
 
 	if (!(reads && writes && as_batch_expired(ad, asq))) {
 		/*
@@ -1090,6 +1333,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 				goto fifo_expired;
 
 			if (as_can_anticipate(ad, rq)) {
+				as_log(ad, "can_anticipate = 1");
 				as_antic_waitreq(ad);
 				return 0;
 			}
@@ -1109,6 +1353,8 @@ static int as_dispatch_request(struct request_queue *q, int force)
 	 * data direction (read / write)
 	 */
 
+	as_log(ad, "select a fresh batch and request");
+
 	if (reads) {
 		BUG_ON(RB_EMPTY_ROOT(&asq->sort_list[BLK_RW_SYNC]));
 
@@ -1123,6 +1369,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 			ad->changed_batch = 1;
 		}
 		ad->batch_data_dir = BLK_RW_SYNC;
+		as_log(ad, "new batch dir is sync");
 		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_SYNC].next);
 		asq->last_check_fifo[ad->batch_data_dir] = jiffies;
 		goto dispatch_request;
@@ -1147,6 +1394,7 @@ dispatch_writes:
 			ad->new_batch = 0;
 		}
 		ad->batch_data_dir = BLK_RW_ASYNC;
+		as_log(ad, "new batch dir is async");
 		asq->current_write_count = asq->write_batch_count;
 		asq->write_batch_idled = 0;
 		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_ASYNC].next);
@@ -1182,6 +1430,9 @@ fifo_expired:
 		ad->changed_batch = 0;
 	}
 
+	if (ad->switch_queue)
+		return 0;
+
 	/*
 	 * rq is the selected appropriate request.
 	 */
@@ -1205,6 +1456,11 @@ static void as_add_request(struct request_queue *q, struct request *rq)
 
 	rq->elevator_private = as_get_io_context(q->node);
 
+	asq->nr_queued[data_dir]++;
+	as_log(ad, "add a %c request read_q=%d write_q=%d",
+			data_dir ? 'R' : 'W', asq->nr_queued[1],
+			asq->nr_queued[0]);
+
 	if (RQ_IOC(rq)) {
 		as_update_iohist(ad, RQ_IOC(rq)->aic, rq);
 		atomic_inc(&RQ_IOC(rq)->aic->nr_queued);
@@ -1410,6 +1666,7 @@ static void *as_init_queue(struct request_queue *q)
 	ad->batch_expire[BLK_RW_ASYNC] = default_write_batch_expire;
 
 	ad->current_batch_expires = jiffies + ad->batch_expire[BLK_RW_SYNC];
+	ad->switch_queue = 0;
 
 	return ad;
 }
@@ -1516,8 +1773,14 @@ static struct elevator_type iosched_as = {
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
index 5b6e878..3df74ac 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -39,6 +39,8 @@ static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
 struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 						 int extract);
 void elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
+int elv_iosched_expire_ioq(struct request_queue *q, int slice_expired,
+					int force);
 
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
 					unsigned short prio)
@@ -2543,6 +2545,7 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 		elv_clear_ioq_must_dispatch(ioq);
 		elv_clear_ioq_wait_busy_done(ioq);
 		elv_mark_ioq_slice_new(ioq);
+		elv_clear_ioq_must_expire(ioq);
 
 		del_timer(&efqd->idle_slice_timer);
 	}
@@ -2701,6 +2704,7 @@ void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
 	elv_clear_ioq_wait_request(ioq);
 	elv_clear_ioq_wait_busy(ioq);
 	elv_clear_ioq_wait_busy_done(ioq);
+	elv_clear_ioq_must_expire(ioq);
 
 	/*
 	 * if ioq->slice_end = 0, that means a queue was expired before first
@@ -2831,16 +2835,18 @@ int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 static void elv_preempt_queue(struct request_queue *q, struct io_queue *ioq)
 {
 	elv_log_ioq(&q->elevator->efqd, ioq, "preempt");
-	elv_ioq_slice_expired(q);
+	if (elv_iosched_expire_ioq(q, 0, 1)) {
+		elv_ioq_slice_expired(q);
 
-	/*
-	 * Put the new queue at the front of the of the current list,
-	 * so we know that it will be selected next.
-	 */
+		/*
+		 * Put the new queue at the front of the of the current list,
+		 * so we know that it will be selected next.
+		 */
 
-	elv_activate_ioq(ioq, 1);
-	elv_ioq_set_slice_end(ioq, 0);
-	elv_mark_ioq_slice_new(ioq);
+		elv_activate_ioq(ioq, 1);
+		elv_ioq_set_slice_end(ioq, 0);
+		elv_mark_ioq_slice_new(ioq);
+	}
 }
 
 void elv_ioq_request_add(struct request_queue *q, struct request *rq)
@@ -3011,11 +3017,55 @@ void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 	}
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
 /* Common layer function to select the next queue to dispatch from */
 void *elv_fq_select_ioq(struct request_queue *q, int force)
 {
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
+	int slice_expired = 1;
 
 	if (!elv_nr_busy_ioq(q->elevator))
 		return NULL;
@@ -3034,6 +3084,10 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 			goto expire;
 	}
 
+	/* This queue has been marked for expiry. Try to expire it */
+	if (elv_ioq_must_expire(ioq))
+		goto expire;
+
 	/*
 	 * If there is only root group present, don't expire the queue for
 	 * single queue ioschedulers (noop, deadline, AS). It is unnecessary
@@ -3121,8 +3175,16 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 		goto keep_queue;
 	}
 
+	slice_expired = 0;
 expire:
-	elv_ioq_slice_expired(q);
+	if (elv_iosched_expire_ioq(q, slice_expired, force))
+		elv_ioq_slice_expired(q);
+	else
+		/*
+		 * Not making ioq = NULL, as AS can deny queue expiration and
+		 * continue to dispatch from same queue
+		 */
+		goto keep_queue;
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
 keep_queue:
@@ -3287,7 +3349,8 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		}
 
 		if (elv_ioq_class_idle(ioq)) {
-			elv_ioq_slice_expired(q);
+			if (elv_iosched_expire_ioq(q, 1, 0))
+				elv_ioq_slice_expired(q);
 			goto done;
 		}
 
@@ -3321,7 +3384,8 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 				elv_ioq_arm_slice_timer(q, 1);
 			} else {
 				/* Expire the queue */
-				elv_ioq_slice_expired(q);
+				if (elv_iosched_expire_ioq(q, 1, 0))
+					elv_ioq_slice_expired(q);
 			}
 		} else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq, 1)
 			 && sync && !rq_noidle(rq))
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 3e99bdb..b47ecb3 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -42,6 +42,7 @@ typedef int (elevator_update_idle_window_fn) (struct elevator_queue*, void*,
 						struct request*);
 typedef struct io_queue* (elevator_close_cooperator_fn) (struct request_queue*,
 						void*, int probe);
+typedef int (elevator_expire_ioq_fn) (struct request_queue*, void *, int, int);
 #endif
 
 struct elevator_ops
@@ -81,6 +82,7 @@ struct elevator_ops
 	elevator_should_preempt_fn *elevator_should_preempt_fn;
 	elevator_update_idle_window_fn *elevator_update_idle_window_fn;
 	elevator_close_cooperator_fn *elevator_close_cooperator_fn;
+	elevator_expire_ioq_fn  *elevator_expire_ioq_fn;
 #endif
 };
 
-- 
1.6.0.6
