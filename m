From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 09/30] x86_64: ifdef out struct thread_struct::ip
Date: Fri, 10 Apr 2009 11:47:38 +0200
Message-ID: <20090410094738.GA11770__13401.8162069426$1239357093$gmane$org@elte.hu>
References: <20090410023522.GJ27788@x200.localdomain>
	<20090410035328.GB29496@us.ibm.com>
	<20090410091931.GF17962@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410091931.GF17962-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


* Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org> wrote:

> 
> * Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > On Fri, Apr 10, 2009 at 06:35:22AM +0400, Alexey Dobriyan wrote:
> > > struct thread_struct::ip isn't used on x86_64, struct pt_regs::ip is used
> > > instead. 
> > > 
> > > kgdb should be reading 0, but I can't check it.
> > > 
> > > Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > ---
> > > 
> > >  arch/x86/include/asm/processor.h |    2 ++
> > >  arch/x86/kernel/kgdb.c           |    2 +-
> > >  2 files changed, 3 insertions(+), 1 deletion(-)
> > > 
> > > --- a/arch/x86/include/asm/processor.h
> > > +++ b/arch/x86/include/asm/processor.h
> > > @@ -421,7 +421,9 @@ struct thread_struct {
> > >  	unsigned short		fsindex;
> > >  	unsigned short		gsindex;
> > >  #endif
> > > +#ifdef CONFIG_X86_32
> > >  	unsigned long		ip;
> > > +#endif
> > >  #ifdef CONFIG_X86_64
> > >  	unsigned long		fs;
> > >  #endif
> > 
> > Do these make struct thread_struct behave better in cachelines 
> > (smaller, less aliasing)? Can we really fit more in the slab du 
> > jour?
> > 
> > Otherwise it seems like we're littering these structs with #ifdefs 
> > and not really saving anything. [...]
> 
> Removing fields always saves memory (even if it does not show up 
> currently due to allocators cache-aligning sizes).

I mean: we always try to consider structure size reductions as if 
they saved real memory, even if they dont do so in the current 
layout and allocation patterns.

In reality only every 8th 8-byte reduction will result in a true 
64-byte cacheline reduction - but still we have to continue small 
reductions otherwise we wont ever get to the larger reductions in 
the first place.

I.e. Alexey's patch shows a real item worth checking, regardless of 
the current size and alignment scenario.

	Ingo
