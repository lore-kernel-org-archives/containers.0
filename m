From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Cleanups for [PATCH 4/9] Memory management (dump)
Date: Wed, 10 Sep 2008 14:03:51 -0700
Message-ID: <1221080631.6781.57.camel__1757.62580843202$1221080884$gmane$org@nimitz>
References: <1220946154-15174-1-git-send-email-orenl@cs.columbia.edu>
	<1220946154-15174-5-git-send-email-orenl@cs.columbia.edu>
	<1221065728.6781.19.camel@nimitz>  <48C811C5.9000102@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C811C5.9000102-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a lot of changes.  But, they're all kinda intertwined
so it's hard to make individual patches out of them.  I've
tried to explain each of the changes as you look through
the patch sequentially.

Note that this patch removes more code than it adds, and I think it
makes everything more readable.  There are a few things I need to fix up
in the restore patch (like the use of nr_free), but nothing really
fundamental.

- Remove use of get_free_pages() for buffers, use kmalloc()
  for its debugging advantages, and not having to deal with
  "orders".
- Now that we use kfree(), don't check for NULL pages/vaddr
  since kfree() does it for us.
- Zero out the pgarr as we remove things from it.  Bug
  hunters will thank us.
- Change ctx->pgarr name to pgarr_list.
- Change the ordering of the pgarr_list so that the first
  entry is always the old "pgcurr".  Make a function to
  find the first entry, and kill "pgcurr".
- Get rid of pgarr->nr_free.  It's redundant with nr_used
  and the fixed-size allocation of all pgarrs.  Create
  a helper function (pgarr_is_full()) to replace it.
- Remove cr_pgarr_prep(), just use cr_pgarr_alloc().
- Create cr_add_to_pgarr() helper which also does some
  checking of the page states that come back from
  follow_page().
- Rename cr_vma_fill_pgarr() to cr_private_vma() to make
  it painfully obvious that it does not deal with
  shared memory of any kind.
- Don't fault in pages with handle_mm_fault(), we do not
  need them to be present, nor should we be wasting
  space on pagetables that need to be created for sparse
  memory areas.
- Add parenthesis around 'page_mapping(page) != NULL' check
- Don't bother releasing pgarr pages for a VMA since it
  will never free all of the VMA's pages anyway
- Don't track total pages.  If we really need this, we can
  track the number of full 'pgarr's on the list, and add
  the used pages from the first one.
- Reverse list iteration since we changed the list order
- Give cr_pgarr_reset() a better name: cr_reset_all_pgarrs()



---

 linux-2.6.git-dave/checkpoint/ckpt_mem.c |  262 +++++++++++++------------------
 linux-2.6.git-dave/checkpoint/ckpt_mem.h |    3 
 linux-2.6.git-dave/include/linux/ckpt.h  |    4 
 3 files changed, 115 insertions(+), 154 deletions(-)

diff -puN checkpoint/ckpt_mem.c~p4-dave checkpoint/ckpt_mem.c
--- linux-2.6.git/checkpoint/ckpt_mem.c~p4-dave	2008-09-10 13:58:55.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_mem.c	2008-09-10 14:00:04.000000000 -0700
@@ -25,41 +25,41 @@
  * (common to ckpt_mem.c and rstr_mem.c).
  *
  * The checkpoint context structure has two members for page-arrays:
- *   ctx->pgarr: list head of the page-array chain
- *   ctx->pgcur: tracks the "current" position in the chain
+ *   ctx->pgarr_list: list head of the page-array chain
  *
  * During checkpoint (and restart) the chain tracks the dirty pages (page
  * pointer and virtual address) of each MM. For a particular MM, these are
- * always added to the "current" page-array (ctx->pgcur). The "current"
+ * always added to the first entry in the ctx->pgarr_list.  This "current"
  * page-array advances as necessary, and new page-array descriptors are
  * allocated on-demand. Before the next MM, the chain is reset but not
- * freed (that is, dereference page pointers and reset ctx->pgcur).
+ * freed (that is, dereference page pointers).
  */
 
-#define CR_PGARR_ORDER  0
-#define CR_PGARR_TOTAL  ((PAGE_SIZE << CR_PGARR_ORDER) / sizeof(void *))
+#define CR_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
 
 /* release pages referenced by a page-array */
