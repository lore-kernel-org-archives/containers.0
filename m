From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 11/11][v15]: Document sys_eclone
Date: Mon, 05 Jul 2010 00:18:53 -0400
Message-ID: <4C315D2D.6000107@cs.columbia.edu>
References: <1278189164-28408-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1278189164-28408-12-git-send-email-sukadev@linux.vnet.ibm.com>
	<AANLkTinM1jqG-9Mgbzft8bALGri7ZpzU9ZcPbMTe4fvW@mail.gmail.com>
	<20100704233951.GK3338@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Albert Cahalan <acahalan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
> On Sat, Jul 03, 2010 at 07:41:30PM -0400, Albert Cahalan wrote:
>> On Sat, Jul 3, 2010 at 4:32 PM, Sukadev Bhattiprolu
>> <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>>

[...]

>>> +       The order of pids in @pids is oldest in pids[0] to youngest pid
>>> +       namespace in pids[nr_pids-1]. If the number of pids specified in the
>>> +       @pids list is fewer than the nesting level of the process, the pids
>>> +       are applied from youngest namespace. I.e if the process is nested in
>>> +       a level-6 pid namespace and @pids only specifies 3 pids, the 3 pids
>>> +       are applied to levels 6, 5 and 4. Levels 0 through 3 are assumed to
>>> +       have a pid of '0' (the kernel will assign a pid in those namespaces).
>> That feels backwards. I'd have guessed pids[0] is how the
>> process sees itself. You'd truncate the array to reduce nesting
>> level rather than pointing into it.
> 
> The only difference between what you ask for and what eclone does is the
> order of the pids. The array is truncatable as you requested. Knowing nr_pids
> is sufficient -- there's no need for something "pointing into it".
> 
> ISTR it was ordered this way to avoid odd-looking loops or extra copying in
> the kernel pid code. Suka may recall the reasoning better than I do -- I'd
> have to dig through list archives to be certain.

This is what I remember, too: the idea was to order the pid's in
the order that the kernel - and (many of ?) us humans - view of
them: top-down. IOW, this corresponds to the hierarchical nature
of the pid-namespace hierarchy: ancestors come first, followed by
descendants.

> 
>>> +       On failure, eclone() returns -1 and sets 'errno' to one of following
>>> +       values (the child process is not created).
>> Careful here: do you intend to document the system call itself,
>> or an expected glibc wrapper that doesn't exist yet?
>>
>>> +       EPERM   Caller does not have the CAP_SYS_ADMIN privilege needed to
>>> +               specify the pids in this call (if pids are not specifed
>>> +               CAP_SYS_ADMIN is not required).
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

I assume that by "any child namespace" you mean "any descendant
namespace" ?

I'm with Matt here. In particular, I make the distinction between
where a process "lives" and where it is "visible". A process is
visible in all the pid-namespaces up its ancestry. However, it
"lives" only in the bottom-most pid-namespace. For example, if it
calls kill(2), it will affect another process in _that_ namespace.

It follows that trying to set pid's in pid-namespaces _below_ you
simply doesn't make sense (beyond the CLONE_NEWPID case).

Finally, there have been objections before to allow pid-selection
by non-privileged process. If such functionality is deemed desired
later on, it can be easily added. However, let's separate that
discussion from the current discussion.

[...]

>>> +static int do_clone(int (*child_fn)(void *), void *child_arg,
>>> +               unsigned int flags_low, int nr_pids, pid_t *pids_list)
>> There needs to be a way to pass child_fn and child_arg
>> via the kernel. Besides being required for kernel-managed
>> stacks, it's normally a saner interface. Stack setup would
>> be much like the stack setup for signal handlers. Imagine
> 
> I'm inclined to say this is a bad idea.
> 
> I didn't think we had "kernel-managed stacks" in mainline. The most we
> have, to my knowledge, is the sigaltstack support and kernel threads.
> 
> I don't see how being able to pass in child_fn and child_arg to the
> kernel improves the sanity of the interface. If anything it will make
> eclone even more exotic -- now at the end of the syscall we'll
> need to mess with the registers/stack of the child much like when we're
> invoking a signal handler. That just adds more arch-specific code than is
> necessary.
> 
> Userspace wrappers are perfectly capable of invoking the child function
> and passing the arguments. Furthermore, passing those arguments requires
> expanding the argument structure or putting even greater pressure on
> registers (which, as you pointed out below, is an issue for vfork).
> 
>> using this for a vfork-like interface that didn't have painful
>> interactions with the compiler.

Pardon my ignorance - what sort of painful interactions ?

>>
>> Speaking of vfork....
>>
>> 1. can you implement it for i386 (register starved) using eclone?
> 
> That's a very good question. I'm going to punt on a direct answer for
> now. Instead,  I wonder if it's even worth enabling vfork through eclone.
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

Indeed good question.

Let me add: "we do not support YET".

It is not too complicated add support to vfork - it merely requires
that we emulate the behavior of both parent and child once they have
completed to restore their state, to ensure that the parent waits
for the child's completion.

(BTW, similar logic will be required to support checkpoint and
especially restart of ptraced processes).

It's just that it will require some (minor, I believe) edits to
the vfork code - which I want to avoid as long as we are awaiting
more review of the current code.

Oren.
