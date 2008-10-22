From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Wed, 22 Oct 2008 11:25:02 +0200
Message-ID: <20081022092502.GW15171__29970.6876547591$1224667642$gmane$org@hawkmoon.kerlabs.com>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
	<48FC4E0C.7050008@fr.ibm.com> <200810221249.55600.major@openvz.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6288227398248862260=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810221249.55600.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============6288227398248862260==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-20975-1224667358-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-20975-1224667358-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 22, 2008 at 12:49:54PM +0400, Andrey Mirkin wrote:
> On Monday 20 October 2008 13:23 Cedric Le Goater wrote:
> > Hello Andrey !
> >
> > > diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
> > > index 109792b..a4848a3 100644
> > > --- a/arch/x86/kernel/entry_32.S
> > > +++ b/arch/x86/kernel/entry_32.S
> > > @@ -225,6 +225,7 @@ ENTRY(ret_from_fork)
> > >  	GET_THREAD_INFO(%ebp)
> > >  	popl %eax
> > >  	CFI_ADJUST_CFA_OFFSET -4
> > > +ret_from_fork_tail:
> > >  	pushl $0x0202			# Reset kernel eflags
> > >  	CFI_ADJUST_CFA_OFFSET 4
> > >  	popfl
> > > @@ -233,6 +234,26 @@ ENTRY(ret_from_fork)
> > >  	CFI_ENDPROC
> > >  END(ret_from_fork)
> > >
> > > +ENTRY(i386_ret_from_resume)
> > > +	CFI_STARTPROC
> > > +	pushl %eax
> > > +	CFI_ADJUST_CFA_OFFSET 4
> > > +	call schedule_tail
> > > +	GET_THREAD_INFO(%ebp)
> > > +	popl %eax
> > > +	CFI_ADJUST_CFA_OFFSET -4
> > > +	movl (%esp), %eax
> > > +	testl %eax, %eax
> > > +	jz    1f
> > > +	pushl %esp
> > > +	call  *%eax
> > > +	addl  $4, %esp
> > > +1:
> > > +	addl  $256, %esp
> > > +	jmp   ret_from_fork_tail
> > > +	CFI_ENDPROC
> > > +END(i386_ret_from_resume)
> >
> > Could you explain why you need to do this
> >
> > 	call  *%eax
> >
> > is it related to the freezer code ?
>=20
> It is not related to the freezer code actually.
> That is needed to restart syscalls. Right now I don't have a code in my=
=20
> patchset which restarts a syscall, but later I plan to add it.
> In OpenVZ checkpointing we restart syscalls if process was caught in sysc=
all=20
> during checkpointing.

Do you checkpoint uninterruptible syscalls as well? If only interruptible
syscalls are checkpointed, I'd say that either this syscall uses ERESTARTSY=
S or
ERESTART_RESTARTBLOCK, and then signal handling code already does the trick=
, or
this syscall does not restart itself when interrupted, and well, this is li=
fe,
userspace just sees -EINTR, which is allowed by the syscall spec.
Actually this is how we checkpoint/migrate tasks in interruptible syscalls =
in
Kerrighed and this works.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-20975-1224667358-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFI/vFuVKcRuvQ9Q1QRAjIRAKCoR0VUnHwiEJ57zm6Vw/5IJsx9xACgi7+U
gM14Y8eKgo+xAz7qEGvFElo=
=ymRV
-----END PGP SIGNATURE-----

--=_bohort-20975-1224667358-0001-2--

--===============6288227398248862260==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6288227398248862260==--
