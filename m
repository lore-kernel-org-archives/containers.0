From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/24] io-controller: Introduce group idling
Date: Sun, 16 Aug 2009 15:30:33 -0400
Message-ID: <1250451046-9966-12-git-send-email-vgoyal__34576.9149404534$1250452963$gmane$org@redhat.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250451046-9966-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, righi.andr
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o It is not always that IO from a process or group is continuous. There are
  cases of dependent reads where next read is not issued till previous read
  has finished. For such cases, CFQ introduced the notion of slice_idle,
  where we idle on the queue for sometime hoping next request will come
  and that's how fairness is provided otherwise queue will be deleted
  immediately from the service tree and this process will not get the
  fair share.

o This patch introduces the similar concept at group level. Idle on the group
  for a period of "group_idle" which is tunable through sysfs interface. So
  if a group is empty and about to be deleted, we idle for the next request.

o This patch also introduces the notion of wait busy where we wait for one
  extra group_idle period even if queue has consumed its time slice. The
  reason being that group will loose its share upon removal from service
  tree as some other entity will be picked for dispatch and vtime jump will
  take place.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/cfq-iosched.c |    5 +-
 block/elevator-fq.c |  207 +++++++++++++++++++++++++++++++++++++++++++++++++--
 block/elevator-fq.h |   44 +++++++++++-
 3 files changed, 247 insertions(+), 9 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 6c1f87a..11ae473 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -980,7 +980,7 @@ static int cfq_dispatch_requests(struct request_queue *q, int force)
 	 */
 	if (elv_nr_busy_ioq(q->elevator) > 1 && ((!cfq_cfqq_sync(cfqq) &&
 	    cfqq->slice_dispatch >= cfq_prio_to_maxrq(cfqd, cfqq)) ||
-	    cfq_class_idle(cfqq))) {
+	    (cfq_class_idle(cfqq) && !elv_iog_should_idle(cfqq->ioq)))) {
 		cfq_slice_expired(cfqd);
 	}
 
@@ -2121,6 +2121,9 @@ static struct elv_fs_entry cfq_attrs[] = {
 	CFQ_ATTR(slice_idle),
 	ELV_ATTR(slice_sync),
 	ELV_ATTR(slice_async),
+#ifdef CONFIG_GROUP_IOSCHED
+	ELV_ATTR(group_idle),
+#endif
 	__ATTR_NULL
 };
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 051a8c9..09377d0 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -19,6 +19,7 @@
 const int elv_slice_sync = HZ / 10;
 int elv_slice_async = HZ / 25;
 const int elv_slice_async_rq = 2;
+int elv_group_idle = HZ / 125;
 static struct kmem_cache *elv_ioq_pool;
 
 /*
@@ -251,6 +252,17 @@ init_io_entity_service_tree(struct io_entity *entity, struct io_entity *parent)
 	entity->st = &parent_iog->sched_data.service_tree[idx];
 }
 
+/*
+ * Returns the number of active entities a particular io group has. This
+ * includes number of active entities on service trees as well as the active
+ * entity which is being served currently, if any.
+ */
+
+static inline int elv_iog_nr_active(struct io_group *iog)
+{
+	return iog->sched_data.nr_active;
+}
+
 #ifdef CONFIG_DEBUG_GROUP_IOSCHED
 static void io_group_path(struct io_group *iog)
 {
@@ -659,6 +671,8 @@ ssize_t __FUNC(struct elevator_queue *e, char *page)		\
 		__data = jiffies_to_msecs(__data);			\
 	return elv_var_show(__data, (page));				\
 }
+SHOW_FUNCTION(elv_group_idle_show, efqd->elv_group_idle, 1);
+EXPORT_SYMBOL(elv_group_idle_show);
 SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
 EXPORT_SYMBOL(elv_slice_sync_show);
 SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
@@ -681,6 +695,8 @@ ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)\
 		*(__PTR) = __data;					\
 	return ret;							\
 }
