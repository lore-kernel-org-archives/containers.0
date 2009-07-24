From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/24] io-controller: Common hierarchical fair queuing code in
	elevaotor layer
Date: Fri, 24 Jul 2009 16:27:38 -0400
Message-ID: <1248467274-32073-9-git-send-email-vgoyal__9493.38719151474$1248470009$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248467274-32073-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o This patch enables hierarchical fair queuing in common layer. It is
  controlled by config option CONFIG_GROUP_IOSCHED.

o Requests keep a reference on ioq and ioq keeps  keep a reference
  on groups. For async queues in CFQ, and single ioq in other
  schedulers, io_group also keeps are reference on io_queue. This
  reference on ioq is dropped when the queue is released
  (elv_release_ioq). So the queue can be freed.

  When a queue is released, it puts the reference to io_group and the
  io_group is released after all the queues are released. Child groups
  also take reference on parent groups, and release it when they are
  destroyed.

o Reads of iocg->group_data are not always iocg->lock; so all the operations
  on that list are still protected by RCU. All modifications to
  iocg->group_data should always done under iocg->lock.

  Whenever iocg->lock and queue_lock can both be held, queue_lock should
  be held first. This avoids all deadlocks. In order to avoid race
  between cgroup deletion and elevator switch the following algorithm is
  used:

	- Cgroup deletion path holds iocg->lock and removes iog entry
	  to iocg->group_data list. Then it drops iocg->lock, holds
	  queue_lock and destroys iog. So in this path, we never hold
	  iocg->lock and queue_lock at the same time. Also, since we
	  remove iog from iocg->group_data under iocg->lock, we can't
	  race with elevator switch.

	- Elevator switch path does not remove iog from
	  iocg->group_data list directly. It first hold iocg->lock,
	  scans iocg->group_data again to see if iog is still there;
	  it removes iog only if it finds iog there. Otherwise, cgroup
	  deletion must have removed it from the list, and cgroup
	  deletion is responsible for removing iog.

  So the path which removes iog from iocg->group_data list does
  the final removal of iog by calling __io_destroy_group()
  function.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/cfq-iosched.c |    3 +
 block/elevator-fq.c |  890 ++++++++++++++++++++++++++++++++++++++++++++++-----
 block/elevator-fq.h |   91 +++++-
 block/elevator.c    |    4 +
 4 files changed, 911 insertions(+), 77 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 09b56e7..98fd508 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1354,6 +1354,9 @@ alloc_cfqq:
 			cfqq->ioq = ioq;
 			cfq_init_cfqq(cfqd, cfqq, current->pid, is_sync);
 			cfq_init_prio_data(cfqq, ioc);
+
+			/* ioq reference on iog */
+			elv_get_iog(iog);
 			cfq_log_cfqq(cfqd, cfqq, "alloced");
 		} else {
 			cfqq = &cfqd->oom_cfqq;
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index d72e697..eddb422 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -41,6 +41,9 @@ static struct kmem_cache *elv_ioq_pool;
  */
 #define WFQ_SERVICE_SHIFT	22
 
+static void
+elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
+
 #ifdef CONFIG_GROUP_IOSCHED
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = entity->parent)
@@ -86,6 +89,69 @@ static inline void bfq_check_next_active(struct io_sched_data *sd,
 {
 	BUG_ON(sd->next_active != entity);
 }
+
+static inline int iog_deleting(struct io_group *iog)
+{
+	return iog->deleting;
+}
+
+/* Do the two (enqueued) entities belong to the same group ? */
+static inline int
+is_same_group(struct io_entity *entity, struct io_entity *new_entity)
+{
+	if (entity->sched_data == new_entity->sched_data)
+		return 1;
+
+	return 0;
+}
+
+static inline struct io_entity *parent_entity(struct io_entity *entity)
+{
+	return entity->parent;
+}
+
+/* return depth at which a io entity is present in the hierarchy */
+static inline int depth_entity(struct io_entity *entity)
+{
+	int depth = 0;
+
+	for_each_entity(entity)
+		depth++;
+
+	return depth;
+}
+
+static void bfq_find_matching_entity(struct io_entity **entity,
+			struct io_entity **new_entity)
+{
+	int entity_depth, new_entity_depth;
+
+	/*
+	 * preemption test can be made between sibling entities who are in the
+	 * same group i.e who have a common parent. Walk up the hierarchy of
+	 * both entities until we find their ancestors who are siblings of
+	 * common parent.
+	 */
+
+	/* First walk up until both entities are at same depth */
+	entity_depth = depth_entity(*entity);
+	new_entity_depth = depth_entity(*new_entity);
+
+	while (entity_depth > new_entity_depth) {
+		entity_depth--;
+		*entity = parent_entity(*entity);
+	}
+
+	while (new_entity_depth > entity_depth) {
+		new_entity_depth--;
+		*new_entity = parent_entity(*new_entity);
+	}
+
+	while (!is_same_group(*entity, *new_entity)) {
+		*entity = parent_entity(*entity);
+		*new_entity = parent_entity(*new_entity);
+	}
+}
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -102,6 +168,23 @@ static inline void bfq_check_next_active(struct io_sched_data *sd,
 					 struct io_entity *entity)
 {
 }
+
+static inline int iog_deleting(struct io_group *iog)
+{
+	/* In flat mode, root cgroup can't be deleted. */
+	return 0;
+}
+
+static void bfq_find_matching_entity(struct io_entity **entity,
+					struct io_entity **new_entity)
+{
+}
+
+static inline int
+is_same_group(struct io_entity *entity, struct io_entity *new_entity)
+{
+	return 1;
+}
 #endif /* GROUP_IOSCHED */
 
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
@@ -359,12 +442,6 @@ static void bfq_get_entity(struct io_entity *entity)
 		elv_get_ioq(ioq);
 }
 
