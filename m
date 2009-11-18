From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 6/6] have ckpt_err set ctx->errno
Date: Tue, 17 Nov 2009 19:53:33 -0600
Message-ID: <1258509213-15318-6-git-send-email-serue@us.ibm.com>
References: <1258509213-15318-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258509213-15318-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Move setting of ctx->errno into do_ckpt_msg().  If the operation is
a restart, and errno was previously unset, then also wake all waiting
callers so they know to quit.

NOTE that the way this is set up, users of _ckpt_err().._ckpt_msg_complete()
do not cause restore_wake_all_on_error() to be called.  If a restart
path has to use _ckpt_err(), then we'll have to work around that, which
seems simplest to do by again using the CKPT_CTX_WOKEN flag separate from
CKPT_CTX_ERROR.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c       |   32 ++++----------------------------
 checkpoint/sys.c           |   25 +++++++++++++++++--------
 include/linux/checkpoint.h |    6 ------
 3 files changed, 21 insertions(+), 42 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 6cdefc9..a45263e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -719,29 +719,6 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
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
@@ -812,8 +789,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		rcu_read_unlock();
 
 		if (!task) {
-			ckpt_debug("could not find task %d\n", pid);
-			restore_notify_error(ctx, -ESRCH);
+			ckpt_err(ctx, -ESRCH, "could not find task %d\n", pid);
 			return -ESRCH;
 		}
 	} else {
@@ -898,7 +874,7 @@ static int do_ghost_task(void)
  out:
 	restore_debug_error(ctx, ret);
 	if (ret < 0)
-		restore_notify_error(ctx, ret);
+		ckpt_err(ctx, ret, "Error while restarting ghost\n");
 
 	current->exit_signal = -1;
 	restore_debug_exit(ctx);
@@ -1009,7 +985,7 @@ static int do_restore_task(void)
  out:
 	restore_debug_error(ctx, ret);
 	if (ret < 0)
-		restore_notify_error(ctx, ret);
+		ckpt_err(ctx, ret, "Error while restarting task\n");
 
 	post_restore_task();
 	current->flags &= ~PF_RESTARTING;
@@ -1272,7 +1248,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	restore_debug_error(ctx, ret);
 
 	if (ret < 0)
-		ckpt_set_ctx_error(ctx, ret);
+		ckpt_err(ctx, ret, "Error while restarting coordinator\n");
 
 	if (ckpt_test_ctx_error(ctx)) {
 		destroy_descendants(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index bf66418..f22bdb7 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -376,6 +376,19 @@ static inline int is_special_flag(char *s)
 }
 
 /*
+ * If exiting a restart with error, then wake up all other tasks
+ * in the restart context.
+ */
+static void restore_wake_all_on_error(struct ckpt_ctx *ctx)
+{
+	if (!ctx->kflags & CKPT_CTX_RESTART)
+		return;
+	complete(&ctx->complete);
+	wake_up_all(&ctx->waitq);
+	wake_up_all(&ctx->ghostq);
+}
+
+/*
  * _ckpt_generate_fmt - handle the special flags in the enhanced format
  * strings used by checkpoint/restart error messages.
  * @ctx: checkpoint context
@@ -459,14 +472,6 @@ static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
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
@@ -543,6 +548,10 @@ void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
 {
 	if (!ctx) return;
 
+	if (err && !ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR)) {
+		ctx->errno = err;
+		restore_wake_all_on_error(ctx);
+	}
 	ckpt_msg_lock(ctx);
 	__do_ckpt_msg(ctx, err, fmt);
 	_ckpt_msg_complete(ctx);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 65765af..470097d 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -104,12 +104,6 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 
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
