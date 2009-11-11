From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/4] cr: add generic LSM c/r support (v7)
Date: Wed, 11 Nov 2009 09:58:50 -0600
Message-ID: <1257955132-8398-4-git-send-email-serue@us.ibm.com>
References: <1257955132-8398-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257955132-8398-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Documentation/checkpoint/readme.txt begins:
"""
Application checkpoint/restart is the ability to save the state
of a running application so that it can later resume its execution
from the time at which it was checkpointed.
"""

This patch adds generic support for c/r of LSM credentials.  Support
for Smack and SELinux (and TOMOYO if appropriate) will be added later.
Capabilities is already supported through generic creds code.

This patch supports ipc_perm, msg_msg, cred (task) and file ->security
fields.  Inodes, superblocks, netif, and xfrm currently are restored
not through sys_restart() but through container creation, and so the
security fields should be done then as well.  Network should be added
when network c/r is added.

Briefly, all security fields must be exported by the LSM as a simple
null-terminated string.  They are checkpointed through the
security_checkpoint_obj() helper, because we must pass it an extra
sectype field.  Splitting SECURITY_OBJ_SEC into one type per object
type would not work because, in Smack, one void* security is used for
all object types.  But we must pass the sectype field because in
SELinux a different type of structure is stashed in each object type.

The RESTART_KEEP_LSM flag indicates that the LSM should
attempt to reuse checkpointed security labels.  It is always
invalid when the LSM at restart differs from that at checkpoint.
It is currently only usable for capabilities.

(For capabilities, restart without RESTART_KEEP_LSM is technically
not implemented.  There actually might be a use case for that,
but the safety of it is dubious so for now we always re-create
checkpointed capability sets whether RESTART_KEEP_LSM is
specified or not)

Changelog:
        sep 3: fix memory leak on LSM restore error path
        Sep 3: provide 2 hooks, may_restart and checkpoint_header, to facilitate
                an LSM tracking policy changes.
        sep 10: merge RESTART_KEEP_LSM patch with basic LSM c/r
                support patches.
        sep 10: rename security_xyz_get_ctx() to security_xyz_checkpoint(),
                in order to avoid confusing with the various other 'context'
                helpers in the security_ namespace, relating to secids and
                sysfs xattrs.
        sep 10: pass context file to security_cred_restore.  SELinux will
                want the file's security context to authorize it as an
                entrypoint for the new process context.
        oct 01: roll up some generic c/r debug hunks from selinux patch.
        oct 05: address set of Oren comments, including:
                1. fix memleak in restore_msg_contents_one
                2. use a separate container checkpoint image section
                3. define SECURITY_CTX_NONE
                4. allocate the right size to l in security_checkpoint_obj
                5. fix ckpt_hdr_lsm alignment
        oct 09: at checkpoint, key on the void*security in the objhash,
                and don't cache the ckpt_stored_lsm at all.  At restart,
                do_restore_security (now moved to security/security.c)
                creates and caches the ckpt_stored_lsm.
	oct 19: At checkpoint, we insert the void* security into the
		objhash.  The first time that we do so, we next write out
		the string representation of the context to the checkpoint
		image, along with the value of the objref for the void*
		security, and insert that into the objhash.  Then at
		restart, when we read a LSM context, we read the objref
		which the void* security had at checkpoint, and we then
		insert the string context with that objref as well.
	oct 19: Address a bunch of Oren comments: add ckpt_write_err()s,
		more commenting, use -ENOSYS not -EOPNOTSUPP.  The biggest
		change is always failing restart when RESTART_KEEP_LSM is
		used but one of the security_XYZ_restore() returns -ENOSYS.
	oct 20: SECURITY_CTX_NONE becomes 0 (from -1) and security_checkpoint_obj
		returns an objref or SECURITY_CTX_NONE on success.
	nov 11: update ckpt_write_err->ckpt_err.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

use ckpt_err, fold into 9357bfb5e

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c               |   31 ++++++-
 checkpoint/objhash.c             |  130 ++++++++++++++++++++++++++
 include/linux/checkpoint.h       |    4 +
 include/linux/checkpoint_hdr.h   |   19 ++++
 include/linux/checkpoint_types.h |    7 ++
 include/linux/security.h         |  168 +++++++++++++++++++++++++++++++++
 ipc/checkpoint.c                 |   24 +++---
 ipc/checkpoint_msg.c             |   18 +++-
 ipc/checkpoint_sem.c             |    4 +-
 ipc/checkpoint_shm.c             |    4 +-
 ipc/util.h                       |    6 +-
 kernel/cred.c                    |   28 +++++-
 security/capability.c            |   48 ++++++++++
 security/security.c              |  191 ++++++++++++++++++++++++++++++++++++++
 14 files changed, 656 insertions(+), 26 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 14ccfd6..b622588 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -148,6 +148,19 @@ static int scan_fds(struct files_struct *files, int **fdtable)
 	return n;
 }
 
