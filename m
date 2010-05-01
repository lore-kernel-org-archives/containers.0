From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 025/100] c/r: external checkpoint of a task other than
	ourself
Date: Sat,  1 May 2010 10:15:07 -0400
Message-ID: <1272723382-19470-26-git-send-email-orenl__34946.3491621011$1272726296$gmane$org@cs.columbia.edu>
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

Now we can do "external" checkpoint, i.e. act on another task.

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container, unless CHECKPOINT_SUBTREE flag is given.

Set state of freezer cgroup of checkpointed task hierarchy to
"CHECKPOINTING" during a checkpoint, to ensure that task(s) cannot be
thawed while at it.

Ensure that all tasks belong to root task's freezer cgroup (the root
task is also tested, to detect it if changes its freezer cgroups
before it moves to "CHECKPOINTING").

sys_restart() remains nearly the same, as the restart is always done
in the context of the restarting task. However, the original task may
have been frozen from user space, or interrupted from a syscall for
the checkpoint. This is accounted for by restoring a suitable retval
for the restarting task, according to how it was checkpointed.

Changelog[v20]:
  - [Nathan Lynch] Use syscall_get_error
Changelog[v19-rc1]:
  - [Serge Hallyn] Add global section container to image format
Changelog[v17]:
  - Move restore_retval() to this patch
  - Tighten ptrace ceckpoint for checkpoint to PTRACE_MODE_ATTACH
  - Use CHECKPOINTING state for hierarchy's freezer for checkpoint
Changelog[v16]:
  - Use CHECKPOINT_SUBTREE to allow subtree (partial container)
Changelog[v14]:
  - Refuse non-self checkpoint if target task isn't frozen
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()
Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them
Changelog[v10]:
  - Grab vfs root of container init, rather than current process

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_types.h |    7 ++-
 kernel/checkpoint/Kconfig        |    1 +
 kernel/checkpoint/checkpoint.c   |   98 +++++++++++++++++++++++++++++++++++++-
 kernel/checkpoint/restart.c      |   66 +++++++++++++++++++++++++-
 kernel/checkpoint/sys.c          |   10 ++++
 5 files changed, 179 insertions(+), 3 deletions(-)

diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 13d6dd5..ff35b97 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -12,12 +12,17 @@
 
 #ifdef __KERNEL__
 
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/fs.h>
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
-	pid_t root_pid;		/* container identifier */
+	pid_t root_pid;				/* [container] root pid */
+	struct task_struct *root_task;		/* [container] root task */
+	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
+	struct task_struct *root_freezer;	/* [container] root task */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
diff --git a/kernel/checkpoint/Kconfig b/kernel/checkpoint/Kconfig
index ef7d406..21fc86b 100644
--- a/kernel/checkpoint/Kconfig
+++ b/kernel/checkpoint/Kconfig
@@ -5,6 +5,7 @@
 config CHECKPOINT
 	bool "Checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	depends on CGROUP_FREEZER
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 0f55d37..e45653b 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -13,6 +13,9 @@
 
 #include <linux/version.h>
 #include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/freezer.h>
+#include <linux/ptrace.h>
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -193,17 +196,108 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	if (t->state == TASK_DEAD) {
+		_ckpt_err(ctx, -EBUSY, "%(T)Task state EXIT_DEAD\n");
+		return -EBUSY;
+	}
+
+	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
+		_ckpt_err(ctx, -EPERM, "%(T)Ptrace attach denied\n");
+		return -EPERM;
+	}
+
+	/* verify that all tasks belongs to same freezer cgroup */
+	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
+		_ckpt_err(ctx, -EBUSY, "%(T)Not frozen or wrong cgroup\n");
+		return -EBUSY;
+	}
+
+	/* FIX: add support for ptraced tasks */
+	if (task_ptrace(t)) {
+		_ckpt_err(ctx, -EBUSY, "%(T)Task is ptraced\n");
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+/* setup checkpoint-specific parts of ctx */
+static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task;
+	struct nsproxy *nsproxy;
+	int ret;
+
+	/*
+	 * No need for explicit cleanup here, because if an error
+	 * occurs then ckpt_ctx_free() is eventually called.
+	 */
+
+	ctx->root_pid = pid;
+
+	/* root task */
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+	if (!task)
+		return -ESRCH;
+	else
+		ctx->root_task = task;
+
+	/* root nsproxy */
+	rcu_read_lock();
+	nsproxy = task_nsproxy(task);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
+	rcu_read_unlock();
+	if (!nsproxy)
+		return -ESRCH;
+	else
+		ctx->root_nsproxy = nsproxy;
+
+	/* root freezer */
+	ctx->root_freezer = task;
+	get_task_struct(task);
+
+	ret = may_checkpoint_task(ctx, task);
+	if (ret) {
+		_ckpt_msg_complete(ctx);
+		put_task_struct(task);
+		put_task_struct(task);
+		put_nsproxy(nsproxy);
+		ctx->root_nsproxy = NULL;
+		ctx->root_task = NULL;
+		return ret;
+	}
+
+	return 0;
+}
+
 long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
 	long ret;
 
