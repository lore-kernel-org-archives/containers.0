From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Wed, 31 Aug 2011 15:10:23 -0700
Message-ID: <20110831151023.5b7e12da.akpm@linux-foundation.org>
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

> On Wed, Aug 31, 2011 at 05:04:16PM +0300, Kirill A. Shutemov wrote:
> ...
> > > 
> > > OK, here is an updated one. Thanks for feedback. Hope this time
> > > all nits are addressed. Still reviews/complains are *very* appreciated.
> > 
> > Please run checkpatch. It points several warnings and one dangerous error.
> > 
> 
> This one passes checkpatch without error (thanks again Kirill for spotting
> the parasite semicolon there!).
> 
> 	Cyrill
> ---
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

I'm reluctant to merge something like this unless/until it has real
use-cases.

What is the status of your c/r effort?

What additional kernel patches are required to bring that effort to a
usable state and where are those patches?

IOW, before starting to merge things I'd like to get an understanding
of what *all* the patches look like and of what level of c/r
functionality they provide.


This particular patch introduces a distressing amount of duplication of
/proc/pid/maps.  The changelog should provide a really good
justification for doing this: why is /proc/pid/maps (and smaps!)
unsuitable and why cannot maps/smaps be fixed to be suitable?

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

This function would benefit from a code comment.

Given that it's pretty generic (indeed there might be open-coded code
which already does this elsewhere), perhaps it should be in mm/mmap.c
as a kernel-wide utility function.  That will add a little overhead to
CONFIG_PROC_FS=n builds, which doesn't seem terribly important.

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

Again, a little bit of interface documentation would be nice.  Explain
what the parsed input format is, at least.

simple_strtoul() is obsolete - use kstrto*().  A checkpatch rule for
this is queued.

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

OK, this is nasty.  We have a local variable which points to a vma but
then we release the locks and refcounts which protect that vma.  So we
have a pointer which we cannot dereference.  That's dangerous.

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

And we don't actually dereference it - at present.  We use it as a bool.

Would it not be nicer, safer and clearer to turn this pointer-as-a-bool
into a bool?

	bool matching_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);

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

The fancy indenting is not a thing we usually do in the kernel.

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

typo

> +		 * might sleep.
> +		 */

Why would lockdep complain about sleep-inside-mmap_sem?

> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			if (vma->vm_file)
> +				nr_files++;
> +		}
> +
> +		if (nr_files) {
> +			info = kmalloc(nr_files * sizeof(*info), GFP_KERNEL);

I figure sizeof(*info) = 50 bytes.  nr_files can easily be >1000.

On large some applications the kmalloc attempt will be too large.  This
is a must-fix.  Using vmalloc() would be very lame.

> +			if (!info)
> +				ret = -ENOMEM;
> +			for (vma = mm->mmap, vmai = 2; vma && info; vma = vma->vm_next) {
> +				if (!vma->vm_file)
> +					continue;
> +				vmai++;

What is "vmai"?  "vma index"?  If so, please call it vma_index.  If
not, please call it something better anyway.

vmai/vma_index could be made local to this code block.

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

Why not do the put_filp() in the previous loop and avoid some cache
misses?

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
>
> ...
>

