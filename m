From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [RFC] fs, proc: Introduce the /proc/<pid>/map_files/ directory v2
Date: Fri, 26 Aug 2011 15:28:51 +0300
Message-ID: <20110826122851.GA25853@shutemov.name>
References: <20110824085329.GL29452@sun> <20110824111806.GA7191@albatros>
	<20110825082944.GH10030@sun> <20110825170147.GM2803@mtj.dyndns.org>
	<20110825170705.GA6387@sun> <20110825205426.GO2803@mtj.dyndns.org>
	<20110825211213.GP2803@mtj.dyndns.org> <20110825213459.GA1929@sun>
	<20110825213931.GR2803@mtj.dyndns.org> <20110826112943.GI3903@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110826112943.GI3903@sun>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Zan Lynx <zlynx-HInyCGIudOg@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, LINUXFS-ML <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 26, 2011 at 03:29:44PM +0400, Cyrill Gorcunov wrote:
> On Thu, Aug 25, 2011 at 11:39:31PM +0200, Tejun Heo wrote:
> ...
> > 
> > Why would you need an extra reference?  All these data structures are
> > created dynamically on access and dentry is always available while any
> > operation on the inode is in progress so it's guaranteed to be
> > available and there's no reason to diddle with reference count.
> > Anyways, we can deal with this optimization later, I think.
> > 
> 
> Hi, thanks a huge for all feedback! Mind to give the below one a
> review shot? Hope this time I've addressed all concerns. Thanks.
> (please check map_files_d_revalidate() precisely). Complains are
> welcome, as always.
> 
> 	Cyrill
> ---
> fs, proc: Introduce the /proc/<pid>/map_files/ directory v4
> 
> This one behaves similarly to the /proc/<pid>/fd/ one - it contains symlinks
> one for each mapping with file, the name of a symlink is "vma->vm_start-vma->vm_end",
> the target is the file. Opening a symlink results in a file that point exactly
> to the same inode as them vma's one.
> 
> For example the ls -l of some arbitrary /proc/<pid>/map_files/
> 
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80403000-7f8f80404000 -> /lib64/libc-2.5.so
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f8061e000-7f8f80620000 -> /lib64/libselinux.so.1
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80826000-7f8f80827000 -> /lib64/libacl.so.1.1.0
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a2f000-7f8f80a30000 -> /lib64/librt-2.5.so
>  | lr-x------ 1 root root 64 Aug 26 06:40 7f8f80a30000-7f8f80a4c000 -> /lib64/ld-2.5.so
> 
> This helps checkpointing process in three ways:
> 
> 1. When dumping a task mappings we do know exact file that is mapped by particular
>    region. We do this by opening /proc/pid/map_files/address symlink the way we do
>    with file descriptors.
> 
> 2. This also helps in determining which anonymous shared mappings are shared with
>    each other by comparing the inodes of them.
> 
> 3. When restoring a set of process in case two of them has a mapping shared, we map
>    the memory by the 1st one and then open its /proc/pid/map_files/address file and
>    map it by the 2nd task.
> 
> v2: (spotted by Tejun Heo)
>  - /proc/<pid>/mfd changed to /proc/<pid>/map_files
>  - find_vma helper is used instead of linear search
>  - routines are re-grouped
>  - d_revalidate is set now
> 
> v3:
>  - d_revalidate reworked, now it should drops no longer valid dentries (Tejun Heo)
>  - ptrace_may_access added into proc_map_files_lookup (Vasiliy Kulikov)
>  - because of filldir (which eventually might need to lock mmap_sem)
>    the proc_map_files_readdir() was reworked to call proc_fill_cache()
>    with unlocked mmap_sem
> 
> v4: (feedback by Tejun Heo and Vasiliy Kulikov)
>  - instead of saving data in proc_inode we rather make a dentry name
>    to keep both vm_start and vm_end accordingly
>  - d_revalidate now honor task credentials
> 
> Signed-off-by: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> Signed-off-by: Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> CC: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
> ---
>  fs/proc/base.c          |  326 +++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/proc_fs.h |    2 
>  2 files changed, 321 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6.git/fs/proc/base.c
> ===================================================================
> --- linux-2.6.git.orig/fs/proc/base.c
> +++ linux-2.6.git/fs/proc/base.c
> @@ -165,7 +165,7 @@ static int get_task_root(struct task_str
>  	return result;
>  }
>  
> -static int proc_cwd_link(struct inode *inode, struct path *path)
> +static int proc_cwd_link(struct dentry *dentry, struct inode *inode, struct path *path)

