From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 7/8] cr: checkpoint and restore task credentials
Date: Mon, 1 Jun 2009 17:22:31 -0500
Message-ID: <20090601222231.GG29460@us.ibm.com>
References: <20090601222119.GB29164@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090601222119.GB29164@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

This patch adds the checkpointing and restart of credentials
(uids, gids, and capabilities) to Oren's c/r patchset (on top
of v14).  It goes to great pains to re-use (and define when
needed) common helpers, in order to make sure that as security
code is modified, the cr code will be updated.  Some of the
helpers should still be moved (i.e. _creds() functions should
be in kernel/cred.c).

When building the credentials for the restarted process, I
1. create a new struct cred as a copy of the running task's
cred (using prepare_cred())
2. always authorize any changes to the new struct cred
based on the permissions of current_cred() (not the current
transient state of the new cred).

While this may mean that certain transient_cred1->transient_cred2
states are allowed which otherwise wouldn't be allowed, the
fact remains that current_cred() is allowed to transition to
transient_cred2.

The reconstructed creds are applied to the task at the very
end of the sys_restart call.  This ensures that any objects which
need to be re-created (file, socket, etc) are re-created using
the creds of the task calling sys_restart - preventing an unpriv
user from creating a privileged object, and ensuring that a
root task can restart a process which had started out privileged,
created some privileged objects, then dropped its privilege.

With these patches, the root user can restart checkpoint images
(created by either hallyn or root) of user hallyn's tasks,
resulting in a program owned by hallyn.

Changelog:
	Jun 01: Don't check ordering of groups in group_info, bc
		set_groups() will sort it for us.
	May 28: 1. Restore securebits
		2. Address Alexey's comments: move prototypes out of
		   sched.h, validate ngroups < NGROUPS_MAX, validate
		   groups are sorted, and get rid of ckpt_hdr_cred->version.
		3. remove bogus unused flag RESTORE_CREATE_USERNS
	May 26: Move group, user, userns, creds c/r functions out
		of checkpoint/process.c and into the appropriate files.
	May 26: Define struct ckpt_hdr_task_creds and move task cred
		objref c/r into {checkpoint_restore}_task_shared().
	May 26: Take cred refs around checkpoint_write_creds()
	May 20: Remove the limit on number of groups in groupinfo
		at checkpoint time
	May 20: Remove the depth limit on empty user namespaces
	May 20: Better document checkpoint_user
	May 18: fix more refcounting: if (userns 5, uid 0) had
		no active tasks or child user_namespaces, then
		it shouldn't exist at restart or it, its namespace,
		and its whole chain of creators will be leaked.
	May 14: fix some refcounting:
		1. a new user_ns needs a ref to remain pinned
		   by its root user
		2. current_user_ns needs an extra ref bc objhash
		   drops two on restart
		3. cred needs a ref for the real credentials bc
		   commit_creds eats one ref.
	May 13: folded in fix to userns refcounting.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/objhash.c             |  118 +++++++++++++++++++++++++++++
 checkpoint/process.c             |  152 +++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint.h       |   11 +++
 include/linux/checkpoint_hdr.h   |   60 +++++++++++++++
 include/linux/checkpoint_types.h |    2 +-
 include/linux/cred.h             |   13 +++
 include/linux/user_namespace.h   |    6 ++
 kernel/cred.c                    |  113 ++++++++++++++++++++++++++++
 kernel/groups.c                  |   59 +++++++++++++++
 kernel/user.c                    |  147 ++++++++++++++++++++++++++++++++++++
 kernel/user_namespace.c          |   86 +++++++++++++++++++++
 11 files changed, 764 insertions(+), 3 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 045a920..20866c5 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -17,6 +17,7 @@
 #include <linux/fdtable.h>
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -177,6 +178,71 @@ static int obj_ipc_ns_users(void *ptr)
 	return atomic_read(&((struct ipc_namespace *) ptr)->count);
 }
 