-void cr_pgarr_unref_pages(struct cr_pgarr *pgarr)
+void cr_pgarr_release_pages(struct cr_pgarr *pgarr)
 {
 	int n;
 
-	/* only checkpoint keeps references to pages */
-	if (pgarr->pages) {
-		cr_debug("nr_used %d\n", pgarr->nr_used);
-		for (n = pgarr->nr_used; n--; )
-			page_cache_release(pgarr->pages[n]);
+	/*
+	 * No need to check pgarr->pages, since
+	 * nr_used will be 0 if it is NULL.
+	 */
+	cr_debug("nr_used %d\n", pgarr->nr_used);
+	for (n = pgarr->nr_used; n >= 0; n--) {
+		page_cache_release(pgarr->pages[n]);
+		pgarr->pages[n] = NULL;
+		pgarr->vaddrs[n] = 0;
 	}
 }
 
 /* free a single page-array object */
 static void cr_pgarr_free_one(struct cr_pgarr *pgarr)
 {
-	cr_pgarr_unref_pages(pgarr);
-	if (pgarr->pages)
-		free_pages((unsigned long) pgarr->pages, CR_PGARR_ORDER);
-	if (pgarr->vaddrs)
-		free_pages((unsigned long) pgarr->vaddrs, CR_PGARR_ORDER);
+	cr_pgarr_release_pages(pgarr);
+	kfree(pgarr->pages);
+	kfree(pgarr->vaddrs);
 	kfree(pgarr);
 }
 
@@ -68,11 +68,10 @@ void cr_pgarr_free(struct cr_ctx *ctx)
 {
 	struct cr_pgarr *pgarr, *tmp;
 
-	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr, list) {
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_list, list) {
 		list_del(&pgarr->list);
 		cr_pgarr_free_one(pgarr);
 	}
-	ctx->pgcur = NULL;
 }
 
 /* allocate a single page-array object */
@@ -84,13 +83,11 @@ static struct cr_pgarr *cr_pgarr_alloc_o
 	if (!pgarr)
 		return NULL;
 
-	pgarr->nr_free = CR_PGARR_TOTAL;
 	pgarr->nr_used = 0;
-
-	pgarr->pages = (struct page **)
-		__get_free_pages(GFP_KERNEL, CR_PGARR_ORDER);
-	pgarr->vaddrs = (unsigned long *)
-		__get_free_pages(GFP_KERNEL, CR_PGARR_ORDER);
+	pgarr->pages  = kmalloc(CR_PGARR_TOTAL * sizeof(struct page *),
+				GFP_KERNEL);
+	pgarr->vaddrs = kmalloc(CR_PGARR_TOTAL * sizeof(unsigned long *),
+				GFP_KERNEL);
 	if (!pgarr->pages || !pgarr->vaddrs) {
 		cr_pgarr_free_one(pgarr);
 		return NULL;
@@ -99,57 +96,56 @@ static struct cr_pgarr *cr_pgarr_alloc_o
 	return pgarr;
 }
 
-/* cr_pgarr_alloc - return the next available pgarr in the page-array chain
+static int pgarr_is_full(struct cr_pgarr *pgarr)
+{
+	if (pgarr->nr_used > CR_PGARR_TOTAL)
+		return 1;
+	return 0;
+}
+
+static struct cr_pgarr *cr_first_pgarr(struct cr_ctx *ctx)
+{
+	return list_first_entry(&ctx->pgarr_list, struct cr_pgarr, list);
+}
+
+/* cr_get_empty_pgarr - return the next available pgarr in the page-array chain
  * @ctx: checkpoint context
  *
- * Return the page-array following ctx->pgcur, extending the chain if needed
+ * Return the first page-array in the list with space.  Extend the
+ * list if none has space.
  */
-struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx)
+struct cr_pgarr *cr_get_empty_pgarr(struct cr_ctx *ctx)
 {
 	struct cr_pgarr *pgarr;
 
-	/* can reuse next element after ctx->pgcur ? */
-	pgarr = ctx->pgcur;
-	if (pgarr && !list_is_last(&pgarr->list, &ctx->pgarr)) {
-		pgarr = list_entry(pgarr->list.next, struct cr_pgarr, list);
+	/*
+	 * This could just as easily be a list_for_each() if we
+	 * need to do a more comprehensive search.
+	 */
+	pgarr = cr_first_pgarr(ctx);
+	if (!pgarr_is_full(pgarr))
 		goto out;
-	}
 
-	/* nope, need to extend the page-array chain */
+	ctx->nr_full_pgarrs++;
 	pgarr = cr_pgarr_alloc_one();
 	if (!pgarr)
 		return NULL;
 
-	list_add_tail(&pgarr->list, &ctx->pgarr);
+	list_add(&pgarr->list, &ctx->pgarr_list);
  out:
-	ctx->pgcur = pgarr;
 	return pgarr;
 
 }
 
 /* reset the page-array chain (dropping page references if necessary) */
