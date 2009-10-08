From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: More performance numbers (Was: Re: IO scheduler based IO
	controller V10)
Date: Thu, 8 Oct 2009 00:42:51 -0400
Message-ID: <20091008044251.GA3490__31477.6745312431$1254977684$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

On Thu, Sep 24, 2009 at 02:33:15PM -0700, Andrew Morton wrote:
[..]
> > 
> > Testing
> > =======
> > 
> > Environment
> > ==========
> > A 7200 RPM SATA drive with queue depth of 31. Ext3 filesystem.
> 
> That's a bit of a toy.
> 
> Do we have testing results for more enterprisey hardware?  Big storage
> arrays?  SSD?  Infiniband?  iscsi?  nfs? (lol, gotcha)
> 
> 

Hi Andrew,

I got hold of a relatively more enterprisey stuff. It is an storage array
with few striped disks(I think 4 or 5). So this is not high end stuff but
better than my single SATA disk. I guess may be entry level enterprisy stuff.
Still trying to get hold of higher end configuration...

Apart from IO scheduler controller number, I also got a chance to run same
tests with dm-ioband controller. I am posting these too. I am also
planning to run similar numbers on Andrea's "max bw" controller also.
Should be able to post those numbers also in 2-3 days.

Software Environment
====================
- 2.6.31 kernel
- V10 of IO scheduler based controller
- version v1.14.0 of dm-ioband patches 

Used fio jobs for 30 seconds in various configurations. All the IO is
direct IO to eliminate the effects of caches.

I have run three sets for each test. Blindly reporting results of set2
from each test, otherwise it is too much of data to report.

Had lun of 2500GB capacity. Used 200G partitions with ext3 file system for my
testing. For IO scheduler based controller patches, created two cgroups of
weight 100 each doing IO to single 200G partition.

For dm-ioband, created two partitions of 200G each and created two ioband
devices of weight 100 each with policy "weight-iosize". Ideally I should
haved used cgroups on dm-ioband also but could not get cgroup patch going.
Because this is striped configuration, not expecting any major changes in
results due to that.  

Sequential reader vs Random  reader
==================================
Launched on random reader in one group and launched increasing number of
sequential readers in other group to see the effect on latency and
bandwidth of random reader.

[fio1 --rw=read --bs=4K --size=2G --runtime=30 --direct=1 ]
[fio2 --rw=randread --bs=4K --size=1G --runtime=30 --direct=1 --group_reporting]

Vanilla CFQ
-----------
[Sequential readers]                          [Random Reader]           
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   13806KB/s 13806KB/s 13483KB/s 28672 usec  1   23KB/s    212 msec    
2   6406KB/s  6268KB/s  12378KB/s 128K usec   1   10KB/s    453 msec    
4   3934KB/s  2536KB/s  13103KB/s 321K usec   1   6KB/s     847 msec    
8   1934KB/s  556KB/s   13009KB/s 876K usec   1   13KB/s    1632 msec   
16  958KB/s   280KB/s   13761KB/s 1621K usec  1   10KB/s    3217 msec   
32  512KB/s   126KB/s   13861KB/s 3241K usec  1   6KB/s     3249 msec   

IO scheduler controller + CFQ
-----------------------------
[Sequential readers]                          [Random Reader]           
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   5651KB/s  5651KB/s  5519KB/s  126K usec   1   222KB/s   130K usec   
2   3144KB/s  1479KB/s  4515KB/s  347K usec   1   225KB/s   189K usec   
4   1852KB/s  626KB/s   5128KB/s  775K usec   1   224KB/s   159K usec   
8   971KB/s   279KB/s   6464KB/s  1666K usec  1   222KB/s   193K usec   
16  454KB/s   129KB/s   6293KB/s  3356K usec  1   218KB/s   466K usec   
32  239KB/s   42KB/s    5986KB/s  6753K usec  1   214KB/s   503K usec   

Notes: 
- The BW and latency of random reader are fairly stable in the face of
  increasing number of sequential readers. There are couple of spikes
  in latency, i guess comes from the hardware somehow. But will debug
  more to make sure that I am not delaying in dispatch of request. 

dm-ioaband + CFQ
----------------
[Sequential readers]                          [Random Reader]           
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   12466KB/s 12466KB/s 12174KB/s 40078 usec  1   37KB/s    221 msec    
2   6240KB/s  5904KB/s  11859KB/s 134K usec   1   12KB/s    443 msec    
4   3517KB/s  2529KB/s  12368KB/s 357K usec   1   6KB/s     772 msec    
8   1779KB/s  594KB/s   9857KB/s  719K usec   1   60KB/s    852K usec   
16  914KB/s   300KB/s   10934KB/s 1467K usec  1   40KB/s    1285K usec  
32  589KB/s   187KB/s   11537KB/s 3547K usec  1   14KB/s    3228 msec   

