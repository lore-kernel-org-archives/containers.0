From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 062/100] c/r: checkpoint and restore task credentials
Date: Sat,  1 May 2010 10:15:44 -0400
Message-ID: <1272723382-19470-63-git-send-email-orenl__31361.7916348905$1272728569$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

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

Changelog [v21]:
  - Do not include checkpoint_hdr.h explicitly
  - Replace __initcall() with late_initcall()
  - Move userns c/r code from checkpoint/namespace.c to
      kernel/{user,cred,user_namespace}.c
  - [Serge Hallyn] Remove [] following individual ops definitions.
  - [Serge Hallyn] Add prototypes for c/r funcs in user_namespace.c in
      user.c when CONFIG_USER_NS=y

Changelog [v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums

Changelog:
	Sep 08: [NTL] discard const from struct cred * where appropriate
	Jun 15: Fix user_ns handling when !CONFIG_USER_N
	        Set creator_ref=0 for root_ns (discard @flags)
		Don't  overwrite global user-ns if CONFIG_USER_NS
	Jun 10: Merge with ckpt-v16-dev (Oren Laadan)
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

Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
[orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org: merge with ckpt-v16-dev]
---
 include/linux/capability.h       |    6 +-
 include/linux/checkpoint.h       |    1 +
 include/linux/checkpoint_hdr.h   |   67 ++++++++++
 include/linux/checkpoint_types.h |    2 +
 kernel/checkpoint/process.c      |  128 ++++++++++++++++++-
 kernel/cred.c                    |  144 +++++++++++++++++++++
 kernel/groups.c                  |   86 +++++++++++++
 kernel/user.c                    |  261 ++++++++++++++++++++++++++++++++++++++
 kernel/user_namespace.c          |   85 ++++++++++++
 9 files changed, 774 insertions(+), 6 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 5abd86c..fe29a7d 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -567,10 +567,10 @@ struct dentry;
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
 
 struct cred;
-int apply_securebits(unsigned securebits, struct cred *new);
+extern int apply_securebits(unsigned securebits, struct cred *new);
 struct ckpt_capabilities;
-int restore_capabilities(struct ckpt_capabilities *h, struct cred *new);
-void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred * cred);
+extern int restore_capabilities(struct ckpt_capabilities *h, struct cred *new);
+extern void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred *cred);
 
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index cd76f70..776de99 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -28,6 +28,7 @@
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/ipc_namespace.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/err.h>
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 9d725db..8598eb5 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -92,6 +92,16 @@ enum {
 #define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
 	CKPT_HDR_CAPABILITIES,
 #define CKPT_HDR_CAPABILITIES CKPT_HDR_CAPABILITIES
+	CKPT_HDR_USER_NS,
+#define CKPT_HDR_USER_NS CKPT_HDR_USER_NS
+	CKPT_HDR_CRED,
+#define CKPT_HDR_CRED CKPT_HDR_CRED
+	CKPT_HDR_USER,
+#define CKPT_HDR_USER CKPT_HDR_USER
+	CKPT_HDR_GROUPINFO,
+#define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
+	CKPT_HDR_TASK_CREDS,
+#define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -169,6 +179,14 @@ enum obj_type {
 #define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
 	CKPT_OBJ_IPC_NS,
 #define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
+	CKPT_OBJ_USER_NS,
+#define CKPT_OBJ_USER_NS CKPT_OBJ_USER_NS
+	CKPT_OBJ_CRED,
+#define CKPT_OBJ_CRED CKPT_OBJ_CRED
+	CKPT_OBJ_USER,
+#define CKPT_OBJ_USER CKPT_OBJ_USER
+	CKPT_OBJ_GROUPINFO,
+#define CKPT_OBJ_GROUPINFO CKPT_OBJ_GROUPINFO
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -252,6 +270,11 @@ struct ckpt_hdr_task {
 	__u32 robust_futex_head_len;
 	__u64 robust_futex_list; /* a __user ptr */
 
+#ifdef CONFIG_AUDITSYSCALL
+	/* would audit want to track the checkpointed ids,
+	   or (more likely) who actually restarted? */
+#endif
+
 	__u64 set_child_tid;
 	__u64 clear_child_tid;
 } __attribute__((aligned(8)));
@@ -266,6 +289,50 @@ struct ckpt_capabilities {
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
+struct ckpt_hdr_user_ns {
+	struct ckpt_hdr h;
+	__s32 creator_ref;
+} __attribute__((aligned(8)));
+
 /* namespaces */
 struct ckpt_hdr_task_ns {
 	struct ckpt_hdr h;
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index d1b893c..fe20842 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -25,6 +25,7 @@
 struct ckpt_stats {
 	int uts_ns;
 	int ipc_ns;
+	int user_ns;
 };
 
 struct ckpt_ctx {
@@ -76,6 +77,7 @@ struct ckpt_ctx {
 	int active_pid;			/* (next) position in pids array */
 	struct completion complete;	/* container root and other tasks on */
 	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+	struct cred *realcred, *ecred;	/* tmp storage for cred at restart */
 
 	struct ckpt_stats stats;	/* statistics */
 
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 68539bd..4bc76e0 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -19,6 +19,7 @@
 #include <linux/poll.h>
 #include <linux/utsname.h>
 #include <linux/syscalls.h>
+#include <linux/user_namespace.h>
 #include <linux/checkpoint.h>
 
 
@@ -135,6 +136,45 @@ static int checkpoint_task_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int checkpoint_task_creds(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int realcred_ref, ecred_ref;
+	struct cred *rcred, *ecred;
+	struct ckpt_hdr_task_creds *h;
+	int ret;
+
+	rcred = (struct cred *) get_cred(t->real_cred);
+	ecred = (struct cred *) get_cred(t->cred);
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
+}
+
 static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -150,10 +190,19 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * restored when it gets to restore, e.g. its memory.
 	 */
 
+	ret = checkpoint_task_creds(ctx, t);
+	ckpt_debug("cred: objref %d\n", ret);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)process credentials\n");
+		return ret;
+	}
+
 	ret = checkpoint_task_ns(ctx, t);
 	ckpt_debug("ns: objref %d\n", ret);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "%(T)process namespaces\n");
 		return ret;
+	}
 
 	files_objref = checkpoint_obj_file_table(ctx, t);
 	ckpt_debug("files: objref %d\n", files_objref);
@@ -433,6 +482,39 @@ static int restore_task_ns(struct ckpt_ctx *ctx)
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
+		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
+			PTR_ERR(realcred), h->cred_ref);
+		ret = PTR_ERR(realcred);
+		goto out;
+	}
+	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
+	if (IS_ERR(ecred)) {
+		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
+			PTR_ERR(ecred), h->ecred_ref);
+		ret = PTR_ERR(ecred);
+		goto out;
+	}
+	ctx->realcred = realcred;
+	ctx->ecred = ecred;
+
+out:
+	ckpt_debug("Returning %d\n", ret);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 static int restore_task_objs(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_task_objs *h;
@@ -443,13 +525,22 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 * and because shared objects are restored before they are
 	 * referenced. See comment in checkpoint_task_objs.
 	 */
+	ret = restore_task_creds(ctx);
+	if (ret < 0) {
+		ckpt_debug("restore_task_creds returned %d\n", ret);
+		return ret;
+	}
 	ret = restore_task_ns(ctx);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_debug("restore_task_ns returned %d\n", ret);
 		return ret;
+	}
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
-	if (IS_ERR(h))
+	if (IS_ERR(h)) {
+		ckpt_debug("Error fetching task obj\n");
 		return PTR_ERR(h);
+	}
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
@@ -461,6 +552,33 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
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
+	old = override_creds(ecred); /* override_creds otoh takes new ref */
+	put_cred(old);
+
+	ctx->realcred = ctx->ecred = NULL;
+	return 0;
+}
+
 int restore_restart_block(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_restart_block *h;
@@ -594,6 +712,10 @@ int restore_task(struct ckpt_ctx *ctx)
 		goto out;
 	ret = restore_task_objs(ctx);
 	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_creds(ctx);
+	ckpt_debug("creds: ret %d\n", ret);
  out:
 	return ret;
 }
