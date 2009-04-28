From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 38/54] Stub implementation of IPC namespace c/r
Date: Tue, 28 Apr 2009 19:24:08 -0400
Message-ID: <1240961064-13991-39-git-send-email-orenl@cs.columbia.edu>
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

Changes:
 - Update to match UTS changes

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    2 --
 checkpoint/objhash.c           |   23 +++++++++++++++++++++++
 checkpoint/process.c           |   21 ++++++++++++++++++++-
 include/linux/checkpoint.h     |   15 +++++++++++++++
 include/linux/checkpoint_hdr.h |    3 +++
 5 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 88dee51..4319976 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -218,8 +218,6 @@ static int may_checkpoint_task(struct task_struct *t, struct ckpt_ctx *ctx)
 	if (!nsproxy) {
 		ret = -ENOSYS;
 	} else {
-		if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
-			ret = -EPERM;
 		if (nsproxy->mnt_ns != ctx->root_nsproxy->mnt_ns)
 			ret = -EPERM;
 		if (nsproxy->pid_ns != ctx->root_nsproxy->pid_ns)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index abf2e47..bdc719e 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -14,6 +14,8 @@
 #include <linux/kernel.h>
 #include <linux/hash.h>
 #include <linux/file.h>
+#include <linux/sched.h>
+#include <linux/ipc_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -60,6 +62,7 @@ void *restore_bad(struct ckpt_ctx *ctx)
  *   obj_mm_{drop,grab}: for mm_struct objects
  *   obj_ns_{drop,grab}: for nsproxy objects
  *   obj_uts_ns_{drop,grab}: for uts_namespace objects
+ *   obj_ipc_ns_{drop,grab}: for ipc_namespace objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -127,6 +130,17 @@ static void obj_uts_ns_drop(void *ptr)
 	put_uts_ns((struct uts_namespace *) ptr);
 }
 
+static int obj_ipc_ns_grab(void *ptr)
+{
+	get_ipc_ns((struct ipc_namespace *) ptr);
+	return 0;
+}
+
+static void obj_ipc_ns_drop(void *ptr)
+{
+	put_ipc_ns((struct ipc_namespace *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -180,6 +194,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_bad,
 		.restore = restore_bad,
 	},
+	/* ipc_ns object */
+	{
+		.obj_name = "IPC_NS",
+		.obj_type = CKPT_OBJ_IPC_NS,
+		.ref_drop = obj_ipc_ns_drop,
+		.ref_grab = obj_ipc_ns_grab,
+		.checkpoint = checkpoint_bad,
+		.restore = restore_bad,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 13dd48b..966aa93 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -202,6 +202,7 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	struct ckpt_hdr_ns *h;
 	int ns_flags = 0;
 	int uts_objref;
+	int ipc_objref;
 	int first, ret;
 
 	uts_objref = ckpt_obj_lookup_add(ctx, nsproxy->uts_ns,
@@ -211,12 +212,20 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 	if (first)
 		ns_flags |= CLONE_NEWUTS;
 
+	ipc_objref = ckpt_obj_lookup_add(ctx, nsproxy->ipc_ns,
+					 CKPT_OBJ_IPC_NS, &first);
+	if (ipc_objref < 0)
+		return ipc_objref;
+	if (first)
+		ns_flags |= CLONE_NEWIPC;
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_NS);
 	if (!h)
 		return -ENOMEM;
 
 	h->flags = ns_flags;
 	h->uts_ref = uts_objref;
+	h->ipc_ref = ipc_objref;
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	ckpt_hdr_put(ctx, h);
@@ -225,6 +234,10 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 
 	if (ns_flags & CLONE_NEWUTS)
 		ret = checkpoint_uts_ns(ctx, nsproxy->uts_ns);
+#if 0
+	if (!ret && (ns_flags & CLONE_NEWIPC))
+		ret = checkpoint_ipc_ns(ctx, nsproxy->ipc_ns);
+#endif
 
 	/* FIX: Write other namespaces here */
 	return ret;
@@ -514,7 +527,7 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	ret = -EINVAL;
 	if (h->uts_ref < 0)
 		goto out;
-	if (h->flags & ~CLONE_NEWUTS)
+	if (h->flags & ~(CLONE_NEWUTS | CLONE_NEWIPC))
 		goto out;
 
 	/* each unseen-before namespace will be un-shared now */
@@ -530,6 +543,12 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	 */
 	ret = restore_uts_ns(ctx, h->uts_ref, h->flags);
 	ckpt_debug("uts ns: %d\n", ret);
+	if (ret < 0)
+		goto out;
+#if 0
+	ret = restore_ipc_ns(ctx, h->ipc_ref, h->flags);
+	ckpt_debug("ipc ns: %d\n", ret);
+#endif
 
 	/* FIX: add more namespaces here */
  out:
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 2cdd94f..867033c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -69,6 +69,21 @@ extern int restore_restart_block(struct ckpt_ctx *ctx);
 extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_ns(struct ckpt_ctx *ctx);
 
+#if 0
+/* ipc-ns */
+#ifdef CONFIG_SYSVIPC
+extern int checkpoint_ipc_ns(struct ckpt_ctx *ctx,
+			     struct ipc_namespace *ipc_ns);
+extern int restore_ipc_ns(struct ckpt_ctx *ctx, int ns_objref, int flags);
+#else
+static inline int checkpoint_ipc_ns(struct ckpt_ctx *ctx,
+				    struct ipc_namespace *ipc_ns)
+{ return 0; }
+static inline int restore_ipc_ns(struct ckpt_ctx *ctx)
+{ return 0; }
+#endif /* CONFIG_SYSVIPC */
+#endif
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4945de6..3051031 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -55,6 +55,7 @@ enum {
 	CKPT_HDR_CPU,
 	CKPT_HDR_NS,
 	CKPT_HDR_UTS_NS,
+	CKPT_HDR_IPC_NS,
 
 	CKPT_HDR_MM = 201,
 	CKPT_HDR_VMA,
@@ -84,6 +85,7 @@ enum obj_type {
 	CKPT_OBJ_MM,
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
+	CKPT_OBJ_IPC_NS,
 	CKPT_OBJ_MAX
 };
 
@@ -177,6 +179,7 @@ struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
 	__u32 flags;
 	__u32 uts_ref;
+	__u32 ipc_ref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_utsns {
-- 
1.5.4.3
