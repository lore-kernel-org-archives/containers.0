From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v4 6/9] cgroup: make rebind_subsystems() handle file
	additions and removals with proper error handling
Date: Fri, 12 Jul 2013 12:37:21 -0700
Message-ID: <20130712193721.GF23680__24104.3439521038$1373657857$gmane$org@mtj.dyndns.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
	<1372463145-4245-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1372463145-4245-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From 705da98c48f39ebe565439353a5b35a0bab08b23 Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Fri, 28 Jun 2013 17:07:30 -0700

Currently, creating and removing cgroup files in the root directory
are handled separately from the actual subsystem binding and unbinding
which happens in rebind_subsystems().  Also, rebind_subsystems() users
aren't handling file creation errors properly.  Let's integrate
top_cgroup file handling into rebind_subsystems() so that it's simpler
to use and everyone handles file creation errors correctly.

* On a successful return, rebind_subsystems() is guaranteed to have
  created all files of the new subsystems and deleted the ones
  belonging to the removed subsystems.  After a failure, no file is
  created or removed.

* cgroup_remount() no longer needs to make explicit populate/clear
  calls as it's all handled by rebind_subsystems(), and it gets proper
  error handling automatically.

* cgroup_mount() has been updated such that the root dentry and cgroup
  are linked before rebind_subsystems().  Also, the init_cred dancing
  and base file handling are moved right above rebind_subsystems()
  call and proper error handling for the base files is added.  While
  at it, add a comment explaining what's going on with the cred thing.

* cgroup_kill_sb() calls rebind_subsystems() to unbind all subsystems
  which now implies removing all subsystem files which requires the
  directory's i_mutex.  Grab it.  This means that files on the root
  cgroup are removed earlier - they used to be deleted from generic
  super_block cleanup from vfs.  This doesn't lead to any functional
  difference and it's cleaner to do the clean up explicitly for all
  files.

Combined with the previous changes, this makes all cgroup file
creation errors handled correctly.

v2: Added comment on init_cred.

v3: Li spotted that cgroup_mount() wasn't freeing tmp_links after base
    file addition failure.  Fix it by adding free_tmp_links error
    handling label.

v4: v3 introduced build bugs which got noticed by Fengguang's awesome
    kbuild test robot.  Fixed, and shame on me.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
I introduced a build bug on v3 and failed to notice it.  I probably
did build testing without the patch applied.  The tree has been
updated.

Thanks.

 kernel/cgroup.c |   73 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 41 insertions(+), 32 deletions(-)

