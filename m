From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 20 Nov 2008 14:42:38 -0800
Message-ID: <e98e18940811201442s787a346em4ada30bcb1badfe6__19546.3973017924$1227221143$gmane$org@mail.gmail.com>
References: <20081118120508.GD15268@gandalf.sssup.it>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<e98e18940811181507t6b1473act2efa23df21dab270@mail.gmail.com>
	<20081119142446.GH26308@kernel.dk>
	<af41c7c40811191612v5db13ae7n3cfe537beb6a157c@mail.gmail.com>
	<20081120081640.GE26308@kernel.dk> <20081120134058.GA29306@redhat.com>
	<e98e18940811201154l6fb0499x24da39812fb2aa7e@mail.gmail.com>
	<20081120211536.GG29306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081120211536.GG29306-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 20, 2008 at 1:15 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Nov 20, 2008 at 11:54:14AM -0800, Nauman Rafique wrote:
>> On Thu, Nov 20, 2008 at 5:40 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > On Thu, Nov 20, 2008 at 09:16:41AM +0100, Jens Axboe wrote:
>> >> On Wed, Nov 19 2008, Divyesh Shah wrote:
>> >> > On Wed, Nov 19, 2008 at 6:24 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>> >> > > On Tue, Nov 18 2008, Nauman Rafique wrote:
>> >> > >> On Tue, Nov 18, 2008 at 11:12 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
>> >> > >> > On Tue, Nov 18 2008, Fabio Checconi wrote:
>> >> > >> >> > From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> >> > >> >> > Date: Tue, Nov 18, 2008 09:07:51AM -0500
>> >> > >> >> >
>> >> > >> >> > On Tue, Nov 18, 2008 at 01:05:08PM +0100, Fabio Checconi wrote:
>> >> > >> >> ...
>> >> > >> >> > > I have to think a little bit on how it would be possible to support
>> >> > >> >> > > an option for time-only budgets, coexisting with the current behavior,
>> >> > >> >> > > but I think it can be done.
>> >> > >> >> > >
>> >> > >> >> >
>> >> > >> >> > IIUC, bfq and cfq are different in following manner.
>> >> > >> >> >
>> >> > >> >> > a. BFQ employs WF2Q+ for fairness and CFQ employes weighted round robin.
>> >> > >> >> > b. BFQ uses the budget (sector count) as notion of service and CFQ uses
>> >> > >> >> >    time slices.
>> >> > >> >> > c. BFQ supports hierarchical fair queuing and CFQ does not.
>> >> > >> >> >
>> >> > >> >> > We are looking forward for implementation of point C. Fabio seems to
>> >> > >> >> > thinking of supporting time slice as a service (B). It seems like
>> >> > >> >> > convergence of CFQ and BFQ except the point A (WF2Q+ vs weighted round
>> >> > >> >> > robin).
>> >> > >> >> >
>> >> > >> >> > It looks like WF2Q+ provides tighter service bound and bfq guys mention
>> >> > >> >> > that they have been able to ensure throughput while ensuring tighter
>> >> > >> >> > bounds. If that's the case, does that mean BFQ is a replacement for CFQ
>> >> > >> >> > down the line?
>> >> > >> >> >
>> >> > >> >>
>> >> > >> >> BFQ started from CFQ, extending it in the way you correctly describe,
>> >> > >> >> so it is indeed very similar.  There are also some minor changes to
>> >> > >> >> locking, cic handling, hw_tag detection and to the CIC_SEEKY heuristic.
>> >> > >> >>
>> >> > >> >> The two schedulers share similar goals, and in my opinion BFQ can be
>> >> > >> >> considered, in the long term, a CFQ replacement; *but* before talking
>> >> > >> >> about replacing CFQ we have to consider that:
>> >> > >> >>
>> >> > >> >>   - it *needs* review and testing; we've done our best, but for sure
>> >> > >> >>     it's not enough; review and testing are never enough;
>> >> > >> >>   - the service domain fairness, which was one of our objectives, requires
>> >> > >> >>     some extra complexity; the mechanisms we used and the design choices
>> >> > >> >>     we've made may not fit all the needs, or may not be as generic as the
>> >> > >> >>     simpler CFQ's ones;
>> >> > >> >>   - CFQ has years of history behind and has been tuned for a wider
>> >> > >> >>     variety of environments than the ones we've been able to test.
>> >> > >> >>
>> >> > >> >> If time-based fairness is considered more robust and the loss of
>> >> > >> >> service-domain fairness is not a problem, then the two schedulers can
>> >> > >> >> be made even more similar.
>> >> > >> >
>> >> > >> > My preferred approach here would be, in order or TODO:
>> >> > >> >
>> >> > >> > - Create and test the smallish patches for seekiness, hw_tag checking,
>> >> > >> >  and so on for CFQ.
>> >> > >> > - Create and test a WF2Q+ service dispatching patch for CFQ.
>> >> > >> >
>> >> > >> > and if there are leftovers after that, we could even conditionally
>> >> > >> > enable some of those if appropriate. I think the WF2Q+ is quite cool and
>> >> > >> > could be easily usable as the default, so it's definitely a viable
>> >> > >> > alternative.
>> >> > >>
>> >> > >> 1 Merge BFQ into CFQ (Jens and Fabio). I am assuming that this would
>> >> > >> result in time slices being scheduled using WF2Q+
>> >> > >
>> >> > > Yep, at least that is my preference.
>> >> > >
>> >> > >> 2 Do the following to support proportional division:
>> >> > >>  a) Expose the per device weight interface to user, instead of calculating
>> >> > >>  from priority.
>> >> > >>  b) Add support for scheduling bandwidth among a hierarchy of cgroups
>> >> > >> (besides threads)
>> >> > >> 3 Do the following to support the goals of 2 level schedulers:
>> >> > >>  a) Limit the request descriptors allocated to each cgroup by adding
>> >> > >>  functionality to elv_may_queue()
>> >> > >>  b) Add support for putting an absolute limit on IO consumed by a
>> >> > >>  cgroup. Such support is provided by Andrea
>> >> > >>  Righi's patches too.
>> >> > >>  c) Add support (configurable option) to keep track of total disk
>> >> > >> time/sectors/count
>> >> > >>  consumed at each device, and factor that into scheduling decision
>> >> > >>  (more discussion needed here)
>> >> > >> 6 Incorporate an IO tracking approach which can allow tracking cgroups
>> >> > >> for asynchronous reads/writes.
>> >> > >> 7 Start an offline email thread to keep track of progress on the above
>> >> > >> goals.
>> >> > >>
>> >> > >> Jens, what is your opinion everything beyond (1) in the above list?
>> >> > >>
>> >> > >> It would be great if work on (1) and (2)-(7) can happen in parallel so
>> >> > >> that we can see "proportional division of IO bandwidth to cgroups" in
>> >> > >> tree sooner than later.
>> >> > >
>> >> > > Sounds feasible, I'd like to see the cgroups approach get more traction.
>> >> > > My primary concern is just that I don't want to merge it into specific
>> >> > > IO schedulers.
>> >> >
>> >> > Jens,
>> >> >      So are you saying you don't prefer cgroups based proportional IO
>> >> > division solutions in the IO scheduler but at a layer above so it can
>> >> > be shared with all IO schedulers?
>> >> >
>> >> >      If yes, then in that case, what do you think about Vivek Goyal's
>> >> > patch or dm-ioband that achieve that. Of course, both solutions don't
>> >> > meet all the requirements in the list above, but we can work on that
>> >> > once we know which direction we should be heading in. In fact, it
>> >> > would help if you could express the reservations (if you have any)
>> >> > about these approaches. That would help in coming up with a plan that
>> >> > everyone agrees on.
>> >>
>> >> The dm approach has some merrits, the major one being that it'll fit
>> >> directly into existing setups that use dm and can be controlled with
>> >> familiar tools. That is a bonus. The draw back is partially the same -
>> >> it'll require dm. So it's still not a fit-all approach, unfortunately.
>> >>
>> >> So I'd prefer an approach that doesn't force you to use dm.
>> >
>> > Hi Jens,
>> >
>> > My patches met the goal of not using the dm for every device one wants
>> > to control.
>> >
>> > Having said that, few things come to mind.
>> >
>> > - In what cases do we need to control the higher level logical devices
>> >  like dm. It looks like real contention for resources is at leaf nodes.
>> >  Hence any kind of resource management/fair queueing should probably be
>> >  done at leaf nodes and not at higher level logical nodes.
>> >
>> >  If that makes sense, then probably we don't need to control dm device
>> >  and we don't need such higher level solutions.
>> >
>> >
>> > - Any kind of 2 level scheduler solution has the potential to break the
>> >  underlying IO scheduler. Higher level solution requires buffering of
>> >  bios and controlled release of bios to lower layers. This control breaks
>> >  the assumptions of lower layer IO scheduler which knows in what order
>> >  bios should be dispatched to device to meet the semantics exported by
>> >  the IO scheduler.
>> >
>> > - 2nd level scheduler does not keep track of tasks but task groups lets
>> >  every group dispatch fair share. This has got little semantic problem in
>> >  the sense that tasks and groups in root cgroup will not be considered at
>> >  same level. "root" will be considered one group at same level with all
>> >  child group hence competing with them for resources.
>> >
>> >  This looks little odd. Considering tasks and groups same level kind of
>> >  makes more sense. cpu scheduler also consideres tasks and groups at same
>> >  level and deviation from that probably is not very good.
>> >
>> >  Considering tasks and groups at same level will matter only if IO
>> >  scheduler maintains separate queue for the task, like CFQ. Because
>> >  in that case IO scheduler tries to provide fairness among various task
>> >  queues. Some schedulers like noop don't have any notion of separate
>> >  task queues and fairness among them. In that case probably we don't
>> >  have a choice but to assume root group competing with child groups.
>> >
>> > Keeping above points in mind, probably two level scheduling is not a
>> > very good idea. If putting the code in a particular IO scheduler is a
>> > concern we can probably explore ways regarding how we can maximize the
>> > sharing of cgroup code among IO schedulers.
>> >
>> > Thanks
>> > Vivek
>> >
>>
>> It seems that we have a solution if we can figure out a way to share
>> cgroup code between different schedulers. I am thinking how other
>> schedulers (AS, Deadline, No-op) would use cgroups. Will they have
>> proportional division between requests from different cgroups? And use
>> their own policy (e.g deadline scheduling) within a cgroup? How about
>> if we have both threads and cgroups at a particular level? I think
>> putting all threads in a default cgroup seems like a reasonable choice
>> in this case.
>>
>> Here is a high level design that comes to mind.
>>
>> Put proportional division code and state in common code. Each level of
>> the hierarchy which has more than one cgroup would have some state
>> maintained in common code. At leaf level of hiearchy, we can have a
>> cgroup specific scheduler (created when a cgroup is created). We can
>> choose a different scheduler for each cgroup (we can have a no-op for
>> one cgroup while cfq for another).
>
> I am not sure that I understand the different scheduler for each cgroup
> aspect of it. What's the need? It makes things even more complicated I
> think.

