From: paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC RESEND 04/14] block,
	bfq: add full hierarchical scheduling and cgroups support
Date: Tue, 27 May 2014 14:42:28 +0200
Message-ID: <1401194558-5283-5-git-send-email-paolo.valente@unimore.it>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401194558-5283-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Complete support for full hierarchical scheduling, with a cgroups
interface. The name of the new subsystem is bfqio.

Weights can be assigned explicitly to groups and processes through the
cgroups interface, differently from what happens, for single
processes, if the cgroups interface is not used (as explained in the
description of patch 2). In particular, since each node has a full
scheduler, each group can be assigned its own weight.

Signed-off-by: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-cgroup.c            | 891 ++++++++++++++++++++++++++++++++++++++++++
 block/bfq-iosched.c           |  66 ++--
 block/bfq-sched.c             |  64 ++-
 block/bfq.h                   | 122 +++++-
 include/linux/cgroup_subsys.h |   4 +
 5 files changed, 1099 insertions(+), 48 deletions(-)
 create mode 100644 block/bfq-cgroup.c

diff --git a/block/bfq-cgroup.c b/block/bfq-cgroup.c
new file mode 100644
index 0000000..00a7a1b
--- /dev/null
+++ b/block/bfq-cgroup.c
@@ -0,0 +1,891 @@
+/*
+ * BFQ: CGROUPS support.
+ *
+ * Based on ideas and code from CFQ:
+ * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
+ *
+ * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
+ *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
+ *
+ * Licensed under the GPL-2 as detailed in the accompanying COPYING.BFQ
+ * file.
+ */
+
+#ifdef CONFIG_CGROUP_BFQIO
+
+static DEFINE_MUTEX(bfqio_mutex);
+
+static bool bfqio_is_removed(struct bfqio_cgroup *bgrp)
+{
+	return bgrp ? !bgrp->online : false;
+}
+
+static struct bfqio_cgroup bfqio_root_cgroup = {
+	.weight = BFQ_DEFAULT_GRP_WEIGHT,
+	.ioprio = BFQ_DEFAULT_GRP_IOPRIO,
+	.ioprio_class = BFQ_DEFAULT_GRP_CLASS,
+};
+
+static inline void bfq_init_entity(struct bfq_entity *entity,
+				   struct bfq_group *bfqg)
+{
+	entity->weight = entity->new_weight;
+	entity->orig_weight = entity->new_weight;
+	entity->ioprio = entity->new_ioprio;
+	entity->ioprio_class = entity->new_ioprio_class;
+	entity->parent = bfqg->my_entity;
+	entity->sched_data = &bfqg->sched_data;
+}
+
+static struct bfqio_cgroup *css_to_bfqio(struct cgroup_subsys_state *css)
+{
+	return css ? container_of(css, struct bfqio_cgroup, css) : NULL;
+}
+
+/*
+ * Search the bfq_group for bfqd into the hash table (by now only a list)
+ * of bgrp.  Must be called under rcu_read_lock().
+ */
+static struct bfq_group *bfqio_lookup_group(struct bfqio_cgroup *bgrp,
+					    struct bfq_data *bfqd)
+{
+	struct bfq_group *bfqg;
+	void *key;
+
+	hlist_for_each_entry_rcu(bfqg, &bgrp->group_data, group_node) {
+		key = rcu_dereference(bfqg->bfqd);
+		if (key == bfqd)
+			return bfqg;
+	}
+
+	return NULL;
+}
+
+static inline void bfq_group_init_entity(struct bfqio_cgroup *bgrp,
+					 struct bfq_group *bfqg)
+{
+	struct bfq_entity *entity = &bfqg->entity;
+
+	/*
+	 * If the weight of the entity has never been set via the sysfs
+	 * interface, then bgrp->weight == 0. In this case we initialize
+	 * the weight from the current ioprio value. Otherwise, the group
+	 * weight, if set, has priority over the ioprio value.
+	 */
+	if (bgrp->weight == 0) {
+		entity->new_weight = bfq_ioprio_to_weight(bgrp->ioprio);
+		entity->new_ioprio = bgrp->ioprio;
+	} else {
+		entity->new_weight = bgrp->weight;
+		entity->new_ioprio = bfq_weight_to_ioprio(bgrp->weight);
+	}
+	entity->orig_weight = entity->weight = entity->new_weight;
+	entity->ioprio = entity->new_ioprio;
+	entity->ioprio_class = entity->new_ioprio_class = bgrp->ioprio_class;
+	entity->my_sched_data = &bfqg->sched_data;
+}
+
+static inline void bfq_group_set_parent(struct bfq_group *bfqg,
+					struct bfq_group *parent)
+{
+	struct bfq_entity *entity;
+
+	entity = &bfqg->entity;
+	entity->parent = parent->my_entity;
+	entity->sched_data = &parent->sched_data;
+}
+
+/**
+ * bfq_group_chain_alloc - allocate a chain of groups.
+ * @bfqd: queue descriptor.
+ * @css: the leaf cgroup_subsys_state this chain starts from.
+ *
+ * Allocate a chain of groups starting from the one belonging to
+ * @cgroup up to the root cgroup.  Stop if a cgroup on the chain
+ * to the root has already an allocated group on @bfqd.
+ */
+static struct bfq_group *bfq_group_chain_alloc(struct bfq_data *bfqd,
+					       struct cgroup_subsys_state *css)
+{
+	struct bfqio_cgroup *bgrp;
+	struct bfq_group *bfqg, *prev = NULL, *leaf = NULL;
+
+	for (; css != NULL; css = css->parent) {
+		bgrp = css_to_bfqio(css);
+
+		bfqg = bfqio_lookup_group(bgrp, bfqd);
+		if (bfqg != NULL) {
+			/*
+			 * All the cgroups in the path from there to the
+			 * root must have a bfq_group for bfqd, so we don't
+			 * need any more allocations.
+			 */
+			break;
+		}
+
+		bfqg = kzalloc(sizeof(*bfqg), GFP_ATOMIC);
+		if (bfqg == NULL)
+			goto cleanup;
+
+		bfq_group_init_entity(bgrp, bfqg);
+		bfqg->my_entity = &bfqg->entity;
+
+		if (leaf == NULL) {
+			leaf = bfqg;
+			prev = leaf;
+		} else {
+			bfq_group_set_parent(prev, bfqg);
+			/*
+			 * Build a list of allocated nodes using the bfqd
+			 * filed, that is still unused and will be
+			 * initialized only after the node will be
+			 * connected.
+			 */
+			prev->bfqd = bfqg;
+			prev = bfqg;
+		}
+	}
+
+	return leaf;
+
+cleanup:
+	while (leaf != NULL) {
+		prev = leaf;
+		leaf = leaf->bfqd;
+		kfree(prev);
+	}
+
+	return NULL;
+}
+
+/**
+ * bfq_group_chain_link - link an allocated group chain to a cgroup
+ *                        hierarchy.
+ * @bfqd: the queue descriptor.
+ * @css: the leaf cgroup_subsys_state to start from.
+ * @leaf: the leaf group (to be associated to @cgroup).
+ *
+ * Try to link a chain of groups to a cgroup hierarchy, connecting the
+ * nodes bottom-up, so we can be sure that when we find a cgroup in the
+ * hierarchy that already as a group associated to @bfqd all the nodes
+ * in the path to the root cgroup have one too.
+ *
+ * On locking: the queue lock protects the hierarchy (there is a hierarchy
+ * per device) while the bfqio_cgroup lock protects the list of groups
+ * belonging to the same cgroup.
+ */
+static void bfq_group_chain_link(struct bfq_data *bfqd,
+				 struct cgroup_subsys_state *css,
+				 struct bfq_group *leaf)
+{
+	struct bfqio_cgroup *bgrp;
+	struct bfq_group *bfqg, *next, *prev = NULL;
+	unsigned long flags;
+
+	assert_spin_locked(bfqd->queue->queue_lock);
+
+	for (; css != NULL && leaf != NULL; css = css->parent) {
+		bgrp = css_to_bfqio(css);
+		next = leaf->bfqd;
+
+		bfqg = bfqio_lookup_group(bgrp, bfqd);
+
+		spin_lock_irqsave(&bgrp->lock, flags);
+
+		rcu_assign_pointer(leaf->bfqd, bfqd);
+		hlist_add_head_rcu(&leaf->group_node, &bgrp->group_data);
+		hlist_add_head(&leaf->bfqd_node, &bfqd->group_list);
+
+		spin_unlock_irqrestore(&bgrp->lock, flags);
+
+		prev = leaf;
+		leaf = next;
+	}
+
+	if (css != NULL && prev != NULL) {
+		bgrp = css_to_bfqio(css);
+		bfqg = bfqio_lookup_group(bgrp, bfqd);
+		bfq_group_set_parent(prev, bfqg);
+	}
+}
+
+/**
+ * bfq_find_alloc_group - return the group associated to @bfqd in @cgroup.
+ * @bfqd: queue descriptor.
+ * @cgroup: cgroup being searched for.
+ *
+ * Return a group associated to @bfqd in @cgroup, allocating one if
+ * necessary.  When a group is returned all the cgroups in the path
+ * to the root have a group associated to @bfqd.
+ *
+ * If the allocation fails, return the root group: this breaks guarantees
+ * but is a safe fallback.  If this loss becomes a problem it can be
+ * mitigated using the equivalent weight (given by the product of the
+ * weights of the groups in the path from @group to the root) in the
+ * root scheduler.
+ *
+ * We allocate all the missing nodes in the path from the leaf cgroup
+ * to the root and we connect the nodes only after all the allocations
+ * have been successful.
+ */
+static struct bfq_group *bfq_find_alloc_group(struct bfq_data *bfqd,
+					      struct cgroup_subsys_state *css)
+{
+	struct bfqio_cgroup *bgrp = css_to_bfqio(css);
+	struct bfq_group *bfqg;
+
+	bfqg = bfqio_lookup_group(bgrp, bfqd);
+	if (bfqg != NULL)
+		return bfqg;
+
+	bfqg = bfq_group_chain_alloc(bfqd, css);
+	if (bfqg != NULL)
+		bfq_group_chain_link(bfqd, css, bfqg);
+	else
+		bfqg = bfqd->root_group;
+
+	return bfqg;
+}
+
+/**
+ * bfq_bfqq_move - migrate @bfqq to @bfqg.
+ * @bfqd: queue descriptor.
+ * @bfqq: the queue to move.
+ * @entity: @bfqq's entity.
+ * @bfqg: the group to move to.
+ *
+ * Move @bfqq to @bfqg, deactivating it from its old group and reactivating
+ * it on the new one.  Avoid putting the entity on the old group idle tree.
+ *
+ * Must be called under the queue lock; the cgroup owning @bfqg must
+ * not disappear (by now this just means that we are called under
+ * rcu_read_lock()).
+ */
+static void bfq_bfqq_move(struct bfq_data *bfqd, struct bfq_queue *bfqq,
+			  struct bfq_entity *entity, struct bfq_group *bfqg)
+{
+	int busy, resume;
+
+	busy = bfq_bfqq_busy(bfqq);
+	resume = !RB_EMPTY_ROOT(&bfqq->sort_list);
+
+	if (busy) {
+		if (!resume)
+			bfq_del_bfqq_busy(bfqd, bfqq, 0);
+		else
+			bfq_deactivate_bfqq(bfqd, bfqq, 0);
+	} else if (entity->on_st)
+		bfq_put_idle_entity(bfq_entity_service_tree(entity), entity);
+
+	/*
+	 * Here we use a reference to bfqg.  We don't need a refcounter
+	 * as the cgroup reference will not be dropped, so that its
+	 * destroy() callback will not be invoked.
+	 */
+	entity->parent = bfqg->my_entity;
+	entity->sched_data = &bfqg->sched_data;
+
+	if (busy && resume)
+		bfq_activate_bfqq(bfqd, bfqq);
+
+	if (bfqd->in_service_queue == NULL && !bfqd->rq_in_driver)
+		bfq_schedule_dispatch(bfqd);
+}
+
+/**
+ * __bfq_bic_change_cgroup - move @bic to @cgroup.
+ * @bfqd: the queue descriptor.
+ * @bic: the bic to move.
+ * @cgroup: the cgroup to move to.
+ *
+ * Move bic to cgroup, assuming that bfqd->queue is locked; the caller
+ * has to make sure that the reference to cgroup is valid across the call.
+ *
+ * NOTE: an alternative approach might have been to store the current
+ * cgroup in bfqq and getting a reference to it, reducing the lookup
+ * time here, at the price of slightly more complex code.
+ */
+static struct bfq_group *__bfq_bic_change_cgroup(struct bfq_data *bfqd,
+						struct bfq_io_cq *bic,
+						struct cgroup_subsys_state *css)
+{
+	struct bfq_queue *async_bfqq = bic_to_bfqq(bic, 0);
+	struct bfq_queue *sync_bfqq = bic_to_bfqq(bic, 1);
+	struct bfq_entity *entity;
+	struct bfq_group *bfqg;
+	struct bfqio_cgroup *bgrp;
+
+	bgrp = css_to_bfqio(css);
+
+	bfqg = bfq_find_alloc_group(bfqd, css);
+	if (async_bfqq != NULL) {
+		entity = &async_bfqq->entity;
+
+		if (entity->sched_data != &bfqg->sched_data) {
+			bic_set_bfqq(bic, NULL, 0);
+			bfq_log_bfqq(bfqd, async_bfqq,
+				     "bic_change_group: %p %d",
+				     async_bfqq, atomic_read(&async_bfqq->ref));
+			bfq_put_queue(async_bfqq);
+		}
+	}
+
+	if (sync_bfqq != NULL) {
+		entity = &sync_bfqq->entity;
+		if (entity->sched_data != &bfqg->sched_data)
+			bfq_bfqq_move(bfqd, sync_bfqq, entity, bfqg);
+	}
+
+	return bfqg;
+}
+
+/**
+ * bfq_bic_change_cgroup - move @bic to @cgroup.
+ * @bic: the bic being migrated.
+ * @cgroup: the destination cgroup.
+ *
+ * When the task owning @bic is moved to @cgroup, @bic is immediately
+ * moved into its new parent group.
+ */
+static void bfq_bic_change_cgroup(struct bfq_io_cq *bic,
+				  struct cgroup_subsys_state *css)
+{
+	struct bfq_data *bfqd;
+	unsigned long uninitialized_var(flags);
+
+	bfqd = bfq_get_bfqd_locked(&(bic->icq.q->elevator->elevator_data),
+				   &flags);
+	if (bfqd != NULL) {
+		__bfq_bic_change_cgroup(bfqd, bic, css);
+		bfq_put_bfqd_unlock(bfqd, &flags);
+	}
+}
+
+/**
+ * bfq_bic_update_cgroup - update the cgroup of @bic.
+ * @bic: the @bic to update.
+ *
+ * Make sure that @bic is enqueued in the cgroup of the current task.
+ * We need this in addition to moving bics during the cgroup attach
+ * phase because the task owning @bic could be at its first disk
+ * access or we may end up in the root cgroup as the result of a
+ * memory allocation failure and here we try to move to the right
+ * group.
+ *
+ * Must be called under the queue lock.  It is safe to use the returned
+ * value even after the rcu_read_unlock() as the migration/destruction
+ * paths act under the queue lock too.  IOW it is impossible to race with
+ * group migration/destruction and end up with an invalid group as:
+ *   a) here cgroup has not yet been destroyed, nor its destroy callback
+ *      has started execution, as current holds a reference to it,
+ *   b) if it is destroyed after rcu_read_unlock() [after current is
+ *      migrated to a different cgroup] its attach() callback will have
+ *      taken care of remove all the references to the old cgroup data.
+ */
+static struct bfq_group *bfq_bic_update_cgroup(struct bfq_io_cq *bic)
+{
+	struct bfq_data *bfqd = bic_to_bfqd(bic);
+	struct bfq_group *bfqg;
+	struct cgroup_subsys_state *css;
+
+	rcu_read_lock();
+	css = task_css(current, bfqio_cgrp_id);
+	bfqg = __bfq_bic_change_cgroup(bfqd, bic, css);
+	rcu_read_unlock();
+
+	return bfqg;
+}
+
+/**
+ * bfq_flush_idle_tree - deactivate any entity on the idle tree of @st.
+ * @st: the service tree being flushed.
+ */
+static inline void bfq_flush_idle_tree(struct bfq_service_tree *st)
+{
+	struct bfq_entity *entity = st->first_idle;
+
+	for (; entity != NULL; entity = st->first_idle)
+		__bfq_deactivate_entity(entity, 0);
+}
+
+/**
+ * bfq_reparent_leaf_entity - move leaf entity to the root_group.
+ * @bfqd: the device data structure with the root group.
+ * @entity: the entity to move.
+ */
+static inline void bfq_reparent_leaf_entity(struct bfq_data *bfqd,
+					    struct bfq_entity *entity)
+{
+	struct bfq_queue *bfqq = bfq_entity_to_bfqq(entity);
+
+	bfq_bfqq_move(bfqd, bfqq, entity, bfqd->root_group);
+	return;
+}
+
+/**
+ * bfq_reparent_active_entities - move to the root group all active
+ *                                entities.
+ * @bfqd: the device data structure with the root group.
+ * @bfqg: the group to move from.
+ * @st: the service tree with the entities.
+ *
+ * Needs queue_lock to be taken and reference to be valid over the call.
+ */
+static inline void bfq_reparent_active_entities(struct bfq_data *bfqd,
+						struct bfq_group *bfqg,
+						struct bfq_service_tree *st)
+{
+	struct rb_root *active = &st->active;
+	struct bfq_entity *entity = NULL;
+
+	if (!RB_EMPTY_ROOT(&st->active))
+		entity = bfq_entity_of(rb_first(active));
+
+	for (; entity != NULL; entity = bfq_entity_of(rb_first(active)))
+		bfq_reparent_leaf_entity(bfqd, entity);
+
+	if (bfqg->sched_data.in_service_entity != NULL)
+		bfq_reparent_leaf_entity(bfqd,
+			bfqg->sched_data.in_service_entity);
+
+	return;
+}
+
+/**
+ * bfq_destroy_group - destroy @bfqg.
+ * @bgrp: the bfqio_cgroup containing @bfqg.
+ * @bfqg: the group being destroyed.
+ *
+ * Destroy @bfqg, making sure that it is not referenced from its parent.
+ */
+static void bfq_destroy_group(struct bfqio_cgroup *bgrp, struct bfq_group *bfqg)
+{
+	struct bfq_data *bfqd;
+	struct bfq_service_tree *st;
+	struct bfq_entity *entity = bfqg->my_entity;
+	unsigned long uninitialized_var(flags);
+	int i;
+
+	hlist_del(&bfqg->group_node);
+
+	/*
+	 * Empty all service_trees belonging to this group before
+	 * deactivating the group itself.
+	 */
+	for (i = 0; i < BFQ_IOPRIO_CLASSES; i++) {
+		st = bfqg->sched_data.service_tree + i;
+
+		/*
+		 * The idle tree may still contain bfq_queues belonging
+		 * to exited task because they never migrated to a different
+		 * cgroup from the one being destroyed now.  No one else
+		 * can access them so it's safe to act without any lock.
+		 */
+		bfq_flush_idle_tree(st);
+
+		/*
+		 * It may happen that some queues are still active
+		 * (busy) upon group destruction (if the corresponding
+		 * processes have been forced to terminate). We move
+		 * all the leaf entities corresponding to these queues
+		 * to the root_group.
+		 * Also, it may happen that the group has an entity
+		 * in service, which is disconnected from the active
+		 * tree: it must be moved, too.
+		 * There is no need to put the sync queues, as the
+		 * scheduler has taken no reference.
+		 */
+		bfqd = bfq_get_bfqd_locked(&bfqg->bfqd, &flags);
+		if (bfqd != NULL) {
+			bfq_reparent_active_entities(bfqd, bfqg, st);
+			bfq_put_bfqd_unlock(bfqd, &flags);
+		}
+	}
+
+	/*
+	 * We may race with device destruction, take extra care when
+	 * dereferencing bfqg->bfqd.
+	 */
+	bfqd = bfq_get_bfqd_locked(&bfqg->bfqd, &flags);
+	if (bfqd != NULL) {
+		hlist_del(&bfqg->bfqd_node);
+		__bfq_deactivate_entity(entity, 0);
+		bfq_put_async_queues(bfqd, bfqg);
+		bfq_put_bfqd_unlock(bfqd, &flags);
+	}
+
+	/*
+	 * No need to defer the kfree() to the end of the RCU grace
+	 * period: we are called from the destroy() callback of our
+	 * cgroup, so we can be sure that no one is a) still using
+	 * this cgroup or b) doing lookups in it.
+	 */
+	kfree(bfqg);
+}
+
+/**
+ * bfq_disconnect_groups - disconnect @bfqd from all its groups.
+ * @bfqd: the device descriptor being exited.
+ *
+ * When the device exits we just make sure that no lookup can return
+ * the now unused group structures.  They will be deallocated on cgroup
+ * destruction.
+ */
+static void bfq_disconnect_groups(struct bfq_data *bfqd)
+{
+	struct hlist_node *tmp;
+	struct bfq_group *bfqg;
+
+	bfq_log(bfqd, "disconnect_groups beginning");
+	hlist_for_each_entry_safe(bfqg, tmp, &bfqd->group_list, bfqd_node) {
+		hlist_del(&bfqg->bfqd_node);
+
+		__bfq_deactivate_entity(bfqg->my_entity, 0);
+
+		/*
+		 * Don't remove from the group hash, just set an
+		 * invalid key.  No lookups can race with the
+		 * assignment as bfqd is being destroyed; this
+		 * implies also that new elements cannot be added
+		 * to the list.
+		 */
+		rcu_assign_pointer(bfqg->bfqd, NULL);
+
+		bfq_log(bfqd, "disconnect_groups: put async for group %p",
+			bfqg);
+		bfq_put_async_queues(bfqd, bfqg);
+	}
+}
+
+static inline void bfq_free_root_group(struct bfq_data *bfqd)
+{
+	struct bfqio_cgroup *bgrp = &bfqio_root_cgroup;
+	struct bfq_group *bfqg = bfqd->root_group;
+
+	bfq_put_async_queues(bfqd, bfqg);
+
+	spin_lock_irq(&bgrp->lock);
+	hlist_del_rcu(&bfqg->group_node);
+	spin_unlock_irq(&bgrp->lock);
+
+	/*
+	 * No need to synchronize_rcu() here: since the device is gone
+	 * there cannot be any read-side access to its root_group.
+	 */
+	kfree(bfqg);
+}
+
+static struct bfq_group *bfq_alloc_root_group(struct bfq_data *bfqd, int node)
+{
+	struct bfq_group *bfqg;
+	struct bfqio_cgroup *bgrp;
+	int i;
+
+	bfqg = kzalloc_node(sizeof(*bfqg), GFP_KERNEL, node);
+	if (bfqg == NULL)
+		return NULL;
+
+	bfqg->entity.parent = NULL;
+	for (i = 0; i < BFQ_IOPRIO_CLASSES; i++)
+		bfqg->sched_data.service_tree[i] = BFQ_SERVICE_TREE_INIT;
+
+	bgrp = &bfqio_root_cgroup;
+	spin_lock_irq(&bgrp->lock);
+	rcu_assign_pointer(bfqg->bfqd, bfqd);
+	hlist_add_head_rcu(&bfqg->group_node, &bgrp->group_data);
+	spin_unlock_irq(&bgrp->lock);
+
+	return bfqg;
+}
+
+#define SHOW_FUNCTION(__VAR)						\
+static u64 bfqio_cgroup_##__VAR##_read(struct cgroup_subsys_state *css, \
+				       struct cftype *cftype)		\
+{									\
+	struct bfqio_cgroup *bgrp = css_to_bfqio(css);			\
+	u64 ret = -ENODEV;						\
+									\
+	mutex_lock(&bfqio_mutex);					\
+	if (bfqio_is_removed(bgrp))					\
+		goto out_unlock;					\
+									\
+	spin_lock_irq(&bgrp->lock);					\
+	ret = bgrp->__VAR;						\
+	spin_unlock_irq(&bgrp->lock);					\
+									\
+out_unlock:								\
+	mutex_unlock(&bfqio_mutex);					\
+	return ret;							\
+}
+
+SHOW_FUNCTION(weight);
+SHOW_FUNCTION(ioprio);
+SHOW_FUNCTION(ioprio_class);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__VAR, __MIN, __MAX)				\
+static int bfqio_cgroup_##__VAR##_write(struct cgroup_subsys_state *css,\
+					struct cftype *cftype,		\
+					u64 val)			\
+{									\
+	struct bfqio_cgroup *bgrp = css_to_bfqio(css);			\
+	struct bfq_group *bfqg;						\
+	int ret = -EINVAL;						\
+									\
+	if (val < (__MIN) || val > (__MAX))				\
+		return ret;						\
+									\
+	ret = -ENODEV;							\
+	mutex_lock(&bfqio_mutex);					\
+	if (bfqio_is_removed(bgrp))					\
+		goto out_unlock;					\
+	ret = 0;							\
+									\
+	spin_lock_irq(&bgrp->lock);					\
+	bgrp->__VAR = (unsigned short)val;				\
+	hlist_for_each_entry(bfqg, &bgrp->group_data, group_node) {	\
+		/*							\
+		 * Setting the ioprio_changed flag of the entity        \
+		 * to 1 with new_##__VAR == ##__VAR would re-set        \
+		 * the value of the weight to its ioprio mapping.       \
+		 * Set the flag only if necessary.			\
+		 */							\
+		if ((unsigned short)val != bfqg->entity.new_##__VAR) {  \
+			bfqg->entity.new_##__VAR = (unsigned short)val; \
+			/*						\
+			 * Make sure that the above new value has been	\
+			 * stored in bfqg->entity.new_##__VAR before	\
+			 * setting the ioprio_changed flag. In fact,	\
+			 * this flag may be read asynchronously (in	\
+			 * critical sections protected by a different	\
+			 * lock than that held here), and finding this	\
+			 * flag set may cause the execution of the code	\
+			 * for updating parameters whose value may	\
+			 * depend also on bfqg->entity.new_##__VAR (in	\
+			 * __bfq_entity_update_weight_prio).		\
+			 * This barrier makes sure that the new value	\
+			 * of bfqg->entity.new_##__VAR is correctly	\
+			 * seen in that code.				\
+			 */						\
+			smp_wmb();                                      \
+			bfqg->entity.ioprio_changed = 1;                \
+		}							\
+	}								\
+	spin_unlock_irq(&bgrp->lock);					\
+									\
+out_unlock:								\
+	mutex_unlock(&bfqio_mutex);					\
+	return ret;							\
+}
+
+STORE_FUNCTION(weight, BFQ_MIN_WEIGHT, BFQ_MAX_WEIGHT);
+STORE_FUNCTION(ioprio, 0, IOPRIO_BE_NR - 1);
+STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
+#undef STORE_FUNCTION
+
+static struct cftype bfqio_files[] = {
+	{
+		.name = "weight",
+		.read_u64 = bfqio_cgroup_weight_read,
+		.write_u64 = bfqio_cgroup_weight_write,
+	},
+	{
+		.name = "ioprio",
+		.read_u64 = bfqio_cgroup_ioprio_read,
+		.write_u64 = bfqio_cgroup_ioprio_write,
+	},
+	{
+		.name = "ioprio_class",
+		.read_u64 = bfqio_cgroup_ioprio_class_read,
+		.write_u64 = bfqio_cgroup_ioprio_class_write,
+	},
+	{ },	/* terminate */
+};
+
+static struct cgroup_subsys_state *bfqio_create(struct cgroup_subsys_state
+						*parent_css)
+{
+	struct bfqio_cgroup *bgrp;
+
+	if (parent_css != NULL) {
+		bgrp = kzalloc(sizeof(*bgrp), GFP_KERNEL);
+		if (bgrp == NULL)
+			return ERR_PTR(-ENOMEM);
+	} else
+		bgrp = &bfqio_root_cgroup;
+
+	spin_lock_init(&bgrp->lock);
+	INIT_HLIST_HEAD(&bgrp->group_data);
+	bgrp->ioprio = BFQ_DEFAULT_GRP_IOPRIO;
+	bgrp->ioprio_class = BFQ_DEFAULT_GRP_CLASS;
+
+	return &bgrp->css;
+}
+
+/*
+ * We cannot support shared io contexts, as we have no means to support
+ * two tasks with the same ioc in two different groups without major rework
+ * of the main bic/bfqq data structures.  By now we allow a task to change
+ * its cgroup only if it's the only owner of its ioc; the drawback of this
+ * behavior is that a group containing a task that forked using CLONE_IO
+ * will not be destroyed until the tasks sharing the ioc die.
+ */
+static int bfqio_can_attach(struct cgroup_subsys_state *css,
+			    struct cgroup_taskset *tset)
+{
+	struct task_struct *task;
+	struct io_context *ioc;
+	int ret = 0;
+
+	cgroup_taskset_for_each(task, tset) {
+		/*
+		 * task_lock() is needed to avoid races with
+		 * exit_io_context()
+		 */
+		task_lock(task);
+		ioc = task->io_context;
+		if (ioc != NULL && atomic_read(&ioc->nr_tasks) > 1)
+			/*
+			 * ioc == NULL means that the task is either too
+			 * young or exiting: if it has still no ioc the
+			 * ioc can't be shared, if the task is exiting the
+			 * attach will fail anyway, no matter what we
+			 * return here.
+			 */
+			ret = -EINVAL;
+		task_unlock(task);
+		if (ret)
+			break;
+	}
+
+	return ret;
+}
+
+static void bfqio_attach(struct cgroup_subsys_state *css,
+			 struct cgroup_taskset *tset)
+{
+	struct task_struct *task;
+	struct io_context *ioc;
+	struct io_cq *icq;
+
+	/*
+	 * IMPORTANT NOTE: The move of more than one process at a time to a
+	 * new group has not yet been tested.
+	 */
+	cgroup_taskset_for_each(task, tset) {
+		ioc = get_task_io_context(task, GFP_ATOMIC, NUMA_NO_NODE);
+		if (ioc) {
+			/*
+			 * Handle cgroup change here.
+			 */
+			rcu_read_lock();
+			hlist_for_each_entry_rcu(icq, &ioc->icq_list, ioc_node)
+				if (!strncmp(
+					icq->q->elevator->type->elevator_name,
+					"bfq", ELV_NAME_MAX))
+					bfq_bic_change_cgroup(icq_to_bic(icq),
+							      css);
+			rcu_read_unlock();
+			put_io_context(ioc);
+		}
+	}
+}
+
+static void bfqio_destroy(struct cgroup_subsys_state *css)
+{
+	struct bfqio_cgroup *bgrp = css_to_bfqio(css);
+	struct hlist_node *tmp;
+	struct bfq_group *bfqg;
+
+	/*
+	 * Since we are destroying the cgroup, there are no more tasks
+	 * referencing it, and all the RCU grace periods that may have
+	 * referenced it are ended (as the destruction of the parent
+	 * cgroup is RCU-safe); bgrp->group_data will not be accessed by
+	 * anything else and we don't need any synchronization.
+	 */
+	hlist_for_each_entry_safe(bfqg, tmp, &bgrp->group_data, group_node)
+		bfq_destroy_group(bgrp, bfqg);
+
+	kfree(bgrp);
+}
+
+static int bfqio_css_online(struct cgroup_subsys_state *css)
+{
+	struct bfqio_cgroup *bgrp = css_to_bfqio(css);
+
+	mutex_lock(&bfqio_mutex);
+	bgrp->online = true;
+	mutex_unlock(&bfqio_mutex);
+
+	return 0;
+}
+
+static void bfqio_css_offline(struct cgroup_subsys_state *css)
+{
+	struct bfqio_cgroup *bgrp = css_to_bfqio(css);
+
+	mutex_lock(&bfqio_mutex);
+	bgrp->online = false;
+	mutex_unlock(&bfqio_mutex);
+}
+
+struct cgroup_subsys bfqio_cgrp_subsys = {
+	.css_alloc = bfqio_create,
+	.css_online = bfqio_css_online,
+	.css_offline = bfqio_css_offline,
+	.can_attach = bfqio_can_attach,
+	.attach = bfqio_attach,
+	.css_free = bfqio_destroy,
+	.base_cftypes = bfqio_files,
+};
+#else
+static inline void bfq_init_entity(struct bfq_entity *entity,
+				   struct bfq_group *bfqg)
+{
+	entity->weight = entity->new_weight;
+	entity->orig_weight = entity->new_weight;
+	entity->ioprio = entity->new_ioprio;
+	entity->ioprio_class = entity->new_ioprio_class;
+	entity->sched_data = &bfqg->sched_data;
+}
+
+static inline struct bfq_group *
+bfq_bic_update_cgroup(struct bfq_io_cq *bic)
+{
+	struct bfq_data *bfqd = bic_to_bfqd(bic);
+	return bfqd->root_group;
+}
+
+static inline void bfq_bfqq_move(struct bfq_data *bfqd,
+				 struct bfq_queue *bfqq,
+				 struct bfq_entity *entity,
+				 struct bfq_group *bfqg)
+{
+}
+
+static inline void bfq_disconnect_groups(struct bfq_data *bfqd)
+{
+	bfq_put_async_queues(bfqd, bfqd->root_group);
+}
+
+static inline void bfq_free_root_group(struct bfq_data *bfqd)
+{
+	kfree(bfqd->root_group);
+}
+
+static struct bfq_group *bfq_alloc_root_group(struct bfq_data *bfqd, int node)
+{
+	struct bfq_group *bfqg;
+	int i;
+
+	bfqg = kmalloc_node(sizeof(*bfqg), GFP_KERNEL | __GFP_ZERO, node);
+	if (bfqg == NULL)
+		return NULL;
+
+	for (i = 0; i < BFQ_IOPRIO_CLASSES; i++)
+		bfqg->sched_data.service_tree[i] = BFQ_SERVICE_TREE_INIT;
+
+	return bfqg;
+}
+#endif
diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 01a98be..b2cbfce 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -66,14 +66,6 @@
 #include "bfq.h"
 #include "blk.h"
 
