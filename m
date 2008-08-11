From: "Naveen Gupta" <ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller (was Re: Too many I/O controller
	patches)
Date: Mon, 11 Aug 2008 11:18:51 -0700
Message-ID: <2846be6b0808111118q14995d84xdb9e6de500e415e2__32379.4848904528$1218478898$gmane$org@mail.gmail.com>
References: <20080804.175126.193692178.ryov@valinux.co.jp>
	<1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<2846be6b0808061237o6667c609l21bdb5a765469e95@mail.gmail.com>
	<1218115028.8460.353.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1218115028.8460.353.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?= <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Fernando


2008/8/7 Fernando Luis V=E1zquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>:
> Hi Naveen,
>
> On Wed, 2008-08-06 at 12:37 -0700, Naveen Gupta wrote:
>> > 3. & 4. & 5. - I/O bandwidth shaping & General design aspects
>> >
>> > The implementation of an I/O scheduling algorithm is to a certain exte=
nt
>> > influenced by what we are trying to achieve in terms of I/O bandwidth
>> > shaping, but, as discussed below, the required accuracy can determine
>> > the layer where the I/O controller has to reside. Off the top of my
>> > head, there are three basic operations we may want perform:
>> >  - I/O nice prioritization: ionice-like approach.
>> >  - Proportional bandwidth scheduling: each process/group of processes
>> > has a weight that determines the share of bandwidth they receive.
>> >  - I/O limiting: set an upper limit to the bandwidth a group of tasks
>> > can use.
>>
>> I/O limiting can be a special case of proportional bandwidth
>> scheduling. A process/process group can use use it's share of
>> bandwidth and if there is spare bandwidth it be allowed to use it. And
>> if we want to absolutely restrict it we add another flag which
>> specifies that the specified proportion is exact and has an upper
>> bound.
>>
>> Let's say the ideal b/w for a device is 100MB/s
>>
>> And process 1 is assigned b/w of 20%. When we say that the proportion
>> is strict, the b/w for process 1 will be 20% of the max b/w (which may
>> be less than 100MB/s) subject to a max of 20MB/s.
> I essentially agree with you. The nice thing about proportional
> bandwidth scheduling is that we get bandwidth guarantees when there is
> contention for the block device, but still get the benefits of
> statistical multiplexing in the non-contended case. With strict IO
> limiting we risk underusing the block devices.
>
>> > If we are pursuing a I/O prioritization model =E0 la CFQ the temptatio=
n is
>> > to implement it at the elevator layer or extend any of the existing I/O
>> > schedulers.
>> >
>> > There have been several proposals that extend either the CFQ scheduler
>> > (see (1), (2) below) or the AS scheduler (see (3) below). The problem
>> > with these controllers is that they are scheduler dependent, which mea=
ns
>> > that they become unusable when we change the scheduler or when we want
>> > to control stacking devices which define their own make_request_fn
>> > function (md and dm come to mind). It could be argued that the physical
>> > devices controlled by a dm or md driver are likely to be fed by
>> > traditional I/O schedulers such as CFQ, but these I/O schedulers would
>> > be running independently from each other, each one controlling its own
>> > device ignoring the fact that they part of a stacking device. This lack
>> > of information at the elevator layer makes it pretty difficult to obta=
in
>> > accurate results when using stacking devices. It seems that unless we
>> > can make the elevator layer aware of the topology of stacking devices
>> > (possibly by extending the elevator API?) evelator-based approaches do
>> > not constitute a generic solution. Here onwards, for discussion
>> > purposes, I will refer to this type of I/O bandwidth controllers as
>> > elevator-based I/O controllers.
>>
>> It can be argued that any scheduling decision wrt to i/o belongs to
>> elevators. Till now they have been used to improve performance. But
>> with new requirements to isolate i/o based on process or cgroup, we
>> need to change the elevators.
> I have the impression there is a tendency to conflate two different
> issues when discussing I/O schedulers and resource controllers, so let
> me elaborate on this point.
>
> On the one hand, we have the problem of feeding physical devices with IO
> requests in such a way that we squeeze the maximum performance out of
> them. Of course in some cases we may want to prioritize responsiveness
> over throughput. In either case the kernel has to perform the same basic
> operations: merging and dispatching IO requests. There is no discussion
> this is the elevator's job and the elevator should take into account the
> physical characteristics of the device.
>
> On the other hand, there is the problem of sharing an IO resource, i.e.
> block device, between multiple tasks or groups of tasks. There are many
> ways of sharing an IO resource depending on what we are trying to
> accomplish: proportional bandwidth scheduling, priority-based
> scheduling, etc. But to implement this sharing algorithms the kernel has
> to determine the task whose IO will be submitted. In a sense, we are
> scheduling tasks (and groups of tasks) not IO requests (which has much
> in common with CPU scheduling). Besides, the sharing problem is not
> directly related to the characteristics of the underlying device, which
> means it does not need to be implemented at the elevator layer.

