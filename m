From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 46/54] sysvipc-shm: correctly handle deleted (active)
	ipc shared memory
Date: Tue, 28 Apr 2009 19:24:16 -0400
Message-ID: <1240961064-13991-47-git-send-email-orenl@cs.columbia.edu>
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

During restart, an ipc shared region may have SHM_DEST, indicating
that it has been originally deleted (while still active). In this
case the task of deleting the region after restoring it is postponed
until the end of the restart; otherwise, it would be quite silly to
delete it at that time, because it will be ... gone :o

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/sys.c                 |   10 ++++++++
 include/linux/checkpoint_types.h |    1 +
 ipc/checkpoint_shm.c             |   48 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 58 insertions(+), 1 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index e3f7012..536f649 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -19,6 +19,7 @@
 #include <linux/uaccess.h>
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
+#include <linux/deferqueue.h>
 
 /*
  * ckpt_unpriv_allowed - sysctl_controlled, do not allow checkpoint of
@@ -216,8 +217,17 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
+	int ret;
+
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	if (ctx->deferqueue) {
+		ret = deferqueue_run(ctx->deferqueue);
+		if (ret != 0)
+			pr_warning("c/r: deferqueue had %d entries\n", ret);
+		deferqueue_destroy(ctx->deferqueue);
+	}
+
 	if (ctx->file)
 		fput(ctx->file);
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index a8dc5b3..8d30dbb 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -52,6 +52,7 @@ struct ckpt_ctx {
 	atomic_t refcount;
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
+	struct deferqueue_head *deferqueue;	/* queue of deferred work */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 9e0d028..d265351 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/deferqueue.h>
 
 #include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
 #include "util.h"
@@ -115,6 +116,30 @@ int checkpoint_ipc_shm(int id, void *p, void *data)
  * ipc restart
  */
 
+struct dq_ipcshm_del {
+	/*
+	 * XXX: always keep ->ipcns first so that put_ipc_ns() can
+	 * be safely provided as the dtor for this deferqueue object
+	 */
+	struct ipc_namespace *ipcns;
+	int id;
+};
+
+static int ipc_shm_delete(void *data)
+{
+	struct dq_ipcshm_del *dq = (struct dq_ipcshm_del *) data;
+	mm_segment_t old_fs;
+	int ret;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	ret = shmctl_down(dq->ipcns, dq->id, IPC_RMID, NULL, 0);
+	set_fs(old_fs);
+
+	put_ipc_ns(dq->ipcns);
+	return ret;
+}
+
 static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_shm *h,
 			    struct shmid_kernel *shp)
@@ -169,7 +194,28 @@ int restore_ipc_shm(struct ckpt_ctx *ctx)
 	if (h->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
 		goto out;
 
-	/* FIXME: this will fail for deleted ipc shm segments */
+	/*
+	 * SHM_DEST means that the shm is to be deleted after creation.
+	 * However, deleting before it's actually attached is quite silly.
+	 * Instead, we defer this task to until restart has succeeded.
+	 */
+	if (h->perms.mode & SHM_DEST) {
+		struct dq_ipcshm_del dq;
+
+		/* to not confuse the rest of the code */
+		h->perms.mode &= ~SHM_DEST;
+
+		dq.id = h->perms.id;
+		dq.ipcns = current->nsproxy->ipc_ns;
+		get_ipc_ns(dq.ipcns);
+
+		/* XXX can safely use put_ipc_ns() as dtor, see above */
+		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
+				     (deferqueue_func_t) ipc_shm_delete,
+				     (deferqueue_func_t) put_ipc_ns);
+		if (ret < 0)
+			goto out;
+	}
 
 	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
 	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
-- 
1.5.4.3
