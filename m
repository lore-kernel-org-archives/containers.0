From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 04/10] sysvipc-shm: checkpoint
Date: Tue,  7 Apr 2009 08:31:37 -0400
Message-ID: <1239107503-21941-5-git-send-email-orenl@cs.columbia.edu>
References: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107503-21941-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint of sysvipc shared memory is performed in two steps: first,
the entire ipc namespace is dumped as a whole by iterating through all
shm objects and dumping the contents of each one. The shmem inode is
registered in the objhash. Second, for each vma that refers to ipc
shared memory we find the inode in the objhash, and save the objref.

(If we find a new inode, that indicates that the ipc namespace is not
entirely frozen and someone must have manipulated it since step 1).

Handling of shm objects that have been deleted (via IPC_RMID) is left
to a later patch in this series.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |    3 -
 checkpoint/ckpt_mem.c          |    9 +++
 checkpoint/ckpt_task.c         |    2 +-
 checkpoint/restart.c           |    4 -
 checkpoint/util_ipc.c          |    7 +-
 include/linux/checkpoint.h     |    6 +-
 include/linux/checkpoint_hdr.h |   15 ++++
 ipc/Makefile                   |    1 +
 ipc/ckpt_shm.c                 |  142 ++++++++++++++++++++++++++++++++++++++++
 ipc/shm.c                      |   11 +++
 10 files changed, 186 insertions(+), 14 deletions(-)
 create mode 100644 ipc/ckpt_shm.c

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 1c6c946..47d5bd1 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -541,9 +541,6 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	ret = cr_write_tree(ctx);
 	if (ret < 0)
 		goto out;
-	ret = cr_write_ipc(ctx, ctx->root_nsproxy);
-	if (ret < 0)
-		goto out;
 
 	ret = cr_write_all_tasks(ctx);
 	if (ret < 0)
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 0df3cda..54b2674 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -566,7 +566,16 @@ static int cr_write_shared_vma_contents(struct cr_ctx *ctx,
 		inode = vma->vm_file->f_dentry->d_inode;
 		ret = cr_write_shmem_contents(ctx, inode);
 		break;
+	case CR_VMA_SHM_IPC:
+		/*
+		 * This doesn't happen, because all IPC regions should have
+		 * been already dumped by now via ipc namespaces; It means
+		 * the ipc_ns has been modified recently during checkpoint.
+		 */
+		ret = -EBUSY;
+		break;
 	case CR_VMA_SHM_ANON_SKIP:
+	case CR_VMA_SHM_IPC_SKIP:
 	case CR_VMA_SHM_FILE_SKIP:
 		/* already saved before .. skip now */
 		break;
diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index b5e330b..4d19e31 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -250,7 +250,7 @@ static int cr_write_namespaces(struct cr_ctx *ctx, struct task_struct *t)
 			goto out;
 	}
 	if (new_ipc) {
-		/* ret = cr_write_ipcns(ctx, nsproxy->ipc_ns); */ ret = 0;
+		ret = cr_write_ipcns(ctx, nsproxy->ipc_ns);
 		if (ret < 0)
 			goto out;
 	}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index c6ac1e4..dad257e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -466,10 +466,6 @@ static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 
-	ret = cr_read_ipc(ctx);
-	if (ret < 0)
-		return ret;
-
 	ret = cr_ctx_restart(ctx, pid);
 	if (ret < 0)
 		return ret;
diff --git a/checkpoint/util_ipc.c b/checkpoint/util_ipc.c
index 70c4b18..c2d2944 100644
--- a/checkpoint/util_ipc.c
+++ b/checkpoint/util_ipc.c
@@ -10,16 +10,15 @@
 
 #ifdef CONFIG_SYSVIPC
 
-#include <linux/version.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy)
+int cr_write_ipcns(struct cr_ctx *ctx, struct ipc_namespace *ipc_ns)
 {
-	return 0;
+	return cr_write_ipc_shm(ctx, ipc_ns);
 }
 
