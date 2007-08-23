From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH] Containers: Avoid lockdep warning
Date: Thu, 23 Aug 2007 11:46:06 +0200
Message-ID: <1187862366.6114.351.camel@twins>
References: <20070822231710.E90B53D66A9@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5464846740907418506=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070822231710.E90B53D66A9@localhost>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


--===============5464846740907418506==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-rDRbp/AAssXovo1KQmve"


--=-rDRbp/AAssXovo1KQmve
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-22 at 16:17 -0700, Paul Menage wrote:
> I think this is the right way to handle the lockdep false-positive in
> the current containers patches, but I'm not that familiar with lockdep
> so any suggestions for a better approach are welcomed.
>=20
>=20
> In order to avoid a false-positive lockdep warning, we lock the root
> inode of a new filesystem mount prior to taking container_mutex, to
> preserve the invariant that container_mutex nests inside
> inode->i_mutex. In order to prevent a lockdep false positive when
> locking i_mutex on a newly-created container directory inode we use
> mutex_lock_nested(), with a nesting level of I_MUTEX_CHILD since the
> new inode will ultimately be a child directory of the parent whose
> i_mutex is nested outside of container_mutex.

So the normal order is:

  inode->i_mutex
    container_mutex (I_MUTEX_NORMAL)

and there is a one off reversal where we take container_mutex before
inode->i_mutex, which is safe because the inode is fresh, so nobody
could have possibly taken it to form the deadlock.

mutex_lock_nested() is indeed the proper annotation.

Using I_MUTEX_CHILD forms the chain:

  container_mutex
    inode->i_mutex (I_MUTEX_CHILD)

In order for this to become a problem there would need to be a:

 inode->i_mutex (I_MUTEX_CHILD)
   inode->i_mutex (I_MUTEX_NORMAL)

chain, which I suppose is precluded to exists on basis of common
sense :-)

> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Acked-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>

>=20
> ---
>  kernel/container.c |   17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
>=20
> Index: container-2.6.23-rc3-mm1/kernel/container.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- container-2.6.23-rc3-mm1.orig/kernel/container.c
> +++ container-2.6.23-rc3-mm1/kernel/container.c
> @@ -966,13 +966,16 @@ static int container_get_sb(struct file_
>  	} else {
>  		/* New superblock */
>  		struct container *cont =3D &root->top_container;
> +		struct inode *inode;
> =20
>  		BUG_ON(sb->s_root !=3D NULL);
> =20
>  		ret =3D container_get_rootdir(sb);
>  		if (ret)
>  			goto drop_new_super;
> +		inode =3D sb->s_root->d_inode;
> =20
> +		mutex_lock(&inode->i_mutex);
>  		mutex_lock(&container_mutex);
> =20
>  		/*
> @@ -985,12 +988,14 @@ static int container_get_sb(struct file_
>  		ret =3D allocate_cg_links(css_group_count, &tmp_cg_links);
>  		if (ret) {
>  			mutex_unlock(&container_mutex);
> +			mutex_unlock(&inode->i_mutex);
>  			goto drop_new_super;
>  		}
> =20
>  		ret =3D rebind_subsystems(root, root->subsys_bits);
>  		if (ret =3D=3D -EBUSY) {
>  			mutex_unlock(&container_mutex);
> +			mutex_unlock(&inode->i_mutex);
>  			goto drop_new_super;
>  		}
> =20
> @@ -1030,16 +1035,8 @@ static int container_get_sb(struct file_
>  		BUG_ON(!list_empty(&cont->children));
>  		BUG_ON(root->number_of_containers !=3D 1);
> =20
> -		/*
> -		 * I believe that it's safe to nest i_mutex inside
> -		 * container_mutex in this case, since no-one else can
> -		 * be accessing this directory yet. But we still need
> -		 * to teach lockdep that this is the case - currently
> -		 * a containerfs remount triggers a lockdep warning
> -		 */
> -		mutex_lock(&cont->dentry->d_inode->i_mutex);
>  		container_populate_dir(cont);
> -		mutex_unlock(&cont->dentry->d_inode->i_mutex);
> +		mutex_unlock(&inode->i_mutex);
>  		mutex_unlock(&container_mutex);
>  	}
> =20
> @@ -1529,7 +1526,7 @@ static int container_create_file(struct=20
> =20
>  		/* start with the directory inode held, so that we can
>  		 * populate it without racing with another mkdir */
> -		mutex_lock(&inode->i_mutex);
> +		mutex_lock_nested(&inode->i_mutex, I_MUTEX_CHILD);
>  	} else if (S_ISREG(mode)) {
>  		inode->i_size =3D 0;
>  		inode->i_fop =3D &container_file_operations;

--=-rDRbp/AAssXovo1KQmve
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGzVdeXA2jU0ANEf4RAny4AJwMbeXPK2INFG23uD6099mFmS0ydQCgg5FK
Ig84DUH5ImlmxZh1VUfSXkE=
=rxGM
-----END PGP SIGNATURE-----

--=-rDRbp/AAssXovo1KQmve--


--===============5464846740907418506==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5464846740907418506==--
