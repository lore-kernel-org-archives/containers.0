From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/3] restart: allow subtree restart of image with sid/pgid zero
Date: Tue, 10 Nov 2009 17:04:52 -0500
Message-ID: <1257890692-28046-3-git-send-email-orenl@librato.com>
References: <1257890692-28046-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257890692-28046-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

In a checkpoint of a child namespace, it is possible that sid or pgid
will be 0 (meaning, they are from a process outside that namespace).

Restarting from such an image with --pidns is easy, and works well.
However, restarting with --no-pids didn't work because we can't deal
with zero pids.

This patch fixes the problem for subtree restart (--no-pidns). If it
finds sid/pgid that are zero, it creates a special ghost task, and
substitutes its pid for all those 0's.

(Also get rid of un-suqashing of sid/pgid == 0 in ckpt_adjust_pids()
because there should no longer be any 0's there).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |  127 +++++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 77 insertions(+), 50 deletions(-)

diff --git a/restart.c b/restart.c
index 2efe879..0c438c2 100644
--- a/restart.c
+++ b/restart.c
@@ -250,9 +250,6 @@ struct task zero_task;
 #define TASK_NEWPID	0x20	/* starts a new pid namespace */
 #define TASK_DEAD	0x40	/* dead task (dummy) */
 
-#define TASK_ZERO_SID	0x100	/* sid was temporarily zeroed */
-#define TASK_ZERO_PGID	0x200	/* pgid was temporarily zeroed */
-
 struct ckpt_ctx {
 	pid_t root_pid;
 	int pipe_in;
@@ -1239,6 +1236,41 @@ static int ckpt_valid_pid(struct ckpt_ctx *ctx, pid_t pid, char *which, int i)
 	return 1;
 }
 
+static int ckpt_alloc_pid(struct ckpt_ctx *ctx)
+{
+	int n = 0;
+
+	/*
+	 * allocate an unused pid for the placeholder
+	 * (this will become inefficient if pid-space is exhausted)
+	 */
+	do {
+		if (ctx->tasks_pid == INT_MAX)
+			ctx->tasks_pid = 2;
+		else
+			ctx->tasks_pid++;
+
+		if (n++ == INT_MAX) {	/* ohhh... */
+			ckpt_err("pid namsepace exhausted");
+			return -1;
+		}
+	} while (hash_lookup(ctx, ctx->tasks_pid));
+
+	return ctx->tasks_pid;
+}
+
+static int ckpt_zero_pid(struct ckpt_ctx *ctx)
+{
+	pid_t pid;
+
+	pid = ckpt_alloc_pid(ctx);
+	if (pid < 0)
+		return -1;
+	if (ckpt_setup_task(ctx, pid, ctx->pids_arr[0].vpid) < 0)
+		return -1;
+	return pid;
+}
+
 static int ckpt_init_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_pids *pids_arr = ctx->pids_arr;
@@ -1246,6 +1278,7 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	struct task *task;
 	pid_t root_pid;
 	pid_t root_sid;
+	pid_t zero_pid = 0;
 	int i;
 
 	root_pid = pids_arr[0].vpid;
@@ -1257,16 +1290,20 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 	 * same as root_pid or 0), and root_sid was inherited from an
 	 * ancestor of that subtree.
 	 *
-	 * So we make the root-task also inherit sid from its ancestor
-	 * (== coordinator), whatever 'restart' task currently has.
-	 * For that, we force the root-task's sid and all references
-	 * to it from other tasks (via sid and pgid), to 0. Later, the
-	 * feeder will substitute the cooridnator's sid for them.
+	 * If we restart with --pidns, make the root-task also inherit
+	 * sid from its ancestor (== coordinator), whatever 'restart'
+	 * task currently has.  For that, we force the root-task's sid
+	 * and all references to it from other tasks (via sid and
+	 * pgid), to 0. Later, the feeder will substitute the
+	 * cooridnator's sid for them.
 	 *
 	 * (Note that this still works even if the coordinator's sid
 	 * is "used" by a restarting task: a new-pidns restart will
 	 * fail because the pid is in use, and in an old-pidns restart
 	 * the task will be assigned a new pid anyway).
+	 *
+	 * If we restart with --no-pidns, we'll add a ghost task below
+	 * whose pid will be used instead of these zeroed entried.
 	 */
 
 	/* forcing root_sid to -1, will make comparisons below fail */
@@ -1288,15 +1325,10 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 		else if (!ckpt_valid_pid(ctx, pids_arr[i].vpgid, "pgid", i))
 			return -1;
 
