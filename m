From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] mktree: add support to ghost tasks (TASK_GHOST)
Date: Fri,  4 Sep 2009 10:20:52 -0400
Message-ID: <1252074054-22241-8-git-send-email-orenl@librato.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252074054-22241-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |  123 +++++++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 80 insertions(+), 43 deletions(-)

diff --git a/restart.c b/restart.c
index 2d8d796..a7f9d22 100644
--- a/restart.c
+++ b/restart.c
@@ -144,12 +144,13 @@ struct task {
 	pid_t real_parent;	/* pid of task's real parent */
 };
 
-#define TASK_ROOT	0x1	/* */
-#define TASK_DEAD	0x2	/* */
-#define TASK_THREAD	0x4	/* */
-#define TASK_SIBLING	0x8	/* */
-#define TASK_SESSION	0x10	/* */
-#define TASK_NEWPID	0x20	/* */
+#define TASK_ROOT	0x1	/* root task */
+#define TASK_GHOST	0x2	/* dead task (pid used as sid/pgid) */
+#define TASK_THREAD	0x4	/* thread (non leader) */
+#define TASK_SIBLING	0x8	/* creator's sibling (use CLONE_PARENT) */
+#define TASK_SESSION	0x10	/* inherits creator's original sid */
+#define TASK_NEWPID	0x20	/* starts a new pid namespace */
+#define TASK_DEAD	0x40	/* dead task (dummy) */
 
 struct ckpt_ctx {
 	pid_t init_pid;
@@ -843,10 +844,12 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 			ckpt_dbg_cont(" prev %d", task->prev_sib->pid);
 		if (task->phantom)
 			ckpt_dbg_cont(" placeholder %d", task->phantom->pid);
-		ckpt_dbg_cont(" %c%c%c%c",
+		ckpt_dbg_cont(" %c%c%c%c%c%c",
 		       (task->flags & TASK_THREAD) ? 'T' : ' ',
 		       (task->flags & TASK_SIBLING) ? 'P' : ' ',
 		       (task->flags & TASK_SESSION) ? 'S' : ' ',
+		       (task->flags & TASK_NEWPID) ? 'N' : ' ',
+		       (task->flags & TASK_GHOST) ? 'G' : ' ',
 		       (task->flags & TASK_DEAD) ? 'D' : ' ');
 		ckpt_dbg_cont("\n");
 	}
@@ -855,7 +858,7 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 	return 0;
 }		
 
-static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid)
+static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 {
 	struct task *task;
 
@@ -864,12 +867,13 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid)
 
 	task = &ctx->tasks_arr[ctx->tasks_nr++];
 
-	task->flags = TASK_DEAD;
+	task->flags = TASK_GHOST;
 
+	/* */
 	task->pid = pid;
-	task->ppid = ckpt_init_task(ctx)->pid;
+	task->ppid = ppid;
 	task->tgid = pid;
-	task->sid = pid;
+	task->sid = ppid;
 
 	task->children = NULL;
 	task->next_sib = NULL;
