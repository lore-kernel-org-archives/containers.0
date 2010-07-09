From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [RFC][PATCH 2/2] pidns: Remove proc flush races when a pid
	namespaces are exiting.
Date: Fri, 9 Jul 2010 14:14:25 +0200
Message-ID: <20100709121425.GB18586@hawkmoon.kerlabs.com>
References: <1277399329-18087-1-git-send-email-louis.rilling@kerlabs.com> <20100624191843.GA14205@redhat.com> <20100625102303.GG3773@hawkmoon.kerlabs.com> <20100625183733.GA2627@us.ibm.com> <20100625192945.GA25532@redhat.com> <20100625212618.GA11917@us.ibm.com> <20100625212758.GA30474@redhat.com> <20100625220713.GA31123@us.ibm.com> <m1r5jd5l0v.fsf_-_@fess.ebiederm.org> <m1mxu15kv4.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-1857-1278677591-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1mxu15kv4.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-1857-1278677591-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 08/07/10 21:39 -0700, Eric W. Biederman wrote:
>=20
> Currently it is possible to put proc_mnt before we have flushed the
> last process that will use the proc_mnt to flush it's proc entries.
>=20
> This race is fixed by not flushing proc entries for dead pid
> namespaces, and calling pid_ns_release_proc unconditionally from
> zap_pid_ns_processes after the pid namespace has been declared dead.

One comment below.

>=20
> To ensure we don't unnecessarily leak any dcache entries with skipped
> flushes pid_ns_release_proc flushes the entire proc_mnt when it is
> called.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  fs/proc/base.c         |    9 +++++----
>  fs/proc/root.c         |    3 +++
>  kernel/pid_namespace.c |    1 +
>  3 files changed, 9 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index acb7ef8..e9d84e1 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -2742,13 +2742,14 @@ void proc_flush_task(struct task_struct *task)
> =20
>  	for (i =3D 0; i <=3D pid->level; i++) {
>  		upid =3D &pid->numbers[i];
> +
> +		/* Don't bother flushing dead pid namespaces */
> +		if (test_bit(PIDNS_DEAD, &upid->ns->flags))
> +			continue;
> +

IMHO, nothing prevents zap_pid_ns_processes() from setting PIDNS_DEAD and
calling pid_ns_release_proc() right now. zap_pid_ns_processes() does not wa=
it
for EXIT_DEAD (self-reaping) children to be released.

Thanks,

Louis

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
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index cfdf032..2298fdd 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -209,5 +209,8 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
> =20
>  void pid_ns_release_proc(struct pid_namespace *ns)
>  {
> +	/* Flush any cached proc dentries for this pid namespace */
> +	shrink_dcache_parent(ns->proc_mnt->mnt_root);
> +
>  	mntput(ns->proc_mnt);
>  }
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index 92032d1..43dec5d 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -189,6 +189,7 @@ void zap_pid_ns_processes(struct pid_namespace *pid_n=
s)
>  		rc =3D sys_wait4(-1, NULL, __WALL, NULL);
>  	} while (rc !=3D -ECHILD);
> =20
> +	pid_ns_release_proc(pid_ns);
>  	acct_exit_ns(pid_ns);
>  	return;
>  }
> --=20
> 1.6.5.2.143.g8cc62
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-1857-1278677591-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkw3EqEACgkQVKcRuvQ9Q1QufQCeMXHzzCwGLKwAKW8ItxR+7IPW
nL8Anigv1MNKqViTr8yBfHCKduoEmljI
=MuRK
-----END PGP SIGNATURE-----

--=_bohort-1857-1278677591-0001-2--
