From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 16/20] io-controller: IO group refcounting support
Date: Tue, 26 May 2009 18:42:05 -0400
Message-ID: <1243377729-2176-17-git-send-email-vgoyal__44759.6111953773$1243381894$gmane$org@redhat.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243377729-2176-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

o In the original BFQ patch once a cgroup is being deleted, it will clean
  up the associated io groups immediately and if there are any active io
  queues with that group, these will be moved to root group. This movement
  of queues is not good from fairness perspective as one can then create
  a cgroup, dump lots of IO and then delete the cgroup and then potentially
  get higher share. Apart from there are more issues hence it was felt that
  we need a io group refcounting mechanism also so that io group can be
  reclaimed asynchronously.

o This is V2 of the io group refcounting patch as implemented by Nauman
  and Divyesh. Currently keeping this patch as a separate one. Once it
  stablizes, will merge it with other patches instead of being a seprate
  one.

o Reference counting for io_group solves many problems, most of which occured
  when we tried to delete the cgroup. Earlier, ioqs were being moved out of
  cgroup to root cgroup. That is problematic in many ways, First, the pending
  requests in queues might get unfair service, and will also cause unfairness
  for other cgroups at the root level. This problem can become signficant if
  cgroups are created and destroyed relatively frequently. Second, moving
  queues to root cgroups was complicated and was causing many BUG_ON's to
  trigger. Third, there is a single io queue in AS, Deadline and Noop within a
  cgroup; and it does not make sense to move it to the root cgroup. The same
  is true of async queues.

o Requests already keep a reference on ioq, so queues keep a reference
  on cgroup. For async queues in CFQ, and single ioq in other
  schedulers, io_group also keeps are reference on io_queue. This
  reference on ioq is dropped when the queue is released
  (elv_release_ioq). So the queue can be freed.

  When a queue is released, it puts the reference to io_group and the
  io_group is released after all the queues are released. Child groups
  also take reference on parent groups, and release it when they are
  destroyed.

o Also we no longer need to maintain a seprate linked list of idle
  entities, which was maintained only to help release the ioq references
  during elevator switch. The code for releasing io_groups is reused for
  elevator switch, resulting in simpler and tight code.

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
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/cfq-iosched.c |   18 ++-
 block/elevator-fq.c |  405 +++++++++++++++++++++++++++++++++------------------
 block/elevator-fq.h |   38 +++++-
 3 files changed, 312 insertions(+), 149 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 75ed566..9b3c263 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1298,8 +1298,8 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	if (async_cfqq != NULL) {
 		__iog = cfqq_to_io_group(async_cfqq);
-
 		if (iog != __iog) {
+			/* cgroup changed, drop the reference to async queue */
 			cic_set_cfqq(cic, NULL, 0);
 			cfq_put_queue(async_cfqq);
 		}
@@ -1307,8 +1307,18 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	if (sync_cfqq != NULL) {
 		__iog = cfqq_to_io_group(sync_cfqq);
-		if (iog != __iog)
-			io_ioq_move(q->elevator, sync_cfqq->ioq, iog);
+
+		/*
+		 * Drop reference to sync queue. A new sync queue will
+		 * be assigned in new group upon arrival of a fresh request.
+		 * If old queue has got requests, those reuests will be
+		 * dispatched over a period of time and queue will be freed
+		 * automatically.
+		 */
+		if (iog != __iog) {
+			cic_set_cfqq(cic, NULL, 1);
+			cfq_put_queue(sync_cfqq);
+		}
 	}
 
 	spin_unlock_irqrestore(q->queue_lock, flags);
@@ -1425,6 +1435,8 @@ alloc_ioq:
 			elv_mark_ioq_sync(cfqq->ioq);
 		}
 		cfqq->pid = current->pid;
