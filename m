From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/2] c/r: tighten logic to protect against bogus pids in input
Date: Tue, 25 Aug 2009 02:09:24 -0400
Message-ID: <1251180567-21957-2-git-send-email-orenl@librato.com>
References: <1251180567-21957-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251180567-21957-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

During restart, each process that completes its restore will wake up
the next process in line, using the pid provided in the image file.
A malicious user could provide bogus pids and cause arbitrary tasks to
be woken up.

This patch tightens the checks and requires that to wake-up a task by
pid during restart, the target task must belong to (have) the same
restart context (task->checkpoint_ctx) as the current process.

Also, update in-code comments about restart and zombie logic.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/restart.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 856a416..ea49203 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -462,12 +462,12 @@ static int restore_read_tree(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 
 	ret = -EINVAL;
-	if (h->nr_tasks < 0)
+	if (h->nr_tasks <= 0)
 		goto out;
 
 	ctx->nr_pids = h->nr_tasks;
 	size = sizeof(*ctx->pids_arr) * ctx->nr_pids;
-	if (size < 0)		/* overflow ? */
+	if (size <= 0)		/* overflow ? */
 		goto out;
 
 	ctx->pids_arr = kmalloc(size, GFP_KERNEL);
@@ -520,8 +520,11 @@ int ckpt_activate_next(struct ckpt_ctx *ctx)
 
 	rcu_read_lock();
 	task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
-	if (task)
+	/* target task must have same restart context */
+	if (task && task->checkpoint_ctx == ctx)
 		wake_up_process(task);
+	else
+		task = NULL;
 	rcu_read_unlock();
 
 	if (!task) {
@@ -568,9 +571,8 @@ static int do_restore_task(void)
 	int ret;
 
 	/*
-	 * Wait for coordinator to make become visible, then grab a
-	 * reference to its restart context. If we're the last task to
-	 * do it, notify the coordinator.
+	 * Wait for coordinator to become visible, then grab a
+	 * reference to its restart context.
 	 */
 	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
 	if (ret < 0)
@@ -610,8 +612,9 @@ static int do_restore_task(void)
 		goto out;
 
 	/*
-	 * zombie: we're done here; Save @ctx on task_struct, to be
-	 * used to ckpt_activate_next(), and released, from do_exit().
+	 * zombie: we're done here; do_exit() will notice the @ctx on
+	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
+	 * will call ckpt_activate_next() and release the @ctx.
 	 */
 	if (ret)
 		do_exit(current->exit_code);
@@ -638,11 +641,11 @@ static int do_restore_task(void)
 }
 
 /**
- * prepare_descendants - set ->restart_tsk of all descendants
+ * prepare_descendants - set ->checkpoint_ctx of all descendants
  * @ctx: checkpoint context
  * @root: root process for restart
  *
- * Called by the coodinator to set the ->restart_tsk pointer of the
+ * Called by the coodinator to set the ->checkpoint_ctx pointer of the
  * root task and all its descendants.
  */
 static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
@@ -662,7 +665,7 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 			break;
 		}
 		/*
-		 * Set task->restart_tsk of all non-zombie descendants.
+		 * Set task->checkpoint_ctx of all non-zombie descendants.
 		 * If a descendant already has a ->checkpoint_ctx, it
 		 * must be a coordinator (for a different restart ?) so
 		 * we fail.
@@ -727,6 +730,7 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 
 	init_completion(&ctx->complete);
 
+	BUG_ON(ctx->active_pid != -1);
 	ret = ckpt_activate_next(ctx);
 	if (ret < 0)
 		return ret;
@@ -839,7 +843,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		if (ret < 0)
 			goto out;
 	} else {
-		/* prepare descendants' t->restart_tsk point to coord */
+		/* prepare descendants' t->checkpoint_ctx point to coord */
 		ret = prepare_descendants(ctx, ctx->root_task);
 		if (ret < 0)
 			goto out;
@@ -970,11 +974,12 @@ void exit_checkpoint(struct task_struct *tsk)
 {
 	struct ckpt_ctx *ctx;
 
-	ctx = tsk->checkpoint_ctx;
-	tsk->checkpoint_ctx = NULL;
+	/* no one else will touch this, because @tsk is dead already */
+	ctx = xchg(&tsk->checkpoint_ctx, NULL);
 
-	/* restarting zombies will acrivate next task in restart */
+	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
+		BUG_ON(ctx->active_pid == -1);
 		if (ckpt_activate_next(ctx) < 0)
 			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
 	}
-- 
1.6.0.4
