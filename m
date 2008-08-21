From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v2][PATCH 8/9] File descriprtors - dump state
Date: Thu, 21 Aug 2008 13:06:14 +0200
Message-ID: <20080821110614.GK581__15515.2509142228$1219316911$gmane$org@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202306530.17436@takamine.ncl.cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7343426473350272654=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202306530.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============7343426473350272654==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-11042-1219316645-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-11042-1219316645-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2008 at 11:07:16PM -0400, Oren Laadan wrote:
>
> Dump the files_struct of a task with 'struct cr_hdr_files', followed by
> all open file descriptors. Since FDs can be shared, they are assigned a
> tag and registered in the object hash.
>
> For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its tag
> and its close-on-exec property. If the FD is to be saved (first time)
> then this is followed by a 'struct cr_hdr_fd_data' with the FD state.
> Then will come the next FD and so on.
>
> This patch only handles basic FDs - regular files, directories and also
> symbolic links.

[...]

> diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
> new file mode 100644
> index 0000000..18faaf1
> --- /dev/null
> +++ b/checkpoint/ckpt_file.c
> @@ -0,0 +1,234 @@
> +/*
> + *  Checkpoint file descriptors
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General =
Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/file.h>
> +#include <linux/fdtable.h>
> +
> +#include "ckpt.h"
> +#include "ckpt_hdr.h"
> +#include "ckpt_file.h"
> +
> +#define CR_DEFAULT_FDTABLE  128
> +
> +/**
> + * cr_scan_fds - scan file table and construct array of open fds
> + * @files: files_struct pointer
> + * @fdtable: (output) array of open fds
> + * @return: the number of open fds found
> + *
> + * Allocates the file descriptors array (*fdtable), caller should free
> + */
> +int cr_scan_fds(struct files_struct *files, int **fdtable)
> +{
> +	int i, j, n, max;
> +	struct fdtable *fdt;
> +	int *fdlist;
> +
> +	max =3D CR_DEFAULT_FDTABLE;
> +
> + repeat:
> +	fdlist =3D kmalloc(max * sizeof(*fdlist), GFP_KERNEL);
> +	if (!fdlist)
> +		return -ENOMEM;
> +
> +	j =3D 0;
> +	n =3D 0;
> +
> +	spin_lock(&files->file_lock);
> +	fdt =3D files_fdtable(files);
> +	for (;;) {
> +		unsigned long set;
> +		i =3D j * __NFDBITS;
> +		if (i >=3D fdt->max_fds)
> +			break;
> +		set =3D fdt->open_fds->fds_bits[j++];

Why not simply use fcheck_files(files, n) and check if the result is not NU=
LL?

> +		while (set) {
> +			if (set & 1) {
> +				if (unlikely(n =3D=3D max)) {
> +					spin_unlock(&files->file_lock);
> +					kfree(fdlist);
> +					max *=3D 2;
> +					if (max < 0)	/* overflow ? */
> +						return -EMFILE;
> +					goto repeat;
> +				}
> +				fdlist[n++] =3D i;
> +			}
> +			i++;
> +			set >>=3D 1;
> +		}
> +	}
> +	spin_unlock(&files->file_lock);
> +
> +	*fdtable =3D fdlist;
> +	return n;
> +}
> +
> +/* cr_write_fd_data - dump the state of a given file pointer */
> +static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int p=
tag)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_fd_data *hh =3D ctx->hbuf;
> +	struct dentry *dent =3D file->f_dentry;
> +	struct inode *inode =3D dent->d_inode;
> +	char *fname;
> +	int flen, how, ret;
> +
> +	h.type =3D CR_HDR_FD_DATA;
> +	h.len =3D sizeof(*hh);
> +	h.ptag =3D ptag;
> +
> +	BUG_ON(!inode);
> +
> +	flen =3D PAGE_SIZE;
> +	fname =3D cr_fill_fname(&file->f_path, ctx->vfsroot, ctx->tbuf, &flen);
> +	if (IS_ERR(fname))
> +		return PTR_ERR(fname);
> +
> +	hh->f_flags =3D file->f_flags;
> +	hh->f_mode =3D file->f_mode;
> +	hh->f_pos =3D file->f_pos;
> +	hh->f_uid =3D file->f_uid;
> +	hh->f_gid =3D file->f_gid;
> +	hh->f_version =3D file->f_version;
> +	/* FIX: need also file->f_owner */
> +
> +	switch(inode->i_mode & S_IFMT) {
> +	case S_IFREG:
> +		how =3D CR_FD_FILE;
> +		break;
> +	case S_IFDIR:
> +		how =3D CR_FD_DIR;
> +		break;
> +	case S_IFLNK:
> +		how =3D CR_FD_LINK;
> +		break;
> +	default:
> +		return -EBADF;
> +	}
> +
> +	/* FIX: check if the file/dir/link is unlinked */
> +
> +	BUG_ON(!flen);
> +
> +	ret =3D cr_write_obj(ctx, &h, hh);
> +	if (!ret && flen)
> +		ret =3D cr_write_str(ctx, fname, flen);
> +
> +	return ret;
> +}
> +
> +/**
> + * cr_write_fd_ent - dump the state of a given file descriptor
> + * @ctx: checkpoint context
> + * @files: files_struct pointer
> + * @fd: file descriptor
> + * + * Save the state of the file descriptor; look up the actual file=20
> pointer
> + * in the hash table, and if found save the matching tag, otherwise call
> + * cr_write_fd_data to dump the file pointer too.
> + */
> +static int
> +cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_fd_ent *hh =3D ctx->hbuf;
> +	struct file *file =3D NULL;
> +	struct fdtable *fdt;
> +	int coe, tag, ret;
> +
> +	/* make sure hh->fd (that is of type __u16) doesn't overflow */
> +	if (fd > USHORT_MAX) {
> +		pr_warning("CR: open files table too big (%d)\n", USHORT_MAX);
> +		return -EMFILE;
> +	}
> +
> +	rcu_read_lock();
> +	fdt =3D files_fdtable(files);
> +	if (fd < fdt->max_fds)
> +		file =3D rcu_dereference(fdt->fd[fd]);

