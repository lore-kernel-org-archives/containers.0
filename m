From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH linux-cr] cr: add selinux support (v6)
Date: Wed, 9 Dec 2009 11:45:57 -0600
Message-ID: <20091209174556.GA23966@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Documentation/checkpoint/readme.txt begins:
"""
Application checkpoint/restart is the ability to save the state
of a running application so that it can later resume its execution
from the time at which it was checkpointed.
"""

This patch adds the ability to checkpoint and restore selinux
contexts for tasks, open files, and sysvipc objects.  Contexts
are checkpointed as strings.  For tasks and files, where a security
struct actually points to several contexts, all contexts are
written out in one string, separated by ':::'.

The default behaviors are to checkpoint contexts, but not to
restore them.  To attempt to restore them, sys_restart() must
be given the RESTART_KEEP_LSM flag.  If this is given then
the caller of sys_restart() must have the new 'restore' permission
to the target objclass, or for instance PROCESS__SETFSCREATE to
itself to specify a create_sid.

There are some tests under cr_tests/selinux at
git://git.sr71.net/~hallyn/cr_tests.git.

A corresponding simple refpolicy (and /usr/share/selinux/devel/include)
patch is needed.

The programs to checkpoint and restart (called 'checkpoint' and
'restart') come from git://git.ncl.cs.columbia.edu/pub/git/user-cr.git.
This patch applies against the checkpoint/restart-enabled kernel
tree at git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git/.

Changelog:
	Dec 09: update to use common_audit_data.
	oct 09: fix memory overrun in selinux_cred_checkpoint.
	oct 02: (Stephen Smalley suggestions):
		1. s/__u32/u32/
		2. enable the fown sid restoration
		3. use process_restore to authorize resetting osid
		4. don't make new hooks inline.
	oct 01: Remove some debugging that is redundant with
		avc log data.
	sep 10: (Most addressing suggestions by Stephen Smalley)
		1. change xyz_get_ctx() to xyz_checkpoint().
		2. check entrypoint permission on cred_restore
		3. always dec context length by 1
		4. don't allow SECSID_NULL when that's not valid
		5. when SECSID_NULL is valid, restore it
		6. c/r task->osid
		7. Just print nothing instead of 'null' for SECSID_NULL
		8. sids are __u32, as are lenghts passed to sid_to_context.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c                         |    1 +
 security/selinux/hooks.c                     |  366 ++++++++++++++++++++++++++
 security/selinux/include/av_perm_to_string.h |    5 +
 security/selinux/include/av_permissions.h    |    5 +
 4 files changed, 377 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 88d791b..cc8e68d 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -665,6 +665,7 @@ static int restore_lsm(struct ckpt_ctx *ctx)
 
 	if (strcmp(ctx->lsm_name, "lsm_none") != 0 &&
 			strcmp(ctx->lsm_name, "smack") != 0 &&
+			strcmp(ctx->lsm_name, "selinux") != 0 &&
 			strcmp(ctx->lsm_name, "default") != 0) {
 		ckpt_debug("c/r: RESTART_KEEP_LSM unsupported for %s\n",
 				ctx->lsm_name);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index bb230d5..cbcdea1 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -76,6 +76,7 @@
 #include <linux/selinux.h>
 #include <linux/mutex.h>
 #include <linux/posix-timers.h>
+#include <linux/checkpoint.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -2979,6 +2980,104 @@ static int selinux_file_permission(struct file *file, int mask)
 	return selinux_revalidate_file_permission(file, mask);
 }
 
