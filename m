From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 7/9] user-cr: remove x86_32 clone_with_pids
Date: Tue, 17 Nov 2009 18:55:44 -0600
Message-ID: <1258505746-31182-8-git-send-email-ntl@pobox.com>
References: <1258505746-31182-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258505746-31182-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Oren-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Remove support code for old clone_with_pids interface and update
comments accordingly.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 clone_x86_32.c |   64 +------------------------------------------------------
 1 files changed, 2 insertions(+), 62 deletions(-)

diff --git a/clone_x86_32.c b/clone_x86_32.c
index 61b593c..6f1d891 100644
--- a/clone_x86_32.c
+++ b/clone_x86_32.c
@@ -1,5 +1,5 @@
 /*
- *  clone_x86_32.c: support for clone_with_pid() on x86_32
+ *  clone_x86_32.c: support for eclone() on x86_32
  *
  *  Copyright (C) Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
  *
@@ -17,70 +17,10 @@
 #include <asm/unistd.h>
 
 /*
- * libc doesn't support clone_with_pid() yet...
+ * libc doesn't support eclone() yet...
  * below is arch-dependent code to use the syscall
  */
 #include <linux/checkpoint.h>
-#if defined(__NR_clone_with_pids)
-
-/* this really belongs to some kernel header ! */
-struct pid_set {
-	int num_pids;
-	pid_t *pids;
-};
-
-/* (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html) */
-int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
-		    struct pid_set *target_pids, void *arg)
-{
-	long retval;
-	void **newstack;
-
-	/*
-	 * Set up the stack for child:
-	 *  - the (void *) arg will be the argument for the child function
-	 *  - the fn pointer will be loaded into ebx after the clone
-	 */
-	newstack = (void **) child_stack;
-	*--newstack = arg;
-	*--newstack = fn;
-
-	__asm__  __volatile__(
-		 "movl %0, %%ebx\n\t"		/* flags -> 1st (ebx) */
-		 "movl %1, %%ecx\n\t"		/* newstack -> 2nd (ecx)*/
-		 "xorl %%edi, %%edi\n\t"	/* 0 -> 3rd (edi) */
-		 "xorl %%edx, %%edx\n\t"	/* 0 -> 4th (edx) */
-		 "pushl %%ebp\n\t"		/* save value of ebp */
-		 "movl %2, %%ebp\n\t"		/* flags -> 6th (ebp) */
-		:
-		:"b" (flags),
-		 "c" (newstack),
-		 "r" (target_pids)
-		);
-
-	__asm__ __volatile__(
-		 "int $0x80\n\t"	/* Linux/i386 system call */
-		 "testl %0,%0\n\t"	/* check return value */
-		 "jne 1f\n\t"		/* jump if parent */
-		 "popl %%ebx\n\t"	/* get subthread function */
-		 "call *%%ebx\n\t"	/* start subthread function */
-		 "movl %2,%0\n\t"
-		 "int $0x80\n"		/* exit system call: exit subthread */
-		 "1:\n\t"
-		 "popl %%ebp\t"		/* restore parent's ebp */
-		:"=a" (retval)
-		:"0" (__NR_clone_with_pids), "i" (__NR_exit)
-		:"ebx", "ecx"
-		);
-
-	if (retval < 0) {
-		errno = -retval;
-		retval = -1;
-	}
-	return retval;
-}
-
-#endif
 
 #include "eclone.h"
 
-- 
1.6.2.5
