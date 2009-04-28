From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 44/54] sysvipc-shm: restart
Date: Tue, 28 Apr 2009 19:24:14 -0400
Message-ID: <1240961064-13991-45-git-send-email-orenl@cs.columbia.edu>
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

Like chekcpoint, restart of sysvipc shared memory is also performed in
two steps: first, the entire ipc namespace is restored as a whole, by
restoring each shm object read from the checkpoint image. The shmem's
file pointer is registered in the objhash. Second, for each vma that
refers to ipc shared memory, we use the objref to find the file in the
objhash, and use that file in calling do_mmap_pgoff().

Handling of shm objects that have been deleted (via IPC_RMID) is left
to a later patch in this series.

Handling of ipc shm mappings that are locked (via SHM_MLOCK) is also
not restored at the moment.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/memory.c  |   22 +++++++++++
 include/linux/shm.h  |    9 ++++
 ipc/checkpoint.c     |    2 +-
 ipc/checkpoint_shm.c |  100 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ipc/shm.c            |   46 +++++++++++++++++++++++
 ipc/util.h           |    1 +
 6 files changed, 179 insertions(+), 1 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index ee26254..7637c1e 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -20,6 +20,7 @@
 #include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
+#include <linux/shm.h>
 #include <linux/proc_fs.h>
 #include <linux/swap.h>
 #include <linux/checkpoint.h>
@@ -1016,6 +1017,13 @@ static int anon_private_restore(struct ckpt_ctx *ctx,
 	return private_vma_restore(ctx, mm, NULL, h);
 }
 
+static int bad_vma_restore(struct ckpt_ctx *ctx,
+			   struct mm_struct *mm,
+			   struct ckpt_hdr_vma *h)
+{
+	return -EINVAL;
+}
+
 /* callbacks to restore vma per its type: */
 struct restore_vma_ops {
 	char *vma_name;
@@ -1068,6 +1076,20 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_SHM_FILE,
 		.restore = filemap_restore,
 	},
+	/* sysvipc shared */
+	{
+		.vma_name = "IPC SHARED",
+		.vma_type = CKPT_VMA_SHM_IPC,
+		/* ipc inode itself is restore by restore_ipc_ns()... */
+		.restore = bad_vma_restore,
+
+	},
+	/* sysvipc shared (skip) */
+	{
+		.vma_name = "IPC SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_IPC_SKIP,
+		.restore = ipcshm_restore,
+	},
 };
 
 /**
diff --git a/include/linux/shm.h b/include/linux/shm.h
index eca6235..1122197 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -118,6 +118,15 @@ static inline int is_file_shm_hugepages(struct file *file)
 }
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_SYSVIPC
+extern int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			  struct ckpt_hdr_vma *h);
+#else
+define ipcshm_restart NULL
+#endif
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SHM_H_ */
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 127eb63..f951c1e 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -209,9 +209,9 @@ static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
 	ipc_ns->sem_ctls[2] = h->sem_ctl_opm;
 	ipc_ns->sem_ctls[3] = h->sem_ctl_mni;
 
