From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] Make cr_may_checkpoint_task() check each namespace
	individually
Date: Tue, 31 Mar 2009 13:58:25 -0700
Message-ID: <1238533107-11796-2-git-send-email-danms@us.ibm.com>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238533107-11796-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ef35754..c2f0e16 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -302,8 +302,19 @@ static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 	if (t != current && !frozen(t))
 		return -EBUSY;
 
-	/* FIXME: change this for nested containers */
-	if (task_nsproxy(t) != ctx->root_nsproxy)
+	if (task_nsproxy(t)->uts_ns != ctx->root_nsproxy->uts_ns)
+		return -EPERM;
+
+	if (task_nsproxy(t)->ipc_ns != ctx->root_nsproxy->ipc_ns)
+		return -EPERM;
+
+	if (task_nsproxy(t)->mnt_ns != ctx->root_nsproxy->mnt_ns)
+		return -EPERM;
+
+	if (task_nsproxy(t)->pid_ns != ctx->root_nsproxy->pid_ns)
+		return -EPERM;
+
+	if (task_nsproxy(t)->net_ns != ctx->root_nsproxy->net_ns)
 		return -EPERM;
 
 	return 0;
-- 
1.5.6.3
