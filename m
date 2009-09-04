From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/3] restart: correctly handle pgid/ppid/sid = 0
Date: Fri,  4 Sep 2009 10:20:54 -0400
Message-ID: <1252074054-22241-10-git-send-email-orenl@librato.com>
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

If pgid, or sid, or ppid is zero, it means that they point to a task
from the ancestor pid-ns. Make sure 'mktree' handles these correctly.

If a 0 pid (pgid/sid/ppid) exists, then force the --pidns option to be
on - to ensure that we have a new pid-ns (and thus a parent pid-ns).

Ignore pid = 0 when setting up new tasks in ckpt_setup_task().

Improve sanity checks for pid 0 and tgid 0 (both are impossible).

Allow ppid = 0 only for root_task. For others, allow sid = 0.

Introduce dummy zero_task that represents the parent of root_task,
likely from ancestor pid-ns. Setting a creator to root_task simplifies
the logic.

Also, ensure that a the tgid of threads is valid (has an entry in the
pids array) even if the thread group leader died.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |  126 +++++++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 89 insertions(+), 37 deletions(-)

diff --git a/restart.c b/restart.c
index a7f9d22..3128d4e 100644
--- a/restart.c
+++ b/restart.c
@@ -63,8 +63,8 @@ static char usage_str[] =
  * the time of the checkpoint may be already in use then. Therefore,
  * by default, 'mktree' creates an equivalen tree without restoring
  * the original pids, assuming that the application can tolerate this.
- * For this, the 'ckpt_hdr_pids' array is transformed on-the-fly
- * before it is fed to the kernel.
+ * For this, the 'ckpt_pids' array is transformed on-the-fly before it
+ * is fed to the kernel.
  *
  * By default, "--pids" implied "--pidns" and vice-versa. The user can
  * use "--pids --no-pidns" for a restart in the currnet namespace -
@@ -144,6 +144,9 @@ struct task {
 	pid_t real_parent;	/* pid of task's real parent */
 };
 
+/* zero_task represents creator of root_task (all pids 0) */
+struct task zero_task;
+
 #define TASK_ROOT	0x1	/* root task */
 #define TASK_GHOST	0x2	/* dead task (pid used as sid/pgid) */
 #define TASK_THREAD	0x4	/* thread (non leader) */
@@ -153,7 +156,7 @@ struct task {
 #define TASK_DEAD	0x40	/* dead task (dummy) */
 
 struct ckpt_ctx {
-	pid_t init_pid;
+	pid_t root_pid;
 	int pipe_in;
 	int pipe_out;
 	int pids_nr;
@@ -196,6 +199,7 @@ int global_sent_sigint;
 
 static int ckpt_build_tree(struct ckpt_ctx *ctx);
 static int ckpt_init_tree(struct ckpt_ctx *ctx);
+static int ckpt_need_pidns(struct ckpt_ctx *ctx);
 static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task);
 static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task);
 static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *session);
@@ -545,6 +549,16 @@ int main(int argc, char *argv[])
 	if (ret < 0)
 		exit(1);
 
