From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Wed, 24 Mar 2010 18:17:53 -0700
Message-ID: <20100325011753.GF5704__3387.59078081257$1269479922$gmane$org@count0.beaverton.ibm.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-2-git-send-email-christofferdall@christofferdall.dk>
	<20100323205342.GA19572@n2100.arm.linux.org.uk>
	<20100324020342.GB5704@count0.beaverton.ibm.com>
	<Pine.LNX.4.64.1003240055050.5867@takamine.ncl.cs.columbia.edu>
	<20100324140252.GC5704@count0.beaverton.ibm.com>
	<4BAA3586.1020604@cs.columbia.edu>
	<7d08b87d1003241236n2b45e6f4ife36da841351df9d@mail.gmail.com>
	<20100325011132.GE5704@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100325011132.GE5704-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 24, 2010 at 06:11:32PM -0700, Matt Helsley wrote:
> On Wed, Mar 24, 2010 at 08:36:39PM +0100, Christoffer Dall wrote:
<snip>
> > Re-using the assembly code or factoring it out so that it can be used
> > from multiple places doesn't seem very pleasing to me, as the assembly
> > code is in the critical path and written specifically for the context
> > of a process entering the kernel. Please correct me if I'm wrong.
> > 
> > I imagine simply a function in C, more or less re-implementing the
> > logic that's already in entry-common.S, might do the trick. I wouldn't
> > worry much about the performance in this case as it will not be used
> > often. The following _untested_ snippet illustrates my idea:
> > 
> > ---
> >  arch/arm/include/asm/syscall.h |   93 +++++++++++++++++++++++++++++++++++++++-
> >  1 files changed, 92 insertions(+), 1 deletions(-)
> > 
> > diff --git a/arch/arm/include/asm/syscall.h b/arch/arm/include/asm/syscall.h
> > index 3b3248f..a7f2615 100644
> > --- a/arch/arm/include/asm/syscall.h
> > +++ b/arch/arm/include/asm/syscall.h
> > @@ -10,10 +10,101 @@
> >  #ifndef _ASM_ARM_SYSCALLS_H
> >  #define _ASM_ARM_SYSCALLS_H
> > 
> > +static inline int get_swi_instruction(struct task_struct *task,
> > +				      struct pt_regs *regs,
> > +				      unsigned long *instr)
> > +{
> > +	struct page *page = NULL;
> > +	unsigned long instr_addr;
> > +	unsigned long *ptr;
> > +	int ret;
> > +
> > +	instr_addr = regs->ARM_pc - 4;
> > +
> > +	down_read(&task->mm->mmap_sem);
> > +	ret = get_user_pages(task, task->mm, instr_addr,
> > +			     1, 0, 0, &page, NULL);
> > +	up_read(&task->mm->mmap_sem);
> > +
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	ptr = (unsigned long *)kmap_atomic(page, KM_USER1);
> > +	memcpy(instr,
> > +	       ptr + (instr_addr >> PAGE_SHIFT),
> 			^shouldn't this be:
> 		      instr_addr & PAGE_MASK

Oops, made my own mistake. I think the address of the kmap'd instruction
would be:

	ptr + (instr_addr & ~PAGE_MASK)

Cheers,
	-Matt Helsley
