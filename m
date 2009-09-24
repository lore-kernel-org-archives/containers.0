From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 14/28] io-controller: Keep track of late preemptions
Date: Thu, 24 Sep 2009 15:25:18 -0400
Message-ID: <1253820332-10246-15-git-send-email-vgoyal__23981.1033978642$1253823168$gmane$org@redhat.com>
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
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  100 +++++++++++++++++++++++++++++++++++++++++++++++++++
 block/elevator-fq.h |    4 ++
 2 files changed, 104 insertions(+), 0 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index b8862d3..25beaf7 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -217,6 +217,62 @@ io_entity_sched_data(struct io_entity *entity)
 	return &iog_of(parent_entity(entity))->sched_data;
 }
 
+static inline void set_late_preemption(struct elevator_queue *eq,
+			struct io_queue *active_ioq, struct io_queue *new_ioq)
+{
+	struct io_group *new_iog;
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
@@ -248,6 +304,20 @@ io_entity_sched_data(struct io_entity *entity)
 
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
@@ -578,11 +648,14 @@ static void dequeue_io_entity(struct io_entity *entity)
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
@@ -627,6 +700,7 @@ static void enqueue_io_entity(struct io_entity *entity)
 {
 	struct io_service_tree *st;
 	struct io_sched_data *sd = io_entity_sched_data(entity);
+	struct io_queue *ioq = ioq_of(entity);
 
 	if (entity->on_idle_st)
 		dequeue_io_entity_idle(entity);
@@ -642,6 +716,9 @@ static void enqueue_io_entity(struct io_entity *entity)
 	st = entity->st;
 	st->nr_active++;
 	sd->nr_active++;
+	/* Keep a track of how many sync queues are backlogged on this group */
+	if (ioq && elv_ioq_sync(ioq) && !elv_ioq_class_idle(ioq))
+		sd->nr_sync++;
 	entity->on_st = 1;
 	place_entity(st, entity, 0);
 	__enqueue_io_entity(st, entity, 0);
@@ -1986,6 +2063,7 @@ __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq, int coop)
 		elv_clear_ioq_must_dispatch(ioq);
 		elv_clear_iog_wait_busy_done(iog);
 		elv_mark_ioq_slice_new(ioq);
+		elv_clear_ioq_must_expire(ioq);
 
 		del_timer(&efqd->idle_slice_timer);
 	}
@@ -2102,6 +2180,10 @@ void elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
 	elv_clear_iog_wait_request(iog);
 	elv_clear_iog_wait_busy(iog);
 	elv_clear_iog_wait_busy_done(iog);
+	elv_clear_ioq_must_expire(ioq);
+
+	if (elv_ioq_sync(ioq))
+		reset_late_preemption(q->elevator, iog, ioq);
 
 	/*
 	 * Queue got expired before even a single request completed or
@@ -2305,6 +2387,15 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 		 */
 		elv_preempt_queue(q, ioq);
 		__blk_run_queue(q);
+	} else {
+		/*
+		 * Request came in a queue which is not active and we did not
+		 * decide to preempt the active queue. It is possible that
+		 * active queue belonged to a different group and we did not
+		 * allow preemption. Keep a track of this event so that once
+		 * this group is ready to dispatch, we can do some more checks
+		 */
+		set_late_preemption(eq, elv_active_ioq(eq), ioq);
 	}
 }
 
@@ -2447,6 +2538,7 @@ void *elv_select_ioq(struct request_queue *q, int force)
 {
 	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
 	struct io_group *iog;
+	struct elv_fq_data *efqd = q->elevator->efqd;
 
 	if (!elv_nr_busy_ioq(q->elevator))
 		return NULL;
@@ -2471,6 +2563,12 @@ void *elv_select_ioq(struct request_queue *q, int force)
 			goto expire;
 	}
 
+	/* This queue has been marked for expiry. Try to expire it */
+	if (elv_ioq_must_expire(ioq)) {
+		elv_log_ioq(efqd, ioq, "select: ioq must_expire. expire");
+		goto expire;
+	}
+
 	/* We are waiting for this group to become busy before it expires.*/
 	if (elv_iog_wait_busy(iog)) {
 		ioq = NULL;
@@ -2555,6 +2653,8 @@ expire:
 new_queue:
 	ioq = elv_set_active_ioq(q, new_ioq);
 keep_queue:
+	if (ioq)
+		check_late_preemption(q->elevator, ioq);
 	return ioq;
 }
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 7b73f11..2992d93 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -43,6 +43,7 @@ struct io_sched_data {
 	struct io_entity *active_entity;
 	int nr_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
+	int nr_sync;
 };
 
 struct io_entity {
@@ -132,6 +133,7 @@ struct io_group {
 	/* Store cgroup path */
 	char path[128];
 #endif
+	int late_preemption;
 };
 
 struct io_cgroup {
@@ -227,6 +229,7 @@ enum elv_queue_state_flags {
 	ELV_QUEUE_FLAG_idle_window,       /* elevator slice idling enabled */
 	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
 	ELV_QUEUE_FLAG_sync,              /* synchronous queue */
+	ELV_QUEUE_FLAG_must_expire,       /* expire queue even slice is left */
 };
 
 #define ELV_IO_QUEUE_FLAG_FNS(name)					\
@@ -249,6 +252,7 @@ ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
 ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
 ELV_IO_QUEUE_FLAG_FNS(sync)
+ELV_IO_QUEUE_FLAG_FNS(must_expire)
 
 #ifdef CONFIG_GROUP_IOSCHED
 
-- 
1.6.0.6
