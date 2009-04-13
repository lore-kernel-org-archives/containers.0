From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Mon, 13 Apr 2009 09:40:17 -0400
Message-ID: <20090413134017.GC18007__4978.64660942486$1239630375$gmane$org@redhat.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090406143556.GK7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 06, 2009 at 08:05:56PM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-03-11 21:56:46]:
> 

Thanks for having a look balbir. Sorry for the late reply..

[..]
> > +Consider following hypothetical scenario. Lets say there are three physical
> > +disks, namely sda, sdb and sdc. Two logical volumes (lv0 and lv1) have been
> > +created on top of these. Some part of sdb is in lv0 and some part is in lv1.
> > +
> > +			    lv0      lv1
> > +			  /	\  /     \
> > +			sda      sdb      sdc
> > +
> > +Also consider following cgroup hierarchy
> > +
> > +				root
> > +				/   \
> > +			       A     B
> > +			      / \    / \
> > +			     T1 T2  T3  T4
> > +
> > +A and B are two cgroups and T1, T2, T3 and T4 are tasks with-in those cgroups.
> > +Assuming T1, T2, T3 and T4 are doing IO on lv0 and lv1. These tasks should
> > +get their fair share of bandwidth on disks sda, sdb and sdc. There is no
> > +IO control on intermediate logical block nodes (lv0, lv1).
> > +
> > +So if tasks T1 and T2 are doing IO on lv0 and T3 and T4 are doing IO on lv1
> > +only, there will not be any contetion for resources between group A and B if
> > +IO is going to sda or sdc. But if actual IO gets translated to disk sdb, then
> > +IO scheduler associated with the sdb will distribute disk bandwidth to
> > +group A and B proportionate to their weight.
> 
> What if we have partitions sda1, sda2 and sda3 instead of sda, sdb and
> sdc?

As Gui already mentioned, IO control is on per device basis (like IO
scheduler) and we don't try to control it per partition basis.

> 
> > +
> > +CFQ already has the notion of fairness and it provides differential disk
> > +access based on priority and class of the task. Just that it is flat and
> > +with cgroup stuff, it needs to be made hierarchical.
> > +
> > +Rest of the IO schedulers (noop, deadline and AS) don't have any notion
> > +of fairness among various threads.
> > +
> > +One of the concerns raised with modifying IO schedulers was that we don't
> > +want to replicate the code in all the IO schedulers. These patches share
> > +the fair queuing code which has been moved to a common layer (elevator
> > +layer). Hence we don't end up replicating code across IO schedulers.
> > +
> > +Design
> > +======
> > +This patchset primarily uses BFQ (Budget Fair Queuing) code to provide
> > +fairness among different IO queues. Fabio and Paolo implemented BFQ which uses
> > +B-WF2Q+ algorithm for fair queuing.
> > +
> 
> References to BFQ, please. I can search them, but having them in the
> doc would be nice.

That's a good point. In next posting I will put references also.

> 
> > +Why BFQ?
> > +
> > +- Not sure if weighted round robin logic of CFQ can be easily extended for
> > +  hierarchical mode. One of the things is that we can not keep dividing
> > +  the time slice of parent group among childrens. Deeper we go in hierarchy
> > +  time slice will get smaller.
> > +
> > +  One of the ways to implement hierarchical support could be to keep track
> > +  of virtual time and service provided to queue/group and select a queue/group
> > +  for service based on any of the various available algoriths.
> > +
> > +  BFQ already had support for hierarchical scheduling, taking those patches
> > +  was easier.
> > +
> 
> Could you elaborate, when you say timeslices get smaller -
> 
> 1. Are you referring to inability to use higher resolution time?
> 2. Loss of throughput due to timeslice degradation?

I think keeping a track of time using higher resolution time should not
be a problem but it would be rather more of loss of throughput due to
smaller timeslices and frequent queue switching.

> 
> > +- BFQ was designed to provide tighter bounds/delay w.r.t service provided
> > +  to a queue. Delay/Jitter with BFQ is supposed to be O(1).
> > +
> > +  Note: BFQ originally used amount of IO done (number of sectors) as notion
> > +        of service provided. IOW, it tried to provide fairness in terms of
> > +        actual IO done and not in terms of actual time disk access was
> > +	given to a queue.
> 
> I assume by sectors you mean the kernel sector size?

Yes.

> 
> > +
> > +	This patcheset modified BFQ to provide fairness in time domain because
> > +	that's what CFQ does. So idea was try not to deviate too much from
> > +	the CFQ behavior initially.
> > +
> > +	Providing fairness in time domain makes accounting trciky because
> > +	due to command queueing, at one time there might be multiple requests
> > +	from different queues and there is no easy way to find out how much
> > +	disk time actually was consumed by the requests of a particular
> > +	queue. More about this in comments in source code.
> > +
> > +So it is yet to be seen if changing to time domain still retains BFQ gurantees
> > +or not.
> > +
> > +From data structure point of view, one can think of a tree per device, where
> > +io groups and io queues are hanging and are being scheduled using B-WF2Q+
> > +algorithm. io_queue, is end queue where requests are actually stored and
> > +dispatched from (like cfqq).
> > +
> > +These io queues are primarily created by and managed by end io schedulers
> > +depending on its semantics. For example, noop, deadline and AS ioschedulers
> > +keep one io queues per cgroup and cfqq keeps one io queue per io_context in
> > +a cgroup (apart from async queues).
> > +
> 
> I assume there is one io_context per cgroup.

No. There can be multiple io_context per cgroup because currently
io_context is defined as threads which are doing IO sharing and are
kept in one queue from IO point of view by cfq and multiple queues are
not created. So there might be many processes/threads in a cgroup and
not necessarily they are sharing the io_context.