--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1003,7 +1003,7 @@ static int rebind_subsystems(struct cgro
 {
 	struct cgroup *cgrp = &root->top_cgroup;
 	struct cgroup_subsys *ss;
-	int i;
+	int i, ret;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
 	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
@@ -1028,7 +1028,16 @@ static int rebind_subsystems(struct cgro
 	if (root->number_of_cgroups > 1)
 		return -EBUSY;
 
-	/* Process each subsystem */
+	ret = cgroup_populate_dir(cgrp, added_mask);
+	if (ret)
+		return ret;
+
+	/*
+	 * Nothing can fail from this point on.  Remove files for the
+	 * removed subsystems and rebind each subsystem.
+	 */
+	cgroup_clear_dir(cgrp, removed_mask);
+
 	for_each_subsys(ss, i) {
 		unsigned long bit = 1UL << i;
 
@@ -1364,22 +1373,9 @@ static int cgroup_remount(struct super_b
 		goto out_unlock;
 	}
 
-	/*
-	 * Clear out the files of subsystems that should be removed, do
-	 * this before rebind_subsystems, since rebind_subsystems may
-	 * change this hierarchy's subsys_list.
-	 */
-	cgroup_clear_dir(cgrp, removed_mask);
-
 	ret = rebind_subsystems(root, added_mask, removed_mask);
-	if (ret) {
-		/* rebind_subsystems failed, re-populate the removed files */
-		cgroup_populate_dir(cgrp, removed_mask);
+	if (ret)
 		goto out_unlock;
-	}
-
-	/* re-populate subsystem files */
-	cgroup_populate_dir(cgrp, added_mask);
 
 	if (opts.release_agent)
 		strcpy(root->release_agent_path, opts.release_agent);
@@ -1578,7 +1574,9 @@ static struct dentry *cgroup_mount(struc
 	int ret = 0;
 	struct super_block *sb;
 	struct cgroupfs_root *new_root;
+	struct list_head tmp_links;
 	struct inode *inode;
+	const struct cred *cred;
 
 	/* First find the desired set of subsystems */
 	mutex_lock(&cgroup_mutex);
@@ -1610,10 +1608,8 @@ static struct dentry *cgroup_mount(struc
 	BUG_ON(!root);
 	if (root == opts.new_root) {
 		/* We used the new root structure, so this is a new hierarchy */
-		struct list_head tmp_links;
 		struct cgroup *root_cgrp = &root->top_cgroup;
 		struct cgroupfs_root *existing_root;
-		const struct cred *cred;
 		int i;
 		struct css_set *cset;
 
@@ -1651,26 +1647,37 @@ static struct dentry *cgroup_mount(struc
 		if (ret)
 			goto unlock_drop;
 
+		sb->s_root->d_fsdata = root_cgrp;
+		root_cgrp->dentry = sb->s_root;
+
+		/*
+		 * We're inside get_sb() and will call lookup_one_len() to
+		 * create the root files, which doesn't work if SELinux is
+		 * in use.  The following cred dancing somehow works around
+		 * it.  See 2ce9738ba ("cgroupfs: use init_cred when
+		 * populating new cgroupfs mount") for more details.
+		 */
+		cred = override_creds(&init_cred);
+
+		ret = cgroup_addrm_files(root_cgrp, NULL, cgroup_base_files, true);
+		if (ret)
+			goto rm_base_files;
+
 		ret = rebind_subsystems(root, root->subsys_mask, 0);
-		if (ret == -EBUSY) {
-			free_cgrp_cset_links(&tmp_links);
-			goto unlock_drop;
-		}
+		if (ret)
+			goto rm_base_files;
+
+		revert_creds(cred);
+
 		/*
 		 * There must be no failure case after here, since rebinding
 		 * takes care of subsystems' refcounts, which are explicitly
 		 * dropped in the failure exit path.
 		 */
 
-		/* EBUSY should be the only error here */
-		BUG_ON(ret);
-
 		list_add(&root->root_list, &cgroup_roots);
 		cgroup_root_count++;
 
-		sb->s_root->d_fsdata = root_cgrp;
-		root->top_cgroup.dentry = sb->s_root;
-
 		/* Link the top cgroup in this hierarchy into all
 		 * the css_set objects */
 		write_lock(&css_set_lock);
@@ -1683,10 +1690,6 @@ static struct dentry *cgroup_mount(struc
 		BUG_ON(!list_empty(&root_cgrp->children));
 		BUG_ON(root->number_of_cgroups != 1);
 
-		cred = override_creds(&init_cred);
-		cgroup_addrm_files(root_cgrp, NULL, cgroup_base_files, true);
-		cgroup_populate_dir(root_cgrp, root->subsys_mask);
-		revert_creds(cred);
 		mutex_unlock(&cgroup_root_mutex);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
@@ -1715,6 +1718,10 @@ static struct dentry *cgroup_mount(struc
 	kfree(opts.name);
 	return dget(sb->s_root);
 
+ rm_base_files:
+	free_cgrp_cset_links(&tmp_links);
+	cgroup_addrm_files(&root->top_cgroup, NULL, cgroup_base_files, false);
+	revert_creds(cred);
  unlock_drop:
 	cgroup_exit_root_id(root);
 	mutex_unlock(&cgroup_root_mutex);
@@ -1741,6 +1748,7 @@ static void cgroup_kill_sb(struct super_
 	BUG_ON(root->number_of_cgroups != 1);
 	BUG_ON(!list_empty(&cgrp->children));
 
+	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
 	mutex_lock(&cgroup_root_mutex);
 
@@ -1773,6 +1781,7 @@ static void cgroup_kill_sb(struct super_
 
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 
 	simple_xattrs_free(&cgrp->xattrs);
