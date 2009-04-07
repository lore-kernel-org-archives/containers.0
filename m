From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Tue, 07 Apr 2009 13:59:17 +0800
Message-ID: <49DAEBB5.5080804__15187.7289092683$1239084247$gmane$org@cn.fujitsu.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
	<20090406143556.GK7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Balbir Singh wrote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-03-11 21:56:46]:
> 
>> +
>> +			    lv0      lv1
>> +			  /	\  /     \
>> +			sda      sdb      sdc
>> +
>> +Also consider following cgroup hierarchy
>> +
>> +				root
>> +				/   \
>> +			       A     B
>> +			      / \    / \
>> +			     T1 T2  T3  T4
>> +
>> +A and B are two cgroups and T1, T2, T3 and T4 are tasks with-in those cgroups.
>> +Assuming T1, T2, T3 and T4 are doing IO on lv0 and lv1. These tasks should
>> +get their fair share of bandwidth on disks sda, sdb and sdc. There is no
>> +IO control on intermediate logical block nodes (lv0, lv1).
>> +
>> +So if tasks T1 and T2 are doing IO on lv0 and T3 and T4 are doing IO on lv1
>> +only, there will not be any contetion for resources between group A and B if
>> +IO is going to sda or sdc. But if actual IO gets translated to disk sdb, then
>> +IO scheduler associated with the sdb will distribute disk bandwidth to
>> +group A and B proportionate to their weight.
> 
> What if we have partitions sda1, sda2 and sda3 instead of sda, sdb and
> sdc?

  The bandwidth controlling is device basis, so with sda1, sda2 and sda3 instead,
  they will contending on sda.

