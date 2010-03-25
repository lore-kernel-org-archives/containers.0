From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Thu, 25 Mar 2010 11:34:16 +0100
Message-ID: <7d08b87d1003250334s595ccebev2c307a0192c2d46e__36795.6554321156$1269513301$gmane$org@mail.gmail.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-2-git-send-email-christofferdall@christofferdall.dk>
	<20100323205342.GA19572@n2100.arm.linux.org.uk>
	<20100324020342.GB5704@count0.beaverton.ibm.com>
	<Pine.LNX.4.64.1003240055050.5867@takamine.ncl.cs.columbia.edu>
	<20100324140252.GC5704@count0.beaverton.ibm.com>
	<4BAA3586.1020604@cs.columbia.edu>
	<7d08b87d1003241236n2b45e6f4ife36da841351df9d@mail.gmail.com>
	<20100325011132.GE5704@count0.beaverton.ibm.com>
	<4BAABDF4.8070904@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BAABDF4.8070904-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 25, 2010 at 2:35 AM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
>
>
> Matt Helsley wrote:
>>
>> On Wed, Mar 24, 2010 at 08:36:39PM +0100, Christoffer Dall wrote:
>>>
>>> On Wed, Mar 24, 2010 at 4:53 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>>> wrote:
>>>>
>>>> Matt Helsley wrote:
>>>>>
>>>>> On Wed, Mar 24, 2010 at 12:57:46AM -0400, Oren Laadan wrote:
>>>>>>
>>>>>> On Tue, 23 Mar 2010, Matt Helsley wrote:
>>>>>>
>>>>>>> On Tue, Mar 23, 2010 at 08:53:42PM +0000, Russell King - ARM Linux
>>>>>>> wrote:
>>>>>>>>
>>>>>>>> On Sun, Mar 21, 2010 at 09:06:03PM -0400, Christoffer Dall wrote:
>>>>>>>>>
>>>>>>>>> This small commit introduces a global state of system calls for A=
RM
>>>>>>>>> making it possible for a debugger or checkpointing to gain
>>>>>>>>> information
>>>>>>>>> about another process' state with respect to system calls.
>>>>>>>>
>>>>>>>> I don't particularly like the idea that we always store the syscall
>>>>>>>> number to memory for every system call, whether the stored version
>>>>>>>> is
>>>>>>>> used or not.
>>>>>>>>
>>>>>>>> Since ARM caches are generally not write allocate, this means most=
ly
>>>>>>>> write-only variables can have a higher than expected expense.
>>>>>>>>
>>>>>>>> Is there not some thread flag which can be checked to see if we ne=
ed
>>>>>>>> to
>>>>>>>> store the syscall number?
>>>>>>>
>>>>>>> Perhaps before we freeze the task we can save the syscall number on
>>>>>>> ARM.
>>>>>>> The patches suggest that the signal delivery path -- which the
>>>>>>> freezer
>>>>>>> utilizes -- has the syscall number already.
>>>>
>>>> Actually, the signal path doesn't have the syscall number, it has
>>>> a binary "in syscall" value.
>>>>
>>
>> Argh. I read too much into the name :(.
>>
>>> Well, this could be changed to pass the syscall number through
>>> registers along to try_to_freeze without any mentionable performance
>>> hit.
>>
>> Yes, that's possible. I was thinking we could still use your thread info
>> field but only store to it when we know it will be useful for c/r rather
>> than for each syscall. Personally, I'd rather avoid passing the extra
>> parameter into try_to_freeze(). Your idea below seems better to me.
>>
>>> Re-using the assembly code or factoring it out so that it can be used
>>> from multiple places doesn't seem very pleasing to me, as the assembly
>>> code is in the critical path and written specifically for the context
>>> of a process entering the kernel. Please correct me if I'm wrong.
>>>
>>> I imagine simply a function in C, more or less re-implementing the
>>> logic that's already in entry-common.S, might do the trick. I wouldn't
>>> worry much about the performance in this case as it will not be used
>>> often. The following _untested_ snippet illustrates my idea:
>>>
>>> ---
>>> =A0arch/arm/include/asm/syscall.h | =A0 93
>>> +++++++++++++++++++++++++++++++++++++++-
>>> =A01 files changed, 92 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/arch/arm/include/asm/syscall.h
>>> b/arch/arm/include/asm/syscall.h
>>> index 3b3248f..a7f2615 100644
>>> --- a/arch/arm/include/asm/syscall.h
>>> +++ b/arch/arm/include/asm/syscall.h
>>> @@ -10,10 +10,101 @@
>>> =A0#ifndef _ASM_ARM_SYSCALLS_H
>>> =A0#define _ASM_ARM_SYSCALLS_H
>>>
>>> +static inline int get_swi_instruction(struct task_struct *task,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct pt_regs *regs,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long *instr)
>>> +{
>>> + =A0 =A0 =A0 struct page *page =3D NULL;
>>> + =A0 =A0 =A0 unsigned long instr_addr;
>>> + =A0 =A0 =A0 unsigned long *ptr;
>>> + =A0 =A0 =A0 int ret;
>>> +
>>> + =A0 =A0 =A0 instr_addr =3D regs->ARM_pc - 4;
>>> +
>>> + =A0 =A0 =A0 down_read(&task->mm->mmap_sem);
>>> + =A0 =A0 =A0 ret =3D get_user_pages(task, task->mm, instr_addr,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01, 0, 0, &page=
, NULL);
>>> + =A0 =A0 =A0 up_read(&task->mm->mmap_sem);
>>> +
>>> + =A0 =A0 =A0 if (ret < 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>>> +
>>> + =A0 =A0 =A0 ptr =3D (unsigned long *)kmap_atomic(page, KM_USER1);
>>> + =A0 =A0 =A0 memcpy(instr,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0ptr + (instr_addr >> PAGE_SHIFT),
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^shouldn't this be:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0instr_addr & PAGE_MASK
>>
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(unsigned long));
>>> + =A0 =A0 =A0 kunmap_atomic(ptr, KM_USER1);
>>> +
>>> + =A0 =A0 =A0 page_cache_release(page);
>>> +
>>> + =A0 =A0 =A0 return 0;
>>> +}
>>
>> (again, not familiar with ARM so my understanding is:
>>
>> I guess swi is "syscall word immediate".
>>
>> The syscall nr is embedded in the instruction as an immediate
>> value and you're getting a copy of that instruction using the value of
>> the pc register just after the syscall instruction was executed.)
>>
>> Perhaps I am missing or forgetting something. Why isn't this as simple
>> as calling get_user() or even copy_from_user() using instr_addr?
>
> In c/r, we only need it at restart when a task calls it on itself.
>
> However the interface itself of get_syscall_nr() can be called by
> any task on another task.
>
> (In fact, I think that for the most part, saving the syscall number
> at checkpoint time may be better than figuring out at restart time).
>

So, as Oren is saying, the point was to make the syscall_get_nr(..)
work according to the interface specified in
include/asm-generic/syscall.h.

Considering it's unknown how we will deal with checkpoint/restart
across CONFIG_ARM_THUMB, CONFIG_OABI_COMPAT etc., I also think it's a
better idea to checkpoint the syscall number at checkpoint and for the
restore, place architecture specific hooks to get the syscall number
instead of calling syscall_get_nr(...) directly. In this way we should
always be able to get the syscall and correctly restart, independently
of what tricks we do to checkpoint restart across configuration
settings - if any.

Best,
Christoffer
