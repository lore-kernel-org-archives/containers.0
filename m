From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/3] cr: add generic LSM c/r support (v4)
Date: Thu, 1 Oct 2009 22:49:16 -0500
Message-ID: <20091002034916.GA16871@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Linux Containers <containers@lists.osdl.org>
Cc: linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Casey Schaufler <casey@schaufler-ca.com>, Stephen Smalley <sds@epoch.ncsc.mil>
List-Id: containers.vger.kernel.org

(wasn't versioning the patchsets before, so randomly pick 4 as
the version for this patchset...)

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

The result of applying this patchset can be seen at
http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=ckpt-v18-hallyn.lsm3

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

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Cc: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: Casey Schaufler <casey@schaufler-ca.com>
---
 Documentation/checkpoint/readme.txt |   25 +++++
 checkpoint/checkpoint.c             |   11 ++
 checkpoint/files.c                  |   34 +++++++
 checkpoint/objhash.c                |   93 +++++++++++++++++
 checkpoint/process.c                |   20 +++-
 checkpoint/restart.c                |   25 +++++
 checkpoint/sys.c                    |   22 ++++
 include/linux/checkpoint.h          |    7 +-
 include/linux/checkpoint_hdr.h      |   24 +++++-
 include/linux/checkpoint_types.h    |    9 ++
 include/linux/security.h            |  188 +++++++++++++++++++++++++++++++++++
 ipc/checkpoint.c                    |   34 +++++--
 ipc/checkpoint_msg.c                |   26 +++++-
 ipc/checkpoint_sem.c                |    4 +-
 ipc/checkpoint_shm.c                |    4 +-
 ipc/util.h                          |    6 +-
 kernel/cred.c                       |   20 ++++-
 security/capability.c               |   74 ++++++++++++++
 security/security.c                 |  131 ++++++++++++++++++++++++
 19 files changed, 731 insertions(+), 26 deletions(-)

diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
index 571c469..8ec5850 100644
--- a/Documentation/checkpoint/readme.txt
+++ b/Documentation/checkpoint/readme.txt
@@ -333,6 +333,31 @@ So that's why we don't want CAP_SYS_ADMIN required up-front. That way
 we will be forced to more carefully review each of those features.
 However, this can be controlled with a sysctl-variable.
 
+LSM
+===
+
+Security modules use custom labels on subjects and objects to
+further mediate access decisions beyond DAC controls.  When
+checkpoint applications, these labels are [ work in progress ]
+checkpointed along with the objects.  At restart, the
+RESTART_KEEP_LSM flag tells the kernel whether re-created objects
+whould keep their checkpointed labels, or get automatically
+recalculated labels.  Since checkpointed labels will only make
+sense to the same LSM which was active at checkpoint time,
+sys_restart() with the RESTART_KEEP_LSM flag will fail with
+-EINVAL if the LSM active at restart is not the same as that
+active at checkpoint.  If RESTART_KEEP_LSM is not specified,
+then objects will be given whatever default labels the LSM and
+their optional policy decide.  Of course, when RESTART_KEEP_LSM
+is specified, the LSM may choose a different label than the
+checkpointed one, or fail the entire restart if the caller
+does not have permission to create objects with the checkpointed
+label.
+
+It should always be safe to take a checkpoint of an application
+under LSM_1, and restart it without the RESTART_KEEP_LSM flag
+under LSM_2.
+
 
 Kernel interfaces
 =================
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 1eeb557..6722035 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -25,6 +25,7 @@
 #include <linux/magic.h>
 #include <linux/hrtimer.h>
 #include <linux/deferqueue.h>
+#include <linux/security.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -351,6 +352,16 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	memset(ctx->lsm_name, 0, SECURITY_NAME_MAX + 1);
+	strlcpy(ctx->lsm_name, security_get_lsm_name(), SECURITY_NAME_MAX + 1);
+	ret = ckpt_write_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
+	ret = security_checkpoint_header(ctx);
+	if (ret < 0)
+		return ret;
+
 	return checkpoint_write_header_arch(ctx);
 }
 
diff --git a/checkpoint/files.c b/checkpoint/files.c
index 27e29a0..570facb 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -145,6 +145,19 @@ static int scan_fds(struct files_struct *files, int **fdtable)
 	return n;
 }
 
