From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 08/54] Dump memory address space
Date: Tue, 28 Apr 2009 19:23:38 -0400
Message-ID: <1240961064-13991-9-git-send-email-orenl@cs.columbia.edu>
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

For each VMA, there is a 'struct ckpt_vma'; if the VMA is file-mapped,
it will be followed by the file name. Then comes the actual contents,
in one or more chunk: each chunk begins with a header that specifies
how many pages it holds, then the virtual addresses of all the dumped
pages in that chunk, followed by the actual contents of all dumped
pages. A header with zero number of pages marks the end of the contents.
Then comes the next VMA and so on.

To checkpoint a vma, call the ops->checkpoint() method of that vma.
Normally the per-vma function will invoke generic_vma_checkpoint()
which first writes the vma description, followed by the specific
logic to dump the contents of the pages.

Currently for private mapped memory we save the pathname of the file
that is mapped (restart will use it to re-open it and then map it).
Later we change that to reference a file object.

Changelog[v14]:
  - Modify the ops->checkpoint method to be much more powerful
  - Improve support for VDSO (with special_mapping checkpoint callback)
  - Save new field 'vdso' in mm_context
  - Revert change to pr_debug(), back to ckpt_debug()
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'h->parent'

Changelog[v13]:
  - pgprot_t is an abstract type; use the proper accessor (fix for
    64-bit powerpc (Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>)

Changelog[v12]:
  - Hide pgarr management inside ckpt_private_vma_fill_pgarr()
  - Fix management of pgarr chain reset and alloc/expand: keep empty
    pgarr in a pool chain
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them.
  - Add missing test for VM_MAYSHARE when dumping memory

Changelog[v10]:
  - Acquire dcache_lock around call to __d_path() in ckpt_fill_name()

Changelog[v9]:
  - Introduce ckpt_ctx_checkpoint() for checkpoint-specific ctx setup
  - Test if __d_path() changes mnt/dentry (when crossing filesystem
    namespace boundary). for now ckpt_fill_fname() fails the checkpoint.

Changelog[v7]:
  - Fix argument given to kunmap_atomic() in memory dump/restore

Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)

Changelog[v5]:
  - Improve memory dump code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Fix use of follow_page() to avoid faulting in non-present pages

Changelog[v4]:
  - Use standard list_... for ckpt_pgarr

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 arch/x86/Kconfig                      |    1 +
 arch/x86/include/asm/checkpoint_hdr.h |    7 +
 arch/x86/mm/checkpoint.c              |   32 ++
 checkpoint/Makefile                   |    2 +-
 checkpoint/checkpoint.c               |   24 ++
 checkpoint/checkpoint_arch.h          |    1 +
 checkpoint/files.c                    |   88 +++++
 checkpoint/memory.c                   |  600 +++++++++++++++++++++++++++++++++
 checkpoint/process.c                  |    4 +
 checkpoint/sys.c                      |    9 +
 include/linux/checkpoint.h            |   25 ++-
 include/linux/checkpoint_hdr.h        |   39 +++
 include/linux/checkpoint_types.h      |   10 +
 mm/filemap.c                          |   30 ++
 mm/mmap.c                             |   30 ++
 15 files changed, 900 insertions(+), 2 deletions(-)
 create mode 100644 checkpoint/files.c
 create mode 100644 checkpoint/memory.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8dfe0c0..3245e9d 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -79,6 +79,7 @@ config HAVE_LATENCYTOP_SUPPORT
 
 config CHECKPOINT_SUPPORT
 	bool
+	depends on COMPAT_VDSO
 	default y if X86_32
 
 config FAST_CMPXCHG_LOCAL
diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 035abbb..bad7b29 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -97,4 +97,11 @@ struct ckpt_hdr_cpu {
 	/* thread_xstate contents follow (if used_math) */
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	__u64 vdso;
+	__u32 ldt_entry_size;
+	__u32 nldt;
+} __attribute__((aligned(8)));
+
 #endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 86ca916..ede7045 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -14,6 +14,7 @@
 #include <asm/desc.h>
 #include <asm/i387.h>
 
+#include <linux/checkpoint_types.h>
 #include <asm/checkpoint_hdr.h>
 #include <linux/checkpoint.h>
 
