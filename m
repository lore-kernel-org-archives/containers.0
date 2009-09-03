From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [RFC PATCH 1/2] cr: lsm: provide hooks for an LSM to track policy
	changes
Date: Thu, 3 Sep 2009 17:28:24 -0500
Message-ID: <20090903222824.GB27377@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Casey Schaufler <casey@schaufler-ca.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

[ This applies on top of the previous LSM c/r patchset.  A corresponding
patch against mktree is needed as well. ]

Provide two new security_ hooks:
security_checkpoint_header:
	Gives the LSM a chance to write a checkpoint
	header object of type CKPT_HDR_LSM_INFO.  This
	can be any data the LSM deems fit, and can be
	written out using
		ckpt_write_obj_type(ctx, data, datalen, CKPT_HDR_LSM_INFO);

security_may_restart:
	Give the LSM an extra chance to refuse restart.  In
	particular the LSM may want to do this if the poicy has
	changed since checkpoint.  The checkpoint per-lsm data can
	be retrieved using

		ckpt_read_buf_type(ctx, MAX_INFO_LEN, CKPT_HDR_LSM_INFO);

	Note that the LSM should only look at that data if
	ctx->lsm_name is the current LSM's name.  Otherwise the
	info will be for another LSM (or the string "dummy").
	The hook will still be called, even if ctx->flags
	does not have RESTART_KEEP_LSM (meaning we do not restore
	checkpointed security labels) since the LSM may have other
	reasons to want to refuse restart.

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c        |    4 +++
 checkpoint/restart.c           |    4 +++
 checkpoint/sys.c               |   22 +++++++++++++++++
 include/linux/checkpoint.h     |    3 ++
 include/linux/checkpoint_hdr.h |    1 +
 include/linux/security.h       |   50 ++++++++++++++++++++++++++++++++++++++++
 security/capability.c          |   26 ++++++++++++++++++++
 security/security.c            |   14 +++++++++++
 8 files changed, 124 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 9dbb33c..a8e7483 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -257,6 +257,10 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	ret = security_checkpoint_header(ctx);
+	if (ret < 0)
+		return ret;
+
 	return checkpoint_write_header_arch(ctx);
 }
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index f51838b..3c248c4 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -446,6 +446,10 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 		}
 	}
 
+	ret = security_may_restart(ctx);
+	if (ret < 0)
+		goto out;
+
 	ret = restore_read_header_arch(ctx);
  out:
 	kfree(uts);
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 525182a..a510138 100644
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
index 3a800a6..bc96fcd 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -47,6 +47,7 @@
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
 #define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN | \
 					 RESTART_KEEP_LSM)
+#define CKPT_LSM_INFO_LEN 200
 
 extern void exit_checkpoint(struct task_struct *tsk);
 
@@ -57,6 +58,8 @@ extern void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int n);
 extern void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr);
 extern void *ckpt_hdr_get(struct ckpt_ctx *ctx, int n);
 extern void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int n, int type);
+extern int ckpt_write_dummy_lsm_info(struct ckpt_ctx *ctx);
+extern void ckpt_snarf_lsm_info(struct ckpt_ctx *ctx);
 
 extern int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
 extern int ckpt_write_obj_type(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 729ca33..78afcec 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -54,6 +54,7 @@ enum {
 	CKPT_HDR_STRING,
 	CKPT_HDR_OBJREF,
 	CKPT_HDR_SEC,
+	CKPT_HDR_LSM_INFO,
 
 	CKPT_HDR_TREE = 101,
 	CKPT_HDR_TASK,
diff --git a/include/linux/security.h b/include/linux/security.h
index 61f224f..d5b18c7 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -45,6 +45,10 @@
 struct ctl_table;
 struct audit_krule;
 
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_ctx;
+#endif
+
 /*
  * These functions are in security/capability.c and are used
  * as the default capabilities functions
@@ -1342,6 +1346,28 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@secdata contains the security context.
  *	@seclen contains the length of the security context.
  *
+ * Security hooks for Checkpoint/restart
+ * (In addition to *_get_ctx and *_restore)
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
@@ -1586,6 +1612,11 @@ struct security_operations {
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
@@ -1833,6 +1864,10 @@ int security_netlink_recv(struct sk_buff *skb, int cap);
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
+#ifdef CONFIG_CHECKPOINT
+int security_may_restart(struct ckpt_ctx *ctx);
+int security_checkpoint_header(struct ckpt_ctx *ctx);
+#endif /* CONFIG_CHECKPOINT */
 
 char *security_get_lsm_name(void);
 
@@ -2637,6 +2672,21 @@ static inline int security_secctx_to_secid(const char *secdata,
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
diff --git a/security/capability.c b/security/capability.c
index 28e6495..2577a3c 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -841,6 +841,28 @@ static void cap_release_secctx(char *secdata, u32 seclen)
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
@@ -1049,6 +1071,10 @@ void security_fixup_ops(struct security_operations *ops)
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
index d198d0c..2a182d5 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1004,6 +1004,20 @@ void security_release_secctx(char *secdata, u32 seclen)
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
-- 
1.6.1

