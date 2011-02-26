From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Sat, 26 Feb 2011 14:54:32 +0100
Message-ID: <20110226135431.GA3251@kerlabs.com>
References: <20110225075552.GB24361@us.ibm.com>
	<20110225115507.GD3915@hawkmoon.kerlabs.com>
	<20110225190132.GA31300@us.ibm.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6816390398429140517=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110225190132.GA31300-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============6816390398429140517==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-32692-1298728414-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-32692-1298728414-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 25, 2011 at 11:01:32AM -0800, Sukadev Bhattiprolu wrote:
> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> | On 24/02/11 23:55 -0800, Sukadev Bhattiprolu wrote:
> | >=20
> | > diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
> | > index b0ea8ec..8ecc052 100644
> | > --- a/kernel/checkpoint/restart.c
> | > +++ b/kernel/checkpoint/restart.c
> | > @@ -972,6 +972,7 @@ static int do_ghost_task(void)
> | >  	if (ret < 0)
> | >  		ckpt_err(ctx, ret, "ghost restart failed\n");
> | > =20
> | > +	current->exit_signal =3D -1;
> |=20
> | Setting ->exit_signal outside of tasklist_lock makes me nervous. All ot=
her
> | places that change ->exit_signal hold write_lock_irq(&tasklist_lock), a=
nd
> | eligibile_child() (for an instance of a reader being another task) holds
> | read_lock(&tasklist_lock). But maybe this does not matter for ghost tas=
ks.
> |=20
>=20
> Yes, an earlier version had the write_lock(&tasklist_lock). Will add it
> back.
>=20
> | >  	restore_debug_exit(ctx);
> | >  	ckpt_ctx_put(ctx);
> | >  	do_exit(0);
> | > @@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct *tsk)
> | >  	/* restarting zombies will activate next task in restart */
> | >  	if (tsk->flags & PF_RESTARTING) {
> | >  		BUG_ON(ctx->active_pid =3D=3D -1);
> | > +
> | > +		/*
> | > +		 * if we are a "ghost" task, that was terminated by the
> | > +		 * container-init (from zap_pid_ns_processes()), we should
> | > +		 * wake up the parent since we are now a detached process.
> | > +		 */
> | > +		read_lock_irq(&tasklist_lock);
> |=20
> | read_lock() is enough. tasklist_lock is never taken for write from IRQs=
 or
> | softIRQs.
> |=20
> | > +                if (tsk->exit_state =3D=3D EXIT_DEAD && !tsk->parent=
->exit_state) {
> | > +                        ckpt_debug("[%d, %s]: exit_checkpoint(): not=
ifying "
> | > +					"parent\n", tsk->pid, tsk->comm);
> | > +                        __wake_up_parent(tsk, tsk->parent);
> | > +                }
> | > +		read_unlock_irq(&tasklist_lock);
> |=20
> | Looking at this closer, I wonder if this wakeup logic should be called =
=66rom
> | do_ghost_task(), right after setting ->exit_signal. This way there woul=
d be no
> | need for a tricky condition to recognize ghost tasks, and (I think) thi=
s is
> | closer to the other cases changing ->exit_signal (reparent_leader() and
> | exit_notify()).
>=20
> Yes, we tried the following in the earlier version.=20
>=20
> void ghost_auto_reapable()
> {
>         write_lock(&tasklist_lock);
>         current->exit_signal =3D -1;
>         __wake_up_parent(current, current->parent);
>         write_unlock(&tasklist_lock);
> }
>=20
> And called this from do_ghost_task(). But with this, the parent could
> wake up, find that it still has an eligible child (the ghost) to wait=20
> for, and go back to waiting before the ghost enters the EXIT_DEAD state.
> And so we would lose the wake up.
>=20
> (zap_pid_ns_processes() passes the __WALL so the ghost would be considered
> an eligible child).

I think I see now. The point is that ->exit_signal =3D -1 is only meant to =
work
correctly for sub-threads, which the parent does not need to wait for. IOW,=
 the
notion of detached task is only implemented for sub-threads.

IIUC, setting ->exit_signal to -1 is only used here to let exit_notify() set
->exit_state to EXIT_DEAD, right? Otherwise, setting ->exit_signal to 0 and
letting do_notify_parent() proceed for ghost tasks would have be sufficient=
 I
guess (provided that the confusion between ghost tasks and zombies could be
easily avoided in do_notify_parent()).

Then I agree that the proposed patch looks like a reasonably simple approac=
h.

Thanks for the explanation,

Louis

>=20
> Sukadev
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-32692-1298728414-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk1pBhcACgkQVKcRuvQ9Q1SgyQCgmiHdKwq6llA9O0I2OqedLbYy
XpcAoJPsr2UqRLcw3UdcF7e7Jy9IqVSs
=bVuE
-----END PGP SIGNATURE-----

--=_bohort-32692-1298728414-0001-2--

--===============6816390398429140517==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6816390398429140517==--
