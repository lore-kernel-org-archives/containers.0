From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v2][PATCH 01/10] Infrastructure for work postponed to the
	end of checkpoint/restart
Date: Tue, 14 Apr 2009 17:48:38 -0500
Message-ID: <20090414224838.GA20179@us.ibm.com>
References: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
	<1239107503-21941-2-git-send-email-orenl@cs.columbia.edu>
	<20090413153504.GA15846@us.ibm.com>
	<49E35F25.5070501@cs.columbia.edu>
	<20090413180459.GA18467@us.ibm.com>
	<49E42A23.4030404@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E42A23.4030404-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>
> >> Serge E. Hallyn wrote:
> >>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >>>> --- a/checkpoint/Makefile
> >>>> +++ b/checkpoint/Makefile
> >>>> @@ -2,8 +2,8 @@
> >>>>  # Makefile for linux checkpoint/restart.
> >>>>  #
> >>>>
> >>>> -obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o \
> >>>> +obj-$(CONFIG_CHECKPOINT) += sys.o objhash.o deferqueue.o \
> >>>>  		checkpoint.o restart.o \
> >>>>  		ckpt_task.o rstr_task.o \
> >>>>  		ckpt_mem.o rstr_mem.o \
> >>>> -		ckpt_file.o rstr_file.o
> >>>> +		ckpt_file.o rstr_file.o \
> >>> ?
> >>>
> >>>> +int cr_deferqueue_add(struct cr_ctx *ctx, cr_deferqueue_func_t function,
> >>>> +		     unsigned int flags, void *data, int size)
> >>>> +{
> >>>> +	struct cr_deferqueue *wq;
> >>>> +
> >>>> +	wq = kmalloc(sizeof(wq) + size, GFP_KERNEL);
> >>>> +	if (!wq)
> >>>> +		return -ENOMEM;
> >>>> +
> >>>> +	wq->function = function;
> >>>> +	wq->flags = flags;
> >>>> +	memcpy(wq->data, data, size);
> >>>> +
> >>>> +	cr_debug("adding work %p function %p\n", wq, wq->function);
> >>>> +	list_add_tail(&ctx->deferqueue, &wq->list);
> >>>> +	return 0;
> >>>> +}
> >>> Shouldn't the deferqueue be protected by a spinlock here?
> >> Not until we implement concurrent checkpoint/restart. At the moment
> >> it's one task at a time the can access it.
> > 
> > That's too bad.  I think this woudl be better done as a single
> > simple patch addin ga new generic deferqueue mechanism for all
> > to use, with a per-queue spinlock protecting both _add and
> > _run
> 
> 
> Fair enough. Would you like to take a stab at it ?

Only compile tested so far, but here's what I end up with so far.
I'll try to hook it into the rest of your patchset later tonight
or tomorrow...

-serge

From 45cdd4a387cb4d34f02fe1a3c9043169d1df2681 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 14 Apr 2009 15:45:38 -0700
Subject: [PATCH 1/1] deferqueue: generic queue to defer work

For us lazy types...

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/Kconfig         |    1 +
 include/linux/deferqueue.h |   31 ++++++++++++++++
 kernel/Makefile            |    1 +
 kernel/deferqueue.c        |   87 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 120 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/deferqueue.h
 create mode 100644 kernel/deferqueue.c

diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index 1761b0a..4e20f18 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -5,6 +5,7 @@
 config CHECKPOINT
 	bool "Enable checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	select DEFERQUEUE
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
diff --git a/include/linux/deferqueue.h b/include/linux/deferqueue.h
new file mode 100644
index 0000000..5de9797
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
+int cr_deferqueue_run(struct deferqueue_head *head);
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
index 0000000..9d6f44b
--- /dev/null
+++ b/kernel/deferqueue.c
@@ -0,0 +1,87 @@
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
+	if (!list_empty(&h->list))
+		pr_debug("%s: freeing non-empty queue\n", __func__);
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
+int cr_deferqueue_run(struct deferqueue_head *head)
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
