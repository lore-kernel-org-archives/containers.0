From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/23] io-controller: Common hierarchical fair queuing code in
	elevaotor layer
Date: Fri, 28 Aug 2009 17:30:56 -0400
Message-ID: <1251495072-7780-8-git-send-email-vgoyal__36997.7772156291$1251496219$gmane$org@redhat.com>
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
 block/cfq-iosched.c |    2 +
 block/elevator-fq.c |  479 +++++++++++++++++++++++++++++++++++++++++++++++++--
 block/elevator-fq.h |   35 ++++
 block/elevator.c    |    4 +
 4 files changed, 509 insertions(+), 11 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 4bde1c8..decb654 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1356,6 +1356,8 @@ alloc_cfqq:
 
 			/* call it after cfq has initialized queue prio */
 			elv_init_ioq_io_group(ioq, iog);
+			/* ioq reference on iog */
+			elv_get_iog(iog);
 			cfq_log_cfqq(cfqd, cfqq, "alloced");
 		} else {
 			cfqq = &cfqd->oom_cfqq;
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index d0f341e..8e40b64 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -519,6 +519,7 @@ void elv_put_ioq(struct io_queue *ioq)
 {
 	struct elv_fq_data *efqd = ioq->efqd;
 	struct elevator_queue *e = efqd->eq;
+	struct io_group *iog;
 
 	BUG_ON(atomic_read(&ioq->ref) <= 0);
 	if (!atomic_dec_and_test(&ioq->ref))
@@ -526,12 +527,14 @@ void elv_put_ioq(struct io_queue *ioq)
 	BUG_ON(ioq->nr_queued);
 	BUG_ON(elv_ioq_busy(ioq));
 	BUG_ON(efqd->active_queue == ioq);
+	iog = ioq_to_io_group(ioq);
 
 	/* Can be called by outgoing elevator. Don't use q */
 	BUG_ON(!e->ops->elevator_free_sched_queue_fn);
 	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
 	elv_log_ioq(efqd, ioq, "put_queue");
 	elv_free_ioq(ioq);
+	elv_put_iog(iog);
 }
 EXPORT_SYMBOL(elv_put_ioq);
 
@@ -738,6 +741,27 @@ void elv_io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 EXPORT_SYMBOL(elv_io_group_set_async_queue);
 
 #ifdef CONFIG_GROUP_IOSCHED
+static void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup);
+
+static void io_group_init_entity(struct io_cgroup *iocg, struct io_group *iog)
+{
+	struct io_entity *entity = &iog->entity;
+
+	entity->weight = iocg->weight;
+	entity->ioprio_class = iocg->ioprio_class;
+	entity->ioprio_changed = 1;
+	entity->my_sd = &iog->sched_data;
+}
+
+static void io_group_set_parent(struct io_group *iog, struct io_group *parent)
+{
+	struct io_entity *entity = &iog->entity;
+
+	init_io_entity_parent(entity, &parent->entity);
+
+	/* Child group reference on parent group. */
+	elv_get_iog(parent);
+}
 
 struct io_cgroup io_root_cgroup = {
 	.weight = IO_WEIGHT_DEFAULT,
@@ -750,6 +774,27 @@ static struct io_cgroup *cgroup_to_io_cgroup(struct cgroup *cgroup)
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
+
 #define SHOW_FUNCTION(__VAR)						\
 static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,		\
 				       struct cftype *cftype)		\
@@ -889,12 +934,6 @@ static void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
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
@@ -906,24 +945,210 @@ struct cgroup_subsys io_subsys = {
 	.use_id = 1,
 };
 
