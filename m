From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 16/54] External checkpoint of a task other than
	ourself
Date: Tue, 28 Apr 2009 19:23:46 -0400
Message-ID: <1240961064-13991-17-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Now we can do "external" checkpoint, i.e. act on another task.

sys_checkpoint() now looks up the target pid (in our namespace) and
checkpoints that corresponding task. That task should be the root of
a container.

sys_restart() remains the same, as the restart is always done in the
context of the restarting task.

Changelog[v14]:
  - Refuse non-self checkpoint if target task isn't frozen

Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them

Changelog[v10]:
  - Grab vfs root of container init, rather than current process

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c          |   77 ++++++++++++++++++++++++++++++++++++--
 checkpoint/restart.c             |    4 +-
 checkpoint/sys.c                 |    6 +++
 include/linux/checkpoint_types.h |    2 +
 4 files changed, 83 insertions(+), 6 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 9abdf73..b741557 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -12,7 +12,11 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/version.h>
+#include <linux/sched.h>
+#include <linux/freezer.h>
+#include <linux/ptrace.h>
 #include <linux/time.h>
+#include <linux/fs_struct.h>
 #include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
@@ -161,22 +165,87 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
-static int ckpt_ctx_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
+static int get_container(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct task_struct *task = NULL;
+	struct nsproxy *nsproxy = NULL;
+	int err = -ESRCH;
+
+	ctx->root_pid = pid;
+
+	read_lock(&tasklist_lock);
+	task = find_task_by_vpid(pid);
+	if (task)
+		get_task_struct(task);
+	read_unlock(&tasklist_lock);
+
+	if (!task)
+		goto out;
+
+#if 0	/* enable to use containers */
+	if (!is_container_init(task)) {
+		err = -EINVAL;
+		goto out;
+	}
+#endif
+
+	if (!ptrace_may_access(task, PTRACE_MODE_READ)) {
+		err = -EPERM;
+		goto out;
+	}
+
+	/* verify that the task is frozen (unless self) */
+	if (task != current && !frozen(task))
+		return -EBUSY;
+
+	/* FIX: add support for ptraced tasks */
+	if (task_ptrace(task))
+		return -EBUSY;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(task);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	if (!nsproxy)
+		goto out;
+
+	ctx->root_task = task;
+	ctx->root_nsproxy = nsproxy;
+
+	return 0;
+
+ out:
+	if (task)
+		put_task_struct(task);
+	return err;
+}
+
+/* setup checkpoint-specific parts of ctx */
+static int ctx_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct fs_struct *fs;
+	int ret;
 
 	ctx->root_pid = pid;
 
+	ret = get_container(ctx, pid);
+	if (ret < 0)
+		return ret;
+
 	/*
 	 * assume checkpointer is in container's root vfs
 	 * FIXME: this works for now, but will change with real containers
 	 */
 
-	fs = current->fs;
+	task_lock(ctx->root_task);
+	fs = ctx->root_task->fs;
 	read_lock(&fs->lock);
 	ctx->fs_mnt = fs->root;
 	path_get(&ctx->fs_mnt);
 	read_unlock(&fs->lock);
+	task_unlock(ctx->root_task);
 
 	return 0;
 }
@@ -185,13 +254,13 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
-	ret = ckpt_ctx_checkpoint(ctx, pid);
+	ret = ctx_checkpoint(ctx, pid);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_task(ctx, current);
+	ret = checkpoint_task(ctx, ctx->root_task);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index ecf2cf0..637de90 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -334,7 +334,7 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 }
 
 /* setup restart-specific parts of ctx */
-static int ckpt_ctx_restart(struct ckpt_ctx *ctx)
+static int ctx_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	return 0;
 }
@@ -343,7 +343,7 @@ int do_restart(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
-	ret = ckpt_ctx_restart(ctx);
+	ret = ctx_restart(ctx, pid);
 	if (ret < 0)
 		return ret;
 	ret = restore_read_header(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 76d5d66..0b7245a 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -12,6 +12,7 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/file.h>
@@ -205,6 +206,11 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	ckpt_pgarr_free(ctx);
 	ckpt_obj_hash_free(ctx);
 
+	if (ctx->root_nsproxy)
+		put_nsproxy(ctx->root_nsproxy);
+	if (ctx->root_task)
+		put_task_struct(ctx->root_task);
+
 	kfree(ctx);
 }
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 12f0ec5..d98ba71 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -22,6 +22,8 @@ struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
 	pid_t root_pid;		/* container identifier */
+	struct task_struct *root_task;	/* container root task */
+	struct nsproxy *root_nsproxy;	/* container root nsproxy */
 
 	unsigned long flags;
 	unsigned long oflags;	/* restart: old flags */
-- 
1.5.4.3
