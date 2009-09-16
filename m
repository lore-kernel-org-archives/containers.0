From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/4] mktree: initial powerpc support hacks
Date: Wed, 16 Sep 2009 04:27:50 -0500
Message-ID: <1253093271-16357-4-git-send-email-ntl@pobox.com>
References: <1253093271-16357-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253093271-16357-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

---
 clone_ppc32.S |   79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 powerpc_asm.h |   46 +++++++++++++++++++++++++++++++++
 restart.c     |   24 +++++++++++++++++
 3 files changed, 149 insertions(+), 0 deletions(-)
 create mode 100644 clone_ppc32.S
 create mode 100644 powerpc_asm.h

diff --git a/clone_ppc32.S b/clone_ppc32.S
new file mode 100644
index 0000000..e159b19
--- /dev/null
+++ b/clone_ppc32.S
@@ -0,0 +1,79 @@
+#include <asm/unistd.h>
+#include "powerpc_asm.h"
+
+/* int [r3] clone_with_pids(int (*fn)(void *arg) [r3],
+ *                          void *child_stack [r4],
+ *                          int flags [r5],
+ *                          void *arg [r6],
+ *                          void *parent_tid [r7],
+ *                          void *tls [r8],
+ *                          void *child_tid [r9],
+ *                          struct target_pid_set *setp [r10]);
+ * Creates a child task with the pids specified by setp.
+ * Returns to parent only, child execution and exit is handled here.
+ * On error, returns negated errno.  On success, returns the pid of the child
+ * created.
+ */
+
+	.text
+	.globl __clone_with_pids
+__clone_with_pids:
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
+	/* Save fn, stack pointer, flags, and arg across system call. */
+	mr	r28,r3
+	mr	r29,r4
+	mr	r30,r5
+	mr	r31,r6
+
+	/* Set up arguments for system call.  Stack pointer is already in r4. */
+	mr	r3,r5	/* flags */
+	mr	r5,r7	/* parent_tid */
+	mr	r6,r8	/* tls */
+	mr	r7,r9	/* child_tid */
+	mr	r8,r10	/* setp */
+
+	/* Do the system call */
+	li	r0,__NR_clone_with_pids
+	sc
+
+	/* Parent or child? */
+	cmpwi	cr1,r3,0
+	crandc	4*cr1+eq,4*cr1+eq,4*cr0+so
+	bne	cr1,parent
+
+	/* Child. Call fn. */
+	mtctr	r28
+	mr 	r3,r31
+	bctrl
+
+	/* Assume result of fn in r3 and exit. */
+	li	r0,__NR_exit
+	sc
+
+parent:
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
diff --git a/powerpc_asm.h b/powerpc_asm.h
new file mode 100644
index 0000000..58f459f
--- /dev/null
+++ b/powerpc_asm.h
@@ -0,0 +1,46 @@
+#ifndef __POWERPC_ASM_H
+#define _POWERPC_ASM_H
+
+#define	r0	0
+#define	r1	1
+#define	r2	2
+#define	r3	3
+#define	r4	4
+#define	r5	5
+#define	r6	6
+#define	r7	7
+#define	r8	8
+#define	r9	9
+#define	r10	10
+#define	r11	11
+#define	r12	12
+#define	r13	13
+#define	r14	14
+#define	r15	15
+#define	r16	16
+#define	r17	17
+#define	r18	18
+#define	r19	19
+#define	r20	20
+#define	r21	21
+#define	r22	22
+#define	r23	23
+#define	r24	24
+#define	r25	25
+#define	r26	26
+#define	r27	27
+#define	r28	28
+#define	r29	29
+#define	r30	30
+#define	r31	31
+
+#define	cr0	0
+#define	cr1	1
+#define	cr2	2
+#define	cr3	3
+#define	cr4	4
+#define	cr5	5
+#define	cr6	6
+#define	cr7	7
+
+#endif /* _POWERPC_ASM_H */
diff --git a/restart.c b/restart.c
index b93a2e1..499614e 100644
--- a/restart.c
+++ b/restart.c
@@ -1951,6 +1951,30 @@ int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 		return retval;
 }
 
+#elif defined(__powerpc__) && defined(__NR_clone_with_pids)
+
+extern int __clone_with_pids(int (*fn)(void *arg), void *child_stack, int flags,
+			     void *arg, void *parent_tid, void *tls,
+			     void *child_tid, struct target_pid_set *setp);
+
+static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
+			struct target_pid_set *target_pids, void *arg)
+{
+	void *parent_tid = NULL;
+	void *tls = NULL;
+	void *child_tid = NULL;
+	pid_t newpid;
+
+	newpid = __clone_with_pids(fn, child_stack, flags, arg, parent_tid,
+				   tls, child_tid, target_pids);
+
+	if (newpid < 0) {
+		errno = -newpid;
+		return -1;
+	}
+
+	return newpid;
+}
 #else  /* !defined(__NR_clone_with_pids) */
 
 /* on other architectures fallback to regular clone(2) */
-- 
1.6.0.6
