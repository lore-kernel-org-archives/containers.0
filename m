From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Tue, 11 Nov 2008 17:30:24 -0500
Message-ID: <20081111223024.GA31527__8247.60094187713$1226442944$gmane$org@redhat.com>
References: <20081106160154.GA7461@redhat.com>
	<1225988173.7803.4723.camel@twins>
	<20081106163957.GB7461@redhat.com>
	<1225990327.7803.4776.camel@twins>
	<20081106170830.GD7461@redhat.com>
	<e98e18940811061507t3e19183byf2b8b291458ba81b@mail.gmail.com>
	<20081107141943.GC21884@redhat.com>
	<e98e18940811071336n58a073d8w2cbaeddd5657d1e9@mail.gmail.com>
	<20081110141143.GC26956@redhat.com>
	<e98e18940811111155q4bd73480pebe088fa1adbe2e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940811111155q4bd73480pebe088fa1adbe2e4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Nov 11, 2008 at 11:55:53AM -0800, Nauman Rafique wrote:
> On Mon, Nov 10, 2008 at 6:11 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Fri, Nov 07, 2008 at 01:36:20PM -0800, Nauman Rafique wrote:
> >> On Fri, Nov 7, 2008 at 6:19 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> > On Thu, Nov 06, 2008 at 03:07:57PM -0800, Nauman Rafique wrote:
> >> >> It seems that approaches with two level scheduling (DM-IOBand or this
> >> >> patch set on top and another scheduler at elevator) will have the
> >> >> possibility of undesirable interactions (see "issues" listed at the
> >> >> end of the second patch). For example, a request submitted as RT might
> >> >> get delayed at higher layers, even if cfq at elevator level is doing
> >> >> the right thing.
> >> >>
> >> >
> >> > Yep. Buffering of bios at higher layer can break underlying elevator's
> >> > assumptions.
> >> >
> >> > What if we start keeping track of task priorities and RT tasks in higher
> >> > level schedulers and dispatch the bios accordingly. Will it break the
> >> > underlying noop, deadline or AS?
> >>
> >> It will probably not. But then we have a cfq-like scheduler at higher
> >> level and we can agree that the combinations "cfq(higher
> >> level)-noop(lower level)", "cfq-deadline", "cfq-as" and "cfq-cfq"
> >> would probably work.  But if we implement one high level cfq-like
> >> scheduler at a higher level, we would not take care of somebody who
> >> wants noop-noop or propotional-noop. The point I am trying to make is
> >> that there is probably no single one-size-fits-all solution for a
> >> higher level scheduler. And we should limit the arbitrary mixing and
> >> matching of higher level schedulers and elevator schedulers. That
> >> being said, the existence of a higher level scheduler is still a point
> >> of debate I guess, see my comments below.
> >>
> >
> > Ya, implemeting CFQ like thing in higher level scheduler will make things
> > complex.
> >
> >>
> >> >
> >> >> Moreover, if the requests in the higher level scheduler are dispatched
> >> >> as soon as they come, there would be no queuing at the higher layers,
> >> >> unless the request queue at the lower level fills up and causes a
> >> >> backlog. And in the absence of queuing, any work-conserving scheduler
> >> >> would behave as a no-op scheduler.
> >> >>
> >> >> These issues motivate to take a second look into two level scheduling.
> >> >> The main motivations for two level scheduling seem to be:
> >> >> (1) Support bandwidth division across multiple devices for RAID and LVMs.
> >> >
> >> > Nauman, can you give an example where we really need bandwidth division
> >> > for higher level devices.
> >> >
> >> > I am beginning to think that real contention is at leaf level physical
> >> > devices and not at higher level logical devices hence we should be doing
> >> > any resource management only at leaf level and not worry about higher
> >> > level logical devices.
> >> >
> >> > If this requirement goes away, then case of two level scheduler weakens
> >> > and one needs to think about doing changes at leaf level IO schedulers.
> >>
> >> I cannot agree with you more on this that there is only contention at
> >> the leaf level physical devices and bandwidth should be managed only
> >> there. But having seen earlier posts on this list, i feel some folks
> >> might not agree with us. For example, if we have RAID-0 striping, we
> >> might want to schedule requests based on accumulative bandwidth used
> >> over all devices. Again, I myself don't agree with moving scheduling
> >> at a higher level just to support that.
> >>
> >
> > Hmm.., I am not very convinced that we need to do resource management
> > at RAID0 device. The common case of resource management is that a higher
> > priority task group is not deprived of resources because of lower priority
> > task group. So if there is no contention between two task groups (At leaf
> > node), then I might as well let them give them full access to RAID 0
> > logical device without any control.
> >
> > Hope people who have requirement of control at higher level devices can
> > pitch in now and share their perspective.
> >
> >> >
> >> >> (2) Divide bandwidth between different cgroups without modifying each
> >> >> of the existing schedulers (and without replicating the code).
> >> >>
> >> >> One possible approach to handle (1) is to keep track of bandwidth
> >> >> utilized by each cgroup in a per cgroup data structure (instead of a
> >> >> per cgroup per device data structure) and use that information to make
> >> >> scheduling decisions within the elevator level schedulers. Such  a
> >> >> patch can be made flag-disabled if co-ordination across different
> >> >> device schedulers is not required.
> >> >>
> >> >
> >> > Can you give more details about it. I am not sure I understand it. Exactly
> >> > what information should be stored in each cgroup.
> >> >
> >> > I think per cgroup per device data structures are good so that an scheduer
> >> > will not worry about other devices present in the system and will just try
> >> > to arbitrate between various cgroup contending for that device. This goes
> >> > back to same issue of getting rid of requirement (1) from io controller.
> >>
> >> I was thinking that we can keep track of disk time used at each
> >> device, and keep the cumulative number in a per cgroup data structure.
> >> But that is only if we want to support bandwidth division across
> >> devices. You and me both agree that we probably do not need to do
> >> that.
> >>
> >> >
> >> >> And (2) can probably be handled by having one scheduler support
> >> >> different modes. For example, one possible mode is "propotional
> >> >> division between crgroups + no-op between threads of a cgroup" or "cfq
> >> >> between cgroups + cfq between threads of a cgroup". That would also
> >> >> help avoid combinations which might not work e.g RT request issue
> >> >> mentioned earlier in this email. And this unified scheduler can re-use
> >> >> code from all the existing patches.
> >> >>
> >> >
> >> > IIUC, you are suggesting some kind of unification between four IO
> >> > schedulers so that proportional weight code is not replicated and user can
> >> > switch mode on the fly based on tunables?
> >>
> >> Yes, that seems to be a solution to avoid replication of code. But we
> >> should also look at any other solutions that avoid replication of
> >> code, and also avoid scheduling in two different layers.
> >> In my opinion, scheduling at two different layers is problematic because
> >> (a) Any buffering done at a higher level will be artificial, unless
> >> the queues at lower levels are completely full. And if there is no
> >> buffering at a higher level, any scheduling scheme would be
> >> ineffective.
> >> (b) We cannot have an arbitrary mixing and matching of higher and
> >> lower level schedulers.
> >>
> >> (a) would exist in any solution in which requests are queued at
> >> multiple levels. Can you please comment on this with respect to the
> >> patch that you have posted?
> >>
> >
> > I am not very sure about the queustion, but in my patch, buffering at
> > at higher layer is irrespective of the status of underlying queue. We
> > try our best to fill underlying queue with request, only subject to the
> > criteria of proportional bandwidth.
> >
> > So, if there are two cgroups A and B and we allocate two cgroups 2000
> > tokens each to begin with. If A has consumed all the tokens soon and B
> > has not, then we will stop A from dispatching more requests and wait for
> > B to either issue more IO and consume tokens or get out of contention.
> > This can leave disk idle for sometime. We can probably do some
> > optimizations here.
> 
> What do you think about elevator based solutions like 2 level cfq
> patches submitted by Satoshi and Vasily earlier?

