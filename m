From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/5] Container Freezer: Add TIF_FREEZE flag to all
	architectures
Date: Mon, 11 Aug 2008 16:53:24 -0700
Message-ID: <20080811235324.279345521__15072.6512926214$1218499025$gmane$org@us.ibm.com>
References: <20080811235323.872291138@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch is the first step in making the refrigerator() available
to all architectures, even for those without power management.

The purpose of such a change is to be able to use the refrigerator()
in a new control group subsystem which will implement a control group
freezer.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Acked-by: Nigel Cunningham <nigel-jrkICu/7yk3k1uMJSBkQmQ@public.gmane.org>
Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/parisc/include/asm/thread_info.h   |    2 ++
 arch/sparc/include/asm/thread_info_32.h |    2 ++
 arch/sparc/include/asm/thread_info_64.h |    2 ++
 include/asm-alpha/thread_info.h         |    2 ++
 include/asm-avr32/thread_info.h         |    1 +
 include/asm-cris/thread_info.h          |    2 ++
 include/asm-h8300/thread_info.h         |    2 ++
 include/asm-m68k/thread_info.h          |    1 +
 include/asm-m68knommu/thread_info.h     |    2 ++
 include/asm-s390/thread_info.h          |    2 ++
 include/asm-um/thread_info.h            |    2 ++
 include/asm-xtensa/thread_info.h        |    2 ++
 12 files changed, 22 insertions(+)

Index: linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_32.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/sparc/include/asm/thread_info_32.h
+++ linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_32.h
@@ -139,6 +139,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
 #define TIF_POLLING_NRFLAG	9	/* true if poll_idle() is polling
 					 * TIF_NEED_RESCHED */
 #define TIF_MEMDIE		10
+#define TIF_FREEZE		11	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
@@ -152,6 +153,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
 #define _TIF_DO_NOTIFY_RESUME_MASK	(_TIF_NOTIFY_RESUME | \
 					 _TIF_SIGPENDING | \
 					 _TIF_RESTORE_SIGMASK)
+#define TIF_FREEZE		(1<<TIF_FREEZE)
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_64.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/sparc/include/asm/thread_info_64.h
+++ linux-2.6.27-rc1-mm1/arch/sparc/include/asm/thread_info_64.h
@@ -237,6 +237,7 @@ register struct thread_info *current_thr
 #define TIF_ABI_PENDING		12
 #define TIF_MEMDIE		13
 #define TIF_POLLING_NRFLAG	14
+#define TIF_FREEZE		15	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
@@ -249,6 +250,7 @@ register struct thread_info *current_thr
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
 #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_USER_WORK_MASK	((0xff << TI_FLAG_WSAVED_SHIFT) | \
 				 _TIF_DO_NOTIFY_RESUME_MASK | \
Index: linux-2.6.27-rc1-mm1/include/asm-alpha/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-alpha/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-alpha/thread_info.h
@@ -74,12 +74,14 @@ register struct thread_info *__current_t
 #define TIF_UAC_SIGBUS		7
 #define TIF_MEMDIE		8
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal */
+#define TIF_FREEZE		16	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 /* Work to do on interrupt/exception return.  */
 #define _TIF_WORK_MASK		(_TIF_SIGPENDING | _TIF_NEED_RESCHED)
Index: linux-2.6.27-rc1-mm1/include/asm-avr32/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-avr32/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-avr32/thread_info.h
@@ -96,6 +96,7 @@ static inline struct thread_info *curren
 #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 #define _TIF_CPU_GOING_TO_SLEEP (1 << TIF_CPU_GOING_TO_SLEEP)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 /* Note: The masks below must never span more than 16 bits! */
 
Index: linux-2.6.27-rc1-mm1/include/asm-cris/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-cris/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-cris/thread_info.h
@@ -88,6 +88,7 @@ struct thread_info {
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
+#define TIF_FREEZE		18	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
@@ -95,6 +96,7 @@ struct thread_info {
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
Index: linux-2.6.27-rc1-mm1/include/asm-h8300/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-h8300/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-h8300/thread_info.h
@@ -89,6 +89,7 @@ static inline struct thread_info *curren
 					   TIF_NEED_RESCHED */
 #define TIF_MEMDIE		4
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
+#define TIF_FREEZE		16	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
@@ -96,6 +97,7 @@ static inline struct thread_info *curren
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 
Index: linux-2.6.27-rc1-mm1/include/asm-m68k/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-m68k/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-m68k/thread_info.h
@@ -52,5 +52,6 @@ struct thread_info {
 #define TIF_DELAYED_TRACE	14	/* single step a syscall */
 #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
 #define TIF_MEMDIE		16
+#define TIF_FREEZE		17	/* thread is freezing for suspend */
 
 #endif	/* _ASM_M68K_THREAD_INFO_H */
Index: linux-2.6.27-rc1-mm1/include/asm-m68knommu/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-m68knommu/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-m68knommu/thread_info.h
@@ -84,12 +84,14 @@ static inline struct thread_info *curren
 #define TIF_POLLING_NRFLAG	3	/* true if poll_idle() is polling
 					   TIF_NEED_RESCHED */
 #define TIF_MEMDIE		4
+#define TIF_FREEZE		16	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 
Index: linux-2.6.27-rc1-mm1/include/asm-s390/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-s390/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-s390/thread_info.h
@@ -98,6 +98,7 @@ static inline struct thread_info *curren
 #define TIF_31BIT		18	/* 32bit process */ 
 #define TIF_MEMDIE		19
 #define TIF_RESTORE_SIGMASK	20	/* restore signal mask in do_signal() */
+#define TIF_FREEZE		21	/* thread is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
@@ -110,6 +111,7 @@ static inline struct thread_info *curren
 #define _TIF_USEDFPU		(1<<TIF_USEDFPU)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_31BIT		(1<<TIF_31BIT)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6.27-rc1-mm1/include/asm-um/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-um/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-um/thread_info.h
@@ -69,6 +69,7 @@ static inline struct thread_info *curren
 #define TIF_MEMDIE	 	5
 #define TIF_SYSCALL_AUDIT	6
 #define TIF_RESTORE_SIGMASK	7
+#define TIF_FREEZE		16	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
@@ -77,5 +78,6 @@ static inline struct thread_info *curren
 #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 #endif
Index: linux-2.6.27-rc1-mm1/include/asm-xtensa/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/include/asm-xtensa/thread_info.h
+++ linux-2.6.27-rc1-mm1/include/asm-xtensa/thread_info.h
@@ -134,6 +134,7 @@ static inline struct thread_info *curren
 #define TIF_MEMDIE		5
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
+#define TIF_FREEZE		17	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
@@ -142,6 +143,7 @@ static inline struct thread_info *curren
 #define _TIF_IRET		(1<<TIF_IRET)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
Index: linux-2.6.27-rc1-mm1/arch/parisc/include/asm/thread_info.h
===================================================================
--- linux-2.6.27-rc1-mm1.orig/arch/parisc/include/asm/thread_info.h
+++ linux-2.6.27-rc1-mm1/arch/parisc/include/asm/thread_info.h
@@ -58,6 +58,7 @@ struct thread_info {
 #define TIF_32BIT               4       /* 32 bit binary */
 #define TIF_MEMDIE		5
 #define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
+#define TIF_FREEZE		7	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
@@ -65,6 +66,7 @@ struct thread_info {
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_32BIT		(1 << TIF_32BIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 #define _TIF_USER_WORK_MASK     (_TIF_SIGPENDING | \
                                  _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)

-- 
