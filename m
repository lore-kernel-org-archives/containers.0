From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: IO scheduler based IO Controller V2
Date: Tue,  5 May 2009 15:58:27 -0400
Message-ID: <1241553525-28095-1-git-send-email-vgoyal__43983.5805831992$1241555863$gmane$org@redhat.com>
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
To: nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, fer
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


Hi All,

Here is the V2 of the IO controller patches generated on top of 2.6.30-rc4.
First version of the patches was posted here.

http://lkml.org/lkml/2009/3/11/486

This patchset is still work in progress but I want to keep on getting the
snapshot of my tree out at regular intervals to get the feedback hence V2.

Before I go into details of what are the major changes from V1, wanted
to highlight other IO controller proposals on lkml.

Other active IO controller proposals
------------------------------------
Currently primarily two other IO controller proposals are out there.

dm-ioband
---------
This patch set is from Ryo Tsuruta from valinux. It is a proportional bandwidth controller implemented as a dm driver.

http://people.valinux.co.jp/~ryov/dm-ioband/

The biggest issue (apart from others), with a 2nd level IO controller is that
buffering of BIOs takes place in a single queue and dispatch of this BIOs
to unerlying IO scheduler is in FIFO manner. That means whenever the buffering
takes place, it breaks the notion of different class and priority of CFQ.

That means RT requests might be stuck behind some write requests or some read
requests might be stuck behind somet write requests for long time etc. To
demonstrate the single FIFO dispatch issues, I had run some basic tests and
posted the results in following mail thread.

http://lkml.org/lkml/2009/4/13/2

These are hard to solve issues and one will end up maintaining the separate
queues for separate classes and priority as CFQ does to fully resolve it.
But that will make 2nd level implementation complex at the same time if
somebody is trying to use IO controller on a single disk or on a hardware RAID
using cfq as scheduler, it will be two layers of queueing maintating separate
queues per priorty level. One at dm-driver level and other at CFQ which again
does not make lot of sense.

On the other hand, if a user is running noop at the device level, at higher
level we will be maintaining multiple cfq like queues, which also does not
make sense as underlying IO scheduler never wanted that.

Hence, IMHO, I think that controlling bio at second level probably is not a
very good idea. We should instead do it at IO scheduler level where we already
maintain all the needed queues. Just that make the scheduling hierarhical and
group aware so isolate IO of one group from other.

IO-throttling
-------------
This patch set is from Andrea Righi provides max bandwidth controller. That
means, it does not gurantee the minimum bandwidth. It provides the maximum
bandwidth limits and throttles the application if it crosses its bandwidth.

So its not apple vs apple comparison. This patch set and dm-ioband provide
proportional bandwidth control where a cgroup can use much more bandwidth
if there are not other users and resource control comes into the picture
only if there is contention.

It seems that there are both the kind of users there. One set of people needing
proportional BW control and other people needing max bandwidth control.

Now the question is, where max bandwidth control should be implemented? At
higher layers or at IO scheduler level? Should proportional bw control and
max bw control be implemented separately at different layer or these should
be implemented at one place?

IMHO, if we are doing proportional bw control at IO scheduler layer, it should
be possible to extend it to do max bw control also here without lot of effort.
Then it probably does not make too much of sense to do two types of control
at two different layers. Doing it at one place should lead to lesser code
and reduced complexity.

Secondly, io-throttling solution also buffers writes at higher layer.
Which again will lead to issue of losing the notion of priority of writes.

Hence, personally I think that users will need both proportional bw as well
as max bw control and we probably should implement these at a single place
instead of splitting it. Once elevator based io controller patchset matures,
it can be enhanced to do max bw control also.

Having said that, one issue with doing upper limit control at elevator/IO
scheduler level is that it does not have the view of higher level logical
devices. So if there is a software RAID with two disks, then one can not do
max bw control on logical device, instead it shall have to be on leaf node
where io scheduler is attached.

Now back to the desciption of this patchset and changes from V1.

- Rebased patches to 2.6.30-rc4.

- Last time Andrew mentioned that async writes are big issue for us hence,
  introduced the control for async writes also.

- Implemented per group request descriptor support. This was needed to
  make sure one group doing lot of IO does not starve other group of request
  descriptors and other group does not get fair share. This is a basic patch
  right now which probably will require more changes after some discussion.

- Exported the disk time used and number of sectors dispatched by a cgroup
  through cgroup interface. This should help us in seeing how much disk
  time each group got and whether it is fair or not.

- Implemented group refcounting support. Lack of this was causing some
  cgroup related issues. There are still some races left out which needs
  to be fixed. 

- For IO tracking/async write tracking, started making use of patches of
  blkio-cgroup from ryo Tsuruta posted here.

  http://lkml.org/lkml/2009/4/28/235

  Currently people seem to be liking the idea of separate subsystem for
  tracking writes and then rest of the users can use that info instead of
  everybody implementing their own. That's a different thing that how many
  users are out there which will end up in kernel is not clear.

  So instead of carrying own versin of bio-cgroup patches, and overloading
  io controller cgroup subsystem, I am making use of blkio-cgroup patches.
  One shall have to mount io controller and blkio subsystem together on the
  same hiearchy for the time being. Later we can take care of the case where
  blkio is mounted on a different hierarchy.

- Replaced group priorities with group weights.

Testing
=======

Again, I have been able to do only very basic testing of reads and writes.
Did not want to hold the patches back because of testing. Providing support
for async writes took much more time than expected and still work is left
in that area. Will continue to do more testing.

Test1 (Fairness for synchronous reads)
======================================
- Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
  cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)

dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &

234179072 bytes (234 MB) copied, 4.13954 s, 56.6 MB/s
234179072 bytes (234 MB) copied, 5.2127 s, 44.9 MB/s

group1 time=3108 group1 sectors=460968
group2 time=1405 group2 sectors=264944

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

test1 statistics: time=9848   sectors=643152
test2 statistics: time=5224   sectors=258600

test1 statistics: time=11736   sectors=785792
test2 statistics: time=6509   sectors=333160

test1 statistics: time=13607   sectors=943968
test2 statistics: time=7443   sectors=394352

test1 statistics: time=15662   sectors=1089496
test2 statistics: time=8568   sectors=451152

So disk time consumed by group1 is almost double of group2.  

Your feedback and comments are welcome.

Thanks
Vivek
