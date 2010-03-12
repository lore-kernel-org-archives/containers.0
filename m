From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH] linux-cr: Handle nested pid namespaces
Date: Thu, 11 Mar 2010 23:27:55 -0600
Message-ID: <1268371676-3029-2-git-send-email-serue@us.ibm.com>
References: <1268371676-3029-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268371676-3029-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

In place of one big pids array, checkpoint one struct ckpt_hdr_pids
per task.  It contains pid/ppid/etc in the root nsproxy's pidns, and
is followed by a list of all virtual pids in child pid namespaces, if
any.

When an nsproxy is created during do_restore_ns(), we don't yet set
its pid_ns - I *think* the nsproxy will generally get recreated by
the task which will use it, but we may as well be sure by having
the pid_ns set when the nsproxy is first assigned.

This patch applies on top of ckpt-v19-dev-serge.  With this patch
applied (and the corresponding user-cr patch), all cr_tests pass,
including a new pidns test.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c          |   91 +++++++++++++++++++++++--------------
 checkpoint/process.c             |   27 +++++++-----
 checkpoint/restart.c             |   59 ++++++++++++++++--------
 checkpoint/sys.c                 |    8 +++-
 include/linux/checkpoint_hdr.h   |   19 +++++---
 include/linux/checkpoint_types.h |    3 +
 kernel/nsproxy.c                 |    9 +++-
 7 files changed, 141 insertions(+), 75 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index b3c1c4f..d40a092 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -27,6 +27,7 @@
 #include <linux/deferqueue.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/pid_namespace.h>
 
 /* unique checkpoint identifier (FIXME: should be per-container ?) */
 static atomic_t ctx_count = ATOMIC_INIT(0);
@@ -237,6 +238,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct task_struct *root = ctx->root_task;
 	struct nsproxy *nsproxy;
+	struct pid_namespace *pidns;
 	int ret = 0;
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
@@ -289,66 +291,85 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
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
 
 	return ret;
 }
 
