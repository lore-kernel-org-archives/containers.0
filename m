From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Tue, 29 Sep 2009 12:53:09 -0700
Message-ID: <e98e18940909291253r1150d8a9p664478d4d9dc75b2__30957.5472413146$1254254229$gmane$org@mail.gmail.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<e98e18940909281737q142c788dpd20b8bdc05dd0eff@mail.gmail.com>
	<20090929032255.GA10664@redhat.com>
	<20090929.185653.183056711.ryov@valinux.co.jp>
	<20090929141049.GA12141@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090929141049.GA12141-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

We have been going around in circles for past many months on this
issue of IO controller. I thought that we are getting closer to a
point where we agree on one approach and go with it, but apparently we
are not. I think it would be useful at this point to learn from the
example of how similar functionality was introduced for other
resources like cpu scheduling and memory controllers.

We are starting from a point where there is no cgroup based resource
allocation for disks and there is a lot to be done. CFS has been doing
hierarchical proportional allocation for CPU scheduling for a while
now. Only recently someone has sent out patches for enforcing upper
limits. And it makes a lot of sense (more discussion on this later).
Also Fernando tells me that memory controller did not support
hierarchies in the first attempt. What I don't understand is, if we
are starting from scratch, why do we want to solve all the problems of
IO scheduling in one attempt?

Max bandwidth Controller or Proportional bandwidth controller
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Enforcing limits is applicable in the scenario where you are managing
a bunch of services in a data center and you want to either charge
them for what they use or you want a very predictable performance over
time. If we just do proportional allocation, then the actual
performance received by a user depends on other co-scheduled tasks. If
other tasks are not using the resource, you end up using their share.
But if all the other co-users become active, the 'extra' resource that
you had would be taken away. Thus without enforcing some upper limit,
predictability gets hurt.  But this becomes an issue only if we are
sharing resources. The most important precondition to sharing
resources is 'the requirement to provide isolation'. And isolation
includes controlling both bandwidth AND latency, in the presence of
other sharers. As Vivek has rightly pointed out, a ticket allocation
based algorithm is good for enforcing upper limits, but it is NOT good
for providing isolation i.e. latency control and even bandwidth in
some cases (as Vivek has shown with results in the last few emails).
Moreover, a solution that is implemented in higher layers (be it VFS
or DM) has little control over what happens in IO scheduler, again
hurting the isolation goal.

In the absence of isolation, we cannot even start sharing a resource.
The predictability or billing are secondary concerns that arise only
if we are sharing resources. If there is somebody who does not care
about isolation, but want to do their billing correctly, I would like
to know about it. Needless to say that max bandwidth limits can also
be enforced at IO scheduling layer.

Common layer vs CFS
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Takuya has raised an interesting point here. If somebody wishes to use
noop, using a common layer IO controller on top of noop isn't
necessarily going to give them the same thing. In fact, with IO
controller, noop might behave much like CFQ.

Moreover at one point, if we decide that we absolutely need IO
controller to work for other schedulers too, we have this Vivek's
patch set as a proof-of-concept. For now, as Jens very rightly pointed
out in our discussion, we can have a "simple scheduler: Noop" and an
"intelligent scheduler: CFQ with cgroup based scheduling".

Class based scheduling
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

CFQ has this notion of classes that needs to be supported in any
solution that we come up with, otherwise we break the semantics of the
existing scheduler. We have workloads which have strong latency
requirements. We have two options: either don't do resource sharing
for them OR share the resource but put them in a higher class (RT) so
that their latencies are not (or minimally) effected by other
workloads running with them.

A solution in higher layer can try to support those semantics, but
what if somebody wants to use a Noop scheduler and does not care about
those semantics? We will end up with multiple schedulers in the upper
layers, and who knows where all this will stop.

Controlling writeback
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