+#ifdef CONFIG_SECURITY
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return security_checkpoint_obj(ctx, file->f_security,
+				       CKPT_SECURITY_FILE);
+}
+#else
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return SECURITY_CTX_NONE;
+}
+#endif
+
 int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 			   struct ckpt_hdr_file *h)
 {
@@ -162,8 +175,14 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (h->f_credref < 0)
 		return h->f_credref;
 
-	ckpt_debug("file %s credref %d", file->f_dentry->d_name.name,
-		h->f_credref);
+	h->f_secref = checkpoint_file_security(ctx, file);
+	if (h->f_secref < 0) {
+		ckpt_err(ctx, h->f_secref, "%(T)file->f_security");
+		return h->f_secref;
+	}
+
+	ckpt_debug("file %s credref %d secref %d\n",
+		file->f_dentry->d_name.name, h->f_credref, h->f_secref);
 
 	/* FIX: need also file->f_owner, etc */
 
@@ -512,6 +531,14 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	put_cred(file->f_cred);
 	file->f_cred = get_cred(cred);
 
+	ret = security_restore_obj(ctx, (void *) file, CKPT_SECURITY_FILE,
+				   h->f_secref);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "file secref %(O)%(P)\n", h->f_secref,
+			 file);
+		return ret;
+	}
+
 	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
 	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
 	if (ret < 0)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 9b1b2f4..c01b0be 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -16,6 +16,7 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/sched.h>
+#include <linux/kref.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
@@ -285,6 +286,36 @@ static int obj_tty_users(void *ptr)
 	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
 }
 
+void lsm_string_free(struct kref *kref)
+{
+	struct ckpt_lsm_string *s = container_of(kref, struct ckpt_lsm_string,
+					kref);
+	kfree(s->string);
+	kfree(s);
+}
+
+static int lsm_string_grab(void *ptr)
+{
+	struct ckpt_lsm_string *s = ptr;
+	kref_get(&s->kref);
+	return 0;
+}
+
+static void lsm_string_drop(void *ptr, int lastref)
+{
+	struct ckpt_lsm_string *s = ptr;
+	kref_put(&s->kref, lsm_string_free);
+}
+
+/* security context strings */
+static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr);
+static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx);
+static void *restore_lsm_string_wrap(struct ckpt_ctx *ctx)
+{
+	return (void *)restore_lsm_string(ctx);
+}
+
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -433,6 +464,33 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_tty,
 		.restore = restore_tty,
 	},
+	/*
+	 * LSM void *security on objhash - at checkpoint
+	 * We don't take a ref because we won't be doing
+	 * anything more with this void* - unless we happen
+	 * to run into it again through some other objects's
+	 * ->security (in which case that object has it pinned).
+	 */
+	{
+		.obj_name = "SECURITY PTR",
+		.obj_type = CKPT_OBJ_SECURITY_PTR,
+		.ref_drop = obj_no_drop,
+		.ref_grab = obj_no_grab,
+	},
+	/*
+	 * LSM security strings - at restart
+	 * This is a struct which we malloc during restart and
+	 * must be freed (by objhash cleanup) at the end of
+	 * restart
+	 */
+	{
+		.obj_name = "SECURITY STRING",
+		.obj_type = CKPT_OBJ_SECURITY,
+		.ref_grab = lsm_string_grab,
+		.ref_drop = lsm_string_drop,
+		.checkpoint = checkpoint_lsm_string,
+		.restore = restore_lsm_string_wrap,
+	},
 };
 
 
@@ -1009,3 +1067,75 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
 	return (obj->ops->obj_type == type ? obj->ptr : ERR_PTR(-ENOMSG));
 }
+
+/*
+ * checkpoint a security context string.  This is done by
+ * security/security.c:security_checkpoint_obj() when it checkpoints
+ * a void*security whose context string has not yet been written out.
+ * The objref for the void*security (which is not itself written out
+ * to the checkpoint image) is stored alongside the context string,
+ * as is the type of object which contained the void* security, i.e.
+ * struct file, struct cred, etc.
+ */
+static int checkpoint_lsm_string(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_lsm_string *l = ptr;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
+	if (!h)
+		return -ENOMEM;
+	h->sectype = l->sectype;
+	h->ptrref = l->ptrref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	if (ret < 0)
+		return ret;
+	return ckpt_write_string(ctx, l->string, strlen(l->string)+1);
+}
+
+/*
+ * callback invoked when a security context string is found in a
+ * checkpoint image at restart.  The context string is saved in the object
+ * hash.  The objref under which the void* security was inserted in the
+ * objhash at checkpoint is also found here, and we re-insert this context
+ * string a second time under that objref.  This is because objects which
+ * had this context will have the objref of the void*security, not of the
+ * context string.
+ */
+static struct ckpt_lsm_string *restore_lsm_string(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_lsm_string *l;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SECURITY);
+	if (IS_ERR(h)) {
+		ckpt_debug("ckpt_read_obj_type returned %ld\n", PTR_ERR(h));
+		return ERR_PTR(PTR_ERR(h));
+	}
+
+	l = kzalloc(sizeof(*l), GFP_KERNEL);
+	if (!l) {
+		l = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	l->string = ckpt_read_string(ctx, CKPT_LSM_STRING_MAX);
+	if (IS_ERR(l->string)) {
+		void *s = l->string;
+		ckpt_debug("ckpt_read_string returned %ld\n", PTR_ERR(s));
+		kfree(l);
+		l = s;
+		goto out;
+	}
+	kref_init(&l->kref);
+	l->sectype = h->sectype;
+	/* l is just a placeholder, don't grab a ref */
+	ckpt_obj_insert(ctx, l, h->ptrref, CKPT_OBJ_SECURITY);
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return l;
+}
+
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 25d9152..46c8461 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -55,6 +55,7 @@
 	 RESTART_KEEP_LSM | \
 	 RESTART_GHOST)
 #define CKPT_LSM_INFO_LEN 200
