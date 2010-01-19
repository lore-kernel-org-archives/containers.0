From: "Michael H. Warfield" <mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org>
Subject: Re: [Devel] Re: LXC container, unmounting unneeded mount points
	(from the container namespace)
Date: Tue, 19 Jan 2010 11:52:07 -0500
Message-ID: <1263919927.9283.21.camel@localhost>
References: <8e04b5821001080608w47b0529dhcd6f8a26e38f24e0@mail.gmail.com>
	<4B473E89.1040200@free.fr>
	<8e04b5821001080625j22517f1i22ec3495d8d1e53b@mail.gmail.com>
	<4B4742A8.1000708@free.fr>
	<8e04b5821001080659y3c4bad1akbaa1e355bb1f730f@mail.gmail.com>
Reply-To: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4844531834567717331=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8e04b5821001080659y3c4bad1akbaa1e355bb1f730f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: "Ciprian Dorin, Craciun" <ciprian.craciun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============4844531834567717331==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-CRn9N+atYhafTMTH5BUv"


--=-CRn9N+atYhafTMTH5BUv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-01-08 at 16:59 +0200, Ciprian Dorin, Craciun wrote:=20
> On Fri, Jan 8, 2010 at 4:35 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> w=
rote:
> > Ciprian Dorin, Craciun wrote:
> >>
> >> On Fri, Jan 8, 2010 at 4:17 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org=
>
> >> wrote:
> >>
> >>>
> >>> Ciprian Dorin, Craciun wrote:
> >>>
> >>>>
> >>>>   Hy all!
> >>>>
> >>>>   Today I've started to play with the LXC containers, and I've got a
> >>>> question: when starting a container (with it's own mount point
> >>>> namespace), and I do a `cat /proc/mounts` I also see the mount point=
s
> >>>> from my host system.
> >>>>
> >>>>   So the question is: how can I force `lxc-create` to remove any
> >>>> uneeded mount points (maybe all)?
> >>>>
> >>>>
> >>>
> >>> Committed today :)
> >>>
> >>>
> >>> http://git.lab.toulouse-stg.fr.ibm.com/?p=3Dlxc.git;a=3Dcommit;h=3Ded=
83715df7666879116d1657b1dd54a8fc6513f6
> >>>
> >
> > Oops, this one:
> >
> > http://lxc.git.sourceforge.net/git/gitweb.cgi?p=3Dlxc/lxc;a=3Dcommit;h=
=3Dbf601689a9e0cea1ceaf17e4f7f853f5392c2827
>=20
>=20
>     Thanks, it works as expected. (It seems that it was in the
> repository... :) )
>=20
>     And one question (off-topic): is there any mailing list dedicated
> to LXC users? (I guess that this mailing list is for the developers
> only, or?)

There is now...  Just created the other day.

The following is some basic information about your mailing list.

The web page for users of the mailing list is:=20

    https://lists.sourceforge.net/lists/listinfo/lxc-users

There is also an email-based interface for users (not administrators)
of the list; you can get info about using it by sending a message
with just the word `help' as subject or in the body, to:

    lxc-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

> Ciprian.

Mike
--=20
Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
   /\/\|=3Dmhw=3D|\/\/          | (678) 463-0932 |  http://www.wittsend.com=
/mhw/
   NIC whois: MHW9          | An optimist believes we live in the best of a=
ll
 PGP Key: 0x674627FF        | possible worlds.  A pessimist is sure of it!

--=-CRn9N+atYhafTMTH5BUv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEVAwUAS1XjN8DrlnVnRif/AQKQfwgAqqphVKre2gqo1PKe2KVvF4d9MsErO+nx
xdFiSp2uqBEeB4UISyZRSkhg5R9iJV/ekcGaUw4EI9xVYbxwASvMFE2YhfbJWzhn
lFJvbI7pPwZRW2NQRUEJhLWtUoOW8bQsrqD+NMWf9GJPAgDaNYJ5LRYD8jjtINUg
E85hOR9kfHdwEXgoFdfpEqKFgv6uYCRPYz3tBu6cXztGY+VkcnWD9BM9IN4N3hev
FnpRyKMTpi8fDHgJMLDlzZjxLEWYYdriav2vygUqHCJyoJK2SKHH80vWg795szgf
Ym+M8iQS4XwZINq1N9QXOao62uG+mBM3wigzimO2NkBPw86UpHZ+BQ==
=1iRT
-----END PGP SIGNATURE-----

--=-CRn9N+atYhafTMTH5BUv--


--===============4844531834567717331==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4844531834567717331==--
