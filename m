From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 5/6] Makes procs file writable to move all threads by
	tgid at once
Date: Fri, 24 Jul 2009 12:08:07 +0200
Message-ID: <20090724100807.GG11101__2181.15006941861$1248430217$gmane$org@hawkmoon.kerlabs.com>
References: <20090724032033.2463.79256.stgit@hastromil.mtv.corp.google.com>
	<20090724032200.2463.82408.stgit@hastromil.mtv.corp.google.com>
	<20090724100220.GF11101@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0298550947725267179=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090724100220.GF11101-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
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
To: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, menage
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============0298550947725267179==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-21203-1248430057-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-21203-1248430057-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 24/07/09 12:02 +0200, Louis Rilling wrote:
> Hi Ben,
>=20
> On 23/07/09 20:22 -0700, Ben Blum wrote:
> > Makes procs file writable to move all threads by tgid at once
> >=20
> > This patch adds functionality that enables users to move all threads in=
 a
> > threadgroup at once to a cgroup by writing the tgid to the 'cgroup.proc=
s'
> > file. This current implementation makes use of a rwsem that's taken for
> > reading in the fork() path to prevent newly forking threads within the
> > threadgroup from "escaping" while moving is in progress.
> >=20
> > Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>=20

[...]

> > +int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> > +{
> > +	int retval;
> > +	struct cgroup_subsys *ss;
> > +	struct cgroup *oldcgrp;
> > +	struct css_set *oldcg;
> > +	struct cgroupfs_root *root =3D cgrp->root;
> > +	int subsys_id;
> > +	/* threadgroup list cursor */
> > +	struct task_struct *tsk;
> > +	/*
> > +	 * we need to make sure we have css_sets for all the tasks we're
> > +	 * going to move -before- we actually start moving them, so that in
> > +	 * case we get an ENOMEM we can bail out before making any changes.
> > +	 */
> > +	struct list_head newcg_list;
> > +	struct cg_list_entry *cg_entry;
> > +
> > +	/* first, make sure this came from a valid tgid */
> > +	if (!thread_group_leader(leader))
> > +		return -EINVAL;
> > +	/*
> > +	 * check that we can legitimately attach to the cgroup.
> > +	 */
> > +	for_each_subsys(root, ss) {
> > +		if (ss->can_attach) {
> > +			retval =3D ss->can_attach(ss, cgrp, leader);
> > +			if (retval)
> > +				return retval;
> > +		}
> >  	}
>=20
> So the semantics of ->can_attach() becomes: if called for a thread group =
leader,
> the result should be valid for the whole thread group, even if only the t=
hread
> group leader is being attached. This looks a bit fuzzy and thus not desir=
able.
> Why not checking ->can_attach() for all threads (and lock cgroup_fork_mut=
ex
> earlier)?

Ok I've read the next patch. Patch 6 should really go before this one, both=
 for
better understanding and safety.

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-21203-1248430057-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkppiAcACgkQVKcRuvQ9Q1T8WQCeJdh1nPjuNw0IPoALo3/Omb4H
p4oAoIfE+CN3T5BwF/uOQuemosudVqII
=tcg3
-----END PGP SIGNATURE-----

--=_bohort-21203-1248430057-0001-2--

--===============0298550947725267179==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0298550947725267179==--