-static inline void
-bfq_init_entity(struct io_entity *entity, struct io_group *iog)
-{
-	entity->sched_data = &iog->sched_data;
-}
-
 /**
  * bfq_find_deepest - find the deepest node that an extraction can modify.
  * @node: the node being removed.
@@ -832,8 +909,26 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 static void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
 	struct io_sched_data *sd;
+	struct io_group *iog, *__iog;
 	struct io_entity *parent;
 
+	iog = container_of(entity->sched_data, struct io_group, sched_data);
+
+	/*
+	 * Hold a reference to entity's iog until we are done. This function
+	 * travels the hierarchy and we don't want to free up the group yet
+	 * while we are traversing the hiearchy. It is possible that this
+	 * group's cgroup has been removed hence cgroup reference is gone.
+	 * If this entity was active entity, then its group will not be on
+	 * any of the trees and it will be freed up the moment queue is
+	 * freed up in __bfq_deactivate_entity().
+	 *
+	 * Hence, hold a reference, deactivate the hierarhcy of entities and
+	 * then drop the reference which should free up the whole chain of
+	 * groups.
+	 */
+	elv_get_iog(iog);
+
 	for_each_entity_safe(entity, parent) {
 		sd = entity->sched_data;
 
@@ -851,6 +946,7 @@ static void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 			 * the budgets on the path towards the root
 			 * need to be updated.
 			 */
+			elv_put_iog(iog);
 			goto update;
 		}
 
@@ -858,11 +954,16 @@ static void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 		 * If we reach there the parent is no more backlogged and
 		 * we want to propagate the dequeue upwards.
 		 *
+		 * If entity's group has been marked for deletion, don't
+		 * requeue the group in idle tree so that it can be freed.
 		 */
-
-		requeue = 1;
+		__iog = container_of(entity->sched_data, struct io_group,
+						sched_data);
+		if (!iog_deleting(__iog))
+			requeue = 1;
 	}
 
+	elv_put_iog(iog);
 	return;
 
 update:
@@ -901,8 +1002,57 @@ static void io_flush_idle_tree(struct io_service_tree *st)
 		__bfq_deactivate_entity(entity, 0);
 }
 
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
 /* Mainly hierarchical grouping code */
 #ifdef CONFIG_GROUP_IOSCHED
+static void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup);
+
+static inline void
+bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->parent = iog->my_entity;
+	entity->sched_data = &iog->sched_data;
+}
+
+static void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
+{
+	struct io_entity *entity = &iog->entity;
+
+	entity->weight = iocg->weight;
+	entity->ioprio_class = entity->new_ioprio_class = iocg->ioprio_class;
+	entity->ioprio_changed = 1;
+	entity->my_sched_data = &iog->sched_data;
+}
+
+static void io_group_set_parent(struct io_group *iog, struct io_group *parent)
+{
+	struct io_entity *entity;
+
+	BUG_ON(parent == NULL);
+	BUG_ON(iog == NULL);
+
+	entity = &iog->entity;
+	entity->parent = parent->my_entity;
+	entity->sched_data = &parent->sched_data;
+	if (entity->parent)
+		/* Child group reference on parent group. */
+		elv_get_iog(parent);
+}
 
 struct io_cgroup io_root_cgroup = {
 	.weight = IO_DEFAULT_GRP_WEIGHT,
@@ -915,6 +1065,26 @@ static struct io_cgroup *cgroup_to_io_cgroup(struct cgroup *cgroup)
 			    struct io_cgroup, css);
 }
 
