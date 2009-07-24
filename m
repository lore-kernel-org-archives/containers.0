From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: [signal 3/3] pending signals (private, shared)
Date: Fri, 24 Jul 2009 15:13:56 +0200
Message-ID: <20090724131356.GI11101@hawkmoon.kerlabs.com>
References: <1248360514-20710-1-git-send-email-orenl@librato.com>
	<1248360514-20710-3-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7396550442532312305=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248360514-20710-3-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

--===============7396550442532312305==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-25792-1248441206-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-25792-1248441206-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 23/07/09 10:48 -0400, Oren Laadan wrote:
> This patch adds checkpoint and restart of pending signals queues:
> struct sigpending, both per-task t->sigpending and shared (per-
> thread-group) t->signal->shared_sigpending.
>=20
> To checkpoint pending signals (private/shared) we first detach the
> signal queue (and copy the mask) to a separate struct sigpending.
> This separate structure can be iterated through without locking.
>=20
> Once the state is saved, we re-attaches (prepends) the original signal
> queue back to the original struct sigpending.
>=20
> Signals that arrive(d) in the meantime will be suitably queued after
> these (for real-time signals). Repeated non-realtime signals will not
> be queued because they will already be marked in the pending mask,
> that remains as is. This is the expected behavior of non-realtime
> signals.
>=20
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  checkpoint/signal.c            |  255 ++++++++++++++++++++++++++++++++++=
+++++-
>  include/linux/checkpoint_hdr.h |   23 ++++
>  2 files changed, 277 insertions(+), 1 deletions(-)
>=20
> diff --git a/checkpoint/signal.c b/checkpoint/signal.c
> index b3f1d3e..940cc4a 100644
> --- a/checkpoint/signal.c
> +++ b/checkpoint/signal.c
> @@ -166,12 +166,99 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int s=
ighand_objref)
>   * signal checkpoint/restart
>   */
> =20
> +static void fill_siginfo(struct ckpt_hdr_siginfo *si, siginfo_t *info)
> +{
> +	si->signo =3D info->si_signo;
> +	si->_errno =3D info->si_errno;
> +	si->code =3D info->si_code;
> +
> +	/* TODO: convert info->si_uid to uid_objref */
> +
> +	switch(info->si_code & __SI_MASK) {
> +	case __SI_TIMER:
> +		si->pid =3D info->si_tid;
> +		si->uid =3D info->si_overrun;
> +		si->sigval_int =3D info->si_int;
> +	si->utime =3D info->si_sys_private;
> +		break;
> +	case __SI_POLL:
> +		si->pid =3D info->si_band;
> +		si->sigval_int =3D info->si_fd;
> +		break;
> +	case __SI_FAULT:
> +		si->sigval_ptr =3D (unsigned long) info->si_addr;
> +#ifdef __ARCH_SI_TRAPNO
> +		si->sigval_int =3D info->si_trapno;
> +#endif
> +		break;
> +	case __SI_CHLD:
> +		si->pid =3D info->si_pid;
> +		si->uid =3D info->si_uid;
> +		si->sigval_int =3D info->si_status;
> +		si->stime =3D info->si_stime;
> +		si->utime =3D info->si_utime;
> +		break;
> +	/*
> +	 * case __SI_KILL:
> +	 * case __SI_RT:
> +	 * case __SI_MESGQ:
> +	 */
> +	default:
> +		si->pid =3D info->si_pid;
> +		si->uid =3D info->si_uid;
> +		si->sigval_ptr =3D (unsigned long) info->si_ptr;
> +		break;
> +	}
> +}
> +
> +/*
> + * To checkpoint pending signals (private/shared) the caller moves the
> + * signal queue (and copies the mask) to a separate struct sigpending,
> + * therefore we can iterate through it without locking.
> + * After we return, the caller re-attaches (prepends) the original
> + * signal queue to the original struct sigpending. Thus, signals that
> + * arrive(d) in the meantime will be suitably queued after these.
> + * Finally, repeated non-realtime signals will not be queued because
> + * they will already be marked in the pending mask, that remains as is.
> + * This is the expected behavior of non-realtime signals.
> + */
> +static int checkpoint_sigpending(struct ckpt_ctx *ctx,
> +				 struct sigpending *pending)
> +{
> +	struct ckpt_hdr_sigpending *h;
> +	struct ckpt_hdr_siginfo *si;
> +	struct sigqueue *q;
> +	int nr_pending =3D 0;
> +	int ret;
> +
> +	list_for_each_entry(q, &pending->list, list)
> +		nr_pending++;
> +	h =3D ckpt_hdr_get_type(ctx, nr_pending * sizeof(*si) + sizeof(*h),
> +			      CKPT_HDR_SIGPENDING);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->nr_pending =3D nr_pending;
> +	fill_sigset(&h->signal, &pending->signal);
> +
> +	si =3D h->siginfo;
> +	list_for_each_entry(q, &pending->list, list)
> +		fill_siginfo(si++, &q->info);

If q has SIGQUEUE_PREALLOC, we should probably abort the checkpoint, until =
POSIX
timers (only users AFAIK) are supported.

Thanks,

Louis

> +
> +	ret =3D ckpt_write_obj(ctx, &h->h);
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +

[...]

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-25792-1248441206-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkpps5QACgkQVKcRuvQ9Q1RxcgCdEHtWwz9QKJvmny38A2Od0IBE
iXoAni9M/2Vg3vgPidKgurKUxJCeJ1St
=mwCd
-----END PGP SIGNATURE-----

--=_bohort-25792-1248441206-0001-2--

--===============7396550442532312305==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7396550442532312305==--
