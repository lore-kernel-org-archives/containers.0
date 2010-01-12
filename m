From: "Michael H. Warfield" <mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org>
Subject: Re: [Devel] Re: LXC container, unmounting unneeded mount points
	(from the 	container namespace)
Date: Mon, 11 Jan 2010 23:03:57 -0500
Message-ID: <1263269037.14592.60.camel@localhost>
References: <8e04b5821001080608w47b0529dhcd6f8a26e38f24e0@mail.gmail.com>
	<4B473E89.1040200@free.fr>
	<8e04b5821001080625j22517f1i22ec3495d8d1e53b@mail.gmail.com>
	<4B4742A8.1000708@free.fr>  <1263268449.14592.53.camel@localhost>
Reply-To: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6267856188547123392=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1263268449.14592.53.camel@localhost>
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
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Ciprian Dorin,
	Craciun" <ciprian.craciun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org


--===============6267856188547123392==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2ERdDDOuQSdHUFGFw513"


--=-2ERdDDOuQSdHUFGFw513
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-01-11 at 22:54 -0500, Michael H. Warfield wrote:=20
> Added lxc-devel to the cc list since this seems to be more appropriate
> over there (maybe) and I've just joined that one as well.
>=20
> On Fri, 2010-01-08 at 15:35 +0100, Daniel Lezcano wrote:=20
> > Ciprian Dorin, Craciun wrote:
> > > On Fri, Jan 8, 2010 at 4:17 PM, Daniel Lezcano <daniel.lezcano@free.f=
r> wrote:
> > >  =20
> > >> Ciprian Dorin, Craciun wrote:
> > >>    =20
> > >>>    Hy all!
> > >>>
> > >>>    Today I've started to play with the LXC containers, and I've got=
 a
> > >>> question: when starting a container (with it's own mount point
> > >>> namespace), and I do a `cat /proc/mounts` I also see the mount poin=
ts
> > >>> from my host system.
> > >>>
> > >>>    So the question is: how can I force `lxc-create` to remove any
> > >>> uneeded mount points (maybe all)?
> > >>>
> > >>>      =20
> > >> Committed today :)
> > >>
> > >> http://git.lab.toulouse-stg.fr.ibm.com/?p=3Dlxc.git;a=3Dcommit;h=3De=
d83715df7666879116d1657b1dd54a8fc6513f6
> > >>    =20

> > Oops, this one:

> > http://lxc.git.sourceforge.net/git/gitweb.cgi?p=3Dlxc/lxc;a=3Dcommit;h=
=3Dbf601689a9e0cea1ceaf17e4f7f853f5392c2827

> Nice.  This is EXACTLY what I've been looking for as well.  Only problem
> is...  It didn't work.  It complains about:

> lxc-start: could not umount 1 mounts"

> Then terminates saying it can't start the container.

> When I throw in some debugging prints, I find out that it's complaining
> that it can't umount {pivotdir}/dev.  Commented out the return -1's in
> that routine so it starts the container anyways and jump into the
> running container and I discover that {pivotdir}/dev/shm is still
> mounted even though it thinks it umounted it.  I can see from the
> debugging prints that it seems to have successfully umount it (the
> debugging message indicates that it umounted it - so it saw it had it
> and tried and got a good return from the attempt) but it's apparently
> still mount.  If I umount that {pivotdir}/dev/shm inside the container,
> I can then umount {pivotdir}/dev and {pivotdir}.=20

> Tried it both by defining lxc.pivotdir and by letting it choose a
> temporary one.  Tried two different containers.  Same result.

:

Crud...  I always forget to mention SOMETHING...

On the host system /dev/shm is a tmpfs file system.

=46rom mount:

tmpfs on /dev/shm type tmpfs (rw)

It's in my /etc/fstab like this:

tmpfs  /dev/shm  tmpfs   defaults        0 0

Seems to be that way on all my Fedora and CentOS systems.  I can umount
that in the host system (doesn't SEEM to do any harm) and then lxc-start
works just fine and can pivot the root and unmount everything.  Seems to
be something to do with tmpfs.

> Of course we also have the strange "rootfs" entry there as well.

> Host system is Fedora 12.
> Host kernel is: 2.6.31.9-174.fc12.i686
> Guest system in each case is CentOS 5.4
>=20
> Regards,
> Mike

Mike
--=20
Michael H. Warfield (AI4NB) | (770) 985-6132 |  mhw-BetbSzk+GohWk0Htik3J/w@public.gmane.org
   /\/\|=3Dmhw=3D|\/\/          | (678) 463-0932 |  http://www.wittsend.com=
/mhw/
   NIC whois: MHW9          | An optimist believes we live in the best of a=
ll
 PGP Key: 0x674627FF        | possible worlds.  A pessimist is sure of it!

--=-2ERdDDOuQSdHUFGFw513
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEVAwUAS0v0rMDrlnVnRif/AQLcJAgAhkAEtdPJI5zWCqLZKxtER9WKTlfaqEyK
/H6JKQ/czS9DupPnZ9LI0EMR7Wgq18mBGZzv+yds5SIjxgbvf87wqUbUqjWX5cYL
L6zJVMAj10O/OQqeMJAugNzG5j6uZjFGqdjsAxuCa8BS2cKMabKA8ltgVqwgp42G
xAfaGFYpG4bLG1dl73uPhBCviHiAEtXl5Hgb54SVVaKgZP56SGH+U8fy+dYsW4ff
swlm7qaIQanorR2kqNjYYDsGZ4657AtqQbjYU53GhQjYFhRbzcDuKUk0nnpbfPpG
sBL93EdwHC6cneqn6U/HT95fr2uZ4rZuOYn4aRpQnvS7YIExfUQNbQ==
=eBhl
-----END PGP SIGNATURE-----

--=-2ERdDDOuQSdHUFGFw513--


--===============6267856188547123392==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============6267856188547123392==--
