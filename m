From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
	ptrace_may_access
Date: Tue, 18 Oct 2016 17:05:07 +0200
Message-ID: <20161018150507.GP14666__41632.572343997$1476803153$gmane$org@pc.thejh.net>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz>
	<8737jt903u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8892791583326245325=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8737jt903u.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============8892791583326245325==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDdTYOCAbkFo0FQC"
Content-Disposition: inline


--dDdTYOCAbkFo0FQC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 18, 2016 at 09:56:53AM -0500, Eric W. Biederman wrote:
> Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
>=20
> > On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
> >>=20
> >> During exec dumpable is cleared if the file that is being executed is
> >> not readable by the user executing the file.  A bug in
> >> ptrace_may_access allows reading the file if the executable happens to
> >> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> >> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
> >>=20
> >> This problem is fixed with only necessary userspace breakage by adding
> >> a user namespace owner to mm_struct, captured at the time of exec,
> >> so it is clear in which user namespace CAP_SYS_PTRACE must be present
> >> in to be able to safely give read permission to the executable.
> >>=20
> >> The function ptrace_may_access is modified to verify that the ptracer
> >> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> >> This ensures that if the task changes it's cred into a subordinate
> >> user namespace it does not become ptraceable.
> >
> > I haven't studied your patch too deeply but one thing that immediately=
=20
> > raised a red flag was that mm might be shared between processes (aka
> > thread groups). What prevents those two to sit in different user
> > namespaces?
> >
> > I am primarily asking because this generated a lot of headache for the
> > memcg handling as those processes might sit in different cgroups while
> > there is only one correct memcg for them which can disagree with the
> > cgroup associated with one of the processes.
>=20
> That is a legitimate concern, but I do not see any of those kinds of
> issues here.
>=20
> Part of the memcg pain comes from the fact that control groups are
> process centric, and part of the pain comes from the fact that it is
> possible to change control groups.  What I am doing is making the mm
> owned by a user namespace (at creation time), and I am not allowing
> changes to that ownership. The credentials of the tasks that use that mm
> may be in the same user namespace or descendent user namespaces.
>=20
> The core goal is to enforce the unreadability of an mm when an
> non-readable file is executed.  This is a time of mm creation property.
> The enforcement of which fits very well with the security/permission
> checking role of the user namespace.

How is that going to work? I thought the core goal was better security for
entering containers.

If I want to dump a non-readable file, afaik, I can just make a new user
namespace, then run the file in there and dump its memory.
I guess you could fix that by entirely prohibiting the execution of a
non-readable file whose owner UID is not mapped. (Adding more dumping
restrictions wouldn't help much because you could still e.g. supply a
malicious dynamic linker if you control the mount namespace.)

--dDdTYOCAbkFo0FQC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYBjojAAoJED4KNFJOeCOo5RUQAJ3hm7OdxQ4XSgeWafVqL83n
olVxqERueawMqp8C2zHpcRHYQdsHf4ldtco3ZpvvIRXZWAkPo0dCDrT7CnOV4hSA
Ee+pWkgytoQ4Gtly57Jx9xuxjrqBUHll1Mo3Bn/FEGr3k+qxgIYf8+UaCgoH6IUv
TScPCMYaXH7lbf3xuMaxW+EebOezw/ITXKvDXc3uzzzTkg0rvgknjGTicvRR1lQS
hQ+3+6+JD9NR4hyfCAZqspBewJwmfgwAzmhCIfvrVtHZq/R/dtyw+vYDGthgY40R
saTtHlpm/iFU8ERcmGEY+tjdDw9fPNGHn5vH+KDbzNk1+39vEije6QJm2okjW1ow
QrT84C3ItODmU7Tah0XXDZPcSNsfpp0oXob26b1VwbIutkl/Pw6bi7WrqYYmUhq/
1XaAiJWoVzlrJlSf7+JTiC4gEjLmYH38KptfOL4UY1/1kIoifeqTSXAsjtk+0BIi
XbIzUgGjRz/qIDfEfMr4/oWXYTfM9WZlYeecdo/lLAa5hyyCgXtrseVk7AIFq5jX
CcTSwo0kCmFncGTjfkiQfcOy4utEJhJduXX8VjnrjQXXsUhFQxinb50lQej52wSg
d8Lz785km03c6myj7fcN4i0KSmnSYwyFhAJirkozN+9WDyqU/K330El6nYG7a4WX
2+sclXsEjiZ3fgWcuv0U
=DXaI
-----END PGP SIGNATURE-----

--dDdTYOCAbkFo0FQC--

--===============8892791583326245325==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8892791583326245325==--
