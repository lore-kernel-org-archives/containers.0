From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 051/100] c/r: make ckpt_may_checkpoint_task() check each
	namespace individually
Date: Sat,  1 May 2010 10:15:33 -0400
Message-ID: <1272723382-19470-52-git-send-email-orenl__42202.5395710536$1272726369$gmane$org@cs.columbia.edu>
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

For a given namespace type, say XXX, if a checkpoint was taken on a
CONFIG_XXX_NS system, is restarted on a !CONFIG_XXX_NS, then ensure
that:

1) The global settings of the global (init) namespace do not get
overwritten. Creating new objects in that namespace is ok, as long as
the request identifier is available.

2) All restarting tasks use a single namespace - because it is
impossible to create additional namespaces to accommodate for what had
been checkpointed.

Original patch introducing nsproxy c/r by Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Chagnelog[v19]:
  - Restart to handle checkpoint images lacking {uts,ipc}-ns
Chagnelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Chagnelog[v18]:
  - Add a few more ckpt_write_err()s
Chagnelog[v17]:
  - Only collect sub-objects of struct_nsproxy once.
  - Restore namespace pieces directly instead of using sys_unshare()
  - Proper handling of restart from namespace(s) without namespace(s)

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h     |    3 +
 include/linux/checkpoint_hdr.h |   16 +++++
 kernel/checkpoint/checkpoint.c |   29 +++++++-
 kernel/checkpoint/objhash.c    |    2 +
 kernel/checkpoint/process.c    |   81 ++++++++++++++++++++++++
 kernel/nsproxy.c               |  136 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 263 insertions(+), 4 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 24ad717..2b6d0c7 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -166,6 +166,9 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
 extern int restore_restart_block(struct ckpt_ctx *ctx);
 
+/* namespaces */
+extern int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t);
+
 /* file table */
 extern int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index fbcbee7..f119991 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -76,6 +76,8 @@ enum {
 #define CKPT_HDR_TREE CKPT_HDR_TREE
 	CKPT_HDR_TASK,
 #define CKPT_HDR_TASK CKPT_HDR_TASK
+	CKPT_HDR_TASK_NS,
+#define CKPT_HDR_TASK_NS CKPT_HDR_TASK_NS
 	CKPT_HDR_TASK_OBJS,
 #define CKPT_HDR_TASK_OBJS CKPT_HDR_TASK_OBJS
 	CKPT_HDR_RESTART_BLOCK,
@@ -84,6 +86,8 @@ enum {
 #define CKPT_HDR_THREAD CKPT_HDR_THREAD
 	CKPT_HDR_CPU,
 #define CKPT_HDR_CPU CKPT_HDR_CPU
+	CKPT_HDR_NS,
+#define CKPT_HDR_NS CKPT_HDR_NS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -141,6 +145,8 @@ enum obj_type {
 #define CKPT_OBJ_FILE CKPT_OBJ_FILE
 	CKPT_OBJ_MM,
 #define CKPT_OBJ_MM CKPT_OBJ_MM
+	CKPT_OBJ_NS,
+#define CKPT_OBJ_NS CKPT_OBJ_NS
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -225,6 +231,16 @@ struct ckpt_hdr_task {
 	__u64 clear_child_tid;
 } __attribute__((aligned(8)));
 
+/* namespaces */
+struct ckpt_hdr_task_ns {
+	struct ckpt_hdr h;
+	__s32 ns_objref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_ns {
+	struct ckpt_hdr h;
+} __attribute__((aligned(8)));
+
 /* task's shared resources */
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 0f83cca..ab1081c 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -219,6 +219,8 @@ static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
 static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct task_struct *root = ctx->root_task;
+	struct nsproxy *nsproxy;
+	int ret = 0;
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
@@ -258,11 +260,30 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -EINVAL;
 	}
 
-	/* FIX: change this when namespaces are added */
-	if (task_nsproxy(t) != ctx->root_nsproxy)
-		return -EPERM;
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
+		ret = -EPERM;
+	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
+		ret = -EPERM;
+	/* no support for >1 private mntns */
+	if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns) {
+		_ckpt_err(ctx, -EPERM, "%(T)Nested mnt_ns unsupported\n");
+		ret = -EPERM;
+	}
+	/* no support for >1 private netns */
+	if (nsproxy->net_ns != ctx->root_nsproxy->net_ns) {
+		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
+		ret = -EPERM;
+	}
+	/* no support for >1 private pidns */
+	if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns) {
+		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
+		ret = -EPERM;
+	}
+	rcu_read_unlock();
 
