From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] restart debug: splatter more ckpt_debugs about
Date: Tue, 29 Sep 2009 11:54:15 -0500
Message-ID: <20090929165415.GB10114@us.ibm.com>
References: <20090929165342.GA10076@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090929165342.GA10076-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Alas they uglify the error paths during restart, but I can't
count on two hands the number of times I've had to add these and
recompile to find one silly bug or other, so I suggest that it
may be worth having these in the code anyway.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |   50 +++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 1085ed5..ebdd5ba 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -662,6 +662,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
+			ckpt_debug("could not find task %d\n", pid);
 			restore_notify_error(ctx, -ESRCH);
 			return -ESRCH;
 		}
@@ -685,6 +686,7 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 	ckpt_debug("active %d < %d (ret %d)\n",
 		   ctx->active_pid, ctx->nr_pids, ret);
 	if (!ret && ckpt_test_ctx_error(ctx)) {
+		ckpt_debug("wait_event_interruptible returned %d\n", ret);
 		force_sig(SIGKILL, current);
 		ret = -EBUSY;
 	}
@@ -827,20 +829,25 @@ static int do_restore_task(void)
 
 	/* wait for our turn, do the restore, and tell next task in line */
 	ret = wait_task_active(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("wait_task_active returned %d\n", ret);
 		goto out;
+	}
 
 	ckpt_debug_log_running(ctx);
 
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
+		ckpt_debug("restore_task returned %d\n", ret);
 		ret = zombie;
 		goto out;
 	}
 
 	ret = restore_activate_next(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_activate_next returned %d\n", ret);
 		goto out;
+	}
 
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
@@ -855,6 +862,8 @@ static int do_restore_task(void)
 
 	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
+	if (ret)
+		ckpt_debug("wait_task_sync returned %d\n", ret);
  out:
 	old_ctx = xchg(&current->checkpoint_ctx, NULL);
 	if (old_ctx)
@@ -970,12 +979,14 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 
 	BUG_ON(ctx->active_pid != -1);
 	ret = restore_activate_next(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_activate_next returned %d\n", ret);
 		return ret;
+	}
 
 	ret = wait_for_completion_interruptible(&ctx->complete);
 
-	ckpt_debug("final sync kflags %#lx\n", ctx->kflags);
+	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
 	/*
 	 * Usually when restart fails, the restarting task will first
 	 * set @ctx->errno before waking us up. In the rare event that
@@ -1051,18 +1062,24 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	ckpt_debug_log_running(ctx);
 
 	ret = restore_read_header(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_read_header returned %d\n", ret);
 		return ret;
+	}
 	ret = restore_read_tree(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_read_tree returned %d\n", ret);
 		return ret;
+	}
 
 	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
 		return -EINVAL;
 
 	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("init_restart_ctx returned %d\n", ret);
 		return ret;
+	}
 
 	/*
 	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
@@ -1094,8 +1111,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	} else {
 		/* prepare descendants' t->checkpoint_ctx point to coord */
 		ret = prepare_descendants(ctx, ctx->root_task);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_debug("prepare_descendants returned %d", ret);
 			goto out;
+		}
 
 		/* tell tasks we're ready for them to dec  ctx->nr_running */
 		wake_up_all(&ctx->waitq);
@@ -1108,17 +1127,23 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 		/* wait for all other tasks to complete do_restore_task() */
 		ret = wait_all_tasks_finish(ctx);
-		if (ret < 0)
+		if (ret < 0) {
+			ckpt_debug("wait_all_tasks_finish returned %d", ret);
 			goto out;
+		}
 	}
 
 	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("deferqueue_run returned %d\n", ret);
 		goto out;
+	}
 
 	ret = restore_read_tail(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_read_tail returned %d\n", ret);
 		goto out;
+	}
 
 	if (ctx->uflags & RESTART_FROZEN) {
 		ret = cgroup_freezer_make_frozen(ctx->root_task);
@@ -1202,6 +1227,9 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 	else
 		ret = do_restore_task();
 
+	if (ret < 0)
+		ckpt_debug("ret %ld\n", ret);
+
 	/* restart(2) isn't idempotent: should not be auto-restarted */
 	if (ret == -ERESTARTSYS || ret == -ERESTARTNOINTR ||
 	    ret == -ERESTARTNOHAND || ret == -ERESTART_RESTARTBLOCK)
-- 
1.6.1
