From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Mon, 6 Apr 2009 15:00:50 -0700
Message-ID: <e98e18940904061500v3d29d7f3t82d4f302b5ab646a@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090406143556.GK7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090406143556.GK7082-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 6, 2009 at 7:35 AM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wr=
ote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-03-11 21:56:46]:
>
>> o Documentation for io-controller.
>>
>> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> ---
>> =A0Documentation/block/io-controller.txt | =A0221 ++++++++++++++++++++++=
+++++++++++
>> =A01 files changed, 221 insertions(+), 0 deletions(-)
>> =A0create mode 100644 Documentation/block/io-controller.txt
>>
>> diff --git a/Documentation/block/io-controller.txt b/Documentation/block=
/io-controller.txt
>> new file mode 100644
>> index 0000000..8884c5a
>> --- /dev/null
>> +++ b/Documentation/block/io-controller.txt
>> @@ -0,0 +1,221 @@
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IO Controller
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +Overview
>> +=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +This patchset implements a proportional weight IO controller. That is o=
ne
>> +can create cgroups and assign prio/weights to those cgroups and task gr=
oup
>> +will get access to disk proportionate to the weight of the group.
>> +
>> +These patches modify elevator layer and individual IO schedulers to do
>> +IO control hence this io controller works only on block devices which u=
se
>> +one of the standard io schedulers can not be used with any xyz logical =
block
>> +device.
>> +
>> +The assumption/thought behind modifying IO scheduler is that resource c=
ontrol
>> +is needed only on leaf nodes where the actual contention for resources =
is
>> +present and not on intertermediate logical block devices.
>> +
>> +Consider following hypothetical scenario. Lets say there are three phys=
ical
>> +disks, namely sda, sdb and sdc. Two logical volumes (lv0 and lv1) have =
been
>> +created on top of these. Some part of sdb is in lv0 and some part is in=
 lv1.
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lv0 =A0 =A0 =A0lv1
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 / =A0 =A0 \ =A0/ =A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sda =A0 =A0 =A0sdb =A0 =A0 =A0=
sdc
>> +
>> +Also consider following cgroup hierarchy
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 / =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =A0 =A0 B
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 / \ =A0 =A0/ \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0T1 T2 =A0T3 =A0T4
>> +
>> +A and B are two cgroups and T1, T2, T3 and T4 are tasks with-in those c=
groups.
>> +Assuming T1, T2, T3 and T4 are doing IO on lv0 and lv1. These tasks sho=
uld
>> +get their fair share of bandwidth on disks sda, sdb and sdc. There is no
>> +IO control on intermediate logical block nodes (lv0, lv1).
>> +
>> +So if tasks T1 and T2 are doing IO on lv0 and T3 and T4 are doing IO on=
 lv1
>> +only, there will not be any contetion for resources between group A and=
 B if
>> +IO is going to sda or sdc. But if actual IO gets translated to disk sdb=
, then
>> +IO scheduler associated with the sdb will distribute disk bandwidth to
>> +group A and B proportionate to their weight.
>
> What if we have partitions sda1, sda2 and sda3 instead of sda, sdb and
> sdc?
>
>> +
>> +CFQ already has the notion of fairness and it provides differential disk
>> +access based on priority and class of the task. Just that it is flat and
>> +with cgroup stuff, it needs to be made hierarchical.
>> +
>> +Rest of the IO schedulers (noop, deadline and AS) don't have any notion
>> +of fairness among various threads.
>> +
>> +One of the concerns raised with modifying IO schedulers was that we don=
't
>> +want to replicate the code in all the IO schedulers. These patches share
>> +the fair queuing code which has been moved to a common layer (elevator
>> +layer). Hence we don't end up replicating code across IO schedulers.
>> +
>> +Design
>> +=3D=3D=3D=3D=3D=3D
>> +This patchset primarily uses BFQ (Budget Fair Queuing) code to provide
>> +fairness among different IO queues. Fabio and Paolo implemented BFQ whi=
ch uses
>> +B-WF2Q+ algorithm for fair queuing.
>> +
>
> References to BFQ, please. I can search them, but having them in the
> doc would be nice.
>
>> +Why BFQ?
>> +
>> +- Not sure if weighted round robin logic of CFQ can be easily extended =
for
>> + =A0hierarchical mode. One of the things is that we can not keep dividi=
ng
>> + =A0the time slice of parent group among childrens. Deeper we go in hie=
rarchy
>> + =A0time slice will get smaller.
>> +
>> + =A0One of the ways to implement hierarchical support could be to keep =
track
>> + =A0of virtual time and service provided to queue/group and select a qu=
eue/group
>> + =A0for service based on any of the various available algoriths.
>> +
>> + =A0BFQ already had support for hierarchical scheduling, taking those p=
atches
>> + =A0was easier.
>> +
>
> Could you elaborate, when you say timeslices get smaller -
>
> 1. Are you referring to inability to use higher resolution time?
> 2. Loss of throughput due to timeslice degradation?
>
>> +- BFQ was designed to provide tighter bounds/delay w.r.t service provid=
ed
>> + =A0to a queue. Delay/Jitter with BFQ is supposed to be O(1).
>> +
>> + =A0Note: BFQ originally used amount of IO done (number of sectors) as =
notion
>> + =A0 =A0 =A0 =A0of service provided. IOW, it tried to provide fairness =
in terms of
>> + =A0 =A0 =A0 =A0actual IO done and not in terms of actual time disk acc=
ess was
>> + =A0 =A0 given to a queue.
>
> I assume by sectors you mean the kernel sector size?
>
>> +
>> + =A0 =A0 This patcheset modified BFQ to provide fairness in time domain=
 because
