From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] c/r: correctly restore pgid
Date: Tue, 25 Aug 2009 02:09:25 -0400
Message-ID: <1251180567-21957-3-git-send-email-orenl@librato.com>
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
Cc: Oren Laadan <orenl-3n9FKfXVdfcggxPgtCmjjw@public.gmane.org>
List-Id: containers.vger.kernel.org

The main challenge with restoring the pgid of tasks is that the
original "owner" (the process with that pid) might have exited
already. I call these "ghost" pgids. 'mktree' does create these
processes, but they then exit without participating in the restart.

To solve this, this patch introduces a RESTART_GHOST flag, used for
"ghost" owners that are created only to pass their pgid to other
tasks. ('mktree' now makes them call restart(2) instead of exiting).

When a "ghost" task calls restart(2), it will be placed on a wait
queue until the restart completes and then exit. This guarantees that
the pgid that it owns remains available for all (regular) restarting
tasks for when they need it.

Regular tasks perform the restart as before, except that they also
now restore their old pgrp, which is guaranteed to exist.

Signed-off-by: Oren Laadan <orenl-3n9FKfXVdfcggxPgtCmjjw@public.gmane.org>
---
 checkpoint/process.c             |   81 ++++++++++++++++++-
 checkpoint/restart.c             |  158 ++++++++++++++++++++++++++------------
 checkpoint/sys.c                 |    3 +-
 include/linux/checkpoint.h       |    8 ++-
 include/linux/checkpoint_types.h |    6 +-
 5 files changed, 199 insertions(+), 57 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 40b2580..d3fd9e4 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -94,8 +94,8 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->exit_signal = t->exit_signal;
 		h->pdeath_signal = t->pdeath_signal;
 
-		h->set_child_tid = t->set_child_tid;
-		h->clear_child_tid = t->clear_child_tid;
+		h->set_child_tid = (unsigned long) t->set_child_tid;
+		h->clear_child_tid = (unsigned long) t->clear_child_tid;
 		save_task_robust_futex_list(h, t);
 	}
 
@@ -472,8 +472,10 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 		t->exit_signal = h->exit_signal;
 		t->pdeath_signal = h->pdeath_signal;
 
-		t->set_child_tid = h->set_child_tid;
-		t->clear_child_tid = h->clear_child_tid;
+		t->set_child_tid =
+			(int __user *) (unsigned long) h->set_child_tid;
+		t->clear_child_tid =
+			(int __user *) (unsigned long) h->clear_child_tid;
 		restore_task_robust_futex_list(h);
 	}
 
