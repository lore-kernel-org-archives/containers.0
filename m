From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Fri, 21 Nov 2008 10:22:23 -0500
Message-ID: <20081121152223.GE3111__17985.1608969786$1227281364$gmane$org@redhat.com>
References: <20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<e98e18940811181507t6b1473act2efa23df21dab270@mail.gmail.com>
	<20081119142446.GH26308@kernel.dk>
	<af41c7c40811191612v5db13ae7n3cfe537beb6a157c@mail.gmail.com>
	<20081120081640.GE26308@kernel.dk>
	<20081120134058.GA29306@redhat.com>
	<e98e18940811201154l6fb0499x24da39812fb2aa7e@mail.gmail.com>
	<20081120211536.GG29306@redhat.com>
	<e98e18940811201442s787a346em4ada30bcb1badfe6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e98e18940811201442s787a346em4ada30bcb1badfe6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 20, 2008 at 02:42:38PM -0800, Nauman Rafique wrote:

[..]
> >> It seems that we have a solution if we can figure out a way to share
> >> cgroup code between different schedulers. I am thinking how other
> >> schedulers (AS, Deadline, No-op) would use cgroups. Will they have
> >> proportional division between requests from different cgroups? And use
> >> their own policy (e.g deadline scheduling) within a cgroup? How about
> >> if we have both threads and cgroups at a particular level? I think
> >> putting all threads in a default cgroup seems like a reasonable choice
> >> in this case.
> >>
> >> Here is a high level design that comes to mind.
> >>
> >> Put proportional division code and state in common code. Each level of
> >> the hierarchy which has more than one cgroup would have some state
> >> maintained in common code. At leaf level of hiearchy, we can have a
> >> cgroup specific scheduler (created when a cgroup is created). We can
> >> choose a different scheduler for each cgroup (we can have a no-op for
> >> one cgroup while cfq for another).
> >
> > I am not sure that I understand the different scheduler for each cgroup
> > aspect of it. What's the need? It makes things even more complicated I
> > think.
> 
> With the design I had in my mind, it seemed like that would come for
> free. But if it does not, I completely agree with you that its not as
> important.
> 
> >
> > But moving proportional division code out of particular scheduler and make
> > it common makes sense.
> >
> > Looking at BFQ, I was thinking that we can just keep large part of the
> > code. This common code can think of everything as scheduling entity. This
> > scheduling entity (SE) will be defined by underlying scheduler depending on
> > how queue management is done by underlying scheduler. So for CFQ, at
> > each level, an SE can be either task or group. For the schedulers which
> > don't maintain separate queues for tasks, it will simply be group at all
> > levels.
> 
> So the structure of hierarchy would be dependent on the underlying scheduler?
> 

Kind of. In fact it will depend on cgroup hierarchy and dependent on
underlying scheduler.

> >
> > We probably can employ B-WFQ2+ to provide hierarchical fairness between
> > secheduling entities of this tree. Common layer will do the scheduling of
> > entities (without knowing what is contained inside) and underlying scheduler
> > will take care of dispatching the requests from the scheduled entity.
> > (It could be a task queue for CFQ or a group queue for other schedulers).
> >
> > The tricky part would be how to abstract it in a clean way. It should lead
> > to reduced code in CFQ/BFQ because B-WFQ2+ logic will be put into a
> > common layer (for large part).
> 
> How about this plan:
> 1 Start with CFQ patched with some BFQ like patches (This is what we
> will have if Jens takes some of Fabio's patches). This will have no
> cgroup related logic (correct me if I am wrong).
> 2 Repeat proportional scheduling logic for cgroups in the common
> layer, without touching the code produced in step 1. That means that
> we will have WF2Q+ used for scheduling cgroup time slices proportional
> to weight in the common code. If CFQ (step 1 output) is used as
> scheduler, WF2Q+ would be used there too, but to schedule time slices
> (in proportion to priorities?) between different threads. Common code
> logic will be completely oblivious of the actual scheduler used
> (patched CFQ, Deadline, AS etc).

I think once you start using WF2Q+ in common layer, CFQ will have to get
rid of that code. (Remember in case of CFQ, we will have a tree which
has got both task and groups as Scheduling Entity). So common layer code
can select the next entity to be dispatched base on WFQ2+ and then 
CFQ will decide which request to dispatch with-in that scheduling entity.

So may be we can start with bfq and try to break the code in two pieces.
One common code and one scheduler specific code. Then try to make use
of common code in deadline or anticipatory to see if things work fine. If,
that works, then we can get to CFQ to make use of common code. By that
time CFQ should have Fabio's changes. I think that will include WF2Q+
algorithm also (At least to provide faireness among taks, and not the
hierarchical thing). Once common layer WF2Q+ works well, we can get rid
of WF2Q+ from CFQ and try to complete the picture.

> cgroup tracking has to be implemented as part of step 2. The good
> thing is that step 2 can proceed independent of step 1, as the output
> of step 1 will have the same interface as the existing CFQ scheduler.
> 

Agreed. any kind of tracking based on bio and not the task context shall
have to be done later, once we have come up with common layer code.

These are very vague high level ideas. Devil lies in details. :-) I will
get started to see how feasible the common layer code idea is.

Thanks
Vivek
