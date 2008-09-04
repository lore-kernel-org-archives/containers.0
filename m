From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v3][PATCH 5/9] Memory managemnet (restore)
Date: Thu, 04 Sep 2008 11:08:03 -0700
Message-ID: <1220551683.23386.32.camel__46114.8513983518$1220552573$gmane$org@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040404060.5982@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040404060.5982-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-09-04 at 04:04 -0400, Oren Laadan wrote:
> +asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);

This needs to go into a header.

> +int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
> +{
> +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int n, rparent;
> +
> +	rparent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
> +	cr_debug("parent %d rparent %d nldt %d\n", parent, rparent, hh->nldt);
> +	if (rparent < 0)
> +		return rparent;
> +	if (rparent != parent)
> +		return -EINVAL;
> +
> +	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
> +		return -EINVAL;
> +
> +	/* to utilize the syscall modify_ldt() we first convert the data
> +	 * in the checkpoint image from 'struct desc_struct' to 'struct
> +	 * user_desc' with reverse logic of inclue/asm/desc.h:fill_ldt() */

Typo in the filename there ^^.

> +	for (n = 0; n < hh->nldt; n++) {
> +		struct user_desc info;
> +		struct desc_struct desc;
> +		mm_segment_t old_fs;
> +		int ret;
> +
> +		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
> +		if (ret < 0)
> +			return ret;
> +
> +		info.entry_number = n;
> +		info.base_addr = desc.base0 | (desc.base1 << 16);
> +		info.limit = desc.limit0;
> +		info.seg_32bit = desc.d;
> +		info.contents = desc.type >> 2;
> +		info.read_exec_only = (desc.type >> 1) ^ 1;
> +		info.limit_in_pages = desc.g;
> +		info.seg_not_present = desc.p ^ 1;
> +		info.useable = desc.avl;

Wouldn't it just be better to save the checkpoint image in the format
that the syscall takes in the first place?

> +		old_fs = get_fs();
> +		set_fs(get_ds());
> +		ret = sys_modify_ldt(1, &info, sizeof(info));
> +		set_fs(old_fs);
> +
> +		if (ret < 0)
> +			return ret;
> +	}
> +
> +	load_LDT(&mm->context);
> +
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	return 0;
> +}
...
> +int cr_read_fname(struct cr_ctx *ctx, void *fname, int flen)
> +{
> +	return cr_read_obj_type(ctx, fname, flen, CR_HDR_FNAME);
> +}
> +
> +/**
> + * cr_read_open_fname - read a file name and open a file
> + * @ctx: checkpoint context
> + * @flags: file flags
> + * @mode: file mode
> + */
> +struct file *cr_read_open_fname(struct cr_ctx *ctx, int flags, int mode)
> +{
> +	struct file *file;
> +	char *fname;
> +	int flen, ret;
> +
> +	flen = PATH_MAX;
> +	fname = kmalloc(flen, GFP_KERNEL);
> +	if (!fname)
> +		return ERR_PTR(-ENOMEM);
> +
> +	ret = cr_read_fname(ctx, fname, flen);
> +	cr_debug("fname '%s' flags %#x mode %#x\n", fname, flags, mode);
> +	if (ret >= 0)
> +		file = filp_open(fname, flags, mode);
> +	else
> +		file = ERR_PTR(ret);
> +
> +	kfree(fname);
> +	return file;
> +}

This looks much better than what was being used before.  Nice!