@@ -717,6 +719,74 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_pgid(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task = current;
+	struct task_struct *ghost;
+	struct pid *pgrp;
+	pid_t pgid;
+	int ret;
+
+	/*
+	 * We enforce the following restrictions on restoring pgrp:
+	 *  1) Only thread group leaders restore pgrp
+	 *  2) Session leader cannot change own pgrp
+	 *  3) Owner of pgrp must belong to same restart tree
+	 *  4) Must have same session as other tasks in same pgrp
+	 *  5) Change must pass setpgid security callback
+	 *
+	 * TODO - check if we need additional restrictions ?
+	 */
+
+	if (!thread_group_leader(task))  /* (1) */
+		return 0;
+
+	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
+
+	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
+		return 0;
+
+	if (task->signal->leader)  /* (2) */
+		return -EINVAL;
+
+	ret = -EINVAL;
+	write_lock_irq(&tasklist_lock);
+
+	pgrp = find_vpid(pgid);
+
+	/*
+	 * Find a process that uses this pgid (it must exist if pgrp
+	 * exists): either the owner, or reference from sig/pgrp.
+	 */
+	ghost = pid_task(pgrp, PIDTYPE_PID);
+	if (!ghost || ghost->exit_state == EXIT_ZOMBIE)
+		ghost = pid_task(pgrp, PIDTYPE_SID);
+	if (!ghost || ghost->exit_state == EXIT_ZOMBIE)
+		ghost = pid_task(pgrp, PIDTYPE_PGID);
+
+	/*
+	 * Verify that the this pgrp "belongs" to our restart tree, by
+	 * comparing its ghost->checkpoint_ctx to ours. This prevents
+	 * malicious input from (guessing and) using unrelated pgrps.
+	 */
+	if (ghost && ghost->checkpoint_ctx == ctx) {  /* (3) */
+		if (task_session(task) != task_session(ghost))  /* (4) */
+			goto unlock;
+
+		ret = security_task_setpgid(task, pgid);  /* (5) */
+		if (ret < 0)
+			goto unlock;
+
+		change_pid(task, PIDTYPE_PGID, pgrp);
+
+		ret = 0;
+	}
+ unlock:
+	write_unlock_irq(&tasklist_lock);
+
+	return ret;
+}
+
 /* pre_restore_task - prepare the task for restore */
 static int pre_restore_task(struct ckpt_ctx *ctx)
 {
@@ -757,6 +827,9 @@ int restore_task(struct ckpt_ctx *ctx)
 	if (ret)
 		goto out;
 
+	ret = restore_task_pgid(ctx);
+	if (ret < 0)
+		goto out;
 	ret = restore_task_objs(ctx);
 	ckpt_debug("objs %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index ea49203..417795e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -481,6 +481,11 @@ static int restore_read_tree(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static inline int all_tasks_activated(struct ckpt_ctx *ctx)
+{
+	return (ctx->active_pid == ctx->nr_pids);
+}
+
 static inline pid_t get_active_pid(struct ckpt_ctx *ctx)
 {
 	int active = ctx->active_pid;
@@ -492,44 +497,56 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
 	return get_active_pid(ctx) == pid;
 }
 
-static inline void _ckpt_notify_error(struct ckpt_ctx *ctx)
+static inline void _restore_notify_error(struct ckpt_ctx *ctx)
 {
 	ckpt_set_ctx_error(ctx);
 	complete(&ctx->complete);
 }
 
 /* Need to call ckpt_debug such that it will get the correct source location */
-#define ckpt_notify_error(ctx) \
+#define restore_notify_error(ctx) \
 do { \
 	ckpt_debug("ctx with root pid %d (%p)", ctx->root_pid, ctx); \
-	_ckpt_notify_error(ctx); \
+	_restore_notify_error(ctx); \
 } while(0)
 
 
-int ckpt_activate_next(struct ckpt_ctx *ctx)
+static void restore_task_done(struct ckpt_ctx *ctx)
+{
+	if (atomic_dec_and_test(&ctx->nr_total))
+		complete(&ctx->complete);
+	BUG_ON(atomic_read(&ctx->nr_total) < 0);
+}
+
+static int restore_activate_next(struct ckpt_ctx *ctx)
 {
 	struct task_struct *task;
 	pid_t pid;
 
-	if (++ctx->active_pid >= ctx->nr_pids) {
-		complete(&ctx->complete);
-		return 0;
-	}
+	ctx->active_pid++;
 
-	pid = get_active_pid(ctx);
+	BUG_ON(ctx->active_pid > ctx->nr_pids);
 
-	rcu_read_lock();
-	task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
-	/* target task must have same restart context */
-	if (task && task->checkpoint_ctx == ctx)
-		wake_up_process(task);
-	else
-		task = NULL;
-	rcu_read_unlock();
+	if (!all_tasks_activated(ctx)) {
+		/* wake up next task in line to restore its state */
+		pid = get_active_pid(ctx);
 
-	if (!task) {
-		ckpt_notify_error(ctx);
-		return -ESRCH;
+		rcu_read_lock();
+		task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
+		/* target task must have same restart context */
+		if (task && task->checkpoint_ctx == ctx)
+			wake_up_process(task);
+		else
+			task = NULL;
+		rcu_read_unlock();
+
+		if (!task) {
+			restore_notify_error(ctx);
+			return -ESRCH;
+		}
+	} else {
+		/* wake up ghosts tasks so that they can terminate */
+		wake_up_all(&ctx->ghostq);
 	}
 
 	return 0;
@@ -564,7 +581,7 @@ static int wait_task_sync(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-static int do_restore_task(void)
+static struct ckpt_ctx *wait_checkpoint_ctx(void)
 {
 	DECLARE_WAIT_QUEUE_HEAD(waitq);
 	struct ckpt_ctx *ctx, *old_ctx;
@@ -576,11 +593,11 @@ static int do_restore_task(void)
 	 */
 	ret = wait_event_interruptible(waitq, current->checkpoint_ctx);
 	if (ret < 0)
-		return ret;
+		return ERR_PTR(ret);
 
 	ctx = xchg(&current->checkpoint_ctx, NULL);
 	if (!ctx)
-		return -EAGAIN;
+		return ERR_PTR(-EAGAIN);
 	ckpt_ctx_get(ctx);
 
 	/*
@@ -591,15 +608,50 @@ static int do_restore_task(void)
 	old_ctx = xchg(&current->checkpoint_ctx, ctx);
 	if (old_ctx) {
 		ckpt_debug("self-set of checkpoint_ctx failed\n");
+
 		/* alert coordinator of unexpected ctx */
-		ckpt_notify_error(old_ctx);
+		restore_notify_error(old_ctx);
 		ckpt_ctx_put(old_ctx);
+
 		/* alert our coordinator that we bail */
-		ckpt_notify_error(ctx);
+		restore_notify_error(ctx);
 		ckpt_ctx_put(ctx);
-		return -EAGAIN;
+
+		ctx = ERR_PTR(-EAGAIN);
 	}
 
+	return ctx;
+}
+
+static int do_ghost_task(void)
+{
+	struct ckpt_ctx *ctx;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	current->flags |= PF_RESTARTING;
+
+	wait_event_interruptible(ctx->ghostq,
+				 all_tasks_activated(ctx) ||
+				 ckpt_test_ctx_error(ctx));
+
+	current->exit_signal = -1;
+	do_exit(0);
+
+	/* NOT REACHED */
+}
+
+static int do_restore_task(void)
+{
+	struct ckpt_ctx *ctx, *old_ctx;
+	int zombie, ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
 	current->flags |= PF_RESTARTING;
 
 	/* wait for our turn, do the restore, and tell next task in line */
@@ -607,22 +659,26 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
-	ret = restore_task(ctx);
+	zombie = restore_task(ctx);
+	if (ret < 0) {
+		ret = zombie;
+		goto out;
+	}
+
+	ret = restore_activate_next(ctx);
 	if (ret < 0)
 		goto out;
 
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
-	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
-	 * will call ckpt_activate_next() and release the @ctx.
+	 * our current->checkpoint_ctx (and our PF_RESTARTING), will
+	 * call restore_task_done() and release the @ctx. This ensures
+	 * that we only report done after we really become zombie.
 	 */
-	if (ret)
+	if (zombie)
 		do_exit(current->exit_code);
 
-	ret = ckpt_activate_next(ctx);
-	if (ret < 0)
-		goto out;
-
+	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
  out:
 	old_ctx = xchg(&current->checkpoint_ctx, NULL);
@@ -631,8 +687,9 @@ static int do_restore_task(void)
 
 	/* if we're first to fail - notify others */
 	if (ret < 0 && !ckpt_test_ctx_error(ctx)) {
-		ckpt_notify_error(ctx);
+		restore_notify_error(ctx);
 		wake_up_all(&ctx->waitq);
+		wake_up_all(&ctx->ghostq);
 	}
 
 	current->flags &= ~PF_RESTARTING;
@@ -654,11 +711,11 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 	struct task_struct *parent = NULL;
 	struct task_struct *task = root;
 	struct ckpt_ctx *old_ctx;
-	int nr_pids = ctx->nr_pids;
+	int nr_pids = 0;
 	int ret = 0;
 
 	read_lock(&tasklist_lock);
-	while (nr_pids) {
+	while (1) {
 		ckpt_debug("consider task %d\n", task_pid_vnr(task));
 		if (task_ptrace(task) & PT_PTRACED) {
 			ret = -EBUSY;
@@ -685,7 +742,7 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 			}
 			ckpt_debug("prepare task %d\n", task_pid_vnr(task));
 			wake_up_process(task);
-			nr_pids--;
+			nr_pids++;
 		}
 
 		/* if has children - proceed with child */
@@ -708,19 +765,23 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 			parent = parent->real_parent;
 		}
 		if (task == root) {
-			/* in case root task in multi-threaded */
+			/* in case root task is multi-threaded */
 			root = task = next_thread(task);
 			if (root == leader)
 				break;
 		}
 	}
 	read_unlock(&tasklist_lock);
-	ckpt_debug("left %d ret %d root/task %d\n", nr_pids, ret, task == root);
+	ckpt_debug("nr %d/%d  ret %d\n", ctx->nr_pids, nr_pids, ret);
 
-	/* fail unless number of processes matches */
-	if (!ret && (nr_pids || task != root))
+	/*
+	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
+	 * tasks used as place-holders for PGIDs, but not fall short.
+	 */
+	if (!ret && (nr_pids < ctx->nr_pids))
 		ret = -ESRCH;
 
+	atomic_set(&ctx->nr_total, nr_pids);
 	return ret;
 }
 
@@ -731,7 +792,7 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 	init_completion(&ctx->complete);
 
 	BUG_ON(ctx->active_pid != -1);
-	ret = ckpt_activate_next(ctx);
+	ret = restore_activate_next(ctx);
 	if (ret < 0)
 		return ret;
 
@@ -792,7 +853,7 @@ static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	if (!nsproxy)
 		return -ESRCH;
 
-	ctx->active_pid = -1;	/* see ckpt_activate_next, get_active_pid */
+	ctx->active_pid = -1;  /* see restore_activate_next, get_active_pid */
 
 	return 0;
 }
@@ -833,7 +894,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		 * with an error on @old_ctx.
 		 */
 		ckpt_debug("bad bavhing checkpoint_ctx\n");
-		ckpt_notify_error(old_ctx);
+		restore_notify_error(old_ctx);
 		ckpt_ctx_put(old_ctx);
 		return -EBUSY;
 	}
@@ -928,12 +989,14 @@ static long restore_retval(void)
 	return ret;
 }
 
