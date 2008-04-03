From: matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC PATCH 1/4] Container Freezer: Add TIF_FREEZE flag to all
	architectures
Date: Thu, 03 Apr 2008 14:03:17 -0700
Message-ID: <20080403210316.659937801__555.60515397719$1207256809$gmane$org@us.ibm.com>
References: <20080403210316.397506379@us.ibm.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch is the first step in making the refrigerator() available 
to all architectures, even for those without power management. 

The purpose of such a change is to be able to use the refrigerator() 
in a new control group subsystem which will implement a control group
freezer.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
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

Index: 2.6.25-rc3-mm1/include/asm-alpha/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-alpha/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-alpha/thread_info.h
@@ -76,12 +76,14 @@ register struct thread_info *__current_t
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
Index: 2.6.25-rc3-mm1/include/asm-avr32/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-avr32/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-avr32/thread_info.h
@@ -88,6 +88,7 @@ static inline struct thread_info *curren
 #define TIF_MEMDIE		6
 #define TIF_RESTORE_SIGMASK	7	/* restore signal mask in do_signal */
 #define TIF_CPU_GOING_TO_SLEEP	8	/* CPU is entering sleep 0 mode */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 #define TIF_DEBUG		30	/* debugging enabled */
 #define TIF_USERSPACE		31      /* true if FS sets userspace */
 
@@ -99,6 +100,7 @@ static inline struct thread_info *curren
 #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
 #define _TIF_CPU_GOING_TO_SLEEP (1 << TIF_CPU_GOING_TO_SLEEP)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 /* Note: The masks below must never span more than 16 bits! */
 
