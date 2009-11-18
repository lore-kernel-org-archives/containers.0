From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/6] Move init_completion(&ctx->complete) to ctx_alloc
Date: Tue, 17 Nov 2009 19:53:31 -0600
Message-ID: <1258509213-15318-4-git-send-email-serue@us.ibm.com>
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

That way we don't risk indirectly calling complete(&ctx->complete)
(through ckpt_err()) before ctx->complete has been initialized.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |    2 --
 checkpoint/sys.c     |    4 ++++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index b684d7a..6cdefc9 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -1092,8 +1092,6 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 {
 	int ret;
 
-	init_completion(&ctx->complete);
-
 	BUG_ON(ctx->active_pid != -1);
 	ret = restore_activate_next(ctx);
 	if (ret < 0)
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index d64f5a7..bf66418 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -245,6 +245,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
 	init_waitqueue_head(&ctx->ghostq);
+	if (kflags == CKPT_CTX_RESTART)
+		init_completion(&ctx->complete);
 
 #ifdef CONFIG_CHECKPOINT_DEBUG
 	INIT_LIST_HEAD(&ctx->task_status);
@@ -473,6 +475,8 @@ static void _ckpt_msg_appendv(struct ckpt_ctx *ctx, int err, char *fmt,
 
 	len += snprintf(&ctx->msg[len], CKPT_MSG_LEN-len, "[offset %lld]",
 			ctx->total);
+	if (len > CKPT_MSG_LEN)
+		goto full;
 	len += vsnprintf(&ctx->msg[len], CKPT_MSG_LEN-len, fmt, ap);
 	if (len > CKPT_MSG_LEN) {
 full:
-- 
1.6.1
