From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/10] Common hierarchical fair queuing code in elevaotor layer
Date: Wed, 11 Mar 2009 21:56:49 -0400
Message-ID: <1236823015-4183-5-git-send-email-vgoyal@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1236823015-4183-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, fer
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch enables hierarchical fair queuing in common layer. It is
controlled by config option CONFIG_GROUP_IOSCHED.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-ioc.c               |    3 +
 block/elevator-fq.c           |  991 ++++++++++++++++++++++++++++++++++++++---
 block/elevator-fq.h           |  113 +++++
 block/elevator.c              |    2 +
 include/linux/blkdev.h        |    7 +-
 include/linux/cgroup_subsys.h |    7 +
 include/linux/iocontext.h     |    5 +
 init/Kconfig                  |    8 +
 8 files changed, 1064 insertions(+), 72 deletions(-)

diff --git a/block/blk-ioc.c b/block/blk-ioc.c
index 012f065..8f0f6cf 100644
--- a/block/blk-ioc.c
+++ b/block/blk-ioc.c
@@ -95,6 +95,9 @@ struct io_context *alloc_io_context(gfp_t gfp_flags, int node)
 		spin_lock_init(&ret->lock);
 		ret->ioprio_changed = 0;
 		ret->ioprio = 0;
+#ifdef CONFIG_GROUP_IOSCHED
+		ret->cgroup_changed = 0;
+#endif
 		ret->last_waited = jiffies; /* doesn't matter... */
 		ret->nr_batch_requests = 0; /* because this is 0 */
 		ret->aic = NULL;
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index a8addd1..389f68e 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -20,10 +20,82 @@ int elv_slice_idle = HZ / 125;
 static struct kmem_cache *elv_ioq_pool;
 
 #define ELV_HW_QUEUE_MIN	(5)
+
+#define IO_DEFAULT_GRP_IOPRIO  4
+#define IO_DEFAULT_GRP_CLASS   IOPRIO_CLASS_BE
+
 #define IO_SERVICE_TREE_INIT   ((struct io_service_tree)		\
 				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
 
+void elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
 /* Mainly the BFQ scheduling code Follows */
+#ifdef CONFIG_GROUP_IOSCHED
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = entity->parent)
+
+#define for_each_entity_safe(entity, parent) \
+	for (; entity && ({ parent = entity->parent; 1; }); entity = parent)
+
+
+struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
+						 int extract);
+void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
+					int requeue);
+void elv_activate_ioq(struct io_queue *ioq);
+void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
+					int requeue);
+
+static int bfq_update_next_active(struct io_sched_data *sd)
+{
+	struct io_group *iog;
+	struct io_entity *entity, *next_active;
+
+	if (sd->active_entity != NULL)
+		/* will update/requeue at the end of service */
+		return 0;
+
+	/*
+	 * NOTE: this can be improved in may ways, such as returning
+	 * 1 (and thus propagating upwards the update) only when the
+	 * budget changes, or caching the bfqq that will be scheduled
+	 * next from this subtree.  By now we worry more about
+	 * correctness than about performance...
+	 */
+	next_active = bfq_lookup_next_entity(sd, 0);
+	sd->next_active = next_active;
+
+	if (next_active != NULL) {
+		iog = container_of(sd, struct io_group, sched_data);
+		entity = iog->my_entity;
+		if (entity != NULL)
+			entity->budget = next_active->budget;
+	}
+
+	return 1;
+}
+
+static inline void bfq_check_next_active(struct io_sched_data *sd,
+					 struct io_entity *entity)
+{
+	BUG_ON(sd->next_active != entity);
+}
+#else /* GROUP_IOSCHED */
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = NULL)
+
+#define for_each_entity_safe(entity, parent) \
+	for (parent = NULL; entity != NULL; entity = parent)
+
+static inline int bfq_update_next_active(struct io_sched_data *sd)
+{
+	return 0;
+}
+
+static inline void bfq_check_next_active(struct io_sched_data *sd,
+					 struct io_entity *entity)
+{
+}
+#endif
 
 /*
  * Shift for timestamp calculations.  This actually limits the maximum
@@ -288,13 +360,6 @@ void bfq_get_entity(struct io_entity *entity)
 		elv_get_ioq(ioq);
 }
 
-void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
-{
-	entity->ioprio = entity->new_ioprio;
-	entity->ioprio_class = entity->new_ioprio_class;
-	entity->sched_data = &iog->sched_data;
-}
-
 /**
  * bfq_find_deepest - find the deepest node that an extraction can modify.
  * @node: the node being removed.
@@ -520,12 +585,27 @@ static void __bfq_activate_entity(struct io_entity *entity)
 }
 
 /**
- * bfq_activate_entity - activate an entity.
+ * bfq_activate_entity - activate an entity and its ancestors if necessary.
  * @entity: the entity to activate.
+ *
+ * Activate @entity and all the entities on the path from it to the root.
  */
 void bfq_activate_entity(struct io_entity *entity)
 {
-	__bfq_activate_entity(entity);
+	struct io_sched_data *sd;
+
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity);
+
+		sd = entity->sched_data;
+		if (!bfq_update_next_active(sd))
+			/*
+			 * No need to propagate the activation to the
+			 * upper entities, as they will be updated when
+			 * the active entity is rescheduled.
+			 */
+			break;
+	}
 }
 
 /**
@@ -561,12 +641,16 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 	else if (entity->tree != NULL)
 		BUG();
 
+	if (was_active || sd->next_active == entity)
+		ret = bfq_update_next_active(sd);
+
 	if (!requeue || !bfq_gt(entity->finish, st->vtime))
 		bfq_forget_entity(st, entity);
 	else
 		bfq_idle_insert(st, entity);
 
 	BUG_ON(sd->active_entity == entity);
+	BUG_ON(sd->next_active == entity);
 
 	return ret;
 }
@@ -578,7 +662,46 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
  */
 void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
