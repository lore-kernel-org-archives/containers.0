From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/ directory v6
Date: Wed, 31 Aug 2011 11:58:16 +0400
Message-ID: <20110831080229.100652529@openvz.org>
References: <20110831075814.003575573@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=cr-proc-map-files-13
Sender: linux-kernel-owner@vger.kernel.org
To: containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Vasiliy Kulikov <segoon@openwall.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>
List-Id: containers.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>

This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
one for each mapping with file, the name of a symlink is "vma->vm_start-vma->vm_end",
the target is the file. Opening a symlink results in a file that point exactly
to the same inode as them vma's one.

For example the ls -l of some arbitrary /proc/<pid>/map_files/

 | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80403000-7f8f80404000 -> /lib64/libc-2.5.so
 | lr-x------ 1 root root 64 Aug 26 06:40 7f8f8061e000-7f8f80620000 -> /lib64/libselinux.so.1
 | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80826000-7f8f80827000 -> /lib64/libacl.so.1.1.0
 | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a2f000-7f8f80a30000 -> /lib64/librt-2.5.so
 | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a30000-7f8f80a4c000 -> /lib64/ld-2.5.so

This helps checkpointing process in three ways:

1. When dumping a task mappings we do know exact file that is mapped by particular
   region. We do this by opening /proc/pid/map_files/address symlink the way we do
   with file descriptors.

2. This also helps in determining which anonymous shared mappings are shared with
   each other by comparing the inodes of them.

3. When restoring a set of process in case two of them has a mapping shared, we map
   the memory by the 1st one and then open its /proc/pid/map_files/address file and
   map it by the 2nd task.

v2: (spotted by Tejun Heo)
 - /proc/<pid>/mfd changed to /proc/<pid>/map_files
 - find_vma helper is used instead of linear search
 - routines are re-grouped
 - d_revalidate is set now

v3:
 - d_revalidate reworked, now it should drops no longer valid dentries (Tejun Heo)
 - ptrace_may_access added into proc_map_files_lookup (Vasiliy Kulikov)
 - because of filldir (which eventually might need to lock mmap_sem)
   the proc_map_files_readdir() was reworked to call proc_fill_cache()
   with unlocked mmap_sem

v4: (feedback by Tejun Heo and Vasiliy Kulikov)
 - instead of saving data in proc_inode we rather make a dentry name
   to keep both vm_start and vm_end accordingly
 - d_revalidate now honor task credentials

v5: (feedback by Kirill A. Shutemov)
 - don't forget to release mmap_sem on error path

v6:
 - sizeof get used in map_files_info which shrink member
   a bit on x86-32 (by Kirill A. Shutemov)
 - map_name_to_addr returns -EINVAL instead of -1
   which is more appropriate (by Tejun Heo)

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
CC: Tejun Heo <tj@kernel.org>
CC: Vasiliy Kulikov <segoon@openwall.com>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: Alexey Dobriyan <adobriyan@gmail.com>
CC: Al Viro <viro@ZenIV.linux.org.uk>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 fs/proc/base.c |  321 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 321 insertions(+)

Index: linux-2.6.git/fs/proc/base.c
===================================================================
--- linux-2.6.git.orig/fs/proc/base.c
+++ linux-2.6.git/fs/proc/base.c
@@ -2170,6 +2170,326 @@ static const struct file_operations proc
 	.llseek		= default_llseek,
 };
 
