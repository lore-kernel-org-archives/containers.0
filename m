From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 14:28:11 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901221415050.10427__37084.791044663$1232663552$gmane$org@chino.kir.corp.google.com>
References: <200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
	<20090122095026.GA10579@ioremap.net>
	<alpine.DEB.2.00.0901220156310.1738@chino.kir.corp.google.com>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
	<20090122132133.GA17524@ioremap.net>
	<alpine.DEB.2.00.0901221216330.2085@chino.kir.corp.google.com>
	<20090122210613.GA10158@ioremap.net>
	<alpine.DEB.2.00.0901221314010.6145@chino.kir.corp.google.com>
	<20090122220446.GA1651@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122220446.GA1651-i6C2adt8DTjR7s880joybQ@public.gmane.org>
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

On Fri, 23 Jan 2009, Evgeniy Polyakov wrote:

> I showed the case when it does not work at all. And then found (in this
> mail), that task (part) has to be present in the memory, which means it
> will be locked, which in turns will not work with the system which
> already locked its range allowed by the limits.
> 

Yes, a userspace oom handler must be sanely implemented.

> And returning to the oom_adj and cpusets tunables. Why any new process
> started in given cpuset can not be tuned by external application or some
> script to have bigger/smaller oom_adj parameter? :)
> 

oom_adj scores are separate from the hard-coded and very fundamental 
heuristic that we should kill a task that has memory allocated on nodes we 
are attempting to free.  Anything else would just be stupid.

> > How do I prioritize oom killing if my system is running cpusets, then?  
> 
> Just the way it works right now :)
> You do not object against patches which improve superh cpu support
> with the argument, that it is not possible to enable that feature,
> when system does not have superh cpu.
> 

No, I object against any patch that isn't a complete solution to the 
problem being presented.  It's purely a matter of good software 
engineering practices and in the interest of a long-term maintainable 
kernel.

> > The userspace handler is a schedulable task resident in memory that, with 
> > any sane implementation, would not require additional memory when running.
> 
> And what happens when it can not lock the memory because of the limits?
> 

Any sane handler for responding to oom conditions will not require 
additional memory from nodes that are under oom, whether that includes all 
system memory or a subset, if it is attached to the oom notifier.

> Hmm, you likely missed the part in the last line. And in the first two,
> where I said that before oom-killer started (and killed some processes,
> usually not those which were need, but its a different story). System
> just did not have a free memory to have _any_ progress neither in atomic
> context, nor in process, so it had to invoke an oom-killer.
> 

The page allocator cannot invoke the oom killer in atomic context, so this 
would be happening in process content where it can sleep.  The userspace 
oom handler will wake up, handle the condition either by relaxing hardwall 
restrictions for either the memory controller or cpusets, or killing a 
task itself unless it chooses to defer to the kernel.

> In that case userspace just can not reply or even awake. While kernel is
> effectively alive if it does not need to allocate a memory. And could
> kill some process to free up the ram.
> 

Wrong, oom conditions do not preempt task scheduling.

> Userspace notifications are great, no problem, but do not rely on them,
> since there is a huge world outside the case it works in, which will be
> quite unhappy when systems start freezing because oom-killer relied on
> the userspace.
> 

I'm quite certain you've spent more time writing emails to me than merging 
the patch and testing its possibilities, given your lack of understanding 
of its very basic concepts.
