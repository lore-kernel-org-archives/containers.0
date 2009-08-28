From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO scheduler based IO controller V9
Date: Fri, 28 Aug 2009 17:30:49 -0400
Message-ID: <1251495072-7780-1-git-send-email-vgoyal__17853.6445288502$1251495210$gmane$org@redhat.com>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


Hi All,

Here is the V9 of the IO controller patches generated on top of 2.6.31-rc7.

For ease of patching, a consolidated patch is available here.

http://people.redhat.com/~vgoyal/io-controller/io-scheduler-based-io-controller-v9.patch

Changes from V8
===============
- Implemented bdi like congestion semantics for io group also. Now once an
  io group gets congested, we don't clear the congestion flag until number
  of requests goes below nr_congestion_off.

  This helps in getting rid of Buffered write performance regression we
  were observing with io controller patches.

  Gui, can you please test it and see if this version is better in terms
  of your buffered write tests.

- Moved some of the functions from blk-core.c to elevator-fq.c. This reduces
  CONFIG_GROUP_IOSCHED ifdefs in blk-core.c and code looks little more clean. 

- Fixed issue of add_front where we go left on rb-tree if add_front is
  specified in case of preemption.

- Requeue async ioq after one round of dispatch. This helps emulationg
  CFQ behavior.

- Pulled in v11 of io tracking patches and modified config option so that if
  CONFIG_TRACK_ASYNC_CONTEXT is not enabled, blkio is not compiled in.

- Fixed some block tracepoints which were broken because of per group request
  list changes.

- Fixed some logging messages.

- Got rid of extra call to update_prio as pointed out by Jerome and Gui.

- Merged the fix from jerome for a crash while chaning prio.

- Got rid of redundant slice_start assignment as pointed by Gui.

- Merged a elv_ioq_nr_dispatched() cleanup from Gui.

- Fixed a compilation issue if CONFIG_BLOCK=n.
 
What problem are we trying to solve
===================================
Provide group IO scheduling feature in Linux along the lines of other resource
controllers like cpu.

IOW, provide facility so that a user can group applications using cgroups and
control the amount of disk time/bandwidth received by a group based on its
weight. 

How to solve the problem
=========================

Different people have solved the issue differetnly. At least there are now
three patchsets available (including this one).

IO throttling
-------------
This is a bandwidth controller which keeps track of IO rate of a group and
throttles the process in the group if it exceeds the user specified limit.

dm-ioband
---------
This is a proportional bandwidth controller implemented as device mapper
driver and provides fair access in terms of amount of IO done (not in terms
of disk time as CFQ does).

So one will setup one or more dm-ioband devices on top of physical/logical
block device, configure the ioband device and pass information like grouping
etc. Now this device will keep track of bios flowing through it and control
the flow of bios based on group policies.

IO scheduler based IO controller
--------------------------------
Here I have viewed the problem of IO contoller as hierarchical group scheduling (along the lines of CFS group scheduling) issue. Currently one can view linux
IO schedulers as flat where there is one root group and all the IO belongs to
that group.

This patchset basically modifies IO schedulers to also support hierarchical
group scheduling. CFQ already provides fairness among different processes. I 
have extended it support group IO schduling. Also took some of the code out
of CFQ and put in a common layer so that same group scheduling code can be
used by noop, deadline and AS to support group scheduling. 

Pros/Cons
=========
There are pros and cons to each of the approach. Following are some of the
thoughts.

- IO throttling is a max bandwidth controller and not a proportional one.
  Additionaly it provides fairness in terms of amount of IO done (and not in
  terms of disk time as CFQ does).

  Personally, I think that proportional weight controller is useful to more
  people than just max bandwidth controller. In addition, IO scheduler based
  controller can also be enhanced to do max bandwidth control, if need be.

- dm-ioband also provides fairness in terms of amount of IO done not in terms
  of disk time. So a seeky process can still run away with lot more disk time.
  Now this is an interesting question that how fairness among groups should be
  viewed and what is more relevant. Should fairness be based on amount of IO
  done or amount of disk time consumed as CFQ does. IO scheduler based
  controller provides fairness in terms of disk time used.

