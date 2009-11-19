From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Thu, 19 Nov 2009 22:44:34 +0100
Message-ID: <20091119214433.GD4767@localdomain>
References: <20091119004838.AD278DE0@kernel>
	<20091119095844.GP4379@hawkmoon.kerlabs.com>
	<1258652929.20093.8941.camel@nimitz>
	<20091119212646.GA4767@localdomain>
	<1258666356.20093.9622.camel@nimitz>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8918356529845658848=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258666356.20093.9622.camel@nimitz>
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
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============8918356529845658848==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-2061-1258667018-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-2061-1258667018-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2009 at 01:32:36PM -0800, Dave Hansen wrote:
> On Thu, 2009-11-19 at 22:26 +0100, Louis Rilling wrote:
> > But actually this is even better :D:
> >=20
> >          __asm__  __volatile__(
> >                   "movq %3, %%r10\n\t"           /* pids in r10*/
> >                   "pushq %%rbp\n\t"              /* save value of ebp */
> >                  :
> >                  :"D" (flags_low), /* rdi */
> >                   "S" (clone_args),/* rsi */
> >                   "d" (args_size), /* rdx */
> >                   "r10" (pids)     /* Linux reads its fourth arg from r=
10 */
> >                  );
>=20
> That gives me:
>=20
> clone-lib.c:28: error: matching constraint references invalid operand
> number

?? I know that this syntax works for r8, but I don't remember for r9-r15. I=
 don't
have my handy documentation nearby, so let met check tomorrow (if nobody fi=
nds
before).

Anyway, although not optimal, even your first version should be ok with res=
pect
to placing the fourth arg in r10 (assuming that the compiler keeps it until=
 the
next asm statement of course, which any [future?] code instrumentation of t=
he
compiler could break).

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-2061-1258667018-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksFvEEACgkQVKcRuvQ9Q1RjQACfQN7Jrprapcu7pTqhOYg4OtXt
gy0An2gnkfnVtPhn5/7TnoF6FjkCoG/J
=TQb6
-----END PGP SIGNATURE-----

--=_bohort-2061-1258667018-0001-2--

--===============8918356529845658848==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8918356529845658848==--
