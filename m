From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: C/R: File substitution at restart
Date: Thu, 9 Sep 2010 12:37:20 +0200
Message-ID: <20100909103720.GF4812@hawkmoon.kerlabs.com>
References: <4C875F6E.2030004@kerlabs.com> <20100908130931.GA11161@hallyn.com>
	<20100908193531.GB8957@count0.beaverton.ibm.com>
	<20100909010352.GA13880@hallyn.com>
	<20100909040635.GE8957@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5738001120138015537=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100909040635.GE8957-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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

--===============5738001120138015537==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-13919-1284028615-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-13919-1284028615-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 08/09/10 21:06 -0700, Matt Helsley wrote:
> On Wed, Sep 08, 2010 at 08:03:52PM -0500, Serge E. Hallyn wrote:
> > Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > > On Wed, Sep 08, 2010 at 08:09:31AM -0500, Serge E. Hallyn wrote:
> > > I think it can be split into two composable pieces which may also be
> > > useful independently.
> > >=20
> > > The first uses the fcntl() interface to add a flag like
> > > O_CLOEXEC. Unlike O_CLOEXEC it marks an fd for preservation during
> > > restart. That way we don't have to specify an fd number and a "source"
> > > to the kernel. Just tell the kernel to keep the fd. The source can
> > > be opened and dup2'd via userspace. This is useful without the
> > > second piece if we want to simply add rather than replace an fd.
> >=20
> > Can you think of any other use for this flag other than restart?
>=20
> <joking>
> I can't think of any other uses for O_CLOEXEC.
> </joking>
>=20
> Seriously though, restart will be used _much_ less often than exec so yes
> it does seem like a waste of a valuable bit and something that wouldn't
> quite belong in an fcntl interface.
>=20
> However we can try to be a tad clever -- we could (ab|re)use O_CLOEXEC.
> Right now restart closes all file descriptors and pays absolutely
> no attention to O_CLOEXEC. We could reuse O_CLOEXEC to mean O_CLOREST
> too. Have user-cr's restart tool mark all unwanted fds O_CLOEXEC. Any we
> want to keep we do not mark with O_CLOEXEC.

This would also be useful at checkpoint, to tell sys_checkpoint() which fds
should be ignored, being because it is not supported or because the applica=
tion
has a better way to deal with it.

>=20
>=20
> Here's another idea which I haven't fully thought out yet.
>=20
> We could introduce the concept of object id substitutions in the image.
> So the image would look like (going from file pos 0 at the top..):
>=20
> 0 +-------------------------------+
>   |                               |
>                 .....
>   +-------------------------------+
>   |     <substitute object>       | <--- object with id =3D=3D <substitut=
e id>
>                 .....
>   +---------------+---------------+
>   |  <object id>  |<substitute id>|
>   +---------------+---------------+
>                 .....
>   +---------------+---------------+
>   |     <object to ignore>        | <-- object with id =3D=3D <object id>
>                 .....
>=20
> (The above is ignoring the ckpt_hdr fields..)
>=20
> When we read the image during restart we use the substitute ids to
> create indirect objhash entries. When we encounter an obj id and
> it refers to an indirect entry we first parse the object (ignoring
> errors and dropping references on new objhash insertions), flip
> a bit on the indirect entry (indicating the object has been parsed),
> and then lookup the substitute id and return whatever that resolved to.
>=20
> We can ignore the new objhash objects by making the objhash have its
> own operation struct. When we're parsing an object that's been
> substituted we just temporarily set the objhash add/lookup operations
> to something suitable for properly dropping references to the new
> object(s). This way we don't have to add checks for this peculiar
> need all over the checkpoint/restart code. Sure it'll be slower...

If at checkpoint we can take care to ignore files that we know will be
substituted, this should not be that slower.

>=20
> I can think of a few problems with that already. If the substituted
> obj differs wildly in file type then any defer queue entries that use
> obj ids to complete the deferred work would fail miserably...

The problem I see with rewriting the image is that this may impose addition=
al
I/O, for instance to duplicate the image before rewriting, or if it is simp=
ly
rewritten to disk. In contrast, having an easily parsable table of fds at t=
he
beginning of the image, with associated object ids (and preferably more info
like file type, path, owner rights, etc.) makes it easy and lightweight to
build a separate substitution table, that we could feed sys_restart() with
(maybe only the coordinator could feed sys_restart() with such a table).

>=20
> That said, so far I've never heard folks discuss substituting anything
> but fds. Perhaps enabling substitution at the objhash level is just too
> broad and we'd be better off only allowing fd substitutions?

Well... A while ago I asked about substituting SYSV IPC objects (I was talk=
ing
about SHM at that moment, but semaphore sets or message queues are even eas=
ier
to substitute). In such a scenario a pipeline of video transcoding would use
SYSV SHMs to store transitional frames between the stages of the pipeline, =
and
the SHMs themselves would not need to be checkpointed, or could be checkpoi=
nted
at a lower frequency than the processes.

Substituting memory mapped files (for instance POSIX SHMs) would be useful =
too.

>=20
> > If so, then having a fcntl flag (and later madvise) makes sense.
> > But if we're going to add options to various different APIS which
> > really are all only useful for c/r, then maybe a single new cr_advise()
> > really does make sense.  The alternative may be more popular at first
> > but would IMO turn into a disaster.
>=20
> Good point.

cr_advise() or changing sys_checkpoint() and sys_restart() are both fine to=
 me.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-13919-1284028615-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkyIuOAACgkQVKcRuvQ9Q1R7aQCg1+/njOZ8pHm2Jqf2sMmwUdqn
HdMAoMvSrAw3ovJx7DymW6aUggn/IXah
=5BAY
-----END PGP SIGNATURE-----

--=_bohort-13919-1284028615-0001-2--

--===============5738001120138015537==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5738001120138015537==--
