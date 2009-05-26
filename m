From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO scheduler based IO controller V3
Date: Tue, 26 May 2009 18:41:49 -0400
Message-ID: <1243377729-2176-1-git-send-email-vgoyal__26173.9224814393$1243380740$gmane$org@redhat.com>
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

Here is the V3 of the IO controller patches generated on top of 2.6.30-rc7.

Previous versions of the patches was posted here.

http://lkml.org/lkml/2009/3/11/486
http://lkml.org/lkml/2009/5/5/275

This patchset is still work in progress but I want to keep on getting the
snapshot of my tree out at regular intervals to get the feedback hence V3.

Changes from V2
===============
- Now this patcheset supports per device per cgroup rules. Thanks to Gui for
  the patch. Previously a cgroup had same weight on all the block devices
  in the system. Now one can specify different weights on different devices
  for same cgroup.

- Made disk time and disk sector statistics per device per cgroup. 

- Replaced the old io group refcounting patch with new patch from nauman.
  Core change being that during cgroup deletion we don't try to hold
  both io_cgroup lock and queue lock at the same time.

- Fixed few bugs in per cgropup request descriptor infrastructure. There
  were instances when a process be put to indefinite sleep after frequent
  elevator switches.

- Did some cleanups like get rid of rq->iog and rq->rl fields. Thanks to
  the nauman and Gui for ideas and patches. Got rid of some dead code too.

- Introduced some more debugging help in the form of two more cgrop files
  "io.disk_queue" and "io.disk_dequeue". It gives the information how many
  a times a group was queued for disk access and how many a times it got
  out of contention.

- Introduced an experimental debug patch where one can wait for new reuquest
  on an async queue before it is expired.

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

Again, I have been able to do only very basic testing of reads and writes.

Test1 (Fairness for synchronous reads)
======================================
- Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
  cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)

dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &

234179072 bytes (234 MB) copied, 4.0167 s, 58.3 MB/s
234179072 bytes (234 MB) copied, 5.21889 s, 44.9 MB/s

group1 time=8 16 2483 group1 sectors=8 16 457840
group2 time=8 16 1317 group2 sectors=8 16 242664

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

test1 statistics: time=8 48 4325   sectors=8 48 226696 dq=8 48 2
test2 statistics: time=8 48 2163   sectors=8 48 107040 dq=8 48 1

test1 statistics: time=8 48 8460   sectors=8 48 489152 dq=8 48 4
test2 statistics: time=8 48 4425   sectors=8 48 256984 dq=8 48 3

test1 statistics: time=8 48 12928   sectors=8 48 792192 dq=8 48 6
test2 statistics: time=8 48 6813   sectors=8 48 384944 dq=8 48 5

test1 statistics: time=8 48 17256   sectors=8 48 1092744 dq=8 48 7
test2 statistics: time=8 48 8980   sectors=8 48 524840 dq=8 48 6

test1 statistics: time=8 48 20488   sectors=8 48 1300832 dq=8 48 8
test2 statistics: time=8 48 10920   sectors=8 48 634864 dq=8 48 7

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

- Anticipatory code will need more work. It is not working properly currently
  and needs more thought regarding idling etc.

Thanks
Vivek
