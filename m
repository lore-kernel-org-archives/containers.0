From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/25] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Thu,  2 Jul 2009 16:01:36 -0400
Message-ID: <1246564917-19603-5-git-send-email-vgoyal__18678.7319639281$1246568293$gmane$org@redhat.com>
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

This is common fair queuing code in elevator layer. This is controlled by
config option CONFIG_ELV_FAIR_QUEUING. This patch initially only introduces
flat fair queuing support where there is only one group, "root group" and all
the tasks belong to root group.

This elevator layer changes are backward compatible. That means any ioscheduler
using old interfaces will continue to work.

This code is essentially the CFQ code for fair queuing. The primary difference
is that flat rounding robin algorithm of CFQ has been replaced with BFQ (WF2Q+).

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   13 +
 block/Makefile           |    1 +
 block/blk.h              |    4 +
 block/elevator-fq.c      | 1254 +++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h      |  304 +++++++++++
 block/elevator.c         |   42 ++-
 include/linux/blkdev.h   |   14 +
 include/linux/elevator.h |   51 ++
 8 files changed, 1667 insertions(+), 16 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 7e803fc..3398134 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -2,6 +2,19 @@ if BLOCK
 
 menu "IO Schedulers"
 
+config ELV_FAIR_QUEUING
+	bool "Elevator Fair Queuing Support"
+	default n
+	---help---
+	  Traditionally only cfq had notion of multiple queues and it did
+	  fair queuing at its own. With the cgroups and need of controlling
+	  IO, now even the simple io schedulers like noop, deadline, as will
+	  have one queue per cgroup and will need hierarchical fair queuing.
+	  Instead of every io scheduler implementing its own fair queuing
+	  logic, this option enables fair queuing in elevator layer so that
+	  other ioschedulers can make use of it.
+	  If unsure, say N.
+
 config IOSCHED_NOOP
 	bool
 	default y
diff --git a/block/Makefile b/block/Makefile
index e9fa4dd..94bfc6e 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -15,3 +15,4 @@ obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
 
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
+obj-$(CONFIG_ELV_FAIR_QUEUING)	+= elevator-fq.o
diff --git a/block/blk.h b/block/blk.h
index 3fae6ad..99c3819 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -71,6 +71,8 @@ static inline void elv_activate_rq(struct request_queue *q, struct request *rq)
 {
 	struct elevator_queue *e = q->elevator;
 
+	elv_fq_activate_rq(q, rq);
+
 	if (e->ops->elevator_activate_req_fn)
 		e->ops->elevator_activate_req_fn(q, rq);
 }
@@ -79,6 +81,8 @@ static inline void elv_deactivate_rq(struct request_queue *q, struct request *rq
 {
 	struct elevator_queue *e = q->elevator;
 
+	elv_fq_deactivate_rq(q, rq);
+
 	if (e->ops->elevator_deactivate_req_fn)
 		e->ops->elevator_deactivate_req_fn(q, rq);
 }
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 7ee4321..6f23d7e 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -14,6 +14,17 @@
 
 #include <linux/blkdev.h>
 #include "elevator-fq.h"
+#include <linux/blktrace_api.h>
+
+/* Values taken from cfq */
+const int elv_slice_sync = HZ / 10;
+int elv_slice_async = HZ / 25;
+const int elv_slice_async_rq = 2;
+int elv_slice_idle = HZ / 125;
+static struct kmem_cache *elv_ioq_pool;
+
+#define ELV_SLICE_SCALE		(5)
+#define ELV_HW_QUEUE_MIN	(5)
 
 #define IO_SERVICE_TREE_INIT   ((struct io_service_tree)		\
 				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
@@ -28,6 +39,22 @@
  */
 #define WFQ_SERVICE_SHIFT	22
 
+static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
+					unsigned short prio)
+{
+	const int base_slice = efqd->elv_slice[sync];
+
+	WARN_ON(prio >= IOPRIO_BE_NR);
+
+	return base_slice + (base_slice/ELV_SLICE_SCALE * (4 - prio));
+}
+
+static inline int
+elv_prio_to_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
+{
+	return elv_prio_slice(efqd, elv_ioq_sync(ioq), ioq->entity.ioprio);
+}
+
 /**
  * bfq_gt - compare two timestamps.
  * @a: first ts.
@@ -423,11 +450,6 @@ __bfq_entity_update_prio(struct io_service_tree *old_st,
 		 */
 		if (ioq) {
 			struct elv_fq_data *efqd = ioq->efqd;
-			/*
-			 * elv_prio_to_slice() is defined in later patches
-			 * where a slice length is calculated from the
-			 * ioprio of the queue.
-			 */
 			entity->budget = elv_prio_to_slice(efqd, ioq);
 		}
 
@@ -750,3 +772,1225 @@ static void io_flush_idle_tree(struct io_service_tree *st)
 	for (; entity != NULL; entity = st->first_idle)
 		__bfq_deactivate_entity(entity, 0);
 }
