From: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO scheduler based IO controller V9
Date: Mon, 14 Sep 2009 16:26:13 +0200
Message-ID: <4AAE5285.7080207@redhat.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<4AA918C1.6070907@redhat.com> <20090910205227.GB3617@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090910205227.GB3617-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Thu, Sep 10, 2009 at 05:18:25PM +0200, Jerome Marchand wrote:
>> Vivek Goyal wrote:
>>> Hi All,
>>>
>>> Here is the V9 of the IO controller patches generated on top of 2.6.31-rc7.
>>  
>> Hi Vivek,
>>
>> I've run some postgresql benchmarks for io-controller. Tests have been
>> made with 2.6.31-rc6 kernel, without io-controller patches (when
>> relevant) and with io-controller v8 and v9 patches.
>> I set up two instances of the TPC-H database, each running in their
>> own io-cgroup. I ran two clients to these databases and tested on each
>> that simple request:
>> $ select count(*) from LINEITEM;
>> where LINEITEM is the biggest table of TPC-H (6001215 entries,
>> 720MB). That request generates a steady stream of IOs.
>>
>> Time is measure by psql (\timing switched on). Each test is run twice
>> or more if there is any significant difference between the first two
>> runs. Before each run, the cache is flush:
>> $ echo 3 > /proc/sys/vm/drop_caches
>>
>>
>> Results with 2 groups of same io policy (BE) and same io weight (1000):
>>
>> 	w/o io-scheduler	io-scheduler v8		io-scheduler v9
>> 	first	second		first	second		first	second
>> 	DB	DB		DB	DB		DB	DB
>>
>> CFQ	48.4s	48.4s		48.2s	48.2s		48.1s	48.5s
>> Noop	138.0s	138.0s		48.3s	48.4s		48.5s	48.8s
>> AS	46.3s	47.0s		48.5s	48.7s		48.3s	48.5s
>> Deadl.	137.1s	137.1s		48.2s	48.3s		48.3s	48.5s
>>
>> As you can see, there is no significant difference for CFQ
>> scheduler.
> 
> Thanks Jerome.  
> 
>> There is big improvement for noop and deadline schedulers
>> (why is that happening?).
> 
> I think because now related IO is in a single queue and it gets to run
> for 100ms or so (like CFQ). So previously, IO from both the instances
> will go into a single queue which should lead to more seeks as requests
> from two groups will kind of get interleaved.
> 
> With io controller, both groups have separate queues so requests from
> both the data based instances will not get interleaved (This almost
> becomes like CFQ where ther are separate queues for each io context
> and for sequential reader, one io context gets to run nicely for certain
> ms based on its priority).
> 
>> The performance with anticipatory scheduler
>> is a bit lower (~4%).
>>
> 
> I will run some tests with AS and see if I can reproduce this lower
> performance and attribute it to a particular piece of code.
> 
>> Results with 2 groups of same io policy (BE), different io weights and
>> CFQ scheduler:
>> 			io-scheduler v8		io-scheduler v9
>> weights = 1000, 500	35.6s	46.7s		35.6s	46.7s
>> weigths = 1000, 250	29.2s	45.8s		29.2s	45.6s
>>
>> The result in term of fairness is close to what we can expect from the
>> ideal theoric case: with io weights of 1000 and 500 (1000 and 250),
>> the first request get 2/3 (4/5) of io time as long as it runs and thus
>> finish in about 3/4 (5/8) of total time. 
>>
> 
> Jerome, after 36.6 seconds, disk will be fully given to second group.
> Hence these times might not reflect the accurate measure of who got how
> much of disk time.

I know and took it into account. Let me detail my calculations.

Both request are of the same size and takes alone a time T to complete
(about 22.5s in our example). For sake of simplification, let's ignore
switching cost. Then, the completion time of both requests running at the
same time would be 2T, whatever are their weights or classes.
If one group weights 1000 and the other 500 (resp. 250), the first group
gets 2/3 (4/5) of the bandwidth as long as it is running, and thus finished
in T/(2/3) = 2T*3/4 (resp. T/(4/5) = 2T*5/8 ) that is 3/4 (5/8) of the
total time. The other always finish in about 2T.

