From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr v19-rc1] Revert "restart: coordinator in new pidns
	to always report status via pipe"
Date: Thu, 19 Nov 2009 09:37:54 -0600
Message-ID: <20091119153754.GA18377@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Oren,

commit 464ff47b6a1241410f432a55ce4bf93c8bd10861 isn't right.  I guess
the problem is that ckpt_coordinator_status(), doesn't do a waitpid
on the global_child_pid?  So if I do a 'restart -w --pids', then the
restarted task proceeds just fine, but restart immediately returns.

Maybe the right answer is to modify ckpt_coordinator_status() to
do a waitpid if ctx->args->wait, but just reverting this commit
doesn't seem to have any ill effects - all my default tests pass.

This reverts commit 464ff47b6a1241410f432a55ce4bf93c8bd10861.
---
 restart.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/restart.c b/restart.c
index d5d069a..cfc359b 100644
--- a/restart.c
+++ b/restart.c
@@ -994,12 +994,10 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 	ckpt_dbg("forking coordinator in new pidns\n");
 
 	/*
-	 * The coordinator report restart susccess/failure via pipe.
-	 * (It cannot use return value, because the in the default
-	 * --wait --copy-status case it is already used to report the
-	 * root-task's return value).
+	 * We won't wait for (collect) the coordinator, so we use a
+	 * pipe instead for the coordinator to report success/failure.
 	 */
-	if (pipe(ctx->pipe_coord) < 0) {
+	if (!ctx->args->wait && pipe(ctx->pipe_coord)) {
 		perror("pipe");
 		return -1;
 	}
@@ -1035,7 +1033,10 @@ static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
 		return -1;
 
 	ctx->args->copy_status = copy;
-	return ckpt_coordinator_status(ctx);
+	if (ctx->args->wait)
+		return ckpt_collect_child(ctx);
+	else
+		return ckpt_coordinator_status(ctx);
 }
 #else
 static int ckpt_coordinator_pidns(struct ckpt_ctx *ctx)
@@ -1093,13 +1094,13 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 		 * around and be reaper until all tasks are gone.
 		 * Otherwise, container will die as soon as we exit.
 		 */
-
-		/* Report success/failure to the parent */
-		if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
-			perror("failed to report status");
-			exit(1);
+		if (!ctx->args->wait) {
+			/* report status because parent won't wait for us */
+			if (write(ctx->pipe_coord[1], &ret, sizeof(ret)) < 0) {
+				perror("failed to report status");
+				exit(1);
+			}
 		}
-
 		ret = ckpt_pretend_reaper(ctx);
 	} else if (ctx->args->wait) {
 		ret = ckpt_collect_child(ctx);
-- 
1.6.1.1
