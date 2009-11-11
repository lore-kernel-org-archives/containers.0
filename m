From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/4] cr: add smack support to lsm c/r (v4)
Date: Wed, 11 Nov 2009 09:58:51 -0600
Message-ID: <1257955132-8398-5-git-send-email-serue@us.ibm.com>
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

This patch implements checkpoint and restore of Smack security
labels.  The rules are the same as in previous versions:

	1. when objects are created during restore() they are
	   automatically labeled with current_security().
	2. if there was a label checkpointed with the object,
	   and that label != current_security() (which is the
	   same as obj->security), then the object is relabeled
	   if the sys_restart() caller has CAP_MAC_ADMIN.
	   Otherwise we return -EPERM.

This has been tested by checkpointing tasks under labels
_, vs1, and vs2, and restarting from tasks under _, vs1,
and vs2, with and without CAP_MAC_ADMIN in the bounding
set, and with and without the '-k' (keep_lsm) flag to mktree.
Expected results:

	#shell 1:
	echo vs1 > /proc/self/attr/current
	ckpt > out
	echo vs2 > /proc/self/attr/current
	mktree -F /cgroup/2 < out
		(frozen)
	# shell 2:
	cat /proc/`pidof ckpt`/attr/current
		vs2
	echo THAWED > /cgroup/2/freezer.state
	# shell 1:
	mktree -k -F /cgroup/2 < out
		(frozen)
	# shell 2:
	cat /proc/`pidof ckpt`/attr/current
		vs1
	echo THAWED > /cgroup/2/freezer.state
	# shell 1:
	capsh --drop=cap_mac_admin --
	mktree -k -F /cgroup/2 < out
		(permission denied)

There are testcases in git://git.sr71.net/~hallyn/cr_tests.git
under cr_tests/smack, which automate the above (and pass).

Changelog:
	sep 3: add a version to smack lsm, accessible through
		/smack/version  (Casey and Serge)
	sep 10: rename xyz_get_ctx() to xyz_checkpoint()

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
---
 checkpoint/restart.c       |    1 +
 security/smack/smack.h     |    1 +
 security/smack/smack_lsm.c |  141 ++++++++++++++++++++++++++++++++++++++++++++
 security/smack/smackfs.c   |   83 ++++++++++++++++++++++++++
 4 files changed, 226 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index b2d0e3a..507b599 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -660,6 +660,7 @@ static int restore_lsm(struct ckpt_ctx *ctx)
 	}
 
 	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
+			strcmp(ctx->lsm_name, "smack") != 0 &&
 			strcmp(ctx->lsm_name, "default") != 0) {
 		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
 				ctx->lsm_name);
diff --git a/security/smack/smack.h b/security/smack/smack.h
index 243bec1..b5c1ce6 100644
--- a/security/smack/smack.h
+++ b/security/smack/smack.h
@@ -216,6 +216,7 @@ u32 smack_to_secid(const char *);
 extern int smack_cipso_direct;
 extern char *smack_net_ambient;
 extern char *smack_onlycap;
+extern char *smack_version;
 extern const char *smack_cipso_option;
 
 extern struct smack_known smack_known_floor;
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 0023182..1058de4 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -27,6 +27,7 @@
 #include <linux/udp.h>
 #include <linux/mutex.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/checkpoint.h>
 #include <net/netlabel.h>
 #include <net/cipso_ipv4.h>
 #include <linux/audit.h>
@@ -892,6 +893,28 @@ static int smack_file_permission(struct file *file, int mask)
 	return 0;
 }
 
