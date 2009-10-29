From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 11/17] have restore_debug_free use ckpt_error
Date: Thu, 29 Oct 2009 15:54:36 -0500
Message-ID: <1256849682-858-12-git-send-email-serue@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 9b75de8..3f23397 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -137,15 +137,16 @@ void restore_debug_free(struct ckpt_ctx *ctx)
 	 */
 	list_for_each_entry(s, &ctx->task_status, list)
 		count++;
-	ckpt_debug("%d tasks registered, nr_tasks was %d nr_total %d\n",
+	ckpt_error(ctx, "%d tasks registered, nr_tasks was %d nr_total %d\n",
 		   count, ctx->nr_tasks, atomic_read(&ctx->nr_total));
 
-	ckpt_debug("active pid was %d, ctx->errno %d\n", ctx->active_pid,
+	ckpt_error(ctx, "active pid was %d, ctx->errno %d\n", ctx->active_pid,
 		   ctx->errno);
-	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
+	ckpt_error(ctx, "kflags %lu uflags %lu oflags %lu", ctx->kflags,
 		   ctx->uflags, ctx->oflags);
 	for (i = 0; i < ctx->active_pid; i++)
-		ckpt_debug("task[%d] to run %d\n", i, ctx->pids_arr[i].vpid);
+		ckpt_error(ctx, "task[%d] to run %d\n", i,
+			   ctx->pids_arr[i].vpid);
 
 	list_for_each_entry_safe(s, p, &ctx->task_status, list) {
 		if (s->flags & RESTART_DBG_COORD)
@@ -170,7 +171,8 @@ void restore_debug_free(struct ckpt_ctx *ctx)
 			state = "Exited";
 		else
 			state = "??????";
-		ckpt_debug("pid %d type %s state %s\n", s->pid, which, state);
+		ckpt_error(ctx, "pid %d type %s state %s\n", s->pid, which,
+			   state);
 		list_del(&s->list);
 		kfree(s);
 	}
-- 
1.6.1
