From: Thadeu Lima de Souza Cascardo <cascardo-/wxwWNsM9nk+uJoB2kUjGw@public.gmane.org>
Subject: Re: cgroup mount point
Date: Tue, 3 Feb 2009 10:57:45 -0200
Message-ID: <20090203125744.GC3788__35001.3219089762$1233666051$gmane$org@vespa.holoscopio.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
	<20090203102416.GA8886@redhat.com> <87ljsnzo4v.fsf@benfinney.id.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3717111643697006715=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ljsnzo4v.fsf-TqlCGjI+HWGnbCmf7pGUHw@public.gmane.org>
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
To: Ben Finney <ben+debian-TqlCGjI+HWGnbCmf7pGUHw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============3717111643697006715==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="da4uJneut+ArUgXk"
Content-Disposition: inline


--da4uJneut+ArUgXk
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 03, 2009 at 11:44:00PM +1100, Ben Finney wrote:
> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>=20
> > On Mon, Feb 02, 2009 at 07:41:53PM -0200, Thadeu Lima de Souza Cascardo=
 wrote:
> > > So, we have some more options now: /cgroups, /containers,
> > > /dev/cpuset, /dev/cpuctl, /opt/cgroup, /opt/cpuset.
> >=20
> > Putting new mount points in / is not really acceptable, so that rules
> > out the first two. /opt is just totally wrong, since that is intended
> > for add on software packages. /dev/ feels a little odd, since it is
> > not really device nodes
>=20
> I agree with all that Thadeu Lima says here. I would add that cgroups
> are nothing to do with device nodes, so definitely don't belong in
> =E2=80=98/dev/=E2=80=99 either.

The message you quoted is from Daniel Berrange, not me. Could you also
tell your rationale for not agreeing with /?

Regards,
Cascardo.

> Since they're a filesystem mapping =E2=80=9Cfor browsing and manipulation
> from user space=E2=80=9D of a kernel facility, I think =E2=80=98/sys/cgro=
ups/=E2=80=99 is
> appropriate.
>=20
> --=20
>  \     =E2=80=9CIt's my belief we developed language because of our deep =
inner |
>   `\                  need to complain.=E2=80=9D =E2=80=94Jane Wagner, vi=
a Lily Tomlin |
> _o__)                                                                  |
> Ben Finney

--da4uJneut+ArUgXk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkmIP0gACgkQyTpryRcqtS0gfwCeNESvcsbtrnHDydfihDHfsyXV
1F0AnjoRLwCaSYBnpRh9BIJFhQn2EJMd
=w/XP
-----END PGP SIGNATURE-----

--da4uJneut+ArUgXk--

--===============3717111643697006715==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3717111643697006715==--
