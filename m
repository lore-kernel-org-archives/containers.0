From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: handling of supplemental groups with userns
Date: Mon, 28 Sep 2015 23:06:13 -0400
Message-ID: <20150929030613.GA28210__8995.58739406547$1443495988$gmane$org@vapier.lan>
References: <20150922162157.GB27286@vapier.lan>
	<87d1xafdk8.fsf@x220.int.ebiederm.org>
	<20150922215215.GE27286@vapier.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4761039438884670325=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150922215215.GE27286-UgUKS2FnFs9+urZeOPWqwQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============4761039438884670325==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Content-Disposition: inline


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 22 Sep 2015 17:52, Mike Frysinger wrote:
> On 22 Sep 2015 14:40, Eric W. Biederman wrote:
> > Mike Frysinger writes:
> > > in the mean time, a "quick" fix might be to change new_idmap_permitted
> > > to walk all the extents, and if all the ranges are set to 1, check the
> > > supplemental groups in addition to the current egid ?
> >=20
> > That allows dropping groups that you could not drop normally and so we
> > can't allow it, by default.
>=20
> if setgroups is set to deny, then it's not possible for me to drop any
> groups, and therefore allowing me to map supplemental groups wouldn't be
> a problem right ?

so this does open up a permission people do not have today by themselves.
since there's no requirement that the current gid be in the supplemental
groups, they could drop a single group by changing to a supp one.

for example, if it looked like:
	getuid() =3D 1000
	getgid() =3D 1000
	getgroups() =3D {100, 250}

then if 1000/100/250 were mapped in, they could do:
	setgid(100)
	getgid() =3D 100
	getgroups() =3D {100, 250}
and thus group 1000 has been dropped.

the reason this doesn't happen today is that writes to gid_map is permitted
only if the writer has CAP_SETGID in the parent userns and the gid has been
mapped there.  normal users don't start out with that cap, and any setuid
helper has to make sure to drop caps & setuid/setgid before execing the next
layer (i.e. do the standard stuff).

so the only way to permit this behavior is if the knobs were extended and we
had a parallel USERNS_SETGID_ALLOWED.  or we updated setgid to check the bit
USERNS_SETGROUPS_ALLOWED since it seems in spirit to cover that.
-mike

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWCgAlAAoJEEFjO5/oN/WBnm0QANIXE9oBP4NgcjquqL/oEzus
XGQoZb6QNnGlX5wCnwCv6HJ8ATRWOFJiRA2y1EOPErQjI4MgS1x2H/L9n32f3Che
e+fmIFEAAUSTIC7rPvbhgUhWc19pEPOs0x3j/mTg66MRnt0aWYJppZp1TLNw/XHK
X/Oq6Lfi+nwpoVYF/GQeDu/FSh3u1f82eMeIsuGQn8K/tz8iGe57tW9Qz9FTyEsc
jFfv82lqw24SI8/mXV+IiscrK9EyDvj60Y43KxZYT2OehFMWzabBwXnyxv6skZFI
FpnDSbWJs4OuCveK9o6B/Sun8Vu+gBMuZkz+lJl4+pQwMsBzT02zYENSHyhOLgYI
Ge0k4cCczBXikGxQTR2oq2bswhqNvU3upfkpasKlkeXhoES/NlKKqseRRj8cW4TU
791FbUeaYe96/npqukZgBpAy33Tm9jW9LsesIPkVp7VlZtn3X4CYpZ8ROeM7ohnq
FuZSl3hWNkNCxiRSi6UzvugDbDZeNUiGANFWvVYLAiloAkwmUhlGTdvzCH0WIxgs
YVrLLRtqszrQxNrDQlZBWOEPToh8GS37pqlUAzimMSscKiu7rJJ8EE07iUDK0AOh
L+AuSni1R+VtgpWx4w1S+DeuDzg46xJnjXADfmi8/J62wwjl7xmShhe6OT6nE0fp
y2KnHib40EAiBaHGyzd0
=Y0q4
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--

--===============4761039438884670325==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============4761039438884670325==--
