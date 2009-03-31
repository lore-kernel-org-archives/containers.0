From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 4/7] sysvipc-shm: restart
Date: Tue, 31 Mar 2009 01:32:29 -0400
Message-ID: <1238477552-17083-5-git-send-email-orenl@cs.columbia.edu>
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
 checkpoint/rstr_mem.c      |   23 ++++++
 checkpoint/util_ipc.c      |    2 +-
 include/linux/checkpoint.h |    3 +
 ipc/ckpt_shm.c             |  167 +++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 193 insertions(+), 2 deletions(-)

diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index 414d6a9..a70f02a 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -342,6 +342,24 @@ static struct file *cr_vma_prep_file(struct cr_ctx *ctx, struct cr_hdr_vma *hh)
 		if (!IS_ERR(file))
 			get_file(file);
 		break;
+#ifdef CONFIG_SYSVIPC
+	case CR_VMA_SHM_IPC_SKIP:	/* shared sysvipc mapping skipped */
+		if (!hh->shm_objref || hh->vma_objref)
+			break;
+		file = cr_obj_get_by_ref(ctx, hh->shm_objref, CR_OBJ_FILE);
+		if (!file)
+			file = ERR_PTR(-EINVAL);
+		if (!IS_ERR(file)) {
+			ret = cr_ipc_shm_attach(file,
+						hh->vm_start,
+						hh->vm_flags);
+			if (ret < 0)
+				file = ERR_PTR(ret);
+		}
+		if (!IS_ERR(file))
+			get_file(file);
+		break;
+#endif
 	case CR_VMA_SHM_FILE:		/* shared mapping of a file */
 		if (!hh->shm_objref || !hh->vma_objref)
 			break;
@@ -429,6 +447,10 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 		goto out;
 	}
 
+	/* yuck: sysvipc shm are already mapped, so skip this */
+	if (vma_type == CR_VMA_SHM_IPC_SKIP)
+		goto contents;
+
 	/* create a new vma */
 	down_write(&mm->mmap_sem);
 	addr = do_mmap_pgoff(file, vm_start, vm_size,
@@ -442,6 +464,7 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 		goto out;
 	}
 
+ contents:
 	/* read in the contents of this vma */
 	if (shm)
 		ret = cr_read_shared_vma_contents(ctx, file, vma_type);
diff --git a/checkpoint/util_ipc.c b/checkpoint/util_ipc.c
index a648579..adbb639 100644
--- a/checkpoint/util_ipc.c
+++ b/checkpoint/util_ipc.c
@@ -20,7 +20,7 @@ int cr_write_ipc(struct cr_ctx *ctx, struct nsproxy *nsproxy)
 
 int cr_read_ipc(struct cr_ctx *ctx)
 {
-	return 0;
+	return cr_read_ipc_shm(ctx);
 }
 
 void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh, struct kern_ipc_perm *perm)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8637537..c556511 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -130,6 +130,9 @@ extern void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh,
 extern int cr_load_ipc_perms(struct cr_hdr_ipc_perms *hh,
 			     struct kern_ipc_perm *perm);
 extern int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns);
+extern int cr_read_ipc_shm(struct cr_ctx *ctx);
+extern int cr_ipc_shm_attach(struct file *file,
+			     unsigned long addr, unsigned long flags);
 #endif
 
 
diff --git a/ipc/ckpt_shm.c b/ipc/ckpt_shm.c
index 6a9382a..ee9b77a 100644
--- a/ipc/ckpt_shm.c
+++ b/ipc/ckpt_shm.c
@@ -14,6 +14,7 @@
 #include <linux/hugetlb.h>
 #include <linux/rwsem.h>
 #include <linux/sched.h>
+#include <linux/file.h>
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
@@ -45,7 +46,10 @@ static int cr_fill_ipc_shm_hdr(struct cr_ctx *ctx,
 	hh->shm_cprid = shp->shm_cprid;
 	hh->shm_lprid = shp->shm_lprid;
 
-	hh->mlock_uid = (shp->mlock_user ? shp->mlock_user->uid : UINT_MAX);
+	if (shp->mlock_user)
+		hh->mlock_uid = shp->mlock_user->uid;
+	else
+		hh->mlock_uid = (unsigned int) -1;
 
 	hh->flags = 0;
 	/* check if shm was setup with SHM_NORESERVE */
@@ -136,3 +140,164 @@ int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
 	up_read(&shm_ids->rw_mutex);
 	return ret;
 }