+#ifdef CONFIG_SECURITY
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return security_checkpoint_obj(ctx, file->f_security,
+					CKPT_SECURITY_FILE);
+}
+#else
+int checkpoint_file_security(struct ckpt_ctx *ctx, struct file *file)
+{
+	return -EOPNOTSUPP;
+}
+#endif
+
 int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 			   struct ckpt_hdr_file *h)
 {
@@ -159,6 +172,16 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (h->f_credref < 0)
 		return h->f_credref;
 
+	h->f_secref = checkpoint_file_security(ctx, file);
+	if (h->f_secref == -EOPNOTSUPP)
+		h->f_secref = -1;
+	else if (h->f_secref < 0)
+		return h->f_secref;
+
+	ckpt_debug("file %s credref %d secref %d",
+		file->f_dentry->d_name.name, h->f_credref,
+		h->f_secref);
+
 	/* FIX: need also file->f_owner, etc */
 
 	return 0;
@@ -507,6 +530,17 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	put_cred(file->f_cred);
 	file->f_cred = get_cred(cred);
 
+	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->f_secref != -1)) {
+		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->f_secref,
+					CKPT_OBJ_SEC);
+		if (IS_ERR(l))
+			return PTR_ERR(l);
+
+		ret = security_file_restore(file, l->string);
+		if (ret)
+			return ret;
+	}
+
 	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
 	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
 	if (ret < 0)
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index f84388d..58ff040 100644
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
@@ -285,6 +286,89 @@ static int obj_tty_users(void *ptr)
 	return atomic_read(&((struct tty_struct *) ptr)->kref.refcount);
 }
 
+static void obj_free_sec(struct kref *kref)
+{
+	struct ckpt_stored_lsm *s = container_of(kref, struct ckpt_stored_lsm,
+					kref);
+	kfree(s->string);
+	kfree(s);
+}
+
+static int obj_sec_grab(void *ptr)
+{
+	struct ckpt_stored_lsm *s = ptr;
+	kref_get(&s->kref);
+	return 0;
+}
+
+static void obj_sec_drop(void *ptr, int lastref)
+{
+	struct ckpt_stored_lsm *s = ptr;
+	kref_put(&s->kref, obj_free_sec);
+}
+
+static int do_checkpoint_security(struct ckpt_ctx *ctx,
+				const struct ckpt_stored_lsm *l)
+{
+	int ret, len;
+	struct ckpt_hdr_lsm *h;
+
+	len = strlen(l->string);
+	if (len > PAGE_SIZE - sizeof(*h))
+		return -E2BIG;
+	h = ckpt_hdr_get_type(ctx, sizeof(*h)+len+1, CKPT_HDR_SEC);
+	if (!h)
+		return -ENOMEM;
+	h->len = len;
+	h->sectype = l->sectype;
+	strncpy(h->string, l->string, len);
+	h->string[len] = '\0';
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int checkpoint_security(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_security(ctx, (struct ckpt_stored_lsm *) ptr);
+}
+
+static struct ckpt_stored_lsm *do_restore_security(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_lsm *h;
+	struct ckpt_stored_lsm *l;
+
+	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_SEC);
+	if (IS_ERR(h))
+		return (struct ckpt_stored_lsm *)h;
+	if (h->len > h->h.len - sizeof(struct ckpt_hdr) ||
+				h->len > PAGE_SIZE) {
+		ckpt_hdr_put(ctx, h);
+		return ERR_PTR(-EINVAL);
+	}
+	l = kzalloc(sizeof(*l), GFP_KERNEL);
+	if (!l) {
+		ckpt_hdr_put(ctx, h);
+		return ERR_PTR(-ENOMEM);
+	}
+	l->string = kzalloc(h->len + 1, GFP_KERNEL);
+	if (!l->string) {
+		kfree(l);
+		ckpt_hdr_put(ctx, h);
+		return ERR_PTR(-ENOMEM);
+	}
+	kref_init(&l->kref);
+	l->sectype = h->sectype;
+	strncpy(l->string, h->string, h->len);
+	ckpt_hdr_put(ctx, h);
+	return l;
+}
+
+static void *restore_security(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_security(ctx);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -433,6 +517,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_tty,
 		.restore = restore_tty,
 	},
