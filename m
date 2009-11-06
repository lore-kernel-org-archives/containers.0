From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/7] restart.c: use ckpt_err
Date: Thu,  5 Nov 2009 18:00:14 -0600
Message-ID: <1257465619-1777-3-git-send-email-serue@us.ibm.com>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Changelog:
	Nove 4: update restart.c ckpt_err usage

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |   81 +++++++++++++++++++++++++++++++++++---------------
 1 files changed, 57 insertions(+), 24 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 130b4b2..e1bd0ad 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -64,7 +64,7 @@ static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
 
 	s = kmalloc(sizeof(*s), GFP_KERNEL);
 	if (!s) {
-		ckpt_debug("no memory to register ?!\n");
+		ckpt_err(ctx, 0, "no memory to register ?!\n");
 		return -ENOMEM;
 	}
 	s->pid = current->pid;
@@ -197,13 +197,13 @@ static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 	len = h->len - sizeof(*h);
 	ptr = kzalloc(len + 1, GFP_KERNEL);
 	if (!ptr) {
-		ckpt_debug("insufficient memory to report image error\n");
+		ckpt_err(ctx, 0, "insufficient memory to report image error\n");
 		return -ENOMEM;
 	}
 
 	ret = ckpt_kread(ctx, ptr, len);
 	if (ret >= 0) {
-		ckpt_debug("%s\n", &ptr[1]);
+		ckpt_err(ctx, 0, "%(S)Error recorded in image\n", &ptr[1]);
 		ret = -EIO;
 	}
 
@@ -757,7 +757,8 @@ static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
 		task->checkpoint_ctx = ckpt_ctx_get(ctx);
 		ret = 0;
 	} else {
-		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
+		ckpt_err(ctx, 0, "task %d already has checkpoint_ctx\n",
+			 task_pid_vnr(task));
 		ret = 1;
 	}
 	task_unlock(task);
@@ -807,7 +808,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
-			ckpt_debug("could not find task %d\n", pid);
+			ckpt_err(ctx, 0, "could not find task %d\n", pid);
 			restore_notify_error(ctx, -ESRCH);
 			return -ESRCH;
 		}
@@ -962,29 +963,38 @@ static int do_restore_task(void)
 	current->flags |= PF_RESTARTING;
 
 	ret = wait_sync_threads();
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "wait_sync_threads\n");
 		goto out;
+	}
 
 	/* wait for our turn, do the restore, and tell next task in line */
 	ret = wait_task_active(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "wait_task_active\n");
 		goto out;
+	}
 
 	restore_debug_running(ctx);
 
 	ret = pre_restore_task();
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "pre_restore_task\n");
 		goto out;
+	}
 
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
 		ret = zombie;
+		ckpt_err(ctx, ret, "restore_task\n");
 		goto out;
 	}
 
 	ret = restore_activate_next(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "restore_activate_next\n");
 		goto out;
+	}
 
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
@@ -1025,12 +1035,12 @@ static int __prepare_descendants(struct task_struct *task, void *data)
 	ckpt_debug("consider task %d\n", task_pid_vnr(task));
 
 	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
-		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
+		ckpt_err(ctx, 0, "stranger task %d\n", task_pid_vnr(task));
 		return -EPERM;
 	}
 
 	if (task_ptrace(task) & PT_PTRACED) {
-		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
+		ckpt_err(ctx, 0, "ptraced task %d\n", task_pid_vnr(task));
 		return -EBUSY;
 	}
 
@@ -1187,23 +1197,34 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 	ret = restore_read_header(ctx);
 	ckpt_debug("restore header: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "restore header\n");
 		return ret;
+	}
 	ret = restore_container(ctx);
 	ckpt_debug("restore container: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "restore container\n");
 		return ret;
+	}
 	ret = restore_read_tree(ctx);
 	ckpt_debug("restore tree: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "restore tree\n");
 		return ret;
+	}
 
-	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
+	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1) {
+		ckpt_err(ctx, 0, "self-restart but nr_pids=%d\n",
+			 ctx->nr_pids);
 		return -EINVAL;
+	}
 
 	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "init_restart_ctx\n");
 		return ret;
+	}
 
 	/*
 	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
@@ -1216,7 +1237,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		 * We are a bad-behaving descendant: an ancestor must
 		 * have prepare_descendants() us as part of a restart.
 		 */
-		ckpt_debug("coord already has checkpoint_ctx\n");
+		ckpt_err(ctx, 0, "coord already has checkpoint_ctx\n");
 		return -EBUSY;
 	}
 
@@ -1229,34 +1250,46 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	if (ctx->uflags & RESTART_TASKSELF) {
 		ret = pre_restore_task();
 		ckpt_debug("pre restore task: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "pre restore task\n");
 			goto out;
+		}
 		ret = restore_task(ctx);
 		ckpt_debug("restore task: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "restore task\n");
 			goto out;
+		}
 	} else {
 		/* prepare descendants' t->checkpoint_ctx point to coord */
 		ret = prepare_descendants(ctx, ctx->root_task);
 		ckpt_debug("restore prepare: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "prepare_descendants\n");
 			goto out;
+		}
 		/* wait for all other tasks to complete do_restore_task() */
 		ret = wait_all_tasks_finish(ctx);
 		ckpt_debug("restore finish: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "wait_all_tasks_finish\n");
 			goto out;
+		}
 	}
 
 	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
 	ckpt_debug("restore deferqueue: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "restore deferqueue\n");
 		goto out;
+	}
 
 	ret = restore_read_tail(ctx);
 	ckpt_debug("restore tail: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "restore tail\n");
 		goto out;
+	}
 
 	if (ctx->uflags & RESTART_FROZEN) {
 		ret = cgroup_freezer_make_frozen(ctx->root_task);
@@ -1368,7 +1401,7 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 	if (!ctx || (ctx->uflags & RESTART_TASKSELF)) {
 		if (ret < 0) {
 			/* partial restore is undefined: terminate */
-			ckpt_debug("restart err %ld, exiting\n", ret);
+			ckpt_err(ctx, ret, "restart error, exiting\n");
 			force_sig(SIGKILL, current);
 		} else {
 			ret = restore_retval();
-- 
1.6.1
