From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/28] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Thu, 24 Sep 2009 15:25:08 -0400
Message-ID: <1253820332-10246-5-git-send-email-vgoyal__15512.8757389777$1253822408$gmane$org@redhat.com>
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

This is common fair queuing code in elevator layer. This is controlled by
config option CONFIG_ELV_FAIR_QUEUING. This patch initially only introduces
flat fair queuing support where there is only one group, "root group" and all
the tasks belong to root group.

This elevator layer changes are backward compatible. That means any ioscheduler
using old interfaces will continue to work.

This is essentially a lot of CFQ logic moved into common layer so that other
IO schedulers can make use of that in hierarhical scheduling setup.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   13 +
 block/Makefile           |    3 +-
 block/as-iosched.c       |    2 +-
 block/blk.h              |    6 +
 block/cfq-iosched.c      |    2 +-
 block/deadline-iosched.c |    3 +-
 block/elevator-fq.c      | 1025 +++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h      |  230 +++++++++++
 block/elevator.c         |   63 +++-
 block/noop-iosched.c     |    2 +-
 include/linux/blkdev.h   |   14 +
 include/linux/elevator.h |   50 +++-
 12 files changed, 1394 insertions(+), 19 deletions(-)

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
index 19ff1e8..d545323 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -5,7 +5,7 @@
 obj-$(CONFIG_BLOCK) := elevator.o blk-core.o blk-tag.o blk-sysfs.o \
 			blk-barrier.o blk-settings.o blk-ioc.o blk-map.o \
 			blk-exec.o blk-merge.o blk-softirq.o blk-timeout.o \
-			ioctl.o genhd.o scsi_ioctl.o elevator-fq.o
+			ioctl.o genhd.o scsi_ioctl.o
 
 obj-$(CONFIG_BLK_DEV_BSG)	+= bsg.o
 obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
@@ -15,3 +15,4 @@ obj-$(CONFIG_IOSCHED_CFQ)	+= cfq-iosched.o
 
 obj-$(CONFIG_BLOCK_COMPAT)	+= compat_ioctl.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY)	+= blk-integrity.o
+obj-$(CONFIG_ELV_FAIR_QUEUING)	+= elevator-fq.o
diff --git a/block/as-iosched.c b/block/as-iosched.c
index 7a12cf6..b90acbe 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -1351,7 +1351,7 @@ static void as_exit_queue(struct elevator_queue *e)
 /*
  * initialize elevator private data (as_data).
  */
