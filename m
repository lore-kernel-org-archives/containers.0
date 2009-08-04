From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V7
Date: Mon, 3 Aug 2009 21:30:01 -0400
Message-ID: <20090804013001.GB2282__26666.6757794612$1249349539$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
	<4A727F6F.9010005@cn.fujitsu.com>
	<20090731131359.GA3668@redhat.com>
	<4A778540.5050502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A778540.5050502-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 04, 2009 at 08:48:00AM +0800, Gui Jianfeng wrote:
> Vivek, Here are some test results with and without CONFIG_TRACK_ASYNC_CONTEXT for V7
> 
> Mode                            Normal read   |   Random read   |   Normal write   |   Random write  |  Direct read  |  Direct Write
> 
> CONFIG_TRACK_ASYNC_CONTEXT=y    70,540KiB/s       3,551KiB/s        64,548KiB/s        9,677KiB/s       53,530KiB/s     54,145KiB/s
> 
> CONFIG_TRACK_ASYNC_CONTEXT=n    71,082KiB/s       3,564KiB/s        66,720KiB/s        9,887KiB/s       51,401KiB/s     55,210KiB/s
> 
> Performance                     +0.7%             +0.3%             +3.3%              +2.1%            -4.0%           +2.0%
> 
> 

Strange. Disabling async context tracking should not impact read
performance as reads are always sync and don't take async tracking path
even if it is enabled. We are instead seeing -4% in direct reads if track
async context is disabled. 

I would recommend that there can be lot of variance between multiple runs.
We should probably run each test 3 times and take some average of that.

Thanks
Vivek

