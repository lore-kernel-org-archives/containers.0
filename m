From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 17/18] io-controller: IO group refcounting support
Date: Tue,  5 May 2009 15:58:44 -0400
Message-ID: <1241553525-28095-18-git-send-email-vgoyal__7640.08231130919$1241555894$gmane$org@redhat.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

o In the original BFQ patch once a cgroup is being deleted, it will clean
  up the associated io groups immediately and if there are any active io
  queues with that group, these will be moved to root group. This movement
  of queues is not good from fairness perspective as one can then create
  a cgroup, dump lots of IO and then delete the cgroup and then potentially
  get higher share. Apart from there are more issues hence it was felt that
  we need a io group refcounting mechanism also so that io group can be
  reclaimed asynchronously.

o This is a crude patch to implement io group refcounting. This is still
  work in progress and Nauman and Divyesh are playing with more ideas.

o I can do basic cgroup creation, deletion, task movement operations and
  there are no crashes (As was reported with V1 by Gui). Though I have not
  verified that io groups are actually being freed. Will do it next.

o There are couple of hard to hit race conditions I am aware of. Will fix
  that in upcoming versions. (RCU lookup when group might be going away
  during cgroup deletion).

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/cfq-iosched.c |   16 ++-
 block/elevator-fq.c |  441 ++++++++++++++++++++++++++++++++++-----------------
 block/elevator-fq.h |   26 ++--
 3 files changed, 320 insertions(+), 163 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index ea71239..cf9d258 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1308,8 +1308,17 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	if (sync_cfqq != NULL) {
 		__iog = cfqq_to_io_group(sync_cfqq);
-		if (iog != __iog)
-			io_ioq_move(q->elevator, sync_cfqq->ioq, iog);
+		/*
+		 * Drop reference to sync queue. A new queue sync queue will
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
@@ -1422,6 +1431,9 @@ alloc_ioq:
 			elv_mark_ioq_sync(cfqq->ioq);
 		}
 		cfqq->pid = current->pid;
+
+		/* ioq reference on iog */
+		elv_get_iog(iog);
 		cfq_log_cfqq(cfqd, cfqq, "alloced");
 	}
 
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index bd98317..1dd0bb3 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -36,7 +36,7 @@ static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
 					struct io_queue *ioq, int probe);
 struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 						 int extract);
-void elv_release_ioq(struct elevator_queue *eq, struct io_queue **ioq_ptr);
+void elv_release_ioq(struct io_queue **ioq_ptr);
 int elv_iosched_expire_ioq(struct request_queue *q, int slice_expired,
 					int force);
 
