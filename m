From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: util-linux-ng: unprivileged mounts support
Date: Tue, 8 Jan 2008 10:31:04 -0500
Message-ID: <200801081031.06826.vapier@gentoo.org>
References: <E1JCCyk-0002pY-AM@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1646180.jnDCrdTZE9";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JCCyk-0002pY-AM@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: util-linux-ng@vger.kernel.org, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

--nextPart1646180.jnDCrdTZE9
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 08 January 2008, Miklos Szeredi wrote:
> --- util-linux-ng.orig/configure.ac	2008-01-07 21:40:22.000000000 +0100
> +++ util-linux-ng/configure.ac	2008-01-07 21:40:50.000000000 +0100
> @@ -91,6 +92,11 @@ fi
>  UTIL_CHECK_LIB(util, openpty)
>  UTIL_CHECK_LIB(termcap, tgetnum)
>
> +UTIL_CHECK_LIB(cap, cap_get_proc)
> +if test $have_cap =3D no; then
> +   AC_MSG_ERROR([libcap is required for mount]);
> +fi

this should be optional and it should be controlled with an AC_ARG_WITH()

with all the non-linux changes that have gone in, does there need to be hea=
der=20
checks here and then have mount.c key off of them ?  i'm thinking so ...
=2Dmike

--nextPart1646180.jnDCrdTZE9
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHg5c6AAoJEEFjO5/oN/WB9ggP/1qUuUNMJr3fP4KxRDqijtCK
bOu4qa0/IXfLu2+Mqlc2vTf9iTq+rRGdNxN+LZIhv/n1BWGuy2PndwMPjiBiTghb
I5VlS+/QlwN9WfE2TOxK0bwrjZBQm8k9hOjJVxsdttjibyJOTQr2uAnUScSdF2+9
o9wSihgPy/AHOolUpIYJzF1xKK0cb3KW8Nve/ZJ6o0bxY41oCmJ+EAUI+CLyUUH/
OjiLEJ9JqdirBPWyQsE24ZjnQR5vzRdDRavjRVVreHYBFcp6BOxAr7beVN+4vyXD
LSlO5WFRVFbOW+WdApPhA34H+a1hJuO6JrlbHYSYq0A9d/OO79a2islQE7BuKklz
eZlOzGymp9AYPFKxmnecyqBllKpctQHAQ3lslHziuU0ova9HIOI7cpdPb3ISooGb
3mInMLou+DIMNoo9X83Qmm4fOgaIw0KbH2/TrbFKVDoNE/9B586tzL0BTyF45qk4
EAwKJP4G3cc2JdAHNUqX/RTqoC8v0jf2/j2hJeO8XfWXL0i8RPhIx7qbtgmgE0Pj
gSi1x4R0y/QLH0HKPEFt3GZ4HGzUkIoq/0MUBBTSHvKweF3bh+/rXpuYE7am/RQQ
xAOm7iHC5C9DIWqtF9V8ps1AXr/e6Ir6jq9Dvv57ZUT0MmBeELH9fWciSggKqVav
xMgDfZ86PHZem33awA6a
=YgCz
-----END PGP SIGNATURE-----

--nextPart1646180.jnDCrdTZE9--
