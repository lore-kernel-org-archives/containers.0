From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 9/9] Introduce functions to restore mm
Date: Wed,  3 Sep 2008 14:57:56 +0400
Message-ID: <1220439476-16465-10-git-send-email-major@openvz.org>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
	<1220439476-16465-5-git-send-email-major@openvz.org>
	<1220439476-16465-6-git-send-email-major@openvz.org>
	<1220439476-16465-7-git-send-email-major@openvz.org>
	<1220439476-16465-8-git-send-email-major@openvz.org>
	<1220439476-16465-9-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-9-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Functions to restore mm, VMAs and mm context are added.

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 cpt/Makefile      |    2 +-
 cpt/cpt.h         |    1 +
 cpt/cpt_image.h   |    5 +
 cpt/rst_mm.c      |  320 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 cpt/rst_process.c |    3 +-
 mm/mmap.c         |    1 +
 mm/mprotect.c     |    2 +
 8 files changed, 336 insertions(+), 2 deletions(-)
 create mode 100644 cpt/rst_mm.c

diff --git a/cpt/Makefile b/cpt/Makefile
index 689a0eb..19ca732 100644
--- a/cpt/Makefile
+++ b/cpt/Makefile
@@ -3,4 +3,4 @@ obj-y += sys_core.o
 obj-$(CONFIG_CHECKPOINT) += cptrst.o
 
 cptrst-objs := sys.o checkpoint.o cpt_process.o cpt_mm.o restart.o \
-	       rst_process.o
+	       rst_process.o rst_mm.o
diff --git a/cpt/cpt.h b/cpt/cpt.h
index d59255f..f2a1b28 100644
--- a/cpt/cpt.h
+++ b/cpt/cpt.h
@@ -62,3 +62,4 @@ int cpt_dump_mm(struct task_struct *tsk, struct cpt_context *ctx);
 int restart_container(struct cpt_context *ctx);
 int rst_get_object(int type, void *tmp, int size, struct cpt_context *ctx);
 int rst_restart_process(struct cpt_context *ctx);
+int rst_restore_mm(struct cpt_context *ctx);
diff --git a/cpt/cpt_image.h b/cpt/cpt_image.h
index ae019e7..3b5b418 100644
--- a/cpt/cpt_image.h
+++ b/cpt/cpt_image.h
@@ -233,6 +233,11 @@ struct cpt_x86_regs
 	__u32	cpt_ss;
 } __attribute__ ((aligned (8)));
 