+#define CKPT_LSM_STRING_MAX 1024
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -95,6 +96,9 @@ extern char *ckpt_fill_fname(struct path *path, struct path *root,
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
 extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
 
+/* defined in objhash.c and also used in security/security.c */
+extern void lsm_string_free(struct kref *kref);
+
 /* socket functions */
 extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
 			      struct socket *socket,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2fa8691..67fa5b6 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -82,6 +82,8 @@ enum {
 #define CKPT_HDR_OBJREF CKPT_HDR_OBJREF
 	CKPT_HDR_LSM_INFO,
 #define CKPT_HDR_LSM_INFO CKPT_HDR_LSM_INFO
+	CKPT_HDR_SECURITY,
+#define CKPT_HDR_SECURITY CKPT_HDR_SECURITY
 
 	CKPT_HDR_TREE = 101,
 #define CKPT_HDR_TREE CKPT_HDR_TREE
@@ -236,6 +238,10 @@ enum obj_type {
 #define CKPT_OBJ_SOCK CKPT_OBJ_SOCK
 	CKPT_OBJ_TTY,
 #define CKPT_OBJ_TTY CKPT_OBJ_TTY
+	CKPT_OBJ_SECURITY_PTR,
+#define CKPT_OBJ_SECURITY_PTR CKPT_OBJ_SECURITY_PTR
+	CKPT_OBJ_SECURITY,
+#define CKPT_OBJ_SECURITY CKPT_OBJ_SECURITY
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -366,6 +372,7 @@ struct ckpt_hdr_cred {
 	__u32 gid, sgid, egid, fsgid;
 	__s32 user_ref;
 	__s32 groupinfo_ref;
+	__s32 sec_ref;
 	struct ckpt_capabilities cap_s;
 } __attribute__((aligned(8)));
 
@@ -378,6 +385,15 @@ struct ckpt_hdr_groupinfo {
 	__u32 groups[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_lsm {
+	struct ckpt_hdr h;
+	__s32 ptrref;
+	__u8 sectype;
+	/*
+	 * This is followed by a string of size len+1,
+	 * null-terminated
+	 */
+} __attribute__((aligned(8)));
 /*
  * todo - keyrings and LSM
  * These may be better done with userspace help though
@@ -511,6 +527,7 @@ struct ckpt_hdr_file {
 	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
+	__s32 f_secref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_file_generic {
@@ -791,6 +808,7 @@ struct ckpt_hdr_ipc_perms {
 	__u32 mode;
 	__u32 _padding;
 	__u64 seq;
+	__s32 sec_ref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_shm {
@@ -824,6 +842,7 @@ struct ckpt_hdr_ipc_msg_msg {
 	struct ckpt_hdr h;
 	__s32 m_type;
 	__u32 m_ts;
+	__s32 sec_ref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_sem {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index ba85baa..0cdc47a 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -95,6 +95,13 @@ struct ckpt_ctx {
 	struct mutex msg_mutex;
 };
 
+/* stored on hashtable */
+struct ckpt_lsm_string {
+	struct kref kref;
+	int sectype;			/* Containing object (file,cred,&c) */
+	int ptrref;			/* the objref for the void* security */
+	char *string;
+};
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/include/linux/security.h b/include/linux/security.h
index 99e4ebc..e68cc82 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -43,6 +43,9 @@
 #define SECURITY_CAP_NOAUDIT 0
 #define SECURITY_CAP_AUDIT 1
 
+/* checkpoint 'N/A' in a checkpoint image for a security context */
+#define SECURITY_CTX_NONE 0
+
 struct ctl_table;
 struct audit_krule;
 
@@ -581,6 +584,15 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	created.
  *	@file contains the file structure to secure.
  *	Return 0 if the hook is successful and permission is granted.
+ * @file_checkpoint:
+ *	Return a string representing the security context on a file.
+ *	@security contains the security field.
+ *	Returns a char* which the caller will free, or -error on error.
+ * @file_restore:
+ *	Set a security context on a file according to the checkpointed context.
+ *	@file contains the file.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Returns 0 on success, -error on failure.
  * @file_free_security:
  *	Deallocate and free any security structures stored in file->f_security.
  *	@file contains the file structure being modified.
@@ -660,6 +672,17 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	manual page for definitions of the @clone_flags.
  *	@clone_flags contains the flags indicating what should be shared.
  *	Return 0 if permission is granted.
+ * @cred_checkpoint:
+ *	Return a string representing the security context on the task cred.
+ *	@security contains the security field.
+ *	Returns a char* which the caller will free, or -error on error.
+ * @cred_restore:
+ *	Set a security context on a task cred according to the checkpointed
+ *	context.
+ *	@file contains the checkpoint file
+ *	@cred contains the cred.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Returns 0 on success, -error on failure.
  * @cred_free:
  *	@cred points to the credentials.
  *	Deallocate and clear the cred->security field in a set of credentials.
@@ -1108,6 +1131,19 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@ipcp contains the kernel IPC permission structure.
  *	@secid contains a pointer to the location where result will be saved.
  *	In case of failure, @secid will be set to zero.
+ * @ipc_checkpoint:
+ *	Return a string representing the security context on the IPC
+ *	permission structure.
+ *	@security contains the security field.
+ *	Returns a char* which the caller will free, or -error on error.
+ * @ipc_restore:
+ *	Set a security context on a IPC permission structure according to
+ *	the checkpointed context.
+ *	@ipcp contains the IPC permission structure, which will have
+ *	already been allocated and initialized when the IPC structure was
+ *	created.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Returns 0 on success, -error on failure.
  *
  * Security hooks for individual messages held in System V IPC message queues
  * @msg_msg_alloc_security:
@@ -1116,6 +1152,16 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	created.
  *	@msg contains the message structure to be modified.
  *	Return 0 if operation was successful and permission is granted.
+ * @msg_msg_checkpoint:
+ *	Return a string representing the security context on an msg_msg
+ *	struct.
+ *	@security contains the security field
+ *	Returns a char* which the caller will free, or -error on error.
+ * @msg_msg_restore:
+ *	Set msg_msg->security according to the checkpointed context.
+ *	@msg contains the message structure to be modified.
+ *	@ctx contains a string representation of the checkpointed context.
+ *	Return 0 on success, -error on failure.
  * @msg_msg_free_security:
  *	Deallocate the security structure for this message.
  *	@msg contains the message structure to be modified.
@@ -1492,6 +1538,8 @@ struct security_operations {
 
 	int (*file_permission) (struct file *file, int mask);
 	int (*file_alloc_security) (struct file *file);
+	char *(*file_checkpoint) (void *security);
+	int (*file_restore) (struct file *file, char *ctx);
 	void (*file_free_security) (struct file *file);
 	int (*file_ioctl) (struct file *file, unsigned int cmd,
 			   unsigned long arg);
@@ -1512,6 +1560,8 @@ struct security_operations {
 	int (*dentry_open) (struct file *file, const struct cred *cred);
 
 	int (*task_create) (unsigned long clone_flags);
+	char *(*cred_checkpoint) (void *security);
+	int (*cred_restore) (struct file *file, struct cred *cred, char *ctx);
 	void (*cred_free) (struct cred *cred);
 	int (*cred_prepare)(struct cred *new, const struct cred *old,
 			    gfp_t gfp);
@@ -1545,8 +1595,12 @@ struct security_operations {
 
 	int (*ipc_permission) (struct kern_ipc_perm *ipcp, short flag);
 	void (*ipc_getsecid) (struct kern_ipc_perm *ipcp, u32 *secid);
+	char *(*ipc_checkpoint) (void *security);
+	int (*ipc_restore) (struct kern_ipc_perm *ipcp, char *ctx);
 
 	int (*msg_msg_alloc_security) (struct msg_msg *msg);
+	char *(*msg_msg_checkpoint) (void *security);
+	int (*msg_msg_restore) (struct msg_msg *msg, char *ctx);
 	void (*msg_msg_free_security) (struct msg_msg *msg);
 
 	int (*msg_queue_alloc_security) (struct msg_queue *msq);
@@ -1755,6 +1809,8 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
 void security_inode_getsecid(const struct inode *inode, u32 *secid);
 int security_file_permission(struct file *file, int mask);
 int security_file_alloc(struct file *file);
+char *security_file_checkpoint(void *security);
+int security_file_restore(struct file *file, char *ctx);
 void security_file_free(struct file *file);
 int security_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 int security_file_mmap(struct file *file, unsigned long reqprot,
@@ -1770,6 +1826,8 @@ int security_file_send_sigiotask(struct task_struct *tsk,
 int security_file_receive(struct file *file);
 int security_dentry_open(struct file *file, const struct cred *cred);
 int security_task_create(unsigned long clone_flags);
+char *security_cred_checkpoint(void *security);
+int security_cred_restore(struct file *file, struct cred *cred, char *ctx);
 void security_cred_free(struct cred *cred);
 int security_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
 void security_commit_creds(struct cred *new, const struct cred *old);
@@ -1800,7 +1858,11 @@ int security_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 void security_task_to_inode(struct task_struct *p, struct inode *inode);
 int security_ipc_permission(struct kern_ipc_perm *ipcp, short flag);
 void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid);
+char *security_ipc_checkpoint(void *security);
+int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx);
 int security_msg_msg_alloc(struct msg_msg *msg);
+char *security_msg_msg_checkpoint(void *security);
+int security_msg_msg_restore(struct msg_msg *msg, char *ctx);
 void security_msg_msg_free(struct msg_msg *msg);
 int security_msg_queue_alloc(struct msg_queue *msq);
 void security_msg_queue_free(struct msg_queue *msq);
@@ -2248,6 +2310,19 @@ static inline int security_file_alloc(struct file *file)
 	return 0;
 }
 
+static inline char *security_file_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_file_restore(struct file *file, char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline void security_file_free(struct file *file)
 { }
 
@@ -2312,6 +2387,20 @@ static inline int security_task_create(unsigned long clone_flags)
 	return 0;
 }
 
+static inline char *security_cred_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline void security_cred_free(struct cred *cred)
 { }
 
@@ -2454,11 +2543,37 @@ static inline void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = 0;
 }
 
+static inline char *security_ipc_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline int security_msg_msg_alloc(struct msg_msg *msg)
 {
 	return 0;
 }
 
+static inline char *security_msg_msg_checkpoint(void *security)
+{
+	/* this shouldn't ever get called if SECURITY=n */
+	return ERR_PTR(-EINVAL);
+}
+
+static inline int security_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	/* we're asked to recreate security contexts for an LSM which had
+	 * contexts, but CONFIG_SECURITY=n now! */
+	return -EINVAL;
+}
+
 static inline void security_msg_msg_free(struct msg_msg *msg)
 { }
 
@@ -3055,5 +3170,58 @@ static inline void free_secdata(void *secdata)
 { }
 #endif /* CONFIG_SECURITY */
 
+#ifdef CONFIG_CHECKPOINT
+#define CKPT_SECURITY_MSG_MSG	1
+#define CKPT_SECURITY_IPC	2
+#define CKPT_SECURITY_FILE	3
+#define CKPT_SECURITY_CRED	4
+#define CKPT_SECURITY_MAX	4
+
+#ifdef CONFIG_SECURITY
+/*
+ * @security_checkpoint_obj:
+ *	Checkpoint a LSM security context.  The context is written out
+ *	as a string.  A positive integer objref uniquely representing the
+ *	security context in this checkpoint image will be returned.
+ *	If the security context has already been written out, then the
+ *	objref of that already written-out context will be used.
+ *	@ctx: the checkpoint context.
+ *	@security: the void*security being checkpointed.
+ *	@sectype: represents the type of object which contained the
+ *		void *security.
+ *	Return 0 or a valid objref on success, or -error on error.
+ */
+int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security, int sectype);
+/*
+ * @security_restore_obj:
+ *	Re-create a checkpointed LSM security context.  The LSM will decide
+ *	based upon the string representation which actual security context
+ *	to assign.
+ *	@ctx: the checkpoint context.
+ *	@obj: The object containing the security context to be restored (cast
+ *	to a void *).
+ *	@sectype: represents the type of object which contained the
+ *		void *security.
+ *	@secref: an integer objref for the string representation of the
+ *		security context to be restored.
+ *	Return 0 on success, or -error on error.
+ */
+int security_restore_obj(struct ckpt_ctx *ctx, void *obj,
+				int sectype, int secref);
+#else
+static inline int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
+				int sectype)
+{
+	return SECURITY_CTX_NONE;
+}
+static inline int security_restore_obj(struct ckpt_ctx *ctx, void *obj,
+				int sectype, int secref)
+{
+	return 0;
+}
+#endif /* CONFIG_SECURITY */
+
+#endif /* CONFIG_CHECKPOINT */
+
 #endif /* ! __LINUX_SECURITY_H */
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index ab9110a..4322dea 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -33,7 +33,8 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
  * Checkpoint
  */
 
-int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+			      struct ckpt_hdr_ipc_perms *h,
 			      struct kern_ipc_perm *perm)
 {
 	if (ipcperms(perm, S_IROTH))
@@ -47,7 +48,12 @@ int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	h->cgid = perm->cgid;
 	h->mode = perm->mode & S_IRWXUGO;
 	h->seq = perm->seq;
-
+	h->sec_ref = security_checkpoint_obj(ctx, perm->security,
+					     CKPT_SECURITY_IPC);
+	if (h->sec_ref < 0) {
+		ckpt_err(ctx, h->sec_ref, "%(T)ipc_perm->security\n");
+		return h->sec_ref;
+	}
 	return 0;
 }
 
@@ -178,7 +184,8 @@ static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
 	return 1;
 }
 
-int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int restore_load_ipc_perms(struct ckpt_ctx *ctx,
+			   struct ckpt_hdr_ipc_perms *h,
 			   struct kern_ipc_perm *perm)
 {
 	if (h->id < 0)
@@ -207,16 +214,9 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	perm->cgid = h->cgid;
 	perm->mode = h->mode;
 	perm->seq = h->seq;
-	/*
-	 * Todo: restore perm->security.
-	 * At the moment it gets set by security_x_alloc() called through
-	 * ipcget()->ipcget_public()->ops-.getnew (->nequeue for instance)
-	 * We will want to ask the LSM to consider resetting the
-	 * checkpointed ->security, based on current_security(),
-	 * the checkpointed ->security, and the checkpoint file context.
-	 */
 
-	return 0;
+	return security_restore_obj(ctx, (void *)perm, CKPT_SECURITY_IPC,
+				   h->sec_ref);
 }
 
 static int restore_ipc_any(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns,
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index b933c19..61b3d78 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -37,7 +37,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&msq->q_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -63,14 +63,21 @@ static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
 	struct ckpt_hdr_ipc_msg_msg *h;
 	struct msg_msgseg *seg;
 	int total, len;
-	int ret;
+	int secref, ret;
 
+	secref = security_checkpoint_obj(ctx, msg->security,
+				      CKPT_SECURITY_MSG_MSG);
+	if (secref < 0) {
+		ckpt_err(ctx, secref, "%(T)msg_msg->security");
+		return secref;
+	}
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
 	if (!h)
 		return -ENOMEM;
 
 	h->m_type = msg->m_type;
 	h->m_ts = msg->m_ts;
+	h->sec_ref = secref;
 
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
@@ -177,7 +184,7 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		return ret;
 
@@ -224,6 +231,11 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->next = NULL;
 	pseg = &msg->next;
 
+	ret = security_restore_obj(ctx, (void *) msg, CKPT_SECURITY_MSG_MSG,
+				   h->sec_ref);
+	if (ret < 0)
+		goto out;
+
 	ret = _ckpt_read_buffer(ctx, (msg + 1), len);
 	if (ret < 0)
 		goto out;
diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
index 76eb2b9..53a19ed 100644
--- a/ipc/checkpoint_sem.c
+++ b/ipc/checkpoint_sem.c
@@ -37,7 +37,7 @@ static int fill_ipc_sem_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&sem->sem_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &sem->sem_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -113,7 +113,7 @@ static int load_ipc_sem_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = restore_load_ipc_perms(&h->perms, &sem->sem_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &sem->sem_perm);
 	if (ret < 0)
 		return ret;
 
diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
index 826e430..01091d9 100644
--- a/ipc/checkpoint_shm.c
+++ b/ipc/checkpoint_shm.c
@@ -41,7 +41,7 @@ static int fill_ipc_shm_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&shp->shm_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &shp->shm_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -165,7 +165,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
 {
 	int ret;
 
-	ret = restore_load_ipc_perms(&h->perms, &shp->shm_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &shp->shm_perm);
 	if (ret < 0)
 		return ret;
 
diff --git a/ipc/util.h b/ipc/util.h
index ba080de..ce34de0 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -199,9 +199,11 @@ void freeary(struct ipc_namespace *ns, struct kern_ipc_perm *ipcp);
 
 
 #ifdef CONFIG_CHECKPOINT
-extern int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+extern int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+				     struct ckpt_hdr_ipc_perms *h,
 				     struct kern_ipc_perm *perm);
-extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+extern int restore_load_ipc_perms(struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_ipc_perms *h,
 				  struct kern_ipc_perm *perm);
 
 extern int ckpt_collect_ipc_shm(int id, void *p, void *data);
diff --git a/kernel/cred.c b/kernel/cred.c
index 62d28a4..d17d1c0 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -706,10 +706,22 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 }
 
 #ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_SECURITY
+int checkpoint_cred_security(struct ckpt_ctx *ctx, struct cred *cred)
+{
+	return security_checkpoint_obj(ctx, cred->security, CKPT_SECURITY_CRED);
+}
+#else
+int checkpoint_cred_security(struct ckpt_ctx *ctx, struct cred *cred)
+{
+	return SECURITY_CTX_NONE;
+}
+#endif
+
 static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 {
 	int ret;
-	int groupinfo_ref, user_ref;
+	int groupinfo_ref, user_ref, secref;
 	struct ckpt_hdr_cred *h;
 
 	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
@@ -719,13 +731,18 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
 	if (user_ref < 0)
 		return user_ref;
+	secref = checkpoint_cred_security(ctx, cred);
+	if (secref < 0) {
+		ckpt_err(ctx, secref, "%(T)cred->security");
+		return secref;
+	}
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
 	if (!h)
 		return -ENOMEM;
 
-	ckpt_debug("cred uid %d fsuid %d gid %d\n", cred->uid, cred->fsuid,
-			cred->gid);
+	ckpt_debug("cred uid %d fsuid %d gid %d secref %d\n", cred->uid,
+			cred->fsuid, cred->gid, secref);
 	h->uid = cred->uid;
 	h->suid = cred->suid;
 	h->euid = cred->euid;
@@ -735,6 +752,7 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	h->sgid = cred->sgid;
 	h->egid = cred->egid;
 	h->fsgid = cred->fsgid;
+	h->sec_ref = secref;
 
 	checkpoint_capabilities(&h->cap_s, cred);
 
@@ -808,6 +826,10 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
 	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
 	if (oldgid != h->fsgid && ret < 0)
 		goto err_putcred;
+	ret = security_restore_obj(ctx, (void *) cred, CKPT_SECURITY_CRED,
+				   h->sec_ref);
+	if (ret)
+		goto err_putcred;
 	ret = restore_capabilities(&h->cap_s, cred);
 	if (ret)
 		goto err_putcred;
diff --git a/security/capability.c b/security/capability.c
index 23026e2..de1e3a1 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -315,6 +315,16 @@ static int cap_file_permission(struct file *file, int mask)
 	return 0;
 }
 
+static inline char *cap_file_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_file_restore(struct file *file, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static int cap_file_alloc_security(struct file *file)
 {
 	return 0;
@@ -373,6 +383,16 @@ static int cap_task_create(unsigned long clone_flags)
 	return 0;
 }
 
+static char *cap_cred_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_cred_restore(struct file *file, struct cred *cred, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static void cap_cred_free(struct cred *cred)
 {
 }
@@ -476,11 +496,31 @@ static void cap_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = 0;
 }
 
+static char *cap_ipc_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static int cap_msg_msg_alloc_security(struct msg_msg *msg)
 {
 	return 0;
 }
 
+static inline char *cap_msg_msg_checkpoint(void *security)
+{
+	return ERR_PTR(-ENOSYS);
+}
+
+static int cap_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	return -ENOSYS;
+}
+
 static void cap_msg_msg_free_security(struct msg_msg *msg)
 {
 }
@@ -948,6 +988,8 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, path_truncate);
 #endif
 	set_to_cap_if_null(ops, file_permission);
