From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Thu, 30 Apr 2009 12:38:36 -0700
Message-ID: <49F9FE3C.3070000__23856.2073828236$1241120543$gmane$org@google.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49DF1256.7080403@cn.fujitsu.com>
	<20090413130958.GB18007@redhat.com>
	<49EE895A.1060101@cn.fujitsu.com>
	<20090422132307.GA23098@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090422132307.GA23098-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Wed, Apr 22, 2009 at 11:04:58AM +0800, Gui Jianfeng wrote:
>   
>> Vivek Goyal wrote:
>>     
>>> On Fri, Apr 10, 2009 at 05:33:10PM +0800, Gui Jianfeng wrote:
>>>       
>>>> Vivek Goyal wrote:
>>>>         
>>>>> Hi All,
>>>>>
>>>>> Here is another posting for IO controller patches. Last time I had posted
>>>>> RFC patches for an IO controller which did bio control per cgroup.
>>>>>           
>>>>   Hi Vivek,
>>>>
>>>>   I got the following OOPS when testing, can't reproduce again :(
>>>>
>>>>         
>>> Hi Gui,
>>>
>>> Thanks for the report. Will look into it and see if I can reproduce it.
>>>       
>>   Hi Vivek,
>>
>>   The following script can reproduce the bug in my box.
>>
>> #!/bin/sh
>>
>> mkdir /cgroup
>> mount -t cgroup -o io io /cgroup
>> mkdir /cgroup/test1
>> mkdir /cgroup/test2
>>
>> echo cfq > /sys/block/sda/queue/scheduler
>> echo 7 > /cgroup/test1/io.ioprio
>> echo 1 > /cgroup/test2/io.ioprio
>> echo 1 > /proc/sys/vm/drop_caches
>> dd if=1000M.1 of=/dev/null &
>> pid1=$!
>> echo $pid1
>> echo $pid1 > /cgroup/test1/tasks
>> dd if=1000M.2 of=/dev/null
>> pid2=$!
>> echo $pid2
>> echo $pid2 > /cgroup/test2/tasks
>>
>>
>> rmdir /cgroup/test1
>> rmdir /cgroup/test2
>> umount /cgroup
>> rmdir /cgroup
>>     
>
> Thanks Gui. We have got races with task movement and cgroup deletion. In
> the original bfq patch, Fabio had implemented the logic to migrate the
> task queue synchronously. It found the logic to be little complicated so I
> changed it to delayed movement of queue from old cgroup to new cgroup.
> Fabio later mentioned that it introduces a race where old cgroup is
> deleted before task queue has actually moved to new cgroup.
>
> Nauman is currently implementing reference counting for io groups and that
> will solve this problem at the same time some other problems like movement
> of queue to root group during cgroup deletion and which can potentially 
> result in unfair share for some time to that queue etc.
>
> Thanks
> Vivek
>   
Hi Gui,
This patch should solve the problems reported by you. Please let me know if it does not work.
@Vivek, this has a few more changes after the patch I sent you separately.

