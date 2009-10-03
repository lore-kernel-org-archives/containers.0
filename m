From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: IO scheduler based IO controller V10
Date: Sat, 3 Oct 2009 15:18:26 +0200
Message-ID: <20091003131826.GA31616__21747.7053673521$1254576195$gmane$org@kernel.dk>
References: <20091002172554.GJ31616@kernel.dk> <20091002172842.GA4884@elte.hu>
	<20091002173732.GK31616@kernel.dk>
	<1254507215.8667.7.camel@marge.simson.net>
	<20091002181903.GN31616@kernel.dk>
	<1254548931.8299.18.camel@marge.simson.net>
	<1254549378.8299.21.camel@marge.simson.net>
	<20091003072401.GV31616@kernel.dk>
	<1254560434.17052.14.camel@marge.simson.net>
	<4e5e476b0910030212y50f97d97nc2e17c35d855cc63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4e5e476b0910030212y50f97d97nc2e17c35d855cc63-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Corrado Zoccolo <czoccolo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, Oct 03 2009, Corrado Zoccolo wrote:
> Hi,
> On Sat, Oct 3, 2009 at 11:00 AM, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org> wrote:
> > On Sat, 2009-10-03 at 09:24 +0200, Jens Axboe wrote:
> >
> >> After shutting down the computer yesterday, I was thinking a bit about
> >> this issue and how to solve it without incurring too much delay. If we
> >> add a stricter control of the depth, that may help. So instead of
> >> allowing up to max_quantum (or larger) depths, only allow gradual build
> >> up of that the farther we get away from a dispatch from the sync IO
> >> queues. For example, when switching to an async or seeky sync queue,
> >> initially allow just 1 in flight. For the next round, if there still
> >> hasn't been sync activity, allow 2, then 4, etc. If we see sync IO que=
ue
> >> again, immediately drop to 1.
> >>
> =

> I would limit just async I/O. Seeky sync queues are automatically
> throttled by being sync, and have already high latency, so we
> shouldn't increase it artificially. I think, instead, that we should
> send multiple seeky requests (possibly coming from different queues)
> at once. They will help especially with raid devices, where the seeks
> for requests going to different disks will happen in parallel.
> =

Async is the prime offendor, definitely.

> >> It could tie in with (or partly replace) the overload feature. The key
> >> to good latency and decent throughput is knowing when to allow queue
> >> build up and when not to.
> >
> > Hm. =A0Starting at 1 sounds a bit thin (like IDLE), multiple iterations=
 to
> > build/unleash any sizable IO, but that's just my gut talking.
> >
> On the other hand, sending 1 write first and then waiting it to
> complete before submitting new ones, will help performing more merges,
> so the subsequent requests will be bigger and thus more efficient.

Usually async writes stack up very quickly, so as long as you don't
drain completely, the merging will happen automagically anyway.

-- =

Jens Axboe
