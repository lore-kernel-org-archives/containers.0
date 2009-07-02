From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/25] io-controller: Core of the B-WF2Q+ scheduler
Date: Thu,  2 Jul 2009 16:01:34 -0400
Message-ID: <1246564917-19603-3-git-send-email-vgoyal__16699.0153761164$1246568250$gmane$org@redhat.com>
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

This is core of the BFQ(B-WF2Q+) scheduler originally implemented by Paolo and
Fabio in BFQ patches. Since then I have taken relevant pieces from BFQ and
continued the work on IO controller. It is not the full patch. Just pulled out
the some bits to show how core scheduler looks like and it becomes easier to
review.

Originally BFQ code was hierarchical. This patch only shows non-hierarchical
bits. Hierarhical code comes in later patches.

This code is the building base of introducing fair queuing logic in common
elevator layer so that it can be used by all the four IO schedulers. In
later patches, CFQ's weighted round robin scheduler will be replaced with
B-WF2Q+ scheduler.

Also note that BFQ originally provided fairness in-terms of number of
sectors of IO done by the queue. It has been modified to provide fairness
in terms of disk time (like CFQ allocate disk time slices proportionate to
prio/weight).

B-WF2Q+ is based on WF2Q+, that is described in [2], together with
H-WF2Q+, while the augmented tree used to implement B-WF2Q+ with O(log N)
complexity derives from the one introduced with EEVDF in [3].

[1] P. Valente and F. Checconi, ``High Throughput Disk Scheduling
    with Deterministic Guarantees on Bandwidth Distribution,'' to be
    published.

    http://algo.ing.unimo.it/people/paolo/disk_sched/bfq.pdf

[2] Jon C.R. Bennett and H. Zhang, ``Hierarchical Packet Fair Queueing
    Algorithms,'' IEEE/ACM Transactions on Networking, 5(5):675-689,
    Oct 1997.

    http://www.cs.cmu.edu/~hzhang/papers/TON-97-Oct.ps.gz

