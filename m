From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH RFC] coredump: virtualize core dump path configuration
Date: Sat, 25 Feb 2017 17:01:23 +0100
Message-ID: <20170225160123.GC11144@pc.thejh.net>
References: <148802737321.604836.9948660933476794784.stgit@buzz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8678372209464750154=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <148802737321.604836.9948660933476794784.stgit@buzz>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============8678372209464750154==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Feb 25, 2017 at 03:56:13PM +0300, Konstantin Khlebnikov wrote:
> This patch adds per-mount-namespace core dump pattern.
>=20
> Kernel writes coredump in chroot/container where application is
> executed or starts pipe helper in the same chroot according to
> pattern set by sysctl "kernel.core_pattern".

I'm pretty sure it doesn't, and if it did, that would be a security bug.

Coredump helpers have, as far as I know, always been executed in the
root directory of init, not inside the chroot.

Absolute core patterns used to write coredumps into the root directory
of the chroot, and that was a security issue, which I fixed:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3D378c6520e7d29280f400ef2ceaf155c86f05a71a

> This configuration is
> global and this sysctl couldn't be extended without breaking anything.
>=20
> This patch adds second sysctl "kernel.core_pattern_ns" which overrides
> global configuration for tasks in current mount namespace.
> Resetting it to empty string reverts core dumps back to global pattern.
>=20
> New namespace gets a copy of this configuration from parent.
> [...]
> +char *namespace_core_pattern(bool alloc)
> +{
> +	struct mnt_namespace *ns =3D current->nsproxy->mnt_ns;
> +
> +	if (!ns->core_pattern && alloc) {
> +		char *new =3D kzalloc(CORENAME_MAX_SIZE, GFP_KERNEL);
> +
> +		if (new && cmpxchg(&ns->core_pattern, NULL, new))
> +			kfree(new);
> +	}
> +
> +	return ns->core_pattern;
> +}
> +
> +static char *current_core_pattern(void)
> +{
> +	struct mnt_namespace *ns =3D current->nsproxy->mnt_ns;
> +
> +	if (ns->core_pattern && ns->core_pattern[0])
> +		return ns->core_pattern;
> +
> +	return core_pattern;
> +}



