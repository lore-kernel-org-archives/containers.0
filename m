From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 15/25] io-conroller: Prepare elevator layer for single queue
	schedulers
Date: Thu,  2 Jul 2009 16:01:47 -0400
Message-ID: <1246564917-19603-16-git-send-email-vgoyal__32374.3564928465$1246567998$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Elevator layer now has support for hierarchical fair queuing. cfq has
been migrated to make use of it and now it is time to do groundwork for
noop, deadline and AS.

noop deadline and AS don't maintain separate queues for different processes.
There is only one single queue. Effectively one can think that in hierarchical
setup, there will be one queue per cgroup where requests from all the
processes in the cgroup will be queued.

Generally io scheduler takes care of creating queues. Because there is
only one queue here, we have modified common layer to take care of queue
creation and some other functionality. This special casing helps in keeping
the changes to noop, deadline and AS to the minimum.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/as-iosched.c       |    2 +-
 block/deadline-iosched.c |    2 +-
 block/elevator-fq.c      |  206 +++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h      |   54 ++++++++++++
 block/elevator.c         |   37 ++++++++-
 block/noop-iosched.c     |    2 +-
 include/linux/elevator.h |   16 ++++-
 7 files changed, 312 insertions(+), 7 deletions(-)

diff --git a/block/as-iosched.c b/block/as-iosched.c
index cafc734..e3514eb 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -1338,7 +1338,7 @@ static int as_may_queue(struct request_queue *q, int rw)
 
 /* Called with queue lock held */
 static void *as_alloc_as_queue(struct request_queue *q,
-				struct elevator_queue *eq, gfp_t gfp_mask)
+		struct elevator_queue *eq, gfp_t gfp_mask, struct io_queue *ioq)
 {
 	struct as_queue *asq;
 	struct as_data *ad = eq->elevator_data;
diff --git a/block/deadline-iosched.c b/block/deadline-iosched.c
index 5bd5257..03d7208 100644
--- a/block/deadline-iosched.c
+++ b/block/deadline-iosched.c
@@ -341,7 +341,7 @@ dispatch_request:
 }
 
 static void *deadline_alloc_deadline_queue(struct request_queue *q,
-				struct elevator_queue *eq, gfp_t gfp_mask)
+		struct elevator_queue *eq, gfp_t gfp_mask, struct io_queue *ioq)
 {
 	struct deadline_queue *dq;
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 7609579..25fdac6 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1031,6 +1031,12 @@ io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
 
 	/* Free up async idle queue */
 	elv_release_ioq(e, &iog->async_idle_queue);
+
+#ifdef CONFIG_GROUP_IOSCHED
+	/* Optimization for io schedulers having single ioq */
+	if (elv_iosched_single_ioq(e))
+		elv_release_ioq(e, &iog->ioq);
+#endif
 }
 
 /* Mainly hierarchical grouping code */
@@ -1867,6 +1873,162 @@ int io_group_allow_merge(struct request *rq, struct bio *bio)
 
 	return (iog == __iog);
 }
