From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Thu, 19 Nov 2009 10:58:44 +0100
Message-ID: <20091119095844.GP4379@hawkmoon.kerlabs.com>
References: <20091119004838.AD278DE0@kernel>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1588460728422748873=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091119004838.AD278DE0@kernel>
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

--===============1588460728422748873==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-24107-1258624667-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-24107-1258624667-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On 18/11/09 16:48 -0800, Dave Hansen wrote:
>=20
> This is still a bit rough, but I figured I'd post it for kicks.
>=20
> Most of the process.c stuff is copy-n-paste with i386 and needs
> to get consolidated.  I also need to give this the new name.
>=20
> I'd appreciate anybody that knows inline assembly well to make
> sure that I'm not being a complete doofus with this call below.
> This seems to work, but I'm not confident it is the best way.

I'm not a total guru of inline assembly, but I have comments :)

>=20
> int clone_with_pids(long flags_low, struct clone_args *clone_args, long a=
rgs_size,
>                  int *pids)
> {
>         long retval;
>=20
>         __asm__  __volatile__(
>                  "movq %3, %%r10\n\t"           /* pids in r10*/
>                  "pushq %%rbp\n\t"              /* save value of ebp */
>                 :
>                 :"D" (flags_low), /* rdi */
>                  "S" (clone_args),/* rsi */
>                  "d" (args_size), /* rdx */
>                  "a" (pids)       /* use rax, which gets moved to r10 */
>                 );

1. The fourth C arg is not in rax, but in rcx.

>=20
>         __asm__ __volatile__(
>                  "syscall\n\t"  /* Linux/x86_64 system call */
>                  "testq %0,%0\n\t"      /* check return value */
>                  "jne 1f\n\t"           /* jump if parent */
>                  "popq %%rbx\n\t"       /* get subthread function */
>                  "call *%%rbx\n\t"      /* start subthread function */
>                  "movq %2,%0\n\t"
>                  "syscall\n"            /* exit system call: exit subthre=
ad */
>                  "1:\n\t"
>                  "popq %%rbp\t"         /* restore parent's ebp */
>                 :"=3Da" (retval)
>                 :"0" (__NR_clone3), "i" (__NR_exit)
>                 :"ebx", "ecx", "edx"
>                 );

2. You should probably not separate this into two asm statements. In partic=
ular,
   the compiler has no way to know that r10 should be preserved between the=
 two
   statements, and may be confused by the change of rsp.

3. r10 and r11 should be listed as clobbered.

4. I fail to see the magic that puts the subthread function pointer in the
   stack.

5. Maybe rdi should contain the subthread argument before calling the subth=
read?

6. rdi, rsi, rdx, rcx, r8 and r9 should be added to the clobber list becaus=
e of
   the call to the subthread function.

7. rsi could be used in place of rbx to hold the function pointer, which wo=
uld
   allow you to remove ebx from the clobber list.

8. I don't see why rbp should be saved. The ABI says it must be saved by the
   callee.

9. Before calling exit(), maybe put some exit code in rdi?

>=20
>         if (retval < 0) {
>                 errno =3D -retval;
>                 retval =3D -1;
>         }
>         return retval;
> }

Thanks,

Louis

[...]

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-24107-1258624667-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksFFtQACgkQVKcRuvQ9Q1TlXQCgnHNNHqtQKDRV/oW5lwyYIdKF
AMIAoMIidVt3jfQamA69VTmFkPNc9iEz
=JyZ5
-----END PGP SIGNATURE-----

--=_bohort-24107-1258624667-0001-2--

--===============1588460728422748873==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============1588460728422748873==--
