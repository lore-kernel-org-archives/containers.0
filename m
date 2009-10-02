From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 02 Oct 2009 14:22:16 +0200
Message-ID: <1254486136.11743.62.camel__8923.14867019213$1254486193$gmane$org@marge.simson.net>
References: <1254034500.7933.6.camel@marge.simson.net>
	<20090927164235.GA23126@kernel.dk>
	<1254340730.7695.32.camel@marge.simson.net>
	<1254341139.7695.36.camel@marge.simson.net>
	<20090930202447.GA28236@redhat.com>
	<1254382405.7595.9.camel@marge.simson.net>
	<20091001185816.GU14918@kernel.dk>
	<1254464628.7158.101.camel@marge.simson.net>
	<20091002080417.GG14918@kernel.dk>
	<1254473609.6378.24.camel@marge.simson.net>
	<20091002095555.GB26962@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091002095555.GB26962-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-10-02 at 11:55 +0200, Jens Axboe wrote:
> On Fri, Oct 02 2009, Mike Galbraith wrote:
> >
> >         /*
> >          * Drain async requests before we start sync IO
> >          */
> >         if (cfq_cfqq_idle_window(cfqq) && cfqd->rq_in_driver[BLK_RW_ASYNC])
> > 
> > Looked about the same to me as..
> >  
> > 	enable_idle = old_idle = cfq_cfqq_idle_window(cfqq);
> > 
> > ..where Vivek prevented turning 1 into 0, so I stamped it ;-)
> 
> cfq_cfqq_idle_window(cfqq) just tells you whether this queue may enter
> idling, not that it is currently idling. The actual idling happens from
> cfq_completed_request(), here:
> 
>                 else if (cfqq_empty && !cfq_close_cooperator(cfqd, cfqq, 1) &&
>                          sync && !rq_noidle(rq))
>                         cfq_arm_slice_timer(cfqd);
> 
> and after that the queue will be marked as waiting, so
> cfq_cfqq_wait_request(cfqq) is a better indication of whether we are
> currently waiting for a request (idling) or not.

Hm.  Then cfq_cfqq_idle_window(cfqq) actually suits my intent better.

(If I want to reduce async's advantage, I should target specifically, ie
only stamp if this queue is a sync queue....otoh, if this queue is sync,
it is now officially too late, whereas if this queue is dd about to
inflict the wrath of kjournald on my reader's world, stamping now is a
really good idea.. scritch scritch scritch <smoke>)

I'll go tinker with it.  Thanks for the clue.

	-Mike
