From: "Naveen Gupta" <ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller (was Re: Too many I/O controller
	patches)
Date: Wed, 6 Aug 2008 12:37:46 -0700
Message-ID: <2846be6b0808061237o6667c609l21bdb5a765469e95__19640.4969589368$1218051698$gmane$org@mail.gmail.com>
References: <20080804.175126.193692178.ryov@valinux.co.jp>
	<1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217985189.3154.57.camel-xpvPi5bcW5X5OjGIXfuPlhrrLbDL3r4M6qtp775pBPw@public.gmane.org>
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

Fernando

Nice summary. My comments are inline.

-Naveen

2008/8/5 Fernando Luis V=E1zquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>:
> On Mon, 2008-08-04 at 10:20 -0700, Dave Hansen wrote:
>> On Mon, 2008-08-04 at 17:51 +0900, Ryo Tsuruta wrote:
>> > This series of patches of dm-ioband now includes "The bio tracking mec=
hanism,"
>> > which has been posted individually to this mailing list.
>> > This makes it easy for anybody to control the I/O bandwidth even when
>> > the I/O is one of delayed-write requests.
>>
>> During the Containers mini-summit at OLS, it was mentioned that there
>> are at least *FOUR* of these I/O controllers floating around.  Have you
>> talked to the other authors?  (I've cc'd at least one of them).
>>
>> We obviously can't come to any kind of real consensus with people just
>> tossing the same patches back and forth.
>>
>> -- Dave
>
> Hi Dave,
>
> I have been tracking the memory controller patches for a while which
> spurred my interest in cgroups and prompted me to start working on I/O
> bandwidth controlling mechanisms. This year I have had several
> opportunities to discuss the design challenges of i/o controllers with
> the NEC and VALinux Japan teams (CCed), most recently last month during
> the Linux Foundation Japan Linux Symposium, where we took advantage of
> Andrew Morton's visit to Japan to do some brainstorming on this topic. I
> will try so summarize what was discussed there (and in the Linux Storage
> & Filesystem Workshop earlier this year) and propose a hopefully
> acceptable way to proceed and try to get things started.
>
> This RFC ended up being a bit longer than I had originally intended, but
> hopefully it will serve as the start of a fruitful discussion.
>
> As you pointed out, it seems that there is not much consensus building
> going on, but that does not mean there is a lack of interest. To get the
> ball rolling it is probably a good idea to clarify the state of things
> and try to establish what we are trying to accomplish.
>
> *** State of things in the mainstream kernel<BR>
> The kernel has had somewhat adavanced I/O control capabilities for quite
> some time now: CFQ. But the current CFQ has some problems:
>  - I/O priority can be set by PID, PGRP, or UID, but...
>  - ...all the processes that fall within the same class/priority are
> scheduled together and arbitrary grouping are not possible.
>  - Buffered I/O is not handled properly.
>  - CFQ's IO priority is an attribute of a process that affects all
> devices it sends I/O requests to. In other words, with the current
> implementation it is not possible to assign per-device IO priorities to
> a task.
>
> *** Goals
>  1. Cgroups-aware I/O scheduling (being able to define arbitrary
> groupings of processes and treat each group as a single scheduling
> entity).
>  2. Being able to perform I/O bandwidth control independently on each
> device.
>  3. I/O bandwidth shaping.
>  4. Scheduler-independent I/O bandwidth control.
>  5. Usable with stacking devices (md, dm and other devices of that
> ilk).
>  6. I/O tracking (handle buffered and asynchronous I/O properly).
>
> The list of goals above is not exhaustive and it is also likely to
> contain some not-so-nice-to-have features so your feedback would be
> appreciated.
>
> 1. & 2.- Cgroups-aware I/O scheduling (being able to define arbitrary
> groupings of processes and treat each group as a single scheduling
> identity)
>
> We obviously need this because our final goal is to be able to control
> the IO generated by a Linux container. The good news is that we already
> have the cgroups infrastructure so, regarding this problem, we would
> just have to transform our I/O bandwidth controller into a cgroup
> subsystem.
>
> This seems to be the easiest part, but the current cgroups
> infrastructure has some limitations when it comes to dealing with block
> devices: impossibility of creating/removing certain control structures
> dynamically and hardcoding of subsystems (i.e. resource controllers).
> This makes it difficult to handle block devices that can be hotplugged
> and go away at any time (this applies not only to usb storage but also
> to some SATA and SCSI devices). To cope with this situation properly we
> would need hotplug support in cgroups, but, as suggested before and
> discussed in the past (see (0) below), there are some limitations.
>
> Even in the non-hotplug case it would be nice if we could treat each
> block I/O device as an independent resource, which means we could do
> things like allocating I/O bandwidth on a per-device basis. As long as
> performance is not compromised too much, adding some kind of basic
> hotplug support to cgroups is probably worth it.
>
> (0) http://lkml.org/lkml/2008/5/21/12
>
> 3. & 4. & 5. - I/O bandwidth shaping & General design aspects
>
> The implementation of an I/O scheduling algorithm is to a certain extent
> influenced by what we are trying to achieve in terms of I/O bandwidth
> shaping, but, as discussed below, the required accuracy can determine
> the layer where the I/O controller has to reside. Off the top of my
> head, there are three basic operations we may want perform:
>  - I/O nice prioritization: ionice-like approach.
>  - Proportional bandwidth scheduling: each process/group of processes
> has a weight that determines the share of bandwidth they receive.
>  - I/O limiting: set an upper limit to the bandwidth a group of tasks
> can use.

