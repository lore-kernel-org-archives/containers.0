From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 01/10] Infrastructure for work postponed to the end of
	checkpoint/restart
Date: Tue,  7 Apr 2009 08:31:34 -0400
Message-ID: <1239107503-21941-2-git-send-email-orenl@cs.columbia.edu>
References: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107503-21941-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

One use case is when restoring an ipc shared memory region that has
been deleted (but is still attached), during restart it needs to be
create, attached and then deleted. However, creation and attachment
are performed in distinct locations, so deletion can not be performed
on the spot. Instead, this work (delete) is deferred until later.
(This example is in one of the following patches).

The interface is as follows:

cr_deferqueue_run(ctx):
  Execute all the pending works in the queue. Returns the number of
  works executed, or an error.

cr_deferqueue_add(ctx, function, flags, data, size):
  Enqueue a postponed work. @function is the function to do the work,
  which will be called with @data as an argument. @size tells the
  size of data. @flags is unused at the moment.

Why aren't we using the existing kernel workqueue mechanism?  We need
to defer to work until the end of the operation: not earlier, since we
need other things to be in place; not later, to not block waiting for
it. However, the workqueue schedules the work for 'some time later'.
Also, the kernel workqueue may run in any task context, but we require
many times that an operation be run in the context of some specific
restarting task (e.g., restoring IPC state of a certain ipc_ns).

Instead, this mechanism is a simple way for the c/r operation as a
whole, and later a task in particular, to defer some action until
later (but not arbitrarily later) _in the restart_ operation.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/Makefile        |    4 +-
 checkpoint/checkpoint.c    |    4 +++
 checkpoint/deferqueue.c    |   62 ++++++++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c       |    4 +++
 checkpoint/sys.c           |    7 +++++
 include/linux/checkpoint.h |    9 ++++++
 6 files changed, 88 insertions(+), 2 deletions(-)
 create mode 100644 checkpoint/deferqueue.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 420c2e6..fc0f766 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,8 +2,8 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o \
+obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o deferqueue.o \
 		checkpoint.o restart.o \
 		ckpt_task.o rstr_task.o \
 		ckpt_mem.o rstr_mem.o \
-		ckpt_file.o rstr_file.o
+		ckpt_file.o rstr_file.o \
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 7382cc3..47d5bd1 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -550,6 +550,10 @@ int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		goto out;
 
+	ret = cr_deferqueue_run(ctx);
+	if (ret < 0)
+		goto out;
+
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
 	/* on success, return (unique) checkpoint identifier */
diff --git a/checkpoint/deferqueue.c b/checkpoint/deferqueue.c
new file mode 100644
index 0000000..a02d577
--- /dev/null
+++ b/checkpoint/deferqueue.c
@@ -0,0 +1,62 @@
+/*
+ *  Checkpoint-restart - infrastructure to manage deferred work
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
+struct cr_deferqueue {
+	cr_deferqueue_func_t function;
+	unsigned int flags;
+	struct list_head list;
+	char data[0];
+};
+
+int cr_deferqueue_add(struct cr_ctx *ctx, cr_deferqueue_func_t function,
+		     unsigned int flags, void *data, int size)
+{
+	struct cr_deferqueue *wq;
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
+	list_add_tail(&ctx->deferqueue, &wq->list);
+	return 0;
+}
+
+/*
+ * cr_deferqueue_run - perform all work in the work queue
+ * @ctx: checkpoint context
+ *
+ * returns: number of works performed, or < 0 on error
+ */
+int cr_deferqueue_run(struct cr_ctx *ctx)
+{
+	struct cr_deferqueue *wq, *n;
+	int nr = 0;
+	int ret;
+
+	list_for_each_entry_safe(wq, n, &ctx->deferqueue, list) {
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
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index f9b6ca1..d5c5ce2 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -483,6 +483,10 @@ static int do_restart_root(struct cr_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 
+	ret = cr_deferqueue_run(ctx);
+	if (ret < 0)
+		return ret;
+
 	return cr_read_tail(ctx);
 }
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 63ee55e..afcbf75 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -171,8 +171,14 @@ static void cr_task_arr_free(struct cr_ctx *ctx)
 
 static void cr_ctx_free(struct cr_ctx *ctx)
 {
+	int ret;
+
 	BUG_ON(atomic_read(&ctx->refcount));
 
+	ret = cr_deferqueue_run(ctx);
+	if (ret != 0)
+		cr_debug("deferred deferqueue had %d entries", ret);
+
 	if (ctx->file)
 		fput(ctx->file);
 
@@ -211,6 +217,7 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 	atomic_set(&ctx->refcount, 0);
 	INIT_LIST_HEAD(&ctx->pgarr_list);
 	INIT_LIST_HEAD(&ctx->pgarr_pool);
+	INIT_LIST_HEAD(&ctx->deferqueue);
 	init_waitqueue_head(&ctx->waitq);
 
 	err = -EBADF;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1999639..9ca6960 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -40,6 +40,7 @@ struct cr_ctx {
 	atomic_t refcount;
 
 	struct cr_objhash *objhash;	/* hash for shared objects */
+	struct list_head deferqueue;	/* list of deferred works */
 
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
@@ -72,6 +73,14 @@ extern void cr_hbuf_put(struct cr_ctx *ctx, int n);
 extern void cr_ctx_get(struct cr_ctx *ctx);
 extern void cr_ctx_put(struct cr_ctx *ctx);
 
+/* deferred tasks */
+
+typedef int (*cr_deferqueue_func_t)(void *);
+
+extern int cr_deferqueue_run(struct cr_ctx *ctx);
+extern int cr_deferqueue_add(struct cr_ctx *ctx, cr_deferqueue_func_t func,
+			     unsigned int flags, void *data, int size);
+
 /* shared objects handling */
 
 enum {
-- 
1.5.4.3
