From: Jaegeuk Kim <jaegeuk.kim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH review] f2fs: Don't assign e_id in f2fs_acl_from_disk
Date: Wed, 26 Dec 2012 11:48:26 +0900
Message-ID: <1356490106.16178.146.camel@kjgkr>
References: <87obhh63wz.fsf@xmission.com>
Reply-To: jaegeuk.kim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2763767893169170479=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <87obhh63wz.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Namjae Jeon <namjae.jeon-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Amit Sahrawat <a.sahrawat-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============2763767893169170479==
Content-type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary="=-BrLpLRpAfyc54VAPcTGn"


--=-BrLpLRpAfyc54VAPcTGn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

2012-12-25 (=ED=99=94), 16:41 -0800, Eric W. Biederman:
> With user namespaces enabled building f2fs fails with:
>=20
>  CC      fs/f2fs/acl.o
> fs/f2fs/acl.c: In function =E2=80=98f2fs_acl_from_disk=E2=80=99:
> fs/f2fs/acl.c:85:21: error: =E2=80=98struct posix_acl_entry=E2=80=99 has =
no member named =E2=80=98e_id=E2=80=99
> make[2]: *** [fs/f2fs/acl.o] Error 1
> make[2]: Target `__build' not remade because of errors.
>=20
> e_id is a backwards compatibility field only used for file systems
> that haven't been converted to use kuids and kgids.  When the posix
> acl tag field is neither ACL_USER nor ACL_GROUP assigning e_id is
> unnecessary.  Remove the assignment so f2fs will build with user
> namespaces enabled.
>=20
> Cc: Jaegeuk Kim <jaegeuk.kim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Cc: Namjae Jeon <namjae.jeon-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Cc: Amit Sahrawat <a.sahrawat-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Jaegeuk Kim <jaegeuk.kim-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

--=20
Jaegeuk Kim
Samsung

--=-BrLpLRpAfyc54VAPcTGn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJQ2mV6AAoJEEAUqH6CSFDSb6wP/js1kKHJOpb/bPBGoLD012nh
5iRGPzkr227wiDMaDf/+eqkdTQhDjwCuHzfsWSykWkSKN6pdUIf40GI8DNLB3sbT
7lwNEU9Ek7DtL95NLrYDcyf3ZejCh33us616icnuGFCmRrct5khdqUbu0Aup3Bwu
bdA2lTJJrtwIuW1Adra0VZBJwi/3lDUSTd2i4tfO6Dx1nR4hnsxqUBp6lqvQDur8
9g+ae/fbteWjvWki89Mzzgtg3gDJtYZC3xiUOnw9QyqEh6mI3xaVQKiqb815mlw0
Rwc7TH06RoHKi3quCYfzCy0kocoRzKa4ydqmkGJAjsSSDMxwswWgNHgziUdaU2ZX
03hjz/+Wk8rgaG5vr9rUYctjznACYD2gyqqxb7xh1nbPOE/unKJXeeF6pxnGeQCz
Kce4ezDOgrVQbby42N+bNA/B+u+VtLN76fu9J1sUbKyp8PcSIV/Wf+i5hc2svc9x
78lmRKaLqP0LS4rDibyHmT4SoAGvEsxinhhMsStPw12mXCrGjc15n2cmbqBHFiNt
PSb757BXo6WPQPavo1ypgLS/BWfcsQzHXAR385lqIF+wZCpT0UDoubwvBNWkHjrw
77dS3LGER7nSZf6nEYI4NRFtRtNtpgYywrB9hCZQtNWu8Od6y7qUg77o/OGEzXJa
4zPucCNJ3CfOXO0YJy0Q
=+htg
-----END PGP SIGNATURE-----

--=-BrLpLRpAfyc54VAPcTGn--


--===============2763767893169170479==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2763767893169170479==--
