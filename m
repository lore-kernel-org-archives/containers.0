From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC RESEND 00/14] New version of the BFQ I/O Scheduler
Date: Fri, 30 May 2014 13:55:27 -0400
Message-ID: <20140530175527.GH16605@redhat.com>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
	<20140530153228.GE16605@redhat.com>
	<20140530161650.GH24871@htj.dyndns.org>
	<20140530170958.GF16605@redhat.com>
	<20140530172609.GI24871@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140530172609.GI24871-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, paolo <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 30, 2014 at 01:26:09PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Fri, May 30, 2014 at 01:09:58PM -0400, Vivek Goyal wrote:
> > Are you referring to BFQ paper. I had read one in the past and it was
> > all about how to achieve more accurate fairness. At this point of time
> > I don't think that smarter algorithm is the problem. Until and unless
> > somebody can show me that how algorithm is a problem.
> 
> Because cfq rr's with heuristically guessed slices and bfq calculates
> where each one is supposed to end and then schedules the slices
> accordingly.  With a lot of slices to serve, cfq loses track of which
> one should come first to adhere to desired latency guarantees while
> bfq doesn't, which in turn allows more latitude in using longer slices
> for bfq allowing for better throughput.  It's all in the paper and
> backed by numbers.  What more do you want?

Now CFQ also dynamically adjusts the slice length based on the how
many queues are ready to do IO. One problem with fixed slice lenth
round robin was that if there are lot of queues doing IO, then after
serving one queue, same queue will get time slice after a long time.

Corrado Zoccolo did work in this area in an attempt to improve latency.
Now slice length is calculated dynamically in an attempt to achieve
better latency.

commit 5db5d64277bf390056b1a87d0bb288c8b8553f96
Author: Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date:   Mon Oct 26 22:44:04 2009 +0100

    cfq-iosched: adapt slice to number of processes doing I/O
 
> 
> > Apart from algorithm, one thing BFQ did different in the past was provide
> > fairness based on amount of IO done *and not in terms of time slice*. I
> > don't know if that's still the case. If it is the case I am wondering
> > why CFQ was converted from amount of IO based fairness to time slice
> > based fairness.
> 
> Rotating rusts being rotating rusts, either measure isn't perfect.
> Bandwidth tracking gets silly with seeky workloads while pure time
> slice tracking unfairly treats users of inner and outer tracks.  BFQ
> uses bw tracking for sequential workload while basically switches to
> time slice tracking for seeky workloads.  These were pretty clearly
> discussed in the paper.

Ok, so you prefer to have another IO scheduler instead of improving
CFQ?

> 
> > I am all for a better algorithm. I just want to somebody to explain it
> > to me that what magic they have done to achieve better throughput as
> > well as better latency.
> 
> It feels more like you're actively refusing to understand it even when
> the algorithm and heristics involved are as clearly presented as it
> could be.  This is one of the best documented piece of work in this
> area of the kernel.  Just read the papers.

Tejun, I have spent significant amount of time on BFQ few years ago. And
that's the reason I have not read it again yet. My understanding was
that there was nothing which would not be done in CFQ (atleast things
which mattered).

Looks like you prefer introducing a new scheduler instead of improving
CFQ. My preference is to improve CFQ. Borrow good ideas from BFQ and
implement them in CFQ.

> 
> > Do you think that CFQ's problems come from round robin algorithms. No,
> > they don't. Most of the time we don't even honor the allocated time
> 
> Oh yes, why do you think we bother with preemption at all?  bfq
> reportedly achieves sufficient fairness and responsiveness without the
> need for preemption.  This is a lot clearer model.

We primarily allow preemption of buffered write queue. If you allocate
a share for buffered write queue, that would be good for not starving
buffered writes but your read latencies should go down. 

> 
> > slice (except sequential IO) and preempt the allocated slice. That's
> > why I think implementing a more fair algorithm is probably not the
> > solution.
> 
> If you actually study what has been presented, you'd immediately
> recognize that a lot of what bfq does is clarification and
> improvements of the buried heuristics.
> 
> Look at it this way: RR + preemption becomes the basic timestamp based
> scheduling and other heuristics are extracted and clarified.  That's
> what it is.
> 
> > CFQ's throughput problems come from idling and driving lower queue depth.
> > And CFQ's throughput problems arise due to suppressing buffered write
> > very actively in presence of sync IO. 
> > 
> > I want to know what has BFQ done fundamentally different to take care of
> > above issues. 
> 
> Yeah, read the paper.  They also analyzed why some things behave
> certain ways.  A lot of them are pretty spot-on.
> 
> > Remember CFQ had started with a simple algorith. Just start allocating
> > time slice in proportion to ioprio. That simple scheme did not work in
> > real world and then it became more complicated.
> 
> Yes, this is another refinement step.  WTF is that so hard to warp
> your head around it?  It doesn't throw away much.  It builds upon cfq
> and clarifies and improves what it has been doing.

So why not improve CFQ instead of carrying and maintaining another 
scheduler. And then have a discussion that what's the default scheduler.

If plan is that BFQ is better than CFQ and instead of fixing CFQ lets
introduce BFQ and slowly phase out CFQ, please say so.

There is alredy lot of confusion in terms of explaining to people what
IO scheduler to use and now there is another one in the mix which is
almost same as CFQ but supposedely performs better.

Thanks
Vivek