+		/* ioq reference on iog */
+		elv_get_iog(iog);
 		cfq_log_cfqq(cfqd, cfqq, "alloced");
 	}
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index bb959f3..9d36227 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -108,6 +108,12 @@ static inline void bfq_check_next_active(struct io_sched_data *sd,
 {
 	BUG_ON(sd->next_active != entity);
 }
+
+static inline int iog_deleting(struct io_group *iog)
+{
+	return iog->deleting;
+}
+
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -124,6 +130,12 @@ static inline void bfq_check_next_active(struct io_sched_data *sd,
 					 struct io_entity *entity)
 {
 }
+
+static inline int iog_deleting(struct io_group *iog)
+{
+	/* In flat mode, root cgroup can't be deleted. */
+	return 0;
+}
 #endif
 
 /*
@@ -224,7 +236,6 @@ static void bfq_idle_extract(struct io_service_tree *st,
 				struct io_entity *entity)
 {
 	struct rb_node *next;
-	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	BUG_ON(entity->tree != &st->idle);
 
@@ -239,10 +250,6 @@ static void bfq_idle_extract(struct io_service_tree *st,
 	}
 
 	bfq_extract(&st->idle, entity);
-
-	/* Delete queue from idle list */
-	if (ioq)
-		list_del(&ioq->queue_list);
 }
 
 /**
@@ -436,7 +443,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
 {
 	struct io_entity *first_idle = st->first_idle;
 	struct io_entity *last_idle = st->last_idle;
-	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
 		st->first_idle = entity;
@@ -444,10 +450,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
 		st->last_idle = entity;
 
 	bfq_insert(&st->idle, entity);
-
-	/* Add this queue to idle list */
-	if (ioq)
-		list_add(&ioq->queue_list, &ioq->efqd->idle_list);
 }
 
 /**
@@ -723,8 +725,26 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
 	struct io_sched_data *sd;
+	struct io_group *iog;
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
 
@@ -736,21 +756,28 @@ void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 			 */
 			break;
 
-		if (sd->next_active != NULL)
+		if (sd->next_active != NULL) {
 			/*
 			 * The parent entity is still backlogged and
 			 * the budgets on the path towards the root
 			 * need to be updated.
 			 */
+			elv_put_iog(iog);
 			goto update;
+		}
 
 		/*
 		 * If we reach there the parent is no more backlogged and
 		 * we want to propagate the dequeue upwards.
+		 *
+		 * If entity's group has been marked for deletion, don't
+		 * requeue the group in idle tree so that it can be freed.
 		 */
-		requeue = 1;
+		if (!iog_deleting(iog))
+			requeue = 1;
 	}
 
+	elv_put_iog(iog);
 	return;
 
 update:
@@ -1008,6 +1035,9 @@ void io_group_set_parent(struct io_group *iog, struct io_group *parent)
 	entity = &iog->entity;
 	entity->parent = parent->my_entity;
 	entity->sched_data = &parent->sched_data;
+	if (entity->parent)
+		/* Child group reference on parent group. */
+		elv_get_iog(parent);
 }
 
 /**
@@ -1176,12 +1206,24 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
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
 
 		if (bio) {
 			struct gendisk *disk = bio->bi_bdev->bd_disk;
 			iog->dev = MKDEV(disk->major, disk->first_minor);
 		}
 
+		iog->iocg_id = css_id(&iocg->css);
+
 		if (leaf == NULL) {
 			leaf = iog;
 			prev = leaf;
@@ -1292,14 +1334,24 @@ struct io_group *io_find_alloc_group(struct request_queue *q,
 	/* Note: Use efqd as key */
 	void *key = efqd;
 
+	/*
+	 * Take a refenrece to css object. Don't want to map a bio to
+	 * a group if it has been marked for deletion
+	 */
+
+	if (!css_tryget(&iocg->css))
+		return iog;
+
 	iog = io_cgroup_lookup_group(iocg, key);
 	if (iog != NULL || !create)
-		return iog;
+		goto end;
 
 	iog = io_group_chain_alloc(q, key, cgroup, bio);
 	if (iog != NULL)
 		io_group_chain_link(q, key, cgroup, iog, efqd);
 
+end:
+	css_put(&iocg->css);
 	return iog;
 }
 
