From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Thu, 22 Jan 2009 02:27:19 -0800 (PST)
Message-ID: <alpine.DEB.2.00.0901220218120.2851@chino.kir.corp.google.com>
References: <200901211638.23101.knikanth@suse.de>
	<200901212054.34929.knikanth@suse.de>
	<alpine.DEB.2.00.0901211241040.21080@chino.kir.corp.google.com>
	<200901221042.30957.knikanth@suse.de>
	<alpine.DEB.2.00.0901220036440.28850@chino.kir.corp.google.com>
	<20090122095026.GA10579@ioremap.net>
	<alpine.DEB.2.00.0901220156310.1738@chino.kir.corp.google.com>
	<20090122101424.GA12317@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090122101424.GA12317-i6C2adt8DTjR7s880joybQ@public.gmane.org>
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

> > In an exclusive cpuset, a task's memory is restricted to a set of mems 
> > that the administrator has designated.  If it is oom, the kernel must free 
> > memory on those nodes or the next allocation will again trigger an oom 
> > (leading to a needlessly killed task that was in a disjoint cpuset).
> > 
> > Really.
> 
> The whole point of oom-killer is to kill the most appropriate task to
> free the memory. And while task is selected system-wide and some
> tunables are added to tweak the behaviour local to some subsystems, this
> cpuset feature is hardcoded into the selection algorithm.

Of course, because the oom killer must be aware that tasks in disjoint 
cpusets are more likely than not to result in no memory freeing for 
current's subsequent allocations.

> And when some tunable starts doing own calculation, behaviour of this
> hardcoded feature changes.
> 

Yes, it is possible to elevate oom_adj scores to override the cpuset 
preference.  That's actually intended since it is now possible for the 
administrator to specify that, against the belief of the kernel, that 
killing a task will free memory in these cpuset-constrained ooms.  That's 
probably because it has either been moved to a different cpuset or its set 
of allowable nodes is dynamic.

> > Then the scope of this new cgroup is restricted to not being used with 
> > cpusets that could oom.
> 
> These are perpendicular tasks - cpusets limit one area of the oom
> handling, cgroup order - another. Some people needs cpusets, others want
> cgroups. cpusets are not something exceptional so that only they have to
> be taken into account when doing system-wide operation like OOM
> condition handling.
> 

A cpuset is a cgroup.  If I am using cpusets, this patch fails to 
adequately allow me to describe my oom preferences for both 
cpuset-constrained ooms and global unconstrained ooms, which is a major 
drawback.

I would encourage you to look at the per-cgroup oom notifier patch[*] that 
defers most of these decisions to userspace.  Given your interest in 
priority based oom preferences as exhibited by your oom_victim patch, I 
think you'll find it of interest since it allows you much greater 
flexibility than you could ever hope for from the kernel's heuristics.

 [*] http://marc.info/?l=linux-mm&m=122575082227252