- IO throttling and dm-ioband both are second level controller. That is these
  controllers are implemented in higher layers than io schedulers. So they
  control the IO at higher layer based on group policies and later IO
  schedulers take care of dispatching these bios to disk.

  Implementing a second level controller has the advantage of being able to
  provide bandwidth control even on logical block devices in the IO stack
  which don't have any IO schedulers attached to these. But they can also 
  interefere with IO scheduling policy of underlying IO scheduler and change
  the effective behavior. Following are some of the issues which I think
  should be visible in second level controller in one form or other.

  Prio with-in group
  ------------------
  A second level controller can potentially interefere with behavior of
  different prio processes with-in a group. bios are buffered at higher layer
  in single queue and release of bios is FIFO and not proportionate to the
  ioprio of the process. This can result in a particular prio level not
  getting fair share.

  Buffering at higher layer can delay read requests for more than slice idle
  period of CFQ (default 8 ms). That means, it is possible that we are waiting
  for a request from the queue but it is buffered at higher layer and then idle
  timer will fire. It means that queue will losse its share at the same time
  overall throughput will be impacted as we lost those 8 ms.
  
  Read Vs Write
  -------------
  Writes can overwhelm readers hence second level controller FIFO release
  will run into issue here. If there is a single queue maintained then reads
  will suffer large latencies. If there separate queues for reads and writes
  then it will be hard to decide in what ratio to dispatch reads and writes as
  it is IO scheduler's decision to decide when and how much read/write to
  dispatch. This is another place where higher level controller will not be in
  sync with lower level io scheduler and can change the effective policies of
  underlying io scheduler.

  Fairness in terms of disk time / size of IO
  ---------------------------------------------
  An higher level controller will most likely be limited to providing fairness
  in terms of size of IO done and will find it hard to provide fairness in
  terms of disk time used (as CFQ provides between various prio levels). This
  is because only IO scheduler knows how much disk time a queue has used.

  Not sure how useful it is to have fairness in terms of secotrs as CFQ has
  been providing fairness in terms of disk time. So a seeky application will
  still run away with lot of disk time and bring down the overall throughput
  of the the disk more than usual.

  CFQ IO context Issues
  ---------------------
  Buffering at higher layer means submission of bios later with the help of
  a worker thread. This changes the io context information at CFQ layer which
  assigns the request to submitting thread. Change of io context info again
  leads to issues of idle timer expiry and issue of a process not getting fair
  share and reduced throughput.

  Throughput with noop, deadline and AS
  ---------------------------------------------
  I think an higher level controller will result in reduced overall throughput
  (as compared to io scheduler based io controller) and more seeks with noop,
  deadline and AS.

  The reason being, that it is likely that IO with-in a group will be related
  and will be relatively close as compared to IO across the groups. For example,
  thread pool of kvm-qemu doing IO for virtual machine. In case of higher level
  control, IO from various groups will go into a single queue at lower level
  controller and it might happen that IO is now interleaved (G1, G2, G1, G3,
  G4....) causing more seeks and reduced throughput. (Agreed that merging will
  help up to some extent but still....).

  Instead, in case of lower level controller, IO scheduler maintains one queue
  per group hence there is no interleaving of IO between groups. And if IO is
  related with-in group, then we shoud get reduced number/amount of seek and
  higher throughput.

  Latency can be a concern but that can be controlled by reducing the time
  slice length of the queue.

- IO scheduler based controller has the limitation that it works only with the
  bottom most devices in the IO stack where IO scheduler is attached. Now the
  question comes that how important/relevant it is to control bandwidth at
  higher level logical devices also. The actual contention for resources is
  at the leaf block device so it probably makes sense to do any kind of
  control there and not at the intermediate devices. Secondly probably it
  also means better use of available resources.

  For example, assume a user has created a linear logical device lv0 using
  three underlying disks sda, sdb and sdc. Also assume there are two tasks
  T1 and T2 in two groups doing IO on lv0. Also assume that weights of groups
  are in the ratio of 2:1 so T1 should get double the BW of T2 on lv0 device.

			     T1    T2
			       \   /
			        lv0
			      /  |  \
			    sda sdb  sdc

  Now if IO control is done at lv0 level, then if T1 is doing IO to only sda,
  and T2's IO is going to sdc. In this case there is no need of resource
  management as both the IOs don't have any contention where it matters. If we
  try to do IO control at lv0 device, it will not be an optimal usage of
  resources and will bring down overall throughput.

IMHO, IO scheduler based IO controller is a reasonable approach to solve the
problem of group bandwidth control, and can do hierarchical IO scheduling
more tightly and efficiently. But I am all ears to alternative approaches and
suggestions how doing things can be done better.

TODO
====
- code cleanups, testing, bug fixing, optimizations, benchmarking etc...
- More testing to make sure there are no regressions in CFQ.

