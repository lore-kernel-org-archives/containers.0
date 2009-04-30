From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 08/54] Dump memory address space
Date: Wed, 29 Apr 2009 21:54:48 -0700
Message-ID: <20090430045448.GB11734@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-9-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1240961064-13991-9-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 28, 2009 at 07:23:38PM -0400, Oren Laadan wrote:
> For each VMA, there is a 'struct ckpt_vma'; if the VMA is file-mapped,
> it will be followed by the file name. Then comes the actual contents,
> in one or more chunk: each chunk begins with a header that specifies
> how many pages it holds, then the virtual addresses of all the dumped
> pages in that chunk, followed by the actual contents of all dumped
> pages. A header with zero number of pages marks the end of the contents.
> Then comes the next VMA and so on.
> 
> To checkpoint a vma, call the ops->checkpoint() method of that vma.
> Normally the per-vma function will invoke generic_vma_checkpoint()
> which first writes the vma description, followed by the specific
> logic to dump the contents of the pages.
> 
> Currently for private mapped memory we save the pathname of the file
> that is mapped (restart will use it to re-open it and then map it).
> Later we change that to reference a file object.
> 
> Changelog[v14]:
>   - Modify the ops->checkpoint method to be much more powerful
>   - Improve support for VDSO (with special_mapping checkpoint callback)
>   - Save new field 'vdso' in mm_context
>   - Revert change to pr_debug(), back to ckpt_debug()
>   - Check whether calls to ckpt_hbuf_get() fail
>   - Discard field 'h->parent'

<snipped previous bits of changelog...>

> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  arch/x86/Kconfig                      |    1 +
>  arch/x86/include/asm/checkpoint_hdr.h |    7 +
>  arch/x86/mm/checkpoint.c              |   32 ++
>  checkpoint/Makefile                   |    2 +-
>  checkpoint/checkpoint.c               |   24 ++
>  checkpoint/checkpoint_arch.h          |    1 +
>  checkpoint/files.c                    |   88 +++++
>  checkpoint/memory.c                   |  600 +++++++++++++++++++++++++++++++++
>  checkpoint/process.c                  |    4 +
>  checkpoint/sys.c                      |    9 +
>  include/linux/checkpoint.h            |   25 ++-
>  include/linux/checkpoint_hdr.h        |   39 +++
>  include/linux/checkpoint_types.h      |   10 +
>  mm/filemap.c                          |   30 ++
>  mm/mmap.c                             |   30 ++
>  15 files changed, 900 insertions(+), 2 deletions(-)
>  create mode 100644 checkpoint/files.c
>  create mode 100644 checkpoint/memory.c

<snipped lots of patch>
 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3303d1b..6b75359 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -34,6 +34,10 @@
>  #include <asm/tlb.h>
>  #include <asm/mmu_context.h>
> 
> +#include <linux/checkpoint_types.h>
> +#include <linux/checkpoint_hdr.h>
> +#include <linux/checkpoint.h>
> +
>  #include "internal.h"
> 
>  #ifndef arch_mmap_check
> @@ -2268,9 +2272,35 @@ static void special_mapping_close(struct vm_area_struct *vma)
>  {
>  }
> 
> +#if CONFIG_CHEKCPOINT
> +static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
> +				      struct vm_area_struct *vma)
> +{
> +	char *name;
> +
> +	/*
> +	 * Currently, we only handle VDSO/vsyscall special handling.
> +	 * Even that, is very basic - we just skip the contents and
> +	 * hope for the best in terms of compatilibity upon restart.
> +	 */
> +
> +	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED)
> +		return -ENOSYS;
> +
> +	name = arch_vma_name(vma);
> +	if (!name || strcmp(vma_name, "[vdso]"))
> +		return -ENOSYS;
> +
> +	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO);
> +}
> +#else
> +#define special_mapping_checkpoint NULL
> +#endif /* CONFIG_CHECKPOINT */
> +
>  static struct vm_operations_struct special_mapping_vmops = {
>  	.close = special_mapping_close,
>  	.fault = special_mapping_fault,

This doesn't compile when CONFIG_CHECKPOINT is not defined. The .checkpoint op
initialization needs to be surrounded with:

#ifdef CONFIG_CHECKPOINT

> +	.checkpoint = special_mapping_checkpoint,

#endif /* CONFIG_CHECKPOINT */

Alternatively, anything that accesses it needs to use suitably-defined
empty, static inline functions.

Cheers,
	-Matt Helsley
