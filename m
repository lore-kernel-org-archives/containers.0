From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Wed, 7 Oct 2009 11:09:29 -0400
Message-ID: <20091007150929.GB3674__38403.591400902$1254928426$gmane$org@redhat.com>
References: <e98e18940910051111r110dc776l5105bf931761b842@mail.gmail.com>
	<20091006.161744.189719641.ryov@valinux.co.jp>
	<20091006112201.GA27866@redhat.com>
	<20091007.233805.183040347.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091007.233805.183040347.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Oct 07, 2009 at 11:38:05PM +0900, Ryo Tsuruta wrote:
> Hi Vivek,
> 
> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > >> If one would like to
> > > > >> combine some physical disks into one logical device like a dm-linear,
> > > > >> I think one should map the IO controller on each physical device and
> > > > >> combine them into one logical device.
> > > > >>
> > > > >
> > > > > In fact this sounds like a more complicated step where one has to setup
> > > > > one dm-ioband device on top of each physical device. But I am assuming
> > > > > that this will go away once you move to per reuqest queue like implementation.
> > > 
> > > I don't understand why the per request queue implementation makes it
> > > go away. If dm-ioband is integrated into the LVM tools, it could allow
> > > users to skip the complicated steps to configure dm-linear devices.
> > > 
> > 
> > Those who are not using dm-tools will be forced to use dm-tools for
> > bandwidth control features.
> 
> If once dm-ioband is integrated into the LVM tools and bandwidth can
> be assigned per device by lvcreate, the use of dm-tools is no longer
> required for users.

But it is same thing. Now LVM tools is mandatory to use?

> 
> > Interesting. In all the test cases you always test with sequential
> > readers. I have changed the test case a bit (I have already reported the
> > results in another mail, now running the same test again with dm-version
> > 1.14). I made all the readers doing direct IO and in other group I put
> > a buffered writer. So setup looks as follows.
> > 
> > In group1, I launch 1 prio 0 reader and increasing number of prio4
> > readers. In group 2 I just run a dd doing buffered writes. Weights of
> > both the groups are 100 each.
> > 
> > Following are the results on 2.6.31 kernel.
> > 
> > With-dm-ioband
> > ==============
> > <------------prio4 readers---------------------->  <---prio0 reader------>
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> > 1   9992KiB/s   9992KiB/s   9992KiB/s   413K usec   4621KiB/s   369K usec   
> > 2   4859KiB/s   4265KiB/s   9122KiB/s   344K usec   4915KiB/s   401K usec   
> > 4   2238KiB/s   1381KiB/s   7703KiB/s   532K usec   3195KiB/s   546K usec   
> > 8   504KiB/s    46KiB/s     1439KiB/s   399K usec   7661KiB/s   220K usec   
> > 16  131KiB/s    26KiB/s     638KiB/s    492K usec   4847KiB/s   359K usec   
> > 
> > With vanilla CFQ
> > ================
> > <------------prio4 readers---------------------->  <---prio0 reader------>
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> > 1   10779KiB/s  10779KiB/s  10779KiB/s  407K usec   16094KiB/s  808K usec   
> > 2   7045KiB/s   6913KiB/s   13959KiB/s  538K usec   18794KiB/s  761K usec   
> > 4   7842KiB/s   4409KiB/s   20967KiB/s  876K usec   12543KiB/s  443K usec   
> > 8   6198KiB/s   2426KiB/s   24219KiB/s  1469K usec  9483KiB/s   685K usec   
> > 16  5041KiB/s   1358KiB/s   27022KiB/s  2417K usec  6211KiB/s   1025K usec  
> > 
> > 
> > Above results are showing how bandwidth got distributed between prio4 and
> > prio1 readers with-in group as we increased number of prio4 readers in
> > the group. In another group a buffered writer is continuously going on
> > as competitor.
> > 
> > Notice, with dm-ioband how bandwidth allocation is broken.
> > 
> > With 1 prio4 reader, prio4 reader got more bandwidth than prio1 reader.
> > 
> > With 2 prio4 readers, looks like prio4 got almost same BW as prio1.
> > 
> > With 8 and 16 prio4 readers, looks like prio0 readers takes over and prio4
> > readers starve.
> > 
> > As we incresae number of prio4 readers in the group, their total aggregate
> > BW share should increase. Instread it is decreasing.
> > 
> > So to me in the face of competition with a writer in other group, BW is
> > all over the place. Some of these might be dm-ioband bugs and some of
> > these might be coming from the fact that buffering takes place in higher
> > layer and dispatch is FIFO?
> 
> Thank you for testing. I did the same test and here are the results.
> 
> with vanilla CFQ
>    <------------prio4 readers------------------>   prio0       group2
>       maxbw       minbw      aggrbw     maxlat     aggrbw      bufwrite
>  1 12,140KiB/s 12,140KiB/s 12,140KiB/s 30001msec 11,125KiB/s  1,923KiB/s
>  2  3,967KiB/s  3,930KiB/s  7,897KiB/s 30001msec 14,213KiB/s  1,586KiB/s
>  4  3,399KiB/s  3,066KiB/s 13,031KiB/s 30082msec  8,930KiB/s  1,296KiB/s
>  8  2,086KiB/s  1,720KiB/s 15,266KiB/s 30003msec  7,546KiB/s    517KiB/s
> 16  1,156KiB/s    837KiB/s 15,377KiB/s 30033msec  4,282KiB/s    600KiB/s
> 
> with dm-ioband weight-iosize policy
>    <------------prio4 readers------------------>   prio0       group2
>       maxbw       minbw      aggrbw     maxlat     aggrbw      bufwrite
>  1    107KiB/s    107KiB/s    107KiB/s 30007msec 12,242KiB/s 12,320KiB/s
>  2  1,259KiB/s    702KiB/s  1,961KiB/s 30037msec  9,657KiB/s 11,657KiB/s
>  4  2,705KiB/s     29KiB/s  5,186KiB/s 30026msec  5,927KiB/s 11,300KiB/s
>  8  2,428KiB/s     27KiB/s  5,629KiB/s 30054msec  5,057KiB/s 10,704KiB/s
> 16  2,465KiB/s     23KiB/s  4,309KiB/s 30032msec  4,750KiB/s  9,088KiB/s
> 
> The results are somewhat different from yours. The bandwidth is
> distributed to each group equally, but CFQ priority is broken as you
> said. I think that the reason is not because of FIFO, but because
> some IO requests are issued from dm-ioband's kernel thread on behalf of
> processes which origirante the IO requests, then CFQ assumes that the
> kernel thread is the originator and uses its io_context.

