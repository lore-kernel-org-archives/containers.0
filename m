From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO scheduler based IO controller V8
Date: Sun, 16 Aug 2009 15:30:22 -0400
Message-ID: <1250451046-9966-1-git-send-email-vgoyal__23335.8771227815$1250452952$gmane$org@redhat.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, righi.andr
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


Hi All,

Here is the V8 of the IO controller patches generated on top of 2.6.31-rc6.

Previous versions of the patches was posted here.

(V1) http://lkml.org/lkml/2009/3/11/486
(V2) http://lkml.org/lkml/2009/5/5/275
(V3) http://lkml.org/lkml/2009/5/26/472
(V4) http://lkml.org/lkml/2009/6/8/580
(V5) http://lkml.org/lkml/2009/6/19/279
(V6) http://lkml.org/lkml/2009/7/2/369
(V7) http://lkml.org/lkml/2009/7/24/253

Changes from V7
===============
- Replaced BFQ with CFS+CFQ like hierarchical scheduler.

  Moving to time domain as service parameter had broken BFQ's assumptions
  about how long a queue runs (queue can run more than budget) and that in
  turn has potential to break the O(1) gurantees of BFQ.

  In addition, BFQ was relatively complex and not sure if benefits were
  proportionate in time domain setup. Hence for the time being trying to
  replace BFQ with a simpler scheduler and see how well does it perform.

  This scheduler borrows the ideas from CFS and CFQ. Time slices to queues are
  allocated based on their priority (like CFQ). These disk times are converted
  to virtual disk time and we keep track of each queue's vdisktime and each
  service tree's min_vdisktime to determine who has consumed how much disk
  time and who should run next (like CFS).

- Fixed few issues reported by Jerome Marchand.

  Apart from this there are miscellaneous cleaups like getting rid of not so
  necessary comments, function renames, debug code re-organization etc.
 
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
(Do we really need it? That's not where the contention for resources is.)

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
- code cleanups, testing, bug fixing, optimizations, benchmarking etc...

Testing
=======

I have been able to do some testing as follows. All my testing is with ext3
file system with a SATA drive which supports queue depth of 31.

Test1 (Isolation between two KVM virtual machines)
==================================================
Created two KVM virtual machines. Partitioned a disk on host in two partitions
and gave one partition to each virtual machine. Put both the virtual machines
in two different cgroup of weight 1000 and 500 each. Virtual machines created
ext3 file system on the partitions exported from host and did buffered writes.
Host seems writes as synchronous and virtual machine with higher weight gets
double the disk time of virtual machine of lower weight. Used deadline
scheduler in this test case.

Some more details about configuration are in documentation patch.

Test2 (Fairness for synchronous reads)
======================================
- Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
  cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)

  Higher weight dd finishes first and at that point of time my script takes
  care of reading cgroup files io.disk_time and io.disk_sectors for both the
  groups and display the results.

  dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
  dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &

  group1 time=8:16 2452 group1 sectors=8:16 457856
  group2 time=8:16 1317 group2 sectors=8:16 247008

  234179072 bytes (234 MB) copied, 3.90912 s, 59.9 MB/s
  234179072 bytes (234 MB) copied, 5.15548 s, 45.4 MB/s

First two fields in time and sectors statistics represent major and minor
number of the device. Third field represents disk time in milliseconds and
number of sectors transferred respectively.

This patchset tries to provide fairness in terms of disk time received. group1
got almost double of group2 disk time (At the time of first dd finish). These
time and sectors statistics can be read using io.disk_time and io.disk_sector
files in cgroup. More about it in documentation file.

Test3 (Reader Vs Buffered Writes)
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
comletion of reader, my scripts read io.disk_time and io.disk_sectors cgroup
files to get an estimate how much disk time each group got and how many
sectors each group did IO for. 

For more accurate accounting of disk time for buffered writes with queuing
hardware I had to set /sys/block/<disk>/queue/iosched/fairness to "1".

sample script
-------------
echo $$ > /cgroup/bfqio/test2/tasks
dd if=/dev/zero of=/mnt/$BLOCKDEV/testzerofile bs=4K count=2097152 &
sleep 10
echo noop > /sys/block/$BLOCKDEV/queue/scheduler
echo  1 > /sys/block/$BLOCKDEV/queue/iosched/fairness
echo $$ > /cgroup/bfqio/test1/tasks
dd if=/mnt/$BLOCKDEV/256M-file of=/dev/null &
wait $!
# Some code for reading cgroup files upon completion of reader.
-------------------------

Results
=======
68435456 bytes (268 MB) copied, 6.87668 s, 39.0 MB/s

group1 time=8:16 3719 group1 sectors=8:16 524816
group2 time=8:16 3659 group2 sectors=8:16 638712

Note, reader finishes now much lesser time and both group1 and group2
got almost 3 seconds of disk time. Hence io-controller provides isolation
from buffered writes.

Test4 (AIO)
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
test1 statistics: time=8:16 17686   sectors=8:16 1049664
test2 statistics: time=8:16 9036   sectors=8:16 585152

Above shows that by the time first fio (higher weight), finished, group
test1 got 17686 ms of disk time and group test2 got 9036 ms of disk time.
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

test1 statistics: time=8:16 25509   sectors=8:16 1049688
test2 statistics: time=8:16 12863   sectors=8:16 527104

Above shows that by the time first fio (higher weight), finished, group
test1 got almost double the disk time of group test2.

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

test1 statistics: time=8:16 1631   sectors=8:16 1680 dq=8:16 2
test2 statistics: time=8:16 896   sectors=8:16 976 dq=8:16 1

test1 statistics: time=8:16 6031   sectors=8:16 88536 dq=8:16 5
test2 statistics: time=8:16 3192   sectors=8:16 4080 dq=8:16 1

test1 statistics: time=8:16 10425   sectors=8:16 390496 dq=8:16 5
test2 statistics: time=8:16 5272   sectors=8:16 77896 dq=8:16 4

test1 statistics: time=8:16 15396   sectors=8:16 747256 dq=8:16 5
test2 statistics: time=8:16 7852   sectors=8:16 235648 dq=8:16 4

test1 statistics: time=8:16 20302   sectors=8:16 1180168 dq=8:16 5
test2 statistics: time=8:16 10297   sectors=8:16 391208 dq=8:16 4

test1 statistics: time=8:16 25244   sectors=8:16 1579928 dq=8:16 6
test2 statistics: time=8:16 12748   sectors=8:16 613096 dq=8:16 4

test1 statistics: time=8:16 30095   sectors=8:16 1927848 dq=8:16 6
test2 statistics: time=8:16 15135   sectors=8:16 806112 dq=8:16 4

First two fields in time and sectors statistics represent major and minor
number of the device. Third field represents disk time in milliseconds and
number of sectors transferred respectively.

So disk time consumed by group1 is almost double of group2 in this case.

Thanks
Vivek
