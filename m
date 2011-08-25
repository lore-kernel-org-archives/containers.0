From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Thu, 25 Aug 2011 12:29:44 +0400
Message-ID: <20110825082944.GH10030@sun>
References: <20110824085329.GL29452@sun>
 <20110824111806.GA7191@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110824111806.GA7191@albatros>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, linux-kernel@vger.kernel.org, James Bottomley <jbottomley@parallels.com>, LINUXFS-ML <linux-fsdevel@vger.kernel.org>, containers@lists.osdl.org, Zan Lynx <zlynx@acm.org>, Andi Kleen <andi@firstfloor.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 24, 2011 at 03:18:06PM +0400, Vasiliy Kulikov wrote:
...
> 
> You have no ptrace_may_access() check in ->lookup(), only in ->readdir().
> 

A huge thanks to all for feedback! Please review this updated version.
The main changes are at v3 mark in changelog. Complains (as always) are
welcome ;)

	Cyrill
---
From: Pavel Emelyanov <xemul@parallels.com>
fs, proc: Introduce the /proc/<pid>/map_files/ directory v3

This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
one for each mapping with file, the name of a symlink is vma->vm_start, the
target is the file. Opening a symlink results in a file that point exactly
to the same inode as them vma's one.

For example the ls -l of some arbitrary /proc/<pid>/map_files/

 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73a00000 -> /lib64/ld-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1b000 -> /lib64/ld-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73c1c000 -> /lib64/ld-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73e00000 -> /lib64/libc-2.5.so
 | lr-x------ 1 cyrill cyrill 64 Aug  9 15:25 0x3d73f4e000 -> /lib64/libc-2.5.so

This helps checkpointing process in three ways:

1. When dumping a task mappings we do know exact file that is mapped by particular
   region. We do this by opening /proc/pid/map_files/address symlink the way we do
   with file descriptors.

2. This also helps in determining which anonymous shared mappings are shared with
   each other by comparing the inodes of them.

3. When restoring a set of process in case two of them has a mapping shared, we map
   the memory by the 1st one and then open its /proc/pid/map_files/address file and
   map it by the 2nd task.

v2:
 - /proc/<pid>/mfd changed to /proc/<pid>/map_files
 - find_vma helper is used instead of linear search
 - routines are re-grouped
 - d_revalidate is set now

v3:
 - d_revalidate reworked, now it should drops no longer valid dentries
 - ptrace_may_access added into proc_map_files_lookup
 - because of filldir (which eventually might need to lock mmap_sem)
   the proc_map_files_readdir() was reworked to call proc_fill_cache()
   with unlocked mmap_sem

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 fs/proc/base.c          |  278 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h |    5 
 2 files changed, 282 insertions(+), 1 deletion(-)

Index: linux-2.6.git/fs/proc/base.c
===================================================================
--- linux-2.6.git.orig/fs/proc/base.c
+++ linux-2.6.git/fs/proc/base.c
@@ -2170,6 +2170,283 @@ static const struct file_operations proc
 	.llseek		= default_llseek,
 };
 
