From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 5/7] Infrastructure for work postponed to the end
	of checkpoint/restart
Date: Tue, 31 Mar 2009 01:32:30 -0400
Message-ID: <1238477552-17083-6-git-send-email-orenl@cs.columbia.edu>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477552-17083-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Add a interface to postpone an action until the end of the entire
checkpoint or restart operation. This is useful when during the
scan of tasks an operation cannot be performed in place, to avoid
the need for a second scan.

One use case is the next patch: when restoring an ipc shared memory
region that has been deleted (but is still attached), during restart
it needs to be create, attached and then deleted. However, creation
and attachment are performed in distinct locations, so deletion can
not be performed on the spot. Instead, this work (delete) is deferred
until later.

The interface is as follows:

cr_workqueue_run(ctx):
  Execute all the pending works in the queue. Returns the number of
  works executed, or an error.

cr_workqueue_add(ctx, function, flags, data, size):
  Enqueue a postponed work. @function is the function to do the work,
  which will be called with @data as an argument. @size tells the
  size of data. @flags is unused at the moment.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/Makefile        |    3 +-
 checkpoint/checkpoint.c    |    4 +++
 checkpoint/restart.c       |    3 ++
 checkpoint/sys.c           |    7 +++++
 checkpoint/workqueue.c     |   62 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h |    9 ++++++
 6 files changed, 87 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/workqueue.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 71061de..d14f156 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,6 +2,7 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o objhash.o \
+obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o \
+	objhash.o workqueue.o \
 	ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o \
 	util_ipc.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 2ebaa05..ffb5d9c 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -584,6 +584,10 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	ret = cr_workqueue_run(ctx);
+	if (ret < 0)
+		goto out;
+
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
 	/* on success, return (unique) checkpoint identifier */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index ed5c725..44f255d 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -530,7 +530,10 @@ static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
 		goto out;
 
 	ret = cr_read_tail(ctx);
+	if (ret < 0)
+		goto out;
 
+	ret = cr_workqueue_run(ctx);
  out:
 	return ret;
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 3a925ae..36486cc 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -167,8 +167,14 @@ static void cr_task_arr_free(struct cr_ctx *ctx)
 
 static void cr_ctx_free(struct cr_ctx *ctx)
 {
+	int ret;
+
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	ret = cr_workqueue_run(ctx);
+	if (ret != 0)
+		cr_debug("deferred workqueue had %d entries", ret);
+
 	if (ctx->file)
 		fput(ctx->file);
 
@@ -206,6 +212,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
+	INIT_LIST_HEAD(&ctx->workqueue);
 	init_waitqueue_head(&ctx->waitq);
 
 	err = -EBADF;
diff --git a/checkpoint/workqueue.c b/checkpoint/workqueue.c
new file mode 100644
index 0000000..e278202
--- /dev/null
+++ b/checkpoint/workqueue.c
@@ -0,0 +1,62 @@
+/*
+ *  Checkpoint-restart - work queue infrastructure to manage deferred work
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/list.h>
+#include <linux/checkpoint.h>
+
+struct cr_workqueue {
+	cr_workqueue_func_t function;
+	unsigned int flags;
+	struct list_head list;
+	char data[0];
+};
+
+int cr_workqueue_add(struct cr_ctx *ctx, cr_workqueue_func_t function,
+		     unsigned int flags, void *data, int size)
+{
+	struct cr_workqueue *wq;
+
+	wq = kmalloc(sizeof(wq) + size, GFP_KERNEL);
+	if (!wq)
+		return -ENOMEM;
+
+	wq->function = function;
+	wq->flags = flags;
+	memcpy(wq->data, data, size);
+
+	cr_debug("adding work %p function %p\n", wq, wq->function);
+	list_add_tail(&ctx->workqueue, &wq->list);
+	return 0;
+}
+
+/*
+ * cr_workqueue_run - perform all work in the work queue
+ * @ctx: checkpoint context
+ *
+ * returns: number of works performed, or < 0 on error
+ */
+int cr_workqueue_run(struct cr_ctx *ctx)
+{
+	struct cr_workqueue *wq, *n;
+	int nr = 0;
+	int ret;
+
+	list_for_each_entry_safe(wq, n, &ctx->workqueue, list) {
+		cr_debug("doing work %p function %p\n", wq, wq->function);
+		ret = wq->function(wq->data);
+		if (ret < 0)
+			cr_debug("wq function failed %d\n", ret);
+		list_del(&wq->list);
+		kfree(wq);
+		nr++;
+	}
+
+	return nr;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c556511..ba218b6 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -38,6 +38,7 @@ struct cr_ctx {
 	atomic_t refcount;
 
 	struct cr_objhash *objhash;	/* hash for shared objects */
+	struct list_head workqueue;	/* list of deferred tasks */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
@@ -71,6 +72,14 @@ extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
 extern void cr_ctx_get(struct cr_ctx *ctx);
 extern void cr_ctx_put(struct cr_ctx *ctx);
 
+/* deferred tasks */
+
+typedef int (*cr_workqueue_func_t)(void *);
+
+extern int cr_workqueue_run(struct cr_ctx *ctx);
+extern int cr_workqueue_add(struct cr_ctx *ctx, cr_workqueue_func_t func,
+			    unsigned int flags, void *data, int size);
+
 /* shared objects handling */
 
 enum {
-- 
1.5.4.3