Open Issues
===========
- Currently for async requests like buffered writes, we get the io group
  information from the page instead of the task context. How important it is
  to determine the context from page?

  Can we put all the pdflush threads into a separate group and control system
  wide buffered write bandwidth. Any buffered writes submitted by the process
  directly will any way go to right group.

  If it is acceptable then we can drop all the code associated with async io
  context and that should simplify the patchset a lot.  

Testing
=======
I have divided testing results in three sections. 

- Latency
- Throughput and Fairness
- Group Fairness

Because I have enhanced CFQ to also do group scheduling, one of the concerns
has been that existing CFQ should not regress at least in flat setup. If
one creates groups and puts tasks in those, then this is new environment and
some properties can change because groups have this additional requirement
of providing isolation also.

Environment
==========
A 7200 RPM SATA drive with queue depth of 31. Ext3 filesystem.
 
Latency Testing
++++++++++++++++

Test1: fsync-test with torture test from linus as background writer
------------------------------------------------------------
I looked at Ext3 fsync latency thread and picked fsync-test from Theodore Ts'o
and torture test from Linus as background writer to see how are the fsync
completion latencies. Following are the results.

Vanilla CFQ              IOC                    IOC (with map async)
===========             =================        ====================
fsync time: 0.2515      fsync time: 0.8580      fsync time: 0.0531
fsync time: 0.1082      fsync time: 0.1408      fsync time: 0.8907
fsync time: 0.2106      fsync time: 0.3228      fsync time: 0.2709
fsync time: 0.2591      fsync time: 0.0978      fsync time: 0.3198
fsync time: 0.2776      fsync time: 0.3035      fsync time: 0.0886
fsync time: 0.2530      fsync time: 0.0903      fsync time: 0.3035
fsync time: 0.2271      fsync time: 0.2712      fsync time: 0.0961
fsync time: 0.1057      fsync time: 0.3357      fsync time: 0.1048
fsync time: 0.1699      fsync time: 0.3175      fsync time: 0.2582
fsync time: 0.1923      fsync time: 0.2964      fsync time: 0.0876
fsync time: 0.1805      fsync time: 0.0971      fsync time: 0.2546
fsync time: 0.2944      fsync time: 0.2728      fsync time: 0.3059
fsync time: 0.1420      fsync time: 0.1079      fsync time: 0.2973
fsync time: 0.2650      fsync time: 0.3103      fsync time: 0.2032
fsync time: 0.1581      fsync time: 0.1987      fsync time: 0.2926
fsync time: 0.2656      fsync time: 0.3048      fsync time: 0.1934
fsync time: 0.2666      fsync time: 0.3092      fsync time: 0.2954
fsync time: 0.1272      fsync time: 0.0165      fsync time: 0.2952
fsync time: 0.2655      fsync time: 0.2827      fsync time: 0.2394
fsync time: 0.0147      fsync time: 0.0068      fsync time: 0.0454
fsync time: 0.2296      fsync time: 0.2923      fsync time: 0.2936
fsync time: 0.0069      fsync time: 0.3021      fsync time: 0.0397
fsync time: 0.2668      fsync time: 0.1032      fsync time: 0.2762
fsync time: 0.1932      fsync time: 0.0962      fsync time: 0.2946
fsync time: 0.1895      fsync time: 0.3545      fsync time: 0.0774
fsync time: 0.2577      fsync time: 0.2406      fsync time: 0.3027
fsync time: 0.4935      fsync time: 0.7193      fsync time: 0.2984
fsync time: 0.2804      fsync time: 0.3251      fsync time: 0.1057
fsync time: 0.2685      fsync time: 0.1001      fsync time: 0.3145
fsync time: 0.1946      fsync time: 0.2525      fsync time: 0.2992

IOC--> With IO controller patches applied. CONFIG_TRACK_ASYNC_CONTEXT=n
IOC(map async) --> IO controller patches with CONFIG_TRACK_ASYNC_CONTEXT=y

If CONFIG_TRACK_ASYNC_CONTEXT=y, async requests are mapped to the group based
on cgroup info stored in page otherwise these are mapped to the cgroup
submitting task belongs to.

Notes: 
- It looks like that max fsync time is a bit higher with IO controller
  patches. Wil dig more into it later.

Test2: read small files with multiple sequential readers (10) runnning
======================================================================
Took Ingo's small file reader test and ran it while 10 sequential readers
were running.