+	set_to_cap_if_null(ops, file_checkpoint);
+	set_to_cap_if_null(ops, file_restore);
 	set_to_cap_if_null(ops, file_alloc_security);
 	set_to_cap_if_null(ops, file_free_security);
 	set_to_cap_if_null(ops, file_ioctl);
@@ -960,6 +1002,8 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, file_receive);
 	set_to_cap_if_null(ops, dentry_open);
 	set_to_cap_if_null(ops, task_create);
+	set_to_cap_if_null(ops, cred_checkpoint);
+	set_to_cap_if_null(ops, cred_restore);
 	set_to_cap_if_null(ops, cred_free);
 	set_to_cap_if_null(ops, cred_prepare);
 	set_to_cap_if_null(ops, cred_commit);
@@ -986,7 +1030,11 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, task_to_inode);
 	set_to_cap_if_null(ops, ipc_permission);
 	set_to_cap_if_null(ops, ipc_getsecid);
+	set_to_cap_if_null(ops, ipc_checkpoint);
+	set_to_cap_if_null(ops, ipc_restore);
 	set_to_cap_if_null(ops, msg_msg_alloc_security);
+	set_to_cap_if_null(ops, msg_msg_checkpoint);
+	set_to_cap_if_null(ops, msg_msg_restore);
 	set_to_cap_if_null(ops, msg_msg_free_security);
 	set_to_cap_if_null(ops, msg_queue_alloc_security);
 	set_to_cap_if_null(ops, msg_queue_free_security);