Put proc_get_link() change in separate patch?

>  {
>  	struct task_struct *task = get_proc_task(inode);
>  	int result = -ENOENT;
> @@ -182,7 +182,7 @@ static int proc_cwd_link(struct inode *i
>  	return result;
>  }
>  
> -static int proc_root_link(struct inode *inode, struct path *path)
> +static int proc_root_link(struct dentry *dentry, struct inode *inode, struct path *path)
>  {
>  	struct task_struct *task = get_proc_task(inode);
>  	int result = -ENOENT;
> @@ -1580,7 +1580,7 @@ static const struct file_operations proc
>  	.release	= single_release,
>  };
>  
> -static int proc_exe_link(struct inode *inode, struct path *exe_path)
> +static int proc_exe_link(struct dentry *dentry, struct inode *inode, struct path *exe_path)
>  {
>  	struct task_struct *task;
>  	struct mm_struct *mm;
> @@ -1616,7 +1616,7 @@ static void *proc_pid_follow_link(struct
>  	if (!proc_fd_access_allowed(inode))
>  		goto out;
>  
> -	error = PROC_I(inode)->op.proc_get_link(inode, &nd->path);
> +	error = PROC_I(inode)->op.proc_get_link(dentry, inode, &nd->path);
>  out:
>  	return ERR_PTR(error);
>  }
> @@ -1655,7 +1655,7 @@ static int proc_pid_readlink(struct dent
>  	if (!proc_fd_access_allowed(inode))
>  		goto out;
>  
> -	error = PROC_I(inode)->op.proc_get_link(inode, &path);
> +	error = PROC_I(inode)->op.proc_get_link(dentry, inode, &path);
>  	if (error)
>  		goto out;
>  
> @@ -1947,7 +1947,7 @@ static int proc_fd_info(struct inode *in
>  	return -ENOENT;
>  }
>  
> -static int proc_fd_link(struct inode *inode, struct path *path)
> +static int proc_fd_link(struct dentry *dentry, struct inode *inode, struct path *path)
>  {
>  	return proc_fd_info(inode, path, NULL);
>  }
> @@ -2170,6 +2170,319 @@ static const struct file_operations proc
>  	.llseek		= default_llseek,
>  };
>  
> +static struct vm_area_struct *
> +find_exact_vma(struct mm_struct *mm, unsigned long vm_start, unsigned long vm_end)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, vm_start);
> +	if (vma && (vma->vm_start != vm_start || vma->vm_end != vm_end))
> +		vma = NULL;
> +	return vma;
> +}
> +
> +static int map_name_to_addr(const unsigned char *name, unsigned long *start, unsigned long *end)
> +{
> +	int ret = -1;
> +	char *endp;
> +
> +	if (unlikely(!name))
> +		goto err;
> +
> +	*start = simple_strtoul(name, &endp, 16);
> +	if (*endp != '-')
> +		goto err;
> +	*end = simple_strtoul(endp + 1, &endp, 16);
> +	if (*endp != 0)
> +		goto err;
> +
> +	ret = 0;
> +
> +err:
> +	return ret;
> +}
> +
> +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> +{
> +	struct vm_area_struct *vma = NULL;
> +	unsigned long vm_start, vm_end;
> +	struct task_struct *task;
> +	const struct cred *cred;
> +	struct mm_struct *mm;
> +	struct inode *inode;
> +
> +	if (nd && nd->flags & LOOKUP_RCU)
> +		return -ECHILD;
> +
> +	inode = dentry->d_inode;
> +	task = get_proc_task(inode);
> +	if (!task)
> +		goto out;
> +
> +	mm = get_task_mm(task);
> +	put_task_struct(task);
> +	if (!mm)
> +		goto out;
> +
> +	if (!map_name_to_addr(dentry->d_name.name, &vm_start, &vm_end)) {
> +		down_read(&mm->mmap_sem);
> +		vma = find_exact_vma(mm, vm_start, vm_end);
> +		up_read(&mm->mmap_sem);
> +	}
> +
> +	mmput(mm);
> +
> +	if (vma) {
> +		if (task_dumpable(task)) {
> +			rcu_read_lock();
> +			cred = __task_cred(task);
> +			inode->i_uid = cred->euid;
> +			inode->i_gid = cred->egid;
> +			rcu_read_unlock();
> +		} else {
> +			inode->i_uid = 0;
> +			inode->i_gid = 0;
> +		}
> +		security_task_to_inode(task, inode);
> +		return 1;
> +	}
> +out:
> +	d_drop(dentry);
> +	return 0;
> +}
> +
> +static const struct dentry_operations tid_map_files_dentry_operations = {
> +	.d_revalidate	= map_files_d_revalidate,
> +	.d_delete	= pid_delete_dentry,
> +};
> +
> +static int proc_map_files_get_link(struct dentry *dentry, struct inode *inode, struct path *path)
> +{
> +	unsigned long vm_start, vm_end;
> +	struct vm_area_struct *vma;
> +	struct task_struct *task;
> +	struct mm_struct *mm;
> +	int rc = -ENOENT;
> +
> +	task = get_proc_task(inode);
> +	if (!task)
> +		goto out;
> +
> +	mm = get_task_mm(task);
> +	put_task_struct(task);
> +	if (!mm)
> +		goto out;
> +
> +	if (map_name_to_addr(dentry->d_name.name,
> +			     &vm_start, &vm_end))
> +		goto out_mmput;
> +
> +	down_read(&mm->mmap_sem);
> +	vma = find_exact_vma(mm, vm_start, vm_end);
> +	if (vma && vma->vm_file) {
> +		*path = vma->vm_file->f_path;
> +		path_get(path);
> +		rc = 0;
> +	}
> +	up_read(&mm->mmap_sem);
> +
> +out_mmput:
> +	mmput(mm);
> +out:
> +	return rc;
> +}
> +
> +struct map_files_info {
> +	struct file	*file;
> +	unsigned char	name[16+16+2]; /* max: %016lx-%016lx\0 */
> +	unsigned long	len;
> +};
> +
> +static struct dentry *
> +proc_map_files_instantiate(struct inode *dir, struct dentry *dentry,
> +			   struct task_struct *task, const void *ptr)
> +{
> +	const struct file *file = ptr;
> +	struct proc_inode *ei;
> +	struct inode *inode;
> +
> +	if (!file)
> +		return ERR_PTR(-ENOENT);
> +
> +	inode = proc_pid_make_inode(dir->i_sb, task);
> +	if (!inode)
> +		return ERR_PTR(-ENOENT);
> +
> +	ei			= PROC_I(inode);
> +	ei->op.proc_get_link	= proc_map_files_get_link;
> +
> +	inode->i_op	= &proc_pid_link_inode_operations;
> +	inode->i_size	= 64;
> +	inode->i_mode	= S_IFLNK;
> +
> +	if (file->f_mode & FMODE_READ)
> +		inode->i_mode |= S_IRUSR | S_IXUSR;
> +	if (file->f_mode & FMODE_WRITE)
> +		inode->i_mode |= S_IWUSR | S_IXUSR;
> +
> +	d_set_d_op(dentry, &tid_map_files_dentry_operations);
> +	d_add(dentry, inode);
> +
> +	return NULL;
> +}
> +
> +static struct dentry *proc_map_files_lookup(struct inode *dir,
> +		struct dentry *dentry, struct nameidata *nd)
> +{
> +	unsigned long vm_start, vm_end;
> +	struct task_struct *task;
> +	struct vm_area_struct *vma;
> +	struct mm_struct *mm;
> +	struct dentry *result;
> +
> +	result = ERR_PTR(-ENOENT);
> +	task = get_proc_task(dir);
> +	if (!task)
> +		goto out_no_task;
> +
> +	result = ERR_PTR(-EPERM);
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ));
> +		goto out_no_mm;
> +
> +	result = ERR_PTR(-ENOENT);
> +	if (map_name_to_addr(dentry->d_name.name,
> +			     &vm_start, &vm_end))
> +		goto out_no_mm;
> +
> +	mm = get_task_mm(task);
> +	if (!mm)
> +		goto out_no_mm;
> +
> +	down_read(&mm->mmap_sem);
> +	vma = find_exact_vma(mm, vm_start, vm_end);
> +	if (!vma)
> +		goto out_no_vma;
> +
> +	result = proc_map_files_instantiate(dir, dentry, task, vma->vm_file);
> +
> +out_no_vma:
> +	up_read(&mm->mmap_sem);
> +	mmput(mm);
> +out_no_mm:
> +	put_task_struct(task);
> +out_no_task:
> +	return result;
> +}
> +
> +static const struct inode_operations proc_map_files_inode_operations = {
> +	.lookup		= proc_map_files_lookup,
> +	.setattr	= proc_setattr,
> +};
> +
> +static int proc_map_files_readdir(struct file *filp, void *dirent, filldir_t filldir)
> +{
> +	struct dentry *dentry = filp->f_path.dentry;
> +	struct inode *inode = dentry->d_inode;
> +	struct vm_area_struct *vma;
> +	struct task_struct *task;
> +	struct mm_struct *mm;
> +	unsigned int vmai;
> +	ino_t ino;
> +	int ret;
> +
> +	ret = -ENOENT;
> +	task = get_proc_task(inode);
> +	if (!task)
> +		goto out_no_task;
> +
> +	ret = -EPERM;
> +	if (!ptrace_may_access(task, PTRACE_MODE_READ))
> +		goto out;
> +
> +	ret = 0;
> +	switch (filp->f_pos) {
> +	case 0:
> +		ino = inode->i_ino;
> +		if (filldir(dirent, ".", 1, 0, ino, DT_DIR) < 0)
> +			goto out;
> +		filp->f_pos++;
> +	case 1:
> +		ino = parent_ino(dentry);
> +		if (filldir(dirent, "..", 2, 1, ino, DT_DIR) < 0)
> +			goto out;
> +		filp->f_pos++;
> +	default:
> +	{
> +		unsigned long nr_files, used, i;
> +		struct map_files_info *info;
> +
> +		mm = get_task_mm(task);
> +		if (!mm)
> +			goto out;
> +		down_read(&mm->mmap_sem);
> +
> +		nr_files = 0;
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			if (vma->vm_file)
> +				nr_files++;
> +		}
> +		if (!nr_files)
> +			goto out;

up_read(&mm->mmap_sem); ?

> +
> +		info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);
> +		if (!info) {
> +			ret = -ENOMEM;
> +			goto out;

Ditto.

> +		}
> +
> +		used = 0;
> +		for (vma = mm->mmap, vmai = 2; vma; vma = vma->vm_next) {
> +			if (!vma->vm_file)
> +				continue;
> +			vmai++;
> +			if (vmai <= filp->f_pos)
> +				continue;
> +
> +			get_file(vma->vm_file);
> +			info[used].file	= vma->vm_file;
> +			info[used].len	= snprintf(info[used].name,
> +						   sizeof(info[used].name),
> +						   "%lx-%lx", vma->vm_start,
> +						   vma->vm_end);
> +			used++;
> +		}
> +
> +		up_read(&mm->mmap_sem);
> +
> +		for (i = 0; i < used; i++) {
> +			ret = proc_fill_cache(filp, dirent, filldir,
> +					      info[i].name,
> +					      info[i].len,
> +					      proc_map_files_instantiate,
> +					      task, info[i].file);
> +			if (ret)
> +				break;
> +			filp->f_pos++;
> +		}
> +
> +		for (i = 0; i < used; i++)
> +			put_filp(info[i].file);
> +
> +		kfree(info);
> +		mmput(mm);
> +	}
> +	}
> +
> +out:
> +	put_task_struct(task);
> +out_no_task:
> +	return ret;
> +}
> +
> +static const struct file_operations proc_map_files_operations = {
> +	.read		= generic_read_dir,
> +	.readdir	= proc_map_files_readdir,
> +	.llseek		= default_llseek,
> +};
> +
>  /*
>   * /proc/pid/fd needs a special permission handler so that a process can still
>   * access /proc/self/fd after it has executed a setuid().
> @@ -2785,6 +3098,7 @@ static const struct inode_operations pro
>  static const struct pid_entry tgid_base_stuff[] = {
>  	DIR("task",       S_IRUGO|S_IXUGO, proc_task_inode_operations, proc_task_operations),
>  	DIR("fd",         S_IRUSR|S_IXUSR, proc_fd_inode_operations, proc_fd_operations),
> +	DIR("map_files",  S_IRUSR|S_IXUSR, proc_map_files_inode_operations, proc_map_files_operations),
>  	DIR("fdinfo",     S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdinfo_operations),
>  	DIR("ns",	  S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_operations),
>  #ifdef CONFIG_NET
> Index: linux-2.6.git/include/linux/proc_fs.h
> ===================================================================
> --- linux-2.6.git.orig/include/linux/proc_fs.h
> +++ linux-2.6.git/include/linux/proc_fs.h
> @@ -253,7 +253,7 @@ extern const struct proc_ns_operations u
>  extern const struct proc_ns_operations ipcns_operations;
>  
>  union proc_op {
> -	int (*proc_get_link)(struct inode *, struct path *);
> +	int (*proc_get_link)(struct dentry *, struct inode *, struct path *);
>  	int (*proc_read)(struct task_struct *task, char *page);
>  	int (*proc_show)(struct seq_file *m,
>  		struct pid_namespace *ns, struct pid *pid,
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

-- 
 Kirill A. Shutemov
