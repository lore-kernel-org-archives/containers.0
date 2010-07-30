From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 2/4] restart thread safety: remove malloc from ckpt_fork_child
Date: Fri, 30 Jul 2010 13:08:31 -0400
Message-ID: <1280509713-6745-2-git-send-email-orenl@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280169472.7875.4290.camel@localhost>
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
Cc: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Id: containers.vger.kernel.org

We use clone and eclone directly and not through glibc, therefore
must explicitly care about thread-safety of malloc.

This patch eliminates the use of malloc() from ckpt_fork_child(). The
malloc was needed to make a pid-array for eclone using data from the
vpids from the checkpoint image. In particular, it added the 0th level
pid. Instead, we re-package vpids array early on by expanding the array
and pre-adding 0th pids before any of the forks take place.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   82 ++++++++++++++++++++++++++++++++----------------------------
 1 files changed, 44 insertions(+), 38 deletions(-)

diff --git a/restart.c b/restart.c
index b281ca2..b274e37 100644
--- a/restart.c
+++ b/restart.c
@@ -1725,9 +1725,9 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	unsigned long flags = SIGCHLD;
 	pid_t pid = 0;
 	pid_t *pids = &pid;
-	int i, j, depth;
+	int i, depth;
 
-	ckpt_dbg("forking child vpid %d flags %#x\n", child->pid, child->flags);
+	ckpt_dbg("fork child vpid %d flags %#x\n", child->pid, child->flags);
 
 	stk = genstack_alloc(PTHREAD_STACK_MIN);
 	if (!stk) {
@@ -1747,17 +1747,7 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 		depth = child->piddepth + 1;
 		clone_args.nr_pids = depth;
 
-		pids = malloc(sizeof(pid_t) * depth);
-		if (!pids) {
-			perror("ckpt_fork_child pids malloc");
-			return -1;
-		}
-
-		memset(pids, 0, sizeof(pid_t) * depth);
-		pids[0] = child->pid;
-
-		for (i = child->piddepth - 1, j = 0; i >= 0; i--, j++)
-			pids[j + 1] = ctx->vpids_arr[child->vidx + j];
+		pids = &ctx->vpids_arr[child->vidx];
 
 #ifndef CLONE_NEWPID
 		if (child->piddepth > child->creator->piddepth) {
@@ -1810,9 +1800,6 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 	if (pid < 0 || !(child->flags & TASK_THREAD))
 		genstack_release(stk);
 
-	if (pids != &pid)
-		free(pids);
-
 	ckpt_dbg("forked child vpid %d (asked %d)\n", pid, child->pid);
 	return pid;
 }
@@ -2336,34 +2323,53 @@ static int ckpt_read_tree(struct ckpt_ctx *ctx)
 	return ret;
 }
 
-/* set the vpids pointers in all the tasks */
+/*
+ * transform vpids arrays to the format convenient for eclone:
+ * prefix the level 0 pid to every sequence of nested pids.
+ * also,  set the vpids pointers in all the tasks.
+ */
 static int assign_vpids(struct ckpt_ctx *ctx)
 {
-	int d, hidx, tidx;
-	struct task *t;
+	__s32 *vpids_arr;
+	int depth, hidx, vidx, tidx;
+	struct task *task;
 
-	for (hidx = 0, tidx = 0; tidx < ctx->pids_nr; tidx++) {
-		t = &ctx->tasks_arr[tidx];
-		d = t->piddepth = ctx->pids_arr[tidx].depth;
-		if (!d) {
-			ckpt_dbg("task[%d].vidx = -1\n", tidx);
-			t->vidx = -1;
-			continue;
-		}
-		t->vidx = hidx;
+	vpids_arr = malloc(sizeof(__s32) * (ctx->vpids_nr + ctx->pids_nr));
+	if (vpids_arr == NULL) {
+		perror("assign_vpids malloc");
+		return -1;
+	}
+
+	for (tidx = 0, hidx = 0, vidx = 0; tidx < ctx->pids_nr; tidx++) {
+		task = &ctx->tasks_arr[tidx];
+		depth = ctx->pids_arr[tidx].depth;
+
+		task->vidx = vidx;
+		task->piddepth = depth;
+
+		/* set task's and top level pid */
+		vpids_arr[vidx++] = task->pid;
+		/* copy task's nested pids */
+		memcpy(&vpids_arr[vidx], &ctx->vpids_arr[hidx],
+		       sizeof(__s32) * depth);
+
+		vidx += depth;
+		hidx += depth;
+
+#ifdef CHECKPOINT_DEBUG
 		ckpt_dbg("task[%d].vidx = %d (depth %d, rpid %d)\n",
-			tidx, hidx, t->piddepth, ctx->pids_arr[tidx].vpid);
-		int i;
-		for (i=0; i<t->piddepth; i++)
-			ckpt_dbg("task[%d].vpid[%d] = %d\n", tidx, i,
-				ctx->vpids_arr[hidx+i]);
-		hidx += d;
-		if (hidx > ctx->vpids_nr) {
-			ckpt_err("Error parsing vpids array");
-			return -1;
+			tidx, vidx, depth, ctx->pids_arr[tidx].vpid);
+		while (depth-- > 0)  {
+			ckpt_dbg("task[%d].vpid[%d] = %d\n", tidx,
+				 depth, vpids_arr[hidx - depth - 1]);
 		}
+#endif
 	}
 
+	/* relpace "raw" vpids_arr with this one */
+	free(ctx->vpids_arr);
+	ctx->vpids_arr = vpids_arr;
+
 	return 0;
 }
 
-- 
1.7.0.4
