From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: lock-free clear page writeback (Was Re: [PATCH
 04/10] memcg: disable local interrupts in lock_page_cgroup()
Date: Fri, 8 Oct 2010 13:41:57 +0900
Message-ID: <20101008134157.bf2d42c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
	<AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
	<20101007093545.429fe04a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007105456.d86d8092.nishimura@mxp.nes.nec.co.jp>
	<20101007111743.322c3993.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152111.df687a62.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007152422.c5919517.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=kBnrtb5KkFQE3tNwVh1dWeUVBepWjec7ReVL0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <AANLkTi=kBnrtb5KkFQE3tNwVh1dWeUVBepWjec7ReVL0@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

On Fri, 8 Oct 2010 08:35:30 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Kame,
>=20
> On Thu, Oct 7, 2010 at 3:24 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Greg, I think clear_page_writeback() will not require _any_ locks wit=
h this patch.
> > But set_page_writeback() requires it...
> > (Maybe adding a special function for clear_page_writeback() is better=
 rather than
> > =C2=A0adding some complex to switch() in update_page_stat())
> >
> > =3D=3D
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Now, at page information accounting, we do lock_page_cgroup() if pc->=
mem_cgroup
> > points to a cgroup where someone is moving charges from.
> >
> > At supporing dirty-page accounting, one of troubles is writeback bit.
> > In general, writeback can be cleared via IRQ context. To update write=
back bit
> > with lock_page_cgroup() in safe way, we'll have to disable IRQ.
> > ....or do something.
> >
> > This patch waits for completion of writeback under lock_page() and do
> > lock_page_cgroup() in safe way. (We never got end_io via IRQ context.=
)
> >
> > By this, writeback-accounting will never see race with account_move()=
 and
> > it can trust pc->mem_cgroup always _without_ any lock.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > =C2=A0mm/memcontrol.c | =C2=A0 18 ++++++++++++++++++
> > =C2=A01 file changed, 18 insertions(+)
> >
> > Index: mmotm-0928/mm/memcontrol.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- mmotm-0928.orig/mm/memcontrol.c
> > +++ mmotm-0928/mm/memcontrol.c
> > @@ -2183,17 +2183,35 @@ static void __mem_cgroup_move_account(st
> > =C2=A0/*
> > =C2=A0* check whether the @pc is valid for moving account and call
> > =C2=A0* __mem_cgroup_move_account()
> > + * Don't call this under pte_lock etc...we'll do lock_page() and wai=
t for
> > + * the end of I/O.
> > =C2=A0*/
> > =C2=A0static int mem_cgroup_move_account(struct page_cgroup *pc,
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgr=
oup *from, struct mem_cgroup *to, bool uncharge)
> > =C2=A0{
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D -EINVAL;
> > +
> > + =C2=A0 =C2=A0 =C2=A0 /*
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We move severl flags and accounting in=
formation here. So we need to
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* avoid the races with update_stat routi=
nes. For most of routines,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* lock_page_cgroup() is enough for avoid=
ing race. But we need to take
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* care of IRQ context. If flag updates c=
omes from IRQ context, This
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* "move account" will be racy (and cause=
 deadlock in lock_page_cgroup())
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Now, the only race we have is Writebac=
k flag. We wait for it cleared
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* before starting our jobs.
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> > +
> > + =C2=A0 =C2=A0 =C2=A0 lock_page(pc->page);
> > + =C2=A0 =C2=A0 =C2=A0 wait_on_page_writeback(pc->page);
> > +
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0lock_page_cgroup(pc);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageCgroupUsed(pc) && pc->mem_cgroup =3D=
=3D from) {
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__mem_cgroup_m=
ove_account(pc, from, to, uncharge);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D 0;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page_cgroup(pc);
> > + =C2=A0 =C2=A0 =C2=A0 unlock_page(pc->page);
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * check events
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> >
> >
>=20
> Looks good to me.
> But let me ask a question.
> Why do only move_account need this logic?

Because charge/uncharge (add/remove to radix-tree or swapcache)
never happens while a page is PG_writeback.

> Is deadlock candidate is only this place?
yes.

> How about mem_cgroup_prepare_migration?
>=20
> unmap_and_move
> lock_page
> mem_cgroup_prepare_migration
> lock_page_cgroup
> ...
> softirq happen
> lock_page_cgroup
>=20
>=20
Nice cactch. I'll move prepare_migraon after wait_on_page_writeback()

> If race happens only where move_account and writeback, please describe
> it as comment.
> It would help to review the code in future.
>=20

Sure, updates are necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