+
+/* Elevator fair queuing function */
+static inline struct io_queue *elv_active_ioq(struct elevator_queue *e)
+{
+	return e->efqd.active_queue;
+}
+
+void *elv_active_sched_queue(struct elevator_queue *e)
+{
+	return ioq_sched_queue(elv_active_ioq(e));
+}
+EXPORT_SYMBOL(elv_active_sched_queue);
+
+int elv_nr_busy_ioq(struct elevator_queue *e)
+{
+	return e->efqd.busy_queues;
+}
+EXPORT_SYMBOL(elv_nr_busy_ioq);
+
+int elv_hw_tag(struct elevator_queue *e)
+{
+	return e->efqd.hw_tag;
+}
+EXPORT_SYMBOL(elv_hw_tag);
+
+/* Helper functions for operating on elevator idle slice timer */
+int elv_mod_idle_slice_timer(struct elevator_queue *eq, unsigned long expires)
+{
+	struct elv_fq_data *efqd = &eq->efqd;
+
+	return mod_timer(&efqd->idle_slice_timer, expires);
+}
+EXPORT_SYMBOL(elv_mod_idle_slice_timer);
+
+int elv_del_idle_slice_timer(struct elevator_queue *eq)
+{
+	struct elv_fq_data *efqd = &eq->efqd;
+
+	return del_timer(&efqd->idle_slice_timer);
+}
+EXPORT_SYMBOL(elv_del_idle_slice_timer);
+
+unsigned int elv_get_slice_idle(struct elevator_queue *eq)
+{
+	return eq->efqd.elv_slice_idle;
+}
+EXPORT_SYMBOL(elv_get_slice_idle);
+
+static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
+{
+	entity_served(&ioq->entity, served);
+}
+
+/* Tells whether ioq is queued in root group or not */
+static inline int is_root_group_ioq(struct request_queue *q,
+					struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	return (ioq->entity.sched_data == &efqd->root_group->sched_data);
+}
+
+/*
+ * sysfs parts below -->
+ */
+static ssize_t
+elv_var_show(unsigned int var, char *page)
+{
+	return sprintf(page, "%d\n", var);
+}
+
+static ssize_t
+elv_var_store(unsigned int *var, const char *page, size_t count)
+{
+	char *p = (char *) page;
+
+	*var = simple_strtoul(p, &p, 10);
+	return count;
+}
+
+#define SHOW_FUNCTION(__FUNC, __VAR, __CONV)				\
+ssize_t __FUNC(struct elevator_queue *e, char *page)		\
+{									\
+	struct elv_fq_data *efqd = &e->efqd;				\
+	unsigned int __data = __VAR;					\
+	if (__CONV)							\
+		__data = jiffies_to_msecs(__data);			\
+	return elv_var_show(__data, (page));				\
+}
+SHOW_FUNCTION(elv_slice_idle_show, efqd->elv_slice_idle, 1);
+EXPORT_SYMBOL(elv_slice_idle_show);
+SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
+EXPORT_SYMBOL(elv_slice_sync_show);
+SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
+EXPORT_SYMBOL(elv_slice_async_show);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
+ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)\
+{									\
+	struct elv_fq_data *efqd = &e->efqd;				\
+	unsigned int __data;						\
+	int ret = elv_var_store(&__data, (page), count);		\
+	if (__data < (MIN))						\
+		__data = (MIN);						\
+	else if (__data > (MAX))					\
+		__data = (MAX);						\
+	if (__CONV)							\
+		*(__PTR) = msecs_to_jiffies(__data);			\
+	else								\
+		*(__PTR) = __data;					\
+	return ret;							\
+}
+STORE_FUNCTION(elv_slice_idle_store, &efqd->elv_slice_idle, 0, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_idle_store);
+STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_sync_store);
+STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_async_store);
+#undef STORE_FUNCTION
+
+void elv_schedule_dispatch(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	if (elv_nr_busy_ioq(q->elevator)) {
+		elv_log(efqd, "schedule dispatch");
+		kblockd_schedule_work(efqd->queue, &efqd->unplug_work);
+	}
+}
+EXPORT_SYMBOL(elv_schedule_dispatch);
+
+static void elv_kick_queue(struct work_struct *work)
+{
+	struct elv_fq_data *efqd =
+		container_of(work, struct elv_fq_data, unplug_work);
+	struct request_queue *q = efqd->queue;
+
+	spin_lock_irq(q->queue_lock);
+	__blk_run_queue(q);
+	spin_unlock_irq(q->queue_lock);
+}
+
+static void elv_shutdown_timer_wq(struct elevator_queue *e)
+{
+	del_timer_sync(&e->efqd.idle_slice_timer);
+	cancel_work_sync(&e->efqd.unplug_work);
+}
+
+static void elv_ioq_set_prio_slice(struct request_queue *q,
+					struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	ioq->slice_end = jiffies + ioq->entity.budget;
+	elv_log_ioq(efqd, ioq, "set_slice=%lu", ioq->entity.budget);
+}
+
+static void elv_ioq_update_io_thinktime(struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = ioq->efqd;
+	unsigned long elapsed = jiffies - ioq->last_end_request;
+	unsigned long ttime = min(elapsed, 2UL * efqd->elv_slice_idle);
+
+	ioq->ttime_samples = (7*ioq->ttime_samples + 256) / 8;
+	ioq->ttime_total = (7*ioq->ttime_total + 256*ttime) / 8;
+	ioq->ttime_mean = (ioq->ttime_total + 128) / ioq->ttime_samples;
+}
+
+/*
+ * Disable idle window if the process thinks too long.
+ * This idle flag can also be updated by io scheduler.
+ */
+static void elv_ioq_update_idle_window(struct elevator_queue *eq,
+				struct io_queue *ioq, struct request *rq)
+{
+	int old_idle, enable_idle;
+	struct elv_fq_data *efqd = ioq->efqd;
+
+	/*
+	 * Don't idle for async or idle io prio class
+	 */
+	if (!elv_ioq_sync(ioq) || elv_ioq_class_idle(ioq))
+		return;
+
+	enable_idle = old_idle = elv_ioq_idle_window(ioq);
+
+	if (!efqd->elv_slice_idle)
+		enable_idle = 0;
+	else if (ioq_sample_valid(ioq->ttime_samples)) {
+		if (ioq->ttime_mean > efqd->elv_slice_idle)
+			enable_idle = 0;
+		else
+			enable_idle = 1;
+	}
+
+	/*
+	 * From think time perspective idle should be enabled. Check with
+	 * io scheduler if it wants to disable idling based on additional
+	 * considrations like seek pattern.
+	 */
+	if (enable_idle) {
+		if (eq->ops->elevator_update_idle_window_fn)
+			enable_idle = eq->ops->elevator_update_idle_window_fn(
+						eq, ioq->sched_queue, rq);
+		if (!enable_idle)
+			elv_log_ioq(efqd, ioq, "iosched disabled idle");
+	}
+
+	if (old_idle != enable_idle) {
+		elv_log_ioq(efqd, ioq, "idle=%d", enable_idle);
+		if (enable_idle)
+			elv_mark_ioq_idle_window(ioq);
+		else
+			elv_clear_ioq_idle_window(ioq);
+	}
+}
+
+struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask)
+{
+	struct io_queue *ioq = NULL;
+
+	ioq = kmem_cache_alloc_node(elv_ioq_pool, gfp_mask, q->node);
+	return ioq;
+}
+EXPORT_SYMBOL(elv_alloc_ioq);
+
+void elv_free_ioq(struct io_queue *ioq)
+{
+	kmem_cache_free(elv_ioq_pool, ioq);
+}
+EXPORT_SYMBOL(elv_free_ioq);
+
+int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
+		struct io_group *iog, void *sched_queue, int ioprio_class,
+		int ioprio, int is_sync)
+{
+	struct elv_fq_data *efqd = &eq->efqd;
+
+	RB_CLEAR_NODE(&ioq->entity.rb_node);
+	atomic_set(&ioq->ref, 0);
+	ioq->efqd = efqd;
+	elv_ioq_set_ioprio_class(ioq, ioprio_class);
+	elv_ioq_set_ioprio(ioq, ioprio);
+	ioq->pid = current->pid;
+	ioq->sched_queue = sched_queue;
+	if (is_sync && !elv_ioq_class_idle(ioq))
+		elv_mark_ioq_idle_window(ioq);
+	bfq_init_entity(&ioq->entity, iog);
+	ioq->entity.budget = elv_prio_to_slice(efqd, ioq);
+	if (is_sync)
+		ioq->last_end_request = jiffies;
+
+	return 0;
+}
+EXPORT_SYMBOL(elv_init_ioq);
+
+void elv_put_ioq(struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = ioq->efqd;
+	struct elevator_queue *e = container_of(efqd, struct elevator_queue,
+						efqd);
+
+	BUG_ON(atomic_read(&ioq->ref) <= 0);
+	if (!atomic_dec_and_test(&ioq->ref))
+		return;
+	BUG_ON(ioq->nr_queued);
+	BUG_ON(ioq->entity.tree != NULL);
+	BUG_ON(elv_ioq_busy(ioq));
+	BUG_ON(efqd->active_queue == ioq);
+
+	/* Can be called by outgoing elevator. Don't use q */
+	BUG_ON(!e->ops->elevator_free_sched_queue_fn);
+
+	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
+	elv_log_ioq(efqd, ioq, "put_queue");
+	elv_free_ioq(ioq);
+}
+EXPORT_SYMBOL(elv_put_ioq);
+
+void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
+{
+	struct io_queue *ioq = *ioq_ptr;
+
+	if (ioq != NULL) {
+		/* Drop the reference taken by the io group */
+		elv_put_ioq(ioq);
+		*ioq_ptr = NULL;
+	}
+}
+
+/*
+ * Normally next io queue to be served is selected from the service tree.
+ * This function allows one to choose a specific io queue to run next
+ * out of order. This is primarily to accomodate the close_cooperator
+ * feature of cfq.
+ *
+ * Currently it is done only for root level as to begin with supporting
+ * close cooperator feature only for root group to make sure default
+ * cfq behavior in flat hierarchy is not changed.
+ */
+static void elv_set_next_ioq(struct request_queue *q, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_entity *entity = &ioq->entity;
+	struct io_sched_data *sd = &efqd->root_group->sched_data;
+	struct io_service_tree *st = io_entity_service_tree(entity);
+
+	BUG_ON(efqd->active_queue != NULL || sd->active_entity != NULL);
+	BUG_ON(!efqd->busy_queues);
+	BUG_ON(sd != entity->sched_data);
+	BUG_ON(!st);
+
+	bfq_update_vtime(st);
+	bfq_active_remove(st, entity);
+	sd->active_entity = entity;
+	entity->service = 0;
+	elv_log_ioq(efqd, ioq, "set_next_ioq");
+}
+
+/* Get next queue for service. */
+static struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_entity *entity = NULL;
+	struct io_queue *ioq = NULL;
+	struct io_sched_data *sd;
+
+	/*
+	 * We should not call lookup when an entity is active, as doing
+	 * lookup can result in an erroneous vtime jump.
+	 */
+	BUG_ON(efqd->active_queue != NULL);
+
+	if (!efqd->busy_queues)
+		return NULL;
+
+	sd = &efqd->root_group->sched_data;
+	entity = bfq_lookup_next_entity(sd, 1);
+
+	BUG_ON(!entity);
+	if (extract)
+		entity->service = 0;
+	ioq = io_entity_to_ioq(entity);
+
+	return ioq;
+}
+
+/*
+ * coop (cooperating queue) tells that io scheduler selected a queue for us
+ * and we did not select the next queue based on fairness.
+ */
+static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
+					int coop)
+{
+	struct request_queue *q = efqd->queue;
+
+	if (ioq) {
+		elv_log_ioq(efqd, ioq, "set_active, busy=%d",
+							efqd->busy_queues);
+		ioq->slice_end = 0;
+
+		elv_clear_ioq_wait_request(ioq);
+		elv_clear_ioq_must_dispatch(ioq);
+		elv_mark_ioq_slice_new(ioq);
+
+		del_timer(&efqd->idle_slice_timer);
+	}
+
+	efqd->active_queue = ioq;
+
+	/* Let iosched know if it wants to take some action */
+	if (ioq) {
+		if (q->elevator->ops->elevator_active_ioq_set_fn)
+			q->elevator->ops->elevator_active_ioq_set_fn(q,
+							ioq->sched_queue, coop);
+	}
+}
+
+/* Get and set a new active queue for service. */
+static struct io_queue *elv_set_active_ioq(struct request_queue *q,
+						struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	int coop = 0;
+
+	if (!ioq)
+		ioq = elv_get_next_ioq(q, 1);
+	else {
+		elv_set_next_ioq(q, ioq);
+		/*
+		 * io scheduler selected the next queue for us. Pass this
+		 * this info back to io scheudler. cfq currently uses it
+		 * to reset coop flag on the queue.
+		 */
+		coop = 1;
+	}
+	__elv_set_active_ioq(efqd, ioq, coop);
+	return ioq;
+}
+
+static void elv_reset_active_ioq(struct elv_fq_data *efqd)
+{
+	struct request_queue *q = efqd->queue;
+	struct io_queue *ioq = elv_active_ioq(efqd->queue->elevator);
+
+	if (q->elevator->ops->elevator_active_ioq_reset_fn)
+		q->elevator->ops->elevator_active_ioq_reset_fn(q,
+							ioq->sched_queue);
+	efqd->active_queue = NULL;
+	del_timer(&efqd->idle_slice_timer);
+}
+
+static void elv_activate_ioq(struct io_queue *ioq, int add_front)
+{
+	bfq_activate_entity(&ioq->entity, add_front);
+}
+
+static void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
+					int requeue)
+{
+	bfq_deactivate_entity(&ioq->entity, requeue);
+}
+
+/* Called when an inactive queue receives a new request. */
+static void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
+{
+	BUG_ON(elv_ioq_busy(ioq));
+	BUG_ON(ioq == efqd->active_queue);
+	elv_log_ioq(efqd, ioq, "add to busy");
+	elv_activate_ioq(ioq, 0);
+	elv_mark_ioq_busy(ioq);
+	efqd->busy_queues++;
+	if (elv_ioq_class_rt(ioq)) {
+		struct io_group *iog = ioq_to_io_group(ioq);
+		iog->busy_rt_queues++;
+	}
+}
+
+static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
+					int requeue)
+{
+	struct elv_fq_data *efqd = &e->efqd;
+
+	BUG_ON(!elv_ioq_busy(ioq));
+	BUG_ON(ioq->nr_queued);
+	elv_log_ioq(efqd, ioq, "del from busy");
+	elv_clear_ioq_busy(ioq);
+	BUG_ON(efqd->busy_queues == 0);
+	efqd->busy_queues--;
+	if (elv_ioq_class_rt(ioq)) {
+		struct io_group *iog = ioq_to_io_group(ioq);
+		iog->busy_rt_queues--;
+	}
+
+	elv_deactivate_ioq(efqd, ioq, requeue);
+}
+
+/*
+ * Do the accounting. Determine how much service (in terms of time slices)
+ * current queue used and adjust the start, finish time of queue and vtime
+ * of the tree accordingly.
+ *
+ * Determining the service used in terms of time is tricky in certain
+ * situations. Especially when underlying device supports command queuing
+ * and requests from multiple queues can be there at same time, then it
+ * is not clear which queue consumed how much of disk time.
+ *
+ * To mitigate this problem, cfq starts the time slice of the queue only
+ * after first request from the queue has completed. This does not work
+ * very well if we expire the queue before we wait for first and more
+ * request to finish from the queue. For seeky queues, we will expire the
+ * queue after dispatching few requests without waiting and start dispatching
+ * from next queue.
+ *
+ * Not sure how to determine the time consumed by queue in such scenarios.
+ * Currently as a crude approximation, we are charging 25% of time slice
+ * for such cases. A better mechanism is needed for accurate accounting.
+ */
+void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_entity *entity = &ioq->entity;
+	long slice_unused = 0, slice_used = 0, slice_overshoot = 0;
+
+	assert_spin_locked(q->queue_lock);
+	elv_log_ioq(efqd, ioq, "slice expired");
+
+	if (elv_ioq_wait_request(ioq))
+		del_timer(&efqd->idle_slice_timer);
+
+	elv_clear_ioq_wait_request(ioq);
+
+	/*
+	 * if ioq->slice_end = 0, that means a queue was expired before first
+	 * reuqest from the queue got completed. Of course we are not planning
+	 * to idle on the queue otherwise we would not have expired it.
+	 *
+	 * Charge for the 25% slice in such cases. This is not the best thing
+	 * to do but at the same time not very sure what's the next best
+	 * thing to do.
+	 *
+	 * This arises from that fact that we don't have the notion of
+	 * one queue being operational at one time. io scheduler can dispatch
+	 * requests from multiple queues in one dispatch round. Ideally for
+	 * more accurate accounting of exact disk time used by disk, one
+	 * should dispatch requests from only one queue and wait for all
+	 * the requests to finish. But this will reduce throughput.
+	 */
+	if (!ioq->slice_end)
+		slice_used = entity->budget/4;
+	else {
+		if (time_after(ioq->slice_end, jiffies)) {
+			slice_unused = ioq->slice_end - jiffies;
+			if (slice_unused == entity->budget) {
+				/*
+				 * queue got expired immediately after
+				 * completing first request. Charge 25% of
+				 * slice.
+				 */
+				slice_used = entity->budget/4;
+			} else
+				slice_used = entity->budget - slice_unused;
+		} else {
+			slice_overshoot = jiffies - ioq->slice_end;
+			slice_used = entity->budget + slice_overshoot;
+		}
+	}
+
+	elv_log_ioq(efqd, ioq, "sl_end=%lx, jiffies=%lx", ioq->slice_end,
+			jiffies);
+	elv_log_ioq(efqd, ioq, "sl_used=%ld, budget=%ld overshoot=%ld",
+				slice_used, entity->budget, slice_overshoot);
+	elv_ioq_served(ioq, slice_used);
+
+	BUG_ON(ioq != efqd->active_queue);
+	elv_reset_active_ioq(efqd);
+
+	if (!ioq->nr_queued)
+		elv_del_ioq_busy(q->elevator, ioq, 1);
+	else
+		elv_activate_ioq(ioq, 0);
+}
+EXPORT_SYMBOL(__elv_ioq_slice_expired);
+
+/*
+ *  Expire the ioq.
+ */
+void elv_ioq_slice_expired(struct request_queue *q)
+{
+	struct io_queue *ioq = elv_active_ioq(q->elevator);
+
+	if (ioq)
+		__elv_ioq_slice_expired(q, ioq);
+}
+
+/*
+ * Check if new_cfqq should preempt the currently active queue. Return 0 for
+ * no or if we aren't sure, a 1 will cause a preemption attempt.
+ */
+static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
+			struct request *rq)
+{
+	struct io_queue *ioq;
+	struct elevator_queue *eq = q->elevator;
+	struct io_entity *entity, *new_entity;
+
+	ioq = elv_active_ioq(eq);
+
+	if (!ioq)
+		return 0;
+
+	entity = &ioq->entity;
+	new_entity = &new_ioq->entity;
+
+	/*
+	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
+	 */
+
+	if (new_entity->ioprio_class == IOPRIO_CLASS_RT
+	    && entity->ioprio_class != IOPRIO_CLASS_RT)
+		return 1;
+	/*
+	 * Allow an BE request to pre-empt an ongoing IDLE clas timeslice.
+	 */
+
+	if (new_entity->ioprio_class == IOPRIO_CLASS_BE
+	    && entity->ioprio_class == IOPRIO_CLASS_IDLE)
+		return 1;
+
+	/*
+	 * Check with io scheduler if it has additional criterion based on
+	 * which it wants to preempt existing queue.
+	 */
+	if (eq->ops->elevator_should_preempt_fn)
+		return eq->ops->elevator_should_preempt_fn(q,
+						ioq_sched_queue(new_ioq), rq);
+
+	return 0;
+}
+
+static void elv_preempt_queue(struct request_queue *q, struct io_queue *ioq)
+{
+	elv_log_ioq(&q->elevator->efqd, ioq, "preempt");
+	elv_ioq_slice_expired(q);
+
+	/*
+	 * Put the new queue at the front of the of the current list,
+	 * so we know that it will be selected next.
+	 */
+
+	elv_activate_ioq(ioq, 1);
+	ioq->slice_end = 0;
+	elv_mark_ioq_slice_new(ioq);
+}
+
+void elv_ioq_request_add(struct request_queue *q, struct request *rq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_queue *ioq = rq->ioq;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	BUG_ON(!efqd);
+	BUG_ON(!ioq);
+	efqd->rq_queued++;
+	ioq->nr_queued++;
+
+	if (!elv_ioq_busy(ioq))
+		elv_add_ioq_busy(efqd, ioq);
+
+	elv_ioq_update_io_thinktime(ioq);
+	elv_ioq_update_idle_window(q->elevator, ioq, rq);
+
+	if (ioq == elv_active_ioq(q->elevator)) {
+		/*
+		 * Remember that we saw a request from this process, but
+		 * don't start queuing just yet. Otherwise we risk seeing lots
+		 * of tiny requests, because we disrupt the normal plugging
+		 * and merging. If the request is already larger than a single
+		 * page, let it rip immediately. For that case we assume that
+		 * merging is already done. Ditto for a busy system that
+		 * has other work pending, don't risk delaying until the
+		 * idle timer unplug to continue working.
+		 */
+		if (elv_ioq_wait_request(ioq)) {
+			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
+			    efqd->busy_queues > 1) {
+				del_timer(&efqd->idle_slice_timer);
+				__blk_run_queue(q);
+			}
+			elv_mark_ioq_must_dispatch(ioq);
+		}
+	} else if (elv_should_preempt(q, ioq, rq)) {
+		/*
+		 * not the active queue - expire current slice if it is
+		 * idle and has expired it's mean thinktime or this new queue
+		 * has some old slice time left and is of higher priority or
+		 * this new queue is RT and the current one is BE
+		 */
+		elv_preempt_queue(q, ioq);
+		__blk_run_queue(q);
+	}
+}
+
+static void elv_idle_slice_timer(unsigned long data)
+{
+	struct elv_fq_data *efqd = (struct elv_fq_data *)data;
+	struct io_queue *ioq;
+	unsigned long flags;
+	struct request_queue *q = efqd->queue;
+
+	elv_log(efqd, "idle timer fired");
+
+	spin_lock_irqsave(q->queue_lock, flags);
+
+	ioq = efqd->active_queue;
+
+	if (ioq) {
+
+		/*
+		 * We saw a request before the queue expired, let it through
+		 */
+		if (elv_ioq_must_dispatch(ioq))
+			goto out_kick;
+
+		/*
+		 * expired
+		 */
+		if (elv_ioq_slice_used(ioq))
+			goto expire;
+
+		/*
+		 * only expire and reinvoke request handler, if there are
+		 * other queues with pending requests
+		 */
+		if (!elv_nr_busy_ioq(q->elevator))
+			goto out_cont;
+
+		/*
+		 * not expired and it has a request pending, let it dispatch
+		 */
+		if (ioq->nr_queued)
+			goto out_kick;
+	}
+expire:
+	elv_ioq_slice_expired(q);
+out_kick:
+	elv_schedule_dispatch(q);
+out_cont:
+	spin_unlock_irqrestore(q->queue_lock, flags);
+}
+
+static void elv_ioq_arm_slice_timer(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_queue *ioq = elv_active_ioq(q->elevator);
+	unsigned long sl;
+
+	BUG_ON(!ioq);
+
+	/*
+	 * SSD device without seek penalty, disable idling. But only do so
+	 * for devices that support queuing, otherwise we still have a problem
+	 * with sync vs async workloads.
+	 */
+	if (blk_queue_nonrot(q) && efqd->hw_tag)
+		return;
+
+	/*
+	 * still requests with the driver, don't idle
+	 */
+	if (efqd->rq_in_driver)
+		return;
+
+	/*
+	 * idle is disabled, either manually or by past process history
+	 */
+	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
+		return;
+
+	/*
+	 * may be iosched got its own idling logic. In that case io
+	 * schduler will take care of arming the timer, if need be.
+	 */
+	if (q->elevator->ops->elevator_arm_slice_timer_fn) {
+		q->elevator->ops->elevator_arm_slice_timer_fn(q,
+						ioq->sched_queue);
+	} else {
+		elv_mark_ioq_wait_request(ioq);
+		sl = efqd->elv_slice_idle;
+		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
+		elv_log_ioq(efqd, ioq, "arm idle: %lu", sl);
+	}
+}
+
+/*
+ * If io scheduler has functionality of keeping track of close cooperator, check
+ * with it if it has got a closely co-operating queue.
+ */
+static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
+					struct io_queue *ioq, int probe)
+{
+	struct elevator_queue *e = q->elevator;
+	struct io_queue *new_ioq = NULL;
+
+	/*
+	 * Currently this feature is supported only for flat hierarchy or
+	 * root group queues so that default cfq behavior is not changed.
+	 */
+	if (!is_root_group_ioq(q, ioq))
+		return NULL;
+
+	if (q->elevator->ops->elevator_close_cooperator_fn)
+		new_ioq = e->ops->elevator_close_cooperator_fn(q,
+						ioq->sched_queue, probe);
+
+	/* Only select co-operating queue if it belongs to root group */
+	if (new_ioq && !is_root_group_ioq(q, new_ioq))
+		return NULL;
+
+	return new_ioq;
+}
+
+/* Common layer function to select the next queue to dispatch from */
+void *elv_fq_select_ioq(struct request_queue *q, int force)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
+	struct io_group *iog;
+
+	if (!elv_nr_busy_ioq(q->elevator))
+		return NULL;
+
+	if (ioq == NULL)
+		goto new_queue;
+
+	/*
+	 * Force dispatch. Continue to dispatch from current queue as long
+	 * as it has requests.
+	 */
+	if (unlikely(force)) {
+		if (ioq->nr_queued)
+			goto keep_queue;
+		else
+			goto expire;
+	}
+
+	/*
+	 * The active queue has run out of time, expire it and select new.
+	 */
+	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq))
+		goto expire;
+
+	/*
+	 * If we have a RT cfqq waiting, then we pre-empt the current non-rt
+	 * cfqq.
+	 */
+	iog = ioq_to_io_group(ioq);
+
+	if (!elv_ioq_class_rt(ioq) && iog->busy_rt_queues) {
+		/*
+		 * We simulate this as cfqq timed out so that it gets to bank
+		 * the remaining of its time slice.
+		 */
+		elv_log_ioq(efqd, ioq, "preempt");
+		goto expire;
+	}
+
+	/*
+	 * The active queue has requests and isn't expired, allow it to
+	 * dispatch.
+	 */
+
+	if (ioq->nr_queued)
+		goto keep_queue;
+
+	/*
+	 * If another queue has a request waiting within our mean seek
+	 * distance, let it run.  The expire code will check for close
+	 * cooperators and put the close queue at the front of the service
+	 * tree.
+	 */
+	new_ioq = elv_close_cooperator(q, ioq, 0);
+	if (new_ioq)
+		goto expire;
+
+	/*
+	 * No requests pending. If the active queue still has requests in
+	 * flight or is idling for a new request, allow either of these
+	 * conditions to happen (or time out) before selecting a new queue.
+	 */
+
+	if (timer_pending(&efqd->idle_slice_timer) ||
+	    (elv_ioq_nr_dispatched(ioq) && elv_ioq_idle_window(ioq))) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
+expire:
+	elv_ioq_slice_expired(q);
+new_queue:
+	ioq = elv_set_active_ioq(q, new_ioq);
+keep_queue:
+	return ioq;
+}
+
+/* A request got removed from io_queue. Do the accounting */
+void elv_ioq_request_removed(struct elevator_queue *e, struct request *rq)
+{
+	struct io_queue *ioq;
+	struct elv_fq_data *efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return;
+
+	ioq = rq->ioq;
+	BUG_ON(!ioq);
+	ioq->nr_queued--;
+
+	efqd = ioq->efqd;
+	BUG_ON(!efqd);
+	efqd->rq_queued--;
+
+	if (elv_ioq_busy(ioq) && (elv_active_ioq(e) != ioq) && !ioq->nr_queued)
+		elv_del_ioq_busy(e, ioq, 1);
+}
+
+/* A request got dispatched. Do the accounting. */
+void elv_fq_dispatched_request(struct elevator_queue *e, struct request *rq)
+{
+	struct io_queue *ioq = rq->ioq;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return;
+
+	BUG_ON(!ioq);
+	elv_ioq_request_dispatched(ioq);
+	elv_ioq_request_removed(e, rq);
+	elv_clear_ioq_must_dispatch(ioq);
+}
+
+void elv_fq_activate_rq(struct request_queue *q, struct request *rq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	efqd->rq_in_driver++;
+	elv_log_ioq(efqd, rq->ioq, "activate rq, drv=%d",
+						efqd->rq_in_driver);
+}
+
+void elv_fq_deactivate_rq(struct request_queue *q, struct request *rq)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	WARN_ON(!efqd->rq_in_driver);
+	efqd->rq_in_driver--;
+	elv_log_ioq(efqd, rq->ioq, "deactivate rq, drv=%d",
+						efqd->rq_in_driver);
+}
+
+/*
+ * Update hw_tag based on peak queue depth over 50 samples under
+ * sufficient load.
+ */
+static void elv_update_hw_tag(struct elv_fq_data *efqd)
+{
+	if (efqd->rq_in_driver > efqd->rq_in_driver_peak)
+		efqd->rq_in_driver_peak = efqd->rq_in_driver;
+
+	if (efqd->rq_queued <= ELV_HW_QUEUE_MIN &&
+	    efqd->rq_in_driver <= ELV_HW_QUEUE_MIN)
+		return;
+
+	if (efqd->hw_tag_samples++ < 50)
+		return;
+
+	if (efqd->rq_in_driver_peak >= ELV_HW_QUEUE_MIN)
+		efqd->hw_tag = 1;
+	else
+		efqd->hw_tag = 0;
+
+	efqd->hw_tag_samples = 0;
+	efqd->rq_in_driver_peak = 0;
+}
+
+/* A request got completed from io_queue. Do the accounting. */
+void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
+{
+	const int sync = rq_is_sync(rq);
+	struct io_queue *ioq;
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	ioq = rq->ioq;
+
+	elv_log_ioq(efqd, ioq, "complete");
+
+	elv_update_hw_tag(efqd);
+
+	WARN_ON(!efqd->rq_in_driver);
+	WARN_ON(!ioq->dispatched);
+	efqd->rq_in_driver--;
+	ioq->dispatched--;
+
+	if (sync)
+		ioq->last_end_request = jiffies;
+
+	/*
+	 * If this is the active queue, check if it needs to be expired,
+	 * or if we want to idle in case it has no pending requests.
+	 */
+
+	if (elv_active_ioq(q->elevator) == ioq) {
+		if (elv_ioq_slice_new(ioq)) {
+			elv_ioq_set_prio_slice(q, ioq);
+			elv_clear_ioq_slice_new(ioq);
+		}
+		/*
+		 * If there are no requests waiting in this queue, and
+		 * there are other queues ready to issue requests, AND
+		 * those other queues are issuing requests within our
+		 * mean seek distance, give them a chance to run instead
+		 * of idling.
+		 */
+		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+			elv_ioq_slice_expired(q);
+		else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq, 1)
+			 && sync && !rq_noidle(rq))
+			elv_ioq_arm_slice_timer(q);
+	}
+
+	if (!efqd->rq_in_driver)
+		elv_schedule_dispatch(q);
+}
+
+struct io_group *io_get_io_group(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	/* In flat mode, there is only root group */
+	return efqd->root_group;
+}
+EXPORT_SYMBOL(io_get_io_group);
+
+void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
+					int ioprio)
+{
+	struct io_queue *ioq = NULL;
+
+	switch (ioprio_class) {
+	case IOPRIO_CLASS_RT:
+		ioq = iog->async_queue[0][ioprio];
+		break;
+	case IOPRIO_CLASS_BE:
+		ioq = iog->async_queue[1][ioprio];
+		break;
+	case IOPRIO_CLASS_IDLE:
+		ioq = iog->async_idle_queue;
+		break;
+	default:
+		BUG();
+	}
+
+	if (ioq)
+		return ioq->sched_queue;
+	return NULL;
+}
+EXPORT_SYMBOL(io_group_async_queue_prio);
+
+void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
+					int ioprio, struct io_queue *ioq)
+{
+	switch (ioprio_class) {
+	case IOPRIO_CLASS_RT:
+		iog->async_queue[0][ioprio] = ioq;
+		break;
+	case IOPRIO_CLASS_BE:
+		iog->async_queue[1][ioprio] = ioq;
+		break;
+	case IOPRIO_CLASS_IDLE:
+		iog->async_idle_queue = ioq;
+		break;
+	default:
+		BUG();
+	}
+
+	/*
+	 * Take the group reference and pin the queue. Group exit will
+	 * clean it up
+	 */
+	elv_get_ioq(ioq);
+}
+EXPORT_SYMBOL(io_group_set_async_queue);
+
+/*
+ * Release all the io group references to its async queues.
+ */
+static void
+io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
+{
+	int i, j;
+
+	for (i = 0; i < 2; i++)
+		for (j = 0; j < IOPRIO_BE_NR; j++)
+			elv_release_ioq(e, &iog->async_queue[i][j]);
+
+	/* Free up async idle queue */
+	elv_release_ioq(e, &iog->async_idle_queue);
+}
+
+static struct io_group *io_alloc_root_group(struct request_queue *q,
+					struct elevator_queue *e, void *key)
+{
+	struct io_group *iog;
+	int i;
+
+	iog = kmalloc_node(sizeof(*iog), GFP_KERNEL | __GFP_ZERO, q->node);
+	if (iog == NULL)
+		return NULL;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
+		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
+
+	return iog;
+}
+
+static void io_free_root_group(struct elevator_queue *e)
+{
+	struct io_group *iog = e->efqd.root_group;
+	struct io_service_tree *st;
+	int i;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		io_flush_idle_tree(st);
+	}
+
+	io_put_io_group_queues(e, iog);
+	kfree(iog);
+}
+
+static void elv_slab_kill(void)
+{
+	/*
+	 * Caller already ensured that pending RCU callbacks are completed,
+	 * so we should have no busy allocations at this point.
+	 */
+	if (elv_ioq_pool)
+		kmem_cache_destroy(elv_ioq_pool);
+}
+
+static int __init elv_slab_setup(void)
+{
+	elv_ioq_pool = KMEM_CACHE(io_queue, 0);
+	if (!elv_ioq_pool)
+		goto fail;
+
+	return 0;
+fail:
+	elv_slab_kill();
+	return -ENOMEM;
+}
+
+/* Initialize fair queueing data associated with elevator */
+int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
+{
+	struct io_group *iog;
+	struct elv_fq_data *efqd = &e->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return 0;
+
+	iog = io_alloc_root_group(q, e, efqd);
+	if (iog == NULL)
+		return 1;
+
+	efqd->root_group = iog;
+	efqd->queue = q;
+
+	init_timer(&efqd->idle_slice_timer);
+	efqd->idle_slice_timer.function = elv_idle_slice_timer;
+	efqd->idle_slice_timer.data = (unsigned long) efqd;
+
+	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
+
+	efqd->elv_slice[0] = elv_slice_async;
+	efqd->elv_slice[1] = elv_slice_sync;
+	efqd->elv_slice_idle = elv_slice_idle;
+	efqd->hw_tag = 1;
+
+	return 0;
+}
+
+/*
+ * elv_exit_fq_data is called before we call elevator_exit_fn. Before
+ * we ask elevator to cleanup its queues, we do the cleanup here so
+ * that all the group and idle tree references to ioq are dropped. Later
+ * during elevator cleanup, ioc reference will be dropped which will lead
+ * to removal of ioscheduler queue as well as associated ioq object.
+ */
+void elv_exit_fq_data(struct elevator_queue *e)
+{
+	struct elv_fq_data *efqd = &e->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return;
+
+	elv_shutdown_timer_wq(e);
+
+	BUG_ON(timer_pending(&efqd->idle_slice_timer));
+	io_free_root_group(e);
+}
+
+/*
+ * This is called after the io scheduler has cleaned up its data structres.
+ * I don't think that this function is required. Right now just keeping it
+ * because cfq cleans up timer and work queue again after freeing up
+ * io contexts. To me io scheduler has already been drained out, and all
+ * the active queue have already been expired so time and work queue should
+ * not been activated during cleanup process.
+ *
+ * Keeping it here for the time being. Will get rid of it later.
+ */
+void elv_exit_fq_data_post(struct elevator_queue *e)
+{
+	struct elv_fq_data *efqd = &e->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return;
+
+	elv_shutdown_timer_wq(e);
+	BUG_ON(timer_pending(&efqd->idle_slice_timer));
+}
+
+
+static int __init elv_fq_init(void)
+{
+	if (elv_slab_setup())
+		return -ENOMEM;
+
+	/* could be 0 on HZ < 1000 setups */
+
+	if (!elv_slice_async)
+		elv_slice_async = 1;
+
+	if (!elv_slice_idle)
+		elv_slice_idle = 1;
+
+	return 0;
+}
+
+module_init(elv_fq_init);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 4554d7f..a7cbc0f 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -22,6 +22,10 @@
 struct io_entity;
 struct io_queue;
 
