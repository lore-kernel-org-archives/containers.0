From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v3][PATCH 8/9] File descriprtors (dump)
Date: Thu, 4 Sep 2008 11:47:40 +0200
Message-ID: <20080904094740.GY14473__28265.9186436378$1220521870$gmane$org@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040405250.5982@takamine.ncl.cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0293267628061441987=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040405250.5982-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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

--===============0293267628061441987==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-6599-1220521527-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-6599-1220521527-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 04, 2008 at 04:05:50AM -0400, Oren Laadan wrote:
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
>

[...]

> diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
> new file mode 100644
> index 0000000..34df371
> --- /dev/null
> +++ b/checkpoint/ckpt_file.c
> @@ -0,0 +1,224 @@
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
> +#include <linux/ckpt.h>
> +#include <linux/ckpt_hdr.h>
> +
> +#include "ckpt_file.h"
> +
> +#define CR_DEFAULT_FDTABLE  256
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
> +	struct fdtable *fdt;
> +	int *fdlist;
> +	int i, n, max;
> +
> +	max =3D CR_DEFAULT_FDTABLE;
> +
> + repeat:
> +	n =3D 0;
> +	fdlist =3D kmalloc(max * sizeof(*fdlist), GFP_KERNEL);
> +	if (!fdlist)
> +		return -ENOMEM;
> +
> +	spin_lock(&files->file_lock);
> +	fdt =3D files_fdtable(files);
> +	for (i =3D 0; i < fdt->max_fds; i++) {
> +		if (fcheck_files(files, i)) {
> +			if (n =3D=3D max) {
> +				spin_unlock(&files->file_lock);
> +				kfree(fdlist);
> +				max *=3D 2;
> +				if (max < 0) {	/* overflow ? */
> +					n =3D -EMFILE;
> +					break;
> +				}
> +				goto repeat;

				fdlist =3D krealloc(fdlist, max, GFP_KERNEL)?

Sorry, I should have suggested this in my first review.

Louis

> +			}
> +			fdlist[n++] =3D i;
> +		}
> +	}
> +	spin_unlock(&files->file_lock);
> +
> +	*fdtable =3D fdlist;
> +	return n;
> +}
> +

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-6599-1220521527-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIv668VKcRuvQ9Q1QRAvWuAKC1ojg6iOa8U2sfcc5YvR4IkuGXrACfamin
bbx1ZDq35Tirzo0R+1UTfTc=
=mt7i
-----END PGP SIGNATURE-----

--=_bohort-6599-1220521527-0001-2--

--===============0293267628061441987==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0293267628061441987==--
