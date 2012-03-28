From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/21] cfq: collapse cfq.h into cfq-iosched.c
Date: Wed, 28 Mar 2012 15:51:22 -0700
Message-ID: <1332975091-10950-13-git-send-email-tj@kernel.org>
References: <1332975091-10950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332975091-10950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

block/cfq.h contains some functions which interact with blkcg;
however, this is only part of it and cfq-iosched.c already has quite
some #ifdef CONFIG_CFQ_GROUP_IOSCHED.  With conf/stat handling being
moved to specific policies, having these relay functions isolated in
cfq.h doesn't make much sense.  Collapse cfq.h into cfq-iosched.c for
now.  Let's split blkcg support properly later if necessary.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/cfq-iosched.c |  114 ++++++++++++++++++++++++++++++++++++++++++++++++-
 block/cfq.h         |  118 ---------------------------------------------------
 2 files changed, 113 insertions(+), 119 deletions(-)
 delete mode 100644 block/cfq.h

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 119e061..2e13e9e 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -15,7 +15,6 @@
 #include <linux/ioprio.h>
 #include <linux/blktrace_api.h>
 #include "blk.h"
-#include "cfq.h"
 
 static struct blkio_policy_type blkio_policy_cfq;
 
@@ -367,6 +366,9 @@ CFQ_CFQQ_FNS(wait_busy);
 #undef CFQ_CFQQ_FNS
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
+
+#include "blk-cgroup.h"
+
 static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg)
 {
 	return blkg_to_pdata(blkg, &blkio_policy_cfq);
@@ -396,6 +398,82 @@ static inline void cfqg_put(struct cfq_group *cfqg)
 	blk_add_trace_msg((cfqd)->queue, "%s " fmt,			\
 			blkg_path(cfqg_to_blkg((cfqg))), ##args)	\
 
+static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol,
+			struct blkio_group *curr_blkg,
+			bool direction, bool sync)
+{
+	blkiocg_update_io_add_stats(blkg, pol, curr_blkg, direction, sync);
+}
+
+static inline void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, unsigned long dequeue)
+{
+	blkiocg_update_dequeue_stats(blkg, pol, dequeue);
+}
+
+static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, unsigned long time,
+			unsigned long unaccounted_time)
+{
+	blkiocg_update_timeslice_used(blkg, pol, time, unaccounted_time);
+}
+
+static inline void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
+			struct blkio_policy_type *pol)
+{
+	blkiocg_set_start_empty_time(blkg, pol);
+}
+
+static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, bool direction,
+			bool sync)
+{
+	blkiocg_update_io_remove_stats(blkg, pol, direction, sync);
+}
+
+static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, bool direction,
+			bool sync)
+{
+	blkiocg_update_io_merged_stats(blkg, pol, direction, sync);
+}
+
+static inline void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol)
+{
+	blkiocg_update_idle_time_stats(blkg, pol);
+}
+
+static inline void
+cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol)
+{
+	blkiocg_update_avg_queue_size_stats(blkg, pol);
+}
+
+static inline void
+cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol)
+{
+	blkiocg_update_set_idle_time_stats(blkg, pol);
+}
+
+static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, uint64_t bytes,
+			bool direction, bool sync)
+{
+	blkiocg_update_dispatch_stats(blkg, pol, bytes, direction, sync);
+}
+
+static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, uint64_t start_time,
+			uint64_t io_start_time, bool direction, bool sync)
+{
+	blkiocg_update_completion_stats(blkg, pol, start_time, io_start_time,
+					direction, sync);
+}
+
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
 
 static inline struct cfq_group *blkg_to_cfqg(struct blkio_group *blkg) { return NULL; }
