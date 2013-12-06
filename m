From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/7] cgroup: remove for_each_root_subsys()
Date: Fri,  6 Dec 2013 15:27:52 -0500
Message-ID: <1386361672-27791-8-git-send-email-tj@kernel.org>
References: <1386361672-27791-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1386361672-27791-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: vdavydov-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

After the previous patch which introduced for_each_css(),
for_each_root_subsys() only has two users left.  This patch replaces
it with for_each_subsys() + explicit subsys_mask testing and remove
for_each_root_subsys() along with cgroupfs_root->subsys_list handling.

This patch doesn't introduce any behavior changes.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h |  9 +--------
 kernel/cgroup.c        | 37 +++++++++++++++----------------------
 2 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8b9a594..cfaf416 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -319,9 +319,6 @@ struct cgroupfs_root {
 	/* Unique id for this hierarchy. */
 	int hierarchy_id;
 
-	/* A list running through the attached subsystems */
-	struct list_head subsys_list;
-
 	/* The root cgroup for this hierarchy */
 	struct cgroup top_cgroup;
 
@@ -617,12 +614,8 @@ struct cgroup_subsys {
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
 
-	/*
-	 * Link to parent, and list entry in parent's children.
-	 * Protected by cgroup_lock()
-	 */
+	/* link to parent, protected by cgroup_lock() */
 	struct cgroupfs_root *root;
-	struct list_head sibling;
 
 	/* list of cftype_sets */
 	struct list_head cftsets;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 329fde8..fb1193b 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -283,10 +283,6 @@ static int notify_on_release(const struct cgroup *cgrp)
 	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
 	     (((ss) = cgroup_subsys[i]) || true); (i)++)
 
-/* iterate each subsystem attached to a hierarchy */
-#define for_each_root_subsys(root, ss)					\
-	list_for_each_entry((ss), &(root)->subsys_list, sibling)
-
 /* iterate across the active hierarchies */
 #define for_each_active_root(root)					\
 	list_for_each_entry((root), &cgroup_roots, root_list)
@@ -1033,7 +1029,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 					   cgroup_css(cgroup_dummy_top, ss));
 			cgroup_css(cgrp, ss)->cgroup = cgrp;
 
-			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
 				ss->bind(cgroup_css(cgrp, ss));
@@ -1052,7 +1047,6 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			RCU_INIT_POINTER(cgrp->subsys[i], NULL);
 
 			cgroup_subsys[i]->root = &cgroup_dummy_root;
-			list_move(&ss->sibling, &cgroup_dummy_root.subsys_list);
 
 			/* subsystem is now free - drop reference on module */
 			module_put(ss->module);
@@ -1079,10 +1073,12 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 {
 	struct cgroupfs_root *root = dentry->d_sb->s_fs_info;
 	struct cgroup_subsys *ss;
+	int ssid;
 
 	mutex_lock(&cgroup_root_mutex);
-	for_each_root_subsys(root, ss)
-		seq_printf(seq, ",%s", ss->name);
+	for_each_subsys(ss, ssid)
+		if (root->subsys_mask & (1 << ssid))
+			seq_printf(seq, ",%s", ss->name);
 	if (root->flags & CGRP_ROOT_SANE_BEHAVIOR)
 		seq_puts(seq, ",sane_behavior");
 	if (root->flags & CGRP_ROOT_NOPREFIX)
@@ -1352,7 +1348,6 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 
-	INIT_LIST_HEAD(&root->subsys_list);
 	INIT_LIST_HEAD(&root->root_list);
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
@@ -4151,7 +4146,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	struct cgroup *cgrp;
 	struct cgroup_name *name;
 	struct cgroupfs_root *root = parent->root;
-	int err = 0;
+	int ssid, err = 0;
 	struct cgroup_subsys *ss;
 	struct super_block *sb = root->sb;
 
@@ -4237,10 +4232,12 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 		goto err_destroy;
 
 	/* let's create and online css's */
-	for_each_root_subsys(root, ss) {
-		err = create_css(cgrp, ss);
-		if (err)
-			goto err_destroy;
+	for_each_subsys(ss, ssid) {
+		if (root->subsys_mask & (1 << ssid)) {
+			err = create_css(cgrp, ss);
+			if (err)
+				goto err_destroy;
+		}
 	}
 
 	mutex_unlock(&cgroup_mutex);
@@ -4536,7 +4533,6 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	cgroup_init_cftsets(ss);
 
 	/* Create the top cgroup state for this subsystem */
-	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
 	ss->root = &cgroup_dummy_root;
 	css = ss->css_alloc(cgroup_css(cgroup_dummy_top, ss));
 	/* We don't handle early failures gracefully */
@@ -4626,7 +4622,6 @@ int __init_or_module cgroup_load_subsys(struct cgroup_subsys *ss)
 		return PTR_ERR(css);
 	}
 
-	list_add(&ss->sibling, &cgroup_dummy_root.subsys_list);
 	ss->root = &cgroup_dummy_root;
 
 	/* our new subsystem will be attached to the dummy hierarchy. */
@@ -4702,9 +4697,6 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	/* deassign the subsys_id */
 	cgroup_subsys[ss->subsys_id] = NULL;
 
-	/* remove subsystem from the dummy root's list of subsystems */
-	list_del_init(&ss->sibling);
-
 	/*
 	 * disentangle the css from all css_sets attached to the dummy
 	 * top. as in loading, we need to pay our respects to the hashtable
@@ -4901,11 +4893,12 @@ int proc_cgroup_show(struct seq_file *m, void *v)
 	for_each_active_root(root) {
 		struct cgroup_subsys *ss;
 		struct cgroup *cgrp;
-		int count = 0;
+		int ssid, count = 0;
 
 		seq_printf(m, "%d:", root->hierarchy_id);
-		for_each_root_subsys(root, ss)
-			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
+		for_each_subsys(ss, ssid)
+			if (root->subsys_mask & (1 << ssid))
+				seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
 		if (strlen(root->name))
 			seq_printf(m, "%sname=%s", count ? "," : "",
 				   root->name);
-- 
1.8.4.2