-#if 0 /* NEXT FEW PATCHES */
 	ret = restore_ipc_any(ctx, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = ckpt_read_ipc_any(ctx, IPC_MSG_IDS,
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 16d8c9d..9e0d028 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -110,3 +110,103 @@ int checkpoint_ipc_shm(int id, void *p, void *data)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+
+/************************************************************************
+ * ipc restart
+ */
+
+static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_shm *h,
+			    struct shmid_kernel *shp)
+{
+	int ret;
+
+	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
+
+	if (h->shm_cprid < 0 || h->shm_lprid < 0)
+		return -EINVAL;
+
+	shp->shm_segsz = h->shm_segsz;
+	shp->shm_atim = h->shm_atim;
+	shp->shm_dtim = h->shm_dtim;
+	shp->shm_ctim = h->shm_ctim;
+	shp->shm_cprid = h->shm_cprid;
+	shp->shm_lprid = h->shm_lprid;
+
+	return 0;
+}
+
+int restore_ipc_shm(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ipc_shm *h;
+	struct kern_ipc_perm *perms;
+	struct shmid_kernel *shp;
+	struct ipc_ids *shm_ids = &current->nsproxy->ipc_ns->ids[IPC_SHM_IDS];
+	struct file *file;
+	int shmflag;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SHM);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+
+#define CKPT_SHMFL_MASK  (SHM_NORESERVE | SHM_HUGETLB)
+	if (h->flags & ~CKPT_SHMFL_MASK)
+		goto out;
+
+	ret = -ENOSYS;
+	if (h->mlock_uid != (unsigned int) -1)	/* FIXME: support SHM_LOCK */
+		goto out;
+	if (h->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
+		goto out;
+
+	/* FIXME: this will fail for deleted ipc shm segments */
+
+	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
+		 h->shm_segsz, shmflag, h->perms.id);
+	ret = do_shmget(h->perms.key, h->shm_segsz, shmflag, h->perms.id);
+	ckpt_debug("shm: do_shmget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&shm_ids->rw_mutex);
+
+	/* we are the sole owners/users of this ipc_ns, it can't go away */
+	perms = ipc_lock(shm_ids, h->perms.id);
+	BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
+
+	shp = container_of(perms, struct shmid_kernel, shm_perm);
+	file = shp->shm_file;
+	get_file(file);
+
+	ret = load_ipc_shm_hdr(ctx, h, shp);
+	ipc_unlock(perms);
+	if (ret < 0)
+		goto mutex;
+
+	/* deposit in objhash and read contents in */
+	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
+	if (ret < 0)
+		goto mutex;
+	ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
+ mutex:
+	fput(file);
+	if (ret < 0) {
+		ckpt_debug("shm: need to remove (%d)\n", ret);
+		do_shm_rmid(current->nsproxy->ipc_ns, perms);
+	}
+	up_write(&shm_ids->rw_mutex);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/shm.c b/ipc/shm.c
index c521e95..5625dbf 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -329,6 +329,52 @@ static int ipcshm_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_SHM_IPC_SKIP,
 				      0, ino_objref);
 }
+
+int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+		   struct ckpt_hdr_vma *h)
+{
+	struct file *file;
+	int shmid, shmflg = 0;
+	mm_segment_t old_fs;
+	unsigned long start;
+	unsigned long addr;
+	int ret;
+
+	if (!h->ino_objref)
+		return -EINVAL;
+	/* FIX: verify the vm_flags too */
+
+	file = ckpt_obj_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
+	if (!file)
+		return -EINVAL;
+	else if (IS_ERR(file))
+		PTR_ERR(file);
+
+	shmid = file->f_dentry->d_inode->i_ino;
+
+	if (!(h->vm_flags & VM_WRITE))
+		shmflg |= SHM_RDONLY;
+
+	/*
+	 * FIX: do_shmat() has limited interface: all-or-nothing
+	 * mapping. If the vma, however, reflects a partial mapping
+	 * then we need to modify that function to accomplish the
+	 * desired outcome.  Partial mapping can exist due to the user
+	 * call shmat() and then unmapping part of the region.
+	 * Currently, we at least detect this and call it a foul play.
+	 */
+	if (((h->vm_end - h->vm_start) != h->ino_size) || h->vm_pgoff)
+		return -ENOSYS;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	start = h->vm_start;
+	ret = do_shmat(shmid, (char __user *) start, shmflg, &addr);
+	set_fs(old_fs);
+
+	BUG_ON(ret >= 0 && addr != h->vm_start);
+	return ret;
+}
 #else
 define ipcshm_checkpoint NULL
 #endif
diff --git a/ipc/util.h b/ipc/util.h
index e4799cb..be2fb94 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -185,6 +185,7 @@ extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *hh,
 				  struct kern_ipc_perm *perm);
 
 extern int checkpoint_ipc_shm(int id, void *p, void *data);
+extern int restore_ipc_shm(struct ckpt_ctx *ctx);
 #endif
 
 #endif
-- 
1.5.4.3
