From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 08:49:21 -0400
Message-ID: <20091002124921.GA4494__25958.3657877103$1254487863$gmane$org@redhat.com>
References: <200910021255.27689.czoccolo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200910021255.27689.czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 02, 2009 at 12:55:25PM +0200, Corrado Zoccolo wrote:
> Hi Jens,
> On Fri, Oct 2, 2009 at 11:28 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> > On Fri, Oct 02 2009, Ingo Molnar wrote:
> >>
> >> * Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> >>
> >
> > It's really not that simple, if we go and do easy latency bits, then
> > throughput drops 30% or more. You can't say it's black and white latency
> > vs throughput issue, that's just not how the real world works. The
> > server folks would be most unpleased.
> Could we be more selective when the latency optimization is introduced?
> 
> The code that is currently touched by Vivek's patch is:
>         if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
>             (cfqd->hw_tag && CIC_SEEKY(cic)))
>                 enable_idle = 0;
> basically, when fairness=1, it becomes just:
>         if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle)
>                 enable_idle = 0;
> 

Actually I am not touching this code. Looking at the V10, I have not
changed anything here in idling code.

I think we are seeing latency improvements with fairness=1 because, CFQ
does pure roundrobin and once a seeky reader expires, it is put at the
end of the queue.

I retained the same behavior if fairness=0 but if fairness=1, then I don't
put the seeky reader at the end of queue, instead it gets vdisktime based
on the disk it has used. So it should get placed ahead of sync readers.

I think following is the code snippet in "elevator-fq.c" which is making a
difference.

        /*
         * We don't want to charge more than allocated slice otherwise
         * this
         * queue can miss one dispatch round doubling max latencies. On
         * the
         * other hand we don't want to charge less than allocated slice as
         * we stick to CFQ theme of queue loosing its share if it does not
         * use the slice and moves to the back of service tree (almost).
         */
        if (!ioq->efqd->fairness)
                queue_charge = allocated_slice;
 
So if a sync readers consumes 100ms and an seeky reader dispatches only
one request, then in CFQ, seeky reader gets to dispatch next request after
another 100ms.

With fairness=1, it should get a lower vdisktime when it comes with a new
request because its last slice usage was less (like CFS sleepers as mike
said). But this will make a difference only if there are more than one
processes in the system otherwise a vtime jump will take place by the time
seeky readers gets backlogged.

Anyway, once I started timestamping the queues and started keeping a cache
of expired queues, then any queue which got new request almost
immediately, should get a lower vdisktime assigned if it did not use the
full time slice in the previous dispatch round. Hence  with fairness=1,
seeky readers kind of get more share of disk (fair share), because these
are now placed ahead of streaming readers and hence get better latencies.

In short, most likely, better latencies are being experienced because
seeky reader is getting lower time stamp (vdisktime), because it did not
use its full time slice in previous dispatch round, and not because we kept
the idling enabled on seeky reader.

Thanks
Vivek

> Note that, even if we enable idling here, the cfq_arm_slice_timer will use
> a different idle window for seeky (2ms) than for normal I/O.
> 
> I think that the 2ms idle window is good for a single rotational SATA disk scenario,
> even if it supports NCQ. Realistic access times for those disks are still around 8ms
> (but it is proportional to seek lenght), and waiting 2ms to see if we get a nearby
> request may pay off, not only in latency and fairness, but also in throughput.
> 
> What we don't want to do is to enable idling for NCQ enabled SSDs
> (and this is already taken care in cfq_arm_slice_timer) or for hardware RAIDs.
> If we agree that hardware RAIDs should be marked as non-rotational, then that
> code could become:
> 
>         if (!atomic_read(&cic->ioc->nr_tasks) || !cfqd->cfq_slice_idle ||
>             (blk_queue_nonrot(cfqd->queue) && cfqd->hw_tag && CIC_SEEKY(cic)))
>                 enable_idle = 0;
>         else if (sample_valid(cic->ttime_samples)) {
> 		unsigned idle_time = CIC_SEEKY(cic) ? CFQ_MIN_TT : cfqd->cfq_slice_idle;
> 		if (cic->ttime_mean > idle_time)
>                         enable_idle = 0;
>                 else
>                         enable_idle = 1;
>         }
> 
> Thanks,
> Corrado
> 
> >
> > --
> > Jens Axboe
> >
> 
> -- 
> __________________________________________________________________________
> 
> dott. Corrado Zoccolo                          mailto:czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> PhD - Department of Computer Science - University of Pisa, Italy
> --------------------------------------------------------------------------
