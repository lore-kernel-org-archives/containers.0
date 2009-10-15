From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] add lsm name and lsm_info (policy header) to container info
Date: Thu, 15 Oct 2009 15:37:21 -0500
Message-ID: <20091015203721.GA5030@us.ibm.com>
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

The LSM name is 'selinux', 'smack', 'tomoyo', or 'dummy'.  We
add that to the container configuration section.  We also add
a LSM policy configuration section.  That is placed after the LSM
name.  It is written by the LSM in security_checkpoint_header(),
called during checkpoint container(), and read by the LSM during
security_may_restart(), which is called from restore_lsm() in
restore_container().

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/checkpoint.c          |   13 ++++++++-
 checkpoint/restart.c             |   41 ++++++++++++++++++++++++++
 checkpoint/sys.c                 |   21 +++++++++++++
 include/linux/checkpoint.h       |    7 ++++-
 include/linux/checkpoint_hdr.h   |   16 ++++++++++
 include/linux/checkpoint_types.h |    2 +
 include/linux/security.h         |   58 ++++++++++++++++++++++++++++++++++++++
 security/capability.c            |   24 +++++++++++++++
 security/security.c              |   26 +++++++++++++++++
 9 files changed, 206 insertions(+), 2 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 6eb8f3b..b8c323c 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -366,7 +366,18 @@ static int checkpoint_container(struct ckpt_ctx *ctx)
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
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 32a9fc5..0cd721c 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -624,6 +624,42 @@ static int restore_read_header(struct ckpt_ctx *ctx)
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
@@ -635,6 +671,11 @@ static int restore_container(struct ckpt_ctx *ctx)
 		return PTR_ERR(h);
 	ckpt_hdr_put(ctx, h);
 
+	/* read the LSM name and info which follow ("are a part of")
+	 * the ckpt_hdr_container */
+	ret = restore_lsm(ctx);
+	if (ret < 0)
+		ckpt_debug("Error %d on LSM configuration\n", ret);
 	return ret;
 }
 
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 260a1ee..5b65eb0 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -169,6 +169,27 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
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
 
 /*
  * Helpers to manage c/r contexts: allocated for each checkpoint and/or
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 914176c..d62631a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  3
+#define CHECKPOINT_VERSION  4
 
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
index ff2e4aa..636e189 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -27,6 +27,15 @@
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
@@ -71,6 +80,8 @@ enum {
 #define CKPT_HDR_STRING CKPT_HDR_STRING
 	CKPT_HDR_OBJREF,
 #define CKPT_HDR_OBJREF CKPT_HDR_OBJREF
+	CKPT_HDR_LSM_INFO,
+#define CKPT_HDR_LSM_INFO CKPT_HDR_LSM_INFO
 
 	CKPT_HDR_TREE = 101,
 #define CKPT_HDR_TREE CKPT_HDR_TREE
@@ -252,6 +263,11 @@ struct ckpt_const {
 /* container configuration section header */
 struct ckpt_hdr_container {
 	struct ckpt_hdr h;
+	/*
+	 * the header is followed by the string:
+	 *   char lsm_name[SECURITY_NAME_MAX + 1]
+	 * plus the CKPT_HDR_LSM_INFO section
+	 */
 };
 
 /* checkpoint image header */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index fa57cdc..b7d3053 100644
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
diff --git a/include/linux/security.h b/include/linux/security.h
index 1f16eea..99e4ebc 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -136,6 +136,13 @@ static inline unsigned long round_hint_to_min(unsigned long hint)
 extern int mmap_min_addr_handler(struct ctl_table *table, int write, struct file *filp,
 				 void __user *buffer, size_t *lenp, loff_t *ppos);
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+
+void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
+int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+#endif
+
 #ifdef CONFIG_SECURITY
 
 struct security_mnt_opts {
@@ -1320,6 +1327,28 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -1556,6 +1585,11 @@ struct security_operations {
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
@@ -1796,6 +1830,12 @@ int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
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
 };
@@ -1818,6 +1858,12 @@ static inline int security_init(void)
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
@@ -2537,6 +2583,18 @@ static inline int security_secctx_to_secid(const char *secdata,
 static inline void security_release_secctx(char *secdata, u32 seclen)
 {
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
 #endif	/* CONFIG_SECURITY */
 
 #ifdef CONFIG_SECURITY_NETWORK
diff --git a/security/capability.c b/security/capability.c
index 88f752e..23026e2 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -792,6 +792,26 @@ static void cap_release_secctx(char *secdata, u32 seclen)
 {
 }
 
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
@@ -992,6 +1012,10 @@ void security_fixup_ops(struct security_operations *ops)
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
index dc7674f..e4fa91a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -16,6 +16,9 @@
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/security.h>
+#ifdef CONFIG_CHECKPOINT
+#include <linux/checkpoint.h>
+#endif
 
 /* Boot-time LSM user choice */
 static __initdata char chosen_lsm[SECURITY_NAME_MAX + 1];
@@ -122,6 +125,11 @@ int register_security(struct security_operations *ops)
 	return 0;
 }
 
+char *security_get_lsm_name(void)
+{
+	return security_ops->name;
+}
+
 /* Security operations */
 
 int security_ptrace_may_access(struct task_struct *child, unsigned int mode)
@@ -959,6 +967,24 @@ void security_release_secctx(char *secdata, u32 seclen)
 }
 EXPORT_SYMBOL(security_release_secctx);
 
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
1.6.1
