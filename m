From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 19:56:29 +0200
Message-ID: <20091002175629.GA14860__13936.554050497$1254506349$gmane$org@elte.hu>
References: <20091002092409.GA19529@elte.hu> <20091002092839.GA26962@kernel.dk>
	<alpine.LFD.2.01.0910020715160.6996@localhost.localdomain>
	<20091002145610.GD31616@kernel.dk>
	<alpine.LFD.2.01.0910020811490.6996@localhost.localdomain>
	<20091002171129.GG31616@kernel.dk> <20091002172046.GA2376@elte.hu>
	<20091002172554.GJ31616@kernel.dk> <20091002172842.GA4884@elte.hu>
	<20091002173732.GK31616@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091002173732.GK31616-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


* Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:

> On Fri, Oct 02 2009, Ingo Molnar wrote:
> > 
> > * Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > On Fri, Oct 02 2009, Ingo Molnar wrote:
> > > > 
> > > > * Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> > > > 
> > > > > It's not _that_ easy, it depends a lot on the access patterns. A 
> > > > > good example of that is actually the idling that we already do. 
> > > > > Say you have two applications, each starting up. If you start them 
> > > > > both at the same time and just care for the dumb low latency, then 
> > > > > you'll do one IO from each of them in turn. Latency will be good, 
> > > > > but throughput will be aweful. And this means that in 20s they are 
> > > > > both started, while with the slice idling and priority disk access 
> > > > > that CFQ does, you'd hopefully have both up and running in 2s.
> > > > > 
> > > > > So latency is good, definitely, but sometimes you have to worry 
> > > > > about the bigger picture too. Latency is more than single IOs, 
> > > > > it's often for complete operation which may involve lots of IOs. 
> > > > > Single IO latency is a benchmark thing, it's not a real life 
> > > > > issue. And that's where it becomes complex and not so black and 
> > > > > white. Mike's test is a really good example of that.
> > > > 
> > > > To the extent of you arguing that Mike's test is artificial (i'm not 
> > > > sure you are arguing that) - Mike certainly did not do an artificial 
> > > > test - he tested 'konsole' cache-cold startup latency, such as:
> > > 
> > > [snip]
> > > 
> > > I was saying the exact opposite, that Mike's test is a good example of 
> > > a valid test. It's not measuring single IO latencies, it's doing a 
> > > sequence of valid events and looking at the latency for those. It's 
> > > benchmarking the bigger picture, not a microbenchmark.
> > 
> > Good, so we are in violent agreement :-)
> 
> Yes, perhaps that last sentence didn't provide enough evidence of 
> which category I put Mike's test into :-)
> 
> So to kick things off, I added an 'interactive' knob to CFQ and 
> defaulted it to on, along with re-enabling slice idling for hardware 
> that does tagged command queuing. This is almost completely identical 
> to what Vivek Goyal originally posted, it's just combined into one and 
> uses the term 'interactive' instead of 'fairness'. I think the former 
> is a better umbrella under which to add further tweaks that may 
> sacrifice throughput slightly, in the quest for better latency.
> 
> It's queued up in the for-linus branch.

i'd say 'latency' describes it even better. 'interactivity' as a term is 
a bit overladen.

	Ingo
