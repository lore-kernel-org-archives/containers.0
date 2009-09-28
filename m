From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Mon, 28 Sep 2009 14:18:46 -0400
Message-ID: <20090928181846.GC3643__33060.1942296655$1254162131$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<4e5e476b0909271000u69d79346s27cccad219e49902@mail.gmail.com>
	<20090928145655.GB8192@redhat.com>
	<4e5e476b0909280835w3410d58aod93a29d1dcda8909@mail.gmail.com>
	<1254160274.9820.25.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254160274.9820.25.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Cc: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Sep 28, 2009 at 07:51:14PM +0200, Mike Galbraith wrote:
> On Mon, 2009-09-28 at 17:35 +0200, Corrado Zoccolo wrote:
> 
> > Great.
> > Can you try the attached patch (on top of 2.6.31)?
> > It implements the alternative approach we discussed privately in july,
> > and it addresses the possible latency increase that could happen with
> > your patch.
> > 
> > To summarize for everyone, we separate sync sequential queues, sync
> > seeky queues and async queues in three separate RR strucutres, and
> > alternate servicing requests between them.
> > 
> > When servicing seeky queues (the ones that are usually penalized by
> > cfq, for which no fairness is usually provided), we do not idle
> > between them, but we do idle for the last queue (the idle can be
> > exited when any seeky queue has requests). This allows us to allocate
> > disk time globally for all seeky processes, and to reduce seeky
> > processes latencies.
> > 
> > I tested with 'konsole -e exit', while doing a sequential write with
> > dd, and the start up time reduced from 37s to 7s, on an old laptop
> > disk.
> 
> I was fiddling around trying to get IDLE class to behave at least, and
> getting a bit frustrated.  Class/priority didn't seem to make much if
> any difference for konsole -e exit timings, and now I know why.

You seem to be testing kconsole timings against a writer. In case of a 
writer prio will not make much of a difference as prio only adjusts length
of slice given to process and writers rarely get to use their slice
length. Reader immediately preemtps it...

I guess changing class to IDLE should have helped a bit as now this is
equivalent to setting the quantum to 1 and after dispatching one request
to disk, CFQ will always expire the writer once. So it might happen that
by the the reader preempted writer, we have less number of requests in
disk and lesser latency for this reader.

> I saw
> the reference to Vivek's patch, and gave it a shot.  Makes a large
> difference.
>                                                            Avg
> perf stat     12.82     7.19     8.49     5.76     9.32    8.7     anticipatory
>               16.24   175.82   154.38   228.97   147.16  144.5     noop
>               43.23    57.39    96.13   148.25   180.09  105.0     deadline
>                9.15    14.51     9.39    15.06     9.90   11.6     cfq fairness=0 dd=nice 0
>               12.22     9.85    12.55     9.88    15.06   11.9     cfq fairness=0 dd=nice 19
>                9.77    13.19    11.78    17.40     9.51   11.9     cfq fairness=0 dd=SCHED_IDLE
>                4.59     2.74     4.70     3.45     4.69    4.0     cfq fairness=1 dd=nice 0
>                3.79     4.66     2.66     5.15     3.03    3.8     cfq fairness=1 dd=nice 19
>                2.79     4.73     2.79     4.02     2.50    3.3     cfq fairness=1 dd=SCHED_IDLE
> 

Hmm.., looks like average latency went down only in  case of fairness=1
and not in case of fairness=0. (Looking at previous mail, average vanilla
cfq latencies were around 12 seconds).

Are you running all this in root group or have you put writers and readers
into separate cgroups?

If everything is running in root group, then I am curious why latency went
down in case of fairness=1. The only thing fairness=1 parameter does is
that it lets complete all the requests from previous queue before start
dispatching from next queue. On top of this is valid only if no preemption
took place. In your test case, konsole should preempt the writer so
practically fairness=1 might not make much difference.

In fact now Jens has committed a patch which achieves the similar effect as
fairness=1 for async queues.

commit 5ad531db6e0f3c3c985666e83d3c1c4d53acccf9
Author: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date:   Fri Jul 3 12:57:48 2009 +0200

    cfq-iosched: drain device queue before switching to a sync queue
    
    To lessen the impact of async IO on sync IO, let the device drain of
    any async IO in progress when switching to a sync cfqq that has idling
    enabled.


If everything is in separate cgroups, then we should have seen latency 
improvements in case of fairness=0 case also. I am little perplexed here..

Thanks
Vivek
