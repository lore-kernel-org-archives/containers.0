From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/5] c/r: simplify logic of tracking restarting tasks
Date: Wed, 30 Sep 2009 21:47:10 -0400
Message-ID: <1254361634-30076-2-git-send-email-orenl@librato.com>
References: <1254361634-30076-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254361634-30076-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

Instead of playing tricks with xchg() of task->checkpoint_ctx, use the
task_{lock,unlock} to protect changes to that pointer. This simplifies
the logic since we no longer need to check for races (and old_ctx).

The remaining changes include cleanup, and unification of common code
to handle errors during restart, and some debug statements.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/restart.c       |  170 ++++++++++++++++++++++----------------------
 checkpoint/sys.c           |    6 +-
 include/linux/checkpoint.h |    2 +-
 kernel/fork.c              |    6 +-
 4 files changed, 92 insertions(+), 92 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 543b380..5d936cf 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -529,17 +529,54 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
 
 static inline void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
 {
-	ckpt_set_ctx_error(ctx, errno);
-	complete(&ctx->complete);
+	/* first to fail: notify everyone (racy but harmless) */
+	if (!ckpt_test_ctx_error(ctx)) {
+		ckpt_debug("setting restart error %d\n", errno); \
+		ckpt_set_ctx_error(ctx, errno);
+		complete(&ctx->complete);
+		wake_up_all(&ctx->waitq);
+		wake_up_all(&ctx->ghostq);
+	}
 }
 
 /* Need to call ckpt_debug such that it will get the correct source location */
 #define restore_notify_error(ctx, errno) \
 do { \
-	ckpt_debug("ctx root pid %d err %d", ctx->root_pid, errno); \
+	ckpt_debug("restart error %d, root pid %d\n", errno, ctx->root_pid); \
 	_restore_notify_error(ctx, errno); \
 } while(0)
 
+static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
+{
+	struct ckpt_ctx *ctx;
+
+	task_lock(task);
+	ctx = ckpt_ctx_get(task->checkpoint_ctx);
+	task_unlock(task);
+	return ctx;
+}
+
+/* returns 1 on success, 0 otherwise */
+static int set_task_ctx(struct task_struct *task, struct ckpt_ctx *ctx)
+{
+	struct ckpt_ctx *old;
+	int ret = 1;
+
+	task_lock(task);
+	if (!ctx || !task->checkpoint_ctx) {
+		old = task->checkpoint_ctx;
+		task->checkpoint_ctx = ckpt_ctx_get(ctx);
+	} else {
+		ckpt_debug("task %d has prior checkpoint_ctx\n",
+			   task_pid_vnr(task));
+		old = NULL;
+		ret = 0;
+	}
+	task_unlock(task);
+	ckpt_ctx_put(old);
+	return ret;
+}
+
 static void restore_task_done(struct ckpt_ctx *ctx)
 {
 	if (atomic_dec_and_test(&ctx->nr_total))
@@ -570,6 +607,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
+			ckpt_debug("could not find task %d\n", pid);
 			restore_notify_error(ctx, -ESRCH);
 			return -ESRCH;
 		}
@@ -590,12 +628,10 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 	ret = wait_event_interruptible(ctx->waitq,
 				       is_task_active(ctx, pid) ||
 				       ckpt_test_ctx_error(ctx));
-	ckpt_debug("active %d < %d (ret %d)\n",
-		   ctx->active_pid, ctx->nr_pids, ret);
-	if (!ret && ckpt_test_ctx_error(ctx)) {
-		force_sig(SIGKILL, current);
+	ckpt_debug("active %d < %d (ret %d, errno %d)\n",
+		   ctx->active_pid, ctx->nr_pids, ret, ctx->errno);
+	if (!ret && ckpt_test_ctx_error(ctx))
 		ret = -EBUSY;
-	}
 	return ret;
 }
 
@@ -603,17 +639,17 @@ static int wait_task_sync(struct ckpt_ctx *ctx)
 {
 	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
 	wait_event_interruptible(ctx->waitq, ckpt_test_ctx_complete(ctx));
-	if (ckpt_test_ctx_error(ctx)) {
-		force_sig(SIGKILL, current);
+	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
+	if (ckpt_test_ctx_error(ctx))
 		return -EBUSY;
-	}
 	return 0;
 }
 
+/* grabs a reference to the @ctx on success; caller should free */
 static struct ckpt_ctx *wait_checkpoint_ctx(void)
 {
 	DECLARE_WAIT_QUEUE_HEAD(waitq);
-	struct ckpt_ctx *ctx, *old_ctx;
+	struct ckpt_ctx *ctx;
 	int ret;
 
 	/*
@@ -621,32 +657,15 @@ static struct ckpt_ctx *wait_checkpoint_ctx(void)
 	 * reference to its restart context.
 	 */
 	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("wait_checkpoint_ctx: failed (%d)\n", ret);
 		return ERR_PTR(ret);
+	}
 