-/*
- * Array of async queues for all the processes, one queue
- * per ioprio value per ioprio_class.
- */
-struct bfq_queue *async_bfqq[2][IOPRIO_BE_NR];
-/* Async queue for the idle class (ioprio is ignored) */
-struct bfq_queue *async_idle_bfqq;
-
 /* Max number of dispatches in one round of service. */
 static const int bfq_quantum = 4;
 
@@ -128,6 +120,7 @@ static inline void bfq_schedule_dispatch(struct bfq_data *bfqd);
 
 #include "bfq-ioc.c"
 #include "bfq-sched.c"
+#include "bfq-cgroup.c"
 
 #define bfq_class_idle(bfqq)	((bfqq)->entity.ioprio_class ==\
 				 IOPRIO_CLASS_IDLE)
@@ -1359,6 +1352,7 @@ static void bfq_changed_ioprio(struct bfq_io_cq *bic)
 {
 	struct bfq_data *bfqd;
 	struct bfq_queue *bfqq, *new_bfqq;
+	struct bfq_group *bfqg;
 	unsigned long uninitialized_var(flags);
 	int ioprio = bic->icq.ioc->ioprio;
 
@@ -1373,7 +1367,9 @@ static void bfq_changed_ioprio(struct bfq_io_cq *bic)
 
 	bfqq = bic->bfqq[BLK_RW_ASYNC];
 	if (bfqq != NULL) {
-		new_bfqq = bfq_get_queue(bfqd, BLK_RW_ASYNC, bic,
+		bfqg = container_of(bfqq->entity.sched_data, struct bfq_group,
+				    sched_data);
+		new_bfqq = bfq_get_queue(bfqd, bfqg, BLK_RW_ASYNC, bic,
 					 GFP_ATOMIC);
 		if (new_bfqq != NULL) {
 			bic->bfqq[BLK_RW_ASYNC] = new_bfqq;
@@ -1417,6 +1413,7 @@ static void bfq_init_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq,
 }
 
 static struct bfq_queue *bfq_find_alloc_queue(struct bfq_data *bfqd,
+					      struct bfq_group *bfqg,
 					      int is_sync,
 					      struct bfq_io_cq *bic,
 					      gfp_t gfp_mask)
@@ -1459,6 +1456,7 @@ retry:
 		}
 
 		bfq_init_prio_data(bfqq, bic);
+		bfq_init_entity(&bfqq->entity, bfqg);
 	}
 
 	if (new_bfqq != NULL)
@@ -1468,26 +1466,27 @@ retry:
 }
 
 static struct bfq_queue **bfq_async_queue_prio(struct bfq_data *bfqd,
+					       struct bfq_group *bfqg,
 					       int ioprio_class, int ioprio)
 {
 	switch (ioprio_class) {
 	case IOPRIO_CLASS_RT:
-		return &async_bfqq[0][ioprio];
+		return &bfqg->async_bfqq[0][ioprio];
 	case IOPRIO_CLASS_NONE:
 		ioprio = IOPRIO_NORM;
 		/* fall through */
 	case IOPRIO_CLASS_BE:
-		return &async_bfqq[1][ioprio];
+		return &bfqg->async_bfqq[1][ioprio];
 	case IOPRIO_CLASS_IDLE:
-		return &async_idle_bfqq;
+		return &bfqg->async_idle_bfqq;
 	default:
 		BUG();
 	}
 }
 
 static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd,