+STORE_FUNCTION(elv_group_idle_store, &efqd->elv_group_idle, 0, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_group_idle_store);
 STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_sync_store);
 STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
@@ -842,6 +858,31 @@ static void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
 	entity->my_sd = &iog->sched_data;
 }
 
+/* Check if we plan to idle on the group associated with this queue or not */
+int elv_iog_should_idle(struct io_queue *ioq)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+	struct elv_fq_data *efqd = ioq->efqd;
+
+	/*
+	 * No idling on group if group idle is disabled or idling is disabled
+	 * for this group. Currently for root group idling is disabled.
+	 */
+	if (!efqd->elv_group_idle || !elv_iog_idle_window(iog))
+		return 0;
+
+	/*
+	 * If this is last active queue in group with no request queued, we
+	 * need to idle on group before expiring the queue to make sure group
+	 * does not loose its share.
+	 */
+	if ((elv_iog_nr_active(iog) <= 1) && !ioq->nr_queued)
+		return 1;
+
+	return 0;
+}
+EXPORT_SYMBOL(elv_iog_should_idle);
+
 static void io_group_set_parent(struct io_group *iog, struct io_group *parent)
 {
 	struct io_entity *entity = &iog->entity;
@@ -1209,6 +1250,7 @@ io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
 
 		atomic_set(&iog->ref, 0);
 
+		elv_mark_iog_idle_window(iog);
 		/*
 		 * Take the initial reference that will be released on destroy
 		 * This can be thought of a joint reference by cgroup and
@@ -1624,6 +1666,10 @@ static void io_free_root_group(struct elevator_queue *e)
 	kfree(iog);
 }
 
+/* No group idling in flat mode */
+int elv_iog_should_idle(struct io_queue *ioq) { return 0; }
+EXPORT_SYMBOL(elv_iog_should_idle);
+
 #endif /* CONFIG_GROUP_IOSCHED */
 
 /*
@@ -1684,7 +1730,9 @@ __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq, int coop)
 		ioq->dispatch_start = jiffies;
 
 		elv_clear_ioq_wait_request(ioq);
+		elv_clear_iog_wait_request(iog);
 		elv_clear_ioq_must_dispatch(ioq);
+		elv_clear_iog_wait_busy_done(iog);
 		elv_mark_ioq_slice_new(ioq);
 
 		del_timer(&efqd->idle_slice_timer);
@@ -1783,14 +1831,19 @@ void elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
 {
 	struct elv_fq_data *efqd = q->elevator->efqd;
 	long slice_used = 0, slice_overshoot = 0;
+	struct io_group *iog = ioq_to_io_group(ioq);
 
 	assert_spin_locked(q->queue_lock);
 	elv_log_ioq(efqd, ioq, "slice expired");
 
-	if (elv_ioq_wait_request(ioq))
+	if (elv_ioq_wait_request(ioq) || elv_iog_wait_request(iog)
+	    || elv_iog_wait_busy(iog))
 		del_timer(&efqd->idle_slice_timer);
 
 	elv_clear_ioq_wait_request(ioq);
+	elv_clear_iog_wait_request(iog);
+	elv_clear_iog_wait_busy(iog);
+	elv_clear_iog_wait_busy_done(iog);
 
 	/*
 	 * Queue got expired before even a single request completed or
@@ -1917,6 +1970,8 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 {
 	struct elv_fq_data *efqd = q->elevator->efqd;
 	struct io_queue *ioq = rq->ioq;
+	struct io_group *iog = ioq_to_io_group(ioq);
+	int group_wait = 0;
 
 	if (!elv_iosched_fair_queuing_enabled(q->elevator))
 		return;
@@ -1929,6 +1984,24 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 	if (!elv_ioq_busy(ioq))
 		elv_add_ioq_busy(efqd, ioq);
 
+	if (elv_iog_wait_request(iog)) {
+		del_timer(&efqd->idle_slice_timer);
+		elv_clear_iog_wait_request(iog);
+		group_wait = 1;
+	}
+
+	/*
+	 * If we were waiting for a request on this group, wait is
+	 * done. Schedule the next dispatch
+	 */
+	if (elv_iog_wait_busy(iog)) {
+		del_timer(&efqd->idle_slice_timer);
+		elv_clear_iog_wait_busy(iog);
+		elv_mark_iog_wait_busy_done(iog);
+		elv_schedule_dispatch(q);
+		return;
+	}
+
 	if (ioq == elv_active_ioq(q->elevator)) {
 		/*
 		 * Remember that we saw a request from this process, but
@@ -1940,7 +2013,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 		 * has other work pending, don't risk delaying until the
 		 * idle timer unplug to continue working.
 		 */
-		if (elv_ioq_wait_request(ioq)) {
+		if (group_wait || elv_ioq_wait_request(ioq)) {
 			del_timer(&efqd->idle_slice_timer);
 			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
 			    efqd->busy_queues > 1 || !blk_queue_plugged(q))
@@ -1957,6 +2030,13 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 		 */
 		elv_preempt_queue(q, ioq);
 		__blk_run_queue(q);
+	} else if (group_wait) {
+		/*
+		 * Got a request in the group we were waiting for. Request
+		 * does not belong to active queue and we have not decided
+		 * to preempt the current active queue. Schedule the dispatch.
+		 */
+		elv_schedule_dispatch(q);
 	}
 }
 
@@ -1974,6 +2054,14 @@ static void elv_idle_slice_timer(unsigned long data)
 	ioq = efqd->active_queue;
 
 	if (ioq) {
+		struct io_group *iog = ioq_to_io_group(ioq);
+
+		elv_clear_iog_wait_request(iog);
+
+		if (elv_iog_wait_busy(iog)) {
+			elv_clear_iog_wait_busy(iog);
+			goto expire;
+		}
 
 		/*
 		 * We saw a request before the queue expired, let it through
@@ -2017,6 +2105,32 @@ static void elv_ioq_arm_slice_timer(struct request_queue *q)
 		eq->ops->elevator_arm_slice_timer_fn(q, ioq->sched_queue);
 }
 
+static void elv_iog_arm_slice_timer(struct request_queue *q,
+				struct io_group *iog, int wait_for_busy)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+	unsigned long sl;
+
+	if (!efqd->elv_group_idle || !elv_iog_idle_window(iog))
+		return;
+	/*
+	 * This queue has consumed its time slice. We are waiting only for
+	 * it to become busy before we select next queue for dispatch.
+	 */
+	if (wait_for_busy) {
+		elv_mark_iog_wait_busy(iog);
+		sl = efqd->elv_group_idle;
+		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+		elv_log_iog(efqd, iog, "arm idle group: %lu wait busy=1", sl);
+		return;
+	}
+
+	elv_mark_iog_wait_request(iog);
+	sl = efqd->elv_group_idle;
+	mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+	elv_log_iog(efqd, iog, "arm_idle group: %lu", sl);
+}
+
 /*
  * If io scheduler has functionality of keeping track of close cooperator, check
  * with it if it has got a closely co-operating queue.
@@ -2046,6 +2160,7 @@ void *elv_select_ioq(struct request_queue *q, int force)
 {
 	struct elv_fq_data *efqd = q->elevator->efqd;
 	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
+	struct io_group *iog;
 
 	if (!elv_nr_busy_ioq(q->elevator))
 		return NULL;
@@ -2053,6 +2168,8 @@ void *elv_select_ioq(struct request_queue *q, int force)
 	if (ioq == NULL)
 		goto new_queue;
 
+	iog = ioq_to_io_group(ioq);
+
 	/*
 	 * Force dispatch. Continue to dispatch from current queue as long
 	 * as it has requests.
@@ -2064,11 +2181,47 @@ void *elv_select_ioq(struct request_queue *q, int force)
 			goto expire;
 	}
 
+	/* We are waiting for this group to become busy before it expires.*/
+	if (elv_iog_wait_busy(iog)) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
 	/*
 	 * The active queue has run out of time, expire it and select new.
 	 */
-	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq))
-		goto expire;
+	if ((elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+	     && !elv_ioq_must_dispatch(ioq)) {
+		/*
+		 * Queue has used up its slice. Wait busy is not on otherwise
+		 * we wouldn't have been here. If this group will be deleted
+		 * after the queue expiry, then make sure we have onece
+		 * done wait busy on the group in an attempt to make it
+		 * backlogged.
+		 *
+		 * Following check helps in two conditions.
+		 * - If there are requests dispatched from the queue and
+		 *   select_ioq() comes before a request completed from the
+		 *   queue and got a chance to arm any of the idle timers.
+		 *
+		 * - If at request completion time slice had not expired and
+		 *   we armed either a ioq timer or group timer but when
+		 *   select_ioq() hits, slice has expired and it will expire
+		 *   the queue without doing busy wait on group.
+		 *
+		 * In similar situations cfq lets delte the queue even if
+		 * idle timer is armed. That does not impact fairness in non
+		 * hierarhical setup due to weighted slice lengths. But in
+		 * hierarchical setup where group slice lengths are derived
+		 * from queue and is not proportional to group's weight, it
+		 * harms the fairness of the group.
+		 */
+		if (elv_iog_should_idle(ioq) && !elv_iog_wait_busy_done(iog)) {
+			ioq = NULL;
+			goto keep_queue;
+		} else
+			goto expire;
+	}
 
 	/*
 	 * The active queue has requests and isn't expired, allow it to
@@ -2100,6 +2253,12 @@ void *elv_select_ioq(struct request_queue *q, int force)
 		goto keep_queue;
 	}
 
+	/* Check for group idling */
+	if (elv_iog_should_idle(ioq) && elv_ioq_nr_dispatched(ioq)) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
 expire:
 	elv_slice_expired(q);
 new_queue:
@@ -2171,11 +2330,13 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 	const int sync = rq_is_sync(rq);
 	struct io_queue *ioq;
 	struct elv_fq_data *efqd = q->elevator->efqd;
+	struct io_group *iog;
 
 	if (!elv_iosched_fair_queuing_enabled(q->elevator))
 		return;
 
 	ioq = rq->ioq;
+	iog = ioq_to_io_group(ioq);
 	WARN_ON(!efqd->rq_in_driver);
 	WARN_ON(!ioq->dispatched);
 	efqd->rq_in_driver--;
@@ -2201,13 +2362,44 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		 * mean seek distance, give them a chance to run instead
 		 * of idling.
 		 */
-		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq)) {
+			/*
+			 * This is the last empty queue in the group and it
+			 * has consumed its slice. If we expire it right away
+			 * group might loose its share. Wait for an extra
+			 * group_idle period for a request before queue
+			 * expires.
+			 */
+			if (elv_iog_should_idle(ioq)) {
+				elv_iog_arm_slice_timer(q, iog, 1);
+				goto done;
+			}
+
+			/* Expire the queue */
 			elv_slice_expired(q);
-		else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq)
+			goto done;
+		} else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq)
 			 && sync && !rq_noidle(rq))
 			elv_ioq_arm_slice_timer(q);
