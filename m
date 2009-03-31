From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 3/7] sysvipc-shm: checkpoint
Date: Tue, 31 Mar 2009 01:32:28 -0400
Message-ID: <1238477552-17083-4-git-send-email-orenl@cs.columbia.edu>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477552-17083-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
 checkpoint/ckpt_mem.c          |    9 +++
 checkpoint/util_ipc.c          |    3 +-
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |   15 ++++
 ipc/Makefile                   |    1 +
 ipc/ckpt_shm.c                 |  138 ++++++++++++++++++++++++++++++++++++++++
 ipc/shm.c                      |   11 +++
 7 files changed, 176 insertions(+), 2 deletions(-)
 create mode 100644 ipc/ckpt_shm.c

diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 9315d1b..41c0bdd 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -558,7 +558,16 @@ static int cr_write_shared_vma_contents(struct cr_ctx *ctx,
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
diff --git a/checkpoint/util_ipc.c b/checkpoint/util_ipc.c
index 70c4b18..a648579 100644
--- a/checkpoint/util_ipc.c
+++ b/checkpoint/util_ipc.c
@@ -10,13 +10,12 @@
 
 #ifdef CONFIG_SYSVIPC
 
-#include <linux/version.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
 int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy)
 {
-	return 0;
+	return cr_write_ipc_shm(ctx, nsproxy->ipc_ns);
 }
 
 int cr_read_ipc(struct cr_ctx *ctx)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 15a9890..8637537 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -129,6 +129,7 @@ extern void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh,
 			      struct kern_ipc_perm *perm);
 extern int cr_load_ipc_perms(struct cr_hdr_ipc_perms *hh,
 			     struct kern_ipc_perm *perm);
+extern int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns);
 #endif
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 6efe8dd..ceb462e 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -138,6 +138,8 @@ enum cr_vma_type {
 	CR_VMA_FILE,		/* private mapped file */
 	CR_VMA_SHM_ANON,	/* shared anonymous */
 	CR_VMA_SHM_ANON_SKIP,	/* shared anonymous, skip contents */
+	CR_VMA_SHM_IPC,		/* shared sysvipc */
+	CR_VMA_SHM_IPC_SKIP,	/* shared sysvipc, skip contents */
 	CR_VMA_SHM_FILE,	/* shared mapped file, only msync */
 	CR_VMA_SHM_FILE_SKIP,	/* shared mapped file, skip msync */
 };
@@ -216,4 +218,17 @@ struct cr_hdr_ipc_perms {
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
index 0000000..6a9382a
--- /dev/null
+++ b/ipc/ckpt_shm.c
@@ -0,0 +1,138 @@
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
+	hh->mlock_uid = (shp->mlock_user ? shp->mlock_user->uid : UINT_MAX);
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
