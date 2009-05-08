From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IO scheduler based IO Controller V2
Date: Fri, 8 May 2009 22:05:01 +0200
Message-ID: <20090508200458.GA3708__32918.9299060546$1241813278$gmane$org@linux>
References: <20090506023332.GA1212@redhat.com>
	<20090506203228.GH8180@redhat.com> <20090506213453.GC4282@linux>
	<20090506215235.GJ8180@redhat.com> <20090507090450.GA4613@linux>
	<20090507141126.GA9463@redhat.com>
	<20090507144501.GB9463@redhat.com>
	<20090507153642.GC9463@redhat.com> <20090507221900.GA29774@linux>
	<20090508180951.GG7293@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090508180951.GG7293-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 08, 2009 at 02:09:51PM -0400, Vivek Goyal wrote:
> On Fri, May 08, 2009 at 12:19:01AM +0200, Andrea Righi wrote:
> > On Thu, May 07, 2009 at 11:36:42AM -0400, Vivek Goyal wrote:
> > > Hmm.., my old config had "AS" as default scheduler that's why I was seeing
> > > the strange issue of RT task finishing after BE. My apologies for that. I
> > > somehow assumed that CFQ is default scheduler in my config.
> > 
> > ok.
> > 
> > > 
> > > So I have re-run the test to see if we are still seeing the issue of
> > > loosing priority and class with-in cgroup. And we still do..
> > > 
> > > 2.6.30-rc4 with io-throttle patches
> > > ===================================
> > > Test1
> > > =====
> > > - Two readers, one BE prio 0 and other BE prio 7 in a cgroup limited with
> > >   8MB/s BW.
> > > 
> > > 234179072 bytes (234 MB) copied, 55.8448 s, 4.2 MB/s
> > > prio 0 task finished
> > > 234179072 bytes (234 MB) copied, 55.8878 s, 4.2 MB/s
> > > 
> > > Test2
> > > =====
> > > - Two readers, one RT prio 0 and other BE prio 7 in a cgroup limited with
> > >   8MB/s BW.
> > > 
> > > 234179072 bytes (234 MB) copied, 55.8876 s, 4.2 MB/s
> > > 234179072 bytes (234 MB) copied, 55.8984 s, 4.2 MB/s
> > > RT task finished
> > 
> > ok, coherent with the current io-throttle implementation.
> > 
> > > 
> > > Test3
> > > =====
> > > - Reader Starvation
> > > - I created a cgroup with BW limit of 64MB/s. First I just run the reader
> > >   alone and then I run reader along with 4 writers 4 times. 
> > > 
> > > Reader alone
> > > 234179072 bytes (234 MB) copied, 3.71796 s, 63.0 MB/s
> > > 
> > > Reader with 4 writers
> > > ---------------------
> > > First run
> > > 234179072 bytes (234 MB) copied, 30.394 s, 7.7 MB/s 
> > > 
> > > Second run
> > > 234179072 bytes (234 MB) copied, 26.9607 s, 8.7 MB/s
> > > 
> > > Third run
> > > 234179072 bytes (234 MB) copied, 37.3515 s, 6.3 MB/s
> > > 
> > > Fourth run
> > > 234179072 bytes (234 MB) copied, 36.817 s, 6.4 MB/s
> > > 
> > > Note that out of 64MB/s limit of this cgroup, reader does not get even
> > > 1/5 of the BW. In normal systems, readers are advantaged and reader gets
> > > its job done much faster even in presence of multiple writers.   
> > 
> > And this is also coherent. The throttling is equally probable for read
> > and write. But this shouldn't happen if we saturate the physical disk BW
> > (doing proportional BW control or using a watermark close to 100 in
> > io-throttle). In this case IO scheduler logic shouldn't be totally
> > broken.
> >
> 
> Can you please explain the watermark a bit more? So blockio.watermark=90
> mean 90% of what? total disk BW? But disk BW varies based on work load?

The controller starts to apply throttling rules only when the total disk
BW utilization is greater than 90%.

The consumed BW is evaluated as (cpu_ticks / io_ticks * 100), where
cpu_ticks are the ticks (in jiffies) since the last i/o request and
io_ticks is the difference of ticks accounted to a particular block
device, retrieved by:

part_stat_read(bdev->bd_part, io_ticks)

BTW it's the same metric (%util) used by iostat.

