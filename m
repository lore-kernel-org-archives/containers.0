From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Wed, 20 Aug 2008 23:05:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808202304490.17436__22913.7583439753$1219288100$gmane$org@takamine.ncl.cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202251500.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org


For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
it will be followed by the file name.  The cr_vma->npages will tell
how many pages were dumped for this VMA.  Then it will be followed
by the actual data: first a dump of the addresses of all dumped
pages (npages entries) followed by a dump of the contents of all
dumped pages (npages pages). Then will come the next VMA and so on.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  checkpoint/Makefile     |    2 +-
  checkpoint/checkpoint.c |    3 +
  checkpoint/ckpt.h       |    6 +
  checkpoint/ckpt_arch.h  |    1 +
  checkpoint/ckpt_hdr.h   |   31 ++++
  checkpoint/ckpt_mem.c   |  382 +++++++++++++++++++++++++++++++++++++++++++++++
  checkpoint/ckpt_mem.h   |   30 ++++
  checkpoint/ckpt_x86.c   |   28 ++++
  checkpoint/rstr_x86.c   |    2 +
  checkpoint/sys.c        |    7 +-
  include/asm-x86/ckpt.h  |    5 +
  11 files changed, 495 insertions(+), 2 deletions(-)
  create mode 100644 checkpoint/ckpt_mem.c
  create mode 100644 checkpoint/ckpt_mem.h

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 29dbb2d..032fc9f 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -1,2 +1,2 @@
-obj-y += sys.o checkpoint.o restart.o
+obj-y += sys.o checkpoint.o restart.o ckpt_mem.o
  obj-$(CONFIG_X86) += ckpt_x86.o rstr_x86.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 949ed58..bf868ae 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -169,6 +169,9 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
  	ret = cr_write_task_struct(ctx, t);
  	cr_debug("task_struct: ret %d\n", ret);
  	if (!ret)
+		ret = cr_write_mm(ctx, t);
+	cr_debug("memory: ret %d\n", ret);
+	if (!ret)
  		ret = cr_write_thread(ctx, t);
  	cr_debug("thread: ret %d\n", ret);
  	if (!ret)
diff --git a/checkpoint/ckpt.h b/checkpoint/ckpt.h
index 7ecafb3..0addb63 100644
--- a/checkpoint/ckpt.h
+++ b/checkpoint/ckpt.h
@@ -29,6 +29,9 @@ struct cr_ctx {
  	void *hbuf;		/* header: to avoid many alloc/dealloc */
  	int hpos;

+	struct cr_pgarr *pgarr;
+	struct cr_pgarr *pgcur;
+
  	struct path *vfsroot;	/* container root */
  };

@@ -62,6 +65,9 @@ int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
  int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
  int cr_read_str(struct cr_ctx *ctx, void *str, int n);

+int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
+int cr_read_mm(struct cr_ctx *ctx);
+
  int do_checkpoint(struct cr_ctx *ctx);
  int do_restart(struct cr_ctx *ctx);

diff --git a/checkpoint/ckpt_arch.h b/checkpoint/ckpt_arch.h
index b7cc8c9..3b87a6f 100644
--- a/checkpoint/ckpt_arch.h
+++ b/checkpoint/ckpt_arch.h
@@ -2,6 +2,7 @@

  int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
  int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int ptag);

  int cr_read_thread(struct cr_ctx *ctx);
  int cr_read_cpu(struct cr_ctx *ctx);
diff --git a/checkpoint/ckpt_hdr.h b/checkpoint/ckpt_hdr.h
index a478b7c..a3919cf 100644
--- a/checkpoint/ckpt_hdr.h
+++ b/checkpoint/ckpt_hdr.h
@@ -30,6 +30,7 @@ struct cr_hdr {
  	__u32 ptag;
  };

