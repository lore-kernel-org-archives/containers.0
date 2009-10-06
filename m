From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Tue, 6 Oct 2009 07:22:01 -0400
Message-ID: <20091006112201.GA27866__7844.47183036736$1254828662$gmane$org@redhat.com>
References: <20091005.235535.193690928.ryov@valinux.co.jp>
	<20091005171023.GG22143@redhat.com>
	<e98e18940910051111r110dc776l5105bf931761b842@mail.gmail.com>
	<20091006.161744.189719641.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091006.161744.189719641.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

On Tue, Oct 06, 2009 at 04:17:44PM +0900, Ryo Tsuruta wrote:
> Hi Vivek and Nauman,
> 
> Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > >> > > How about adding a callback function to the higher level controller?
> > >> > > CFQ calls it when the active queue runs out of time, then the higer
> > >> > > level controller use it as a trigger or a hint to move IO group, so
> > >> > > I think a time-based controller could be implemented at higher level.
> > >> > >
> > >> >
> > >> > Adding a call back should not be a big issue. But that means you are
> > >> > planning to run only one group at higher layer at one time and I think
> > >> > that's the problem because than we are introducing serialization at higher
> > >> > layer. So any higher level device mapper target which has multiple
> > >> > physical disks under it, we might be underutilizing these even more and
> > >> > take a big hit on overall throughput.
> > >> >
> > >> > The whole design of doing proportional weight at lower layer is optimial
> > >> > usage of system.
> > >>
> > >> But I think that the higher level approch makes easy to configure
> > >> against striped software raid devices.
> > >
> > > How does it make easier to configure in case of higher level controller?
> > >
> > > In case of lower level design, one just have to create cgroups and assign
> > > weights to cgroups. This mininum step will be required in higher level
> > > controller also. (Even if you get rid of dm-ioband device setup step).
> 
> In the case of lower level controller, if we need to assign weights on
> a per device basis, we have to assign weights to all devices of which
> a raid device consists, but in the case of higher level controller, 
> we just assign weights to the raid device only.
> 

This is required only if you need to assign different weights to different
devices. This is just additional facility and not a requirement. Normally
you will not be required to do that and devices will inherit the cgroup
weights automatically. So one has to only assign the cgroup weights.

> > >> If one would like to
> > >> combine some physical disks into one logical device like a dm-linear,
> > >> I think one should map the IO controller on each physical device and
> > >> combine them into one logical device.
> > >>
> > >
> > > In fact this sounds like a more complicated step where one has to setup
> > > one dm-ioband device on top of each physical device. But I am assuming
> > > that this will go away once you move to per reuqest queue like implementation.
> 
> I don't understand why the per request queue implementation makes it
> go away. If dm-ioband is integrated into the LVM tools, it could allow
> users to skip the complicated steps to configure dm-linear devices.
> 

Those who are not using dm-tools will be forced to use dm-tools for
bandwidth control features.

> > > I think it should be same in principal as my initial implementation of IO
> > > controller on request queue and I stopped development on it because of FIFO
> > > dispatch.
> 
> I think that FIFO dispatch seldom lead to prioviry inversion, because
> holding period for throttling is not too long to break the IO priority.
> I did some tests to see whether priority inversion is happened.
> 
> The first test ran fio sequential readers on the same group. The BE0
> reader got the highest throughput as I expected.
> 
> nr_threads      16      |      16    |     1
> ionice          BE7     |     BE7    |    BE0
> ------------------------+------------+-------------
> vanilla     10,076KiB/s | 9,779KiB/s | 32,775KiB/s
> ioband       9,576KiB/s | 9,367KiB/s | 34,154KiB/s
> 
> The second test ran fio sequential readers on two different groups and
> give weights of 20 and 10 to each group respectively. The bandwidth
> was distributed according to their weights and the BE0 reader got
> higher throughput than the BE7 readers in the same group. IO priority
> was preserved within the IO group.
> 
> group         group1    |         group2
> weight          20      |           10    
> ------------------------+--------------------------
> nr_threads      16      |      16    |     1
> ionice          BE7     |     BE7    |    BE0
> ------------------------+--------------------------
> ioband      27,513KiB/s | 3,524KiB/s | 10,248KiB/s
>                         |     Total = 13,772KiB/s
> 

Interesting. In all the test cases you always test with sequential
readers. I have changed the test case a bit (I have already reported the
results in another mail, now running the same test again with dm-version
1.14). I made all the readers doing direct IO and in other group I put
a buffered writer. So setup looks as follows.

In group1, I launch 1 prio 0 reader and increasing number of prio4
readers. In group 2 I just run a dd doing buffered writes. Weights of
both the groups are 100 each.

Following are the results on 2.6.31 kernel.

With-dm-ioband
==============
<------------prio4 readers---------------------->  <---prio0 reader------>
nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
1   9992KiB/s   9992KiB/s   9992KiB/s   413K usec   4621KiB/s   369K usec   
2   4859KiB/s   4265KiB/s   9122KiB/s   344K usec   4915KiB/s   401K usec   
4   2238KiB/s   1381KiB/s   7703KiB/s   532K usec   3195KiB/s   546K usec   
8   504KiB/s    46KiB/s     1439KiB/s   399K usec   7661KiB/s   220K usec   
16  131KiB/s    26KiB/s     638KiB/s    492K usec   4847KiB/s   359K usec   

