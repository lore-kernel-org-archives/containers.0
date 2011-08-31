From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 31 Aug 2011 15:50:18 -0700
Message-ID: <20110831155018.fba63834.akpm@linux-foundation.org>
References: <20110831075814.003575573@openvz.org>
	<20110831080229.100652529@openvz.org>
	<20110831090612.GA3253@albatros>
	<20110831112642.GI25465@sun>
	<20110831140416.GA17626@shutemov.name>
	<20110831142622.GB30615@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110831142622.GB30615@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Wed, 31 Aug 2011 18:26:22 +0400
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> fs, proc: Introduce the /proc/<pid>/map_files/ directory v8
> 
> From: Pavel Emelyanov <xemul@parallels.com>
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

I'm reluctant to merge large hunks c/r infrastructure before knowing
that it will actually be useful and used.

What it the state of your c/r effort?

What additional kernel patches will be needed to enable it?

Where are those patches?



This particular patch is distressingly similar to /proc/pid/maps and
smaps.  To justify a merge the changelog should clearly describe why
maps/smaps are unsuitable for this application and why they are
unfixable.

>
> ...
>
> --- linux-2.6.git.orig/fs/proc/base.c
> +++ linux-2.6.git/fs/proc/base.c
> @@ -2170,6 +2170,373 @@ static const struct file_operations proc
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

This function would be better with a little documentation.

It is quite generic and it may be the case that other parts of the
kernel are already doing this in an open-coded fashion.  Perhaps it
should be placed in mm/mmap.c along with the other vma manipulation
library code.  This would add a small amount of dead code to
CONFIG_PROC_FS=n builds.

> +static int map_name_to_addr(const unsigned char *name, unsigned long *start, unsigned long *end)
> +{
> +	int ret = -EINVAL;
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

Again, documentation would improve this code.  At least describe the
parsed input format.

simple_strtoul() is obsolete.  Use kstrto*().  There is a new
checkpatch rule pending for this.

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

This is nasty.  We have a pointer to a vma, but we drop the locks and
refcounts which protect that vma.  So we have a local pointer which we
cannot dereference.  It's a bit of a hand-grenade.

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

And indeed it was not dereferenced (yet).  It is treated as a bool.

Would it not be nicer, safer and clearer to turn the pointer-as-a-bool
into a bool?

	bool matching_vma_found = !!find_exact_vma(mm, vm_start, vm_end);

> +	}
> +out:
> +	d_drop(dentry);
> +	return 0;
> +}
> +
>
> ...
>
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

The fancy indenting is atypical for kernel code.

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
>
> ...
>
> +/*
> + * NOTE: The getattr/setattr for both /proc/$pid/map_files and
> + * /proc/$pid/fd seems to have share the code, so need to be
> + * unified and code duplication eliminated!

Why not do this now?

> + */
> +
> +int proc_map_files_setattr(struct dentry *dentry, struct iattr *attr)

static

> +{
> +	struct inode *inode = dentry->d_inode;
> +	struct task_struct *task;
> +	int ret = -EACCES;
> +
> +	task = get_proc_task(inode);
> +	if (!task)
> +		return -ESRCH;
> +
> +	if (!lock_trace(task)) {
> +		ret = proc_setattr(dentry, attr);
> +		unlock_trace(task);
> +	}
> +
> +	put_task_struct(task);
> +	return ret;
> +}
> +
>
> ...
>
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
> +		struct map_files_info *info = NULL;
> +		unsigned long nr_files, used, i;
> +
> +		mm = get_task_mm(task);
> +		if (!mm)
> +			goto out;
> +		down_read(&mm->mmap_sem);
> +
> +		nr_files = 0;
> +		used = 0;
> +
> +		/*
> +		 * We need two passes here:
> +		 *  1) Collect vmas of mapped files with mmap_sem taken
> +		 *  2) Release mmap_sem and instantiate entries
> +		 * othrewise we get lockdep complains since filldir
> +		 * might sleep.

Why would a sleep-inside-mmap_sem cause a lockdep warning?

> +		 */
> +
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			if (vma->vm_file)
> +				nr_files++;
> +		}
> +
> +		if (nr_files) {
> +			info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);

I calculate sizeof(*info) to be 50 bytes.  nr_files can easily be in
the thousands.

So this kmalloc will be far too large on large applications.  This is a
must-fix.  Fixing it with vmalloc() is lame.

> +			if (!info)
> +				ret = -ENOMEM;
> +			for (vma = mm->mmap, vmai = 2; vma && info; vma = vma->vm_next) {

What does "vmai" mean?  "vma index"?  If so, call it vma_index.  If
not, call it something else which is meaningful.

vmai/vma_index could be made local to this code block.

> +				if (!vma->vm_file)
> +					continue;
> +				vmai++;
> +				if (vmai <= filp->f_pos)
> +					continue;
> +
> +				get_file(vma->vm_file);
> +				info[used].file	= vma->vm_file;
> +				info[used].len	= snprintf(info[used].name,
> +							   sizeof(info[used].name),
> +							   "%lx-%lx",
> +							   vma->vm_start,
> +							   vma->vm_end);
> +				used++;
> +			}
> +		}
> +
> +		up_read(&mm->mmap_sem);
> +
> +		for (i = 0; i < used; i++) {
> +			ret = proc_fill_cache(filp, dirent, filldir,
> +					      info[i].name, info[i].len,
> +					      proc_map_files_instantiate,
> +					      task, info[i].file);
> +			if (ret)
> +				break;
> +			filp->f_pos++;
> +		}
> +
> +		for (i = 0; i < used; i++)
> +			put_filp(info[i].file);

Why not do the put_filp() in the previous loop and avoid some cache misses?

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
>
> ...
>