Index: 2.6.25-rc3-mm1/include/asm-cris/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-cris/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-cris/thread_info.h
@@ -86,6 +86,7 @@ struct thread_info {
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
 #define TIF_MEMDIE		17
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_NOTIFY_RESUME	(1<<TIF_NOTIFY_RESUME)
@@ -93,6 +94,7 @@ struct thread_info {
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */
Index: 2.6.25-rc3-mm1/include/asm-h8300/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-h8300/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-h8300/thread_info.h
@@ -92,6 +92,7 @@ static inline struct thread_info *curren
 					   TIF_NEED_RESCHED */
 #define TIF_MEMDIE		4
 #define TIF_RESTORE_SIGMASK	5	/* restore signal mask in do_signal() */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
@@ -99,6 +100,7 @@ static inline struct thread_info *curren
 #define _TIF_NEED_RESCHED	(1<<TIF_NEED_RESCHED)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 
Index: 2.6.25-rc3-mm1/include/asm-m68k/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-m68k/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-m68k/thread_info.h
@@ -58,5 +58,6 @@ struct thread_info {
 #define TIF_DELAYED_TRACE	14	/* single step a syscall */
 #define TIF_SYSCALL_TRACE	15	/* syscall trace active */
 #define TIF_MEMDIE		16
+#define TIF_FREEZE		19
 
 #endif	/* _ASM_M68K_THREAD_INFO_H */
Index: 2.6.25-rc3-mm1/include/asm-m68knommu/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-m68knommu/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-m68knommu/thread_info.h
@@ -88,12 +88,14 @@ static inline struct thread_info *curren
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
 
Index: 2.6.25-rc3-mm1/include/asm-parisc/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-parisc/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-parisc/thread_info.h
@@ -62,6 +62,7 @@ struct thread_info {
 #define TIF_32BIT               4       /* 32 bit binary */
 #define TIF_MEMDIE		5
 #define TIF_RESTORE_SIGMASK	6	/* restore saved signal mask */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
@@ -69,6 +70,7 @@ struct thread_info {
 #define _TIF_POLLING_NRFLAG	(1 << TIF_POLLING_NRFLAG)
 #define _TIF_32BIT		(1 << TIF_32BIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 #define _TIF_USER_WORK_MASK     (_TIF_SIGPENDING | \
                                  _TIF_NEED_RESCHED | _TIF_RESTORE_SIGMASK)
Index: 2.6.25-rc3-mm1/include/asm-s390/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-s390/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-s390/thread_info.h
@@ -101,6 +101,7 @@ static inline struct thread_info *curren
 					   TIF_NEED_RESCHED */
 #define TIF_31BIT		18	/* 32bit process */ 
 #define TIF_MEMDIE		19
+#define TIF_FREEZE		20	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
@@ -113,6 +114,7 @@ static inline struct thread_info *curren
 #define _TIF_USEDFPU		(1<<TIF_USEDFPU)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_31BIT		(1<<TIF_31BIT)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #endif /* __KERNEL__ */
 
Index: 2.6.25-rc3-mm1/include/asm-sparc/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-sparc/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-sparc/thread_info.h
@@ -137,6 +137,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
 #define TIF_POLLING_NRFLAG	9	/* true if poll_idle() is polling
 					 * TIF_NEED_RESCHED */
 #define TIF_MEMDIE		10
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 /* as above, but as bit values */
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
@@ -145,6 +146,7 @@ BTFIXUPDEF_CALL(void, free_thread_info, 
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_USEDFPU		(1<<TIF_USEDFPU)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #endif /* __KERNEL__ */
 
Index: 2.6.25-rc3-mm1/include/asm-sparc64/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-sparc64/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-sparc64/thread_info.h
@@ -236,6 +236,7 @@ register struct thread_info *current_thr
 #define TIF_ABI_PENDING		12
 #define TIF_MEMDIE		13
 #define TIF_POLLING_NRFLAG	14
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
@@ -249,6 +250,7 @@ register struct thread_info *current_thr
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_USER_WORK_MASK	((0xff << TI_FLAG_WSAVED_SHIFT) | \
 				 (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK | \
Index: 2.6.25-rc3-mm1/include/asm-um/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-um/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-um/thread_info.h
@@ -83,6 +83,7 @@ static inline struct thread_info *curren
 #define TIF_MEMDIE	 	5
 #define TIF_SYSCALL_AUDIT	6
 #define TIF_RESTORE_SIGMASK	7
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1 << TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1 << TIF_SIGPENDING)
@@ -91,5 +92,6 @@ static inline struct thread_info *curren
 #define _TIF_MEMDIE		(1 << TIF_MEMDIE)
 #define _TIF_SYSCALL_AUDIT	(1 << TIF_SYSCALL_AUDIT)
 #define _TIF_RESTORE_SIGMASK	(1 << TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1 << TIF_FREEZE)
 
 #endif
Index: 2.6.25-rc3-mm1/include/asm-v850/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-v850/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-v850/thread_info.h
@@ -82,12 +82,14 @@ struct thread_info {
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
Index: 2.6.25-rc3-mm1/include/asm-xtensa/thread_info.h
===================================================================
--- 2.6.25-rc3-mm1.orig/include/asm-xtensa/thread_info.h
+++ 2.6.25-rc3-mm1/include/asm-xtensa/thread_info.h
@@ -138,6 +138,7 @@ static inline struct thread_info *curren
 #define TIF_MEMDIE		5
 #define TIF_RESTORE_SIGMASK	6	/* restore signal mask in do_signal() */
 #define TIF_POLLING_NRFLAG	16	/* true if poll_idle() is polling TIF_NEED_RESCHED */
+#define TIF_FREEZE		19	/* is freezing for suspend */
 
 #define _TIF_SYSCALL_TRACE	(1<<TIF_SYSCALL_TRACE)
 #define _TIF_SIGPENDING		(1<<TIF_SIGPENDING)
@@ -146,6 +147,7 @@ static inline struct thread_info *curren
 #define _TIF_IRET		(1<<TIF_IRET)
 #define _TIF_POLLING_NRFLAG	(1<<TIF_POLLING_NRFLAG)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
+#define _TIF_FREEZE		(1<<TIF_FREEZE)
 
 #define _TIF_WORK_MASK		0x0000FFFE	/* work to do on interrupt/exception return */
 #define _TIF_ALLWORK_MASK	0x0000FFFF	/* work to do on any return to u-space */

-- 

-- 