Notes:
- Does not look like we provide fairness to random reader here. Latencies
  are on the rise and BW is on the decline. this is almost like Vanilla
  CFQ with reduced overall throughput.

- dm-ioband claims that they do not provide fairness for slow moving group
  and I think it is a bad idea. This leads to very weak isolation with
  no benefits. Especially if a buffered writer is running in other group.
  This should be fixed.

Random writers vs Random reader
================================
[fio1 --rw=randwrite --bs=64K --size=2G --runtime=30 --ioengine=libaio --iodepth=4 --direct=1 ]
[fio2 --rw=randread --bs=4K --size=1G --runtime=30 --direct=1 --group_reporting]

Vanilla CFQ
-----------
[Random Writers]                              [Random Reader]           
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   67785KB/s 67785KB/s 66197KB/s 45499 usec  1   170KB/s   94098 usec  
2   35163KB/s 35163KB/s 68678KB/s 218K usec   1   75KB/s    2335 msec   
4   17759KB/s 15308KB/s 64206KB/s 2387K usec  1   85KB/s    2331 msec   
8   8725KB/s  6495KB/s  57120KB/s 3761K usec  1   67KB/s    2488K usec  
16  3912KB/s  3456KB/s  57121KB/s 1273K usec  1   60KB/s    1668K usec  
32  2020KB/s  1503KB/s  56786KB/s 4221K usec  1   39KB/s    1101 msec   

IO scheduler controller + CFQ
-----------------------------
[Random Writers]                              [Random Reader]           
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   20919KB/s 20919KB/s 20428KB/s 288K usec   1   213KB/s   580K usec   
2   14765KB/s 14674KB/s 28749KB/s 776K usec   1   203KB/s   112K usec   
4   7177KB/s  7091KB/s  27839KB/s 970K usec   1   197KB/s   132K usec   
8   3027KB/s  2953KB/s  23285KB/s 3145K usec  1   218KB/s   203K usec   
16  1959KB/s  1750KB/s  28919KB/s 1266K usec  1   160KB/s   182K usec   
32  908KB/s   753KB/s   26267KB/s 2091K usec  1   208KB/s   144K usec   

Notes:
- Again disk time has been divided half and half between random reader
  group and random writer group. Fairly stable BW and latencies for
  random reader in the face of increasing number of random writers.

- Drop in aggregate bw of random writers is expected as they now get only
  half of disk time.

dm-ioaband + CFQ
----------------
[Random Writers]                              [Random Reader]           
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   63659KB/s 63659KB/s 62167KB/s 89954 usec  1   164KB/s   72 msec     
2   27109KB/s 27096KB/s 52933KB/s 674K usec   1   140KB/s   2204K usec  
4   16553KB/s 16216KB/s 63946KB/s 694K usec   1   56KB/s    1871 msec   
8   3907KB/s  3347KB/s  28752KB/s 2406K usec  1   226KB/s   2407K usec  
16  2841KB/s  2647KB/s  42334KB/s 870K usec   1   52KB/s    3043 msec   
32  738KB/s   657KB/s   21285KB/s 1529K usec  1   21KB/s    4435 msec   

Notes:
- Again no fairness for random reader. Decreasing BW, increasing latency.
  No isolation in this case.

- I am curious what happened to random writer throughput in case of "32"
  writers. We did not get higher BW for random reader but random writer still
  suffering in throughput for random writer. I can see this for all the
  three sets.

Sequential Readers vs Sequential reader
=======================================
[fio1 --rw=read --bs=4K --size=2G --runtime=30 --direct=1]
[fio2 --rw=read --bs=4K --size=2G --runtime=30 --direct=1]

Vanilla CFQ
-----------
[Sequential Readers]                          [Sequential Reader]       
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   6434KB/s  6434KB/s  6283KB/s  107K usec   1   7017KB/s  111K usec   
2   4688KB/s  3284KB/s  7785KB/s  274K usec   1   4541KB/s  218K usec   
4   3365KB/s  1326KB/s  9769KB/s  597K usec   1   3038KB/s  424K usec   
8   1827KB/s  504KB/s   12053KB/s 813K usec   1   1389KB/s  813K usec   
16  1022KB/s  301KB/s   13954KB/s 1618K usec  1   676KB/s   1617K usec  
32  494KB/s   149KB/s   13611KB/s 3216K usec  1   416KB/s   3215K usec  

IO scheduler controller + CFQ
-----------------------------
[Sequential Readers]                          [Sequential Reader]       
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   6605KB/s  6605KB/s  6450KB/s  120K usec   1   6527KB/s  120K usec   
2   3706KB/s  1985KB/s  5558KB/s  323K usec   1   6331KB/s  149K usec   
4   2053KB/s  672KB/s   5731KB/s  721K usec   1   6267KB/s  148K usec   
8   1013KB/s  337KB/s   6962KB/s  1525K usec  1   6136KB/s  120K usec   
16  497KB/s   125KB/s   6873KB/s  3226K usec  1   5882KB/s  113K usec   
32  297KB/s   48KB/s    6445KB/s  6394K usec  1   5767KB/s  116K usec   

