From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 0/7 + tools] Checkpoint/restore mostly in the
	userspace
Date: Tue, 26 Jul 2011 15:02:15 -0700
Message-ID: <20110726220215.GE14808@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com>
	<20110723002558.GE16940@count0.beaverton.ibm.com>
	<20110723051005.GE21089@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110723051005.GE21089-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Jul 23, 2011 at 07:10:05AM +0200, Tejun Heo wrote:
> Hello,
> 
> On Fri, Jul 22, 2011 at 05:25:58PM -0700, Matt Helsley wrote:
> > Finally, I think there's substantial room here for quiet and subtle
> > races to corrupt checkpoint images. If we add /proc interfaces only to
> > find they're racy will we need to add yet more /proc interfaces to
> > maintain backward compatibility yet fix the races? To get the locking
> > that ensures a consistent subset of information with this /proc-based
> > approach I think we'll frequently need to change the contents of
> > existing /proc files.
> 
> The target processes need to be frozen to remove race conditions (be
> it SIGSOTP, cgroup freeze or PTRACE trap).  If there are exceptions in

SIGSTOP does not work as I've pointed out several times. I already pointed
out the problem with using the cgroup freezer as-is. As for ptrace
trapping, how would checkpointing a process and its debugger work?
This can happen when checkpointing a container. It seems to me that
they'd interfere with each other by either preventing one another from
attaching (last I checked ptrace was limited this way -- apologies if I
missed some of your work) or one would resume the task 'unexpectedly'
Do we aspire to have these bugs or would we rather plan on having
something that works?

> the boundaries between frozen domain and the rest of the system,
> they'll need to be dealt with and those need to be dealt with whether
> the thing is in kernel or not.

in-kernel we can use existing locks without changing the interface.

What's the plan for userspace? Will it be possible for userspace to
accidentally use the interfaces without holding the userspace "locks"
and thus quietly gather inconsistent information? I think the freezer
is necessary but not sufficient.

> > Imagine trusting the output of top to exactly represent the state of
> > your system's cpu usage. That's the sort of thing a piecemeal /proc
> > interface gets us. You're asking us to trust that frequent checkpoints
> > (say once every five minutes) of large, multiprocess, month-long
> > program runs won't quietly get corrupted and will leave plenty of
> > performance to not interfere with the throughput of the work.
> 
> This is rather bogus.  If you freeze the processes, most of the
> information in /proc (the ones which would show up in top anyway)

"most"... begging the question: which?

What the freezer covers seems very loosely defined in comparison to kernel
lock coverage (kernel locks also have great tool support..).
While the freezer is useful I think we'd be foolish to rely on empirical
observation of which /proc contents don't seem to change while the task is
frozen. As best I can tell the only thing the freezer is guaranteed to
cover is the register state of the frozen task and keep it in-kernel so
only that task cannot execute and produce side-effects. Once you
get to multiple threads/processes it's possible for them to share mm,
fd table, filesystem data, etc. so you have to make sure that everything
that shares those resources is also frozen and remains frozen for the
duration of the checkpoint (the point of a previous post about the freezer).
How will we find all things that share an mm, or an fd table, etc.
in a race-free way, from userspace, and ensure they are and remain frozen?
What about other shared resources like System V Shm, Sems,... ?

> doesn't change.  What race condition?

It's hard to point to specific race conditions when *you* haven't
posted checkpoint code -- just hints and ideas. Until you have something
more substantial the best I can do is review Pavel's code and worry about
what problems might later be uncovered in the future ptrace/proc
interfaces you choose to introduce.

> > A kernel syscall interface has a better chance of allowing us to fix
> > races without changing the interface. We've fixed a few races with
> > Oren's tree and none of them required us to change the output format.
> 
> Sure, that was completely embedded in the kernel and things can be
> implemented and fixed with much less consideration.  I can see how
> that would be easier for the specific use case, but that EXACTLY is
> why it can't go upstream.  I just can't see it happening and think it

It can't go upstream because it's too easy to implement and fix?
It can't go upstream because it has a specific use case?
Is there something that says every interface added to the kernel *must*
be useful for something besides the purpose that originally inspired it?

> would be far more productive spending the time and energy looking for
> and implementing solutions which actually can go mainline.  If you

Oh, you mean stuff that's hard to implement and fix? ;)

> don't care about mainlining, that's great too, but then there's no
> point in talking about it either.

Quite the contrary. How is it a good thing to ignore flaws in a
proposed solution to a problem? You're advocating a bunch of new kernel 
interfaces with the idea that they will be useful for checkpoint/restart.
If they turn out to be racy for the purposes of checkpointing then
kernel maintainers such as yourself will have those interfaces to support
and we will still have no reliable "mainline" checkpoint/restart.

I keep going back to the in-kernel implementation because I believe it
sets the bar -- I think you should do as well or better if you're going
to claim these interfaces are useful for checkpoint/restart. That does not
mean I expect people to like the out-of-tree in-kernel implementation. We
were given a high standard to meet for our checkpoint/restart work and I
don't see why your checkpoint/restart solution should be held to a lower
standard.

So if you don't want me to bring up in-kernel checkpoint/restart then stop
suggesting these interfaces will enable checkpoint/restart or show me
some real code.

Cheers,
	-Matt
