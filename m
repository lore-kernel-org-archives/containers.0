From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/24] io-controller: Debug hierarchical IO scheduling
Date: Fri, 24 Jul 2009 16:27:41 -0400
Message-ID: <1248467274-32073-12-git-send-email-vgoyal__3720.44914770431$1248469933$gmane$org@redhat.com>
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

o Littile debugging aid for hierarchical IO scheduling.

o Enabled under CONFIG_DEBUG_GROUP_IOSCHED

o Currently it outputs more debug messages in blktrace output which helps
  a great deal in debugging in hierarchical setup. It also creates additional
  cgroup interfaces io.disk_queue and io.disk_dequeue to output some more
  debugging data.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |    8 ++
 block/elevator-fq.c   |  300 ++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h   |   38 ++++++-
 3 files changed, 339 insertions(+), 7 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index a91a807..a7d0bf8 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -90,6 +90,14 @@ config DEFAULT_IOSCHED
 	default "cfq" if DEFAULT_CFQ
 	default "noop" if DEFAULT_NOOP
 
+config DEBUG_GROUP_IOSCHED
+	bool "Debug Hierarchical Scheduling support"
+	depends on CGROUPS && GROUP_IOSCHED
+	default n
+	---help---
+	  Enable some debugging hooks for hierarchical scheduling support.
+	  Currently it just outputs more information in blktrace output.
+
 endmenu
 
 endif
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index c546962..ca26960 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -153,6 +153,119 @@ static void bfq_find_matching_entity(struct io_entity **entity,
 		*new_entity = parent_entity(*new_entity);
 	}
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
+
+/* Returns parent group of io group */
+static inline struct io_group *iog_parent(struct io_group *iog)
+{
+	struct io_group *piog;
+
+	if (!iog->entity.sched_data)
+		return NULL;
+
+	/*
+	 * Not following entity->parent pointer as for top level groups
+	 * this pointer is NULL.
+	 */
+	piog = container_of(iog->entity.sched_data, struct io_group,
+					sched_data);
+	return piog;
+}
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+static void io_group_path(struct io_group *iog, char *buf, int buflen)
+{
+	unsigned short id = iog->iocg_id;
+	struct cgroup_subsys_state *css;
+
+	rcu_read_lock();
+
+	if (!id)
+		goto out;
+
+	css = css_lookup(&io_subsys, id);
+	if (!css)
+		goto out;
+
+	if (!css_tryget(css))
+		goto out;
+
+	cgroup_path(css->cgroup, buf, buflen);
+
+	css_put(css);
+
+	rcu_read_unlock();
+	return;
+out:
+	rcu_read_unlock();
+	buf[0] = '\0';
+	return;
+}
+
+/*
+ * An entity has been freshly added to active tree. Either it came from
+ * idle tree or it was not on any of the trees. Do the accounting.
+ */
+static inline void bfq_account_for_entity_addition(struct io_entity *entity)
+{
+	struct io_group *iog = io_entity_to_iog(entity);
+
+	if (iog) {
+		struct elv_fq_data *efqd;
+
+		/*
+		 * Keep track of how many times a group has been added
+		 * to active tree.
+		 */
+		iog->queue++;
+		iog->queue_start = jiffies;
+
+		/* Log group addition event */
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		if (efqd)
+			elv_log_iog(efqd, iog, "add group weight=%u",
+					iog->entity.weight);
+		rcu_read_unlock();
+	}
+}
+
+/*
+ * An entity got removed from active tree and either went to idle tree or
+ * not is on any of the tree. Do the accouting
+ */
+static inline void bfq_account_for_entity_deletion(struct io_entity *entity)
+{
+	struct io_group *iog = io_entity_to_iog(entity);
+
+	if (iog) {
+		struct elv_fq_data *efqd;
+
+		iog->dequeue++;
+		/* Keep a track of how long group was on active tree */
+		iog->queue_duration += jiffies_to_msecs(jiffies -
+						iog->queue_start);
+		iog->queue_start = 0;
+
+		/* Log group deletion event */
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		if (efqd)
+			elv_log_iog(efqd, iog, "del group weight=%u",
+					iog->entity.weight);
+		rcu_read_unlock();
+	}
+}
+#endif /* DEBUG_GROUP_IOSCHED */
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -186,6 +299,11 @@ is_same_group(struct io_entity *entity, struct io_entity *new_entity)
 {
 	return 1;
 }