+static int obj_cred_grab(void *ptr)
+{
+	get_cred((struct cred *) ptr);
+	return 0;
+}
+
+static void obj_cred_drop(void *ptr)
+{
+	put_cred((struct cred *) ptr);
+}
+
+static int obj_cred_users(void *ptr)
+{
+	return atomic_read(&((struct cred *) ptr)->usage);
+}
+
+static int obj_user_grab(void *ptr)
+{
+	struct user_struct *u = ptr;
+	(void) get_uid(u);
+	return 0;
+}
+
+static void obj_user_drop(void *ptr)
+{
+	free_uid((struct user_struct *) ptr);
+}
+
+static int obj_user_users(void *ptr)
+{
+	return atomic_read(&((struct user_struct *) ptr)->__count);
+}
+
+static int obj_userns_grab(void *ptr)
+{
+	get_user_ns((struct user_namespace *) ptr);
+	return 0;
+}
+
+static void obj_userns_drop(void *ptr)
+{
+	put_user_ns((struct user_namespace *) ptr);
+}
+
+static int obj_user_ns_users(void *ptr)
+{
+	return atomic_read(&((struct user_namespace *) ptr)->kref.refcount);
+}
+
+static int obj_groupinfo_grab(void *ptr)
+{
+	get_group_info((struct group_info *) ptr);
+	return 0;
+}
+
+static void obj_groupinfo_drop(void *ptr)
+{
+	put_group_info((struct group_info *) ptr);
+}
+
+static int obj_groupinfo_users(void *ptr)
+{
+	return atomic_read(&((struct group_info *) ptr)->usage);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -254,6 +320,46 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_bad,
 		.restore = restore_bad,
 	},
+	/* user_ns object */
+	{
+		.obj_name = "USER_NS",
+		.obj_type = CKPT_OBJ_USER_NS,
+		.ref_drop = obj_userns_drop,
+		.ref_grab = obj_userns_grab,
+		.ref_users = obj_user_ns_users,
+		.checkpoint = checkpoint_userns,
+		.restore = restore_userns,
+	},
+	/* struct cred */
+	{
+		.obj_name = "CRED",
+		.obj_type = CKPT_OBJ_CRED,
+		.ref_drop = obj_cred_drop,
+		.ref_grab = obj_cred_grab,
+		.ref_users = obj_cred_users,
+		.checkpoint = checkpoint_cred,
+		.restore = restore_cred,
+	},
+	/* user object */
+	{
+		.obj_name = "USER",
+		.obj_type = CKPT_OBJ_USER,
+		.ref_drop = obj_user_drop,
+		.ref_grab = obj_user_grab,
+		.ref_users = obj_user_users,
+		.checkpoint = checkpoint_user,
+		.restore = restore_user,
+	},
+	/* struct groupinfo */
+	{
+		.obj_name = "GROUPINFO",
+		.obj_type = CKPT_OBJ_GROUPINFO,
+		.ref_drop = obj_groupinfo_drop,
+		.ref_grab = obj_groupinfo_grab,
+		.ref_users = obj_groupinfo_users,
+		.checkpoint = checkpoint_groupinfo,
+		.restore = restore_groupinfo,
+	},
 };
 
 
@@ -323,6 +429,18 @@ static struct ckpt_obj *obj_find_by_ptr(struct ckpt_ctx *ctx, void *ptr)
 	return NULL;
 }
 