DESC
Add ref counting for io_group.
EDESC
    
        Reference counting for io_group solves many problems, most of which
        occured when we tried to delete the cgroup. Earlier, ioqs were being
        moved out of cgroup to root cgroup. That is problematic in many ways:
        First, the pending requests in queues might get unfair service, and
        will also cause unfairness for other cgroups at the root level. This
        problem can become signficant if cgroups are created and destroyed
        relatively frequently. Second, moving queues to root cgroups was
        complicated and was causing many BUG_ON's to trigger. Third, there is
        a single io queue in AS, Deadline and Noop within a cgroup; and it
        does not make sense to move it to the root cgroup. The same is true of
        async queues.
    
        Requests already keep a reference on ioq, so queues keep a reference on
        cgroup. For async queues in CFQ, and single ioq in other schedulers,
        io_group also keeps are reference on io_queue. This reference on ioq
        is dropped when the queue is released (elv_release_ioq). So the queue
        can be freed.
    
        When a queue is released, it puts the reference to io_group and the
        io_group is released after all the queues are released. Child groups
        also take reference on parent groups, and release it when they are
        destroyed.
    
        Also we no longer need to maintain a seprate linked list of idle
        entities, which was maintained only to help release the ioq references
        during elevator switch. The code for releasing io_groups is reused for
        elevator switch, resulting in simpler and tight code.

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 0ecf7c7..21e8ab8 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1090,8 +1090,8 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	if (async_cfqq != NULL) {
 		__iog = cfqq_to_io_group(async_cfqq);
-
 		if (iog != __iog) {
+			/* Cgroup has changed, drop the reference to async queue */
 			cic_set_cfqq(cic, NULL, 0);
 			cfq_put_queue(async_cfqq);
 		}
@@ -1099,8 +1099,10 @@ static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
 
 	if (sync_cfqq != NULL) {
 		__iog = cfqq_to_io_group(sync_cfqq);
-		if (iog != __iog)
-			io_ioq_move(q->elevator, sync_cfqq->ioq, iog);
+		if (iog != __iog) {
+			cic_set_cfqq(cic, NULL, 1);
+			cfq_put_queue(sync_cfqq);
+		}
 	}
 
 	spin_unlock_irqrestore(q->queue_lock, flags);
@@ -1114,8 +1116,8 @@ static void cfq_ioc_set_cgroup(struct io_context *ioc)
 #endif  /* CONFIG_IOSCHED_CFQ_HIER */
 
 static struct cfq_queue *
-cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
-				struct io_context *ioc, gfp_t gfp_mask)
+cfq_find_alloc_queue(struct cfq_data *cfqd, struct io_group *iog,
+		     int is_sync, struct io_context *ioc, gfp_t gfp_mask)
 {
 	struct cfq_queue *cfqq, *new_cfqq = NULL;
 	struct cfq_io_context *cic;
@@ -1198,6 +1200,8 @@ alloc_ioq:
 			elv_mark_ioq_sync(cfqq->ioq);
 		}
 		cfqq->pid = current->pid;
+		/* ioq reference on iog */
+		elv_get_iog(iog);
 		cfq_log_cfqq(cfqd, cfqq, "alloced");
 	}
 
@@ -1229,7 +1233,8 @@ cfq_get_queue(struct cfq_data *cfqd, int is_sync, struct io_context *ioc,
 	}
 
 	if (!cfqq) {
-		cfqq = cfq_find_alloc_queue(cfqd, is_sync, ioc, gfp_mask);
+		cfqq = cfq_find_alloc_queue(cfqd, iog, 
+					    is_sync, ioc, gfp_mask);
 		if (!cfqq)
 			return NULL;
 	}
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 7474f6d..52419d1 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -198,7 +198,6 @@ static void bfq_idle_extract(struct io_service_tree *st,
 				struct io_entity *entity)
 {
 	struct rb_node *next;
-	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	BUG_ON(entity->tree != &st->idle);
 
@@ -213,10 +212,6 @@ static void bfq_idle_extract(struct io_service_tree *st,
 	}
 
 	bfq_extract(&st->idle, entity);
-
-	/* Delete queue from idle list */
-	if (ioq)
-		list_del(&ioq->queue_list);
 }
 
 /**
@@ -420,7 +415,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
 {
 	struct io_entity *first_idle = st->first_idle;
 	struct io_entity *last_idle = st->last_idle;
-	struct io_queue *ioq = io_entity_to_ioq(entity);
 
 	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
 		st->first_idle = entity;
@@ -428,10 +422,6 @@ static void bfq_idle_insert(struct io_service_tree *st,
 		st->last_idle = entity;
 
 	bfq_insert(&st->idle, entity);
-
-	/* Add this queue to idle list */
-	if (ioq)
-		list_add(&ioq->queue_list, &ioq->efqd->idle_list);
 }
 
 /**
@@ -666,8 +656,13 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
 	struct io_sched_data *sd;
+	struct io_group *iog;
 	struct io_entity *parent;
 
+	iog = container_of(entity->sched_data, struct io_group, sched_data);
+	/* Hold a reference to entity's iog until we are done */
+	elv_get_iog(iog);
+
 	for_each_entity_safe(entity, parent) {
 		sd = entity->sched_data;
 
@@ -679,13 +674,15 @@ void bfq_deactivate_entity(struct io_entity *entity, int requeue)
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
@@ -694,6 +691,7 @@ void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 		requeue = 1;
 	}
 
+	elv_put_iog(iog);
 	return;
 
 update:
@@ -944,6 +942,8 @@ void io_group_set_parent(struct io_group *iog, struct io_group *parent)
 	entity = &iog->entity;
 	entity->parent = parent->my_entity;
 	entity->sched_data = &parent->sched_data;