+		/*
+		 * If this is the last queue in the group and we did not
+		 * decide to idle on queue, idle on group.
+		 */
+		if (elv_iog_should_idle(ioq) && !ioq->dispatched
+		    && !timer_pending(&efqd->idle_slice_timer)) {
+			/*
+			 * If queue has used up its slice, wait for the
+			 * one extra group_idle period to let the group
+			 * backlogged again. This is to avoid a group loosing
+			 * its fair share.
+			 */
+			if (elv_ioq_slice_used(ioq))
+				elv_iog_arm_slice_timer(q, iog, 1);
+			else
+				elv_iog_arm_slice_timer(q, iog, 0);
+		}
 	}
-
+done:
 	if (!efqd->rq_in_driver)
 		elv_schedule_dispatch(q);
 }
@@ -2284,6 +2476,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
+	efqd->elv_group_idle = elv_group_idle;
 
 	return 0;
 }
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 0b6ecf5..5f2cb8b 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -97,6 +97,7 @@ struct io_queue {
 struct io_group {
 	struct io_entity entity;
 	atomic_t ref;
+	unsigned int flags;
 	struct io_sched_data sched_data;
 	struct hlist_node group_node;
 	struct hlist_node elv_data_node;
@@ -171,6 +172,8 @@ struct elv_fq_data {
 	struct timer_list idle_slice_timer;
 	struct work_struct unplug_work;
 
+	unsigned int elv_group_idle;
+
 	/* Base slice length for sync and async queues */
 	unsigned int elv_slice[2];
 
@@ -239,6 +242,42 @@ ELV_IO_QUEUE_FLAG_FNS(idle_window)
 ELV_IO_QUEUE_FLAG_FNS(slice_new)
 ELV_IO_QUEUE_FLAG_FNS(sync)
 
+#ifdef CONFIG_GROUP_IOSCHED
+
+enum elv_group_state_flags {
+	ELV_GROUP_FLAG_idle_window,	  /* elevator group idling enabled */
+	ELV_GROUP_FLAG_wait_request,	  /* waiting for a request */
+	ELV_GROUP_FLAG_wait_busy,	  /* wait for this queue to get busy */
+	ELV_GROUP_FLAG_wait_busy_done,	  /* Have already waited on this group*/
+};
+
+#define ELV_IO_GROUP_FLAG_FNS(name)					\
+static inline void elv_mark_iog_##name(struct io_group *iog)		\
+{                                                                       \
+	(iog)->flags |= (1 << ELV_GROUP_FLAG_##name);			\
+}                                                                       \
+static inline void elv_clear_iog_##name(struct io_group *iog)		\
+{                                                                       \
+	(iog)->flags &= ~(1 << ELV_GROUP_FLAG_##name);			\
+}                                                                       \
+static inline int elv_iog_##name(struct io_group *iog)         		\
+{                                                                       \
+	return ((iog)->flags & (1 << ELV_GROUP_FLAG_##name)) != 0;	\
+}
+
+#else /* GROUP_IOSCHED */
+
+#define ELV_IO_GROUP_FLAG_FNS(name)					\
+static inline void elv_mark_iog_##name(struct io_group *iog) {}		\
+static inline void elv_clear_iog_##name(struct io_group *iog) {}	\
+static inline int elv_iog_##name(struct io_group *iog) { return 0; }
+#endif /* GROUP_IOSCHED */
+
+ELV_IO_GROUP_FLAG_FNS(idle_window)
+ELV_IO_GROUP_FLAG_FNS(wait_request)
+ELV_IO_GROUP_FLAG_FNS(wait_busy)
+ELV_IO_GROUP_FLAG_FNS(wait_busy_done)
+
 static inline void elv_get_ioq(struct io_queue *ioq)
 {
 	atomic_inc(&ioq->ref);
@@ -364,7 +403,9 @@ extern int elv_io_group_allow_merge(struct request *rq, struct bio *bio);
 extern void elv_put_iog(struct io_group *iog);
 extern struct io_group *elv_io_get_io_group(struct request_queue *q,
 						int create);
-
+extern ssize_t elv_group_idle_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_group_idle_store(struct elevator_queue *q, const char *name,
+					size_t count);
 static inline void elv_get_iog(struct io_group *iog)
 {
 	atomic_inc(&iog->ref);
@@ -432,6 +473,7 @@ extern void elv_io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
 extern void elv_free_ioq(struct io_queue *ioq);
 extern struct io_group *ioq_to_io_group(struct io_queue *ioq);
+extern int elv_iog_should_idle(struct io_queue *ioq);
 
 #else /* CONFIG_ELV_FAIR_QUEUING */
 static inline struct elv_fq_data *
-- 
1.6.0.6
