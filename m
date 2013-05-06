From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/33] blkcg: invoke blkcg_policy->pd_init() after parent is
	linked
Date: Mon,  6 May 2013 15:45:43 -0700
Message-ID: <1367880372-28312-5-git-send-email-tj@kernel.org>
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

Currently, when creating a new blkcg_gq, each policy's pd_init_fn() is
invoked in blkg_alloc() before the parent is linked.  This makes it
difficult for policies to perform initializations which are dependent
on the parent.

This patch moves pd_init_fn() invocations to blkg_create() after the
parent blkg is linked where the new blkg is fully initialized.  As
this means that blkg_free() can't assume that pd's are initialized,
pd_exit_fn() invocations are moved to __blkg_release().  This
guarantees that pd_exit_fn() is also invoked with fully initialized
blkgs with valid parent pointers.

This will help implementing hierarchy support in blk-throttle.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 6b10d5c..f13cf95 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -51,18 +51,8 @@ static void blkg_free(struct blkcg_gq *blkg)
 	if (!blkg)
 		return;
 
-	for (i = 0; i < BLKCG_MAX_POLS; i++) {
-		struct blkcg_policy *pol = blkcg_policy[i];
-		struct blkg_policy_data *pd = blkg->pd[i];
-
-		if (!pd)
-			continue;
-
-		if (pol && pol->pd_exit_fn)
-			pol->pd_exit_fn(blkg);
-
-		kfree(pd);
-	}
+	for (i = 0; i < BLKCG_MAX_POLS; i++)
+		kfree(blkg->pd[i]);
 
 	blk_exit_rl(&blkg->rl);
 	kfree(blkg);
@@ -114,10 +104,6 @@ static struct blkcg_gq *blkg_alloc(struct blkcg *blkcg, struct request_queue *q,
 		blkg->pd[i] = pd;
 		pd->blkg = blkg;
 		pd->plid = i;
-
-		/* invoke per-policy init */
-		if (pol->pd_init_fn)
-			pol->pd_init_fn(blkg);
 	}
 
 	return blkg;
@@ -214,7 +200,7 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	}
 	blkg = new_blkg;
 
-	/* link parent and insert */
+	/* link parent */
 	if (blkcg_parent(blkcg)) {
 		blkg->parent = __blkg_lookup(blkcg_parent(blkcg), q, false);
 		if (WARN_ON_ONCE(!blkg->parent)) {
@@ -224,6 +210,15 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 		blkg_get(blkg->parent);
 	}
 
+	/* invoke per-policy init */
+	for (i = 0; i < BLKCG_MAX_POLS; i++) {
+		struct blkcg_policy *pol = blkcg_policy[i];
+
+		if (blkg->pd[i] && pol->pd_init_fn)
+			pol->pd_init_fn(blkg);
+	}
+
+	/* insert */
 	spin_lock(&blkcg->lock);
 	ret = radix_tree_insert(&blkcg->blkg_tree, q->id, blkg);
 	if (likely(!ret)) {
@@ -381,6 +376,16 @@ static void blkg_rcu_free(struct rcu_head *rcu_head)
 
 void __blkg_release(struct blkcg_gq *blkg)
 {
+	int i;
+
+	/* tell policies that this one is being freed */
+	for (i = 0; i < BLKCG_MAX_POLS; i++) {
+		struct blkcg_policy *pol = blkcg_policy[i];
+
+		if (blkg->pd[i] && pol->pd_exit_fn)
+			pol->pd_exit_fn(blkg);
+	}
+
 	/* release the blkcg and parent blkg refs this blkg has been holding */
 	css_put(&blkg->blkcg->css);
 	if (blkg->parent)
-- 
1.8.1.4
