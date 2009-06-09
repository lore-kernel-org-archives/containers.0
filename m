From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/19] io-controller: Common hierarchical fair queuing code in
	elevaotor layer
Date: Mon,  8 Jun 2009 22:08:48 -0400
Message-ID: <1244513342-11758-6-git-send-email-vgoyal__12447.5765195259$1244515935$gmane$org@redhat.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
 block/blk-ioc.c               |    3 +
 block/cfq-iosched.c           |    2 +
 block/elevator-fq.c           | 1156 +++++++++++++++++++++++++++++++++++++----
 block/elevator-fq.h           |  163 ++++++-
 block/elevator.c              |    4 +
 include/linux/blkdev.h        |    2 +-
 include/linux/cgroup_subsys.h |    7 +
 include/linux/iocontext.h     |    5 +
 init/Kconfig                  |    8 +
 9 files changed, 1242 insertions(+), 108 deletions(-)

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
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index f90c534..8888631 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1313,6 +1313,8 @@ alloc_ioq:
 			elv_mark_ioq_sync(cfqq->ioq);
 		}
 		cfqq->pid = current->pid;
+		/* ioq reference on iog */
+		elv_get_iog(iog);
 		cfq_log_cfqq(cfqd, cfqq, "alloced");
 	}
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 7778701..1640949 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -26,6 +26,10 @@ static int elv_rate_sampling_window = HZ / 10;
 
 #define ELV_SLICE_SCALE		(5)
 #define ELV_HW_QUEUE_MIN	(5)
+
+#define IO_DEFAULT_GRP_WEIGHT  500
+#define IO_DEFAULT_GRP_CLASS   IOPRIO_CLASS_BE
+
 #define IO_SERVICE_TREE_INIT   ((struct io_service_tree)		\
 				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
 
@@ -33,6 +37,7 @@ static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
 					struct io_queue *ioq, int probe);
 struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 						 int extract);
+void elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
 
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
 					unsigned short prio)