I/O limiting can be a special case of proportional bandwidth
scheduling. A process/process group can use use it's share of
bandwidth and if there is spare bandwidth it be allowed to use it. And
if we want to absolutely restrict it we add another flag which
specifies that the specified proportion is exact and has an upper
bound.

Let's say the ideal b/w for a device is 100MB/s

And process 1 is assigned b/w of 20%. When we say that the proportion
is strict, the b/w for process 1 will be 20% of the max b/w (which may
be less than 100MB/s) subject to a max of 20MB/s.


>
> If we are pursuing a I/O prioritization model =E0 la CFQ the temptation is
> to implement it at the elevator layer or extend any of the existing I/O
> schedulers.
>
> There have been several proposals that extend either the CFQ scheduler
> (see (1), (2) below) or the AS scheduler (see (3) below). The problem
> with these controllers is that they are scheduler dependent, which means
> that they become unusable when we change the scheduler or when we want
> to control stacking devices which define their own make_request_fn
> function (md and dm come to mind). It could be argued that the physical
> devices controlled by a dm or md driver are likely to be fed by
> traditional I/O schedulers such as CFQ, but these I/O schedulers would
> be running independently from each other, each one controlling its own
> device ignoring the fact that they part of a stacking device. This lack
> of information at the elevator layer makes it pretty difficult to obtain
> accurate results when using stacking devices. It seems that unless we
> can make the elevator layer aware of the topology of stacking devices
> (possibly by extending the elevator API?) evelator-based approaches do
> not constitute a generic solution. Here onwards, for discussion
> purposes, I will refer to this type of I/O bandwidth controllers as
> elevator-based I/O controllers.

It can be argued that any scheduling decision wrt to i/o belongs to
elevators. Till now they have been used to improve performance. But
with new requirements to isolate i/o based on process or cgroup, we
need to change the elevators.

If we add another layer of i/o scheduling (block layer I/O controller)
above elevators
1) It builds another layer of i/o scheduling (bandwidth or priority)
2) This new layer can have decisions for i/o scheduling which conflict
with underlying elevator. e.g. If we decide to do b/w scheduling in
this new layer, there is no way a priority based elevator could work
underneath it.

If a custom make_request_fn is defined (which means the said device is
not using existing elevator), it could build it's own scheduling
rather than asking kernel to add another layer at the time of i/o
submission. Since it has complete control of i/o.

