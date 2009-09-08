From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/6] c/r: [pty 1/2] allow allocation of desired pty slave
Date: Tue, 8 Sep 2009 16:04:22 +0200
Message-ID: <20090908140422.GR12824@hawkmoon.kerlabs.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-3-git-send-email-orenl@librato.com>
	<20090904152644.GA15253@us.ibm.com>
	<20090908080944.GP12824@hawkmoon.kerlabs.com>
	<4AA659C7.5020700@librato.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0960095559340064440=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AA659C7.5020700-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============0960095559340064440==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-27779-1252418622-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-27779-1252418622-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 08/09/09  9:19 -0400, Oren Laadan wrote:
>=20
>=20
> Louis Rilling wrote:
> > On 04/09/09 10:26 -0500, Serge E. Hallyn wrote:
> >> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> >>> During restart, we need to allocate pty slaves with the same
> >>> identifiers as recorded during checkpoint. Modify the allocation code
> >>> to allow an in-kernel caller to request a specific slave identifier.
> >>>
> >>> For this, add a new field to task_struct - 'required_id'. It will
> >>> hold the desired identifier when restoring a (master) pty.
> >>>
> >>> The code in ptmx_open() will use this value only for tasks that try to
> >>> open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
> >>> isn't CKPT_REQUIRED_NONE (-1).
> >> So noone has indicated any preference for this versus the ptmx_create()
> >> approach...
> >>
> >> I'm satisfied knowing we have a working fallback in case task->require=
d_id
> >> is deemed unacceptable.
> >>
> >> However I'd like to not have linux-kernel folks think us morons for not
> >> having considered that.  Can you add a message to the changelog saying
> >> why we're going with this approach (namely, that it lets us re-use
> >> filp_open() instead of having to do a custom alloc_file in a new code-=
path,
> >> which introduces maintenance duplication for file permission checking
> >> paths)?
> >=20
> > As far as I am concerned, I do have a preference for the ptmx_create()
> > approach. This task->required_id field reminds me the former approach t=
aken for
> > restarting pids and (and SYSV IPC ids IIRC) from userspace, that was pr=
oposed
> > last year and actually deemed unacceptable [ IIRC, this was an argument=
 in favor
> > of a restart() syscall ]. I know that it's not the same since ->require=
d_id is
> > not set from userspace and used in a later syscall, but still ...
> >=20
> > Moreover I see no reason whey there would be no way to refactorize ptmx=
 code and
> > have less duplicated code with the ptmx_create() approach.
>=20
> I basically agree - I simply took the easiest/fastest path; if the ptmx
> code is properly refactored, we should use that instead.
>=20
> Did you have a chance to look at Serge's attempt to do exactly that ?
> https://lists.linux-foundation.org/pipermail/containers/2009-September/02=
0363.html

I only had a quick look. Will try to look closer, but don't rely on me being
quick at this.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-27779-1252418622-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqmZGYACgkQVKcRuvQ9Q1Q9lACgitU7/9aF7Xc93df2kU6gSD6e
YjkAnA15bDNKr+lEfTnA2MU7zi4U82Ka
=1b51
-----END PGP SIGNATURE-----

--=_bohort-27779-1252418622-0001-2--

--===============0960095559340064440==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0960095559340064440==--
