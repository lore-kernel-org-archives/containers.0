From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/28] io-controller: Core scheduler changes to support
	hierarhical scheduling
Date: Thu, 24 Sep 2009 15:25:10 -0400
Message-ID: <1253820332-10246-7-git-send-email-vgoyal__45532.6218311258$1253824013$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253820332-10246-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

o This patch introduces core changes in fair queuing scheduler to support
  hierarhical/group scheduling. It is enabled by CONFIG_GROUP_IOSCHED.

Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  190 +++++++++++++++++++++++++++++++++++++++++++++++----
 block/elevator-fq.h |   19 +++++
 init/Kconfig        |    8 ++
 3 files changed, 204 insertions(+), 13 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 629ddaa..0e3d58c 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -145,6 +145,88 @@ static inline struct io_group *iog_of(struct io_entity *entity)
 	return NULL;
 }
 
+#ifdef CONFIG_GROUP_IOSCHED
+/* check for entity->parent so that loop is not executed for root entity. */
+#define for_each_entity(entity)	\
+	for (; entity && entity->parent; entity = entity->parent)
+
+/* Do the two (enqueued) entities belong to the same group ? */
+static inline int
+is_same_group(struct io_entity *entity, struct io_entity *new_entity)
+{
+	if (parent_entity(entity) == parent_entity(new_entity))
+		return 1;
+
+	return 0;
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
+static void find_matching_io_entity(struct io_entity **entity,
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
+struct io_group *ioq_to_io_group(struct io_queue *ioq)
+{
+	return iog_of(parent_entity(&ioq->entity));
+}
+EXPORT_SYMBOL(ioq_to_io_group);
+
+static inline struct io_sched_data *
+io_entity_sched_data(struct io_entity *entity)
+{
+	return &iog_of(parent_entity(entity))->sched_data;
+}
+
+#else /* GROUP_IOSCHED */
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = NULL)
+
+static void find_matching_io_entity(struct io_entity **entity,
+			struct io_entity **new_entity) { }
+
+static inline int
+is_same_group(struct io_entity *entity, struct io_entity *new_entity)
+{
+	return 1;
+}
+
 static inline struct elv_fq_data *efqd_of(struct io_entity *entity)
 {
 	return ioq_of(entity)->efqd;
@@ -163,6 +245,7 @@ io_entity_sched_data(struct io_entity *entity)
 
 	return &efqd->root_group->sched_data;
 }
+#endif /* GROUP_IOSCHED */
 
 static inline void
 init_io_entity_service_tree(struct io_entity *entity, struct io_entity *parent)
@@ -175,12 +258,18 @@ init_io_entity_service_tree(struct io_entity *entity, struct io_entity *parent)
 	entity->st = &parent_iog->sched_data.service_tree[idx];
 }
 
-static void
-entity_served(struct io_entity *entity, unsigned long served,
-		unsigned long queue_charge, unsigned long nr_sectors)
+static void entity_served(struct io_entity *entity, unsigned long served,
+		unsigned long queue_charge, unsigned long group_charge,
+		unsigned long nr_sectors)
 {
-	entity->vdisktime += elv_delta_fair(queue_charge, entity);
-	update_min_vdisktime(entity->st);
+	unsigned long charge = queue_charge;
+
+	for_each_entity(entity) {
+		entity->vdisktime += elv_delta_fair(queue_charge, entity);
+		update_min_vdisktime(entity->st);
+		/* Group charge can be different from queue charge */
+		charge = group_charge;
+	}
 }
 
 static void place_entity(struct io_service_tree *st, struct io_entity *entity,
@@ -542,14 +631,23 @@ static void put_prev_ioq(struct io_queue *ioq)
 {
 	struct io_entity *entity = &ioq->entity;
 
-	put_prev_io_entity(entity);
+	for_each_entity(entity) {
+		put_prev_io_entity(entity);
+	}
 }
 
 static void dequeue_ioq(struct io_queue *ioq)
 {
 	struct io_entity *entity = &ioq->entity;
 
-	dequeue_io_entity(entity);
+	for_each_entity(entity) {
+		struct io_sched_data *sd = io_entity_sched_data(entity);
+
+		dequeue_io_entity(entity);
+		/* Don't dequeue parent if it has other entities besides us */
+		if (sd->nr_active)
+			break;
+	}
 	elv_put_ioq(ioq);
 	return;
 }
@@ -560,7 +658,12 @@ static void enqueue_ioq(struct io_queue *ioq)
 	struct io_entity *entity = &ioq->entity;
 
 	elv_get_ioq(ioq);
-	enqueue_io_entity(entity);
+
+	for_each_entity(entity) {
+		if (entity->on_st)
+			break;
+		enqueue_io_entity(entity);
+	}
 }
 
 static inline void
