From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/24] io-controller: Debug hierarchical IO scheduling
Date: Sun, 16 Aug 2009 15:30:32 -0400
Message-ID: <1250451046-9966-11-git-send-email-vgoyal__37248.7810477198$1250452766$gmane$org@redhat.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250451046-9966-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, righi.andr
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
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
 block/Kconfig.iosched |    8 +++
 block/elevator-fq.c   |  168 ++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h   |   29 +++++++++
 3 files changed, 202 insertions(+), 3 deletions(-)

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
index de13d30..051a8c9 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -251,6 +251,91 @@ init_io_entity_service_tree(struct io_entity *entity, struct io_entity *parent)
 	entity->st = &parent_iog->sched_data.service_tree[idx];
 }
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+static void io_group_path(struct io_group *iog)
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
+	cgroup_path(css->cgroup, iog->path, sizeof(iog->path));
+
+	css_put(css);
+
+	rcu_read_unlock();
+	return;
+out:
+	rcu_read_unlock();
+	iog->path[0] = '\0';
+	return;
+}
+
+static inline void debug_update_stats_enqueue(struct io_entity *entity)
+{
+	struct io_group *iog = iog_of(entity);
+
+	if (iog) {
+		struct elv_fq_data *efqd;
+
+		/*
+		 * Keep track of how many times a group has been added
+		 * to active tree.
+		 */
+		iog->queue++;
+
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		if (efqd)
+			elv_log_iog(efqd, iog, "add group weight=%u",
+					iog->entity.weight);
+		rcu_read_unlock();
+	}
+}
+
+static inline void debug_update_stats_dequeue(struct io_entity *entity)
+{
+	struct io_group *iog = iog_of(entity);
+
+	if (iog) {
+		struct elv_fq_data *efqd;
+
+		iog->dequeue++;
+		rcu_read_lock();
+		efqd = rcu_dereference(iog->key);
+		if (efqd)
+			elv_log_iog(efqd, iog, "del group weight=%u",
+					iog->entity.weight);
+		rcu_read_unlock();
+	}
+}
+
+static inline void print_ioq_service_stats(struct io_queue *ioq)
+{
+	struct io_group *iog = ioq_to_io_group(ioq);
+
+	elv_log_ioq(ioq->efqd, ioq, "service: QTt=0x%lx QTs=0x%lx GTt=0x%lx"
+		" GTs=0x%lx", ioq->entity.total_time, ioq->entity.total_sectors,
+		iog->entity.total_time, iog->entity.total_sectors);
+}
+
+#else /* DEBUG_GROUP_IOSCHED */
+static inline void io_group_path(struct io_group *iog) {}
+static inline void print_ioq_service_stats(struct io_queue *ioq) {}
+static inline void debug_update_stats_enqueue(struct io_entity *entity) {}
+static inline void debug_update_stats_dequeue(struct io_entity *entity) {}
+#endif /* DEBUG_GROUP_IOSCHED */
+
 static void
 entity_served(struct io_entity *entity, unsigned long served,
 				unsigned long nr_sectors)
@@ -338,6 +423,7 @@ static void dequeue_io_entity(struct io_entity *entity)
 	entity->on_st = 0;
 	st->nr_active--;
 	sd->nr_active--;
+	debug_update_stats_dequeue(entity);
 }
 
 static void
@@ -384,6 +470,7 @@ static void enqueue_io_entity(struct io_entity *entity)
 	entity->on_st = 1;
 	place_entity(st, entity, 0);
 	__enqueue_io_entity(st, entity);
+	debug_update_stats_enqueue(entity);
 }
 
 static struct io_entity *__lookup_next_io_entity(struct io_service_tree *st)
