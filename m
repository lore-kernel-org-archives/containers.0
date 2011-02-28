From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 06/10] Checkpoint/restart mm support
Date: Mon, 28 Feb 2011 17:40:28 -0600
Message-ID: <1298936432-29607-7-git-send-email-ntl__3698.51315995238$1298937042$gmane$org@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Add a checkpoint() method to vm_operations_struct; this is responsible
for dumping the attributes and contents of a VMA.  For each vma, there
is a 'struct ckpt_vma'; then comes the actual contents, a page at a
time.

Normally the per-vma function will invoke generic_vma_checkpoint()
which first writes the vma description, followed by the specific logic
to dump the contents of the pages.

Restoring the memory address space begins with nuking the existing one
of the current process, and then reading the vma state and contents.
Call do_mmap_pgoffset() for each vma and then read in the data.

Based on original code by Oren Laadan.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
[ntl: remove page array chain code; dump/restore VMAs one page at a time]
[ntl: move special_mapping_checkpoint/restore() to mm/checkpoint.c]
[ntl: move filemap_checkpoint/restore() to mm/checkpoint.c]
[ntl: do without custom __get_dirty_page API; use get_user_pages]
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/mm.h |   12 +
 mm/Makefile        |    1 +
 mm/checkpoint.c    |  906 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c       |    4 +
 mm/mmap.c          |    3 +
 5 files changed, 926 insertions(+), 0 deletions(-)
 create mode 100644 mm/checkpoint.c

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5397237..14ff613 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -20,6 +20,7 @@ struct anon_vma;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
+struct ckpt_ctx;
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -229,6 +230,9 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
+#ifdef CONFIG_CHECKPOINT
+	int (*checkpoint)(struct ckpt_ctx *ctx, struct vm_area_struct *vma);
+#endif
 };
 
 struct mmu_gather;