+	/* LSM security labels */
+	{
+		.obj_name = "LSM",
+		.obj_type = CKPT_OBJ_SEC,
+		.ref_drop = obj_sec_drop,
+		.ref_grab = obj_sec_grab,
+		.checkpoint = checkpoint_security,
+		.restore = restore_security,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 5ba64f0..ed7896c 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -581,11 +581,15 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 
 	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(realcred)) {
+		ckpt_debug("Error %ld fetching readlcred (ref %d)",
+			PTR_ERR(realcred), h->cred_ref);
 		ret = PTR_ERR(realcred);
 		goto out;
 	}
 	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(ecred)) {
+		ckpt_debug("Error %ld fetching ecred (ref %d)",
+			PTR_ERR(ecred), h->ecred_ref);
 		ret = PTR_ERR(ecred);
 		goto out;
 	}
@@ -593,6 +597,7 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 	ctx->ecred = ecred;
 
 out:
+	ckpt_debug("Returning %d.", ret);
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -608,14 +613,21 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 * referenced. See comment in checkpoint_task_objs.
 	 */
 	ret = restore_task_creds(ctx);
-	if (!ret)
-		ret = restore_task_ns(ctx);
-	if (ret < 0)
+	if (ret) {
+		ckpt_debug("restore_task_creds returned %d", ret);
+		return ret;
+	}
+	ret = restore_task_ns(ctx);
+	if (ret) {
+		ckpt_debug("restore_task_ns returned %d", ret);
 		return ret;
+	}
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
-	if (IS_ERR(h))
+	if (IS_ERR(h)) {
+		ckpt_debug("Error fetching task obj");
 		return PTR_ERR(h);
+	}
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index b12c8bd..bba2b45 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -457,6 +457,31 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	ret = _ckpt_read_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
+	if (ret < 0)
+		goto out;
+	if (ctx->uflags & RESTART_KEEP_LSM) {
+		char *cur = security_get_lsm_name();
+		if (strncmp(cur, ctx->lsm_name, SECURITY_NAME_MAX + 1) != 0) {
+			pr_warning("c/r: checkpointed LSM %s, current is %s.\n",
+				ctx->lsm_name, cur);
+			ret = -EINVAL;
+			goto out;
+		}
+		/* to be implemented later, per-lsm */
+		if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
+				strcmp(ctx->lsm_name, "default") != 0) {
+			pr_warning("c/r: RESTART_KEEP_LSM unsupported for %s\n",
+					ctx->lsm_name);
+			ret = -ENOSYS;
+			goto out;
+		}
+	}
+
+	ret = security_may_restart(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = restore_read_header_arch(ctx);
  out:
 	kfree(uts);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 7604089..0a1e8a6 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -169,6 +169,28 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
 	return h;
 }
 
+#define DUMMY_LSM_INFO "dummy"
+
+int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx)
+{
+	return ckpt_write_obj_type(ctx, DUMMY_LSM_INFO,
+			strlen(DUMMY_LSM_INFO), CKPT_HDR_LSM_INFO);
+}
+
+/*
+ * ckpt_snarf_lsm_info
+ * If there is a CKPT_HDR_LSM_INFO field, toss it.
+ * Used when the current LSM doesn't care about this field.
+ */
+void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr *h;
+
+	h = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
+	if (!IS_ERR(h))
+		ckpt_hdr_put(ctx, h);
+}
+
 
 /*
  * Helpers to manage c/r contexts: allocated for each checkpoint and/or
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e403dd7..707f9fb 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  2
+#define CHECKPOINT_VERSION  3
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
@@ -19,6 +19,7 @@
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
 #define RESTART_GHOST		0x4
+#define RESTART_KEEP_LSM	0x8
 
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
@@ -48,7 +49,9 @@
 #define RESTART_USER_FLAGS  \
 	(RESTART_TASKSELF | \
 	 RESTART_FROZEN | \
+	 RESTART_KEEP_LSM | \
 	 RESTART_GHOST)
+#define CKPT_LSM_INFO_LEN 200
 
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
@@ -62,6 +65,8 @@ extern void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int n);
 extern void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr);
 extern void *ckpt_hdr_get(struct ckpt_ctx *ctx, int n);
 extern void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int n, int type);
+extern int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+extern void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
 
 extern int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
 extern int ckpt_write_obj_type(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2ed523f..61ac537 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -58,6 +58,8 @@ enum {
 	CKPT_HDR_BUFFER,
 	CKPT_HDR_STRING,
 	CKPT_HDR_OBJREF,
+	CKPT_HDR_SEC,
+	CKPT_HDR_LSM_INFO,
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
@@ -146,6 +148,7 @@ enum obj_type {
 	CKPT_OBJ_GROUPINFO,
 	CKPT_OBJ_SOCK,
 	CKPT_OBJ_TTY,
+	CKPT_OBJ_SEC,
 	CKPT_OBJ_MAX
 };
 
@@ -189,10 +192,11 @@ struct ckpt_hdr_header {
 	__u64 uflags;	/* uflags from checkpoint */
 
 	/*
-	 * the header is followed by three strings:
+	 * the header is followed by four strings:
 	 *   char release[const.uts_release_len];
 	 *   char version[const.uts_version_len];
 	 *   char machine[const.uts_machine_len];
+	 *   char lsm_name[SECURITY_NAME_MAX + 1]
 	 */
 } __attribute__((aligned(8)));
 