Vanilla CFQ     IOC (flat)      IOC (10 readers in 10 groups)
0.12 seconds    0.11 seconds    1.62 seconds
0.05 seconds    0.05 seconds    1.18 seconds
0.05 seconds    0.05 seconds    1.17 seconds
0.03 seconds    0.04 seconds    1.18 seconds
1.15 seconds    1.17 seconds    1.29 seconds
1.18 seconds    1.16 seconds    1.17 seconds
1.17 seconds    1.16 seconds    1.17 seconds
1.18 seconds    1.15 seconds    1.28 seconds
1.17 seconds    1.15 seconds    1.17 seconds
1.16 seconds    1.18 seconds    1.18 seconds
1.15 seconds    1.15 seconds    1.17 seconds
1.17 seconds    1.15 seconds    1.18 seconds
1.17 seconds    1.15 seconds    1.17 seconds
1.17 seconds    1.16 seconds    1.18 seconds
1.17 seconds    1.15 seconds    1.17 seconds
0.04 seconds    0.04 seconds    1.18 seconds
1.17 seconds    1.16 seconds    1.17 seconds
1.18 seconds    1.15 seconds    1.17 seconds
1.18 seconds    1.15 seconds    1.28 seconds
1.18 seconds    1.15 seconds    1.18 seconds
1.17 seconds    1.16 seconds    1.18 seconds
1.17 seconds    1.18 seconds    1.17 seconds
1.17 seconds    1.15 seconds    1.17 seconds
1.16 seconds    1.16 seconds    1.17 seconds
1.17 seconds    1.15 seconds    1.17 seconds
1.16 seconds    1.15 seconds    1.17 seconds
1.15 seconds    1.15 seconds    1.18 seconds
1.18 seconds    1.16 seconds    1.17 seconds
1.16 seconds    1.16 seconds    1.17 seconds
1.17 seconds    1.16 seconds    1.17 seconds
1.16 seconds    1.16 seconds    1.17 seconds

In third column, 10 readers have been put into 10 groups instead of running
into root group. Small file reader runs in to root group.

Notes: It looks like that here read latencies remain same as with vanilla CFQ.

Test3: read small files with multiple writers (8) runnning
==========================================================
Again running small file reader test with 8 buffered writers running with
prio 0 to 7.

Latency results are in seconds. Tried to capture the output with multiple
configurations of IO controller to see the effect.

Vanilla  IOC     IOC     IOC     IOC    IOC     IOC
        (flat)(groups) (groups) (map)  (map)    (map)
                (f=0)   (f=1)   (flat) (groups) (groups)
                                        (f=0)   (f=1)
0.25    0.03    0.31    0.25    0.29    1.25    0.39
0.27    0.28    0.28    0.30    0.41    0.90    0.80
0.25    0.24    0.23    0.37    0.27    1.17    0.24
0.14    0.14    0.14    0.13    0.15    0.10    1.11
0.14    0.16    0.13    0.16    0.15    0.06    0.58
0.16    0.11    0.15    0.12    0.19    0.05    0.14
0.03    0.17    0.12    0.17    0.04    0.12    0.12
0.13    0.13    0.13    0.14    0.03    0.05    0.05
0.18    0.13    0.17    0.09    0.09    0.05    0.07
0.11    0.18    0.16    0.18    0.14    0.05    0.12
0.28    0.14    0.15    0.15    0.13    0.02    0.04
0.16    0.14    0.14    0.12    0.15    0.00    0.13
0.14    0.13    0.14    0.13    0.13    0.02    0.02
0.13    0.11    0.12    0.14    0.15    0.06    0.01
0.27    0.28    0.32    0.24    0.25    0.01    0.01
0.14    0.15    0.18    0.15    0.13    0.06    0.02
0.15    0.13    0.13    0.13    0.13    0.00    0.04
0.15    0.13    0.15    0.14    0.15    0.01    0.05
0.11    0.17    0.15    0.13    0.13    0.02    0.00
0.17    0.13    0.17    0.12    0.18    0.39    0.01
0.18    0.16    0.14    0.16    0.14    0.89    0.47
0.13    0.13    0.14    0.04    0.12    0.64    0.78
0.16    0.15    0.19    0.11    0.16    0.67    1.17
0.04    0.12    0.14    0.04    0.18    0.67    0.63
0.03    0.13    0.17    0.11    0.15    0.61    0.69
0.15    0.16    0.13    0.14    0.13    0.77    0.66
0.12    0.12    0.15    0.11    0.13    0.92    0.73
0.15    0.12    0.15    0.16    0.13    0.70    0.73
0.11    0.13    0.15    0.10    0.18    0.73    0.82
0.16    0.19    0.15    0.16    0.14    0.71    0.74
0.28    0.05    0.26    0.22    0.17    2.91    0.79
0.13    0.05    0.14    0.14    0.14    0.44    0.65
0.16    0.22    0.18    0.13    0.26    0.31    0.65
0.10    0.13    0.12    0.11    0.16    0.25    0.66
0.13    0.14    0.16    0.15    0.12    0.17    0.76
0.19    0.11    0.12    0.14    0.17    0.20    0.71
0.16    0.15    0.14    0.15    0.11    0.19    0.68
0.13    0.13    0.13    0.13    0.16    0.04    0.78
0.14    0.16    0.15    0.17    0.15    1.20    0.80
0.17    0.13    0.14    0.18    0.14    0.76    0.63

