From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/12] Move mmap checkpoint/restart into mm/mmap.c
Date: Fri, 26 Feb 2010 00:45:10 -0800
Message-ID: <c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
	<385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Moving the memory pieces is more complicated because portions of it are
shared with ipc. Split the mm header bits into another
header file: include/linux/mm_checkpoint.h file so it's clear that these
are the only pieces we need in ipc/

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/Makefile           |    3 +-
 checkpoint/memory.c           | 1364 -----------------------------------------
 checkpoint/process.c          |    1 +
 checkpoint/sys.c              |    1 +
 include/linux/checkpoint.h    |   50 +--
 include/linux/mm.h            |   18 +
 include/linux/mm_checkpoint.h |   45 ++
 include/linux/proc_fs.h       |   19 -
 ipc/checkpoint.c              |    3 +-
 ipc/checkpoint_msg.c          |    3 +-
 ipc/checkpoint_sem.c          |    3 +-
 ipc/checkpoint_shm.c          |    3 +-
 ipc/shm.c                     |    2 +-
 mm/filemap.c                  |    2 +-
 mm/mmap.c                     | 1348 ++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c                    |    2 +-
 16 files changed, 1424 insertions(+), 1443 deletions(-)
 delete mode 100644 checkpoint/memory.c
 create mode 100644 include/linux/mm_checkpoint.h

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 5bc8468..9571af3 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -8,5 +8,4 @@ obj-$(CONFIG_CHECKPOINT) += \
 	checkpoint.o \
 	restart.o \
 	process.o \