@@ -108,6 +108,16 @@ static inline void bfq_check_next_active(struct io_sched_data *sd,
 {
 	BUG_ON(sd->next_active != entity);
 }
+
+static inline struct io_group *io_entity_to_iog(struct io_entity *entity)
+{
+	struct io_group *iog = NULL;
+
+	BUG_ON(entity == NULL);
+	if (entity->my_sched_data != NULL)
+		iog = container_of(entity, struct io_group, entity);
+	return iog;
+}
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -124,6 +134,11 @@ static inline void bfq_check_next_active(struct io_sched_data *sd,
 					 struct io_entity *entity)
 {
 }
+
+static inline struct io_group *io_entity_to_iog(struct io_entity *entity)
+{
+	return NULL;
+}
 #endif
 
 /*
@@ -224,7 +239,6 @@ static void bfq_idle_extract(struct io_service_tree *st,
 				struct io_entity *entity)
 {
 	struct rb_node *next;
-	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	BUG_ON(entity->tree != &st->idle);
 
@@ -239,10 +253,6 @@ static void bfq_idle_extract(struct io_service_tree *st,
 	}
 
 	bfq_extract(&st->idle, entity);
-
-	/* Delete queue from idle list */
-	if (ioq)
-		list_del(&ioq->queue_list);
 }
 
 /**
@@ -374,9 +384,12 @@ static void bfq_active_insert(struct io_service_tree *st,
 void bfq_get_entity(struct io_entity *entity)
 {
 	struct io_queue *ioq = io_entity_to_ioq(entity);
+	struct io_group *iog = io_entity_to_iog(entity);
 
 	if (ioq)
 		elv_get_ioq(ioq);
+	else
+		elv_get_iog(iog);
 }
 
 /**
@@ -436,7 +449,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
 {
 	struct io_entity *first_idle = st->first_idle;
 	struct io_entity *last_idle = st->last_idle;
-	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
 		st->first_idle = entity;
@@ -444,10 +456,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
 		st->last_idle = entity;
 
 	bfq_insert(&st->idle, entity);
-
-	/* Add this queue to idle list */
-	if (ioq)
-		list_add(&ioq->queue_list, &ioq->efqd->idle_list);
 }
 
 /**
@@ -463,14 +471,21 @@ static void bfq_forget_entity(struct io_service_tree *st,
 				struct io_entity *entity)
 {
 	struct io_queue *ioq = NULL;
+	struct io_group *iog = NULL;
 
 	BUG_ON(!entity->on_st);
 	entity->on_st = 0;
 	st->wsum -= entity->weight;
+
 	ioq = io_entity_to_ioq(entity);
-	if (!ioq)
+	if (ioq) {
+		elv_put_ioq(ioq);
 		return;
-	elv_put_ioq(ioq);
+	}
+
+	iog = io_entity_to_iog(entity);
+	if (iog)
+		elv_put_iog(iog);
 }
 
 /**
@@ -909,21 +924,21 @@ void entity_served(struct io_entity *entity, bfq_service_t served,
 /*
  * Release all the io group references to its async queues.
  */
-void io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
+void io_put_io_group_queues(struct io_group *iog)
 {
 	int i, j;
 
 	for (i = 0; i < 2; i++)
 		for (j = 0; j < IOPRIO_BE_NR; j++)
-			elv_release_ioq(e, &iog->async_queue[i][j]);
+			elv_release_ioq(&iog->async_queue[i][j]);
 
 	/* Free up async idle queue */
-	elv_release_ioq(e, &iog->async_idle_queue);
+	elv_release_ioq(&iog->async_idle_queue);
 
 #ifdef CONFIG_GROUP_IOSCHED
 	/* Optimization for io schedulers having single ioq */
-	if (elv_iosched_single_ioq(e))
-		elv_release_ioq(e, &iog->ioq);
+	if (iog->ioq)
+		elv_release_ioq(&iog->ioq);
 #endif
 }
 
@@ -1018,6 +1033,9 @@ void io_group_set_parent(struct io_group *iog, struct io_group *parent)
 	entity = &iog->entity;
 	entity->parent = parent->my_entity;
 	entity->sched_data = &parent->sched_data;
+	if (entity->parent)
+		/* Child group reference on parent group */
+		elv_get_iog(parent);
 }
 
 /**
@@ -1210,6 +1228,9 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 		if (!iog)
 			goto cleanup;
 
+		atomic_set(&iog->ref, 0);
+		iog->deleting = 0;
+
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
 
@@ -1279,7 +1300,12 @@ void io_group_chain_link(struct request_queue *q, void *key,
 
 		rcu_assign_pointer(leaf->key, key);
 		hlist_add_head_rcu(&leaf->group_node, &iocg->group_data);
+		/* io_cgroup reference on io group */
+		elv_get_iog(leaf);
+
 		hlist_add_head(&leaf->elv_data_node, &efqd->group_list);
+		/* elevator reference on io group */
+		elv_get_iog(leaf);
 
 		spin_unlock_irqrestore(&iocg->lock, flags);
 
@@ -1388,12 +1414,23 @@ struct io_cgroup *get_iocg_from_bio(struct bio *bio)
 	if (!iocg)
 		return &io_root_cgroup;
 
