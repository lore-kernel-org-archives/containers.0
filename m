From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/9] user-cr: x86_32 eclone wrapper
Date: Tue, 17 Nov 2009 18:55:39 -0600
Message-ID: <1258505746-31182-3-git-send-email-ntl@pobox.com>
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

---
 clone_x86_32.c |   65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/clone_x86_32.c b/clone_x86_32.c
index 8ab3c3e..61b593c 100644
--- a/clone_x86_32.c
+++ b/clone_x86_32.c
@@ -81,3 +81,68 @@ int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 }
 
 #endif
+
+#include "eclone.h"
+
+#ifndef __NR_eclone
+#define __NR_eclone 337
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
+	__asm__	 __volatile__(
+		"movl %0, %%ebx\n\t"	       /* flags -> 1st (ebx) */
+		"movl %1, %%ecx\n\t"	       /* clone_args -> 2nd (ecx) */
+		"movl %2, %%edx\n\t"	       /* args_size -> 3rd (edx) */
+		"movl %3, %%edi\n\t"	       /* pids -> 4th (edi) */
+		"pushl %%ebp\n\t"	       /* save value of ebp */
+		:
+		:"b" (clone_flags_low),
+		 "c" (&my_args),
+		 "d" (sizeof(my_args)),
+		 "D" (pids)
+		);
+
+	__asm__ __volatile__(
+		"int $0x80\n\t"	       /* Linux/i386 system call */
+		"testl %0,%0\n\t"      /* check return value */
+		"jne 1f\n\t"	       /* jump if parent */
+		"popl %%ebx\n\t"       /* get subthread function */
+		"call *%%ebx\n\t"      /* start subthread function */
+		"movl %2,%0\n\t"
+		"int $0x80\n"	       /* exit system call: exit subthread */
+		"1:\n\t"
+		"popl %%ebp\t"	       /* restore parent's ebp */
+		:"=a" (retval)
+		:"0" (__NR_eclone), "i" (__NR_exit)
+		:"ebx", "ecx"
+		);
+
+	if (retval < 0) {
+		errno = -retval;
+		retval = -1;
+	}
+	return retval;
+}
-- 
1.6.2.5
