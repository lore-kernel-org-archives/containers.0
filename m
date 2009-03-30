From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] s390 c/r: fix up v14
Date: Mon, 30 Mar 2009 08:44:11 -0400
Message-ID: <49D0BE9B.9060604@cs.columbia.edu>
References: <20090324161611.GA19751@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090324161611.GA19751-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Make a few changes to the s390 c/r code to reflect v14 changes.
> CONFIG_CHECKPOINT_RESTART is now CONFIG_CHECKPOINT, and 'parent'
> is gone.

Added, thanks.

> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/mm/Makefile     |    2 +-
>  arch/s390/mm/checkpoint.c |    5 +----
>  2 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/s390/mm/Makefile b/arch/s390/mm/Makefile
> index 040fbb7..b16161e 100644
> --- a/arch/s390/mm/Makefile
> +++ b/arch/s390/mm/Makefile
> @@ -6,4 +6,4 @@ obj-y	 := init.o fault.o extmem.o mmap.o vmem.o pgtable.o
>  obj-$(CONFIG_CMM) += cmm.o
>  obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
>  obj-$(CONFIG_PAGE_STATES) += page-states.o
> -obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o restart.o
> +obj-$(CONFIG_CHECKPOINT) += checkpoint.o restart.o
> diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
> index 216bdd8..c4e3719 100644
> --- a/arch/s390/mm/checkpoint.c
> +++ b/arch/s390/mm/checkpoint.c
> @@ -79,7 +79,6 @@ int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
>  
>  	h.type = CR_HDR_CPU;
>  	h.len = sizeof(*hh);
> -	h.parent = task_pid_vnr(t);
>  
>  	cr_s390_regs(CR_CPT, hh, t);
>  
> @@ -98,7 +97,6 @@ int cr_write_head_arch(struct cr_ctx *ctx)
>  
>  	h.type = CR_HDR_HEAD_ARCH;
>  	h.len = sizeof(*hh);
> -	h.parent = 0;
>  
>  	ret = cr_write_obj(ctx, &h, &hh);
>  	cr_hbuf_put(ctx, sizeof(*hh));
> @@ -106,7 +104,7 @@ int cr_write_head_arch(struct cr_ctx *ctx)
>  	return ret;
>  }
>  
> -int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
>  {
>  	struct cr_hdr h;
>  	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> @@ -114,7 +112,6 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
>  
>  	h.type = CR_HDR_MM_CONTEXT;
>  	h.len = sizeof(*hh);
> -	h.parent = parent;
>  
>  	cr_s390_mm(CR_CPT, hh, mm);
>  
