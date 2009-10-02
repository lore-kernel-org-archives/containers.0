From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Fri, 02 Oct 2009 08:23:48 +0200
Message-ID: <1254464628.7158.101.camel__19024.337284691$1254464766$gmane$org@marge.simson.net>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
	<4ABC28DE.7050809@datenparkplatz.de>
	<20090925202636.GC15007@redhat.com>
	<1253976676.7005.40.camel@marge.simson.net>
	<1254034500.7933.6.camel@marge.simson.net>
	<20090927164235.GA23126@kernel.dk>
	<1254340730.7695.32.camel@marge.simson.net>
	<1254341139.7695.36.camel@marge.simson.net>
	<20090930202447.GA28236@redhat.com>
	<1254382405.7595.9.camel@marge.simson.net>
	<20091001185816.GU14918@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091001185816.GU14918-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
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

On Thu, 2009-10-01 at 20:58 +0200, Jens Axboe wrote:
> On Thu, Oct 01 2009, Mike Galbraith wrote:
> > > CIC_SEEK_THR is 8K jiffies so that would be 8seconds on 1000HZ system. Try
> > > using one "slice_idle" period of 8 ms. But it might turn out to be too
> > > short depending on the disk speed.
> > 
> > Yeah, it is too short, as is even _400_ ms.  Trouble is, by the time
> > some new task is determined to be seeky, the damage is already done.
> > 
> > The below does better, though not as well as "just say no to overload"
> > of course ;-)
> 
> So this essentially takes the "avoid impact from previous slice" to a
> new extreme, but idling even before dispatching requests from the new
> queue. We basically do two things to prevent this already - one is to
> only set the slice when the first request is actually serviced, and the
> other is to drain async requests completely before starting sync ones.
> I'm a bit surprised that the former doesn't solve the problem fully, I
> guess what happens is that if the drive has been flooded with writes, it
> may service the new read immediately and then return to finish emptying
> its writeback cache. This will cause an impact for any sync IO until
> that cache is flushed, and then cause that sync queue to not get as much
> service as it should have.

I did the stamping selection other than how long have we been solo based
on these possibly wrong speculations:

If we're in the idle window and doing the async drain thing, we've at
the spot where Vivek's patch helps a ton.  Seemed like a great time to
limit the size of any io that may land in front of my sync reader to
plain "you are not alone" quantity.

If we've got sync io in flight, that should mean that my new or old
known seeky queue has been serviced at least once.  There's likely to be
more on the way, so delay overloading then too. 

The seeky bit is supposed to be the earlier "last time we saw a seeker"
thing, but known seeky is too late to help a new task at all unless you
turn off the overloading for ages, so I added the if incalculable check
for good measure, hoping that meant the task is new, may want to exec.

Stamping any place may (see below) possibly limit the size of the io the
reader can generate as well as writer, but I figured what's good for the
goose is good for the the gander, or it ain't really good.  The overload
was causing the observed pain, definitely ain't good for both at these
times at least, so don't let it do that.

> Perhaps the "set slice on first complete" isn't working correctly? Or
> perhaps we just need to be more extreme.

Dunno, I was just tossing rocks and sticks at it.

I don't really understand the reasoning behind overloading:  I can see
that allows cutting thicker slabs for the disk, but with the streaming
writer vs reader case, seems only the writers can do that.  The reader
is unlikely to be alone isn't it?  Seems to me that either dd, a flusher
thread or kjournald is going to be there with it, which gives dd a huge
advantage.. it has two proxies to help it squabble over disk, konsole
has none.

	-Mike