> Vivek Goyal wrote:
> > On Fri, Jul 31, 2009 at 01:21:51PM +0800, Gui Jianfeng wrote:
> >> Hi Vivek,
> >>
> >> Here are some test results for normal reads and write for IO Controller V7 by fio.
> >> Tested with "fairness == 0". It seems performance gets better comparing with V6.
> >>
> >> Mode         Normal read   |   Random read   |   Normal write   |   Random write  |  Direct read  |  Direct Write
> >>
> >> 2.6.31-rc1   71,613KiB/s       3,606KiB/s        66,250KiB/s        9,420KiB/s       51,535KiB/s     55,752KiB/s
> >>
> >> V7           70,540KiB/s       3,551KiB/s        64,548KiB/s        9,677KiB/s       53,530KiB/s     54,145KiB/s
> >>
> >> Performance  -1.5%             -1.5%             -2.6%              +2.7%            +3.9%           -2.9%
> >>
> > 
> > Thanks Gui. Can you also try V7 with CONFIG_TRACK_ASYNC_CONTEXT=n. I tried
> > that and I got better results for buffered writes.
> > 
> > In my testing I still see some performance regression for buffered writes
> > which goes away if I disable group io scheduling and just use flat mode.
> > 
> > I will spend more time to find out where it is coming from.
> > 
> > Thanks
> > Vivek
> > 
> > 
> >> Vivek Goyal wrote:
> >>> Hi All,
> >>>
> >>> Here is the V7 of the IO controller patches generated on top of 2.6.31-rc4.
> >>>
> >>> For ease of patching, a consolidated patch is available here.
> >>>
> >>> http://people.redhat.com/~vgoyal/io-controller/io-scheduler-based-io-controller-v7.patch
> >>>
> >>> Previous versions of the patches was posted here.
> >>>
> >>> (V1) http://lkml.org/lkml/2009/3/11/486
> >>> (V2) http://lkml.org/lkml/2009/5/5/275
> >>> (V3) http://lkml.org/lkml/2009/5/26/472
> >>> (V4) http://lkml.org/lkml/2009/6/8/580
> >>> (V5) http://lkml.org/lkml/2009/6/19/279
> >>> (V6) http://lkml.org/lkml/2009/7/2/369
> >>>
> >>> Changes from V6
> >>> ===============
> >>> - Introduced the notion of group_idling where we idle for next request to
> >>>   come from the same group before we expire it. It is along the lines of
> >>>   cfq's slice_idle thing to provide fairness. Switching to group idling
> >>>   now helps in the sense that we don't have to rely whether queue idling
> >>>   was turned on or not by CFQ. It becomes too much of debugging pain with
> >>>   different work loads and different kind of storage media. Introduction
> >>>   of group_idle should help.
> >>>
> >>> - Moved some of the code like dynamic queue idling update, arming queue
> >>>   idling timer, keeping track of average think time etc back to CFQ. With
> >>>   group idling we don't need it now. Reduce the amount of change.
> >>>
> >>> - Enabled cfq's close cooperator functionality in groups. So far this worked
> >>>   only in root group. Now it should work in non-root groups also.
> >>>
> >>> - Got rid of the patch where we calculated disk time based on average disk
> >>>   rate in some circumstances. It was giving bad numbers in early queue
> >>>   deletion cases. Also did not think that it was helping a lot. Remvoed it
> >>>   for the time being.
> >>>  
> >>> - Added an experimental patch to map sync requests using bio tracking info and
> >>>   not task context. This is only for noop, deadline and AS.
> >>>
> >>> - Got rid of experimental patch of idling for async queues. Don't think it
> >>>   was helping.
> >>>
> >>> - Got rid of wait_busy and wait_busy_done logic from queue. Instead
> >>>   implemented it for groups.
> >>>
> >>> - Introduced oom_ioq to accomodate oom_cfqq change recently.
> >>>
> >>> - Broke-up elv_init_ioq() fn into smaller functions. It had 7 arguments and
> >>>   looked complicated.
> >>>
> >>> - Fixed a bug in blk_queue_io_group_congested(). Thanks to Munehiro Ikeda.
> >>>
> >>> - Merged gui's patch to fix the cgroup file format issue.
> >>>
> >>> - Merged gui's patch to update per group congestion limit when
> >>>   q->nr_group_requests is updated.
> >>>
> >>> - Fixed a bug where close cooperation will not work if we wait for all the
> >>>   requests to finish from previous queue.
> >>>
> >>> - Fixed group deletion accouting where deletion from idle tree were also
> >>>   appearing in the log.
> >>>
> >>> - Got rid of busy_rt_queues infrastructure.
> >>>
> >>> - Got rid of elv_ioq_request_dispatched(). An helper function just to
> >>>   increment a variable.
> >>>   
> >>> Limitations
> >>> ===========
> >>>
> >>> - This IO controller provides the bandwidth control at the IO scheduler
> >>>   level (leaf node in stacked hiearchy of logical devices). So there can
> >>>   be cases (depending on configuration) where application does not see
> >>>   proportional BW division at higher logical level device.
> >>>
> >>>   LWN has written an article about the issue here.
> >>>
> >>> 	http://lwn.net/Articles/332839/
> >>>
> >>> How to solve the issue of fairness at higher level logical devices
> >>> ==================================================================
> >>> (Do we really need it? That's not where the contention for resources is.)
> >>>
> >>> Couple of suggestions have come forward.
> >>>
> >>> - Implement IO control at IO scheduler layer and then with the help of
> >>>   some daemon, adjust the weight on underlying devices dynamiclly, depending
> >>>   on what kind of BW gurantees are to be achieved at higher level logical
> >>>   block devices.
> >>>
> >>> - Also implement a higher level IO controller along with IO scheduler
> >>>   based controller and let user choose one depending on his needs.
> >>>
> >>>   A higher level controller does not know about the assumptions/policies
> >>>   of unerldying IO scheduler, hence it has the potential to break down
> >>>   the IO scheduler's policy with-in cgroup. A lower level controller
> >>>   can work with IO scheduler much more closely and efficiently.
> >>>  
> >>> Other active IO controller developments
> >>> =======================================
> >>>
> >>> IO throttling
> >>> -------------
> >>>
> >>>   This is a max bandwidth controller and not the proportional one. Secondly
> >>>   it is a second level controller which can break the IO scheduler's
> >>>   policy/assumtions with-in cgroup. 
> >>>
> >>> dm-ioband
> >>> ---------
> >>>
> >>>  This is a proportional bandwidth controller implemented as device mapper
> >>>  driver. It is also a second level controller which can break the
> >>>  IO scheduler's policy/assumptions with-in cgroup.
> >>>
> >>> TODO
> >>> ====
> >>> - code cleanups, testing, bug fixing, optimizations, benchmarking etc...
> >>>
> >>> Testing
> >>> =======
> >>>
> >>> I have been able to do some testing as follows. All my testing is with ext3
> >>> file system with a SATA drive which supports queue depth of 31.
> >>>
> >>> Test1 (Isolation between two KVM virtual machines)
> >>> ==================================================
> >>> Created two KVM virtual machines. Partitioned a disk on host in two partitions
> >>> and gave one partition to each virtual machine. Put both the virtual machines
> >>> in two different cgroup of weight 1000 and 500 each. Virtual machines created
> >>> ext3 file system on the partitions exported from host and did buffered writes.
> >>> Host seems writes as synchronous and virtual machine with higher weight gets
> >>> double the disk time of virtual machine of lower weight. Used deadline
> >>> scheduler in this test case.
> >>>
> >>> Some more details about configuration are in documentation patch.
> >>>
> >>> Test2 (Fairness for synchronous reads)
> >>> ======================================
> >>> - Two dd in two cgroups with cgrop weights 1000 and 500. Ran two "dd" in those
> >>>   cgroups (With CFQ scheduler and /sys/block/<device>/queue/fairness = 1)
> >>>
> >>>   Higher weight dd finishes first and at that point of time my script takes
> >>>   care of reading cgroup files io.disk_time and io.disk_sectors for both the
> >>>   groups and display the results.
> >>>
> >>>   dd if=/mnt/$BLOCKDEV/zerofile1 of=/dev/null &
> >>>   dd if=/mnt/$BLOCKDEV/zerofile2 of=/dev/null &
> >>>
> >>>   234179072 bytes (234 MB) copied, 3.9065 s, 59.9 MB/s
> >>>   234179072 bytes (234 MB) copied, 5.19232 s, 45.1 MB/s
> >>>
> >>>   group1 time=8 16 2471 group1 sectors=8 16 457840
> >>>   group2 time=8 16 1220 group2 sectors=8 16 225736
> >>>
> >>> First two fields in time and sectors statistics represent major and minor
> >>> number of the device. Third field represents disk time in milliseconds and
> >>> number of sectors transferred respectively.
> >>>
> >>> This patchset tries to provide fairness in terms of disk time received. group1
> >>> got almost double of group2 disk time (At the time of first dd finish). These
> >>> time and sectors statistics can be read using io.disk_time and io.disk_sector
> >>> files in cgroup. More about it in documentation file.
> >>>
> >>> Test3 (Reader Vs Buffered Writes)
> >>> ================================
> >>> Buffered writes can be problematic and can overwhelm readers, especially with
> >>> noop and deadline. IO controller can provide isolation between readers and
> >>> buffered (async) writers.
> >>>
> >>> First I ran the test without io controller to see the severity of the issue.
> >>> Ran a hostile writer and then after 10 seconds started a reader and then
> >>> monitored the completion time of reader. Reader reads a 256 MB file. Tested
> >>> this with noop scheduler.
> >>>
> >>> sample script
> >>> ------------
> >>> sync
> >>> echo 3 > /proc/sys/vm/drop_caches
> >>> time dd if=/dev/zero of=/mnt/sdb/reader-writer-zerofile bs=4K count=2097152
> >>> conv=fdatasync &
> >>> sleep 10
> >>> time dd if=/mnt/sdb/256M-file of=/dev/null &
> >>>
> >>> Results
> >>> -------
> >>> 8589934592 bytes (8.6 GB) copied, 106.045 s, 81.0 MB/s (Writer)
> >>> 268435456 bytes (268 MB) copied, 96.5237 s, 2.8 MB/s (Reader)
> >>>
> >>> Now it was time to test io controller whether it can provide isolation between
> >>> readers and writers with noop. I created two cgroups of weight 1000 each and
> >>> put reader in group1 and writer in group 2 and ran the test again. Upon
> >>> comletion of reader, my scripts read io.dis_time and io.disk_group cgroup
> >>> files to get an estimate how much disk time each group got and how many
> >>> sectors each group did IO for. 
> >>>
> >>> For more accurate accounting of disk time for buffered writes with queuing
> >>> hardware I had to set /sys/block/<disk>/queue/iosched/fairness to "1".
> >>>
> >>> sample script
> >>> -------------
> >>> echo $$ > /cgroup/bfqio/test2/tasks
> >>> dd if=/dev/zero of=/mnt/$BLOCKDEV/testzerofile bs=4K count=2097152 &
> >>> sleep 10
> >>> echo noop > /sys/block/$BLOCKDEV/queue/scheduler
> >>> echo  1 > /sys/block/$BLOCKDEV/queue/iosched/fairness
> >>> echo $$ > /cgroup/bfqio/test1/tasks
> >>> dd if=/mnt/$BLOCKDEV/256M-file of=/dev/null &
> >>> wait $!
> >>> # Some code for reading cgroup files upon completion of reader.
> >>> -------------------------
> >>>
> >>> Results
> >>> =======
> >>> 268435456 bytes (268 MB) copied, 6.65819 s, 40.3 MB/s (Reader) 
> >>>
> >>> group1 time=8 16 3063	group1 sectors=8 16 524808
> >>> group2 time=8 16 3071	group2 sectors=8 16 441752
> >>>
> >>> Note, reader finishes now much lesser time and both group1 and group2
> >>> got almost 3 seconds of disk time. Hence io-controller provides isolation
> >>> from buffered writes.
> >>>
> >>> Test4 (AIO)
> >>> ===========
> >>>
> >>> AIO reads
> >>> -----------
> >>> Set up two fio, AIO read jobs in two cgroup with weight 1000 and 500
> >>> respectively. I am using cfq scheduler. Following are some lines from my test
> >>> script.
> >>>
> >>> ---------------------------------------------------------------
> >>> echo 1000 > /cgroup/bfqio/test1/io.weight
> >>> echo 500 > /cgroup/bfqio/test2/io.weight
> >>>
> >>> fio_args="--ioengine=libaio --rw=read --size=512M --direct=1"
> >>> echo 1 > /sys/block/$BLOCKDEV/queue/iosched/fairness
> >>>
> >>> echo $$ > /cgroup/bfqio/test1/tasks
> >>> fio $fio_args --name=test1 --directory=/mnt/$BLOCKDEV/fio1/
> >>> --output=/mnt/$BLOCKDEV/fio1/test1.log
> >>> --exec_postrun="../read-and-display-group-stats.sh $maj_dev $minor_dev" &
> >>>
> >>> echo $$ > /cgroup/bfqio/test2/tasks
> >>> fio $fio_args --name=test2 --directory=/mnt/$BLOCKDEV/fio2/
> >>> --output=/mnt/$BLOCKDEV/fio2/test2.log &
> >>> ----------------------------------------------------------------
> >>>
> >>> test1 and test2 are two groups with weight 1000 and 500 respectively.
> >>> "read-and-display-group-stats.sh" is one small script which reads the
> >>> test1 and test2 cgroup files to determine how much disk time each group
> >>> got till first fio job finished.
> >>>
> >>> Results
> >>> ------
> >>> test1 statistics: time=8 16 22403   sectors=8 16 1049640
> >>> test2 statistics: time=8 16 11400   sectors=8 16 552864
> >>>
> >>> Above shows that by the time first fio (higher weight), finished, group
> >>> test1 got 22403 ms of disk time and group test2 got 11400 ms of disk time.
> >>> similarly the statistics for number of sectors transferred are also shown.
> >>>
> >>> Note that disk time given to group test1 is almost double of group2 disk
> >>> time.
> >>>
> >>> AIO writes
> >>> ----------
> >>> Set up two fio, AIO direct write jobs in two cgroup with weight 1000 and 500
> >>> respectively. I am using cfq scheduler. Following are some lines from my test
> >>> script.
> >>>
> >>> ------------------------------------------------
> >>> echo 1000 > /cgroup/bfqio/test1/io.weight
> >>> echo 500 > /cgroup/bfqio/test2/io.weight
> >>> fio_args="--ioengine=libaio --rw=write --size=512M --direct=1"
> >>>
> >>> echo 1 > /sys/block/$BLOCKDEV/queue/iosched/fairness
> >>>
> >>> echo $$ > /cgroup/bfqio/test1/tasks
> >>> fio $fio_args --name=test1 --directory=/mnt/$BLOCKDEV/fio1/
> >>> --output=/mnt/$BLOCKDEV/fio1/test1.log
> >>> --exec_postrun="../read-and-display-group-stats.sh $maj_dev $minor_dev" &
> >>>
> >>> echo $$ > /cgroup/bfqio/test2/tasks
> >>> fio $fio_args --name=test2 --directory=/mnt/$BLOCKDEV/fio2/
> >>> --output=/mnt/$BLOCKDEV/fio2/test2.log &
> >>> -------------------------------------------------
> >>>
> >>> test1 and test2 are two groups with weight 1000 and 500 respectively.
> >>> "read-and-display-group-stats.sh" is one small script which reads the
> >>> test1 and test2 cgroup files to determine how much disk time each group
> >>> got till first fio job finished.
> >>>
> >>> Following are the results.
> >>>
> >>> test1 statistics: time=8 16 29085   sectors=8 16 1049656
> >>> test2 statistics: time=8 16 14652   sectors=8 16 516728
> >>>
> >>> Above shows that by the time first fio (higher weight), finished, group
> >>> test1 got 28085 ms of disk time and group test2 got 14652 ms of disk time.
> >>> similarly the statistics for number of sectors transferred are also shown.
> >>>
> >>> Note that disk time given to group test1 is almost double of group2 disk
> >>> time.
> >>>
> >>> Test5 (Fairness for async writes, Buffered Write Vs Buffered Write)
> >>> ===================================================================
> >>> Fairness for async writes is tricky and biggest reason is that async writes
> >>> are cached in higher layers (page cahe) as well as possibly in file system
> >>> layer also (btrfs, xfs etc), and are dispatched to lower layers not necessarily
> >>> in proportional manner.
> >>>
> >>> For example, consider two dd threads reading /dev/zero as input file and doing
> >>> writes of huge files. Very soon we will cross vm_dirty_ratio and dd thread will
> >>> be forced to write out some pages to disk before more pages can be dirtied. But
> >>> not necessarily dirty pages of same thread are picked. It can very well pick
> >>> the inode of lesser priority dd thread and do some writeout. So effectively
> >>> higher weight dd is doing writeouts of lower weight dd pages and we don't see
> >>> service differentation.
> >>>
> >>> IOW, the core problem with async write fairness is that higher weight thread
> >>> does not throw enought IO traffic at IO controller to keep the queue
> >>> continuously backlogged. In my testing, there are many .2 to .8 second
> >>> intervals where higher weight queue is empty and in that duration lower weight
> >>> queue get lots of job done giving the impression that there was no service
> >>> differentiation.
> >>>
> >>> In summary, from IO controller point of view async writes support is there.
> >>> Because page cache has not been designed in such a manner that higher 
> >>> prio/weight writer can do more write out as compared to lower prio/weight
> >>> writer, gettting service differentiation is hard and it is visible in some
> >>> cases and not visible in some cases.
> >>>
> >>> Do we really care that much for fairness among two writer cgroups? One can
> >>> choose to do direct writes or sync writes if fairness for writes really
> >>> matters for him.
> >>>
> >>> Following is the only case where it is hard to ensure fairness between cgroups.
> >>>
> >>> - Buffered writes Vs Buffered Writes.
> >>>
> >>> So to test async writes I created two partitions on a disk and created ext3
> >>> file systems on both the partitions.  Also created two cgroups and generated
> >>> lots of write traffic in two cgroups (50 fio threads) and watched the disk
> >>> time statistics in respective cgroups at the interval of 2 seconds. Thanks to
> >>> ryo tsuruta for the test case.
> >>>
> >>> *****************************************************************
> >>> sync
> >>> echo 3 > /proc/sys/vm/drop_caches
> >>>
> >>> fio_args="--size=64m --rw=write --numjobs=50 --group_reporting"
> >>>
> >>> echo $$ > /cgroup/bfqio/test1/tasks
> >>> fio $fio_args --name=test1 --directory=/mnt/sdd1/fio/ --output=/mnt/sdd1/fio/test1.log &
> >>>
> >>> echo $$ > /cgroup/bfqio/test2/tasks
> >>> fio $fio_args --name=test2 --directory=/mnt/sdd2/fio/ --output=/mnt/sdd2/fio/test2.log &
> >>> *********************************************************************** 
> >>>
> >>> And watched the disk time and sector statistics for the both the cgroups
> >>> every 2 seconds using a script. How is snippet from output.
> >>>
> >>> test1 statistics: time=8 48 1315   sectors=8 48 55776 dq=8 48 1
> >>> test2 statistics: time=8 48 633   sectors=8 48 14720 dq=8 48 2
> >>>
> >>> test1 statistics: time=8 48 5586   sectors=8 48 339064 dq=8 48 2
> >>> test2 statistics: time=8 48 2985   sectors=8 48 146656 dq=8 48 3
> >>>
> >>> test1 statistics: time=8 48 9935   sectors=8 48 628728 dq=8 48 3
> >>> test2 statistics: time=8 48 5265   sectors=8 48 278688 dq=8 48 4
> >>>
> >>> test1 statistics: time=8 48 14156   sectors=8 48 932488 dq=8 48 6
> >>> test2 statistics: time=8 48 7646   sectors=8 48 412704 dq=8 48 7
> >>>
> >>> test1 statistics: time=8 48 18141   sectors=8 48 1231488 dq=8 48 10
> >>> test2 statistics: time=8 48 9820   sectors=8 48 548400 dq=8 48 8
> >>>
> >>> test1 statistics: time=8 48 21953   sectors=8 48 1485632 dq=8 48 13
> >>> test2 statistics: time=8 48 12394   sectors=8 48 698288 dq=8 48 10
> >>>
> >>> test1 statistics: time=8 48 25167   sectors=8 48 1705264 dq=8 48 13
> >>> test2 statistics: time=8 48 14042   sectors=8 48 817808 dq=8 48 10
> >>>
> >>> First two fields in time and sectors statistics represent major and minor
> >>> number of the device. Third field represents disk time in milliseconds and
> >>> number of sectors transferred respectively.
> >>>
> >>> So disk time consumed by group1 is almost double of group2 in this case.
> >>>
> >>> Your feedback is welcome.
> >>>
> >>> Thanks
> >>> Vivek
> >>>
> >>>
> >>>
> >> -- 
> >> Regards
> >> Gui Jianfeng
> > 
> > 
> > 
> 
> -- 
> Regards
> Gui Jianfeng
> 
