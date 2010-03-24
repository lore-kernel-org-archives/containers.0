From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 3/3] c/r: ARM implementation of
	checkpoint/restart
Date: Wed, 24 Mar 2010 21:48:45 +0100
Message-ID: <7d08b87d1003241348g347f092k1142318490e0bdcc__3319.34191422096$1269463780$gmane$org@mail.gmail.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-4-git-send-email-christofferdall@christofferdall.dk>
	<20100323211843.GC19572@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100323211843.GC19572-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 23, 2010 at 10:18 PM, Russell King - ARM Linux
<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org> wrote:
> On Sun, Mar 21, 2010 at 09:06:05PM -0400, Christoffer Dall wrote:
>> The ISA version (given by __LINUX_ARM_ARCH__) is checkpointed and verifi=
ed
>> against the machine architecture on restart.
>
> I think you misunderstand what __LINUX_ARM_ARCH__ signifies. =A0It is the
> build architecture for the kernel, and it indicates the lowest
> architecture version that the kernel will run on.

Yes, clearly I didn't understand this fully. So is it in fact possible
to compile the kernel with __LINUX_ARM_ARCH=3D6 and have
CONFIG_CPU_32v7? Or is it a matter of running a v6 kernel with
CONFIG_CPU_32v6 on a newer architecture?

What I would like to accomplish is the best way to make sure that the
restarted process will in fact be able to run. What is the best way to
ensure this with regards to the architecture version?

>
> That doesn't indicate what ISA version the system is running on, or even
> if the ABI is compatible (we have two ABIs - OABI and EABI).

That's why I checkpointed CONFIG_OABI_COMPAT, but I realize that it's
not sufficient.

How about checkpointing CONFIG_AEABI and CONFIG_OABI_COMPAT and making
sure that we either restore to the same setting of the two or restore
to CONFIG_OABI_COMPAT=3Dy?

>
> There's also the matter of FP implementation - whether it is VFP or FPA,
> and whether iwMMXt is available or not. =A0(iwMMXt precludes the use of
> FPA.)

I had a feeling this would be an issue, but I never dove into the
workings of FP on ARM. Can you give me some concrete pointers as what
to checkpoint and restart / check on restart for a process using FP to
be able to be restarted?

>
>> Regarding ThumbEE, the thumbee_state field on the thread_info is stored
>> in checkpoints when CONFIG_ARM_THUMBEE and 0 is stored otherwise. If
>> a value different than 0 is checkpointed and CONFIG_ARM_THUMBEE is not
>> set on the restore system, the restore is aborted. Feedback on this
>> implementation is very welcome.
>
> I don't recognise this configuration symbol; it doesn't exist in mainline.
>

I encountered it when looking at struct thread_info in
arch/arm/include/asm/thread_info.h, and have not seen et before. After
looking into it a little more, it's included it 2.6.33 and defined in
arch/arm/mm/Kconfig.

>> We checkpoint whether the system is running with CONFIG_MMU or not and
>> require the same configuration for the system on which we restore the
>> process. It might be possible to allow something more fine-grained,
>> if it's worth the energy. Input on this item is also very welcome,
>> specifically from someone who knows the exact meaning of the end_brk
>> field.
>
> Processes which run on MMU and non-MMU CPUs are unlikely to be
> interchangable - the run time environments are quite different. =A0I
> think this is a sane check.
>
thanks.

>> +/* dump the thread_struct of a given task */
>> +int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
>> +{
>> + =A0 =A0 int ret;
>> + =A0 =A0 struct ckpt_hdr_thread *h;
>> + =A0 =A0 struct thread_info *ti =3D task_thread_info(t);
>> +
>> + =A0 =A0 h =3D ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_THREAD);
>> + =A0 =A0 if (!h)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Store the syscall information about the checkpointed proc=
ess
>> + =A0 =A0 =A0* as we need to know if the process was doing a syscall (an=
d which)
>> + =A0 =A0 =A0* during restart.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 h->syscall =3D ti->syscall;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Store remaining thread-specific info.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 h->tp_value =3D ti->tp_value;
>
> How do you safely obtain consistent information from a thread? =A0Do you
> temporarily stop it?
>
