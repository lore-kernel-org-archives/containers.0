From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Fri, 19 Jun 2009 20:32:16 -0500
Message-ID: <20090620013216.GA4435@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>
Cc: linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Stephen Smalley <sds@epoch.ncsc.mil>, Alexey Dobriyan <adobriyan@gmail.com>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Here is the next version of the patch implementing checkpoint
and restore of LSM contexts.  This is just handling IPC objects
as a proof of concept.  But actually, looking ahead and both
files and tasks, I see that selinux stores several sids in the
security structs.  For instance, for tasks there is the current
sid, exec sid, create sid, keycreate_sid, and sockcreate_sid.
So I guess I'll have to ask the LSM for how many secids it wants
to checkpoint, then checkpoint an array of contexts?

From 19669b07cdfef4d377f3f188e2421c4124e38708 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue@us.ibm.com>
Date: Wed, 17 Jun 2009 12:00:21 -0400
Subject: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects

Introduce a cache of secids for checkpoint and restart.
At checkpoint, it takes a secid, stores the corresponding
context string, and stores the objref for later use.
At restart, read the context from checkpoint image,
ask the security module for a secid, and store the secid
on the objhash.

The per-object security c/r code will be responsible for
getting secid from void*security at checkpoint time, and
converting secid to void*security at restore time.

The code to c/r contexts for IPC objects is also in this
patch.

For Smack, assign the label of the process doing sys_restart()
if !capable(CAP_MAC_ADMIN), otherwise use the checkpointed
label.

For SELinux, define a new 'restore' permission for ipc objects.
(A corresponding trival policy patch adding 'restore' to the
common flask permissions for refpolicy is also needed).  The
caller of sys_restart() must have the class:restore permission
to assign the checkpointed label, else restart will be refused.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/objhash.c                             |   10 ++
 checkpoint/sys.c                                 |   15 ++
 include/linux/checkpoint_hdr.h                   |   12 ++-
 include/linux/checkpoint_types.h                 |    7 +
 include/linux/security.h                         |   92 ++++++++++++
 ipc/checkpoint.c                                 |   20 ++-
 ipc/checkpoint_msg.c                             |   45 ++++++-
 ipc/checkpoint_sem.c                             |   18 +++-
 ipc/checkpoint_shm.c                             |   18 +++-
 ipc/util.h                                       |    3 +-
 security/capability.c                            |   38 +++++
 security/security.c                              |  169 ++++++++++++++++++++++
 security/selinux/hooks.c                         |   48 ++++++
 security/selinux/include/av_inherit.h            |    8 +-
 security/selinux/include/av_permissions.h        |   10 +-
 security/selinux/include/common_perm_to_string.h |    1 +
 security/smack/smack_lsm.c                       |   77 ++++++++++
 17 files changed, 571 insertions(+), 20 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index b4bc2e4..c266375 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/security.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -365,6 +366,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_groupinfo,
 		.restore = restore_groupinfo,
 	},
+	/* LSM context */
+	{
+		.obj_name = "SECURITY",
+		.obj_type = CKPT_OBJ_SECURITY,
+		.ref_grab = obj_no_grab,
+		.ref_drop = obj_no_drop,
+		.checkpoint = checkpoint_security,
+		.restore = restore_security,
+	},
 };
 
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 38a5299..06a2c00 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -20,6 +20,7 @@
 #include <linux/file.h>
 #include <linux/uaccess.h>
 #include <linux/capability.h>
+#include <linux/security.h>
 #include <linux/checkpoint.h>
 #include <linux/deferqueue.h>
 
@@ -188,6 +189,16 @@ static void task_arr_free(struct ckpt_ctx *ctx)
 	kfree(ctx->tasks_arr);
 }
 
+void free_secreflist(struct ckpt_ctx *ctx)
+{
+	struct sec_store *s, *p;
+
+	list_for_each_entry_safe(s, p, &ctx->secref_list, list) {
+		list_del(&s->list);
+		kfree(s);
+	}
+}
+
 static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 {
 	int ret;
@@ -217,6 +228,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 		put_task_struct(ctx->root_task);
 	if (ctx->root_freezer)
 		put_task_struct(ctx->root_freezer);
+	free_secreflist(ctx);
 
 	kfree(ctx->pids_arr);
 
@@ -233,6 +245,9 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx)
 		return ERR_PTR(-ENOMEM);
 
