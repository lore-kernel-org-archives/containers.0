From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: [signal 3/3] pending signals (private, shared)
Date: Fri, 24 Jul 2009 14:36:29 +0200
Message-ID: <20090724123629.GH11101@hawkmoon.kerlabs.com>
References: <1248360514-20710-1-git-send-email-orenl@librato.com>
	<1248360514-20710-3-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2374017065578380421=="
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

--===============2374017065578380421==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-24774-1248438958-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-24774-1248438958-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Oren,

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

[...]

> +
> +static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *p=
ending)
> +{
> +	struct ckpt_hdr_sigpending *h;
> +	struct ckpt_hdr_siginfo *si;
> +	struct sigqueue *q, *n;
> +	int ret =3D 0;
> +
> +	h =3D ckpt_read_buf_type(ctx, 0, CKPT_HDR_SIGPENDING);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	INIT_LIST_HEAD(&pending->list);
> +	load_sigset(&pending->signal, &h->signal);
> +
> +	si =3D h->siginfo;
> +	while (h->nr_pending--) {
> +		q =3D sigqueue_alloc();

This introduces a memory leak, since collect_signal() won't free q. Better =
to
use __sigqueue_alloc() here, or clear the SIGQUEUE_PREALLOC flag.

Thanks,

Louis

> +		if (!q) {
> +			ret =3D -ENOMEM;
> +			break;
> +		}
> +
> +		ret =3D load_siginfo(&q->info, si++);
> +		if (ret < 0) {
> +			sigqueue_free(q);
> +			break;
> +		}
> +
> +		list_add_tail(&pending->list, &q->list);
> +	}
> +
> +	if (ret < 0) {
> +		list_for_each_entry_safe(q, n, &pending->list, list) {
> +			list_del_init(&q->list);
> +			sigqueue_free(q);
> +		}
> +	}
> +
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +

[...]

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-24774-1248438958-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkppqs0ACgkQVKcRuvQ9Q1S+lgCdHh6bafkrG0jYv1hDsyUDUWfh
PksAoM4lNWPRLt8u7qyx0H7ip8B7283v
=eYZ7
-----END PGP SIGNATURE-----

--=_bohort-24774-1248438958-0001-2--

--===============2374017065578380421==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2374017065578380421==--
