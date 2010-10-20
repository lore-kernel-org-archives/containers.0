From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 08/11] checkpoint/restart of anonymous hugetlb mappings
Date: Wed, 20 Oct 2010 13:56:43 -0500
Message-ID: <1287601006-13794-9-git-send-email-ntl@pobox.com>
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
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Support checkpoint and restore of both private and shared
hugepage-backed mappings established via mmap(MAP_HUGETLB).  Introduce
APIs for checkpoint and restart of individual huge pages which are to
be used by the sysv SHM_HUGETLB c/r code.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint.h     |    3 +
 include/linux/checkpoint_hdr.h |   16 +++
 include/linux/hugetlb.h        |   11 ++
 mm/checkpoint.c                |   13 ++
 mm/hugetlb.c                   |  257 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 300 insertions(+), 0 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index df0a9ed..7b30ce5 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -304,6 +304,9 @@ extern unsigned long generic_vma_restore(struct mm_struct *mm,
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
 
+extern int hugetlb_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			   struct ckpt_hdr_vma *hdr);
+
 extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 				      struct vm_area_struct *vma,
 				      struct inode *inode);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 6a3e309..d08d91e 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -166,6 +166,8 @@ enum {
 #define CKPT_HDR_VMA CKPT_HDR_VMA
 	CKPT_HDR_PGARR,
 #define CKPT_HDR_PGARR CKPT_HDR_PGARR
+	CKPT_HDR_HPAGE,
+#define CKPT_HDR_HPAGE CKPT_HDR_HPAGE
 	CKPT_HDR_MM_CONTEXT,
 #define CKPT_HDR_MM_CONTEXT CKPT_HDR_MM_CONTEXT
 
@@ -916,6 +918,10 @@ enum vma_type {
 #define CKPT_VMA_SHM_IPC_SKIP CKPT_VMA_SHM_IPC_SKIP
 	CKPT_VMA_DEVICE,	/* c/r mapping only, skip contents */
 #define CKPT_VMA_DEVICE CKPT_VMA_DEVICE
+	CKPT_VMA_HUGETLB,
+#define CKPT_VMA_HUGETLB CKPT_VMA_HUGETLB
+	CKPT_VMA_HUGETLB_SKIP,
+#define CKPT_VMA_HUGETLB_SKIP CKPT_VMA_HUGETLB_SKIP
 	CKPT_VMA_MAX,
 #define CKPT_VMA_MAX CKPT_VMA_MAX
 };
@@ -942,6 +948,16 @@ struct ckpt_hdr_pgarr {
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
index 78b4bc6..3808c04 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -47,6 +47,8 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						int acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
+int hugetlb_restore_page(struct ckpt_ctx *ctx, struct page *page);
+int hugetlb_checkpoint_page(struct ckpt_ctx *ctx, struct page *page);
 
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
@@ -323,6 +325,15 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1;
 }
+
+static inline int hugetlb_restore_page(struct ckpt_ctx *ctx, struct page *page)
+{
+	return -ENOSYS;
+}
+static inline int hugetlb_checkpoint_page(struct ckpt_ctx *ctx, struct page *page)
+{
+	return -ENOSYS;
+}
 #endif
 
 #endif /* _LINUX_HUGETLB_H */
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index 38c8b1f..8732b9e 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -1035,6 +1035,8 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
 		vm_flags |= MAP_PRIVATE;
 	if (orig_vm_flags & VM_NORESERVE)
 		vm_flags |= MAP_NORESERVE;
+	if (orig_vm_flags & VM_HUGETLB)
+		vm_flags |= MAP_HUGETLB;
 
 	return vm_flags;
 }
@@ -1217,6 +1219,17 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_DEVICE,
 		.restore = device_vma_restore,
 	},
