From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] fix -ESRCH on self-restart
Date: Mon, 15 Jun 2009 15:20:22 -0500
Message-ID: <20090615202022.GA18223@us.ibm.com>
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

when doing a self-restart, we can't search for ourselves on our
list of children...

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index b87d0e1..13f48fb 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -569,16 +569,16 @@ static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
 	return ret;
 }
 
-/* setup restart-specific parts of ctx */
-static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
 {
-	struct task_struct *task;
-	struct nsproxy *nsproxy;
+	struct task_struct *task = current;
 
-	/*
-	 * No need for explicit cleanup here, because if an error
-	 * occurs then ckpt_ctx_free() is eventually called.
-	 */
+	if (ctx->uflags & RESTART_TASKSELF) {
+		ctx->root_pid = pid;
+		ctx->root_task = task;
+		get_task_struct(current);
+		return current;
+	}
 
 	read_lock(&tasklist_lock);
 	list_for_each_entry(task, &current->children, sibling) {
@@ -590,11 +590,25 @@ static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
 		}
 	}
 	read_unlock(&tasklist_lock);
+	return task;
+}
+
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct nsproxy *nsproxy;
+
+	/*
+	 * No need for explicit cleanup here, because if an error
+	 * occurs then ckpt_ctx_free() is eventually called.
+	 */
+
+	ctx->root_task = choose_root_task(ctx, pid);
 	if (!ctx->root_task)
 		return -ESRCH;
 
 	rcu_read_lock();
-	nsproxy = task_nsproxy(task);
+	nsproxy = task_nsproxy(ctx->root_task);
 	if (nsproxy) {
 		get_nsproxy(nsproxy);
 		ctx->root_nsproxy = nsproxy;
-- 
1.6.1