@@ -1344,6 +1396,13 @@ static inline struct cgroup *get_cgroup_from_bio(struct bio *bio)
 /*
  * Find the io group bio belongs to.
  * If "create" is set, io group is created if it is not already present.
+ *
+ * Note: This function should be called with queue lock held. It returns
+ * a pointer to io group without taking any reference. That group will
+ * be around as long as queue lock is not dropped (as group reclaim code
+ * needs to get hold of queue lock). So if somebody needs to use group
+ * pointer even after dropping queue lock, take a reference to the group
+ * before dropping queue lock.
  */
 struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
 					int create)
@@ -1352,6 +1411,8 @@ struct io_group *io_get_io_group(struct request_queue *q, struct bio *bio,
 	struct io_group *iog;
 	struct elv_fq_data *efqd = &q->elevator->efqd;
 
+	assert_spin_locked(q->queue_lock);
+
 	rcu_read_lock();
 
 	if (!bio)
@@ -1390,13 +1451,20 @@ void io_free_root_group(struct elevator_queue *e)
 	struct io_cgroup *iocg = &io_root_cgroup;
 	struct elv_fq_data *efqd = &e->efqd;
 	struct io_group *iog = efqd->root_group;
+	struct io_service_tree *st;
+	int i;
 
 	BUG_ON(!iog);
 	spin_lock_irq(&iocg->lock);
 	hlist_del_rcu(&iog->group_node);
 	spin_unlock_irq(&iocg->lock);
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		io_flush_idle_tree(st);
+	}
 	io_put_io_group_queues(e, iog);
-	kfree(iog);
+	elv_put_iog(iog);
 }
 
 struct io_group *io_alloc_root_group(struct request_queue *q,
@@ -1410,6 +1478,7 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	if (iog == NULL)
 		return NULL;
 
+	elv_get_iog(iog);
 	iog->entity.parent = NULL;
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
@@ -1418,6 +1487,7 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	spin_lock_irq(&iocg->lock);
 	rcu_assign_pointer(iog->key, key);
 	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
+	iog->iocg_id = css_id(&iocg->css);
 	spin_unlock_irq(&iocg->lock);
 
 	return iog;
@@ -1513,106 +1583,149 @@ void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 }
 
 /*
- * Move the queue to the root group if it is active. This is needed when
- * a cgroup is being deleted and all the IO is not done yet. This is not
- * very good scheme as a user might get unfair share. This needs to be
- * fixed.
+ * This cleanup function does the last bit of things to destroy cgroup.
+ * It should only get called after io_destroy_group has been invoked.
  */
-void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
-				struct io_group *iog)
+void io_group_cleanup(struct io_group *iog)
 {
-	int busy, resume;
-	struct io_entity *entity = &ioq->entity;
-	struct elv_fq_data *efqd = &e->efqd;
-	struct io_service_tree *st = io_entity_service_tree(entity);
-
-	busy = elv_ioq_busy(ioq);
-	resume = !!ioq->nr_queued;
+	struct io_service_tree *st;
+	struct io_entity *entity = iog->my_entity;
+	int i;
 
-	BUG_ON(resume && !entity->on_st);
-	BUG_ON(busy && !resume && entity->on_st && ioq != efqd->active_queue);
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
 
-	/*
-	 * We could be moving an queue which is on idle tree of previous group
-	 * What to do? I guess anyway this queue does not have any requests.
-	 * just forget the entity and free up from idle tree.
-	 *
-	 * This needs cleanup. Hackish.
-	 */
-	if (entity->tree == &st->idle) {
-		BUG_ON(atomic_read(&ioq->ref) < 2);
-		bfq_put_idle_entity(st, entity);
+		BUG_ON(!RB_EMPTY_ROOT(&st->active));
+		BUG_ON(!RB_EMPTY_ROOT(&st->idle));
+		BUG_ON(st->wsum != 0);
 	}
 
-	if (busy) {
-		BUG_ON(atomic_read(&ioq->ref) < 2);
+	BUG_ON(iog->sched_data.next_active != NULL);
+	BUG_ON(iog->sched_data.active_entity != NULL);
+	BUG_ON(entity != NULL && entity->tree != NULL);
 
-		if (!resume)
-			elv_del_ioq_busy(e, ioq, 0);
-		else
-			elv_deactivate_ioq(efqd, ioq, 0);
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
 	}
 
 	/*
-	 * Here we use a reference to bfqg.  We don't need a refcounter
-	 * as the cgroup reference will not be dropped, so that its
-	 * destroy() callback will not be invoked.
+	 * Also check there are no active entities being served which are
+	 * not on active tree
 	 */
-	entity->parent = iog->my_entity;
-	entity->sched_data = &iog->sched_data;
 
-	if (busy && resume)
-		elv_activate_ioq(ioq, 0);
+	if (iog->sched_data.active_entity)
+		return 1;
+
+	return 0;
 }