+
+/*
+ * Find/Create the io queue the rq should go in. This is an optimization
+ * for the io schedulers (noop, deadline and AS) which maintain only single
+ * io queue per cgroup. In this case common layer can just maintain a
+ * pointer in group data structure and keeps track of it.
+ *
+ * For the io schdulers like cfq, which maintain multiple io queues per
+ * cgroup, and decide the io queue  of request based on process, this
+ * function is not invoked.
+ */
+int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
+					gfp_t gfp_mask)
+{
+	struct elevator_queue *e = q->elevator;
+	unsigned long flags;
+	struct io_queue *ioq = NULL, *new_ioq = NULL;
+	struct io_group *iog;
+	void *sched_q = NULL, *new_sched_q = NULL;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return 0;
+
+	might_sleep_if(gfp_mask & __GFP_WAIT);
+	spin_lock_irqsave(q->queue_lock, flags);
+
+retry:
+	/* Determine the io group request belongs to */
+	iog = io_get_io_group(q, 1);
+	BUG_ON(!iog);
+
+	/* Get the iosched queue */
+	ioq = iog->ioq;
+	if (!ioq) {
+		/* io queue and sched_queue needs to be allocated */
+		BUG_ON(!e->ops->elevator_alloc_sched_queue_fn);
+
+		if (new_ioq) {
+			goto alloc_sched_q;
+		} else if (gfp_mask & __GFP_WAIT) {
+			/*
+			 * Inform the allocator of the fact that we will
+			 * just repeat this allocation if it fails, to allow
+			 * the allocator to do whatever it needs to attempt to
+			 * free memory.
+			 */
+			spin_unlock_irq(q->queue_lock);
+			new_ioq = elv_alloc_ioq(q, gfp_mask | __GFP_NOFAIL
+							| __GFP_ZERO);
+			spin_lock_irq(q->queue_lock);
+			goto retry;
+		} else {
+			ioq = elv_alloc_ioq(q, gfp_mask | __GFP_ZERO);
+			if (!ioq)
+				goto queue_fail;
+		}
+
+alloc_sched_q:
+		if (new_sched_q) {
+			ioq = new_ioq;
+			new_ioq = NULL;
+			sched_q = new_sched_q;
+			new_sched_q = NULL;
+		} else if (gfp_mask & __GFP_WAIT) {
+			/*
+			 * Inform the allocator of the fact that we will
+			 * just repeat this allocation if it fails, to allow
+			 * the allocator to do whatever it needs to attempt to
+			 * free memory.
+			 */
+			spin_unlock_irq(q->queue_lock);
+			/* Call io scheduer to create scheduler queue */
+			new_sched_q = e->ops->elevator_alloc_sched_queue_fn(q,
+					e, gfp_mask | __GFP_NOFAIL
+					| __GFP_ZERO, new_ioq);
+			spin_lock_irq(q->queue_lock);
+			goto retry;
+		} else {
+			sched_q = e->ops->elevator_alloc_sched_queue_fn(q, e,
+						gfp_mask | __GFP_ZERO, ioq);
+			if (!sched_q) {
+				elv_free_ioq(ioq);
+				goto queue_fail;
+			}
+		}
+
+		elv_init_ioq(e, ioq, iog, sched_q, IOPRIO_CLASS_BE,
+					IOPRIO_NORM, 1);
+		io_group_set_ioq(iog, ioq);
+		elv_mark_ioq_sync(ioq);
+		elv_get_iog(iog);
+	}
+
+	if (new_sched_q)
+		e->ops->elevator_free_sched_queue_fn(q->elevator, new_sched_q);
+
+	if (new_ioq)
+		elv_free_ioq(new_ioq);
+
+	/* Request reference */
+	elv_get_ioq(ioq);
+	rq->ioq = ioq;
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return 0;
+
+queue_fail:
+	WARN_ON((gfp_mask & __GFP_WAIT) && !ioq);
+	elv_schedule_dispatch(q);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return 1;
+}
+
+/*
+ * Find out the io queue of current task. Optimization for single ioq
+ * per io group io schedulers.
+ */
+struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
+{
+	struct io_group *iog;
+
+	/* Determine the io group and io queue of the bio submitting task */
+	iog = io_get_io_group(q, 0);
+	if (!iog) {
+		/* May be task belongs to a cgroup for which io group has
+		 * not been setup yet. */
+		return NULL;
+	}
+	return iog->ioq;
+}
+
+/*
+ * This request has been serviced. Clean up ioq info and drop the reference.
+ * Again this is called only for single queue per cgroup schedulers (noop,
+ * deadline, AS).
+ */
+void elv_fq_unset_request_ioq(struct request_queue *q, struct request *rq)
+{
+	struct io_queue *ioq = rq->ioq;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	if (ioq) {
+		rq->ioq = NULL;
+		elv_put_ioq(ioq);
+	}
+}
+
+static inline int is_only_root_group(void)
+{
+	if (list_empty(&io_root_cgroup.css.cgroup->children))
+		return 1;
+
+	return 0;
+}
+
 #else /* GROUP_IOSCHED */
 static void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
 {
@@ -1916,6 +2078,11 @@ struct io_group *io_get_io_group(struct request_queue *q, int create)
 	return q->elevator->efqd.root_group;
 }
 EXPORT_SYMBOL(io_get_io_group);
+
+static inline int is_only_root_group(void)
+{
+	return 1;
+}
 #endif /* GROUP_IOSCHED */
 
 /* Elevator fair queuing function */
@@ -2206,7 +2373,12 @@ int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
 	ioq->efqd = efqd;
 	elv_ioq_set_ioprio_class(ioq, ioprio_class);
 	elv_ioq_set_ioprio(ioq, ioprio);
-	ioq->pid = current->pid;
+
+	if (elv_iosched_single_ioq(eq))
+		ioq->pid = 0;
+	else
+		ioq->pid = current->pid;
+
 	ioq->sched_queue = sched_queue;
 	if (is_sync && !elv_ioq_class_idle(ioq))
 		elv_mark_ioq_idle_window(ioq);
