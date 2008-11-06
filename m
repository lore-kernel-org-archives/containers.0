From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Thu, 6 Nov 2008 15:07:57 -0800
Message-ID: <e98e18940811061507t3e19183byf2b8b291458ba81b__30872.9027201936$1226013148$gmane$org@mail.gmail.com>
References: <20081106153022.215696930@redhat.com>
	<1225986593.7803.4688.camel@twins> <20081106160154.GA7461@redhat.com>
	<1225988173.7803.4723.camel@twins> <20081106163957.GB7461@redhat.com>
	<1225990327.7803.4776.camel@twins> <20081106170830.GD7461@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081106170830.GD7461-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

It seems that approaches with two level scheduling (DM-IOBand or this
patch set on top and another scheduler at elevator) will have the
possibility of undesirable interactions (see "issues" listed at the
end of the second patch). For example, a request submitted as RT might
get delayed at higher layers, even if cfq at elevator level is doing
the right thing.

Moreover, if the requests in the higher level scheduler are dispatched
as soon as they come, there would be no queuing at the higher layers,
unless the request queue at the lower level fills up and causes a
backlog. And in the absence of queuing, any work-conserving scheduler
would behave as a no-op scheduler.

These issues motivate to take a second look into two level scheduling.
The main motivations for two level scheduling seem to be:
(1) Support bandwidth division across multiple devices for RAID and LVMs.
(2) Divide bandwidth between different cgroups without modifying each
of the existing schedulers (and without replicating the code).

One possible approach to handle (1) is to keep track of bandwidth
utilized by each cgroup in a per cgroup data structure (instead of a
per cgroup per device data structure) and use that information to make
scheduling decisions within the elevator level schedulers. Such  a
patch can be made flag-disabled if co-ordination across different
device schedulers is not required.

And (2) can probably be handled by having one scheduler support
different modes. For example, one possible mode is "propotional
division between crgroups + no-op between threads of a cgroup" or "cfq
between cgroups + cfq between threads of a cgroup". That would also
help avoid combinations which might not work e.g RT request issue
mentioned earlier in this email. And this unified scheduler can re-use
code from all the existing patches.

Thanks.
--
Nauman

On Thu, Nov 6, 2008 at 9:08 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Nov 06, 2008 at 05:52:07PM +0100, Peter Zijlstra wrote:
>> On Thu, 2008-11-06 at 11:39 -0500, Vivek Goyal wrote:
>> > On Thu, Nov 06, 2008 at 05:16:13PM +0100, Peter Zijlstra wrote:
>> > > On Thu, 2008-11-06 at 11:01 -0500, Vivek Goyal wrote:
>> > >
>> > > > > Does this still require I use dm, or does it also work on regular block
>> > > > > devices? Patch 4/4 isn't quite clear on this.
>> > > >
>> > > > No. You don't have to use dm. It will simply work on regular devices. We
>> > > > shall have to put few lines of code for it to work on devices which don't
>> > > > make use of standard __make_request() function and provide their own
>> > > > make_request function.
>> > > >
>> > > > Hence for example, I have put that few lines of code so that it can work
>> > > > with dm device. I shall have to do something similar for md too.
>> > > >
>> > > > Though, I am not very sure why do I need to do IO control on higher level
>> > > > devices. Will it be sufficient if we just control only bottom most
>> > > > physical block devices?
>> > > >
>> > > > Anyway, this approach should work at any level.
>> > >
>> > > Nice, although I would think only doing the higher level devices makes
>> > > more sense than only doing the leafs.
>> > >
>> >
>> > I thought that we should be doing any kind of resource management only at
>> > the level where there is actual contention for the resources.So in this case
>> > looks like only bottom most devices are slow and don't have infinite bandwidth
>> > hence the contention.(I am not taking into account the contention at
>> > bus level or contention at interconnect level for external storage,
>> > assuming interconnect is not the bottleneck).
>> >
>> > For example, lets say there is one linear device mapper device dm-0 on
>> > top of physical devices sda and sdb. Assuming two tasks in two different
>> > cgroups are reading two different files from deivce dm-0. Now if these
>> > files both fall on same physical device (either sda or sdb), then they
>> > will be contending for resources. But if files being read are on different
>> > physical deivces then practically there is no device contention (Even on
>> > the surface it might look like that dm-0 is being contended for). So if
>> > files are on different physical devices, IO controller will not know it.
>> > He will simply dispatch one group at a time and other device might remain
>> > idle.
>> >
>> > Keeping that in mind I thought we will be able to make use of full
>> > available bandwidth if we do IO control only at bottom most device. Doing
>> > it at higher layer has potential of not making use of full available bandwidth.
>> >
>> > > Is there any reason we cannot merge this with the regular io-scheduler
>> > > interface? afaik the only problem with doing group scheduling in the
>> > > io-schedulers is the stacked devices issue.
>> >
>> > I think we should be able to merge it with regular io schedulers. Apart
>> > from stacked device issue, people also mentioned that it is so closely
>> > tied to IO schedulers that we will end up doing four implementations for
>> > four schedulers and that is not very good from maintenance perspective.
>> >
>> > But I will spend more time in finding out if there is a common ground
>> > between schedulers so that a lot of common IO control code can be used
>> > in all the schedulers.
>> >
>> > >
>> > > Could we make the io-schedulers aware of this hierarchy?
>> >
>> > You mean IO schedulers knowing that there is somebody above them doing
>> > proportional weight dispatching of bios? If yes, how would that help?
>>
>> Well, take the slightly more elaborate example or a raid[56] setup. This
>> will need to sometimes issue multiple leaf level ios to satisfy one top
>> level io.
>>
>> How are you going to attribute this fairly?
>>
>
> I think in this case, definition of fair allocation will be little
> different. We will do fair allocation only at the leaf nodes where
> there is actual contention, irrespective of higher level setup.
>
> So if higher level block device issues multiple ios to satisfy one top
> level io, we will actually do the bandwidth allocation only on
> those multiple ios because that's the real IO contending for disk
> bandwidth.  And if these multiple ios are going to different physical
> devices, then contention management will take place on those devices.
>
> IOW, we will not worry about providing fairness at bios submitted to
> higher level devices. We will just pitch in for contention management
> only when request from various cgroups are contending for physical
> device at bottom most layers. Isn't if fair?
>
> Thanks
> Vivek
>
>> I don't think the issue of bandwidth availability like above will really
>> be an issue, if your stripe is set up symmetrically, the contention
>> should average out to both (all) disks in equal measures.
>>
>> The only real issue I can see is with linear volumes, but those are
>> stupid anyway - non of the gains but all the risks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
