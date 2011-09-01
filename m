From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Thu, 1 Sep 2011 15:49:46 -0700
Message-ID: <20110901154946.b43ba91b.akpm@linux-foundation.org>
References: <20110831075814.003575573@openvz.org>
	<20110831080229.100652529@openvz.org>
	<20110831090612.GA3253@albatros>
	<20110831112642.GI25465@sun>
	<20110831140416.GA17626@shutemov.name>
	<20110831142622.GB30615@sun>
	<20110831151023.5b7e12da.akpm@linux-foundation.org>
	<20110901104633.GG30615@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110901104633.GG30615@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vasiliy Kulikov <segoon@openwall.com>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Thu, 1 Sep 2011 14:46:34 +0400
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Wed, Aug 31, 2011 at 03:10:23PM -0700, Andrew Morton wrote:
> > 
> > This function would benefit from a code comment.
> > 
> > Given that it's pretty generic (indeed there might be open-coded code
> > which already does this elsewhere), perhaps it should be in mm/mmap.c
> > as a kernel-wide utility function.  That will add a little overhead to
> > CONFIG_PROC_FS=n builds, which doesn't seem terribly important.
> > 
> 
> Andrew, here is an attempt to address concerns. Please review.
> Complains are welcome as always!

Changelog still doesn't explain why /proc/pid/maps is unfixably unsuitable.

>
> ...
>
> +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> +{
> +	unsigned long vm_start, vm_end;
> +	struct task_struct *task;
> +	const struct cred *cred;
> +	struct mm_struct *mm;
> +	struct inode *inode;
> +
> +	bool exact_vma_exists = false;
>

Extraneous newline there.

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
> +	if (!dname_to_vma_addr(dentry, &vm_start, &vm_end)) {
> +		down_read(&mm->mmap_sem);
> +		exact_vma_exists = !!find_exact_vma(mm, vm_start, vm_end);
> +		up_read(&mm->mmap_sem);
> +	}
> +
> +	mmput(mm);
> +
> +	if (exact_vma_exists) {
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
> +		unsigned long nr_files, used, pos, i;
> +		unsigned long mem_size = 0;
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
> +		 *
> +		 *  1) Collect vmas of mapped files with mmap_sem taken
> +		 *  2) Release mmap_sem and instantiate entries
> +		 *
> +		 * otherwise we get lockdep complained, since filldir()
> +		 * routine might require mmap_sem taken in might_fault().
> +		 */
> +
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			if (vma->vm_file)
> +				nr_files++;
> +		}
> +
> +		if (nr_files) {
> +			mem_size = nr_files * sizeof(*info);
> +			if (mem_size <= KMALLOC_MAX_SIZE)
> +				info = kmalloc(mem_size, GFP_KERNEL);
> +			else
> +				info = vmalloc(mem_size);

This still sucks :(

A KMALLOC_MAX_SIZE allocation is huuuuuuuuuuuuge!  I don't know how big
it is nowadays, but over 100 kbytes.  This will frequently send page
reclaim on a berzerk rampage freeing *thousands* of pages (or
relocating pages) until it manages to generate 20 or 30 physically
contiguous free pages.

Also, vmalloc sucks.  The more often we perform vmallocs (with a mix of
differently-sized ones), the more internally fragmented the vmalloc
arena will become.  With some workloads we'll run out of
sufficiently-large contiguous free spaces and things will start
failing.  This doesn't happen often.  Yet.  But the more vmalloc()
callsites we add, the more likely and the more frequent it becomes.  So
vmalloc is something we should only use as a last resort.

The most robust implementation here is to allocate a large number of
small objects - one per vma.  A list would be a suitable way of
managing them.

But do we *really* need to do it in two passes?  Avoiding the temporary
storage would involve doing more work under mmap_sem, and a put_filp()
under mmap_sem might be problematic.

