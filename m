From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 1.0.5 has been released!
Date: Mon, 14 Jul 2014 11:31:28 -0400
Message-ID: <20140714153128.GK25357__2327.86523779414$1405352218$gmane$org@dakara>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2498449209877637195=="
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


--===============2498449209877637195==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="9RxwyT9MtfFuvYYZ"
Content-Disposition: inline


--9RxwyT9MtfFuvYYZ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

The fifth LXC 1.0 bugfix release is now out!

This includes over two months worth of bugfixes contributed by 11
individual developers. The most important changes are support for
unprivileged containers with recent kernels and the inclusion of a
seccomp policy by default (to prevent exploits such as the recently
release "shocker").


As usual, the full announcement and changelog may be found at:
https://linuxcontainers.org/news/

And our tarballs can be downloaded from:
https://linuxcontainers.org/downloads/


As a reminder, LXC upstream is planning on maintaining the LXC 1.0
branch with frequent bugfix and security updates until April 2019.


St=E9phane Graber
On behalf of the LXC development team

--9RxwyT9MtfFuvYYZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJTw/fQAAoJEMY4l01keS1nXTkP/2azOFwHtOK7EFzykwDLxDAL
dq/CvkEyNIStX314SWE4jLknfrgVIQfg1n0f4IEOi74bjIRHqom6pcdcvp7eeCbN
MLNrcDKl3pB0rcb4AE5bIg9NpIyUxxxlcDhH7xwwVMmnErOuqfFhKFzQe9VCWO/M
zpDe+bINCwNfbWn57oZXQFYS9jXnJ+++jt3BesEfEHadEAtS6X83Btm1MZwXr590
82/kPWhsdN4tFIOL/FwzadyIS9FV3TDkwYBOV8QR0JVlYdL+4d3MiX8jdIb7Kw4A
LaJKVQATSmZ3O00W8gzQUxzXSskIPf2F1T6W1fZNMZDul9CQK+NJx2AIkH+X1Pvp
MXnDMv9qvl6AfMoCJRNmgkd8IsNEVBr19/uSMUMe0KxNw7eb4YcE4Ijp2NgeHpfv
RLXEpCIw2kEuUXVlnSBIh/gacrXVfrj/3TN2pOm6DQfMyDqvixXXkyQfDXY+wD1W
3Y4pn7OSTf6bhCL/eUwfyNk+uxSRD3C3g/ZItyF974S399zP/+rWIBqIGZCcr5on
YY0wu4/npF4190XzSNwL/6E2Shs2/eineRE6CDD1ybGCjNp9C9jLcG99vU5jG0xQ
ZK26yfB2MKWrNnvJLuMpqr1ewfjX8HyiOPcS5Ie0UZjDx4W+IHSj0BNBiBSofEc7
a4wzUnxkPczdAAZHv0Iv
=Lev1
-----END PGP SIGNATURE-----

--9RxwyT9MtfFuvYYZ--

--===============2498449209877637195==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2498449209877637195==--
