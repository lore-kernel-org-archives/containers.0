From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] restart: another correction for when root task with sid != pid
Date: Sun, 18 Oct 2009 22:53:59 -0400
Message-ID: <1255920839-14683-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

The case where root_sid != root_pid is handled explicitly. This
patch makes the following fixes:

1) Complain if any pid is invalid (negative, or zero without also
requesting new pid-ns).

2) Remove ckpt_need_pidns() - instead, ckpt_adjust_pids() now
removes zeroed out {sid,pgid}s and uses the coordinators sid for
them (as expected !)

3) In ckpt_adjust_pids() also swap task's vsid (and no need to
swap a negative pid).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |  111 +++++++++++++++++++++++++++++++++++--------------------------
 1 files changed, 64 insertions(+), 47 deletions(-)

diff --git a/restart.c b/restart.c
index 54da220..fbaab88 100644
--- a/restart.c
+++ b/restart.c
@@ -243,6 +243,9 @@ struct task zero_task;
 #define TASK_NEWPID	0x20	/* starts a new pid namespace */
 #define TASK_DEAD	0x40	/* dead task (dummy) */
 
+#define TASK_ZERO_SID	0x100	/* sid was temporarily zeroed */
+#define TASK_ZERO_PGID	0x200	/* pgid was temporarily zeroed */
+
 struct ckpt_ctx {
 	pid_t root_pid;
 	int pipe_in;
@@ -282,7 +285,6 @@ int global_sent_sigint;
 
 static int ckpt_build_tree(struct ckpt_ctx *ctx);
 static int ckpt_init_tree(struct ckpt_ctx *ctx);
-static int ckpt_need_pidns(struct ckpt_ctx *ctx);
 static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task);
 static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task);
 static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *session);
@@ -720,16 +722,6 @@ int main(int argc, char *argv[])
 	if (ret < 0)
 		exit(1);
 
-	/*
-	 * For a pgid/sid == 0, the corresponding restarting task will
-	 * expect to reference the parent pid-ns (of entire restart).
-	 * We ensure that one does exist by setting ctx.args->pidns.
-	 */
-	if (!ctx.args->pidns && ckpt_need_pidns(&ctx)) {
-		ckpt_dbg("found pgid/sid 0, need pidns\n");
-		ctx.args->pidns = 1;
-	}
-
 	if (ctx.args->pidns && ctx.tasks_arr[0].pid != 1) {
 		ckpt_dbg("new pidns without init\n");
 		if (global_send_sigint == -1)
@@ -1080,13 +1072,27 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 	return 0;
 }
 
+static inline int ckpt_valid_pid(pid_t pid, int pidns, char *which, int i)
+{
+	if (pid < 0) {
+		ckpt_err("Invalid %s %d (for task#%d)\n", which, pid, i);
+		return 0;
+	}
+	if (!pidns && pid == 0) {
+		ckpt_err("Zero %s (for task#%d) requires pid-ns\n", which, i);
+		return 0;
+	}
+	return 1;
+}
+
 static int ckpt_init_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_pids *pids_arr = ctx->pids_arr;
 	int pids_nr = ctx->pids_nr;
+	int pidns = ctx->args->pidns;
 	struct task *task;
-	pid_t root_sid;
 	pid_t root_pid;
+	pid_t root_sid;
 	int i;
 
 	root_pid = pids_arr[0].vpid;
@@ -1095,18 +1101,24 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	/*
 	 * The case where root_sid != root_pid is special. It must be
 	 * from a subtree checkpoint (in container, root_sid is either
-	 * root_pid or 0).
-	 * This means that root_sid was inherited from an ancestor of
-	 * that subtree. So we make root_task here also inherit its
-	 * sid from its ancestor (whatever the 'restart' process had).
+	 * same as root_pid or 0), and root_sid was inherited from an
+	 * ancestor of that subtree.
 	 *
-	 * We do it by forcing it to be 0. We also need to force all
-	 * references to it from other processes, via sid and pgid, to
-	 * 0. For that, we keep the root_sid to compare against (see
-	 * one-line comment below).
+	 * So we make the root-task also inherit sid from its ancestor
+	 * (== coordinator), whatever 'restart' task currently has.
+	 * For that, we force the root-task's sid and all references
+	 * to it from other tasks (via sid and pgid), to 0. Later, the
+	 * feeder will substitute the cooridnator's sid for them.
+	 *
+	 * (Note that this still works even if the coordinator's sid
+	 * is "used" by a restarting task: a new-pidns restart will
+	 * fail because the pid is in use, and in an old-pidns restart
+	 * the task will be assigned a new pid anyway).
 	 */