> 
>> +
>> +CFQ already has the notion of fairness and it provides differential disk
>> +access based on priority and class of the task. Just that it is flat and
>> +with cgroup stuff, it needs to be made hierarchical.
>> +
>> +Rest of the IO schedulers (noop, deadline and AS) don't have any notion
>> +of fairness among various threads.
>> +
>> +One of the concerns raised with modifying IO schedulers was that we don't
>> +want to replicate the code in all the IO schedulers. These patches share
>> +the fair queuing code which has been moved to a common layer (elevator
>> +layer). Hence we don't end up replicating code across IO schedulers.
>> +
>> +Design
>> +======
>> +This patchset primarily uses BFQ (Budget Fair Queuing) code to provide
>> +fairness among different IO queues. Fabio and Paolo implemented BFQ which uses
>> +B-WF2Q+ algorithm for fair queuing.
>> +
> 
> References to BFQ, please. I can search them, but having them in the
> doc would be nice.
> 
>> +Why BFQ?
>> +
>> +- Not sure if weighted round robin logic of CFQ can be easily extended for
>> +  hierarchical mode. One of the things is that we can not keep dividing
>> +  the time slice of parent group among childrens. Deeper we go in hierarchy
>> +  time slice will get smaller.
>> +
>> +  One of the ways to implement hierarchical support could be to keep track
>> +  of virtual time and service provided to queue/group and select a queue/group
>> +  for service based on any of the various available algoriths.
>> +
>> +  BFQ already had support for hierarchical scheduling, taking those patches
>> +  was easier.
>> +
> 
> Could you elaborate, when you say timeslices get smaller -
> 
> 1. Are you referring to inability to use higher resolution time?
> 2. Loss of throughput due to timeslice degradation?
> 
>> +- BFQ was designed to provide tighter bounds/delay w.r.t service provided
>> +  to a queue. Delay/Jitter with BFQ is supposed to be O(1).
>> +
>> +  Note: BFQ originally used amount of IO done (number of sectors) as notion
>> +        of service provided. IOW, it tried to provide fairness in terms of
>> +        actual IO done and not in terms of actual time disk access was
>> +	given to a queue.
> 
> I assume by sectors you mean the kernel sector size?
> 
>> +
>> +	This patcheset modified BFQ to provide fairness in time domain because
>> +	that's what CFQ does. So idea was try not to deviate too much from
>> +	the CFQ behavior initially.
>> +
>> +	Providing fairness in time domain makes accounting trciky because
>> +	due to command queueing, at one time there might be multiple requests
>> +	from different queues and there is no easy way to find out how much
>> +	disk time actually was consumed by the requests of a particular
>> +	queue. More about this in comments in source code.
>> +
>> +So it is yet to be seen if changing to time domain still retains BFQ gurantees
>> +or not.
>> +
>> +From data structure point of view, one can think of a tree per device, where
>> +io groups and io queues are hanging and are being scheduled using B-WF2Q+
>> +algorithm. io_queue, is end queue where requests are actually stored and
>> +dispatched from (like cfqq).
>> +
>> +These io queues are primarily created by and managed by end io schedulers
>> +depending on its semantics. For example, noop, deadline and AS ioschedulers
>> +keep one io queues per cgroup and cfqq keeps one io queue per io_context in
>> +a cgroup (apart from async queues).
>> +
> 
> I assume there is one io_context per cgroup.
> 
>> +A request is mapped to an io group by elevator layer and which io queue it
>> +is mapped to with in group depends on ioscheduler. Currently "current" task
>> +is used to determine the cgroup (hence io group) of the request. Down the
>> +line we need to make use of bio-cgroup patches to map delayed writes to
>> +right group.
> 
> That seem acceptable
> 
>> +
>> +Going back to old behavior
>> +==========================
>> +In new scheme of things essentially we are creating hierarchical fair
>> +queuing logic in elevator layer and chaning IO schedulers to make use of
>> +that logic so that end IO schedulers start supporting hierarchical scheduling.
>> +
>> +Elevator layer continues to support the old interfaces. So even if fair queuing
>> +is enabled at elevator layer, one can have both new hierchical scheduler as
>> +well as old non-hierarchical scheduler operating.
>> +
>> +Also noop, deadline and AS have option of enabling hierarchical scheduling.
>> +If it is selected, fair queuing is done in hierarchical manner. If hierarchical
>> +scheduling is disabled, noop, deadline and AS should retain their existing
>> +behavior.
>> +
>> +CFQ is the only exception where one can not disable fair queuing as it is
>> +needed for provding fairness among various threads even in non-hierarchical
>> +mode.
>> +
>> +Various user visible config options
>> +===================================
>> +CONFIG_IOSCHED_NOOP_HIER
>> +	- Enables hierchical fair queuing in noop. Not selecting this option
>> +	  leads to old behavior of noop.
>> +
>> +CONFIG_IOSCHED_DEADLINE_HIER
>> +	- Enables hierchical fair queuing in deadline. Not selecting this
>> +	  option leads to old behavior of deadline.
>> +
>> +CONFIG_IOSCHED_AS_HIER
>> +	- Enables hierchical fair queuing in AS. Not selecting this option
>> +	  leads to old behavior of AS.
>> +
>> +CONFIG_IOSCHED_CFQ_HIER
>> +	- Enables hierarchical fair queuing in CFQ. Not selecting this option
>> +	  still does fair queuing among various queus but it is flat and not
>> +	  hierarchical.
>> +
>> +Config options selected automatically
>> +=====================================
>> +These config options are not user visible and are selected/deselected
>> +automatically based on IO scheduler configurations.
>> +
>> +CONFIG_ELV_FAIR_QUEUING
>> +	- Enables/Disables the fair queuing logic at elevator layer.
>> +
>> +CONFIG_GROUP_IOSCHED
>> +	- Enables/Disables hierarchical queuing and associated cgroup bits.
>> +
>> +TODO
>> +====
>> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking etc...
>> +- Convert cgroup ioprio to notion of weight.
>> +- Anticipatory code will need more work. It is not working properly currently
>> +  and needs more thought.
> 
> What are the problems with the code?

  Anticipatory has its own idling logic, so what is the concerning here is how to make
  as work together with commom layer.

-- 
Regards
Gui Jianfeng
