From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 4/4] c/r: support checkpoint/restart of SysV SHM_HUGETLB
	regions
Date: Mon, 10 Jan 2011 21:11:29 -0500
Message-ID: <1294711889-30343-5-git-send-email-orenl@cs.columbia.edu>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
List-Id: containers.vger.kernel.org

Large page-backed shm regions require special handling, especially
during restart.  The association of a large page with a shm region's
inode can occur only in the context of a process causing a fault with
the region mapped into its mm.  In order to restore that association,
temporarily shmat-attach the restored SHM_HUGETLB region to the
restarting process's mm, using the just-restored ipc namespace
instead of the current one (the nsproxy switch hasn't occured yet).

Since the temporary shmat of the region during restart causes some of
the shm attributes to be updated, re-restore them from the ipc_shm
checkpoint header after unmapping.

Original patch by Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>.

Changelog[v23-rc1]:
  - Mofidied to reuse existing code in mm/checkpoint.c (specifically
  checkpoint_memory_contents() and restore_memory_contents()

Cc: Nathan Lynch <<ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/hugetlbfs/inode.c           |   23 ++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |    3 +++
 include/linux/hugetlb.h        |    7 +++++++
 ipc/checkpoint_shm.c           |   39 +++++++++++++++++++++++++++++----------
 mm/checkpoint.c                |   13 ++++++++-----
 mm/hugetlb.c                   |   32 +++++++++++++++++++++++++++++++-
 6 files changed, 100 insertions(+), 17 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a5fe681..89e8cae 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -32,6 +32,7 @@
 #include <linux/security.h>
 #include <linux/magic.h>
 #include <linux/migrate.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 
@@ -448,6 +449,23 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+static const struct file_operations hugetlbfs_dir_operations = {
+	/* Just like simple_dir_operations except... */
+	.open		= dcache_dir_open,
+	.release	= dcache_dir_close,
+	.llseek		= dcache_dir_lseek,
+	.read		= generic_read_dir,
+	.readdir	= dcache_readdir,
+	.fsync		= noop_fsync,
+
+	/* The checkpoint ops are unlike simple_dir_operations */
+	.checkpoint	= generic_file_checkpoint,
+};
+#else
+#define hugetlbfs_dir_operations simple_dir_operations
+#endif
+
 static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid, 
 					gid_t gid, int mode, dev_t dev)
 {
@@ -483,7 +501,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb, uid_t uid,
 			break;
 		case S_IFDIR:
 			inode->i_op = &hugetlbfs_dir_inode_operations;
-			inode->i_fop = &simple_dir_operations;
+			inode->i_fop = &hugetlbfs_dir_operations;
 
 			/* directory inodes start off with i_nlink == 2 (for "." entry) */
 			inc_nlink(inode);
@@ -691,6 +709,9 @@ const struct file_operations hugetlbfs_file_operations = {
 	.fsync			= noop_fsync,
 	.get_unmapped_area	= hugetlb_get_unmapped_area,
 	.llseek		= default_llseek,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 static const struct inode_operations hugetlbfs_dir_inode_operations = {
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b7a7406..ef14a67 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -944,6 +944,8 @@ struct ckpt_hdr_vma {
 	__u64 vm_page_prot;
 	__u64 vm_flags;
 	__u64 vm_pgoff;
+
+	__u16 hugetlb_shift;
 } __attribute__((aligned(8)));
 
 /* page array */
@@ -1091,6 +1093,7 @@ struct ckpt_hdr_ipc_shm {
 	__u32 mlock_uid;
 	__u32 flags;
 	__u32 objref;
+	__u16 shift;  /* hugetlb */
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_msg {
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index a0aabe1..7cddb0d 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -48,6 +48,8 @@ int checkpoint_dump_hugetlb(struct ckpt_ctx *ctx, struct page *page);
 int restore_read_hugetlb(struct ckpt_ctx *ctx, struct page *page);
 struct page *consider_hugetlb_private_page(struct vm_area_struct *vma,
 					   unsigned long addr);
+struct page *consider_hugetlb_shared_page(struct file *file,
+					  unsigned long idx);
 #endif
 
 int dequeue_hwpoisoned_huge_page(struct page *page);
@@ -135,6 +137,11 @@ static inline struct page *consider_hugetlb_private_page(struct vm_area_struct *
 {
 	return ERR_PTR(-ENOSYS);
 }
+static inline struct page *consider_hugetlb_shared_page(struct file *file,
+							unsigned long idx)
+{
+	return ERR_PTR(-ENOSYS);
+}
 #endif
 
 #endif /* !CONFIG_HUGETLB_PAGE */
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 05ba5cf..a0b18be 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -61,8 +61,8 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 
 	/* check if shm was setup with SHM_HUGETLB (unsupported yet) */
 	if (is_file_hugepages(shp->shm_file)) {
-		pr_warning("c/r: unsupported SHM_HUGETLB\n");
-		ret = -ENOSYS;
+		h->flags |= SHM_HUGETLB;
+		h->shift = huge_page_shift(hstate_file(shp->shm_file));
 	} else {
 		struct shmem_inode_info *info;
 
@@ -173,6 +173,15 @@ static int ipc_shm_delete(void *data)
 	return ret;
 }
 
+static void __load_ipc_shm_hdr(const struct ckpt_hdr_ipc_shm *h, struct shmid_kernel *shp)
+{
+	shp->shm_atim = h->shm_atim;
+	shp->shm_dtim = h->shm_dtim;
+	shp->shm_ctim = h->shm_ctim;
+	shp->shm_cprid = h->shm_cprid;
+	shp->shm_lprid = h->shm_lprid;
+}
+
 /* called with the msgids->rw_mutex is write-held */
 static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_shm *h,
@@ -190,11 +199,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 	if (h->shm_cprid < 0 || h->shm_lprid < 0)
 		return -EINVAL;
 
-	shp->shm_atim = h->shm_atim;
-	shp->shm_dtim = h->shm_dtim;
-	shp->shm_ctim = h->shm_ctim;
-	shp->shm_cprid = h->shm_cprid;
-	shp->shm_lprid = h->shm_lprid;
+	__load_ipc_shm_hdr(h, shp);
 
 	return 0;
 }
@@ -206,6 +211,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	struct shmid_kernel *shp;
 	struct ipc_ids *shm_ids = &ns->ids[IPC_SHM_IDS];
 	struct file *file;
+	unsigned long addr;
 	int shmflag;
 	int ret;
 
@@ -217,15 +223,13 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	if (h->perms.id < 0)
 		goto out;
 
-#define CKPT_SHMFL_MASK  (SHM_NORESERVE | SHM_HUGETLB)
+#define CKPT_SHMFL_MASK  (SHM_NORESERVE)
 	if (h->flags & ~CKPT_SHMFL_MASK)
 		goto out;
 
 	ret = -ENOSYS;
 	if (h->mlock_uid != (unsigned int) -1)	/* FIXME: support SHM_LOCK */
 		goto out;
-	if (h->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
-		goto out;
 
 	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
 	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
@@ -294,7 +298,22 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
 	if (ret < 0)
 		goto fput;
+
+	if (is_file_hugepages(file)) {
+		ret = do_shmat_ns_pgoff(ns, shp->shm_perm.id,
+					(char __user *) 0, 0, &addr, 0, 0);
+		if (ret < 0)
+			goto fput;
+		ckpt_debug("temporarily using %#lx for huge shm\n", addr);
+	}
+
 	ret = restore_memory_contents(ctx, file, 0);
+
+	if (is_file_hugepages(file)) {
+		sys_shmdt((void __user *) addr);
+		__load_ipc_shm_hdr(h, shp);
+	}
+
 fput:
 	fput(file);
 
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index 1c50f62..ac61b2a 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -327,7 +327,7 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 			else if (!huge)    /* !vma && !huge */
 				page = consider_shared_page(file, addr);
 			else               /* !vma && huge */
-				page = ERR_PTR(-EINVAL);
+				page = consider_hugetlb_shared_page(file, addr);
 
 			if (IS_ERR(page)) {
 				cnt = PTR_ERR(page);
@@ -444,10 +444,10 @@ int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 		end = vma->vm_end;
 		addr = vma->vm_start;
 	} else {
-		huge = 0;
-		pagesize = PAGE_SIZE;
-		end = PAGE_ALIGN(i_size_read(file->f_dentry->d_inode))
-			>> PAGE_CACHE_SHIFT;
+		struct inode *ino = file->f_dentry->d_inode;
+ 		huge = is_file_hugepages(file);
+		pagesize = huge ? huge_page_size(hstate_inode(ino)) : PAGE_SIZE;
+		end = ALIGN(i_size_read(ino), pagesize) >> (ffs(pagesize) - 1);
 		addr = 0;
 	}
 
@@ -546,6 +546,9 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 	h->vm_flags = vma->vm_flags;
 	h->vm_pgoff = vma->vm_pgoff;
 
+	if (is_vm_hugetlb_page(vma))
+		h->hugetlb_shift = huge_page_shift(hstate_vma(vma));
+
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 44e4e0a..f8cccf3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2136,7 +2136,7 @@ static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 struct page *consider_hugetlb_private_page(struct vm_area_struct *vma,
 					   unsigned long addr)
 {
-	sturct page *page;
+	struct page *page;
 	int ret, nr = 1;
 
 	ret = follow_hugetlb_page(vma->vm_mm, vma, &page, NULL,
@@ -2149,6 +2149,36 @@ struct page *consider_hugetlb_private_page(struct vm_area_struct *vma,
 	return page;
 }
 
+struct page *consider_hugetlb_shared_page(struct file *file, unsigned long idx)
+{
+	struct address_space *mapping = file->f_mapping;
+	struct page *page;
+
+	page = find_get_page(mapping, idx);
+
+	/*
+	 * Only care about dirty pages; find_get_page() only returns
+	 * pages that have been allocated, so they must be dirty. The
+	 * pages returned are referenced.
+	 */
+
+	if (page) {
+		/*
+		 * If users can be writing to this page using arbitrary
+		 * virtual addresses, take care about potential aliasing
+		 * before reading the page on the kernel side.
+		 */
+		if (mapping_writably_mapped(mapping))
+			flush_dcache_page(page);
+		/*
+		 * Mark the page accessed if we read the beginning.
+		 */
+		mark_page_accessed(page);
+	}
+
+	return page;
+}
+
 int checkpoint_dump_hugetlb(struct ckpt_ctx *ctx, struct page *head)
 {
 	unsigned int nr_pages;
-- 
1.7.1
