From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] Expose page read/write functions
Date: Tue, 17 Nov 2009 12:24:43 -0800
Message-ID: <1258489484-28227-2-git-send-email-danms@us.ibm.com>
References: <1258489484-28227-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258489484-28227-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Expose checkpoint_dump_page() and restore_read_page() from memory.c.
Also convert them to use a common scratch buffer in the ckpt_ctx
to avoid alloc/dealloc on every page I/O (or group of them).

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/memory.c              |   29 ++++++++---------------------
 checkpoint/sys.c                 |    8 ++++++++
 include/linux/checkpoint.h       |    3 +++
 include/linux/checkpoint_types.h |    2 ++
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index ec3603a..9a4fe83 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -394,16 +394,15 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 }
 
 /* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
-static int checkpoint_dump_page(struct ckpt_ctx *ctx,
-				struct page *page, char *buf)
+int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page)
 {
 	void *ptr;
 
 	ptr = kmap_atomic(page, KM_USER1);
-	memcpy(buf, ptr, PAGE_SIZE);
+	memcpy(ctx->scratch_page, ptr, PAGE_SIZE);
 	kunmap_atomic(ptr, KM_USER1);
 
-	return ckpt_kwrite(ctx, buf, PAGE_SIZE);
+	return ckpt_kwrite(ctx, ctx->scratch_page, PAGE_SIZE);
 }
 
 /**
@@ -416,7 +415,6 @@ static int checkpoint_dump_page(struct ckpt_ctx *ctx,
 static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
 {
 	struct ckpt_pgarr *pgarr;
-	void *buf;
 	int i, ret = 0;
 
 	if (!total)
@@ -434,19 +432,14 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
 			return ret;
 	}
 
-	buf = (void *) __get_free_page(GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		for (i = 0; i < pgarr->nr_used; i++) {
-			ret = checkpoint_dump_page(ctx, pgarr->pages[i], buf);
+			ret = checkpoint_dump_page(ctx, pgarr->pages[i]);
 			if (ret < 0)
 				goto out;
 		}
 	}
  out:
-	free_page((unsigned long) buf);
 	return ret;
 }
 
@@ -889,17 +882,17 @@ static int read_pages_vaddrs(struct ckpt_ctx *ctx, unsigned long nr_pages)
 	return 0;
 }
 
-static int restore_read_page(struct ckpt_ctx *ctx, struct page *page, void *p)
+int restore_read_page(struct ckpt_ctx *ctx, struct page *page)
 {
 	void *ptr;
 	int ret;
 
-	ret = ckpt_kread(ctx, p, PAGE_SIZE);
+	ret = ckpt_kread(ctx, ctx->scratch_page, PAGE_SIZE);
 	if (ret < 0)
 		return ret;
 
 	ptr = kmap_atomic(page, KM_USER1);
-	memcpy(ptr, p, PAGE_SIZE);
+	memcpy(ptr, ctx->scratch_page, PAGE_SIZE);
 	kunmap_atomic(ptr, KM_USER1);
 
 	return 0;
@@ -937,13 +930,8 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
 {
 	struct ckpt_pgarr *pgarr;
 	unsigned long *vaddrs;
-	char *buf;
 	int i, ret = 0;
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
 	down_read(&current->mm->mmap_sem);
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		vaddrs = pgarr->vaddrs;
@@ -961,7 +949,7 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
 				goto out;
 			}
 
-			ret = restore_read_page(ctx, page, buf);
+			ret = restore_read_page(ctx, page);
 			page_cache_release(page);
 
 			if (ret < 0)
@@ -971,7 +959,6 @@ static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
 
  out:
 	up_read(&current->mm->mmap_sem);
-	kfree(buf);
 	return 0;
 }
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index baed891..88a8f25 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -246,6 +246,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	sock_listening_list_free(&ctx->listen_sockets);
 
+	free_page((unsigned long)ctx->scratch_page);
+
 	kfree(ctx);
 }
 
@@ -259,6 +261,12 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx)
 		return ERR_PTR(-ENOMEM);
 
+	ctx->scratch_page = (void *)__get_free_page(GFP_KERNEL);
+	if (!ctx->scratch_page) {
+		err = -ENOMEM;
+		goto err;
+	}
+
 	ctx->uflags = uflags;
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 2bf7755..72a299e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -94,6 +94,9 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
+int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
+int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
+
 /* pids */
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
 extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 79c9c09..c13532d 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -69,6 +69,8 @@ struct ckpt_ctx {
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
 
+	void *scratch_page;             /* Scratch buffer for page I/O */
+
 	/* [multi-process checkpoint] */
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
 	int nr_tasks;                   /* size of tasks array */
-- 
1.6.2.5
