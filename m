From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 11/12] block, bfq: boost the throughput
	on NCQ-capable flash-based devices
Date: Wed, 18 Jun 2014 21:14:45 -0400
Message-ID: <20140619011445.GA16203@mtj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-12-git-send-email-paolo.valente@unimore.it>
	<20140531115216.GB5057@htj.dyndns.org>
	<36BFDB73-AEC2-4B87-9FD6-205E9431E722@unimore.it>
	<20140603171124.GE26210@htj.dyndns.org>
	<03CDD106-DB18-4E8F-B3D6-2AAD45782A06@unimore.it>
	<20140604135627.GB5004@htj.dyndns.org>
	<D163E069-ED77-4BF5-A488-9A90C41C60C1@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <D163E069-ED77-4BF5-A488-9A90C41C60C1-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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

On Mon, Jun 16, 2014 at 12:46:36PM +0200, Paolo Valente wrote:
> To preserve the desired distribution of the device throughput (or time), this
> scheme entails updating weights every time the set of active queues changes.
> For example (sorry for the trivial example, but I just want to make sure that I am
> not misunderstanding what you are telling me), suppose that two groups,
> A and B, are reserved 50% of the throughput each, and that the first group contains
> two processes, whereas the second group just one process. Apart from the
> additional per-queue interventions of cfq to improve latency or throughput, the
> queues the two processes in in group A are reserved 50% of the group throughput
> each. It follows that, if all the three queues are backlogged, then a correct weight
> distribution for a flat underlying scheduler is, e.g., 25 and 25 for the two processes
> in group A, and 50 for the process in group B.
> 
> But, if one of the queues in group A becomes idle, then the correct weights
> of the still-active queues become, e.g., 50 and 50.

Yeap, that's what cfq is doing now.  Flattening priorities to the top
level each time the set of active queues changes.  It probably is
introducing weird artifacts to scheduling but given the existing
amount of existing noise I don't think it'd make a noticeable
difference.

> Changing weights this way has basically no influence of the per-request latency
> guarantees of cfq, because cfq is based on a round-robin scheme, and the latter
> already suffers from a large deviation with respect to an ideal service. In contrast,
> things change dramatically with an accurate scheduler, such as the internal
> B-WF2Q+ scheduler of BFQ. In that case, as explained, e.g., here for packet
> scheduling (but the problem is exactly the same)
> 
> http://www.algogroup.unimore.it/people/paolo/dynWF2Q+/dynWF2Q+.pdf
> 
> weight changes would just break service guarantees, and lead to the same
> deviation as a round-robin scheduler. As proved in the same
> document, to preserve guarantees, weight updates should be delayed/concealed
> in a non-trivial (although computationally cheap) way.

Ah, bummer.  Flattening is so much easier to deal with.

> If useful, I am willing to provide more details, although these aspects are most
> certainly quite theoretical and boring.

Including a simplified intuitive explanation of why fully hierarchical
scheduling is necessary with reference to more detailed explanation
would be nice.

> > Another thing I'm curious about is that the logic that you're using to
> > disable idling assumes that the disk will serve the queued commands
> > more or less in fair manner over time, right?  If so, why does queues
> > having the same weight matter?  Shouldn't the bandwidth scheduling
> > eventually make them converge to the specified weights over time?
> > Isn't wr_coeff > 1 test enough for maintaining reasonable
> > responsiveness?
> 
> Unfortunately, when I first defined bfq with Fabio, this was one of the main
> mistakes made in most of existing research I/O schedulers. More precisely, your
> statement is true for async queues, but fails for sync queues. The problem is that
> the (only) way in which a process pushes a scheduler into giving it its reserved
> throughput is by issuing requests at a higher rate than that at which they are
> served. But, with sync queues this just cannot happen. In particular,
> postponing the service of a sync request delays the arrival of the next,
> but not-yet-arrived, sync request of the same process. Intuitively, for the scheduler,
> it is like if the process was happy with the throughput it is receiving, because
> it happens to issue requests exactly at that rate.
> 
> This problems is described in more detail, for example, in Section 5.3 of
> http://www.algogroup.unimore.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf
> 
> bfq deals with this problem by properly back-shifting request timestamps when
> needed. But idling is necessary for this mechanism to work (unless more
> complex solutions are adopted).

Oh... I understand why idling is necessary to actually implement io
priorities.  I was wondering about the optimization for queued devices
and why it matters whether the active queues have equal weight or not.
If the optimization can be used for three of 1s, why can't it be used
for 1 and 2?

Thanks.

-- 
tejun
