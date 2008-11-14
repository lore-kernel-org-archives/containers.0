From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Fri, 14 Nov 2008 14:44:22 -0800
Message-ID: <e98e18940811141444u5947b806v27fac453ed1e8a5__27927.8577109382$1226702898$gmane$org@mail.gmail.com>
References: <20081106153022.215696930@redhat.com>
	<20081113.180558.519459540419535699.ryov@valinux.co.jp>
	<20081113155834.GE7542@redhat.com>
	<af41c7c40811131041t1b8491b6la5574ebe75f89000@mail.gmail.com>
	<20081113214642.GG7542@redhat.com>
	<af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>
	<20081114160525.GE24624@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081114160525.GE24624-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

In an attempt to make sure that this discussion leads to
something useful, we have summarized the points raised in this
discussion and have come up with a strategy for future.
The goal of this is to find common ground between all the approaches
proposed on this mailing list.

1 Start with Satoshi's latest patches.
2 Do the following to support propotional division:
 a) Give time slices in proportion to weights (configurable
 option). We can support both priorities and weights by doing
 propotional division between requests with same priorities.
3 Schedule time slices using WF2Q+ instead of round robin.
 Test the performance impact (both throughput and jitter in latency).
4 Do the following to support the goals of 2 level schedulers:
 a) Limit the request descriptors allocated to each cgroup by adding
 functionality to elv_may_queue()
 b) Add support for putting an absolute limit on IO consumed by a
 cgroup. Such support exists in dm-ioband and is provided by Andrea
 Righi's patches too.
 c) Add support (configurable option) to keep track of total disk
time/sectors/count
 consumed at each device, and factor that into scheduling decision
 (more discussion needed here)
5 Support multiple layers of cgroups to align IO controller behavior
 with CPU scheduling behavior (more discussion?)
6 Incorporate an IO tracking approach which re-uses memory resource
controller code but is not dependent on it (may be biocgroup patches from
dm-ioband can be used here directly)
7 Start an offline email thread to keep track of progress on the above
goals.

Please feel free to add/modify items to the list
when you respond back. Any comments/suggestions are more than welcome.

Thanks.
Divyesh & Nauman

On Fri, Nov 14, 2008 at 8:05 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Thu, Nov 13, 2008 at 02:57:29PM -0800, Divyesh Shah wrote:
>
> [..]
>> > > > Ryo, do you still want to stick to two level scheduling? Given the problem
>> > > > of it breaking down underlying scheduler's assumptions, probably it makes
>> > > > more sense to the IO control at each individual IO scheduler.
>> > >
>> > > Vivek,
>> > >      I agree with you that 2 layer scheduler *might* invalidate some
>> > > IO scheduler assumptions (though some testing might help here to
>> > > confirm that). However, one big concern I have with proportional
>> > > division at the IO scheduler level is that there is no means of doing
>> > > admission control at the request queue for the device. What we need is
>> > > request queue partitioning per cgroup.
>> > >     Consider that I want to divide my disk's bandwidth among 3
>> > > cgroups(A, B and C) equally. But say some tasks in the cgroup A flood
>> > > the disk with IO requests and completely use up all of the requests in
>> > > the rq resulting in the following IOs to be blocked on a slot getting
>> > > empty in the rq thus affecting their overall latency. One might argue
>> > > that over the long term though we'll get equal bandwidth division
>> > > between these cgroups. But now consider that cgroup A has tasks that
>> > > always storm the disk with large number of IOs which can be a problem
>> > > for other cgroups.
>> > >     This actually becomes an even larger problem when we want to
>> > > support high priority requests as they may get blocked behind other
>> > > lower priority requests which have used up all the available requests
>> > > in the rq. With request queue division we can achieve this easily by
>> > > having tasks requiring high priority IO belong to a different cgroup.
>> > > dm-ioband and any other 2-level scheduler can do this easily.
>> > >
>> >
>> > Hi Divyesh,
>> >
>> > I understand that request descriptors can be a bottleneck here. But that
>> > should be an issue even today with CFQ where a low priority process
>> > consume lots of request descriptors and prevent higher priority process
>> > from submitting the request.
>>
>> Yes that is true and that is one of the main reasons why I would lean
>> towards 2-level scheduler coz you get request queue division as well.
>>
>>  I think you already said it and I just
>> > reiterated it.
>> >
>> > I think in that case we need to do something about request descriptor
>> > allocation instead of relying on 2nd level of IO scheduler.
>> > At this point I am not sure what to do. May be we can take feedback from the
>> > respective queue (like cfqq) of submitting application and if it is already
>> > backlogged beyond a certain limit, then we can put that application to sleep
>> > and stop it from consuming excessive amount of request descriptors
>> > (despite the fact that we have free request descriptors).
>>
>> This should be done per-cgroup rather than per-process.
>>
>
> Yep, per cgroup limit will make more sense. get_request() already calls
> elv_may_queue() to get a feedback from IO scheduler. May be here IO
> scheduler can make a decision how many request descriptors are already
> allocated to this cgroup. And if the queue is congested, then IO scheduler
> can deny the fresh request allocation.
>
> Thanks
> Vivek
>
