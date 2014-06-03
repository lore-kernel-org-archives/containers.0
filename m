From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 11/12] block, bfq: boost the throughput
	on NCQ-capable flash-based devices
Date: Tue, 3 Jun 2014 13:11:24 -0400
Message-ID: <20140603171124.GE26210__27381.550303153$1401815502$gmane$org@htj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-12-git-send-email-paolo.valente@unimore.it>
	<20140531115216.GB5057@htj.dyndns.org>
	<36BFDB73-AEC2-4B87-9FD6-205E9431E722@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <36BFDB73-AEC2-4B87-9FD6-205E9431E722-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Mon, Jun 02, 2014 at 11:26:07AM +0200, Paolo Valente wrote:
> >> #define cond_for_expiring_non_wr  (bfqd->hw_tag && \
> >> -				   bfqd->wr_busy_queues > 0)
> >> +				   (bfqd->wr_busy_queues > 0 || \
> >> +				    (symmetric_scenario && \
> >> +				     blk_queue_nonrot(bfqd->queue))))
> > 
> > 	expire_non_wr = zzz;
> > 
> 
> The solution you propose is the first that came to my mind. But then
> I went for a clumsy macro-based solution because: 1) the whole
> function is all about evaluating a long logical expression, 2) the
> macro-based solution allows the short-circuit to be used at best,
> and the number of steps to be minimized. For example, with async
> queues, only one condition is evaluated.
> 
> Defining three variables entails instead that the value of all the
> variables is computed every time, even if most of the times there is
> no need to.
>
> Would this gain be negligible (sorry for my ignorance), or would
> not it be however enough to justify these unusual macros?

The compiler should be able to optimize those to basically the same
code.  AFAICS, everything the code tests is trivially known to be
without side-effect to the compiler.  Besides, even if the compiler
generates slightly less efficient code, which it shouldn't, it's
highly unlikely that this level of micro CPU cycle optimization would
be measureable for something as heavy as [bc]fq.

> > This optimization may be theoretically interesting but doesn't seem
> > practical at all and would make the sytem behave distinctively
> > differently depending on something which is extremely subtle and seems
> > completely unrelated.  Furthermore, on any system which uses blkcg,
> > ext4, btrfs or has any task which has non-zero nice value, it won't
> > make any difference.  Its value is only theoretical.
> 
> Turning on idling unconditionally when blkcg is used, is one of the
> first solutions we have considered. But there seem to be practical
> scenarios where this would cause an unjustified loss of
> throughput. The main example for us was ulatencyd, which AFAIK
> creates one group for each process and, by default, assigns to all
> processes the same weight. But the assigned weight is not the one
> associated to the default ioprio.

Isn't the optimization "not idling" when these conditions are met?
Shouldn't the comparison be against the benefit of "not idling
selectively" vs "always idling" when blkcg is in use?

Another problem there is that this not only depends on the number of
processes but the number of threads in it.  cgroup is moving away from
allowing threads of a single process in different cgroups, so this
means that the operation can fluctuate in a very unexpected manner.

I'm not really convinced about the approach.  With rotating disks, we
know that allowing queue depth > 1 generaly lowers both throughput and
responsiveness and brings benefits in quite restricted cases.  It
seems rather backwards to always allow QD > 1 and then try to optimize
in an attempt to recover what's lost.  Wouldn't it make far more sense
to actively maintain QD == 1 by default and allow QD > 1 in specific
cases where it can be determined to be more beneficial than harmful?

> I do not know how widespread a mechanism like ulatencyd is
> precisely, but in the symmetric scenario it creates, the throughput
> on, e.g., an HDD would drop by half if the workload is mostly random
> and we removed the more complex mechanism we set up.  Wouldn't this
> be bad?

It looks like a lot of complexity for optimization for a very
specific, likely unreliable (in terms of its triggering condition),
use case.  The triggering condition is just too specific.

> > Another thing to consider is that virtually all remotely modern
> > devices, rotational or not, are queued. At this point, it's rather
> > pointless to design one behavior for !queued and another for queued.
> > Things should just be designed for queued devices.
> 
> I am sorry for expressing doubts again (mainly because of my
> ignorance), but a few months ago I had to work with some portable
> devices for a company specialized in ARM systems. As an HDD, they
> were using a Toshiba MK6006GAH. If I remember well, this device had
> no NCQ. Instead of the improvements that we obtained by using bfq
> with this slow device, removing the differentiated behavior of bfq
> with respect to queued/!queued devices would have caused just a loss
> of throughput.

Heh, that's 60GB ATA-100 hard drive.  Had no idea those are still
being produced.  However, my point still is that the design should be
focused on queued devices.  They're predominant in the market and
it'll only continue to become more so.  What bothers me is that the
scheduler essentially loses control and shows sub-optimal behavior on
queued devices by default and that's how it's gonna perform in vast
majority of the use cases.

> >  I don't know what
> > the solution is but given that the benefits of NCQ for rotational
> > devices is extremely limited, sticking with single request model in
> > most cases and maybe allowing queued operation for specific workloads
> > might be a better approach.  As for ssds, just do something simple.
> > It's highly likely that most ssds won't travel this code path in the
> > near future anyway.
> 
> This is the point that worries me mostly. As I pointed out in one of my previous emails, dispatching requests to an SSD  without control causes high latencies, or even complete unresponsiveness (Figure 8 in
> http://algogroup.unimore.it/people/paolo/disk_sched/extra_results.php
> or Figure 9 in
> http://algogroup.unimore.it/people/paolo/disk_sched/results.php).
> 
> I am of course aware that efficiency is a critical issue with fast
> devices, and is probably destined to become more and more critical
> in the future. But, as a user, I would be definitely unhappy with a
> system that can, e.g., update itself in one minute instead of five,
> but, during that minute may become unresponsive. In particular, I
> would not be pleased to buy a more expensive SSD and get a much less
> responsive system than that I had with a cheaper HDD and bfq fully
> working.

blk-mq is right around the corner and newer devices won't travel this
path at all.  Hopefully, ahci too will be served through blk-mq too
when it's connected to ssds, so its usefulness for high performance
devices will diminsh rather quickly over the coming several years.  It
sure would be nice to still be able to carry some optimizations but it
does shift the trade-off balance in terms of how much extra complexity
is justified.

Thanks.

-- 
tejun
