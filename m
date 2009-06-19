From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO scheduler based io controller (V5)
Date: Fri, 19 Jun 2009 16:37:18 -0400
Message-ID: <1245443858-8487-1-git-send-email-vgoyal__41576.5572376133$1245445119$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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


Hi All,

Here is the V5 of the IO controller patches generated on top of 2.6.30.

Previous versions of the patches was posted here.

(V1) http://lkml.org/lkml/2009/3/11/486
(V2) http://lkml.org/lkml/2009/5/5/275
(V3) http://lkml.org/lkml/2009/5/26/472
(V4) http://lkml.org/lkml/2009/6/8/580

This patchset is still work in progress but I want to keep on getting the
snapshot of my tree out at regular intervals to get the feedback hence V5.

Changes from V4
===============
- Implemented bdi_*_congested_group() functions to also determine if a
  particular io group on a bdi is congested or not. So far we only used
  determine whether bdi is congested or not. But now there is one request
  list per group and one also needs to check whether the particular
  io group io is going into is congested or not.

- Fixed preemption logic in hiearchical mode. In hiearchical mode, one
  needs to traverse up the hiearchy so that current queue and new queue
  are at same level to make a decision whether preeption should be done
  or not. Took the idea and code from CFS cpu scheduler.

- There were some tunables which were appearing under
  /sys/block/<device>/queue dir but these tunables actually belonged to
  ioschedulers in hierarhical moded. Fixed it.
 
- Fixed another preemption issue where if any RT queue was pending
  (busy_rt_queues), current queue was being expired. Now this preemption is
  done only if there are busy_rt_queues in the same group.

  (Though I think that busy_rt_queues is redundant code as the moment RT
   request comes, we preempt the BE queue so we should never run into the
   issue of RT reuqest pending while BE is running. Keeping the code for the
   time being). 
 
- Applied the patch from Gui where he got rid of only_root_group code and
  now used cgroups children list to determine if root group is only group
  or there are childrens too.

- Applied few cleanup patches from Gui.

- We store the device id (major, minor) in io group. Previously I was
  retrieving that info from bio. Switched to gettting that info from
  backing device.

Limitations
===========

- This IO controller provides the bandwidth control at the IO scheduler
  level (leaf node in stacked hiearchy of logical devices). So there can
  be cases (depending on configuration) where application does not see
  proportional BW division at higher logical level device.

  LWN has written an article about the issue here.

	http://lwn.net/Articles/332839/

How to solve the issue of fairness at higher level logical devices
==================================================================
Couple of suggestions have come forward.

- Implement IO control at IO scheduler layer and then with the help of
  some daemon, adjust the weight on underlying devices dynamiclly, depending
  on what kind of BW gurantees are to be achieved at higher level logical
  block devices.

- Also implement a higher level IO controller along with IO scheduler
  based controller and let user choose one depending on his needs.

  A higher level controller does not know about the assumptions/policies
  of unerldying IO scheduler, hence it has the potential to break down
  the IO scheduler's policy with-in cgroup. A lower level controller
  can work with IO scheduler much more closely and efficiently.
 
Other active IO controller developments
=======================================

IO throttling
-------------

  This is a max bandwidth controller and not the proportional one. Secondly
  it is a second level controller which can break the IO scheduler's
  policy/assumtions with-in cgroup. 

dm-ioband
---------

 This is a proportional bandwidth controller implemented as device mapper
 driver. It is also a second level controller which can break the
 IO scheduler's policy/assumptions with-in cgroup.

Testing
=======

I have been able to do only very basic testing of reads and writes.

Test1 (Fairness for synchronous reads)
======================================
- Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
  cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)

dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &

234179072 bytes (234 MB) copied, 3.9065 s, 59.9 MB/s
234179072 bytes (234 MB) copied, 5.19232 s, 45.1 MB/s

group1 time=8 16 2471 group1 sectors=8 16 457840
group2 time=8 16 1220 group2 sectors=8 16 225736

First two fields in time and sectors statistics represent major and minor
number of the device. Third field represents disk time in milliseconds and
number of sectors transferred respectively.

This patchset tries to provide fairness in terms of disk time received. group1
got almost double of group2 disk time (At the time of first dd finish). These
time and sectors statistics can be read using io.disk_time and io.disk_sector
files in cgroup. More about it in documentation file.

