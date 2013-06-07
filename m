From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Fri, 7 Jun 2013 13:23:49 -0700
Message-ID: <20130607202349.GC14781__10959.4079702676$1370636654$gmane$org@mtj.dyndns.org>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
	<20130606211410.GF5045@htj.dyndns.org>
	<20130607101220.GE10742@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130607101220.GE10742-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Fri, Jun 07, 2013 at 11:12:20AM +0100, Daniel P. Berrange wrote:
> Well we pretty much needs the tunables available in the cpu, cpuset
> and cpuacct controllers to be available for the set of non-vCPU threads
> as a group. eg, cpu_shares, cfs_period_us, cfs_quota_us, cpuacct.usage,
> cpuacct.usage_percpu, cpuset.cpus, cpuset.mems.
> 
> CPU/memory affinity could possibly be done with a combination of
> sched_setaffinity + libnuma, but I'm not sure that it has quite
> the same semantics. IIUC, with cpuset cgroup changing affinity
> will cause the kernel to migrate existing memory allocations to
> the newly specified node masks, but this isn't done if you just
> use sched_setaffinity/libnuma.

The features are overlapping mostly.  The exact details might differ
but is that really an overriding concern?  With autonuma, the kernel
will do migration automatically anyway and it's more likely to show
better overall behavior anyway performing migration gradually.  One of
the problems with some of cgroup's features is that they're clutch or
hackery to achieve pretty specific goals and I want to at least
discourage such usages.  If something can be done with the usual
programming API, it's better to stick with them.  They tend to be much
better thought-through, engineered and given a lot more attention.

> For cpu accounting, you'd have to look at the overall cgroup usage
> and then subtract the usage accounted to each vcpu thread to get
> the non-vCPU thread group total. Possible but slightly tedious &
> more inaccurate since you will have timing delays getting info
> from each thread's /proc files

But you would want to keep track of how much cpu time each vcpu
consumes anyway, right?  That's a logical thing to do.

> I don't see any way to do cpu_sahres, cfs_period_us and cfs_quota_us
> for the group of non-vCPU threads as a whole. You can't set these
> at the per-thread level since that is semantically very different.
> You can't set these for the process as a whole at the cgroup level,
> since that'll confine vCPU threads at the same time which is also
> semantically very different.

The above doesn't really explain why you need them.  It just describes
what you're doing right now and how that doesn't map exactly to the
usual interface.  What effect are you achieving with tuning those
scheduler params which BTW is much more deeply connected to scheduler
internals and thus a lot more volatile?  Exploiting such features is
dangerous for both userland and kernel - userland is much more likely
to get affected by kernel implementation changes and in turn kernel is
locked into interface which it never intended to make available widely
and gets restricted in what it can do to improve the implementation.
While quite unlikely, people regularly talk about alternative
scheduler implementations and things like above mean that any such
alternative implementations would have to emulate, of course
imperfectly, those knobs which may have no meaning whatsoever to the
new scheduler.

I'm sure you had good reasons adding those but the fact that you're
depending on them at all instead of the usual scheduler API is not a
good thing and if at all possible should be removed.  This is about
the same theme that I talked above.  It looks like a good feature on
the surface but is also something which is deterimental in the long
term.  We want to closely limit accesses to such implementation
details as much as possible.

So, can you please explain what benefits you're getting out of by
tuning those scheduler specific knobs which can't be obtained via
normal scheduler API and how much difference that actually makes?
Because if it's something legitimately necessary, it should really be
accessible in generic manner so that lay programs can make use of them
too.

Thanks.

-- 
tejun
