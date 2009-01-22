From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 13:35:13 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901221314010.6145@chino.kir.corp.google.com>
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
	<20090122210613.GA10158@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122210613.GA10158-i6C2adt8DTjR7s880joybQ@public.gmane.org>
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

> Only the fact that cpusets have _very_ special meaning in the oom-killer
> codepath, while it should be just another tunable (if it should be
> special code at all at the first place, why there were no objection and
> argument, that tasks could have different oom_adj?).
> 

That's because the oom killer needs to kill a task that will allow future 
memory freeing on current->mems_allowed in these cases.  Appropriate 
oom_adj scores can override that preference, it's up to the administrator.

> > The oom.victim priority may well be valid for a system-wide condition 
> > where a specific aggregate of tasks are less critical than others and 
> > would be preferred to be killed.  But that doesn't help in a 
> > cpuset-constrained oom on the same machine if it doesn't lead to future 
> > memory freeing.
> 
> And that is The Main Point. Not to help some subsystem, but be useful
> for others. It is different tunable. It has really nothing with cpusets.

It doesn't work with any system that is running with cpusets, that's the 
problem with accepting such code.  There needs to be clear and convincing 
evidence that a userspace oom notifier, which could handle all possible 
cases and is much more robust and flexible, would not suffice for such 
situations.

> Then do not use anything else when cpusets are enabled.
> Do not compile SuperH cpu support when you do not have such processes.
> Do not enable iscsi support if you do not need this.
> Do not enable cgroup oom-killer tunable when you want cpuset.
> 

How do I prioritize oom killing if my system is running cpusets, then?  
Your answer is that I can't, since this new cgroup doesn't work with them; 
so this solution is incomplete.  The oom killer notification patch[*] is 
much more functional and does allow this problem to be solved on all types 
of systems because the implementation of such a handler is left to the 
administrator.

 [*] http://marc.info/?l=linux-mm&m=122575082227252

> Please explain, how task will make that decision (like freeing some
> ram), when it can not be even swapped out? It is a great idea to be able
> to monitor memory usage, but relying on that just does not work.
> 

The userspace handler is a schedulable task resident in memory that, with 
any sane implementation, would not require additional memory when running.

> > This is completely and utterly wrong.  If you had read the code 
> > thoroughly, you would see that the page allocation is deferred until 
> > userspace has the opportunity to respond.  That time in deferral isn't 
> > absurd, it would take time for the oom killer's exiting task to free 
> > memory anyway.  The change simply allows a delay between a page 
> > allocation failure and invoking the oom killer.
> > 
> > It will even work on UP systems since the page allocator has multiple 
> > reschedule points where a dedicated or monitoring application attached to 
> > the cgroup could add or free memory itself so the allocation succeeds when 
> > current is rescheduled.
> 
> Yup, it will wait for some timeout while userspace will respond. The
> problem is that it will not in some cases. And so far I think (and I may
> be wrong), that it will not be able to respond most of the time.
> 

We've used it quite successfully for over a year, so your hypothesis in 
this case may be less than accurate.

> In every oom-condition I worked with, system was completely unusable
> before oom-killer started to berserk several processes. They were not
> able to allocate some data to read network input (atomic context) and to
> even read a console input.
> 

If your system failed to allocate GFP_ATOMIC memory, then those are page 
allocation failures in the buddy allocator and will actually never invoke 
the oom killer since it cannot sleep in that context.
