From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 03/17] ckpt_write_err update checkpoint/checkpoint.c
Date: Thu, 29 Oct 2009 15:54:28 -0500
Message-ID: <1256849682-858-4-git-send-email-serue@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 checkpoint/checkpoint.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index c6be4f9..35fce15 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -319,12 +319,12 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
 	if (t->exit_state == EXIT_DEAD) {
-		__ckpt_write_err(ctx, "TE", "task state EXIT_DEAD\n", -EBUSY);
+		__ckpt_write_err(ctx, "%(T)%(E)task state EXIT_DEAD\n", -EBUSY);
 		return -EBUSY;
 	}
 
 	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
-		__ckpt_write_err(ctx, "TE", "ptrace attach denied", -EPERM);
+		__ckpt_write_err(ctx, "%(T)%(E)ptrace attach denied", -EPERM);
 		return -EPERM;
 	}
 
@@ -334,13 +334,13 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	/* verify that all tasks belongs to same freezer cgroup */
 	if (t != current && !in_same_cgroup_freezer(t, ctx->root_freezer)) {
-		__ckpt_write_err(ctx, "TE", "unfrozen or wrong cgroup", -EBUSY);
+		__ckpt_write_err(ctx, "%(T)%(E)unfrozen or wrong cgroup", -EBUSY);
 		return -EBUSY;
 	}
 
 	/* FIX: add support for ptraced tasks */
 	if (task_ptrace(t)) {
-		__ckpt_write_err(ctx, "TE", "task is ptraced", -EBUSY);
+		__ckpt_write_err(ctx, "%(T)%(E)task is ptraced", -EBUSY);
 		return -EBUSY;
 	}
 
@@ -350,22 +350,22 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	 */
 	if (ctx->root_init && t != root &&
 	    t->real_parent == root->real_parent && t->tgid != root->tgid) {
-		__ckpt_write_err(ctx, "TE", "task is sibling of root", -EINVAL);
+		__ckpt_write_err(ctx, "%(T)%(E)task is sibling of root", -EINVAL);
 		return -EINVAL;
 	}
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
 	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
-		__ckpt_write_err(ctx, "TE", "bad mnt_ns", -EPERM);
+		__ckpt_write_err(ctx, "%(T)%(E)bad mnt_ns", -EPERM);
 		ret = -EPERM;
 	}
 	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
-		__ckpt_write_err(ctx, "TE", "bad pid_ns", -EPERM);
+		__ckpt_write_err(ctx, "%(T)%(E)bad pid_ns", -EPERM);
 		ret = -EPERM;
 	}
 	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
-		__ckpt_write_err(ctx, "TE", "bad net_ns", -EPERM);
+		__ckpt_write_err(ctx, "%(T)%(E)bad net_ns", -EPERM);
 		ret = -EPERM;
 	}
 	rcu_read_unlock();
@@ -435,7 +435,7 @@ static int collect_objects(struct ckpt_ctx *ctx)
 		ret = ckpt_collect_task(ctx, ctx->tasks_arr[n]);
 		if (ret < 0) {
 			ctx->tsk = ctx->tasks_arr[n];
-			ckpt_write_err(ctx, "TE", "collect failed", ret);
+			ckpt_write_err(ctx, "%(T)%(E)collect failed", ret);
 			ctx->tsk = NULL;
 			break;
 		}
@@ -465,7 +465,7 @@ static int __tree_count_tasks(struct task_struct *task, void *data)
 
 	if (ctx->tasks_arr) {
 		if (d->nr == ctx->nr_tasks) {  /* unlikely... try again later */
-			__ckpt_write_err(ctx, "TE", "bad task count\n", -EBUSY);
+			__ckpt_write_err(ctx, "%(T)%(E)bad task count\n", -EBUSY);
 			ret = -EBUSY;
 			goto out;
 		}
@@ -476,7 +476,7 @@ static int __tree_count_tasks(struct task_struct *task, void *data)
 	ret = 1;
  out:
 	if (ret < 0)
-		ckpt_write_err(ctx, "", NULL);
+		ckpt_write_err(ctx, NULL);
 	ctx->tsk = NULL;
 	return ret;
 }
@@ -635,7 +635,7 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
 	ctx->root_init = is_container_init(task);
 
 	if (!(ctx->uflags & CHECKPOINT_SUBTREE) && !ctx->root_init) {
-		ckpt_write_err(ctx, "E", "not container init", -EINVAL);
+		ckpt_write_err(ctx, "%(E)not container init", -EINVAL);
 		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
 	}
 
@@ -662,7 +662,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	if (ctx->root_freezer) {
 		ret = cgroup_freezer_begin_checkpoint(ctx->root_freezer);
 		if (ret < 0) {
-			ckpt_write_err(ctx, "E", "freezer cgroup failed", ret);
+			ckpt_write_err(ctx, "%(E)freezer cgroup failed", ret);
 			return ret;
 		}
 	}
@@ -705,7 +705,7 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 
 	/* verify that all objects were indeed visited */
 	if (!ckpt_obj_visited(ctx)) {
-		ckpt_write_err(ctx, "E", "leak: unvisited", -EBUSY);
+		ckpt_write_err(ctx, "%(E)leak: unvisited", -EBUSY);
 		ret = -EBUSY;
 		goto out;
 	}
-- 
1.6.1
