From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 16/24] blkcg: add blkg_policy_data->plid
Date: Fri, 28 Dec 2012 12:35:38 -0800
Message-ID: <1356726946-26037-17-git-send-email-tj__41841.1352475688$1356727505$gmane$org@kernel.org>
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

Add pd->plid so that the policy a pd belongs to can be identified
easily.  This will be used to implement hierarchical blkg_[rw]stats.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 2 ++
 block/blk-cgroup.h | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 10e1df9..3a8de32 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -113,6 +113,7 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q,
 
 		blkg->pd[i] = pd;
 		pd->blkg = blkg;
+		pd->plid = i;
 
 		/* invoke per-policy init */
 		if (pol->pd_init_fn)
@@ -908,6 +909,7 @@ int blkcg_activate_policy(struct request_queue *q,
 
 		blkg->pd[pol->plid] = pd;
 		pd->blkg = blkg;
+		pd->plid = pol->plid;
 		pol->pd_init_fn(blkg);
 
 		spin_unlock(&blkg->blkcg->lock);
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 2446225..40f5b97 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -81,8 +81,9 @@ struct blkg_rwstat {
  * beginning and pd_size can't be smaller than pd.
  */
 struct blkg_policy_data {
-	/* the blkg this per-policy data belongs to */
+	/* the blkg and policy id this per-policy data belongs to */
 	struct blkcg_gq			*blkg;
+	int				plid;
 
 	/* used during policy activation */
 	struct list_head		alloc_node;
-- 
1.8.0.2
