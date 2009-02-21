From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH] Check may_checkpoint() early
Date: Sat, 21 Feb 2009 12:12:21 -0800
Message-ID: <20090221201221.GA13532@us.ibm.com>
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
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Mon, 16 Feb 2009 12:05:50 -0800
Subject: [PATCH] Check 'may_checkpoint()' early

We currently check if a task is checkpointable when writing the task
information to checkpoint file. The small downside of doing this check
late is that we may have processed several processes in the tree before
hitting one that cannot be checkpointed.

We anyway walk the process tree we are checkpointing earlier, while
counting the tasks. We could check if all processes in the tree are
checkpointable at that time and fail early if any of them are not.
Since the process tree should be frozen, checking earlier should not
matter ?

For now, the patch leaves the existing check in cr_write_pids(). We
can remove that later.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint/checkpoint.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 64155de..2bbb409 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -347,11 +347,18 @@ static int cr_tree_count_tasks(struct cr_ctx *ctx)
 	struct task_struct **tasks_arr = ctx->tasks_arr;
 	int tasks_nr = ctx->tasks_nr;
 	int nr = 0;
+	int ret;
 
 	read_lock(&tasklist_lock);
 
 	/* count tasks via DFS scan of the tree */
 	while (1) {
+		ret = cr_may_checkpoint_task(task, ctx);
+		if (ret < 0) {
+			nr = ret;
+			break;
+		}
+
 		if (tasks_arr) {
 			/* unlikely... but if so then try again later */
 			if (nr == tasks_nr) {
@@ -409,6 +416,8 @@ static int cr_build_tree(struct cr_ctx *ctx)
 
 	/* count tasks (no side effects) */
 	n = cr_tree_count_tasks(ctx);
+	if (n < 0)
+		return n;
 
 	ctx->tasks_nr = n;
 	ctx->tasks_arr = kzalloc(n * sizeof(*ctx->tasks_arr), GFP_KERNEL);
-- 
1.5.2.5
