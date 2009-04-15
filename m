From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/4] sysvipc-shm: correctly handle deleted (active) ipc
	shared memory
Date: Wed, 15 Apr 2009 11:03:03 -0500
Message-ID: <20090415160303.GC31983@us.ibm.com>
References: <20090415160221.GA31929@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415160221.GA31929-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

During restart, an ipc shared region may have SHM_DEST, indicating
that it has been originally deleted (while still active). In this
case the task of deleting the region after restoring it is postponed
until the end of the restart; otherwise, it would be quite silly to
delete it at that time, because it will be ... gone :o

Changelog:
	Apr 14 2009: Serge converts to generic deferqueue

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/sys.c           |   11 ++++++++++
 include/linux/checkpoint.h |    1 +
 ipc/ckpt_shm.c             |   45 ++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 63ee55e..3dfb7d9 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -16,6 +16,7 @@
 #include <linux/uaccess.h>
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
+#include <linux/deferqueue.h>
 
 #include "checkpoint_mem.h"
 
@@ -171,8 +172,14 @@ static void cr_task_arr_free(struct cr_ctx *ctx)
 
 static void cr_ctx_free(struct cr_ctx *ctx)
 {
+	int ret;
+
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	ret = deferqueue_run(ctx->deferqueue);
+	if (ret != 0)
+		cr_debug("deferred deferqueue had %d entries", ret);
+
 	if (ctx->file)
 		fput(ctx->file);
 
@@ -219,6 +226,10 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 		goto err;
 
 	err = -ENOMEM;
+	ctx->deferqueue = deferqueue_create();
+	if (!ctx->deferqueue)
+		goto err;
+
 	ctx->hbuf = kmalloc(CR_HBUF_TOTAL, GFP_KERNEL);
 	if (!ctx->hbuf)
 		goto err;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7e8d4e0..82d2a40 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -42,6 +42,7 @@ struct cr_ctx {
 	atomic_t refcount;
 
 	struct cr_objhash *objhash;	/* hash for shared objects */
+	struct deferqueue_head *deferqueue; /* list of deferred work */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
diff --git a/ipc/ckpt_shm.c b/ipc/ckpt_shm.c
index ee9b77a..a944b67 100644
--- a/ipc/ckpt_shm.c
+++ b/ipc/ckpt_shm.c
@@ -18,6 +18,7 @@
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/deferqueue.h>
 
 #include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
 #include "util.h"
@@ -145,6 +146,25 @@ int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
  * ipc restart
  */
 
+struct cr_dq_ipcshm_del {
+	struct ipc_namespace *ipcns;
+	int id;
+};
+
+static int cr_ipc_shm_delete(void *data)
+{
+	struct cr_dq_ipcshm_del *dq = (struct cr_dq_ipcshm_del *) data;
+	mm_segment_t old_fs;
+	int ret;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	ret = shmctl_down(dq->ipcns, dq->id, IPC_RMID, NULL, 0);
+	set_fs(old_fs);
+
+	return ret;
+}
+
 int cr_ipc_shm_attach(struct file *file,
 		      unsigned long vm_addr,
 		      unsigned long vm_flags)
@@ -224,7 +244,25 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 	if (hh->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
 		goto out;
 
-	/* FIXME: this will fail for deleted ipc shm segments */
+	/*
+	 * SHM_DEST means that the shm is to be deleted after creation.
+	 * However, deleting before it's actually attached is quite silly.
+	 * Instead, we defer this task to until restart has succeeded.
+	 */
+	if (hh->perms.mode & SHM_DEST) {
+		struct cr_dq_ipcshm_del dq;
+
+		/* to not confuse the rest of the code */
+		hh->perms.mode &= ~SHM_DEST;
+
+		dq.ipcns = current->nsproxy->ipc_ns;
+		dq.id = hh->perms.id;
+
+		ret = deferqueue_add(ctx->deferqueue, cr_ipc_shm_delete,
+				       &dq, sizeof(dq));
+		if (ret < 0)
+			goto out;
+	}
 
 	shmflag = hh->flags | hh->perms.mode | IPC_CREAT | IPC_EXCL;
 	cr_debug("shm: do_shmget size %lld flag %#x id %d\n",
@@ -235,7 +273,6 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 		goto out;
 
 	down_write(&shm_ids->rw_mutex);
-
 	ret = -EIDRM;
 	perms = ipc_lock(shm_ids, hh->perms.id);
 	if (IS_ERR(perms)) {	/* this should not happen .. but be safe */
@@ -261,9 +298,9 @@ static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
 	/* deposit in objhash and read contents in */
 	ret = cr_obj_add_ref(ctx, file, hh->objref, CR_OBJ_FILE, 0);
 	if (ret < 0)
-		goto file;
+		goto fput;
 	ret = cr_read_shmem_contents(ctx, file->f_dentry->d_inode);
- file:
+ fput:
 	fput(file);
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
-- 
1.5.4.3
