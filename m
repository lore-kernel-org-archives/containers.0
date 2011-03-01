From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Tue, 1 Mar 2011 16:31:05 +0100
Message-ID: <20110301153105.GD4410@hawkmoon.kerlabs.com>
References: <20110225075552.GB24361@us.ibm.com>
	<20110225115507.GD3915@hawkmoon.kerlabs.com>
	<20110225190132.GA31300@us.ibm.com>
	<20110226135431.GA3251@kerlabs.com>
	<4D6BB499.7050602@cs.columbia.edu>
	<20110228150942.GD18970@hawkmoon.kerlabs.com>
	<4D6C1D58.5060400@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8602029376545819352=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D6C1D58.5060400-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

--===============8602029376545819352==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-18259-1298993399-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-18259-1298993399-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 28/02/11 17:10 -0500, Oren Laadan wrote:
>=20
>=20
> On 02/28/2011 10:09 AM, Louis Rilling wrote:
> > On 28/02/11  9:43 -0500, Oren Laadan wrote:
> >>
> >>
> >> On 02/26/2011 08:54 AM, Louis Rilling wrote:
> >>> On Fri, Feb 25, 2011 at 11:01:32AM -0800, Sukadev Bhattiprolu wrote:
> >>>> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> >>>> | On 24/02/11 23:55 -0800, Sukadev Bhattiprolu wrote:
> >>>> | >=20
> >>>> | > diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/res=
tart.c
> >>>> | > index b0ea8ec..8ecc052 100644
> >>>> | > --- a/kernel/checkpoint/restart.c
> >>>> | > +++ b/kernel/checkpoint/restart.c
> >>>> | > @@ -972,6 +972,7 @@ static int do_ghost_task(void)
> >>>> | >  	if (ret < 0)
> >>>> | >  		ckpt_err(ctx, ret, "ghost restart failed\n");
> >>>> | > =20
> >>>> | > +	current->exit_signal =3D -1;
> >>>> |=20
> >>>> | Setting ->exit_signal outside of tasklist_lock makes me nervous. A=
ll other
> >>>> | places that change ->exit_signal hold write_lock_irq(&tasklist_loc=
k), and
> >>>> | eligibile_child() (for an instance of a reader being another task)=
 holds
> >>>> | read_lock(&tasklist_lock). But maybe this does not matter for ghos=
t tasks.
> >>>> |=20
> >>>>
> >>>> Yes, an earlier version had the write_lock(&tasklist_lock). Will add=
 it
> >>>> back.
> >>>>
> >>>> | >  	restore_debug_exit(ctx);
> >>>> | >  	ckpt_ctx_put(ctx);
> >>>> | >  	do_exit(0);
> >>>> | > @@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct *=
tsk)
> >>>> | >  	/* restarting zombies will activate next task in restart */
> >>>> | >  	if (tsk->flags & PF_RESTARTING) {
> >>>> | >  		BUG_ON(ctx->active_pid =3D=3D -1);
> >>>> | > +
> >>>> | > +		/*
> >>>> | > +		 * if we are a "ghost" task, that was terminated by the
> >>>> | > +		 * container-init (from zap_pid_ns_processes()), we should
> >>>> | > +		 * wake up the parent since we are now a detached process.
> >>>> | > +		 */
> >>>> | > +		read_lock_irq(&tasklist_lock);
> >>>> |=20
> >>>> | read_lock() is enough. tasklist_lock is never taken for write from=
 IRQs or
> >>>> | softIRQs.
> >>>> |=20
> >>>> | > +                if (tsk->exit_state =3D=3D EXIT_DEAD && !tsk->p=
arent->exit_state) {
> >>>> | > +                        ckpt_debug("[%d, %s]: exit_checkpoint()=
: notifying "
> >>>> | > +					"parent\n", tsk->pid, tsk->comm);
> >>>> | > +                        __wake_up_parent(tsk, tsk->parent);
> >>>> | > +                }
> >>>> | > +		read_unlock_irq(&tasklist_lock);
> >>>> |=20
> >>>> | Looking at this closer, I wonder if this wakeup logic should be ca=
lled from
> >>>> | do_ghost_task(), right after setting ->exit_signal. This way there=
 would be no
> >>>> | need for a tricky condition to recognize ghost tasks, and (I think=
) this is
> >>>> | closer to the other cases changing ->exit_signal (reparent_leader(=
) and
> >>>> | exit_notify()).
> >>>>
> >>>> Yes, we tried the following in the earlier version.=20
> >>>>
> >>>> void ghost_auto_reapable()
> >>>> {
> >>>>         write_lock(&tasklist_lock);
> >>>>         current->exit_signal =3D -1;
> >>>>         __wake_up_parent(current, current->parent);
> >>>>         write_unlock(&tasklist_lock);
> >>>> }
> >>>>
> >>>> And called this from do_ghost_task(). But with this, the parent could
> >>>> wake up, find that it still has an eligible child (the ghost) to wai=
t=20
> >>>> for, and go back to waiting before the ghost enters the EXIT_DEAD st=
ate.
> >>>> And so we would lose the wake up.
> >>>>
> >>>> (zap_pid_ns_processes() passes the __WALL so the ghost would be cons=
idered
> >>>> an eligible child).
> >>>
> >>> I think I see now. The point is that ->exit_signal =3D -1 is only mea=
nt to work
> >>> correctly for sub-threads, which the parent does not need to wait for=
=2E IOW, the
> >>> notion of detached task is only implemented for sub-threads.
> >>>
> >>> IIUC, setting ->exit_signal to -1 is only used here to let exit_notif=
y() set
> >>> ->exit_state to EXIT_DEAD, right? Otherwise, setting ->exit_signal to=
 0 and
> >>> letting do_notify_parent() proceed for ghost tasks would have be suff=
icient I
> >>> guess (provided that the confusion between ghost tasks and zombies co=
uld be
> >>> easily avoided in do_notify_parent()).
> >>>
> >>> Then I agree that the proposed patch looks like a reasonably simple a=
pproach.
> >>>
> >>> Thanks for the explanation,
> >>>
> >>
> >> Louis, Suka:
> >>
> >> One subtlety with the method is that if a process get reparented
> >> (for whatever reason) then the ->exit_signal field is reset to=20
> >> SIGCHLD. Fortunately, that should not affect us because our ghost
> >> tasks never become orphaned.
> >=20
> > AFAICS, this is not true for detached tasks: neither in reparent_leader=
(), nor
> > in exit_notify(). Unless I missed another place?
>=20
> Doh.. you are totally right, I missed that.
> Sometime it feels really good to be wrong :)

