From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] clone_with_pids()^w eclone() for x86_64
Date: Thu, 19 Nov 2009 22:29:05 +0100
Message-ID: <20091119212905.GB4767@localdomain>
References: <20091119004838.AD278DE0@kernel>
	<20091119095844.GP4379@hawkmoon.kerlabs.com>
	<1258652929.20093.8941.camel@nimitz>
	<20091119212646.GA4767@localdomain>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0503382057707780600=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091119212646.GA4767@localdomain>
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

--===============0503382057707780600==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-1776-1258666090-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-1776-1258666090-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2009 at 10:26:46PM +0100, Louis Rilling wrote:
> On Thu, Nov 19, 2009 at 09:48:49AM -0800, Dave Hansen wrote:
> > On Thu, 2009-11-19 at 10:58 +0100, Louis Rilling wrote:
> > > > int clone_with_pids(long flags_low, struct clone_args *clone_args, =
long args_size,
> > > >                  int *pids)
> > > > {
> > > >         long retval;
> > > >=20
> > > >         __asm__  __volatile__(
> > > >                  "movq %3, %%r10\n\t"           /* pids in r10*/
> > > >                  "pushq %%rbp\n\t"              /* save value of eb=
p */
> > > >                 :
> > > >                 :"D" (flags_low), /* rdi */
> > > >                  "S" (clone_args),/* rsi */
> > > >                  "d" (args_size), /* rdx */
> > > >                  "a" (pids)       /* use rax, which gets moved to r=
10 */
> > > >                 );
> > >=20
> > > 1. The fourth C arg is not in rax, but in rcx.
> >=20
> > Hey Louis,
> >=20
> > So, try as I might, I couldn't get that to work.  I thought it was rcx,
> > too.
> >=20
> > So, changing that instruction to:
> >=20
> >                 "movq %3, %%rcx\n\t"           /* pids in r10*/
>=20
> Hm, no.
>=20
> I meant (without taking into account my other comments):
>=20
>          __asm__  __volatile__(
>                   "movq %3, %%r10\n\t"           /* pids in r10*/
>                   "pushq %%rbp\n\t"              /* save value of ebp */
>                  :
>                  :"D" (flags_low), /* rdi */
>                   "S" (clone_args),/* rsi */
>                   "d" (args_size), /* rdx */
>                   "c" (pids)       /* use rcx, which gets moved to r10 */
>                  );
>=20
> But actually this is even better :D:
>=20
>          __asm__  __volatile__(
>                   "movq %3, %%r10\n\t"           /* pids in r10*/
>                   "pushq %%rbp\n\t"              /* save value of ebp */
>                  :
>                  :"D" (flags_low), /* rdi */
>                   "S" (clone_args),/* rsi */
>                   "d" (args_size), /* rdx */
>                   "r10" (pids)     /* Linux reads its fourth arg from r10=
 */
>                  );
>=20

Grrrr, I sent the email too quickly! This is the better version:

         __asm__  __volatile__(
                  "pushq %%rbp\n\t"              /* save value of ebp */
                 :
                 :"D" (flags_low), /* rdi */
                  "S" (clone_args),/* rsi */
                  "d" (args_size), /* rdx */
                  "r10" (pids)     /* Linux reads its fourth arg from r10 */
                 );

Louis


> >=20
> > and putting 0x11111, etc... in for the args the strace output for the
> > syscall looks like this:
> >=20
> >         syscall_299(0x11111, 0x22222, 0x33333, 0x1, 0x1, 0x2, 0, 0, 0,
> >         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
> >         0, 0) =3D -1 (errno 22)
> >=20
> > and I get -EFAULT back from the function doing the copy_from_user() of
> > the pids argument, even when using good values.
> >=20
> > If I use the asm posted above, I get this:
> >        =20
> >         syscall_299(0x11111, 0x22222, 0x33333, 0x44444, 0x1, 0x2, 0, 0,
> >         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
> >         0, 0, 0) =3D -1 (errno 22)
> >        =20
> > Or, this from a real call:
> >        =20
> >         syscall_299(0x1100011, 0x7fff19f0fd40, 0x38, 0x602070, 0x1, 0x2,
> >         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
> >         0, 0, 0, 0, 0[2992, 377]: Child:
> >        =20
> > I had to find r10 basically by trial and error.  I have no idea why it
> > works.
>=20
> r10 is used to pass the fourth arg to the kernel because the syscall inst=
ruction
> puts next rip (return address) in rcx. Using r10 instead of rcx is define=
d as part
> of Linux ABI for x86_64.
>=20
> For all the details, read the comments in
> arch/x86/kernel/entry_64.S:ENTRY(system_call).
>=20
> >=20
> > > >=20
> > > >         __asm__ __volatile__(
> > > >                  "syscall\n\t"  /* Linux/x86_64 system call */
> > > >                  "testq %0,%0\n\t"      /* check return value */
> > > >                  "jne 1f\n\t"           /* jump if parent */
> > > >                  "popq %%rbx\n\t"       /* get subthread function */
> > > >                  "call *%%rbx\n\t"      /* start subthread function=
 */
> > > >                  "movq %2,%0\n\t"
> > > >                  "syscall\n"            /* exit system call: exit s=
ubthread */
> > > >                  "1:\n\t"
> > > >                  "popq %%rbp\t"         /* restore parent's ebp */
> > > >                 :"=3Da" (retval)
> > > >                 :"0" (__NR_clone3), "i" (__NR_exit)
> > > >                 :"ebx", "ecx", "edx"
> > > >                 );
> > >=20
> > > 2. You should probably not separate this into two asm statements. In =
particular,
> > >    the compiler has no way to know that r10 should be preserved betwe=
en the two
> > >    statements, and may be confused by the change of rsp.
> >=20
> > Yeah, I wondered about that.  Suka, we should probably fix your tests
> > and the i386 code, too.
> >=20
> > > 3. r10 and r11 should be listed as clobbered.
> >=20
> > D'oh!  I didn't even touch the bottom registers because it continued to
> > work from the i386 version that I stole from Suka. =20
>=20
> That's again because of the syscall instruction, which saves EFLAGS to r11
> (and sysret restores EFLAGS from r11).
>=20
> >=20
> > > 4. I fail to see the magic that puts the subthread function pointer i=
n the
> > >    stack.
> > >=20
> > > 5. Maybe rdi should contain the subthread argument before calling the=
 subthread?
> > >=20
> > > 6. rdi, rsi, rdx, rcx, r8 and r9 should be added to the clobber list =
because of
> > >    the call to the subthread function.
> > >=20
> > > 7. rsi could be used in place of rbx to hold the function pointer, wh=
ich would
> > >    allow you to remove ebx from the clobber list.
> > >=20
> > > 8. I don't see why rbp should be saved. The ABI says it must be saved=
 by the
> > >    callee.
> > >=20
> > > 9. Before calling exit(), maybe put some exit code in rdi?
> >=20
> > Thanks for looking through this, Louis.  I'll send out another version
> > in a bit.
>=20
> Thanks,
>=20
> Louis
>=20
> --=20
> Dr Louis Rilling			Kerlabs
> Skype: louis.rilling			Batiment Germanium
> Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
> http://www.kerlabs.com/			35700 Rennes



--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-1776-1258666090-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAksFuKEACgkQVKcRuvQ9Q1Sr8wCfe3UqFhLeDAoFsFcbZBXiKZpX
OU4Amwbjh8HYDedSij/m/Pdzo9x7dFlu
=2TbD
-----END PGP SIGNATURE-----

--=_bohort-1776-1258666090-0001-2--

--===============0503382057707780600==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0503382057707780600==--