-EXPORT_SYMBOL(io_ioq_move);
 
+/*
+ * After the group is destroyed, no new sync IO should come to the group.
+ * It might still have pending IOs in some busy queues. It should be able to
+ * send those IOs down to the disk. The async IOs (due to dirty page writeback)
+ * would go in the root group queues after this, as the group does not exist
+ * anymore.
+ */
 static void __io_destroy_group(struct elv_fq_data *efqd, struct io_group *iog)
 {
 	struct elevator_queue *eq;
-	struct io_entity *entity = iog->my_entity;
 	struct io_service_tree *st;
 	int i;
 
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
 	eq = container_of(efqd, struct elevator_queue, efqd);
 	hlist_del(&iog->elv_data_node);
-	__bfq_deactivate_entity(entity, 0);
 	io_put_io_group_queues(eq, iog);
 
-	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
-		st = iog->sched_data.service_tree + i;
+	/*
+	 * We can come here either through cgroup deletion path or through
+	 * elevator exit path. If we come here through cgroup deletion path
+	 * check if io group has any active entities or not. If not, then
+	 * deactivate this io group to make sure it is removed from idle
+	 * tree it might have been on. If this group was on idle tree, then
+	 * this probably will be the last reference and group will be
+	 * freed upon putting the reference down.
+	 */
 
+	if (!io_group_has_active_entities(iog)) {
 		/*
-		 * The idle tree may still contain bfq_queues belonging
-		 * to exited task because they never migrated to a different
-		 * cgroup from the one being destroyed now.  Noone else
-		 * can access them so it's safe to act without any lock.
+		 * io group does not have any active entites. Because this
+		 * group has been decoupled from io_cgroup list and this
+		 * cgroup is being deleted, this group should not receive
+		 * any new IO. Hence it should be safe to deactivate this
+		 * io group and remove from the scheduling tree.
 		 */
-		io_flush_idle_tree(st);
-
-		BUG_ON(!RB_EMPTY_ROOT(&st->active));
-		BUG_ON(!RB_EMPTY_ROOT(&st->idle));
+		__bfq_deactivate_entity(iog->my_entity, 0);
 	}
 
-	BUG_ON(iog->sched_data.next_active != NULL);
-	BUG_ON(iog->sched_data.active_entity != NULL);
-	BUG_ON(entity->tree != NULL);
+	/*
+	 * Put the reference taken at the time of creation so that when all
+	 * queues are gone, cgroup can be destroyed.
+	 */
+	elv_put_iog(iog);
 }
 
