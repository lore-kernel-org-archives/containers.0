From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: updated x86_64 eclone() stub
Date: Fri, 4 Dec 2009 18:24:16 +0100
Message-ID: <20091204172416.GN2430@hawkmoon.kerlabs.com>
References: <1259940567.32391.4950.camel@nimitz>
	<20091204160123.GJ2430@hawkmoon.kerlabs.com>
	<1259942713.32391.5061.camel@nimitz>
	<20091204160825.GL2430@hawkmoon.kerlabs.com>
	<1259943689.32391.5111.camel@nimitz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1819407047745815307=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259943689.32391.5111.camel@nimitz>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============1819407047745815307==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-31369-1259947396-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-31369-1259947396-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/12/09  8:21 -0800, Dave Hansen wrote:
> On Fri, 2009-12-04 at 17:08 +0100, Louis Rilling wrote:
> > On 04/12/09  8:05 -0800, Dave Hansen wrote:
> > > > syscall also destroys r11, so it should be added to the clobber lis=
t.
> > >=20
> > > Even though it is a ptregscall?
> >=20
> > The assembly instruction itself destroys r11 (same for rcx).
>=20
> Thanks again for the help, Louis.  How does this look?

Looks ok :)

Thanks,

Louis

>=20
> int clone_with_pids(long flags_low, struct clone_args *clone_args, long a=
rgs_size,
>                  int *pids)
> {
>         long retval;
>=20
>         __asm__  __volatile__(
>                  "movq %5, %%r10\n\t"   /* pids in r10*/
>                  "syscall\n\t"          /* Linux/x86_64 system call */
>                  "testq %0,%0\n\t"      /* check return value */
>                  "jne 1f\n\t"           /* jump if parent */
>                  "popq %%rax\n\t"       /* get subthread function */
>                  "popq %%rdi\n\t"       /* get the subthread function arg=
 */
>                  "call *%%rax\n\t"      /* start subthread function */
>                  "movq %6,%0\n\t"
>                  "syscall\n"            /* exit system call: exit subthre=
ad */
>                  "1:\n\t"
>                 :"=3Da" (retval)
>                 :"0" (__NR_clone3),/* eax */
>                  "D" (flags_low),  /* rdi */
>                  "S" (clone_args), /* rsi */
>                  "d" (args_size),  /* rdx */
>                  "m" (pids),       /* gets moved to r10 */
>                  "i" (__NR_exit)
>                 :"rcx", "r10", "r11", "cc"=20
>         );
>         /*
>          * glibc lists 'cc' as clobbered, so we might as
> 	 * well do it too.  'r11' and 'rcx' are clobbered
> 	 * by the 'syscall' instruction itself.  'r8' and
> 	 * 'r9' are clobbered by the clone, but that
> 	 * thread will exit before getting back out to C.
>          */
>=20
>         if (retval < 0) {
>                 errno =3D -retval;
>                 retval =3D -1;
>         }
>         return retval;
> }
>=20
>=20
>=20
> > Thanks,
> >=20
> > Louis
> >=20
> -- Dave
>=20

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-31369-1259947396-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksZRcAACgkQVKcRuvQ9Q1RlPgCg0S7CQ1t62L7nRDVVi/GG/iBs
oOcAnjpOFPC2NI1yWvlDktZGyB9DILjG
=uWjL
-----END PGP SIGNATURE-----

--=_bohort-31369-1259947396-0001-2--

--===============1819407047745815307==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1819407047745815307==--