diff --git a/security/security.c b/security/security.c
index e4fa91a..024f06c 100644
--- a/security/security.c
+++ b/security/security.c
@@ -633,6 +633,16 @@ int security_file_alloc(struct file *file)
 	return security_ops->file_alloc_security(file);
 }
 
+char *security_file_checkpoint(void *security)
+{
+	return security_ops->file_checkpoint(security);
+}
+
+int security_file_restore(struct file *file, char *ctx)
+{
+	return security_ops->file_restore(file, ctx);
+}
+
 void security_file_free(struct file *file)
 {
 	security_ops->file_free_security(file);
@@ -692,6 +702,16 @@ int security_task_create(unsigned long clone_flags)
 	return security_ops->task_create(clone_flags);
 }
 
+char *security_cred_checkpoint(void *security)
+{
+	return security_ops->cred_checkpoint(security);
+}
+
+int security_cred_restore(struct file *file, struct cred *cred, char *ctx)
+{
+	return security_ops->cred_restore(file, cred, ctx);
+}
+
 void security_cred_free(struct cred *cred)
 {
 	security_ops->cred_free(cred);
@@ -827,11 +847,31 @@ void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	security_ops->ipc_getsecid(ipcp, secid);
 }
 
+char *security_ipc_checkpoint(void *security)
+{
+	return security_ops->ipc_checkpoint(security);
+}
+
+int security_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	return security_ops->ipc_restore(ipcp, ctx);
+}
+
 int security_msg_msg_alloc(struct msg_msg *msg)
 {
 	return security_ops->msg_msg_alloc_security(msg);
 }
 
