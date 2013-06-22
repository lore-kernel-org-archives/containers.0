From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/6] cgroup: prefix global variables with "cgroup_"
Date: Fri, 21 Jun 2013 18:34:10 -0700
Message-ID: <1371864854-28364-3-git-send-email-tj__22397.5407578566$1371864889$gmane$org@kernel.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371864854-28364-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Global variable names in kernel/cgroup.c are asking for trouble -
subsys, roots, rootnode and so on.  Rename them to have "cgroup_"
prefix.

* s/subsys/cgroup_subsys/

* s/rootnode/cgroup_dummy_root/

* s/dummytop/cgroup_cummy_top/

* s/roots/cgroup_roots/

* s/root_count/cgroup_root_count/

This patch is purely cosmetic.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 153 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 77 insertions(+), 76 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 766be3c..dbb4418 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -96,16 +96,19 @@ static DEFINE_MUTEX(cgroup_root_mutex);
  */
 #define SUBSYS(_x) [_x ## _subsys_id] = &_x ## _subsys,
 #define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
-static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
+static struct cgroup_subsys *cgroup_subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
 };
 
 /*
- * The "rootnode" hierarchy is the "dummy hierarchy", reserved for the
- * subsystems that are otherwise unattached - it never has more than a
- * single cgroup, and all tasks are part of that cgroup.
+ * The dummy hierarchy, reserved for the subsystems that are otherwise
+ * unattached - it never has more than a single cgroup, and all tasks are
+ * part of that cgroup.
  */
-static struct cgroupfs_root rootnode;
+static struct cgroupfs_root cgroup_dummy_root;
+
+/* dummy_top is a shorthand for the dummy hierarchy's top cgroup */
+static struct cgroup * const cgroup_dummy_top = &cgroup_dummy_root.top_cgroup;
 
 /*
  * cgroupfs file entry, pointed to from leaf dentry->d_fsdata.
@@ -183,8 +186,8 @@ struct cgroup_event {
 
 /* The list of hierarchy roots */
 
-static LIST_HEAD(roots);
-static int root_count;
+static LIST_HEAD(cgroup_roots);
+static int cgroup_root_count;
 
 /*
  * Hierarchy ID allocation and mapping.  It follows the same exclusion
@@ -193,9 +196,6 @@ static int root_count;
  */
 static DEFINE_IDR(cgroup_hierarchy_idr);
 
-/* dummytop is a shorthand for the dummy hierarchy's top cgroup */
-#define dummytop (&rootnode.top_cgroup)
-
 static struct cgroup_name root_cgroup_name = { .name = "/" };
 
 /*
@@ -268,7 +268,7 @@ list_for_each_entry(_ss, &_root->subsys_list, sibling)
 
 /* for_each_active_root() allows you to iterate across the active hierarchies */
 #define for_each_active_root(_root) \
