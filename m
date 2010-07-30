From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/4] restart: check for overflow when counting (nested) vpids
Date: Fri, 30 Jul 2010 13:08:30 -0400
Message-ID: <1280509713-6745-1-git-send-email-orenl@cs.columbia.edu>
References: <1280169472.7875.4290.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280169472.7875.4290.camel@localhost>
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
Cc: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/restart.c b/restart.c
index d813269..b281ca2 100644
--- a/restart.c
+++ b/restart.c
@@ -1780,14 +1780,10 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 			flags |= CLONE_NEWPID;
 		}
 		if (flags & CLONE_NEWPID && !ctx->args->pidns) {
-			ckpt_err("Must use --pidns for nested pidns container");
+			ckpt_err("need --pidns for nested pidns container");
 			errno = -EINVAL;
 			return -1;
 		}
-#if 0
-		if (flags & CLONE_NEWPID)
-			clone_args.nr_pids--;
-#endif
 #endif /* CLONE_NEWPID */
 	}
 
@@ -2375,17 +2371,26 @@ static int ckpt_read_vpids(struct ckpt_ctx *ctx)
 {
 	int i, len, ret;
 
-	for (i = 0; i < ctx->pids_nr; i++)
-		ctx->vpids_nr += ctx->pids_arr[i].depth;
+	for (i = 0; i < ctx->pids_nr; i++) {
+		if (ctx->pids_arr[i].depth < 0) {
+			ckpt_err("Invalid depth %d for pid %d",
+				 ctx->pids_arr[i].depth,
+				 ctx->tasks_arr[i].pid);
+			errno = -EINVAL;
+			return -1;
+		}
 
-	ckpt_dbg("number of vpids: %d\n", ctx->vpids_nr);
+		ctx->vpids_nr += ctx->pids_arr[i].depth;
 
-	if (ctx->vpids_nr < 0) {
-		ckpt_err("Invalid number of vpids %d", ctx->vpids_nr);
-		errno = -EINVAL;
-		return -1;
+		if(ctx->vpids_nr < 0) {
+			ckpt_err("Number of vpids overflowed");
+			errno = -E2BIG;
+			return -1;
+		}
 	}
 
+	ckpt_dbg("number of vpids: %d\n", ctx->vpids_nr);
+
 	if (!ctx->vpids_nr)
 		return 0;
 
-- 
1.7.0.4