+static inline void __user * cpt_ptr_import(__u64 ptr)
+{
+	return (void*)(unsigned long)ptr;
+}
+
 static inline __u64 cpt_timespec_export(struct timespec *tv)
 {
 	return (((u64)tv->tv_sec) << 32) + tv->tv_nsec;
diff --git a/cpt/rst_mm.c b/cpt/rst_mm.c
new file mode 100644
index 0000000..cccbff6
--- /dev/null
+++ b/cpt/rst_mm.c
@@ -0,0 +1,320 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/vmalloc.h>
+#include <linux/syscalls.h>
+
+#include "cpt.h"
+#include "cpt_image.h"
+
+static unsigned long make_prot(struct cpt_vma_image *vmai)
+{
+	unsigned long prot = 0;
+
+	if (vmai->cpt_flags & VM_READ)
+		prot |= PROT_READ;
+	if (vmai->cpt_flags & VM_WRITE)
+		prot |= PROT_WRITE;
+	if (vmai->cpt_flags & VM_EXEC)
+		prot |= PROT_EXEC;
+	if (vmai->cpt_flags & VM_GROWSDOWN)
+		prot |= PROT_GROWSDOWN;
+	if (vmai->cpt_flags & VM_GROWSUP)
+		prot |= PROT_GROWSUP;
+	return prot;
+}
+
+static unsigned long make_flags(struct cpt_vma_image *vmai)
+{
+	unsigned long flags = MAP_FIXED;
+
+	if (vmai->cpt_flags&(VM_SHARED|VM_MAYSHARE))
+		flags |= MAP_SHARED;
+	else
+		flags |= MAP_PRIVATE;
+
+	if (vmai->cpt_file == CPT_NULL)
+		flags |= MAP_ANONYMOUS;
+	if (vmai->cpt_flags & VM_GROWSDOWN)
+		flags |= MAP_GROWSDOWN;
+#ifdef MAP_GROWSUP
+	if (vmai->cpt_flags & VM_GROWSUP)
+		flags |= MAP_GROWSUP;
+#endif
+	if (vmai->cpt_flags & VM_DENYWRITE)
+		flags |= MAP_DENYWRITE;
+	if (vmai->cpt_flags & VM_EXECUTABLE)
+		flags |= MAP_EXECUTABLE;
+	if (!(vmai->cpt_flags & VM_ACCOUNT))
+		flags |= MAP_NORESERVE;
+	return flags;
+}
+
+static int rst_restore_one_vma(struct cpt_context *ctx)
+{
+	int err;
+	int i;
+	unsigned long addr;
+	struct mm_struct *mm = current->mm;
+	struct cpt_vma_image vmai;
+	struct vm_area_struct *vma;
+	struct file *file = NULL;
+	unsigned long prot;
+
+	err = rst_get_object(CPT_OBJ_VMA, &vmai, sizeof(vmai), ctx);
+	if (err)
+		return err;
+
+	prot = make_prot(&vmai);
+
+	if (vmai.cpt_vma_type == CPT_VMA_FILE) {
+		struct cpt_object_hdr h;
+		int len;
+		char *path;
+
+		err = rst_get_object(CPT_OBJ_NAME, &h, sizeof(h), ctx);
+		if (err)
+			goto out;
+		len = h.cpt_len - sizeof(h);
+		if (len < 0) {
+			err = -EINVAL;
+			goto out;
+		}
+		path = kmalloc(len, GFP_KERNEL);
+		if (!path) {
+			err = -ENOMEM;
+			goto out;
+		}
+		err = ctx->read(path, len, ctx);
+		if (err) {
+			kfree(path);
+			goto out;
+		}
+
+		/* Just open file
+		   TODO: open with correct flags */
+		file = filp_open(path, O_RDONLY, 0);
+		kfree(path);
+		if (IS_ERR(file)) {
+			err = PTR_ERR(file);
+			goto out;
+		}
+	}
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap_pgoff(file, vmai.cpt_start,
+			     vmai.cpt_end - vmai.cpt_start,
+			     prot, make_flags(&vmai),
+			     vmai.cpt_pgoff);
+
+	if (addr != vmai.cpt_start) {
+		up_write(&mm->mmap_sem);
+
+		err = -EINVAL;
+		if (IS_ERR((void*)addr))
+			err = addr;
+		goto out;
+	}
+
+	vma = find_vma(mm, vmai.cpt_start);
+	if (vma == NULL) {
+		up_write(&mm->mmap_sem);
+		eprintk("cannot find mmapped vma\n");
+		err = -ESRCH;
+		goto out;
+	}
+
+	/* do_mmap_pgoff() can merge new area to previous one (not to the next,
+	 * we mmap in order, the rest of mm is still unmapped). This can happen
+	 * f.e. if flags are to be adjusted later, or if we had different
+	 * anon_vma on two adjacent regions. Split it by brute force. */
+	if (vma->vm_start != vmai.cpt_start) {
+		err = split_vma(mm, vma, (unsigned long)vmai.cpt_start, 0);
+		if (err) {
+			up_write(&mm->mmap_sem);
+			eprintk("cannot split vma\n");
+			goto out;
+		}
+	}
+	up_write(&mm->mmap_sem);
+
+	for (i = 0; i < vmai.cpt_page_num; i++) {
+		struct cpt_page_block pb;
+
+		err = rst_get_object(CPT_OBJ_PAGES, &pb, sizeof(pb), ctx);
+		if (err)
+			goto out;
+		if (!(vmai.cpt_flags & VM_ACCOUNT) && !(prot & PROT_WRITE)) {
+			/* I guess this is get_user_pages() messed things,
+			 * this happens f.e. when gdb inserts breakpoints.
+			 */
+			int j;
+			for (j = 0; j < (pb.cpt_end-pb.cpt_start)/PAGE_SIZE; j++) {
+				struct page *page;
+				void *maddr;
+				err = get_user_pages(current, current->mm,
+						(unsigned long)pb.cpt_start +
+						j * PAGE_SIZE,
+						1, 1, 1, &page, NULL);
+				if (err == 0)
+					err = -EFAULT;
+				if (err < 0) {
+					eprintk("get_user_pages: %d\n", err);
+					goto out;
+				}
+				err = 0;
+				maddr = kmap(page);
+				if (pb.cpt_content == CPT_CONTENT_VOID) {
+					memset(maddr, 0, PAGE_SIZE);
+				} else if (pb.cpt_content == CPT_CONTENT_DATA) {
+					err = ctx->read(maddr, PAGE_SIZE, ctx);
+					if (err) {
+						kunmap(page);
+						goto out;
+					}
+				} else {
+					err = -EINVAL;
+					kunmap(page);
+					goto out;
+				}
+				set_page_dirty_lock(page);
+				kunmap(page);
+				page_cache_release(page);
+			}
+		} else {
+			if (!(prot & PROT_WRITE))
+				sys_mprotect(vmai.cpt_start,
+						vmai.cpt_end - vmai.cpt_start,
+						prot | PROT_WRITE);
+			if (pb.cpt_content == CPT_CONTENT_VOID) {
+				int j;
+				for (j=0; j<(pb.cpt_end-pb.cpt_start)/sizeof(unsigned long); j++) {
+					err = __put_user(0UL, ((unsigned long __user*)(unsigned long)pb.cpt_start) + j);
+					if (err) {
+						eprintk("__put_user 2 %d\n", err);
+						goto out;
+					}
+				}
+			} else if (pb.cpt_content == CPT_CONTENT_DATA) {
+				err = ctx->read(cpt_ptr_import(pb.cpt_start),
+						pb.cpt_end - pb.cpt_start,
+						ctx);
+				if (err)
+					goto out;
+			} else {
+				err = -EINVAL;
+				goto out;
+			}
+			if (!(prot & PROT_WRITE))
+				sys_mprotect(vmai.cpt_start,
+						vmai.cpt_end - vmai.cpt_start,
+						prot);
+		}
+	}
+
+out:
+	if (file)
+		fput(file);
+	return err;
+}
+
+static int rst_restore_mm_context(struct cpt_context *ctx)
+{
+	struct cpt_obj_bits b;
+	struct mm_struct *mm = current->mm;
+	int oldsize = mm->context.size;
+	int err;
+	void *oldldt;
+	void *newldt;
+
+	err = rst_get_object(CPT_OBJ_BITS, &b, sizeof(b), ctx);
+	if (err)
+		return err;
+
+	if (b.cpt_size > PAGE_SIZE)
+		newldt = vmalloc(b.cpt_size);
+	else
+		newldt = kmalloc(b.cpt_size, GFP_KERNEL);
+
+	if (!newldt)
+		return -ENOMEM;
+
+	err = ctx->read(newldt, b.cpt_size, ctx);
+	if (err)
+		return err;
+
+	oldldt = mm->context.ldt;
+	mm->context.ldt = newldt;
+	mm->context.size = b.cpt_size / LDT_ENTRY_SIZE;
+
+	load_LDT(&mm->context);
+
+	if (oldsize) {
+		if (oldsize * LDT_ENTRY_SIZE > PAGE_SIZE)
+			vfree(oldldt);
+		else
+			kfree(oldldt);
+	}
+
+	return 0;
+}
+
+int rst_restore_mm(struct cpt_context *ctx)
+{
+	int err;
+	int i;
+	struct mm_struct *mm = current->mm;
+	struct cpt_mm_image m;
+
+	err = rst_get_object(CPT_OBJ_MM, &m, sizeof(m), ctx);
+	if (err)
+		return err;
+
+	down_write(&mm->mmap_sem);
+	do_munmap(mm, 0, TASK_SIZE);
+
+	mm->start_code = m.cpt_start_code;
+	mm->end_code = m.cpt_end_code;
+	mm->start_data = m.cpt_start_data;
+	mm->end_data = m.cpt_end_data;
+	mm->start_brk = m.cpt_start_brk;
+	mm->brk = m.cpt_brk;
+	mm->start_stack = m.cpt_start_stack;
+	mm->arg_start = m.cpt_start_arg;
+	mm->arg_end = m.cpt_end_arg;
+	mm->env_start = m.cpt_start_env;
+	mm->env_end = m.cpt_end_env;
+	mm->def_flags = m.cpt_def_flags;
+	mm->flags = m.cpt_flags;
+
+	up_write(&mm->mmap_sem);
+
+	for (i = 0; i < m.cpt_map_count; i++) {
+		err = rst_restore_one_vma(ctx);
+		if (err < 0)
+			goto out;
+	}
+
+	err = rst_restore_mm_context(ctx);
+out:
+	return err;
+}
+
diff --git a/cpt/rst_process.c b/cpt/rst_process.c
index 6d47f3c..84be46e 100644
--- a/cpt/rst_process.c
+++ b/cpt/rst_process.c
@@ -210,7 +210,8 @@ static int restart_thread(void *arg)
 	err = rst_get_object(CPT_OBJ_TASK, ti, sizeof(*ti), ctx);
 	if (!err)
 		err = rst_restore_task_struct(current, ti, ctx);
-	/* Restore mm here */
+	if (!err)
+		err = rst_restore_mm(ctx);
 	if (!err)
 		err = rst_restore_fpustate(current, ti, ctx);
 	if (!err)
diff --git a/mm/mmap.c b/mm/mmap.c
index 971d0ed..98d1ba9 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1858,6 +1858,7 @@ int split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
 
 	return 0;
 }
+EXPORT_SYMBOL(split_vma);
 
 /* Munmap is split into 2 main parts -- this part which finds
  * what needs doing, and the areas themselves, which do the
diff --git a/mm/mprotect.c b/mm/mprotect.c
index fded06f..47c7d75 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -22,6 +22,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/module.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -317,3 +318,4 @@ out:
 	up_write(&current->mm->mmap_sem);
 	return error;
 }
+EXPORT_SYMBOL(sys_mprotect);
-- 
1.5.6