-	namespace.o \
-	memory.o \
+	namespace.o
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
deleted file mode 100644
index e0b3b54..0000000
--- a/checkpoint/memory.c
+++ /dev/null
@@ -1,1364 +0,0 @@
-/*
- *  Checkpoint/restart memory contents
- *
- *  Copyright (C) 2008-2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DMEM
-
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/slab.h>
-#include <linux/file.h>
-#include <linux/aio.h>
-#include <linux/err.h>
-#include <linux/mm.h>
-#include <linux/mman.h>
-#include <linux/pagemap.h>
-#include <linux/mm_types.h>
-#include <linux/shm.h>
-#include <linux/proc_fs.h>
-#include <linux/swap.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-
-/*
- * page-array chains: each ckpt_pgarr describes a set of <struct page *,vaddr>
- * tuples (where vaddr is the virtual address of a page in a particular mm).
- * Specifically, we use separate arrays so that all vaddrs can be written
- * and read at once.
- */
-
-struct ckpt_pgarr {
-	unsigned long *vaddrs;
-	struct page **pages;
-	unsigned int nr_used;
-	struct list_head list;
-};
-
-#define CKPT_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
-#define CKPT_PGARR_BATCH  (16 * CKPT_PGARR_TOTAL)
-
-static inline int pgarr_is_full(struct ckpt_pgarr *pgarr)
-{
-	return (pgarr->nr_used == CKPT_PGARR_TOTAL);
-}
-
-static inline int pgarr_nr_free(struct ckpt_pgarr *pgarr)
-{
-	return CKPT_PGARR_TOTAL - pgarr->nr_used;
-}
-
-/*
- * utilities to alloc, free, and handle 'struct ckpt_pgarr' (page-arrays)
- * (common to ckpt_mem.c and rstr_mem.c).
- *
- * The checkpoint context structure has two members for page-arrays:
- *   ctx->pgarr_list: list head of populated page-array chain
- *   ctx->pgarr_pool: list head of empty page-array pool chain
- *
- * During checkpoint (and restart) the chain tracks the dirty pages (page
- * pointer and virtual address) of each MM. For a particular MM, these are
- * always added to the head of the page-array chain (ctx->pgarr_list).
- * Before the next chunk of pages, the chain is reset (by dereferencing
- * all pages) but not freed; instead, empty descsriptors are kept in pool.
- *
- * The head of the chain page-array ("current") advances as necessary. When
- * it gets full, a new page-array descriptor is pushed in front of it. The
- * new descriptor is taken from first empty descriptor (if one exists, for
- * instance, after a chain reset), or allocated on-demand.
- *
- * When dumping the data, the chain is traversed in reverse order.
- */
-
-/* return first page-array in the chain */
-static inline struct ckpt_pgarr *pgarr_first(struct ckpt_ctx *ctx)
-{
-	if (list_empty(&ctx->pgarr_list))
-		return NULL;
-	return list_first_entry(&ctx->pgarr_list, struct ckpt_pgarr, list);
-}
-
-/* return (and detach) first empty page-array in the pool, if exists */
-static inline struct ckpt_pgarr *pgarr_from_pool(struct ckpt_ctx *ctx)
-{
-	struct ckpt_pgarr *pgarr;
-
-	if (list_empty(&ctx->pgarr_pool))
-		return NULL;
-	pgarr = list_first_entry(&ctx->pgarr_pool, struct ckpt_pgarr, list);
-	list_del(&pgarr->list);
-	return pgarr;
-}
-
-/* release pages referenced by a page-array */
-static void pgarr_release_pages(struct ckpt_pgarr *pgarr)
-{
-	ckpt_debug("total pages %d\n", pgarr->nr_used);
-	/*
-	 * both checkpoint and restart use 'nr_used', however we only
-	 * collect pages during checkpoint; in restart we simply return
-	 * because pgarr->pages remains NULL.
-	 */
-	if (pgarr->pages) {
-		struct page **pages = pgarr->pages;
-		int nr = pgarr->nr_used;
-
-		while (nr--)
-			page_cache_release(pages[nr]);
-	}
-
-	pgarr->nr_used = 0;
-}
-
-/* free a single page-array object */
-static void pgarr_free_one(struct ckpt_pgarr *pgarr)
-{
-	pgarr_release_pages(pgarr);
-	kfree(pgarr->pages);
-	kfree(pgarr->vaddrs);
-	kfree(pgarr);
-}
-
-/* free the chains of page-arrays (populated and empty pool) */
-void ckpt_pgarr_free(struct ckpt_ctx *ctx)
-{
-	struct ckpt_pgarr *pgarr, *tmp;
-
-	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_list, list) {
-		list_del(&pgarr->list);
-		pgarr_free_one(pgarr);
-	}
-
-	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_pool, list) {
-		list_del(&pgarr->list);
-		pgarr_free_one(pgarr);
-	}
-}
-
-/* allocate a single page-array object */
-static struct ckpt_pgarr *pgarr_alloc_one(unsigned long flags)
-{
-	struct ckpt_pgarr *pgarr;
-
-	pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
-	if (!pgarr)
-		return NULL;
-	pgarr->vaddrs = kmalloc(CKPT_PGARR_TOTAL * sizeof(unsigned long),
-				GFP_KERNEL);
-	if (!pgarr->vaddrs)
-		goto nomem;
-
-	/* pgarr->pages is needed only for checkpoint */
-	if (flags & CKPT_CTX_CHECKPOINT) {
-		pgarr->pages = kmalloc(CKPT_PGARR_TOTAL *
-				       sizeof(struct page *), GFP_KERNEL);
-		if (!pgarr->pages)
-			goto nomem;
-	}
-
-	return pgarr;
- nomem:
-	pgarr_free_one(pgarr);
-	return NULL;
-}
-
-/* pgarr_current - return the next available page-array in the chain
- * @ctx: checkpoint context
- *
- * Returns the first page-array in the list that has space. Otherwise,
- * try the next page-array after the last non-empty one, and move it to
- * the front of the chain. Extends the list if none has space.
- */
-static struct ckpt_pgarr *pgarr_current(struct ckpt_ctx *ctx)
-{
-	struct ckpt_pgarr *pgarr;
-
-	pgarr = pgarr_first(ctx);
-	if (pgarr && !pgarr_is_full(pgarr))
-		return pgarr;
-
-	pgarr = pgarr_from_pool(ctx);
-	if (!pgarr)
-		pgarr = pgarr_alloc_one(ctx->kflags);
-	if (!pgarr)
-		return NULL;
-
-	list_add(&pgarr->list, &ctx->pgarr_list);
-	return pgarr;
-}
-
-/* reset the page-array chain (dropping page references if necessary) */
-static void pgarr_reset_all(struct ckpt_ctx *ctx)
-{
-	struct ckpt_pgarr *pgarr;
-
-	list_for_each_entry(pgarr, &ctx->pgarr_list, list)
-		pgarr_release_pages(pgarr);
-	list_splice_init(&ctx->pgarr_list, &ctx->pgarr_pool);
-}
-
-/**************************************************************************
- * Checkpoint
- *
- * Checkpoint is outside the context of the checkpointee, so one cannot
- * simply read pages from user-space. Instead, we scan the address space
- * of the target to cherry-pick pages of interest. Selected pages are
- * enlisted in a page-array chain (attached to the checkpoint context).
- * To save their contents, each page is mapped to kernel memory and then
- * dumped to the file descriptor.
- */
-
-/**
- * consider_private_page - return page pointer for dirty pages
- * @vma - target vma
- * @addr - page address
- *
- * Looks up the page that correspond to the address in the vma, and
- * returns the page if it was modified (and grabs a reference to it),
- * or otherwise returns NULL (or error).
- */
-static struct page *consider_private_page(struct vm_area_struct *vma,
-					  unsigned long addr)
-{
-	return __get_dirty_page(vma, addr);
-}
-
-/**
- * consider_shared_page - return page pointer for dirty pages
- * @ino - inode of shmem object
- * @idx - page index in shmem object
- *
- * Looks up the page that corresponds to the index in the shmem object,
- * and returns the page if it was modified (and grabs a reference to it),
- * or otherwise returns NULL (or error).
- */
-static struct page *consider_shared_page(struct inode *ino, unsigned long idx)
-{
-	struct page *page = NULL;
-	int ret;
-
-	/*
-	 * Inspired by do_shmem_file_read(): very simplified version.
-	 *
-	 * FIXME: consolidate with do_shmem_file_read()
-	 */
-
-	ret = shmem_getpage(ino, idx, &page, SGP_READ, NULL);
-	if (ret < 0)
-		return ERR_PTR(ret);
-
-	/*
-	 * Only care about dirty pages; shmem_getpage() only returns
-	 * pages that have been allocated, so they must be dirty. The
-	 * pages returned are locked and referenced.
-	 */
-
-	if (page) {
-		unlock_page(page);
-		/*
-		 * If users can be writing to this page using arbitrary
-		 * virtual addresses, take care about potential aliasing
-		 * before reading the page on the kernel side.
-		 */
-		if (mapping_writably_mapped(ino->i_mapping))
-			flush_dcache_page(page);
-		/*
-		 * Mark the page accessed if we read the beginning.
-		 */
-		mark_page_accessed(page);
-	}
-
-	return page;
-}
-
-/**
- * vma_fill_pgarr - fill a page-array with addr/page tuples
- * @ctx - checkpoint context
- * @vma - vma to scan
- * @start - start address (updated)
- *
- * Returns the number of pages collected
- */
-static int vma_fill_pgarr(struct ckpt_ctx *ctx,
-			  struct vm_area_struct *vma, struct inode *inode,
-			  unsigned long *start, unsigned long end)
-{
-	unsigned long addr = *start;
-	struct ckpt_pgarr *pgarr;
-	int nr_used;
-	int cnt = 0;
-
-	BUG_ON(inode && vma);
-
-	if (vma)
-		down_read(&vma->vm_mm->mmap_sem);
-	do {
-		pgarr = pgarr_current(ctx);
-		if (!pgarr) {
-			cnt = -ENOMEM;
-			goto out;
-		}
-
-		nr_used = pgarr->nr_used;
-
-		while (addr < end) {
-			struct page *page;
-
-			if (vma)
-				page = consider_private_page(vma, addr);
-			else
-				page = consider_shared_page(inode, addr);
-
-			if (IS_ERR(page)) {
-				cnt = PTR_ERR(page);
-				goto out;
-			}
-
-			if (page) {
-				_ckpt_debug(CKPT_DPAGE,
-					    "got page %#lx\n", addr);
-				pgarr->pages[pgarr->nr_used] = page;
-				pgarr->vaddrs[pgarr->nr_used] = addr;
-				pgarr->nr_used++;
-			}
-
-			if (vma)
-				addr += PAGE_SIZE;
-			else
-				addr++;
-
-			if (pgarr_is_full(pgarr))
-				break;
-		}
-
-		cnt += pgarr->nr_used - nr_used;
-
-	} while ((cnt < CKPT_PGARR_BATCH) && (addr < end));
- out:
-	if (vma)
-		up_read(&vma->vm_mm->mmap_sem);
-	*start = addr;
-	return cnt;
-}
-
-/* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
-int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page)
-{
-	void *ptr;
-
-	ptr = kmap_atomic(page, KM_USER1);
-	memcpy(ctx->scratch_page, ptr, PAGE_SIZE);
-	kunmap_atomic(ptr, KM_USER1);
-
-	return ckpt_kwrite(ctx, ctx->scratch_page, PAGE_SIZE);
-}
-
-/**
- * vma_dump_pages - dump pages listed in the ctx page-array chain
- * @ctx - checkpoint context
- * @total - total number of pages
- *
- * First dump all virtual addresses, followed by the contents of all pages
- */
-static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
-{
-	struct ckpt_pgarr *pgarr;
-	int i, ret = 0;
-
-	if (!total)
-		return 0;
-
-	i =  total * (sizeof(unsigned long) + PAGE_SIZE);
-	ret = ckpt_write_obj_type(ctx, NULL, i, CKPT_HDR_BUFFER);
-	if (ret < 0)
-		return ret;
-
-	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
-		ret = ckpt_kwrite(ctx, pgarr->vaddrs,
-				  pgarr->nr_used * sizeof(unsigned long));
-		if (ret < 0)
-			return ret;
-	}
-
-	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
-		for (i = 0; i < pgarr->nr_used; i++) {
-			ret = checkpoint_dump_page(ctx, pgarr->pages[i]);
-			if (ret < 0)
-				return ret;
-		}
-	}
-
-	return ret;
-}
-
-/**
- * checkpoint_memory_contents - dump contents of a memory region
- * @ctx - checkpoint context
- * @vma - vma to scan (--or--)
- * @inode - inode to scan
- *
- * Collect lists of pages that needs to be dumped, and corresponding
- * virtual addresses into ctx->pgarr_list page-array chain. Then dump
- * the addresses, followed by the page contents.
- */
-int checkpoint_memory_contents(struct ckpt_ctx *ctx,
-			       struct vm_area_struct *vma,
-			       struct inode *inode)
-{
-	struct ckpt_hdr_pgarr *h;
-	unsigned long addr, end;
-	int cnt, ret;
-
-	BUG_ON(vma && inode);
-
-	if (vma) {
-		addr = vma->vm_start;
-		end = vma->vm_end;
-	} else {
-		addr = 0;
-		end = PAGE_ALIGN(i_size_read(inode)) >> PAGE_CACHE_SHIFT;
-	}
-
-	/*
-	 * Work iteratively, collecting and dumping at most CKPT_PGARR_BATCH
-	 * in each round. Each iterations is divided into two steps:
-	 *
-	 * (1) scan: scan through the PTEs of the vma to collect the pages
-	 * to dump (later we'll also make them COW), while keeping a list
-	 * of pages and their corresponding addresses on ctx->pgarr_list.
-	 *
-	 * (2) dump: write out a header specifying how many pages, followed
-	 * by the addresses of all pages in ctx->pgarr_list, followed by
-	 * the actual contents of all pages. (Then, release the references
-	 * to the pages and reset the page-array chain).
-	 *
-	 * (This split makes the logic simpler by first counting the pages
-	 * that need saving. More importantly, it allows for a future
-	 * optimization that will reduce application downtime by deferring
-	 * the actual write-out of the data to after the application is
-	 * allowed to resume execution).
-	 *
-	 * After dumping the entire contents, conclude with a header that
-	 * specifies 0 pages to mark the end of the contents.
-	 */
-
-	while (addr < end) {
-		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
-		if (cnt == 0)
-			break;
-		else if (cnt < 0)
-			return cnt;
-
-		ckpt_debug("collected %d pages\n", cnt);
-
-		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
-		if (!h)
-			return -ENOMEM;
-
-		h->nr_pages = cnt;
-		ret = ckpt_write_obj(ctx, &h->h);
-		ckpt_hdr_put(ctx, h);
-		if (ret < 0)
-			return ret;
-
-		ret = vma_dump_pages(ctx, cnt);
-		if (ret < 0)
-			return ret;
-
-		pgarr_reset_all(ctx);
-	}
-
-	/* mark end of contents with header saying "0" pages */
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
-	if (!h)
-		return -ENOMEM;
-	h->nr_pages = 0;
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	return ret;
-}
-
-/**
- * generic_vma_checkpoint - dump metadata of vma
- * @ctx: checkpoint context
- * @vma: vma object
- * @type: vma type
- * @vma_objref: vma objref
- */
-int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
-			   enum vma_type type, int vma_objref, int ino_objref)
-{
-	struct ckpt_hdr_vma *h;
-	int ret;
-
-	ckpt_debug("vma %#lx-%#lx flags %#lx type %d\n",
-		 vma->vm_start, vma->vm_end, vma->vm_flags, type);
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_VMA);
-	if (!h)
-		return -ENOMEM;
-
-	h->vma_type = type;
-	h->vma_objref = vma_objref;
-	h->ino_objref = ino_objref;
-
-	if (vma->vm_file)
-		h->ino_size = i_size_read(vma->vm_file->f_dentry->d_inode);
-	else
-		h->ino_size = 0;
-
-	h->vm_start = vma->vm_start;
-	h->vm_end = vma->vm_end;
-	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
-	h->vm_flags = vma->vm_flags;
-	h->vm_pgoff = vma->vm_pgoff;
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	return ret;
-}
-
-/**
- * private_vma_checkpoint - dump contents of private (anon, file) vma
- * @ctx: checkpoint context
- * @vma: vma object
- * @type: vma type
- * @vma_objref: vma objref
- */
-int private_vma_checkpoint(struct ckpt_ctx *ctx,
-			   struct vm_area_struct *vma,
-			   enum vma_type type, int vma_objref)
-{
-	int ret;
-
-	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
-
-	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref, 0);
-	if (ret < 0)
-		goto out;
-	ret = checkpoint_memory_contents(ctx, vma, NULL);
- out:
-	return ret;
-}
-
-/**
- * shmem_vma_checkpoint - dump contents of private (anon, file) vma
- * @ctx: checkpoint context
- * @vma: vma object
- * @type: vma type
- * @objref: vma object id
- */
-int shmem_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
-			 enum vma_type type, int ino_objref)
-{
-	struct file *file = vma->vm_file;
-	int ret;
-
-	ckpt_debug("type %d, ino_ref %d\n", type, ino_objref);
-	BUG_ON(!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)));
-	BUG_ON(!file);
-
-	ret = generic_vma_checkpoint(ctx, vma, type, 0, ino_objref);
-	if (ret < 0)
-		goto out;
-	if (type == CKPT_VMA_SHM_ANON_SKIP)
-		goto out;
-	ret = checkpoint_memory_contents(ctx, NULL, file->f_dentry->d_inode);
- out:
-	return ret;
-}
-
-/**
- * anonymous_checkpoint - dump contents of private-anonymous vma
- * @ctx: checkpoint context
- * @vma: vma object
- */
-static int anonymous_checkpoint(struct ckpt_ctx *ctx,
-				struct vm_area_struct *vma)
-{
-	/* should be private anonymous ... verify that this is the case */
-	BUG_ON(vma->vm_flags & VM_MAYSHARE);
-	BUG_ON(vma->vm_file);
-
-	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
-}
-
-static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
-{
-	struct vm_area_struct *vma, *next;
-	int map_count = 0;
-	int ret = 0;
-
-	vma = kzalloc(sizeof(*vma), GFP_KERNEL);
-	if (!vma)
-		return -ENOMEM;
-
-	/*
-	 * Must not hold mm->mmap_sem when writing to image file, so
-	 * can't simply traverse the vma list. Instead, use find_vma()
-	 * to get the @next and make a local "copy" of it.
-	 */
-	while (1) {
-		down_read(&mm->mmap_sem);
-		next = find_vma(mm, vma->vm_end);
-		if (!next) {
-			up_read(&mm->mmap_sem);
-			break;
-		}
-		if (vma->vm_file)
-			fput(vma->vm_file);
-		*vma = *next;
-		if (vma->vm_file)
-			get_file(vma->vm_file);
-		up_read(&mm->mmap_sem);
-
-		map_count++;
-
-		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
-			 vma->vm_start, vma->vm_end, vma->vm_flags);
-
-		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
-			ckpt_err(ctx, -ENOSYS, "%(T)vma: bad flags (%#lx)\n",
-					vma->vm_flags);
-			ret = -ENOSYS;
-			break;
-		}
-
-		if (!vma->vm_ops)
-			ret = anonymous_checkpoint(ctx, vma);
-		else if (vma->vm_ops->checkpoint)
-			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
-		else
-			ret = -ENOSYS;
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "%(T)vma: failed\n");
-			break;
-		}
-		/*
-		 * The file was collected, but not always checkpointed;
-		 * be safe and mark as visited to appease leak detection
-		 */
-		if (vma->vm_file && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
-			ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
-			if (ret < 0)
-				break;
-		}
-	}
-
-	if (vma->vm_file)
-		fput(vma->vm_file);
-
-	kfree(vma);
-
-	return ret < 0 ? ret : map_count;
-}
-
-#define CKPT_AT_SZ (AT_VECTOR_SIZE * sizeof(u64))
-/*
- * We always write saved_auxv out as an array of u64s, though it is
- * an array of u32s on 32-bit arch.
- */
-static int ckpt_write_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
-{
-	int i, ret;
-	u64 *buf = kzalloc(CKPT_AT_SZ, GFP_KERNEL);
-
-	if (!buf)
-		return -ENOMEM;
-	for (i = 0; i < AT_VECTOR_SIZE; i++)
-		buf[i] = mm->saved_auxv[i];
-	ret = ckpt_write_buffer(ctx, buf, CKPT_AT_SZ);
-	kfree(buf);
-	return ret;
-}
-
-static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
-{
-	struct ckpt_hdr_mm *h;
-	struct file *exe_file = NULL;
-	int ret;
-
-	if (check_for_outstanding_aio(mm)) {
-		ckpt_err(ctx, -EBUSY, "(%T)Outstanding aio\n");
-		return -EBUSY;
-	}
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
-	if (!h)
-		return -ENOMEM;
-
-	down_read(&mm->mmap_sem);
-
-	h->flags = mm->flags;
-	h->def_flags = mm->def_flags;
-
-	h->start_code = mm->start_code;
-	h->end_code = mm->end_code;
-	h->start_data = mm->start_data;
-	h->end_data = mm->end_data;
-	h->start_brk = mm->start_brk;
-	h->brk = mm->brk;
-	h->start_stack = mm->start_stack;
-	h->arg_start = mm->arg_start;
-	h->arg_end = mm->arg_end;
-	h->env_start = mm->env_start;
-	h->env_end = mm->env_end;
-
-	h->map_count = mm->map_count;
-
-	if (mm->exe_file) {  /* checkpoint the ->exe_file */
-		exe_file = mm->exe_file;
-		get_file(exe_file);
-	}
-
-	/*
-	 * Drop mm->mmap_sem before writing data to checkpoint image
-	 * to avoid reverse locking order (inode must come before mm).
-	 */
-	up_read(&mm->mmap_sem);
-
-	if (exe_file) {
-		h->exe_objref = checkpoint_obj(ctx, exe_file, CKPT_OBJ_FILE);
-		if (h->exe_objref < 0) {
-			ret = h->exe_objref;
-			goto out;
-		}
-	}
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	if (ret < 0)
-		goto out;
-
-	ret = ckpt_write_auxv(ctx, mm);
-	if (ret < 0)
-		return ret;
-
-	ret = checkpoint_vmas(ctx, mm);
-	if (ret != h->map_count && ret >= 0)
-		ret = -EBUSY; /* checkpoint mm leak */
-	if (ret < 0)
-		goto out;
-
-	ret = checkpoint_mm_context(ctx, mm);
- out:
-	if (exe_file)
-		fput(exe_file);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr)
-{
-	return do_checkpoint_mm(ctx, (struct mm_struct *) ptr);
-}
-
-int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct mm_struct *mm;
-	int objref;
-
-	mm = get_task_mm(t);
-	objref = checkpoint_obj(ctx, mm, CKPT_OBJ_MM);
-	mmput(mm);
-
-	return objref;
-}
-
-/***********************************************************************
- * Collect
- */
-
-static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
-{
-	struct vm_area_struct *vma;
-	struct file *file;
-	int ret;
-
-	/* if already exists (ret == 0), nothing to do */
-	ret = ckpt_obj_collect(ctx, mm, CKPT_OBJ_MM);
-	if (ret <= 0)
-		return ret;
-
-	/* if first time for this mm (ret > 0), proceed inside */
-	down_read(&mm->mmap_sem);
-	if (mm->exe_file) {
-		ret = ckpt_collect_file(ctx, mm->exe_file);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "%(T)mm: collect exe_file\n");
-			goto out;
-		}
-	}
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		file = vma->vm_file;
-		if (!file)
-			continue;
-		ret = ckpt_collect_file(ctx, file);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "%(T)mm: collect vm_file\n");
-			break;
-		}
-	}
- out:
-	up_read(&mm->mmap_sem);
-	return ret;
-
-}
-
-int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct mm_struct *mm;
-	int ret;
-
-	mm = get_task_mm(t);
-	ret = collect_mm(ctx, mm);
-	mmput(mm);
-
-	return ret;
-}
-
-/***********************************************************************
- * Restart
- *
- * Unlike checkpoint, restart is executed in the context of each restarting
- * process: vma regions are restored via a call to mmap(), and the data is
- * read into the address space of the current process.
- */
-
-/**
- * read_pages_vaddrs - read addresses of pages to page-array chain
- * @ctx - restart context
- * @nr_pages - number of address to read
- */
-static int read_pages_vaddrs(struct ckpt_ctx *ctx, unsigned long nr_pages)
-{
-	struct ckpt_pgarr *pgarr;
-	unsigned long *vaddrp;
-	int nr, ret;
-
-	while (nr_pages) {
-		pgarr = pgarr_current(ctx);
-		if (!pgarr)
-			return -ENOMEM;
-		nr = pgarr_nr_free(pgarr);
-		if (nr > nr_pages)
-			nr = nr_pages;
-		vaddrp = &pgarr->vaddrs[pgarr->nr_used];
-		ret = ckpt_kread(ctx, vaddrp, nr * sizeof(unsigned long));
-		if (ret < 0)
-			return ret;
-		pgarr->nr_used += nr;
-		nr_pages -= nr;
-	}
-	return 0;
-}
-
-int restore_read_page(struct ckpt_ctx *ctx, struct page *page)
-{
-	void *ptr;
-	int ret;
-
-	ret = ckpt_kread(ctx, ctx->scratch_page, PAGE_SIZE);
-	if (ret < 0)
-		return ret;
-
-	ptr = kmap_atomic(page, KM_USER1);
-	memcpy(ptr, ctx->scratch_page, PAGE_SIZE);
-	kunmap_atomic(ptr, KM_USER1);
-
-	return 0;
-}
-
-static struct page *bring_private_page(unsigned long addr)
-{
-	struct page *page;
-	int ret;
-
-	ret = get_user_pages(current, current->mm, addr, 1, 1, 1, &page, NULL);
-	if (ret < 0)
-		page = ERR_PTR(ret);
-	return page;
-}
-
-static struct page *bring_shared_page(unsigned long idx, struct inode *ino)
-{
-	struct page *page = NULL;
-	int ret;
-
-	ret = shmem_getpage(ino, idx, &page, SGP_WRITE, NULL);
-	if (ret < 0)
-		return ERR_PTR(ret);
-	if (page)
-		unlock_page(page);
-	return page;
-}
-
-/**
- * read_pages_contents - read in data of pages in page-array chain
- * @ctx - restart context
- */
-static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
-{
-	struct ckpt_pgarr *pgarr;
-	unsigned long *vaddrs;
-	int i, ret;
-
-	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
-		vaddrs = pgarr->vaddrs;
-		for (i = 0; i < pgarr->nr_used; i++) {
-			struct page *page;
-
-			/* TODO: do in chunks to reduce mmap_sem overhead */
-			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
-			down_read(&current->mm->mmap_sem);
-			if (inode)
-				page = bring_shared_page(vaddrs[i], inode);
-			else
-				page = bring_private_page(vaddrs[i]);
-			up_read(&current->mm->mmap_sem);
-
-			if (IS_ERR(page))
-				return PTR_ERR(page);
-
-			ret = restore_read_page(ctx, page);
-			page_cache_release(page);
-
-			if (ret < 0)
-				return ret;
-		}
-	}
-	return 0;
-}
-
-/**
- * restore_memory_contents - restore contents of a memory region
- * @ctx - restart context
- * @inode - backing inode
- *
- * Reads a header that specifies how many pages will follow, then reads
- * a list of virtual addresses into ctx->pgarr_list page-array chain,
- * followed by the actual contents of the corresponding pages. Iterates
- * these steps until reaching a header specifying "0" pages, which marks
- * the end of the contents.
- */
-int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
-{
-	struct ckpt_hdr_pgarr *h;
-	unsigned long nr_pages;
-	int len, ret = 0;
-
-	while (1) {
-		h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
-		if (IS_ERR(h))
-			break;
-
-		ckpt_debug("total pages %ld\n", (unsigned long) h->nr_pages);
-
-		nr_pages = h->nr_pages;
-		ckpt_hdr_put(ctx, h);
-
-		if (!nr_pages)
-			break;
-
-		len = nr_pages * (sizeof(unsigned long) + PAGE_SIZE);
-		ret = _ckpt_read_buffer(ctx, NULL, len);
-		if (ret < 0)
-			break;
-
-		ret = read_pages_vaddrs(ctx, nr_pages);
-		if (ret < 0)
-			break;
-		ret = read_pages_contents(ctx, inode);
-		if (ret < 0)
-			break;
-		pgarr_reset_all(ctx);
-	}
-
-	return ret;
-}
-
-/**
- * calc_map_prot_bits - convert vm_flags to mmap protection
- * orig_vm_flags: source vm_flags
- */
-static unsigned long calc_map_prot_bits(unsigned long orig_vm_flags)
-{
-	unsigned long vm_prot = 0;
-
-	if (orig_vm_flags & VM_READ)
-		vm_prot |= PROT_READ;
-	if (orig_vm_flags & VM_WRITE)
-		vm_prot |= PROT_WRITE;
-	if (orig_vm_flags & VM_EXEC)
-		vm_prot |= PROT_EXEC;
-	if (orig_vm_flags & PROT_SEM)   /* only (?) with IPC-SHM  */
-		vm_prot |= PROT_SEM;
-
-	return vm_prot;
-}
-
-/**
- * calc_map_flags_bits - convert vm_flags to mmap flags
- * orig_vm_flags: source vm_flags
- */
-static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
-{
-	unsigned long vm_flags = 0;
-
-	vm_flags = MAP_FIXED;
-	if (orig_vm_flags & VM_GROWSDOWN)
-		vm_flags |= MAP_GROWSDOWN;
-	if (orig_vm_flags & VM_DENYWRITE)
-		vm_flags |= MAP_DENYWRITE;
-	if (orig_vm_flags & VM_EXECUTABLE)
-		vm_flags |= MAP_EXECUTABLE;
-	if (orig_vm_flags & VM_MAYSHARE)
-		vm_flags |= MAP_SHARED;
-	else
-		vm_flags |= MAP_PRIVATE;
-
-	return vm_flags;
-}
-
-/**
- * generic_vma_restore - restore a vma
- * @mm - address space
- * @file - file to map (NULL for anonymous)
- * @h - vma header data
- */
-unsigned long generic_vma_restore(struct mm_struct *mm,
-				  struct file *file,
-				  struct ckpt_hdr_vma *h)
-{
-	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
-	unsigned long addr;
-
-	if (h->vm_end < h->vm_start)
-		return -EINVAL;
-	if (h->vma_objref < 0)
-		return -EINVAL;
-
-	vm_start = h->vm_start;
-	vm_pgoff = h->vm_pgoff;
-	vm_size = h->vm_end - h->vm_start;
-	vm_prot = calc_map_prot_bits(h->vm_flags);
-	vm_flags = calc_map_flags_bits(h->vm_flags);
-
-	down_write(&mm->mmap_sem);
-	addr = do_mmap_pgoff(file, vm_start, vm_size,
-			     vm_prot, vm_flags, vm_pgoff);
-	up_write(&mm->mmap_sem);
-	ckpt_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
-		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
-
-	return addr;
-}
-
-/**
- * private_vma_restore - read vma data, recreate it and read contents
- * @ctx: checkpoint context
- * @mm: memory address space
- * @file: file to use for mapping
- * @h - vma header data
- */
-int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
-			struct file *file, struct ckpt_hdr_vma *h)
-{
-	unsigned long addr;
-
-	if (h->vm_flags & (VM_SHARED | VM_MAYSHARE))
-		return -EINVAL;
-
-	addr = generic_vma_restore(mm, file, h);
-	if (IS_ERR((void *) addr))
-		return PTR_ERR((void *) addr);
-
-	return restore_memory_contents(ctx, NULL);
-}
-
-/**
- * anon_private_restore - read vma data, recreate it and read contents
- * @ctx: checkpoint context
- * @mm: memory address space
- * @h - vma header data
- */
-static int anon_private_restore(struct ckpt_ctx *ctx,
-				     struct mm_struct *mm,
-				     struct ckpt_hdr_vma *h)
-{
-	/*
-	 * vm_pgoff for anonymous mapping is the "global" page
-	 * offset (namely from addr 0x0), so we force a zero
-	 */
-	h->vm_pgoff = 0;
-
-	return private_vma_restore(ctx, mm, NULL, h);
-}
-
-static int bad_vma_restore(struct ckpt_ctx *ctx,
-			   struct mm_struct *mm,
-			   struct ckpt_hdr_vma *h)
-{
-	return -EINVAL;
-}
-
-/* callbacks to restore vma per its type: */
-struct restore_vma_ops {
-	char *vma_name;
-	enum vma_type vma_type;
-	int (*restore) (struct ckpt_ctx *ctx,
-			struct mm_struct *mm,
-			struct ckpt_hdr_vma *ptr);
-};
-
-static struct restore_vma_ops restore_vma_ops[] = {
-	/* ignored vma */
-	{
-		.vma_name = "IGNORE",
-		.vma_type = CKPT_VMA_IGNORE,
-		.restore = NULL,
-	},
-	/* special mapping (vdso) */
-	{
-		.vma_name = "VDSO",
-		.vma_type = CKPT_VMA_VDSO,
-		.restore = special_mapping_restore,
-	},
-	/* anonymous private */
-	{
-		.vma_name = "ANON PRIVATE",
-		.vma_type = CKPT_VMA_ANON,
-		.restore = anon_private_restore,
-	},
-	/* file-mapped private */
-	{
-		.vma_name = "FILE PRIVATE",
-		.vma_type = CKPT_VMA_FILE,
-		.restore = filemap_restore,
-	},
-	/* anonymous shared */
-	{
-		.vma_name = "ANON SHARED",
-		.vma_type = CKPT_VMA_SHM_ANON,
-		.restore = shmem_restore,
-	},
-	/* anonymous shared (skipped) */
-	{
-		.vma_name = "ANON SHARED (skip)",
-		.vma_type = CKPT_VMA_SHM_ANON_SKIP,
-		.restore = shmem_restore,
-	},
-	/* file-mapped shared */
-	{
-		.vma_name = "FILE SHARED",
-		.vma_type = CKPT_VMA_SHM_FILE,
-		.restore = filemap_restore,
-	},
-	/* sysvipc shared */
-	{
-		.vma_name = "IPC SHARED",
-		.vma_type = CKPT_VMA_SHM_IPC,
-		/* ipc inode itself is restore by restore_ipc_ns()... */
-		.restore = bad_vma_restore,
-
-	},
-	/* sysvipc shared (skip) */
-	{
-		.vma_name = "IPC SHARED (skip)",
-		.vma_type = CKPT_VMA_SHM_IPC_SKIP,
-		.restore = ipcshm_restore,
-	},
-};
-
-/**
- * restore_vma - read vma data, recreate it and read contents
- * @ctx: checkpoint context
- * @mm: memory address space
- */
-static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
-{
-	struct ckpt_hdr_vma *h;
-	struct restore_vma_ops *ops;
-	int ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_VMA);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d inoref %d\n",
-		   (unsigned long) h->vm_start, (unsigned long) h->vm_end,
-		   (unsigned long) h->vm_flags, (int) h->vma_type,
-		   (int) h->vma_objref, (int) h->ino_objref);
-
-	ret = -EINVAL;
-	if (h->vm_end < h->vm_start)
-		goto out;
-	if (h->vma_objref < 0 || h->ino_objref < 0)
-		goto out;
-	if (h->vma_type >= CKPT_VMA_MAX)
-		goto out;
-	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
-		return -ENOSYS;
-
-	ops = &restore_vma_ops[h->vma_type];
-
-	/* make sure we don't change this accidentally */
-	BUG_ON(ops->vma_type != h->vma_type);
-
-	if (ops->restore) {
-		ckpt_debug("vma type %s\n", ops->vma_name);
-		ret = ops->restore(ctx, mm, h);
-	} else {
-		ckpt_debug("vma ignored\n");
-		ret = 0;
-	}
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int ckpt_read_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
-{
-	int i, ret;
-	u64 *buf = kmalloc(CKPT_AT_SZ, GFP_KERNEL);
-
-	if (!buf)
-		return -ENOMEM;
-	ret = _ckpt_read_buffer(ctx, buf, CKPT_AT_SZ);
-	if (ret < 0)
-		goto out;
-
-	ret = -E2BIG;
-	for (i = 0; i < AT_VECTOR_SIZE; i++)
-		if (buf[i] > (u64) ULONG_MAX)
-			goto out;
-
-	for (i = 0; i < AT_VECTOR_SIZE - 1; i++)
-		mm->saved_auxv[i] = buf[i];
-	/* sanitize the input: force AT_NULL in last entry  */
-	mm->saved_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
-
-	ret = 0;
- out:
-	kfree(buf);
-	return ret;
-}
-
-static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_mm *h;
-	struct mm_struct *mm = NULL;
-	struct file *file;
-	unsigned int nr;
-	int ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM);
-	if (IS_ERR(h))
-		return (struct mm_struct *) h;
-
-	ckpt_debug("map_count %d\n", h->map_count);
-
-	/* XXX need more sanity checks */
-
-	ret = -EINVAL;
-	if ((h->start_code > h->end_code) ||
-	    (h->start_data > h->end_data))
-		goto out;
-	if (h->exe_objref < 0)
-		goto out;
-	if (h->def_flags & ~VM_LOCKED)
-		goto out;
-	if (h->flags & ~(MMF_DUMP_FILTER_MASK |
-			 ((1 << MMF_DUMP_FILTER_BITS) - 1)))
-		goto out;
-
-	mm = current->mm;
-
-	/* point of no return -- destruct current mm */
-	down_write(&mm->mmap_sem);
-	ret = destroy_mm(mm);
-	if (ret < 0) {
-		up_write(&mm->mmap_sem);
-		goto out;
-	}
-
-	mm->flags = h->flags;
-	mm->def_flags = h->def_flags;
-
-	mm->start_code = h->start_code;
-	mm->end_code = h->end_code;
-	mm->start_data = h->start_data;
-	mm->end_data = h->end_data;
-	mm->start_brk = h->start_brk;
-	mm->brk = h->brk;
-	mm->start_stack = h->start_stack;
-	mm->arg_start = h->arg_start;
-	mm->arg_end = h->arg_end;
-	mm->env_start = h->env_start;
-	mm->env_end = h->env_end;
-
-	/* restore the ->exe_file */
-	if (h->exe_objref) {
-		file = ckpt_obj_fetch(ctx, h->exe_objref, CKPT_OBJ_FILE);
-		if (IS_ERR(file)) {
-			up_write(&mm->mmap_sem);
-			ret = PTR_ERR(file);
-			goto out;
-		}
-		set_mm_exe_file(mm, file);
-	}
-	up_write(&mm->mmap_sem);
-
-	ret = ckpt_read_auxv(ctx, mm);
-	if (ret < 0) {
-		ckpt_err(ctx, ret, "Error restoring auxv\n");
-		goto out;
-	}
-
-	for (nr = h->map_count; nr; nr--) {
-		ret = restore_vma(ctx, mm);
-		if (ret < 0)
-			goto out;
-	}
-
-	ret = restore_mm_context(ctx, mm);
- out:
-	ckpt_hdr_put(ctx, h);
-	if (ret < 0)
-		return ERR_PTR(ret);
-	/* restore_obj() expect an extra reference */
-	atomic_inc(&mm->mm_users);
-	return mm;
-}
-
-void *restore_mm(struct ckpt_ctx *ctx)
-{
-	return (void *) do_restore_mm(ctx);
-}
-
-int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref)
-{
-	struct mm_struct *mm;
-	int ret;
-
-	mm = ckpt_obj_fetch(ctx, mm_objref, CKPT_OBJ_MM);
-	if (IS_ERR(mm))
-		return PTR_ERR(mm);
-
-	if (mm == current->mm)
-		return 0;
-
-	ret = exec_mmap(mm);
-	if (ret < 0)
-		return ret;
-
-	atomic_inc(&mm->mm_users);
-	return 0;
-}
diff --git a/checkpoint/process.c b/checkpoint/process.c
index f917112..6e3e382 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -21,6 +21,7 @@
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
 #include <linux/syscalls.h>
 
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index d34ff98..a420c02 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -21,6 +21,7 @@
 #include <linux/uaccess.h>
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
+#include <linux/mm_checkpoint.h> /* for ckpt_pgarr_free() */
 #include <linux/deferqueue.h>
 
 /*
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7a06272..0fc3f70 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -101,9 +101,6 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
-extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
-extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
-
 /* pids */
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
 extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
