From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 089/100] c/r: add lsm name and lsm_info (policy header) to
	container info
Date: Sat,  1 May 2010 10:16:11 -0400
Message-ID: <1272723382-19470-90-git-send-email-orenl__36663.9739055701$1272729948$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kentaro Takeda <takedakn-3MafRgGXt7BL9jVzuh4AOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

The LSM name is 'selinux', 'smack', 'tomoyo', or 'dummy'.  We
add that to the container configuration section.  We also add
a LSM policy configuration section.  That is placed after the LSM
name.  It is written by the LSM in security_checkpoint_header(),
called during checkpoint container(), and read by the LSM during
security_may_restart(), which is called from restore_lsm() in
restore_container().

Cc: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Kentaro Takeda <takedakn-3MafRgGXt7BL9jVzuh4AOg@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Documentation/checkpoint/readme.txt |   24 ++++++++++++++
 Documentation/checkpoint/usage.txt  |    2 +
 include/linux/checkpoint.h          |    6 +++
 include/linux/checkpoint_hdr.h      |   16 +++++++++
 include/linux/checkpoint_types.h    |    2 +
 include/linux/security.h            |   61 +++++++++++++++++++++++++++++++++++
 kernel/checkpoint/checkpoint.c      |   13 +++++++-
 kernel/checkpoint/restart.c         |   41 +++++++++++++++++++++++
 kernel/checkpoint/sys.c             |   22 ++++++++++++
 security/capability.c               |   25 ++++++++++++++
 security/security.c                 |   26 +++++++++++++++
 11 files changed, 237 insertions(+), 1 deletions(-)

diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
index 2548bb4..030a001 100644
--- a/Documentation/checkpoint/readme.txt
+++ b/Documentation/checkpoint/readme.txt
@@ -343,6 +343,30 @@ So that's why we don't want CAP_SYS_ADMIN required up-front. That way
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
 
 Sockets
 =======
diff --git a/Documentation/checkpoint/usage.txt b/Documentation/checkpoint/usage.txt
index 239c162..d697ed1 100644
--- a/Documentation/checkpoint/usage.txt
+++ b/Documentation/checkpoint/usage.txt
@@ -36,6 +36,8 @@ The API consists of three new system calls:
    - RESTART_FROEZN : processes remain frozen once restart completes
    - RESTART_GHOST : process is a ghost (placeholder for a pid)
    - RESTART_CONN_RESET : reset previously open sockets to be closed
+   - RESTART_KEEP_LSM : re-created objects keep their checkpointed
+       labels (or otherwise get automatically recalculated labels).
  (Note that this argument may mean 'ckptid' to identify an in-kernel
  checkpoint image, with some @flags in the future).
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index b7d7258..c56ece7 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -19,6 +19,7 @@
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
 #define RESTART_GHOST		0x4
+#define RESTART_KEEP_LSM	0x8
 #define RESTART_CONN_RESET      0x10
 
 /* misc user visible */
@@ -59,8 +60,11 @@ extern long do_sys_restart(pid_t pid, int fd,
 	(RESTART_TASKSELF | \
 	 RESTART_FROZEN | \
 	 RESTART_GHOST | \
+	 RESTART_KEEP_LSM | \
 	 RESTART_CONN_RESET)
 
+#define CKPT_LSM_INFO_LEN 200
+
 extern int walk_task_subtree(struct task_struct *task,
 			     int (*func)(struct task_struct *, void *),
 			     void *data);
@@ -73,6 +77,8 @@ extern void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int n);
 extern void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr);
 extern void *ckpt_hdr_get(struct ckpt_ctx *ctx, int n);
 extern void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int n, int type);