@@ -2589,6 +2761,14 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 	struct io_entity *entity, *new_entity;
 	struct io_group *iog = NULL, *new_iog = NULL;
 
+	/*
+	 * Currently only CFQ has preemption logic. Other schedulers don't
+	 * have any notion of preemption across classes or preemption with-in
+	 * class etc.
+	 */
+	if (elv_iosched_single_ioq(eq))
+		return 0;
+
 	ioq = elv_active_ioq(eq);
 
 	if (!ioq)
@@ -2873,6 +3053,17 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 			goto expire;
 	}
 
+	/*
+	 * If there is only root group present, don't expire the queue for
+	 * single queue ioschedulers (noop, deadline, AS). It is unnecessary
+	 * overhead.
+	 */
+
+	if (is_only_root_group() && elv_iosched_single_ioq(q->elevator)) {
+		elv_log_ioq(efqd, ioq, "select: only root group, no expiry");
+		goto keep_queue;
+	}
+
 	/* We are waiting for this queue to become busy before it expires.*/
 	if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
 		ioq = NULL;
@@ -3112,6 +3303,19 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		}
 
 		/*
+		 * If there is only root group present, don't expire the queue
+		 * for single queue ioschedulers (noop, deadline, AS). It is
+		 * unnecessary overhead.
+		 */
+
+		if (is_only_root_group() &&
+			elv_iosched_single_ioq(q->elevator)) {
+			elv_log_ioq(efqd, ioq, "select: only root group,"
+					" no expiry");
+			goto done;
+		}
+
+		/*
 		 * If there are no requests waiting in this queue, and
 		 * there are other queues ready to issue requests, AND
 		 * those other queues are issuing requests within our
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index a414309..baa6cee 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -255,6 +255,9 @@ struct io_group {
 
 	/* The device MKDEV(major, minor), this group has been created for */
 	dev_t	dev;
+
+	/* Single ioq per group, used for noop, deadline, anticipatory */
+	struct io_queue *ioq;
 };
 
 /**
@@ -514,6 +517,21 @@ static inline int update_requeue(struct io_queue *ioq, int requeue)
 	return requeue;
 }
 
+extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
+					gfp_t gfp_mask);
+extern void elv_fq_unset_request_ioq(struct request_queue *q,
+					struct request *rq);
+extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
+
+/* Sets the single ioq associated with the io group. (noop, deadline, AS) */
+static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
+{
+	BUG_ON(!iog);
+	/* io group reference. Will be dropped when group is destroyed. */
+	elv_get_ioq(ioq);
+	iog->ioq = ioq;
+}
+
 #else /* !GROUP_IOSCHED */
 static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
 {
@@ -533,6 +551,26 @@ static inline int update_requeue(struct io_queue *ioq, int requeue)
 	return requeue;
 }
 
+static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
+{
+}
+
+static inline int elv_fq_set_request_ioq(struct request_queue *q,
+					struct request *rq, gfp_t gfp_mask)
+{
+	return 0;
+}
+
+static inline void elv_fq_unset_request_ioq(struct request_queue *q,
+						struct request *rq)
+{
+}
+
+static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
+{
+	return NULL;
+}
+
 #endif /* GROUP_IOSCHED */
 
 extern ssize_t elv_slice_idle_show(struct elevator_queue *q, char *name);
@@ -642,5 +680,21 @@ static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
 {
 	return 1;
 }
+static inline int elv_fq_set_request_ioq(struct request_queue *q,
+					struct request *rq, gfp_t gfp_mask)
+{
+	return 0;
+}
+
+static inline void elv_fq_unset_request_ioq(struct request_queue *q,
+						struct request *rq)
+{
+}
+
+static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
+{
+	return NULL;
+}
+
 #endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _BFQ_SCHED_H */
