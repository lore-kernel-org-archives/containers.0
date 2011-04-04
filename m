From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 4 Apr 2011 16:53:44 -0500
Message-ID: <20110404215344.GC7873__36951.9884851345$1301954200$gmane$org@peq.hallyn.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
	<1301952046.31531.112.camel@tp-t61>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2444410523913068199=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1301952046.31531.112.camel@tp-t61>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============2444410523913068199==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EeQfGwPcQSOJBaQU"
Content-Disposition: inline


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> >   If it can gain traction
> > better than linux-cr, that'd be one thing.  But given the amount of
> > review and testing the other tree has gotten
>=20
> How much traction do you think linux-cr has?  It doesn't seem any closer
> to mainline than it was a year ago, and it barely has any users.  I
> don't think posting this little proof-of-concept patch set is disrupting
> linux-cr's progress toward mainline.

No, I agree with you there.  I appreciate your attempt, and it would have
been great if it had worked.  My comments are only about going forward
=66rom today onward.  And, going forward, I don't believe that this API
simplification (and regression in functionality) is going to pay off
the way you'd hoped.

> > I'd really prefer that everyone was using the same tree, and sending
> > any and all patches which they need, no matter how ugly they fear
> > they are, upstream.  To that end, I think it would be appropriate
> > for you or Dan to get write access to Oren's tree or to move to a
> > newly cloned copy of his tree to which one of you has acces.
>=20
> Oren and I disagree on some fundamental aspects of how kernel c/r should
> be implemented (hence this patch set), so I'm not sure how this would
> work.

Ok, not you then :)

I'm willing to do it, but since I won't be able to spend full time
reviewing it, I'd have to set some ground-rules, like:  I"ll pull in
any patch as soon as it has an ack from (Oren, Dan Smith, Matt
Helsley) which is not also from the submitter.  Any regression in
automated tests cause the patch which caused it to get kicked out.

If you want to discuss the technical advantages of not allowing a task
to call checkpoint on another task, let's start a new thread to do that.
So far, I'm against it.

thanks,
-serge

--EeQfGwPcQSOJBaQU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNmj3oAAoJEHmllQITXQdF/n8IAJnKkl3LVEM673EZco3gqEqY
rAP+CeE0aH1KrOTcscQ841wAm5JqARCZ3wxC41SjvkBtxX3euw/3y16c4ANaIFLU
5jpAqFJ2Yqt6V7AygURi1UX+IirN2AVgIKGycuVbdbeqmM/iAQGZbdWASgtb8K/3
kzuMqsbaU6Kdncw21061HXOVPeUZ9DdlYVr5n0+uE8BHrlNvABlI/vy/yuQZkKbW
IhLZu39CVDSy8QvlVCDfHR9GOXDVB/NQNbdvLHfuPPW0b1MQJfqF7rY8rTiMQXjP
d6Dg4jcGpQUOJ7QvskvOQ6nWGKjv/4TInIQ05XRhHg0WwCUrTxAbLY68ABeD0O8=
=kp7r
-----END PGP SIGNATURE-----

--EeQfGwPcQSOJBaQU--

--===============2444410523913068199==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2444410523913068199==--