+#ifdef CONFIG_ELV_FAIR_QUEUING
+#define ELV_ATTR(name) \
+	__ATTR(name, S_IRUGO|S_IWUSR, elv_##name##_show, elv_##name##_store)
+
 /**
  * struct io_service_tree - per ioprio_class service tree.
  * @active: tree for active entities (i.e., those backlogged).
@@ -149,15 +153,125 @@ struct io_entity {
 struct io_queue {
 	struct io_entity entity;
 	atomic_t ref;
+	unsigned int flags;
 
 	/* Pointer to generic elevator fair queuing data structure */
 	struct elv_fq_data *efqd;
+	pid_t pid;
+
+	/* Number of requests queued on this io queue */
+	unsigned long nr_queued;
+
+	/* Requests dispatched from this queue */
+	int dispatched;
+
+	/* Keep a track of think time of processes in this queue */
+	unsigned long last_end_request;
+	unsigned long ttime_total;
+	unsigned long ttime_samples;
+	unsigned long ttime_mean;
+
+	unsigned long slice_end;
+
+	/* Pointer to io scheduler's queue */
+	void *sched_queue;
 };
 
 struct io_group {
 	struct io_sched_data sched_data;
+	/*
+	 * async queue for each priority case for RT and BE class.
+	 * Used only for cfq.
+	 */
+
+	struct io_queue *async_queue[2][IOPRIO_BE_NR];
+	struct io_queue *async_idle_queue;
+
+	/*
+	 * Used to track any pending rt requests so we can pre-empt current
+	 * non-RT cfqq in service when this value is non-zero.
+	 */
+	unsigned int busy_rt_queues;
+};
+
+struct elv_fq_data {
+	struct io_group *root_group;
+
+	struct request_queue *queue;
+	unsigned int busy_queues;
+
+	/* Number of requests queued */
+	int rq_queued;
+
+	/* Pointer to the ioscheduler queue being served */
+	void *active_queue;
+
+	/*
+	 * queue-depth detection
+	 */
+	int rq_in_driver;
+	int hw_tag;
+	int hw_tag_samples;
+	int rq_in_driver_peak;
+
+	/*
+	 * elevator fair queuing layer has the capability to provide idling
+	 * for ensuring fairness for processes doing dependent reads.
+	 * This might be needed to ensure fairness among two processes doing
+	 * synchronous reads in two different cgroups. noop and deadline don't
+	 * have any notion of anticipation/idling. As of now, these are the
+	 * users of this functionality.
+	 */
+	unsigned int elv_slice_idle;
+	struct timer_list idle_slice_timer;
+	struct work_struct unplug_work;
+
+	/* Base slice length for sync and async queues */
+	unsigned int elv_slice[2];
 };
 