-				       int is_sync, struct bfq_io_cq *bic,
-				       gfp_t gfp_mask)
+				       struct bfq_group *bfqg, int is_sync,
+				       struct bfq_io_cq *bic, gfp_t gfp_mask)
 {
 	const int ioprio = IOPRIO_PRIO_DATA(bic->ioprio);
 	const int ioprio_class = IOPRIO_PRIO_CLASS(bic->ioprio);
@@ -1495,12 +1494,13 @@ static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd,
 	struct bfq_queue *bfqq = NULL;
 
 	if (!is_sync) {
-		async_bfqq = bfq_async_queue_prio(bfqd, ioprio_class, ioprio);
+		async_bfqq = bfq_async_queue_prio(bfqd, bfqg, ioprio_class,
+						  ioprio);
 		bfqq = *async_bfqq;
 	}
 
 	if (bfqq == NULL)
-		bfqq = bfq_find_alloc_queue(bfqd, is_sync, bic, gfp_mask);
+		bfqq = bfq_find_alloc_queue(bfqd, bfqg, is_sync, bic, gfp_mask);
 
 	/*
 	 * Pin the queue now that it's allocated, scheduler exit will
@@ -1830,6 +1830,7 @@ static int bfq_set_request(struct request_queue *q, struct request *rq,
 	const int rw = rq_data_dir(rq);
 	const int is_sync = rq_is_sync(rq);
 	struct bfq_queue *bfqq;
+	struct bfq_group *bfqg;
 	unsigned long flags;
 
 	might_sleep_if(gfp_mask & __GFP_WAIT);
@@ -1841,9 +1842,11 @@ static int bfq_set_request(struct request_queue *q, struct request *rq,
 	if (bic == NULL)
 		goto queue_fail;
 
+	bfqg = bfq_bic_update_cgroup(bic);
+
 	bfqq = bic_to_bfqq(bic, is_sync);
 	if (bfqq == NULL || bfqq == &bfqd->oom_bfqq) {
-		bfqq = bfq_get_queue(bfqd, is_sync, bic, gfp_mask);
+		bfqq = bfq_get_queue(bfqd, bfqg, is_sync, bic, gfp_mask);
 		bic_set_bfqq(bic, bfqq, is_sync);
 	}
 
@@ -1937,10 +1940,12 @@ static void bfq_shutdown_timer_wq(struct bfq_data *bfqd)
 static inline void __bfq_put_async_bfqq(struct bfq_data *bfqd,
 					struct bfq_queue **bfqq_ptr)
 {
+	struct bfq_group *root_group = bfqd->root_group;
 	struct bfq_queue *bfqq = *bfqq_ptr;
 
 	bfq_log(bfqd, "put_async_bfqq: %p", bfqq);
 	if (bfqq != NULL) {
+		bfq_bfqq_move(bfqd, bfqq, &bfqq->entity, root_group);
 		bfq_log_bfqq(bfqd, bfqq, "put_async_bfqq: putting %p, %d",
 			     bfqq, atomic_read(&bfqq->ref));
 		bfq_put_queue(bfqq);
@@ -1949,18 +1954,20 @@ static inline void __bfq_put_async_bfqq(struct bfq_data *bfqd,
 }
 
 /*
- * Release the extra reference of the async queues as the device
- * goes away.
+ * Release all the bfqg references to its async queues.  If we are
+ * deallocating the group these queues may still contain requests, so
+ * we reparent them to the root cgroup (i.e., the only one that will
+ * exist for sure until all the requests on a device are gone).
  */
-static void bfq_put_async_queues(struct bfq_data *bfqd)
+static void bfq_put_async_queues(struct bfq_data *bfqd, struct bfq_group *bfqg)
 {
 	int i, j;
 
 	for (i = 0; i < 2; i++)
 		for (j = 0; j < IOPRIO_BE_NR; j++)
-			__bfq_put_async_bfqq(bfqd, &async_bfqq[i][j]);
+			__bfq_put_async_bfqq(bfqd, &bfqg->async_bfqq[i][j]);
 
-	__bfq_put_async_bfqq(bfqd, &async_idle_bfqq);
+	__bfq_put_async_bfqq(bfqd, &bfqg->async_idle_bfqq);
 }
 
 static void bfq_exit_queue(struct elevator_queue *e)
@@ -1976,18 +1983,20 @@ static void bfq_exit_queue(struct elevator_queue *e)
 	list_for_each_entry_safe(bfqq, n, &bfqd->idle_list, bfqq_list)
 		bfq_deactivate_bfqq(bfqd, bfqq, 0);
 
-	bfq_put_async_queues(bfqd);
+	bfq_disconnect_groups(bfqd);
 	spin_unlock_irq(q->queue_lock);
 
 	bfq_shutdown_timer_wq(bfqd);
 
 	synchronize_rcu();
 
+	bfq_free_root_group(bfqd);
 	kfree(bfqd);
 }
 
 static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 {
+	struct bfq_group *bfqg;
 	struct bfq_data *bfqd;
 	struct elevator_queue *eq;
 
@@ -2016,6 +2025,15 @@ static int bfq_init_queue(struct request_queue *q, struct elevator_type *e)
 	q->elevator = eq;
 	spin_unlock_irq(q->queue_lock);
 
+	bfqg = bfq_alloc_root_group(bfqd, q->node);
+	if (bfqg == NULL) {
+		kfree(bfqd);
+		kobject_put(&eq->kobj);
+		return -ENOMEM;
+	}
+
+	bfqd->root_group = bfqg;
+
 	init_timer(&bfqd->idle_slice_timer);
 	bfqd->idle_slice_timer.function = bfq_idle_slice_timer;
 	bfqd->idle_slice_timer.data = (unsigned long)bfqd;
@@ -2279,7 +2297,7 @@ static int __init bfq_init(void)
 		return -ENOMEM;
 
 	elv_register(&iosched_bfq);
-	pr_info("BFQ I/O-scheduler version: v0");
+	pr_info("BFQ I/O-scheduler version: v1");
 
 	return 0;
 }
