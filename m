From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/24] io-controller: core bfq scheduler changes for
	hierarchical setup
Date: Fri, 24 Jul 2009 16:27:36 -0400
Message-ID: <1248467274-32073-7-git-send-email-vgoyal__43023.5114218251$1248469914$gmane$org@redhat.com>
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

o Some of the core bfq scheduler changes for hiearchical groups.

Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |  169 ++++++++++++++++++++++++++++++++++++++++++++++-----
 block/elevator-fq.h |    4 +
 init/Kconfig        |    8 +++
 3 files changed, 165 insertions(+), 16 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index e302ca0..8f8fe9a 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -38,6 +38,69 @@ static struct kmem_cache *elv_ioq_pool;
  */
 #define WFQ_SERVICE_SHIFT	22
 
+#ifdef CONFIG_GROUP_IOSCHED
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = entity->parent)
+
+#define for_each_entity_safe(entity, parent) \
+	for (; entity && ({ parent = entity->parent; 1; }); entity = parent)
+
+
+static struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
+						 int extract);
+
+static int bfq_update_next_active(struct io_sched_data *sd)
+{
+	struct io_group *iog;
+	struct io_entity *entity, *next_active;
+
+	if (sd->active_entity != NULL)
+		/* will update/requeue at the end of service */
+		return 0;
+
+	/*
+	 * NOTE: this can be improved in may ways, such as returning
+	 * 1 (and thus propagating upwards the update) only when the
+	 * budget changes, or caching the bfqq that will be scheduled
+	 * next from this subtree.  By now we worry more about
+	 * correctness than about performance...
+	 */
+	next_active = bfq_lookup_next_entity(sd, 0);
+	sd->next_active = next_active;
+
+	if (next_active != NULL) {
+		iog = container_of(sd, struct io_group, sched_data);
+		entity = iog->my_entity;
+		if (entity != NULL)
+			entity->budget = next_active->budget;
+	}
+
+	return 1;
+}
+
+static inline void bfq_check_next_active(struct io_sched_data *sd,
+					 struct io_entity *entity)
+{
+	BUG_ON(sd->next_active != entity);
+}
+#else /* GROUP_IOSCHED */
+#define for_each_entity(entity)	\
+	for (; entity != NULL; entity = NULL)
+
+#define for_each_entity_safe(entity, parent) \
+	for (parent = NULL; entity != NULL; entity = parent)
+
+static inline int bfq_update_next_active(struct io_sched_data *sd)
+{
+	return 0;
+}
+
+static inline void bfq_check_next_active(struct io_sched_data *sd,
+					 struct io_entity *entity)
+{
+}
+#endif /* GROUP_IOSCHED */
+
 static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
 					unsigned short prio)
 {
@@ -582,8 +645,10 @@ static struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
 		entity = __bfq_lookup_next_entity(st);
 		if (entity != NULL) {
 			if (extract) {
+				bfq_check_next_active(sd, entity);
 				bfq_active_remove(st, entity);
 				sd->active_entity = entity;
+				sd->next_active = NULL;
 			}
 			break;
 		}
@@ -660,11 +725,8 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
 	if (add_front) {
 		struct io_entity *next_entity;
 
-		/*
-		 * Determine the entity which will be dispatched next
-		 * Use sd->next_active once hierarchical patch is applied
-		 */
-		next_entity = bfq_lookup_next_entity(sd, 0);
+		/* Determine the entity which will be dispatched next */
+		next_entity = sd->next_active;
 
 		if (next_entity && next_entity != entity) {
 			struct io_service_tree *new_st;
@@ -696,7 +758,21 @@ static void __bfq_activate_entity(struct io_entity *entity, int add_front)
  */
 static void bfq_activate_entity(struct io_entity *entity, int add_front)
 {
-	__bfq_activate_entity(entity, add_front);
+	struct io_sched_data *sd;
+
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity, add_front);
+
+		add_front = 0;
+		sd = entity->sched_data;
+		if (!bfq_update_next_active(sd))
+			/*
+			 * No need to propagate the activation to the
+			 * upper entities, as they will be updated when
+			 * the active entity is rescheduled.
+			 */
+			break;
+	}
 }
 
 /**
@@ -731,6 +807,8 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 		bfq_idle_remove(st, entity);
 	else if (entity->tree != NULL)
 		BUG();
+	if (was_active || sd->next_active == entity)
+		ret = bfq_update_next_active(sd);
 
 	if (!requeue || !bfq_gt(entity->finish, st->vtime))
 		bfq_forget_entity(st, entity);
@@ -738,6 +816,7 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
 		bfq_idle_insert(st, entity);
 
 	BUG_ON(sd->active_entity == entity);
+	BUG_ON(sd->next_active == entity);
 
 	return ret;
 }
@@ -749,18 +828,62 @@ static int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
  */
 static void bfq_deactivate_entity(struct io_entity *entity, int requeue)
 {
-	__bfq_deactivate_entity(entity, requeue);
+	struct io_sched_data *sd;
+	struct io_entity *parent;
+
+	for_each_entity_safe(entity, parent) {
+		sd = entity->sched_data;
+
+		if (!__bfq_deactivate_entity(entity, requeue))
+			/*
+			 * The parent entity is still backlogged, and
+			 * we don't need to update it as it is still
+			 * under service.
+			 */
+			break;
+
+		if (sd->next_active != NULL) {
+			/*
+			 * The parent entity is still backlogged and
+			 * the budgets on the path towards the root
+			 * need to be updated.
+			 */
+			goto update;
+		}
+
+		/*
+		 * If we reach there the parent is no more backlogged and
+		 * we want to propagate the dequeue upwards.
+		 *
+		 */
+
+		requeue = 1;
+	}
+
+	return;
+
+update:
+	entity = parent;
+	for_each_entity(entity) {
+		__bfq_activate_entity(entity, 0);
+
+		sd = entity->sched_data;
+		if (!bfq_update_next_active(sd))
+			break;
+	}
 }
 
 static void entity_served(struct io_entity *entity, unsigned long served)
 {
 	struct io_service_tree *st;
 
-	st = io_entity_service_tree(entity);
-	entity->service += served;
-	BUG_ON(st->wsum == 0);
-	st->vtime += bfq_delta(served, st->wsum);
-	bfq_forget_idle(st);
+	for_each_entity(entity) {
+		st = io_entity_service_tree(entity);
+		entity->service += served;
+		BUG_ON(st->wsum == 0);
+		st->vtime += bfq_delta(served, st->wsum);
+		bfq_forget_idle(st);
+	}
 }
 
 /**
@@ -1068,11 +1191,25 @@ static struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
 		return NULL;
 
 	sd = &efqd->root_group->sched_data;
-	entity = bfq_lookup_next_entity(sd, 1);
 
-	BUG_ON(!entity);
-	if (extract)
-		entity->service = 0;
+	for (; sd != NULL; sd = entity->my_sched_data) {
+		entity = bfq_lookup_next_entity(sd, 1);
+		/*
+		 * entity can be null despite the fact that there are busy
+		 * queues. if all the busy queues are under a group which is
+		 * currently under service.
+		 * So if we are just looking for next ioq while something is
+		 * being served, null entity is not an error.
+		 */
+		BUG_ON(!entity && extract);
+
+		if (extract)
+			entity->service = 0;
+
+		if (!entity)
+			return NULL;
+	}
+
 	ioq = io_entity_to_ioq(entity);
 
 	return ioq;
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index d870360..ed65a87 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -72,6 +72,7 @@ struct io_service_tree {
  */
 struct io_sched_data {
 	struct io_entity *active_entity;
+	struct io_entity *next_active;
 	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
 };
 
@@ -178,7 +179,10 @@ struct io_queue {
 };
 
 struct io_group {
+	struct io_entity entity;
 	struct io_sched_data sched_data;
+	struct io_entity *my_entity;
+
 	/*
 	 * async queue for each priority case for RT and BE class.
 	 * Used only for cfq.
diff --git a/init/Kconfig b/init/Kconfig
index cb2c092..fa3edd6 100644
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
