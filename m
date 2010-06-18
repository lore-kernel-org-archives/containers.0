From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Fri, 18 Jun 2010 10:20:33 +0200
Message-ID: <20100618082033.GD16877@hawkmoon.kerlabs.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <20100617212003.GA4182@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-8946-1276849169-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100617212003.GA4182@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-8946-1276849169-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 17/06/10 23:20 +0200, Oleg Nesterov wrote:
> On 06/16, Louis Rilling wrote:
> >
> > Detached tasks are not seen by zap_pid_ns_processes()->sys_wait4(), so
> > that release_task()->proc_flush_task() of container init can be called
> > before it is for some detached tasks in the namespace.
> >
> > Pin proc_mnt's in copy_process(), so that proc_flush_task() becomes safe
> > whatever the ordering of tasks.
>=20
> I must have missed something, but can't we just move mntput() ?

See the log of the commit introducing pid_ns_release_proc() (6f4e6433):

    Sice the namespace holds the vfsmnt, vfsmnt holds the superblock and the
    superblock holds the namespace we must explicitly break this circle to =
destroy
    all the stuff.  This is done after the init of the namespace dies.  Run=
ning a
    few steps forward - when init exits it will kill all its children, so no
    proc_mnt will be needed after its death.

Thanks,

Louis

>=20
> Oleg.
>=20
> --- x/kernel/pid_namespace.c
> +++ x/kernel/pid_namespace.c
> @@ -110,6 +110,9 @@ static void destroy_pid_namespace(struct
>  {
>  	int i;
> =20
> +	if (ns->proc_mount)
> +		mntput(ns->proc_mount);
> +
>  	for (i =3D 0; i < PIDMAP_ENTRIES; i++)
>  		kfree(ns->pidmap[i].page);
>  	kmem_cache_free(pid_ns_cachep, ns);
> --- x/fs/proc/base.c
> +++ x/fs/proc/base.c
> @@ -2745,10 +2745,6 @@ void proc_flush_task(struct task_struct=20
>  		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
>  					tgid->numbers[i].nr);
>  	}
> -
> -	upid =3D &pid->numbers[pid->level];
> -	if (upid->nr =3D=3D 1)
> -		pid_ns_release_proc(upid->ns);
>  }
> =20
>  static struct dentry *proc_pid_instantiate(struct inode *dir,
>=20

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-8946-1276849169-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwbLFEACgkQVKcRuvQ9Q1TsnACgm8EtzQNDlCvEhIB6XBu3GjAl
ajUAoL2n1ZFnH9IGzcBwCpJZsZdw2P7Q
=Xqh6
-----END PGP SIGNATURE-----

--=_bohort-8946-1276849169-0001-2--