f(0/1)--> refers to "fairness" tunable. This is new tunable part of CFQ. It
  	  set, we wait for requests from one queue to finish before new
	  queue is scheduled in.

group ---> writers are running into individual groups and not in root group.
map---> buffered writes are mapped to group using info stored in page.

Notes: Except the case of column 6 and 7 when writeres are in separate groups
and we are mapping their writes to respective group, latencies seem to be
fine. I think the latencies are higher for the last two cases because
now the reader can't preempt the writer.

				root
			       / \  \ \
			      R  G1 G2 G3
				 |  |  |
				 W  W  W
Test4: Random Reader test in presece of 4 sequential readers and 4 buffered
       writers
============================================================================
Used fio to this time to run one random reader and see how does it fair in
the presence of 4 sequential readers and 4 writers.

I have just pasted the output of random reader from fio.

Vanilla Kernel, Three runs
--------------------------
read : io=20,512KiB, bw=349KiB/s, iops=10, runt= 60075msec
clat (usec): min=944, max=2,675K, avg=93715.04, stdev=305815.90

read : io=13,696KiB, bw=233KiB/s, iops=7, runt= 60035msec
clat (msec): min=2, max=1,812, avg=140.26, stdev=382.55

read : io=13,824KiB, bw=235KiB/s, iops=7, runt= 60185msec
clat (usec): min=766, max=2,025K, avg=139310.55, stdev=383647.54

IO controller kernel, Three runs
--------------------------------
read : io=10,304KiB, bw=175KiB/s, iops=5, runt= 60083msec
clat (msec): min=2, max=2,654, avg=186.59, stdev=524.08

read : io=10,176KiB, bw=173KiB/s, iops=5, runt= 60054msec
clat (usec): min=792, max=2,567K, avg=188841.70, stdev=517154.75

read : io=11,040KiB, bw=188KiB/s, iops=5, runt= 60003msec
clat (usec): min=779, max=2,625K, avg=173915.56, stdev=508118.60

Notes:
- Looks like vanilla CFQ gives a bit more disk access to random reader. Will
  dig into it.

Throughput and Fairness
+++++++++++++++++++++++
Test5: Bandwidth distribution between 4 sequential readers and 4 buffered
       writers
==========================================================================
Used fio to launch 4 sequential readers and 4 buffered writers and watched
how BW is distributed.

Vanilla kernel, Three sets
--------------------------
read : io=962MiB, bw=16,818KiB/s, iops=513, runt= 60008msec
read : io=969MiB, bw=16,920KiB/s, iops=516, runt= 60077msec
read : io=978MiB, bw=17,063KiB/s, iops=520, runt= 60096msec
read : io=922MiB, bw=16,106KiB/s, iops=491, runt= 60057msec
write: io=235MiB, bw=4,099KiB/s, iops=125, runt= 60049msec
write: io=226MiB, bw=3,944KiB/s, iops=120, runt= 60049msec
write: io=215MiB, bw=3,747KiB/s, iops=114, runt= 60049msec
write: io=207MiB, bw=3,606KiB/s, iops=110, runt= 60049msec
READ: io=3,832MiB, aggrb=66,868KiB/s, minb=16,106KiB/s, maxb=17,063KiB/s,
mint=60008msec, maxt=60096msec
WRITE: io=882MiB, aggrb=15,398KiB/s, minb=3,606KiB/s, maxb=4,099KiB/s,
mint=60049msec, maxt=60049msec

