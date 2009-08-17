From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Improve debug output from ckpt_notify_error()
Date: Mon, 17 Aug 2009 13:34:23 -0700
Message-ID: <20090817203423.GA12194@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

    Make ckpt_debug() report a more useful location than the
    line of some generic debug/error wrapper.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 3d3d4ed..febc9b7 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -485,13 +485,20 @@ static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
 	return get_active_pid(ctx) == pid;
 }
 
-static inline void ckpt_notify_error(struct ckpt_ctx *ctx)
+static inline void _ckpt_notify_error(struct ckpt_ctx *ctx)
 {
-	ckpt_debug("ctx with root pid %d (%p)", ctx->root_pid, ctx);
 	ckpt_set_ctx_error(ctx);
 	complete(&ctx->complete);
 }
 
+/* Need to call ckpt_debug such that it will get the correct source location */
+#define ckpt_notify_error(ctx) \
+do { \
+	ckpt_debug("ctx with root pid %d (%p)", ctx->root_pid, ctx); \
+	_ckpt_notify_error(ctx); \
+} while(0)
+
+
 int ckpt_activate_next(struct ckpt_ctx *ctx)
 {
 	struct task_struct *task;