-	ctx = xchg(&current->checkpoint_ctx, NULL);
-	if (!ctx)
+	ctx = get_task_ctx(current);
+	if (!ctx) {
+		ckpt_debug("wait_checkpoint_ctx: checkpoint_ctx missing\n");
 		return ERR_PTR(-EAGAIN);
-	ckpt_ctx_get(ctx);
-
-	/*
-	 * Put the @ctx back on our task_struct. If an ancestor tried
-	 * to prepare_descendants() on us (although extremly unlikely)
-	 * we will encounter the ctx that he xchg()ed there and bail.
-	 */
-	old_ctx = xchg(&current->checkpoint_ctx, ctx);
-	if (old_ctx) {
-		ckpt_debug("self-set of checkpoint_ctx failed\n");
-
-		/* alert coordinator of unexpected ctx */
-		restore_notify_error(old_ctx, -EAGAIN);
-		ckpt_ctx_put(old_ctx);
-
-		/* alert our coordinator that we bail */
-		restore_notify_error(ctx, -EAGAIN);
-		ckpt_ctx_put(ctx);
-
-		ctx = ERR_PTR(-EAGAIN);
 	}
 
 	return ctx;
@@ -655,6 +674,7 @@ static struct ckpt_ctx *wait_checkpoint_ctx(void)
 static int do_ghost_task(void)
 {
 	struct ckpt_ctx *ctx;
+	int ret;
 
 	ctx = wait_checkpoint_ctx();
 	if (IS_ERR(ctx))
@@ -662,9 +682,11 @@ static int do_ghost_task(void)
 
 	current->flags |= PF_RESTARTING;
 
-	wait_event_interruptible(ctx->ghostq,
-				 all_tasks_activated(ctx) ||
-				 ckpt_test_ctx_error(ctx));
+	ret = wait_event_interruptible(ctx->ghostq,
+				       all_tasks_activated(ctx) ||
+				       ckpt_test_ctx_error(ctx));
+	if (ret < 0)
+		restore_notify_error(ctx, ret);
 
 	current->exit_signal = -1;
 	ckpt_ctx_put(ctx);
@@ -675,7 +697,7 @@ static int do_ghost_task(void)
 
 static int do_restore_task(void)
 {
-	struct ckpt_ctx *ctx, *old_ctx;
+	struct ckpt_ctx *ctx;
 	int zombie, ret;
 
 	ctx = wait_checkpoint_ctx();
@@ -713,18 +735,11 @@ static int do_restore_task(void)
 	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
  out:
-	old_ctx = xchg(&current->checkpoint_ctx, NULL);
-	if (old_ctx)
-		ckpt_ctx_put(old_ctx);
-
-	/* if we're first to fail - notify others */
-	if (ret < 0 && !ckpt_test_ctx_error(ctx)) {
+	if (ret < 0)
 		restore_notify_error(ctx, ret);
-		wake_up_all(&ctx->waitq);
-		wake_up_all(&ctx->ghostq);
-	}
 
 	current->flags &= ~PF_RESTARTING;
+	set_task_ctx(current, NULL);
 	ckpt_ctx_put(ctx);
 	return ret;
 }
@@ -742,17 +757,14 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 	struct task_struct *leader = root;
 	struct task_struct *parent = NULL;
 	struct task_struct *task = root;
-	struct ckpt_ctx *old_ctx;
 	int nr_pids = 0;
-	int ret = 0;
+	int ret = -EBUSY;
 
 	read_lock(&tasklist_lock);
 	while (1) {
 		ckpt_debug("consider task %d\n", task_pid_vnr(task));
-		if (task_ptrace(task) & PT_PTRACED) {
-			ret = -EBUSY;
+		if (task_ptrace(task) & PT_PTRACED)
 			break;
-		}
 		/*
 		 * Set task->checkpoint_ctx of all non-zombie descendants.
 		 * If a descendant already has a ->checkpoint_ctx, it
@@ -764,14 +776,8 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 		 * already be set.
 		 */
 		if (!task->exit_state) {
-			ckpt_ctx_get(ctx);
-			old_ctx = xchg(&task->checkpoint_ctx, ctx);
-			if (old_ctx) {
-				ckpt_debug("bad task %d\n",task_pid_vnr(task));
-				ckpt_ctx_put(old_ctx);
-				ret = -EAGAIN;
+			if (!set_task_ctx(task, ctx))
 				break;
-			}
 			ckpt_debug("prepare task %d\n", task_pid_vnr(task));
 			wake_up_process(task);
 			nr_pids++;
@@ -799,8 +805,10 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 		if (task == root) {
 			/* in case root task is multi-threaded */
 			root = task = next_thread(task);
-			if (root == leader)
+			if (root == leader) {
+				ret = 0;
 				break;
+			}
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -829,8 +837,7 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 		return ret;
 
 	ret = wait_for_completion_interruptible(&ctx->complete);
-
-	ckpt_debug("final sync kflags %#lx\n", ctx->kflags);
+	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
 	/*
 	 * Usually when restart fails, the restarting task will first
 	 * set @ctx->errno before waking us up. In the rare event that
@@ -899,13 +906,14 @@ static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
 
 static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 {
-	struct ckpt_ctx *old_ctx;
 	int ret;
 
 	ret = restore_read_header(ctx);
+	ckpt_debug("restore header: %d\n", ret);
 	if (ret < 0)
 		return ret;
 	ret = restore_read_tree(ctx);
+	ckpt_debug("restore tree: %d\n", ret);
 	if (ret < 0)
 		return ret;
 
@@ -920,45 +928,42 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
 	 * prepare_descendants() on us, it will fail. Furthermore,
 	 * that ancestor won't proceed deeper to interfere with our
-	 * descendants that are restarting (e.g. by xchg()ing their
-	 * ->checkpoint_ctx pointer temporarily).
+	 * descendants that are restarting.
 	 */
-	ckpt_ctx_get(ctx);
-	old_ctx = xchg(&current->checkpoint_ctx, ctx);
-	if (old_ctx) {
+	if (!set_task_ctx(current, ctx)) {
 		/*
 		 * We are a bad-behaving descendant: an ancestor must
-		 * have done prepare_descendants() on us as part of a
-		 * restart. Oh, well ... alert ancestor (coordinator)
-		 * with an error on @old_ctx.
+		 * have prepare_descendants() us as part of a restart.
 		 */
-		ckpt_debug("bad behaving checkpoint_ctx\n");
-		restore_notify_error(old_ctx, -EBUSY);
-		ckpt_ctx_put(old_ctx);
-		ret = -EBUSY;
-		goto out;
+		ckpt_debug("coord already has checkpoint_ctx\n");
+		return -EBUSY;
 	}
 
 	if (ctx->uflags & RESTART_TASKSELF) {
 		ret = restore_task(ctx);
+		ckpt_debug("restore task: %d\n", ret);
 		if (ret < 0)
 			goto out;
 	} else {
 		/* prepare descendants' t->checkpoint_ctx point to coord */
 		ret = prepare_descendants(ctx, ctx->root_task);
+		ckpt_debug("restore prepare: %d\n", ret);
 		if (ret < 0)
 			goto out;
 		/* wait for all other tasks to complete do_restore_task() */
 		ret = wait_all_tasks_finish(ctx);
+		ckpt_debug("restore finish: %d\n", ret);
 		if (ret < 0)
 			goto out;
 	}
 
 	ret = deferqueue_run(ctx->deferqueue);  /* run deferred work */
+	ckpt_debug("restore deferqueue: %d\n", ret);
 	if (ret < 0)
 		goto out;
 
 	ret = restore_read_tail(ctx);
+	ckpt_debug("restore tail: %d\n", ret);
 	if (ret < 0)
 		goto out;
 
@@ -974,14 +979,8 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 	if (!(ctx->uflags & RESTART_TASKSELF))
 		wake_up_all(&ctx->waitq);
-	/*
-	 * If an ancestor attempts to prepare_descendants() on us, it
-	 * xchg()s our ->checkpoint_ctx, and free it. Our @ctx will,
-	 * instead, point to the ctx that said ancestor placed.
-	 */
-	ctx = xchg(&current->checkpoint_ctx, NULL);
-	ckpt_ctx_put(ctx);
 
+	set_task_ctx(current, NULL);
 	return ret;
 }
 
@@ -1070,6 +1069,7 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 		}
 	}
 
+	ckpt_debug("sys_restart returns %ld\n", ret);
 	return ret;
 }
 
@@ -1082,7 +1082,7 @@ void exit_checkpoint(struct task_struct *tsk)
 	struct ckpt_ctx *ctx;
 
 	/* no one else will touch this, because @tsk is dead already */
-	ctx = xchg(&tsk->checkpoint_ctx, NULL);
+	ctx = tsk->checkpoint_ctx;
 
 	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 76a3fa9..77613d7 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -263,9 +263,11 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	return ERR_PTR(err);
 }
 
-void ckpt_ctx_get(struct ckpt_ctx *ctx)
+struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx)
 {
-	atomic_inc(&ctx->refcount);
+	if (ctx)
+		atomic_inc(&ctx->refcount);
+	return ctx;
 }
 
 void ckpt_ctx_put(struct ckpt_ctx *ctx)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 5294a96..b7f1796 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -134,7 +134,7 @@ extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
 extern int ckpt_obj_reserve(struct ckpt_ctx *ctx);
 
-extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
+extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
diff --git a/kernel/fork.c b/kernel/fork.c
index 57118e4..0e226f5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1188,10 +1188,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 #ifdef CONFIG_CHECKPOINT
 	/* If parent is restarting, child should be too */
-	if (unlikely(current->checkpoint_ctx)) {
-		p->checkpoint_ctx = current->checkpoint_ctx;
-		ckpt_ctx_get(p->checkpoint_ctx);
-	}
+	if (unlikely(current->checkpoint_ctx))
+		p->checkpoint_ctx = ckpt_ctx_get(current->checkpoint_ctx);
 #endif
 	/*
 	 * The task hasn't been attached yet, so its cpus_allowed mask will
-- 
1.6.0.4
