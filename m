From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 42/54] ipc namespace: save and restore ipc namespace
	basics
Date: Tue, 28 Apr 2009 19:24:12 -0400
Message-ID: <1240961064-13991-43-git-send-email-orenl@cs.columbia.edu>
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

Save and restores the common state (parameters) of ipc namespace.

Also add logic to iterate through the objects of sysvipc shared memory,
message queues and semaphores. The logic to save and restore the state
of these objects will be added in the next few patches.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/process.c           |    4 -
 include/linux/checkpoint.h     |    5 +-
 include/linux/checkpoint_hdr.h |   22 +++++
 ipc/checkpoint.c               |  204 ++++++++++++++++++++++++++++++++++++++--
 4 files changed, 221 insertions(+), 14 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 966aa93..b731891 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -234,10 +234,8 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 
 	if (ns_flags & CLONE_NEWUTS)
 		ret = checkpoint_uts_ns(ctx, nsproxy->uts_ns);
-#if 0
 	if (!ret && (ns_flags & CLONE_NEWIPC))
 		ret = checkpoint_ipc_ns(ctx, nsproxy->ipc_ns);
-#endif
 
 	/* FIX: Write other namespaces here */
 	return ret;
@@ -545,10 +543,8 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
 	ckpt_debug("uts ns: %d\n", ret);
 	if (ret < 0)
 		goto out;
-#if 0
 	ret = restore_ipc_ns(ctx, h->ipc_ref, h->flags);
 	ckpt_debug("ipc ns: %d\n", ret);
-#endif
 
 	/* FIX: add more namespaces here */
  out:
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8a7fe9a..f915564 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -73,7 +73,6 @@ extern int restore_restart_block(struct ckpt_ctx *ctx);
 extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_ns(struct ckpt_ctx *ctx);
 
-#if 0
 /* ipc-ns */
 #ifdef CONFIG_SYSVIPC
 extern int checkpoint_ipc_ns(struct ckpt_ctx *ctx,
@@ -86,7 +85,9 @@ static inline int checkpoint_ipc_ns(struct ckpt_ctx *ctx,
 static inline int restore_ipc_ns(struct ckpt_ctx *ctx)
 { return 0; }
 #endif /* CONFIG_SYSVIPC */
-#endif
+
+extern int checkpoint_ipcns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns);
+extern int restore_ipcns(struct ckpt_ctx *ctx);
 
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0af5532..2ad3cb7 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -285,6 +285,28 @@ struct ckpt_hdr_file_pipe_state {
 } __attribute__((aligned(8)));
 
 /* ipc commons */
+struct ckpt_hdr_ipcns {
+	struct ckpt_hdr h;
+	__u64 shm_ctlmax;
+	__u64 shm_ctlall;
+	__s32 shm_ctlmni;
+
+	__s32 msg_ctlmax;
+	__s32 msg_ctlmnb;
+	__s32 msg_ctlmni;
+
+	__s32 sem_ctl_msl;
+	__s32 sem_ctl_mns;
+	__s32 sem_ctl_opm;
+	__s32 sem_ctl_mni;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_ipc {
+	struct ckpt_hdr h;
+	__u32 ipc_type;
+	__u32 ipc_count;
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_ipc_perms {
 	__s32 id;
 	__u32 key;
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 9a6cd9d..e00e524 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -17,15 +17,15 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-int checkpoint_ipcns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
-{
-	return 0;
-}
+#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
+#include "util.h"
 
-int restore_ipcns(struct ckpt_ctx *ctx)
-{
-	return 0;
-}
+/* for ckpt_debug */
+static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
+
+/**************************************************************************
+ * Checkpoint
+ */
 
 void checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 			       struct kern_ipc_perm *perm)
@@ -40,6 +40,82 @@ void checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	h->seq = perm->seq;
 }
 
+static int checkpoint_ipc_any(struct ckpt_ctx *ctx,
+			      struct ipc_namespace *ipc_ns,
+			      int ipc_ind, int ipc_type,
+			      int (*func)(int id, void *p, void *data))
+{
+	struct ckpt_hdr_ipc *h;
+	struct ipc_ids *ipc_ids = &ipc_ns->ids[ipc_ind];
+	int ret = -ENOMEM;
+
+	down_read(&ipc_ids->rw_mutex);
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC);
+	if (!h)
+		goto out;
+
+	h->ipc_type = ipc_type;
+	h->ipc_count = ipc_ids->in_use;
+	ckpt_debug("ipc-%s count %d\n", ipc_ind_to_str[ipc_ind], h->ipc_count);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ret = idr_for_each(&ipc_ids->ipcs_idr, func, ctx);
+	ckpt_debug("ipc-%s ret %d\n", ipc_ind_to_str[ipc_ind], ret);
+ out:
+	up_read(&ipc_ids->rw_mutex);
+	return ret;
+}
+
+int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
+{
+	struct ckpt_hdr_ipcns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_NS);
+	if (!h)
+		return -ENOMEM;
+
+	h->shm_ctlmax = ipc_ns->shm_ctlmax;
+	h->shm_ctlall = ipc_ns->shm_ctlall;
+	h->shm_ctlmni = ipc_ns->shm_ctlmni;
+
+	h->msg_ctlmax = ipc_ns->msg_ctlmax;
+	h->msg_ctlmnb = ipc_ns->msg_ctlmnb;
+	h->msg_ctlmni = ipc_ns->msg_ctlmni;
+
+	h->sem_ctl_msl = ipc_ns->sem_ctls[0];
+	h->sem_ctl_mns = ipc_ns->sem_ctls[1];
+	h->sem_ctl_opm = ipc_ns->sem_ctls[2];
+	h->sem_ctl_mni = ipc_ns->sem_ctls[3];
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+#if 0 /* NEXT FEW PATCHES */
+	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
+				 CKPT_HDR_IPC_SHM, checkpoint_ipc_shm);
+	if (ret < 0)
+		return ret;
+	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
+				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
+	if (ret < 0)
+		return ret;
+	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
+				 CKPT_HDR_IPC_SEM, checkpoint_ipc_sem);
+#endif
+	return ret;
+}
+
+/**************************************************************************
+ * Restart
+ */
+
 int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 			   struct kern_ipc_perm *perm)
 {
@@ -71,3 +147,115 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 
 	return 0;
 }
