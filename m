From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 02 Oct 2009 20:13:35 +0200
Message-ID: <1254507215.8667.7.camel__22148.2322937392$1254507325$gmane$org@marge.simson.net>
References: <20091002080417.GG14918@kernel.dk>
	<20091002092409.GA19529@elte.hu> <20091002092839.GA26962@kernel.dk>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-10-02 at 19:37 +0200, Jens Axboe wrote:
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
> Yes, perhaps that last sentence didn't provide enough evidence of which
> category I put Mike's test into :-)
> 
> So to kick things off, I added an 'interactive' knob to CFQ and
> defaulted it to on, along with re-enabling slice idling for hardware
> that does tagged command queuing. This is almost completely identical to
> what Vivek Goyal originally posted, it's just combined into one and uses
> the term 'interactive' instead of 'fairness'. I think the former is a
> better umbrella under which to add further tweaks that may sacrifice
> throughput slightly, in the quest for better latency.
> 
> It's queued up in the for-linus branch.

FWIW, I did a matrix of Vivek's patch combined with my hack.  Seems we
do lose a bit of dd throughput over stock with either or both.

dd pre         65.1     65.4     67.5     64.8     65.1   65.5     fairness=1 overload_delay=1
perf stat      1.70     1.94     1.32     1.89     1.87    1.7
dd post        69.4     62.3     69.7     70.3     69.6   68.2

dd pre         67.0     67.8     64.7     64.7     64.9   65.8     fairness=1 overload_delay=0
perf stat      4.89     3.13     2.98     2.71     2.17    3.1
dd post        67.2     63.3     62.6     62.8     63.1   63.8

dd pre         65.0     66.0     66.9     64.6     67.0   65.9     fairness=0 overload_delay=1
perf stat      4.66     3.81     4.23     2.98     4.23    3.9
dd post        62.0     60.8     62.4     61.4     62.2   61.7

dd pre         65.3     65.6     64.9     69.5     65.8   66.2     fairness=0 overload_delay=0
perf stat     14.79     9.11    14.16     8.44    13.67   12.0
dd post        64.1     66.5     64.0     66.5     64.4   65.1
