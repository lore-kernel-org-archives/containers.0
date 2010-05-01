From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 070/100] c/r: correctly restore pgid
Date: Sat,  1 May 2010 10:15:52 -0400
Message-ID: <1272723382-19470-71-git-send-email-orenl__27701.4272789986$1272727349$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

Changelog [v19-rc1]:
  - Simplify logic of tracking restarting tasks
  - Debug final process-tree state on restart
  - [Matt Helsley] Add cpp definitions for enums
  - Self-restart to tolerate missing pgid
Changelog [v3]:
  - Fix leak of ckpt_ctx when restoring "ghost" tasks
Changelog [v2]:
  - Call change_pid() only if new pgrp differs from current one
Changelog [v1]:
  - Verify that pgid owner is a thread-group-leader.
  - Handle the case of pgid/sid == 0 using root's parent pid-ns

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h       |   11 +++-
 include/linux/checkpoint_hdr.h   |    3 +
 include/linux/checkpoint_types.h |    7 ++-
 kernel/checkpoint/process.c      |  102 ++++++++++++++++++++++++++++++++++++++
 kernel/checkpoint/restart.c      |   59 +++++++++++++++++++---
 kernel/checkpoint/sys.c          |    3 +-
 6 files changed, 172 insertions(+), 13 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 92a0df0..549f133 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -18,6 +18,7 @@
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
+#define RESTART_GHOST		0x4
 
 /* misc user visible */
 #define CHECKPOINT_FD_NONE	-1