@@ -592,7 +695,7 @@ EXPORT_SYMBOL(elv_put_ioq);
 
 static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 {
-	unsigned long allocated_slice, queue_charge;
+	unsigned long allocated_slice, queue_charge, group_charge;
 
 	allocated_slice = elv_prio_to_slice(ioq->efqd, ioq);
 
@@ -604,7 +707,18 @@ static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 	 * use the slice and moves to the back of service tree (almost).
 	 */
 	queue_charge = allocated_slice;
-	entity_served(&ioq->entity, served, queue_charge, ioq->nr_sectors);
+
+	/*
+	 * Group is charged the real time consumed so that it does not loose
+	 * fair share.
+	 */
+	if (served > allocated_slice)
+		group_charge = allocated_slice;
+	else
+		group_charge = served;
+
+	entity_served(&ioq->entity, served, queue_charge, group_charge,
+			ioq->nr_sectors);
 }
 
 /*
@@ -804,6 +918,45 @@ void elv_io_group_set_async_queue(struct io_group *iog, int ioprio_class,
 }
 EXPORT_SYMBOL(elv_io_group_set_async_queue);
 
+#ifdef CONFIG_GROUP_IOSCHED
+
+static void io_free_root_group(struct elevator_queue *e)
+{
+	struct io_group *iog = e->efqd->root_group;
+	struct io_service_tree *st;
+	int i;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
+		st = iog->sched_data.service_tree + i;
+		flush_idle_tree(st);
+	}
+
+	put_io_group_queues(e, iog);
+	kfree(iog);
+}
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
+	iog->entity.parent = NULL;
+	iog->entity.my_sd = &iog->sched_data;
+	iog->key = key;
+
+	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
+		iog->sched_data.service_tree[i] = ELV_SERVICE_TREE_INIT;
+
+	return iog;
+}
+
+#else /* CONFIG_GROUP_IOSCHED */
+
 static struct io_group *io_alloc_root_group(struct request_queue *q,
 					struct elevator_queue *e, void *key)
 {
@@ -839,6 +992,8 @@ static void io_free_root_group(struct elevator_queue *e)
 	kfree(iog);
 }
 
+#endif /* CONFIG_GROUP_IOSCHED */
+
 /*
  * Should be called after ioq prio and class has been initialized as prio
  * class data will be used to determine which service tree in the group
@@ -864,9 +1019,11 @@ static struct io_queue *elv_get_next_ioq(struct request_queue *q)
 		return NULL;
 
 	sd = &efqd->root_group->sched_data;
-	entity = lookup_next_io_entity(sd);
-	if (!entity)
-		return NULL;
+	for (; sd != NULL; sd = entity->my_sd) {
+		entity = lookup_next_io_entity(sd);
+		if (!entity)
+			return NULL;
+	}
 
 	ioq = ioq_of(entity);
 	return ioq;
@@ -1073,6 +1230,13 @@ static int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
 	new_entity = &new_ioq->entity;
 
 	/*
+	 * In hierarchical setup, one need to traverse up the hierarchy
+	 * till both the queues are children of same parent to make a
+	 * decision whether to do the preemption or not.
+	 */
+	find_matching_io_entity(&entity, &new_entity);
+
+	/*
 	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
 	 */
 
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 6ea0d18..068f240 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -93,6 +93,23 @@ struct io_queue {
 	void *sched_queue;
 };
 
+#ifdef CONFIG_GROUP_IOSCHED /* CONFIG_GROUP_IOSCHED */
+struct io_group {
+	struct io_entity entity;
+	atomic_t ref;
+	struct io_sched_data sched_data;
+	/*
+	 * async queue for each priority case for RT and BE class.
+	 * Used only for cfq.
+	 */
+
+	struct io_queue *async_queue[2][IOPRIO_BE_NR];
+	struct io_queue *async_idle_queue;
+	void *key;
+};
+
+#else /* CONFIG_GROUP_IOSCHED */
+
 struct io_group {
 	struct io_entity entity;
 	struct io_sched_data sched_data;
@@ -106,6 +123,8 @@ struct io_group {
 	void *key;
 };
 
+#endif /* CONFIG_GROUP_IOSCHED */
+
 struct elv_fq_data {
 	struct io_group *root_group;
 
diff --git a/init/Kconfig b/init/Kconfig
index 3f7e609..29f701d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -612,6 +612,14 @@ config CGROUP_MEM_RES_CTLR_SWAP
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
