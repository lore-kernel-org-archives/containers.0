From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/10] Introduce functions to dump mm
Date: Sat, 18 Oct 2008 03:11:34 +0400
Message-ID: <1224285098-573-7-git-send-email-major@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-2-git-send-email-major@openvz.org>
	<1224285098-573-3-git-send-email-major@openvz.org>
	<1224285098-573-4-git-send-email-major@openvz.org>
	<1224285098-573-5-git-send-email-major@openvz.org>
	<1224285098-573-6-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-6-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Functions to dump mm struct, VMAs and mm context are added.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 arch/x86/mm/hugetlbpage.c |    2 +
 checkpoint/Makefile       |    2 +-
 checkpoint/checkpoint.h   |    1 +
 checkpoint/cpt_image.h    |   61 +++++++
 checkpoint/cpt_mm.c       |  434 +++++++++++++++++++++++++++++++++++++++++++++
 checkpoint/cpt_process.c  |    8 +-
 mm/memory.c               |    1 +
 7 files changed, 504 insertions(+), 5 deletions(-)
 create mode 100644 checkpoint/cpt_mm.c

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 8f307d9..63028e7 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -12,6 +12,7 @@
 #include <linux/slab.h>
 #include <linux/err.h>
 #include <linux/sysctl.h>
+#include <linux/module.h>
 #include <asm/mman.h>
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
@@ -221,6 +222,7 @@ int pmd_huge(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_PSE);
 }
+EXPORT_SYMBOL(pmd_huge);
 
 int pud_huge(pud_t pud)
 {
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 457cc96..bbb0e37 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,4 @@ obj-y += sys_core.o
 
 obj-$(CONFIG_CHECKPOINT) += cptrst.o
 
-cptrst-objs := sys.o checkpoint.o cpt_process.o
+cptrst-objs := sys.o checkpoint.o cpt_process.o cpt_mm.o
diff --git a/checkpoint/checkpoint.h b/checkpoint/checkpoint.h
index 9e46b10..e3e6b66 100644
--- a/checkpoint/checkpoint.h
+++ b/checkpoint/checkpoint.h
@@ -61,3 +61,4 @@ extern int debug_level;
 
 int dump_container(struct cpt_context *ctx);
 int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx);
+int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx);
diff --git a/checkpoint/cpt_image.h b/checkpoint/cpt_image.h
index cddfe37..160cf85 100644
--- a/checkpoint/cpt_image.h
+++ b/checkpoint/cpt_image.h
@@ -16,13 +16,19 @@
 #include <linux/sched.h>
 #include <asm/segment.h>
 
+#define CPT_NULL (~0ULL)
+
 enum _cpt_object_type
 {
 	CPT_OBJ_TASK = 0,
+	CPT_OBJ_MM,
 	CPT_OBJ_MAX,
 	/* The objects above are stored in memory while checkpointing */
 
 	CPT_OBJ_HEAD = 1024,
+	CPT_OBJ_VMA,
+	CPT_OBJ_PAGES,
+	CPT_OBJ_NAME,
 	CPT_OBJ_X86_REGS,
 	CPT_OBJ_BITS,
 };
@@ -35,6 +41,7 @@ enum _cpt_content_type {
 	CPT_CONTENT_REF,
 	CPT_CONTENT_X86_FPUSTATE,
 	CPT_CONTENT_X86_FPUSTATE_OLD,
+	CPT_CONTENT_MM_CONTEXT,
 	CPT_CONTENT_MAX
 };
 
@@ -123,6 +130,60 @@ struct cpt_task_image {
 	__u64	cpt_maj_flt;
 } __attribute__ ((aligned (8)));
 
