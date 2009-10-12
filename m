From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Performance numbers with IO throttling patches (Was: Re: IO
	scheduler based IO controller V10)
Date: Mon, 12 Oct 2009 17:11:20 -0400
Message-ID: <20091012211120.GE7152__375.651990953152$1255382010$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
	<20091010195316.GB16510@redhat.com> <20091010222728.GA30943@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091010222728.GA30943@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Oct 11, 2009 at 12:27:30AM +0200, Andrea Righi wrote:

[..]
> > Multiple Random Reader vs Sequential Reader
> > ===============================================
> > Generally random readers bring the throughput down of others in the
> > system. Ran a test to see the impact of increasing number of random readers on
> > single sequential reader in different groups.
> > 
> > Vanilla CFQ
> > -----------------------------------
> > [Multiple Random Reader]                      [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   23KB/s    23KB/s    22KB/s    691 msec    1   13519KB/s 468K usec   
> > 2   152KB/s   152KB/s   297KB/s   244K usec   1   12380KB/s 31675 usec  
> > 4   174KB/s   156KB/s   638KB/s   249K usec   1   10860KB/s 36715 usec  
> > 8   49KB/s    11KB/s    310KB/s   1856 msec   1   1292KB/s  990K usec   
> > 16  63KB/s    48KB/s    877KB/s   762K usec   1   3905KB/s  506K usec   
> > 32  35KB/s    27KB/s    951KB/s   2655 msec   1   1109KB/s  1910K usec  
> > 
> > IO scheduler controller + CFQ
> > -----------------------------------
> > [Multiple Random Reader]                      [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   228KB/s   228KB/s   223KB/s   132K usec   1   5551KB/s  129K usec   
> > 2   97KB/s    97KB/s    190KB/s   154K usec   1   5718KB/s  122K usec   
> > 4   115KB/s   110KB/s   445KB/s   208K usec   1   5909KB/s  116K usec   
> > 8   23KB/s    12KB/s    158KB/s   2820 msec   1   5445KB/s  168K usec   
> > 16  11KB/s    3KB/s     145KB/s   5963 msec   1   5418KB/s  164K usec   
> > 32  6KB/s     2KB/s     139KB/s   12762 msec  1   5398KB/s  175K usec   
> > 
> > Notes:
> > - Sequential reader in group2 seems to be well isolated from random readers
> >   in group1. Throughput and latency of sequential reader are stable and
> >   don't drop as number of random readers inrease in system.
> > 
> > io-throttle + CFQ
> > ------------------
> > BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> > [Multiple Random Reader]                      [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   37KB/s    37KB/s    36KB/s    218K usec   1   8006KB/s  20529 usec  
> > 2   185KB/s   183KB/s   360KB/s   228K usec   1   7475KB/s  33665 usec  
> > 4   188KB/s   171KB/s   699KB/s   262K usec   1   6800KB/s  46224 usec  
> > 8   84KB/s    51KB/s    573KB/s   1800K usec  1   2835KB/s  885K usec   
> > 16  21KB/s    9KB/s     294KB/s   3590 msec   1   437KB/s   1855K usec  
> > 32  34KB/s    27KB/s    980KB/s   2861K usec  1   1145KB/s  1952K usec  
> > 
> > Notes:
> > - I have setup limits of 10MB/s in both the cgroups. Now random reader
> >   group will never achieve that kind of speed, so it will not be throttled
> >   and then it goes onto impact the throughput and latency of other groups
> >   in the system.
> > 
> > - Now the key question is how conservative one should in be setting up 
> >   max BW limit. On this box if a customer has bought 10MB/s cgroup and if
> >   he is running some random readers it will kill throughput of other
> >   groups in the system and their latencies will shoot up. No isolation in
> >   this case.
> > 
> > - So in general, max BW provides isolation from high speed groups but it
> >   does not provide isolaton from random reader groups which are moving
> >   slow.
> 
> Remember that in addition to blockio.bandwidth-max the io-throttle
> controlller also provides blockio.iops-max to enforce hard limits on the
> number of IO operations per second. Probably for this testcase both
> cgroups should be limited in terms of BW and iops to achieve a better
> isolation.
> 

I modified my report scripts to also output aggreagate iops numbers and
remove max-bandwidth and min-bandwidth numbers. So for same tests and same
results I am now reporting iops numbers also. ( I have not re-run the
tests.)

IO scheduler controller + CFQ
-----------------------------------
[Multiple Random Reader]            [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   223KB/s   132K usec   55        1   5551KB/s  129K usec   1387      
2   190KB/s   154K usec   46        1   5718KB/s  122K usec   1429      
4   445KB/s   208K usec   111       1   5909KB/s  116K usec   1477      
8   158KB/s   2820 msec   36        1   5445KB/s  168K usec   1361      
16  145KB/s   5963 msec   28        1   5418KB/s  164K usec   1354      
32  139KB/s   12762 msec  23        1   5398KB/s  175K usec   1349      

io-throttle + CFQ
-----------------------------------
BW limit group1=10 MB/s             BW limit group2=10 MB/s             
[Multiple Random Reader]            [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   36KB/s    218K usec   9         1   8006KB/s  20529 usec  2001      
2   360KB/s   228K usec   89        1   7475KB/s  33665 usec  1868      
4   699KB/s   262K usec   173       1   6800KB/s  46224 usec  1700      
8   573KB/s   1800K usec  139       1   2835KB/s  885K usec   708       
16  294KB/s   3590 msec   68        1   437KB/s   1855K usec  109       
32  980KB/s   2861K usec  230       1   1145KB/s  1952K usec  286       

Note that in case of random reader groups, iops are really small. Few
thougts.

- What should be the iops limit I should choose for the group. Lets say if
  I choose "80", then things should be better for sequential reader group,
  but just think of what will happen to random reader group. Especially,
  if nature of workload in group1 changes to sequential. Group1 will
  simply be killed.

  So yes, one can limit a group both by BW as well as iops-max, but this
  requires you to know in advance exactly what workload is running in the
  group. The moment workoload changes, these settings might have a very
  bad effects.

  So my biggest concern with max-bwidth and max-iops limits is that how
  will one configure the system for a dynamic environment. Think of two
  virtual machines being used by two customers. At one point they might be
  doing some copy operation and running sequential workload an later some
  webserver or database query might be doing some random read operations.

- Notice the interesting case of 16 random readers. iops for random reader
  group is really low, but still the throughput and iops of sequential
  reader group is very bad. I suspect that at CFQ level, some kind of
  mixup has taken place where we have not enabled idling for sequential
  reader and disk became seek bound hence both the group are loosing.
  (Just a guess)

 Out of curiousity I looked at the results of set1 and set3 also and they
 seem to be exhibiting the similar behavior.

Set1
----
io-throttle + CFQ
-----------------------------------
BW limit group1=10 MB/s             BW limit group2=10 MB/s             
[Multiple Random Reader]            [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   37KB/s    227K usec   9         1   8033KB/s  18773 usec  2008      
2   342KB/s   601K usec   84        1   7406KB/s  476K usec   1851      
4   677KB/s   163K usec   167       1   6743KB/s  69196 usec  1685      
8   310KB/s   1780 msec   74        1   882KB/s   915K usec   220       
16  877KB/s   431K usec   211       1   3278KB/s  274K usec   819       
32  1109KB/s  1823 msec   261       1   1217KB/s  1022K usec  304       

Set3
----
io-throttle + CFQ
-----------------------------------
BW limit group1=10 MB/s             BW limit group2=10 MB/s             
[Multiple Random Reader]            [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   34KB/s    693K usec   8         1   7908KB/s  469K usec   1977      
2   343KB/s   204K usec   85        1   7402KB/s  33962 usec  1850      
4   691KB/s   228K usec   171       1   6847KB/s  76957 usec  1711      
8   306KB/s   1806 msec   73        1   852KB/s   925K usec   213       
16  287KB/s   3581 msec   63        1   439KB/s   1820K usec  109       
32  976KB/s   3592K usec  230       1   1170KB/s  2895K usec  292      

> > 
> > Multiple Sequential Reader vs Random Reader
> > ===============================================
> > Now running a reverse test where in one group I am running increasing
> > number of sequential readers and in other group I am running one random
> > reader and see the impact of sequential readers on random reader.
> > 
> > Vanilla CFQ
> > -----------------------------------
> > [Multiple Sequential Reader]                  [Random Reader]           
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   13978KB/s 13978KB/s 13650KB/s 27614 usec  1   22KB/s    227 msec    
> > 2   6225KB/s  6166KB/s  12101KB/s 568K usec   1   10KB/s    457 msec    
> > 4   4052KB/s  2462KB/s  13107KB/s 322K usec   1   6KB/s     841 msec    
> > 8   1899KB/s  557KB/s   12960KB/s 829K usec   1   13KB/s    1628 msec   
> > 16  1007KB/s  279KB/s   13833KB/s 1629K usec  1   10KB/s    3236 msec   
> > 32  506KB/s   98KB/s    13704KB/s 3389K usec  1   6KB/s     3238 msec   
> > 
> > IO scheduler controller + CFQ
> > -----------------------------------
> > [Multiple Sequential Reader]                  [Random Reader]           
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   5721KB/s  5721KB/s  5587KB/s  126K usec   1   223KB/s   126K usec   
> > 2   3216KB/s  1442KB/s  4549KB/s  349K usec   1   224KB/s   176K usec   
> > 4   1895KB/s  640KB/s   5121KB/s  775K usec   1   222KB/s   189K usec   
> > 8   957KB/s   285KB/s   6368KB/s  1680K usec  1   223KB/s   142K usec   
> > 16  458KB/s   132KB/s   6455KB/s  3343K usec  1   219KB/s   165K usec   
> > 32  248KB/s   55KB/s    6001KB/s  6957K usec  1   220KB/s   504K usec   
> > 
> > Notes:
> > - Random reader is well isolated from increasing number of sequential
> >   readers in other group. BW and latencies are stable.
> >  
> > io-throttle + CFQ
> > -----------------------------------
> > BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> > [Multiple Sequential Reader]                  [Random Reader]           
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   8200KB/s  8200KB/s  8007KB/s  20275 usec  1   37KB/s    217K usec   
> > 2   3926KB/s  3919KB/s  7661KB/s  122K usec   1   16KB/s    441 msec    
> > 4   2271KB/s  1497KB/s  7672KB/s  611K usec   1   9KB/s     927 msec    
> > 8   1113KB/s  513KB/s   7507KB/s  849K usec   1   21KB/s    1020 msec   
> > 16  661KB/s   236KB/s   7959KB/s  1679K usec  1   13KB/s    2926 msec   
> > 32  292KB/s   109KB/s   7864KB/s  3446K usec  1   8KB/s     3439 msec   
> > 
> > BW limit group1=5 MB/s                        BW limit group2=5 MB/s    
> > [Multiple Sequential Reader]                  [Random Reader]           
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   4686KB/s  4686KB/s  4576KB/s  21095 usec  1   57KB/s    219K usec   
> > 2   2298KB/s  2179KB/s  4372KB/s  132K usec   1   37KB/s    431K usec   
> > 4   1245KB/s  1019KB/s  4449KB/s  324K usec   1   26KB/s    835 msec    
> > 8   584KB/s   403KB/s   4109KB/s  833K usec   1   30KB/s    1625K usec  
> > 16  346KB/s   252KB/s   4605KB/s  1641K usec  1   129KB/s   3236K usec  
> > 32  175KB/s   56KB/s    4269KB/s  3236K usec  1   8KB/s     3235 msec   
> > 
> > Notes:
> > 
> > - Above result is surprising to me. I have run it twice. In first run, I
> >   setup per cgroup limit as 10MB/s and in second run I set it up 5MB/s. In
> >   both the cases as number of sequential readers increase in other groups, 
> >   random reader's throughput decreases and latencies increase. This is
> >   happening despite the fact that sequential readers are being throttled
> >   to make sure it does not impact workload in other group. Wondering why
> >   random readers are not seeing consistent throughput and latencies.
> 
> Maybe because CFQ is still trying to be fair among processes instead of
> cgroups. Remember that io-throttle doesn't touch the CFQ code (for this
> I'm definitely convinced that CFQ should be changed to think also in
> terms of cgroups, and io-throttle alone is not enough).
> 

True. I think that's what is happening here. CFQ will see requests from
all the sequential readers and will try to give these 100ms slice but 
random reader will get one chance to dispatch requests and then will again
be at the back of the service tree.

Throttling at higher layers should help a bit so that group1 does not get
to run for too long, but still it does not seem to be helping a lot.

So it becomes important that underying IO scheduler knows about groups and
then does the scheduling accordingly otherwise we run into issues of 
"weak isolation" between groups and "not improved latecies".

> So, even if group1 is being throttled in part it is still able to submit
> some requests that get a higher priority respect to the requests
> submitted by the single random reader task.
> 
> It could be interesting to test another IO scheduler (deadline, as or
> even noop) to check if this is the actual problem.
> 
> > 
> > - Andrea, can you please also run similar tests to see if you see same
> >   results or not. This is to rule out any testing methodology errors or
> >   scripting bugs. :-). I also have collected the snapshot of some cgroup
> >   files like bandwidth-max, throttlecnt, and stats. Let me know if you want
> >   those to see what is happenig here. 
> 
> Sure, I'll do some tests ASAP. Another interesting test would be to set
> a blockio.iops-max limit also for the sequential readers' cgroup, to be
> sure we're not touching some iops physical disk limit.
> 
> Could you post all the options you used with fio, so I can repeat some
> tests as similar as possible to yours?
> 
> > 
> > Multiple Sequential Reader vs Sequential Reader
> > ===============================================
> > - This time running random readers are out of the picture and trying to
> >   see the effect of increasing number of sequential readers on another
> >   sequential reader running in a different group.
> > 
> > Vanilla CFQ
> > -----------------------------------
> > [Multiple Sequential Reader]                  [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   6325KB/s  6325KB/s  6176KB/s  114K usec   1   6902KB/s  120K usec   
> > 2   4588KB/s  3102KB/s  7510KB/s  571K usec   1   4564KB/s  680K usec   
> > 4   3242KB/s  1158KB/s  9469KB/s  495K usec   1   3198KB/s  410K usec   
> > 8   1775KB/s  459KB/s   12011KB/s 1178K usec  1   1366KB/s  818K usec   
> > 16  943KB/s   296KB/s   13285KB/s 1923K usec  1   728KB/s   1816K usec  
> > 32  511KB/s   148KB/s   13555KB/s 3286K usec  1   391KB/s   3212K usec  
> > 
> > IO scheduler controller + CFQ
> > -----------------------------------
> > [Multiple Sequential Reader]                  [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   6781KB/s  6781KB/s  6622KB/s  109K usec   1   6691KB/s  115K usec   
> > 2   3758KB/s  1876KB/s  5502KB/s  693K usec   1   6373KB/s  419K usec   
> > 4   2100KB/s  671KB/s   5751KB/s  987K usec   1   6330KB/s  569K usec   
> > 8   1023KB/s  355KB/s   6969KB/s  1569K usec  1   6086KB/s  120K usec   
> > 16  520KB/s   130KB/s   7094KB/s  3140K usec  1   5984KB/s  119K usec   
> > 32  245KB/s   86KB/s    6621KB/s  6571K usec  1   5850KB/s  113K usec   
> > 
> > Notes:
> > - BW and latencies of sequential reader in group 2 are fairly stable as
> >   number of readers increase in first group.
> > 
> > io-throttle + CFQ
> > -----------------------------------
> > BW limit group1=30 MB/s                       BW limit group2=30 MB/s   
> > [Multiple Sequential Reader]                  [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   6343KB/s  6343KB/s  6195KB/s  116K usec   1   6993KB/s  109K usec   
> > 2   4583KB/s  3046KB/s  7451KB/s  583K usec   1   4516KB/s  433K usec   
> > 4   2945KB/s  1324KB/s  9552KB/s  602K usec   1   3001KB/s  583K usec   
> > 8   1804KB/s  473KB/s   12257KB/s 861K usec   1   1386KB/s  815K usec   
> > 16  942KB/s   265KB/s   13560KB/s 1659K usec  1   718KB/s   1658K usec  
> > 32  462KB/s   143KB/s   13757KB/s 3482K usec  1   409KB/s   3480K usec  
> > 
> > Notes:
> > - BW decreases and latencies increase in group2 as number of readers
> >   increase in first group. This should be due to fact that no throttling
> >   will happen as none of the groups is hitting the limit of 30MB/s. To
> >   me this is the tricky part. How a service provider is supposed to 
> >   set the limit of groups. If groups are not hitting max limits, it will
> >   still impact the BW and latencies in other group.
> 
> Are you using 4k block size here? because in case of too small blocks
> you could hit some physical iops limit. Also for this case it could be
> interesting to see what happens setting both BW and iops hard limits.
> 

Hmm.., Same results posted with iops numbers.

io-throttle + CFQ
-----------------------------------
BW limit group1=30 MB/s             BW limit group2=30 MB/s             
[Multiple Sequential Reader]        [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   6195KB/s  116K usec   1548      1   6993KB/s  109K usec   1748      
2   7451KB/s  583K usec   1862      1   4516KB/s  433K usec   1129      
4   9552KB/s  602K usec   2387      1   3001KB/s  583K usec   750       
8   12257KB/s 861K usec   3060      1   1386KB/s  815K usec   346       
16  13560KB/s 1659K usec  3382      1   718KB/s   1658K usec  179       
32  13757KB/s 3482K usec  3422      1   409KB/s   3480K usec  102       

BW limit group1=10 MB/s             BW limit group2=10 MB/s             
[Multiple Sequential Reader]        [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   4032KB/s  215K usec   1008      1   4076KB/s  170K usec   1019      
2   4655KB/s  291K usec   1163      1   2891KB/s  212K usec   722       
4   5872KB/s  417K usec   1466      1   1881KB/s  411K usec   470       
8   7312KB/s  841K usec   1824      1   853KB/s   816K usec   213       
16  7844KB/s  1728K usec  1956      1   503KB/s   1609K usec  125       
32  7920KB/s  3417K usec  1969      1   249KB/s   3205K usec  62        

BW limit group1=5 MB/s              BW limit group2=5 MB/s              
[Multiple Sequential Reader]        [Sequential Reader]                 
nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
1   2377KB/s  110K usec   594       1   2415KB/s  120K usec   603       
2   2759KB/s  222K usec   689       1   1709KB/s  220K usec   427       
4   3314KB/s  420K usec   828       1   1163KB/s  414K usec   290       
8   4060KB/s  901K usec   1011      1   527KB/s   816K usec   131       
16  4324KB/s  1613K usec  1074      1   311KB/s   1613K usec  77        
32  4320KB/s  3235K usec  1067      1   163KB/s   3209K usec  40        

Note that with bw limit 30MB/s, we are able to hit iops more than 3400 but
with bw=5MB/s, we are hitting close to 1100 iops. So I think we are
under-utilizing the storage here and not run into any kind of iops
limit.

> > 
> > BW limit group1=10 MB/s                       BW limit group2=10 MB/s   
> > [Multiple Sequential Reader]                  [Sequential Reader]       
> > nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
> > 1   4128KB/s  4128KB/s  4032KB/s  215K usec   1   4076KB/s  170K usec   
> > 2   2880KB/s  1886KB/s  4655KB/s  291K usec   1   2891KB/s  212K usec   
> > 4   1912KB/s  888KB/s   5872KB/s  417K usec   1   1881KB/s  411K usec   
> > 8   1032KB/s  432KB/s   7312KB/s  841K usec   1   853KB/s   816K usec   
> > 16  540KB/s   259KB/s   7844KB/s  1728K usec  1   503KB/s   1609K usec  
> > 32  291KB/s   111KB/s   7920KB/s  3417K usec  1   249KB/s   3205K usec  
> > 
> > Notes:
> > - Same test with 10MB/s as group limit. This is again a surprising result.
> >   Max BW in first group is being throttled but still throughput is
> >   dropping significantly in second group and latencies are on the rise.
> 
> Same consideration about CFQ and/or iops limit. Could you post all the
> fio options you've used also for this test (or better, for all tests)?
> 

Already posted in a separate mail.

> > 
> > - Limit of first group is 10MB/s but it is achieving max BW of around
> >   8MB/s only. What happened to rest of the 2MB/s?
> 
> Ditto.
> 

For 10MB/s case, max iops seems to be 2000 collectively, way below than
3400. So I doubt that this is case of hitting max iops.
 
Thanks
Vivek