+extern int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+extern void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
 
 extern int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
 extern int ckpt_write_obj_type(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 90cbc15..9bf8eeb 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -33,6 +33,15 @@
 #endif
 
 /*
+ * /usr/include/linux/security.h is not exported to userspace, so
+ * we need this value here for userspace restart.c to read.
+ *
+ * CHECKPOINT_LSM_NAME_MAX should be SECURITY_NAME_MAX
+ * security_may_restart() has a BUILD_BUG_ON to enforce that.
+ */
+#define CHECKPOINT_LSM_NAME_MAX 10
+
+/*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
  * __attribute__((aligned (8))) for the entire structure.
@@ -77,6 +86,8 @@ enum {
 #define CKPT_HDR_STRING CKPT_HDR_STRING
 	CKPT_HDR_OBJREF,
 #define CKPT_HDR_OBJREF CKPT_HDR_OBJREF
+	CKPT_HDR_LSM_INFO,
+#define CKPT_HDR_LSM_INFO CKPT_HDR_LSM_INFO
 
 	CKPT_HDR_TREE = 101,
 #define CKPT_HDR_TREE CKPT_HDR_TREE
@@ -304,6 +315,11 @@ struct ckpt_hdr_tail {
 /* container configuration section header */
 struct ckpt_hdr_container {
 	struct ckpt_hdr h;
+	/*
+	 * the header is followed by the string:
+	 *   char lsm_name[SECURITY_NAME_MAX + 1]
+	 * plus the CKPT_HDR_LSM_INFO section
+	 */
 } __attribute__((aligned(8)));;
 
 /* task tree */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index b27312b..955a18c 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -21,6 +21,7 @@
 #include <linux/fs.h>
 #include <linux/ktime.h>
 #include <linux/wait.h>
+#include <linux/security.h>
 
 struct ckpt_stats {
 	int uts_ns;
@@ -38,6 +39,7 @@ struct ckpt_ctx {
 	struct task_struct *root_task;		/* [container] root task */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
 	struct task_struct *root_freezer;	/* [container] root task */
+	char lsm_name[SECURITY_NAME_MAX + 1];   /* security module at ckpt */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
diff --git a/include/linux/security.h b/include/linux/security.h
index 3158dd9..e45bd0f 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -145,6 +145,13 @@ extern int mmap_min_addr_handler(struct ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp, loff_t *ppos);
 #endif
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+
+void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
+int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+#endif
+
 #ifdef CONFIG_SECURITY
 
 struct security_mnt_opts {
@@ -1379,6 +1386,28 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
+ *	refuse restart (for instance) across policy changes.
+ *	The info is to be written as a an object of type CKPT_HDR_LSM_INFO.
+ *	@ctx is the checkpoint/restart context (see <linux/checkpoint_types.h>)
+ *	Return 0 on success, <0 on error.
+ *
  * Security hooks for Audit
  *
  * @audit_rule_init:
@@ -1661,6 +1690,11 @@ struct security_operations {
 	int (*inode_setsecctx)(struct dentry *dentry, void *ctx, u32 ctxlen);
 	int (*inode_getsecctx)(struct inode *inode, void **ctx, u32 *ctxlen);
 
+#ifdef CONFIG_CHECKPOINT
+	int (*may_restart) (struct ckpt_ctx *ctx);
+	int (*checkpoint_header) (struct ckpt_ctx *ctx);
+#endif
+
 #ifdef CONFIG_SECURITY_NETWORK
 	int (*unix_stream_connect) (struct socket *sock,
 				    struct socket *other, struct sock *newsk);
@@ -1913,6 +1947,14 @@ void security_release_secctx(char *secdata, u32 seclen);
 int security_inode_notifysecctx(struct inode *inode, void *ctx, u32 ctxlen);
 int security_inode_setsecctx(struct dentry *dentry, void *ctx, u32 ctxlen);
 int security_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen);
+
+#ifdef CONFIG_CHECKPOINT
+int security_may_restart(struct ckpt_ctx *ctx);
+int security_checkpoint_header(struct ckpt_ctx *ctx);
+#endif /* CONFIG_CHECKPOINT */
+
+char *security_get_lsm_name(void);
+
 #else /* CONFIG_SECURITY */
 struct security_mnt_opts {
 };
@@ -1935,6 +1977,12 @@ static inline int security_init(void)
 	return 0;
 }
 
+#define DEFAULT_LSM_NAME "lsm_none"
+static inline char *security_get_lsm_name(void)
+{
+	return DEFAULT_LSM_NAME;
+}
+
 static inline int security_ptrace_access_check(struct task_struct *child,
 					     unsigned int mode)
 {
@@ -2682,6 +2730,19 @@ static inline int security_inode_getsecctx(struct inode *inode, void **ctx, u32
 {
 	return -EOPNOTSUPP;
 }
+
+#ifdef CONFIG_CHECKPOINT
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
+
 #endif	/* CONFIG_SECURITY */
 
 #ifdef CONFIG_SECURITY_NETWORK
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index ccc5367..7a4f1ce 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -193,7 +193,18 @@ static int checkpoint_container(struct ckpt_ctx *ctx)
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 
-	return ret;
+	if (ret < 0)
+		return ret;
+
+	memset(ctx->lsm_name, 0, CHECKPOINT_LSM_NAME_MAX + 1);
+	strlcpy(ctx->lsm_name, security_get_lsm_name(),
+				CHECKPOINT_LSM_NAME_MAX + 1);
+	ret = ckpt_write_buffer(ctx, ctx->lsm_name,
+				CHECKPOINT_LSM_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
+	return security_checkpoint_header(ctx);
 }
 
 /* write the checkpoint trailer */
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 2314f7d..6605597 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -659,6 +659,42 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* read the LSM configuration section */
+static int restore_lsm(struct ckpt_ctx *ctx)
+{
+	int ret;
+	char *cur_lsm = security_get_lsm_name();
+
+	ret = _ckpt_read_buffer(ctx, ctx->lsm_name,
+				CHECKPOINT_LSM_NAME_MAX + 1);
+	if (ret < 0) {
+		ckpt_debug("Error %d reading lsm name\n", ret);
+		return ret;
+	}
+
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		goto skip_lsm;
+
+	if (strncmp(cur_lsm, ctx->lsm_name, CHECKPOINT_LSM_NAME_MAX + 1) != 0) {
+		ckpt_debug("c/r: checkpointed LSM %s, current is %s.\n",
+			ctx->lsm_name, cur_lsm);
+		return -EPERM;
+	}
+
+	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
+			strcmp(ctx->lsm_name, "default") != 0) {
+		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
+				ctx->lsm_name);
+		return -ENOSYS;
+	}
+
+skip_lsm:
+	ret = security_may_restart(ctx);
+	if (ret < 0)
+		ckpt_debug("security_may_restart returned %d\n", ret);
+	return ret;
+}
+
 /* read the container configuration section */
 static int restore_container(struct ckpt_ctx *ctx)
 {
@@ -670,6 +706,11 @@ static int restore_container(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 	ckpt_hdr_put(ctx, h);
 
+	/* read the LSM name and info which follow ("are a part of")
+	 * the ckpt_hdr_container */
+	ret = restore_lsm(ctx);
+	if (ret < 0)
+		ckpt_debug("Error %d on LSM configuration\n", ret);
 	return ret;
 }
 
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index a20ce9f..23073e4 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -175,6 +175,28 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
 }
 EXPORT_SYMBOL(ckpt_hdr_get_type);
 
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
  * restart operation, and persists until the operation is completed.
diff --git a/security/capability.c b/security/capability.c
index 4875142..72e4c00 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -852,6 +852,27 @@ static int cap_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen)
 {
 	return 0;
 }
+
+#ifdef CONFIG_CHECKPOINT
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
@@ -1064,6 +1085,10 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, inode_notifysecctx);
 	set_to_cap_if_null(ops, inode_setsecctx);
 	set_to_cap_if_null(ops, inode_getsecctx);
+#ifdef CONFIG_CHECKPOINT
+	set_to_cap_if_null(ops, may_restart);
+	set_to_cap_if_null(ops, checkpoint_header);
+#endif
 #ifdef CONFIG_SECURITY_NETWORK
 	set_to_cap_if_null(ops, unix_stream_connect);
 	set_to_cap_if_null(ops, unix_may_send);
diff --git a/security/security.c b/security/security.c
index 687c6fd..2d6ca52 100644
--- a/security/security.c
+++ b/security/security.c
@@ -17,6 +17,9 @@
 #include <linux/kernel.h>
 #include <linux/security.h>
 #include <linux/ima.h>
+#ifdef CONFIG_CHECKPOINT
+#include <linux/checkpoint.h>
+#endif
 
 /* Boot-time LSM user choice */
 static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1] =
