From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v4][PATCH 5/9] Memory managemnet (restore)
Date: Tue,  9 Sep 2008 03:42:30 -0400
Message-ID: <1220946154-15174-6-git-send-email-orenl__9081.56285663626$1220947042$gmane$org@cs.columbia.edu>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220946154-15174-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
 arch/x86/mm/checkpoint.c   |    5 +-
 arch/x86/mm/restart.c      |   54 +++++++
 checkpoint/Makefile        |    2 +-
 checkpoint/ckpt_arch.h     |    2 +
 checkpoint/restart.c       |   43 ++++++
 checkpoint/rstr_mem.c      |  351 ++++++++++++++++++++++++++++++++++++++++++++
 include/asm-x86/ckpt_hdr.h |    4 +
 include/linux/ckpt.h       |    2 +
 include/linux/ckpt_hdr.h   |    2 +-
 9 files changed, 460 insertions(+), 5 deletions(-)
 create mode 100644 checkpoint/rstr_mem.c

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 50cfd29..534684f 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -208,17 +208,16 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
 
 	hh->ldt_entry_size = LDT_ENTRY_SIZE;
 	hh->nldt = mm->context.size;
-
 	cr_debug("nldt %d\n", hh->nldt);
 
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
 
 	mutex_unlock(&mm->context.lock);
-
+ out:
 	return ret;
 }
diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
index d7fb89a..be5e0cd 100644
--- a/arch/x86/mm/restart.c
+++ b/arch/x86/mm/restart.c
@@ -177,3 +177,57 @@ int cr_read_cpu(struct cr_ctx *ctx)
  out:
 	return ret;
 }
+
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
+{
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int n, rparent;
+
+	rparent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	cr_debug("parent %d rparent %d nldt %d\n", parent, rparent, hh->nldt);
+	if (rparent < 0)
+		return rparent;
+	if (rparent != parent)
+		return -EINVAL;
+
+	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
+		return -EINVAL;
+
+	/* to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of include/asm/desc.h:fill_ldt() */
+
+	for (n = 0; n < hh->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+		int ret;
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
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 3a0df6d..ac35033 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
-		ckpt_mem.o
+		ckpt_mem.o rstr_mem.o
diff --git a/checkpoint/ckpt_arch.h b/checkpoint/ckpt_arch.h
index 9bd0ba4..29dd326 100644
--- a/checkpoint/ckpt_arch.h
+++ b/checkpoint/ckpt_arch.h
@@ -6,3 +6,5 @@ int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent);
 
 int cr_read_thread(struct cr_ctx *ctx);
 int cr_read_cpu(struct cr_ctx *ctx);
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent);
+
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 5226994..f8c919d 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -77,6 +77,45 @@ int cr_read_string(struct cr_ctx *ctx, void *str, int len)
 	return cr_read_obj_type(ctx, str, len, CR_HDR_STRING);
 }
 
