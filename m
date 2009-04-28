From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 19/54] Checkpoint multiple processes
Date: Tue, 28 Apr 2009 19:23:49 -0400
Message-ID: <1240961064-13991-20-git-send-email-orenl@cs.columbia.edu>
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

Checkpointing of multiple processes works by recording the tasks tree
structure below a given task (usually this task is the container init).

For a given task, do a DFS scan of the tasks tree and collect them
into an array (keeping a reference to each task). Using DFS simplifies
the recreation of tasks either in user space or kernel space. For each
task collected, test if it can be checkpointed, and save its pid, tgid,
and ppid.

The actual work is divided into two passes: a first scan counts the
tasks, then memory is allocated and a second scan fills the array.

The logic is suitable for creation of processes during restart either
in userspace or by the kernel.

Currently we ignore threads and zombies, as well as session ids.

Changelog[v14]:
  - Refuse non-self checkpoint if target task isn't frozen
  - Refuse checkpoint (for now) if task is ptraced
  - Revert change to pr_debug(), back to ckpt_debug()
  - Use only unsigned fields in checkpoint headers
  - Check retval of ckpt_tree_count_tasks() in ckpt_build_tree()
  - Discard 'h.parent' field
  - Check whether calls to ckpt_hbuf_get() fail
  - Disallow threads or siblings to container init

Changelog[v13]:
  - Release tasklist_lock in error path in ckpt_tree_count_tasks()
  - Use separate index for 'tasks_arr' and 'hh' in ckpt_write_pids()

Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c          |  256 ++++++++++++++++++++++++++++++++++---
 checkpoint/sys.c                 |   16 +++
 include/linux/checkpoint_hdr.h   |   16 +++-
 include/linux/checkpoint_types.h |   10 +-
 4 files changed, 273 insertions(+), 25 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 07901c1..0299046 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -166,6 +166,233 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* dump all tasks in ctx->tasks_arr[] */
