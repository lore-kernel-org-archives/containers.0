From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] linux-cr: nested pid namespaces (v3)
Date: Wed, 24 Mar 2010 10:56:09 +0100
Message-ID: <20100324095609.GU19240@hawkmoon.kerlabs.com>
References: <20100323051839.GA16123@us.ibm.com> <20100323071431.GC4242@localdomain> <20100323135244.GA20910@hallyn.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-9795-1269424482-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100323135244.GA20910@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-9795-1269424482-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 23/03/10  8:52 -0500, Serge E. Hallyn wrote:
> Quoting Louis Rilling (Louis.Rilling@kerlabs.com):
>=20
> Hi Louis, thanks again for reviewing.

No problem, thanks to you for your patience.

>=20
> > To me the real reason is to anticipate pid namespace unsharing. And this
> > together with setns() will need to re-consider much of the namespace C/R
> > logic imho. For instance, checkpoint could be done from a foreign task
> > having entered the container, leak detection should take such foreign
> > tasks into account (see example below), etc.
>=20
> ...
>=20
> > > =20
> > > @@ -293,10 +295,15 @@ static int may_checkpoint_task(struct ckpt_ctx =
*ctx, struct task_struct *t)
> > >  		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
> > >  		ret =3D -EPERM;
> > >  	}
> > > -	/* no support for >1 private pidns */
> > > -	if (nsproxy->pid_ns !=3D ctx->root_nsproxy->pid_ns) {
> > > -		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
> > > -		ret =3D -EPERM;
> > > +	/* pidns must be descendent of root_nsproxy */
> > > +	pidns =3D nsproxy->pid_ns;
> >=20
> > In case of unshared pid namespace, task_active_pid_ns(t) should be chec=
ked
> > instead of t->nsproxy->pid_ns: we can't checkpoint a foreign task.
>=20
> Unsharing can only be done to a child ns, so it wouldn't be foreign.
> Though of course that depends on which one ends up being the original
> pid_ns (see below).

If task was created in an ancestor pid namespace of the checkpointed contai=
ner,
I call it foreign and I don't think that we want to checkpoint it together =
with
the container.

>=20
> Now, regarding supporting unshared pid_ns, I think that (1) it will
> be a simple matter of separately doing
> 	pid_pidns =3D checkpoint_obj(task_active_pid_ns(task));
> 	nsp_pidns =3D checkpoint_obj(task->nsproxy->pid_ns);
> since we will need to record both.

Agreed. As long as both of those namespaces are descendant of the container=
's
root pid namespace.

> In addition, (2) the most
> recent emails I see on the topics are still unsure about whether
> we want to have the unshared pid_ns be reflected in=20
> ns_of_pid(task_pid(task)) or task->nsproxy->pid_ns, so I think
> we'll just have to handle them when they are implemented.

I did not notice any (convincing) argument in favor of changing
ns_of_pid(task_pid(task)) (aka task_active_pid_ns(task)), and I like how Er=
ic's
proposal is simple to implement. But I agree with you that pid namespaces
handling should not be re-worked before a more definitive approach is
implemented.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-9795-1269424482-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkup4bkACgkQVKcRuvQ9Q1SoFgCgiagwsx6zwewtv4CH9ltQeE+S
MsEAoM5nHnCbbh2CGbsOVaBGbEdO9qe1
=Tll5
-----END PGP SIGNATURE-----

--=_bohort-9795-1269424482-0001-2--
