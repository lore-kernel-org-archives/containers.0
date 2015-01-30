From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: LXC 1.1 has been released!
Date: Fri, 30 Jan 2015 14:23:33 +0100
Message-ID: <20150130132333.GI18477__6923.78922035477$1422624231$gmane$org@castiana.ipv6.teksavvy.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8284753705165528597=="
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


--===============8284753705165528597==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="lZZ4ablUVnt2XgAh"
Content-Disposition: inline


--lZZ4ablUVnt2XgAh
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello everyone,

The LXC team is pleased to announce the release of LXC 1.1!

This new upstream release is the result of the work of over 80
individual contributors.

The highlights are:
 - Introduction of checkpoint/restore support for containers through CRIU.
   This allows to serialize the container running state to disk, for
   live migration or for later local restoration of the container.

 - Support for running systemd as the init system inside the container
   was also greatly improved and should now work by default both for
   privileged and unprivileged containers when combined with lxcfs and a
   recent systemd.

 - Init scripts have now all been updated to provide the same feature
   set, which means that a lxcbr0 bridge with a DHCP and DNS server
   (dnsmasq) is now the default for anyone using LXC. We currently provide
   init scripts for systemd, sysvinit and upstart.=20

Those are just highlights, there are a lot more new features and user
experience improvements. For a full list, see:
https://linuxcontainers.org/lxc/news/

The release tarball can be downloaded at:
https://linuxcontainers.org/lxc/downloads/


This release will be supported until January 2016 or 2 months after the
next LXC release, whichever comes last.

We therefore still recommend that people using LXC in production
environments where long term support is important stick to LXC 1.0 which
is supported until April 2019 and receives frequent bugfix updates.


St=E9phane Graber
On behalf of the LXC development team

--lZZ4ablUVnt2XgAh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJUy4XVAAoJEMY4l01keS1nUF4QAKL9ebVxcKRMaBN4AEGFSY6k
GGoEuFBMKuZyCZ+SgmQceyfLNkeqA1cp8DeJFAgIaZ1+K8VZAKjRREOjiTzXhs8z
inquvce0fBcMfqqfSJPtQ/wahNrCL/jF9xCZKmmTjloJwruyV2kzIEfKcT6WqeLI
HfN0Lq5S3F9nFKOUd7FTJc34Lsv8K0GildWS8EfRQUoy6IYowbf3iHF1wsfZeLIA
c8hTD1mTn2jhujw7FAKFrSDLT35eO17dJaKSLh0nAGUsgqYqHk1kKLx54maKc6E/
XFP2NTzoJjSQbJdmegIRJeszpnbxmJwVlAkLOpkcNuwzqx7eg1g3XqM+TZME1oeH
DvDY06Qe7IHKL0iUnwZwGDQdnNsqe1bJNKHeDkMNzGGtpZ2Ki3xqEmEtChgN8c+f
PqSa1Qj+8wS1HZI9rUI3RiOzT3s+MLEVRa0nzJpZX9HcJavP4ydoCmulyO5PEJLZ
k4fFkk2nYjwBI5kJgND2N4x6SQ4HkHqXJIhACAt24X0QL7xXre5SRd50hUxX3toY
iuOEUh3cPr2/5pqE4zwBR3Xo4Je6uxk4a1RO+EZszWaA9M+4osVIKYa6UBtRCoHO
Vajeyp4A3mWokq0IQIIKLt4pFdzIZxUGh7tpShOvTbgM52F7PcaUVYEuOcASbVTu
veyk41s5FvDRorgoeKIY
=EJEw
-----END PGP SIGNATURE-----

--lZZ4ablUVnt2XgAh--

--===============8284753705165528597==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8284753705165528597==--
