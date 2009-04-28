From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 52/54] sysvipc-sem: restart
Date: Tue, 28 Apr 2009 19:24:22 -0400
Message-ID: <1240961064-13991-53-git-send-email-orenl@cs.columbia.edu>
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

The semaphores are restored by creating each 'sem object read from the
checkpoint image. Each semaphore array (sem->sem_base) is checked for
validity of contents before copies to the corresponding semaphore.

TODO: this patch does not handle semaphore-undo -- this data should be
restored per-task while iterating through the tasks.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 ipc/checkpoint.c     |    2 -
 ipc/checkpoint_sem.c |  116 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ipc/util.h           |    3 +
 3 files changed, 119 insertions(+), 2 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 7a2f4a5..e14dea6 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -213,12 +213,10 @@ static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_ipc_any(ctx, IPC_MSG_IDS,
 			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = restore_ipc_any(ctx, IPC_SEM_IDS,
 			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
-#endif
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index fc6ea44..0065202 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -99,3 +99,119 @@ int checkpoint_ipc_sem(int id, void *p, void *data)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+
+/************************************************************************
+ * ipc restart
+ */
+
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
+int restore_ipc_sem(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ipc_sem *h;
+	struct kern_ipc_perm *perms;
+	struct sem_array *sem;
+	struct sem *sma = NULL;
+	struct ipc_ids *sem_ids = &current->nsproxy->ipc_ns->ids[IPC_SEM_IDS];
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
+		goto out;
+	}
+
+	/* restore the message queue now */
+	semflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
+		 h->perms.key, semflag, h->perms.id);
+	ret = do_semget(h->perms.key, h->sem_nsems, semflag, h->perms.id);
+	ckpt_debug("sem: do_msgget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&sem_ids->rw_mutex);
+
+	/* we are the sole owners/users of this ipc_ns, it can't go away */
+	perms = ipc_lock(sem_ids, h->perms.id);
+	BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
+
+	sem = container_of(perms, struct sem_array, sem_perm);
+	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
+
+	ret = load_ipc_sem_hdr(ctx, h, sem);
+	ipc_unlock(perms);
+
+	if (ret < 0) {
+		ckpt_debug("sem: need to remove (%d)\n", ret);
+		freeary(current->nsproxy->ipc_ns, perms);
+	}
+	up_write(&sem_ids->rw_mutex);
+ out:
+	kfree(sma);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/util.h b/ipc/util.h
index 5b7cead..54f9acb 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -184,6 +184,8 @@ int ipcget(struct ipc_namespace *ns, struct ipc_ids *ids,
 /* for checkpoint/restart */
 extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
 extern int do_msgget(key_t key, int msgflg, int req_id);
+extern int do_semget(key_t key, int nsems, int semflg, int req_id);
+
 extern void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 extern void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 
@@ -202,6 +204,7 @@ extern int checkpoint_ipc_msg(int id, void *p, void *data);
 extern int restore_ipc_msg(struct ckpt_ctx *ctx);
 
 extern int checkpoint_ipc_sem(int id, void *p, void *data);
+extern int restore_ipc_sem(struct ckpt_ctx *ctx);
 #endif
 
 #endif
-- 
1.5.4.3
