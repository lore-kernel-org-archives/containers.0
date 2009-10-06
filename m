From: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: Do we support ioprio on SSDs with NCQ (Was: Re: IO scheduler
	based IO controller V10)
Date: Tue, 6 Oct 2009 20:53:42 +0200
Message-ID: <20091006185341.GD5216__23413.8231761337$1254855386$gmane$org@kernel.dk>
References: <20091002222756.GG4494@redhat.com>
	<4e5e476b0910030543o776fb505ka0ce38da9d83b33c@mail.gmail.com>
	<20091003133810.GC12925@redhat.com>
	<4e5e476b0910040215m35af5c99pf2c3a463a5cb61dd@mail.gmail.com>
	<20091004121122.GB18778@redhat.com>
	<4e5e476b0910040546h5f77cd1fo3172fe5c229eb579@mail.gmail.com>
	<x49my457uef.fsf@segfault.boston.devel.redhat.com>
	<4e5e476b0910051409x33f8365flf32e8e7548d72e79@mail.gmail.com>
	<20091006084120.GJ5216@kernel.dk>
	<4e5e476b0910060200i7c028b3fr4c235bf5f18c3aa1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4e5e476b0910060200i7c028b3fr4c235bf5f18c3aa1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Ulrich Lukas <stellplatz-nr.13a-7vBoImwI/YtIVYojq0lqJrNAH6kLmebB@public.gmane.org>, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 06 2009, Corrado Zoccolo wrote:
> On Tue, Oct 6, 2009 at 10:41 AM, Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> > On Mon, Oct 05 2009, Corrado Zoccolo wrote:
> >> On Mon, Oct 5, 2009 at 5:06 PM, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> > It stands for residual, not residency. =A0Make more sense?
> >> It makes sense when computed, but not when used in rb_key computation.
> >> Why should we postpone queues that where preempted, instead of giving
> >> them a boost?
> >
> > We should not, if it is/was working correctly, it should allow both for
> > increase/descrease of tree position (hence it's a long and can go
> > negative) to account for both over and under time.
> =

> I'm doing some tests with and without it.
> How it is working now is:
> definition:
>         if (timed_out && !cfq_cfqq_slice_new(cfqq)) {
>                 cfqq->slice_resid =3D cfqq->slice_end - jiffies;
>                 cfq_log_cfqq(cfqd, cfqq, "resid=3D%ld",
> cfqq->slice_resid);
>         }
> * here resid is > 0 if there was residual time, and < 0 if the queue
> overrun its slice.
> use:
>                 rb_key =3D cfq_slice_offset(cfqd, cfqq) + jiffies;
>                 rb_key +=3D cfqq->slice_resid;
>                 cfqq->slice_resid =3D 0;
> * here if residual is > 0, we postpone, i.e. penalize.  If residual is
> < 0 (i.e. the queue overrun), we anticipate it, i.e. we boost it.
> =

> So this is likely not what we want.

Indeed, that should be -=3D cfqq->slice_resid.

> I did some tests with and without it, or changing the sign, and it
> doesn't matter at all for pure sync workloads.

For most cases it will not change things a lot, but it should be
technically correct.

> The only case in which it matters a little, from my experiments, is
> for sync vs async workload. Here, since async queues are preempted,
> the current form of the code penalizes them, so they get larger
> delays, and we get more bandwidth for sync.

Right

> This is, btw, the only positive outcome (I can think of) from the
> current form of the code, and I think we could obtain it more easily
> by unconditionally adding a delay for async queues:
>                 rb_key =3D cfq_slice_offset(cfqd, cfqq) + jiffies;
> 		if (!cfq_cfqq_sync(cfqq)) {
>                         rb_key +=3D CFQ_ASYNC_DELAY;
> 	        }
> =

> removing completely the resid stuff (or at least leaving us with the
> ability of using it with the proper sign).

It's more likely for the async queue to overrun, but it can happen for
others as well. I'm keeping the residual count, but making the sign
change of course.

-- =

Jens Axboe
