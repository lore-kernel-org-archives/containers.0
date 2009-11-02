From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 02/12] switch ckpt_write_err callers to ckpt_err
Date: Mon,  2 Nov 2009 16:23:30 -0600
Message-ID: <1257200620-15499-3-git-send-email-serue@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/mm/checkpoint.c |    4 ++--
 checkpoint/checkpoint.c  |   39 ++++++++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 32d9dca..df5bf4b 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -154,11 +154,11 @@ static unsigned short decode_segment(__u16 seg)
 static int may_checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	if (t->thread.vm86_info) {
-		ckpt_write_err(ctx, "TE", "task in VM86 mode", -EBUSY);
+		ckpt_err(ctx, "%(T)%(E)Task in VM86 mode\n", -EBUSY);
 		return -EBUSY;
 	}
 	if (task_thread_info(t)->flags & CKPT_X86_TIF_UNSUPPORTED) {
-		ckpt_write_err(ctx, "TE", "bad thread info flags %#lx", -EBUSY);
+		ckpt_err(ctx, "%(T)%(E)Bad thread info flags %#lx\n", -EBUSY);
 		return -EBUSY;
 	}
 	return 0;
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6eb8f3b..30c6637 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -410,12 +410,12 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
 	if (t->exit_state == EXIT_DEAD) {
-		__ckpt_write_err(ctx, "TE", "task state EXIT_DEAD\n", -EBUSY);
+		_ckpt_err(ctx, "%(T)%(E)Task state EXIT_DEAD\n", -EBUSY);
 		return -EBUSY;
 	}
 
 	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
-		__ckpt_write_err(ctx, "TE", "ptrace attach denied", -EPERM);
+		_ckpt_err(ctx, "%(T)%(E)Ptrace attach denied\n", -EPERM);
 		return -EPERM;
 	}
 
@@ -425,13 +425,13 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	/* verify that all tasks belongs to same freezer cgroup */
 	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
-		__ckpt_write_err(ctx, "TE", "unfrozen or wrong cgroup", -EBUSY);
+		_ckpt_err(ctx, "%(T)%(E)Unfrozen or wrong cgroup\n", -EBUSY);
 		return -EBUSY;
 	}
 
 	/* FIX: add support for ptraced tasks */
 	if (task_ptrace(t)) {
-		__ckpt_write_err(ctx, "TE", "task is ptraced", -EBUSY);
+		_ckpt_err(ctx, "%(T)%(E)Task is ptraced\n", -EBUSY);
 		return -EBUSY;
 	}
 
@@ -441,22 +441,22 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	 */
 	if (ctx->root_init && t != root &&
 	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
-		__ckpt_write_err(ctx, "TE", "task is sibling of root", -EINVAL);
+		_ckpt_err(ctx, "%(T)%(E)Task is sibling of root\n", -EINVAL);
 		return -EINVAL;
 	}
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
 	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
-		__ckpt_write_err(ctx, "TE", "bad mnt_ns", -EPERM);
+		_ckpt_err(ctx, "%(T)%(E)Bad mnt_ns\n", -EPERM);
 		ret = -EPERM;
 	}
 	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
-		__ckpt_write_err(ctx, "TE", "bad pid_ns", -EPERM);
+		_ckpt_err(ctx, "%(T)%(E)Bad pid_ns\n", -EPERM);
 		ret = -EPERM;
 	}
 	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
-		__ckpt_write_err(ctx, "TE", "bad net_ns", -EPERM);
+		_ckpt_err(ctx, "%(T)%(E)Bad net_ns\n", -EPERM);
 		ret = -EPERM;
 	}
 	rcu_read_unlock();
@@ -526,7 +526,7 @@ static int collect_objects(struct ckpt_ctx *ctx)
 		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
 		if (ret < 0) {
 			ctx->tsk = ctx->tasks_arr[n];
-			ckpt_write_err(ctx, "TE", "collect failed", ret);
+			ckpt_err(ctx, "%(T)%(E)Collect failed\n", ret);
 			ctx->tsk = NULL;
 			break;
 		}
@@ -547,7 +547,7 @@ static int __tree_count_tasks(struct task_struct *task, void *data)
 	struct ckpt_ctx *ctx = d->ctx;
 	int ret;
 
-	ctx->tsk = task;  /* (for ckpt_write_err) */
+	ctx->tsk = task;  /* (for _ckpt_err()) */
 
 	/* is this task cool ? */
 	ret = may_checkpoint_task(ctx, task);
@@ -556,7 +556,8 @@ static int __tree_count_tasks(struct task_struct *task, void *data)
 
 	if (ctx->tasks_arr) {
 		if (d->nr == ctx->nr_tasks) {  /* unlikely... try again later */
-			__ckpt_write_err(ctx, "TE", "bad task count\n", -EBUSY);
+			_ckpt_err(ctx, "%(T)%(E)Bad task count (d->nr = %d)\n",
+				-EBUSY, d->nr);
 			ret = -EBUSY;
 			goto out;
 		}
@@ -566,8 +567,6 @@ static int __tree_count_tasks(struct task_struct *task, void *data)
 
 	ret = 1;
  out:
-	if (ret < 0)
-		ckpt_write_err(ctx, "", NULL);
 	ctx->tsk = NULL;
 	return ret;
 }
@@ -575,11 +574,17 @@ static int __tree_count_tasks(struct task_struct *task, void *data)
 static int tree_count_tasks(struct ckpt_ctx *ctx)
 {
 	struct ckpt_cnt_tasks data;
+	int ret;
 
 	data.ctx = ctx;
 	data.nr = 0;
 
-	return walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
+	ckpt_msg_lock(ctx);
+	ret = walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
+	ckpt_msg_unlock(ctx);
+	if (ret < 0)
+		_ckpt_msg_complete(ctx);
+	return ret;
 }
 
 /*
@@ -726,7 +731,7 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->root_init = is_container_init(task);
 
 	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
-		ckpt_write_err(ctx, "E", "not container init", -EINVAL);
+		ckpt_err(ctx, "%(E)Not container init\n", -EINVAL);
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 	}
 
@@ -753,7 +758,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	if (ctx->root_freezer) {
 		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
 		if (ret < 0) {
-			ckpt_write_err(ctx, "E", "freezer cgroup failed", ret);
+			ckpt_err(ctx, "%(E)Freezer cgroup failed\n", ret);
 			return ret;
 		}
 	}
@@ -796,7 +801,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	/* verify that all objects were indeed visited */
 	if (!ckpt_obj_visited(ctx)) {
-		ckpt_write_err(ctx, "E", "leak: unvisited", -EBUSY);
+		ckpt_err(ctx, "%(E)Leak: unvisited\n", -EBUSY);
 		ret = -EBUSY;
 		goto out;
 	}
-- 
1.6.1