@@ -265,6 +269,8 @@ struct ckpt_hdr_cred {
 	__u32 gid, sgid, egid, fsgid;
 	__s32 user_ref;
 	__s32 groupinfo_ref;
+	__s32 sec_ref;
+	__u32 padding;
 	struct ckpt_capabilities cap_s;
 } __attribute__((aligned(8)));
 
@@ -277,6 +283,16 @@ struct ckpt_hdr_groupinfo {
 	__u32 groups[0];
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_lsm {
+	struct ckpt_hdr h;
+	__u8 sectype;
+	__u16 len;
+	/*
+	 * This is followed by a string of size len+1,
+	 * null-terminated
+	 */
+	__u8 string[0];
+} __attribute__((aligned(8)));
 /*
  * todo - keyrings and LSM
  * These may be better done with userspace help though
@@ -392,6 +408,8 @@ struct ckpt_hdr_file {
 	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
+	__s32 f_secref;
+	__u32 f_padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_file_generic {
@@ -634,6 +652,8 @@ struct ckpt_hdr_ipc_perms {
 	__u32 mode;
 	__u32 _padding;
 	__u64 seq;
+	__s32 sec_ref;
+	__u32 padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_shm {
@@ -667,6 +687,8 @@ struct ckpt_hdr_ipc_msg_msg {
 	struct ckpt_hdr h;
 	__s32 m_type;
 	__u32 m_ts;
+	__s32 sec_ref;
+	__u32 padding;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_ipc_sem {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index b9393f4..6a2c9dc 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -21,6 +21,7 @@
 #include <linux/fs.h>
 #include <linux/ktime.h>
 #include <linux/wait.h>
+#include <linux/security.h>
 
 struct ckpt_stats {
 	int uts_ns;
@@ -42,6 +43,7 @@ struct ckpt_ctx {
 	struct task_struct *root_task;		/* [container] root task */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
 	struct task_struct *root_freezer;	/* [container] root task */
+	char lsm_name[SECURITY_NAME_MAX + 1];   /* security module at ckpt */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
@@ -82,6 +84,13 @@ struct ckpt_ctx {
 	struct ckpt_stats stats;	/* statistics */
 };
 
+/* stored on hashtable */
+struct ckpt_stored_lsm {
+	struct kref kref;
+	int sectype;
+	char *string;
+};
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_CHECKPOINT_TYPES_H_ */
diff --git a/include/linux/security.h b/include/linux/security.h
index 1f16eea..67f9c53 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -46,6 +46,10 @@
 struct ctl_table;
 struct audit_krule;
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+#endif
+
 /*
  * These functions are in security/capability.c and are used
  * as the default capabilities functions
@@ -574,6 +578,15 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -653,6 +666,17 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -1101,6 +1125,19 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -1109,6 +1146,16 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -1320,6 +1367,28 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@secdata contains the security context.
  *	@seclen contains the length of the security context.
  *
+ * Security hooks for Checkpoint/restart
+ * (In addition to *_checkpoint and *_restore)
+ *
+ * @may_restart:
+ *	Authorize sys_restart().
+ *	Note that all construction of kernel resources, credentials,
+ *	etc is already authorized per the caller's credentials.  This
+ *	hook is intended for the LSM to make further decisions about
+ *	a task not being allowed to restart at all, for instance if
+ *	the policy has changed since checkpoint.
+ *	@ctx is the checkpoint/restart context (see <linux/checkpoint_types.h>)
+ *	Return 0 if allowed, <0 on error.
+ *
+ * @checkpoint_header:
+ *	Optionally write out a LSM-specific checkpoint header.  This is
+ *	a chance to write out policy information, for instance.  The same
+ *	LSM on restart can then use the info in security_may_restart() to
+ * 	refuse restart (for instance) across policy changes.
+ *	The info is to be written as a an object of type CKPT_HDR_LSM_INFO.
+ *	@ctx is the checkpoint/restart context (see <linux/checkpoint_types.h>)
+ *	Return 0 on success, <0 on error.
+ *
  * Security hooks for Audit
  *
  * @audit_rule_init:
@@ -1463,6 +1532,8 @@ struct security_operations {
 
 	int (*file_permission) (struct file *file, int mask);
 	int (*file_alloc_security) (struct file *file);
+	char *(*file_checkpoint) (void *security);
+	int (*file_restore) (struct file *file, char *ctx);
 	void (*file_free_security) (struct file *file);
 	int (*file_ioctl) (struct file *file, unsigned int cmd,
 			   unsigned long arg);
@@ -1483,6 +1554,8 @@ struct security_operations {
 	int (*dentry_open) (struct file *file, const struct cred *cred);
 
 	int (*task_create) (unsigned long clone_flags);
+	char *(*cred_checkpoint) (void *security);
+	int (*cred_restore) (struct file *file, struct cred *cred, char *ctx);
 	void (*cred_free) (struct cred *cred);
 	int (*cred_prepare)(struct cred *new, const struct cred *old,
 			    gfp_t gfp);
@@ -1516,8 +1589,12 @@ struct security_operations {
 
 	int (*ipc_permission) (struct kern_ipc_perm *ipcp, short flag);
 	void (*ipc_getsecid) (struct kern_ipc_perm *ipcp, u32 *secid);
+	char *(*ipc_checkpoint) (void *security);
+	int (*ipc_restore) (struct kern_ipc_perm *ipcp, char *ctx);
 
 	int (*msg_msg_alloc_security) (struct msg_msg *msg);
+	char *(*msg_msg_checkpoint) (void *security);
+	int (*msg_msg_restore) (struct msg_msg *msg, char *ctx);
 	void (*msg_msg_free_security) (struct msg_msg *msg);
 
 	int (*msg_queue_alloc_security) (struct msg_queue *msq);
@@ -1556,6 +1633,11 @@ struct security_operations {
 	int (*secctx_to_secid) (const char *secdata, u32 seclen, u32 *secid);
 	void (*release_secctx) (char *secdata, u32 seclen);
 
+#ifdef CONFIG_CHECKPOINT
+	int (*may_restart) (struct ckpt_ctx *ctx);
+	int (*checkpoint_header) (struct ckpt_ctx *ctx);
+#endif
+
 #ifdef CONFIG_SECURITY_NETWORK
 	int (*unix_stream_connect) (struct socket *sock,
 				    struct socket *other, struct sock *newsk);
@@ -1721,6 +1803,8 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
 void security_inode_getsecid(const struct inode *inode, u32 *secid);
 int security_file_permission(struct file *file, int mask);
 int security_file_alloc(struct file *file);
+char *security_file_checkpoint(void *security);
+int security_file_restore(struct file *file, char *ctx);
 void security_file_free(struct file *file);
 int security_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 int security_file_mmap(struct file *file, unsigned long reqprot,
@@ -1736,6 +1820,8 @@ int security_file_send_sigiotask(struct task_struct *tsk,
 int security_file_receive(struct file *file);
 int security_dentry_open(struct file *file, const struct cred *cred);
 int security_task_create(unsigned long clone_flags);
+char *security_cred_checkpoint(void *security);
+int security_cred_restore(struct file *file, struct cred *cred, char *ctx);
 void security_cred_free(struct cred *cred);
 int security_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
 void security_commit_creds(struct cred *new, const struct cred *old);
@@ -1766,7 +1852,11 @@ int security_task_prctl(int option, unsigned long arg2, unsigned long arg3,
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
@@ -1795,6 +1885,12 @@ int security_netlink_recv(struct sk_buff *skb, int cap);
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
+#ifdef CONFIG_CHECKPOINT
+int security_may_restart(struct ckpt_ctx *ctx);
+int security_checkpoint_header(struct ckpt_ctx *ctx);
+#endif /* CONFIG_CHECKPOINT */
+
+char *security_get_lsm_name(void);
 
 #else /* CONFIG_SECURITY */
 struct security_mnt_opts {
@@ -1818,6 +1914,12 @@ static inline int security_init(void)
 	return 0;
 }
 
+#define DEFAULT_LSM_NAME "lsm_none"
+static inline char *security_get_lsm_name(void)
+{
+	return DEFAULT_LSM_NAME;
+}
+
 static inline int security_ptrace_may_access(struct task_struct *child,
 					     unsigned int mode)
 {
@@ -2202,6 +2304,19 @@ static inline int security_file_alloc(struct file *file)
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
 
@@ -2266,6 +2381,20 @@ static inline int security_task_create(unsigned long clone_flags)
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
 
@@ -2408,11 +2537,37 @@ static inline void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
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
 
@@ -2537,6 +2692,21 @@ static inline int security_secctx_to_secid(const char *secdata,
 static inline void security_release_secctx(char *secdata, u32 seclen)
 {
 }
+
+#ifdef CONFIG_CHECKPOINT
+void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
+int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+
+static inline int security_may_restart(struct ckpt_ctx *ctx)
+{
+	ckpt_snarf_lsm_info(ctx);
+	return 0;
+}
+static inline int security_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	return ckpt_write_dummy_lsm_info(ctx);
+}
+#endif /* CONFIG_CHECKPOINT */
 #endif	/* CONFIG_SECURITY */
 
 #ifdef CONFIG_SECURITY_NETWORK
@@ -2997,5 +3167,23 @@ static inline void free_secdata(void *secdata)
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
+int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
+				unsigned sectype);
+#else
+static inline int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
+				unsigned sectype)
+{ return -1; }
+#endif /* CONFIG_SECURITY */
+
+#endif /* CONFIG_CHECKPOINT */
+
 #endif /* ! __LINUX_SECURITY_H */
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 8e6e9ba..c0d3f13 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -31,7 +31,8 @@ static char *ipc_ind_to_str[] = { "sem", "msg", "shm" };
  * Checkpoint
  */
 
