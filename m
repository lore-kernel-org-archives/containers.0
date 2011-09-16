From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v12
Date: Fri, 16 Sep 2011 21:56:18 +0400
Message-ID: <20110916175618.GA20046@albatros>
References: <20110914113912.GQ25367@sun>
 <20110914134405.GV25367@sun>
 <20110914144841.GA7906@albatros>
 <20110914160018.GW25367@sun>
 <20110914160724.GA10612@albatros>
 <20110915091417.GA27755@sun>
 <20110915092757.GA23404@albatros>
 <20110915102922.GB27755@sun>
 <20110915105651.GA17575@albatros>
 <20110915201939.GE12040@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110915201939.GE12040@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm00@gmail.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Kirill Shutemov <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, James Bottomley <jbottomley@parallels.com>, Nathan Lynch <ntl@pobox.com>, Zan Lynx <zlynx@acm.org>, Daniel Lezcano <dlezcano@fr.ibm.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

Hi Cyrill,

On Fri, Sep 16, 2011 at 00:19 +0400, Cyrill Gorcunov wrote:
> On Thu, Sep 15, 2011 at 02:56:51PM +0400, Vasiliy Kulikov wrote:
> ...
> > > > 
> > > > How can you restore a set of processes in case they share an RW mapping
> > > > as RW in both tasks if you deny opening /proc/$pid/map_files/$address as W?
> > > 
> > > I can read the link first to figure out the file path and re-open it as rw via
> > > path itself (which implies the restorer still must have enough rights to open
> > > it as rw).
> > 
> > And what about RW mapping of unlinked files?
> > 
> 
> So we indeed still need RW-capable links there. To break a tie the
> CAP_SYS_ADMIN requirement being put into, so without such capabilities
> granted there should be no way to mis-use this iterface (still there
> is an opportunity to enhance/relax permissions if we ever need).
> 
> Vasiliy, check it please. Restored unlinking files is a different target
> not addressed by this patch.
> 
> 	Cyrill
> ---
> fs, proc: Introduce the /proc/<pid>/map_files/ directory v14
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
> This *helps* checkpointing process in three ways:
> 
> 1. When dumping a task mappings we do know exact file that is mapped by particular
>    region. We do this by opening /proc/$pid/map_files/$address symlink the way we do
>    with file descriptors.
> 
> 2. This also helps in determining which anonymous shared mappings are shared with
>    each other by comparing the inodes of them.
> 
> 3. When restoring a set of processes in case two of them has a mapping shared, we map
>    the memory by the 1st one and then open its /proc/$pid/map_files/$address file and
>    map it by the 2nd task.
> 
> Using /proc/$pid/maps for this is quite inconvenient since it brings repeatable
> re-reading and reparsing for this text file which slows down restore procedure
> significantly. Also as being pointed in (3) it is a way easier to use top level
> shared mapping in children as /proc/$pid/map_files/$address when needed.
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
> v5: (feedback by Kirill A. Shutemov)
>  - don't forget to release mmap_sem on error path
> 
> v6:
>  - sizeof get used in map_files_info which shrink member a bit on
>    x86-32 (by Kirill A. Shutemov)
>  - map_name_to_addr returns -EINVAL instead of -1
>    which is more appropriate (by Tejun Heo)
> 
> v7:
>  - add [get/set]attr handlers for
>    proc_map_files_inode_operations (by Vasiliy Kulikov)
> 
> v8:
>  - Kirill A. Shutemov spotted a parasite semicolon
>    which ruined the ptrace_check call, fixed.
> 
> v9: (feedback by Andrew Morton)
>  - find_exact_vma moved into include/linux/mm.h as an inline helper
>  - proc_map_files_setattr uses either kmalloc or vmalloc depending
>    on how many objects are to be allocated
>  - no more map_name_to_addr but dname_to_vma_addr introduced instead
>    and it uses sscanf because in one case the find_exact_vma() is used
>    only to confirm existence of vma area the boolean flag is used
>  - fancy justification dropped
>  - still the proc_map_files_get/setattr leaved untouched
>    until additional fd/ patches applied first.
> 
> v10: (feedback by Andrew Morton)
>  - flex_arrays are used instead of kmalloc/vmalloc calls
>  - map_files_d_revalidate use ptrace_may_access for
>    security reason (by Vasiliy Kulikov)
> 
> v11:
>  - should use fput and drop !ret test from a loop code
>    (feedback by Andrew Morton)
>  - no need for 'used' variable, use existing
>    nr_files with file->pos predicate
>  - if preallocation fails no need to go further,
>    simply release mmap semaphore and jump out
> 
> v12:
>  - rework map_files_d_revalidate to make sure
>    the task get released on return (by Vasiliy Kulikov)
> 
> v13:
>  - proc_map_files_inode_operations are set to be the same
>    as proc_fd_inode_operations, ie to include .permission
>    pointing to proc_fd_permission
> 
> v14: (by Vasiliy Kulikov)
>  - for security reason map_files/ entries are allowed for
>    readers with CAP_SYS_ADMIN credentials granted only

