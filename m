From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH][cr]: Fix ghost task bug
Date: Mon, 28 Mar 2011 17:24:58 +0200
Message-ID: <20110328152454.GB21527@hawkmoon.kerlabs.com>
References: <20110228150942.GD18970@hawkmoon.kerlabs.com>
	<4D6C1D58.5060400@cs.columbia.edu>
	<20110301153105.GD4410@hawkmoon.kerlabs.com>
	<4D6FB5D9.8010002@cs.columbia.edu>
	<20110303163531.GO21429@hawkmoon.kerlabs.com>
	<4D710E37.8000109@cs.columbia.edu>
	<20110304172914.GE3543@hawkmoon.kerlabs.com>
	<4D8D4BE9.8010605@cs.columbia.edu>
	<20110326160607.GA18492@hawkmoon.kerlabs.com>
	<4D8EAC5A.2080604@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5047731212045027633=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D8EAC5A.2080604-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

--===============5047731212045027633==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-20786-1301325830-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-20786-1301325830-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 26/03/11 23:17 -0400, Oren Laadan wrote:
>=20
> On 03/26/2011 12:06 PM, Louis Rilling wrote:
> > On 25/03/11 22:14 -0400, Oren Laadan wrote:
> >>
> >>
> >> On 03/04/2011 12:29 PM, Louis Rilling wrote:
> >>> On 04/03/11 11:07 -0500, Oren Laadan wrote:
> >>>> On 03/03/2011 11:35 AM, Louis Rilling wrote:
> >>>>> On 03/03/11 10:38 -0500, Oren Laadan wrote:
> >>>>>> On 03/01/2011 10:31 AM, Louis Rilling wrote:
> >>>>>>> On 28/02/11 17:10 -0500, Oren Laadan wrote:
> >>>>>>>> So looking at the code again, we could add one condition in exit=
=2Ec
> >>>>>>>> at wait_consider_task(), after the test of p->exit_state =3D=3D =
EXIT_DEAD,
> >>>>>>>> to also test:
> >>>>>>>>
> >>>>>>>> inline static bool is_ghost_task(p)
> >>>>>>>> {
> >>>>>>>> 	return (p->flags & (PF_EXITING|PF_RESTARTING) =3D=3D
> >>>>>>>> 		PF_EXITING|PF_RESTARTING) && task_detached(p)
> >>>>>>>> }
> >>>>>>>>
> >>>>>>>> 	if (p->flags & is_ghost_task(p))
> >>>>>>>> 		return 0;
> >>>>>>>>
> >>>>>>>> Or something along the lines (e.g. used EXIT_ZOMBIE comparison i=
nstead
> >>>>>>>> of PF_EXITING). While requiring a kernel patch, it is relatively=
 short,
> >>>>>>>> clean and easy to review.
> >>>>>
> >>>>> EXIT_ZOMBIE comparison would not optimize much imho, since p->flags=
 must be
> >>>>> checked anyway.
> >>>>>
> >>>>> Nit1: I don't think that checking p->flags saves anything before ca=
lling
> >>>>> is_ghost_task().
> >>>>
> >>>> Hmm.. right -
> >>>> That's a leftover from before I decided to introduce is_ghost_task()
> >>>>
> >>>>>
> >>>>> Nit2: why would you like to check that PF_EXITING and PF_RESTARTING=
 come
> >>>>> together? Is it to make sure that no "real" restarted thread will b=
e skipped
> >>>>> this way?
> >>>>
> >>>> If wait() is called to get the state of stopped children, and for
> >>>> whatever reason the ghost is stopped or being ptraced (we should
> >>>> probably prevent that... but ok) - testing for the exiting/zombie=20
> >>>> condition is an extra safety measure: only skip this task when it
> >>>> is actually exiting.
> >>>
> >>> I don't see how a ghost task could be stopped or ptraced, since it ca=
lls
> >>> do_exit() right after becoming detached, and thus identifiable as a g=
host.
> >>> Unless it gets ptraced right before calling sys_restart()? Even in th=
at case,
> >>> it's not reapable by ptrace since it's not in stopped state. OTOH, it=
 may still
> >>> be reaped in wait_task_continued() (see below).
> >>>
> >>>>
> >>>> Do you not think it's needed ?
> >>>
> >>> Not sure. As far as I can see, other restarting (with PF_RESTARTING) =
and
> >>> detached tasks can only be sub-threads, and are mostly not reapable i=
n any way
> >>> as long as PF_RESTARTING is set. They can surely be reaped neither by
> >>> wait_task_zombie(), nor by wait_task_stopped(). The only possibility =
I see is by
> >>> wait_task_continued(), because a previous "wakeup from stopped" has n=
ot been
> >>> consumed before the checkpoint.
> >>>
> >>> But, and I think that this is a good reason to check PF_EXITING (or
> >>> ->exit_state), if threads are skipped this way, then wait() might inc=
orrectly
> >>> return -ECHILD instead of sleeping.
> >>>
> >>> Wait. Even with this, after ->exit_signal is set to -1, and before PF=
_EXITING is
> >>> set, wait_consider_task() can still consider the ghost as potentially=
 reapable
