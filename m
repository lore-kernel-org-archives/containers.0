From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/11] blkcg: __blkg_lookup_create() doesn't have to fail on
	radix tree preload failure
Date: Thu, 26 Apr 2012 14:59:12 -0700
Message-ID: <1335477561-11131-3-git-send-email-tj@kernel.org>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1335477561-11131-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

__blkg_lookup_create() currently fails if radix_tree_preload() fails;
however, preload failrue doesn't imply insertion failure.  Don't fail
__blkg_lookup_create() on preload failure.

While at it, drop sparse locking annotation which no longer applies.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 4ab7420..197fb50 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -177,9 +177,9 @@ EXPORT_SYMBOL_GPL(blkg_lookup);
 
 static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 					     struct request_queue *q)
-	__releases(q->queue_lock) __acquires(q->queue_lock)
 {
 	struct blkcg_gq *blkg;
+	bool preloaded;
 	int ret;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
@@ -203,9 +203,7 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 		goto err_put;
 
 	/* insert */
-	ret = radix_tree_preload(GFP_ATOMIC);
-	if (ret)
-		goto err_free;
+	preloaded = !radix_tree_preload(GFP_ATOMIC);
 
 	spin_lock(&blkcg->lock);
 	ret = radix_tree_insert(&blkcg->blkg_tree, q->id, blkg);
@@ -215,14 +213,13 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 	}
 	spin_unlock(&blkcg->lock);
 
-	radix_tree_preload_end();
-
+	if (preloaded)
+		radix_tree_preload_end();
 	if (!ret)
 		return blkg;
-err_free:
-	blkg_free(blkg);
 err_put:
 	css_put(&blkcg->css);
+	blkg_free(blkg);
 	return ERR_PTR(ret);
 }
 
-- 
1.7.7.3