+	if (entity->parent)
+		elv_get_iog(parent);
 }
 
 /**
@@ -1052,6 +1052,10 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
+		/* Take the initial reference that will be released on destroy */
+		atomic_set(&iog->ref, 0);
+		iog->deleting = 0;
+		elv_get_iog(iog);
 
 		if (leaf == NULL) {
 			leaf = iog;
@@ -1074,7 +1078,7 @@ cleanup:
 	while (leaf != NULL) {
 		prev = leaf;
 		leaf = leaf->key;
-		kfree(iog);
+		kfree(prev);
 	}
 
 	return NULL;
@@ -1197,13 +1201,20 @@ void io_free_root_group(struct elevator_queue *e)
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
@@ -1217,6 +1228,7 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	if (iog == NULL)
 		return NULL;
 
+	elv_get_iog(iog);
 	iog->entity.parent = NULL;
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
 		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
@@ -1311,90 +1323,89 @@ void iocg_attach(struct cgroup_subsys *subsys, struct cgroup *cgroup,
 	task_unlock(tsk);
 }
 
-/*
- * Move the queue to the root group if it is active. This is needed when
- * a cgroup is being deleted and all the IO is not done yet. This is not
- * very good scheme as a user might get unfair share. This needs to be
- * fixed.
+/* This cleanup function is does the last bit of things to destroy cgroup.
+   It should only get called after io_destroy_group has been invoked.
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
-	}
+	kfree(iog);
+}
 
-	/*
-	 * Here we use a reference to bfqg.  We don't need a refcounter
-	 * as the cgroup reference will not be dropped, so that its
-	 * destroy() callback will not be invoked.
-	 */
-	entity->parent = iog->my_entity;
-	entity->sched_data = &iog->sched_data;
+void elv_put_iog(struct io_group *iog)
+{
+	struct io_group *parent = NULL;
+	struct io_entity *entity;
 
-	if (busy && resume)
-		elv_activate_ioq(ioq);
+	BUG_ON(!iog);
+
+	entity = iog->my_entity;
+
+	BUG_ON(atomic_read(&iog->ref) <= 0);
+	if (!atomic_dec_and_test(&iog->ref))
+		return;
+
+	if (iog->my_entity)
+		parent = container_of(iog->my_entity->parent,
+				      struct io_group, entity);
+
+	if (entity)
+		__bfq_deactivate_entity(entity, 0);
+
+	io_group_cleanup(iog);
+
+	if (parent)
+		elv_put_iog(parent);
 }
-EXPORT_SYMBOL(io_ioq_move);
+EXPORT_SYMBOL(elv_put_iog);
 
+/* After the group is destroyed, no new sync IO should come to the group.
+   It might still have pending IOs in some busy queues. It should be able to 
+   send those IOs down to the disk. The async IOs (due to dirty page writeback)
+   would go in the root group queues after this, as the group does not exist
+   anymore.
+   When one of those busy queues get new requests, the queue
+   is moved to the new cgroup. 
+*/
 static void __io_destroy_group(struct elv_fq_data *efqd, struct io_group *iog)
 {
 	struct elevator_queue *eq;
-	struct io_entity *entity = iog->my_entity;
 	struct io_service_tree *st;
 	int i;
 
-	eq = container_of(efqd, struct elevator_queue, efqd);
-	hlist_del(&iog->elv_data_node);
-	__bfq_deactivate_entity(entity, 0);
-	io_put_io_group_queues(eq, iog);
+	BUG_ON(iog->my_entity == NULL);
 
+	/* We flush idle tree now, and don't put things in there
+	   any more.
+	 */
 	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
 		st = iog->sched_data.service_tree + i;
-
-		/*
-		 * The idle tree may still contain bfq_queues belonging
-		 * to exited task because they never migrated to a different
-		 * cgroup from the one being destroyed now.  Noone else
-		 * can access them so it's safe to act without any lock.
-		 */
 		io_flush_idle_tree(st);
-
-		BUG_ON(!RB_EMPTY_ROOT(&st->active));
-		BUG_ON(!RB_EMPTY_ROOT(&st->idle));
 	}
+	iog->deleting = 1;
 
-	BUG_ON(iog->sched_data.next_active != NULL);
-	BUG_ON(iog->sched_data.active_entity != NULL);
-	BUG_ON(entity->tree != NULL);
+	eq = container_of(efqd, struct elevator_queue, efqd);
+	hlist_del(&iog->elv_data_node);
+	io_put_io_group_queues(eq, iog);
+	/* Put the reference taken at the time of creation
+	   so that when all queues are gone, cgroup can be destroyed.
+	 */
+	elv_put_iog(iog);
 }
 
 /**
@@ -1438,14 +1449,6 @@ static void io_destroy_group(struct io_cgroup *iocg, struct io_group *iog)
 		spin_unlock_irqrestore(efqd->queue->queue_lock, flags);
 	}
 	rcu_read_unlock();
-
-	/*
-	 * No need to defer the kfree() to the end of the RCU grace
-	 * period: we are called from the destroy() callback of our
-	 * cgroup, so we can be sure that noone is a) still using
-	 * this cgroup or b) doing lookups in it.
-	 */
-	kfree(iog);
 }
 
 void iocg_destroy(struct cgroup_subsys *subsys, struct cgroup *cgroup)