@@ -240,6 +241,37 @@ int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* dump the mm->context state */
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (!h)
+		return -ENOMEM;
+
+	mutex_lock(&mm->context.lock);
+
+	h->vdso = (unsigned long) mm->context.vdso;
+	h->ldt_entry_size = LDT_ENTRY_SIZE;
+	h->nldt = mm->context.size;
+
+	ckpt_debug("nldt %d vdso %#llx\n", h->nldt, h->vdso);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_kwrite(ctx, mm->context.ldt,
+			mm->context.size * LDT_ENTRY_SIZE);
+
+ out:
+	mutex_unlock(&mm->context.lock);
+	return ret;
+}
+
 /**************************************************************************
  * Restart
  */
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 5d2c083..a33ab77 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o \
-	process.o
+	process.o memory.o files.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 62ba0a6..9abdf73 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -15,6 +15,7 @@
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/fdtable.h>
 #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <linux/utsname.h>
@@ -160,10 +161,33 @@ static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int ckpt_ctx_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
+{
+	struct fs_struct *fs;
+
+	ctx->root_pid = pid;
+
+	/*
+	 * assume checkpointer is in container's root vfs
+	 * FIXME: this works for now, but will change with real containers
+	 */
+
+	fs = current->fs;
+	read_lock(&fs->lock);
+	ctx->fs_mnt = fs->root;
+	path_get(&ctx->fs_mnt);
+	read_unlock(&fs->lock);
+
+	return 0;
+}
+
 int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 {
 	int ret;
 
+	ret = ckpt_ctx_checkpoint(ctx, pid);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
index 2ee4d7f..d168b9c 100644
--- a/checkpoint/checkpoint_arch.h
+++ b/checkpoint/checkpoint_arch.h
@@ -3,6 +3,7 @@
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
 extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
diff --git a/checkpoint/files.c b/checkpoint/files.c
new file mode 100644
index 0000000..1718526
--- /dev/null
+++ b/checkpoint/files.c
@@ -0,0 +1,88 @@
+/*
+ *  Checkpoint file descriptors
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
+#include <linux/file.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * fill_fname - return pathname of a given file
+ * @path: path name
+ * @root: relative root
+ * @buf: buffer for pathname
+ * @len: buffer length (in) and pathname length (out)
+ */
+static char *fill_fname(struct path *path, struct path *root,
+			char *buf, int *len)
+{
+	struct path tmp = *root;
+	char *fname;
+
+	BUG_ON(!buf);
+	spin_lock(&dcache_lock);
+	fname = __d_path(path, &tmp, buf, *len);
+	spin_unlock(&dcache_lock);
+	if (IS_ERR(fname))
+		return fname;
+	*len = (buf + (*len) - fname);
+	/*
+	 * FIX: if __d_path() changed these, it must have stepped out of
+	 * init's namespace. Since currently we require a unified namespace
+	 * within the container: simply fail.
+	 */
+	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
+		fname = ERR_PTR(-EBADF);
+
+	return fname;
+}
+
+/**
+ * dump_fname - write a file name
+ * @ctx: checkpoint context
+ * @path: path name
+ * @root: relative root
+ */
+static int dump_fname(struct ckpt_ctx *ctx,
+		      struct path *path, struct path *root)
+{
+	char *buf, *fname;
+	int ret, flen;
+
+	/*
+	 * FIXME: we can optimize and save memory (and storage) if we
+	 * share strings (through objhash) and reference them instead
+	 */
+
+	flen = PATH_MAX;
+	buf = kmalloc(flen, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	fname = fill_fname(path, root, buf, &flen);
+	if (!IS_ERR(fname))
+		ret = ckpt_write_obj_type(ctx, fname, flen, CKPT_HDR_FNAME);
+	else
+		ret = PTR_ERR(fname);
+
+	kfree(buf);
+	return ret;
+}
+
+int checkpoint_file(struct ckpt_ctx *ctx, struct file *file)
+{
+	return dump_fname(ctx, &file->f_path, &ctx->fs_mnt);
+}
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
new file mode 100644
index 0000000..668d883
--- /dev/null
+++ b/checkpoint/memory.c
@@ -0,0 +1,600 @@
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
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DMEM
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "checkpoint_arch.h"
+
+/*
+ * page-array chains: each ckpt_pgarr describes a set of <struct page *,vaddr>
+ * tuples (where vaddr is the virtual address of a page in a particular mm).
+ * Specifically, we use separate arrays so that all vaddrs can be written
+ * and read at once.
+ */
+
+struct ckpt_pgarr {
+	unsigned long *vaddrs;
+	struct page **pages;
+	unsigned int nr_used;
+	struct list_head list;
+};
+
+#define CKPT_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
+#define CKPT_PGARR_CHUNK  (4 * CKPT_PGARR_TOTAL)
+
+static inline int pgarr_is_full(struct ckpt_pgarr *pgarr)
+{
+	return (pgarr->nr_used == CKPT_PGARR_TOTAL);
+}
+
+static inline int pgarr_nr_free(struct ckpt_pgarr *pgarr)
+{
+	return CKPT_PGARR_TOTAL - pgarr->nr_used;
+}
+
+/*
+ * utilities to alloc, free, and handle 'struct ckpt_pgarr' (page-arrays)
+ * (common to ckpt_mem.c and rstr_mem.c).
+ *
+ * The checkpoint context structure has two members for page-arrays:
+ *   ctx->pgarr_list: list head of populated page-array chain
+ *   ctx->pgarr_pool: list head of empty page-array pool chain
+ *
+ * During checkpoint (and restart) the chain tracks the dirty pages (page
+ * pointer and virtual address) of each MM. For a particular MM, these are
+ * always added to the head of the page-array chain (ctx->pgarr_list).
+ * Before the next chunk of pages, the chain is reset (by dereferencing
+ * all pages) but not freed; instead, empty descsriptors are kept in pool.
+ *
+ * The head of the chain page-array ("current") advances as necessary. When
+ * it gets full, a new page-array descriptor is pushed in front of it. The
+ * new descriptor is taken from first empty descriptor (if one exists, for
+ * instance, after a chain reset), or allocated on-demand.
+ *
+ * When dumping the data, the chain is traversed in reverse order.
+ */
+
+/* return first page-array in the chain */
+static inline struct ckpt_pgarr *pgarr_first(struct ckpt_ctx *ctx)
+{
+	if (list_empty(&ctx->pgarr_list))
+		return NULL;
+	return list_first_entry(&ctx->pgarr_list, struct ckpt_pgarr, list);
+}
+
+/* return (and detach) first empty page-array in the pool, if exists */
+static inline struct ckpt_pgarr *pgarr_from_pool(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr;
+
+	if (list_empty(&ctx->pgarr_pool))
+		return NULL;
+	pgarr = list_first_entry(&ctx->pgarr_pool, struct ckpt_pgarr, list);
+	list_del(&pgarr->list);
+	return pgarr;
+}
+
+/* release pages referenced by a page-array */
+static void pgarr_release_pages(struct ckpt_pgarr *pgarr)
+{
+	ckpt_debug("total pages %d\n", pgarr->nr_used);
+	/*
+	 * both checkpoint and restart use 'nr_used', however we only
+	 * collect pages during checkpoint; in restart we simply return
+	 * because pgarr->pages remains NULL.
+	 */
+	if (pgarr->pages) {
+		struct page **pages = pgarr->pages;
+		int nr = pgarr->nr_used;
+
+		while (nr--)
+			page_cache_release(pages[nr]);
+	}
+
+	pgarr->nr_used = 0;
+}
+
+/* free a single page-array object */
+static void pgarr_free_one(struct ckpt_pgarr *pgarr)
+{
+	pgarr_release_pages(pgarr);
+	kfree(pgarr->pages);
+	kfree(pgarr->vaddrs);
+	kfree(pgarr);
+}
+
+/* free the chains of page-arrays (populated and empty pool) */
+void ckpt_pgarr_free(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr, *tmp;
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_list, list) {
+		list_del(&pgarr->list);
+		pgarr_free_one(pgarr);
+	}
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_pool, list) {
+		list_del(&pgarr->list);
+		pgarr_free_one(pgarr);
+	}
+}
+
+/* allocate a single page-array object */
+static struct ckpt_pgarr *pgarr_alloc_one(unsigned long flags)
+{
+	struct ckpt_pgarr *pgarr;
+
+	pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
+	if (!pgarr)
+		return NULL;
+	pgarr->vaddrs = kmalloc(CKPT_PGARR_TOTAL * sizeof(unsigned long),
+				GFP_KERNEL);
+	if (!pgarr->vaddrs)
+		goto nomem;
+
+	/* pgarr->pages is needed only for checkpoint */
+	if (flags & CKPT_CTX_CHECKPOINT) {
+		pgarr->pages = kmalloc(CKPT_PGARR_TOTAL *
+				       sizeof(struct page *), GFP_KERNEL);
+		if (!pgarr->pages)
+			goto nomem;
+	}
+
+	return pgarr;
+ nomem:
+	pgarr_free_one(pgarr);
+	return NULL;
+}
+
+/* pgarr_current - return the next available page-array in the chain
+ * @ctx: checkpoint context
+ *
+ * Returns the first page-array in the list that has space. Otherwise,
+ * try the next page-array after the last non-empty one, and move it to
+ * the front of the chain. Extends the list if none has space.
+ */
+static struct ckpt_pgarr *pgarr_current(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr;
+
+	pgarr = pgarr_first(ctx);
+	if (pgarr && !pgarr_is_full(pgarr))
+		return pgarr;
+
+	pgarr = pgarr_from_pool(ctx);
+	if (!pgarr)
+		pgarr = pgarr_alloc_one(ctx->flags);
+	if (!pgarr)
+		return NULL;
+
+	list_add(&pgarr->list, &ctx->pgarr_list);
+	return pgarr;
+}
+
+/* reset the page-array chain (dropping page references if necessary) */
+static void pgarr_reset_all(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr;
+
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list)
+		pgarr_release_pages(pgarr);
+	list_splice_init(&ctx->pgarr_list, &ctx->pgarr_pool);
+}
+
+/*
+ * Checkpoint
+ *
+ * Checkpoint is outside the context of the checkpointee, so one cannot
+ * simply read pages from user-space. Instead, we scan the address space
+ * of the target to cherry-pick pages of interest. Selected pages are
+ * enlisted in a page-array chain (attached to the checkpoint context).
+ * To save their contents, each page is mapped to kernel memory and then
+ * dumped to the file descriptor.
+ */
+
+
+/**
+ * private_follow_page - return page pointer for dirty pages
+ * @vma - target vma
+ * @addr - page address
+ *
+ * Looks up the page that correspond to the address in the vma, and
+ * returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ */
+static struct page *consider_private_page(struct vm_area_struct *vma,
+					  unsigned long addr)
+{
+	struct page *page;
+
+	/*
+	 * simplified version of get_user_pages(): already have vma,
+	 * only need FOLL_ANON, and (for now) ignore fault stats.
+	 *
+	 * follow_page() will return NULL if the page is not present
+	 * (swapped), ZERO_PAGE(0) if the pte wasn't allocated, and
+	 * the actual page pointer otherwise.
+	 *
+	 * FIXME: consolidate with get_user_pages()
+	 */
+
+	cond_resched();
+	while (!(page = follow_page(vma, addr, FOLL_ANON | FOLL_GET))) {
+		int ret;
+
+		/* the page is swapped out - bring it in (optimize ?) */
+		ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+		if (ret & VM_FAULT_ERROR) {
+			if (ret & VM_FAULT_OOM)
+				return ERR_PTR(-ENOMEM);
+			else if (ret & VM_FAULT_SIGBUS)
+				return ERR_PTR(-EFAULT);
+			else
+				BUG();
+			break;
+		}
+		cond_resched();
+	}
+
+	if (IS_ERR(page))
+		return page;
+
+	/*
+	 * Only care about dirty pages: either anonymous non-zero pages,
+	 * or file-backed COW (copy-on-write) pages that were modified.
+	 * A clean COW page is not interesting because its contents are
+	 * identical to the backing file; ignore such pages.
+	 * A file-backed broken COW is identified by its page_mapping()
+	 * being unset (NULL) because the page will no longer be mapped
+	 * to the original file after having been modified.
+	 */
+	if (page == ZERO_PAGE(0)) {
+		/* this is the zero page: ignore */
+		page_cache_release(page);
+		page = NULL;
+	} else if (vma->vm_file && (page_mapping(page) != NULL)) {
+		/* file backed clean cow: ignore */
+		page_cache_release(page);
+		page = NULL;
+	}
+
+	return page;
+}
+
+/**
+ * private_vma_fill_pgarr - fill a page-array with addr/page tuples
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ * @start - start address (updated)
+ *
+ * Returns the number of pages collected
+ */
+static int private_vma_fill_pgarr(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	struct ckpt_pgarr *pgarr;
+	int nr_used;
+	int cnt = 0;
+
+	/* this function is only for private memory (anon or file-mapped) */
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	do {
+		pgarr = pgarr_current(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+
+		nr_used = pgarr->nr_used;
+
+		while (addr < end) {
+			struct page *page;
+
+			page = consider_private_page(vma, addr);
+			if (IS_ERR(page))
+				return PTR_ERR(page);
+
+			if (page) {
+				_ckpt_debug(CKPT_DPAGE,
+					    "got page %#lx\n", addr);
+				pgarr->pages[pgarr->nr_used] = page;
+				pgarr->vaddrs[pgarr->nr_used] = addr;
+				pgarr->nr_used++;
+			}
+
+			addr += PAGE_SIZE;
+
+			if (pgarr_is_full(pgarr))
+				break;
+		}
+
+		cnt += pgarr->nr_used - nr_used;
+
+	} while ((cnt < CKPT_PGARR_CHUNK) && (addr < end));
+
+	*start = addr;
+	return cnt;
+}
+
+/* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
+static int checkpoint_dump_page(struct ckpt_ctx *ctx,
+				struct page *page, char *buf)
+{
+	void *ptr;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(buf, ptr, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
+
+	return ckpt_kwrite(ctx, buf, PAGE_SIZE);
+}
+
+/**
+ * vma_dump_pages - dump pages listed in the ctx page-array chain
+ * @ctx - checkpoint context
+ * @total - total number of pages
+ *
+ * First dump all virtual addresses, followed by the contents of all pages
+ */
+static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
+{
+	struct ckpt_pgarr *pgarr;
+	void *buf;
+	int i, ret = 0;
+
+	if (!total)
+		return 0;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		ret = ckpt_kwrite(ctx, pgarr->vaddrs,
+				pgarr->nr_used * sizeof(*pgarr->vaddrs));
+		if (ret < 0)
+			return ret;
+	}
+
+	buf = (void *) __get_free_page(GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		for (i = 0; i < pgarr->nr_used; i++) {
+			ret = checkpoint_dump_page(ctx, pgarr->pages[i], buf);
+			if (ret < 0)
+				goto out;
+		}
+	}
+
+ out:
+	free_page((unsigned long) buf);
+	return ret;
+}
+
+/**
+ * checkpoint_private_contents - dump contents of a VMA with private memory
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ * Collect lists of pages that needs to be dumped, and corresponding
+ * virtual addresses into ctx->pgarr_list page-array chain. Then dump
+ * the addresses, followed by the page contents.
+ */
+static int checkpoint_private_contents(struct ckpt_ctx *ctx,
+				       struct vm_area_struct *vma)
+{
+	struct ckpt_hdr_pgarr *h;
+	unsigned long addr = vma->vm_start;
+	int cnt, ret;
+
+	/*
+	 * Work iteratively, collecting and dumping at most CKPT_PGARR_CHUNK
+	 * in each round. Each iterations is divided into two steps:
+	 *
+	 * (1) scan: scan through the PTEs of the vma to collect the pages
+	 * to dump (later we'll also make them COW), while keeping a list
+	 * of pages and their corresponding addresses on ctx->pgarr_list.
+	 *
+	 * (2) dump: write out a header specifying how many pages, followed
+	 * by the addresses of all pages in ctx->pgarr_list, followed by
+	 * the actual contents of all pages. (Then, release the references
+	 * to the pages and reset the page-array chain).
+	 *
+	 * (This split makes the logic simpler by first counting the pages
+	 * that need saving. More importantly, it allows for a future
+	 * optimization that will reduce application downtime by deferring
+	 * the actual write-out of the data to after the application is
+	 * allowed to resume execution).
+	 *
+	 * After dumpting the entire contents, conclude with a header that
+	 * specifies 0 pages to mark the end of the contents.
+	 */
+
+	while (addr < vma->vm_end) {
+		cnt = private_vma_fill_pgarr(ctx, vma, &addr);
+		if (cnt == 0)
+			break;
+		else if (cnt < 0)
+			return cnt;
+
+		ckpt_debug("collected %d pages\n", cnt);
+
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
+		if (!h)
+			return -ENOMEM;
+
+		h->nr_pages = cnt;
+		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+		ckpt_hdr_put(ctx, h);
+		if (ret < 0)
+			return ret;
+
+		ret = vma_dump_pages(ctx, cnt);
+		if (ret < 0)
+			return ret;
+
+		pgarr_reset_all(ctx);
+	}
+
+	/* mark end of contents with header saying "0" pages */
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
+	if (!h)
+		return -ENOMEM;
+	h->nr_pages = 0;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**
+ * generic_vma_checkpoint - dump metadata of vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ */
+int generic_vma_checkpoint(struct ckpt_ctx *ctx,
+			   struct vm_area_struct *vma, enum vma_type type)
+{
+	struct ckpt_hdr_vma *h;
+	int ret;
+
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d\n",
+		 vma->vm_start, vma->vm_end, vma->vm_flags, type);
+
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_VMA);
+	if (!h)
+		return -ENOMEM;
+
+	h->vma_type = type;
+	h->vm_start = vma->vm_start;
+	h->vm_end = vma->vm_end;
+	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	h->vm_flags = vma->vm_flags;
+	h->vm_pgoff = vma->vm_pgoff;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**
+ * private_vma_checkpoint - dump contents of private (anon, file) vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ */
+int private_vma_checkpoint(struct ckpt_ctx *ctx,
+			   struct vm_area_struct *vma,
+			   enum vma_type type)
+{
+	int ret;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	ret = generic_vma_checkpoint(ctx, vma, type);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_private_contents(ctx, vma);
+ out:
+	return ret;
+}
+
+/**
+ * anonymous_checkpoint - dump contents of anonymous vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ */
+static int anonymous_checkpoint(struct ckpt_ctx *ctx,
+				struct vm_area_struct *vma)
+{
+	/* should be private anonymous ... verify that this is the case */
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(vma->vm_file);
+
+	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON);
+}
+
+int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_mm *h;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (!h)
+		return -ENOMEM;
+
+	mm = get_task_mm(t);
+
+	down_read(&mm->mmap_sem);
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
+	/* FIX: need also mm->flags */
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	/* write the vma's */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
+			 vma->vm_start, vma->vm_end, vma->vm_flags);
+		if (!vma->vm_ops)
+			ret = anonymous_checkpoint(ctx, vma);
+		else if (vma->vm_ops->checkpoint)
+			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
+		else
+			ret = -ENOSYS;
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = checkpoint_mm_context(ctx, mm);
+ out:
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+	return ret;
+}
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 0578182..64deb76 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -57,6 +57,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = checkpoint_mm(ctx, t);
+	ckpt_debug("memory: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index a99cd51..5ebbac9 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -197,7 +197,13 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	if (ctx->file)
 		fput(ctx->file);
+
 	kfree(ctx->hbuf);
+
+	path_put(&ctx->fs_mnt);		/* safe with NULL pointers */
+
+	ckpt_pgarr_free(ctx);
+
 	kfree(ctx);
 }
 