-static void *as_init_queue(struct request_queue *q)
+static void *as_init_queue(struct request_queue *q, struct elevator_queue *eq)
 {
 	struct as_data *ad;
 
diff --git a/block/blk.h b/block/blk.h
index 3fae6ad..d05b4cf 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -1,6 +1,8 @@
 #ifndef BLK_INTERNAL_H
 #define BLK_INTERNAL_H
 
+#include "elevator-fq.h"
+
 /* Amount of time in which a process may batch requests */
 #define BLK_BATCH_TIME	(HZ/50UL)
 
@@ -71,6 +73,8 @@ static inline void elv_activate_rq(struct request_queue *q, struct request *rq)
 {
 	struct elevator_queue *e = q->elevator;
 
+	elv_activate_rq_fair(q, rq);
+
 	if (e->ops->elevator_activate_req_fn)
 		e->ops->elevator_activate_req_fn(q, rq);
 }
@@ -79,6 +83,8 @@ static inline void elv_deactivate_rq(struct request_queue *q, struct request *rq
 {
 	struct elevator_queue *e = q->elevator;
 
+	elv_deactivate_rq_fair(q, rq);
+
 	if (e->ops->elevator_deactivate_req_fn)
 		e->ops->elevator_deactivate_req_fn(q, rq);
 }
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index fd7080e..5a67ec0 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2448,7 +2448,7 @@ static void cfq_exit_queue(struct elevator_queue *e)
 	kfree(cfqd);
 }
 
-static void *cfq_init_queue(struct request_queue *q)
+static void *cfq_init_queue(struct request_queue *q, struct elevator_queue *eq)
 {
 	struct cfq_data *cfqd;
 	int i;
diff --git a/block/deadline-iosched.c b/block/deadline-iosched.c
index b547cbc..25af8b9 100644
--- a/block/deadline-iosched.c
+++ b/block/deadline-iosched.c
@@ -347,7 +347,8 @@ static void deadline_exit_queue(struct elevator_queue *e)
 /*
  * initialize elevator private data (deadline_data).
  */
-static void *deadline_init_queue(struct request_queue *q)
+static void *
+deadline_init_queue(struct request_queue *q, struct elevator_queue *eq)
 {
 	struct deadline_data *dd;
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 8343397..629ddaa 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -12,14 +12,23 @@
  */
 
 #include <linux/blkdev.h>
+#include <linux/blktrace_api.h>
 #include "elevator-fq.h"
 
+const int elv_slice_sync = HZ / 10;
+int elv_slice_async = HZ / 25;
+const int elv_slice_async_rq = 2;
+static struct kmem_cache *elv_ioq_pool;
+
 /*
  * offset from end of service tree
  */
 #define ELV_IDLE_DELAY		(HZ / 5)
 #define ELV_SLICE_SCALE		(500)
 #define ELV_SERVICE_SHIFT	20
+#define ELV_HW_QUEUE_MIN	(5)
+#define ELV_SERVICE_TREE_INIT   ((struct io_service_tree)	\
+				{ RB_ROOT, NULL, 0, NULL, 0})
 
 static void check_idle_tree_release(struct io_service_tree *st);
 
@@ -105,7 +114,7 @@ static inline u64 min_vdisktime(u64 min_vdisktime, u64 vdisktime)
 
 static void update_min_vdisktime(struct io_service_tree *st)
 {
-	u64 vdisktime;
+	u64 vdisktime = st->min_vdisktime;
 
 	if (st->active_entity)
 		vdisktime = st->active_entity->vdisktime;
@@ -141,6 +150,12 @@ static inline struct elv_fq_data *efqd_of(struct io_entity *entity)
 	return ioq_of(entity)->efqd;
 }
 
+struct io_group *ioq_to_io_group(struct io_queue *ioq)
+{
+	return ioq->efqd->root_group;
+}
+EXPORT_SYMBOL(ioq_to_io_group);
+
 static inline struct io_sched_data *
 io_entity_sched_data(struct io_entity *entity)
 {
@@ -468,6 +483,7 @@ static struct io_entity *lookup_next_io_entity(struct io_sched_data *sd)
 			__dequeue_io_entity(st, entity);
 			st->active_entity = entity;
 			sd->active_entity = entity;
+			update_min_vdisktime(entity->st);
 			break;
 		}
 	}
@@ -556,7 +572,1014 @@ init_io_entity_parent(struct io_entity *entity, struct io_entity *parent)
 
 void elv_put_ioq(struct io_queue *ioq)
 {
+	struct elv_fq_data *efqd = ioq->efqd;
+	struct elevator_queue *e = efqd->eq;
+
 	BUG_ON(atomic_read(&ioq->ref) <= 0);
 	if (!atomic_dec_and_test(&ioq->ref))
 		return;
+	BUG_ON(ioq->nr_queued);
+	BUG_ON(elv_ioq_busy(ioq));
+	BUG_ON(efqd->active_queue == ioq);
+
+	/* Can be called by outgoing elevator. Don't use q */
+	BUG_ON(!e->ops->elevator_free_sched_queue_fn);
+	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
+	elv_log_ioq(efqd, ioq, "put_queue");
+	elv_free_ioq(ioq);
+}
+EXPORT_SYMBOL(elv_put_ioq);
+
+static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
+{
+	unsigned long allocated_slice, queue_charge;
+
+	allocated_slice = elv_prio_to_slice(ioq->efqd, ioq);
+
+	/*
+	 * We don't want to charge more than allocated slice otherwise this
+	 * queue can miss one dispatch round doubling max latencies. On the
+	 * other hand we don't want to charge less than allocated slice as
+	 * we stick to CFQ theme of queue loosing its share if it does not
+	 * use the slice and moves to the back of service tree (almost).
+	 */
+	queue_charge = allocated_slice;
+	entity_served(&ioq->entity, served, queue_charge, ioq->nr_sectors);
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
+	struct elv_fq_data *efqd = e->efqd;				\
+	unsigned int __data = __VAR;					\
+	if (__CONV)							\
+		__data = jiffies_to_msecs(__data);			\
+	return elv_var_show(__data, (page));				\
+}
+SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
+EXPORT_SYMBOL(elv_slice_sync_show);
+SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
+EXPORT_SYMBOL(elv_slice_async_show);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
+ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)\
+{									\
+	struct elv_fq_data *efqd = e->efqd;				\
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
+STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_sync_store);
+STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
+EXPORT_SYMBOL(elv_slice_async_store);
+#undef STORE_FUNCTION
+
+void elv_schedule_dispatch(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+
+	if (elv_nr_busy_ioq(q->elevator)) {
+		elv_log(efqd, "schedule dispatch");
+		kblockd_schedule_work(q, &efqd->unplug_work);
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
+	del_timer_sync(&e->efqd->idle_slice_timer);
+	cancel_work_sync(&e->efqd->unplug_work);
+}
+
+static void elv_set_prio_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
+{
+	ioq->slice_start = jiffies;
+	ioq->slice_end = elv_prio_to_slice(efqd, ioq) + jiffies;
+	elv_log_ioq(efqd, ioq, "set_slice=%lu", ioq->slice_end - jiffies);
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
+int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq, pid_t pid,
+		int is_sync)
+{
+	RB_CLEAR_NODE(&ioq->entity.rb_node);
+	atomic_set(&ioq->ref, 0);
+	ioq->efqd = eq->efqd;
+	ioq->pid = pid;
+
+	elv_ioq_set_ioprio_class(ioq, IOPRIO_CLASS_BE);
+	elv_ioq_set_ioprio(ioq, IOPRIO_NORM);
+
+	return 0;
+}
+EXPORT_SYMBOL(elv_init_ioq);
+
+static void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
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
+ * Release all the io group references to its async queues.
+ */
+static void
+put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
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
+void *elv_io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
+						int ioprio)
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
+EXPORT_SYMBOL(elv_io_group_async_queue_prio);
+
+void elv_io_group_set_async_queue(struct io_group *iog, int ioprio_class,
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
+EXPORT_SYMBOL(elv_io_group_set_async_queue);
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
+	iog->entity.parent = NULL;
+	iog->entity.my_sd = &iog->sched_data;
+	iog->key = key;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
+		iog->sched_data.service_tree[i] = ELV_SERVICE_TREE_INIT;
+
+	return iog;
+}
+
+static void io_free_root_group(struct elevator_queue *e)
+{
+	struct io_group *iog = e->efqd->root_group;
+	struct io_service_tree *st;
+	int i;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		flush_idle_tree(st);
+	}
+
+	put_io_group_queues(e, iog);
+	kfree(iog);
+}
+
+/*
+ * Should be called after ioq prio and class has been initialized as prio
+ * class data will be used to determine which service tree in the group
+ * entity should be attached to.
+ */
+void elv_init_ioq_io_group(struct io_queue *ioq, struct io_group *iog)
+{
+	init_io_entity_parent(&ioq->entity, &iog->entity);
+}
+EXPORT_SYMBOL(elv_init_ioq_io_group);
+
+/* Get next queue for service. */
+static struct io_queue *elv_get_next_ioq(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+	struct io_entity *entity = NULL;
+	struct io_queue *ioq = NULL;
+	struct io_sched_data *sd;
+
+	BUG_ON(efqd->active_queue != NULL);
+
+	if (!efqd->busy_queues)
+		return NULL;
+
+	sd = &efqd->root_group->sched_data;
+	entity = lookup_next_io_entity(sd);
+	if (!entity)
+		return NULL;
+
+	ioq = ioq_of(entity);
+	return ioq;
+}
+
+/*
+ * coop (cooperating queue) tells that io scheduler selected a queue for us
+ * and we did not select the next queue based on fairness.
+ */
+static void
+__elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq, int coop)
+{
+	struct request_queue *q = efqd->queue;
+	struct elevator_queue *eq = q->elevator;
+
+	if (ioq) {
+		elv_log_ioq(efqd, ioq, "set_active, busy=%d",
+						efqd->busy_queues);
+		ioq->slice_start = ioq->slice_end = 0;
+		ioq->dispatch_start = jiffies;
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
+	if (ioq && eq->ops->elevator_active_ioq_set_fn)
+		eq->ops->elevator_active_ioq_set_fn(q, ioq->sched_queue, coop);
+}
+
+static inline int ioq_is_idling(struct io_queue *ioq)
+{
+	return (elv_ioq_wait_request(ioq) ||
+			timer_pending(&ioq->efqd->idle_slice_timer));
+}
+
+/* Get and set a new active queue for service. */
+static struct
+io_queue *elv_set_active_ioq(struct request_queue *q, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+	int coop = 0;
+
+	if (ioq) {
+		requeue_ioq(ioq, 1);
+		/*
+		 * io scheduler selected the next queue for us. Pass this
+		 * this info back to io scheudler. cfq currently uses it
+		 * to reset coop flag on the queue.
+		 */
+		coop = 1;
+	}
+
+	ioq = elv_get_next_ioq(q);
+	__elv_set_active_ioq(efqd, ioq, coop);
+	return ioq;
+}
+
+static void elv_reset_active_ioq(struct elv_fq_data *efqd)
+{
+	struct request_queue *q = efqd->queue;
+	struct elevator_queue *eq = q->elevator;
+	struct io_queue *ioq = elv_active_ioq(eq);
+
+	if (eq->ops->elevator_active_ioq_reset_fn)
+		eq->ops->elevator_active_ioq_reset_fn(q, ioq->sched_queue);
+
+	efqd->active_queue = NULL;
+	del_timer(&efqd->idle_slice_timer);
+}
+
+/* Called when an inactive queue receives a new request. */
+static void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
+{
+	BUG_ON(elv_ioq_busy(ioq));
+	BUG_ON(ioq == efqd->active_queue);
+	elv_log_ioq(efqd, ioq, "add to busy");
+	enqueue_ioq(ioq);
+	elv_mark_ioq_busy(ioq);
+	efqd->busy_queues++;
+}
+
+static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = e->efqd;
+
+	BUG_ON(!elv_ioq_busy(ioq));
+	BUG_ON(ioq->nr_queued);
+	elv_log_ioq(efqd, ioq, "del from busy");
+	elv_clear_ioq_busy(ioq);
+	BUG_ON(efqd->busy_queues == 0);
+	efqd->busy_queues--;
+	dequeue_ioq(ioq);
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
+ * Currently one should set fairness = 1 to force completion of requests
+ * from queue before dispatch from next queue starts. This should help in
+ * better time accounting at the expense of throughput.
+ */
+void elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+	long slice_used = 0, slice_overshoot = 0;
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
+	 * Queue got expired before even a single request completed or
+	 * got expired immediately after first request completion. Use
+	 * the time elapsed since queue was scheduled in.
+	 */
+	if (!ioq->slice_end || ioq->slice_start == jiffies) {
+		slice_used = jiffies - ioq->dispatch_start;
+		if (!slice_used)
+			slice_used = 1;
+		goto done;
+	}
+
+	slice_used = jiffies - ioq->slice_start;
+	if (time_after(jiffies, ioq->slice_end))
+		slice_overshoot = jiffies - ioq->slice_end;
+
+done:
+	elv_log_ioq(efqd, ioq, "disp_start = %lu sl_start= %lu sl_end=%lu,"
+			" jiffies=%lu", ioq->dispatch_start, ioq->slice_start,
+			ioq->slice_end, jiffies);
+	elv_log_ioq(efqd, ioq, "sl_used=%ld, overshoot=%ld sect=%lu",
+				slice_used, slice_overshoot, ioq->nr_sectors);
+	elv_ioq_served(ioq, slice_used);
+
+	BUG_ON(ioq != efqd->active_queue);
+	elv_reset_active_ioq(efqd);
+	/* Queue is being expired. Reset number of secotrs dispatched */
+	ioq->nr_sectors = 0;
+
+	put_prev_ioq(ioq);
+
+	if (!ioq->nr_queued)
+		elv_del_ioq_busy(q->elevator, ioq);
+	else if (!elv_ioq_sync(ioq)) {
+		/*
+		 * Requeue async ioq so that these will be again placed at
+		 * the end of service tree giving a chance to sync queues.
+		 */
+		requeue_ioq(ioq, 0);
+	}
+}
+EXPORT_SYMBOL(elv_ioq_slice_expired);
+
+/* Expire the ioq. */
+void elv_slice_expired(struct request_queue *q)
+{
+	struct io_queue *ioq = elv_active_ioq(q->elevator);
+
+	if (ioq)
+		elv_ioq_slice_expired(q, ioq);
+}
+
+/*
+ * Check if new_cfqq should preempt the currently active queue. Return 0 for
+ * no or if we aren't sure, a 1 will cause a preemption attempt.
+ */
+static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
+			struct request *rq)
+{
+	struct io_queue *active_ioq;
+	struct elevator_queue *eq = q->elevator;
+	struct io_entity *entity, *new_entity;
+
+	active_ioq = elv_active_ioq(eq);
+
+	if (!active_ioq)
+		return 0;
+
+	entity = &active_ioq->entity;
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
+	if (eq->ops->elevator_should_preempt_fn) {
+		void *sched_queue = elv_ioq_sched_queue(new_ioq);
+
+		return eq->ops->elevator_should_preempt_fn(q, sched_queue, rq);
+	}
+
+	return 0;
+}
+
+static void elv_preempt_queue(struct request_queue *q, struct io_queue *ioq)
+{
+	elv_log_ioq(q->elevator->efqd, ioq, "preempt");
+	elv_slice_expired(q);
+
+	/*
+	 * Put the new queue at the front of the of the current list,
+	 * so we know that it will be selected next.
+	 */
+
+	requeue_ioq(ioq, 1);
+	elv_mark_ioq_slice_new(ioq);
+}
+
+void elv_ioq_request_add(struct request_queue *q, struct request *rq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+	struct io_queue *ioq = rq->ioq;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	BUG_ON(!efqd);
+	BUG_ON(!ioq);
+	ioq->nr_queued++;
+	elv_log_ioq(efqd, ioq, "add rq: rq_queued=%d", ioq->nr_queued);
+
+	if (!elv_ioq_busy(ioq))
+		elv_add_ioq_busy(efqd, ioq);
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
+			del_timer(&efqd->idle_slice_timer);
+			elv_clear_ioq_wait_request(ioq);
+			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
+			    efqd->busy_queues > 1 || !blk_queue_plugged(q))
+				__blk_run_queue(q);
+			else
+				elv_mark_ioq_must_dispatch(ioq);
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
+		elv_clear_ioq_wait_request(ioq);
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
+	elv_slice_expired(q);
+out_kick:
+	elv_schedule_dispatch(q);
+out_cont:
+	spin_unlock_irqrestore(q->queue_lock, flags);
+}
+
+static void elv_ioq_arm_slice_timer(struct request_queue *q)
+{
+	struct elevator_queue *eq = q->elevator;
+	struct io_queue *ioq = elv_active_ioq(eq);
+
+	if (eq->ops->elevator_arm_slice_timer_fn)
+		eq->ops->elevator_arm_slice_timer_fn(q, ioq->sched_queue);
+}
+
+/*
+ * If io scheduler has functionality of keeping track of close cooperator, check
+ * with it if it has got a closely co-operating queue.
+ */
+static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
+					struct io_queue *ioq)
+{
+	struct elevator_queue *e = q->elevator;
+	struct io_queue *new_ioq = NULL;
+	void *sched_queue = ioq->sched_queue;
+
+	if (q->elevator->ops->elevator_close_cooperator_fn)
+		new_ioq = e->ops->elevator_close_cooperator_fn(q, sched_queue);
+
+	if (new_ioq)
+		elv_log_ioq(e->efqd, ioq, "cooperating ioq=%d", new_ioq->pid);
+
+	return new_ioq;
+}
+
+/* Common layer function to select the next queue to dispatch from */
+void *elv_select_ioq(struct request_queue *q, int force)
+{
+	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
+
+	if (!elv_nr_busy_ioq(q->elevator))
+		return NULL;
+
+	if (ioq == NULL)
+		goto new_queue;
+
+	/* There is only one active queue which is empty. Nothing to dispatch */
+	if (elv_nr_busy_ioq(q->elevator) == 1 && !ioq->nr_queued)
+		return NULL;
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
+	new_ioq = elv_close_cooperator(q, ioq);
+	if (new_ioq)
+		goto expire;
+
+	/*
+	 * No requests pending. If the active queue still has requests in
+	 * flight or is idling for a new request, allow either of these
+	 * conditions to happen (or time out) before selecting a new queue.
+	 */
+
+	if (ioq_is_idling(ioq) ||
+	    (elv_ioq_nr_dispatched(ioq) && elv_ioq_idle_window(ioq))) {
+		ioq = NULL;
+		goto keep_queue;
+	}
+
+expire:
+	elv_slice_expired(q);
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
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return;
+
+	ioq = rq->ioq;
+	BUG_ON(!ioq);
+	ioq->nr_queued--;
+}
+
+/* A request got dispatched. Do the accounting. */
+void elv_dispatched_request_fair(struct elevator_queue *e, struct request *rq)
+{
+	struct io_queue *ioq = rq->ioq;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return;
+
+	BUG_ON(!ioq);
+	ioq->dispatched++;
+	ioq->nr_sectors += blk_rq_sectors(rq);
+	elv_ioq_request_removed(e, rq);
+	elv_clear_ioq_must_dispatch(ioq);
+}
+
+void elv_activate_rq_fair(struct request_queue *q, struct request *rq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	efqd->rq_in_driver++;
+	elv_log_ioq(efqd, rq->ioq, "activate rq, drv=%d",
+						efqd->rq_in_driver);
+}
+
+void elv_deactivate_rq_fair(struct request_queue *q, struct request *rq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
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
+ * if this is only queue and it has completed all its requests and has nothing
+ * to dispatch, expire it. We don't want to keep it around idle otherwise later
+ * when it is expired, all this idle time will be added to queue's disk time
+ * used and queue might not get a chance to run for a long time.
+ */
+static inline void
+check_expire_last_empty_queue(struct request_queue *q, struct io_queue *ioq)
+{
+	struct elv_fq_data *efqd = q->elevator->efqd;
+
+	if (efqd->busy_queues != 1)
+		return;
+
+	if (ioq->dispatched || ioq->nr_queued)
+		return;
+
+	/*
+	 * Anticipation is on. Don't expire queue. Either a new request will
+	 * come or it is up to io scheduler to expire the queue once idle
+	 * timer fires
+	 */
+
+	if (ioq_is_idling(ioq))
+		return;
+
+	elv_log_ioq(efqd, ioq, "expire last empty queue");
+	elv_slice_expired(q);
+}
+
+/* A request got completed from io_queue. Do the accounting. */
+void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
+{
+	const int sync = rq_is_sync(rq);
+	struct io_queue *ioq;
+	struct elv_fq_data *efqd = q->elevator->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return;
+
+	ioq = rq->ioq;
+	WARN_ON(!efqd->rq_in_driver);
+	WARN_ON(!ioq->dispatched);
+	efqd->rq_in_driver--;
+	ioq->dispatched--;
+
+	elv_log_ioq(efqd, ioq, "complete rq_queued=%d drv=%d disp=%d",
+			ioq->nr_queued, efqd->rq_in_driver,
+			elv_ioq_nr_dispatched(ioq));
+	/*
+	 * If this is the active queue, check if it needs to be expired,
+	 * or if we want to idle in case it has no pending requests.
+	 */
+
+	if (elv_active_ioq(q->elevator) == ioq) {
+		if (elv_ioq_slice_new(ioq)) {
+			elv_set_prio_slice(q->elevator->efqd, ioq);
+			elv_clear_ioq_slice_new(ioq);
+		}
+
+		/*
+		 * If there are no requests waiting in this queue, and
+		 * there are other queues ready to issue requests, AND
+		 * those other queues are issuing requests within our
+		 * mean seek distance, give them a chance to run instead
+		 * of idling.
+		 */
+		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
+			elv_slice_expired(q);
+		else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq)
+			 && sync && !rq_noidle(rq))
+			elv_ioq_arm_slice_timer(q);
+
+		check_expire_last_empty_queue(q, ioq);
+	}
+
+	if (!efqd->rq_in_driver)
+		elv_schedule_dispatch(q);
 }
