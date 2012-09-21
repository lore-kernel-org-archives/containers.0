From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 03/25] userns: Convert usb functionfs to use kuid/kgid
	where appropriate
Date: Fri, 21 Sep 2012 12:32:54 +0300
Message-ID: <20120921093252.GA15626__6229.66700834713$1348220284$gmane$org@arwen.pp.htv.fi>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
	<1348141326-23355-3-git-send-email-ebiederm@xmission.com>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3833491407909052067=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-3-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============3833491407909052067==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Content-Disposition: inline


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 20, 2012 at 04:41:44AM -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>=20
> Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>

> ---
>  drivers/usb/gadget/f_fs.c |   23 ++++++++++++++++-------
>  init/Kconfig              |    1 -
>  2 files changed, 16 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/usb/gadget/f_fs.c b/drivers/usb/gadget/f_fs.c
> index 8adc79d..f9ee4e0 100644
> --- a/drivers/usb/gadget/f_fs.c
> +++ b/drivers/usb/gadget/f_fs.c
> @@ -220,8 +220,8 @@ struct ffs_data {
>  	/* File permissions, written once when fs is mounted */
>  	struct ffs_file_perms {
>  		umode_t				mode;
> -		uid_t				uid;
> -		gid_t				gid;
> +		kuid_t				uid;
> +		kgid_t				gid;
>  	}				file_perms;
> =20
>  	/*
> @@ -1143,10 +1143,19 @@ static int ffs_fs_parse_opts(struct ffs_sb_fill_d=
ata *data, char *opts)
>  			break;
> =20
>  		case 3:
> -			if (!memcmp(opts, "uid", 3))
> -				data->perms.uid =3D value;
> +			if (!memcmp(opts, "uid", 3)) {
> +				data->perms.uid =3D make_kuid(current_user_ns(), value);
> +				if (!uid_valid(data->perms.uid)) {
> +					pr_err("%s: unmapped value: %lu\n", opts, value);
> +					return -EINVAL;
> +				}
> +			}
>  			else if (!memcmp(opts, "gid", 3))
> -				data->perms.gid =3D value;
> +				data->perms.gid =3D make_kgid(current_user_ns(), value);
> +				if (!gid_valid(data->perms.gid)) {
> +					pr_err("%s: unmapped value: %lu\n", opts, value);
> +					return -EINVAL;
> +				}
>  			else
>  				goto invalid;
>  			break;
> @@ -1175,8 +1184,8 @@ ffs_fs_mount(struct file_system_type *t, int flags,
>  	struct ffs_sb_fill_data data =3D {
>  		.perms =3D {
>  			.mode =3D S_IFREG | 0600,
> -			.uid =3D 0,
> -			.gid =3D 0
> +			.uid =3D GLOBAL_ROOT_UID,
> +			.gid =3D GLOBAL_ROOT_GID,
>  		},
>  		.root_mode =3D S_IFDIR | 0500,
>  	};
> diff --git a/init/Kconfig b/init/Kconfig
> index 633bde2..e7e0cc1 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -932,7 +932,6 @@ config UIDGID_CONVERTED
>  	depends on NET_9P =3D n
> =20
>  	# Filesystems
> -	depends on USB_FUNCTIONFS =3D n
>  	depends on DEVTMPFS =3D n
>  	depends on XENFS =3D n
> =20
> --=20
> 1.7.5.4
>=20

--=20
balbi

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQXDREAAoJEIaOsuA1yqREQVQQAKge0VRPy0D6c1gZ26nDY6sX
LSkYo611fbmQaJqwli8uGGoFRjWOJpvzXrRY+ZtIO7RsSsSH818S+3KYK2PiaoSW
BrqS/hnSomgZVX05DrPimBMF1T9jijY+pBxlGEFixJbI/kLSc5vt29myKDxwTxch
Tk9AYEDL2JCIhO5y/gLYEghY5a8AaoVRiRi/raP7YfgvBLuiMSw/LZ1EH21OYWN9
mQNG1tx8XdpDfjNICENVgLHJvgMD++YWU8rT+6UyJZZSfCHHhIY06yJkIH2x1J3A
zUm1Nwj9PWl+Ci+JnKWiKpZAFnps3+JN30bfjWIP8XEBSlaRoUcQg6aGzBN3bLfU
EF6KRZZNPR/yVjq8CSjReFiIx5S/+fY16CKZEr6GBSxqSzNtMiAQ4yWKQniHku4V
zZq/APK+MuqadKWqj3lAQ+kyZy1tObhgwUvWuK18j4MdYseiQXD5mmKlNtPyVJ3I
rja8nWd9QxZd4MMSDPHQ493OzCbf6ouaM3MYdu22FM2RM9vdoirWJnImYV/3mCtn
AoP0Nhr4Ef+GkFuTW/HL0RyVp2irrgHhcT/v1h2Hj+AGAgwWtzVNBqhiGZATFZWM
hiXijVWXKfL25EBNlL724excHtQGbhPTQ+a6t7hRQuMzCWAMHAJlk2IdWIFFubuA
ZMyItkYrusjH3zFkW5In
=kvb2
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--

--===============3833491407909052067==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3833491407909052067==--