You should probably use fcheck_files() instead of copying its code here. I =
agree
that this means dereferencing files->fdt a second time below, but is it so
performance critical?

> +	if (file) {
> +		coe =3D FD_ISSET(fd, fdt->close_on_exec);
> +		get_file(file);
> +	}
> +	rcu_read_unlock();
> +
> +	/* sanity check (although this shouldn't happen) */
> +	if (unlikely(!file))
> +		return -EBADF;
> +
> +	ret =3D cr_obj_add_ptr(ctx, (void *) file, &tag, CR_OBJ_FILE, 0);
> +	cr_debug("fd %d tag %d file %p c-o-e %d)\n", fd, tag, file, coe);
> +
> +	if (ret >=3D 0) {
> +		int new =3D ret;
> +
> +		h.type =3D CR_HDR_FD_ENT;
> +		h.len =3D sizeof(*hh);
> +		h.ptag =3D 0;
> + +		hh->tag =3D tag;
    ^
    |

> +		hh->fd =3D fd;
> +		hh->close_on_exec =3D coe;
> +
> +		ret =3D cr_write_obj(ctx, &h, hh);
> +
> +		/* new=3D=3D1 if-and-only-if file was new and added to hash */
> +		if (!ret && new)
> +			ret =3D cr_write_fd_data(ctx, file, tag);
> +	}
> +
> +	fput(file);
> +	return ret;
> +}
> +
> +int cr_write_files(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_files *hh =3D ctx->hbuf;
> +	struct files_struct *files;
> +	int *fdtable;
> +	int nfds, n, ret;
> +
> +	h.type =3D CR_HDR_FILES;
> +	h.len =3D sizeof(*hh);
> +	h.ptag =3D task_pid_vnr(t);
> +
> +	files =3D get_files_struct(t);
> +
> +	nfds =3D cr_scan_fds(files, &fdtable);
> +	if (nfds < 0) {
> +		ret =3D nfds;
> +		goto out;
> +	}
> + +	hh->tag =3D 0;
    ^
    |

> +	hh->nfds =3D nfds;
> +
> +	ret =3D cr_write_obj(ctx, &h, hh);
> +	if (ret < 0)
> +		goto clean;
> +
> +	cr_debug("nfds %d\n", nfds);
> +	for (n =3D 0; n < nfds; n++) {
> +		ret =3D cr_write_fd_ent(ctx, files, n);
> +		if (ret < 0)
> +			break;
> +	}
> +
> + clean:
> +	kfree(fdtable);
> + out:
> +	put_files_struct(files);
> +
> +	return ret;
> +}

[...]

> diff --git a/checkpoint/ckpt_hdr.h b/checkpoint/ckpt_hdr.h
> index a3919cf..a8a37db 100644
> --- a/checkpoint/ckpt_hdr.h
> +++ b/checkpoint/ckpt_hdr.h

[...]

> @@ -114,4 +125,24 @@ struct cr_hdr_vma {
>
>  } __attribute__ ((aligned (8)));
>
> +struct cr_hdr_files {
> +	__u32 tag;	/* sharing identifier */
> +	__u32 nfds;
> +} __attribute__ ((aligned (8)));
> +
> +struct cr_hdr_fd_ent {
> +	__u32 tag;
> +	__u16 fd;
> +	__u16 close_on_exec;
> +} __attribute__ ((aligned (8)));
> +
> +struct cr_hdr_fd_data {
> +	__u16 how;
> +	__u16 f_mode;
> +	__u32 f_flags;
> +	__u32 f_uid, f_gid;

We are not at a 64bits boundary here. Should add one __32 padding or reorde=
r the
fields.

> +	__u64 f_pos;
> +	__u64 f_version;
> +} __attribute__ ((aligned (8)));
> +
>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */
> --=20
> 1.5.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-11042-1219316645-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIrUwmVKcRuvQ9Q1QRAu3xAKCM17+uzP2G7m6281nU58UIN2Ez1gCgyTJw
TN/e/FlYW22yi8mrCuiYczs=
=0w81
-----END PGP SIGNATURE-----

--=_bohort-11042-1219316645-0001-2--

--===============7343426473350272654==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7343426473350272654==--
