From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: fix ipc scheduling while atomic - take 3
Date: Wed,  3 Mar 2010 15:31:36 -0500
Message-ID: <1267648296-5517-1-git-send-email-orenl@cs.columbia.edu>
References: <1267054267-2819-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267054267-2819-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This patch applies to the current head of ckpt-v19-dev.

While the previous fix was correct, it was incomplete in the sense that
a similar problem exists during checkpoint. So here is a better attempt
at fixing both.

The main idea is that holding the {shm,msg,sem}ids->rw_mutex is enough
at checkpoint when calling checkpoint_fill_ipc_perms() because the data
accessed is either immutable or protected against change with the mutex.
For restart, the same argument as before works - we are the sole users
of a new ipc-ns, and no unaothorized accessed is possible (still, in
this version the code is a bit cleaner).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>


---
 ipc/checkpoint.c     |   26 ++++++++++++++++++++++++++
 ipc/checkpoint_msg.c |   29 +++++++++++++++--------------
 ipc/checkpoint_sem.c |   18 ++++++++++--------
 ipc/checkpoint_shm.c |   18 +++++++++++-------
 4 files changed, 62 insertions(+), 29 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 06027c2..ca181ae 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -33,6 +33,19 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
  * Checkpoint
  */
 
+/*
+ * Requires that ids->rw_mutex be held; this is sufficient because:
+ *
+ * (a) The data accessed either may not change at all (e.g. id, key,
+ * sqe), or may only change by ipc_update_perm() (e.g. uid, cuid, gid,
+ * cgid, mode), which is only called with the mutex write-held.
+ *
+ * (b) The function ipcperms() relies solely on the latter (uid, vuid,
+ * gid, cgid, mode)
+ *
+ * (c) The security context perm->security also may only change when the
+ * mutex is taken.
+ */
 int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
 			      struct ckpt_hdr_ipc_perms *h,
 			      struct kern_ipc_perm *perm)
@@ -48,12 +61,14 @@ int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
 	h->cgid = perm->cgid;
 	h->mode = perm->mode & S_IRWXUGO;
 	h->seq = perm->seq;
+
 	h->sec_ref = security_checkpoint_obj(ctx, perm->security,
 					     CKPT_SECURITY_IPC);
 	if (h->sec_ref < 0) {
 		ckpt_err(ctx, h->sec_ref, "%(T)ipc_perm->security\n");
 		return h->sec_ref;
 	}
+
 	return 0;
 }
 
@@ -184,6 +199,17 @@ static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
 	return 1;
 }
 
+/*
+ * Requires that ids->rw_mutex be held; this is sufficient because:
+ *
+ * (a) The data accessed either may only change by ipc_update_perm()
+ * or by security hooks (perm->security), all of which are only called
+ * with the mutex write-held.
+ *
+ * (b) During restart, we are guarantted to be using a brand new
+ * ipc-ns, only accessible to us, so there will be no attempt for
+ * access validation while we restore the state (by other tasks).
+ */
 int restore_load_ipc_perms(struct ckpt_ctx *ctx,
 			   struct ckpt_hdr_ipc_perms *h,
 			   struct kern_ipc_perm *perm)
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 1933121..7b9a984 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -29,18 +29,18 @@
  * ipc checkpoint
  */
 
+/* called with the msgids->rw_mutex is read-held */
 static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_msg *h,
 			    struct msg_queue *msq)
 {
-	int ret = 0;
-
-	ipc_lock_by_ptr(&msq->q_perm);
+	int ret;
 
 	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
-		goto unlock;
+		return ret;
 
+	ipc_lock_by_ptr(&msq->q_perm);
 	h->q_stime = msq->q_stime;
 	h->q_rtime = msq->q_rtime;
 	h->q_ctime = msq->q_ctime;
@@ -49,13 +49,12 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 	h->q_qbytes = msq->q_qbytes;
 	h->q_lspid = msq->q_lspid;
 	h->q_lrpid = msq->q_lrpid;
-
- unlock:
 	ipc_unlock(&msq->q_perm);
+
 	ckpt_debug("msg: lspid %d rspid %d qnum %lld qbytes %lld\n",
 		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
 
-	return ret;
+	return 0;
 }
 
 static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
@@ -144,6 +143,7 @@ static int checkpoint_msg_queue(struct ckpt_ctx *ctx, struct msg_queue *msq)
 	return ret;
 }
 
+/* called with the msgids->rw_mutex is read-held */
 int checkpoint_ipc_msg(int id, void *p, void *data)
 {
 	struct ckpt_hdr_ipc_msg *h;
@@ -178,6 +178,7 @@ int checkpoint_ipc_msg(int id, void *p, void *data)
  * ipc restart
  */
 
+/* called with the msgids->rw_mutex is write-held */
 static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_msg *h,
 			    struct msg_queue *msq)
@@ -349,19 +350,16 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	 *
 	 * 1) The msgid could not have been deleted between its creation
 	 *   and taking the rw_mutex above.
-	 * 2) No unauthorized task will attempt to gain access to it,
-	 *   so it is safe to do away with ipc_lock(). This is useful
-	 *   because we can call functions that sleep.
-	 * 3) Likewise, we only restore the security bits further below,
-	 *   so it is safe to ignore this (theoretical only!) race.
+	 *
+	 * 2) No unauthorized task will have attempted to gain access
+	 *   to it either, not even until we restore the security bit
+	 *   further below, so the theoretical security race is void.
 	 *
 	 * If/when we allow to restore the ipc state within the parent's
 	 * ipc-ns, we will need to re-examine this.
 	 */