-void cr_pgarr_reset(struct cr_ctx *ctx)
+void cr_reset_all_pgarrs(struct cr_ctx *ctx)
 {
 	struct cr_pgarr *pgarr;
 
-	list_for_each_entry(pgarr, &ctx->pgarr, list) {
-		cr_pgarr_unref_pages(pgarr);
-		pgarr->nr_free = CR_PGARR_TOTAL;
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list) {
+		cr_pgarr_release_pages(pgarr);
 		pgarr->nr_used = 0;
 	}
-	ctx->pgcur = NULL;
-}
-
-
-/* return current page-array (and allocate if needed) */
-struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx
-)
-{
-	struct cr_pgarr *pgarr = ctx->pgcur;
-
-	if (!pgarr->nr_free)
-		pgarr = cr_pgarr_alloc(ctx);
-	return pgarr;
 }
 
 /*
@@ -161,116 +157,84 @@ struct cr_pgarr *cr_pgarr_prep(struct cr
  * dumped to the file descriptor.
  */
 
+/*
+ * You must ensure that the pgarr has space before
+ * calling this function.
+ */
+static inline void cr_add_to_pgarr(struct cr_pgarr *pgarr, struct page *page,
+				  unsigned long vaddr)
+{
+	/*
+	 * We're really just handing the result of the
+	 * follow_page() here.
+	 */
+	if (page == NULL)
+		return;
+	if (page == ZERO_PAGE(0))
+		return;
+
+	get_page(page);
+	pgarr->pages[pgarr->nr_used] = page;
+	pgarr->vaddrs[pgarr->nr_used] = vaddr;
+	pgarr->nr_used++;
+}
+
+static inline void cr_pgarr_release_index(struct cr_pgarr *pgarr, int index)
+{
+	page_cache_release(pgarr->pages[index]);
+	pgarr->pages[index] = NULL;
+	pgarr->vaddrs[index] = 0;
+	pgarr->nr_used--;
+}
+
 /**
- * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
+ * cr_private_vma - fill the ctx structure with pgarrs containing
+ * 		    the contents of this VMA
  * @ctx - checkpoint context
- * @pgarr - page-array to fill
  * @vma - vma to scan
- * @start - start address (updated)
  */
-static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
-			     struct vm_area_struct *vma, unsigned long *start)
+static int cr_private_vma(struct cr_ctx *ctx,
+			struct vm_area_struct *vma)
 {
-	unsigned long end = vma->vm_end;
-	unsigned long addr = *start;
-	struct page **pagep;
-	unsigned long *addrp;
-	int cow, nr, ret = 0;
-
-	nr = pgarr->nr_free;
-	pagep = &pgarr->pages[pgarr->nr_used];
-	addrp = &pgarr->vaddrs[pgarr->nr_used];
-	cow = !!vma->vm_file;
+	struct cr_pgarr *pgarr;
+	unsigned long addr = vma->vm_start;
+	int ret = 0;
+	int cow = 0;
+	int orig_nr_used;
 
-	while (addr < end) {
-		struct page *page;
+reload:
+	pgarr = cr_get_empty_pgarr(ctx);
+	if (!pgarr)
+		return -ENOMEM;
 
-		/*
-		 * simplified version of get_user_pages(): already have vma,
-		 * only need FOLL_TOUCH, and (for now) ignore fault stats.
-		 *
-		 * FIXME: consolidate with get_user_pages()
-		 */
+       	orig_nr_used = pgarr->nr_used;
+	/*
+	 * This function is only for private mappings.  If
+	 * the vma is file backed, it must be a cow.
+	 */
+	if (vma->vm_file)
+		cow = 1;
 
-		cond_resched();
-		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
-			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
-			if (ret & VM_FAULT_ERROR) {
-				if (ret & VM_FAULT_OOM)
-					ret = -ENOMEM;
-				else if (ret & VM_FAULT_SIGBUS)
-					ret = -EFAULT;
-				else
-					BUG();
-				break;
-			}
-			cond_resched();
-			ret = 0;
-		}
+	while (addr < vma->vm_end) {
+		struct page *page;
 
+		cond_resched();
+		page = follow_page(vma, addr, FOLL_TOUCH);
 		if (IS_ERR(page))
 			ret = PTR_ERR(page);
 
 		if (ret < 0)
 			break;
 
-		if (page == ZERO_PAGE(0)) {
-			page = NULL;	/* zero page: ignore */
-		} else if (cow && page_mapping(page) != NULL) {
-			page = NULL;	/* clean cow: ignore */
-		} else {
-			get_page(page);
-			*(addrp++) = addr;
-			*(pagep++) = page;
-			if (--nr == 0) {
-				addr += PAGE_SIZE;
-				break;
-			}
-		}
-
+		if (cow && (page_mapping(page) != NULL))
+			page = NULL;
+		cr_add_to_pgarr(pgarr, page, addr);
 		addr += PAGE_SIZE;
+		if (pgarr_is_full(pgarr))
+			goto reload;
 	}
 
-	if (unlikely(ret < 0)) {
-		nr = pgarr->nr_free - nr;
-		while (nr--)
-			page_cache_release(*(--pagep));
-		return ret;
-	}
-
-	*start = addr;
-	return pgarr->nr_free - nr;
-}
-
-/**
- * cr_vma_scan_pages - scan vma for pages that will need to be dumped
- * @ctx - checkpoint context
- * @vma - vma to scan
- *
- * lists of page pointes and corresponding virtual addresses are tracked
- * inside ctx->pgarr page-array chain
- */
-static int cr_vma_scan_pages(struct cr_ctx *ctx, struct vm_area_struct *vma)
-{
-	unsigned long addr = vma->vm_start;
-	unsigned long end = vma->vm_end;
-	struct cr_pgarr *pgarr;
-	int nr, total = 0;
-
-	while (addr < end) {
-		pgarr = cr_pgarr_prep(ctx);
-		if (!pgarr)
-			return -ENOMEM;
-		nr = cr_vma_fill_pgarr(ctx, pgarr, vma, &addr);
-		if (nr < 0)
-			return nr;
-		pgarr->nr_free -= nr;
-		pgarr->nr_used += nr;
-		total += nr;
-	}
-
-	cr_debug("total %d\n", total);
-	return total;
+	return ret;
 }
 
 static int cr_page_write(struct cr_ctx *ctx, struct page *page, char *buf)
