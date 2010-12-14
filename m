From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: STDIN_FILENO during restart
Date: Mon, 13 Dec 2010 21:50:43 -0800
Message-ID: <20101214055043.GA26636@us.ibm.com>
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

Oren

Is there a reason we hard code STDIN_FILENO during restart in usercr ?

Or can we simply use the fd passed by the caller of cr_restart() -
something like in this patch ? 

Whether it is STDIN_FILENO or another fd, do_sys_restart() holds a reference
to the 'struct file' and so we should still be able to read the image even
if close_all_fds() closes the fd. Or is there a subtle reason, we stick to
STDIN_FILENO ?

Sukadev
---
 src/lxc/user-cr/restart.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/src/lxc/user-cr/restart.c b/src/lxc/user-cr/restart.c
index 5b22948..944dbf1 100644
--- a/src/lxc/user-cr/restart.c
+++ b/src/lxc/user-cr/restart.c
@@ -169,6 +169,7 @@ static int global_child_status;
 static int global_child_collected;
 static int global_sent_sigint;
 static struct signal_array signal_array[] = INIT_SIGNAL_ARRAY;
+static int global_input_fd = -1;

 /*
  * TODO: Implement an API to let callers choose if/how an interrupt be sent
@@ -403,15 +404,23 @@ int process_args(struct cr_restart_args *args)
 	global_ulogfd = args->ulogfd;
 	global_uerrfd = args->uerrfd;

+	if (args->infd < 0) {
+		ckpt_err("Invalid input fd %d\n", args->infd);
+		exit(1);
+	}
+	global_input_fd = args->infd;
+
+#if 0
 	/* input file descriptor (default: stdin) */
 	if (args->infd >= 0) {
-		if (dup2(args->infd, STDIN_FILENO) < 0) {
+		if (dup2(args->infd, global_input_fd) < 0) {
 			ckpt_perror("dup2 input file");
 			exit(1);
 		}
-		if (args->infd != STDIN_FILENO)
+		if (args->infd != global_input_fd)
 			close(args->infd);
 	}
+#endif

 	/* output file descriptor (default: none) */
 	if (args->klogfd < 0)
@@ -492,7 +501,7 @@ int cr_restart(struct cr_restart_args *args)
 		if (args->mnt_pty && ckpt_remount_devpts(&ctx) < 0)
 			exit(1);

-		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args->klogfd);
+		restart(getpid(), global_input_fd, RESTART_TASKSELF, args->klogfd);

 		/* reach here if restart(2) failed ! */
 		ckpt_perror("restart");
@@ -926,7 +935,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ctx->args->keep_lsm)
 		flags |= RESTART_KEEP_LSM;

-	ret = restart(root_pid, STDIN_FILENO, flags, ctx->args->klogfd);
+	ret = restart(root_pid, global_input_fd, flags, ctx->args->klogfd);

 	if (ret < 0) {
 		ckpt_perror("restart failed");
@@ -1658,7 +1667,7 @@ static int ckpt_make_tree(struct ckpt_ctx *ctx, struct task *task)

 	/* on success this doesn't return */
 	ckpt_dbg("about to call sys_restart(), flags %#lx\n", flags);
-	ret = restart(0, STDIN_FILENO, flags, CHECKPOINT_FD_NONE);
+	ret = restart(0, global_input_fd, flags, CHECKPOINT_FD_NONE);
 	if (ret < 0)
 		ckpt_perror("task restore failed");
 	return ret;
@@ -1857,8 +1866,8 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 	ctx->pipe_out = ctx->pipe_child[1];
 	/* feeder pipe */
 	close(ctx->pipe_feed[1]);
-	if (ctx->pipe_feed[0] != STDIN_FILENO) {
-		dup2(ctx->pipe_feed[0], STDIN_FILENO);
+	if (ctx->pipe_feed[0] != global_input_fd) {
+		dup2(ctx->pipe_feed[0], global_input_fd);
 		close(ctx->pipe_feed[0]);
 	}

@@ -1878,7 +1887,7 @@ static void ckpt_read_write_blind(struct ckpt_ctx *ctx)
 	int ret;

 	while (1) {
-		ret = read(STDIN_FILENO, ctx->buf, BUFSIZE);
+		ret = read(global_input_fd, ctx->buf, BUFSIZE);
 		ckpt_dbg("c/r read input %d\n", ret);
 		if (ret == 0)
 			break;
@@ -1897,7 +1906,7 @@ static void ckpt_read_write_inspect(struct ckpt_ctx *ctx)
 	int len, ret;

 	while (1) {
-		ret = _ckpt_read(STDIN_FILENO, &h, sizeof(h));
+		ret = _ckpt_read(global_input_fd, &h, sizeof(h));
 ckpt_dbg("ret %d len %d type %d\n", ret, h.len, h.type);
 		if (ret == 0)
 			break;
@@ -1915,7 +1924,7 @@ ckpt_dbg("ret %d len %d type %d\n", ret, h.len, h.type);
 		h.len -= sizeof(h);
 		if (h.type == CKPT_HDR_ERROR) {
 			len = (h.len > BUFSIZE ? BUFSIZE : h.len);
-			ret = read(STDIN_FILENO, ctx->buf, len);
+			ret = read(global_input_fd, ctx->buf, len);
 			if (ret < 0)
 				ckpt_abort(ctx, "error record");
 			errno = EIO;
@@ -1926,7 +1935,7 @@ ckpt_dbg("ret %d len %d type %d\n", ret, h.len, h.type);

 		while (h.len) {
 			len = (h.len > BUFSIZE ? BUFSIZE : h.len);
-			ret = read(STDIN_FILENO, ctx->buf, len);
+			ret = read(global_input_fd, ctx->buf, len);
 			if (ret == 0)
 				ckpt_abort(ctx, "short record");
 			if (ret < 0)
@@ -2163,7 +2172,7 @@ static int ckpt_read_obj(struct ckpt_ctx *ctx,
 {
 	int ret;

-	ret = ckpt_read(STDIN_FILENO, h, sizeof(*h));
+	ret = ckpt_read(global_input_fd, h, sizeof(*h));
 	if (ret < 0)
 		return ret;
 	if (h->len < sizeof(*h) || h->len > n) {
@@ -2172,7 +2181,7 @@ static int ckpt_read_obj(struct ckpt_ctx *ctx,
 	}
 	if (h->len == sizeof(*h))
 		return 0;
-	return ckpt_read(STDIN_FILENO, buf, h->len - sizeof(*h));
+	return ckpt_read(global_input_fd, buf, h->len - sizeof(*h));
 }

 static int ckpt_read_obj_type(struct ckpt_ctx *ctx, void *buf, int n, int type)
-- 
1.6.6.1
