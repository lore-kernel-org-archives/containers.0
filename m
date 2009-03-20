From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 18/23] Prepare to support shared memory
Date: Fri, 20 Mar 2009 14:27:53 -0700
Message-ID: <1237584473.8286.307.camel@nimitz>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-19-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237574868-3371-19-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-03-20 at 14:47 -0400, Oren Laadan wrote:
> diff --git a/checkpoint/checkpoint_mem.h b/checkpoint/checkpoint_mem.h
> index de1d4c8..3157dde 100644
> --- a/checkpoint/checkpoint_mem.h
> +++ b/checkpoint/checkpoint_mem.h
> @@ -43,4 +43,22 @@ static inline int cr_pgarr_nr_free(struct cr_pgarr *pgarr)
>         return CR_PGARR_TOTAL - pgarr->nr_used;
>  }
> 
> +/*
> + * This probably belongs in include/linux/mm.h
> + */
> +
> +/* Flag allocation requirements to shmem_getpage and shmem_swp_alloc */
> +enum sgp_type {
> +       SGP_READ,       /* don't exceed i_size, don't allocate page */
> +       SGP_CACHE,      /* don't exceed i_size, may allocate page */
> +       SGP_DIRTY,      /* like SGP_CACHE, but set new page dirty */
> +       SGP_WRITE,      /* may exceed i_size, may allocate page */
> +};
> +
> +int shmem_getpage(struct inode *inode, unsigned long idx,
> +                 struct page **pagep, enum sgp_type sgp, int *type);
> +
> +extern struct vm_operations_struct shmem_vm_ops;
> +extern struct vm_operations_struct shm_vm_ops;
...
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -103,8 +103,8 @@ static unsigned long shmem_default_max_inodes(void)
>  }
>  #endif
> 
> -static int shmem_getpage(struct inode *inode, unsigned long idx,
> -                        struct page **pagep, enum sgp_type sgp, int *type);
> +int shmem_getpage(struct inode *inode, unsigned long idx,
> +                 struct page **pagep, enum sgp_type sgp, int *type);

Personally, I think it is bad form to export someone else's function for
them.  Please move the current shmem.c function declaration to a header
that can be included by both the c/r code and shmem.c

> /* return the subtype of a shared vma segment */
> static enum vm_type cr_shared_vma_type(struct vm_area_struct *vma, int new)
> {
>         enum vm_type vma_type;
> 
>         if (vma->vm_ops == &shmem_vm_ops)       /* /dev/zero or anonymous */
>                 vma_type = CR_VMA_SHM_ANON;
>         else if (vma->vm_ops == &shm_vm_ops)    /* IPC (unsupported yet) */
>                 vma_type = -EINVAL;
>         else
>                 vma_type = CR_VMA_SHM_FILE;
> 
>         if (!new && vma_type == CR_VMA_SHM_ANON)
>                 vma_type = CR_VMA_SHM_ANON_SKIP;
> 
>         return vma_type;
> }

This just looks really fragile to me.  The first thing that comes up in
my cscope is bf5xx_pcm_mmap().  That is VM_SHARED, but is *certainly*
not CR_VMA_SHM_FILE.  

Instead of *checking* vma->vm_ops, I believe the more correct solutions
here is to add an new vm_op which can be asked for its CR_VMA_* type.

-- Dave
