From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [patch 2/2] sched: fix nr_uninterruptible accounting of frozen
	tasks really
Date: Fri, 17 Jul 2009 14:48:43 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0907171441020.11571__1652.36946563727$1247835070$gmane$org@localhost.localdomain>
References: <20090717121545.489258927@linutronix.de>
	<20090717122103.225652146@linutronix.de>
	<1247833910.15751.61.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>, Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 17 Jul 2009, Peter Zijlstra wrote:

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

Fine with me, but it seems that the cgroup folks have some luser space
stuff looking at proc/loadavg which goes berserk when loadavg
increases rapidly due to freezing. OTOH that stuff seems to be
oblivious to the fact that the commit in question brings loadavg
irreversibly to 0 when you do enough freeze/thaw cycles.

So either we revert or apply the fix, which keeps the accounting
straight and solves the freezer loadavg thing. No strong opinion on
that.

Thanks,

	tglx
