From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/13] cgroup: factor out cgroup_setup_root() from
	cgroup_mount()
Date: Tue, 28 Jan 2014 18:54:37 -0500
Message-ID: <1390953285-16360-6-git-send-email-tj@kernel.org>
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

Factor out new root initialization into cgroup_setup_root() from
cgroup_mount().  This makes it easier to follow and will ease kernfs
conversion.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 211 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 113 insertions(+), 98 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2349698..bdbd9ad 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1446,17 +1446,126 @@ static int cgroup_get_rootdir(struct super_block *sb)
 	return 0;
 }
 
+static int cgroup_setup_root(struct cgroupfs_root *root)
+{
+	LIST_HEAD(tmp_links);
+	struct super_block *sb = root->sb;
+	struct cgroup *root_cgrp = &root->top_cgroup;
+	struct cgroupfs_root *existing_root;
+	struct css_set *cset;
+	struct inode *inode;
+	const struct cred *cred;
+	int i, ret;
+
+	lockdep_assert_held(&cgroup_tree_mutex);
+	lockdep_assert_held(&cgroup_mutex);
+	BUG_ON(sb->s_root != NULL);
+
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
+
+	ret = cgroup_get_rootdir(sb);
+	if (ret) {
+		mutex_lock(&cgroup_tree_mutex);
+		mutex_lock(&cgroup_mutex);
+		return ret;
+	}
+	inode = sb->s_root->d_inode;
+
+	mutex_lock(&inode->i_mutex);
+	mutex_lock(&cgroup_tree_mutex);
+	mutex_lock(&cgroup_mutex);
+
+	ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
+	if (ret < 0)
+		goto out_unlock;
+	root_cgrp->id = ret;
+
+	/* check for name clashes with existing mounts */
+	ret = -EBUSY;
+	if (strlen(root->name))
+		for_each_active_root(existing_root)
+			if (!strcmp(existing_root->name, root->name))
+				goto out_unlock;
+
+	/*
+	 * We're accessing css_set_count without locking css_set_lock here,
+	 * but that's OK - it can only be increased by someone holding
+	 * cgroup_lock, and that's us. The worst that can happen is that we
+	 * have some link structures left over
+	 */
+	ret = allocate_cgrp_cset_links(css_set_count, &tmp_links);
+	if (ret)
+		goto out_unlock;
+
+	/* ID 0 is reserved for dummy root, 1 for unified hierarchy */
+	ret = cgroup_init_root_id(root, 2, 0);
+	if (ret)
+		goto out_unlock;
+
+	sb->s_root->d_fsdata = root_cgrp;
+	root_cgrp->dentry = sb->s_root;
+
+	/*
+	 * We're inside get_sb() and will call lookup_one_len() to create
+	 * the root files, which doesn't work if SELinux is in use.  The
+	 * following cred dancing somehow works around it.  See 2ce9738ba
+	 * ("cgroupfs: use init_cred when populating new cgroupfs mount")
+	 * for more details.
+	 */
+	cred = override_creds(&init_cred);
+
+	ret = cgroup_addrm_files(root_cgrp, cgroup_base_files, true);
+	if (ret)
+		goto rm_base_files;
+
+	ret = rebind_subsystems(root, root->subsys_mask, 0);
+	if (ret)
+		goto rm_base_files;
+
+	revert_creds(cred);
+
+	/*
+	 * There must be no failure case after here, since rebinding takes
+	 * care of subsystems' refcounts, which are explicitly dropped in
+	 * the failure exit path.
+	 */
+	list_add(&root->root_list, &cgroup_roots);
+	cgroup_root_count++;
+
+	/*
+	 * Link the top cgroup in this hierarchy into all the css_set
+	 * objects.
+	 */
+	write_lock(&css_set_lock);
+	hash_for_each(css_set_table, i, cset, hlist)
+		link_css_set(&tmp_links, cset, root_cgrp);
+	write_unlock(&css_set_lock);
+
+	BUG_ON(!list_empty(&root_cgrp->children));
+	BUG_ON(root->number_of_cgroups != 1);
+
+	ret = 0;
+	goto out_unlock;
+
+rm_base_files:
+	cgroup_addrm_files(&root->top_cgroup, cgroup_base_files, false);
+	revert_creds(cred);
+	cgroup_exit_root_id(root);
+out_unlock:
+	mutex_unlock(&inode->i_mutex);
+	free_cgrp_cset_links(&tmp_links);
+	return ret;
+}
+
 static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			 int flags, const char *unused_dev_name,
 			 void *data)
 {
-	LIST_HEAD(tmp_links);
 	struct super_block *sb = NULL;
-	struct inode *inode = NULL;
 	struct cgroupfs_root *root = NULL;
 	struct cgroup_sb_opts opts;
 	struct cgroupfs_root *new_root;
-	const struct cred *cred;
 	int ret;
 
 	mutex_lock(&cgroup_tree_mutex);
@@ -1493,94 +1602,9 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	root = sb->s_fs_info;
 	BUG_ON(!root);
 	if (root == opts.new_root) {
-		/* We used the new root structure, so this is a new hierarchy */
-		struct cgroup *root_cgrp = &root->top_cgroup;
-		struct cgroupfs_root *existing_root;
-		int i;
-		struct css_set *cset;
-
-		BUG_ON(sb->s_root != NULL);
-
-		mutex_unlock(&cgroup_mutex);
-		mutex_unlock(&cgroup_tree_mutex);
-
-		ret = cgroup_get_rootdir(sb);
+		ret = cgroup_setup_root(root);
 		if (ret)
 			goto out_unlock;
-		inode = sb->s_root->d_inode;
-
-		mutex_lock(&inode->i_mutex);
-		mutex_lock(&cgroup_tree_mutex);
-		mutex_lock(&cgroup_mutex);
-
-		ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
-		if (ret < 0)
-			goto out_unlock;
-		root_cgrp->id = ret;
-
-		/* Check for name clashes with existing mounts */
-		ret = -EBUSY;
-		if (strlen(root->name))
-			for_each_active_root(existing_root)
-				if (!strcmp(existing_root->name, root->name))
-					goto out_unlock;
-
-		/*
-		 * We're accessing css_set_count without locking
-		 * css_set_lock here, but that's OK - it can only be
-		 * increased by someone holding cgroup_lock, and
-		 * that's us. The worst that can happen is that we
-		 * have some link structures left over
-		 */
-		ret = allocate_cgrp_cset_links(css_set_count, &tmp_links);
-		if (ret)
-			goto out_unlock;
-
-		/* ID 0 is reserved for dummy root, 1 for unified hierarchy */
-		ret = cgroup_init_root_id(root, 2, 0);
-		if (ret)
-			goto out_unlock;
-
-		sb->s_root->d_fsdata = root_cgrp;
-		root_cgrp->dentry = sb->s_root;
-
-		/*
-		 * We're inside get_sb() and will call lookup_one_len() to
-		 * create the root files, which doesn't work if SELinux is
-		 * in use.  The following cred dancing somehow works around
-		 * it.  See 2ce9738ba ("cgroupfs: use init_cred when
-		 * populating new cgroupfs mount") for more details.
-		 */
-		cred = override_creds(&init_cred);
-
-		ret = cgroup_addrm_files(root_cgrp, cgroup_base_files, true);
-		if (ret)
-			goto rm_base_files;
-
-		ret = rebind_subsystems(root, root->subsys_mask, 0);
-		if (ret)
-			goto rm_base_files;
-
-		revert_creds(cred);
-
-		/*
-		 * There must be no failure case after here, since rebinding
-		 * takes care of subsystems' refcounts, which are explicitly
-		 * dropped in the failure exit path.
-		 */
-
-		list_add(&root->root_list, &cgroup_roots);
-		cgroup_root_count++;
-
-		/* Link the top cgroup in this hierarchy into all
-		 * the css_set objects */
-		write_lock(&css_set_lock);
-		hash_for_each(css_set_table, i, cset, hlist)
-			link_css_set(&tmp_links, cset, root_cgrp);
-		write_unlock(&css_set_lock);
-
-		BUG_ON(!list_empty(&root_cgrp->children));
-		BUG_ON(root->number_of_cgroups != 1);
 	} else {
 		/*
 		 * We re-used an existing hierarchy - the new root (if
@@ -1600,22 +1624,13 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	}
 
 	ret = 0;
-	goto out_unlock;
-
-rm_base_files:
-	cgroup_addrm_files(&root->top_cgroup, cgroup_base_files, false);
-	revert_creds(cred);
-	cgroup_exit_root_id(root);
 out_unlock:
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-	if (inode)
-		mutex_unlock(&inode->i_mutex);
 
 	if (ret && !IS_ERR_OR_NULL(sb))
 		deactivate_locked_super(sb);
 
-	free_cgrp_cset_links(&tmp_links);
 	kfree(opts.release_agent);
 	kfree(opts.name);
 
-- 
1.8.5.3
