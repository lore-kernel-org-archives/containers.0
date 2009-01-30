From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Thu, 29 Jan 2009 21:55:30 -0600
Message-ID: <20090130035530.GA30595__4389.59205425835$1233287886$gmane$org@us.ibm.com>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1233182478-27113-2-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> The only thing of significance here is that the checkpointed task's
> pt_regs and fp state are saved and restored (see cr_write_cpu and
> cr_read_cpu); the rest of the code consists of dummy implementations
> of the APIs the arch needs to provide to the checkpoint/restart core.
> 
> What works:
> * self and external checkpoint of simple (single thread, one open
>   file) 32- and 64-bit processes on a ppc64 kernel
> 
> What doesn't work:
> * restarting a 32-bit task from a 64-bit task and vice versa
> 
> Untested:
> * ppc32 (but it builds)
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/powerpc/include/asm/checkpoint_hdr.h |   40 +++++
>  arch/powerpc/mm/Makefile                  |    1 +
>  arch/powerpc/mm/checkpoint.c              |  261 +++++++++++++++++++++++++++++
>  3 files changed, 302 insertions(+), 0 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/checkpoint_hdr.h
>  create mode 100644 arch/powerpc/mm/checkpoint.c
> 
> diff --git a/arch/powerpc/include/asm/checkpoint_hdr.h b/arch/powerpc/include/asm/checkpoint_hdr.h
> new file mode 100644
> index 0000000..752c53f
> --- /dev/null
> +++ b/arch/powerpc/include/asm/checkpoint_hdr.h
> @@ -0,0 +1,40 @@
> +#ifndef __ASM_PPC_CKPT_HDR_H
> +#define __ASM_PPC_CKPT_HDR_H
> +/*
> + *  Checkpoint/restart - architecture specific headers ppc
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/types.h>
> +#include <asm/ptrace.h>
> +#include <asm/mmu.h>
> +#include <asm/processor.h>
> +
> +struct cr_hdr_head_arch {
> +	__u32 unimplemented;
> +};
> +
> +struct cr_hdr_thread {
> +	__u32 unimplemented;
> +};
> +
> +struct cr_hdr_cpu {
> +	struct pt_regs pt_regs;
> +	/* relevant fields from thread_struct */
> +	double fpr[32][TS_FPRWIDTH];
> +	unsigned int fpscr;
> +	int fpexc_mode;
> +	/* unsigned int align_ctl; this is never updated? */
> +	unsigned long dabr;
> +};
> +
> +struct cr_hdr_mm_context {
> +	__u32 unimplemented;
> +};
> +
> +#endif /* __ASM_PPC_CKPT_HDR__H */
> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
> index e7392b4..8a523a0 100644
> --- a/arch/powerpc/mm/Makefile
> +++ b/arch/powerpc/mm/Makefile
> @@ -24,3 +24,4 @@ obj-$(CONFIG_NEED_MULTIPLE_NODES) += numa.o
>  obj-$(CONFIG_PPC_MM_SLICES)	+= slice.o
>  obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
>  obj-$(CONFIG_PPC_SUBPAGE_PROT)	+= subpage-prot.o
> +obj-$(CONFIG_CHECKPOINT_RESTART) += checkpoint.o
> diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
> new file mode 100644
> index 0000000..8cdff24
> --- /dev/null
> +++ b/arch/powerpc/mm/checkpoint.c
> @@ -0,0 +1,261 @@
> +/*
> + *  Checkpoint/restart - architecture specific support for powerpc.
> + *  Based on x86 implementation.
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *  Copyright 2009 IBM Corp.
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#define DEBUG 1 /* for pr_debug */
> +
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +#include <linux/kernel.h>
> +#include <asm/processor.h>
> +
> +static void cr_hdr_init(struct cr_hdr *hdr, __s16 type, __s16 len, __u32 parent)
> +{
> +	hdr->type = type;
> +	hdr->len = len;
> +	hdr->parent = parent;
> +}
> +
> +/* dump the thread_struct of a given task */
> +int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr_thread *thread_hdr;
> +	struct cr_hdr cr_hdr;
> +	u32 parent;
> +	int ret;
> +
> +	thread_hdr = cr_hbuf_get(ctx, sizeof(*thread_hdr));
> +	if (!thread_hdr)
> +		return -ENOMEM;
> +
> +	parent = task_pid_vnr(t);
> +
> +	cr_hdr_init(&cr_hdr, CR_HDR_THREAD, sizeof(*thread_hdr), parent);