+
+	/* forcing root_sid to -1, will make comparisons below fail */
 	if (root_sid == root_pid)
-		root_sid = 0;
+		root_sid = -1;
 
 	/* populate with known tasks */
 	for (i = 0; i < pids_nr; i++) {
@@ -1114,11 +1126,24 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 		task->flags = 0;
 
+		if (!ckpt_valid_pid(pids_arr[i].vpid, pidns, "pid", i))
+			return -1;
+		else if (!ckpt_valid_pid(pids_arr[i].vtgid, pidns, "tgid", i))
+			return -1;
+		else if (!ckpt_valid_pid(pids_arr[i].vsid, pidns, "sid", i))
+			return -1;
+		else if (!ckpt_valid_pid(pids_arr[i].vpgid, pidns, "pgid", i))
+			return -1;
+
 		/* zero references to root_sid (root_sid != root_pid) */
-		if (pids_arr[i].vsid == root_sid)
+		if (pids_arr[i].vsid == root_sid) {
+			task->flags |= TASK_ZERO_SID;
 			pids_arr[i].vsid = 0;
-		if (pids_arr[i].vpgid == root_sid)
+		}
+		if (pids_arr[i].vpgid == root_sid) {
+			task->flags |= TASK_ZERO_PGID;
 			pids_arr[i].vpgid = 0;
+		}
 
 		task->pid = pids_arr[i].vpid;
 		task->ppid = pids_arr[i].vppid;
@@ -1134,14 +1159,6 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		task->rpid = -1;
 		task->ctx = ctx;
 
-		if (task->pid == 0) {
-			ckpt_err("Invalid pid 0 for task#%d\n", i);
-			return -1;
-		} else if (task->tgid == 0) {
-			ckpt_err("Invalid tgid 0 for task#%d\n", i);
-			return -1;
-		}
-
 		if (hash_insert(ctx, task->pid, task) < 0)
 			return -1;
 	}
@@ -1198,20 +1215,6 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-static int ckpt_need_pidns(struct ckpt_ctx *ctx)
-{
-	int i;
-
-	for (i = 0; i < ctx->pids_nr; i++) {
-		if (ctx->pids_arr[i].vpid == 0 ||
-		    ctx->pids_arr[i].vpgid == 0 ||
-		    ctx->pids_arr[i].vsid == 0)
-			return 1;
-	}
-
-	return 0;
-}
-
 /*
  * Algorithm DumpForest
  * "Transparent Checkpoint/Restart of Multiple Processes on Commodity
@@ -1888,6 +1891,9 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 {
 	struct pid_swap swap;
 	int n, m, len, ret;
+	pid_t coord_sid;
+
+	coord_sid = getsid(0);
 
 	/*
 	 * Make a copy of the original array to fix a nifty bug where
@@ -1920,11 +1926,22 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 				ctx->copy_arr[m].vpid = swap.new;
 			if (ctx->pids_arr[m].vtgid == swap.old)
 				ctx->copy_arr[m].vtgid = swap.new;
+			if (ctx->pids_arr[m].vsid == swap.old)
+				ctx->copy_arr[m].vsid = swap.new;
 			if (ctx->pids_arr[m].vpgid == swap.old)
 				ctx->copy_arr[m].vpgid = swap.new;
-			else if (ctx->pids_arr[m].vpgid == -swap.old)
-				ctx->copy_arr[m].vpgid = -swap.new;
 		}
+
+		/*
+		 * If the task's {sid,pgid} was zeroed out (inside
+		 * ckpt_init_tree) then substitute the coordinator's
+		 * sid for it now. (This should leave no more 0's in
+		 * restart of a subtree-checkpoint).
+		 */
+		if (ctx->tasks_arr[n].flags & TASK_ZERO_SID)
+			ctx->pids_arr[m].vsid = coord_sid;
+		if (ctx->tasks_arr[n].flags & TASK_ZERO_PGID)
+			ctx->pids_arr[m].vpgid = coord_sid;
 	}
 
 	memcpy(ctx->pids_arr, ctx->copy_arr, len);
-- 
1.6.0.4