-/**
- * bfq_destroy_group - destroy @bfqg.
- * @bgrp: the bfqio_cgroup containing @bfqg.
- * @bfqg: the group being destroyed.
- *
- * Destroy @bfqg, making sure that it is not referenced from its parent.
- */
-static void io_destroy_group(struct io_cgroup *iocg, struct io_group *iog)
+void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
 {
-	struct elv_fq_data *efqd = NULL;
+	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
+	struct io_group *iog;
+	struct elv_fq_data *efqd;
 	unsigned long uninitialized_var(flags);
 
-	/* Remove io group from cgroup list */
-	hlist_del(&iog->group_node);
-
 	/*
 	 * io groups are linked in two lists. One list is maintained
 	 * in elevator (efqd->group_list) and other is maintained
@@ -1622,52 +1735,78 @@ static void io_destroy_group(struct io_cgroup *iocg, struct io_group *iog)
 	 * exiting and both might try to cleanup the same io group
 	 * so need to be little careful.
 	 *
-	 * Following code first accesses efqd under RCU to make sure
-	 * iog->key is pointing to valid efqd and then takes the
-	 * associated queue lock. After gettting the queue lock it
-	 * again checks whether elevator exit path had alreday got
-	 * hold of io group (iog->key == NULL). If yes, it does not
-	 * try to free up async queues again or flush the idle tree.
+	 * (iocg->group_data) is protected by iocg->lock. To avoid deadlock,
+	 * we can't hold the queue lock while holding iocg->lock. So we first
+	 * remove iog from iocg->group_data under iocg->lock. Whoever removes
+	 * iog from iocg->group_data should call __io_destroy_group to remove
+	 * iog.
 	 */
 
 	rcu_read_lock();
-	efqd = rcu_dereference(iog->key);
-	if (efqd != NULL) {
-		spin_lock_irqsave(efqd->queue->queue_lock, flags);
-		if (iog->key == efqd)
-			__io_destroy_group(efqd, iog);
-		spin_unlock_irqrestore(efqd->queue->queue_lock, flags);
+
+remove_entry:
+	spin_lock_irqsave(&iocg->lock, flags);
+
+	if (hlist_empty(&iocg->group_data)) {
+		spin_unlock_irqrestore(&iocg->lock, flags);
+		goto done;
 	}
-	rcu_read_unlock();
+	iog = hlist_entry(iocg->group_data.first, struct io_group,
+			  group_node);
+	efqd = rcu_dereference(iog->key);
+	hlist_del_rcu(&iog->group_node);
+	spin_unlock_irqrestore(&iocg->lock, flags);
 
-	/*
-	 * No need to defer the kfree() to the end of the RCU grace
-	 * period: we are called from the destroy() callback of our
-	 * cgroup, so we can be sure that noone is a) still using
-	 * this cgroup or b) doing lookups in it.
-	 */
-	kfree(iog);
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
 }
 
-void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
+/*
+ * This functions checks if iog is still in iocg->group_data, and removes it.
+ * If iog is not in that list, then cgroup destroy path has removed it, and
+ * we do not need to remove it.
+ */
+void io_group_check_and_destroy(struct elv_fq_data *efqd, struct io_group *iog)
 {
-	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
-	struct hlist_node *n, *tmp;
-	struct io_group *iog;
+	struct io_cgroup *iocg;
+	unsigned short id = iog->iocg_id;
+	struct hlist_node *n;
+	struct io_group *__iog;
+	unsigned long flags;
+	struct cgroup_subsys_state *css;
 
-	/*
-	 * Since we are destroying the cgroup, there are no more tasks
-	 * referencing it, and all the RCU grace periods that may have
-	 * referenced it are ended (as the destruction of the parent
-	 * cgroup is RCU-safe); bgrp->group_data will not be accessed by
-	 * anything else and we don't need any synchronization.
-	 */
-	hlist_for_each_entry_safe(iog, n, tmp, &iocg->group_data, group_node)
-		io_destroy_group(iocg, iog);
+	rcu_read_lock();
 
-	BUG_ON(!hlist_empty(&iocg->group_data));
+	BUG_ON(!id);
+	css = css_lookup(&io_subsys, id);
 
-	kfree(iocg);
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
 }
 
 void io_disconnect_groups(struct elevator_queue *e)
@@ -1678,19 +1817,7 @@ void io_disconnect_groups(struct elevator_queue *e)
 
 	hlist_for_each_entry_safe(iog, pos, n, &efqd->group_list,
 					elv_data_node) {
-		hlist_del(&iog->elv_data_node);
-
-		__bfq_deactivate_entity(iog->my_entity, 0);
-
-		/*
-		 * Don't remove from the group hash, just set an
-		 * invalid key.  No lookups can race with the
-		 * assignment as bfqd is being destroyed; this
-		 * implies also that new elements cannot be added
-		 * to the list.
-		 */
-		rcu_assign_pointer(iog->key, NULL);
-		io_put_io_group_queues(e, iog);
+		io_group_check_and_destroy(efqd, iog);
 	}
 }
 
@@ -1821,6 +1948,7 @@ alloc_ioq:
 		elv_init_ioq(e, ioq, iog, sched_q, IOPRIO_CLASS_BE, 4, 1);
 		io_group_set_ioq(iog, ioq);
 		elv_mark_ioq_sync(ioq);
