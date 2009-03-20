From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc][PATCH 19/23] Dump anonymous- and file-mapped- shared
	memory
Date: Fri, 20 Mar 2009 14:47:44 -0400
Message-ID: <1237574868-3371-20-git-send-email-orenl@cs.columbia.edu>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237574868-3371-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

We now handle anonymous and file-mapped shared memory. Support for IPC
shared memory requires support for IPC first. We extend cr_write_vma()
to detect shared memory VMAs and handle it separately than private
memory.

There is not much to do for file-mapped shared memory, except to force
msync() on the region to ensure that the file system is consistent
with the checkpoint image. Use our internal type CR_VMA_SHM_FILE.

Anonymous shared memory is always backed by inode in shmem filesystem.
We use that inode to look up the VMA in the objhash and register it if
not found (on first encounter). In this case, the type of the VMA is
set to CR_VMA_SHM_ANON, and we dump the contents. On the other hand,
if it is found there, we must have already saved it before, so we
change the type to CR_VMA_SHM_ANON_SKIP and skip it.

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
 checkpoint/ckpt_mem.c          |  278 ++++++++++++++++++++++++++++++++++------
 checkpoint/rstr_mem.c          |    4 +
 include/linux/checkpoint_hdr.h |   12 ++-
 mm/shmem.c                     |    3 +
 4 files changed, 257 insertions(+), 40 deletions(-)

diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 6975c87..2ac5571 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -13,6 +13,7 @@
 #include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/pagemap.h>
+#include <linux/swap.h>
 #include <linux/mm_types.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -182,11 +183,11 @@ void cr_pgarr_reset_all(struct cr_ctx *ctx)
 
 
 /**
- * cr_private_follow_page - return page pointer for dirty pages
+ * cr_consider_private_page - return page pointer for dirty pages
  * @vma - target vma
  * @addr - page address
  *
- * Looks up the page that correspond to the address in the vma, and
+ * Looks up the page that corresponds to the address in the vma, and
  * returns the page if it was modified (and grabs a reference to it),
  * or otherwise returns NULL (or error).
  *
@@ -252,25 +253,79 @@ cr_consider_private_page(struct vm_area_struct *vma, unsigned long addr)
 }
 
 /**
- * cr_private_vma_fill_pgarr - fill a page-array with addr/page tuples
+ * cr_consider_shared_page - return page pointer for dirty pages
+ * @ino - inode of shmem object
+ * @idx - page index in shmem object
+ *
+ * Looks up the page that corresponds to the index in the shmem object,
+ * and returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ *
+ * This function should _only_ called for shared vma's.
+ */
+static struct page *
+cr_consider_shared_page(struct inode *inode, unsigned long idx)
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
+	ret = shmem_getpage(inode, idx, &page, SGP_READ, NULL);
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
+		if (mapping_writably_mapped(inode->i_mapping))
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
+ * cr_vma_fill_pgarr - fill a page-array with addr/page tuples
  * @ctx - checkpoint context
  * @vma - vma to scan
  * @start - start address (updated)
+ * @start - end address (updated)
  *
+ * For private vma, records addr/page tuples. For shared vma, records
+ * index/page (index is the index of the page in the shmem object).
  * Returns the number of pages collected
  */
