From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 1/5] Container Freezer: Add TIF_FREEZE flag to all
	architectures
Date: Wed, 23 Apr 2008 23:47:57 -0700
Message-ID: <20080424064756.935832298__8749.10822972215$1209019959$gmane$org@us.ibm.com>
References: <20080424064756.643890130@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=cgroup-freezer/cgroup-freezer-add-the-tif-freeze-flag-to-all-archs.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch is the first step in making the refrigerator() available 
to all architectures, even for those without power management. 

The purpose of such a change is to be able to use the refrigerator() 
in a new control group subsystem which will implement a control group
freezer.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/asm-alpha/thread_info.h     |    2 ++
 include/asm-avr32/thread_info.h     |    2 ++
 include/asm-cris/thread_info.h      |    2 ++
 include/asm-h8300/thread_info.h     |    2 ++
 include/asm-m68k/thread_info.h      |    1 +
 include/asm-m68knommu/thread_info.h |    2 ++
 include/asm-parisc/thread_info.h    |    2 ++
 include/asm-s390/thread_info.h      |    2 ++
 include/asm-sparc/thread_info.h     |    2 ++
 include/asm-sparc64/thread_info.h   |    2 ++
 include/asm-um/thread_info.h        |    2 ++
 include/asm-v850/thread_info.h      |    2 ++
 include/asm-xtensa/thread_info.h    |    2 ++
 13 files changed, 25 insertions(+)

Index: linux-2.6.25-mm1/include/asm-alpha/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-alpha/thread_info.h
+++ linux-2.6.25-mm1/include/asm-alpha/thread_info.h
@@ -74,16 +74,18 @@ register struct thread_info *__current_t
 #define TIF_UAC_NOPRINT		5	/* see sysinfo.h */
 #define TIF_UAC_NOFIX		6
 #define TIF_UAC_SIGBUS		7
 #define TIF_MEMDIE		8
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 /* Work to do on interrupt/exception return.  */
 #define _TIF_WORK_MASK		(_TIF_SIGPENDING | _TIF_NEED_RESCHED)
 
 /* Work to do on any return to userspace.  */
Index: linux-2.6.25-mm1/include/asm-avr32/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-avr32/thread_info.h
+++ linux-2.6.25-mm1/include/asm-avr32/thread_info.h
@@ -86,10 +86,11 @@ static inline struct thread_info *curren
 #define TIF_BREAKPOINT		4	/* enter monitor mode on return */
 #define TIF_SINGLE_STEP		5	/* single step in progress */
 #define TIF_MEMDIE		6
 #define TIF_RESTORE_SIGMASK	7	/* restore signal mask in do_signal */
 #define TIF_CPU_GOING_TO_SLEEP	8	/* CPU is entering sleep 0 mode */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 #define TIF_DEBUG		30	/* debugging enabled */
 #define TIF_USERSPACE		31      /* true if FS sets userspace */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
@@ -97,10 +98,11 @@ static inline struct thread_info *curren
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_SINGLE_STEP	(1 << TIF_SINGLE_STEP)
 #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 #define _TIF_CPU_GOING_TO_SLEEP (1 << TIF_CPU_GOING_TO_SLEEP)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 /* Note: The masks below must never span more than 16 bits! */
 
 /* work to do on interrupt/exception return */
 #define _TIF_WORK_MASK				\