+/* header types */
  enum {
  	CR_HDR_HEAD = 1,
  	CR_HDR_STR,
@@ -45,6 +46,12 @@ enum {
  	CR_HDR_TAIL = 5001
  };

+/* vma subtypes */
+enum {
+	CR_VMA_ANON = 1,
+	CR_VMA_FILE
+};
+
  struct cr_hdr_head {
  	__u64 magic;

@@ -83,4 +90,28 @@ struct cr_hdr_task {
  	char comm[TASK_COMM_LEN];
  } __attribute__ ((aligned (8)));

+struct cr_hdr_mm {
+	__u32 tag;	/* sharing identifier */
+	__s16 map_count;
+	__s16 _padding;
+
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+
+} __attribute__ ((aligned (8)));
+
+struct cr_hdr_vma {
+	__u32 how;
+	__s16 npages;
+	__u16 fname;
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+
+} __attribute__ ((aligned (8)));
+
  #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
new file mode 100644
index 0000000..a23aa29
--- /dev/null
+++ b/checkpoint/ckpt_mem.c
@@ -0,0 +1,382 @@
+/*
+ *  Checkpoint memory contents
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+#include "ckpt_arch.h"
+#include "ckpt_mem.h"
+
+/*
+ * utilities to alloc, free, and handle 'struct cr_pgarr'
+ * (common to ckpt_mem.c and rstr_mem.c)
+ */
+
+#define CR_PGARR_ORDER  0
+#define CR_PGARR_TOTAL  ((PAGE_SIZE << CR_PGARR_ORDER) / sizeof(void *))
+
+/* release pages referenced by a page-array */
+void _cr_pgarr_release(struct cr_ctx *ctx, struct cr_pgarr *pgarr)
+{
+	int n;
+
+	/* only checkpoint keeps references to pages */
+	if (ctx->flags & CR_CTX_CKPT) {
+		cr_debug("nused %d\n", pgarr->nused);
+		for (n = pgarr->nused; n--; )
+			page_cache_release(pgarr->pages[n]);
+	}
+	pgarr->nused = 0;
+	pgarr->nleft = CR_PGARR_TOTAL;
+}
+
+/* release pages referenced by chain of page-arrays */
+void cr_pgarr_release(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next)
+		_cr_pgarr_release(ctx, pgarr);
+}
+
+/* free a chain of page-arrays */
+void cr_pgarr_free(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr, *pgnxt;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgnxt) {
+		_cr_pgarr_release(ctx, pgarr);
+		free_pages((unsigned long) ctx->pgarr->addrs, CR_PGARR_ORDER);
+		free_pages((unsigned long) ctx->pgarr->pages, CR_PGARR_ORDER);
+		pgnxt = pgarr->next;
+		kfree(pgarr);
+	}
+}
+
+/* allocate and add a new page-array to chain */
+struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx, struct cr_pgarr **pgnew)
+{
+	struct cr_pgarr *pgarr = ctx->pgcur;
+
+	if (pgarr && pgarr->next) {
+		ctx->pgcur = pgarr->next;
+		return pgarr->next;
+	}
+
+	if ((pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL))) {
+		pgarr->nused = 0;
+		pgarr->nleft = CR_PGARR_TOTAL;
+		pgarr->addrs = (unsigned long *)
+			__get_free_pages(GFP_KERNEL, CR_PGARR_ORDER);
+		pgarr->pages = (struct page **)
+			__get_free_pages(GFP_KERNEL, CR_PGARR_ORDER);
+		if (likely(pgarr->addrs && pgarr->pages)) {
+			*pgnew = pgarr;
+			ctx->pgcur = pgarr;
+			return pgarr;
+		} else if (pgarr->addrs)
+			free_pages((unsigned long) pgarr->addrs,
+				   CR_PGARR_ORDER);
+		kfree(pgarr);
+	}
+
+	return NULL;
+}
+
+/* return current page-array (and allocate if needed) */
+struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr = ctx->pgcur;
+
+	if (unlikely(!pgarr->nleft))
+		pgarr = cr_pgarr_alloc(ctx, &pgarr->next);
+	return pgarr;
+}
+
+/*
+ * Checkpoint is outside the context of the checkpointee, so one cannot
+ * simply read pages from user-space. Instead, we scan the address space
+ * of the target to cherry-pick pages of interest. Selected pages are
+ * enlisted in a page-array chain (attached to the checkpoint context).
+ * To save their contents, each page is mapped to kernel memory and then
+ * dumped to the file descriptor.
+ */
+
+/**
+ * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
+ * @ctx - checkpoint context
+ * @pgarr - page-array to fill
+ * @vma - vma to scan
+ * @start - start address (updated)
+ */
+static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
+			     struct vm_area_struct *vma, unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	struct page **pagep;
+	unsigned long *addrp;
+	int cow, nr, ret = 0;
+
+	nr = pgarr->nleft;
+	pagep = &pgarr->pages[pgarr->nused];
+	addrp = &pgarr->addrs[pgarr->nused];
+	cow = !!vma->vm_file;
+
+	while (addr < end) {
+		struct page *page;
+
+		/* simplified version of get_user_pages(): already have vma,
+		* only need FOLL_TOUCH, and (for now) ignore fault stats */
+
+		cond_resched();
+		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
+			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+			if (ret & VM_FAULT_ERROR) {
+				if (ret & VM_FAULT_OOM)
+					ret = -ENOMEM;
+				else if (ret & VM_FAULT_SIGBUS)
+					ret = -EFAULT;
+				else
+					BUG();
+				break;
+			}
+			cond_resched();
+		}
+
+		if (IS_ERR(page)) {
+			ret = PTR_ERR(page);
+			break;
+		}
+
+		if (page == ZERO_PAGE(0))
+			page = NULL;	/* zero page: ignore */
+		else if (cow && page_mapping(page) != NULL)
+			page = NULL;	/* clean cow: ignore */
+		else {
+			get_page(page);
+			*(addrp++) = addr;
+			*(pagep++) = page;
+			if (--nr == 0) {
+				addr += PAGE_SIZE;
+				break;
+			}
+		}
+
+		addr += PAGE_SIZE;
+	}
+
+	if (unlikely(ret < 0)) {
+		nr = pgarr->nleft - nr;
+		while (nr--)
+			page_cache_release(*(--pagep));
+		return ret;
+	}
+
+	*start = addr;
+	return (pgarr->nleft - nr);
+}
+
+/**
+ * cr_vma_scan_pages - scan vma for pages that will need to be dumped
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ * a list of addr/page tuples is kept in ctx->pgarr page-array chain
+ */
+static int cr_vma_scan_pages(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	unsigned long addr = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	struct cr_pgarr *pgarr;
+	int nr, total = 0;
+
+	while (addr < end) {
+		if (!(pgarr = cr_pgarr_prep(ctx)))
+			return -ENOMEM;
+		if ((nr = cr_vma_fill_pgarr(ctx, pgarr, vma, &addr)) < 0)
+			return nr;
+		pgarr->nleft -= nr;
+		pgarr->nused += nr;
+		total += nr;
+	}
+
+	cr_debug("total %d\n", total);
+	return total;
+}
+
+/**
+ * cr_vma_dump_pages - dump pages listed in the ctx page-array chain
+ * @ctx - checkpoint context
+ * @total - total number of pages
+ */
+static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
+{
+	struct cr_pgarr *pgarr;
+	int ret;
+
+	if (!total)
+		return 0;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
+		ret = cr_kwrite(ctx, pgarr->addrs,
+			       pgarr->nused * sizeof(*pgarr->addrs));
+		if (ret < 0)
+			return ret;
+	}
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
+		struct page **pages = pgarr->pages;
+		int nr = pgarr->nused;
+		void *ptr;
+
+		while (nr--) {
+			ptr = kmap(*pages);
+			ret = cr_kwrite(ctx, ptr, PAGE_SIZE);
+			kunmap(*pages);
+			if (ret < 0)
+				return ret;
+			pages++;
+		}
+	}
+
+	return total;
+}
+
+static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct cr_hdr h;
+	struct cr_hdr_vma *hh = ctx->hbuf;
+	char *fname = NULL;
+	int flen = 0, how, nr, ret;
+
+	h.type = CR_HDR_VMA;
+	h.len = sizeof(*hh);
+	h.ptag = 0;
+
+	hh->vm_start = vma->vm_start;
+	hh->vm_end = vma->vm_end;
+	hh->vm_page_prot = vma->vm_page_prot.pgprot;
+	hh->vm_flags = vma->vm_flags;
+	hh->vm_pgoff = vma->vm_pgoff;
+
+	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
+		pr_warning("CR: unknown VMA %#lx\n", vma->vm_flags);
+		return -ETXTBSY;
+	}
+
+	/* by default assume anon memory */
+	how = CR_VMA_ANON;
+
+	/* if there is a backing file, assume private-mapped */
+	/* (NEED: check if the file is unlinked) */
+	if (vma->vm_file) {
+		flen = PAGE_SIZE;
+		fname = cr_fill_fname(&vma->vm_file->f_path,
+				      ctx->vfsroot, ctx->tbuf, &flen);
+		if (IS_ERR(fname))
+			return PTR_ERR(fname);
+		how = CR_VMA_FILE;
+	}
+
+	hh->how = how;
+	hh->fname = !!fname;
+
+	/*
+	 * it seems redundant now, but we do it in 3 steps for because:
+	 * first, the logic is simpler when we how many pages before
+	 * dumping them; second, a future optimization will defer the
+	 * writeout (dump, and free) to a later step; in which case all
+	 * the pages to be dumped will be aggregated on the checkpoint ctx
+	 */
+
+	/* (1) scan: scan through the PTEs of the vma to count the pages
+	 * to dump (and later make those pages COW), and keep the list of
+	 * pages (and a reference to each page) on the checkpoint ctx */
+	nr = cr_vma_scan_pages(ctx, vma);
+	if (nr < 0)
+		return nr;
+
+	hh->npages = nr;
+	ret = cr_write_obj(ctx, &h, hh);
+
+	if (!ret && flen)
+		ret = cr_write_str(ctx, fname, flen);
+
+	if (ret < 0)
+		return ret;
+
+	/* (2) dump: write out the addresses of all pages in the list (on
+	 * the checkpoint ctx) followed by the contents of all pages */
+	ret = cr_vma_dump_pages(ctx, nr);
+
+	/* (3) free: free the extra references to the pages in the list */
+	cr_pgarr_release(ctx);
+
+	return ret;
+}
+
+int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm *hh = ctx->hbuf;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int ret;
+
+	h.type = CR_HDR_MM;
+	h.len = sizeof(*hh);
+	h.ptag = task_pid_vnr(t);
+
+	mm = get_task_mm(t);
+
+	hh->tag = 1;	/* dummy for now; meaningful with multiple tasks */
+
+	down_read(&mm->mmap_sem);
+
+	hh->start_code = mm->start_code;
+	hh->end_code = mm->end_code;
+	hh->start_data = mm->start_data;
+	hh->end_data = mm->end_data;
+	hh->start_brk = mm->start_brk;
+	hh->brk = mm->brk;
+	hh->start_stack = mm->start_stack;
+	hh->arg_start = mm->arg_start;
+	hh->arg_end = mm->arg_end;
+	hh->env_start = mm->env_start;
+	hh->env_end = mm->env_end;
+
+	hh->map_count = mm->map_count;
+
+	/* FIX: need also mm->flags */
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	/* write the vma's */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if ((ret = cr_write_vma(ctx, vma)) < 0)
+			goto out;
+	}
+
+	ret = cr_write_mm_context(ctx, mm, hh->tag);
+
+ out:
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+	return ret;
+}
diff --git a/checkpoint/ckpt_mem.h b/checkpoint/ckpt_mem.h
new file mode 100644
index 0000000..83d1cfc
--- /dev/null
+++ b/checkpoint/ckpt_mem.h
@@ -0,0 +1,30 @@
+#ifndef _CHECKPOINT_CKPT_MEM_H_
+#define _CHECKPOINT_CKPT_MEM_H_
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/mm_types.h>
+
+/* page-array chains: each pgarr holds a list of <addr,page> tuples */
+struct cr_pgarr {
+	unsigned long *addrs;
+	struct page **pages;
+	struct cr_pgarr *next;
+	unsigned short nleft;
+	unsigned short nused;
+};
+
+void _cr_pgarr_release(struct cr_ctx *ctx, struct cr_pgarr *pgarr);
+void cr_pgarr_release(struct cr_ctx *ctx);
+void cr_pgarr_free(struct cr_ctx *ctx);
+struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx, struct cr_pgarr **pgnew);
+struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx);
+
+#endif /* _CHECKPOINT_CKPT_MEM_H_ */
diff --git a/checkpoint/ckpt_x86.c b/checkpoint/ckpt_x86.c
index ad6c8e8..b365fff 100644
--- a/checkpoint/ckpt_x86.c
+++ b/checkpoint/ckpt_x86.c
@@ -188,3 +188,31 @@ int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t)

  	return cr_write_obj(ctx, &h, hh);
  }