diff --git a/kernel/cred.c b/kernel/cred.c
index fbd1750..a8013c8 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -17,6 +17,7 @@
 #include <linux/init_task.h>
 #include <linux/security.h>
 #include <linux/cn_proc.h>
+#include <linux/checkpoint.h>
 #include "cred-internals.h"
 
 #if 0
@@ -1009,3 +1010,146 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 	}
 	return -EPERM;
 }
+
+#ifdef CONFIG_CHECKPOINT
+static int checkpoint_cred(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct cred *cred = ptr;
+	struct ckpt_hdr_cred *h;
+	int groupinfo_ref, user_ref;
+	int ret;
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
+	ckpt_debug("cred uid %d fsuid %d gid %d\n", cred->uid, cred->fsuid,
+			cred->gid);
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
+static void *restore_cred(struct ckpt_ctx *ctx)
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
+	return (void *) cred;
+
+err_putcred:
+	abort_creds(cred);
+error:
+	ckpt_hdr_put(ctx, h);
+	return ERR_PTR(ret);
+}
+
+static int obj_cred_grab(void *ptr)
+{
+	get_cred((struct cred *) ptr);
+	return 0;
+}
+
+static void obj_cred_drop(void *ptr, int lastref)
+{
+	put_cred((struct cred *) ptr);
+}
+
+/* struct cred */
+static const struct ckpt_obj_ops ckpt_obj_cred_ops = {
+	.obj_name = "CRED",
+	.obj_type = CKPT_OBJ_CRED,
+	.ref_drop = obj_cred_drop,
+	.ref_grab = obj_cred_grab,
+	.checkpoint = checkpoint_cred,
+	.restore = restore_cred,
+};
+
+static int __init checkpoint_register_cred(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_cred_ops);
+}
+
+late_initcall(checkpoint_register_cred);
+#endif
diff --git a/kernel/groups.c b/kernel/groups.c
index 2b45b2e..185efb3 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -6,6 +6,7 @@
 #include <linux/slab.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/checkpoint.h>
 #include <asm/uaccess.h>
 
 /* init to 2 - one for init_task, one to ensure it is never freed */
