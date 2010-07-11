From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH 01/24] pidns: Remove races by stopping the caching of
	proc_mnt
Date: Sun, 11 Jul 2010 16:14:07 +0200
Message-ID: <20100711141406.GD18586@hawkmoon.kerlabs.com>
References: <20100625192945.GA25532@redhat.com> <20100625212618.GA11917@us.ibm.com> <20100625212758.GA30474@redhat.com> <20100625220713.GA31123@us.ibm.com> <m1r5jd5l0v.fsf_-_@fess.ebiederm.org> <m1mxu15kv4.fsf_-_@fess.ebiederm.org> <20100709121425.GB18586@hawkmoon.kerlabs.com> <m1lj9k4xfx.fsf@fess.ebiederm.org> <20100709141324.GC18586@hawkmoon.kerlabs.com> <m1aaq04ph2.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-22142-1278857570-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1aaq04ph2.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>, Oleg Nesterov <oleg@redhat.com>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-22142-1278857570-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 09/07/10  8:58 -0700, Eric W. Biederman wrote:
>=20
> Having proc reference the pid_namespace and the pid_namespace
> reference proc is a serious reference counting problem, which has
> resulted in both leaks and use after free problems.  Mount already
> knows how to go from a pid_namespace to a mount of proc, so we don't
> need to cache the proc mount.
>=20
> To do this I introduce get_proc_mnt and replace pid_ns->proc_mnt users
> with it. Additionally I remove pid_ns_(prepare|release)_proc as they
> are now unneeded.
>=20
> This is slightly less efficient but it is much easier to avoid the
> races.  If efficiency winds up being a problem we can revisit our data
> structures.

IIUC, the difference between this solution and the first one I proposed is =
that
instead of pinning proc_mnt with mntget() at copy_process()-time, proc_mnt =
is
looked for and, if possible, mntget() at release_task()-time.

Could you elaborate on the trade-off, that is accessing proc_mnt at
copy_process()-time vs looking up proc_mnt at release_task()-time?

Thanks,

Louis

