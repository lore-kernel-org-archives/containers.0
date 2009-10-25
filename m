From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] user-cr: fix race in ckpt_coordinator_pidns and --no-wait
Date: Sun, 25 Oct 2009 18:12:47 -0400
Message-ID: <1256508767-2356-1-git-send-email-orenl@librato.com>
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

In a restart with --pidns, if the root-task has pid != 1, then we fork
a new process as the init of the new pid-ns, and that process becomes
the coordinator (instead of 'restart').

The original 'restart' process will then wait for the new coordinator
to exit (when all restarted tasks and their descendants terminate).
With --no-wait, 'restart' doesn't wait for them to exit, but should
simply return as soon as the restart completes.

However, it has no way to know when (and if) the restart completes,
because the coordiantor calls sys_restart(). As a result, it may exit
early, exiting the feeder (which is a thread) too, and fail the
restart.

This patch adds a pipe through which the new coordinator reports the
status of the restart back to its parent, so that the parent only
exits once it knows that the operation has completed.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/restart.c b/restart.c
index fbaab88..14d8aec 100644
--- a/restart.c
+++ b/restart.c
@@ -254,6 +254,7 @@ struct ckpt_ctx {
 
 	int pipe_child[2];	/* for children to report status */
 	int pipe_feed[2];	/* for feeder to provide input */
+	int pipe_coord[2];	/* for coord to report status (if needed) */
 
 	struct ckpt_pids *pids_arr;
 	struct ckpt_pids *copy_arr;
@@ -848,7 +849,32 @@ static int ckpt_probe_child(pid_t pid, char *str)
 #ifdef CLONE_NEWPID
 static int __ckpt_coordinator(void *arg)
 {
-	return ckpt_coordinator((struct ckpt_ctx *) arg);
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) arg;
+
+	if (!ctx->args->wait)
+		close(ctx->pipe_coord[0]);
+
+	return ckpt_coordinator(ctx);
+}
+
+static int ckpt_coordinator_status(struct ckpt_ctx *ctx)
+{
+	int status = -1;
+	int ret;
+
+	close(ctx->pipe_coord[1]);
+
+	ret = read(ctx->pipe_coord[0], &status, sizeof(status));
+	if (ret < 0)
+		perror("read coordinator status");
+	else if (ret == 0) {
+		/* coordinator failed to report */
+		ckpt_dbg("Coordinator failed to report status.");
+	} else
+		status = 0;
+
+	close(ctx->pipe_coord[0]);
+	return status;
 }
 
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
@@ -859,6 +885,15 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 
 	ckpt_dbg("forking coordinator in new pidns\n");
 
+	/*
+	 * We won't wait for (collect) the coordinator, so we use a
+	 * pipe instead for the coordinator to report success/failure.
+	 */
+	if (!ctx->args->wait && pipe(ctx->pipe_coord)) {
+		perror("pipe");
+		return -1;
+	}
+
 	stk = malloc(PTHREAD_STACK_MIN);
 	if (!stk) {
 		perror("coordinator stack malloc");
@@ -893,7 +928,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	if (ctx->args->wait)
 		return ckpt_collect_child(ctx);
 	else
-		return 0;
+		return ckpt_coordinator_status(ctx);
 }
 #else
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
@@ -941,17 +976,24 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	ckpt_verbose("Success\n");
 	ckpt_dbg("restart succeeded\n");
 
+	ret = 0;
+
 	if (ctx->args->pidns && ctx->tasks_arr[0].pid != 1) {
 		/*
 		 * If root task isn't container init, we must stay
 		 * around and be reaper until all tasks are gone.
 		 * Otherwise, container will die as soon as we exit.
 		 */
+		if (!ctx->args->wait) {
+			/* report status because parent won't wait for us */
+			if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
+				perror("failed to report status");
+				exit(1);
+			}
+		}
 		ret = ckpt_pretend_reaper(ctx);
 	} else if (ctx->args->wait) {
 		ret = ckpt_collect_child(ctx);
-	} else {
-		ret = 0;
 	}
 
 	if (ret < 0)
-- 
1.6.0.4
