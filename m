From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Fri, 29 Apr 2016 08:38:48 -0700
Message-ID: <1461944328.2311.10.camel@HansenPartnership.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7814847492463224874=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160428230045.GS22888-q4NCUed9G3sTnwFZoN752g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "W. Trevor King" <wking-vJI2gpByivqcqzYg7KEe8g@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============7814847492463224874==
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-yBfO5sB/Vk/TzoqZ4KsO"


--=-yBfO5sB/Vk/TzoqZ4KsO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-28 at 16:00 -0700, W. Trevor King wrote:
> On Thu, Apr 28, 2016 at 03:02:08PM -0700, James Bottomley wrote:
> > /etc/usernamespaces
> >=20
> > and the format be :::
> >=20
> > =E2=80=A6
> >=20
> > If this sounds OK to people, I can code up a utility that does this,
> > which should probably belong in util-linux.
>=20
> This sounds a lot like shadow's newuidmap and newgidmap [1,2,3].
>=20
> Cheers,
> Trevor
>=20
> [1]: https://github.com/shadow-maint/shadow/commit/673c2a6f9aa6c69588f4c1=
be08589b8d3475a520
> [2]: http://man7.org/linux/man-pages/man1/newuidmap.1.html
> [3]: http://man7.org/linux/man-pages/man5/subuid.5.html

I think that mostly works.  No-one's packaging it yet, which is why I
didn't notice.  It also looks like the build dependencies have vastly
expanded, so I can't get it to build in the build service yet.

It looks like the only addition it needs is the setgroups flag for
newgidmap, which the security people will need, so I can patch that.=20
 Plus it's trying to install newgidmap/newuidmap as setuid root rather
than cap_setuid/cap_setgid, but that's fixable in the spec file.

James

--=-yBfO5sB/Vk/TzoqZ4KsO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXI4ATAAoJEDeqqVYsXL0MHpUH/3K2v2wf1jZFN81sfFV2qADF
Nho6BbShZG/HyfYEjeukaxiq1IVQIyfCPGsArNO03Ld0ouAILvLzGKFkI2yIGM5C
i0/kwNyfFv1jHuj8MoW18lpypXmzQJNIcSi90yokJazSdDDsVZ9dsGDuW9+Q/FSh
8XZpY2oXtlkJT4FOYNr96YHS3fHo2iZY/R5CATDCmzmHS4UWcFbE4y0ko77vvIwf
aOaZ7vZLQ6FhehuT8sA2XAARTUccdqkw2XRlHOh28vbGWsWAwkPymqPkZ6R1mY19
aQWRZG0iegI5JT1jVfb37ADapDdlzv+jGpfA5cuXr/7B37F14q4I1LUHYwVvJns=
=YK2/
-----END PGP SIGNATURE-----

--=-yBfO5sB/Vk/TzoqZ4KsO--


--===============7814847492463224874==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7814847492463224874==--