@@ -1333,10 +1337,18 @@ extern void truncate_inode_pages_range(struct address_space *,
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
 
+/* generic vm_area_ops exported for mapped files checkpoint */
+extern int filemap_checkpoint(struct ckpt_ctx *, struct vm_area_struct *);
+
 /* mm/page-writeback.c */
 int write_one_page(struct page *page, int wait);
 void task_dirty_inc(struct task_struct *tsk);
 
+
+/* checkpoint/restart */
+extern int special_mapping_checkpoint(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma);
+
 /* readahead.c */
 #define VM_MAX_READAHEAD	128	/* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
diff --git a/mm/Makefile b/mm/Makefile
index f73f75a..657a9e0 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
new file mode 100644
index 0000000..f26c23d
--- /dev/null
+++ b/mm/checkpoint.c
@@ -0,0 +1,906 @@
+/*
+ *  Checkpoint/restart memory contents
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
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
+#include <linux/aio.h>
+#include <linux/highmem.h>
+#include <linux/elf.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+#include <linux/proc_fs.h>
+#include <linux/checkpoint.h>
+
+#include "internal.h" /* __get_user_pages */
+
+/**************************************************************************
+ * Checkpoint
+ *
+ * Checkpoint is outside the context of the checkpointee, so one
+ * cannot simply read pages from user-space. Instead, we scan the
+ * address space of the target to cherry-pick pages of interest.  To
+ * save their contents, each page is mapped to kernel memory and then
+ * dumped to the file descriptor.
+ */
+
+static int dump_page_header(struct ckpt_ctx *ctx, unsigned long addr)
+{
+	struct ckpt_hdr_page *hdr;
+	int err;
+
+	hdr = ckpt_hdr_get_type(ctx, sizeof(*hdr), CKPT_HDR_PAGE);
+	if (!hdr)
+		return -ENOMEM;
+
+	hdr->vaddr = addr;
+	err = ckpt_write_obj(ctx, &hdr->hdr);
+	kfree(hdr);
+
+	return err;
+}
+
+static int dump_page_contents(struct ckpt_ctx *ctx, struct page *page)
+{
+	void *ptr;
+	int err;
+
+	ptr = kmap(page);
+	err = ckpt_kwrite(ctx, ptr, PAGE_SIZE);
+	kunmap(page);
+
+	return err;
+}
+
+static int dump_vma_page_terminator(struct ckpt_ctx *ctx)
+{
+	return dump_page_header(ctx, CKPT_VMA_LAST_PAGE);
+}
+
+/**
+ * checkpoint_memory_contents - dump contents of a VMA with private memory
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ */
+static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma)
+{
+	unsigned long addr;
+	int err = 0;
+
+	/* We don't hold mmap_sem - the mm's tasks are frozen. */
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		struct page *page;
+		int nr_pages;
+		int flags;
+
+		if (fatal_signal_pending(current)) {
+			err = -EINTR;
+			break;
+		}
+
+		cond_resched();
+
+		nr_pages = 1;
+		flags = FOLL_FORCE | FOLL_DUMP | FOLL_GET;
+		nr_pages = __get_user_pages(ctx->tsk, vma->vm_mm, addr,
+					    nr_pages, flags, &page, NULL);
+		if (nr_pages == -EFAULT)
+			continue;
+
+		if (nr_pages != 1) {
+			WARN_ON_ONCE(nr_pages == 0);
+			err = nr_pages;
+			break;
+		}
+
+		err = dump_page_header(ctx, addr);
+		if (!err)
+			err = dump_page_contents(ctx, page);
+
+		page_cache_release(page);
+
+		if (err)
+			break;
+	}
+
+	if (!err)
+		err = dump_vma_page_terminator(ctx);
+
+	return err;
+}
+
+/**
+ * generic_vma_checkpoint - dump metadata of vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @vma_objref: vma objref
+ */
+int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
+			   enum vma_type type, int vma_objref)
+{
+	struct ckpt_hdr_vma *h;
+	int ret;
+
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d\n",
+		 vma->vm_start, vma->vm_end, vma->vm_flags, type);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_VMA);
+	if (!h)
+		return -ENOMEM;
+
+	h->vma_type = type;
+	h->vma_objref = vma_objref;
+	h->vm_start = vma->vm_start;
+	h->vm_end = vma->vm_end;
+	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	h->vm_flags = vma->vm_flags;
+	h->vm_pgoff = vma->vm_pgoff;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+
+	return ret;
+}
+
+/**
+ * private_vma_checkpoint - dump contents of private (anon, file) vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @vma_objref: vma objref
+ */
+static int private_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type, int vma_objref)
+{
+	int ret;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, vma);
+ out:
+	return ret;
+}
+
+int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	int vma_objref;
+
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(!file);
+
+	vma_objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
+	if (vma_objref < 0)
+		return vma_objref;
+
+	return private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
+}
+
+/*
+ * FIX:
+ *   - checkpoint vdso pages (once per distinct vdso is enough)
+ *   - check for compatilibility between saved and current vdso
+ *   - accommodate for dynamic kernel data in vdso page
+ *
+ * Current, we require COMPAT_VDSO which somewhat mitigates the issue
+ */
+int special_mapping_checkpoint(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma)
+{
+	const char *name;
+
+	/*
+	 * FIX:
+	 * Currently, we only handle VDSO/vsyscall special handling.
+	 * Even that, is very basic - we just skip the contents and
+	 * hope for the best in terms of compatilibity upon restart.
+	 */
+
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED)
+		return -ENOSYS;
+
+	name = arch_vma_name(vma);
+	if (!name || strcmp(name, "[vdso]"))
+		return -ENOSYS;
+
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
+}
+
+/**
+ * anonymous_checkpoint - dump contents of private-anonymous vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ */
+static int anonymous_checkpoint(struct ckpt_ctx *ctx,
+				struct vm_area_struct *vma)
+{
+	/* should be private anonymous ... verify that this is the case */
+	BUG_ON(vma->vm_flags & VM_MAYSHARE);
+	BUG_ON(vma->vm_file);
+
+	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
+}
+
+static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma, *next;
+	int map_count = 0;
+	int ret = 0;
+
+	vma = kzalloc(sizeof(*vma), GFP_KERNEL);
+	if (!vma)
+		return -ENOMEM;
+
+	/*
+	 * Must not hold mm->mmap_sem when writing to image file, so
+	 * can't simply traverse the vma list. Instead, use find_vma()
+	 * to get the @next and make a local "copy" of it.
+	 */
+	while (1) {
+		down_read(&mm->mmap_sem);
+		next = find_vma(mm, vma->vm_end);
+		if (!next) {
+			up_read(&mm->mmap_sem);
+			break;
+		}
+		if (vma->vm_file)
+			fput(vma->vm_file);
+		*vma = *next;
+		if (vma->vm_file)
+			get_file(vma->vm_file);
+		up_read(&mm->mmap_sem);
+
+		map_count++;
+
+		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
+			 vma->vm_start, vma->vm_end, vma->vm_flags);
+
+		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+			ckpt_debug("vma: bad flags (%#lx)\n", vma->vm_flags);
+			ret = -ENOSYS;
+			break;
+		}
+
+		if (!vma->vm_ops)
+			ret = anonymous_checkpoint(ctx, vma);
+		else if (vma->vm_ops->checkpoint)
+			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
+		else
+			ret = -ENOSYS;
+		if (ret < 0) {
+			ckpt_debug("vma checkpoint failed\n");
+			break;
+		}
+	}
+
+	if (vma->vm_file)
+		fput(vma->vm_file);
+
+	kfree(vma);
+
+	return ret < 0 ? ret : map_count;
+}
+
+#define CKPT_AT_SZ (AT_VECTOR_SIZE * sizeof(u64))
+/*
+ * We always write saved_auxv out as an array of u64s, though it is
+ * an array of u32s on 32-bit arch.
+ */
+static int ckpt_write_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	int i, ret;
+	u64 *buf = kzalloc(CKPT_AT_SZ, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+	for (i = 0; i < AT_VECTOR_SIZE; i++)
+		buf[i] = mm->saved_auxv[i];
+	ret = ckpt_write_buffer(ctx, buf, CKPT_AT_SZ);
+	kfree(buf);
+	return ret;
+}
+
+static int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct mm_struct *mm = ptr;
+	struct ckpt_hdr_mm *h;
+	struct file *exe_file = NULL;
+	int ret;
+
+	if (mm_has_pending_aio(mm)) {
+		ckpt_debug("Outstanding aio\n");
+		return -EBUSY;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&mm->mmap_sem);
+
+	h->flags = mm->flags;
+	h->def_flags = mm->def_flags;
+
+	h->start_code = mm->start_code;
+	h->end_code = mm->end_code;
+	h->start_data = mm->start_data;
+	h->end_data = mm->end_data;
+	h->start_brk = mm->start_brk;
+	h->brk = mm->brk;
+	h->start_stack = mm->start_stack;
+	h->arg_start = mm->arg_start;
+	h->arg_end = mm->arg_end;
+	h->env_start = mm->env_start;
+	h->env_end = mm->env_end;
+
+	h->map_count = mm->map_count;
+
+	if (mm->exe_file) {  /* checkpoint the ->exe_file */
+		exe_file = mm->exe_file;
+		get_file(exe_file);
+	}
+
+	/*
+	 * Drop mm->mmap_sem before writing data to checkpoint image
+	 * to avoid reverse locking order (inode must come before mm).
+	 */
+	up_read(&mm->mmap_sem);
+
+	if (exe_file) {
+		h->exe_objref = checkpoint_obj(ctx, exe_file, CKPT_OBJ_FILE);
+		if (h->exe_objref < 0) {
+			ret = h->exe_objref;
+			goto out;
+		}
+	}
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_auxv(ctx, mm);
+	if (ret < 0)
+		return ret;
+
+	ret = checkpoint_vmas(ctx, mm);
+	if (ret != h->map_count && ret >= 0)
+		ret = -EBUSY; /* checkpoint mm leak */
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_mm_context(ctx, mm);
+ out:
+	if (exe_file)
+		fput(exe_file);
+	kfree(h);
+	return ret;
+}
+
+int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct mm_struct *mm;
+	int objref;
+
+	mm = get_task_mm(t);
+	objref = checkpoint_obj(ctx, mm, CKPT_OBJ_MM);
+	mmput(mm);
+
+	return objref;
+}
+
+/***********************************************************************
+ * Restart
+ *
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read into the address space of the current process.
+ */
+
+static int restore_page(struct ckpt_ctx *ctx, unsigned long addr)
+{
+	struct page *page;
+	void *ptr;
+	int err;
+
+	down_read(&current->mm->mmap_sem);
+
+	err = get_user_pages(current, current->mm, addr, 1, 1, 1, &page, NULL);
+	if (err != 1) {
+		if (WARN_ON_ONCE(err >= 0))
+			err = -EFAULT;
+		goto out_unlock;
+	}
+
+	ptr = kmap(page);
+	err = ckpt_kread(ctx, ptr, PAGE_SIZE);
+	kunmap(page);
+
+	page_cache_release(page);
+
+out_unlock:
+	up_read(&current->mm->mmap_sem);
+
+	return err;
+}
+
+/**
+ * restore_memory_contents - restore contents of a VMA with private memory
+ * @ctx - restart context
+ */
+static int restore_memory_contents(struct ckpt_ctx *ctx)
+{
+	int err = 0;
+
+	while (true) {
+		struct ckpt_hdr_page *hdr;
+		unsigned long addr;
+
+		if (fatal_signal_pending(current)) {
+			err = -EINTR;
+			break;
+		}
+
+		cond_resched();
+
+		hdr = ckpt_read_obj_type(ctx, sizeof(*hdr), CKPT_HDR_PAGE);
+		if (IS_ERR(hdr)) {
+			err = PTR_ERR(hdr);
+			break;
+		}
+
+		addr = hdr->vaddr;
+		kfree(hdr);
+
+		if (addr == CKPT_VMA_LAST_PAGE)
+			break;
+
+		err = restore_page(ctx, addr);
+		if (err)
+			break;
+	}
+
+	return err;
+}
+
+/**
+ * calc_map_prot_bits - convert vm_flags to mmap protection
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long calc_map_prot_bits(unsigned long orig_vm_flags)
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
+ * calc_map_flags_bits - convert vm_flags to mmap flags
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
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
+/**
+ * generic_vma_restore - restore a vma
+ * @mm - address space
+ * @file - file to map (NULL for anonymous)
+ * @h - vma header data
+ */
+static unsigned long generic_vma_restore(struct mm_struct *mm,
+					 struct file *file,
+					 struct ckpt_hdr_vma *h)
+{
+	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+
+	if (h->vm_end < h->vm_start)
+		return -EINVAL;
+	if (h->vma_objref < 0)
+		return -EINVAL;
+
+	vm_start = h->vm_start;
+	vm_pgoff = h->vm_pgoff;
+	vm_size = h->vm_end - h->vm_start;
+	vm_prot = calc_map_prot_bits(h->vm_flags);
+	vm_flags = calc_map_flags_bits(h->vm_flags);
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap_pgoff(file, vm_start, vm_size,
+			     vm_prot, vm_flags, vm_pgoff);
+	up_write(&mm->mmap_sem);
+	ckpt_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
+		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	return addr;
+}
+
+/**
+ * private_vma_restore - read vma data, recreate it and read contents
+ * @ctx: checkpoint context
+ * @mm: memory address space
+ * @file: file to use for mapping
+ * @h - vma header data
+ */
+static int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			       struct file *file, struct ckpt_hdr_vma *h)
+{
+	unsigned long addr;
+
+	if (h->vm_flags & (VM_SHARED | VM_MAYSHARE))
+		return -EINVAL;
+
+	addr = generic_vma_restore(mm, file, h);
+	if (IS_ERR((void *) addr))
+		return PTR_ERR((void *) addr);
+
+	return restore_memory_contents(ctx);
+}
+
+/**
+ * anon_private_restore - read vma data, recreate it and read contents
+ * @ctx: checkpoint context
+ * @mm: memory address space
+ * @h - vma header data
+ */
+static int anon_private_restore(struct ckpt_ctx *ctx,
+				     struct mm_struct *mm,
+				     struct ckpt_hdr_vma *h)
+{
+	/*
+	 * vm_pgoff for anonymous mapping is the "global" page
+	 * offset (namely from addr 0x0), so we force a zero
+	 */
+	h->vm_pgoff = 0;
+
+	return private_vma_restore(ctx, mm, NULL, h);
+}
+
+static int filemap_restore(struct ckpt_ctx *ctx,
+		    struct mm_struct *mm,
+		    struct ckpt_hdr_vma *h)
+{
+	struct file *file;
+	int ret;
+
+	if (h->vma_type == CKPT_VMA_FILE &&
+	    (h->vm_flags & (VM_SHARED | VM_MAYSHARE)))
+		return -EINVAL;
+
+	file = ckpt_obj_fetch(ctx, h->vma_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	ret = private_vma_restore(ctx, mm, file, h);
+	return ret;
+}
+
+#ifndef arch_restore_vdso
+#define arch_restore_vdso arch_restore_vdso
+#warn "arch_restore_vdso not implemented"
+static inline int arch_restore_vdso(unsigned long addr)
+{
+	return -ENOSYS;
+}
+#endif
+
+static int special_mapping_restore(struct ckpt_ctx *ctx,
+				   struct mm_struct *mm,
+				   struct ckpt_hdr_vma *h)
+{
+	BUG_ON(h->vma_type != CKPT_VMA_VDSO);
+
+	return arch_restore_vdso(h->vm_start);
+}
+
+/* callbacks to restore vma per its type: */
+struct restore_vma_ops {
+	char *vma_name;
+	enum vma_type vma_type;
+	int (*restore) (struct ckpt_ctx *ctx,
+			struct mm_struct *mm,
+			struct ckpt_hdr_vma *ptr);
+};
+
+static struct restore_vma_ops restore_vma_ops[] = {
+	/* ignored vma */
+	{
+		.vma_name = "IGNORE",
+		.vma_type = CKPT_VMA_IGNORE,
+		.restore = NULL,
+	},
+	/* special mapping (vdso) */
+	{
+		.vma_name = "VDSO",
+		.vma_type = CKPT_VMA_VDSO,
+		.restore = special_mapping_restore,
+	},
+	/* anonymous private */
+	{
+		.vma_name = "ANON PRIVATE",
+		.vma_type = CKPT_VMA_ANON,
+		.restore = anon_private_restore,
+	},
+	/* file-mapped private */
+	{
+		.vma_name = "FILE PRIVATE",
+		.vma_type = CKPT_VMA_FILE,
+		.restore = filemap_restore,
+	},
+};
+
+/**
+ * restore_vma - read vma data, recreate it and read contents
+ * @ctx: checkpoint context
+ * @mm: memory address space
+ */
+static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_vma *h;
+	struct restore_vma_ops *ops;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_VMA);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d\n",
+		   (unsigned long) h->vm_start, (unsigned long) h->vm_end,
+		   (unsigned long) h->vm_flags, (int) h->vma_type,
+		   (int) h->vma_objref);
+
+	ret = -EINVAL;
+	if (h->vm_end < h->vm_start)
+		goto out;
+	if (h->vma_objref < 0)
+		goto out;
+	if (h->vma_type >= CKPT_VMA_MAX)
+		goto out;
+	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
+		return -ENOSYS;
+
+	ops = &restore_vma_ops[h->vma_type];
+
+	/* make sure we don't change this accidentally */
+	BUG_ON(ops->vma_type != h->vma_type);
+
+	if (ops->restore) {
+		ckpt_debug("vma type %s\n", ops->vma_name);
+		ret = ops->restore(ctx, mm, h);
+	} else {
+		ckpt_debug("vma ignored\n");
+		ret = 0;
+	}
+ out:
+	kfree(h);
+	return ret;
+}
+
+static int ckpt_read_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	int i, ret;
+	u64 *buf = kmalloc(CKPT_AT_SZ, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+	ret = _ckpt_read_buffer(ctx, buf, CKPT_AT_SZ);
+	if (ret < 0)
+		goto out;
+
+	ret = -E2BIG;
+	for (i = 0; i < AT_VECTOR_SIZE; i++)
+		if (buf[i] > (u64) ULONG_MAX)
+			goto out;
+
+	for (i = 0; i < AT_VECTOR_SIZE - 1; i++)
+		mm->saved_auxv[i] = buf[i];
+	/* sanitize the input: force AT_NULL in last entry  */
+	mm->saved_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
+
+	ret = 0;
+ out:
+	kfree(buf);
+	return ret;
+}
+
+static int destroy_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap(mm, vma->vm_start,
+				vma->vm_end - vma->vm_start);
+		if (ret < 0) {
+			pr_warning("%s: failed munmap (%d)\n", __func__, ret);
+			return ret;
+		}
+	}
+	return 0;
+}
+
+static void *restore_mm(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_mm *h;
+	struct mm_struct *mm = NULL;
+	struct file *file;
+	unsigned int nr;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (IS_ERR(h))
+		return (void *) h;
+
+	ckpt_debug("map_count %d\n", h->map_count);
+
+	ret = -EINVAL;
+	if ((h->start_code > h->end_code) ||
+	    (h->start_data > h->end_data))
+		goto out;
+	if (h->exe_objref < 0)
+		goto out;
+	if (h->def_flags & ~VM_LOCKED)
+		goto out;
+	if (h->flags & ~(MMF_DUMP_FILTER_MASK |
+			 ((1 << MMF_DUMP_FILTER_BITS) - 1)))
+		goto out;
+
+	mm = current->mm;
+
+	/* point of no return -- destruct current mm */
+	down_write(&mm->mmap_sem);
+	ret = destroy_mm(mm);
+	if (ret < 0) {
+		up_write(&mm->mmap_sem);
+		goto out;
+	}
+
+	mm->flags = h->flags;
+	mm->def_flags = h->def_flags;
+
+	mm->start_code = h->start_code;
+	mm->end_code = h->end_code;
+	mm->start_data = h->start_data;
+	mm->end_data = h->end_data;
+	mm->start_brk = h->start_brk;
+	mm->brk = h->brk;
+	mm->start_stack = h->start_stack;
+	mm->arg_start = h->arg_start;
+	mm->arg_end = h->arg_end;
+	mm->env_start = h->env_start;
+	mm->env_end = h->env_end;
+
+	/* restore the ->exe_file */
+	if (h->exe_objref) {
+		file = ckpt_obj_fetch(ctx, h->exe_objref, CKPT_OBJ_FILE);
+		if (IS_ERR(file)) {
+			up_write(&mm->mmap_sem);
+			ret = PTR_ERR(file);
+			goto out;
+		}
+		set_mm_exe_file(mm, file);
+	}
+	up_write(&mm->mmap_sem);
+
+	ret = ckpt_read_auxv(ctx, mm);
+	if (ret < 0) {
+		ckpt_debug("Error restoring auxv (%d)\n", ret);
+		goto out;
+	}
+
+	for (nr = h->map_count; nr; nr--) {
+		ret = restore_vma(ctx, mm);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = restore_mm_context(ctx, mm);
+ out:
+	kfree(h);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	/* restore_obj() expect an extra reference */
+	atomic_inc(&mm->mm_users);
+	return (void *)mm;
+}
+
+int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = ckpt_obj_fetch(ctx, mm_objref, CKPT_OBJ_MM);
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
+
+	if (mm == current->mm)
+		return 0;
+
+	ret = exec_mmap(mm);
+	if (ret < 0)
+		return ret;
+
+	atomic_inc(&mm->mm_users);
+	return 0;
+}
+
+/*
+ * mm-related checkpoint objects
+ */
+
+static int obj_mm_grab(void *ptr)
+{
+	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
+	return 0;
+}
+
+static void obj_mm_drop(void *ptr, int lastref)
+{
+	mmput((struct mm_struct *) ptr);
+}
+
+/* mm object */
+static const struct ckpt_obj_ops ckpt_obj_mm_ops = {
+	.obj_name = "MM",
+	.obj_type = CKPT_OBJ_MM,
+	.ref_drop = obj_mm_drop,
+	.ref_grab = obj_mm_grab,
+	.checkpoint = checkpoint_mm,
+	.restore = restore_mm,
+};
+
+static int __init checkpoint_register_mm(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_mm_ops);
+}
+late_initcall(checkpoint_register_mm);
diff --git a/mm/filemap.c b/mm/filemap.c
index 6b9aee2..410b4fc 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/checkpoint.h>
 #include "internal.h"
 
 /*
@@ -1651,6 +1652,9 @@ EXPORT_SYMBOL(filemap_fault);
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/mmap.c b/mm/mmap.c
index 50a4aa0..cb47b58 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2447,6 +2447,9 @@ static void special_mapping_close(struct vm_area_struct *vma)
 static const struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = special_mapping_checkpoint,
+#endif
 };
 
 /*
-- 
1.7.4