+	/*
+	 * For a pgid/sid == 0, the corresponding restarting task will
+	 * expect to reference the parent pid-ns (of entire restart).
+	 * We ensure that one does exist by setting ctx.args->pidns.
+	 */
+	if (!ctx.args->pidns && ckpt_need_pidns(&ctx)) {
+		ckpt_dbg("found pgid/sid 0, need pidns\n");
+		ctx.args->pidns = 1;
+	}
+
 	if (ctx.args->pidns && ctx.tasks_arr[0].pid != 1) {
 		ckpt_dbg("new pidns without init\n");
 		if (global_send_sigint == -1)
@@ -821,8 +835,6 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 	/* assign a creator to each task */
 	for (i = 0; i < ctx->tasks_nr; i++) {
 		task = &ctx->tasks_arr[i];
-		if (task == ckpt_init_task(ctx))
-			continue;
 		if (task->creator)
 			continue;
 		if (ckpt_set_creator(ctx, task) < 0) {
@@ -837,7 +849,7 @@ static int ckpt_build_tree(struct ckpt_ctx *ctx)
 		task = &ctx->tasks_arr[i];
 		ckpt_dbg("[%d] pid %d ppid %d sid %d creator %d",
 			 i, task->pid, task->ppid, task->sid,
-		       task->creator ? task->creator->pid : 0);
+			 task->creator->pid);
 		if (task->next_sib)
 			ckpt_dbg_cont(" next %d", task->next_sib->pid);
 		if (task->prev_sib)
@@ -862,7 +874,10 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 {
 	struct task *task;
 
-	if (hash_lookup(ctx, pid))
+	if (pid == 0)  /* ignore if outside namespace */
+		return 0;
+
+	if (hash_lookup(ctx, pid))  /* already handled */
 		return 0;
 
 	task = &ctx->tasks_arr[ctx->tasks_nr++];
@@ -896,7 +911,7 @@ static int ckpt_setup_task(struct ckpt_ctx *ctx, pid_t pid, pid_t ppid)
 
 static int ckpt_init_tree(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_pids *pids_arr = ctx->pids_arr;
+	struct ckpt_pids *pids_arr = ctx->pids_arr;
 	int pids_nr = ctx->pids_nr;
 	struct task *task;
 	pid_t root_sid;
@@ -908,16 +923,6 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	root_sid = pids_arr[0].vsid;
 	root_pgid = pids_arr[0].vpgid;
 
-	/* XXX for out-of-container subtrees */
-	for (i = 0; i < pids_nr; i++) {
-		if (pids_arr[i].vsid == root_sid)
-			pids_arr[i].vsid = root_pid;
-		if (pids_arr[i].vpgid == root_sid)
-			pids_arr[i].vpgid = root_pid;
-		if (pids_arr[i].vpgid == root_pgid)
-			pids_arr[i].vpgid = root_pid;
-	}
-
 	/* populate with known tasks */
 	for (i = 0; i < pids_nr; i++) {
 		task = &ctx->tasks_arr[i];
@@ -938,6 +943,14 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		task->rpid = -1;
 		task->ctx = ctx;
 
+		if (task->pid == 0) {
+			ckpt_err("Invalid pid 0 for task#%d\n", i);
+			return -1;
+		} else if (task->tgid == 0) {
+			ckpt_err("Invalid tgid 0 for task#%d\n", i);
+			return -1;
+		}
+
 		if (hash_insert(ctx, task->pid, task) < 0)
 			return -1;
 	}
@@ -946,31 +959,60 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 	/* add pids unaccounted for (no tasks) */
 	for (i = 0; i < pids_nr; i++) {
-		/* session leader's parent is root task */
-		if (ckpt_setup_task(ctx, pids_arr->vsid, root_pid) < 0)
+		pid_t sid;
+
+		sid = pids_arr[i].vsid;
+
+		/*
+		 * An unaccounted-for sid belongs to a task that was a
+		 * session leader and died. We can safe set its parent
+		 * (and creator) to be the root task.
+		 */
+		if (ckpt_setup_task(ctx, sid, root_pid) < 0)
 			return -1;
 
 		/*
-		 * If pgrp != sid, pgrp owner's parent is sid. Other
-		 * tasks with same pgrp will need to have threir sid
-		 * matching, too, when the kernel restores their pgrp.
-		 * If pgrp == sid, then the call above would have
-		 * ensured that the pid is hashed: ckpt_setup_task()
-		 * will return promptly.
+		 * If a pid belongs to a dead thread group leader, we
+		 * need to add it with the same sid as current (and
+		 * other) threads.
 		 */
-		if (ckpt_setup_task(ctx, pids_arr->vpgid, pids_arr->vsid) < 0)
+		if (ckpt_setup_task(ctx, pids_arr[i].vtgid, sid) < 0)
 			return -1;
 
-		pids_arr++;
+		/*
+		 * If pgrp == sid, then the pgrp/sid will already have
+		 * been hashed by now (e.g. by the call above) and the
+		 * ckpt_setup_task() will return promptly.
+		 * If pgrp != sid, then the pgrp 'owner' must have the
+		 * same sid as us: all tasks with same pgrp must have
+		 * their sid matching.
+		 */
+		if (ckpt_setup_task(ctx, pids_arr[i].vpgid, sid) < 0)
+			return -1;
 	}
 
-	/* mark root task(s) */
-	ctx->tasks_arr[0].flags |= TASK_ROOT;
+	/* mark root task(s), and set its "creator" to be zero_task */
+	ckpt_init_task(ctx)->flags |= TASK_ROOT;
+	ckpt_init_task(ctx)->creator = &zero_task;
 
 	ckpt_dbg("total tasks (including ghosts): %d\n", ctx->tasks_nr);
 	return 0;
 }
 
+static int ckpt_need_pidns(struct ckpt_ctx *ctx)
+{
+	int i;
+
+	for (i = 0; i < ctx->pids_nr; i++) {
+		if (ctx->pids_arr[i].vpid == 0 ||
+		    ctx->pids_arr[i].vpgid == 0 ||
+		    ctx->pids_arr[i].vsid == 0)
+			return 1;
+	}
+
+	return 0;
+}
+
 /*
  * Algorithm DumpForest
  * "Transparent Checkpoint/Restart of Multiple Processes on Commodity
@@ -1043,10 +1085,20 @@ static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
 	struct task *creator;
 
 	if (task == ckpt_init_task(ctx)) {
-		ckpt_err("pid %d: no init creator\n", ckpt_init_task(ctx)->pid);
+		ckpt_err("pid %d: logical error\n", ckpt_init_task(ctx)->pid);
 		return -1;
 	}
 
+	/* only root_task can have ppid == 0, parent must always exist */
+	if (task->ppid == 0 || !parent) {
+		ckpt_err("pid %d: invalid ppid %d\n", task->pid, task->ppid);
+		return -1;
+	}
+
+	/* sid == 0 must have been inherited from outside the container */
+	if (task->sid == 0)
+		session = ckpt_init_task(ctx);
+
 	if (task->tgid != task->pid) {
 		/* thread: creator is thread-group-leader */
 		ckpt_dbg("pid %d: thread tgid %d\n", task->pid, task->tgid);
@@ -1073,7 +1125,7 @@ static int ckpt_set_creator(struct ckpt_ctx *ctx, struct task *task)
 		creator = session->phantom;
 	} else {
 		/* first make sure we know the session's creator */
-		if (!session->creator && session != ckpt_init_task(ctx)) {
+		if (!session->creator) {
 			/* (non-session-leader) recursive: session's creator */
 			ckpt_dbg("pid %d: recursive session creator %d\n",
 			       task->pid, task->sid);
@@ -1206,7 +1258,7 @@ static int ckpt_propagate_session(struct ckpt_ctx *ctx, struct task *task)
 		ckpt_dbg("pid %d: moving up to %d\n", task->pid, creator->pid);
 		task = creator;
 
-		if(!task->creator && task != ckpt_init_task(ctx)) {
+		if(!task->creator) {
 			if (ckpt_set_creator(ctx, task) < 0)
 				return -1;
 		}
@@ -1389,7 +1441,7 @@ int ckpt_fork_stub(void *data)
 
 	/* root has some extra work */
 	if (task->flags & TASK_ROOT) {
-		ctx->init_pid = _getpid();
+		ctx->root_pid = _getpid();
 		ckpt_dbg("root task pid %d\n", _getpid());
 	}
 
@@ -1513,13 +1565,13 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 static void ckpt_abort(struct ckpt_ctx *ctx, char *str)
 {
 	perror(str);
-	kill(-(ctx->init_pid), SIGKILL);
+	kill(-(ctx->root_pid), SIGKILL);
 	exit(1);
 }
 
 /*
  * feeder process: delegates checkpoint image stream to the kernel.
- * In '--no-pids' mode, transform the pids array (struct ckpt_hdr_pids)
+ * In '--no-pids' mode, transform the pids array (struct ckpt_pids)
  * on the fly and feed the result to the "init" task of the restart
  */
 static int ckpt_do_feeder(void *data)
@@ -1567,7 +1619,7 @@ static int ckpt_do_feeder(void *data)
 }
 
 /*
- * ckpt_adjust_pids: transform the pids array (struct ckpt_hdr_pids) by
+ * ckpt_adjust_pids: transform the pids array (struct ckpt_pids) by
  * substituing actual pid values for original pid values.
  *
  * Collect pids reported by the newly created tasks; each task sends
-- 
1.6.0.4
