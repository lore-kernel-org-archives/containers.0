From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Thu, 07 Aug 2008 17:30:52 +0900 (JST)
Message-ID: <20080807.173052.13120905.taka__17559.7158879556$1218098076$gmane$org@valinux.co.jp>
References: <1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<2846be6b0808061237o6667c609l21bdb5a765469e95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2846be6b0808061237o6667c609l21bdb5a765469e95-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Naveen,

> > If we are pursuing a I/O prioritization model =E0 la CFQ the temptation=
 is
> > to implement it at the elevator layer or extend any of the existing I/O
> > schedulers.
> >
> > There have been several proposals that extend either the CFQ scheduler
> > (see (1), (2) below) or the AS scheduler (see (3) below). The problem
> > with these controllers is that they are scheduler dependent, which means
> > that they become unusable when we change the scheduler or when we want
> > to control stacking devices which define their own make_request_fn
> > function (md and dm come to mind). It could be argued that the physical
> > devices controlled by a dm or md driver are likely to be fed by
> > traditional I/O schedulers such as CFQ, but these I/O schedulers would
> > be running independently from each other, each one controlling its own
> > device ignoring the fact that they part of a stacking device. This lack
> > of information at the elevator layer makes it pretty difficult to obtain
> > accurate results when using stacking devices. It seems that unless we
> > can make the elevator layer aware of the topology of stacking devices
> > (possibly by extending the elevator API?) evelator-based approaches do
> > not constitute a generic solution. Here onwards, for discussion
> > purposes, I will refer to this type of I/O bandwidth controllers as
> > elevator-based I/O controllers.
> =

> It can be argued that any scheduling decision wrt to i/o belongs to
> elevators. Till now they have been used to improve performance. But
> with new requirements to isolate i/o based on process or cgroup, we
> need to change the elevators.
> =

> If we add another layer of i/o scheduling (block layer I/O controller)
> above elevators
> 1) It builds another layer of i/o scheduling (bandwidth or priority)
> 2) This new layer can have decisions for i/o scheduling which conflict
> with underlying elevator. e.g. If we decide to do b/w scheduling in
> this new layer, there is no way a priority based elevator could work
> underneath it.

I seems like the same goes for the current Linux kernel implementation
that if processes issued a lot of I/O requests and the io-request queue
of a disk is overflowed, all the I/O requests after will be blocked
and the priorities of them are meaningless.
In other word, it won't work if it receives lots of requests more than
the ability/bandwidth of a disk.

It doesn't seem so weird if it won't work if a cgroup issues lots of
I/O requests more than the bandwidth which is assigned to the cgroup.

> If a custom make_request_fn is defined (which means the said device is
> not using existing elevator), it could build it's own scheduling
> rather than asking kernel to add another layer at the time of i/o
> submission. Since it has complete control of i/o.

Thanks,
Hirokazu Takahashi
