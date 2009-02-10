From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re:
	Checkpoint / Restart)
Date: Tue, 10 Feb 2009 11:25:13 +0100
Message-ID: <20090210102513.GB32106@hawkmoon.kerlabs.com>
References: <20090207001609.8168.14884.stgit@lahore.corp.google.com>
	<f4192e520902090953x43a98134hfaa8443d586a32a6@mail.gmail.com>
	<49908323.3090606@google.com> <49908EA0.2080901@fr.ibm.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3473553607458054632=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49908EA0.2080901-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Jim Winget <winget-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============3473553607458054632==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-21218-1234261514-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-21218-1234261514-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/02/09 21:14 +0100, Cedric Le Goater wrote:

[...]

> I think that the current way of doing things is work in progress and needs
> to be reviewed. The way checkpoint/restart is triggered has always been
> controversial among the stakeholders.
>=20
> We've been maintaining a C/R solution on ppc32, ppc64, x86, x86_64, ia64,=
=20
> s390, s390x since 2002 working on the above principles you are describing.
> UNICOS and later IRIX used similar principles, following the POSIX draft
> on checkpoint/restart.
>=20
> For the signal, we have 'hijacked' SIGSTOP but new signals SIGCKPT and=20
> SIGRESTART would definitely be a nicer solution for a mainline solution.

In Kerrighed we implemented a variant of signal handler, which is more
transparent to userspace. Instead of using userspace signals (for instance
SIGRTMIN), we send a signal with si_code =3D SI_KERRIGHED. When dequeuing s=
uch a
signal, get_signal_to_deliver() calls the appropriate kernel callback (eg.
task_checkpoint()), and then continues as if the signal were ignored.

This solution has two nice properties:
- no userspace signal is overloaded, so that applications can use whatever
  signals they want;
- every task will eventually handle the signal with the right callback, whe=
ther
  they use the VDSO page or not.

Of course there is the matching drawback: userspace cannot use the checkpoi=
nt
signal to perform application-dependent control. However, this kind of thing
could equally be done from the checkpoint callback setting up an
application-defined signal handler.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-21218-1234261514-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJkVYJVKcRuvQ9Q1QRAqISAJ0ThhtFGQXalXmz/32OiE8DqDc8LACgv9vL
fhYkliBNUKLfasey9Sp+Qj4=
=gnB7
-----END PGP SIGNATURE-----

--=_bohort-21218-1234261514-0001-2--

--===============3473553607458054632==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3473553607458054632==--