@@ -286,3 +287,88 @@ int in_egroup_p(gid_t grp)
 }
 
 EXPORT_SYMBOL(in_egroup_p);
+
+#ifdef CONFIG_CHECKPOINT
+static int checkpoint_groupinfo(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct group_info *g = ptr;
+	struct ckpt_hdr_groupinfo *h;
+	int ret, i, size;
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
+static void *restore_groupinfo(struct ckpt_ctx *ctx)
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
+static int obj_groupinfo_grab(void *ptr)
+{
+	get_group_info((struct group_info *) ptr);
+	return 0;
+}
+
+static void obj_groupinfo_drop(void *ptr, int lastref)
+{
+	put_group_info((struct group_info *) ptr);
+}
+
+static const struct ckpt_obj_ops ckpt_obj_groupinfo_ops = {
+	.obj_name = "GROUPINFO",
+	.obj_type = CKPT_OBJ_GROUPINFO,
+	.ref_drop = obj_groupinfo_drop,
+	.ref_grab = obj_groupinfo_grab,
+	.checkpoint = checkpoint_groupinfo,
+	.restore = restore_groupinfo,
+};
+
+static int __init checkpoint_register_groupinfo(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_groupinfo_ops);
+}
+
+late_initcall(checkpoint_register_groupinfo);
+#endif
diff --git a/kernel/user.c b/kernel/user.c
index 766467b..4d1fda6 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
 #include "cred-internals.h"
 
 struct user_namespace init_user_ns = {
@@ -184,6 +185,262 @@ out_unlock:
 	return NULL;
 }
 
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
+static int do_checkpoint_user(struct ckpt_ctx *ctx, struct user_struct *u)
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
+	ns_objref = ckpt_obj_lookup(ctx, u->user_ns, CKPT_OBJ_USER_NS);
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
+		if (ckpt_obj_lookup(ctx, save_u, CKPT_OBJ_USER))
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
+static int checkpoint_user(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_user(ctx, (struct user_struct *) ptr);
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
+static struct user_struct *do_restore_user(struct ckpt_ctx *ctx)
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
+
+static void *restore_user(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_user(ctx);
+}
+
+static int obj_user_grab(void *ptr)
+{
+	struct user_struct *u = ptr;
+	(void) get_uid(u);
+	return 0;
+}
+
+static void obj_user_drop(void *ptr, int lastref)
+{
+	free_uid((struct user_struct *) ptr);
+}
+
+/* user object */
+static const struct ckpt_obj_ops ckpt_obj_user_ops = {
+	.obj_name = "USER",
+	.obj_type = CKPT_OBJ_USER,
+	.ref_drop = obj_user_drop,
+	.ref_grab = obj_user_grab,
+	.checkpoint = checkpoint_user,
+	.restore = restore_user,
+};
+
+#ifdef CONFIG_USER_NS
+extern int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_userns(struct ckpt_ctx *ctx);
+#else
+/*
+ * user_ns  -  trivial checkpoint/restore for !CONFIG_USER_NS case
+ */
+static int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct ckpt_hdr_user_ns *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static void *restore_userns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *ns;
+
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.user_ns)
+		return ERR_PTR(-EEXIST);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	if (h->creator_ref)
+		ns = ERR_PTR(-EINVAL);
+	else
+		ns = get_user_ns(current_user_ns());
+
+	ctx->stats.user_ns++;
+	ckpt_hdr_put(ctx, h);
+	return ns;
+}
+#endif
+
+static int obj_userns_grab(void *ptr)
+{
+	get_user_ns((struct user_namespace *) ptr);
+	return 0;
+}
+
+static void obj_userns_drop(void *ptr, int lastref)
+{
+	put_user_ns((struct user_namespace *) ptr);
+}
+
+/* user_ns object */
+static const struct ckpt_obj_ops ckpt_obj_userns_ops = {
+	.obj_name = "USER_NS",
+	.obj_type = CKPT_OBJ_USER_NS,
+	.ref_drop = obj_userns_drop,
+	.ref_grab = obj_userns_grab,
+	.checkpoint = checkpoint_userns,
+	.restore = restore_userns,
+};
+
+static int __init checkpoint_register_userns(void)
+{
+	int ret;
+
+	ret = register_checkpoint_obj(&ckpt_obj_userns_ops);
+	if (ret < 0)
+		return ret;
+	ret = register_checkpoint_obj(&ckpt_obj_user_ops);
+	if (ret < 0)
+		return ret;
+	return 0;
+}
+#endif
+
 static int __init uid_cache_init(void)
 {
 	int n;
@@ -199,7 +456,11 @@ static int __init uid_cache_init(void)
 	uid_hash_insert(&root_user, uidhashentry(&init_user_ns, 0));
 	spin_unlock_irq(&uidhash_lock);
 
+#ifdef CONFIG_CHECKPOINT
+	return checkpoint_register_userns();
+#else
 	return 0;
+#endif
 }
 
 module_init(uid_cache_init);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index e624b0f..abed3fa 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -9,6 +9,7 @@
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
 #include <linux/user_namespace.h>