>> + =A0 =A0 that's what CFQ does. So idea was try not to deviate too much =
from
>> + =A0 =A0 the CFQ behavior initially.
>> +
>> + =A0 =A0 Providing fairness in time domain makes accounting trciky beca=
use
>> + =A0 =A0 due to command queueing, at one time there might be multiple r=
equests
>> + =A0 =A0 from different queues and there is no easy way to find out how=
 much
>> + =A0 =A0 disk time actually was consumed by the requests of a particular
>> + =A0 =A0 queue. More about this in comments in source code.
>> +
>> +So it is yet to be seen if changing to time domain still retains BFQ gu=
rantees
>> +or not.
>> +
>> +From data structure point of view, one can think of a tree per device, =
where
>> +io groups and io queues are hanging and are being scheduled using B-WF2=
Q+
>> +algorithm. io_queue, is end queue where requests are actually stored and
>> +dispatched from (like cfqq).
>> +
>> +These io queues are primarily created by and managed by end io schedule=
rs
>> +depending on its semantics. For example, noop, deadline and AS ioschedu=
lers
>> +keep one io queues per cgroup and cfqq keeps one io queue per io_contex=
t in
>> +a cgroup (apart from async queues).
>> +
>
> I assume there is one io_context per cgroup.
>
>> +A request is mapped to an io group by elevator layer and which io queue=
 it
>> +is mapped to with in group depends on ioscheduler. Currently "current" =
task
>> +is used to determine the cgroup (hence io group) of the request. Down t=
he
>> +line we need to make use of bio-cgroup patches to map delayed writes to
>> +right group.
>
> That seem acceptable
>
>> +
>> +Going back to old behavior
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
>> +In new scheme of things essentially we are creating hierarchical fair
>> +queuing logic in elevator layer and chaning IO schedulers to make use of
>> +that logic so that end IO schedulers start supporting hierarchical sche=
duling.
>> +
>> +Elevator layer continues to support the old interfaces. So even if fair=
 queuing
>> +is enabled at elevator layer, one can have both new hierchical schedule=
r as
>> +well as old non-hierarchical scheduler operating.
>> +
>> +Also noop, deadline and AS have option of enabling hierarchical schedul=
ing.
>> +If it is selected, fair queuing is done in hierarchical manner. If hier=
archical
>> +scheduling is disabled, noop, deadline and AS should retain their exist=
ing
>> +behavior.
>> +
>> +CFQ is the only exception where one can not disable fair queuing as it =
is
>> +needed for provding fairness among various threads even in non-hierarch=
ical
>> +mode.
>> +
>> +Various user visible config options
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +CONFIG_IOSCHED_NOOP_HIER
>> + =A0 =A0 - Enables hierchical fair queuing in noop. Not selecting this =
option
>> + =A0 =A0 =A0 leads to old behavior of noop.
>> +
>> +CONFIG_IOSCHED_DEADLINE_HIER
>> + =A0 =A0 - Enables hierchical fair queuing in deadline. Not selecting t=
his
>> + =A0 =A0 =A0 option leads to old behavior of deadline.
>> +
>> +CONFIG_IOSCHED_AS_HIER
>> + =A0 =A0 - Enables hierchical fair queuing in AS. Not selecting this op=
tion
>> + =A0 =A0 =A0 leads to old behavior of AS.
>> +
>> +CONFIG_IOSCHED_CFQ_HIER
>> + =A0 =A0 - Enables hierarchical fair queuing in CFQ. Not selecting this=
 option
>> + =A0 =A0 =A0 still does fair queuing among various queus but it is flat=
 and not