+	/* hugeltb */
+	{
+		.vma_name = "HUGETLB",
+		.vma_type = CKPT_VMA_HUGETLB,
+		.restore = hugetlb_restore,
+	},
+	{
+		.vma_name = "HUGETLB (SKIP)",
+		.vma_type = CKPT_VMA_HUGETLB_SKIP,
+		.restore = hugetlb_restore,
+	},
 };
 
 /**
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6034dc9..3b5942c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -8,7 +8,10 @@
 #include <linux/mm.h>
 #include <linux/seq_file.h>
 #include <linux/sysctl.h>
+#include <linux/checkpoint.h>
+#include <linux/file.h>
 #include <linux/highmem.h>
+#include <linux/mman.h>
 #include <linux/mmu_notifier.h>
 #include <linux/nodemask.h>
 #include <linux/pagemap.h>
@@ -2057,10 +2060,264 @@ static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return 0;
 }
 
+#define ckpt_debug_hpage_hdr(hdr) \
+	ckpt_debug("vaddr=%#llx shift=%hu\n", (hdr)->vaddr, (hdr)->shift)
+
+static void ckpt_hdr_hpage_init(struct ckpt_hdr_hpage *hdr, unsigned long shift)
+{
+	hdr->h.type = CKPT_HDR_HPAGE;
+	hdr->h.len = sizeof(struct ckpt_hdr_hpage);
+	hdr->shift = shift;
+	hdr->vaddr = 0; /* to be filled in by user */
+}
+
+int hugetlb_checkpoint_page(struct ckpt_ctx *ctx, struct page *head)
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
+		cond_resched();
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
+#define CKPT_HDR_HPAGE_LAST ~(0UL)
+static bool ckpt_hdr_hpage_last(const struct ckpt_hdr_hpage *hdr)
+{
+	return hdr->vaddr == CKPT_HDR_HPAGE_LAST;
+}
+
+static int hugetlb_dump_contents(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct ckpt_hdr_hpage hdr;
+	unsigned long pageshift;
+	unsigned long pagesize;
+	unsigned long addr;
+	int ret;
+
+	pageshift = huge_page_shift(hstate_vma(vma));
+	pagesize = vma_kernel_pagesize(vma);
+
+	ckpt_hdr_hpage_init(&hdr, pageshift);
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += pagesize) {
+		struct page *page = NULL;
+
+		down_read(&vma->vm_mm->mmap_sem);
+		ret = __get_user_pages(ctx->tsk, vma->vm_mm,
+				       addr, 1, FOLL_DUMP | FOLL_GET,
+				       &page, NULL);
+		/* FOLL_DUMP gives -EFAULT for holes */
+		if (ret == -EFAULT)
+			ret = 0;
+		up_read(&vma->vm_mm->mmap_sem);
+
+		if (ret < 0)
+			goto release;
+		if (!page)
+			continue;
+
+		hdr.vaddr = addr;
+
+		ckpt_debug_hpage_hdr(&hdr);
+
+		ret = ckpt_write_obj(ctx, &hdr.h);
+		if (ret < 0)
+			goto release;
+
+		ret = hugetlb_checkpoint_page(ctx, page);
+release:
+		if (page)
+			page_cache_release(page);
+		if (ret < 0)
+			break;
+	}
+
+	if (ret < 0)
+		goto err;
+	hdr.vaddr = CKPT_HDR_HPAGE_LAST;
+	ret = ckpt_write_obj(ctx, &hdr.h);
+err:
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
+	vma_type = first ? CKPT_VMA_HUGETLB : CKPT_VMA_HUGETLB_SKIP;
+
+	ret = generic_vma_checkpoint(ctx, vma, vma_type, 0, ino_objref);
+	if (ret)
+		return ret;
+
+	if (vma_type == CKPT_VMA_HUGETLB)
+		ret = hugetlb_dump_contents(ctx, vma);
+
+	return ret;
+}
+
+int hugetlb_restore_page(struct ckpt_ctx *ctx, struct page *head)
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
+		cond_resched();
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
+static int hugetlb_restore_contents(struct ckpt_ctx *ctx)
+{
+	int ret = 0;
+
+	while (1) {
+		struct ckpt_hdr_hpage *hdr;
+		unsigned long addr;
+		struct page *page;
+		bool last;
+
+		hdr = ckpt_read_obj_type(ctx, sizeof(*hdr), CKPT_HDR_HPAGE);
+		if (IS_ERR(hdr)) {
+			ret = PTR_ERR(hdr);
+			break;
+		}
+
+		ckpt_debug_hpage_hdr(hdr);
+		last = ckpt_hdr_hpage_last(hdr);
+		addr = (unsigned long)hdr->vaddr;
+
+		ckpt_hdr_put(ctx, hdr);
+
+		if (last)
+			break;
+
+		down_read(&current->mm->mmap_sem);
+		ret = get_user_pages(current, current->mm, addr, 1, 1, 1,
+				     &page, NULL);
+		up_read(&current->mm->mmap_sem);
+
+		if (ret < 0)
+			break;
+
+		ret = hugetlb_restore_page(ctx, page);
+
+		page_cache_release(page);
+
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+
+int hugetlb_restore(struct ckpt_ctx *ctx, struct mm_struct *mm, struct ckpt_hdr_vma *hdr)
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
+		ret = hugetlb_restore_contents(ctx);
+out:
+	fput(file);
+	return ret;
+}
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
-- 
1.7.2.2
