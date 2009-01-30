From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Thu, 29 Jan 2009 19:11:05 -0500
Message-ID: <49824599.5030503__46008.4181897857$1233274420$gmane$org@cs.columbia.edu>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<49814FA2.9060108@cs.columbia.edu>
	<20090129214035.GB6913@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090129214035.GB6913@localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: Nathan Lynch <ntl@pobox.com>
Cc: containers@lists.osdl.org, linuxppc-dev@ozlabs.org
List-Id: containers.vger.kernel.org


Nathan Lynch wrote:
> Hey Oren, thanks for taking a look.
> 
> Oren Laadan wrote:
>> Nathan Lynch wrote:
>>> What doesn't work:
>>> * restarting a 32-bit task from a 64-bit task and vice versa
>> Is there a test to bail if we attempt to checkpoint such tasks ?
> 
> No, but I'll add one if it looks too hard to fix for the next round.
> 
> 
>>> +struct cr_hdr_cpu {
>>> +	struct pt_regs pt_regs;
>> It has been suggested (as done in x86/32 code) not to use 'struct pt_regs'
>> because it "can (and has) changed on x86" and because "it only container
>> the registers that the kernel trashes, not all usermode registers".
>>
>> https://lists.linux-foundation.org/pipermail/containers/2008-August/012355.html
> 
> Yeah, I considered that discussion, but the situation is different for
> powerpc (someone on linuxppc-dev smack me if I'm wrong here :)
> pt_regs is part of the ABI, and it encompasses all user mode registers
> except for floating point, which are handled separately.
> 
> 
>>> +	/* relevant fields from thread_struct */
>>> +	double fpr[32][TS_FPRWIDTH];
>> Can TS_FPRWIDTH change between sub-archs or kernel versions ?  If so, it
>> needs to be stated explicitly.
>>
>>> +	unsigned int fpscr;
>>> +	int fpexc_mode;
>>> +	/* unsigned int align_ctl; this is never updated? */
>>> +	unsigned long dabr;
>> Are these fields always guarantee to compile to the same number of bytes
>> regardless of 32/64 bit choice of compiler (or sub-arch?) ?
>>
>> In the x86(32/64) architecture we use types with explicit size such as
>> __u32 and the like to ensure that it always compiled to the same
>> size.
> 
> Yeah, I'll have to fix these up.
> 
> 
> 
>>> +static void cr_hdr_init(struct cr_hdr *hdr, __s16 type, __s16 len, __u32 parent)
>>> +{
>>> +	hdr->type = type;
>>> +	hdr->len = len;
>>> +	hdr->parent = parent;
>>> +}
>>> +
>> This function is rather generic and useful to non-arch-dependent and other
>> architectures code. Perhaps put in a separate patch ?
> 
> Alright.  By the way, why are cr_hdr->type and cr_hdr->len signed
> types?
> 

No particular reason. I can change that in v14.

> 
>>> +int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)
>>> +{
>>> +	struct cr_hdr_cpu *cpu_hdr;
>>> +	struct pt_regs *pt_regs;
>>> +	struct cr_hdr cr_hdr;
>>> +	u32 parent;
>>> +	int ret;
>>> +
>>> +	cpu_hdr = cr_hbuf_get(ctx, sizeof(*cpu_hdr));
>>> +	if (!cpu_hdr)
>>> +		return -ENOMEM;
>>> +
>>> +	parent = task_pid_vnr(t);
>>> +
>>> +	cr_hdr_init(&cr_hdr, CR_HDR_CPU, sizeof(*cpu_hdr), parent);
>>> +
>>> +	/* pt_regs: GPRs, MSR, etc */
>>> +	pt_regs = task_pt_regs(t);
>>> +	cpu_hdr->pt_regs = *pt_regs;
>>> +
>>> +	/* FP state */
>>> +	memcpy(cpu_hdr->fpr, t->thread.fpr, sizeof(cpu_hdr->fpr));
>> As note above, is sizeof(cpu_hdr->fpr) the same on all chips ?
> 
> It can differ depending on kernel configuration.

So the actual size needs to be explicitly indicated (and compared with).

> 
> 
>>> +/* restart APIs */
>>> +
>> The restart APIs belong in a separate file: arch/powerpc/mm/restart.c
> 
> Explain why, please?  This isn't a lot of code, and it seems likely
> that checkpoint and restart paths will share data structures and tend
> to be modified together over time.

This one has little code, but usually that isn't the case, and many of
the data structures shared are anyway exported. Since the split makes
sense in other cases, it makes sense to follow convention.

Personally I don't have a strong opinion on this. However one of the
initial feedbacks for the existing patchset requested that I split the
functionality between files (and to separate commits).

In other words, if nobody else cries, I won't spoil it ;)

> 
> 
>>> +		pr_debug("%s: unexpected thread_hdr contents: 0x%lx\n",
>>> +			 __func__, (unsigned long)thread_hdr->unimplemented);
>> Given the macro for 'pr_fmt' in include/linux/checkpoint.h, the use of
>> __func__ is redunant.
> 
> It seems to me that defining your own pr_fmt in a "public" header like
> that is inappropriate, or at least unconventional.  Any file that
> happens to include linux/checkpoint.h will have any prior definitions
> of pr_fmt overridden, no?
> 

Hmmm.. didn't think of it this way. Using the pr_debug() there was yet
another feedback from LKML, and it seemed reasonable to me. Can you
think of a case where linux/checkpoint.h will happen to be included
in checkpoint-related code ?

> 
>>> +	regs = task_pt_regs(current);
>>> +	*regs = cpu_hdr->pt_regs;
>>> +
>>> +	regs->msr = sanitize_msr(regs->msr);
>>> +
>>> +	/* FP state */
>>> +	memcpy(current->thread.fpr, cpu_hdr->fpr, sizeof(current->thread.fpr));
>>> +	current->thread.fpscr.val = cpu_hdr->fpscr;
>>> +	current->thread.fpexc_mode = cpu_hdr->fpexc_mode;
>>> +
>>> +	/* debug registers */
>>> +	current->thread.dabr = cpu_hdr->dabr;
>> I'm unfamiliar with powerpc; is it necessary to sanitize any of the registers
>> here ?  For instance, can the user cause harm with specially crafted values
>> of some registers ?
> 
> I had this in mind with the treatment of MSR, but I'll check on the
> others, thanks.
> 
> 
>>> +int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int rparent)
>>> +{
>>> +	struct cr_hdr_mm_context *mm_hdr;
>>> +	int ret;
>>> +
>>> +	mm_hdr = cr_hbuf_get(ctx, sizeof(*mm_hdr));
>>> +	if (!mm_hdr)
>>> +		return -ENOMEM;
>>> +
>>> +	ret = cr_read_obj_type(ctx, mm_hdr, sizeof(*mm_hdr),
>>> +				  CR_HDR_MM_CONTEXT);
>>> +	if (ret != rparent)
>>> +		goto out;
>> Seems like 'ret' isn't set to an error value if the 'goto' executes.
> 
> It returns whatever error value cr_read_obj_type() returns.  Hrm.  I
> guess if the image is garbage, cr_read_obj_type can potentially return
> a non-error value that still isn't the desired value, is that right?
> 

True.

Thanks,

Oren.
