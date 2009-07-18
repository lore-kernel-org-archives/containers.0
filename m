From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [patch 2/2] sched: fix nr_uninterruptible accounting of frozen
	tasks really
Date: Sat, 18 Jul 2009 14:56:31 +0200
Message-ID: <1247921791.6597.5.camel@laptop>
References: <20090717121545.489258927@linutronix.de>
	<20090717122103.225652146@linutronix.de>
	<1247833910.15751.61.camel@twins>
	<20090717152235.GA5878@count0.beaverton.ibm.com>
	<1247849254.6522.75.camel@laptop>
	<1247864134.17553.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1247864134.17553.30.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>, Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-07-17 at 15:55 -0500, Nathan Lynch wrote:
> On Fri, 2009-07-17 at 18:47 +0200, Peter Zijlstra wrote:
> > On Fri, 2009-07-17 at 08:22 -0700, Matt Helsley wrote:
> > 
> > > The job scheduler in question does not use FROZEN as a transient state and
> > > does not use checkpoint/restart at all since c/r is still a work in progress.
> 
> Right, the job scheduler uses the cgroup freezer as a mechanism to
> preempt a low priority job for a higher priority job.  (It had used
> SIGSTOP in the past.)  So in this scenario a frozen cgroup may remain in
> that state for a while.  Load average is consulted as a measure of
> system utilization.

I think that this is an utterly broken use for it, if you want something
like that make a signal cgroup or something and deliver SIGSTOP to all
of them.

In other words, why is the freezer any better than the SIGSTOP approach?

> > > Even when used for power management it seems wrong to count frozen tasks
> > > towards the loadavg since they aren't using CPU time or waiting for IO.
> > 
> > You're abusing it for _WHAT_?
> 
> I think Matt was referring to system-wide suspend/resume/hibernate, not
> a behavior of the job scheduler, if that's your concern.

I understood he referred to the crazy use-case you mentioned above, IMHO
frozen should be a temporary state used for things like
snapshot/migrate.

I'm still very tempted to plain simply revert that original patch.
