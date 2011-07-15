From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 0/1] proc: Introduce the /proc/<pid>/mfd/ directory
Date: Fri, 15 Jul 2011 17:45:46 +0400
Message-ID: <4E20448A.5010207@parallels.com>
References: <4E204466.8010204@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4E204466.8010204-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
one for each mapping with file, the name of a symlink is vma->vm_start, the
target is the file. Opening a symlink results in a file that point exactly
to the same inode as them vma's one.

This thing is aimed to help checkpointing processes.

Signed-off-by: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

---
 fs/proc/base.c          |  204 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h |    5 +-
 2 files changed, 208 insertions(+), 1 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index dfa5327..633af12 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1995,6 +1995,49 @@ static int proc_fd_link(struct inode *inode, struct path *path)
 	return proc_fd_info(inode, path, NULL);
 }
 
+static int proc_mfd_get_link(struct inode *inode, struct path *path)
+{
+	struct task_struct *task;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	unsigned long vm_start;
+	int rc = -ENOENT;
+
+	task = get_proc_task(inode);
+	if (!task)
+		goto out;
+
+	mm = get_task_mm(task);
+	put_task_struct(task);
+
+	if (!mm)
+		goto out;
+
+	vm_start = PROC_I(inode)->vm_start;
+
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_start < vm_start)
+			continue;
+		if (vma->vm_start > vm_start)
+			break;
+		if (!vma->vm_file)
+			break;
+
+		*path = vma->vm_file->f_path;
+		path_get(path);
+
+		rc = 0;
+		break;
+	}
+
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+
+out:
+	return rc;
+}
+
 static int tid_fd_revalidate(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode;
@@ -2213,6 +2256,115 @@ static const struct file_operations proc_fd_operations = {
 	.llseek		= default_llseek,
 };
 
+static const struct dentry_operations tid_mfd_dentry_operations = {
+	.d_delete	= pid_delete_dentry,
+};
+
+static struct dentry *proc_mfd_instantiate(struct inode *dir, struct dentry *dentry,
+					   struct task_struct *task, const void *ptr)
+{
+	const struct vm_area_struct *vma = ptr;
+	struct file *file = vma->vm_file;
+	struct proc_inode *ei;
+	struct inode *inode;
+
+	if (!file)
+		return ERR_PTR(-ENOENT);
+
+	inode = proc_pid_make_inode(dir->i_sb, task);
+	if (!inode)
+		return ERR_PTR(-ENOENT);
+
+	ei			= PROC_I(inode);
+	ei->vm_start		= vma->vm_start;
+	ei->op.proc_get_link	= proc_mfd_get_link;
+
+	inode->i_op	= &proc_pid_link_inode_operations;
+	inode->i_size	= 64;
+	inode->i_mode	= S_IFLNK;
+
+	if (file->f_mode & FMODE_READ)
+		inode->i_mode |= S_IRUSR | S_IXUSR;
+	if (file->f_mode & FMODE_WRITE)
+		inode->i_mode |= S_IWUSR | S_IXUSR;
+
+	d_set_d_op(dentry, &tid_mfd_dentry_operations);
+	d_add(dentry, inode);
+
+	return NULL;
+}
+
+static int proc_mfd_readdir(struct file *filp, void *dirent, filldir_t filldir)
+{
+	struct dentry *dentry = filp->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	struct vm_area_struct *vma;
+	struct task_struct *task;
+	struct mm_struct *mm;
+	unsigned int vmai;
+	ino_t ino;
+	int ret;
+
+	ret = -ENOENT;
+	task = get_proc_task(inode);
+	if (!task)
+		goto out_no_task;
+
+	ret = -EPERM;
+	if (!ptrace_may_access(task, PTRACE_MODE_READ))
+		goto out;
+
+	ret = 0;
+	switch (filp->f_pos) {
+	case 0:
+		ino = inode->i_ino;
+		if (filldir(dirent, ".", 1, 0, ino, DT_DIR) < 0)
+			goto out;
+		filp->f_pos++;
+	case 1:
+		ino = parent_ino(dentry);
+		if (filldir(dirent, "..", 2, 1, ino, DT_DIR) < 0)
+			goto out;
+		filp->f_pos++;
+	default:
+		mm = get_task_mm(task);
+		if (!mm)
+			goto out;
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap, vmai = 2; vma; vma = vma->vm_next) {
+			char name[2 + 16 + 1];
+			int len;
+
+			if (!vma->vm_file)
+				continue;
+
+			vmai++;
+			if (vmai < filp->f_pos)
+				continue;
+
+			filp->f_pos++;
+			len = snprintf(name, sizeof(name), "0x%lx", vma->vm_start);
+			if (proc_fill_cache(filp, dirent, filldir,
+					    name, len, proc_mfd_instantiate,
+					    task, vma) < 0)
+				break;
+		}
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+
+out:
+	put_task_struct(task);
+out_no_task:
+	return ret;
+}
+
+static const struct file_operations proc_mfd_operations = {
+	.read		= generic_read_dir,
+	.readdir	= proc_mfd_readdir,
+	.llseek		= default_llseek,
+};
+
 /*
  * /proc/pid/fd needs a special permission handler so that a process can still
  * access /proc/self/fd after it has executed a setuid().
@@ -2240,6 +2392,57 @@ static const struct inode_operations proc_fd_inode_operations = {
 	.setattr	= proc_setattr,
 };
 
+static struct dentry *proc_mfd_lookup(struct inode *dir,
+		struct dentry *dentry, struct nameidata *nd)
+{
+	struct task_struct *task;
+	unsigned long vm_start;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct dentry *result;
+	char *endp;
+
+	result = ERR_PTR(-ENOENT);
+
+	task = get_proc_task(dir);
+	if (!task)
+		goto out_no_task;
+
+	vm_start = simple_strtoul(dentry->d_name.name, &endp, 16);
+	if (*endp != '\0')
+		goto out_no_mm;
+
+	mm = get_task_mm(task);
+	if (!mm)
+		goto out_no_mm;
+
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->vm_start == vm_start)
+			break;
+		if (vma->vm_start > vm_start)
+			goto out_no_vma;
+	}
+
+	if (!vma)
+		goto out_no_vma;
+
+	result = proc_mfd_instantiate(dir, dentry, task, vma);
+
+out_no_vma:
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+out_no_mm:
+	put_task_struct(task);
+out_no_task:
+	return result;
+}
+
+static const struct inode_operations proc_mfd_inode_operations = {
+	.lookup		= proc_mfd_lookup,
+	.setattr	= proc_setattr,
+};
+
 static struct dentry *proc_fdinfo_instantiate(struct inode *dir,
 	struct dentry *dentry, struct task_struct *task, const void *ptr)
 {
@@ -2819,6 +3022,7 @@ static const struct inode_operations proc_task_inode_operations;
 static const struct pid_entry tgid_base_stuff[] = {
 	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
 	DIR("fd",         S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
+	DIR("mfd",        S_IRUSR|S_IXUSR, proc_mfd_inode_operations, proc_mfd_operations),
 	DIR("fdinfo",     S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdinfo_operations),
 #ifdef CONFIG_NET
 	DIR("net",        S_IRUGO|S_IXUGO, proc_net_inode_operations, proc_net_operations),
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index eaf4350..c779c74 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -265,7 +265,10 @@ struct ctl_table;
 
 struct proc_inode {
 	struct pid *pid;
-	int fd;
+	union {
+		int fd;
+		unsigned long vm_start;
+	};
 	union proc_op op;
 	struct proc_dir_entry *pde;
 	struct ctl_table_header *sysctl;
-- 
1.5.5.6