+/*
+ * Search the io_group for efqd into the hash table (by now only a list)
+ * of bgrp.  Must be called under rcu_read_lock().
+ */
+static struct io_group *
+io_cgroup_lookup_group(struct io_cgroup *iocg, void *key)
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
 #define SHOW_FUNCTION(__VAR)						\
 static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,		\
 				       struct cftype *cftype)		\
@@ -1055,12 +1225,6 @@ static void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 	task_unlock(tsk);
 }
 
-static void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
-{
-
-	/* Implemented in later patch */
-}
-
 struct cgroup_subsys io_subsys = {
 	.name = "io",
 	.create = iocg_create,
@@ -1071,7 +1235,597 @@ struct cgroup_subsys io_subsys = {
 	.subsys_id = io_subsys_id,
 	.use_id = 1,
 };
+
+static inline unsigned int iog_weight(struct io_group *iog)
+{
+	return iog->entity.weight;
+}
+
+/**
+ * io_group_chain_alloc - allocate a chain of groups.
+ * @efqd: queue descriptor.
+ * @cgroup: the leaf cgroup this chain starts from.
+ *
+ * Allocate a chain of groups starting from the one belonging to
+ * @cgroup up to the root cgroup.  Stop if a cgroup on the chain
+ * to the root has already an allocated group on @efqd.
+ */
+static struct io_group *
+io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
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
+			 * root must have a io_group for efqd, so we don't
+			 * need any more allocations.
+			 */
+			break;
+		}
+
+		iog = kzalloc_node(sizeof(*iog), flags, q->node);
+		if (!iog)
+			goto cleanup;
+
+		iog->iocg_id = css_id(&iocg->css);
+
+		io_group_init_entity(iocg, iog);
+		iog->my_entity = &iog->entity;
+
+		atomic_set(&iog->ref, 0);
+		iog->deleting = 0;
+
+		/*
+		 * Take the initial reference that will be released on destroy
+		 * This can be thought of a joint reference by cgroup and
+		 * elevator which will be dropped by either elevator exit
+		 * or cgroup deletion path depending on who is exiting first.
+		 */
+		elv_get_iog(iog);
+
+		if (leaf == NULL) {
+			leaf = iog;
+			prev = leaf;
+		} else {
+			io_group_set_parent(prev, iog);
+			/*
+			 * Build a list of allocated nodes using the efqd
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
+		kfree(prev);
+	}
+
+	return NULL;
+}
+
+/**
+ * io_group_chain_link - link an allocatd group chain to a cgroup hierarchy.
+ * @efqd: the queue descriptor.
+ * @cgroup: the leaf cgroup to start from.
+ * @leaf: the leaf group (to be associated to @cgroup).
+ *
+ * Try to link a chain of groups to a cgroup hierarchy, connecting the
+ * nodes bottom-up, so we can be sure that when we find a cgroup in the
+ * hierarchy that already as a group associated to @efqd all the nodes
+ * in the path to the root cgroup have one too.
+ *
+ * On locking: the queue lock protects the hierarchy (there is a hierarchy
+ * per device) while the io_cgroup lock protects the list of groups
+ * belonging to the same cgroup.
+ */
+static void io_group_chain_link(struct request_queue *q, void *key,
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
+ * io_find_alloc_group - return the group associated to @efqd in @cgroup.
+ * @fqd: queue descriptor.
+ * @cgroup: cgroup being searched for.
+ * @create: if set to 1, create the io group if it has not been created yet.
+ *
+ * Return a group associated to @fqd in @cgroup, allocating one if
+ * necessary.  When a group is returned all the cgroups in the path
+ * to the root have a group associated to @efqd.
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
+static struct io_group *io_find_alloc_group(struct request_queue *q,
+			struct cgroup *cgroup, struct elv_fq_data *efqd,
+			int create)
+{
+	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
+	struct io_group *iog = NULL;
+	/* Note: Use efqd as key */
+	void *key = efqd;
+
+	/*
+	 * Take a refenrece to css object. Don't want to map a bio to
+	 * a group if it has been marked for deletion
+	 */
+
+	if (!css_tryget(&iocg->css))
+		return iog;
+
+	iog = io_cgroup_lookup_group(iocg, key);
+	if (iog != NULL || !create)
+		goto end;
+
+	iog = io_group_chain_alloc(q, key, cgroup);
+	if (iog != NULL)
+		io_group_chain_link(q, key, cgroup, iog, efqd);
+
+end:
+	css_put(&iocg->css);
+	return iog;
+}
+
+/*
+ * Search for the io group current task belongs to. If create=1, then also
+ * create the io group if it is not already there.
+ *
+ * Note: This function should be called with queue lock held. It returns
+ * a pointer to io group without taking any reference. That group will
+ * be around as long as queue lock is not dropped (as group reclaim code
+ * needs to get hold of queue lock). So if somebody needs to use group
+ * pointer even after dropping queue lock, take a reference to the group
+ * before dropping queue lock.
+ */
+struct io_group *io_get_io_group(struct request_queue *q, int create)
+{
+	struct cgroup *cgroup;
+	struct io_group *iog;
+	struct elv_fq_data *efqd = &q->elevator->efqd;
+
+	assert_spin_locked(q->queue_lock);
+
+	rcu_read_lock();
+	cgroup = task_cgroup(current, io_subsys_id);
+	iog = io_find_alloc_group(q, cgroup, efqd, create);
+	if (!iog) {
+		if (create)
+			iog = efqd->root_group;
+		else
+			/*
+			 * bio merge functions doing lookup don't want to
+			 * map bio to root group by default
+			 */
+			iog = NULL;
+	}
+	rcu_read_unlock();
+	return iog;
+}
+EXPORT_SYMBOL(io_get_io_group);
+
+static void io_free_root_group(struct elevator_queue *e)
+{
+	struct io_cgroup *iocg = &io_root_cgroup;
+	struct elv_fq_data *efqd = &e->efqd;
+	struct io_group *iog = efqd->root_group;
+	struct io_service_tree *st;
+	int i;
+
+	BUG_ON(!iog);
+	spin_lock_irq(&iocg->lock);
+	hlist_del_rcu(&iog->group_node);
+	spin_unlock_irq(&iocg->lock);
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		io_flush_idle_tree(st);
+	}
+
+	io_put_io_group_queues(e, iog);
+	elv_put_iog(iog);
+}
+
+static struct io_group *io_alloc_root_group(struct request_queue *q,
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
+	elv_get_iog(iog);
+	iog->entity.parent = NULL;
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
+		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
+
+	iocg = &io_root_cgroup;
+	spin_lock_irq(&iocg->lock);
+	rcu_assign_pointer(iog->key, key);
+	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
+	iog->iocg_id = css_id(&iocg->css);
+	spin_unlock_irq(&iocg->lock);
+
+	return iog;
+}
+
+static void io_group_free_rcu(struct rcu_head *head)
+{
+	struct io_group *iog;
+
+	iog = container_of(head, struct io_group, rcu_head);
+	kfree(iog);
+}
+
+/*
+ * This cleanup function does the last bit of things to destroy cgroup.
+ * It should only get called after io_destroy_group has been invoked.
+ */
+static void io_group_cleanup(struct io_group *iog)
+{
+	struct io_service_tree *st;
+	struct io_entity *entity = iog->my_entity;
+	int i;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+
+		BUG_ON(!RB_EMPTY_ROOT(&st->active));
+		BUG_ON(!RB_EMPTY_ROOT(&st->idle));
+		BUG_ON(st->wsum != 0);
+	}
+
+	BUG_ON(iog->sched_data.next_active != NULL);
+	BUG_ON(iog->sched_data.active_entity != NULL);
+	BUG_ON(entity != NULL && entity->tree != NULL);
+
+	/*
+	 * Wait for any rcu readers to exit before freeing up the group.
+	 * Primarily useful when io_get_io_group() is called without queue
+	 * lock to access some group data from bdi_congested_group() path.
+	 */
+	call_rcu(&iog->rcu_head, io_group_free_rcu);
+}
+
+void elv_put_iog(struct io_group *iog)
+{
+	struct io_group *parent = NULL;
+	struct io_entity *entity;
+
+	BUG_ON(!iog);
+
+	entity = iog->my_entity;
+
+	BUG_ON(atomic_read(&iog->ref) <= 0);
+	if (!atomic_dec_and_test(&iog->ref))
+		return;
+
+	if (entity)
+		parent = container_of(iog->my_entity->parent,
+					struct io_group, entity);
+
+	io_group_cleanup(iog);
+
+	if (parent)
+		elv_put_iog(parent);
+}
+EXPORT_SYMBOL(elv_put_iog);
+
+/*
+ * check whether a given group has got any active entities on any of the
+ * service tree.
+ */
+static inline int io_group_has_active_entities(struct io_group *iog)
+{
+	int i;
+	struct io_service_tree *st;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		if (!RB_EMPTY_ROOT(&st->active))
+			return 1;
+	}
+
+	/*
+	 * Also check there are no active entities being served which are
+	 * not on active tree
+	 */
+
+	if (iog->sched_data.active_entity)
+		return 1;
+
+	return 0;
+}
+
+/*
+ * After the group is destroyed, no new sync IO should come to the group.
+ * It might still have pending IOs in some busy queues. It should be able to
+ * send those IOs down to the disk. The async IOs (due to dirty page writeback)
+ * would go in the root group queues after this, as the group does not exist
+ * anymore.
+ */
+static void __io_destroy_group(struct elv_fq_data *efqd, struct io_group *iog)
+{
+	struct elevator_queue *eq;
+	struct io_service_tree *st;
+	int i;
+
+	BUG_ON(iog->my_entity == NULL);
+
+	/*
+	 * Mark io group for deletion so that no new entry goes in
+	 * idle tree. Any active queue will be removed from active
+	 * tree and not put in to idle tree.
+	 */
+	iog->deleting = 1;
+
+	/* We flush idle tree now, and don't put things in there any more. */
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+
+		io_flush_idle_tree(st);
+	}
+
+	eq = container_of(efqd, struct elevator_queue, efqd);
+	hlist_del(&iog->elv_data_node);
+	io_put_io_group_queues(eq, iog);
+
+	/*
+	 * We can come here either through cgroup deletion path or through
+	 * elevator exit path. If we come here through cgroup deletion path
+	 * check if io group has any active entities or not. If not, then
+	 * deactivate this io group to make sure it is removed from idle
+	 * tree it might have been on. If this group was on idle tree, then
+	 * this probably will be the last reference and group will be
+	 * freed upon putting the reference down.
+	 */
+
+	if (!io_group_has_active_entities(iog)) {
+		/*
+		 * io group does not have any active entites. Because this
+		 * group has been decoupled from io_cgroup list and this
+		 * cgroup is being deleted, this group should not receive
+		 * any new IO. Hence it should be safe to deactivate this
+		 * io group and remove from the scheduling tree.
+		 */
+		__bfq_deactivate_entity(iog->my_entity, 0);
+	}
+
+	/*
+	 * Put the reference taken at the time of creation so that when all
+	 * queues are gone, cgroup can be destroyed.
+	 */
+	elv_put_iog(iog);
+}
+
+static void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+{
+	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
+	struct io_group *iog;
+	struct elv_fq_data *efqd;
+	unsigned long uninitialized_var(flags);
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
+	 * (iocg->group_data) is protected by iocg->lock. To avoid deadlock,
+	 * we can't hold the queue lock while holding iocg->lock. So we first
+	 * remove iog from iocg->group_data under iocg->lock. Whoever removes
+	 * iog from iocg->group_data should call __io_destroy_group to remove
+	 * iog.
+	 */
+
+	rcu_read_lock();
+
+remove_entry:
+	spin_lock_irqsave(&iocg->lock, flags);
+
+	if (hlist_empty(&iocg->group_data)) {
+		spin_unlock_irqrestore(&iocg->lock, flags);
+		goto done;
+	}
+	iog = hlist_entry(iocg->group_data.first, struct io_group,
+			  group_node);
+	efqd = rcu_dereference(iog->key);
+	hlist_del_rcu(&iog->group_node);
+	iog->iocg_id = 0;
+	spin_unlock_irqrestore(&iocg->lock, flags);
+
+	spin_lock_irqsave(efqd->queue->queue_lock, flags);
+	__io_destroy_group(efqd, iog);
+	spin_unlock_irqrestore(efqd->queue->queue_lock, flags);
+	goto remove_entry;
+
+done:
+	free_css_id(&io_subsys, &iocg->css);
+	rcu_read_unlock();
+	BUG_ON(!hlist_empty(&iocg->group_data));
+	kfree(iocg);
+}
+
+/*
+ * This functions checks if iog is still in iocg->group_data, and removes it.
+ * If iog is not in that list, then cgroup destroy path has removed it, and
+ * we do not need to remove it.
+ */
+static void io_group_check_and_destroy(struct elv_fq_data *efqd,
+					struct io_group *iog)
+{
+	struct io_cgroup *iocg;
+	unsigned long flags;
+	struct cgroup_subsys_state *css;
+
+	rcu_read_lock();
+
+	css = css_lookup(&io_subsys, iog->iocg_id);
+
+	if (!css)
+		goto out;
+
+	iocg = container_of(css, struct io_cgroup, css);
+
+	spin_lock_irqsave(&iocg->lock, flags);
+
+	if (iog->iocg_id) {
+		hlist_del_rcu(&iog->group_node);
+		__io_destroy_group(efqd, iog);
+	}
+
+	spin_unlock_irqrestore(&iocg->lock, flags);
+out:
+	rcu_read_unlock();
+}
+
+static void io_disconnect_groups(struct elevator_queue *e)
+{
+	struct hlist_node *pos, *n;
+	struct io_group *iog;
+	struct elv_fq_data *efqd = &e->efqd;
+
+	hlist_for_each_entry_safe(iog, pos, n, &efqd->group_list,
+					elv_data_node) {
+		io_group_check_and_destroy(efqd, iog);
+	}
+}
+
+/*
+ * if bio sumbmitting task and rq don't belong to same io_group, it can't
+ * be merged
+ */
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
+	iog = io_get_io_group(q, 0);
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
+#else /* GROUP_IOSCHED */
+static inline void
+bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->sched_data = &iog->sched_data;
+}
+
+static inline void io_disconnect_groups(struct elevator_queue *e) {}
+static inline unsigned int iog_weight(struct io_group *iog) { return 0; }
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
+struct io_group *io_get_io_group(struct request_queue *q, int create)
+{
+	/* In flat mode, there is only root group */
+	return q->elevator->efqd.root_group;
+}
+EXPORT_SYMBOL(io_get_io_group);
 #endif /* GROUP_IOSCHED */
