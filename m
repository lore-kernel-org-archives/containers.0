From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 21/29] Dump anonymous- and file-mapped-
	shared memory
Date: Wed, 1 Apr 2009 18:06:57 -0500
Message-ID: <20090401230657.GB27725@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-22-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-22-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> We now handle anonymous and file-mapped shared memory. Support for IPC
> shared memory requires support for IPC first. We extend cr_write_vma()
> to detect shared memory VMAs and handle it separately than private
> memory.
> 
> There is not much to do for file-mapped shared memory, except to force
> msync() on the region to ensure that the file system is consistent
> with the checkpoint image. Use our internal type CR_VMA_SHM_FILE.
> 
> Anonymous shared memory is always backed by inode in shmem filesystem.
> We use that inode to look up the VMA in the objhash and register it if
> not found (on first encounter). In this case, the type of the VMA is
> CR_VMA_SHM_ANON, and we dump the contents. On the other hand, if it is
> found there, we must have already saved it before, so we change the
> type to CR_VMA_SHM_ANON_SKIP and skip it.
> 
> To dump the contents of a shmem VMA, we loop through the pages of the
> inode in the shmem filesystem, and dump the contents of each dirty
> (allocated) page - unallocated pages must be clean.
> 
> Note that we save the original size of a shmem VMA because it may have
> been re-mapped partially. The format itself remains like with private
> VMAs, except that instead of addresses we record _indices_ (page nr)
> into the backing inode.
> 
> Changelog[v14]:
>   - Introduce patch
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Some nits though:

...

> +/**
> + * cr_vma_fill_pgarr - fill a page-array with addr/page tuples
>   * @ctx - checkpoint context

@shm - 

>   * @vma - vma to scan
>   * @start - start address (updated)
> + * @start - end address (updated)
>   *
> + * For private vma, records addr/page tuples. For shared vma, records
> + * index/page (index is the index of the page in the shmem object).
>   * Returns the number of pages collected
>   */
> -static int
> -cr_private_vma_fill_pgarr(struct cr_ctx *ctx, struct vm_area_struct *vma,
> -			  unsigned long *start)
> +static int cr_vma_fill_pgarr(struct cr_ctx *ctx, int shm,
> +			     struct vm_area_struct *vma, struct inode *ino,
> +			     unsigned long *start, unsigned long end)

...

>  /**
> - * cr_write_private_vma_contents - dump contents of a VMA with private memory
> + * cr_write_vma_contents - dump contents of a VMA
>   * @ctx - checkpoint context
>   * @vma - vma to scan

again lots of new args to comment

>   *
> @@ -367,17 +429,18 @@ static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
>   * virtual addresses into ctx->pgarr_list page-array chain. Then dump
>   * the addresses, followed by the page contents.
>   */
> -static int
> -cr_write_private_vma_contents(struct cr_ctx *ctx, struct vm_area_struct *vma)
> +static int cr_write_vma_contents(struct cr_ctx *ctx, int shm,
> +				 struct vm_area_struct *vma, struct inode *ino,
> +				 unsigned long start, unsigned long end)

...

> +/**
> + * cr_write_shared_vma_contents - dump contents of a VMA with shared memory
> + * @ctx - checkpoint context
> + * @vma - vma to scan
> + */
> +static int cr_write_shared_vma_contents(struct cr_ctx *ctx,
> +					struct vm_area_struct *vma,
> +					enum cr_vma_type vma_type)
> +{
> +	struct inode *inode;
> +	int ret = 0;
> +
> +	/*
> +	 * Citing mmap(2): "Updates to the mapping are visible to other
> +	 * processes that map this file, and are carried through to the
> +	 * underlying file. The file may not actually be updated until
> +	 * msync(2) or munmap(2) is called"
> +	 *
> +	 * Citing msync(2): "Without use of this call there is no guarantee
> +	 * that changes are written back before munmap(2) is called."
> +	 *
> +	 * Force msync for region of shared mapped files, to ensure that
> +	 * that the file system is consistent with the checkpoint image.
> +	 * (inspired by sys_msync).
> +	 *
> +	 * [FIXME: call vfs_sync only once per shared segment]
> +	 */
> +
> +	switch (vma_type) {
> +	case CR_VMA_SHM_FILE:
> +		/* no need for contents that are stored in the file system */
> +		ret = vfs_fsync(vma->vm_file, vma->vm_file->f_path.dentry, 0);
> +		break;
> +	case CR_VMA_SHM_ANON:
> +		/* save the contents of this resgion */
> +		inode = vma->vm_file->f_dentry->d_inode;
> +		ret = cr_write_shmem_contents(ctx, inode);
> +		break;
> +	case CR_VMA_SHM_ANON_SKIP:
> +	case CR_VMA_SHM_FILE_SKIP:
> +		/* already saved before .. skip now */
> +		break;
> +	default:
> +		BUG();

Well, no - since the user can feed in whatever crap they want,
this isn't a *bug*, right?

> +	}
> +
> +	return ret;
> +}
> +
> +/* return the subtype of a private vma segment */
> +static enum cr_vma_type cr_private_vma_type(struct vm_area_struct *vma)
> +{
> +	if (vma->vm_file)
> +		return CR_VMA_FILE;
> +	else
> +		return CR_VMA_ANON;
> +}
> +
> +/*
> + * cr_shared_vma_type - return the subtype of a shared vma
> + * @vma: target vma
> + * @old: 0 if shared segment seen first time, else 1
> + */
> +static enum cr_vma_type cr_shared_vma_type(struct vm_area_struct *vma, int old)
> +{
> +	enum cr_vma_type vma_type = -ENOSYS;
> +
> +	if (vma->vm_ops && vma->vm_ops->cr_vma_type) {
> +		vma_type = (*vma->vm_ops->cr_vma_type)(vma);
> +		if (old)
> +			vma_type = cr_vma_type_skip(vma_type);

Heh, well that seems a little more obtuse than it needs to be...  Seems
like just doing vma_type++ would keep the reader more grounded about
what is going on.  But I'm not asking you to change it (bc I'm sure
someone likes it and would ask to change it back)

...

>  struct cr_hdr_vma {
>  	__u32 vma_type;
> -	__u32 vma_objref;	/* for vma->vm_file */
> +	__s32 vma_objref;	/* objref of backing file */
> +	__s32 shm_objref;	/* objref of shared segment */

You're going to upset Alexey again with the signeds, aren't you?

> +	__u32 _padding;
> +	__u64 shm_size;		/* size of shared segment */
> 
>  	__u64 vm_start;
>  	__u64 vm_end;
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 53118f0..06aeda5 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -28,6 +28,7 @@
>  #include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/swap.h>
> +#include <linux/checkpoint_hdr.h>
> 
>  static struct vfsmount *shm_mnt;
> 
> @@ -1470,6 +1471,13 @@ static struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
>  }
>  #endif
> 
> +#ifdef CONFIG_CHECKPOINT
> +static int shmem_cr_vma_type(struct vm_area_struct *vma)
> +{
> +	return CR_VMA_SHM_ANON;
> +}
> +#endif
> +
>  int shmem_lock(struct file *file, int lock, struct user_struct *user)
>  {
>  	struct inode *inode = file->f_path.dentry->d_inode;
> @@ -2477,6 +2485,9 @@ static struct vm_operations_struct shmem_vm_ops = {
>  	.set_policy     = shmem_set_policy,
>  	.get_policy     = shmem_get_policy,
>  #endif
> +#ifdef CONFIG_CHECKPOINT
> +	.cr_vma_type	= shmem_cr_vma_type,
> +#endif
>  };
> 
> 
> -- 
> 1.5.4.3
