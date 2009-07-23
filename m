From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] c/r: [signal 1/3] blocked and template for shared signals
Date: Thu, 23 Jul 2009 10:48:32 -0400
Message-ID: <1248360514-20710-1-git-send-email-orenl@librato.com>
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

This patch adds checkpoint/restart of blocked signals mask
(t->blocked) and a template for shared signals (t->signal).

Because t->signal sharing is tied to threads, we ensure proper sharing
of t->signal (struct signal_struct) for threads only.

Access to t->signal is protected by locking t->sighand->lock.
Therefore, the usual checkpoint_obj() invoking the callback
checkpoint_signal(ctx, signal) is insufficient because the task
pointer is unavailable.

Instead, handling of t->signal sharing is explicit using helpers
like ckpt_obj_lookup_add(), ckpt_obj_fetch() and ckpt_obj_insert().
The actual state is saved (if needed) _after_ the task_objs data.

To prevent tasks from handling restored signals during restart,
set their mask to block all signals and only restore the original
mask at the very end (before the last sync point).

Introduce per-task pointer 'ckpt_data' to temporary store data
for restore actions that are deferred to the end (like restoring
the signal block mask).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/objhash.c           |    9 +++
 checkpoint/process.c           |   65 ++++++++++++++++++++++-
 checkpoint/signal.c            |  114 ++++++++++++++++++++++++++++++++++++---
 include/linux/checkpoint.h     |    6 ++
 include/linux/checkpoint_hdr.h |   14 +++++-
 5 files changed, 197 insertions(+), 11 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index da43bf4..32cf1ff 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -301,6 +301,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_sighand,
 		.restore = restore_sighand,
 	},
+	/* signal object */
+	{
+		.obj_name = "SIGNAL",
+		.obj_type = CKPT_OBJ_SIGNAL,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+		.checkpoint = checkpoint_bad,
+		.restore = restore_bad,
+	},
 	/* ns object */
 	{
 		.obj_name = "NSPROXY",
diff --git a/checkpoint/process.c b/checkpoint/process.c
index d76ab2c..40b2580 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -181,7 +181,8 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int files_objref;
 	int mm_objref;
 	int sighand_objref;
-	int ret;
+	int signal_objref;
+	int first, ret;
 
 	/*
 	 * Shared objects may have dependencies among them: task->mm
@@ -224,14 +225,37 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return sighand_objref;
 	}
 
+	/*
+	 * Handle t->signal differently because the checkpoint method
+	 * for t->signal needs access to owning task_struct to access
+	 * t->sighand (to lock/unlock). First explicitly determine if
+	 * need to save, and only below invoke checkpoint_obj_signal()
+	 * if needed.
+	 */
+	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
+					    CKPT_OBJ_SIGNAL, &first);
+	ckpt_debug("signal: objref %d\n", signal_objref);
+	if (signal_objref < 0)
+		return signal_objref;
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
 	h->sighand_objref = sighand_objref;
+	h->signal_objref = signal_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	/* actually save t->signal, if need to */
+	if (first)
+		ret = checkpoint_obj_signal(ctx, t);
+	if (ret < 0)
+		ckpt_write_err(ctx, "task %d (%s), signal_struct: %d",
+			       task_pid_vnr(t), t->comm, ret);
 
 	return ret;
 }
@@ -374,6 +398,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		goto out;
 	ret = checkpoint_cpu(ctx, t);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_signal(ctx, t);
+	ckpt_debug("task-signal %d\n", ret);
  out:
 	return ret;
 }
@@ -547,6 +575,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 
 	ret = restore_obj_sighand(ctx, h->sighand_objref);
 	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj_signal(ctx, h->signal_objref);
+	ckpt_debug("signal: ret %d (%p)\n", ret, current->signal);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -684,11 +717,37 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* pre_restore_task - prepare the task for restore */
+static int pre_restore_task(struct ckpt_ctx *ctx)
+{
+	sigset_t sigset;
+
+	/*
+	 * Block task's signals to avoid interruptions due to signals,
+	 * say, from restored timers, file descriptors etc. Signals
+	 * will be unblocked when restore completes.
+	 *
+	 * NOTE: tasks with file descriptors set to send a SIGKILL as
+	 * i/o notification may fail the restart if a signal occurs
+	 * before that task completed its restore. FIX ?
+	 */
+	sigfillset(&sigset);
+	sigdelset(&sigset, SIGKILL);
+	sigdelset(&sigset, SIGSTOP);
+	sigprocmask(SIG_SETMASK, &sigset, NULL);
+
+	return 0;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
 	int ret;
 
+	ret = pre_restore_task(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = restore_task_struct(ctx);
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
@@ -716,6 +775,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_creds(ctx);
 	ckpt_debug("creds: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_task_signal(ctx);
  out:
 	return ret;
 }
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 506476b..70df7c4 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -28,7 +28,7 @@ static inline void load_sigset(sigset_t *sigset, struct ckpt_hdr_sigset *h)
 }
 
 /***********************************************************************
- * Checkpoint
+ * sighand checkpoint/collect/restart
  */
 
 int do_checkpoint_sighand(struct ckpt_ctx *ctx, struct sighand_struct *sighand)
@@ -81,10 +81,6 @@ int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
 	return objref;
 }
 
