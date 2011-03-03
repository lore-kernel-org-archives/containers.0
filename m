From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Thu, 3 Mar 2011 17:35:31 +0100
Message-ID: <20110303163531.GO21429@hawkmoon.kerlabs.com>
References: <20110225075552.GB24361@us.ibm.com>
	<20110225115507.GD3915@hawkmoon.kerlabs.com>
	<20110225190132.GA31300@us.ibm.com>
	<20110226135431.GA3251@kerlabs.com>
	<4D6BB499.7050602@cs.columbia.edu>
	<20110228150942.GD18970@hawkmoon.kerlabs.com>
	<4D6C1D58.5060400@cs.columbia.edu>
	<20110301153105.GD4410@hawkmoon.kerlabs.com>
	<4D6FB5D9.8010002@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9125998293646476896=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D6FB5D9.8010002-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============9125998293646476896==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-29138-1299170064-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-29138-1299170064-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 03/03/11 10:38 -0500, Oren Laadan wrote:
>=20
>=20
> On 03/01/2011 10:31 AM, Louis Rilling wrote:
> > On 28/02/11 17:10 -0500, Oren Laadan wrote:
> >>
> >>
> >> On 02/28/2011 10:09 AM, Louis Rilling wrote:
> >>> On 28/02/11  9:43 -0500, Oren Laadan wrote:
> >>>>
> >>>>
> >>>> On 02/26/2011 08:54 AM, Louis Rilling wrote:
> >>>>> On Fri, Feb 25, 2011 at 11:01:32AM -0800, Sukadev Bhattiprolu wrote:
> >>>>>> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> >>>>>> | On 24/02/11 23:55 -0800, Sukadev Bhattiprolu wrote:
> >>>>>> | >=20
> >>>>>> | > diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/r=
estart.c
> >>>>>> | > index b0ea8ec..8ecc052 100644
> >>>>>> | > --- a/kernel/checkpoint/restart.c
> >>>>>> | > +++ b/kernel/checkpoint/restart.c
> >>>>>> | > @@ -972,6 +972,7 @@ static int do_ghost_task(void)
> >>>>>> | >  	if (ret < 0)
> >>>>>> | >  		ckpt_err(ctx, ret, "ghost restart failed\n");
> >>>>>> | > =20
> >>>>>> | > +	current->exit_signal =3D -1;
> >>>>>> |=20
> >>>>>> | Setting ->exit_signal outside of tasklist_lock makes me nervous.=
 All other
> >>>>>> | places that change ->exit_signal hold write_lock_irq(&tasklist_l=
ock), and
> >>>>>> | eligibile_child() (for an instance of a reader being another tas=
k) holds
> >>>>>> | read_lock(&tasklist_lock). But maybe this does not matter for gh=
ost tasks.
> >>>>>> |=20
> >>>>>>
> >>>>>> Yes, an earlier version had the write_lock(&tasklist_lock). Will a=
dd it
> >>>>>> back.
> >>>>>>
> >>>>>> | >  	restore_debug_exit(ctx);
> >>>>>> | >  	ckpt_ctx_put(ctx);
> >>>>>> | >  	do_exit(0);
> >>>>>> | > @@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct=
 *tsk)