+#include <linux/checkpoint.h>
 #include <linux/cred.h>
 
 static struct user_namespace *_new_user_ns(struct user_struct *creator,
@@ -103,3 +104,87 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+#ifdef CONFIG_CHECKPOINT
+/*
+ * do_checkpoint_userns() is only called from do_checkpoint_user().
+ * When called, we always know that either:
+ *   1. This is the root_ns (user_ns of the ctx->root_task),
+ *	in which case we set h->creator_ref = 0.
+ * or
+ *   2. The creator has already been written out to the
+ *	checkpoint image (and saved in the objhash)
+ */
+int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct user_namespace *ns = ptr;
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *root_ns;
+	int creator_ref = 0;
+	int ret;
+
+	root_ns = task_cred_xxx(ctx->root_task, user)->user_ns;
+	if (ns != root_ns) {
+		creator_ref = ckpt_obj_lookup(ctx, ns->creator, CKPT_OBJ_USER);
+		if (!creator_ref)
+			return -EINVAL;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (!h)
+		return -ENOMEM;
+	h->creator_ref = creator_ref;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+void *restore_userns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_user_ns *h;
+	struct user_namespace *ns;
+	struct user_struct *new_root, *creator;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	if (!h->creator_ref) {
+		ns = get_user_ns(current_user_ns());
+		goto out;
+	}
+
+	creator = ckpt_obj_fetch(ctx, h->creator_ref, CKPT_OBJ_USER);
+	if (IS_ERR(creator)) {
+		ns = ERR_PTR(-EINVAL);
+		goto out;
+	}
+
+	ns = new_user_ns(creator, &new_root);
+	if (IS_ERR(ns))
+		goto out;
+
+	/* ns only referenced from new_root, which we discard below */
+	get_user_ns(ns);
+
+	/* new_user_ns() doesn't bump creator's refcount */
+	get_uid(creator);
+
+	/*
+	 * Free the new root user.  If we actually needed it,
+	 * then it will show up later in the checkpoint image
+	 * The objhash will keep the userns pinned until then.
+	 */
+	free_uid(new_root);
+out:
+	ctx->stats.user_ns++;
+	ckpt_hdr_put(ctx, h);
+	return ns;
+}
+
+/*
+ * The checkpoint ops for userns are registered from user.c in order to handle
+ * the !CONFIG_USER_NS case.
+ */
+#endif
-- 
1.6.3.3
