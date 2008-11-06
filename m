From: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Subject: [patch 1/4] io controller: documentation
Date: Thu, 06 Nov 2008 10:30:23 -0500
Message-ID: <20081106153135.743458085__32486.5216076889$1225987682$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=bio-group-documentation.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3ieIwRZHo2/mJg@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Index: linux17/Documentation/controllers/io-controller.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux17/Documentation/controllers/io-controller.txt	2008-11-06 09:12:44.000000000 -0500
@@ -0,0 +1,172 @@
+				IO Controller
+				============
+
+Design
+=====
+This patchset implements a basic version of proportional weight IO controller.
+It is heavily derived from dm-ioband IO controller with one key difference
+and that is, there is no separate device mapper driver and there is no
+need to create a dm-ioband device on top of every block device which needs
+to do the IO control. In this implementation, all the control logic has
+been internalized and has been made per request queue. Enabling or disabling
+IO control on a block device is just a matter of writing a 0 or 1 in
+appropriate sysfs file.
+
+This is a proportional weight controller and that means various cgroups
+are assigned shares and tasks in those cgroups get to dispatch the bio
+in proportion to their cgroup share.
+
+All the contending cgroups are assigned tokens proportionate to their
+weights. One token is charged for one sector of IO. Once all the contending
+cgroups have consumed their tokens, fresh token allocation takes place and
+this is how disk bandwidth allocation proportion to weight is achieved.
+
+The bigger picture is that all the bios being submitted to a block device
+are first inspected by IO controller logic (bio_group_controller()), only if
+IO controller has been enabled on that device. The cgroup of the bio is
+determined and controller checks if this cgroup has sufficient tokens to
+dispatch the bio. If sufficient tokens are there, bio submitting thread
+continues to dispatch the bio through normal path otherwise IO controller
+buffers the bio and submitting thread returns back. These buffered bios
+are dispatched to lower layers later once the associate group (bio group)
+has sufficient tokens to dispatch the bios. This delayed dispatching is
+done with the help of a worker thread (biogroup).
+
+IO control can be enabled/disabled dynamically on any of the block device
+through sysfs file system. For example, to enable IO control on a device
+do following.
+
+echo 1 > /sys/block/sda/biogroup
+
+To disable IO control write 0.
+
+echo 0 > /sys/block/sda/biogroup
+
+This should be doable for any of the block device in the stack. Currently this
+patch places the hooks only for device mapper driver and still need to tweak
+md.
+
+For example, assume there are two cgroups A and B with weights 1024 and 2048
+in the system. Tasks in two cgroups A and B are doing IO to two disks sda and
+sdb in the system. A user has enabled IO control on both sda and sdb. Now on
+both sda and sdb, tasks in cgroup B will get to use 2/3 of disk BW and
+tasks in cgroup A will get to use 1/3 of disk bandwidth, only in case of
+contention. If tasks in any of the groups stop doing IO to a particular disk,
+task in other group will get to use full disk BW for that duration.
+
+
+HOWTO
+====
+- Enable cgroup, memory controller and block IO controller in kernel config
+  file.
+
+- Boot into the kernel and mount io controller.
+
+  mount -t cgroup -o bio none /cgroup/bio/
+
+- Create two cgroups test1 and test2
+
+  cd /cgroup/bio
+  mkdir test1 test2
+
+- Allocate weight 4096 to test1 and weight 2048 to test2
+
+  echo 4096 > /cgroup/bio/test1/bio.shares
+  echo 2048 > /cgroup/bio/test1/bio.shares
+
+- Launch "dd" operations in cgroup test1 and test2.
+
+  echo $$ > /cgroup/bio/test1/tasks
+  dd if=/somefile1 of=/dev/null
+  echo $$ > /cgroup/bio/test2/tasks
+  dd if=/somefile2 of=/dev/null
+
+Job in cgroup test1 should finish before job in cgroup test2. To verify
+that "dd" in cgroup test1 got to dispatch more bio as compared to "dd" in
+test2, look at "bio.aggregate_tokens" in both the cgroup (At same time). At
+any point of time when both the dd's are running, aggregate_tokens in cgroup
+test1 should be approximately double of aggregate_tokens in cgroup test2
+(Because weight of cgroup test1 is double of weight of cgroup test2).
+
+Some Tunables
+=============
+Some tunables appear in cgroup file system and in sysfs for respective
+device for debug and for configuration. Here is a brief description.
+
+Cgroup Files
+============
+bio.shares
+	Specifies the weight of the cgroup.
+
+bio.aggregate_tokens
+	Specifies total number of tokens dispatched by this cgroup. One token
+	represents one sector of IO.
+
+bio.jiffies
+	What was the jiffies values when last bio from this cgroup was released.
+
+bio.nr_token_slices
+	How many times this cgroup got the token allocation done from token
+	slice. We kind of create a token slice and every contending cgroup
+	gets the pie out of the slice based on the share.
+
+bio.nr_off_the_tree
+	How many times this bio group went off the list of contending groups.
+	We maintain an rb-tree of biogroups contending for IO and token
+	allocation takes place to these groups regularly. If some group stops
+	doing IO then it is considered to be idle and removed from the tree
+	and added back later when group has IO to perform. This file just
+	counts how many times this bio group went off the tree.
+
+Sysfs Tunabels
+==============
+/sys/block/{deice name}/biogroup
+	Whether IO controller (bio groups) are active on this device or not.
+
+/sys/block/{deice name}/deftoken
+	Default number of tokens which are given to a bio group upon start
+	if all the bio groups were of same weight. token slice is of dynamic
+	length. So if there are 3 cgroups contending and deftoken is 100 then
+	token slice lenght will be 100*3 = 300 and now out of this slice
+	three groups will get the tokens based on their weights.
+
+/sys/block/{deice name}/idletime
+	The time after which if a bio group does not generate the bio, it is
+	considered idle and removed from the rb-tree. Currently by default it
+	is 8ms.
+
+/sys/block/{deice name}/newslice_count
+	How many times new token allocation took place on this queue.
+
+TODO
+====
+- Do extensive testing in various scenarios and do performance optimization
+  and fix the things where broken.
+
+- IO schedulers derive context information from "current". This assumption
+  will be broken if bios are being submitted by a worker thread (biogroup).
+  Probably we need to put io context pointer in bio itself to get rid of
+  this dependency.
+
+- Allocating tokens for per sector of IO is crude approximation and will lead
+  to unfair bandwidth allocation in case task in cgroup is doing sequential IO
+  and task in other group is doing random IO. Rik Van Riel, suggested that
+  probably we should switch to time based scheme. Keep a track of average time
+  it takes to complete IO from a cgroup and do the allocation accordingly.
+
+- Currently this controller is dependent on memory controller being enabled.
+  Try to reduce this coupling.
+
+ISSUES
+======
+- IO controller can buffer the bios if suffcient tokens were not available
+  at the time of bio submission. Once the tokens are available, these bios
+  are dispatched to elevator/lower layers in first come first serve manner.
+  And this has potential to break CFQ where a RT tasks should be able to
+  dispatch the bio first or a high priority task should be able to release
+  more bio as compared to low priority task in same cgroup.
+
+  Not sure how to fix it. May be we need to maintain another rb-tree and
+  keep track of RT tasks and tasks priorities and dispatch accordingly. This
+  is equivalent of duplicating lots of CFQ logic and not sure how would it
+  impact AS behaviour.

-- 
