From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Performance numbers with IO throttling patches (Was: Re: IO
	scheduler based IO controller V10)
Date: Sun, 11 Oct 2009 00:27:30 +0200
Message-ID: <20091010222728.GA30943__22393.76495495$1255213766$gmane$org@linux>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
	<20091010195316.GB16510@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091010195316.GB16510-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Oct 10, 2009 at 03:53:16PM -0400, Vivek Goyal wrote:
> On Thu, Sep 24, 2009 at 02:33:15PM -0700, Andrew Morton wrote:
> 
> [..]
> > > Environment
> > > ==========
> > > A 7200 RPM SATA drive with queue depth of 31. Ext3 filesystem.
> > 
> > That's a bit of a toy.
> > 
> > Do we have testing results for more enterprisey hardware?  Big storage
> > arrays?  SSD?  Infiniband?  iscsi?  nfs? (lol, gotcha)
> > 
> > 
> 
> Hi All,

Hi Vivek,

thanks for posting this detailed report first of all. A few comments
below.

> 
> Couple of days back I posted some performance number of "IO scheduler
> controller" and "dm-ioband" here.
> 
> http://lkml.org/lkml/2009/10/8/9
> 
> Now I have run similar tests with Andrea Righi's IO throttling approach
> of max bandwidth control. This is the exercise to understand pros/cons
> of each approach and see how can we take things forward.
> 
> Environment
> ===========
> Software
> --------
> - 2.6.31 kenrel
> - IO scheduler controller V10 on top of 2.6.31
> - IO throttling patch on top of 2.6.31. Patch is available here.
> 
> http://www.develer.com/~arighi/linux/patches/io-throttle/old/cgroup-io-throttle-2.6.31.patch
> 
> Hardware
> --------
> A storage array of 5 striped disks of 500GB each.
> 
> Used fio jobs for 30 seconds in various configurations. Most of the IO is
> direct IO to eliminate the effects of caches.
> 
> I have run three sets for each test. Blindly reporting results of set2
> from each test, otherwise it is too much of data to report.
> 
> Had lun of 2500GB capacity. Used 200G partition with ext3 file system for
> my testing. For IO scheduler controller testing, created two cgroups of 
> weight 100 each so that effectively disk can be divided half/half between
> two groups.
> 
> For IO throttling patches also created two cgroups. Now tricky part is
> that it is a max bw controller and not a proportional weight controller.
> So dividing the disk capacity half/half between two cgroups is tricky. The
> reason being I just don't know what's the BW capacity of underlying
> storage. Throughput varies so much with type of workload. For example, on
> my arrary, this is how throughput looks like with different workloads.
> 
> 8 sequential buffered readers 			115 MB/s
> 8 direct sequential readers bs=64K		64 MB/s
> 8 direct sequential readers bs=4K		14 MB/s
> 
> 8 buffered random readers bs=64K		3 MB/s
> 8 direct random readers bs=64K			15 MB/s
> 8 direct random readers bs=4K			1.5 MB/s
> 
> So throughput seems to be varying from 1.5 MB/s to 115 MB/s depending
> on workload. What should be the BW limits per cgroup to divide disk BW
> in half/half between two groups?
> 
> So I took a conservative estimate and divide max bandwidth divide by 2,
> and thought of array capacity as 60MB/s and assign each cgroup 30MB/s. In
> some cases I have assigened even 10MB/s or 5MB/s to each cgropu to see the
> effects of throttling. I am using "Leaky bucket" policy for all the tests.
> 
> As theme of two controllers is different, at some places it might sound
> like apples vs oranges comparison. But still it does help...
> 
> Multiple Random Reader vs Sequential Reader
> ===============================================
> Generally random readers bring the throughput down of others in the
> system. Ran a test to see the impact of increasing number of random readers on
> single sequential reader in different groups.
> 
> Vanilla CFQ
> -----------------------------------
> [Multiple Random Reader]                      [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   23KB/s    23KB/s    22KB/s    691 msec    1   13519KB/s 468K usec   
> 2   152KB/s   152KB/s   297KB/s   244K usec   1   12380KB/s 31675 usec  
> 4   174KB/s   156KB/s   638KB/s   249K usec   1   10860KB/s 36715 usec  
> 8   49KB/s    11KB/s    310KB/s   1856 msec   1   1292KB/s  990K usec   
> 16  63KB/s    48KB/s    877KB/s   762K usec   1   3905KB/s  506K usec   
> 32  35KB/s    27KB/s    951KB/s   2655 msec   1   1109KB/s  1910K usec  
> 
> IO scheduler controller + CFQ
> -----------------------------------
> [Multiple Random Reader]                      [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   228KB/s   228KB/s   223KB/s   132K usec   1   5551KB/s  129K usec   
> 2   97KB/s    97KB/s    190KB/s   154K usec   1   5718KB/s  122K usec   
> 4   115KB/s   110KB/s   445KB/s   208K usec   1   5909KB/s  116K usec   
> 8   23KB/s    12KB/s    158KB/s   2820 msec   1   5445KB/s  168K usec   
> 16  11KB/s    3KB/s     145KB/s   5963 msec   1   5418KB/s  164K usec   
> 32  6KB/s     2KB/s     139KB/s   12762 msec  1   5398KB/s  175K usec   
> 
> Notes:
> - Sequential reader in group2 seems to be well isolated from random readers
>   in group1. Throughput and latency of sequential reader are stable and
>   don't drop as number of random readers inrease in system.
> 
> io-throttle + CFQ
> ------------------
> BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> [Multiple Random Reader]                      [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   37KB/s    37KB/s    36KB/s    218K usec   1   8006KB/s  20529 usec  
> 2   185KB/s   183KB/s   360KB/s   228K usec   1   7475KB/s  33665 usec  
> 4   188KB/s   171KB/s   699KB/s   262K usec   1   6800KB/s  46224 usec  
> 8   84KB/s    51KB/s    573KB/s   1800K usec  1   2835KB/s  885K usec   
> 16  21KB/s    9KB/s     294KB/s   3590 msec   1   437KB/s   1855K usec  
> 32  34KB/s    27KB/s    980KB/s   2861K usec  1   1145KB/s  1952K usec  
> 
> Notes:
> - I have setup limits of 10MB/s in both the cgroups. Now random reader
>   group will never achieve that kind of speed, so it will not be throttled
>   and then it goes onto impact the throughput and latency of other groups
>   in the system.
> 
> - Now the key question is how conservative one should in be setting up 
>   max BW limit. On this box if a customer has bought 10MB/s cgroup and if
>   he is running some random readers it will kill throughput of other
>   groups in the system and their latencies will shoot up. No isolation in
>   this case.
> 
> - So in general, max BW provides isolation from high speed groups but it
>   does not provide isolaton from random reader groups which are moving
>   slow.

Remember that in addition to blockio.bandwidth-max the io-throttle
controlller also provides blockio.iops-max to enforce hard limits on the
number of IO operations per second. Probably for this testcase both
cgroups should be limited in terms of BW and iops to achieve a better
isolation.

> 
> Multiple Sequential Reader vs Random Reader
> ===============================================
> Now running a reverse test where in one group I am running increasing
> number of sequential readers and in other group I am running one random
> reader and see the impact of sequential readers on random reader.
> 
> Vanilla CFQ
> -----------------------------------
> [Multiple Sequential Reader]                  [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   13978KB/s 13978KB/s 13650KB/s 27614 usec  1   22KB/s    227 msec    
> 2   6225KB/s  6166KB/s  12101KB/s 568K usec   1   10KB/s    457 msec    
> 4   4052KB/s  2462KB/s  13107KB/s 322K usec   1   6KB/s     841 msec    
> 8   1899KB/s  557KB/s   12960KB/s 829K usec   1   13KB/s    1628 msec   
> 16  1007KB/s  279KB/s   13833KB/s 1629K usec  1   10KB/s    3236 msec   
> 32  506KB/s   98KB/s    13704KB/s 3389K usec  1   6KB/s     3238 msec   
> 
> IO scheduler controller + CFQ
> -----------------------------------
> [Multiple Sequential Reader]                  [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   5721KB/s  5721KB/s  5587KB/s  126K usec   1   223KB/s   126K usec   
> 2   3216KB/s  1442KB/s  4549KB/s  349K usec   1   224KB/s   176K usec   
> 4   1895KB/s  640KB/s   5121KB/s  775K usec   1   222KB/s   189K usec   
> 8   957KB/s   285KB/s   6368KB/s  1680K usec  1   223KB/s   142K usec   
> 16  458KB/s   132KB/s   6455KB/s  3343K usec  1   219KB/s   165K usec   
> 32  248KB/s   55KB/s    6001KB/s  6957K usec  1   220KB/s   504K usec   
> 
> Notes:
> - Random reader is well isolated from increasing number of sequential
>   readers in other group. BW and latencies are stable.
>  
> io-throttle + CFQ
> -----------------------------------
> BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> [Multiple Sequential Reader]                  [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   8200KB/s  8200KB/s  8007KB/s  20275 usec  1   37KB/s    217K usec   
> 2   3926KB/s  3919KB/s  7661KB/s  122K usec   1   16KB/s    441 msec    
> 4   2271KB/s  1497KB/s  7672KB/s  611K usec   1   9KB/s     927 msec    
> 8   1113KB/s  513KB/s   7507KB/s  849K usec   1   21KB/s    1020 msec   
> 16  661KB/s   236KB/s   7959KB/s  1679K usec  1   13KB/s    2926 msec   
> 32  292KB/s   109KB/s   7864KB/s  3446K usec  1   8KB/s     3439 msec   
> 
> BW limit group1=5 MB/s                        BW limit group2=5 MB/s    
> [Multiple Sequential Reader]                  [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   4686KB/s  4686KB/s  4576KB/s  21095 usec  1   57KB/s    219K usec   
> 2   2298KB/s  2179KB/s  4372KB/s  132K usec   1   37KB/s    431K usec   
> 4   1245KB/s  1019KB/s  4449KB/s  324K usec   1   26KB/s    835 msec    
> 8   584KB/s   403KB/s   4109KB/s  833K usec   1   30KB/s    1625K usec  
> 16  346KB/s   252KB/s   4605KB/s  1641K usec  1   129KB/s   3236K usec  
> 32  175KB/s   56KB/s    4269KB/s  3236K usec  1   8KB/s     3235 msec   
> 
> Notes:
> 
> - Above result is surprising to me. I have run it twice. In first run, I
>   setup per cgroup limit as 10MB/s and in second run I set it up 5MB/s. In
>   both the cases as number of sequential readers increase in other groups, 
>   random reader's throughput decreases and latencies increase. This is
>   happening despite the fact that sequential readers are being throttled
>   to make sure it does not impact workload in other group. Wondering why
>   random readers are not seeing consistent throughput and latencies.

Maybe because CFQ is still trying to be fair among processes instead of
cgroups. Remember that io-throttle doesn't touch the CFQ code (for this
I'm definitely convinced that CFQ should be changed to think also in
terms of cgroups, and io-throttle alone is not enough).

So, even if group1 is being throttled in part it is still able to submit
some requests that get a higher priority respect to the requests
submitted by the single random reader task.

It could be interesting to test another IO scheduler (deadline, as or
even noop) to check if this is the actual problem.

> 
> - Andrea, can you please also run similar tests to see if you see same
>   results or not. This is to rule out any testing methodology errors or
>   scripting bugs. :-). I also have collected the snapshot of some cgroup
>   files like bandwidth-max, throttlecnt, and stats. Let me know if you want
>   those to see what is happenig here. 

Sure, I'll do some tests ASAP. Another interesting test would be to set
a blockio.iops-max limit also for the sequential readers' cgroup, to be
sure we're not touching some iops physical disk limit.

Could you post all the options you used with fio, so I can repeat some
tests as similar as possible to yours?

> 
> Multiple Sequential Reader vs Sequential Reader
> ===============================================
> - This time running random readers are out of the picture and trying to
>   see the effect of increasing number of sequential readers on another
>   sequential reader running in a different group.
> 
> Vanilla CFQ
> -----------------------------------
> [Multiple Sequential Reader]                  [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   6325KB/s  6325KB/s  6176KB/s  114K usec   1   6902KB/s  120K usec   
> 2   4588KB/s  3102KB/s  7510KB/s  571K usec   1   4564KB/s  680K usec   
> 4   3242KB/s  1158KB/s  9469KB/s  495K usec   1   3198KB/s  410K usec   
> 8   1775KB/s  459KB/s   12011KB/s 1178K usec  1   1366KB/s  818K usec   
> 16  943KB/s   296KB/s   13285KB/s 1923K usec  1   728KB/s   1816K usec  
> 32  511KB/s   148KB/s   13555KB/s 3286K usec  1   391KB/s   3212K usec  
> 
> IO scheduler controller + CFQ
> -----------------------------------
> [Multiple Sequential Reader]                  [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   6781KB/s  6781KB/s  6622KB/s  109K usec   1   6691KB/s  115K usec   
> 2   3758KB/s  1876KB/s  5502KB/s  693K usec   1   6373KB/s  419K usec   
> 4   2100KB/s  671KB/s   5751KB/s  987K usec   1   6330KB/s  569K usec   
> 8   1023KB/s  355KB/s   6969KB/s  1569K usec  1   6086KB/s  120K usec   
> 16  520KB/s   130KB/s   7094KB/s  3140K usec  1   5984KB/s  119K usec   
> 32  245KB/s   86KB/s    6621KB/s  6571K usec  1   5850KB/s  113K usec   
> 
> Notes:
> - BW and latencies of sequential reader in group 2 are fairly stable as
>   number of readers increase in first group.
> 
> io-throttle + CFQ
> -----------------------------------
> BW limit group1=30 MB/s                       BW limit group2=30 MB/s   
> [Multiple Sequential Reader]                  [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   6343KB/s  6343KB/s  6195KB/s  116K usec   1   6993KB/s  109K usec   
> 2   4583KB/s  3046KB/s  7451KB/s  583K usec   1   4516KB/s  433K usec   
> 4   2945KB/s  1324KB/s  9552KB/s  602K usec   1   3001KB/s  583K usec   
> 8   1804KB/s  473KB/s   12257KB/s 861K usec   1   1386KB/s  815K usec   
> 16  942KB/s   265KB/s   13560KB/s 1659K usec  1   718KB/s   1658K usec  
> 32  462KB/s   143KB/s   13757KB/s 3482K usec  1   409KB/s   3480K usec  
> 
> Notes:
> - BW decreases and latencies increase in group2 as number of readers
>   increase in first group. This should be due to fact that no throttling
>   will happen as none of the groups is hitting the limit of 30MB/s. To
>   me this is the tricky part. How a service provider is supposed to 
>   set the limit of groups. If groups are not hitting max limits, it will
>   still impact the BW and latencies in other group.

Are you using 4k block size here? because in case of too small blocks
you could hit some physical iops limit. Also for this case it could be
interesting to see what happens setting both BW and iops hard limits.

> 
> BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> [Multiple Sequential Reader]                  [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   4128KB/s  4128KB/s  4032KB/s  215K usec   1   4076KB/s  170K usec   
> 2   2880KB/s  1886KB/s  4655KB/s  291K usec   1   2891KB/s  212K usec   
> 4   1912KB/s  888KB/s   5872KB/s  417K usec   1   1881KB/s  411K usec   
> 8   1032KB/s  432KB/s   7312KB/s  841K usec   1   853KB/s   816K usec   
> 16  540KB/s   259KB/s   7844KB/s  1728K usec  1   503KB/s   1609K usec  
> 32  291KB/s   111KB/s   7920KB/s  3417K usec  1   249KB/s   3205K usec  
> 
> Notes:
> - Same test with 10MB/s as group limit. This is again a surprising result.
>   Max BW in first group is being throttled but still throughput is
>   dropping significantly in second group and latencies are on the rise.

Same consideration about CFQ and/or iops limit. Could you post all the
fio options you've used also for this test (or better, for all tests)?

> 
> - Limit of first group is 10MB/s but it is achieving max BW of around
>   8MB/s only. What happened to rest of the 2MB/s?

Ditto.

> 
> - Andrea, again, please do run this test. The throughput drop in second
>   group stumps me and forces me to think if I am doing something wrong.  
> 
> BW limit group1=5 MB/s                        BW limit group2=5 MB/s    
> [Multiple Sequential Reader]                  [Sequential Reader]       
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   2434KB/s  2434KB/s  2377KB/s  110K usec   1   2415KB/s  120K usec   
> 2   1639KB/s  1186KB/s  2759KB/s  222K usec   1   1709KB/s  220K usec   
> 4   1114KB/s  648KB/s   3314KB/s  420K usec   1   1163KB/s  414K usec   
> 8   567KB/s   366KB/s   4060KB/s  901K usec   1   527KB/s   816K usec   
> 16  329KB/s   179KB/s   4324KB/s  1613K usec  1   311KB/s   1613K usec  
> 32  178KB/s   70KB/s    4320KB/s  3235K usec  1   163KB/s   3209K usec  
> 
> - Setting the limit to 5MB/s per group also does not seem to be helping
>   the second group.
> 
> Multiple Random Writer vs Random Reader
> ===============================================
> This time running multiple random writers in first group and see the
> impact on throughput and latency of random reader in different group.
> 
> Vanilla CFQ
> -----------------------------------
> [Multiple Random Writer]                      [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   64018KB/s 64018KB/s 62517KB/s 353K usec   1   190KB/s   96 msec     
> 2   35298KB/s 35257KB/s 68899KB/s 208K usec   1   76KB/s    2416 msec   
> 4   16387KB/s 14662KB/s 60630KB/s 3746K usec  1   106KB/s   2308K usec  
> 8   5106KB/s  3492KB/s  33335KB/s 2995K usec  1   193KB/s   2292K usec  
> 16  3676KB/s  3002KB/s  51807KB/s 2283K usec  1   72KB/s    2298K usec  
> 32  2169KB/s  1480KB/s  56882KB/s 1990K usec  1   35KB/s    1093 msec   
> 
> IO scheduler controller + CFQ
> -----------------------------------
> [Multiple Random Writer]                      [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   20369KB/s 20369KB/s 19892KB/s 877K usec   1   255KB/s   137K usec   
> 2   14347KB/s 14288KB/s 27964KB/s 1010K usec  1   228KB/s   117K usec   
> 4   6996KB/s  6701KB/s  26775KB/s 1362K usec  1   221KB/s   180K usec   
> 8   2849KB/s  2770KB/s  22007KB/s 2660K usec  1   250KB/s   485K usec   
> 16  1463KB/s  1365KB/s  22384KB/s 2606K usec  1   254KB/s   115K usec   
> 32  799KB/s   681KB/s   22404KB/s 2879K usec  1   266KB/s   107K usec   
> 
> Notes
> - BW and latencies of random reader in second group are fairly stable.
> 
> io-throttle + CFQ
> -----------------------------------
> BW limit group1=30 MB/s                       BW limit group2=30 MB/s   
> [Multiple Random Writer]                      [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   21920KB/s 21920KB/s 21406KB/s 1017K usec  1   353KB/s   432K usec   
> 2   14291KB/s 9626KB/s  23357KB/s 1832K usec  1   362KB/s   177K usec   
> 4   7130KB/s  5135KB/s  24736KB/s 1336K usec  1   348KB/s   425K usec   
> 8   3165KB/s  2949KB/s  23792KB/s 2133K usec  1   336KB/s   146K usec   
> 16  1653KB/s  1406KB/s  23694KB/s 2198K usec  1   337KB/s   115K usec   
> 32  793KB/s   717KB/s   23198KB/s 2195K usec  1   330KB/s   192K usec   
> 
> BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> [Multiple Random Writer]                      [Random Reader]           
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   7903KB/s  7903KB/s  7718KB/s  1037K usec  1   474KB/s   103K usec   
> 2   4496KB/s  4428KB/s  8715KB/s  1091K usec  1   450KB/s   553K usec   
> 4   2153KB/s  1827KB/s  7914KB/s  2042K usec  1   458KB/s   108K usec   
> 8   1129KB/s  1087KB/s  8688KB/s  1280K usec  1   432KB/s   98215 usec  
> 16  606KB/s   527KB/s   8668KB/s  2303K usec  1   426KB/s   90609 usec  
> 32  312KB/s   259KB/s   8599KB/s  2557K usec  1   441KB/s   95283 usec  
> 
> Notes:
> - IO throttling seems to be working really well here. Random writers are
>   contained in the first group and this gives stable BW and latencies
>   to random reader in second group.
> 
> Multiple Buffered Writer vs Buffered Writer
> ===========================================
> This time run multiple buffered writers in group1 and see run a single
> buffered writer in other group and see if we can provide fairness and
> isolation.
> 
> Vanilla CFQ
> ------------
> [Multiple Buffered Writer]                    [Buffered Writer]         
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   68997KB/s 68997KB/s 67380KB/s 645K usec   1   67122KB/s 567K usec   
> 2   47509KB/s 46218KB/s 91510KB/s 865K usec   1   45118KB/s 865K usec   
> 4   28002KB/s 26906KB/s 105MB/s   1649K usec  1   26879KB/s 1643K usec  
> 8   15985KB/s 14849KB/s 117MB/s   943K usec   1   15653KB/s 766K usec   
> 16  11567KB/s 6881KB/s  128MB/s   1174K usec  1   7333KB/s  947K usec   
> 32  5877KB/s  3649KB/s  130MB/s   1205K usec  1   5142KB/s  988K usec   
> 
> IO scheduler controller + CFQ
> -----------------------------------
> [Multiple Buffered Writer]                    [Buffered Writer]         
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   68580KB/s 68580KB/s 66972KB/s 2901K usec  1   67194KB/s 2901K usec  
> 2   47419KB/s 45700KB/s 90936KB/s 3149K usec  1   44628KB/s 2377K usec  
> 4   27825KB/s 27274KB/s 105MB/s   1177K usec  1   27584KB/s 1177K usec  
> 8   15382KB/s 14288KB/s 114MB/s   1539K usec  1   14794KB/s 783K usec   
> 16  9161KB/s  7592KB/s  124MB/s   3177K usec  1   7713KB/s  886K usec   
> 32  4928KB/s  3961KB/s  126MB/s   1152K usec  1   6465KB/s  4510K usec  
> 
> Notes:
> - It does not work. Buffered writer in second group are being overwhelmed
>   by writers in group1.
> 
> - This is a limitation of IO scheduler based controller currently as page
>   cache at higher layer evens out the traffic and does not throw more
>   traffic from higher weight group.
> 
> - This is something needs more work at higher layers like dirty limts
>   per cgroup in memory contoller and the method to writeout buffered 
>   pages belonging to a particular memory cgroup. This is still being
>   brainstormed.
> 
> io-throttle + CFQ
> -----------------------------------
> BW limit group1=30 MB/s                       BW limit group2=30 MB/s   
> [Multiple Buffered Writer]                    [Buffered Writer]         
> nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> 1   33863KB/s 33863KB/s 33070KB/s 3046K usec  1   25165KB/s 13248K usec 
> 2   13457KB/s 12906KB/s 25745KB/s 9286K usec  1   29958KB/s 3736K usec  
> 4   7414KB/s  6543KB/s  27145KB/s 10557K usec 1   30968KB/s 8356K usec  
> 8   3562KB/s  2640KB/s  24430KB/s 12012K usec 1   30801KB/s 7037K usec  
> 16  3962KB/s  881KB/s   26632KB/s 12650K usec 1   31150KB/s 7173K usec  
> 32  3275KB/s  406KB/s   27295KB/s 14609K usec 1   26328KB/s 8069K usec  
> 
> Notes:
> - This seems to work well here. io-throttle is throttling the writers
>   before they write too much of data in page cache. One side effect of
>   this seems to be that now a process will not be allowed to write at
>   memory speed in page cahce and will be limited to disk IO speed limits
>   set for the cgroup.
> 
>   Andrea is thinking of removing throttling in balance_dirty_pages() to allow
>   writting at disk speed till we hit dirty_limits. But removing it leads
>   to a different issue where too many dirty pages from a single group can
>   be present from a cgroup in page cache and if that cgroup is slow moving
>   one, then pages are flushed to disk at slower speed delyaing other
>   higher rate cgroups. (all discussed in private mails with Andrea).

I confirm this. :) But IMHO before removing the throttling in
balance_dirty_pages() we really need the per-cgroup dirty limit / dirty
page cache quota.

> 
> 
> ioprio class and iopriority with-in cgroups issues with IO-throttle
> ===================================================================
> 
> Currently throttling logic is designed in such a way that it makes the
> throttling uniform for every process in the group. So we will loose the
> differentiation between different class of processes or differnetitation
> between different priority of processes with-in group.
> 
> I have run the tests of these in the past and reported it here in the
> past.
> 
> https://lists.linux-foundation.org/pipermail/containers/2009-May/017588.html
> 
> Thanks
> Vivek

-- 
Andrea Righi - Develer s.r.l
http://www.develer.com
