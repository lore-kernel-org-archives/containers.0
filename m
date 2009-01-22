From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 12:28:45 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901221216330.2085__12348.554042592$1232656424$gmane$org@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901212054.34929.knikanth@suse.de>
	<alpine.DEB.2.00.0901211241040.21080@chino.kir.corp.google.com>
	<200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
	<20090122095026.GA10579@ioremap.net>
	<alpine.DEB.2.00.0901220156310.1738@chino.kir.corp.google.com>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
	<20090122132133.GA17524@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122132133.GA17524-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 22 Jan 2009, Evgeniy Polyakov wrote:

> > Of course, because the oom killer must be aware that tasks in disjoint 
> > cpusets are more likely than not to result in no memory freeing for 
> > current's subsequent allocations.
> 
> And if we replace cpuset with cgroup (or anything else), nothing
> changes, so why this was made so special?
> 

I don't know what you're talking about, cpusets are simply a client of the 
cgroup interface.

The problem that I'm identifying with this change is that the 
user-specified priority (in terms of oom.victim settings) conflicts when 
the kernel encounters a system-wide unconstrained oom versus a 
cpuset-constrained oom.

The oom.victim priority may well be valid for a system-wide condition 
where a specific aggregate of tasks are less critical than others and 
would be preferred to be killed.  But that doesn't help in a 
cpuset-constrained oom on the same machine if it doesn't lead to future 
memory freeing.

Cpusets are special in this regard because the oom killer's heuristics in 
this case are based on a function of the oom triggering task, current.  We 
check for tasks sharing current->mems_allowed so that we are freeing 
memory that the task can eventually use.  So this new oom cgroup cannot be 
used on any machine with one or more cpusets that may oom without the 
possibility of needlessly killing tasks.

> Having userspace to decide which task to kill may not work in some cases
> at all (when task is swapped and we need to kill someone to get the mem
> to swap out the task, which will make that decision).
> 

Yes, and it's always possible for userspace to defer back to the kernel in 
such cases.  But in the majority of cases that you seem to be interested 
in, this type of notification system seems like it would work quite well:

 - to replace your oom_victim patch, your userspace handler could simply
   issue a SIGKILL to the chosen job in place of the oom killer.  The 
   added benefit here is that your userspace handler could actually 
   support a prioritized list so if one application isn't running, it
   could check another, and another, etc., and

 - to replace this oom.victim patch, the userspace handler could check
   for the presence of the aggregate of tasks that would have appeared
   attached to the new cgroup and issue the same SIGKILL.

> +			/* If we're planning to retry, we should wake
> +			 * up any userspace waiter in order to let it
> +			 * handle the OOM
> +			 */
> +			wake_up_all(&cs->oom_wait);
> 
> You must be kidding :)
> If by the 'userspace' you do not mean special kernel thread, but in
> this case there is no difference compared to existing in-kernel code.
> 

That wakes up any userspace notifier that you've attached to the cgroup 
representing the tasks you're interested in controlling oom responses for.  
Your userspace application can then effectively take the place of the oom 
killer by expanding a cpuset's memory, elevating a memory controller 
reservation, killing current, or using its own heuristics to respond to 
the problem.

But we should probably discuss the implementation of the per-cgroup oom 
notifier in the thread dedicated to it, not this one.

> At OOM time there is no userspace. We can not wakeup anyone or send (and
> expect it will be received) some notification. The only alive entity in
> the system is the kernel, who has to decide who must be killed based on
> some data provided by administrator (or by default with some
> heuristics).
> 

This is completely and utterly wrong.  If you had read the code 
thoroughly, you would see that the page allocation is deferred until 
userspace has the opportunity to respond.  That time in deferral isn't 
absurd, it would take time for the oom killer's exiting task to free 
memory anyway.  The change simply allows a delay between a page 
allocation failure and invoking the oom killer.

It will even work on UP systems since the page allocator has multiple 
reschedule points where a dedicated or monitoring application attached to 
the cgroup could add or free memory itself so the allocation succeeds when 
current is rescheduled.
