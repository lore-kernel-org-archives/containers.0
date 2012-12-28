From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 18/24] blkcg: s/blkg_rwstat_sum()/blkg_rwstat_total()/
Date: Fri, 28 Dec 2012 12:35:40 -0800
Message-ID: <1356726946-26037-19-git-send-email-tj@kernel.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1356726946-26037-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Rename blkg_rwstat_sum() to blkg_rwstat_total().  sum will be used for
summing up stats from multiple blkgs.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.h  | 4 ++--
 block/cfq-iosched.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 678e89e..586c0ac 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -461,14 +461,14 @@ static inline struct blkg_rwstat blkg_rwstat_read(struct blkg_rwstat *rwstat)
 }
 
 /**
- * blkg_rwstat_sum - read the total count of a blkg_rwstat
+ * blkg_rwstat_total - read the total count of a blkg_rwstat
  * @rwstat: blkg_rwstat to read
  *
  * Return the total count of @rwstat regardless of the IO direction.  This
  * function can be called without synchronization and takes care of u64
  * atomicity.
  */
-static inline uint64_t blkg_rwstat_sum(struct blkg_rwstat *rwstat)
+static inline uint64_t blkg_rwstat_total(struct blkg_rwstat *rwstat)
 {
 	struct blkg_rwstat tmp = blkg_rwstat_read(rwstat);
 
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index e8f3106..d43145cc 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -536,7 +536,7 @@ static void cfqg_stats_set_start_empty_time(struct cfq_group *cfqg)
 {
 	struct cfqg_stats *stats = &cfqg->stats;
 
-	if (blkg_rwstat_sum(&stats->queued))
+	if (blkg_rwstat_total(&stats->queued))
 		return;
 
 	/*
@@ -580,7 +580,7 @@ static void cfqg_stats_update_avg_queue_size(struct cfq_group *cfqg)
 	struct cfqg_stats *stats = &cfqg->stats;
 
 	blkg_stat_add(&stats->avg_queue_size_sum,
-		      blkg_rwstat_sum(&stats->queued));
+		      blkg_rwstat_total(&stats->queued));
 	blkg_stat_add(&stats->avg_queue_size_samples, 1);
 	cfqg_stats_update_group_wait_time(stats);
 }
-- 
1.8.0.2
