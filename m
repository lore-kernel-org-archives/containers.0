From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Creating tasks on restart: userspace vs kernel
Date: Tue, 14 Apr 2009 20:36:33 +0400
Message-ID: <20090414163633.GE27461@x200.localdomain>
References: <49E40662.2040508@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756892AbZDNQgg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E40662.2040508@cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org

On Mon, Apr 13, 2009 at 11:43:30PM -0400, Oren Laadan wrote:
> For checkpoint/restart (c/r) we need a method to (re)create the tasks
> tree during restart. There are basically two approaches: in userspace
> (zap approach) or in the kernel (openvz approach).
> 
> Once tasks have been created both approaches are similar in that all
> restarting tasks end up calling the equivalent of "do_restart()" in
> the kernel to perform the gory details of restoring its state.
> 
> In terms of performance, both approaches are similar, and both can
> optimize to avoid duplicating resources unnecessarily during the
> clone (e.g. mm, etc) knowing that they will be reconstructed soon
> after.
> 
> So the question is what's better - user-space or kernel ?
> 
> Too bad that Alexey chose to ignore what's been discussed in
> linux-containers mailing list in his recent post.  Here is my take on
> cons/pros.
> 
> Task creation in the kernel
> ---------------------------
> * how: the user program calls sys_restart() which, for each task to
>   restore, creates a kernel thread which is demoted to a regular
>   process manually.
> 
> * pro: a single task that calls sys_restart()
> * pro: restarting tasks are in full control of kernel at all times
> 
> * con: arch-dependent, harder to port across architectures

Not a "con" at all.

For the usage purposes, kernel_thread() is arch-independent.
Filesystems create kernel threads and not have a single bit of
arch-specific code.

> * con: can only restart a full container

This is by design.

Granularity of whole damn thing is one container both on checkpoint and
restart.

You want to chop pieces, fine, do surgery on _image_.

> Task creation in user space
> ---------------------------
> * how: the user programs calls fork/clone to recreate a suitable
>   task tree in userspace, and each task calls sys_restart() to restore
>   its state; some kernel glue is necessary to synchronize restarting
>   tasks when in the kernel.

> * pro: allows important flexibility during restart (see <1>)
> * pro: code leverages existing well-understood syscalls (fork, clone)

kernel_thread() is effectively clone(2).

> * pro: allows restart of a only subtree (see <2>)
> 
> * con: requires a way to creates tasks with specific pid (see <3>)
> 
> <1> Flexibility:
> 
> In the spirit of madvise() that lets tasks advise the kernel because
> they know better, there should be cradvise() for checkpoint/restart
> purposes. During checkpoint it can tell the kernel "don't save this
> piece of memory, it's scratch", or "ignore this file-descriptor" etc.
> During restart, it will can tell the kernel "use this file-descriptor"
> or "use this network namespace" (instead of trying to restore).
> 
> Offering cradvise() capability during restart is especially important
> in cases where the kernel (inevitably) won't know how to restore a
> resource (e.g. think special devices), when the application wants to
> override (e.g. think of a c/r aware server that would like to change
> the port on which it is listening), or when it's that much simpler to
> do it in userspace (e.g. think setting up network namespaces).
> 
> Another important example is distributed checkpoint, where the
> restarting tasks could (re)create all their network connections in
> user space, before invoking sys_restart() and tell the kernel, via
> cradvise(), to use the newly created sockets.
> 
> The need for this sort of flexibility has been stressed multiple times
> and by multiple stake-holders interested in checkpoint/restart.
> 
> <2> Restarting a subtree:
> 
> The primary c/r effort is directed towards providing c/r functionality
> for containers.
> 
> Wouldn't it be nice if, while doing so and at minimal added effort, we
> also gain a method to checkpoint and restart an arbitrary subtree of
> tasks, which isn't necessarily an entire container ?

Do this in userspace.

> Sure, it will be more constrained (e.g. resulting pid in restart won't
> match the original pids), and won't work for all applications.

Given correctly written image chopper, all pids will be fine and
correctness will be bounded by how good user understands what can be
chopped and can't.

Besides, if such chopper can only chop task_struct's, you'll get correct
image.

In the end correctness of chopping will be equal to how good user
understands that two task_struct's are independent of each other.

> But it will still be a useful tool for many use cases, like batch cpu jobs,
> some servers, vnc sessions (if you want graphics) etc. Imagine you run
> 'octave' for a week and must reboot now - 'octave' wouldn't care if
> you checkpointed it and then restart with a different pid !
> 
> <3> Clone with pid:
> 
> To restart processes from userspace, there needs to be a way to
> request a specific pid--in the current pid_ns--for the child process
> (clearly, if it isn't in use).
> 
> Why is it a disadvantage ?  to Linus, a syscall clone_with_pid()
> "sounds like a _wonderful_ attack vector against badly written
> user-land software...".  Actually, getting a specific pid is possible
> without this syscall.  But the point is that it's undesirable to have
> this functionality unrestricted.
> 
> So one option is to require root privileges. Another option is to
> restrict such action in pid_ns created by the same user. Even more so,
> restrict to only containers that are being restarted.

You want to do small part in userspace and consequently end up with hacks
both userspace-visible and in-kernel.

Pids aren't special, they are struct pid, dynamically allocated and
refcounted just like any other structtures.

They _become_ special for you intended method of restart.

You also have flags in nsproxy image (or where?) like "do clone with
CLONE_NEWUTS".

This is unneeded!

nsproxy (or task_struct) image have reference (objref/position) to uts_ns image.

On restart, one lookups object by reference or restore it if needed,
takes refcount and glue. Just like with every other two structures.

No "what to do, what to do" logic.

> Either way we go, it should be fairly easy to switch from one method
> to the other, should we need to.
> 
> All in all, there isn't a strong reason in favor of kernel method.
> 
> In contrast, it's at least as simple in userspace (reusing existing
> syscalls). More importantly, the flexibility that we gain with restart
> of tasks in userspace, no cost incurred (in terms of implementation or
> runtime overhead).

Regarding of who should orchestrate restart(2).

Special process who calls restart(2) should do it. It doesn't relate to
restarted process at all. It isn't, for example, init of future container.

Reasons:
1) somebody should write registers before final jump to userspace.
   Task itself can't generally do it: struct pt_regs is in the same place
   as kernel stack.

   cr_load_cpu_regs() does exactly this: as current writes to it's own
   pt_regs. Oren, why don't you see crashes?

   I first tried to do it and was greeted with horrible crashes because
   e.g current becoming NULL under current. That's why 
   cr_arch_restore_task_struct() is not done in current context.

2) Somebody should restore who is parent of whom, who ptraces whom,
   resolved all possible loops and so on. Intuition tells me that it
   should be context which is not involved into restart(2) other than
   doing this post-restart-before-thaw part.

   Consequently, it should not be init of futire container. It's just
   another task after all, from the POV of reparenting code.
