From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 15/23] cgroup: make hierarchy iterators deal with
	cgroup_subsys_state instead of cgroup
Date: Thu,  1 Aug 2013 17:49:53 -0400
Message-ID: <1375393801-4817-16-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup is currently in the process of transitioning to using css
(cgroup_subsys_state) as the primary handle instead of cgroup in
subsystem API.  For hierarchy iterators, this is beneficial because

* In most cases, css is the only thing subsystems care about anyway.

* On the planned unified hierarchy, iterations for different
  subsystems will need to skip over different subtrees of the
  hierarchy depending on which subsystems are enabled on each cgroup.
  Passing around css makes it unnecessary to explicitly specify the
  subsystem in question as css is intersection between cgroup and
  subsystem

* For the planned unified hierarchy, css's would need to be created
  and destroyed dynamically independent from cgroup hierarchy.  Having
  cgroup core manage css iteration makes enforcing deref rules a lot
  easier.

Most subsystem conversions are straight-forward.  Noteworthy changes
are

* blkio: cgroup_to_blkcg() is no longer used.  Removed.

* freezer: cgroup_freezer() is no longer used.  Removed.

* devices: cgroup_to_devcgroup() is no longer used.  Removed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
---
 block/blk-cgroup.c       |   8 +--
 block/blk-cgroup.h       |  25 ++++-----
 block/blk-throttle.c     |   8 +--
 include/linux/cgroup.h   |  88 ++++++++++++++++---------------
 kernel/cgroup.c          | 131 ++++++++++++++++++++++++++---------------------
 kernel/cgroup_freezer.c  |  25 ++++-----
 kernel/cpuset.c          |  58 ++++++++++-----------
 mm/memcontrol.c          |  20 ++++----
 security/device_cgroup.c |  11 ++--
 9 files changed, 187 insertions(+), 187 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index f46f3c6..4b40640 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -614,7 +614,7 @@ u64 blkg_stat_recursive_sum(struct blkg_policy_data *pd, int off)
 {
 	struct blkcg_policy *pol = blkcg_policy[pd->plid];
 	struct blkcg_gq *pos_blkg;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 	u64 sum;
 
 	lockdep_assert_held(pd->blkg->q->queue_lock);
@@ -622,7 +622,7 @@ u64 blkg_stat_recursive_sum(struct blkg_policy_data *pd, int off)
 	sum = blkg_stat_read((void *)pd + off);
 
 	rcu_read_lock();
-	blkg_for_each_descendant_pre(pos_blkg, pos_cgrp, pd_to_blkg(pd)) {
+	blkg_for_each_descendant_pre(pos_blkg, pos_css, pd_to_blkg(pd)) {
 		struct blkg_policy_data *pos_pd = blkg_to_pd(pos_blkg, pol);
 		struct blkg_stat *stat = (void *)pos_pd + off;
 
@@ -649,7 +649,7 @@ struct blkg_rwstat blkg_rwstat_recursive_sum(struct blkg_policy_data *pd,
 {
 	struct blkcg_policy *pol = blkcg_policy[pd->plid];
 	struct blkcg_gq *pos_blkg;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 	struct blkg_rwstat sum;
 	int i;
 
@@ -658,7 +658,7 @@ struct blkg_rwstat blkg_rwstat_recursive_sum(struct blkg_policy_data *pd,
 	sum = blkg_rwstat_read((void *)pd + off);
 
 	rcu_read_lock();
-	blkg_for_each_descendant_pre(pos_blkg, pos_cgrp, pd_to_blkg(pd)) {
+	blkg_for_each_descendant_pre(pos_blkg, pos_css, pd_to_blkg(pd)) {
 		struct blkg_policy_data *pos_pd = blkg_to_pd(pos_blkg, pol);
 		struct blkg_rwstat *rwstat = (void *)pos_pd + off;
 		struct blkg_rwstat tmp;
diff --git a/block/blk-cgroup.h b/block/blk-cgroup.h
index b6802c4..8555386 100644
--- a/block/blk-cgroup.h
+++ b/block/blk-cgroup.h
@@ -184,11 +184,6 @@ static inline struct blkcg *css_to_blkcg(struct cgroup_subsys_state *css)
 	return css ? container_of(css, struct blkcg, css) : NULL;
 }
 
-static inline struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup)
-{
-	return css_to_blkcg(cgroup_css(cgroup, blkio_subsys_id));
-}
-
 static inline struct blkcg *task_blkcg(struct task_struct *tsk)
 {
 	return css_to_blkcg(task_css(tsk, blkio_subsys_id));
@@ -289,32 +284,31 @@ struct blkcg_gq *__blkg_lookup(struct blkcg *blkcg, struct request_queue *q,
 /**
  * blkg_for_each_descendant_pre - pre-order walk of a blkg's descendants
  * @d_blkg: loop cursor pointing to the current descendant
- * @pos_cgrp: used for iteration
+ * @pos_css: used for iteration
  * @p_blkg: target blkg to walk descendants of
  *
  * Walk @c_blkg through the descendants of @p_blkg.  Must be used with RCU
  * read locked.  If called under either blkcg or queue lock, the iteration
  * is guaranteed to include all and only online blkgs.  The caller may
- * update @pos_cgrp by calling cgroup_rightmost_descendant() to skip
- * subtree.
+ * update @pos_css by calling css_rightmost_descendant() to skip subtree.
  */
-#define blkg_for_each_descendant_pre(d_blkg, pos_cgrp, p_blkg)		\
-	cgroup_for_each_descendant_pre((pos_cgrp), (p_blkg)->blkcg->css.cgroup) \
-		if (((d_blkg) = __blkg_lookup(cgroup_to_blkcg(pos_cgrp), \
+#define blkg_for_each_descendant_pre(d_blkg, pos_css, p_blkg)		\
+	css_for_each_descendant_pre((pos_css), &(p_blkg)->blkcg->css)	\
+		if (((d_blkg) = __blkg_lookup(css_to_blkcg(pos_css),	\
 					      (p_blkg)->q, false)))
 
 /**
  * blkg_for_each_descendant_post - post-order walk of a blkg's descendants
  * @d_blkg: loop cursor pointing to the current descendant
- * @pos_cgrp: used for iteration
+ * @pos_css: used for iteration
  * @p_blkg: target blkg to walk descendants of
  *
  * Similar to blkg_for_each_descendant_pre() but performs post-order
  * traversal instead.  Synchronization rules are the same.
  */
-#define blkg_for_each_descendant_post(d_blkg, pos_cgrp, p_blkg)		\
-	cgroup_for_each_descendant_post((pos_cgrp), (p_blkg)->blkcg->css.cgroup) \
-		if (((d_blkg) = __blkg_lookup(cgroup_to_blkcg(pos_cgrp), \
+#define blkg_for_each_descendant_post(d_blkg, pos_css, p_blkg)		\
+	css_for_each_descendant_post((pos_css), &(p_blkg)->blkcg->css)	\
+		if (((d_blkg) = __blkg_lookup(css_to_blkcg(pos_css),	\
 					      (p_blkg)->q, false)))
 
 /**
@@ -577,7 +571,6 @@ static inline int blkcg_activate_policy(struct request_queue *q,
 static inline void blkcg_deactivate_policy(struct request_queue *q,
 					   const struct blkcg_policy *pol) { }
 
-static inline struct blkcg *cgroup_to_blkcg(struct cgroup *cgroup) { return NULL; }
 static inline struct blkcg *bio_blkcg(struct bio *bio) { return NULL; }
 
 static inline struct blkg_policy_data *blkg_to_pd(struct blkcg_gq *blkg,
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 88bcfb6..8cefa7f 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1349,7 +1349,7 @@ static int tg_set_conf(struct cgroup_subsys_state *css, struct cftype *cft,
 	struct throtl_grp *tg;
 	struct throtl_service_queue *sq;
 	struct blkcg_gq *blkg;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 	int ret;
 
 	ret = blkg_conf_prep(blkcg, &blkcg_policy_throtl, buf, &ctx);
@@ -1380,7 +1380,7 @@ static int tg_set_conf(struct cgroup_subsys_state *css, struct cftype *cft,
 	 * blk-throttle.
 	 */
 	tg_update_has_rules(tg);
-	blkg_for_each_descendant_pre(blkg, pos_cgrp, ctx.blkg)
+	blkg_for_each_descendant_pre(blkg, pos_css, ctx.blkg)
 		tg_update_has_rules(blkg_to_tg(blkg));
 
 	/*
@@ -1623,7 +1623,7 @@ void blk_throtl_drain(struct request_queue *q)
 {
 	struct throtl_data *td = q->td;
 	struct blkcg_gq *blkg;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 	struct bio *bio;
 	int rw;
 
@@ -1636,7 +1636,7 @@ void blk_throtl_drain(struct request_queue *q)
 	 * better to walk service_queue tree directly but blkg walk is
 	 * easier.
 	 */
-	blkg_for_each_descendant_post(blkg, pos_cgrp, td->queue->root_blkg)
+	blkg_for_each_descendant_post(blkg, pos_css, td->queue->root_blkg)
 		tg_drain_bios(&blkg_to_tg(blkg)->service_queue);
 
 	tg_drain_bios(&td_root_tg(td)->service_queue);
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index df6ab19..7fba0d0 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -780,68 +780,72 @@ static inline struct cgroup *cgroup_from_id(struct cgroup_subsys *ss, int id)
 	return idr_find(&ss->root->cgroup_idr, id);
 }
 
-struct cgroup *cgroup_next_child(struct cgroup *pos, struct cgroup *cgrp);
+struct cgroup_subsys_state *css_next_child(struct cgroup_subsys_state *pos,
+					   struct cgroup_subsys_state *parent);
 
 /**
- * cgroup_for_each_child - iterate through children of a cgroup
- * @pos: the cgroup * to use as the loop cursor
- * @cgrp: cgroup whose children to walk
+ * css_for_each_child - iterate through children of a css
+ * @pos: the css * to use as the loop cursor
+ * @parent: css whose children to walk
  *
- * Walk @cgrp's children.  Must be called under rcu_read_lock().  A child
- * cgroup which hasn't finished ->css_online() or already has finished
+ * Walk @parent's children.  Must be called under rcu_read_lock().  A child
+ * css which hasn't finished ->css_online() or already has finished
  * ->css_offline() may show up during traversal and it's each subsystem's
  * responsibility to verify that each @pos is alive.
  *
  * If a subsystem synchronizes against the parent in its ->css_online() and
- * before starting iterating, a cgroup which finished ->css_online() is
+ * before starting iterating, a css which finished ->css_online() is
  * guaranteed to be visible in the future iterations.
  *
  * It is allowed to temporarily drop RCU read lock during iteration.  The
  * caller is responsible for ensuring that @pos remains accessible until
  * the start of the next iteration by, for example, bumping the css refcnt.
  */
-#define cgroup_for_each_child(pos, cgrp)				\
-	for ((pos) = cgroup_next_child(NULL, (cgrp)); (pos);		\
-	     (pos) = cgroup_next_child((pos), (cgrp)))
+#define css_for_each_child(pos, parent)					\
+	for ((pos) = css_next_child(NULL, (parent)); (pos);		\
+	     (pos) = css_next_child((pos), (parent)))
 
-struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
-					  struct cgroup *cgroup);
-struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos);
+struct cgroup_subsys_state *
+css_next_descendant_pre(struct cgroup_subsys_state *pos,
+			struct cgroup_subsys_state *css);
+
+struct cgroup_subsys_state *
+css_rightmost_descendant(struct cgroup_subsys_state *pos);
 
 /**
- * cgroup_for_each_descendant_pre - pre-order walk of a cgroup's descendants
- * @pos: the cgroup * to use as the loop cursor
- * @cgroup: cgroup whose descendants to walk
+ * css_for_each_descendant_pre - pre-order walk of a css's descendants
+ * @pos: the css * to use as the loop cursor
+ * @root: css whose descendants to walk
  *
- * Walk @cgroup's descendants.  Must be called under rcu_read_lock().  A
- * descendant cgroup which hasn't finished ->css_online() or already has
+ * Walk @root's descendants.  Must be called under rcu_read_lock().  A
+ * descendant css which hasn't finished ->css_online() or already has
  * finished ->css_offline() may show up during traversal and it's each
  * subsystem's responsibility to verify that each @pos is alive.
  *
  * If a subsystem synchronizes against the parent in its ->css_online() and
  * before starting iterating, and synchronizes against @pos on each
- * iteration, any descendant cgroup which finished ->css_online() is
+ * iteration, any descendant css which finished ->css_online() is
  * guaranteed to be visible in the future iterations.
  *
  * In other words, the following guarantees that a descendant can't escape
  * state updates of its ancestors.
  *
- * my_online(@cgrp)
+ * my_online(@css)
  * {
- *	Lock @cgrp->parent and @cgrp;
- *	Inherit state from @cgrp->parent;
+ *	Lock @css's parent and @css;
+ *	Inherit state from the parent;
  *	Unlock both.
  * }
  *
- * my_update_state(@cgrp)
+ * my_update_state(@css)
  * {
- *	Lock @cgrp;
- *	Update @cgrp's state;
- *	Unlock @cgrp;
+ *	Lock @css;
+ *	Update @css's state;
+ *	Unlock @css;
  *
- *	cgroup_for_each_descendant_pre(@pos, @cgrp) {
+ *	css_for_each_descendant_pre(@pos, @css) {
  *		Lock @pos;
- *		Verify @pos is alive and inherit state from @pos->parent;
+ *		Verify @pos is alive and inherit state from @pos's parent;
  *		Unlock @pos;
  *	}
  * }
@@ -852,8 +856,7 @@ struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos);
  * visible by walking order and, as long as inheriting operations to the
  * same @pos are atomic to each other, multiple updates racing each other
  * still result in the correct state.  It's guaranateed that at least one
- * inheritance happens for any cgroup after the latest update to its
- * parent.
+ * inheritance happens for any css after the latest update to its parent.
  *
  * If checking parent's state requires locking the parent, each inheriting
  * iteration should lock and unlock both @pos->parent and @pos.
@@ -866,25 +869,26 @@ struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos);
  * caller is responsible for ensuring that @pos remains accessible until
  * the start of the next iteration by, for example, bumping the css refcnt.
  */
-#define cgroup_for_each_descendant_pre(pos, cgroup)			\
-	for (pos = cgroup_next_descendant_pre(NULL, (cgroup)); (pos);	\
-	     pos = cgroup_next_descendant_pre((pos), (cgroup)))
+#define css_for_each_descendant_pre(pos, css)				\
+	for ((pos) = css_next_descendant_pre(NULL, (css)); (pos);	\
+	     (pos) = css_next_descendant_pre((pos), (css)))
 
-struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
-					   struct cgroup *cgroup);
+struct cgroup_subsys_state *
+css_next_descendant_post(struct cgroup_subsys_state *pos,
+			 struct cgroup_subsys_state *css);
 
 /**
- * cgroup_for_each_descendant_post - post-order walk of a cgroup's descendants
- * @pos: the cgroup * to use as the loop cursor
- * @cgroup: cgroup whose descendants to walk
+ * css_for_each_descendant_post - post-order walk of a css's descendants
+ * @pos: the css * to use as the loop cursor
+ * @css: css whose descendants to walk
  *
- * Similar to cgroup_for_each_descendant_pre() but performs post-order
+ * Similar to css_for_each_descendant_pre() but performs post-order
  * traversal instead.  Note that the walk visibility guarantee described in
  * pre-order walk doesn't apply the same to post-order walks.
  */
-#define cgroup_for_each_descendant_post(pos, cgroup)			\
-	for (pos = cgroup_next_descendant_post(NULL, (cgroup)); (pos);	\
-	     pos = cgroup_next_descendant_post((pos), (cgroup)))
+#define css_for_each_descendant_post(pos, css)				\
+	for ((pos) = css_next_descendant_post(NULL, (css)); (pos);	\
+	     (pos) = css_next_descendant_post((pos), (css)))
 
 /* A cgroup_iter should be treated as an opaque object */
 struct cgroup_iter {
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7b53b58..850ad87 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2807,8 +2807,8 @@ static void cgroup_cfts_prepare(void)
 	/*
 	 * Thanks to the entanglement with vfs inode locking, we can't walk
 	 * the existing cgroups under cgroup_mutex and create files.
-	 * Instead, we use cgroup_for_each_descendant_pre() and drop RCU
-	 * read lock before calling cgroup_addrm_files().
+	 * Instead, we use css_for_each_descendant_pre() and drop RCU read
+	 * lock before calling cgroup_addrm_files().
 	 */
 	mutex_lock(&cgroup_mutex);
 }
@@ -2818,10 +2818,11 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 {
 	LIST_HEAD(pending);
 	struct cgroup_subsys *ss = cfts[0].ss;
-	struct cgroup *cgrp, *root = &ss->root->top_cgroup;
+	struct cgroup *root = &ss->root->top_cgroup;
 	struct super_block *sb = ss->root->sb;
 	struct dentry *prev = NULL;
 	struct inode *inode;
+	struct cgroup_subsys_state *css;
 	u64 update_before;
 	int ret = 0;
 
@@ -2854,7 +2855,9 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 
 	/* add/rm files for all cgroups created before */
 	rcu_read_lock();
-	cgroup_for_each_descendant_pre(cgrp, root) {
+	css_for_each_descendant_pre(css, cgroup_css(root, ss->subsys_id)) {
+		struct cgroup *cgrp = css->cgroup;
+
 		if (cgroup_is_dead(cgrp))
 			continue;
 
@@ -3030,17 +3033,21 @@ static void cgroup_enable_task_cg_lists(void)
 }
 
 /**
- * cgroup_next_child - find the next child of a given cgroup
- * @pos: the current position (%NULL to initiate traversal)
- * @cgrp: cgroup whose descendants to walk
+ * css_next_child - find the next child of a given css
+ * @pos_css: the current position (%NULL to initiate traversal)
+ * @parent_css: css whose children to walk
  *
- * This function returns the next child of @cgrp and should be called under
- * RCU read lock.  The only requirement is that @cgrp and @pos are
- * accessible.  The next sibling is guaranteed to be returned regardless of
- * their states.
+ * This function returns the next child of @parent_css and should be called
+ * under RCU read lock.  The only requirement is that @parent_css and
+ * @pos_css are accessible.  The next sibling is guaranteed to be returned
+ * regardless of their states.
  */
-struct cgroup *cgroup_next_child(struct cgroup *pos, struct cgroup *cgrp)
+struct cgroup_subsys_state *
+css_next_child(struct cgroup_subsys_state *pos_css,
+	       struct cgroup_subsys_state *parent_css)
 {
+	struct cgroup *pos = pos_css ? pos_css->cgroup : NULL;
+	struct cgroup *cgrp = parent_css->cgroup;
 	struct cgroup *next;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
@@ -3074,59 +3081,64 @@ struct cgroup *cgroup_next_child(struct cgroup *pos, struct cgroup *cgrp)
 				break;
 	}
 
-	if (&next->sibling != &cgrp->children)
-		return next;
-	return NULL;
+	if (&next->sibling == &cgrp->children)
+		return NULL;
+
+	if (parent_css->ss)
+		return cgroup_css(next, parent_css->ss->subsys_id);
+	else
+		return &next->dummy_css;
 }
-EXPORT_SYMBOL_GPL(cgroup_next_child);
+EXPORT_SYMBOL_GPL(css_next_child);
 
 /**
- * cgroup_next_descendant_pre - find the next descendant for pre-order walk
+ * css_next_descendant_pre - find the next descendant for pre-order walk
  * @pos: the current position (%NULL to initiate traversal)
- * @cgroup: cgroup whose descendants to walk
+ * @root: css whose descendants to walk
  *
- * To be used by cgroup_for_each_descendant_pre().  Find the next
- * descendant to visit for pre-order traversal of @cgroup's descendants.
+ * To be used by css_for_each_descendant_pre().  Find the next descendant
+ * to visit for pre-order traversal of @root's descendants.
  *
  * While this function requires RCU read locking, it doesn't require the
  * whole traversal to be contained in a single RCU critical section.  This
  * function will return the correct next descendant as long as both @pos
- * and @cgroup are accessible and @pos is a descendant of @cgroup.
+ * and @root are accessible and @pos is a descendant of @root.
  */
-struct cgroup *cgroup_next_descendant_pre(struct cgroup *pos,
-					  struct cgroup *cgroup)
+struct cgroup_subsys_state *
+css_next_descendant_pre(struct cgroup_subsys_state *pos,
+			struct cgroup_subsys_state *root)
 {
-	struct cgroup *next;
+	struct cgroup_subsys_state *next;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
-	/* if first iteration, pretend we just visited @cgroup */
+	/* if first iteration, pretend we just visited @root */
 	if (!pos)
-		pos = cgroup;
+		pos = root;
 
 	/* visit the first child if exists */
-	next = cgroup_next_child(NULL, pos);
+	next = css_next_child(NULL, pos);
 	if (next)
 		return next;
 
 	/* no child, visit my or the closest ancestor's next sibling */
-	while (pos != cgroup) {
-		next = cgroup_next_child(pos, pos->parent);
+	while (pos != root) {
+		next = css_next_child(pos, css_parent(pos));
 		if (next)
 			return next;
-		pos = pos->parent;
+		pos = css_parent(pos);
 	}
 
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(cgroup_next_descendant_pre);
+EXPORT_SYMBOL_GPL(css_next_descendant_pre);
 
 /**
- * cgroup_rightmost_descendant - return the rightmost descendant of a cgroup
- * @pos: cgroup of interest
+ * css_rightmost_descendant - return the rightmost descendant of a css
+ * @pos: css of interest
  *
- * Return the rightmost descendant of @pos.  If there's no descendant,
- * @pos is returned.  This can be used during pre-order traversal to skip
+ * Return the rightmost descendant of @pos.  If there's no descendant, @pos
+ * is returned.  This can be used during pre-order traversal to skip
  * subtree of @pos.
  *
  * While this function requires RCU read locking, it doesn't require the
@@ -3134,9 +3146,10 @@ EXPORT_SYMBOL_GPL(cgroup_next_descendant_pre);
  * function will return the correct rightmost descendant as long as @pos is
  * accessible.
  */
-struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos)
+struct cgroup_subsys_state *
+css_rightmost_descendant(struct cgroup_subsys_state *pos)
 {
-	struct cgroup *last, *tmp;
+	struct cgroup_subsys_state *last, *tmp;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
@@ -3144,62 +3157,64 @@ struct cgroup *cgroup_rightmost_descendant(struct cgroup *pos)
 		last = pos;
 		/* ->prev isn't RCU safe, walk ->next till the end */
 		pos = NULL;
-		cgroup_for_each_child(tmp, last)
+		css_for_each_child(tmp, last)
 			pos = tmp;
 	} while (pos);
 
 	return last;
 }
-EXPORT_SYMBOL_GPL(cgroup_rightmost_descendant);
+EXPORT_SYMBOL_GPL(css_rightmost_descendant);
 
-static struct cgroup *cgroup_leftmost_descendant(struct cgroup *pos)
+static struct cgroup_subsys_state *
+css_leftmost_descendant(struct cgroup_subsys_state *pos)
 {
-	struct cgroup *last;
+	struct cgroup_subsys_state *last;
 
 	do {
 		last = pos;
-		pos = cgroup_next_child(NULL, pos);
+		pos = css_next_child(NULL, pos);
 	} while (pos);
 
 	return last;
 }
 
 /**
- * cgroup_next_descendant_post - find the next descendant for post-order walk
+ * css_next_descendant_post - find the next descendant for post-order walk
  * @pos: the current position (%NULL to initiate traversal)
- * @cgroup: cgroup whose descendants to walk
+ * @root: css whose descendants to walk
  *
- * To be used by cgroup_for_each_descendant_post().  Find the next
- * descendant to visit for post-order traversal of @cgroup's descendants.
+ * To be used by css_for_each_descendant_post().  Find the next descendant
+ * to visit for post-order traversal of @root's descendants.
  *
  * While this function requires RCU read locking, it doesn't require the
  * whole traversal to be contained in a single RCU critical section.  This
  * function will return the correct next descendant as long as both @pos
  * and @cgroup are accessible and @pos is a descendant of @cgroup.
  */
-struct cgroup *cgroup_next_descendant_post(struct cgroup *pos,
-					   struct cgroup *cgroup)
+struct cgroup_subsys_state *
+css_next_descendant_post(struct cgroup_subsys_state *pos,
+			 struct cgroup_subsys_state *root)
 {
-	struct cgroup *next;
+	struct cgroup_subsys_state *next;
 
 	WARN_ON_ONCE(!rcu_read_lock_held());
 
 	/* if first iteration, visit the leftmost descendant */
 	if (!pos) {
-		next = cgroup_leftmost_descendant(cgroup);
-		return next != cgroup ? next : NULL;
+		next = css_leftmost_descendant(root);
+		return next != root ? next : NULL;
 	}
 
 	/* if there's an unvisited sibling, visit its leftmost descendant */
-	next = cgroup_next_child(pos, pos->parent);
+	next = css_next_child(pos, css_parent(pos));
 	if (next)
-		return cgroup_leftmost_descendant(next);
+		return css_leftmost_descendant(next);
 
 	/* no sibling left, visit parent */
-	next = pos->parent;
-	return next != cgroup ? next : NULL;
+	next = css_parent(pos);
+	return next != root ? next : NULL;
 }
-EXPORT_SYMBOL_GPL(cgroup_next_descendant_post);
+EXPORT_SYMBOL_GPL(css_next_descendant_post);
 
 void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it)
 	__acquires(css_set_lock)
@@ -4540,9 +4555,9 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
 	 * creation by disabling cgroup_lock_live_group().  Note that
-	 * CGRP_DEAD assertion is depended upon by cgroup_next_child() to
+	 * CGRP_DEAD assertion is depended upon by css_next_child() to
 	 * resume iteration after dropping RCU read lock.  See
-	 * cgroup_next_child() for details.
+	 * css_next_child() for details.
 	 */
 	set_bit(CGRP_DEAD, &cgrp->flags);
 
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 19613ba..98ca48d 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -50,11 +50,6 @@ static inline struct freezer *css_freezer(struct cgroup_subsys_state *css)
 	return css ? container_of(css, struct freezer, css) : NULL;
 }
 
-static inline struct freezer *cgroup_freezer(struct cgroup *cgroup)
-{
-	return css_freezer(cgroup_css(cgroup, freezer_subsys_id));
-}
-
 static inline struct freezer *task_freezer(struct task_struct *task)
 {
 	return css_freezer(task_css(task, freezer_subsys_id));
@@ -120,7 +115,7 @@ static int freezer_css_online(struct cgroup_subsys_state *css)
 	/*
 	 * The following double locking and freezing state inheritance
 	 * guarantee that @cgroup can never escape ancestors' freezing
-	 * states.  See cgroup_for_each_descendant_pre() for details.
+	 * states.  See css_for_each_descendant_pre() for details.
 	 */
 	if (parent)
 		spin_lock_irq(&parent->lock);
@@ -262,7 +257,7 @@ out:
 static void update_if_frozen(struct cgroup_subsys_state *css)
 {
 	struct freezer *freezer = css_freezer(css);
-	struct cgroup *pos;
+	struct cgroup_subsys_state *pos;
 	struct cgroup_iter it;
 	struct task_struct *task;
 
@@ -275,8 +270,8 @@ static void update_if_frozen(struct cgroup_subsys_state *css)
 		goto out_unlock;
 
 	/* are all (live) children frozen? */
-	cgroup_for_each_child(pos, css->cgroup) {
-		struct freezer *child = cgroup_freezer(pos);
+	css_for_each_child(pos, css) {
+		struct freezer *child = css_freezer(pos);
 
 		if ((child->state & CGROUP_FREEZER_ONLINE) &&
 		    !(child->state & CGROUP_FROZEN))
@@ -309,13 +304,13 @@ out_unlock:
 static int freezer_read(struct cgroup_subsys_state *css, struct cftype *cft,
 			struct seq_file *m)
 {
-	struct cgroup *pos;
+	struct cgroup_subsys_state *pos;
 
 	rcu_read_lock();
 
 	/* update states bottom-up */
-	cgroup_for_each_descendant_post(pos, css->cgroup)
-		update_if_frozen(cgroup_css(pos, freezer_subsys_id));
+	css_for_each_descendant_post(pos, css)
+		update_if_frozen(pos);
 	update_if_frozen(css);
 
 	rcu_read_unlock();
@@ -396,7 +391,7 @@ static void freezer_apply_state(struct freezer *freezer, bool freeze,
  */
 static void freezer_change_state(struct freezer *freezer, bool freeze)
 {
-	struct cgroup *pos;
+	struct cgroup_subsys_state *pos;
 
 	/* update @freezer */
 	spin_lock_irq(&freezer->lock);
@@ -409,8 +404,8 @@ static void freezer_change_state(struct freezer *freezer, bool freeze)
 	 * CGROUP_FREEZING_PARENT.
 	 */
 	rcu_read_lock();
-	cgroup_for_each_descendant_pre(pos, freezer->css.cgroup) {
-		struct freezer *pos_f = cgroup_freezer(pos);
+	css_for_each_descendant_pre(pos, &freezer->css) {
+		struct freezer *pos_f = css_freezer(pos);
 		struct freezer *parent = parent_freezer(pos_f);
 
 		/*
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 89b76e1..be4f503 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -210,29 +210,29 @@ static struct cpuset top_cpuset = {
 /**
  * cpuset_for_each_child - traverse online children of a cpuset
  * @child_cs: loop cursor pointing to the current child
- * @pos_cgrp: used for iteration
+ * @pos_css: used for iteration
  * @parent_cs: target cpuset to walk children of
  *
  * Walk @child_cs through the online children of @parent_cs.  Must be used
  * with RCU read locked.
  */
-#define cpuset_for_each_child(child_cs, pos_cgrp, parent_cs)		\
-	cgroup_for_each_child((pos_cgrp), (parent_cs)->css.cgroup)	\
-		if (is_cpuset_online(((child_cs) = cgroup_cs((pos_cgrp)))))
+#define cpuset_for_each_child(child_cs, pos_css, parent_cs)		\
+	css_for_each_child((pos_css), &(parent_cs)->css)		\
+		if (is_cpuset_online(((child_cs) = css_cs((pos_css)))))
 
 /**
  * cpuset_for_each_descendant_pre - pre-order walk of a cpuset's descendants
  * @des_cs: loop cursor pointing to the current descendant
- * @pos_cgrp: used for iteration
+ * @pos_css: used for iteration
  * @root_cs: target cpuset to walk ancestor of
  *
  * Walk @des_cs through the online descendants of @root_cs.  Must be used
- * with RCU read locked.  The caller may modify @pos_cgrp by calling
- * cgroup_rightmost_descendant() to skip subtree.
+ * with RCU read locked.  The caller may modify @pos_css by calling
+ * css_rightmost_descendant() to skip subtree.
  */
-#define cpuset_for_each_descendant_pre(des_cs, pos_cgrp, root_cs)	\
-	cgroup_for_each_descendant_pre((pos_cgrp), (root_cs)->css.cgroup) \
-		if (is_cpuset_online(((des_cs) = cgroup_cs((pos_cgrp)))))
+#define cpuset_for_each_descendant_pre(des_cs, pos_css, root_cs)	\
+	css_for_each_descendant_pre((pos_css), &(root_cs)->css)		\
+		if (is_cpuset_online(((des_cs) = css_cs((pos_css)))))
 
 /*
  * There are two global mutexes guarding cpuset structures - cpuset_mutex
@@ -430,7 +430,7 @@ static void free_trial_cpuset(struct cpuset *trial)
 
 static int validate_change(struct cpuset *cur, struct cpuset *trial)
 {
-	struct cgroup *cgrp;
+	struct cgroup_subsys_state *css;
 	struct cpuset *c, *par;
 	int ret;
 
@@ -438,7 +438,7 @@ static int validate_change(struct cpuset *cur, struct cpuset *trial)
 
 	/* Each of our child cpusets must be a subset of us */
 	ret = -EBUSY;
-	cpuset_for_each_child(c, cgrp, cur)
+	cpuset_for_each_child(c, css, cur)
 		if (!is_cpuset_subset(c, trial))
 			goto out;
 
@@ -459,7 +459,7 @@ static int validate_change(struct cpuset *cur, struct cpuset *trial)
 	 * overlap
 	 */
 	ret = -EINVAL;
-	cpuset_for_each_child(c, cgrp, par) {
+	cpuset_for_each_child(c, css, par) {
 		if ((is_cpu_exclusive(trial) || is_cpu_exclusive(c)) &&
 		    c != cur &&
 		    cpumask_intersects(trial->cpus_allowed, c->cpus_allowed))
@@ -508,13 +508,13 @@ static void update_domain_attr_tree(struct sched_domain_attr *dattr,
 				    struct cpuset *root_cs)
 {
 	struct cpuset *cp;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 
 	rcu_read_lock();
-	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
+	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
 		/* skip the whole subtree if @cp doesn't have any CPU */
 		if (cpumask_empty(cp->cpus_allowed)) {
-			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+			pos_css = css_rightmost_descendant(pos_css);
 			continue;
 		}
 
@@ -589,7 +589,7 @@ static int generate_sched_domains(cpumask_var_t **domains,
 	struct sched_domain_attr *dattr;  /* attributes for custom domains */
 	int ndoms = 0;		/* number of sched domains in result */
 	int nslot;		/* next empty doms[] struct cpumask slot */
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 
 	doms = NULL;
 	dattr = NULL;
@@ -618,7 +618,7 @@ static int generate_sched_domains(cpumask_var_t **domains,
 	csn = 0;
 
 	rcu_read_lock();
-	cpuset_for_each_descendant_pre(cp, pos_cgrp, &top_cpuset) {
+	cpuset_for_each_descendant_pre(cp, pos_css, &top_cpuset) {
 		/*
 		 * Continue traversing beyond @cp iff @cp has some CPUs and
 		 * isn't load balancing.  The former is obvious.  The
@@ -635,7 +635,7 @@ static int generate_sched_domains(cpumask_var_t **domains,
 			csa[csn++] = cp;
 
 		/* skip @cp's subtree */
-		pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+		pos_css = css_rightmost_descendant(pos_css);
 	}
 	rcu_read_unlock();
 
@@ -886,16 +886,16 @@ static void update_tasks_cpumask_hier(struct cpuset *root_cs,
 				      bool update_root, struct ptr_heap *heap)
 {
 	struct cpuset *cp;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 
 	if (update_root)
 		update_tasks_cpumask(root_cs, heap);
 
 	rcu_read_lock();
-	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
+	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
 		/* skip the whole subtree if @cp have some CPU */
 		if (!cpumask_empty(cp->cpus_allowed)) {
-			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+			pos_css = css_rightmost_descendant(pos_css);
 			continue;
 		}
 		if (!css_tryget(&cp->css))
@@ -1143,16 +1143,16 @@ static void update_tasks_nodemask_hier(struct cpuset *root_cs,
 				       bool update_root, struct ptr_heap *heap)
 {
 	struct cpuset *cp;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 
 	if (update_root)
 		update_tasks_nodemask(root_cs, heap);
 
 	rcu_read_lock();
-	cpuset_for_each_descendant_pre(cp, pos_cgrp, root_cs) {
+	cpuset_for_each_descendant_pre(cp, pos_css, root_cs) {
 		/* skip the whole subtree if @cp have some CPU */
 		if (!nodes_empty(cp->mems_allowed)) {
-			pos_cgrp = cgroup_rightmost_descendant(pos_cgrp);
+			pos_css = css_rightmost_descendant(pos_css);
 			continue;
 		}
 		if (!css_tryget(&cp->css))
@@ -1973,7 +1973,7 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 	struct cpuset *cs = css_cs(css);
 	struct cpuset *parent = parent_cs(cs);
 	struct cpuset *tmp_cs;
-	struct cgroup *pos_cgrp;
+	struct cgroup_subsys_state *pos_css;
 
 	if (!parent)
 		return 0;
@@ -2005,7 +2005,7 @@ static int cpuset_css_online(struct cgroup_subsys_state *css)
 	 * (and likewise for mems) to the new cgroup.
 	 */
 	rcu_read_lock();
-	cpuset_for_each_child(tmp_cs, pos_cgrp, parent) {
+	cpuset_for_each_child(tmp_cs, pos_css, parent) {
 		if (is_mem_exclusive(tmp_cs) || is_cpu_exclusive(tmp_cs)) {
 			rcu_read_unlock();
 			goto out_unlock;
@@ -2252,10 +2252,10 @@ static void cpuset_hotplug_workfn(struct work_struct *work)
 	/* if cpus or mems changed, we need to propagate to descendants */
 	if (cpus_updated || mems_updated) {
 		struct cpuset *cs;
-		struct cgroup *pos_cgrp;
+		struct cgroup_subsys_state *pos_css;
 
 		rcu_read_lock();
-		cpuset_for_each_descendant_pre(cs, pos_cgrp, &top_cpuset) {
+		cpuset_for_each_descendant_pre(cs, pos_css, &top_cpuset) {
 			if (!css_tryget(&cs->css))
 				continue;
 			rcu_read_unlock();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ab64dfc..2285319 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1082,7 +1082,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
 static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
 		struct mem_cgroup *last_visited)
 {
-	struct cgroup *prev_cgroup, *next_cgroup;
+	struct cgroup_subsys_state *prev_css, *next_css;
 
 	/*
 	 * Root is not visited by cgroup iterators so it needs an
@@ -1091,11 +1091,9 @@ static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
 	if (!last_visited)
 		return root;
 
-	prev_cgroup = (last_visited == root) ? NULL
-		: last_visited->css.cgroup;
+	prev_css = (last_visited == root) ? NULL : &last_visited->css;
 skip_node:
-	next_cgroup = cgroup_next_descendant_pre(
-			prev_cgroup, root->css.cgroup);
+	next_css = css_next_descendant_pre(prev_css, &root->css);
 
 	/*
 	 * Even if we found a group we have to make sure it is
@@ -1104,13 +1102,13 @@ skip_node:
 	 * last_visited css is safe to use because it is
 	 * protected by css_get and the tree walk is rcu safe.
 	 */
-	if (next_cgroup) {
-		struct mem_cgroup *mem = mem_cgroup_from_cont(
-				next_cgroup);
+	if (next_css) {
+		struct mem_cgroup *mem = mem_cgroup_from_css(next_css);
+
 		if (css_tryget(&mem->css))
 			return mem;
 		else {
-			prev_cgroup = next_cgroup;
+			prev_css = next_css;
 			goto skip_node;
 		}
 	}
@@ -4939,10 +4937,10 @@ static void mem_cgroup_reparent_charges(struct mem_cgroup *memcg)
  */
 static inline bool __memcg_has_children(struct mem_cgroup *memcg)
 {
-	struct cgroup *pos;
+	struct cgroup_subsys_state *pos;
 
 	/* bounce at first found */
-	cgroup_for_each_child(pos, memcg->css.cgroup)
+	css_for_each_child(pos, &memcg->css)
 		return true;
 	return false;
 }
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index e0ca464..9bf230a 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -56,11 +56,6 @@ static inline struct dev_cgroup *css_to_devcgroup(struct cgroup_subsys_state *s)
 	return s ? container_of(s, struct dev_cgroup, css) : NULL;
 }
 
-static inline struct dev_cgroup *cgroup_to_devcgroup(struct cgroup *cgroup)
-{
-	return css_to_devcgroup(cgroup_css(cgroup, devices_subsys_id));
-}
-
 static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 {
 	return css_to_devcgroup(task_css(task, devices_subsys_id));
@@ -447,13 +442,13 @@ static void revalidate_active_exceptions(struct dev_cgroup *devcg)
 static int propagate_exception(struct dev_cgroup *devcg_root,
 			       struct dev_exception_item *ex)
 {
-	struct cgroup *root = devcg_root->css.cgroup, *pos;
+	struct cgroup_subsys_state *pos;
 	int rc = 0;
 
 	rcu_read_lock();
 
-	cgroup_for_each_descendant_pre(pos, root) {
-		struct dev_cgroup *devcg = cgroup_to_devcgroup(pos);
+	css_for_each_descendant_pre(pos, &devcg_root->css) {
+		struct dev_cgroup *devcg = css_to_devcgroup(pos);
 
 		/*
 		 * Because devcgroup_mutex is held, no devcg will become
-- 
1.8.3.1