-int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int checkpoint_fill_ipc_perms(struct ckpt_ctx *ctx,
+			      struct ckpt_hdr_ipc_perms *h,
 			      struct kern_ipc_perm *perm)
 {
 	if (ipcperms(perm, S_IROTH))
@@ -45,6 +46,15 @@ int checkpoint_fill_ipc_perms(struct ckpt_hdr_ipc_perms *h,
 	h->cgid = perm->cgid;
 	h->mode = perm->mode & S_IRWXUGO;
 	h->seq = perm->seq;
+	if (perm->security) {
+		h->sec_ref = security_checkpoint_obj(ctx, perm->security,
+					CKPT_SECURITY_IPC);
+		if (h->sec_ref == -EOPNOTSUPP)
+			h->sec_ref = -1;
+		else if (h->sec_ref < 0)
+			return h->sec_ref;
+	} else
+		h->sec_ref = -1;
 
 	return 0;
 }
@@ -176,7 +186,8 @@ static int validate_created_perms(struct ckpt_hdr_ipc_perms *h)
 	return 1;
 }
 
-int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
+int restore_load_ipc_perms(struct ckpt_ctx *ctx,
+			   struct ckpt_hdr_ipc_perms *h,
 			   struct kern_ipc_perm *perm)
 {
 	if (h->id < 0)
@@ -205,14 +216,17 @@ int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *h,
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
+
+	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
+		int ret;
+		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
+					CKPT_OBJ_SEC);
+		if (IS_ERR(l))
+			return PTR_ERR(l);
+		ret = security_ipc_restore(perm, l->string);
+		if (ret)
+			return ret;
+	}
 
 	return 0;
 }
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index b933c19..24f4097 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -37,7 +37,7 @@ static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
 
 	ipc_lock_by_ptr(&msq->q_perm);
 