+
+/*
+ * The process associted with ioq (in case of cfq), is going away. Mark it
+ * for deletion.
+ */
+void elv_exit_ioq(struct io_queue *ioq)
+{
+	struct io_entity *entity = &ioq->entity;
+
+	/*
+	 * Async ioq's belong to io group and are cleaned up once group is
+	 * being deleted. Not need to do any cleanup here even if cfq has
+	 * dropped the reference to the queue
+	 */
+	if (!elv_ioq_sync(ioq))
+		return;
+
+	/*
+	 * This queue is still under service. Just mark it so that once all
+	 * the IO from queue is done, it is not put back in idle tree.
+	 */
+	if (entity->on_st) {
+		entity->exiting = 1;
+		return;
+	} else if (entity->on_idle_st) {
+		/* Remove ioq from idle tree */
+		dequeue_io_entity_idle(entity);
+	}
+}
+EXPORT_SYMBOL(elv_exit_ioq);
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
+struct elv_fq_data *
+elv_alloc_fq_data(struct request_queue *q, struct elevator_queue *e)
+{
+	struct elv_fq_data *efqd = NULL;
+
+	efqd = kmalloc_node(sizeof(*efqd), GFP_KERNEL | __GFP_ZERO, q->node);
+	return efqd;
+}
+
+void elv_release_fq_data(struct elv_fq_data *efqd)
+{
+	kfree(efqd);
+}
+
+/* Initialize fair queueing data associated with elevator */
+int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
+{
+	struct io_group *iog;
+	struct elv_fq_data *efqd = e->efqd;
+
+	if (!elv_iosched_fair_queuing_enabled(e))
+		return 0;
+
+	iog = io_alloc_root_group(q, e, efqd);
+	if (iog == NULL)
+		return 1;
+
+	efqd->root_group = iog;
+
+	/*
+	 * Our fallback ioq if elv_alloc_ioq() runs into OOM issues.
+	 * Grab a permanent reference to it, so that the normal code flow
+	 * will not attempt to free it.
+	 */
+	elv_init_ioq(e, &efqd->oom_ioq, 1, 0);
+	elv_get_ioq(&efqd->oom_ioq);
+	elv_init_ioq_io_group(&efqd->oom_ioq, iog);
+
+	efqd->queue = q;
+	efqd->eq = e;
+
+	init_timer(&efqd->idle_slice_timer);
+	efqd->idle_slice_timer.function = elv_idle_slice_timer;
+	efqd->idle_slice_timer.data = (unsigned long) efqd;
+
+	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
+
+	efqd->elv_slice[0] = elv_slice_async;
+	efqd->elv_slice[1] = elv_slice_sync;
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
+	struct elv_fq_data *efqd = e->efqd;
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
+	return 0;
+}
+
+module_init(elv_fq_init);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index ee46a47..6ea0d18 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -22,6 +22,10 @@
 #define IO_WEIGHT_DEFAULT	500
 #define IO_IOPRIO_CLASSES	3
 