With vanilla CFQ
================
<------------prio4 readers---------------------->  <---prio0 reader------>
nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
1   10779KiB/s  10779KiB/s  10779KiB/s  407K usec   16094KiB/s  808K usec   
2   7045KiB/s   6913KiB/s   13959KiB/s  538K usec   18794KiB/s  761K usec   
4   7842KiB/s   4409KiB/s   20967KiB/s  876K usec   12543KiB/s  443K usec   
8   6198KiB/s   2426KiB/s   24219KiB/s  1469K usec  9483KiB/s   685K usec   
16  5041KiB/s   1358KiB/s   27022KiB/s  2417K usec  6211KiB/s   1025K usec  


Above results are showing how bandwidth got distributed between prio4 and
prio1 readers with-in group as we increased number of prio4 readers in
the group. In another group a buffered writer is continuously going on
as competitor.

Notice, with dm-ioband how bandwidth allocation is broken.

With 1 prio4 reader, prio4 reader got more bandwidth than prio1 reader.

With 2 prio4 readers, looks like prio4 got almost same BW as prio1.

With 8 and 16 prio4 readers, looks like prio0 readers takes over and prio4
readers starve.

As we incresae number of prio4 readers in the group, their total aggregate
BW share should increase. Instread it is decreasing.

So to me in the face of competition with a writer in other group, BW is
all over the place. Some of these might be dm-ioband bugs and some of
these might be coming from the fact that buffering takes place in higher
layer and dispatch is FIFO?

> Here is my test script.
> -------------------------------------------------------------------------
> arg="--time_base --rw=read --runtime=30 --directory=/mnt1 --size=1024M \
>      --group_reporting"
> 
> sync
> echo 3 > /proc/sys/vm/drop_caches
> 
> echo $$ > /cgroup/1/tasks
> ionice -c 2 -n 0 fio $arg --name=read1 --output=read1.log --numjobs=16 &
> echo $$ > /cgroup/2/tasks
> ionice -c 2 -n 0 fio $arg --name=read2 --output=read2.log --numjobs=16 &
> ionice -c 1 -n 0 fio $arg --name=read3 --output=read3.log --numjobs=1 &
> echo $$ > /cgroup/tasks
> wait
> -------------------------------------------------------------------------
> 
> Be that as it way, I think that if every bio can point the iocontext
> of the process, then it makes it possible to handle IO priority in the
> higher level controller. A patchse has already posted by Takhashi-san.
> What do you think about this idea?
> 
>   Date Tue, 22 Apr 2008 22:51:31 +0900 (JST)
>   Subject [RFC][PATCH 1/10] I/O context inheritance
>   From Hirokazu Takahashi <>
>   http://lkml.org/lkml/2008/4/22/195

So far you have been denying that there are issues with ioprio with-in
group in higher level controller. Here you seems to be saying that there are
issues with ioprio and we need to take this patch in to solve the issue? I am
confused?

Anyway, if you think that above patch is needed to solve the issue of
ioprio in higher level controller, why are you not posting it as part of
your patch series regularly, so that we can also apply this patch along
with other patches and test the effects?

> 
> > > So you seem to be suggesting that you will move dm-ioband to request queue
> > > so that setting up additional device setup is gone. You will also enable
> > > it to do time based groups policy, so that we don't run into issues on
> > > seeky media. Will also enable dispatch from one group only at a time so
> > > that we don't run into isolation issues and can do time accounting
> > > accruately.
> > 
> > Will that approach solve the problem of doing bandwidth control on
> > logical devices? What would be the advantages compared to Vivek's
> > current patches?
> 
> I will only move the point where dm-ioband grabs bios, other
> dm-ioband's mechanism and functionality will stll be the same.
> The advantages against to scheduler based controllers are:
>  - can work with any type of block devices
>  - can work with any type of IO scheduler and no need a big change.
> 

The big change thing we will come to know for sure when we have
implementation for the timed groups done and shown that it works as well as my
patches. There are so many subtle things with time based approach. 

[..]
> > >> > Is there a new version of dm-ioband now where you have solved the issue of
> > >> > sync/async dispatch with-in group? Before meeting at mini-summit, I am
> > >> > trying to run some tests and come up with numbers so that we have more
> > >> > clear picture of pros/cons.
> > >>
> > >> Yes, I've released new versions of dm-ioband and blkio-cgroup. The new
> > >> dm-ioband handles sync/async IO requests separately and
> > >> the write-starve-read issue you pointed out is fixed. I would
> > >> appreciate it if you would try them.
> > >> http://sourceforge.net/projects/ioband/files/
> > >
> > > Cool. Will get to testing it.
> 
> Thanks for your help in advance.

Against what kernel version above patches apply. The biocgroup patches
I tried against 2.6.31 as well as 2.6.32-rc1 and it does not apply cleanly
against any of these?

So for the time being I am doing testing with biocgroup patches.

Thanks
Vivek
