From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroups: remove some redundant NULL checks
Date: Fri, 21 Nov 2008 11:59:06 +0800
Message-ID: <4926320A.5060507@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

- In cgroup_clone(), if vfs_mkdir() returns successfully,
  dentry->d_fsdata will be the pointer to the newly created
  cgroup and won't be NULL.

- a cgroup file's dentry->d_fsdata won't be NULL, guaranteed
  by cgroup_add_file().

- When walking through the subsystems of a cgroup_fs (using
  for_each_subsys), cgrp->subsys[ss->subsys_id] won't be NULL,
  guaranteed by cgroup_create().

(Also remove 2 unused variables in cgroup_rmdir().

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   31 ++++++++-----------------------
 1 files changed, 8 insertions(+), 23 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fe00b3b..fcbb2d8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -588,7 +588,7 @@ static void cgroup_call_pre_destroy(struct cgroup *cgrp)
 {
 	struct cgroup_subsys *ss;
 	for_each_subsys(cgrp->root, ss)
-		if (ss->pre_destroy && cgrp->subsys[ss->subsys_id])
+		if (ss->pre_destroy)
 			ss->pre_destroy(ss, cgrp);
 	return;
 }
@@ -612,10 +612,8 @@ static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 		/*
 		 * Release the subsystem state objects.
 		 */
-		for_each_subsys(cgrp->root, ss) {
-			if (cgrp->subsys[ss->subsys_id])
-				ss->destroy(ss, cgrp);
-		}
+		for_each_subsys(cgrp->root, ss)
+			ss->destroy(ss, cgrp);
 
 		cgrp->root->number_of_cgroups--;
 		mutex_unlock(&cgroup_mutex);
@@ -1443,7 +1441,7 @@ static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
 
-	if (!cft || cgroup_is_removed(cgrp))
+	if (cgroup_is_removed(cgrp))
 		return -ENODEV;
 	if (cft->write)
 		return cft->write(cgrp, cft, file, buf, nbytes, ppos);
@@ -1488,7 +1486,7 @@ static ssize_t cgroup_file_read(struct file *file, char __user *buf,
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
 
-	if (!cft || cgroup_is_removed(cgrp))
+	if (cgroup_is_removed(cgrp))
 		return -ENODEV;
 
 	if (cft->read)
@@ -1552,10 +1550,8 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	err = generic_file_open(inode, file);
 	if (err)
 		return err;
-
 	cft = __d_cft(file->f_dentry);
-	if (!cft)
-		return -ENODEV;
+
 	if (cft->read_map || cft->read_seq_string) {
 		struct cgroup_seqfile_state *state =
 			kzalloc(sizeof(*state), GFP_USER);
@@ -1697,7 +1693,7 @@ int cgroup_add_file(struct cgroup *cgrp,
 		error = cgroup_create_file(dentry, 0644 | S_IFREG,
 						cgrp->root->sb);
 		if (!error)
-			dentry->d_fsdata = (void *)cft;
+			dentry->d_fsdata = cft;
 		dput(dentry);
 	} else
 		error = PTR_ERR(dentry);
@@ -2461,8 +2457,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	struct cgroup *cgrp = dentry->d_fsdata;
 	struct dentry *d;
 	struct cgroup *parent;
-	struct super_block *sb;
-	struct cgroupfs_root *root;
 
 	/* the vfs holds both inode->i_mutex already */
 
@@ -2485,8 +2479,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
-	root = cgrp->root;
-	sb = root->sb;
 
 	if (atomic_read(&cgrp->count)
 	    || !list_empty(&cgrp->children)
@@ -2966,7 +2958,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 	}
 
 	/* Create the cgroup directory, which also creates the cgroup */
-	ret = vfs_mkdir(inode, dentry, S_IFDIR | 0755);
+	ret = vfs_mkdir(inode, dentry, 0755);
 	child = __d_cgrp(dentry);
 	dput(dentry);
 	if (ret) {
@@ -2976,13 +2968,6 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
 		goto out_release;
 	}
 
-	if (!child) {
-		printk(KERN_INFO
-		       "Couldn't find new cgroup %s\n", nodename);
-		ret = -ENOMEM;
-		goto out_release;
-	}
-
 	/* The cgroup now exists. Retake cgroup_mutex and check
 	 * that we're still in the same state that we thought we
 	 * were. */
-- 
1.5.4.rc3
