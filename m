From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 2 Oct 2009 19:13:54 +0200
Message-ID: <20091002171354.GH31616__24233.8360906162$1254503725$gmane$org@kernel.dk>
References: <20090930202447.GA28236@redhat.com>
	<1254382405.7595.9.camel@marge.simson.net>
	<20091001185816.GU14918@kernel.dk>
	<1254464628.7158.101.camel@marge.simson.net>
	<20091002080417.GG14918@kernel.dk> <20091002092409.GA19529@elte.hu>
	<20091002092839.GA26962@kernel.dk>
	<alpine.LFD.2.01.0910020715160.6996@localhost.localdomain>
	<20091002145610.GD31616@kernel.dk>
	<2c0942db0910020933l6d312c6ahae0e00619f598b39@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2c0942db0910020933l6d312c6ahae0e00619f598b39-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 02 2009, Ray Lee wrote:
> On Fri, Oct 2, 2009 at 7:56 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> > In some cases I wish we had a server vs desktop switch, since it would
> > decisions on this easier. I know you say that servers care about
> > latency, but not at all to the extent that desktops do. Most desktop
> > users would gladly give away the top of the performance for latency,
> > that's not true of most server users. Depends on what the server does,
> > of course.
> 
> If most of the I/O on a system exhibits seeky tendencies, couldn't the
> schedulers notice that and use that as the hint for what to optimize?
> 
> I mean, there's no switch better than the actual I/O behavior itself.

Heuristics like that have a tendency to fail. What's the cut-off point?
Additionally, heuristics based on past process/system behaviour also has
a tendency to be suboptimal, since things aren't static.

We already look at seekiness of individual processes or groups. IIRC,
as-iosched also keeps a per-queue tracking.

-- 
Jens Axboe
