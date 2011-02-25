From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Fri, 25 Feb 2011 12:55:07 +0100
Message-ID: <20110225115507.GD3915@hawkmoon.kerlabs.com>
References: <20110225075552.GB24361@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0274319952093344885=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110225075552.GB24361-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

--===============0274319952093344885==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-14638-1298634842-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-14638-1298634842-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 24/02/11 23:55 -0800, Sukadev Bhattiprolu wrote:
>=20
> From b32a8c440687955975180e909620eba50cb146c3 Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 22 Feb 2011 10:44:55 -0800
> Subject: [PATCH 1/1] Fix ghost task bug
>=20
> Ghost tasks used to be marked as "detached" in do_ghost_task() but
> this resulted in a crash which was fixed as discussed in:
> https://lists.linux-foundation.org/pipermail/containers/2010-December/026=
076.html.
>=20
> But that fix incorrectly attempted to mark a task as detached from user
> space. It is not possible to "detach" a task from user space, which
> means we must detach the thread in the kernel while still avoiding
> the above crash.
>=20
> The original crash occured because the container-init did not wait for
> the detached children. When the detached children exited, they would
> access a freed proc_mnt. Eric Biederman fixed this crash as discussed in
> the above link.
>=20
> While Eric's patch fixed the crash it could still leave the container
> init hanging indefinitely due to the following race:
>=20
> container-int:				ghost task
> -----------------                      ------------
> 					do_ghost_task()
>=20
> zap_pid_ns_processes()
> - send SIGKILL
> - do_wait()
>    - at least one child exists
>    - so wait for child to exit
>    					wake up for the SIGKILL
> 					set ->exit_signal =3D -1
> 					exit without notifying parent
>=20
> This leaves the container init waiting indefinitely.
>=20
> To fix this hang, we have the children of container-init issue an extra w=
ake
> up call in exit_checkpoint(). Note that in exit_checkpoint() we do not kn=
ow
> if it is the ghost task that is exiting. Since this wake up applies to any
> other task, we should further make sure that the parent is itself not exi=
ting
> (which could cause __wake_up_parent() to access invalid pointers in the
> parent's task structure).
>=20
> See this thread for more discussion:
>=20
> https://lists.linux-foundation.org/pipermail/containers/2011-February/026=
459.html
>=20
> Signed-off-by: Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org)
> Cc: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
> ---
>  kernel/checkpoint/restart.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
>=20
> diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
> index b0ea8ec..8ecc052 100644
> --- a/kernel/checkpoint/restart.c
> +++ b/kernel/checkpoint/restart.c
> @@ -972,6 +972,7 @@ static int do_ghost_task(void)
>  	if (ret < 0)
>  		ckpt_err(ctx, ret, "ghost restart failed\n");
> =20
> +	current->exit_signal =3D -1;

Setting ->exit_signal outside of tasklist_lock makes me nervous. All other
places that change ->exit_signal hold write_lock_irq(&tasklist_lock), and
eligibile_child() (for an instance of a reader being another task) holds
read_lock(&tasklist_lock). But maybe this does not matter for ghost tasks.

>  	restore_debug_exit(ctx);
>  	ckpt_ctx_put(ctx);
>  	do_exit(0);
> @@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct *tsk)
>  	/* restarting zombies will activate next task in restart */
>  	if (tsk->flags & PF_RESTARTING) {
>  		BUG_ON(ctx->active_pid =3D=3D -1);
> +
> +		/*
> +		 * if we are a "ghost" task, that was terminated by the
> +		 * container-init (from zap_pid_ns_processes()), we should
> +		 * wake up the parent since we are now a detached process.
> +		 */
> +		read_lock_irq(&tasklist_lock);

read_lock() is enough. tasklist_lock is never taken for write from IRQs or
softIRQs.

> +                if (tsk->exit_state =3D=3D EXIT_DEAD && !tsk->parent->ex=
it_state) {
> +                        ckpt_debug("[%d, %s]: exit_checkpoint(): notifyi=
ng "
> +					"parent\n", tsk->pid, tsk->comm);
> +                        __wake_up_parent(tsk, tsk->parent);
> +                }
> +		read_unlock_irq(&tasklist_lock);

Looking at this closer, I wonder if this wakeup logic should be called from
do_ghost_task(), right after setting ->exit_signal. This way there would be=
 no
need for a tricky condition to recognize ghost tasks, and (I think) this is
closer to the other cases changing ->exit_signal (reparent_leader() and
exit_notify()).

Opinions?

Thanks,

Louis

> +
>  		restore_task_done(ctx);
> +
>  	}
> =20
>  	ckpt_ctx_put(ctx);
> --=20
> 1.6.6.1
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-14638-1298634842-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk1nmJsACgkQVKcRuvQ9Q1TWDQCeMf5d1Mk9BsREjA2nD7n7ZjC3
3UYAninzitTws+eO623nYGy6FkiGS0x5
=N6Lh
-----END PGP SIGNATURE-----

--=_bohort-14638-1298634842-0001-2--

--===============0274319952093344885==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0274319952093344885==--
