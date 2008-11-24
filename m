From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/2] Add flags for user-space and in-kernel process
	creation
Date: Mon, 24 Nov 2008 17:02:11 +0100
Message-ID: <20081124160211.GE27238@hawkmoon.kerlabs.com>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
	<1227541175-30301-2-git-send-email-major@openvz.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6840114978315888283=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227541175-30301-2-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============6840114978315888283==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-26512-1227542379-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-26512-1227542379-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 24/11/08 18:39 +0300, Andrey Mirkin wrote:
> Introduce 2 flags for user-space and in-kernel process creation during
> restart procedure.
> Also a stub function for in-kernel process restart is introduced.
>=20

[...]

> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 7745500..e4a9287 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -264,8 +264,8 @@ asmlinkage long sys_restart(int crid, int fd, unsigne=
d long flags)
>  	pid_t pid;
>  	int ret;
> =20
> -	/* no flags for now */
> -	if (flags)
> +	if ((flags & (CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_USERSPACE)) =3D=
=3D
> +			(CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_USERSPACE))

I guess that the intent was:
+	if ((flags & (CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_KERNEL)) =3D=3D
+			(CR_CTX_RSTR_IN_USERSPACE | CR_CTX_RSTR_IN_KERNEL))

?

Louis

>  		return -EINVAL;
> =20
>  	/* FIXME: for now, we use 'crid' as a pid */
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index cab5e19..947469a 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -61,6 +61,8 @@ struct cr_ctx {
>  /* cr_ctx: flags */
>  #define CR_CTX_CKPT	0x1
>  #define CR_CTX_RSTR	0x2
> +#define CR_CTX_RSTR_IN_USERSPACE	0x4
> +#define CR_CTX_RSTR_IN_KERNEL		0x8
> =20
>  extern int cr_kwrite(struct cr_ctx *ctx, void *buf, int count);
>  extern int cr_kread(struct cr_ctx *ctx, void *buf, int count);
> @@ -108,6 +110,7 @@ extern int cr_write_mm(struct cr_ctx *ctx, struct tas=
k_struct *t);
>  extern int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);
> =20
>  extern int do_restart(struct cr_ctx *ctx, pid_t pid);
> +extern int do_restart_in_kernel(struct cr_ctx *ctx);
>  extern int cr_read_mm(struct cr_ctx *ctx);
>  extern int cr_read_files(struct cr_ctx *ctx);
> =20
> --=20
> 1.5.6
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-26512-1227542379-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJKtACVKcRuvQ9Q1QRAjU7AKDEDbmB926iU/ehqNhof6qb5ASXJACfWOsV
D8tliYbn8YOCaXugOKIofCE=
=ZWhK
-----END PGP SIGNATURE-----

--=_bohort-26512-1227542379-0001-2--

--===============6840114978315888283==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6840114978315888283==--
