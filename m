From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 16417] New: Slow context switches with SMP
	and CONFIG_FAIR_GROUP_SCHED
Date: Mon, 02 Aug 2010 10:58:41 +0200
Message-ID: <1280739521.1923.18.camel@laptop>
References: <bug-16417-10286@https.bugzilla.kernel.org/>
	<20100722155222.f0fdc50a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100722155222.f0fdc50a.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: pbourdon-SxHCd5+OuqTrt3ojHgZu+w@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2010-07-22 at 15:52 -0700, Andrew Morton wrote:

> > We have been experiencing slow context switches using a large number of cgroups
> > (around 600 groups) and CONFIG_FAIR_GROUP_SCHED. This causes a system time
> > usage increase on context switching heavy processes (measured with pidstat -w)
> > and a drop in timer interrupts handling.
> > 
> > This problem only appears on SMP : when booting with nosmp, the issue does not
> > appear. From maxprocs=2 to maxprocs=8 we were able to reproduce it accurately.
> > 
> > Steps to reproduce :
> > - mount the cgroup filesystem in /dev/cgroup
> > - cd /dev/cgroup && for i in $(seq 1 5000); do mkdir test_group_$i; done
> > - launch lat_ctx from lmbench, for instance ./lat_ctx -N 200 100
> > 
> > The results from lat_ctx were the following :
> > - SMP enabled, no cgroups : 2.65
> > - SMP enabled, 1000 cgroups : 3.40
> > - SMP enabled, 6000 cgroups : 3957.36
> > - SMP disabled, 6000 cgroups : 1.58
> > 
> > We can see that from a certain amount of cgroups, the context switching starts
> > taking a lot of time. Another way to reproduce this problem :
> > - launch cat /dev/zero | pv -L 1G > /dev/null
> > - look at the CPU usage (about 40% here)
> > - cd /dev/cgroup && for i in $(seq 1 5000); do mkdir test_group_$i; done
> > - look at the CPU usage (about 80% here)
> > 

Does: echo NO_LB_SHARES_UPDATE > /debug/sched_features
(or wherever you mounted debugfs) help things?

It will make the thing less fair but should cut out a lot of overhead in
the wakeup path. The wakeup redistribution is throttled somewhat, but if
you're looking for the worst latency you'll see the spikes for sure.

The problem is that the whole group fairness mess involves equations
covering all groups and all cpus. Its a frigging nightmare I wish
someone would take away from me.

I've tried several times to come up with some statistical approach, but
every time I try that I end up with unstable stuff that has feed-forward
loops that cause unfairness to blow out in stead of dampen it.

> > Also note that when a lot of cgroups are present, the system is spending a lot
> > of time in softirqs, and there are less timer interrupts handled than normally
> > (according to our graphs).

Right, so load-balancing is O(n) in the number of tasks and groups, it
does try to break out once it moved enough, but if you have tons of
empty groups..

I guess the alternative would be to keep a per-cpu list of non-empty
groups, except that that would add more overhead to wakeup/sleep and
would need stronger serialization than the current RCU bits.
