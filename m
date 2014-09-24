From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 1.0.6 has been released!
Date: Wed, 24 Sep 2014 16:37:25 -0400
Message-ID: <20140924203725.GZ19386@dakara>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7697542826867136098=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, lxc-users-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============7697542826867136098==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="O2v8LnVIcZ+EDjcF"
Content-Disposition: inline


--O2v8LnVIcZ+EDjcF
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

The sixth LXC 1.0 bugfix release is now out!

This includes over two months worth of bugfixes contributed by 24
individual developers. The most important fix is the support for nested
unprivileged containers which was broken recently because of a kernel
security update.


As usual, the full announcement and changelog may be found at:
https://linuxcontainers.org/news/

And our tarballs can be downloaded from:
https://linuxcontainers.org/downloads/


As a reminder, LXC upstream is planning on maintaining the LXC 1.0
branch with frequent bugfix and security updates until April 2019.


St=E9phane Graber
On behalf of the LXC development team

--O2v8LnVIcZ+EDjcF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUIyuFAAoJEMY4l01keS1n1CMP/RJKxq0HGjqllUhtSrO0d+ab
xOJYBfO2QFj3uotuHvALr6vJOAb+Fjmw1EZt9aUytRWyAatGesyDOLohCNfZis1l
8AhU4FWUfAkOu3xNGHIhFtpkro+/b6bNv1xzSCbS+LdGSM9KN6iEzT2QfzkaC61e
lFzeP/zVUPlwuDOE0cF53/sfUeaNGzjbcS2bjdE1yg7JTjHkuUhntDJg9aZsRX5N
Iykre5M9Fli3yHEutVrlegvJiCMvuQB5eMTmkTNz10iji9R11E6NVYeU/MD/BzTF
u6qfyFvkDnIJ/SImGT3xaVdF7nBPDtlguzh9tJQzQVaHzr5azKnuJovt9P2OKA5V
cn1lIswGIsopXAf89En7asIzhqBf9qlY9VFCghsW0LnveoocEPVqoSfLEuEewCX5
1HTPd0hh/RomWWi45aE1dd7Te3/UVOSox9my/fkaAT+/xbASnZ9ZY6t5nCDceupq
bftUCjKsyRRITKnRyo15UthU2X0MSZvmmblQzlzCn83IdIZpa3C+Oe8kf1sLdhgX
e/OLUVeJDxE0ElY8KHsQZ95upXSEviFABxpFMIMiZJ5CLQLsamJ8y6Ink3rV7gwI
KQ1jNXgcTtBMK/govzeb1C7EjipxA8G+NQD3d2E8C6TTq7uZQ75bDoGbwSisn2oQ
5RLXdiQ3X1t6Mv7yRbC/
=ba1c
-----END PGP SIGNATURE-----

--O2v8LnVIcZ+EDjcF--

--===============7697542826867136098==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7697542826867136098==--
