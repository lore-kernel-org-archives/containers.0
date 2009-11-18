From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/9] user-cr: s390 eclone wrapper
Date: Tue, 17 Nov 2009 18:55:40 -0600
Message-ID: <1258505746-31182-4-git-send-email-ntl@pobox.com>
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

Based on original work from Serge Hallyn.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 clone_s390x.c |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/clone_s390x.c b/clone_s390x.c
index dada822..5ed6f15 100644
--- a/clone_s390x.c
+++ b/clone_s390x.c
@@ -70,3 +70,65 @@ int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 }
 
 #endif  /* !defined(__NR_clone_with_pids) */
+
+#include "eclone.h"
+
+#ifndef __NR_eclone
+#define __NR_eclone 332
+#endif
+
+typedef unsigned long long u64;
+
+#define do_eclone(flags, pids, args, sz) \
+( { \
+  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_eclone); 
+  register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
+  register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
+  register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
+  register unsigned long int __r5 asm ("5") = (unsigned long int)(pids); \
+  register long int __result asm ("2"); \
+  __asm__ __volatile__( \
+	  " svc 0\n" /* do __NR_eclone syscall */ \
+	  " ltgr %%r2,%%r2\n" /* returned 0? */ \
+	  " jnz 1f\n" /* if not goto label 1 */ \
+	  " lg %%r3,0(%%r15)\n"	  /* get fnarg off stack into arg 1 */ \
+	  " lg %%r2,8(%%r15)\n"	  /* get fn off stack int r3 basr*/ \
+	  " lgr %%r1,%%r15\n" /* tmp store old stack pointer */ \
+	  " aghi %%r15,-160\n" /* move the stack */ \
+	  " stg %%r1,0(%%r15)\n" /* and save old stack pointer */ \
+	  " basr %%r14,%%r3\n" /* call fn(arg) */ \
+	  " svc 1\n"  /* call exit */ \
+	  " 1:\n" \
+	  : "=d" (__result) \
+	  : "d" (__r1), "0" (__r2), "d" (__r3), "d" (__r4), "d" (__r5) \
+	  : "memory"); \
+	__result; \
+} )
+
+int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
+	   struct clone_args *clone_args, pid_t *pids)
+{
+	struct clone_args my_args;
+	u64 *child_sp;
+	int rc;
+
+	if (clone_args->child_stack) {
+		child_sp = (void *)(clone_args->child_stack +
+				    clone_args->child_stack_size);
+		*--child_sp = (u64)fn_arg;
+		*--child_sp = (u64)fn;
+	} else
+		child_sp = (u64 *)0;
+
+	my_args = *clone_args;
+	my_args.child_stack = (unsigned long)child_sp;
+	my_args.child_stack_size = 0;
+
+	rc = do_eclone(flags, pids, &my_args, sizeof(struct clone_args));
+	if (rc < 0) {
+		errno = rc;
+		rc = -1;
+	}
+
+	return rc;
+}
-- 
1.6.2.5