@@ -51,6 +56,85 @@ elv_prio_to_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
 }
 
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
+void elv_activate_ioq(struct io_queue *ioq, int add_front);
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
+
+static inline int iog_deleting(struct io_group *iog)
+{
+	return iog->deleting;
+}
+
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
+
+static inline int iog_deleting(struct io_group *iog)
+{
+	/* In flat mode, root cgroup can't be deleted. */
+	return 0;
+}
+#endif
 
 /*
  * Shift for timestamp calculations.  This actually limits the maximum
@@ -283,7 +367,6 @@ static void bfq_active_insert(struct io_service_tree *st,
 	struct rb_node *node = &entity->rb_node;
 
 	bfq_insert(&st->active, entity);
-
 	if (node->rb_left != NULL)
 		node = node->rb_left;
 	else if (node->rb_right != NULL)
@@ -292,16 +375,6 @@ static void bfq_active_insert(struct io_service_tree *st,
 	bfq_update_active_tree(node);
 }
 
-/**
- * bfq_ioprio_to_weight - calc a weight from an ioprio.
- * @ioprio: the ioprio value to convert.
- */
-static bfq_weight_t bfq_ioprio_to_weight(int ioprio)
-{
-	WARN_ON(ioprio < 0 || ioprio >= IOPRIO_BE_NR);
-	return IOPRIO_BE_NR - ioprio;
-}
-
 void bfq_get_entity(struct io_entity *entity)
 {
 	struct io_queue *ioq = io_entity_to_ioq(entity);
@@ -310,13 +383,6 @@ void bfq_get_entity(struct io_entity *entity)
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
@@ -359,7 +425,6 @@ static void bfq_active_extract(struct io_service_tree *st,
 
 	node = bfq_find_deepest(&entity->rb_node);
 	bfq_extract(&st->active, entity);
-
 	if (node != NULL)
 		bfq_update_active_tree(node);
 }
@@ -454,8 +519,10 @@ __bfq_entity_update_prio(struct io_service_tree *old_st,
 	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	if (entity->ioprio_changed) {
+		old_st->wsum -= entity->weight;
 		entity->ioprio = entity->new_ioprio;
 		entity->ioprio_class = entity->new_ioprio_class;
+		entity->weight = entity->new_weight;
 		entity->ioprio_changed = 0;
 
 		/*
@@ -467,9 +534,6 @@ __bfq_entity_update_prio(struct io_service_tree *old_st,
 			entity->budget = elv_prio_to_slice(efqd, ioq);
 		}
 
-		old_st->wsum -= entity->weight;
-		entity->weight = bfq_ioprio_to_weight(entity->ioprio);
-
 		/*
 		 * NOTE: here we may be changing the weight too early,
 		 * this will cause unfairness.  The correct approach
@@ -551,11 +615,8 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 	if (add_front) {
 		struct io_entity *next_entity;
 
-		/*
-		 * Determine the entity which will be dispatched next
-		 * Use sd->next_active once hierarchical patch is applied
-		 */
-		next_entity = bfq_lookup_next_entity(sd, 0);
+		/* Determine the entity which will be dispatched next */
+		next_entity = sd->next_active;
 
 		if (next_entity && next_entity != entity) {
 			struct io_service_tree *new_st;
@@ -582,12 +643,27 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 }
 
 /**
- * bfq_activate_entity - activate an entity.
+ * bfq_activate_entity - activate an entity and its ancestors if necessary.
  * @entity: the entity to activate.
+ * Activate @entity and all the entities on the path from it to the root.
  */
 void bfq_activate_entity(struct io_entity *entity, int add_front)
 {
-	__bfq_activate_entity(entity, add_front);
+	struct io_sched_data *sd;
+
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity, add_front);
+
+		add_front = 0;
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
@@ -623,12 +699,16 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
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
@@ -640,7 +720,74 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
  */
 void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
-	__bfq_deactivate_entity(entity, requeue);
+	struct io_sched_data *sd;
+	struct io_group *iog, *__iog;
+	struct io_entity *parent;
+
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
+		if (sd->next_active != NULL) {
+			/*
+			 * The parent entity is still backlogged and
+			 * the budgets on the path towards the root
+			 * need to be updated.
+			 */
+			elv_put_iog(iog);
+			goto update;
+		}
+
+		/*
+		 * If we reach there the parent is no more backlogged and
+		 * we want to propagate the dequeue upwards.
+		 *
+		 * If entity's group has been marked for deletion, don't
+		 * requeue the group in idle tree so that it can be freed.
+		 */
+
+		__iog = container_of(entity->sched_data, struct io_group,
+						sched_data);
+		if (!iog_deleting(__iog))
+			requeue = 1;
+	}
+
+	elv_put_iog(iog);
+	return;
+
+update:
+	entity = parent;
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity, 0);
+
+		sd = entity->sched_data;
+		if (!bfq_update_next_active(sd))
+			break;
+	}
 }
 
 /**
@@ -757,8 +904,10 @@ struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
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
@@ -770,12 +919,13 @@ struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 void entity_served(struct io_entity *entity, bfq_service_t served)
 {
 	struct io_service_tree *st;
-
-	st = io_entity_service_tree(entity);
-	entity->service += served;
-	BUG_ON(st->wsum == 0);
-	st->vtime += bfq_delta(served, st->wsum);
-	bfq_forget_idle(st);
+	for_each_entity(entity) {
+		st = io_entity_service_tree(entity);
+		entity->service += served;
+		BUG_ON(st->wsum == 0);
+		st->vtime += bfq_delta(served, st->wsum);
+		bfq_forget_idle(st);
+	}
 }
 
 /**
@@ -790,6 +940,817 @@ void io_flush_idle_tree(struct io_service_tree *st)
 		__bfq_deactivate_entity(entity, 0);
 }
 
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
+	.weight = IO_DEFAULT_GRP_WEIGHT,
+	.ioprio_class = IO_DEFAULT_GRP_CLASS,
+};
+
+void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->ioprio = entity->new_ioprio;
+	entity->weight = entity->new_weight;
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
+void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
+{
+	struct io_entity *entity = &iog->entity;
+
+	entity->weight = entity->new_weight = iocg->weight;
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
+	if (entity->parent)
+		/* Child group reference on parent group. */
+		elv_get_iog(parent);
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
+SHOW_FUNCTION(weight);
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
+	iocg->__VAR = (unsigned long)val;				\
+	hlist_for_each_entry(iog, n, &iocg->group_data, group_node) {	\
+		iog->entity.new_##__VAR = (unsigned long)val;		\
+		smp_wmb();						\
+		iog->entity.ioprio_changed = 1;				\
+	}								\
+	spin_unlock_irq(&iocg->lock);					\
+									\
+	cgroup_unlock();						\
+									\
+	return 0;							\
+}
+
+STORE_FUNCTION(weight, 1, WEIGHT_MAX);
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
+		iog->iocg_id = css_id(&iocg->css);
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
+		kfree(prev);
+	}
+
+	return NULL;
+}
+
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
+ * @create: if set to 1, create the io group if it has not been created yet.
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
+void io_free_root_group(struct elevator_queue *e)
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
+struct cftype bfqio_files[] = {
+	{
+		.name = "weight",
+		.read_u64 = io_cgroup_weight_read,
+		.write_u64 = io_cgroup_weight_write,
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
+	iocg->weight = IO_DEFAULT_GRP_WEIGHT;
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
+ * This cleanup function does the last bit of things to destroy cgroup.
+ * It should only get called after io_destroy_group has been invoked.
+ */
+void io_group_cleanup(struct io_group *iog)
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
+	iog->iocg_id = 0;
+	kfree(iog);
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
+void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
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
+void io_group_check_and_destroy(struct elv_fq_data *efqd, struct io_group *iog)
+{
+	struct io_cgroup *iocg;
+	unsigned short id = iog->iocg_id;
+	struct hlist_node *n;
+	struct io_group *__iog;
+	unsigned long flags;
+	struct cgroup_subsys_state *css;
+
+	rcu_read_lock();
+
+	BUG_ON(!id);
+	css = css_lookup(&io_subsys, id);
+
+	/* css can't go away as associated io group is still around */
+	BUG_ON(!css);
+
+	iocg = container_of(css, struct io_cgroup, css);
+
+	spin_lock_irqsave(&iocg->lock, flags);
+	hlist_for_each_entry_rcu(__iog, n, &iocg->group_data, group_node) {
+		/*
+		 * Remove iog only if it is still in iocg list. Cgroup
+		 * deletion could have deleted it already.
+		 */
+		if (__iog == iog) {
+			hlist_del_rcu(&iog->group_node);
+			__io_destroy_group(efqd, iog);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&iocg->lock, flags);
+	rcu_read_unlock();
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
+		io_group_check_and_destroy(efqd, iog);
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
+
+#else /* GROUP_IOSCHED */
+void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
+{
+	entity->ioprio = entity->new_ioprio;
+	entity->weight = entity->new_weight;
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
+void io_free_root_group(struct elevator_queue *e)
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
+	return q->elevator->efqd.root_group;
+}
+EXPORT_SYMBOL(io_get_io_group);
+#endif /* CONFIG_GROUP_IOSCHED*/
+
 /* Elevator fair queuing function */
 struct io_queue *rq_ioq(struct request *rq)
 {
@@ -1135,11 +2096,10 @@ void elv_free_ioq(struct io_queue *ioq)
 EXPORT_SYMBOL(elv_free_ioq);
 
 int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
-			void *sched_queue, int ioprio_class, int ioprio,
-			int is_sync)
+		struct io_group *iog, void *sched_queue, int ioprio_class,
+		int ioprio, int is_sync)
 {
 	struct elv_fq_data *efqd = &eq->efqd;
-	struct io_group *iog = io_lookup_io_group_current(efqd->queue);
 
 	RB_CLEAR_NODE(&ioq->entity.rb_node);
 	atomic_set(&ioq->ref, 0);
@@ -1161,10 +2121,14 @@ void elv_put_ioq(struct io_queue *ioq)
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
@@ -1176,6 +2140,7 @@ void elv_put_ioq(struct io_queue *ioq)
 	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
 	elv_log_ioq(efqd, ioq, "put_queue");
 	elv_free_ioq(ioq);
+	elv_put_iog(iog);
 }
 EXPORT_SYMBOL(elv_put_ioq);
 
@@ -1237,11 +2202,23 @@ struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
 		return NULL;
 
 	sd = &efqd->root_group->sched_data;
-	entity = bfq_lookup_next_entity(sd, 1);
+	for (; sd != NULL; sd = entity->my_sched_data) {
+		entity = bfq_lookup_next_entity(sd, 1);
+		/*
+		 * entity can be null despite the fact that there are busy
+		 * queues. if all the busy queues are under a group which is
+		 * currently under service.
+		 * So if we are just looking for next ioq while something is
+		 * being served, null entity is not an error.
+		 */
+		BUG_ON(!entity && extract);
+
+		if (extract)
+			entity->service = 0;
 
-	BUG_ON(!entity);
-	if (extract)
-		entity->service = 0;
+		if (!entity)
+			return NULL;
+	}
 	ioq = io_entity_to_ioq(entity);
 
 	return ioq;
@@ -1257,8 +2234,12 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 	struct request_queue *q = efqd->queue;
 
 	if (ioq) {
-		elv_log_ioq(efqd, ioq, "set_active, busy=%d",
-							efqd->busy_queues);
+		struct io_group *iog = ioq_to_io_group(ioq);
+		elv_log_ioq(efqd, ioq, "set_active, busy=%d ioprio=%d"
+				" weight=%ld group_weight=%ld",
+				efqd->busy_queues,
+				ioq->entity.ioprio, ioq->entity.weight,
+				iog_weight(iog));
 		ioq->slice_end = 0;
 
 		elv_clear_ioq_wait_request(ioq);
@@ -1323,6 +2304,8 @@ void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 	if (ioq == efqd->active_queue)
 		elv_reset_active_ioq(efqd);
 
+	requeue = update_requeue(ioq, requeue);
+
 	bfq_deactivate_entity(&ioq->entity, requeue);
 }
 
@@ -1493,6 +2476,7 @@ int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 {
 	struct io_queue *ioq;
 	struct elevator_queue *eq = q->elevator;
+	struct io_group *iog = NULL, *new_iog = NULL;
 
 	ioq = elv_active_ioq(eq);
 
@@ -1510,14 +2494,26 @@ int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 
 	/*
 	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
+	 *
+	 * TODO: In hierarchical setup, one need to traverse up the hier
+	 * till both the queues are children of same parent to make a
+	 * decision whether to do the preemption or not. Something like
+	 * what cfs has done for cpu scheduler. Will do it little later.
 	 */
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
 
@@ -1932,14 +2928,6 @@ void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
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
@@ -1990,52 +2978,6 @@ void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
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
@@ -2079,6 +3021,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->idle_slice_timer.data = (unsigned long) efqd;
 
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
+	INIT_HLIST_HEAD(&efqd->group_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
@@ -2098,12 +3041,23 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
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
index 3abcb0b..a37be0f 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -11,11 +11,13 @@
  */
 
 #include <linux/blkdev.h>
+#include <linux/cgroup.h>
 
 #ifndef _BFQ_SCHED_H
 #define _BFQ_SCHED_H
 
 #define IO_IOPRIO_CLASSES	3
+#define WEIGHT_MAX 		1000
 
 typedef u64 bfq_timestamp_t;
 typedef unsigned long bfq_weight_t;
@@ -71,6 +73,7 @@ struct io_service_tree {
  */
 struct io_sched_data {
 	struct io_entity *active_entity;
+	struct io_entity *next_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
 };
 
@@ -86,13 +89,12 @@ struct io_sched_data {
  *             this entity; used for O(log N) lookups into active trees.
  * @service: service received during the last round of service.
  * @budget: budget used to calculate F_i; F_i = S_i + @budget / @weight.
- * @weight: weight of the queue, calculated as IOPRIO_BE_NR - @ioprio.
  * @parent: parent entity, for hierarchical scheduling.
  * @my_sched_data: for non-leaf nodes in the cgroup hierarchy, the
  *                 associated scheduler queue, %NULL on leaf nodes.
  * @sched_data: the scheduler queue this entity belongs to.
- * @ioprio: the ioprio in use.
- * @new_ioprio: when an ioprio change is requested, the new ioprio value
+ * @weight: the weight in use.
+ * @new_weight: when a weight change is requested, the new weight value
  * @ioprio_class: the ioprio_class in use.
  * @new_ioprio_class: when an ioprio_class change is requested, the new
  *                    ioprio_class value.
@@ -134,13 +136,13 @@ struct io_entity {
 	bfq_timestamp_t min_start;
 
 	bfq_service_t service, budget;
-	bfq_weight_t weight;
 
 	struct io_entity *parent;
 
 	struct io_sched_data *my_sched_data;
 	struct io_sched_data *sched_data;
 
+	bfq_weight_t weight, new_weight;
 	unsigned short ioprio, new_ioprio;
 	unsigned short ioprio_class, new_ioprio_class;
 
@@ -181,6 +183,79 @@ struct io_queue {
 	void *sched_queue;
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
+struct io_group {
+	struct io_entity entity;
+	struct hlist_node elv_data_node;
+	struct hlist_node group_node;
+	struct io_sched_data sched_data;
+	atomic_t ref;
+
+	struct io_entity *my_entity;
+
+	/*
+	 * A cgroup has multiple io_groups, one for each request queue.
+	 * to find io group belonging to a particular queue, elv_fq_data
+	 * pointer is stored as a key.
+	 */
+	void *key;
+
+	/* async_queue and idle_queue are used only for cfq */
+	struct io_queue *async_queue[2][IOPRIO_BE_NR];
+	struct io_queue *async_idle_queue;
+
+	int deleting;
+	unsigned short iocg_id;
+};
+
+/**
+ * struct bfqio_cgroup - bfq cgroup data structure.
+ * @css: subsystem state for bfq in the containing cgroup.
+ * @weight: cgroup weight.
+ * @ioprio_class: cgroup ioprio_class.
+ * @lock: spinlock that protects @weight, @ioprio_class and @group_data.
+ * @group_data: list containing the bfq_group belonging to this cgroup.
+ *
+ * @group_data is accessed using RCU, with @lock protecting the updates,
+ * @weight and @ioprio_class are protected by @lock.
+ */
+struct io_cgroup {
+	struct cgroup_subsys_state css;
+
+	unsigned long weight, ioprio_class;
+
+	spinlock_t lock;
+	struct hlist_head group_data;
+};
+#else
 struct io_group {
 	struct io_sched_data sched_data;
 
@@ -188,10 +263,14 @@ struct io_group {
 	struct io_queue *async_queue[2][IOPRIO_BE_NR];
 	struct io_queue *async_idle_queue;
 };
+#endif
 
 struct elv_fq_data {
 	struct io_group *root_group;
 
+	/* List of io groups hanging on this elevator */
+	struct hlist_head group_list;
+
 	struct request_queue *queue;
 	unsigned int busy_queues;
 	/*
@@ -358,9 +437,20 @@ static inline void elv_ioq_set_ioprio_class(struct io_queue *ioq,
 	ioq->entity.ioprio_changed = 1;
 }
 
+/**
+ * bfq_ioprio_to_weight - calc a weight from an ioprio.
+ * @ioprio: the ioprio value to convert.
+ */
+static inline bfq_weight_t bfq_ioprio_to_weight(int ioprio)
+{
+	WARN_ON(ioprio < 0 || ioprio >= IOPRIO_BE_NR);
+	return ((IOPRIO_BE_NR - ioprio) * WEIGHT_MAX)/IOPRIO_BE_NR;
+}
+
 static inline void elv_ioq_set_ioprio(struct io_queue *ioq, int ioprio)
 {
 	ioq->entity.new_ioprio = ioprio;
+	ioq->entity.new_weight = bfq_ioprio_to_weight(ioprio);
 	ioq->entity.ioprio_changed = 1;
 }
 
@@ -377,6 +467,60 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
 						sched_data);
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+extern int io_group_allow_merge(struct request *rq, struct bio *bio);
+extern void elv_put_iog(struct io_group *iog);
+static inline bfq_weight_t iog_weight(struct io_group *iog)
+{
+	return iog->entity.weight;
+}
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
+/*
+ * Currently root group is not part of elevator group list and freed
+ * separately. Hence in case of non-hierarchical setup, nothing todo.
+ */
+static inline void io_disconnect_groups(struct elevator_queue *e) {}
+static inline bfq_weight_t iog_weight(struct io_group *iog)
+{
+	/* Just root group is present and weight is immaterial. */
+	return 0;
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
 /* Functions used by blksysfs.c */
 extern ssize_t elv_slice_idle_show(struct request_queue *q, char *name);
 extern ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
@@ -413,7 +557,8 @@ extern void elv_put_ioq(struct io_queue *ioq);
 extern void __elv_ioq_slice_expired(struct request_queue *q,
 					struct io_queue *ioq);
 extern int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
-		void *sched_queue, int ioprio_class, int ioprio, int is_sync);
+		struct io_group *iog, void *sched_queue, int ioprio_class,
+		int ioprio, int is_sync);
 extern void elv_schedule_dispatch(struct request_queue *q);
 extern int elv_hw_tag(struct elevator_queue *e);
 extern void *elv_active_sched_queue(struct elevator_queue *e);
@@ -425,7 +570,7 @@ extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
 					int ioprio);
 extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 					int ioprio, struct io_queue *ioq);
-extern struct io_group *io_lookup_io_group_current(struct request_queue *q);
+extern struct io_group *io_get_io_group(struct request_queue *q, int create);
 extern int elv_nr_busy_ioq(struct elevator_queue *e);
 extern int elv_nr_busy_rt_ioq(struct elevator_queue *e);
 extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
@@ -478,5 +623,11 @@ static inline void *elv_fq_select_ioq(struct request_queue *q, int force)
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
index c2f07f5..3944385 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -105,6 +105,10 @@ int elv_rq_merge_ok(struct request *rq, struct bio *bio)
 	if (bio_integrity(bio) != blk_integrity_rq(rq))
 		return 0;
 
+	/* If rq and bio belongs to different groups, dont allow merging */
+	if (!io_group_allow_merge(rq, bio))
+		return 0;
+
 	if (!elv_iosched_allow_merge(rq, bio))
 		return 0;
 
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 96a94c9..539cb9d 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -249,7 +249,7 @@ struct request {
 #ifdef CONFIG_ELV_FAIR_QUEUING
 	/* io queue request belongs to */
 	struct io_queue *ioq;
-#endif
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
index 0a2815d..271187f 100644
--- a/include/linux/iocontext.h
+++ b/include/linux/iocontext.h
@@ -69,6 +69,11 @@ struct io_context {
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
index 7be4d38..ab76477 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -606,6 +606,14 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  Now, memory usage of swap_cgroup is 2 bytes per entry. If swap page
 	  size is 4096bytes, 512k per 1Gbytes of swap.
 
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
1.6.0.6