@@ -407,6 +485,40 @@ static inline void cfqg_put(struct cfq_group *cfqg) { }
 	blk_add_trace_msg((cfqd)->queue, "cfq%d " fmt, (cfqq)->pid, ##args)
 #define cfq_log_cfqg(cfqd, cfqg, fmt, args...)		do {} while (0)
 
+static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol,
+			struct blkio_group *curr_blkg, bool direction,
+			bool sync) { }
+static inline void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, unsigned long dequeue) { }
+static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, unsigned long time,
+			unsigned long unaccounted_time) { }
+static inline void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
+			struct blkio_policy_type *pol) { }
+static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, bool direction,
+			bool sync) { }
+static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, bool direction,
+			bool sync) { }
+static inline void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol) { }
+static inline void
+cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
+					struct blkio_policy_type *pol) { }
+
+static inline void
+cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
+				       struct blkio_policy_type *pol) { }
+
+static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, uint64_t bytes,
+			bool direction, bool sync) { }
+static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
+			struct blkio_policy_type *pol, uint64_t start_time,
+			uint64_t io_start_time, bool direction, bool sync) { }
+
 #endif	/* CONFIG_CFQ_GROUP_IOSCHED */
 
 #define cfq_log(cfqd, fmt, args...)	\
diff --git a/block/cfq.h b/block/cfq.h
deleted file mode 100644
index c8b15ef..0000000
--- a/block/cfq.h
+++ /dev/null
@@ -1,118 +0,0 @@
-#ifndef _CFQ_H
-#define _CFQ_H
-#include "blk-cgroup.h"
-
-#ifdef CONFIG_CFQ_GROUP_IOSCHED
-static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol,
-			struct blkio_group *curr_blkg,
-			bool direction, bool sync)
-{
-	blkiocg_update_io_add_stats(blkg, pol, curr_blkg, direction, sync);
-}
-
-static inline void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long dequeue)
-{
-	blkiocg_update_dequeue_stats(blkg, pol, dequeue);
-}
-
-static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long time,
-			unsigned long unaccounted_time)
-{
-	blkiocg_update_timeslice_used(blkg, pol, time, unaccounted_time);
-}
-
-static inline void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_set_start_empty_time(blkg, pol);
-}
-
-static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync)
-{
-	blkiocg_update_io_remove_stats(blkg, pol, direction, sync);
-}
-
-static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync)
-{
-	blkiocg_update_io_merged_stats(blkg, pol, direction, sync);
-}
-
-static inline void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_update_idle_time_stats(blkg, pol);
-}
-
-static inline void
-cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_update_avg_queue_size_stats(blkg, pol);
-}
-
-static inline void
-cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol)
-{
-	blkiocg_update_set_idle_time_stats(blkg, pol);
-}
-
-static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t bytes,
-			bool direction, bool sync)
-{
-	blkiocg_update_dispatch_stats(blkg, pol, bytes, direction, sync);
-}
-
-static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t start_time,
-			uint64_t io_start_time, bool direction, bool sync)
-{
-	blkiocg_update_completion_stats(blkg, pol, start_time, io_start_time,
-					direction, sync);
-}
-
-#else /* CFQ_GROUP_IOSCHED */
-static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol,
-			struct blkio_group *curr_blkg, bool direction,
-			bool sync) { }
-static inline void cfq_blkiocg_update_dequeue_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long dequeue) { }
-static inline void cfq_blkiocg_update_timeslice_used(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, unsigned long time,
-			unsigned long unaccounted_time) { }
-static inline void cfq_blkiocg_set_start_empty_time(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-static inline void cfq_blkiocg_update_io_remove_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync) { }
-static inline void cfq_blkiocg_update_io_merged_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, bool direction,
-			bool sync) { }
-static inline void cfq_blkiocg_update_idle_time_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol) { }
-static inline void
-cfq_blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg,
-					struct blkio_policy_type *pol) { }
-
-static inline void
-cfq_blkiocg_update_set_idle_time_stats(struct blkio_group *blkg,
-				       struct blkio_policy_type *pol) { }
-
-static inline void cfq_blkiocg_update_dispatch_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t bytes,
-			bool direction, bool sync) { }
-static inline void cfq_blkiocg_update_completion_stats(struct blkio_group *blkg,
-			struct blkio_policy_type *pol, uint64_t start_time,
-			uint64_t io_start_time, bool direction, bool sync) { }
-
-#endif /* CFQ_GROUP_IOSCHED */
-#endif
-- 
1.7.7.3
