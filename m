From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of checkpoint/restart
Date: Tue, 23 Mar 2010 11:09:33 -0500
Message-ID: <20100323160933.GA4465__43108.9668920778$1269360628$gmane$org@us.ibm.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1269219965-23923-4-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Christoffer Dall (christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org):
> Implements architecture specific requirements for checkpoint/restart on
> ARM. The changes touch almost only c/r related code. Most of the work is
> done in arch/arm/checkpoint.c, which implements checkpointing of the CPU
> and necessary fields on the thread_info struct.
> 
> The ISA version (given by __LINUX_ARM_ARCH__) is checkpointed and verified
> against the machine architecture on restart. If they differ, an error is
> raised and restart aborted. It should be possible to restart on newer
> architectures, but further investigation is warranted.
> 
> Regarding ThumbEE, the thumbee_state field on the thread_info is stored
> in checkpoints when CONFIG_ARM_THUMBEE and 0 is stored otherwise. If
> a value different than 0 is checkpointed and CONFIG_ARM_THUMBEE is not
> set on the restore system, the restore is aborted. Feedback on this
> implementation is very welcome.
> 
> We checkpoint whether the system is running with CONFIG_MMU or not and
> require the same configuration for the system on which we restore the
> process. It might be possible to allow something more fine-grained,
> if it's worth the energy. Input on this item is also very welcome,
> specifically from someone who knows the exact meaning of the end_brk
> field.
> 
> Added support for syscall sys_checkpoint and sys_restart for ARM:
> __NR_checkpoint         367
> __NR_restart            368
> 
> 
> Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
> Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
> Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

In terms of the cr api I don't see any problems.  Two nits below,
but in any case

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks, this is really cool, especially how minimal it is :)
-serge

...

> +static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
> +{
> +	int i;
> +	struct pt_regs *regs = task_pt_regs(t);
> +
> +	memcpy(regs, &h->uregs, sizeof(struct pt_regs));
> +
> +	for (i = 0; i < 16; i++)
> +		regs->uregs[i] = h->uregs[i];
> +
> +	/*
> +	 * Restore only user-writable bits on the CPSR
> +	 */
> +	regs->ARM_cpsr = regs->ARM_cpsr |
> +			 (h->ARM_cpsr & (PSR_N_BIT | PSR_Z_BIT |
> +					 PSR_C_BIT | PSR_V_BIT |
> +					 PSR_V_BIT | PSR_Q_BIT |
> +					 PSR_E_BIT | PSR_GE_BITS));
> +	regs->ARM_ORIG_r0 = h->ARM_ORIG_r0;
> +
> +	return 0;
> +}
> +
> +/* read the cpu state and registers for the current task */
> +int restore_cpu(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_cpu *h;
> +	struct task_struct *t = current;
> +	int ret;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	ret = load_cpu_regs(h, t);

will load_cpu_regs() ever be changed to return anything but 0?  If
not both fns can be simplified.

...

> +int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
> +{
> +	struct ckpt_hdr_mm_context *h;
> +	int ret = 0;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +#if !CONFIG_MMU
> +	mm->context.end_brk = h->end_brk;
> +#endif
> +
> +	ckpt_hdr_put(ctx, h);
> +	return ret;

Again ret doesn't seem needed here.

-serge