+static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
+{
+	int n, ret = 0;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		ckpt_debug("dumping task #%d\n", n);
+		ret = checkpoint_task(ctx, ctx->tasks_arr[n]);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
+static int may_checkpoint_task(struct task_struct *t, struct ckpt_ctx *ctx)
+{
+	struct pid_namespace *ns = ctx->root_nsproxy->pid_ns;
+
+	ckpt_debug("check %d\n", task_pid_nr_ns(t, ns));
+
+	if (t->state == TASK_DEAD) {
+		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+		return -EAGAIN;
+	}
+
+	if (!ptrace_may_access(t, PTRACE_MODE_READ))
+		return -EPERM;
+
+	/* verify that the task is frozen (unless self) */
+	if (t != current && !frozen(t))
+		return -EBUSY;
+
+	/* FIX: add support for ptraced tasks */
+	if (task_ptrace(t))
+		return -EBUSY;
+
+	/*
+	 * FIX: for now, disallow siblings of container init created
+	 * via CLONE_PARENT (unclear if they will remain possible)
+	 */
+	if (ctx->root_init && t != ctx->root_task &&
+	    t->real_parent == ctx->root_task->real_parent)
+		return -EINVAL;
+
+	/* FIX: change this for nested containers */
+	if (task_nsproxy(t) != ctx->root_nsproxy)
+		return -EPERM;
+
+	return 0;
+}
+
+#define CKPT_HDR_PIDS_CHUNK	256
+
+static int checkpoint_pids(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_pids *h;
+	struct pid_namespace *ns;
+	struct task_struct *task;
+	struct task_struct **tasks_arr;
+	int nr_tasks, n, pos = 0, ret = 0;
+
+	ns = ctx->root_nsproxy->pid_ns;
+	tasks_arr = ctx->tasks_arr;
+	nr_tasks = ctx->nr_tasks;
+	BUG_ON(nr_tasks <= 0);
+
+	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	if (!h)
+		return -ENOMEM;
+
+	do {
+		rcu_read_lock();
+		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
+			task = tasks_arr[pos];
+
+			h[n].vpid = task_pid_nr_ns(task, ns);
+			h[n].vtgid = task_tgid_nr_ns(task, ns);
+			h[n].vpgid = task_pgrp_nr_ns(task, ns);
+			h[n].vsid = task_session_nr_ns(task, ns);
+			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
+			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
+				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
+			pos++;
+		}
+		rcu_read_unlock();
+
+		n = min(nr_tasks, CKPT_HDR_PIDS_CHUNK);
+		ret = ckpt_kwrite(ctx, h, n * sizeof(*h));
+		if (ret < 0)
+			break;
+
+		nr_tasks -= n;
+	} while (nr_tasks > 0);
+
+	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	return ret;
+}
+
+/* count number of tasks in tree (and optionally fill pid's in array) */
+static int tree_count_tasks(struct ckpt_ctx *ctx)
+{
+	struct task_struct *root;
+	struct task_struct *task;
+	struct task_struct *parent;
+	struct task_struct **tasks_arr = ctx->tasks_arr;
+	int nr_tasks = ctx->nr_tasks;
+	int nr = 0;
+	int ret;
+
+	read_lock(&tasklist_lock);
+
+	/* we hold the lock, so root_task->real_parent can't change */
+	task = ctx->root_task;
+	if (ctx->root_init) {
+		/* container-init: start from container parent */
+		parent = task->real_parent;
+		root = parent;
+	} else {
+		/* non-container-init: start from root task and down */
+		parent = NULL;
+		root = task;
+	}
+
+	/* count tasks via DFS scan of the tree */
+	while (1) {
+		/* is this task cool ? */
+		ret = may_checkpoint_task(task, ctx);
+		if (ret < 0) {
+			nr = ret;
+			break;
+		}
+		if (tasks_arr) {
+			/* unlikely... but if so then try again later */
+			if (nr == nr_tasks) {
+				nr = -EAGAIN; /* cleanup in ckpt_ctx_free() */
+				break;
+			}
+			tasks_arr[nr] = task;
+			get_task_struct(task);
+		}
+		nr++;
+		/* if has children - proceed with child */
+		if (!list_empty(&task->children)) {
+			parent = task;
+			task = list_entry(task->children.next,
+					  struct task_struct, sibling);
+			continue;
+		}
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
+		if (task == root)
+			break;
+	}
+
+	read_unlock(&tasklist_lock);
+	return nr;
+}
+
+/*
+ * build_tree - scan the tasks tree in DFS order and fill in array
+ * @ctx: checkpoint context
+ *
+ * Using DFS order simplifies the restart logic to re-create the tasks.
+ *
+ * On success, ctx->tasks_arr will be allocated and populated with all
+ * tasks (reference taken), and ctx->nr_tasks will hold the total count.
+ * The array is cleaned up by ckpt_ctx_free().
+ */
+static int build_tree(struct ckpt_ctx *ctx)
+{
+	int n, m;
+
+	/* count tasks (no side effects) */
+	n = tree_count_tasks(ctx);
+	if (n < 0)
+		return n;
+
+	ctx->nr_tasks = n;
+	ctx->tasks_arr = kzalloc(n * sizeof(*ctx->tasks_arr), GFP_KERNEL);
+	if (!ctx->tasks_arr)
+		return -ENOMEM;
+
+	/* count again (now will fill array) */
+	m = tree_count_tasks(ctx);
+
+	/* unlikely, but ... (cleanup in ckpt_ctx_free) */
+	if (m < 0)
+		return m;
+	else if (m != n)
+		return -EBUSY;
+
+	return 0;
+}
+
+/* dump the array that describes the tasks tree */
+static int checkpoint_tree(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tree *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TREE);
+	if (!h)
+		return -ENOMEM;
+
+	h->nr_tasks = ctx->nr_tasks;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	ret = checkpoint_pids(ctx);
+	return ret;
+}
+
+
 static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 {
 	struct task_struct *task = NULL;
@@ -183,26 +410,6 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 	if (!task)
 		goto out;
 
-#if 0	/* enable to use containers */
-	if (!is_container_init(task)) {
-		err = -EINVAL;
-		goto out;
-	}
-#endif
-
-	if (!ptrace_may_access(task, PTRACE_MODE_READ)) {
-		err = -EPERM;
-		goto out;
-	}
-
-	/* verify that the task is frozen (unless self) */
-	if (task != current && !frozen(task))
-		return -EBUSY;
-
-	/* FIX: add support for ptraced tasks */
-	if (task_ptrace(task))
-		return -EBUSY;
-
 	rcu_read_lock();
 	nsproxy = task_nsproxy(task);
 	if (nsproxy)
@@ -214,6 +421,7 @@ static int get_container(struct ckpt_ctx *ctx, pid_t pid)
 
 	ctx->root_task = task;
 	ctx->root_nsproxy = nsproxy;
+	ctx->root_init = is_container_init(task);
 
 	return 0;
 
@@ -258,10 +466,16 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ret = ctx_checkpoint(ctx, pid);
 	if (ret < 0)
 		goto out;
+	ret = build_tree(ctx);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_task(ctx, ctx->root_task);
+	ret = checkpoint_tree(ctx);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_all_tasks(ctx);
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_write_tail(ctx);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 6ba0446..6484c03 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -194,6 +194,19 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
  * restart operation, and persists until the operation is completed.
  */
 
+static void task_arr_free(struct ckpt_ctx *ctx)
+{
+	int n;
+
+	for (n = 0; n < ctx->nr_tasks; n++) {
+		if (ctx->tasks_arr[n]) {
+			put_task_struct(ctx->tasks_arr[n]);
+			ctx->tasks_arr[n] = NULL;
+		}
+	}
+	kfree(ctx->tasks_arr);
+}
+
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	if (ctx->file)
@@ -206,6 +219,9 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	ckpt_pgarr_free(ctx);
 	ckpt_obj_hash_free(ctx);
 
+	if (ctx->tasks_arr)
+		task_arr_free(ctx);
+
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 84403f2..03846ca 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -47,7 +47,8 @@ enum {
 	CKPT_HDR_FNAME,
 	CKPT_HDR_OBJREF,
 
-	CKPT_HDR_TASK = 101,
+	CKPT_HDR_TREE = 101,
+	CKPT_HDR_TASK,
 	CKPT_HDR_RESTART_BLOCK,
 	CKPT_HDR_THREAD,
 	CKPT_HDR_CPU,
@@ -111,6 +112,19 @@ struct ckpt_hdr_tail {
 	__u64 magic;
 } __attribute__((aligned(8)));
 
+/* task tree */
+struct ckpt_hdr_tree {
+	struct ckpt_hdr h;
+	__s32 nr_tasks;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_pids {
+	__s32 vpid;
+	__s32 vppid;
+	__s32 vtgid;
+	__s32 vpgid;
+	__s32 vsid;
+} __attribute__((aligned(8)));
 
 /* task data */
 struct ckpt_hdr_task {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index f59f749..c3040a7 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -24,9 +24,10 @@ struct ckpt_ctx {
 
 	ktime_t ktime_begin;	/* checkpoint start time */
 
-	pid_t root_pid;		/* container identifier */
-	struct task_struct *root_task;	/* container root task */
-	struct nsproxy *root_nsproxy;	/* container root nsproxy */
+	int root_init;		/* is root a container init ? */
+	pid_t root_pid;		/* (container) root identifier */
+	struct task_struct *root_task;	/* (container) root task */
+	struct nsproxy *root_nsproxy;	/* (container) root nsproxy */
 
 	unsigned long flags;
 	unsigned long oflags;	/* restart: old flags */
@@ -37,6 +38,9 @@ struct ckpt_ctx {
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
 
+	struct task_struct **tasks_arr;	/* array of all tasks in container */
+	int nr_tasks;			/* size of tasks array */
+
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
-- 
1.5.4.3