-	__bfq_deactivate_entity(entity, requeue);
+	struct io_sched_data *sd;
+	struct io_entity *parent;
+
+	for_each_entity_safe(entity, parent) {
+		sd = entity->sched_data;
+
+		if (!__bfq_deactivate_entity(entity, requeue))
+			/*
+			 * The parent entity is still backlogged, and
+			 * we don't need to update it as it is still
+			 * under service.
+			 */
+			break;
+
+		if (sd->next_active != NULL)
+			/*
+			 * The parent entity is still backlogged and
+			 * the budgets on the path towards the root
+			 * need to be updated.
+			 */
+			goto update;
+
+		/*
+		 * If we reach there the parent is no more backlogged and
+		 * we want to propagate the dequeue upwards.
+		 */
+		requeue = 1;
+	}
+
+	return;
+
+update:
+	entity = parent;
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity);
+
+		sd = entity->sched_data;
+		if (!bfq_update_next_active(sd))
+			break;
+	}
 }
 
 /**
@@ -695,8 +818,10 @@ struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 		entity = __bfq_lookup_next_entity(st);
 		if (entity != NULL) {
 			if (extract) {
+				bfq_check_next_active(sd, entity);
 				bfq_active_extract(st, entity);
 				sd->active_entity = entity;
+				sd->next_active = NULL;
 			}
 			break;
 		}
@@ -709,14 +834,756 @@ void entity_served(struct io_entity *entity, bfq_service_t served)
 {
 	struct io_service_tree *st;
 
-	st = io_entity_service_tree(entity);
-	entity->service += served;
-	WARN_ON_ONCE(entity->service > entity->budget);
-	BUG_ON(st->wsum == 0);
-	st->vtime += bfq_delta(served, st->wsum);
-	bfq_forget_idle(st);
+	for_each_entity(entity) {
+		st = io_entity_service_tree(entity);
+		entity->service += served;
+		WARN_ON_ONCE(entity->service > entity->budget);
+		BUG_ON(st->wsum == 0);
+		st->vtime += bfq_delta(served, st->wsum);
+		bfq_forget_idle(st);
+	}
+}
+
+/*
+ * Release all the io group references to its async queues.
+ */
+void io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
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
+
+/* Mainly hierarchical grouping code */
+#ifdef CONFIG_GROUP_IOSCHED
+
+struct io_cgroup io_root_cgroup = {
+	.ioprio = IO_DEFAULT_GRP_IOPRIO,
+	.ioprio_class = IO_DEFAULT_GRP_CLASS,
+};
+
+void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->ioprio = entity->new_ioprio;
+	entity->ioprio_class = entity->new_ioprio_class;
+	entity->parent = iog->my_entity;
+	entity->sched_data = &iog->sched_data;
+}
+
+struct io_cgroup *cgroup_to_io_cgroup(struct cgroup *cgroup)
+{
+	return container_of(cgroup_subsys_state(cgroup, io_subsys_id),
+			    struct io_cgroup, css);
+}
+
+/*
+ * Search the bfq_group for bfqd into the hash table (by now only a list)
+ * of bgrp.  Must be called under rcu_read_lock().
+ */
+struct io_group *io_cgroup_lookup_group(struct io_cgroup *iocg, void *key)
+{
+	struct io_group *iog;
+	struct hlist_node *n;
+	void *__key;
+
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		__key = rcu_dereference(iog->key);
+		if (__key == key)
+			return iog;
+	}
+
+	return NULL;
+}
+
+struct io_group *io_lookup_io_group_current(struct request_queue *q)
+{
+	struct io_group *iog;
+	struct io_cgroup *iocg;
+	struct cgroup *cgroup;
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	cgroup = task_cgroup(current, io_subsys_id);
+	iocg = cgroup_to_io_cgroup(cgroup);
+	iog = io_cgroup_lookup_group(iocg, efqd);
+	return iog;
+}
+EXPORT_SYMBOL(io_lookup_io_group_current);
+
+void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
+{
+	struct io_entity *entity = &iog->entity;
+
+	entity->ioprio = entity->new_ioprio = iocg->ioprio;
+	entity->ioprio_class = entity->new_ioprio_class = iocg->ioprio_class;
+	entity->ioprio_changed = 1;
+	entity->my_sched_data = &iog->sched_data;
+}
+
+void io_group_set_parent(struct io_group *iog, struct io_group *parent)
+{
+	struct io_entity *entity;
+
+	BUG_ON(parent == NULL);
+	BUG_ON(iog == NULL);
+
+	entity = &iog->entity;
+	entity->parent = parent->my_entity;
+	entity->sched_data = &parent->sched_data;
+}
+
+/**
+ * bfq_flush_idle_tree - deactivate any entity on the idle tree of @st.
+ * @st: the service tree being flushed.
+ */
+void io_flush_idle_tree(struct io_service_tree *st)
+{
+	struct io_entity *entity = st->first_idle;
+
+	for (; entity != NULL; entity = st->first_idle)
+		__bfq_deactivate_entity(entity, 0);
+}
+
+#define SHOW_FUNCTION(__VAR)						\
+static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,		\
+				       struct cftype *cftype)		\
+{									\
+	struct io_cgroup *iocg;					\
+	u64 ret;							\
+									\
+	if (!cgroup_lock_live_group(cgroup))				\
+		return -ENODEV;						\
+									\
+	iocg = cgroup_to_io_cgroup(cgroup);				\
+	spin_lock_irq(&iocg->lock);					\
+	ret = iocg->__VAR;						\
+	spin_unlock_irq(&iocg->lock);					\
+									\
+	cgroup_unlock();						\
+									\
+	return ret;							\
+}
+
+SHOW_FUNCTION(ioprio);
+SHOW_FUNCTION(ioprio_class);
+#undef SHOW_FUNCTION
+
+#define STORE_FUNCTION(__VAR, __MIN, __MAX)				\
+static int io_cgroup_##__VAR##_write(struct cgroup *cgroup,		\
+					struct cftype *cftype,		\
+					u64 val)			\
+{									\
+	struct io_cgroup *iocg;					\
+	struct io_group *iog;						\
+	struct hlist_node *n;						\
+									\
+	if (val < (__MIN) || val > (__MAX))				\
+		return -EINVAL;						\
+									\
+	if (!cgroup_lock_live_group(cgroup))				\
+		return -ENODEV;						\
+									\
+	iocg = cgroup_to_io_cgroup(cgroup);				\
+									\
+	spin_lock_irq(&iocg->lock);					\
+	iocg->__VAR = (unsigned char)val;				\
+	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {	\
+		iog->entity.new_##__VAR = (unsigned char)val;		\
+		smp_wmb();						\
+		iog->entity.ioprio_changed = 1;			\
+	}								\
+	spin_unlock_irq(&iocg->lock);					\
+									\
+	cgroup_unlock();						\
+									\
+	return 0;							\
+}
+
+STORE_FUNCTION(ioprio, 0, IOPRIO_BE_NR - 1);
+STORE_FUNCTION(ioprio_class, IOPRIO_CLASS_RT, IOPRIO_CLASS_IDLE);
+#undef STORE_FUNCTION
+
+/**
+ * bfq_group_chain_alloc - allocate a chain of groups.
+ * @bfqd: queue descriptor.
+ * @cgroup: the leaf cgroup this chain starts from.
+ *
+ * Allocate a chain of groups starting from the one belonging to
+ * @cgroup up to the root cgroup.  Stop if a cgroup on the chain
+ * to the root has already an allocated group on @bfqd.
+ */
+struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
+					struct cgroup *cgroup)
+{
+	struct io_cgroup *iocg;
+	struct io_group *iog, *leaf = NULL, *prev = NULL;
+	gfp_t flags = GFP_ATOMIC |  __GFP_ZERO;
+
+	for (; cgroup != NULL; cgroup = cgroup->parent) {
+		iocg = cgroup_to_io_cgroup(cgroup);
+
+		iog = io_cgroup_lookup_group(iocg, key);
+		if (iog != NULL) {
+			/*
+			 * All the cgroups in the path from there to the
+			 * root must have a bfq_group for bfqd, so we don't
+			 * need any more allocations.
+			 */
+			break;
+		}
+
+		iog = kzalloc_node(sizeof(*iog), flags, q->node);
+		if (!iog)
+			goto cleanup;
+
+		io_group_init_entity(iocg, iog);
+		iog->my_entity = &iog->entity;
+
+		if (leaf == NULL) {
+			leaf = iog;
+			prev = leaf;
+		} else {
+			io_group_set_parent(prev, iog);
+			/*
+			 * Build a list of allocated nodes using the bfqd
+			 * filed, that is still unused and will be initialized
+			 * only after the node will be connected.
+			 */
+			prev->key = iog;
+			prev = iog;
+		}
+	}
+
+	return leaf;
+
+cleanup:
+	while (leaf != NULL) {
+		prev = leaf;
+		leaf = leaf->key;
+		kfree(iog);
+	}
+
+	return NULL;
 }
 
