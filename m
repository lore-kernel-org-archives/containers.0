From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/9] user-cr: ppc32 eclone wrapper
Date: Tue, 17 Nov 2009 18:55:41 -0600
Message-ID: <1258505746-31182-5-git-send-email-ntl@pobox.com>
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

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 clone_ppc.c  |   43 ++++++++++++++++++++++++++++++++
 clone_ppc_.S |   77 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+), 0 deletions(-)

diff --git a/clone_ppc.c b/clone_ppc.c
index 49797fd..c9eee8b 100644
--- a/clone_ppc.c
+++ b/clone_ppc.c
@@ -56,3 +56,46 @@ int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 }
 
 #endif
+
+#include "eclone.h"
+
+extern int __eclone(int (*fn)(void *arg),
+		    void *child_sp,
+		    int flags,
+		    void *fn_arg,
+		    struct clone_args *args,
+		    size_t args_size,
+		    pid_t *pids);
+
+int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
+	   struct clone_args *clone_args, pid_t *pids)
+{
+	struct clone_args my_args;
+	unsigned long child_sp;
+	int newpid;
+
+	if (clone_args->child_stack)
+		child_sp = clone_args->child_stack +
+			clone_args->child_stack_size - 1;
+	else
+		child_sp = 0;
+
+	my_args = *clone_args;
+	my_args.child_stack = child_sp;
+	my_args.child_stack_size = 0;
+
+	newpid = __eclone(fn,
+			  (void *)child_sp,
+			  clone_flags_low,
+			  fn_arg,
+			  &my_args,
+			  sizeof(my_args),
+			  pids);
+
+	if (newpid < 0) {
+		errno = -newpid;
+		newpid = -1;
+	}
+
+	return newpid;
+}
diff --git a/clone_ppc_.S b/clone_ppc_.S
index cb3e053..fa89c31 100644
--- a/clone_ppc_.S
+++ b/clone_ppc_.S
@@ -88,3 +88,80 @@ parent:
 	neg	r3,r3
 	blr
 
+#ifndef __NR_eclone
+#define __NR_eclone     323
+#endif
+
+/* int [r3] eclone(int (*fn)(void *arg) [r3],
+ *                          void *child_sp [r4],
+ *                          int flags [r5],
+ *                          void *fn_arg [r6],
+ *                          struct clone_args *args [r7],
+ *                          size_t args_size [r8],
+ *                          pid_t *pids [r9]);
+ * Creates a child task with the pids specified by pids.
+ * Returns to parent only, child execution and exit is handled here.
+ * On error, returns negated errno.  On success, returns the pid of the child
+ * created.
+ */
+
+.globl __eclone
+__eclone:
+
+	/* No argument validation. */
+
+	/* Set up parent's stack frame. */
+	stwu	r1,-32(r1)
+
+	/* Save non-volatiles (r28-r31) which we plan to use. */
+	stmw	r28,16(r1)
+
+	/* Set up child's stack frame. */
+	clrrwi	r4,r4,4
+	li	r0,0
+	stw	r0,-16(r4)
+
+	/* Save fn, stack pointer, flags, and fn_arg across system call. */
+	mr	r28,r3
+	mr	r29,r4
+	mr	r30,r5
+	mr	r31,r6
+
+	/* Set up arguments for system call. */
+	mr	r3,r5	/* flags */
+	mr	r4,r7	/* clone_args */
+	mr	r5,r8	/* clone_args' size */
+	mr	r6,r9	/* pids */
+
+	/* Do the system call */
+	li	r0,__NR_eclone
+	sc
+
+	/* Parent or child? */
+	cmpwi	cr1,r3,0
+	crandc	4*cr1+eq,4*cr1+eq,4*cr0+so
+	bne	cr1,eclone_parent
+
+	/* Child. Call fn. */
+	mtctr	r28
+	mr	r3,r31
+	bctrl
+
+	/* Assume result of fn in r3 and exit. */
+	li	r0,__NR_exit
+	sc
+
+eclone_parent:
+	/* Restore non-volatiles. */
+	lmw	r28,16(r1)
+
+	addi	r1,r1,32
+
+	/* Return to caller on success. */
+	bnslr
+
+	/* Handle error.  Negate the return value to signal an error
+	 * to the caller, which must set errno.
+	 */
+	neg	r3,r3
+	blr
-- 
1.6.2.5