@@ -133,6 +136,11 @@ int register_security(struct security_operations *ops)
 	return 0;
 }
 
+char *security_get_lsm_name(void)
+{
+	return security_ops->name;
+}
+
 /* Security operations */
 
 int security_ptrace_access_check(struct task_struct *child, unsigned int mode)
@@ -1042,6 +1050,24 @@ int security_inode_getsecctx(struct inode *inode, void **ctx, u32 *ctxlen)
 }
 EXPORT_SYMBOL(security_inode_getsecctx);
 
+#ifdef CONFIG_CHECKPOINT
+int security_may_restart(struct ckpt_ctx *ctx)
+{
+	/*
+	 * SECURITY_NAME_MAX is defined in linux/security.h,
+	 * CHECKPOINT_LSM_NAME_MAX in linux/checkpoint_hdr.h
+	 */
+	BUILD_BUG_ON(CHECKPOINT_LSM_NAME_MAX != SECURITY_NAME_MAX);
+
+	return security_ops->may_restart(ctx);
+}
+
+int security_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	return security_ops->checkpoint_header(ctx);
+}
+#endif
+
 #ifdef CONFIG_SECURITY_NETWORK
 
 int security_unix_stream_connect(struct socket *sock, struct socket *other,
-- 
1.6.3.3
