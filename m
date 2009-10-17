From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Performance numbers with IO throttling patches (Was: Re: IO
	scheduler based IO controller V10)
Date: Sat, 17 Oct 2009 17:18:19 +0200
Message-ID: <20091017151817.GA29639__34463.0260872238$1255792817$gmane$org@linux>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<20090924143315.781cd0ac.akpm@linux-foundation.org>
	<20091010195316.GB16510@redhat.com> <20091010222728.GA30943@linux>
	<20091012211120.GE7152@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091012211120.GE7152-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Mon, Oct 12, 2009 at 05:11:20PM -0400, Vivek Goyal wrote:

[snip]

> I modified my report scripts to also output aggreagate iops numbers and
> remove max-bandwidth and min-bandwidth numbers. So for same tests and same
> results I am now reporting iops numbers also. ( I have not re-run the
> tests.)
> 
> IO scheduler controller + CFQ
> -----------------------------------
> [Multiple Random Reader]            [Sequential Reader]                 
> nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
> 1   223KB/s   132K usec   55        1   5551KB/s  129K usec   1387      
> 2   190KB/s   154K usec   46        1   5718KB/s  122K usec   1429      
> 4   445KB/s   208K usec   111       1   5909KB/s  116K usec   1477      
> 8   158KB/s   2820 msec   36        1   5445KB/s  168K usec   1361      
> 16  145KB/s   5963 msec   28        1   5418KB/s  164K usec   1354      
> 32  139KB/s   12762 msec  23        1   5398KB/s  175K usec   1349      
> 
> io-throttle + CFQ
> -----------------------------------
> BW limit group1=10 MB/s             BW limit group2=10 MB/s             
> [Multiple Random Reader]            [Sequential Reader]                 
> nr  Agg-bandw Max-latency Agg-iops  nr  Agg-bandw Max-latency Agg-iops  
> 1   36KB/s    218K usec   9         1   8006KB/s  20529 usec  2001      
> 2   360KB/s   228K usec   89        1   7475KB/s  33665 usec  1868      
> 4   699KB/s   262K usec   173       1   6800KB/s  46224 usec  1700      
> 8   573KB/s   1800K usec  139       1   2835KB/s  885K usec   708       
> 16  294KB/s   3590 msec   68        1   437KB/s   1855K usec  109       
> 32  980KB/s   2861K usec  230       1   1145KB/s  1952K usec  286       
> 
> Note that in case of random reader groups, iops are really small. Few
> thougts.
> 
> - What should be the iops limit I should choose for the group. Lets say if
>   I choose "80", then things should be better for sequential reader group,
>   but just think of what will happen to random reader group. Especially,
>   if nature of workload in group1 changes to sequential. Group1 will
>   simply be killed.
> 
>   So yes, one can limit a group both by BW as well as iops-max, but this
>   requires you to know in advance exactly what workload is running in the
>   group. The moment workoload changes, these settings might have a very
>   bad effects.
> 
>   So my biggest concern with max-bwidth and max-iops limits is that how
>   will one configure the system for a dynamic environment. Think of two
>   virtual machines being used by two customers. At one point they might be
>   doing some copy operation and running sequential workload an later some
>   webserver or database query might be doing some random read operations.

The main problem IMHO is how to accurately evaluate the cost of an IO
operation. On rotational media for example the cost to read two distant
blocks is not the same cost of reading two contiguous blocks (while on a
flash/SSD drive the cost is probably the same).

io-throttle tries to quantify the cost in absolute terms (iops and BW),
but this is not enough to cover all the possible cases. For example, you
could hit a physical disk limit, because you're doing a workload too
seeky, even if the iops and BW numbers are low.

> 
> - Notice the interesting case of 16 random readers. iops for random reader
>   group is really low, but still the throughput and iops of sequential
>   reader group is very bad. I suspect that at CFQ level, some kind of
>   mixup has taken place where we have not enabled idling for sequential
>   reader and disk became seek bound hence both the group are loosing.
>   (Just a guess)

Yes, my guess is the same.

I've re-run some of your tests using a SSD (a MOBI MTRON MSD-PATA3018-ZIF1),
but changing few parameters: I used a larger block size for the
sequential workload (there's no need to reduce the block size of the
single reads if we suppose to read a lot of contiguous blocks).

