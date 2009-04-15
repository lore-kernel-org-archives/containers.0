From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/4] deferqueue: generic queue to defer work
Date: Wed, 15 Apr 2009 11:02:54 -0500
Message-ID: <20090415160254.GB31983@us.ibm.com>
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

deferqueue_create(void):
  Allocated a new deferqueue.

deferqueue_run(deferqueue):
  Execute all the pending works in the queue. Returns the number of
  works executed, or an error.

deferqueue_add(deferqueue, function, data, size):
  Enqueue a postponed work. @function is the function to do the work,
  which will be called with @data as an argument. @size tells the
  size of data.

deferqueue_destroy(deferqueue):
  Free the deferqueue and any queued items.

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
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/Kconfig         |    5 ++
 include/linux/deferqueue.h |   31 ++++++++++++++
 kernel/Makefile            |    1 +
 kernel/deferqueue.c        |   94 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 131 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/deferqueue.h
 create mode 100644 kernel/deferqueue.c

diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index 1761b0a..53ed6fa 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -2,9 +2,14 @@
 # implemented the hooks for processor state etc. needed by the
 # core checkpoint/restart code.
 
+config DEFERQUEUE
+	bool
+	default n
+
 config CHECKPOINT
 	bool "Enable checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	select DEFERQUEUE
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
diff --git a/include/linux/deferqueue.h b/include/linux/deferqueue.h
new file mode 100644
index 0000000..fbdc897
--- /dev/null
+++ b/include/linux/deferqueue.h
@@ -0,0 +1,31 @@
+/*
+ * workqueue.h --- work queue handling for Linux.
+ */
+
+#ifndef _LINUX_DEFERQUEUE_H
+#define _LINUX_DEFERQUEUE_H
+
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+
+typedef int (*deferqueue_func_t)(void *);
+
+struct deferqueue_entry {
+	deferqueue_func_t function;
+	struct list_head list;
+	char data[0];
+};
+
+struct deferqueue_head {
+	spinlock_t lock;
+	struct list_head list;
+};
+
+struct deferqueue_head *deferqueue_create(void);
+void deferqueue_destroy(struct deferqueue_head *h);
+int deferqueue_add(struct deferqueue_head *head, deferqueue_func_t function,
+		void *data, int size);
+int deferqueue_run(struct deferqueue_head *head);
+
+#endif
diff --git a/kernel/Makefile b/kernel/Makefile
index e4791b3..0848374 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -22,6 +22,7 @@ CFLAGS_REMOVE_cgroup-debug.o = -pg
 CFLAGS_REMOVE_sched_clock.o = -pg
 endif
 
+obj-$(CONFIG_DEFERQUEUE) += deferqueue.o
 obj-$(CONFIG_FREEZER) += freezer.o
 obj-$(CONFIG_PROFILING) += profile.o
 obj-$(CONFIG_SYSCTL_SYSCALL_CHECK) += sysctl_check.o
diff --git a/kernel/deferqueue.c b/kernel/deferqueue.c
new file mode 100644
index 0000000..35abab0
--- /dev/null
+++ b/kernel/deferqueue.c
@@ -0,0 +1,94 @@
+/*
+ *  Checkpoint-restart - infrastructure to manage deferred work
+ *
+ *  This differs from a workqueue in that the work must be deferred
+ *  until specifically run by the caller.
+ *
+ *  As the only user currently is checkpoint/restart, which has
+ *  very simple usage, the locking is kept simple.  Adding rules
+ *  is protected by the head->lock.  But deferqueue_run() is only
+ *  called once, after all entries have been added.  So it is not
+ *  protected.  Similarly, _destroy is only called once when the
+ *  cr_ctx is releeased, so it is not locked or refcounted.  These
+ *  can of course be added if needed by other users.
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/deferqueue.h>
+
+struct deferqueue_head *deferqueue_create(void)
+{
+	struct deferqueue_head *h = kmalloc(sizeof(*h), GFP_KERNEL);
+	if (h) {
+		spin_lock_init(&h->lock);
+		INIT_LIST_HEAD(&h->list);
+	}
+	return h;
+}
+
+void deferqueue_destroy(struct deferqueue_head *h)
+{
+	if (!list_empty(&h->list)) {
+		struct deferqueue_entry *wq, *n;
+
+		pr_debug("%s: freeing non-empty queue\n", __func__);
+		list_for_each_entry_safe(wq, n, &h->list, list) {
+			list_del(&wq->list);
+			kfree(wq);
+		}
+	}
+	kfree(h);
+}
+
+int deferqueue_add(struct deferqueue_head *head, deferqueue_func_t function,
+		void *data, int size)
+{
+	struct deferqueue_entry *wq;
+
+	wq = kmalloc(sizeof(wq) + size, GFP_KERNEL);
+	if (!wq)
+		return -ENOMEM;
+
+	wq->function = function;
+	memcpy(wq->data, data, size);
+
+	pr_debug("%s: adding work %p function %p\n", __func__, wq,
+			wq->function);
+	spin_lock(&head->lock);
+	list_add_tail(&head->list, &wq->list);
+	spin_unlock(&head->lock);
+	return 0;
+}
+
+/*
+ * deferqueue_run - perform all work in the work queue
+ * @head: deferqueue_head from which to run
+ *
+ * returns: number of works performed, or < 0 on error
+ */
+int deferqueue_run(struct deferqueue_head *head)
+{
+	struct deferqueue_entry *wq, *n;
+	int nr = 0;
+	int ret;
+
+	list_for_each_entry_safe(wq, n, &head->list, list) {
+		pr_debug("doing work %p function %p\n", wq, wq->function);
+		ret = wq->function(wq->data);
+		if (ret < 0)
+			pr_debug("wq function failed %d\n", ret);
+		list_del(&wq->list);
+		kfree(wq);
+		nr++;
+	}
+
+	return nr;
+}
-- 
1.5.4.3
