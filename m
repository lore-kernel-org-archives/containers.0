From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: tighten checks on supported vma to checkpoint or
	restart
Date: Tue, 22 Sep 2009 23:11:37 -0500
Message-ID: <20090923041137.GA11296@us.ibm.com>
References: <1253652479-11565-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1253652479-11565-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oren Laadan <orenl-RdfvBDnrOiyVc3sceRu5cw@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> From: Oren Laadan <orenl-RdfvBDnrOiyVc3sceRu5cw@public.gmane.org>
> 
> Move test of vma flags against CKPT_VMA_NOT_SUPPORTED to one place:
> {checkpoint,restore}_vma(). Also tighten sanity tests on restore.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/memory.c |   24 +++++++++---------------
>  1 files changed, 9 insertions(+), 15 deletions(-)
> 
> diff --git a/checkpoint/memory.c b/checkpoint/memory.c
> index 7754074..0da948f 100644
> --- a/checkpoint/memory.c
> +++ b/checkpoint/memory.c
> @@ -554,12 +554,6 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
>  	ckpt_debug("vma %#lx-%#lx flags %#lx type %d\n",
>  		 vma->vm_start, vma->vm_end, vma->vm_flags, type);
> 
> -	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
> -		ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
> -			       -ENOSYS, vma->vm_flags);
> -		return -ENOSYS;
> -	}
> -
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_VMA);
>  	if (!h)
>  		return -ENOMEM;
> @@ -644,12 +638,7 @@ static int anonymous_checkpoint(struct ckpt_ctx *ctx,
>  				struct vm_area_struct *vma)
>  {
>  	/* should be private anonymous ... verify that this is the case */
> -	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
> -		ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
> -			       -ENOSYS, vma->vm_flags);
> -		return -ENOSYS;
> -	}
> -
> +	BUG_ON(vma->vm_flags & VM_MAYSHARE);
>  	BUG_ON(vma->vm_file);
> 
>  	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
> @@ -707,6 +696,11 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
>  			 vma->vm_start, vma->vm_end, vma->vm_flags);
> +		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
> +			ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
> +				       -ENOSYS, vma->vm_flags);
> +			return -ENOSYS;
> +		}
>  		if (!vma->vm_ops)
>  			ret = anonymous_checkpoint(ctx, vma);
>  		else if (vma->vm_ops->checkpoint)
> @@ -1033,8 +1027,6 @@ unsigned long generic_vma_restore(struct mm_struct *mm,
>  		return -EINVAL;
>  	if (h->vma_objref < 0)
>  		return -EINVAL;
> -	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
> -		return -ENOSYS;
> 
>  	vm_start = h->vm_start;
>  	vm_pgoff = h->vm_pgoff;
> @@ -1064,7 +1056,7 @@ int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
>  {
>  	unsigned long addr;
> 
> -	if (h->vm_flags & VM_SHARED)
> +	if (h->vm_flags & (VM_SHARED | VM_MAYSHARE))
>  		return -EINVAL;
> 
>  	addr = generic_vma_restore(mm, file, h);
> @@ -1195,6 +1187,8 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
>  		goto out;
>  	if (h->vma_type >= CKPT_VMA_MAX)
>  		goto out;
> +	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
> +		return -ENOSYS;
> 
>  	ops = &restore_vma_ops[h->vma_type];
> 
> -- 
> 1.6.0.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
