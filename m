From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/4] c/r: support for real/virt/prof itimers (v2)
Date: Tue, 4 Aug 2009 16:17:46 +0200
Message-ID: <20090804141746.GQ29252@hawkmoon.kerlabs.com>
References: <1249376956-27555-1-git-send-email-orenl@librato.com>
	<1249376956-27555-5-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3836243020365800066=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249376956-27555-5-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============3836243020365800066==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-28427-1249395433-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-28427-1249395433-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Oren,

On 04/08/09  5:09 -0400, Oren Laadan wrote:
> This patch adds support for real/virt/prof itimers.
> Expiry and the interval values are both saved in nanoseconds.
>=20
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  checkpoint/signal.c            |   72 ++++++++++++++++++++++++++++++++++=
++++++
>  include/linux/checkpoint_hdr.h |    6 +++
>  2 files changed, 78 insertions(+), 0 deletions(-)
>=20
> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
> index c9da06b..18b3e2d 100644
> --- a/checkpoint/signal.c
> +++ b/checkpoint/signal.c
> @@ -15,6 +15,7 @@
>  #include <linux/signal.h>
>  #include <linux/errno.h>
>  #include <linux/resource.h>
> +#include <linux/timer.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> =20
> @@ -264,6 +265,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, st=
ruct task_struct *t)
>  	struct signal_struct *signal;
>  	struct sigpending shared_pending;
>  	struct rlimit *rlim;
> +	struct timeval tval;
>  	unsigned long flags;
>  	int i, ret;
> =20
> @@ -299,6 +301,49 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, s=
truct task_struct *t)
>  		h->rlim[i].rlim_cur =3D rlim[i].rlim_cur;
>  		h->rlim[i].rlim_max =3D rlim[i].rlim_max;
>  	}
> +
> +	/* real/virt/prof itimers */
> +	h->it_real_incr =3D ktime_to_ns(signal->it_real_incr);
> +	/*
> +	 * (a) If the timer is now active (did not expire), compute
> +	 * the time delta.
> +	 * (b) If the timer expired, and delivered the signal already,
> +	 * then set the expire (value) to the interval
> +	 * (c) If the timer expired but did not yet deliver the
> +	 * signal, then set the expire to the minimum possible, so it
> +	 * will expire immediately after restart succeeds.
> +	 */
> +	if (hrtimer_active(&signal->real_timer)) {
> +		ktime_t delta =3D hrtimer_get_remaining(&signal->real_timer);
> +		/*
> +		 * If the timer expired after the the test above, then
> +		 * set the expire to the minimum possible (because by
> +		 * now the pending signals have been saved already, but
> +		 * without the signal from this very expiry).
> +		 */
> +		ckpt_debug("active ! %lld\n", delta.tv64);
> +		if (delta.tv64 <=3D 0)
> +			delta.tv64 =3D NSEC_PER_USEC;
> +		h->it_real_value =3D ktime_to_ns(delta);
> +	} else if (sigismember(&signal->shared_pending.signal, SIGALRM)) {
> +		/* case (b) */
> +		h->it_real_value =3D h->it_real_incr;
> +	} else {
> +		/* case (c) */
> +		h->it_real_value =3D
> +			ktime_to_ns((ktime_t) { .tv64 =3D NSEC_PER_USEC });
> +	}

AFAICS the third case catches expired timers having not delivered the signa=
l yet
as well as inactive timers. If the latter, at restart the timer will be
rearmed while it should not.

However, reading hrtimer code I understand that case (c) cannot happen. IOW=
 if
the timer has expired but has not sent SIGALRM yet, then hrtimer_active()
returns true, and the first block already handles that case correctly.

Moreover case (b) only happens if the timer was not automatically rearmed,
that is it_real_incr =3D=3D 0. So in this case the signal was already sent =
(and
picked for checkpointing if not handled), and h->it_real_value should be se=
t to
0.

So the following could be actually better:

	h->it_real_incr =3D ktime_to_ns(signal->it_real_incr);
	/*
	 * (a) If the timer is now active, compute the time delta.
	 * (b) Otherwise, siglock ensures that 	 */
	if (hrtimer_active(&signal->real_timer)) {
		ktime_t delta =3D hrtimer_get_remaining(&signal->real_timer);
		/*
		 * If the timer expired after the the test above, then
		 * set the expire to the minimum possible (because by
		 * now the pending signals have been saved already, but
		 * the signal from this very expiry won't be sent before we
		 * release t->sighand->siglock.
		 */
		ckpt_debug("active ! %lld\n", delta.tv64);
		if (delta.tv64 <=3D 0)
			delta.tv64 =3D NSEC_PER_USEC;
		h->it_real_value =3D ktime_to_ns(delta);
	} else {
		BUG_ON(h->it_real_incr);
		h->it_real_value =3D 0;
	}

