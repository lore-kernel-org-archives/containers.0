From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 51/54] sysvipc-sem: checkpoint
Date: Tue, 28 Apr 2009 19:24:21 -0400
Message-ID: <1240961064-13991-52-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint of sysvipc semaphores is performed by iterating through all
sem objects and dumping the contents of each one. The semaphore array
of each sem is dumped with that object.

The semaphore array (sem->sem_base) holds an array of 'struct sem',
which is a {int, int}. Because this translates into the same format
on 32- and 64-bit architectures, the checkpoint format is simply the
dump of this array as is.

TODO: this patch does not handle semaphore-undo -- this data should be
saved per-task while iterating through the tasks.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    8 +++
 ipc/Makefile                   |    3 +-
 ipc/checkpoint.c               |    2 -
 ipc/checkpoint_sem.c           |  101 ++++++++++++++++++++++++++++++++++++++++
 ipc/util.h                     |    2 +
 5 files changed, 113 insertions(+), 3 deletions(-)
 create mode 100644 ipc/checkpoint_sem.c

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index bf34b08..0e15f3f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -356,6 +356,14 @@ struct ckpt_hdr_ipc_msg_msg {
 	__u32 m_ts;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_sem {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
+	__u64 sem_otime;
+	__u64 sem_ctime;
+	__u32 sem_nsems;
+} __attribute__((aligned(8)));
+
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
diff --git a/ipc/Makefile b/ipc/Makefile
index ca408ff..81af168 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,5 +9,6 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o checkpoint_msg.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o \
+			checkpoint_shm.o checkpoint_msg.o checkpoint_sem.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index dfd3286..7a2f4a5 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -103,12 +103,10 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
 				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
 				 CKPT_HDR_IPC_SEM, checkpoint_ipc_sem);
-#endif
 	return ret;
 }
 
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
new file mode 100644
index 0000000..fc6ea44
--- /dev/null
+++ b/ipc/checkpoint_sem.c
@@ -0,0 +1,101 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc sem
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
+
+#include <linux/mm.h>
+#include <linux/sem.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&sem->sem_perm);
+
+	checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+
+	h->sem_otime = sem->sem_otime;
+	h->sem_ctime = sem->sem_ctime;
+	h->sem_nsems = sem->sem_nsems;
+
+	ipc_unlock(&sem->sem_perm);
+
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+	return ret;
+}
+
+/**
+ * ckpt_write_sem_array - dump the state of a semaphore array
+ * @ctx: checkpoint context
+ * @sem: semphore array
+ *
+ * The state of a sempahore is an array of 'struct sem'. This structure
+ * is {int, int}, which translates to the same format {32 bits, 32 bits}
+ * on both 32- and 64-bit architectures. So we simply dump the array.
+ *
+ * The sem-undo information is not saved per ipc_ns, but rather per task.
+ */
+static int checkpoint_sem_array(struct ckpt_ctx *ctx, struct sem_array *sem)
+{
+	/* this is a "best-effort" test, so lock not needed */
+	if (!list_empty(&sem->sem_pending))
+		return -EBUSY;
+
+	/* our caller holds the mutex, so this is safe */
+	return ckpt_write_buffer(ctx, sem->sem_base,
+			       sem->sem_nsems * sizeof(*sem->sem_base));
+}
+
+int checkpoint_ipc_sem(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct sem_array *sem;
+	int ret;
+
+	sem = container_of(perm, struct sem_array, sem_perm);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_sem_hdr(ctx, h, sem);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	if (h->sem_nsems)
+		ret = checkpoint_sem_array(ctx, sem);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/util.h b/ipc/util.h
index a4016e7..5b7cead 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -200,6 +200,8 @@ extern int restore_ipc_shm(struct ckpt_ctx *ctx);
 
 extern int checkpoint_ipc_msg(int id, void *p, void *data);
 extern int restore_ipc_msg(struct ckpt_ctx *ctx);
+
+extern int checkpoint_ipc_sem(int id, void *p, void *data);
 #endif
 
 #endif
-- 
1.5.4.3