[3] I. Stoica and H. Abdel-Wahab, ``Earliest Eligible Virtual Deadline
    First: A Flexible and Accurate Mechanism for Proportional Share
    Resource Allocation,'' technical report.

    http://www.cs.berkeley.edu/~istoica/papers/eevdf-tr-95.pdf

Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  717 +++++++++++++++++++++++++++++++++++++++++++++++++++
 block/elevator-fq.h |  172 ++++++++++++
 2 files changed, 889 insertions(+), 0 deletions(-)
 create mode 100644 block/elevator-fq.c
 create mode 100644 block/elevator-fq.h

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
new file mode 100644
index 0000000..a58efdc
--- /dev/null
+++ b/block/elevator-fq.c
@@ -0,0 +1,717 @@
+/*
+ * elevator fair queuing Layer. Uses B-WF2Q+ hierarchical scheduler for
+ * fair queuing.
+ *
+ * Based on ideas and code from CFQ:
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
+#define IO_SERVICE_TREE_INIT   ((struct io_service_tree)		\
+				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
+
+/* Mainly the BFQ scheduling code Follows */
+
+/*
+ * Shift for timestamp calculations.  This actually limits the maximum
+ * service allowed in one timestamp delta (small shift values increase it),
+ * the maximum total weight that can be used for the queues in the system
+ * (big shift values increase it), and the period of virtual time wraparounds.
+ */
+#define WFQ_SERVICE_SHIFT	22
+
+/**
+ * bfq_gt - compare two timestamps.
+ * @a: first ts.
+ * @b: second ts.
+ *
+ * Return @a > @b, dealing with wrapping correctly.
+ */
+static inline int bfq_gt(u64 a, u64 b)
+{
+	return (s64)(a - b) > 0;
+}
+
+/**
+ * bfq_delta - map service into the virtual time domain.
+ * @service: amount of service.
+ * @weight: scale factor.
+ */
+static inline u64 bfq_delta(unsigned long service, unsigned int weight)
+{
+	u64 d = (u64)service << WFQ_SERVICE_SHIFT;
+
+	do_div(d, weight);
+	return d;
+}
+
+/**
+ * bfq_calc_finish - assign the finish time to an entity.
+ * @entity: the entity to act upon.
+ * @service: the service to be charged to the entity.
+ */
+static inline void bfq_calc_finish(struct io_entity *entity,
+					unsigned long service)
+{
+	BUG_ON(entity->weight == 0);
+
+	entity->finish = entity->start + bfq_delta(service, entity->weight);
+}
+
+static inline struct io_queue *io_entity_to_ioq(struct io_entity *entity)
+{
+	struct io_queue *ioq = NULL;
+
+	BUG_ON(entity == NULL);
+	if (entity->my_sched_data == NULL)
+		ioq = container_of(entity, struct io_queue, entity);
+	return ioq;
+}
+
+/**
+ * io_entity_of - get an entity from a node.
+ * @node: the node field of the entity.
+ *
+ * Convert a node pointer to the relative entity.  This is used only
+ * to simplify the logic of some functions and not as the generic
+ * conversion mechanism because, e.g., in the tree walking functions,
+ * the check for a %NULL value would be redundant.
+ */
+static inline struct io_entity *io_entity_of(struct rb_node *node)
+{
+	struct io_entity *entity = NULL;
+
+	if (node != NULL)
+		entity = rb_entry(node, struct io_entity, rb_node);
+
+	return entity;
+}
+
+/**
+ * bfq_remove - remove an entity from a tree.
+ * @root: the tree root.
+ * @entity: the entity to remove.
+ */
+static inline void bfq_remove(struct rb_root *root, struct io_entity *entity)
+{
+	BUG_ON(entity->tree != root);
+
+	entity->tree = NULL;
+	rb_erase(&entity->rb_node, root);
+}
+
+/**
+ * bfq_idle_remove - remove an entity from the idle tree.
+ * @st: the service tree of the owning @entity.
+ * @entity: the entity being removed.
+ */
+static void bfq_idle_remove(struct io_service_tree *st,
+				struct io_entity *entity)
+{
+	struct rb_node *next;
+
+	BUG_ON(entity->tree != &st->idle);
+
+	if (entity == st->first_idle) {
+		next = rb_next(&entity->rb_node);
+		st->first_idle = io_entity_of(next);
+	}
+
+	if (entity == st->last_idle) {
+		next = rb_prev(&entity->rb_node);
+		st->last_idle = io_entity_of(next);
+	}
+
+	bfq_remove(&st->idle, entity);
+}
+
+/**
+ * bfq_insert - generic tree insertion.
+ * @root: tree root.
+ * @entity: entity to insert.
+ *
+ * This is used for the idle and the active tree, since they are both
+ * ordered by finish time.
+ */
+static void bfq_insert(struct rb_root *root, struct io_entity *entity)
+{
+	struct io_entity *entry;
+	struct rb_node **node = &root->rb_node;
+	struct rb_node *parent = NULL;
+
+	BUG_ON(entity->tree != NULL);
+
+	while (*node != NULL) {
+		parent = *node;
+		entry = rb_entry(parent, struct io_entity, rb_node);
+
+		if (bfq_gt(entry->finish, entity->finish))
+			node = &parent->rb_left;
+		else
+			node = &parent->rb_right;
+	}
+
+	rb_link_node(&entity->rb_node, parent, node);
+	rb_insert_color(&entity->rb_node, root);
+
+	entity->tree = root;
+}
+
+/**
+ * bfq_update_min - update the min_start field of a entity.
+ * @entity: the entity to update.
+ * @node: one of its children.
+ *
+ * This function is called when @entity may store an invalid value for
+ * min_start due to updates to the active tree.  The function  assumes
+ * that the subtree rooted at @node (which may be its left or its right
+ * child) has a valid min_start value.
+ */
+static inline void bfq_update_min(struct io_entity *entity,
+					struct rb_node *node)
+{
+	struct io_entity *child;
+
+	if (node != NULL) {
+		child = rb_entry(node, struct io_entity, rb_node);
+		if (bfq_gt(entity->min_start, child->min_start))
+			entity->min_start = child->min_start;
+	}
+}
+
+/**
+ * bfq_update_active_node - recalculate min_start.
+ * @node: the node to update.
+ *
+ * @node may have changed position or one of its children may have moved,
+ * this function updates its min_start value.  The left and right subtrees
+ * are assumed to hold a correct min_start value.
+ */
+static inline void bfq_update_active_node(struct rb_node *node)
+{
+	struct io_entity *entity = rb_entry(node, struct io_entity, rb_node);
+
+	entity->min_start = entity->start;
+	bfq_update_min(entity, node->rb_right);
+	bfq_update_min(entity, node->rb_left);
+}
+
+/**
+ * bfq_update_active_tree - update min_start for the whole active tree.
+ * @node: the starting node.
+ *
+ * @node must be the deepest modified node after an update.  This function
+ * updates its min_start using the values held by its children, assuming
+ * that they did not change, and then updates all the nodes that may have
+ * changed in the path to the root.  The only nodes that may have changed
+ * are the ones in the path or their siblings.
+ */
+static void bfq_update_active_tree(struct rb_node *node)
+{
+	struct rb_node *parent;
+
+up:
+	bfq_update_active_node(node);
+
+	parent = rb_parent(node);
+	if (parent == NULL)
+		return;
+
+	if (node == parent->rb_left && parent->rb_right != NULL)
+		bfq_update_active_node(parent->rb_right);
+	else if (parent->rb_left != NULL)
+		bfq_update_active_node(parent->rb_left);
+
+	node = parent;
+	goto up;
+}
+
+/**
+ * bfq_active_insert - insert an entity in the active tree of its group/device.
+ * @st: the service tree of the entity.
+ * @entity: the entity being inserted.
+ *
+ * The active tree is ordered by finish time, but an extra key is kept
+ * per each node, containing the minimum value for the start times of
+ * its children (and the node itself), so it's possible to search for
+ * the eligible node with the lowest finish time in logarithmic time.
+ */
+static void bfq_active_insert(struct io_service_tree *st,
+					struct io_entity *entity)
+{
+	struct rb_node *node = &entity->rb_node;
+
+	bfq_insert(&st->active, entity);
+
+	if (node->rb_left != NULL)
+		node = node->rb_left;
+	else if (node->rb_right != NULL)
+		node = node->rb_right;
+
+	bfq_update_active_tree(node);
+}
+
+static void bfq_get_entity(struct io_entity *entity)
+{
+	struct io_queue *ioq = io_entity_to_ioq(entity);
+
+	if (ioq)
+		elv_get_ioq(ioq);
+}
+
+static void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->ioprio = entity->new_ioprio;
+	entity->ioprio_class = entity->new_ioprio_class;
+	entity->sched_data = &iog->sched_data;
+}
+
+/**
+ * bfq_find_deepest - find the deepest node that an extraction can modify.
+ * @node: the node being removed.
+ *
+ * Do the first step of an extraction in an rb tree, looking for the
+ * node that will replace @node, and returning the deepest node that
+ * the following modifications to the tree can touch.  If @node is the
+ * last node in the tree return %NULL.
+ */
+static struct rb_node *bfq_find_deepest(struct rb_node *node)
+{
+	struct rb_node *deepest;
+
+	if (node->rb_right == NULL && node->rb_left == NULL)
+		deepest = rb_parent(node);
+	else if (node->rb_right == NULL)
+		deepest = node->rb_left;
+	else if (node->rb_left == NULL)
+		deepest = node->rb_right;
+	else {
+		deepest = rb_next(node);
+		if (deepest->rb_right != NULL)
+			deepest = deepest->rb_right;
+		else if (rb_parent(deepest) != node)
+			deepest = rb_parent(deepest);
+	}
+
+	return deepest;
+}
+
+/**
+ * bfq_active_remove - remove an entity from the active tree.
+ * @st: the service_tree containing the tree.
+ * @entity: the entity being removed.
+ */
+static void bfq_active_remove(struct io_service_tree *st,
+				struct io_entity *entity)
+{
+	struct rb_node *node;
+
+	node = bfq_find_deepest(&entity->rb_node);
+	bfq_remove(&st->active, entity);
+
+	if (node != NULL)
+		bfq_update_active_tree(node);
+}
+
+/**
+ * bfq_idle_insert - insert an entity into the idle tree.
+ * @st: the service tree containing the tree.
+ * @entity: the entity to insert.
+ */
+static void bfq_idle_insert(struct io_service_tree *st,
+					struct io_entity *entity)
+{
+	struct io_entity *first_idle = st->first_idle;
+	struct io_entity *last_idle = st->last_idle;
+
+	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
+		st->first_idle = entity;
+	if (last_idle == NULL || bfq_gt(entity->finish, last_idle->finish))
+		st->last_idle = entity;
+
+	bfq_insert(&st->idle, entity);
+}
+
+/**
+ * bfq_forget_entity - remove an entity from the wfq trees.
+ * @st: the service tree.
+ * @entity: the entity being removed.
+ *
+ * Update the device status and forget everything about @entity, putting
+ * the device reference to it, if it is a queue.  Entities belonging to
+ * groups are not refcounted.
+ */
+static void bfq_forget_entity(struct io_service_tree *st,
+				struct io_entity *entity)
+{
+	struct io_queue *ioq = NULL;
+
+	BUG_ON(!entity->on_st);
+	entity->on_st = 0;
+	st->wsum -= entity->weight;
+	ioq = io_entity_to_ioq(entity);
+	if (!ioq)
+		return;
+	elv_put_ioq(ioq);
+}
+
+/**
+ * bfq_put_idle_entity - release the idle tree ref of an entity.
+ * @st: service tree for the entity.
+ * @entity: the entity being released.
+ */
+static void bfq_put_idle_entity(struct io_service_tree *st,
+				struct io_entity *entity)
+{
+	bfq_idle_remove(st, entity);
+	bfq_forget_entity(st, entity);
+}
+
+/**
+ * bfq_forget_idle - update the idle tree if necessary.
+ * @st: the service tree to act upon.
+ *
+ * To preserve the global O(log N) complexity we only remove one entry here;
+ * as the idle tree will not grow indefinitely this can be done safely.
+ */
+static void bfq_forget_idle(struct io_service_tree *st)
+{
+	struct io_entity *first_idle = st->first_idle;
+	struct io_entity *last_idle = st->last_idle;
+
+	if (RB_EMPTY_ROOT(&st->active) && last_idle != NULL &&
+	    !bfq_gt(last_idle->finish, st->vtime)) {
+		/*
+		 * Active tree is empty. Pull back vtime to finish time of
+		 * last idle entity on idle tree.
+		 * Rational seems to be that it reduces the possibility of
+		 * vtime wraparound (bfq_gt(V-F) < 0).
+		 */
+		st->vtime = last_idle->finish;
+	}
+
+	if (first_idle != NULL && !bfq_gt(first_idle->finish, st->vtime))
+		bfq_put_idle_entity(st, first_idle);
+}
+
+
+static struct io_service_tree *
+__bfq_entity_update_prio(struct io_service_tree *old_st,
+				struct io_entity *entity)
+{
+	struct io_service_tree *new_st = old_st;
+	struct io_queue *ioq = io_entity_to_ioq(entity);
+
+	if (entity->ioprio_changed) {
+		old_st->wsum -= entity->weight;
+		entity->ioprio = entity->new_ioprio;
+		entity->ioprio_class = entity->new_ioprio_class;
+		entity->weight = entity->new_weight;
+		entity->ioprio_changed = 0;
+
+		/*
+		 * Also update the scaled budget for ioq. Group will get the
+		 * updated budget once ioq is selected to run next.
+		 */
+		if (ioq) {
+			struct elv_fq_data *efqd = ioq->efqd;
+			/*
+			 * elv_prio_to_slice() is defined in later patches
+			 * where a slice length is calculated from the
+			 * ioprio of the queue.
+			 */
+			entity->budget = elv_prio_to_slice(efqd, ioq);
+		}
+
+		/*
+		 * NOTE: here we may be changing the weight too early,
+		 * this will cause unfairness.  The correct approach
+		 * would have required additional complexity to defer
+		 * weight changes to the proper time instants (i.e.,
+		 * when entity->finish <= old_st->vtime).
+		 */
+		new_st = io_entity_service_tree(entity);
+		new_st->wsum += entity->weight;
+
+		if (new_st != old_st)
+			entity->start = new_st->vtime;
+	}
+
+	return new_st;
+}
+
+/**
+ * bfq_update_vtime - update vtime if necessary.
+ * @st: the service tree to act upon.
+ *
+ * If necessary update the service tree vtime to have at least one
+ * eligible entity, skipping to its start time.  Assumes that the
+ * active tree of the device is not empty.
+ *
+ * NOTE: this hierarchical implementation updates vtimes quite often,
+ * we may end up with reactivated tasks getting timestamps after a
+ * vtime skip done because we needed a ->first_active entity on some
+ * intermediate node.
+ */
+static void bfq_update_vtime(struct io_service_tree *st)
+{
+	struct io_entity *entry;
+	struct rb_node *node = st->active.rb_node;
+
+	entry = rb_entry(node, struct io_entity, rb_node);
+	if (bfq_gt(entry->min_start, st->vtime)) {
+		st->vtime = entry->min_start;
+		bfq_forget_idle(st);
+	}
+}
+
+/**
+ * bfq_first_active - find the eligible entity with the smallest finish time
+ * @st: the service tree to select from.
+ *
+ * This function searches the first schedulable entity, starting from the
+ * root of the tree and going on the left every time on this side there is
+ * a subtree with at least one eligible (start <= vtime) entity.  The path
+ * on the right is followed only if a) the left subtree contains no eligible
+ * entities and b) no eligible entity has been found yet.
+ */
+static struct io_entity *bfq_first_active_entity(struct io_service_tree *st)
+{
+	struct io_entity *entry, *first = NULL;
+	struct rb_node *node = st->active.rb_node;
+
+	while (node != NULL) {
+		entry = rb_entry(node, struct io_entity, rb_node);
+left:
+		if (!bfq_gt(entry->start, st->vtime))
+			first = entry;
+
+		BUG_ON(bfq_gt(entry->min_start, st->vtime));
+
+		if (node->rb_left != NULL) {
+			entry = rb_entry(node->rb_left,
+					 struct io_entity, rb_node);
+			if (!bfq_gt(entry->min_start, st->vtime)) {
+				node = node->rb_left;
+				goto left;
+			}
+		}
+		if (first != NULL)
+			break;
+		node = node->rb_right;
+	}
+
+	BUG_ON(first == NULL && !RB_EMPTY_ROOT(&st->active));
+	return first;
+}
+
+/**
+ * __bfq_lookup_next_entity - return the first eligible entity in @st.
+ * @st: the service tree.
+ *
+ * Update the virtual time in @st and return the first eligible entity
+ * it contains.
+ */
+static struct io_entity *__bfq_lookup_next_entity(struct io_service_tree *st)
+{
+	struct io_entity *entity;
+
+	if (RB_EMPTY_ROOT(&st->active))
+		return NULL;
+
+	bfq_update_vtime(st);
+	entity = bfq_first_active_entity(st);
+	BUG_ON(bfq_gt(entity->start, st->vtime));
+
+	return entity;
+}
+
+/**
+ * bfq_lookup_next_entity - return the first eligible entity in @sd.
+ * @sd: the sched_data.
+ * @extract: if true the returned entity will be also extracted from @sd.
+ *
+ * NOTE: since we cache the next_active entity at each level of the
+ * hierarchy, the complexity of the lookup can be decreased with
+ * absolutely no effort just returning the cached next_active value;
+ * we prefer to do full lookups to test the consistency of * the data
+ * structures.
+ */
+static struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
+						 int extract)
+{
+	struct io_service_tree *st = sd->service_tree;
+	struct io_entity *entity;
+	int i;
+
+	/*
+	 * We should not call lookup when an entity is active, as doing lookup
+	 * can result in an erroneous vtime jump.
+	 */
+	BUG_ON(sd->active_entity != NULL);
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++, st++) {
+		entity = __bfq_lookup_next_entity(st);
+		if (entity != NULL) {
+			if (extract) {
+				bfq_active_remove(st, entity);
+				sd->active_entity = entity;
+			}
+			break;
+		}
+	}
+
+	return entity;
+}
+
+/**
+ * __bfq_activate_entity - activate an entity.
+ * @entity: the entity being activated.
+ *
+ * Called whenever an entity is activated, i.e., it is not active and one
+ * of its children receives a new request, or has to be reactivated due to
+ * budget exhaustion.  It uses the current budget of the entity (and the
+ * service received if @entity is active) of the queue to calculate its
+ * timestamps.
+ */
+static void __bfq_activate_entity(struct io_entity *entity)
+{
+	struct io_sched_data *sd = entity->sched_data;
+	struct io_service_tree *st = io_entity_service_tree(entity);
+
+	if (entity == sd->active_entity) {
+		BUG_ON(entity->tree != NULL);
+		/*
+		 * If we are requeueing the current entity we have
+		 * to take care of not charging to it service it has
+		 * not received.
+		 */
+		bfq_calc_finish(entity, entity->service);
+		entity->start = entity->finish;
+		sd->active_entity = NULL;
+	} else if (entity->tree == &st->active) {
+		/*
+		 * Requeueing an entity due to a change of some
+		 * next_active entity below it.  We reuse the old
+		 * start time.
+		 */
+		bfq_active_remove(st, entity);
+	} else if (entity->tree == &st->idle) {
+		/*
+		 * Must be on the idle tree, bfq_idle_remove() will
+		 * check for that.
+		 */
+		bfq_idle_remove(st, entity);
+		entity->start = bfq_gt(st->vtime, entity->finish) ?
+				       st->vtime : entity->finish;
+	} else {
+		/*
+		 * The finish time of the entity may be invalid, and
+		 * it is in the past for sure, otherwise the queue
+		 * would have been on the idle tree.
+		 */
+		entity->start = st->vtime;
+		st->wsum += entity->weight;
+		bfq_get_entity(entity);
+
+		BUG_ON(entity->on_st);
+		entity->on_st = 1;
+	}
+
+	st = __bfq_entity_update_prio(st, entity);
+	bfq_calc_finish(entity, entity->budget);
+	bfq_active_insert(st, entity);
+}
+
+/**
+ * bfq_activate_entity - activate an entity.
+ * @entity: the entity to activate.
+ */
+static void bfq_activate_entity(struct io_entity *entity)
+{
+	__bfq_activate_entity(entity);
+}
+
+/**
+ * __bfq_deactivate_entity - deactivate an entity from its service tree.
+ * @entity: the entity to deactivate.
+ * @requeue: if false, the entity will not be put into the idle tree.
+ *
+ * Deactivate an entity, independently from its previous state.  If the
+ * entity was not on a service tree just return, otherwise if it is on
+ * any scheduler tree, extract it from that tree, and if necessary
+ * and if the caller did not specify @requeue, put it on the idle tree.
+ *
+ */
+static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
+{
+	struct io_sched_data *sd = entity->sched_data;
+	struct io_service_tree *st = io_entity_service_tree(entity);
+	int was_active = entity == sd->active_entity;
+	int ret = 0;
+
+	if (!entity->on_st)
+		return 0;
+
+	BUG_ON(was_active && entity->tree != NULL);
+
+	if (was_active) {
+		bfq_calc_finish(entity, entity->service);
+		sd->active_entity = NULL;
+	} else if (entity->tree == &st->active)
+		bfq_active_remove(st, entity);
+	else if (entity->tree == &st->idle)
+		bfq_idle_remove(st, entity);
+	else if (entity->tree != NULL)
+		BUG();
+
+	if (!requeue || !bfq_gt(entity->finish, st->vtime))
+		bfq_forget_entity(st, entity);
+	else
+		bfq_idle_insert(st, entity);
+
+	BUG_ON(sd->active_entity == entity);
+
+	return ret;
+}
+
+/**
+ * bfq_deactivate_entity - deactivate an entity.
+ * @entity: the entity to deactivate.
+ * @requeue: true if the entity can be put on the idle tree
+ */
+static void bfq_deactivate_entity(struct io_entity *entity, int requeue)
+{
+	__bfq_deactivate_entity(entity, requeue);
+}
+
+static void entity_served(struct io_entity *entity, unsigned long served)
+{
+	struct io_service_tree *st;
+
+	st = io_entity_service_tree(entity);
+	entity->service += served;
+	BUG_ON(st->wsum == 0);
+	st->vtime += bfq_delta(served, st->wsum);
+	bfq_forget_idle(st);
+}
+
+/**
+ * io_flush_idle_tree - deactivate any entity on the idle tree of @st.
+ * @st: the service tree being flushed.
+ */
+static void io_flush_idle_tree(struct io_service_tree *st)
+{
+	struct io_entity *entity = st->first_idle;
+
+	for (; entity != NULL; entity = st->first_idle)
+		__bfq_deactivate_entity(entity, 0);
+}
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
new file mode 100644
index 0000000..4554d7f
--- /dev/null
+++ b/block/elevator-fq.h
@@ -0,0 +1,172 @@
+/*
+ * elevator fair queuing Layer. Uses B-WF2Q+ hierarchical scheduler for
+ * fair queuing. Data structures and common functions prototypes.
+ *
+ * Based on ideas and code from CFQ:
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
+
+#ifndef _BFQ_SCHED_H
+#define _BFQ_SCHED_H
+
+#define IO_IOPRIO_CLASSES	3
+
+struct io_entity;
+struct io_queue;
+
+/**
+ * struct io_service_tree - per ioprio_class service tree.
+ * @active: tree for active entities (i.e., those backlogged).
+ * @idle: tree for idle entities (i.e., those not backlogged, with V <= F_i).
+ * @first_idle: idle entity with minimum F_i.
+ * @last_idle: idle entity with maximum F_i.
+ * @vtime: scheduler virtual time.
+ * @wsum: scheduler weight sum; active and idle entities contribute to it.
+ *
+ * Each service tree represents a B-WF2Q+ scheduler on its own.  Each
+ * ioprio_class has its own independent scheduler, and so its own
+ * io_service_tree.  All the fields are protected by the queue lock
+ * of the containing efqd.
+ */
+struct io_service_tree {
+	struct rb_root active;
+	struct rb_root idle;
+
+	struct io_entity *first_idle;
+	struct io_entity *last_idle;
+
+	u64 vtime;
+	unsigned int wsum;
+};
+
+/**
+ * struct io_sched_data - multi-class scheduler.
+ * @active_entity: entity under service.
+ * @next_active: head-of-the-line entity in the scheduler.
+ * @service_tree: array of service trees, one per ioprio_class.
+ *
+ * io_sched_data is the basic scheduler queue.  It supports three
+ * ioprio_classes, and can be used either as a toplevel queue or as
+ * an intermediate queue on a hierarchical setup.
+ * @next_active points to the active entity of the sched_data service
+ * trees that will be scheduled next.
+ *
+ * The supported ioprio_classes are the same as in CFQ, in descending
+ * priority order, IOPRIO_CLASS_RT, IOPRIO_CLASS_BE, IOPRIO_CLASS_IDLE.
+ * Requests from higher priority queues are served before all the
+ * requests from lower priority queues; among requests of the same
+ * queue requests are served according to B-WF2Q+.
+ * All the fields are protected by the queue lock of the containing efqd.
+ */
+struct io_sched_data {
+	struct io_entity *active_entity;
+	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
+};
+
+/**
+ * struct io_entity - schedulable entity.
+ * @rb_node: service_tree member.
+ * @on_st: flag, true if the entity is on a tree (either the active or
+ *         the idle one of its service_tree).
+ * @finish: B-WF2Q+ finish timestamp (aka F_i).
+ * @start: B-WF2Q+ start timestamp (aka S_i).
+ * @tree: tree the entity is enqueued into; %NULL if not on a tree.
+ * @min_start: minimum start time of the (active) subtree rooted at
+ *             this entity; used for O(log N) lookups into active trees.
+ * @service: service received during the last round of service.
+ * @budget: budget used to calculate F_i; F_i = S_i + @budget / @weight.
+ * @weight: weight of the queue, calculated as IOPRIO_BE_NR - @ioprio.
+ * @new_weight: when a weight change is requested, the new weight value
+ * @parent: parent entity, for hierarchical scheduling.
+ * @my_sched_data: for non-leaf nodes in the cgroup hierarchy, the
+ *                 associated scheduler queue, %NULL on leaf nodes.
+ * @sched_data: the scheduler queue this entity belongs to.
+ * @ioprio: the ioprio in use.
+ * @new_ioprio: when an ioprio change is requested, the new ioprio value
+ * @ioprio_class: the ioprio_class in use.
+ * @new_ioprio_class: when an ioprio_class change is requested, the new
+ *                    ioprio_class value.
+ * @ioprio_changed: flag, true when the user requested an ioprio or
+ *                  ioprio_class change.
+ *
+ * A io_entity is used to represent either a io_queue (leaf node in the
+ * cgroup hierarchy) or a io_group into the upper level scheduler.  Each
+ * entity belongs to the sched_data of the parent group in the cgroup
+ * hierarchy.  Non-leaf entities have also their own sched_data, stored
+ * in @my_sched_data.
+ *
+ * Each entity stores independently its priority values; this would allow
+ * different weights on different devices, but this functionality is not
+ * exported to userspace by now.  Priorities are updated lazily, first
+ * storing the new values into the new_* fields, then setting the
+ * @ioprio_changed flag.  As soon as there is a transition in the entity
+ * state that allows the priority update to take place the effective and
+ * the requested priority values are synchronized.
+ *
+ * The weight value is calculated from the ioprio to export the same
+ * interface as CFQ.
+ *
+ * All the fields are protected by the queue lock of the containing efqd.
+ */
+struct io_entity {
+	struct rb_node rb_node;
+
+	int on_st;
+
+	u64 finish;
+	u64 start;
+
+	struct rb_root *tree;
+
+	u64 min_start;
+
+	unsigned long service, budget;
+	unsigned int weight, new_weight;
+
+	struct io_entity *parent;
+
+	struct io_sched_data *my_sched_data;
+	struct io_sched_data *sched_data;
+
+	unsigned short ioprio, new_ioprio;
+	unsigned short ioprio_class, new_ioprio_class;
+
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
+
+	/* Pointer to generic elevator fair queuing data structure */
+	struct elv_fq_data *efqd;
+};
+
+struct io_group {
+	struct io_sched_data sched_data;
+};
+
+static inline struct io_service_tree *
+io_entity_service_tree(struct io_entity *entity)
+{
+	struct io_sched_data *sched_data = entity->sched_data;
+	unsigned int idx = entity->ioprio_class - 1;
+
+	BUG_ON(idx >= IO_IOPRIO_CLASSES);
+	BUG_ON(sched_data == NULL);
+
+	return sched_data->service_tree + idx;
+}
+#endif /* _BFQ_SCHED_H */
-- 
1.6.0.6
