From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Mon, 21 Jun 2010 13:11:27 +0200
Message-ID: <20100621111127.GI16877@hawkmoon.kerlabs.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <4C19F0A3.2050707@parallels.com> <m1631hdbdu.fsf@fess.ebiederm.org> <20100617213638.GB4182@redhat.com> <20100618082738.GE16877@hawkmoon.kerlabs.com> <20100618162734.GB7404@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-13922-1277118621-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618162734.GB7404@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-13922-1277118621-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 18/06/10 18:27 +0200, Oleg Nesterov wrote:
> On 06/18, Louis Rilling wrote:
> >
> > On 17/06/10 23:36 +0200, Oleg Nesterov wrote:
> > > On 06/17, Eric W. Biederman wrote:
> > > >
> > > > The task->children isn't changed until __unhash_process() which runs
> > > > after flush_proc_task().
> > >
> > > Yes. But this is only the current implementation detail.
> > > It would be nice to cleanup the code so that EXIT_DEAD tasks are
> > > never sit in ->children list.
> > >
> > > > So we should be able to come up with
> > > > a variant of do_wait() that zap_pid_ns_processes can use that does
> > > > what we need.
> > >
> > > See above...
> > >
> > > Even if we modify do_wait() or add the new variant, how the caller
> > > can wait for EXIT_DEAD tasks? I don't think we want to modify
> > > release_task() to do __wake_up_parent() or something similar.
> >
> > Indeed, I was thinking about calling __wake_up_parent() from release_ta=
sk()
> > once parent->children becomes empty.
> >
> > Not sure about the performance impact though. Maybe some WAIT_NO_CHILDR=
EN flag
> > in parent->signal could limit it. But if EXIT_DEAD children are removed=
 from
> > ->children before release_task(), I'm afraid that this becomes impossib=
le.
>=20
> Thinking more, even the current do_wait() from zap_pid_ns_processes()
> is not really good. Suppose that some none-init thread is ptraced, then
> zap_pid_ns_processes() will hange until the tracer does do_wait() or
> exits.

Is this really a bad thing? If somebody ptraces a task in a pid namespace, =
that
sounds reasonable to have this namespace (and it's init task) pinned.

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-13922-1277118621-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwfSN8ACgkQVKcRuvQ9Q1R4DwCfR9yzSs3WDTbFTp2O3dO3gSrE
ivkAoKzzTC8iwc4pLEf76ok6riQJ0Qv/
=P5Tp
-----END PGP SIGNATURE-----

--=_bohort-13922-1277118621-0001-2--