+	/*
+	 * If this cgroup io_cgroup is being deleted, map the bio to
+	 * root cgroup
+	 */
+	if (css_is_removed(&iocg->css))
+		return &io_root_cgroup;
+
 	return iocg;
 }
 
 /*
  * Find the io group bio belongs to.
  * If "create" is set, io group is created if it is not already present.
+ *
+ * Note: There is a narrow window of race where a group is being freed
+ * by cgroup deletion path and some rq has slipped through in this group.
+ * Fix it.
  */
 struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
 					int create)
@@ -1440,8 +1477,8 @@ void io_free_root_group(struct elevator_queue *e)
 	spin_lock_irq(&iocg->lock);
 	hlist_del_rcu(&iog->group_node);
 	spin_unlock_irq(&iocg->lock);
-	io_put_io_group_queues(e, iog);
-	kfree(iog);
+	io_put_io_group_queues(iog);
+	elv_put_iog(iog);
 }
 
 struct io_group *io_alloc_root_group(struct request_queue *q,
@@ -1459,11 +1496,15 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
 
+	atomic_set(&iog->ref, 0);
+
 	blk_init_request_list(&iog->rl);
 
 	iocg = &io_root_cgroup;
 	spin_lock_irq(&iocg->lock);
 	rcu_assign_pointer(iog->key, key);
+	/* elevator reference. */
+	elv_get_iog(iog);
 	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
 	spin_unlock_irq(&iocg->lock);
 
@@ -1560,105 +1601,109 @@ void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 }
 
 /*
- * Move the queue to the root group if it is active. This is needed when
- * a cgroup is being deleted and all the IO is not done yet. This is not
- * very good scheme as a user might get unfair share. This needs to be
- * fixed.
+ * check whether a given group has got any active entities on any of the
+ * service tree.
  */
-void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
-				struct io_group *iog)
+static inline int io_group_has_active_entities(struct io_group *iog)
 {
-	int busy, resume;
-	struct io_entity *entity = &ioq->entity;
-	struct elv_fq_data *efqd = &e->efqd;
-	struct io_service_tree *st = io_entity_service_tree(entity);
+	int i;
+	struct io_service_tree *st;
 
-	busy = elv_ioq_busy(ioq);
-	resume = !!ioq->nr_queued;
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		if (!RB_EMPTY_ROOT(&st->active))
+			return 1;
+	}
 
-	BUG_ON(resume && !entity->on_st);
-	BUG_ON(busy && !resume && entity->on_st && ioq != efqd->active_queue);
+	return 0;
+}
+
+/*
+ * Should be called with both iocg->lock as well as queue lock held (if
+ * group is still connected on elevator list)
+ */
+void __iocg_destroy(struct io_cgroup *iocg, struct io_group *iog,
+				int queue_lock_held)
+{
+	int i;
+	struct io_service_tree *st;
 
 	/*
-	 * We could be moving an queue which is on idle tree of previous group
-	 * What to do? I guess anyway this queue does not have any requests.
-	 * just forget the entity and free up from idle tree.
-	 *
-	 * This needs cleanup. Hackish.
+	 * If we are here then we got the queue lock if group was still on
+	 * elevator list. If group had already been disconnected from elevator
+	 * list, then we don't need the queue lock.
 	 */
-	if (entity->tree == &st->idle) {
-		BUG_ON(atomic_read(&ioq->ref) < 2);
-		bfq_put_idle_entity(st, entity);
-	}
 
-	if (busy) {
-		BUG_ON(atomic_read(&ioq->ref) < 2);
-
-		if (!resume)
-			elv_del_ioq_busy(e, ioq, 0);
-		else
-			elv_deactivate_ioq(efqd, ioq, 0);
-	}
+	/* Remove io group from cgroup list */
+	hlist_del(&iog->group_node);
 
 	/*
-	 * Here we use a reference to bfqg.  We don't need a refcounter
-	 * as the cgroup reference will not be dropped, so that its
-	 * destroy() callback will not be invoked.
+	 * Mark io group for deletion so that no new entry goes in
+	 * idle tree. Any active queue will be removed from active
+	 * tree and not put in to idle tree.
 	 */
-	entity->parent = iog->my_entity;
-	entity->sched_data = &iog->sched_data;
+	iog->deleting = 1;
 
-	if (busy && resume)
-		elv_activate_ioq(ioq, 0);
-}
-EXPORT_SYMBOL(io_ioq_move);
+	/* Flush idle tree.  */
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		io_flush_idle_tree(st);
+	}
 
