From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/14] cgroup: always use cgroup_css()
Date: Thu,  8 Aug 2013 16:13:38 -0400
Message-ID: <1375992831-4650-2-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_css() is the accessor for cgroup->subsys[] but is not used
consistently.  cgroup->subsys[] will become RCU protected and
cgroup_css() will grow synchronization sanity checks.  In preparation,
make all cgroup->subsys[] dereferences use cgroup_css() consistently.

This patch doesn't introduce any functional difference.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 58 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 52f0498..49ad96e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -574,7 +574,7 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 			/* Subsystem is in this hierarchy. So we want
 			 * the subsystem state from the new
 			 * cgroup */
-			template[i] = cgrp->subsys[i];
+			template[i] = cgroup_css(cgrp, i);
 		} else {
 			/* Subsystem is not in this hierarchy, so we
 			 * don't want to change the subsystem state */
@@ -871,7 +871,7 @@ static void cgroup_free_fn(struct work_struct *work)
 	 * Release the subsystem state objects.
 	 */
 	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 		ss->css_free(css);
 	}
@@ -1067,27 +1067,27 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 
 		if (bit & added_mask) {
 			/* We're binding this subsystem to this hierarchy */
-			BUG_ON(cgrp->subsys[i]);
-			BUG_ON(!cgroup_dummy_top->subsys[i]);
-			BUG_ON(cgroup_dummy_top->subsys[i]->cgroup != cgroup_dummy_top);
+			BUG_ON(cgroup_css(cgrp, i));
+			BUG_ON(!cgroup_css(cgroup_dummy_top, i));
+			BUG_ON(cgroup_css(cgroup_dummy_top, i)->cgroup != cgroup_dummy_top);
 
 			cgrp->subsys[i] = cgroup_dummy_top->subsys[i];
-			cgrp->subsys[i]->cgroup = cgrp;
+			cgroup_css(cgrp, i)->cgroup = cgrp;
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
-				ss->bind(cgrp->subsys[i]);
+				ss->bind(cgroup_css(cgrp, i));
 
 			/* refcount was already taken, and we're keeping it */
 			root->subsys_mask |= bit;
 		} else if (bit & removed_mask) {
 			/* We're removing this subsystem */
-			BUG_ON(cgrp->subsys[i] != cgroup_dummy_top->subsys[i]);
-			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
+			BUG_ON(cgroup_css(cgrp, i) != cgroup_css(cgroup_dummy_top, i));
+			BUG_ON(cgroup_css(cgrp, i)->cgroup != cgrp);
 
 			if (ss->bind)
-				ss->bind(cgroup_dummy_top->subsys[i]);
-			cgroup_dummy_top->subsys[i]->cgroup = cgroup_dummy_top;
+				ss->bind(cgroup_css(cgroup_dummy_top, i));
+			cgroup_css(cgroup_dummy_top, i)->cgroup = cgroup_dummy_top;
 			cgrp->subsys[i] = NULL;
 			cgroup_subsys[i]->root = &cgroup_dummy_root;
 			list_move(&ss->sibling, &cgroup_dummy_root.subsys_list);
@@ -2072,7 +2072,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 		if (ss->can_attach) {
 			retval = ss->can_attach(css, &tset);
@@ -2114,7 +2114,7 @@ static int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk,
 	 * step 4: do subsystem attach callbacks.
 	 */
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 		if (ss->attach)
 			ss->attach(css, &tset);
@@ -2136,7 +2136,7 @@ out_put_css_set_refs:
 out_cancel_attach:
 	if (retval) {
 		for_each_root_subsys(root, ss) {
-			struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+			struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 			if (ss == failed_ss)
 				break;
@@ -2308,7 +2308,7 @@ static struct cgroup_subsys_state *cgroup_file_css(struct cfent *cfe)
 	struct cgroup *cgrp = __d_cgrp(cfe->dentry->d_parent);
 
 	if (cft->ss)
-		return cgrp->subsys[cft->ss->subsys_id];
+		return cgroup_css(cgrp, cft->ss->subsys_id);
 	return &cgrp->dummy_css;
 }
 
@@ -4241,7 +4241,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 
 	/* This cgroup is ready now */
 	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 		struct css_id *id = rcu_dereference_protected(css->id, true);
 
 		/*
@@ -4285,7 +4285,7 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	css->id = NULL;
 	if (cgrp == cgroup_dummy_top)
 		css->flags |= CSS_ROOT;
-	BUG_ON(cgrp->subsys[ss->subsys_id]);
+	BUG_ON(cgroup_css(cgrp, ss->subsys_id));
 	cgrp->subsys[ss->subsys_id] = css;
 
 	/*
@@ -4300,7 +4300,7 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 /* invoke ->css_online() on a new CSS and mark it online if successful */
 static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
-	struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+	struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 	int ret = 0;
 
 	lockdep_assert_held(&cgroup_mutex);
@@ -4315,7 +4315,7 @@ static int online_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 /* if the CSS is online, invoke ->css_offline() on it and mark it offline */
 static void offline_css(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
-	struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+	struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -4400,7 +4400,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	for_each_root_subsys(root, ss) {
 		struct cgroup_subsys_state *css;
 
-		css = ss->css_alloc(parent->subsys[ss->subsys_id]);
+		css = ss->css_alloc(cgroup_css(parent, ss->subsys_id));
 		if (IS_ERR(css)) {
 			err = PTR_ERR(css);
 			goto err_free_all;
@@ -4477,7 +4477,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 
 err_free_all:
 	for_each_root_subsys(root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 		if (css) {
 			percpu_ref_cancel_init(&css->refcnt);
@@ -4590,7 +4590,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 */
 	atomic_set(&cgrp->css_kill_cnt, 1);
 	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
 		/*
 		 * Killing would put the base ref, but we need to keep it
@@ -4676,7 +4676,7 @@ static void cgroup_offline_fn(struct work_struct *work)
 	 * destruction happens only after all css's are released.
 	 */
 	for_each_root_subsys(cgrp->root, ss)
-		css_put(cgrp->subsys[ss->subsys_id]);
+		css_put(cgroup_css(cgrp, ss->subsys_id));
 
 	/* delete this cgroup from parent->children */
 	list_del_rcu(&cgrp->sibling);
@@ -4741,7 +4741,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	/* Create the top cgroup state for this subsystem */
 	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
 	ss->root = &cgroup_dummy_root;
-	css = ss->css_alloc(cgroup_dummy_top->subsys[ss->subsys_id]);
+	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss->subsys_id));
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
 	init_cgroup_css(css, ss, cgroup_dummy_top);
@@ -4820,7 +4820,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 * struct, so this can happen first (i.e. before the dummy root
 	 * attachment).
 	 */
-	css = ss->css_alloc(cgroup_dummy_top->subsys[ss->subsys_id]);
+	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss->subsys_id));
 	if (IS_ERR(css)) {
 		/* failure case - need to deassign the cgroup_subsys[] slot. */
 		cgroup_subsys[ss->subsys_id] = NULL;
@@ -4936,7 +4936,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * the cgrp->subsys pointer to find their state. note that this
 	 * also takes care of freeing the css_id.
 	 */
-	ss->css_free(cgroup_dummy_top->subsys[ss->subsys_id]);
+	ss->css_free(cgroup_css(cgroup_dummy_top, ss->subsys_id));
 	cgroup_dummy_top->subsys[ss->subsys_id] = NULL;
 
 	mutex_unlock(&cgroup_mutex);
@@ -5562,8 +5562,8 @@ static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
 	struct css_id *child_id, *parent_id;
 
 	subsys_id = ss->subsys_id;
-	parent_css = parent->subsys[subsys_id];
-	child_css = child->subsys[subsys_id];
+	parent_css = cgroup_css(parent, subsys_id);
+	child_css = cgroup_css(child, subsys_id);
 	parent_id = rcu_dereference_protected(parent_css->id, true);
 	depth = parent_id->depth + 1;
 
@@ -5624,7 +5624,7 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
 
 	/* get cgroup */
 	cgrp = __d_cgrp(f->f_dentry);
-	css = cgrp->subsys[id];
+	css = cgroup_css(cgrp, id);
 	return css ? css : ERR_PTR(-ENOENT);
 }
 
-- 
1.8.3.1
