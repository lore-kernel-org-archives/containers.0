From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/23] io-controller: blkio_cgroup patches from Ryo to
	track async bios.
Date: Tue, 1 Sep 2009 10:11:42 -0400
Message-ID: <20090901141142.GA13709__14408.4953041331$1251814577$gmane$org@redhat.com>
References: <4A9C09BE.4060404@redhat.com> <20090831185640.GF3758@redhat.com>
	<e98e18940908311651s26de5b70ye6f4a82402956309@mail.gmail.com>
	<20090901.160004.226800357.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090901.160004.226800357.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
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

On Tue, Sep 01, 2009 at 04:00:04PM +0900, Ryo Tsuruta wrote:
> Hi,
> =

> > > Hi Rik,
> > >
> > > Thanks for reviewing the patches. I wanted to have better understandi=
ng of
> > > where all does it help to associate a bio to the group of process who
> > > created/owned the page. Hence few thoughts.
> > >
> > > When a bio is submitted to IO scheduler, it needs to determine the gr=
oup
> > > bio belongs to and group which should be charged to. There seem to be=
 two
> > > methods.
> > >
> > > - Attribute the bio to cgroup submitting process belongs to.
> > > - For async requests, track the original owner hence cgroup of the pa=
ge
> > > =A0and charge that group for the bio.
> > >
> > > One can think of pros/cons of both the approaches.
> > >
> > > - The primary use case of tracking async context seems be that if a
> > > =A0process T1 in group G1 mmaps a big file and then another process T=
2 in
> > > =A0group G2, asks for memory and triggers reclaim and generates write=
s of
> > > =A0the file pages mapped by T1, then these writes should not be charg=
ed to
> > > =A0T2, hence blkio_cgroup pages.
> > >
> > > =A0But the flip side of this might be that group G2 is a low weight g=
roup
> > > =A0and probably too busy also right now, which will delay the write o=
ut
> > > =A0and possibly T2 will wait longer for memory to be allocated.
> =

> In order to avoid this wait, dm-ioband issues IO which has a page with
> PG_Reclaim as early as possible.
> =


So in above case IO is still charged to G2 but you keep a track if page is
PG_Reclaim then releae the this bio before other bios queued up in the
group?

> > > - At one point of time Andrew mentioned that buffered writes are gene=
rally a
> > > =A0big problem and one needs to map these to owner's group. Though I =
am not
> > > =A0very sure what specific problem he was referring to. Can we attrib=
ute
> > > =A0buffered writes to pdflush threads and move all pdflush threads in=
 a
> > > =A0cgroup to limit system wide write out activity?
> =

> I think that buffered writes also should be controlled per cgroup as
> well as synchronous writes.
> =


But it is hard to achieve fairness for buffered writes becase we don't
create complete parallel IO paths and not necessarily higher weight
process dispatches more buffered writes to IO scheduler. (Due to page
cache buffered write logic).

So in some cases we might see buffered write fairness and in other cases
not. For example, run two dd processes in two groups doing buffered writes
and it is hard to achieve fairness between these.

That's why the idea that if we can't ensure Buffered write vs Buffered
write fairness in all the cases, then does it make sense to attribute
buffered writes to pdflush and put pdflush threads into a separate group
to limit system wide write out activity. =


> > > - Somebody also gave an example where there is a memory hogging proce=
ss and
> > > =A0possibly pushes out some processes to swap. It does not sound fair=
 to
> > > =A0charge those proccess for that swap writeout. These processes never
> > > =A0requested swap IO.
> =

> I think that swap writeouts should be charged to the memory hogging
> process, because the process consumes more resources and it should get
> a penalty.
> =


A process requesting memory gets IO penalty? IMHO, swapping is a kernel =

mechanism and kernel's way of providing extended RAM. If we want to solve
the issue of memory hogging by a process then right way to solve is to use
memory controller and not by charging the process for IO activity.
Instead, proabably a more suitable way is to charge swap activity to root
group (where by default all the kernel related activity goes).   =


> > > - If there are multiple buffered writers in the system, then those wr=
iters
> > > =A0can also be forced to writeout some pages to disk before they are
> > > =A0allowed to dirty more pages. As per the page cache design, any wri=
ter
> > > =A0can pick any inode and start writing out pages. So it can happen a
> > > =A0weight group task is writting out pages dirtied by a lower weight =
group
> > > =A0task. If, async bio is mapped to owner's group, it might happen th=
at
> > > =A0higher weight group task might be made to sleep on lower weight gr=
oup
> > > =A0task because request descriptors are all consumed up.
> =

> As mentioned above, in dm-ioband, the bio is charged to the page owner
> and issued immediately.

But you are doing it only for selected pages and not for all buffered
writes?

> =

> > > It looks like there does not seem to be a clean way which covers all =
the
> > > cases without issues. I am just trying to think, what is a simple way
> > > which covers most of the cases. Can we just stick to using submitting=
 task
> > > context to determine a bio's group (as cfq does). Which can result in
> > > following.
> > >
> > > - Less code and reduced complexity.
> > >
> > > - Buffered writes will be charged to pdflush and its group. If one wi=
sh to
> > > =A0limit buffered write activity for pdflush, one can move all the pd=
flush
> > > =A0threads into a group and assign desired weight. Writes submitted in
> > > =A0process context will continue to be charged to that process irresp=
ective
> > > =A0of the fact who dirtied that page.
> > =

> > What if we wanted to control buffered write activity per group? If a
> > group keeps dirtying pages, we wouldn't want it to dominate the disk
> > IO capacity at the expense of other cgroups (by dominating the writes
> > sent down by pdflush).
> =

> Yes, I think that is true.
> =


But anyway we are not able to gurantee this isolation in all the cases.
Again I go back to example of two dd threads doing buffered writes in two
groups.

I don't mind keeping it. Just wanted to make sure that we agree and
understand that keeping it does not mean that we get buffered write vs
buffered write isolation/fairness in all the cases.

> > > - swap activity will be charged to kswapd and its group. If swap writ=
es
> > > =A0are coming from process context, it gets charged to process and its
> > > =A0group.
> > >
> > > - If one is worried about the case of one process being charged for w=
rite
> > > =A0out of file mapped by another process during reclaim, then we can
> > > =A0probably make use of memory controller and mount memory controller=
 and
> > > =A0io controller together on same hierarchy. I am told that with memo=
ry
> > > =A0controller, group's memory will be reclaimed by the process reques=
ting
> > > =A0more memory. If that's the case, then IO will automatically be cha=
rged
> > > =A0to right group if we use submitting task context.
> > >
> > > I just wanted to bring this point forward for more discussions to know
> > > what is the right thing to do? Use bio tracking or not.
> =

> Thanks for bringing it forward.
> =


Thanks
Vivek
