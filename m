From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [EXAMPLE CODE] Parasite thread injection using PTRACE_SEIZE and
 friends
Date: Fri, 22 Jul 2011 16:19:53 -0700
Message-ID: <20110722231953.GC16940@count0.beaverton.ibm.com>
References: <20110720140037.GM3455@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110720140037.GM3455@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Glauber Costa <glommer@parallels.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, Jul 20, 2011 at 04:00:37PM +0200, Tejun Heo wrote:
> Hello,
> 
> This has taken much longer than expected (which BTW is usually
> expected) but ptrace fixes and new features are mostly complete now.
> They're sitting in Oleg's ptrace branch waiting for merge window.
> 
>   http://git.kernel.org/?p=linux/kernel/git/oleg/misc.git;a=shortlog;h=refs/heads/ptrace
>   git://git.kernel.org/pub/scm/linux/kernel/git/oleg/misc.git ptrace
> 
> With new ptrace requests, a process can be captured and manipulated
> practically transparently.  Other than syscall retry or -EINTR failure
> in special cases and timing difference, everything including job
> control stop state stays transparent across ptrace operations.
> 
> One of the concerns raised about using ptrace for CR was that it
> doesn't have access to states which are visible only to the process
> being checkpointed and exporting every such information outside would
> be too laborious.  The attached ptrace-parasite example code
> demonstrates how this can be solved.  Using new ptrace requests, it
> inserts a parasite thread to the host process transparently.  The code
> is also available in the following git branch (the first link is code
> brwser, second git branch you can clone from).
> 
>   http://code.google.com/p/ptrace-parasite/source/browse/
>   https://code.google.com/p/ptrace-parasite/ ptrace-parasite
> 
> It only works on x86-64 and requires Oleg's ptrace branch.  'make'
> produces two binaries - simple-host and parasite.  If you run
> simple-host in a terminal and run parasite with the pid (thread 00's
> tid) of the simple-host in another terminal, you should see something
> like the following.
> 
>   # ./simple-host
>   thread 01(4580): alive
>   thread 02(4581): alive
>   thread 03(4582): alive
>   thread 04(4583): alive
>   thread 00(4579): alive
>   hello, world!
>   parasite: hello, world!
>   parasite: tid / time = 4629 / 1311169280
>   thread 03(4582): alive
>   thread 02(4581): alive
>   thread 01(4580): alive
>   thread 04(4583): alive
>   thread 00(4579): alive
>   ...
> 
>   # ./parasite 4579
>   Seizing 4579
>   Seizing 4580
>   Seizing 4581
>   Seizing 4582
>   Seizing 4583
>   executing test blob
>   blocking all signals = 0, prev_sigmask 0
>   executing mmap blob = 0x7fc4eca35000
>   executing clone blob = 4629
>   executing parasite
>   executing munmap blob = 0
>   restoring sigmask = 0, prev_sigmask 0xfffffffffffbfeef
> 
> The first "hello, world!" is printed by the infected host thread which
> is then directed to block all signals, mmap an area and clone parasite
> thread.  The lines which start with "parasite: " are printed by the
> new parasite thread.  While the parasite is running, all host threads
> are ptrace trapped and when they're resumed they have no way to find
> out what happened to their precious process.  Note that host can be
> any program.
> 
> The implementation is naive and simplicistic, especially the part
> which seizes all threads belonging to the target process but it should
> be enough to demonstrate how this can be done.
> 
> I'm sure there still are a lot of things missing for reasonable
> userland CR but I think this should at least provide the core process
> capturing part of it and make the whole thing more feasible.
> 
> One missing piece is that it can't operate on a process which is
> already being ptraced.  Adding nested ptrace would solve some part of
> it but it leads to a lot of complexity, most of it stemming from the
> fact that it diversifies the places target processes may be trapped
> at.  Determining which exact point isn't that difficult but rolling
> back from and restoring to some of those debug traps can be difficult
> or even impossible.  For debugger checkpointing, probably more
> cooperative approach would make more sense.  Anyways, I don't think
> this is too big a deal at this point.
> 
> Thank you.

parasitism is fine for a slow-but-sure debugger but is not suitable
for checkpoint/restart.

The difficulty of checkpoint/restart is not that the task has
more information than the kernel. Quite the contrary. Most of
the "information" the task has that the kernel is not explicitly
aware of is encoded in the task's memory. So long as the kernel
faithfully restores memory and registers the task can know little 
the kernel doesn't already know.

One example of something the task knows that the kernel does not is
which pids it cares about. However, a parasitic thread capable
of checkpointing arbitrary processes won't know about these pids
either -- it would have to be designed to checkpoint *only* the
process it was injected into.

Furthermore, the kernel has information necessary for checkpoint/restart
that the task does not. The composition of an epoll set is one
example.

So ptrace is just the wrong interface to base checkpoint/restart on.
Pavel's approach, though I believe it is subtly flawed, is better.

Cheers,
	-Matt Helsley
