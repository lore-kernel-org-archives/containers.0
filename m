From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 25/54] Dump anonymous- and file-mapped- shared memory
Date: Tue, 28 Apr 2009 19:23:55 -0400
Message-ID: <1240961064-13991-26-git-send-email-orenl@cs.columbia.edu>
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

We now handle anonymous and file-mapped shared memory. Support for IPC
shared memory requires support for IPC first. We extend ckpt_write_vma()
to detect shared memory VMAs and handle it separately than private
memory.

There is not much to do for file-mapped shared memory, except to force
msync() on the region to ensure that the file system is consistent
with the checkpoint image. Use our internal type CKPT_VMA_SHM_FILE.

Anonymous shared memory is always backed by inode in shmem filesystem.
We use that inode to look up the VMA in the objhash and register it if
not found (on first encounter). In this case, the type of the VMA is
CKPT_VMA_SHM_ANON, and we dump the contents. On the other hand, if it is
found there, we must have already saved it before, so we change the
type to CKPT_VMA_SHM_ANON_SKIP and skip it.

To dump the contents of a shmem VMA, we loop through the pages of the
inode in the shmem filesystem, and dump the contents of each dirty
(allocated) page - unallocated pages must be clean.

Note that we save the original size of a shmem VMA because it may have
been re-mapped partially. The format itself remains like with private
VMAs, except that instead of addresses we record _indices_ (page nr)
into the backing inode.

Changelog[v14]:
  - Introduce patch

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/memory.c            |  155 ++++++++++++++++++++++++++++++++++-----
 include/linux/checkpoint.h     |   15 +++--
 include/linux/checkpoint_hdr.h |    8 ++-
 mm/filemap.c                   |   45 +++++++++++-
 mm/mmap.c                      |    2 +-
 mm/shmem.c                     |   35 +++++++++
 6 files changed, 228 insertions(+), 32 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 4fa634a..f96a50f 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -21,6 +21,7 @@
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
 #include <linux/proc_fs.h>
