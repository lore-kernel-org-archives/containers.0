From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO scheduler based IO controller V6
Date: Thu,  2 Jul 2009 16:01:32 -0400
Message-ID: <1246564917-19603-1-git-send-email-vgoyal__17741.9406282299$1246567930$gmane$org@redhat.com>
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

Here is the V6 of the IO controller patches generated on top of 2.6.31-rc1.

Previous versions of the patches was posted here.

(V1) http://lkml.org/lkml/2009/3/11/486
(V2) http://lkml.org/lkml/2009/5/5/275
(V3) http://lkml.org/lkml/2009/5/26/472
(V4) http://lkml.org/lkml/2009/6/8/580
(V5) http://lkml.org/lkml/2009/6/19/279

This patchset is still work in progress but I want to keep on getting the
snapshot of my tree out at regular intervals to get the feedback hence V6.

Changes from V5
===============
- Broke down two of the biggest patches in to smaller patches. Now core of
  bfq scheduler patches are separate patch and it should make review a bit
  easier. I will try to break the patches down even more.

	- Broke out bfq core scheduler changes from flat fair queuing code.
	- Created separate patch for in class preemtion logic.
	- Created separate patch to for core bfq hierarchical scheduler
	  changes. 
	- Created a separate patch for cgroup related bits.

- Introduced a new patch to wait for requests to complete from previous
  queue before next queue is scheduled. It helps in achieving better
  accounting of disk time used by writes and hence better isolation between
  reads and buffered writes. This helps achieve fairness between sync queues
  and buffered writes.

- Merged gui's patch for optimization during io group deletion.

- Merged gui's per device rule interface patch resulting from Paul Menage's
  feedback.

- Merged gui's patch to read group data under rcu lock instead of taking
  spin lock.

- Took care of some of the balbir's review comments on V5.

	- Got rid of additional user defined data tyepes. "bfq_timestamp_t",
	  bfq_weight_t and bfq_service_t.
	- Changed data type of "weight" to unsigned int.
	- replaced *_extract() function names with *_remove().
	- Renamed some of the bfq_* functions to io_* in comments.

- Misc code cleanups

	- Moved io_get_io_group() and other common changes from patch
	  "implement per group bdi congestion interface" to upper patches.
	- Made lots of functions static.
	- Got rid of some forward declarations.
	- Replaced rq_ioq() with req_ioq() and moved it to blkdev.h
	- Some comment cleanups.
	- Got rid of elv_ioq_set_slice_end()
	- Got rid of redundant declaration of io_disconnect_groups().
	- Got rid of io_group_ioq()

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

TODO
====
- Lots of code cleanups, testing, bug fixing, optimizations, benchmarking
  etc...

- Improve time keeping so that sub jiffy queue expiry time can be accounted
  for.

- Work on a better interface (possibly cgroup based) for configuring per
  group request descriptor limits.

- Debug and fix some of the areas like page cache where higher weight cgroup
  async writes are stuck behind lower weight cgroup async writes.

Testing
=======

I have been able to do some testing as follows. All my testing is with ext3
file system with a SATA drive which supports queue depth of 31.

Test1 (Fairness for synchronous reads)
======================================
- Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
  cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)

  Higher weight dd finishes first and at that point of time my script takes
  care of reading cgroup files io.disk_time and io.disk_sectors for both the
  groups and display the results.

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

Test2 (Reader Vs Buffered Writes)
================================
Buffered writes can be problematic and can overwhelm readers, especially with
noop and deadline. IO controller can provide isolation between readers and
buffered (async) writers.

First I ran the test without io controller to see the severity of the issue.
Ran a hostile writer and then after 10 seconds started a reader and then
monitored the completion time of reader. Reader reads a 256 MB file. Tested
this with noop scheduler.

sample script
------------
sync
echo 3 > /proc/sys/vm/drop_caches
time dd if=/dev/zero of=/mnt/sdb/reader-writer-zerofile bs=4K count=2097152
conv=fdatasync &
sleep 10
time dd if=/mnt/sdb/256M-file of=/dev/null &

Results
-------
8589934592 bytes (8.6 GB) copied, 106.045 s, 81.0 MB/s (Writer)
268435456 bytes (268 MB) copied, 96.5237 s, 2.8 MB/s (Reader)

Now it was time to test io controller whether it can provide isolation between
readers and writers with noop. I created two cgroups of weight 1000 each and
put reader in group1 and writer in group 2 and ran the test again. Upon
comletion of reader, my scripts read io.dis_time and io.disk_group cgroup
files to get an estimate how much disk time each group got and how many
sectors each group did IO for. 

For more accurate accounting of disk time for buffered writes with queuing
hardware I had to set /sys/block/<disk>/queue/iosched/fairness to "2".

sample script
-------------
echo $$ > /cgroup/bfqio/test2/tasks
dd if=/dev/zero of=/mnt/$BLOCKDEV/testzerofile bs=4K count=2097152 &
sleep 10
echo noop > /sys/block/$BLOCKDEV/queue/scheduler
echo  2 > /sys/block/$BLOCKDEV/queue/iosched/fairness
echo $$ > /cgroup/bfqio/test1/tasks
dd if=/mnt/$BLOCKDEV/256M-file of=/dev/null &
wait $!
# Some code for reading cgroup files upon completion of reader.
-------------------------

Results
=======
268435456 bytes (268 MB) copied, 6.65819 s, 40.3 MB/s (Reader) 

