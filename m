From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Initialize msg_msg security pointer at restart.
Date: Wed, 30 Mar 2011 22:29:54 -0500
Message-ID: <20110331032954.GA8747@peq.hallyn.com>
References: <1301512246-32114-1-git-send-email-jrs@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5243357058975714927=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1301512246-32114-1-git-send-email-jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
To: "Jose R. Santos" <jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============5243357058975714927==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Content-Disposition: inline


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Jose R. Santos (jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> This small oversight was causing either crashes on free_msg() or
> restart failures under some message queue workloads.
>=20
> Signed-off-by: Jose R. Santos <jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

What kernel is this?

Starting with the last line in your context, there is:

	/* set default MAC attributes */
	ret =3D security_msg_msg_alloc(msg);
	if (ret < 0)
		goto out;

which should take care of that.  I don't know of an LSM which
doesn't define msg_msg_alloc() but does define msg_msg_free().
Do you have a stack trace to show where it was getting
freed?

> CC: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  ipc/checkpoint_msg.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
> index 0a19d1f..6fa2c8e 100644
> --- a/ipc/checkpoint_msg.c
> +++ b/ipc/checkpoint_msg.c
> @@ -233,6 +233,7 @@ static struct msg_msg *restore_msg_contents_one(struc=
t ckpt_ctx *ctx, int *clen)
>  		goto out;
>  	}
>  	msg->next =3D NULL;
> +        msg->security =3D NULL;
>  	pseg =3D &msg->next;
> =20
>  	/* set default MAC attributes */
> --=20
> 1.7.1
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNk/UyAAoJEHmllQITXQdF5ZMH/R4eEPTtWtrfwUjEvABdfn6u
GaPWgnRUJvSOjHTUs4PQkM0a/vzj7yXgizRveFVMRfEsq/01rYrQI4F1C65yiP4o
s0Bt7cOSwcuI3PndfroH1WU7J86096CCV5U4j+kDOcyoIbzRw2jPnF6IsOSAoMFC
UGVSl4B7Zn9oDk6dA8o1h934Lacy/X5CMO5OvBhqpPiOhq+eM9IK6iFzbSuQoAGk
x4QfcXiMJeKblsVtFVF5HRQ6Cxo0HgdDA0ol5blR0gJHURG187myl/rbd8MKxY0R
5WStF9Io50xeMPlPK4a05yycEz7tazI2qu4Vb2HN48l43QeV9BPuUEnSukvzVsM=
=o0Xt
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--

--===============5243357058975714927==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5243357058975714927==--
