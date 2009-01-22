From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Fri, 23 Jan 2009 00:06:14 +0300
Message-ID: <20090122210613.GA10158__15894.9356679388$1232658572$gmane$org@ioremap.net>
References: <200901212054.34929.knikanth@suse.de>
	<alpine.DEB.2.00.0901211241040.21080@chino.kir.corp.google.com>
	<200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
	<20090122095026.GA10579@ioremap.net>
	<alpine.DEB.2.00.0901220156310.1738@chino.kir.corp.google.com>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
	<20090122132133.GA17524@ioremap.net>
	<alpine.DEB.2.00.0901221216330.2085@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0901221216330.2085-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 22, 2009 at 12:28:45PM -0800, David Rientjes (rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) wrote:
> I don't know what you're talking about, cpusets are simply a client of the 
> cgroup interface.

Only the fact that cpusets have _very_ special meaning in the oom-killer
codepath, while it should be just another tunable (if it should be
special code at all at the first place, why there were no objection and
argument, that tasks could have different oom_adj?).

> The problem that I'm identifying with this change is that the 
> user-specified priority (in terms of oom.victim settings) conflicts when 
> the kernel encounters a system-wide unconstrained oom versus a 
> cpuset-constrained oom.
> 
> The oom.victim priority may well be valid for a system-wide condition 
> where a specific aggregate of tasks are less critical than others and 
> would be preferred to be killed.  But that doesn't help in a 
> cpuset-constrained oom on the same machine if it doesn't lead to future 
> memory freeing.

And that is The Main Point. Not to help some subsystem, but be useful
for others. It is different tunable. It has really nothing with cpusets.
It is not aimed to help or make things worse for the cpusets. I even do
not understand why this very specific case not used by the wast majority
of the users was even rised in the discussion of the system-wide
oom-killer bahaviour and its more precise cgroup tunable.

This is different. It has its own tunable, which is used when cpusets
are enabled. Discussed tunable should be used at its own time. Admin has
a right to decide how he wants to tune oom-killer behaviour. And the
only point I hear, is that something does not help when we have cpusets
enabled.

> Cpusets are special in this regard because the oom killer's heuristics in 
> this case are based on a function of the oom triggering task, current.  We 
> check for tasks sharing current->mems_allowed so that we are freeing 
> memory that the task can eventually use.  So this new oom cgroup cannot be 
> used on any machine with one or more cpusets that may oom without the 
> possibility of needlessly killing tasks.

Then do not use anything else when cpusets are enabled.
Do not compile SuperH cpu support when you do not have such processes.
Do not enable iscsi support if you do not need this.
Do not enable cgroup oom-killer tunable when you want cpuset.

> > Having userspace to decide which task to kill may not work in some cases
> > at all (when task is swapped and we need to kill someone to get the mem
> > to swap out the task, which will make that decision).
> > 
> 
> Yes, and it's always possible for userspace to defer back to the kernel in 
> such cases.  But in the majority of cases that you seem to be interested 
> in, this type of notification system seems like it would work quite well:
> 
>  - to replace your oom_victim patch, your userspace handler could simply
>    issue a SIGKILL to the chosen job in place of the oom killer.  The 
>    added benefit here is that your userspace handler could actually 
>    support a prioritized list so if one application isn't running, it
>    could check another, and another, etc., and
> 
>  - to replace this oom.victim patch, the userspace handler could check
>    for the presence of the aggregate of tasks that would have appeared
>    attached to the new cgroup and issue the same SIGKILL.

Besides the fact that it is possible that userspace will not even wake
up. Since to wake it up we have to swap it out, which in turn needs some
memory, which we do not have, since we are in, hmm, Out-Of-Memory
condition.

There may be cases when this will work, I do not argue. But so far the
most common case I imagine is when it will not be able to wake up :)

> > If by the 'userspace' you do not mean special kernel thread, but in
> > this case there is no difference compared to existing in-kernel code.
> 
> That wakes up any userspace notifier that you've attached to the cgroup 
> representing the tasks you're interested in controlling oom responses for.  
> Your userspace application can then effectively take the place of the oom 
> killer by expanding a cpuset's memory, elevating a memory controller 
> reservation, killing current, or using its own heuristics to respond to 
> the problem.
> 
> But we should probably discuss the implementation of the per-cgroup oom 
> notifier in the thread dedicated to it, not this one.

Please explain, how task will make that decision (like freeing some
ram), when it can not be even swapped out? It is a great idea to be able
to monitor memory usage, but relying on that just does not work.

> > At OOM time there is no userspace. We can not wakeup anyone or send (and
> > expect it will be received) some notification. The only alive entity in
> > the system is the kernel, who has to decide who must be killed based on
> > some data provided by administrator (or by default with some
> > heuristics).
> > 
> 
> This is completely and utterly wrong.  If you had read the code 
> thoroughly, you would see that the page allocation is deferred until 
> userspace has the opportunity to respond.  That time in deferral isn't 
> absurd, it would take time for the oom killer's exiting task to free 
> memory anyway.  The change simply allows a delay between a page 
> allocation failure and invoking the oom killer.
> 
> It will even work on UP systems since the page allocator has multiple 
> reschedule points where a dedicated or monitoring application attached to 
> the cgroup could add or free memory itself so the allocation succeeds when 
> current is rescheduled.

Yup, it will wait for some timeout while userspace will respond. The
problem is that it will not in some cases. And so far I think (and I may
be wrong), that it will not be able to respond most of the time.

In every oom-condition I worked with, system was completely unusable
before oom-killer started to berserk several processes. They were not
able to allocate some data to read network input (atomic context) and to
even read a console input.


What I want to say is the simple matter of the iteraction within the
kernel oom-handler. Let it be as smart or as stupid as admin decided. I
have no objection against letting it to get some knowledge from the
outsude of its own world (like wait for userspace to respond). I vote by
both hands for implementing some kind of notification mechanism which
could be used by the userspace to get oom-notifications in particular
and to watch its (or system-wide) memory usage in general.

But all those things should be additional tunables. Which do not even
remotely, even theoretically allow a lockup. So userspace notifications
are great as long as this is not the only way to have a progress in the
OOM situation. And the highest priority in this case should be kernel
and its tunables (like proposed cgroup patch), since relying on
userspace in this case may be fatal. But of course it can be enabled and
contribute.

-- 
	Evgeniy Polyakov