read : io=1,002MiB, bw=17,513KiB/s, iops=534, runt= 60020msec
read : io=979MiB, bw=17,085KiB/s, iops=521, runt= 60080msec
read : io=953MiB, bw=16,637KiB/s, iops=507, runt= 60092msec
read : io=920MiB, bw=16,057KiB/s, iops=490, runt= 60108msec
write: io=215MiB, bw=3,560KiB/s, iops=108, runt= 63289msec
write: io=136MiB, bw=2,361KiB/s, iops=72, runt= 60502msec
write: io=127MiB, bw=2,101KiB/s, iops=64, runt= 63289msec
write: io=233MiB, bw=3,852KiB/s, iops=117, runt= 63289msec
READ: io=3,855MiB, aggrb=67,256KiB/s, minb=16,057KiB/s, maxb=17,513KiB/s,
mint=60020msec, maxt=60108msec
WRITE: io=711MiB, aggrb=11,771KiB/s, minb=2,101KiB/s, maxb=3,852KiB/s,
mint=60502msec, maxt=63289msec

read : io=985MiB, bw=17,179KiB/s, iops=524, runt= 60149msec
read : io=974MiB, bw=17,025KiB/s, iops=519, runt= 60002msec
read : io=962MiB, bw=16,772KiB/s, iops=511, runt= 60170msec
read : io=932MiB, bw=16,280KiB/s, iops=496, runt= 60057msec
write: io=177MiB, bw=2,933KiB/s, iops=89, runt= 63094msec
write: io=152MiB, bw=2,637KiB/s, iops=80, runt= 60323msec
write: io=240MiB, bw=3,983KiB/s, iops=121, runt= 63094msec
write: io=147MiB, bw=2,439KiB/s, iops=74, runt= 63094msec
READ: io=3,855MiB, aggrb=67,174KiB/s, minb=16,280KiB/s, maxb=17,179KiB/s,
mint=60002msec, maxt=60170msec
WRITE: io=715MiB, aggrb=11,877KiB/s, minb=2,439KiB/s, maxb=3,983KiB/s,
mint=60323msec, maxt=63094msec

IO controller kernel three sets
-------------------------------
read : io=944MiB, bw=16,483KiB/s, iops=503, runt= 60055msec
read : io=941MiB, bw=16,433KiB/s, iops=501, runt= 60073msec
read : io=900MiB, bw=15,713KiB/s, iops=479, runt= 60040msec
read : io=866MiB, bw=15,112KiB/s, iops=461, runt= 60086msec
write: io=244MiB, bw=4,262KiB/s, iops=130, runt= 60040msec
write: io=177MiB, bw=3,085KiB/s, iops=94, runt= 60042msec
write: io=158MiB, bw=2,758KiB/s, iops=84, runt= 60041msec
write: io=180MiB, bw=3,137KiB/s, iops=95, runt= 60040msec
READ: io=3,651MiB, aggrb=63,718KiB/s, minb=15,112KiB/s, maxb=16,483KiB/s,
mint=60040msec, maxt=60086msec
WRITE: io=758MiB, aggrb=13,243KiB/s, minb=2,758KiB/s, maxb=4,262KiB/s,
mint=60040msec, maxt=60042msec

read : io=960MiB, bw=16,734KiB/s, iops=510, runt= 60137msec
read : io=917MiB, bw=16,001KiB/s, iops=488, runt= 60122msec
read : io=897MiB, bw=15,683KiB/s, iops=478, runt= 60004msec
read : io=908MiB, bw=15,824KiB/s, iops=482, runt= 60149msec
write: io=209MiB, bw=3,563KiB/s, iops=108, runt= 61400msec
write: io=177MiB, bw=3,030KiB/s, iops=92, runt= 61400msec
write: io=200MiB, bw=3,409KiB/s, iops=104, runt= 61400msec
write: io=204MiB, bw=3,489KiB/s, iops=106, runt= 61400msec
READ: io=3,682MiB, aggrb=64,194KiB/s, minb=15,683KiB/s, maxb=16,734KiB/s,
mint=60004msec, maxt=60149msec
WRITE: io=790MiB, aggrb=13,492KiB/s, minb=3,030KiB/s, maxb=3,563KiB/s,
mint=61400msec, maxt=61400msec