> 
> > Doing a very quick test with io-throttle, using a 10MB/s BW limit and
> > blockio.watermark=90:
> > 
> > Launching reader
> > 256+0 records in
> > 256+0 records out
> > 268435456 bytes (268 MB) copied, 32.2798 s, 8.3 MB/s
> > 
> > In the same time the writers wrote ~190MB, so the single reader got
> > about 1/3 of the total BW.
> > 
> > 182M testzerofile4
> > 198M testzerofile1
> > 188M testzerofile3
> > 189M testzerofile2
> > 
> 
> But its now more a max bw controller at all now? I seem to be getting the
> total BW of (268+182+198+188+189)/32 = 32MB/s and you set the limit to
> 10MB/s?
>  

The limit of 10MB/s is applied only when the consumed disk BW hits 90%.

If the disk is not fully saturated no limit is applied. It's nothing
more than soft limiting, to avoid to waste the unused disk BW that we
have with hard limits. This is similar to the proportional approach from
a certain point of view.

But ok, this only reduces the number of times that we block the IO
requests. The fact is that when we apply throttling the probability to
block a read or a write it's the same also in this case.

> 
> [..]
> > What are the results with your IO scheduler controller (if you already
> > have them, otherwise I'll repeat this test in my system)? It seems a
> > very interesting test to compare the advantages of the IO scheduler
> > solution respect to the io-throttle approach.
> > 
> 
> I had not done any reader writer testing so far. But you forced me to run
> some now. :-) Here are the results. 

Good! :)