-static void __io_destroy_group(struct elv_fq_data *efqd, struct io_group *iog)
-{
-	struct elevator_queue *eq;
-	struct io_entity *entity = iog->my_entity;
-	struct io_service_tree *st;
-	int i;
+	/*
+	 * Drop io group reference on all async queues. This group is
+	 * going away so once these queues are empty, free those up
+	 * instead of keeping these around in the hope that new IO
+	 * will come.
+	 *
+	 * Note: If this group is disconnected from elevator, elevator
+	 * switch must have already done it.
+	 */
 
-	eq = container_of(efqd, struct elevator_queue, efqd);
-	hlist_del(&iog->elv_data_node);
-	__bfq_deactivate_entity(entity, 0);
-	io_put_io_group_queues(eq, iog);
+	io_put_io_group_queues(iog);
 
-	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
-		st = iog->sched_data.service_tree + i;
+	if (!io_group_has_active_entities(iog)) {
+		/*
+		 * io group does not have any active entites. Because this
+		 * group has been decoupled from io_cgroup list and this
+		 * cgroup is being deleted, this group should not receive
+		 * any new IO. Hence it should be safe to deactivate this
+		 * io group and remove from the scheduling tree.
+		 */
+		__bfq_deactivate_entity(iog->my_entity, 0);
 
 		/*
-		 * The idle tree may still contain bfq_queues belonging
-		 * to exited task because they never migrated to a different
-		 * cgroup from the one being destroyed now.  Noone else
-		 * can access them so it's safe to act without any lock.
+		 * Because this io group does not have any active entities,
+		 * it should be safe to remove it from elevator list and
+		 * drop elvator reference so that upon dropping io_cgroup
+		 * reference, this io group should be freed and we don't
+		 * wait for elevator switch to happen to free the group
+		 * up.
 		 */
-		io_flush_idle_tree(st);
+		if (queue_lock_held) {
+			hlist_del(&iog->elv_data_node);
+			rcu_assign_pointer(iog->key, NULL);
+			/*
+			 * Drop iog reference taken by elevator
+			 * (efqd->group_list)
+			 */
+			elv_put_iog(iog);
+		}
 
-		BUG_ON(!RB_EMPTY_ROOT(&st->active));
-		BUG_ON(!RB_EMPTY_ROOT(&st->idle));
 	}
 
-	BUG_ON(iog->sched_data.next_active != NULL);
-	BUG_ON(iog->sched_data.active_entity != NULL);
-	BUG_ON(entity->tree != NULL);
+	/* Drop iocg reference on io group */
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
-	unsigned long uninitialized_var(flags);
-
-	/* Remove io group from cgroup list */
-	hlist_del(&iog->group_node);
+	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
+	struct hlist_node *n, *tmp;
+	struct io_group *iog;
+	unsigned long flags;
+	int queue_lock_held = 0;
+	struct elv_fq_data *efqd;
 
 	/*
 	 * io groups are linked in two lists. One list is maintained
@@ -1677,58 +1722,93 @@ static void io_destroy_group(struct io_cgroup *iocg, struct io_group *iog)
 	 * try to free up async queues again or flush the idle tree.
 	 */
 
-	rcu_read_lock();
-	efqd = rcu_dereference(iog->key);
-	if (efqd != NULL) {
-		spin_lock_irqsave(efqd->queue->queue_lock, flags);
-		if (iog->key == efqd)
-			__io_destroy_group(efqd, iog);
-		spin_unlock_irqrestore(efqd->queue->queue_lock, flags);
-	}
-	rcu_read_unlock();
-
-	/*
-	 * No need to defer the kfree() to the end of the RCU grace
-	 * period: we are called from the destroy() callback of our
-	 * cgroup, so we can be sure that noone is a) still using
-	 * this cgroup or b) doing lookups in it.
-	 */
-	kfree(iog);
-}
+retry:
+	spin_lock_irqsave(&iocg->lock, flags);
+	hlist_for_each_entry_safe(iog, n, tmp, &iocg->group_data, group_node) {
+		/* Take the group queue lock */
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		if (efqd != NULL) {
+			if (spin_trylock_irq(efqd->queue->queue_lock)) {
+				if (iog->key == efqd) {
+					queue_lock_held = 1;
+					rcu_read_unlock();
+					goto locked;
+				}
 
-void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
-{
-	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
-	struct hlist_node *n, *tmp;
-	struct io_group *iog;
+				/*
+				 * After acquiring the queue lock, we found
+				 * iog->key==NULL, that means elevator switch
+				 * completed, group is no longer connected on
+				 * elevator hence we can proceed safely without
+				 * queue lock.
+				 */
+				spin_unlock_irq(efqd->queue->queue_lock);
+			} else {
+				/*
+				 * Did not get the queue lock while trying.
+				 * Backout. Drop iocg->lock and try again
+				 */
+				rcu_read_unlock();
+				spin_unlock_irqrestore(&iocg->lock, flags);
+				udelay(100);
+				goto retry;
 
-	/*
-	 * Since we are destroying the cgroup, there are no more tasks
-	 * referencing it, and all the RCU grace periods that may have
-	 * referenced it are ended (as the destruction of the parent
-	 * cgroup is RCU-safe); bgrp->group_data will not be accessed by
-	 * anything else and we don't need any synchronization.
-	 */
-	hlist_for_each_entry_safe(iog, n, tmp, &iocg->group_data, group_node)
-		io_destroy_group(iocg, iog);
+			}
+		}
+		/*
+		 * We come here when iog->key==NULL, that means elevator switch
+		 * has already taken place and now this group is no more
+		 * connected on elevator and one does not have to have a
+		 * queue lock to do the cleanup.
+		 */
+		rcu_read_unlock();
+locked:
+		__iocg_destroy(iocg, iog, queue_lock_held);
+		if (queue_lock_held) {
+			spin_unlock_irq(efqd->queue->queue_lock);
+			queue_lock_held = 0;
+		}
+	}
+	spin_unlock_irqrestore(&iocg->lock, flags);
 
 	BUG_ON(!hlist_empty(&iocg->group_data));
 
 	kfree(iocg);
 }
 