read : io=968MiB, bw=16,867KiB/s, iops=514, runt= 60158msec
read : io=925MiB, bw=16,135KiB/s, iops=492, runt= 60142msec
read : io=875MiB, bw=15,286KiB/s, iops=466, runt= 60003msec
read : io=872MiB, bw=15,221KiB/s, iops=464, runt= 60049msec
write: io=213MiB, bw=3,720KiB/s, iops=113, runt= 60162msec
write: io=203MiB, bw=3,536KiB/s, iops=107, runt= 60163msec
write: io=208MiB, bw=3,620KiB/s, iops=110, runt= 60162msec
write: io=203MiB, bw=3,538KiB/s, iops=107, runt= 60163msec
READ: io=3,640MiB, aggrb=63,439KiB/s, minb=15,221KiB/s, maxb=16,867KiB/s,
mint=60003msec, maxt=60158msec
WRITE: io=827MiB, aggrb=14,415KiB/s, minb=3,536KiB/s, maxb=3,720KiB/s,
mint=60162msec, maxt=60163msec

Notes: It looks like vanilla CFQ favors readers a bit more over writers as
       compared to io controller cfq. Will dig into it.
	 
Test6: Bandwidth distribution between readers of diff prio
==========================================================
Using fio, ran 8 readers of prio 0 to 7 and let it run for 30 seconds and
watched for overall throughput and who got how much IO done. 

Vanilla kernel, Three sets
---------------------------
read : io=454MiB, bw=15,865KiB/s, iops=484, runt= 30004msec
read : io=382MiB, bw=13,330KiB/s, iops=406, runt= 30086msec
read : io=325MiB, bw=11,330KiB/s, iops=345, runt= 30074msec
read : io=294MiB, bw=10,253KiB/s, iops=312, runt= 30062msec
read : io=238MiB, bw=8,321KiB/s, iops=253, runt= 30048msec
read : io=145MiB, bw=5,061KiB/s, iops=154, runt= 30032msec
read : io=99MiB, bw=3,456KiB/s, iops=105, runt= 30021msec
read : io=67,040KiB, bw=2,280KiB/s, iops=69, runt= 30108msec
READ: io=2,003MiB, aggrb=69,767KiB/s, minb=2,280KiB/s, maxb=15,865KiB/s,
mint=30004msec, maxt=30108msec

read : io=450MiB, bw=15,727KiB/s, iops=479, runt= 30001msec
read : io=371MiB, bw=12,966KiB/s, iops=395, runt= 30040msec
read : io=325MiB, bw=11,321KiB/s, iops=345, runt= 30099msec
read : io=296MiB, bw=10,332KiB/s, iops=315, runt= 30086msec
read : io=238MiB, bw=8,319KiB/s, iops=253, runt= 30056msec
read : io=152MiB, bw=5,290KiB/s, iops=161, runt= 30070msec
read : io=100MiB, bw=3,483KiB/s, iops=106, runt= 30020msec
read : io=68,832KiB, bw=2,340KiB/s, iops=71, runt= 30118msec
READ: io=2,000MiB, aggrb=69,631KiB/s, minb=2,340KiB/s, maxb=15,727KiB/s,
mint=30001msec, maxt=30118msec

read : io=450MiB, bw=15,691KiB/s, iops=478, runt= 30068msec
read : io=369MiB, bw=12,882KiB/s, iops=393, runt= 30032msec
read : io=364MiB, bw=12,732KiB/s, iops=388, runt= 30015msec
read : io=283MiB, bw=9,889KiB/s, iops=301, runt= 30002msec
read : io=228MiB, bw=7,935KiB/s, iops=242, runt= 30091msec
read : io=144MiB, bw=5,018KiB/s, iops=153, runt= 30103msec
read : io=97,760KiB, bw=3,327KiB/s, iops=101, runt= 30083msec
read : io=66,784KiB, bw=2,276KiB/s, iops=69, runt= 30046msec
READ: io=1,999MiB, aggrb=69,625KiB/s, minb=2,276KiB/s, maxb=15,691KiB/s,
mint=30002msec, maxt=30103msec

IO controller kernel, Three sets
--------------------------------
read : io=404MiB, bw=14,103KiB/s, iops=430, runt= 30072msec
read : io=344MiB, bw=11,999KiB/s, iops=366, runt= 30035msec
read : io=294MiB, bw=10,257KiB/s, iops=313, runt= 30052msec
read : io=254MiB, bw=8,888KiB/s, iops=271, runt= 30021msec
read : io=238MiB, bw=8,311KiB/s, iops=253, runt= 30086msec
read : io=177MiB, bw=6,202KiB/s, iops=189, runt= 30001msec
read : io=158MiB, bw=5,517KiB/s, iops=168, runt= 30118msec
read : io=99MiB, bw=3,464KiB/s, iops=105, runt= 30107msec
READ: io=1,971MiB, aggrb=68,604KiB/s, minb=3,464KiB/s, maxb=14,103KiB/s,
mint=30001msec, maxt=30118msec