@@ -212,6 +218,9 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long flags)
 
 	ctx->flags = flags;
 
+	INIT_LIST_HEAD(&ctx->pgarr_list);
+	INIT_LIST_HEAD(&ctx->pgarr_pool);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1433290..108e6a1 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -41,13 +41,36 @@ extern int do_restart(struct ckpt_ctx *ctx, pid_t pid);
 extern int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_task(struct ckpt_ctx *ctx);
 
+/* memory */
+extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
+
+extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type);
+extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type);
+
+extern int checkpoint_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+
+#define CKPT_VMA_NOT_SUPPORTED					\
+	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB |		\
+	 VM_NONLINEAR | VM_PFNMAP | VM_RESERVED | VM_NORESERVE	\
+	 | VM_HUGETLB | VM_NONLINEAR | VM_MAPPED_COPY |		\
+	 VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
+
+/* files */
+extern int checkpoint_file(struct ckpt_ctx *ctx, struct file *file);
+
 
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
 #define CKPT_DSYS	0x2		/* generic (system) */
 #define CKPT_DRW	0x4		/* image read/write */
+#define CKPT_DMEM	0x8		/* memory state */
+#define CKPT_DPAGE	0x10		/* memory pages */
 
-#define CKPT_DDEFAULT	0x7		/* default debug level */
+#define CKPT_DDEFAULT	0xf		/* default debug level */
 
 #ifndef CKPT_DFLAG
 #define CKPT_DFLAG	0x0		/* nothing */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 9716f4b..dab6b7f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -44,6 +44,7 @@ enum {
 	CKPT_HDR_HEADER_ARCH,
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
+	CKPT_HDR_FNAME,
 
 	CKPT_HDR_TASK = 101,
 	CKPT_HDR_THREAD,
