From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO scheduler based IO controller V4
Date: Mon,  8 Jun 2009 22:08:43 -0400
Message-ID: <1244513342-11758-1-git-send-email-vgoyal__1346.89737246863$1244515410$gmane$org@redhat.com>
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

Here is the V4 of the IO controller patches generated on top of 2.6.30-rc8.

Previous versions of the patches was posted here.

http://lkml.org/lkml/2009/3/11/486
http://lkml.org/lkml/2009/5/5/275
http://lkml.org/lkml/2009/5/26/472

This patchset is still work in progress but I want to keep on getting the
snapshot of my tree out at regular intervals to get the feedback hence V4.

Changes from V3
===============
- Fixed Anticipatory io scheduler to work with common hierarchical fair
  queuing layer. In previous postings, the basic code for AS was there
  but there were some issues w.r.t dyanmic write batch length adjustments, 
  anticipation and queue expiry, and code was not tested. Now I have fixed
  the issues and done basic testing of the code. AS should work now.

- Did some changes to outputting debug messages. Now group is also printed
  along with queue info and introduced new debug messages in AS.

- Took few code cleanups and fixes from Gui Jianfeng.

- Stopped expiring the queue for noop, deadline and AS if there is only root
  group present. This should help us avoid unnecessary overhead of queue
  switching and help retain the old IO scheduler behavior if one is not
  using cgroup stuff with IO schedulers compiled in hierarchical mode.

- Merged the io group refcounting patch with higher level patches.

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
Fairness for async writes is tricy and biggest reason is that async writes
are cached in higher layers (page cahe) and are dispatched to lower layers
not necessarily in proportional manner. For example, consider two dd threads
reading /dev/zero as input file and doing writes of huge files. Very soon
we will cross vm_dirty_ratio and dd thread will be forced to write out some
pages to disk before more pages can be dirtied. But not necessarily dirty
pages of same thread are picked. It can very well pick the inode of lesser
priority dd thread and do some writeout. So effectively higher weight dd is
doing writeouts of lower weight dd pages and we don't see service differentation

IOW, the core problem with async write fairness is that higher weight thread
does not throw enought IO traffic at IO controller to keep the queue
continuously backlogged. This are many .2 to .8 second intervals where higher
weight queue is empty and in that duration lower weight queue get lots of job
done giving the impression that there was no service differentiation.

In summary, from IO controller point of view async writes support is there. Now
we need to do some more work in higher layers to make sure higher weight process
is not blocked behind IO of some lower weight process. This is a TODO item.

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

- Debug and fix some of the areas like page cache where higher weight cgroup
  async writes are stuck behind lower weight cgroup async writes.

Thanks
Vivek
