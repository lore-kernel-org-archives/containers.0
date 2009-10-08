From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fix up headers so we can munge them for use by userspace.
Date: Wed, 7 Oct 2009 18:06:14 -0700
Message-ID: <20091008010614.GF18101@count0.beaverton.ibm.com>
References: <1254553859-481-1-git-send-email-matthltc@us.ibm.com>
	<20091006022027.GA31628@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091006022027.GA31628-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Oct 05, 2009 at 09:20:27PM -0500, Serge E. Hallyn wrote:
> I'm sorry, I'm really pretty ignorant when it comes to userspace includes.

Me too. The shallow similarities in kernel/userspace header organization have,
in the past, inspired plenty of bad assumptions on my part.

> Can you give a little more explanation as to:
> 	1. why we don't need sys/user.h, and why it was included originally?

sys/user.h includes definitions for register structs/array lengths.

The comment above the include says:
/* i387 structure seen from kernel/userspace */

but the checkpoint headers do not re-use existing register structs/array
lengths from sys/user.h since those same definitions are not used
in the kernel.

Similarly, s390 does not re-use existing register structs/array lengths
from sys/user.h.

Honestly, I don't know why they were included originally when none of
these structs/array lengths were used.

> 	2. why we need sys/types.h first?  I don't see that mentioned in
> 		the linux/types.h.

Maybe I was wrong -- I can't seem to reproduce any build errors by
re-ordering those two.

> 	3. how much of this will be distro-dependent?

Not much. I think since we're talking about headers it's more about glibc
and kernel versions than distros -- I don't think SLES organizes its
glibc headers differently than RHEL or debian. Are you aware of any
distro differences that aren't just due to different upstream versions?

I've been building x86-32 on Fedora 10 and Ubuntu Jaunty. From time to
time I've also been testing and/or looking at headers from RHEL for s390 and
ppc. If anything I'm seeing "older" headers which I would expect to have
fewer of the required definitions and hence more of the problems related to
glibc headers.

> Don't read this as questioning their correctness, just as my curiosity.

Sure. They are good questions, and even questions about correctness
are welcome.

Cheers,
	-Matt Helsley

> 
> thanks,
> -serge
> 
> Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  arch/s390/include/asm/checkpoint_hdr.h |    7 +++++--
> >  arch/x86/include/asm/checkpoint_hdr.h  |    2 --
> >  include/linux/checkpoint_hdr.h         |    4 ++++
> >  3 files changed, 9 insertions(+), 4 deletions(-)
> > 
> > diff --git a/arch/s390/include/asm/checkpoint_hdr.h b/arch/s390/include/asm/checkpoint_hdr.h
> > index b6ea8ce..bc9f624 100644
> > --- a/arch/s390/include/asm/checkpoint_hdr.h
> > +++ b/arch/s390/include/asm/checkpoint_hdr.h
> > @@ -19,8 +19,6 @@
> > 
> >  #ifdef __KERNEL__
> >  #include <asm/processor.h>
> > -#else
> > -#include <sys/user.h>
> >  #endif
> > 
> >  #ifdef CONFIG_64BIT
> > @@ -34,7 +32,12 @@
> >   * NUM_FPRS defined in <asm/ptrace.h> to be 16
> >   * NUM_APRS defined in <asm/ptrace.h> to be 16
> >   * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
> > + *              but is not yet in glibc headers.
> >   */
> > +#ifndef NUM_CR_WORDS
> > +#define NUM_CR_WORDS 3
> > +#endif
> > +
> >  struct ckpt_hdr_cpu {
> >  	struct ckpt_hdr h;
> >  	__u64 args[1];
> > diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
> > index 7a24de5..282bd31 100644
> > --- a/arch/x86/include/asm/checkpoint_hdr.h
> > +++ b/arch/x86/include/asm/checkpoint_hdr.h
> > @@ -34,8 +34,6 @@
> >  /* i387 structure seen from kernel/userspace */
> >  #ifdef __KERNEL__
> >  #include <asm/processor.h>
> > -#else
> > -#include <sys/user.h>
> >  #endif
> > 
> >  #ifdef CONFIG_X86_32
> > diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> > index f8bd4e1..b318cee 100644
> > --- a/include/linux/checkpoint_hdr.h
> > +++ b/include/linux/checkpoint_hdr.h
> > @@ -10,6 +10,10 @@
> >   *  distribution for more details.
> >   */
> > 
> > +#ifndef __KERNEL__
> > +/* In userspace sys/types.h must be included before linux/types.h */
> > +#include <sys/types.h>
> > +#endif
> >  #include <linux/types.h>
> > 
> >  #ifdef __KERNEL__
> > -- 
> > 1.5.6.3
> > 
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