@@ -51,6 +52,7 @@ enum {
 
 	CKPT_HDR_MM = 201,
 	CKPT_HDR_VMA,
+	CKPT_HDR_PGARR,
 	CKPT_HDR_MM_CONTEXT,
 
 	CKPT_HDR_TAIL = 5001
@@ -101,4 +103,41 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+/* memory layout */
+struct ckpt_hdr_mm {
+	struct ckpt_hdr h;
+	__u32 map_count;
+	__u32 _padding;
+
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+} __attribute__((aligned(8)));
+
+/* vma subtypes */
+enum vma_type {
+	CKPT_VMA_VDSO = 1,	/* special vdso vma */
+	CKPT_VMA_ANON,		/* private anonymous */
+	CKPT_VMA_FILE,		/* private mapped file */
+};
+
+/* vma decsriptor */
+struct ckpt_hdr_vma {
+	struct ckpt_hdr h;
+	__u32 vma_type;
+	__u32 _padding;
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+} __attribute__((aligned(8)));
+
+/* page array */
+struct ckpt_hdr_pgarr {
+	struct ckpt_hdr h;
+	__u64 nr_pages;		/* number of pages to saved */
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index b04090f..84b4ef4 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -10,6 +10,10 @@
  *  distribution for more details.
  */
 
+#include <linux/list.h>
+#include <linux/path.h>
+#include <linux/fs.h>
+
 #define CKPT_VERSION  1
 
 struct ckpt_ctx {
@@ -25,8 +29,14 @@ struct ckpt_ctx {
 
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
+
+	struct list_head pgarr_list;	/* page array to dump VMA contents */
+	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
+
+	struct path fs_mnt;	/* container root (FIXME) */
 };
 
+
 /* ckpt_ctx: flags */
 #define CKPT_CTX_CHECKPOINT	0x1
 #define CKPT_CTX_RESTART	0x2
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..2b58027 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,10 @@
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
 #include "internal.h"
 
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
+
 /*
  * FIXME: remove all knowledge of the buffer layer from the core VM
  */
@@ -1625,8 +1629,34 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+#ifdef CONFIG_CHECKPOINT
+static int filemap_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma)
+{
+	int ret;
+
+	/* should be private anonymous ... verify that this is the case */
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(!vma->vm_file);
+
+	ret = checkpoint_file(ctx, vma->vm_file);
+	if (ret < 0)
+		goto out;
+	ret = private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE);
+ out:
+	return ret;
+}
+#else
+#define filemap_checkpoint NULL
+#endif /* CONFIG_CHECKPOINT */
+
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.checkpoint	= filemap_checkpoint,
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/mmap.c b/mm/mmap.c
index 3303d1b..6b75359 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -34,6 +34,10 @@
 #include <asm/tlb.h>
 #include <asm/mmu_context.h>
 
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
+
 #include "internal.h"
 
 #ifndef arch_mmap_check
@@ -2268,9 +2272,35 @@ static void special_mapping_close(struct vm_area_struct *vma)
 {
 }
 
+#if CONFIG_CHEKCPOINT
+static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma)
+{
+	char *name;
+
+	/*
+	 * Currently, we only handle VDSO/vsyscall special handling.
+	 * Even that, is very basic - we just skip the contents and
+	 * hope for the best in terms of compatilibity upon restart.
+	 */
+
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED)
+		return -ENOSYS;
+
+	name = arch_vma_name(vma);
+	if (!name || strcmp(vma_name, "[vdso]"))
+		return -ENOSYS;
+
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO);
+}
+#else
+#define special_mapping_checkpoint NULL
+#endif /* CONFIG_CHECKPOINT */
+
 static struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
+	.checkpoint = special_mapping_checkpoint,
 };
 
 /*
-- 
1.5.4.3
