From: "W. Trevor King" <wking-vJI2gpByivqcqzYg7KEe8g@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Thu, 28 Apr 2016 16:00:46 -0700
Message-ID: <20160428230045.GS22888@odin.tremily.us>
References: <1461880928.2307.48.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5175475621015650954=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1461880928.2307.48.camel-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============5175475621015650954==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="A/Qc/oxTFhy3MK1v"
Content-Disposition: inline


--A/Qc/oxTFhy3MK1v
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 28, 2016 at 03:02:08PM -0700, James Bottomley wrote:
> /etc/usernamespaces
>=20
> and the format be <user>:<start>:<length>:<flags>
>
> =E2=80=A6
>=20
> If this sounds OK to people, I can code up a utility that does this,
> which should probably belong in util-linux.

This sounds a lot like shadow's newuidmap and newgidmap [1,2,3].

Cheers,
Trevor

[1]: https://github.com/shadow-maint/shadow/commit/673c2a6f9aa6c69588f4c1be=
08589b8d3475a520
[2]: http://man7.org/linux/man-pages/man1/newuidmap.1.html
[3]: http://man7.org/linux/man-pages/man5/subuid.5.html

--=20
This email may be signed or encrypted with GnuPG (http://www.gnupg.org).
For more information, see http://en.wikipedia.org/wiki/Pretty_Good_Privacy

--A/Qc/oxTFhy3MK1v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJXIpYdAAoJEAPqygegUbGsalMP/iYdKxYkyqyQXyooApfm1r8g
s4TpqZo/TemduERXf0gM2upqKPhOQskymwUiEKVgkDPKmL58IlSX67pHzIPWXmrO
hj8uQkLXPsIfdObXsTEyy/QGWQNNOGRJHS2xuyWULVkEbl2niukd4Acq22jYDpi4
4OA08K9FtM6QTeNc5yHuW1r+4+qVFlrkjXTC08cvWPBnheMj2Jn6Zp8RKQDYFUdQ
frbpmw/s8reXz1nlIzk3XKymuk5usAG89upqcjKo78a3QQz611dUcmk24rqT0a0A
YTf18n18JgnwHTDJ6+jvy50D+7L/LRSg802asYmtyeYSC5rdIZSE4g+sIOYwonZP
J4kOAeSJ+K/GRcewG4fOrDs2Tk8TsgaEYS+oWXFjHVDUhXhOtiC5GdKejtb2Ygfu
Mw8t3hQXYq3A7kTzCfQRXBnV69/4qHXmMCEAX0Bk9RQ2hWr1Gjfc4CMakjleCVEY
9dlPEZDNiSXVAP2r1U6CNvYxk/Ifbo4TReHDq/TtkjLf7rxE/XVV34cHtFysJuD0
qTcP3tfmWNShg+QM1GEdzzNqs0ISzDQ7CgGm4Yl1xQsSXWs/Kw4WKvLJJDPpsmfp
zaC4G2NrPaVZxjrfch9UskKJpbUylKlm3DOLoA9USrySkdnFF8sy5mw9U/07PN6F
e0furFL0O9cSccumSRxM
=07bX
-----END PGP SIGNATURE-----

--A/Qc/oxTFhy3MK1v--

--===============5175475621015650954==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============5175475621015650954==--