All you're writing here is the vpid, right?  The arch-independent
code already stores that?

> +
> +	thread_hdr->unimplemented = 0xdeadbeef;
> +
> +	ret = cr_write_obj(ctx, &cr_hdr, thread_hdr);
> +	cr_hbuf_put(ctx, sizeof(*thread_hdr));
> +
> +	return ret;
> +}
> +
> +/* dump the cpu state and registers of a given task */
> +int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr_cpu *cpu_hdr;
> +	struct pt_regs *pt_regs;
> +	struct cr_hdr cr_hdr;
> +	u32 parent;
> +	int ret;
> +
> +	cpu_hdr = cr_hbuf_get(ctx, sizeof(*cpu_hdr));
> +	if (!cpu_hdr)
> +		return -ENOMEM;
> +
> +	parent = task_pid_vnr(t);
> +
> +	cr_hdr_init(&cr_hdr, CR_HDR_CPU, sizeof(*cpu_hdr), parent);
> +
> +	/* pt_regs: GPRs, MSR, etc */
> +	pt_regs = task_pt_regs(t);
> +	cpu_hdr->pt_regs = *pt_regs;
> +
> +	/* FP state */
> +	memcpy(cpu_hdr->fpr, t->thread.fpr, sizeof(cpu_hdr->fpr));
> +	cpu_hdr->fpscr = t->thread.fpscr.val;
> +	cpu_hdr->fpexc_mode = t->thread.fpexc_mode;
> +
> +	/* Handle DABR for now, dbcr[01] later */
> +	cpu_hdr->dabr = t->thread.dabr;
> +
> +	/* ToDo: Altivec/VSX/SPE state */
> +
> +	ret = cr_write_obj(ctx, &cr_hdr, cpu_hdr);
> +	cr_hbuf_put(ctx, sizeof(*cpu_hdr));
> +
> +	return ret;
> +}
> +
> +int cr_write_head_arch(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_head_arch *arch_hdr;
> +	struct cr_hdr cr_hdr;
> +	int ret;
> +
> +	arch_hdr = cr_hbuf_get(ctx, sizeof(*arch_hdr));
> +	if (!arch_hdr)
> +		return -ENOMEM;
> +
> +	cr_hdr_init(&cr_hdr, CR_HDR_HEAD_ARCH, sizeof(*arch_hdr), 0);
> +
> +	arch_hdr->unimplemented = 0xdeadbeef;

No need to write this just for the sake of writing something, imo.

> +	ret = cr_write_obj(ctx, &cr_hdr, arch_hdr);
> +	cr_hbuf_put(ctx, sizeof(*arch_hdr));
> +
> +	return ret;
> +}
> +
> +/* dump the mm->context state */
> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
> +{
> +	struct cr_hdr_mm_context *mm_hdr;
> +	struct cr_hdr cr_hdr;
> +	size_t size;
> +	int ret;
> +
> +	size = sizeof(*mm_hdr);
> +
> +	mm_hdr = cr_hbuf_get(ctx, size);
> +	if (!mm_hdr)
> +		return -ENOMEM;
> +
> +	cr_hdr_init(&cr_hdr, CR_HDR_MM_CONTEXT, size, parent);
> +
> +	mm_hdr->unimplemented = 0xdeadbeef;

Again

> +	ret = cr_write_obj(ctx, &cr_hdr, mm_hdr);
> +	cr_hbuf_put(ctx, size);
> +
> +	return ret;
> +}
> +
> +/* restart APIs */
> +
> +/* read the thread_struct into the current task */
> +int cr_read_thread(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_thread *thread_hdr;
> +	int ret;
> +
> +	thread_hdr = cr_hbuf_get(ctx, sizeof(*thread_hdr));
> +	if (!thread_hdr)
> +		return -ENOMEM;
> +
> +	ret = cr_read_obj_type(ctx, thread_hdr, sizeof(*thread_hdr),
> +				  CR_HDR_THREAD);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = 0;
> +
> +	if (thread_hdr->unimplemented != 0xdeadbeef) {
> +		pr_debug("%s: unexpected thread_hdr contents: 0x%lx\n",
> +			 __func__, (unsigned long)thread_hdr->unimplemented);
> +		ret = -EINVAL;
> +	}

DROP

> +out:
> +	cr_hbuf_put(ctx, sizeof(*thread_hdr));
> +	return ret;
> +}
> +
> +/* Based on the MSR value from a checkpoint image, produce an MSR
> + * value that is appropriate for the restored task.  Right now we only
> + * check for MSR_SF (64-bit) for PPC64.
> + */
> +static unsigned long sanitize_msr(unsigned long msr_ckpt)
> +{
> +#ifdef CONFIG_PPC32
> +	return MSR_USER;
> +#else
> +	if (msr_ckpt & MSR_SF)
> +		return MSR_USER64;
> +	return MSR_USER32;
> +#endif
> +}
> +
> +int cr_read_cpu(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_cpu *cpu_hdr;
> +	struct pt_regs *regs;
> +	int ret;
> +
> +	cpu_hdr = cr_hbuf_get(ctx, sizeof(*cpu_hdr));
> +	if (!cpu_hdr)
> +		return -ENOMEM;
> +
> +	ret = cr_read_obj_type(ctx, cpu_hdr, sizeof(*cpu_hdr),
> +				  CR_HDR_CPU);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = 0;
> +
> +	regs = task_pt_regs(current);
> +	*regs = cpu_hdr->pt_regs;
> +
> +	regs->msr = sanitize_msr(regs->msr);
> +
> +	/* FP state */
> +	memcpy(current->thread.fpr, cpu_hdr->fpr, sizeof(current->thread.fpr));
> +	current->thread.fpscr.val = cpu_hdr->fpscr;
> +	current->thread.fpexc_mode = cpu_hdr->fpexc_mode;
> +
> +	/* debug registers */
> +	current->thread.dabr = cpu_hdr->dabr;
> +out:
> +	cr_hbuf_put(ctx, sizeof(*cpu_hdr));
> +	return ret;
> +}
> +
> +int cr_read_head_arch(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_head_arch *arch_hdr;
> +	int ret;
> +
> +	arch_hdr = cr_hbuf_get(ctx, sizeof(*arch_hdr));
> +	if (!arch_hdr)
> +		return -ENOMEM;
> +
> +	ret = cr_read_obj_type(ctx, arch_hdr, sizeof(*arch_hdr),
> +				  CR_HDR_HEAD_ARCH);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = 0;
> +
> +	if (arch_hdr->unimplemented != 0xdeadbeef) {
> +		pr_debug("%s: unexpected arch_hdr contents: 0x%lx\n",
> +			 __func__, (unsigned long)arch_hdr->unimplemented);
> +		ret = -EINVAL;

DROP

> +	}
> +out:
> +	cr_hbuf_put(ctx, sizeof(*arch_hdr));
> +	return ret;
> +}
> +
> +int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int rparent)
> +{
> +	struct cr_hdr_mm_context *mm_hdr;
> +	int ret;
> +
> +	mm_hdr = cr_hbuf_get(ctx, sizeof(*mm_hdr));
> +	if (!mm_hdr)
> +		return -ENOMEM;
> +
> +	ret = cr_read_obj_type(ctx, mm_hdr, sizeof(*mm_hdr),
> +				  CR_HDR_MM_CONTEXT);
> +	if (ret != rparent)
> +		goto out;
> +
> +	ret = 0;
> +
> +	if (mm_hdr->unimplemented != 0xdeadbeef) {
> +		pr_debug("%s: unexpected mm_hdr contents: 0x%lx\n",
> +			 __func__, (unsigned long)mm_hdr->unimplemented);
> +		ret = -EINVAL;

DROP

> +	}
> +
> +out:
> +	cr_hbuf_put(ctx, sizeof(*mm_hdr));
> +	return ret;
> +}
> -- 
> 1.5.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