-static int
-cr_private_vma_fill_pgarr(struct cr_ctx *ctx, struct vm_area_struct *vma,
-			  unsigned long *start)
+static int cr_vma_fill_pgarr(struct cr_ctx *ctx, int shm,
+			     struct vm_area_struct *vma, struct inode *ino,
+			     unsigned long *start, unsigned long end)
 {
-	unsigned long end = vma->vm_end;
 	unsigned long addr = *start;
 	struct cr_pgarr *pgarr;
 	int nr_used;
 	int cnt = 0;
 
 	/* this function is only for private memory (anon or file-mapped) */
-	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+	BUG_ON((vma && inode) || (inode && !shm) || (vma && shm));
+	BUG_ON(vma && (vma->vm_flags & (VM_SHARED | VM_MAYSHARE)));
 
 	do {
 		pgarr = cr_pgarr_current(ctx);
@@ -282,7 +337,11 @@ cr_private_vma_fill_pgarr(struct cr_ctx *ctx, struct vm_area_struct *vma,
 		while (addr < end) {
 			struct page *page;
 
-			page = cr_consider_private_page(vma, addr);
+			if (shm)
+				page = cr_consider_shared_page(ino, addr);
+			else
+				page = cr_consider_private_page(vma, addr);
+
 			if (IS_ERR(page))
 				return PTR_ERR(page);
 
@@ -359,7 +418,7 @@ static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
 }
 
 /**
- * cr_write_private_vma_contents - dump contents of a VMA with private memory
+ * cr_write_vma_contents - dump contents of a VMA
  * @ctx - checkpoint context
  * @vma - vma to scan
  *
@@ -367,17 +426,18 @@ static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
  * virtual addresses into ctx->pgarr_list page-array chain. Then dump
  * the addresses, followed by the page contents.
  */
-static int
-cr_write_private_vma_contents(struct cr_ctx *ctx, struct vm_area_struct *vma)
+static int cr_write_vma_contents(struct cr_ctx *ctx, int shm,
+				 struct vm_area_struct *vma, struct inode *ino,
+				 unsigned long start, unsigned long end)
 {
 	struct cr_hdr h;
 	struct cr_hdr_pgarr *hh;
-	unsigned long addr = vma->vm_start;
+	unsigned long addr = start;
 	int cnt, ret;
 
 	/*
 	 * Work iteratively, collecting and dumping at most CR_PGARR_CHUNK
-	 * in each round. Each iterations is divided into two steps:
+	 * in each round. Each iteration is divided into two steps:
 	 *
 	 * (1) scan: scan through the PTEs of the vma to collect the pages
 	 * to dump (later we'll also make them COW), while keeping a list
@@ -394,15 +454,16 @@ cr_write_private_vma_contents(struct cr_ctx *ctx, struct vm_area_struct *vma)
 	 * the actual write-out of the data to after the application is
 	 * allowed to resume execution).
 	 *
-	 * After dumpting the entire contents, conclude with a header that
+	 * After dumping the entire contents, conclude with a header that
 	 * specifies 0 pages to mark the end of the contents.
 	 */
 
 	h.type = CR_HDR_PGARR;
 	h.len = sizeof(*hh);
 
-	while (addr < vma->vm_end) {
-		cnt = cr_private_vma_fill_pgarr(ctx, vma, &addr);
+	while (addr < end) {
+
+		cnt = cr_vma_fill_pgarr(ctx, shm, vma, ino, &addr, end);
 		if (cnt == 0)
 			break;
 		else if (cnt < 0)
@@ -436,13 +497,117 @@ cr_write_private_vma_contents(struct cr_ctx *ctx, struct vm_area_struct *vma)
 	return ret;
 }
 
+/**
+ * cr_write_private_vma_contents - dump contents of a VMA with private memory
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ */
+static int cr_write_private_vma_contents(struct cr_ctx *ctx,
+					 struct vm_area_struct *vma)
+{
+	return cr_write_vma_contents(ctx, 0, vma, NULL,
+				     vma->vm_start, vma->vm_end);
+}
+
+static int cr_shmem_inode_to_pages(struct inode *inode)
+{
+	return PAGE_ALIGN(i_size_read(inode)) >> PAGE_CACHE_SHIFT;
+}
+
+/**
+ * cr_write_shared_vma_contents - dump contents of a VMA with shared memory
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ */
+static int cr_write_shared_vma_contents(struct cr_ctx *ctx,
+					struct vm_area_struct *vma,
+					enum vm_type vma_type)
+{
+	struct inode *inode;
+	unsigned long end;
+	int ret;
+
+	/*
+	 * Citing mmap(2): "Updates to the mapping are visible to other
+	 * processes that map this file, and are carried through to the
+	 * underlying file. The file may not actually be updated until
+	 * msync(2) or munmap(2) is called"
+	 *
+	 * Citing msync(2): "Without use of this call there is no guarantee
+	 * that changes are written back before munmap(2) is called."
+	 *
+	 * Force msync for region of shared mapped files, to ensure that
+	 * that the file system is consistent with the checkpoint image.
+	 * (inspired by sys_msync).
+	 *
+	 * [FIXME: do this only once per shared segment]
+	 */
+
+	switch (vma_type) {
+	case CR_VMA_SHM_FILE:
+		/* no need for contents that are stored in the file system */
+		ret = vfs_fsync(vma->vm_file, vma->vm_file->f_path.dentry, 0);
+		break;
+	case VMA_SHM_ANON:
+		/* save the contents of this resgion */
+		inode = vma->vm_file->f_dentry->d_inode;
+		end = cr_shmem_inode_to_pages(inode);
+		ret = cr_write_vma_contents(ctx, 1, NULL, inode, 0, end);
+		break;
+	case VMA_SHM_ANON_SKIP:
+		/* already saved before .. skip now */
+		ret = 0;
+		break;
+	}
+
+	return ret;
+}
+
+/* return the subtype of a private vma segment */
+static enum vm_type cr_private_vma_type(struct vm_area_struct *vma)
+{
+	if (vma->vm_file)
+		return CR_VMA_FILE;
+	else
+		return CR_VMA_ANON;
+}
+
+/* return the subtype of a shared vma segment */
+static enum vm_type cr_shared_vma_type(struct vm_area_struct *vma, int new)
+{
+	enum vm_type vma_type;
+
+	if (vma->vm_ops == &shmem_vm_ops)	/* /dev/zero or anonymous */
+		vma_type = CR_VMA_SHM_ANON;
+	else if (vma->vm_ops == &shm_vm_ops)	/* IPC (unsupported yet) */
+		vma_type = -EINVAL;
+	else
+		vma_type = CR_VMA_SHM_FILE;
+
+	if (!new && vma_type == CR_VMA_SHM_ANON)
+		vma_type = CR_VMA_SHM_ANON_SKIP;
+
+	return vma_type;
+}
+
+/**
+ * cr_write_vma - classify the vma and dump its contents
+ * @ctx: checkpoint context
+ * @vma: vma object
+ *
+ * vma type can be
+ *  CR_VMA_ANON: private anonymous
+ *  CR_VMA_FILE: private mapped file
+ *  CR_VMA_SHM_ANON: shared anonymous
+ *  CR_VMA_SHM_FILE: shared mapped file
+ *  CR_VMA_SHM_ANON_SKIP: shared anonymous, skip contents
+ */
 static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 {
 	struct cr_hdr h;
 	struct cr_hdr_vma *hh;
-	int vma_type;
-	int objref = 0;
-	int new = 0;
+	enum vm_type vma_type;
+	int objref, new;
 	int ret;
 
 	h.type = CR_HDR_VMA;
@@ -450,7 +615,7 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
-		return -EBUSY;
+		return -ENOMEM;
 
 	hh->vm_start = vma->vm_start;
 	hh->vm_end = vma->vm_end;
@@ -458,8 +623,7 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 	hh->vm_flags = vma->vm_flags;
 	hh->vm_pgoff = vma->vm_pgoff;
 
-#define CR_BAD_VM_FLAGS  \
-	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB | VM_NONLINEAR)
+#define CR_BAD_VM_FLAGS  (VM_IO | VM_HUGETLB | VM_NONLINEAR)
 
 	if (vma->vm_flags & CR_BAD_VM_FLAGS) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
@@ -467,38 +631,78 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 		goto out;
 	}
 
-	vma_type = CR_VMA_ANON;  /* by default assume anon memory */
+	/*
+	 * Categorize the vma whether shared or private. If shared, deposit
+	 * the backing inode in the objhash, so that the contents are only
+	 * dumped once.
+	 */
+	if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE)) {
+		struct inode *inode = vma->vm_file->f_dentry->d_inode;;
+		new = cr_obj_add_ptr(ctx, inode, &objref, CR_OBJ_INODE, 0);
+		if (new < 0) {
+			ret = new;
+			goto out;
+		}
+		hh->shm_objref = objref;
+		hh->shm_size = i_size_read(inode);
+		vma_type = cr_shared_vma_type(vma, new);
+	} else {
+		hh->shm_objref = 0;
+		hh->shm_size = 0;
+		vma_type = cr_private_vma_type(vma);
+	}
+
+	if (vma_type < 0) {
+		ret = vma_type;
+		goto out;
+	}
+
+	hh->vma_type = vma_type;
 
-	if (vma->vm_file)
-		vma_type = CR_VMA_FILE;		/* assume private-mapped */
-
-	/* if file-backed, add 'file' to the hash (will keep a reference) */
-	if (vma->vm_file) {
-		new = cr_obj_add_ptr(ctx, vma->vm_file,
-				     &objref, CR_OBJ_FILE, 0);
-		cr_debug("vma %p objref %d file %p)\n",
-			 vma, objref, vma->vm_file);
+	/*
+	 * If the vma is file-backed (private or shared) we need to save
+	 * the corresponding file object. As the file object can be shared,
+	 * we follow the same logic as when handling file descriptors.
+	 */
+	if (vma_type == CR_VMA_FILE || vma_type == CR_VMA_SHM_FILE) {
+		struct file *file = vma->vm_file;
+		new = cr_obj_add_ptr(ctx, file, &objref, CR_OBJ_FILE, 0);
+		cr_debug("vma %p objref %d file %p)\n", vma, objref, file);
 		if (new < 0) {
 			ret  = new;
 			goto out;
 		}
+		hh->vma_objref = objref;
+	} else {
+		hh->vma_objref = 0;
+		new = 0;
 	}
 
-	hh->vma_type = vma_type;
-	hh->vma_objref = objref;
+	cr_debug("vma %#lx-%#lx flags %#lx f_objref %d s_objref %d type %d\n",
+		 (unsigned long) hh->vm_start, (unsigned long) hh->vm_end,
+		 (unsigned long) hh->vm_flags, (int) hh->vma_objref,
+		 (int) hh->shm_objref, (int) hh->vma_type);
 
+	/* at last, the vma header is ready: write it out */
 	ret = cr_write_obj(ctx, &h, hh);
 	if (ret < 0)
 		goto out;
 
-	/* new==1 if-and-only-if file was newly added to hash */
+	/*
+	 * new==1 if-and-only-if file was newly added to hash; in that
+	 * case we need to dump its state as well
+	 */
 	if (new) {
 		ret = cr_write_file(ctx, vma->vm_file);
 		if (ret < 0)
 			goto out;
 	}
 
-	ret = cr_write_private_vma_contents(ctx, vma);
+	/* finally, dump the actual contents of this vma */
+	if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE))
+		ret = cr_write_shared_vma_contents(ctx, vma, vma_type);
+	else
+		ret = cr_write_private_vma_contents(ctx, vma);
 
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index 5f46f11..3dc73f4 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -323,6 +323,10 @@ static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
 		/* standard case: read the data into the memory */
 		ret = cr_read_private_vma_contents(ctx);
 		break;
+	default:
+		/* pacifcy gcc (the default will be caught above) */
+		ret = -EINVAL;
+		break;
 	}
 
  out:
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index bc054f2..c30c5f6 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -117,13 +117,19 @@ struct cr_hdr_mm {
 
 /* vma subtypes */
 enum vm_type {
-	CR_VMA_ANON = 1,
-	CR_VMA_FILE
+	CR_VMA_ANON,
+	CR_VMA_FILE,
+	CR_VMA_SHM_ANON,
+	CR_VMA_SHM_ANON_SKIP,
+	CR_VMA_SHM_FILE
 };
 
 struct cr_hdr_vma {
 	__u32 vma_type;
-	__u32 vma_objref;	/* for vma->vm_file */
+	__s32 vma_objref;	/* objref of backing file */
+	__s32 shm_objref;	/* objref of shared segment */
+	__u32 _padding;
+	__u64 shm_size;		/* size of shared segment */
 
 	__u64 vm_start;
 	__u64 vm_end;
diff --git a/mm/shmem.c b/mm/shmem.c
index e5abf26..a12ab7d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -91,6 +91,9 @@ enum sgp_type {
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
 };
 
+int shmem_getpage(struct inode *inode, unsigned long idx,
+		  struct page **pagep, enum sgp_type sgp, int *type);
+
 #ifdef CONFIG_TMPFS
 static unsigned long shmem_default_max_blocks(void)
 {
-- 
1.5.4.3