-list_for_each_entry(_root, &roots, root_list)
+list_for_each_entry(_root, &cgroup_roots, root_list)
 
 static inline struct cgroup *__d_cgrp(struct dentry *dentry)
 {
@@ -650,7 +650,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 		return NULL;
 
 	/* Allocate all the cgrp_cset_link objects that we'll need */
-	if (allocate_cgrp_cset_links(root_count, &tmp_links) < 0) {
+	if (allocate_cgrp_cset_links(cgroup_root_count, &tmp_links) < 0) {
 		kfree(cset);
 		return NULL;
 	}
@@ -1000,7 +1000,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	/* Check that any added subsystems are currently free */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		unsigned long bit = 1UL << i;
-		struct cgroup_subsys *ss = subsys[i];
+		struct cgroup_subsys *ss = cgroup_subsys[i];
 		if (!(bit & added_mask))
 			continue;
 		/*
@@ -1009,7 +1009,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		 * ensure that subsystems won't disappear once selected.
 		 */
 		BUG_ON(ss == NULL);
-		if (ss->root != &rootnode) {
+		if (ss->root != &cgroup_dummy_root) {
 			/* Subsystem isn't free */
 			return -EBUSY;
 		}
@@ -1024,15 +1024,15 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
+		struct cgroup_subsys *ss = cgroup_subsys[i];
 		unsigned long bit = 1UL << i;
 		if (bit & added_mask) {
 			/* We're binding this subsystem to this hierarchy */
 			BUG_ON(ss == NULL);
 			BUG_ON(cgrp->subsys[i]);
-			BUG_ON(!dummytop->subsys[i]);
-			BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
-			cgrp->subsys[i] = dummytop->subsys[i];
+			BUG_ON(!cgroup_dummy_top->subsys[i]);
+			BUG_ON(cgroup_dummy_top->subsys[i]->cgroup != cgroup_dummy_top);
+			cgrp->subsys[i] = cgroup_dummy_top->subsys[i];
 			cgrp->subsys[i]->cgroup = cgrp;
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
@@ -1042,14 +1042,14 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		} else if (bit & removed_mask) {
 			/* We're removing this subsystem */
 			BUG_ON(ss == NULL);
-			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
+			BUG_ON(cgrp->subsys[i] != cgroup_dummy_top->subsys[i]);
 			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 			if (ss->bind)
-				ss->bind(dummytop);
-			dummytop->subsys[i]->cgroup = dummytop;
+				ss->bind(cgroup_dummy_top);
+			cgroup_dummy_top->subsys[i]->cgroup = cgroup_dummy_top;
 			cgrp->subsys[i] = NULL;
-			subsys[i]->root = &rootnode;
-			list_move(&ss->sibling, &rootnode.subsys_list);
+			cgroup_subsys[i]->root = &cgroup_dummy_root;
+			list_move(&ss->sibling, &cgroup_dummy_root.subsys_list);
 			/* subsystem is now free - drop reference on module */
 			module_put(ss->module);
 		} else if (bit & final_subsys_mask) {
@@ -1112,10 +1112,10 @@ struct cgroup_sb_opts {
 };
 
 /*
- * Convert a hierarchy specifier into a bitmask of subsystems and flags. Call
- * with cgroup_mutex held to protect the subsys[] array. This function takes
- * refcounts on subsystems to be used, unless it returns error, in which case
- * no refcounts are taken.
+ * Convert a hierarchy specifier into a bitmask of subsystems and
+ * flags. Call with cgroup_mutex held to protect the cgroup_subsys[]
+ * array. This function takes refcounts on subsystems to be used, unless it
+ * returns error, in which case no refcounts are taken.
  */
 static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 {
@@ -1201,7 +1201,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 		}
 
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
+			struct cgroup_subsys *ss = cgroup_subsys[i];
 			if (ss == NULL)
 				continue;
 			if (strcmp(token, ss->name))
@@ -1228,7 +1228,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 	 */
 	if (all_ss || (!one_ss && !opts->none && !opts->name)) {
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
+			struct cgroup_subsys *ss = cgroup_subsys[i];
 			if (ss == NULL)
 				continue;
 			if (ss->disabled)
@@ -1284,7 +1284,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 
 		if (!(bit & opts->subsys_mask))
 			continue;
-		if (!try_module_get(subsys[i]->module)) {
+		if (!try_module_get(cgroup_subsys[i]->module)) {
 			module_pin_failed = true;
 			break;
 		}
@@ -1301,7 +1301,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 
 			if (!(bit & opts->subsys_mask))
 				continue;
-			module_put(subsys[i]->module);
+			module_put(cgroup_subsys[i]->module);
 		}
 		return -ENOENT;
 	}
@@ -1317,7 +1317,7 @@ static void drop_parsed_module_refcounts(unsigned long subsys_mask)
 
 		if (!(bit & subsys_mask))
 			continue;
-		module_put(subsys[i]->module);
+		module_put(cgroup_subsys[i]->module);
 	}
 }
 
@@ -1648,8 +1648,8 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		/* EBUSY should be the only error here */
 		BUG_ON(ret);
 
-		list_add(&root->root_list, &roots);
-		root_count++;
+		list_add(&root->root_list, &cgroup_roots);
+		cgroup_root_count++;
 
 		sb->s_root->d_fsdata = root_cgrp;
 		root->top_cgroup.dentry = sb->s_root;
@@ -1746,7 +1746,7 @@ static void cgroup_kill_sb(struct super_block *sb) {
 
 	if (!list_empty(&root->root_list)) {
 		list_del(&root->root_list);
-		root_count--;
+		cgroup_root_count--;
 	}
 
 	cgroup_exit_root_id(root);
@@ -2810,7 +2810,7 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 	u64 update_before;
 
 	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
-	if (!cfts || ss->root == &rootnode ||
+	if (!cfts || ss->root == &cgroup_dummy_root ||
 	    !atomic_inc_not_zero(&sb->s_active)) {
 		mutex_unlock(&cgroup_mutex);
 		return;
@@ -4191,7 +4191,7 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 	css->cgroup = cgrp;
 	css->flags = 0;
 	css->id = NULL;
-	if (cgrp == dummytop)
+	if (cgrp == cgroup_dummy_top)
 		css->flags |= CSS_ROOT;
 	BUG_ON(cgrp->subsys[ss->subsys_id]);
 	cgrp->subsys[ss->subsys_id] = css;
@@ -4620,12 +4620,12 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	cgroup_init_cftsets(ss);
 
 	/* Create the top cgroup state for this subsystem */
-	list_add(&ss->sibling, &rootnode.subsys_list);
-	ss->root = &rootnode;
-	css = ss->css_alloc(dummytop);
+	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
+	ss->root = &cgroup_dummy_root;
+	css = ss->css_alloc(cgroup_dummy_top);
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
-	init_cgroup_css(css, ss, dummytop);
+	init_cgroup_css(css, ss, cgroup_dummy_top);
 
 	/* Update the init_css_set to contain a subsys
 	 * pointer to this state - since the subsystem is
@@ -4640,7 +4640,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	 * need to invoke fork callbacks here. */
 	BUG_ON(!list_empty(&init_task.tasks));
 
-	BUG_ON(online_css(ss, dummytop));
+	BUG_ON(online_css(ss, cgroup_dummy_top));
 
 	mutex_unlock(&cgroup_mutex);
 
@@ -4686,7 +4686,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	 */
 	if (ss->module == NULL) {
 		/* a sanity check */
-		BUG_ON(subsys[ss->subsys_id] != ss);
+		BUG_ON(cgroup_subsys[ss->subsys_id] != ss);
 		return 0;
 	}
 
@@ -4694,26 +4694,26 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	cgroup_init_cftsets(ss);
 
 	mutex_lock(&cgroup_mutex);
-	subsys[ss->subsys_id] = ss;
+	cgroup_subsys[ss->subsys_id] = ss;
 
 	/*
 	 * no ss->css_alloc seems to need anything important in the ss
-	 * struct, so this can happen first (i.e. before the rootnode
+	 * struct, so this can happen first (i.e. before the dummy root
 	 * attachment).
 	 */
-	css = ss->css_alloc(dummytop);
+	css = ss->css_alloc(cgroup_dummy_top);
 	if (IS_ERR(css)) {
-		/* failure case - need to deassign the subsys[] slot. */
-		subsys[ss->subsys_id] = NULL;
+		/* failure case - need to deassign the cgroup_subsys[] slot. */
+		cgroup_subsys[ss->subsys_id] = NULL;
 		mutex_unlock(&cgroup_mutex);
 		return PTR_ERR(css);
 	}
 
-	list_add(&ss->sibling, &rootnode.subsys_list);
-	ss->root = &rootnode;
+	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
+	ss->root = &cgroup_dummy_root;
 
 	/* our new subsystem will be attached to the dummy hierarchy. */
-	init_cgroup_css(css, ss, dummytop);
+	init_cgroup_css(css, ss, cgroup_dummy_top);
 	/* init_idr must be after init_cgroup_css because it sets css->id. */
 	if (ss->use_id) {
 		ret = cgroup_init_idr(ss, css);
@@ -4744,7 +4744,7 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 	}
 	write_unlock(&css_set_lock);
 
-	ret = online_css(ss, dummytop);
+	ret = online_css(ss, cgroup_dummy_top);
 	if (ret)
 		goto err_unload;
 
@@ -4779,27 +4779,28 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * try_module_get in parse_cgroupfs_options should ensure that it
 	 * doesn't start being used while we're killing it off.
 	 */
-	BUG_ON(ss->root != &rootnode);
+	BUG_ON(ss->root != &cgroup_dummy_root);
 
 	mutex_lock(&cgroup_mutex);
 
-	offline_css(ss, dummytop);
+	offline_css(ss, cgroup_dummy_top);
 
 	if (ss->use_id)
 		idr_destroy(&ss->idr);
 
 	/* deassign the subsys_id */
-	subsys[ss->subsys_id] = NULL;
+	cgroup_subsys[ss->subsys_id] = NULL;
 
-	/* remove subsystem from rootnode's list of subsystems */
+	/* remove subsystem from the dummy root's list of subsystems */
 	list_del_init(&ss->sibling);
 
 	/*
-	 * disentangle the css from all css_sets attached to the dummytop. as
-	 * in loading, we need to pay our respects to the hashtable gods.
+	 * disentangle the css from all css_sets attached to the dummy
+	 * top. as in loading, we need to pay our respects to the hashtable
+	 * gods.
 	 */
 	write_lock(&css_set_lock);
-	list_for_each_entry(link, &dummytop->cset_links, cset_link) {
+	list_for_each_entry(link, &cgroup_dummy_top->cset_links, cset_link) {
 		struct css_set *cset = link->cset;
 		unsigned long key;
 
@@ -4811,13 +4812,13 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	write_unlock(&css_set_lock);
 
 	/*
-	 * remove subsystem's css from the dummytop and free it - need to
-	 * free before marking as null because ss->css_free needs the
-	 * cgrp->subsys pointer to find their state. note that this also
-	 * takes care of freeing the css_id.
+	 * remove subsystem's css from the cgroup_dummy_top and free it -
+	 * need to free before marking as null because ss->css_free needs
+	 * the cgrp->subsys pointer to find their state. note that this
+	 * also takes care of freeing the css_id.
 	 */
-	ss->css_free(dummytop);
-	dummytop->subsys[ss->subsys_id] = NULL;
+	ss->css_free(cgroup_dummy_top);
+	cgroup_dummy_top->subsys[ss->subsys_id] = NULL;
 
 	mutex_unlock(&cgroup_mutex);
 }
@@ -4837,17 +4838,17 @@ int __init cgroup_init_early(void)
 	INIT_LIST_HEAD(&init_css_set.tasks);
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
-	init_cgroup_root(&rootnode);
-	root_count = 1;
+	init_cgroup_root(&cgroup_dummy_root);
+	cgroup_root_count = 1;
 	RCU_INIT_POINTER(init_task.cgroups, &init_css_set);
 
 	init_cgrp_cset_link.cset = &init_css_set;
-	init_cgrp_cset_link.cgrp = dummytop;
-	list_add(&init_cgrp_cset_link.cset_link, &rootnode.top_cgroup.cset_links);
+	init_cgrp_cset_link.cgrp = cgroup_dummy_top;
+	list_add(&init_cgrp_cset_link.cset_link, &cgroup_dummy_top->cset_links);
 	list_add(&init_cgrp_cset_link.cgrp_link, &init_css_set.cgrp_links);
 
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
+		struct cgroup_subsys *ss = cgroup_subsys[i];
 
 		/* at bootup time, we don't worry about modular subsystems */
 		if (!ss || ss->module)
@@ -4886,7 +4887,7 @@ int __init cgroup_init(void)
 		return err;
 
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
+		struct cgroup_subsys *ss = cgroup_subsys[i];
 
 		/* at bootup time, we don't worry about modular subsystems */
 		if (!ss || ss->module)
@@ -4905,7 +4906,7 @@ int __init cgroup_init(void)
 	mutex_lock(&cgroup_mutex);
 	mutex_lock(&cgroup_root_mutex);
 
-	BUG_ON(cgroup_init_root_id(&rootnode));
+	BUG_ON(cgroup_init_root_id(&cgroup_dummy_root));
 
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
@@ -5009,7 +5010,7 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
 	 */
 	mutex_lock(&cgroup_mutex);
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-		struct cgroup_subsys *ss = subsys[i];
+		struct cgroup_subsys *ss = cgroup_subsys[i];
 		if (ss == NULL)
 			continue;
 		seq_printf(m, "%s\t%d\t%d\t%d\n",
@@ -5106,7 +5107,7 @@ void cgroup_post_fork(struct task_struct *child)
 		 * can't touch that.
 		 */
 		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
+			struct cgroup_subsys *ss = cgroup_subsys[i];
 
 			if (ss->fork)
 				ss->fork(child);
@@ -5177,7 +5178,7 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 		 * subsystems, see cgroup_post_fork() for details.
 		 */
 		for (i = 0; i < CGROUP_BUILTIN_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
+			struct cgroup_subsys *ss = cgroup_subsys[i];
 
 			if (ss->exit) {
 				struct cgroup *old_cgrp = cset->subsys[i]->cgroup;
@@ -5295,7 +5296,7 @@ static int __init cgroup_disable(char *str)
 		if (!*token)
 			continue;
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
+			struct cgroup_subsys *ss = cgroup_subsys[i];
 
 			/*
 			 * cgroup_disable, being at boot time, can't
-- 
1.8.2.1