Notes:
- Stable BW and lateneis for sequential reader in the face of increasing
  number of readers in other group.

dm-ioaband + CFQ
----------------
[Sequential Readers]                          [Sequential Reader]       
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
1   7140KB/s  7140KB/s  6972KB/s  112K usec   1   6886KB/s  165K usec   
2   3965KB/s  2762KB/s  6569KB/s  479K usec   1   5887KB/s  475K usec   
4   2725KB/s  1483KB/s  7999KB/s  532K usec   1   4774KB/s  500K usec   
8   1610KB/s  621KB/s   9565KB/s  729K usec   1   2910KB/s  677K usec   
16  904KB/s   319KB/s   10809KB/s 1431K usec  1   1970KB/s  1399K usec  
32  553KB/s   8KB/s     11794KB/s 2330K usec  1   1337KB/s  2398K usec  

Notes:
- Decreasing throughput and increasing latencies for sequential reader.
  Hence no isolation in this case.

- Also note the in case of "32" readers, difference between "max-bw" and
  "min-bw" is relatively large, considering that all the 32 readers are
  of same prio. So bw distribution with-in group is not very good. This is
  the issue of ioprio with-in group I have pointed many times. Ryo is
  looking into it now.

Sequential Readers vs Multiple Random Readers
=======================================
Ok, because dm-ioband does not provide fairness in case if heavy IO
activity is not going in the group, I decided to run a slightly different
test case where 16 sequential readers are running in one group and I
run increasing number of random readers in other group to see when do
I start getting fairness and its effect.

[fio1 --rw=read --bs=4K --size=2G --runtime=30 --direct=1 ]
[fio2 --rw=randread --bs=4K --size=1G --runtime=30 --direct=1 --group_reporting]

Vanilla CFQ
-----------
[Sequential Readers]                          [Multiple Random Readers] 
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
16  961KB/s   280KB/s   13978KB/s 1673K usec  1   10KB/s    3223 msec   
16  903KB/s   260KB/s   12925KB/s 1770K usec  2   28KB/s    3465 msec   
16  832KB/s   231KB/s   11428KB/s 2088K usec  4   57KB/s    3891K usec  
16  765KB/s   187KB/s   9899KB/s  2500K usec  8   99KB/s    3937K usec  
16  512KB/s   144KB/s   6759KB/s  3451K usec  16  148KB/s   5470K usec  

IO scheduler controller + CFQ
-----------------------------
[Sequential Readers]                          [Multiple Random Readers] 
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
16  456KB/s   112KB/s   6380KB/s  3361K usec  1   221KB/s   503K usec   
16  476KB/s   159KB/s   6040KB/s  3432K usec  2   214KB/s   549K usec   
16  606KB/s   178KB/s   6052KB/s  3801K usec  4   177KB/s   1341K usec  
16  589KB/s   83KB/s    6243KB/s  3394K usec  8   154KB/s   3288K usec  
16  547KB/s   122KB/s   6122KB/s  3538K usec  16  145KB/s   5959K usec  

Notes:
- Stable BW and latencies for sequential reader group in the face of
  increasing number of random readers in other group.

- Because disk is divided half/half in terms of time, random reader group
  also gets decent amount of job done. Not sure why BW dips a bit when 
  number of random readers increases. Too seeky to handle?
 
dm-ioaband + CFQ
----------------
[Sequential Readers]                          [Multiple Random Readers] 
nr  Max-bandw Min-bandw Agg-bandw Max-latency nr  Agg-bandw Max-latency 
16  926KB/s   293KB/s   10256KB/s 1634K usec  1   55KB/s    1377K usec  
16  906KB/s   284KB/s   9240KB/s  1825K usec  2   71KB/s    2392K usec  
16  321KB/s   18KB/s    1621KB/s  2037K usec  4   326KB/s   2054K usec  
16  188KB/s   16KB/s    1188KB/s  9757K usec  8   404KB/s   3269K usec  
16  167KB/s   64KB/s    1700KB/s  2859K usec  16  1064KB/s  2920K usec  

Notes:
- Looks like ioband tried to provide fairness from the time when number of
  random readers are 4. Note, there is sudden increase in BW of random
  readers and drastic drop in BW of sequential readers.

- By the time number of readers reach 16, total array throughput reduces
  to around 2.7 MB/s. It got killed because suddenly we are trying to
  provide fairness in terms of size of IO. That's why on seeky media
  fairness in terms of disk time works better.

- There is no isolation between groups. Throughput of sequential reader
  group continues to drop and latencies rise.

- I think these are serious issues which should be looked into and fixed.  

Thanks
Vivek