+
+/************************************************************************
+ * ipc restart
+ */
+
+int cr_ipc_shm_attach(struct file *file,
+		      unsigned long vm_addr,
+		      unsigned long vm_flags)
+{
+	mm_segment_t old_fs;
+	unsigned long addr;
+	int shmid, shmflg = 0;
+	int ret;
+
+	shmid = file->f_dentry->d_inode->i_ino;
+
+	if (!(vm_flags & VM_WRITE))
+		shmflg |= SHM_RDONLY;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	ret = do_shmat(shmid, (char __user *) vm_addr, shmflg, &addr);
+	set_fs(old_fs);
+
+	BUG_ON(ret >= 0 && addr != vm_addr);
+	return ret;
+}
+
+static int cr_load_ipc_shm_hdr(struct cr_ctx *ctx,
+			       struct cr_hdr_ipc_shm *hh,
+			       struct shmid_kernel *shp)
+{
+	int ret;
+
+	ret = cr_load_ipc_perms(&hh->perms, &shp->shm_perm);
+	if (ret < 0)
+		return ret;
+
+	cr_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
+		 hh->shm_cprid, hh->shm_lprid, hh->shm_segsz, hh->mlock_uid);
+
+	if (hh->shm_cprid < 0 || hh->shm_lprid < 0)
+		return -EINVAL;
+
+	shp->shm_segsz = hh->shm_segsz;
+	shp->shm_atim = hh->shm_atim;
+	shp->shm_dtim = hh->shm_dtim;
+	shp->shm_ctim = hh->shm_ctim;
+	shp->shm_cprid = hh->shm_cprid;
+	shp->shm_lprid = hh->shm_lprid;
+
+	return 0;
+}
+
+static int cr_do_read_ipc_shm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_ipc_shm *hh;
+	struct kern_ipc_perm *perms;
+	struct shmid_kernel *shp;
+	struct ipc_ids *shm_ids = &current->nsproxy->ipc_ns->ids[IPC_SHM_IDS];
+	struct file *file;
+	int shmflag;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_IPC_SHM);
+	if (ret < 0)
+		goto out;
+	ret = -EINVAL;
+	if (hh->perms.id < 0)
+		goto out;
+
+#define CR_SHMFL_MASK  (SHM_NORESERVE | SHM_HUGETLB)
+	if (hh->flags & ~CR_SHMFL_MASK)
+		goto out;
+
+	ret = -ENOSYS;
+	if (hh->mlock_uid != (unsigned int) -1)	/* FIXME: support SHM_LOCK */
+		goto out;
+	if (hh->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
+		goto out;
+
+	/* FIXME: this will fail for deleted ipc shm segments */
+
+	shmflag = hh->flags | hh->perms.mode | IPC_CREAT | IPC_EXCL;
+	cr_debug("shm: do_shmget size %lld flag %#x id %d\n",
+		 hh->shm_segsz, shmflag, hh->perms.id);
+	ret = do_shmget(hh->perms.key, hh->shm_segsz, shmflag, hh->perms.id);
+	cr_debug("shm: do_shmget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&shm_ids->rw_mutex);
+
+	ret = -EIDRM;
+	perms = ipc_lock(shm_ids, hh->perms.id);
+	if (IS_ERR(perms)) {	/* this should not happen .. but be safe */
+		up_write(&shm_ids->rw_mutex);
+		ret = PTR_ERR(perms);
+		goto out;
+	}
+
+	shp = container_of(perms, struct shmid_kernel, shm_perm);
+	ret = cr_load_ipc_shm_hdr(ctx, hh, shp);
+	if (ret < 0) {
+		cr_debug("shm: need to remove (%d)\n", ret);
+		do_shm_rmid(current->nsproxy->ipc_ns, perms);
+		up_write(&shm_ids->rw_mutex);
+		goto out;
+	}
+
+	file = shp->shm_file;
+	get_file(file);
+	ipc_unlock(perms);
+	up_write(&shm_ids->rw_mutex);
+
+	/* deposit in objhash and read contents in */
+	ret = cr_obj_add_ref(ctx, file, hh->objref, CR_OBJ_FILE, 0);
+	if (ret < 0)
+		goto file;
+	ret = cr_read_shmem_contents(ctx, file->f_dentry->d_inode);
+ file:
+	fput(file);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_read_ipc_shm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_ipc *hh;
+	int n, ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_IPC);
+	if (ret < 0)
+		goto out;
+
+	cr_debug("shm: count %d\n", hh->ipc_count);
+
+	ret = -EINVAL;
+	if (hh->ipc_type != CR_HDR_IPC_SHM)
+		goto out;
+
+	ret = 0;
+	for (n = 0; n < hh->ipc_count; n++) {
+		ret = cr_do_read_ipc_shm(ctx);
+		if (ret < 0)
+			goto out;
+	}
+
+ out:
+	cr_debug("shm: ret %d\n", ret);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
-- 
1.5.4.3