-/***********************************************************************
- * Collect
- */
-
 int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct sighand_struct *sighand;
@@ -101,10 +97,6 @@ int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
-/***********************************************************************
- * Restart
- */
-
 struct sighand_struct *do_restore_sighand(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_sighand *h;
@@ -168,3 +160,107 @@ int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
 
 	return 0;
 }
+
+/***********************************************************************
+ * signal checkpoint/restart
+ */
+
+static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (!h)
+		return -ENOMEM;
+
+	/* fill in later */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	BUG_ON(t->flags & PF_EXITING);
+	return checkpoint_signal(ctx, t);
+}
+
+static int restore_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* fill in later */
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+
+int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
+{
+	struct signal_struct *signal;
+	int ret = 0;
+
+	signal = ckpt_obj_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	if (!IS_ERR(signal)) {
+		/*
+		 * signal_struct is already shared properly as it is
+		 * tied to thread groups. Since thread relationships
+		 * are already restore now, t->signal must match.
+		 */
+		if (signal != current->signal)
+			ret = -EINVAL;
+	} else if (PTR_ERR(signal) == -EINVAL) {
+		/* first timer: add to hash and restore our t->signal */
+		ret = ckpt_obj_insert(ctx, current->signal,
+				      signal_objref, CKPT_OBJ_SIGNAL);
+		if (ret >= 0)
+			ret = restore_signal(ctx);
+	} else {
+		ret = PTR_ERR(signal);
+	}
+
+	return ret;
+}
+
+int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	fill_sigset(&h->blocked, &t->blocked);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_task_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal_task *h;
+	sigset_t blocked;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	load_sigset(&blocked, &h->blocked);
+	/* silently remove SIGKILL, SIGSTOP */
+	sigdelset(&blocked, SIGKILL);
+	sigdelset(&blocked, SIGSTOP);
+
+	sigprocmask(SIG_SETMASK, &blocked, NULL);
+	recalc_sigpending();
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 60d1116..d977d68 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -230,6 +230,12 @@ extern int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_sighand(struct ckpt_ctx *ctx);
 
+extern int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
+
+extern int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_task_signal(struct ckpt_ctx *ctx);
+
 /* useful macros to copy fields and buffers to/from ckpt_hdr_xxx structures */
 #define CKPT_CPT 1
 #define CKPT_RST 2
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4b85956..63afdc7 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -87,6 +87,8 @@ enum {
 	CKPT_HDR_IPC_SEM,
 
 	CKPT_HDR_SIGHAND = 601,
+	CKPT_HDR_SIGNAL,
+	CKPT_HDR_SIGNAL_TASK,
 
 	CKPT_HDR_TAIL = 9001,
 
@@ -115,6 +117,7 @@ enum obj_type {
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
 	CKPT_OBJ_SIGHAND,
+	CKPT_OBJ_SIGNAL,
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
@@ -209,7 +212,6 @@ struct ckpt_hdr_task {
 	__u32 compat_robust_futex_list; /* a compat __user ptr */
 	__u32 robust_futex_head_len;
 	__u64 robust_futex_list; /* a __user ptr */
-
 } __attribute__((aligned(8)));
 
 /* Posix capabilities */
@@ -285,6 +287,7 @@ struct ckpt_hdr_task_objs {
 	__s32 files_objref;
 	__s32 mm_objref;
 	__s32 sighand_objref;
+	__s32 signal_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -427,6 +430,15 @@ struct ckpt_hdr_sighand {
 	struct ckpt_hdr_sigaction action[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_signal {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_signal_task {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_sigset blocked;
+} __attribute__((aligned(8)));
+
 /* ipc commons */
 struct ckpt_hdr_ipcns {
 	struct ckpt_hdr h;
-- 
1.6.0.4
