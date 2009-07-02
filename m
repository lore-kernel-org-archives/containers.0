From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 5/9] [RFC] Remove cgroup_subsys.root pointer
Date: Thu, 2 Jul 2009 11:04:48 +0200
Message-ID: <20090702090447.GD4305__33930.4536967122$1246525654$gmane$org@localdomain>
References: <20090702020624.14469.47066.stgit@menage.mtv.corp.google.com>
	<20090702021118.14469.2107.stgit@menage.mtv.corp.google.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8547795916222777277=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090702021118.14469.2107.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
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
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============8547795916222777277==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-21710-1246525464-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-21710-1246525464-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 01, 2009 at 07:11:18PM -0700, Paul Menage wrote:
> [RFC] Remove cgroup_subsys.root pointer
>=20
> In preparation for supporting cgroup subsystems that can be bound to
> multiple hierarchies, remove the "root" pointer and associated list
> structures.  Subsystem hierarchy membership is now determined entirely
> through the subsystem bitmasks in struct cgroupfs_root.
>=20
> Minor changes include:
>   - root_list now includes the inactive root
>   - for_each_active_root() -> for_each_root()
>   - for_each_subsys() is now guaranteed to be in subsys_id order
>=20

[...]

> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index dede632..8b1b92f 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c

[...]

> @@ -191,13 +182,36 @@ static int notify_on_release(const struct cgroup *c=
grp)
>   * for_each_subsys() allows you to iterate on each subsystem attached to
>   * an active hierarchy
>   */
> +static inline struct cgroup_subsys *nth_ss(int n)
> +{
> +	return (n >=3D CGROUP_SUBSYS_COUNT) ? NULL : subsys[n];
> +}
>  #define for_each_subsys(_root, _ss) \
> -list_for_each_entry(_ss, &_root->subsys_list, sibling)
> +for (_ss =3D nth_ss(find_first_bit(&(_root)->subsys_bits, CGROUP_SUBSYS_=
COUNT));\
> +	    _ss !=3D NULL;						      \
> +    _ss =3D nth_ss(find_next_bit(&(_root)->subsys_bits, CGROUP_SUBSYS_CO=
UNT,    \
> +			       _ss->subsys_id + 1)))
> =20
> -/* for_each_active_root() allows you to iterate across the active hierar=
chies */
> -#define for_each_active_root(_root) \
> +
> +/* for_each_root() allows you to iterate across all hierarchies */
> +#define for_each_root(_root) \
>  list_for_each_entry(_root, &roots, root_list)
> =20
> +/* Find the root for a given subsystem */
> +static struct cgroupfs_root *find_root(struct cgroup_subsys *ss)
> +{
> +	int id =3D ss->subsys_id;
> +	struct cgroupfs_root *root, *res =3D NULL;
> +	for_each_root(root) {
> +		if (root->subsys_bits && (1UL << id)) {
Should be &, not && ------------------^^

Louis

> +			BUG_ON(res);
> +			res =3D root;
> +		}
> +	}
> +	BUG_ON(!res);
> +	return res;
> +}
> +
>  /* the list of cgroups eligible for automatic release. Protected by
>   * release_list_lock */
>  static LIST_HEAD(release_list);

[...]

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-21710-1246525464-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkpMeC8ACgkQVKcRuvQ9Q1QALwCdERKaivSiq+ZotPM6H5ndrmxN
p0wAoKDxBWK6jwG/oLQixTBlkDF+kriZ
=D/io
-----END PGP SIGNATURE-----

--=_bohort-21710-1246525464-0001-2--

--===============8547795916222777277==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8547795916222777277==--
