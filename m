From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 083/100] c/r: nested pid namespaces (v3)
Date: Sat,  1 May 2010 10:16:05 -0400
Message-ID: <1272723382-19470-84-git-send-email-orenl__12957.2359532633$1272728561$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Support checkpoint and restart of tasks in nested pid namespaces.  We
keep the original single pids_array to minimize memory allocations.
The pids array entries are augmented with a pidns depth (relative to
the container init's pidns.  If any tasks are in nested pid namespace,
another single array will hold all of the vpids.  At restart those are
used by userspace to determine how to call eclone().  Kernel ignores
them.

Changelog:
  Mar 31:
	Oren: Get rid of ckpt_hdr_vpids - can be inferred at restart
  Mar 29:
	Oren: Remove portion of patch that adds 'rpid'
  Mar 22:
	Use Louis Rilling's smarter ckpt_vpids algorithm
	verbatim, to handle pid_ns depths > CKPT_HDR_PIDS_CHUNK,
	as well as fix an apparent bug in my original code.

	As Louis suggested, use task_active_pid_ns() rather than
	task->nsproxy->pid_ns.  In fact it's a must, bc the
	checkpointed task may be dead and have NULL
	task->nsproxy->pid_ns.

	Oren: Add spinlock for nsproxy->pidns; use
	ckpt_read_consume() to consume vpids; and use __s32 instead
	of ckpt_vpid struct

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h       |    2 +-
 include/linux/checkpoint_hdr.h   |    2 +
 include/linux/checkpoint_types.h |    3 +
 kernel/checkpoint/checkpoint.c   |  111 +++++++++++++++++++++++++++++++++----
 kernel/checkpoint/process.c      |   22 ++++++--
 kernel/checkpoint/restart.c      |   39 ++++++++++++--
 kernel/checkpoint/sys.c          |    4 ++
 kernel/nsproxy.c                 |    9 +++-
 8 files changed, 169 insertions(+), 23 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6560f63..b7d7258 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  5
+#define CHECKPOINT_VERSION  6
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e74d668..f2779d1 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -309,11 +309,13 @@ struct ckpt_hdr_tree {
 } __attribute__((aligned(8)));
 
 struct ckpt_pids {
+	/* These pids are in the root_nsproxy's pid ns */
 	__s32 vpid;
 	__s32 vppid;
 	__s32 vtgid;
 	__s32 vpgid;
 	__s32 vsid;
+	__s32 depth; /* pid namespace depth relative to container init */
 } __attribute__((aligned(8)));
 
 /* pids */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 79c6394..b27312b 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -70,6 +70,9 @@ struct ckpt_ctx {
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
 	int nr_tasks;                   /* size of tasks array */
 
+	int nr_vpids;
+	struct pid_namespace *coord_pidns;	/* coordinator pid_ns */
+
 	/* [multi-process restart] */
 	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
 	int nr_pids;			/* size of pids array */
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 72a706e..ccc5367 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -28,6 +28,7 @@
 #include <linux/hrtimer.h>
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
+#include <linux/pid_namespace.h>
 
 /* unique checkpoint identifier (FIXME: should be per-container ?) */
 static atomic_t ctx_count = ATOMIC_INIT(0);
@@ -232,6 +233,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct task_struct *root = ctx->root_task;
 	struct nsproxy *nsproxy;
 	int ret = 0;
+	struct pid_namespace *pidns;
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
@@ -283,10 +285,15 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
 		ret = -EPERM;
 	}
-	/* no support for >1 private pidns */
-	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
-		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
-		ret = -EPERM;
+	/* pidns must be descendent of root_nsproxy */
+	pidns = nsproxy->pid_ns;
+	while (pidns != ctx->root_nsproxy->pid_ns) {
+		if (pidns == &init_pid_ns) {
+			ret = -EPERM;
+			_ckpt_err(ctx, ret, "%(T)stranger pid_ns\n");
+			break;
+		}
+		pidns = pidns->parent;
 	}
 	rcu_read_unlock();
 
@@ -295,15 +302,19 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 #define CKPT_HDR_PIDS_CHUNK	256
 
+/*
+ * Write the pids in ctx->root_nsproxy->pidns.  This info is
+ * needed at restart to unambiguously dereference tasks.
+ */
 static int checkpoint_pids(struct ckpt_ctx *ctx)
 {
 	struct ckpt_pids *h;
-	struct pid_namespace *ns;
+	struct pid_namespace *root_pidns;
 	struct task_struct *task;
 	struct task_struct **tasks_arr;
 	int nr_tasks, n, pos = 0, ret = 0;
 
-	ns = ctx->root_nsproxy->pid_ns;
+	root_pidns = ctx->root_nsproxy->pid_ns;
 	tasks_arr = ctx->tasks_arr;
 	nr_tasks = ctx->nr_tasks;
 	BUG_ON(nr_tasks <= 0);
@@ -321,15 +332,21 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
 	do {
 		rcu_read_lock();
 		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
+			struct pid_namespace *task_pidns;
 			task = tasks_arr[pos];
 
-			h[n].vpid = task_pid_nr_ns(task, ns);
-			h[n].vtgid = task_tgid_nr_ns(task, ns);
-			h[n].vpgid = task_pgrp_nr_ns(task, ns);
-			h[n].vsid = task_session_nr_ns(task, ns);
-			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
+			h[n].vpid = task_pid_nr_ns(task, root_pidns);
+			h[n].vtgid = task_tgid_nr_ns(task, root_pidns);
+			h[n].vpgid = task_pgrp_nr_ns(task, root_pidns);
+			h[n].vsid = task_session_nr_ns(task, root_pidns);
+			h[n].vppid = task_tgid_nr_ns(task->real_parent,
+					root_pidns);
+			task_pidns = task_active_pid_ns(task);
+			h[n].depth = task_pidns->level - root_pidns->level;
+
 			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
 				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
+			ctx->nr_vpids += h[n].depth;
 			pos++;
 		}
 		rcu_read_unlock();
@@ -346,6 +363,70 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int checkpoint_vpids(struct ckpt_ctx *ctx)
+{
+	__s32 *h;  /* vpid array */
+	struct pid_namespace *root_pidns, *task_pidns = NULL, *active_pidns;
+	struct task_struct *task;
+	int ret, nr_tasks = ctx->nr_tasks;
+	int tidx = 0; /* index into task array */
+	int hidx = 0; /* pids written into current __s32 chunk */
+	int vidx = 0; /* vpid index for current task */
+
+	root_pidns = ctx->root_nsproxy->pid_ns;
+	nr_tasks = ctx->nr_tasks;
+
+	ret = ckpt_write_obj_type(ctx, NULL,
+				  sizeof(*h) * ctx->nr_vpids,
+				  CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	if (!h)
+		return -ENOMEM;
+
+	do {
+		rcu_read_lock();
+		while (tidx < nr_tasks && hidx < CKPT_HDR_PIDS_CHUNK) {
+			int nsdelta;
+
+			task = ctx->tasks_arr[tidx];
+			active_pidns = task_active_pid_ns(task);
+			nsdelta = active_pidns->level - root_pidns->level;
+			if (hidx + nsdelta - vidx > CKPT_HDR_PIDS_CHUNK)
+				/*
+				 * We will release rcu before recording the
+				 * remaining vpids, but neither task nor its
+				 * pid can disappear.
+				 */
+				nsdelta = CKPT_HDR_PIDS_CHUNK - hidx + vidx;
+
+			if (vidx == 0)
+				task_pidns = active_pidns;
+			while (vidx++ < nsdelta) {
+				h[hidx++] = task_pid_nr_ns(task, task_pidns);
+				task_pidns = task_pidns->parent;
+			}
+
+			if (task_pidns == root_pidns) {
+				tidx++;
+				vidx = 0;
+			}
+		}
+		rcu_read_unlock();
+
+		ret = ckpt_kwrite(ctx, h, hidx * sizeof(*h));
+		if (ret < 0)
+			break;
+
+		hidx = 0;
+	} while (tidx < nr_tasks);
+
+	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
+	return ret;
+}
+
 static int collect_objects(struct ckpt_ctx *ctx)
 {
 	int n, ret = 0;
@@ -470,7 +551,13 @@ static int checkpoint_tree(struct ckpt_ctx *ctx)
 		return ret;
 
 	ret = checkpoint_pids(ctx);
-	return ret;
+	if (ret < 0)
+		return ret;
+
+	if (ctx->nr_vpids == 0)
+		return 0;
+
+	return checkpoint_vpids(ctx);
 }
 
 static struct task_struct *get_freezer_task(struct task_struct *root_task)
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 922287b..f6f3771 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -23,7 +23,7 @@
 #include <linux/syscalls.h>
 #include <linux/security.h> /* security_task_setpgid()   */
 #include <linux/checkpoint.h>
-
+#include <linux/pid_namespace.h>
 
 pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
 {
@@ -52,7 +52,7 @@ struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
 		 * Find the owner process of this pgid (it must exist
 		 * if pgrp exists). It must be a thread group leader.
 		 */
-		pgrp = find_vpid(pgid);
+		pgrp = find_pid_ns(pgid, ctx->root_nsproxy->pid_ns);
 		p = pid_task(pgrp, PIDTYPE_PID);
 		if (!p || !thread_group_leader(p))
 			return NULL;
@@ -561,6 +561,13 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/*
+ * restart is currently serialized, but if/when that changes we want
+ * to make sure that setting nsproxy->pidns in restore_task_ns() is only
+ * done once.  That's what checkpoint_nslock is for
+ */
+DEFINE_SPINLOCK(checkpoint_nslock);
+
 static int restore_task_ns(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_ns *h;
@@ -578,6 +585,10 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
 	}
 
 	if (nsproxy != task_nsproxy(current)) {
+		spin_lock(&checkpoint_nslock);
+		if (!nsproxy->pid_ns)
+			nsproxy->pid_ns = get_pid_ns(current->nsproxy->pid_ns);
+		spin_unlock(&checkpoint_nslock);
 		get_nsproxy(nsproxy);
 		switch_task_namespaces(current, nsproxy);
 	}
@@ -829,8 +840,8 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 
 	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
 
-	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
-		return 0;
+	if (pgid == task_pgrp_nr_ns(task, ctx->root_nsproxy->pid_ns))
+		return 0;  /* nothing to do */
 
 	if (task->signal->leader)  /* (2) */
 		return -EINVAL;
@@ -850,6 +861,9 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 	if (ctx->uflags & RESTART_TASKSELF)
 		ret = 0;
 
+	if (ret < 0)
+		ckpt_err(ctx, ret, "setting pgid\n");
+
 	return ret;
 }
 
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 7c38c1a..2314f7d 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -24,6 +24,7 @@
 #include <linux/termios.h>
 #include <linux/elf.h>
 #include <linux/deferqueue.h>
+#include <linux/pid_namespace.h>
 #include <linux/checkpoint.h>
 
 #include <asm/syscall.h>
@@ -719,6 +720,29 @@ static int restore_read_tree(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/*
+ * read all the vpids - we don't actually care about them,
+ * userspace did
+ */
+static int restore_slurp_vpids(struct ckpt_ctx *ctx)
+{
+	int size, ret, i;
+
+	for (i = 0; i < ctx->nr_pids; i++)
+		ctx->nr_vpids += ctx->pids_arr[i].depth;
+
+	if (ctx->nr_vpids == 0)
+		return 0;
+
+	size = sizeof(__s32) * ctx->nr_vpids;
+	if (size < 0)		/* overflow ? */
+		return -EINVAL;
+
+	ret = ckpt_read_consume(ctx, size + sizeof(struct ckpt_hdr),
+				CKPT_HDR_BUFFER);
+	return ret;
+}
+
 static inline int all_tasks_activated(struct ckpt_ctx *ctx)
 {
 	return (ctx->active_pid == ctx->nr_pids);
@@ -807,7 +831,8 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 		pid = get_active_pid(ctx);
 
 		rcu_read_lock();
-		task = find_task_by_pid_ns(pid, ctx->root_nsproxy->pid_ns);
+		task = find_task_by_pid_ns(pid,
+					task_active_pid_ns(ctx->root_task));
 		/* target task must have same restart context */
 		if (task && task->checkpoint_ctx == ctx)
 			wake_up_process(task);
@@ -829,7 +854,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 
 static int wait_task_active(struct ckpt_ctx *ctx)
 {
-	pid_t pid = task_pid_vnr(current);
+	pid_t pid = task_pid_nr_ns(current, task_active_pid_ns(ctx->root_task));
 	int ret;
 
 	ckpt_debug("pid %d waiting\n", pid);
@@ -845,7 +870,8 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 
 static int wait_task_sync(struct ckpt_ctx *ctx)
 {
-	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
+	ckpt_debug("pid %d syncing\n",
+		task_pid_nr_ns(current, task_active_pid_ns(ctx->root_task)));
 	wait_event_interruptible(ctx->waitq, ckpt_test_complete(ctx));
 	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
 	if (ckpt_test_error(ctx))
@@ -1119,7 +1145,7 @@ static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
 
 	read_lock(&tasklist_lock);
 	list_for_each_entry(task, &current->children, sibling) {
-		if (task_pid_vnr(task) == pid) {
+		if (task_pid_nr_ns(task, ctx->coord_pidns) == pid) {
 			get_task_struct(task);
 			ctx->root_task = task;
 			ctx->root_pid = pid;
@@ -1196,6 +1222,11 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 
+	ret = restore_slurp_vpids(ctx);
+	ckpt_debug("read vpids %d\n", ret);
+	if (ret < 0)
+		return ret;
+
 	if ((ctx->uflags & RESTART_TASKSELF) && ctx->nr_pids != 1)
 		return -EINVAL;
 
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index b8369e4..a20ce9f 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -25,6 +25,7 @@
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/deferqueue.h>
+#include <linux/pid_namespace.h>
 
 /*
  * ckpt_unpriv_allowed - sysctl controlled.
@@ -218,6 +219,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
 
+	if (ctx->coord_pidns)
+		put_pid_ns(ctx->coord_pidns);
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
@@ -249,6 +252,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->uflags = uflags;
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
+	ctx->coord_pidns = get_pid_ns(current->nsproxy->pid_ns);
 
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 5bdce9e..7fb3cea 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -381,8 +381,13 @@ static void *restore_ns(struct ckpt_ctx *ctx)
 		get_net(net_ns);
 		nsproxy->net_ns = net_ns;
 
-		get_pid_ns(current->nsproxy->pid_ns);
-		nsproxy->pid_ns = current->nsproxy->pid_ns;
+		/*
+		 * The pid_ns will get assigned the first time that we
+		 * assign the nsproxy to a task.  The task had unshared
+		 * its pid_ns in userspace before calling restart, and
+		 * we want to keep using that pid_ns.
+		 */
+		nsproxy->pid_ns = NULL;
 	}
  out:
 	if (ret < 0)
-- 
1.6.3.3
