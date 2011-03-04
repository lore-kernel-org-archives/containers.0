From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Fri, 4 Mar 2011 18:29:14 +0100
Message-ID: <20110304172914.GE3543@hawkmoon.kerlabs.com>
References: <20110225115507.GD3915@hawkmoon.kerlabs.com>
	<20110225190132.GA31300@us.ibm.com>
	<20110226135431.GA3251@kerlabs.com>
	<4D6BB499.7050602@cs.columbia.edu>
	<20110228150942.GD18970@hawkmoon.kerlabs.com>
	<4D6C1D58.5060400@cs.columbia.edu>
	<20110301153105.GD4410@hawkmoon.kerlabs.com>
	<4D6FB5D9.8010002@cs.columbia.edu>
	<20110303163531.GO21429@hawkmoon.kerlabs.com>
	<4D710E37.8000109@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8132960851953137301=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D710E37.8000109-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

--===============8132960851953137301==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-17544-1299259687-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-17544-1299259687-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/03/11 11:07 -0500, Oren Laadan wrote:
> On 03/03/2011 11:35 AM, Louis Rilling wrote:
> > On 03/03/11 10:38 -0500, Oren Laadan wrote:
> >> On 03/01/2011 10:31 AM, Louis Rilling wrote:
> >>> On 28/02/11 17:10 -0500, Oren Laadan wrote:
> >>>> So looking at the code again, we could add one condition in exit.c
> >>>> at wait_consider_task(), after the test of p->exit_state =3D=3D EXIT=
_DEAD,
> >>>> to also test:
> >>>>
> >>>> inline static bool is_ghost_task(p)
> >>>> {
> >>>> 	return (p->flags & (PF_EXITING|PF_RESTARTING) =3D=3D
> >>>> 		PF_EXITING|PF_RESTARTING) && task_detached(p)
> >>>> }
> >>>>
> >>>> 	if (p->flags & is_ghost_task(p))
> >>>> 		return 0;
> >>>>
> >>>> Or something along the lines (e.g. used EXIT_ZOMBIE comparison inste=
ad
> >>>> of PF_EXITING). While requiring a kernel patch, it is relatively sho=
rt,
> >>>> clean and easy to review.
> >=20
> > EXIT_ZOMBIE comparison would not optimize much imho, since p->flags mus=
t be
> > checked anyway.
> >=20
> > Nit1: I don't think that checking p->flags saves anything before calling
> > is_ghost_task().
>=20
> Hmm.. right -
> That's a leftover from before I decided to introduce is_ghost_task()
>=20
> >=20
> > Nit2: why would you like to check that PF_EXITING and PF_RESTARTING come
> > together? Is it to make sure that no "real" restarted thread will be sk=
ipped
> > this way?
>=20
> If wait() is called to get the state of stopped children, and for
> whatever reason the ghost is stopped or being ptraced (we should
> probably prevent that... but ok) - testing for the exiting/zombie=20
> condition is an extra safety measure: only skip this task when it
> is actually exiting.

I don't see how a ghost task could be stopped or ptraced, since it calls
do_exit() right after becoming detached, and thus identifiable as a ghost.
Unless it gets ptraced right before calling sys_restart()? Even in that cas=
e,
it's not reapable by ptrace since it's not in stopped state. OTOH, it may s=
till
be reaped in wait_task_continued() (see below).

>=20
> Do you not think it's needed ?

Not sure. As far as I can see, other restarting (with PF_RESTARTING) and
detached tasks can only be sub-threads, and are mostly not reapable in any =
way
as long as PF_RESTARTING is set. They can surely be reaped neither by
wait_task_zombie(), nor by wait_task_stopped(). The only possibility I see =
is by
wait_task_continued(), because a previous "wakeup from stopped" has not been
consumed before the checkpoint.

But, and I think that this is a good reason to check PF_EXITING (or
->exit_state), if threads are skipped this way, then wait() might incorrect=
ly
return -ECHILD instead of sleeping.

Wait. Even with this, after ->exit_signal is set to -1, and before PF_EXITI=
NG is
set, wait_consider_task() can still consider the ghost as potentially reapa=
ble
in the future. Deadlock again.

In fact, it's probably much saner to have something atomic, like:

	write_lock_irq(&tasklist_lock);
	p->flags |=3D PF_EXITING;
	p->exit_signal =3D -1;
	__wake_up_parent(p, p->parent);
	write_unlock_irq(&tasklist_lock);

Unfortunately this is not accepted by do_exit(). So two kinds of solutions:
either set a new flag =E0 la PF_RESTART_GHOST, and only check for this flag=
 in
wait_consider_task(),
or somewhere in do_exit() (latest in exit_notify()), have
another mean to recognize ghost tasks, and do the ->exit_signal =3D -1 +
__wake_up_parent() there.

What's your opinion?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-17544-1299259687-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1xIWoACgkQVKcRuvQ9Q1TK/QCfVFGiTNEXjE6rU0uo0+X1utms
k1MAnAgo6zq7VLnQkoOUl7lAoQGiJIYU
=1U7b
-----END PGP SIGNATURE-----

--=_bohort-17544-1299259687-0001-2--

--===============8132960851953137301==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8132960851953137301==--
