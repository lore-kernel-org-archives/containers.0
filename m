From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/6] c/r: [pty 1/2] allow allocation of desired pty slave
Date: Tue, 8 Sep 2009 10:09:44 +0200
Message-ID: <20090908080944.GP12824@hawkmoon.kerlabs.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-3-git-send-email-orenl@librato.com>
	<20090904152644.GA15253@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8735788150404148434=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090904152644.GA15253-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============8735788150404148434==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-21780-1252397343-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-21780-1252397343-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 04/09/09 10:26 -0500, Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> > During restart, we need to allocate pty slaves with the same
> > identifiers as recorded during checkpoint. Modify the allocation code
> > to allow an in-kernel caller to request a specific slave identifier.
> >=20
> > For this, add a new field to task_struct - 'required_id'. It will
> > hold the desired identifier when restoring a (master) pty.
> >=20
> > The code in ptmx_open() will use this value only for tasks that try to
> > open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
> > isn't CKPT_REQUIRED_NONE (-1).
>=20
> So noone has indicated any preference for this versus the ptmx_create()
> approach...
>=20
> I'm satisfied knowing we have a working fallback in case task->required_id
> is deemed unacceptable.
>=20
> However I'd like to not have linux-kernel folks think us morons for not
> having considered that.  Can you add a message to the changelog saying
> why we're going with this approach (namely, that it lets us re-use
> filp_open() instead of having to do a custom alloc_file in a new code-pat=
h,
> which introduces maintenance duplication for file permission checking
> paths)?

As far as I am concerned, I do have a preference for the ptmx_create()
approach. This task->required_id field reminds me the former approach taken=
 for
restarting pids and (and SYSV IPC ids IIRC) from userspace, that was propos=
ed
last year and actually deemed unacceptable [ IIRC, this was an argument in =
favor
of a restart() syscall ]. I know that it's not the same since ->required_id=
 is
not set from userspace and used in a later syscall, but still ...

Moreover I see no reason whey there would be no way to refactorize ptmx cod=
e and
have less duplicated code with the ptmx_create() approach.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-21780-1252397343-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqmEUgACgkQVKcRuvQ9Q1SH0ACgrwJYp6EJ/53diAxPJPFzNMoI
VgQAoM/0BcUzG9YjA2YwTlOAxZM3F8gn
=Ummz
-----END PGP SIGNATURE-----

--=_bohort-21780-1252397343-0001-2--

--===============8735788150404148434==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8735788150404148434==--
