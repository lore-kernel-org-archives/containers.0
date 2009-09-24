From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Thu, 24 Sep 2009 14:33:15 -0700
Message-ID: <20090924143315.781cd0ac.akpm__24412.2510929175$1253828122$gmane$org@linux-foundation.org>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253820332-10246-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 24 Sep 2009 15:25:04 -0400
Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> 
> Hi All,
> 
> Here is the V10 of the IO controller patches generated on top of 2.6.31.
> 

Thanks for the writeup.  It really helps and is most worthwhile for a
project of this importance, size and complexity.


>  
> What problem are we trying to solve
> ===================================
> Provide group IO scheduling feature in Linux along the lines of other resource
> controllers like cpu.
> 
> IOW, provide facility so that a user can group applications using cgroups and
> control the amount of disk time/bandwidth received by a group based on its
> weight. 
> 
> How to solve the problem
> =========================
> 
> Different people have solved the issue differetnly. So far looks it looks
> like we seem to have following two core requirements when it comes to
> fairness at group level.
> 
> - Control bandwidth seen by groups.
> - Control on latencies when a request gets backlogged in group.
> 
> At least there are now three patchsets available (including this one).
> 
> IO throttling
> -------------
> This is a bandwidth controller which keeps track of IO rate of a group and
> throttles the process in the group if it exceeds the user specified limit.
> 
> dm-ioband
> ---------
> This is a proportional bandwidth controller implemented as device mapper
> driver and provides fair access in terms of amount of IO done (not in terms
> of disk time as CFQ does).
> 
> So one will setup one or more dm-ioband devices on top of physical/logical
> block device, configure the ioband device and pass information like grouping
> etc. Now this device will keep track of bios flowing through it and control
> the flow of bios based on group policies.
> 
> IO scheduler based IO controller
> --------------------------------
> Here we have viewed the problem of IO contoller as hierarchical group
> scheduling (along the lines of CFS group scheduling) issue. Currently one can
> view linux IO schedulers as flat where there is one root group and all the IO
> belongs to that group.
> 
> This patchset basically modifies IO schedulers to also support hierarchical
> group scheduling. CFQ already provides fairness among different processes. I 
> have extended it support group IO schduling. Also took some of the code out
> of CFQ and put in a common layer so that same group scheduling code can be
> used by noop, deadline and AS to support group scheduling. 
> 
> Pros/Cons
> =========
> There are pros and cons to each of the approach. Following are some of the
> thoughts.
> 
> Max bandwidth vs proportional bandwidth
> ---------------------------------------
> IO throttling is a max bandwidth controller and not a proportional one.
> Additionaly it provides fairness in terms of amount of IO done (and not in
> terms of disk time as CFQ does).
> 
> Personally, I think that proportional weight controller is useful to more
> people than just max bandwidth controller. In addition, IO scheduler based
> controller can also be enhanced to do max bandwidth control. So it can 
> satisfy wider set of requirements.
> 
> Fairness in terms of disk time vs size of IO
> ---------------------------------------------
> An higher level controller will most likely be limited to providing fairness
> in terms of size/number of IO done and will find it hard to provide fairness
> in terms of disk time used (as CFQ provides between various prio levels). This
> is because only IO scheduler knows how much disk time a queue has used and
> information about queues and disk time used is not exported to higher
> layers.
> 
> So a seeky application will still run away with lot of disk time and bring
> down the overall throughput of the the disk.

But that's only true if the thing is poorly implemented.

A high-level controller will need some view of the busyness of the
underlying device(s).  That could be "proportion of idle time", or
"average length of queue" or "average request latency" or some mix of
these or something else altogether.

But these things are simple to calculate, and are simple to feed back
to the higher-level controller and probably don't require any changes
to to IO scheduler at all, which is a great advantage.


And I must say that high-level throttling based upon feedback from
lower layers seems like a much better model to me than hacking away in
the IO scheduler layer.  Both from an implementation point of view and
from a "we can get it to work on things other than block devices" point
of view.

