From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/12] cgroup: make cgroup_css() take cgroup_subsys * instead
	and allow NULL subsys
Date: Thu, 15 Aug 2013 12:02:20 -0400
Message-ID: <1376582550-12548-3-git-send-email-tj__32715.1010315449$1376582584$gmane$org@kernel.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1376582550-12548-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_css() is no longer used in hot paths.  Make it take struct
cgroup_subsys * and allow the users to specify NULL subsys to obtain
the dummy_css.  This removes open-coded NULL subsystem testing in a
couple users and generally simplifies the code.

After this patch, css_from_dir() also allows NULL @ss and returns the
matching dummy_css.  This behavior change doesn't affect its only user
- perf.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 90 +++++++++++++++++++++++++++------------------------------
 1 file changed, 43 insertions(+), 47 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 007053d..f09ce8d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -226,19 +226,22 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 /**
  * cgroup_css - obtain a cgroup's css for the specified subsystem
  * @cgrp: the cgroup of interest
- * @subsys_id: the subsystem of interest
+ * @ss: the subsystem of interest (%NULL returns the dummy_css)
  *
- * Return @cgrp's css (cgroup_subsys_state) associated with @subsys_id.
- * This function must be called either under cgroup_mutex or
- * rcu_read_lock() and the caller is responsible for pinning the returned
- * css if it wants to keep accessing it outside the said locks.  This
- * function may return %NULL if @cgrp doesn't have @subsys_id enabled.
+ * Return @cgrp's css (cgroup_subsys_state) associated with @ss.  This
+ * function must be called either under cgroup_mutex or rcu_read_lock() and
+ * the caller is responsible for pinning the returned css if it wants to
+ * keep accessing it outside the said locks.  This function may return
+ * %NULL if @cgrp doesn't have @subsys_id enabled.
  */
 static struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
-					      int subsys_id)
+					      struct cgroup_subsys *ss)
 {
-	return rcu_dereference_check(cgrp->subsys[subsys_id],
-				     lockdep_is_held(&cgroup_mutex));
+	if (ss)
+		return rcu_dereference_check(cgrp->subsys[ss->subsys_id],
+					     lockdep_is_held(&cgroup_mutex));
+	else
+		return &cgrp->dummy_css;
 }
 
 /* convenient tests for these bits */
@@ -580,7 +583,7 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 			/* Subsystem is in this hierarchy. So we want
 			 * the subsystem state from the new
 			 * cgroup */
