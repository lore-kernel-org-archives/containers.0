From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: Do not overload dispatch queue (Was: Re: IO scheduler based IO
	controller V10)
Date: Sat, 03 Oct 2009 21:49:46 +0200
Message-ID: <1254599386.7153.46.camel__15578.9291755811$1254599461$gmane$org@marge.simson.net>
References: <20091003124049.GB12925@redhat.com>
	<20091003132115.GB31616@kernel.dk> <20091003135623.GD12925@redhat.com>
	<1254578553.7499.5.camel@marge.simson.net>
	<20091003142840.GE31616@kernel.dk>
	<1254581496.8293.8.camel@marge.simson.net>
	<20091003151445.GF31616@kernel.dk>
	<1254585420.7539.2.camel@marge.simson.net>
	<20091003173532.GG31616@kernel.dk>
	<1254596864.7153.9.camel@marge.simson.net>
	<20091003192321.GA26573@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091003192321.GA26573-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
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

On Sat, 2009-10-03 at 21:23 +0200, Jens Axboe wrote:
> On Sat, Oct 03 2009, Mike Galbraith wrote:

> > > So that's pure goodness, at least.
> > 
> > Yeah, but it's a double edged sword, _maybe_ cut too far in the other
> > direction.  (impression)
> 
> How can it be too fast? IOW, I think you'll have to quantify that
> statement :-)

Oh boy.  It it were perfectly fair, it should be roughly twice the time
it takes to load seekily when running solo, which it's exceeded
considerably.  I'm not complaining mind you, just being a worry wart.
Previously the reader was suffering the pains of hell, which the two
dinky changes made match my expectations nearly perfectly (1.7 sec is
real close to 1.8, which is real close to the 0.9 it takes to get the
bugger loaded cold)

> > > So far that looks like a winner. The dictator wanted good latency, he's
> > > getting good latency. I'll continue working on this on monday, while I'm
> > > waiting for delivery of the Trabant.
> > 
> > I'm unsure feel wise.  Disk is sounding too seeky, which worries me.
> 
> Care to elaborate on the feel? Seekiness is not good of course,
> depending on timing the async delay could cause some skipping back and
> forth. But remember that when you don't hear the disk, it could likely
> be doing the async IO which will make the disk very quiet (since it's
> just a streamed write). The konsole test is bound to cause seeks, when
> it's juggling async IO too. Even alone it's likely pretty seeky. So is
> the seekiness persistent, or just shortly when starting konsole?

It's a huge winner for sure, and there's no way to quantify.  I'm just
afraid the other shoe will drop from what I see/hear.  I should have
kept my trap shut and waited really, but the impression was strong.
Sorry for making unquantifiable noise.  Ignore me.  I've been
watching/feeling tests for too many hours and hours and hours ;-)

	-Mike
