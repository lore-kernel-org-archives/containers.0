From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/23] io-controller: Core of the elevator fair queuing
Date: Fri, 28 Aug 2009 17:30:51 -0400
Message-ID: <1251495072-7780-3-git-send-email-vgoyal__9660.91108643941$1251495369$gmane$org@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

o This is core of the io scheduler implemented at elevator layer. This is a mix
  of cpu CFS scheduler and CFQ IO scheduler. Some of the bits from CFS have
  to be derived so that we can support hierarchical scheduling. Without
  cgroups or with-in group, we should essentially get same behavior as CFQ.

o This patch only shows non-hierarchical bits. Hierarhical code comes in later
  patches.

o This code is the building base of introducing fair queuing logic in common
  elevator layer so that it can be used by all the four IO schedulers.

Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Makefile      |    2 +-
 block/elevator-fq.c |  404 +++++++++++++++++++++++++++++++++++++++++++++++++++
 block/elevator-fq.h |  148 +++++++++++++++++++
 3 files changed, 553 insertions(+), 1 deletions(-)
 create mode 100644 block/elevator-fq.c
 create mode 100644 block/elevator-fq.h

diff --git a/block/Makefile b/block/Makefile
index 6c54ed0..19ff1e8 100644
--- a/block/Makefile
+++ b/block/Makefile
@@ -5,7 +5,7 @@
 obj-$(CONFIG_BLOCK) := elevator.o blk-core.o blk-tag.o blk-sysfs.o \
 			blk-barrier.o blk-settings.o blk-ioc.o blk-map.o \
 			blk-exec.o blk-merge.o blk-softirq.o blk-timeout.o \
