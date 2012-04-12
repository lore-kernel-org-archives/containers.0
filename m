From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] Merge task counter into memcg
Date: Thu, 12 Apr 2012 09:38:25 -0700
Message-ID: <20120412163825.GB13069@google.com>
References: <20120411185715.GA4317@somewhere.redhat.com>
	<4F862851.3040208@jp.fujitsu.com>
	<20120412113217.GB11455@somewhere.redhat.com>
	<4F86BFC6.2050400@parallels.com>
	<20120412123256.GI1787@cmpxchg.org>
	<4F86D4BD.1040305@parallels.com>
	<20120412153055.GL1787@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120412153055.GL1787-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Johannes.

On Thu, Apr 12, 2012 at 05:30:55PM +0200, Johannes Weiner wrote:
> > But also, I believe this has been widely discussed in person by
> > people, in separate groups. Maybe Tejun can do a small writeup of
> > where we stand?

I'm still mulling over it.  What I want is single hierarchy with more
unified rules regarding how different controllers handle the hierarchy
in such way that different controllers may interact - ie. memcg and
blkio can share the same page tags, or cgroup-freezer can provide
freezing service to other controllers.  I want if a task belongs to
cgroup, it belongs to _the_ cgroup and you can figure out all cgroup
related stuff from there.

I also want to move away from this notion that any random userland
application can modify and access the cgroupfs hierarhcies directly.
It's way too low level and cgroup doesn't have nearly enough
multiplexing capability to support such usage.  We end up where
everyone is wading through fog hoping not to step on someone else's
toe, and the interface is a bit too integrated with internal
mechanisms to be exposed directly to random userland application
without another layer of abstraction / indirection / control.

> > I would also point out that this is exactly what it is (IMHO): an
> > ongoing discussion. You are more than welcome to chime in.
> 
> I thought the conclusion was that nobody really had any sane use case
> for multiple hierarchies.  So while nobody wanted to just disable them
> in fear of breaking someones usecase, individual controllers still can
> only be active in a single hierarchy.  I don't see why the task
> controller should now as a precedence support a level of flexibility
> that is very doubtful in the first place.

The reason why I asked Frederic whether it would make more sense as
part of memcg wasn't about flexibility but mostly about the type of
the resource.  I'll continue below.

> > Agree. Even people aiming for unified hierarchies are okay with an
> > opt-in/out system, I believe. So the controllers need not to be
> > active at all times. One way of doing this is what I suggested to
> > Frederic: If you don't limit, don't account.
> 
> I don't agree, it's a valid usecase to monitor a workload without
> limiting it in any way.  I do it all the time.

AFAICS, this seems to be the most valid use case for different
controllers seeing different part of the hierarchy, even if the
hierarchies aren't completely separate.  Accounting and control being
in separate controllers is pretty sucky too as it ends up accounting
things multiple times.  Maybe all controllers should learn how to do
accounting w/o applying limits?  Not sure yet.

> To reraise a point from my other email that was ignored: do users
> actually really care about the number of tasks when they want to
> prevent forkbombs?  If a task would use neither CPU nor memory, you
> would not be interested in limiting the number of tasks.
> 
> Because the number of tasks is not a resource.  CPU and memory are.
>
> So again, if we would include the memory impact of tasks properly
> (structures, kernel stack pages) in the kernel memory counters which
> we allow to limit, shouldn't this solve our problem?

The task counter is trying to control the *number* of tasks, which is
purely memory overhead.  Translating #tasks into the actual amount of
memory isn't too trivial tho - the task stack isn't the only
allocation and the numbers should somehow make sense to the userland
in consistent way.  Also, I'm not sure whether this particular limit
should live in its silo or should be summed up together as part of
kmem (kmem itself is in its own silo after all apart from user memory,
right?).  So, if those can be settled, I think protecting against fork
bombs could fit memcg better in the sense that the whole thing makes
more sense.

Thanks.

-- 
tejun