-			template[i] = cgroup_css(cgrp, i);
+			template[i] = cgroup_css(cgrp, ss);
 		} else {
 			/* Subsystem is not in this hierarchy, so we
 			 * don't want to change the subsystem state */
@@ -1062,30 +1065,30 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 
 		if (bit & added_mask) {
 			/* We're binding this subsystem to this hierarchy */
-			BUG_ON(cgroup_css(cgrp, i));
-			BUG_ON(!cgroup_css(cgroup_dummy_top, i));
-			BUG_ON(cgroup_css(cgroup_dummy_top, i)->cgroup != cgroup_dummy_top);
+			BUG_ON(cgroup_css(cgrp, ss));
+			BUG_ON(!cgroup_css(cgroup_dummy_top, ss));
+			BUG_ON(cgroup_css(cgroup_dummy_top, ss)->cgroup != cgroup_dummy_top);
 
 			rcu_assign_pointer(cgrp->subsys[i],
-					   cgroup_css(cgroup_dummy_top, i));
-			cgroup_css(cgrp, i)->cgroup = cgrp;
+					   cgroup_css(cgroup_dummy_top, ss));
+			cgroup_css(cgrp, ss)->cgroup = cgrp;
 
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
-				ss->bind(cgroup_css(cgrp, i));
+				ss->bind(cgroup_css(cgrp, ss));
 
 			/* refcount was already taken, and we're keeping it */
 			root->subsys_mask |= bit;
 		} else if (bit & removed_mask) {
 			/* We're removing this subsystem */
-			BUG_ON(cgroup_css(cgrp, i) != cgroup_css(cgroup_dummy_top, i));
-			BUG_ON(cgroup_css(cgrp, i)->cgroup != cgrp);
+			BUG_ON(cgroup_css(cgrp, ss) != cgroup_css(cgroup_dummy_top, ss));
+			BUG_ON(cgroup_css(cgrp, ss)->cgroup != cgrp);
 
 			if (ss->bind)
-				ss->bind(cgroup_css(cgroup_dummy_top, i));
+				ss->bind(cgroup_css(cgroup_dummy_top, ss));
 
-			cgroup_css(cgroup_dummy_top, i)->cgroup = cgroup_dummy_top;
+			cgroup_css(cgroup_dummy_top, ss)->cgroup = cgroup_dummy_top;
 			RCU_INIT_POINTER(cgrp->subsys[i], NULL);
 
 			cgroup_subsys[i]->root = &cgroup_dummy_root;
@@ -1930,7 +1933,7 @@ EXPORT_SYMBOL_GPL(cgroup_taskset_next);
 struct cgroup_subsys_state *cgroup_taskset_cur_css(struct cgroup_taskset *tset,
 						   int subsys_id)
 {
-	return cgroup_css(tset->cur_cgrp, subsys_id);
+	return cgroup_css(tset->cur_cgrp, cgroup_subsys[subsys_id]);
 }
 EXPORT_SYMBOL_GPL(cgroup_taskset_cur_css);
 
@@ -2071,7 +2074,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
 
 		if (ss->can_attach) {
 			retval = ss->can_attach(css, &tset);
@@ -2113,7 +2116,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * step 4: do subsystem attach callbacks.
 	 */
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
 
 		if (ss->attach)
 			ss->attach(css, &tset);
@@ -2135,7 +2138,7 @@ out_put_css_set_refs:
 out_cancel_attach:
 	if (retval) {
 		for_each_root_subsys(root, ss) {
-			struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+			struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
 
 			if (ss == failed_ss)
 				break;
@@ -2481,13 +2484,9 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	 * @css stays alive for all file operations.
 	 */
 	rcu_read_lock();
-	if (cft->ss) {
-		css = cgroup_css(cgrp, cft->ss->subsys_id);
-		if (!css_tryget(css))
-			css = NULL;
-	} else {
-		css = &cgrp->dummy_css;
-	}
+	css = cgroup_css(cgrp, cft->ss);
+	if (cft->ss && !css_tryget(css))
+		css = NULL;
 	rcu_read_unlock();
 
 	if (!css)
@@ -2878,7 +2877,7 @@ static int cgroup_cfts_commit(struct cftype *cfts, bool is_add)
 
 	/* add/rm files for all cgroups created before */
 	rcu_read_lock();
-	css_for_each_descendant_pre(css, cgroup_css(root, ss->subsys_id)) {
+	css_for_each_descendant_pre(css, cgroup_css(root, ss)) {
 		struct cgroup *cgrp = css->cgroup;
 
 		if (cgroup_is_dead(cgrp))
@@ -3082,10 +3081,7 @@ css_next_child(struct cgroup_subsys_state *pos_css,
 	if (&next->sibling == &cgrp->children)
 		return NULL;
 
-	if (parent_css->ss)
-		return cgroup_css(next, parent_css->ss->subsys_id);
-	else
-		return &next->dummy_css;
+	return cgroup_css(next, parent_css->ss);
 }
 EXPORT_SYMBOL_GPL(css_next_child);
 
@@ -4110,7 +4106,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
 	rcu_read_lock();
 
 	ret = -EINVAL;
-	event->css = cgroup_css(cgrp, event->cft->ss->subsys_id);
+	event->css = cgroup_css(cgrp, event->cft->ss);
 	if (event->css)
 		ret = 0;
 
@@ -4266,7 +4262,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 
 	/* This cgroup is ready now */
 	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
 		struct css_id *id = rcu_dereference_protected(css->id, true);
 
 		/*
@@ -4349,11 +4345,11 @@ static void init_css(struct cgroup_subsys_state *css, struct cgroup_subsys *ss,
 	css->id = NULL;
 
 	if (cgrp->parent)
-		css->parent = cgroup_css(cgrp->parent, ss->subsys_id);
+		css->parent = cgroup_css(cgrp->parent, ss);
 	else
 		css->flags |= CSS_ROOT;
 
-	BUG_ON(cgroup_css(cgrp, ss->subsys_id));
+	BUG_ON(cgroup_css(cgrp, ss));
 }
 
 /* invoke ->css_online() on a new CSS and mark it online if successful */
@@ -4466,7 +4462,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css;
 
-		css = ss->css_alloc(cgroup_css(parent, ss->subsys_id));
+		css = ss->css_alloc(cgroup_css(parent, ss));
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
 			goto err_free_all;
@@ -4712,7 +4708,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * percpu refs of all css's are confirmed to be killed.
 	 */
 	for_each_root_subsys(cgrp->root, ss)
-		kill_css(cgroup_css(cgrp, ss->subsys_id));
+		kill_css(cgroup_css(cgrp, ss));
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
@@ -4839,7 +4835,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
 	ss->root = &cgroup_dummy_root;
-	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss->subsys_id));
+	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss));
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
 	init_css(css, ss, cgroup_dummy_top);
@@ -4918,7 +4914,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 * struct, so this can happen first (i.e. before the dummy root
 	 * attachment).
 	 */
-	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss->subsys_id));
+	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss));
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the cgroup_subsys[] slot. */
 		cgroup_subsys[ss->subsys_id] = NULL;
@@ -5000,7 +4996,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 
 	mutex_lock(&cgroup_mutex);
 
-	offline_css(cgroup_css(cgroup_dummy_top, ss->subsys_id));
+	offline_css(cgroup_css(cgroup_dummy_top, ss));
 
 	if (ss->use_id)
 		idr_destroy(&ss->idr);
@@ -5034,7 +5030,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * the cgrp->subsys pointer to find their state. note that this
 	 * also takes care of freeing the css_id.
 	 */
-	ss->css_free(cgroup_css(cgroup_dummy_top, ss->subsys_id));
+	ss->css_free(cgroup_css(cgroup_dummy_top, ss));
 	RCU_INIT_POINTER(cgroup_dummy_top->subsys[ss->subsys_id], NULL);
 
 	mutex_unlock(&cgroup_mutex);
@@ -5721,7 +5717,7 @@ struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
 		return ERR_PTR(-EBADF);
 
 	cgrp = __d_cgrp(dentry);
-	return cgroup_css(cgrp, ss->subsys_id) ?: ERR_PTR(-ENOENT);
+	return cgroup_css(cgrp, ss) ?: ERR_PTR(-ENOENT);
 }
 
 #ifdef CONFIG_CGROUP_DEBUG
-- 
1.8.3.1