+/*
+ * look up an obj and return objref if in hash, else
+ * return 0.  Used during checkpoint.
+ */
+int obj_lookup(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_obj *obj = obj_find_by_ptr(ctx, ptr);
+	if (obj)
+		return obj->objref;
+	return 0;
+}
+
 static struct ckpt_obj *obj_find_by_objref(struct ckpt_ctx *ctx, int objref)
 {
 	struct hlist_head *h;
diff --git a/checkpoint/process.c b/checkpoint/process.c
index b604a85..5c59cc0 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -17,6 +17,7 @@
 #include <linux/futex.h>
 #include <linux/poll.h>
 #include <linux/utsname.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/syscalls.h>
@@ -25,6 +26,26 @@
  * Checkpoint
  */
 
+int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_groupinfo(ctx, (struct group_info *)ptr);
+}
+
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_userns(ctx, (struct user_namespace *) ptr);
+}
+
+int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_user(ctx, (struct user_struct *)ptr);
+}
+
+int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr)
+{
+	return checkpoint_write_cred(ctx, (struct cred *) ptr);
+}
+
 /* dump the task_struct of a given task */
 static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -161,6 +182,46 @@ static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int checkpoint_task_creds(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int realcred_ref, ecred_ref;
+	struct cred *rcred, *ecred;
+	struct ckpt_hdr_task_creds *h;
+	int ret;
+
+	rcred = get_cred(t->real_cred);
+	ecred = get_cred(t->cred);
+
+	realcred_ref = checkpoint_obj(ctx, rcred, CKPT_OBJ_CRED);
+	if (realcred_ref < 0) {
+		ret = realcred_ref;
+		goto error;
+	}
+
+	ecred_ref = checkpoint_obj(ctx, ecred, CKPT_OBJ_CRED);
+	if (ecred_ref < 0) {
+		ret = ecred_ref;
+		goto error;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
+	if (!h) {
+		ret = -ENOMEM;
+		goto error;
+	}
+
+	h->cred_ref = realcred_ref;
+	h->ecred_ref = ecred_ref;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+error:
+	put_cred(rcred);
+	put_cred(ecred);
+	return ret;
+
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -176,7 +237,9 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * restored when it gets to restore, e.g. its memory.
 	 */
 
-	ret = checkpoint_task_ns(ctx, t);
+	ret = checkpoint_task_creds(ctx, t);
+	if (!ret)
+		ret = checkpoint_task_ns(ctx, t);
 	if (ret < 0)
 		return ret;
 
@@ -348,6 +411,26 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
  * Restart
  */
 
+void *restore_groupinfo(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_groupinfo(ctx);
+}
+
+void *restore_userns(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_userns(ctx);
+}
+
+void *restore_user(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_user(ctx);
+}
+
+void *restore_cred(struct ckpt_ctx *ctx)
+{
+	return (void *) restore_read_cred(ctx);
+}
+
 /* read the task_struct into the current task */
 static int restore_task_struct(struct ckpt_ctx *ctx)
 {
@@ -365,8 +448,12 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 
 	memset(t->comm, 0, TASK_COMM_LEN);
 	ret = _ckpt_read_string(ctx, t->comm, h->task_comm_len);
+	if (ret < 0)
+		goto out;
 
 	/* FIXME: restore remaining relevant task_struct fields */
+
+	ret = 0;
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -514,6 +601,34 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_task_creds(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_creds *h;
+	struct cred *realcred, *ecred;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_CREDS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(realcred)) {
+		ret = PTR_ERR(realcred);
+		goto out;
+	}
+	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(ecred)) {
+		ret = PTR_ERR(ecred);
+		goto out;
+	}
+	ctx->realcred = realcred;
+	ctx->ecred = ecred;
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 static int restore_task_objs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -524,7 +639,9 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 * and because shared objects are restored before they are
 	 * referenced. See comment in checkpoint_task_objs.
 	 */
-	ret = restore_task_ns(ctx);
+	ret = restore_task_creds(ctx);
+	if (!ret)
+		ret = restore_task_ns(ctx);
 	if (ret < 0)
 		return ret;
 
@@ -542,6 +659,33 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+static int restore_creds(struct ckpt_ctx *ctx)
+{
+	int ret;
+	const struct cred *old;
+	struct cred *rcred, *ecred;
+
+	rcred = ctx->realcred;
+	ecred = ctx->ecred;
+
+	/* commit_creds will take one ref for the eff creds, but
+	 * expects us to hold a ref for the obj creds, so take a
+	 * ref here */
+	get_cred(rcred);
+	ret = commit_creds(rcred);
+	if (ret)
+		return ret;
+
+	if (ecred == rcred)
+		return 0;
+
+	old =  override_creds(ecred); /* override_creds otoh takes new ref */
+	put_cred(old);
+
+	ctx->realcred = ctx->ecred = NULL;
+	return 0;
+}
+
 int restore_restart_block(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_restart_block *h;
@@ -670,6 +814,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_cpu(ctx);
 	ckpt_debug("cpu %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_creds(ctx);
+	ckpt_debug("creds: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index ec117f0..812a444 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -53,6 +53,7 @@ extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 			       enum obj_type type, int *first);
+extern int obj_lookup(struct ckpt_ctx *ctx, void *ptr);
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
 			   enum obj_type type);
 
@@ -117,6 +118,16 @@ extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 			       struct ckpt_hdr_file *h);
 
+/* credentials */
+int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_user(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr);
+void *restore_groupinfo(struct ckpt_ctx *ctx);
+void *restore_userns(struct ckpt_ctx *ctx);
+void *restore_user(struct ckpt_ctx *ctx);
+void *restore_cred(struct ckpt_ctx *ctx);
+
 /* memory */
 extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b67db6b..da9e44b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -57,6 +57,11 @@ enum {
 	CKPT_HDR_UTS_NS,
 	CKPT_HDR_IPC_NS,
 	CKPT_HDR_CAPABILITIES,
+	CKPT_HDR_USER_NS,
+	CKPT_HDR_CRED,
+	CKPT_HDR_USER,
+	CKPT_HDR_GROUPINFO,
+	CKPT_HDR_TASK_CREDS,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -105,6 +110,10 @@ enum obj_type {
 	CKPT_OBJ_NS,
 	CKPT_OBJ_UTS_NS,
 	CKPT_OBJ_IPC_NS,
+	CKPT_OBJ_USER_NS,
+	CKPT_OBJ_CRED,
+	CKPT_OBJ_USER,
+	CKPT_OBJ_GROUPINFO,
 	CKPT_OBJ_MAX
 };
 
@@ -164,6 +173,11 @@ struct ckpt_hdr_task {
 	__u32 exit_code;
 	__u32 exit_signal;
 
+#ifdef CONFIG_AUDITSYSCALL
+	/* would audit want to track the checkpointed ids,
+	   or (more likely) who actually restarted? */
+#endif
+
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
@@ -175,6 +189,52 @@ struct ckpt_capabilities {
 	__u32 padding;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_task_creds {
+	struct ckpt_hdr h;
+	__s32 cred_ref;
+	__s32 ecred_ref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_cred {
+	struct ckpt_hdr h;
+	__u32 uid, suid, euid, fsuid;
+	__u32 gid, sgid, egid, fsgid;
+	__s32 user_ref;
+	__s32 groupinfo_ref;
+	struct ckpt_capabilities cap_s;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_groupinfo {
+	struct ckpt_hdr h;
+	__u32 ngroups;
+	/*
+	 * This is followed by ngroups __u32s
+	 */
+	__u32 groups[0];
+} __attribute__((aligned(8)));
+
+/*
+ * todo - keyrings and LSM
+ * These may be better done with userspace help though
+ */
+struct ckpt_hdr_user_struct {
+	struct ckpt_hdr h;
+	__u32 uid;
+	__s32 userns_ref;
+} __attribute__((aligned(8)));
+
+/*
+ * The user-struct mostly tracks system resource usage.
+ * Most of it's contents therefore will simply be set
+ * correctly as restart opens resources
+ */
+#define CKPT_USERNS_INIT 1
+struct ckpt_hdr_user_ns {
+	struct ckpt_hdr h;
+	__u32 flags;
+	__s32 creator_ref;
+} __attribute__((aligned(8)));
+
 /* namespaces */
 struct ckpt_hdr_task_ns {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 45a0f80..ffa94b3 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -15,7 +15,6 @@
 
 #define CHECKPOINT_SUBTREE	0x1
 
-
 #ifdef __KERNEL__
 struct ckpt_ctx;
 struct ckpt_hdr_file;
@@ -70,6 +69,7 @@ struct ckpt_ctx {
 	atomic_t tasks_count;		/* sync of tasks: used to coordinate */
 	struct completion complete;	/* container root and other tasks on */
 	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 };
 
 /* ckpt_ctx: kflags */
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 2ffffbe..e3269d5 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -77,6 +77,14 @@ extern int groups_search(const struct group_info *, gid_t);
 extern int in_group_p(gid_t);
 extern int in_egroup_p(gid_t);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+int checkpoint_write_groupinfo(struct ckpt_ctx *, struct group_info *);
+struct group_info *restore_read_groupinfo(struct ckpt_ctx *);
+int checkpoint_write_user(struct ckpt_ctx *, struct user_struct *);
+struct user_struct *restore_read_user(struct ckpt_ctx *);
+#endif
+
 /*
  * The common credentials for a thread group
  * - shared by CLONE_THREAD
@@ -352,4 +360,9 @@ int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid, gid_t sgid);
 int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid);
 int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid);
 
+#ifdef CONFIG_CHECKPOINT
+int checkpoint_write_cred(struct ckpt_ctx *, const struct cred *);
+struct cred *restore_read_cred(struct ckpt_ctx *);
+#endif
+
 #endif /* _LINUX_CRED_H */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index a2b82d5..3eeee40 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -62,4 +62,10 @@ static inline void put_user_ns(struct user_namespace *ns)
 
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+int checkpoint_write_userns(struct ckpt_ctx *, struct user_namespace *);
+struct user_namespace *restore_read_userns(struct ckpt_ctx *);
+#endif
+
 #endif /* _LINUX_USER_H */
diff --git a/kernel/cred.c b/kernel/cred.c
index a017399..6ef75a1 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -16,6 +16,7 @@
 #include <linux/init_task.h>
 #include <linux/security.h>
 #include <linux/cn_proc.h>
+#include <linux/checkpoint.h>
 #include "cred-internals.h"
 
 static struct kmem_cache *cred_jar;
@@ -703,3 +704,115 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 	}
 	return -EPERM;
 }
+
+#ifdef CONFIG_CHECKPOINT
+int checkpoint_write_cred(struct ckpt_ctx *ctx, const struct cred *cred)
+{
+	int ret;
+	int groupinfo_ref, user_ref;
+	struct ckpt_hdr_cred *h;
+
+	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
+					CKPT_OBJ_GROUPINFO);
+	if (groupinfo_ref < 0)
+		return groupinfo_ref;
+	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
+	if (user_ref < 0)
+		return user_ref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
+	if (!h)
+		return -ENOMEM;
+
+	h->uid = cred->uid;
+	h->suid = cred->suid;
+	h->euid = cred->euid;
+	h->fsuid = cred->fsuid;
+
+	h->gid = cred->gid;
+	h->sgid = cred->sgid;
+	h->egid = cred->egid;
+	h->fsgid = cred->fsgid;
+
+	checkpoint_capabilities(&h->cap_s, cred);
+
+	h->user_ref = user_ref;
+	h->groupinfo_ref = groupinfo_ref;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+struct cred *restore_read_cred(struct ckpt_ctx *ctx)
+{
+	struct cred *cred;
+	struct ckpt_hdr_cred *h;
+	struct user_struct *user;
+	struct group_info *groupinfo;
+	int ret = -EINVAL;
+	uid_t olduid;
+	gid_t oldgid;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CRED);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	cred = prepare_creds();
+	if (!cred)
+		goto error;
+
+
+	/* Do we care if the target user and target group were compatible?
+	 * Probably.  But then, we can't do any setuid without CAP_SETUID,
+	 * so we must have been privileged to abuse it... */
+	groupinfo = ckpt_obj_fetch(ctx, h->groupinfo_ref, CKPT_OBJ_GROUPINFO);
+	if (IS_ERR(groupinfo))
+		goto err_putcred;
+	user = ckpt_obj_fetch(ctx, h->user_ref, CKPT_OBJ_USER);
+	if (IS_ERR(user))
+		goto err_putcred;
+
+	/*
+	 * TODO: this check should  go into the common helper in
+	 * kernel/sys.c, and should account for user namespaces
+	 */
+	if (!capable(CAP_SETGID))
+		for (i = 0; i < groupinfo->ngroups; i++) {
+			if (!in_egroup_p(GROUP_AT(groupinfo, i)))
+				goto err_putcred;
+		}
+	ret = set_groups(cred, groupinfo);
+	if (ret < 0)
+		goto err_putcred;
+	free_uid(cred->user);
+	cred->user = get_uid(user);
+	ret = cred_setresuid(cred, h->uid, h->euid, h->suid);
+	if (ret < 0)
+		goto err_putcred;
+	ret = cred_setfsuid(cred, h->fsuid, &olduid);
+	if (olduid != h->fsuid && ret < 0)
+		goto err_putcred;
+	ret = cred_setresgid(cred, h->gid, h->egid, h->sgid);
+	if (ret < 0)
+		goto err_putcred;
+	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
+	if (oldgid != h->fsgid && ret < 0)
+		goto err_putcred;
+	ret = restore_capabilities(&h->cap_s, cred);
+	if (ret)
+		goto err_putcred;
+
+	ckpt_hdr_put(ctx, h);
+	return cred;
+
+err_putcred:
+	abort_creds(cred);
+error:
+	ckpt_hdr_put(ctx, h);
+	return ERR_PTR(ret);
+}
+
+#endif
diff --git a/kernel/groups.c b/kernel/groups.c
index 2b45b2e..74db0ae 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -6,6 +6,7 @@
 #include <linux/slab.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/checkpoint.h>
 #include <asm/uaccess.h>
 
 /* init to 2 - one for init_task, one to ensure it is never freed */
@@ -286,3 +287,61 @@ int in_egroup_p(gid_t grp)
 }
 
 EXPORT_SYMBOL(in_egroup_p);
+
+#ifdef CONFIG_CHECKPOINT
+int checkpoint_write_groupinfo(struct ckpt_ctx *ctx, struct group_info *g)
+{
+	int ret, i, size;
+	struct ckpt_hdr_groupinfo *h;
+
+	size = sizeof(*h) + g->ngroups * sizeof(__u32);
+	h = ckpt_hdr_get_type(ctx, size, CKPT_HDR_GROUPINFO);
+	if (!h)
+		return -ENOMEM;
+
+	h->ngroups = g->ngroups;
+	for (i = 0; i < g->ngroups; i++)
+		h->groups[i] = GROUP_AT(g, i);
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/*
+ * TODO - switch to reading in smaller blocks?
+ */
+#define MAX_GROUPINFO_SIZE (sizeof(*h)+NGROUPS_MAX*sizeof(gid_t))
+struct group_info *restore_read_groupinfo(struct ckpt_ctx *ctx)
+{
+	struct group_info *g;
+	struct ckpt_hdr_groupinfo *h;
+	int i;
+
+	h = ckpt_read_buf_type(ctx, MAX_GROUPINFO_SIZE, CKPT_HDR_GROUPINFO);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	g = ERR_PTR(-EINVAL);
+	if (h->ngroups > NGROUPS_MAX)
+		goto out;
+
+	for (i = 1; i < h->ngroups; i++)
+		if (h->groups[i-1] >= h->groups[i])
+			goto out;
+
+	g = groups_alloc(h->ngroups);
+	if (!g) {
+		g = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	for (i = 0; i < h->ngroups; i++)
+		GROUP_AT(g, i) = h->groups[i];
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return g;
+}
+
+#endif
diff --git a/kernel/user.c b/kernel/user.c
index 850e0ba..97f13e2 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
 #include "cred-internals.h"
 
 struct user_namespace init_user_ns = {
@@ -497,3 +498,149 @@ static int __init uid_cache_init(void)
 }
 
 module_init(uid_cache_init);
+
+#ifdef CONFIG_CHECKPOINT
+/*
+ * write the user struct
+ * TODO keyring will need to be dumped
+ *
+ * Here is what we're doing.  Remember a task can do clone(CLONE_NEWUSER)
+ * resulting in a cloned task in a new user namespace, with uid 0 in that
+ * new user_ns.  In that case, the parent's user (uid+user_ns) is the
+ * 'creator' of the new user_ns.
+ * Here, we call the user_ns of the ctx->root_task the 'root_ns'.  When we
+ * checkpoint a user-struct, we must store the chain of creators.  We
+ * must not do so recursively, this being the kernel.  In
+ * checkpoint_write_user() we walk and record in memory the list of creators up
+ * to either the latest user_struct which has already been saved, or the
+ * root_ns.  Then we walk that chain backward, writing out the user_ns and
+ * user_struct to the checkpoint image.
+ */
+#define UNSAVED_STRIDE 50
+int checkpoint_write_user(struct ckpt_ctx *ctx, struct user_struct *u)
+{
+	struct user_namespace *ns, *root_ns;
+	struct ckpt_hdr_user_struct *h;
+	int ns_objref;
+	int ret, i, unsaved_ns_nr = 0;
+	struct user_struct *save_u;
+	struct user_struct **unsaved_creators;
+	int step = 1, size;
+
+	/* if we've already saved the userns, then life is good */
+	ns_objref = obj_lookup(ctx, u->user_ns);
+	if (ns_objref)
+		goto write_user;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+
+	if (u->user_ns == root_ns)
+		goto save_last_ns;
+
+	size = UNSAVED_STRIDE*sizeof(struct user_struct *);
+	unsaved_creators = kmalloc(size, GFP_KERNEL);
+	if (!unsaved_creators)
+		return -ENOMEM;
+	save_u = u;
+	do {
+		ns = save_u->user_ns;
+		save_u = ns->creator;
+		if (obj_lookup(ctx, save_u))
+			goto found;
+		unsaved_creators[unsaved_ns_nr++] = save_u;
+		if (unsaved_ns_nr == step * UNSAVED_STRIDE) {
+			step++;
+			size = step*UNSAVED_STRIDE*sizeof(struct user_struct *);
+			unsaved_creators = krealloc(unsaved_creators, size,
+							GFP_KERNEL);
+			if (!unsaved_creators)
+				return -ENOMEM;
+		}
+	} while (ns != root_ns);
+
+found:
+	for (i = unsaved_ns_nr-1; i >= 0; i--) {
+		ret = checkpoint_obj(ctx, unsaved_creators[i], CKPT_OBJ_USER);
+		if (ret < 0) {
+			kfree(unsaved_creators);
+			return ret;
+		}
+	}
+	kfree(unsaved_creators);
+
+save_last_ns:
+	ns_objref = checkpoint_obj(ctx, u->user_ns, CKPT_OBJ_USER_NS);
+	if (ns_objref < 0)
+		return ns_objref;
+
+write_user:
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER);
+	if (!h)
+		return -ENOMEM;
+
+	h->uid = u->uid;
+	h->userns_ref = ns_objref;
+
+	/* write out the user_struct */
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int may_setuid(struct user_namespace *ns, uid_t uid)
+{
+	/*
+	 * this next check will one day become
+	 * if capable(CAP_SETUID, ns) return 1;
+	 * followed by uid_equiv(current_userns, current_uid, ns, uid)
+	 * instead of just uids.
+	 */
+	if (capable(CAP_SETUID))
+		return 1;
+
+	/*
+	 * this may be overly strict, but since we might end up
+	 * restarting a privileged program here, we do not want
+	 * someone with only CAP_SYS_ADMIN but no CAP_SETUID to
+	 * be able to create random userids even in a userns he
+	 * created.
+	 */
+	if (current_user()->user_ns != ns)
+		return 0;
+	if (current_uid() == uid ||
+		current_euid() == uid ||
+		current_suid() == uid)
+		return 1;
+	return 0;
+}
+
+struct user_struct *restore_read_user(struct ckpt_ctx *ctx)
+{
+	struct user_struct *u;
+	struct user_namespace *ns;
+	struct ckpt_hdr_user_struct *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	ns = ckpt_obj_fetch(ctx, h->userns_ref, CKPT_OBJ_USER_NS);
+	if (IS_ERR(ns)) {
+		u = ERR_PTR(PTR_ERR(ns));
+		goto out;
+	}
+
+	if (!may_setuid(ns, h->uid)) {
+		u = ERR_PTR(-EPERM);
+		goto out;
+	}
+	u = alloc_uid(ns, h->uid);
+	if (!u)
+		u = ERR_PTR(-EINVAL);
+
+out:
+	ckpt_hdr_put(ctx, h);
+	return u;
+}
+#endif
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index e624b0f..857cb3d 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
 #include <linux/cred.h>
 
 static struct user_namespace *_new_user_ns(struct user_struct *creator,
@@ -103,3 +104,88 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+#ifdef CONFIG_CHECKPOINT
+/*
+ * checkpoint_write_userns() is only called from
+ * checkpoint_write_user().  When called, we always know that
+ * either:
+ *   1. This is the root_ns (user_ns of the ctx->root_task),
+ *	in which case we don't store a creator, but rather
+ *	set the CKPT_USERNS_INIT flag.
+ * or
+ *   2. The creator has already been written out to the
+ *	checkpoint image (and saved in the objhash)
+ */
+int checkpoint_write_userns(struct ckpt_ctx *ctx,
+				   struct user_namespace *ns)
+{
+	struct ckpt_hdr_user_ns *h;
+	int creator_ref = 0;
+	unsigned int flags = 0;
+	struct user_namespace *root_ns;
+	int ret;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+	if (ns == root_ns)
+		flags = CKPT_USERNS_INIT;
+	else
+		creator_ref = obj_lookup(ctx, ns->creator);
+	if (!flags && !creator_ref)
+		return -EINVAL;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (!h)
+		return -ENOMEM;
+	h->creator_ref = creator_ref;
+	h->flags = flags;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+struct user_namespace *restore_read_userns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *ns;
+	struct user_struct *new_root, *creator;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+	if (h->flags & ~CKPT_USERNS_INIT)  /* only 1 valid flag */
+		return ERR_PTR(-EINVAL);
+	if (h->flags & CKPT_USERNS_INIT) {
+		ckpt_hdr_put(ctx, h);
+		/* grab an extra ref bc objhash will drop an extra */
+		return get_user_ns(current_user_ns());
+	}
+	creator = ckpt_obj_fetch(ctx, h->creator_ref, CKPT_OBJ_USER);
+	ckpt_hdr_put(ctx, h);
+
+	if (IS_ERR(creator))
+		return ERR_PTR(-EINVAL);
+	ns = new_user_ns(creator, &new_root);
+
+	if (IS_ERR(ns))
+		return ns;
+
+	/* new_user_ns() doesn't bump creator's refcount */
+	get_uid(creator);
+
+	/* objhash will drop new_ns refcount, but new_root
+	 * should hold a ref */
+	get_user_ns(ns);
+
+	/*
+	 * Free the new root user.  If we actually needed it,
+	 * then it will show up later in the checkpoint image
+	 * The objhash will keep the userns pinned until then.
+	 */
+	free_uid(new_root);
+
+	return ns;
+}
+
+#endif
-- 
1.6.1