It seems like writeback path has problems, but we should not try to
solve those problems with the same patch set that is trying to do
basic cgroup based IO scheduling. Jens patches for per-bdi pdflush are
already in. They should solve the problem of pdflush not sending down
enough IOs; at least Jens results seem to show that. IMHO, the next
step is to use memory controller in conjunction with IO controller,
and a per group per bdi pdflush threads (only if a group is doing IO
on that bdi), something similar to io_group that we have in Vivek's
patches. That should solve multiple problems. First, it would allow us
to obviate the need of any tracking for dirty pages. Second, we can
build a feedback from IO scheduling layer to the upper layers. If the
number of pending writes in IO controller for a given group exceed a
limit, we block the submitting thread (pdflush), similar to current
congestion implementation. Then the group would start hitting dirty
limits at one point (we would need per group dirty limits, as has
already been pointed out by others), thus blocking the tasks that are
dirtying the pages. Thus using a block layer IO controller, we can
achieve the affect similar achieved by Righi's proposal.

Vivek has summarized most of the other arguments very well. In short,
what I am trying to say is lets start with something very simple that
satisfies some of the most important requirements and we can build
upon that.

On Tue, Sep 29, 2009 at 7:10 AM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Tue, Sep 29, 2009 at 06:56:53PM +0900, Ryo Tsuruta wrote:
>> Hi Vivek and all,
>>
>> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> > On Mon, Sep 28, 2009 at 05:37:28PM -0700, Nauman Rafique wrote:
>>
>> > > We are starting from a point where there is no cgroup based IO
>> > > scheduling in the kernel. And it is probably not reasonable to satis=
fy
>> > > all IO scheduling related requirements in one patch set. We can start
>> > > with something simple, and build on top of that. So a very simple
>> > > patch set that enables cgroup based proportional scheduling for CFQ
>> > > seems like the way to go at this point.
>> >
>> > Sure, we can start with CFQ only. But a bigger question we need to ans=
wer
>> > is that is CFQ the right place to solve the issue? Jens, do you think
>> > that CFQ is the right place to solve the problem?
>> >
>> > Andrew seems to favor a high level approach so that IO schedulers are =
less
>> > complex and we can provide fairness at high level logical devices also.
>>
>> I'm not in favor of expansion of CFQ, because some enterprise storages
>> are better performed with NOOP rather than CFQ, and I think bandwidth
>> control is needed much more for such storage system. Is it easy to
>> support other IO schedulers even if a new IO scheduler is introduced?
>> I would like to know a bit more specific about Namuman's scheduler desig=
n.
>>
>
> The new design is essentially the old design. Except the fact that
> suggestion is that in the first step instead of covering all the 4 IO
> schedulers, first cover only CFQ and then later others.
>
> So providing fairness for NOOP is not an issue. Even if we introduce new
> IO schedulers down the line, I can't think of a reason why can't we cover
> that too with common layer.
>
>> > I will again try to summarize my understanding so far about the pros/c=
ons
>> > of each approach and then we can take the discussion forward.
>>
>> Good summary. Thanks for your work.
>>
>> > Fairness in terms of size of IO or disk time used
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
>> > On a seeky media, fairness in terms of disk time can get us better res=
ults
>> > instead fairness interms of size of IO or number of IO.
>> >
>> > If we implement some kind of time based solution at higher layer, then
>> > that higher layer should know who used how much of time each group use=
d. We
>> > can probably do some kind of timestamping in bio to get a sense when d=
id it
>> > get into disk and when did it finish. But on a multi queue hardware th=
ere
>> > can be multiple requests in the disk either from same queue or from di=
ffernet
>> > queues and with pure timestamping based apparoch, so far I could not t=
hink
>> > how at high level we will get an idea who used how much of time.
>>
>> IIUC, could the overlap time be calculated from time-stamp on a multi
>> queue hardware?
>
> So far could not think of anything clean. Do you have something in mind.
>
> I was thinking that elevator layer will do the merge of bios. So IO
> scheduler/elevator can time stamp the first bio in the request as it goes
> into the disk and again timestamp with finish time once request finishes.
>
> This way higher layer can get an idea how much disk time a group of bios
> used. But on multi queue, if we dispatch say 4 requests from same queue,
> then time accounting becomes an issue.
>
> Consider following where four requests rq1, rq2, rq3 and rq4 are
> dispatched to disk at time t0, t1, t2 and t3 respectively and these
> requests finish at time t4, t5, t6 and t7. For sake of simlicity assume
> time elapsed between each of milestones is t. Also assume that all these
> requests are from same queue/group.
>
> =A0 =A0 =A0 =A0t0 =A0 t1 =A0 t2 =A0 t3 =A0t4 =A0 t5 =A0 t6 =A0 t7
> =A0 =A0 =A0 =A0rq1 =A0rq2 =A0rq3 rq4 =A0rq1 =A0rq2 =A0rq3 rq4
>
> Now higher layer will think that time consumed by group is:
>
> (t4-t0) + (t5-t1) + (t6-t2) + (t7-t3) =3D 16t
>
> But the time elapsed is only 7t.
>
> Secondly if a different group is running only single sequential reader,
> there CFQ will be driving queue depth of 1 and time will not be running
> faster and this inaccuracy in accounting will lead to unfair share between
> groups.
>
> So we need something better to get a sense which group used how much of
> disk time.
>
>>
>> > So this is the first point of contention that how do we want to provide
>> > fairness. In terms of disk time used or in terms of size of IO/number =
of
>> > IO.
>> >
>> > Max bandwidth Controller or Proportional bandwidth controller
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > What is our primary requirement here? A weight based proportional
>> > bandwidth controller where we can use the resources optimally and any
>> > kind of throttling kicks in only if there is contention for the disk.
>> >
>> > Or we want max bandwidth control where a group is not allowed to use t=
he
>> > disk even if disk is free.
>> >
>> > Or we need both? I would think that at some point of time we will need
>> > both but we can start with proportional bandwidth control first.
>>
>> How about making throttling policy be user selectable like the IO
>> scheduler and putting it in the higher layer? So we could support
>> all of policies (time-based, size-based and rate limiting). There
>> seems not to only one solution which satisfies all users. But I agree
>> with starting with proportional bandwidth control first.
>>
>
> What are the cases where time based policy does not work and size based
> policy works better and user would choose size based policy and not timed
> based one?
>
> I am not against implementing things in higher layer as long as we can
> ensure tight control on latencies, strong isolation between groups and
> not break CFQ's class and ioprio model with-in group.
>
>> BTW, I will start to reimplement dm-ioband into block layer.
>
> Can you elaborate little bit on this?
>
>>
>> > Fairness for higher level logical devices
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > Do we want good fairness numbers for higher level logical devices also
>> > or it is sufficient to provide fairness at leaf nodes. Providing fairn=
ess
>> > at leaf nodes can help us use the resources optimally and in the proce=
ss
>> > we can get fairness at higher level also in many of the cases.
>>
>> We should also take care of block devices which provide their own
>> make_request_fn() and not use a IO scheduler. We can't use the leaf
>> nodes approach to such devices.
>>
>
> I am not sure how big an issue is this. This can be easily solved by
> making use of NOOP scheduler by these devices. What are the reasons for
> these devices to not use even noop?
>
>> > But do we want strict fairness numbers on higher level logical devices
>> > even if it means sub-optimal usage of unerlying phsical devices?
>> >
>> > I think that for proportinal bandwidth control, it should be ok to pro=
vide
>> > fairness at higher level logical device but for max bandwidth control =
it
>> > might make more sense to provide fairness at higher level. Consider a
>> > case where from a striped device a customer wants to limit a group to
>> > 30MB/s and in case of leaf node control, if every leaf node provides
>> > 30MB/s, it might accumulate to much more than specified rate at logical
>> > device.
>> >
>> > Latency Control and strong isolation between groups
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
>> > Do we want a good isolation between groups and better latencies and
>> > stronger isolation between groups?
>> >
>> > I think if problem is solved at IO scheduler level, we can achieve bet=
ter
>> > latency control and hence stronger isolation between groups.
>> >
>> > Higher level solutions should find it hard to provide same kind of lat=
ency
>> > control and isolation between groups as IO scheduler based solution.
>>
>> Why do you think that the higher level solution is hard to provide it?
>> I think that it is a matter of how to implement throttling policy.
>>
>
> So far both in dm-ioband and IO throttling solution I have seen that
> higher layer implements some of kind leaky bucket/token bucket algorithm,
> which inherently allows IO from all the competing groups until they run
> out of tokens and then these groups are made to wait till fresh tokens are
> issued.
>
> That means, most of the times, IO scheduler will see requests from more
> than one group at the same time and that will be the source of weak
> isolation between groups.
>
> Consider following simple examples. Assume there are two groups and one
> contains 16 random readers and other contains 1 random reader.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0G1 =A0 =A0 =A0G2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 16RR =A0 =A0 1RR
>
> Now it might happen that IO scheduler sees requests from all the 17 RR
> readers at the same time. (Throttling probably will kick in later because
> you would like to give one group a nice slice of 100ms otherwise
> sequential readers will suffer a lot and disk will become seek bound).
>
> So CFQ will dispatch requests (at least one), from each of the 16 random
> readers first and then from 1 random reader in group 2 and this increases
> the max latency for the application in group 2 and provides weak
> isolation.
>
> There will also be additional issues with CFQ preemtpion logic. CFQ will
> have no knowledge of groups and it will do cross group preemtptions. For
> example if a meta data request comes in group1, it will preempt any of
> the queue being served in other groups. So somebody doing "find . *" or
> "cat <small files>" in one group will keep on preempting a sequential
> reader in other group. Again this will probably lead to higher max
> latencies.
>
> Note, even if CFQ does not enable idling on random readers, and expires
> queue after single dispatch, seeking time between queues can be
> significant. Similarly, if instead of 16 random reders we had 16 random
> synchronous writers we will have seek time issue as well as writers can
> often dump bigger requests which also adds to latency.
>
> This latency issue can be solved if we dispatch requests only from one
> group for a certain time of time and then move to next group. (Something
> what common layer is doing).
>
> If we go for only single group dispatching requests, then we shall have
> to implemnt some of the preemption semantics also in higher layer because
> in certain cases we want to do preemption across the groups. Like RT task
> group preemting non-RT task group etc.
>
> Once we go deeper into implementation, I think we will find more issues.
>
>> > Fairness for buffered writes
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>> > Doing io control at any place below page cache has disadvantage that p=
age
>> > cache might not dispatch more writes from higher weight group hence hi=
gher
>> > weight group might not see more IO done. Andrew says that we don't have
>> > a solution to this problem in kernel and he would like to see it handl=
ed
>> > properly.
>> >
>> > Only way to solve this seems to be to slow down the writers before they
>> > write into page cache. IO throttling patch handled it by slowing down
>> > writer if it crossed max specified rate. Other suggestions have come in
>> > the form of dirty_ratio per memory cgroup or a separate cgroup control=
ler
>> > al-together where some kind of per group write limit can be specified.
>> >
>> > So if solution is implemented at IO scheduler layer or at device mapper
>> > layer, both shall have to rely on another controller to be co-mounted
>> > to handle buffered writes properly.
>> >
>> > Fairness with-in group
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > One of the issues with higher level controller is that how to do fair
>> > throttling so that fairness with-in group is not impacted. Especially
>> > the case of making sure that we don't break the notion of ioprio of the
>> > processes with-in group.
>>
>> I ran your test script to confirm that the notion of ioprio was not
>> broken by dm-ioband. Here is the results of the test.
>> https://lists.linux-foundation.org/pipermail/containers/2009-May/017834.=
html
>>
>> I think that the time period during which dm-ioband holds IO requests
>> for throttling would be too short to break the notion of ioprio.
>
> Ok, I re-ran that test. Previously default io_limit value was 192 and now
> I set it up to 256 as you suggested. I still see writer starving reader. I
> have removed "conv=3Dfdatasync" from writer so that a writer is pure buff=
ered
> writes.
>
> With vanilla CFQ
> ----------------
> reader: 578867200 bytes (579 MB) copied, 10.803 s, 53.6 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 39.4596 s, 54.4 MB/s
>
> with dm-ioband default io_limit=3D192
> -----------------------------------
> writer: 2147483648 bytes (2.1 GB) copied, 46.2991 s, 46.4 MB/s
> reader: 578867200 bytes (579 MB) copied, 52.1419 s, 11.1 MB/s
>
> ioband2: 0 40355280 ioband 8:50 1 4 192 none weight 768 :100
> ioband1: 0 37768752 ioband 8:49 1 4 192 none weight 768 :100
>
> with dm-ioband default io_limit=3D256
> -----------------------------------
> reader: 578867200 bytes (579 MB) copied, 42.6231 s, 13.6 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 49.1678 s, 43.7 MB/s
>
> ioband2: 0 40355280 ioband 8:50 1 4 256 none weight 1024 :100
> ioband1: 0 37768752 ioband 8:49 1 4 256 none weight 1024 :100
>
> Notice that with vanilla CFQ, reader is taking 10 seconds to finish and
> with dm-ioband it takes more than 40 seconds to finish. So writer is still
> starving the reader with both io_limit 192 and 256.
>
> On top of that can you please give some details how increasing the
> buffered queue length reduces the impact of writers?
>
> IO Prio issue
> --------------
> I ran another test where two ioband devices were created of weight 100
> each on two partitions. In first group 4 readers were launched. Three
> readers are of class BE and prio 7, fourth one is of class BE prio 0. In
> group2, I launched a buffered writer.
>
> One would expect that prio0 reader gets more bandwidth as compared to
> prio 4 readers and prio 7 readers will get more or less same bw. Looks li=
ke
> that is not happening. Look how vanilla CFQ provides much more bandwidth
> to prio0 reader as compared to prio7 reader and how putting them in the
> group reduces the difference betweej prio0 and prio7 readers.
>
> Following are the results.
>
> Vanilla CFQ
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> set1
> ----
> prio 0 reader: 578867200 bytes (579 MB) copied, 14.6287 s, 39.6 MB/s
> 578867200 bytes (579 MB) copied, 50.5431 s, 11.5 MB/s
> 578867200 bytes (579 MB) copied, 51.0175 s, 11.3 MB/s
> 578867200 bytes (579 MB) copied, 52.1346 s, 11.1 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 85.2212 s, 25.2 MB/s
>
> set2
> ----
> prio 0 reader: 578867200 bytes (579 MB) copied, 14.3198 s, 40.4 MB/s
> 578867200 bytes (579 MB) copied, 48.8599 s, 11.8 MB/s
> 578867200 bytes (579 MB) copied, 51.206 s, 11.3 MB/s
> 578867200 bytes (579 MB) copied, 51.5233 s, 11.2 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 83.0834 s, 25.8 MB/s
>
> set3
> ----
> prio 0 reader: 578867200 bytes (579 MB) copied, 14.5222 s, 39.9 MB/s
> 578867200 bytes (579 MB) copied, 51.1256 s, 11.3 MB/s
> 578867200 bytes (579 MB) copied, 51.2004 s, 11.3 MB/s
> 578867200 bytes (579 MB) copied, 51.9652 s, 11.1 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 82.7328 s, 26.0 MB/s
>
> with dm-ioband
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> ioband2: 0 40355280 ioband 8:50 1 4 192 none weight 768 :100
> ioband1: 0 37768752 ioband 8:49 1 4 192 none weight 768 :100
>
> set1
> ----
> prio 0 reader: 578867200 bytes (579 MB) copied, 67.4385 s, 8.6 MB/s
> 578867200 bytes (579 MB) copied, 126.726 s, 4.6 MB/s
> 578867200 bytes (579 MB) copied, 143.203 s, 4.0 MB/s
> 578867200 bytes (579 MB) copied, 148.025 s, 3.9 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 156.953 s, 13.7 MB/s
>
> set2
> ---
> prio 0 reader: 578867200 bytes (579 MB) copied, 58.4422 s, 9.9 MB/s
> 578867200 bytes (579 MB) copied, 113.936 s, 5.1 MB/s
> 578867200 bytes (579 MB) copied, 122.763 s, 4.7 MB/s
> 578867200 bytes (579 MB) copied, 128.198 s, 4.5 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 141.394 s, 15.2 MB/s
>
> set3
> ----
> prio 0 reader: 578867200 bytes (579 MB) copied, 59.8992 s, 9.7 MB/s
> 578867200 bytes (579 MB) copied, 136.858 s, 4.2 MB/s
> 578867200 bytes (579 MB) copied, 139.91 s, 4.1 MB/s
> 578867200 bytes (579 MB) copied, 139.986 s, 4.1 MB/s
> writer: 2147483648 bytes (2.1 GB) copied, 151.889 s, 14.1 MB/s
>
> Note: In vanilla CFQ, prio0 reader got more than 350% BW of prio 7 reader.
> =A0 =A0 =A0With dm-ioband this ratio changed to less than 200%.
>
> =A0 =A0 =A0I will run more tests, but this show how notion of priority wi=
th-in a
> =A0 =A0 =A0group changes if we implement throttling at higher layer and d=
on't
> =A0 =A0 =A0keep it with CFQ.
>
> =A0 =A0 The second thing which strikes me is that I divided the disk 50% =
each
> =A0 =A0 between readers and writers and in that case would expect protect=
ion
> =A0 =A0 for writers and expect writers to finish fast. But writers have b=
een
> =A0 =A0 slowed down like and it also kills overall disk throughput. I thi=
nk
> =A0 =A0 it probably became seek bound.
>
> =A0 =A0 I think the moment I get more time, I will run some timed fio tes=
ts
> =A0 =A0 and look at how overall disk performed and how bandwidth was
> =A0 =A0 distributed with-in group and between groups.
>
>>
>> > Especially io throttling patch was very bad in terms of prio with-in
>> > group where throttling treated everyone equally and difference between
>> > process prio disappeared.
>> >
>> > Reads Vs Writes
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > A higher level control most likely will change the ratio in which reads
>> > and writes are dispatched to disk with-in group. It used to be decided
>> > by IO scheduler so far but with higher level groups doing throttling a=
nd
>> > possibly buffering the bios and releasing them later, they will have to
>> > come up with their own policy on in what proportion reads and writes
>> > should be dispatched. In case of IO scheduler based control, all the
>> > queuing takes place at IO scheduler and it still retains control of
>> > in what ration reads and writes should be dispatched.
>>
>> I don't think it is a concern. The current implementation of dm-ioband
>> is that sync/async IO requests are handled separately and the
>> backlogged IOs are released according to the order of arrival if both
>> sync and async requests are backlogged.
>
> At least the version of dm-ioband I have is not producing the desired
> results. See above.
>
> Is there a newer version? I will run some tests on that too. But I think
> you will again run into same issue where you will decide the ratio of
> read vs write with-in group and as I change the IO schedulers results
> will vary.
>
> So at this point of time I can't think how can you solve read vs write
> ratio issue at higher layer without changing the behavior or underlying
> IO scheduler.
>
>>
>> > Summary
>> > =3D=3D=3D=3D=3D=3D=3D
>> >
>> > - An io scheduler based io controller can provide better latencies,
>> > =A0 stronger isolation between groups, time based fairness and will not
>> > =A0 interfere with io schedulers policies like class, ioprio and
>> > =A0 reader vs writer issues.
>> >
>> > =A0 But it can gunrantee fairness at higher logical level devices.
>> > =A0 Especially in case of max bw control, leaf node control does not s=
ound
>> > =A0 to be the most appropriate thing.
>> >
>> > - IO throttling provides max bw control in terms of absolute rate. It =
has
>> > =A0 the advantage that it can provide control at higher level logical =
device
>> > =A0 and also control buffered writes without need of additional contro=
ller
>> > =A0 co-mounted.
>> >
>> > =A0 But it does only max bw control and not proportion control so one =
might
>> > =A0 not be using resources optimally. It looses sense of task prio and=
 class
