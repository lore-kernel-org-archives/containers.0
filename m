From: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [RFC] Limit dump_pipe program's permission to init for
	container
Date: Fri, 8 Jul 2016 11:26:10 -0400
Message-ID: <20160708152610.GC19948@castiana>
References: <ebe572465ba7c6d12004b62ed752cc5804bf13b4.1467975799.git.zhaolei@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3162983518665435426=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ebe572465ba7c6d12004b62ed752cc5804bf13b4.1467975799.git.zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============3162983518665435426==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="zCKi3GIZzVBPywwA"
Content-Disposition: inline


--zCKi3GIZzVBPywwA
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 08, 2016 at 07:08:10PM +0800, Zhao Lei wrote:
> Currently when we set core_pattern to a pipe, the pipe program is
> forked by kthread running with root's permission, and write dumpfile
> into host's filesystem.
> Same thing happened for container, the dumper and dumpfile are also
> in host(not in container).
>=20
> It have following program:
> 1: Not consistent with file_type core_pattern
>    When we set core_pattern to a file, the container will write dump
>    into container's filesystem instead of host.
> 2: Not safe for privileged container
>    In a privileged container, user can destroy host system by following
>    command:
>    # # In a container
>    # echo "|/bin/dd of=3D/boot/vmlinuz" >/proc/sys/kernel/core_pattern
>    # make_dump
>=20
> This patch switch dumper program's permission to init task, it is to say,
> for container, dumper program have same permission with init task in
> container, which make dumper program put in container's filesystem, and
> write coredump into container's filesystem.
> The dumper's permission is also limited into subset of container's init
> process.
>=20
> See following discussion for detail:
> http://www.gossamer-threads.com/lists/linux/kernel/2455363
> http://www.gossamer-threads.com/lists/linux/kernel/2397602
>=20
> Todo:
> 1: Set different core_pattern to host and each container.
> 2: Keep compatibility with current design
> All above are done in previous version of this patch,
> need some restruct.
>=20
> Any suggestion is welcome for this patch.


Ok, so those two todo items are I think absolute musts before we can
consider any of this.

Changing the default behavior that we have had ever since pipe in
core_pattern and namespaces have existed would cause serious problem for
existing users.


Speaking for myself, LXC does setup limitations on privileged containers
which prevent them from changing the core_pattern so that it can't be
abused for privileged containers.
The core_pattern on Ubuntu then sends all crashes to apport, as root, on
the host. Apport is then container aware and handles forwarding the
crash (through a unix socket) to the apport process inside the
container.

Your suggested change would likely make this all fail as apport on the
host must be called as root to be able to access the container's
filesystem (through /proc/<PID>/root).


With namespacing in place, then we wouldn't need the apport relay trick
on the host, so that'd be fine.

And otherwise, making this behavior optional (different pattern or
something) would be fine too (not breaking existing users).

