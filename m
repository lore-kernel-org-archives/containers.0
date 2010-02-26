From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 09/12] Move mmap checkpoint/restart into mm/mmap.c
Date: Fri, 26 Feb 2010 12:48:10 -0600
Message-ID: <1267210090.15300.108.camel@localhost.localdomain>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
	<385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
	<c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2010-02-26 at 00:45 -0800, Matt Helsley wrote:
> Moving the memory pieces is more complicated because portions of it are
> shared with ipc. Split the mm header bits into another
> header file: include/linux/mm_checkpoint.h file so it's clear that these
> are the only pieces we need in ipc/

> diff --git a/include/linux/mm_checkpoint.h b/include/linux/mm_checkpoint.h
> new file mode 100644
> index 0000000..0092321
> --- /dev/null
> +++ b/include/linux/mm_checkpoint.h
> @@ -0,0 +1,45 @@
> +#ifndef _LINUX_MM_CHECKPOINT_H
> +#define _LINUX_MM_CHECKPOINT_H
> +
> +#include <linux/checkpoint.h> /* for ckpt_obj_fetch, restore_read_page */

But ckpt_obj_fetch and restore_read_page aren't referred to in this
file?  I understand that users of mm_checkpoint.h may need those APIs
but it's more conventional for those users to include the appropriate
headers directly.


> +#include <linux/checkpoint_hdr.h> /* for struct ckpt_hdr_vma */
> +#include <linux/checkpoint_types.h> /* for struct ckpt_ctx */

You can just declare these like so:

struct ckpt_hdr_vma;
struct ckpt_ctx;

Need similar for inode, vm_area_struct, etc. -- I think so far you're
just getting lucky because checkpoint headers are included late and the
headers for the objects they refer to have already been included.


> +
> +extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
> +
> +extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
> +extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
> +
> +extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
> +
> +extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
> +				      struct vm_area_struct *vma,
> +				      struct inode *inode);
> +extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
> +
> +/* common vma checkpoint/restore operations */
> +extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
> +				  struct vm_area_struct *vma,
> +				  enum vma_type type,
> +				  int vma_objref, int ino_objref);
> +extern unsigned long generic_vma_restore(struct mm_struct *mm,
> +					 struct file *file,
> +					 struct ckpt_hdr_vma *h);
> +extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
> +				  struct vm_area_struct *vma,
> +				  enum vma_type type,
> +				  int vma_objref);
> +extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
> +			       struct file *file, struct ckpt_hdr_vma *h);
> +extern int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
> +				struct vm_area_struct *vma,
> +				enum vma_type type,
> +				int ino_objref);
> +
> +
> +#define CKPT_VMA_NOT_SUPPORTED						\
> +	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
> +	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
> +	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
> +
> +#endif /* _LINUX_MM_CHECKPOINT_H */


> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index 379eaed..e187078 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -173,12 +173,6 @@ extern void proc_net_remove(struct net *net, const char *name);
>  extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
>  	struct proc_dir_entry *parent);
>  
> -/* While the {get|set|dup}_mm_exe_file functions are for mm_structs, they are
> - * only needed to implement /proc/<pid>|self/exe so we define them here. */
> -extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
> -extern struct file *get_mm_exe_file(struct mm_struct *mm);
> -extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
> -
>  #else
>  
>  #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
> @@ -226,19 +220,6 @@ static inline void pid_ns_release_proc(struct pid_namespace *ns)
>  {
>  }
>  
> -static inline void set_mm_exe_file(struct mm_struct *mm,
> -				   struct file *new_exe_file)
> -{}
> -
> -static inline struct file *get_mm_exe_file(struct mm_struct *mm)
> -{
> -	return NULL;
> -}
> -
> -static inline void dup_mm_exe_file(struct mm_struct *oldmm,
> -	       			   struct mm_struct *newmm)
> -{}
> -
>  #endif /* CONFIG_PROC_FS */
>  
>  #if !defined(CONFIG_PROC_KCORE)
> diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
> index 4322dea..2b05067 100644
> --- a/ipc/checkpoint.c
> +++ b/ipc/checkpoint.c
> @@ -15,8 +15,7 @@
>  #include <linux/msg.h>
>  #include <linux/sched.h>
>  #include <linux/ipc_namespace.h>
> -#include <linux/checkpoint.h>
> -#include <linux/checkpoint_hdr.h>
> +#include <linux/mm_checkpoint.h>

I'm not sure I understand the reason for this kind of change in this
patch.  ipc/checkpoint.c surely uses the APIs in checkpoint.h and
checkpoint_hdr.h so it should include them directly -- that's the usual
Linux practice AFAIK.  By all means, if there's a foo.c that needs only
the APIs in mm_checkpoint.h, then it should include only that.
