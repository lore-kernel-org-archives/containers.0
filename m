From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/11] procfs: Use the proc generic infrastructure for
	proc/self.
Date: Fri, 16 Nov 2012 08:35:40 -0800
Message-ID: <1353083750-3621-1-git-send-email-ebiederm@xmission.com>
References: <8739097bkk.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8739097bkk.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

I had visions at one point of splitting proc into two filesystems.  If
that had happened proc/self being the the part of proc that actually deals
with pids would have been a nice cleanup.  As it is proc/self requires
a lot of unnecessary infrastructure for a single file.

The only user visible change is that a mounted /proc for a pid namespace
that is dead now shows a broken proc symlink, instead of being completely
invisible.  I don't think anyone will notice or care.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/Makefile   |    1 +
 fs/proc/base.c     |  154 +---------------------------------------------------
 fs/proc/internal.h |    1 +
 fs/proc/root.c     |    1 +
 fs/proc/self.c     |   59 ++++++++++++++++++++
 5 files changed, 64 insertions(+), 152 deletions(-)
 create mode 100644 fs/proc/self.c

diff --git a/fs/proc/Makefile b/fs/proc/Makefile
index 99349ef..981b056 100644
--- a/fs/proc/Makefile
+++ b/fs/proc/Makefile
@@ -21,6 +21,7 @@ proc-y	+= uptime.o
 proc-y	+= version.o
 proc-y	+= softirqs.o
 proc-y	+= namespaces.o
+proc-y	+= self.o
 proc-$(CONFIG_PROC_SYSCTL)	+= proc_sysctl.o
 proc-$(CONFIG_NET)		+= proc_net.o
 proc-$(CONFIG_PROC_KCORE)	+= kcore.o
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 144a967..cbe454e 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2237,146 +2237,6 @@ static const struct file_operations proc_coredump_filter_operations = {
 };
 #endif
 
-/*
- * /proc/self:
- */
-static int proc_self_readlink(struct dentry *dentry, char __user *buffer,
-			      int buflen)
-{
-	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
-	pid_t tgid = task_tgid_nr_ns(current, ns);
-	char tmp[PROC_NUMBUF];
-	if (!tgid)
-		return -ENOENT;
-	sprintf(tmp, "%d", tgid);
-	return vfs_readlink(dentry,buffer,buflen,tmp);
-}
-
-static void *proc_self_follow_link(struct dentry *dentry, struct nameidata *nd)
-{
-	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
-	pid_t tgid = task_tgid_nr_ns(current, ns);
-	char *name = ERR_PTR(-ENOENT);
-	if (tgid) {
-		/* 11 for max length of signed int in decimal + NULL term */
-		name = kmalloc(12, GFP_KERNEL);
-		if (!name)
-			name = ERR_PTR(-ENOMEM);
-		else
-			sprintf(name, "%d", tgid);
-	}
-	nd_set_link(nd, name);
-	return NULL;
-}
-
-static void proc_self_put_link(struct dentry *dentry, struct nameidata *nd,
-				void *cookie)
-{
-	char *s = nd_get_link(nd);
-	if (!IS_ERR(s))
-		kfree(s);
-}
-
-static const struct inode_operations proc_self_inode_operations = {
-	.readlink	= proc_self_readlink,
-	.follow_link	= proc_self_follow_link,
-	.put_link	= proc_self_put_link,
-};
-
-/*
- * proc base
- *
- * These are the directory entries in the root directory of /proc
- * that properly belong to the /proc filesystem, as they describe
- * describe something that is process related.
- */
-static const struct pid_entry proc_base_stuff[] = {
-	NOD("self", S_IFLNK|S_IRWXUGO,
-		&proc_self_inode_operations, NULL, {}),
-};
-
-static struct dentry *proc_base_instantiate(struct inode *dir,
-	struct dentry *dentry, struct task_struct *task, const void *ptr)
-{
-	const struct pid_entry *p = ptr;
-	struct inode *inode;
-	struct proc_inode *ei;
-	struct dentry *error;
-
-	/* Allocate the inode */
-	error = ERR_PTR(-ENOMEM);
-	inode = new_inode(dir->i_sb);
-	if (!inode)
-		goto out;
-
-	/* Initialize the inode */
-	ei = PROC_I(inode);
-	inode->i_ino = get_next_ino();
-	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
-
-	/*
-	 * grab the reference to the task.
-	 */
-	ei->pid = get_task_pid(task, PIDTYPE_PID);
-	if (!ei->pid)
-		goto out_iput;
-
-	inode->i_mode = p->mode;
-	if (S_ISDIR(inode->i_mode))
-		set_nlink(inode, 2);
-	if (S_ISLNK(inode->i_mode))
-		inode->i_size = 64;
-	if (p->iop)
-		inode->i_op = p->iop;
-	if (p->fop)
-		inode->i_fop = p->fop;
-	ei->op = p->op;
-	d_add(dentry, inode);
-	error = NULL;
-out:
-	return error;
-out_iput:
-	iput(inode);
-	goto out;
-}
-
-static struct dentry *proc_base_lookup(struct inode *dir, struct dentry *dentry)
-{
-	struct dentry *error;
-	struct task_struct *task = get_proc_task(dir);
-	const struct pid_entry *p, *last;
-
-	error = ERR_PTR(-ENOENT);
-
-	if (!task)
-		goto out_no_task;
-
-	/* Lookup the directory entry */
-	last = &proc_base_stuff[ARRAY_SIZE(proc_base_stuff) - 1];
-	for (p = proc_base_stuff; p <= last; p++) {
-		if (p->len != dentry->d_name.len)
-			continue;
-		if (!memcmp(dentry->d_name.name, p->name, p->len))
-			break;
-	}
-	if (p > last)
-		goto out;
-
-	error = proc_base_instantiate(dir, dentry, task, p);
-
-out:
-	put_task_struct(task);
-out_no_task:
-	return error;
-}
-
-static int proc_base_fill_cache(struct file *filp, void *dirent,
-	filldir_t filldir, struct task_struct *task, const struct pid_entry *p)
-{
-	return proc_fill_cache(filp, dirent, filldir, p->name, p->len,
-				proc_base_instantiate, task, p);
-}
-
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 static int do_io_accounting(struct task_struct *task, char *buffer, int whole)
 {
@@ -2767,15 +2627,11 @@ out:
 
 struct dentry *proc_pid_lookup(struct inode *dir, struct dentry * dentry, unsigned int flags)
 {
-	struct dentry *result;
+	struct dentry *result = NULL;
 	struct task_struct *task;
 	unsigned tgid;
 	struct pid_namespace *ns;
 
-	result = proc_base_lookup(dir, dentry);
-	if (!IS_ERR(result) || PTR_ERR(result) != -ENOENT)
-		goto out;
-
 	tgid = name_to_int(dentry);
 	if (tgid == ~0U)
 		goto out;
@@ -2838,7 +2694,7 @@ retry:
 	return iter;
 }
 
-#define TGID_OFFSET (FIRST_PROCESS_ENTRY + ARRAY_SIZE(proc_base_stuff))
+#define TGID_OFFSET (FIRST_PROCESS_ENTRY)
 
 static int proc_pid_fill_cache(struct file *filp, void *dirent, filldir_t filldir,
 	struct tgid_iter iter)
@@ -2872,12 +2728,6 @@ int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir)
 	if (!reaper)
 		goto out_no_task;
 
