From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] c/r: define s390-specific checkpoint-restart code (v3)
Date: Wed, 4 Feb 2009 12:27:13 -0600
Message-ID: <20090204182713.GA8722@us.ibm.com>
References: <20090203161223.GA17998@us.ibm.com>
	<200902041019.53683.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200902041019.53683.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Christian Borntraeger (borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org):
> Am Tuesday 03 February 2009 17:12:23 schrieb Serge E. Hallyn:
> [...]
> > +/* Nothing to do for mm context state */
> > +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int
> > parent) +{
> > +	struct cr_hdr h;
> > +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> > +	int ret;
> > +
> > +	h.type = CR_HDR_MM_CONTEXT;
> > +	h.len = sizeof(*hh);
> > +	h.parent = parent;
> > +
> > +#if 0
> > +	/* Oren's v13 is on an older kernel which has no vdso_base */
> > +	/* on newer kernel, we'll have to enable this */
> > +	hh->vdso_base = mm->context.vdso_base;
> > +	printk(KERN_NOTICE "checkpointing vdso_base %lx\n", hh->vdso_base);
> > +#else
> > +	hh->vdso_base = 0;
> > +#endif
> > +
> > +	ret = cr_write_obj(ctx, &h, hh);
> > +	cr_hbuf_put(ctx, sizeof(*hh));
> > +
> > +	return ret;
> > +}

Hi,  thanks for taking a look.  (I can definately use some help)

> Hmm, maybe you should also save/restore other elements of mm_context_t.

Oren pointed out (on Jan 15, see
https://lists.linux-foundation.org/pipermail/containers/2009-January/015304.html)
that the arch-independent restart code will re-create the checkpointed
memory mappings using do_mmap_pgoff().  So the other mm_context_t
contents should be automatically handled, right?

> At least noexec, has_pgste and alloc_pgste have an impact on the page table 
> layout and special features like no execute or the ability to run kvm guests.

I went ahead and added those three - but they're always all 0 on my
testcases so far, and restoring them doesn't fix my restart segfault :(

How and why are they supposed to be set though?  Looking through the
s390 arch code, I don't really see anything justifying hand-tweaking
them.

> > +int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int
> > rparent) +{
> > +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> > +	int parent, ret = -EINVAL;
> > +
> > +	s390_enable_sie();
> 
> Hmm, why do you call s390_enable_sie()? It will fail on multi-threaded apps 
> and will create enhanced page tables for running kvm guest otherwise. It is 
> not needed for non-kvm processes. See the has_pgste/alloc_pgste topic above.

Short answer: bc martin told me to :)  But I take it I misunderstood,
and should only do that if running in kvm?
(That email at
https://lists.linux-foundation.org/pipermail/containers/2009-January/015305.html)

But thinking through this:  if some task 798 is running inside kvm,
it will have already done s390_enable_sie(), right?  So if it now
does sys_restart(), we shouldn't run that again, right?

So I've removed it again.  (Which still doesn't solve my segfault on
restart.  At the moment I'm busily learning about the VM debugger :)

thanks,
-serge
