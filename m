From: Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 19 Nov 2008 16:12:30 -0800
Message-ID: <af41c7c40811191612v5db13ae7n3cfe537beb6a157c__26583.3174613819$1227140101$gmane$org@mail.gmail.com>
References: <20081114160525.GE24624@redhat.com>
	<20081117142309.GA15564@redhat.com> <4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<e98e18940811181507t6b1473act2efa23df21dab270@mail.gmail.com>
	<20081119142446.GH26308@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081119142446.GH26308-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 19, 2008 at 6:24 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Nov 18 2008, Nauman Rafique wrote:
>> On Tue, Nov 18, 2008 at 11:12 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>> > On Tue, Nov 18 2008, Fabio Checconi wrote:
>> >> > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> >> > Date: Tue, Nov 18, 2008 09:07:51AM -0500
>> >> >
>> >> > On Tue, Nov 18, 2008 at 01:05:08PM +0100, Fabio Checconi wrote:
>> >> ...
>> >> > > I have to think a little bit on how it would be possible to support
>> >> > > an option for time-only budgets, coexisting with the current behavior,
>> >> > > but I think it can be done.
>> >> > >
>> >> >
>> >> > IIUC, bfq and cfq are different in following manner.
>> >> >
>> >> > a. BFQ employs WF2Q+ for fairness and CFQ employes weighted round robin.
>> >> > b. BFQ uses the budget (sector count) as notion of service and CFQ uses
>> >> >    time slices.
>> >> > c. BFQ supports hierarchical fair queuing and CFQ does not.
>> >> >
>> >> > We are looking forward for implementation of point C. Fabio seems to
>> >> > thinking of supporting time slice as a service (B). It seems like
>> >> > convergence of CFQ and BFQ except the point A (WF2Q+ vs weighted round
>> >> > robin).
>> >> >
>> >> > It looks like WF2Q+ provides tighter service bound and bfq guys mention
>> >> > that they have been able to ensure throughput while ensuring tighter
>> >> > bounds. If that's the case, does that mean BFQ is a replacement for CFQ
>> >> > down the line?
>> >> >
>> >>
>> >> BFQ started from CFQ, extending it in the way you correctly describe,
>> >> so it is indeed very similar.  There are also some minor changes to
>> >> locking, cic handling, hw_tag detection and to the CIC_SEEKY heuristic.
>> >>
>> >> The two schedulers share similar goals, and in my opinion BFQ can be
>> >> considered, in the long term, a CFQ replacement; *but* before talking
>> >> about replacing CFQ we have to consider that:
>> >>
>> >>   - it *needs* review and testing; we've done our best, but for sure
>> >>     it's not enough; review and testing are never enough;
>> >>   - the service domain fairness, which was one of our objectives, requires
>> >>     some extra complexity; the mechanisms we used and the design choices
>> >>     we've made may not fit all the needs, or may not be as generic as the
>> >>     simpler CFQ's ones;
>> >>   - CFQ has years of history behind and has been tuned for a wider
>> >>     variety of environments than the ones we've been able to test.
>> >>
>> >> If time-based fairness is considered more robust and the loss of
>> >> service-domain fairness is not a problem, then the two schedulers can
>> >> be made even more similar.
>> >
>> > My preferred approach here would be, in order or TODO:
>> >
>> > - Create and test the smallish patches for seekiness, hw_tag checking,
>> >  and so on for CFQ.
>> > - Create and test a WF2Q+ service dispatching patch for CFQ.
>> >
>> > and if there are leftovers after that, we could even conditionally
>> > enable some of those if appropriate. I think the WF2Q+ is quite cool and
>> > could be easily usable as the default, so it's definitely a viable
>> > alternative.
>>
>> 1 Merge BFQ into CFQ (Jens and Fabio). I am assuming that this would
>> result in time slices being scheduled using WF2Q+
>
> Yep, at least that is my preference.
>
>> 2 Do the following to support proportional division:
>>  a) Expose the per device weight interface to user, instead of calculating
>>  from priority.
>>  b) Add support for scheduling bandwidth among a hierarchy of cgroups
>> (besides threads)
>> 3 Do the following to support the goals of 2 level schedulers:
>>  a) Limit the request descriptors allocated to each cgroup by adding
>>  functionality to elv_may_queue()
>>  b) Add support for putting an absolute limit on IO consumed by a
>>  cgroup. Such support is provided by Andrea
>>  Righi's patches too.
>>  c) Add support (configurable option) to keep track of total disk
>> time/sectors/count
>>  consumed at each device, and factor that into scheduling decision
>>  (more discussion needed here)
>> 6 Incorporate an IO tracking approach which can allow tracking cgroups
>> for asynchronous reads/writes.
>> 7 Start an offline email thread to keep track of progress on the above
>> goals.
>>
>> Jens, what is your opinion everything beyond (1) in the above list?
>>
>> It would be great if work on (1) and (2)-(7) can happen in parallel so
>> that we can see "proportional division of IO bandwidth to cgroups" in
>> tree sooner than later.
>
> Sounds feasible, I'd like to see the cgroups approach get more traction.
> My primary concern is just that I don't want to merge it into specific
> IO schedulers.

Jens,
     So are you saying you don't prefer cgroups based proportional IO
division solutions in the IO scheduler but at a layer above so it can
be shared with all IO schedulers?

     If yes, then in that case, what do you think about Vivek Goyal's
patch or dm-ioband that achieve that. Of course, both solutions don't
meet all the requirements in the list above, but we can work on that
once we know which direction we should be heading in. In fact, it
would help if you could express the reservations (if you have any)
about these approaches. That would help in coming up with a plan that
everyone agrees on.

Thanks,
DIvyesh

 As you mention, we can hook into the may queue logic for
> that subset of the problem, that avoids touching the io scheduler. If we
> can get this supported 'generically', then I'd be happy to help out.
>
> --
> Jens Axboe
>
>