I have had a very high level look at Satoshi's patch. I will go into 
details soon. I was thinking that this patch solves the problem only
for CFQ. Can we create a common layer which can be shared by all
the four IO schedulers.

So this one common layer can take care of all the management w.r.t
per device per cgroup data structures and track all the groups, their
limits (either token based or time based scheme), and control the
dispatch of requests.

This way we can enable IO controller not only for CFQ but for all the
IO schedulers without duplicating too much of code.

This is what I am playing around with currently. At this point I am
not sure, how much of common ground I can have between all the IO
schedulers.

> CFQ can be trivially
> modified to do proportional division (i.e give time slices in
> proportion to weight instead of priority).
> And such a solution would
> avoid idleness problem like the one you mentioned above.

Can you just elaborate a little on how do you get around idleness problem?
If you don't create idleness than if two tasks in two cgroups are doing
sequential IO, they might simply get into lockstep and we will not achieve
any differentiated service proportionate to their weight.  

>  and can also
> avoid burstiness issues (see smoothing patches -- v1.2.0 and v1.3.0 --
> of dm-ioband) in token based schemes.
> 
> Also doing time based token allocation (as you mentioned in TODO list)
> sounds very interesting. Can we look at the disk time taken by each
> bio and use that to account for tokens? The problem is that the time
> taken is not available when the requests are sent to disk, but we can
> do delayed token charging (i.e deduct tokens after the request is
> completed?). It seems that such an approach should work. What do you
> think?

This is a good idea. Charging the cgroup based on time actually consumed
should be doable. I will look into it. I think in the past somebody
mentioned that how do you account for the seek time taken because of 
switchover between cgroups? May be average time per cgroup can help here
a bit.

This is more about refining the dispatch algorightm once we have agreed
upon other semantics like 2 level scheduler and can we come up with a common
layer which can be shared by all four IO schedulers. Once common layer is
possible, we can always change the common layer algorithm from token based
to time based to achive better accuracy.

Thanks
Vivek
