From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 5/9] Memory managemnet - restore state
Date: Wed, 20 Aug 2008 23:05:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808202305210.17436__42908.4590090953$1219288137$gmane$org@takamine.ncl.cs.columbia.edu>
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


Restoring the memory address space begins with nuking the existing one
of the current process, and then reading the VMA state and contents.
Call do_mmap_pgoffset() for each VMA and then read in the data.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  checkpoint/Makefile    |    2 +-
  checkpoint/ckpt_arch.h |    1 +
  checkpoint/restart.c   |    3 +
  checkpoint/rstr_mem.c  |  356 ++++++++++++++++++++++++++++++++++++++++++++++++
  checkpoint/rstr_x86.c  |   55 ++++++++
  5 files changed, 416 insertions(+), 1 deletions(-)
  create mode 100644 checkpoint/rstr_mem.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 032fc9f..41e0877 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -1,2 +1,2 @@
-obj-y += sys.o checkpoint.o restart.o ckpt_mem.o
+obj-y += sys.o checkpoint.o restart.o ckpt_mem.o rstr_mem.o
  obj-$(CONFIG_X86) += ckpt_x86.o rstr_x86.o
diff --git a/checkpoint/ckpt_arch.h b/checkpoint/ckpt_arch.h
index 3b87a6f..ab7ac1c 100644
--- a/checkpoint/ckpt_arch.h
+++ b/checkpoint/ckpt_arch.h
@@ -6,3 +6,4 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int ptag);

  int cr_read_thread(struct cr_ctx *ctx);
  int cr_read_cpu(struct cr_ctx *ctx);
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int ptag);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index a85f48b..81ce0a4 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -183,6 +183,9 @@ static int cr_read_task(struct cr_ctx *ctx)
  	ret = cr_read_task_struct(ctx);
  	cr_debug("task_struct: ret %d\n", ret);
  	if (!ret)