>=20
> Suggested-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Suggested-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>=20
> Signed-off-by: Zhao Lei <zhaolei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  fs/coredump.c           | 84 +++++++++++++++++++++++++++++++++++++++++++=
+++++-
>  include/linux/binfmts.h |  1 +
>  2 files changed, 84 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/coredump.c b/fs/coredump.c
> index 281b768..92dc343 100644
> --- a/fs/coredump.c
> +++ b/fs/coredump.c
> @@ -516,6 +516,8 @@ static int umh_pipe_setup(struct subprocess_info *inf=
o, struct cred *new)
>  {
>  	struct file *files[2];
>  	struct coredump_params *cp =3D (struct coredump_params *)info->data;
> +	struct task_struct *base_task;
> +
>  	int err =3D create_pipe_files(files, 0);
>  	if (err)
>  		return err;
> @@ -524,10 +526,78 @@ static int umh_pipe_setup(struct subprocess_info *i=
nfo, struct cred *new)
> =20
>  	err =3D replace_fd(0, files[0], 0);
>  	fput(files[0]);
> +	if (err)
> +		return err;
> +
>  	/* and disallow core files too */
>  	current->signal->rlim[RLIMIT_CORE] =3D (struct rlimit){1, 1};
> =20
> -	return err;
> +	base_task =3D cp->base_task;
> +	if (base_task) {
> +		const struct cred *base_cred;
> +
> +		/* Set fs_root to base_task */
> +		spin_lock(&base_task->fs->lock);
> +		set_fs_root(current->fs, &base_task->fs->root);
> +		spin_unlock(&base_task->fs->lock);
> +
> +		/* Set namespaces to base_task */
> +		switch_task_namespaces(current, base_task->nsproxy);
> +
> +		/* Set cgroup to base_task */
> +		current->flags &=3D ~PF_NO_SETAFFINITY;
> +		err =3D cgroup_attach_task_all(base_task, current);
> +		if (err < 0)
> +			return err;
> +
> +		/* Set cred to base_task */
> +		base_cred =3D get_task_cred(base_task);
> +
> +		new->uid   =3D base_cred->uid;
> +		new->gid   =3D base_cred->gid;
> +		new->suid  =3D base_cred->suid;
> +		new->sgid  =3D base_cred->sgid;
> +		new->euid  =3D base_cred->euid;
> +		new->egid  =3D base_cred->egid;
> +		new->fsuid =3D base_cred->fsuid;
> +		new->fsgid =3D base_cred->fsgid;
> +
> +		new->securebits =3D base_cred->securebits;
> +
> +		new->cap_inheritable =3D base_cred->cap_inheritable;
> +		new->cap_permitted   =3D base_cred->cap_permitted;
> +		new->cap_effective   =3D base_cred->cap_effective;
> +		new->cap_bset        =3D base_cred->cap_bset;
> +		new->cap_ambient     =3D base_cred->cap_ambient;
> +
> +		security_cred_free(new);
> +#ifdef CONFIG_SECURITY
> +		new->security =3D NULL;
> +#endif
> +		err =3D security_prepare_creds(new, base_cred, GFP_KERNEL);
> +		if (err < 0) {
> +			put_cred(base_cred);
> +			return err;
> +		}
> +
> +		free_uid(new->user);
> +		new->user =3D base_cred->user;
> +		get_uid(new->user);
> +
> +		put_user_ns(new->user_ns);
> +		new->user_ns =3D base_cred->user_ns;
> +		get_user_ns(new->user_ns);
> +
> +		put_group_info(new->group_info);
> +		new->group_info =3D base_cred->group_info;
> +		get_group_info(new->group_info);
> +
> +		put_cred(base_cred);
> +
> +		validate_creds(new);
> +	}
> +
> +	return 0;
>  }
> =20
>  void do_coredump(const siginfo_t *siginfo)
> @@ -590,6 +660,7 @@ void do_coredump(const siginfo_t *siginfo)
> =20
>  	if (ispipe) {
>  		int dump_count;
> +		struct task_struct *vinit_task;
>  		char **helper_argv;
>  		struct subprocess_info *sub_info;
> =20
> @@ -631,6 +702,12 @@ void do_coredump(const siginfo_t *siginfo)
>  			goto fail_dropcount;
>  		}
> =20
> +		vinit_task =3D find_task_by_vpid(1);
> +		if (!vinit_task) {
> +			printk(KERN_WARNING "failed getting init task info, skipping core dum=
p\n");
> +			goto fail_dropcount;
> +		}
> +
>  		helper_argv =3D argv_split(GFP_KERNEL, cn.corename, NULL);
>  		if (!helper_argv) {
>  			printk(KERN_WARNING "%s failed to allocate memory\n",
> @@ -638,6 +715,10 @@ void do_coredump(const siginfo_t *siginfo)
>  			goto fail_dropcount;
>  		}
> =20
> +		get_task_struct(vinit_task);
> +
> +		cprm.base_task =3D vinit_task;
> +
>  		retval =3D -ENOMEM;
>  		sub_info =3D call_usermodehelper_setup(helper_argv[0],
>  						helper_argv, NULL, GFP_KERNEL,
> @@ -646,6 +727,7 @@ void do_coredump(const siginfo_t *siginfo)
>  			retval =3D call_usermodehelper_exec(sub_info,
>  							  UMH_WAIT_EXEC);
> =20
> +		put_task_struct(vinit_task);
>  		argv_free(helper_argv);
>  		if (retval) {
>  			printk(KERN_INFO "Core dump to |%s pipe failed\n",
> diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
> index 314b3ca..0c9a72c 100644
> --- a/include/linux/binfmts.h
> +++ b/include/linux/binfmts.h
> @@ -59,6 +59,7 @@ struct linux_binprm {
> =20
>  /* Function parameter for binfmt->coredump */
>  struct coredump_params {
> +	struct task_struct *base_task;
>  	const siginfo_t *siginfo;
>  	struct pt_regs *regs;
>  	struct file *file;
> --=20
> 1.8.5.1
>=20
>=20
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

--=20
St=E9phane Graber
Ubuntu developer
http://www.ubuntu.com

--zCKi3GIZzVBPywwA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJXf8YSAAoJEMY4l01keS1nxG8P/RUxpCohb+JlqsfXMqOrkddF
JcfJS2jUsL2nILCeq0LRMOY7ghKlDds6EZXn+I12Amv2GrtgrkdipgIgluQIC4QM
1Eg31idP0g9P9z9ZUuRHrwiPbDf9puMXE8MwOjEVKgQdWMv82C3CCqOASB1Of9Ls
7BYXGaDs/HOOzoDFmefE5cC3CNKhFD7upX+05fgPPsBgIIrEUlU2kjrl3fyLn7TA
DBE+D5Bj77zNedai4dYGmynhz6DiYen2xBX6YG/ayywFOaY6cH2LaqzNULhWjepP
Fk90QLygB5GBz9xm4uPcu+lvvUqFJFMsSXKp4yj8X5raY/1fTzdmDNmX7GomJnzj
1O6A7vFHbxSqAfTM/yXDMxTTp5dQ47Td+imqJbvS0QyaNw6WwHaRJeHEZtCj+UZ0
kNH2XLHh+XTtxk0R9LjrY9ABX8BiQ9RscY9GI1q/jwm1Ywym1WdnxlIw5tLxwUGN
tQDBqKbeCyqj3ISlmzILNHm3HQVceMy+w/9OB0ahEQBblix8WsI3r3DQ5WDq7aGB
ObztBN7Zw484ap9LUeu/0mLR8U4Hz6PKbld+8xuWGV7l+OZ6ml3+eZYyUrvb/CcY
CL3F611l7t8Du524le0lm5HHLFhtXnxcI1wXPP1QJfnIWJ6So26mKs0WiNiLREK4
RLnVz3GzRZxevuLtbAnO
=WaPY
-----END PGP SIGNATURE-----

--zCKi3GIZzVBPywwA--

--===============3162983518665435426==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3162983518665435426==--
