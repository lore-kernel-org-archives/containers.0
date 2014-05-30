From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC RESEND 00/14] New version of the BFQ I/O Scheduler
Date: Fri, 30 May 2014 13:09:58 -0400
Message-ID: <20140530170958.GF16605@redhat.com>
References: <1401194558-5283-1-git-send-email-paolo.valente@unimore.it>
	<20140530153228.GE16605@redhat.com>
	<20140530161650.GH24871@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140530161650.GH24871-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On Fri, May 30, 2014 at 12:16:50PM -0400, Tejun Heo wrote:
> Hello, Vivek.
> 
> On Fri, May 30, 2014 at 11:32:28AM -0400, Vivek Goyal wrote:
> > I don't think most of the people care about strong fairness guarantee.
> > As an algorithm round robin is not bad for ensuring fairness. CFQ had
> > started with that but then it stopped focussing on fairness and rather
> > focussed on trying to address various real issues.
> 
> Oh, I widely disagree.  Have you looked at the test results in the
> paper?  Unless the results are completely bogus, which it probably
> isn't, this is awesome.  This is a *lot* more clearly characterized
> algorithm which shows significantly better behavior especially in use
> cases where scheduling matters.  I mean, it even reaches higher
> throughput while achieving lower latency.  Why wouldn't we want it?
> 

Of everybody wants "higher throughput while achieving lower latency". Most
of the time these are contradictory goals.

Instead of just looking at numbers, I am keen on knowing what's the
fundamental design change which allows this. What is CFQ doing wrong
which BFQ gets right.

Are you referring to BFQ paper. I had read one in the past and it was
all about how to achieve more accurate fairness. At this point of time
I don't think that smarter algorithm is the problem. Until and unless
somebody can show me that how algorithm is a problem.

Apart from algorithm, one thing BFQ did different in the past was provide
fairness based on amount of IO done *and not in terms of time slice*. I
don't know if that's still the case. If it is the case I am wondering
why CFQ was converted from amount of IO based fairness to time slice
based fairness.

I am all for a better algorithm. I just want to somebody to explain it
to me that what magic they have done to achieve better throughput as
well as better latency.

Do you think that CFQ's problems come from round robin algorithms. No,
they don't. Most of the time we don't even honor the allocated time
slice (except sequential IO) and preempt the allocated slice. That's
why I think implementing a more fair algorithm is probably not the
solution.

CFQ's throughput problems come from idling and driving lower queue depth.
And CFQ's throughput problems arise due to suppressing buffered write
very actively in presence of sync IO. 

I want to know what has BFQ done fundamentally different to take care of
above issues. 

> > And CFQ's problems don't arise from not having a good fairness algorithm.
> > So I don't think this should be the reason for taking a new scheduler.
> 
> In comparison, cfq's fairness behavior is a lot worse but even
> ignoring thing, one of the major problems of cfq is that the behavior
> is hardly characterized.  It's really difficult to anticipate what
> it'd do and understand why, which makes it very difficult to maintain
> and improve.  Even just for the latter point, it'd be worthwhile to
> adopt bfq.

Remember CFQ had started with a simple algorith. Just start allocating
time slice in proportion to ioprio. That simple scheme did not work in
real world and then it became more complicated.

What's the guarantee that same thing will not happen to BFQ. There is
no point in getting fairness if overall performance sucks. That's what
happens even with block IO cgroups. Create more than 4 cgroups, put some
workload in that and with CFQ your performance will be so bad that you
will drop the idea of getting fairness.

Why performance is bad, again due to idling. In an attmept to provide
isolation between IO of two cgroups, we idle. You want to dilute the
the isolation, sure you will get better throughput and CFQ can do that
too.

> 
> > I think instead of numbers, what would help is a short description
> > that what's the fundamental problem with CFQ which BFQ does not
> > have and how did you solve that issue.
> 
> The papers are pretty clear and not too long.  Have you read them?

Can you please provide me the link to the paper. I had read one few
years back. I am not sure if it is still the same paper of a new one.
And after experimenting with their implementation and playing with 
CFQ, my impression was that fairness algorithm is not the core problem.

I will be more than happy to be proven wrong. Just I need somebody to
not throw just numbers at me but rather explain to me that why BFQ
performs better and why CFQ can't do the same thing.

Thanks
Vivek
