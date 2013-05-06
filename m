From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 33/33] blk-throttle: implement proper hierarchy support
Date: Mon,  6 May 2013 15:46:12 -0700
Message-ID: <1367880372-28312-34-git-send-email-tj__46629.8579391607$1367880778$gmane$org@kernel.org>
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

With the recent updates, blk-throttle is finally ready for proper
hierarchy support.  Dispatching now honors service_queue->parent_sq
and propagates correctly.  The only thing missing is setting
->parent_sq correctly so that throtl_grp hierarchy matches the cgroup
hierarchy.

This patch updates throtl_pd_init() such that service_queues form the
same hierarchy as the cgroup hierarchy if sane_behavior is enabled.
As this concludes proper hierarchy support for blkcg, the shameful
.broken_hierarchy tag is removed from blkio_subsys.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c     |  8 --------
 block/blk-throttle.c   | 22 +++++++++++++++++++++-
 include/linux/cgroup.h |  2 ++
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index af2ca27..8d9edc8 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -911,14 +911,6 @@ struct cgroup_subsys blkio_subsys = {
 	.subsys_id = blkio_subsys_id,
 	.base_cftypes = blkcg_files,
 	.module = THIS_MODULE,
-
-	/*
-	 * blkio subsystem is utterly broken in terms of hierarchy support.
-	 * It treats all cgroups equally regardless of where they're
-	 * located in the hierarchy - all cgroups are treated as if they're
-	 * right below the root.  Fix it and remove the following.
-	 */
-	.broken_hierarchy = true,
 };
 EXPORT_SYMBOL_GPL(blkio_subsys);
 
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 27f006b..08a32df 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -397,10 +397,30 @@ static void throtl_pd_init(struct blkcg_gq *blkg)
 {
 	struct throtl_grp *tg = blkg_to_tg(blkg);
 	struct throtl_data *td = blkg->q->td;
+	struct throtl_service_queue *parent_sq;
 	unsigned long flags;
 	int rw;
 
-	throtl_service_queue_init(&tg->service_queue, &td->service_queue);
+	/*
+	 * If sane_hierarchy is enabled, we switch to properly hierarchical
+	 * behavior where limits on a given throtl_grp are applied to the
+	 * whole subtree rather than just the group itself.  e.g. If 16M
+	 * read_bps limit is set on the root group, the whole system can't
+	 * exceed 16M for the device.
+	 *
+	 * If sane_hierarchy is not enabled, the broken flat hierarchy
+	 * behavior is retained where all throtl_grps are treated as if
+	 * they're all separate root groups right below throtl_data.
+	 * Limits of a group don't interact with limits of other groups
+	 * regardless of the position of the group in the hierarchy.
+	 */
+	parent_sq = &td->service_queue;
+
+	if (cgroup_sane_behavior(blkg->blkcg->css.cgroup) && blkg->parent)
+		parent_sq = &blkg_to_tg(blkg->parent)->service_queue;
+
+	throtl_service_queue_init(&tg->service_queue, parent_sq);
+
 	for (rw = READ; rw <= WRITE; rw++) {
 		throtl_qnode_init(&tg->qnode_on_self[rw], tg);
 		throtl_qnode_init(&tg->qnode_on_parent[rw], tg);
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c371888..3c5f780 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -271,6 +271,8 @@ enum {
 	 * - memcg: use_hierarchy is on by default and the cgroup file for
 	 *   the flag is not created.
 	 *
+	 * - blkcg: blk-throttle becomes properly hierarchical.
+	 *
 	 * The followings are planned changes.
 	 *
 	 * - release_agent will be disallowed once replacement notification
-- 
1.8.1.4
