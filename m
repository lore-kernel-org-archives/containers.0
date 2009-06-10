From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/10] cr: restore LSM credentials
Date: Tue, 9 Jun 2009 20:46:37 -0500
Message-ID: <20090610014637.GH5658@us.ibm.com>
References: <20090610014412.GA5628@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090610014412.GA5628-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint and restore task and ipc struct ->security info.
(files->f_security yet to be done).

LSM contexts (a string representation of obj->security) are
checkpointed as shared objects before any object referencing
it.  The object's checkpoint header struct has a reference
(h->sec_ref) to the shared object.  A NULL ->security is indicated
by h->sec_ref = -1.

At checkpoint time, for each obj->security to be checkpointed,
the LSM will be asked (once) to convert it to a string, in memory
which the checkpoint subsystem will kfree.  At restart time,
the LSM will first return some meaningful token given the
checkpointed string.  That token will be passed to per-object-type
restore functions (task_restore_context(), shm_restore_security(),
etc) where the LSM can determine based on the object type, the
caller, and the token, whether to allow the object restore, and
what value to actually assign to ->security.  In smack, the
token is the actual imported label.  In SELinux, it is a temporary
pointer to the sid which the checkpointed context referred to.

In smack, the checkpointed labels are used for both tasks and
ipc objects so long as the task calling sys_restart() has
CAP_MAC_ADMIN.  Otherwise, if the checkpointed label is different
from current_security(), -EPERM is returned.

The basics of SELinux support are there (enough to demonstrate working
c/r with SELinux enforcing), but there will need to be new object
permissions for restore, so the precise nature of those needs to be
discussed.  For instance, do we want to define process:restore
and ipc_msg_msg:restore, in which case
        allow root_t user_t:process restore
would mean that root_t may restart a task and label it user_t?

Since we are potentially skipping several allowed domain transitions
(resulting in an illegal short-cut domain transition or type creation),
I have a fear that the only sane way to proceed would be to have
one all-powerful domain, checkpoint_restore_t, which can effectively
transition to any domain it wants to by (ab)using the checkpoint
image.

Or, perhaps we can define intermediate domains...  So if we want
user_t to be able to restart a server of type X_t, then we create
a X_restore_t type, allow user_t to transition to it using a
program which does sys_restart(), which in turn may transition to
X_t?

Obviously this needs discussion.

Tomoyo has not been updated or tested.  Given its path-based
domain name model, I'm not sure what the tomoyo maintainers
would prefer - that the restart program be reflected in the
domain name, or that the original domain name be restored.

This is the first posting of this patch.  There are testcases
in git://git.sr71.net/~hallyn/cr_tests.git , in particular
under (the slightly mis-named) cr_tests/userns/ directory.
All pass fine with all LSMS (except Tomoyo, not tested).

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c           |   56 ++++++++++++
 include/linux/checkpoint_hdr.h |   15 +++
 include/linux/security.h       |  105 +++++++++++++++++++++
 ipc/checkpoint.c               |   19 +++--
 ipc/checkpoint_msg.c           |   30 ++++++-
 ipc/checkpoint_sem.c           |   12 +++-
 ipc/checkpoint_shm.c           |   12 +++-
 ipc/util.h                     |    3 +-
 kernel/cred.c                  |   29 ++++++-
 security/capability.c          |   47 ++++++++++
 security/security.c            |   39 ++++++++
 security/selinux/hooks.c       |  196 ++++++++++++++++++++++++++++++++++++++++
 security/smack/smack_lsm.c     |  135 +++++++++++++++++++++++++++
 13 files changed, 686 insertions(+), 12 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 84f003d..674b9b3 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -20,6 +20,7 @@
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/security.h>
 
 struct ckpt_obj;
 struct ckpt_obj_ops;
@@ -247,6 +248,52 @@ static int obj_groupinfo_users(void *ptr)
 	return atomic_read(&((struct group_info *) ptr)->usage);
 }
 
+/*
+ * checkpoint_string - checkpoint a shared string
+ * @ctx: checkpoint context
+ * @str: string to checkpoint
+ *
+ * If ptr has already been checkpointed, return the objref
+ * Else write it to checkpoint image and return the objref
+ * On error, return <0.
+ */
+#define MAX_STR_LEN 200
+static int checkpoint_security(struct ckpt_ctx *ctx, void *ptr)
+{
+	char *str;
+	int ret;
+	int len = 0;
+
+	str = security_context_to_str(ptr);
+	if (!str)
+		return 0;
+	if (IS_ERR(str))
+		return PTR_ERR(str);
+	len = strlen(str) + 1;
+	if (len > MAX_STR_LEN) {
+		printk(KERN_NOTICE "%s: security context too long\n",
+			__func__);
+		return -EINVAL;
+	}
+	ret = ckpt_write_obj_type(ctx, str, len, CKPT_HDR_SEC);
+	/* the LSM created a new string for us, now free it */
+	kfree(str);
+	return ret;
+}
+
+static void *restore_security(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_lsm *h;
+	void *security;
+
+	h = ckpt_read_buf_type(ctx, MAX_STR_LEN, CKPT_HDR_SEC);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	security = security_context_from_str(h->str);
+	ckpt_hdr_put(ctx, h);
+	return security;
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -364,6 +411,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_groupinfo,
 		.restore = restore_groupinfo,
 	},
