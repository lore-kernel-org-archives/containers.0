From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Thu, 25 Mar 2010 11:29:45 +0100
Message-ID: <7d08b87d1003250329t589ba41er2f1127190be078cf__8293.84304020113$1269513135$gmane$org@mail.gmail.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-2-git-send-email-christofferdall@christofferdall.dk>
	<20100323205342.GA19572@n2100.arm.linux.org.uk>
	<20100324020342.GB5704@count0.beaverton.ibm.com>
	<Pine.LNX.4.64.1003240055050.5867@takamine.ncl.cs.columbia.edu>
	<20100324140252.GC5704@count0.beaverton.ibm.com>
	<4BAA3586.1020604@cs.columbia.edu>
	<7d08b87d1003241236n2b45e6f4ife36da841351df9d@mail.gmail.com>
	<20100325011132.GE5704@count0.beaverton.ibm.com>
	<20100325011753.GF5704@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100325011753.GF5704-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 25, 2010 at 2:17 AM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Mar 24, 2010 at 06:11:32PM -0700, Matt Helsley wrote:
>> On Wed, Mar 24, 2010 at 08:36:39PM +0100, Christoffer Dall wrote:
> <snip>
>> > Re-using the assembly code or factoring it out so that it can be used
>> > from multiple places doesn't seem very pleasing to me, as the assembly
>> > code is in the critical path and written specifically for the context
>> > of a process entering the kernel. Please correct me if I'm wrong.
>> >
>> > I imagine simply a function in C, more or less re-implementing the
>> > logic that's already in entry-common.S, might do the trick. I wouldn't
>> > worry much about the performance in this case as it will not be used
>> > often. The following _untested_ snippet illustrates my idea:
>> >
>> > ---
>> > =A0arch/arm/include/asm/syscall.h | =A0 93 +++++++++++++++++++++++++++=
++++++++++++-
>> > =A01 files changed, 92 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/sys=
call.h
>> > index 3b3248f..a7f2615 100644
>> > --- a/arch/arm/include/asm/syscall.h
>> > +++ b/arch/arm/include/asm/syscall.h
>> > @@ -10,10 +10,101 @@
>> > =A0#ifndef _ASM_ARM_SYSCALLS_H
>> > =A0#define _ASM_ARM_SYSCALLS_H
>> >
>> > +static inline int get_swi_instruction(struct task_struct *task,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stru=
ct pt_regs *regs,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsi=
gned long *instr)
>> > +{
>> > + =A0 struct page *page =3D NULL;
>> > + =A0 unsigned long instr_addr;
>> > + =A0 unsigned long *ptr;
>> > + =A0 int ret;
>> > +
>> > + =A0 instr_addr =3D regs->ARM_pc - 4;
>> > +
>> > + =A0 down_read(&task->mm->mmap_sem);
>> > + =A0 ret =3D get_user_pages(task, task->mm, instr_addr,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01, 0, 0, &page, NULL);
>> > + =A0 up_read(&task->mm->mmap_sem);
>> > +
>> > + =A0 if (ret < 0)
>> > + =A0 =A0 =A0 =A0 =A0 return ret;
>> > +
>> > + =A0 ptr =3D (unsigned long *)kmap_atomic(page, KM_USER1);
>> > + =A0 memcpy(instr,
>> > + =A0 =A0 =A0 =A0 =A0ptr + (instr_addr >> PAGE_SHIFT),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ^shouldn't this be:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 instr_addr & PAGE_MASK
>
> Oops, made my own mistake. I think the address of the kmap'd instruction
> would be:
>
> =A0 =A0 =A0 =A0ptr + (instr_addr & ~PAGE_MASK)
>

Yes. Thanks for pointing it out.
