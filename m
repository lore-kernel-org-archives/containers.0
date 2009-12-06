From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 3/3] c/r: fix checkpoint/restart of vmas that extend beyond
	file size
Date: Sun,  6 Dec 2009 15:11:10 -0500
Message-ID: <1260130270-2634-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Since kernel 2.6.32 checkpoint cannot handle file mappings that extend
past the end of a file giving "checkpoint: Bad address" on all archs,
because of a change in how follow_page() handles not-present pages:

	mm: FOLL_DUMP replace FOLL_ANON
 	8e4b9a60718970bbc02dfd3abd0b956ab65af231

Consider these scenarios:

1. Task maps a file beyond it's limit, never touches those
 extra page (if it did, it would get EFAULT/Bus error)

2. Task maps a file and writes the last page, then the file gets
 truncated (by at least a page). A subsequent access to the page will
 cause bus error (VM_FAULT_SIGBUS).

3. If the file size is extended back (using truncate) and the task
 accesses that page, then the task will get a fresh page (losing data
 it had written to that address before).

[Before kernel 2.6.32, that page would become anonymous once it was
dirtied, such that accesses in case #2 are valid, and in case #3 the
task would see the old page regardless of the file contents.]

--CHECKPOINT: in 2.6.31 checkpoint used FOLL_ANON flags to tell
follow_page() to return the zero-page for case#1. For case#2, the
actual page was returned.

In kernel 2.3.32, FOLL_DUMP now makes follow_page() return NULL and we
call handle_mm_fault(). The fault handler returns VM_FAULT_SIGBUS in
case#1 (and depending on arch, case#2 too), and checkpoint fails.

This patch introduces a new FOLL_DIRTY flag which tells follow_page()
to return -EFAULT also for not-present file-backed pages. Accordingly,
__get_dirty_page() uses FOLL_DUMP | FOLL_DIRTY and converts the error
value EFAULT to NULL - telling the caller that the page in question is
clean.

This is fact also optimizes the checkpoint: before, if a file-backed
page was not-present we would first fault it in (read from disk) and
then detect that it was virgin. Instead, now we detect that the page
is clean earlier without needing to fault it in.

--RESTART: case #1 works, because mmap() works as before, and those
pages that were never touched will not be restored either, they will
remain untouched.

The same holds for case#2 (as of kernel 2.6.32), because at checkpoint
it would decide that the page is clean and not save the contents, and
therefore it will not try to restore the contents at restart. This is
consistent with the expected behavior after restart: if the file
remains as is, subsequent accesses will trigger a bus error, and if
the file is extended, then the user will observe a fresh page.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/mm.h |    1 +
 mm/memory.c        |   50 +++++++++++++++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 74828b0..dc34b87 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1275,6 +1275,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
 #define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
+#define FOLL_DIRTY	0x20	/* give error on non-present file mapped */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/memory.c b/mm/memory.c
index 5bf113a..26ad05b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1211,8 +1211,17 @@ bad_page:
 
 no_page:
 	pte_unmap_unlock(ptep, ptl);
-	if (!pte_none(pte))
+	if (!pte_none(pte)) {
+		/*
+		 * When checkpointing we only care about dirty pages.
+		 * If a file-backed page is missing, then return an
+		 * error to tell __get_dirty_page() that it's clean,
+		 * so it won't try to demand page it into memory.
+		 */
+		if ((flags & FOLL_DIRTY) && pte_file(pte))
+			page = ERR_PTR(-EFAULT);
 		return page;
+	}
 
 no_page_table:
 	/*
@@ -1226,6 +1235,15 @@ no_page_table:
 	if ((flags & FOLL_DUMP) &&
 	    (!vma->vm_ops || !vma->vm_ops->fault))
 		return ERR_PTR(-EFAULT);
+	/*
+	 * When checkpointing we only care about dirty pages. If there
+	 * is no page table for a non-anonymous page, we return an
+	 * error to tell __get_dirty_page() that the page is clean, so
+	 * it won't allocate page tables and the page unnecessarily.
+	 */
+	if ((flags & FOLL_DIRTY) && vma->vm_ops)
+		return ERR_PTR(-EFAULT);
+
 	return page;
 }
 
@@ -1489,31 +1507,30 @@ pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
  * @addr - page address
  *
  * Looks up the page that correspond to the address in the vma, and
- * returns the page if it was modified (and grabs a reference to it),
+ * return the page if it was modified (and grabs a reference to it),
  * or otherwise returns NULL or error.
  *
+ * Should only be called for private vma.
  * Must be called with mmap_sem held for read or write.
  */
 struct page *__get_dirty_page(struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
 
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
 	/*
-	 * Simplified version of __get_user_pages(): already have vma
-	 * and (for now) ignore fault stats.
-	 *
-	 * Follow_page() will return NULL if the page is not present
-	 * (swapped), ZERO_PAGE(0) if the pte wasn't allocated or was
-	 * untouched (anon), and the actual page pointer otherwise.
-	 *
-	 * FIXME: consolidate with get_user_pages()
-	 *
-	 * FIXME2: see comment about core dumping in follow_page() -
-	 * also useful here if could save allocation of page tables.
+	 * FOLL_DUMP tells follow_page() to return -EFAULT for either
+	 * non-present anonymous pages, or memory "holes".
+	 * FOLL_DIRTY tells follow_page() to return -EFAULT also for
+	 * non-present file-mapped pages.
+	 * Otherwise, follow_page() returns the page, or NULL if the
+	 * page is swapped out.
 	 */
 
 	cond_resched();
-	while (!(page = follow_page(vma, addr, FOLL_GET))) {
+	while (!(page = follow_page(vma, addr,
+				    FOLL_GET | FOLL_DUMP | FOLL_DIRTY))) {
 		int ret;
 
 		/* the page is swapped out - bring it in (optimize ?) */
@@ -1530,7 +1547,10 @@ struct page *__get_dirty_page(struct vm_area_struct *vma, unsigned long addr)
 		cond_resched();
 	}
 
-	if (IS_ERR(page))
+	/* -EFAULT means that the page is clean (see above) */
+	if (PTR_ERR(page) == -EFAULT)
+		return NULL;
+	else if (IS_ERR(page))
 		return page;
 
 	/*
-- 
1.6.3.3
