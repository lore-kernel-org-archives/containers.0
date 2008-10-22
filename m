From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 06/10] Introduce functions to dump mm
Date: Wed, 22 Oct 2008 12:58:43 +0400
Message-ID: <200810221258.44447.major__28244.4473974921$1224666039$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-7-git-send-email-major@openvz.org>
	<20081020122514.GR15171@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081020122514.GR15171-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 16:25 Louis Rilling wrote:
> On Sat, Oct 18, 2008 at 03:11:34AM +0400, Andrey Mirkin wrote:
> > Functions to dump mm struct, VMAs and mm context are added.
>
> Again, a few little comments.
>
> [...]
>
> > diff --git a/checkpoint/cpt_mm.c b/checkpoint/cpt_mm.c
> > new file mode 100644
> > index 0000000..8a22c48
> > --- /dev/null
> > +++ b/checkpoint/cpt_mm.c
> > @@ -0,0 +1,434 @@
> > +/*
> > + *  Copyright (C) 2008 Parallels, Inc.
> > + *
> > + *  Authors:	Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> > + *
> > + *  This program is free software; you can redistribute it and/or
> > + *  modify it under the terms of the GNU General Public License as
> > + *  published by the Free Software Foundation, version 2 of the
> > + *  License.
> > + *
> > + */
> > +
> > +#include <linux/sched.h>
> > +#include <linux/slab.h>
> > +#include <linux/file.h>
> > +#include <linux/mm.h>
> > +#include <linux/errno.h>
> > +#include <linux/major.h>
> > +#include <linux/mman.h>
> > +#include <linux/mnt_namespace.h>
> > +#include <linux/mount.h>
> > +#include <linux/namei.h>
> > +#include <linux/pagemap.h>
> > +#include <linux/hugetlb.h>
> > +#include <asm/ldt.h>
> > +
> > +#include "checkpoint.h"
> > +#include "cpt_image.h"
> > +
> > +struct page_area
> > +{
> > +	int type;
> > +	unsigned long start;
> > +	unsigned long end;
> > +	pgoff_t pgoff;
> > +	loff_t mm;
> > +	__u64 list[16];
> > +};
> > +
> > +struct page_desc
> > +{
> > +	int	type;
> > +	pgoff_t	index;
> > +	loff_t	mm;
> > +	int	shared;
> > +};
> > +
> > +enum {
> > +	PD_ABSENT,
> > +	PD_COPY,
> > +	PD_FUNKEY,
> > +};
> > +
> > +/* 0: page can be obtained from backstore, or still not mapped anonymous
> >  page, +      or something else, which does not requre copy.
> > +   1: page requires copy
> > +   2: page requres copy but its content is zero. Quite useless.
> > +   3: wp page is shared after fork(). It is to be COWed when modified.
> > +   4: page is something unsupported... We copy it right now.
> > + */
> > +
> > +static void page_get_desc(struct vm_area_struct *vma, unsigned long
> > addr, +			  struct page_desc *pdesc, cpt_context_t * ctx)
> > +{
> > +	struct mm_struct *mm = vma->vm_mm;
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	pte_t *ptep, pte;
> > +	spinlock_t *ptl;
> > +	struct page *pg = NULL;
> > +	pgoff_t linear_index = (addr - vma->vm_start)/PAGE_SIZE +
> > vma->vm_pgoff; +
> > +	pdesc->index = linear_index;
> > +	pdesc->shared = 0;
> > +	pdesc->mm = CPT_NULL;
> > +
> > +	if (vma->vm_flags & VM_IO) {
> > +		pdesc->type = PD_ABSENT;
> > +		return;
> > +	}
> > +
> > +	pgd = pgd_offset(mm, addr);
> > +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> > +		goto out_absent;
> > +	pud = pud_offset(pgd, addr);
> > +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> > +		goto out_absent;
> > +	pmd = pmd_offset(pud, addr);
> > +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> > +		goto out_absent;
> > +#ifdef CONFIG_X86
> > +	if (pmd_huge(*pmd)) {
> > +		eprintk("page_huge\n");
> > +		goto out_unsupported;
> > +	}
> > +#endif
> > +	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
> > +	pte = *ptep;
> > +	pte_unmap(ptep);
> > +
> > +	if (pte_none(pte))
> > +		goto out_absent_unlock;
> > +
> > +	if ((pg = vm_normal_page(vma, addr, pte)) == NULL) {
> > +		pdesc->type = PD_COPY;
> > +		goto out_unlock;
> > +	}
> > +
> > +	get_page(pg);
> > +	spin_unlock(ptl);
> > +
> > +	if (pg->mapping && !PageAnon(pg)) {
> > +		if (vma->vm_file == NULL) {
> > +			eprintk("pg->mapping!=NULL for fileless vma: %08lx\n", addr);
> > +			goto out_unsupported;
> > +		}
> > +		if (vma->vm_file->f_mapping != pg->mapping) {
> > +			eprintk("pg->mapping!=f_mapping: %08lx %p %p\n",
> > +				    addr, vma->vm_file->f_mapping, pg->mapping);
> > +			goto out_unsupported;
> > +		}
> > +		pdesc->index = (pg->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT));
> > +		/* Page is in backstore. For us it is like
> > +		 * it is not present.
> > +		 */
> > +		goto out_absent;
> > +	}
> > +
> > +	if (PageReserved(pg)) {
> > +		/* Special case: ZERO_PAGE is used, when an
> > +		 * anonymous page is accessed but not written. */
> > +		if (pg == ZERO_PAGE(addr)) {
> > +			if (pte_write(pte)) {
> > +				eprintk("not funny already, writable ZERO_PAGE\n");
> > +				goto out_unsupported;
> > +			}
> > +			/* Just copy it for now */
> > +			pdesc->type = PD_COPY;
> > +			goto out_put;
> > +		}
> > +		eprintk("reserved page %lu at %08lx\n", pg->index, addr);
> > +		goto out_unsupported;
> > +	}
> > +
> > +	if (!pg->mapping) {
> > +		eprintk("page without mapping at %08lx\n", addr);
> > +		goto out_unsupported;
> > +	}
> > +
> > +	pdesc->type = PD_COPY;
> > +
> > +out_put:
> > +	if (pg)
> > +		put_page(pg);
> > +	return;
> > +
> > +out_unlock:
> > +	spin_unlock(ptl);
> > +	goto out_put;
> > +
> > +out_absent_unlock:
> > +	spin_unlock(ptl);
> > +
> > +out_absent:
> > +	pdesc->type = PD_ABSENT;
> > +	goto out_put;
> > +
> > +out_unsupported:
> > +	pdesc->type = PD_FUNKEY;
> > +	goto out_put;
> > +}
> > +
> > +static int count_vma_pages(struct vm_area_struct *vma, struct
> > cpt_context *ctx) +{
> > +	unsigned long addr;
> > +	int page_num = 0;
> > +
> > +	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> > +		struct page_desc pd;
> > +
> > +		page_get_desc(vma, addr, &pd, ctx);
> > +
> > +		if (pd.type != PD_COPY) {
> > +			return -EINVAL;
> > +		} else {
> > +			page_num += 1;
> > +		}
> > +
> > +	}
> > +	return page_num;
> > +}
> > +
> > +/* ATTN: We give "current" to get_user_pages(). This is wrong, but
> > get_user_pages() + * does not really need this thing. It just stores some
> > page fault stats there. + *
> > + * BUG: some archs (f.e. sparc64, but not Intel*) require flush cache
> > pages + * before accessing vma.
> > + */
> > +static int dump_pages(struct vm_area_struct *vma, unsigned long start,
> > +		unsigned long end, struct cpt_context *ctx)
> > +{
> > +#define MAX_PAGE_BATCH 16
> > +	struct page *pg[MAX_PAGE_BATCH];
> > +	int npages = (end - start)/PAGE_SIZE;
> > +	int count = 0;
> > +
> > +	while (count < npages) {
> > +		int copy = npages - count;
> > +		int n;
> > +
> > +		if (copy > MAX_PAGE_BATCH)
> > +			copy = MAX_PAGE_BATCH;
> > +		n = get_user_pages(current, vma->vm_mm, start, copy,
> > +				   0, 1, pg, NULL);
> > +		if (n == copy) {
> > +			int i;
> > +			for (i=0; i<n; i++) {
> > +				char *maddr = kmap(pg[i]);
> > +				ctx->write(maddr, PAGE_SIZE, ctx);
> > +				kunmap(pg[i]);
>
> There is no error handling in this inner loop. Should be fixed imho.

Yes, you right. Already fixed in next version. I'll try to send it out 
shortly.

>
> > +			}
> > +		} else {
> > +			eprintk("get_user_pages fault");
> > +			for ( ; n > 0; n--)
> > +				page_cache_release(pg[n-1]);
> > +			return -EFAULT;
> > +		}
> > +		start += n*PAGE_SIZE;
> > +		count += n;
> > +		for ( ; n > 0; n--)
> > +			page_cache_release(pg[n-1]);
> > +	}
> > +	return 0;
> > +}
> > +
> > +static int dump_page_block(struct vm_area_struct *vma,
> > +			   struct cpt_page_block *pgb,
> > +			   struct cpt_context *ctx)
> > +{
> > +	int err;
> > +	pgb->cpt_len = sizeof(*pgb) + pgb->cpt_end - pgb->cpt_start;
> > +	pgb->cpt_type = CPT_OBJ_PAGES;
> > +	pgb->cpt_hdrlen = sizeof(*pgb);
> > +	pgb->cpt_content = CPT_CONTENT_DATA;
> > +
> > +	err = ctx->write(pgb, sizeof(*pgb), ctx);
> > +	if (!err)
> > +		err = dump_pages(vma, pgb->cpt_start, pgb->cpt_end, ctx);
> > +
> > +	return err;
> > +}
> > +
> > +static int cpt_dump_dentry(struct path *p, cpt_context_t *ctx)
> > +{
> > +	int len;
> > +	char *path;
> > +	char *buf;
> > +	struct cpt_object_hdr o;
> > +
> > +	buf = (char *)__get_free_page(GFP_KERNEL);
> > +	if (!buf)
> > +		return -ENOMEM;
> > +
> > +	path = d_path(p, buf, PAGE_SIZE);
> > +
> > +	if (IS_ERR(path)) {
> > +		free_page((unsigned long)buf);
> > +		return PTR_ERR(path);
> > +	}
> > +
> > +	len = buf + PAGE_SIZE - 1 - path;
> > +	o.cpt_len = sizeof(o) + len + 1;
> > +	o.cpt_type = CPT_OBJ_NAME;
> > +	o.cpt_hdrlen = sizeof(o);
> > +	o.cpt_content = CPT_CONTENT_NAME;
> > +	path[len] = 0;
> > +
> > +	ctx->write(&o, sizeof(o), ctx);
> > +	ctx->write(path, len + 1, ctx);
>
> Error handling?
Will fix it, thanks.

>
> > +	free_page((unsigned long)buf);
> > +
> > +	return 0;
> > +}
> > +
> > +static int dump_one_vma(struct mm_struct *mm,
> > +			struct vm_area_struct *vma, struct cpt_context *ctx)
> > +{
> > +	struct cpt_vma_image *v;
> > +	unsigned long addr;
> > +	int page_num;
> > +	int err;
> > +
> > +	v = kzalloc(sizeof(*v), GFP_KERNEL);
> > +	if (!v)
> > +		return -ENOMEM;
> > +
> > +	v->cpt_len = sizeof(*v);
> > +	v->cpt_type = CPT_OBJ_VMA;
> > +	v->cpt_hdrlen = sizeof(*v);
> > +	v->cpt_content = CPT_CONTENT_ARRAY;
> > +
> > +	v->cpt_start = vma->vm_start;
> > +	v->cpt_end = vma->vm_end;
> > +	v->cpt_flags = vma->vm_flags;
> > +	if (vma->vm_flags & VM_HUGETLB) {
> > +		eprintk("huge TLB VMAs are still not supported\n");
> > +		kfree(v);
> > +		return -EINVAL;
> > +	}
> > +	v->cpt_pgprot = vma->vm_page_prot.pgprot;
> > +	v->cpt_pgoff = vma->vm_pgoff;
> > +	v->cpt_file = CPT_NULL;
> > +	v->cpt_vma_type = CPT_VMA_TYPE_0;
> > +
> > +	page_num = count_vma_pages(vma, ctx);
> > +	if (page_num < 0) {
> > +		kfree(v);
> > +		return -EINVAL;
> > +	}
>
> AFAICS, since count_vma_pages only supports pages with PD_COPY, and since
> get_page_desc() tags text segment pages (file-mapped and not anonymous
> since not written to) as PD_ABSENT, no executable is checkpointable. So,
> where is the trick? Am I completely missing something about page mapping?
Oh, that's my fault, I have sent wrong version. I will send new patchset with 
correct page mapping today.

>
> > +	v->cpt_page_num = page_num;
> > +
> > +	if (vma->vm_file) {
> > +		v->cpt_file = 0;
> > +		v->cpt_vma_type = CPT_VMA_FILE;
> > +	}
> > +
> > +	ctx->write(v, sizeof(*v), ctx);
>
> Error handling?
Yes, will add it.

>
> > +	kfree(v);
> > +
> > +	if (vma->vm_file) {
> > +		err = cpt_dump_dentry(&vma->vm_file->f_path, ctx);
> > +		if (err < 0)
> > +			return err;
> > +	}
> > +
> > +	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
> > +		struct page_desc pd;
> > +		struct cpt_page_block pgb;
> > +
> > +		page_get_desc(vma, addr, &pd, ctx);
> > +
> > +		if (pd.type == PD_FUNKEY || pd.type == PD_ABSENT) {
> > +			eprintk("dump_one_vma: funkey page\n");
> > +			return -EINVAL;
> > +		}
> > +
> > +		pgb.cpt_start = addr;
> > +		pgb.cpt_end = addr + PAGE_SIZE;
> > +		dump_page_block(vma, &pgb, ctx);
>
> Error handling?
Yeap, thanks.

>
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int cpt_dump_mm_context(struct mm_struct *mm, struct cpt_context
> > *ctx) +{
> > +#ifdef CONFIG_X86
> > +	if (mm->context.size) {
> > +		struct cpt_obj_bits b;
> > +		int size;
> > +
> > +		mutex_lock(&mm->context.lock);
> > +
> > +		b.cpt_type = CPT_OBJ_BITS;
> > +		b.cpt_len = sizeof(b);
> > +		b.cpt_content = CPT_CONTENT_MM_CONTEXT;
> > +		b.cpt_size = mm->context.size * LDT_ENTRY_SIZE;
> > +
> > +		ctx->write(&b, sizeof(b), ctx);
> > +
> > +		size = mm->context.size * LDT_ENTRY_SIZE;
> > +
> > +		ctx->write(mm->context.ldt, size, ctx);
>
> Error handling?
Thanks again!

>
> > +
> > +		mutex_unlock(&mm->context.lock);
> > +	}
> > +#endif
> > +	return 0;
> > +}
> > +
> > +int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx)
> > +{
> > +	struct mm_struct *mm = tsk->mm;
> > +	struct cpt_mm_image *v;
> > +	struct vm_area_struct *vma;
> > +	int err;
> > +
> > +	v = kzalloc(sizeof(*v), GFP_KERNEL);
> > +	if (!v)
> > +		return -ENOMEM;
> > +
> > +	v->cpt_len = sizeof(*v);
> > +	v->cpt_type = CPT_OBJ_MM;
> > +	v->cpt_hdrlen = sizeof(*v);
> > +	v->cpt_content = CPT_CONTENT_ARRAY;
> > +
> > +	down_read(&mm->mmap_sem);
> > +	v->cpt_start_code = mm->start_code;
> > +	v->cpt_end_code = mm->end_code;
> > +	v->cpt_start_data = mm->start_data;
> > +	v->cpt_end_data = mm->end_data;
> > +	v->cpt_start_brk = mm->start_brk;
> > +	v->cpt_brk = mm->brk;
> > +	v->cpt_start_stack = mm->start_stack;
> > +	v->cpt_start_arg = mm->arg_start;
> > +	v->cpt_end_arg = mm->arg_end;
> > +	v->cpt_start_env = mm->env_start;
> > +	v->cpt_end_env = mm->env_end;
> > +	v->cpt_def_flags = mm->def_flags;
> > +	v->cpt_flags = mm->flags;
> > +	v->cpt_map_count = mm->map_count;
> > +
> > +	err = ctx->write(v, sizeof(*v), ctx);
> > +	kfree(v);
> > +
> > +	if (err) {
> > +		eprintk("error during writing mm\n");
> > +		goto err_up;
> > +	}
> > +
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		if ((err = dump_one_vma(mm, vma, ctx)) != 0)
> > +			goto err_up;
> > +	}
> > +
> > +	err = cpt_dump_mm_context(mm, ctx);
> > +
> > +err_up:
> > +	up_read(&mm->mmap_sem);
> > +
> > +	return err;
> > +}
> > +
>
> [...]
>
> Louis