+/* Should be called with queue lock held */
 void io_disconnect_groups(struct elevator_queue *e)
 {
 	struct hlist_node *pos, *n;
 	struct io_group *iog;
 	struct elv_fq_data *efqd = &e->efqd;
+	int i;
+	struct io_service_tree *st;
 
 	hlist_for_each_entry_safe(iog, pos, n, &efqd->group_list,
 					elv_data_node) {
-		hlist_del(&iog->elv_data_node);
-
+		/*
+		 * At this point of time group should be on idle tree. This
+		 * would extract the group from idle tree.
+		 */
 		__bfq_deactivate_entity(iog->my_entity, 0);
 
+		/* Flush all the idle trees of the group */
+		for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+			st = iog->sched_data.service_tree + i;
+			io_flush_idle_tree(st);
+		}
+
+		/*
+		 * This has to be here also apart from cgroup cleanup path
+		 * and the reason being that if async queue reference of the
+		 * group are not dropped, then async ioq as well as associated
+		 * queue will not be reclaimed. Apart from that async cfqq
+		 * has to be cleaned up before elevator goes away.
+		 */
+		io_put_io_group_queues(iog);
+
 		/*
 		 * Don't remove from the group hash, just set an
 		 * invalid key.  No lookups can race with the
@@ -1736,11 +1816,68 @@ void io_disconnect_groups(struct elevator_queue *e)
 		 * implies also that new elements cannot be added
 		 * to the list.
 		 */
+		hlist_del(&iog->elv_data_node);
 		rcu_assign_pointer(iog->key, NULL);
-		io_put_io_group_queues(e, iog);
+		/* Drop iog reference taken by elevator (efqd->group_list)*/
+		elv_put_iog(iog);
 	}
 }
 