-#define CKPT_HDR_PIDS_CHUNK	256
+/* called under rcu_read_lock */
+static void copy_task(struct ckpt_hdr_pids *h, struct task_struct *t,
+			struct pid_namespace *root_pid_ns,
+			struct pid_namespace *task_pid_ns)
+{
+	int i = 0;
+	__s32 *pids;
+
+	h->pid = task_pid_nr_ns(t, root_pid_ns);
+	h->tgid = task_tgid_nr_ns(t, root_pid_ns);
+	h->pgid = task_pgrp_nr_ns(t, root_pid_ns);
+	h->sid = task_session_nr_ns(t, root_pid_ns);
+	h->ppid = task_tgid_nr_ns(t->real_parent, root_pid_ns);
+	h->rpid = task_pid_vnr(t);
+	pids = h->vpids;
+
+	while (task_pid_ns != root_pid_ns) {
+		pids[i++] = task_pid_nr_ns(t, task_pid_ns);
+		task_pid_ns = task_pid_ns->parent;
+	}
+}
 
 static int checkpoint_pids(struct ckpt_ctx *ctx)
 {
-	struct ckpt_pids *h;
-	struct pid_namespace *ns;
+	struct ckpt_hdr_pids *h;
+	struct pid_namespace *root_pidns;
 	struct task_struct *task;
 	struct task_struct **tasks_arr;
-	int nr_tasks, n, pos = 0, ret = 0;
+	int nr_tasks, i, ret = 0;
 
-	ns = ctx->root_nsproxy->pid_ns;
+	root_pidns = ctx->root_nsproxy->pid_ns;
 	tasks_arr = ctx->tasks_arr;
 	nr_tasks = ctx->nr_tasks;
 	BUG_ON(nr_tasks <= 0);
 
-	ret = ckpt_write_obj_type(ctx, NULL,
-				  sizeof(*h) * nr_tasks,
-				  CKPT_HDR_BUFFER);
-	if (ret < 0)
-		return ret;
+	for (i=0; i<nr_tasks; i++) {
+		int nsdelta, size;
+		struct pid_namespace *task_pidns;
 
-	h = ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
-	if (!h)
-		return -ENOMEM;
+		task = tasks_arr[i];
+		rcu_read_lock();
+		task_pidns = task_nsproxy(task)->pid_ns;
+		rcu_read_unlock();
+
+		nsdelta = task_pidns->level - root_pidns->level;
+		size = sizeof(*h) + nsdelta * sizeof(__s32);
+
+		h = ckpt_hdr_get_type(ctx, size, CKPT_HDR_PID);
+		if (!h)
+			return -ENOMEM;
 
-	do {
 		rcu_read_lock();
-		for (n = 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
-			task = tasks_arr[pos];
-
-			h[n].vpid = task_pid_nr_ns(task, ns);
-			h[n].vtgid = task_tgid_nr_ns(task, ns);
-			h[n].vpgid = task_pgrp_nr_ns(task, ns);
-			h[n].vsid = task_session_nr_ns(task, ns);
-			h[n].vppid = task_tgid_nr_ns(task->real_parent, ns);
-			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
-				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
-			pos++;
-		}
+		copy_task(h, task, root_pidns, task_pidns);
 		rcu_read_unlock();
+		ckpt_debug("task[%d]: pid %d tgid %d parent %d\n",
+			   i, h->pid, h->tgid, h->ppid);
 
-		n = min(nr_tasks, CKPT_HDR_PIDS_CHUNK);
-		ret = ckpt_kwrite(ctx, h, n * sizeof(*h));
+		ret = ckpt_write_obj(ctx, &h->h);
+		ckpt_hdr_put(ctx, h);
 		if (ret < 0)
 			break;
 
-		nr_tasks -= n;
-	} while (nr_tasks > 0);
+	}
 
-	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
 	return ret;
 }
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index f917112..bb44960 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -22,7 +22,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/syscalls.h>
-
+#include <linux/pid_namespace.h>
 
 pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid)
 {
@@ -36,12 +36,6 @@ struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
 	struct pid *pgrp;
 
 	if (pgid == 0) {
-		/*
-		 * At checkpoint the pgid owner lived in an ancestor
-		 * pid-ns. The best we can do (sanely and safely) is
-		 * to examine the parent of this restart's root: if in
-		 * a distinct pid-ns, use its pgrp; otherwise fail.
-		 */
 		p = ctx->root_task->real_parent;
 		if (p->nsproxy->pid_ns == current->nsproxy->pid_ns)
 			return NULL;
@@ -51,7 +45,7 @@ struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid)
 		 * Find the owner process of this pgid (it must exist
 		 * if pgrp exists). It must be a thread group leader.
 		 */
-		pgrp = find_vpid(pgid);
+		pgrp = find_pid_ns(pgid, ctx->root_nsproxy->pid_ns);
 		p = pid_task(pgrp, PIDTYPE_PID);
 		if (!p || !thread_group_leader(p))
 			return NULL;
@@ -578,6 +572,14 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
 	}
 
 	if (nsproxy != task_nsproxy(current)) {
+		/*
+		 * This is *kinda* shady to do without any locking.  However
+		 * it is safe because each task is restarted separately in
+		 * serial.  If that ever changes, we'll need a spinlock?
+		 */
+		if (!nsproxy->pid_ns)
+			nsproxy->pid_ns = get_pid_ns(current->nsproxy->pid_ns);
+
 		get_nsproxy(nsproxy);
 		switch_task_namespaces(current, nsproxy);
 	}
@@ -827,10 +829,10 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 	if (!thread_group_leader(task))  /* (1) */
 		return 0;
 
-	pgid = ctx->pids_arr[ctx->active_pid].vpgid;
+	pgid = ctx->vpgids_arr[ctx->active_pid];
 
-	if (pgid == task_pgrp_vnr(task))  /* nothing to do */
-		return 0;
+	if (pgid == task_pgrp_nr_ns(task, ctx->root_nsproxy->pid_ns))
+		return 0;  /* nothing to do */
 
 	if (task->signal->leader)  /* (2) */
 		return -EINVAL;
@@ -850,6 +852,9 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 	if (ctx->uflags & RESTART_TASKSELF)
 		ret = 0;
 
