From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Wed, 24 Aug 2011 12:53:29 +0400
Message-ID: <20110824085329.GL29452@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Serge Hallyn <serge.hallyn@canonical.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, James Bottomley <jbottomley@parallels.com>
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>

This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
one for each mapping with file, the name of a symlink is vma->vm_start, the
target is the file. Opening a symlink results in a file that point exactly
to the same inode as them vma's one.

This thing is aimed to help checkpointing processes.

For example the ls -l of some arbitrary /proc/<pid>/map_files/

 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1b000 -> /lib64/ld-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1c000 -> /lib64/ld-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73e00000 -> /lib64/libc-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73f4e000 -> /lib64/libc-2.5.so

v2:
 - /proc/<pid>/mfd changed to /proc/<pid>/map_files
 - find_vma helper is used instead of linear search
 - routines are re-grouped
 - .d_revalidate is set now

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/proc/base.c          |  191 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h |    5 +
 2 files changed, 195 insertions(+), 1 deletion(-)

Please review. This is a part of previous c/r patchset as well
but I guess it might be treated separately.

Objections, complains, comments are highly appreciated!

Index: linux-2.6.git/fs/proc/base.c
===================================================================
--- linux-2.6.git.orig/fs/proc/base.c
+++ linux-2.6.git/fs/proc/base.c
@@ -2170,6 +2170,196 @@ static const struct file_operations proc
 	.llseek		= default_llseek,
 };
 
+static const struct dentry_operations tid_map_files_dentry_operations = {
+	.d_revalidate	= pid_revalidate,
+	.d_delete	= pid_delete_dentry,
+};
+
+static int proc_map_files_get_link(struct inode *inode, struct path *path)
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
+	vma = find_vma(mm, vm_start);
+	if (vma && vma->vm_start == vm_start && vma->vm_file) {
+		*path = vma->vm_file->f_path;
+		path_get(path);
+		rc = 0;
+	}
+	up_read(&mm->mmap_sem);
+
+	mmput(mm);
+
+out:
+	return rc;
+}
+
+static struct dentry *
+proc_map_files_instantiate(struct inode *dir, struct dentry *dentry,
+			   struct task_struct *task, const void *ptr)
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
+	ei->op.proc_get_link	= proc_map_files_get_link;
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
+	d_set_d_op(dentry, &tid_map_files_dentry_operations);
+	d_add(dentry, inode);
+
+	return NULL;
+}
+
+static struct dentry *proc_map_files_lookup(struct inode *dir,
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
+	vma = find_vma(mm, vm_start);
+	if (!vma || vma->vm_start != vm_start)
+		goto out_no_vma;
+	result = proc_map_files_instantiate(dir, dentry, task, vma);
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
+static const struct inode_operations proc_map_files_inode_operations = {
+	.lookup		= proc_map_files_lookup,
+	.setattr	= proc_setattr,
+};
+
+static int proc_map_files_readdir(struct file *filp, void *dirent, filldir_t filldir)
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
+					    name, len, proc_map_files_instantiate,
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
+static const struct file_operations proc_map_files_operations = {
+	.read		= generic_read_dir,
+	.readdir	= proc_map_files_readdir,
+	.llseek		= default_llseek,
+};
+
 /*
  * /proc/pid/fd needs a special permission handler so that a process can still
  * access /proc/self/fd after it has executed a setuid().
@@ -2785,6 +2975,7 @@ static const struct inode_operations pro
 static const struct pid_entry tgid_base_stuff[] = {
 	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
 	DIR("fd",         S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
+	DIR("map_files",  S_IRUSR|S_IXUSR, proc_map_files_inode_operations, proc_map_files_operations),
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
