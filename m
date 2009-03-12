From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 01/10] Documentation
Date: Thu, 12 Mar 2009 15:30:54 +0530
Message-ID: <20090312100054.GA8024__13684.8761969761$1236852425$gmane$org@linux.vnet.ibm.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<1236823015-4183-2-git-send-email-vgoyal@redhat.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1236823015-4183-2-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Mar 11, 2009 at 09:56:46PM -0400, Vivek Goyal wrote:
> o Documentation for io-controller.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  Documentation/block/io-controller.txt |  221 +++++++++++++++++++++++++++++++++
>  1 files changed, 221 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/block/io-controller.txt
> 
> diff --git a/Documentation/block/io-controller.txt b/Documentation/block/io-controller.txt
> new file mode 100644
> index 0000000..8884c5a
> --- /dev/null
> +++ b/Documentation/block/io-controller.txt
> @@ -0,0 +1,221 @@
> +				IO Controller
> +				=============
> +
> +Overview
> +========
> +
> +This patchset implements a proportional weight IO controller. That is one
> +can create cgroups and assign prio/weights to those cgroups and task group
> +will get access to disk proportionate to the weight of the group.
> +
> +These patches modify elevator layer and individual IO schedulers to do
> +IO control hence this io controller works only on block devices which use
> +one of the standard io schedulers can not be used with any xyz logical block
> +device.
> +
> +The assumption/thought behind modifying IO scheduler is that resource control
> +is needed only on leaf nodes where the actual contention for resources is
> +present and not on intertermediate logical block devices.
> +
> +Consider following hypothetical scenario. Lets say there are three physical
> +disks, namely sda, sdb and sdc. Two logical volumes (lv0 and lv1) have been
> +created on top of these. Some part of sdb is in lv0 and some part is in lv1.
> +
> +			    lv0      lv1
> +			  /	\  /     \
> +			sda      sdb      sdc
> +
> +Also consider following cgroup hierarchy
> +
> +				root
> +				/   \
> +			       A     B
> +			      / \    / \
> +			     T1 T2  T3  T4
> +
> +A and B are two cgroups and T1, T2, T3 and T4 are tasks with-in those cgroups.
> +Assuming T1, T2, T3 and T4 are doing IO on lv0 and lv1. These tasks should
> +get their fair share of bandwidth on disks sda, sdb and sdc. There is no
> +IO control on intermediate logical block nodes (lv0, lv1).
> +
> +So if tasks T1 and T2 are doing IO on lv0 and T3 and T4 are doing IO on lv1
> +only, there will not be any contetion for resources between group A and B if
> +IO is going to sda or sdc. But if actual IO gets translated to disk sdb, then
> +IO scheduler associated with the sdb will distribute disk bandwidth to
> +group A and B proportionate to their weight.
> +
> +CFQ already has the notion of fairness and it provides differential disk
> +access based on priority and class of the task. Just that it is flat and
> +with cgroup stuff, it needs to be made hierarchical.
> +
> +Rest of the IO schedulers (noop, deadline and AS) don't have any notion
> +of fairness among various threads.
> +
> +One of the concerns raised with modifying IO schedulers was that we don't
> +want to replicate the code in all the IO schedulers. These patches share
> +the fair queuing code which has been moved to a common layer (elevator
> +layer). Hence we don't end up replicating code across IO schedulers.
> +
> +Design
> +======
> +This patchset primarily uses BFQ (Budget Fair Queuing) code to provide
> +fairness among different IO queues. Fabio and Paolo implemented BFQ which uses
> +B-WF2Q+ algorithm for fair queuing.
> +
> +Why BFQ?
> +
> +- Not sure if weighted round robin logic of CFQ can be easily extended for
> +  hierarchical mode. One of the things is that we can not keep dividing
> +  the time slice of parent group among childrens. Deeper we go in hierarchy
> +  time slice will get smaller.
> +
> +  One of the ways to implement hierarchical support could be to keep track
> +  of virtual time and service provided to queue/group and select a queue/group
> +  for service based on any of the various available algoriths.
> +
> +  BFQ already had support for hierarchical scheduling, taking those patches
> +  was easier.
> +
> +- BFQ was designed to provide tighter bounds/delay w.r.t service provided
> +  to a queue. Delay/Jitter with BFQ is supposed to be O(1).
> +
> +  Note: BFQ originally used amount of IO done (number of sectors) as notion
> +        of service provided. IOW, it tried to provide fairness in terms of
> +        actual IO done and not in terms of actual time disk access was
> +	given to a queue.
> +
> +	This patcheset modified BFQ to provide fairness in time domain because
> +	that's what CFQ does. So idea was try not to deviate too much from
> +	the CFQ behavior initially.
> +
> +	Providing fairness in time domain makes accounting trciky because
> +	due to command queueing, at one time there might be multiple requests
> +	from different queues and there is no easy way to find out how much
> +	disk time actually was consumed by the requests of a particular
> +	queue. More about this in comments in source code.
> +
> +So it is yet to be seen if changing to time domain still retains BFQ gurantees
> +or not.
> +
> +From data structure point of view, one can think of a tree per device, where
> +io groups and io queues are hanging and are being scheduled using B-WF2Q+
> +algorithm. io_queue, is end queue where requests are actually stored and
> +dispatched from (like cfqq).
> +
> +These io queues are primarily created by and managed by end io schedulers
> +depending on its semantics. For example, noop, deadline and AS ioschedulers
> +keep one io queues per cgroup and cfqq keeps one io queue per io_context in
> +a cgroup (apart from async queues).
> +
> +A request is mapped to an io group by elevator layer and which io queue it
> +is mapped to with in group depends on ioscheduler. Currently "current" task
> +is used to determine the cgroup (hence io group) of the request. Down the
> +line we need to make use of bio-cgroup patches to map delayed writes to
> +right group.
> +
> +Going back to old behavior
> +==========================
> +In new scheme of things essentially we are creating hierarchical fair
> +queuing logic in elevator layer and chaning IO schedulers to make use of
> +that logic so that end IO schedulers start supporting hierarchical scheduling.
> +
> +Elevator layer continues to support the old interfaces. So even if fair queuing
> +is enabled at elevator layer, one can have both new hierchical scheduler as
> +well as old non-hierarchical scheduler operating.
> +
> +Also noop, deadline and AS have option of enabling hierarchical scheduling.
> +If it is selected, fair queuing is done in hierarchical manner. If hierarchical
> +scheduling is disabled, noop, deadline and AS should retain their existing
> +behavior.
> +
> +CFQ is the only exception where one can not disable fair queuing as it is
> +needed for provding fairness among various threads even in non-hierarchical
> +mode.
> +
> +Various user visible config options
> +===================================
> +CONFIG_IOSCHED_NOOP_HIER
> +	- Enables hierchical fair queuing in noop. Not selecting this option
> +	  leads to old behavior of noop.
> +
> +CONFIG_IOSCHED_DEADLINE_HIER
> +	- Enables hierchical fair queuing in deadline. Not selecting this
> +	  option leads to old behavior of deadline.
> +
> +CONFIG_IOSCHED_AS_HIER
> +	- Enables hierchical fair queuing in AS. Not selecting this option
> +	  leads to old behavior of AS.
> +
> +CONFIG_IOSCHED_CFQ_HIER
> +	- Enables hierarchical fair queuing in CFQ. Not selecting this option
> +	  still does fair queuing among various queus but it is flat and not
> +	  hierarchical.
> +
> +Config options selected automatically
> +=====================================
> +These config options are not user visible and are selected/deselected
> +automatically based on IO scheduler configurations.
> +
> +CONFIG_ELV_FAIR_QUEUING
> +	- Enables/Disables the fair queuing logic at elevator layer.
> +
> +CONFIG_GROUP_IOSCHED
> +	- Enables/Disables hierarchical queuing and associated cgroup bits.
> +
> +TODO
> +====
> +- Lots of cleanups, testing, bug fixing, optimizations, benchmarking etc...
> +- Convert cgroup ioprio to notion of weight.
> +- Anticipatory code will need more work. It is not working properly currently
> +  and needs more thought.
> +- Use of bio-cgroup patches.
> +- Use of Nauman's per cgroup request descriptor patches.
> +
> +HOWTO
> +=====
> +So far I have done very simple testing of running two dd threads in two
> +different cgroups. Here is what you can do.
> +
> +- Enable hierarchical scheduling in io scheuduler of your choice (say cfq).
> +	CONFIG_IOSCHED_CFQ_HIER=y
> +
> +- Compile and boot into kernel and mount IO controller.
> +
> +	mount -t cgroup -o io none /cgroup
> +
> +- Create two cgroups
> +	mkdir -p /cgroup/test1/ /cgroup/test2
> +
> +- Set io priority of group test1 and test2
> +	echo 0 > /cgroup/test1/io.ioprio
> +	echo 4 > /cgroup/test2/io.ioprio
> +
> +- Create two same size files (say 512MB each) on same disk (file1, file2) and
> +  launch two dd threads in different cgroup to read those files. Make sure
> +  right io scheduler is being used for the block device where files are
> +  present (the one you compiled in hierarchical mode).
> +
> +	echo 1 > /proc/sys/vm/drop_caches
> +
> +	dd if=/mnt/lv0/zerofile1 of=/dev/null &
> +	echo $! > /cgroup/test1/tasks
> +	cat /cgroup/test1/tasks
> +
> +	dd if=/mnt/lv0/zerofile2 of=/dev/null &
> +	echo $! > /cgroup/test2/tasks
> +	cat /cgroup/test2/tasks
> +
> +- First dd should finish first.
> +
> +Some Test Results
> +=================
> +- Two dd in two cgroups with prio 0 and 4. Ran two "dd" in those cgroups.
> +
> +234179072 bytes (234 MB) copied, 10.1811 s, 23.0 MB/s
> +234179072 bytes (234 MB) copied, 12.6187 s, 18.6 MB/s
> +
> +- Three dd in three cgroups with prio 0, 4, 4.
> +
> +234179072 bytes (234 MB) copied, 13.7654 s, 17.0 MB/s
> +234179072 bytes (234 MB) copied, 19.476 s, 12.0 MB/s
> +234179072 bytes (234 MB) copied, 20.1858 s, 11.6 MB/s

Hi Vivek,

I would be interested in knowing if these are the results expected?

-- 
regards,
Dhaval
