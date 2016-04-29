From: "W. Trevor King" <wking-vJI2gpByivqcqzYg7KEe8g@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Fri, 29 Apr 2016 11:34:05 -0700
Message-ID: <20160429183404.GE22888@odin.tremily.us>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
	<20160429155303.GA8900@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3891087660691269030=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160429155303.GA8900-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============3891087660691269030==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ayEWcOB1VvXmLrn2"
Content-Disposition: inline


--ayEWcOB1VvXmLrn2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 29, 2016 at 10:53:03AM -0500, Serge E. Hallyn wrote:
> Quoting James Bottomley:
> > I think that mostly works.  No-one's packaging it yet, which is why I
>=20
> https://packages.debian.org/jessie/uidmap
> https://launchpad.net/ubuntu/yakkety/+package/uidmap
> http://rpm.pbone.net/index.php3/stat/45/idpl/28763248/numer/1/nazwa/newui=
dmap

On the other hand, Gentoo is waiting on a clean release tarball [1].
It looks like 4.3-1 was missing a clean autoreconf [2]?  Has anything
been pushed since?

Cheers,
Trevor

[1]: https://bugs.gentoo.org/show_bug.cgi?id=3D580432#c3
[2]: https://lists.alioth.debian.org/pipermail/pkg-shadow-devel/2016-March/=
010924.html
     Subject: [Pkg-shadow-devel] new shadow release candidate
     Date: Tue Mar 22 18:58:55 UTC 2016

--=20
This email may be signed or encrypted with GnuPG (http://www.gnupg.org).
For more information, see http://en.wikipedia.org/wiki/Pretty_Good_Privacy

--ayEWcOB1VvXmLrn2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJXI6kaAAoJEAPqygegUbGszy4P/1IvQ91zflgU1SYT9qbKP2pj
XddYYpW+mqsnJY4WVsVxRzVrSxcEbns4kdGvoKiu92MEsoYtZzYIufY4uR/Ef5+L
tDwyjx3bHGBq4yDUHUsxjLF6Z7GHNrnu1X+71rL12Rh13PoNZhZq8BS9t9nVGB7F
gW80obPL401pI9WKVsaK3IAY9VrSN3WKCm6dK6ZuYVsajFEoq8S8hJETAg5LfpIQ
4jyzziSHaf5nLrV7V+D01ATDyrR2nTRJP31lLXGQNP2ox+qm1WU6jUdruLcoOvTP
XHOHzfBoUCnOMVcxYlhIAggXz+OGeCBV7dnnOurcUiqsD8A9YOBLdFWcrKPE7QPw
IommBAHsB2qHQeZRvHypnhDISQTn5gAKd7tgh/EqYoWCrwlnIVRKL0fLlcER2/XJ
mtENIHmnCYI1I97yo4QZZ06PAqm1/fjvLludCOO0dCT+3LKsrDtYegvrN1RFjnz3
+Zb61VgpaVOjNfUBIwFwKGjPgEVI03iPvtHqhckVklssXDM4jfsuwp7aP0u02IGe
XUmv0ibNZSa6xS69na9fUJlstIr1sjJv+h0Au6BoD2SVmvgc1Tlkrd42wnML1IHW
vqtE9KeMWFXBs+c1XuRqa/vpxsu5/UZsVPuWhWGwX8mQ05eiHPve7ynO79pGuKQV
NjvgyZ6CH9XA/srqqkv0
=Xr/4
-----END PGP SIGNATURE-----

--ayEWcOB1VvXmLrn2--

--===============3891087660691269030==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3891087660691269030==--
