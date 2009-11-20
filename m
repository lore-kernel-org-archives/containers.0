From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Fri, 20 Nov 2009 10:31:24 +0100
Message-ID: <20091120093124.GR4379@hawkmoon.kerlabs.com>
References: <20091119004838.AD278DE0@kernel>
	<20091119095844.GP4379@hawkmoon.kerlabs.com>
	<20091120072914.GA4291@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5843416159564629096=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091120072914.GA4291-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============5843416159564629096==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-10363-1258709427-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-10363-1258709427-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 19/11/09 23:29 -0800, Sukadev Bhattiprolu wrote:
> Louis Rilling [Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org] wrote:
> | >=20
> | >         __asm__ __volatile__(
> | >                  "syscall\n\t"  /* Linux/x86_64 system call */
> | >                  "testq %0,%0\n\t"      /* check return value */
> | >                  "jne 1f\n\t"           /* jump if parent */
> | >                  "popq %%rbx\n\t"       /* get subthread function */
> | >                  "call *%%rbx\n\t"      /* start subthread function */
> | >                  "movq %2,%0\n\t"
> | >                  "syscall\n"            /* exit system call: exit sub=
thread */
> | >                  "1:\n\t"
> | >                  "popq %%rbp\t"         /* restore parent's ebp */
> | >                 :"=3Da" (retval)
> | >                 :"0" (__NR_clone3), "i" (__NR_exit)
> | >                 :"ebx", "ecx", "edx"
> | >                 );
> |=20
> | 2. You should probably not separate this into two asm statements. In pa=
rticular,
> |    the compiler has no way to know that r10 should be preserved between=
 the two
> |    statements, and may be confused by the change of rsp.
> |=20
>=20
> Don't know enough asm, but can we leave them as two asm statements if we
> add all registers with parameters to the clobbered list ? The i386 code t=
hat
> Dave is referring to adds 3 (%ebx, %ecx, %edx) to the clobbered list, but=
 is
> the missing the fourth, %edi.

No. Nothing prevents the compiler from instrumenting the code and overwriti=
ng
registers between the two statements. Moreover I don't see the point of
separating this in two statements. To me it looks weird to separate input
registers setup from syscall call.

The clobbered list just lets the compiler know that those registers may be
overwritten by the asm instructions, so that the compiler should not rely o=
n the
contents of those registers after the asm statement. But as soon as the
statement is executed, the compiler can use the clobbered registers again.

Louis

>=20
> Sukadev
>=20
> | 3. r10 and r11 should be listed as clobbered.
> |=20
> | 4. I fail to see the magic that puts the subthread function pointer in =
the
> |    stack.
> |=20
> | 5. Maybe rdi should contain the subthread argument before calling the s=
ubthread?
> |=20
> | 6. rdi, rsi, rdx, rcx, r8 and r9 should be added to the clobber list be=
cause of
> |    the call to the subthread function.
> |=20
> | 7. rsi could be used in place of rbx to hold the function pointer, whic=
h would
> |    allow you to remove ebx from the clobber list.
> |=20
> | 8. I don't see why rbp should be saved. The ABI says it must be saved b=
y the
> |    callee.
> |=20
> | 9. Before calling exit(), maybe put some exit code in rdi?
> |=20
> | >=20
> | >         if (retval < 0) {
> | >                 errno =3D -retval;
> | >                 retval =3D -1;
> | >         }
> | >         return retval;
> | > }
> |=20
> | Thanks,
> |=20
> | Louis
> |=20
> | [...]
> |=20
> | --=20
> | Dr Louis Rilling			Kerlabs
> | Skype: louis.rilling			Batiment Germanium
> | Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
> | http://www.kerlabs.com/			35700 Rennes
>=20
>=20
>=20
> | _______________________________________________
> | Containers mailing list
> | Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> | https://lists.linux-foundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-10363-1258709427-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksGYewACgkQVKcRuvQ9Q1Q+FQCeIyERR81ckOjuR1J7XA7IGctB
dz0AoIlQyUw5bsJRDGsQpcBd/Nga5mm4
=SpKQ
-----END PGP SIGNATURE-----

--=_bohort-10363-1258709427-0001-2--

--===============5843416159564629096==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5843416159564629096==--
