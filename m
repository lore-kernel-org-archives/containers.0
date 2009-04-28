From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 43/54] sysvipc-shm: checkpoint
Date: Tue, 28 Apr 2009 19:24:13 -0400
Message-ID: <1240961064-13991-44-git-send-email-orenl@cs.columbia.edu>
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
 checkpoint/memory.c            |    6 +-
 include/linux/checkpoint.h     |    3 +
 include/linux/checkpoint_hdr.h |   17 ++++++
 ipc/Makefile                   |    2 +-
 ipc/checkpoint.c               |    2 +-
 ipc/checkpoint_shm.c           |  112 ++++++++++++++++++++++++++++++++++++++++
 ipc/shm.c                      |   29 ++++++++++
 ipc/util.h                     |    3 +-
 8 files changed, 168 insertions(+), 6 deletions(-)
 create mode 100644 ipc/checkpoint_shm.c

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 7a6e3f4..ee26254 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -457,9 +457,9 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
  * virtual addresses into ctx->pgarr_list page-array chain. Then dump
  * the addresses, followed by the page contents.
  */
-static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
-				      struct vm_area_struct *vma,
-				      struct inode *inode)
+int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+			       struct vm_area_struct *vma,
+			       struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long addr, end;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index f915564..65838b4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -112,6 +112,9 @@ extern unsigned long generic_vma_restore(struct mm_struct *mm,
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
 
+extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma,
+				      struct inode *inode);
 extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 
 extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2ad3cb7..12a808c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -213,6 +213,8 @@ enum vma_type {
 	CKPT_VMA_SHM_ANON,	/* shared anonymous */
 	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
 	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
+	CKPT_VMA_SHM_IPC,	/* shared sysvipc */
+	CKPT_VMA_SHM_IPC_SKIP,	/* shared sysvipc (skip contents) */
 	CKPT_VMA_MAX,
 };
 
@@ -308,6 +310,7 @@ struct ckpt_hdr_ipc {
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_perms {
+	struct ckpt_hdr h;
 	__s32 id;
 	__u32 key;
 	__u32 uid;
@@ -319,6 +322,20 @@ struct ckpt_hdr_ipc_perms {
 	__u64 seq;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_shm {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
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
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/ipc/Makefile b/ipc/Makefile
index aa6c8dd..7e23683 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,5 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index e00e524..127eb63 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -97,9 +97,9 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
 	if (ret < 0)
 		return ret;
 
-#if 0 /* NEXT FEW PATCHES */
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
 				 CKPT_HDR_IPC_SHM, checkpoint_ipc_shm);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
new file mode 100644
index 0000000..16d8c9d
--- /dev/null
+++ b/ipc/checkpoint_shm.c
@@ -0,0 +1,112 @@
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
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
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
+static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_shm *h,
+			    struct shmid_kernel *shp)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&shp->shm_perm);
+
+	checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
+
+	h->shm_segsz = shp->shm_segsz;
+	h->shm_atim = shp->shm_atim;
+	h->shm_dtim = shp->shm_dtim;
+	h->shm_ctim = shp->shm_ctim;
+	h->shm_cprid = shp->shm_cprid;
+	h->shm_lprid = shp->shm_lprid;
+
+	if (shp->mlock_user)
+		h->mlock_uid = shp->mlock_user->uid;
+	else
+		h->mlock_uid = (unsigned int) -1;
+
+	h->flags = 0;
+	/* check if shm was setup with SHM_NORESERVE */
+	if (SHMEM_I(shp->shm_file->f_dentry->d_inode)->flags & VM_NORESERVE)
+		h->flags |= SHM_NORESERVE;
+	/* check if shm was setup with SHM_HUGETLB (unsupported yet) */
+	if (is_file_hugepages(shp->shm_file)) {
+		pr_warning("c/r: unsupported SHM_HUGETLB\n");
+		ret = -ENOSYS;
+	}
+
+	ipc_unlock(&shp->shm_perm);
+	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
+
+	return ret;
+}
+
+int checkpoint_ipc_shm(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_shm *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct shmid_kernel *shp;
+	struct inode *inode;
+	int first, objref;
+	int ret;
+
+	shp = container_of(perm, struct shmid_kernel, shm_perm);
+	inode = shp->shm_file->f_dentry->d_inode;
+
+	objref = ckpt_obj_lookup_add(ctx, inode, CKPT_OBJ_INODE, &first);
+	if (objref < 0)
+		return objref;
+	/* this must be the first time we see this region */
+	BUG_ON(!first);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_SHM);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_shm_hdr(ctx, h, shp);
+	if (ret < 0)
+		goto out;
+
+	h->objref = objref;
+	ckpt_debug("shm: objref %d\n", h->objref);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_memory_contents(ctx, NULL, inode);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/shm.c b/ipc/shm.c
index 7dd5f0c..c521e95 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -40,6 +40,8 @@
 #include <linux/mount.h>
 #include <linux/ipc_namespace.h>
 #include <linux/ima.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 
@@ -305,6 +307,32 @@ int is_file_shm_hugepages(struct file *file)
 	return ret;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int ipcshm_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	int ino_objref;
+	int first;
+
+	ino_objref = ckpt_obj_lookup_add(ctx, vma->vm_file->f_dentry->d_inode,
+				       CKPT_OBJ_INODE, &first);
+	if (ino_objref < 0)
+		return ino_objref;
+
+	/*
+	 * This shouldn't happen, because all IPC regions should have
+	 * been already dumped by now via ipc namespaces; It means
+	 * the ipc_ns has been modified recently during checkpoint.
+	 */
+	if (first)
+		return -EBUSY;
+
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_SHM_IPC_SKIP,
+				      0, ino_objref);
+}
+#else
+define ipcshm_checkpoint NULL
+#endif
+
 static const struct file_operations shm_file_operations = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
@@ -320,6 +348,7 @@ static struct vm_operations_struct shm_vm_ops = {
 	.set_policy = shm_set_policy,
 	.get_policy = shm_get_policy,
 #endif
+	.checkpoint = ipcshm_checkpoint,
 };
 
 /**
diff --git a/ipc/util.h b/ipc/util.h
index d3f7367..e4799cb 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -183,7 +183,8 @@ extern void checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *hh,
 				      struct kern_ipc_perm *perm);
 extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *hh,
 				  struct kern_ipc_perm *perm);
-#endif
 
+extern int checkpoint_ipc_shm(int id, void *p, void *data);
+#endif
 
 #endif
-- 
1.5.4.3
