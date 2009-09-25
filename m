From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][v7][PATCH 8/9]: Define clone2() syscall
Date: Fri, 25 Sep 2009 12:56:32 +0200
Message-ID: <20090925105632.GG12824__27829.8723431819$1253876303$gmane$org@hawkmoon.kerlabs.com>
References: <20090924165548.GA16586@us.ibm.com>
	<20090924170308.GH16989@us.ibm.com>
	<200909242343.59903.arnd@arndb.de>
	<20090925082346.GB4436@localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4088388785607986899=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090925082346.GB4436@localdomain>
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
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============4088388785607986899==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-7906-1253876148-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-7906-1253876148-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 25/09/09 10:23 +0200, Louis Rilling wrote:
> On Thu, Sep 24, 2009 at 11:43:59PM +0200, Arnd Bergmann wrote:
> > On Thursday 24 September 2009, Sukadev Bhattiprolu wrote:
> > > +asmlinkage long
> > > +sys_clone2(struct clone_struct __user *ucs, pid_t __user *pids)
> > > +{
> > > +       int rc;
> > > +       struct clone_struct kcs;
> > > +       unsigned long clone_flags;
> > > +       int __user *parent_tid_ptr;
> > > +       int __user *child_tid_ptr;
> > > +       unsigned long __user child_stack_base;
> > > +       struct pt_regs *regs;
> > > +
> > > +       rc =3D copy_from_user(&ucs, &kcs, sizeof(kcs));
> > > +       if (rc)
> > > +               return -EFAULT;
> > > +
> > > +       /*
> > > +        * TODO: Convert clone_flags to 64-bit
> > > +        */
> > > +       clone_flags =3D (unsigned long)kcs.flags;
> > > +       child_stack_base =3D (unsigned long)kcs.child_stack;
> > > +       parent_tid_ptr =3D &ucs.parent_tid;
> > > +       child_tid_ptr =3D  &ucs.child_tid;
> > > +       regs =3D task_pt_regs(current);
> > > +
> > > +       if (!child_stack_base)
> > > +               child_stack_base =3D user_stack_pointer(regs);
> > > +
> > > +       return do_fork_with_pids(clone_flags, child_stack_base, regs,=
 0,
> > > +                       parent_tid_ptr, child_tid_ptr, kcs.nr_pids, p=
ids);
> > > +}
> > > +
> >=20
> > The function looks ok, but you have put it into arch/x86/kernel/process=
_32.c,
> > which is specific to x86-32. Since the code in this form is generic, why
> > not just put it into kernel/fork.c? You should probably enclose it with=
in
> > #ifdef CONFIG_HAVE_ARCH_TRACEHOOK to make sure that user_stack_pointer()
> > is implemented, but then it would be immediately usable by the nine arc=
hitectures
> > implementing that. The other architectures can then decide between addi=
ng
> > their private version of sys_clone2 with an open-coded user_stack_point=
er
> > implementation or alternatively implement the tracehooks.
>=20
> It will very likely break ia64, which defines CONFIG_HAVE_ARCH_TRACEHOOK =
and
> already has sys_clone2().

-> sys_clone_ext() ?

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-7906-1253876148-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkq8oeAACgkQVKcRuvQ9Q1Q6SwCgimdrl0B5UnPR3otnzftg5DrZ
21sAmwSFxuqZP6a9bqaNXiu3J2IBhLrz
=4eRk
-----END PGP SIGNATURE-----

--=_bohort-7906-1253876148-0001-2--

--===============4088388785607986899==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4088388785607986899==--
