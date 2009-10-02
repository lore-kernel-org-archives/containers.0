From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 21:09:36 +0200
Message-ID: <20091002190936.GT31616__30295.4344464981$1254510617$gmane$org@kernel.dk>
References: <20091002171129.GG31616@kernel.dk> <20091002172046.GA2376@elte.hu>
	<20091002172554.GJ31616@kernel.dk> <20091002172842.GA4884@elte.hu>
	<20091002173732.GK31616@kernel.dk> <20091002175629.GA14860@elte.hu>
	<20091002180437.GL31616@kernel.dk> <20091002183649.GE8161@mit.edu>
	<20091002184549.GS31616@kernel.dk> <20091002190110.GA25297@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091002190110.GA25297-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 02 2009, Ingo Molnar wrote:
> 
> * Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Fri, Oct 02 2009, Theodore Tso wrote:
> > > On Fri, Oct 02, 2009 at 08:04:37PM +0200, Jens Axboe wrote:
> > > > > i'd say 'latency' describes it even better. 'interactivity' as a term is 
> > > > > a bit overladen.
> > > > 
> > > > I'm not too crazy about it either. How about just using 'desktop' 
> > > > since this is obviously what we are really targetting? 'latency' 
> > > > isn't fully descriptive either, since it may not necessarily 
> > > > provide the best single IO latency (noop would).
> > > 
> > > As Linus has already pointed out, it's not necessarily "desktop" 
> > > versus "server".  There will be certain high frequency transaction 
> > > database workloads (for example) that will very much care about 
> > > latency.  I think "low_latency" may be the best term to use.
> > 
> > Not necessarily, but typically it will be. As already noted, I don't 
> > think latency itself is a very descriptive term for this.
> 
> Why not? Nobody will think of 'latency' as something that requires noop, 
> but as something that in practice achieves low latencies, for stuff that 
> people use.

Alright, I'll acknowledge that if that's the general consensus. I may be
somewhat biased myself.

-- 
Jens Axboe
