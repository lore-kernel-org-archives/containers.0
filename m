From: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] cr: Introduce s390x checkpoint/restart code
Date: Thu, 15 Jan 2009 11:10:44 +0100
Message-ID: <1232014244.30152.19.camel@localhost>
References: <20090115050523.GA10415@us.ibm.com>
	<1232012395.30152.13.camel@localhost>
	<496F082C.3020008@cs.columbia.edu>
Reply-To: schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <496F082C.3020008-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-01-15 at 04:55 -0500, Oren Laadan wrote:
> 
> Martin Schwidefsky wrote:
> > This hunk from patch #2 worries me a bit:
> > 
> >  struct cr_hdr_mm_context {
> > -       __s16 unimplemented;
> > +#if 0
> > +       unsigned long asce_bits;
> > +       unsigned long asce_limit;
> > +       int noexec;
> > +       int has_pgste;
> > +       int alloc_pgste;
> > +#endif
> > +       unsigned long vdso_base;
> >  };
> > 
> > The page table can have 2, 3, or 4 levels and if KVM is used the page
> > tables have a the pgste table attached to them. If that is ignored then
> > the creation of the process address space on restart is definitly
> > broken.
> 
> Disclaimer: I have zero knowledge about s390 specifics, so take
> this with a grain of salt...
> 
> That said, I wonder why would we care about the page table choice ?
> Does user-level have any notion of this low-level detail ?
> 
> We save the VMAs in checkpoint, and reconstruct them in restart by
> calling do_mmap_pgoff(). The nearest we get to that level is in
> calling follow_page() in cr_consider_private_page(), at checkpoint.
> 
> I'd expect everything below to be entirely transparent to us.

Ok, the recreation of the VMs with do_mmap_pgoff takes care of the
number of page table leves. It gets automatically upgraded when the
first VMA is mapped that is over the limit.

What is left are the pgstes tables. After you forked the new process
that is used to restart a KVM enabled process you need to call
s390_enable_sie(), preferably before you recreate the VMAs.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.
