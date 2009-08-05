From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 4/4] c/r: support for real/virt/prof itimers (v2)
Date: Wed, 5 Aug 2009 12:40:30 +0200
Message-ID: <20090805104030.GU29252@hawkmoon.kerlabs.com>
References: <1249376956-27555-1-git-send-email-orenl@librato.com>
	<1249376956-27555-5-git-send-email-orenl@librato.com>
	<20090804141746.GQ29252@hawkmoon.kerlabs.com>
	<4A78816A.6080001@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6279417569231051437=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A78816A.6080001-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

--===============6279417569231051437==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-25132-1249468797-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-25132-1249468797-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/08/09 14:43 -0400, Oren Laadan wrote:
>=20
>=20
> Louis Rilling wrote:
> > Hi Oren,
> >=20
> > On 04/08/09  5:09 -0400, Oren Laadan wrote:
> >> This patch adds support for real/virt/prof itimers.
> >> Expiry and the interval values are both saved in nanoseconds.
> >>
> >> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> >> ---
> >>  checkpoint/signal.c            |   72 +++++++++++++++++++++++++++++++=
+++++++++
> >>  include/linux/checkpoint_hdr.h |    6 +++
> >>  2 files changed, 78 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
> >> index c9da06b..18b3e2d 100644
> >> --- a/checkpoint/signal.c
> >> +++ b/checkpoint/signal.c
> >> @@ -15,6 +15,7 @@
> >>  #include <linux/signal.h>
> >>  #include <linux/errno.h>
> >>  #include <linux/resource.h>
> >> +#include <linux/timer.h>
> >>  #include <linux/checkpoint.h>
> >>  #include <linux/checkpoint_hdr.h>
> >> =20
> >> @@ -264,6 +265,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx,=
 struct task_struct *t)
> >>  	struct signal_struct *signal;
> >>  	struct sigpending shared_pending;
> >>  	struct rlimit *rlim;
> >> +	struct timeval tval;
> >>  	unsigned long flags;
> >>  	int i, ret;
> >> =20
> >> @@ -299,6 +301,49 @@ static int checkpoint_signal(struct ckpt_ctx *ctx=
, struct task_struct *t)
> >>  		h->rlim[i].rlim_cur =3D rlim[i].rlim_cur;
> >>  		h->rlim[i].rlim_max =3D rlim[i].rlim_max;
> >>  	}
> >> +
> >> +	/* real/virt/prof itimers */
> >> +	h->it_real_incr =3D ktime_to_ns(signal->it_real_incr);
> >> +	/*
> >> +	 * (a) If the timer is now active (did not expire), compute
> >> +	 * the time delta.
> >> +	 * (b) If the timer expired, and delivered the signal already,
> >> +	 * then set the expire (value) to the interval
> >> +	 * (c) If the timer expired but did not yet deliver the
> >> +	 * signal, then set the expire to the minimum possible, so it
> >> +	 * will expire immediately after restart succeeds.
> >> +	 */
> >> +	if (hrtimer_active(&signal->real_timer)) {
> >> +		ktime_t delta =3D hrtimer_get_remaining(&signal->real_timer);
> >> +		/*
> >> +		 * If the timer expired after the the test above, then
> >> +		 * set the expire to the minimum possible (because by
> >> +		 * now the pending signals have been saved already, but
> >> +		 * without the signal from this very expiry).
> >> +		 */
> >> +		ckpt_debug("active ! %lld\n", delta.tv64);
> >> +		if (delta.tv64 <=3D 0)
> >> +			delta.tv64 =3D NSEC_PER_USEC;
> >> +		h->it_real_value =3D ktime_to_ns(delta);
> >> +	} else if (sigismember(&signal->shared_pending.signal, SIGALRM)) {
> >> +		/* case (b) */
> >> +		h->it_real_value =3D h->it_real_incr;
> >> +	} else {
> >> +		/* case (c) */
> >> +		h->it_real_value =3D
> >> +			ktime_to_ns((ktime_t) { .tv64 =3D NSEC_PER_USEC });
> >> +	}
> >=20
> > AFAICS the third case catches expired timers having not delivered the s=
ignal yet
> > as well as inactive timers. If the latter, at restart the timer will be
> > rearmed while it should not.
> >=20
> > However, reading hrtimer code I understand that case (c) cannot happen.=
 IOW if
