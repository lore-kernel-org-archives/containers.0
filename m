From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Sat, 26 Sep 2009 16:51:16 +0200
Message-ID: <1253976676.7005.40.camel__17702.9523336843$1253976851$gmane$org@marge.simson.net>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090925202636.GC15007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-09-25 at 16:26 -0400, Vivek Goyal wrote:
> On Fri, Sep 25, 2009 at 04:20:14AM +0200, Ulrich Lukas wrote:
> > Vivek Goyal wrote:
> > > Notes:
> > > - With vanilla CFQ, random writers can overwhelm a random reader.
> > >   Bring down its throughput and bump up latencies significantly.
> > 
> > 
> > IIRC, with vanilla CFQ, sequential writing can overwhelm random readers,
> > too.
> > 
> > I'm basing this assumption on the observations I made on both OpenSuse
> > 11.1 and Ubuntu 9.10 alpha6 which I described in my posting on LKML
> > titled: "Poor desktop responsiveness with background I/O-operations" of
> > 2009-09-20.
> > (Message ID: 4AB59CBB.8090907-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org)
> > 
> > 
> > Thus, I'm posting this to show that your work is greatly appreciated,
> > given the rather disappointig status quo of Linux's fairness when it
> > comes to disk IO time.
> > 
> > I hope that your efforts lead to a change in performance of current
> > userland applications, the sooner, the better.
> > 
> [Please don't remove people from original CC list. I am putting them back.]
> 
> Hi Ulrich,
> 
> I quicky went through that mail thread and I tried following on my
> desktop.
> 
> ##########################################
> dd if=/home/vgoyal/4G-file of=/dev/null &
> sleep 5
> time firefox
> # close firefox once gui pops up.
> ##########################################
> 
> It was taking close to 1 minute 30 seconds to launch firefox and dd got 
> following.
> 
> 4294967296 bytes (4.3 GB) copied, 100.602 s, 42.7 MB/s
> 
> (Results do vary across runs, especially if system is booted fresh. Don't
>  know why...).
> 
> 
> Then I tried putting both the applications in separate groups and assign
> them weights 200 each.
> 
> ##########################################
> dd if=/home/vgoyal/4G-file of=/dev/null &
> echo $! > /cgroup/io/test1/tasks
> sleep 5
> echo $$ > /cgroup/io/test2/tasks
> time firefox
> # close firefox once gui pops up.
> ##########################################
> 
> Now I firefox pops up in 27 seconds. So it cut down the time by 2/3.
> 
> 4294967296 bytes (4.3 GB) copied, 84.6138 s, 50.8 MB/s
> 
> Notice that throughput of dd also improved.
> 
> I ran the block trace and noticed in many a cases firefox threads
> immediately preempted the "dd". Probably because it was a file system
> request. So in this case latency will arise from seek time.
> 
> In some other cases, threads had to wait for up to 100ms because dd was
> not preempted. In this case latency will arise both from waiting on queue
> as well as seek time.

Hm, with tip, I see ~10ms max wakeup latency running scriptlet below.

> With cgroup thing, We will run 100ms slice for the group in which firefox
> is being launched and then give 100ms uninterrupted time slice to dd. So
> it should cut down on number of seeks happening and that's why we probably
> see this improvement.

I'm not testing with group IO/CPU, but my numbers kinda agree that it's
seek latency that's THE killer.  What the compiled numbers below from
the cheezy script below that _seem_ to be telling me is that the default
setting of CFQ quantum is allowing too many write requests through,
inflicting too much read latency... for the disk where my binaries live.
The longer the seeky burst, the more it hurts both reader/writer, so
cutting down the max requests queueable helps the reader (which i think
can't queue anything near per unit time that the writer can) finish and
get out of the writer's way sooner.

'nuff possibly useless words, onward to possibly useless numbers :)

dd pre == number dd emits upon receiving USR1 before execing perf.
perf stat == time to load/execute perf stat konsole -e exit.
dd post == same after dd number, after perf finishes.

quantum = 1                                                  Avg
dd pre         58.4     52.5     56.1     61.6     52.3     56.1  MB/s
perf stat      2.87     0.91     1.64     1.41     0.90      1.5  Sec
dd post        56.6     61.0     66.3     64.7     60.9     61.9

quantum = 2
dd pre         59.7     62.4     58.9     65.3     60.3     61.3
perf stat      5.81     6.09     6.24    10.13     6.21      6.8
dd post        64.0     62.6     64.2     60.4     61.1     62.4

quantum = 3
dd pre         65.5     57.7     54.5     51.1     56.3     57.0
perf stat     14.01    13.71     8.35     5.35     8.57      9.9
dd post        59.2     49.1     58.8     62.3     62.1     58.3

quantum = 4
dd pre         57.2     52.1     56.8     55.2     61.6     56.5
perf stat     11.98     1.61     9.63    16.21    11.13     10.1
dd post        57.2     52.6     62.2     49.3     50.2     54.3

Nothing pinned btw, 4 cores available, but only 1 drive.

#!/bin/sh

DISK=sdb
QUANTUM=/sys/block/$DISK/queue/iosched/quantum
END=$(cat $QUANTUM)

for q in `seq 1 $END`; do
	echo $q > $QUANTUM
	LOGFILE=quantum_log_$q
	rm -f $LOGFILE
	for i in `seq 1 5`; do
		echo 2 > /proc/sys/vm/drop_caches
		sh -c "dd if=/dev/zero of=./deleteme.dd 2>&1|tee -a $LOGFILE" &
		sleep 30
		sh -c "echo quantum $(cat $QUANTUM) loop $i" 2>&1|tee -a $LOGFILE
		perf stat -- killlall -q get_stuf_into_ram >/dev/null 2>&1
		sleep 1
		killall -q -USR1 dd &
		sleep 1
		sh -c "perf stat -- konsole -e exit" 2>&1|tee -a $LOGFILE
		sleep 1
		killall -q -USR1 dd &
		sleep 5
		killall -qw dd
		rm -f ./deleteme.dd
		sync
		sh -c "echo" 2>&1|tee -a $LOGFILE
	done;
done;