Louis

> +
> +	cputime_to_timeval(signal->it_virt_expires, &tval);
> +	h->it_virt_value =3D timeval_to_ns(&tval);
> +	cputime_to_timeval(signal->it_virt_incr, &tval);
> +	h->it_virt_incr =3D timeval_to_ns(&tval);
> +
> +	cputime_to_timeval(signal->it_prof_expires, &tval);
> +	h->it_prof_value =3D timeval_to_ns(&tval);
> +	cputime_to_timeval(signal->it_prof_incr, &tval);
> +	h->it_prof_incr =3D timeval_to_ns(&tval);
> +
>  	unlock_task_sighand(t, &flags);
> =20
>  	ret =3D ckpt_write_obj(ctx, &h->h);
> @@ -416,6 +461,7 @@ static int restore_signal(struct ckpt_ctx *ctx)
>  	struct ckpt_hdr_signal *h;
>  	struct sigpending new_pending;
>  	struct sigpending *pending;
> +	struct itimerval itimer;
>  	struct rlimit rlim;
>  	int i, ret;
> =20
> @@ -436,12 +482,38 @@ static int restore_signal(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		goto out;
> =20
> +	/*
> +	 * Reset real/virt/prof itimer (in case they were set), to
> +	 * prevent unwanted signals after flushing current signals
> +	 * and before restoring original real/virt/prof itimer.
> +	 */
> +	itimer.it_value =3D (struct timeval) { .tv_sec =3D 0, .tv_usec =3D 0 };
> +	itimer.it_interval =3D  (struct timeval) { .tv_sec =3D 0, .tv_usec =3D =
0 };
> +	do_setitimer(ITIMER_REAL, &itimer, NULL);
> +	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
> +	do_setitimer(ITIMER_PROF, &itimer, NULL);
> +
>  	spin_lock_irq(&current->sighand->siglock);
>  	pending =3D &current->signal->shared_pending;
>  	flush_sigqueue(pending);
>  	pending->signal =3D new_pending.signal;
>  	list_splice_init(&new_pending.list, &pending->list);
>  	spin_unlock_irq(&current->sighand->siglock);
> +
> +	/* real/virt/prof itimers */
> +	itimer.it_value =3D ns_to_timeval(h->it_real_value);
> +	itimer.it_interval =3D ns_to_timeval(h->it_real_incr);
> +	ret =3D do_setitimer(ITIMER_REAL, &itimer, NULL);
> +	if (ret < 0)
> +		goto out;
> +	itimer.it_value =3D ns_to_timeval(h->it_virt_value);
> +	itimer.it_interval =3D ns_to_timeval(h->it_virt_incr);
> +	ret =3D do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
> +	if (ret < 0)
> +		goto out;
> +	itimer.it_value =3D ns_to_timeval(h->it_prof_value);
> +	itimer.it_interval =3D ns_to_timeval(h->it_prof_incr);
> +	ret =3D do_setitimer(ITIMER_PROF, &itimer, NULL);
>   out:
>  	ckpt_hdr_put(ctx, h);
>  	return ret;
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hd=
r.h
> index 9dcb160..a0ec25f 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -472,6 +472,12 @@ struct ckpt_hdr_rlimit {
>  struct ckpt_hdr_signal {
>  	struct ckpt_hdr h;
>  	struct ckpt_hdr_rlimit rlim[CKPT_RLIM_NLIMITS];
> +	__u64 it_real_value;
> +	__u64 it_real_incr;
> +	__u64 it_virt_value;
> +	__u64 it_virt_incr;
> +	__u64 it_prof_value;
> +	__u64 it_prof_incr;
>  } __attribute__((aligned(8)));
> =20
>  struct ckpt_hdr_signal_task {
> --=20
> 1.6.0.4
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

--=_bohort-28427-1249395433-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkp4QwoACgkQVKcRuvQ9Q1SZJQCgqN011TnkN0TRkGac7+J7v27Q
h3UAni3hK1mXd3lkKrdRl3MIh0IzAJXi
=uQcs
-----END PGP SIGNATURE-----

--=_bohort-28427-1249395433-0001-2--

--===============3836243020365800066==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3836243020365800066==--