+char *security_msg_msg_checkpoint(void *security)
+{
+	return security_ops->msg_msg_checkpoint(security);
+}
+
+int security_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	return security_ops->msg_msg_restore(msg, ctx);
+}
+
 void security_msg_msg_free(struct msg_msg *msg)
 {
 	security_ops->msg_msg_free_security(msg);
@@ -1270,3 +1310,154 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 }
 
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_CHECKPOINT
+
+/**
+ * security_checkpoint_obj - called during application checkpoint to
+ * record the security context of objects.
+ *
+ * First we add the void*security address to the objhash as a type
+ * CKPT_OBJ_SECURITY_PTR.  This records the fact that we've seen this
+ * context.  If we've seen the context before, then we simply place the
+ * recorded objref in *secref and return success.
+
+ * If this is the first time we've seen this context for this checkpoint
+ * image, then we
+ * 1. ask the LSM for a string representation of the context
+ * 2. create a struct ckpt_lsm_string pointing to the string and to the
+ *    objref which we got for the void*security in the objhash.
+ * 3. write that out to the checkpoint image as a CKPT_OBJ_SECURITY.  it
+ *    will be freed when the objhash is cleared.
+ *
+ * Returns 0 or a valid objref on success, or -error on error.
+ *
+ * This is only used at checkpoint of course.
+ */
+int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security, int sectype)
+{
+	int new, ret = -ENOMEM;
+	char *str;
+	struct ckpt_lsm_string *l;
+	int secref;
+
+	if (!security)
+		return SECURITY_CTX_NONE;
+
+	secref = ckpt_obj_lookup_add(ctx, security, CKPT_OBJ_SECURITY_PTR,
+				     &new);
+	if (!new)
+		return secref;
+
+	/*
+	 * Ask the LSM for a string representation
+	 */
+	switch (sectype) {
+	case CKPT_SECURITY_MSG_MSG:
+		str = security_msg_msg_checkpoint(security);
+		break;
+	case CKPT_SECURITY_IPC:
+		str = security_ipc_checkpoint(security);
+		break;
+	case CKPT_SECURITY_FILE:
+		str = security_file_checkpoint(security);
+		break;
+	case CKPT_SECURITY_CRED:
+		str = security_cred_checkpoint(security);
+		break;
+	default:
+		str = ERR_PTR(-EINVAL);
+		break;
+	}
+
+	if (IS_ERR(str)) {
+		if (PTR_ERR(str) == -ENOSYS)
+			return SECURITY_CTX_NONE;
+		return PTR_ERR(str);
+	}
+
+	l = kzalloc(sizeof(*l), GFP_KERNEL);
+	if (!l) {
+		kfree(str);
+		return -ENOMEM;
+	}
+	l->ptrref = secref;
+	l->sectype = sectype;
+	l->string = str;
+	kref_init(&l->kref);
+	ret = checkpoint_obj(ctx, l, CKPT_OBJ_SECURITY);
+	kref_put(&l->kref, lsm_string_free);
+	if (ret < 0)
+		return ret;
+
+	return secref;
+}
+
+/*
+ * Choose a security context for an object being restored during
+ * application restart.  @v is an object (file, cred, etc) containing
+ * a security context and being re-created.  It has been type-cast
+ * to a void*.  @sectype tells us what sort of object v is.  @secref
+ * is the objhash id representing the security context.
+ *
+ * If sys_restart() was called without the RESTART_KEEP_LSM flag,
+ * then default security contexts will be assigned to the re-created
+ * object (in fact, they already have by this point).  Otherwise, the
+ * LSM is expected to use the string context representation to assign
+ * the same security context to this object (if allowed).
+ *
+ * At checkpoint time, @secref was the objref for the void*security
+ * (which was not written to disk).  The
+ * checkpoint/objhash.c:restore_lsm_string() function should, before we
+ * get here, have read the context string in the checkpoint image, and
+ * inserted a second copy of the struct ckpt_lsm_string on the objhash,
+ * with this objref.
+ *
+ * Returns 0 on success, -error on error.
+ */
+int security_restore_obj(struct ckpt_ctx *ctx, void *v, int sectype,
+			 int secref)
+{
+	struct ckpt_lsm_string *l;
+	int ret;
+
+	/* return if caller didn't want to restore checkpointed labels */
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		return 0;
+
+	l = ckpt_obj_fetch(ctx, secref, CKPT_OBJ_SECURITY);
+	if (IS_ERR(l))
+		return PTR_ERR(l);
+
+	/* return if checkpointed label was "Not Applicable" */
+	if (secref == SECURITY_CTX_NONE)
+		return 0;
+
+	/* Ask the LSM to apply a void*security to the object
+	 * based on the checkpointed context string */
+	switch (sectype) {
+	case CKPT_SECURITY_IPC:
+		ret = security_ipc_restore((struct kern_ipc_perm *) v,
+					l->string);
+		break;
+	case CKPT_SECURITY_MSG_MSG:
+		ret = security_msg_msg_restore((struct msg_msg *) v,
+						l->string);
+		break;
+	case CKPT_SECURITY_FILE:
+		ret = security_file_restore((struct file *) v, l->string);
+		break;
+	case CKPT_SECURITY_CRED:
+		ret = security_cred_restore(ctx->file, (struct cred *) v,
+						l->string);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+	if (ret)
+		ckpt_err(ctx, ret, "%(O)sectype %d lsm restore hook error\n",
+			   secref, sectype);
+
+	return ret;
+}
+#endif
-- 
1.6.1
