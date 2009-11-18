From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 9/9] user-cr: remove powerpc clone_with_pids
Date: Tue, 17 Nov 2009 18:55:46 -0600
Message-ID: <1258505746-31182-10-git-send-email-ntl@pobox.com>
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

Remove C and asm support code for old clone_with_pids interface and
update comments accordingly.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 clone_ppc.c  |   37 +--------------------------
 clone_ppc_.S |   79 +---------------------------------------------------------
 2 files changed, 2 insertions(+), 114 deletions(-)

diff --git a/clone_ppc.c b/clone_ppc.c
index c9eee8b..47b8290 100644
--- a/clone_ppc.c
+++ b/clone_ppc.c
@@ -16,46 +16,11 @@
 #include <sys/syscall.h>
 #include <asm/unistd.h>
 
-struct target_pid_set;
-
-extern int __clone_with_pids(int (*fn)(void *arg),
-			     void *child_stack ,
-			     int flags,
-			     void *arg,
-			     void *parent_tid,
-			     void *tls,
-			     void *child_tid,
-			     struct target_pid_set *setp);
-
 /*
- * libc doesn't support clone_with_pid() yet...
+ * libc doesn't support eclone() yet...
  * below is arch-dependent code to use the syscall
  */
 #include <linux/checkpoint.h>
-#if defined(__NR_clone_with_pids)
-
-/* (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html) */
-
-int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
-			   struct target_pid_set *target_pids, void *arg)
-{
-	void *parent_tid = NULL;
-	void *tls = NULL;
-	void *child_tid = NULL;
-	pid_t newpid;
-
-	newpid = __clone_with_pids(fn, child_stack, flags, arg, parent_tid,
-				   tls, child_tid, target_pids);
-
-	if (newpid < 0) {
-		errno = -newpid;
-		return -1;
-	}
-
-	return newpid;
-}
-
-#endif
 
 #include "eclone.h"
 
diff --git a/clone_ppc_.S b/clone_ppc_.S
index fa89c31..b736e13 100644
--- a/clone_ppc_.S
+++ b/clone_ppc_.S
@@ -1,5 +1,5 @@
 /*
- *  clone_ppc_.S: support for clone_with_pid() on powerpc (32 bit)
+ *  clone_ppc_.S: ppc32 support for eclone()
  *
  *  Author:	Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
  *
@@ -11,83 +11,6 @@
 #include <asm/unistd.h>
 #include "powerpc_asm.h"
 
-/* int [r3] clone_with_pids(int (*fn)(void *arg) [r3],
- *                          void *child_stack [r4],
- *                          int flags [r5],
- *                          void *arg [r6],
- *                          void *parent_tid [r7],
- *                          void *tls [r8],
- *                          void *child_tid [r9],
- *                          struct target_pid_set *setp [r10]);
- * Creates a child task with the pids specified by setp.
- * Returns to parent only, child execution and exit is handled here.
- * On error, returns negated errno.  On success, returns the pid of the child
- * created.
- */
-
-.text
-.globl __clone_with_pids
-__clone_with_pids:
-
-/* No argument validation. */
-
-/* Set up parent's stack frame. */
-stwu	r1,-32(r1)
-
-	/* Save non-volatiles (r28-r31) which we plan to use. */
-	stmw	r28,16(r1)
-
-	/* Set up child's stack frame. */
-	clrrwi	r4,r4,4
-	li	r0,0
-	stw	r0,-16(r4)
-
-	/* Save fn, stack pointer, flags, and arg across system call. */
-	mr	r28,r3
-	mr	r29,r4
-	mr	r30,r5
-	mr	r31,r6
-
-	/* Set up arguments for system call.  Stack pointer is already in r4. */
-	mr	r3,r5	/* flags */
-	mr	r5,r7	/* parent_tid */
-	mr	r6,r8	/* tls */
-	mr	r7,r9	/* child_tid */
-	mr	r8,r10	/* setp */
-
-	/* Do the system call */
-	li	r0,__NR_clone_with_pids
-	sc
-
-	/* Parent or child? */
-	cmpwi	cr1,r3,0
-	crandc	4*cr1+eq,4*cr1+eq,4*cr0+so
-	bne	cr1,parent
-
-	/* Child. Call fn. */
-	mtctr	r28
-	mr 	r3,r31
-	bctrl
-
-	/* Assume result of fn in r3 and exit. */
-	li	r0,__NR_exit
-	sc
-
-parent:
-	/* Restore non-volatiles. */
-	lmw	r28,16(r1)
-
-	addi	r1,r1,32
-
-	/* Return to caller on success. */
-	bnslr
-
-	/* Handle error.  Negate the return value to signal an error
-	 * to the caller, which must set errno.
-	 */
-	neg	r3,r3
-	blr
-
 #ifndef __NR_eclone
 #define __NR_eclone     323
 #endif
-- 
1.6.2.5