> >>>>>> | >  	/* restarting zombies will activate next task in restart */
> >>>>>> | >  	if (tsk->flags & PF_RESTARTING) {
> >>>>>> | >  		BUG_ON(ctx->active_pid =3D=3D -1);
> >>>>>> | > +
> >>>>>> | > +		/*
> >>>>>> | > +		 * if we are a "ghost" task, that was terminated by the
> >>>>>> | > +		 * container-init (from zap_pid_ns_processes()), we should
> >>>>>> | > +		 * wake up the parent since we are now a detached process.
> >>>>>> | > +		 */
> >>>>>> | > +		read_lock_irq(&tasklist_lock);
> >>>>>> |=20
> >>>>>> | read_lock() is enough. tasklist_lock is never taken for write fr=
om IRQs or
> >>>>>> | softIRQs.
> >>>>>> |=20
> >>>>>> | > +                if (tsk->exit_state =3D=3D EXIT_DEAD && !tsk-=
>parent->exit_state) {
> >>>>>> | > +                        ckpt_debug("[%d, %s]: exit_checkpoint=
(): notifying "
> >>>>>> | > +					"parent\n", tsk->pid, tsk->comm);
> >>>>>> | > +                        __wake_up_parent(tsk, tsk->parent);
> >>>>>> | > +                }
> >>>>>> | > +		read_unlock_irq(&tasklist_lock);
> >>>>>> |=20
> >>>>>> | Looking at this closer, I wonder if this wakeup logic should be =
called from
> >>>>>> | do_ghost_task(), right after setting ->exit_signal. This way the=
re would be no
> >>>>>> | need for a tricky condition to recognize ghost tasks, and (I thi=
nk) this is
> >>>>>> | closer to the other cases changing ->exit_signal (reparent_leade=
r() and
> >>>>>> | exit_notify()).
> >>>>>>
> >>>>>> Yes, we tried the following in the earlier version.=20
> >>>>>>
> >>>>>> void ghost_auto_reapable()
> >>>>>> {
> >>>>>>         write_lock(&tasklist_lock);
> >>>>>>         current->exit_signal =3D -1;
> >>>>>>         __wake_up_parent(current, current->parent);
> >>>>>>         write_unlock(&tasklist_lock);
> >>>>>> }
> >>>>>>
> >>>>>> And called this from do_ghost_task(). But with this, the parent co=
uld
> >>>>>> wake up, find that it still has an eligible child (the ghost) to w=
ait=20
> >>>>>> for, and go back to waiting before the ghost enters the EXIT_DEAD =
state.
> >>>>>> And so we would lose the wake up.
> >>>>>>
> >>>>>> (zap_pid_ns_processes() passes the __WALL so the ghost would be co=
nsidered
> >>>>>> an eligible child).
> >>>>>
> >>>>> I think I see now. The point is that ->exit_signal =3D -1 is only m=
eant to work
> >>>>> correctly for sub-threads, which the parent does not need to wait f=
or. IOW, the
> >>>>> notion of detached task is only implemented for sub-threads.
> >>>>>
> >>>>> IIUC, setting ->exit_signal to -1 is only used here to let exit_not=
ify() set
> >>>>> ->exit_state to EXIT_DEAD, right? Otherwise, setting ->exit_signal =
to 0 and
> >>>>> letting do_notify_parent() proceed for ghost tasks would have be su=
fficient I
> >>>>> guess (provided that the confusion between ghost tasks and zombies =
could be
> >>>>> easily avoided in do_notify_parent()).
> >>>>>
> >>>>> Then I agree that the proposed patch looks like a reasonably simple=
 approach.
> >>>>>
> >>>>> Thanks for the explanation,
> >>>>>
> >>>>
> >>>> Louis, Suka:
> >>>>
> >>>> One subtlety with the method is that if a process get reparented
> >>>> (for whatever reason) then the ->exit_signal field is reset to=20
> >>>> SIGCHLD. Fortunately, that should not affect us because our ghost
> >>>> tasks never become orphaned.
> >>>
> >>> AFAICS, this is not true for detached tasks: neither in reparent_lead=
er(), nor
> >>> in exit_notify(). Unless I missed another place?
> >>
> >> Doh.. you are totally right, I missed that.
> >> Sometime it feels really good to be wrong :)
> >=20
> > ;)
> >=20
> >>
> >>>
> >>>>
> >>>> However, I can't avoid thinking that maybe there is a better way=20
> >>>> to do this altogether ?
> >>>>
> >>>> The requirement is simple: ghost tasks are temporary tasks whose
> >>>> role is to keep certain pid's alive for the duration of the restart
> >>>> and then exit without a trace before the restarted tasks resume
> >>>> execution.
> >>>>
> >>>> The reason I opted for the ->exit_signal =3D -1 is because it makes
> >>>> sure that the parent need not explicitly collect the child ghost.
> >>>>
> >>>> If I had set it to 0, then it would not send a signal, but still
> >>>> would require a wait() to collect it (right ?).
> >>>
> >>> Right.
> >>>
> >>>>
> >>>> Can you think of a way to achieve this functionality without the=20
> >>>> subtleties that we have observed so far ?  even at the cost of a=20
> >>>> minor change to, say, wait() logic or what not ?
> >>>
> >>> I wonder if things would be easier by providing a mean to distinguish=
 ghost