+static inline unsigned int iog_weight(struct io_group *iog)
+{
+	return iog->entity.weight;
+}
+
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
+
+		atomic_set(&iog->ref, 0);
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
+static void io_group_chain_link(struct request_queue *q, void *key,
+				struct cgroup *cgroup, struct io_group *leaf,
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
+	/*
+	 * This connects the topmost element of the allocated chain to the
+	 * parent group.
+	 */
+	if (cgroup != NULL && prev != NULL) {
+		iocg = cgroup_to_io_cgroup(cgroup);
+		iog = io_cgroup_lookup_group(iocg, key);
+		io_group_set_parent(prev, iog);
+	}
+}
+
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
+struct io_group *elv_io_get_io_group(struct request_queue *q, int create)
+{
+	struct cgroup *cgroup;
+	struct io_group *iog;
+	struct elv_fq_data *efqd = q->elevator->efqd;
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
+EXPORT_SYMBOL(elv_io_get_io_group);
+
 static void io_free_root_group(struct elevator_queue *e)
 {
 	struct io_group *iog = e->efqd->root_group;
+	struct io_cgroup *iocg = &io_root_cgroup;
+
+	spin_lock_irq(&iocg->lock);
+	hlist_del_rcu(&iog->group_node);
+	spin_unlock_irq(&iocg->lock);
 
 	put_io_group_queues(e, iog);
-	kfree(iog);
+	elv_put_iog(iog);
 }
 
 static struct io_group *io_alloc_root_group(struct request_queue *q,
 					struct elevator_queue *e, void *key)
 {
 	struct io_group *iog;
+	struct io_cgroup *iocg = &io_root_cgroup;
 	int i;
 
 	iog = kmalloc_node(sizeof(*iog), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (iog == NULL)
 		return NULL;
 
+	elv_get_iog(iog);
 	iog->entity.parent = NULL;
 	iog->entity.my_sd = &iog->sched_data;
 	iog->key = key;
@@ -931,11 +1156,215 @@ static struct io_group *io_alloc_root_group(struct request_queue *q,
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = ELV_SERVICE_TREE_INIT;
 
+	spin_lock_irq(&iocg->lock);
+	rcu_assign_pointer(iog->key, key);
+	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
+	iog->iocg_id = css_id(&iocg->css);
+	spin_unlock_irq(&iocg->lock);
+
 	return iog;
 }
 
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
+	int i;
+
+	BUG_ON(iog->sched_data.active_entity != NULL);
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		BUG_ON(!RB_EMPTY_ROOT(&st->active));
+		BUG_ON(st->active_entity != NULL);
+	}
+
+	/*
+	 * Wait for any rcu readers to exit before freeing up the group.
+	 * Primarily useful when elv_io_get_io_group() is called without queue
+	 * lock to access some group data from bdi_congested_group() path.
+	 */
+	call_rcu(&iog->rcu_head, io_group_free_rcu);
+}
+
+void elv_put_iog(struct io_group *iog)
+{
+	struct io_group *parent_iog = NULL;
+	struct io_entity *parent;
+
+	BUG_ON(atomic_read(&iog->ref) <= 0);
+	if (!atomic_dec_and_test(&iog->ref))
+		return;
+
+	parent = parent_entity(&iog->entity);
+	if (parent)
+		parent_iog = iog_of(parent);
+
+	io_group_cleanup(iog);
+
+	if (parent_iog)
+		elv_put_iog(parent_iog);
+}
+EXPORT_SYMBOL(elv_put_iog);
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
+	hlist_del(&iog->elv_data_node);
+	put_io_group_queues(efqd->eq, iog);
+
+	/*
+	 * Put the reference taken at the time of creation so that when all
+	 * queues are gone, group can be destroyed.
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
+static void
+io_group_check_and_destroy(struct elv_fq_data *efqd, struct io_group *iog)
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
+static void release_elv_io_groups(struct elevator_queue *e)
+{
+	struct hlist_node *pos, *n;
+	struct io_group *iog;
+	struct elv_fq_data *efqd = e->efqd;
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
+int elv_io_group_allow_merge(struct request *rq, struct bio *bio)
+{
+	struct request_queue *q = rq->q;
+	struct io_queue *ioq = rq->ioq;
+	struct io_group *iog, *__iog;
+
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return 1;
+
+	/* Determine the io group of the bio submitting task */
+	iog = elv_io_get_io_group(q, 0);
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
 #else /* CONFIG_GROUP_IOSCHED */
 
+static inline unsigned int iog_weight(struct io_group *iog) { return 0; }
+static inline void release_elv_io_groups(struct elevator_queue *e) {}
+
 static struct io_group *io_alloc_root_group(struct request_queue *q,
 					struct elevator_queue *e, void *key)
 {
@@ -1012,8 +1441,13 @@ __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq, int coop)
 	struct elevator_queue *eq = q->elevator;
 
 	if (ioq) {
-		elv_log_ioq(efqd, ioq, "set_active, busy=%d",
-						efqd->busy_queues);
+		struct io_group *iog = ioq_to_io_group(ioq);
+		elv_log_ioq(efqd, ioq, "set_active, busy=%d class=%hu prio=%hu"
+				" weight=%u group_weight=%u qued=%d",
+				efqd->busy_queues, ioq->entity.ioprio_class,
+				ioq->entity.ioprio, ioq->entity.weight,
+				iog_weight(iog), ioq->nr_queued);
+
 		ioq->slice_start = ioq->slice_end = 0;
 		ioq->dispatch_start = jiffies;
 
@@ -1186,6 +1620,7 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 	struct io_queue *ioq;
 	struct elevator_queue *eq = q->elevator;
 	struct io_entity *entity, *new_entity;
+	struct io_group *iog = NULL, *new_iog = NULL;
 
 	ioq = elv_active_ioq(eq);
 
@@ -1218,9 +1653,16 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
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
 	if (eq->ops->elevator_should_preempt_fn) {
 		void *sched_queue = elv_ioq_sched_queue(new_ioq);
 
@@ -1365,6 +1807,10 @@ static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
 	if (new_ioq)
 		elv_log_ioq(e->efqd, ioq, "cooperating ioq=%d", new_ioq->pid);
 
+	/* Only select co-operating queue if it belongs to same group as ioq */
+	if (new_ioq && !is_same_group(&ioq->entity, &new_ioq->entity))
+		return NULL;
+
 	return new_ioq;
 }
 
@@ -1607,6 +2053,7 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 	efqd->idle_slice_timer.data = (unsigned long) efqd;
 
 	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
+	INIT_HLIST_HEAD(&efqd->group_list);
 
 	efqd->elv_slice[0] = elv_slice_async;
 	efqd->elv_slice[1] = elv_slice_sync;
@@ -1624,12 +2071,22 @@ int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
 void elv_exit_fq_data(struct elevator_queue *e)
 {
 	struct elv_fq_data *efqd = e->efqd;
+	struct request_queue *q = efqd->queue;
 
 	if (!elv_iosched_fair_queuing_enabled(e))
 		return;
 
 	elv_shutdown_timer_wq(e);
 
+	spin_lock_irq(q->queue_lock);
+	release_elv_io_groups(e);
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
index f92afac..56d0bfc 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -93,6 +93,7 @@ struct io_group {
 	atomic_t ref;
 	struct io_sched_data sched_data;
 	struct hlist_node group_node;
+	struct hlist_node elv_data_node;
 	unsigned short iocg_id;
 	/*
 	 * async queue for each priority case for RT and BE class.
@@ -102,6 +103,7 @@ struct io_group {
 	struct io_queue *async_queue[2][IOPRIO_BE_NR];
 	struct io_queue *async_idle_queue;
 	void *key;
+	struct rcu_head rcu_head;
 };
 
 struct io_cgroup {
@@ -135,6 +137,9 @@ struct io_group {
 struct elv_fq_data {
 	struct io_group *root_group;
 
+	/* List of io groups hanging on this elevator */
+	struct hlist_head group_list;
+
 	struct request_queue *queue;
 	struct elevator_queue *eq;
 	unsigned int busy_queues;
@@ -315,6 +320,28 @@ static inline struct io_queue *elv_get_oom_ioq(struct elevator_queue *eq)
 	return &eq->efqd->oom_ioq;
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+
+extern int elv_io_group_allow_merge(struct request *rq, struct bio *bio);
+extern void elv_put_iog(struct io_group *iog);
+extern struct io_group *elv_io_get_io_group(struct request_queue *q,
+						int create);
+
+static inline void elv_get_iog(struct io_group *iog)
+{
+	atomic_inc(&iog->ref);
+}
+
+#else /* !GROUP_IOSCHED */
+
+static inline int elv_io_group_allow_merge(struct request *rq, struct bio *bio)
+{
+	return 1;
+}
+
+static inline void elv_get_iog(struct io_group *iog) {}
+static inline void elv_put_iog(struct io_group *iog) {}
+
 static inline struct io_group *
 elv_io_get_io_group(struct request_queue *q, int create)
 {
@@ -322,6 +349,8 @@ elv_io_get_io_group(struct request_queue *q, int create)
 	return q->elevator->efqd->root_group;
 }
 
+#endif /* GROUP_IOSCHED */
+
 extern ssize_t elv_slice_sync_show(struct elevator_queue *q, char *name);
 extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
 						size_t count);
@@ -405,6 +434,12 @@ static inline void *elv_select_ioq(struct request_queue *q, int force)
 {
 	return NULL;
 }
+
+static inline int elv_io_group_allow_merge(struct request *rq, struct bio *bio)
+
+{
+	return 1;
+}
 #endif /* CONFIG_ELV_FAIR_QUEUING */
 #endif /* _ELV_SCHED_H */
 #endif /* CONFIG_BLOCK */
diff --git a/block/elevator.c b/block/elevator.c
index ea4042e..b2725cd 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -122,6 +122,10 @@ int elv_rq_merge_ok(struct request *rq, struct bio *bio)
 	    !bio_failfast_driver(bio)	 != !blk_failfast_driver(rq))
 		return 0;
 
+	/* If rq and bio belongs to different groups, dont allow merging */
+	if (!elv_io_group_allow_merge(rq, bio))
+		return 0;
+
 	if (!elv_iosched_allow_merge(rq, bio))
 		return 0;
 
-- 
1.6.0.6