-	ret = checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+	ret = checkpoint_fill_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		goto unlock;
 
@@ -64,13 +64,23 @@ static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
 	struct msg_msgseg *seg;
 	int total, len;
 	int ret;
-
+	int sec_ref = -1;
+
+	if (msg->security) {
+		sec_ref = security_checkpoint_obj(ctx, msg->security,
+						CKPT_SECURITY_MSG_MSG);
+		if (sec_ref == -EOPNOTSUPP)
+			sec_ref = -1;
+		else if (sec_ref < 0)
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
@@ -177,7 +187,7 @@ static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
 {
 	int ret = 0;
 
-	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
+	ret = restore_load_ipc_perms(ctx, &h->perms, &msq->q_perm);
 	if (ret < 0)
 		return ret;
 
@@ -224,6 +234,16 @@ static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
 	msg->next = NULL;
 	pseg = &msg->next;
 
+	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
+		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
+					CKPT_OBJ_SEC);
+		if (IS_ERR(l))
+			return (struct msg_msg *)l;
+		ret = security_msg_msg_restore(msg, l->string);
+		if (ret)
+			return ERR_PTR(ret);
+	}
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
index 9710cae..06bc676 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -709,7 +709,7 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
 static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 {
 	int ret;
-	int groupinfo_ref, user_ref;
+	int groupinfo_ref, user_ref, sec_ref = -1;
 	struct ckpt_hdr_cred *h;
 
 	groupinfo_ref = checkpoint_obj(ctx, cred->group_info,
@@ -719,6 +719,14 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	user_ref = checkpoint_obj(ctx, cred->user, CKPT_OBJ_USER);
 	if (user_ref < 0)
 		return user_ref;
+#ifdef CONFIG_SECURITY
+	sec_ref = security_checkpoint_obj(ctx, cred->security,
+					CKPT_SECURITY_CRED);
+	if (sec_ref == -EOPNOTSUPP)
+		sec_ref = -1;
+	else if (sec_ref < 0)
+		return sec_ref;
+#endif  /* else cred->security doesn't exist and sec_ref = -1 */
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CRED);
 	if (!h)
@@ -733,6 +741,7 @@ static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
 	h->sgid = cred->sgid;
 	h->egid = cred->egid;
 	h->fsgid = cred->fsgid;
+	h->sec_ref = sec_ref;
 
 	checkpoint_capabilities(&h->cap_s, cred);
 
@@ -806,6 +815,15 @@ static struct cred *do_restore_cred(struct ckpt_ctx *ctx)
 	ret = cred_setfsgid(cred, h->fsgid, &oldgid);
 	if (oldgid != h->fsgid && ret < 0)
 		goto err_putcred;
+	if ((ctx->uflags & RESTART_KEEP_LSM) && (h->sec_ref != -1)) {
+		struct ckpt_stored_lsm *l = ckpt_obj_fetch(ctx, h->sec_ref,
+					CKPT_OBJ_SEC);
+		if (IS_ERR(l))
+			return (struct cred *)l;
+		ret = security_cred_restore(ctx->file, cred, l->string);
+		if (ret)
+			goto err_putcred;
+	}
 	ret = restore_capabilities(&h->cap_s, cred);
 	if (ret)
 		goto err_putcred;
diff --git a/security/capability.c b/security/capability.c
index 88f752e..4e82df8 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -315,6 +315,16 @@ static int cap_file_permission(struct file *file, int mask)
 	return 0;
 }
 
