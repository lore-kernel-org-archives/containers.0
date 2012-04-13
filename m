From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 11/11] blkcg: shoot down blkgs if all policies are deactivated
Date: Fri, 13 Apr 2012 13:11:35 -0700
Message-ID: <1334347895-6268-12-git-send-email-tj__15110.7198828415$1334347986$gmane$org@kernel.org>
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

There's no reason to keep blkgs around if no policy is activated for
the queue.  This patch moves queue locking out of blkg_destroy_all()
and call it from blkg_deactivate_policy() on deactivation of the last
policy on the queue.

This change was suggested by Vivek.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 10f0d2f..b1807d4 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -258,7 +258,7 @@ static void blkg_destroy_all(struct request_queue *q)
 {
 	struct blkio_group *blkg, *n;
 
-	spin_lock_irq(q->queue_lock);
+	lockdep_assert_held(q->queue_lock);
 
 	list_for_each_entry_safe(blkg, n, &q->blkg_list, q_node) {
 		struct blkio_cgroup *blkcg = blkg->blkcg;
@@ -267,8 +267,6 @@ static void blkg_destroy_all(struct request_queue *q)
 		blkg_destroy(blkg);
 		spin_unlock(&blkcg->lock);
 	}
-
-	spin_unlock_irq(q->queue_lock);
 }
 
 static void blkg_rcu_free(struct rcu_head *rcu_head)
@@ -646,7 +644,10 @@ void blkcg_drain_queue(struct request_queue *q)
  */
 void blkcg_exit_queue(struct request_queue *q)
 {
+	spin_lock_irq(q->queue_lock);
 	blkg_destroy_all(q);
+	spin_unlock_irq(q->queue_lock);
+
 	blk_throtl_exit(q);
 }
 
@@ -802,6 +803,10 @@ void blkcg_deactivate_policy(struct request_queue *q,
 
 	__clear_bit(pol->plid, q->blkcg_pols);
 
+	/* if no policy is left, no need for blkgs - shoot them down */
+	if (bitmap_empty(q->blkcg_pols, BLKCG_MAX_POLS))
+		blkg_destroy_all(q);
+
 	list_for_each_entry(blkg, &q->blkg_list, q_node) {
 		/* grab blkcg lock too while removing @pd from @blkg */
 		spin_lock(&blkg->blkcg->lock);
-- 
1.7.7.3
