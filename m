From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 28/28] io-controller: debug elevator fair queuing support
Date: Thu, 24 Sep 2009 15:25:32 -0400
Message-ID: <1253820332-10246-29-git-send-email-vgoyal__42297.0379739583$1253824003$gmane$org@redhat.com>
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

o More debugging help to debug elevator fair queuing support. Enabled under
  CONFIG_DEBUG_ELV_FAIR_QUEUING. Currently it prints vdisktime related
  trace messages in blktrace.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
index e69de98..62691c6 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -37,6 +37,24 @@ static int elv_ioq_wait_busy = HZ / 125;
 
 static void check_idle_tree_release(struct io_service_tree *st);
 
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
@@ -435,6 +453,26 @@ static inline void debug_update_stats_enqueue(struct io_entity *entity) {}
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
 static void entity_served(struct io_entity *entity, unsigned long served,
 		unsigned long queue_charge, unsigned long group_charge,
 		unsigned long nr_sectors)
@@ -442,10 +480,14 @@ static void entity_served(struct io_entity *entity, unsigned long served,
 	unsigned long charge = queue_charge;
 
 	for_each_entity(entity) {
-		entity->vdisktime += elv_delta_fair(charge, entity);
+		u64 delta;
+
+		delta = elv_delta_fair(charge, entity);
+		entity->vdisktime += delta;
 		update_min_vdisktime(entity->st);
 		entity->total_time += served;
 		entity->total_sectors += nr_sectors;
+		debug_entity_vdisktime(entity, charge, delta);
 		/* Group charge can be different from queue charge */
 		charge = group_charge;
 	}
@@ -499,6 +541,9 @@ static void place_entity(struct io_service_tree *st, struct io_entity *entity,
 		vdisktime = st->min_vdisktime;
 done:
 	entity->vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
+	elv_log_entity(entity, "place_entity: vdisktime=%llu"
+			" min_vdisktime=%llu", entity->vdisktime,
+			st->min_vdisktime);
 }
 
 static inline void io_entity_update_prio(struct io_entity *entity)
-- 
1.6.0.6
