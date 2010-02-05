From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] user-cr: add ppc64 eclone wrapper
Date: Fri,  5 Feb 2010 15:00:02 -0600
Message-ID: <1265403602-1083-2-git-send-email-ntl@pobox.com>
References: <1265403602-1083-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265403602-1083-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

---
 Makefile       |    8 +++++
 clone_ppc64.c  |    1 +
 clone_ppc64_.S |   96 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+), 0 deletions(-)
 create mode 100644 clone_ppc64.c
 create mode 100644 clone_ppc64_.S

diff --git a/Makefile b/Makefile
index 35188f9..11db11f 100644
--- a/Makefile
+++ b/Makefile
@@ -45,6 +45,14 @@ endif
 
 # on powerpc, need also assembly file
 ifeq ($(SUBARCH),ppc)
+CFLAGS += -m32
+ASFLAGS += -m32
+restart: clone_$(SUBARCH)_.o
+nsexeccwp: clone_$(SUBARCH)_.o
+endif
+ifeq ($(SUBARCH),ppc64)
+CFLAGS += -m64
+ASFLAGS += -m64
 restart: clone_$(SUBARCH)_.o
 nsexeccwp: clone_$(SUBARCH)_.o
 endif
diff --git a/clone_ppc64.c b/clone_ppc64.c
new file mode 100644
index 0000000..5aec466
--- /dev/null
+++ b/clone_ppc64.c
@@ -0,0 +1 @@
+#include "clone_ppc.c"
diff --git a/clone_ppc64_.S b/clone_ppc64_.S
new file mode 100644
index 0000000..9fa71e7
--- /dev/null
+++ b/clone_ppc64_.S
@@ -0,0 +1,96 @@
+/*
+ *  clone_ppc64_.S: ppc64 support for eclone()
+ *
+ *  Author:	Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/unistd.h>
+#include "powerpc_asm.h"
+
+#ifndef __powerpc64__
+#error This code is 64-bit only!
+#endif
+
+#ifndef __NR_eclone
+#define __NR_eclone     323
+#endif
+
+/* int [r3] eclone(int (*fn)(void *arg) [r3],
+ *                          int flags [r4],
+ *                          void *fn_arg [r5],
+ *                          struct clone_args *args [r6],
+ *                          size_t args_size [r7],
+ *                          pid_t *pids [r8]);
+ * Creates a child task with the pids specified by pids.
+ * Returns to parent only, child execution and exit is handled here.
+ * On error, returns negated errno.  On success, returns the pid of the child
+ * created.
+ */
+
+.text
+	.global __eclone
+	.section	".opd","aw"
+	.align 3
+__eclone:
+	.quad .__eclone,.TOC.@tocbase,0
+	.previous
+	.global .__eclone
+.__eclone:
+	/* Set up parent's stack frame. */
+	stdu	r1,-80(r1)
+
+	/* Save non-volatiles */
+	std	r30,64(r1)
+	std	r31,72(r1)
+
+	/* Save fn and fn_arg across system call */
+	mr	r30,r3
+	mr	r31,r5
+
+	/* Set up arguments for system call. */
+	mr	r3,r4	/* flags */
+	mr	r4,r6	/* clone_args */
+	mr	r5,r7	/* clone_args' size */
+	mr	r6,r8	/* pids */
+
+	/* Do the system call */
+	li	r0,__NR_eclone
+	sc
+
+	/* Parent or child? */
+	cmpdi	cr1,r3,0
+	crandc	4*cr1+eq,4*cr1+eq,4*cr0+so
+	bne	cr1,eclone_parent
+
+	/* Child.  Call fn. */
+	std 	r2,40(r1)	/* save TOC base */
+	ld	r0,0(r30)	/* extract fn pointer from descriptor */
+	ld	r2,8(r30)	/* extract TOC base from descriptor */
+	mtctr	r0
+	mr	r3,r31		/* fn argument */
+	bctrl
+	ld	r2,40(r1)	/* restore TOC base */
+
+	/* Assume result of fn in r3 and exit. */
+	li	r0,__NR_exit
+	sc
+
+eclone_parent:
+	/* Restore non-volatiles. */
+	ld	r31,72(r1)
+	ld	r30,64(r1)
+
+	addi	r1,r1,80
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
1.6.0.6