> Currently dm-ioband provides fairness in terms of number/size of IO.
> 
> Latencies and isolation between groups
> --------------------------------------
> An higher level controller is generally implementing a bandwidth throttling
> solution where if a group exceeds either the max bandwidth or the proportional
> share then throttle that group.
> 
> This kind of approach will probably not help in controlling latencies as it
> will depend on underlying IO scheduler. Consider following scenario. 
> 
> Assume there are two groups. One group is running multiple sequential readers
> and other group has a random reader. sequential readers will get a nice 100ms
> slice

Do you refer to each reader within group1, or to all readers?  It would be
daft if each reader in group1 were to get 100ms.

> each and then a random reader from group2 will get to dispatch the
> request. So latency of this random reader will depend on how many sequential
> readers are running in other group and that is a weak isolation between groups.

And yet that is what you appear to mean.

But surely nobody would do that - the 100ms would be assigned to and
distributed amongst all readers in group1?

> When we control things at IO scheduler level, we assign one time slice to one
> group and then pick next entity to run. So effectively after one time slice
> (max 180ms, if prio 0 sequential reader is running), random reader in other
> group will get to run. Hence we achieve better isolation between groups as
> response time of process in a differnt group is generally not dependent on
> number of processes running in competing group.  

I don't understand why you're comparing this implementation with such
an obviously dumb competing design!

> So a higher level solution is most likely limited to only shaping bandwidth
> without any control on latencies.
> 
> Stacking group scheduler on top of CFQ can lead to issues
> ---------------------------------------------------------
> IO throttling and dm-ioband both are second level controller. That is these
> controllers are implemented in higher layers than io schedulers. So they
> control the IO at higher layer based on group policies and later IO
> schedulers take care of dispatching these bios to disk.
> 
> Implementing a second level controller has the advantage of being able to
> provide bandwidth control even on logical block devices in the IO stack
> which don't have any IO schedulers attached to these. But they can also 
> interefere with IO scheduling policy of underlying IO scheduler and change
> the effective behavior. Following are some of the issues which I think
> should be visible in second level controller in one form or other.
> 
>   Prio with-in group
>   ------------------
>   A second level controller can potentially interefere with behavior of
>   different prio processes with-in a group. bios are buffered at higher layer
>   in single queue and release of bios is FIFO and not proportionate to the
>   ioprio of the process. This can result in a particular prio level not
>   getting fair share.

That's an administrator error, isn't it?  Should have put the
different-priority processes into different groups.

>   Buffering at higher layer can delay read requests for more than slice idle
>   period of CFQ (default 8 ms). That means, it is possible that we are waiting
>   for a request from the queue but it is buffered at higher layer and then idle
>   timer will fire. It means that queue will losse its share at the same time
>   overall throughput will be impacted as we lost those 8 ms.

That sounds like a bug.

>   Read Vs Write
>   -------------
>   Writes can overwhelm readers hence second level controller FIFO release
>   will run into issue here. If there is a single queue maintained then reads
>   will suffer large latencies. If there separate queues for reads and writes
>   then it will be hard to decide in what ratio to dispatch reads and writes as
>   it is IO scheduler's decision to decide when and how much read/write to
>   dispatch. This is another place where higher level controller will not be in
>   sync with lower level io scheduler and can change the effective policies of
>   underlying io scheduler.

