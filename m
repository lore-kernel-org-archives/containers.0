From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 15/21] blkcg: add blkio_policy_ops operations for exit and
	stat reset
Date: Wed, 28 Mar 2012 15:51:25 -0700
Message-ID: <1332975091-10950-16-git-send-email-tj@kernel.org>
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

Add blkio_policy_ops->blkio_exit_group_fn() and
->blkio_reset_group_stats_fn().  These will be used to further
modularize blkcg policy implementation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |   16 ++++++++++++----
 block/blk-cgroup.h |    4 ++++
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 16158e5..e4848ee 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -131,12 +131,17 @@ static void blkg_free(struct blkio_group *blkg)
 		return;
 
 	for (i = 0; i < BLKIO_NR_POLICIES; i++) {
+		struct blkio_policy_type *pol = blkio_policy[i];
 		struct blkg_policy_data *pd = blkg->pd[i];
 
-		if (pd) {
-			free_percpu(pd->stats_cpu);
-			kfree(pd);
-		}
+		if (!pd)
+			continue;
+
+		if (pol && pol->ops.blkio_exit_group_fn)
+			pol->ops.blkio_exit_group_fn(blkg);
+
+		free_percpu(pd->stats_cpu);
+		kfree(pd);
 	}
 
 	kfree(blkg);
@@ -432,6 +437,9 @@ blkiocg_reset_stats(struct cgroup *cgroup, struct cftype *cftype, u64 val)
 			blkg_stat_reset(&stats->empty_time);
 #endif
 			blkio_reset_stats_cpu(blkg, pol->plid);
+
+			if (pol->ops.blkio_reset_group_stats_fn)
+				pol->ops.blkio_reset_group_stats_fn(blkg);
 		}
 	}
 
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index c82de47..d0ee649 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -153,9 +153,13 @@ struct blkio_group {
 };
 
 typedef void (blkio_init_group_fn)(struct blkio_group *blkg);
+typedef void (blkio_exit_group_fn)(struct blkio_group *blkg);
+typedef void (blkio_reset_group_stats_fn)(struct blkio_group *blkg);
 
 struct blkio_policy_ops {
 	blkio_init_group_fn *blkio_init_group_fn;
+	blkio_exit_group_fn *blkio_exit_group_fn;
+	blkio_reset_group_stats_fn *blkio_reset_group_stats_fn;
 };
 
 struct blkio_policy_type {
-- 
1.7.7.3
