From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH 1/6] Container Freezer: Add TIF_FREEZE flag to all
	architectures
Date: Sat, 2 Aug 2008 00:54:19 +0200
Message-ID: <200808020054.21088.rjw__32301.2796500281$1217631462$gmane$org@sisk.pl>
References: <20080801050659.924495279@us.ibm.com> <4893025D.9090801@fr.ibm.com>
	<1217628325.25300.270.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1217628325.25300.270.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Nigel Cunningham <ncunningham-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Saturday, 2 of August 2008, Matt Helsley wrote:
> 
> On Fri, 2008-08-01 at 14:32 +0200, Cedric Le Goater wrote:
> > Nigel Cunningham wrote:
> > > Hi.
> > > 
> > > On Thu, 2008-07-31 at 22:07 -0700, Matt Helsley wrote:
> > >> This patch is the first step in making the refrigerator() available
> > >> to all architectures, even for those without power management.
> > >>
> > >> The purpose of such a change is to be able to use the refrigerator()
> > >> in a new control group subsystem which will implement a control group
> > >> freezer.
> > > 
> > > Is there a reason for always using 19, rather than just the next
> > > available bit?
> > 
> > At the time I did the patch, it was to be consistent with the other 
> > arches supporting suspend but this can not be true anymore. So we might
> > as well just use the next available bit as you suggest. 
> > 
> > Thanks,
> > 
> > C.
> 
> 	This is a good point.
> 
> 	I did a quick survey of the thread_info*.h headers. Most archs appear
> to use the MSW/LSW to distinguish "pending work-to-be-done" (LSW) vs.
> other flags (MSW). This explains most of the gaps in thread flag
> assignment. In some other cases the bits are allocated based on whether
> the arch asm code uses asm immediate values to test the flag. sparc64 is
> by far the most elaborate and includes some excellent comments to
> explain the situation.
> 
> The gaps in allocated flag bit assignments not explained in
> thread_info*.h comments are:
> 
> 	mips doesn't use bit 0, there's a gap between 4 and 9, and another gap
> between 24 and 31.
> 
> 	m32r has a gap between bit 4 and bit 8.
> 
> 	ia64 has a gap at bit 5.
> 
> 	blackfin doesn't explicitly mention the MSW/LSW distinction but appears
> to follow it.
> 
> 	arm also doesn't mention MSW/LSW but appears consistent with that
> explanation.
> 
> 	avr32 makes the MSW/LSW distinction but this doesn't fully explain
> jumping from bit 8 to bit 30 unless they're allocating numbers in the
> opposite direction within the MSW (highest flag is bit 31).
> 
> 	m68k starts at 6 and the comments don't explain why. At first glance it
> doesn't appear to be because of m68knommu. It also jumps from bit 7 to
> bit 14 without explanation and appears to not follow the MSW/LSW
> convention.
> 
> 	cris has an inexplicable gap between bit 3 and bit 9.
> 
> 	s390 has a gap at bit 1. It appears to follow the MSW/LSW distinction
> but doesn't mention it in a comment.
> 
> 	x86 has a gap at bit 9.
> 
> 	"sparc32" has a gap between 4 and 8.
> 
> So I've modified the flag numbers to follow apparent conventions of each
> arch as best I can tell given the lack of explanation above.
> ------------
> From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Subject: Container Freezer: Add TIF_FREEZE flag to all architectures
> 
> This patch is the first step in making the refrigerator() available
> to all architectures, even for those without power management.
> 
> The purpose of such a change is to be able to use the refrigerator()
> in a new control group subsystem which will implement a control group
> freezer.
> 
> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Acked-by: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
> Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>

