From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 6/6] blkcg: collapse blkcg_policy_ops into blkcg_policy
Date: Mon, 16 Apr 2012 13:57:27 -0700
Message-ID: <1334609847-12747-7-git-send-email-tj__20953.9486481392$1334609902$gmane$org@kernel.org>
References: <1334609847-12747-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334609847-12747-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

There's no reason to keep blkcg_policy_ops separate.  Collapse it into
blkcg_policy.

This patch doesn't introduce any functional change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c   |   16 ++++++++--------
 block/blk-cgroup.h   |   12 +++++-------
 block/blk-throttle.c |   13 ++++++-------
 block/cfq-iosched.c  |   11 +++++------
 4 files changed, 24 insertions(+), 28 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 3d49552..8228385 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -78,8 +78,8 @@ static void blkg_free(struct blkcg_gq *blkg)
 		if (!pd)
 			continue;
 
-		if (pol && pol->ops.pd_exit_fn)
-			pol->ops.pd_exit_fn(blkg);
+		if (pol && pol->pd_exit_fn)
+			pol->pd_exit_fn(blkg);
 
 		kfree(pd);
 	}
@@ -132,7 +132,7 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q)
 		struct blkcg_policy *pol = blkcg_policy[i];
 
 		if (blkcg_policy_enabled(blkg->q, pol))
-			pol->ops.pd_init_fn(blkg);
+			pol->pd_init_fn(blkg);
 	}
 
 	return blkg;
@@ -305,8 +305,8 @@ static int blkcg_reset_stats(struct cgroup *cgroup, struct cftype *cftype,
 			struct blkcg_policy *pol = blkcg_policy[i];
 
 			if (blkcg_policy_enabled(blkg->q, pol) &&
-			    pol->ops.pd_reset_stats_fn)
-				pol->ops.pd_reset_stats_fn(blkg);
+			    pol->pd_reset_stats_fn)
+				pol->pd_reset_stats_fn(blkg);
 		}
 	}
 
@@ -758,7 +758,7 @@ int blkcg_activate_policy(struct request_queue *q,
 
 		blkg->pd[pol->plid] = pd;
 		pd->blkg = blkg;
-		pol->ops.pd_init_fn(blkg);
+		pol->pd_init_fn(blkg);
 
 		spin_unlock(&blkg->blkcg->lock);
 	}
@@ -804,8 +804,8 @@ void blkcg_deactivate_policy(struct request_queue *q,
 		/* grab blkcg lock too while removing @pd from @blkg */
 		spin_lock(&blkg->blkcg->lock);
 
-		if (pol->ops.pd_exit_fn)
-			pol->ops.pd_exit_fn(blkg);
+		if (pol->pd_exit_fn)
+			pol->pd_exit_fn(blkg);
 
 		kfree(blkg->pd[pol->plid]);
 		blkg->pd[pol->plid] = NULL;
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 18b021e..44cb908 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -99,19 +99,17 @@ typedef void (blkcg_pol_init_pd_fn)(struct blkcg_gq *blkg);
 typedef void (blkcg_pol_exit_pd_fn)(struct blkcg_gq *blkg);
 typedef void (blkcg_pol_reset_pd_stats_fn)(struct blkcg_gq *blkg);
 
-struct blkcg_policy_ops {
-	blkcg_pol_init_pd_fn		*pd_init_fn;
-	blkcg_pol_exit_pd_fn		*pd_exit_fn;
-	blkcg_pol_reset_pd_stats_fn	*pd_reset_stats_fn;
-};
-
 struct blkcg_policy {
-	struct blkcg_policy_ops		ops;
 	int				plid;
 	/* policy specific private data size */
 	size_t				pd_size;
 	/* cgroup files for the policy */
 	struct cftype			*cftypes;
+
+	/* operations */
+	blkcg_pol_init_pd_fn		*pd_init_fn;
+	blkcg_pol_exit_pd_fn		*pd_exit_fn;
+	blkcg_pol_reset_pd_stats_fn	*pd_reset_stats_fn;
 };
 
 extern struct blkcg blkcg_root;
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 6a0a17a..46310ec 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1100,13 +1100,12 @@ static void throtl_shutdown_wq(struct request_queue *q)
 }
 
 static struct blkcg_policy blkcg_policy_throtl = {
-	.ops = {
-		.pd_init_fn		= throtl_pd_init,
-		.pd_exit_fn		= throtl_pd_exit,
-		.pd_reset_stats_fn	= throtl_pd_reset_stats,
-	},
-	.pd_size = sizeof(struct throtl_grp),
-	.cftypes = throtl_files,
+	.pd_size		= sizeof(struct throtl_grp),
+	.cftypes		= throtl_files,
+
+	.pd_init_fn		= throtl_pd_init,
+	.pd_exit_fn		= throtl_pd_exit,
+	.pd_reset_stats_fn	= throtl_pd_reset_stats,
 };
 
 bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 7865cc3..832b2ac 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -4165,12 +4165,11 @@ static struct elevator_type iosched_cfq = {
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
 static struct blkcg_policy blkcg_policy_cfq = {
-	.ops = {
-		.pd_init_fn		= cfq_pd_init,
-		.pd_reset_stats_fn	= cfq_pd_reset_stats,
-	},
-	.pd_size = sizeof(struct cfq_group),
-	.cftypes = cfq_blkcg_files,
+	.pd_size		= sizeof(struct cfq_group),
+	.cftypes		= cfq_blkcg_files,
+
+	.pd_init_fn		= cfq_pd_init,
+	.pd_reset_stats_fn	= cfq_pd_reset_stats,
 };
 #endif
 
-- 
1.7.7.3
