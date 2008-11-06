From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 5/7] proc_net: Don't show the wrong /proc/net after unshare.
Date: Thu, 06 Nov 2008 02:56:09 -0800
Message-ID: <m1skq515ti.fsf_-_@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<m163n12ko9.fsf_-_@frodo.ebiederm.org>
	<m1y6zx15yj.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1y6zx15yj.fsf_-_-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 06 Nov 2008 02:53:08 -0800")
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


This is accomplished by dropping the /proc/<pid>/net
dentry when we discover an older version of /proc/net
is mounted upon it.  This prevents new lookups from
using the mount and ultimately proc_shrink_automounts
will catch up with it and remove the old mount point.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c     |   11 +++++++----
 fs/proc/internal.h |   11 +++++++++++
 fs/proc/proc_net.c |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9a68fa4..8b0d066 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1487,6 +1487,7 @@ static int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode = dentry->d_inode;
 	struct task_struct *task = get_proc_task(inode);
+	int ret = 0;
 	if (task) {
 		if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
 		    task_dumpable(task)) {
@@ -1497,12 +1498,14 @@ static int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
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
index ffa285e..f9f8de6 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -64,6 +64,17 @@ extern const struct file_operations proc_kmsg_operations;
 extern const struct file_operations proc_net_operations;
 extern const struct inode_operations proc_net_inode_operations;
 
+#ifdef CONFIG_NET
+extern int proc_net_revalidate(struct task_struct *task, struct dentry *dentry,
+				struct nameidata *nd);
+#else
+static inline int proc_net_revalidate(struct task_struct *t, struct dentry *d,
+					struct nameidata *nd)
+{
+	return 1;
+}
+#endif
+
 void free_proc_entry(struct proc_dir_entry *de);
 
 void proc_init_inodecache(void);
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 57e0f22..4a7551a 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -174,6 +174,39 @@ const struct inode_operations proc_net_inode_operations = {
 	.follow_link	= proc_net_follow_link,
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
+	if (!nd || (inode->i_op != &proc_net_inode_operations))
+		goto out;
+
+	/* If the wrong filesystem is mounted on
+	 * /proc/<pid>/net report the dentry is invalid.
+	 */
+	tdentry = dget(dentry);
+	tmnt = mntget(nd->path.mnt);
+	if (follow_down(&tmnt, &tdentry)) {
+		struct nsproxy *ns;
+		rcu_read_lock();
+		ns = task_nsproxy(task);
+		if ((ns == NULL) ||
+		     (tmnt->mnt_sb->s_magic != PROC_NET_SUPER_MAGIC) ||
+		     (tmnt->mnt_sb->s_fs_info != ns->net_ns))
+			ret = 0;
+		rcu_read_unlock();
+	}
+	mntput(tmnt);
+	dput(tdentry);
+out:
+	return ret;
+}
+
 struct proc_dir_entry *proc_net_fops_create(struct net *net,
 	const char *name, mode_t mode, const struct file_operations *fops)
 {
-- 
1.5.3.rc6.17.g1911