diff --git a/block/elevator.c b/block/elevator.c
index 76cfc3a..862be80 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -206,9 +206,17 @@ static void *elevator_alloc_sched_queue(struct request_queue *q,
 {
 	void *sched_queue = NULL;
 
+	/*
+	 * If fair queuing is enabled, then queue allocation takes place
+	 * during set_request() functions when request actually comes
+	 * in.
+	 */
+	if (elv_iosched_fair_queuing_enabled(eq))
+		return NULL;
+
 	if (eq->ops->elevator_alloc_sched_queue_fn) {
 		sched_queue = eq->ops->elevator_alloc_sched_queue_fn(q, eq,
-								GFP_KERNEL);
+							GFP_KERNEL, NULL);
 		if (!sched_queue)
 			return ERR_PTR(-ENOMEM);
 
@@ -829,6 +837,13 @@ int elv_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
 {
 	struct elevator_queue *e = q->elevator;
 
+	/*
+	 * Optimization for noop, deadline and AS which maintain only single
+	 * ioq per io group
+	 */
+	if (elv_iosched_single_ioq(e))
+		return elv_fq_set_request_ioq(q, rq, gfp_mask);
+
 	if (e->ops->elevator_set_req_fn)
 		return e->ops->elevator_set_req_fn(q, rq, gfp_mask);
 
@@ -840,6 +855,15 @@ void elv_put_request(struct request_queue *q, struct request *rq)
 {
 	struct elevator_queue *e = q->elevator;
 
+	/*
+	 * Optimization for noop, deadline and AS which maintain only single
+	 * ioq per io group
+	 */
+	if (elv_iosched_single_ioq(e)) {
+		elv_fq_unset_request_ioq(q, rq);
+		return;
+	}
+
 	if (e->ops->elevator_put_req_fn)
 		e->ops->elevator_put_req_fn(rq);
 }
@@ -1224,9 +1248,18 @@ EXPORT_SYMBOL(elv_select_sched_queue);
 
 /*
  * Get the io scheduler queue pointer for current task.
+ *
+ * If fair queuing is enabled, determine the io group of task and retrieve
+ * the ioq pointer from that. This is used by only single queue ioschedulers
+ * for retrieving the queue associated with the group to decide whether the
+ * new bio can do a front merge or not.
  */
 void *elv_get_sched_queue_current(struct request_queue *q)
 {
-	return q->elevator->sched_queue;
+	/* Fair queuing is not enabled. There is only one queue. */
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return q->elevator->sched_queue;
+
+	return ioq_sched_queue(elv_lookup_ioq_current(q));
 }
 EXPORT_SYMBOL(elv_get_sched_queue_current);
diff --git a/block/noop-iosched.c b/block/noop-iosched.c
index d587832..731dbf2 100644
--- a/block/noop-iosched.c
+++ b/block/noop-iosched.c
@@ -62,7 +62,7 @@ noop_latter_request(struct request_queue *q, struct request *rq)
 }
 
 static void *noop_alloc_noop_queue(struct request_queue *q,
-				struct elevator_queue *eq, gfp_t gfp_mask)
+		struct elevator_queue *eq, gfp_t gfp_mask, struct io_queue *ioq)
 {
 	struct noop_queue *nq;
 
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index e7048b9..6d2c8db 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -30,7 +30,7 @@ typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct reques
 
 typedef void *(elevator_init_fn) (struct request_queue *);
 typedef void (elevator_exit_fn) (struct elevator_queue *);
-typedef void* (elevator_alloc_sched_queue_fn) (struct request_queue *q, struct elevator_queue *eq, gfp_t);
+typedef void* (elevator_alloc_sched_queue_fn) (struct request_queue *q, struct elevator_queue *eq, gfp_t, struct io_queue *ioq);
 typedef void (elevator_free_sched_queue_fn) (struct elevator_queue*, void *);
 #ifdef CONFIG_ELV_FAIR_QUEUING
 typedef void (elevator_active_ioq_set_fn) (struct request_queue*, void *, int);
@@ -247,17 +247,31 @@ enum {
 /* iosched wants to use fair queuing logic of elevator layer */
 #define	ELV_IOSCHED_NEED_FQ	1
 
+/* iosched maintains only single ioq per group.*/
+#define ELV_IOSCHED_SINGLE_IOQ        2
+
 static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
 {
 	return (e->elevator_type->elevator_features) & ELV_IOSCHED_NEED_FQ;
 }
 
+static inline int elv_iosched_single_ioq(struct elevator_queue *e)
+{
+	return (e->elevator_type->elevator_features) & ELV_IOSCHED_SINGLE_IOQ;
+}
+
 #else /* ELV_IOSCHED_FAIR_QUEUING */
 
 static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
 {
 	return 0;
 }
+
+static inline int elv_iosched_single_ioq(struct elevator_queue *e)
+{
+	return 0;
+}
+
 #endif /* ELV_IOSCHED_FAIR_QUEUING */
 extern void *elv_get_sched_queue(struct request_queue *q, struct request *rq);
 extern void *elv_select_sched_queue(struct request_queue *q, int force);
-- 
1.6.0.6
