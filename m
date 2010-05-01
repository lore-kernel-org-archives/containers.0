From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 057/100] c/r: support semaphore sysv-ipc
Date: Sat,  1 May 2010 10:15:39 -0400
Message-ID: <1272723382-19470-58-git-send-email-orenl__47651.8328105614$1272727474$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
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

Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
Changelog[v20]:
  - Fix "scheduling in atomic" while restoring ipc sem
Changelog[v19-rc3]:
  - Don't free sma if it's an error on restore
Changelog[v18]:
  - Handle kmalloc failure in restore_sem_array()
Changelog[v17]:
  - Restore objects in the right namespace
  - Forward declare struct msg_msg (instead of include linux/msg.h)
  - Fix typo in comment
  - Don't unlock ipc before calling freeary in error path

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    8 ++
 ipc/Makefile                   |    2 +-
 ipc/checkpoint.c               |    4 -
 ipc/checkpoint_sem.c           |  240 ++++++++++++++++++++++++++++++++++++++++
 ipc/sem.c                      |   11 +-
 ipc/util.h                     |    8 ++
 6 files changed, 261 insertions(+), 12 deletions(-)
 create mode 100644 ipc/checkpoint_sem.c

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0349c9a..3ae2d7d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -499,6 +499,14 @@ struct ckpt_hdr_ipc_msg_msg {
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
index ed46f37..55e38d4 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -10,4 +10,4 @@ obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
 obj-$(CONFIG_SYSVIPC_CHECKPOINT) += checkpoint.o \
-		checkpoint_shm.o checkpoint_msg.o
+		checkpoint_shm.o checkpoint_msg.o checkpoint_sem.o
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index dec8d6e..fa40e01 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -133,12 +133,10 @@ static int checkpoint_ipc_ns(struct ckpt_ctx *ctx, void *ptr)
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
 
@@ -326,7 +324,6 @@ static void *restore_ipc_ns(struct ckpt_ctx *ctx)
 
 	ret = restore_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = restore_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
@@ -335,7 +332,6 @@ static void *restore_ipc_ns(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
 			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
-#endif
 	if (ret < 0)
 		goto out;
 
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
new file mode 100644
index 0000000..cfd6f96
--- /dev/null
+++ b/ipc/checkpoint_sem.c
@@ -0,0 +1,240 @@
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
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+struct msg_msg;
+#include "util.h"
+
+#include <linux/checkpoint.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+/* called with the msgids->rw_mutex is read-held */
+static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	if (ret < 0)
+		return ret;
+
+	ipc_lock_by_ptr(&sem->sem_perm);
+	h->sem_otime = sem->sem_otime;
+	h->sem_ctime = sem->sem_ctime;
+	h->sem_nsems = sem->sem_nsems;
+	ipc_unlock(&sem->sem_perm);
+
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+
+	return 0;
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
+/* called with the msgids->rw_mutex is read-held */
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
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	if (h->sem_nsems)
+		ret = checkpoint_sem_array(ctx, sem);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/************************************************************************
+ * ipc restart
+ */
+
+/* called with the msgids->rw_mutex is write-held */
+static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
+			       struct ckpt_hdr_ipc_sem *h,
+			       struct sem_array *sem)
+{
+	int ret = 0;
+
+	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
+
+	sem->sem_otime = h->sem_otime;
+	sem->sem_ctime = h->sem_ctime;
+	sem->sem_nsems = h->sem_nsems;
+
+	return 0;
+}
+
+/**
+ * ckpt_read_sem_array - read the state of a semaphore array
+ * @ctx: checkpoint context
+ * @sem: semphore array
+ *
+ * Expect the data in an array of 'struct sem': {32 bit, 32 bit}.
+ * See comment in ckpt_write_sem_array().
+ *
+ * The sem-undo information is not restored per ipc_ns, but rather per task.
+ */
+static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
+{
+	struct sem *sma;
+	int i, ret;
+
+	sma = kmalloc(nsems * sizeof(*sma), GFP_KERNEL);
+	if (!sma)
+		return ERR_PTR(-ENOMEM);
+	ret = _ckpt_read_buffer(ctx, sma, nsems * sizeof(*sma));
+	if (ret < 0)
+		goto out;
+
+	/* validate sem array contents */
+	for (i = 0; i < nsems; i++) {
+		if (sma[i].semval < 0 || sma[i].sempid < 0) {
+			ret = -EINVAL;
+			break;
+		}
+	}
+ out:
+	if (ret < 0) {
+		kfree(sma);
+		sma = ERR_PTR(ret);
+	}
+	return sma;
+}
+
+int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct kern_ipc_perm *ipc;
+	struct sem_array *sem;
+	struct sem *sma = NULL;
+	struct ipc_ids *sem_ids = &ns->ids[IPC_SEM_IDS];
+	int semflag, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+	if (h->sem_nsems < 0)
+		goto out;
+
+	/* read sempahore array state */
+	sma = restore_sem_array(ctx, h->sem_nsems);
+	if (IS_ERR(sma)) {
+		ret = PTR_ERR(sma);
+		sma = NULL;
+		goto out;
+	}
+
+	/* restore the message queue now */
+	semflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
+		 h->perms.key, semflag, h->perms.id);
+	ret = do_semget(ns, h->perms.key, h->sem_nsems, semflag, h->perms.id);
+	ckpt_debug("sem: do_semget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&sem_ids->rw_mutex);
+
+	/*
+	 * We are the sole owners/users of this brand new ipc-ns, so:
+	 *
+	 * 1) The semid could not have been deleted between its creation
+	 *   and taking the rw_mutex above.
+	 * 2) No unauthorized task will attempt to gain access to it,
+	 *   so it is safe to do away with ipc_lock(). This is useful
+	 *   because we can call functions that sleep.
+	 * 3) Likewise, we only restore the security bits further below,
+	 *   so it is safe to ignore this (theoretical only!) race.
+	 *
+	 * If/when we allow to restore the ipc state within the parent's
+	 * ipc-ns, we will need to re-examine this.
+	 */
+	ipc = ipc_lock(sem_ids, h->perms.id);
+	BUG_ON(IS_ERR(ipc));
+
+	sem = container_of(ipc, struct sem_array, sem_perm);
+	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
+
+	/* this is safe because no unauthorized access is possible */
+	ipc_unlock(ipc);
+
+	ret = load_ipc_sem_hdr(ctx, h, sem);
+	if (ret < 0) {
+		ipc_lock_by_ptr(&sem->sem_perm);
+		ckpt_debug("sem: need to remove (%d)\n", ret);
+		freeary(ns, ipc);
+		ipc_unlock(ipc);
+	}
+	up_write(&sem_ids->rw_mutex);
+ out:
+	kfree(sma);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/sem.c b/ipc/sem.c
index faed3a3..37da85e 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -93,7 +93,6 @@
 #define sem_checkid(sma, semid)	ipc_checkid(&sma->sem_perm, semid)
 
 static int newary(struct ipc_namespace *, struct ipc_params *, int);
-static void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 #ifdef CONFIG_PROC_FS
 static int sysvipc_sem_proc_show(struct seq_file *s, void *it);
 #endif
@@ -317,14 +316,12 @@ static inline int sem_more_checks(struct kern_ipc_perm *ipcp,
 	return 0;
 }
 
-int do_semget(key_t key, int nsems, int semflg, int req_id)
+int do_semget(struct ipc_namespace *ns, key_t key, int nsems,
+	      int semflg, int req_id)
 {
-	struct ipc_namespace *ns;
 	struct ipc_ops sem_ops;
 	struct ipc_params sem_params;
 
-	ns = current->nsproxy->ipc_ns;
-
 	if (nsems < 0 || nsems > ns->sc_semmsl)
 		return -EINVAL;
 
@@ -341,7 +338,7 @@ int do_semget(key_t key, int nsems, int semflg, int req_id)
 
 SYSCALL_DEFINE3(semget, key_t, key, int, nsems, int, semflg)
 {
-	return do_semget(key, nsems, semflg, -1);
+	return do_semget(current->nsproxy->ipc_ns, key, nsems, semflg, -1);
 }
 
 /*
@@ -574,7 +571,7 @@ static void free_un(struct rcu_head *head)
  * as a writer and the spinlock for this semaphore set hold. sem_ids.rw_mutex
  * remains locked on exit.
  */
-static void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
+void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp)
 {
 	struct sem_undo *un, *tu;
 	struct sem_queue *q, *tq;
diff --git a/ipc/util.h b/ipc/util.h
index 8a223f0..ba080de 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -193,6 +193,11 @@ void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 int do_msgget(struct ipc_namespace *ns, key_t key, int msgflg, int req_id);
 void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
+int do_semget(struct ipc_namespace *ns, key_t key, int nsems, int semflg,
+	      int req_id);
+void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
+
+
 #ifdef CONFIG_CHECKPOINT
 extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
@@ -205,6 +210,9 @@ extern int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
 
 extern int checkpoint_ipc_msg(int id, void *p, void *data);
 extern int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
+
+extern int checkpoint_ipc_sem(int id, void *p, void *data);
+extern int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns);
 #endif
 
 #endif
-- 
1.6.3.3
