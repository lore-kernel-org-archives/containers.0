From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 25 Sep 2009 10:09:52 +0900
Message-ID: <20090925100952.55c2dd7a.kamezawa.hiroyu__31086.5955464125$1253841295$gmane$org@jp.fujitsu.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090924143315.781cd0ac.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 24 Sep 2009 14:33:15 -0700
Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > Test5 (Fairness for async writes, Buffered Write Vs Buffered Write)
> > ===================================================================
> > Fairness for async writes is tricky and biggest reason is that async writes
> > are cached in higher layers (page cahe) as well as possibly in file system
> > layer also (btrfs, xfs etc), and are dispatched to lower layers not necessarily
> > in proportional manner.
> > 
> > For example, consider two dd threads reading /dev/zero as input file and doing
> > writes of huge files. Very soon we will cross vm_dirty_ratio and dd thread will
> > be forced to write out some pages to disk before more pages can be dirtied. But
> > not necessarily dirty pages of same thread are picked. It can very well pick
> > the inode of lesser priority dd thread and do some writeout. So effectively
> > higher weight dd is doing writeouts of lower weight dd pages and we don't see
> > service differentation.
> > 
> > IOW, the core problem with buffered write fairness is that higher weight thread
> > does not throw enought IO traffic at IO controller to keep the queue
> > continuously backlogged. In my testing, there are many .2 to .8 second
> > intervals where higher weight queue is empty and in that duration lower weight
> > queue get lots of job done giving the impression that there was no service
> > differentiation.
> > 
> > In summary, from IO controller point of view async writes support is there.
> > Because page cache has not been designed in such a manner that higher 
> > prio/weight writer can do more write out as compared to lower prio/weight
> > writer, gettting service differentiation is hard and it is visible in some
> > cases and not visible in some cases.
> 
> Here's where it all falls to pieces.
> 
> For async writeback we just don't care about IO priorities.  Because
> from the point of view of the userspace task, the write was async!  It
> occurred at memory bandwidth speed.
> 
> It's only when the kernel's dirty memory thresholds start to get
> exceeded that we start to care about prioritisation.  And at that time,
> all dirty memory (within a memcg?) is equal - a high-ioprio dirty page
> consumes just as much memory as a low-ioprio dirty page.
> 
> So when balance_dirty_pages() hits, what do we want to do?
> 
> I suppose that all we can do is to block low-ioprio processes more
> agressively at the VFS layer, to reduce the rate at which they're
> dirtying memory so as to give high-ioprio processes more of the disk
> bandwidth.
> 
> But you've gone and implemented all of this stuff at the io-controller
> level and not at the VFS level so you're, umm, screwed.
> 

I think I must support dirty-ratio in memcg layer. But not yet.
I can't easily imagine how the system will work if both dirty-ratio and
io-controller cgroup are supported. But considering use them as a set of
cgroup, called containers(zone?), it's will not be bad, I think.

The final bottelneck queue for fairness in usual workload on usual (small)
server will ext3's journal, I wonder ;)

Thanks,
-Kame