-int cr_read_ipc(struct cr_ctx *ctx)
+int cr_read_ipcns(struct cr_ctx *ctx)
 {
 	return 0;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 9d6710b..97565f8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -15,6 +15,7 @@
 #include <linux/path.h>
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
 #include <asm/atomic.h>
 
 #define CR_VERSION  3
@@ -126,14 +127,14 @@ extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 extern int cr_write_shmem_contents(struct cr_ctx *ctx, struct inode *inode);
 extern int cr_read_shmem_contents(struct cr_ctx *ctx, struct inode *inode);
 
-extern int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy);
+extern int cr_write_ipcns(struct cr_ctx *ctx, struct ipc_namespace *ipc_ns);
 extern int cr_write_task(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_restart_block(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_file(struct cr_ctx *ctx, struct file *file);
 
-extern int cr_read_ipc(struct cr_ctx *ctx);
+extern int cr_read_ipcns(struct cr_ctx *ctx);
 extern int cr_read_task(struct cr_ctx *ctx);
 extern int cr_read_restart_block(struct cr_ctx *ctx);
 extern int cr_read_mm(struct cr_ctx *ctx);
@@ -150,6 +151,7 @@ extern void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh,
 			      struct kern_ipc_perm *perm);
 extern int cr_load_ipc_perms(struct cr_hdr_ipc_perms *hh,
 			     struct kern_ipc_perm *perm);
+extern int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns);
 #endif
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3a2c4af..b93b2fc 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -175,6 +175,8 @@ enum cr_vma_type {
 	CR_VMA_FILE,		/* private mapped file */
 	CR_VMA_SHM_ANON,	/* shared anonymous */
 	CR_VMA_SHM_ANON_SKIP,	/* shared anonymous, skip contents */
+	CR_VMA_SHM_IPC,		/* shared sysvipc */
+	CR_VMA_SHM_IPC_SKIP,	/* shared sysvipc, skip contents */
 	CR_VMA_SHM_FILE,	/* shared mapped file, only msync */
 	CR_VMA_SHM_FILE_SKIP,	/* shared mapped file, skip msync */
 	CR_VMA_UNKNOWN,		/* unkown (unsupported) vma type */
@@ -254,4 +256,17 @@ struct cr_hdr_ipc_perms {
 	__u64 seq;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_ipc_shm {
+	struct cr_hdr_ipc_perms perms;
+	__u64 shm_segsz;
+	__u64 shm_atim;
+	__u64 shm_dtim;
+	__u64 shm_ctim;
+	__s32 shm_cprid;
+	__s32 shm_lprid;
+	__u32 mlock_uid;
+	__u32 flags;
+	__u32 objref;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index 65c3843..0789ec8 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -8,4 +8,5 @@ obj-$(CONFIG_SYSVIPC_SYSCTL) += ipc_sysctl.o
 obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
+obj-$(CONFIG_CHECKPOINT) += ckpt_shm.o
 
diff --git a/ipc/ckpt_shm.c b/ipc/ckpt_shm.c
new file mode 100644
index 0000000..a473cc3
--- /dev/null
+++ b/ipc/ckpt_shm.c
@@ -0,0 +1,142 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc shm
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/mm.h>
+#include <linux/shm.h>
+#include <linux/shmem_fs.h>
+#include <linux/hugetlb.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int cr_fill_ipc_shm_hdr(struct cr_ctx *ctx,
+			       struct cr_hdr_ipc_shm *hh,
+			       struct shmid_kernel *shp)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&shp->shm_perm);
+
+	cr_fill_ipc_perms(&hh->perms, &shp->shm_perm);
+
+	hh->shm_segsz = shp->shm_segsz;
+	hh->shm_atim = shp->shm_atim;
+	hh->shm_dtim = shp->shm_dtim;
+	hh->shm_ctim = shp->shm_ctim;
+	hh->shm_cprid = shp->shm_cprid;
+	hh->shm_lprid = shp->shm_lprid;
+
+	if (shp->mlock_user)
+		hh->mlock_uid = shp->mlock_user->uid;
+	else
+		hh->mlock_uid = (unsigned int) -1;
+
+	hh->flags = 0;
+	/* check if shm was setup with SHM_NORESERVE */
+	if (SHMEM_I(shp->shm_file->f_dentry->d_inode)->flags & VM_NORESERVE)
+		hh->flags |= SHM_NORESERVE;
+	/* check if shm was setup with SHM_HUGETLB (unsupported yet) */
+	if (is_file_hugepages(shp->shm_file)) {
+		pr_warning("c/r: unsupported SHM_HUGETLB\n");
+		ret = -ENOSYS;
+	}
+
+	ipc_unlock(&shp->shm_perm);
+	cr_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+		 hh->shm_cprid, hh->shm_lprid, hh->shm_segsz, hh->mlock_uid);
+
+	return ret;
+}
+
+static int cr_do_write_ipc_shm(int id, void *p, void *data)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipc_shm *hh;
+	struct cr_ctx *ctx = (struct cr_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct shmid_kernel *shp;
+	struct inode *inode;
+	int ret;
+
+	shp = container_of(perm, struct shmid_kernel, shm_perm);
+	inode = shp->shm_file->f_dentry->d_inode;
+
+	h.type = CR_HDR_IPC_SHM;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_fill_ipc_shm_hdr(ctx, hh, shp);
+	if (ret < 0)
+		goto out;
+
+	ret = cr_obj_add_ptr(ctx, inode, &hh->objref, CR_OBJ_INODE, 0);
+	if (ret < 0)
+		goto out;
+	BUG_ON(ret != 1);	/* must be first time always */
+
+	cr_debug("shm: objref %d\n", hh->objref);
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	ret = cr_write_shmem_contents(ctx, inode);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipc *hh;
+	struct ipc_ids *shm_ids = &ipcns->ids[IPC_SHM_IDS];
+	int ret = -ENOMEM;
+
+	down_read(&shm_ids->rw_mutex);
+
+	h.type = CR_HDR_IPC;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		goto out;
+
+	hh->ipc_type = CR_HDR_IPC_SHM;
+	hh->ipc_count = shm_ids->in_use;
+	cr_debug("shm: count %d\n", hh->ipc_count);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto out;
+
+	ret = idr_for_each(&shm_ids->ipcs_idr, cr_do_write_ipc_shm, ctx);
+	cr_debug("shm: ret %d\n", ret);
+
+ out:
+	up_read(&shm_ids->rw_mutex);
+	return ret;
+}
diff --git a/ipc/shm.c b/ipc/shm.c
index 4135f28..5ac6aec 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -39,6 +39,7 @@
 #include <linux/nsproxy.h>
 #include <linux/mount.h>
 #include <linux/ipc_namespace.h>
+#include <linux/checkpoint_hdr.h>
 
 #include <asm/uaccess.h>
 
@@ -244,6 +245,13 @@ static struct mempolicy *shm_get_policy(struct vm_area_struct *vma,
 }
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+static int shm_cr_vma_type(struct vm_area_struct *vma)
+{
+	return CR_VMA_SHM_IPC;
+}
+#endif
+
 static int shm_mmap(struct file * file, struct vm_area_struct * vma)
 {
 	struct shm_file_data *sfd = shm_file_data(file);
@@ -319,6 +327,9 @@ static struct vm_operations_struct shm_vm_ops = {
 	.set_policy = shm_set_policy,
 	.get_policy = shm_get_policy,
 #endif
+#if defined(CONFIG_CHECKPOINT)
+	.cr_vma_type = shm_cr_vma_type,
+#endif
 };
 
 /**
-- 
1.5.4.3
