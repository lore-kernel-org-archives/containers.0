From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] Revert "Infrastructure for work postponed to the end
	of checkpoint/restart"
Date: Wed, 15 Apr 2009 11:02:44 -0500
Message-ID: <20090415160244.GA31983@us.ibm.com>
References: <20090415160221.GA31929@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090415160221.GA31929-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This reverts commit cf909e388fc45c3c462ce5f0dbf9b83988a5c1ea.

Conflicts:

	checkpoint/Makefile
---
 checkpoint/Makefile        |    2 +-
 checkpoint/checkpoint.c    |    4 ---
 checkpoint/deferqueue.c    |   62 --------------------------------------------
 checkpoint/restart.c       |    4 ---
 checkpoint/sys.c           |    7 -----
 include/linux/checkpoint.h |    9 ------
 6 files changed, 1 insertions(+), 87 deletions(-)
 delete mode 100644 checkpoint/deferqueue.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index e64784e..23b1e3c 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,7 +2,7 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o deferqueue.o \
+obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o \
 		checkpoint.o restart.o \
 		ckpt_task.o rstr_task.o \
 		ckpt_mem.o rstr_mem.o \
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 47d5bd1..7382cc3 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -550,10 +550,6 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
-	ret = cr_deferqueue_run(ctx);
-	if (ret < 0)
-		goto out;
-
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
 	/* on success, return (unique) checkpoint identifier */
diff --git a/checkpoint/deferqueue.c b/checkpoint/deferqueue.c
deleted file mode 100644
index a02d577..0000000
--- a/checkpoint/deferqueue.c
+++ /dev/null
@@ -1,62 +0,0 @@
-/*
- *  Checkpoint-restart - infrastructure to manage deferred work
- *
- *  Copyright (C) 2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-#include <linux/list.h>
-#include <linux/checkpoint.h>
-
-struct cr_deferqueue {
-	cr_deferqueue_func_t function;
-	unsigned int flags;
-	struct list_head list;
-	char data[0];
-};
-
-int cr_deferqueue_add(struct cr_ctx *ctx, cr_deferqueue_func_t function,
-		     unsigned int flags, void *data, int size)
-{
-	struct cr_deferqueue *wq;
-
-	wq = kmalloc(sizeof(wq) + size, GFP_KERNEL);
-	if (!wq)
-		return -ENOMEM;
-
-	wq->function = function;
-	wq->flags = flags;
-	memcpy(wq->data, data, size);
-
-	cr_debug("adding work %p function %p\n", wq, wq->function);
-	list_add_tail(&ctx->deferqueue, &wq->list);
-	return 0;
-}
-
-/*
- * cr_deferqueue_run - perform all work in the work queue
- * @ctx: checkpoint context
- *
- * returns: number of works performed, or < 0 on error
- */
-int cr_deferqueue_run(struct cr_ctx *ctx)
-{
-	struct cr_deferqueue *wq, *n;
-	int nr = 0;
-	int ret;
-
-	list_for_each_entry_safe(wq, n, &ctx->deferqueue, list) {
-		cr_debug("doing work %p function %p\n", wq, wq->function);
-		ret = wq->function(wq->data);
-		if (ret < 0)
-			cr_debug("wq function failed %d\n", ret);
-		list_del(&wq->list);
-		kfree(wq);
-		nr++;
-	}
-
-	return nr;
-}
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index dad257e..5293b9a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -484,10 +484,6 @@ static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 
-	ret = cr_deferqueue_run(ctx);
-	if (ret < 0)
-		return ret;
-
 	return cr_read_tail(ctx);
 }
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index afcbf75..63ee55e 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -171,14 +171,8 @@ static void cr_task_arr_free(struct cr_ctx *ctx)
 
 static void cr_ctx_free(struct cr_ctx *ctx)
 {
-	int ret;
-
 	BUG_ON(atomic_read(&ctx->refcount));
 
-	ret = cr_deferqueue_run(ctx);
-	if (ret != 0)
-		cr_debug("deferred deferqueue had %d entries", ret);
-
 	if (ctx->file)
 		fput(ctx->file);
 
@@ -217,7 +211,6 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
-	INIT_LIST_HEAD(&ctx->deferqueue);
 	init_waitqueue_head(&ctx->waitq);
 
 	err = -EBADF;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 898176c..7e8d4e0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -42,7 +42,6 @@ struct cr_ctx {
 	atomic_t refcount;
 
 	struct cr_objhash *objhash;	/* hash for shared objects */
-	struct list_head deferqueue;	/* list of deferred works */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
@@ -75,14 +74,6 @@ extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
 extern void cr_ctx_get(struct cr_ctx *ctx);
 extern void cr_ctx_put(struct cr_ctx *ctx);
 
-/* deferred tasks */
-
-typedef int (*cr_deferqueue_func_t)(void *);
-
-extern int cr_deferqueue_run(struct cr_ctx *ctx);
-extern int cr_deferqueue_add(struct cr_ctx *ctx, cr_deferqueue_func_t func,
-			     unsigned int flags, void *data, int size);
-
 /* shared objects handling */
 
 enum {
-- 
1.5.4.3