+
+static int restore_ipc_any(struct ckpt_ctx *ctx, int ipc_ind, int ipc_type,
+			   int (*func)(struct ckpt_ctx *ctx))
+{
+	struct ckpt_hdr_ipc *h;
+	int n, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("ipc-%s: count %d\n", ipc_ind_to_str[ipc_ind], h->ipc_count);
+
+	ret = -EINVAL;
+	if (h->ipc_type != ipc_type)
+		goto out;
+
+	ret = 0;
+	for (n = 0; n < h->ipc_count; n++) {
+		ret = (*func)(ctx);
+		if (ret < 0)
+			goto out;
+	}
+ out:
+	ckpt_debug("ipc-%s: ret %d\n", ipc_ind_to_str[ipc_ind], ret);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
+{
+	struct ipc_namespace *ipc_ns = current->nsproxy->ipc_ns;
+	struct ckpt_hdr_ipcns *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_NS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->shm_ctlmax < 0 || h->shm_ctlall < 0 || h->shm_ctlmni < 0)
+		goto out;
+	if (h->msg_ctlmax < 0 || h->msg_ctlmnb < 0 || h->msg_ctlmni < 0)
+		goto out;
+	if (h->sem_ctl_msl < 0 || h->sem_ctl_mns < 0 ||
+	    h->sem_ctl_opm < 0 || h->sem_ctl_mni < 0)
+		goto out;
+
+	/* this is a brand new ipc_ns: safe to rewrite its properties */
+	ipc_ns->shm_ctlmax = h->shm_ctlmax;
+	ipc_ns->shm_ctlall = h->shm_ctlall;
+	ipc_ns->shm_ctlmni = h->shm_ctlmni;
+
+	ipc_ns->msg_ctlmax = h->msg_ctlmax;
+	ipc_ns->msg_ctlmnb = h->msg_ctlmnb;
+	ipc_ns->msg_ctlmni = h->msg_ctlmni;
+
+	ipc_ns->sem_ctls[0] = h->sem_ctl_msl;
+	ipc_ns->sem_ctls[1] = h->sem_ctl_mns;
+	ipc_ns->sem_ctls[2] = h->sem_ctl_opm;
+	ipc_ns->sem_ctls[3] = h->sem_ctl_mni;
+
+#if 0 /* NEXT FEW PATCHES */
+	ret = restore_ipc_any(ctx, IPC_SHM_IDS,
+			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_read_ipc_any(ctx, IPC_MSG_IDS,
+			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
+	if (ret < 0)
+		goto out;
+	ret = restore_ipc_any(ctx, IPC_SEM_IDS,
+			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
+#endif
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_ipc_ns(struct ckpt_ctx *ctx, int ns_objref, int flags)
+{
+	struct ipc_namespace *ipc_ns;
+	int ret = 0;
+
+	ipc_ns = ckpt_obj_fetch(ctx, ns_objref, CKPT_OBJ_IPC_NS);
+	if (IS_ERR(ipc_ns))
+		return PTR_ERR(ipc_ns);
+
+	/* sanity: CLONE_NEWIPC if-and-only-if ipc_ns is NULL (first timer) */
+	if (!!ipc_ns ^ !(flags & CLONE_NEWIPC))
+		return -EINVAL;
+
+	if (!ipc_ns) {
+		ret = do_restore_ipc_ns(ctx);
+		if (ret < 0)
+			return ret;
+		ret = ckpt_obj_insert(ctx, current->nsproxy->ipc_ns,
+				      ns_objref, CKPT_OBJ_IPC_NS);
+	} else {
+		struct ipc_namespace *old_ipc_ns;
+
+		/* safe because nsproxy->count must be 1 ... */
+		BUG_ON(atomic_read(&current->nsproxy->count) != 1);
+
+		old_ipc_ns = current->nsproxy->ipc_ns;
+		current->nsproxy->ipc_ns = ipc_ns;
+		get_ipc_ns(ipc_ns);
+		put_ipc_ns(old_ipc_ns);
+	}
+
+	return ret;
+}
-- 
1.5.4.3
