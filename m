From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] Add support for the per-task sem_undo list (v4)
Date: Tue, 10 Aug 2010 09:20:54 -0700
Message-ID: <1281457254-18890-3-git-send-email-danms@us.ibm.com>
References: <1281457254-18890-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281457254-18890-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

The semaphore undo list is a set of adjustments to be made to semaphores
held by a task on exit.  Right now, we do not checkpoint or restore this
list which could cause undesirable behavior by a restarted process on exit.

Changes in v4:
 - Change __get_task_semids() to __get_semids()
 - Make two checkpoint functions properly static
 - Change restore_task_sem_undo_adj() to restore_sem_undo_adj()
 - Add a few comments to the restore functions regarding allocation of
   the undo list and the refcount strategy
 - Add a call to ipcperms() to find_alloc_undo() that checks a specified
   set of permissions before attaching the current task to the undo
 - Break out the new find_alloc_undo() behavior and provide a variant
   that bypasses the check when it's not necessary

Changes in v3:
 - Move taking of the refcount for the first process to restore_sem_undo()
   and make restore_obj_sem_undo() take the reference for second-and-
   later tasks
 - Fix uses of __u16 to represent a short
 - Fix potential for overrunning the un->semadj buffer in restore
 - Move the checkpoint object and init functions to the bottom of sem.c
 - Use ckpt_read_payload() instead of allocating our own semadj buffer
 - Change the build bug macro to use the new one introduced in the previous
   patch

Changes in v2:
 - Remove collect operation
 - Add a BUILD_BUG_ON() to ensure sizeof(short) == sizeof(__u16)
 - Use sizeof(__u16) when copying to/from checkpoint header
 - Fix a couple of leaked hdr objects
 - Avoid reading the semadj buffer with rcu_read_lock() held
 - Set the sem_undo pointer on tasks other than the first to restore a list
 - Fix refcounting on restart
 - Pull out the guts of exit_sem() into put_undo_list() and call that
   from our drop() function in case we're the last one.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h     |    4 +
 include/linux/checkpoint_hdr.h |   18 ++
 ipc/sem.c                      |  366 ++++++++++++++++++++++++++++++++++++++--
 kernel/checkpoint/process.c    |   13 ++
 4 files changed, 383 insertions(+), 18 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 4e25042..a11d40e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -271,6 +271,10 @@ extern int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref);
 
