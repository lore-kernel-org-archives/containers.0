From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/4] blkcg: fix blkcg->css ref leak in __blkg_lookup_create()
Date: Thu, 19 Apr 2012 16:29:23 -0700
Message-ID: <1334878164-24788-4-git-send-email-tj@kernel.org>
References: <1334878164-24788-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1334878164-24788-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

__blkg_lookup_create() leaked blkcg->css ref if blkg allocation
failed.  Fix it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 8228385..30a7a9c 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -174,6 +174,7 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
 	struct blkcg_gq *blkg;
+	int ret;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 	lockdep_assert_held(q->queue_lock);
@@ -186,24 +187,22 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 	if (!css_tryget(&blkcg->css))
 		return ERR_PTR(-EINVAL);
 
-	/*
-	 * Allocate and initialize.
-	 */
+	/* allocate */
+	ret = -ENOMEM;
 	blkg = blkg_alloc(blkcg, q);
-
-	/* did alloc fail? */
-	if (unlikely(!blkg)) {
-		blkg = ERR_PTR(-ENOMEM);
-		goto out;
-	}
+	if (unlikely(!blkg))
+		goto err_put;
 
 	/* insert */
 	spin_lock(&blkcg->lock);
 	hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
 	list_add(&blkg->q_node, &q->blkg_list);
 	spin_unlock(&blkcg->lock);
-out:
 	return blkg;
+
+err_put:
+	css_put(&blkcg->css);
+	return ERR_PTR(ret);
 }
 
 struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
-- 
1.7.7.3
