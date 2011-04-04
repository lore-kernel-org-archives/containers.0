From: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 04 Apr 2011 19:16:50 -0400
Message-ID: <31800.1301959010__2087.51542163572$1301959378$gmane$org@localhost>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
	<20110404104119.78189678.akpm@linux-foundation.org>
	<20110404185119.GB4782@peq.hallyn.com>
	<20110404124222.fd5eb85b.akpm@linux-foundation.org>
	<20110404215511.GA27628@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1073024754863783191=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Mon, 04 Apr 2011 14:55:11 PDT."
	<20110404215511.GA27628-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============1073024754863783191==
Content-Type: multipart/signed; boundary="==_Exmh_1301959009_4775P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit

--==_Exmh_1301959009_4775P
Content-Type: text/plain; charset=us-ascii

On Mon, 04 Apr 2011 14:55:11 PDT, Matt Helsley said:

> Now we're back with a new minimal patch set. You're asking us to do the same
> thing and expect different results -- stack more patches on top and expect to
> get it reviewed. OK, but what reason do we have to believe this time will be
> any different?

Has the terrain changed any since last time? In particular, ISTR a bunch of
activity in namespace support since last time - does that change what your
patch set needs to do?

--==_Exmh_1301959009_4775P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNmlFhcC3lWbTT17ARAi5cAJ4zBClgnu1wJpFmOWFE9gqFpt84wQCgwcdX
gwYPaJN8orq6V/JzfnUsD8w=
=yJjo
-----END PGP SIGNATURE-----

--==_Exmh_1301959009_4775P--


--===============1073024754863783191==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1073024754863783191==--