+/**
+ * bfq_group_chain_link - link an allocatd group chain to a cgroup hierarchy.
+ * @bfqd: the queue descriptor.
+ * @cgroup: the leaf cgroup to start from.
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
+void io_group_chain_link(struct request_queue *q, void *key,
+				struct cgroup *cgroup,
+				struct io_group *leaf,
+				struct elv_fq_data *efqd)
+{
+	struct io_cgroup *iocg;
+	struct io_group *iog, *next, *prev = NULL;
+	unsigned long flags;
+
+	assert_spin_locked(q->queue_lock);
+
+	for (; cgroup != NULL && leaf != NULL; cgroup = cgroup->parent) {
+		iocg = cgroup_to_io_cgroup(cgroup);
+		next = leaf->key;
+
+		iog = io_cgroup_lookup_group(iocg, key);
+		BUG_ON(iog != NULL);
+
+		spin_lock_irqsave(&iocg->lock, flags);
+
+		rcu_assign_pointer(leaf->key, key);
+		hlist_add_head_rcu(&leaf->group_node, &iocg->group_data);
+		hlist_add_head(&leaf->elv_data_node, &efqd->group_list);
+
+		spin_unlock_irqrestore(&iocg->lock, flags);
+
+		prev = leaf;
+		leaf = next;
+	}
+
+	BUG_ON(cgroup == NULL && leaf != NULL);
+
+	if (cgroup != NULL && prev != NULL) {
+		iocg = cgroup_to_io_cgroup(cgroup);
+		iog = io_cgroup_lookup_group(iocg, key);
+		io_group_set_parent(prev, iog);
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
+ * but is a safe fallbak.  If this loss becames a problem it can be
+ * mitigated using the equivalent weight (given by the product of the
+ * weights of the groups in the path from @group to the root) in the
+ * root scheduler.
+ *
+ * We allocate all the missing nodes in the path from the leaf cgroup
+ * to the root and we connect the nodes only after all the allocations
+ * have been successful.
+ */
+struct io_group *io_find_alloc_group(struct request_queue *q,
+			struct cgroup *cgroup, struct elv_fq_data *efqd)
+{
+	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
+	struct io_group *iog;
+	/* Note: Use efqd as key */
+	void *key = efqd;
+
+	iog = io_cgroup_lookup_group(iocg, key);
+	if (iog != NULL)
+		return iog;
+
+	iog = io_group_chain_alloc(q, key, cgroup);
+	if (iog != NULL)
+		io_group_chain_link(q, key, cgroup, iog, efqd);
+
+	return iog;
+}
+
+/*
+ * Generic function to make sure cgroup hierarchy is all setup once a request
+ * from a cgroup is received by the io scheduler.
+ */
+struct io_group *io_get_io_group(struct request_queue *q)
+{
+	struct cgroup *cgroup;
+	struct io_group *iog;
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	rcu_read_lock();
+	cgroup = task_cgroup(current, io_subsys_id);
+	iog = io_find_alloc_group(q, cgroup, efqd);
+	if (iog == NULL)
+		iog = efqd->root_group;
+	rcu_read_unlock();
+
+	return iog;
+}
+
+void io_free_root_group(struct elevator_queue *e)
+{
+	struct io_cgroup *iocg = &io_root_cgroup;
+	struct elv_fq_data *efqd = &e->efqd;
+	struct io_group *iog = efqd->root_group;
+
+	BUG_ON(!iog);
+	spin_lock_irq(&iocg->lock);
+	hlist_del_rcu(&iog->group_node);
+	spin_unlock_irq(&iocg->lock);
+	io_put_io_group_queues(e, iog);
+	kfree(iog);
+}
+
+struct io_group *io_alloc_root_group(struct request_queue *q,
+					struct elevator_queue *e, void *key)
+{
+	struct io_group *iog;
+	struct io_cgroup *iocg;
+	int i;
+
+	iog = kmalloc_node(sizeof(*iog), GFP_KERNEL | __GFP_ZERO, q->node);
+	if (iog == NULL)
+		return NULL;
+
+	iog->entity.parent = NULL;
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
+		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
+
+	iocg = &io_root_cgroup;
+	spin_lock_irq(&iocg->lock);
+	rcu_assign_pointer(iog->key, key);
+	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
+	spin_unlock_irq(&iocg->lock);
+
+	return iog;
+}
+
+struct cftype bfqio_files[] = {
+	{
+		.name = "ioprio",
+		.read_u64 = io_cgroup_ioprio_read,
+		.write_u64 = io_cgroup_ioprio_write,
+	},
+	{
+		.name = "ioprio_class",
+		.read_u64 = io_cgroup_ioprio_class_read,
+		.write_u64 = io_cgroup_ioprio_class_write,
+	},
+};
+
+int iocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+	return cgroup_add_files(cgroup, subsys, bfqio_files,
+				ARRAY_SIZE(bfqio_files));
+}
+
+struct cgroup_subsys_state *iocg_create(struct cgroup_subsys *subsys,
+						struct cgroup *cgroup)
+{
+	struct io_cgroup *iocg;
+
+	if (cgroup->parent != NULL) {
+		iocg = kzalloc(sizeof(*iocg), GFP_KERNEL);
+		if (iocg == NULL)
+			return ERR_PTR(-ENOMEM);
+	} else
+		iocg = &io_root_cgroup;
+
+	spin_lock_init(&iocg->lock);
+	INIT_HLIST_HEAD(&iocg->group_data);
+	iocg->ioprio = IO_DEFAULT_GRP_IOPRIO;
+	iocg->ioprio_class = IO_DEFAULT_GRP_CLASS;
+
+	return &iocg->css;
+}
+
+/*
+ * We cannot support shared io contexts, as we have no mean to support
+ * two tasks with the same ioc in two different groups without major rework
+ * of the main cic/bfqq data structures.  By now we allow a task to change
+ * its cgroup only if it's the only owner of its ioc; the drawback of this
+ * behavior is that a group containing a task that forked using CLONE_IO
+ * will not be destroyed until the tasks sharing the ioc die.
+ */
+int iocg_can_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
+			    struct task_struct *tsk)
+{
+	struct io_context *ioc;
+	int ret = 0;
+
+	/* task_lock() is needed to avoid races with exit_io_context() */
+	task_lock(tsk);
+	ioc = tsk->io_context;
+	if (ioc != NULL && atomic_read(&ioc->nr_tasks) > 1)
+		/*
+		 * ioc == NULL means that the task is either too young or
+		 * exiting: if it has still no ioc the ioc can't be shared,
+		 * if the task is exiting the attach will fail anyway, no
+		 * matter what we return here.
+		 */
+		ret = -EINVAL;
+	task_unlock(tsk);
+
+	return ret;
+}
+
+void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
+			 struct cgroup *prev, struct task_struct *tsk)
+{
+	struct io_context *ioc;
+
+	task_lock(tsk);
+	ioc = tsk->io_context;
+	if (ioc != NULL)
+		ioc->cgroup_changed = 1;
+	task_unlock(tsk);
+}
+
+/*
+ * Move the queue to the root group if it is active. This is needed when
+ * a cgroup is being deleted and all the IO is not done yet. This is not
+ * very good scheme as a user might get unfair share. This needs to be
+ * fixed.
+ */
+void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
+				struct io_group *iog)
+{
+	int busy, resume;
+	struct io_entity *entity = &ioq->entity;
+	struct elv_fq_data *efqd = &e->efqd;
+	struct io_service_tree *st = io_entity_service_tree(entity);
+
+	busy = elv_ioq_busy(ioq);
+	resume = !!ioq->nr_queued;
+
+	BUG_ON(resume && !entity->on_st);
+	BUG_ON(busy && !resume && entity->on_st && ioq != efqd->active_queue);
+
+	/*
+	 * We could be moving an queue which is on idle tree of previous group
+	 * What to do? I guess anyway this queue does not have any requests.
+	 * just forget the entity and free up from idle tree.
+	 *
+	 * This needs cleanup. Hackish.
+	 */
+	if (entity->tree == &st->idle) {
+		BUG_ON(atomic_read(&ioq->ref) < 2);
+		bfq_put_idle_entity(st, entity);
+	}
+
+	if (busy) {
+		BUG_ON(atomic_read(&ioq->ref) < 2);
+
+		if (!resume)
+			elv_del_ioq_busy(e, ioq, 0);
+		else
+			elv_deactivate_ioq(efqd, ioq, 0);
+	}
+
+	/*
+	 * Here we use a reference to bfqg.  We don't need a refcounter
+	 * as the cgroup reference will not be dropped, so that its
+	 * destroy() callback will not be invoked.
+	 */
+	entity->parent = iog->my_entity;
+	entity->sched_data = &iog->sched_data;
+
+	if (busy && resume)
+		elv_activate_ioq(ioq);
+}
+EXPORT_SYMBOL(io_ioq_move);
+
+static void __io_destroy_group(struct elv_fq_data *efqd, struct io_group *iog)
+{
+	struct elevator_queue *eq;
+	struct io_entity *entity = iog->my_entity;
+	struct io_service_tree *st;
+	int i;
+
+	eq = container_of(efqd, struct elevator_queue, efqd);
+	hlist_del(&iog->elv_data_node);
+	__bfq_deactivate_entity(entity, 0);
+	io_put_io_group_queues(eq, iog);
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+
+		/*
+		 * The idle tree may still contain bfq_queues belonging
+		 * to exited task because they never migrated to a different
+		 * cgroup from the one being destroyed now.  Noone else
+		 * can access them so it's safe to act without any lock.
+		 */
+		io_flush_idle_tree(st);
+
+		BUG_ON(!RB_EMPTY_ROOT(&st->active));
+		BUG_ON(!RB_EMPTY_ROOT(&st->idle));
+	}
+
+	BUG_ON(iog->sched_data.next_active != NULL);
+	BUG_ON(iog->sched_data.active_entity != NULL);
+	BUG_ON(entity->tree != NULL);
+}
+
+/**
+ * bfq_destroy_group - destroy @bfqg.
+ * @bgrp: the bfqio_cgroup containing @bfqg.
+ * @bfqg: the group being destroyed.
+ *
+ * Destroy @bfqg, making sure that it is not referenced from its parent.
+ */
+static void io_destroy_group(struct io_cgroup *iocg, struct io_group *iog)
+{
+	struct elv_fq_data *efqd = NULL;
+	unsigned long uninitialized_var(flags);
+
+	/* Remove io group from cgroup list */
+	hlist_del(&iog->group_node);
+
+	/*
+	 * io groups are linked in two lists. One list is maintained
+	 * in elevator (efqd->group_list) and other is maintained
+	 * per cgroup structure (iocg->group_data).
+	 *
+	 * While a cgroup is being deleted, elevator also might be
+	 * exiting and both might try to cleanup the same io group
+	 * so need to be little careful.
+	 *
+	 * Following code first accesses efqd under RCU to make sure
+	 * iog->key is pointing to valid efqd and then takes the
+	 * associated queue lock. After gettting the queue lock it
+	 * again checks whether elevator exit path had alreday got
+	 * hold of io group (iog->key == NULL). If yes, it does not
+	 * try to free up async queues again or flush the idle tree.
+	 */
+
+	rcu_read_lock();
+	efqd = rcu_dereference(iog->key);
+	if (efqd != NULL) {
+		spin_lock_irqsave(efqd->queue->queue_lock, flags);
+		if (iog->key == efqd)
+			__io_destroy_group(efqd, iog);
+		spin_unlock_irqrestore(efqd->queue->queue_lock, flags);
+	}
+	rcu_read_unlock();
+
+	/*
+	 * No need to defer the kfree() to the end of the RCU grace
+	 * period: we are called from the destroy() callback of our
+	 * cgroup, so we can be sure that noone is a) still using
+	 * this cgroup or b) doing lookups in it.
+	 */
+	kfree(iog);
+}
+
+void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
+	struct hlist_node *n, *tmp;
+	struct io_group *iog;
+
+	/*
+	 * Since we are destroying the cgroup, there are no more tasks
+	 * referencing it, and all the RCU grace periods that may have
+	 * referenced it are ended (as the destruction of the parent
+	 * cgroup is RCU-safe); bgrp->group_data will not be accessed by
+	 * anything else and we don't need any synchronization.
+	 */
+	hlist_for_each_entry_safe(iog, n, tmp, &iocg->group_data, group_node)
+		io_destroy_group(iocg, iog);
+
+	BUG_ON(!hlist_empty(&iocg->group_data));
+
+	kfree(iocg);
+}
+
+void io_disconnect_groups(struct elevator_queue *e)
+{
+	struct hlist_node *pos, *n;
+	struct io_group *iog;
+	struct elv_fq_data *efqd = &e->efqd;
+
+	hlist_for_each_entry_safe(iog, pos, n, &efqd->group_list,
+					elv_data_node) {
+		hlist_del(&iog->elv_data_node);
+
+		__bfq_deactivate_entity(iog->my_entity, 0);
+
+		/*
+		 * Don't remove from the group hash, just set an
+		 * invalid key.  No lookups can race with the
+		 * assignment as bfqd is being destroyed; this
+		 * implies also that new elements cannot be added
+		 * to the list.
+		 */
+		rcu_assign_pointer(iog->key, NULL);
+		io_put_io_group_queues(e, iog);
+	}
+}
+
+struct cgroup_subsys io_subsys = {
+	.name = "io",
+	.create = iocg_create,
+	.can_attach = iocg_can_attach,
+	.attach = iocg_attach,
+	.destroy = iocg_destroy,
+	.populate = iocg_populate,
+	.subsys_id = io_subsys_id,
+};
+
+/* if bio sumbmitting task and rq don't belong to same io_group, it can't
+ * be merged */
+int io_group_allow_merge(struct request *rq, struct bio *bio)
+{
+	struct request_queue *q = rq->q;
+	struct io_queue *ioq = rq->ioq;
+	struct io_group *iog, *__iog;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return 1;
+
+	/* Determine the io group of the bio submitting task */
+	iog = io_lookup_io_group_current(q);
+	if (!iog) {
+		/* May be task belongs to a differet cgroup for which io
+		 * group has not been setup yet. */
+		return 0;
+	}
+
+	/* Determine the io group of the ioq, rq belongs to*/
+	__iog = ioq_to_io_group(ioq);
+
+	return (iog == __iog);
+}
+
+/* find/create the io group request belongs to and put that info in rq */
+void elv_fq_set_request_io_group(struct request_queue *q,
+						struct request *rq)
+{
+	struct io_group *iog;
+	unsigned long flags;
+
+	/* Make sure io group hierarchy has been setup and also set the
+	 * io group to which rq belongs. Later we should make use of
+	 * bio cgroup patches to determine the io group */
+	spin_lock_irqsave(q->queue_lock, flags);
+	iog = io_get_io_group(q);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	BUG_ON(!iog);
+
+	/* Store iog in rq. TODO: take care of referencing */
+	rq->iog = iog;
+}
+
+#else /* GROUP_IOSCHED */
+void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->ioprio = entity->new_ioprio;
+	entity->ioprio_class = entity->new_ioprio_class;
+	entity->sched_data = &iog->sched_data;
+}
+
+struct io_group *io_alloc_root_group(struct request_queue *q,
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
+struct io_group *io_lookup_io_group_current(struct request_queue *q)
+{
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	return efqd->root_group;
+}
+EXPORT_SYMBOL(io_lookup_io_group_current);
+
+void io_free_root_group(struct elevator_queue *e)
+{
+	struct io_group *iog = e->efqd.root_group;
+	io_put_io_group_queues(e, iog);
+	kfree(iog);
+}
+
+struct io_group *io_get_io_group(struct request_queue *q)
+{
+	return q->elevator->efqd.root_group;
+}
+
+#endif /* CONFIG_GROUP_IOSCHED*/
+
 /* Elevator fair queuing function */
 struct io_queue *rq_ioq(struct request *rq)
 {
@@ -995,9 +1862,11 @@ EXPORT_SYMBOL(elv_put_ioq);
 
 void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
 {
+	struct io_group *root_group = e->efqd.root_group;
 	struct io_queue *ioq = *ioq_ptr;
 
 	if (ioq != NULL) {
+		io_ioq_move(e, ioq, root_group);
 		/* Drop the reference taken by the io group */
 		elv_put_ioq(ioq);
 		*ioq_ptr = NULL;
@@ -1022,14 +1891,27 @@ struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
 		return NULL;
 
 	sd = &efqd->root_group->sched_data;
-	if (extract)
-		entity = bfq_lookup_next_entity(sd, 1);
-	else
-		entity = bfq_lookup_next_entity(sd, 0);
+	for (; sd != NULL; sd = entity->my_sched_data) {
+		if (extract)
+			entity = bfq_lookup_next_entity(sd, 1);
+		else
+			entity = bfq_lookup_next_entity(sd, 0);
+
+		/*
+		 * entity can be null despite the fact that there are busy
+		 * queues. if all the busy queues are under a group which is
+		 * currently under service.
+		 * So if we are just looking for next ioq while something is
+		 * being served, null entity is not an error.
+		 */
+		BUG_ON(!entity && extract);
 
-	BUG_ON(!entity);
-	if (extract)
-		entity->service = 0;
+		if (extract)
+			entity->service = 0;
+
+		if (!entity)
+			return NULL;
+	}
 	ioq = io_entity_to_ioq(entity);
 
 	return ioq;
@@ -1262,6 +2144,7 @@ int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 {
 	struct io_queue *ioq;
 	struct elevator_queue *eq = q->elevator;
+	struct io_group *iog = NULL, *new_iog = NULL;
 
 	ioq = elv_active_ioq(eq);
 
@@ -1283,10 +2166,17 @@ int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 	if (elv_ioq_class_rt(new_ioq) && !elv_ioq_class_rt(ioq))
 		return 1;
 
+	iog = ioq_to_io_group(ioq);
+	new_iog = ioq_to_io_group(new_ioq);
+
 	/*
-	 * Check with io scheduler if it has additional criterion based on
-	 * which it wants to preempt existing queue.
+	 * If both the queues belong to same group, check with io scheduler
+	 * if it has additional criterion based on which it wants to
+	 * preempt existing queue.
 	 */
+	if (iog != new_iog)
+		return 0;
+
 	if (eq->ops->elevator_should_preempt_fn)
 		return eq->ops->elevator_should_preempt_fn(q, new_ioq, rq);
 
@@ -1663,14 +2553,6 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		elv_schedule_dispatch(q);
 }
 
-struct io_group *io_lookup_io_group_current(struct request_queue *q)
-{
-	struct elv_fq_data *efqd = &q->elevator->efqd;
-
-	return efqd->root_group;
-}
-EXPORT_SYMBOL(io_lookup_io_group_current);
-
 void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
 					int ioprio)
 {
@@ -1721,44 +2603,6 @@ void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 }
 EXPORT_SYMBOL(io_group_set_async_queue);
 
-/*
- * Release all the io group references to its async queues.
- */
-void io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
-{
-	int i, j;
-
-	for (i = 0; i < 2; i++)
-		for (j = 0; j < IOPRIO_BE_NR; j++)
-			elv_release_ioq(e, &iog->async_queue[i][j]);
-
-	/* Free up async idle queue */
-	elv_release_ioq(e, &iog->async_idle_queue);
-}
-
-struct io_group *io_alloc_root_group(struct request_queue *q,
-					struct elevator_queue *e, void *key)
-{
-	struct io_group *iog;
-	int i;
-
-	iog = kmalloc_node(sizeof(*iog), GFP_KERNEL | __GFP_ZERO, q->node);
-	if (iog == NULL)
-		return NULL;
-
-	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
-		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
-
-	return iog;
-}
-
-void io_free_root_group(struct elevator_queue *e)
-{
-	struct io_group *iog = e->efqd.root_group;
-	io_put_io_group_queues(e, iog);
-	kfree(iog);
-}
-
 static void elv_slab_kill(void)
 {
 	/*
@@ -1804,6 +2648,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
 
 	INIT_LIST_HEAD(&efqd->idle_list);
+	INIT_HLIST_HEAD(&efqd->group_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
@@ -1833,10 +2678,14 @@ void elv_exit_fq_data(struct elevator_queue *e)
 	spin_lock_irq(q->queue_lock);
 	/* This should drop all the idle tree references of ioq */
 	elv_free_idle_ioq_list(e);
+	/* This should drop all the io group references of async queues */
+	io_disconnect_groups(e);
 	spin_unlock_irq(q->queue_lock);
 
 	elv_shutdown_timer_wq(e);
 
+	/* Wait for iog->key accessors to exit their grace periods. */
+	synchronize_rcu();
 	BUG_ON(timer_pending(&efqd->idle_slice_timer));
 	io_free_root_group(e);
 }
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index b5a0d08..3fab8f8 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -9,6 +9,7 @@
  */
 
 #include <linux/blkdev.h>
+#include <linux/cgroup.h>
 
 #ifndef _BFQ_SCHED_H
 #define _BFQ_SCHED_H
@@ -69,6 +70,7 @@ struct io_service_tree {
  */
 struct io_sched_data {
 	struct io_entity *active_entity;
+	struct io_entity *next_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
 };
 
@@ -183,17 +185,90 @@ struct io_queue {
 	unsigned long total_service;
 };
 
+#ifdef CONFIG_GROUP_IOSCHED
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
+ *             to avoid too many special cases during group creation/migration.
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
 struct io_group {
+	struct io_entity entity;
+	struct hlist_node elv_data_node;
+	struct hlist_node group_node;
 	struct io_sched_data sched_data;
 
+	struct io_entity *my_entity;
+
+	/*
+	 * A cgroup has multiple io_groups, one for each request queue.
+	 * to find io group belonging to a particular queue, elv_fq_data
+	 * pointer is stored as a key.
+	 */
+	void *key;
+
 	/* async_queue and idle_queue are used only for cfq */
 	struct io_queue *async_queue[2][IOPRIO_BE_NR];
 	struct io_queue *async_idle_queue;
 };
 
+/**
+ * struct bfqio_cgroup - bfq cgroup data structure.
+ * @css: subsystem state for bfq in the containing cgroup.
+ * @ioprio: cgroup ioprio.
+ * @ioprio_class: cgroup ioprio_class.
+ * @lock: spinlock that protects @ioprio, @ioprio_class and @group_data.
+ * @group_data: list containing the bfq_group belonging to this cgroup.
+ *
+ * @group_data is accessed using RCU, with @lock protecting the updates,
+ * @ioprio and @ioprio_class are protected by @lock.
+ */
+struct io_cgroup {
+	struct cgroup_subsys_state css;
+
+	unsigned short ioprio, ioprio_class;
+
+	spinlock_t lock;
+	struct hlist_head group_data;
+};
+#else
+struct io_group {
+	struct io_sched_data sched_data;
+
+	/* async_queue and idle_queue are used only for cfq */
+	struct io_queue *async_queue[2][IOPRIO_BE_NR];
+	struct io_queue *async_idle_queue;
+};
+#endif
+
 struct elv_fq_data {
 	struct io_group *root_group;
 
+	/* List of io groups hanging on this elevator */
+	struct hlist_head group_list;
+
 	/* List of io queues on idle tree. */
 	struct list_head idle_list;
 
@@ -380,6 +455,39 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
 						sched_data);
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+extern int io_group_allow_merge(struct request *rq, struct bio *bio);
+extern void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
+					struct io_group *iog);
+extern void elv_fq_set_request_io_group(struct request_queue *q,
+						struct request *rq);
+#else /* !GROUP_IOSCHED */
+/*
+ * No ioq movement is needed in case of flat setup. root io group gets cleaned
+ * up upon elevator exit and before that it has been made sure that both
+ * active and idle tree are empty.
+ */
+static inline void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
+					struct io_group *iog)
+{
+}
+
+static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
+{
+	return 1;
+}
+/*
+ * Currently root group is not part of elevator group list and freed
+ * separately. Hence in case of non-hierarchical setup, nothing todo.
+ */
+static inline void io_disconnect_groups(struct elevator_queue *e) {}
+static inline void elv_fq_set_request_io_group(struct request_queue *q,
+						struct request *rq)
+{
+}
+
+#endif /* GROUP_IOSCHED */
+
 /* Functions used by blksysfs.c */
 extern ssize_t elv_slice_idle_show(struct request_queue *q, char *name);
 extern ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
@@ -475,5 +583,10 @@ static inline void *elv_fq_select_ioq(struct request_queue *q, int force)
 {
 	return NULL;
 }
+
+static inline void elv_fq_set_request_io_group(struct request_queue *q,
+						struct request *rq)
+{
+}
 #endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _BFQ_SCHED_H */
diff --git a/block/elevator.c b/block/elevator.c
index 7a3a7e9..27889bc 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -888,6 +888,8 @@ int elv_set_request(struct request_queue *q, struct request *rq, gfp_t gfp_mask)
 {
 	struct elevator_queue *e = q->elevator;
 
+	elv_fq_set_request_io_group(q, rq);
+
 	if (e->ops->elevator_set_req_fn)
 		return e->ops->elevator_set_req_fn(q, rq, gfp_mask);
 
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index cf02216..0baeb8e 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -238,7 +238,12 @@ struct request {
 #ifdef CONFIG_ELV_FAIR_QUEUING
 	/* io queue request belongs to */
 	struct io_queue *ioq;
-#endif
+
+#ifdef CONFIG_GROUP_IOSCHED
+	/* io group request belongs to */
+	struct io_group *iog;
+#endif /* GROUP_IOSCHED */
+#endif /* ELV_FAIR_QUEUING */
 };
 
 static inline unsigned short req_get_ioprio(struct request *req)
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 9c8d31b..68ea6bd 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -60,3 +60,10 @@ SUBSYS(net_cls)
 #endif
 
 /* */
+
+#ifdef CONFIG_GROUP_IOSCHED
+SUBSYS(io)
+#endif
+
+/* */
+
diff --git a/include/linux/iocontext.h b/include/linux/iocontext.h
index 08b987b..51664bb 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -73,6 +73,11 @@ struct io_context {
 	unsigned short ioprio;
 	unsigned short ioprio_changed;
 
+#ifdef CONFIG_GROUP_IOSCHED
+	/* If task changes the cgroup, elevator processes it asynchronously */
+	unsigned short cgroup_changed;
+#endif
+
 	/*
 	 * For request batching
 	 */
diff --git a/init/Kconfig b/init/Kconfig
index 6a5c5fe..66c2310 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -538,6 +538,14 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  there will be no overhead from this. Even when you set this config=y,
 	  if boot option "noswapaccount" is set, swap will not be accounted.
 
+config GROUP_IOSCHED
+	bool "Group IO Scheduler"
+	depends on CGROUPS && ELV_FAIR_QUEUING
+	default n
+	---help---
+	  This feature lets IO scheduler recognize task groups and control
+	  disk bandwidth allocation to such task groups.
+
 endif # CGROUPS
 
 config MM_OWNER
-- 
1.6.0.1
