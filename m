From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 24/24] io-controller: debug elevator fair queuing support
Date: Sun, 16 Aug 2009 15:30:46 -0400
Message-ID: <1250451046-9966-25-git-send-email-vgoyal__5599.67197846181$1250451904$gmane$org@redhat.com>
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

o More debugging help to debug elevator fair queuing support. Enabled under
  CONFIG_DEBUG_ELV_FAIR_QUEUING. Currently it prints vdisktime related
  trace messages in blktrace.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |    9 +++++++++
 block/elevator-fq.c   |   47 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 55 insertions(+), 1 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 8b507c4..edcd317 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -15,6 +15,15 @@ config ELV_FAIR_QUEUING
 	  other ioschedulers can make use of it.
 	  If unsure, say N.
 
+config DEBUG_ELV_FAIR_QUEUING
+	bool "Debug elevator fair queuing"
+	depends on ELV_FAIR_QUEUING
+	default n
+	---help---
+	  Enable some debugging hooks for elevator fair queuing support.
+	  Currently it just outputs more information about vdisktime in
+	  blktrace output .
+
 config IOSCHED_NOOP
 	bool
 	default y
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 2f7a419..d04e925 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -34,6 +34,24 @@ static struct kmem_cache *elv_ioq_pool;
 #define ELV_SERVICE_TREE_INIT   ((struct io_service_tree)	\
 				{ RB_ROOT, NULL, 0, NULL, 0})
 
+#ifdef CONFIG_DEBUG_ELV_FAIR_QUEUING
+#define elv_log_entity(entity, fmt, args...) 			\
+{                                                               \
+{								\
+	struct io_queue *ioq = ioq_of(entity);			\
+	struct io_group *iog = iog_of(entity);			\
+								\
+	if (ioq) {						\
+		elv_log_ioq(ioq->efqd, ioq, fmt, ##args);	\
+	} else	{						\
+		elv_log_iog((struct elv_fq_data *)iog->key, iog, fmt, ##args);\
+	}							\
+}								\
+}
+#else
+#define elv_log_entity(entity, fmt, args...)
+#endif
+
 static inline struct io_queue *ioq_of(struct io_entity *entity)
 {
 	if (entity->my_sd == NULL)
@@ -350,15 +368,39 @@ static inline void debug_update_stats_enqueue(struct io_entity *entity) {}
 static inline void debug_update_stats_dequeue(struct io_entity *entity) {}
 #endif /* DEBUG_GROUP_IOSCHED */
 
+#ifdef CONFIG_DEBUG_ELV_FAIR_QUEUING
+static inline void debug_entity_vdisktime(struct io_entity *entity,
+					unsigned long served, u64 delta)
+{
+	struct elv_fq_data *efqd;
+	struct io_group *iog;
+
+	elv_log_entity(entity, "vdisktime=%llu service=%lu delta=%llu"
+				" entity->weight=%u", entity->vdisktime,
+				served, delta, entity->weight);
+
+	iog = iog_of(parent_entity(entity));
+	efqd = iog->key;
+	elv_log_iog(efqd, iog, "min_vdisktime=%llu", entity->st->min_vdisktime);
+}
+#else /* DEBUG_ELV_FAIR_QUEUING */
+static inline void debug_entity_vdisktime(struct io_entity *entity,
+					unsigned long served, u64 delta) {}
+#endif /* DEBUG_ELV_FAIR_QUEUING */
+
 static void
 entity_served(struct io_entity *entity, unsigned long served,
 				unsigned long nr_sectors)
 {
 	for_each_entity(entity) {
-		entity->vdisktime += elv_delta_fair(served, entity);
+		u64 delta;
+
+		delta = elv_delta_fair(served, entity);
+		entity->vdisktime += delta;
 		update_min_vdisktime(entity->st);
 		entity->total_time += served;
 		entity->total_sectors += nr_sectors;
+		debug_entity_vdisktime(entity, served, delta);
 	}
 }
 
@@ -391,6 +433,9 @@ static void place_entity(struct io_service_tree *st, struct io_entity *entity,
 		vdisktime = st->min_vdisktime;
 
 	entity->vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
+	elv_log_entity(entity, "place_entity: vdisktime=%llu"
+			" min_vdisktime=%llu", entity->vdisktime,
+			st->min_vdisktime);
 }
 
 static inline void io_entity_update_prio(struct io_entity *entity)
-- 
1.6.0.6
