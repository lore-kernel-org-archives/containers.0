From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 36/54] Make ckpt_may_checkpoint_task() check each
	namespace individually
Date: Tue, 28 Apr 2009 19:24:06 -0400
Message-ID: <1240961064-13991-37-git-send-email-orenl@cs.columbia.edu>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   24 ++++++++++++--
 checkpoint/objhash.c           |   21 ++++++++++++
 checkpoint/process.c           |   67 ++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h     |    4 ++
 include/linux/checkpoint_hdr.h |    9 +++++
 5 files changed, 119 insertions(+), 6 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6305e5d..64b5b45 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -184,6 +184,8 @@ static int checkpoint_all_tasks(struct ckpt_ctx *ctx)
 static int may_checkpoint_task(struct task_struct *t, struct ckpt_ctx *ctx)
 {
 	struct pid_namespace *ns = ctx->root_nsproxy->pid_ns;
+	struct nsproxy *nsproxy;
+	int ret = 0;
 
 	ckpt_debug("check %d\n", task_pid_nr_ns(t, ns));
 
@@ -211,11 +213,25 @@ static int may_checkpoint_task(struct task_struct *t, struct ckpt_ctx *ctx)
 	    t->real_parent == ctx->root_task->real_parent)
 		return -EINVAL;
 
-	/* FIX: change this for nested containers */
-	if (task_nsproxy(t) != ctx->root_nsproxy)
-		return -EPERM;
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	if (!nsproxy) {
+		ret = -ENOSYS;
+	} else {
+		if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
+			ret = -EPERM;
+		if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
+			ret = -EPERM;
+		if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
+			ret = -EPERM;
+		if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns)
+			ret = -EPERM;
+		if (nsproxy->net_ns != ctx->root_nsproxy->net_ns)
+			ret = -EPERM;
+	}
+	rcu_read_unlock();
 
-	return 0;
+	return ret;
 }
 
 #define CKPT_HDR_PIDS_CHUNK	256
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 4fb5afa..819a1be 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -58,6 +58,7 @@ void *restore_bad(struct ckpt_ctx *ctx)
  *   obj_file_{drop,grab}: for file objects
  *   obj_inode_{drop,grab}: for inode objects
  *   obj_mm_{drop,grab}: for mm_struct objects
+ *   obj_ns_{drop,grab}: for nsproxy objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -103,6 +104,17 @@ static void obj_mm_drop(void *ptr)
 	mmput((struct mm_struct *) ptr);
 }
 
+static int obj_ns_grab(void *ptr)
+{
+	get_nsproxy((struct nsproxy *) ptr);
+	return 0;
+}
+
+static void obj_ns_drop(void *ptr)
+{
+	put_nsproxy((struct nsproxy *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -138,6 +150,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_mm,
 		.restore = restore_mm,
 	},
+	/* ns object */
+	{
+		.obj_name = "NSPROXY",
+		.obj_type = CKPT_OBJ_NS,
+		.ref_drop = obj_ns_drop,
+		.ref_grab = obj_ns_grab,
+		.checkpoint = checkpoint_ns,
+		.restore = restore_ns,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 0bd4845..2c489fd 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -162,12 +162,43 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+
+static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
+{
+	return 0;
+}
+
+int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_ns(ctx, (struct nsproxy *) ptr);
+}
+
+int checkpoint_ns_obj(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct nsproxy *nsproxy;
+	int ret;
+
+	rcu_read_lock();
+	nsproxy = task_nsproxy(t);
+	get_nsproxy(nsproxy);
+	rcu_read_unlock();
+
+	ret = checkpoint_obj(ctx, nsproxy, CKPT_OBJ_NS);
+	put_nsproxy(nsproxy);
+	return ret;
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
 	int mm_objref;
+	int ns_objref;
 	int ret;
 
+	ns_objref = checkpoint_ns_obj(ctx, t);
+	ckpt_debug("nsproxy: objref %d\n", ns_objref);
+	if (ns_objref < 0)
+		return ns_objref;
 	mm_objref = checkpoint_mm_obj(ctx, t);
 	ckpt_debug("memory: objref %d\n", mm_objref);
 	if (mm_objref < 0)
@@ -178,6 +209,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return -ENOMEM;
 
 	h->mm_objref = mm_objref;
+	h->ns_objref = ns_objref;
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	ckpt_hdr_put(ctx, h);
@@ -344,18 +376,49 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
+{
+	return task_nsproxy(current);
+}
+
+void *restore_ns(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_ns(ctx);
+}
+
+static int restore_ns_obj(struct ckpt_ctx *ctx, int ns_objref)
+{
+	struct nsproxy *nsproxy;
+
+	nsproxy = ckpt_obj_fetch(ctx, ns_objref, CKPT_OBJ_NS);
+	if (!nsproxy)
+		return -EINVAL;
+	else if (IS_ERR(nsproxy))
+		return PTR_ERR(nsproxy);
+
+	if (nsproxy != task_nsproxy(current))
+		switch_task_namespaces(current, nsproxy);
+
+	return 0;
+}
+
 static int restore_task_objs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_objs *h;
 	int ret;
 
-	h = ckpt_read_obj_type(ctx, CKPT_HDR_TASK_OBJS, sizeof(*h));
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
+	ret = restore_ns_obj(ctx, h->ns_objref);
+	ckpt_debug("nsproxy: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
 	ret = restore_mm_obj(ctx, h->mm_objref);
 	ckpt_debug("memory: ret %d\n", ret);
-
+ out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d554776..2cdd94f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -65,6 +65,10 @@ extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
 extern int restore_restart_block(struct ckpt_ctx *ctx);
 
+/* namespaces */
+extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_ns(struct ckpt_ctx *ctx);
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 8b00fb8..405d3bc 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -80,6 +80,7 @@ enum obj_type {
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_INODE,
 	CKPT_OBJ_MM,
+	CKPT_OBJ_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -144,6 +145,7 @@ struct ckpt_hdr_task {
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
 	__s32 mm_objref;
+	__s32 ns_objref;
 } __attribute__((aligned(8)));
 
 /* (thread) restart blocks */
@@ -167,6 +169,13 @@ enum restart_block_type {
 	CKPT_RESTART_BLOCK_FUTEX
 };
 
+/* namespaces */
+struct ckpt_hdr_ns {
+	struct ckpt_hdr h;
+	__u32 flags;
+	__u32 uts_ref;
+} __attribute__((aligned(8)));
+
 /* memory layout */
 struct ckpt_hdr_mm {
 	struct ckpt_hdr h;
-- 
1.5.4.3