With the design I had in my mind, it seemed like that would come for
free. But if it does not, I completely agree with you that its not as
important.

>
> But moving proportional division code out of particular scheduler and make
> it common makes sense.
>
> Looking at BFQ, I was thinking that we can just keep large part of the
> code. This common code can think of everything as scheduling entity. This
> scheduling entity (SE) will be defined by underlying scheduler depending on
> how queue management is done by underlying scheduler. So for CFQ, at
> each level, an SE can be either task or group. For the schedulers which
> don't maintain separate queues for tasks, it will simply be group at all
> levels.

So the structure of hierarchy would be dependent on the underlying scheduler?

>
> We probably can employ B-WFQ2+ to provide hierarchical fairness between
> secheduling entities of this tree. Common layer will do the scheduling of
> entities (without knowing what is contained inside) and underlying scheduler
> will take care of dispatching the requests from the scheduled entity.
> (It could be a task queue for CFQ or a group queue for other schedulers).
>
> The tricky part would be how to abstract it in a clean way. It should lead
> to reduced code in CFQ/BFQ because B-WFQ2+ logic will be put into a
> common layer (for large part).

How about this plan:
1 Start with CFQ patched with some BFQ like patches (This is what we
will have if Jens takes some of Fabio's patches). This will have no
cgroup related logic (correct me if I am wrong).
2 Repeat proportional scheduling logic for cgroups in the common
layer, without touching the code produced in step 1. That means that
we will have WF2Q+ used for scheduling cgroup time slices proportional
to weight in the common code. If CFQ (step 1 output) is used as
scheduler, WF2Q+ would be used there too, but to schedule time slices
(in proportion to priorities?) between different threads. Common code
logic will be completely oblivious of the actual scheduler used
(patched CFQ, Deadline, AS etc).

cgroup tracking has to be implemented as part of step 2. The good
thing is that step 2 can proceed independent of step 1, as the output
of step 1 will have the same interface as the existing CFQ scheduler.

>
>>
>> The scheduler gets a callback (just like it does right now from
>> driver) when the common code schedules a time slice (or budget) from
>> that cgroup. No buffering/queuing is done in the common code, so it
>> will still be a single level scheduler. When a request arrives, it is
>> routed to its scheduler's queues based on its cgroup.
>>
>> The common code proportional scheduler uses specified weights to
>> schedule time slices. Please let me know if it makes any sense. And
>> then we can start talking about lower level details.
>
> We can use either time slices or budgets (may be configurable) depending
> on which gives better results.
>
> Thanks
> Vivek
>
