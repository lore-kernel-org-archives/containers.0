From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/3] c/r: call restore_notify_error for restart (not
	checkpoint !)
Date: Sun,  6 Dec 2009 15:08:33 -0500
Message-ID: <1260130113-2423-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/restart.c       |   25 +++++--------------------
 checkpoint/sys.c           |    4 ++--
 include/linux/checkpoint.h |    8 ++++++++
 3 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 88d791b..7c79419 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -863,9 +863,9 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 				       ckpt_test_ctx_error(ctx));
 	ckpt_debug("active %d < %d (ret %d, errno %d)\n",
 		   ctx->active_pid, ctx->nr_pids, ret, ctx->errno);
-	if (!ret && ckpt_test_ctx_error(ctx))
-		ret = -EBUSY;
-	return ret;
+	if (ckpt_test_ctx_error(ctx))
+		return ckpt_get_error(ctx);
+	return 0;
 }
 
 static int wait_task_sync(struct ckpt_ctx *ctx)
@@ -874,7 +874,7 @@ static int wait_task_sync(struct ckpt_ctx *ctx)
 	wait_event_interruptible(ctx->waitq, ckpt_test_ctx_complete(ctx));
 	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
 	if (ckpt_test_ctx_error(ctx))
-		return -EBUSY;
+		return ckpt_get_error(ctx);
 	return 0;
 }
 
@@ -1127,14 +1127,6 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 
 	ret = wait_for_completion_interruptible(&ctx->complete);
 	ckpt_debug("final sync kflags %#lx (ret %d)\n", ctx->kflags, ret);
-	/*
-	 * Usually when restart fails, the restarting task will first
-	 * set @ctx->errno before waking us up. In the rare event that
-	 * @ctx->errno is unset, we must have been interrupted and
-	 * then checked for an error prior to ctx->errno update...
-	 */
-	if (ckpt_test_ctx_error(ctx))
-		ret = ctx->errno ? ctx->errno : -EINTR;
 
 	return ret;
 }
@@ -1303,14 +1295,7 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 
 	if (ckpt_test_ctx_error(ctx)) {
 		destroy_descendants(ctx);
-		/*
-		 * If a restaring task (or we) reported an error, that set
-		 * out return value to that error. (Need the unlikely loop
-		 * because the error is recorded after the flag is set).
-		 */
-		while (!ctx->errno)
-			yield();
-		ret = ctx->errno;
+		ret = ckpt_get_error(ctx);
 	} else {
 		ckpt_set_ctx_success(ctx);
 		wake_up_all(&ctx->waitq);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 749e2fd..dbee469 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -333,7 +333,7 @@ static void ckpt_set_error(struct ckpt_ctx *ctx, int err)
 	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR)) {
 		ctx->errno = err;
 		/* on restart, notify all tasks in restarting subtree */
-		if (!(ctx->kflags & CKPT_CTX_RESTART))
+		if (ctx->kflags & CKPT_CTX_RESTART)
 			restore_notify_error(ctx);
 	}
 }
@@ -480,7 +480,7 @@ void _ckpt_msg_complete(struct ckpt_ctx *ctx)
 	if (ctx->msglen <= 1)
 		return;
 
-	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ctx->errno) {
+	if (ctx->kflags & CKPT_CTX_CHECKPOINT && ckpt_test_ctx_error(ctx)) {
 		ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
 		if (!ret)
 			ret = ckpt_write_string(ctx, ctx->msg, ctx->msglen);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1f85162..c6c8d56 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -126,6 +126,14 @@ extern void sock_listening_list_free(struct list_head *head);
 #define ckpt_test_ctx_complete(ctx)  \
 	((ctx)->kflags & (CKPT_CTX_SUCCESS | CKPT_CTX_ERROR))
 
+static inline int ckpt_get_error(struct ckpt_ctx *ctx)
+{
+	/* errno is set after error flag: make sure we don't miss it */
+	while (!ctx->errno)
+		yield();
+	return ctx->errno;
+}
+
 extern void restore_notify_error(struct ckpt_ctx *ctx);
 
 /* obj_hash */
-- 
1.6.3.3
