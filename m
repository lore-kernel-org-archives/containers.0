From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 3/4] c/r: checkpoint/restart of anonymous hugetlb mappings
Date: Mon, 10 Jan 2011 21:11:28 -0500
Message-ID: <1294711889-30343-4-git-send-email-orenl@cs.columbia.edu>
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

Support checkpoint and restore of both private and shared
hugepage-backed mappings established via mmap(MAP_HUGETLB).  Introduce
APIs for checkpoint and restart of individual huge pages which are to
be used by the sysv SHM_HUGETLB c/r code.

Original patch posted by Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>.

Changelog[v23-rc1]:
  - Mofidied to reuse existing code in mm/checkpoint.c (specifically
  checkpoint_memory_contents() and restore_memory_contents()
  - Merge patch that adds the necessary plumbing to to checkpoint
  open hugetlbfs files.
  - Merge patch that removes VM_HUGETLB from CKPT_VMA_NOT_SUPPORTED

Cc: Nathan Lynch <<ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h     |    3 +-
 include/linux/checkpoint_hdr.h |   16 ++++
 include/linux/hugetlb.h        |   34 +++++++++
 ipc/checkpoint_shm.c           |    2 +-
 mm/checkpoint.c                |   82 ++++++++++++++++------
 mm/hugetlb.c                   |  157 ++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c                     |    2 +-
 7 files changed, 272 insertions(+), 24 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6da31c5..51298d4 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -300,7 +300,8 @@ extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 				      struct vm_area_struct *vma,
 				      struct file *file);