> >>> in the future. Deadlock again.
> >>>
> >>> In fact, it's probably much saner to have something atomic, like:
> >>>
> >>> 	write_lock_irq(&tasklist_lock);
> >>> 	p->flags |=3D PF_EXITING;
> >>> 	p->exit_signal =3D -1;
> >>> 	__wake_up_parent(p, p->parent);
> >>> 	write_unlock_irq(&tasklist_lock);
> >>>
> >>> Unfortunately this is not accepted by do_exit(). So two kinds of solu=
tions:
> >>> either set a new flag =E0 la PF_RESTART_GHOST, and only check for thi=
s flag in
> >>> wait_consider_task(),
> >>> or somewhere in do_exit() (latest in exit_notify()), have
> >>> another mean to recognize ghost tasks, and do the ->exit_signal =3D -=
1 +
> >>> __wake_up_parent() there.
> >>>
> >>> What's your opinion?
> >>>
> >>
> >> Doing it in wait_consider_task() may be a problem since we only mark
> >> a task as ghost after it has lived for a while, so wait() would have
> >> already considered it a valid child to wait for.
> >>
> >> If I had to choose, then I'd do the snippet you suggest above - and
> >> in particular where PF_EXITING is already set, which is exit_signals().
> >>
> >> Adding a means to recognize ghost tasks is simple: we ran out of=20
> >> task->flags, but we can add a c/r related field to hold such a flag
> >> (we already add one field to the task_struct).
> >>
> >> Do you think that will do it ?
> >=20
> > Yup, any way to have a flag protected by tasklist_lock would be ok. For
> > instance, use some bit near ->did_exec. IMHO of course :)
>=20
> Good idea.
> How about this patch:
>=20
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index e42bf29..5a08d49 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1267,6 +1267,9 @@ struct task_struct {
>  	unsigned in_execve:1;	/* Tell the LSMs that the process is doing an
>  				 * execve */
>  	unsigned in_iowait:1;
> +#ifdef CONFIG_CHECKPOINT
> +	unsigned ckpt_ghost:1;  /* ghost task in c/r - auto-reap */
> +#endif
> =20
> =20
>  	/* Revert to default priority/policy when forking */
> diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
> index 01da67f..880d456 100644
> --- a/kernel/checkpoint/restart.c
> +++ b/kernel/checkpoint/restart.c
> @@ -971,6 +971,8 @@ static int do_ghost_task(void)
>  	restore_debug_error(ctx, ret);
>  	if (ret < 0)
>  		ckpt_err(ctx, ret, "ghost restart failed\n");
> +	else
> +		current->ckpt_ghost =3D 1;
> =20
>  	restore_debug_exit(ctx);
>  	ckpt_ctx_put(ctx);
> diff --git a/kernel/signal.c b/kernel/signal.c
> index b1e6a31..8bc7c9e 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -2017,6 +2017,13 @@ void exit_signals(struct task_struct *tsk)
>  	struct task_struct *t;
> =20
>  	if (thread_group_empty(tsk) || signal_group_exit(tsk->signal)) {
> +		if (tsk->ckpt_ghost) {
> +			write_lock_irq(&tasklist_lock);
> +			p->flags |=3D PF_EXITING;
> +			p->exit_signal =3D -1;
> +			__wake_up_parent(p, p->parent);
> +			write_unlock_irq(&tasklist_lock);
> +		}
>  		tsk->flags |=3D PF_EXITING;
>  		return;

This alone is not enough. I was not clear enough and did not pay enough
attention to your suggestion, I'm afraid :)
wait_consider_task() can still wait for such a child, with __WALL or __WCLO=
NE.
So wait_consider_task() must check ->ckpt_ghost, and __wake_up_parent() mus=
t be
done when setting ->ckpt_ghost. Then PF_EXITING need no particular handling=
, and
all can be done in do_ghost_task().

In other words, something like this could do it (hope it's not an issue to =
set
->ckpt_ghost before calling restore_debug_error()):


diff --git a/include/linux/sched.h b/include/linux/sched.h
index e42bf29..5a08d49 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1267,6 +1267,9 @@ struct task_struct {
 	unsigned in_execve:1;	/* Tell the LSMs that the process is doing an
 				 * execve */
 	unsigned in_iowait:1;
+#ifdef CONFIG_CHECKPOINT
+	unsigned ckpt_ghost:1;  /* ghost task in c/r - auto-reap */
+#endif
=20
=20
 	/* Revert to default priority/policy when forking */
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 25e3b6d..e7b66f5 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -1307,6 +1307,17 @@ static int do_ghost_task(void)
 	ret =3D wait_event_interruptible(ctx->ghostq,
 				       all_tasks_activated(ctx) ||
 				       ckpt_test_error(ctx));
+	if (ret < 0)
+		goto out;
+
+	write_lock_irq(&tasklist_lock);
+	/* Tell parent not to wait for us. It may be already waiting though. */
+	current->ckpt_ghost =3D 1;
+	__wake_up_parent(current, current->parent);
+	/* Re-use sub-threads' auto-reap logic */
+	current->exit_signal =3D -1;
+	write_unlock_irq(&tasklist_lock);
+
  out:
 	restore_debug_error(ctx, ret);
 	if (ret < 0)
diff --git a/kernel/exit.c b/kernel/exit.c
index 6d81911..75cab68 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1554,6 +1554,11 @@ static int wait_consider_task(struct wait_opts *wo, =
int ptrace,
 	if (p->exit_state =3D=3D EXIT_DEAD)
 		return 0;
=20
+#ifdef CONFIG_CHECKPOINT
+	if (p->ckpt_ghost)
+		return 0;
+#endif
+
 	/*
 	 * We don't reap group leaders with subthreads.
 	 */

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-20786-1301325830-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk2QqEYACgkQVKcRuvQ9Q1TDVACgt6swZBzfpAc4RXCzFsTshZdV
M4UAoNExYeC+vzMQ+rFeqriDmPEoOOLU
=ctIK
-----END PGP SIGNATURE-----

--=_bohort-20786-1301325830-0001-2--

--===============5047731212045027633==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5047731212045027633==--