+
+int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int ptag)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm_context *hh = ctx->hbuf;
+	int ret;
+
+	h.type = CR_HDR_MM_CONTEXT;
+	h.len = sizeof(*hh);
+	h.ptag = ptag;
+
+	mutex_lock(&mm->context.lock);
+
+	hh->ldt_entry_size = LDT_ENTRY_SIZE;
+	hh->nldt = mm->context.size;
+
+	cr_debug("nldt %d\n", hh->nldt);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		return ret;
+
+	ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
+
+	mutex_unlock(&mm->context.lock);
+
+	return ret;
+}
diff --git a/checkpoint/rstr_x86.c b/checkpoint/rstr_x86.c
index a24a7de..86b6c83 100644
--- a/checkpoint/rstr_x86.c
+++ b/checkpoint/rstr_x86.c
@@ -8,6 +8,8 @@
   *  distribution for more details.
   */

+#include <asm/unistd.h>
+
  #include <asm/ckpt.h>
  #include <asm/desc.h>
  #include <asm/i387.h>
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 2891c48..eec5032 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -15,6 +15,7 @@
  #include <linux/capability.h>

  #include "ckpt.h"
+#include "ckpt_mem.h"

  /*
   * helpers to write/read to/from the image file descriptor
@@ -112,7 +113,6 @@ static atomic_t cr_ctx_count;	/* unique checkpoint identifier */

  void cr_ctx_free(struct cr_ctx *ctx)
  {
-
  	if (ctx->file)
  		fput(ctx->file);
  	if (ctx->vfsroot)
@@ -121,6 +121,8 @@ void cr_ctx_free(struct cr_ctx *ctx)
  	free_pages((unsigned long) ctx->tbuf, CR_TBUF_ORDER);
  	free_pages((unsigned long) ctx->hbuf, CR_HBUF_ORDER);

+	cr_pgarr_free(ctx);
+
  	kfree(ctx);
  }

@@ -137,6 +139,9 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, struct file *file, unsigned long flags)
  	if (!ctx->tbuf || !ctx->hbuf)
  		goto nomem;

+	if (!cr_pgarr_alloc(ctx, &ctx->pgarr))
+		goto nomem;
+
  	ctx->pid = pid;
  	ctx->flags = flags;

diff --git a/include/asm-x86/ckpt.h b/include/asm-x86/ckpt.h
index cd74657..a2d98fb 100644
--- a/include/asm-x86/ckpt.h
+++ b/include/asm-x86/ckpt.h
@@ -69,4 +69,9 @@ struct cr_hdr_cpu {

  } __attribute__ ((aligned (8)));

+struct cr_hdr_mm_context {
+	__s16 ldt_entry_size;
+	__s16 nldt;
+} __attribute__ ((aligned (8)));
+
  #endif /* __ASM_X86_CKPT_H */
-- 
1.5.4.3