+
+static inline struct io_group *io_entity_to_iog(struct io_entity *entity)
+{
+	return NULL;
+}
 #endif /* GROUP_IOSCHED */
 
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
@@ -426,6 +544,7 @@ static void bfq_active_insert(struct io_service_tree *st,
 	struct rb_node *node = &entity->rb_node;
 
 	bfq_insert(&st->active, entity);
+	entity->sched_data->nr_active++;
 
 	if (node->rb_left != NULL)
 		node = node->rb_left;
@@ -485,6 +604,7 @@ static void bfq_active_remove(struct io_service_tree *st,
 
 	node = bfq_find_deepest(&entity->rb_node);
 	bfq_remove(&st->active, entity);
+	entity->sched_data->nr_active--;
 
 	if (node != NULL)
 		bfq_update_active_tree(node);
@@ -571,6 +691,21 @@ static void bfq_forget_idle(struct io_service_tree *st)
 		bfq_put_idle_entity(st, first_idle);
 }
 
+/*
+ * Returns the number of active entities a particular io group has. This
+ * includes number of active entities on service tree as well as the active
+ * entity which is being served currently, if any.
+ */
+
+static inline int elv_iog_nr_active(struct io_group *iog)
+{
+	struct io_sched_data *sd = &iog->sched_data;
+
+	if (sd->active_entity)
+		return sd->nr_active + 1;
+	else
+		return sd->nr_active;
+}
 
 static struct io_service_tree *
 __bfq_entity_update_prio(struct io_service_tree *old_st,
@@ -752,6 +887,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 {
 	struct io_sched_data *sd = entity->sched_data;
 	struct io_service_tree *st = io_entity_service_tree(entity);
+	int newly_added = 0;
 
 	if (entity == sd->active_entity) {
 		BUG_ON(entity->tree != NULL);
@@ -778,6 +914,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 		bfq_idle_remove(st, entity);
 		entity->start = bfq_gt(st->vtime, entity->finish) ?
 				       st->vtime : entity->finish;
+		newly_added = 1;
 	} else {
 		/*
 		 * The finish time of the entity may be invalid, and
@@ -790,6 +927,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 
 		BUG_ON(entity->on_st);
 		entity->on_st = 1;
+		newly_added = 1;
 	}
 
 	st = __bfq_entity_update_prio(st, entity);
@@ -831,6 +969,11 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 		bfq_calc_finish(entity, entity->budget);
 	}
 	bfq_active_insert(st, entity);
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	if (newly_added)
+		bfq_account_for_entity_addition(entity);
+#endif
 }
 
 /**
@@ -872,7 +1015,7 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 	struct io_sched_data *sd = entity->sched_data;
 	struct io_service_tree *st = io_entity_service_tree(entity);
 	int was_active = entity == sd->active_entity;
-	int ret = 0;
+	int ret = 0, active_removed = 0;
 
 	if (!entity->on_st)
 		return 0;
@@ -882,9 +1025,11 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 	if (was_active) {
 		bfq_calc_finish(entity, entity->service);
 		sd->active_entity = NULL;
-	} else if (entity->tree == &st->active)
+		active_removed = 1;
+	} else if (entity->tree == &st->active) {
 		bfq_active_remove(st, entity);
-	else if (entity->tree == &st->idle)
+		active_removed = 1;
+	} else if (entity->tree == &st->idle)
 		bfq_idle_remove(st, entity);
 	else if (entity->tree != NULL)
 		BUG();
@@ -899,6 +1044,10 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 	BUG_ON(sd->active_entity == entity);
 	BUG_ON(sd->next_active == entity);
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	if (active_removed)
+		bfq_account_for_entity_deletion(entity);
+#endif
 	return ret;
 }
 
@@ -1208,6 +1357,67 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
 	return 0;
 }
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+static int io_cgroup_disk_queue_read(struct cgroup *cgroup,
+			struct cftype *cftype, struct seq_file *m)
+{
+	struct io_cgroup *iocg = NULL;
+	struct io_group *iog = NULL;
+	struct hlist_node *n;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	iocg = cgroup_to_io_cgroup(cgroup);
+	rcu_read_lock();
+	/* Loop through all the io groups and print statistics */
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (iog->key) {
+			seq_printf(m, "%u:%u %lu %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev), iog->queue,
+					iog->queue_duration);
+		}
+	}
+	rcu_read_unlock();
+	cgroup_unlock();
+
+	return 0;
+}
+
+static int io_cgroup_disk_dequeue_read(struct cgroup *cgroup,
+			struct cftype *cftype, struct seq_file *m)
+{
+	struct io_cgroup *iocg = NULL;
+	struct io_group *iog = NULL;
+	struct hlist_node *n;
+
+	if (!cgroup_lock_live_group(cgroup))
+		return -ENODEV;
+
+	iocg = cgroup_to_io_cgroup(cgroup);
+	spin_lock_irq(&iocg->lock);
+	/* Loop through all the io groups and print statistics */
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (iog->key) {
+			seq_printf(m, "%u:%u %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev), iog->dequeue);
+		}
+	}
+	spin_unlock_irq(&iocg->lock);
+	cgroup_unlock();
+
+	return 0;
+}
+#endif
+
 struct cftype bfqio_files[] = {
 	{
 		.name = "weight",
@@ -1227,6 +1437,16 @@ struct cftype bfqio_files[] = {
 		.name = "disk_sectors",
 		.read_seq_string = io_cgroup_disk_sectors_read,
 	},
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	{
+		.name = "disk_queue",
+		.read_seq_string = io_cgroup_disk_queue_read,
+	},
+	{
+		.name = "disk_dequeue",
+		.read_seq_string = io_cgroup_disk_dequeue_read,
+	},
+#endif
 };
 
 static int iocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
@@ -1367,6 +1587,11 @@ io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
 		 */
 		elv_get_iog(iog);
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		io_group_path(iog, iog->path, sizeof(iog->path));
+#endif
+
+
 		if (leaf == NULL) {
 			leaf = iog;
 			prev = leaf;
@@ -1947,6 +2172,22 @@ EXPORT_SYMBOL(elv_del_idle_slice_timer);
 static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 {
 	entity_served(&ioq->entity, served, ioq->nr_sectors);
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		{
+			struct elv_fq_data *efqd = ioq->efqd;
+			struct io_group *iog = ioq_to_io_group(ioq);
+			elv_log_ioq(efqd, ioq, "ioq served: QSt=0x%lx QSs=0x%lx"
+				" QTt=0x%lx QTs=0x%lx GTt=0x%lx "
+				" GTs=0x%lx rq_queued=%d",
+				served, ioq->nr_sectors,
+				ioq->entity.total_service,
+				ioq->entity.total_sector_service,
+				iog->entity.total_service,
+				iog->entity.total_sector_service,
+				ioq->nr_queued);
+		}
+#endif
 }
 
 /*
@@ -2238,10 +2479,29 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 	if (ioq) {
 		struct io_group *iog = ioq_to_io_group(ioq);
 		elv_log_ioq(efqd, ioq, "set_active, busy=%d ioprio=%d"
-				" weight=%u group_weight=%u",
+				" weight=%u rq_queued=%d group_weight=%u",
 				efqd->busy_queues,
 				ioq->entity.ioprio, ioq->entity.weight,
-				iog_weight(iog));
+				ioq->nr_queued, iog_weight(iog));
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+			{
+				int nr_active = 0;
+				struct io_group *parent = NULL;
+
+				parent = iog_parent(iog);
+				if (parent)
+					nr_active = elv_iog_nr_active(parent);
+
+				elv_log_ioq(efqd, ioq, "set_active, ioq"
+				" nrgrps=%d QTt=0x%lx QTs=0x%lx GTt=0x%lx "
+				" GTs=0x%lx rq_queued=%d", nr_active,
+				ioq->entity.total_service,
+				ioq->entity.total_sector_service,
+				iog->entity.total_service,
+				iog->entity.total_sector_service,
+				ioq->nr_queued);
+			}
+#endif
 		ioq->slice_end = 0;
 		ioq->slice_start = jiffies;
 
@@ -2301,10 +2561,23 @@ static void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
 {
 	BUG_ON(elv_ioq_busy(ioq));
 	BUG_ON(ioq == efqd->active_queue);
-	elv_log_ioq(efqd, ioq, "add to busy");
 	elv_activate_ioq(ioq, 0);
 	elv_mark_ioq_busy(ioq);
 	efqd->busy_queues++;
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	{
+		struct io_group *iog = ioq_to_io_group(ioq);
+		elv_log_ioq(efqd, ioq, "add to busy: QTt=0x%lx QTs=0x%lx"
+			" GTt=0x%lx GTs=0x%lx rq_queued=%d",
+			ioq->entity.total_service,
+			ioq->entity.total_sector_service,
+			iog->entity.total_service,
+			iog->entity.total_sector_service,
+			ioq->nr_queued);
+	}
+#else
+	elv_log_ioq(efqd, ioq, "add to busy");
+#endif
 }
 
 static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
@@ -2314,7 +2587,21 @@ static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
 
 	BUG_ON(!elv_ioq_busy(ioq));
 	BUG_ON(ioq->nr_queued);
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	{
+		struct io_group *iog = ioq_to_io_group(ioq);
+		elv_log_ioq(efqd, ioq, "del from busy: QTt=0x%lx "
+			"QTs=0x%lx ioq GTt=0x%lx GTs=0x%lx "
+			"rq_queued=%d",
+			ioq->entity.total_service,
+			ioq->entity.total_sector_service,
+			iog->entity.total_service,
+			iog->entity.total_sector_service,
+			ioq->nr_queued);
+	}
+#else
 	elv_log_ioq(efqd, ioq, "del from busy");
+#endif
 	elv_clear_ioq_busy(ioq);
 	BUG_ON(efqd->busy_queues == 0);
 	efqd->busy_queues--;
@@ -2503,6 +2790,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 	BUG_ON(!efqd);
 	BUG_ON(!ioq);
 	ioq->nr_queued++;
+	elv_log_ioq(efqd, ioq, "add rq: rq_queued=%d", ioq->nr_queued);
 
 	if (!elv_ioq_busy(ioq))
 		elv_add_ioq_busy(efqd, ioq);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index b7f9f82..1da7ecc 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -75,6 +75,7 @@ struct io_service_tree {
 struct io_sched_data {
 	struct io_entity *active_entity;
 	struct io_entity *next_active;
+	int nr_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
 };
 
@@ -243,6 +244,23 @@ struct io_group {
 
 	/* The device MKDEV(major, minor), this group has been created for */
 	dev_t	dev;
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	/* How many times this group has been added to active tree */
+	unsigned long queue;
+
+	/* How long this group remained on active tree, in ms */
+	unsigned long queue_duration;
+
+	/* When was this group added to active tree */
+	unsigned long queue_start;
+
+	/* How many times this group has been removed from active tree */
+	unsigned long dequeue;
+
+	/* Store cgroup path */
+	char path[128];
+#endif
 };
 
 /**
@@ -303,10 +321,29 @@ struct elv_fq_data {
 };
 
 /* Logging facilities. */
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+#define elv_log_ioq(efqd, ioq, fmt, args...) \
+{								\
+	blk_add_trace_msg((efqd)->queue, "elv%d%c %s " fmt, (ioq)->pid,	\
+			elv_ioq_sync(ioq) ? 'S' : 'A', \
+			ioq_to_io_group(ioq)->path, ##args); \
+}
+
+#define elv_log_iog(efqd, iog, fmt, args...) \
+{                                                                      \
+	blk_add_trace_msg((efqd)->queue, "elv %s " fmt, (iog)->path, ##args); \
+}
+
+#else
 #define elv_log_ioq(efqd, ioq, fmt, args...) \
 	blk_add_trace_msg((efqd)->queue, "elv%d%c " fmt, (ioq)->pid,	\
 				elv_ioq_sync(ioq) ? 'S' : 'A', ##args)
 
+#define elv_log_iog(efqd, iog, fmt, args...) \
+	blk_add_trace_msg((efqd)->queue, "elv " fmt, ##args)
+
+#endif
+
 #define elv_log(efqd, fmt, args...) \
 	blk_add_trace_msg((efqd)->queue, "elv " fmt, ##args)
 
@@ -443,7 +480,6 @@ static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
 #ifdef CONFIG_GROUP_IOSCHED
 extern int io_group_allow_merge(struct request *rq, struct bio *bio);
 extern void elv_put_iog(struct io_group *iog);
-
 static inline void elv_get_iog(struct io_group *iog)
 {
 	atomic_inc(&iog->ref);
-- 
1.6.0.6