+struct cpt_mm_image {
+	__u64	cpt_len;
+	__u32	cpt_hdrlen;
+	__u16	cpt_type;
+	__u16	cpt_content;
+
+	__u64	cpt_start_code;
+	__u64	cpt_end_code;
+	__u64	cpt_start_data;
+	__u64	cpt_end_data;
+	__u64	cpt_start_brk;
+	__u64	cpt_brk;
+	__u64	cpt_start_stack;
+	__u64	cpt_start_arg;
+	__u64	cpt_end_arg;
+	__u64	cpt_start_env;
+	__u64	cpt_end_env;
+	__u64	cpt_def_flags;
+	__u64	cpt_flags;
+	__u64	cpt_map_count;
+} __attribute__ ((aligned (8)));
+
+struct cpt_vma_image
+{
+	__u64	cpt_len;
+	__u32	cpt_hdrlen;
+	__u16	cpt_type;
+	__u16	cpt_content;
+
+	__u64	cpt_file;
+	__u32	cpt_vma_type;
+#define CPT_VMA_TYPE_0		0
+#define CPT_VMA_FILE		1
+	__u32	cpt_pad;
+
+	__u64	cpt_start;
+	__u64	cpt_end;
+	__u64	cpt_flags;
+	__u64	cpt_pgprot;
+	__u64	cpt_pgoff;
+	__u64	cpt_page_num;
+} __attribute__ ((aligned (8)));
+
+struct cpt_page_block
+{
+	__u64	cpt_len;
+	__u32	cpt_hdrlen;
+	__u16	cpt_type;
+	__u16	cpt_content;
+
+	__u64	cpt_start;
+	__u64	cpt_end;
+} __attribute__ ((aligned (8)));
+
 struct cpt_obj_bits
 {
 	__u64	cpt_len;
diff --git a/checkpoint/cpt_mm.c b/checkpoint/cpt_mm.c
new file mode 100644
index 0000000..8a22c48
--- /dev/null
+++ b/checkpoint/cpt_mm.c
@@ -0,0 +1,434 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Authors:	Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/mm.h>
+#include <linux/errno.h>
+#include <linux/major.h>
+#include <linux/mman.h>
+#include <linux/mnt_namespace.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/pagemap.h>
+#include <linux/hugetlb.h>
+#include <asm/ldt.h>
+
+#include "checkpoint.h"
+#include "cpt_image.h"
+
+struct page_area
+{
+	int type;
+	unsigned long start;
+	unsigned long end;
+	pgoff_t pgoff;
+	loff_t mm;
+	__u64 list[16];
+};
+
+struct page_desc
+{
+	int	type;
+	pgoff_t	index;
+	loff_t	mm;
+	int	shared;
+};
+
+enum {
+	PD_ABSENT,
+	PD_COPY,
+	PD_FUNKEY,
+};
+
+/* 0: page can be obtained from backstore, or still not mapped anonymous  page,
+      or something else, which does not requre copy.
+   1: page requires copy
+   2: page requres copy but its content is zero. Quite useless.
+   3: wp page is shared after fork(). It is to be COWed when modified.
+   4: page is something unsupported... We copy it right now.
+ */
+
+static void page_get_desc(struct vm_area_struct *vma, unsigned long addr,
+			  struct page_desc *pdesc, cpt_context_t * ctx)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
+	spinlock_t *ptl;
+	struct page *pg = NULL;
+	pgoff_t linear_index = (addr - vma->vm_start)/PAGE_SIZE + vma->vm_pgoff;
+
+	pdesc->index = linear_index;
+	pdesc->shared = 0;
+	pdesc->mm = CPT_NULL;
+
+	if (vma->vm_flags & VM_IO) {
+		pdesc->type = PD_ABSENT;
+		return;
+	}
+
+	pgd = pgd_offset(mm, addr);
+	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
+		goto out_absent;
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
+		goto out_absent;
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+		goto out_absent;
+#ifdef CONFIG_X86
+	if (pmd_huge(*pmd)) {
+		eprintk("page_huge\n");
+		goto out_unsupported;
+	}
+#endif
+	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	pte = *ptep;
+	pte_unmap(ptep);
+
+	if (pte_none(pte))
+		goto out_absent_unlock;
+
+	if ((pg = vm_normal_page(vma, addr, pte)) == NULL) {
+		pdesc->type = PD_COPY;
+		goto out_unlock;
+	}
+
+	get_page(pg);
+	spin_unlock(ptl);
+
+	if (pg->mapping && !PageAnon(pg)) {
+		if (vma->vm_file == NULL) {
+			eprintk("pg->mapping!=NULL for fileless vma: %08lx\n", addr);
+			goto out_unsupported;
+		}
+		if (vma->vm_file->f_mapping != pg->mapping) {
+			eprintk("pg->mapping!=f_mapping: %08lx %p %p\n",
+				    addr, vma->vm_file->f_mapping, pg->mapping);
+			goto out_unsupported;
+		}
+		pdesc->index = (pg->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT));
+		/* Page is in backstore. For us it is like
+		 * it is not present.
+		 */
+		goto out_absent;
+	}
+
+	if (PageReserved(pg)) {
+		/* Special case: ZERO_PAGE is used, when an
+		 * anonymous page is accessed but not written. */
+		if (pg == ZERO_PAGE(addr)) {
+			if (pte_write(pte)) {
+				eprintk("not funny already, writable ZERO_PAGE\n");
+				goto out_unsupported;
+			}
+			/* Just copy it for now */
+			pdesc->type = PD_COPY;
+			goto out_put;
+		}
+		eprintk("reserved page %lu at %08lx\n", pg->index, addr);
+		goto out_unsupported;
+	}
+
+	if (!pg->mapping) {
+		eprintk("page without mapping at %08lx\n", addr);
+		goto out_unsupported;
+	}
+
+	pdesc->type = PD_COPY;
+
+out_put:
+	if (pg)
+		put_page(pg);
+	return;
+
+out_unlock:
+	spin_unlock(ptl);
+	goto out_put;
+
+out_absent_unlock:
+	spin_unlock(ptl);
+
+out_absent:
+	pdesc->type = PD_ABSENT;
+	goto out_put;
+
+out_unsupported:
+	pdesc->type = PD_FUNKEY;
+	goto out_put;
+}
+
+static int count_vma_pages(struct vm_area_struct *vma, struct cpt_context *ctx)
+{
+	unsigned long addr;
+	int page_num = 0;
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		struct page_desc pd;
+
+		page_get_desc(vma, addr, &pd, ctx);
+
+		if (pd.type != PD_COPY) {
+			return -EINVAL;
+		} else {
+			page_num += 1;
+		}
+		
+	}
+	return page_num;
+}
+
+/* ATTN: We give "current" to get_user_pages(). This is wrong, but get_user_pages()
+ * does not really need this thing. It just stores some page fault stats there.
+ *
+ * BUG: some archs (f.e. sparc64, but not Intel*) require flush cache pages
+ * before accessing vma.
+ */
+static int dump_pages(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, struct cpt_context *ctx)
+{
+#define MAX_PAGE_BATCH 16
+	struct page *pg[MAX_PAGE_BATCH];
+	int npages = (end - start)/PAGE_SIZE;
+	int count = 0;
+
+	while (count < npages) {
+		int copy = npages - count;
+		int n;
+
+		if (copy > MAX_PAGE_BATCH)
+			copy = MAX_PAGE_BATCH;
+		n = get_user_pages(current, vma->vm_mm, start, copy,
+				   0, 1, pg, NULL);
+		if (n == copy) {
+			int i;
+			for (i=0; i<n; i++) {
+				char *maddr = kmap(pg[i]);
+				ctx->write(maddr, PAGE_SIZE, ctx);
+				kunmap(pg[i]);
+			}
+		} else {
+			eprintk("get_user_pages fault");
+			for ( ; n > 0; n--)
+				page_cache_release(pg[n-1]);
+			return -EFAULT;
+		}
+		start += n*PAGE_SIZE;
+		count += n;
+		for ( ; n > 0; n--)
+			page_cache_release(pg[n-1]);
+	}
+	return 0;
+}
+
+static int dump_page_block(struct vm_area_struct *vma,
+			   struct cpt_page_block *pgb,
+			   struct cpt_context *ctx)
+{
+	int err;
+	pgb->cpt_len = sizeof(*pgb) + pgb->cpt_end - pgb->cpt_start;
+	pgb->cpt_type = CPT_OBJ_PAGES;
+	pgb->cpt_hdrlen = sizeof(*pgb);
+	pgb->cpt_content = CPT_CONTENT_DATA;
+
+	err = ctx->write(pgb, sizeof(*pgb), ctx);
+	if (!err)
+		err = dump_pages(vma, pgb->cpt_start, pgb->cpt_end, ctx);
+
+	return err;
+}
+
+static int cpt_dump_dentry(struct path *p, cpt_context_t *ctx)
+{
+	int len;
+	char *path;
+	char *buf;
+	struct cpt_object_hdr o;
+
+	buf = (char *)__get_free_page(GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	path = d_path(p, buf, PAGE_SIZE);
+
+	if (IS_ERR(path)) {
+		free_page((unsigned long)buf);
+		return PTR_ERR(path);
+	}
+
+	len = buf + PAGE_SIZE - 1 - path;
+	o.cpt_len = sizeof(o) + len + 1;
+	o.cpt_type = CPT_OBJ_NAME;
+	o.cpt_hdrlen = sizeof(o);
+	o.cpt_content = CPT_CONTENT_NAME;
+	path[len] = 0;
+
+	ctx->write(&o, sizeof(o), ctx);
+	ctx->write(path, len + 1, ctx);
+	free_page((unsigned long)buf);
+
+	return 0;
+}
+
+static int dump_one_vma(struct mm_struct *mm,
+			struct vm_area_struct *vma, struct cpt_context *ctx)
+{
+	struct cpt_vma_image *v;
+	unsigned long addr;
+	int page_num;
+	int err;
+
+	v = kzalloc(sizeof(*v), GFP_KERNEL);
+	if (!v)
+		return -ENOMEM;
+
+	v->cpt_len = sizeof(*v);
+	v->cpt_type = CPT_OBJ_VMA;
+	v->cpt_hdrlen = sizeof(*v);
+	v->cpt_content = CPT_CONTENT_ARRAY;
+
+	v->cpt_start = vma->vm_start;
+	v->cpt_end = vma->vm_end;
+	v->cpt_flags = vma->vm_flags;
+	if (vma->vm_flags & VM_HUGETLB) {
+		eprintk("huge TLB VMAs are still not supported\n");
+		kfree(v);
+		return -EINVAL;
+	}
+	v->cpt_pgprot = vma->vm_page_prot.pgprot;
+	v->cpt_pgoff = vma->vm_pgoff;
+	v->cpt_file = CPT_NULL;
+	v->cpt_vma_type = CPT_VMA_TYPE_0;
+
+	page_num = count_vma_pages(vma, ctx);
+	if (page_num < 0) {
+		kfree(v);
+		return -EINVAL;
+	}
+	v->cpt_page_num = page_num;
+
+	if (vma->vm_file) {
+		v->cpt_file = 0;
+		v->cpt_vma_type = CPT_VMA_FILE;
+	}
+
+	ctx->write(v, sizeof(*v), ctx);
+	kfree(v);
+
+	if (vma->vm_file) {
+		err = cpt_dump_dentry(&vma->vm_file->f_path, ctx);
+		if (err < 0)
+			return err;
+	}
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		struct page_desc pd;
+		struct cpt_page_block pgb;
+
+		page_get_desc(vma, addr, &pd, ctx);
+
+		if (pd.type == PD_FUNKEY || pd.type == PD_ABSENT) {
+			eprintk("dump_one_vma: funkey page\n");
+			return -EINVAL;
+		}
+
+		pgb.cpt_start = addr;
+		pgb.cpt_end = addr + PAGE_SIZE;
+		dump_page_block(vma, &pgb, ctx);
+	}
+
+	return 0;
+}
+
+static int cpt_dump_mm_context(struct mm_struct *mm, struct cpt_context *ctx)
+{
+#ifdef CONFIG_X86
+	if (mm->context.size) {
+		struct cpt_obj_bits b;
+		int size;
+
+		mutex_lock(&mm->context.lock);
+
+		b.cpt_type = CPT_OBJ_BITS;
+		b.cpt_len = sizeof(b);
+		b.cpt_content = CPT_CONTENT_MM_CONTEXT;
+		b.cpt_size = mm->context.size * LDT_ENTRY_SIZE;
+
+		ctx->write(&b, sizeof(b), ctx);
+
+		size = mm->context.size * LDT_ENTRY_SIZE;
+
+		ctx->write(mm->context.ldt, size, ctx);
+
+		mutex_unlock(&mm->context.lock);
+	}
+#endif
+	return 0;
+}
+
+int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx)
+{
+	struct mm_struct *mm = tsk->mm;
+	struct cpt_mm_image *v;
+	struct vm_area_struct *vma;
+	int err;
+
+	v = kzalloc(sizeof(*v), GFP_KERNEL);
+	if (!v)
+		return -ENOMEM;
+
+	v->cpt_len = sizeof(*v);
+	v->cpt_type = CPT_OBJ_MM;
+	v->cpt_hdrlen = sizeof(*v);
+	v->cpt_content = CPT_CONTENT_ARRAY;
+
+	down_read(&mm->mmap_sem);
+	v->cpt_start_code = mm->start_code;
+	v->cpt_end_code = mm->end_code;
+	v->cpt_start_data = mm->start_data;
+	v->cpt_end_data = mm->end_data;
+	v->cpt_start_brk = mm->start_brk;
+	v->cpt_brk = mm->brk;
+	v->cpt_start_stack = mm->start_stack;
+	v->cpt_start_arg = mm->arg_start;
+	v->cpt_end_arg = mm->arg_end;
+	v->cpt_start_env = mm->env_start;
+	v->cpt_end_env = mm->env_end;
+	v->cpt_def_flags = mm->def_flags;
+	v->cpt_flags = mm->flags;
+	v->cpt_map_count = mm->map_count;
+
+	err = ctx->write(v, sizeof(*v), ctx);
+	kfree(v);
+	
+	if (err) {
+		eprintk("error during writing mm\n");
+		goto err_up;
+	}
+	
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if ((err = dump_one_vma(mm, vma, ctx)) != 0)
+			goto err_up;
+	}
+
+	err = cpt_dump_mm_context(mm, ctx);
+
+err_up:
+	up_read(&mm->mmap_sem);
+
+	return err;
+}
+
diff --git a/checkpoint/cpt_process.c b/checkpoint/cpt_process.c
index 58f608d..1f7a54b 100644
--- a/checkpoint/cpt_process.c
+++ b/checkpoint/cpt_process.c
@@ -225,12 +225,12 @@ int cpt_dump_task(struct task_struct *tsk, struct cpt_context *ctx)
 
 	err = cpt_dump_task_struct(tsk, ctx);
 
-	/* Dump task mm */
-
 	if (!err)
-		cpt_dump_fpustate(tsk, ctx);
+		err = cpt_dump_mm(tsk, ctx);
+	if (!err)
+		err = cpt_dump_fpustate(tsk, ctx);
 	if (!err)
-		cpt_dump_registers(tsk, ctx);
+		err = cpt_dump_registers(tsk, ctx);
 
 	return err;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 1002f47..479a294 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -481,6 +481,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 out:
 	return pfn_to_page(pfn);
 }
+EXPORT_SYMBOL(vm_normal_page);
 
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
-- 
1.5.6