>> > =A0 with-in group as any of the task can be throttled with-in group. B=
ecause
>> > =A0 throttling does not kick in till you hit the max bw limit, it shou=
ld find
>> > =A0 it hard to provide same latencies as io scheduler based control.
>> >
>> > - dm-ioband also has the advantage that it can provide fairness at hig=
her
>> > =A0 level logical devices.
>> >
>> > =A0 But, fairness is provided only in terms of size of IO or number of=
 IO.
>> > =A0 No time based fairness. It is very throughput oriented and does not
>> > =A0 throttle high speed group if other group is running slow random re=
ader.
>> > =A0 This results in bad latnecies for random reader group and weaker
>> > =A0 isolation between groups.
>>
>> A new policy can be added to dm-ioband. Actually, range-bw policy,
>> which provides min and max bandwidth control, does time-based
>> throttling. Moreover there is room for improvement for existing
>> policies. The write-starve-read issue you pointed out will be solved
>> soon.
>>
>> > =A0 Also it does not provide fairness if a group is not continuously
>> > =A0 backlogged. So if one is running 1-2 dd/sequential readers in the =
group,
>> > =A0 one does not get fairness until workload is increased to a point w=
here
>> > =A0 group becomes continuously backlogged. This also results in poor
>> > =A0 latencies and limited fairness.
>>
>> This is intended to efficiently use bandwidth of underlying devices
>> when IO load is low.
>
> But this has following undesired results.
>
> - Slow moving group does not get reduced latencies. For example, random r=
eaders
> =A0in slow moving group get no isolation and will continue to see higher =
max
> =A0latencies.
>
> - A single sequential reader in one group does not get fair share and
> =A0we might be pushing buffered writes in other group thinking that we
> =A0are getting better throughput. But the fact is that we are eating away
> =A0readers share in group1 and giving it to writers in group2. Also I
> =A0showed that we did not necessarily improve the overall throughput of
> =A0the system by doing so. (Because it increases the number of seeks).
>
> =A0I had sent you a mail to show that.
>
> http://www.linux-archive.org/device-mapper-development/368752-ioband-limi=
ted-fairness-weak-isolation-between-groups-regarding-dm-ioband-tests.html
>
> =A0But you changed the test case to run 4 readers in a single group to sh=
ow that
> =A0it throughput does not decrease. Please don't change test cases. In ca=
se of 4
> =A0sequential readers in the group, group is continuously backlogged and =
you
> =A0don't steal bandwidth from slow moving group. So in that mail I was not
> =A0even discussing the scenario when you don't steal the bandwidth from
> =A0other group.
>
> =A0I specially created one slow moving group with one reader so that we e=
nd up
> =A0stealing bandwidth from slow moving group and show that we did not ach=
ive
> =A0higher overall throughput by stealing the BW at the same time we did n=
ot get
> =A0fairness for single reader and observed decreasing throughput for sing=
le
> =A0reader as number of writers in other group increased.
>
> Thanks
> Vivek
>
>>
>> > At this point of time it does not look like a single IO controller all
>> > the scenarios/requirements. This means few things to me.
>> >
>> > - Drop some of the requirements and go with one implementation which m=
eets
>> > =A0 those reduced set of requirements.
>> >
>> > - Have more than one IO controller implementation in kenrel. One for l=
ower
>> > =A0 level control for better latencies, stronger isolation and optimal=
 resource
>> > =A0 usage and other one for fairness at higher level logical devices a=
nd max
>> > =A0 bandwidth control.
>> >
>> > =A0 And let user decide which one to use based on his/her needs.
>> >
>> > - Come up with more intelligent way of doing IO control where single
>> > =A0 controller covers all the cases.
>> >
>> > At this point of time, I am more inclined towards option 2 of having m=
ore
>> > than one implementation in kernel. :-) (Until and unless we can brains=
trom
>> > and come up with ideas to make option 3 happen).
>> >
>> > > It would be great if we discuss our plans on the mailing list, so we
>> > > can get early feedback from everyone.
>> >
>> > This is what comes to my mind so far. Please add to the list if I have=
 missed
>> > some points. Also correct me if I am wrong about the pros/cons of the
>> > approaches.
>> >
>> > Thoughts/ideas/opinions are welcome...
>> >
>> > Thanks
>> > Vivek
>>
>> Thanks,
>> Ryo Tsuruta
>