@@ -174,6 +171,9 @@ extern int ckpt_obj_reserve(struct ckpt_ctx *ctx);
 extern struct ckpt_ctx *ckpt_ctx_get(struct ckpt_ctx *ctx);
 extern void ckpt_ctx_put(struct ckpt_ctx *ctx);
 
+extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
+extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
+
 extern long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid);
 extern long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags);
 
@@ -189,12 +189,10 @@ extern void post_restore_task(void);
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
 extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
-extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
-extern int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
@@ -261,48 +259,6 @@ extern void *restore_cred(struct ckpt_ctx *ctx);
 
 extern int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_userns(struct ckpt_ctx *ctx);
-
-/* memory */
-extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
-
-extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
-				  struct vm_area_struct *vma,
-				  enum vma_type type,
-				  int vma_objref, int ino_objref);
-extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
-				  struct vm_area_struct *vma,
-				  enum vma_type type,
-				  int vma_objref);
-extern int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
-				struct vm_area_struct *vma,
-				enum vma_type type,
-				int ino_objref);
-
-extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
-extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
-
-extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
-extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
-extern void *restore_mm(struct ckpt_ctx *ctx);
-
-extern unsigned long generic_vma_restore(struct mm_struct *mm,
-					 struct file *file,
-					 struct ckpt_hdr_vma *h);
-
-extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
-			       struct file *file, struct ckpt_hdr_vma *h);
-
-extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
-				      struct vm_area_struct *vma,
-				      struct inode *inode);
-extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
-
-
-#define CKPT_VMA_NOT_SUPPORTED						\
-	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
-	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
-	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
-
 /* signals */
 extern int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 210d8e3..2459d1d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1303,8 +1303,26 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
 #ifdef CONFIG_PROC_FS
