From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
	Vpid:)
Date: Thu, 16 Jun 2011 17:08:12 +0200
Message-ID: <20110616150811.GA15328@hawkmoon.kerlabs.com>
References: <20110615145527.4016.70157.stgit@bahia.local> <20110615184625.GA15573@redhat.com> <1308222107.8230.49.camel@bahia.local> <20110616123554.GA7230@hawkmoon.kerlabs.com> <1308229251.8230.77.camel@bahia.local> <20110616132551.GB7230@hawkmoon.kerlabs.com> <20110616145044.GA25379@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-26591-1308236803-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110616145044.GA25379@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-26591-1308236803-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16/06/11 16:51 +0200, Oleg Nesterov wrote:
> On 06/16, Louis Rilling wrote:
> >
> > On 16/06/11 15:00 +0200, Greg Kurz wrote:
> > > peeking into pid->numbers.
> >
> > It ends like open-coding an optimized version of task_pid_vnr(). If the
> > optimization is really important (I guess this depends on the depth of =
recursive
> > pid namespaces), it would be better to re-write task_pid_vnr().
>=20
> No, task_pid_vnr(p) is different, it should use the caller's namespace.

Damned, I read __task_pid_nr_ns() too quickly. Thanks for correcting me.

>=20
> Just in case, I agree there is no need to optimize this code. The simpler
> the better. I mentioned pid->numbers[pid->level] just to point that all
> we need is task_pid() itself, there are no subtle races which need the
> locking.

Agreed.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-26591-1308236803-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk36HFsACgkQVKcRuvQ9Q1RkcACfaBKcZTofy/85sHd8OtyR9Xj9
KQEAmwTqFHbfHIyumGIC1Cu2tTHtl6YY
=eXhP
-----END PGP SIGNATURE-----

--=_bohort-26591-1308236803-0001-2--