@@ -540,6 +627,9 @@ EXPORT_SYMBOL(elv_put_ioq);
 static void elv_ioq_served(struct io_queue *ioq, unsigned long served)
 {
 	entity_served(&ioq->entity, served, ioq->nr_sectors);
+	elv_log_ioq(ioq->efqd, ioq, "ioq served: QSt=0x%lx QSs=0x%lx qued=%d",
+			served, ioq->nr_sectors, ioq->nr_queued);
+	print_ioq_service_stats(ioq);
 }
 
 /*
@@ -793,7 +883,6 @@ io_cgroup_lookup_group(struct io_cgroup *iocg, void *key)
 	return NULL;
 }
 
-
 #define SHOW_FUNCTION(__VAR)						\
 static u64 io_cgroup_##__VAR##_read(struct cgroup *cgroup,		\
 				       struct cftype *cftype)		\
@@ -913,6 +1002,64 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
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
+		if (iog->key)
+			seq_printf(m, "%u:%u %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev), iog->queue);
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
+		if (iog->key)
+			seq_printf(m, "%u:%u %lu\n", MAJOR(iog->dev),
+					MINOR(iog->dev), iog->dequeue);
+	}
+	spin_unlock_irq(&iocg->lock);
+	cgroup_unlock();
+
+	return 0;
+}
+#endif
+
 struct cftype io_files[] = {
 	{
 		.name = "weight",
@@ -932,6 +1079,16 @@ struct cftype io_files[] = {
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
@@ -1059,6 +1216,7 @@ io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
 		 * or cgroup deletion path depending on who is exiting first.
 		 */
 		elv_get_iog(iog);
+		io_group_path(iog);
 
 		if (leaf == NULL) {
 			leaf = iog;
@@ -1233,6 +1391,7 @@ static struct io_group *io_alloc_root_group(struct request_queue *q,
 	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
 	iog->iocg_id = css_id(&iocg->css);
 	spin_unlock_irq(&iocg->lock);
+	io_group_path(iog);
 
 	return iog;
 }
@@ -1519,6 +1678,7 @@ __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq, int coop)
 				efqd->busy_queues, ioq->entity.ioprio_class,
 				ioq->entity.ioprio, ioq->entity.weight,
 				iog_weight(iog), ioq->nr_queued);
+		print_ioq_service_stats(ioq);
 
 		ioq->slice_start = ioq->slice_end = 0;
 		ioq->dispatch_start = jiffies;
@@ -1577,10 +1737,11 @@ static void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
 {
 	BUG_ON(elv_ioq_busy(ioq));
 	BUG_ON(ioq == efqd->active_queue);
-	elv_log_ioq(efqd, ioq, "add to busy");
 	enqueue_ioq(ioq);
 	elv_mark_ioq_busy(ioq);
 	efqd->busy_queues++;
+	elv_log_ioq(efqd, ioq, "add to busy: qued=%d", ioq->nr_queued);
+	print_ioq_service_stats(ioq);
 }
 
 static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq)
@@ -1589,7 +1750,8 @@ static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq)
 
 	BUG_ON(!elv_ioq_busy(ioq));
 	BUG_ON(ioq->nr_queued);
-	elv_log_ioq(efqd, ioq, "del from busy");
+	elv_log_ioq(efqd, ioq, "del from busy: qued=%d", ioq->nr_queued);
+	print_ioq_service_stats(ioq);
 	elv_clear_ioq_busy(ioq);
 	BUG_ON(efqd->busy_queues == 0);
 	efqd->busy_queues--;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index e1d5bdd..0b6ecf5 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -113,6 +113,16 @@ struct io_group {
 
 	/* The device MKDEV(major, minor), this group has been created for */
 	dev_t	dev;
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	/* How many times this group has been added to active tree */
+	unsigned long queue;
+
+	/* How many times this group has been removed from active tree */
+	unsigned long dequeue;
+
+	/* Store cgroup path */
+	char path[128];
+#endif
 };
 
 struct io_cgroup {
@@ -169,10 +179,29 @@ struct elv_fq_data {
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
 
-- 
1.6.0.6
