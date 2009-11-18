From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/9] user-cr: use eclone API for restart
Date: Tue, 17 Nov 2009 18:55:43 -0600
Message-ID: <1258505746-31182-7-git-send-email-ntl@pobox.com>
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

Replace use of clone_with_pids with clone_args/eclone.  After this the
clone_with_pids support code can go away.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 restart.c |   46 +++++++++++++++-------------------------------
 1 files changed, 15 insertions(+), 31 deletions(-)

diff --git a/restart.c b/restart.c
index d5d069a..258cda9 100644
--- a/restart.c
+++ b/restart.c
@@ -34,25 +34,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-
-/* this really belongs to some kernel header ! */
-struct pid_set {
-	int num_pids;
-	pid_t *pids;
-};
-
-/* (until it's supported by libc) from clone_ARCH.c */
-#if defined(__NR_clone_with_pids) && defined(ARCH_HAS_CLONE_WITH_PID)
-extern int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
-			   struct pid_set *target_pids, void *arg);
-#else
-static int clone_with_pids(int (*fn)(void *), void *child_stack, int flags,
-			   struct pid_set *target_pids, void *arg)
-{
-	return clone(fn, child_stack, flags, arg);
-}
-#endif
-
+#include "eclone.h"
 
 static char usage_str[] =
 "usage: restart [opts]\n"
@@ -1852,23 +1834,20 @@ int ckpt_fork_stub(void *data)
 
 static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 {
-	struct pid_set pid_set;
-	char *stack_region;
-	char *stack_start;
+	struct clone_args clone_args;
+	void *stack;
 	unsigned long flags = SIGCHLD;
+	size_t stack_sz = PTHREAD_STACK_MIN;
+	size_t nr_pids = 1;
 	pid_t pid = 0;
 
 	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
 
-	stack_region = malloc(PTHREAD_STACK_MIN);
-	if (!stack_region) {
+	stack = malloc(stack_sz);
+	if (!stack) {
 		perror("stack malloc");
 		return -1;
 	}
-	stack_start = stack_region + PTHREAD_STACK_MIN - 1;
-
-	pid_set.pids = &pid;
-	pid_set.num_pids = 1;
 
 	if (child->flags & TASK_THREAD) {
 		flags |= CLONE_THREAD | CLONE_SIGHAND | CLONE_VM;
@@ -1893,15 +1872,20 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	else
 		child->real_parent = _getpid();
 
-	pid = clone_with_pids(ckpt_fork_stub, stack_start, flags, &pid_set, child);
+	memset(&clone_args, 0, sizeof(clone_args));
+	clone_args.child_stack = (unsigned long)stack;
+	clone_args.child_stack_size = stack_sz;
+	clone_args.nr_pids = nr_pids;
+
+	pid = eclone(ckpt_fork_stub, child, flags, &clone_args, &pid);
 	if (pid < 0) {
 		perror("clone");
-		free(stack_region);
+		free(stack);
 		return -1;
 	}
 
 	if (!(child->flags & TASK_THREAD))
-		free(stack_region);
+		free(stack);
 
 	ckpt_dbg("forked child vpid %d (asked %d)\n", pid, child->pid);
 	return pid;
-- 
1.6.2.5
