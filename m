From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 34/36] Make cr_may_checkpoint_task() check each
	namespace individually
Date: Tue,  7 Apr 2009 08:27:42 -0400
Message-ID: <1239107264-21775-35-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index efd8109..630b52c 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -233,6 +233,7 @@ static int cr_write_all_tasks(struct cr_ctx *ctx)
 static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 {
 	struct pid_namespace *ns = ctx->root_nsproxy->pid_ns;
+	int ret = 0;
 
 	cr_debug("check %d\n", task_pid_nr_ns(t, ns));
 
@@ -256,11 +257,20 @@ static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 	    t->real_parent == ctx->root_task->real_parent)
 		return -EINVAL;
 
-	/* FIX: change this for nested containers */
-	if (task_nsproxy(t) != ctx->root_nsproxy)
-		return -EPERM;
+	rcu_read_lock();
+	if (task_nsproxy(t)->uts_ns != ctx->root_nsproxy->uts_ns)
+		ret = -EPERM;
+	if (task_nsproxy(t)->ipc_ns != ctx->root_nsproxy->ipc_ns)
+		ret = -EPERM;
+	if (task_nsproxy(t)->mnt_ns != ctx->root_nsproxy->mnt_ns)
+		ret = -EPERM;
+	if (task_nsproxy(t)->pid_ns != ctx->root_nsproxy->pid_ns)
+		ret = -EPERM;
+	if (task_nsproxy(t)->net_ns != ctx->root_nsproxy->net_ns)
+		ret = -EPERM;
+	rcu_read_unlock();
 
-	return 0;
+	return ret;
 }
 
 #define CR_HDR_PIDS_CHUNK	256
-- 
1.5.4.3
