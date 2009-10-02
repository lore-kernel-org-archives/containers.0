From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 16:56:10 +0200
Message-ID: <20091002145610.GD31616__44627.3217596628$1254495446$gmane$org@kernel.dk>
References: <1254340730.7695.32.camel@marge.simson.net>
	<1254341139.7695.36.camel@marge.simson.net>
	<20090930202447.GA28236@redhat.com>
	<1254382405.7595.9.camel@marge.simson.net>
	<20091001185816.GU14918@kernel.dk>
	<1254464628.7158.101.camel@marge.simson.net>
	<20091002080417.GG14918@kernel.dk> <20091002092409.GA19529@elte.hu>
	<20091002092839.GA26962@kernel.dk>
	<alpine.LFD.2.01.0910020715160.6996@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0910020715160.6996-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 02 2009, Linus Torvalds wrote:
> 
> 
> On Fri, 2 Oct 2009, Jens Axboe wrote:
> > 
> > It's really not that simple, if we go and do easy latency bits, then
> > throughput drops 30% or more.
> 
> Well, if we're talking 500-950% improvement vs 30% deprovement, I think 
> it's pretty clear, though. Even the server people do care about latencies. 
> 
> Often they care quite a bit, in fact.

Mostly they care about throughput, and when they come running because
some their favorite app/benchmark/etc is now 2% slower, I get to hear
about it all the time. So yes, latency is not ignored, but mostly they
yack about throughput.

> And Mike's patch didn't look big or complicated. 

It wasn't, it was more of a hack than something mergeable though (and I
think Mike will agree on that). So I'll repeat what I said to Mike, I'm
very well prepared to get something worked out and merged and I very
much appreciate the work he's putting into this.

> > You can't say it's black and white latency vs throughput issue,
> 
> Umm. Almost 1000% vs 30%. Forget latency vs throughput. That's pretty damn 
> black-and-white _regardless_ of what you're measuring. Plus you probably 
> made up the 30% - have you tested the patch?

The 30% is totally made up, it's based on previous latency vs throughput
tradeoffs. I haven't tested Mike's patch.

> And quite frankly, we get a _lot_ of complaints about latency. A LOT. It's 
> just harder to measure, so people seldom attach numbers to it. But that 
> again means that when people _are_ able to attach numbers to it, we should 
> take those numbers _more_ seriously rather than less.

I agree, we can easily make CFQ be very about about latency. If you
think that is fine, then lets just do that. Then we'll get to fix the
server side up when the next RHEL/SLES/whatever cycle is honing in on a
kernel, hopefully we wont have to start over when that happens.

> So the 30% you threw out as a number is pretty much worthless. 

It's hand waving, definitely. But I've been doing io scheduler tweaking
for years, and I know how hard it is to balance. If you want latency,
then you basically only ever give the device 1 thing to do. And you let
things cool down before switching over. If you do that, then your nice
big array of SSDs or rotating drives will easily drop to 1/4th of the
original performance. So we try and tweak the logic to make everybody
happy.

In some cases I wish we had a server vs desktop switch, since it would
decisions on this easier. I know you say that servers care about
latency, but not at all to the extent that desktops do. Most desktop
users would gladly give away the top of the performance for latency,
that's not true of most server users. Depends on what the server does,
of course.

-- 
Jens Axboe
