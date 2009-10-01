From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 5/5] c/r: defer restore of blocked signals mask during restart
Date: Wed, 30 Sep 2009 21:47:14 -0400
Message-ID: <1254361634-30076-6-git-send-email-orenl@librato.com>
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

When a task finished restoring its state, it calls wait_task_sync()
to wait for all others tasks, in an interruptible wait.

If the task also restored some pending signal from its saves state,
then the signal may become visible when the blocked mask is restored.
In this case the sleep will fail, as will the entire restart.

(Note that it doesn't affect other threads, because the blocked mask
is per-thread.

To avoid this, we block all signals for restarting processes until the
_entire_ restart succeeds, and defer the setting of blocked mask to
that point.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/process.c             |   22 +++++++++++++++++++++-
 checkpoint/restart.c             |   12 ++++++++++++
 checkpoint/signal.c              |    8 ++++++--
 include/linux/checkpoint.h       |    2 ++
 include/linux/checkpoint_types.h |    4 ++++
 include/linux/sched.h            |    2 +-
 6 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 3c02f8e..5ba64f0 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -815,10 +815,15 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 }
 
 /* pre_restore_task - prepare the task for restore */
-static int pre_restore_task(struct ckpt_ctx *ctx)
+int pre_restore_task(struct ckpt_ctx *ctx)
 {
 	sigset_t sigset;
 
+	/* task-specific restart data: freed from post_restore_task() */
+	current->checkpoint_data = kzalloc(sizeof(struct ckpt_data), GFP_KERNEL);
+	if (!current->checkpoint_data)
+		return -ENOMEM;
+
 	/*
 	 * Block task's signals to avoid interruptions due to signals,
 	 * say, from restored timers, file descriptors etc. Signals
@@ -828,6 +833,9 @@ static int pre_restore_task(struct ckpt_ctx *ctx)
 	 * i/o notification may fail the restart if a signal occurs
 	 * before that task completed its restore. FIX ?
 	 */
+
+	current->checkpoint_data->blocked = current->blocked;
+
 	sigfillset(&sigset);
 	sigdelset(&sigset, SIGKILL);
 	sigdelset(&sigset, SIGSTOP);
@@ -836,6 +844,18 @@ static int pre_restore_task(struct ckpt_ctx *ctx)
 	return 0;
 }
 
+/* pre_restore_task - prepare the task for restore */
+void post_restore_task(struct ckpt_ctx *ctx)
+{
+	/* only now is it safe to unblock the restored task's signals */
+	sigprocmask(SIG_SETMASK, &current->checkpoint_data->blocked, NULL);
+	recalc_sigpending();
+
+	/* task-specific restart data: allocated in pre_restore_task() */
+	kfree(current->checkpoint_data);
+	current->checkpoint_data = NULL;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 258e9eb..b12c8bd 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -763,6 +763,10 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
+	ret = pre_restore_task(ctx);
+	if (ret < 0)
+		goto out;
+
 	zombie = restore_task(ctx);
 	if (zombie < 0) {
 		ret = zombie;
@@ -790,6 +794,7 @@ static int do_restore_task(void)
 	if (ret < 0)
 		restore_notify_error(ctx, ret);
 
+	post_restore_task(ctx);
 	current->flags &= ~PF_RESTARTING;
 	set_task_ctx(current, NULL);
 	ckpt_ctx_put(ctx);
@@ -997,6 +1002,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	 */
 
 	if (ctx->uflags & RESTART_TASKSELF) {
+		ret = pre_restore_task(ctx);
+		ckpt_debug("pre restore task: %d\n", ret);
+		if (ret < 0)
+			goto out;
 		ret = restore_task(ctx);
 		ckpt_debug("restore task: %d\n", ret);
 		if (ret < 0)
@@ -1029,6 +1038,9 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		ckpt_debug("freezing restart tasks ... %d\n", ret);
 	}
  out:
+	if (ctx->uflags & RESTART_TASKSELF)
+		post_restore_task(ctx);
+
 	if (ret < 0) {
 		ckpt_set_ctx_error(ctx, ret);
 		destroy_descendants(ctx);
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index cd3956d..cdfb142 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -712,8 +712,12 @@ int restore_task_signal(struct ckpt_ctx *ctx)
 	sigdelset(&blocked, SIGKILL);
 	sigdelset(&blocked, SIGSTOP);
 
-	sigprocmask(SIG_SETMASK, &blocked, NULL);
-	recalc_sigpending();
+	/*
+	 * Unblocking signals now may affect us in wait_task_sync().
+	 * Instead, save blocked mask in current->checkpoint_data for
+	 * post_restore_task().
+	 */
+	current->checkpoint_data->blocked = blocked;
 
 	ckpt_hdr_put(ctx, h);
 	return 0;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 12210e4..e403dd7 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -148,6 +148,8 @@ extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
+extern int pre_restore_task(struct ckpt_ctx *ctx);
+extern void post_restore_task(struct ckpt_ctx *ctx);
 
 /* arch hooks */
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 9b7b4dd..b9393f4 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -28,6 +28,10 @@ struct ckpt_stats {
 	int user_ns;
 };
 
+struct ckpt_data {
+	sigset_t blocked;
+};
+
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0ab9553..3448873 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1482,7 +1482,7 @@ struct task_struct {
 #endif /* CONFIG_TRACING */
 #ifdef CONFIG_CHECKPOINT
 	struct ckpt_ctx *checkpoint_ctx;
-	unsigned long required_id;
+	struct ckpt_data *checkpoint_data;
 #endif
 };
 
-- 
1.6.0.4
