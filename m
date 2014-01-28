From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/13] cgroup: relocate functions in preparation of kernfs
	conversion
Date: Tue, 28 Jan 2014 18:54:44 -0500
Message-ID: <1390953285-16360-13-git-send-email-tj__1854.0370780558$1390953388$gmane$org@kernel.org>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953285-16360-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Relocate cgroup_init/exit_root_id(), cgroup_free_root(),
cgroup_kill_sb() and cgroup_file_name() in preparation of kernfs
conversion.

These are pure relocations to make kernfs conversion easier to follow.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 232 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 117 insertions(+), 115 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0c5d1d1..228ed88 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -170,6 +170,8 @@ static int need_forkexit_callback __read_mostly;
 static struct cftype cgroup_base_files[];
 
 static void cgroup_put(struct cgroup *cgrp);
+static int rebind_subsystems(struct cgroupfs_root *root,
+			     unsigned long added_mask, unsigned removed_mask);
 static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
@@ -690,6 +692,42 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	return cset;
 }
 
+static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
+{
+	int id;
+
+	lockdep_assert_held(&cgroup_mutex);
+
+	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, start, end,
+			      GFP_KERNEL);
+	if (id < 0)
+		return id;
+
+	root->hierarchy_id = id;
+	return 0;
+}
+
+static void cgroup_exit_root_id(struct cgroupfs_root *root)
+{
+	lockdep_assert_held(&cgroup_mutex);
+
+	if (root->hierarchy_id) {
+		idr_remove(&cgroup_hierarchy_idr, root->hierarchy_id);
+		root->hierarchy_id = 0;
+	}
+}
+
+static void cgroup_free_root(struct cgroupfs_root *root)
+{
+	if (root) {
+		/* hierarhcy ID shoulid already have been released */
+		WARN_ON_ONCE(root->hierarchy_id);
+
+		idr_destroy(&root->cgroup_idr);
+		kfree(root);
+	}
+}
+
 static void cgroup_get_root(struct cgroupfs_root *root)
 {
 	atomic_inc(&root->sb->s_active);
@@ -700,6 +738,59 @@ static void cgroup_put_root(struct cgroupfs_root *root)
 	deactivate_super(root->sb);
 }
 
+static void cgroup_kill_sb(struct super_block *sb)
+{
+	struct cgroupfs_root *root = sb->s_fs_info;
+	struct cgroup *cgrp = &root->top_cgroup;
+	struct cgrp_cset_link *link, *tmp_link;
+	int ret;
+
+	BUG_ON(!root);
+
+	BUG_ON(root->number_of_cgroups != 1);
+	BUG_ON(!list_empty(&cgrp->children));
+
+	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
+	mutex_lock(&cgroup_tree_mutex);
+	mutex_lock(&cgroup_mutex);
+
+	/* Rebind all subsystems back to the default hierarchy */
+	if (root->flags & CGRP_ROOT_SUBSYS_BOUND) {
+		ret = rebind_subsystems(root, 0, root->subsys_mask);
+		/* Shouldn't be able to fail ... */
+		BUG_ON(ret);
+	}
+
+	/*
+	 * Release all the links from cset_links to this hierarchy's
+	 * root cgroup
+	 */
+	write_lock(&css_set_lock);
+
+	list_for_each_entry_safe(link, tmp_link, &cgrp->cset_links, cset_link) {
+		list_del(&link->cset_link);
+		list_del(&link->cgrp_link);
+		kfree(link);
+	}
+	write_unlock(&css_set_lock);
+
+	if (!list_empty(&root->root_list)) {
+		list_del(&root->root_list);
+		cgroup_root_count--;
+	}
+
+	cgroup_exit_root_id(root);
+
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
+	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
+
+	simple_xattrs_free(&cgrp->xattrs);
+
+	kill_litter_super(sb);
+	cgroup_free_root(root);
+}
+
 /*
  * Return the cgroup for "task" from the given hierarchy. Must be
  * called with cgroup_mutex held.
@@ -846,6 +937,32 @@ static char *cgroup_file_name(struct cgroup *cgrp, const struct cftype *cft,
 	return buf;
 }
 
+/**
+ * cgroup_file_mode - deduce file mode of a control file
+ * @cft: the control file in question
+ *
+ * returns cft->mode if ->mode is not 0
+ * returns S_IRUGO|S_IWUSR if it has both a read and a write handler
+ * returns S_IRUGO if it has only a read handler
+ * returns S_IWUSR if it has only a write hander
+ */
+static umode_t cgroup_file_mode(const struct cftype *cft)
+{
+	umode_t mode = 0;
+
+	if (cft->mode)
+		return cft->mode;
+
+	if (cft->read_u64 || cft->read_s64 || cft->seq_show)
+		mode |= S_IRUGO;
+
+	if (cft->write_u64 || cft->write_s64 || cft->write_string ||
+	    cft->trigger)
+		mode |= S_IWUSR;
+
+	return mode;
+}
+
 static void cgroup_free_fn(struct work_struct *work)
 {
 	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
@@ -1356,31 +1473,6 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	idr_init(&root->cgroup_idr);
 }
 