What if we pass the task specific information to the elevator. We do
this for CFQ (where we pass the priority). And if we need any
additional information to be passed we could add that in a similar
manner.

I really liked your initial suggestion where step 1 would be to add
I/O tracking patches. And then use this in CFQ and AS to do resource
sharing. And if we see any shortcoming with this approach. Let's see
what the best place is to solve remaining problems.


>
> Traditional elevators limit themselves to schedule IO requests to disk
> with no regard to where it came from. However, new IO schedulers such as
> CFQ combine this with IO prioritization capabilities. This means that
> the elevator decides the application whose IO will be dispatched next.
> The problem is that at this layer there is not enough information to
> make such decisions in an accurate way, because, as mentioned in the
> RFC, the elevator has not way to know the block IO topology. The
> implication of this is that the elevator does not know the impact a
> particular scheduling decision will make in the IO throughput seen by
> applications, which is what users care about.

Is it possible to send the topology information to the elevators. And
then they can make global as well as local decisions.

>
> For all these reasons, I think the elevator should take care of
> optimizing the last stretch of the IO path (generic block layer -> block
> device) for performance/responsiveness, and leave the job of ensuring
> that each task is guaranteed a fair share of the kernel's IO resources
> to the upper layers (for example a block layer resource controller).
>
> I recognize that in some cases global performance could be improved if
> the block layer had access to information from the elevator, and that is
> why I mentioned in the RFC that in some cases it might make sense to
> combine a block layer resource controller and a elevator layer one (we
> just would need to figure out a way for the to communicate with each
> other and work well in tandem).
>
>> If we add another layer of i/o scheduling (block layer I/O controller)
>> above elevators
>> 1) It builds another layer of i/o scheduling (bandwidth or priority)
> As I mentioned before we are trying to achieve two things: making the
> best use of block devices, and sharing those IO resources between tasks
> or groups of tasks. There are two possible approaches here: implement
> everything in the elevator or move the sharing bits somewhere above the
> elevator layer. In either case we have to carry out the same tasks so
> the impact of delegating part of the work to a new layer should not be
> that big, and, hopefully, will improve maintainability.
>
>> 2) This new layer can have decisions for i/o scheduling which conflict
>> with underlying elevator. e.g. If we decide to do b/w scheduling in
>> this new layer, there is no way a priority based elevator could work
>> underneath it.
> The priority system could be implemented above the elevator layer in the
> block layer resource controller, which means that the elevator would
> only have to worry about scheduling the requests it receives from the
> block layer and dispatching them to disk in the best possible way.
>
> An alternative would be using a block layer resource controller and a
> elavator-based resource controller in tandem.
>
>> If a custom make_request_fn is defined (which means the said device is
>> not using existing elevator),
> Please note that each of the block devices that constitute a stacking
> device could have its own elevator.

Another possible approach, if the top layer cannot pass topology info
to the underling block device elevators. We could use FIFO for the
underlying block devices, effectively disabling them. The Top layer
will make it's scheduling decision in custom __make_request and the
layers below will just forward. And we can easily avoid any conflict.

>
>> it could build it's own scheduling
>> rather than asking kernel to add another layer at the time of i/o
>> submission. Since it has complete control of i/o.
> I think that is something we should avoid. The IO scheduling behavior
> that the user sees should not depend on the topology of the system. We
> certainly do not want to reimplement the same scheduling algorithm for
> every RAID driver. I am of the opinion that whatever IO scheduling
> algorithm we choose should be implemented just once and usable under any
> IO configuration.
>
I agree that we shouldn't be reinventing things for every RAID driver.
We could have a generic algorithm which everyone plugs into. If not
that is not possible, we always have the option to create one in
custom __make_request.

>


-Naveen
