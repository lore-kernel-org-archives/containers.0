From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 26 Nov 2008 15:40:18 +0900
Message-ID: <1227681618.12997.163.camel__29819.3899020136$1227681853$gmane$org@sebastian.kern.oss.ntt.co.jp>
References: <4922224A.5030502@cn.fujitsu.com>
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>
	<20081118120508.GD15268@gandalf.sssup.it>
	<20081118140751.GA4283@redhat.com>
	<20081118144139.GE15268@gandalf.sssup.it>
	<20081118191208.GJ26308@kernel.dk>
	<e98e18940811181507t6b1473act2efa23df21dab270@mail.gmail.com>
	<20081119142446.GH26308@kernel.dk>
	<af41c7c40811191612v5db13ae7n3cfe537beb6a157c@mail.gmail.com>
	<20081120081640.GE26308@kernel.dk> <20081120134058.GA29306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081120134058.GA29306-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-11-20 at 08:40 -0500, Vivek Goyal wrote:
> > The dm approach has some merrits, the major one being that it'll fit
> > directly into existing setups that use dm and can be controlled with
> > familiar tools. That is a bonus. The draw back is partially the same -
> > it'll require dm. So it's still not a fit-all approach, unfortunately.
> > 
> > So I'd prefer an approach that doesn't force you to use dm.
> 
> Hi Jens,
> 
> My patches met the goal of not using the dm for every device one wants
> to control.
> 
> Having said that, few things come to mind.
> 
> - In what cases do we need to control the higher level logical devices
>   like dm. It looks like real contention for resources is at leaf nodes.
>   Hence any kind of resource management/fair queueing should probably be
>   done at leaf nodes and not at higher level logical nodes.

The problem with stacking devices is that we do not know how the IO
going through the leaf nodes contributes to the aggregate throughput
seen by the application/cgroup that generated it, which is what end
users care about.

The block device could be a plain old sata device, a loop device, a
stacking device, a SSD, you name it, but their topologies and the fact
that some of them do not even use an elevator should be transparent to
the user.

If you wanted to do resource management at the leaf nodes some kind of
topology information should be passed down to the elevators controlling
the underlying devices, which in turn would need to work cooperatively.

>   If that makes sense, then probably we don't need to control dm device
>   and we don't need such higher level solutions.

For the reasons stated above the two level scheduling approach seems
cleaner to me.

> - Any kind of 2 level scheduler solution has the potential to break the
>   underlying IO scheduler. Higher level solution requires buffering of
>   bios and controlled release of bios to lower layers. This control breaks
>   the assumptions of lower layer IO scheduler which knows in what order
>   bios should be dispatched to device to meet the semantics exported by
>   the IO scheduler.

Please notice that the such an IO controller would only get in the way
of the elevator in case of contention for the device. What is more,
depending on the workload it turns out that buffering at higher layers
in a per-cgroup or per-task basis, like dm-band does, may actually
increase the aggregate throughput (I think that the dm-band team
observed this behavior too). The reason seems to be that bios buffered
in such way tend to be highly correlated and thus very likely to get
merged when released to the elevator.

> - 2nd level scheduler does not keep track of tasks but task groups lets
>   every group dispatch fair share. This has got little semantic problem in
>   the sense that tasks and groups in root cgroup will not be considered at
>   same level. "root" will be considered one group at same level with all
>   child group hence competing with them for resources.
> 
>   This looks little odd. Considering tasks and groups same level kind of
>   makes more sense. cpu scheduler also consideres tasks and groups at same
>   level and deviation from that probably is not very good.
> 
>   Considering tasks and groups at same level will matter only if IO
>   scheduler maintains separate queue for the task, like CFQ. Because
>   in that case IO scheduler tries to provide fairness among various task
>   queues. Some schedulers like noop don't have any notion of separate
>   task queues and fairness among them. In that case probably we don't
>   have a choice but to assume root group competing with child groups.

If deemed necessary this case could be handled too, but it does not look
like a show-stopper.

> Keeping above points in mind, probably two level scheduling is not a
> very good idea. If putting the code in a particular IO scheduler is a
> concern we can probably explore ways regarding how we can maximize the
> sharing of cgroup code among IO schedulers.

As discussed above, I still think that the two level scheduling approach
makes more sense. Regarding the sharing of cgroup code among IO
schedulers I am all for it. If we consider that elevators should only
care about maximizing usage of the underlying devices, implementing
other non-hardware-dependent scheduling disciplines (that prioritize
according to the task or cgroup that generated the IO, for example) at
higher layers so that we can reuse code makes a lot of sense.

Thanks,

Fernando
