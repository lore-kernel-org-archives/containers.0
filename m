From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/9] user-cr: remove s390 clone_with_pids
Date: Tue, 17 Nov 2009 18:55:45 -0600
Message-ID: <1258505746-31182-9-git-send-email-ntl@pobox.com>
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
 clone_s390x.c |   51 ++-------------------------------------------------
 1 files changed, 2 insertions(+), 49 deletions(-)

diff --git a/clone_s390x.c b/clone_s390x.c
index 5ed6f15..af3d41f 100644
--- a/clone_s390x.c
+++ b/clone_s390x.c
@@ -1,5 +1,5 @@
 /*
- *  clone_s390.c: support for clone_with_pid() on s390x (64 bit)
+ *  clone_s390.c: support for eclone() on s390x (64 bit)
  *
  *  Copyright (C) IBM Corporation
  *
@@ -19,57 +19,10 @@
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
-
-#define do_clone_with_pids(stack, flags, ptid, ctid, setp) ({ \
-	register unsigned long int __r2 asm ("2") = (unsigned long int)(stack);\
-	register unsigned long int __r3 asm ("3") = (unsigned long int)(flags);\
-	register unsigned long int __r4 asm ("4") = (unsigned long int)(ptid); \
-	register unsigned long int __r5 asm ("5") = (unsigned long int)(ctid); \
-	register unsigned long int __r6 asm ("6") = (unsigned long int)(NULL); \
-	register unsigned long int __r7 asm ("7") = (unsigned long int)(setp); \
-	register unsigned long int __result asm ("2"); \
-	__asm__ __volatile__( \
-		" lghi %%r1,%7\n" \
-		" svc 0\n" \
-		: "=d" (__result) \
-		: "0" (__r2), "d" (__r3), \
-		  "d" (__r4), "d" (__r5), "d" (__r6), "d" (__r7), \
-		  "i" (__NR_clone_with_pids) \
-		: "1", "cc", "memory" \
-	); \
-		__result; \
-	})
-
-int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
-			struct pid_set *target_pids, void *arg)
-{
-	long retval;
-	retval = do_clone_with_pids(child_stack, flags, NULL, NULL,
-				    target_pids);
-
-	if (retval < 0) {
-		errno = -retval;
-		return -1;
-	} else if (retval == 0) {
-		return fn(arg);
-	} else
-		return retval;
-}
-
-#endif  /* !defined(__NR_clone_with_pids) */
 
 #include "eclone.h"
 
-- 
1.6.2.5