Ok. Our numbers can vary a bit depending on fio settings like block size
and underlying storage also. But that's not the important thing. Currently
with this test I just wanted to point out that model of ioprio with-in group
is currently broken with dm-ioband and good that you can reproduce that.

One minor nit, for max latency you need to look at "clat " row and "max=" field
in fio output. Most of the time "max latency" will matter most. You seem to
be currently grepping for "maxt" which is just seems to be telling how
long did test run and in this case 30 seconds.

Assigning reads to right context in CFQ and not to dm-ioband thread might
help a bit, but I am bit skeptical and following is the reason.

CFQ relies on time providing longer time slice length for higher priority
process and if one does not use time slice, it looses its share. So the moment
you buffer even single bio of a process in dm-layer, if CFQ was servicing that
process at same time, that process will loose its share. CFQ will at max
anticipate for 8 ms and if buffering is longer than 8ms, CFQ will expire the
queue and move on to next queue. Later if you submit same bio and with
dm-ioband helper thread and even if CFQ attributes it to right process, it is
not going to help much as process already lost it slice and now a new slice
will start.

> 
> > > Here is my test script.
> > > -------------------------------------------------------------------------
> > > arg="--time_base --rw=read --runtime=30 --directory=/mnt1 --size=1024M \
> > >      --group_reporting"
> > > 
> > > sync
> > > echo 3 > /proc/sys/vm/drop_caches
> > > 
> > > echo $$ > /cgroup/1/tasks
> > > ionice -c 2 -n 0 fio $arg --name=read1 --output=read1.log --numjobs=16 &
> > > echo $$ > /cgroup/2/tasks
> > > ionice -c 2 -n 0 fio $arg --name=read2 --output=read2.log --numjobs=16 &
> > > ionice -c 1 -n 0 fio $arg --name=read3 --output=read3.log --numjobs=1 &
> > > echo $$ > /cgroup/tasks
> > > wait
> > > -------------------------------------------------------------------------
> > > 
> > > Be that as it way, I think that if every bio can point the iocontext
> > > of the process, then it makes it possible to handle IO priority in the
> > > higher level controller. A patchse has already posted by Takhashi-san.
> > > What do you think about this idea?
> > > 
> > >   Date Tue, 22 Apr 2008 22:51:31 +0900 (JST)
> > >   Subject [RFC][PATCH 1/10] I/O context inheritance
> > >   From Hirokazu Takahashi <>
> > >   http://lkml.org/lkml/2008/4/22/195
> > 
> > So far you have been denying that there are issues with ioprio with-in
> > group in higher level controller. Here you seems to be saying that there are
> > issues with ioprio and we need to take this patch in to solve the issue? I am
> > confused?
> 
> The true intention of this patch is to preserve the io-context of a
> process which originate it, but I think that we could also make use of
> this patch for one of the way to solve this issue.
> 

Ok. Did you run the same test with this patch applied and how do numbers look
like? Can you please forward port it to 2.6.31 and I will also like to
play with it?

I am running more tests/numbers with 2.6.31 for all the IO controllers and
planning to post it to lkml before we meet for IO mini summit. Numbers can
help us understand the issue better.

In first phase I am planning to post numbers for IO scheudler controller
and dm-ioband. Then will get to max bw controller of Andrea Righi.

> > Anyway, if you think that above patch is needed to solve the issue of
> > ioprio in higher level controller, why are you not posting it as part of
> > your patch series regularly, so that we can also apply this patch along
> > with other patches and test the effects?
> 
> I will post the patch, but I would like to find out and understand the
> reason of above test results before posting the patch.
> 

Ok. So in the mean time, I will continue to do testing with dm-ioband
version 1.14.0 and post the numbers.

> > Against what kernel version above patches apply. The biocgroup patches
> > I tried against 2.6.31 as well as 2.6.32-rc1 and it does not apply cleanly
> > against any of these?
> > 
> > So for the time being I am doing testing with biocgroup patches.
> 
> I created those patches against 2.6.32-rc1 and made sure the patches
> can be cleanly applied to that version.

I am applying dm-ioband patch first and then bio cgroup patches. Is this
right order? Will try again.

Anyway, don't have too much time for IO mini summit, so will stick to
2.6.31 for the time being. If time permits, will venture into 32-rc1 also.

Thanks
Vivek
