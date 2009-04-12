From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Fix arch-specific use of mm->context.vdso in v14-rc3
Date: Sat, 11 Apr 2009 22:54:07 -0400
Message-ID: <49E157CF.3030601@cs.columbia.edu>
References: <1239127585-15930-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239127585-15930-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Added.

Dan Smith wrote:
> On s390 and PPC, the mm_context does not have a void *vdso member, but
> rather an unsigned long vdso_base.  Since we cast the void * to an
> unsigned long anyway, add an arch-specific cr_arch_vdso() function to
> return the address.
> 
> This is tested on s390 and x86, but needs PPC validation.
> 
>     Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/powerpc/mm/checkpoint.c |    6 ++++++
>  arch/s390/mm/checkpoint.c    |    6 ++++++
>  arch/x86/mm/checkpoint.c     |    5 +++++
>  checkpoint/checkpoint_arch.h |    1 +
>  checkpoint/rstr_mem.c        |    2 +-
>  5 files changed, 19 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
> index 731874b..7d56ff7 100644
> --- a/arch/powerpc/mm/checkpoint.c
> +++ b/arch/powerpc/mm/checkpoint.c
> @@ -498,3 +498,9 @@ int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
>  {
>  	return 0;
>  }
> +
> +unsigned long cr_arch_vdso(struct cr_ctx *ctx, struct mm_struct *mm)
> +{
> +	return mm->context.vdso_base;
> +}
> +
> diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
> index 263d8bd..68be905 100644
> --- a/arch/s390/mm/checkpoint.c
> +++ b/arch/s390/mm/checkpoint.c
> @@ -119,3 +119,9 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
>  
>  	return ret;
>  }
> +
> +unsigned long cr_arch_vdso(struct cr_ctx *ctx, struct mm_struct *mm)
> +{
> +	return mm->context.vdso_base;
> +}
> +
> diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
> index 64e6635..0a3fee6 100644
> --- a/arch/x86/mm/checkpoint.c
> +++ b/arch/x86/mm/checkpoint.c
> @@ -271,3 +271,8 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
>  	mutex_unlock(&mm->context.lock);
>  	return ret;
>  }
> +
> +unsigned long cr_arch_vdso(struct cr_ctx *ctx, struct mm_struct *mm)
> +{
> +	return (unsigned long)mm->context.vdso;
> +}
> diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
> index 0afe666..e189811 100644
> --- a/checkpoint/checkpoint_arch.h
> +++ b/checkpoint/checkpoint_arch.h
> @@ -1,6 +1,7 @@
>  #include <linux/checkpoint.h>
>  
>  extern int cr_retval_restart(struct cr_ctx *ctx);
> +extern unsigned long cr_arch_vdso(struct cr_ctx *ctx, struct mm_struct *mm);
>  
>  extern int cr_write_head_arch(struct cr_ctx *ctx);
>  extern int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
> diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
> index 7e73129..ca3a2fd 100644
> --- a/checkpoint/rstr_mem.c
> +++ b/checkpoint/rstr_mem.c
> @@ -416,7 +416,7 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
>  
>  	/* handle special VDSO vma */
>  	if (vma_type == CR_VMA_VDSO) {
> -		if (vm_start != (unsigned long) mm->context.vdso)
> +		if (vm_start != cr_arch_vdso(ctx, mm))
>  			goto out;
>  		/* FIXME: uggh ... need to dig in */
>  		ret = 0;
