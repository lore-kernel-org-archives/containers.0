From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH 18/23] io-controller: blkio_cgroup patches from Ryo to
	track async bios.
Date: Wed, 02 Sep 2009 18:52:51 +0900 (JST)
Message-ID: <20090902.185251.193693849.ryov__13045.294621452$1251885357$gmane$org@valinux.co.jp>
References: <e98e18940908311651s26de5b70ye6f4a82402956309@mail.gmail.com>
	<20090901.160004.226800357.ryov@valinux.co.jp>
	<20090901141142.GA13709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090901141142.GA13709-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

> > > > - The primary use case of tracking async context seems be that if a
> > > > =A0process T1 in group G1 mmaps a big file and then another process=
 T2 in
> > > > =A0group G2, asks for memory and triggers reclaim and generates wri=
tes of
> > > > =A0the file pages mapped by T1, then these writes should not be cha=
rged to
> > > > =A0T2, hence blkio_cgroup pages.
> > > >
> > > > =A0But the flip side of this might be that group G2 is a low weight=
 group
> > > > =A0and probably too busy also right now, which will delay the write=
 out
> > > > =A0and possibly T2 will wait longer for memory to be allocated.
> > =

> > In order to avoid this wait, dm-ioband issues IO which has a page with
> > PG_Reclaim as early as possible.
> > =

> =

> So in above case IO is still charged to G2 but you keep a track if page is
> PG_Reclaim then releae the this bio before other bios queued up in the
> group?

Yes, the bio with PG_Reclaim page is given priority over the other bios.

> > > > - At one point of time Andrew mentioned that buffered writes are ge=
nerally a
> > > > =A0big problem and one needs to map these to owner's group. Though =
I am not
> > > > =A0very sure what specific problem he was referring to. Can we attr=
ibute
> > > > =A0buffered writes to pdflush threads and move all pdflush threads =
in a
> > > > =A0cgroup to limit system wide write out activity?
> > =

> > I think that buffered writes also should be controlled per cgroup as
> > well as synchronous writes.
> > =

> =

> But it is hard to achieve fairness for buffered writes becase we don't
> create complete parallel IO paths and not necessarily higher weight
> process dispatches more buffered writes to IO scheduler. (Due to page
> cache buffered write logic).
> =

> So in some cases we might see buffered write fairness and in other cases
> not. For example, run two dd processes in two groups doing buffered writes
> and it is hard to achieve fairness between these.
> =

> That's why the idea that if we can't ensure Buffered write vs Buffered
> write fairness in all the cases, then does it make sense to attribute
> buffered writes to pdflush and put pdflush threads into a separate group
> to limit system wide write out activity. =


If all buffered writes are treated as system wide activities, it does
not mean that bandwidth is being controlled. It is true that pdflush
doesn't do I/O according to weight, but bandwidth (including for
bufferd writes) should be reserved for each cgroup.

> > > > - Somebody also gave an example where there is a memory hogging pro=
cess and
> > > > =A0possibly pushes out some processes to swap. It does not sound fa=
ir to
> > > > =A0charge those proccess for that swap writeout. These processes ne=
ver
> > > > =A0requested swap IO.
> > =

> > I think that swap writeouts should be charged to the memory hogging
> > process, because the process consumes more resources and it should get
> > a penalty.
> > =

> =

> A process requesting memory gets IO penalty? IMHO, swapping is a kernel =

> mechanism and kernel's way of providing extended RAM. If we want to solve
> the issue of memory hogging by a process then right way to solve is to use
> memory controller and not by charging the process for IO activity.
> Instead, proabably a more suitable way is to charge swap activity to root
> group (where by default all the kernel related activity goes).   =


No. In the current blkio-cgroup, a process which uses a large amount
of memory gets penalty, not a memory requester.

As you wrote, using both io-controller and memory controller are
required to prevent swap-out caused by memory consumption on another
cgroup.

> > > > - If there are multiple buffered writers in the system, then those =
writers
> > > > =A0can also be forced to writeout some pages to disk before they are
> > > > =A0allowed to dirty more pages. As per the page cache design, any w=
riter
> > > > =A0can pick any inode and start writing out pages. So it can happen=
 a
> > > > =A0weight group task is writting out pages dirtied by a lower weigh=
t group
> > > > =A0task. If, async bio is mapped to owner's group, it might happen =
that
> > > > =A0higher weight group task might be made to sleep on lower weight =
group
> > > > =A0task because request descriptors are all consumed up.
> > =

> > As mentioned above, in dm-ioband, the bio is charged to the page owner
> > and issued immediately.
> =

> But you are doing it only for selected pages and not for all buffered
> writes?

I'm sorry, I wrote wrong on the previous mail, IO for writing out
page-cache pages is not issued immediately, it is throttled by
dm-ioband.

Anyway, there is a case where a higher weight group task is made
to sleep, but if we reserve the memory for each cgroup by memory
controller in advance, we can avoid the task put to sleep.

Thanks,
Ryo Tsuruta