read : io=375MiB, bw=13,066KiB/s, iops=398, runt= 30110msec
read : io=326MiB, bw=11,409KiB/s, iops=348, runt= 30003msec
read : io=308MiB, bw=10,758KiB/s, iops=328, runt= 30066msec
read : io=256MiB, bw=8,937KiB/s, iops=272, runt= 30091msec
read : io=232MiB, bw=8,088KiB/s, iops=246, runt= 30041msec
read : io=192MiB, bw=6,695KiB/s, iops=204, runt= 30077msec
read : io=144MiB, bw=5,014KiB/s, iops=153, runt= 30051msec
read : io=96,224KiB, bw=3,281KiB/s, iops=100, runt= 30026msec
READ: io=1,928MiB, aggrb=67,145KiB/s, minb=3,281KiB/s, maxb=13,066KiB/s,
mint=30003msec, maxt=30110msec

read : io=405MiB, bw=14,162KiB/s, iops=432, runt= 30021msec
read : io=354MiB, bw=12,386KiB/s, iops=378, runt= 30007msec
read : io=303MiB, bw=10,567KiB/s, iops=322, runt= 30062msec
read : io=261MiB, bw=9,126KiB/s, iops=278, runt= 30040msec
read : io=228MiB, bw=7,946KiB/s, iops=242, runt= 30048msec
read : io=178MiB, bw=6,222KiB/s, iops=189, runt= 30074msec
read : io=152MiB, bw=5,286KiB/s, iops=161, runt= 30093msec
read : io=99MiB, bw=3,446KiB/s, iops=105, runt= 30110msec
READ: io=1,981MiB, aggrb=68,996KiB/s, minb=3,446KiB/s, maxb=14,162KiB/s,
mint=30007msec, maxt=30110msec

Notes:
- It looks like overall throughput is 1-3% less in case of io controller.
- Bandwidth distribution between various prio levels has changed a bit. CFQ
  seems to have 100ms slice length for prio4 and then this slice increases
  by 20% for each prio level as prio increases and decreases by 20% as prio
  levels decrease. So Io controller does not seem to be doing too bad as in
  meeting that distribution.

Group Fairness
+++++++++++++++
Test7 (Isolation between two KVM virtual machines)
==================================================
Created two KVM virtual machines. Partitioned a disk on host in two partitions
and gave one partition to each virtual machine. Put both the virtual machines
in two different cgroup of weight 1000 and 500 each. Virtual machines created
ext3 file system on the partitions exported from host and did buffered writes.
Host seems writes as synchronous and virtual machine with higher weight gets
double the disk time of virtual machine of lower weight. Used deadline
scheduler in this test case.

Some more details about configuration are in documentation patch.

Test8 (Fairness for synchronous reads)
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

Test9 (Reader Vs Buffered Writes)
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
268435456 bytes (268 MB) copied, 6.92248 s, 38.8 MB/s

group1 time=8:16 3185 group1 sectors=8:16 524824
group2 time=8:16 3190 group2 sectors=8:16 503848

Note, reader finishes now much lesser time and both group1 and group2
got almost 3 seconds of disk time. Hence io-controller provides isolation
from buffered writes.

Test10 (AIO)
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

test1 statistics: time=8:16 17955   sectors=8:16 1049656 dq=8:16 2
test2 statistics: time=8:16 9217   sectors=8:16 602592 dq=8:16 1

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

test1 statistics: time=8:16 25452   sectors=8:16 1049664 dq=8:16 2
test2 statistics: time=8:16 12939   sectors=8:16 532184 dq=8:16 4

Above shows that by the time first fio (higher weight), finished, group
test1 got almost double the disk time of group test2.

Test11 (Fairness for async writes, Buffered Write Vs Buffered Write)
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

IOW, the core problem with buffered write fairness is that higher weight thread
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

Previous versions of the patches were posted here.
------------------------------------------------

(V1) http://lkml.org/lkml/2009/3/11/486
(V2) http://lkml.org/lkml/2009/5/5/275
(V3) http://lkml.org/lkml/2009/5/26/472
(V4) http://lkml.org/lkml/2009/6/8/580
(V5) http://lkml.org/lkml/2009/6/19/279
(V6) http://lkml.org/lkml/2009/7/2/369
(V7) http://lkml.org/lkml/2009/7/24/253
(V8) http://lkml.org/lkml/2009/8/16/204

Thanks
Vivek
