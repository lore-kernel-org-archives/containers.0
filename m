From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Wed, 27 Aug 2008 08:41:36 -0700
Message-ID: <1219851696.8680.67.camel__39430.9683739722$1219851923$gmane$org@nimitz>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>
	<1219437422.20559.146.camel@nimitz> <48B0F449.2000006@cs.columbia.edu>
	<1219768406.8680.17.camel@nimitz>  <48B49C61.1040003@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48B49C61.1040003-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-08-26 at 20:14 -0400, Oren Laadan wrote:
> >>>> +
> >>>> +	while (addr < end) {
> >>>> +		struct page *page;
> >>>> +
> >>>> +		/* simplified version of get_user_pages(): already have vma,
> >>>> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
> >>>> +
> >>>> +		cond_resched();
> >>>> +		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
> >>>> +			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
> >>>> +			if (ret & VM_FAULT_ERROR) {
> >>>> +				if (ret & VM_FAULT_OOM)
> >>>> +					ret = -ENOMEM;
> >>>> +				else if (ret & VM_FAULT_SIGBUS)
> >>>> +					ret = -EFAULT;
> >>>> +				else
> >>>> +					BUG();
> >>>> +				break;
> >>>> +			}
> >>>> +			cond_resched();
> >>>> +		}
> >>> At best this needs to get folded back into its own function.  This is
> >> This is almost identical to the original - see the preceding comment.
> > 
> > Exactly.  The code is copy-and-pasted.  If there's a bug in the
> > original, who will change this one?  Better to simply consolidate the
> > code into one copy.
> > 
> >>> pretty hard to read as-is.  Also, are there truly no in-kernel functions
> >>> that can be used for this?
> >> Can you suggest one ?
> > 
> > This is where the mentality has to shift.  Instead of thinking "there is
> > no exact in-kernel match for what I want here" we need to consider that
> > we can modify the in-kernel ones.  They can be modified to suit both
> > existing and the new needs that we have.
> 
> I agree.
> 
> However, my main goal now is not to make this patch perfect, but to provide
> a viable proof-of-concept that demonstrates how we want to do things. Unless
> you feel we are near ready to send these for inclusion soon (...), I intend
> to prioritize design and functionality.

So, you currently have buy-in on this basic approach from the OpenVZ
guys, and probably Ingo.  If you get too far along in the "design and
functionality" and a community member comes up with a really good
objection to some basic part of the "design and functionality" you're
going to have a lot of code to rewrite.

I'm trying to get minimized the quantity of "design and functionality"
down to the bare minimum set where we can get this merged.  So, yes, I
do think these should be sent for inclusion soon.

I believe that we're on course to create another large out-of-tree patch
set that does in-kernel checkpoint/restart.  We have no shortage of
those.  It's been done many times before.

This one will *HOPEFULLY* be different from all the rest when it gets
merged.  

> >>>> +	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
> >>>> +		struct page **pages = pgarr->pages;
> >>>> +		int nr = pgarr->nused;
> >>>> +		void *ptr;
> >>>> +
> >>>> +		while (nr--) {
> >>>> +			ptr = kmap(*pages);
> >>>> +			ret = cr_kwrite(ctx, ptr, PAGE_SIZE);
> >>>> +			kunmap(*pages);
> >>> Why not use kmap_atomic() here?
> >> It is my understanding that the code must not sleep between kmap_atomic()
> >> and kunmap_atomic().
> > 
> > Yes, but you're going to absolutely kill performance on systems which
> > have expensive global TLB flushes.  Frequent kmaps()s should be avoided
> > at all costs.
> > 
> > The best way around this would be to change the interface to cr_kwrite()
> > so that it didn't have to use *mapped* kernel memory.  Maybe an
> > interface that takes 'struct page'.  Or, one where we kmap_atomic() the
> > buffer, kunmap_atomic(), copy to a temporary buffer, then cr_kwrite().
> > 
> >>>> +static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
> >>>> +{
> >>>> +	struct cr_hdr h;
> >>>> +	struct cr_hdr_vma *hh = ctx->hbuf;
> >>>> +	char *fname = NULL;
> >>>> +	int flen = 0, how, nr, ret;
> >>>> +
> >>>> +	h.type = CR_HDR_VMA;
> >>>> +	h.len = sizeof(*hh);
> >>>> +	h.ptag = 0;
> >>>> +
> >>>> +	hh->vm_start = vma->vm_start;
> >>>> +	hh->vm_end = vma->vm_end;
> >>>> +	hh->vm_page_prot = vma->vm_page_prot.pgprot;
> >>>> +	hh->vm_flags = vma->vm_flags;
> >>>> +	hh->vm_pgoff = vma->vm_pgoff;
> >>>> +
> >>>> +	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
> >>>> +		pr_warning("CR: unknown VMA %#lx\n", vma->vm_flags);
> >>>> +		return -ETXTBSY;
> >>>> +	}
> >>> Hmmm.  Interesting error code for VM_HUGETLB.  :)
> >> :)  well, the usual EINVAL didn't seem suitable. Any better suggestions ?
> > 
> > -ENOSUP might be clearest for now.  "Your system call tried to do
> > something unsupported."
> 
> Are you suggesting adding a new error code ?

Dang.  What's the thing we return from system calls that are
unsupported?  Did I just dream that up?

-- Dave
