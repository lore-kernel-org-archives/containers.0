From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: piggyback on task->saved_sigmask and drop
	task->checkpoint_data
Date: Thu, 18 Feb 2010 23:15:03 -0500
Message-ID: <1266552903-26547-1-git-send-email-orenl@cs.columbia.edu>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The field task->checkpoint_data was introduced to hold the saved
mask of a task so that it could be restored last thing before a
task returns to userspace.

Given that we can piggyback on the existing task->saved_sigmask field,
this patch drops the special checkpoint_data pointer.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/process.c             |   18 ++----------------
 checkpoint/signal.c              |    4 ++--
 include/linux/checkpoint_types.h |    4 ----
 include/linux/sched.h            |    1 -
 4 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 94cd0c1..f917112 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -858,11 +858,6 @@ int pre_restore_task(void)
 {
 	sigset_t sigset;
 
-	/* task-specific restart data: freed from post_restore_task() */
-	current->checkpoint_data = kzalloc(sizeof(struct ckpt_data), GFP_KERNEL);
-	if (!current->checkpoint_data)
-		return -ENOMEM;
-
 	/*
 	 * Block task's signals to avoid interruptions due to signals,
 	 * say, from restored timers, file descriptors etc. Signals
@@ -872,8 +867,7 @@ int pre_restore_task(void)
 	 * i/o notification may fail the restart if a signal occurs
 	 * before that task completed its restore. FIX ?
 	 */
-
-	current->checkpoint_data->blocked = current->blocked;
+	current->saved_sigmask = current->blocked;
 
 	sigfillset(&sigset);
 	sigdelset(&sigset, SIGKILL);
@@ -886,16 +880,8 @@ int pre_restore_task(void)
 /* finish up task restore */
 void post_restore_task(void)
 {
-	/* can happen if restart failed early */
-	if (!current->checkpoint_data)
-		return;
-
 	/* only now is it safe to unblock the restored task's signals */
-	sigprocmask(SIG_SETMASK, &current->checkpoint_data->blocked, NULL);
-
-	/* task-specific restart data: allocated in pre_restore_task() */
-	kfree(current->checkpoint_data);
-	current->checkpoint_data = NULL;
+	sigprocmask(SIG_SETMASK, &current->saved_sigmask, NULL);
 }
 
 /* read the entire state of the current task */
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 609e924..d448278 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -719,10 +719,10 @@ int restore_task_signal(struct ckpt_ctx *ctx)
 
 	/*
 	 * Unblocking signals now may affect us in wait_task_sync().
-	 * Instead, save blocked mask in current->checkpoint_data for
+	 * Instead, save blocked mask in current->saved_sigmaks for
 	 * post_restore_task().
 	 */
-	current->checkpoint_data->blocked = blocked;
+	current->saved_sigmask = blocked;
 
 	ckpt_hdr_put(ctx, h);
 	return 0;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 51efd5a..5d5e00d 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -29,10 +29,6 @@ struct ckpt_stats {
 	int user_ns;
 };
 
-struct ckpt_data {
-	sigset_t blocked;
-};
-
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 965b6c6..a70d7d1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1584,7 +1584,6 @@ struct task_struct {
 #endif
 #ifdef CONFIG_CHECKPOINT
 	struct ckpt_ctx *checkpoint_ctx;
-	struct ckpt_data *checkpoint_data;
 #endif
 };
 
-- 
1.6.3.3
