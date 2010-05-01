From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 065/100] c/r: [signal 1/4] blocked and template for shared
	signals
Date: Sat,  1 May 2010 10:15:47 -0400
Message-ID: <1272723382-19470-66-git-send-email-orenl__13621.6577062898$1272728530$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds checkpoint/restart of blocked signals mask
(t->blocked) and a template for shared signals (t->signal).

Because t->signal sharing is tied to threads, we ensure proper sharing
of t->signal (struct signal_struct) for threads only.

Access to t->signal is protected by locking t->sighand->lock.
Therefore, the usual checkpoint_obj() invoking the callback
checkpoint_signal(ctx, signal) is insufficient because the task
pointer is unavailable.

Instead, handling of t->signal sharing is explicit using helpers
like ckpt_obj_lookup_add(), ckpt_obj_fetch() and ckpt_obj_insert().
The actual state is saved (if needed) _after_ the task_objs data.

To prevent tasks from handling restored signals during restart,
set their mask to block all signals and only restore the original
mask at the very end (before the last sync point).

Introduce per-task pointer 'ckpt_data' to temporary store data
for restore actions that are deferred to the end (like restoring
the signal block mask).

Changelog [ckpt-v19]:
  - Use task->saves_sigmask and drop task->checkpoint_data
  - [Serge Hallyn] Handle saved_sigmask at checkpoint

Changelog [ckpt-v19-rc1]:
  - Defer restore of blocked signals mask during restart
  - [Matt Helsley] Add cpp definitions for enums

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/signal.c      |    5 ++
 arch/x86/kernel/signal.c       |    5 ++
 include/linux/checkpoint.h     |    8 +++
 include/linux/checkpoint_hdr.h |   16 +++++
 include/linux/signal.h         |    3 +
 kernel/checkpoint/process.c    |   71 ++++++++++++++++++++++-
 kernel/checkpoint/restart.c    |   13 ++++
 kernel/fork.c                  |    3 +
 kernel/signal.c                |  124 +++++++++++++++++++++++++++++++++++++++-
 9 files changed, 246 insertions(+), 2 deletions(-)

diff --git a/arch/s390/kernel/signal.c b/arch/s390/kernel/signal.c
index 83425b1..41e03d3 100644
--- a/arch/s390/kernel/signal.c
+++ b/arch/s390/kernel/signal.c
@@ -540,6 +540,11 @@ void do_signal(struct pt_regs *regs)
 	}
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	return !!(test_tsk_thread_flag(task, TIF_RESTORE_SIGMASK));
+}
+
 void do_notify_resume(struct pt_regs *regs)
 {
 	clear_thread_flag(TIF_NOTIFY_RESUME);
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index 4fd173c..eb63d59 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -831,6 +831,11 @@ static void do_signal(struct pt_regs *regs)
 	}
 }
 
+int task_has_saved_sigmask(struct task_struct *task)
+{
+	return !!(task_thread_info(task)->status & TS_RESTORE_SIGMASK);
+}
+
 /*
  * notification of userspace execution resumption
  * - triggered by the TIF_WORK_MASK flags
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8e8cf6e..92a0df0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -154,6 +154,8 @@ extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
+extern int pre_restore_task(void);
+extern void post_restore_task(void);
 
 /* arch hooks */
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
@@ -248,6 +250,12 @@ extern int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
 
 extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 
