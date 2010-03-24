From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 2/3] ARM: Add the eclone system call
Date: Wed, 24 Mar 2010 11:19:07 -0700
Message-ID: <20100324181907.GA28161__11022.3870179199$1269454530$gmane$org@us.ibm.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-3-git-send-email-christofferdall@christofferdall.dk>
	<20100323210616.GB19572@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100323210616.GB19572-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

Russell King - ARM Linux [linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org] wrote:
| > +asmlinkage int sys_eclone(unsigned flags_low, struct clone_args __user *uca,
| > +			  int args_size, pid_t __user *pids,
| > +			  struct pt_regs *regs)
| > +{
| > +	int rc;
| > +	struct clone_args kca;
| > +	unsigned long flags;
| > +	int __user *parent_tidp;
| > +	int __user *child_tidp;
| > +	unsigned long __user stack;
| 
| __user on an integer type doesn't make any sense; integer types do not
| have address spaces.

Ah, will fix  that for x86 32/64 bit implementations.

| 
| > +	unsigned long stack_size;
| > +
| > +	rc = fetch_clone_args_from_user(uca, args_size, &kca);
| > +	if (rc)
| > +		return rc;
| > +
| > +	/*
| > +	 * TODO: Convert 'clone-flags' to 64-bits on all architectures.
| > +	 * TODO: When ->clone_flags_high is non-zero, copy it in to the
| > +	 * 	 higher word(s) of 'flags':
| > +	 *
| > +	 * 		flags = (kca.clone_flags_high << 32) | flags_low;
| > +	 */
| > +	flags = flags_low;
| > +	parent_tidp = (int *)(unsigned long)kca.parent_tid_ptr;
| > +	child_tidp = (int *)(unsigned long)kca.child_tid_ptr;
| 
| This will produce sparse errors.  Is there a reason why 'clone_args'
| tid pointers aren't already pointers marked with __user ?

Making them pointers would make them 32-bit on some and 64-bit on other
architectures. We wanted the fields to be the same size on all architectures
for easier portability/extensibility. Given that we are copying-in a structure
from user-space, copying in a few extra bytes on the 32-bit architectures
would not be significant.

| 
| > +
| > +	stack_size = (unsigned long)kca.child_stack_size;
| 
| Shouldn't this already be of integer type?
| 
| > +	if (stack_size)
| > +		return -EINVAL;
| 
| So the stack must have a zero size?  Is this missing a '!' ?

Some architectures (IA64 ?) use the stack-size field. Those that don't
need it should error out. Again, its because we are trying to keep the
interface common across architectures.

| 
| > +
| > +	stack = (unsigned long)kca.child_stack;
| > +	if (!stack)
| > +		stack = regs->ARM_sp;
| > +
| > +	return do_fork_with_pids(flags, stack, regs, stack_size, parent_tidp,
| > +				child_tidp, kca.nr_pids, pids);
| 
| Hmm, so let me get this syscall interface right.  We have some arguments
| passed in registers and others via a (variable sized?) structure.  It seems
| really weird to have, eg, a pointer to the pids and the number of pids
| passed in two separate ways.
| 
| The grouping between what's passed in registers and via this clone_args
| structure seems to be random.  Can it be sanitized?

:-) Well, we went through a lot of discussions on this. Here is one pointer
http://lkml.org/lkml/2009/9/11/92 (and that was version 6 of 13+ :-).

We wanted the first parameter of eclone(), flags, to remain 32-bit value to
avoid confusing user-space. (i.e if they accidentally pass a 64-bit flags
value to the clone() system call which takes 32-bit flags, the higher-32
bits would silently be dropped). 

By sticking the higher clone-flags in 'struct clone_args', all architectures
would have to do the same extra work to set the higher flags so less
chance of error.

Re: passing the number of pids, nr_pids in the structure, I think it was
just that by passing it in the structure, we could avoid using an extra
register for the system call parameter.

'pid_t *' would be of different size on different architecutres. Passing
it as a separate parameter would avoid the pointer conversion.  Note
that unlike the tid pointers above which are a few individual fields,
the pid_t array could in theory be large.

Hope that helps. Thanks the review comments.

Sukadev
