From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 2/2] sched: fix nr_uninterruptible accounting of frozen
	tasks really
Date: Fri, 17 Jul 2009 08:22:35 -0700
Message-ID: <20090717152235.GA5878__7866.51468738473$1247847441$gmane$org@count0.beaverton.ibm.com>
References: <20090717121545.489258927@linutronix.de>
	<20090717122103.225652146@linutronix.de>
	<1247833910.15751.61.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1247833910.15751.61.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>, Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 17, 2009 at 02:31:50PM +0200, Peter Zijlstra wrote:
> On Fri, 2009-07-17 at 12:25 +0000, Thomas Gleixner wrote:
> > plain text document attachment (freezer-fix-accounting-for-real.patch)
> > commit e3c8ca8336 (sched: do not count frozen tasks toward load) broke
> > the nr_uninterruptible accounting on freeze/thaw. On freeze the task
> > is excluded from accounting with a check for (task->flags &
> > PF_FROZEN), but that flag is cleared before the task is thawed. So
> > while we prevent that the freezing task with state
> > TASK_UNINTERRUPTIBLE is accounted to nr_uninterruptible we decrement
> > nr_uninterruptible on thaw.
> > 
> > Use a separate flag which is handled by the freezing task itself. Set
> > it before calling the scheduler with TASK_UNINTERRUPTIBLE state and
> > clear it after we return from frozen state.
> 
> Right, so I'm wondering why we don't fully revert e3c8ca8336 to begin
> with.
> 
> The changelog reads:
> 
> ---
> commit e3c8ca8336707062f3f7cb1cd7e6b3c753baccdd
> Author: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> Date:   Wed Apr 8 19:45:12 2009 -0500
> 
>     sched: do not count frozen tasks toward load
> 
>     Freezing tasks via the cgroup freezer causes the load average to climb
>     because the freezer's current implementation puts frozen tasks in
>     uninterruptible sleep (D state).
> 
>     Some applications which perform job-scheduling functions consult the
>     load average when making decisions.  If a cgroup is frozen, the load
>     average does not provide a useful measure of the system's utilization
>     to such applications.  This is especially inconvenient if the job
>     scheduler employs the cgroup freezer as a mechanism for preempting low
>     priority jobs.  Contrast this with using SIGSTOP for the same purpose:
>     the stopped tasks do not count toward system load.
> 
>     Change task_contributes_to_load() to return false if the task is
>     frozen.  This results in /proc/loadavg behavior that better meets
>     users' expectations.
> ---
> 
> It appears to me that a frozen cgroup is a transient state. Either you
> would typically do something like:
> 
>   freeze -> {snapshot, migrate} -> {thaw, destroy}
> 
> Therefore a short increase in load doesn't seem like too big a problem,
> its going to be gone soon anyway.
> 
> Hmm?

The job scheduler in question does not use FROZEN as a transient state and
does not use checkpoint/restart at all since c/r is still a work in progress.
Even when used for power management it seems wrong to count frozen tasks
towards the loadavg since they aren't using CPU time or waiting for IO.

Cheers,
	-Matt Helsley
