From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/21] blkcg: BLKIO_STAT_CPU_SECTORS doesn't have subcounters
Date: Wed, 28 Mar 2012 15:51:12 -0700
Message-ID: <1332975091-10950-3-git-send-email-tj@kernel.org>
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

BLKIO_STAT_CPU_SECTORS doesn't need read/write/sync/async subcounters
and is counted by blkio_group_stats_cpu->sectors; however, it still
holds a member in blkio_group_stats_cpu->stat_arr_cpu.

Rearrange stat_type_cpu and define BLKIO_STAT_CPU_ARR_NR and use it
for stat_arr_cpu[] size so that only SERVICE_BYTES and SERVICED have
subcounters.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 1add3dc..2060d81 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -58,14 +58,17 @@ enum stat_type {
 
 /* Per cpu stats */
 enum stat_type_cpu {
-	BLKIO_STAT_CPU_SECTORS,
 	/* Total bytes transferred */
 	BLKIO_STAT_CPU_SERVICE_BYTES,
 	/* Total IOs serviced, post merge */
 	BLKIO_STAT_CPU_SERVICED,
-	BLKIO_STAT_CPU_NR
+
+	/* All the single valued stats go below this */
+	BLKIO_STAT_CPU_SECTORS,
 };
 
+#define BLKIO_STAT_CPU_ARR_NR	(BLKIO_STAT_CPU_SERVICED + 1)
+
 enum stat_sub_type {
 	BLKIO_STAT_READ = 0,
 	BLKIO_STAT_WRITE,
@@ -167,7 +170,7 @@ struct blkio_group_stats {
 /* Per cpu blkio group stats */
 struct blkio_group_stats_cpu {
 	uint64_t sectors;
-	uint64_t stat_arr_cpu[BLKIO_STAT_CPU_NR][BLKIO_STAT_TOTAL];
+	uint64_t stat_arr_cpu[BLKIO_STAT_CPU_ARR_NR][BLKIO_STAT_TOTAL];
 	struct u64_stats_sync syncp;
 };
 
-- 
1.7.7.3