+	if (ret < 0)
+		ckpt_err(ctx, ret, "setting pgid\n");
+
 	return ret;
 }
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 0891952..4d1b804 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -145,7 +145,7 @@ void restore_debug_free(struct ckpt_ctx *ctx)
 	ckpt_debug("kflags %lu uflags %lu oflags %lu", ctx->kflags,
 		   ctx->uflags, ctx->oflags);
 	for (i = 0; i < ctx->nr_pids; i++)
-		ckpt_debug("task[%d] to run %d\n", i, ctx->pids_arr[i].vpid);
+		ckpt_debug("task[%d] to run %d\n", i, ctx->vpids_arr[i]);
 
 	list_for_each_entry_safe(s, p, &ctx->task_status, list) {
 		if (s->flags & RESTART_DBG_COORD)
@@ -417,7 +417,8 @@ void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
 
 	h = ckpt_read_obj(ctx, len, len);
 	if (IS_ERR(h)) {
-		ckpt_err(ctx, PTR_ERR(h), "Expecting to read type %d\n", type);
+		ckpt_err(ctx, PTR_ERR(h), "Expecting to read type %d len %d\n",
+			type, len);
 		return h;
 	}
 
@@ -722,34 +723,51 @@ static int restore_read_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+#define CKPT_MAX_PIDS_SZ 99999
 /* restore_read_tree - read the tasks tree into the checkpoint context */
 static int restore_read_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
-	int size, ret;
+	int i, size;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TREE);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ret = -EINVAL;
+	ctx->nr_pids = h->nr_tasks;
+	ckpt_hdr_put(ctx, h);
+
 	if (h->nr_tasks <= 0)
-		goto out;
+		return -EINVAL;
 
-	ctx->nr_pids = h->nr_tasks;
-	size = sizeof(*ctx->pids_arr) * ctx->nr_pids;
+	size = sizeof(pid_t) * ctx->nr_pids;
 	if (size <= 0)		/* overflow ? */
-		goto out;
+		return -EINVAL;
 
-	ctx->pids_arr = kmalloc(size, GFP_KERNEL);
-	if (!ctx->pids_arr) {
-		ret = -ENOMEM;
-		goto out;
+	ctx->vpids_arr = kmalloc(size, GFP_KERNEL);
+	ctx->vpgids_arr = kmalloc(size, GFP_KERNEL);
+	if (!ctx->vpids_arr || !ctx->vpgids_arr)
+		return -ENOMEM;
+
+	for (i=0; i<ctx->nr_pids; i++) {
+		struct ckpt_hdr_pids *p;
+		
+		p = ckpt_read_obj(ctx, 0, CKPT_MAX_PIDS_SZ);
+		if (!p)
+			return -EINVAL;
+		if (p->h.type != CKPT_HDR_PID) {
+			ckpt_hdr_put(ctx, p);
+			return -EINVAL;
+		}
+		if (p->h.len < sizeof(*p)) {
+			ckpt_hdr_put(ctx, p);
+			return -EINVAL;
+		}
+		ctx->vpids_arr[i] = p->pid;
+		ctx->vpgids_arr[i] = p->pgid;
+		ckpt_hdr_put(ctx, p);
 	}
-	ret = _ckpt_read_buffer(ctx, ctx->pids_arr, size);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
+	return 0;
 }
 
 static inline int all_tasks_activated(struct ckpt_ctx *ctx)
@@ -760,7 +778,7 @@ static inline int all_tasks_activated(struct ckpt_ctx *ctx)
 static inline pid_t get_active_pid(struct ckpt_ctx *ctx)
 {
 	int active = ctx->active_pid;
-	return active >= 0 ? ctx->pids_arr[active].vpid : 0;
+	return active >= 0 ? ctx->vpids_arr[active] : 0;
 }
 
 static inline int is_task_active(struct ckpt_ctx *ctx, pid_t pid)
