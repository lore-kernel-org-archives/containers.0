From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Mon, 21 Jun 2010 13:09:10 +0200
Message-ID: <20100621110910.GH16877@hawkmoon.kerlabs.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com> <20100618082033.GD16877@hawkmoon.kerlabs.com> <20100618111554.GA3252@redhat.com> <20100618160849.GA7404@redhat.com> <20100618173320.GG16877@hawkmoon.kerlabs.com> <20100618175541.GA13680@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-13816-1277118485-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618175541.GA13680@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-13816-1277118485-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 18/06/10 19:55 +0200, Oleg Nesterov wrote:
> On 06/18, Louis Rilling wrote:
> > > @@ -74,7 +74,7 @@ static int proc_get_sb(struct file_syste
> > >  		ei =3D PROC_I(sb->s_root->d_inode);
> > >  		if (!ei->pid) {
> > >  			rcu_read_lock();
> > > -			ei->pid =3D get_pid(find_pid_ns(1, ns));
> > > +			ei->pid =3D find_pid_ns(1, ns);
> >
> > I don't think that this is correct. IIUC, proc_delete_inode() calls put=
_pid() on
> > ei->pid.
>=20
> Yes,
>=20
> > So either a special case is added in proc_delete_inode(), or we try to
> > live with get_pid() here. I'm actually not sure that we can pretend tha=
t this
> > pid remains valid if we don't get_pid() here.
>=20
> But please see another change below,
>=20
> > > +static void proc_mntput(struct work_struct *work)
> > >  {
> > > +	struct pid_namespace *ns =3D container_of(work, struct pid_namespac=
e, proc_put);
> > > +
> > > +	PROC_I(ns->proc_mnt->mnt_sb->s_root->d_inode)->pid =3D NULL;
> > >  	mntput(ns->proc_mnt);
> > >  }
>=20
> it clears ei->pid.
>=20
> We are called from free_pid_ns() path, this ->pid must not have any refer=
ence.
> Any get_pid() implies get_pid_ns().
>=20
> What do you think?

Hm, I didn't look close enough. Sorry about that. However, I'm still concer=
ned
with this since this pid can have been freed right after container init's
release_task(), and I don't see how it is guaranteed that nobody still trie=
s to
access this proc_mnt.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-13816-1277118485-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwfSFYACgkQVKcRuvQ9Q1SWFQCfVx7cLGjWbEa3vuJFs+u2Wx1w
xXoAn0VVYhXTGeCjKwm06NntPXHRB+jG
=gZ41
-----END PGP SIGNATURE-----

--=_bohort-13816-1277118485-0001-2--
