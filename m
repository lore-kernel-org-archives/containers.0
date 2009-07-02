From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 01/25] io-controller: Documentation
Date: Thu,  2 Jul 2009 16:01:33 -0400
Message-ID: <1246564917-19603-2-git-send-email-vgoyal__28981.1926697896$1246568137$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246564917-19603-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o Documentation for io-controller.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 Documentation/block/00-INDEX          |    2 +
 Documentation/block/io-controller.txt |  378 +++++++++++++++++++++++++++++++++
 2 files changed, 380 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/block/io-controller.txt

diff --git a/Documentation/block/00-INDEX b/Documentation/block/00-INDEX
index 961a051..dc8bf95 100644
--- a/Documentation/block/00-INDEX
+++ b/Documentation/block/00-INDEX
@@ -10,6 +10,8 @@ capability.txt
 	- Generic Block Device Capability (/sys/block/<disk>/capability)
 deadline-iosched.txt
 	- Deadline IO scheduler tunables
+io-controller.txt
+	- IO controller for provding hierarchical IO scheduling
 ioprio.txt
 	- Block io priorities (in CFQ scheduler)
 request.txt
diff --git a/Documentation/block/io-controller.txt b/Documentation/block/io-controller.txt
new file mode 100644
index 0000000..b2a96b3
--- /dev/null
+++ b/Documentation/block/io-controller.txt
@@ -0,0 +1,378 @@
+				IO Controller
+				=============
+
+Overview
+========
+
+This patchset implements a proportional weight IO controller. That is one
+can create cgroups and assign prio/weights to those cgroups and task group
+will get access to disk proportionate to the weight of the group.
+
+These patches modify elevator layer and individual IO schedulers to do
+IO control hence this io controller works only on block devices which use
+one of the standard io schedulers can not be used with any xyz logical block
+device.
+
+The assumption/thought behind modifying IO scheduler is that resource control
+is needed only on leaf nodes where the actual contention for resources is
+present and not on intertermediate logical block devices.
+
+Consider following hypothetical scenario. Lets say there are three physical
+disks, namely sda, sdb and sdc. Two logical volumes (lv0 and lv1) have been
+created on top of these. Some part of sdb is in lv0 and some part is in lv1.
+
+			    lv0      lv1
+			  /	\  /     \
+			sda      sdb      sdc
+
+Also consider following cgroup hierarchy
+
+				root
+				/   \
+			       A     B
+			      / \    / \
+			     T1 T2  T3  T4
+
+A and B are two cgroups and T1, T2, T3 and T4 are tasks with-in those cgroups.
+Assuming T1, T2, T3 and T4 are doing IO on lv0 and lv1. These tasks should
+get their fair share of bandwidth on disks sda, sdb and sdc. There is no
+IO control on intermediate logical block nodes (lv0, lv1).
+
+So if tasks T1 and T2 are doing IO on lv0 and T3 and T4 are doing IO on lv1
+only, there will not be any contetion for resources between group A and B if
+IO is going to sda or sdc. But if actual IO gets translated to disk sdb, then
+IO scheduler associated with the sdb will distribute disk bandwidth to
+group A and B proportionate to their weight.
+
+CFQ already has the notion of fairness and it provides differential disk
+access based on priority and class of the task. Just that it is flat and
+with cgroup stuff, it needs to be made hierarchical to achive a good
+hierarchical control on IO.
+
+Rest of the IO schedulers (noop, deadline and AS) don't have any notion
+of fairness among various threads. They maintain only one queue where all
+the IO gets queued (internally this queue is split in read and write queue
+for deadline and AS). With this patchset, now we maintain one queue per
+cgropu per device and then try to do fair queuing among those queues.
+
+One of the concerns raised with modifying IO schedulers was that we don't
+want to replicate the code in all the IO schedulers. These patches share
+the fair queuing code which has been moved to a common layer (elevator
+layer). Hence we don't end up replicating code across IO schedulers. Following
+diagram depicts the concept.
+
+			--------------------------------
+			| Elevator Layer + Fair Queuing |
+			--------------------------------
+			 |	     |	     |       |
+			NOOP     DEADLINE    AS     CFQ
+
+Design
+======
+This patchset primarily uses BFQ (Budget Fair Queuing) code to provide
+fairness among different IO queues. Fabio and Paolo implemented BFQ which uses
+B-WF2Q+ algorithm for fair queuing.
+
+Why BFQ?
+
+- Not sure if weighted round robin logic of CFQ can be easily extended for
+  hierarchical mode. One of the things is that we can not keep dividing
+  the time slice of parent group among childrens. Deeper we go in hierarchy
+  time slice will get smaller.
+
+  One of the ways to implement hierarchical support could be to keep track
+  of virtual time and service provided to queue/group and select a queue/group
+  for service based on any of the various available algoriths.
+
+  BFQ already had support for hierarchical scheduling, taking those patches
+  was easier.
+
+- BFQ was designed to provide tighter bounds/delay w.r.t service provided
+  to a queue. Delay/Jitter with BFQ is O(1).
+
+  Note: BFQ originally used amount of IO done (number of sectors) as notion
+        of service provided. IOW, it tried to provide fairness in terms of
+        actual IO done and not in terms of actual time disk access was
+	given to a queue.
+
+	This patcheset modified BFQ to provide fairness in time domain because
+	that's what CFQ does. So idea was try not to deviate too much from
+	the CFQ behavior initially.
+
+	Providing fairness in time domain makes accounting trciky because
+	due to command queueing, at one time there might be multiple requests
+	from different queues and there is no easy way to find out how much
+	disk time actually was consumed by the requests of a particular
+	queue. More about this in comments in source code.
+
+We have taken BFQ code as starting point for providing fairness among groups
+because it already contained lots of features which we required to implement
+hierarhical IO scheduling. With this patch set, I am not trying to ensure O(1)
+delay here as my goal is to provide fairness among groups. Most likely that
+will mean that latencies are not worse than what cfq currently provides (if
+not improved ones). Once fairness is ensured, one can look into  more in
+ensuring O(1) latencies.
+
+From data structure point of view, one can think of a tree per device, where
+io groups and io queues are hanging and are being scheduled using B-WF2Q+
+algorithm. io_queue, is end queue where requests are actually stored and
+dispatched from (like cfqq).
+
+These io queues are primarily created by and managed by end io schedulers
+depending on its semantics. For example, noop, deadline and AS ioschedulers
+keep one io queues per cgroup and cfqq keeps one io queue per io_context in
+a cgroup (apart from async queues).
+
+A request is mapped to an io group by elevator layer and which io queue it
+is mapped to with in group depends on ioscheduler. Currently "current" task
+is used to determine the cgroup (hence io group) of the request. Down the
+line we need to make use of bio-cgroup patches to map delayed writes to
+right group.
+
+Going back to old behavior
+==========================
+In new scheme of things essentially we are creating hierarchical fair
+queuing logic in elevator layer and chaning IO schedulers to make use of
+that logic so that end IO schedulers start supporting hierarchical scheduling.
+
+Elevator layer continues to support the old interfaces. So even if fair queuing
+is enabled at elevator layer, one can have both new hierchical scheduler as
+well as old non-hierarchical scheduler operating.
+
+Also noop, deadline and AS have option of enabling hierarchical scheduling.
+If it is selected, fair queuing is done in hierarchical manner. If hierarchical
+scheduling is disabled, noop, deadline and AS should retain their existing
+behavior.
+
+CFQ is the only exception where one can not disable fair queuing as it is
+needed for provding fairness among various threads even in non-hierarchical
+mode.
+
+Various user visible config options
+===================================
+CONFIG_IOSCHED_NOOP_HIER
+	- Enables hierchical fair queuing in noop. Not selecting this option
+	  leads to old behavior of noop.
+
+CONFIG_IOSCHED_DEADLINE_HIER
+	- Enables hierchical fair queuing in deadline. Not selecting this
+	  option leads to old behavior of deadline.
+
+CONFIG_IOSCHED_AS_HIER
+	- Enables hierchical fair queuing in AS. Not selecting this option
+	  leads to old behavior of AS.
+
+CONFIG_IOSCHED_CFQ_HIER
+	- Enables hierarchical fair queuing in CFQ. Not selecting this option
+	  still does fair queuing among various queus but it is flat and not
+	  hierarchical.
+
+CGROUP_BLKIO
+	- This option enables blkio-cgroup controller for IO tracking
+	  purposes. That means, by this controller one can attribute a write
+	  to the original cgroup and not assume that it belongs to submitting
+	  thread.
+
+CONFIG_TRACK_ASYNC_CONTEXT
+	- Currently CFQ attributes the writes to the submitting thread and
+	  caches the async queue pointer in the io context of the process.
+	  If this option is set, it tells cfq and elevator fair queuing logic
+	  that for async writes make use of IO tracking patches and attribute
+	  writes to original cgroup and not to write submitting thread.
+
+CONFIG_DEBUG_GROUP_IOSCHED
+	- Throws extra debug messages in blktrace output helpful in doing
+	  doing debugging in hierarchical setup.
+
+	- Also allows for export of extra debug statistics like group queue
+	  and dequeue statistics on device through cgroup interface.
+
+Config options selected automatically
+=====================================
+These config options are not user visible and are selected/deselected
+automatically based on IO scheduler configurations.
+
+CONFIG_ELV_FAIR_QUEUING
+	- Enables/Disables the fair queuing logic at elevator layer.
+
+CONFIG_GROUP_IOSCHED
+	- Enables/Disables hierarchical queuing and associated cgroup bits.
+
+HOWTO
+=====
+So far I have done very simple testing of running two dd threads in two
+different cgroups. Here is what you can do.
+
+- Enable hierarchical scheduling in io scheuduler of your choice (say cfq).
+	CONFIG_IOSCHED_CFQ_HIER=y
+
+- Enable IO tracking for async writes.
+	CONFIG_TRACK_ASYNC_CONTEXT=y
+
+  (This will automatically select CGROUP_BLKIO)
+
+- Compile and boot into kernel and mount IO controller and blkio io tracking
+  controller.
+
+	mount -t cgroup -o io,blkio none /cgroup
+
+- Create two cgroups
+	mkdir -p /cgroup/test1/ /cgroup/test2
+
+- Set weights of group test1 and test2
+	echo 1000 > /cgroup/test1/io.weight
+	echo 500 > /cgroup/test2/io.weight
+
+- Set "fairness" parameter to 1 at the disk you are testing.
+
+  echo 1 > /sys/block/<disk>/queue/iosched/fairness
+
+- Create two same size files (say 512MB each) on same disk (file1, file2) and
+  launch two dd threads in different cgroup to read those files. Make sure
+  right io scheduler is being used for the block device where files are
+  present (the one you compiled in hierarchical mode).
+
+	sync
+	echo 3 > /proc/sys/vm/drop_caches
+
+	dd if=/mnt/sdb/zerofile1 of=/dev/null &
+	echo $! > /cgroup/test1/tasks
+	cat /cgroup/test1/tasks
+
+	dd if=/mnt/sdb/zerofile2 of=/dev/null &
+	echo $! > /cgroup/test2/tasks
+	cat /cgroup/test2/tasks
+
+- At macro level, first dd should finish first. To get more precise data, keep
+  on looking at (with the help of script), at io.disk_time and io.disk_sectors
+  files of both test1 and test2 groups. This will tell how much disk time
+  (in milli seconds), each group got and how many secotors each group
+  dispatched to the disk. We provide fairness in terms of disk time, so
+  ideally io.disk_time of cgroups should be in proportion to the weight.
+  (It is hard to achieve though :-)).
+
+Regarding "fairness" parameter
+==============================
+IO controller has introduced a "fairness" tunable for every io scheduler.
+Currently this tunable can assume values 0, 1 and 2.
+
+There are places where io schedulers are geared towards throughput. Sometimes
+fairness and throughput don't go together. This tunable helps choose fairness
+over throughput depending on the need.
+
+0 --> We should achive existing io scheduler behavior. Some of the special
+      fairness hooks are disabled.
+
+1 --> Helps in achieving the better fairness for sync queues.
+
+2 --> If buffered writes come into play, use this. For example, One cgroup
+      doing sync reads and other cgroup doing buffered writes, use "2" to
+      provide better fairness/isolation between two cgroups.
+
+Details of cgroup files
+=======================
+- io.ioprio_class
+	- Specifies class of the cgroup (RT, BE, IDLE). This is default io
+	  class of the group on all the devices until and unless overridden by
+	  per device rule. (See io.policy).
+
+	  1 = RT; 2 = BE, 3 = IDLE
+
+- io.weight
+	- Specifies per cgroup weight. This is default weight of the group
+	  on all the devices until and unless overridden by per device rule.
+	  (See io.policy).
+
+- io.disk_time
+	- disk time allocated to cgroup per device in milliseconds. First
+	  two fields specify the major and minor number of the device and
+	  third field specifies the disk time allocated to group in
+	  milliseconds.
+
+- io.disk_sectors
+	- number of sectors transferred to/from disk by the group. First
+	  two fields specify the major and minor number of the device and
+	  third field specifies the number of sectors transferred by the
+	  group to/from the device.
+
+- io.disk_queue
+	- Debugging aid only enabled if CONFIG_DEBUG_GROUP_IOSCHED=y. This
+	  gives the statistics about how many a times a group was queued
+	  on service tree of the device. First two fields specify the major
+	  and minor number of the device and third field specifies the number
+	  of times a group was queued on a particular device.
+
+- io.disk_queue
+	- Debugging aid only enabled if CONFIG_DEBUG_GROUP_IOSCHED=y. This
+	  gives the statistics about how many a times a group was de-queued
+	  or removed from the service tree of the device. This basically gives
+	  and idea if we can generate enough IO to create continuously
+	  backlogged groups. First two fields specify the major and minor
+	  number of the device and third field specifies the number
+	  of times a group was de-queued on a particular device.
+
+- io.policy
+	- One can specify per cgroup per device rules using this interface.
+	  These rules override the default value of group weight and class as
+	  specified by io.weight and io.ioprio_class.
+
+	  Following is the format.
+
+	#echo dev_maj:dev_minor weight ioprio_class > /patch/to/cgroup/io.policy
+
+	weight=0 means removing a policy.
+
+	Examples:
+
+	Configure weight=300 ioprio_class=2 on /dev/hdb (8:16) in this cgroup
+	# echo 8:16 300 2 > io.policy
+	# cat io.policy
+	dev	weight	class
+	8:16	300	2
+
+	Configure weight=500 ioprio_class=1 on /dev/hda (8:0) in this cgroup
+	# echo 8:0 500 1 > io.policy
+	# cat io.policy
+	dev	weight	class
+	8:0	500	1
+	8:16	300	2
+
+	Remove the policy for /dev/hda in this cgroup
+	# echo 8:0 0 1 > io.policy
+	# cat io.policy
+	dev	weight	class
+	8:16	300	2
+
+About configuring request desriptors
+====================================
+Traditionally there are 128 request desriptors allocated per request queue
+where io scheduler is operating (/sys/block/<disk>/queue/nr_requests). If these
+request descriptors are exhausted, processes will put to sleep and woken
+up once request descriptors are available.
+
+With io controller and cgroup stuff, one can not afford to allocate requests
+from single pool as one group might allocate lots of requests and then tasks
+from other groups might be put to sleep and this other group might be a
+higher weight group. Hence to make sure that a group always can get the
+request descriptors it is entitled to, one needs to make request descriptor
+limit per group on every queue.
+
+A new parameter /sys/block/<disk>/queue/nr_group_requests has been introduced
+and this parameter controlls the maximum number of requests per group.
+nr_requests still continues to control total number of request descriptors
+on the queue.
+
+Ideally one should set nr_requests to be following.
+
+nr_requests = number_of_cgroups * nr_group_requests
+
+This will make sure that at any point of time nr_group_requests number of
+request descriptors will be available for any of the cgroups.
+
+Currently default nr_requests=512 and nr_group_requests=128. This will make
+sure that apart from root group one can create 3 more group without running
+into any issues. If one decides to create more cgorus, nr_requests and
+nr_group_requests should be adjusted accordingly.
+
+Probably a better way to assign limit to group request descriptors is through
+sysfs interface. This is a future TODO item.
-- 
1.6.0.6
