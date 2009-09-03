From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/23] io-controller: blkio_cgroup patches from Ryo to
	track async bios.
Date: Wed, 2 Sep 2009 22:40:14 -0400
Message-ID: <20090903024014.GA8644__48831.9142409184$1251945798$gmane$org@redhat.com>
References: <20090901141142.GA13709@redhat.com>
	<20090902.185251.193693849.ryov@valinux.co.jp>
	<20090902135821.GB5012@redhat.com>
	<20090903.112423.226782505.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090903.112423.226782505.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Sep 03, 2009 at 11:24:23AM +0900, Ryo Tsuruta wrote:
> Hi Vivek,
> =

> Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > > > > > > - Somebody also gave an example where there is a memory hoggi=
ng process and
> > > > > > > =A0possibly pushes out some processes to swap. It does not so=
und fair to
> > > > > > > =A0charge those proccess for that swap writeout. These proces=
ses never
> > > > > > > =A0requested swap IO.
> > > > > =

> > > > > I think that swap writeouts should be charged to the memory hoggi=
ng
> > > > > process, because the process consumes more resources and it shoul=
d get
> > > > > a penalty.
> > > > > =

> > > > =

> > > > A process requesting memory gets IO penalty? IMHO, swapping is a ke=
rnel =

> > > > mechanism and kernel's way of providing extended RAM. If we want to=
 solve
> > > > the issue of memory hogging by a process then right way to solve is=
 to use
> > > > memory controller and not by charging the process for IO activity.
> > > > Instead, proabably a more suitable way is to charge swap activity t=
o root
> > > > group (where by default all the kernel related activity goes).   =

> > > =

> > > No. In the current blkio-cgroup, a process which uses a large amount
> > > of memory gets penalty, not a memory requester.
> > > =

> > =

> > At ioband level you just get to see bio and page. How do you decide whe=
ter
> > this bio is being issued by a process which is a memory hog?
> > =

> > In fact requester of memory could be anybody. It could be memory hog or=
 a
> > different process. So are you saying that you got a mechanism where you =

> > can detect that a process is memory hog and charge swap activity to it.
> > IOW, if there are two processes A and B and assume A is the memory hog =
and
> > then B requests for memory which triggers lot of swap IO, then you can
> > charge all that IO to memory hog A?
> =

> When an annoymou page is allocated, blkio-cgroup sets an ID to the
> page. And then when the page is going to swap out, dm-ioband can know
> who the owner of the page is by retrieving ID from the page.
> =

> In the above case, since the pages of the process A are swapped-out, =

> dm-ioband charges swap IO to the process A.
> =


But this does not mean that in all cases memory hog is being charged for
swap IO, as you have said. So if a process A has done some anonymous page
allocations and later a memory hog B comes in and forces swap out of A, =

you will charge A for swap activity which does not seem fair as B is
memory hog here?

Thanks
Vivek

> > Can you please point me to the relevant code in dm-ioband?
> > =

> > IMHO, to keep things simple, all swapping activity should be charged to
> > root group and be considered as kernel activity and user space not be
> > charged for that.
> =

> Thanks,
> Ryo Tsuruta