> >>> tasks from truely restarted tasks in do_notify_parent().
> >>>
> >>> Assuming this, there might be a kernel-patch-free way, although I can=
't say if
> >>> this fits userspace restart constraints:
> >>>
> >>> Setting the signal handler of ghost tasks' parent to SIG_IGN, and ->e=
xit_signal
> >>
> >> Yes, I thought about it. But those parent are part of the restart,
> >> and changing their signal handlers will is tricky and will require
> >> complex sync logic at the end of restart to ensure that all tasks
> >> restore their handlers after the ghosts are gone and released, but
> >> before any task gets to userspace ... I don't want to go there.
> >=20
> > Yes, I can imagine well the added complexity in userspace.
> >=20
> >>
> >>> of ghost tasks to SIGCHLD, will make them autoreap. This requires tha=
t the
> >>> parent does not need to synchronize with other children until all gho=
st tasks
> >>> have exited, and that the parent remains alive too.
> >>>
> >>> So, why not adding some flag PF_RESTART_GHOST or TIF_RESTART_GHOST?
> >>
> >> Actually, we already have a way to distinguish them:
> >>
> >> 	if ((tsk->flags & PF_RESTARTING) && task_detached(tsk))
> >>
> >> One problem with this is that we only set exit_signal to -1 after
> >> the ghost was born, so if the parent is already waiting I think=20
> >> that will be racy, as per suka's comment above.
> >=20
> > Yes.
> >=20
> >>
> >> So looking at the code again, we could add one condition in exit.c
> >> at wait_consider_task(), after the test of p->exit_state =3D=3D EXIT_D=
EAD,
> >> to also test:
> >>
> >> inline static bool is_ghost_task(p)
> >> {
> >> 	return (p->flags & (PF_EXITING|PF_RESTARTING) =3D=3D
> >> 		PF_EXITING|PF_RESTARTING) && task_detached(p)
> >> }
> >>
> >> 	if (p->flags & is_ghost_task(p))
> >> 		return 0;
> >>
> >> Or something along the lines (e.g. used EXIT_ZOMBIE comparison instead
> >> of PF_EXITING). While requiring a kernel patch, it is relatively short,
> >> clean and easy to review.

EXIT_ZOMBIE comparison would not optimize much imho, since p->flags must be
checked anyway.

Nit1: I don't think that checking p->flags saves anything before calling
is_ghost_task().

Nit2: why would you like to check that PF_EXITING and PF_RESTARTING come
together? Is it to make sure that no "real" restarted thread will be skipped
this way?

> >=20
> > Adding the check in do_wait() is racy IMHO. What does prevent do_ghost_=
task()
> > from setting ->exit_signal =3D -1 after the parent sleeps in do_wait()?
>=20
> If we do it per your suggestion (and I also had suggested the
> same originally):
>=20
> >>>>>> void ghost_auto_reapable()
> >>>>>> {
> >>>>>>         write_lock(&tasklist_lock);
> >>>>>>         current->exit_signal =3D -1;
> >>>>>>         __wake_up_parent(current, current->parent);
> >>>>>>         write_unlock(&tasklist_lock);
> >>>>>> }
>=20
> then it should be safe, no ?

s/write_lock/write_lock_irq/ and I'll call it safe :)

>=20
> >=20
> > Otherwise, why not making ghost tasks simply sub-threads of the "parent=
"? They
> > would autoreap and nobody would wait or have to wait for them. I would =
feel so
> > much better if we had not to change ->exit_signal in do_ghost_task()...
>=20
> There are two types of ghosts:
>=20
> 1) A placeholder needed to ensure that some processes are orphaned
> correctly (while retaining their sid)
>=20
> 2) A placeholder needed to ensure that a certain pid exists during
> the restart (and can be, e.g. used by other processes as pgid).
>=20
> in both cases, a thread of the parent won't do what I need: in the
> first case, the child will be re-parented to another thread (leader?).

any other thread, possibly the leader. Right.

> And in the second, the pgid will be be usable as a pgid.

You probably meant that the pid would not be usable as a pgid (because not =
group
leader pid, possible session mismatch, etc.).

>=20
> But please keep throwing suggestions, we're making progress here...
>=20

(Just had a closer look to how pgids are restored)

Well, given that it's useful to have a consistent pgid/session for ghost ta=
sks,
and that it looks too difficult to rework the synchronization logic before
reaping ghost tasks (referring to the ->exit_signal =3D 0 + parent sighandl=
er =3D
SIG_IGN suggestion), I'm falling short of cleaner suggestions :)

The ghost_auto_reapable() thing above + wait_consider_task() change looks l=
ike
the cleanest solution so far. My only fear is that people could be reluctan=
t to
adding this (small?) overhead to do_wait() "only" for cr.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-29138-1299170064-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1vw1MACgkQVKcRuvQ9Q1S2iwCgx9QvVVLkn3kuI33Z/wtwHA0R
OgoAnRZAAGMxPNn6dd+LoRrK9qQj60Of
=TtDT
-----END PGP SIGNATURE-----

--=_bohort-29138-1299170064-0001-2--

--===============9125998293646476896==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============9125998293646476896==--
