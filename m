From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 04/13] cgroup: restructure locking and error handling in
	cgroup_mount()
Date: Tue, 28 Jan 2014 18:54:36 -0500
Message-ID: <1390953285-16360-5-git-send-email-tj@kernel.org>
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

cgroup is scheduled to be converted to kernfs.  After conversion,
cgroup_mount() won't use the sget() machinery for finding out existing
super_blocks but instead would do that directly.  It'll search the
existing cgroupfs_roots for a matching one and create a new one iff a
match doesn't exist.  To ease such conversion, this patch restructures
locking and error handling of the function.

cgroup_tree_mutex and cgroup_mutex are grabbed from the get-go and
held until return.  For now, due to the way vfs locks nest outside
cgroup mutexes, the two cgroup mutexes are temporarily dropped across
sget() and inode mutex locking, which looks quite ridiculous; however,
these will be removed through kernfs conversion and structuring the
code this way makes the conversion less painful.

The error goto labels are consolidated to two.  This looks unwieldy
now but the next patch will factor out creation of new root into a
separate function with accompanying error handling and it'll look a
lot better.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 73 +++++++++++++++++++++++++++++++--------------------------
 1 file changed, 40 insertions(+), 33 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index bff7d64..2349698 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1450,21 +1450,22 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			 int flags, const char *unused_dev_name,
 			 void *data)
 {
+	LIST_HEAD(tmp_links);
+	struct super_block *sb = NULL;
+	struct inode *inode = NULL;
+	struct cgroupfs_root *root = NULL;
 	struct cgroup_sb_opts opts;
-	struct cgroupfs_root *root;
-	int ret = 0;
-	struct super_block *sb;
 	struct cgroupfs_root *new_root;
-	struct list_head tmp_links;
-	struct inode *inode;
 	const struct cred *cred;
+	int ret;
 
-	/* First find the desired set of subsystems */
+	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
+
+	/* First find the desired set of subsystems */
 	ret = parse_cgroupfs_options(data, &opts);
-	mutex_unlock(&cgroup_mutex);
 	if (ret)
-		goto out_err;
+		goto out_unlock;
 
 	/*
 	 * Allocate a new cgroup root. We may not need it if we're
@@ -1473,16 +1474,20 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	new_root = cgroup_root_from_opts(&opts);
 	if (!new_root) {
 		ret = -ENOMEM;
-		goto out_err;
+		goto out_unlock;
 	}
 	opts.new_root = new_root;
 
 	/* Locate an existing or new sb for this hierarchy */
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_tree_mutex);
 	sb = sget(fs_type, cgroup_test_super, cgroup_set_super, 0, &opts);
+	mutex_lock(&cgroup_tree_mutex);
+	mutex_lock(&cgroup_mutex);
 	if (IS_ERR(sb)) {
 		ret = PTR_ERR(sb);
 		cgroup_free_root(opts.new_root);
-		goto out_err;
+		goto out_unlock;
 	}
 
 	root = sb->s_fs_info;
@@ -1496,9 +1501,12 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 
 		BUG_ON(sb->s_root != NULL);
 
+		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&cgroup_tree_mutex);
+
 		ret = cgroup_get_rootdir(sb);
 		if (ret)
-			goto drop_new_super;
+			goto out_unlock;
 		inode = sb->s_root->d_inode;
 
 		mutex_lock(&inode->i_mutex);
@@ -1507,7 +1515,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 
 		ret = idr_alloc(&root->cgroup_idr, root_cgrp, 0, 1, GFP_KERNEL);
 		if (ret < 0)
-			goto unlock_drop;
+			goto out_unlock;
 		root_cgrp->id = ret;
 
 		/* Check for name clashes with existing mounts */
@@ -1515,7 +1523,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		if (strlen(root->name))
 			for_each_active_root(existing_root)
 				if (!strcmp(existing_root->name, root->name))
-					goto unlock_drop;
+					goto out_unlock;
 
 		/*
 		 * We're accessing css_set_count without locking
@@ -1526,12 +1534,12 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 */
 		ret = allocate_cgrp_cset_links(css_set_count, &tmp_links);
 		if (ret)
-			goto unlock_drop;
+			goto out_unlock;
 
 		/* ID 0 is reserved for dummy root, 1 for unified hierarchy */
 		ret = cgroup_init_root_id(root, 2, 0);
 		if (ret)
-			goto unlock_drop;
+			goto out_unlock;
 
 		sb->s_root->d_fsdata = root_cgrp;
 		root_cgrp->dentry = sb->s_root;
@@ -1571,14 +1579,8 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			link_css_set(&tmp_links, cset, root_cgrp);
 		write_unlock(&css_set_lock);
 
-		free_cgrp_cset_links(&tmp_links);
-
 		BUG_ON(!list_empty(&root_cgrp->children));
 		BUG_ON(root->number_of_cgroups != 1);
-
-		mutex_unlock(&cgroup_mutex);
-		mutex_unlock(&cgroup_tree_mutex);
-		mutex_unlock(&inode->i_mutex);
 	} else {
 		/*
 		 * We re-used an existing hierarchy - the new root (if
@@ -1590,32 +1592,37 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 			if ((root->flags | opts.flags) & CGRP_ROOT_SANE_BEHAVIOR) {
 				pr_err("cgroup: sane_behavior: new mount options should match the existing superblock\n");
 				ret = -EINVAL;
-				goto drop_new_super;
+				goto out_unlock;
 			} else {
 				pr_warning("cgroup: new mount options do not match the existing superblock, will be ignored\n");
 			}
 		}
 	}
 
-	kfree(opts.release_agent);
-	kfree(opts.name);
-	return dget(sb->s_root);
+	ret = 0;
+	goto out_unlock;
 
- rm_base_files:
-	free_cgrp_cset_links(&tmp_links);
+rm_base_files:
 	cgroup_addrm_files(&root->top_cgroup, cgroup_base_files, false);
 	revert_creds(cred);
- unlock_drop:
 	cgroup_exit_root_id(root);
+out_unlock:
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgroup_tree_mutex);
-	mutex_unlock(&inode->i_mutex);
- drop_new_super:
-	deactivate_locked_super(sb);
- out_err:
+	if (inode)
+		mutex_unlock(&inode->i_mutex);
+
+	if (ret && !IS_ERR_OR_NULL(sb))
+		deactivate_locked_super(sb);
+
+	free_cgrp_cset_links(&tmp_links);
 	kfree(opts.release_agent);
 	kfree(opts.name);
-	return ERR_PTR(ret);
+
+	if (!ret)
+		return dget(sb->s_root);
+	else
+		return ERR_PTR(ret);
 }
 
 static void cgroup_kill_sb(struct super_block *sb)
-- 
1.8.5.3