+static struct vm_area_struct *
+find_exact_vma(struct mm_struct *mm, unsigned long vm_start, unsigned long vm_end)
+{
+	struct vm_area_struct *vma = find_vma(mm, vm_start);
+	if (vma && (vma->vm_start != vm_start || vma->vm_end != vm_end))
+		vma = NULL;
+	return vma;
+}
+
+static int map_name_to_addr(const unsigned char *name, unsigned long *start, unsigned long *end)
+{
+	int ret = -EINVAL;
+	char *endp;
+
+	if (unlikely(!name))
+		goto err;
+
+	*start = simple_strtoul(name, &endp, 16);
+	if (*endp != '-')
+		goto err;
+	*end = simple_strtoul(endp + 1, &endp, 16);
+	if (*endp != 0)
+		goto err;
+
+	ret = 0;
+
+err:
+	return ret;
+}
+
+static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
+{
+	struct vm_area_struct *vma = NULL;
+	unsigned long vm_start, vm_end;
+	struct task_struct *task;
+	const struct cred *cred;
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
+	if (!map_name_to_addr(dentry->d_name.name, &vm_start, &vm_end)) {
+		down_read(&mm->mmap_sem);
+		vma = find_exact_vma(mm, vm_start, vm_end);
+		up_read(&mm->mmap_sem);
+	}
+
+	mmput(mm);
+
+	if (vma) {
+		if (task_dumpable(task)) {
+			rcu_read_lock();
+			cred = __task_cred(task);
+			inode->i_uid = cred->euid;
+			inode->i_gid = cred->egid;
+			rcu_read_unlock();
+		} else {
+			inode->i_uid = 0;
+			inode->i_gid = 0;
+		}
+		security_task_to_inode(task, inode);
+		return 1;
+	}
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
+static int proc_map_files_get_link(struct dentry *dentry, struct inode *inode, struct path *path)
+{
+	unsigned long vm_start, vm_end;
+	struct vm_area_struct *vma;
+	struct task_struct *task;
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
+	rc = map_name_to_addr(dentry->d_name.name,
+			      &vm_start, &vm_end);
+	if (rc)
+		goto out_mmput;
+
+	down_read(&mm->mmap_sem);
+	vma = find_exact_vma(mm, vm_start, vm_end);
+	if (vma && vma->vm_file) {
+		*path = vma->vm_file->f_path;
+		path_get(path);
+		rc = 0;
+	}
+	up_read(&mm->mmap_sem);
+
+out_mmput:
+	mmput(mm);
+out:
+	return rc;
+}
+
+struct map_files_info {
+	struct file	*file;
+	unsigned long	len;
+	unsigned char	name[4*sizeof(long)+2]; /* max: %lx-%lx\0 */
+};
+
+static struct dentry *
+proc_map_files_instantiate(struct inode *dir, struct dentry *dentry,
+			   struct task_struct *task, const void *ptr)
+{
+	const struct file *file = ptr;
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
+	unsigned long vm_start, vm_end;
+	struct task_struct *task;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct dentry *result;
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
+	result = ERR_PTR(-ENOENT);
+	if (map_name_to_addr(dentry->d_name.name,
+			     &vm_start, &vm_end))
+		goto out_no_mm;
+
+	mm = get_task_mm(task);
+	if (!mm)
+		goto out_no_mm;
+
+	down_read(&mm->mmap_sem);
+	vma = find_exact_vma(mm, vm_start, vm_end);
+	if (!vma)
+		goto out_no_vma;
+
+	result = proc_map_files_instantiate(dir, dentry, task, vma->vm_file);
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
+		struct map_files_info *info = NULL;
+		unsigned long nr_files, used, i;
+
+		mm = get_task_mm(task);
+		if (!mm)
+			goto out;
+		down_read(&mm->mmap_sem);
+
+		nr_files = 0;
+		used = 0;
+
+		/*
+		 * We need two passes here:
+		 *  1) Collect vmas of mapped files with mmap_sem taken
+		 *  2) Release mmap_sem and instantiate entries
+		 * othrewise we get lockdep complains since filldir
+		 * might sleep.
+		 */
+
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (vma->vm_file)
+				nr_files++;
+		}
+
+		if (nr_files) {
+			info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);
+			if (!info)
+				ret = -ENOMEM;
+			for (vma = mm->mmap, vmai = 2; vma && info; vma = vma->vm_next) {
+				if (!vma->vm_file)
+					continue;
+				vmai++;
+				if (vmai <= filp->f_pos)
+					continue;
+
+				get_file(vma->vm_file);
+				info[used].file	= vma->vm_file;
+				info[used].len	= snprintf(info[used].name,
+							   sizeof(info[used].name),
+							   "%lx-%lx",
+							   vma->vm_start,
+							   vma->vm_end);
+				used++;
+			}
+		}
+
+		up_read(&mm->mmap_sem);
+
+		for (i = 0; i < used; i++) {
+			ret = proc_fill_cache(filp, dirent, filldir,
+					      info[i].name, info[i].len,
+					      proc_map_files_instantiate,
+					      task, info[i].file);
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
@@ -2785,6 +3105,7 @@ static const struct inode_operations pro
 static const struct pid_entry tgid_base_stuff[] = {
 	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
 	DIR("fd",         S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
+	DIR("map_files",  S_IRUSR|S_IXUSR, proc_map_files_inode_operations, proc_map_files_operations),
 	DIR("fdinfo",     S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdinfo_operations),
 	DIR("ns",	  S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_operations),
 #ifdef CONFIG_NET
