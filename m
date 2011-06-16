From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
	Vpid:)
Date: Thu, 16 Jun 2011 14:35:55 +0200
Message-ID: <20110616123554.GA7230@hawkmoon.kerlabs.com>
References: <20110615145527.4016.70157.stgit@bahia.local> <20110615184625.GA15573@redhat.com> <1308222107.8230.49.camel@bahia.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-23791-1308227667-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1308222107.8230.49.camel@bahia.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-23791-1308227667-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 16/06/11 13:01 +0200, Greg Kurz wrote:
> On Wed, 2011-06-15 at 20:46 +0200, Oleg Nesterov wrote:
> > On 06/15, Greg Kurz wrote:
> > >
> > > @@ -176,6 +177,17 @@ static inline void task_state(struct seq_file *m=
, struct pid_namespace *ns,
> > >  		if (tracer)
> > >  			tpid =3D task_pid_nr_ns(tracer, ns);
> > >  	}
> > > +	actpid =3D 0;
> > > +	sighand =3D rcu_dereference(p->sighand);
> > > +	if (sighand) {
> > > +		struct pid_namespace *pid_ns;
> > > +		unsigned long flags;
> > > +		spin_lock_irqsave(&sighand->siglock, flags);
> >=20
> > Well. This is not exactly right. We have lock_task_sighand() for this.
> >=20
>=20
> I see... ->sighand could change so we need the for(;;) loop in
> __lock_task_sighand() to be sure we have the right pointer, correct ?
> By the way, if we use lock_task_sighand() we'll end up with nested
> rcu_read_lock(): it will work but I don't know how it may affect
> performance...

rcu_read_lock() is very cheap.

>=20
> > But. Why do you need ->siglock? Why rcu_read_lock() is not enough?
> >=20
>=20
> Because there's a race with
> __exit_signal()->__unhash_process()->detach_pid() that can break
> task_active_pid_ns() and rcu won't help here (unless *perhaps* by
> modifying __exit_signal() but I don't want to mess with such a critical
> path).

In case of race, the only risk is that task_active_pid_ns() returns NULL.
Otherwise, RCU guarantees that the pid_ns will stay alive (see below).

>=20
> > Hmm. You don't even need pid_ns afaics, you could simply look at
> > pid->numbers[pid->level].
> >=20
>=20
> True but I will have the same problem: detach_pid() nullifies the pid.

But the pid won't be freed until an RCU grace period expires. See free_pid(=
). So
the non-determinism here is when /proc/<pid>/status is read at the same as
threaded execve() or task's exit(), in which case a stale pid (execve()) or
no pid (exit after __unhash_process()) can be accessed. This does not look =
like
a big deal...

Thanks,

Louis

>=20
> Thanks for your comments.
>=20
> --
> Greg
>=20
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-23791-1308227667-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk35+KoACgkQVKcRuvQ9Q1QJOwCfV4wz61ec6uOjRYtDGDfQHB3b
EEIAoMjwn6rtvDkgNsNBd3a4BgY9nfUl
=KK+P
-----END PGP SIGNATURE-----

--=_bohort-23791-1308227667-0001-2--
