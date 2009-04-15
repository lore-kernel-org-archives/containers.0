From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Save and restore task->personality
Date: Wed, 15 Apr 2009 12:10:16 -0400
Message-ID: <1239811816-21082-1-git-send-email-danms@us.ibm.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds a spot in the task record to save the personality value
of the task_struct.

It also masks out READ_IMPLIES_EXEC before starting to avoid read-only
maps being restored as read-exec.  To avoid re-setting this flag too early,
it also introduces a "task_ctx" object to hold information that may be
collected when reading the task structure, but needs to be restored at a
later time (such as after the maps are read).  Since there may be additional
settings that need to be deferred until the end of task restore, I decided
to add the context object and a "cleanup" function to wrap things up.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/ckpt_task.c         |    2 ++
 checkpoint/restart.c           |    8 ++++++++
 checkpoint/rstr_task.c         |   25 +++++++++++++++++++++++--
 include/linux/checkpoint_hdr.h |    2 ++
 4 files changed, 35 insertions(+), 2 deletions(-)

diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index 4d19e31..6a4118a 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -38,6 +38,8 @@ static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
 	hh->exit_code = t->exit_code;
 	hh->exit_signal = t->exit_signal;
 
+	hh->personality = current->personality;
+
 	hh->task_comm_len = TASK_COMM_LEN;
 
 	/* FIXME: save remaining relevant task_struct fields */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index c6bcfac..2ad4b30 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -15,6 +15,7 @@
 #include <linux/magic.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/personality.h>
 #include <asm/syscall.h>
 
 #include "checkpoint_arch.h"
@@ -524,6 +525,13 @@ int do_restart(struct cr_ctx *ctx, pid_t pid)
 {
 	int ret;
 
+	/* Remove the READ_IMPLIES_EXEC flag from our personality
+	 * (if present) so that our restart logic doesn't change read
+	 * maps to read-execute.  If the task had this flag set at
+	 * checkpoint, it will be restored later.
+	 */
+	current->personality &= ~READ_IMPLIES_EXEC;
+
 	if (ctx)
 		ret = do_restart_root(ctx, pid);
 	else
diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
index fe5c059..bb09f99 100644
--- a/checkpoint/rstr_task.c
+++ b/checkpoint/rstr_task.c
@@ -20,8 +20,13 @@
 
 #include "checkpoint_arch.h"
 
+/* Per-task settings that need to be restored at the end of task restart */
+struct cr_task_ctx {
+	unsigned int personality;
+};
+
 /* read the task_struct into the current task */
-static int cr_read_task_struct(struct cr_ctx *ctx)
+static int cr_read_task_struct(struct cr_ctx *ctx, struct cr_task_ctx *tsk_ctx)
 {
 	struct cr_hdr_task *hh;
 	struct task_struct *t = current;
@@ -52,6 +57,8 @@ static int cr_read_task_struct(struct cr_ctx *ctx)
 	}
 	kfree(buf);
 
+	tsk_ctx->personality = hh->personality;
+
 	/* FIXME: restore remaining relevant task_struct fields */
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
@@ -314,12 +321,22 @@ static int cr_read_namespaces(struct cr_ctx *ctx)
 	return ret;
 }
 
+int cr_task_cleanup(struct cr_ctx *ctx, struct cr_task_ctx *tsk_ctx)
+{
+	current->personality = tsk_ctx->personality;
+
+	return 0;
+}
+
 /* read the entire state of the current task */
 int cr_read_task(struct cr_ctx *ctx)
 {
 	int ret;
+	struct cr_task_ctx tsk_ctx;
+
+	memset(&tsk_ctx, 0, sizeof(tsk_ctx));
 
-	ret = cr_read_task_struct(ctx);
+	ret = cr_read_task_struct(ctx, &tsk_ctx);
 	cr_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
@@ -341,6 +358,10 @@ int cr_read_task(struct cr_ctx *ctx)
 		goto out;
 	ret = cr_read_cpu(ctx);
 	cr_debug("cpu: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = cr_task_cleanup(ctx, &tsk_ctx);
+	cr_debug("cleanup: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 92b0336..f3a4e05 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -127,6 +127,8 @@ struct cr_hdr_task {
 	__u32 exit_code;
 	__u32 exit_signal;
 
+	__u64 personality;
+
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
-- 
1.6.1
