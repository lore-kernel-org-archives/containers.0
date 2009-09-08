From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 26/23] io-controller: fix writer preemption with in a group
Date: Tue, 8 Sep 2009 18:28:35 -0400
Message-ID: <20090908222835.GD3558__5000.47306200049$1252448997$gmane$org@redhat.com>
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


o Found another issue during testing. Consider following hierarchy.

			root
			/ \
		       R1  G1
			  /\
			 R2 W

  Generally in CFQ when readers and writers are running, reader immediately
  preempts writers and hence reader gets the better bandwidth. In case of
  hierarchical setup, it becomes little more tricky. In above diagram, G1
  is a group and R1, R2 are readers and W is writer tasks.

  Now assume W runs and then R1 runs and then R2 runs. After R2 has used its
  time slice, if R1 is schedule in, after couple of ms, R1 will get backlogged
  again in group G1, (streaming reader). But it will not preempt R1 as R1 is
  also a reader and also because preemption across group is not allowed for
  isolation reasons. Hence R2 will get backlogged in G1 and will get a 
  vdisktime much higher than W. So when G2 gets scheduled again, W will get
  to run its full slice length despite the fact R2 is queue on same service
  tree.

  The core issue here is that apart from regular preemptions (preemption 
  across classes), CFQ also has this special notion of preemption with-in
  class and that can lead to issues active task is running in a differnt
  group than where new queue gets backlogged.

  To solve the issue keep a track of this event (I am calling it late
  preemption). When a group becomes eligible to run again, if late_preemption
  is set, check if there are sync readers backlogged, and if yes, expire the
  writer after one round of dispatch.

  This solves the issue of reader not getting enough bandwidth in hierarchical
  setups.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  125 ++++++++++++++++++++++++++++++++++++++++++++++------
 block/elevator-fq.h |    2 
 2 files changed, 114 insertions(+), 13 deletions(-)

