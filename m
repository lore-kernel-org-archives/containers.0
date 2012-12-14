From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/12] blkcg: make blkcg_gq's hierarchical
Date: Fri, 14 Dec 2012 14:41:17 -0800
Message-ID: <1355524885-22719-5-git-send-email-tj@kernel.org>
References: <1355524885-22719-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355524885-22719-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Currently a child blkg (blkcg_gq) can be created even if its parent
doesn't exist.  ie. Given a blkg, it's not guaranteed that its
ancestors will exist.  This makes it difficult to implement proper
hierarchy support for blkcg policies.

Always create blkgs recursively and make a child blkg hold a reference
to its parent.  blkg->parent is added so that finding the parent is
easy.  blkcg_parent() is also added in the process.

This change can be visible to userland.  e.g. while issuing IO in a
nested cgroup didn't affect the ancestors at all, now it will
initialize all ancestor blkgs and zero stats for the request_queue
will always appear on them.  While this is userland visible, this
shouldn't cause any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 42 +++++++++++++++++++++++++++++++++++++-----
 block/blk-cgroup.h | 18 ++++++++++++++++++
 2 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index fde2286..c858628 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -201,7 +201,16 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	}
 	blkg = new_blkg;
 
-	/* insert */
+	/* link parent and insert */
+	if (blkcg_parent(blkcg)) {
+		blkg->parent = __blkg_lookup(blkcg_parent(blkcg), q, false);
+		if (WARN_ON_ONCE(!blkg->parent)) {
+			blkg = ERR_PTR(-EINVAL);
+			goto err_put_css;
+		}
+		blkg_get(blkg->parent);
+	}
+
 	spin_lock(&blkcg->lock);
 	ret = radix_tree_insert(&blkcg->blkg_tree, q->id, blkg);
 	if (likely(!ret)) {
@@ -213,6 +222,10 @@ static struct blkcg_gq *blkg_create(struct blkcg *blkcg,
 	if (!ret)
 		return blkg;
 
+	/* @blkg failed fully initialized, use the usual release path */
+	blkg_put(blkg);
+	return ERR_PTR(ret);
+
 err_put_css:
 	css_put(&blkcg->css);
 err_free_blkg:
@@ -226,8 +239,9 @@ err_free_blkg:
  * @q: request_queue of interest
  *
  * Lookup blkg for the @blkcg - @q pair.  If it doesn't exist, try to
- * create one.  This function should be called under RCU read lock and
- * @q->queue_lock.
+ * create one.  blkg creation is performed recursively from blkcg_root such
+ * that all non-root blkg's have access to the parent blkg.  This function
+ * should be called under RCU read lock and @q->queue_lock.
  *
  * Returns pointer to the looked up or created blkg on success, ERR_PTR()
  * value on error.  If @q is dead, returns ERR_PTR(-EINVAL).  If @q is not
@@ -252,7 +266,23 @@ struct blkcg_gq *blkg_lookup_create(struct blkcg *blkcg,
 	if (blkg)
 		return blkg;
 
-	return blkg_create(blkcg, q, NULL);
+	/*
+	 * Create blkgs walking down from blkcg_root to @blkcg, so that all
+	 * non-root blkgs have access to their parents.
+	 */
+	while (true) {
+		struct blkcg *pos = blkcg;
+		struct blkcg *parent = blkcg_parent(blkcg);
+
+		while (parent && !__blkg_lookup(parent, q, false)) {
+			pos = parent;
+			parent = blkcg_parent(parent);
+		}
+
+		blkg = blkg_create(pos, q, NULL);
+		if (pos == blkcg || IS_ERR(blkg))
+			return blkg;
+	}
 }
 EXPORT_SYMBOL_GPL(blkg_lookup_create);
 
@@ -321,8 +351,10 @@ static void blkg_rcu_free(struct rcu_head *rcu_head)
 
 void __blkg_release(struct blkcg_gq *blkg)
 {
-	/* release the extra blkcg reference this blkg has been holding */
+	/* release the blkcg and parent blkg refs this blkg has been holding */
 	css_put(&blkg->blkcg->css);
+	if (blkg->parent)
+		blkg_put(blkg->parent);
 
 	/*
 	 * A group is freed in rcu manner. But having an rcu lock does not
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 2459730..b26ed58 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -94,8 +94,13 @@ struct blkcg_gq {
 	struct list_head		q_node;
 	struct hlist_node		blkcg_node;
 	struct blkcg			*blkcg;
+
+	/* all non-root blkcg_gq's are guaranteed to have access to parent */
+	struct blkcg_gq			*parent;
+
 	/* request allocation list for this blkcg-q pair */
 	struct request_list		rl;
+
 	/* reference count */
 	int				refcnt;
 
@@ -181,6 +186,19 @@ static inline struct blkcg *bio_blkcg(struct bio *bio)
 }
 
 /**
+ * blkcg_parent - get the parent of a blkcg
+ * @blkcg: blkcg of interest
+ *
+ * Return the parent blkcg of @blkcg.  Can be called anytime.
+ */
+static inline struct blkcg *blkcg_parent(struct blkcg *blkcg)
+{
+	struct cgroup *pcg = blkcg->css.cgroup->parent;
+
+	return pcg ? cgroup_to_blkcg(pcg) : NULL;
+}
+
+/**
  * blkg_to_pdata - get policy private data
  * @blkg: blkg of interest
  * @pol: policy of interest
-- 
1.7.11.7
