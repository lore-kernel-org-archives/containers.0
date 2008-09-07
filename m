From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 5/9] Memory managemnet (restore)
Date: Sat, 06 Sep 2008 23:09:06 -0400
Message-ID: <48C345D2.1020603__21803.0403172181$1220757264$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0809040404060.5982@takamine.ncl.cs.columbia.edu>
	<1220551683.23386.32.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220551683.23386.32.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Thu, 2008-09-04 at 04:04 -0400, Oren Laadan wrote:
>> +asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);
> 
> This needs to go into a header.
> 
>> +int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
>> +{
>> +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
>> +	int n, rparent;
>> +
>> +	rparent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
>> +	cr_debug("parent %d rparent %d nldt %d\n", parent, rparent, hh->nldt);
>> +	if (rparent < 0)
>> +		return rparent;
>> +	if (rparent != parent)
>> +		return -EINVAL;
>> +
>> +	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
>> +		return -EINVAL;
>> +
>> +	/* to utilize the syscall modify_ldt() we first convert the data
>> +	 * in the checkpoint image from 'struct desc_struct' to 'struct
>> +	 * user_desc' with reverse logic of inclue/asm/desc.h:fill_ldt() */
> 
> Typo in the filename there ^^.
> 
>> +	for (n = 0; n < hh->nldt; n++) {
>> +		struct user_desc info;
>> +		struct desc_struct desc;
>> +		mm_segment_t old_fs;
>> +		int ret;
>> +
>> +		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
>> +		if (ret < 0)
>> +			return ret;
>> +
>> +		info.entry_number = n;
>> +		info.base_addr = desc.base0 | (desc.base1 << 16);
>> +		info.limit = desc.limit0;
>> +		info.seg_32bit = desc.d;
>> +		info.contents = desc.type >> 2;
>> +		info.read_exec_only = (desc.type >> 1) ^ 1;
>> +		info.limit_in_pages = desc.g;
>> +		info.seg_not_present = desc.p ^ 1;
>> +		info.useable = desc.avl;
> 
> Wouldn't it just be better to save the checkpoint image in the format
> that the syscall takes in the first place?

Because the syscall accepts a different format (user_desc) than it gives
back (desc_struct, which is the kernel format), conversion must occur,
either during checkpoint or during restart.
I prefer in restart: because checkpoint is more performance critical,
because it allows - in the future - to directly insert the data bypassing
the syscall (like openvz), and because we may need conversions anyway in
restart, e.g. to restart a 32 bit app on a 64 bit kernel.

> 

[...]

>> +static int cr_vma_read_pages_addr(struct cr_ctx *ctx, int npages)
>> +{
>> +	struct cr_pgarr *pgarr;
>> +	int nr, ret;
>> +
>> +	while (npages) {
>> +		pgarr = cr_pgarr_prep(ctx);
>> +		if (!pgarr)
>> +			return -ENOMEM;
>> +		nr = min(npages, (int) pgarr->nleft);
> 
> Do you find it any easier to read this as:
> 
> 	nr = npages;
> 	if (nr > pgarr->nleft)
> 		nr = pgarr->nleft;
> 
> ?

Just shorter.

>> +		ret = cr_kread(ctx, pgarr->addrs, nr * sizeof(unsigned long));
>> +		if (ret < 0)
>> +			return ret;
>> +		pgarr->nleft -= nr;
>> +		pgarr->nused += nr;
>> +		npages -= nr;
>> +	}
>> +	return 0;
>> +}
>> +
>> +/**
>> + * cr_vma_read_pages_data - read in data of pages in page-array chain
>> + * @ctx - restart context
>> + * @npages - number of pages
>> + */
>> +static int cr_vma_read_pages_data(struct cr_ctx *ctx, int npages)
>> +{
>> +	struct cr_pgarr *pgarr;
>> +	unsigned long *addrs;
>> +	int nr, ret;
>> +
>> +	for (pgarr = ctx->pgarr; npages; pgarr = pgarr->next) {
>> +		addrs = pgarr->addrs;
>> +		nr = pgarr->nused;
>> +		npages -= nr;
>> +		while (nr--) {
>> +			ret = cr_uread(ctx, (void *) *(addrs++), PAGE_SIZE);
> 
> The void cast is unnecessary, right?

It is: cr_uread() expects "void *", while "*addrs" is "unsigned long".

> 
>> +			if (ret < 0)
>> +				return ret;
>> +		}
>> +	}
>> +
>> +	return 0;
>> +}
> 
> I'm having some difficulty parsing this function.  Could we
> s/data/contents/ in the function name?  It also looks like addrs is
> being used like an array here.  Can we use it explicitly that way?  I'd
> also like to see it called vaddr or something explicit about what kinds
> of addresses they are.
> 
>> +/* change the protection of an address range to be writable/non-writable.
>> + * this is useful when restoring the memory of a read-only vma */
>> +static int cr_vma_writable(struct mm_struct *mm, unsigned long start,
>> +			   unsigned long end, int writable)
> 
> "cr_vma_writable" is a question to me.  This needs to be
> "cr_vma_make_writable" or something to indicate that it is modifying the
> vma.
> 
>> +{
>> +	struct vm_area_struct *vma, *prev;
>> +	unsigned long flags = 0;
>> +	int ret = -EINVAL;
>> +
>> +	cr_debug("vma %#lx-%#lx writable %d\n", start, end, writable);
>> +
>> +	down_write(&mm->mmap_sem);
>> +	vma = find_vma_prev(mm, start, &prev);
>> +	if (unlikely(!vma || vma->vm_start > end || vma->vm_end < start))
>> +		goto out;
> 
> Kill the unlikely(), please.  It's unnecessary and tends to make things
> slower when not used correctly.  Can you please check all the future
> patches and make sure that you don't accidentally introduce these later?
> 
>> +	if (writable && !(vma->vm_flags & VM_WRITE))
>> +		flags = vma->vm_flags | VM_WRITE;
>> +	else if (!writable && (vma->vm_flags & VM_WRITE))
>> +		flags = vma->vm_flags & ~VM_WRITE;
>> +	cr_debug("flags %#lx\n", flags);
>> +	if (flags)
>> +		ret = mprotect_fixup(vma, &prev, vma->vm_start,
>> +				     vma->vm_end, flags);
> 
> Is this to fixup the same things that setup_arg_pages() uses it for?  We
> should probably consolidate those calls somehow.  

This is needed for a VMA that has modified pages but is read-only: e.g. a
task modifies memory then calls mprotect() to make it read-only.
Since during restart we will recreate this VMA as read-only, we need to
temporarily make it read-write to be able to read the saved contents into
it, and then restore the read-only protection.

setup_arg_pages() is unrelated, and the code doesn't seem to have much in
common.

> 
>> + out:
>> +	up_write(&mm->mmap_sem);
>> +	return ret;
>> +}
>> +
>> +/**
>> + * cr_vma_read_pages - read in pages for to restore a vma
>> + * @ctx - restart context
>> + * @cr_vma - vma descriptor from restart
>> + */
>> +static int cr_vma_read_pages(struct cr_ctx *ctx, struct cr_hdr_vma *cr_vma)
>> +{
>> +	struct mm_struct *mm = current->mm;
>> +	int ret = 0;
>> +
>> +	if (!cr_vma->nr_pages)
>> +		return 0;
> 
> Looking at this code, I can now tell that we need to be more explicit
> about what nr_pages is.  Is it the nr_pages that the vma spans,
> contains, maps....??  Why do we need to check it here?

nr_pages is the number of pages _saved_ for this VMA, that is, the number
of pages to follow to read in. If it's zero, we don't read anything (the
VMA is had no dirty pages). Otherwise, we need to read that many addresses
followed by that many pages.

> 
>> +	/* in the unlikely case that this vma is read-only */
>> +	if (!(cr_vma->vm_flags & VM_WRITE))
>> +		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 1);
>> +	if (ret < 0)
>> +		goto out;
>> +	ret = cr_vma_read_pages_addr(ctx, cr_vma->nr_pages);
> 
> The english here is a bit funky.  I think this needs to be
> cr_vma_read_page_addrs().  The other way makes it sound like you're
> reading the "page's addr", meaning a singular page.  Same for data.
> 
>> +	if (ret < 0)
>> +		goto out;
>> +	ret = cr_vma_read_pages_data(ctx, cr_vma->nr_pages);
>> +	if (ret < 0)
>> +		goto out;
>> +
>> +	cr_pgarr_release(ctx);	/* reset page-array chain */
> 
> Where did this sucker get allocated?  This is going to be a bit
> difficult to audit since it isn't allocated and freed (or released) at
> the same level.  Seems like it would be much nicer if it was allocated
> at the beginning of this function.

The name is misleading, should be:  cr_pgarr_reset().  What happens is
that we allocate the chain of cr_pgarr on demand. Once done with one MM,
we reset the state and reuse the same chain until we need to expand it.
I renamed and added comments about it in the next version.

> 
>> +	/* restore original protection for this vma */
>> +	if (!(cr_vma->vm_flags & VM_WRITE))
>> +		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 0);
>> +
>> + out:
>> +	return ret;
>> +}
> 
> Ugh.  Is this a security hole?  What if the user was not allowed to
> write to the file being mmap()'d by this VMA?  Is this a window where
> someone could come in and (using ptrace or something similar) write to
> the file?

Not a security hole: this is only for private memory, so it never
modifies the underlying file. This is related to what I explained before
about read-only VMAs that have modified pages.

The process is restarting, inside a container that is restarting. All
tasks inside should be calling sys_restart() (by design) and no other
process from outside should be allowed to ptrace them at this point.

(In any case, if some other tasks ptraces this task, it can make it do
anything anyhow).

> 
> We copy into the process address space all the time when not in its
> context explicitly.  

Huh ?

> 
>> +/**
>> + * cr_calc_map_prot_bits - convert vm_flags to mmap protection
>> + * orig_vm_flags: source vm_flags

[...]

>> +	switch (hh->vma_type) {
>> +	case CR_VMA_ANON:
>> +	case CR_VMA_FILE:
>> +		/* standard case: read the data into the memory */
>> +		ret = cr_vma_read_pages(ctx, hh);
>> +		break;
>> +	}
>> +
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	if (vm_prot & PROT_EXEC)
>> +		flush_icache_range(hh->vm_start, hh->vm_end);
> 
> Why the heck is this here?  Isn't this a fresh mm?  We shouldn't have to
> do this unless we had a VMA here previously.  Maybe it would be more
> efficient to do this when tearing down the old vmas.

Good point, thanks.

[...]

Oren.
