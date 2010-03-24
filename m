From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of
	checkpoint/restart
Date: Wed, 24 Mar 2010 20:46:55 +0100
Message-ID: <7d08b87d1003241246i39c9163ch6426d2184de628b0__9010.33927589214$1269460121$gmane$org@mail.gmail.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
	<20100323160933.GA4465@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100323160933.GA4465-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 23, 2010 at 5:09 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Christoffer Dall (christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org):
>> Implements architecture specific requirements for checkpoint/restart on
>> ARM. The changes touch almost only c/r related code. Most of the work is
>> done in arch/arm/checkpoint.c, which implements checkpointing of the CPU
>> and necessary fields on the thread_info struct.
>>
>> The ISA version (given by __LINUX_ARM_ARCH__) is checkpointed and verifi=
ed
>> against the machine architecture on restart. If they differ, an error is
>> raised and restart aborted. It should be possible to restart on newer
>> architectures, but further investigation is warranted.
>>
>> Regarding ThumbEE, the thumbee_state field on the thread_info is stored
>> in checkpoints when CONFIG_ARM_THUMBEE and 0 is stored otherwise. If
>> a value different than 0 is checkpointed and CONFIG_ARM_THUMBEE is not
>> set on the restore system, the restore is aborted. Feedback on this
>> implementation is very welcome.
>>
>> We checkpoint whether the system is running with CONFIG_MMU or not and
>> require the same configuration for the system on which we restore the
>> process. It might be possible to allow something more fine-grained,
>> if it's worth the energy. Input on this item is also very welcome,
>> specifically from someone who knows the exact meaning of the end_brk
>> field.
>>
>> Added support for syscall sys_checkpoint and sys_restart for ARM:
>> __NR_checkpoint =A0 =A0 =A0 =A0 367
>> __NR_restart =A0 =A0 =A0 =A0 =A0 =A0368
>>
>>
>> Cc: rmk-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
>> Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
>> Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>
> In terms of the cr api I don't see any problems. =A0Two nits below,
> but in any case
>
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
> thanks, this is really cool, especially how minimal it is :)
> -serge
thanks
>
> ...
>
>> +static int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
>> +{
>> + =A0 =A0 int i;
>> + =A0 =A0 struct pt_regs *regs =3D task_pt_regs(t);
>> +
>> + =A0 =A0 memcpy(regs, &h->uregs, sizeof(struct pt_regs));
>> +
>> + =A0 =A0 for (i =3D 0; i < 16; i++)
>> + =A0 =A0 =A0 =A0 =A0 =A0 regs->uregs[i] =3D h->uregs[i];
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Restore only user-writable bits on the CPSR
>> + =A0 =A0 =A0*/
>> + =A0 =A0 regs->ARM_cpsr =3D regs->ARM_cpsr |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(h->ARM_cpsr & (PSR_N_BIT |=
 PSR_Z_BIT |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0PSR_C_BIT | PSR_V_BIT |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0PSR_V_BIT | PSR_Q_BIT |
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0PSR_E_BIT | PSR_GE_BITS));
>> + =A0 =A0 regs->ARM_ORIG_r0 =3D h->ARM_ORIG_r0;
>> +
>> + =A0 =A0 return 0;
>> +}
>> +
>> +/* read the cpu state and registers for the current task */
>> +int restore_cpu(struct ckpt_ctx *ctx)
>> +{
>> + =A0 =A0 struct ckpt_hdr_cpu *h;
>> + =A0 =A0 struct task_struct *t =3D current;
>> + =A0 =A0 int ret;
>> +
>> + =A0 =A0 h =3D ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CPU);
>> + =A0 =A0 if (IS_ERR(h))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(h);
>> +
>> + =A0 =A0 ret =3D load_cpu_regs(h, t);
>
> will load_cpu_regs() ever be changed to return anything but 0? =A0If
> not both fns can be simplified.
>

you're right. I will put load_cpu_regs() inline in restore_cpu.
> ...
>
>> +int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
>> +{
>> + =A0 =A0 struct ckpt_hdr_mm_context *h;
>> + =A0 =A0 int ret =3D 0;
>> +
>> + =A0 =A0 h =3D ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
>> + =A0 =A0 if (IS_ERR(h))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(h);
>> +
>> +#if !CONFIG_MMU
>> + =A0 =A0 mm->context.end_brk =3D h->end_brk;
>> +#endif
>> +
>> + =A0 =A0 ckpt_hdr_put(ctx, h);
>> + =A0 =A0 return ret;
>
> Again ret doesn't seem needed here.
indeed it doesn't.

-Christoffer
