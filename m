From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 12/17] use ckpt_error in checkpoint/restart.c
Date: Tue, 27 Oct 2009 17:46:22 -0500
Message-ID: <1256683587-23961-13-git-send-email-serge@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256683587-23961-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

In cases where f(x) always returns 0 or <0, I felt free to
remove ckpt_debugs in favor of ckpt_error() only on error.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |   90 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 59 insertions(+), 31 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 9b75de8..540b7f7 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -64,7 +64,7 @@ static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
 
 	s = kmalloc(sizeof(*s), GFP_KERNEL);
 	if (!s) {
-		ckpt_debug("no memory to register ?!\n");
+		ckpt_error(ctx, "no memory to register ?!\n");
 		return -ENOMEM;
 	}
 	s->pid = current->pid;
@@ -197,13 +197,13 @@ static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 	len = h->len - sizeof(*h);
 	ptr = kzalloc(len + 1, GFP_KERNEL);
 	if (!ptr) {
-		ckpt_debug("insufficient memory to report image error\n");
+		ckpt_error(ctx, "insufficient memory to report image error\n");
 		return -ENOMEM;
 	}
 
 	ret = ckpt_kread(ctx, ptr, len);
 	if (ret >= 0) {
-		ckpt_debug("%s\n", &ptr[1]);
+		ckpt_error(ctx, "%s\n", &ptr[1]);
 		ret = -EIO;
 	}
 
@@ -715,7 +715,7 @@ static void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
 {
 	/* first to fail: notify everyone (racy but harmless) */
 	if (!ckpt_test_ctx_error(ctx)) {
-		ckpt_debug("setting restart error %d\n", errno); \
+		ckpt_error(ctx, "setting restart error %d\n", errno);
 		ckpt_set_ctx_error(ctx, errno);
 		complete(&ctx->complete);
 		wake_up_all(&ctx->waitq);
@@ -729,7 +729,8 @@ static void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
 */
 #define restore_notify_error(ctx, errno) \
 do { \
-	ckpt_debug("restart error %d, root pid %d\n", errno, ctx->root_pid); \
+	ckpt_error(ctx, "restart error %d, root pid %d\n", errno, \
+		   ctx->root_pid); \
 	_restore_notify_error(ctx, errno); \
 } while(0)
 
@@ -753,7 +754,8 @@ static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
 		task->checkpoint_ctx = ckpt_ctx_get(ctx);
 		ret = 0;
 	} else {
-		ckpt_debug("task %d has checkpoint_ctx\n", task_pid_vnr(task));
+		ckpt_error(ctx, "task %d has checkpoint_ctx\n",
+			   task_pid_vnr(task));
 		ret = 1;
 	}
 	task_unlock(task);
@@ -803,7 +805,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
-			ckpt_debug("could not find task %d\n", pid);
+			ckpt_error(ctx, "could not find task %d\n", pid);
 			restore_notify_error(ctx, -ESRCH);
 			return -ESRCH;
 		}
@@ -958,29 +960,38 @@ static int do_restore_task(void)
 	current->flags |= PF_RESTARTING;
 
 	ret = wait_sync_threads();
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "wait_sync_threads ret %d\n", ret);
 		goto out;
+	}
 
 	/* wait for our turn, do the restore, and tell next task in line */
 	ret = wait_task_active(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "wait_task_active ret %d\n", ret);
 		goto out;
+	}
 
 	restore_debug_running(ctx);
 
 	ret = pre_restore_task();
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "pre_restore_task ret %d\n", ret);
 		goto out;
+	}
 
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
+		ckpt_error(ctx, "restore_task ret %d\n", ret);
 		ret = zombie;
 		goto out;
 	}
 
 	ret = restore_activate_next(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "restore_activate_next ret %d\n", ret);
 		goto out;
+	}
 
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
@@ -1021,12 +1032,12 @@ static int __prepare_descendants(struct task_struct *task, void *data)
 	ckpt_debug("consider task %d\n", task_pid_vnr(task));
 
 	if (!ptrace_may_access(task, PTRACE_MODE_ATTACH)) {
-		ckpt_debug("stranger task %d\n", task_pid_vnr(task));
+		ckpt_error(ctx, "stranger task %d\n", task_pid_vnr(task));
 		return -EPERM;
 	}
 
 	if (task_ptrace(task) & PT_PTRACED) {
-		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
+		ckpt_error(ctx, "ptraced task %d\n", task_pid_vnr(task));
 		return -EBUSY;
 	}
 
@@ -1182,24 +1193,31 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	restore_debug_running(ctx);
 
 	ret = restore_read_header(ctx);
-	ckpt_debug("restore header: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "restore header: %d\n", ret);
 		return ret;
+	}
 	ret = restore_container(ctx);
-	ckpt_debug("restore container: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "restore container: %d\n", ret);
 		return ret;
+	}
 	ret = restore_read_tree(ctx);
-	ckpt_debug("restore tree: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "restore tree: %d\n", ret);
 		return ret;
+	}
 
-	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
+	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1) {
+		ckpt_error(ctx, "self-restart but nr_pids=%d\n", ctx->nr_pids);
 		return -EINVAL;
+	}
 
 	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "init_restart_ctx returned %d\n", ret);
 		return ret;
+	}
 
 	/*
 	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
@@ -1212,7 +1230,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		 * We are a bad-behaving descendant: an ancestor must
 		 * have prepare_descendants() us as part of a restart.
 		 */
-		ckpt_debug("coord already has checkpoint_ctx\n");
+		ckpt_error(ctx, "coord already has checkpoint_ctx\n");
 		return -EBUSY;
 	}
 
@@ -1224,35 +1242,45 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 	if (ctx->uflags & RESTART_TASKSELF) {
 		ret = pre_restore_task();
-		ckpt_debug("pre restore task: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_error(ctx, "pre restore task: %d\n", ret);
 			goto out;
+		}
 		ret = restore_task(ctx);
 		ckpt_debug("restore task: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_error(ctx, "restore task: %d\n", ret);
 			goto out;
+		}
 	} else {
 		/* prepare descendants' t->checkpoint_ctx point to coord */
 		ret = prepare_descendants(ctx, ctx->root_task);
 		ckpt_debug("restore prepare: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_error(ctx, "restore prepare: %d\n", ret);
 			goto out;
+		}
 		/* wait for all other tasks to complete do_restore_task() */
 		ret = wait_all_tasks_finish(ctx);
 		ckpt_debug("restore finish: %d\n", ret);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_error(ctx, "wait_all_tasks_finish: %d\n", ret);
 			goto out;
+		}
 	}
 
 	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
 	ckpt_debug("restore deferqueue: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "restore deferqueue: %d\n", ret);
 		goto out;
+	}
 
 	ret = restore_read_tail(ctx);
-	ckpt_debug("restore tail: %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_error(ctx, "restore tail: %d\n", ret);
 		goto out;
+	}
 
 	if (ctx->uflags & RESTART_FROZEN) {
 		ret = cgroup_freezer_make_frozen(ctx->root_task);
@@ -1364,7 +1392,7 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 	if (!ctx || (ctx->uflags & RESTART_TASKSELF)) {
 		if (ret < 0) {
 			/* partial restore is undefined: terminate */
-			ckpt_debug("restart err %ld, exiting\n", ret);
+			ckpt_error(ctx, "restart err %ld, exiting\n", ret);
 			force_sig(SIGKILL, current);
 		} else {
 			ret = restore_retval();
-- 
1.6.1
