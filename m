From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 18/18] io-controller: Debug hierarchical IO scheduling
Date: Tue,  5 May 2009 15:58:45 -0400
Message-ID: <1241553525-28095-19-git-send-email-vgoyal__49718.7633337036$1241555860$gmane$org@redhat.com>
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

o Littile debugging aid for hierarchical IO scheduling.

o Enabled under CONFIG_DEBUG_GROUP_IOSCHED

o Currently it outputs more debug messages in blktrace output which helps
  a great deal in debugging in hierarchical setup.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |   10 +++-
 block/elevator-fq.c   |  131 +++++++++++++++++++++++++++++++++++++++++++++++--
 block/elevator-fq.h   |    6 ++
 3 files changed, 141 insertions(+), 6 deletions(-)

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
index 1dd0bb3..9500619 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -30,7 +30,7 @@ static int elv_rate_sampling_window = HZ / 10;
 #define IO_DEFAULT_GRP_CLASS   IOPRIO_CLASS_BE
 
 #define IO_SERVICE_TREE_INIT   ((struct io_service_tree)		\
-				{ RB_ROOT, RB_ROOT, NULL, NULL, 0, 0 })
+				{ RB_ROOT, RB_ROOT, 0, NULL, NULL, 0, 0 })
 
 static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
 					struct io_queue *ioq, int probe);
@@ -118,6 +118,37 @@ static inline struct io_group *io_entity_to_iog(struct io_entity *entity)
 		iog = container_of(entity, struct io_group, entity);
 	return iog;
 }
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
+#endif
 #else /* GROUP_IOSCHED */
 #define for_each_entity(entity)	\
 	for (; entity != NULL; entity = NULL)
@@ -372,7 +403,7 @@ static void bfq_active_insert(struct io_service_tree *st,
 	struct rb_node *node = &entity->rb_node;
 
 	bfq_insert(&st->active, entity);
-
+	st->nr_active++;
 	if (node->rb_left != NULL)
 		node = node->rb_left;
 	else if (node->rb_right != NULL)
@@ -434,7 +465,7 @@ static void bfq_active_extract(struct io_service_tree *st,
 
 	node = bfq_find_deepest(&entity->rb_node);
 	bfq_extract(&st->active, entity);
-
+	st->nr_active--;
 	if (node != NULL)
 		bfq_update_active_tree(node);
 }
@@ -1233,6 +1264,9 @@ struct io_group *io_group_chain_alloc(struct request_queue *q, void *key,
 
 		io_group_init_entity(iocg, iog);
 		iog->my_entity = &iog->entity;
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		iog->iocg_id = css_id(&iocg->css);
+#endif
 
 		blk_init_request_list(&iog->rl);
 
@@ -1506,6 +1540,9 @@ struct io_group *io_alloc_root_group(struct request_queue *q,
 	/* elevator reference. */
 	elv_get_iog(iog);
 	hlist_add_head_rcu(&iog->group_node, &iocg->group_data);
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	iog->iocg_id = css_id(&iocg->css);
+#endif
 	spin_unlock_irq(&iocg->lock);
 
 	return iog;
@@ -1886,6 +1923,7 @@ struct cgroup_subsys io_subsys = {
 	.destroy = iocg_destroy,
 	.populate = iocg_populate,
 	.subsys_id = io_subsys_id,
+	.use_id = 1,
 };
 
 /*
@@ -2203,6 +2241,25 @@ EXPORT_SYMBOL(elv_get_slice_idle);
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
@@ -2671,11 +2728,34 @@ static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
 
 	if (ioq) {
 		struct io_group *iog = ioq_to_io_group(ioq);
+
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
+				struct io_service_tree *grpst;
+				int nr_active = 0;
+				if (iog != efqd->root_group) {
+					grpst = io_entity_service_tree(
+								&iog->entity);
+					nr_active = grpst->nr_active;
+				}
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
@@ -2764,6 +2844,22 @@ void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
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
@@ -2773,7 +2869,24 @@ void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
 
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
@@ -3000,6 +3113,14 @@ void elv_ioq_request_add(struct request_queue *q, struct request *rq)
 
 	elv_ioq_update_io_thinktime(ioq);
 	elv_ioq_update_idle_window(q->elevator, ioq, rq);
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+		{
+			char path[128];
+			io_group_path(rq_iog(q, rq), path, sizeof(path));
+			elv_log_ioq(efqd, ioq, "add rq: group path=%s "
+					"rq_queued=%d", path, ioq->nr_queued);
+		}
+#endif
 
 	if (ioq == elv_active_ioq(q->elevator)) {
 		/*
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 42e3777..db3a347 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -43,6 +43,8 @@ struct io_service_tree {
 	struct rb_root active;
 	struct rb_root idle;
 
+	int nr_active;
+
 	struct io_entity *first_idle;
 	struct io_entity *last_idle;
 
@@ -245,6 +247,10 @@ struct io_group {
 
 	/* io group is going away */
 	int deleting;
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+	unsigned short iocg_id;
+#endif
 };
 
 /**
-- 
1.6.0.1
