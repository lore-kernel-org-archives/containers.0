From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] c/r: define s390-specific checkpoint-restart code (v5)
Date: Tue, 24 Feb 2009 13:37:37 -0600
Message-ID: <20090224193737.GB24007@us.ibm.com>
References: <1235500639-9597-1-git-send-email-danms@us.ibm.com>
	<1235500639-9597-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1235500639-9597-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):

Thanks, Dan, this looks very nice with the CR_COPY, plus you
fixed the bug I couldn't find :)  A few comments:

> +struct cr_hdr_cpu {
> +	__u64 args[1];

Dave wanted this to not be an array, right?

> +	__u64 gprs[NUM_GPRS];
> +	__u64 orig_gpr2;
> +	__u16 svcnr;
> +	__u16 ilc;
> +	__u32 acrs[NUM_ACRS];
> +	__u64 ieee_instruction_pointer;
> +
> +	/* psw_t */
> +	__u64 psw_t_mask;
> +	__u64 psw_t_addr;
> +
> +	/* s390_fp_regs_t */
> +	__u32 fpc;
> +	union {
> +		float f;
> +		double d;
> +		__u64 ui;

Since this is a union, and you don't deal with its
members but just memcpy it, why not just change it
to

	__u64 fprs[NUM_FPRS];

and not have a union at all?

> +		struct {
> +			__u32 fp_hi;
> +			__u32 fp_lo;
> +		} fp;
> +	} fprs[NUM_FPRS];
> +
> +	/* per_struct */
> +	__u64 per_control_regs[3];

I assume Dave still wants you to add a

#define PER_NUM_REGS 3

into the arch/s390/include/asm/processor.h or something.

> +void cr_s390_mm(int op, struct cr_hdr_mm_context *hh, struct mm_struct *mm)
> +{
> +#if 0

The comment about why this is ifdefed out for now should stay
here.

> +	CR_COPY(op, hh->vdso_base, mm->context.vdso_base);
> +#endif
> +	CR_COPY(op, hh->noexec, mm->context.noexec);
> +	CR_COPY(op, hh->has_pgste, mm->context.has_pgste);
> +	CR_COPY(op, hh->alloc_pgste, mm->context.alloc_pgste);
> +	CR_COPY(op, hh->asce_bits, mm->context.asce_bits);
> +	CR_COPY(op, hh->asce_limit, mm->context.asce_limit);
> +}
> +
> +int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	return 0;
> +}
> +
> +/* dump the cpu state and registers of a given task */
> +int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_cpu *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int ret;
> +
> +	h.type = CR_HDR_CPU;
> +	h.len = sizeof(*hh);
> +	h.parent = task_pid_vnr(t);

BTW - I know Dave mentioened using a generic helper for this
often-used stanza above, but I continue to be against that
bc the helper ends up having to take a bunch of eye-numbing
arguments and I think the code ends up hard to read.  But
maybe you can think of a way to make that clearer...

> +
> +	cr_s390_regs(CR_CPT, hh, t);
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
> +
> +int cr_write_head_arch(struct cr_ctx *ctx)
> +{
> +	return 0;
> +}
> +
> +/* Nothing to do for mm context state */

The above comment is clearly wrong :)

> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int ret;
> +
> +	h.type = CR_HDR_MM_CONTEXT;
> +	h.len = sizeof(*hh);
> +	h.parent = parent;
> +
> +	cr_s390_mm(CR_CPT, hh, mm);
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}
...
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
> +	restore_access_regs(hh->acrs);

Just a comment explaining why?

> +out:
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	return ret;
> +}

thanks
-serge