+	/* struct ckpt_sec */
+	{
+		.obj_name = "SECURITY",
+		.obj_type = CKPT_OBJ_SEC,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+		.checkpoint = checkpoint_security,
+		.restore = restore_security,
+	},
 };
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 1a4033c..a447b5a 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -45,6 +45,7 @@ enum {
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
 	CKPT_HDR_OBJREF,
+	CKPT_HDR_SEC,
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
@@ -114,6 +115,7 @@ enum obj_type {
 	CKPT_OBJ_CRED,
 	CKPT_OBJ_USER,
 	CKPT_OBJ_GROUPINFO,
+	CKPT_OBJ_SEC,
 	CKPT_OBJ_MAX
 };
 
@@ -181,6 +183,13 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+/* LSM security contexts (shared) */
+struct ckpt_hdr_lsm {
+	struct ckpt_hdr h;
+	/* followed by `len' characters */
+	char str[];
+} __attribute__((aligned(8)));
+
 /* Posix capabilities */
 struct ckpt_capabilities {
 	__u32 cap_i_0, cap_i_1; /* inheritable set */
@@ -204,6 +213,8 @@ struct ckpt_hdr_cred {
 	__s32 user_ref;
 	__s32 groupinfo_ref;
 	struct ckpt_capabilities cap_s;
+	__s32 sec_ref;
+	__u32 padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_groupinfo {
@@ -418,6 +429,8 @@ struct ckpt_hdr_ipc_perms {
 	__u32 mode;
 	__u32 _padding;
 	__u64 seq;
+	__s32 sec_ref;
+	__u32 padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_shm {
@@ -451,6 +464,8 @@ struct ckpt_hdr_ipc_msg_msg {
 	struct ckpt_hdr h;
 	__s32 m_type;
 	__u32 m_ts;
+	__s32 sec_ref;
+	__u32 padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_sem {
diff --git a/include/linux/security.h b/include/linux/security.h
index d5fd616..5625553 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1089,6 +1089,12 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	created.
  *	@msg contains the message structure to be modified.
  *	Return 0 if operation was successful and permission is granted.
+ * @msg_msg_restore_security:
+ *	Allocate and attach a security structure to the msg->security field
+ *	during sys_restart().
+ *	@msg contains the message structure to be modified.
+ *	@stored contains a string representing the checkpointed context
+ *	Return 0 if operation was successful and permission is granted.
  * @msg_msg_free_security:
  *	Deallocate the security structure for this message.
  *	@msg contains the message structure to be modified.
@@ -1101,6 +1107,14 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	NULL when the structure is first created.
  *	@msq contains the message queue structure to be modified.
  *	Return 0 if operation was successful and permission is granted.
+ * @msg_queue_restore_security:
+ *	Allocate and attach a security structure to the
+ *	msq->q_perm.security field when a msgq is being restored, based on the
+ *	checkpointed context.
+ *	@msq contains the message queue structure to be modified.
+ *	@stored containers a string representation of the checkpointed
+ *	context.
+ *	Return 0 if operation was successful and permission is granted.
  * @msg_queue_free_security:
  *	Deallocate security structure for this message queue.
  *	@msq contains the message queue structure to be modified.
@@ -1146,6 +1160,12 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	first created.
  *	@shp contains the shared memory structure to be modified.
  *	Return 0 if operation was successful and permission is granted.
+ * @shm_restore_security:
+ *	Allocate and attach a security structure to the shp->shm_perm.security
+ *	field during sys_restart().
+ *	@shp contains the shared memory structure to be modified.
+ *	@stored containers the checkpoint security context string.
+ *	Return 0 if operation was successful and permission is granted.
  * @shm_free_security:
  *	Deallocate the security struct for this memory segment.
  *	@shp contains the shared memory structure to be modified.
@@ -1181,6 +1201,12 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	first created.
  *	@sma contains the semaphore structure
  *	Return 0 if operation was successful and permission is granted.
+ * @sem_restore_security:
+ *	Allocate and attach a security structure to the sma->sem_perm.security
+ *	field during sys_restart().
+ *	@sma contains the semaphore structure
+ *	@stored contains the string respresentation of checkpointed ->security.
+ *	Return 0 if operation was successful and permission is granted.
  * @sem_free_security:
  *	deallocate security struct for this semaphore
  *	@sma contains the semaphore structure.
@@ -1331,6 +1357,31 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	audit_rule_init.
  *	@rule contains the allocated rule
  *
+ * Security hooks for checkpoint/restore of security contexts
+
+ * @context_to_str:
+ *	Given a void *->security, return a char* which will be meaningful
+ *	at the restart.  For most LSMs, this will likely be
+ *	"(char *)ptr"
+ *	@ptr: The ->security field to convert to a string.
+ *	@str: The string representation of @ptr.
+ *	Return a valid char*, or < 0 if error.
+ *
+ * @context_from_str:
+ *	Given a char *, return a valid ->security which can be assigned
+ *	to an object.
+ *	@str: The string representation of a context
+ *	Return < 0 if error.  For instance -EINVAL if the current policy
+ *	has no such context.
+ *
+ * @task_restore_context:
+ *	Choose a valid context for a task being restored from checkpoint
+ *	image.
+ *	@orig: The struct cred of the task which called sys_restart()
+ *	@stored: The context stored for the checkpointed task.
+ *	@f_security: The context of the checkpoint file.
+ *	Return 0 if cred was updated, < 0 if restart should be denied
+ *
  * This is the main security structure.
  */
 struct security_operations {
@@ -1498,9 +1549,11 @@ struct security_operations {
 	void (*ipc_getsecid) (struct kern_ipc_perm *ipcp, u32 *secid);
 
 	int (*msg_msg_alloc_security) (struct msg_msg *msg);
+	int (*msg_msg_restore_security) (struct msg_msg *msg, void *stored);
 	void (*msg_msg_free_security) (struct msg_msg *msg);
 
 	int (*msg_queue_alloc_security) (struct msg_queue *msq);
+	int (*msg_queue_restore_security) (struct msg_queue *msq, void *stored);
 	void (*msg_queue_free_security) (struct msg_queue *msq);
 	int (*msg_queue_associate) (struct msg_queue *msq, int msqflg);
 	int (*msg_queue_msgctl) (struct msg_queue *msq, int cmd);
@@ -1512,6 +1565,7 @@ struct security_operations {
 				 long type, int mode);
 
 	int (*shm_alloc_security) (struct shmid_kernel *shp);
+	int (*shm_restore_security) (struct shmid_kernel *shp, void *stored);
 	void (*shm_free_security) (struct shmid_kernel *shp);
 	int (*shm_associate) (struct shmid_kernel *shp, int shmflg);
 	int (*shm_shmctl) (struct shmid_kernel *shp, int cmd);
@@ -1519,6 +1573,7 @@ struct security_operations {
 			  char __user *shmaddr, int shmflg);
 
 	int (*sem_alloc_security) (struct sem_array *sma);
+	int (*sem_restore_security) (struct sem_array *sma, void *stored);
 	void (*sem_free_security) (struct sem_array *sma);
 	int (*sem_associate) (struct sem_array *sma, int semflg);
 	int (*sem_semctl) (struct sem_array *sma, int cmd);
@@ -1609,6 +1664,11 @@ struct security_operations {
 				 struct audit_context *actx);
 	void (*audit_rule_free) (void *lsmrule);
 #endif /* CONFIG_AUDIT */
+
+	char *(*context_to_str) (void *security);
+	void *(*context_from_str) (char *str);
+	int (*task_restore_context) (struct cred *cred, void *stored,
+				       void *f_security);
 };
 
 /* prototypes */
@@ -1747,8 +1807,10 @@ void security_task_to_inode(struct task_struct *p, struct inode *inode);
 int security_ipc_permission(struct kern_ipc_perm *ipcp, short flag);
 void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid);
 int security_msg_msg_alloc(struct msg_msg *msg);
+int security_msg_msg_restore(struct msg_msg *msg, void *stored);
 void security_msg_msg_free(struct msg_msg *msg);
 int security_msg_queue_alloc(struct msg_queue *msq);
+int security_msg_queue_restore(struct msg_queue *msq, void *stored);
 void security_msg_queue_free(struct msg_queue *msq);
 int security_msg_queue_associate(struct msg_queue *msq, int msqflg);
 int security_msg_queue_msgctl(struct msg_queue *msq, int cmd);
@@ -1757,11 +1819,13 @@ int security_msg_queue_msgsnd(struct msg_queue *msq,
 int security_msg_queue_msgrcv(struct msg_queue *msq, struct msg_msg *msg,
 			      struct task_struct *target, long type, int mode);
 int security_shm_alloc(struct shmid_kernel *shp);
+int security_shm_restore(struct shmid_kernel *shp, void *stored);
 void security_shm_free(struct shmid_kernel *shp);
 int security_shm_associate(struct shmid_kernel *shp, int shmflg);
 int security_shm_shmctl(struct shmid_kernel *shp, int cmd);
 int security_shm_shmat(struct shmid_kernel *shp, char __user *shmaddr, int shmflg);
 int security_sem_alloc(struct sem_array *sma);
+int security_sem_restore(struct sem_array *sma, void *stored);
 void security_sem_free(struct sem_array *sma);
 int security_sem_associate(struct sem_array *sma, int semflg);
 int security_sem_semctl(struct sem_array *sma, int cmd);
@@ -1775,6 +1839,10 @@ int security_netlink_recv(struct sk_buff *skb, int cap);
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
+char *security_context_to_str(void *security);
+void *security_context_from_str(char *str);
+int security_task_restore_context(struct cred *cred, void *stored,
+				void *f_security);
 
 #else /* CONFIG_SECURITY */
 struct security_mnt_opts {
@@ -2393,6 +2461,11 @@ static inline int security_msg_msg_alloc(struct msg_msg *msg)
 	return 0;
 }
 
+static inline int security_msg_msg_restore(struct msg_msg *msg, void *stored)
+{
+	return 0;
+}
+
 static inline void security_msg_msg_free(struct msg_msg *msg)
 { }
 
@@ -2401,6 +2474,12 @@ static inline int security_msg_queue_alloc(struct msg_queue *msq)
 	return 0;
 }
 
+static inline int security_msg_queue_restore(struct msg_queue *msq,
+						void *stored)
+{
+	return 0;
+}
+
 static inline void security_msg_queue_free(struct msg_queue *msq)
 { }
 
@@ -2434,6 +2513,11 @@ static inline int security_shm_alloc(struct shmid_kernel *shp)
 	return 0;
 }
 
+static inline int security_shm_restore(struct shmid_kernel *shp, void *stored)
+{
+	return 0;
+}
+
 static inline void security_shm_free(struct shmid_kernel *shp)
 { }
 
@@ -2459,6 +2543,11 @@ static inline int security_sem_alloc(struct sem_array *sma)
 	return 0;
 }
 
+static inline int security_sem_restore(struct sem_array *sma, void *stored)
+{
+	return 0;
+}
+
 static inline void security_sem_free(struct sem_array *sma)
 { }
 
@@ -2517,6 +2606,22 @@ static inline int security_secctx_to_secid(const char *secdata,
 static inline void security_release_secctx(char *secdata, u32 seclen)
 {
 }
+
+static inline char *security_context_to_str(void *security)
+{
+	return NULL;
+}
+
+static inline void *security_context_from_str(char *str)
+{
+	return NULL;
+}
+
+static inline int security_task_restore_context(struct cred *cred,
+				void *stored, void *f_security)
+{
+	return 0;
+}
 #endif	/* CONFIG_SECURITY */
 
 #ifdef CONFIG_SECURITY_NETWORK
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index bc77743..6da8ac8 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -27,7 +27,8 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
  * Checkpoint
  */
 
-int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+			      struct ckpt_hdr_ipc_perms *h,
 			      struct kern_ipc_perm *perm)
 {
 	if (ipcperms(perm, S_IROTH))
@@ -42,6 +43,13 @@ int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	h->mode = perm->mode & S_IRWXUGO;
 	h->seq = perm->seq;
 
+	if (perm->security) {
+		h->sec_ref = checkpoint_obj(ctx, perm->security, CKPT_OBJ_SEC);
+		if (h->sec_ref < 0)
+			return h->sec_ref;
+	} else
+		h->sec_ref = -1;
+
 	return 0;
 }
 
@@ -169,13 +177,10 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
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
index fb1a61e..025e33f 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -18,6 +18,7 @@
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/security.h>
 
 #include "util.h"
 
@@ -36,7 +37,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&msq->q_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -63,13 +64,20 @@ static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
 	struct msg_msgseg *seg;
 	int total, len;
 	int ret;
+	int sec_ref = -1;
 
+	if (msg->security) {
+		sec_ref = checkpoint_obj(ctx, msg->security, CKPT_OBJ_SEC);
+		if (sec_ref < 0)
+			return sec_ref;
+	}
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
 	if (!h)
 		return -ENOMEM;
 
 	h->m_type = msg->m_type;
 	h->m_ts = msg->m_ts;
+	h->sec_ref = sec_ref;
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -175,10 +183,19 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 			    struct msg_queue *msq)
 {
 	int ret = 0;
+	void *security = NULL;;
 
 	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
 	if (ret < 0)
 		return ret;
+	if (h->perms.sec_ref != -1) {
+		security = ckpt_obj_fetch(ctx, h->perms.sec_ref, CKPT_OBJ_SEC);
+		if (IS_ERR(security))
+			return PTR_ERR(security);
+	}
+	ret = security_msg_queue_restore(msq, security);
+	if (ret)
+		return ret;
 
 	ckpt_debug("msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
 		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
@@ -200,6 +217,7 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	struct ckpt_hdr_ipc_msg_msg *h;
 	struct msg_msg *msg = NULL;
 	struct msg_msgseg *seg, **pseg;
+	void *security = NULL;
 	int total, len;
 	int ret;
 
@@ -222,6 +240,16 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	}
 	msg->next = NULL;
 	pseg = &msg->next;
+	if (h->sec_ref != -1) {
+		security = ckpt_obj_fetch(ctx, h->sec_ref, CKPT_OBJ_SEC);
+		if (IS_ERR(security)) {
+			ret = PTR_ERR(security);
+			goto out;
+		}
+	}
+	ret = security_msg_msg_restore(msg, security);
+	if (ret)
+		goto out;
 
 	ret = _ckpt_read_buffer(ctx, (msg + 1), len);
 	if (ret < 0)
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index e6934dc..cd76bcc 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -18,6 +18,7 @@
 #include <linux/syscalls.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/security.h>
 
 #include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
 #include "util.h"
@@ -37,7 +38,7 @@ static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&sem->sem_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -112,10 +113,19 @@ static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
 			       struct sem_array *sem)
 {
 	int ret = 0;
+	void *security = NULL;
 
 	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
 	if (ret < 0)
 		return ret;
+	if (h->perms.sec_ref != -1) {
+		security = ckpt_obj_fetch(ctx, h->perms.sec_ref, CKPT_OBJ_SEC);
+		if (IS_ERR(security))
+			return PTR_ERR(security);
+	}
+	ret = security_sem_restore(sem, security);
+	if (ret)
+		return ret;
 
 	ckpt_debug("sem: nsems %u\n", h->sem_nsems);
 
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 0d8eb14..cf100fe 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -22,6 +22,7 @@
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
 #include <linux/deferqueue.h>
+#include <linux/security.h>
 
 #include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
 #include "util.h"
@@ -41,7 +42,7 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&shp->shm_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -148,10 +149,19 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 			    struct shmid_kernel *shp)
 {
 	int ret;
+	void *security = NULL;
 
 	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
 	if (ret < 0)
 		return ret;
+	if (h->perms.sec_ref != -1) {
+		security = ckpt_obj_fetch(ctx, h->perms.sec_ref, CKPT_OBJ_SEC);
+		if (IS_ERR(security))
+			return PTR_ERR(security);
+	}
+	ret = security_shm_restore(shp, security);
+	if (ret)
+		return ret;
 
 	ckpt_debug("shm: cprid %d lprid %d segsz %lld mlock %d\n",
 		 h->shm_cprid, h->shm_lprid, h->shm_segsz, h->mlock_uid);
diff --git a/ipc/util.h b/ipc/util.h
index 020de7b..5976308 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -192,7 +192,8 @@ extern void freeary(struct ipc_namespace *, struct kern_ipc_perm *);
 extern void do_shm_rmid(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
 #ifdef CONFIG_CHECKPOINT
-extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+extern int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+				     struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
 extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 				  struct kern_ipc_perm *perm);
diff --git a/kernel/cred.c b/kernel/cred.c
index 6ef75a1..c47d175 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -709,8 +709,9 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 int checkpoint_write_cred(struct ckpt_ctx *ctx, const struct cred *cred)
 {
 	int ret;
-	int groupinfo_ref, user_ref;
+	int groupinfo_ref, user_ref, sec_ref = -1;
 	struct ckpt_hdr_cred *h;
+	void *security = NULL;
 
 	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
 					CKPT_OBJ_GROUPINFO);
@@ -719,6 +720,16 @@ int checkpoint_write_cred(struct ckpt_ctx *ctx, const struct cred *cred)
 	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
 	if (user_ref < 0)
 		return user_ref;
+#ifdef CONFIG_SECURITY
+	/* should we checkpoint a 'lsm_na' field when !security ? */
+	security = cred->security;
+#endif
+
+	if (security) {
+		sec_ref = checkpoint_obj(ctx, security, CKPT_OBJ_SEC);
+		if (sec_ref < 0)
+			return sec_ref;
+	}
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
 	if (!h)
@@ -738,6 +749,7 @@ int checkpoint_write_cred(struct ckpt_ctx *ctx, const struct cred *cred)
 
 	h->user_ref = user_ref;
 	h->groupinfo_ref = groupinfo_ref;
+	h->sec_ref = sec_ref;
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	ckpt_hdr_put(ctx, h);
@@ -751,6 +763,7 @@ struct cred *restore_read_cred(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_cred *h;
 	struct user_struct *user;
 	struct group_info *groupinfo;
+	void *security = NULL;
 	int ret = -EINVAL;
 	uid_t olduid;
 	gid_t oldgid;
@@ -774,6 +787,20 @@ struct cred *restore_read_cred(struct ckpt_ctx *ctx)
 	user = ckpt_obj_fetch(ctx, h->user_ref, CKPT_OBJ_USER);
 	if (IS_ERR(user))
 		goto err_putcred;
+	if (h->sec_ref != -1)
+		security = ckpt_obj_fetch(ctx, h->sec_ref, CKPT_OBJ_SEC);
+	if (IS_ERR(security))
+		goto err_putcred;
+
+#ifdef CONFIG_SECURITY
+	/*
+	 * Ask LSM to reset original task->security if allowed
+	 */
+	ret = security_task_restore_context(cred, security,
+					ctx->file->f_security);
+	if (ret)
+		goto err_putcred;
+#endif
 
 	/*
 	 * TODO: this check should  go into the common helper in
diff --git a/security/capability.c b/security/capability.c
index 21b6cea..4e586a7 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -490,6 +490,11 @@ static int cap_msg_msg_alloc_security(struct msg_msg *msg)
 	return 0;
 }
 
+static int cap_msg_msg_restore_security(struct msg_msg *msg, void *stored)
+{
+	return 0;
+}
+
 static void cap_msg_msg_free_security(struct msg_msg *msg)
 {
 }
@@ -499,6 +504,12 @@ static int cap_msg_queue_alloc_security(struct msg_queue *msq)
 	return 0;
 }
 
+static int cap_msg_queue_restore_security(struct msg_queue *msq,
+					void *stored)
+{
+	return 0;
+}
+
 static void cap_msg_queue_free_security(struct msg_queue *msq)
 {
 }
@@ -530,6 +541,11 @@ static int cap_shm_alloc_security(struct shmid_kernel *shp)
 	return 0;
 }
 
+static int cap_shm_restore_security(struct shmid_kernel *shp, void *stored)
+{
+	return 0;
+}
+
 static void cap_shm_free_security(struct shmid_kernel *shp)
 {
 }
@@ -555,6 +571,11 @@ static int cap_sem_alloc_security(struct sem_array *sma)
 	return 0;
 }
 
+static int cap_sem_restore_security(struct sem_array *sma, void *stored)
+{
+	return 0;
+}
+
 static void cap_sem_free_security(struct sem_array *sma)
 {
 }
@@ -848,6 +869,23 @@ static void cap_audit_rule_free(void *lsmrule)
 }
 #endif /* CONFIG_AUDIT */
 
+/* checkpoint/restore hooks */
+static char *cap_context_to_str(void *security)
+{
+	return NULL;
+}
+
+static void *cap_context_from_str(char *str)
+{
+	return NULL;
+}
+
+static int cap_task_restore_context(struct cred *cred, void *stored,
+				      void *f_security)
+{
+	return 0;
+}
+
 struct security_operations default_security_ops = {
 	.name	= "default",
 };
@@ -976,19 +1014,23 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, ipc_permission);
 	set_to_cap_if_null(ops, ipc_getsecid);
 	set_to_cap_if_null(ops, msg_msg_alloc_security);
+	set_to_cap_if_null(ops, msg_msg_restore_security);
 	set_to_cap_if_null(ops, msg_msg_free_security);
 	set_to_cap_if_null(ops, msg_queue_alloc_security);
+	set_to_cap_if_null(ops, msg_queue_restore_security);
 	set_to_cap_if_null(ops, msg_queue_free_security);
 	set_to_cap_if_null(ops, msg_queue_associate);
 	set_to_cap_if_null(ops, msg_queue_msgctl);
 	set_to_cap_if_null(ops, msg_queue_msgsnd);
 	set_to_cap_if_null(ops, msg_queue_msgrcv);
 	set_to_cap_if_null(ops, shm_alloc_security);
+	set_to_cap_if_null(ops, shm_restore_security);
 	set_to_cap_if_null(ops, shm_free_security);
 	set_to_cap_if_null(ops, shm_associate);
 	set_to_cap_if_null(ops, shm_shmctl);
 	set_to_cap_if_null(ops, shm_shmat);
 	set_to_cap_if_null(ops, sem_alloc_security);
+	set_to_cap_if_null(ops, sem_restore_security);
 	set_to_cap_if_null(ops, sem_free_security);
 	set_to_cap_if_null(ops, sem_associate);
 	set_to_cap_if_null(ops, sem_semctl);
@@ -1054,4 +1096,9 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, audit_rule_match);
 	set_to_cap_if_null(ops, audit_rule_free);
 #endif
+
+/* checkpoint/restore hooks */
+	set_to_cap_if_null(ops, context_from_str);
+	set_to_cap_if_null(ops, context_to_str);
+	set_to_cap_if_null(ops, task_restore_context);
 }
diff --git a/security/security.c b/security/security.c
index 5284255..26e7989 100644
--- a/security/security.c
+++ b/security/security.c
@@ -827,6 +827,11 @@ int security_msg_msg_alloc(struct msg_msg *msg)
 	return security_ops->msg_msg_alloc_security(msg);
 }
 
+int security_msg_msg_restore(struct msg_msg *msg, void *stored)
+{
+	return security_ops->msg_msg_restore_security(msg, stored);
+}
+
 void security_msg_msg_free(struct msg_msg *msg)
 {
 	security_ops->msg_msg_free_security(msg);
@@ -837,6 +842,11 @@ int security_msg_queue_alloc(struct msg_queue *msq)
 	return security_ops->msg_queue_alloc_security(msq);
 }
 
+int security_msg_queue_restore(struct msg_queue *msq, void *stored)
+{
+	return security_ops->msg_queue_restore_security(msq, stored);
+}
+
 void security_msg_queue_free(struct msg_queue *msq)
 {
 	security_ops->msg_queue_free_security(msq);
@@ -869,6 +879,11 @@ int security_shm_alloc(struct shmid_kernel *shp)
 	return security_ops->shm_alloc_security(shp);
 }
 
+int security_shm_restore(struct shmid_kernel *shp, void *stored)
+{
+	return security_ops->shm_restore_security(shp, stored);
+}
+
 void security_shm_free(struct shmid_kernel *shp)
 {
 	security_ops->shm_free_security(shp);
@@ -894,6 +909,11 @@ int security_sem_alloc(struct sem_array *sma)
 	return security_ops->sem_alloc_security(sma);
 }
 
+int security_sem_restore(struct sem_array *sma, void *stored)
+{
+	return security_ops->sem_restore_security(sma, stored);
+}
+
 void security_sem_free(struct sem_array *sma)
 {
 	security_ops->sem_free_security(sma);
@@ -962,6 +982,25 @@ void security_release_secctx(char *secdata, u32 seclen)
 }
 EXPORT_SYMBOL(security_release_secctx);
 
+char *security_context_to_str(void *security)
+{
+	return security_ops->context_to_str(security);
+}
+EXPORT_SYMBOL(security_context_to_str);
+
+void *security_context_from_str(char *str)
+{
+	return security_ops->context_from_str(str);
+}
+EXPORT_SYMBOL(security_context_from_str);
+
+int security_task_restore_context(struct cred *cred, void *stored,
+			void *f_security)
+{
+	return security_ops->task_restore_context(cred, stored, f_security);
+}
+EXPORT_SYMBOL(security_task_restore_context);
+
 #ifdef CONFIG_SECURITY_NETWORK
 
 int security_unix_stream_connect(struct socket *sock, struct socket *other,
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 2fcad7c..ba24808 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4695,6 +4695,15 @@ static int selinux_msg_msg_alloc_security(struct msg_msg *msg)
 	return msg_msg_alloc_security(msg);
 }
 
+static int selinux_msg_msg_restore_security(struct msg_msg *msg, void *stored)
+{
+	/*
+	 * TODO - actually restore from 'stored' subject to authorization
+	 */
+	kfree(stored);
+	return msg_msg_alloc_security(msg);
+}
+
 static void selinux_msg_msg_free_security(struct msg_msg *msg)
 {
 	msg_msg_free_security(msg);
@@ -4726,6 +4735,38 @@ static int selinux_msg_queue_alloc_security(struct msg_queue *msq)
 	return 0;
 }
 
+static int selinux_msg_queue_restore_security(struct msg_queue *msq,
+					void *stored)
+{
+	struct ipc_security_struct *isec;
+	struct avc_audit_data ad;
+	u32 sid = current_sid();
+	int rc;
+
+	/*
+	 * TODO restore based on 'stored'.  Since I don't know how we
+	 * want to decide on that yet, I'm for now just treating it as
+	 * a brand new message queue
+	 */
+	kfree(stored);
+	rc = ipc_alloc_security(current, &msq->q_perm, SECCLASS_MSGQ);
+	if (rc)
+		return rc;
+
+	isec = msq->q_perm.security;
+
+	AVC_AUDIT_DATA_INIT(&ad, IPC);
+	ad.u.ipc_id = msq->q_perm.key;
+
+	rc = avc_has_perm(sid, isec->sid, SECCLASS_MSGQ,
+			  MSGQ__CREATE, &ad);
+	if (rc) {
+		ipc_free_security(&msq->q_perm);
+		return rc;
+	}
+	return 0;
+}
+
 static void selinux_msg_queue_free_security(struct msg_queue *msq)
 {
 	ipc_free_security(&msq->q_perm);
@@ -4867,6 +4908,38 @@ static int selinux_shm_alloc_security(struct shmid_kernel *shp)
 	return 0;
 }
 
+static int selinux_shm_restore_security(struct shmid_kernel *shp,
+					void *stored)
+{
+	struct ipc_security_struct *isec;
+	struct avc_audit_data ad;
+	u32 sid = current_sid();
+	int rc;
+
+	/*
+	 * TODO restore based on 'stored'.  Since I don't know how we
+	 * want to decide on that yet, I'm for now just treating it as
+	 * a brand new message queue
+	 */
+	kfree(stored);
+	rc = ipc_alloc_security(current, &shp->shm_perm, SECCLASS_SHM);
+	if (rc)
+		return rc;
+
+	isec = shp->shm_perm.security;
+
+	AVC_AUDIT_DATA_INIT(&ad, IPC);
+	ad.u.ipc_id = shp->shm_perm.key;
+
+	rc = avc_has_perm(sid, isec->sid, SECCLASS_SHM,
+			  SHM__CREATE, &ad);
+	if (rc) {
+		ipc_free_security(&shp->shm_perm);
+		return rc;
+	}
+	return 0;
+}
+
 static void selinux_shm_free_security(struct shmid_kernel *shp)
 {
 	ipc_free_security(&shp->shm_perm);
@@ -4959,6 +5032,37 @@ static int selinux_sem_alloc_security(struct sem_array *sma)
 	return 0;
 }
 
+static int selinux_sem_restore_security(struct sem_array *sma, void *stored)
+{
+	struct ipc_security_struct *isec;
+	struct avc_audit_data ad;
+	u32 sid = current_sid();
+	int rc;
+
+	/*
+	 * TODO restore based on 'stored'.  Since I don't know how we
+	 * want to decide on that yet, I'm for now just treating it as
+	 * a brand new message queue
+	 */
+	kfree(stored);
+	rc = ipc_alloc_security(current, &sma->sem_perm, SECCLASS_SEM);
+	if (rc)
+		return rc;
+
+	isec = sma->sem_perm.security;
+
+	AVC_AUDIT_DATA_INIT(&ad, IPC);
+	ad.u.ipc_id = sma->sem_perm.key;
+
+	rc = avc_has_perm(sid, isec->sid, SECCLASS_SEM,
+			  SEM__CREATE, &ad);
+	if (rc) {
+		ipc_free_security(&sma->sem_perm);
+		return rc;
+	}
+	return 0;
+}
+
 static void selinux_sem_free_security(struct sem_array *sma)
 {
 	ipc_free_security(&sma->sem_perm);
@@ -5315,6 +5419,90 @@ static int selinux_key_getsecurity(struct key *key, char **_buffer)
 
 #endif
 
+/* checkpoint/restore hooks */
+
+/*
+ * the c/r code will free the char* we return
+ */
+static char *selinux_context_to_str(void *security)
+{
+	struct task_security_struct *s = security;
+	int len = 0;
+	char *v = NULL;
+	int ret;
+
+	if (!s)
+		return ERR_PTR(-EINVAL);
+	ret = security_sid_to_context(s->sid, &v, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return v;
+}
+
+struct sidp {
+	u32 sid;
+};
+
+/*
+ * we just return error if the context is not valid.  We let the
+ * domain transition/type creation code construct a valid
+ * task_security (or whatever) struct with the sid.
+ */
+static void *selinux_context_from_str(char *str)
+{
+	int error;
+	u32 sid;
+	struct sidp *retv;
+
+	error = security_context_to_sid(str, strlen(str), &sid);
+	if (error)
+		return ERR_PTR(error);
+	retv = kmalloc(sizeof(*retv), GFP_KERNEL);
+	if (!retv)
+		return ERR_PTR(-ENOMEM);
+	retv->sid = sid;
+	return retv;
+}
+
+/*
+ * stored is actually still the char* representation of the context
+ * (bc that's what we return in selinux_context_from_str())
+ */
+static int selinux_task_restore_context(struct cred *cred, void *stored,
+					void *f_security)
+{
+	struct task_security_struct *s = cred->security;
+	struct file_security_struct *fsec = f_security;
+	struct sidp *sidp = stored;
+	u32 newsid;
+	int error;
+
+	if (!sidp)
+		return -EINVAL;
+
+	newsid = sidp->sid;
+	kfree(sidp);
+
+	if (s->sid == newsid)
+		return 0;
+
+	/* these are not the right checks.  Will we want a
+	 * process:PROCESS_RESTORE_TRANSITION permission?
+	 */
+	error = avc_has_perm(s->sid, newsid,
+			  SECCLASS_PROCESS, PROCESS__TRANSITION, NULL);
+	if (error)
+		return error;
+
+	error = avc_has_perm(newsid, fsec->sid,
+			  SECCLASS_FILE, FILE__ENTRYPOINT, NULL);
+	if (error)
+		return error;
+	
+	s->sid = s->osid = newsid;
+	return 0;
+}
+
 static struct security_operations selinux_ops = {
 	.name =				"selinux",
 
@@ -5414,9 +5602,11 @@ static struct security_operations selinux_ops = {
 	.ipc_getsecid =			selinux_ipc_getsecid,
 
 	.msg_msg_alloc_security =	selinux_msg_msg_alloc_security,
+	.msg_msg_restore_security =	selinux_msg_msg_restore_security,
 	.msg_msg_free_security =	selinux_msg_msg_free_security,
 
 	.msg_queue_alloc_security =	selinux_msg_queue_alloc_security,
+	.msg_queue_restore_security =	selinux_msg_queue_restore_security,
 	.msg_queue_free_security =	selinux_msg_queue_free_security,
 	.msg_queue_associate =		selinux_msg_queue_associate,
 	.msg_queue_msgctl =		selinux_msg_queue_msgctl,
@@ -5424,12 +5614,14 @@ static struct security_operations selinux_ops = {
 	.msg_queue_msgrcv =		selinux_msg_queue_msgrcv,
 
 	.shm_alloc_security =		selinux_shm_alloc_security,
+	.shm_restore_security =		selinux_shm_restore_security,
 	.shm_free_security =		selinux_shm_free_security,
 	.shm_associate =		selinux_shm_associate,
 	.shm_shmctl =			selinux_shm_shmctl,
 	.shm_shmat =			selinux_shm_shmat,
 
 	.sem_alloc_security =		selinux_sem_alloc_security,
+	.sem_restore_security =		selinux_sem_restore_security,
 	.sem_free_security =		selinux_sem_free_security,
 	.sem_associate =		selinux_sem_associate,
 	.sem_semctl =			selinux_sem_semctl,
@@ -5499,6 +5691,10 @@ static struct security_operations selinux_ops = {
 	.audit_rule_match =		selinux_audit_rule_match,
 	.audit_rule_free =		selinux_audit_rule_free,
 #endif
+
+	.context_to_str =		selinux_context_to_str,
+	.context_from_str =		selinux_context_from_str,
+	.task_restore_context =		selinux_task_restore_context,
 };
 
 static __init int selinux_init(void)
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 98b3195..dfc0f7a 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1608,6 +1608,32 @@ static int smack_msg_msg_alloc_security(struct msg_msg *msg)
 }
 
 /**
+ * smack_msg_msg_restore_security - Set the security blob for msg_msg
+ * @msg: the object
+ * @stored: the checkpointed label
+ *
+ * Returns 0
+ */
+static int smack_msg_msg_restore_security(struct msg_msg *msg,
+					void *stored)
+{
+	struct kern_ipc_perm *isp = &sma->sem_perm;
+	char *str = smk_import(stored, 0);
+
+	if (str == NULL)
+		return -EINVAL;
+
+	msg->security = current_security();
+	if (current_security() != str) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		msg->security = str;
+	}
+	return 0;
+	return 0;
+}
+
+/**
  * smack_msg_msg_free_security - Clear the security blob for msg_msg
  * @msg: the object
  *
@@ -1644,6 +1670,30 @@ static int smack_shm_alloc_security(struct shmid_kernel *shp)
 }
 
 /**
+ * smack_shm_restore_security - retore the security blob for shm
+ * @shp: the object
+ * @stored: the checkpointed label
+ *
+ * Returns 0
+ */
+static int smack_shm_restore_security(struct shmid_kernel *shp, void *stored)
+{
+	struct kern_ipc_perm *isp = &shp->shm_perm;
+	char *str = smk_import(stored, 0);
+
+	if (str == NULL)
+		return -EINVAL;
+
+	isp->security = current_security();
+	if (current_security() != str) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		isp->security = str;
+	}
+	return 0;
+}
+
+/**
  * smack_shm_free_security - Clear the security blob for shm
  * @shp: the object
  *
@@ -1753,6 +1803,31 @@ static int smack_sem_alloc_security(struct sem_array *sma)
 }
 
 /**
+ * smack_sem_restore_security - Set the security blob for sem
+ * @sma: the object
+ * @stored: the label stored in checkpoint image
+ *
+ * Returns 0
+ */
+static int smack_sem_restore_security(struct sem_array *sma,
+				void *stored)
+{
+	struct kern_ipc_perm *isp = &sma->sem_perm;
+	char *str = smk_import(stored, 0);
+
+	if (str == NULL)
+		return -EINVAL;
+
+	isp->security = current_security();
+	if (current_security() != str) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		isp->security = str;
+	}
+	return 0;
+}
+
+/**
  * smack_sem_free_security - Clear the security blob for sem
  * @sma: the object
  *
@@ -1857,6 +1932,31 @@ static int smack_msg_queue_alloc_security(struct msg_queue *msq)
 }
 
 /**
+ * smack_msg_restore_security - Set the security blob for msg
+ * @msq: the object
+ * @stored: the stored label
+ *
+ * Returns 0
+ */
+static int smack_msg_queue_restore_security(struct msg_queue *msq,
+					void *stored)
+{
+	struct kern_ipc_perm *kisp = &msq->q_perm;
+	char *str = smk_import(stored, 0);
+
+	if (str == NULL)
+		return -EINVAL;
+
+	kisp->security = current_security();
+	if (current_security() != str) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		kisp->security = str;
+	}
+	return 0;
+}
+
+/**
  * smack_msg_free_security - Clear the security blob for msg
  * @msq: the object
  *
@@ -2823,6 +2923,33 @@ static void smack_release_secctx(char *secdata, u32 seclen)
 {
 }
 
+/* checkpoint/restore hooks */
+static char *smack_context_to_str(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static void *smack_context_from_str(char *str)
+{
+	char *newsmack = smk_import(str, 0);
+
+	if (newsmack == NULL)
+		return ERR_PTR(-EINVAL);
+
+	return newsmack;
+}
+
+static int smack_task_restore_context(struct cred *cred, void *stored,
+					void *f_security)
+{
+	if (cred->security != stored) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		cred->security = stored;
+	}
+	return 0;
+}
+
 struct security_operations smack_ops = {
 	.name =				"smack",
 
@@ -2902,9 +3029,11 @@ struct security_operations smack_ops = {
 	.ipc_getsecid =			smack_ipc_getsecid,
 
 	.msg_msg_alloc_security = 	smack_msg_msg_alloc_security,
+	.msg_msg_restore_security = 	smack_msg_msg_restore_security,
 	.msg_msg_free_security = 	smack_msg_msg_free_security,
 
 	.msg_queue_alloc_security = 	smack_msg_queue_alloc_security,
+	.msg_queue_restore_security = 	smack_msg_queue_restore_security,
 	.msg_queue_free_security = 	smack_msg_queue_free_security,
 	.msg_queue_associate = 		smack_msg_queue_associate,
 	.msg_queue_msgctl = 		smack_msg_queue_msgctl,
@@ -2912,12 +3041,14 @@ struct security_operations smack_ops = {
 	.msg_queue_msgrcv = 		smack_msg_queue_msgrcv,
 
 	.shm_alloc_security = 		smack_shm_alloc_security,
+	.shm_restore_security = 	smack_shm_restore_security,
 	.shm_free_security = 		smack_shm_free_security,
 	.shm_associate = 		smack_shm_associate,
 	.shm_shmctl = 			smack_shm_shmctl,
 	.shm_shmat = 			smack_shm_shmat,
 
 	.sem_alloc_security = 		smack_sem_alloc_security,
+	.sem_restore_security = 	smack_sem_restore_security,
 	.sem_free_security = 		smack_sem_free_security,
 	.sem_associate = 		smack_sem_associate,
 	.sem_semctl = 			smack_sem_semctl,
@@ -2964,6 +3095,10 @@ struct security_operations smack_ops = {
 	.secid_to_secctx = 		smack_secid_to_secctx,
 	.secctx_to_secid = 		smack_secctx_to_secid,
 	.release_secctx = 		smack_release_secctx,
+
+	.context_to_str =		smack_context_to_str,
+	.context_from_str =		smack_context_from_str,
+	.task_restore_context =		smack_task_restore_context,
 };
 
 
-- 
1.6.1