-		/* zero references to root_sid (root_sid != root_pid) */
-		if (pids_arr[i].vsid == root_sid) {
-			task->flags |= TASK_ZERO_SID;
+		if (pids_arr[i].vsid == root_sid)
 			pids_arr[i].vsid = 0;
-		}
-		if (pids_arr[i].vpgid == root_sid) {
-			task->flags |= TASK_ZERO_PGID;
+		if (pids_arr[i].vpgid == root_sid)
 			pids_arr[i].vpgid = 0;
-		}
 
 		task->pid = pids_arr[i].vpid;
 		task->ppid = pids_arr[i].vppid;
@@ -1324,6 +1356,9 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 
 		sid = pids_arr[i].vsid;
 
+		/* Remember if we find any vsid/vpgid - see below */
+		if (pids_arr[i].vsid == 0 || pids_arr[i].vpgid == 0)
+			zero_pid = 1;
 		/*
 		 * An unaccounted-for sid belongs to a task that was a
 		 * session leader and died. We can safe set its parent
@@ -1360,6 +1395,27 @@ static int ckpt_init_tree(struct ckpt_ctx *ctx)
 			return -1;
 	}
 
+	/*
+	 * Zero sid/pgid is disallowed in --no-pidns mode. If there
+	 * were any, we invent a new ghost-zero task and substitute
+	 * its pid for those any sid/pgid.
+	 */
+	if (zero_pid && !ctx->args->pidns) {
+		zero_pid = ckpt_zero_pid(ctx);
+		if (zero_pid < 0)
+			return -1;
+		for (i = 0; i < pids_nr; i++) {
+			if (pids_arr[i].vsid == 0) {
+				pids_arr[i].vsid = zero_pid;
+				pids_arr[i].vppid = zero_pid;
+			}
+			if (pids_arr[i].vpgid == 0) {
+				pids_arr[i].vpgid = zero_pid;
+				pids_arr[i].vppid = zero_pid;
+			}
+		}
+	}
+
 	/* mark root task(s), and set its "creator" to be zero_task */
 	ckpt_init_task(ctx)->flags |= TASK_ROOT;
 	ckpt_init_task(ctx)->creator = &zero_task;
@@ -1534,7 +1590,7 @@ static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task)
 {
 	struct task *session = hash_lookup(ctx, task->sid);
 	struct task *holder = &ctx->tasks_arr[ctx->tasks_nr++];
-	int n = 0;
+	pid_t pid;
 
 	if (ctx->tasks_nr > ctx->tasks_max) {
 		/* shouldn't happen, beacuse we prepared enough */
@@ -1542,27 +1598,15 @@ static int ckpt_placeholder_task(struct ckpt_ctx *ctx, struct task *task)
 		return -1;
 	}
 
-	/*
-	 * allocate an unused pid for the placeholder
-	 * (this will become inefficient if pid-space is exhausted)
-	 */
-	do {
-		if (ctx->tasks_pid == INT_MAX)
-			ctx->tasks_pid = 2;
-		else
-			ctx->tasks_pid++;
-
-		if (n++ == INT_MAX) {	/* ohhh... */
-			ckpt_err("pid namsepace exhausted");
-			return -1;
-		}
-	} while (hash_lookup(ctx, ctx->tasks_pid));
+	pid = ckpt_alloc_pid(ctx);
+	if (pid < 0)
+		return -1;
 
 	holder->flags = TASK_DEAD;
 
-	holder->pid = ctx->tasks_pid;
+	holder->pid = pid;
 	holder->ppid = ckpt_init_task(ctx)->pid;
-	holder->tgid = holder->pid;
+	holder->tgid = pid;
 	holder->sid = task->sid;
 
 	holder->children = NULL;
@@ -2097,23 +2141,6 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 		}
 	}
 
-	if (!ctx->args->pidns) {
-		/*
-		 * If a task's {sid,pgid} was zeroed out (in ckpt_init_tree)
-		 * then substitute the coordinator's sid for it now. (This
-		 * should leave no more 0's in restart of subtree-checkpoint).
-		 *
-		 * NOTE: thanks to the construction of tasks_arr[], the first
-		 * ctx->pid_nr entries in both arrays match (the same pids).
-		 */
-		for (m = 0; m < ctx->pids_nr; m++) {
-			if (ctx->tasks_arr[m].flags & TASK_ZERO_SID)
-				ctx->copy_arr[m].vsid = coord_sid;
-			if (ctx->tasks_arr[m].flags & TASK_ZERO_PGID)
-				ctx->copy_arr[m].vpgid = coord_sid;
-		}
-	}
-
 	memcpy(ctx->pids_arr, ctx->copy_arr, len);
 
 #ifdef CHECKPOINT_DEBUG
-- 
1.6.0.4
