From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 4 Apr 2011 13:51:20 -0500
Message-ID: <20110404185119.GB4782__9139.50145845792$1301943146$gmane$org@peq.hallyn.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
	<20110404104119.78189678.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8075801920335736719=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110404104119.78189678.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============8075801920335736719==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yEPQxsgoJgBvi8ip"
Content-Disposition: inline


--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Mon, 4 Apr 2011 11:27:53 -0500 "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wr=
ote:
>=20
> > Andrew (Cc:d), did you see this thread go by, and it did it look
> > in any way more palatable to you?  Have you had any thoughts on
> > checkpoint/restart in the last few months?  Or did that horse quietly
> > die over winter?
>=20
> argh, it was the victim of LIFO.
>=20
> All I can say at this stage is that I'll be interested next time it
> comes past, sorry.

Thanks, that's good to know.

As you know, we started with a minimal patchset, then grew it over time
to answer the "but how will you (xyz) without uglifying the kernel".
Would you recommend we go back to keeping a separate minimal patchset,
or that we develop on the current, pretty feature-full version?  I'm not
convinced believe there will be bandwidth to keep two trees and do both
justice.

thanks,
-serge

--yEPQxsgoJgBvi8ip
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNmhMnAAoJEHmllQITXQdFz4kIAJnRFp4UJ/LE2ycg/vzD+HW8
pCygLgGOayTmoZqyms5T51P3ObbRYY98L3pUMMExc9/kQ8bdeWnH5s7D93QzTHYP
7+PxCW/c3jA8Nc9BOnIImMelUhFCcjyp0YyAHbMQN8Ej5DuAJOrgjwpyAeQRbhUR
rR74y8rlOFB+4FEDOpLwnM0xawfTPyW4VB6Vk5/8VjkEaDvcWB+/cuBboMuA8uYO
gqH7v1EyJxaeuJ0nAjrnvgDXyCfpWJNmiVVlS/B+x8w+CGRxcd8WBsZ/UU7bAGen
NCw17QyVsaAn6KwBU8YZeKZLto39kINHwFyDTjcm6N0EuCQ1JTiRvOiXUO9phRE=
=VIBb
-----END PGP SIGNATURE-----

--yEPQxsgoJgBvi8ip--

--===============8075801920335736719==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8075801920335736719==--