@@ -1477,19 +1480,8 @@ void io_disconnect_groups(struct elevator_queue *e)
 
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
+		hlist_del(&iog->group_node);
+		__io_destroy_group(efqd, iog);
 	}
 }
 
@@ -1637,6 +1629,7 @@ alloc_ioq:
 		elv_init_ioq(e, ioq, sched_q, IOPRIO_CLASS_BE, 4, 1);
 		io_group_set_ioq(iog, ioq);
 		elv_mark_ioq_sync(ioq);
+		elv_get_iog(iog);
 	}
 
 	if (new_sched_q)
@@ -1997,10 +1990,14 @@ void elv_put_ioq(struct io_queue *ioq)
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
@@ -2012,16 +2009,15 @@ void elv_put_ioq(struct io_queue *ioq)
 	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
 	elv_log_ioq(efqd, ioq, "freed");
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
@@ -2122,9 +2118,14 @@ void elv_activate_ioq(struct io_queue *ioq)
 void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 					int requeue)
 {
+	struct io_group *iog = ioq_to_io_group(ioq);
+
 	if (ioq == efqd->active_queue)
 		elv_reset_active_ioq(efqd);
 
+	if (iog->deleting == 1)
+		requeue = 0;
+
 	bfq_deactivate_entity(&ioq->entity, requeue);
 }
 
@@ -2460,15 +2461,6 @@ void elv_ioq_arm_slice_timer(struct request_queue *q)
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
@@ -2838,8 +2830,6 @@ void elv_exit_fq_data(struct elevator_queue *e)
 	elv_shutdown_timer_wq(e);
 
 	spin_lock_irq(q->queue_lock);
-	/* This should drop all the idle tree references of ioq */
-	elv_free_idle_ioq_list(e);
 	/* This should drop all the io group references of async queues */
 	io_disconnect_groups(e);
 	spin_unlock_irq(q->queue_lock);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 62b2ee2..7622b28 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -213,6 +213,7 @@ struct io_group {
 	struct hlist_node elv_data_node;
 	struct hlist_node group_node;
 	struct io_sched_data sched_data;
+	atomic_t ref;
 
 	struct io_entity *my_entity;
 
@@ -229,6 +230,8 @@ struct io_group {
 
 	/* Single ioq per group, used for noop, deadline, anticipatory */
 	struct io_queue *ioq;
+
+	int deleting;
 };
 
 /**
@@ -462,6 +465,8 @@ extern int elv_fq_set_request_ioq(struct request_queue *q, struct request *rq,
 					gfp_t gfp_mask);
 extern void elv_fq_unset_request_ioq(struct request_queue *q,
 					struct request *rq);
+extern void elv_put_iog(struct io_group *iog);
+
 extern struct io_queue *elv_lookup_ioq_current(struct request_queue *q);
 
 /* Returns single ioq associated with the io group. */
@@ -480,6 +485,11 @@ static inline void io_group_set_ioq(struct io_group *iog, struct io_queue *ioq)
 	iog->ioq = ioq;
 }
 
+static inline void elv_get_iog(struct io_group *iog)
+{
+	atomic_inc(&iog->ref);
+}
+
 #else /* !GROUP_IOSCHED */
 /*
  * No ioq movement is needed in case of flat setup. root io group gets cleaned
@@ -531,6 +541,15 @@ static inline struct io_queue *elv_lookup_ioq_current(struct request_queue *q)
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
+
 #endif /* GROUP_IOSCHED */
 
 /* Functions used by blksysfs.c */
