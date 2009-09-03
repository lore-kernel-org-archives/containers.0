From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [RFC PATCH 2/2] cr: debug security_checkpoint_header and
	security_may_restart
Date: Thu, 3 Sep 2009 17:28:53 -0500
Message-ID: <20090903222853.GA27556@us.ibm.com>
References: <20090903222824.GB27377@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090903222824.GB27377@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Casey Schaufler <casey@schaufler-ca.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>
List-Id: containers.vger.kernel.org

This patch, for debugging only, introduces a silly admin-controlled
'policy version' for smack.  By default the version is 1.  An
admin (with CAP_MAC_ADMIN) can change it by echoing a new value
into /smack/version.

It then defines security_checkpoint_header() to add this 'policy
version' into the checkpoint header, and defines security_may_restart()
to refuse restart if both:
	1. the caller asked for RESTART_KEEP_LSM
and
	2. the checkpointed version was different from the current.

This of course is easy enough to test by doing

	echo 1 > /smack/version
	ckpt > out
	mktree < out
		succeed
	mktree -k < out
		succeed
	echo 2 > /smack/version
	mktree < out
		succeed
	mktree -k < out
		fail

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 security/smack/smack_lsm.c |   46 +++++++++++++++++++++++++++
 security/smack/smackfs.c   |   75 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 121 insertions(+), 0 deletions(-)

diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 279fdce..f0d4a08 100644
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
@@ -3111,6 +3112,47 @@ static void smack_release_secctx(char *secdata, u32 seclen)
 {
 }
 
+#ifdef CONFIG_CHECKPOINT
+extern int smack_version;
+
+static int smack_may_restart(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr *h;
+	char *smackv;
+	int v = 0, slen, ret;
+
+	h = ckpt_read_buf_type(ctx, CKPT_LSM_INFO_LEN, CKPT_HDR_LSM_INFO);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (strcmp(ctx->lsm_name, "smack") != 0)
+		return 0;
+
+	smackv = (char *) (h + 1);
+	slen = h->len - sizeof(*h);
+	if (smackv[slen-1] != '\0')
+		smackv[slen-1] = '\0';
+	ret = sscanf(smackv, "%d", &v);
+	ckpt_hdr_put(ctx, h);
+	if (!(ctx->uflags & RESTART_KEEP_LSM))
+		return 0;
+	if (ret != 1 || v != smack_version) {
+		ckpt_debug("Smack version at checkpoint was %d, now is %d\n",
+			v, smack_version);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int smack_checkpoint_header(struct ckpt_ctx *ctx)
+{
+	char smackv[10];
+	sprintf(smackv, "%d", smack_version);
+	return ckpt_write_obj_type(ctx, smackv, strlen(smackv)+1,
+				  CKPT_HDR_LSM_INFO);
+}
+#endif
+
 struct security_operations smack_ops = {
 	.name =				"smack",
 
@@ -3245,6 +3287,10 @@ struct security_operations smack_ops = {
 	.secid_to_secctx = 		smack_secid_to_secctx,
 	.secctx_to_secid = 		smack_secctx_to_secid,
 	.release_secctx = 		smack_release_secctx,
+#ifdef CONFIG_CHECKPOINT
+	.may_restart =			smack_may_restart,
+	.checkpoint_header =		smack_checkpoint_header,
+#endif
 };
 
 
diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index f83a809..7b20ad9 100644
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
@@ -60,6 +62,11 @@ static DEFINE_MUTEX(smk_netlbladdr_lock);
 char *smack_net_ambient = smack_known_floor.smk_known;
 
 /*
+ * this is the policy version, a simple integer
+ */
+int smack_version = 1;
+
+/*
  * This is the level in a CIPSO header that indicates a
  * smack label is contained directly in the category set.
  * It can be reset via smackfs/direct
@@ -1255,6 +1262,72 @@ static const struct file_operations smk_logging_ops = {
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
+	char temp[SMK_VERSIONLEN];
+
+	if (*ppos != 0)
+		return 0;
+
+	mutex_lock(&smack_version_lock);
+	sprintf(temp, "%d\n", smack_version);
+	mutex_unlock(&smack_version_lock);
+
+	return simple_read_from_buffer(buf, count, ppos, temp, strlen(temp));
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
+	char in[SMK_VERSIONLEN];
+	int tmp, ret;
+
+	if (!capable(CAP_MAC_ADMIN))
+		return -EPERM;
+
+	if (count >= SMK_VERSIONLEN)
+		return -EINVAL;
+
+	if (copy_from_user(in, buf, count) != 0)
+		return -EFAULT;
+
+	in[count-1] = '\0';
+	ret = sscanf(in, "%d", &tmp);
+	if (ret != 1)
+		return -EINVAL;
+	mutex_lock(&smack_version_lock);
+	smack_version = tmp;
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
@@ -1287,6 +1360,8 @@ static int smk_fill_super(struct super_block *sb, void *data, int silent)
 			{"onlycap", &smk_onlycap_ops, S_IRUGO|S_IWUSR},
 		[SMK_LOGGING]	=
 			{"logging", &smk_logging_ops, S_IRUGO|S_IWUSR},
+		[SMK_VERSION]	=
+			{"version", &smk_version_ops, S_IRUGO|S_IWUSR},
 		/* last one */ {""}
 	};
 
-- 
1.6.1