diff --git a/block/bfq-sched.c b/block/bfq-sched.c
index a9142f5..8801b6c 100644
--- a/block/bfq-sched.c
+++ b/block/bfq-sched.c
@@ -8,6 +8,61 @@
  *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
  */
 
+#ifdef CONFIG_CGROUP_BFQIO
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = entity->parent)
+
+#define for_each_entity_safe(entity, parent) \
+	for (; entity && ({ parent = entity->parent; 1; }); entity = parent)
+
+static struct bfq_entity *bfq_lookup_next_entity(struct bfq_sched_data *sd,
+						 int extract,
+						 struct bfq_data *bfqd);
+
+static inline void bfq_update_budget(struct bfq_entity *next_in_service)
+{
+	struct bfq_entity *bfqg_entity;
+	struct bfq_group *bfqg;
+	struct bfq_sched_data *group_sd;
+
+	group_sd = next_in_service->sched_data;
+
+	bfqg = container_of(group_sd, struct bfq_group, sched_data);
+	/*
+	 * bfq_group's my_entity field is not NULL only if the group
+	 * is not the root group. We must not touch the root entity
+	 * as it must never become an in-service entity.
+	 */
+	bfqg_entity = bfqg->my_entity;
+	if (bfqg_entity != NULL)
+		bfqg_entity->budget = next_in_service->budget;
+}
+
+static int bfq_update_next_in_service(struct bfq_sched_data *sd)
+{
+	struct bfq_entity *next_in_service;
+
+	if (sd->in_service_entity != NULL)
+		/* will update/requeue at the end of service */
+		return 0;
+
+	/*
+	 * NOTE: this can be improved in many ways, such as returning
+	 * 1 (and thus propagating upwards the update) only when the
+	 * budget changes, or caching the bfqq that will be scheduled
+	 * next from this subtree.  By now we worry more about
+	 * correctness than about performance...
+	 */
+	next_in_service = bfq_lookup_next_entity(sd, 0, NULL);
+	sd->next_in_service = next_in_service;
+
+	if (next_in_service != NULL)
+		bfq_update_budget(next_in_service);
+
+	return 1;
+}
+
+#else
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
 
