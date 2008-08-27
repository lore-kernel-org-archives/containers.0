From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Tue, 26 Aug 2008 20:14:25 -0400
Message-ID: <48B49C61.1040003__25397.067613858$1219796302$gmane$org@cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>	
	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>	
	<1219437422.20559.146.camel@nimitz>
	<48B0F449.2000006@cs.columbia.edu>
	<1219768406.8680.17.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1219768406.8680.17.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Sun, 2008-08-24 at 01:40 -0400, Oren Laadan wrote:
>>>> +/* vma subtypes */
>>>> +enum {
>>>> +	CR_VMA_ANON = 1,
>>>> +	CR_VMA_FILE
>>>> +};
>>> Is this really necessary, or can we infer it from the contents of the
>>> VMA?
>> This classification eventually simplifies both dump and restore. For
>> instance, it decides whether a file name follows or not.
>>
>> There will be more, later:  CR_VMA_FILE_UNLINKED (mapped to an unlinked
>> file), CR_VMA_ANON_SHARED (shared anonymous), CR_VMA_ANON_SHARED_SKIP
>> (shared anonymous, had been sent before) and so on.
> 
> I still don't see there being a need to explicitly specify the
> distinction.  Why should a VMA mapping an unlinked file be any different
> from a linked one?  It should point over to the 'file' checkpoint
> structure and let the real work be done there.
> 
> There are no truly anonymous shared areas.  They anon ones are still
> file-backed as far as the kernel is concerned.  If we do the file saving
> correctly, I think most of these problems just fall out.

The classifications helps to make the code cleaner (and more readable). In
any case, you need at least to save a classifier that tells whether a shared
VMA is anonymous, or mapped to a file, or is an IPC shmem segment (and also
whether that IPC segment has been removed - a la unlinked): you simply don't
treat them equally; and on the restart side you can't re-test it on the VMA 
structure itself.

Given that we need a classifier anyway, re-using it to describe all VMAs and
not only distinguish the above (and maybe more) cases not only enhances the
readability of the code, but also allows to merge common code paths based on
the value of the classifier.

Probably you won't be convinced until I add the code to support all types of
VMAs. As it is, the classifier is harmless, so please bare with it for now.

> 
>>>>   struct cr_hdr_head {
>>>>   	__u64 magic;
>>>>

[...]

>>>> +
>>>> +	while (addr < end) {
>>>> +		struct page *page;
>>>> +
>>>> +		/* simplified version of get_user_pages(): already have vma,
>>>> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
>>>> +
>>>> +		cond_resched();
>>>> +		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
>>>> +			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
>>>> +			if (ret & VM_FAULT_ERROR) {
>>>> +				if (ret & VM_FAULT_OOM)
>>>> +					ret = -ENOMEM;
>>>> +				else if (ret & VM_FAULT_SIGBUS)
>>>> +					ret = -EFAULT;
>>>> +				else
>>>> +					BUG();
>>>> +				break;
>>>> +			}
>>>> +			cond_resched();
>>>> +		}
>>> At best this needs to get folded back into its own function.  This is
>> This is almost identical to the original - see the preceding comment.
> 
> Exactly.  The code is copy-and-pasted.  If there's a bug in the
> original, who will change this one?  Better to simply consolidate the
> code into one copy.
> 
>>> pretty hard to read as-is.  Also, are there truly no in-kernel functions
>>> that can be used for this?
>> Can you suggest one ?
> 
> This is where the mentality has to shift.  Instead of thinking "there is
> no exact in-kernel match for what I want here" we need to consider that
> we can modify the in-kernel ones.  They can be modified to suit both
> existing and the new needs that we have.

I agree.

However, my main goal now is not to make this patch perfect, but to provide
a viable proof-of-concept that demonstrates how we want to do things. Unless
you feel we are near ready to send these for inclusion soon (...), I intend
to prioritize design and functionality.

I'll add a FIXME comment there. Of course, should you provide a patch to fix
this (or any other such issue) I'll merge it in for the next round.

> 
>>>> +	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
>>>> +		struct page **pages = pgarr->pages;
>>>> +		int nr = pgarr->nused;
>>>> +		void *ptr;
>>>> +
>>>> +		while (nr--) {
>>>> +			ptr = kmap(*pages);
>>>> +			ret = cr_kwrite(ctx, ptr, PAGE_SIZE);
>>>> +			kunmap(*pages);
>>> Why not use kmap_atomic() here?
>> It is my understanding that the code must not sleep between kmap_atomic()
>> and kunmap_atomic().
> 
> Yes, but you're going to absolutely kill performance on systems which
> have expensive global TLB flushes.  Frequent kmaps()s should be avoided
> at all costs.
> 
> The best way around this would be to change the interface to cr_kwrite()
> so that it didn't have to use *mapped* kernel memory.  Maybe an
> interface that takes 'struct page'.  Or, one where we kmap_atomic() the
> buffer, kunmap_atomic(), copy to a temporary buffer, then cr_kwrite().
> 
>>>> +static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
>>>> +{
>>>> +	struct cr_hdr h;
>>>> +	struct cr_hdr_vma *hh = ctx->hbuf;
>>>> +	char *fname = NULL;
>>>> +	int flen = 0, how, nr, ret;
>>>> +
>>>> +	h.type = CR_HDR_VMA;
>>>> +	h.len = sizeof(*hh);
>>>> +	h.ptag = 0;
>>>> +
>>>> +	hh->vm_start = vma->vm_start;
>>>> +	hh->vm_end = vma->vm_end;
>>>> +	hh->vm_page_prot = vma->vm_page_prot.pgprot;
>>>> +	hh->vm_flags = vma->vm_flags;
>>>> +	hh->vm_pgoff = vma->vm_pgoff;
>>>> +
>>>> +	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
>>>> +		pr_warning("CR: unknown VMA %#lx\n", vma->vm_flags);
>>>> +		return -ETXTBSY;
>>>> +	}
>>> Hmmm.  Interesting error code for VM_HUGETLB.  :)
>> :)  well, the usual EINVAL didn't seem suitable. Any better suggestions ?
> 
> -ENOSUP might be clearest for now.  "Your system call tried to do
> something unsupported."

Are you suggesting adding a new error code ?

Oren.