>
> A simple way of solving the problems discussed in the previous paragraph
> is to perform I/O control before the I/O actually enters the block layer
> either at the pagecache level (when pages are dirtied) or at the entry
> point to the generic block layer (generic_make_request()). Andrea's I/O
> throttling patches stick to the former variant (see (4) below) and
> Tsuruta-san and Takahashi-san's dm-ioband (see (5) below) take the later
> approach. The rationale is that by hooking into the source of I/O
> requests we can perform I/O control in a topology-agnostic and
> elevator-agnostic way. I will refer to this new type of I/O bandwidth
> controller as block layer I/O controller.
>
> By residing just above the generic block layer the implementation of a
> block layer I/O controller becomes relatively easy, but by not taking
> into account the characteristics of the underlying devices we might risk
> underutilizing them. For this reason, in some cases it would probably
> make sense to complement a generic I/O controller with elevator-based
> I/O controller, so that the maximum throughput can be squeezed from the
> physical devices.
>
> (1) Uchida-san's CFQ-based scheduler: http://lwn.net/Articles/275944/
> (2) Vasily's CFQ-based scheduler: http://lwn.net/Articles/274652/
> (3) Naveen Gupta's AS-based scheduler: http://lwn.net/Articles/288895/
> (4) Andrea Righi's i/o bandwidth controller (I/O throttling):http://threa=
d.gmane.org/gmane.linux.kernel.containers/5975
> (5) Tsuruta-san and Takahashi-san's dm-ioband: http://thread.gmane.org/gm=
ane.linux.kernel.virtualization/6581
>
> 6.- I/O tracking
>
> This is arguably the most important part, since to perform I/O control
> we need to be able to determine where the I/O is coming from.
>
> Reads are trivial because they are served in the context of the task
> that generated the I/O. But most writes are performed by pdflush,
> kswapd, and friends so performing I/O control just in the synchronous
> I/O path would lead to large inaccuracy. To get this right we would need
> to track ownership all the way up to the pagecache page. In other words,
> it is necessary to track who is dirtying pages so that when they are
> written to disk the right task is charged for that I/O.
>
> Fortunately, such tracking of pages is one of the things the existing
> memory resource controller is doing to control memory usage. This is a
> clever observation which has a useful implication: if the rather
> imbricated tracking and accounting parts of the memory resource
> controller were split the I/O controller could leverage the existing
> infrastructure to track buffered and asynchronous I/O. This is exactly
> what the bio-cgroup (see (6) below) patches set out to do.
>
> It is also possible to do without I/O tracking. For that we would need
> to hook into the synchronous I/O path and every place in the kernel
> where pages are dirtied (see (4) above for details). However controlling
> the rate at which a cgroup can generate dirty pages seems to be a task
> that belongs in the memory controller not the I/O controller. As Dave
> and Paul suggested its probably better to delegate this to the memory
> controller. In fact, it seems that Yamamoto-san is cooking some patches
> that implement just that: dirty balancing for cgroups (see (7) for
> details).
>
> Another argument in favor of I/O tracking is that not only block layer
> I/O controllers would benefit from it, but also the existing I/O
> schedulers and the elevator-based I/O controllers proposed by
> Uchida-san, Vasily, and Naveen (Yoshikawa-san, who is CCed, and myself
> are working on this and hopefully will be sending patches soon).
>
> (6) Tsuruta-san and Takahashi-san's I/O tracking patches: http://lkml.org=
/lkml/2008/8/4/90
> (7) Yamamoto-san dirty balancing patches: http://lwn.net/Articles/289237/
>
> *** How to move on
>
> As discussed before, it probably makes sense to have both a block layer
> I/O controller and a elevator-based one, and they could certainly
> cohabitate. As discussed before, all of them need I/O tracking
> capabilities so I would like to suggest the plan below to get things
> started:
>
>  - Improve the I/O tracking patches (see (6) above) until they are in
> mergeable shape.
>  - Fix CFQ and AS to use the new I/O tracking functionality to show its
> benefits. If the performance impact is acceptable this should suffice to
> convince the respective maintainer and get the I/O tracking patches
> merged.
>  - Implement a block layer resource controller. dm-ioband is a working
> solution and feature rich but its dependency on the dm infrastructure is
> likely to find opposition (the dm layer does not handle barriers
> properly and the maximum size of I/O requests can be limited in some
> cases). In such a case, we could either try to build a standalone
> resource controller based on dm-ioband (which would probably hook into
> generic_make_request) or try to come up with something new.
>  - If the I/O tracking patches make it into the kernel we could move on
> and try to get the Cgroup extensions to CFQ and AS mentioned before (see
> (1), (2), and (3) above for details) merged.
>  - Delegate the task of controlling the rate at which a task can
> generate dirty pages to the memory controller.
>
> This RFC is somewhat vague but my feeling is that we build some
> consensus on the goals and basic design aspects before delving into
> implementation details.
>
> I would appreciate your comments and feedback.
>
> - Fernando
>
>