+#ifdef CONFIG_ELV_FAIR_QUEUING
+#define ELV_ATTR(name) \
+	__ATTR(name, S_IRUGO|S_IWUSR, elv_##name##_show, elv_##name##_store)
+
 struct io_service_tree {
 	struct rb_root active;
 	struct io_entity *active_entity;
@@ -68,23 +72,80 @@ struct io_queue {
 
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
+	/* Number of sectors dispatched in current dispatch round */
+	unsigned long nr_sectors;
+
+	/* time when dispatch from the queue was started */
+	unsigned long dispatch_start;
+	/* time when first request from queue completed and slice started. */
+	unsigned long slice_start;
+	unsigned long slice_end;
+
+	/* Pointer to io scheduler's queue */
+	void *sched_queue;
 };
 
 struct io_group {
 	struct io_entity entity;
 	struct io_sched_data sched_data;
+	/*
+	 * async queue for each priority case for RT and BE class.
+	 * Used only for cfq.
+	 */
+
+	struct io_queue *async_queue[2][IOPRIO_BE_NR];
+	struct io_queue *async_idle_queue;
+	void *key;
 };
 
 struct elv_fq_data {
 	struct io_group *root_group;
 
+	struct request_queue *queue;
+	struct elevator_queue *eq;
+	unsigned int busy_queues;
+
+	/* Pointer to the ioscheduler queue being served */
+	void *active_queue;
+
+	int rq_in_driver;
+
+	struct timer_list idle_slice_timer;
+	struct work_struct unplug_work;
+
 	/* Base slice length for sync and async queues */
 	unsigned int elv_slice[2];
+
+	/* Fallback dummy ioq for extreme OOM conditions */
+	struct io_queue oom_ioq;
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
 /* Some shared queue flag manipulation functions among elevators */
 
 enum elv_queue_state_flags {
+	ELV_QUEUE_FLAG_busy,          /* has requests or is under service */
+	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
+	ELV_QUEUE_FLAG_must_dispatch,	  /* must be allowed a dispatch */
+	ELV_QUEUE_FLAG_idle_window,       /* elevator slice idling enabled */
+	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
 	ELV_QUEUE_FLAG_sync,              /* synchronous queue */
 };
 
@@ -102,6 +163,11 @@ static inline int elv_ioq_##name(struct io_queue *ioq)         		\
 	return ((ioq)->flags & (1 << ELV_QUEUE_FLAG_##name)) != 0;	\
 }
 
+ELV_IO_QUEUE_FLAG_FNS(busy)
+ELV_IO_QUEUE_FLAG_FNS(wait_request)
+ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
+ELV_IO_QUEUE_FLAG_FNS(idle_window)
+ELV_IO_QUEUE_FLAG_FNS(slice_new)
 ELV_IO_QUEUE_FLAG_FNS(sync)
 
 static inline void elv_get_ioq(struct io_queue *ioq)
@@ -150,6 +216,170 @@ static inline int elv_ioq_ioprio(struct io_queue *ioq)
 	return ioq->entity.ioprio;
 }
 
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
+static inline void *elv_ioq_sched_queue(struct io_queue *ioq)
+{
+	if (ioq)
+		return ioq->sched_queue;
+	return NULL;
+}
+
+static inline struct io_queue *elv_active_ioq(struct elevator_queue *e)
+{
+	return e->efqd->active_queue;
+}
+
+static inline void *elv_active_sched_queue(struct elevator_queue *e)
+{
+	return elv_ioq_sched_queue(elv_active_ioq(e));
+}
+
+static inline int elv_rq_in_driver(struct elevator_queue *e)
+{
+	return e->efqd->rq_in_driver;
+}
+
+static inline int elv_nr_busy_ioq(struct elevator_queue *e)
+{
+	return e->efqd->busy_queues;
+}
+
+/* Helper functions for operating on elevator idle slice timer */
+static inline int
+elv_mod_idle_slice_timer(struct elevator_queue *eq, unsigned long expires)
+{
+	return mod_timer(&eq->efqd->idle_slice_timer, expires);
+}
+
+static inline int elv_del_idle_slice_timer(struct elevator_queue *eq)
+{
+	return del_timer(&eq->efqd->idle_slice_timer);
+}
+
+static inline void
+elv_init_ioq_sched_queue(struct elevator_queue *eq, struct io_queue *ioq,
+					void *sched_queue)
+{
+	ioq->sched_queue = sched_queue;
+}
+
+static inline struct io_queue *elv_get_oom_ioq(struct elevator_queue *eq)
+{
+	return &eq->efqd->oom_ioq;
+}
+
+static inline struct io_group *
+elv_io_get_io_group(struct request_queue *q, int create)
+{
+	/* In flat mode, there is only root group */
+	return q->elevator->efqd->root_group;
+}
+
+extern ssize_t elv_slice_sync_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
+						size_t count);
+extern ssize_t elv_slice_async_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_slice_async_store(struct elevator_queue *q, const char *name,
+						size_t count);
+
+/* Functions used by elevator.c */
+extern struct elv_fq_data *elv_alloc_fq_data(struct request_queue *q,
+					struct elevator_queue *e);
+extern void elv_release_fq_data(struct elv_fq_data *efqd);
+extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
+extern void elv_exit_fq_data(struct elevator_queue *e);
+
+extern void elv_ioq_request_add(struct request_queue *q, struct request *rq);
+extern void elv_ioq_request_removed(struct elevator_queue *e,
+					struct request *rq);
+extern void elv_dispatched_request_fair(struct elevator_queue *e,
+					struct request *rq);
+
+extern void elv_activate_rq_fair(struct request_queue *q, struct request *rq);
+extern void elv_deactivate_rq_fair(struct request_queue *q, struct request *rq);
+
+extern void elv_ioq_completed_request(struct request_queue *q,
+				struct request *rq);
+
+extern void *elv_select_ioq(struct request_queue *q, int force);
+
+/* Functions used by io schedulers */
 extern void elv_put_ioq(struct io_queue *ioq);
+extern void elv_ioq_slice_expired(struct request_queue *q,
+					struct io_queue *ioq);
+extern int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
+				pid_t pid, int is_sync);
+extern void elv_init_ioq_io_group(struct io_queue *ioq, struct io_group *iog);
+extern void elv_schedule_dispatch(struct request_queue *q);
+extern void *elv_io_group_async_queue_prio(struct io_group *iog,
+						int ioprio_class, int ioprio);
+extern void elv_io_group_set_async_queue(struct io_group *iog, int ioprio_class,
+					int ioprio, struct io_queue *ioq);
+extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
+extern void elv_free_ioq(struct io_queue *ioq);
+extern struct io_group *ioq_to_io_group(struct io_queue *ioq);
+extern void elv_exit_ioq(struct io_queue *ioq);
+
+#else /* CONFIG_ELV_FAIR_QUEUING */
+static inline struct elv_fq_data *
+elv_alloc_fq_data(struct request_queue *q, struct elevator_queue *e)
+{
+	return 0;
+}
+static inline void elv_release_fq_data(struct elv_fq_data *efqd) {}
+
+static inline int
+elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
+{
+	return 0;
+}
+
+static inline void elv_exit_fq_data(struct elevator_queue *e) {}
+
+static inline void
+elv_activate_rq_fair(struct request_queue *q, struct request *rq) {}
+
+static inline void
+elv_deactivate_rq_fair(struct request_queue *q, struct request *rq) {}
+
+static inline void
+elv_dispatched_request_fair(struct elevator_queue *e, struct request *rq) {}
+
+static inline void
+elv_ioq_request_removed(struct elevator_queue *e, struct request *rq) {}
+
+static inline void
+elv_ioq_request_add(struct request_queue *q, struct request *rq) {}
+
+static inline void
+elv_ioq_completed_request(struct request_queue *q, struct request *rq) {}
+
+static inline void *elv_ioq_sched_queue(struct io_queue *ioq) { return NULL; }
+static inline void *elv_select_ioq(struct request_queue *q, int force)
+{
+	return NULL;
+}
+#endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _ELV_SCHED_H */
 #endif /* CONFIG_BLOCK */
diff --git a/block/elevator.c b/block/elevator.c
index 2d511f9..ea4042e 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -53,6 +53,15 @@ static const int elv_hash_shift = 6;
 #define ELV_HASH_ENTRIES	(1 << elv_hash_shift)
 #define rq_hash_key(rq)		(blk_rq_pos(rq) + blk_rq_sectors(rq))
 
+static inline struct elv_fq_data *elv_efqd(struct elevator_queue *eq)
+{
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	return eq->efqd;
+#else
+	return NULL;
+#endif
+}
+
 /*
  * Query io scheduler to see if the current process issuing bio may be
  * merged with rq.
@@ -187,7 +196,7 @@ static struct elevator_type *elevator_get(const char *name)
 static void *elevator_init_queue(struct request_queue *q,
 				 struct elevator_queue *eq)
 {
-	return eq->ops->elevator_init_fn(q);
+	return eq->ops->elevator_init_fn(q, eq);
 }
 
 static void elevator_attach(struct request_queue *q, struct elevator_queue *eq,
@@ -239,8 +248,21 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
 	for (i = 0; i < ELV_HASH_ENTRIES; i++)
 		INIT_HLIST_HEAD(&eq->hash[i]);
 
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	eq->efqd = elv_alloc_fq_data(q, eq);
+
+	if (!eq->efqd)
+		goto err;
+
+	if (elv_init_fq_data(q, eq))
+		goto err;
+#endif
 	return eq;
 err:
+	if (elv_efqd(eq))
+		elv_release_fq_data(elv_efqd(eq));
+	if (eq->hash)
+		kfree(eq->hash);
 	kfree(eq);
 	elevator_put(e);
 	return NULL;
@@ -252,6 +274,7 @@ static void elevator_release(struct kobject *kobj)
 
 	e = container_of(kobj, struct elevator_queue, kobj);
 	elevator_put(e->elevator_type);
+	elv_release_fq_data(elv_efqd(e));
 	kfree(e->hash);
 	kfree(e);
 }
@@ -309,6 +332,7 @@ EXPORT_SYMBOL(elevator_init);
 void elevator_exit(struct elevator_queue *e)
 {
 	mutex_lock(&e->sysfs_lock);
+	elv_exit_fq_data(e);
 	if (e->ops->elevator_exit_fn)
 		e->ops->elevator_exit_fn(e);
 	e->ops = NULL;
@@ -438,6 +462,7 @@ void elv_dispatch_sort(struct request_queue *q, struct request *rq)
 	elv_rqhash_del(q, rq);
 
 	q->nr_sorted--;
+	elv_dispatched_request_fair(q->elevator, rq);
 
 	boundary = q->end_sector;
 	stop_flags = REQ_SOFTBARRIER | REQ_HARDBARRIER | REQ_STARTED;
@@ -478,6 +503,7 @@ void elv_dispatch_add_tail(struct request_queue *q, struct request *rq)
 	elv_rqhash_del(q, rq);
 
 	q->nr_sorted--;
+	elv_dispatched_request_fair(q->elevator, rq);
 
 	q->end_sector = rq_end_sector(rq);
 	q->boundary_rq = rq;
@@ -545,6 +571,7 @@ void elv_merge_requests(struct request_queue *q, struct request *rq,
 	elv_rqhash_del(q, next);
 
 	q->nr_sorted--;
+	elv_ioq_request_removed(e, next);
 	q->last_merge = rq;
 }
 
@@ -651,12 +678,8 @@ void elv_insert(struct request_queue *q, struct request *rq, int where)
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
@@ -755,13 +778,12 @@ EXPORT_SYMBOL(elv_add_request);
 
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
@@ -841,8 +863,11 @@ void elv_completed_request(struct request_queue *q, struct request *rq)
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
@@ -1138,3 +1163,17 @@ struct request *elv_rb_latter_request(struct request_queue *q,
 	return NULL;
 }
 EXPORT_SYMBOL(elv_rb_latter_request);
+
+/* Get the io scheduler queue pointer. For cfq, it is stored in rq->ioq*/
+void *elv_get_sched_queue(struct request_queue *q, struct request *rq)
+{
+	return elv_ioq_sched_queue(req_ioq(rq));
+}
+EXPORT_SYMBOL(elv_get_sched_queue);
+
+/* Select an ioscheduler queue to dispatch request from. */
+void *elv_select_sched_queue(struct request_queue *q, int force)
+{
+	return elv_ioq_sched_queue(elv_select_ioq(q, force));
+}
+EXPORT_SYMBOL(elv_select_sched_queue);
diff --git a/block/noop-iosched.c b/block/noop-iosched.c
index 3a0d369..36fc210 100644
--- a/block/noop-iosched.c
+++ b/block/noop-iosched.c
@@ -65,7 +65,7 @@ noop_latter_request(struct request_queue *q, struct request *rq)
 	return list_entry(rq->queuelist.next, struct request, queuelist);
 }
 
