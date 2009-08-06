From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [kernel PATCH] cr: checkpoint the active LSM and add
	RESTART_KEEP_LSM flag
Date: Thu, 6 Aug 2009 11:19:16 -0500
Message-ID: <20090806161916.GA1607@us.ibm.com>
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

(this requires a matching patch for mktree, coming next)

The RESTART_KEEP_LSM flag indicates that the LSM should
attempt to reuse checkpointed security labels.  It is always
invalid when the LSM at restart differs from that at checkpoint.
It is currently only usable for capabilities.

(For capabilities, restart without RESTART_KEEP_LSM is technically
not implemented.  There actually might be a use case for that,
but the safety of it is dubious so for now we always re-create
checkpointed capability sets whether RESTART_KEEP_LSM is
specified or not)

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/checkpoint/readme.txt |   25 +++++++++++++++++++++++++
 checkpoint/checkpoint.c             |    6 ++++++
 checkpoint/restart.c                |   19 +++++++++++++++++++
 include/linux/checkpoint.h          |    5 +++--
 include/linux/checkpoint_hdr.h      |    3 ++-
 include/linux/checkpoint_types.h    |    2 ++
 include/linux/security.h            |    8 ++++++++
 security/security.c                 |    5 +++++
 8 files changed, 70 insertions(+), 3 deletions(-)

diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
index e84dc39..a60e001 100644
--- a/Documentation/checkpoint/readme.txt
+++ b/Documentation/checkpoint/readme.txt
@@ -328,6 +328,31 @@ So that's why we don't want CAP_SYS_ADMIN required up-front. That way
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
index c368270..ad0bbaa 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -248,6 +248,12 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
+	memset(ctx->lsm_name, 0, SECURITY_NAME_MAX + 1);
+	strlcpy(ctx->lsm_name, security_get_lsm_name(), SECURITY_NAME_MAX + 1);
+	ret = ckpt_write_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
+	if (ret < 0)
+		return ret;
+
 	return checkpoint_write_header_arch(ctx);
 }
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 65cafd9..56a69de 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -366,6 +366,25 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	ret = _ckpt_read_buffer(ctx, ctx->lsm_name, SECURITY_NAME_MAX + 1);
+	if (ret < 0)
+		goto out;
+	if (ctx->uflags & RESTART_KEEP_LSM) {
+		char *curlsm = security_get_lsm_name();
+		if (strncmp(curlsm, ctx->lsm_name, SECURITY_NAME_MAX + 1) != 0) {
+			pr_warning("c/r: checkpointed LSM %s, current is %s.\n",
+				ctx->lsm_name, curlsm);
+			return -EINVAL;
+		}
+		/* to be implemented later, per-lsm */
+		if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
+				strcmp(ctx->lsm_name, "default") !=0) {
+			pr_warning("c/r: RESTART_KEEP_LSM unsupported for %s\n",
+					ctx->lsm_name);
+			return -ENOSYS;
+		}
+	}
+
 	ret = restore_read_header_arch(ctx);
  out:
 	kfree(uts);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 45cf0fe..ec8de7a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -18,6 +18,7 @@
 /* restart user flags */
 #define RESTART_TASKSELF	0x1
 #define RESTART_FROZEN		0x2
+#define RESTART_KEEP_LSM	0x4
 
 #ifdef __KERNEL__
 #ifdef CONFIG_CHECKPOINT
@@ -29,7 +30,6 @@
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 
-
 /* ckpt_ctx: kflags */
 #define CKPT_CTX_CHECKPOINT_BIT		0
 #define CKPT_CTX_RESTART_BIT		1
@@ -43,7 +43,8 @@
 
 /* ckpt_ctx: uflags */
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
-#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
+#define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN | \
+					 RESTART_KEEP_LSM)
 
 extern void exit_checkpoint(struct task_struct *tsk);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4b85956..398ef71 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -160,10 +160,11 @@ struct ckpt_hdr_header {
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
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index e98251b..8943f5c 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -19,6 +19,7 @@
 #include <linux/fs.h>
 #include <linux/ktime.h>
 #include <linux/wait.h>
+#include <linux/security.h>
 
 struct ckpt_stats {
 	int uts_ns;
@@ -36,6 +37,7 @@ struct ckpt_ctx {
 	struct task_struct *root_task;		/* [container] root task */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
 	struct task_struct *root_freezer;	/* [container] root task */
+	char lsm_name[SECURITY_NAME_MAX + 1];   /* security module at ckpt */
 
 	unsigned long kflags;	/* kerenl flags */
 	unsigned long uflags;	/* user flags */
diff --git a/include/linux/security.h b/include/linux/security.h
index 5eff459..f1033a4 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1776,6 +1776,8 @@ int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
 
+char *security_get_lsm_name(void);
+
 #else /* CONFIG_SECURITY */
 struct security_mnt_opts {
 };
@@ -1798,6 +1800,12 @@ static inline int security_init(void)
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
diff --git a/security/security.c b/security/security.c
index dc7674f..3829156 100644
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
-- 
1.6.1