-extern int restore_memory_contents(struct ckpt_ctx *ctx, struct file *file);
+extern int restore_memory_contents(struct ckpt_ctx *ctx,
+				   struct file *file, int huge);
 
 
 #define CKPT_VMA_NOT_SUPPORTED	\
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f7e233d..b7a7406 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -169,6 +169,8 @@ enum {
 #define CKPT_HDR_VMA CKPT_HDR_VMA
 	CKPT_HDR_PGARR,
 #define CKPT_HDR_PGARR CKPT_HDR_PGARR
+	CKPT_HDR_HPAGE,
+#define CKPT_HDR_HPAGE CKPT_HDR_HPAGE
 	CKPT_HDR_MM_CONTEXT,
 #define CKPT_HDR_MM_CONTEXT CKPT_HDR_MM_CONTEXT
 
@@ -922,6 +924,10 @@ enum vma_type {
 #define CKPT_VMA_SHM_IPC CKPT_VMA_SHM_IPC
 	CKPT_VMA_SHM_IPC_SKIP,	/* shared sysvipc (skip contents) */
 #define CKPT_VMA_SHM_IPC_SKIP CKPT_VMA_SHM_IPC_SKIP
+	CKPT_VMA_HUGETLB,
+#define CKPT_VMA_HUGETLB CKPT_VMA_HUGETLB
+	CKPT_VMA_HUGETLB_SKIP,
+#define CKPT_VMA_HUGETLB_SKIP CKPT_VMA_HUGETLB_SKIP
 };
 
 /* vma descriptor */
@@ -946,6 +952,16 @@ struct ckpt_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+/* huge page */
+struct ckpt_hdr_hpage {
+	struct ckpt_hdr h;
+	union {
+		__u64 vaddr;
+		__u64 index;
+	};
+	__u16 shift;
+} __attribute__((aligned(8)));
+
 /* signals */
 struct ckpt_sigset {
 	__u8 sigset[CKPT_ARCH_NSIG / 8];
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 943c76b..a0aabe1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -43,6 +43,13 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						int acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
+#ifdef CONFIG_CHECKPOINT
+int checkpoint_dump_hugetlb(struct ckpt_ctx *ctx, struct page *page);
+int restore_read_hugetlb(struct ckpt_ctx *ctx, struct page *page);
+struct page *consider_hugetlb_private_page(struct vm_area_struct *vma,
+					   unsigned long addr);
+#endif
+
 int dequeue_hwpoisoned_huge_page(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
 
@@ -114,6 +121,22 @@ static inline void copy_huge_page(struct page *dst, struct page *src)
 #define HPAGE_SIZE	PAGE_SIZE
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+static inline int checkpoint_dump_hugetlb(struct ckpt_ctx *ctx, struct page *page)
+{
+	return -ENOSYS;
+}
+static inline int restore_read_hugetlb(struct ckpt_ctx *ctx, struct page *page)
+{
+	return -ENOSYS;
+}
+static inline struct page *consider_hugetlb_private_page(struct vm_area_struct *vma,
+							 unsigned long addr)
+{
+	return ERR_PTR(-ENOSYS);
+}
+#endif
+
 #endif /* !CONFIG_HUGETLB_PAGE */
 
 #define HUGETLB_ANON_FILE "anon_hugepage"
@@ -332,4 +355,15 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 #define hstate_index_to_shift(index) 0
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_HUGETLB_PAGE
+struct ckpt_ctx;
+struct ckpt_hdr_vma;
+extern int hugetlb_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			   struct ckpt_hdr_vma *h);
+#else
+#define hugetlb_restore NULL
+#endif
+#endif
+
 #endif /* _LINUX_HUGETLB_H */
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index acfb79b..05ba5cf 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -294,7 +294,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
 	if (ret < 0)
 		goto fput;
-	ret = restore_memory_contents(ctx, file);
+	ret = restore_memory_contents(ctx, file, 0);
 fput:
 	fput(file);
 
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index 8b40f4d..1c50f62 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -25,6 +25,7 @@
 #include <linux/proc_fs.h>
 #include <linux/swap.h>
 #include <linux/syscalls.h>
+#include <linux/hugetlb.h>
 #include <linux/checkpoint.h>
 
 /*
@@ -240,7 +241,7 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
  */
 static struct page *consider_shared_page(struct file *file, unsigned long idx)
 {
-	struct ino *inode = file->f_dentfy->d_inode;
+	struct inode *ino = file->f_dentry->d_inode;
 	struct page *page = NULL;
 	int ret;
 
@@ -288,20 +289,24 @@ static struct page *consider_shared_page(struct file *file, unsigned long idx)
  */
 static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 			  struct vm_area_struct *vma, struct file *file,
-			  unsigned long *start, unsigned long end)
+			  int huge, unsigned long *start, unsigned long end)
 {
 	unsigned long addr = *start;
 	struct ckpt_pgarr *pgarr;
 	struct inode *inode;
+	unsigned long pagesize;
 	int nr_used;
 	int cnt = 0;
 
 	BUG_ON(file && vma);
 
-	if (vma)
+	if (vma) {
 		down_read(&vma->vm_mm->mmap_sem);
-	else
+		pagesize = vma_kernel_pagesize(vma);
+	} else {
 		inode = file->f_dentry->d_inode;
+		pagesize = 1;
+	}
 
 	do {
 		pgarr = pgarr_current(ctx);
@@ -315,10 +320,14 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 		while (addr < end) {
 			struct page *page;
 
-			if (vma)
+			if (vma && !huge)  /* vma && !huge */
 				page = consider_private_page(vma, addr);
-			else
+			else if (vma)      /* vma && huge */
+				page = consider_hugetlb_private_page(vma, addr);
+			else if (!huge)    /* !vma && !huge */
 				page = consider_shared_page(file, addr);
+			else               /* !vma && huge */
+				page = ERR_PTR(-EINVAL);
 
 			if (IS_ERR(page)) {
 				cnt = PTR_ERR(page);
@@ -333,10 +342,7 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 				pgarr->nr_used++;
 			}
 
-			if (vma)
-				addr += PAGE_SIZE;
-			else
-				addr++;
+			addr += pagesize;
 
 			if (pgarr_is_full(pgarr))
 				break;
@@ -368,10 +374,13 @@ int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page)
  * vma_dump_pages - dump pages listed in the ctx page-array chain
  * @ctx - checkpoint context
  * @total - total number of pages
+ * @huge - indicates hugetbl pages
+ * @pagesize - page size
  *
  * First dump all virtual addresses, followed by the contents of all pages
  */
-static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
+static int vma_dump_pages(struct ckpt_ctx *ctx, int total,
+			  int huge, unsigned long pagesize)
 {
 	struct ckpt_pgarr *pgarr;
 	int i, ret = 0;
@@ -379,7 +388,7 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
 	if (!total)
 		return 0;
 
-	i =  total * (sizeof(unsigned long) + PAGE_SIZE);
+	i =  total * (sizeof(unsigned long) + pagesize);
 	ret = ckpt_write_obj_type(ctx, NULL, i, CKPT_HDR_BUFFER);
 	if (ret < 0)
 		return ret;
@@ -393,7 +402,12 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
 
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		for (i = 0; i < pgarr->nr_used; i++) {
-			ret = checkpoint_dump_page(ctx, pgarr->pages[i]);
+			if (!huge)
+				ret = checkpoint_dump_page(ctx,
+							   pgarr->pages[i]);
+			else
+				ret = checkpoint_dump_hugetlb(ctx,
+							   pgarr->pages[i]);
 			if (ret < 0)
 				return ret;
 		}
@@ -418,14 +432,20 @@ int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long addr, end;
+	unsigned long pagesize;
 	int cnt, ret;
+	int huge;
 
 	BUG_ON(vma && file);
 
 	if (vma) {
-		addr = vma->vm_start;
+		huge = is_vm_hugetlb_page(vma);
+		pagesize = vma_kernel_pagesize(vma);
 		end = vma->vm_end;
+		addr = vma->vm_start;
 	} else {
+		huge = 0;
+		pagesize = PAGE_SIZE;
 		end = PAGE_ALIGN(i_size_read(file->f_dentry->d_inode))
 			>> PAGE_CACHE_SHIFT;
 		addr = 0;
@@ -455,7 +475,7 @@ int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 	 */
 
 	while (addr < end) {
-		cnt = vma_fill_pgarr(ctx, vma, file, &addr, end);
+		cnt = vma_fill_pgarr(ctx, vma, file, huge, &addr, end);
 		if (cnt == 0)
 			break;
 		else if (cnt < 0)
@@ -473,7 +493,7 @@ int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 		if (ret < 0)
 			return ret;
 
-		ret = vma_dump_pages(ctx, cnt);
+		ret = vma_dump_pages(ctx, cnt, huge, pagesize);
 		if (ret < 0)
 			return ret;
 
@@ -905,8 +925,10 @@ static struct page *bring_shared_page(unsigned long idx, struct inode *ino)
 /**
  * read_pages_contents - read in data of pages in page-array chain
  * @ctx - restart context
+ * @file - associated file (mapped or ipc)
+ * @huge - hugetlb flag
  */
-static int read_pages_contents(struct ckpt_ctx *ctx, struct file *file)
+static int read_pages_contents(struct ckpt_ctx *ctx, struct file *file, int huge)
 {
 	struct ckpt_pgarr *pgarr;
 	unsigned long *vaddrs;
@@ -932,7 +954,11 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct file *file)
 			if (IS_ERR(page))
 				return PTR_ERR(page);
 
-			ret = restore_read_page(ctx, page);
+			if (!huge)
+				ret = restore_read_page(ctx, page);
+			else
+				ret = restore_read_hugetlb(ctx, page);
+
 			page_cache_release(page);
 
 			if (ret < 0)
@@ -953,7 +979,7 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct file *file)
  * these steps until reaching a header specifying "0" pages, which marks
  * the end of the contents.
  */
-int restore_memory_contents(struct ckpt_ctx *ctx, struct file *file)
+int restore_memory_contents(struct ckpt_ctx *ctx, struct file *file, int huge)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long nr_pages;
@@ -980,7 +1006,7 @@ int restore_memory_contents(struct ckpt_ctx *ctx, struct file *file)
 		ret = read_pages_vaddrs(ctx, nr_pages);
 		if (ret < 0)
 			break;
-		ret = read_pages_contents(ctx, file);
+		ret = read_pages_contents(ctx, file, huge);
 		if (ret < 0)
 			break;
 		pgarr_reset_all(ctx);
@@ -1030,6 +1056,8 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
 		vm_flags |= MAP_PRIVATE;
 	if (orig_vm_flags & VM_NORESERVE)
 		vm_flags |= MAP_NORESERVE;
+	if (orig_vm_flags & VM_HUGETLB)
+		vm_flags |= MAP_HUGETLB;
 
 	return vm_flags;
 }
@@ -1094,7 +1122,7 @@ int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	if (IS_ERR((void *) addr))
 		return PTR_ERR((void *) addr);
 
-	return restore_memory_contents(ctx, NULL);
+	return restore_memory_contents(ctx, NULL, 0);
 }
 
 /**
@@ -1189,6 +1217,18 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_SHM_IPC_SKIP,
 		.restore = ipcshm_restore,
 	},
+	/* hugeltb */
+	{
+		.vma_name = "HUGETLB",
+		.vma_type = CKPT_VMA_HUGETLB,
+		.restore = hugetlb_restore,
+	},
+	/* hugetlb (skip) */
+	{
+		.vma_name = "HUGETLB (SKIP)",
+		.vma_type = CKPT_VMA_HUGETLB_SKIP,
+		.restore = hugetlb_restore,
+	},
 };
 
 /**
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8585524..44e4e0a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -8,6 +8,9 @@
 #include <linux/mm.h>
 #include <linux/seq_file.h>
 #include <linux/sysctl.h>
+#include <linux/checkpoint.h>
+#include <linux/file.h>
+#include <linux/mman.h>
 #include <linux/highmem.h>
 #include <linux/mmu_notifier.h>
 #include <linux/nodemask.h>
@@ -2129,10 +2132,164 @@ static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+struct page *consider_hugetlb_private_page(struct vm_area_struct *vma,
+					   unsigned long addr)
+{
+	sturct page *page;
+	int ret, nr = 1;
+
+	ret = follow_hugetlb_page(vma->vm_mm, vma, &page, NULL,
+				  &addr, &nr, 1, FOLL_DUMP | FOLL_GET);
+	if (ret == -EFAULT)
+		return NULL;
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	return page;
+}
+
+int checkpoint_dump_hugetlb(struct ckpt_ctx *ctx, struct page *head)
+{
+	unsigned int nr_pages;
+	struct page *page;
+	int ret = 0;
+	int i;
+
+	nr_pages = pages_per_huge_page(page_hstate(head));
+	page = head;
+
+	for (i = 0; i < nr_pages; i++) {
+		void *ptr;
+
+		ptr = kmap_atomic(page, KM_USER1);
+		copy_page(ctx->scratch_page, ptr);
+		kunmap_atomic(ptr, KM_USER1);
+		ret = ckpt_kwrite(ctx, ctx->scratch_page, PAGE_SIZE);
+		if (ret < 0)
+			break;
+
+		page = mem_map_next(page, head, i + 1);
+	}
+
+	return ret;
+}
+
+static int hugetlb_vm_op_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	enum vma_type vma_type;
+	int ino_objref;
+	int ret, first;
+
+	BUG_ON(!(vma->vm_flags & VM_HUGETLB));
+	BUG_ON(!vma->vm_file);
+
+	ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
+	if (ret < 0)
+		return ret;
+
+	ino_objref = ckpt_obj_lookup_add(ctx, vma->vm_file->f_dentry->d_inode,
+					 CKPT_OBJ_INODE, &first);
+	if (ino_objref < 0)
+		return ino_objref;
+
+	vma_type = (first ? CKPT_VMA_HUGETLB : CKPT_VMA_HUGETLB_SKIP);
+
+	ret = generic_vma_checkpoint(ctx, vma, vma_type, 0, ino_objref);
+	if (ret)
+		return ret;
+
+	if (vma_type == CKPT_VMA_HUGETLB)
+		ret = checkpoint_memory_contents(ctx, vma, NULL);
+
+	return ret;
+}
+
+int restore_read_hugetlb(struct ckpt_ctx *ctx, struct page *head)
+{
+	unsigned int nr_pages;
+	struct page *page;
+	int ret = 0;
+	int i;
+
+	nr_pages = pages_per_huge_page(page_hstate(head));
+	page = head;
+
+	for (i = 0; i < nr_pages; i++) {
+		void *ptr;
+
+		ret = ckpt_kread(ctx, ctx->scratch_page, PAGE_SIZE);
+		if (ret < 0)
+			break;
+
+		ptr = kmap_atomic(page, KM_USER1);
+		copy_page(ptr, ctx->scratch_page);
+		kunmap_atomic(ptr, KM_USER1);
+
+		page = mem_map_next(page, head, i + 1);
+	}
+
+	return ret;
+}
+
+int hugetlb_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+		    struct ckpt_hdr_vma *hdr)
+{
+	unsigned long addr;
+	struct file *file;
+	int ret = 0;
+
+	if (!(hdr->vm_flags & (VM_HUGETLB)))
+		return -EINVAL;
+
+	file = ckpt_obj_try_fetch(ctx, hdr->ino_objref, CKPT_OBJ_FILE);
+	if (PTR_ERR(file) == -EINVAL)
+		file = NULL;
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	/* To do: don't assume same default_hstate on source and destinaton */
+	if (!file) {
+		struct user_struct *user = NULL;
+		unsigned long len;
+
+		if (hdr->vma_type != CKPT_VMA_HUGETLB)
+			return -EINVAL;
+
+		/* see sys_mmap_pgoff */
+		len = hdr->vm_end - hdr->vm_start;
+		len = ALIGN(len, huge_page_size(&default_hstate));
+		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
+					  &user, HUGETLB_ANONHUGE_INODE);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+		ret = ckpt_obj_insert(ctx, file, hdr->ino_objref, CKPT_OBJ_FILE);
+		if (ret < 0)
+			goto out;
+	} else {
+		if (hdr->vma_type != CKPT_VMA_HUGETLB_SKIP)
+			return -EINVAL;
+		get_file(file);
+	}
+
+	addr = generic_vma_restore(mm, file, hdr);
+	if (IS_ERR((void *)addr))
+		ret = PTR_ERR((void *)addr);
+	else if (hdr->vma_type == CKPT_VMA_HUGETLB)
+		ret = restore_memory_contents(ctx, file, 1);
+out:
+	fput(file);
+	return ret;
+}
+#endif /* CONFIG_CHECKPOINT */
+
 const struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
 	.open = hugetlb_vm_op_open,
 	.close = hugetlb_vm_op_close,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = hugetlb_vm_op_checkpoint,
+#endif
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
diff --git a/mm/shmem.c b/mm/shmem.c
index cf018ba..7649368 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2486,7 +2486,7 @@ int shmem_restore(struct ckpt_ctx *ctx,
 		return PTR_ERR((void *) addr);
 
 	if (h->vma_type == CKPT_VMA_SHM_ANON)
-		ret = restore_memory_contents(ctx, file);
+		ret = restore_memory_contents(ctx, file, 0);
  out:
 	fput(file);
 	return ret;
-- 
1.7.1