@@ -892,36 +896,38 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid)
 
 static int ckpt_init_tree(struct ckpt_ctx *ctx)
 {
+	struct ckpt_hdr_pids *pids_arr = ctx->pids_arr;
+	int pids_nr = ctx->pids_nr;
 	struct task *task;
-	pid_t init_sid;
-	pid_t init_pid;
-	pid_t init_pgid;
+	pid_t root_sid;
+	pid_t root_pid;
+	pid_t root_pgid;
 	int i;
 
-	init_pid = ctx->pids_arr[0].vpid;
-	init_sid = ctx->pids_arr[0].vsid;
-	init_pgid = ctx->pids_arr[0].vpgid;
+	root_pid = pids_arr[0].vpid;
+	root_sid = pids_arr[0].vsid;
+	root_pgid = pids_arr[0].vpgid;
 
 	/* XXX for out-of-container subtrees */
-	for (i = 0; i < ctx->pids_nr; i++) {
-		if (ctx->pids_arr[i].vsid == init_sid)
-			ctx->pids_arr[i].vsid = init_pid;
-		if (ctx->pids_arr[i].vpgid == init_sid)
-			ctx->pids_arr[i].vpgid = init_pid;
-		if (ctx->pids_arr[i].vpgid == init_pgid)
-			ctx->pids_arr[i].vpgid = init_pid;
+	for (i = 0; i < pids_nr; i++) {
+		if (pids_arr[i].vsid == root_sid)
+			pids_arr[i].vsid = root_pid;
+		if (pids_arr[i].vpgid == root_sid)
+			pids_arr[i].vpgid = root_pid;
+		if (pids_arr[i].vpgid == root_pgid)
+			pids_arr[i].vpgid = root_pid;
 	}
 
 	/* populate with known tasks */
-	for (i = 0; i < ctx->pids_nr; i++) {
+	for (i = 0; i < pids_nr; i++) {
 		task = &ctx->tasks_arr[i];
 
 		task->flags = 0;
 
-		task->pid = ctx->pids_arr[i].vpid;
-		task->ppid = ctx->pids_arr[i].vppid;
-		task->tgid = ctx->pids_arr[i].vtgid;
-		task->sid = ctx->pids_arr[i].vsid;
+		task->pid = pids_arr[i].vpid;
+		task->ppid = pids_arr[i].vppid;
+		task->tgid = pids_arr[i].vtgid;
+		task->sid = pids_arr[i].vsid;
 
 		task->children = NULL;
 		task->next_sib = NULL;
@@ -936,19 +942,32 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 			return -1;
 	}
 
-	ctx->tasks_nr = ctx->pids_nr;
+	ctx->tasks_nr = pids_nr;
 
 	/* add pids unaccounted for (no tasks) */
-	for (i = 0; i < ctx->pids_nr; i++) {
-		if (ckpt_setup_task(ctx, ctx->pids_arr[i].vsid) < 0)
+	for (i = 0; i < pids_nr; i++) {
+		/* session leader's parent is root task */
+		if (ckpt_setup_task(ctx, pids_arr->vsid, root_pid) < 0)
 			return -1;
-		if (ckpt_setup_task(ctx, ctx->pids_arr[i].vpgid) < 0)
+
+		/*
+		 * If pgrp != sid, pgrp owner's parent is sid. Other
+		 * tasks with same pgrp will need to have threir sid
+		 * matching, too, when the kernel restores their pgrp.
+		 * If pgrp == sid, then the call above would have
+		 * ensured that the pid is hashed: ckpt_setup_task()
+		 * will return promptly.
+		 */
+		if (ckpt_setup_task(ctx, pids_arr->vpgid, pids_arr->vsid) < 0)
 			return -1;
+
+		pids_arr++;
 	}
 
 	/* mark root task(s) */
 	ctx->tasks_arr[0].flags |= TASK_ROOT;
 
+	ckpt_dbg("total tasks (including ghosts): %d\n", ctx->tasks_nr);
 	return 0;
 }
 
@@ -970,10 +989,11 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
  * flags, pid, tgid, sid, pgid, and pointers to the a creator, next
  * and previous sibling, and first child task. Note that the creator
  * may not necessarily correspond to the parent. The possible flags
- * are TASK_DEAD, TASK_THREAD, TASK_SESSION (that asks inherit a
- * session id), and TASK_SIBLING (that asks to inherit the parent via
- * CLONE_PARENT). The algorithm loops through all the entries in the
- * table:
+ * are TASK_ROOT, TASK_GHOST, TASK_THREAD, TASK_SIBLING (that asks to
+ * inherit the parent via CLONE_PARENT), TASK_SESSION (that asks to
+ * inherit a session id), TASK_NEWPID (that asks to start a new pid
+ * namespace), and TASK_DEAD. The algorithm loops through all the
+ * entries in the table:
  *
  * If the entry is a thread and not the thread group leader, we set
  * the creator to be the thread group leader and set TASK_THREAD.
@@ -1023,7 +1043,7 @@ static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
 	struct task *creator;
 
 	if (task == ckpt_init_task(ctx)) {
-		ckpt_err("pid %d: init - no creator\n", ckpt_init_task(ctx)->pid);
+		ckpt_err("pid %d: no init creator\n", ckpt_init_task(ctx)->pid);
 		return -1;
 	}
 
@@ -1230,6 +1250,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 {
 	struct task *child;
 	struct pid_swap swap;
+	unsigned long flags = 0;
 	pid_t newpid;
 	int ret;
 
@@ -1307,9 +1328,20 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)
 	}
 	close(ctx->pipe_out);
 
+	/*
+	 * Ghost tasks are not restarted and end up dead, but their
+	 * pids are referred to by other tasks' pgids (also sids, that
+	 * are already properly set by now). Therefore, they stick
+	 * around until those tasks actually restore their pgrp, and
+	 * then exit (more precisely, killed). The RESTART_GHOST flag
+	 * tells the kernel that they are not to be restored.
+	 */
+	if (task->flags & TASK_GHOST)
+		flags |= RESTART_GHOST;
+
 	/* on success this doesn't return */
-	ckpt_dbg("about to call sys_restart()\n");
-	ret = restart(0, STDIN_FILENO, 0);
+	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
+	ret = restart(0, STDIN_FILENO, flags);
 	if (ret < 0)
 		perror("task restore failed");
 	return ret;
@@ -1562,7 +1594,10 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	memcpy(ctx->copy_arr, ctx->pids_arr, len);
 
 	/* read in 'pid_swap' data and adjust ctx->pids_arr */
-	for (n = 0; n < ctx->pids_nr; n++) {
+	for (n = 0; n < ctx->tasks_nr; n++) {
+		/* don't expect data from dead tasks */
+		if (ctx->tasks_arr[n].flags & TASK_DEAD)
+			continue;
 		ret = read(ctx->pipe_in, &swap, sizeof(swap));
 		if (ret < 0)
 			ckpt_abort(ctx, "read pipe");
@@ -1577,8 +1612,10 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 				ctx->copy_arr[m].vpid = swap.new;
 			if (ctx->pids_arr[m].vtgid == swap.old)
 				ctx->copy_arr[m].vtgid = swap.new;
-			if (ctx->pids_arr[m].vppid == swap.old)
-				ctx->copy_arr[m].vppid = swap.new;
+			if (ctx->pids_arr[m].vpgid == swap.old)
+				ctx->copy_arr[m].vpgid = swap.new;
+			else if (ctx->pids_arr[m].vpgid == -swap.old)
+				ctx->copy_arr[m].vpgid = -swap.new;
 		}
 	}
 
-- 
1.6.0.4