;)

>=20
> >=20
> >>
> >> However, I can't avoid thinking that maybe there is a better way=20
> >> to do this altogether ?
> >>
> >> The requirement is simple: ghost tasks are temporary tasks whose
> >> role is to keep certain pid's alive for the duration of the restart
> >> and then exit without a trace before the restarted tasks resume
> >> execution.
> >>
> >> The reason I opted for the ->exit_signal =3D -1 is because it makes
> >> sure that the parent need not explicitly collect the child ghost.
> >>
> >> If I had set it to 0, then it would not send a signal, but still
> >> would require a wait() to collect it (right ?).
> >=20
> > Right.
> >=20
> >>
> >> Can you think of a way to achieve this functionality without the=20
> >> subtleties that we have observed so far ?  even at the cost of a=20
> >> minor change to, say, wait() logic or what not ?
> >=20
> > I wonder if things would be easier by providing a mean to distinguish g=
host
> > tasks from truely restarted tasks in do_notify_parent().
> >=20
> > Assuming this, there might be a kernel-patch-free way, although I can't=
 say if
> > this fits userspace restart constraints:
> >=20
> > Setting the signal handler of ghost tasks' parent to SIG_IGN, and ->exi=
t_signal
>=20
> Yes, I thought about it. But those parent are part of the restart,
> and changing their signal handlers will is tricky and will require
> complex sync logic at the end of restart to ensure that all tasks
> restore their handlers after the ghosts are gone and released, but
> before any task gets to userspace ... I don't want to go there.

Yes, I can imagine well the added complexity in userspace.

>=20
> > of ghost tasks to SIGCHLD, will make them autoreap. This requires that =
the
> > parent does not need to synchronize with other children until all ghost=
 tasks
> > have exited, and that the parent remains alive too.
> >=20
> > So, why not adding some flag PF_RESTART_GHOST or TIF_RESTART_GHOST?
>=20
> Actually, we already have a way to distinguish them:
>=20
> 	if ((tsk->flags & PF_RESTARTING) && task_detached(tsk))
>=20
> One problem with this is that we only set exit_signal to -1 after
> the ghost was born, so if the parent is already waiting I think=20
> that will be racy, as per suka's comment above.

Yes.

>=20
> So looking at the code again, we could add one condition in exit.c
> at wait_consider_task(), after the test of p->exit_state =3D=3D EXIT_DEAD,
> to also test:
>=20
> inline static bool is_ghost_task(p)
> {
> 	return (p->flags & (PF_EXITING|PF_RESTARTING) =3D=3D
> 		PF_EXITING|PF_RESTARTING) && task_detached(p)
> }
>=20
> 	if (p->flags & is_ghost_task(p))
> 		return 0;
>=20
> Or something along the lines (e.g. used EXIT_ZOMBIE comparison instead
> of PF_EXITING). While requiring a kernel patch, it is relatively short,
> clean and easy to review.

Adding the check in do_wait() is racy IMHO. What does prevent do_ghost_task=
()
=66rom setting ->exit_signal =3D -1 after the parent sleeps in do_wait()?

Otherwise, why not making ghost tasks simply sub-threads of the "parent"? T=
hey
would autoreap and nobody would wait or have to wait for them. I would feel=
 so
much better if we had not to change ->exit_signal in do_ghost_task()...

Opinion?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-18259-1298993399-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1tETkACgkQVKcRuvQ9Q1TNdACg1L9Sf2C8pRPDeZn/i/g2VU/Y
PqYAoNCxynj114U6LQo/hVirVCQ6j/sQ
=Y3u2
-----END PGP SIGNATURE-----

--=_bohort-18259-1298993399-0001-2--

--===============8602029376545819352==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8602029376545819352==--