+/* per-task semaphore undo */
+extern int checkpoint_obj_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_sem_undo(struct ckpt_ctx *ctx, int sem_undo_objref);
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e455b99..049bb82 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -182,6 +182,10 @@ enum {
 #define CKPT_HDR_IPC_MSG_MSG CKPT_HDR_IPC_MSG_MSG
 	CKPT_HDR_IPC_SEM,
 #define CKPT_HDR_IPC_SEM CKPT_HDR_IPC_SEM
+	CKPT_HDR_TASK_SEM_UNDO_LIST,
+#define CKPT_HDR_TASK_SEM_UNDO_LIST CKPT_HDR_TASK_SEM_UNDO_LIST
+	CKPT_HDR_TASK_SEM_UNDO,
+#define CKPT_HDR_TASK_SEM_UNDO CKPT_HDR_TASK_SEM_UNDO
 
 	CKPT_HDR_SIGHAND = 601,
 #define CKPT_HDR_SIGHAND CKPT_HDR_SIGHAND
@@ -288,6 +292,8 @@ enum obj_type {
 #define CKPT_OBJ_NET_NS CKPT_OBJ_NET_NS
 	CKPT_OBJ_NETDEV,
 #define CKPT_OBJ_NETDEV CKPT_OBJ_NETDEV
+	CKPT_OBJ_SEM_UNDO,
+#define CKPT_OBJ_SEM_UNDO CKPT_OBJ_SEM_UNDO
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -476,6 +482,17 @@ struct ckpt_hdr_ns {
 	__s32 net_objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_task_sem_undo_list {
+	struct ckpt_hdr h;
+	__u32 count;
+};
+
+struct ckpt_hdr_task_sem_undo {
+	struct ckpt_hdr h;
+	__u32 semid;
+	__u32 semadj_count;
+};
+
 /* cannot include <linux/tty.h> from userspace, so define: */
 #define CKPT_NEW_UTS_LEN  64
 #ifdef __KERNEL__
@@ -502,6 +519,7 @@ struct ckpt_hdr_task_objs {
 	__s32 files_objref;
 	__s32 mm_objref;
 	__s32 fs_objref;
+	__s32 sem_undo_objref;
 	__s32 sighand_objref;
 	__s32 signal_objref;
 } __attribute__((aligned(8)));
diff --git a/ipc/sem.c b/ipc/sem.c
index e439b73..9e3e463 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -132,14 +132,6 @@ void sem_exit_ns(struct ipc_namespace *ns)
 }
 #endif
 
-void __init sem_init (void)
-{
-	sem_init_ns(&init_ipc_ns);
-	ipc_init_proc_interface("sysvipc/sem",
-				"       key      semid perms      nsems   uid   gid  cuid  cgid      otime      ctime\n",
-				IPC_SEM_IDS, sysvipc_sem_proc_show);
-}
-
 /*
  * sem_lock_(check_) routines are called in the paths where the rw_mutex
  * is not held.
@@ -1051,7 +1043,7 @@ static struct sem_undo *lookup_undo(struct sem_undo_list *ulp, int semid)
 }
 
 /**
- * find_alloc_undo - Lookup (and if not present create) undo array
+ * __find_alloc_undo - Lookup (and if not present create) undo array
  * @ns: namespace
  * @semid: semaphore array id
  *
@@ -1061,7 +1053,8 @@ static struct sem_undo *lookup_undo(struct sem_undo_list *ulp, int semid)
  * Lifetime-rules: sem_undo is rcu-protected, on success, the function
  * performs a rcu_read_lock().
  */
-static struct sem_undo *find_alloc_undo(struct ipc_namespace *ns, int semid)
+static struct sem_undo *__find_alloc_undo(struct ipc_namespace *ns, int semid,
+					  short checkperms)
 {
 	struct sem_array *sma;
 	struct sem_undo_list *ulp;
@@ -1087,6 +1080,11 @@ static struct sem_undo *find_alloc_undo(struct ipc_namespace *ns, int semid)
 	if (IS_ERR(sma))
 		return ERR_PTR(PTR_ERR(sma));
 
+	if (checkperms && ipcperms(&sma->sem_perm, checkperms)) {
+		sem_unlock(sma);
+		return ERR_PTR(-EPERM);
+	}
+
 	nsems = sma->sem_nsems;
 	sem_getref_and_unlock(sma);
 
@@ -1133,6 +1131,11 @@ out:
 	return un;
 }
 
+static struct sem_undo *find_alloc_undo(struct ipc_namespace *ns, int semid)
+{
+	return __find_alloc_undo(ns, semid, 0);
+}
+
 SYSCALL_DEFINE4(semtimedop, int, semid, struct sembuf __user *, tsops,
 		unsigned, nsops, const struct timespec __user *, timeout)
 {
@@ -1363,14 +1366,8 @@ int copy_semundo(unsigned long clone_flags, struct task_struct *tsk)
  * The current implementation does not do so. The POSIX standard
  * and SVID should be consulted to determine what behavior is mandated.
  */
-void exit_sem(struct task_struct *tsk)
+static void put_undo_list(struct sem_undo_list *ulp)
 {
-	struct sem_undo_list *ulp;
-
-	ulp = tsk->sysvsem.undo_list;
-	if (!ulp)
-		return;
-	tsk->sysvsem.undo_list = NULL;
 
 	if (!atomic_dec_and_test(&ulp->refcnt))
 		return;
@@ -1393,7 +1390,7 @@ void exit_sem(struct task_struct *tsk)
 		if (semid == -1)
 			break;
 
-		sma = sem_lock_check(tsk->nsproxy->ipc_ns, un->semid);
+		sma = sem_lock_check(ulp->ipc_ns, un->semid);
 
 		/* exit_sem raced with IPC_RMID, nothing to do */
 		if (IS_ERR(sma))
@@ -1451,6 +1448,16 @@ void exit_sem(struct task_struct *tsk)
 	kfree(ulp);
 }
 
+void exit_sem(struct task_struct *tsk)
+{
+	struct sem_undo_list *ulp = tsk->sysvsem.undo_list;
+
+	if (ulp) {
+		put_undo_list(ulp);
+		tsk->sysvsem.undo_list = NULL;
+	}
+}
+
 #ifdef CONFIG_PROC_FS
 static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
 {
@@ -1470,3 +1477,326 @@ static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
 			  sma->sem_ctime);
 }
 #endif
+
+static int __get_semids(struct sem_undo_list *ulp, int *semids, int max)
+{
+	int count = 0;
+	struct sem_undo *un;
+
+	if (!ulp)
+		return 0;
+
+	spin_lock(&ulp->lock);
+	list_for_each_entry_rcu(un, &ulp->list_proc, list_proc) {
+		if (count >= max) {
+			count = -E2BIG;
+			break;
+		}
+		semids[count++] = un->semid;
+	}
+	spin_unlock(&ulp->lock);
+
+	return count;
+}
+
+static int get_task_semids(struct sem_undo_list *ulp, int **semid_listp)
+{
+	int ret;
+	int max = 32;
+	int *semid_list = NULL;
+ retry:
+	*semid_listp = krealloc(semid_list, max * sizeof(int), GFP_KERNEL);
+	if (!*semid_listp) {
+		kfree(semid_list);
+		return -ENOMEM;
+	}
+	semid_list = *semid_listp;
+
+	ret = __get_semids(ulp, semid_list, max);
+	if (ret == -E2BIG) {
+		max *= 2;
+		goto retry;
+	} else if (ret < 0) {
+		kfree(semid_list);
+		*semid_listp = NULL;
+	}
+
+	return ret;
+}
+
+static int checkpoint_sem_undo_adj(struct ckpt_ctx *ctx, struct sem_undo *un)
+{
+	int nsems;
+	int ret;
+	short *semadj = NULL;
+	struct sem_array *sma;
+	struct ckpt_hdr_task_sem_undo *h = NULL;
+
+	sma = sem_lock(ctx->root_nsproxy->ipc_ns, un->semid);
+	if (IS_ERR(sma)) {
+		ckpt_debug("unable to lock semid %i (wrong ns?)\n", un->semid);
+		return PTR_ERR(sma);
+	}
+
+	nsems = sma->sem_nsems;
+	sem_getref_and_unlock(sma);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
+	if (!h)
+		goto putref_abort;
+
+	semadj = kzalloc(nsems * sizeof(short), GFP_KERNEL);
+	if (!semadj)
+		goto putref_abort;
+
+	sem_lock_and_putref(sma);
+
+	h->semid = un->semid;
+	h->semadj_count = nsems;
+	memcpy(semadj, un->semadj, h->semadj_count * sizeof(__s16));
+
+	sem_unlock(sma);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	if (ret == 0)
+		ret = ckpt_write_buffer(ctx, semadj, nsems * sizeof(__s16));
+
+	kfree(semadj);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+
+ putref_abort:
+	sem_putref(sma);
+	if (h)
+		ckpt_hdr_put(ctx, h);
+
+	return -ENOMEM;
+}
+
+static int write_sem_undo_list(struct ckpt_ctx *ctx, struct sem_undo_list *ulp,
+			       int count, int *semids)
+{
+	int i;
+	int ret;
+
+	for (i = 0; i < count; i++) {
+		struct sem_undo *un;
+
+		spin_lock(&ulp->lock);
+		un = lookup_undo(ulp, semids[i]);
+		spin_unlock(&ulp->lock);
+
+		if (!un) {
+			ckpt_debug("unable to lookup semid %i\n", semids[i]);
+			return -EINVAL;
+		}
+
+		ret = checkpoint_sem_undo_adj(ctx, un);
+		ckpt_debug("checkpoint_sem_undo: %i\n", ret);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int checkpoint_sem_undo(struct ckpt_ctx *ctx, void *ptr)
+{
+	int ret;
+	int *semids = NULL;
+	struct sem_undo_list *ulp = ptr;
+	struct ckpt_hdr_task_sem_undo_list *h;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO_LIST);
+	if (!h)
+		return -ENOMEM;
+
+	ret = get_task_semids(ulp, &semids);
+	if (ret < 0)
+		goto out;
+	h->count = ret;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
+	if (ret < 0)
+		goto out;
+
+	ret = write_sem_undo_list(ctx, ulp, h->count, semids);
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(semids);
+
+	return ret;
+}
+
+int checkpoint_obj_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sem_undo_list *ulp;
+
+	ulp = t->sysvsem.undo_list;
+	if (ulp)
+		return checkpoint_obj(ctx, ulp, CKPT_OBJ_SEM_UNDO);
+
+	return 0;
+}
+
+static int sem_undo_nsems(struct sem_undo *un, struct ipc_namespace *ns)
+{
+	struct sem_array *sma;
+	int nsems;
+
+	sma = sem_lock(ns, un->semid);
+	if (IS_ERR(sma))
+		return PTR_ERR(sma);
+
+	nsems = sma->sem_nsems;
+
+	sem_unlock(sma);
+
+	return nsems;
+}
+
+static int restore_sem_undo_adj(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_sem_undo *h;
+	int len;
+	int ret = -ENOMEM;
+	int nsems;
+	struct sem_undo *un;
+	int valid;
+	__s16 *semadj = NULL;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	len = sizeof(__s16) * h->semadj_count;
+	ret = ckpt_read_payload(ctx, (void **)&semadj, len, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		goto out;
+
+	un = __find_alloc_undo(current->nsproxy->ipc_ns, h->semid, S_IWUGO);
+	if (IS_ERR(un)) {
+		ret = PTR_ERR(un);
+		ckpt_debug("unable to find semid %i\n", h->semid);
+		goto out;
+	}
+
+	nsems = sem_undo_nsems(un, current->nsproxy->ipc_ns);
+	if (nsems == h->semadj_count)
+		memcpy(un->semadj, semadj, len);
+	else
+		ret = -EINVAL;
+	rcu_read_unlock();
+
+	if (ret < 0)
+		ckpt_err(ctx, ret,
+			 "unable to restore semid %i (claimed=%i actual=%i)\n",
+			 h->semid, h->semadj_count, nsems);
+	else
+		ckpt_debug("semid %i restored with %i adjustments\n",
+			   h->semid, h->semadj_count);
+ out:
+	ckpt_hdr_put(ctx, h);
+	kfree(semadj);
+
+	return ret;
+}
+
+static void *restore_sem_undo(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_sem_undo_list *h;
+	struct sem_undo_list *ulp = NULL;
+	int i;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO_LIST);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	/*
+	 * On success, alloc_undo_list() attaches the new @ulp to
+	 * current task - so no need for explicit cleanup
+	 */
+	ulp = alloc_undo_list(current->nsproxy->ipc_ns);
+	if (!ulp) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < h->count; i++) {
+		ret = restore_sem_undo_adj(ctx);
+		if (ret < 0)
+			goto out;
+	}
+
+	/* success: account for reference in the objhash */
+	atomic_inc(&ulp->refcnt);
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	else
+		return ulp;
+}
+
+int restore_obj_sem_undo(struct ckpt_ctx *ctx, int sem_undo_objref)
+{
+	struct sem_undo_list *ulp;
+
+	if (!sem_undo_objref)
+		return 0; /* Task had no undo list */
+
+	ulp = ckpt_obj_try_fetch(ctx, sem_undo_objref, CKPT_OBJ_SEM_UNDO);
+	if (IS_ERR(ulp))
+		return PTR_ERR(ulp);
+
+	/* The first task to restore a shared list should already have this,
+	 * but subsequent ones won't, so attach to current in that case and
+	 * take our reference.
+	 */
+	if (!current->sysvsem.undo_list) {
+		current->sysvsem.undo_list = ulp;
+		atomic_inc(&ulp->refcnt);
+	}
+
+	return 0;
+}
+
+static int obj_sem_undo_grab(void *ptr)
+{
+	struct sem_undo_list *ulp = ptr;
+
+	atomic_inc(&ulp->refcnt);
+	return 0;
+}
+
+static void obj_sem_undo_drop(void *ptr, int lastref)
+{
+	struct sem_undo_list *ulp = ptr;
+
+	put_undo_list(ulp);
+}
+
+static const struct ckpt_obj_ops ckpt_obj_sem_undo_ops = {
+	.obj_name = "IPC_SEM_UNDO",
+	.obj_type = CKPT_OBJ_SEM_UNDO,
+	.ref_drop = obj_sem_undo_drop,
+	.ref_grab = obj_sem_undo_grab,
+	.checkpoint = checkpoint_sem_undo,
+	.restore = restore_sem_undo,
+};
+
+void __init sem_init (void)
+{
+	sem_init_ns(&init_ipc_ns);
+	ipc_init_proc_interface("sysvipc/sem",
+				"       key      semid perms      nsems   uid   gid  cuid  cgid      otime      ctime\n",
+				IPC_SEM_IDS, sysvipc_sem_proc_show);
+
+	/* sem_undo_list uses a short but we write a __s16 */
+	CKPT_BUILD_BUG_ON_MISMATCH(*CKPT_STRUCT_MEMBER(sem_undo, semadj),
+				   __s16);
+
+	register_checkpoint_obj(&ckpt_obj_sem_undo_ops);
+}
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 936675a..4ec9cdd 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -236,6 +236,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	int files_objref;
 	int mm_objref;
 	int fs_objref;
+	int sem_undo_objref;
 	int sighand_objref;
 	int signal_objref;
 	int first, ret;
@@ -283,6 +284,12 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return fs_objref;
 	}
 
+	sem_undo_objref = checkpoint_obj_sem_undo(ctx, t);
+	if (sem_undo_objref < 0) {
+		ckpt_err(ctx, sem_undo_objref, "%(T)process sem_undo\n");
+		return sem_undo_objref;
+	}
+
 	sighand_objref = checkpoint_obj_sighand(ctx, t);
 	ckpt_debug("sighand: objref %d\n", sighand_objref);
 	if (sighand_objref < 0) {
@@ -311,6 +318,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	h->files_objref = files_objref;
 	h->mm_objref = mm_objref;
 	h->fs_objref = fs_objref;
+	h->sem_undo_objref = sem_undo_objref;
 	h->sighand_objref = sighand_objref;
 	h->signal_objref = signal_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -679,6 +687,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	ret = restore_obj_sem_undo(ctx, h->sem_undo_objref);
+	ckpt_debug("sem_undo: ret %d\n", ret);
+	if (ret < 0)
+		return ret;
+
 	ret = restore_obj_sighand(ctx, h->sighand_objref);
 	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
 	if (ret < 0)
-- 
1.7.1.1