Index: linux16/block/elevator-fq.h
===================================================================
--- linux16.orig/block/elevator-fq.h	2009-09-08 15:47:45.000000000 -0400
+++ linux16/block/elevator-fq.h	2009-09-08 16:12:25.000000000 -0400
@@ -43,6 +43,7 @@ struct io_sched_data {
 	struct io_entity *active_entity;
 	int nr_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
+	int nr_sync;
 };
 
 struct io_entity {
@@ -150,6 +151,7 @@ struct io_group {
 	unsigned long state;
 	/* request list associated with the group */
 	struct request_list rl;
+	int late_preemption;
 };
 
 struct io_policy_node {
Index: linux16/block/elevator-fq.c
===================================================================
--- linux16.orig/block/elevator-fq.c	2009-09-08 15:47:45.000000000 -0400
+++ linux16/block/elevator-fq.c	2009-09-08 16:12:25.000000000 -0400
@@ -236,6 +236,68 @@ io_entity_sched_data(struct io_entity *e
 	return &iog_of(parent_entity(entity))->sched_data;
 }
 
+static inline void set_late_preemption(struct elevator_queue *eq,
+			struct io_queue *active_ioq, struct io_queue *new_ioq)
+{
+	struct io_group *new_iog;
+
+	if (elv_iosched_single_ioq(eq))
+		return;
+
+	if (!active_ioq)
+		return;
+
+	/* For the time being, set late preempt only if new queue is sync */
+	if (!elv_ioq_sync(new_ioq))
+		return;
+
+	new_iog = ioq_to_io_group(new_ioq);
+
+	if (ioq_to_io_group(active_ioq) != new_iog
+	    && !new_iog->late_preemption) {
+		new_iog->late_preemption = 1;
+		elv_log_ioq(eq->efqd, new_ioq, "set late preempt");
+	}
+}
+
+static inline void reset_late_preemption(struct elevator_queue *eq,
+				struct io_group *iog, struct io_queue *ioq)
+{
+	if (iog->late_preemption) {
+		iog->late_preemption = 0;
+		elv_log_ioq(eq->efqd, ioq, "reset late preempt");
+	}
+}
+
+static inline void
+check_late_preemption(struct elevator_queue *eq, struct io_queue *ioq)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+
+	if (elv_iosched_single_ioq(eq))
+		return;
+
+	if (!iog->late_preemption)
+		return;
+
+	/*
+	 * If a sync queue got queued in a group where other writers are are
+	 * queued and at the time of queuing some other reader was running
+	 * in anohter group, then this reader will not preempt the reader in
+	 * another group. Side affect of this is that once this group gets
+	 * scheduled, writer will start running and will not get preempted,
+	 * as it should have been.
+	 *
+	 * Don't expire the writer right now otherwise writers might get
+	 * completely starved. Let it just do one dispatch round and then
+	 * expire. Mark the queue for expiry.
+	 */
+	if (!elv_ioq_sync(ioq) && iog->sched_data.nr_sync) {
+		elv_mark_ioq_must_expire(ioq);
+		elv_log_ioq(eq->efqd, ioq, "late preempt, must expire");
+	}
+}
+
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -267,6 +329,20 @@ io_entity_sched_data(struct io_entity *e
 
 	return &efqd->root_group->sched_data;
 }
+
+static inline void set_late_preemption(struct elevator_queue *eq,
+		struct io_queue *active_ioq, struct io_queue *new_ioq)
+{
+}
+
+static inline void reset_late_preemption(struct elevator_queue *eq,
+				struct io_group *iog, struct io_queue *ioq)
+{
+}
+
+static inline void
+check_late_preemption(struct elevator_queue *eq, struct io_queue *ioq) { }
+
 #endif /* GROUP_IOSCHED */
 
 static inline void
@@ -620,11 +696,14 @@ static void dequeue_io_entity(struct io_
 {
 	struct io_service_tree *st = entity->st;
 	struct io_sched_data *sd = io_entity_sched_data(entity);
+	struct io_queue *ioq = ioq_of(entity);
 
 	__dequeue_io_entity(st, entity);
 	entity->on_st = 0;
 	st->nr_active--;
 	sd->nr_active--;
+	if (ioq && elv_ioq_sync(ioq) && !elv_ioq_class_idle(ioq))
+		sd->nr_sync--;
 	debug_update_stats_dequeue(entity);
 
 	if (vdisktime_gt(entity->vdisktime, st->min_vdisktime))
@@ -669,6 +748,7 @@ static void enqueue_io_entity(struct io_
 {
 	struct io_service_tree *st;
 	struct io_sched_data *sd = io_entity_sched_data(entity);
+	struct io_queue *ioq = ioq_of(entity);
 
 	if (entity->on_idle_st)
 		dequeue_io_entity_idle(entity);
@@ -684,6 +764,9 @@ static void enqueue_io_entity(struct io_
 	st = entity->st;
 	st->nr_active++;
 	sd->nr_active++;
+	/* Keep a track of how many sync queues are backlogged on this group */
+	if (ioq && elv_ioq_sync(ioq) && !elv_ioq_class_idle(ioq))
+		sd->nr_sync++;
 	entity->on_st = 1;
 	place_entity(st, entity, 0);
 	__enqueue_io_entity(st, entity, 0);
@@ -2796,6 +2879,8 @@ void elv_ioq_slice_expired(struct reques
 	elv_clear_iog_wait_busy_done(iog);
 	elv_clear_ioq_must_expire(ioq);
 
+	if (elv_ioq_sync(ioq))
+		reset_late_preemption(q->elevator, iog, ioq);
 	/*
 	 * Queue got expired before even a single request completed or
 	 * got expired immediately after first request completion. Use
@@ -2853,7 +2938,7 @@ void elv_slice_expired(struct request_qu
  * no or if we aren't sure, a 1 will cause a preemption attempt.
  */
 static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
-			struct request *rq)
+			struct request *rq, int group_wait_req)
 {
 	struct io_queue *ioq;
 	struct elevator_queue *eq = q->elevator;
@@ -2909,6 +2994,14 @@ static int elv_should_preempt(struct req
 	if (iog != new_iog)
 		return 0;
 
+	/*
+	 * New queue belongs to same group as active queue. If we are just
+ 	 * idling on the group (not queue), then let this new queue preempt
+ 	 * the active queue.
+ 	 */
+	if (group_wait_req)
+		return 1;
+
 	if (eq->ops->elevator_should_preempt_fn) {
 		void *sched_queue = elv_ioq_sched_queue(new_ioq);
 
@@ -2939,9 +3032,10 @@ void elv_ioq_request_add(struct request_
 	struct elv_fq_data *efqd = q->elevator->efqd;
 	struct io_queue *ioq = rq->ioq;
 	struct io_group *iog = ioq_to_io_group(ioq);
-	int group_wait = 0;
+	int group_wait_req = 0;
+	struct elevator_queue *eq = q->elevator;
 
-	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+	if (!elv_iosched_fair_queuing_enabled(eq))
 		return;
 
 	BUG_ON(!efqd);
@@ -2955,7 +3049,7 @@ void elv_ioq_request_add(struct request_
 	if (elv_iog_wait_request(iog)) {
 		del_timer(&efqd->idle_slice_timer);
 		elv_clear_iog_wait_request(iog);
-		group_wait = 1;
+		group_wait_req = 1;
 	}
 
 	/*
@@ -2970,7 +3064,7 @@ void elv_ioq_request_add(struct request_
 		return;
 	}
 
-	if (ioq == elv_active_ioq(q->elevator)) {
+	if (ioq == elv_active_ioq(eq)) {
 		/*
 		 * Remember that we saw a request from this process, but
 		 * don't start queuing just yet. Otherwise we risk seeing lots
@@ -2981,7 +3075,7 @@ void elv_ioq_request_add(struct request_
 		 * has other work pending, don't risk delaying until the
 		 * idle timer unplug to continue working.
 		 */
-		if (group_wait || elv_ioq_wait_request(ioq)) {
+		if (group_wait_req || elv_ioq_wait_request(ioq)) {
 			del_timer(&efqd->idle_slice_timer);
 			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
 			    efqd->busy_queues > 1 || !blk_queue_plugged(q))
@@ -2989,7 +3083,7 @@ void elv_ioq_request_add(struct request_
 			else
 				elv_mark_ioq_must_dispatch(ioq);
 		}
-	} else if (elv_should_preempt(q, ioq, rq)) {
+	} else if (elv_should_preempt(q, ioq, rq, group_wait_req)) {
 		/*
 		 * not the active queue - expire current slice if it is
 		 * idle and has expired it's mean thinktime or this new queue
@@ -2998,13 +3092,15 @@ void elv_ioq_request_add(struct request_
 		 */
 		elv_preempt_queue(q, ioq);
 		__blk_run_queue(q);
-	} else if (group_wait) {
+	} else {
 		/*
-		 * Got a request in the group we were waiting for. Request
-		 * does not belong to active queue and we have not decided
-		 * to preempt the current active queue. Schedule the dispatch.
+		 * Request came in a queue which is not active and we did not
+		 * decide to preempt the active queue. It is possible that
+		 * active queue belonged to a different group and we did not
+		 * allow preemption. Keep a track of this event so that once
+		 * this group is ready to dispatch, we can do some more checks
 		 */
-		elv_schedule_dispatch(q);
+		set_late_preemption(eq, elv_active_ioq(eq), ioq);
 	}
 }
 
@@ -3274,10 +3370,13 @@ expire:
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
 keep_queue:
-	if (ioq)
+	if (ioq) {
 		elv_log_ioq(efqd, ioq, "select busy=%d qued=%d disp=%d",
 				elv_nr_busy_ioq(q->elevator), ioq->nr_queued,
 				elv_ioq_nr_dispatched(ioq));
+		check_late_preemption(q->elevator, ioq);
+	}
+
 	return ioq;
 }