@@ -19,14 +74,10 @@ static inline int bfq_update_next_in_service(struct bfq_sched_data *sd)
 	return 0;
 }
 
-static inline void bfq_check_next_in_service(struct bfq_sched_data *sd,
-					     struct bfq_entity *entity)
-{
-}
-
 static inline void bfq_update_budget(struct bfq_entity *next_in_service)
 {
 }
+#endif
 
 /*
  * Shift for timestamp calculations.  This actually limits the maximum
@@ -842,7 +893,6 @@ static struct bfq_entity *bfq_lookup_next_entity(struct bfq_sched_data *sd,
 		entity = __bfq_lookup_next_entity(st + i, false);
 		if (entity != NULL) {
 			if (extract) {
-				bfq_check_next_in_service(sd, entity);
 				bfq_active_extract(st + i, entity);
 				sd->in_service_entity = entity;
 				sd->next_in_service = NULL;
@@ -866,7 +916,7 @@ static struct bfq_queue *bfq_get_next_queue(struct bfq_data *bfqd)
 	if (bfqd->busy_queues == 0)
 		return NULL;
 
-	sd = &bfqd->sched_data;
+	sd = &bfqd->root_group->sched_data;
 	for (; sd != NULL; sd = entity->my_sched_data) {
 		entity = bfq_lookup_next_entity(sd, 1, bfqd);
 		entity->service = 0;
diff --git a/block/bfq.h b/block/bfq.h
index bd146b6..b982567 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -1,5 +1,5 @@
 /*
- * BFQ-v0 for 3.15.0: data structures and common functions prototypes.
+ * BFQ-v1 for 3.15.0: data structures and common functions prototypes.
  *
  * Based on ideas and code from CFQ:
  * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
@@ -92,7 +92,7 @@ struct bfq_sched_data {
  * @budget: budget used to calculate F_i; F_i = S_i + @budget / @weight.
  * @weight: weight of the queue
  * @parent: parent entity, for hierarchical scheduling.
- * @my_sched_data: for non-leaf nodes in the hierarchy, the
+ * @my_sched_data: for non-leaf nodes in the cgroup hierarchy, the
  *                 associated scheduler queue, %NULL on leaf nodes.
  * @sched_data: the scheduler queue this entity belongs to.
  * @ioprio: the ioprio in use.
@@ -105,10 +105,11 @@ struct bfq_sched_data {
  * @ioprio_changed: flag, true when the user requested a weight, ioprio or
  *                  ioprio_class change.
  *
- * A bfq_entity is used to represent a bfq_queue (leaf node in the upper
- * level scheduler). Each entity belongs to the sched_data of the parent
- * group hierarchy. Non-leaf entities have also their own sched_data,
- * stored in @my_sched_data.
+ * A bfq_entity is used to represent either a bfq_queue (leaf node in the
+ * cgroup hierarchy) or a bfq_group into the upper level scheduler.  Each
+ * entity belongs to the sched_data of the parent group in the cgroup
+ * hierarchy.  Non-leaf entities have also their own sched_data, stored
+ * in @my_sched_data.
  *
  * Each entity stores independently its priority values; this would
  * allow different weights on different devices, but this
@@ -119,13 +120,14 @@ struct bfq_sched_data {
  * update to take place the effective and the requested priority
  * values are synchronized.
  *
- * The weight value is calculated from the ioprio to export the same
- * interface as CFQ.  When dealing with  ``well-behaved'' queues (i.e.,
- * queues that do not spend too much time to consume their budget
- * and have true sequential behavior, and when there are no external
- * factors breaking anticipation) the relative weights at each level
- * of the hierarchy should be guaranteed.  All the fields are
- * protected by the queue lock of the containing bfqd.
+ * Unless cgroups are used, the weight value is calculated from the
+ * ioprio to export the same interface as CFQ.  When dealing with
+ * ``well-behaved'' queues (i.e., queues that do not spend too much
+ * time to consume their budget and have true sequential behavior, and
+ * when there are no external factors breaking anticipation) the
+ * relative weights at each level of the cgroups hierarchy should be
+ * guaranteed.  All the fields are protected by the queue lock of the
+ * containing bfqd.
  */
 struct bfq_entity {
 	struct rb_node rb_node;
@@ -154,6 +156,8 @@ struct bfq_entity {
 	int ioprio_changed;
 };
 
+struct bfq_group;
+
 /**
  * struct bfq_queue - leaf schedulable entity.
  * @ref: reference counter.
@@ -177,7 +181,11 @@ struct bfq_entity {
  * @pid: pid of the process owning the queue, used for logging purposes.
  *
  * A bfq_queue is a leaf request queue; it can be associated with an
- * io_context or more, if it is async.
+ * io_context or more, if it is async. @cgroup holds a reference to the
+ * cgroup, to be sure that it does not disappear while a bfqq still
+ * references it (mostly to avoid races between request issuing and task
+ * migration followed by cgroup destruction). All the fields are protected
+ * by the queue lock of the containing bfqd.
  */
 struct bfq_queue {
 	atomic_t ref;
@@ -244,7 +252,7 @@ enum bfq_device_speed {
 /**
  * struct bfq_data - per device data structure.
  * @queue: request queue for the managed device.
- * @sched_data: root @bfq_sched_data for the device.
+ * @root_group: root bfq_group for the device.
  * @busy_queues: number of bfq_queues containing requests (including the
  *		 queue in service, even if it is idling).
  * @queued: number of queued requests.
@@ -267,6 +275,7 @@ enum bfq_device_speed {
  * @peak_rate_samples: number of samples used to calculate @peak_rate.
  * @bfq_max_budget: maximum budget allotted to a bfq_queue before
  *                  rescheduling.
+ * @group_list: list of all the bfq_groups active on the device.
  * @active_list: list of all the bfq_queues active on the device.
  * @idle_list: list of all the bfq_queues idle on the device.
  * @bfq_quantum: max number of requests dispatched per dispatch round.
@@ -293,7 +302,7 @@ enum bfq_device_speed {
 struct bfq_data {
 	struct request_queue *queue;
 
-	struct bfq_sched_data sched_data;
+	struct bfq_group *root_group;
 
 	int busy_queues;
 	int queued;
@@ -320,6 +329,7 @@ struct bfq_data {
 	u64 peak_rate;
 	unsigned long bfq_max_budget;
 
+	struct hlist_head group_list;
 	struct list_head active_list;
 	struct list_head idle_list;
 
@@ -390,6 +400,82 @@ enum bfqq_expiration {
 	BFQ_BFQQ_NO_MORE_REQUESTS,	/* the queue has no more requests */
 };
 
+#ifdef CONFIG_CGROUP_BFQIO
+/**
+ * struct bfq_group - per (device, cgroup) data structure.
+ * @entity: schedulable entity to insert into the parent group sched_data.
+ * @sched_data: own sched_data, to contain child entities (they may be
+ *              both bfq_queues and bfq_groups).
+ * @group_node: node to be inserted into the bfqio_cgroup->group_data
+ *              list of the containing cgroup's bfqio_cgroup.
+ * @bfqd_node: node to be inserted into the @bfqd->group_list list
+ *             of the groups active on the same device; used for cleanup.
+ * @bfqd: the bfq_data for the device this group acts upon.
+ * @async_bfqq: array of async queues for all the tasks belonging to
+ *              the group, one queue per ioprio value per ioprio_class,
+ *              except for the idle class that has only one queue.
+ * @async_idle_bfqq: async queue for the idle class (ioprio is ignored).
+ * @my_entity: pointer to @entity, %NULL for the toplevel group; used
+ *             to avoid too many special cases during group creation/
+ *             migration.
+ *
+ * Each (device, cgroup) pair has its own bfq_group, i.e., for each cgroup
+ * there is a set of bfq_groups, each one collecting the lower-level
+ * entities belonging to the group that are acting on the same device.
+ *
+ * Locking works as follows:
+ *    o @group_node is protected by the bfqio_cgroup lock, and is accessed
+ *      via RCU from its readers.
+ *    o @bfqd is protected by the queue lock, RCU is used to access it
+ *      from the readers.
+ *    o All the other fields are protected by the @bfqd queue lock.
+ */
+struct bfq_group {
+	struct bfq_entity entity;
+	struct bfq_sched_data sched_data;
+
+	struct hlist_node group_node;
+	struct hlist_node bfqd_node;
+
+	void *bfqd;
+
+	struct bfq_queue *async_bfqq[2][IOPRIO_BE_NR];
+	struct bfq_queue *async_idle_bfqq;
+
+	struct bfq_entity *my_entity;
+};
+
+/**
+ * struct bfqio_cgroup - bfq cgroup data structure.
+ * @css: subsystem state for bfq in the containing cgroup.
+ * @online: flag marked when the subsystem is inserted.
+ * @weight: cgroup weight.
+ * @ioprio: cgroup ioprio.
+ * @ioprio_class: cgroup ioprio_class.
+ * @lock: spinlock that protects @ioprio, @ioprio_class and @group_data.
+ * @group_data: list containing the bfq_group belonging to this cgroup.
+ *
+ * @group_data is accessed using RCU, with @lock protecting the updates,
+ * @ioprio and @ioprio_class are protected by @lock.
+ */
+struct bfqio_cgroup {
+	struct cgroup_subsys_state css;
+	bool online;
+
+	unsigned short weight, ioprio, ioprio_class;
+
+	spinlock_t lock;
+	struct hlist_head group_data;
+};
+#else
+struct bfq_group {
+	struct bfq_sched_data sched_data;
+
+	struct bfq_queue *async_bfqq[2][IOPRIO_BE_NR];
+	struct bfq_queue *async_idle_bfqq;
+};
+#endif
+
 static inline struct bfq_service_tree *
 bfq_entity_service_tree(struct bfq_entity *entity)
 {
@@ -460,8 +546,10 @@ static inline void bfq_put_bfqd_unlock(struct bfq_data *bfqd,
 static void bfq_changed_ioprio(struct bfq_io_cq *bic);
 static void bfq_put_queue(struct bfq_queue *bfqq);
 static void bfq_dispatch_insert(struct request_queue *q, struct request *rq);
-static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd, int is_sync,
+static struct bfq_queue *bfq_get_queue(struct bfq_data *bfqd,
+				       struct bfq_group *bfqg, int is_sync,
 				       struct bfq_io_cq *bic, gfp_t gfp_mask);
+static void bfq_put_async_queues(struct bfq_data *bfqd, struct bfq_group *bfqg);
 static void bfq_exit_bfqq(struct bfq_data *bfqd, struct bfq_queue *bfqq);
 
 #endif /* _BFQ_H */
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 768fe44..cdd2528 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -39,6 +39,10 @@ SUBSYS(net_cls)
 SUBSYS(blkio)
 #endif
 
+#if IS_ENABLED(CONFIG_CGROUP_BFQIO)
+SUBSYS(bfqio)
+#endif
+
 #if IS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf_event)
 #endif
-- 
1.9.2