> 
> Because one is max BW controller and other is proportional BW controller
> doing exact comparison is hard. Still....
> 
> Test1
> =====
> Try to run lots of writers (50 random writers using fio and 4 sequential
> writers with dd if=/dev/zero) and one single reader either in root group
> or with in one cgroup to show that readers are not starved by writers
> as opposed to io-throttle controller.
> 
> Run test1 with vanilla kernel with CFQ
> =====================================
> Launched 50 fio random writers, 4 sequential writers and 1 reader in root
> and noted how long it takes reader to finish. Also noted the per second output
> from iostat -d 1 -m /dev/sdb1 to monitor how disk throughput varies.
> 
> ***********************************************************************
> # launch 50 writers fio job
> 
> fio_args="--size=64m --rw=write --numjobs=50 --group_reporting"
> fio $fio_args --name=test2 --directory=/mnt/sdb/fio2/ --output=/mnt/sdb/fio2/test2.log > /dev/null  &
> 
> #launch 4 sequential writers
> ionice -c 2 -n 7 dd if=/dev/zero of=/mnt/sdb/testzerofile1 bs=4K count=524288 &
> ionice -c 2 -n 7 dd if=/dev/zero of=/mnt/sdb/testzerofile2 bs=4K count=524288 &
> ionice -c 2 -n 7 dd if=/dev/zero of=/mnt/sdb/testzerofile3 bs=4K count=524288 &
> ionice -c 2 -n 7 dd if=/dev/zero of=/mnt/sdb/testzerofile4 bs=4K count=524288 &
> 
> echo "Sleeping for 5 seconds"
> sleep 5
> echo "Launching reader"
> 
> ionice -c 2 -n 0 dd if=/mnt/sdb/zerofile2 of=/dev/zero &
> wait $!
> echo "Reader Finished"
> ***************************************************************************
> 
> Results
> -------
> 234179072 bytes (234 MB) copied, 4.55047 s, 51.5 MB/s
> 
> Reader finished in 4.5 seconds. Following are few lines from iostat output
> 
> ***********************************************************************
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            151.00         0.04        48.33          0         48
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            120.00         1.78        31.23          1         31
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            504.95        56.75         7.51         57          7
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            547.47        62.71         4.47         62          4
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            441.00        49.80         7.82         49          7
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            441.41        48.28        13.84         47         13
> 
> *************************************************************************
> 
> Note how, first write picks up and then suddenly reader comes in and CFQ
> allocates a huge chunk of BW to reader to give it the advantage.
> 
> Run Test1 with IO scheduler based io controller patch
> =====================================================
> 
> 234179072 bytes (234 MB) copied, 5.23141 s, 44.8 MB/s 
> 
> Reader finishes in 5.23 seconds. Why does it take more time than CFQ,
> because looks like current algorithm is not punishing writers that hard.
> This can be fixed and not an issue.
> 
> Following is some output from iostat.
> 
> **********************************************************************
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            139.60         0.04        43.83          0         44
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            227.72        16.88        29.05         17         29
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            349.00        35.04        16.06         35         16
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            339.00        34.16        21.07         34         21
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            343.56        36.68        12.54         37         12
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            378.00        38.68        19.47         38         19
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            532.00        59.06        10.00         59         10
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            125.00         2.62        38.82          2         38
> ************************************************************************
> 
> Note how read throughput goes up when reader comes in. Also note that
> writer is still getting some decent IO done and that's why reader took
> little bit more time as compared to CFQ.
> 
> 
> Run Test1 with IO throttle patches
> ==================================
> 
> Now same test is run with io-throttle patches. The only difference is that
> it run the test in a cgroup with max limit of 32MB/s. That should mean 
> that effectvily we got a disk which can support at max 32MB/s of IO rate.
> If we look at above CFQ and io controller results, it looks like with
> above load we touched a peak of 70MB/s.  So one can think of same test
> being run on a disk roughly half the speed of original disk.
> 
> 234179072 bytes (234 MB) copied, 144.207 s, 1.6 MB/s
> 
> Reader got a disk rate of 1.6MB/s (5 %) out of 32MB/s capacity, as opposed to
> the case CFQ and io scheduler controller where reader got around 70-80% of
> disk BW under similar work load.
> 
> Test2
> =====
> Run test2 with io scheduler based io controller
> ===============================================
> Now run almost same test with a little difference. This time I create two
> cgroups of same weight 1000. I run the 50 fio random writer in one cgroup
> and 4 sequential writers and 1 reader in second group. This test is more
> to show that proportional BW IO controller is working and because of
> reader in group1, group2 writes are not killed (providing isolation) and
> secondly, reader still gets preference over the writers which are in same
> group.
> 
> 				root
> 			     /       \		
> 			  group1     group2
> 		  (50 fio writers)   ( 4 writers and one reader)
> 
> 234179072 bytes (234 MB) copied, 12.8546 s, 18.2 MB/s
> 
> Reader finished in almost 13 seconds and got around 18MB/s. Remember when
> everything was in root group reader got around 45MB/s. This is to account
> for the fact that half of the disk is now being shared by other cgroup
> which are running 50 fio writes and reader can't steal the disk from them.
> 
> Following is some portion of iostat output when reader became active
> *********************************************************************
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            103.92         0.03        40.21          0         41
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            240.00        15.78        37.40         15         37
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            206.93        13.17        28.50         13         28
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            224.75        15.39        27.89         15         28
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            270.71        16.85        25.95         16         25
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            215.84         8.81        32.40          8         32
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            216.16        19.11        20.75         18         20
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            211.11        14.67        35.77         14         35
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            208.91        15.04        26.95         15         27
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            277.23        24.30        28.53         24         28
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            202.97        12.29        34.79         12         35
> **********************************************************************
> 
> Total disk throughput is varying a lot, on an average it looks like it
> is getting 45MB/s. Lets say 50% of that is going to cgroup1 (fio writers),
> then out of rest of 22 MB/s reader seems to have to 18MB/s. These are
> highly approximate numbers. I think I need to come up with some kind of 
> tool to measure per cgroup throughput (like we have for per partition
> stat) for more accurate comparision.
> 
> But the point is that second cgroup got the isolation and read got
> preference with-in same cgroup. The expected behavior.
> 
> Run test2 with io-throttle
> ==========================
> Same setup of two groups. The only difference is that I setup two groups
> with (16MB) limit. So previous 32MB limit got divided between two cgroups
> 50% each.
> 
> - 234179072 bytes (234 MB) copied, 90.8055 s, 2.6 MB/s
> 
> Reader took 90 seconds to finish.  It seems to have got around 16% of
> available disk BW (16MB) to it.
> 
> iostat output is long. Will just paste one section.
> 
> ************************************************************************
> [..]
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            141.58        10.16        16.12         10         16
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            174.75         8.06        12.31          7         12
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1             47.52         0.12         6.16          0          6
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1             82.00         0.00        31.85          0         31
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1            141.00         0.00        48.07          0         48
> 
> Device:            tps    MB_read/s    MB_wrtn/s    MB_read    MB_wrtn
> sdb1             72.73         0.00        26.52          0         26
>  
> 
> ***************************************************************************
> 
> Conclusion
> ==========
> It just reaffirms that with max BW control, we are not doing a fair job
> of throttling hence no more hold the IO scheduler properties with-in
> cgroup.
> 
> With proportional BW controller implemented at IO scheduler level, one
> can do very tight integration with IO controller and hence retain 
> IO scheduler behavior with-in cgroup.

It is worth to bug you I would say :). Results are interesting,
definitely. I'll check if it's possible to merge part of the io-throttle
max BW control in this controller and who knows if finally we'll be able
to converge to a common proposal...

Thanks,
-Andrea