group1 time=8 16 3063	group1 sectors=8 16 524808
group2 time=8 16 3071	group2 sectors=8 16 441752

Note, reader finishes now much lesser time and both group1 and group2
got almost 3 seconds of disk time. Hence io-controller provides isolation
from buffered writes.

Test3 (AIO)
===========

AIO reads
-----------
Set up two fio, AIO read jobs in two cgroup with weight 1000 and 500
respectively. I am using cfq scheduler. Following are some lines from my test
script.

---------------------------------------------------------------
echo 1000 > /cgroup/bfqio/test1/io.weight
echo 500 > /cgroup/bfqio/test2/io.weight

fio_args="--ioengine=libaio --rw=read --size=512M --direct=1"
echo 1 > /sys/block/$BLOCKDEV/queue/iosched/fairness

echo $$ > /cgroup/bfqio/test1/tasks
fio $fio_args --name=test1 --directory=/mnt/$BLOCKDEV/fio1/
--output=/mnt/$BLOCKDEV/fio1/test1.log
--exec_postrun="../read-and-display-group-stats.sh $maj_dev $minor_dev" &

echo $$ > /cgroup/bfqio/test2/tasks
fio $fio_args --name=test2 --directory=/mnt/$BLOCKDEV/fio2/
--output=/mnt/$BLOCKDEV/fio2/test2.log &
----------------------------------------------------------------

test1 and test2 are two groups with weight 1000 and 500 respectively.
"read-and-display-group-stats.sh" is one small script which reads the
test1 and test2 cgroup files to determine how much disk time each group
got till first fio job finished.

Results
------
test1 statistics: time=8 16 22403   sectors=8 16 1049640
test2 statistics: time=8 16 11400   sectors=8 16 552864

Above shows that by the time first fio (higher weight), finished, group
test1 got 22403 ms of disk time and group test2 got 11400 ms of disk time.
similarly the statistics for number of sectors transferred are also shown.

Note that disk time given to group test1 is almost double of group2 disk
time.

AIO writes
----------
Set up two fio, AIO direct write jobs in two cgroup with weight 1000 and 500
respectively. I am using cfq scheduler. Following are some lines from my test
script.

------------------------------------------------
echo 1000 > /cgroup/bfqio/test1/io.weight
echo 500 > /cgroup/bfqio/test2/io.weight
fio_args="--ioengine=libaio --rw=write --size=512M --direct=1"

echo 1 > /sys/block/$BLOCKDEV/queue/iosched/fairness

echo $$ > /cgroup/bfqio/test1/tasks
fio $fio_args --name=test1 --directory=/mnt/$BLOCKDEV/fio1/
--output=/mnt/$BLOCKDEV/fio1/test1.log
--exec_postrun="../read-and-display-group-stats.sh $maj_dev $minor_dev" &

echo $$ > /cgroup/bfqio/test2/tasks
fio $fio_args --name=test2 --directory=/mnt/$BLOCKDEV/fio2/
--output=/mnt/$BLOCKDEV/fio2/test2.log &
-------------------------------------------------

test1 and test2 are two groups with weight 1000 and 500 respectively.
"read-and-display-group-stats.sh" is one small script which reads the
test1 and test2 cgroup files to determine how much disk time each group
got till first fio job finished.

Following are the results.

test1 statistics: time=8 16 29085   sectors=8 16 1049656
test2 statistics: time=8 16 14652   sectors=8 16 516728

Above shows that by the time first fio (higher weight), finished, group
test1 got 28085 ms of disk time and group test2 got 14652 ms of disk time.
similarly the statistics for number of sectors transferred are also shown.

Note that disk time given to group test1 is almost double of group2 disk
time.

Test4 (Writes with O_SYNC)
==========================
Created two groups with weight 1000 and 500 and launched two fio jobs doing
sync writes.

sample script
---------------------------
fio_args="--size=256m --rw=write --numjobs=1 --group_reporting --sync=1"

echo $$ > /cgroup/bfqio/test1/tasks
time fio $fio_args --name=test1 --directory=/mnt/$BLOCKDEV/fio1/
--output=/mnt/$BLOCKDEV/fio1/test1.log > /dev/null &

echo $$ > /cgroup/bfqio/test2/tasks
time fio $fio_args --name=test2 --directory=/mnt/$BLOCKDEV/fio2/
--output=/mnt/$BLOCKDEV/fio2/test2.log > /dev/null &

# some code to read group data upon completion of first fio job
----------------------------

Results
-------
group1 time=8 16 15194	group1 sectors=8 16 524864
group2 time=8 16 7689	group2 sectors=8 16 258920

Note, group 1 got almost double of group2 time as per the weight settings.

Test5 (Fairness for async writes, Buffered Write Vs Buffered Write)
===================================================================
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

Do we really care that much for fairness among two writer cgroups? One can
choose to do direct writes or sync writes if fairness for writes really
matters for him.

Following is the only case where it is hard to ensure fairness between cgroups.

- Buffered writes Vs Buffered Writes.

So to test async writes I created two partitions on a disk and created ext3
file systems on both the partitions.  Also created two cgroups and generated
lots of write traffic in two cgroups (50 fio threads) and watched the disk
time statistics in respective cgroups at the interval of 2 seconds. Thanks to
ryo tsuruta for the test case.

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

So disk time consumed by group1 is almost double of group2 in this case.

Thanks
Vivek