+/* Logging facilities. */
+#define elv_log_ioq(efqd, ioq, fmt, args...) \
+	blk_add_trace_msg((efqd)->queue, "elv%d%c " fmt, (ioq)->pid,	\
+				elv_ioq_sync(ioq) ? 'S' : 'A', ##args)
+
+#define elv_log(efqd, fmt, args...) \
+	blk_add_trace_msg((efqd)->queue, "elv " fmt, ##args)
+
+#define ioq_sample_valid(samples)   ((samples) > 80)
+
+/* Some shared queue flag manipulation functions among elevators */
+
+enum elv_queue_state_flags {
+	ELV_QUEUE_FLAG_busy = 0,          /* has requests or is under service */
+	ELV_QUEUE_FLAG_sync,              /* synchronous queue */
+	ELV_QUEUE_FLAG_idle_window,	  /* elevator slice idling enabled */
+	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
+	ELV_QUEUE_FLAG_must_dispatch,	  /* must be allowed a dispatch */
+	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
+};
+
+#define ELV_IO_QUEUE_FLAG_FNS(name)					\
+static inline void elv_mark_ioq_##name(struct io_queue *ioq)		\
+{                                                                       \
+	(ioq)->flags |= (1 << ELV_QUEUE_FLAG_##name);			\
+}                                                                       \
+static inline void elv_clear_ioq_##name(struct io_queue *ioq)		\
+{                                                                       \
+	(ioq)->flags &= ~(1 << ELV_QUEUE_FLAG_##name);			\
+}                                                                       \
+static inline int elv_ioq_##name(struct io_queue *ioq)         		\
+{                                                                       \
+	return ((ioq)->flags & (1 << ELV_QUEUE_FLAG_##name)) != 0;	\
+}
+
+ELV_IO_QUEUE_FLAG_FNS(busy)
+ELV_IO_QUEUE_FLAG_FNS(sync)
+ELV_IO_QUEUE_FLAG_FNS(wait_request)
+ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
+ELV_IO_QUEUE_FLAG_FNS(idle_window)
+ELV_IO_QUEUE_FLAG_FNS(slice_new)
+
 static inline struct io_service_tree *
 io_entity_service_tree(struct io_entity *entity)
 {
@@ -169,4 +283,194 @@ io_entity_service_tree(struct io_entity *entity)
 
 	return sched_data->service_tree + idx;
 }
+
+/* A request got dispatched from the io_queue. Do the accounting. */
+static inline void elv_ioq_request_dispatched(struct io_queue *ioq)
+{
+	ioq->dispatched++;
+}
+
+static inline int elv_ioq_slice_used(struct io_queue *ioq)
+{
+	if (elv_ioq_slice_new(ioq))
+		return 0;
+	if (time_before(jiffies, ioq->slice_end))
+		return 0;
+
+	return 1;
+}
+
+/* How many request are currently dispatched from the queue */
+static inline int elv_ioq_nr_dispatched(struct io_queue *ioq)
+{
+	return ioq->dispatched;
+}
+
+/* How many request are currently queued in the queue */
+static inline int elv_ioq_nr_queued(struct io_queue *ioq)
+{
+	return ioq->nr_queued;
+}
+
+static inline void elv_get_ioq(struct io_queue *ioq)
+{
+	atomic_inc(&ioq->ref);
+}
+
+static inline int elv_ioq_class_idle(struct io_queue *ioq)
+{
+	return ioq->entity.ioprio_class == IOPRIO_CLASS_IDLE;
+}
+
+static inline int elv_ioq_class_rt(struct io_queue *ioq)
+{
+	return ioq->entity.ioprio_class == IOPRIO_CLASS_RT;
+}
+
+static inline int elv_ioq_ioprio_class(struct io_queue *ioq)
+{
+	return ioq->entity.new_ioprio_class;
+}
+
+static inline int elv_ioq_ioprio(struct io_queue *ioq)
+{
+	return ioq->entity.new_ioprio;
+}
+
+static inline void elv_ioq_set_ioprio_class(struct io_queue *ioq,
+						int ioprio_class)
+{
+	ioq->entity.new_ioprio_class = ioprio_class;
+	ioq->entity.ioprio_changed = 1;
+}
+
+/**
+ * bfq_ioprio_to_weight - calc a weight from an ioprio.
+ * @ioprio: the ioprio value to convert.
+ */
+static inline unsigned int bfq_ioprio_to_weight(int ioprio)
+{
+	WARN_ON(ioprio < 0 || ioprio >= IOPRIO_BE_NR);
+	return IOPRIO_BE_NR - ioprio;
+}
+
+static inline void elv_ioq_set_ioprio(struct io_queue *ioq, int ioprio)
+{
+	ioq->entity.new_ioprio = ioprio;
+	ioq->entity.new_weight = bfq_ioprio_to_weight(ioprio);
+	ioq->entity.ioprio_changed = 1;
+}
+
+static inline void *ioq_sched_queue(struct io_queue *ioq)
+{
+	if (ioq)
+		return ioq->sched_queue;
+	return NULL;
+}
+
+static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
+{
+	return container_of(ioq->entity.sched_data, struct io_group,
+						sched_data);
+}
+
+extern ssize_t elv_slice_idle_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_slice_idle_store(struct elevator_queue *q, const char *name,
+						size_t count);
+extern ssize_t elv_slice_sync_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
+						size_t count);
+extern ssize_t elv_slice_async_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_slice_async_store(struct elevator_queue *q, const char *name,
+						size_t count);
+
+/* Functions used by elevator.c */
+extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
+extern void elv_exit_fq_data(struct elevator_queue *e);
+extern void elv_exit_fq_data_post(struct elevator_queue *e);
+
+extern void elv_ioq_request_add(struct request_queue *q, struct request *rq);
+extern void elv_ioq_request_removed(struct elevator_queue *e,
+					struct request *rq);
+extern void elv_fq_dispatched_request(struct elevator_queue *e,
+					struct request *rq);
+
+extern void elv_fq_activate_rq(struct request_queue *q, struct request *rq);
+extern void elv_fq_deactivate_rq(struct request_queue *q, struct request *rq);
+
+extern void elv_ioq_completed_request(struct request_queue *q,
+				struct request *rq);
+
+extern void *elv_fq_select_ioq(struct request_queue *q, int force);
+
+/* Functions used by io schedulers */
+extern void elv_put_ioq(struct io_queue *ioq);
+extern void __elv_ioq_slice_expired(struct request_queue *q,
+					struct io_queue *ioq);
+extern int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
+		struct io_group *iog, void *sched_queue, int ioprio_class,
+		int ioprio, int is_sync);
+extern void elv_schedule_dispatch(struct request_queue *q);
+extern int elv_hw_tag(struct elevator_queue *e);
+extern void *elv_active_sched_queue(struct elevator_queue *e);
+extern int elv_mod_idle_slice_timer(struct elevator_queue *eq,
+					unsigned long expires);
+extern int elv_del_idle_slice_timer(struct elevator_queue *eq);
+extern unsigned int elv_get_slice_idle(struct elevator_queue *eq);
+extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
+					int ioprio);
+extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
+					int ioprio, struct io_queue *ioq);
+extern struct io_group *io_get_io_group(struct request_queue *q);
+extern int elv_nr_busy_ioq(struct elevator_queue *e);
+extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
+extern void elv_free_ioq(struct io_queue *ioq);
+
+#else /* CONFIG_ELV_FAIR_QUEUING */
+
+static inline int elv_init_fq_data(struct request_queue *q,
+					struct elevator_queue *e)
+{
+	return 0;
+}
+
+static inline void elv_exit_fq_data(struct elevator_queue *e) {}
+static inline void elv_exit_fq_data_post(struct elevator_queue *e) {}
+
+static inline void elv_fq_activate_rq(struct request_queue *q,
+					struct request *rq)
+{
+}
+
+static inline void elv_fq_deactivate_rq(struct request_queue *q,
+					struct request *rq)
+{
+}
+
+static inline void elv_fq_dispatched_request(struct elevator_queue *e,
+						struct request *rq)
+{
+}
+
+static inline void elv_ioq_request_removed(struct elevator_queue *e,
+						struct request *rq)
+{
+}
+
+static inline void elv_ioq_request_add(struct request_queue *q,
+					struct request *rq)
+{
+}
+
+static inline void elv_ioq_completed_request(struct request_queue *q,
+						struct request *rq)
+{
+}
+
+static inline void *ioq_sched_queue(struct io_queue *ioq) { return NULL; }
+static inline void *elv_fq_select_ioq(struct request_queue *q, int force)
+{
+	return NULL;
+}
+#endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _BFQ_SCHED_H */
diff --git a/block/elevator.c b/block/elevator.c
index ca86192..357f529 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -226,6 +226,9 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
 	for (i = 0; i < ELV_HASH_ENTRIES; i++)
 		INIT_HLIST_HEAD(&eq->hash[i]);
 
+	if (elv_init_fq_data(q, eq))
+		goto err;
+
 	return eq;
 err:
 	kfree(eq);
@@ -296,9 +299,11 @@ EXPORT_SYMBOL(elevator_init);
 void elevator_exit(struct elevator_queue *e)
 {
 	mutex_lock(&e->sysfs_lock);
+	elv_exit_fq_data(e);
 	if (e->ops->elevator_exit_fn)
 		e->ops->elevator_exit_fn(e);
 	e->ops = NULL;
+	elv_exit_fq_data_post(e);
 	mutex_unlock(&e->sysfs_lock);
 
 	kobject_put(&e->kobj);
@@ -425,6 +430,7 @@ void elv_dispatch_sort(struct request_queue *q, struct request *rq)
 	elv_rqhash_del(q, rq);
 
 	q->nr_sorted--;
+	elv_fq_dispatched_request(q->elevator, rq);
 
 	boundary = q->end_sector;
 	stop_flags = REQ_SOFTBARRIER | REQ_HARDBARRIER | REQ_STARTED;
@@ -465,6 +471,7 @@ void elv_dispatch_add_tail(struct request_queue *q, struct request *rq)
 	elv_rqhash_del(q, rq);
 
 	q->nr_sorted--;
+	elv_fq_dispatched_request(q->elevator, rq);
 
 	q->end_sector = rq_end_sector(rq);
 	q->boundary_rq = rq;
@@ -532,6 +539,7 @@ void elv_merge_requests(struct request_queue *q, struct request *rq,
 	elv_rqhash_del(q, next);
 
 	q->nr_sorted--;
+	elv_ioq_request_removed(e, next);
 	q->last_merge = rq;
 }
 
@@ -638,12 +646,8 @@ void elv_insert(struct request_queue *q, struct request *rq, int where)
 				q->last_merge = rq;
 		}
 
-		/*
-		 * Some ioscheds (cfq) run q->request_fn directly, so
-		 * rq cannot be accessed after calling
-		 * elevator_add_req_fn.
-		 */
 		q->elevator->ops->elevator_add_req_fn(q, rq);
+		elv_ioq_request_add(q, rq);
 		break;
 
 	case ELEVATOR_INSERT_REQUEUE:
@@ -742,13 +746,12 @@ EXPORT_SYMBOL(elv_add_request);
 
 int elv_queue_empty(struct request_queue *q)
 {
-	struct elevator_queue *e = q->elevator;
-
 	if (!list_empty(&q->queue_head))
 		return 0;
 
-	if (e->ops->elevator_queue_empty_fn)
-		return e->ops->elevator_queue_empty_fn(q);
+	/* Hopefully nr_sorted works and no need to call queue_empty_fn */
+	if (q->nr_sorted)
+		return 0;
 
 	return 1;
 }
@@ -828,8 +831,11 @@ void elv_completed_request(struct request_queue *q, struct request *rq)
 	 */
 	if (blk_account_rq(rq)) {
 		q->in_flight[rq_is_sync(rq)]--;
-		if (blk_sorted_rq(rq) && e->ops->elevator_completed_req_fn)
-			e->ops->elevator_completed_req_fn(q, rq);
+		if (blk_sorted_rq(rq)) {
+			if (e->ops->elevator_completed_req_fn)
+				e->ops->elevator_completed_req_fn(q, rq);
+			elv_ioq_completed_request(q, rq);
+		}
 	}
 
 	/*
@@ -1125,3 +1131,17 @@ struct request *elv_rb_latter_request(struct request_queue *q,
 	return NULL;
 }
 EXPORT_SYMBOL(elv_rb_latter_request);
+
+/* Get the io scheduler queue pointer. For cfq, it is stored in rq->ioq*/
+void *elv_get_sched_queue(struct request_queue *q, struct request *rq)
+{
+	return ioq_sched_queue(req_ioq(rq));
+}
+EXPORT_SYMBOL(elv_get_sched_queue);
+
+/* Select an ioscheduler queue to dispatch request from. */
+void *elv_select_sched_queue(struct request_queue *q, int force)
+{
+	return ioq_sched_queue(elv_fq_select_ioq(q, force));
+}
+EXPORT_SYMBOL(elv_select_sched_queue);
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 8963d91..551e17d 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -234,6 +234,11 @@ struct request {
 
 	/* for bidi */
 	struct request *next_rq;
+
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	/* io queue request belongs to */
+	struct io_queue *ioq;
+#endif
 };
 
 static inline unsigned short req_get_ioprio(struct request *req)
@@ -241,6 +246,15 @@ static inline unsigned short req_get_ioprio(struct request *req)
 	return req->ioprio;
 }
 
+static inline struct io_queue *req_ioq(struct request *req)
+{
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	return req->ioq;
+#else
+	return NULL;
+#endif
+}
+
 /*
  * State information carried for REQ_TYPE_PM_SUSPEND and REQ_TYPE_PM_RESUME
  * requests. Some step values could eventually be made generic.
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 1cb3372..81f1ed8 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -2,6 +2,7 @@
 #define _LINUX_ELEVATOR_H
 
 #include <linux/percpu.h>
+#include "../../block/elevator-fq.h"
 
 #ifdef CONFIG_BLOCK
 
@@ -29,6 +30,18 @@ typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct reques
 
 typedef void *(elevator_init_fn) (struct request_queue *);
 typedef void (elevator_exit_fn) (struct elevator_queue *);
+#ifdef CONFIG_ELV_FAIR_QUEUING
+typedef void (elevator_free_sched_queue_fn) (struct elevator_queue*, void *);
+typedef void (elevator_active_ioq_set_fn) (struct request_queue*, void *, int);
+typedef void (elevator_active_ioq_reset_fn) (struct request_queue *, void*);
+typedef void (elevator_arm_slice_timer_fn) (struct request_queue*, void*);
+typedef int (elevator_should_preempt_fn) (struct request_queue*, void*,
+						struct request*);
+typedef int (elevator_update_idle_window_fn) (struct elevator_queue*, void*,
+						struct request*);
+typedef struct io_queue* (elevator_close_cooperator_fn) (struct request_queue*,
+						void*, int probe);
+#endif
 
 struct elevator_ops
 {
@@ -56,6 +69,17 @@ struct elevator_ops
 	elevator_init_fn *elevator_init_fn;
 	elevator_exit_fn *elevator_exit_fn;
 	void (*trim)(struct io_context *);
+
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	elevator_free_sched_queue_fn *elevator_free_sched_queue_fn;
+	elevator_active_ioq_set_fn *elevator_active_ioq_set_fn;
+	elevator_active_ioq_reset_fn *elevator_active_ioq_reset_fn;
+
+	elevator_arm_slice_timer_fn *elevator_arm_slice_timer_fn;
+	elevator_should_preempt_fn *elevator_should_preempt_fn;
+	elevator_update_idle_window_fn *elevator_update_idle_window_fn;
+	elevator_close_cooperator_fn *elevator_close_cooperator_fn;
+#endif
 };
 
 #define ELV_NAME_MAX	(16)
@@ -76,6 +100,9 @@ struct elevator_type
 	struct elv_fs_entry *elevator_attrs;
 	char elevator_name[ELV_NAME_MAX];
 	struct module *elevator_owner;
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	int elevator_features;
+#endif
 };
 
 /*
@@ -89,6 +116,10 @@ struct elevator_queue
 	struct elevator_type *elevator_type;
 	struct mutex sysfs_lock;
 	struct hlist_head *hash;
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	/* fair queuing data */
+	struct elv_fq_data efqd;
+#endif
 };
 
 /*
@@ -207,5 +238,25 @@ enum {
 	__val;							\
 })
 
+/* iosched can let elevator know their feature set/capability */
+#ifdef CONFIG_ELV_FAIR_QUEUING
+
+/* iosched wants to use fair queuing logic of elevator layer */
+#define	ELV_IOSCHED_NEED_FQ	1
+
+static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
+{
+	return (e->elevator_type->elevator_features) & ELV_IOSCHED_NEED_FQ;
+}
+
+#else /* ELV_IOSCHED_FAIR_QUEUING */
+
+static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
+{
+	return 0;
+}
+#endif /* ELV_IOSCHED_FAIR_QUEUING */
+extern void *elv_get_sched_queue(struct request_queue *q, struct request *rq);
+extern void *elv_select_sched_queue(struct request_queue *q, int force);
 #endif /* CONFIG_BLOCK */
 #endif
-- 
1.6.0.6