+static inline char *cap_file_checkpoint(void *security)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static int cap_file_restore(struct file *file, char *ctx)
+{
+	return -EOPNOTSUPP;
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
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static int cap_cred_restore(struct file *file, struct cred *cred, char *ctx)
+{
+	return -EOPNOTSUPP;
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
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static int cap_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	return -EOPNOTSUPP;
+}
+
 static int cap_msg_msg_alloc_security(struct msg_msg *msg)
 {
 	return 0;
 }
 
+static inline char *cap_msg_msg_checkpoint(void *security)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static int cap_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	return -EOPNOTSUPP;
+}
+
 static void cap_msg_msg_free_security(struct msg_msg *msg)
 {
 }
@@ -792,6 +832,28 @@ static void cap_release_secctx(char *secdata, u32 seclen)
 {
 }
 
+#ifdef CONFIG_CHECKPOINT
+void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
+int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+static int cap_may_restart(struct ckpt_ctx *ctx)
+{
+	/*
+	 * Note that all construction of kernel resources, credentials,
+	 * etc is already authorized per the caller's credentials.  This
+	 * hook is intended for the LSM to make further decisions about
+	 * a task not being allowed to restart at all, for instance if
+	 * the policy has changed since checkpoint.
+	 */
+	ckpt_snarf_lsm_info(ctx);
+	return 0;
+}
+
+static int cap_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	return ckpt_write_dummy_lsm_info(ctx);
+}
+#endif
+
 #ifdef CONFIG_KEYS
 static int cap_key_alloc(struct key *key, const struct cred *cred,
 			 unsigned long flags)
@@ -928,6 +990,8 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, path_truncate);
 #endif
 	set_to_cap_if_null(ops, file_permission);
+	set_to_cap_if_null(ops, file_checkpoint);
+	set_to_cap_if_null(ops, file_restore);
 	set_to_cap_if_null(ops, file_alloc_security);
 	set_to_cap_if_null(ops, file_free_security);
 	set_to_cap_if_null(ops, file_ioctl);
