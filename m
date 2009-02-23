From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: define s390-specific checkpoint-restart code (v4)
Date: Mon, 23 Feb 2009 15:04:48 -0800
Message-ID: <87fxi492lr.fsf@caffeine.danplanet.com>
References: <1235425143-9949-1-git-send-email-danms@us.ibm.com>
	<1235428269.26788.195.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1235428269.26788.195.camel@nimitz> (Dave Hansen's message of
	"Mon, 23 Feb 2009 14:31:09 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

> +#define CR_390_PACK_TRACE_FLAGS(hdr, thread)	\
>> +  do {						\
>> +    hdr->em_instr = 0;				\
>> +    if (thread->per_info.single_step)		\
>> +      hdr->em_instr |= 1;			\
>> +    if (thread->per_info.instruction_fetch)	\
>> +      hdr->em_instr |= 2;			\
>> +} while (0)
>> +
>> +#define CR_390_UNPACK_TRACE_FLAGS(hdr, thread)	\
>> +  do {						\
>> +    if (hdr->em_instr & 1)			\
>> +      thread->per_info.single_step = 1;		\
>> +    if (hdr->em_instr & 2)			\
>> +      thread->per_info.instruction_fetch = 1;	\
>> +  } while (0)

DH> Why are these macros?

Well, almost the exact code above was spread between the checkpoint
and restart paths.  I think that this makes it a little clearer what 1
and 2 are since you can see them together.

DH> Why do we need to pack them, anyway?

I assume Serge was trying not to waste a word per flag, and expecting
more flags to be needed to justify the savings.

>> +/*
>> + * Notes
>> + * NUM_GPRS defined in <asm/ptrace.h> to be 16
>> + * NUM_FPRS defined in <asm/ptrace.h> to be 16
>> + * NUM_APRS defined in <asm/ptrace.h> to be 16
>> + */
>> +struct cr_hdr_cpu {
>> +	__u64 args[1];
>> +	__u64 gprs[NUM_GPRS];
>> +	__u64 orig_gpr2;
>> +	__u16 svcnr;
>> +	__u16 ilc;
>> +	__u32 acrs[NUM_ACRS];
>> +	__u64 ieee_instruction_pointer;
>> +
>> +	/* psw_t */
>> +	__u64 psw_t_mask;
>> +	__u64 psw_t_addr;
>> +
>> +	/* s390_fp_regs_t */
>> +	__u32 fpc;
>> +	struct {
>> +		float f;
>> +		double d;
>> +		__u64 ui;
>> +		__u32 fp_hi;
>> +		__u32 fp_lo;
>> +	} fprs[NUM_FPRS];

DH> I don't see a lot of floating point code go by, so I'm a bit
DH> stupid on this.  But, this doesn't make a lot of sense to me.  Are
DH> there really parallel sets of float and double registers?  Or, do
DH> we want some kind of union here?

Yeah, this looks like an improper copy of the freg_t union in
s390/include/asm/ptrace.h to me.  Serge, was there a specific reason
for doing this?  If not I'll make it mirror the actual definition.

>> diff --git a/arch/s390/kernel/compat_wrapper.S b/arch/s390/kernel/compat_wrapper.S
>> index fc2c971..9546a81 100644
>> --- a/arch/s390/kernel/compat_wrapper.S
>> +++ b/arch/s390/kernel/compat_wrapper.S
>> @@ -1767,3 +1767,15 @@ sys_dup3_wrapper:
>> sys_epoll_create1_wrapper:
>> lgfr	%r2,%r2			# int
>> jg	sys_epoll_create1	# branch to system call
>> +
>> +	.globl sys_checkpoint_wrapper
>> +sys_checkpoint_wrapper:
>> +	lgfr	%r2,%r2			# pid_t
>> +	lgfr	%r3,%r3			# int
>> +	llgfr	%r4,%r4			# unsigned long
>> +
>> +	.globl sys_restart_wrapper
>> +sys_restart_wrapper:
>> +	lgfr	%r2,%r2			# int
>> +	lgfr	%r3,%r3			# int
>> +	llgfr	%r4,%r4			# unsigned long

DH> So, all s390 syscalls need these wrappers?  They don't do anything
DH> in particular to help c/r, right?

Looking at the existing file, I'd say everything is wrapped that way.
You'd have to ask someone who knows about s390 for the reason why, I
guess :)

DH> One minor issue with all of these memcpy()s is that they're not
DH> stupid-proof.  To figure out whether the 'sizeof(unsigned int)' is
DH> correct, I need to go back and look to ensure that hh->acrs is, in
DH> fact, an 'unsigned int'.  But if you do:

DH> 	memcpy(hh->acrs, &thread->acrs[0], sizeof(hh->acrs));

This doesn't copy all of the access registers though, just the first
one.  Perhaps you were thrown off by the use of &thread->acrs[0]?  I'd
prefer to just use thread->acrs there for clarity, so I'll make that
change as well.

>> +	hh->psw_t_mask = regs->psw.mask;
>> +	hh->psw_t_addr = regs->psw.addr;
>> +
>> +	hh->args[0] = regs->args[0];

DH> Why is this an array?

Because it's an array of 1 in regs->args.  I'll add a comment :)

