From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Mon, 26 Jul 2010 07:18:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1007260711310.1050@takamine.ncl.cs.columbia.edu>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
	<1279569285.25071.98.camel@localhost>
	<AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM@mail.gmail.com>
	<4C4516DD.1000809@cs.columbia.edu>
	<AANLkTimPENgm-LSh6iMv2uxegRdHEivbGMTYmEfiOEJG@mail.gmail.com>
	<Pine.LNX.4.64.1007201906370.15255@takamine.ncl.cs.columbia.edu>
	<AANLkTinZYiWPtSegjRJWnlc6hipFAZyujr8-2ug6ettF@mail.gmail.com>
	<Pine.LNX.4.64.1007210143120.22870@takamine.ncl.cs.columbia.edu>
	<AANLkTinOFIzK8RZnp9NHouKv-WA7Omr08pPTGfrfVLfP@mail.gmail.com>
	<Pine.LNX.4.64.1007212102010.6257@takamine.ncl.cs.columbia.edu>
	<AANLkTimW98q0sFZeCAk3xHsEfBV9yhL4kUKHjNGxn_2P@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="998262290-1590582552-1280143114=:1050"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimW98q0sFZeCAk3xHsEfBV9yhL4kUKHjNGxn_2P-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: John Paul Walters <jpnwalters-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--998262290-1590582552-1280143114=:1050
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id o6QBIi7r001157

Hi John,

Please try the following patch - it should be applied _instead_ of the=20
patch I sent on 7/20.

The previous patch was still insufficient when the root task has not only=
=20
threads, but also a child (the child was a "ghost" task used temporarily=20
during restart). I believe this patch correctly addresses the problem, an=
d=20
I tested against your program with and without --pidns.

I'll wait for your confirmation before pushing the fix to cpt-v22-dev.

Thanks !

Oren.

---
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index 171c867..c5517c2 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -625,8 +625,11 @@ int walk_task_subtree(struct task_struct *root,
 		}
=20
 		/* if we arrive at root again -- done */
-		if (task =3D=3D root)
-			break;
+		if (task =3D=3D root) {
+			/* if not last thread - proceed with thread */
+			task =3D root =3D next_thread(task);
+			if (thread_group_leader(task))
+				break;
 	}
 	read_unlock(&tasklist_lock);
=20
---

On Thu, 22 Jul 2010, John Paul Walters wrote:

