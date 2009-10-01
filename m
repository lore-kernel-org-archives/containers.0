From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/5] c/r: introduce walk_task_subtree() to iterate through
	descendants
Date: Wed, 30 Sep 2009 21:47:12 -0400
Message-ID: <1254361634-30076-4-git-send-email-orenl@librato.com>
References: <1254361634-30076-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254361634-30076-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

Introduce a helper to iterate over the descendants of a given
task. The prototype is:

int walk_task_subtree(struct task_struct *root,
		      int (*func)(struct task_struct *, void *),
      		      void *data)

The function will start with @root, and iterate through all the
descendants, including threads, in a DFS manner. Children of a task
are traversed before proceeding to the next thread of that task.

For each task, the callback @func will be called providing the task
pointer and the @data. The callback is invoked while holding the
tasklist_lock for reading. If the callback fails it should return a
negative error, and the traversal ends. If the callback succeeds, it
returns a non-negative number, and these values are summed.

On success, walk_task_subtree() returns the total summed. On failure,
it returns a negative value.

The code in checkpoint/checkpoint.c and checkpoint/restart.c has
been converted to use this helper.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c    |   97 ++++++++++++++--------------------------
 checkpoint/restart.c       |  105 +++++++++++++++++++-------------------------
 checkpoint/sys.c           |   55 +++++++++++++++++++++++
 include/linux/checkpoint.h |    3 +
 4 files changed, 137 insertions(+), 123 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index dbe9e10..1eeb557 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -520,80 +520,51 @@ static int collect_objects(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+struct ckpt_cnt_tasks {
+	struct ckpt_ctx *ctx;
+	int nr;
+};
+
 /* count number of tasks in tree (and optionally fill pid's in array) */
-static int tree_count_tasks(struct ckpt_ctx *ctx)
+static int __tree_count_tasks(struct task_struct *task, void *data)
 {
-	struct task_struct *root;
-	struct task_struct *task;
-	struct task_struct *parent;
-	struct task_struct **tasks_arr = ctx->tasks_arr;
-	int nr_tasks = ctx->nr_tasks;
-	int nr = 0;
+	struct ckpt_cnt_tasks *d = (struct ckpt_cnt_tasks *) data;
+	struct ckpt_ctx *ctx = d->ctx;
 	int ret;
 
-	read_lock(&tasklist_lock);
-
-	/* we hold the lock, so root_task->real_parent can't change */
-	task = ctx->root_task;
-	if (ctx->root_init) {
-		/* container-init: start from container parent */
-		parent = task->real_parent;
-		root = parent;
-	} else {
-		/* non-container-init: start from root task and down */
-		parent = NULL;
-		root = task;
-	}
-
-	/* count tasks via DFS scan of the tree */
-	while (1) {
-		ctx->tsk = task;  /* (for ckpt_write_err) */
+	ctx->tsk = task;  /* (for ckpt_write_err) */
 
-		/* is this task cool ? */
-		ret = may_checkpoint_task(ctx, task);
-		if (ret < 0) {
-			nr = ret;
-			break;
-		}
-		if (tasks_arr) {
-			/* unlikely... but if so then try again later */
-			if (nr == nr_tasks) {
-				nr = -EBUSY; /* cleanup in ckpt_ctx_free() */
-				break;
-			}
-			tasks_arr[nr] = task;
-			get_task_struct(task);
-		}
-		nr++;
-		/* if has children - proceed with child */
-		if (!list_empty(&task->children)) {
-			parent = task;
-			task = list_entry(task->children.next,
-					  struct task_struct, sibling);
-			continue;
-		}
-		while (task != root) {
-			/* if has sibling - proceed with sibling */
-			if (!list_is_last(&task->sibling, &parent->children)) {
-				task = list_entry(task->sibling.next,
-						  struct task_struct, sibling);
-				break;
-			}
+	/* is this task cool ? */
+	ret = may_checkpoint_task(ctx, task);
+	if (ret < 0)
+		goto out;
 
-			/* else, trace back to parent and proceed */
-			task = parent;
-			parent = parent->real_parent;
+	if (ctx->tasks_arr) {
+		if (d->nr == ctx->nr_tasks) {  /* unlikely... try again later */
+			__ckpt_write_err(ctx, "TE", "bad task count\n", -EBUSY);
+			ret = -EBUSY;
+			goto out;
 		}
-		if (task == root)
-			break;
+		ctx->tasks_arr[d->nr++] = task;
+		get_task_struct(task);
 	}
+
+	ret = 1;
+ out:
+	if (ret < 0)
+		ckpt_write_err(ctx, "", NULL);
 	ctx->tsk = NULL;
+	return ret;
+}
 
-	read_unlock(&tasklist_lock);
+static int tree_count_tasks(struct ckpt_ctx *ctx)
+{
+	struct ckpt_cnt_tasks data;
 
-	if (nr < 0)
-		ckpt_write_err(ctx, "", NULL);
-	return nr;
+	data.ctx = ctx;
+	data.nr = 0;
+
+	return walk_task_subtree(ctx->root_task, __tree_count_tasks, &data);
 }
 
 /*
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 37454c5..c021eaf 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -804,77 +804,56 @@ static int do_restore_task(void)
  * Called by the coodinator to set the ->checkpoint_ctx pointer of the
  * root task and all its descendants.
  */
-static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
+static int __prepare_descendants(struct task_struct *task, void *data)
 {
-	struct task_struct *leader = root;
-	struct task_struct *parent = NULL;
-	struct task_struct *task = root;
-	int nr_pids = 0;
-	int ret = -EBUSY;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
 
-	read_lock(&tasklist_lock);
-	while (1) {
-		ckpt_debug("consider task %d\n", task_pid_vnr(task));
-		if (task_ptrace(task) & PT_PTRACED)
-			break;
-		/*
-		 * Set task->checkpoint_ctx of all non-zombie descendants.
-		 * If a descendant already has a ->checkpoint_ctx, it
-		 * must be a coordinator (for a different restart ?) so
-		 * we fail.
-		 *
-		 * Note that own ancestors cannot interfere since they
-		 * won't descend past us, as own ->checkpoint_ctx must
-		 * already be set.
-		 */
-		if (!task->exit_state) {
-			if (!set_task_ctx(task, ctx))
-				break;
-			ckpt_debug("prepare task %d\n", task_pid_vnr(task));
-			wake_up_process(task);
-			nr_pids++;
-		}
+	ckpt_debug("consider task %d\n", task_pid_vnr(task));
 
-		/* if has children - proceed with child */
-		if (!list_empty(&task->children)) {
-			parent = task;
-			task = list_entry(task->children.next,
-					  struct task_struct, sibling);
-			continue;
-		}
-		while (task != root) {
-			/* if has sibling - proceed with sibling */
-			if (!list_is_last(&task->sibling, &parent->children)) {
-				task = list_entry(task->sibling.next,
-						  struct task_struct, sibling);
-				break;
-			}
-
-			/* else, trace back to parent and proceed */
-			task = parent;
-			parent = parent->real_parent;
-		}
-		if (task == root) {
-			/* in case root task is multi-threaded */
-			root = task = next_thread(task);
-			if (root == leader) {
-				ret = 0;
-				break;
-			}
-		}
+	if (task_ptrace(task) & PT_PTRACED) {
+		ckpt_debug("ptraced task %d\n", task_pid_vnr(task));
+		return -EBUSY;
 	}
-	read_unlock(&tasklist_lock);
-	ckpt_debug("nr %d/%d  ret %d\n", ctx->nr_pids, nr_pids, ret);
+
+	/*
+	 * Set task->checkpoint_ctx of all non-zombie descendants.
+	 * If a descendant already has a ->checkpoint_ctx, it
+	 * must be a coordinator (for a different restart ?) so
+	 * we fail.
+	 *
+	 * Note that own ancestors cannot interfere since they
+	 * won't descend past us, as own ->checkpoint_ctx must
+	 * already be set.
+	 */
+	if (!task->exit_state) {
+		if (!set_task_ctx(task, ctx))
+			return -EBUSY;
+		ckpt_debug("prepare task %d\n", task_pid_vnr(task));
+		wake_up_process(task);
+		return 1;
+	}
+
+	return 0;
+}
+
+static int prepare_descendants(struct ckpt_ctx *ctx, struct task_struct *root)
+{
+	int nr_pids;
+
+	nr_pids = walk_task_subtree(root, __prepare_descendants, ctx);
+	ckpt_debug("nr %d/%d\n", ctx->nr_pids, nr_pids);
+	if (nr_pids < 0)
+		return nr_pids;
 
 	/*
 	 * Actual tasks count may exceed ctx->nr_pids due of 'dead'
 	 * tasks used as place-holders for PGIDs, but not fall short.
 	 */
-	if (!ret && (nr_pids < ctx->nr_pids))
-		ret = -ESRCH;
+	if (nr_pids < ctx->nr_pids)
+		return -ESRCH;
 
 	atomic_set(&ctx->nr_total, nr_pids);
-	return ret;
+	return nr_pids;
 }
 
 static int wait_all_tasks_finish(struct ckpt_ctx *ctx)
@@ -991,6 +970,12 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 		return -EBUSY;
 	}
 
+	/*
+	 * From now on we are committed to the restart. If anything
+	 * fails, we'll wipe out the entire subtree below us, to
+	 * ensure proper cleanup.
+	 */
+
 	if (ctx->uflags & RESTART_TASKSELF) {
 		ret = restore_task(ctx);
 		ckpt_debug("restore task: %d\n", ret);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 77613d7..7604089 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -276,6 +276,61 @@ void ckpt_ctx_put(struct ckpt_ctx *ctx)
 		ckpt_ctx_free(ctx);
 }
 
+int walk_task_subtree(struct task_struct *root,
+		      int (*func)(struct task_struct *, void *),
+		      void *data)
+{
+
+	struct task_struct *leader = root;
+	struct task_struct *parent = NULL;
+	struct task_struct *task = root;
+	int total = 0;
+	int ret;
+
+	read_lock(&tasklist_lock);
+	while (1) {
+		/* invoke callback on this task */
+		ret = func(task, data);
+		if (ret < 0)
+			break;
+
+		total += ret;
+
+		/* if has children - proceed with child */
+		if (!list_empty(&task->children)) {
+			parent = task;
+			task = list_entry(task->children.next,
+					  struct task_struct, sibling);
+			continue;
+		}
+
+		while (task != root) {
+			/* if has sibling - proceed with sibling */
+			if (!list_is_last(&task->sibling, &parent->children)) {
+				task = list_entry(task->sibling.next,
+						  struct task_struct, sibling);
+				break;
+			}
+
+			/* else, trace back to parent and proceed */
+			task = parent;
+			parent = parent->real_parent;
+		}
+
+		if (task == root) {
+			/* in case root task is multi-threaded */
+			root = task = next_thread(task);
+			if (root == leader)
+				break;
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	ckpt_debug("total %d ret %d\n", total, ret);
+	return (ret < 0 ? ret : total);
+}
+
+
 /**
  * sys_checkpoint - checkpoint a container
  * @pid: pid of the container init(1) process
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index b7f1796..12210e4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -50,6 +50,9 @@
 	 RESTART_FROZEN | \
 	 RESTART_GHOST)
 
+extern int walk_task_subtree(struct task_struct *task,
+			     int (*func)(struct task_struct *, void *),
+			     void *data);
 extern void exit_checkpoint(struct task_struct *tsk);
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
-- 
1.6.0.4