+
 /* Elevator fair queuing function */
 static inline struct io_queue *elv_active_ioq(struct elevator_queue *e)
 {
@@ -1284,10 +2038,14 @@ void elv_put_ioq(struct io_queue *ioq)
 	struct elv_fq_data *efqd = ioq->efqd;
 	struct elevator_queue *e = container_of(efqd, struct elevator_queue,
 						efqd);
+	struct io_group *iog;
 
 	BUG_ON(atomic_read(&ioq->ref) <= 0);
 	if (!atomic_dec_and_test(&ioq->ref))
 		return;
+
+	iog = ioq_to_io_group(ioq);
+
 	BUG_ON(ioq->nr_queued);
 	BUG_ON(ioq->entity.tree != NULL);
 	BUG_ON(elv_ioq_busy(ioq));
@@ -1299,10 +2057,11 @@ void elv_put_ioq(struct io_queue *ioq)
 	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
 	elv_log_ioq(efqd, ioq, "put_queue");
 	elv_free_ioq(ioq);
+	elv_put_iog(iog);
 }
 EXPORT_SYMBOL(elv_put_ioq);
 
-void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
+static void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
 {
 	struct io_queue *ioq = *ioq_ptr;
 
@@ -1321,6 +2080,7 @@ static void elv_activate_ioq(struct io_queue *ioq, int add_front)
 static void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 					int requeue)
 {
+	requeue = update_requeue(ioq, requeue);
 	bfq_deactivate_entity(&ioq->entity, requeue);
 }
 