>> + =A0 =A0 =A0 hierarchical.
>> +
>> +Config options selected automatically
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +These config options are not user visible and are selected/deselected
>> +automatically based on IO scheduler configurations.
>> +
>> +CONFIG_ELV_FAIR_QUEUING
>> + =A0 =A0 - Enables/Disables the fair queuing logic at elevator layer.
>> +
>> +CONFIG_GROUP_IOSCHED
>> + =A0 =A0 - Enables/Disables hierarchical queuing and associated cgroup =
bits.
>> +
>> +TODO
>> +=3D=3D=3D=3D
>> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking et=
c...
>> +- Convert cgroup ioprio to notion of weight.
>> +- Anticipatory code will need more work. It is not working properly cur=
rently
>> + =A0and needs more thought.
>
> What are the problems with the code?
>
>> +- Use of bio-cgroup patches.
>
> I saw these posted as well

I have refactored the bio-cgroup patches to work on top of this patch
set, and keep track of async writes. But we have not been able to get
proportional division for async writes. The problem seems to stem from
the fact that pdflush is cgroup agnostic. Getting proportional IO
scheduling to work might need work beyond block layer. Vivek has been
able to do more testing with those patches, and can explain more.

>
>> +- Use of Nauman's per cgroup request descriptor patches.
>> +
>
> More details would be nice, I am not sure I understand

Right now, the block layer has a limit on request descriptors that can
be allocated. Once that limit is reached, a process trying to get a
request descriptor would be blocked. I wrote a patch in which I made
the request descriptor limit per cgroup, i.e a process will only be
blocked if request descriptors allocated to a give cgroup exceed a
certain limit.

This patch set is already big and we are trying to be careful to
include all the work we have done for solving the problem. So I was
planning to hold onto that patch, and send it out for comments once
the basic infrastructure gets some traction.

>
>> +HOWTO
>> +=3D=3D=3D=3D=3D
>> +So far I have done very simple testing of running two dd threads in two
>> +different cgroups. Here is what you can do.
>> +
>> +- Enable hierarchical scheduling in io scheuduler of your choice (say c=
fq).
>> + =A0 =A0 CONFIG_IOSCHED_CFQ_HIER=3Dy
>> +
>> +- Compile and boot into kernel and mount IO controller.
>> +
>> + =A0 =A0 mount -t cgroup -o io none /cgroup
>> +
>> +- Create two cgroups
>> + =A0 =A0 mkdir -p /cgroup/test1/ /cgroup/test2
>> +
>> +- Set io priority of group test1 and test2
>> + =A0 =A0 echo 0 > /cgroup/test1/io.ioprio
>> + =A0 =A0 echo 4 > /cgroup/test2/io.ioprio
>> +
>
> What is the meaning of priorities? Which is higher, which is lower?
> What is the maximum? How does it impact b/w?
>
>> +- Create two same size files (say 512MB each) on same disk (file1, file=
2) and
>> + =A0launch two dd threads in different cgroup to read those files. Make=
 sure
>> + =A0right io scheduler is being used for the block device where files a=
re
>> + =A0present (the one you compiled in hierarchical mode).
>> +
>> + =A0 =A0 echo 1 > /proc/sys/vm/drop_caches
>> +
>> + =A0 =A0 dd if=3D/mnt/lv0/zerofile1 of=3D/dev/null &
>> + =A0 =A0 echo $! > /cgroup/test1/tasks
>> + =A0 =A0 cat /cgroup/test1/tasks
>> +
>> + =A0 =A0 dd if=3D/mnt/lv0/zerofile2 of=3D/dev/null &
>> + =A0 =A0 echo $! > /cgroup/test2/tasks
>> + =A0 =A0 cat /cgroup/test2/tasks
>> +
>> +- First dd should finish first.
>> +
>> +Some Test Results
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +- Two dd in two cgroups with prio 0 and 4. Ran two "dd" in those cgroup=
s.
>> +
>> +234179072 bytes (234 MB) copied, 10.1811 s, 23.0 MB/s
>> +234179072 bytes (234 MB) copied, 12.6187 s, 18.6 MB/s
>> +
>> +- Three dd in three cgroups with prio 0, 4, 4.
>> +
>> +234179072 bytes (234 MB) copied, 13.7654 s, 17.0 MB/s
>> +234179072 bytes (234 MB) copied, 19.476 s, 12.0 MB/s
>> +234179072 bytes (234 MB) copied, 20.1858 s, 11.6 MB/s
>> --
>> 1.6.0.1
>>
>>
>
> --
> =A0 =A0 =A0 =A0Balbir
>
