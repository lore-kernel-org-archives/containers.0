From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 4 Apr 2011 17:03:09 -0500
Message-ID: <20110404220309.GA10229__48147.3003667363$1301958231$gmane$org@peq.hallyn.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
	<4D9A00B1.2080002@cs.columbia.edu>
	<1301953409.31531.130.camel@tp-t61>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2250250841164908603=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1301953409.31531.130.camel@tp-t61>
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
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============2250250841164908603==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8t9RHnE3ZwKMSgU+"
Content-Disposition: inline


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Mon, 2011-04-04 at 13:32 -0400, Oren Laadan wrote:
> > From the technical point of view it *is* a big problem:  there are
> > very good reasons why we chose a certain design.=20
> >=20
> > If Natahan is suggesting in-kernel tree creation as a temporary thing
> > to simplify the code for review - then, given that this patch handles
> > a single process, doing so add lots of unnecessary code, all of which
> > in the kernel.
> >=20
> > If this is the beginning of a permanent approach, then it is totally
> > incompatible with what we have done so far, and severely restricts=20
> > the kind of use--cases of the project, potentially making it too
> > unattractive for many natural adaptors, like HPC users. Sorry, nack.
>=20
> It's not a stopgap measure to "ease review" or whatever; recreating the
> task tree in-kernel is a fundamental - and simplifying - part of the

I hadn't gotten to that part yet, so I'm on the fence.

The API for starting a checkpoint, that I'm not on the fence on.

-serge

--8t9RHnE3ZwKMSgU+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNmkAdAAoJEHmllQITXQdFgPgH/0Z7FN38XsLCtBToSwRdoSLf
F6XIBNg26GXZRv45OCAZTMkcM53FqdJboK9fDGKZNAWH40i+koGJ9xOj/Q5GQG+f
wmg32DQw6+GuvInAnOgxQrpne7AA1vJyHcDvZvKWzQqL7Dtok7amJGqBvnXMRd3l
z78LvbNU++4F7dP4Uq0crC4yneztHwQ6S8/VaQGD9AReTMFTt4a289gFSjHLUHvg
95tDzNe/U5KP7pui9Qk9J0TVH3Udptp/JcSzncOkzlhNu53FZYus3dZ3eOgB04cl
IrzNMeA/KfTFipMON6smWPQePIaL0x4vz7eRMASCvKFadOsVaCPg37IBVeiN25k=
=ldML
-----END PGP SIGNATURE-----

--8t9RHnE3ZwKMSgU+--

--===============2250250841164908603==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2250250841164908603==--
