From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: C/R: File substitution at restart
Date: Thu, 9 Sep 2010 13:34:11 +0200
Message-ID: <20100909113411.GH4812@hawkmoon.kerlabs.com>
References: <4C875F6E.2030004@kerlabs.com> <20100908130931.GA11161@hallyn.com>
	<20100908193531.GB8957@count0.beaverton.ibm.com>
	<20100909010352.GA13880@hallyn.com>
	<20100909040635.GE8957@count0.beaverton.ibm.com>
	<20100909103720.GF4812@hawkmoon.kerlabs.com>
	<20100909110220.GF8957@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4669484202638710283=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100909110220.GF8957-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Matthieu =?iso-8859-1?Q?Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============4669484202638710283==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-14976-1284032026-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-14976-1284032026-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/09/10  4:02 -0700, Matt Helsley wrote:
> On Thu, Sep 09, 2010 at 12:37:20PM +0200, Louis Rilling wrote:
> > On 08/09/10 21:06 -0700, Matt Helsley wrote:
> > > On Wed, Sep 08, 2010 at 08:03:52PM -0500, Serge E. Hallyn wrote:
> > > > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > > > > On Wed, Sep 08, 2010 at 08:09:31AM -0500, Serge E. Hallyn wrote:
> > > > > I think it can be split into two composable pieces which may also=
 be
> > > > > useful independently.
> > > > >=20
> > > > > The first uses the fcntl() interface to add a flag like
> > > > > O_CLOEXEC. Unlike O_CLOEXEC it marks an fd for preservation during
> > > > > restart. That way we don't have to specify an fd number and a "so=
urce"
> > > > > to the kernel. Just tell the kernel to keep the fd. The source can
> > > > > be opened and dup2'd via userspace. This is useful without the
> > > > > second piece if we want to simply add rather than replace an fd.
> > > >=20
> > > > Can you think of any other use for this flag other than restart?
> > >=20
> > > <joking>
> > > I can't think of any other uses for O_CLOEXEC.
> > > </joking>
> > >=20
> > > Seriously though, restart will be used _much_ less often than exec so=
 yes
> > > it does seem like a waste of a valuable bit and something that wouldn=
't
> > > quite belong in an fcntl interface.
> > >=20
> > > However we can try to be a tad clever -- we could (ab|re)use O_CLOEXE=
C.
> > > Right now restart closes all file descriptors and pays absolutely
> > > no attention to O_CLOEXEC. We could reuse O_CLOEXEC to mean O_CLOREST
> > > too. Have user-cr's restart tool mark all unwanted fds O_CLOEXEC. Any=
 we
> > > want to keep we do not mark with O_CLOEXEC.
> >=20
> > This would also be useful at checkpoint, to tell sys_checkpoint() which=
 fds
> > should be ignored, being because it is not supported or because the app=
lication
> > has a better way to deal with it.
>=20
> True. Though unlike restart I don't think we just can (ab|re)use O_CLOEXEC
> for that purpose.
>=20
> >=20
> > >=20
> > >=20
> > > Here's another idea which I haven't fully thought out yet.
> > >=20
> > > We could introduce the concept of object id substitutions in the imag=
e.
> > > So the image would look like (going from file pos 0 at the top..):
> > >=20
> > > 0 +-------------------------------+
> > >   |                               |
> > >                 .....
> > >   +-------------------------------+
> > >   |     <substitute object>       | <--- object with id =3D=3D <subst=
itute id>
> > >                 .....
> > >   +---------------+---------------+
> > >   |  <object id>  |<substitute id>|
> > >   +---------------+---------------+
> > >                 .....
> > >   +---------------+---------------+
> > >   |     <object to ignore>        | <-- object with id =3D=3D <object=
 id>
> > >                 .....
> > >=20
> > > (The above is ignoring the ckpt_hdr fields..)
> > >=20
> > > When we read the image during restart we use the substitute ids to
> > > create indirect objhash entries. When we encounter an obj id and
> > > it refers to an indirect entry we first parse the object (ignoring
> > > errors and dropping references on new objhash insertions), flip
> > > a bit on the indirect entry (indicating the object has been parsed),
> > > and then lookup the substitute id and return whatever that resolved t=
o.
> > >=20
> > > We can ignore the new objhash objects by making the objhash have its
> > > own operation struct. When we're parsing an object that's been
> > > substituted we just temporarily set the objhash add/lookup operations
> > > to something suitable for properly dropping references to the new
> > > object(s). This way we don't have to add checks for this peculiar
> > > need all over the checkpoint/restart code. Sure it'll be slower...
> >=20
> > If at checkpoint we can take care to ignore files that we know will be
> > substituted, this should not be that slower.
>=20
> So, would you say typically it's the application developer who knows
> what to ignore? Are we expecting distros/packagers to be able to set
> that up? Admins? These specific optimizations seem like they would be a
> bit fragile unless the application developer is involved.

If you look at OpenMPI's C/R framework, the policy to ignore/substitude fds
(mostly sockets and log files) is programmed in the C/R plugin. In that cas=
e,
the middleware knows.

Otherwise, for such optimization cases I expect applications to come with
dedicated C/R helpers. So, yes, the application developer is involved.

However, in some special cases like stdio redirection of containers,
administrators should be able to do it, or even users. Imagine a user feedi=
ng
some file to the checkpointed app, and wanting the app to work on a differe=
nt
file at restart.  With a parsing tool and enough info in the fd table of the
checkpoint image, the user could easily know which fd should be substituted
because its path matches the file that was fed to the app.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-14976-1284032026-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkyIxjMACgkQVKcRuvQ9Q1SxzACguT1Cj8LK+z5Lk18xXnKgB1BO
8mgAnRlh7cwjV27I427CxaJQn4/+20wl
=3M0i
-----END PGP SIGNATURE-----

--=_bohort-14976-1284032026-0001-2--

--===============4669484202638710283==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============4669484202638710283==--
