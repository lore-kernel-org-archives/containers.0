From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Review: Can we move init_restart_ctx() up ?
Date: Thu, 1 Oct 2009 22:14:56 -0700
Message-ID: <20091002051456.GA6684@us.ibm.com>
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



Would it be easier/cleaner if we initialized the restart ctx soon after
allocating it ? Looks like we already have the information we need at that
point.

That way, do_restart() won't need the 'pid' parameter and we anyway use
the 'if(ctx)' check to test for the coordinator.

BTW, can we move the '->active_pid = -1' in init_restart_ctx() to
ckpt_ctx_alloc() itself ?

(This is mostly as a code-review comment, have not tested the patch yet).

---
 checkpoint/restart.c       |   10 +++-------
 checkpoint/sys.c           |   13 +++++++++----
 include/linux/checkpoint.h |    2 +-
 3 files changed, 13 insertions(+), 12 deletions(-)

Index: linux-cr/checkpoint/restart.c
===================================================================
--- linux-cr.orig/checkpoint/restart.c	2009-10-01 21:42:21.000000000 -0700
+++ linux-cr/checkpoint/restart.c	2009-10-01 21:44:24.000000000 -0700
@@ -897,7 +897,7 @@ static int init_restart_ctx(struct ckpt_
 	return 0;
 }
 
-static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
+static int do_restore_coord(struct ckpt_ctx *ctx)
 {
 	struct ckpt_ctx *old_ctx;
 	int ret;
@@ -912,10 +912,6 @@ static int do_restore_coord(struct ckpt_
 	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
 		return -EINVAL;
 
-	ret = init_restart_ctx(ctx, pid);
-	if (ret < 0)
-		return ret;
-
 	/*
 	 * Populate own ->checkpoint_ctx: if an ancestor attempts to
 	 * prepare_descendants() on us, it will fail. Furthermore,
@@ -1033,12 +1029,12 @@ static long restore_retval(void)
 	return ret;
 }
 
-long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
+long do_restart(struct ckpt_ctx *ctx, unsigned long flags)
 {
 	long ret;
 
 	if (ctx)
-		ret = do_restore_coord(ctx, pid);
+		ret = do_restore_coord(ctx);
 	else if (flags & RESTART_GHOST)
 		ret = do_ghost_task();
 	else
Index: linux-cr/checkpoint/sys.c
===================================================================
--- linux-cr.orig/checkpoint/sys.c	2009-10-01 21:39:43.000000000 -0700
+++ linux-cr/checkpoint/sys.c	2009-10-01 21:42:07.000000000 -0700
@@ -330,12 +330,17 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int
 	if (!ckpt_unpriv_allowed && !capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	if (pid)
+	if (pid) {
 		ctx = ckpt_ctx_alloc(fd, flags, CKPT_CTX_RESTART);
-	if (IS_ERR(ctx))
-		return PTR_ERR(ctx);
+		if (IS_ERR(ctx))
+			return PTR_ERR(ctx);
 
-	ret = do_restart(ctx, pid, flags);
+		ret = init_restart_ctx(ctx, pid);
+		if (ret < 0)
+			return ret;
+	}
+
+	ret = do_restart(ctx, flags);
 
 	ckpt_ctx_put(ctx);
 	return ret;
Index: linux-cr/include/linux/checkpoint.h
===================================================================
--- linux-cr.orig/include/linux/checkpoint.h	2009-10-01 21:44:54.000000000 -0700
+++ linux-cr/include/linux/checkpoint.h	2009-10-01 21:45:01.000000000 -0700
@@ -138,7 +138,7 @@ extern void ckpt_ctx_get(struct ckpt_ctx
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
-extern long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags);
+extern long do_restart(struct ckpt_ctx *ctx, unsigned long flags);
 
 /* task */
 extern int ckpt_activate_next(struct ckpt_ctx *ctx);
