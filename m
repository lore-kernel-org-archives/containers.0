From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH user-cr 1/2] use v13 of eclone in clone_s390x.c
Date: Thu, 12 Nov 2009 23:24:45 -0600
Message-ID: <1258089886-10034-2-git-send-email-serue@us.ibm.com>
References: <1258089886-10034-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258089886-10034-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 clone_s390x.c |  100 ++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 68 insertions(+), 32 deletions(-)

diff --git a/clone_s390x.c b/clone_s390x.c
index dada822..945a98d 100644
--- a/clone_s390x.c
+++ b/clone_s390x.c
@@ -13,17 +13,20 @@
 #define _GNU_SOURCE
 
 #include <unistd.h>
+#include <string.h>
+#include <malloc.h>
 #include <errno.h>
 #include <sys/types.h>
 #include <sys/syscall.h>
 #include <asm/unistd.h>
 
+#define __NR_eclone 332
 /*
- * libc doesn't support clone_with_pid() yet...
+ * libc doesn't support eclone() yet...
  * below is arch-dependent code to use the syscall
  */
 #include <linux/checkpoint.h>
-#if defined(__NR_clone_with_pids)
+#if defined(__NR_eclone)
 
 /* this really belongs to some kernel header ! */
 struct pid_set {
@@ -31,42 +34,75 @@ struct pid_set {
 	pid_t *pids;
 };
 
-/* (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html) */
+typedef unsigned long long u64;
+typedef unsigned int u32;
+typedef int pid_t;
+struct clone_args {
+	u64 clone_flags_high;
+	u64 child_stack;
+	u64 child_stack_size;
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
 
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
+	u32 nr_pids;
+
+	u32 reserved0;
+	u64 reserved1;
+};
+
+#define do_eclone(flags, pids, args, sz) \
+( { \
+  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_eclone); \
+  register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
+  register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
+  register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
+  register unsigned long int __r5 asm ("5") = (unsigned long int)(pids); \
+  register long int __result asm ("2"); \
+  __asm__ __volatile__( \
+	  " svc 0\n" /* do __NR_eclone syscall */ \
+	  " ltgr %%r2,%%r2\n" /* returned 0? */ \
+	  " jnz 1f\n" /* if not goto label 1 */ \
+	  " lg %%r3,0(%%r15)\n"   /* get fnarg off stack into arg 1 */ \
+	  " lg %%r2,8(%%r15)\n"   /* get fn off stack int r3 basr*/ \
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
 
 int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
 			struct pid_set *target_pids, void *arg)
 {
-	long retval;
-	retval = do_clone_with_pids(child_stack, flags, NULL, NULL,
-				    target_pids);
+	struct clone_args clone_args, *ca = &clone_args;
+	u64 *s;
+
+	memset(ca, 0, sizeof(struct clone_args));
+	ca->nr_pids = target_pids->num_pids;
+	if (!child_stack) {
+		/* we could pass in null and then in eclone not
+		 * call exit if child_stack was null, but we'll
+		 * just malloc here */
+		int sz = 4*getpagesize();
+		child_stack = malloc(sz);
+		if (!child_stack)
+			return -ENOMEM;
+		child_stack += sz; /* we'll decrement before assigning */
+	}
+	ca->child_stack = (u64) child_stack;
+	s = (u64 *) ca->child_stack;
+	*--s = (u64) arg;
+	*--s = (u64) fn;
+	ca->child_stack -= 16;
 
-	if (retval < 0) {
-		errno = -retval;
-		return -1;
-	} else if (retval == 0) {
-		return fn(arg);
-	} else
-		return retval;
+	return do_eclone(flags, target_pids->pids, ca,
+				    sizeof(struct clone_args));
 }
 
 #endif  /* !defined(__NR_clone_with_pids) */
-- 
1.6.1.1