@@ -1399,8 +2159,12 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 	struct request_queue *q = efqd->queue;
 
 	if (ioq) {
-		elv_log_ioq(efqd, ioq, "set_active, busy=%d",
-							efqd->busy_queues);
+		struct io_group *iog = ioq_to_io_group(ioq);
+		elv_log_ioq(efqd, ioq, "set_active, busy=%d ioprio=%d"
+				" weight=%u group_weight=%u",
+				efqd->busy_queues,
+				ioq->entity.ioprio, ioq->entity.weight,
+				iog_weight(iog));
 		ioq->slice_end = 0;
 		ioq->slice_start = jiffies;
 
@@ -1585,6 +2349,7 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 	struct io_queue *ioq;
 	struct elevator_queue *eq = q->elevator;
 	struct io_entity *entity, *new_entity;
+	struct io_group *iog = NULL, *new_iog = NULL;
 
 	ioq = elv_active_ioq(eq);
 
@@ -1595,6 +2360,13 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 	new_entity = &new_ioq->entity;
 
 	/*
+	 * In hierarchical setup, one need to traverse up the hierarchy
+	 * till both the queues are children of same parent to make a
+	 * decision whether to do the preemption or not.
+	 */
+	bfq_find_matching_entity(&entity, &new_entity);
+
+	/*
 	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
 	 */
 
@@ -1610,9 +2382,17 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 		return 1;
 
 	/*
-	 * Check with io scheduler if it has additional criterion based on
-	 * which it wants to preempt existing queue.
+	 * If both the queues belong to same group, check with io scheduler
+	 * if it has additional criterion based on which it wants to
+	 * preempt existing queue.
 	 */
+	iog = ioq_to_io_group(ioq);
+	new_iog = ioq_to_io_group(new_ioq);
+
+	if (iog != new_iog)
+		return 0;
+
+
 	if (eq->ops->elevator_should_preempt_fn)
 		return eq->ops->elevator_should_preempt_fn(q,
 						ioq_sched_queue(new_ioq), rq);
@@ -1758,6 +2538,10 @@ static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
 	if (q->elevator->ops->elevator_close_cooperator_fn)
 		new_ioq = e->ops->elevator_close_cooperator_fn(q, sched_queue);
 
+	/* Only select co-operating queue if it belongs to same group as ioq */
+	if (new_ioq && !is_same_group(&ioq->entity, &new_ioq->entity))
+		return NULL;
+
 	if (new_ioq)
 		elv_log_ioq(&e->efqd, ioq, "cooperating ioq=%d", new_ioq->pid);
 
@@ -1939,15 +2723,6 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
 		elv_schedule_dispatch(q);
 }
 
