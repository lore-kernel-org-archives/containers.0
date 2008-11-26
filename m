From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 26 Nov 2008 10:18:49 -0500
Message-ID: <20081126151849.GC27826__26817.7304570147$1227713217$gmane$org@redhat.com>
References: <20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<e98e18940811181507t6b1473act2efa23df21dab270@mail.gmail.com>
	<20081119142446.GH26308@kernel.dk>
	<af41c7c40811191612v5db13ae7n3cfe537beb6a157c@mail.gmail.com>
	<20081120081640.GE26308@kernel.dk>
	<20081120134058.GA29306@redhat.com>
	<1227681618.12997.163.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1227681618.12997.163.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Fernando Luis =?iso-8859-1?Q?V=E1zquez?= Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 26, 2008 at 03:40:18PM +0900, Fernando Luis V=E1zquez Cao wrote:
> On Thu, 2008-11-20 at 08:40 -0500, Vivek Goyal wrote:
> > > The dm approach has some merrits, the major one being that it'll fit
> > > directly into existing setups that use dm and can be controlled with
> > > familiar tools. That is a bonus. The draw back is partially the same -
> > > it'll require dm. So it's still not a fit-all approach, unfortunately.
> > > =

> > > So I'd prefer an approach that doesn't force you to use dm.
> > =

> > Hi Jens,
> > =

> > My patches met the goal of not using the dm for every device one wants
> > to control.
> > =

> > Having said that, few things come to mind.
> > =

> > - In what cases do we need to control the higher level logical devices
> >   like dm. It looks like real contention for resources is at leaf nodes.
> >   Hence any kind of resource management/fair queueing should probably be
> >   done at leaf nodes and not at higher level logical nodes.
> =

> The problem with stacking devices is that we do not know how the IO
> going through the leaf nodes contributes to the aggregate throughput
> seen by the application/cgroup that generated it, which is what end
> users care about.
> =


If we keep track of cgroup information in bio and don't loose it while
bio traverses through the stack of devices, then leaf node can still do
the proportional fair share allocation among contending cgroups on that
device.

I think end users care about getting fair share if there is a contention
anywhere along the IO path. Real contention is at leaf nodes. However =

complex the logical device topology is, if two applications are not
contending for disk at lowest level, there is no point in doing any kind
of resource management among them. Though the applications seemingly might
be contending for higher level logical device, at leaf nodes, their IOs
might be going to different disk altogether and practically there is no
contention. =


> The block device could be a plain old sata device, a loop device, a
> stacking device, a SSD, you name it, but their topologies and the fact
> that some of them do not even use an elevator should be transparent to
> the user.

Are there some devices which don't use elevators at leaf nodes? If no,
then its not a issue. =


> =

> If you wanted to do resource management at the leaf nodes some kind of
> topology information should be passed down to the elevators controlling
> the underlying devices, which in turn would need to work cooperatively.
> =


I am not able to understand why some kind of topology information needs
to be passed to underlying elevators. As long as end device can map a bio
correctly to the right cgroup (irrespective of complex topology) and end
device step into resource management only if there is contention for
resources among cgroups on that device, things are fine. We don't have
to worry about intermediate complex topology.

I will take one hypothetical example. Lets assume there are two cgroups
A and B with weights 2048 and 1024 respectively. To me this information
means that if A, and B really conted for the resources somewhere, then
make sure A gets 2/3 of resources and B gets 1/3 of resource.

Now if tasks in these two groups happen to contend for same disk at lowest
level, we do resource management otherwise we don't. Why do I need to
worry about intermediate logical devices in the IO path? =


May be I am missing something. A detailed example will help here...  =


> >   If that makes sense, then probably we don't need to control dm device
> >   and we don't need such higher level solutions.
> =

> For the reasons stated above the two level scheduling approach seems
> cleaner to me.
> =

> > - Any kind of 2 level scheduler solution has the potential to break the
> >   underlying IO scheduler. Higher level solution requires buffering of
> >   bios and controlled release of bios to lower layers. This control bre=
aks
> >   the assumptions of lower layer IO scheduler which knows in what order
> >   bios should be dispatched to device to meet the semantics exported by
> >   the IO scheduler.
> =

> Please notice that the such an IO controller would only get in the way
> of the elevator in case of contention for the device.

True. So are we saying that a user can get expected CFQ or AS behavior
only if there is no contention. If there is contention, then we don't
gurantee anything?

> What is more,
> depending on the workload it turns out that buffering at higher layers
> in a per-cgroup or per-task basis, like dm-band does, may actually
> increase the aggregate throughput (I think that the dm-band team
> observed this behavior too). The reason seems to be that bios buffered
> in such way tend to be highly correlated and thus very likely to get
> merged when released to the elevator.

The goal here is not to increase throughput by doing buffering at higher
layer. This is what IO scheduler currently does. It tries to buffer bios
and select these appropriately to boost throughput. If one needs to focus
on increasing throughput, it should be done at IO scheduler level and
not by introducing one more buffering layer in between.
 =

> =

> > - 2nd level scheduler does not keep track of tasks but task groups lets
> >   every group dispatch fair share. This has got little semantic problem=
 in
> >   the sense that tasks and groups in root cgroup will not be considered=
 at
> >   same level. "root" will be considered one group at same level with all
> >   child group hence competing with them for resources.
> > =

> >   This looks little odd. Considering tasks and groups same level kind of
> >   makes more sense. cpu scheduler also consideres tasks and groups at s=
ame
> >   level and deviation from that probably is not very good.
> > =

> >   Considering tasks and groups at same level will matter only if IO
> >   scheduler maintains separate queue for the task, like CFQ. Because
> >   in that case IO scheduler tries to provide fairness among various task
> >   queues. Some schedulers like noop don't have any notion of separate
> >   task queues and fairness among them. In that case probably we don't
> >   have a choice but to assume root group competing with child groups.
> =

> If deemed necessary this case could be handled too, but it does not look
> like a show-stopper.
> =


It is not a show stopper for sure. But it can be a genuine concern in case
of CFQ atleast which tries to provide fairness among tasks.

Think of following scenario. (Diagram taken from peterz's mail).
		root
		/ | \
	       1  2  A
		    / \
		   B   3

Assume that task 1, task 2 and group A belong to Best effort class and they
all have the same priority. If we go for two level scheduling than, disk BW
will be divided in the ratio of 25%, 25% and 50% between task 1, task 2 and
group A.

I think it should instead be 33% each. Again coming back to the idea of
treating 1, 2 and A at same level.

So this is not a show stopper but once you go for one approach, swithing
to another will become really hard as it might require close interatction
with underlying scheduler and fundamentally 2 level scheduler will find
it very hard to communicate with IO scheduler.

> > Keeping above points in mind, probably two level scheduling is not a
> > very good idea. If putting the code in a particular IO scheduler is a
> > concern we can probably explore ways regarding how we can maximize the
> > sharing of cgroup code among IO schedulers.
> =

> As discussed above, I still think that the two level scheduling approach
> makes more sense.

IMHO, two level scheduling approach makes a case only if resource
management at leaf nodes does not solve the requirements. So far we =

have not got a concrete example where resource management at intermediate
logical devices is needed and resource management at leaf nodes is not
sufficient.  =


Thanks
Vivek

> Regarding the sharing of cgroup code among IO
> schedulers I am all for it. If we consider that elevators should only
> care about maximizing usage of the underlying devices, implementing
> other non-hardware-dependent scheduling disciplines (that prioritize
> according to the task or cgroup that generated the IO, for example) at
> higher layers so that we can reuse code makes a lot of sense.
> =

> Thanks,
> =

> Fernando
