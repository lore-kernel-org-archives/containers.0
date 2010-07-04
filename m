From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Sun, 4 Jul 2010 16:39:51 -0700
Message-ID: <20100704233951.GK3338@count0.beaverton.ibm.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
> On Sat, Jul 3, 2010 at 4:32 PM, Sukadev Bhattiprolu
> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
> > +struct clone_args {
> > +       u64 clone_flags_high;
> > +       u64 child_stack_base;
> > +       u64 child_stack_size;
> > +       u64 parent_tid_ptr;
> > +       u64 child_tid_ptr;
> > +       u32 nr_pids;
> > +       u32 reserved0;
> > +};
> > +
> > +
> > +sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs_size,
> > +               pid_t * __user pids)
> 
> I don't see why cargs_size is needed for expansion if you have flags.

I think it's cleaner this way. The alternative you seem to be hinting at
is:

If we used a flag bit to indicate an expansion of the parameters then it
would only be able to specify one expansion before we'd have to start
using bits in the args structure itself. Using those extra bits is
quite gross -- we'd have to copy the initial portion of the struct, decode
the bit(s) describing the size, and then copy the rest. Also, do we have
any bits left in flags_low? I thought those were all used up...

Or perhaps I wasn't able to anticipate the details of your suggestion
and you had something else in mind?

The way Suka has it we just directly encode the size of struct clone_args
as a parameter and get it over with.

> 
> > +       The order of pids in @pids is oldest in pids[0] to youngest pid
> > +       namespace in pids[nr_pids-1]. If the number of pids specified in the
> > +       @pids list is fewer than the nesting level of the process, the pids
> > +       are applied from youngest namespace. I.e if the process is nested in
> > +       a level-6 pid namespace and @pids only specifies 3 pids, the 3 pids
> > +       are applied to levels 6, 5 and 4. Levels 0 through 3 are assumed to
> > +       have a pid of '0' (the kernel will assign a pid in those namespaces).
> 
> That feels backwards. I'd have guessed pids[0] is how the
> process sees itself. You'd truncate the array to reduce nesting
> level rather than pointing into it.

The only difference between what you ask for and what eclone does is the
order of the pids. The array is truncatable as you requested. Knowing nr_pids
is sufficient -- there's no need for something "pointing into it".

ISTR it was ordered this way to avoid odd-looking loops or extra copying in
the kernel pid code. Suka may recall the reasoning better than I do -- I'd
have to dig through list archives to be certain.

> 
> > +       On failure, eclone() returns -1 and sets 'errno' to one of following
> > +       values (the child process is not created).
> 
> Careful here: do you intend to document the system call itself,
> or an expected glibc wrapper that doesn't exist yet?
> 
> > +       EPERM   Caller does not have the CAP_SYS_ADMIN privilege needed to
> > +               specify the pids in this call (if pids are not specifed
> > +               CAP_SYS_ADMIN is not required).
> 
> It seems appropriate to let PID 1 in any PID namespace be
> able to assign PIDs in it's own namespace and in any
> child namespaces.

I disagree. The way you describe it, more than one "pid 1" could be
involved thus the pid assignment could conflict. Especially in the case
of container checkpoint/restart where one or more of those "pid 1" tasks
is not aware that it's being restarted. It gets even worse if you don't
assume that the same container software is being used in nested
containers.

> 
> > +       EINVAL  The child_stack_size field is not 0 (on architectures that
> > +               pass in a stack pointer in ->child_stack field).
> 
> need to change this
> 
> > +                "int $0x80\n\t"        /* Linux/i386 system call */
> > +                "testl %0,%0\n\t"      /* check return value */
> > +                "jne 1f\n\t"           /* jump if parent */
> > +
> > +                "popl %%esi\n\t"       /* get subthread function */
> > +                "call *%%esi\n\t"      /* start subthread function */
> > +                "movl %2,%0\n\t"
> > +                "int $0x80\n"          /* exit system call: exit subthread */
> ...
> > +/*
> > + * Allocate a stack for the clone-child and arrange to have the child
> > + * execute @child_fn with @child_arg as the argument.
> > + */
> ...
> > +       *--stack = child_arg;
> > +       *--stack = child_fn;
> ...
> > +static int do_clone(int (*child_fn)(void *), void *child_arg,
> > +               unsigned int flags_low, int nr_pids, pid_t *pids_list)
> 
> There needs to be a way to pass child_fn and child_arg
> via the kernel. Besides being required for kernel-managed
> stacks, it's normally a saner interface. Stack setup would
> be much like the stack setup for signal handlers. Imagine

I'm inclined to say this is a bad idea.

I didn't think we had "kernel-managed stacks" in mainline. The most we
have, to my knowledge, is the sigaltstack support and kernel threads.

I don't see how being able to pass in child_fn and child_arg to the
kernel improves the sanity of the interface. If anything it will make
eclone even more exotic -- now at the end of the syscall we'll
need to mess with the registers/stack of the child much like when we're
invoking a signal handler. That just adds more arch-specific code than is
necessary.

Userspace wrappers are perfectly capable of invoking the child function
and passing the arguments. Furthermore, passing those arguments requires
expanding the argument structure or putting even greater pressure on
registers (which, as you pointed out below, is an issue for vfork).

> using this for a vfork-like interface that didn't have painful
> interactions with the compiler.
> 
> Speaking of vfork....
> 
> 1. can you implement it for i386 (register starved) using eclone?

That's a very good question. I'm going to punt on a direct answer for
now. Instead,  I wonder if it's even worth enabling vfork through eclone.
vfork is rarely used, is supported by the "old" clone syscall, and any
old code adapted to use eclone for vfork would need significant
changes because of vfork's specialness. (A consequence of the way vfork
borrows page tables and must avoid clobbering parent's registers..)

So while vfork support in eclone might be "nice" to have I don't think
it's strictly necessary.

> 
> 2. can you restart a pair of processes between vfork and execve?

Another good question.

No, we do not support that. In fact, the man page suggests vfork children
are not supposed to make syscalls other than execve, kill(SIGABRT), or
"_exit". To me that clearly justifies not being able to call restart from
a vfork child.

Cheers,
	-Matt Helsley
