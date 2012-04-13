From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/11] cfq: fix build breakage & warnings
Date: Fri, 13 Apr 2012 13:11:25 -0700
Message-ID: <1334347895-6268-2-git-send-email-tj@kernel.org>
References: <1334347895-6268-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334347895-6268-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

* CFQ_WEIGHT_* defined inside CONFIG_BLK_CGROUP causes cfq-iosched.c
  compile failure when the config is disabled.  Move it outside the
  ifdef block.

* Dummy cfqg_stats_*() definitions were lacking inline modifiers
  causing unused functions warning if !CONFIG_CFQ_GROUP_IOSCHED.  Add
  them.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.h  |    4 ++--
 block/cfq-iosched.c |   17 ++++++++---------
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index ca0ff7c..64392ac 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -27,13 +27,13 @@ enum blkio_policy_id {
 /* Max limits for throttle policy */
 #define THROTL_IOPS_MAX		UINT_MAX
 
-#ifdef CONFIG_BLK_CGROUP
-
 /* CFQ specific, out here for blkcg->cfq_weight */
 #define CFQ_WEIGHT_MIN		10
 #define CFQ_WEIGHT_MAX		1000
 #define CFQ_WEIGHT_DEFAULT	500
 
+#ifdef CONFIG_BLK_CGROUP
+
 enum blkg_rwstat_type {
 	BLKG_RWSTAT_READ,
 	BLKG_RWSTAT_WRITE,
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index cff8b5b..7a8c3e0 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -17,7 +17,7 @@
 #include "blk.h"
 #include "blk-cgroup.h"
 
-static struct blkio_policy_type blkio_policy_cfq;
+static struct blkio_policy_type blkio_policy_cfq __maybe_unused;
 
 /*
  * tunables
@@ -541,14 +541,13 @@ static void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg)
 
 #else	/* CONFIG_CFQ_GROUP_IOSCHED && CONFIG_DEBUG_BLK_CGROUP */
 
-static void cfqg_stats_set_start_group_wait_time(struct cfq_group *cfqg,
-						 struct cfq_group *curr_cfqg) { }
-static void cfqg_stats_end_empty_time(struct cfqg_stats *stats) { }
-static void cfqg_stats_update_dequeue(struct cfq_group *cfqg) { }
-static void cfqg_stats_set_start_empty_time(struct cfq_group *cfqg) { }
-static void cfqg_stats_update_idle_time(struct cfq_group *cfqg) { }
-static void cfqg_stats_set_start_idle_time(struct cfq_group *cfqg) { }
-static void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg) { }
+static inline void cfqg_stats_set_start_group_wait_time(struct cfq_group *cfqg, struct cfq_group *curr_cfqg) { }
+static inline void cfqg_stats_end_empty_time(struct cfqg_stats *stats) { }
+static inline void cfqg_stats_update_dequeue(struct cfq_group *cfqg) { }
+static inline void cfqg_stats_set_start_empty_time(struct cfq_group *cfqg) { }
+static inline void cfqg_stats_update_idle_time(struct cfq_group *cfqg) { }
+static inline void cfqg_stats_set_start_idle_time(struct cfq_group *cfqg) { }
+static inline void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg) { }
 
 #endif	/* CONFIG_CFQ_GROUP_IOSCHED && CONFIG_DEBUG_BLK_CGROUP */
 
-- 
1.7.7.3
