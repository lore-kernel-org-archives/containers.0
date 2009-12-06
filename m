From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] user-cr: eclone x86-64 wrapper
Date: Sun,  6 Dec 2009 15:31:08 -0500
Message-ID: <1260131469-2917-3-git-send-email-orenl@cs.columbia.edu>
References: <1260131469-2917-1-git-send-email-orenl@cs.columbia.edu>
	<1260131469-2917-2-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1260131469-2917-2-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 clone_x86_64.c |   88 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)
 create mode 100644 clone_x86_64.c

diff --git a/clone_x86_64.c b/clone_x86_64.c
new file mode 100644
index 0000000..d6d7e6f
--- /dev/null
+++ b/clone_x86_64.c
@@ -0,0 +1,88 @@
+/*
+ *  clone_x86_64.c: support for eclone() on x86_64
+ *
+ *  Copyright (C) Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
+ *  Copyright (C) Dave Hansen <daveh-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define _GNU_SOURCE
+
+#include <unistd.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/syscall.h>
+#include <asm/unistd.h>
+
+/*
+ * libc doesn't support eclone() yet...
+ * below is arch-dependent code to use the syscall
+ */
+#include <linux/checkpoint.h>
+
+#include "eclone.h"
+
+#ifndef __NR_eclone
+#define __NR_eclone 299
+#endif
+
+int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
+	   struct clone_args *clone_args, pid_t *pids)
+{
+	struct clone_args my_args;
+	long retval;
+	void **newstack;
+
+	if (clone_args->child_stack) {
+		/*
+		 * Set up the stack for child:
+		 *  - fn_arg will be the argument for the child function
+		 *  - the fn pointer will be loaded into ebx after the clone
+		 */
+		newstack = (void **)(unsigned long)(clone_args->child_stack +
+					    clone_args->child_stack_size);
+		*--newstack = fn_arg;
+		*--newstack = fn;
+	} else
+		newstack = (void **)0;
+
+	my_args = *clone_args;
+	my_args.child_stack = (unsigned long)newstack;
+	my_args.child_stack_size = 0;
+
+        __asm__  __volatile__(
+		"movq %6, %%r10\n\t"	/* pids in r10*/
+		"syscall\n\t"		/* Linux/x86_64 system call */
+		"testq %0,%0\n\t"	/* check return value */
+		"jne 1f\n\t"		/* jump if parent */
+		"popq %%rax\n\t"	/* get subthread function */
+		"popq %%rdi\n\t"	/* get the subthread function arg */
+		"call *%%rax\n\t"	/* start subthread function */
+		"movq %2,%0\n\t"
+		"syscall\n"		/* exit system call: exit subthread */
+		"1:\n\t"
+		:"=a" (retval)
+		:"0" (__NR_eclone), "i" (__NR_exit),
+		 "D" (clone_flags_low),	/* rdi */
+		 "S" (&my_args),	/* rsi */
+		 "d" (sizeof(my_args)),	/* rdx */
+		 "m" (pids)		/* gets moved to r10 */
+		:"rcx", "r10", "r11", "cc"
+		);
+				        /*
+         * glibc lists 'cc' as clobbered, so we might as
+	 * well do it too.  'r11' and 'rcx' are clobbered
+	 * by the 'syscall' instruction itself.  'r8' and
+	 * 'r9' are clobbered by the clone, but that
+	 * thread will exit before getting back out to C.
+         */
+
+	if (retval < 0) {
+		errno = -retval;
+		retval = -1;
+	}
+	return retval;
+}
-- 
1.6.3.3