The actual results above are pretty closed to these theoretical values and
that how I concluded that the controller is pretty fair.

> 
> Can you just capture the output of "io.disk_time" file in both the cgroups
> at the time of completion of task in higher weight group. Alternatively,
> you can just run this a script in a loop which prints the output of
>  "cat io.disk_time | grep major:minor" every  2 seconds. That way we can
> see how disk times are being distributed between groups.

Actually, I already check that and the result was good but I didn't keep
the output, so I just rerun the (1000,500) weights. First column is the 
time spent by first group since last refresh (refresh period is 2s).
The second column is the same for second group. The group test3 is not
used. The first "ratios" column is the ratio between io time spent by first
group and time spent by second group.

$ ./watch_cgroup.sh 2
test1: 0        test2: 0        test3: 0        ratios: --      --      --
test1: 805      test2: 301      test3: 0        ratios: 2.67441860465116279069  --      --
test1: 1209     test2: 714      test3: 0        ratios: 1.69327731092436974789  --      --
test1: 1306     test2: 503      test3: 0        ratios: 2.59642147117296222664  --      --
test1: 1210     test2: 604      test3: 0        ratios: 2.00331125827814569536  --      --
test1: 1207     test2: 605      test3: 0        ratios: 1.99504132231404958677  --      --
test1: 1209     test2: 605      test3: 0        ratios: 1.99834710743801652892  --      --
test1: 1206     test2: 606      test3: 0        ratios: 1.99009900990099009900  --      --
test1: 1109     test2: 607      test3: 0        ratios: 1.82701812191103789126  --      --
test1: 1213     test2: 603      test3: 0        ratios: 2.01160862354892205638  --      --
test1: 1214     test2: 608      test3: 0        ratios: 1.99671052631578947368  --      --
test1: 1211     test2: 603      test3: 0        ratios: 2.00829187396351575456  --      --
test1: 1110     test2: 603      test3: 0        ratios: 1.84079601990049751243  --      --
test1: 1210     test2: 605      test3: 0        ratios: 2.00000000000000000000  --      --
test1: 1211     test2: 601      test3: 0        ratios: 2.01497504159733777038  --      --
test1: 1210     test2: 607      test3: 0        ratios: 1.99341021416803953871  --      --
test1: 1204     test2: 604      test3: 0        ratios: 1.99337748344370860927  --      --
test1: 1207     test2: 605      test3: 0        ratios: 1.99504132231404958677  --      --
test1: 1089     test2: 708      test3: 0        ratios: 1.53813559322033898305  --      --
test1: 0        test2: 2124     test3: 0        ratios: 0       --      --
test1: 0        test2: 1915     test3: 0        ratios: 0       --      --
test1: 0        test2: 1919     test3: 0        ratios: 0       --      --
test1: 0        test2: 2023     test3: 0        ratios: 0       --      --
test1: 0        test2: 1925     test3: 0        ratios: 0       --      --
test1: 0        test2: 705      test3: 0        ratios: 0       --      --
test1: 0        test2: 0        test3: 0        ratios: --      --      --

As you can see, the ratio stays close to 2 as long as first request is
running.

Regards,
Jerome

> 
>> Results  with 2 groups of different io policies, same io weight and
>> CFQ scheduler:
>> 			io-scheduler v8		io-scheduler v9
>> policy = RT, BE		22.5s	45.3s		22.4s	45.0s
>> policy = BE, IDLE	22.6s	44.8s		22.4s	45.0s
>>
>> Here again, the result in term of fairness is very close from what we
>> expect.
> 
> Same as above in this case too.
> 
> These seem to be good test for fairness measurement in case of streaming 
> readers. I think one more interesting test case will be do how are the 
> random read latencies in case of multiple streaming readers present.
> 
> So if we can launch 4-5 dd processes in one group and then issue some
> random small queueries on postgresql in second group, I am keen to see
> how quickly the query can be completed with and without io controller.
> Would be interesting to see at results for all 4 io schedulers.
> 
> Thanks
> Vivek