> ---
>  arch/parisc/include/asm/thread_info.h   |    2 ++
>  arch/sparc/include/asm/thread_info_32.h |    2 ++
>  arch/sparc/include/asm/thread_info_64.h |    2 ++
>  include/asm-alpha/thread_info.h         |    2 ++
>  include/asm-avr32/thread_info.h         |    1 +
>  include/asm-cris/thread_info.h          |    2 ++
>  include/asm-h8300/thread_info.h         |    2 ++
>  include/asm-m68k/thread_info.h          |    1 +
>  include/asm-m68knommu/thread_info.h     |    2 ++
>  include/asm-s390/thread_info.h          |    2 ++
>  include/asm-um/thread_info.h            |    2 ++
>  include/asm-xtensa/thread_info.h        |    2 ++
>  12 files changed, 22 insertions(+)
> 
> Index: linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_32.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/arch/sparc/include/asm/thread_info_32.h
> +++ linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_32.h
> @@ -139,6 +139,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
>  #define TIF_POLLING_NRFLAG	9	/* true if poll_idle() is polling
>  					 * TIF_NEED_RESCHED */
>  #define TIF_MEMDIE		10
> +#define TIF_FREEZE		11	/* is freezing for suspend */
>  
>  /* as above, but as bit values */
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
> @@ -152,6 +153,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
>  #define _TIF_DO_NOTIFY_RESUME_MASK	(_TIF_NOTIFY_RESUME | \
>  					 _TIF_SIGPENDING | \
>  					 _TIF_RESTORE_SIGMASK)
> +#define TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #endif /* __KERNEL__ */
>  
> Index: linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_64.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/arch/sparc/include/asm/thread_info_64.h
> +++ linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_64.h
> @@ -237,6 +237,7 @@ register struct thread_info *current_thr
>  #define TIF_ABI_PENDING		12
>  #define TIF_MEMDIE		13
>  #define TIF_POLLING_NRFLAG	14
> +#define TIF_FREEZE		15	/* is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
>  #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
> @@ -249,6 +250,7 @@ register struct thread_info *current_thr
>  #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
>  #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #define _TIF_USER_WORK_MASK	((0xff << TI_FLAG_WSAVED_SHIFT) | \
>  				 _TIF_DO_NOTIFY_RESUME_MASK | \
> Index: linux-2.6.27-rc1-mm1/include/asm-alpha/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-alpha/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-alpha/thread_info.h
> @@ -74,12 +74,14 @@ register struct thread_info *__current_t
>  #define TIF_UAC_SIGBUS		7
>  #define TIF_MEMDIE		8
>  #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal */
> +#define TIF_FREEZE		16	/* is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
>  #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
>  #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  /* Work to do on interrupt/exception return.  */
>  #define _TIF_WORK_MASK		(_TIF_SIGPENDING | _TIF_NEED_RESCHED)
> Index: linux-2.6.27-rc1-mm1/include/asm-avr32/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-avr32/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-avr32/thread_info.h
> @@ -96,6 +96,7 @@ static inline struct thread_info *curren
>  #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
>  #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
>  #define _TIF_CPU_GOING_TO_SLEEP (1 << TIF_CPU_GOING_TO_SLEEP)
> +#define _TIF_FREEZE		(1 << TIF_FREEZE)
>  
>  /* Note: The masks below must never span more than 16 bits! */
>  
> Index: linux-2.6.27-rc1-mm1/include/asm-cris/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-cris/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-cris/thread_info.h
> @@ -88,6 +88,7 @@ struct thread_info {
>  #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
>  #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
>  #define TIF_MEMDIE		17
> +#define TIF_FREEZE		18	/* is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
>  #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
> @@ -95,6 +96,7 @@ struct thread_info {
>  #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
>  #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
>  #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
> Index: linux-2.6.27-rc1-mm1/include/asm-h8300/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-h8300/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-h8300/thread_info.h
> @@ -89,6 +89,7 @@ static inline struct thread_info *curren
>  					   TIF_NEED_RESCHED */
>  #define TIF_MEMDIE		4
>  #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
> +#define TIF_FREEZE		16	/* is freezing for suspend */
>  
>  /* as above, but as bit values */
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
> @@ -96,6 +97,7 @@ static inline struct thread_info *curren
>  #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
>  #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
>  
> Index: linux-2.6.27-rc1-mm1/include/asm-m68k/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-m68k/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-m68k/thread_info.h
> @@ -52,5 +52,6 @@ struct thread_info {
>  #define TIF_DELAYED_TRACE	14	/* single step a syscall */
>  #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
>  #define TIF_MEMDIE		16
> +#define TIF_FREEZE		17	/* thread is freezing for suspend */
>  
>  #endif	/* _ASM_M68K_THREAD_INFO_H */
> Index: linux-2.6.27-rc1-mm1/include/asm-m68knommu/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-m68knommu/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-m68knommu/thread_info.h
> @@ -84,12 +84,14 @@ static inline struct thread_info *curren
>  #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
>  					   TIF_NEED_RESCHED */
>  #define TIF_MEMDIE		4
> +#define TIF_FREEZE		16	/* is freezing for suspend */
>  
>  /* as above, but as bit values */
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
>  #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
>  #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
>  
> Index: linux-2.6.27-rc1-mm1/include/asm-s390/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-s390/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-s390/thread_info.h
> @@ -98,6 +98,7 @@ static inline struct thread_info *curren
>  #define TIF_31BIT		18	/* 32bit process */ 
>  #define TIF_MEMDIE		19
>  #define TIF_RESTORE_SIGMASK	20	/* restore signal mask in do_signal() */
> +#define TIF_FREEZE		21	/* thread is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
>  #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
> @@ -110,6 +111,7 @@ static inline struct thread_info *curren
>  #define _TIF_USEDFPU		(1<<TIF_USEDFPU)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
>  #define _TIF_31BIT		(1<<TIF_31BIT)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #endif /* __KERNEL__ */
>  
> Index: linux-2.6.27-rc1-mm1/include/asm-um/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-um/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-um/thread_info.h
> @@ -69,6 +69,7 @@ static inline struct thread_info *curren
>  #define TIF_MEMDIE	 	5
>  #define TIF_SYSCALL_AUDIT	6
>  #define TIF_RESTORE_SIGMASK	7
> +#define TIF_FREEZE		16	/* is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
>  #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
> @@ -77,5 +78,6 @@ static inline struct thread_info *curren
>  #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
>  #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
>  #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
> +#define _TIF_FREEZE		(1 << TIF_FREEZE)
>  
>  #endif
> Index: linux-2.6.27-rc1-mm1/include/asm-xtensa/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/asm-xtensa/thread_info.h
> +++ linux-2.6.27-rc1-mm1/include/asm-xtensa/thread_info.h
> @@ -134,6 +134,7 @@ static inline struct thread_info *curren
>  #define TIF_MEMDIE		5
>  #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
>  #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
> +#define TIF_FREEZE		17	/* is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
>  #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
> @@ -142,6 +143,7 @@ static inline struct thread_info *curren
>  #define _TIF_IRET		(1<<TIF_IRET)
>  #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
>  #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
> +#define _TIF_FREEZE		(1<<TIF_FREEZE)
>  
>  #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
>  #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
> Index: linux-2.6.27-rc1-mm1/arch/parisc/include/asm/thread_info.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/arch/parisc/include/asm/thread_info.h
> +++ linux-2.6.27-rc1-mm1/arch/parisc/include/asm/thread_info.h
> @@ -58,6 +58,7 @@ struct thread_info {
>  #define TIF_32BIT               4       /* 32 bit binary */
>  #define TIF_MEMDIE		5
>  #define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
> +#define TIF_FREEZE		7	/* is freezing for suspend */
>  
>  #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
>  #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
> @@ -65,6 +66,7 @@ struct thread_info {
>  #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
>  #define _TIF_32BIT		(1 << TIF_32BIT)
>  #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
> +#define _TIF_FREEZE		(1 << TIF_FREEZE)
>  
>  #define _TIF_USER_WORK_MASK     (_TIF_SIGPENDING | \
>                                   _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
> 
> 
> 
> 