> > the timer has expired but has not sent SIGALRM yet, then hrtimer_active=
()
> > returns true, and the first block already handles that case correctly.
>=20
> Yes, I re-read the code and (c) should not happen, because the timer
> cannot become inactive without having sent SIGALRM as long as we hold
> the siglock.
>=20
> > Moreover case (b) only happens if the timer was not automatically rearm=
ed,
> > that is it_real_incr =3D=3D 0. So in this case the signal was already s=
ent (and
> > picked for checkpointing if not handled), and h->it_real_value should b=
e set to
> > 0.
>=20
> Here is the scenario I had in mind:
>=20
> 1) kernel/hrtimer.c:__run_hrtimer() is called with the timer fires,
> sets the timer state to HRTIMER_STATE_CALLBACK and then invokes
> the callback.
>=20
> 2) for itimers, the callback is kernel/itimer.c:it_real_fn(): it
> sends the signal and returns HRTIMER_NORESTART.
>=20
> 3) back to __run_hrtimer() which does _not_ call enqueue_hrtimer(),
> and then _clears_ the HRTIMER_STATE_CALLBACK. This results in the
> state being zero -- that is, hrtimer_active() will be false.
>=20
> So in #2 SIGALRM was sent, and then in #3 the timer became inactive
> without holding siglock, and not re-armed. (if it_real_incr > 0, it
> should and will be re-armed when the signal is dequeued).
>=20
> Therefore when we restart, we need to set it_real_incr to its saved
> value, and it_real_value to 0. Then, if SIGALRM was sent, it will
> be dequeued after restart, and depending on it_real_incr the timer
> will, or will not, be re-armed. If SIGALRM was not sent, then it
> must be that it_real_incr is also 0.
>=20
> IOW, in both cases (SIGALRM sent/not sent) of the inactive timer,
> the value of it_real_incr should be 0, therefore the code you

I guess that you meant it_real_value, not it_real_incr.

> suggest below is correct, except for the BUG_ON statement.

You're right. I missed the fact that the timer was only rearmed when dequeu=
ing
SIGALRM, which is a bit counter-intuitive since blocking SIGALRM then intro=
duces
a drift in timer events.

>=20
> (In restart, it's not a big deal if these values are "incorrect",
> because the worst harm it can do is send a superfluous SIGALRM).

I'm not sure that superfuous SIGALRM are harmless, especially if the process
just deactivated all timers. However, IIUC there will be none so it's ok.

Thanks,

Louis

>=20
> >=20
> > So the following could be actually better:
> >=20
> > 	h->it_real_incr =3D ktime_to_ns(signal->it_real_incr);
> > 	/*
> > 	 * (a) If the timer is now active, compute the time delta.
> > 	 * (b) Otherwise, siglock ensures that 	 */
> > 	if (hrtimer_active(&signal->real_timer)) {
> > 		ktime_t delta =3D hrtimer_get_remaining(&signal->real_timer);
> > 		/*
> > 		 * If the timer expired after the the test above, then
> > 		 * set the expire to the minimum possible (because by
> > 		 * now the pending signals have been saved already, but
> > 		 * the signal from this very expiry won't be sent before we
> > 		 * release t->sighand->siglock.
> > 		 */
> > 		ckpt_debug("active ! %lld\n", delta.tv64);
> > 		if (delta.tv64 <=3D 0)
> > 			delta.tv64 =3D NSEC_PER_USEC;
> > 		h->it_real_value =3D ktime_to_ns(delta);
> > 	} else {
> > 		BUG_ON(h->it_real_incr);
> > 		h->it_real_value =3D 0;
> > 	}
> >=20
> > Louis
>=20
> Thanks,
>=20
> Oren.
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

--=_bohort-25132-1249468797-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkp5YZ4ACgkQVKcRuvQ9Q1RtMACgozMOH4Jd74R75hOm0bsG5mmb
59oAmQFIA+Sx+HeeeHm86qDnv66+uHmD
=dq9Z
-----END PGP SIGNATURE-----

--=_bohort-25132-1249468797-0001-2--

--===============6279417569231051437==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6279417569231051437==--
