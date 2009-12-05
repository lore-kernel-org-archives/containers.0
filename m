From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/5] user-cr: use genstack API in restart.c
Date: Fri,  4 Dec 2009 23:02:30 -0600
Message-ID: <1259989351-28552-5-git-send-email-ntl@pobox.com>
References: <1259989351-28552-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259989351-28552-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Fixes a couple of off-by-one bugs and makes it more portable.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 Makefile  |    2 +-
 restart.c |   42 +++++++++++++++++++++---------------------
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/Makefile b/Makefile
index 1a37844..b1485cb 100644
--- a/Makefile
+++ b/Makefile
@@ -37,7 +37,7 @@ restart: CFLAGS += -D__REENTRANT -pthread
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
-restart: clone_$(SUBARCH).o
+restart: clone_$(SUBARCH).o genstack.o
 restart: CFLAGS += -DARCH_HAS_ECLONE
 nsexeccwp: clone_$(SUBARCH).o
 nsexeccwp: CFLAGS += -DARCH_HAS_ECLONE
diff --git a/restart.c b/restart.c
index f0fa348..9d1c1d1 100644
--- a/restart.c
+++ b/restart.c
@@ -36,6 +36,7 @@
 #include <linux/checkpoint_hdr.h>
 
 #include "eclone.h"
+#include "genstack.h"
 
 static char usage_str[] =
 "usage: restart [opts]\n"
@@ -1001,9 +1002,10 @@ static int ckpt_coordinator_status(struct ckpt_ctx *ctx)
 
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 {
-	void *stk = NULL;
 	pid_t coord_pid;
 	int copy, ret;
+	genstack stk;
+	void *sp;
 
 	ckpt_dbg("forking coordinator in new pidns\n");
 
@@ -1018,18 +1020,18 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 		return -1;
 	}
 
-	stk = malloc(PTHREAD_STACK_MIN);
+	stk = genstack_alloc(PTHREAD_STACK_MIN);
 	if (!stk) {
-		perror("coordinator stack malloc");
+		perror("coordinator genstack_alloc");
 		return -1;
 	}
-	stk += PTHREAD_STACK_MIN;
+	sp = genstack_sp(stk);
 
 	copy = ctx->args->copy_status;
 	ctx->args->copy_status = 1;
 
-	coord_pid = clone(__ckpt_coordinator, stk, CLONE_NEWPID|SIGCHLD, ctx);
-	free(stk - PTHREAD_STACK_MIN);
+	coord_pid = clone(__ckpt_coordinator, sp, CLONE_NEWPID|SIGCHLD, ctx);
+	genstack_release(stk);
 	if (coord_pid < 0) {
 		perror("clone coordinator");
 		return coord_pid;
@@ -1883,17 +1885,16 @@ int ckpt_fork_stub(void *data)
 static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 {
 	struct clone_args clone_args;
-	void *stack;
+	genstack stk;
 	unsigned long flags = SIGCHLD;
-	size_t stack_sz = PTHREAD_STACK_MIN;
 	size_t nr_pids = 1;
 	pid_t pid = 0;
 
 	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
 
-	stack = malloc(stack_sz);
-	if (!stack) {
-		perror("stack malloc");
+	stk = genstack_alloc(PTHREAD_STACK_MIN);
+	if (!stk) {
+		perror("ckpt_fork_child genstack_alloc");
 		return -1;
 	}
 
@@ -1921,19 +1922,19 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 		child->real_parent = _getpid();
 
 	memset(&clone_args, 0, sizeof(clone_args));
-	clone_args.child_stack = (unsigned long)stack;
-	clone_args.child_stack_size = stack_sz;
+	clone_args.child_stack = (unsigned long)genstack_base(stk);
+	clone_args.child_stack_size = genstack_size(stk);
 	clone_args.nr_pids = nr_pids;
 
 	pid = eclone(ckpt_fork_stub, child, flags, &clone_args, &pid);
 	if (pid < 0) {
 		perror("eclone");
-		free(stack);
+		genstack_release(stk);
 		return -1;
 	}
 
 	if (!(child->flags & TASK_THREAD))
-		free(stack);
+		genstack_release(stk);
 
 	ckpt_dbg("forked child vpid %d (asked %d)\n", pid, child->pid);
 	return pid;
@@ -1950,7 +1951,7 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
  */
 static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 {
-	void *stack;
+	genstack stk;
 	pid_t pid;
 
 	if (pipe(ctx->pipe_feed)) {
@@ -1969,14 +1970,13 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 	 * this may interfere with the restart.
 	 */
 
-	stack = malloc(PTHREAD_STACK_MIN);
-	if (!stack) {
-		perror("stack malloc");
+	stk = genstack_alloc(PTHREAD_STACK_MIN);
+	if (!stk) {
+		perror("ckpt_fork_feeder genstack_alloc");
 		return -1;
 	}
-	stack += PTHREAD_STACK_MIN;
 
-	pid = clone(ckpt_do_feeder, stack,
+	pid = clone(ckpt_do_feeder, genstack_sp(stk),
 		    CLONE_THREAD | CLONE_SIGHAND | CLONE_VM, ctx);
 	if (pid < 0) {
 		perror("feeder thread");
-- 
1.6.0.6
