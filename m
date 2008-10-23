From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 06/10] Introduce functions to dump mm
Date: Thu, 23 Oct 2008 12:43:41 +0400
Message-ID: <200810231243.42181.major__34530.3790680648$1224751706$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-7-git-send-email-major@openvz.org>
	<1224523278.1848.123.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224523278.1848.123.camel@nimitz>
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
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 21:21 Dave Hansen wrote:
> On Sat, 2008-10-18 at 03:11 +0400, Andrey Mirkin wrote:
> > +static void page_get_desc(struct vm_area_struct *vma, unsigned long
> > addr, +                         struct page_desc *pdesc, cpt_context_t *
> > ctx) +{
> > +       struct mm_struct *mm = vma->vm_mm;
> > +       pgd_t *pgd;
> > +       pud_t *pud;
> > +       pmd_t *pmd;
> > +       pte_t *ptep, pte;
> > +       spinlock_t *ptl;
> > +       struct page *pg = NULL;
> > +       pgoff_t linear_index = (addr - vma->vm_start)/PAGE_SIZE +
> > vma->vm_pgoff; +
> > +       pdesc->index = linear_index;
> > +       pdesc->shared = 0;
> > +       pdesc->mm = CPT_NULL;
> > +
> > +       if (vma->vm_flags & VM_IO) {
> > +               pdesc->type = PD_ABSENT;
> > +               return;
> > +       }
> > +
> > +       pgd = pgd_offset(mm, addr);
> > +       if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> > +               goto out_absent;
> > +       pud = pud_offset(pgd, addr);
> > +       if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> > +               goto out_absent;
> > +       pmd = pmd_offset(pud, addr);
> > +       if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> > +               goto out_absent;
> > +#ifdef CONFIG_X86
> > +       if (pmd_huge(*pmd)) {
> > +               eprintk("page_huge\n");
> > +               goto out_unsupported;
> > +       }
> > +#endif
>
> I take it you know that this breaks with the 1GB (x86_64) and 16GB (ppc)
> large pages.
>
> Since you have the VMA, why not use is_vm_hugetlb_page()?
Right now I'm checking VM_HUGETLB flag on VMAs in dump_one_vma().
This checks were added for sanity purpose just to throw out all unsupported 
right now cases.

Andrey
