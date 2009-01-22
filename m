From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 16:21:33 +0300
Message-ID: <20090122132133.GA17524__14927.4424104535$1232630731$gmane$org@ioremap.net>
References: <200901211638.23101.knikanth@suse.de>
	<200901212054.34929.knikanth@suse.de>
	<alpine.DEB.2.00.0901211241040.21080@chino.kir.corp.google.com>
	<200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
	<20090122095026.GA10579@ioremap.net>
	<alpine.DEB.2.00.0901220156310.1738@chino.kir.corp.google.com>
	<20090122101424.GA12317@ioremap.net>
	<alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0901220218120.2851-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

On Thu, Jan 22, 2009 at 02:27:19AM -0800, David Rientjes (rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) wrote:
> > The whole point of oom-killer is to kill the most appropriate task to
> > free the memory. And while task is selected system-wide and some
> > tunables are added to tweak the behaviour local to some subsystems, this
> > cpuset feature is hardcoded into the selection algorithm.
> 
> Of course, because the oom killer must be aware that tasks in disjoint 
> cpusets are more likely than not to result in no memory freeing for 
> current's subsequent allocations.

And if we replace cpuset with cgroup (or anything else), nothing
changes, so why this was made so special?

> > And when some tunable starts doing own calculation, behaviour of this
> > hardcoded feature changes.
> > 
> 
> Yes, it is possible to elevate oom_adj scores to override the cpuset 
> preference.  That's actually intended since it is now possible for the 
> administrator to specify that, against the belief of the kernel, that 
> killing a task will free memory in these cpuset-constrained ooms.  That's 
> probably because it has either been moved to a different cpuset or its set 
> of allowable nodes is dynamic.

Yes, admin has to be aware of some obscure inner kernel policy which he
may not be using to be able to tune system-wide behaviour... Right now
it is not even documented :)

> > These are perpendicular tasks - cpusets limit one area of the oom
> > handling, cgroup order - another. Some people needs cpusets, others want
> > cgroups. cpusets are not something exceptional so that only they have to
> > be taken into account when doing system-wide operation like OOM
> > condition handling.
> 
> A cpuset is a cgroup.  If I am using cpusets, this patch fails to 
> adequately allow me to describe my oom preferences for both 
> cpuset-constrained ooms and global unconstrained ooms, which is a major 
> drawback.
> 
> I would encourage you to look at the per-cgroup oom notifier patch[*] that 
> defers most of these decisions to userspace.  Given your interest in 
> priority based oom preferences as exhibited by your oom_victim patch, I 
> think you'll find it of interest since it allows you much greater 
> flexibility than you could ever hope for from the kernel's heuristics.
> 
>  [*] http://marc.info/?l=linux-mm&m=122575082227252

Having userspace to decide which task to kill may not work in some cases
at all (when task is swapped and we need to kill someone to get the mem
to swap out the task, which will make that decision).

+			/* If we're planning to retry, we should wake
+			 * up any userspace waiter in order to let it
+			 * handle the OOM
+			 */
+			wake_up_all(&cs->oom_wait);

You must be kidding :)
If by the 'userspace' you do not mean special kernel thread, but in
this case there is no difference compared to existing in-kernel code.

At OOM time there is no userspace. We can not wakeup anyone or send (and
expect it will be received) some notification. The only alive entity in
the system is the kernel, who has to decide who must be killed based on
some data provided by administrator (or by default with some
heuristics).

-- 
	Evgeniy Polyakov