@@ -940,6 +1004,8 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, file_receive);
 	set_to_cap_if_null(ops, dentry_open);
 	set_to_cap_if_null(ops, task_create);
+	set_to_cap_if_null(ops, cred_checkpoint);
+	set_to_cap_if_null(ops, cred_restore);
 	set_to_cap_if_null(ops, cred_free);
 	set_to_cap_if_null(ops, cred_prepare);
 	set_to_cap_if_null(ops, cred_commit);
@@ -966,7 +1032,11 @@ void security_fixup_ops(struct security_operations *ops)
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
@@ -992,6 +1062,10 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, secid_to_secctx);
 	set_to_cap_if_null(ops, secctx_to_secid);
 	set_to_cap_if_null(ops, release_secctx);
+#ifdef CONFIG_CHECKPOINT
+	set_to_cap_if_null(ops, may_restart);
+	set_to_cap_if_null(ops, checkpoint_header);
+#endif
 #ifdef CONFIG_SECURITY_NETWORK
 	set_to_cap_if_null(ops, unix_stream_connect);
 	set_to_cap_if_null(ops, unix_may_send);
diff --git a/security/security.c b/security/security.c
index dc7674f..52647e0 100644
--- a/security/security.c
+++ b/security/security.c
@@ -122,6 +122,11 @@ int register_security(struct security_operations *ops)
 	return 0;
 }
 
+char *security_get_lsm_name(void)
+{
+	return security_ops->name;
+}
+
 /* Security operations */
 
 int security_ptrace_may_access(struct task_struct *child, unsigned int mode)
@@ -625,6 +630,16 @@ int security_file_alloc(struct file *file)
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
@@ -684,6 +699,16 @@ int security_task_create(unsigned long clone_flags)
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
@@ -819,11 +844,31 @@ void security_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
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
@@ -959,6 +1004,20 @@ void security_release_secctx(char *secdata, u32 seclen)
 }
 EXPORT_SYMBOL(security_release_secctx);
 
+#ifdef CONFIG_CHECKPOINT
+int security_may_restart(struct ckpt_ctx *ctx)
+{
+	return security_ops->may_restart(ctx);
+}
+EXPORT_SYMBOL(security_may_restart);
+
+int security_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	return security_ops->checkpoint_header(ctx);
+}
+EXPORT_SYMBOL(security_checkpoint_header);
+#endif
+
 #ifdef CONFIG_SECURITY_NETWORK
 
 int security_unix_stream_connect(struct socket *sock, struct socket *other,
@@ -1244,3 +1303,75 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
 }
 
 #endif /* CONFIG_AUDIT */
+
+#ifdef CONFIG_CHECKPOINT
+
+#include <linux/checkpoint.h>
+
+/**
+ * security_checkpoint_obj - if first checkpoint of this void* security,
+ * then 1. ask the LSM for a string representing the context, 2. checkpoint
+ * that string
+ * @ctx: the checkpoint context
+ * @security: the void* security being checkpointed
+ * @sectype: indicates the type of object, because LSMs can (and do) store
+ * different types of data for different types of objects.
+ *
+ * Returns the objref of the checkpointed ckpt_stored_lsm representing the
+ * context, or -error on error.
+ *
+ * This is only used at checkpoint of course.
+ */
+int security_checkpoint_obj(struct ckpt_ctx *ctx, void *security,
+				unsigned sectype)
+{
+	int strref;
+	struct ckpt_stored_lsm *l;
+	char *str;
+	int len;
+
+	/*
+	 * to simplify the LSM code, short-cut a null security
+	 * here.
+	 */
+	if (!security)
+		return -EOPNOTSUPP;
+
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
+	/* str will be alloc'ed for us by the LSM.  We will free it when
+	 * we clear out our hashtable */
+	if (IS_ERR(str))
+		return PTR_ERR(str);
+
+	len = strlen(str);
+	l = kzalloc(sizeof(*l) + len + 1, GFP_KERNEL);
+	if (!l) {
+		kfree(str);
+		return -ENOMEM;
+	}
+	kref_init(&l->kref);
+	l->sectype = sectype;
+	l->string = str;
+
+	strref = checkpoint_obj(ctx, l, CKPT_OBJ_SEC);
+	/* do we need to free l if strref was err? */
+	return strref;
+}
+
+#endif
-- 
1.6.1