-struct io_group *io_get_io_group(struct request_queue *q)
-{
-	struct elv_fq_data *efqd = &q->elevator->efqd;
-
-	/* In flat mode, there is only root group */
-	return efqd->root_group;
-}
-EXPORT_SYMBOL(io_get_io_group);
-
 void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
 					int ioprio)
 {
@@ -1998,53 +2773,6 @@ void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 }
 EXPORT_SYMBOL(io_group_set_async_queue);
 
-/*
- * Release all the io group references to its async queues.
- */
-static void
-io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
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
-static struct io_group *io_alloc_root_group(struct request_queue *q,
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
-static void io_free_root_group(struct elevator_queue *e)
-{
-	struct io_group *iog = e->efqd.root_group;
-	struct io_service_tree *st;
-	int i;
-
-	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
-		st = iog->sched_data.service_tree + i;
-		io_flush_idle_tree(st);
-	}
-
-	io_put_io_group_queues(e, iog);
-	kfree(iog);
-}
-
 static void elv_slab_kill(void)
 {
 	/*
@@ -2099,6 +2827,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->idle_slice_timer.data = (unsigned long) efqd;
 
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
+	INIT_HLIST_HEAD(&efqd->group_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
@@ -2116,12 +2845,23 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 void elv_exit_fq_data(struct elevator_queue *e)
 {
 	struct elv_fq_data *efqd = &e->efqd;
+	struct request_queue *q = efqd->queue;
 
 	if (!elv_iosched_fair_queuing_enabled(e))
 		return;
 
 	elv_shutdown_timer_wq(e);
 
+	spin_lock_irq(q->queue_lock);
+	/* This should drop all the io group references of async queues */
+	io_disconnect_groups(e);
+	spin_unlock_irq(q->queue_lock);
+
+	elv_shutdown_timer_wq(e);
+
+	/* Wait for iog->key accessors to exit their grace periods. */
+	synchronize_rcu();
+
 	BUG_ON(timer_pending(&efqd->idle_slice_timer));
 	io_free_root_group(e);
 }
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 6711c85..ceae511 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -181,19 +181,57 @@ struct io_queue {
 };
 
 #ifdef CONFIG_GROUP_IOSCHED
