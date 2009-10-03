From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Sat, 3 Oct 2009 09:24:01 +0200
Message-ID: <20091003072401.GV31616__30829.4917027981$1254554774$gmane$org@kernel.dk>
References: <alpine.LFD.2.01.0910020811490.6996@localhost.localdomain>
	<20091002171129.GG31616@kernel.dk> <20091002172046.GA2376@elte.hu>
	<20091002172554.GJ31616@kernel.dk> <20091002172842.GA4884@elte.hu>
	<20091002173732.GK31616@kernel.dk>
	<1254507215.8667.7.camel@marge.simson.net>
	<20091002181903.GN31616@kernel.dk>
	<1254548931.8299.18.camel@marge.simson.net>
	<1254549378.8299.21.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254549378.8299.21.camel-YqMYhexLQo1vAv1Ojkdn7Q@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Oct 03 2009, Mike Galbraith wrote:
> On Sat, 2009-10-03 at 07:49 +0200, Mike Galbraith wrote:
> > On Fri, 2009-10-02 at 20:19 +0200, Jens Axboe wrote:
> > 
> > > If you could do a cleaned up version of your overload patch based on
> > > this:
> > > 
> > > http://git.kernel.dk/?p=linux-2.6-block.git;a=commit;h=1d2235152dc745c6d94bedb550fea84cffdbf768
> > > 
> > > then lets take it from there.
> 
> Note to self: build the darn thing after last minute changes.
> 
> Block:  Delay overloading of CFQ queues to improve read latency.
> 
> Introduce a delay maximum dispatch timestamp, and stamp it when:
>         1. we encounter a known seeky or possibly new sync IO queue.
>         2. the current queue may go idle and we're draining async IO.
>         3. we have sync IO in flight and are servicing an async queue.
>         4  we are not the sole user of disk.
> Disallow exceeding quantum if any of these events have occurred recently.
> 
> Protect this behavioral change with a "desktop_dispatch" knob and default
> it to "on".. providing an easy means of regression verification prior to
> hate-mail dispatch :) to CC list.

It still doesn't build:

block/cfq-iosched.c: In function ?cfq_dispatch_requests?:
block/cfq-iosched.c:1345: error: ?max_delay? undeclared (first use in
this function)

After shutting down the computer yesterday, I was thinking a bit about
this issue and how to solve it without incurring too much delay. If we
add a stricter control of the depth, that may help. So instead of
allowing up to max_quantum (or larger) depths, only allow gradual build
up of that the farther we get away from a dispatch from the sync IO
queues. For example, when switching to an async or seeky sync queue,
initially allow just 1 in flight. For the next round, if there still
hasn't been sync activity, allow 2, then 4, etc. If we see sync IO queue
again, immediately drop to 1.

It could tie in with (or partly replace) the overload feature. The key
to good latency and decent throughput is knowing when to allow queue
build up and when not to.

-- 
Jens Axboe
