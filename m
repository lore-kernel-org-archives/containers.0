From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: clone_with_pids() library interface
Date: Mon, 8 Jun 2009 04:25:54 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0906080354070.12219@takamine.ncl.cs.columbia.edu>
References: <20090606022225.GA19083@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090606022225.GA19083-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Coindicentally I also got it to run. The prototype is in agreement
with the usual clone() prototype.

#if defined(__i386__) && defined(__NR_clone_with_pids)
/*
 * libc doesn't support clone_with_pid() yet...
 * (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html)
 */
static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
			   struct target_pid_set *target_pids, void *arg)
{
	long retval;
	void **newstack;

	/*
	 * Set up the stack for child:
	 *  - the (void *) arg will be the argument for the child function
	 *  - the fn pointer will be loaded into ebx after the clone
	 */
	newstack = (void **) child_stack;
	*--newstack = arg;
	*--newstack = fn;

	__asm__  __volatile__(
		 "movl %0, %%ebx\n\t"		/* flags -> 1st (ebx) */
		 "movl %1, %%ecx\n\t"		/* newstack -> 2nd (ecx)*/
		 "xorl %%edi, %%edi\n\t"	/* 0 -> edi */
		 "xorl %%edx, %%edx\n\t"	/* 0 -> edx */
		 "pushl %%ebp\n\t"		/* save value of ebp */
		 "movl %2, %%ebp\n\t"		/* flags -> 6th (ebp) */
		:
		:"b" (flags),
		 "c" (newstack),
		 "r" (target_pids)
		);

	__asm__ __volatile__(
		 "int $0x80\n\t"	/* Linux/i386 system call */
		 "testl %0,%0\n\t"	/* check return value */
		 "jne 1f\n\t"		/* jump if parent */
		 "popl %%ebx\n\t"	/* get subthread function */
		 "call *%%ebx\n\t"	/* start subthread function */
		 "movl %2,%0\n\t"
		 "int $0x80\n"		/* exit system call: exit subthread */
		 "1:\n\t"
		 "popl %%ebp\t"		/* restore parent's ebp */
		:"=a" (retval)
		:"0" (__NR_clone_with_pids), "i" (__NR_exit)
		:"ebx", "ecx"
		);

	if (retval < 0) {
		errno = -retval;
		retval = -1;
	}
	return retval;
}
#endif

I added it to mktree.c and commited to user-cr.git :: ckpt-v16-dev,
I also added the clone_with_pids patches to linux-cr.git :: ckpt-v16-dev

It works well when not in a new namespace (mktree --pids < ckpt.image)
assuming the the pids are avaiable.

It doesn't work yet when in a new namespace, as the kernel code needs
to be adjusted (for the restarting tasks to find the coordintor in an
ancestor namespace).

Oren.


On Fri, 5 Jun 2009, Sukadev Bhattiprolu wrote:

> 
> Attached are two files -
> 
> 	cwp.c 		- implements clone_with_pids() library interface
> 	cwp-test.c	- a simple program to test the interface
> 
> There maybe more optimal ways of implementing it though :-)
> 
> If it makes sense, will submit as a patch to user-cr tree.
> 
> Sukadev
> 