+/*
+ * This cleanup function is does the last bit of things to destroy cgroup.
+   It should only get called after io_destroy_group has been invoked.
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
+	kfree(iog);
+}
+
+/*
+ * Should be called with queue lock held. The only case it can be called
+ * without queue lock held is when elevator has gone away leaving behind
+ * dead io groups which are hanging there to be reclaimed when cgroup is
+ * deleted. In case of cgroup deletion, I think there is only one thread
+ * doing deletion and rest of the threads should have been taken care by
+ * cgroup stuff.
+ */
+void elv_put_iog(struct io_group *iog)
+{
+	struct io_group *parent = NULL;
+
+	BUG_ON(!iog);
+
+	BUG_ON(atomic_read(&iog->ref) <= 0);
+	if (!atomic_dec_and_test(&iog->ref))
+		return;
+
+	BUG_ON(iog->entity.on_st);
+
+	if (iog->my_entity)
+		parent = container_of(iog->my_entity->parent,
+				      struct io_group, entity);
+	io_group_cleanup(iog);
+
+	if (parent)
+		elv_put_iog(parent);
+}
+EXPORT_SYMBOL(elv_put_iog);
+
 struct cgroup_subsys io_subsys = {
 	.name = "io",
 	.create = iocg_create,
@@ -1887,6 +2024,8 @@ alloc_ioq:
 		elv_init_ioq(e, ioq, rq->iog, sched_q, IOPRIO_CLASS_BE, 4, 1);
 		io_group_set_ioq(iog, ioq);
 		elv_mark_ioq_sync(ioq);
+		/* ioq reference on iog */
+		elv_get_iog(iog);
 	}
 
 	if (new_sched_q)
@@ -1987,7 +2126,7 @@ EXPORT_SYMBOL(io_get_io_group_bio);
 void io_free_root_group(struct elevator_queue *e)
 {
 	struct io_group *iog = e->efqd.root_group;
-	io_put_io_group_queues(e, iog);
+	io_put_io_group_queues(iog);
 	kfree(iog);
 }
 
@@ -2437,13 +2576,11 @@ void elv_put_ioq(struct io_queue *ioq)
 }
 EXPORT_SYMBOL(elv_put_ioq);
 