The IO schedulers already take care of read-vs-write and already take
care of preventing large writes-starve-reads latencies (or at least,
they're supposed to).

>   CFQ IO context Issues
>   ---------------------
>   Buffering at higher layer means submission of bios later with the help of
>   a worker thread.

Why?

If it's a read, we just block the userspace process.

If it's a delayed write, the IO submission already happens in a kernel thread.

If it's a synchronous write, we have to block the userspace caller
anyway.

Async reads might be an issue, dunno.

> This changes the io context information at CFQ layer which
>   assigns the request to submitting thread. Change of io context info again
>   leads to issues of idle timer expiry and issue of a process not getting fair
>   share and reduced throughput.

But we already have that problem with delayed writeback, which is a
huge thing - often it's the majority of IO.

>   Throughput with noop, deadline and AS
>   ---------------------------------------------
>   I think an higher level controller will result in reduced overall throughput
>   (as compared to io scheduler based io controller) and more seeks with noop,
>   deadline and AS.
> 
>   The reason being, that it is likely that IO with-in a group will be related
>   and will be relatively close as compared to IO across the groups. For example,
>   thread pool of kvm-qemu doing IO for virtual machine. In case of higher level
>   control, IO from various groups will go into a single queue at lower level
>   controller and it might happen that IO is now interleaved (G1, G2, G1, G3,
>   G4....) causing more seeks and reduced throughput. (Agreed that merging will
>   help up to some extent but still....).
> 
>   Instead, in case of lower level controller, IO scheduler maintains one queue
>   per group hence there is no interleaving of IO between groups. And if IO is
>   related with-in group, then we shoud get reduced number/amount of seek and
>   higher throughput.
> 
>   Latency can be a concern but that can be controlled by reducing the time
>   slice length of the queue.

Well maybe, maybe not.  If a group is throttled, it isn't submitting
new IO.  The unthrottled group is doing the IO submitting and that IO
will have decent locality.

> Fairness at logical device level vs at physical device level
> ------------------------------------------------------------
> 
> IO scheduler based controller has the limitation that it works only with the
> bottom most devices in the IO stack where IO scheduler is attached.
> 
> For example, assume a user has created a logical device lv0 using three
> underlying disks sda, sdb and sdc. Also assume there are two tasks T1 and T2
> in two groups doing IO on lv0. Also assume that weights of groups are in the
> ratio of 2:1 so T1 should get double the BW of T2 on lv0 device.
> 
> 			     T1    T2
> 			       \   /
> 			        lv0
> 			      /  |  \
> 			    sda sdb  sdc
> 
> 
> Now resource control will take place only on devices sda, sdb and sdc and
> not at lv0 level. So if IO from two tasks is relatively uniformly
> distributed across the disks then T1 and T2 will see the throughput ratio
> in proportion to weight specified. But if IO from T1 and T2 is going to
> different disks and there is no contention then at higher level they both
> will see same BW.
> 
> Here a second level controller can produce better fairness numbers at
> logical device but most likely at redued overall throughput of the system,
> because it will try to control IO even if there is no contention at phsical
> possibly leaving diksks unused in the system.
> 
> Hence, question comes that how important it is to control bandwidth at
> higher level logical devices also. The actual contention for resources is
> at the leaf block device so it probably makes sense to do any kind of
> control there and not at the intermediate devices. Secondly probably it
> also means better use of available resources.

hm.  What will be the effects of this limitation in real-world use?

> Limited Fairness
> ----------------
> Currently CFQ idles on a sequential reader queue to make sure it gets its
> fair share. A second level controller will find it tricky to anticipate.
> Either it will not have any anticipation logic and in that case it will not
> provide fairness to single readers in a group (as dm-ioband does) or if it
> starts anticipating then we should run into these strange situations where
> second level controller is anticipating on one queue/group and underlying
> IO scheduler might be anticipating on something else.

It depends on the size of the inter-group timeslices.  If the amount of
time for which a group is unthrottled is "large" comapred to the
typical anticipation times, this issue fades away.

And those timeslices _should_ be large.  Because as you mentioned
above, different groups are probably working different parts of the
disk.

> Need of device mapper tools
> ---------------------------
> A device mapper based solution will require creation of a ioband device
> on each physical/logical device one wants to control. So it requires usage
> of device mapper tools even for the people who are not using device mapper.
> At the same time creation of ioband device on each partition in the system to 
> control the IO can be cumbersome and overwhelming if system has got lots of
> disks and partitions with-in.
> 
> 
> IMHO, IO scheduler based IO controller is a reasonable approach to solve the
> problem of group bandwidth control, and can do hierarchical IO scheduling
> more tightly and efficiently.
> 
> But I am all ears to alternative approaches and suggestions how doing things
> can be done better and will be glad to implement it.
> 
> TODO
> ====
> - code cleanups, testing, bug fixing, optimizations, benchmarking etc...
> - More testing to make sure there are no regressions in CFQ.
> 
> Testing
> =======
> 
> Environment
> ==========
> A 7200 RPM SATA drive with queue depth of 31. Ext3 filesystem.

That's a bit of a toy.

Do we have testing results for more enterprisey hardware?  Big storage
arrays?  SSD?  Infiniband?  iscsi?  nfs? (lol, gotcha)


> I am mostly
> running fio jobs which have been limited to 30 seconds run and then monitored
> the throughput and latency.
>  
> Test1: Random Reader Vs Random Writers
> ======================================
> Launched a random reader and then increasing number of random writers to see
> the effect on random reader BW and max lantecies.
> 
> [fio --rw=randwrite --bs=64K --size=2G --runtime=30 --direct=1 --ioengine=libaio --iodepth=4 --numjobs= <1 to 32> ]
> [fio --rw=randread --bs=4K --size=2G --runtime=30 --direct=1]
> 
> [Vanilla CFQ, No groups]
> <--------------random writers-------------------->  <------random reader-->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   5737KiB/s   5737KiB/s   5737KiB/s   164K usec   503KiB/s    159K usec   
> 2   2055KiB/s   1984KiB/s   4039KiB/s   1459K usec  150KiB/s    170K usec   
> 4   1238KiB/s   932KiB/s    4419KiB/s   4332K usec  153KiB/s    225K usec   
> 8   1059KiB/s   929KiB/s    7901KiB/s   1260K usec  118KiB/s    377K usec   
> 16  604KiB/s    483KiB/s    8519KiB/s   3081K usec  47KiB/s     756K usec   
> 32  367KiB/s    222KiB/s    9643KiB/s   5940K usec  22KiB/s     923K usec   
> 
> Created two cgroups group1 and group2 of weights 500 each.  Launched increasing
> number of random writers in group1 and one random reader in group2 using fio.
> 
> [IO controller CFQ; group_idle=8; group1 weight=500; group2 weight=500]
> <--------------random writers(group1)-------------> <-random reader(group2)->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   18115KiB/s  18115KiB/s  18115KiB/s  604K usec   345KiB/s    176K usec   
> 2   3752KiB/s   3676KiB/s   7427KiB/s   4367K usec  402KiB/s    187K usec   
> 4   1951KiB/s   1863KiB/s   7642KiB/s   1989K usec  384KiB/s    181K usec   
> 8   755KiB/s    629KiB/s    5683KiB/s   2133K usec  366KiB/s    319K usec   
> 16  418KiB/s    369KiB/s    6276KiB/s   1323K usec  352KiB/s    287K usec   
> 32  236KiB/s    191KiB/s    6518KiB/s   1910K usec  337KiB/s    273K usec   

That's a good result.

> Also ran the same test with IO controller CFQ in flat mode to see if there
> are any major deviations from Vanilla CFQ. Does not look like any.
> 
> [IO controller CFQ; No groups ]
> <--------------random writers-------------------->  <------random reader-->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   5696KiB/s   5696KiB/s   5696KiB/s   259K usec   500KiB/s    194K usec   
> 2   2483KiB/s   2197KiB/s   4680KiB/s   887K usec   150KiB/s    159K usec   
> 4   1471KiB/s   1433KiB/s   5817KiB/s   962K usec   126KiB/s    189K usec   
> 8   691KiB/s    580KiB/s    5159KiB/s   2752K usec  197KiB/s    246K usec   
> 16  781KiB/s    698KiB/s    11892KiB/s  943K usec   61KiB/s     529K usec   
> 32  415KiB/s    324KiB/s    12461KiB/s  4614K usec  17KiB/s     737K usec   
> 
> Notes:
> - With vanilla CFQ, random writers can overwhelm a random reader. Bring down
>   its throughput and bump up latencies significantly.

Isn't that a CFQ shortcoming which we should address separately?  If
so, the comparisons aren't presently valid because we're comparing with
a CFQ which has known, should-be-fixed problems.

> - With IO controller, one can provide isolation to the random reader group and
>   maintain consitent view of bandwidth and latencies. 
> 
> Test2: Random Reader Vs Sequential Reader
> ========================================
> Launched a random reader and then increasing number of sequential readers to
> see the effect on BW and latencies of random reader.
> 
> [fio --rw=read --bs=4K --size=2G --runtime=30 --direct=1 --numjobs= <1 to 16> ]
> [fio --rw=randread --bs=4K --size=2G --runtime=30 --direct=1]
> 
> [ Vanilla CFQ, No groups ]
> <---------------seq readers---------------------->  <------random reader-->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   23318KiB/s  23318KiB/s  23318KiB/s  55940 usec  36KiB/s     247K usec   
> 2   14732KiB/s  11406KiB/s  26126KiB/s  142K usec   20KiB/s     446K usec   
> 4   9417KiB/s   5169KiB/s   27338KiB/s  404K usec   10KiB/s     993K usec   
> 8   3360KiB/s   3041KiB/s   25850KiB/s  954K usec   60KiB/s     956K usec   
> 16  1888KiB/s   1457KiB/s   26763KiB/s  1871K usec  28KiB/s     1868K usec  
> 
> Created two cgroups group1 and group2 of weights 500 each.  Launched increasing
> number of sequential readers in group1 and one random reader in group2 using
> fio.
> 
> [IO controller CFQ; group_idle=1; group1 weight=500; group2 weight=500]
> <---------------group1--------------------------->  <------group2--------->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   13733KiB/s  13733KiB/s  13733KiB/s  247K usec   330KiB/s    154K usec   
> 2   8553KiB/s   4963KiB/s   13514KiB/s  472K usec   322KiB/s    174K usec   
> 4   5045KiB/s   1367KiB/s   13134KiB/s  947K usec   318KiB/s    178K usec   
> 8   1774KiB/s   1420KiB/s   13035KiB/s  1871K usec  323KiB/s    233K usec   
> 16  959KiB/s    518KiB/s    12691KiB/s  3809K usec  324KiB/s    208K usec   
> 
> Also ran the same test with IO controller CFQ in flat mode to see if there
> are any major deviations from Vanilla CFQ. Does not look like any.
> 
> [IO controller CFQ; No groups ]
> <---------------seq readers---------------------->  <------random reader-->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   23028KiB/s  23028KiB/s  23028KiB/s  47460 usec  36KiB/s     253K usec   
> 2   14452KiB/s  11176KiB/s  25628KiB/s  145K usec   20KiB/s     447K usec   
> 4   8815KiB/s   5720KiB/s   27121KiB/s  396K usec   10KiB/s     968K usec   
> 8   3335KiB/s   2827KiB/s   24866KiB/s  960K usec   62KiB/s     955K usec   
> 16  1784KiB/s   1311KiB/s   26537KiB/s  1883K usec  26KiB/s     1866K usec  
> 
> Notes:
> - The BW and latencies of random reader in group 2 seems to be stable and
>   bounded and does not get impacted much as number of sequential readers
>   increase in group1. Hence provding good isolation.
> 
> - Throughput of sequential readers comes down and latencies go up as half
>   of disk bandwidth (in terms of time) has been reserved for random reader
>   group.
> 
> Test3: Sequential Reader Vs Sequential Reader
> ============================================
> Created two cgroups group1 and group2 of weights 500 and 1000 respectively.
> Launched increasing number of sequential readers in group1 and one sequential
> reader in group2 using fio and monitored how bandwidth is being distributed
> between two groups.
> 
> First 5 columns give stats about job in group1 and last two columns give
> stats about job in group2.
> 
> <---------------group1--------------------------->  <------group2--------->
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency Agg-bdwidth Max-latency 
> 1   8970KiB/s   8970KiB/s   8970KiB/s   230K usec   20681KiB/s  124K usec   
> 2   6783KiB/s   3202KiB/s   9984KiB/s   546K usec   19682KiB/s  139K usec   
> 4   4641KiB/s   1029KiB/s   9280KiB/s   1185K usec  19235KiB/s  172K usec   
> 8   1435KiB/s   1079KiB/s   9926KiB/s   2461K usec  19501KiB/s  153K usec   
> 16  764KiB/s    398KiB/s    9395KiB/s   4986K usec  19367KiB/s  172K usec   
> 
> Note: group2 is getting double the bandwidth of group1 even in the face
> of increasing number of readers in group1.
> 
> Test4 (Isolation between two KVM virtual machines)
> ==================================================
> Created two KVM virtual machines. Partitioned a disk on host in two partitions
> and gave one partition to each virtual machine. Put both the virtual machines
> in two different cgroup of weight 1000 and 500 each. Virtual machines created
> ext3 file system on the partitions exported from host and did buffered writes.
> Host seems writes as synchronous and virtual machine with higher weight gets
> double the disk time of virtual machine of lower weight. Used deadline
> scheduler in this test case.
> 
> Some more details about configuration are in documentation patch.
> 
> Test5 (Fairness for async writes, Buffered Write Vs Buffered Write)
> ===================================================================
> Fairness for async writes is tricky and biggest reason is that async writes
> are cached in higher layers (page cahe) as well as possibly in file system
> layer also (btrfs, xfs etc), and are dispatched to lower layers not necessarily
> in proportional manner.
> 
> For example, consider two dd threads reading /dev/zero as input file and doing
> writes of huge files. Very soon we will cross vm_dirty_ratio and dd thread will
> be forced to write out some pages to disk before more pages can be dirtied. But
> not necessarily dirty pages of same thread are picked. It can very well pick
> the inode of lesser priority dd thread and do some writeout. So effectively
> higher weight dd is doing writeouts of lower weight dd pages and we don't see
> service differentation.
> 
> IOW, the core problem with buffered write fairness is that higher weight thread
> does not throw enought IO traffic at IO controller to keep the queue
> continuously backlogged. In my testing, there are many .2 to .8 second
> intervals where higher weight queue is empty and in that duration lower weight
> queue get lots of job done giving the impression that there was no service
> differentiation.
> 
> In summary, from IO controller point of view async writes support is there.
> Because page cache has not been designed in such a manner that higher 
> prio/weight writer can do more write out as compared to lower prio/weight
> writer, gettting service differentiation is hard and it is visible in some
> cases and not visible in some cases.

Here's where it all falls to pieces.

For async writeback we just don't care about IO priorities.  Because
from the point of view of the userspace task, the write was async!  It
occurred at memory bandwidth speed.

It's only when the kernel's dirty memory thresholds start to get
exceeded that we start to care about prioritisation.  And at that time,
all dirty memory (within a memcg?) is equal - a high-ioprio dirty page
consumes just as much memory as a low-ioprio dirty page.

So when balance_dirty_pages() hits, what do we want to do?

I suppose that all we can do is to block low-ioprio processes more
agressively at the VFS layer, to reduce the rate at which they're
dirtying memory so as to give high-ioprio processes more of the disk
bandwidth.

But you've gone and implemented all of this stuff at the io-controller
level and not at the VFS level so you're, umm, screwed.

Importantly screwed!  It's a very common workload pattern, and one
which causes tremendous amounts of IO to be generated very quickly,
traditionally causing bad latency effects all over the place.  And we
have no answer to this.

> Vanilla CFQ Vs IO Controller CFQ
> ================================
> We have not fundamentally changed CFQ, instead enhanced it to also support
> hierarchical io scheduling. In the process invariably there are small changes
> here and there as new scenarios come up. Running some tests here and comparing
> both the CFQ's to see if there is any major deviation in behavior.
> 
> Test1: Sequential Readers
> =========================
> [fio --rw=read --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=<1 to 16> ]
> 
> IO scheduler: Vanilla CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   35499KiB/s  35499KiB/s  35499KiB/s  19195 usec  
> 2   17089KiB/s  13600KiB/s  30690KiB/s  118K usec   
> 4   9165KiB/s   5421KiB/s   29411KiB/s  380K usec   
> 8   3815KiB/s   3423KiB/s   29312KiB/s  830K usec   
> 16  1911KiB/s   1554KiB/s   28921KiB/s  1756K usec  
> 
> IO scheduler: IO controller CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   34494KiB/s  34494KiB/s  34494KiB/s  14482 usec  
> 2   16983KiB/s  13632KiB/s  30616KiB/s  123K usec   
> 4   9237KiB/s   5809KiB/s   29631KiB/s  372K usec   
> 8   3901KiB/s   3505KiB/s   29162KiB/s  822K usec   
> 16  1895KiB/s   1653KiB/s   28945KiB/s  1778K usec  
> 
> Test2: Sequential Writers
> =========================
> [fio --rw=write --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=<1 to 16> ]
> 
> IO scheduler: Vanilla CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   22669KiB/s  22669KiB/s  22669KiB/s  401K usec   
> 2   14760KiB/s  7419KiB/s   22179KiB/s  571K usec   
> 4   5862KiB/s   5746KiB/s   23174KiB/s  444K usec   
> 8   3377KiB/s   2199KiB/s   22427KiB/s  1057K usec  
> 16  2229KiB/s   556KiB/s    20601KiB/s  5099K usec  
> 
> IO scheduler: IO Controller CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   22911KiB/s  22911KiB/s  22911KiB/s  37319 usec  
> 2   11752KiB/s  11632KiB/s  23383KiB/s  245K usec   
> 4   6663KiB/s   5409KiB/s   23207KiB/s  384K usec   
> 8   3161KiB/s   2460KiB/s   22566KiB/s  935K usec   
> 16  1888KiB/s   795KiB/s    21349KiB/s  3009K usec  
> 
> Test3: Random Readers
> =========================
> [fio --rw=randread --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=1 to 16]
> 
> IO scheduler: Vanilla CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   484KiB/s    484KiB/s    484KiB/s    22596 usec  
> 2   229KiB/s    196KiB/s    425KiB/s    51111 usec  
> 4   119KiB/s    73KiB/s     405KiB/s    2344 msec   
> 8   93KiB/s     23KiB/s     399KiB/s    2246 msec   
> 16  38KiB/s     8KiB/s      328KiB/s    3965 msec   
> 
> IO scheduler: IO Controller CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   483KiB/s    483KiB/s    483KiB/s    29391 usec  
> 2   229KiB/s    196KiB/s    426KiB/s    51625 usec  
> 4   132KiB/s    88KiB/s     417KiB/s    2313 msec   
> 8   79KiB/s     18KiB/s     389KiB/s    2298 msec   
> 16  43KiB/s     9KiB/s      327KiB/s    3905 msec   
> 
> Test4: Random Writers
> =====================
> [fio --rw=randwrite --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=1 to 16]
> 
> IO scheduler: Vanilla CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   14641KiB/s  14641KiB/s  14641KiB/s  93045 usec  
> 2   7896KiB/s   1348KiB/s   9245KiB/s   82778 usec  
> 4   2657KiB/s   265KiB/s    6025KiB/s   216K usec   
> 8   951KiB/s    122KiB/s    3386KiB/s   1148K usec  
> 16  66KiB/s     22KiB/s     829KiB/s    1308 msec   
> 
> IO scheduler: IO Controller CFQ
> 
> nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> 1   14454KiB/s  14454KiB/s  14454KiB/s  74623 usec  
> 2   4595KiB/s   4104KiB/s   8699KiB/s   135K usec   
> 4   3113KiB/s   334KiB/s    5782KiB/s   200K usec   
> 8   1146KiB/s   95KiB/s     3832KiB/s   593K usec   
> 16  71KiB/s     29KiB/s     814KiB/s    1457 msec   
> 
> Notes:
>  - Does not look like that anything has changed significantly.
> 
> Previous versions of the patches were posted here.
> ------------------------------------------------
> 
> (V1) http://lkml.org/lkml/2009/3/11/486
> (V2) http://lkml.org/lkml/2009/5/5/275
> (V3) http://lkml.org/lkml/2009/5/26/472
> (V4) http://lkml.org/lkml/2009/6/8/580
> (V5) http://lkml.org/lkml/2009/6/19/279
> (V6) http://lkml.org/lkml/2009/7/2/369
> (V7) http://lkml.org/lkml/2009/7/24/253
> (V8) http://lkml.org/lkml/2009/8/16/204
> (V9) http://lkml.org/lkml/2009/8/28/327
> 
> Thanks
> Vivek
