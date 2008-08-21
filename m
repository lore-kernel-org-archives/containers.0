From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v2][PATCH 5/9] Memory managemnet - restore state
Date: Thu, 21 Aug 2008 12:07:36 +0200
Message-ID: <20080821100736.GI581__3048.20455280623$1219313382$gmane$org@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202305210.17436@takamine.ncl.cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0495224650469921548=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202305210.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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

--===============0495224650469921548==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-9984-1219313126-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-9984-1219313126-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2008 at 11:05:39PM -0400, Oren Laadan wrote:
>
> Restoring the memory address space begins with nuking the existing one
> of the current process, and then reading the VMA state and contents.
> Call do_mmap_pgoffset() for each VMA and then read in the data.

[...]

> diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
> new file mode 100644
> index 0000000..df602a9
> --- /dev/null
> +++ b/checkpoint/rstr_mem.c

[...]

> +static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
> +{
> +	struct cr_hdr_vma *hh =3D cr_hbuf_get(ctx, sizeof(*hh));
> +	unsigned long vm_size, vm_flags, vm_prot, vm_pgoff;
> +	unsigned long addr;
> +	unsigned long flags;
> +	struct file *file =3D NULL;
> +	char *fname =3D NULL;
> +	int ret;
> +
> +	ret =3D cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
> +	if (ret < 0)
> +		return ret;
> +	else if (ret !=3D 0)
> +		return -EINVAL;
> +
> +	cr_debug("vma %#lx-%#lx npages %d\n", (unsigned long) hh->vm_start,
> +		 (unsigned long) hh->vm_end, (int) hh->npages);
> +
> +	if (hh->vm_end < hh->vm_start || hh->npages < 0)
> +		return -EINVAL;
> +
> +	vm_size =3D hh->vm_end - hh->vm_start;
> +	vm_prot =3D cr_calc_map_prot_bits(hh->vm_flags);
> +	vm_flags =3D cr_calc_map_flags_bits(hh->vm_flags);
> +	vm_pgoff =3D hh->vm_pgoff;
> +
> +	if (hh->fname) {
> +		fname =3D ctx->tbuf;
> +		ret =3D cr_read_str(ctx, fname, PAGE_SIZE);
> +		if (ret < 0)
> +			return ret;
> +	}
> +
> +	cr_debug("vma fname '%s' how %d\n", fname, hh->how);
> +
> +	switch (hh->how) {
> +
> +	case CR_VMA_ANON:		/* anonymous private mapping */
> +		if (hh->fname)
> +			return -EINVAL;
> +		/* vm_pgoff for anonymous mapping is the "global" page
> +		   offset (namely from addr 0x0), so we force a zero */
> +		vm_pgoff =3D 0;
> +		break;
> +
> +	case CR_VMA_FILE:		/* private mapping from a file */
> +		if (!hh->fname)
> +			return -EINVAL;
> +		/* O_RDWR only needed if both (VM_WRITE|VM_SHARED) are set */
> +		flags =3D hh->vm_flags & (VM_WRITE | VM_SHARED);
> +		flags =3D (flags =3D=3D (VM_WRITE | VM_SHARED) ? O_RDWR : O_RDONLY);
> +		file =3D filp_open(fname, flags, 0);
> +		if (IS_ERR(file))
> +			return PTR_ERR(file);
> +		break;
> +
> +	default:
> +		return -EINVAL;
> +
> +	}
> +
> +	addr =3D do_mmap_pgoff(file, (unsigned long) hh->vm_start,
> +			     vm_size, vm_prot, vm_flags, vm_pgoff);
> +	cr_debug("size %#lx prot %#lx flag %#lx pgoff %#lx =3D> %#lx\n",
> +		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
> +
> +	/* the file (if opened) is now referenced by the vma */
> +	if (file)
> +		filp_close(file, NULL);
> +
> +	if (IS_ERR((void*) addr))
> +		return (PTR_ERR((void *) addr));
> +
> +	/*
> +	 * CR_VMA_ANON: read in memory as is
> +	 * CR_VMA_FILE: read in memory as is
> +	 * (more to follow ...)
> +	 */
> +
> +	switch (hh->how) {
> +	case CR_VMA_ANON:
> +	case CR_VMA_FILE:
> +		/* standard case: read the data into the memory */
> +		ret =3D cr_vma_read_pages(ctx, hh);
> +		break;
> +	}
> +
> +	if (ret < 0)
> +		return ret;
> +
> +	if (vm_prot & PROT_EXEC)
> +		flush_icache_range(hh->vm_start, hh->vm_end);
> +
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	cr_debug("vma retval %d\n", ret);
> +	return 0;
> +}
> +
> +static int cr_destroy_mm(struct mm_struct *mm)
> +{
> +	struct vm_area_struct *vmnext =3D mm->mmap;
> +	struct vm_area_struct *vma;
> +	int ret;
> +
> +	while (vmnext) {
> +		vma =3D vmnext;
> +		vmnext =3D vmnext->vm_next;
> +		ret =3D do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
> +		if (ret < 0)
> +			return ret;
> +	}
> +	return 0;
> +}
> +
> +int cr_read_mm(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_mm *hh =3D cr_hbuf_get(ctx, sizeof(*hh));
> +	struct mm_struct *mm;
> +	int nr, ret;
> +
> +	ret =3D cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
> +	if (ret < 0)
> +		return ret;
> +#if 0	/* activate when containers are used */
> +	if (ret !=3D task_pid_vnr(current))
> +		return -EINVAL;
> +#endif
> +	cr_debug("map_count %d\n", hh->map_count);
> +
> +	/* XXX need more sanity checks */
> +	if (hh->start_code > hh->end_code ||
> +	    hh->start_data > hh->end_data || hh->map_count < 0)
> +		return -EINVAL;
> +
> +	mm =3D current->mm;
> +
> +	/* point of no return -- destruct current mm */
> +	down_write(&mm->mmap_sem);
> +	ret =3D cr_destroy_mm(mm);
> +	up_write(&mm->mmap_sem);
> +
> +	if (ret < 0)
> +		return ret;
> +

Should down_write(&mm->mmap_sem) again here, and hold it until all vmas are
restored. This means removing down_write() from cr_vma_writable(). Or perha=
ps
make it finer grain: release it before looping on the vmas and make
cr_read_vma() take it again before calling do_mmap_pgoff().

> +	mm->start_code =3D hh->start_code;
> +	mm->end_code =3D hh->end_code;
> +	mm->start_data =3D hh->start_data;
> +	mm->end_data =3D hh->end_data;
> +	mm->start_brk =3D hh->start_brk;
> +	mm->brk =3D hh->brk;
> +	mm->start_stack =3D hh->start_stack;
> +	mm->arg_start =3D hh->arg_start;
> +	mm->arg_end =3D hh->arg_end;
> +	mm->env_start =3D hh->env_start;
> +	mm->env_end =3D hh->env_end;
> +
> +	/* FIX: need also mm->flags */
> +
> +	for (nr =3D hh->map_count; nr; nr--) {
> +		ret =3D cr_read_vma(ctx, mm);
> +		if (ret < 0)
> +			return ret;
> +	}
> +
> +	ret =3D cr_read_mm_context(ctx, mm, hh->tag);
> +
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	return ret;
> +}

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-9984-1219313126-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIrT5oVKcRuvQ9Q1QRAiiBAJ4/AOr1TJ+ZQForWjtq3jriXdyyawCgruiS
upYyro6bbBhpngX/KtzGb48=
=dg92
-----END PGP SIGNATURE-----

--=_bohort-9984-1219313126-0001-2--

--===============0495224650469921548==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0495224650469921548==--
