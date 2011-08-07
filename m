From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 1/4] proc: Introduce the /proc/<pid>/mfd/ directory
Date: Mon, 08 Aug 2011 01:01:13 +0400
Message-ID: <20110807210526.741513583@openvz.org>
References: <20110807210112.245578619@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=cr-1
Sender: linux-kernel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akp>
Cc: Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, Cyrill Gorcunov <gorcunov@openvz.org>
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>

This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
one for each mapping with file, the name of a symlink is vma->vm_start, the
target is the file. Opening a symlink results in a file that point exactly
to the same inode as them vma's one.

This thing is aimed to help checkpointing processes.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Reviewed-by: Tejun Heo <tj@kernel.org>
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/proc/base.c          |  204 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h |    5 -
 2 files changed, 208 insertions(+), 1 deletion(-)

Index: linux-2.6.git/fs/proc/base.c
===================================================================
--- linux-2.6.git.orig/fs/proc/base.c
+++ linux-2.6.git/fs/proc/base.c
@@ -1944,6 +1944,49 @@ static int proc_fd_link(struct inode *in
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
@@ -2162,6 +2205,115 @@ static const struct file_operations proc
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
@@ -2185,6 +2337,57 @@ static const struct inode_operations pro
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
@@ -2777,6 +2980,7 @@ static const struct inode_operations pro
 static const struct pid_entry tgid_base_stuff[] = {
 	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
 	DIR("fd",         S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
+	DIR("mfd",        S_IRUSR|S_IXUSR, proc_mfd_inode_operations, proc_mfd_operations),
 	DIR("fdinfo",     S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdinfo_operations),
 	DIR("ns",	  S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_operations),
 #ifdef CONFIG_NET
Index: linux-2.6.git/include/linux/proc_fs.h
===================================================================
--- linux-2.6.git.orig/include/linux/proc_fs.h
+++ linux-2.6.git/include/linux/proc_fs.h
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