+/* Set/Get/Dup a reference to the file /proc/<pid>/exe symlinks to. */
+extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
+extern struct file *get_mm_exe_file(struct mm_struct *mm);
+extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
+
 void vm_stat_account(struct mm_struct *, unsigned long, struct file *, long);
 #else
+static inline void set_mm_exe_file(struct mm_struct *mm,
+				   struct file *new_exe_file)
+{}
+
+static inline struct file *get_mm_exe_file(struct mm_struct *mm)
+{
+	return NULL;
+}
+
+static inline void dup_mm_exe_file(struct mm_struct *oldmm,
+				   struct mm_struct *newmm)
+{}
+
 static inline void vm_stat_account(struct mm_struct *mm,
 			unsigned long flags, struct file *file, long pages)
 {
diff --git a/include/linux/mm_checkpoint.h b/include/linux/mm_checkpoint.h
new file mode 100644
index 0000000..0092321
--- /dev/null
+++ b/include/linux/mm_checkpoint.h
@@ -0,0 +1,45 @@
+#ifndef _LINUX_MM_CHECKPOINT_H
+#define _LINUX_MM_CHECKPOINT_H
+
+#include <linux/checkpoint.h> /* for ckpt_obj_fetch, restore_read_page */
+#include <linux/checkpoint_hdr.h> /* for struct ckpt_hdr_vma */
+#include <linux/checkpoint_types.h> /* for struct ckpt_ctx */
+
+extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
+
+extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
+
+extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+
+extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma,
+				      struct inode *inode);
+extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
+
+/* common vma checkpoint/restore operations */
+extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type,
+				  int vma_objref, int ino_objref);
+extern unsigned long generic_vma_restore(struct mm_struct *mm,
+					 struct file *file,
+					 struct ckpt_hdr_vma *h);
+extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type,
+				  int vma_objref);
+extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			       struct file *file, struct ckpt_hdr_vma *h);
+extern int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
+				struct vm_area_struct *vma,
+				enum vma_type type,
+				int ino_objref);
+
+
+#define CKPT_VMA_NOT_SUPPORTED						\
+	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
+	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
+	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
+
+#endif /* _LINUX_MM_CHECKPOINT_H */
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 379eaed..e187078 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -173,12 +173,6 @@ extern void proc_net_remove(struct net *net, const char *name);
 extern struct proc_dir_entry *proc_net_mkdir(struct net *net, const char *name,
 	struct proc_dir_entry *parent);
 
