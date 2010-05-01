From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 031/100] c/r: support for zombie processes
Date: Sat,  1 May 2010 10:15:13 -0400
Message-ID: <1272723382-19470-32-git-send-email-orenl__40722.4609902643$1272725932$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

During checkpoint, a zombie processes need only save p->comm,
p->state, p->exit_state, and p->exit_code.

During restart, zombie processes are created like all other
processes. They validate the saved exit_code restore p->comm
and p->exit_code. Then they call do_exit() instead of waking
up the next task in line.

But before, they place the @ctx in p->checkpoint_ctx, so that
only at exit time they will wake up the next task in line,
and drop the reference to the @ctx.

This provides the guarantee that when the coordinator's wait
completes, all normal tasks completed their restart, and all
zombie tasks are already zombified (as opposed to perhap only
becoming a zombie).

Changelog[v19-rc1]:
  - Simplify logic of tracking restarting tasks
Changelog[v18]:
  - Fix leak of ckpt_ctx when restoring zombie tasks
  - Add a few more ckpt_write_err()s
Changelog[v17]:
  - Validate t->exit_signal for both threads and leader
  - Skip zombies in most of may_checkpoint_task()
  - Save/restore t->pdeath_signal
  - Validate ->exit_signal and ->pdeath_signal

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    1 +
 kernel/checkpoint/checkpoint.c |   10 ++++--
 kernel/checkpoint/process.c    |   69 +++++++++++++++++++++++++++++++++++-----
 kernel/checkpoint/restart.c    |   22 +++++++++++--
 5 files changed, 89 insertions(+), 14 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index f787a75..2d32c17 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -113,6 +113,7 @@ extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid);
 
 /* task */