@@ -52,7 +53,10 @@ extern long do_sys_restart(pid_t pid, int fd,
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
-#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
+#define RESTART_USER_FLAGS  \
+	(RESTART_TASKSELF | \
+	 RESTART_FROZEN | \
+	 RESTART_GHOST)
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -90,6 +94,9 @@ extern char *ckpt_fill_fname(struct path *path, struct path *root,
 extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
 extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 
+/* pids */
+extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
@@ -147,7 +154,7 @@ extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
-extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
+extern long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 01f7493..e706636 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -273,6 +273,9 @@ struct ckpt_pids {
 	__s32 vsid;
 } __attribute__((aligned(8)));
 
+/* pids */
+#define CKPT_PID_NULL  -1
+
 /* task data */
 struct ckpt_hdr_task {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index fe20842..d69b795 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -73,10 +73,11 @@ struct ckpt_ctx {
 	/* [multi-process restart] */
 	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
-	atomic_t nr_total;		/* total tasks count */
+	atomic_t nr_total;		/* total tasks count (with ghosts) */
 	int active_pid;			/* (next) position in pids array */
-	struct completion complete;	/* container root and other tasks on */
-	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct completion complete;	/* completion for container root */
+	wait_queue_head_t waitq;	/* waitqueue for restarting tasks */
+	wait_queue_head_t ghostq;	/* waitqueue for ghost tasks */
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 8cb88ae..fa08616 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -20,9 +20,61 @@
 #include <linux/utsname.h>
 #include <linux/syscalls.h>
 #include <linux/user_namespace.h>
+#include <linux/syscalls.h>
+#include <linux/security.h> /* security_task_setpgid()   */
 #include <linux/checkpoint.h>
 
 
+pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
+{
+	return pid ? pid_nr_ns(pid, ctx->root_nsproxy->pid_ns) : CKPT_PID_NULL;
+}
+
+/* must be called with tasklist_lock or rcu_read_lock() held */
+struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
+{
+	struct task_struct *p;
+	struct pid *pgrp;
+
+	if (pgid == 0) {
+		/*
+		 * At checkpoint the pgid owner lived in an ancestor
+		 * pid-ns. The best we can do (sanely and safely) is
+		 * to examine the parent of this restart's root: if in
+		 * a distinct pid-ns, use its pgrp; otherwise fail.
+		 */
+		p = ctx->root_task->real_parent;
+		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
+			return NULL;
+		pgrp = task_pgrp(p);
+	} else {
+		/*
+		 * Find the owner process of this pgid (it must exist
+		 * if pgrp exists). It must be a thread group leader.
+		 */
+		pgrp = find_vpid(pgid);
+		p = pid_task(pgrp, PIDTYPE_PID);
+		if (!p || !thread_group_leader(p))
+			return NULL;
+		/*
+		 * The pgrp must "belong" to our restart tree (compare
+		 * p->checkpoint_ctx to ours). This prevents malicious
+		 * input from (guessing and) using unrelated pgrps. If
+		 * the owner is dead, then it doesn't have a context,
+		 * so instead compare against its (real) parent's.
+		 */
+		if (p->exit_state == EXIT_ZOMBIE)
+			p = p->real_parent;
+		if (p->checkpoint_ctx != ctx)
+			return NULL;
+	}
+
+	if (task_session(current) != task_session(p))
+		return NULL;
+
+	return pgrp;
+}
+
 #ifdef CONFIG_FUTEX
 static void save_task_robust_futex_list(struct ckpt_hdr_task *h,
 					struct task_struct *t)
@@ -737,6 +789,53 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_pgid(struct ckpt_ctx *ctx)
+{
+	struct task_struct *task = current;
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
+
+	write_lock_irq(&tasklist_lock);
+	pgrp = _ckpt_find_pgrp(ctx, pgid);  /* (3) and (4) */
+	if (pgrp && task_pgrp(task) != pgrp) {
+		ret = security_task_setpgid(task, pgid);  /* (5) */
+		if (!ret)
+			change_pid(task, PIDTYPE_PGID, pgrp);
+	}
+	write_unlock_irq(&tasklist_lock);
+
+	/* self-restart: be tolerant if old pgid isn't found */
+	if (ctx->uflags & RESTART_TASKSELF)
+		ret = 0;
+
+	return ret;
+}
+
 /* prepare the task for restore */
 int pre_restore_task(void)
 {
@@ -782,6 +881,9 @@ int restore_task(struct ckpt_ctx *ctx)
 	if (ret)
 		goto out;
 
+	ret = restore_task_pgid(ctx);
+	if (ret < 0)
+		goto out;
 	ret = restore_thread(ctx);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 3b2593d..e7a5b5b 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -737,6 +737,7 @@ void restore_notify_error(struct ckpt_ctx *ctx)
 {
 	complete(&ctx->complete);
 	wake_up_all(&ctx->waitq);
+	wake_up_all(&ctx->ghostq);
 }
 
 static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
@@ -812,6 +813,9 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 			ckpt_err(ctx, -ESRCH, "task %d not found\n", pid);
 			return -ESRCH;
 		}
+	} else {
+		/* wake up ghosts tasks so that they can terminate */
+		wake_up_all(&ctx->ghostq);
 	}
 
 	return 0;
@@ -869,6 +873,38 @@ static struct ckpt_ctx *wait_checkpoint_ctx(void)
 	return ctx;
 }
 
+static int do_ghost_task(void)
+{
+	struct ckpt_ctx *ctx;
+	int ret;
+
+	ctx = wait_checkpoint_ctx();
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	ret = restore_debug_task(ctx, RESTART_DBG_GHOST);
+	if (ret < 0)
+		goto out;
+
+	current->flags |= PF_RESTARTING;
+	restore_debug_running(ctx);
+
+	ret = wait_event_interruptible(ctx->ghostq,
+				       all_tasks_activated(ctx) ||
+				       ckpt_test_error(ctx));
+ out:
+	restore_debug_error(ctx, ret);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "ghost restart failed\n");
+
+	current->exit_signal = -1;
+	restore_debug_exit(ctx);
+	ckpt_ctx_put(ctx);
+	do_exit(0);
+
+	/* NOT REACHED */
+}
+
 /*
  * Ensure that all members of a thread group are in sys_restart before
  * restoring any of them. Otherwise, restore may modify shared state
@@ -948,10 +984,15 @@ static int do_restore_task(void)
 		goto out;
 	}
 
+	ret = restore_activate_next(ctx);
+	if (ret < 0)
+		goto out;
+
 	/*
 	 * zombie: we're done here; do_exit() will notice the @ctx on
-	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
-	 * will call restore_activate_next() and release the @ctx.
+	 * our current->checkpoint_ctx (and our PF_RESTARTING), will
+	 * call restore_task_done() and release the @ctx. This ensures
+	 * that we only report done after we really become zombie.
 	 */
 	if (zombie) {
 		restore_debug_exit(ctx);
@@ -1033,8 +1074,11 @@ static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
 	if (nr_pids < 0)
 		return nr_pids;
 
-	/* fail unless number of processes matches */
-	if (nr_pids != ctx->nr_pids)
+	/*
+	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
+	 * tasks used as place-holders for PGIDs, but not fall short.
+	 */
+	if (nr_pids < ctx->nr_pids)
 		return -ESRCH;
 
 	atomic_set(&ctx->nr_total, nr_pids);
@@ -1280,12 +1324,14 @@ static long restore_retval(void)
 	return syscall_get_return_value(current, regs);
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
 
@@ -1333,8 +1379,7 @@ void exit_checkpoint(struct task_struct *tsk)
 	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
 		BUG_ON(ctx->active_pid == -1);
-		if (restore_activate_next(ctx) < 0)
-			pr_warning("c/r: [%d] failed zombie exit\n", tsk->pid);
+		restore_task_done(ctx);
 	}
 
 	ckpt_ctx_put(ctx);
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index 73d84bd..86dabfa 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -250,6 +250,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
+	init_waitqueue_head(&ctx->ghostq);
 	init_completion(&ctx->complete);
 
 	init_completion(&ctx->errno_sync);
@@ -658,7 +659,7 @@ long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 
-	ret = do_restart(ctx, pid);
+	ret = do_restart(ctx, pid, flags);
 
 	ckpt_ctx_put(ctx);
 	return ret;
-- 
1.6.3.3
