From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Creating tasks on restart: userspace vs kernel
Date: Mon, 13 Apr 2009 23:43:30 -0400
Message-ID: <49E40662.2040508@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754799AbZDNDqs@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-Id: containers.vger.kernel.org


For checkpoint/restart (c/r) we need a method to (re)create the tasks
tree during restart. There are basically two approaches: in userspace
(zap approach) or in the kernel (openvz approach).

Once tasks have been created both approaches are similar in that all
restarting tasks end up calling the equivalent of "do_restart()" in
the kernel to perform the gory details of restoring its state.

In terms of performance, both approaches are similar, and both can
optimize to avoid duplicating resources unnecessarily during the
clone (e.g. mm, etc) knowing that they will be reconstructed soon
after.

So the question is what's better - user-space or kernel ?

Too bad that Alexey chose to ignore what's been discussed in
linux-containers mailing list in his recent post.  Here is my take on
cons/pros.

Task creation in the kernel
---------------------------
* how: the user program calls sys_restart() which, for each task to
  restore, creates a kernel thread which is demoted to a regular
  process manually.

* pro: a single task that calls sys_restart()
* pro: restarting tasks are in full control of kernel at all times

* con: arch-dependent, harder to port across architectures
* con: can only restart a full container

Task creation in user space
---------------------------
* how: the user programs calls fork/clone to recreate a suitable
  task tree in userspace, and each task calls sys_restart() to restore
  its state; some kernel glue is necessary to synchronize restarting
  tasks when in the kernel.

* pro: allows important flexibility during restart (see <1>)
* pro: code leverages existing well-understood syscalls (fork, clone)
* pro: allows restart of a only subtree (see <2>)

* con: requires a way to creates tasks with specific pid (see <3>)

<1> Flexibility:

In the spirit of madvise() that lets tasks advise the kernel because
they know better, there should be cradvise() for checkpoint/restart
purposes. During checkpoint it can tell the kernel "don't save this
piece of memory, it's scratch", or "ignore this file-descriptor" etc.
During restart, it will can tell the kernel "use this file-descriptor"
or "use this network namespace" (instead of trying to restore).

Offering cradvise() capability during restart is especially important
in cases where the kernel (inevitably) won't know how to restore a
resource (e.g. think special devices), when the application wants to
override (e.g. think of a c/r aware server that would like to change
the port on which it is listening), or when it's that much simpler to
do it in userspace (e.g. think setting up network namespaces).

Another important example is distributed checkpoint, where the
restarting tasks could (re)create all their network connections in
user space, before invoking sys_restart() and tell the kernel, via
cradvise(), to use the newly created sockets.

The need for this sort of flexibility has been stressed multiple times
and by multiple stake-holders interested in checkpoint/restart.

<2> Restarting a subtree:

The primary c/r effort is directed towards providing c/r functionality
for containers.

Wouldn't it be nice if, while doing so and at minimal added effort, we
also gain a method to checkpoint and restart an arbitrary subtree of
tasks, which isn't necessarily an entire container ?

Sure, it will be more constrained (e.g. resulting pid in restart won't
match the original pids), and won't work for all applications. But it
will still be a useful tool for many use cases, like batch cpu jobs,
some servers, vnc sessions (if you want graphics) etc. Imagine you run
'octave' for a week and must reboot now - 'octave' wouldn't care if
you checkpointed it and then restart with a different pid !

<3> Clone with pid:

To restart processes from userspace, there needs to be a way to
request a specific pid--in the current pid_ns--for the child process
(clearly, if it isn't in use).

Why is it a disadvantage ?  to Linus, a syscall clone_with_pid()
"sounds like a _wonderful_ attack vector against badly written
user-land software...".  Actually, getting a specific pid is possible
without this syscall.  But the point is that it's undesirable to have
this functionality unrestricted.

So one option is to require root privileges. Another option is to
restrict such action in pid_ns created by the same user. Even more so,
restrict to only containers that are being restarted.

---

Either way we go, it should be fairly easy to switch from one method
to the other, should we need to.

All in all, there isn't a strong reason in favor of kernel method.

In contrast, it's at least as simple in userspace (reusing existing
syscalls). More importantly, the flexibility that we gain with restart
of tasks in userspace, no cost incurred (in terms of implementation or
runtime overhead).

Oren.
