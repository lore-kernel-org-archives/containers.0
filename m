From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/4] c/r: pass file instead of inode to
	checkpoint_memory_pointer
Date: Mon, 10 Jan 2011 21:11:26 -0500
Message-ID: <1294711889-30343-2-git-send-email-orenl@cs.columbia.edu>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

This patch prepares the ground for a smooth integration of the support
for hugetlb page coming in following patches.

Cc: Nathan Lynch <<ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint.h |    4 ++--
 ipc/checkpoint_shm.c       |    4 ++--
 mm/checkpoint.c            |   35 ++++++++++++++++++++++-------------
 mm/shmem.c                 |    2 +-
 4 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c015106..6da31c5 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -299,8 +299,8 @@ extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 
 extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 				      struct vm_area_struct *vma,
-				      struct inode *inode);
-extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
+				      struct file *file);
+extern int restore_memory_contents(struct ckpt_ctx *ctx, struct file *file);
 
 
 #define CKPT_VMA_NOT_SUPPORTED	\
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 69ba35a..acfb79b 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -117,7 +117,7 @@ int checkpoint_ipc_shm(int id, void *p, void *data)
 	if (ret < 0)
 		goto out;
 
-	ret = checkpoint_memory_contents(ctx, NULL, inode);
+	ret = checkpoint_memory_contents(ctx, NULL, shp->shm_file);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -294,7 +294,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	ret = ckpt_obj_insert(ctx, file, h->objref, CKPT_OBJ_FILE);
 	if (ret < 0)
 		goto fput;
-	ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
+	ret = restore_memory_contents(ctx, file);
 fput:
 	fput(file);
 
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index c30a195..8b40f4d 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -231,15 +231,16 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
 
 /**
  * consider_shared_page - return page pointer for dirty pages
- * @ino - inode of shmem object
+ * @file - file of shmem object
  * @idx - page index in shmem object
  *
  * Looks up the page that corresponds to the index in the shmem object,
  * and returns the page if it was modified (and grabs a reference to it),
  * or otherwise returns NULL (or error).
  */
-static struct page *consider_shared_page(struct inode *ino, unsigned long idx)
+static struct page *consider_shared_page(struct file *file, unsigned long idx)
 {
+	struct ino *inode = file->f_dentfy->d_inode;
 	struct page *page = NULL;
 	int ret;
 
@@ -286,18 +287,22 @@ static struct page *consider_shared_page(struct inode *ino, unsigned long idx)
  * Returns the number of pages collected
  */
 static int vma_fill_pgarr(struct ckpt_ctx *ctx,
-			  struct vm_area_struct *vma, struct inode *inode,
+			  struct vm_area_struct *vma, struct file *file,
 			  unsigned long *start, unsigned long end)
 {
 	unsigned long addr = *start;
 	struct ckpt_pgarr *pgarr;
+	struct inode *inode;
 	int nr_used;
 	int cnt = 0;
 
-	BUG_ON(inode && vma);
+	BUG_ON(file && vma);
 
 	if (vma)
 		down_read(&vma->vm_mm->mmap_sem);
+	else
+		inode = file->f_dentry->d_inode;
+
 	do {
 		pgarr = pgarr_current(ctx);
 		if (!pgarr) {
@@ -313,7 +318,7 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 			if (vma)
 				page = consider_private_page(vma, addr);
 			else
-				page = consider_shared_page(inode, addr);
+				page = consider_shared_page(file, addr);
 
 			if (IS_ERR(page)) {
 				cnt = PTR_ERR(page);
@@ -409,20 +414,21 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
  */
 int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 			       struct vm_area_struct *vma,
-			       struct inode *inode)
+			       struct file *file)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long addr, end;
 	int cnt, ret;
 
-	BUG_ON(vma && inode);
+	BUG_ON(vma && file);
 
 	if (vma) {
 		addr = vma->vm_start;
 		end = vma->vm_end;
 	} else {
+		end = PAGE_ALIGN(i_size_read(file->f_dentry->d_inode))
+			>> PAGE_CACHE_SHIFT;
 		addr = 0;
-		end = PAGE_ALIGN(i_size_read(inode)) >> PAGE_CACHE_SHIFT;
 	}
 
 	/*
@@ -449,7 +455,7 @@ int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 	 */
 
 	while (addr < end) {
-		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
+		cnt = vma_fill_pgarr(ctx, vma, file, &addr, end);
 		if (cnt == 0)
 			break;
 		else if (cnt < 0)
@@ -571,7 +577,7 @@ int shmem_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 		goto out;
 	if (type == CKPT_VMA_SHM_ANON_SKIP)
 		goto out;
-	ret = checkpoint_memory_contents(ctx, NULL, file->f_dentry->d_inode);
+	ret = checkpoint_memory_contents(ctx, NULL, file);
  out:
 	return ret;
 }
@@ -900,12 +906,15 @@ static struct page *bring_shared_page(unsigned long idx, struct inode *ino)
  * read_pages_contents - read in data of pages in page-array chain
  * @ctx - restart context
  */
-static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
+static int read_pages_contents(struct ckpt_ctx *ctx, struct file *file)
 {
 	struct ckpt_pgarr *pgarr;
 	unsigned long *vaddrs;
+	struct inode *inode;
 	int i, ret;
 
+	inode = file ? file->f_dentry->d_inode : NULL;
+
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		vaddrs = pgarr->vaddrs;
 		for (i = 0; i < pgarr->nr_used; i++) {
@@ -944,7 +953,7 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
  * these steps until reaching a header specifying "0" pages, which marks
  * the end of the contents.
  */
-int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
+int restore_memory_contents(struct ckpt_ctx *ctx, struct file *file)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long nr_pages;
@@ -971,7 +980,7 @@ int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
 		ret = read_pages_vaddrs(ctx, nr_pages);
 		if (ret < 0)
 			break;
-		ret = read_pages_contents(ctx, inode);
+		ret = read_pages_contents(ctx, file);
 		if (ret < 0)
 			break;
 		pgarr_reset_all(ctx);
diff --git a/mm/shmem.c b/mm/shmem.c
index 07bb8d4..cf018ba 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2486,7 +2486,7 @@ int shmem_restore(struct ckpt_ctx *ctx,
 		return PTR_ERR((void *) addr);
 
 	if (h->vma_type == CKPT_VMA_SHM_ANON)
-		ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
+		ret = restore_memory_contents(ctx, file);
  out:
 	fput(file);
 	return ret;
-- 
1.7.1