>  /* format_corename will inspect the pattern parameter, and output a
>   * name into corename, which must have space for at least
>   * CORENAME_MAX_SIZE bytes plus one byte for the zero terminator.
> @@ -187,7 +212,7 @@ static int cn_print_exe_file(struct core_name *cn)
>  static int format_corename(struct core_name *cn, struct coredump_params =
*cprm)
>  {
>  	const struct cred *cred =3D current_cred();
> -	const char *pat_ptr =3D core_pattern;
> +	const char *pat_ptr =3D current_core_pattern();
>  	int ispipe =3D (*pat_ptr =3D=3D '|');
>  	int pid_in_pattern =3D 0;
>  	int err =3D 0;

If you don't change more here, the behavior is going to be that
the namespaced core pattern causes coredump helpers to be launched
and absolute-path coredumps to be written relative to init's root
directory and with the privileges of root in the init namespace.

Those semantics seem unintuitive to me. Shouldn't the coredumps
be written relative to some sort of root directory of the user
namespace? (Yes, I realize that no clear semantics for that are
defined.) And shouldn't the coredumps be written with the
privileges of the user namespace on which the coredump pattern
was set?


> diff --git a/fs/mount.h b/fs/mount.h
> index 2c856fc47ae3..894bca887104 100644
> --- a/fs/mount.h
> +++ b/fs/mount.h
> @@ -16,6 +16,7 @@ struct mnt_namespace {
>  	u64 event;
>  	unsigned int		mounts; /* # of mounts in the namespace */
>  	unsigned int		pending_mounts;
> +	char			*core_pattern;
>  };
> =20
>  struct mnt_pcp {
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 487ba30bb5c6..a8dd58eb10da 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -24,6 +24,7 @@
>  #include <linux/magic.h>
>  #include <linux/bootmem.h>
>  #include <linux/task_work.h>
> +#include <linux/binfmts.h>	/* CORENAME_MAX_SIZE */
>  #include "pnode.h"
>  #include "internal.h"
> =20
> @@ -2828,6 +2829,7 @@ static void free_mnt_ns(struct mnt_namespace *ns)
>  	ns_free_inum(&ns->ns);
>  	dec_mnt_namespaces(ns->ucounts);
>  	put_user_ns(ns->user_ns);
> +	kfree(ns->core_pattern);
>  	kfree(ns);
>  }
> =20
> @@ -2872,6 +2874,7 @@ static struct mnt_namespace *alloc_mnt_ns(struct us=
er_namespace *user_ns)
>  	new_ns->ucounts =3D ucounts;
>  	new_ns->mounts =3D 0;
>  	new_ns->pending_mounts =3D 0;
> +	new_ns->core_pattern =3D NULL;
>  	return new_ns;
>  }
> =20
> @@ -2899,6 +2902,15 @@ struct mnt_namespace *copy_mnt_ns(unsigned long fl=
ags, struct mnt_namespace *ns,
>  	if (IS_ERR(new_ns))
>  		return new_ns;
> =20
> +	if (ns->core_pattern) {
> +		new_ns->core_pattern =3D kmemdup(ns->core_pattern,
> +					       CORENAME_MAX_SIZE, GFP_KERNEL);
> +		if (!new_ns->core_pattern) {
> +			free_mnt_ns(new_ns);
> +			return ERR_PTR(-ENOMEM);
> +		}
> +	}
> +

AFAICS copying it this way means that in the following scenario,
namespace B will still use the core_pattern "foo" while namespace A
is using core_pattern "bar":
 - you set the core_pattern of namespace A to "foo"
 - namespace A creates a child namespace B
 - you set the core_pattern of namespace A to "bar"

Those are pretty unintuitive semantics. It might be better
to not copy the pattern and instead loop up through the
namespaces in current_core_pattern() or so.

Also, wouldn't you have to use an atomic read here or so?

>  	namespace_lock();
>  	/* First pass: copy the tree topology */
>  	copy_flags =3D CL_COPY_UNBINDABLE | CL_EXPIRE;
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 1aea594a54db..9e66daf1e236 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -483,6 +483,13 @@ static struct ctl_table kern_table[] =3D {
>  		.proc_handler	=3D proc_dostring_coredump,
>  	},
>  	{
> +		.procname	=3D "core_pattern_ns",
> +		.data		=3D NULL,
> +		.maxlen		=3D CORENAME_MAX_SIZE,
> +		.mode		=3D 0644,
> +		.proc_handler	=3D proc_dostring_coredump,
> +	},
> +	{

Only root can write it? That seems weird if you intend to use it
for containers.

>  		.procname	=3D "core_pipe_limit",
>  		.data		=3D &core_pipe_limit,
>  		.maxlen		=3D sizeof(unsigned int),
> @@ -2408,10 +2415,27 @@ static int proc_dointvec_minmax_coredump(struct c=
tl_table *table, int write,
>  }
> =20
>  #ifdef CONFIG_COREDUMP
> +extern char *namespace_core_pattern(bool alloc);
> +
>  static int proc_dostring_coredump(struct ctl_table *table, int write,
>  		  void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> -	int error =3D proc_dostring(table, write, buffer, lenp, ppos);
> +	struct ctl_table tmp_table;
> +	char empty[] =3D "";
> +	int error;
> +
> +	if (!table->data) {
> +		tmp_table =3D *table;
> +		table =3D &tmp_table;
> +		table->data =3D namespace_core_pattern(write);
> +		if (!table->data) {
> +			if (write)
> +				return -ENOMEM;
> +			table->data =3D empty;
> +		}
> +	}
> +
> +	error =3D proc_dostring(table, write, buffer, lenp, ppos);
>  	if (!error)
>  		validate_coredump_safety();
>  	return error;
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

--0F1p//8PRICkK4MW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYsapTAAoJED4KNFJOeCOoVwcP/2dTJjRgx2b8efIQhbvnZwfH
hvv81NTMHAWqlG+nsEebmBbmZ2iuGtXhP+RlDWa7zdMih8OeJTc4ElBwAPP/AGDp
AxmshWv4KqA3kUtUb+k+D5o6/wIjYKzm+qBq9obPDSGxtyAoZ7N6/wKeXtwufV1y
w75sQeW8kukOam3sUJpWqCueGy+iAQp41n2uBPQqdWChrNzzvQGgUOfhRt1Z2QVC
T+0kkO9DztTkdy8U4bPvWNGwRu17qdkNNykI3mGtg6iI6uZR7al5N9HeJ7kCVP/T
AvUwcy678MBnUbaVjYj6cGsBlzTRjiP+s9aUNiz++44Lo3ZBpkjXzRr2i34mHE25
bQOxSezBfDdUQ6/hqjER/4QFEEjWm8OtnwfqWx8p7XADn7osy28K3QpcIZtpSDKl
BZtAwG6nkY3x9lR8H7Z6XkxiD5qEm44ISQE4gajSolqlhyBNkthKChvWPurAaAIs
vbdaOHOuf+wG/tvw4pLhlSRTjzypnfOHa604GzCJbA2CiJVS/Fh1i9epUY3cCN3I
eoNVd0qPFc7bg8pGHem94P4g0+ObpFI0yk7gR4eTIK59M/VFiWDiL2ATBb0icLp1
11NBR+iln4XtCNCECn8mK1e8Clr65UzjhBfRH13pBlvNHZ1p08XpdBogPjLgbTbQ
+k4vuHGw6g//+WGnSrq8
=C8fR
-----END PGP SIGNATURE-----

--0F1p//8PRICkK4MW--

--===============8678372209464750154==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============8678372209464750154==--