+static inline char *smack_file_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_file_restore(struct file *file, char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	/* I think by definition, file->f_security == current_security
+	 * right now, but let's assume somehow it might not be */
+	if (newsmack == file->f_security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	file->f_security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_file_alloc_security - assign a file security blob
  * @file: the object
@@ -1079,6 +1102,27 @@ static int smack_file_receive(struct file *file)
  * Task hooks
  */
 
+static inline char *smack_cred_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	if (newsmack == cred->security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	cred->security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_cred_free - "free" task-level security credentials
  * @cred: the credentials in question
@@ -1742,6 +1786,26 @@ static int smack_msg_msg_alloc_security(struct msg_msg *msg)
 	return 0;
 }
 
+static inline char *smack_msg_msg_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	if (newsmack == msg->security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	msg->security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_msg_msg_free_security - Clear the security blob for msg_msg
  * @msg: the object
@@ -2175,6 +2239,26 @@ static void smack_ipc_getsecid(struct kern_ipc_perm *ipp, u32 *secid)
 	*secid = smack_to_secid(smack);
 }
 
+static inline char *smack_ipc_checkpoint(void *security)
+{
+	return kstrdup((char *)security, GFP_KERNEL);
+}
+
+static inline int smack_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	char *newsmack = smk_import(ctx, 0);
+
+	if (newsmack == NULL)
+		return -EINVAL;
+	if (newsmack == ipcp->security)
+		return 0;
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+	ipcp->security = newsmack;
+
+	return 0;
+}
+
 /**
  * smack_d_instantiate - Make sure the blob is correct on an inode
  * @opt_dentry: unused
@@ -3029,6 +3113,51 @@ static void smack_release_secctx(char *secdata, u32 seclen)
 {
 }
 
+#ifdef CONFIG_CHECKPOINT
+
+static int smack_may_restart(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr *chp;
+	char *saved_version;
+	int ret = 0;
+
+	chp = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
+	if (IS_ERR(chp))
+		return PTR_ERR(chp);
+
+	/*
+	 * After the checkpoint header comes the null terminated
+	 * Smack "policy" version. This will usually be the
+	 * floor label "_".
+	 */
+	saved_version = (char *)(chp + 1);
+
+	/*
+	 * Of course, it is possible that a "policy" version mismatch
+	 * is not considered threatening.
+	 */
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		goto skip;
+
+	if (strcmp(saved_version, smack_version) != 0) {
+		ckpt_debug("Smack version at checkpoint was"
+			   "\"%s\", now is \"%s\".\n",
+				saved_version, smack_version);
+		ret = -EINVAL;
+	}
+skip:
+	ckpt_hdr_put(ctx, chp);
+	return ret;
+}
+
+static int smack_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	return ckpt_write_obj_type(ctx, smack_version,
+					strlen(smack_version) + 1,
+					CKPT_HDR_LSM_INFO);
+}
+#endif
+
 struct security_operations smack_ops = {
 	.name =				"smack",
 
@@ -3064,6 +3193,8 @@ struct security_operations smack_ops = {
 	.inode_getsecid =		smack_inode_getsecid,
 
 	.file_permission = 		smack_file_permission,
+	.file_checkpoint = 		smack_file_checkpoint,
+	.file_restore = 		smack_file_restore,
 	.file_alloc_security = 		smack_file_alloc_security,
 	.file_free_security = 		smack_file_free_security,
 	.file_ioctl = 			smack_file_ioctl,
@@ -3073,6 +3204,8 @@ struct security_operations smack_ops = {
 	.file_send_sigiotask = 		smack_file_send_sigiotask,
 	.file_receive = 		smack_file_receive,
 
+	.cred_checkpoint =		smack_cred_checkpoint,
+	.cred_restore =			smack_cred_restore,
 	.cred_free =			smack_cred_free,
 	.cred_prepare =			smack_cred_prepare,
 	.cred_commit =			smack_cred_commit,
@@ -3094,8 +3227,12 @@ struct security_operations smack_ops = {
 
 	.ipc_permission = 		smack_ipc_permission,
 	.ipc_getsecid =			smack_ipc_getsecid,
+	.ipc_checkpoint =		smack_ipc_checkpoint,
+	.ipc_restore =			smack_ipc_restore,
 
 	.msg_msg_alloc_security = 	smack_msg_msg_alloc_security,
+	.msg_msg_checkpoint =		smack_msg_msg_checkpoint,
+	.msg_msg_restore =		smack_msg_msg_restore,
 	.msg_msg_free_security = 	smack_msg_msg_free_security,
 
 	.msg_queue_alloc_security = 	smack_msg_queue_alloc_security,
@@ -3155,6 +3292,10 @@ struct security_operations smack_ops = {
 	.secid_to_secctx = 		smack_secid_to_secctx,
 	.secctx_to_secid = 		smack_secctx_to_secid,
 	.release_secctx = 		smack_release_secctx,
+#ifdef CONFIG_CHECKPOINT
+	.may_restart =			smack_may_restart,
+	.checkpoint_header =		smack_checkpoint_header,
+#endif
 };
 
 
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index f83a809..0f0d5aa 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -42,6 +42,7 @@ enum smk_inos {
 	SMK_NETLBLADDR	= 8,	/* single label hosts */
 	SMK_ONLYCAP	= 9,	/* the only "capable" label */
 	SMK_LOGGING	= 10,	/* logging */
+	SMK_VERSION	= 11,	/* logging */
 };
 
 /*
@@ -51,6 +52,7 @@ static DEFINE_MUTEX(smack_list_lock);
 static DEFINE_MUTEX(smack_cipso_lock);
 static DEFINE_MUTEX(smack_ambient_lock);
 static DEFINE_MUTEX(smk_netlbladdr_lock);
+static DEFINE_MUTEX(smack_version_lock);
 
 /*
  * This is the "ambient" label for network traffic.
@@ -60,6 +62,16 @@ static DEFINE_MUTEX(smk_netlbladdr_lock);
 char *smack_net_ambient = smack_known_floor.smk_known;
 
 /*
+ * This is the policy version. In the interest of simplicity the
+ * policy version is a string that meets all of the requirements
+ * of a Smack label. This is enforced by the expedient of
+ * importing it like a label. The policy version is thus always
+ * also a valid label on the system. This may prove useful under
+ * some as yet undiscovered circumstance.
+ */
+char *smack_version = smack_known_floor.smk_known;
+
+/*
  * This is the level in a CIPSO header that indicates a
  * smack label is contained directly in the category set.
  * It can be reset via smackfs/direct
@@ -1255,6 +1267,75 @@ static const struct file_operations smk_logging_ops = {
 	.read		= smk_read_logging,
 	.write		= smk_write_logging,
 };
+
+#define SMK_VERSIONLEN 12
+/**
+ * smk_read_version - read() for /smack/version
+ * @filp: file pointer, not actually used
+ * @buf: where to put the result
+ * @cn: maximum to send along
+ * @ppos: where to start
+ *
+ * Returns number of bytes read or error code, as appropriate
+ */
+static ssize_t smk_read_version(struct file *filp, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	int rc;
+
+	if (*ppos != 0)
+		return 0;
+
+	mutex_lock(&smack_version_lock);
+
+	rc = simple_read_from_buffer(buf, count, ppos, smack_version,
+					strlen(smack_version) + 1);
+
+	mutex_unlock(&smack_version_lock);
+
+	return rc;
+}
+
+/**
+ * smk_write_version - write() for /smack/version
+ * @file: file pointer, not actually used
+ * @buf: where to get the data from
+ * @count: bytes sent
+ * @ppos: where to start
+ *
+ * Returns number of bytes written or error code, as appropriate
+ */
+static ssize_t smk_write_version(struct file *file, const char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	char *smack;
+	char in[SMK_LABELLEN];
+
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+
+	if (count >= SMK_LABELLEN)
+		return -EINVAL;
+
+	if (copy_from_user(in, buf, count) != 0)
+		return -EFAULT;
+
+	smack = smk_import(in, count);
+	if (smack == NULL)
+		return -EINVAL;
+
+	mutex_lock(&smack_version_lock);
+	smack_version = smack;
+	mutex_unlock(&smack_version_lock);
+
+	return count;
+}
+
+static const struct file_operations smk_version_ops = {
+	.read		= smk_read_version,
+	.write		= smk_write_version,
+};
+
 /**
  * smk_fill_super - fill the /smackfs superblock
  * @sb: the empty superblock
@@ -1287,6 +1368,8 @@ static int smk_fill_super(struct super_block *sb, void *data, int silent)
 			{"onlycap", &smk_onlycap_ops, S_IRUGO|S_IWUSR},
 		[SMK_LOGGING]	=
 			{"logging", &smk_logging_ops, S_IRUGO|S_IWUSR},
+		[SMK_VERSION]	=
+			{"version", &smk_version_ops, S_IRUGO|S_IWUSR},
 		/* last one */ {""}
 	};
 
-- 
1.6.1