-void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
+void elv_release_ioq(struct io_queue **ioq_ptr)
 {
-	struct io_group *root_group = e->efqd.root_group;
 	struct io_queue *ioq = *ioq_ptr;
 
 	if (ioq != NULL) {
-		io_ioq_move(e, ioq, root_group);
 		/* Drop the reference taken by the io group */
 		elv_put_ioq(ioq);
 		*ioq_ptr = NULL;
@@ -2600,9 +2737,19 @@ void elv_activate_ioq(struct io_queue *ioq, int add_front)
 void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 					int requeue)
 {
+	struct io_group *iog = ioq_to_io_group(ioq);
+
 	if (ioq == efqd->active_queue)
 		elv_reset_active_ioq(efqd);
 
+	/*
+	 * The io group ioq belongs to is going away. Don't requeue the
+	 * ioq on idle tree. Free it.
+	 */
+#ifdef CONFIG_GROUP_IOSCHED
+	if (iog->deleting == 1)
+		requeue = 0;
+#endif
 	bfq_deactivate_entity(&ioq->entity, requeue);
 }
 
@@ -3002,15 +3149,6 @@ void elv_ioq_arm_slice_timer(struct request_queue *q, int wait_for_busy)
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
@@ -3427,7 +3565,6 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
 
-	INIT_LIST_HEAD(&efqd->idle_list);
 	INIT_HLIST_HEAD(&efqd->group_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
@@ -3458,9 +3595,19 @@ void elv_exit_fq_data(struct elevator_queue *e)
 	elv_shutdown_timer_wq(e);
 
 	spin_lock_irq(q->queue_lock);
-	/* This should drop all the idle tree references of ioq */
-	elv_free_idle_ioq_list(e);
-	/* This should drop all the io group references of async queues */
+	/*
+	 * This should drop all the references of async queues taken by
+	 * io group.
+	 *
+	 * Also should should deactivate the group and extract from the
+	 * idle tree. (group can not be on active tree now after the
+	 * elevator has been drained).
+	 *
+	 * Should flush idle tree of the group which inturn will drop
+	 * ioq reference taken by active/idle tree.
+	 *
+	 * Drop the iog reference taken by elevator.
+	 */
 	io_disconnect_groups(e);
 	spin_unlock_irq(q->queue_lock);
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 58543ec..42e3777 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -165,7 +165,6 @@ struct io_queue {
 
 	/* Pointer to generic elevator data structure */
 	struct elv_fq_data *efqd;
-	struct list_head queue_list;
 	pid_t pid;
 
 	/* Number of requests queued on this io queue */
@@ -219,6 +218,7 @@ struct io_queue {
  *    o All the other fields are protected by the @bfqd queue lock.
  */
 struct io_group {
+	atomic_t ref;
 	struct io_entity entity;
 	struct hlist_node elv_data_node;
 	struct hlist_node group_node;
@@ -242,6 +242,9 @@ struct io_group {
 
 	/* request list associated with the group */
 	struct request_list rl;
+
+	/* io group is going away */
+	int deleting;
 };
 
 /**
@@ -279,9 +282,6 @@ struct elv_fq_data {
 	/* List of io groups hanging on this elevator */
 	struct hlist_head group_list;
 
-	/* List of io queues on idle tree. */
-	struct list_head idle_list;
-
 	struct request_queue *queue;
 	unsigned int busy_queues;
 	/*
@@ -504,8 +504,6 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
 
 #ifdef CONFIG_GROUP_IOSCHED
 extern int io_group_allow_merge(struct request *rq, struct bio *bio);
-extern void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
-					struct io_group *iog);
 extern void elv_fq_set_request_io_group(struct request_queue *q,
 					struct request *rq, struct bio *bio);
 static inline bfq_weight_t iog_weight(struct io_group *iog)
@@ -523,6 +521,8 @@ extern struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 extern struct request_list *io_group_get_request_list(struct request_queue *q,
 						struct bio *bio);
 
+extern void elv_put_iog(struct io_group *iog);
+
 /* Returns single ioq associated with the io group. */
 static inline struct io_queue *io_group_ioq(struct io_group *iog)
 {
@@ -545,17 +545,12 @@ static inline struct io_group *rq_iog(struct request_queue *q,
 	return rq->iog;
 }
 
-#else /* !GROUP_IOSCHED */
-/*
- * No ioq movement is needed in case of flat setup. root io group gets cleaned
- * up upon elevator exit and before that it has been made sure that both
- * active and idle tree are empty.
- */
-static inline void io_ioq_move(struct elevator_queue *e, struct io_queue *ioq,
-					struct io_group *iog)
+static inline void elv_get_iog(struct io_group *iog)
 {
+	atomic_inc(&iog->ref);
 }
 
+#else /* !GROUP_IOSCHED */
 static inline int io_group_allow_merge(struct request *rq, struct bio *bio)
 {
 	return 1;
@@ -608,6 +603,9 @@ static inline struct io_queue *elv_lookup_ioq_bio(struct request_queue *q,
 	return NULL;
 }
 
+static inline void elv_get_iog(struct io_group *iog) { }
+
+static inline void elv_put_iog(struct io_group *iog) { }
 
 extern struct io_group *rq_iog(struct request_queue *q, struct request *rq);
 
-- 
1.6.0.1
