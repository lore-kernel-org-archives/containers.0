From: Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Mon, 4 Mar 2013 06:56:54 +0100
Message-ID: <20130304055654.GE2629__5467.42625670067$1362376665$gmane$org@mykerinos.kheops.frmug.org>
References: <87d2wxshu0.fsf@xmission.com>
	<20130303153726.GA14737@austin.hallyn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0690756284289729072=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130303153726.GA14737-anj0Drq5vpzx6HRWoRZK3AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Nicolas =?utf-8?B?RnJhbsOnb2lz?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============0690756284289729072==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Md/poaVZ8hnGTzuv"
Content-Disposition: inline


--Md/poaVZ8hnGTzuv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> Hi Nekral,
>=20
> This isn't a great urgency, but the final userns kernel support needed
> for this patchset to be useful should land in 3.9, so it isn't that
> far off.  Do you have any objections to/feedback on this set?  Would
> this be possible to get into Debian?


In Debian jessie, maybe, if someone takes shadow over....or if Nicolas
finds some motivation and time to work again on shadow.

In Debian wheezy, definitely no....but this is of no use, as Debian
wheezy will certainly not use a 3.9 kernel.


--Md/poaVZ8hnGTzuv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRNDehAAoJEIcvcCxNbiWor2cQAJbcESYX1DaLwveCwz4GSgd7
lnt8XEOrMHrs2cme8yyocvvgBrhNeb8KQOgUdcLs4MwLyxYkaDD6m0mjKlB+2heG
ud8spEb5G7Jijbr4nZ2GyIyeJzz1qp4aeIM7otl1EixmskO546XkVyYvcvwHtwgl
G5/6gdWUDYlBB7Iytr/+5a0MbRRhMr2tHaT+vrGz1AZT9X9U1s/9fgHoEcrOGYZO
pQ65fhpQNadqshE87nQtX+CRmAXT7zU6aEQMrVEE/UfSpAw2fsB9ld2fqcnn53Gd
JgQ/hYL2MPU60Q8oYvRkUK+Rk+c/D8iqyErX/pldo2bpbE6ThuLIyZ2YYGLgS7hk
xvbUGtHZAHT8uMDI5p57AOQnZb4FPkxF9iT8Xf5glQbrUSjqq1OWFneu7iLfWGiv
ibn+U3JQyv/QAZj/WGDL/d6saTpEzdzhrrS8kmAmhFSjVOCold4oghaPzsX+Qtin
xeuwOLG52rcPACNfLmgF48rnAiCPxK113Mizm0zQ85H2yxjMrqCmjjkE7VMtQNmp
dh7OelqVLKGTf3+tIqt9Q2pmxrEYA//mZEMxEtuf9BfX4DPkdBEV3PkVfPJqZ0x8
O7jhMgxSScynyQZyUXsiwrrl3tfmIcmXF1HNjUnPytJm1p0Ai+vKhHLxbj1VkE8s
OsGQmJzwrc3XELl3OiS6
=xklQ
-----END PGP SIGNATURE-----

--Md/poaVZ8hnGTzuv--

--===============0690756284289729072==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0690756284289729072==--
