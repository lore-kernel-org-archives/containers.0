From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 06/10] Introduce functions to dump mm
Date: Thu, 23 Oct 2008 06:51:20 -0700
Message-ID: <1224769880.12673.15.camel__44230.5041746751$1224770345$gmane$org@nimitz>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-7-git-send-email-major@openvz.org>
	<1224523278.1848.123.camel@nimitz>
	<200810231243.42181.major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200810231243.42181.major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-10-23 at 12:43 +0400, Andrey Mirkin wrote:
> > > +#ifdef CONFIG_X86
> > > +       if (pmd_huge(*pmd)) {
> > > +               eprintk("page_huge\n");
> > > +               goto out_unsupported;
> > > +       }
> > > +#endif
> >
> > I take it you know that this breaks with the 1GB (x86_64) and 16GB (ppc)
> > large pages.
> >
> > Since you have the VMA, why not use is_vm_hugetlb_page()?
> Right now I'm checking VM_HUGETLB flag on VMAs in dump_one_vma().
> This checks were added for sanity purpose just to throw out all unsupported 
> right now cases.

I'm telling you that it's no good.  Not only should this path never be
hit.  But, if it is, you'll crash anyway in some cases.

It's a bad check.  At best it misleads the reader to think that you've
covered your bases.

-- Dave