+/*
+ * for file context, we print both the fsec->sid and fsec->fown_sid
+ * as string representations, separated by ':::'
+ * We don't touch isid - if you wanted that set you shoulda set up the
+ * fs correctly.
+ */
+static char *selinux_file_checkpoint(void *security)
+{
+	struct file_security_struct *fsec = security;
+	char *s1 = NULL, *s2 = NULL, *sfull;
+	u32 len1, len2, lenfull;
+	int ret;
+
+	if (fsec->sid == 0 || fsec->fown_sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(fsec->sid, &s1, &len1);
+	if (ret)
+		return ERR_PTR(ret);
+	len1--;
+	ret = security_sid_to_context(fsec->fown_sid, &s2, &len2);
+	if (ret) {
+		kfree(s1);
+		return ERR_PTR(ret);
+	}
+	len2--;
+	lenfull = len1 + len2 + 3;
+	sfull = kmalloc(lenfull + 1, GFP_KERNEL);
+	if (!sfull) {
+		sfull = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	sfull[lenfull] = '\0';
+	sprintf(sfull, "%s:::%s", s1, s2);
+
+out:
+	kfree(s1);
+	kfree(s2);
+	return sfull;
+}
+
+static int selinux_file_restore(struct file *file, char *ctx)
+{
+	char *s1, *s2;
+	u32 sid1 = 0, sid2 = 0;
+	int ret = -EINVAL;
+	struct file_security_struct *fsec = file->f_security;
+
+	/*
+	 * Objhash made sure the string is null-terminated.
+	 * We make a copy so we can mangle it.
+	 */
+	s1 = kstrdup(ctx, GFP_KERNEL);
+	if (!s1)
+		return -ENOMEM;
+	s2 = strstr(s1, ":::");
+	if (!s2)
+		goto out;
+
+	*s2 = '\0';
+	s2 += 3;
+	if (*s2 == '\0')
+		goto out;
+
+	/* SECSID_NULL is not valid for file sids */
+	if (strlen(s1) == 0 || strlen(s2) == 0)
+		goto out;
+
+	ret = security_context_to_sid(s1, strlen(s1), &sid1);
+	if (ret)
+		goto out;
+	ret = security_context_to_sid(s2, strlen(s2), &sid2);
+	if (ret)
+		goto out;
+
+	if (sid1 && fsec->sid != sid1) {
+		ret = avc_has_perm(current_sid(), sid1, SECCLASS_FILE,
+					FILE__RESTORE, NULL);
+		if (ret)
+			goto out;
+		fsec->sid = sid1;
+	}
+
+	if (sid2 && fsec->fown_sid != sid2) {
+		ret = avc_has_perm(current_sid(), sid2, SECCLASS_FILE,
+				FILE__FOWN_RESTORE, NULL);
+		if (ret)
+			goto out;
+	       fsec->fown_sid = sid2;
+	}
+
+	ret = 0;
+
+out:
+	kfree(s1);
+	return ret;
+}
+
 static int selinux_file_alloc_security(struct file *file)
 {
 	return file_alloc_security(file);
@@ -3237,6 +3336,186 @@ static int selinux_task_create(unsigned long clone_flags)
 	return current_has_perm(current, PROCESS__FORK);
 }
 
+#define NUMTASKSIDS 6
+/*
+ * for cred context, we print:
+ *   osid, sid, exec_sid, create_sid, keycreate_sid, sockcreate_sid;
+ * as string representations, separated by ':::'
+ */
+static char *selinux_cred_checkpoint(void *security)
+{
+	struct task_security_struct *tsec = security;
+	char *stmp, *sfull = NULL;
+	u32 slen, runlen;
+	int i, ret;
+	u32 sids[NUMTASKSIDS] = { tsec->osid, tsec->sid, tsec->exec_sid,
+		tsec->create_sid, tsec->keycreate_sid, tsec->sockcreate_sid };
+
+	if (sids[0] == 0 || sids[1] == 0)
+		/* SECSID_NULL is not valid for osid or sid */
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(sids[0], &sfull, &runlen);
+	if (ret)
+		return ERR_PTR(ret);
+	runlen--;
+
+	for (i = 1; i < NUMTASKSIDS; i++) {
+		if (sids[i] == 0) {
+			stmp = NULL;
+			slen = 0;
+		} else {
+			ret = security_sid_to_context(sids[i], &stmp, &slen);
+			if (ret) {
+				kfree(sfull);
+				return ERR_PTR(ret);
+			}
+			slen--;
+		}
+		/* slen + runlen + ':::' + \0 */
+		sfull = krealloc(sfull, slen + runlen + 3 + 1,
+				 GFP_KERNEL);
+		if (!sfull) {
+			kfree(stmp);
+			return ERR_PTR(-ENOMEM);
+		}
+		sprintf(sfull+runlen, ":::%s", stmp ? stmp : "");
+		runlen += slen + 3;
+		kfree(stmp);
+	}
+
+	return sfull;
+}
+
+static inline int credrestore_nullvalid(int which)
+{
+	int valid_array[NUMTASKSIDS] = {
+		0, /* task osid */
+		0, /* task sid */
+		1, /* exec sid */
+		1, /* create sid */
+		1, /* keycreate_sid */
+		1, /* sockcreate_sid */
+	};
+
+	return valid_array[which];
+}
+
+static int selinux_cred_restore(struct file *file, struct cred *cred,
+					char *ctx)
+{
+	char *s, *s1, *s2 = NULL;
+	int ret = -EINVAL;
+	struct task_security_struct *tsec = cred->security;
+	int i;
+	u32 sids[NUMTASKSIDS];
+	struct inode *ctx_inode = file->f_dentry->d_inode;
+	struct common_audit_data ad;
+
+	/*
+	 * objhash made sure the string is null-terminated
+	 * now we want our own copy so we can chop it up with \0's
+	 */
+	s = kstrdup(ctx, GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+
+	s1 = s;
+	for (i = 0; i < NUMTASKSIDS; i++) {
+		if (i < NUMTASKSIDS-1) {
+			ret = -EINVAL;
+			s2 = strstr(s1, ":::");
+			if (!s2)
+				goto out;
+			*s2 = '\0';
+			s2 += 3;
+		}
+		if (strlen(s1) == 0) {
+			ret = -EINVAL;
+			if (credrestore_nullvalid(i))
+				sids[i] = 0;
+			else
+				goto out;
+		} else {
+			ret = security_context_to_sid(s1, strlen(s1), &sids[i]);
+			if (ret)
+				goto out;
+		}
+		s1 = s2;
+	}
+
+	/*
+	 * Check that these transitions are allowed, and effect them.
+	 * XXX: Do these checks suffice?
+	 */
+	if (tsec->osid != sids[0]) {
+		ret = avc_has_perm(current_sid(), sids[0], SECCLASS_PROCESS,
+					PROCESS__RESTORE, NULL);
+		if (ret)
+			goto out;
+		 tsec->osid = sids[0];
+	}
+
+	if (tsec->sid != sids[1]) {
+		struct inode_security_struct *isec;
+		ret = avc_has_perm(current_sid(), sids[1], SECCLASS_PROCESS,
+					PROCESS__RESTORE, NULL);
+		if (ret)
+			goto out;
+
+		/* check whether checkpoint file type is a valid entry
+		 * point to the new domain:  we may want a specific
+		 * 'restore_entrypoint' permission for this, but let's
+		 * see if just entrypoint is deemed sufficient
+		 */
+
+		COMMON_AUDIT_DATA_INIT(&ad, FS);
+		ad.u.fs.path = file->f_path;
+
+		isec = ctx_inode->i_security;
+		ret = avc_has_perm(sids[1], isec->sid, SECCLASS_FILE,
+				FILE__ENTRYPOINT, &ad);
+		if (ret)
+			goto out;
+		/* TODO: do we need to check for shared state? */
+		tsec->sid = sids[1];
+	}
+
+	ret = -EPERM;
+	if (sids[2] != tsec->exec_sid) {
+		if (!current_has_perm(current, PROCESS__SETEXEC))
+			goto out;
+		tsec->exec_sid = sids[2];
+	}
+
+	if (sids[3] != tsec->create_sid) {
+		if (!current_has_perm(current, PROCESS__SETFSCREATE))
+			goto out;
+		tsec->create_sid = sids[3];
+	}
+
+	if (tsec->keycreate_sid != sids[4]) {
+		if (!current_has_perm(current, PROCESS__SETKEYCREATE))
+			goto out;
+		if (!may_create_key(sids[4], current))
+			goto out;
+		tsec->keycreate_sid = sids[4];
+	}
+
+	if (tsec->sockcreate_sid != sids[5]) {
+		if (!current_has_perm(current, PROCESS__SETSOCKCREATE))
+			goto out;
+		tsec->sockcreate_sid = sids[5];
+	}
+
+	ret = 0;
+
+out:
+	kfree(s);
+	return ret;
+}
+
+
 /*
  * allocate the SELinux part of blank credentials
  */
@@ -4762,6 +5041,44 @@ static void ipc_free_security(struct kern_ipc_perm *perm)
 	kfree(isec);
 }
 
+static char *selinux_msg_msg_checkpoint(void *security)
+{
+	struct msg_security_struct *msec = security;
+	char *s;
+	u32 len;
+	int ret;
+
+	if (msec->sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(msec->sid, &s, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return s;
+}
+
+static int selinux_msg_msg_restore(struct msg_msg *msg, char *ctx)
+{
+	struct msg_security_struct *msec = msg->security;
+	int ret;
+	u32 sid = 0;
+
+	ret = security_context_to_sid(ctx, strlen(ctx), &sid);
+	if (ret)
+		return ret;
+
+	if (msec->sid == sid)
+		return 0;
+
+	ret = avc_has_perm(current_sid(), sid, SECCLASS_MSG,
+				MSG__RESTORE, NULL);
+	if (ret)
+		return ret;
+
+	msec->sid = sid;
+	return 0;
+}
+
 static int msg_msg_alloc_security(struct msg_msg *msg)
 {
 	struct msg_security_struct *msec;
@@ -5165,6 +5482,47 @@ static void selinux_ipc_getsecid(struct kern_ipc_perm *ipcp, u32 *secid)
 	*secid = isec->sid;
 }
 
+static char *selinux_ipc_checkpoint(void *security)
+{
+	struct ipc_security_struct *isec = security;
+	char *s;
+	u32 len;
+	int ret;
+
+	if (isec->sid == 0)
+		return ERR_PTR(-EINVAL);
+
+	ret = security_sid_to_context(isec->sid, &s, &len);
+	if (ret)
+		return ERR_PTR(ret);
+	return s;
+}
+
+static int selinux_ipc_restore(struct kern_ipc_perm *ipcp, char *ctx)
+{
+	struct ipc_security_struct *isec = ipcp->security;
+	int ret;
+	u32 sid = 0;
+	struct common_audit_data ad;
+
+	ret = security_context_to_sid(ctx, strlen(ctx), &sid);
+	if (ret)
+		return ret;
+
+	if (isec->sid == sid)
+		return 0;
+
+	COMMON_AUDIT_DATA_INIT(&ad, IPC);
+	ad.u.ipc_id = ipcp->key;
+	ret = avc_has_perm(current_sid(), sid, SECCLASS_IPC,
+				IPC__RESTORE, &ad);
+	if (ret)
+		return ret;
+
+	isec->sid = sid;
+	return 0;
+}
+
 static void selinux_d_instantiate(struct dentry *dentry, struct inode *inode)
 {
 	if (inode)
@@ -5512,6 +5870,8 @@ static struct security_operations selinux_ops = {
 	.inode_getsecid =		selinux_inode_getsecid,
 
 	.file_permission =		selinux_file_permission,
+	.file_checkpoint =		selinux_file_checkpoint,
+	.file_restore =			selinux_file_restore,
 	.file_alloc_security =		selinux_file_alloc_security,
 	.file_free_security =		selinux_file_free_security,
 	.file_ioctl =			selinux_file_ioctl,
@@ -5527,6 +5887,8 @@ static struct security_operations selinux_ops = {
 
 	.task_create =			selinux_task_create,
 	.cred_alloc_blank =		selinux_cred_alloc_blank,
+	.cred_checkpoint =		selinux_cred_checkpoint,
+	.cred_restore =			selinux_cred_restore,
 	.cred_free =			selinux_cred_free,
 	.cred_prepare =			selinux_cred_prepare,
 	.cred_transfer =		selinux_cred_transfer,
@@ -5550,8 +5912,12 @@ static struct security_operations selinux_ops = {
 
 	.ipc_permission =		selinux_ipc_permission,
 	.ipc_getsecid =			selinux_ipc_getsecid,
+	.ipc_checkpoint =		selinux_ipc_checkpoint,
+	.ipc_restore =			selinux_ipc_restore,
 
 	.msg_msg_alloc_security =	selinux_msg_msg_alloc_security,
+	.msg_msg_checkpoint =		selinux_msg_msg_checkpoint,
+	.msg_msg_restore =		selinux_msg_msg_restore,
 	.msg_msg_free_security =	selinux_msg_msg_free_security,
 
 	.msg_queue_alloc_security =	selinux_msg_queue_alloc_security,
diff --git a/security/selinux/include/av_perm_to_string.h b/security/selinux/include/av_perm_to_string.h
index 2b683ad..c5a1838 100644
--- a/security/selinux/include/av_perm_to_string.h
+++ b/security/selinux/include/av_perm_to_string.h
@@ -19,6 +19,8 @@
    S_(SECCLASS_FILE, FILE__ENTRYPOINT, "entrypoint")
    S_(SECCLASS_FILE, FILE__EXECMOD, "execmod")
    S_(SECCLASS_FILE, FILE__OPEN, "open")
+   S_(SECCLASS_FILE, FILE__RESTORE, "restore")
+   S_(SECCLASS_FILE, FILE__FOWN_RESTORE, "fown_restore")
    S_(SECCLASS_CHR_FILE, CHR_FILE__EXECUTE_NO_TRANS, "execute_no_trans")
    S_(SECCLASS_CHR_FILE, CHR_FILE__ENTRYPOINT, "entrypoint")
    S_(SECCLASS_CHR_FILE, CHR_FILE__EXECMOD, "execmod")
@@ -88,9 +90,11 @@
    S_(SECCLASS_PROCESS, PROCESS__EXECHEAP, "execheap")
    S_(SECCLASS_PROCESS, PROCESS__SETKEYCREATE, "setkeycreate")
    S_(SECCLASS_PROCESS, PROCESS__SETSOCKCREATE, "setsockcreate")
+   S_(SECCLASS_PROCESS, PROCESS__RESTORE, "restore")
    S_(SECCLASS_MSGQ, MSGQ__ENQUEUE, "enqueue")
    S_(SECCLASS_MSG, MSG__SEND, "send")
    S_(SECCLASS_MSG, MSG__RECEIVE, "receive")
+   S_(SECCLASS_MSG, MSG__RESTORE, "restore")
    S_(SECCLASS_SHM, SHM__LOCK, "lock")
    S_(SECCLASS_SECURITY, SECURITY__COMPUTE_AV, "compute_av")
    S_(SECCLASS_SECURITY, SECURITY__COMPUTE_CREATE, "compute_create")
@@ -108,6 +112,7 @@
    S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_MOD, "syslog_mod")
    S_(SECCLASS_SYSTEM, SYSTEM__SYSLOG_CONSOLE, "syslog_console")
    S_(SECCLASS_SYSTEM, SYSTEM__MODULE_REQUEST, "module_request")
+   S_(SECCLASS_IPC, IPC__RESTORE, "restore")
    S_(SECCLASS_CAPABILITY, CAPABILITY__CHOWN, "chown")
    S_(SECCLASS_CAPABILITY, CAPABILITY__DAC_OVERRIDE, "dac_override")
    S_(SECCLASS_CAPABILITY, CAPABILITY__DAC_READ_SEARCH, "dac_read_search")
diff --git a/security/selinux/include/av_permissions.h b/security/selinux/include/av_permissions.h
index 0546d61..77ad07b 100644
--- a/security/selinux/include/av_permissions.h
+++ b/security/selinux/include/av_permissions.h
@@ -101,6 +101,8 @@
 #define FILE__ENTRYPOINT                          0x00040000UL
 #define FILE__EXECMOD                             0x00080000UL
 #define FILE__OPEN                                0x00100000UL
+#define FILE__RESTORE                             0x00200000UL
+#define FILE__FOWN_RESTORE                        0x00400000UL
 #define LNK_FILE__IOCTL                           0x00000001UL
 #define LNK_FILE__READ                            0x00000002UL
 #define LNK_FILE__WRITE                           0x00000004UL
@@ -475,6 +477,7 @@
 #define PROCESS__EXECHEAP                         0x08000000UL
 #define PROCESS__SETKEYCREATE                     0x10000000UL
 #define PROCESS__SETSOCKCREATE                    0x20000000UL
+#define PROCESS__RESTORE	                  0x40000000UL
 #define IPC__CREATE                               0x00000001UL
 #define IPC__DESTROY                              0x00000002UL
 #define IPC__GETATTR                              0x00000004UL
@@ -484,6 +487,7 @@
 #define IPC__ASSOCIATE                            0x00000040UL
 #define IPC__UNIX_READ                            0x00000080UL
 #define IPC__UNIX_WRITE                           0x00000100UL
+#define IPC__RESTORE                              0x00000200UL
 #define SEM__CREATE                               0x00000001UL
 #define SEM__DESTROY                              0x00000002UL
 #define SEM__GETATTR                              0x00000004UL
@@ -505,6 +509,7 @@
 #define MSGQ__ENQUEUE                             0x00000200UL
 #define MSG__SEND                                 0x00000001UL
 #define MSG__RECEIVE                              0x00000002UL
+#define MSG__RESTORE                              0x00000004UL
 #define SHM__CREATE                               0x00000001UL
 #define SHM__DESTROY                              0x00000002UL
 #define SHM__GETATTR                              0x00000004UL
-- 
1.6.1