-
 	ipc = ipc_lock(msg_ids, h->perms.id);
 	BUG_ON(IS_ERR(ipc));
-	ipc_unlock(ipc);
 
 	msq = container_of(ipc, struct msg_queue, q_perm);
 	BUG_ON(!list_empty(&msq->q_messages));
@@ -376,6 +374,9 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	msq->q_qbytes = h->q_qbytes;
 	msq->q_qnum = h->q_qnum;
 
+	/* this is safe because no unauthorized access is possible */
+	ipc_unlock(ipc);
+
 	ret = load_ipc_msg_hdr(ctx, h, msq);
 	if (ret < 0) {
 		ckpt_debug("msq: need to remove (%d)\n", ret);
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index ac28592..890374d 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -29,27 +29,26 @@ struct msg_msg;
  * ipc checkpoint
  */
 
+/* called with the msgids->rw_mutex is read-held */
 static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
 			       struct ckpt_hdr_ipc_sem *h,
 			       struct sem_array *sem)
 {
 	int ret = 0;
 
-	ipc_lock_by_ptr(&sem->sem_perm);
-
 	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
-		goto unlock;
+		return ret;
 
+	ipc_lock_by_ptr(&sem->sem_perm);
 	h->sem_otime = sem->sem_otime;
 	h->sem_ctime = sem->sem_ctime;
 	h->sem_nsems = sem->sem_nsems;
-
- unlock:
 	ipc_unlock(&sem->sem_perm);
+
 	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
 
-	return ret;
+	return 0;
 }
 
 /**
@@ -74,6 +73,7 @@ static int checkpoint_sem_array(struct ckpt_ctx *ctx, struct sem_array *sem)
 			       sem->sem_nsems * sizeof(*sem->sem_base));
 }
 
+/* called with the msgids->rw_mutex is read-held */
 int checkpoint_ipc_sem(int id, void *p, void *data)
 {
 	struct ckpt_hdr_ipc_sem *h;
@@ -107,6 +107,7 @@ int checkpoint_ipc_sem(int id, void *p, void *data)
  * ipc restart
  */
 
+/* called with the msgids->rw_mutex is write-held */
 static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
 			       struct ckpt_hdr_ipc_sem *h,
 			       struct sem_array *sem)
@@ -215,14 +216,15 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	 * If/when we allow to restore the ipc state within the parent's
 	 * ipc-ns, we will need to re-examine this.
 	 */
-
 	ipc = ipc_lock(sem_ids, h->perms.id);
 	BUG_ON(IS_ERR(ipc));
-	ipc_unlock(ipc);
 
 	sem = container_of(ipc, struct sem_array, sem_perm);
 	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
 
+	/* this is safe because no unauthorized access is possible */
+	ipc_unlock(ipc);
+
 	ret = load_ipc_sem_hdr(ctx, h, sem);
 	if (ret < 0) {
 		ipc_lock_by_ptr(&sem->sem_perm);
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 62eacaf..bfba5dc 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -33,17 +33,18 @@
  * ipc checkpoint
  */
 
+/* called with the msgids->rw_mutex is read-held */
 static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_shm *h,
 			    struct shmid_kernel *shp)
 {
 	int ret = 0;
 
-	ipc_lock_by_ptr(&shp->shm_perm);
-
 	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
-		goto unlock;
+		return ret;
+
+	ipc_lock_by_ptr(&shp->shm_perm);
 
 	h->shm_segsz = shp->shm_segsz;
 	h->shm_atim = shp->shm_atim;
@@ -67,14 +68,15 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 		ret = -ENOSYS;
 	}
 
- unlock:
 	ipc_unlock(&shp->shm_perm);
+
 	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
 		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
 
 	return ret;
 }
 
+/* called with the msgids->rw_mutex is read-held */
 int checkpoint_ipc_shm(int id, void *p, void *data)
 {
 	struct ckpt_hdr_ipc_shm *h;
@@ -168,6 +170,7 @@ static int ipc_shm_delete(void *data)
 	return ret;
 }
 
+/* called with the msgids->rw_mutex is write-held */
 static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct ckpt_hdr_ipc_shm *h,
 			    struct shmid_kernel *shp)
@@ -242,7 +245,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 
 		dq.id = h->perms.id;
 		dq.ipcns = ns;
-		get_ipc_ns(dq.ipcns);
+		get_ipc_ns(ns);
 
 		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
 				     (deferqueue_func_t) ipc_shm_delete,
@@ -269,15 +272,16 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
 	 * If/when we allow to restore the ipc state within the parent's
 	 * ipc-ns, we will need to re-examine this.
 	 */
-
 	ipc = ipc_lock(shm_ids, h->perms.id);
 	BUG_ON(IS_ERR(ipc));
-	ipc_unlock(ipc);
 
 	shp = container_of(ipc, struct shmid_kernel, shm_perm);
 	file = shp->shm_file;
 	get_file(file);
 
+	/* this is safe because no unauthorized access is possible */
+	ipc_unlock(ipc);
+
 	ret = load_ipc_shm_hdr(ctx, h, shp);
 	if (ret < 0)
 		goto mutex;
-- 
1.6.3.3