> Hi Oren,
>=20
> Thanks for the patch.  For the --pidns case, that seems to have solved
> the problem.  In the case of --no-pidns, restart still hangs as
> described before.  Should this work with in the --no-pidns case, or is
> it expected to fail in this case?
>=20
> JP
>=20
> On Wed, Jul 21, 2010 at 9:04 PM, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wr=
ote:
> > Hi John,
> >
> > This is a bit embarrassing, the behavior sounds too familiar --
> > please try to following patch:
> >
> > --
> > diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoin=
t.c
> > index 3fb9deb..b770f70 100644
> > --- a/arch/x86/kernel/checkpoint.c
> > +++ b/arch/x86/kernel/checkpoint.c
> > @@ -104,7 +104,7 @@ int checkpoint_thread(struct ckpt_ctx *ctx, struc=
t task_struct *t)
> > =A0 =A0 =A0 =A0h->gdt_entry_tls_entries =3D GDT_ENTRY_TLS_ENTRIES;
> > =A0 =A0 =A0 =A0h->sizeof_tls_array =3D tls_size;
> > =A0 =A0 =A0 =A0h->sysenter_return =3D (__u64) (unsigned long)
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_thread_info(current)->sysenter_ret=
urn;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_thread_info(t)->sysenter_return;
> >
> > =A0 =A0 =A0 =A0/* For simplicity dump the entire array */
> > =A0 =A0 =A0 =A0memcpy(h + 1, t->thread.tls_array, tls_size);
> > --
> >
> > On Wed, 21 Jul 2010, John Paul Walters wrote:
> >
> >> >>
> >> >> Hi Oren,
> >> >>
> >> >> I'm still unable to fully restart the application with your patch=
, but
> >> >> the result is now different. =A0If I attempt to restart using =A0=
--pidns
> >> >> and -F, both threads are created and frozen. =A0However, as soon =
as I
> >> >> thaw them I get a segfault. =A0If I attempt to restart them witho=
ut the
> >> >> --pidns option, I get a message from restart indicating that it's
> >> >> about to call sys_restart and restart hangs. =A0I also have the
> >> >> following in my syslog:
> >> >
> >> > Hi John,
> >> >
> >> > I assume the log below is for the --no-pidns case, right ?
> >> > Can you also post the output of 'restart -vd ...' ?
> >> > (Unfortunately I won't have a chance to try it until the weekend)
> >> >
> >>
> >> Hi Oren,
> >>
> >> That's correct, the original log was for the --no-pidns case. =A0Bel=
ow
> >> I've included the restart log up to the point where it hangs at
> >> sys_restart. =A0Thanks again for all of your help.
> >>
> >> best,
> >> JP
> >>
> >> ./restart -v -d --no-pidns < checkpoint_out
> >> <4124>number of tasks: 2
> >> <4124>number of vpids: 0
> >> <4124>total tasks (including ghosts): 3
> >> <4124>pid 3583: thread tgid 3582
> >> <4124>pid 3583: creator set to 3582
> >> <4124>pid 1: propagate session 3582
> >> <4124>pid 1: creator set to 3582
> >> <4124>pid 1: set session
> >> <4124>pid 1: moving up to 3582
> >> <4124>=3D=3D=3D=3D=3D=3D TASKS
> >> <4124> =A0 =A0 =A0 =A0[0] pid 3582 ppid 3349 sid 0 creator 0
> >> <4124> =A0 =A0 =A0 =A0[1] pid 3583 ppid 3349 sid 0 creator 3582 prev=
 1 T
> >> <4124> =A0 =A0 =A0 =A0[2] pid 1 ppid 3582 sid 3582 creator 3582 next=
 3583 =A0 S G
> >> <4124>............
> >> <4124>task[0].vidx =3D -1
> >> <4124>task[1].vidx =3D -1
> >> <4124>subtree (existing pidns)
> >> <4124>forking child vpid 3582 flags 0x1
> >> <4124>task 3582 forking with flags 11 numpids 1
> >> <4124>task 3582 pid[0]=3D0
> >> <4124>forked child vpid 4126 (asked 3582)
> >> <4126>root task pid 4126
> >> <4126>pid 3582: pid 4126 sid 3386 parent 4124
> >> <4126>pid 3582: fork child 1 with session
> >> <4126>forking child vpid 1 flags 0x12
> >> <4126>task 1 forking with flags 11 numpids 1
> >> <4126>task 1 pid[0]=3D0
> >> <4126>forked child vpid 4127 (asked 1)
> >> <4126>pid 3582: fork child 3583 without session
> >> <4126>forking child vpid 3583 flags 0x4
> >> <4126>task 3583 forking with flags 10911 numpids 1
> >> <4126>task 3583 pid[0]=3D0
> >> <4126>forked child vpid 4128 (asked 3583)
> >> <4126>about to call sys_restart(), flags 0
> >> <4125>=3D=3D=3D=3D=3D=3D PIDS ARRAY
> >> <4125>[0] pid 3582 ppid 1 sid 1 pgid 3582
> >> <4125>[1] pid 3583 ppid 1 sid 1 pgid 3582
> >> <4125>............
> >> <4125>c/r swap old 3582 new 4126
> >> <4128>pid 3583: pid 4128 sid 3386 parent 4124
> >> <4128>about to call sys_restart(), flags 0
> >> <4125>c/r swap old 3583 new 4128
> >> <4127>pid 1: pid 4127 sid 3386 parent 4126
> >> <4125>c/r swap old 1 new 4127
> >> <4125>=3D=3D=3D=3D=3D=3D PIDS ARRAY (swaped)
> >> <4125>[0] pid 4126 ppid 1 sid 4127 pgid 4126
> >> <4125>[1] pid 4128 ppid 1 sid 4127 pgid 4126
> >> <4125>............
> >> <4125>c/r read input 16384
> >> <4127>about to call sys_restart(), flags 0x4
> >> <4125>c/r read input 16384
> >> <4125>c/r read input 16384
> >> <4125>c/r read input 16384
> >> <4125>c/r read input 16384
> >>
> >>
> >>
> >>
> >>
> >>
> >> > Thanks,
> >> >
> >> > Oren.
> >> >
> >> >>
> >> >>
> >> >> [ 1482.348060] [3753:3753:c/r:walk_task_subtree:633] total 2 ret =
1
> >> >> [ 1482.348060] [3753:3753:c/r:prepare_descendants:1148] nr 2/2
> >> >> [ 1482.348060] [3753:3753:c/r:do_restore_coord:1320] restore prep=
are: 2
> >> >> [ 1541.864073] [err -512][pos 419][E @ do_ghost_task:973]ghost re=
start failed
> >> >> [ 1541.864343] [err -512][pos 419][E @ do_restore_task:1084]task =
restart failed
> >> >> [ 1541.864346] [3755:3755:c/r:clear_task_ctx:852] task 3755 clear=
 checkpoint_ctx
> >> >> [ 1541.864349] [3755:3755:c/r:do_restart:1444] restart err -4, ex=
iting
> >> >> [ 1541.864352] [3755:3755:c/r:do_restart:1451] sys_restart return=
s -4
> >> >> [ 1541.864366] [3757:3757:c/r:wait_checkpoint_ctx:938]
> >> >> wait_checkpoint_ctx: failed (-512)
> >> >> [ 1541.864368] [3757:3757:c/r:do_restart:1444] restart err -4, ex=
iting
> >> >> [ 1541.864371] [3757:3757:c/r:do_restart:1451] sys_restart return=
s -4
> >> >> [ 1541.864689] [3753:3753:c/r:wait_all_tasks_finish:1173] final s=
ync
> >> >> kflags 0x1a (ret 0)
> >> >> [ 1541.864692] [3753:3753:c/r:do_restore_coord:1325] restore fini=
sh: 0
> >> >> [ 1541.864694] [3753:3753:c/r:do_restore_coord:1331] restore defe=
rqueue: 0
> >> >> [ 1541.864698] [err -512][pos 419][E @
> >> >> ckpt_read_obj_type:426]Expecting to read type 9001
> >> >> [ 1541.864700] [3753:3753:c/r:do_restore_coord:1336] restore tail=
: -512
> >> >> [ 1541.864703] [err -512][pos 419][E @ do_restore_coord:1350]rest=
art
> >> >> failed (coordinator)
> >> >> [ 1541.864706] [3753:3753:c/r:walk_task_subtree:633] total 0 ret =
0
> >> >> [ 1541.864709] [3753:3753:c/r:clear_task_ctx:852] task 3753 clear=
 checkpoint_ctx
> >> >> [ 1541.864715] [3753:3753:c/r:do_restart:1451] sys_restart return=
s -4
> >> >> [ 1541.864718] [3753:3753:c/r:restore_debug_free:144] 3 tasks
> >> >> registered, nr_tasks was 0 nr_total 1
> >> >> [ 1541.864721] [3753:3753:c/r:restore_debug_free:147] active pid =
was
> >> >> 0, ctx->errno -512
> >> >> [ 1541.864723] [3753:3753:c/r:restore_debug_free:149] kflags 26 u=
flags
> >> >> 0 oflags 1
> >> >> [ 1541.864726] [3753:3753:c/r:restore_debug_free:151] task[0] to =
run 3755
> >> >> [ 1541.864728] [3753:3753:c/r:restore_debug_free:151] task[1] to =
run 3757
> >> >> [ 1541.864731] [3753:3753:c/r:restore_debug_free:176] pid 3753 ty=
pe
> >> >> Coord state Failed
> >> >> [ 1541.864735] [3753:3753:c/r:restore_debug_free:176] pid 3755 ty=
pe
> >> >> Root state Failed
> >> >> [ 1541.864737] [3753:3753:c/r:restore_debug_free:176] pid 3756 ty=
pe
> >> >> Ghost state Failed
> >> >>
> >> >> thanks,
> >> >> JP
> >> >>
> >> >> >
> >> >> > ---
> >> >> > diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
> >> >> > index 171c867..3288af0 100644
> >> >> > --- a/kernel/checkpoint/sys.c
> >> >> > +++ b/kernel/checkpoint/sys.c
> >> >> > @@ -605,13 +605,13 @@ int walk_task_subtree(struct task_struct =
*root,
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> >> >> >
> >> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if not last thread - proceed w=
ith thread */
> >> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task =3D next_thread(task);
> >> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!thread_group_leader(task))
> >> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> >> >> > +
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* by definition, skip siblings =
of root */
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (task !=3D root) {
> >> >> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if not last th=
read - proceed with thread */
> >> >> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task =3D next_thr=
ead(task);
> >> >> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!thread_group=
_leader(task))
> >> >> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 b=
reak;
> >> >> > -
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* if has siblin=
g - proceed with sibling */
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!list_is_las=
t(&task->sibling, &parent->children)) {
> >> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
task =3D list_entry(task->sibling.next,
> >> >> > ---
> >> >>
> >> >>
> >>
> >>
>=20
>=20
--998262290-1590582552-1280143114=:1050
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--998262290-1590582552-1280143114=:1050--
