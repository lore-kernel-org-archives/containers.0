From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [lxc-devel] RFC: Device Namespaces
Date: Tue, 3 Sep 2013 15:35:34 -0400
Message-ID: <20130903193534.GE3104__36628.9925449111$1378237494$gmane$org@castiana>
References: <CAA4jN2aw4zEW=UfKCyqaOvXnbiRb_J9srfCn4OXTFzc6vWBM4A@mail.gmail.com>
	<521F9BBE.2070505@amacapital.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0660383653860012236=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <521F9BBE.2070505-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============0660383653860012236==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="JBi0ZxuS5uaEhkUZ"
Content-Disposition: inline


--JBi0ZxuS5uaEhkUZ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 29, 2013 at 12:06:38PM -0700, Andy Lutomirski wrote:
> On 08/22/2013 10:43 AM, Oren Laadan wrote:
> > Hi everyone!
> >=20
> > We [1] have been working on bringing lightweight virtualization to
> > Linux-based mobile devices like Android (or other Linux-based devices w=
ith
> > diverse I/O) and want to share our solution: device namespaces.
>=20
> Have you looked at systemd-logind?  It seems to do something similar.

logind can be used to know the list of existing user sessions and which
have console access, it also creates and to some extent manages cgroups
but it doesn't do anything that the device namespace would at the kernel
level.

The main benefit from having a device namespace in the kernel would be
to only get the uevents and device access for devices that are either
owned or shared with the container. Being able to have fake devices
replace some of the standard ones would also be nice to have.

--=20
St=E9phane Graber
Ubuntu developer
http://www.ubuntu.com

--JBi0ZxuS5uaEhkUZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBCgAGBQJSJjoGAAoJEMY4l01keS1n4AgP/2hPVARn1h8XjNPR+PKBebbf
Iu1VS5yuAr7UZ+4HsBhqESynBHEcyswMRTQQstOF5yOQVVGgg10RZuJB0Lgq3uE5
rj8gZf9CCD2fBvB4NR3IdcGoDiqgGlg8O8+CnIoExZP7iGHqujvpUWSLEfbLTknK
v6A7BP8eabQBsaVtjsSXj8v+OU4dz4BGlI6pMjplX350sPNm/tpJE6KIrmvXNzW1
uIP7NTCuwZ2wSDf7M7MC+vgPmjFDBxYJDwJdaveAY++H0esVXzd2yhxPL69o2cqL
SQ9+Mbs+MM6rKWulEV7oRVP4F8OkjoLyZVVr/sTz9m24lFK3xDAbxmgzT9cz7H7b
XvPfe+Ji6/cjH9Khu2eF03ReCk4lnUMCS3ZgzbJN3wsn3DbGPkQoo6viFjQiFCIs
GiDQu96xLH5a6YMsglALhxUrXynosaI6lsEZAVjHuRNeMgLDT/47iRsaWCjznf6z
Xll8zdf/945/Q0LznCL/4u0dHTF6leq5oVUZ0gYAfE+I9HHN4FFqeoc/D/HxZJj4
y4+fEOtJDCYaTOB7pB7N7oM2CrcKaVyLJfm2SaReOnfeeTu0AwJWmhT3aRGKRPtU
z2NsBJJWVbx9rAEBVGj+P/buNxatfYHclvypLQmyC/xE7UitEYCXh7LvW959ZO5b
Nm4YOjSMSPu523ck6wLz
=xu29
-----END PGP SIGNATURE-----

--JBi0ZxuS5uaEhkUZ--

--===============0660383653860012236==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0660383653860012236==--
