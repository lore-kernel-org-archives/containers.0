From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 6/7] have ckpt_err set ctx->errno
Date: Thu,  5 Nov 2009 18:00:18 -0600
Message-ID: <1257465619-1777-7-git-send-email-serue@us.ibm.com>
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

Move setting of ctx->errno into do_ckpt_msg().  We leave a small separate
function to notify all restarting tasks in case of failure.  We use a
CKPT_CTX_WOKEN bit for this.  If we always notify restarting tasks of
failure inside do_ckpt_msg() then we will have to be more careful about
when ckpt_err() is called at restart.  Only 4 instances were doing the
wakeup right now (at the end of each possible restart sequence), and we
don't want to risk moving notification too early.

This patch also fixes what should have been a problem before: always
init_completion(&complete), else we might complete(&complete) on random junk

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c       |   66 +++++++++++++++++++++----------------------
 checkpoint/sys.c           |   11 ++-----
 include/linux/checkpoint.h |   13 +++-----
 3 files changed, 40 insertions(+), 50 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index e1bd0ad..9e2647e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -58,6 +58,20 @@ struct ckpt_task_status {
 	struct list_head list;
 };
 
+/*
+ * restore_wake_all_on_error() is always called after a ckpt_err()
+ * with err < 0.  So CKPT_CTX_ERROR will always be set before this
+ * gets called.
+ */
+static void restore_wake_all_on_error(struct ckpt_ctx *ctx)
+{
+	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_WOKEN)) {
+		complete(&ctx->complete);
+		wake_up_all(&ctx->waitq);
+		wake_up_all(&ctx->ghostq);
+	}
+}
+
 static int restore_debug_task(struct ckpt_ctx *ctx, int flags)
 {
 	struct ckpt_task_status *s;
@@ -714,29 +728,6 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
 	return get_active_pid(ctx) == pid;
 }
 
-/* should not be called under write_lock_irq(&tasklist_lock) */
-static void _restore_notify_error(struct ckpt_ctx *ctx, int errno)
-{
-	/* first to fail: notify everyone (racy but harmless) */
-	if (!ckpt_test_ctx_error(ctx)) {
-		ckpt_debug("setting restart error %d\n", errno); \
-		ckpt_set_ctx_error(ctx, errno);
-		complete(&ctx->complete);
-		wake_up_all(&ctx->waitq);
-		wake_up_all(&ctx->ghostq);
-	}
-}
-
-/*
- * Need to call ckpt_debug such that it will get the correct source
- * location.  Should not be called under write_lock_irq(&tasklist_lock)
-*/
-#define restore_notify_error(ctx, errno) \
-do { \
-	ckpt_debug("restart error %d, root pid %d\n", errno, ctx->root_pid); \
-	_restore_notify_error(ctx, errno); \
-} while(0)
-
 static inline struct ckpt_ctx *get_task_ctx(struct task_struct *task)
 {
 	struct ckpt_ctx *ctx;
@@ -781,7 +772,8 @@ static void clear_task_ctx(struct task_struct *task)
 static void restore_task_done(struct ckpt_ctx *ctx)
 {
 	if (atomic_dec_and_test(&ctx->nr_total))
-		complete(&ctx->complete);
+		if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_WOKEN))
+			complete(&ctx->complete);
 	BUG_ON(atomic_read(&ctx->nr_total) < 0);
 }
 
@@ -808,8 +800,8 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
-			ckpt_err(ctx, 0, "could not find task %d\n", pid);
-			restore_notify_error(ctx, -ESRCH);
+			ckpt_err(ctx, -ESRCH, "could not find task %d\n", pid);
+			restore_wake_all_on_error(ctx);
 			return -ESRCH;
 		}
 	} else {
@@ -893,8 +885,10 @@ static int do_ghost_task(void)
 				       ckpt_test_ctx_error(ctx));
  out:
 	restore_debug_error(ctx, ret);
-	if (ret < 0)
-		restore_notify_error(ctx, ret);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "waiting on ghostq\n");
+		restore_wake_all_on_error(ctx);
+	}
 
 	current->exit_signal = -1;
 	restore_debug_exit(ctx);
@@ -1013,8 +1007,10 @@ static int do_restore_task(void)
 	ret = wait_task_sync(ctx);
  out:
 	restore_debug_error(ctx, ret);
