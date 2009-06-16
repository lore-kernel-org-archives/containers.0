From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] ipc cr: restore objects in the right namespace
Date: Tue, 16 Jun 2009 18:54:40 -0500
Message-ID: <20090616235440.GA9052@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

When restoring and filling in an ipc ns, we need to create
the new objects inside the new namespace, not current's.
So pass the target namespace into the fns that need it.

With this patch, my ipc c/r patches all pass.  Without it,
some of course always fail while others succeed if the
original ipc_ns happens to start off empty.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint.c     |   14 ++++++++------
 ipc/checkpoint_msg.c |   12 ++++++------
 ipc/checkpoint_sem.c |    8 ++++----
 ipc/checkpoint_shm.c |   10 +++++-----
 ipc/msg.c            |    7 ++-----
 ipc/sem.c            |    8 +++-----
 ipc/shm.c            |    8 +++-----
 ipc/util.h           |   15 +++++++++------
 8 files changed, 40 insertions(+), 42 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index d2f1665..7cc6f84 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -196,8 +196,10 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	return 0;
 }
 
-static int restore_ipc_any(struct ckpt_ctx *ctx, int ipc_ind, int ipc_type,
-			   int (*func)(struct ckpt_ctx *ctx))
+static int restore_ipc_any(struct ipc_namespace *ns, struct ckpt_ctx *ctx,
+			   int ipc_ind, int ipc_type,
+			   int (*func)(struct ipc_namespace *,
+			   		struct ckpt_ctx *ctx))
 {
 	struct ckpt_hdr_ipc *h;
 	int n, ret;
@@ -214,7 +216,7 @@ static int restore_ipc_any(struct ckpt_ctx *ctx, int ipc_ind, int ipc_type,
 
 	ret = 0;
 	for (n = 0; n < h->ipc_count; n++) {
-		ret = (*func)(ctx);
+		ret = (*func)(ns, ctx);
 		if (ret < 0)
 			goto out;
 	}
@@ -282,15 +284,15 @@ static struct ipc_namespace *do_restore_ipc_ns(struct ckpt_ctx *ctx)
 	get_ipc_ns(ipc_ns);
 #endif
 
-	ret = restore_ipc_any(ctx, IPC_SHM_IDS,
+	ret = restore_ipc_any(ipc_ns, ctx, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
 	if (ret < 0)
 		goto out;
-	ret = restore_ipc_any(ctx, IPC_MSG_IDS,
+	ret = restore_ipc_any(ipc_ns, ctx, IPC_MSG_IDS,
 			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
 	if (ret < 0)
 		goto out;
-	ret = restore_ipc_any(ctx, IPC_SEM_IDS,
+	ret = restore_ipc_any(ipc_ns, ctx, IPC_SEM_IDS,
 			      CKPT_HDR_IPC_SEM, restore_ipc_sem);
 	    if (ret < 0)
 		    goto out;
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index fb1a61e..51385b0 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -289,12 +289,12 @@ static int restore_msg_contents(struct ckpt_ctx *ctx, struct list_head *queue,
 	return ret;
 }
 
-int restore_ipc_msg(struct ckpt_ctx *ctx)
+int restore_ipc_msg(struct ipc_namespace *ns, struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_ipc_msg *h;
 	struct kern_ipc_perm *perms;
 	struct msg_queue *msq;
-	struct ipc_ids *msg_ids = &current->nsproxy->ipc_ns->ids[IPC_MSG_IDS];
+	struct ipc_ids *msg_ids = &ns->ids[IPC_MSG_IDS];
 	struct list_head messages;
 	unsigned long cbytes;
 	int msgflag;
@@ -323,7 +323,7 @@ int restore_ipc_msg(struct ckpt_ctx *ctx)
 	msgflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
 	ckpt_debug("msg: do_msgget key %d flag %#x id %d\n",
 		 h->perms.key, msgflag, h->perms.id);
-	ret = do_msgget(h->perms.key, msgflag, h->perms.id);
+	ret = do_msgget(ns, h->perms.key, msgflag, h->perms.id);
 	ckpt_debug("msg: do_msgget ret %d\n", ret);
 	if (ret < 0)
 		goto out;
@@ -341,8 +341,8 @@ int restore_ipc_msg(struct ckpt_ctx *ctx)
 	list_splice_init(&messages, &msq->q_messages);
 
 	/* adjust msq and namespace statistics */
-	atomic_add(h->q_cbytes, &current->nsproxy->ipc_ns->msg_bytes);
-	atomic_add(h->q_qnum, &current->nsproxy->ipc_ns->msg_hdrs);
+	atomic_add(h->q_cbytes, &ns->msg_bytes);
+	atomic_add(h->q_qnum, &ns->msg_hdrs);
 	msq->q_cbytes = h->q_cbytes;
 	msq->q_qbytes = h->q_qbytes;
 	msq->q_qnum = h->q_qnum;
@@ -351,7 +351,7 @@ int restore_ipc_msg(struct ckpt_ctx *ctx)
 
 	if (ret < 0) {
 		ckpt_debug("msq: need to remove (%d)\n", ret);
-		freeque(current->nsproxy->ipc_ns, perms);
+		freeque(ns, perms);
 	} else
 		ipc_unlock(perms);
 	up_write(&msg_ids->rw_mutex);
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 19e9402..64d61ee 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -161,13 +161,13 @@ static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
 	return sma;
 }
 
-int restore_ipc_sem(struct ckpt_ctx *ctx)
+int restore_ipc_sem(struct ipc_namespace *ns, struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_ipc_sem *h;
 	struct kern_ipc_perm *perms;
 	struct sem_array *sem;
 	struct sem *sma = NULL;
-	struct ipc_ids *sem_ids = &current->nsproxy->ipc_ns->ids[IPC_SEM_IDS];
+	struct ipc_ids *sem_ids = &ns->ids[IPC_SEM_IDS];
 	int semflag, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_SEM);
@@ -191,7 +191,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx)
 	semflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
 	ckpt_debug("sem: do_semget key %d flag %#x id %d\n",
 		 h->perms.key, semflag, h->perms.id);
-	ret = do_semget(h->perms.key, h->sem_nsems, semflag, h->perms.id);
+	ret = do_semget(ns, h->perms.key, h->sem_nsems, semflag, h->perms.id);
 	ckpt_debug("sem: do_semget ret %d\n", ret);
 	if (ret < 0)
 		goto out;
@@ -208,7 +208,7 @@ int restore_ipc_sem(struct ckpt_ctx *ctx)
 	ret = load_ipc_sem_hdr(ctx, h, sem);
 	if (ret < 0) {
 		ckpt_debug("sem: need to remove (%d)\n", ret);
-		freeary(current->nsproxy->ipc_ns, perms);
+		freeary(ns,  perms);
 	} else
 		ipc_unlock(perms);
 	up_write(&sem_ids->rw_mutex);
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 0d8eb14..41bacfb 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -169,12 +169,12 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 	return 0;
 }
 
-int restore_ipc_shm(struct ckpt_ctx *ctx)
+int restore_ipc_shm(struct ipc_namespace *ns, struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_ipc_shm *h;
 	struct kern_ipc_perm *perms;
 	struct shmid_kernel *shp;
-	struct ipc_ids *shm_ids = &current->nsproxy->ipc_ns->ids[IPC_SHM_IDS];
+	struct ipc_ids *shm_ids = &ns->ids[IPC_SHM_IDS];
 	struct file *file;
 	int shmflag;
 	int ret;
@@ -209,7 +209,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx)
 		h->perms.mode &= ~SHM_DEST;
 
 		dq.id = h->perms.id;
-		dq.ipcns = current->nsproxy->ipc_ns;
+		dq.ipcns = ns;
 		get_ipc_ns(dq.ipcns);
 
 		/* XXX can safely use put_ipc_ns() as dtor, see above */
@@ -223,7 +223,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx)
 	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
 	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
 		 h->shm_segsz, shmflag, h->perms.id);
-	ret = do_shmget(h->perms.key, h->shm_segsz, shmflag, h->perms.id);
+	ret = do_shmget(ns, h->perms.key, h->shm_segsz, shmflag, h->perms.id);
 	ckpt_debug("shm: do_shmget ret %d\n", ret);
 	if (ret < 0)
 		goto out;
@@ -251,7 +251,7 @@ int restore_ipc_shm(struct ckpt_ctx *ctx)
 	fput(file);
 	if (ret < 0) {
 		ckpt_debug("shm: need to remove (%d)\n", ret);
-		do_shm_rmid(current->nsproxy->ipc_ns, perms);
+		do_shm_rmid(ns, perms);
 	} else
 		ipc_unlock(perms);
 	up_write(&shm_ids->rw_mutex);
diff --git a/ipc/msg.c b/ipc/msg.c
index 1d5d087..3559d53 100644
--- a/ipc/msg.c
+++ b/ipc/msg.c
@@ -310,14 +310,11 @@ static inline int msg_security(struct kern_ipc_perm *ipcp, int msgflg)
 	return security_msg_queue_associate(msq, msgflg);
 }
 
-int do_msgget(key_t key, int msgflg, int req_id)
+int do_msgget(struct ipc_namespace *ns, key_t key, int msgflg, int req_id)
 {
-	struct ipc_namespace *ns;
 	struct ipc_ops msg_ops;
 	struct ipc_params msg_params;
 
-	ns = current->nsproxy->ipc_ns;
-
 	msg_ops.getnew = newque;
 	msg_ops.associate = msg_security;
 	msg_ops.more_checks = NULL;
@@ -330,7 +327,7 @@ int do_msgget(key_t key, int msgflg, int req_id)
 
 SYSCALL_DEFINE2(msgget, key_t, key, int, msgflg)
 {
-	return do_msgget(key, msgflg, -1);
+	return do_msgget(current->nsproxy->ipc_ns, key, msgflg, -1);
 }
 
 static inline unsigned long
diff --git a/ipc/sem.c b/ipc/sem.c
index c60076e..fedc4fd 100644
--- a/ipc/sem.c
+++ b/ipc/sem.c
@@ -309,14 +309,12 @@ static inline int sem_more_checks(struct kern_ipc_perm *ipcp,
 	return 0;
 }
 
-int do_semget(key_t key, int nsems, int semflg, int req_id)
+int do_semget(struct ipc_namespace *ns, key_t key, int nsems, int semflg,
+		int req_id)
 {
-	struct ipc_namespace *ns;
 	struct ipc_ops sem_ops;
 	struct ipc_params sem_params;
 
-	ns = current->nsproxy->ipc_ns;
-
 	if (nsems < 0 || nsems > ns->sc_semmsl)
 		return -EINVAL;
 
@@ -333,7 +331,7 @@ int do_semget(key_t key, int nsems, int semflg, int req_id)
 
 SYSCALL_DEFINE3(semget, key_t, key, int, nsems, int, semflg)
 {
-	return do_semget(key, nsems, semflg, -1);
+	return do_semget(current->nsproxy->ipc_ns, key, nsems, semflg, -1);
 }
 
 /*
diff --git a/ipc/shm.c b/ipc/shm.c
index 0ed6a9d..aa34969 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -519,14 +519,12 @@ static inline int shm_more_checks(struct kern_ipc_perm *ipcp,
 	return 0;
 }
 
-int do_shmget(key_t key, size_t size, int shmflg, int req_id)
+int do_shmget(struct ipc_namespace *ns, key_t key, size_t size, int shmflg,
+		int req_id)
 {
-	struct ipc_namespace *ns;
 	struct ipc_ops shm_ops;
 	struct ipc_params shm_params;
 
-	ns = current->nsproxy->ipc_ns;
-
 	shm_ops.getnew = newseg;
 	shm_ops.associate = shm_security;
 	shm_ops.more_checks = shm_more_checks;
@@ -540,7 +538,7 @@ int do_shmget(key_t key, size_t size, int shmflg, int req_id)
 
 SYSCALL_DEFINE3(shmget, key_t, key, size_t, size, int, shmflg)
 {
-	return do_shmget(key, size, shmflg, -1);
+	return do_shmget(current->nsproxy->ipc_ns, key, size, shmflg, -1);
 }
 
 static inline unsigned long copy_shmid_to_user(void __user *buf, struct shmid64_ds *in, int version)
diff --git a/ipc/util.h b/ipc/util.h
index f838081..fa974eb 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -186,9 +186,12 @@ void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
 /* for checkpoint/restart */
 extern struct ipc_namespace *create_ipc_ns(void);
 
-extern int do_shmget(key_t key, size_t size, int shmflg, int req_id);
-extern int do_msgget(key_t key, int msgflg, int req_id);
-extern int do_semget(key_t key, int nsems, int semflg, int req_id);
+extern int do_shmget(struct ipc_namespace *ns, key_t key, size_t size,
+			int shmflg, int req_id);
+extern int do_msgget(struct ipc_namespace *ns, key_t key, int msgflg,
+			int req_id);
+extern int do_semget(struct ipc_namespace *ns, key_t key, int nsems,
+			int semflg, int req_id);
 
 extern void freeque(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 extern void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
@@ -202,13 +205,13 @@ extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				  struct kern_ipc_perm *perm);
 
 extern int checkpoint_ipc_shm(int id, void *p, void *data);
-extern int restore_ipc_shm(struct ckpt_ctx *ctx);
+extern int restore_ipc_shm(struct ipc_namespace *, struct ckpt_ctx *);
 
 extern int checkpoint_ipc_msg(int id, void *p, void *data);
-extern int restore_ipc_msg(struct ckpt_ctx *ctx);
+extern int restore_ipc_msg(struct ipc_namespace *, struct ckpt_ctx *);
 
 extern int checkpoint_ipc_sem(int id, void *p, void *data);
-extern int restore_ipc_sem(struct ckpt_ctx *ctx);
+extern int restore_ipc_sem(struct ipc_namespace *, struct ckpt_ctx *);
 #endif
 
 #endif
-- 
1.6.1