+		ret = cr_read_mm(ctx);
+	cr_debug("memory: ret %d\n", ret);
+	if (!ret)
  		ret = cr_read_thread(ctx);
  	cr_debug("thread: ret %d\n", ret);
  	if (!ret)
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
new file mode 100644
index 0000000..df602a9
--- /dev/null
+++ b/checkpoint/rstr_mem.c
@@ -0,0 +1,356 @@
+/*
+ *  Restart memory contents
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
+#include <linux/fcntl.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/mm_types.h>
+#include <linux/mman.h>
+#include <linux/mm.h>
+#include <linux/err.h>
+#include <asm/cacheflush.h>
+
+#include "ckpt.h"
+#include "ckpt_arch.h"
+#include "ckpt_hdr.h"
+#include "ckpt_mem.h"
+
+/*
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read in directly to the address space of the current process
+ */
+
+/**
+ * cr_vma_read_pages_addr - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_addr(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	int nr, ret;
+
+	while (npages) {
+		if (!(pgarr = cr_pgarr_prep(ctx)))
+			return -ENOMEM;
+		nr = min(npages, (int) pgarr->nleft);
+		ret = cr_kread(ctx, pgarr->addrs, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nleft -= nr;
+		pgarr->nused += nr;
+		npages -= nr;
+	}
+	return 0;
+}
+
+/**
+ * cr_vma_read_pages_data - read in data of pages in page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_data(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	unsigned long *addrs;
+	int nr, ret;
+
+	for (pgarr = ctx->pgarr; npages; pgarr = pgarr->next) {
+		addrs = pgarr->addrs;
+		nr = pgarr->nused;
+		npages -= nr;
+		while (nr--) {
+			ret = cr_uread(ctx, (void *) *(addrs++), PAGE_SIZE);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return 0;
+}
+
+/* change the protection of an address range to be writable/non-writable.
+ * this is useful when restoring the memory of a read-only vma */
+static int cr_vma_writable(struct mm_struct *mm, unsigned long start,
+			   unsigned long end, int writable)
+{
+	struct vm_area_struct *vma, *prev;
+	unsigned long flags = 0;
+	int ret = -EINVAL;
+
+	cr_debug("vma %#lx-%#lx writable %d\n", start, end, writable);
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma_prev(mm, start, &prev);
+	if (unlikely(!vma || vma->vm_start > end || vma->vm_end < start))
+		goto out;
+	if (writable && !(vma->vm_flags & VM_WRITE))
+		flags = vma->vm_flags | VM_WRITE;
+	else if (!writable && (vma->vm_flags & VM_WRITE))
+		flags = vma->vm_flags & ~VM_WRITE;
+	cr_debug("flags %#lx\n", flags);
+	if (flags)
+		ret = mprotect_fixup(vma, &prev, vma->vm_start,
+				     vma->vm_end, flags);
+ out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
+/**
+ * cr_vma_read_pages - read in pages for to restore a vma
+ * @ctx - restart context
+ * @cr_vma - vma descriptor from restart
+ */
+static int cr_vma_read_pages(struct cr_ctx *ctx, struct cr_hdr_vma *cr_vma)
+{
+	struct mm_struct *mm = current->mm;
+	int ret = 0;
+
+	if (!cr_vma->npages)
+		return 0;
+
+	/* in the unlikely case that this vma is read-only */
+	if (!(cr_vma->vm_flags & VM_WRITE))
+		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 1);
+
+	if (!ret)
+		ret = cr_vma_read_pages_addr(ctx, cr_vma->npages);
+	if (!ret)
+		ret = cr_vma_read_pages_data(ctx, cr_vma->npages);
+	if (ret < 0)
+		return ret;
+
+	cr_pgarr_release(ctx);	/* reset page-array chain */
+
+	/* restore original protection for this vma */
+	if (!(cr_vma->vm_flags & VM_WRITE))
+		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 0);
+
+	return ret;
+}
+
+/**
+ * cr_calc_map_prot_bits - convert vm_flags to mmap protection
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long cr_calc_map_prot_bits(unsigned long orig_vm_flags)
+{
+	unsigned long vm_prot = 0;
+
+	if (orig_vm_flags & VM_READ)
+		vm_prot |= PROT_READ;
+	if (orig_vm_flags & VM_WRITE)
+		vm_prot |= PROT_WRITE;
+	if (orig_vm_flags & VM_EXEC)
+		vm_prot |= PROT_EXEC;
+	if (orig_vm_flags & PROT_SEM)   /* only (?) with IPC-SHM  */
+		vm_prot |= PROT_SEM;
+
+	return vm_prot;
+}
+
+/**
+ * cr_calc_map_flags_bits - convert vm_flags to mmap flags
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long cr_calc_map_flags_bits(unsigned long orig_vm_flags)
+{
+	unsigned long vm_flags = 0;
+
+	vm_flags = MAP_FIXED;
+	if (orig_vm_flags & VM_GROWSDOWN)
+		vm_flags |= MAP_GROWSDOWN;
+	if (orig_vm_flags & VM_DENYWRITE)
+		vm_flags |= MAP_DENYWRITE;
+	if (orig_vm_flags & VM_EXECUTABLE)
+		vm_flags |= MAP_EXECUTABLE;
+	if (orig_vm_flags & VM_MAYSHARE)
+		vm_flags |= MAP_SHARED;
+	else
+		vm_flags |= MAP_PRIVATE;
+
+	return vm_flags;
+}
+
+static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	unsigned long vm_size, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+	unsigned long flags;
+	struct file *file = NULL;
+	char *fname = NULL;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
+	if (ret < 0)
+		return ret;
+	else if (ret != 0)
+		return -EINVAL;
+
+	cr_debug("vma %#lx-%#lx npages %d\n", (unsigned long) hh->vm_start,
+		 (unsigned long) hh->vm_end, (int) hh->npages);
+
+	if (hh->vm_end < hh->vm_start || hh->npages < 0)
+		return -EINVAL;
+
+	vm_size = hh->vm_end - hh->vm_start;
+	vm_prot = cr_calc_map_prot_bits(hh->vm_flags);
+	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
+	vm_pgoff = hh->vm_pgoff;
+
+	if (hh->fname) {
+		fname = ctx->tbuf;
+		ret = cr_read_str(ctx, fname, PAGE_SIZE);
+		if (ret < 0)
+			return ret;
+	}
+
+	cr_debug("vma fname '%s' how %d\n", fname, hh->how);
+
+	switch (hh->how) {
+
+	case CR_VMA_ANON:		/* anonymous private mapping */
+		if (hh->fname)
+			return -EINVAL;
+		/* vm_pgoff for anonymous mapping is the "global" page
+		   offset (namely from addr 0x0), so we force a zero */
+		vm_pgoff = 0;
+		break;
+
+	case CR_VMA_FILE:		/* private mapping from a file */
+		if (!hh->fname)
+			return -EINVAL;
+		/* O_RDWR only needed if both (VM_WRITE|VM_SHARED) are set */
+		flags = hh->vm_flags & (VM_WRITE | VM_SHARED);
+		flags = (flags == (VM_WRITE | VM_SHARED) ? O_RDWR : O_RDONLY);
+		file = filp_open(fname, flags, 0);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+		break;
+
+	default:
+		return -EINVAL;
+
+	}
+
+	addr = do_mmap_pgoff(file, (unsigned long) hh->vm_start,
+			     vm_size, vm_prot, vm_flags, vm_pgoff);
+	cr_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
+		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	/* the file (if opened) is now referenced by the vma */
+	if (file)
+		filp_close(file, NULL);
+
+	if (IS_ERR((void*) addr))
+		return (PTR_ERR((void *) addr));
+
+	/*
+	 * CR_VMA_ANON: read in memory as is
+	 * CR_VMA_FILE: read in memory as is
+	 * (more to follow ...)
+	 */
+
+	switch (hh->how) {
+	case CR_VMA_ANON:
+	case CR_VMA_FILE:
+		/* standard case: read the data into the memory */
+		ret = cr_vma_read_pages(ctx, hh);
+		break;
+	}
+
+	if (ret < 0)
+		return ret;
+
+	if (vm_prot & PROT_EXEC)
+		flush_icache_range(hh->vm_start, hh->vm_end);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	cr_debug("vma retval %d\n", ret);
+	return 0;
+}
+
+static int cr_destroy_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
+int cr_read_mm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct mm_struct *mm;
+	int nr, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
+	if (ret < 0)
+		return ret;
+#if 0	/* activate when containers are used */
+	if (ret != task_pid_vnr(current))
+		return -EINVAL;
+#endif
+	cr_debug("map_count %d\n", hh->map_count);
+
+	/* XXX need more sanity checks */
+	if (hh->start_code > hh->end_code ||
+	    hh->start_data > hh->end_data || hh->map_count < 0)
+		return -EINVAL;
+
+	mm = current->mm;
+
+	/* point of no return -- destruct current mm */
+	down_write(&mm->mmap_sem);
+	ret = cr_destroy_mm(mm);
+	up_write(&mm->mmap_sem);
+
+	if (ret < 0)
+		return ret;
+
+	mm->start_code = hh->start_code;
+	mm->end_code = hh->end_code;
+	mm->start_data = hh->start_data;
+	mm->end_data = hh->end_data;
+	mm->start_brk = hh->start_brk;
+	mm->brk = hh->brk;
+	mm->start_stack = hh->start_stack;
+	mm->arg_start = hh->arg_start;
+	mm->arg_end = hh->arg_end;
+	mm->env_start = hh->env_start;
+	mm->env_end = hh->env_end;
+
+	/* FIX: need also mm->flags */
+
+	for (nr = hh->map_count; nr; nr--) {
+		ret = cr_read_vma(ctx, mm);
+		if (ret < 0)
+			return ret;
+	}
+
+	ret = cr_read_mm_context(ctx, mm, hh->tag);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff --git a/checkpoint/rstr_x86.c b/checkpoint/rstr_x86.c
index 86b6c83..918df5c 100644
--- a/checkpoint/rstr_x86.c
+++ b/checkpoint/rstr_x86.c
@@ -176,3 +176,58 @@ int cr_read_cpu(struct cr_ctx *ctx)

  	return ret;
  }
+
+asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);
+
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int ptag)
+{
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int n, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	cr_debug("ptag %d ret %d nldt %d\n", ptag, ret, hh->nldt);
+	if (ret < 0)
+		return ret;
+	if (ret != ptag)
+		return -EINVAL;
+
+	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
+		return -EINVAL;
+
+	/* to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of inclue/asm/desc.h:fill_ldt() */
+
+	for (n = 0; n < hh->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+
+		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
+		if (ret < 0)
+			return ret;
+
+		info.entry_number = n;
+		info.base_addr = desc.base0 | (desc.base1 << 16);
+		info.limit = desc.limit0;
+		info.seg_32bit = desc.d;
+		info.contents = desc.type >> 2;
+		info.read_exec_only = (desc.type >> 1) ^ 1;
+		info.limit_in_pages = desc.g;
+		info.seg_not_present = desc.p ^ 1;
+		info.useable = desc.avl;
+
+		old_fs = get_fs();
+		set_fs(get_ds());
+		ret = sys_modify_ldt(1, &info, sizeof(info));
+		set_fs(old_fs);
+
+		if (ret < 0)
+			return ret;
+	}
+
+	load_LDT(&mm->context);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
+}
-- 
1.5.4.3
