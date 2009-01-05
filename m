From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/6] proc: don't show the wrong /proc/net after unshare
Date: Tue, 6 Jan 2009 02:34:11 +0300
Message-ID: <20090105233411.GD3924@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From e61d04ffef58c5c088d333a67d56241fa29ab2dc Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Wed, 19 Nov 2008 04:57:28 +0300
Subject: [PATCH 4/6] proc: don't show the wrong /proc/net after unshare

This is accomplished by dropping the /proc/<pid>/net
dentry when we discover an older version of /proc/net
is mounted upon it.  This prevents new lookups from
using the mount and ultimately proc_shrink_automounts
will catch up with it and remove the old mount point.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/proc/base.c     |   11 +++++++----
 fs/proc/internal.h |    9 +++++++++
 fs/proc/proc_net.c |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index e6e89d3..a4b7cac 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1518,6 +1518,7 @@ static int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *task = get_proc_task(inode);
 	const struct cred *cred;
+	int ret = 0;
 
 	if (task) {
 		if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
@@ -1532,12 +1533,14 @@ static int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
 			inode->i_gid = 0;
 		}
 		inode->i_mode &= ~(S_ISUID | S_ISGID);
-		security_task_to_inode(task, inode);
+		ret = proc_net_revalidate(task, dentry, nd);
+		if (ret == 1)
+			security_task_to_inode(task, inode);
 		put_task_struct(task);
-		return 1;
 	}
-	d_drop(dentry);
-	return 0;
+	if (ret == 0)
+		d_drop(dentry);
+	return ret;
 }
 
 static int pid_delete_dentry(struct dentry * dentry)
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 36e0636..5cfe798 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -62,6 +62,15 @@ extern const struct file_operations proc_clear_refs_operations;
 extern const struct file_operations proc_pagemap_operations;
 extern const struct inode_operations proc_net_inode_operations;
 
+#ifdef CONFIG_NET
+int proc_net_revalidate(struct task_struct *tsk, struct dentry *dentry, struct nameidata *nd);
+#else
+static inline int proc_net_revalidate(struct task_struct *tsk, struct dentry *dentry, struct nameidata *nd)
+{
+	return 1;
+}
+#endif
+
 void free_proc_entry(struct proc_dir_entry *de);
 
 void proc_init_inodecache(void);
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 1054d92..b026c87 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -169,6 +169,41 @@ const struct inode_operations proc_net_inode_operations = {
 };
 
 
+int proc_net_revalidate(struct task_struct *task, struct dentry *dentry,
+			struct nameidata *nd)
+{
+	struct inode *inode = dentry->d_inode;
+	struct dentry *tdentry;
+	struct vfsmount *tmnt;
+	int ret = 1;
+
+	/* Are we talking about a proc/net mount point? */
+	if (!nd || inode->i_op != &proc_net_inode_operations)
+		goto out;
+
+	/*
+	 * If the wrong filesystem is mounted on /proc/<pid>/net report the
+	 * dentry is invalid.
+	 */
+	tmnt = mntget(nd->path.mnt);
+	tdentry = dget(dentry);
+	if (follow_down(&tmnt, &tdentry)) {
+		struct nsproxy *ns;
+
+		rcu_read_lock();
+		ns = task_nsproxy(task);
+		if ((ns == NULL) ||
+		     (tmnt->mnt_sb->s_magic != PROC_NET_SUPER_MAGIC) ||
+		     (tmnt->mnt_sb->s_fs_info != ns->net_ns))
+			ret = 0;
+		rcu_read_unlock();
+	}
+	dput(tdentry);
+	mntput(tmnt);
+out:
+	return ret;
+}
+
 struct proc_dir_entry *proc_net_fops_create(struct net *net,
 	const char *name, mode_t mode, const struct file_operations *fops)
 {
-- 
1.5.6.5