+	ret = init_checkpoint_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
+
+	if (ctx->root_freezer) {
+		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
+		if (ret < 0)
+			return ret;
+	}
+
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_container(ctx);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_task(ctx, current);
+	ret = checkpoint_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
@@ -214,5 +308,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->crid = atomic_inc_return(&ctx_count);
 	ret = ctx->crid;
  out:
+	if (ctx->root_freezer)
+		cgroup_freezer_end_checkpoint(ctx->root_freezer);
 	return ret;
 }
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index f2b8575..7b6caf9 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -18,8 +18,11 @@
 #include <linux/file.h>
 #include <linux/magic.h>
 #include <linux/utsname.h>
+#include <linux/elf.h>
 #include <linux/checkpoint.h>
 
+#include <asm/syscall.h>
+
 static int _ckpt_read_err(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 {
 	char *ptr;
@@ -448,10 +451,69 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static long restore_retval(void)
+{
+	struct pt_regs *regs = task_pt_regs(current);
+	long syscall_err;
+	long syscall_nr;
+
+	/*
+	 * For the restart, we entered the kernel via sys_restart(),
+	 * so our return path is via the syscall exit. In particular,
+	 * the code in entry.S will put the value that we will return
+	 * into a register (e.g. regs->eax in x86), thus passing it to
+	 * the caller task.
+	 *
+	 * What we do now depends on what happened to the checkpointed
+	 * task right before the checkpoint - there are three cases:
+	 *
+	 * 1) It was carrying out a syscall when became frozen, or
+	 * 2) It was running in userspace, or
+	 * 3) It was doing a self-checkpoint
+	 *
+	 * In case #1, if the syscall succeeded, perhaps partially,
+	 * then the retval is non-negative. If it failed, the error
+	 * may be one of -ERESTART..., which is interpreted in the
+	 * signal handling code. If that is the case, we force the
+	 * signal handler to kick in by faking a signal to ourselves
+	 * (a la freeze/thaw) when ret < 0.
+	 *
+	 * In case #2, our return value will overwrite the original
+	 * value in the affected register. Workaround by simply using
+	 * that saved value of that register as our retval.
+	 *
+	 * In case #3, then the state was recorded while the task was
+	 * in checkpoint(2) syscall. The syscall is execpted to return
+	 * 0 when returning from a restart. Fortunately, this already
+	 * has been arranged for at checkpoint time (the register that
+	 * holds the retval, e.g. regs->eax in x86, was set to
+	 * zero).
+	 */
+
+	/* needed for all 3 cases: get old value/error/retval */
+	syscall_nr = syscall_get_nr(current, regs);
+	syscall_err = syscall_get_error(current, regs);
+
+	/* if from a syscall and returning error, kick in signal handling */
+	if (syscall_nr >= 0 && syscall_err != 0)
+		set_tsk_thread_flag(current, TIF_SIGPENDING);
+
+	return syscall_get_return_value(current, regs);
+}
+
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx, pid_t pid)
+{
+	return 0;
+}
+
 long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	long ret;
 
+	ret = init_restart_ctx(ctx, pid);
+	if (ret < 0)
+		return ret;
 	ret = restore_read_header(ctx);
 	if (ret < 0)
 		return ret;
@@ -462,7 +524,9 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 	ret = restore_read_tail(ctx);
+	if (ret < 0)
+		return ret;
 
 	/* on success, adjust the return value if needed [TODO] */
-	return ret;
+	return restore_retval();
 }
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index af8c1bf..28a1b27 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -13,7 +13,9 @@
 
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/nsproxy.h>
 #include <linux/kernel.h>
+#include <linux/cgroup.h>
 #include <linux/syscalls.h>
 #include <linux/slab.h>
 #include <linux/fs.h>
@@ -163,6 +165,14 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 		fput(ctx->file);
 	if (ctx->logfile)
 		fput(ctx->logfile);
+
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+	if (ctx->root_freezer)
+		put_task_struct(ctx->root_freezer);
+
 	kfree(ctx);
 }
 
-- 
1.6.3.3
