From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 08/10] Introduce functions to restart a process
Date: Wed, 22 Oct 2008 12:44:48 +0200
Message-ID: <20081022104448.GX15171__25248.2638964013$1224672424$gmane$org@hawkmoon.kerlabs.com>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-9-git-send-email-major@openvz.org>
	<48FC4E0C.7050008@fr.ibm.com> <200810221249.55600.major@openvz.org>
	<20081022092502.GW15171@hawkmoon.kerlabs.com>
	<1224669979.4210.15.camel@localhost.localdomain>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7670360263810088249=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224669979.4210.15.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============7670360263810088249==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-23467-1224672144-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-23467-1224672144-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 22, 2008 at 12:06:19PM +0200, Greg Kurz wrote:
> On Wed, 2008-10-22 at 11:25 +0200, Louis Rilling wrote:
> > Do you checkpoint uninterruptible syscalls as well? If only interruptib=
le
> > syscalls are checkpointed, I'd say that either this syscall uses ERESTA=
RTSYS or
> > ERESTART_RESTARTBLOCK, and then signal handling code already does the t=
rick, or
> > this syscall does not restart itself when interrupted, and well, this i=
s life,
> > userspace just sees -EINTR, which is allowed by the syscall spec.
> > Actually this is how we checkpoint/migrate tasks in interruptible sysca=
lls in
> > Kerrighed and this works.
> >=20
> > Louis
> >=20
>=20
> I don't know Kerrighed internals but I understand you perform checkpoint
> with a signal handler. Right ?

Right. This is an kernel-internal-only signal, so all signals remain availa=
ble
for userspace.

> This approach has a huge benefit: the
> signal handling code do all the arch dependant stuff to save registers
> in user memory.

Hm, I'm not sure to understand what you mean here. We just rely on arch code
that jumps to signal handling to correctly setup struct pt_regs, which is t=
hen
passed to the checkpoint code. So yes, userspace registers are mostly saved=
 by
existing arch code. But in x86-64 for instance, segment registers still nee=
d to
be saved by the checkpoint code (a bit like copy_thread() does), and I don't
know arch-independent functions doing this.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-23467-1224672144-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFI/wQgVKcRuvQ9Q1QRAlYSAJ9m7SbP58UJecxrODh20bCidW8GiQCaA8au
cwPAhqb8bpNORt8BMVatako=
=seeX
-----END PGP SIGNATURE-----

--=_bohort-23467-1224672144-0001-2--

--===============7670360263810088249==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7670360263810088249==--
