From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 24/25] io-controller: Debug hierarchical IO scheduling
Date: Thu,  2 Jul 2009 16:01:56 -0400
Message-ID: <1246564917-19603-25-git-send-email-vgoyal__498.317639767443$1246568202$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |   10 ++-
 block/as-iosched.c    |   50 ++++++---
 block/elevator-fq.c   |  280 ++++++++++++++++++++++++++++++++++++++++++++++++-
 block/elevator-fq.h   |   36 +++++++
 4 files changed, 354 insertions(+), 22 deletions(-)

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
diff --git a/block/as-iosched.c b/block/as-iosched.c
index 213f3e3..9ad96ee 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -78,6 +78,7 @@ enum anticipation_status {
 };
 
 struct as_queue {
+	struct io_queue *ioq;
 	/*
 	 * requests (as_rq s) are present on both sort_list and fifo_list
 	 */
@@ -162,6 +163,17 @@ enum arq_state {
 #define RQ_STATE(rq)	((enum arq_state)(rq)->elevator_private2)
 #define RQ_SET_STATE(rq, state)	((rq)->elevator_private2 = (void *) state)
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+#define as_log_asq(ad, asq, fmt, args...)				\
+{									\
+	blk_add_trace_msg((ad)->q, "as %s " fmt,			\
+			ioq_to_io_group((asq)->ioq)->path, ##args);	\
+}
+#else
+#define as_log_asq(ad, asq, fmt, args...) \
+	blk_add_trace_msg((ad)->q, "as " fmt, ##args)
+#endif
+
 #define as_log(ad, fmt, args...)        \
 	blk_add_trace_msg((ad)->q, "as " fmt, ##args)
 
@@ -225,7 +237,7 @@ static void as_save_batch_context(struct as_data *ad, struct as_queue *asq)
 	}
 
 out:
-	as_log(ad, "save batch: dir=%c time_left=%d changed_batch=%d"
+	as_log_asq(ad, asq, "save batch: dir=%c time_left=%d changed_batch=%d"
 			" new_batch=%d, antic_status=%d",
 			ad->batch_data_dir ? 'R' : 'W',
 			asq->current_batch_time_left,
@@ -247,8 +259,8 @@ static void as_restore_batch_context(struct as_data *ad, struct as_queue *asq)
 						asq->current_batch_time_left;
 	/* restore asq batch_data_dir info */
 	ad->batch_data_dir = asq->saved_batch_data_dir;
-	as_log(ad, "restore batch: dir=%c time=%d reads_q=%d writes_q=%d"
-			" ad->antic_status=%d",
+	as_log_asq(ad, asq, "restore batch: dir=%c time=%d reads_q=%d"
+			" writes_q=%d ad->antic_status=%d",
 			ad->batch_data_dir ? 'R' : 'W',
 			asq->current_batch_time_left,
 			asq->nr_queued[1], asq->nr_queued[0],
@@ -277,8 +289,8 @@ static int as_expire_ioq(struct request_queue *q, void *sched_queue,
 	int status = ad->antic_status;
 	struct as_queue *asq = sched_queue;
 
-	as_log(ad, "as_expire_ioq slice_expired=%d, force=%d", slice_expired,
-		force);
+	as_log_asq(ad, asq, "as_expire_ioq slice_expired=%d, force=%d",
+			slice_expired, force);
 
 	/* Forced expiry. We don't have a choice */
 	if (force) {
@@ -1021,9 +1033,10 @@ static void update_write_batch(struct as_data *ad, struct request *rq)
 	if (write_time < 0)
 		write_time = 0;
 
-	as_log(ad, "upd write: write_time=%d batch=%d write_batch_idled=%d"
-			" current_write_count=%d", write_time, batch,
-			asq->write_batch_idled, asq->current_write_count);
+	as_log_asq(ad, asq, "upd write: write_time=%d batch=%d"
+			" write_batch_idled=%d current_write_count=%d",
+			write_time, batch, asq->write_batch_idled,
+			asq->current_write_count);
 
 	if (write_time > batch && !asq->write_batch_idled) {
 		if (write_time > batch * 3)
@@ -1040,7 +1053,7 @@ static void update_write_batch(struct as_data *ad, struct request *rq)
 	if (asq->write_batch_count < 1)
 		asq->write_batch_count = 1;
 
-	as_log(ad, "upd write count=%d", asq->write_batch_count);
+	as_log_asq(ad, asq, "upd write count=%d", asq->write_batch_count);
 }
 
 /*
@@ -1059,7 +1072,7 @@ static void as_completed_request(struct request_queue *q, struct request *rq)
 		goto out;
 	}
 
-	as_log(ad, "complete: reads_q=%d writes_q=%d changed_batch=%d"
+	as_log_asq(ad, asq, "complete: reads_q=%d writes_q=%d changed_batch=%d"
 		" new_batch=%d switch_queue=%d, dir=%c",
 		asq->nr_queued[1], asq->nr_queued[0], ad->changed_batch,
 		ad->new_batch, ad->switch_queue,
@@ -1253,7 +1266,7 @@ static void as_move_to_dispatch(struct as_data *ad, struct request *rq)
 	if (RQ_IOC(rq) && RQ_IOC(rq)->aic)
 		atomic_inc(&RQ_IOC(rq)->aic->nr_dispatched);
 	ad->nr_dispatched++;
-	as_log(ad, "dispatch req dir=%c nr_dispatched = %d",
+	as_log_asq(ad, asq, "dispatch req dir=%c nr_dispatched = %d",
 			data_dir ? 'R' : 'W', ad->nr_dispatched);
 }
 
@@ -1302,7 +1315,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 		}
 		asq->last_check_fifo[BLK_RW_ASYNC] = jiffies;
 
-		as_log(ad, "forced dispatch");
+		as_log_asq(ad, asq, "forced dispatch");
 		return dispatched;
 	}
 
@@ -1316,7 +1329,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 		|| ad->antic_status == ANTIC_WAIT_REQ
 		|| ad->antic_status == ANTIC_WAIT_NEXT
 		|| ad->changed_batch) {
-		as_log(ad, "no dispatch. read_q=%d, writes_q=%d"
+		as_log_asq(ad, asq, "no dispatch. read_q=%d, writes_q=%d"
 			" ad->antic_status=%d, changed_batch=%d,"
 			" switch_queue=%d new_batch=%d", asq->nr_queued[1],
 			asq->nr_queued[0], ad->antic_status, ad->changed_batch,
@@ -1335,7 +1348,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 				goto fifo_expired;
 
 			if (as_can_anticipate(ad, rq)) {
-				as_log(ad, "can_anticipate = 1");
+				as_log_asq(ad, asq, "can_anticipate = 1");
 				as_antic_waitreq(ad);
 				return 0;
 			}
@@ -1355,7 +1368,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 	 * data direction (read / write)
 	 */
 
-	as_log(ad, "select a fresh batch and request");
+	as_log_asq(ad, asq, "select a fresh batch and request");
 
 	if (reads) {
 		BUG_ON(RB_EMPTY_ROOT(&asq->sort_list[BLK_RW_SYNC]));
@@ -1371,7 +1384,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 			ad->changed_batch = 1;
 		}
 		ad->batch_data_dir = BLK_RW_SYNC;
-		as_log(ad, "new batch dir is sync");
+		as_log_asq(ad, asq, "new batch dir is sync");
 		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_SYNC].next);
 		asq->last_check_fifo[ad->batch_data_dir] = jiffies;
 		goto dispatch_request;
@@ -1396,7 +1409,7 @@ dispatch_writes:
 			ad->new_batch = 0;
 		}
 		ad->batch_data_dir = BLK_RW_ASYNC;
-		as_log(ad, "new batch dir is async");
+		as_log_asq(ad, asq, "new batch dir is async");
 		asq->current_write_count = asq->write_batch_count;
 		asq->write_batch_idled = 0;
 		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_ASYNC].next);
@@ -1459,7 +1472,7 @@ static void as_add_request(struct request_queue *q, struct request *rq)
 	rq->elevator_private = as_get_io_context(q->node);
 
 	asq->nr_queued[data_dir]++;
-	as_log(ad, "add a %c request read_q=%d write_q=%d",
+	as_log_asq(ad, asq, "add a %c request read_q=%d write_q=%d",
 			data_dir ? 'R' : 'W', asq->nr_queued[1],
 			asq->nr_queued[0]);
 
@@ -1614,6 +1627,7 @@ static void *as_alloc_as_queue(struct request_queue *q,
 
 	if (asq->write_batch_count < 2)
 		asq->write_batch_count = 2;
+	asq->ioq = ioq;
 out:
 	return asq;
 }
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 31b066d..5b3f068 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -159,6 +159,119 @@ static void bfq_find_matching_entity(struct io_entity **entity,
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
@@ -186,6 +299,11 @@ static void bfq_find_matching_entity(struct io_entity **entity,
 					struct io_entity **new_entity)
 {
 }
+
+static inline struct io_group *io_entity_to_iog(struct io_entity *entity)
+{
+	return NULL;
+}
 #endif /* GROUP_IOSCHED */
 
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
@@ -769,6 +887,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 {
 	struct io_sched_data *sd = entity->sched_data;
 	struct io_service_tree *st = io_entity_service_tree(entity);
+	int newly_added = 0;
 
 	if (entity == sd->active_entity) {
 		BUG_ON(entity->tree != NULL);
@@ -795,6 +914,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 		bfq_idle_remove(st, entity);
 		entity->start = bfq_gt(st->vtime, entity->finish) ?
 				       st->vtime : entity->finish;
+		newly_added = 1;
 	} else {
 		/*
 		 * The finish time of the entity may be invalid, and
@@ -807,6 +927,7 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 
 		BUG_ON(entity->on_st);
 		entity->on_st = 1;
+		newly_added = 1;
 	}
 
 	st = __bfq_entity_update_prio(st, entity);
@@ -844,6 +965,11 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
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
@@ -912,6 +1038,9 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 	BUG_ON(sd->active_entity == entity);
 	BUG_ON(sd->next_active == entity);
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	bfq_account_for_entity_deletion(entity);
+#endif
 	return ret;
 }
 
@@ -1170,6 +1299,10 @@ int elv_io_group_congested(struct request_queue *q, struct page *page, int sync)
 	}
 
 	ret = elv_is_iog_congested(q, iog, sync);
+	if (ret)
+		elv_log_iog(&q->elevator->efqd, iog, "iog congested=%d sync=%d"
+			" rl.count[sync]=%d nr_group_requests=%d",
+			ret, sync, iog->rl.count[sync], q->nr_group_requests);
 	rcu_read_unlock();
 	return ret;
 }
@@ -1538,6 +1671,67 @@ static int io_cgroup_disk_sectors_read(struct cgroup *cgroup,
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
+			seq_printf(m, "%u %u %lu %lu\n", MAJOR(iog->dev),
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
 struct cftype bfqio_files[] = {
 	{
 		.name = "policy",
@@ -1563,6 +1757,16 @@ struct cftype bfqio_files[] = {
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
@@ -1707,6 +1911,11 @@ io_group_chain_alloc(struct request_queue *q, void *key, struct cgroup *cgroup)
 		blk_init_request_list(&iog->rl);
 		elv_io_group_congestion_threshold(q, iog);
 
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		io_group_path(iog, iog->path, sizeof(iog->path));
+#endif
+
+
 		if (leaf == NULL) {
 			leaf = iog;
 			prev = leaf;
@@ -2548,6 +2757,22 @@ EXPORT_SYMBOL(elv_get_slice_idle);
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
 
 /* Tells whether ioq is queued in root group or not */
@@ -2926,10 +3151,29 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
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
 
 		elv_clear_ioq_wait_request(ioq);
@@ -3010,6 +3254,21 @@ static void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
 		struct io_group *iog = ioq_to_io_group(ioq);
 		iog->busy_rt_queues++;
 	}
+
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
@@ -3019,7 +3278,21 @@ static void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
 
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
@@ -3311,6 +3584,7 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 
 	elv_ioq_update_io_thinktime(ioq);
 	elv_ioq_update_idle_window(q->elevator, ioq, rq);
+	elv_log_ioq(efqd, ioq, "add rq: rq_queued=%d", ioq->nr_queued);
 
 	if (ioq == elv_active_ioq(q->elevator)) {
 		/*
@@ -3531,7 +3805,7 @@ void *elv_fq_select_ioq(struct request_queue *q, int force)
 	}
 
 	/* We are waiting for this queue to become busy before it expires.*/
-	if (efqd->fairness && elv_ioq_wait_busy(ioq)) {
+	if (elv_ioq_wait_busy(ioq)) {
 		ioq = NULL;
 		goto keep_queue;
 	}
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 58c650b..19ac8ca 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -265,6 +265,23 @@ struct io_group {
 
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
+
+	/* Store cgroup path */
+	char path[128];
+#endif
 };
 
 struct io_policy_node {
@@ -368,10 +385,29 @@ struct elv_fq_data {
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
