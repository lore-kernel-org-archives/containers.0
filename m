From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [PATCH 05/14] userns: Convert hostfs to use kuid and kgid where
	appropriate
Date: Sun, 23 Sep 2012 23:59:40 +0200
Message-ID: <505F864C.2000103__29216.5551604286$1348438011$gmane$org@nod.at>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<1348187330-6616-5-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4820958477022345105=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348187330-6616-5-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============4820958477022345105==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig670CD0EC8234AD49ECC064C4"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig670CD0EC8234AD49ECC064C4
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 21.09.2012 02:28, schrieb Eric W. Biederman:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>=20
> Cc: Jeff Dike <jdike-OPE4K8JWMJJBDgjK7y7TUQ@public.gmane.org>
> Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---

Looks sane to me.

Acked-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>

BTW: How you do test your user namespace patches?
Is there a generic way to compare/verify uids within a namespace vs. the =
initial namespace?

Thanks,
//richard


--------------enig670CD0EC8234AD49ECC064C4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQEcBAEBAgAGBQJQX4ZRAAoJEN9758yqZn9eZkMH/3PMootkUYID2/hTZXChfFpL
T7/YE7JSuJh9Eg3xRPVxkgOOmNA/T5lziEkjsclRhcAEWD3HBs+g1AEQyRWVtJIa
kjbY/b1dnK9QM2/c8gAEaX5YWGsP1aPsHS5TIeP/dIn175MH59aA2tN/YfLPkYAm
kKKDEE31YAwb3jKyDN/dxS2XRleNeYIoUNebF76vAqFdVXjDyfi6ST/0VltVekRX
FHEo+m4xVORD0J6r5jGunTopVVPxhSSGFy5ZlcxV5gPLr4L4LC+5QEdbpLyQd87g
iVPZIPp+hw4yCMEACfbjlGNVnUZTIwvtR2DTUxiiqZKBbgFc5xNF/RiJ7j8z6Xk=
=trgK
-----END PGP SIGNATURE-----

--------------enig670CD0EC8234AD49ECC064C4--

--===============4820958477022345105==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============4820958477022345105==--
