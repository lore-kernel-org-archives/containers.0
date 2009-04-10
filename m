From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 09/30] x86_64: ifdef out struct thread_struct::ip
Date: Fri, 10 Apr 2009 11:20:00 +0200
Message-ID: <20090410092000.GG17962__35357.9879775227$1239355571$gmane$org@elte.hu>
References: <20090410023522.GJ27788@x200.localdomain>
	<20090410035328.GB29496@us.ibm.com>
	<1239336639.3036.20.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239336639.3036.20.camel-6Ww87KsxWewAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


* Jaswinder Singh Rajput <jaswinder-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> On Thu, 2009-04-09 at 20:53 -0700, Matt Helsley wrote:
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
> > Do these make struct thread_struct behave better in cachelines (smaller,
> > less aliasing)? Can we really fit more in the slab du jour?
> > 
> > Otherwise it seems like we're littering these structs with #ifdefs
> > and not really saving anything. If these #ifdefs don't save any space why not 
> > just put in a comment:
> > 
> > >  	unsigned long		ip; /* Used only on i386 */
> > 
> > Or maybe even:
> > 
> > 	union {
> > 	  	unsigned long		ip; /* Used only on i386 */
> > 	  	unsigned long		fs; /* Used only on x86_64 */
> > 	};
> > 
> 
> Can we do it like this:
>   	unsigned long		ip_fs; /* ip: i386, fs: x86_64 */
> 
> I am using same variable for both cases, or we can use some better 
> name than ip_fs. I am assuming either it is i386 or x86_64 machine 
> ;-)

This is the least clean variant amongst all the suggestions.

	Ingo
