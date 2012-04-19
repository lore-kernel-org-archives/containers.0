From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/4] blkcg: use radix tree to index blkgs from blkcg
Date: Thu, 19 Apr 2012 16:29:24 -0700
Message-ID: <1334878164-24788-5-git-send-email-tj__5990.10367081991$1334878205$gmane$org@kernel.org>
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

blkg lookup is currently performed by traversing linked list anchored
at blkcg->blkg_list.  This is very unscalable and with blk-throttle
enabled and enough request queues on the system, this can get very
ugly quickly (blk-throttle performs look up on every bio submission).

This patch makes blkcg use radix tree to index blkgs combined with
simple last-looked-up hint.  This is mostly identical to how icqs are
indexed from ioc.

Note that because __blkg_lookup() may be invoked without holding queue
lock, hint is only updated from __blkg_lookup_create().  Due to cfq's
cfqq caching, this makes hint updates overly lazy.  This will be
improved with scheduled blkcg aware request allocation.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/blk-cgroup.c |   52 ++++++++++++++++++++++++++++++++++++++++++++--------
 block/blk-cgroup.h |    6 ++++++
 2 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 30a7a9c..02cf633 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -142,11 +142,21 @@ static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
 				      struct request_queue *q)
 {
 	struct blkcg_gq *blkg;
-	struct hlist_node *n;
 
-	hlist_for_each_entry_rcu(blkg, n, &blkcg->blkg_list, blkcg_node)
-		if (blkg->q == q)
-			return blkg;
+	blkg = rcu_dereference(blkcg->blkg_hint);
+	if (blkg && blkg->q == q)
+		return blkg;
+
+	/*
+	 * Hint didn't match.  Look up from the radix tree.  Note that we
+	 * may not be holding queue_lock and thus are not sure whether
+	 * @blkg from blkg_tree has already been removed or not, so we
+	 * can't update hint to the lookup result.  Leave it to the caller.
+	 */
+	blkg = radix_tree_lookup(&blkcg->blkg_tree, q->id);
+	if (blkg && blkg->q == q)
+		return blkg;
+
 	return NULL;
 }
 
@@ -179,9 +189,12 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 	WARN_ON_ONCE(!rcu_read_lock_held());
 	lockdep_assert_held(q->queue_lock);
 
+	/* lookup and update hint on success, see __blkg_lookup() for details */
 	blkg = __blkg_lookup(blkcg, q);
-	if (blkg)
+	if (blkg) {
+		rcu_assign_pointer(blkcg->blkg_hint, blkg);
 		return blkg;
+	}
 
 	/* blkg holds a reference to blkcg */
 	if (!css_tryget(&blkcg->css))
@@ -194,12 +207,24 @@ static struct blkcg_gq *__blkg_lookup_create(struct blkcg *blkcg,
 		goto err_put;
 
 	/* insert */
+	ret = radix_tree_preload(GFP_ATOMIC);
+	if (ret)
+		goto err_free;
+
 	spin_lock(&blkcg->lock);
-	hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
-	list_add(&blkg->q_node, &q->blkg_list);
+	ret = radix_tree_insert(&blkcg->blkg_tree, q->id, blkg);
+	if (likely(!ret)) {
+		hlist_add_head_rcu(&blkg->blkcg_node, &blkcg->blkg_list);
+		list_add(&blkg->q_node, &q->blkg_list);
+	}
 	spin_unlock(&blkcg->lock);
-	return blkg;
 
+	radix_tree_preload_end();
+
+	if (!ret)
+		return blkg;
+err_free:
+	blkg_free(blkg);
 err_put:
 	css_put(&blkcg->css);
 	return ERR_PTR(ret);
@@ -229,10 +254,20 @@ static void blkg_destroy(struct blkcg_gq *blkg)
 	/* Something wrong if we are trying to remove same group twice */
 	WARN_ON_ONCE(list_empty(&blkg->q_node));
 	WARN_ON_ONCE(hlist_unhashed(&blkg->blkcg_node));
+
+	radix_tree_delete(&blkcg->blkg_tree, blkg->q->id);
 	list_del_init(&blkg->q_node);
 	hlist_del_init_rcu(&blkg->blkcg_node);
 
 	/*
+	 * Both setting lookup hint to and clearing it from @blkg are done
+	 * under queue_lock.  If it's not pointing to @blkg now, it never
+	 * will.  Hint assignment itself can race safely.
+	 */
+	if (rcu_dereference_raw(blkcg->blkg_hint) == blkg)
+		rcu_assign_pointer(blkcg->blkg_hint, NULL);
+
+	/*
 	 * Put the reference taken at the time of creation so that when all
 	 * queues are gone, group can be destroyed.
 	 */
@@ -593,6 +628,7 @@ static struct cgroup_subsys_state *blkcg_create(struct cgroup *cgroup)
 	blkcg->id = atomic64_inc_return(&id_seq); /* root is 0, start from 1 */
 done:
 	spin_lock_init(&blkcg->lock);
+	INIT_RADIX_TREE(&blkcg->blkg_tree, GFP_ATOMIC);
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
 
 	return &blkcg->css;
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 44cb908..8ac457c 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/cgroup.h>
 #include <linux/u64_stats_sync.h>
 #include <linux/seq_file.h>
+#include <linux/radix-tree.h>
 
 /* Max limits for throttle policy */
 #define THROTL_IOPS_MAX		UINT_MAX
@@ -37,9 +38,14 @@ enum blkg_rwstat_type {
 	BLKG_RWSTAT_TOTAL = BLKG_RWSTAT_NR,
 };
 
+struct blkcg_gq;
+
 struct blkcg {
 	struct cgroup_subsys_state	css;
 	spinlock_t			lock;
+
+	struct radix_tree_root		blkg_tree;
+	struct blkcg_gq			*blkg_hint;
 	struct hlist_head		blkg_list;
 
 	/* for policies to test whether associated blkcg has changed */
-- 
1.7.7.3