+/**
+ * cr_read_fname - read a file name
+ * @ctx: checkpoint context
+ * @fname: buffer
+ * @n: buffer length
+ */
+int cr_read_fname(struct cr_ctx *ctx, void *fname, int flen)
+{
+	return cr_read_obj_type(ctx, fname, flen, CR_HDR_FNAME);
+}
+
+/**
+ * cr_read_open_fname - read a file name and open a file
+ * @ctx: checkpoint context
+ * @flags: file flags
+ * @mode: file mode
+ */
+struct file *cr_read_open_fname(struct cr_ctx *ctx, int flags, int mode)
+{
+	struct file *file;
+	char *fname;
+	int flen, ret;
+
+	flen = PATH_MAX;
+	fname = kmalloc(flen, GFP_KERNEL);
+	if (!fname)
+		return ERR_PTR(-ENOMEM);
+
+	ret = cr_read_fname(ctx, fname, flen);
+	cr_debug("fname '%s' flags %#x mode %#x\n", fname, flags, mode);
+	if (ret >= 0)
+		file = filp_open(fname, flags, mode);
+	else
+		file = ERR_PTR(ret);
+
+	kfree(fname);
+	return file;
+}
+
 /* read the checkpoint header */
 static int cr_read_head(struct cr_ctx *ctx)
 {
@@ -169,6 +208,10 @@ static int cr_read_task(struct cr_ctx *ctx)
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_read_mm(ctx);
+	cr_debug("memory: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_read_thread(ctx);
 	cr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
new file mode 100644
index 0000000..106b635
--- /dev/null
+++ b/checkpoint/rstr_mem.c
@@ -0,0 +1,351 @@
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
+#include <linux/ckpt.h>
+#include <linux/ckpt_hdr.h>
+
+#include "ckpt_arch.h"
+#include "ckpt_mem.h"
+
+/*
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read in directly to the address space of the current process
+ */
+
+/**
+ * cr_vma_read_pages_vaddrs - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_vaddrs(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	int nr, ret;
+
+	while (npages) {
+		pgarr = cr_pgarr_prep(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+		nr = min(npages, (int) pgarr->nr_free);
+		ret = cr_kread(ctx, pgarr->vaddrs, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nr_free -= nr;
+		pgarr->nr_used += nr;
+		npages -= nr;
+	}
+	return 0;
+}
+
+/**
+ * cr_vma_read_pages_contents - read in data of pages in page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_contents(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	unsigned long *vaddrs;
+	int i, ret;
+
+	list_for_each_entry(pgarr, &ctx->pgarr, list) {
+		vaddrs = pgarr->vaddrs;
+		for (i = 0; i < pgarr->nr_used; i++) {
+			void *ptr = (void *) vaddrs[i];
+			ret = cr_uread(ctx, ptr, PAGE_SIZE);
+			if (ret < 0)
+				return ret;
+		}
+		npages -= pgarr->nr_used;
+	}
+	return 0;
+}
+
+/* change the protection of an address range to be writable/non-writable.
+ * this is useful when restoring the memory of a read-only vma */
+static int cr_vma_set_writable(struct mm_struct *mm, unsigned long start,
+			       unsigned long end, int writable)
+{
+	struct vm_area_struct *vma, *prev;
+	unsigned long flags = 0;
+	int ret = -EINVAL;
+
+	cr_debug("vma %#lx-%#lx writable %d\n", start, end, writable);
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma_prev(mm, start, &prev);
+	if (!vma || vma->vm_start > end || vma->vm_end < start)
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
+static int cr_vma_read_pages(struct cr_ctx *ctx, struct cr_hdr_vma *hh)
+{
+	struct mm_struct *mm = current->mm;
+	int ret = 0;
+
+	if (!hh->nr_pages)
+		return 0;
+
+	/* in the unlikely case that this vma is read-only */
+	if (!(hh->vm_flags & VM_WRITE))
+		ret = cr_vma_set_writable(mm, hh->vm_start, hh->vm_end, 1);
+	if (ret < 0)
+		goto out;
+	ret = cr_vma_read_pages_vaddrs(ctx, hh->nr_pages);
+	if (ret < 0)
+		goto out;
+	ret = cr_vma_read_pages_contents(ctx, hh->nr_pages);
+	if (ret < 0)
+		goto out;
+
+	cr_pgarr_reset(ctx);	/* reset page-array chain */
+
+	/* restore original protection for this vma */
+	if (!(hh->vm_flags & VM_WRITE))
+		ret = cr_vma_set_writable(mm, hh->vm_start, hh->vm_end, 0);
+
+ out:
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
+	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+	unsigned long flags;
+	struct file *file = NULL;
+	int parent, ret = 0;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
+	if (parent < 0)
+		return parent;
+	else if (parent != 0)
+		return -EINVAL;
+
+	cr_debug("vma %#lx-%#lx type %d nr_pages %d\n",
+		 (unsigned long) hh->vm_start, (unsigned long) hh->vm_end,
+		 (int) hh->vma_type, (int) hh->nr_pages);
+
+	if (hh->vm_end < hh->vm_start || hh->nr_pages < 0)
+		return -EINVAL;
+
+	vm_start = hh->vm_start;
+	vm_pgoff = hh->vm_pgoff;
+	vm_size = hh->vm_end - hh->vm_start;
+	vm_prot = cr_calc_map_prot_bits(hh->vm_flags);
+	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
+
+	switch (hh->vma_type) {
+
+	case CR_VMA_ANON:		/* anonymous private mapping */
+		/* vm_pgoff for anonymous mapping is the "global" page
+		   offset (namely from addr 0x0), so we force a zero */
+		vm_pgoff = 0;
+		break;
+
+	case CR_VMA_FILE:		/* private mapping from a file */
+		/* O_RDWR only needed if both (VM_WRITE|VM_SHARED) are set */
+		flags = hh->vm_flags;
+		if ((flags & (VM_WRITE|VM_SHARED)) == (VM_WRITE|VM_SHARED))
+			flags = O_RDWR;
+		else
+			flags = O_RDONLY;
+		file = cr_read_open_fname(ctx, flags, 0);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+		break;
+
+	default:
+		return -EINVAL;
+
+	}
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap_pgoff(file, vm_start, vm_size,
+			     vm_prot, vm_flags, vm_pgoff);
+	up_write(&mm->mmap_sem);
+	cr_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
+		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	/* the file (if opened) is now referenced by the vma */
+	if (file)
+		filp_close(file, NULL);
+
+	if (IS_ERR((void *) addr))
+		return PTR_ERR((void *) addr);
+
+	/*
+	 * CR_VMA_ANON: read in memory as is
+	 * CR_VMA_FILE: read in memory as is
+	 * (more to follow ...)
+	 */
+
+	switch (hh->vma_type) {
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
+		if (ret < 0) {
+			pr_debug("CR: restart failed do_munmap (%d)\n", ret);
+			return ret;
+		}
+	}
+	return 0;
+}
+
+int cr_read_mm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct mm_struct *mm;
+	int nr, parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
+	if (parent < 0)
+		return parent;
+#if 0	/* activate when containers are used */
+	if (parent != task_pid_vnr(current))
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
+	if (ret < 0) {
+		up_write(&mm->mmap_sem);
+		return ret;
+	}
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
+	up_write(&mm->mmap_sem);
+
+
+	/* FIX: need also mm->flags */
+
+	for (nr = hh->map_count; nr; nr--) {
+		ret = cr_read_vma(ctx, mm);
+		if (ret < 0)
+			return ret;
+	}
+
+	ret = cr_read_mm_context(ctx, mm, hh->objref);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff --git a/include/asm-x86/ckpt_hdr.h b/include/asm-x86/ckpt_hdr.h
index 6bc61ac..f8eee6a 100644
--- a/include/asm-x86/ckpt_hdr.h
+++ b/include/asm-x86/ckpt_hdr.h
@@ -74,4 +74,8 @@ struct cr_hdr_mm_context {
 	__s16 nldt;
 } __attribute__((aligned(8)));
 
+
+/* misc prototypes from kernel (not defined elsewhere) */
+asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);
+
 #endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/include/linux/ckpt.h b/include/linux/ckpt.h
index 5c62a90..9305e7b 100644
--- a/include/linux/ckpt.h
+++ b/include/linux/ckpt.h
@@ -59,6 +59,8 @@ int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root);
 int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
 int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
 int cr_read_string(struct cr_ctx *ctx, void *str, int len);
+int cr_read_fname(struct cr_ctx *ctx, void *fname, int n);
+struct file *cr_read_open_fname(struct cr_ctx *ctx, int flags, int mode);
 
 int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 int cr_read_mm(struct cr_ctx *ctx);
diff --git a/include/linux/ckpt_hdr.h b/include/linux/ckpt_hdr.h
index ac77d7d..f064cbb 100644
--- a/include/linux/ckpt_hdr.h
+++ b/include/linux/ckpt_hdr.h
@@ -102,7 +102,7 @@ enum vm_type {
 struct cr_hdr_vma {
 	__u32 vma_type;
 	__u32 _padding;
-	__s64 nr_pages;
+	__s64 nr_pages;		/* number of pages saved */
 
 	__u64 vm_start;
 	__u64 vm_end;
-- 
1.5.4.3