-	return 0;
+	return ret;
 }
 
 #define CKPT_HDR_PIDS_CHUNK	256
diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
index 1d78dbf..d504568 100644
--- a/kernel/checkpoint/objhash.c
+++ b/kernel/checkpoint/objhash.c
@@ -498,6 +498,8 @@ int ckpt_obj_contained(struct ckpt_ctx *ctx)
 	ckpt_obj_users_inc(ctx, ctx->file, 1);
 	if (ctx->logfile)
 		ckpt_obj_users_inc(ctx, ctx->logfile, 1);
+	/* account for ctx->root_nsproxy (if in the table already) */
+	ckpt_obj_users_inc(ctx, ctx->root_nsproxy, 1);
 
 	hlist_for_each_entry(obj, node, &ctx->obj_hash->list, next) {
 		if (!obj->ops->ref_users)
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 1ec5c6a..22fb938 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -12,6 +12,7 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/posix-timers.h>
 #include <linux/futex.h>
 #include <linux/compat.h>
@@ -103,6 +104,35 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_ns *h;
+	struct nsproxy *nsproxy;
+	int ns_objref;
+	int ret;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	ns_objref = checkpoint_obj(ctx, nsproxy, CKPT_OBJ_NS);
+	put_nsproxy(nsproxy);
+
+	ckpt_debug("nsproxy: objref %d\n", ns_objref);
+	if (ns_objref < 0)
+		return ns_objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
+	if (!h)
+		return -ENOMEM;
+	h->ns_objref = ns_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -110,6 +140,19 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int mm_objref;
 	int ret;
 
+	/*
+	 * Shared objects may have dependencies among them: task->mm
+	 * depends on task->nsproxy (by ipc_ns). Therefore first save
+	 * the namespaces, and then the remaining shared objects.
+	 * During restart a task will already have its namespaces
+	 * restored when it gets to restore, e.g. its memory.
+	 */
+
+	ret = checkpoint_task_ns(ctx, t);
+	ckpt_debug("ns: objref %d\n", ret);
+	if (ret < 0)
+		return ret;
+
 	files_objref = checkpoint_obj_file_table(ctx, t);
 	ckpt_debug("files: objref %d\n", files_objref);
 	if (files_objref < 0) {
@@ -284,6 +327,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	int ret;
 
+	ret = ckpt_collect_ns(ctx, t);
+	if (ret < 0)
+		return ret;
 	ret = ckpt_collect_file_table(ctx, t);
 	if (ret < 0)
 		return ret;
@@ -359,11 +405,46 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_ns *h;
+	struct nsproxy *nsproxy;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_NS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	nsproxy = ckpt_obj_fetch(ctx, h->ns_objref, CKPT_OBJ_NS);
+	if (IS_ERR(nsproxy)) {
+		ret = PTR_ERR(nsproxy);
+		goto out;
+	}
+
+	if (nsproxy != task_nsproxy(current)) {
+		get_nsproxy(nsproxy);
+		switch_task_namespaces(current, nsproxy);
+	}
+ out:
+	ckpt_debug("nsproxy: ret %d (%p)\n", ret, task_nsproxy(current));
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 static int restore_task_objs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_objs *h;
 	int ret;
 
+	/*
+	 * Namespaces come first, because ->mm depends on ->nsproxy,
+	 * and because shared objects are restored before they are
+	 * referenced. See comment in checkpoint_task_objs.
+	 */
+	ret = restore_task_ns(ctx);
+	if (ret < 0)
+		return ret;
+
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f74e6c0..7082283 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -22,6 +22,7 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/checkpoint.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -233,10 +234,145 @@ void exit_task_namespaces(struct task_struct *p)
 	switch_task_namespaces(p, NULL);
 }
 
+#ifdef CONFIG_CHECKPOINT
+int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct nsproxy *nsproxy;
+	int exists;
+	int ret;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	if (nsproxy)
+		get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	if (!nsproxy)
+		return 0;
+
+	/* if already exists, don't proceed inside the struct */
+	exists = ckpt_obj_lookup(ctx, nsproxy, CKPT_OBJ_NS);
+
+	ret = ckpt_obj_collect(ctx, nsproxy, CKPT_OBJ_NS);
+	if (ret < 0 || exists)
+		goto out;
+
+	/* TODO: collect other namespaces here */
+ out:
+	put_nsproxy(nsproxy);
+	return ret;
+}
+
+static int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct nsproxy *nsproxy = ptr;
+	struct ckpt_hdr_ns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (!h)
+		return -ENOMEM;
+
+	/* TODO: Write other namespaces here */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static void *restore_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ns *h;
+	struct nsproxy *nsproxy = NULL;
+	struct uts_namespace *uts_ns;
+	struct ipc_namespace *ipc_ns;
+	struct mnt_namespace *mnt_ns;
+	struct net *net_ns;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
+	if (IS_ERR(h))
+		return (void *) h;
+
+	uts_ns = ctx->root_nsproxy->uts_ns;
+	ipc_ns = ctx->root_nsproxy->ipc_ns;
+	mnt_ns = ctx->root_nsproxy->mnt_ns;
+	net_ns = ctx->root_nsproxy->net_ns;
+
+	if (uts_ns == current->nsproxy->uts_ns &&
+	    ipc_ns == current->nsproxy->ipc_ns &&
+	    mnt_ns == current->nsproxy->mnt_ns &&
+	    net_ns == current->nsproxy->net_ns) {
+		/* all xxx-ns are identical: reuse nsproxy */
+		nsproxy = current->nsproxy;
+		get_nsproxy(nsproxy);
+	} else {
+		nsproxy = create_nsproxy();
+		if (!nsproxy) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		get_uts_ns(uts_ns);
+		nsproxy->uts_ns = uts_ns;
+		get_ipc_ns(ipc_ns);
+		nsproxy->ipc_ns = ipc_ns;
+		get_mnt_ns(mnt_ns);
+		nsproxy->mnt_ns = mnt_ns;
+		get_net(net_ns);
+		nsproxy->net_ns = net_ns;
+
+		get_pid_ns(current->nsproxy->pid_ns);
+		nsproxy->pid_ns = current->nsproxy->pid_ns;
+	}
+ out:
+	if (ret < 0)
+		nsproxy = ERR_PTR(ret);
+	ckpt_hdr_put(ctx, h);
+	return (void *) nsproxy;
+}
+
+static int obj_ns_grab(void *ptr)
+{
+	get_nsproxy((struct nsproxy *) ptr);
+	return 0;
+}
+
+static void obj_ns_drop(void *ptr, int lastref)
+{
+	put_nsproxy((struct nsproxy *) ptr);
+}
+
+static int obj_ns_users(void *ptr)
+{
+	return atomic_read(&((struct nsproxy *) ptr)->count);
+}
+
+/* ns object */
+static const struct ckpt_obj_ops ckpt_obj_nsproxy_ops = {
+	.obj_name = "NSPROXY",
+	.obj_type = CKPT_OBJ_NS,
+	.ref_drop = obj_ns_drop,
+	.ref_grab = obj_ns_grab,
+	.ref_users = obj_ns_users,
+	.checkpoint = checkpoint_ns,
+	.restore = restore_ns,
+};
+
+static inline int checkpoint_register_nsproxy(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_nsproxy_ops);
+}
+#endif /* CONFIG_CHECKPOINT */
+
 static int __init nsproxy_cache_init(void)
 {
 	nsproxy_cachep = KMEM_CACHE(nsproxy, SLAB_PANIC);
+#ifdef CONFIG_CHECKPOINT
+	return checkpoint_register_nsproxy();
+#else
 	return 0;
+#endif
 }
 
 module_init(nsproxy_cache_init);
-- 
1.6.3.3
