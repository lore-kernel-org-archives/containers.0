From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Wed, 24 Mar 2010 18:11:32 -0700
Message-ID: <20100325011132.GE5704__3294.84842154688$1269479538$gmane$org@count0.beaverton.ibm.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-2-git-send-email-christofferdall@christofferdall.dk>
	<20100323205342.GA19572@n2100.arm.linux.org.uk>
	<20100324020342.GB5704@count0.beaverton.ibm.com>
	<Pine.LNX.4.64.1003240055050.5867@takamine.ncl.cs.columbia.edu>
	<20100324140252.GC5704@count0.beaverton.ibm.com>
	<4BAA3586.1020604@cs.columbia.edu>
	<7d08b87d1003241236n2b45e6f4ife36da841351df9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <7d08b87d1003241236n2b45e6f4ife36da841351df9d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 24, 2010 at 08:36:39PM +0100, Christoffer Dall wrote:
> On Wed, Mar 24, 2010 at 4:53 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
> >
> >
> > Matt Helsley wrote:
> >>
> >> On Wed, Mar 24, 2010 at 12:57:46AM -0400, Oren Laadan wrote:
> >>>
> >>> On Tue, 23 Mar 2010, Matt Helsley wrote:
> >>>
> >>>> On Tue, Mar 23, 2010 at 08:53:42PM +0000, Russell King - ARM Linux
> >>>> wrote:
> >>>>>
> >>>>> On Sun, Mar 21, 2010 at 09:06:03PM -0400, Christoffer Dall wrote:
> >>>>>>
> >>>>>> This small commit introduces a global state of system calls for ARM
> >>>>>> making it possible for a debugger or checkpointing to gain information
> >>>>>> about another process' state with respect to system calls.
> >>>>>
> >>>>> I don't particularly like the idea that we always store the syscall
> >>>>> number to memory for every system call, whether the stored version is
> >>>>> used or not.
> >>>>>
> >>>>> Since ARM caches are generally not write allocate, this means mostly
> >>>>> write-only variables can have a higher than expected expense.
> >>>>>
> >>>>> Is there not some thread flag which can be checked to see if we need to
> >>>>> store the syscall number?
> >>>>
> >>>> Perhaps before we freeze the task we can save the syscall number on ARM.
> >>>> The patches suggest that the signal delivery path -- which the freezer
> >>>> utilizes -- has the syscall number already.
> >
> > Actually, the signal path doesn't have the syscall number, it has
> > a binary "in syscall" value.
> >

Argh. I read too much into the name :(.

> 
> Well, this could be changed to pass the syscall number through
> registers along to try_to_freeze without any mentionable performance
> hit.

Yes, that's possible. I was thinking we could still use your thread info
field but only store to it when we know it will be useful for c/r rather
than for each syscall. Personally, I'd rather avoid passing the extra
parameter into try_to_freeze(). Your idea below seems better to me.

> Re-using the assembly code or factoring it out so that it can be used
> from multiple places doesn't seem very pleasing to me, as the assembly
> code is in the critical path and written specifically for the context
> of a process entering the kernel. Please correct me if I'm wrong.
> 
> I imagine simply a function in C, more or less re-implementing the
> logic that's already in entry-common.S, might do the trick. I wouldn't
> worry much about the performance in this case as it will not be used
> often. The following _untested_ snippet illustrates my idea:
> 
> ---
>  arch/arm/include/asm/syscall.h |   93 +++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 92 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
> index 3b3248f..a7f2615 100644
> --- a/arch/arm/include/asm/syscall.h
> +++ b/arch/arm/include/asm/syscall.h
> @@ -10,10 +10,101 @@
>  #ifndef _ASM_ARM_SYSCALLS_H
>  #define _ASM_ARM_SYSCALLS_H
> 
> +static inline int get_swi_instruction(struct task_struct *task,
> +				      struct pt_regs *regs,
> +				      unsigned long *instr)
> +{
> +	struct page *page = NULL;
> +	unsigned long instr_addr;
> +	unsigned long *ptr;
> +	int ret;
> +
> +	instr_addr = regs->ARM_pc - 4;
> +
> +	down_read(&task->mm->mmap_sem);
> +	ret = get_user_pages(task, task->mm, instr_addr,
> +			     1, 0, 0, &page, NULL);
> +	up_read(&task->mm->mmap_sem);
> +
> +	if (ret < 0)
> +		return ret;
> +
> +	ptr = (unsigned long *)kmap_atomic(page, KM_USER1);
> +	memcpy(instr,
> +	       ptr + (instr_addr >> PAGE_SHIFT),
			^shouldn't this be:
		      instr_addr & PAGE_MASK

> +	       sizeof(unsigned long));
> +	kunmap_atomic(ptr, KM_USER1);
> +
> +	page_cache_release(page);
> +
> +	return 0;
> +}

(again, not familiar with ARM so my understanding is:

I guess swi is "syscall word immediate".

The syscall nr is embedded in the instruction as an immediate
value and you're getting a copy of that instruction using the value of
the pc register just after the syscall instruction was executed.)

Perhaps I am missing or forgetting something. Why isn't this as simple
as calling get_user() or even copy_from_user() using instr_addr?

Cheers,
	-Matt Helsley