+#include <linux/swap.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -283,6 +284,54 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
 }
 
 /**
+ * consider_shared_page - return page pointer for dirty pages
+ * @ino - inode of shmem object
+ * @idx - page index in shmem object
+ *
+ * Looks up the page that corresponds to the index in the shmem object,
+ * and returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ */
+static struct page *consider_shared_page(struct inode *ino, unsigned long idx)
+{
+	struct page *page = NULL;
+	int ret;
+
+	/*
+	 * Inspired by do_shmem_file_read(): very simplified version.
+	 *
+	 * FIXME: consolidate with do_shmem_file_read()
+	 */
+
+	ret = shmem_getpage(ino, idx, &page, SGP_READ, NULL);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	/*
+	 * Only care about dirty pages; shmem_getpage() only returns
+	 * pages that have been allocated, so they must be dirty. The
+	 * pages returned are locked and referenced.
+	 */
+
+	if (page) {
+		unlock_page(page);
+		/*
+		 * If users can be writing to this page using arbitrary
+		 * virtual addresses, take care about potential aliasing
+		 * before reading the page on the kernel side.
+		 */
+		if (mapping_writably_mapped(ino->i_mapping))
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
+/**
  * private_vma_fill_pgarr - fill a page-array with addr/page tuples
  * @ctx - checkpoint context
  * @vma - vma to scan
@@ -290,18 +339,17 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
  *
  * Returns the number of pages collected
  */
-static int private_vma_fill_pgarr(struct ckpt_ctx *ctx,
-				  struct vm_area_struct *vma,
-				  unsigned long *start)
+static int vma_fill_pgarr(struct ckpt_ctx *ctx,
+			  struct vm_area_struct *vma, struct inode *inode,
+			  unsigned long *start, unsigned long end)
 {
-	unsigned long end = vma->vm_end;
 	unsigned long addr = *start;
 	struct ckpt_pgarr *pgarr;
 	int nr_used;
 	int cnt = 0;
 
 	/* this function is only for private memory (anon or file-mapped) */
-	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+	BUG_ON(inode && vma);
 
 	do {
 		pgarr = pgarr_current(ctx);
@@ -313,7 +361,11 @@ static int private_vma_fill_pgarr(struct ckpt_ctx *ctx,
 		while (addr < end) {
 			struct page *page;
 
-			page = consider_private_page(vma, addr);
+			if (vma)
+				page = consider_private_page(vma, addr);
+			else
+				page = consider_shared_page(inode, addr);
+
 			if (IS_ERR(page))
 				return PTR_ERR(page);
 
@@ -325,7 +377,10 @@ static int private_vma_fill_pgarr(struct ckpt_ctx *ctx,
 				pgarr->nr_used++;
 			}
 
-			addr += PAGE_SIZE;
+			if (vma)
+				addr += PAGE_SIZE;
+			else
+				addr++;
 
 			if (pgarr_is_full(pgarr))
 				break;
@@ -393,24 +448,36 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
 }
 
 /**
- * checkpoint_private_contents - dump contents of a VMA with private memory
+ * checkpoint_memory_contents - dump contents of a memory region
  * @ctx - checkpoint context
- * @vma - vma to scan
+ * @vma - vma to scan (--or--)
+ * @inode - inode to scan
  *
  * Collect lists of pages that needs to be dumped, and corresponding
  * virtual addresses into ctx->pgarr_list page-array chain. Then dump
  * the addresses, followed by the page contents.
  */
-static int checkpoint_private_contents(struct ckpt_ctx *ctx,
-				       struct vm_area_struct *vma)
+static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma,
+				      struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
-	unsigned long addr = vma->vm_start;
+	unsigned long addr, end;
 	int cnt, ret;
 
+	BUG_ON(vma && inode);
+
+	if (vma) {
+		addr = vma->vm_start;
+		end = vma->vm_end;
+	} else {
+		addr = 0;
+		end = PAGE_ALIGN(i_size_read(inode)) >> PAGE_CACHE_SHIFT;
+	}
+
 	/*
 	 * Work iteratively, collecting and dumping at most CKPT_PGARR_CHUNK
-	 * in each round. Each iterations is divided into two steps:
+	 * in each round. Each iteration is divided into two steps:
 	 *
 	 * (1) scan: scan through the PTEs of the vma to collect the pages
 	 * to dump (later we'll also make them COW), while keeping a list
@@ -427,12 +494,12 @@ static int checkpoint_private_contents(struct ckpt_ctx *ctx,
 	 * the actual write-out of the data to after the application is
 	 * allowed to resume execution).
 	 *
-	 * After dumpting the entire contents, conclude with a header that
+	 * After dumping the entire contents, conclude with a header that
 	 * specifies 0 pages to mark the end of the contents.
 	 */
 
-	while (addr < vma->vm_end) {
-		cnt = private_vma_fill_pgarr(ctx, vma, &addr);
+	while (addr < end) {
+		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
 		if (cnt == 0)
 			break;
 		else if (cnt < 0)
@@ -476,7 +543,7 @@ static int checkpoint_private_contents(struct ckpt_ctx *ctx,
  * @objref: vma object id
  */
 int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
-			   enum vma_type type, int vma_objref)
+			   enum vma_type type, int vma_objref, int ino_objref)
 {
 	struct ckpt_hdr_vma *h;
 	int ret;
@@ -495,6 +562,12 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 
 	h->vma_type = type;
 	h->vma_objref = vma_objref;
+	h->ino_objref = ino_objref;
+
+	if (vma->vm_file)
+		h->ino_size = i_size_read(vma->vm_file->f_dentry->d_inode);
+	else
+		h->ino_size = 0;
 
 	h->vm_start = vma->vm_start;
 	h->vm_end = vma->vm_end;
@@ -523,16 +596,43 @@ int private_vma_checkpoint(struct ckpt_ctx *ctx,
 
 	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
 
-	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref);
+	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref, 0);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, vma, NULL);
+ out:
+	return ret;
+}
+
+/**
+ * shmem_vma_checkpoint - dump contents of private (anon, file) vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @objref: vma object id
+ */
+int shmem_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
+			 enum vma_type type, int ino_objref)
+{
+	struct file *file = vma->vm_file;
+	int ret;
+
+	ckpt_debug("type %d, ino_ref %d\n", type, ino_objref);
+	BUG_ON(!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)));
+	BUG_ON(!file);
+
+	ret = generic_vma_checkpoint(ctx, vma, type, 0, ino_objref);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_private_contents(ctx, vma);
+	if (type == CKPT_VMA_SHM_ANON_SKIP)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, NULL, file->f_dentry->d_inode);
  out:
 	return ret;
 }
 
 /**
- * anonymous_checkpoint - dump contents of anonymous vma
+ * anonymous_checkpoint - dump contents of private-anonymous vma
  * @ctx: checkpoint context
  * @vma: vma object
  */
@@ -908,6 +1008,21 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_FILE,
 		.restore = filemap_restore,
 	},
+	/* anonymous shared */
+	{
+		.vma_name = "ANON SHARED",
+		.vma_type = CKPT_VMA_SHM_ANON,
+	},
+	/* anonymous shared (skipped) */
+	{
+		.vma_name = "ANON SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_ANON_SKIP,
+	},
+	/* file-mapped shared */
+	{
+		.vma_name = "FILE SHARED",
+		.vma_type = CKPT_VMA_SHM_FILE,
+	},
 };
 
 /**
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 859897f..53399f8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -71,11 +71,15 @@ extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma,
 				  enum vma_type type,
-				  int vma_objref);
+				  int vma_objref, int ino_objref);
 extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma,
 				  enum vma_type type,
 				  int vma_objref);
+extern int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
+				struct vm_area_struct *vma,
+				enum vma_type type,
+				int ino_objref);
 
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
@@ -83,11 +87,10 @@ extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 extern int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_mm(struct ckpt_ctx *ctx);
 
-#define CKPT_VMA_NOT_SUPPORTED					\
-	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB |		\
-	 VM_NONLINEAR | VM_PFNMAP | VM_RESERVED | VM_NORESERVE	\
-	 | VM_HUGETLB | VM_NONLINEAR | VM_MAPPED_COPY |		\
-	 VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
+#define CKPT_VMA_NOT_SUPPORTED						\
+	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
+	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
+	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 /* files */
 extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 555bbf3..59fab62 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -177,6 +177,9 @@ enum vma_type {
 	CKPT_VMA_VDSO,		/* special vdso vma */
 	CKPT_VMA_ANON,		/* private anonymous */
 	CKPT_VMA_FILE,		/* private mapped file */
+	CKPT_VMA_SHM_ANON,	/* shared anonymous */
+	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
+	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
 	CKPT_VMA_MAX,
 };
 