-			ioctl.o genhd.o scsi_ioctl.o
+			ioctl.o genhd.o scsi_ioctl.o elevator-fq.o
 
 obj-$(CONFIG_BLK_DEV_BSG)	+= bsg.o
 obj-$(CONFIG_IOSCHED_NOOP)	+= noop-iosched.o
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
new file mode 100644
index 0000000..be7374d
--- /dev/null
+++ b/block/elevator-fq.c
@@ -0,0 +1,404 @@
+/*
+ * elevator fair queuing Layer.
+ *
+ * Based on ideas and code from CFQ, CFS and BFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Copyright (C) 2009 Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+ * 	              Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
+ */
+
+#include <linux/blkdev.h>
+#include "elevator-fq.h"
+
+/*
+ * offset from end of service tree
+ */
+#define ELV_IDLE_DELAY		(HZ / 5)
+#define ELV_SLICE_SCALE		(500)
+#define ELV_SERVICE_SHIFT	20
+
+static inline struct io_queue *ioq_of(struct io_entity *entity)
+{
+	if (entity->my_sd == NULL)
+		return container_of(entity, struct io_queue, entity);
+	return NULL;
+}
+
+static inline int io_entity_class_rt(struct io_entity *entity)
+{
+	return entity->ioprio_class == IOPRIO_CLASS_RT;
+}
+
+static inline int io_entity_class_idle(struct io_entity *entity)
+{
+	return entity->ioprio_class == IOPRIO_CLASS_IDLE;
+}
+
+static inline s64
+entity_key(struct io_service_tree *st, struct io_entity *entity)
+{
+	return entity->vdisktime - st->min_vdisktime;
+}
+
+static inline u64
+elv_delta(u64 service, unsigned int numerator_wt, unsigned int denominator_wt)
+{
+	if (numerator_wt != denominator_wt) {
+		service = service * numerator_wt;
+		do_div(service, denominator_wt);
+	}
+
+	return service;
+}
+
+static inline u64 elv_delta_fair(unsigned long delta, struct io_entity *entity)
+{
+	u64 d = delta << ELV_SERVICE_SHIFT;
+
+	return elv_delta(d, IO_WEIGHT_DEFAULT, entity->weight);
+}
+
+static inline int
+elv_weight_slice(struct elv_fq_data *efqd, int sync, unsigned int weight)
+{
+	const int base_slice = efqd->elv_slice[sync];
+
+	WARN_ON(weight > IO_WEIGHT_MAX);
+
+	return elv_delta(base_slice, weight, IO_WEIGHT_DEFAULT);
+}
+
+static inline int
+elv_prio_to_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
+{
+	return elv_weight_slice(efqd, elv_ioq_sync(ioq), ioq->entity.weight);
+}
+
+static inline u64 max_vdisktime(u64 min_vdisktime, u64 vdisktime)
+{
+	s64 delta = (s64)(vdisktime - min_vdisktime);
+	if (delta > 0)
+		min_vdisktime = vdisktime;
+
+	return min_vdisktime;
+}
+
+static inline u64 min_vdisktime(u64 min_vdisktime, u64 vdisktime)
+{
+	s64 delta = (s64)(vdisktime - min_vdisktime);
+	if (delta < 0)
+		min_vdisktime = vdisktime;
+
+	return min_vdisktime;
+}
+
+static void update_min_vdisktime(struct io_service_tree *st)
+{
+	u64 vdisktime;
+
+	if (st->active_entity)
+		vdisktime = st->active_entity->vdisktime;
+
+	if (st->rb_leftmost) {
+		struct io_entity *entity = rb_entry(st->rb_leftmost,
+						struct io_entity, rb_node);
+
+		if (!st->active_entity)
+			vdisktime = entity->vdisktime;
+		else
+			vdisktime = min_vdisktime(vdisktime, entity->vdisktime);
+	}
+
+	st->min_vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
+}
+
+static inline struct io_entity *parent_entity(struct io_entity *entity)
+{
+	return entity->parent;
+}
+
+static inline struct io_group *iog_of(struct io_entity *entity)
+{
+	if (entity->my_sd)
+		return container_of(entity, struct io_group, entity);
+	return NULL;
+}
+
+static inline struct elv_fq_data *efqd_of(struct io_entity *entity)
+{
+	return ioq_of(entity)->efqd;
+}
+
+static inline struct io_sched_data *
+io_entity_sched_data(struct io_entity *entity)
+{
+	struct elv_fq_data *efqd = efqd_of(entity);
+
+	return &efqd->root_group->sched_data;
+}
+
+static inline void
+init_io_entity_service_tree(struct io_entity *entity, struct io_entity *parent)
+{
+	struct io_group *parent_iog = iog_of(parent);
+	unsigned short idx = entity->ioprio_class - 1;
+
+	BUG_ON(idx >= IO_IOPRIO_CLASSES);
+
+	entity->st = &parent_iog->sched_data.service_tree[idx];
+}
+
+static void
+entity_served(struct io_entity *entity, unsigned long served,
+				unsigned long nr_sectors)
+{
+	entity->vdisktime += elv_delta_fair(served, entity);
+	update_min_vdisktime(entity->st);
+}
+
+static void place_entity(struct io_service_tree *st, struct io_entity *entity,
+				int add_front)
+{
+	u64 vdisktime = st->min_vdisktime;
+	struct rb_node *parent;
+	struct io_entity *entry;
+	int nr_active = st->nr_active - 1;
+
+	/*
+	 * Currently put entity at the end of last entity. This probably will
+	 * require adjustments as we move along
+	 */
+	if (io_entity_class_idle(entity)) {
+		vdisktime = elv_delta_fair(ELV_IDLE_DELAY, entity);
+		parent = rb_last(&st->active);
+		if (parent) {
+			entry = rb_entry(parent, struct io_entity, rb_node);
+			vdisktime += entry->vdisktime;
+		}
+	} else if (!add_front && nr_active) {
+		parent = rb_last(&st->active);
+		if (parent) {
+			entry = rb_entry(parent, struct io_entity, rb_node);
+			vdisktime = entry->vdisktime;
+		}
+	} else
+		vdisktime = st->min_vdisktime;
+
+	entity->vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
+}
+
+static inline void io_entity_update_prio(struct io_entity *entity)
+{
+	if (unlikely(entity->ioprio_changed)) {
+		/*
+		 * Re-initialize the service tree as ioprio class of the
+		 * entity might have changed.
+		 */
+		init_io_entity_service_tree(entity, parent_entity(entity));
+		entity->ioprio_changed = 0;
+	}
+}
+
+static void
+__dequeue_io_entity(struct io_service_tree *st, struct io_entity *entity)
+{
+	/*
+	 * This can happen when during put_prev_io_entity, we detect that ioprio
+	 * of the queue has changed and decide to dequeue_entity() and requeue
+	 * back. In this case entity is on service tree but has already been
+	 * removed from rb tree.
+	 */
+	if (RB_EMPTY_NODE(&entity->rb_node))
+		return;
+
+	if (st->rb_leftmost == &entity->rb_node) {
+		struct rb_node *next_node;
+
+		next_node = rb_next(&entity->rb_node);
+		st->rb_leftmost = next_node;
+	}
+
+	rb_erase(&entity->rb_node, &st->active);
+	RB_CLEAR_NODE(&entity->rb_node);
+}
+
+static void dequeue_io_entity(struct io_entity *entity)
+{
+	struct io_service_tree *st = entity->st;
+	struct io_sched_data *sd = io_entity_sched_data(entity);
+
+	__dequeue_io_entity(st, entity);
+	entity->on_st = 0;
+	st->nr_active--;
+	sd->nr_active--;
+}
+
+static void
+__enqueue_io_entity(struct io_service_tree *st, struct io_entity *entity)
+{
+	struct rb_node **node = &st->active.rb_node;
+	struct rb_node *parent = NULL;
+	struct io_entity *entry;
+	s64 key = entity_key(st, entity);
+	int leftmost = 1;
+
+	while (*node != NULL) {
+		parent = *node;
+		entry = rb_entry(parent, struct io_entity, rb_node);
+
+		if (key < entity_key(st, entry)) {
+			node = &parent->rb_left;
+		} else {
+			node = &parent->rb_right;
+			leftmost = 0;
+		}
+	}
+
+	/*
+	 * Maintain a cache of leftmost tree entries (it is frequently
+	 * used)
+	 */
+	if (leftmost)
+		st->rb_leftmost = &entity->rb_node;
+
+	rb_link_node(&entity->rb_node, parent, node);
+	rb_insert_color(&entity->rb_node, &st->active);
+}
+
+static void enqueue_io_entity(struct io_entity *entity)
+{
+	struct io_service_tree *st;
+	struct io_sched_data *sd = io_entity_sched_data(entity);
+
+	io_entity_update_prio(entity);
+	st = entity->st;
+	st->nr_active++;
+	sd->nr_active++;
+	entity->on_st = 1;
+	place_entity(st, entity, 0);
+	__enqueue_io_entity(st, entity);
+}
+
+static struct io_entity *__lookup_next_io_entity(struct io_service_tree *st)
+{
+	struct rb_node *left = st->rb_leftmost;
+
+	if (!left)
+		return NULL;
+
+	return rb_entry(left, struct io_entity, rb_node);
+}
+
+static struct io_entity *lookup_next_io_entity(struct io_sched_data *sd)
+{
+	struct io_service_tree *st = sd->service_tree;
+	struct io_entity *entity = NULL;
+	int i;
+
+	BUG_ON(sd->active_entity != NULL);
+
+	if (!sd->nr_active)
+		return NULL;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++, st++) {
+		entity = __lookup_next_io_entity(st);
+		if (entity) {
+			__dequeue_io_entity(st, entity);
+			st->active_entity = entity;
+			sd->active_entity = entity;
+			break;
+		}
+	}
+
+	return entity;
+}
+
+static void requeue_io_entity(struct io_entity *entity)
+{
+	struct io_service_tree *st = entity->st;
+	struct io_entity *next_entity;
+
+	next_entity = __lookup_next_io_entity(st);
+
+	/*
+	 * This is to emulate cfq like functionality where preemption can
+	 * happen with-in same class, like sync queue preempting async queue
+	 * May be this is not a very good idea from fairness point of view
+	 * as preempting queue gains share. Keeping it for now.
+	 *
+	 * This feature is also used by cfq close cooperator functionlity
+	 * where cfq selects a queue out of order to run next based on
+	 * close cooperator.
+	 */
+
+	if (next_entity && next_entity != entity) {
+		__dequeue_io_entity(st, entity);
+		place_entity(st, entity, 1);
+		__enqueue_io_entity(st, entity);
+	}
+}
+
+/* Requeue and ioq (already on the tree) to the front of service tree */
+static void requeue_ioq(struct io_queue *ioq)
+{
+	requeue_io_entity(&ioq->entity);
+}
+
+static void put_prev_io_entity(struct io_entity *entity)
+{
+	struct io_service_tree *st = entity->st;
+	struct io_sched_data *sd = io_entity_sched_data(entity);
+
+	st->active_entity = NULL;
+	sd->active_entity = NULL;
+
+	if (unlikely(entity->ioprio_changed)) {
+		dequeue_io_entity(entity);
+		enqueue_io_entity(entity);
+	} else
+		__enqueue_io_entity(st, entity);
+}
+
+/* Put curr ioq back into rb tree. */
+static void put_prev_ioq(struct io_queue *ioq)
+{
+	struct io_entity *entity = &ioq->entity;
+
+	put_prev_io_entity(entity);
+}
+
+static void dequeue_ioq(struct io_queue *ioq)
+{
+	struct io_entity *entity = &ioq->entity;
+
+	dequeue_io_entity(entity);
+	elv_put_ioq(ioq);
+	return;
+}
+
+/* Put a new queue on to the tree */
+static void enqueue_ioq(struct io_queue *ioq)
+{
+	struct io_entity *entity = &ioq->entity;
+
+	elv_get_ioq(ioq);
+	enqueue_io_entity(entity);
+}
+
+static inline void
+init_io_entity_parent(struct io_entity *entity, struct io_entity *parent)
+{
+	entity->parent = parent;
+	init_io_entity_service_tree(entity, parent);
+}
+
+void elv_put_ioq(struct io_queue *ioq)
+{
+	BUG_ON(atomic_read(&ioq->ref) <= 0);
+	if (!atomic_dec_and_test(&ioq->ref))
+		return;
+}
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
new file mode 100644
index 0000000..868e035
--- /dev/null
+++ b/block/elevator-fq.h
@@ -0,0 +1,148 @@
+/*
+ * elevator fair queuing Layer. Data structures and common functions prototypes.
+ *
+ * Based on ideas and code from CFQ, CFS and BFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Copyright (C) 2009 Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
+ * 	              Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
+ */
+
+#ifdef CONFIG_BLOCK
+#include <linux/blkdev.h>
+
+#ifndef _ELV_SCHED_H
+#define _ELV_SCHED_H
+
+#define IO_WEIGHT_MIN		100
+#define IO_WEIGHT_MAX		1000
+#define IO_WEIGHT_DEFAULT	500
+#define IO_IOPRIO_CLASSES	3
+
+struct io_service_tree {
+	struct rb_root active;
+	struct io_entity *active_entity;
+	u64 min_vdisktime;
+	struct rb_node *rb_leftmost;
+	unsigned int nr_active;
+};
+
+struct io_sched_data {
+	struct io_entity *active_entity;
+	int nr_active;
+	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
+};
+
+struct io_entity {
+	struct rb_node rb_node;
+	int on_st;
+	u64 vdisktime;
+	unsigned int weight;
+	struct io_entity *parent;
+
+	struct io_sched_data *my_sd;
+	struct io_service_tree *st;
+
+	unsigned short ioprio, ioprio_class;
+	int ioprio_changed;
+};
+
+/*
+ * A common structure representing the io queue where requests are actually
+ * queued.
+ */
+struct io_queue {
+	struct io_entity entity;
+	atomic_t ref;
+	unsigned int flags;
+
+	/* Pointer to generic elevator fair queuing data structure */
+	struct elv_fq_data *efqd;
+};
+
+struct io_group {
+	struct io_entity entity;
+	struct io_sched_data sched_data;
+};
+
+struct elv_fq_data {
+	struct io_group *root_group;
+
+	/* Base slice length for sync and async queues */
+	unsigned int elv_slice[2];
+};
+
+/* Some shared queue flag manipulation functions among elevators */
+
+enum elv_queue_state_flags {
+	ELV_QUEUE_FLAG_sync,              /* synchronous queue */
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
+ELV_IO_QUEUE_FLAG_FNS(sync)
+
+static inline void elv_get_ioq(struct io_queue *ioq)
+{
+	atomic_inc(&ioq->ref);
+}
+
+static inline unsigned int elv_ioprio_to_weight(int ioprio)
+{
+	WARN_ON(ioprio < 0 || ioprio >= IOPRIO_BE_NR);
+	/* Map prio 7 - 0 to weights 200 to 900 */
+	return IO_WEIGHT_DEFAULT + (IO_WEIGHT_DEFAULT/5 * (4 - ioprio));
+}
+
+static inline void elv_ioq_set_ioprio(struct io_queue *ioq, int ioprio)
+{
+	ioq->entity.ioprio = ioprio;
+	ioq->entity.weight = elv_ioprio_to_weight(ioprio);
+	ioq->entity.ioprio_changed = 1;
+}
+
+static inline void elv_ioq_set_ioprio_class(struct io_queue *ioq,
+						int ioprio_class)
+{
+	ioq->entity.ioprio_class = ioprio_class;
+	ioq->entity.ioprio_changed = 1;
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
+	return ioq->entity.ioprio_class;
+}
+
+static inline int elv_ioq_ioprio(struct io_queue *ioq)
+{
+	return ioq->entity.ioprio;
+}
+
+extern void elv_put_ioq(struct io_queue *ioq);
+#endif /* _ELV_SCHED_H */
+#endif /* CONFIG_BLOCK */
-- 
1.6.0.6