Index: linux-2.6.25-mm1/include/asm-cris/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-cris/thread_info.h
+++ linux-2.6.25-mm1/include/asm-cris/thread_info.h
@@ -84,17 +84,19 @@ struct thread_info {
 #define TIF_SIGPENDING		2	/* signal pending */
 #define TIF_NEED_RESCHED	3	/* rescheduling necessary */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
 
 #endif /* __KERNEL__ */
Index: linux-2.6.25-mm1/include/asm-h8300/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-h8300/thread_info.h
+++ linux-2.6.25-mm1/include/asm-h8300/thread_info.h
@@ -90,17 +90,19 @@ static inline struct thread_info *curren
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
 #define TIF_MEMDIE		4
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6.25-mm1/include/asm-m68k/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-m68k/thread_info.h
+++ linux-2.6.25-mm1/include/asm-m68k/thread_info.h
@@ -56,7 +56,8 @@ struct thread_info {
 #define TIF_SIGPENDING		6	/* signal pending */
 #define TIF_NEED_RESCHED	7	/* rescheduling necessary */
 #define TIF_DELAYED_TRACE	14	/* single step a syscall */
 #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
 #define TIF_MEMDIE		16
+#define TIF_FREEZE		19
 
 #endif	/* _ASM_M68K_THREAD_INFO_H */
Index: linux-2.6.25-mm1/include/asm-m68knommu/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-m68knommu/thread_info.h
+++ linux-2.6.25-mm1/include/asm-m68knommu/thread_info.h
@@ -86,16 +86,18 @@ static inline struct thread_info *curren
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
 #define TIF_MEMDIE		4
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6.25-mm1/include/asm-parisc/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-parisc/thread_info.h
+++ linux-2.6.25-mm1/include/asm-parisc/thread_info.h
@@ -60,17 +60,19 @@ struct thread_info {
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_32BIT               4       /* 32 bit binary */
 #define TIF_MEMDIE		5
 #define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_32BIT		(1 << TIF_32BIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 #define _TIF_USER_WORK_MASK     (_TIF_SIGPENDING | \
                                  _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
 
 #endif /* __KERNEL__ */
Index: linux-2.6.25-mm1/include/asm-s390/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-s390/thread_info.h
+++ linux-2.6.25-mm1/include/asm-s390/thread_info.h
@@ -99,10 +99,11 @@ static inline struct thread_info *curren
 #define TIF_POLLING_NRFLAG	17	/* true if poll_idle() is polling 
 					   TIF_NEED_RESCHED */
 #define TIF_31BIT		18	/* 32bit process */ 
 #define TIF_MEMDIE		19
 #define TIF_RESTORE_SIGMASK	20	/* restore signal mask in do_signal() */
+#define TIF_FREEZE		21	/* thread is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
@@ -111,10 +112,11 @@ static inline struct thread_info *curren
 #define _TIF_SINGLE_STEP	(1<<TIF_SINGLE_STEP)
 #define _TIF_MCCK_PENDING	(1<<TIF_MCCK_PENDING)
 #define _TIF_USEDFPU		(1<<TIF_USEDFPU)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_31BIT		(1<<TIF_31BIT)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #endif /* __KERNEL__ */
 
 #define PREEMPT_ACTIVE		0x4000000
 
Index: linux-2.6.25-mm1/include/asm-sparc/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-sparc/thread_info.h
+++ linux-2.6.25-mm1/include/asm-sparc/thread_info.h
@@ -135,17 +135,19 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
 #define TIF_USEDFPU		8	/* FPU was used by this task
 					 * this quantum (SMP) */
 #define TIF_POLLING_NRFLAG	9	/* true if poll_idle() is polling
 					 * TIF_NEED_RESCHED */
 #define TIF_MEMDIE		10
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_USEDFPU		(1<<TIF_USEDFPU)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_THREAD_INFO_H */
Index: linux-2.6.25-mm1/include/asm-sparc64/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-sparc64/thread_info.h
+++ linux-2.6.25-mm1/include/asm-sparc64/thread_info.h
@@ -234,10 +234,11 @@ register struct thread_info *current_thr
  *       an immediate value in instructions such as andcc.
  */
 #define TIF_ABI_PENDING		12
 #define TIF_MEMDIE		13
 #define TIF_POLLING_NRFLAG	14
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_PERFCTR		(1<<TIF_PERFCTR)
@@ -247,10 +248,11 @@ register struct thread_info *current_thr
 #define _TIF_SECCOMP		(1<<TIF_SECCOMP)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_USER_WORK_MASK	((0xff << TI_FLAG_WSAVED_SHIFT) | \
 				 (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK | \
 				  _TIF_NEED_RESCHED | _TIF_PERFCTR))
 
Index: linux-2.6.25-mm1/include/asm-um/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-um/thread_info.h
+++ linux-2.6.25-mm1/include/asm-um/thread_info.h
@@ -81,15 +81,17 @@ static inline struct thread_info *curren
 					 */
 #define TIF_RESTART_BLOCK 	4
 #define TIF_MEMDIE	 	5
 #define TIF_SYSCALL_AUDIT	6
 #define TIF_RESTORE_SIGMASK	7
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1 << TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG     (1 << TIF_POLLING_NRFLAG)
 #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 #endif
Index: linux-2.6.25-mm1/include/asm-v850/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-v850/thread_info.h
+++ linux-2.6.25-mm1/include/asm-v850/thread_info.h
@@ -80,16 +80,18 @@ struct thread_info {
 #define TIF_SIGPENDING		1	/* signal pending */
 #define TIF_NEED_RESCHED	2	/* rescheduling necessary */
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
 #define TIF_MEMDIE		4
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 
 /* Size of kernel stack for each process.  */
 #define THREAD_SIZE		0x2000
 
Index: linux-2.6.25-mm1/include/asm-xtensa/thread_info.h
===================================================================
--- linux-2.6.25-mm1.orig/include/asm-xtensa/thread_info.h
+++ linux-2.6.25-mm1/include/asm-xtensa/thread_info.h
@@ -136,18 +136,20 @@ static inline struct thread_info *curren
 #define TIF_SINGLESTEP		3	/* restore singlestep on return to user mode */
 #define TIF_IRET		4	/* return with iret */
 #define TIF_MEMDIE		5
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_SINGLESTEP		(1<<TIF_SINGLESTEP)
 #define _TIF_IRET		(1<<TIF_IRET)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
 
 /*

-- 