> 
> > +A request is mapped to an io group by elevator layer and which io queue it
> > +is mapped to with in group depends on ioscheduler. Currently "current" task
> > +is used to determine the cgroup (hence io group) of the request. Down the
> > +line we need to make use of bio-cgroup patches to map delayed writes to
> > +right group.
> 
> That seem acceptable

Andrew first wants to see a solid plan for handling async writes :-) So 
currently I am playing with patches to map writes to correct cgroup.
Mapping the IO to right cgroup is only one part of the problem. Other part
is that I am not seeing a continuious stream of writes at IO scheduler
level. So if two dd processes are running in user space, ideally one can
expect two continuous stream of write requests at IO scheduler but instead
I see bursty serialized traffic. So a bunch of write request from first
dd then another bunch of write requests from second dd and it goes on..
and this leads to no service differentiation between two writes because
when higher priority task is not dispatching any IO (for .2 seconds), 
lower priority task/group gets to use full disk and soon catches up with
higher priority one..

Part of this serialization was taking place at request descriptor
allocation infrastructure where number of request descriptors are limited
and if one writer first consumes most of the descriptors it will
block/serialize other writer.

Now I have got a crude working patch where I can limit per group request
descriptors so that one group can not block other group. But still don't
see continuously backlogged write queues at IO scheduler...

Time to do more debugging and move up the layer and see where this
serialization is taking place (i guess page cache...).

> 
> > +
> > +Going back to old behavior
> > +==========================
> > +In new scheme of things essentially we are creating hierarchical fair
> > +queuing logic in elevator layer and chaning IO schedulers to make use of
> > +that logic so that end IO schedulers start supporting hierarchical scheduling.
> > +
> > +Elevator layer continues to support the old interfaces. So even if fair queuing
> > +is enabled at elevator layer, one can have both new hierchical scheduler as
> > +well as old non-hierarchical scheduler operating.
> > +
> > +Also noop, deadline and AS have option of enabling hierarchical scheduling.
> > +If it is selected, fair queuing is done in hierarchical manner. If hierarchical
> > +scheduling is disabled, noop, deadline and AS should retain their existing
> > +behavior.
> > +
> > +CFQ is the only exception where one can not disable fair queuing as it is
> > +needed for provding fairness among various threads even in non-hierarchical
> > +mode.
> > +
> > +Various user visible config options
> > +===================================
> > +CONFIG_IOSCHED_NOOP_HIER
> > +	- Enables hierchical fair queuing in noop. Not selecting this option
> > +	  leads to old behavior of noop.
> > +
> > +CONFIG_IOSCHED_DEADLINE_HIER
> > +	- Enables hierchical fair queuing in deadline. Not selecting this
> > +	  option leads to old behavior of deadline.
> > +
> > +CONFIG_IOSCHED_AS_HIER
> > +	- Enables hierchical fair queuing in AS. Not selecting this option
> > +	  leads to old behavior of AS.
> > +
> > +CONFIG_IOSCHED_CFQ_HIER
> > +	- Enables hierarchical fair queuing in CFQ. Not selecting this option
> > +	  still does fair queuing among various queus but it is flat and not
> > +	  hierarchical.
> > +
> > +Config options selected automatically
> > +=====================================
> > +These config options are not user visible and are selected/deselected
> > +automatically based on IO scheduler configurations.
> > +
> > +CONFIG_ELV_FAIR_QUEUING
> > +	- Enables/Disables the fair queuing logic at elevator layer.
> > +
> > +CONFIG_GROUP_IOSCHED
> > +	- Enables/Disables hierarchical queuing and associated cgroup bits.
> > +
> > +TODO
> > +====
> > +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking etc...
> > +- Convert cgroup ioprio to notion of weight.
> > +- Anticipatory code will need more work. It is not working properly currently
> > +  and needs more thought.
> 
> What are the problems with the code?

Have not got a chance to look into the issues in detail yet. Just a crude run
saw drop in performance. Will debug it later the moment I have got async writes
handled...

> > +- Use of bio-cgroup patches.
> 
> I saw these posted as well
> 
> > +- Use of Nauman's per cgroup request descriptor patches.
> > +
> 
> More details would be nice, I am not sure I understand

Currently the number of request descriptors which can be allocated per
device/request queue are fixed by a sysfs tunable (q->nr_requests). So
if there is lots of IO going on from one cgroup then it will consume all
the available request descriptors and other cgroup might starve and not
get its fair share.

Hence we also need to introduce the notion of request descriptor limit per
cgroup so that if request descriptors from one group are exhausted, then
it does not impact the IO of other cgroup.

> 
> > +HOWTO
> > +=====
> > +So far I have done very simple testing of running two dd threads in two
> > +different cgroups. Here is what you can do.
> > +
> > +- Enable hierarchical scheduling in io scheuduler of your choice (say cfq).
> > +	CONFIG_IOSCHED_CFQ_HIER=y
> > +
> > +- Compile and boot into kernel and mount IO controller.
> > +
> > +	mount -t cgroup -o io none /cgroup
> > +
> > +- Create two cgroups
> > +	mkdir -p /cgroup/test1/ /cgroup/test2
> > +
> > +- Set io priority of group test1 and test2
> > +	echo 0 > /cgroup/test1/io.ioprio
> > +	echo 4 > /cgroup/test2/io.ioprio
> > +
> 
> What is the meaning of priorities? Which is higher, which is lower?
> What is the maximum? How does it impact b/w?

Currently cfq has notion of priority range 0-7 (0 being highest). To being
with we simply adopted that notion though we are converting it to weights
now for group.

Mapping from group priority to group weight is linear. So prio 0 group
should get double the BW of prio 4 group.

Thanks
Vivek