-static int cgroup_init_root_id(struct cgroupfs_root *root, int start, int end)
-{
-	int id;
-
-	lockdep_assert_held(&cgroup_mutex);
-
-	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, start, end,
-			      GFP_KERNEL);
-	if (id < 0)
-		return id;
-
-	root->hierarchy_id = id;
-	return 0;
-}
-
-static void cgroup_exit_root_id(struct cgroupfs_root *root)
-{
-	lockdep_assert_held(&cgroup_mutex);
-
-	if (root->hierarchy_id) {
-		idr_remove(&cgroup_hierarchy_idr, root->hierarchy_id);
-		root->hierarchy_id = 0;
-	}
-}
-
 static int cgroup_test_super(struct super_block *sb, void *data)
 {
 	struct cgroup_sb_opts *opts = data;
@@ -1430,17 +1522,6 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	return root;
 }
 
-static void cgroup_free_root(struct cgroupfs_root *root)
-{
-	if (root) {
-		/* hierarhcy ID shoulid already have been released */
-		WARN_ON_ONCE(root->hierarchy_id);
-
-		idr_destroy(&root->cgroup_idr);
-		kfree(root);
-	}
-}
-
 static int cgroup_set_super(struct super_block *sb, void *data)
 {
 	int ret;
@@ -1682,59 +1763,6 @@ out_unlock:
 		return ERR_PTR(ret);
 }
 
-static void cgroup_kill_sb(struct super_block *sb)
-{
-	struct cgroupfs_root *root = sb->s_fs_info;
-	struct cgroup *cgrp = &root->top_cgroup;
-	struct cgrp_cset_link *link, *tmp_link;
-	int ret;
-
-	BUG_ON(!root);
-
-	BUG_ON(root->number_of_cgroups != 1);
-	BUG_ON(!list_empty(&cgrp->children));
-
-	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
-	mutex_lock(&cgroup_tree_mutex);
-	mutex_lock(&cgroup_mutex);
-
-	/* Rebind all subsystems back to the default hierarchy */
-	if (root->flags & CGRP_ROOT_SUBSYS_BOUND) {
-		ret = rebind_subsystems(root, 0, root->subsys_mask);
-		/* Shouldn't be able to fail ... */
-		BUG_ON(ret);
-	}
-
-	/*
-	 * Release all the links from cset_links to this hierarchy's
-	 * root cgroup
-	 */
-	write_lock(&css_set_lock);
-
-	list_for_each_entry_safe(link, tmp_link, &cgrp->cset_links, cset_link) {
-		list_del(&link->cset_link);
-		list_del(&link->cgrp_link);
-		kfree(link);
-	}
-	write_unlock(&css_set_lock);
-
-	if (!list_empty(&root->root_list)) {
-		list_del(&root->root_list);
-		cgroup_root_count--;
-	}
-
-	cgroup_exit_root_id(root);
-
-	mutex_unlock(&cgroup_mutex);
-	mutex_unlock(&cgroup_tree_mutex);
-	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
-
-	simple_xattrs_free(&cgrp->xattrs);
-
-	kill_litter_super(sb);
-	cgroup_free_root(root);
-}
-
 static struct file_system_type cgroup_fs_type = {
 	.name = "cgroup",
 	.mount = cgroup_mount,
@@ -2610,32 +2638,6 @@ static int cgroup_create_file(struct dentry *dentry, umode_t mode,
 	return 0;
 }
 
-/**
- * cgroup_file_mode - deduce file mode of a control file
- * @cft: the control file in question
- *
- * returns cft->mode if ->mode is not 0
- * returns S_IRUGO|S_IWUSR if it has both a read and a write handler
- * returns S_IRUGO if it has only a read handler
- * returns S_IWUSR if it has only a write hander
- */
-static umode_t cgroup_file_mode(const struct cftype *cft)
-{
-	umode_t mode = 0;
-
-	if (cft->mode)
-		return cft->mode;
-
-	if (cft->read_u64 || cft->read_s64 || cft->seq_show)
-		mode |= S_IRUGO;
-
-	if (cft->write_u64 || cft->write_s64 || cft->write_string ||
-	    cft->trigger)
-		mode |= S_IWUSR;
-
-	return mode;
-}
-
 static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 {
 	struct dentry *dir = cgrp->dentry;
-- 
1.8.5.3