This changelog is currently much longer than the commit description text ;)

> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> CC: Tejun Heo <tj@kernel.org>
> CC: Vasiliy Kulikov <segoon@openwall.com>
> CC: "Kirill A. Shutemov" <kirill@shutemov.name>
> CC: Alexey Dobriyan <adobriyan@gmail.com>
> CC: Al Viro <viro@ZenIV.linux.org.uk>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Pavel Machek <pavel@ucw.cz>
> ---
>  fs/proc/base.c     |  343 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mm.h |   12 +
>  2 files changed, 355 insertions(+)
> 
> Index: linux-2.6.git/fs/proc/base.c
> ===================================================================
> --- linux-2.6.git.orig/fs/proc/base.c
> +++ linux-2.6.git/fs/proc/base.c
> @@ -83,6 +83,7 @@
>  #include <linux/pid_namespace.h>
>  #include <linux/fs_struct.h>
>  #include <linux/slab.h>
> +#include <linux/flex_array.h>
>  #ifdef CONFIG_HARDWALL
>  #include <asm/hardwall.h>
>  #endif
> @@ -133,6 +134,8 @@ struct pid_entry {
>  		NULL, &proc_single_file_operations,	\
>  		{ .proc_show = show } )
>  
> +static int proc_fd_permission(struct inode *inode, int mask);
> +
>  /*
>   * Count the number of hardlinks for the pid_entry table, excluding the .
>   * and .. links.
> @@ -2201,6 +2204,345 @@ static const struct file_operations proc
>  };
>  
>  /*
> + * dname_to_vma_addr - maps a dentry name into two unsigned longs
> + * which represent vma start and end addresses.
> + */
> +static int dname_to_vma_addr(struct dentry *dentry,
> +			     unsigned long *start, unsigned long *end)
> +{
> +	if (sscanf(dentry->d_name.name, "%lx-%lx", start, end) != 2)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +
> +static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
> +{
> +	unsigned long vm_start, vm_end;
> +	bool exact_vma_exists = false;
> +	struct mm_struct *mm = NULL;
> +	struct task_struct *task;
> +	const struct cred *cred;
> +	struct inode *inode;
> +	int status = 0;
> +
> +	if (nd && nd->flags & LOOKUP_RCU)
> +		return -ECHILD;
> +
> +	if (!capable(CAP_SYS_ADMIN))
> +		goto out_notask;

As I said off-list, it's a pitty that only a root dumper process may
dump a task.  However, for the specific usecase - C/R - it should be OK.

> +
> + inode = dentry->d_inode;
> + task = get_proc_task(inode);
> + if (!task)
> +         goto out_notask;
> +
> + if (!ptrace_may_access(task, PTRACE_MODE_READ))
> +         goto out;

While this is not needed with capable() check, it's OK to keep it for
the future more finegranted access checks.

BTW, not a big deal, but probably you should return -EACCES on
!capable() as file presence is not an issue in this case.

    if (!ptrace_may_access(task, PTRACE_MODE_READ))
        goto out_notask;

    status = -EACCES;
    if (!capable(CAP_SYS_ADMIN))
        goto out_notask;

    status = 0;


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
