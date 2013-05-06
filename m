From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 32/33] blk-throttle: implement throtl_grp->has_rules[]
Date: Mon,  6 May 2013 15:46:11 -0700
Message-ID: <1367880372-28312-33-git-send-email-tj__29604.5613628396$1367880774$gmane$org@kernel.org>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1367880372-28312-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

blk_throtl_bio() has a quick exit path for throtl_grps without limits
configured.  It looks at the bps and iops limits and if both are not
configured, the bio is issued immediately.  While this is correct in
the current flat hierarchy as each throtl_grp behaves completely
independently, it would become wrong in proper hierarchy mode.  A
group without any limits could still be limited by one of its
ancestors and bio's queued for such group should not bypass
blk-throtl.

As having a quick bypass mechanism is beneficial, this patch
reimplements the mechanism such that it's correct even with proper
hierarchy.  throtl_grp->has_rules[] is added.  These booleans are
updated for the whole subtree whenever a config is updated so that
has_rules[] of the whole subtree stays synchronized.  They're also
updated when a new throtl_grp comes online so that it can't escape the
limits of its ancestors.

As no throtl_grp has another throtl_grp as parent now, this patch
doesn't yet make any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c | 49 ++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 42 insertions(+), 7 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 7477f33..27f006b 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -124,6 +124,9 @@ struct throtl_grp {
 
 	unsigned int flags;
 
+	/* are there any throtl rules between this group and td? */
+	bool has_rules[2];
+
 	/* bytes per second rate limits */
 	uint64_t bps[2];
 
@@ -422,6 +425,30 @@ static void throtl_pd_init(struct blkcg_gq *blkg)
 	spin_unlock_irqrestore(&tg_stats_alloc_lock, flags);
 }
 
+/*
+ * Set has_rules[] if @tg or any of its parents have limits configured.
+ * This doesn't require walking up to the top of the hierarchy as the
+ * parent's has_rules[] is guaranteed to be correct.
+ */
+static void tg_update_has_rules(struct throtl_grp *tg)
+{
+	struct throtl_grp *parent_tg = sq_to_tg(tg->service_queue.parent_sq);
+	int rw;
+
+	for (rw = READ; rw <= WRITE; rw++)
+		tg->has_rules[rw] = (parent_tg && parent_tg->has_rules[rw]) ||
+				    (tg->bps[rw] != -1 || tg->iops[rw] != -1);
+}
+
+static void throtl_pd_online(struct blkcg_gq *blkg)
+{
+	/*
+	 * We don't want new groups to escape the limits of its ancestors.
+	 * Update has_rules[] after a new group is brought online.
+	 */
+	tg_update_has_rules(blkg_to_tg(blkg));
+}
+
 static void throtl_pd_exit(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
@@ -843,12 +870,6 @@ static bool tg_with_in_bps_limit(struct throtl_grp *tg, struct bio *bio,
 	return 0;
 }
 
-static bool tg_no_rule_group(struct throtl_grp *tg, bool rw) {
-	if (tg->bps[rw] == -1 && tg->iops[rw] == -1)
-		return 1;
-	return 0;
-}
-
 /*
  * Returns whether one can dispatch a bio or not. Also returns approx number
  * of jiffies to wait before this bio is with-in IO rate and can be dispatched
@@ -1307,6 +1328,8 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 	struct blkg_conf_ctx ctx;
 	struct throtl_grp *tg;
 	struct throtl_service_queue *sq;
+	struct blkcg_gq *blkg;
+	struct cgroup *pos_cgrp;
 	int ret;
 
 	ret = blkg_conf_prep(blkcg, &blkcg_policy_throtl, buf, &ctx);
@@ -1330,6 +1353,17 @@ static int tg_set_conf(struct cgroup *cgrp, struct cftype *cft, const char *buf,
 		   tg->iops[READ], tg->iops[WRITE]);
 
 	/*
+	 * Update has_rules[] flags for the updated tg's subtree.  A tg is
+	 * considered to have rules if either the tg itself or any of its
+	 * ancestors has rules.  This identifies groups without any
+	 * restrictions in the whole hierarchy and allows them to bypass
+	 * blk-throttle.
+	 */
+	tg_update_has_rules(tg);
+	blkg_for_each_descendant_pre(blkg, pos_cgrp, ctx.blkg)
+		tg_update_has_rules(blkg_to_tg(blkg));
+
+	/*
 	 * We're already holding queue_lock and know @tg is valid.  Let's
 	 * apply the new config directly.
 	 *
@@ -1415,6 +1449,7 @@ static struct blkcg_policy blkcg_policy_throtl = {
 	.cftypes		= throtl_files,
 
 	.pd_init_fn		= throtl_pd_init,
+	.pd_online_fn		= throtl_pd_online,
 	.pd_exit_fn		= throtl_pd_exit,
 	.pd_reset_stats_fn	= throtl_pd_reset_stats,
 };
@@ -1442,7 +1477,7 @@ bool blk_throtl_bio(struct request_queue *q, struct bio *bio)
 	blkcg = bio_blkcg(bio);
 	tg = throtl_lookup_tg(td, blkcg);
 	if (tg) {
-		if (tg_no_rule_group(tg, rw)) {
+		if (!tg->has_rules[rw]) {
 			throtl_update_dispatch_stats(tg_to_blkg(tg),
 						     bio->bi_size, bio->bi_rw);
 			goto out_unlock_rcu;
-- 
1.8.1.4