-	for (; nr < ARRAY_SIZE(proc_base_stuff); filp->f_pos++, nr++) {
-		const struct pid_entry *p = &proc_base_stuff[nr];
-		if (proc_base_fill_cache(filp, dirent, filldir, reaper, p) < 0)
-			goto out;
-	}
-
 	ns = filp->f_dentry->d_sb->s_fs_info;
 	iter.task = NULL;
 	iter.tgid = filp->f_pos - TGID_OFFSET;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 43973b0..252544c 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -15,6 +15,7 @@ struct  ctl_table_header;
 struct  mempolicy;
 
 extern struct proc_dir_entry proc_root;
+extern void proc_self_init(void);
 #ifdef CONFIG_PROC_SYSCTL
 extern int proc_sys_init(void);
 extern void sysctl_head_put(struct ctl_table_header *head);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 9889a92..5da9849 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -169,6 +169,7 @@ void __init proc_root_init(void)
 		return;
 	}
 
+	proc_self_init();
 	proc_symlink("mounts", NULL, "self/mounts");
 
 	proc_net_init();
diff --git a/fs/proc/self.c b/fs/proc/self.c
new file mode 100644
index 0000000..aa5cc3b
--- /dev/null
+++ b/fs/proc/self.c
@@ -0,0 +1,59 @@
+#include <linux/proc_fs.h>
+#include <linux/sched.h>
+#include <linux/namei.h>
+
+/*
+ * /proc/self:
+ */
+static int proc_self_readlink(struct dentry *dentry, char __user *buffer,
+			      int buflen)
+{
+	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
+	pid_t tgid = task_tgid_nr_ns(current, ns);
+	char tmp[PROC_NUMBUF];
+	if (!tgid)
+		return -ENOENT;
+	sprintf(tmp, "%d", tgid);
+	return vfs_readlink(dentry,buffer,buflen,tmp);
+}
+
+static void *proc_self_follow_link(struct dentry *dentry, struct nameidata *nd)
+{
+	struct pid_namespace *ns = dentry->d_sb->s_fs_info;
+	pid_t tgid = task_tgid_nr_ns(current, ns);
+	char *name = ERR_PTR(-ENOENT);
+	if (tgid) {
+		/* 11 for max length of signed int in decimal + NULL term */
+		name = kmalloc(12, GFP_KERNEL);
+		if (!name)
+			name = ERR_PTR(-ENOMEM);
+		else
+			sprintf(name, "%d", tgid);
+	}
+	nd_set_link(nd, name);
+	return NULL;
+}
+
+static void proc_self_put_link(struct dentry *dentry, struct nameidata *nd,
+				void *cookie)
+{
+	char *s = nd_get_link(nd);
+	if (!IS_ERR(s))
+		kfree(s);
+}
+
+static const struct inode_operations proc_self_inode_operations = {
+	.readlink	= proc_self_readlink,
+	.follow_link	= proc_self_follow_link,
+	.put_link	= proc_self_put_link,
+};
+
+void __init proc_self_init(void)
+{
+	struct proc_dir_entry *proc_self_symlink;
+	mode_t mode;
+
+	mode = S_IFLNK | S_IRWXUGO;
+	proc_self_symlink = proc_create("self", mode, NULL, NULL );
+	proc_self_symlink->proc_iops = &proc_self_inode_operations;
+}
-- 
1.7.5.4
