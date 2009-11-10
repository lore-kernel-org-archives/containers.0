From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr 1/2] use Suka's v11 api
Date: Tue, 10 Nov 2009 10:58:39 -0600
Message-ID: <20091110165839.GA19222@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch:
	1. changes restart to pass the right values to
		clone-with-pids.
	2. updates the clone_s390x.c to work with the
		new kernel.

All tests under cr_tests/ pass with this patch.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 clone_s390x.c |   92 +++++++++++++++++++++++++++++++++++++--------------------
 restart.c     |   14 +++++----
 2 files changed, 68 insertions(+), 38 deletions(-)

diff --git a/clone_s390x.c b/clone_s390x.c
index dada822..71cf52f 100644
--- a/clone_s390x.c
+++ b/clone_s390x.c
@@ -14,6 +14,7 @@
 
 #include <unistd.h>
 #include <errno.h>
+#include <string.h>
 #include <sys/types.h>
 #include <sys/syscall.h>
 #include <asm/unistd.h>
@@ -25,48 +26,75 @@
 #include <linux/checkpoint.h>
 #if defined(__NR_clone_with_pids)
 
-/* this really belongs to some kernel header ! */
 struct pid_set {
 	int num_pids;
 	pid_t *pids;
 };
 
-/* (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html) */
+typedef unsigned long long u64;
+typedef unsigned int u32;
+typedef int pid_t;
+struct clone_args {
+	u64 clone_flags_high;
 
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
+	u64 child_stack_base;
+	u64 child_stack_size;
 
-int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
+	u64 parent_tid_ptr;
+	u64 child_tid_ptr;
+
+	u32 nr_pids;
+
+	u32 reserved0;
+	u64 reserved1;
+};
+
+#define do_cwp(flags, pids, args, sz) \
+( { \
+  register unsigned long int __r1 asm ("1") = (unsigned long int)(__NR_clone_with_pids); \
+  register unsigned long int __r2 asm ("2") = (unsigned long int)(flags); \
+  register unsigned long int __r3 asm ("3") = (unsigned long int)(args); \
+  register unsigned long int __r4 asm ("4") = (unsigned long int)(sz); \
+  register unsigned long int __r5 asm ("5") = (unsigned long int)(pids); \
+  register long int __result asm ("2"); \
+  __asm__ __volatile__( \
+	  " svc 0\n" /* do __NR_cwp syscall */ \
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
+int clone_with_pids(int (*fn)(void *), void *child_stack,
+			unsigned long stack_size, unsigned long flags,
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
+	ca->child_stack_size = stack_size - 16;
+	ca->child_stack_base = (u64) child_stack;
+	if (child_stack) {
+		s = (u64 *) (ca->child_stack_base + ca->child_stack_size);
+		*--s = (u64) arg;
+		*--s = (u64) fn;
+		ca->child_stack_size -= 16;
+	}
 
-	if (retval < 0) {
-		errno = -retval;
-		return -1;
-	} else if (retval == 0) {
-		return fn(arg);
-	} else
-		return retval;
+	return do_cwp(flags, target_pids->pids, ca,
+				    sizeof(struct clone_args));
 }
 
 #endif  /* !defined(__NR_clone_with_pids) */
diff --git a/restart.c b/restart.c
index 35c54ea..ebc7bf8 100644
--- a/restart.c
+++ b/restart.c
@@ -43,10 +43,12 @@ struct pid_set {
 
 /* (until it's supported by libc) from clone_ARCH.c */
 #if defined(__NR_clone_with_pids) && defined(ARCH_HAS_CLONE_WITH_PID)
-extern int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
+extern int clone_with_pids(int (*fn)(void *), void *child_stack,
+			   unsigned long stack_size, int flags,
 			   struct pid_set *target_pids, void *arg);
 #else
-static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
+static int clone_with_pids(int (*fn)(void *), void *child_stack,
+			    unsigned long stack_size, int flags,
 			   struct pid_set *target_pids, void *arg)
 {
 	return clone(fn, child_stack, flags, arg);
@@ -1749,18 +1751,17 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 {
 	struct pid_set pid_set;
 	char *stack_region;
-	char *stack_start;
 	unsigned long flags = SIGCHLD;
+	unsigned long stack_size = PTHREAD_STACK_MIN;
 	pid_t pid = 0;
 
 	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
 
-	stack_region = malloc(PTHREAD_STACK_MIN);
+	stack_region = malloc(stack_size);
 	if (!stack_region) {
 		perror("stack malloc");
 		return -1;
 	}
-	stack_start = stack_region + PTHREAD_STACK_MIN - 1;
 
 	pid_set.pids = &pid;
 	pid_set.num_pids = 1;
@@ -1788,7 +1789,8 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	else
 		child->real_parent = _getpid();
 
-	pid = clone_with_pids(ckpt_fork_stub, stack_start, flags, &pid_set, child);
+	pid = clone_with_pids(ckpt_fork_stub, stack_region, stack_size - 16,
+				flags, &pid_set, child);
 	if (pid < 0) {
 		perror("clone");
 		free(stack_region);
-- 
1.6.1.1