> +/*
> + * Unlike checkpoint, restart is executed in the context of each restarting
> + * process: vma regions are restored via a call to mmap(), and the data is
> + * read in directly to the address space of the current process
> + */
> +
> +/**
> + * cr_vma_read_pages_addr - read addresses of pages to page-array chain
> + * @ctx - restart context
> + * @npages - number of pages
> + */
> +static int cr_vma_read_pages_addr(struct cr_ctx *ctx, int npages)
> +{
> +	struct cr_pgarr *pgarr;
> +	int nr, ret;
> +
> +	while (npages) {
> +		pgarr = cr_pgarr_prep(ctx);
> +		if (!pgarr)
> +			return -ENOMEM;
> +		nr = min(npages, (int) pgarr->nleft);

Do you find it any easier to read this as:

	nr = npages;
	if (nr > pgarr->nleft)
		nr = pgarr->nleft;

?

> +		ret = cr_kread(ctx, pgarr->addrs, nr * sizeof(unsigned long));
> +		if (ret < 0)
> +			return ret;
> +		pgarr->nleft -= nr;
> +		pgarr->nused += nr;
> +		npages -= nr;
> +	}
> +	return 0;
> +}
> +
> +/**
> + * cr_vma_read_pages_data - read in data of pages in page-array chain
> + * @ctx - restart context
> + * @npages - number of pages
> + */
> +static int cr_vma_read_pages_data(struct cr_ctx *ctx, int npages)
> +{
> +	struct cr_pgarr *pgarr;
> +	unsigned long *addrs;
> +	int nr, ret;
> +
> +	for (pgarr = ctx->pgarr; npages; pgarr = pgarr->next) {
> +		addrs = pgarr->addrs;
> +		nr = pgarr->nused;
> +		npages -= nr;
> +		while (nr--) {
> +			ret = cr_uread(ctx, (void *) *(addrs++), PAGE_SIZE);

The void cast is unnecessary, right?

> +			if (ret < 0)
> +				return ret;
> +		}
> +	}
> +
> +	return 0;
> +}

I'm having some difficulty parsing this function.  Could we
s/data/contents/ in the function name?  It also looks like addrs is
being used like an array here.  Can we use it explicitly that way?  I'd
also like to see it called vaddr or something explicit about what kinds
of addresses they are.

> +/* change the protection of an address range to be writable/non-writable.
> + * this is useful when restoring the memory of a read-only vma */
> +static int cr_vma_writable(struct mm_struct *mm, unsigned long start,
> +			   unsigned long end, int writable)

"cr_vma_writable" is a question to me.  This needs to be
"cr_vma_make_writable" or something to indicate that it is modifying the
vma.

> +{
> +	struct vm_area_struct *vma, *prev;
> +	unsigned long flags = 0;
> +	int ret = -EINVAL;
> +
> +	cr_debug("vma %#lx-%#lx writable %d\n", start, end, writable);
> +
> +	down_write(&mm->mmap_sem);
> +	vma = find_vma_prev(mm, start, &prev);
> +	if (unlikely(!vma || vma->vm_start > end || vma->vm_end < start))
> +		goto out;

Kill the unlikely(), please.  It's unnecessary and tends to make things
slower when not used correctly.  Can you please check all the future
patches and make sure that you don't accidentally introduce these later?

> +	if (writable && !(vma->vm_flags & VM_WRITE))
> +		flags = vma->vm_flags | VM_WRITE;
> +	else if (!writable && (vma->vm_flags & VM_WRITE))
> +		flags = vma->vm_flags & ~VM_WRITE;
> +	cr_debug("flags %#lx\n", flags);
> +	if (flags)
> +		ret = mprotect_fixup(vma, &prev, vma->vm_start,
> +				     vma->vm_end, flags);

Is this to fixup the same things that setup_arg_pages() uses it for?  We
should probably consolidate those calls somehow.  

> + out:
> +	up_write(&mm->mmap_sem);
> +	return ret;
> +}
> +
> +/**
> + * cr_vma_read_pages - read in pages for to restore a vma
> + * @ctx - restart context
> + * @cr_vma - vma descriptor from restart
> + */
> +static int cr_vma_read_pages(struct cr_ctx *ctx, struct cr_hdr_vma *cr_vma)
> +{
> +	struct mm_struct *mm = current->mm;
> +	int ret = 0;
> +
> +	if (!cr_vma->nr_pages)
> +		return 0;

Looking at this code, I can now tell that we need to be more explicit
about what nr_pages is.  Is it the nr_pages that the vma spans,
contains, maps....??  Why do we need to check it here?

> +	/* in the unlikely case that this vma is read-only */
> +	if (!(cr_vma->vm_flags & VM_WRITE))
> +		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 1);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_vma_read_pages_addr(ctx, cr_vma->nr_pages);