+/**
+ * struct io_group - per (device, cgroup) data structure.
+ * @entity: schedulable entity to insert into the parent group sched_data.
+ * @sched_data: own sched_data, to contain child entities (they may be
+ *              both io_queues and io_groups).
+ * @group_node: node to be inserted into the io_cgroup->group_data
+ *              list of the containing cgroup's io_cgroup.
+ * @elv_data_node: node to be inserted into the @efqd->group_list list
+ *             of the groups active on the same device; used for cleanup.
+ * @async_queue: array of async queues for all the tasks belonging to
+ *              the group, one queue per ioprio value per ioprio_class,
+ *              except for the idle class that has only one queue.
+ * @async_idle_queue: async queue for the idle class (ioprio is ignored).
+ * @my_entity: pointer to @entity, %NULL for the toplevel group; used
+ *             to avoid too many special cases during group creation/migration.
+ *
+ * Each (device, cgroup) pair has its own io_group, i.e., for each cgroup
+ * there is a set of io_groups, each one collecting the lower-level
+ * entities belonging to the group that are acting on the same device.
+ *
+ * Locking works as follows:
+ *    o @group_node is protected by the io_cgroup lock, and is accessed
+ *      via RCU from its readers.
+ *    o @efqd is protected by the queue lock, RCU is used to access it
+ *      from the readers.
+ *    o All the other fields are protected by the @efqd queue lock.
+ */
 struct io_group {
 	struct io_entity entity;
+	struct hlist_node elv_data_node;
 	struct hlist_node group_node;
 	struct io_sched_data sched_data;
+	atomic_t ref;
 	struct io_entity *my_entity;
 
 	/*
+	 * A cgroup has multiple io_groups, one for each request queue.
+	 * to find io group belonging to a particular queue, elv_fq_data
+	 * pointer is stored as a key.
+	 */
+	void *key;
+
+	/*
 	 * async queue for each priority case for RT and BE class.
 	 * Used only for cfq.
 	 */
 
 	struct io_queue *async_queue[2][IOPRIO_BE_NR];
 	struct io_queue *async_idle_queue;
+	struct rcu_head rcu_head;
+	int deleting;
 	unsigned short iocg_id;
 };
 