-static void *noop_init_queue(struct request_queue *q)
+static void *noop_init_queue(struct request_queue *q, struct elevator_queue *eq)
 {
 	struct noop_data *nd;
 
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 69103e0..7cff5f2 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -229,6 +229,11 @@ struct request {
 
 	/* for bidi */
 	struct request *next_rq;
+
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	/* io queue request belongs to */
+	struct io_queue *ioq;
+#endif
 };
 
 static inline unsigned short req_get_ioprio(struct request *req)
@@ -236,6 +241,15 @@ static inline unsigned short req_get_ioprio(struct request *req)
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
index 1cb3372..4414a61 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -27,8 +27,19 @@ typedef void (elevator_put_req_fn) (struct request *);
 typedef void (elevator_activate_req_fn) (struct request_queue *, struct request *);
 typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct request *);
 
-typedef void *(elevator_init_fn) (struct request_queue *);
+typedef void *(elevator_init_fn) (struct request_queue *,
+					struct elevator_queue *);
 typedef void (elevator_exit_fn) (struct elevator_queue *);
+#ifdef CONFIG_ELV_FAIR_QUEUING
+typedef void (elevator_free_sched_queue_fn) (struct elevator_queue*, void *);
+typedef void (elevator_active_ioq_set_fn) (struct request_queue*, void *, int);
+typedef void (elevator_active_ioq_reset_fn) (struct request_queue *, void*);
+typedef void (elevator_arm_slice_timer_fn) (struct request_queue*, void*);
+typedef int (elevator_should_preempt_fn) (struct request_queue*, void*,
+						struct request*);
+typedef struct io_queue* (elevator_close_cooperator_fn) (struct request_queue*,
+						void*);
+#endif
 
 struct elevator_ops
 {
@@ -56,6 +67,16 @@ struct elevator_ops
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
+	elevator_close_cooperator_fn *elevator_close_cooperator_fn;
+#endif
 };
 
 #define ELV_NAME_MAX	(16)
@@ -76,6 +97,9 @@ struct elevator_type
 	struct elv_fs_entry *elevator_attrs;
 	char elevator_name[ELV_NAME_MAX];
 	struct module *elevator_owner;
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	int elevator_features;
+#endif
 };
 
 /*
@@ -89,6 +113,10 @@ struct elevator_queue
 	struct elevator_type *elevator_type;
 	struct mutex sysfs_lock;
 	struct hlist_head *hash;
+#ifdef CONFIG_ELV_FAIR_QUEUING
+	/* fair queuing data */
+	struct elv_fq_data *efqd;
+#endif
 };
 
 /*
@@ -207,5 +235,25 @@ enum {
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
