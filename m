From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 19/20] io-controller: Debug hierarchical IO scheduling
Date: Tue, 26 May 2009 18:42:08 -0400
Message-ID: <1243377729-2176-20-git-send-email-vgoyal__12781.0741927989$1243380962$gmane$org@redhat.com>
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

o Littile debugging aid for hierarchical IO scheduling.

o Enabled under CONFIG_DEBUG_GROUP_IOSCHED

o Currently it outputs more debug messages in blktrace output which helps
  a great deal in debugging in hierarchical setup. It also creates additional
  cgroup interfaces io.disk_queue and io.disk_dequeue to output some more
  debugging data.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |   10 ++-
 block/elevator-fq.c   |  298 ++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h   |   14 +++
 3 files changed, 318 insertions(+), 4 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 0677099..79f188c 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -140,6 +140,14 @@ config TRACK_ASYNC_CONTEXT
 	  request, original owner of the bio is decided by using io tracking
 	  patches otherwise we continue to attribute the request to the
 	  submitting thread.
-endmenu
 
+config DEBUG_GROUP_IOSCHED
+	bool "Debug Hierarchical Scheduling support"
+	depends on CGROUPS && GROUP_IOSCHED
+	default n
+	---help---
+	  Enable some debugging hooks for hierarchical scheduling support.
+	  Currently it just outputs more information in blktrace output.
+
+endmenu
 endif
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 6d97ad9..6dd8683 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -115,6 +115,126 @@ static inline int iog_deleting(struct io_group *iog)
 	return iog->deleting;
 }
 
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
+		char path[128];
+
+		/*
+		 * Keep track of how many times a group has been removed
+		 * from active tree because it did not have any active
+		 * backlogged ioq under it
+		 */
+		iog->queue++;
+		iog->queue_start = jiffies;
+
+		/* Log group addition event */
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		if (efqd) {
+			io_group_path(iog, path, sizeof(path));
+			elv_log(efqd, "add group=%s weight=%ld", path,
+					iog->entity.weight);
+		}
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
+		char path[128];
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
+		if (efqd) {
+			io_group_path(iog, path, sizeof(path));
+			elv_log(efqd, "del group=%s weight=%ld", path,
+					iog->entity.weight);
+		}
+		rcu_read_unlock();
+	}
+}
+#endif
+
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -137,6 +257,12 @@ static inline int iog_deleting(struct io_group *iog)
 	/* In flat mode, root cgroup can't be deleted. */
 	return 0;
 }