-/* While the {get|set|dup}_mm_exe_file functions are for mm_structs, they are
- * only needed to implement /proc/<pid>|self/exe so we define them here. */
-extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
-extern struct file *get_mm_exe_file(struct mm_struct *mm);
-extern void dup_mm_exe_file(struct mm_struct *oldmm, struct mm_struct *newmm);
-
 #else
 
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
@@ -226,19 +220,6 @@ static inline void pid_ns_release_proc(struct pid_namespace *ns)
 {
 }
 
-static inline void set_mm_exe_file(struct mm_struct *mm,
-				   struct file *new_exe_file)
-{}
-
-static inline struct file *get_mm_exe_file(struct mm_struct *mm)
-{
-	return NULL;
-}
-
-static inline void dup_mm_exe_file(struct mm_struct *oldmm,
-	       			   struct mm_struct *newmm)
-{}
-
 #endif /* CONFIG_PROC_FS */
 
 #if !defined(CONFIG_PROC_KCORE)
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 4322dea..2b05067 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -15,8 +15,7 @@
 #include <linux/msg.h>
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
 
 #include "util.h"
 
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 61b3d78..51fb712 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -22,8 +22,7 @@
 
 #include "util.h"
 
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
 
 /************************************************************************
  * ipc checkpoint
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 395c84d..d1a9ba1 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -22,8 +22,7 @@
 struct msg_msg;
 #include "util.h"
 
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
 
 /************************************************************************
  * ipc checkpoint
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 01091d9..f06cfda 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -26,8 +26,7 @@
 #include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
 #include "util.h"
 
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
 
 /************************************************************************
  * ipc checkpoint
diff --git a/ipc/shm.c b/ipc/shm.c
index 18ae1b8..f4c3cea 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -39,7 +39,7 @@
 #include <linux/nsproxy.h>
 #include <linux/mount.h>
 #include <linux/ipc_namespace.h>
-#include <linux/checkpoint.h>
+#include <linux/mm_checkpoint.h>
 
 #include <asm/uaccess.h>
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 4ea28e6..1495ec0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,7 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
-#include <linux/checkpoint.h>
+#include <linux/mm_checkpoint.h>
 #include "internal.h"
 
 /*
diff --git a/mm/mmap.c b/mm/mmap.c
index b19a754..c934021 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -29,6 +29,8 @@
 #include <linux/mmu_notifier.h>
 #include <linux/perf_event.h>
 #include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/mm_checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2624,6 +2626,1352 @@ void mm_drop_all_locks(struct mm_struct *mm)
 }
 
 #ifdef CONFIG_CHECKPOINT
+/* default debug level for output */
+#undef CKPT_DFLAG
+#define CKPT_DFLAG  CKPT_DMEM
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
+#define CKPT_PGARR_BATCH  (16 * CKPT_PGARR_TOTAL)
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
+		pgarr = pgarr_alloc_one(ctx->kflags);
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
+/**************************************************************************
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
+/**
+ * consider_private_page - return page pointer for dirty pages
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
+	return __get_dirty_page(vma, addr);
+}
+
+/**
+ * consider_shared_page - return page pointer for dirty pages
+ * @ino - inode of shmem object
+ * @idx - page index in shmem object
+ *
+ * Looks up the page that corresponds to the index in the shmem object,
+ * and returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ */
+static struct page *consider_shared_page(struct inode *ino, unsigned long idx)
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
+	ret = shmem_getpage(ino, idx, &page, SGP_READ, NULL);
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
+		if (mapping_writably_mapped(ino->i_mapping))
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
+ * vma_fill_pgarr - fill a page-array with addr/page tuples
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ * @start - start address (updated)
+ *
+ * Returns the number of pages collected
+ */
+static int vma_fill_pgarr(struct ckpt_ctx *ctx,
+			  struct vm_area_struct *vma, struct inode *inode,
+			  unsigned long *start, unsigned long end)
+{
+	unsigned long addr = *start;
+	struct ckpt_pgarr *pgarr;
+	int nr_used;
+	int cnt = 0;
+
+	BUG_ON(inode && vma);
+
+	if (vma)
+		down_read(&vma->vm_mm->mmap_sem);
+	do {
+		pgarr = pgarr_current(ctx);
+		if (!pgarr) {
+			cnt = -ENOMEM;
+			goto out;
+		}
+
+		nr_used = pgarr->nr_used;
+
+		while (addr < end) {
+			struct page *page;
+
+			if (vma)
+				page = consider_private_page(vma, addr);
+			else
+				page = consider_shared_page(inode, addr);
+
+			if (IS_ERR(page)) {
+				cnt = PTR_ERR(page);
+				goto out;
+			}
+
+			if (page) {
+				_ckpt_debug(CKPT_DPAGE,
+					    "got page %#lx\n", addr);
+				pgarr->pages[pgarr->nr_used] = page;
+				pgarr->vaddrs[pgarr->nr_used] = addr;
+				pgarr->nr_used++;
+			}
+
+			if (vma)
+				addr += PAGE_SIZE;
+			else
+				addr++;
+
+			if (pgarr_is_full(pgarr))
+				break;
+		}
+
+		cnt += pgarr->nr_used - nr_used;
+
+	} while ((cnt < CKPT_PGARR_BATCH) && (addr < end));
+ out:
+	if (vma)
+		up_read(&vma->vm_mm->mmap_sem);
+	*start = addr;
+	return cnt;
+}
+
+/* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
+int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page)
+{
+	void *ptr;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(ctx->scratch_page, ptr, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
+
+	return ckpt_kwrite(ctx, ctx->scratch_page, PAGE_SIZE);
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
+	int i, ret = 0;
+
+	if (!total)
+		return 0;
+
+	i =  total * (sizeof(unsigned long) + PAGE_SIZE);
+	ret = ckpt_write_obj_type(ctx, NULL, i, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		ret = ckpt_kwrite(ctx, pgarr->vaddrs,
+				  pgarr->nr_used * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+	}
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		for (i = 0; i < pgarr->nr_used; i++) {
+			ret = checkpoint_dump_page(ctx, pgarr->pages[i]);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return ret;
+}
+
+/**
+ * checkpoint_memory_contents - dump contents of a memory region
+ * @ctx - checkpoint context
+ * @vma - vma to scan (--or--)
+ * @inode - inode to scan
+ *
+ * Collect lists of pages that needs to be dumped, and corresponding
+ * virtual addresses into ctx->pgarr_list page-array chain. Then dump
+ * the addresses, followed by the page contents.
+ */
+int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+			       struct vm_area_struct *vma,
+			       struct inode *inode)
+{
+	struct ckpt_hdr_pgarr *h;
+	unsigned long addr, end;
+	int cnt, ret;
+
+	BUG_ON(vma && inode);
+
+	if (vma) {
+		addr = vma->vm_start;
+		end = vma->vm_end;
+	} else {
+		addr = 0;
+		end = PAGE_ALIGN(i_size_read(inode)) >> PAGE_CACHE_SHIFT;
+	}
+
+	/*
+	 * Work iteratively, collecting and dumping at most CKPT_PGARR_BATCH
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
+	 * After dumping the entire contents, conclude with a header that
+	 * specifies 0 pages to mark the end of the contents.
+	 */
+
+	while (addr < end) {
+		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
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
+		ret = ckpt_write_obj(ctx, &h->h);
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
+	ret = ckpt_write_obj(ctx, &h->h);
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
+ * @vma_objref: vma objref
+ */
+int generic_vma_checkpoint(struct ckpt_ctx *ctx,
+			   struct vm_area_struct *vma,
+			   enum vma_type type, int vma_objref,
+			   int ino_objref)
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
+	h->ino_objref = ino_objref;
+
+	if (vma->vm_file)
+		h->ino_size = i_size_read(vma->vm_file->f_dentry->d_inode);
+	else
+		h->ino_size = 0;
+
+	h->vm_start = vma->vm_start;
+	h->vm_end = vma->vm_end;
+	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	h->vm_flags = vma->vm_flags;
+	h->vm_pgoff = vma->vm_pgoff;
+
+	ret = ckpt_write_obj(ctx, &h->h);
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
+ * @vma_objref: vma objref
+ */
+int private_vma_checkpoint(struct ckpt_ctx *ctx,
+			   struct vm_area_struct *vma,
+			   enum vma_type type, int vma_objref)
+{
+	int ret;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref, 0);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, vma, NULL);
+ out:
+	return ret;
+}
+
+/**
+ * shmem_vma_checkpoint - dump contents of private (anon, file) vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @objref: vma object id
+ */
+int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
+			 struct vm_area_struct *vma,
+			 enum vma_type type, int ino_objref)
+{
+	struct file *file = vma->vm_file;
+	int ret;
+
+	ckpt_debug("type %d, ino_ref %d\n", type, ino_objref);
+	BUG_ON(!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)));
+	BUG_ON(!file);
+
+	ret = generic_vma_checkpoint(ctx, vma, type, 0, ino_objref);
+	if (ret < 0)
+		goto out;
+	if (type == CKPT_VMA_SHM_ANON_SKIP)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, NULL, file->f_dentry->d_inode);
+ out:
+	return ret;
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
+			ckpt_err(ctx, -ENOSYS, "%(T)vma: bad flags (%#lx)\n",
+					vma->vm_flags);
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
+			ckpt_err(ctx, ret, "%(T)vma: failed\n");
+			break;
+		}
+		/*
+		 * The file was collected, but not always checkpointed;
+		 * be safe and mark as visited to appease leak detection
+		 */
+		if (vma->vm_file && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
+			ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
+			if (ret < 0)
+				break;
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
+/* Defined by arch */
+extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
+
+static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm *h;
+	struct file *exe_file = NULL;
+	int ret;
+
+	if (check_for_outstanding_aio(mm)) {
+		ckpt_err(ctx, -EBUSY, "(%T)Outstanding aio\n");
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
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_mm(ctx, (struct mm_struct *) ptr);
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
+ * Collect
+ */
+
+static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	struct file *file;
+	int ret;
+
+	/* if already exists (ret == 0), nothing to do */
+	ret = ckpt_obj_collect(ctx, mm, CKPT_OBJ_MM);
+	if (ret <= 0)
+		return ret;
+
+	/* if first time for this mm (ret > 0), proceed inside */
+	down_read(&mm->mmap_sem);
+	if (mm->exe_file) {
+		ret = ckpt_collect_file(ctx, mm->exe_file);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "%(T)mm: collect exe_file\n");
+			goto out;
+		}
+	}
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		file = vma->vm_file;
+		if (!file)
+			continue;
+		ret = ckpt_collect_file(ctx, file);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "%(T)mm: collect vm_file\n");
+			break;
+		}
+	}
+ out:
+	up_read(&mm->mmap_sem);
+	return ret;
+
+}
+
+int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = get_task_mm(t);
+	ret = collect_mm(ctx, mm);
+	mmput(mm);
+
+	return ret;
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
+/**
+ * read_pages_vaddrs - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @nr_pages - number of address to read
+ */
+static int read_pages_vaddrs(struct ckpt_ctx *ctx, unsigned long nr_pages)
+{
+	struct ckpt_pgarr *pgarr;
+	unsigned long *vaddrp;
+	int nr, ret;
+
+	while (nr_pages) {
+		pgarr = pgarr_current(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+		nr = pgarr_nr_free(pgarr);
+		if (nr > nr_pages)
+			nr = nr_pages;
+		vaddrp = &pgarr->vaddrs[pgarr->nr_used];
+		ret = ckpt_kread(ctx, vaddrp, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nr_used += nr;
+		nr_pages -= nr;
+	}
+	return 0;
+}
+
+int restore_read_page(struct ckpt_ctx *ctx, struct page *page)
+{
+	void *ptr;
+	int ret;
+
+	ret = ckpt_kread(ctx, ctx->scratch_page, PAGE_SIZE);
+	if (ret < 0)
+		return ret;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(ptr, ctx->scratch_page, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
+
+	return 0;
+}
+
+static struct page *bring_private_page(unsigned long addr)
+{
+	struct page *page;
+	int ret;
+
+	ret = get_user_pages(current, current->mm, addr, 1, 1, 1, &page, NULL);
+	if (ret < 0)
+		page = ERR_PTR(ret);
+	return page;
+}
+
+static struct page *bring_shared_page(unsigned long idx, struct inode *ino)
+{
+	struct page *page = NULL;
+	int ret;
+
+	ret = shmem_getpage(ino, idx, &page, SGP_WRITE, NULL);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	if (page)
+		unlock_page(page);
+	return page;
+}
+
+/**
+ * read_pages_contents - read in data of pages in page-array chain
+ * @ctx - restart context
+ */
+static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
+{
+	struct ckpt_pgarr *pgarr;
+	unsigned long *vaddrs;
+	int i, ret;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		vaddrs = pgarr->vaddrs;
+		for (i = 0; i < pgarr->nr_used; i++) {
+			struct page *page;
+
+			/* TODO: do in chunks to reduce mmap_sem overhead */
+			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
+			down_read(&current->mm->mmap_sem);
+			if (inode)
+				page = bring_shared_page(vaddrs[i], inode);
+			else
+				page = bring_private_page(vaddrs[i]);
+			up_read(&current->mm->mmap_sem);
+
+			if (IS_ERR(page))
+				return PTR_ERR(page);
+
+			ret = restore_read_page(ctx, page);
+			page_cache_release(page);
+
+			if (ret < 0)
+				return ret;
+		}
+	}
+	return 0;
+}
+
+/**
+ * restore_memory_contents - restore contents of a memory region
+ * @ctx - restart context
+ * @inode - backing inode
+ *
+ * Reads a header that specifies how many pages will follow, then reads
+ * a list of virtual addresses into ctx->pgarr_list page-array chain,
+ * followed by the actual contents of the corresponding pages. Iterates
+ * these steps until reaching a header specifying "0" pages, which marks
+ * the end of the contents.
+ */
+int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
+{
+	struct ckpt_hdr_pgarr *h;
+	unsigned long nr_pages;
+	int len, ret = 0;
+
+	while (1) {
+		h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
+		if (IS_ERR(h))
+			break;
+
+		ckpt_debug("total pages %ld\n", (unsigned long) h->nr_pages);
+
+		nr_pages = h->nr_pages;
+		ckpt_hdr_put(ctx, h);
+
+		if (!nr_pages)
+			break;
+
+		len = nr_pages * (sizeof(unsigned long) + PAGE_SIZE);
+		ret = _ckpt_read_buffer(ctx, NULL, len);
+		if (ret < 0)
+			break;
+
+		ret = read_pages_vaddrs(ctx, nr_pages);
+		if (ret < 0)
+			break;
+		ret = read_pages_contents(ctx, inode);
+		if (ret < 0)
+			break;
+		pgarr_reset_all(ctx);
+	}
+
+	return ret;
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
+unsigned long generic_vma_restore(struct mm_struct *mm,
+				  struct file *file,
+				  struct ckpt_hdr_vma *h)
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
+int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			struct file *file, struct ckpt_hdr_vma *h)
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
+	return restore_memory_contents(ctx, NULL);
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
+static int bad_vma_restore(struct ckpt_ctx *ctx,
+			   struct mm_struct *mm,
+			   struct ckpt_hdr_vma *h)
+{
+	return -EINVAL;
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
+	/* anonymous shared */
+	{
+		.vma_name = "ANON SHARED",
+		.vma_type = CKPT_VMA_SHM_ANON,
+		.restore = shmem_restore,
+	},
+	/* anonymous shared (skipped) */
+	{
+		.vma_name = "ANON SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_ANON_SKIP,
+		.restore = shmem_restore,
+	},
+	/* file-mapped shared */
+	{
+		.vma_name = "FILE SHARED",
+		.vma_type = CKPT_VMA_SHM_FILE,
+		.restore = filemap_restore,
+	},
+	/* sysvipc shared */
+	{
+		.vma_name = "IPC SHARED",
+		.vma_type = CKPT_VMA_SHM_IPC,
+		/* ipc inode itself is restore by restore_ipc_ns()... */
+		.restore = bad_vma_restore,
+
+	},
+	/* sysvipc shared (skip) */
+	{
+		.vma_name = "IPC SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_IPC_SKIP,
+		.restore = ipcshm_restore,
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
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d inoref %d\n",
+		   (unsigned long) h->vm_start, (unsigned long) h->vm_end,
+		   (unsigned long) h->vm_flags, (int) h->vma_type,
+		   (int) h->vma_objref, (int) h->ino_objref);
+
+	ret = -EINVAL;
+	if (h->vm_end < h->vm_start)
+		goto out;
+	if (h->vma_objref < 0 || h->ino_objref < 0)
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
+	ckpt_hdr_put(ctx, h);
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
+extern int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
+
+static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_mm *h;
+	struct mm_struct *mm = NULL;
+	struct file *file;
+	unsigned int nr;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (IS_ERR(h))
+		return (struct mm_struct *) h;
+
+	ckpt_debug("map_count %d\n", h->map_count);
+
+	/* XXX need more sanity checks */
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
+		ckpt_err(ctx, ret, "Error restoring auxv\n");
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
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	/* restore_obj() expect an extra reference */
+	atomic_inc(&mm->mm_users);
+	return mm;
+}
+
+static void *restore_mm(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_mm(ctx);
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
 static int obj_mm_grab(void *ptr)
 {
 	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
diff --git a/mm/shmem.c b/mm/shmem.c
index e103155..3696342 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -29,7 +29,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/swap.h>
-#include <linux/checkpoint.h>
+#include <linux/mm_checkpoint.h>
 
 static struct vfsmount *shm_mnt;
 
-- 
1.6.3.3
