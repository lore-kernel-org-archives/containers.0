From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: replace error_sem with an event completion
Date: Sun, 14 Mar 2010 22:37:30 -0400
Message-ID: <1268620650-23068-1-git-send-email-orenl@cs.columbia.edu>
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

(This patch applies on top of ckpt-v20-rc1)

The value of ctx->errno is protected by a semaphore to ensure that
processes do not pique at it prematurely (that is - after the error
bit is set, but before the value is committed).

But, lockdep sometimes complains when an error is detected from a
legitimately failed restart attempt. This is because we release
ctx->errno_sem in a task context different from the one in which it
was acquired.

Replace the semaphore with an event completion: this sort of
synchronization is what completion constructs are all about.

Originally reported by Nathan Lynch.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/sys.c                 |   13 ++++---------
 include/linux/checkpoint.h       |    5 ++---
 include/linux/checkpoint_types.h |    2 +-
 3 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index b605784..fe85ca7 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -280,8 +280,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	init_waitqueue_head(&ctx->ghostq);
 	init_completion(&ctx->complete);
 
-	init_rwsem(&ctx->errno_sem);
-	down_write(&ctx->errno_sem);
+	init_completion(&ctx->errno_sync);
 
 #ifdef CONFIG_CHECKPOINT_DEBUG
 	INIT_LIST_HEAD(&ctx->task_status);
@@ -343,11 +342,8 @@ void ckpt_set_error(struct ckpt_ctx *ctx, int err)
 	/* atomically set ctx->errno */
 	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR)) {
 		ctx->errno = err;
-		/*
-		 * We initialized ctx->errno_sem write-held to prevent
-		 * other tasks from reading ctx->errno prematurely.
-		 */
-		up_write(&ctx->errno_sem);
+		/* make ctx->errno visible to all other tasks */
+		complete_all(&ctx->errno_sync);
 		/* on restart, notify all tasks in restarting subtree */
 		if (ctx->kflags & CKPT_CTX_RESTART)
 			restore_notify_error(ctx);
@@ -357,8 +353,7 @@ void ckpt_set_error(struct ckpt_ctx *ctx, int err)
 void ckpt_set_success(struct ckpt_ctx *ctx)
 {
 	ckpt_set_ctx_kflag(ctx, CKPT_CTX_SUCCESS);
-	/* avoid warning "lock still held" when freeing (was write-held) */
-	up_write(&ctx->errno_sem);
+	complete_all(&ctx->errno_sync);
 }
 
 /* helpers to handler log/dbg/err messages */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index a25bac1..a8b9e21 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -160,10 +160,9 @@ static inline int ckpt_get_error(struct ckpt_ctx *ctx)
 {
 	/*
 	 * We may notice CKPT_CTX_ERROR before ctx->errno is set, but
-	 * ctx->errno_sem remains (write) held until after it's done.
+	 * ctx->errno_sync remains not-completed until after it's done.
 	 */
-	if (!ctx->errno)
-		down_read(&ctx->errno_sem);
+	wait_for_completion(&ctx->errno_sync);
 	return ctx->errno;
 }
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index efc9357..e9cc1d8 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -61,7 +61,7 @@ struct ckpt_ctx {
 	char err_string[256];	/* checkpoint: error string */
 
 	int errno;		/* errno that caused failure */
-	struct rw_semaphore errno_sem;	/* protect errno setting */
+	struct completion errno_sync;	/* protect errno setting */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
-- 
1.6.3.3