@@ -300,7 +264,7 @@ static int cr_vma_dump_pages(struct cr_c
 	if (!total)
 		return 0;
 
-	list_for_each_entry(pgarr, &ctx->pgarr, list) {
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		ret = cr_kwrite(ctx, pgarr->vaddrs,
 				pgarr->nr_used * sizeof(*pgarr->vaddrs));
 		if (ret < 0)
@@ -311,7 +275,7 @@ static int cr_vma_dump_pages(struct cr_c
 	if (!buf)
 		return -ENOMEM;
 
-	list_for_each_entry(pgarr, &ctx->pgarr, list) {
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		for (i = 0; i < pgarr->nr_used; i++) {
 			ret = cr_page_write(ctx, pgarr->pages[i], buf);
 			if (ret < 0)
@@ -366,7 +330,7 @@ static int cr_write_vma(struct cr_ctx *c
 	/* (1) scan: scan through the PTEs of the vma to count the pages
 	 * to dump (and later make those pages COW), and keep the list of
 	 * pages (and a reference to each page) on the checkpoint ctx */
-	nr = cr_vma_scan_pages(ctx, vma);
+	nr = cr_private_vma(ctx, vma);
 	if (nr < 0)
 		return nr;
 
@@ -387,7 +351,7 @@ static int cr_write_vma(struct cr_ctx *c
 	ret = cr_vma_dump_pages(ctx, nr);
 
 	/* (3) free: release the extra references to the pages in the list */
-	cr_pgarr_reset(ctx);
+	cr_reset_all_pgarrs(ctx);
 
 	return ret;
 }
diff -puN checkpoint/ckpt_mem.h~p4-dave checkpoint/ckpt_mem.h
--- linux-2.6.git/checkpoint/ckpt_mem.h~p4-dave	2008-09-10 13:58:55.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_mem.h	2008-09-10 13:58:55.000000000 -0700
@@ -23,13 +23,10 @@ struct cr_pgarr {
 	unsigned long *vaddrs;
 	struct page **pages;
 	unsigned int nr_used;	/* how many entries already used */
-	unsigned int nr_free;	/* how many entries still free */
 	struct list_head list;
 };
 
-void cr_pgarr_reset(struct cr_ctx *ctx);
 void cr_pgarr_free(struct cr_ctx *ctx);
-struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx);
 struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx);
 
 #endif /* _CHECKPOINT_CKPT_MEM_H_ */
diff -puN include/linux/ckpt.h~p4-dave include/linux/ckpt.h
--- linux-2.6.git/include/linux/ckpt.h~p4-dave	2008-09-10 13:58:55.000000000 -0700
+++ linux-2.6.git-dave/include/linux/ckpt.h	2008-09-10 13:58:55.000000000 -0700
@@ -28,8 +28,8 @@ struct cr_ctx {
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
 
-	struct list_head pgarr;	/* page array for dumping VMA contents */
-	struct cr_pgarr *pgcur;	/* current position in page array */
+	struct list_head pgarr_list;	/* page array for dumping VMA contents */
+	unsigned long nr_full_pgarrs;
 
 	struct path *vfsroot;	/* container root (FIXME) */
 };
_



-- Dave
