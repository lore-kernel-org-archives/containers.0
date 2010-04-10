From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH][usercr]: Remove exit() calls in app_restart()
Date: Fri, 9 Apr 2010 20:25:04 -0700
Message-ID: <20100410032504.GA7265@us.ibm.com>
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

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 9 Apr 2010 18:36:46 -0700
Subject: [RFC][PATCH] Remove exit() calls from app_restart().

app_restart() will eventually become an API for USERCR. When it encounters
an error, app_restart() should return an error code rather than exit. So
replace (most) exit() calls in app_restart() with a return code. Of course
there maybe situations where app_restart() may fail and leave some child
processes, but hopefully this patch does not worsen those cases :-)

NOTE:	There are few exit() calls remaining in restart.c. These fall into
	two categories. First category of exit() calls are those made in
	child processes (i.e processes created by app_restart()). Those exits
	are fine (and required).

	The second category of the exit() calls are those in signal handlers.
	We should remove these exits when we define better API to address
	signal-handling in app_restart().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |  102 +++++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 59 insertions(+), 43 deletions(-)

diff --git a/restart.c b/restart.c
index c5c65a2..3224335 100644
--- a/restart.c
+++ b/restart.c
@@ -335,7 +335,7 @@ static void sigint_handler(int sig)
 static int freezer_prepare(struct ckpt_ctx *ctx)
 {
 	char *freezer;
-	int fd, ret;
+	int fd, n, ret;
 
 #define FREEZER_THAWED  "THAWED"
 
@@ -345,25 +345,31 @@ static int freezer_prepare(struct ckpt_ctx *ctx)
 		return -1;
 	}
 
+	ret = -1;
 	sprintf(freezer, "%s/freezer.state", ctx->args->freezer);
 
 	fd = open(freezer, O_WRONLY, 0);
 	if (fd < 0) {
 		ckpt_perror("freezer path");
-		free(freezer);
-		exit(1);
+		goto out_free;
 	}
-	ret = write(fd, FREEZER_THAWED, sizeof(FREEZER_THAWED)); 
-	if (ret != sizeof(FREEZER_THAWED)) {
+
+	n = write(fd, FREEZER_THAWED, sizeof(FREEZER_THAWED)); 
+	if (n != sizeof(FREEZER_THAWED)) {
 		ckpt_perror("thawing freezer");
-		free(freezer);
-		exit(1);
+		goto out_close;
 	}
 
 	sprintf(freezer, "%s/tasks", ctx->args->freezer);
 	ctx->freezer = freezer;
+	ret = 0;
+
+out_close:
 	close(fd);
-	return 0;
+
+out_free:
+	free(freezer);
+	return ret;
 }
 
 static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
@@ -371,7 +377,6 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 	char pidstr[16];
 	int fd, n, ret;
 
-
 	fd = open(ctx->freezer, O_WRONLY, 0);
 	if (fd < 0) {
 		ckpt_perror("freezer path");
@@ -406,7 +411,7 @@ int process_args(struct app_restart_args *args)
 	if (args->infd >= 0) {
 		if (dup2(args->infd, STDIN_FILENO) < 0) {
 			ckpt_perror("dup2 input file");
-			exit(1);
+			return -1;
 		}
 		if (args->infd != STDIN_FILENO)
 			close(args->infd);
@@ -423,7 +428,7 @@ int process_args(struct app_restart_args *args)
 	if (args->pidns) {
 		ckpt_err("This version of restart was compiled without "
 		       "support for --pidns.\n");
-		exit(1);
+		return -1;
 	}
 #endif
 
@@ -431,7 +436,7 @@ int process_args(struct app_restart_args *args)
 	if (global_debug) {
 		ckpt_err("This version of restart was compiled without "
 		       "support for --debug.\n");
-		exit(1);
+		return -1;
 	}
 #endif
 
@@ -443,7 +448,7 @@ int process_args(struct app_restart_args *args)
 	if (args->pids) {
 		ckpt_err("This version of restart was compiled without "
 		       "support for --pids.\n");
-		exit(1);
+		return -1;
 	}
 #endif
 #endif
@@ -452,7 +457,7 @@ int process_args(struct app_restart_args *args)
 	    (args->pids || args->pidns || args->show_status ||
 	     args->copy_status || args->freezer)) {
 		ckpt_err("Invalid mix of --self with multiprocess options\n");
-		exit(1);
+		return -1;
 	}
 
 	return 0;
@@ -472,29 +477,30 @@ int app_restart(struct app_restart_args *args)
 
 	/* freezer preparation */
 	if (args->freezer && freezer_prepare(&ctx) < 0)
-		exit(1);
+		return -1;
 
+	ret = -1;
 	/* self-restart ends here: */
 	if (args->self) {
 		/* private mounts namespace ? */
 		if (args->mntns && unshare(CLONE_NEWNS | CLONE_FS) < 0) {
 			ckpt_perror("unshare");
-			exit(1);
+			goto cleanup_freezer;
 		}
 		/* chroot ? */
 		if (args->root && chroot(args->root) < 0) {
 			ckpt_perror("chroot");
-			exit(1);
+			goto cleanup_freezer;
 		}
 		/* remount /dev/pts ? */
 		if (args->mnt_pty && ckpt_remount_devpts(&ctx) < 0)
-			exit(1);
+			goto cleanup_freezer;
 
 		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args->klogfd);
 
 		/* reach here if restart(2) failed ! */
 		ckpt_perror("restart");
-		exit(1);
+		goto cleanup_freezer;
 	}
 
 	setpgrp();