@@ -231,6 +269,9 @@ struct io_group {
 struct elv_fq_data {
 	struct io_group *root_group;
 
+	/* List of io groups hanging on this elevator */
+	struct hlist_head group_list;
+
 	struct request_queue *queue;
 	unsigned int busy_queues;
 
@@ -366,7 +407,7 @@ static inline void elv_ioq_set_ioprio_class(struct io_queue *ioq,
 static inline unsigned int bfq_ioprio_to_weight(int ioprio)
 {
 	WARN_ON(ioprio < 0 || ioprio >= IOPRIO_BE_NR);
-	return IOPRIO_BE_NR - ioprio;
+	return ((IOPRIO_BE_NR - ioprio) * WEIGHT_MAX)/IOPRIO_BE_NR;
 }
 
 static inline void elv_ioq_set_ioprio(struct io_queue *ioq, int ioprio)
@@ -389,6 +430,46 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
 						sched_data);
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+extern int io_group_allow_merge(struct request *rq, struct bio *bio);
+extern void elv_put_iog(struct io_group *iog);
+
+static inline void elv_get_iog(struct io_group *iog)
+{
+	atomic_inc(&iog->ref);
+}
+
+static inline int update_requeue(struct io_queue *ioq, int requeue)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+
+	if (iog->deleting == 1)
+		return 0;
+
+	return requeue;
+}
+
+#else /* !GROUP_IOSCHED */
+static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
+{
+	return 1;
+}
+
+static inline void elv_get_iog(struct io_group *iog)
+{
+}
+
+static inline void elv_put_iog(struct io_group *iog)
+{
+}
+
+static inline int update_requeue(struct io_queue *ioq, int requeue)
+{
+	return requeue;
+}
+
+#endif /* GROUP_IOSCHED */
+
 extern ssize_t elv_slice_sync_show(struct elevator_queue *q, char *name);
 extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
 						size_t count);
@@ -437,7 +518,7 @@ extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
 					int ioprio);
 extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 					int ioprio, struct io_queue *ioq);
-extern struct io_group *io_get_io_group(struct request_queue *q);
+extern struct io_group *io_get_io_group(struct request_queue *q, int create);
 extern int elv_nr_busy_ioq(struct elevator_queue *e);
 extern int elv_rq_in_driver(struct elevator_queue *e);
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
@@ -489,5 +570,11 @@ static inline void *elv_fq_select_ioq(struct request_queue *q, int force)
 {
 	return NULL;
 }
+
+static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
+
+{
+	return 1;
+}
 #endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _BFQ_SCHED_H */
diff --git a/block/elevator.c b/block/elevator.c
index 42dd0a6..9f4b60f 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -113,6 +113,10 @@ int elv_rq_merge_ok(struct request *rq, struct bio *bio)
 	    !bio_failfast_driver(bio)	 != !blk_failfast_driver(rq))
 		return 0;
 
+	/* If rq and bio belongs to different groups, dont allow merging */
+	if (!io_group_allow_merge(rq, bio))
+		return 0;
+
 	if (!elv_iosched_allow_merge(rq, bio))
 		return 0;
 
-- 
1.6.0.6