+		elv_get_iog(iog);
 	}
 
 	if (new_sched_q)
@@ -2339,10 +2467,14 @@ void elv_put_ioq(struct io_queue *ioq)
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
@@ -2354,16 +2486,15 @@ void elv_put_ioq(struct io_queue *ioq)
 	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
 	elv_log_ioq(efqd, ioq, "put_queue");
 	elv_free_ioq(ioq);
+	elv_put_iog(iog);
 }
 EXPORT_SYMBOL(elv_put_ioq);
 
 void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
 {
-	struct io_group *root_group = e->efqd.root_group;
 	struct io_queue *ioq = *ioq_ptr;
 
 	if (ioq != NULL) {
-		io_ioq_move(e, ioq, root_group);
 		/* Drop the reference taken by the io group */
 		elv_put_ioq(ioq);
 		*ioq_ptr = NULL;
@@ -2524,6 +2655,8 @@ void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 	if (ioq == efqd->active_queue)
 		elv_reset_active_ioq(efqd);
 
+	requeue = update_requeue(ioq, requeue);
+
 	bfq_deactivate_entity(&ioq->entity, requeue);
 }
 
@@ -2925,15 +3058,6 @@ void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
 	}
 }
 
-void elv_free_idle_ioq_list(struct elevator_queue *e)
-{
-	struct io_queue *ioq, *n;
-	struct elv_fq_data *efqd = &e->efqd;
-
-	list_for_each_entry_safe(ioq, n, &efqd->idle_list, queue_list)
-		elv_deactivate_ioq(efqd, ioq, 0);
-}
-
 /*
  * Call iosched to let that elevator wants to expire the queue. This gives
  * iosched like AS to say no (if it is in the middle of batch changeover or
@@ -3372,7 +3496,6 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
 
-	INIT_LIST_HEAD(&efqd->idle_list);
 	INIT_HLIST_HEAD(&efqd->group_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
@@ -3403,8 +3526,6 @@ void elv_exit_fq_data(struct elevator_queue *e)
 	elv_shutdown_timer_wq(e);
 
 	spin_lock_irq(q->queue_lock);
-	/* This should drop all the idle tree references of ioq */
-	elv_free_idle_ioq_list(e);
 	/* This should drop all the io group references of async queues */
 	io_disconnect_groups(e);
 	spin_unlock_irq(q->queue_lock);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 48fb8f1..def533b 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -166,7 +166,6 @@ struct io_queue {
 
 	/* Pointer to generic elevator data structure */
 	struct elv_fq_data *efqd;
-	struct list_head queue_list;
 	pid_t pid;
 
 	/* Number of requests queued on this io queue */
@@ -224,6 +223,7 @@ struct io_group {
 	struct hlist_node elv_data_node;
 	struct hlist_node group_node;
 	struct io_sched_data sched_data;
+	atomic_t ref;
 
 	struct io_entity *my_entity;
 
@@ -244,6 +244,9 @@ struct io_group {
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
 
+	int deleting;
+	unsigned short iocg_id;
+
 };
 
 /**
@@ -281,9 +284,6 @@ struct elv_fq_data {
 	/* List of io groups hanging on this elevator */
 	struct hlist_head group_list;
 
-	/* List of io queues on idle tree. */
-	struct list_head idle_list;
-
 	struct request_queue *queue;
 	unsigned int busy_queues;
 	/*
@@ -519,6 +519,8 @@ extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
 					struct bio *bio, gfp_t gfp_mask);
 extern void elv_fq_unset_request_ioq(struct request_queue *q,
 					struct request *rq);
+extern void elv_put_iog(struct io_group *iog);
+
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
 extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 						struct bio *bio);
@@ -539,6 +541,21 @@ static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
 	iog->ioq = ioq;
 }
 
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
 #else /* !GROUP_IOSCHED */
 /*
  * No ioq movement is needed in case of flat setup. root io group gets cleaned
@@ -597,6 +614,19 @@ static inline struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 	return NULL;
 }
 
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
 #endif /* GROUP_IOSCHED */
 
 /* Functions used by blksysfs.c */
-- 
1.6.0.1