>> +	hh->svcnr = regs->svcnr;
>> +	hh->ilc = regs->ilc;
>> +	memcpy(hh->gprs, regs->gprs, NUM_GPRS*sizeof(unsigned long));
>> +	hh->orig_gpr2 = regs->orig_gpr2;
>> +
>> +	hh->ieee_instruction_pointer = thread->ieee_instruction_pointer;
>> +
>> +	/* per_info */
>> +	memcpy(&hh->per_control_regs, &thread->per_info.control_regs.words,
>> +		3 * sizeof(unsigned long));

DH> This '3' is a magic number and is used in a few places.  Does it
DH> make sense to define it as a variable.

You know, I said the same thing when I reviewed this set initially.
However the actual s390 code where its defined uses the magic 3, so if
we define a constant we could still be out of sync with the actual
definition.

>> +	cr_save_cpu_regs(hh, t);
>> +
>> +	ret = cr_write_obj(ctx, &h, hh);
>> +	cr_hbuf_put(ctx, sizeof(*hh));
>> +	WARN_ON_ONCE(ret < 0);
>> +
>> +	return ret;
>> +}

DH> The WARN_ON() probably shouldn't be there when this is submitted.

Okay.

>> +	/* ilc is syscall restart addr.  it looks like we must
>> +	  restore it since we restore psw.addr */

DH> Don't forget CodingStyle on these, please.

Okay.

DH> I'm struggling to figure out how we're going to keep up with
DH> keeping checkpoint and restart synchronized.  This is all pretty
DH> mindless copying in both directions.  Is it possible and
DH> worthwhile for us to just define it once, but use it for both
DH> checkpoint and restart with some macro trickery?

DH> #define CKPT 1
DH> #define RST  2

DH> #define CR_COPY(op, a, b)
DH> 	do {
DH> 		WARN_ON(sizeof(a) != sizeof(b));
DH> 		if (op == CKPT)
DH> 			memcpy(&a, &b, sizeof(b));
DH> 		else
DH> 			memcpy(&b, &a, sizeof(b));
DH> 	} while (0);

DH> void s390_cr_regs(int op, struct task_struct *thread, *hh)
DH> {
DH> 	CR_COPY(op, thread->per_info.lowcore.words.perc_atmid, hh->perc_atmid);
DH> 	CR_COPY(op, thread->per_info.lowcore.words.address, hh->address);
DH> 	CR_COPY(op, thread->per_info.lowcore.words.access_id, hh->access_id);
DH> 	...
DH> }

DH> int cr_read_cpu(struct cr_ctx *ctx)
DH> {
DH> 	s390_cr_regs(RST, thread, hh);
DH> }

DH> int cr_save_cpu(struct cr_ctx *ctx)
DH> {
DH> 	s390_cr_regs(CKPT, thread, hh);
DH> }

DH> That works for both regular variables and for arrays.  Is the
DH> decreased line count worth the weirdo non-standard abstraction?

It looks cleaner to me, so I'm happy to change it if people think that
would be better.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