+static struct vm_area_struct *find_exact_vma(struct mm_struct *mm, unsigned long vm_start)
+{
+	struct vm_area_struct *vma = find_vma(mm, vm_start);
+	if (vma && vma->vm_start != vm_start)
+		vma = NULL;
+	return vma;
+}
+
+static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
+{
+	struct task_struct *task;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct inode *inode;
+
+	if (nd && nd->flags & LOOKUP_RCU)
+		return -ECHILD;
+
+	inode = dentry->d_inode;
+	task = get_proc_task(inode);
+	if (!task)
+		goto out;
+
+	mm = get_task_mm(task);
+	put_task_struct(task);
+	if (!mm)
+		goto out;
+
+	down_read(&mm->mmap_sem);
+	vma = find_exact_vma(mm, PROC_I(inode)->vm_start);
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+
+	if (vma)
+		return 1;
+out:
+	d_drop(dentry);
+	return 0;
+}
+
+static const struct dentry_operations tid_map_files_dentry_operations = {
+	.d_revalidate	= map_files_d_revalidate,
+	.d_delete	= pid_delete_dentry,
+};
+
+static int proc_map_files_get_link(struct inode *inode, struct path *path)
+{
+	struct task_struct *task;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	int rc = -ENOENT;
+
+	task = get_proc_task(inode);
+	if (!task)
+		goto out;
+
+	mm = get_task_mm(task);
+	put_task_struct(task);
+	if (!mm)
+		goto out;
+
+	down_read(&mm->mmap_sem);
+	vma = find_exact_vma(mm, PROC_I(inode)->vm_start);
+	if (vma && vma->vm_file) {
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
+struct map_files_info {
+	struct file	*file;
+	unsigned long	vm_start;
+	unsigned char	name[24];
+	unsigned long	len;
+};
+
+static struct dentry *
+proc_map_files_instantiate(struct inode *dir, struct dentry *dentry,
+			   struct task_struct *task, const void *ptr)
+{
+	const struct map_files_info *info = ptr;
+	struct proc_inode *ei;
+	struct inode *inode;
+
+	if (!info->file)
+		return ERR_PTR(-ENOENT);
+
+	inode = proc_pid_make_inode(dir->i_sb, task);
+	if (!inode)
+		return ERR_PTR(-ENOENT);
+
+	ei			= PROC_I(inode);
+	ei->vm_start		= info->vm_start;
+	ei->op.proc_get_link	= proc_map_files_get_link;
+
+	inode->i_op	= &proc_pid_link_inode_operations;
+	inode->i_size	= 64;
+	inode->i_mode	= S_IFLNK;
+
+	if (info->file->f_mode & FMODE_READ)
+		inode->i_mode |= S_IRUSR | S_IXUSR;
+	if (info->file->f_mode & FMODE_WRITE)
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
+	struct map_files_info info;
+	struct mm_struct *mm;
+	struct dentry *result;
+	char *endp;
+
+	result = ERR_PTR(-ENOENT);
+	task = get_proc_task(dir);
+	if (!task)
+		goto out_no_task;
+
+	result = ERR_PTR(-EPERM);
+	if (!ptrace_may_access(task, PTRACE_MODE_READ));
+		goto out_no_mm;
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
+	vma = find_exact_vma(mm, vm_start);
+	if (!vma)
+		goto out_no_vma;
+
+	memset(&info, 0, sizeof(info));
+	info.file	= vma->vm_file;
+	info.vm_start	= vm_start;
+
+	result = proc_map_files_instantiate(dir, dentry, task, &info);
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
+	{
+		unsigned long nr_files, used, i;
+		struct map_files_info *info;
+
+		mm = get_task_mm(task);
+		if (!mm)
+			goto out;
+		down_read(&mm->mmap_sem);
+
+		nr_files = 0;
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (vma->vm_file)
+				nr_files++;
+		}
+		if (!nr_files)
+			goto out;
+
+		info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);
+		if (!info) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		used = 0;
+		for (vma = mm->mmap, vmai = 2; vma; vma = vma->vm_next) {
+			if (!vma->vm_file)
+				continue;
+			vmai++;
+			if (vmai <= filp->f_pos)
+				continue;
+
+			get_file(vma->vm_file);
+			info[used].file	= vma->vm_file;
+			info[used].vm_start= vma->vm_start;
+
+			info[used].len = snprintf(info[used].name,
+						  sizeof(info[used].name),
+						  "0x%lx", vma->vm_start);
+			used++;
+		}
+
+		up_read(&mm->mmap_sem);
+
+		for (i = 0; i < used; i++) {
+			ret = proc_fill_cache(filp, dirent, filldir,
+					      info[i].name,
+					      info[i].len,
+					      proc_map_files_instantiate,
+					      task, &info[i]);
+			if (ret)
+				break;
+			filp->f_pos++;
+		}
+
+		for (i = 0; i < used; i++)
+			put_filp(info[i].file);
+
+		kfree(info);
+		mmput(mm);
+	}
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
@@ -2785,6 +3062,7 @@ static const struct inode_operations pro
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
