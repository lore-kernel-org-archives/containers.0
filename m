From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Wed, 06 Aug 2008 15:41:32 +0900
Message-ID: <1218004892.3950.12.camel__17698.8236410127$1218005044$gmane$org@sebastian.kern.oss.ntt.co.jp>
References: <20080804.175126.193692178.ryov@valinux.co.jp>
	<1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<20080806.151824.104049463.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080806.151824.104049463.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2008-08-06 at 15:18 +0900, Ryo Tsuruta wrote:
> Hi Fernando,
> 
> > This RFC ended up being a bit longer than I had originally intended, but
> > hopefully it will serve as the start of a fruitful discussion.
> 
> Thanks a lot for posting the RFC.
> 
> > *** Goals
> >   1. Cgroups-aware I/O scheduling (being able to define arbitrary
> > groupings of processes and treat each group as a single scheduling
> > entity).
> >   2. Being able to perform I/O bandwidth control independently on each
> > device.
> >   3. I/O bandwidth shaping.
> >   4. Scheduler-independent I/O bandwidth control.
> >   5. Usable with stacking devices (md, dm and other devices of that
> > ilk).
> >   6. I/O tracking (handle buffered and asynchronous I/O properly).
> >
> > The list of goals above is not exhaustive and it is also likely to
> > contain some not-so-nice-to-have features so your feedback would be
> > appreciated.
> 
> I'd like to add the following item to the goals.
> 
>   7. Selectable from multiple bandwidth control policy (proportion,
>      maximum rate limiting, ...) like I/O scheduler.
Yep, makes sense.

> > *** How to move on
> > 
> > As discussed before, it probably makes sense to have both a block layer
> > I/O controller and a elevator-based one, and they could certainly
> > cohabitate. As discussed before, all of them need I/O tracking
> > capabilities so I would like to suggest the plan below to get things
> > started:
> > 
> >   - Improve the I/O tracking patches (see (6) above) until they are in
> > mergeable shape.
> >   - Fix CFQ and AS to use the new I/O tracking functionality to show its
> > benefits. If the performance impact is acceptable this should suffice to
> > convince the respective maintainer and get the I/O tracking patches
> > merged.
> >   - Implement a block layer resource controller. dm-ioband is a working
> > solution and feature rich but its dependency on the dm infrastructure is
> > likely to find opposition (the dm layer does not handle barriers
> > properly and the maximum size of I/O requests can be limited in some
> > cases). In such a case, we could either try to build a standalone
> > resource controller based on dm-ioband (which would probably hook into
> > generic_make_request) or try to come up with something new.
> >   - If the I/O tracking patches make it into the kernel we could move on
> > and try to get the Cgroup extensions to CFQ and AS mentioned before (see
> > (1), (2), and (3) above for details) merged.
> >   - Delegate the task of controlling the rate at which a task can
> > generate dirty pages to the memory controller.
> 
> I agree with your plan.
> We keep bio-cgroup improving and porting to the latest kernel.
Having more users of bio-cgroup would probably help to get it merged, so
we'll certainly send patches as soon as we get our cfq prototype in
shape.

Regards,

Fernando