+extern int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
+
+extern int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_task_signal(struct ckpt_ctx *ctx);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2dea11e..19c778b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -138,6 +138,10 @@ enum {
 
 	CKPT_HDR_SIGHAND = 601,
 #define CKPT_HDR_SIGHAND CKPT_HDR_SIGHAND
+	CKPT_HDR_SIGNAL,
+#define CKPT_HDR_SIGNAL CKPT_HDR_SIGNAL
+	CKPT_HDR_SIGNAL_TASK,
+#define CKPT_HDR_SIGNAL_TASK CKPT_HDR_SIGNAL_TASK
 
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
@@ -178,6 +182,8 @@ enum obj_type {
 #define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_SIGHAND,
 #define CKPT_OBJ_SIGHAND CKPT_OBJ_SIGHAND
+	CKPT_OBJ_SIGNAL,
+#define CKPT_OBJ_SIGNAL CKPT_OBJ_SIGNAL
 	CKPT_OBJ_NS,
 #define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_UTS_NS,
@@ -378,6 +384,7 @@ struct ckpt_hdr_task_objs {
 	__s32 files_objref;
 	__s32 mm_objref;
 	__s32 sighand_objref;
+	__s32 signal_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -536,6 +543,15 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_signal {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_signal_task {
+	struct ckpt_hdr h;
+	struct ckpt_sigset blocked;
+} __attribute__((aligned(8)));
+
 /* ipc commons */
 struct ckpt_hdr_ipcns {
 	struct ckpt_hdr h;
diff --git a/include/linux/signal.h b/include/linux/signal.h
index fcd2b14..031784c 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -378,6 +378,9 @@ int unhandled_signal(struct task_struct *tsk, int sig);
 
 void signals_init(void);
 
+/* [arch] checkpoint: should saved_sigmask be used in place of blocked */
+int task_has_saved_sigmask(struct task_struct *task);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SIGNAL_H */
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 5927b7b..8cb88ae 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -181,7 +181,8 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int files_objref;
 	int mm_objref;
 	int sighand_objref;
-	int ret;
+	int signal_objref;
+	int first, ret;
 
 	/*
 	 * Shared objects may have dependencies among them: task->mm
@@ -226,14 +227,38 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return sighand_objref;
 	}
 
+	/*
+	 * Handle t->signal differently because the checkpoint method
+	 * for t->signal needs access to owning task_struct to access
+	 * t->sighand (to lock/unlock). First explicitly determine if
+	 * need to save, and only below invoke checkpoint_obj_signal()
+	 * if needed.
+	 */
+	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
+					    CKPT_OBJ_SIGNAL, &first);
+	ckpt_debug("signal: objref %d\n", signal_objref);
+	if (signal_objref < 0) {
+		ckpt_err(ctx, signal_objref, "%(T)process signals\n");
+		return signal_objref;
+	}
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
 	h->sighand_objref = sighand_objref;
+	h->signal_objref = signal_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	/* actually save t->signal, if need to */
+	if (first)
+		ret = checkpoint_obj_signal(ctx, t);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "%(T)signal_struct\n");
 
 	return ret;
 }
@@ -378,6 +403,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		goto out;
 	ret = checkpoint_task_objs(ctx, t);
 	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_signal(ctx, t);
+	ckpt_debug("task-signal %d\n", ret);
  out:
 	ctx->tsk = NULL;
 	return ret;
@@ -566,6 +595,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 
 	ret = restore_obj_sighand(ctx, h->sighand_objref);
 	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_signal(ctx, h->signal_objref);
+	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -703,6 +737,37 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* prepare the task for restore */
+int pre_restore_task(void)
+{
+	sigset_t sigset;
+
+	/*
+	 * Block task's signals to avoid interruptions due to signals,
+	 * say, from restored timers, file descriptors etc. Signals
+	 * will be unblocked when restore completes.
+	 *
+	 * NOTE: tasks with file descriptors set to send a SIGKILL as
+	 * i/o notification may fail the restart if a signal occurs
+	 * before that task completed its restore. FIX ?
+	 */
+	current->saved_sigmask = current->blocked;
+
+	sigfillset(&sigset);
+	sigdelset(&sigset, SIGKILL);
+	sigdelset(&sigset, SIGSTOP);
+	sigprocmask(SIG_SETMASK, &sigset, NULL);
+
+	return 0;
+}
+
+/* finish up task restore */
+void post_restore_task(void)
+{
+	/* only now is it safe to unblock the restored task's signals */
+	sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
@@ -735,6 +800,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_creds(ctx);
 	ckpt_debug("creds: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_signal(ctx);
+	ckpt_debug("signal: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index c9a667d..92d3e00 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -935,6 +935,10 @@ static int do_restore_task(void)
 
 	restore_debug_running(ctx);
 
+	ret = pre_restore_task();
+	if (ret < 0)
+		goto out;
+
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
 		ret = zombie;
@@ -948,6 +952,7 @@ static int do_restore_task(void)
 	 */
 	if (zombie) {
 		restore_debug_exit(ctx);
+		post_restore_task();
 		ckpt_ctx_put(ctx);
 		do_exit(current->exit_code);
 	}
@@ -959,6 +964,7 @@ static int do_restore_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "task restart failed\n");
 
+	post_restore_task();
 	current->flags &= ~PF_RESTARTING;
 	clear_task_ctx(current);
 	ckpt_ctx_put(ctx);
@@ -1166,6 +1172,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	 */
 
 	if (ctx->uflags & RESTART_TASKSELF) {
+		ret = pre_restore_task();
+		ckpt_debug("pre restore task: %d\n", ret);
+		if (ret < 0)
+			goto out;
 		ret = restore_task(ctx);
 		ckpt_debug("restore task: %d\n", ret);
 		if (ret < 0)
@@ -1198,6 +1208,9 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		ckpt_debug("freezing restart tasks ... %d\n", ret);
 	}
  out:
+	if (ctx->uflags & RESTART_TASKSELF)
+		post_restore_task();
+
 	restore_debug_error(ctx, ret);
 	if (ret < 0)
 		ckpt_err(ctx, ret, "restart failed (coordinator)\n");
diff --git a/kernel/fork.c b/kernel/fork.c
index 5d88ee6..86ced8c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -887,6 +887,9 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 
 	sig->oom_adj = current->signal->oom_adj;
 
+#ifdef CONFIG_CHECKPOINT
+	atomic_set(&sig->restart_count, 0);
+#endif
 	return 0;
 }
 
diff --git a/kernel/signal.c b/kernel/signal.c
index fdd760a..0e71eee 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2905,9 +2905,131 @@ static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
 	.restore = restore_sighand,
 };
 
+
+/***********************************************************************
+ * signal checkpoint/restart
+ */
+
+static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (!h)
+		return -ENOMEM;
+
+	/* fill in later */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	BUG_ON(t->flags & PF_EXITING);
+	return checkpoint_signal(ctx, t);
+}
+
+static int restore_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* fill in later */
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
+{
+	struct signal_struct *signal;
+	int ret = 0;
+
+	signal = ckpt_obj_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	if (!IS_ERR(signal)) {
+		/*
+		 * signal_struct is already shared properly as it is
+		 * tied to thread groups. Since thread relationships
+		 * are already restore now, t->signal must match.
+		 */
+		if (signal != current->signal)
+			ret = -EINVAL;
+	} else if (PTR_ERR(signal) == -EINVAL) {
+		/* first timer: add to hash and restore our t->signal */
+		ret = ckpt_obj_insert(ctx, current->signal,
+				      signal_objref, CKPT_OBJ_SIGNAL);
+		if (ret >= 0)
+			ret = restore_signal(ctx);
+	} else {
+		ret = PTR_ERR(signal);
+	}
+
+	return ret;
+}
+
+int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	if (task_has_saved_sigmask(t))
+		fill_sigset(&h->blocked, &t->saved_sigmask);
+	else
+		fill_sigset(&h->blocked, &t->blocked);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_task_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal_task *h;
+	sigset_t blocked;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	load_sigset(&blocked, &h->blocked);
+	/* silently remove SIGKILL, SIGSTOP */
+	sigdelset(&blocked, SIGKILL);
+	sigdelset(&blocked, SIGSTOP);
+
+	/*
+	 * Unblocking signals now may affect us in wait_task_sync().
+	 * Instead, save blocked mask in current->saved_sigmaks for
+	 * post_restore_task().
+	 */
+	current->saved_sigmask = blocked;
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+static const struct ckpt_obj_ops ckpt_obj_signal_ops = {
+	.obj_name = "SIGNAL",
+	.obj_type = CKPT_OBJ_SIGNAL,
+};
+
 static int __init checkpoint_register_signal(void)
 {
-	return register_checkpoint_obj(&ckpt_obj_sighand_ops);
+	int ret;
+
+	ret = register_checkpoint_obj(&ckpt_obj_sighand_ops);
+	if (ret < 0)
+		return ret;
+	return register_checkpoint_obj(&ckpt_obj_signal_ops);
 }
 #endif /* CONFIG_CHECKPOINT */
 
-- 
1.6.3.3