And for all the io-throttle tests I switched to noop scheduler (CFQ must
be changed to be cgroup-aware before using it together with io-throttle,
otherwise the result is that one simply breaks the logic of the other).

=== io-throttle settings ===
cgroup #1: max-bw 10MB/s, max-iops 2150 iop/s
cgroup #1: max-bw 10MB/s, max-iops 2150 iop/s

During the tests I used a larger block size for sequential readers,
respect to the random readers:

sequential-read:	block size = 1MB
random-read:		block size = 4KB

sequential-readers vs sequential-reader
=======================================
[ cgroup #1 workload ]
fio_args="--rw=read --bs=1M --size=512M --runtime=30 --numjobs=N --direct=1"
[ cgroup #2 workload ]
fio_args="--rw=read --bs=1M --size=512M --runtime=30 --numjobs=1 --direct=1"

__2.6.32-rc5__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	36210KB/s	1	36992KB/s
2	47558KB/s	1	24479KB/s
4	57587KB/s	1	14809KB/s
8	64667KB/s	1	8393KB/s

__2.6.32-rc5-io-throttle__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	10195KB/s	1	10193KB/s
2	10279KB/s	1	10276KB/s
4	10281KB/s	1	10277KB/s
8	10279KB/s	1	10277KB/s

random-readers vs sequential-reader
===================================
[ cgroup #1 workload ]
fio_args="--rw=randread --bs=4k --size=512M --runtime=30 --numjobs=N --direct=1"
[ cgroup #2 workload ]
fio_args="--rw=read --bs=1M --size=512M --runtime=30 --numjobs=1 --direct=1"

__2.6.32-rc5__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	4767KB/s	1	52819KB/s
2	5900KB/s	1	39788KB/s
4	7783KB/s	1	27966KB/s
8	9296KB/s	1	17606KB/s

__2.6.32-rc5-io-throttle__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	8861KB/s	1	8886KB/s
2	8887KB/s	1	7578KB/s
4	8886KB/s	1	7271KB/s
8	8889KB/s	1	7489KB/s

sequential-readers vs random-reader
===================================
[ cgroup #1 workload ]
fio_args="--rw=read --bs=1M --size=512M --runtime=30 --numjobs=N --direct=1"
[ cgroup #2 workload ]
fio_args="--rw=randread --bs=4k --size=512M --runtime=30 --numjobs=1 --direct=1"

__2.6.32-rc5__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	54511KB/s	1	4865KB/s
2	70312KB/s	1	 965KB/s
4	71543KB/s	1	 484KB/s
8	72899KB/s	1	  98KB/s

__2.6.32-rc5-io-throttle__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	8875KB/s	1	8885KB/s
2	8884KB/s	1	8148KB/s
4	8886KB/s	1	7637KB/s
8	8886KB/s	1	7411KB/s

random-readers vs random-reader
===============================
[ cgroup #1 workload ]
fio_args="--rw=randread --bs=4k --size=512M --runtime=30 --numjobs=N --direct=1"
[ cgroup #2 workload ]
fio_args="--rw=randread --bs=4k --size=512M --runtime=30 --numjobs=1 --direct=1"

__2.6.32-rc5__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	6141KB/s	1	6320KB/s
2	8567KB/s	1	3987KB/s
4	9783KB/s	1	2610KB/s
8	11067KB/s	1	1227KB/s

__2.6.32-rc5-io-throttle__
[   cgroup #1   ]       [   cgroup #2   ]
tasks	aggr-bw		tasks	aggr-bw
1	8883KB/s	1	8886KB/s
2	8888KB/s	1	7676KB/s
4	8887KB/s	1	7364KB/s
8	8884KB/s	1	7264KB/s

With the SSD there's not a consistent degradation of cgroup #2 when we
increase the tasks of the concurrent random readers in cgroup #1 (both
in the random-vs-random or random-vs-sequential cases).

We should better analyze the details (probably blktrace would help
here), but it seems that in your tests the mix of CFQ and io-throttle
generated a too seeky workload that caused the bad performance values of
the sequential reader.

-Andrea