>=20
> Reported-by: Louis Rilling <Louis.Rilling@kerlabs.com>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  arch/um/drivers/mconsole_kern.c |    4 +++-
>  fs/hppfs/hppfs.c                |    2 +-
>  fs/proc/base.c                  |   13 +++++++------
>  fs/proc/root.c                  |   15 ++-------------
>  include/linux/pid_namespace.h   |    3 ---
>  include/linux/proc_fs.h         |   13 +------------
>  kernel/fork.c                   |    6 ------
>  kernel/sysctl_binary.c          |    3 ++-
>  8 files changed, 16 insertions(+), 43 deletions(-)
>=20
> diff --git a/arch/um/drivers/mconsole_kern.c b/arch/um/drivers/mconsole_k=
ern.c
> index de317d0..e89f72c 100644
> --- a/arch/um/drivers/mconsole_kern.c
> +++ b/arch/um/drivers/mconsole_kern.c
> @@ -125,7 +125,7 @@ void mconsole_log(struct mc_request *req)
>  void mconsole_proc(struct mc_request *req)
>  {
>  	struct nameidata nd;
> -	struct vfsmount *mnt =3D current->nsproxy->pid_ns->proc_mnt;
> +	struct vfsmount *mnt;
>  	struct file *file;
>  	int n, err;
>  	char *ptr =3D req->request.data, *buf;
> @@ -134,7 +134,9 @@ void mconsole_proc(struct mc_request *req)
>  	ptr +=3D strlen("proc");
>  	ptr =3D skip_spaces(ptr);
> =20
> +	mnt =3D get_proc_mnt(task_active_pid_ns(current));
>  	err =3D vfs_path_lookup(mnt->mnt_root, mnt, ptr, LOOKUP_FOLLOW, &nd);
> +	mntput(mnt);
>  	if (err) {
>  		mconsole_reply(req, "Failed to look up file", 1, 0);
>  		goto out;
> diff --git a/fs/hppfs/hppfs.c b/fs/hppfs/hppfs.c
> index 826c3f9..79e61ab 100644
> --- a/fs/hppfs/hppfs.c
> +++ b/fs/hppfs/hppfs.c
> @@ -718,7 +718,7 @@ static int hppfs_fill_super(struct super_block *sb, v=
oid *d, int silent)
>  	struct vfsmount *proc_mnt;
>  	int err =3D -ENOENT;
> =20
> -	proc_mnt =3D mntget(current->nsproxy->pid_ns->proc_mnt);
> +	proc_mnt =3D get_proc_mnt(task_active_pid_ns(current));
>  	if (IS_ERR(proc_mnt))
>  		goto out;
> =20
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index acb7ef8..93a3ee9 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -2735,6 +2735,7 @@ void proc_flush_task(struct task_struct *task)
>  {
>  	int i;
>  	struct pid *pid, *tgid;
> +	struct vfsmount *mnt;
>  	struct upid *upid;
> =20
>  	pid =3D task_pid(task);
> @@ -2742,13 +2743,13 @@ void proc_flush_task(struct task_struct *task)
> =20
>  	for (i =3D 0; i <=3D pid->level; i++) {
>  		upid =3D &pid->numbers[i];
> -		proc_flush_task_mnt(upid->ns->proc_mnt, upid->nr,
> -					tgid->numbers[i].nr);
> -	}
> +		mnt =3D get_proc_mnt(upid->ns);
> +		if (IS_ERR(mnt))
> +			continue;
> =20
> -	upid =3D &pid->numbers[pid->level];
> -	if (upid->nr =3D=3D 1)
> -		pid_ns_release_proc(upid->ns);
> +		proc_flush_task_mnt(mnt, upid->nr, tgid->numbers[i].nr);
> +		mntput(mnt);
> +	}
>  }
> =20
>  static struct dentry *proc_pid_instantiate(struct inode *dir,
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index 4258384..c042015 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -79,7 +79,6 @@ static int proc_get_sb(struct file_system_type *fs_type,
>  		}
> =20
>  		sb->s_flags |=3D MS_ACTIVE;
> -		ns->proc_mnt =3D mnt;
>  	}
> =20
>  	simple_set_mnt(mnt, sb);
> @@ -204,18 +203,8 @@ struct proc_dir_entry proc_root =3D {
>  	.parent		=3D &proc_root,
>  };
> =20
> -int pid_ns_prepare_proc(struct pid_namespace *ns)
> +struct vfsmount *get_proc_mnt(struct pid_namespace *ns)
>  {
> -	struct vfsmount *mnt;
> -
> -	mnt =3D kern_mount_data(&proc_fs_type, ns);
> -	if (IS_ERR(mnt))
> -		return PTR_ERR(mnt);
> -
> -	return 0;
> +	return kern_mount_data(&proc_fs_type, ns);
>  }
> =20
> -void pid_ns_release_proc(struct pid_namespace *ns)
> -{
> -	mntput(ns->proc_mnt);
> -}
> diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
> index 38d1032..3feb917 100644
> --- a/include/linux/pid_namespace.h
> +++ b/include/linux/pid_namespace.h
> @@ -24,9 +24,6 @@ struct pid_namespace {
>  	struct kmem_cache *pid_cachep;
>  	unsigned int level;
>  	struct pid_namespace *parent;
> -#ifdef CONFIG_PROC_FS
> -	struct vfsmount *proc_mnt;
> -#endif
>  #ifdef CONFIG_BSD_PROCESS_ACCT
>  	struct bsd_acct_struct *bacct;
>  #endif
> diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
> index 379eaed..6b7a416 100644
> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -103,6 +103,7 @@ struct vmcore {
>  #ifdef CONFIG_PROC_FS
> =20
>  extern void proc_root_init(void);
> +struct vfsmount *get_proc_mnt(struct pid_namespace *ns);
> =20
>  void proc_flush_task(struct task_struct *task);
> =20
> @@ -116,9 +117,6 @@ extern void remove_proc_entry(const char *name, struc=
t proc_dir_entry *parent);
> =20
>  struct pid_namespace;
> =20
> -extern int pid_ns_prepare_proc(struct pid_namespace *ns);
> -extern void pid_ns_release_proc(struct pid_namespace *ns);
> -
>  /*
>   * proc_tty.c
>   */
> @@ -217,15 +215,6 @@ struct tty_driver;
>  static inline void proc_tty_register_driver(struct tty_driver *driver) {=
};
>  static inline void proc_tty_unregister_driver(struct tty_driver *driver)=
 {};
> =20
> -static inline int pid_ns_prepare_proc(struct pid_namespace *ns)
> -{
> -	return 0;
> -}
> -
> -static inline void pid_ns_release_proc(struct pid_namespace *ns)
> -{
> -}
> -
>  static inline void set_mm_exe_file(struct mm_struct *mm,
>  				   struct file *new_exe_file)
>  {}
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b6cce14..b063a9c 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1154,12 +1154,6 @@ static struct task_struct *copy_process(unsigned l=
ong clone_flags,
>  		pid =3D alloc_pid(p->nsproxy->pid_ns);
>  		if (!pid)
>  			goto bad_fork_cleanup_io;
> -
> -		if (clone_flags & CLONE_NEWPID) {
> -			retval =3D pid_ns_prepare_proc(p->nsproxy->pid_ns);
> -			if (retval < 0)
> -				goto bad_fork_free_pid;
> -		}
>  	}
> =20
>  	p->pid =3D pid_nr(pid);
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index 1357c57..68f302a 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -1350,8 +1350,9 @@ static ssize_t binary_sysctl(const int *name, int n=
len,
>  		goto out_putname;
>  	}
> =20
> -	mnt =3D current->nsproxy->pid_ns->proc_mnt;
> +	mnt =3D get_proc_mnt(task_active_pid_ns(current));
>  	result =3D vfs_path_lookup(mnt->mnt_root, mnt, pathname, 0, &nd);
> +	mntput(mnt);
>  	if (result)
>  		goto out_putname;
> =20
> --=20
> 1.6.5.2.143.g8cc62
>=20

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-22142-1278857570-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkw50a4ACgkQVKcRuvQ9Q1SjCACdFfU49fSnd2+4evGsK/0IIJRZ
0ioAn1y4fziH7I+syBV1uncENvrbOhx+
=AxHt
-----END PGP SIGNATURE-----

--=_bohort-22142-1278857570-0001-2--
