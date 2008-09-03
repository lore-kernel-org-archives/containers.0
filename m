From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 6/9] Introduce functions to dump mm
Date: Wed, 3 Sep 2008 16:17:29 +0200
Message-ID: <20080903141729.GT14473__38525.6209563979$1220451758$gmane$org@hawkmoon.kerlabs.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<1220439476-16465-5-git-send-email-major@openvz.org>
	<1220439476-16465-6-git-send-email-major@openvz.org>
	<1220439476-16465-7-git-send-email-major@openvz.org>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5702176619485782913=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-7-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============5702176619485782913==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-23675-1220451316-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-23675-1220451316-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 03, 2008 at 02:57:53PM +0400, Andrey Mirkin wrote:
> Functions to dump mm struct, VMAs and mm context are added.
>=20

[...]

> diff --git a/cpt/cpt_mm.c b/cpt/cpt_mm.c
> new file mode 100644
> index 0000000..6e025cc
> --- /dev/null
> +++ b/cpt/cpt_mm.c
> @@ -0,0 +1,431 @@
> +/*
> + *  Copyright (C) 2008 Parallels, Inc.
> + *
> + *  Authors:	Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + *
> + */
> +
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/file.h>
> +#include <linux/mm.h>
> +#include <linux/errno.h>
> +#include <linux/major.h>
> +#include <linux/mman.h>
> +#include <linux/mnt_namespace.h>
> +#include <linux/mount.h>
> +#include <linux/namei.h>
> +#include <linux/pagemap.h>
> +#include <linux/hugetlb.h>
> +#include <asm/ldt.h>
> +
> +#include "cpt.h"
> +#include "cpt_image.h"
> +
> +struct page_area
> +{
> +	int type;
> +	unsigned long start;
> +	unsigned long end;
> +	pgoff_t pgoff;
> +	loff_t mm;
> +	__u64 list[16];
> +};
> +
> +struct page_desc
> +{
> +	int	type;
> +	pgoff_t	index;
> +	loff_t	mm;
> +	int	shared;
> +};
> +
> +enum {
> +	PD_ABSENT,
> +	PD_COPY,
> +	PD_FUNKEY,
> +};
> +
> +/* 0: page can be obtained from backstore, or still not mapped anonymous=
  page,
> +      or something else, which does not requre copy.
> +   1: page requires copy
> +   2: page requres copy but its content is zero. Quite useless.
> +   3: wp page is shared after fork(). It is to be COWed when modified.
> +   4: page is something unsupported... We copy it right now.
> + */
> +
> +static void page_get_desc(struct vm_area_struct *vma, unsigned long addr,
> +			  struct page_desc *pdesc, cpt_context_t * ctx)
> +{
> +	struct mm_struct *mm =3D vma->vm_mm;
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *ptep, pte;
> +	spinlock_t *ptl;
> +	struct page *pg =3D NULL;
> +	pgoff_t linear_index =3D (addr - vma->vm_start)/PAGE_SIZE + vma->vm_pgo=
ff;
> +
> +	pdesc->index =3D linear_index;
> +	pdesc->shared =3D 0;
> +	pdesc->mm =3D CPT_NULL;
> +
> +	if (vma->vm_flags & VM_IO) {
> +		pdesc->type =3D PD_ABSENT;
> +		return;
> +	}
> +
> +	pgd =3D pgd_offset(mm, addr);
> +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> +		goto out_absent;
> +	pud =3D pud_offset(pgd, addr);
> +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> +		goto out_absent;
> +	pmd =3D pmd_offset(pud, addr);
> +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> +		goto out_absent;
> +#ifdef CONFIG_X86
> +	if (pmd_huge(*pmd)) {
> +		eprintk("page_huge\n");
> +		goto out_unsupported;
> +	}
> +#endif
> +	ptep =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	pte =3D *ptep;
> +	pte_unmap(ptep);
> +
> +	if (pte_none(pte))
> +		goto out_absent_unlock;
> +
> +	if ((pg =3D vm_normal_page(vma, addr, pte)) =3D=3D NULL) {
> +		pdesc->type =3D PD_COPY;
> +		goto out_unlock;
> +	}
> +
> +	get_page(pg);
> +	spin_unlock(ptl);
> +
> +	if (pg->mapping && !PageAnon(pg)) {
> +		if (vma->vm_file =3D=3D NULL) {
> +			eprintk("pg->mapping!=3DNULL for fileless vma: %08lx\n", addr);
> +			goto out_unsupported;
> +		}
> +		if (vma->vm_file->f_mapping !=3D pg->mapping) {
> +			eprintk("pg->mapping!=3Df_mapping: %08lx %p %p\n",
> +				    addr, vma->vm_file->f_mapping, pg->mapping);
> +			goto out_unsupported;
> +		}
> +		pdesc->index =3D (pg->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT));
> +		/* Page is in backstore. For us it is like
> +		 * it is not present.
> +		 */
> +		goto out_absent;
> +	}
> +
> +	if (PageReserved(pg)) {
> +		/* Special case: ZERO_PAGE is used, when an
> +		 * anonymous page is accessed but not written. */
> +		if (pg =3D=3D ZERO_PAGE(addr)) {
> +			if (pte_write(pte)) {
> +				eprintk("not funny already, writable ZERO_PAGE\n");
> +				goto out_unsupported;
> +			}
> +			goto out_absent;
> +		}
> +		eprintk("reserved page %lu at %08lx\n", pg->index, addr);
> +		goto out_unsupported;
> +	}
> +
> +	if (!pg->mapping) {
> +		eprintk("page without mapping at %08lx\n", addr);
> +		goto out_unsupported;
> +	}
> +
> +	pdesc->type =3D PD_COPY;
> +
> +out_put:
> +	if (pg)
> +		put_page(pg);
> +	return;
> +
> +out_unlock:
> +	spin_unlock(ptl);
> +	goto out_put;
> +
> +out_absent_unlock:
> +	spin_unlock(ptl);
> +
> +out_absent:
> +	pdesc->type =3D PD_ABSENT;
> +	goto out_put;
> +
> +out_unsupported:
> +	pdesc->type =3D PD_FUNKEY;
> +	goto out_put;
> +}
> +
> +static int count_vma_pages(struct vm_area_struct *vma, struct cpt_contex=
t *ctx)
> +{
> +	unsigned long addr;
> +	int page_num =3D 0;
> +
> +	for (addr =3D vma->vm_start; addr < vma->vm_end; addr +=3D PAGE_SIZE) {
> +		struct page_desc pd;
> +
> +		page_get_desc(vma, addr, &pd, ctx);
> +
> +		if (pd.type !=3D PD_COPY) {
> +			return -EINVAL;
> +		} else {
> +			page_num +=3D 1;
> +		}
> +	=09
> +	}
> +	return page_num;
> +}
> +
> +/* ATTN: We give "current" to get_user_pages(). This is wrong, but get_u=
ser_pages()
> + * does not really need this thing. It just stores some page fault stats=
 there.
> + *
> + * BUG: some archs (f.e. sparc64, but not Intel*) require flush cache pa=
ges
> + * before accessing vma.
> + */
> +static int dump_pages(struct vm_area_struct *vma, unsigned long start,
> +		unsigned long end, struct cpt_context *ctx)
> +{
> +#define MAX_PAGE_BATCH 16
> +	struct page *pg[MAX_PAGE_BATCH];
> +	int npages =3D (end - start)/PAGE_SIZE;
> +	int count =3D 0;
> +
> +	while (count < npages) {
> +		int copy =3D npages - count;
> +		int n;
> +
> +		if (copy > MAX_PAGE_BATCH)
> +			copy =3D MAX_PAGE_BATCH;
> +		n =3D get_user_pages(current, vma->vm_mm, start, copy,
> +				   0, 1, pg, NULL);
> +		if (n =3D=3D copy) {
> +			int i;
> +			for (i=3D0; i<n; i++) {
> +				char *maddr =3D kmap(pg[i]);
> +				ctx->write(maddr, PAGE_SIZE, ctx);
> +				kunmap(pg[i]);
> +			}
> +		} else {
> +			eprintk("get_user_pages fault");
> +			for ( ; n > 0; n--)
> +				page_cache_release(pg[n-1]);
> +			return -EFAULT;
> +		}
> +		start +=3D n*PAGE_SIZE;
> +		count +=3D n;
> +		for ( ; n > 0; n--)
> +			page_cache_release(pg[n-1]);
> +	}
> +	return 0;
> +}
> +
> +static int dump_page_block(struct vm_area_struct *vma,
> +			   struct cpt_page_block *pgb,
> +			   struct cpt_context *ctx)
> +{
> +	int err;
> +	pgb->cpt_len =3D sizeof(*pgb) + pgb->cpt_end - pgb->cpt_start;
> +	pgb->cpt_type =3D CPT_OBJ_PAGES;
> +	pgb->cpt_hdrlen =3D sizeof(*pgb);
> +	pgb->cpt_content =3D CPT_CONTENT_DATA;
> +
> +	err =3D ctx->write(pgb, sizeof(*pgb), ctx);
> +	if (!err)
> +		err =3D dump_pages(vma, pgb->cpt_start, pgb->cpt_end, ctx);
> +
> +	return err;
> +}
> +
> +static int cpt_dump_dentry(struct path *p, cpt_context_t *ctx)
> +{
> +	int len;
> +	char *path;
> +	char *buf;
> +	struct cpt_object_hdr o;
> +
> +	buf =3D (char *)__get_free_page(GFP_KERNEL);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	path =3D d_path(p, buf, PAGE_SIZE);
> +
> +	if (IS_ERR(path)) {
> +		free_page((unsigned long)buf);
> +		return PTR_ERR(path);
> +	}
> +
> +	len =3D buf + PAGE_SIZE - 1 - path;
> +	o.cpt_len =3D sizeof(o) + len + 1;
> +	o.cpt_type =3D CPT_OBJ_NAME;
> +	o.cpt_hdrlen =3D sizeof(o);
> +	o.cpt_content =3D CPT_CONTENT_NAME;
> +	path[len] =3D 0;
> +
> +	ctx->write(&o, sizeof(o), ctx);
> +	ctx->write(path, len + 1, ctx);
> +	free_page((unsigned long)buf);
> +
> +	return 0;
> +}
> +
> +static int dump_one_vma(struct mm_struct *mm,
> +			struct vm_area_struct *vma, struct cpt_context *ctx)
> +{
> +	struct cpt_vma_image *v;
> +	unsigned long addr;
> +	int page_num;
> +	int err;
> +
> +	v =3D kzalloc(sizeof(*v), GFP_KERNEL);
> +	if (!v)
> +		return -ENOMEM;
> +
> +	v->cpt_len =3D sizeof(*v);
> +	v->cpt_type =3D CPT_OBJ_VMA;
> +	v->cpt_hdrlen =3D sizeof(*v);
> +	v->cpt_content =3D CPT_CONTENT_ARRAY;
> +
> +	v->cpt_start =3D vma->vm_start;
> +	v->cpt_end =3D vma->vm_end;
> +	v->cpt_flags =3D vma->vm_flags;
> +	if (vma->vm_flags & VM_HUGETLB) {
> +		eprintk("huge TLB VMAs are still not supported\n");
> +		kfree(v);
> +		return -EINVAL;
> +	}
> +	v->cpt_pgprot =3D vma->vm_page_prot.pgprot;
> +	v->cpt_pgoff =3D vma->vm_pgoff;
> +	v->cpt_file =3D CPT_NULL;
> +	v->cpt_vma_type =3D CPT_VMA_TYPE_0;
> +
> +	page_num =3D count_vma_pages(vma, ctx);
> +	if (page_num < 0) {
> +		kfree(v);
> +		return -EINVAL;
> +	}
> +	v->cpt_page_num =3D page_num;
> +
> +	if (vma->vm_file) {
> +		v->cpt_file =3D 0;
> +		v->cpt_vma_type =3D CPT_VMA_FILE;
> +	}
> +
> +	ctx->write(v, sizeof(*v), ctx);
> +	kfree(v);
> +
> +	if (vma->vm_file) {
> +		err =3D cpt_dump_dentry(&vma->vm_file->f_path, ctx);
> +		if (err < 0)
> +			return err;
> +	}
> +
> +	for (addr =3D vma->vm_start; addr < vma->vm_end; addr +=3D PAGE_SIZE) {
> +		struct page_desc pd;
> +		struct cpt_page_block pgb;
> +
> +		page_get_desc(vma, addr, &pd, ctx);
> +
> +		if (pd.type =3D=3D PD_FUNKEY || pd.type =3D=3D PD_ABSENT) {
> +			eprintk("dump_one_vma: funkey page\n");
> +			return -EINVAL;

IIUC, as soon as ZERO_PAGE is hit, checkpoint aborts. I doubt that many
applications will be checkpointable with this limitation.

> +		}
> +
> +		pgb.cpt_start =3D addr;
> +		pgb.cpt_end =3D addr + PAGE_SIZE;
> +		dump_page_block(vma, &pgb, ctx);
> +	}
> +
> +	return 0;
> +}
> +
> +static int cpt_dump_mm_context(struct mm_struct *mm, struct cpt_context =
*ctx)
> +{
> +#ifdef CONFIG_X86
> +	if (mm->context.size) {
> +		struct cpt_obj_bits b;
> +		int size;
> +
> +		mutex_lock(&mm->context.lock);
> +
> +		b.cpt_type =3D CPT_OBJ_BITS;
> +		b.cpt_len =3D sizeof(b);
> +		b.cpt_content =3D CPT_CONTENT_MM_CONTEXT;
> +		b.cpt_size =3D mm->context.size * LDT_ENTRY_SIZE;
> +
> +		ctx->write(&b, sizeof(b), ctx);
> +
> +		size =3D mm->context.size * LDT_ENTRY_SIZE;
> +
> +		ctx->write(mm->context.ldt, size, ctx);
> +
> +		mutex_unlock(&mm->context.lock);
> +	}
> +#endif
> +	return 0;
> +}
> +
> +int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx)
> +{
> +	struct mm_struct *mm =3D tsk->mm;
> +	struct cpt_mm_image *v;
> +	struct vm_area_struct *vma;
> +	int err;
> +
> +	v =3D kzalloc(sizeof(*v), GFP_KERNEL);
> +	if (!v)
> +		return -ENOMEM;
> +
> +	v->cpt_len =3D sizeof(*v);
> +	v->cpt_type =3D CPT_OBJ_MM;
> +	v->cpt_hdrlen =3D sizeof(*v);
> +	v->cpt_content =3D CPT_CONTENT_ARRAY;
> +
> +	v->cpt_start_code =3D mm->start_code;
> +	v->cpt_end_code =3D mm->end_code;
> +	v->cpt_start_data =3D mm->start_data;
> +	v->cpt_end_data =3D mm->end_data;
> +	v->cpt_start_brk =3D mm->start_brk;
> +	v->cpt_brk =3D mm->brk;
> +	v->cpt_start_stack =3D mm->start_stack;
> +	v->cpt_start_arg =3D mm->arg_start;
> +	v->cpt_end_arg =3D mm->arg_end;
> +	v->cpt_start_env =3D mm->env_start;
> +	v->cpt_end_env =3D mm->env_end;
> +	v->cpt_def_flags =3D mm->def_flags;
> +	v->cpt_flags =3D mm->flags;
> +	v->cpt_map_count =3D mm->map_count;
> +
> +	err =3D ctx->write(v, sizeof(*v), ctx);
> +	kfree(v);
> +=09
> +	if (err) {
> +		eprintk("error during writing mm\n");
> +		return err;
> +	}
> +=09
> +	for (vma =3D mm->mmap; vma; vma =3D vma->vm_next) {
> +		int err;
> +
> +		if ((err =3D dump_one_vma(mm, vma, ctx)) !=3D 0)
> +			return err;
> +	}

Why not down_reading mm->mmap_sem here, while it is properly down_written d=
uring
restart? Is it because we can rely on the tasks being frozen during checkpo=
int,
and not during restart?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-23675-1220451316-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIvpx5VKcRuvQ9Q1QRAj1QAJ4g02MhCogjELb96jwc2HSwvCsopwCdGqE0
kDHKBY2qbZGyAB//UX5QM4I=
=6L5O
-----END PGP SIGNATURE-----

--=_bohort-23675-1220451316-0001-2--

--===============5702176619485782913==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5702176619485782913==--