> Importantly screwed!  It's a very common workload pattern, and one
> which causes tremendous amounts of IO to be generated very quickly,
> traditionally causing bad latency effects all over the place.  And we
> have no answer to this.
> 
> > Vanilla CFQ Vs IO Controller CFQ
> > ================================
> > We have not fundamentally changed CFQ, instead enhanced it to also support
> > hierarchical io scheduling. In the process invariably there are small changes
> > here and there as new scenarios come up. Running some tests here and comparing
> > both the CFQ's to see if there is any major deviation in behavior.
> > 
> > Test1: Sequential Readers
> > =========================
> > [fio --rw=read --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=<1 to 16> ]
> > 
> > IO scheduler: Vanilla CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   35499KiB/s  35499KiB/s  35499KiB/s  19195 usec  
> > 2   17089KiB/s  13600KiB/s  30690KiB/s  118K usec   
> > 4   9165KiB/s   5421KiB/s   29411KiB/s  380K usec   
> > 8   3815KiB/s   3423KiB/s   29312KiB/s  830K usec   
> > 16  1911KiB/s   1554KiB/s   28921KiB/s  1756K usec  
> > 
> > IO scheduler: IO controller CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   34494KiB/s  34494KiB/s  34494KiB/s  14482 usec  
> > 2   16983KiB/s  13632KiB/s  30616KiB/s  123K usec   
> > 4   9237KiB/s   5809KiB/s   29631KiB/s  372K usec   
> > 8   3901KiB/s   3505KiB/s   29162KiB/s  822K usec   
> > 16  1895KiB/s   1653KiB/s   28945KiB/s  1778K usec  
> > 
> > Test2: Sequential Writers
> > =========================
> > [fio --rw=write --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=<1 to 16> ]
> > 
> > IO scheduler: Vanilla CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   22669KiB/s  22669KiB/s  22669KiB/s  401K usec   
> > 2   14760KiB/s  7419KiB/s   22179KiB/s  571K usec   
> > 4   5862KiB/s   5746KiB/s   23174KiB/s  444K usec   
> > 8   3377KiB/s   2199KiB/s   22427KiB/s  1057K usec  
> > 16  2229KiB/s   556KiB/s    20601KiB/s  5099K usec  
> > 
> > IO scheduler: IO Controller CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   22911KiB/s  22911KiB/s  22911KiB/s  37319 usec  
> > 2   11752KiB/s  11632KiB/s  23383KiB/s  245K usec   
> > 4   6663KiB/s   5409KiB/s   23207KiB/s  384K usec   
> > 8   3161KiB/s   2460KiB/s   22566KiB/s  935K usec   
> > 16  1888KiB/s   795KiB/s    21349KiB/s  3009K usec  
> > 
> > Test3: Random Readers
> > =========================
> > [fio --rw=randread --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=1 to 16]
> > 
> > IO scheduler: Vanilla CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   484KiB/s    484KiB/s    484KiB/s    22596 usec  
> > 2   229KiB/s    196KiB/s    425KiB/s    51111 usec  
> > 4   119KiB/s    73KiB/s     405KiB/s    2344 msec   
> > 8   93KiB/s     23KiB/s     399KiB/s    2246 msec   
> > 16  38KiB/s     8KiB/s      328KiB/s    3965 msec   
> > 
> > IO scheduler: IO Controller CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   483KiB/s    483KiB/s    483KiB/s    29391 usec  
> > 2   229KiB/s    196KiB/s    426KiB/s    51625 usec  
> > 4   132KiB/s    88KiB/s     417KiB/s    2313 msec   
> > 8   79KiB/s     18KiB/s     389KiB/s    2298 msec   
> > 16  43KiB/s     9KiB/s      327KiB/s    3905 msec   
> > 
> > Test4: Random Writers
> > =====================
> > [fio --rw=randwrite --bs=4K --size=2G --runtime=30 --direct=1 --numjobs=1 to 16]
> > 
> > IO scheduler: Vanilla CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   14641KiB/s  14641KiB/s  14641KiB/s  93045 usec  
> > 2   7896KiB/s   1348KiB/s   9245KiB/s   82778 usec  
> > 4   2657KiB/s   265KiB/s    6025KiB/s   216K usec   
> > 8   951KiB/s    122KiB/s    3386KiB/s   1148K usec  
> > 16  66KiB/s     22KiB/s     829KiB/s    1308 msec   
> > 
> > IO scheduler: IO Controller CFQ
> > 
> > nr  Max-bdwidth Min-bdwidth Agg-bdwidth Max-latency 
> > 1   14454KiB/s  14454KiB/s  14454KiB/s  74623 usec  
> > 2   4595KiB/s   4104KiB/s   8699KiB/s   135K usec   
> > 4   3113KiB/s   334KiB/s    5782KiB/s   200K usec   
> > 8   1146KiB/s   95KiB/s     3832KiB/s   593K usec   
> > 16  71KiB/s     29KiB/s     814KiB/s    1457 msec   
> > 
> > Notes:
> >  - Does not look like that anything has changed significantly.
> > 
> > Previous versions of the patches were posted here.
> > ------------------------------------------------
> > 
> > (V1) http://lkml.org/lkml/2009/3/11/486
> > (V2) http://lkml.org/lkml/2009/5/5/275
> > (V3) http://lkml.org/lkml/2009/5/26/472
> > (V4) http://lkml.org/lkml/2009/6/8/580
> > (V5) http://lkml.org/lkml/2009/6/19/279
> > (V6) http://lkml.org/lkml/2009/7/2/369
> > (V7) http://lkml.org/lkml/2009/7/24/253
> > (V8) http://lkml.org/lkml/2009/8/16/204
> > (V9) http://lkml.org/lkml/2009/8/28/327
> > 
> > Thanks
> > Vivek
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