@@ -862,7 +880,7 @@ static int restore_activate_next(struct ckpt_ctx *ctx)
 
 static int wait_task_active(struct ckpt_ctx *ctx)
 {
-	pid_t pid = task_pid_vnr(current);
+	pid_t pid = task_pid_nr_ns(current, ctx->root_nsproxy->pid_ns);
 	int ret;
 
 	ckpt_debug("pid %d waiting\n", pid);
@@ -878,7 +896,8 @@ static int wait_task_active(struct ckpt_ctx *ctx)
 
 static int wait_task_sync(struct ckpt_ctx *ctx)
 {
-	ckpt_debug("pid %d syncing\n", task_pid_vnr(current));
+	ckpt_debug("pid %d syncing\n",
+		task_pid_nr_ns(current, ctx->root_nsproxy->pid_ns));
 	wait_event_interruptible(ctx->waitq, ckpt_test_complete(ctx));
 	ckpt_debug("task sync done (errno %d)\n", ctx->errno);
 	if (ckpt_test_error(ctx))
@@ -1152,7 +1171,7 @@ static struct task_struct *choose_root_task(struct ckpt_ctx *ctx, pid_t pid)
 
 	read_lock(&tasklist_lock);
 	list_for_each_entry(task, &current->children, sibling) {
-		if (task_pid_vnr(task) == pid) {
+		if (task_pid_nr_ns(task, ctx->coord_pidns) == pid) {
 			get_task_struct(task);
 			ctx->root_task = task;
 			ctx->root_pid = pid;
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index b605784..90caf61 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -22,6 +22,7 @@
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
 #include <linux/deferqueue.h>
+#include <linux/pid_namespace.h>
 
 /*
  * ckpt_unpriv_allowed - sysctl controlled.
@@ -243,6 +244,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
 
+	if (ctx->coord_pidns)
+		put_pid_ns(ctx->coord_pidns);
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
 	if (ctx->root_task)
@@ -252,7 +255,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	free_page((unsigned long) ctx->scratch_page);
 
-	kfree(ctx->pids_arr);
+	kfree(ctx->vpids_arr);
+	kfree(ctx->vpgids_arr);
 
 	sock_listening_list_free(&ctx->listen_sockets);
 
@@ -273,6 +277,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
 
+	ctx->coord_pidns = get_pid_ns(current->nsproxy->pid_ns);
+
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 41412d1..7957b3b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -117,6 +117,8 @@ enum {
 #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
 	CKPT_HDR_TASK_CREDS,
 #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
+	CKPT_HDR_PID,
+#define CKPT_HDR_PID CKPT_HDR_PID
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -326,12 +328,17 @@ struct ckpt_hdr_tree {
 	__s32 nr_tasks;
 } __attribute__((aligned(8)));
 
-struct ckpt_pids {
-	__s32 vpid;
-	__s32 vppid;
-	__s32 vtgid;
-	__s32 vpgid;
-	__s32 vsid;
+struct ckpt_hdr_pids {
+	struct ckpt_hdr h;
+	__s32 rpid;  /* pid in checkpointer's pid_ns */
+	/* The rest of these are in container init's pid_ns */
+	__s32 pid;
+	__s32 ppid;
+	__s32 tgid;
+	__s32 pgid;
+	__s32 sid;
+	/* followed by pids in pid_ns up to root->nsproxy->pid_ns */
+	__s32 vpids[0];
 } __attribute__((aligned(8)));
 
 /* pids */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5d5e00d..57a7d80 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -37,6 +37,7 @@ struct ckpt_ctx {
 	int root_init;				/* [container] root init ? */
 	pid_t root_pid;				/* [container] root pid */
 	struct task_struct *root_task;		/* [container] root task */
+	struct pid_namespace *coord_pidns;	/* coordinator pid_ns */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
 	struct task_struct *root_freezer;	/* [container] root task */
 	char lsm_name[SECURITY_NAME_MAX + 1];   /* security module at ckpt */
@@ -74,6 +75,8 @@ struct ckpt_ctx {
 
 	/* [multi-process restart] */
 	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
+	pid_t *vpids_arr;		/* array of all pids, in container pidns */
+	pid_t *vpgids_arr;		/* array of all vpgids, in container pidns */
 	int nr_pids;			/* size of pids array */
 	atomic_t nr_total;		/* total tasks count (with ghosts) */
 	int active_pid;			/* (next) position in pids array */
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 0da0d83..6d86240 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -364,8 +364,13 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
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
1.6.1