-	if (ret < 0)
-		restore_notify_error(ctx, ret);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "wait_task_sync\n");
+		restore_wake_all_on_error(ctx);
+	}
 
 	post_restore_task();
 	current->flags &= ~PF_RESTARTING;
@@ -1097,8 +1093,6 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 {
 	int ret;
 
-	init_completion(&ctx->complete);
-
 	BUG_ON(ctx->active_pid != -1);
 	ret = restore_activate_next(ctx);
 	if (ret < 0)
@@ -1247,6 +1241,8 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	 * subtree that we marked for restart - see below.
 	 */
 
+	init_completion(&ctx->complete);
+
 	if (ctx->uflags & RESTART_TASKSELF) {
 		ret = pre_restore_task();
 		ckpt_debug("pre restore task: %d\n", ret);
@@ -1301,8 +1297,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 	restore_debug_error(ctx, ret);
 
-	if (ret < 0)
-		ckpt_set_ctx_error(ctx, ret);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "coordinator noting error\n");
+		restore_wake_all_on_error(ctx);
+	}
 
 	if (ckpt_test_ctx_error(ctx)) {
 		destroy_descendants(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index c1c4e99..8cd9baa 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -457,14 +457,6 @@ static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
 	int len = ctx->msglen;
 
 	if (err) {
-		/* At restart we must use a more baroque helper to set
-		 * ctx->errno, which also wakes all other waiting restarting
-		 * tasks.  But at checkpoint we just set ctx->errno so that
-		 * _ckpt_msg_complete() will know to write the error message
-		 * to the checkpoint image.
-		 */
-		if (ctx->kflags & CKPT_CTX_CHECKPOINT && !ctx->errno)
-			ctx->errno = err;
 		len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[err %d]",
 				 err);
 		if (len > CKPT_MSG_LEN)
@@ -533,10 +525,13 @@ void _do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
 	__do_ckpt_msg(ctx, err, fmt);
 }
 
+
 void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
 {
 	if (!ctx) return;
 
+	if (err && !ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR))
+		ctx->errno = err;
 	ckpt_msg_lock(ctx);
 	__do_ckpt_msg(ctx, err, fmt);
 	_ckpt_msg_complete(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8fd6cba..2920630 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -40,11 +40,13 @@
 #define CKPT_CTX_RESTART_BIT		1
 #define CKPT_CTX_SUCCESS_BIT		2
 #define CKPT_CTX_ERROR_BIT		3
+#define CKPT_CTX_WOKEN_BIT		4 /* after ERROR is set, wake all */
 
 #define CKPT_CTX_CHECKPOINT	(1 << CKPT_CTX_CHECKPOINT_BIT)
 #define CKPT_CTX_RESTART	(1 << CKPT_CTX_RESTART_BIT)
 #define CKPT_CTX_SUCCESS	(1 << CKPT_CTX_SUCCESS_BIT)
 #define CKPT_CTX_ERROR		(1 << CKPT_CTX_ERROR_BIT)
+#define CKPT_CTX_WOKEN		(1 << CKPT_CTX_WOKEN_BIT)
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
@@ -53,6 +55,9 @@
 	 RESTART_FROZEN | \
 	 RESTART_GHOST)
 
+#define ckpt_test_and_set_ctx_kflag(__ctx, __kflag)  \
+	test_and_set_bit(__kflag##_BIT, &(__ctx)->kflags)
+
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
 			     void *data);
@@ -99,17 +104,9 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
-#define ckpt_test_and_set_ctx_kflag(__ctx, __kflag)  \
-	test_and_set_bit(__kflag##_BIT, &(__ctx)->kflags)
 
 #define ckpt_set_ctx_success(ctx)  ckpt_set_ctx_kflag(ctx, CKPT_CTX_SUCCESS)
 
-static inline void ckpt_set_ctx_error(struct ckpt_ctx *ctx, int errno)
-{
-	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR))
-		ctx->errno = errno;
-}
-
 #define ckpt_test_ctx_error(ctx)  \
 	((ctx)->kflags & CKPT_CTX_ERROR)
 #define ckpt_test_ctx_complete(ctx)  \
-- 
1.6.1
