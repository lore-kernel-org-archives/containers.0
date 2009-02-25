From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] c/r: define s390-specific checkpoint-restart code (v6)
Date: Wed, 25 Feb 2009 16:28:17 -0600
Message-ID: <20090225162817.2003383c@thinkcentre.lan>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
	<1235585529-806-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1235585529-806-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Wed, 25 Feb 2009 13:12:09 -0500
Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> +void cr_s390_regs(int op, struct cr_hdr_cpu *hh, struct task_struct *t)
> +{
> +	struct pt_regs *regs = task_pt_regs(t);
> +	struct thread_struct *thr = &t->thread;
> +
> +	CR_COPY(op, hh->fpc, thr->fp_regs.fpc);
> +	CR_COPY(op, hh->fprs, thr->fp_regs.fprs);
> +	CR_COPY(op, hh->acrs, thr->acrs);
> +	CR_COPY(op, hh->psw_t_mask, regs->psw.mask);
> +	CR_COPY(op, hh->psw_t_addr, regs->psw.addr);
> +	CR_COPY(op, hh->args, regs->args);
> +	CR_COPY(op, hh->svcnr, regs->svcnr);
> +	CR_COPY(op, hh->ilc, regs->ilc);
> +	CR_COPY(op, hh->gprs, regs->gprs);
> +	CR_COPY(op, hh->orig_gpr2, regs->orig_gpr2);
> +	CR_COPY(op, hh->per_control_regs, thr->per_info.control_regs.words);
> +	CR_COPY(op, hh->starting_addr, thr->per_info.starting_addr);
> +	CR_COPY(op, hh->ending_addr, thr->per_info.ending_addr);
> +	CR_COPY(op, hh->perc_atmid, thr->per_info.lowcore.words.perc_atmid);
> +	CR_COPY(op, hh->address, thr->per_info.lowcore.words.address);
> +	CR_COPY(op, hh->access_id, thr->per_info.lowcore.words.access_id);
> +	CR_COPY(op, hh->ieee_instruction_pointer,
> +		thr->ieee_instruction_pointer);
> +
> +	CR_COPY_BIT(op, hh->single_step, thr->per_info.single_step);
> +	CR_COPY_BIT(op, hh->instruction_fetch,
> +		    thr->per_info.instruction_fetch);
> +}

No comments here except that I dislike the macros (see response to
patch #2); I'm quoting this because I have a question about one of its
call sites below.


> +
> +void cr_s390_mm(int op, struct cr_hdr_mm_context *hh, struct mm_struct *mm)
> +{
> +#if 0
> +	/* Oren's v13 is on an older kernel which has no vdso_base
> +	 * on newer kernel, we'll have to enable this
> +	 */
> +	CR_COPY(op, hh->vdso_base, mm->context.vdso_base);
> +#endif

During restart, does this replace the current task's VDSO contents, and
if so, is that wise?  VDSO areas contain things like timestamps for
gettimeofday()...


> +/* Write an empty header since it is assumed to be there */
> +int cr_write_head_arch(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_head_arch *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int ret;
> +
> +	h.type = CR_HDR_HEAD_ARCH;
> +	h.len = sizeof(*hh);
> +	h.parent = 0;
> +
> +	ret = cr_write_obj(ctx, &h, &hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}

In the powerpc implementation I was able to get away with returning
zero, without writing dummy headers, for cases like this.


> diff --git a/arch/s390/mm/restart.c b/arch/s390/mm/restart.c
> new file mode 100644
> index 0000000..18229f1
> --- /dev/null
> +++ b/arch/s390/mm/restart.c
> @@ -0,0 +1,85 @@
> +/*
> + *  Checkpoint/restart - architecture specific support for s390
> + *
> + *  Copyright IBM Corp. 2009
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +#include <linux/kernel.h>
> +#include <asm/system.h>
> +#include <asm/pgtable.h>
> +
> +extern void cr_s390_regs(int op, struct cr_hdr_cpu *hh, struct task_struct *t);
> +extern void cr_s390_mm(int op, struct cr_hdr_mm_context *hh,
> +		       struct mm_struct *mm);

These belong in a header, please...


> +int cr_read_cpu(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct pt_regs *regs = task_pt_regs(current);
> +	int parent, ret;
> +
> +	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_CPU);
> +	if  (parent < 0) {
> +		ret = parent;
> +		goto out;
> +	}
> +	ret = 0;
> +
> +	regs->psw.addr &= ~PSW_ADDR_INSN;
> +	cr_s390_regs(CR_RST, hh, current);

The PSW_ADDR_INSN bit in regs->psw.addr is cleared, and then
regs->psw.addr is overwritten by cr_s390_regs?
