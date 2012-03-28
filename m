From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/21] blkcg: drop blkiocg_file_write_u64()
Date: Wed, 28 Mar 2012 15:51:15 -0700
Message-ID: <1332975091-10950-6-git-send-email-tj@kernel.org>
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

blkiocg_file_write_u64() has single switch case.  Drop
blkiocg_file_write_u64(), rename blkio_weight_write() to
blkcg_set_weight() and use it directly for .write_u64 callback.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |   35 +++++++----------------------------
 1 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index f670217..ae539d3 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1207,8 +1207,9 @@ static int blkiocg_file_read(struct cgroup *cgrp, struct cftype *cft,
 	return 0;
 }
 
-static int blkio_weight_write(struct blkio_cgroup *blkcg, int plid, u64 val)
+static int blkcg_set_weight(struct cgroup *cgrp, struct cftype *cft, u64 val)
 {
+	struct blkio_cgroup *blkcg = cgroup_to_blkio_cgroup(cgrp);
 	struct blkio_group *blkg;
 	struct hlist_node *n;
 
@@ -1220,10 +1221,11 @@ static int blkio_weight_write(struct blkio_cgroup *blkcg, int plid, u64 val)
 	blkcg->weight = (unsigned int)val;
 
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
-		struct blkg_policy_data *pd = blkg->pd[plid];
+		struct blkg_policy_data *pd = blkg->pd[BLKIO_POLICY_PROP];
 
-		if (!pd->conf.weight)
-			blkio_update_group_weight(blkg, plid, blkcg->weight);
+		if (pd && !pd->conf.weight)
+			blkio_update_group_weight(blkg, BLKIO_POLICY_PROP,
+						  blkcg->weight);
 	}
 
 	spin_unlock_irq(&blkcg->lock);
@@ -1251,29 +1253,6 @@ static u64 blkiocg_file_read_u64 (struct cgroup *cgrp, struct cftype *cft) {
 	return 0;
 }
 
-static int
-blkiocg_file_write_u64(struct cgroup *cgrp, struct cftype *cft, u64 val)
-{
-	struct blkio_cgroup *blkcg;
-	enum blkio_policy_id plid = BLKIOFILE_POLICY(cft->private);
-	int name = BLKIOFILE_ATTR(cft->private);
-
-	blkcg = cgroup_to_blkio_cgroup(cgrp);
-
-	switch(plid) {
-	case BLKIO_POLICY_PROP:
-		switch(name) {
-		case BLKIO_PROP_weight:
-			return blkio_weight_write(blkcg, plid, val);
-		}
-		break;
-	default:
-		BUG();
-	}
-
-	return 0;
-}
-
 struct cftype blkio_files[] = {
 	{
 		.name = "weight_device",
@@ -1288,7 +1267,7 @@ struct cftype blkio_files[] = {
 		.private = BLKIOFILE_PRIVATE(BLKIO_POLICY_PROP,
 				BLKIO_PROP_weight),
 		.read_u64 = blkiocg_file_read_u64,
-		.write_u64 = blkiocg_file_write_u64,
+		.write_u64 = blkcg_set_weight,
 	},
 	{
 		.name = "time",
-- 
1.7.7.3
