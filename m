From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 1/3] restart: coordinator in new pidns to always report status
	via pipe
Date: Tue, 10 Nov 2009 17:04:50 -0500
Message-ID: <1257890692-28046-1-git-send-email-orenl@librato.com>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Serge Hallyn reports:
  "another question: if i run 'restart < out' and sys_restart returns
  due to a -EPERM on some object, then restart.c returns 1.  but if i
  'restart --pids', then it reports the error and returns 0.  unless i
  add --copy-status to the flags.  that seems inconsistent?"

It was with a subtree checkpoint in a child pidns, root-task is not
pid 1, So, the restarts calls ckpt_coordinator_pidns() execution.

In commit 2000bbb4b9... "restart: fix race in ckpt_coordinator_pidns
and --no-wait" adds a pipe for a coordinator in a new pids to report
success/failure of the restart operation back to the parent when the
parent does not wish to wait.

IOW, the coordinator's exit value is overloaded - used once to report
success/failure and once (optionally) to report root-tasks exit status.

This patch fixes this by extending the previous commit to make the
coordinator-pidns always report the restart status via the pipe, and
only use the exit status for --wait --copy-status case.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/restart.c b/restart.c
index 35c54ea..5871bbf 100644
--- a/restart.c
+++ b/restart.c
@@ -942,10 +942,12 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	ckpt_dbg("forking coordinator in new pidns\n");
 
 	/*
-	 * We won't wait for (collect) the coordinator, so we use a
-	 * pipe instead for the coordinator to report success/failure.
+	 * The coordinator report restart susccess/failure via pipe.
+	 * (It cannot use return value, because the in the default
+	 * --wait --copy-status case it is already used to report the
+	 * root-task's return value).
 	 */
-	if (!ctx->args->wait && pipe(ctx->pipe_coord)) {
+	if (pipe(ctx->pipe_coord) < 0) {
 		perror("pipe");
 		return -1;
 	}
@@ -981,10 +983,7 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 		return -1;
 
 	ctx->args->copy_status = copy;
-	if (ctx->args->wait)
-		return ckpt_collect_child(ctx);
-	else
-		return ckpt_coordinator_status(ctx);
+	return ckpt_coordinator_status(ctx);
 }
 #else
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
@@ -1040,13 +1039,13 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		 * around and be reaper until all tasks are gone.
 		 * Otherwise, container will die as soon as we exit.
 		 */
-		if (!ctx->args->wait) {
-			/* report status because parent won't wait for us */
-			if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
-				perror("failed to report status");
-				exit(1);
-			}
+
+		/* Report success/failure to the parent */
+		if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
+			perror("failed to report status");
+			exit(1);
 		}
+
 		ret = ckpt_pretend_reaper(ctx);
 	} else if (ctx->args->wait) {
 		ret = ckpt_collect_child(ctx);
-- 
1.6.0.4