@@ -502,48 +508,50 @@ int app_restart(struct app_restart_args *args)
 	ret = ckpt_read_header(&ctx);
 	if (ret < 0) {
 		ckpt_perror("read c/r header");
-		exit(1);
+		goto cleanup_freezer;
 	}
 		
 	ret = ckpt_read_header_arch(&ctx);
 	if (ret < 0) {
 		ckpt_perror("read c/r header arch");
-		exit(1);
+		goto cleanup_freezer;
 	}
 
 	ret = ckpt_read_container(&ctx);
 	if (ret < 0) {
 		ckpt_perror("read c/r container section");
-		exit(1);
+		goto cleanup_freezer;
 	}
 
 	ret = ckpt_read_tree(&ctx);
 	if (ret < 0) {
 		ckpt_perror("read c/r tree");
-		exit(1);
+		goto cleanup_freezer;
 	}
 
 	ret = ckpt_read_vpids(&ctx);
 	if (ret < 0) {
 		ckpt_perror("read c/r tree");
-		exit(1);
+		goto cleanup_freezer;
 	}
 
 	/* build creator-child-relationship tree */
-	if (hash_init(&ctx) < 0)
-		exit(1);
+	ret = hash_init(&ctx);
+	if (ret < 0)
+		goto cleanup_freezer;
+
 	ret = ckpt_build_tree(&ctx);
 	hash_exit(&ctx);
 	if (ret < 0)
-		exit(1);
+		goto cleanup_freezer;
 
 	ret = assign_vpids(&ctx);
 	if (ret < 0)
-		exit(1);
+		goto cleanup_freezer;
 
 	ret = ckpt_fork_feeder(&ctx);
 	if (ret < 0)
-		exit(1);
+		goto cleanup_freezer;
 
 	/*
 	 * Have the first child in the restarted process tree
@@ -587,6 +595,8 @@ int app_restart(struct app_restart_args *args)
 	if (ret >= 0)
 		ret = global_child_pid;
 
+cleanup_freezer:
+	free(ctx.freezer);
 	return ret;
 }
 
@@ -648,7 +658,7 @@ static int ckpt_collect_child(struct ckpt_ctx *ctx)
 		status = global_child_status;
 	} else if (pid < 0) {
 		ckpt_perror("WEIRD: collect child task");
-		exit(1);
+		return -1;
 	}
 
 	return ckpt_parse_status(status, mimic, verbose);
@@ -742,14 +752,14 @@ static int ckpt_probe_child(pid_t pid, char *str)
 	ret = waitpid(pid, &status, WNOHANG);
 	if (ret == pid) {
 		report_exit_status(status, str, 0);
-		exit(1);
+		return -1;
 	} else if (ret < 0 && errno == ECHILD) {
 		ckpt_err("WEIRD: %s exited without trace (%s)\n",
 			 str, strerror(errno));
-		exit(1);
+		return -1;
 	} else if (ret != 0) {
 		ckpt_err("waitpid for %s (%s)", str, strerror(errno));
-		exit(1);
+		return -1;
 	}
 	return 0;
 }
@@ -841,10 +851,11 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 		return -1;
 	}
 
+	ret = -1;
 	stk = genstack_alloc(PTHREAD_STACK_MIN);
 	if (!stk) {
 		ckpt_perror("coordinator genstack_alloc");
-		return -1;
+		goto out_close;
 	}
 	sp = genstack_sp(stk);
 
@@ -858,7 +869,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	genstack_release(stk);
 	if (coord_pid < 0) {
 		ckpt_perror("clone coordinator");
-		return coord_pid;
+		goto out_close;
 	}
 	global_child_pid = coord_pid;
 
@@ -872,7 +883,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	 * signal handler was plugged; verify that it's still there.
 	 */
 	if (ckpt_probe_child(coord_pid, "coordinator") < 0)
-		return -1;
+		goto out_close;
 
 	ctx->args->copy_status = copy;
 
@@ -881,13 +892,18 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	if (ret == 0 && ctx->args->wait)
 		ret = ckpt_collect_child(ctx);
 
+out_close:
+	if (ret < 0) {
+		close(ctx->pipe_coord[0]);
+		close(ctx->pipe_coord[1]);
+	}
 	return ret;
 }
 #else /* CLONE_NEWPID */
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 {
 	ckpt_err("logical error: ckpt_coordinator_pidns unexpected\n");
-	exit(1);
+	return -1;
 }
 #endif /* CLONE_NEWPID */
 
@@ -899,7 +915,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 
 	root_pid = ckpt_fork_child(ctx, &ctx->tasks_arr[0]);
 	if (root_pid < 0)
-		exit(1);
+		return -1;
 	global_child_pid = root_pid;
 
 	/* catch SIGCHLD to detect errors during hierarchy creation */
@@ -912,7 +928,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	 * signal handler was plugged; verify that it's still there.
 	 */
 	if (ckpt_probe_child(root_pid, "root task") < 0)
-		exit(1);
+		return -1;
 
 	if (ctx->args->keep_frozen)
 		flags |= RESTART_FROZEN;
@@ -925,7 +941,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		ckpt_perror("restart failed");
 		ckpt_verbose("Failed\n");
 		ckpt_dbg("restart failed ?\n");
-		exit(1);
+		return -1;
 	}
 
 	ckpt_verbose("Success\n");
@@ -937,7 +953,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		/* Report success/failure to the parent */
 		if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
 			ckpt_perror("failed to report status");
-			exit(1);
+			return -1;
 		}
 
 		/*
@@ -1835,12 +1851,12 @@ static int ckpt_fork_feeder(struct ckpt_ctx *ctx)
 
 	if (pipe(ctx->pipe_feed)) {
 		ckpt_perror("pipe");
-		exit(1);
+		return -1;
 	}
 
 	if (pipe(ctx->pipe_child) < 0) {
 		ckpt_perror("pipe");
-		exit(1);
+		return -1;
 	}
 
 	/*
