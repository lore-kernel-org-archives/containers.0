From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/33] blkcg: move blkg_for_each_descendant_pre() to
	block/blk-cgroup.h
Date: Mon,  6 May 2013 15:45:41 -0700
Message-ID: <1367880372-28312-3-git-send-email-tj@kernel.org>
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

blk-throttle hierarchy support will make use of it.  Move
blkg_for_each_descendant_pre() from block/blk-cgroup.c to
block/blk-cgroup.h.

signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-cgroup.c | 24 ++----------------------
 block/blk-cgroup.h | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 0ab211a..6b10d5c 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -32,26 +32,6 @@ EXPORT_SYMBOL_GPL(blkcg_root);
 
 static struct blkcg_policy *blkcg_policy[BLKCG_MAX_POLS];
 
-static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
-				      struct request_queue *q, bool update_hint);
-
-/**
- * blkg_for_each_descendant_pre - pre-order walk of a blkg's descendants
- * @d_blkg: loop cursor pointing to the current descendant
- * @pos_cgrp: used for iteration
- * @p_blkg: target blkg to walk descendants of
- *
- * Walk @c_blkg through the descendants of @p_blkg.  Must be used with RCU
- * read locked.  If called under either blkcg or queue lock, the iteration
- * is guaranteed to include all and only online blkgs.  The caller may
- * update @pos_cgrp by calling cgroup_rightmost_descendant() to skip
- * subtree.
- */
-#define blkg_for_each_descendant_pre(d_blkg, pos_cgrp, p_blkg)		\
-	cgroup_for_each_descendant_pre((pos_cgrp), (p_blkg)->blkcg->css.cgroup) \
-		if (((d_blkg) = __blkg_lookup(cgroup_to_blkcg(pos_cgrp), \
-					      (p_blkg)->q, false)))
-
 static bool blkcg_policy_enabled(struct request_queue *q,
 				 const struct blkcg_policy *pol)
 {
@@ -158,8 +138,8 @@ err_free:
  * @q's bypass state.  If @update_hint is %true, the caller should be
  * holding @q->queue_lock and lookup hint is updated on success.
  */
-static struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg,
-				      struct request_queue *q, bool update_hint)
+struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg, struct request_queue *q,
+			       bool update_hint)
 {
 	struct blkcg_gq *blkg;
 
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index 4e595ee..11f5b92 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -282,6 +282,26 @@ static inline void blkg_put(struct blkcg_gq *blkg)
 		__blkg_release(blkg);
 }
 
+struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg, struct request_queue *q,
+			       bool update_hint);
+
+/**
+ * blkg_for_each_descendant_pre - pre-order walk of a blkg's descendants
+ * @d_blkg: loop cursor pointing to the current descendant
+ * @pos_cgrp: used for iteration
+ * @p_blkg: target blkg to walk descendants of
+ *
+ * Walk @c_blkg through the descendants of @p_blkg.  Must be used with RCU
+ * read locked.  If called under either blkcg or queue lock, the iteration
+ * is guaranteed to include all and only online blkgs.  The caller may
+ * update @pos_cgrp by calling cgroup_rightmost_descendant() to skip
+ * subtree.
+ */
+#define blkg_for_each_descendant_pre(d_blkg, pos_cgrp, p_blkg)		\
+	cgroup_for_each_descendant_pre((pos_cgrp), (p_blkg)->blkcg->css.cgroup) \
+		if (((d_blkg) = __blkg_lookup(cgroup_to_blkcg(pos_cgrp), \
+					      (p_blkg)->q, false)))
+
 /**
  * blk_get_rl - get request_list to use
  * @q: request_queue of interest
-- 
1.8.1.4
