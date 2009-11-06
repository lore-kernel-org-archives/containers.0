From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] don't swap 0 sids if ctx->arg->pids
Date: Fri, 6 Nov 2009 01:37:08 -0600
Message-ID: <20091106073708.GA18978@us.ibm.com>
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

It breaks restart --pidns

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/restart.c b/restart.c
index 47d729a..f523adf 100644
--- a/restart.c
+++ b/restart.c
@@ -2039,12 +2039,13 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	 * NOTE: thanks to the construction of tasks_arr[], the first
 	 * ctx->pid_nr entries in both arrays match (the same pids).
 	 */
-	for (m = 0; m < ctx->pids_nr; m++) {
-		if (ctx->tasks_arr[m].flags & TASK_ZERO_SID)
-			ctx->copy_arr[m].vsid = coord_sid;
-		if (ctx->tasks_arr[m].flags & TASK_ZERO_PGID)
-			ctx->copy_arr[m].vpgid = coord_sid;
-	}
+	if (!ctx->args->pids)
+		for (m = 0; m < ctx->pids_nr; m++) {
+			if (ctx->tasks_arr[m].flags & TASK_ZERO_SID)
+				ctx->copy_arr[m].vsid = coord_sid;
+			if (ctx->tasks_arr[m].flags & TASK_ZERO_PGID)
+				ctx->copy_arr[m].vpgid = coord_sid;
+		}
 
 	memcpy(ctx->pids_arr, ctx->copy_arr, len);
 	close(ctx->pipe_in);
-- 
1.6.1.1