Test2 (Fairness for async writes)
=================================
Fairness for async writes is tricky and biggest reason is that async writes
are cached in higher layers (page cahe) as well as possibly in file system
layer also (btrfs, xfs etc), and are dispatched to lower layers not necessarily
in proportional manner.

For example, consider two dd threads reading /dev/zero as input file and doing
writes of huge files. Very soon we will cross vm_dirty_ratio and dd thread will
be forced to write out some pages to disk before more pages can be dirtied. But
not necessarily dirty pages of same thread are picked. It can very well pick
the inode of lesser priority dd thread and do some writeout. So effectively
higher weight dd is doing writeouts of lower weight dd pages and we don't see
service differentation.

IOW, the core problem with async write fairness is that higher weight thread
does not throw enought IO traffic at IO controller to keep the queue
continuously backlogged. In my testing, there are many .2 to .8 second
intervals where higher weight queue is empty and in that duration lower weight
queue get lots of job done giving the impression that there was no service
differentiation.

In summary, from IO controller point of view async writes support is there.
Because page cache has not been designed in such a manner that higher 
prio/weight writer can do more write out as compared to lower prio/weight
writer, gettting service differentiation is hard and it is visible in some
cases and not visible in some cases.

To get fairness for async writes in all cases, higher layer needs to be
fixed. That probably is a lot of work. Do we really care that much for
fairness among two writer cgroups? One can choose to do direct IO if
fairness for buffered writes really matters for him. I think we care more
for fairness in following cases and with this patch we should be able to
achive that.

- Read Vs Read
- Read Vs Writes (Buffered writes or direct IO writes)
	- Making sure that isolation is achieved between reader and writer
	  cgroup.  
- All form of direct IO.

Following is the only case where it is hard to ensure fairness between cgroups
because of higher layer design.

- Buffered writes Vs Buffered Writes.

So to test async writes I generated lots of write traffic in two cgroups (50
fio threads) and watched the disk time statistics in respective cgroups at
the interval of 2 seconds. Thanks to ryo tsuruta for the test case.

*****************************************************************
sync
echo 3 > /proc/sys/vm/drop_caches

fio_args="--size=64m --rw=write --numjobs=50 --group_reporting"

echo $$ > /cgroup/bfqio/test1/tasks
fio $fio_args --name=test1 --directory=/mnt/sdd1/fio/ --output=/mnt/sdd1/fio/test1.log &

echo $$ > /cgroup/bfqio/test2/tasks
fio $fio_args --name=test2 --directory=/mnt/sdd2/fio/ --output=/mnt/sdd2/fio/test2.log &
*********************************************************************** 

And watched the disk time and sector statistics for the both the cgroups
every 2 seconds using a script. How is snippet from output.

test1 statistics: time=8 48 1315   sectors=8 48 55776 dq=8 48 1
test2 statistics: time=8 48 633   sectors=8 48 14720 dq=8 48 2

test1 statistics: time=8 48 5586   sectors=8 48 339064 dq=8 48 2
test2 statistics: time=8 48 2985   sectors=8 48 146656 dq=8 48 3

test1 statistics: time=8 48 9935   sectors=8 48 628728 dq=8 48 3
test2 statistics: time=8 48 5265   sectors=8 48 278688 dq=8 48 4

test1 statistics: time=8 48 14156   sectors=8 48 932488 dq=8 48 6
test2 statistics: time=8 48 7646   sectors=8 48 412704 dq=8 48 7

test1 statistics: time=8 48 18141   sectors=8 48 1231488 dq=8 48 10
test2 statistics: time=8 48 9820   sectors=8 48 548400 dq=8 48 8

test1 statistics: time=8 48 21953   sectors=8 48 1485632 dq=8 48 13
test2 statistics: time=8 48 12394   sectors=8 48 698288 dq=8 48 10

test1 statistics: time=8 48 25167   sectors=8 48 1705264 dq=8 48 13
test2 statistics: time=8 48 14042   sectors=8 48 817808 dq=8 48 10

First two fields in time and sectors statistics represent major and minor
number of the device. Third field represents disk time in milliseconds and
number of sectors transferred respectively.

So disk time consumed by group1 is almost double of group2.

TODO
====
- Lots of code cleanups, testing, bug fixing, optimizations, benchmarking
  etc...

- Work on a better interface (possibly cgroup based) for configuring per
  group request descriptor limits.

- Debug and fix some of the areas like page cache where higher weight cgroup
  async writes are stuck behind lower weight cgroup async writes.

Thanks
Vivek
