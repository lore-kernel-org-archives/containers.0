From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v2][PATCH 2/9] General infrastructure for checkpoint restart
Date: Thu, 21 Aug 2008 11:35:29 +0200
Message-ID: <20080821093529.GG581__10928.2176163562$1219311476$gmane$org@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202303460.17436@takamine.ncl.cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7692196188347762517=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202303460.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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

--===============7692196188347762517==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-9501-1219311200-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-9501-1219311200-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2008 at 11:04:13PM -0400, Oren Laadan wrote:
>
> Add those interfaces, as well as helpers needed to easily manage the
> file format. The code is roughly broken out as follows:
>
> ckpt/sys.c - user/kernel data transfer, as well as setup of the
> checkpoint/restart context (a per-checkpoint data structure for
> housekeeping)
>
> ckpt/checkpoint.c - output wrappers and basic checkpoint handling
>
> ckpt/restart.c - input wrappers and basic restart handling
>
> Patches to add the per-architecture support as well as the actual
> work to do the memory checkpoint follow in subsequent patches.
>

[...]

> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> new file mode 100644
> index 0000000..2891c48
> --- /dev/null
> +++ b/checkpoint/sys.c

[...]

> +/*
> + * helpers to manage CR contexts: allocated for each checkpoint and/or
> + * restart operation, and persists until the operation is completed.
> + */
> +
> +static atomic_t cr_ctx_count;	/* unique checkpoint identifier */

I thought we agreed that this counter should be per-container. Perhaps add a
TODO here?

> +
> +void cr_ctx_free(struct cr_ctx *ctx)
> +{
> +
> +	if (ctx->file)
> +		fput(ctx->file);
> +	if (ctx->vfsroot)
> +		path_put(ctx->vfsroot);
> +
> +	free_pages((unsigned long) ctx->tbuf, CR_TBUF_ORDER);
> +	free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);
> +
> +	kfree(ctx);
> +}
> +
> +struct cr_ctx *cr_ctx_alloc(pid_t pid, struct file *file, unsigned long =
flags)
> +{
> +	struct cr_ctx *ctx;
> +
> +	ctx =3D kzalloc(sizeof(*ctx), GFP_KERNEL);
> +	if (!ctx)
> +		return NULL;
> +
> +	ctx->tbuf =3D (void *) __get_free_pages(GFP_KERNEL, CR_TBUF_ORDER);
> +	ctx->hbuf =3D (void *) __get_free_pages(GFP_KERNEL, CR_HBUF_ORDER);
> +	if (!ctx->tbuf || !ctx->hbuf)
> +		goto nomem;
> +
> +	ctx->pid =3D pid;
> +	ctx->flags =3D flags;
> +
> +	ctx->file =3D file;
> +	get_file(file);
> +
> +	/* assume checkpointer is in container's root vfs */

I'm a bit puzzled by this assumption. I would say: either this is a
self-checkpoint (only current process), or this is a container checkpoint. =
In
the latter case, I expect that in the general case the checkpointer lives
outside the container (and the interface of sys_checkpoint() below confirms
this), so it's root fs is probably not the container's one.

Does it differ from what you're planning?

Thanks,

Louis

> +	ctx->vfsroot =3D &current->fs->root;
> +	path_get(ctx->vfsroot);
> +
> +	ctx->crid =3D atomic_inc_return(&cr_ctx_count);
> +
> +	return ctx;
> +
> + nomem:
> +	cr_ctx_free(ctx);
> +	return NULL;
> +}
> +
> +/**
> + * sys_checkpoint - checkpoint a container
> + * @pid: pid of the container init(1) process
> + * @fd: file to which dump the checkpoint image
> + * @flags: checkpoint operation flags
> + */
> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
> +{
> +	struct cr_ctx *ctx;
> +	struct file *file;
> +	int fput_needed;
> +	int ret;
> +
> +	file =3D fget_light(fd, &fput_needed);
> +	if (!file)
> +		return -EBADF;
> +
> +	/* no flags for now */
> +	if (flags)
> +		return -EINVAL;
> +
> +	ctx =3D cr_ctx_alloc(pid, file, flags | CR_CTX_CKPT);
> +	if (!ctx) {
> +		fput_light(file, fput_needed);
> +		return -ENOMEM;
> +	}
> +
> +	ret =3D do_checkpoint(ctx);
> +
> +	cr_ctx_free(ctx);
> +	fput_light(file, fput_needed);
> +
> +	return ret;
> +}
> +
> +/**
> + * sys_restart - restart a container
> + * @crid: checkpoint image identifier
> + * @fd: file from which read the checkpoint image
> + * @flags: restart operation flags
> + */
> +asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
> +{
> +	struct cr_ctx *ctx;
> +	struct file *file;
> +	int fput_needed;
> +	int ret;
> +
> +	file =3D fget_light(fd, &fput_needed);
> +	if (!file)
> +		return -EBADF;
> +
> +	/* no flags for now */
> +	if (flags)
> +		return -EINVAL;
> +
> +	ctx =3D cr_ctx_alloc(crid, file, flags | CR_CTX_RSTR);
> +	if (!ctx) {
> +		fput_light(file, fput_needed);
> +		return -ENOMEM;
> +	}
> +
> +	ret =3D do_restart(ctx);
> +
> +	cr_ctx_free(ctx);
> +	fput_light(file, fput_needed);
> +
> +	return ret;
> +}

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-9501-1219311200-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIrTbhVKcRuvQ9Q1QRAvmJAKDIygnl8IBXqdZwrDkZzJY8o4Q0nACeLtsV
50ivpgmLfC8uDAhVBw9PAXA=
=p8wl
-----END PGP SIGNATURE-----

--=_bohort-9501-1219311200-0001-2--

--===============7692196188347762517==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============7692196188347762517==--