+
+static inline struct io_group *io_entity_to_iog(struct io_entity *entity)
+{
+	return NULL;
+}
+
 #endif
 
 /*
@@ -570,6 +696,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 {
 	struct io_sched_data *sd = entity->sched_data;
 	struct io_service_tree *st = io_entity_service_tree(entity);
+	int newly_added = 0;
 
 	if (entity == sd->active_entity) {
 		BUG_ON(entity->tree != NULL);
@@ -596,6 +723,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 		bfq_idle_extract(st, entity);
 		entity->start = bfq_gt(st->vtime, entity->finish) ?
 				       st->vtime : entity->finish;
+		newly_added = 1;
 	} else {
 		/*
 		 * The finish time of the entity may be invalid, and
@@ -608,6 +736,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 
 		BUG_ON(entity->on_st);
 		entity->on_st = 1;
+		newly_added = 1;
 	}
 
 	st = __bfq_entity_update_prio(st, entity);
@@ -645,6 +774,10 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 		bfq_calc_finish(entity, entity->budget);
 	}
 	bfq_active_insert(st, entity);
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	if (newly_added)
+		bfq_account_for_entity_addition(entity);
+#endif
 }
 
 /**
@@ -715,6 +848,9 @@ int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 	BUG_ON(sd->active_entity == entity);
 	BUG_ON(sd->next_active == entity);
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	bfq_account_for_entity_deletion(entity);
+#endif
 	return ret;
 }
 
@@ -1205,6 +1341,67 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
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
+	spin_lock_irq(&iocg->lock);
+	/* Loop through all the io groups and print statistics */
+	hlist_for_each_entry_rcu(iog, n, &iocg->group_data, group_node) {
+		/*
+		 * There might be groups which are not functional and
+		 * waiting to be reclaimed upon cgoup deletion.
+		 */
+		if (iog->key) {
+			seq_printf(m, "%u %u %lu %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev), iog->queue,
+					iog->queue_duration);
+		}
+	}
+	spin_unlock_irq(&iocg->lock);
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
+			seq_printf(m, "%u %u %lu\n", MAJOR(iog->dev),
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
 /**
  * bfq_group_chain_alloc - allocate a chain of groups.
  * @bfqd: queue descriptor.
@@ -1754,6 +1951,16 @@ struct cftype bfqio_files[] = {
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
 
 int iocg_populate(struct cgroup_subsys *subsys, struct cgroup *cgroup)
@@ -2078,6 +2285,7 @@ struct cgroup_subsys io_subsys = {
 	.destroy = iocg_destroy,
 	.populate = iocg_populate,
 	.subsys_id = io_subsys_id,
+	.use_id = 1,
 };
 
 /*
@@ -2361,6 +2569,25 @@ EXPORT_SYMBOL(elv_get_slice_idle);
 void elv_ioq_served(struct io_queue *ioq, bfq_service_t served)
 {
 	entity_served(&ioq->entity, served, ioq->nr_sectors);
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		{
+			struct elv_fq_data *efqd = ioq->efqd;
+			char path[128];
+			struct io_group *iog = ioq_to_io_group(ioq);
+			io_group_path(iog, path, sizeof(path));
+			elv_log_ioq(efqd, ioq, "ioq served: QSt=0x%lx QSs=0x%lx"
+				" QTt=0x%lx QTs=0x%lx grp=%s GTt=0x%lx "
+				" GTs=0x%lx rq_queued=%d",
+				served, ioq->nr_sectors,
+				ioq->entity.total_service,
+				ioq->entity.total_sector_service,
+				path,
+				iog->entity.total_service,
+				iog->entity.total_sector_service,
+				ioq->nr_queued);
+		}
+#endif
 }
 
 /* Tells whether ioq is queued in root group or not */
@@ -2835,10 +3062,32 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 	if (ioq) {
 		struct io_group *iog = ioq_to_io_group(ioq);
 		elv_log_ioq(efqd, ioq, "set_active, busy=%d ioprio=%d"
-				" weight=%ld group_weight=%ld",
+				" weight=%ld rq_queued=%d group_weight=%ld",
 				efqd->busy_queues,
 				ioq->entity.ioprio, ioq->entity.weight,
-				iog_weight(iog));
+				ioq->nr_queued, iog_weight(iog));
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+			{
+				char path[128];
+				int nr_active = 0;
+				struct io_group *parent = NULL;
+
+				parent = iog_parent(iog);
+				if (parent)
+					nr_active = elv_iog_nr_active(parent);
+
+				io_group_path(iog, path, sizeof(path));
+				elv_log_ioq(efqd, ioq, "set_active, ioq grp=%s"
+				" nrgrps=%d QTt=0x%lx QTs=0x%lx GTt=0x%lx "
+				" GTs=0x%lx rq_queued=%d", path, nr_active,
+				ioq->entity.total_service,
+				ioq->entity.total_sector_service,
+				iog->entity.total_service,
+				iog->entity.total_sector_service,
+				ioq->nr_queued);
+			}
+#endif
 		ioq->slice_end = 0;
 
 		elv_clear_ioq_wait_request(ioq);
@@ -2920,6 +3169,22 @@ void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
 	efqd->busy_queues++;
 	if (elv_ioq_class_rt(ioq))
 		efqd->busy_rt_queues++;
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		{
+			char path[128];
+			struct io_group *iog = ioq_to_io_group(ioq);
+			io_group_path(iog, path, sizeof(path));
+			elv_log(efqd, "add to busy: QTt=0x%lx QTs=0x%lx "
+				"ioq grp=%s GTt=0x%lx GTs=0x%lx rq_queued=%d",
+				ioq->entity.total_service,
+				ioq->entity.total_sector_service,
+				path,
+				iog->entity.total_service,
+				iog->entity.total_sector_service,
+				ioq->nr_queued);
+		}
+#endif
 }
 
 void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
@@ -2929,7 +3194,24 @@ void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
 
 	BUG_ON(!elv_ioq_busy(ioq));
 	BUG_ON(ioq->nr_queued);
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		{
+			char path[128];
+			struct io_group *iog = ioq_to_io_group(ioq);
+			io_group_path(iog, path, sizeof(path));
+			elv_log_ioq(efqd, ioq, "del from busy: QTt=0x%lx "
+				"QTs=0x%lx ioq grp=%s GTt=0x%lx GTs=0x%lx "
+				"rq_queued=%d",
+				ioq->entity.total_service,
+				ioq->entity.total_sector_service,
+				path,
+				iog->entity.total_service,
+				iog->entity.total_sector_service,
+				ioq->nr_queued);
+		}
+#else
 	elv_log_ioq(efqd, ioq, "del from busy");
+#endif
 	elv_clear_ioq_busy(ioq);
 	BUG_ON(efqd->busy_queues == 0);
 	efqd->busy_queues--;
@@ -3157,6 +3439,16 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 
 	elv_ioq_update_io_thinktime(ioq);
 	elv_ioq_update_idle_window(q->elevator, ioq, rq);
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		{
+			char path[128];
+			struct io_group *iog = ioq_to_io_group(ioq);
+
+			io_group_path(iog, path, sizeof(path));
+			elv_log_ioq(efqd, ioq, "add rq: group path=%s "
+					"rq_queued=%d", path, ioq->nr_queued);
+		}
+#endif
 
 	if (ioq == elv_active_ioq(q->elevator)) {
 		/*
@@ -3364,7 +3656,7 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 	}
 
 	/* We are waiting for this queue to become busy before it expires.*/
-	if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
+	if (elv_ioq_wait_busy(ioq)) {
 		ioq = NULL;
 		goto keep_queue;
 	}
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 9062bfd..de0f6b0 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -249,6 +249,20 @@ struct io_group {
 
 	/* request list associated with the group */
 	struct request_list rl;
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
+#endif
 };
 
 struct io_policy_node {
-- 
1.6.0.1
