From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] user_namespaces.7: Record new 340 line idmap limit
Date: Sun, 19 Nov 2017 10:48:44 +0100
Message-ID: <20171119094843.axqozve4trhbdvug__1371.07017585567$1511084935$gmane$org@gmail.com>
References: <20171119012505.1925-1-christian.brauner@ubuntu.com>
	<0b3acf79-dd24-5845-b4f4-6d2f9222a5a6@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6178071239076536907=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <0b3acf79-dd24-5845-b4f4-6d2f9222a5a6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============6178071239076536907==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="omt6r5hzorz6soif"
Content-Disposition: inline


--omt6r5hzorz6soif
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 19, 2017 at 10:00:39AM +0100, Michael Kerrisk (man-pages) wrote:
> Hello Christian,
>=20
>=20
> On 11/19/2017 02:25 AM, Christian Brauner wrote:
> > This patch documents the following commit:
> >=20
> > commit 6397fac4915ab3002dc15aae751455da1a852f25
> > Author: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> > Date:   Wed Oct 25 00:04:41 2017 +0200
> >=20
> >     userns: bump idmap limits to 340
> >=20
> > Since Linux 4.15 the number of idmap lines has been bumped to 340.
> > The patch also removes the "(arbitrary)" in "There is an (arbitrary) li=
mit on
> > the number of lines in the file." since the 340 line limit is well-expl=
ained by
> > the current implementation. The struct recording the idmaps is 12 bytes=
 and
> > quite some proc files only allow writes the size of a single page size =
which is
> > 4096kB. This leaves room for 340 idmappings (340 * 12 =3D 4080 bytes).
> > The struct layout itself has been chosen very carefully to allow for an
> > implementation that limits the time-complexity for the idmap codepaths =
to
> > O(log n). However, I think it's unnecessary to expose this much impleme=
ntation
> > detail to users in the man page. So only mention this in the commit mes=
sage.
> > Furthermore, the comment about the page size restriction is misleading.=
 The
> > kernel sources show that >=3D page size is considered an error.
>=20
> Thanks for the patch and the detailed commit message.
> I've applied the patch, but restored the historical details,
> since users need also to now about older kernel behavior.

Thanks Michael!
Christian

--omt6r5hzorz6soif
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJaEVN6AAoJEHs8OR7+qTYkkUcP/3jDPLBjl6D9K9nBL4BvVDdf
Mnhxl1BF8vEdgqOD73//fzFrbdq+jSoMGu2VzD5KLY2qT/betklxe479tmnktZkx
FU9EJhCwZzeL0Tyc7w3HQgcjfHYHL871v1Gn3PEqtndtjeyieFkKXi4M8gPtz5oL
8OfArrjEFmEfC/uXXq3appK/BehROyoZTpgi6fDB1rjWGcy2rjIztYj9RsfO9mn8
wdb82nNl7tiS39xf9rqgTwKzvmyt1skeGc4L3uDWU8zED3XbxrKyt1FweDyX88Sf
0siZRO97skiahhfKerCJEezAk/wTccNJr2h95ktdS3WaJbDJbFOyXHJwdBTLNfoB
/X9oyeYFKqnH6wIKYBNdY3L987qYgxU3HDk2KBBI6b+lY/oUCydNvrwIjPsIO1hM
zJo3G0ID0wiaw1duDTyFp2s//t/x7LlvdDjbYDeSneYWCn+rqA4CV3jPjg0f6ngU
5mEYOhWXqwvmijc2xx8s69Ax3m501H6I3nvILToRI26LcjrYRafx4UQxpZG/7Gpx
AYEJJwM9tOoX4S0R1v9lUneiPzw9Tl6dKtFc66bUShfistmze3nHnbUIjBkgaE9k
Q397VpId9HynXxkxq4LhDJkpDgwmbybtO+oBF/G3x3ypzecaJ+0g/iHPpiL+ux1h
cy2JKkuzSR8exnVbCOmt
=MtvO
-----END PGP SIGNATURE-----

--omt6r5hzorz6soif--

--===============6178071239076536907==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6178071239076536907==--
