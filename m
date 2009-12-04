From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: updated x86_64 eclone() stub
Date: Fri, 4 Dec 2009 17:01:23 +0100
Message-ID: <20091204160123.GJ2430@hawkmoon.kerlabs.com>
References: <1259940567.32391.4950.camel@nimitz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2273260147060884818=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259940567.32391.4950.camel@nimitz>
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

--===============2273260147060884818==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-29050-1259942423-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-29050-1259942423-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/12/09  7:29 -0800, Dave Hansen wrote:
> This more closely resembles what glibc does.
>=20
> The last version had a push/popq %ebp.  But, after looking at the glibc
> code, I believe this to be unnecessary on 64-bit.  Suka also pointed out
> that we were neglecting to pull the subthread's function argument off
> the stack.
>=20
> I also changed the register being used  for the subthread variable to be
> rax.  This is just to more closely resemble the glibc code.  It doesn't
> hurt to use it this way mostly because we overwrite it for the exit
> syscall anyway.
>=20
> int eclone(long flags_low, struct clone_args *clone_args, long args_size,
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
>                 :"rbx", "rcx", "r8", "r9", "r10"

Why is rbx in the clobber list? It's not used at all.

r8 and r9 can be removed from the clobber list, since they can only be clob=
bered
when calling the subthread, and then exit() is called without returning to =
C.

syscall also destroys r11, so it should be added to the clobber list.

Libc also adds "cc" to the clobber list. I'm not sure that this matters tho=
ugh.

So the result could be:
                 :"rcx", "r10", "r11", "cc"

Thanks,

Louis


>         );
>=20
>         if (retval < 0) {
>                 errno =3D -retval;
>                 retval =3D -1;
>         }
>         return retval;
> }
>=20
> -- Dave
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-29050-1259942423-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksZMlMACgkQVKcRuvQ9Q1QNmwCff1MT6yYL7iwUUhNS55x18Yw2
ExkAn175cyemUH/lrXlUWAj1uNiR4qGW
=OJZT
-----END PGP SIGNATURE-----

--=_bohort-29050-1259942423-0001-2--

--===============2273260147060884818==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2273260147060884818==--