@@ -184,7 +187,10 @@ enum vma_type {
 struct ckpt_hdr_vma {
 	struct ckpt_hdr h;
 	__u32 vma_type;
-	__u32 vma_objref;	/* for vma->vm_file */
+	__s32 vma_objref;	/* objref of backing file */
+	__s32 ino_objref;	/* objref of shared segment */
+	__u32 _padding;
+	__u64 ino_size;		/* size of shared segment */
 
 	__u64 vm_start;
 	__u64 vm_end;
diff --git a/mm/filemap.c b/mm/filemap.c
index e515845..e9499d9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1630,10 +1630,12 @@ page_not_uptodate:
 EXPORT_SYMBOL(filemap_fault);
 
 #ifdef CONFIG_CHECKPOINT
-static int filemap_checkpoint(struct ckpt_ctx *ctx,
-				  struct vm_area_struct *vma)
+static int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 {
+	struct file *file = vma->vm_file;
 	int vma_objref;
+	int ino_objref;
+	int first, ret;
 
 	/* should be private anonymous ... verify that this is the case */
 	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
@@ -1641,14 +1643,49 @@ static int filemap_checkpoint(struct ckpt_ctx *ctx,
 		return -ENOSYS;
 	}
 
-	BUG_ON(!vma->vm_file);
+	BUG_ON(!file);
 
 	/* checkpoint the file object first (will add to objhash) */
 	vma_objref = checkpoint_obj(ctx, vma->vm_file, CKPT_OBJ_FILE);
 	if (vma_objref < 0)
 		return vma_objref;
 
-	return  private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
+	if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE)) {
+		/*
+		 * Citing mmap(2): "Updates to the mapping are visible
+		 * to other processes that map this file, and are
+		 * carried through to the underlying file. The file
+		 * may not actually be updated until msync(2) or
+		 * munmap(2) is called"
+		 *
+		 * Citing msync(2): "Without use of this call there is
+		 * no guarantee that changes are written back before
+		 * munmap(2) is called."
+		 *
+		 * Force msync for region of shared mapped files, to
+		 * ensure that that the file system is consistent with
+		 * the checkpoint image.  (inspired by sys_msync).
+		 */
+
+		ino_objref = ckpt_obj_lookup_add(ctx, file->f_dentry->d_inode,
+					       CKPT_OBJ_INODE, &first);
+		if (ino_objref < 0)
+			return ino_objref;
+
+		if (first) {
+			ret = vfs_fsync(file, file->f_path.dentry, 0);
+			if (ret < 0)
+				return ret;
+		}
+
+		ret = generic_vma_checkpoint(ctx, vma, CKPT_VMA_SHM_FILE,
+					     vma_objref, ino_objref);
+	} else {
+		ret = private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE,
+					     vma_objref);
+	}
+
+	return ret;
 }
 
 int filemap_restore(struct ckpt_ctx *ctx,
diff --git a/mm/mmap.c b/mm/mmap.c
index 0c65512..555a6a3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2300,7 +2300,7 @@ static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 	if (!name || strcmp(name, "[vdso]"))
 		return -ENOSYS;
 
-	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0, 0);
 }
 
 int special_mapping_restore(struct ckpt_ctx *ctx,
diff --git a/mm/shmem.c b/mm/shmem.c
index e24da02..17847b0 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -31,6 +31,10 @@
 #include <linux/swap.h>
 #include <linux/ima.h>
 
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
+
 static struct vfsmount *shm_mnt;
 
 #ifdef CONFIG_SHMEM
@@ -2377,6 +2381,34 @@ static void shmem_destroy_inode(struct inode *inode)
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int shmem_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	enum vma_type vma_type;
+	int ino_objref;
+	int first;
+
+	/* should be private anonymous ... verify that this is the case */
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(!vma->vm_file);
+
+	ino_objref = ckpt_obj_lookup_add(ctx, vma->vm_file->f_dentry->d_inode,
+					 CKPT_OBJ_INODE, &first);
+	if (ino_objref < 0)
+		return ino_objref;
+
+	vma_type = (first ? CKPT_VMA_SHM_ANON : CKPT_VMA_SHM_ANON_SKIP);
+
+	return shmem_vma_checkpoint(ctx, vma, vma_type, ino_objref);
+}
+#else
+#define shmem_checkpoint NULL
+#endif /* CONFIG_CHECKPOINT */
+
 static void init_once(void *foo)
 {
 	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
@@ -2492,6 +2524,9 @@ static struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= shmem_checkpoint,
+#endif
 };
 
 
-- 
1.5.4.3