+extern int ckpt_activate_next(struct ckpt_ctx *ctx);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4abae32..68ee0f3 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -165,6 +165,7 @@ struct ckpt_hdr_task {
 	__u32 exit_state;
 	__u32 exit_code;
 	__u32 exit_signal;
+	__u32 pdeath_signal;
 
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 14801f3..f451f8f 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -219,7 +219,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
-	if (t->state == TASK_DEAD) {
+	if (t->exit_state == EXIT_DEAD) {
 		_ckpt_err(ctx, -EBUSY, "%(T)Task state EXIT_DEAD\n");
 		return -EBUSY;
 	}
@@ -229,6 +229,10 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EPERM;
 	}
 
+	/* zombies are cool (and also don't have nsproxy, below...) */
+	if (t->exit_state)
+		return 0;
+
 	/* verify that all tasks belongs to same freezer cgroup */
 	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
 		_ckpt_err(ctx, -EBUSY, "%(T)Not frozen or wrong cgroup\n");
@@ -245,8 +249,8 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * FIX: for now, disallow siblings of container init created
 	 * via CLONE_PARENT (unclear if they will remain possible)
 	 */
-	if (ctx->root_init && t != root && t->tgid != root->tgid &&
-	    t->real_parent == root->real_parent) {
+	if (ctx->root_init && t != root &&
+	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
 		_ckpt_err(ctx, -EINVAL, "%(T)Task is sibling of root\n");
 		return -EINVAL;
 	}
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index b662e5d..ce009cb 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -34,12 +34,18 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->state = t->state;
 	h->exit_state = t->exit_state;
 	h->exit_code = t->exit_code;
-	h->exit_signal = t->exit_signal;
 
-	h->set_child_tid = (unsigned long) t->set_child_tid;
-	h->clear_child_tid = (unsigned long) t->clear_child_tid;
+	if (t->exit_state) {
+		/* zombie - skip remaining state */
+		BUG_ON(t->exit_state != EXIT_ZOMBIE);
+	} else {
+		/* FIXME: save remaining relevant task_struct fields */
+		h->exit_signal = t->exit_signal;
+		h->pdeath_signal = t->pdeath_signal;
 
-	/* FIXME: save remaining relevant task_struct fields */
+		h->set_child_tid = (unsigned long) t->set_child_tid;
+		h->clear_child_tid = (unsigned long) t->clear_child_tid;
+	}
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -170,6 +176,11 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
 		goto out;
+
+	/* zombie - we're done here */
+	if (t->exit_state)
+		return 0;
+
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
@@ -189,6 +200,19 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
  * Restart
  */
 
+static inline int valid_exit_code(int exit_code)
+{
+	if (exit_code >= 0x10000)
+		return 0;
+	if (exit_code & 0xff) {
+		if (exit_code & ~0xff)
+			return 0;
+		if (!valid_signal(exit_code & 0xff))
+			return 0;
+	}
+	return 1;
+}
+
 /* read the task_struct into the current task */
 static int restore_task_struct(struct ckpt_ctx *ctx)
 {
@@ -200,15 +224,39 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
+	ret = -EINVAL;
+	if (h->state == TASK_DEAD) {
+		if (h->exit_state != EXIT_ZOMBIE)
+			goto out;
+		if (!valid_exit_code(h->exit_code))
+			goto out;
+		t->exit_code = h->exit_code;
+	} else {
+		if (h->exit_code)
+			goto out;
+		if ((thread_group_leader(t) && !valid_signal(h->exit_signal)) ||
+		    (!thread_group_leader(t) && h->exit_signal != -1))
+			goto out;
+		if (!valid_signal(h->pdeath_signal))
+			goto out;
+
+		/* FIXME: restore remaining relevant task_struct fields */
+		t->exit_signal = h->exit_signal;
+		t->pdeath_signal = h->pdeath_signal;
+
+		t->set_child_tid =
+			(int __user *) (unsigned long) h->set_child_tid;
+		t->clear_child_tid =
+			(int __user *) (unsigned long) h->clear_child_tid;
+	}
+
 	memset(t->comm, 0, TASK_COMM_LEN);
 	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
 	if (ret < 0)
 		goto out;
 
-	t->set_child_tid = (int __user *) (unsigned long) h->set_child_tid;
-	t->clear_child_tid = (int __user *) (unsigned long) h->clear_child_tid;
-
-	/* FIXME: restore remaining relevant task_struct fields */
+	/* return 1 for zombie, 0 otherwise */
+	ret = (h->state == TASK_DEAD ? 1 : 0);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -328,6 +376,11 @@ int restore_task(struct ckpt_ctx *ctx)
 	ckpt_debug("task %d\n", ret);
 	if (ret < 0)
 		goto out;
+
+	/* zombie - we're done here */
+	if (ret)
+		goto out;
+
 	ret = restore_thread(ctx);
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index ddc71ee..18b3815 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -854,7 +854,7 @@ static int wait_sync_threads(void)
 static int do_restore_task(void)
 {
 	struct ckpt_ctx *ctx;
-	int ret;
+	int zombie, ret;
 
 	ctx = wait_checkpoint_ctx();
 	if (IS_ERR(ctx))
@@ -864,6 +864,8 @@ static int do_restore_task(void)
 	if (ret < 0)
 		goto out;
 
+	current->flags |= PF_RESTARTING;
+
 	ret = wait_sync_threads();
 	if (ret < 0)
 		goto out;
@@ -875,9 +877,22 @@ static int do_restore_task(void)
 
 	restore_debug_running(ctx);
 
-	ret = restore_task(ctx);
-	if (ret < 0)
+	zombie = restore_task(ctx);
+	if (zombie < 0) {
+		ret = zombie;
 		goto out;
+	}
+
+	/*
+	 * zombie: we're done here; do_exit() will notice the @ctx on
+	 * our current->checkpoint_ctx (and our PF_RESTARTING) - it
+	 * will call restore_activate_next() and release the @ctx.
+	 */
+	if (zombie) {
+		restore_debug_exit(ctx);
+		ckpt_ctx_put(ctx);
+		do_exit(current->exit_code);
+	}
 
 	restore_task_done(ctx);
 	ret = wait_task_sync(ctx);
@@ -886,6 +901,7 @@ static int do_restore_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "task restart failed\n");
 
+	current->flags &= ~PF_RESTARTING;
 	clear_task_ctx(current);
 	ckpt_ctx_put(ctx);
 	return ret;
-- 
1.6.3.3