The english here is a bit funky.  I think this needs to be
cr_vma_read_page_addrs().  The other way makes it sound like you're
reading the "page's addr", meaning a singular page.  Same for data.

> +	if (ret < 0)
> +		goto out;
> +	ret = cr_vma_read_pages_data(ctx, cr_vma->nr_pages);
> +	if (ret < 0)
> +		goto out;
> +
> +	cr_pgarr_release(ctx);	/* reset page-array chain */

Where did this sucker get allocated?  This is going to be a bit
difficult to audit since it isn't allocated and freed (or released) at
the same level.  Seems like it would be much nicer if it was allocated
at the beginning of this function.

> +	/* restore original protection for this vma */
> +	if (!(cr_vma->vm_flags & VM_WRITE))
> +		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 0);
> +
> + out:
> +	return ret;
> +}

Ugh.  Is this a security hole?  What if the user was not allowed to
write to the file being mmap()'d by this VMA?  Is this a window where
someone could come in and (using ptrace or something similar) write to
the file?

We copy into the process address space all the time when not in its
context explicitly.  

> +/**
> + * cr_calc_map_prot_bits - convert vm_flags to mmap protection
> + * orig_vm_flags: source vm_flags
> + */
> +static unsigned long cr_calc_map_prot_bits(unsigned long orig_vm_flags)
> +{
> +	unsigned long vm_prot = 0;
> +
> +	if (orig_vm_flags & VM_READ)
> +		vm_prot |= PROT_READ;
> +	if (orig_vm_flags & VM_WRITE)
> +		vm_prot |= PROT_WRITE;
> +	if (orig_vm_flags & VM_EXEC)
> +		vm_prot |= PROT_EXEC;
> +	if (orig_vm_flags & PROT_SEM)   /* only (?) with IPC-SHM  */
> +		vm_prot |= PROT_SEM;
> +
> +	return vm_prot;
> +}
> +
> +/**
> + * cr_calc_map_flags_bits - convert vm_flags to mmap flags
> + * orig_vm_flags: source vm_flags
> + */
> +static unsigned long cr_calc_map_flags_bits(unsigned long orig_vm_flags)
> +{
> +	unsigned long vm_flags = 0;
> +
> +	vm_flags = MAP_FIXED;
> +	if (orig_vm_flags & VM_GROWSDOWN)
> +		vm_flags |= MAP_GROWSDOWN;
> +	if (orig_vm_flags & VM_DENYWRITE)
> +		vm_flags |= MAP_DENYWRITE;
> +	if (orig_vm_flags & VM_EXECUTABLE)
> +		vm_flags |= MAP_EXECUTABLE;
> +	if (orig_vm_flags & VM_MAYSHARE)
> +		vm_flags |= MAP_SHARED;
> +	else
> +		vm_flags |= MAP_PRIVATE;
> +
> +	return vm_flags;
> +}
> +
> +static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
> +{
> +	struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	unsigned long vm_size, vm_flags, vm_prot, vm_pgoff;
> +	unsigned long addr;
> +	unsigned long flags;
> +	struct file *file = NULL;
> +	int parent, ret = 0;
> +
> +	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
> +	if (parent < 0)
> +		return parent;
> +	else if (parent != 0)
> +		return -EINVAL;
> +
> +	cr_debug("vma %#lx-%#lx type %d nr_pages %d\n",
> +		 (unsigned long) hh->vm_start, (unsigned long) hh->vm_end,
> +		 (int) hh->vma_type, (int) hh->nr_pages);
> +
> +	if (hh->vm_end < hh->vm_start || hh->nr_pages < 0)
> +		return -EINVAL;
> +
> +	vm_size = hh->vm_end - hh->vm_start;
> +	vm_prot = cr_calc_map_prot_bits(hh->vm_flags);
> +	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
> +	vm_pgoff = hh->vm_pgoff;
> +
> +	switch (hh->vma_type) {
> +
> +	case CR_VMA_ANON:		/* anonymous private mapping */
> +		/* vm_pgoff for anonymous mapping is the "global" page
> +		   offset (namely from addr 0x0), so we force a zero */
> +		vm_pgoff = 0;
> +		break;
> +
> +	case CR_VMA_FILE:		/* private mapping from a file */
> +		/* O_RDWR only needed if both (VM_WRITE|VM_SHARED) are set */
> +		flags = hh->vm_flags & (VM_WRITE | VM_SHARED);
> +		flags = (flags == (VM_WRITE | VM_SHARED) ? O_RDWR : O_RDONLY);

Man, that's hard to parse.  Could you break that up a little bit to make
it easier to read?

> +		file = cr_read_open_fname(ctx, flags, 0);
> +		if (IS_ERR(file))
> +			return PTR_ERR(file);
> +		break;
> +
> +	default:
> +		return -EINVAL;
> +
> +	}
> +
> +	down_write(&mm->mmap_sem);
> +	addr = do_mmap_pgoff(file, (unsigned long) hh->vm_start,
> +			     vm_size, vm_prot, vm_flags, vm_pgoff);

I'd probably just make a local vm_start to make these all consistent and
do all the ugly casting in one place.

> +	up_write(&mm->mmap_sem);
> +	cr_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
> +		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
> +
> +	/* the file (if opened) is now referenced by the vma */
> +	if (file)
> +		filp_close(file, NULL);
> +
> +	if (IS_ERR((void *) addr))
> +		return PTR_ERR((void *) addr);
> +
> +	/*
> +	 * CR_VMA_ANON: read in memory as is
> +	 * CR_VMA_FILE: read in memory as is
> +	 * (more to follow ...)
> +	 */
> +
> +	switch (hh->vma_type) {
> +	case CR_VMA_ANON:
> +	case CR_VMA_FILE:
> +		/* standard case: read the data into the memory */
> +		ret = cr_vma_read_pages(ctx, hh);
> +		break;
> +	}
> +
> +	if (ret < 0)
> +		return ret;
> +
> +	if (vm_prot & PROT_EXEC)
> +		flush_icache_range(hh->vm_start, hh->vm_end);

Why the heck is this here?  Isn't this a fresh mm?  We shouldn't have to
do this unless we had a VMA here previously.  Maybe it would be more
efficient to do this when tearing down the old vmas.

> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	cr_debug("vma retval %d\n", ret);
> +	return 0;
> +}
> +
> +static int cr_destroy_mm(struct mm_struct *mm)
> +{
> +	struct vm_area_struct *vmnext = mm->mmap;
> +	struct vm_area_struct *vma;
> +	int ret;
> +
> +	while (vmnext) {
> +		vma = vmnext;
> +		vmnext = vmnext->vm_next;
> +		ret = do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
> +		if (ret < 0) {
> +			pr_debug("CR: restart failed do_munmap (%d)\n", ret);
> +			return ret;
> +		}
> +	}
> +	return 0;
> +}
> +
> +int cr_read_mm(struct cr_ctx *ctx)
> +{
> +	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct mm_struct *mm;
> +	int nr, parent, ret;
> +
> +	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
> +	if (parent < 0)
> +		return parent;
> +#if 0	/* activate when containers are used */
> +	if (parent != task_pid_vnr(current))
> +		return -EINVAL;
> +#endif
> +	cr_debug("map_count %d\n", hh->map_count);
> +
> +	/* XXX need more sanity checks */
> +	if (hh->start_code > hh->end_code ||
> +	    hh->start_data > hh->end_data || hh->map_count < 0)
> +		return -EINVAL;
> +
> +	mm = current->mm;
> +
> +	/* point of no return -- destruct current mm */
> +	down_write(&mm->mmap_sem);
> +	ret = cr_destroy_mm(mm);

The other approach would be to do something more analogous to exec():
create the entire new mm and switch to it in the end. 

-- Dave
