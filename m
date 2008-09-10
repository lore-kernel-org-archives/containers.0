From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Cleanups for: [PATCH 5/9] Memory managemnet (restore)
Date: Wed, 10 Sep 2008 15:00:14 -0700
Message-ID: <1221084015.6781.66.camel__41942.1038510793$1221084270$gmane$org@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040404060.5982@takamine.ncl.cs.columbia.edu>
	<1220551683.23386.32.camel@nimitz> <48C345D2.1020603@cs.columbia.edu>
	<1220892596.23386.166.camel@nimitz> <48C6113A.3080804@cs.columbia.edu>
	<1221082922.6781.62.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221082922.6781.62.camel@nimitz>
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

Here's the restore side of my cleanups on top of the v4 patches and the
one against 4/9 I just sent.

This purely makes it compile again.

---

 linux-2.6.git-dave/checkpoint/ckpt_mem.c |    2 --
 linux-2.6.git-dave/checkpoint/ckpt_mem.h |    4 ++++
 linux-2.6.git-dave/checkpoint/rstr_mem.c |   30 +++++++++++++++++++-----------
 3 files changed, 23 insertions(+), 13 deletions(-)

diff -puN checkpoint/rstr_mem.c~p5-dave checkpoint/rstr_mem.c
--- linux-2.6.git/checkpoint/rstr_mem.c~p5-dave	2008-09-10 14:51:26.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/rstr_mem.c	2008-09-10 14:58:53.000000000 -0700
@@ -31,27 +31,35 @@
  * read in directly to the address space of the current process
  */
 
+static int pgarr_nr_free(struct cr_pgarr *pgarr)
+{
+	return CR_PGARR_TOTAL - pgarr->nr_used;
+}
+
 /**
- * cr_vma_read_pages_vaddrs - read addresses of pages to page-array chain
+ * cr_vma_restore_contents - read addresses of pages to page-array chain
  * @ctx - restart context
  * @npages - number of pages
  */
-static int cr_vma_read_pages_vaddrs(struct cr_ctx *ctx, int npages)
+static int cr_vma_restore_contents(struct cr_ctx *ctx, int pages_to_read)
 {
 	struct cr_pgarr *pgarr;
 	int nr, ret;
 
-	while (npages) {
-		pgarr = cr_pgarr_prep(ctx);
+	while (pages_to_read) {
+		unsigned long *vaddr_position;
+		pgarr = cr_get_empty_pgarr(ctx);
 		if (!pgarr)
 			return -ENOMEM;
-		nr = min(npages, (int) pgarr->nr_free);
-		ret = cr_kread(ctx, pgarr->vaddrs, nr * sizeof(unsigned long));
+		nr = pages_to_read;
+	       	if (nr > pgarr_nr_free(pgarr))
+			nr = pgarr_nr_free(pgarr);
+		vaddr_position = &pgarr->vaddrs[pgarr->nr_used];
+		ret = cr_kread(ctx, vaddr_position, nr * sizeof(unsigned long));
 		if (ret < 0)
 			return ret;
-		pgarr->nr_free -= nr;
 		pgarr->nr_used += nr;
-		npages -= nr;
+		pages_to_read -= nr;
 	}
 	return 0;
 }
@@ -67,7 +75,7 @@ static int cr_vma_read_pages_contents(st
 	unsigned long *vaddrs;
 	int i, ret;
 
-	list_for_each_entry(pgarr, &ctx->pgarr, list) {
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list) {
 		vaddrs = pgarr->vaddrs;
 		for (i = 0; i < pgarr->nr_used; i++) {
 			void *ptr = (void *) vaddrs[i];
@@ -126,14 +134,14 @@ static int cr_vma_read_pages(struct cr_c
 		ret = cr_vma_set_writable(mm, hh->vm_start, hh->vm_end, 1);
 	if (ret < 0)
 		goto out;
-	ret = cr_vma_read_pages_vaddrs(ctx, hh->nr_pages);
+	ret = cr_vma_restore_contents(ctx, hh->nr_pages);
 	if (ret < 0)
 		goto out;
 	ret = cr_vma_read_pages_contents(ctx, hh->nr_pages);
 	if (ret < 0)
 		goto out;
 
-	cr_pgarr_reset(ctx);	/* reset page-array chain */
+	cr_reset_all_pgarrs(ctx);	/* reset page-array chain */
 
 	/* restore original protection for this vma */
 	if (!(hh->vm_flags & VM_WRITE))
diff -puN checkpoint/ckpt_mem.c~p5-dave checkpoint/ckpt_mem.c
--- linux-2.6.git/checkpoint/ckpt_mem.c~p5-dave	2008-09-10 14:51:33.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_mem.c	2008-09-10 14:51:54.000000000 -0700
@@ -35,8 +35,6 @@
  * freed (that is, dereference page pointers).
  */
 
-#define CR_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
-
 /* release pages referenced by a page-array */
 void cr_pgarr_release_pages(struct cr_pgarr *pgarr)
 {
diff -puN checkpoint/ckpt_mem.h~p5-dave checkpoint/ckpt_mem.h
--- linux-2.6.git/checkpoint/ckpt_mem.h~p5-dave	2008-09-10 14:52:17.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_mem.h	2008-09-10 14:57:09.000000000 -0700
@@ -26,7 +26,11 @@ struct cr_pgarr {
 	struct list_head list;
 };
 
+#define CR_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
+
 void cr_pgarr_free(struct cr_ctx *ctx);
+void cr_reset_all_pgarrs(struct cr_ctx *ctx);
 struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx);
+struct cr_pgarr *cr_get_empty_pgarr(struct cr_ctx *ctx);
 
 #endif /* _CHECKPOINT_CKPT_MEM_H_ */
_


-- Dave