+	spin_lock_init(&ctx->secref_lock);
+	INIT_LIST_HEAD(&ctx->secref_list);
+
 	ctx->uflags = uflags;
 	ctx->kflags = kflags;
 	ctx->ktime_begin = ktime_get();
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e42e0db..e3fb9b3 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -62,6 +62,7 @@ enum {
 	CKPT_HDR_USER,
 	CKPT_HDR_GROUPINFO,
 	CKPT_HDR_TASK_CREDS,
+	CKPT_HDR_SECURITY,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -114,6 +115,7 @@ enum obj_type {
 	CKPT_OBJ_CRED,
 	CKPT_OBJ_USER,
 	CKPT_OBJ_GROUPINFO,
+	CKPT_OBJ_SECURITY,
 	CKPT_OBJ_MAX
 };
 
@@ -192,6 +194,12 @@ struct ckpt_capabilities {
 	__u32 padding;
 } __attribute__((aligned(8)));
 
+/* LSM security contexts (shared) */
+struct ckpt_hdr_sec {
+	struct ckpt_hdr h;
+	char str[];
+} __attribute__((aligned(8)));
+
 struct ckpt_hdr_task_creds {
 	struct ckpt_hdr h;
 	__s32 cred_ref;
@@ -418,7 +426,7 @@ struct ckpt_hdr_ipc_perms {
 	__u32 cuid;
 	__u32 cgid;
 	__u32 mode;
-	__u32 _padding;
+	__s32 secref;
 	__u64 seq;
 } __attribute__((aligned(8)));
 
@@ -453,6 +461,8 @@ struct ckpt_hdr_ipc_msg_msg {
 	struct ckpt_hdr h;
 	__s32 m_type;
 	__u32 m_ts;
+	__s32 secref;
+	__u32 padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_sem {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 27fbe26..74c218a 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -73,6 +73,13 @@ struct ckpt_ctx {
 	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
+
+	/*
+	 * next two form basis for a mini-cache of LSM contexts
+	 * turn it into a rbtree or hash
+	 */
+	spinlock_t secref_lock;
+	struct list_head secref_list;
 };
 
 #endif /* __KERNEL__ */
diff --git a/include/linux/security.h b/include/linux/security.h
index d5fd616..38f643c 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1092,6 +1092,16 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  * @msg_msg_free_security:
  *	Deallocate the security structure for this message.
  *	@msg contains the message structure to be modified.
+ * @msg_msg_getsecid:
+ *	Get the secid associated with the msg_msg object.
+ *	@msg contains the message object
+ *	@secid contains a pointer to the location where result will be saved.
+ *	In case of failure, @secid will be set to zero.
+ * @msg_msg_restore:
+ *	Set security context on restored object
+ *	@msg contains the newly created msg_msg object
+ *	@secid contains the secid corresponding to the checkpointed context.
+ *	Return 0 if a proper label was set and permission is granted.
  *
  * Security hooks for System V IPC Message Queues
  *
@@ -1137,6 +1147,11 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@type contains the type of message requested.
  *	@mode contains the operational flags.
  *	Return 0 if permission is granted.
+ * @msg_queue_restore:
+ *	Set permission on a newly restored msg_queue
+ *	@msq contains the message queue being restored.
+ *	@secid is the secid corresponding to the checkpointed context.
+ *	Return 0 if an appropriate context was set and permission is granted.
  *
  * Security hooks for System V Shared Memory Segments
  *
@@ -1172,6 +1187,11 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@shmaddr contains the address to attach memory region to.
  *	@shmflg contains the operational flags.
  *	Return 0 if permission is granted.
+ * @shm_restore:
+ *	Set permission on a newly restored shm
+ *	@shm contains the shm being restored.
+ *	@secid is the secid corresponding to the checkpointed context.
+ *	Return 0 if an appropriate context was set and permission is granted.
  *
  * Security hooks for System V Semaphores
  *
@@ -1208,6 +1228,11 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@nsops contains the number of operations to perform.
  *	@alter contains the flag indicating whether changes are to be made.
  *	Return 0 if permission is granted.
+ * @sem_restore:
+ *	Set permission on a newly restored sem
+ *	@sem contains the sem being restored.
+ *	@secid is the secid corresponding to the checkpointed context.
+ *	Return 0 if an appropriate context was set and permission is granted.
  *
  * @ptrace_may_access:
  *	Check permission before allowing the current process to trace the
@@ -1499,6 +1524,8 @@ struct security_operations {
 
 	int (*msg_msg_alloc_security) (struct msg_msg *msg);
 	void (*msg_msg_free_security) (struct msg_msg *msg);
+	void (*msg_msg_getsecid) (struct msg_msg *msg, u32 *secid);
+	int (*msg_msg_restore) (struct msg_msg *msg, u32 secid);
 
 	int (*msg_queue_alloc_security) (struct msg_queue *msq);
 	void (*msg_queue_free_security) (struct msg_queue *msq);
@@ -1510,6 +1537,7 @@ struct security_operations {
 				 struct msg_msg *msg,
 				 struct task_struct *target,
 				 long type, int mode);
+	int (*msg_queue_restore) (struct msg_queue *msq, u32 secid);
 
 	int (*shm_alloc_security) (struct shmid_kernel *shp);
 	void (*shm_free_security) (struct shmid_kernel *shp);
@@ -1517,6 +1545,7 @@ struct security_operations {
 	int (*shm_shmctl) (struct shmid_kernel *shp, int cmd);
 	int (*shm_shmat) (struct shmid_kernel *shp,
 			  char __user *shmaddr, int shmflg);
+	int (*shm_restore) (struct shmid_kernel *shp, u32 secid);
 
 	int (*sem_alloc_security) (struct sem_array *sma);
 	void (*sem_free_security) (struct sem_array *sma);
@@ -1524,6 +1553,7 @@ struct security_operations {
 	int (*sem_semctl) (struct sem_array *sma, int cmd);
 	int (*sem_semop) (struct sem_array *sma,
 			  struct sembuf *sops, unsigned nsops, int alter);
+	int (*sem_restore) (struct sem_array *sma, u32 secid);
 
 	int (*netlink_send) (struct sock *sk, struct sk_buff *skb);
 	int (*netlink_recv) (struct sk_buff *skb, int cap);
@@ -1748,6 +1778,8 @@ int security_ipc_permission(struct kern_ipc_perm *ipcp, short flag);
 void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid);
 int security_msg_msg_alloc(struct msg_msg *msg);
 void security_msg_msg_free(struct msg_msg *msg);
+void security_msg_msg_getsecid(struct msg_msg *msg, u32 *secid);
+int security_msg_msg_restore(struct msg_msg *msg, u32 secid);
 int security_msg_queue_alloc(struct msg_queue *msq);
 void security_msg_queue_free(struct msg_queue *msq);
 int security_msg_queue_associate(struct msg_queue *msq, int msqflg);
@@ -1756,17 +1788,20 @@ int security_msg_queue_msgsnd(struct msg_queue *msq,
 			      struct msg_msg *msg, int msqflg);
 int security_msg_queue_msgrcv(struct msg_queue *msq, struct msg_msg *msg,
 			      struct task_struct *target, long type, int mode);
+int security_msg_queue_restore(struct msg_queue *msq, u32 secid);
 int security_shm_alloc(struct shmid_kernel *shp);
 void security_shm_free(struct shmid_kernel *shp);
 int security_shm_associate(struct shmid_kernel *shp, int shmflg);
 int security_shm_shmctl(struct shmid_kernel *shp, int cmd);
 int security_shm_shmat(struct shmid_kernel *shp, char __user *shmaddr, int shmflg);
+int security_shm_restore(struct shmid_kernel *shp, u32 secid);
 int security_sem_alloc(struct sem_array *sma);
 void security_sem_free(struct sem_array *sma);
 int security_sem_associate(struct sem_array *sma, int semflg);
 int security_sem_semctl(struct sem_array *sma, int cmd);
 int security_sem_semop(struct sem_array *sma, struct sembuf *sops,
 			unsigned nsops, int alter);
+int security_sem_restore(struct sem_array *sma, u32 secid);
 void security_d_instantiate(struct dentry *dentry, struct inode *inode);
 int security_getprocattr(struct task_struct *p, char *name, char **value);
 int security_setprocattr(struct task_struct *p, char *name, void *value, size_t size);
@@ -2393,6 +2428,18 @@ static inline int security_msg_msg_alloc(struct msg_msg *msg)
 	return 0;
 }
 
+static inline void security_msg_msg_getsecid(struct msg_msg *msg, u32 *secid)
+{
+	*secid = 0;
+}
+
+static inline int security_msg_msg_restore(struct msg_msg *msg, u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static inline void security_msg_msg_free(struct msg_msg *msg)
 { }
 
@@ -2429,6 +2476,14 @@ static inline int security_msg_queue_msgrcv(struct msg_queue *msq,
 	return 0;
 }
 
+static inline int security_msg_queue_restore(struct msg_queue *msq,
+						u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static inline int security_shm_alloc(struct shmid_kernel *shp)
 {
 	return 0;
@@ -2454,6 +2509,14 @@ static inline int security_shm_shmat(struct shmid_kernel *shp,
 	return 0;
 }
 
+static inline int security_shm_restore(struct shmid_kernel *shp,
+					u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static inline int security_sem_alloc(struct sem_array *sma)
 {
 	return 0;
@@ -2479,6 +2542,14 @@ static inline int security_sem_semop(struct sem_array *sma,
 	return 0;
 }
 
+static inline int security_sem_restore(struct sem_array *sma,
+					u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static inline void security_d_instantiate(struct dentry *dentry, struct inode *inode)
 { }
 
@@ -2975,7 +3046,28 @@ static inline char *alloc_secdata(void)
 
 static inline void free_secdata(void *secdata)
 { }
+
+#endif /* CONFIG_SECURITY */
+
+#ifdef CONFIG_CHECKPOINT
+struct sec_store {
+	int secid;  /* LSM secid */
+	int secref; /* objhash reference */
+	struct list_head list;
+};
+#ifdef CONFIG_SECURITY
+extern int checkpoint_security(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_security(struct ckpt_ctx *ctx);
+extern int checkpoint_security_getsecref(struct ckpt_ctx *ctx, int secid);
+#else /* CONFIG_SECURITY */
+#define checkpoint_security checkpoint_bad
+#define restore_security restore_bad
+static inline int checkpoint_security_getsecref(struct ckpt_ctx *ctx, int secid)
+{
+	return 0;
+}
 #endif /* CONFIG_SECURITY */
+#endif /* CONFIG_CHECKPOINT */
 
 #endif /* ! __LINUX_SECURITY_H */
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 88996e2..b7641e2 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -15,6 +15,7 @@
 #include <linux/msg.h>
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
+#include <linux/security.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -31,9 +32,12 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
  * Checkpoint
  */
 
-int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+			      struct ckpt_hdr_ipc_perms *h,
 			      struct kern_ipc_perm *perm)
 {
+	int secid;
+
 	if (ipcperms(perm, S_IROTH))
 		return -EACCES;
 
@@ -46,6 +50,11 @@ int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	h->mode = perm->mode & S_IRWXUGO;
 	h->seq = perm->seq;
 
+	security_ipc_getsecid(perm, &secid);
+	h->secref = checkpoint_security_getsecref(ctx, secid);
+	if (h->secref < 0)
+		return h->secref;
+
 	return 0;
 }
 
@@ -185,13 +194,10 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	perm->mode = h->mode;
 	perm->seq = h->seq;
 	/*
-	 * Todo: restore perm->security.
-	 * At the moment it gets set by security_x_alloc() called through
-	 * ipcget()->ipcget_public()->ops-.getnew (->nequeue for instance)
-	 * We will want to ask the LSM to consider resetting the
-	 * checkpointed ->security, based on current_security(),
-	 * the checkpointed ->security, and the checkpoint file context.
+	 * The checkpointed ->security value will be restored
+	 * (and verified) by our caller.
 	 */
+	perm->security = NULL;
 
 	return 0;
 }
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index 51385b0..ca55339 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
+#include <linux/security.h>
 #include <linux/ipc_namespace.h>
 
 #include "util.h"
@@ -36,7 +37,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&msq->q_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -62,12 +63,19 @@ static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
 	struct ckpt_hdr_ipc_msg_msg *h;
 	struct msg_msgseg *seg;
 	int total, len;
-	int ret;
+	int ret, secid, secref;
+
+	security_msg_msg_getsecid(msg, &secid);
+	secref = checkpoint_security_getsecref(ctx, secid);
+	if (secref < 0)
+		return secref;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
 	if (!h)
 		return -ENOMEM;
 
+	h->secref = secref;
+
 	h->m_type = msg->m_type;
 	h->m_ts = msg->m_ts;
 
@@ -175,11 +183,26 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 			    struct msg_queue *msq)
 {
 	int ret = 0;
+	int secid = 0;
 
 	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
 	if (ret < 0)
 		return ret;
 
+	if (h->perms.secref) {
+		struct sec_store *s;
+		s = ckpt_obj_fetch(ctx, h->perms.secref, CKPT_OBJ_SECURITY);
+		if (IS_ERR(s))
+			return PTR_ERR(s);
+		secid = s->secid;
+	}
+	ret = security_msg_queue_alloc(msq);
+	if (ret)
+		return ret;
+	ret = security_msg_queue_restore(msq, secid);
+	if (ret < 0)
+		return ret;
+
 	ckpt_debug("msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
 		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
 
@@ -201,7 +224,7 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	struct msg_msg *msg = NULL;
 	struct msg_msgseg *seg, **pseg;
 	int total, len;
-	int ret;
+	int ret, secid = 0;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
 	if (IS_ERR(h))
@@ -245,6 +268,22 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 		total -= len;
 	}
 
+	if (h->secref) {
+		struct sec_store *s;
+		s = ckpt_obj_fetch(ctx, h->secref, CKPT_OBJ_SECURITY);
+		if (IS_ERR(s)) {
+			ret = PTR_ERR(s);
+			goto out;
+		}
+		secid = s->secid;
+	}
+	ret = security_msg_msg_alloc(msg);
+	if (ret)
+		goto out;
+	ret = security_msg_msg_restore(msg, secid);
+	if (ret < 0)
+		goto out;
+
 	msg->m_type = h->m_type;
 	msg->m_ts = h->m_ts;
 	*clen = h->m_ts;
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 64d61ee..609750b 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -17,6 +17,7 @@
 #include <linux/sched.h>
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
+#include <linux/security.h>
 #include <linux/ipc_namespace.h>
 
 struct msg_msg;
@@ -37,7 +38,7 @@ static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&sem->sem_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -112,11 +113,26 @@ static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
 			       struct sem_array *sem)
 {
 	int ret = 0;
+	int secid = 0;
 
 	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
 	if (ret < 0)
 		return ret;
 
+	if (h->perms.secref) {
+		struct sec_store *s;
+		s = ckpt_obj_fetch(ctx, h->perms.secref, CKPT_OBJ_SECURITY);
+		if (IS_ERR(s))
+			return PTR_ERR(s);
+		secid = s->secid;
+	}
+	ret = security_sem_alloc(sem);
+	if (ret)
+		return ret;
+	ret = security_sem_restore(sem, secid);
+	if (ret < 0)
+		return ret;
+
 	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
 
 	sem->sem_otime = h->sem_otime;
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 41bacfb..a2a0e41 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/security.h>
 #include <linux/deferqueue.h>
 
 #include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
@@ -41,7 +42,7 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&shp->shm_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -148,11 +149,26 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct shmid_kernel *shp)
 {
 	int ret;
+	int secid = 0;
 
 	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
 	if (ret < 0)
 		return ret;
 
+	if (h->perms.secref) {
+		struct sec_store *s;
+		s = ckpt_obj_fetch(ctx, h->perms.secref, CKPT_OBJ_SECURITY);
+		if (IS_ERR(s))
+			return PTR_ERR(s);
+		secid = s->secid;
+	}
+	ret = security_shm_alloc(shp);
+	if (ret)
+		return ret;
+	ret = security_shm_restore(shp, secid);
+	if (ret < 0)
+		return ret;
+
 	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
 		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
 
diff --git a/ipc/util.h b/ipc/util.h
index fa974eb..bed25bd 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -199,7 +199,8 @@ extern void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
 #ifdef CONFIG_CHECKPOINT
-extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+extern int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+				     struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
 extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				  struct kern_ipc_perm *perm);
diff --git a/security/capability.c b/security/capability.c
index 21b6cea..d0d2e39 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -494,6 +494,18 @@ static void cap_msg_msg_free_security(struct msg_msg *msg)
 {
 }
 
+static void cap_msg_msg_getsecid(struct msg_msg *msg, u32 *secid)
+{
+	*secid = 0;
+}
+
+static int cap_msg_msg_restore(struct msg_msg *msg, u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static int cap_msg_queue_alloc_security(struct msg_queue *msq)
 {
 	return 0;
@@ -525,6 +537,13 @@ static int cap_msg_queue_msgrcv(struct msg_queue *msq, struct msg_msg *msg,
 	return 0;
 }
 
+static int cap_msg_queue_restore(struct msg_queue *msq, u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static int cap_shm_alloc_security(struct shmid_kernel *shp)
 {
 	return 0;
@@ -550,6 +569,13 @@ static int cap_shm_shmat(struct shmid_kernel *shp, char __user *shmaddr,
 	return 0;
 }
 
+static int cap_shm_restore(struct shmid_kernel *shp, u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 static int cap_sem_alloc_security(struct sem_array *sma)
 {
 	return 0;
@@ -575,6 +601,13 @@ static int cap_sem_semop(struct sem_array *sma, struct sembuf *sops,
 	return 0;
 }
 
+static int cap_sem_restore(struct sem_array *sma, u32 secid)
+{
+	if (secid)
+		return -EINVAL;
+	return 0;
+}
+
 #ifdef CONFIG_SECURITY_NETWORK
 static int cap_unix_stream_connect(struct socket *sock, struct socket *other,
 				   struct sock *newsk)
@@ -977,22 +1010,27 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, ipc_getsecid);
 	set_to_cap_if_null(ops, msg_msg_alloc_security);
 	set_to_cap_if_null(ops, msg_msg_free_security);
+	set_to_cap_if_null(ops, msg_msg_getsecid);
+	set_to_cap_if_null(ops, msg_msg_restore);
 	set_to_cap_if_null(ops, msg_queue_alloc_security);
 	set_to_cap_if_null(ops, msg_queue_free_security);
 	set_to_cap_if_null(ops, msg_queue_associate);
 	set_to_cap_if_null(ops, msg_queue_msgctl);
 	set_to_cap_if_null(ops, msg_queue_msgsnd);
 	set_to_cap_if_null(ops, msg_queue_msgrcv);
+	set_to_cap_if_null(ops, msg_queue_restore);
 	set_to_cap_if_null(ops, shm_alloc_security);
 	set_to_cap_if_null(ops, shm_free_security);
 	set_to_cap_if_null(ops, shm_associate);
 	set_to_cap_if_null(ops, shm_shmctl);
 	set_to_cap_if_null(ops, shm_shmat);
+	set_to_cap_if_null(ops, shm_restore);
 	set_to_cap_if_null(ops, sem_alloc_security);
 	set_to_cap_if_null(ops, sem_free_security);
 	set_to_cap_if_null(ops, sem_associate);
 	set_to_cap_if_null(ops, sem_semctl);
 	set_to_cap_if_null(ops, sem_semop);
+	set_to_cap_if_null(ops, sem_restore);
 	set_to_cap_if_null(ops, netlink_send);
 	set_to_cap_if_null(ops, netlink_recv);
 	set_to_cap_if_null(ops, d_instantiate);
diff --git a/security/security.c b/security/security.c
index 5284255..d737e0e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -16,6 +16,7 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/security.h>
+#include <linux/checkpoint.h>
 
 /* Boot-time LSM user choice */
 static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1];
@@ -832,6 +833,16 @@ void security_msg_msg_free(struct msg_msg *msg)
 	security_ops->msg_msg_free_security(msg);
 }
 
+void security_msg_msg_getsecid(struct msg_msg *msg, u32 *secid)
+{
+	security_ops->msg_msg_getsecid(msg, secid);
+}
+
+int security_msg_msg_restore(struct msg_msg *msg, u32 secid)
+{
+	return security_ops->msg_msg_restore(msg, secid);
+}
+
 int security_msg_queue_alloc(struct msg_queue *msq)
 {
 	return security_ops->msg_queue_alloc_security(msq);
@@ -864,6 +875,11 @@ int security_msg_queue_msgrcv(struct msg_queue *msq, struct msg_msg *msg,
 	return security_ops->msg_queue_msgrcv(msq, msg, target, type, mode);
 }
 
+int security_msg_queue_restore(struct msg_queue *msq, u32 secid)
+{
+	return security_ops->msg_queue_restore(msq, secid);
+}
+
 int security_shm_alloc(struct shmid_kernel *shp)
 {
 	return security_ops->shm_alloc_security(shp);
@@ -889,6 +905,11 @@ int security_shm_shmat(struct shmid_kernel *shp, char __user *shmaddr, int shmfl
 	return security_ops->shm_shmat(shp, shmaddr, shmflg);
 }
 
+int security_shm_restore(struct shmid_kernel *shp, u32 secid)
+{
+	return security_ops->shm_restore(shp, secid);
+}
+
 int security_sem_alloc(struct sem_array *sma)
 {
 	return security_ops->sem_alloc_security(sma);
@@ -915,6 +936,11 @@ int security_sem_semop(struct sem_array *sma, struct sembuf *sops,
 	return security_ops->sem_semop(sma, sops, nsops, alter);
 }
 
+int security_sem_restore(struct sem_array *sma, u32 secid)
+{
+	return security_ops->sem_restore(sma, secid);
+}
+
 void security_d_instantiate(struct dentry *dentry, struct inode *inode)
 {
 	if (unlikely(inode && IS_PRIVATE(inode)))
@@ -1247,3 +1273,146 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 }
 
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_CHECKPOINT
+
+static int do_checkpoint_security(struct ckpt_ctx *ctx,
+				struct sec_store *s)
+{
+	char *str;
+	int ret, len;
+
+	ret = security_secid_to_secctx(s->secid, &str, &len);
+	if (ret)
+		return ret;
+	ret = ckpt_write_obj_type(ctx, str, len, CKPT_HDR_SECURITY);
+	security_release_secctx(str, len);
+	return ret;
+}
+
+int checkpoint_security(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_security(ctx, (struct sec_store *) ptr);
+}
+
+/*
+ * stupid ordered list insertion  Replace with rbtree or hash
+ * return 1 if the secid was already stored
+ * call with ctx->secref_lock held
+ */
+static int insert_secref(struct ckpt_ctx *ctx, struct sec_store *news)
+{
+	struct sec_store *last=NULL, *s;
+
+	if (list_empty(&ctx->secref_list)) {
+		list_add(&news->list, &ctx->secref_list);
+		return 0;
+	}
+
+	list_for_each_entry(s, &ctx->secref_list, list) {
+		if (s->secid == news->secid)
+			/* race */
+			return 1;
+		else if (s->secid < news->secid)
+			last = s;
+		else
+			break;
+	}
+	/*
+	 * if last is not null, insert after last.  Otherwise
+	 * this should be the first item
+	 */
+	if (last)
+		list_add(&news->list, &last->list);
+	else
+		list_add(&news->list, &ctx->secref_list);
+	return 0;
+}
+
+/* just need some sane value */
+#define MAX_STR_LEN 300
+static struct sec_store *do_restore_security(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_sec *h;
+	int id;
+	int ret, conflict;
+	struct sec_store *s;
+
+	h = ckpt_read_buf_type(ctx, MAX_STR_LEN, CKPT_HDR_SECURITY);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	ret = security_secctx_to_secid(h->str, strlen(h->str)+1, &id);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	s = kmalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return ERR_PTR(-ENOMEM);
+	s->secid = id;
+	spin_lock(&ctx->secref_lock);
+	conflict = insert_secref(ctx, s);
+	spin_unlock(&ctx->secref_lock);
+	if (conflict) /* not possible */
+		return ERR_PTR(-EINVAL);
+	return s;
+}
+
+void *restore_security(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_security(ctx);
+}
+
+/*
+ * if there's already a cached entry with secid, return
+ * its secref.  Return -1 if there is no such entry.  If
+ * LSMs are actually not supported, then a value of 0 may
+ * in fact be returned as the secref
+ */
+static int get_secref_from_secid(struct ckpt_ctx *ctx, int secid)
+{
+	int ret = -1;
+	struct sec_store *s;
+
+	spin_lock(&ctx->secref_lock);
+	list_for_each_entry(s, &ctx->secref_list, list)
+		if (s->secid == secid) {
+			ret = s->secref;
+			break;
+		}
+	spin_unlock(&ctx->secref_lock);
+	return ret;
+}
+
+/*
+ * get a objhash reference from a secid
+ * if already stored, return existing ref
+ * else checkpoint it and return the new ref
+ */
+int checkpoint_security_getsecref(struct ckpt_ctx *ctx, int secid)
+{
+	int ret, conflict=0, secref = 0;
+	struct sec_store *s;
+
+again:
+	ret = get_secref_from_secid(ctx, secid);
+	if (ret >= 0)
+		return ret;
+	BUG_ON(conflict!=0); /* a racer added it to list, but now it's gone? */
+	s = kzalloc(sizeof(*s), GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+	s->secid = secid;
+	spin_lock(&ctx->secref_lock);
+	conflict = insert_secref(ctx, s);
+	if (conflict) {
+		spin_unlock(&ctx->secref_lock);
+		kfree(s);
+		goto again;
+	}
+	if (secid != 0)
+		secref = checkpoint_obj(ctx, s, CKPT_OBJ_SECURITY);
+	s->secref = secref;
+	spin_unlock(&ctx->secref_lock);
+	return secref;
+}
+#endif
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fcad7c..591f545 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4675,6 +4675,19 @@ static void msg_msg_free_security(struct msg_msg *msg)
 	kfree(msec);
 }
 
+static int selinux_msg_msg_restore(struct msg_msg *msg, u32 secid)
+{
+	struct msg_security_struct *msec = msg->security;
+	u32 sid = current_sid();
+	int ret;
+
+	ret = avc_has_perm(sid, secid, SECCLASS_MSG, MSG__RESTORE, NULL);
+	if (ret)
+		return ret;
+	msec->sid = secid;
+	return 0;
+}
+
 static int ipc_has_perm(struct kern_ipc_perm *ipc_perms,
 			u32 perms)
 {
@@ -4700,6 +4713,12 @@ static void selinux_msg_msg_free_security(struct msg_msg *msg)
 	msg_msg_free_security(msg);
 }
 
+static void selinux_msg_msg_getsecid(struct msg_msg *msg, u32 *secid)
+{
+	struct msg_security_struct *msec = msg->security;
+	*secid = msec->sid;
+}
+
 /* message queue security operations */
 static int selinux_msg_queue_alloc_security(struct msg_queue *msq)
 {
@@ -4841,6 +4860,14 @@ static int selinux_msg_queue_msgrcv(struct msg_queue *msq, struct msg_msg *msg,
 	return rc;
 }
 
+static int selinux_msg_queue_restore(struct msg_queue *msq, u32 secid)
+{
+	struct ipc_security_struct *isec = msq->q_perm.security;
+
+	isec->sid = secid;
+	return ipc_has_perm(&msq->q_perm, MSGQ__RESTORE);
+}
+
 /* Shared Memory security operations */
 static int selinux_shm_alloc_security(struct shmid_kernel *shp)
 {
@@ -4933,6 +4960,14 @@ static int selinux_shm_shmat(struct shmid_kernel *shp,
 	return ipc_has_perm(&shp->shm_perm, perms);
 }
 
+static int selinux_shm_restore(struct shmid_kernel *shp, u32 secid)
+{
+	struct ipc_security_struct *isec = shp->shm_perm.security;
+
+	isec->sid = secid;
+	return ipc_has_perm(&shp->shm_perm, SHM__RESTORE);
+}
+
 /* Semaphore security operations */
 static int selinux_sem_alloc_security(struct sem_array *sma)
 {
@@ -5034,6 +5069,14 @@ static int selinux_sem_semop(struct sem_array *sma,
 	return ipc_has_perm(&sma->sem_perm, perms);
 }
 
+static int selinux_sem_restore(struct sem_array *sma, u32 secid)
+{
+	struct ipc_security_struct *isec = sma->sem_perm.security;
+
+	isec->sid = secid;
+	return ipc_has_perm(&sma->sem_perm, SEM__RESTORE);
+}
+
 static int selinux_ipc_permission(struct kern_ipc_perm *ipcp, short flag)
 {
 	u32 av = 0;
@@ -5415,6 +5458,8 @@ static struct security_operations selinux_ops = {
 
 	.msg_msg_alloc_security =	selinux_msg_msg_alloc_security,
 	.msg_msg_free_security =	selinux_msg_msg_free_security,
+	.msg_msg_getsecid =		selinux_msg_msg_getsecid,
+	.msg_msg_restore =		selinux_msg_msg_restore,
 
 	.msg_queue_alloc_security =	selinux_msg_queue_alloc_security,
 	.msg_queue_free_security =	selinux_msg_queue_free_security,
@@ -5422,18 +5467,21 @@ static struct security_operations selinux_ops = {
 	.msg_queue_msgctl =		selinux_msg_queue_msgctl,
 	.msg_queue_msgsnd =		selinux_msg_queue_msgsnd,
 	.msg_queue_msgrcv =		selinux_msg_queue_msgrcv,
+	.msg_queue_restore =		selinux_msg_queue_restore,
 
 	.shm_alloc_security =		selinux_shm_alloc_security,
 	.shm_free_security =		selinux_shm_free_security,
 	.shm_associate =		selinux_shm_associate,
 	.shm_shmctl =			selinux_shm_shmctl,
 	.shm_shmat =			selinux_shm_shmat,
+	.shm_restore =			selinux_shm_restore,
 
 	.sem_alloc_security =		selinux_sem_alloc_security,
 	.sem_free_security =		selinux_sem_free_security,
 	.sem_associate =		selinux_sem_associate,
 	.sem_semctl =			selinux_sem_semctl,
 	.sem_semop =			selinux_sem_semop,
+	.sem_restore =			selinux_sem_restore,
 
 	.d_instantiate =		selinux_d_instantiate,
 
diff --git a/security/selinux/include/av_inherit.h b/security/selinux/include/av_inherit.h
index 8377a4b..0d7689d 100644
--- a/security/selinux/include/av_inherit.h
+++ b/security/selinux/include/av_inherit.h
@@ -15,10 +15,10 @@
    S_(SECCLASS_KEY_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_UNIX_STREAM_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_UNIX_DGRAM_SOCKET, socket, 0x00400000UL)
-   S_(SECCLASS_IPC, ipc, 0x00000200UL)
-   S_(SECCLASS_SEM, ipc, 0x00000200UL)
-   S_(SECCLASS_MSGQ, ipc, 0x00000200UL)
-   S_(SECCLASS_SHM, ipc, 0x00000200UL)
+   S_(SECCLASS_IPC, ipc, 0x00000400UL)
+   S_(SECCLASS_SEM, ipc, 0x00000400UL)
+   S_(SECCLASS_MSGQ, ipc, 0x00000400UL)
+   S_(SECCLASS_SHM, ipc, 0x00000400UL)
    S_(SECCLASS_NETLINK_ROUTE_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_FIREWALL_SOCKET, socket, 0x00400000UL)
    S_(SECCLASS_NETLINK_TCPDIAG_SOCKET, socket, 0x00400000UL)
diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
index d645192..3c3eba6 100644
--- a/security/selinux/include/av_permissions.h
+++ b/security/selinux/include/av_permissions.h
@@ -47,6 +47,7 @@
 #define COMMON_IPC__ASSOCIATE                            0x00000040UL
 #define COMMON_IPC__UNIX_READ                            0x00000080UL
 #define COMMON_IPC__UNIX_WRITE                           0x00000100UL
+#define COMMON_IPC__RESTORE                              0x00000200UL
 #define FILESYSTEM__MOUNT                         0x00000001UL
 #define FILESYSTEM__REMOUNT                       0x00000002UL
 #define FILESYSTEM__UNMOUNT                       0x00000004UL
@@ -462,6 +463,7 @@
 #define IPC__ASSOCIATE                            0x00000040UL
 #define IPC__UNIX_READ                            0x00000080UL
 #define IPC__UNIX_WRITE                           0x00000100UL
+#define IPC__RESTORE                              0x00000200UL
 #define SEM__CREATE                               0x00000001UL
 #define SEM__DESTROY                              0x00000002UL
 #define SEM__GETATTR                              0x00000004UL
@@ -471,6 +473,7 @@
 #define SEM__ASSOCIATE                            0x00000040UL
 #define SEM__UNIX_READ                            0x00000080UL
 #define SEM__UNIX_WRITE                           0x00000100UL
+#define SEM__RESTORE                              0x00000200UL
 #define MSGQ__CREATE                              0x00000001UL
 #define MSGQ__DESTROY                             0x00000002UL
 #define MSGQ__GETATTR                             0x00000004UL
@@ -480,9 +483,11 @@
 #define MSGQ__ASSOCIATE                           0x00000040UL
 #define MSGQ__UNIX_READ                           0x00000080UL
 #define MSGQ__UNIX_WRITE                          0x00000100UL
-#define MSGQ__ENQUEUE                             0x00000200UL
+#define MSGQ__RESTORE                             0x00000200UL
+#define MSGQ__ENQUEUE                             0x00000400UL
 #define MSG__SEND                                 0x00000001UL
 #define MSG__RECEIVE                              0x00000002UL
+#define MSG__RESTORE                              0x00000004UL
 #define SHM__CREATE                               0x00000001UL
 #define SHM__DESTROY                              0x00000002UL
 #define SHM__GETATTR                              0x00000004UL
@@ -492,7 +497,8 @@
 #define SHM__ASSOCIATE                            0x00000040UL
 #define SHM__UNIX_READ                            0x00000080UL
 #define SHM__UNIX_WRITE                           0x00000100UL
-#define SHM__LOCK                                 0x00000200UL
+#define SHM__RESTORE                              0x00000200UL
+#define SHM__LOCK                                 0x00000400UL
 #define SECURITY__COMPUTE_AV                      0x00000001UL
 #define SECURITY__COMPUTE_CREATE                  0x00000002UL
 #define SECURITY__COMPUTE_MEMBER                  0x00000004UL
diff --git a/security/selinux/include/common_perm_to_string.h b/security/selinux/include/common_perm_to_string.h
index ce5b6e2..fb94053 100644
--- a/security/selinux/include/common_perm_to_string.h
+++ b/security/selinux/include/common_perm_to_string.h
@@ -54,5 +54,6 @@ TB_(common_ipc_perm_to_string)
     S_("associate")
     S_("unix_read")
     S_("unix_write")
+    S_("restore")
 TE_(common_ipc_perm_to_string)
 
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 98b3195..070aeb7 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1619,6 +1619,33 @@ static void smack_msg_msg_free_security(struct msg_msg *msg)
 }
 
 /**
+ * smack_msg_msg_getsecid - Extract smack security id
+ * @msg: the object
+ * @secid: where result will be saved
+ */
+static void smack_msg_msg_getsecid(struct msg_msg *msg, u32 *secid)
+{
+	char *smack = msg->security;
+
+	*secid = smack_to_secid(smack);
+}
+
+static int smack_msg_msg_restore(struct msg_msg *msg, u32 secid)
+{
+	char *smack = smack_from_secid(secid);
+
+	if (smack == NULL)
+		return -EINVAL;
+	if (current_security() != smack) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		msg->security = smack;
+	} else
+		msg->security = current_security();
+	return 0;
+}
+
+/**
  * smack_of_shm - the smack pointer for the shm
  * @shp: the object
  *
@@ -1727,6 +1754,21 @@ static int smack_shm_shmat(struct shmid_kernel *shp, char __user *shmaddr,
 	return smk_curacc(ssp, may);
 }
 
+static int smack_shm_restore(struct shmid_kernel *shp, u32 secid)
+{
+	char *smack = smack_from_secid(secid);
+
+	if (smack == NULL)
+		return -EINVAL;
+	if (current_security() != smack) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		shp->shm_perm.security = smack;
+	} else
+		shp->shm_perm.security = current_security();
+	return 0;
+}
+
 /**
  * smack_of_sem - the smack pointer for the sem
  * @sma: the object
@@ -1842,6 +1884,21 @@ static int smack_sem_semop(struct sem_array *sma, struct sembuf *sops,
 	return smk_curacc(ssp, MAY_READWRITE);
 }
 
+static int smack_sem_restore(struct sem_array *sma, u32 secid)
+{
+	char *smack = smack_from_secid(secid);
+
+	if (smack == NULL)
+		return -EINVAL;
+	if (current_security() != smack) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		sma->sem_perm.security = smack;
+	} else
+		sma->sem_perm.security = current_security();
+	return 0;
+}
+
 /**
  * smack_msg_alloc_security - Set the security blob for msg
  * @msq: the object
@@ -1967,6 +2024,21 @@ static int smack_msg_queue_msgrcv(struct msg_queue *msq, struct msg_msg *msg,
 	return smk_curacc(msp, MAY_READWRITE);
 }
 
+static int smack_msg_queue_restore(struct msg_queue *msq, u32 secid)
+{
+	char *smack = smack_from_secid(secid);
+
+	if (smack == NULL)
+		return -EINVAL;
+	if (current_security() != smack) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		msq->q_perm.security = smack;
+	} else
+		msq->q_perm.security = current_security();
+	return 0;
+}
+
 /**
  * smack_ipc_permission - Smack access for ipc_permission()
  * @ipp: the object permissions
@@ -2903,6 +2975,8 @@ struct security_operations smack_ops = {
 
 	.msg_msg_alloc_security = 	smack_msg_msg_alloc_security,
 	.msg_msg_free_security = 	smack_msg_msg_free_security,
+	.msg_msg_getsecid = 		smack_msg_msg_getsecid,
+	.msg_msg_restore = 		smack_msg_msg_restore,
 
 	.msg_queue_alloc_security = 	smack_msg_queue_alloc_security,
 	.msg_queue_free_security = 	smack_msg_queue_free_security,
@@ -2910,18 +2984,21 @@ struct security_operations smack_ops = {
 	.msg_queue_msgctl = 		smack_msg_queue_msgctl,
 	.msg_queue_msgsnd = 		smack_msg_queue_msgsnd,
 	.msg_queue_msgrcv = 		smack_msg_queue_msgrcv,
+	.msg_queue_restore = 		smack_msg_queue_restore,
 
 	.shm_alloc_security = 		smack_shm_alloc_security,
 	.shm_free_security = 		smack_shm_free_security,
 	.shm_associate = 		smack_shm_associate,
 	.shm_shmctl = 			smack_shm_shmctl,
 	.shm_shmat = 			smack_shm_shmat,
+	.shm_restore = 			smack_shm_restore,
 
 	.sem_alloc_security = 		smack_sem_alloc_security,
 	.sem_free_security = 		smack_sem_free_security,
 	.sem_associate = 		smack_sem_associate,
 	.sem_semctl = 			smack_sem_semctl,
 	.sem_semop = 			smack_sem_semop,
+	.sem_restore = 			smack_sem_restore,
 
 	.netlink_send =			cap_netlink_send,
 	.netlink_recv = 		cap_netlink_recv,
-- 
1.6.1