-long do_restart(struct ckpt_ctx *ctx, pid_t pid)
+long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
 {
 	long ret;
 
 	if (ctx)
 		ret = do_restore_coord(ctx, pid);
+	else if (flags & RESTART_GHOST)
+		ret = do_ghost_task();
 	else
 		ret = do_restore_task();
 
@@ -980,8 +1043,7 @@ void exit_checkpoint(struct task_struct *tsk)
 	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
 		BUG_ON(ctx->active_pid == -1);
-		if (ckpt_activate_next(ctx) < 0)
-			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+		restore_task_done(ctx);
 	}
 
 	ckpt_ctx_put(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 3db18f7..7ff3189 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -241,6 +241,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
+	init_waitqueue_head(&ctx->ghostq);
 
 	err = -EBADF;
 	ctx->file = fget(fd);
@@ -333,7 +334,7 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
-	ret = do_restart(ctx, pid);
+	ret = do_restart(ctx, pid, flags);
 
 	ckpt_ctx_put(ctx);
 	return ret;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 5e90ef9..69691ca 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -18,6 +18,7 @@
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
+#define RESTART_GHOST		0x4
 
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
@@ -44,7 +45,10 @@
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
-#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
+#define RESTART_USER_FLAGS  \
+	(RESTART_TASKSELF | \
+	 RESTART_FROZEN | \
+	 RESTART_GHOST)
 
 #define CKPT_REQUIRED_NONE  ((unsigned long) -1L)
 
@@ -129,7 +133,7 @@ extern void ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
-extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index e98251b..c98c21b 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -63,9 +63,11 @@ struct ckpt_ctx {
 	/* [multi-process restart] */
 	struct ckpt_hdr_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
+	atomic_t nr_total;		/* total tasks count (with ghosts) */
 	int active_pid;			/* (next) position in pids array */
-	struct completion complete;	/* container root and other tasks on */
-	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct completion complete;	/* completion for container root */
+	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
+	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
-- 
1.6.0.4
