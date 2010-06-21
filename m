From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Mon, 21 Jun 2010 13:15:54 +0200
Message-ID: <20100621111554.GJ16877@hawkmoon.kerlabs.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-14088-1277118888-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618175541.GA13680@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-14088-1277118888-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 18/06/10 19:55 +0200, Oleg Nesterov wrote:
> On 06/18, Louis Rilling wrote:
> >
> > On 18/06/10 18:08 +0200, Oleg Nesterov wrote:
> > >
> > > Not sure I ever understood this code. Certainly I can't say I underst=
and
> > > it now. Still, do we really need this circle? I am almost sure the pa=
tch
> > > below is not right (and it wasn't tested at all), but could you take a
> > > look?
> >
> > I won't pretend understanding better than you do. Still I can try to gi=
ve my 2
> > cents.
> >
> > Overall, I don't feel comfortable at being able to have a living proc_m=
nt
> > with a dead pid_ns.
>=20
> Yes, this should be fixed, I already realized this. work->func(ns) is
> called when ns is already fixed.
>=20
> Otherwise, nobody should use ns->proc_mount when ns is already dead/freed.

I meant the opposite. proc_mnt can be kept mounted somewhere, and accesses =
to it
will likely try to access (freed) pid_ns from it.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-14088-1277118888-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwfSekACgkQVKcRuvQ9Q1TPTACeKP9VO9Zm9Acfa+vBrzsgGC1d
KIwAoJgCrFZoxZnQwp7EOmr0kKkGymbC
=OTCR
-----END PGP SIGNATURE-----

--=_bohort-14088-1277118888-0001-2--
