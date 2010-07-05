From: Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Sun, 4 Jul 2010 20:45:42 -0400
Message-ID: <AANLkTilTGvFTkjy8vi8N8msB7koEp0r7SnpPqJkVN4XA@mail.gmail.com>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100704233951.GK3338-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Jul 4, 2010 at 7:39 PM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
>> On Sat, Jul 3, 2010 at 4:32 PM, Sukadev Bhattiprolu
>> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>
>> > +struct clone_args {
>> > + =A0 =A0 =A0 u64 clone_flags_high;
>> > + =A0 =A0 =A0 u64 child_stack_base;
>> > + =A0 =A0 =A0 u64 child_stack_size;
>> > + =A0 =A0 =A0 u64 parent_tid_ptr;
>> > + =A0 =A0 =A0 u64 child_tid_ptr;
>> > + =A0 =A0 =A0 u32 nr_pids;
>> > + =A0 =A0 =A0 u32 reserved0;
>> > +};
>> > +
>> > +
>> > +sys_eclone(u32 flags_low, struct clone_args * __user cargs, int cargs=
_size,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t * __user pids)
>>
>> I don't see why cargs_size is needed for expansion if you have flags.
>
> I think it's cleaner this way. The alternative you seem to be hinting at
> is:
>
> If we used a flag bit to indicate an expansion of the parameters then it
> would only be able to specify one expansion before we'd have to start
> using bits in the args structure itself. Using those extra bits is
> quite gross -- we'd have to copy the initial portion of the struct, decode
> the bit(s) describing the size, and then copy the rest. Also, do we have
> any bits left in flags_low? I thought those were all used up...

You'd be copying from a struct in userspace to some random local
variables in the kernel. There is no reason why the kernel would
have to use a struct at all. You copy the flags, then see what else
you need to copy.

FYI, interfaces with struct size parameters have a long history of
being rejected. Unless policy has changed or you've been granted
a special exemption, this isn't going to go well for you.

>> > + =A0 =A0 =A0 EPERM =A0 Caller does not have the CAP_SYS_ADMIN privile=
ge needed to
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 specify the pids in this call (if pids a=
re not specifed
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 CAP_SYS_ADMIN is not required).
>>
>> It seems appropriate to let PID 1 in any PID namespace be
>> able to assign PIDs in it's own namespace and in any
>> child namespaces.
>
> I disagree. The way you describe it, more than one "pid 1" could be
> involved thus the pid assignment could conflict. Especially in the case
> of container checkpoint/restart where one or more of those "pid 1" tasks
> is not aware that it's being restarted. It gets even worse if you don't
> assume that the same container software is being used in nested
> containers.

I agree that stuff may break, but that would be user error.
I don't see why the kernel should be protecting tasks from
being broken by strange restart situations.

>> There needs to be a way to pass child_fn and child_arg
>> via the kernel. Besides being required for kernel-managed
>> stacks, it's normally a saner interface. Stack setup would
>> be much like the stack setup for signal handlers. Imagine
>
> I'm inclined to say this is a bad idea.
>
> I didn't think we had "kernel-managed stacks" in mainline. The most we
> have, to my knowledge, is the sigaltstack support and kernel threads.

Right, I hope to add it if you don't. Right now a thread is
unable to properly exit without help from some other thread
unless the programmer dares to run without a stack.

FYI, I've done just that, in the cloninator.c test code.

Original
http://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg105341.html
http://lkml.org/lkml/2006/12/18/312

Revised
http://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg106130.html
http://lkml.org/lkml/2006/12/19/335

> I don't see how being able to pass in child_fn and child_arg to the
> kernel improves the sanity of the interface. If anything it will make
> eclone even more exotic -- now at the end of the syscall we'll
> need to mess with the registers/stack of the child much like when we're
> invoking a signal handler. That just adds more arch-specific code than is
> necessary.
>
> Userspace wrappers are perfectly capable of invoking the child function
> and passing the arguments.

I'd rather that than have arch-specific code in random
programs trying to use the interface. Imagine if setting
up a signal handler required userspace code to have a
pile of arch-specific stack handling code. That'd suck.

>> Speaking of vfork....
>>
>> 1. can you implement it for i386 (register starved) using eclone?
>
> That's a very good question. I'm going to punt on a direct answer for
> now. Instead, =A0I wonder if it's even worth enabling vfork through eclon=
e.
> vfork is rarely used, is supported by the "old" clone syscall, and any
> old code adapted to use eclone for vfork would need significant
> changes because of vfork's specialness. (A consequence of the way vfork
> borrows page tables and must avoid clobbering parent's registers..)
>
> So while vfork support in eclone might be "nice" to have I don't think
> it's strictly necessary.
>
>> 2. can you restart a pair of processes between vfork and execve?
>
> Another good question.
>
> No, we do not support that. In fact, the man page suggests vfork children
> are not supposed to make syscalls other than execve, kill(SIGABRT), or
> "_exit". To me that clearly justifies not being able to call restart from
> a vfork child.

You can safely ignore the man page, which was clearly written
by a rather prejudiced author.

People use vfork. For example, GNU make uses vfork. It can be way
faster than fork for processes with large page tables.

People rely on vfork to have the traditional behavior, including the ability
to call things like dup2 and open. People expect the traditional parent
suspension, and they expect the address space (but nothing else) to
be shared. In other words, plain fork is not an acceptable substitute.
