From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/10] cr: lsm: restore file->f_security
Date: Tue, 9 Jun 2009 20:47:04 -0500
Message-ID: <20090610014704.GI5658@us.ibm.com>
References: <20090610014412.GA5628@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090610014412.GA5628-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

file->f_cred is the cred of the task which opened it.  file->f_security
can be separately set by the LSM.  Checkpoint the file->f_security,
and at restart ask the LSM, using security_file_restore, based on the current
task's context and the checkpointed f_security, which f_security to apply (or
whether to refuse the restart altogether).

For Smack, accept the checkpointed label if the restarting task has
CAP_MAC_ADMIN.

For SELinux, I currently ignore the checkpointed label and call
file_alloc_security().  Do we want to have 'restore' permission for
class file?

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c             |   33 +++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    1 +
 include/linux/security.h       |   13 +++++++++++++
 security/capability.c          |    6 ++++++
 security/security.c            |    5 +++++
 security/selinux/hooks.c       |   11 +++++++++++
 security/smack/smack_lsm.c     |   26 +++++++++++++++++++++++++-
 7 files changed, 94 insertions(+), 1 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 5be7d1b..36c7f35 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -19,6 +19,7 @@
 #include <linux/fsnotify.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/syscalls.h>
+#include <linux/security.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -155,6 +156,14 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	if (h->f_credref < 0)
 		return h->f_credref;
 
+#ifdef CONFIG_SECURITY
+	if (file->f_security) {
+		h->f_secref = checkpoint_obj(ctx, file->f_security, CKPT_OBJ_SEC);
+		if (h->f_secref < 0)
+			return h->f_secref;
+	} else
+		h->f_secref = -1;
+#endif
 	/* FIX: need also file->f_owner, etc */
 
 	return 0;
@@ -437,6 +446,26 @@ static int attach_file(struct file *file)
 	return fd;
 }
 
+#ifdef CONFIG_SECURITY
+int restore_file_security(struct ckpt_ctx *ctx, struct file *file,
+			   struct ckpt_hdr_file *h)
+{
+	void *security = NULL;
+
+	if (h->f_secref != -1)
+		security = ckpt_obj_fetch(ctx, h->f_secref, CKPT_OBJ_SEC);
+	if (IS_ERR(security))
+		return PTR_ERR(security);
+	return security_file_restore(file, security);
+}
+#else
+static inline int restore_file_security(struct ckpt_ctx *ctx,
+		struct file *file, struct ckpt_hdr_file *h)
+{
+	return 0;
+}
+#endif
+
 #define CKPT_SETFL_MASK  \
 	(O_APPEND | O_NONBLOCK | O_NDELAY | FASYNC | O_DIRECT | O_NOATIME)
 
@@ -455,6 +484,10 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	put_cred(file->f_cred);
 	file->f_cred = get_cred(cred);
 
+	ret = restore_file_security(ctx, file, h);
+	if (ret < 0)
+		goto out;
+
 	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
 	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
 	if (ret < 0)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index a447b5a..1722826 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -320,6 +320,7 @@ struct ckpt_hdr_file {
 	__s32 f_credref;
 	__u64 f_pos;
 	__u64 f_version;
+	__s32 f_secref;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_file_generic {
diff --git a/include/linux/security.h b/include/linux/security.h
index 5625553..936a2a1 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -554,6 +554,12 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	created.
  *	@file contains the file structure to secure.
  *	Return 0 if the hook is successful and permission is granted.
+ * @file_restore_security:
+ *	Allocate and attach a security structure to the file->f_security field
+ *	during sys_restart().
+ *	@file contains the file structure to secure.
+ *	@stored contains the checkpointed context.
+ *	Return 0 if the hook is successful and permission is granted.
  * @file_free_security:
  *	Deallocate and free any security structures stored in file->f_security.
  *	@file contains the file structure being modified.
@@ -1494,6 +1500,7 @@ struct security_operations {
 
 	int (*file_permission) (struct file *file, int mask);
 	int (*file_alloc_security) (struct file *file);
+	int (*file_restore_security) (struct file *file, void *stored);
 	void (*file_free_security) (struct file *file);
 	int (*file_ioctl) (struct file *file, unsigned int cmd,
 			   unsigned long arg);
@@ -1761,6 +1768,7 @@ int security_inode_listsecurity(struct inode *inode, char *buffer, size_t buffer
 void security_inode_getsecid(const struct inode *inode, u32 *secid);
 int security_file_permission(struct file *file, int mask);
 int security_file_alloc(struct file *file);
+int security_file_restore(struct file *file, void *stored);
 void security_file_free(struct file *file);
 int security_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 int security_file_mmap(struct file *file, unsigned long reqprot,
@@ -2250,6 +2258,11 @@ static inline int security_file_alloc(struct file *file)
 	return 0;
 }
 
+static inline int security_file_restore(struct file *file, void *stored)
+{
+	return 0;
+}
+
 static inline void security_file_free(struct file *file)
 { }
 
diff --git a/security/capability.c b/security/capability.c
index 4e586a7..f0a3c65 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -320,6 +320,11 @@ static int cap_file_alloc_security(struct file *file)
 	return 0;
 }
 
+static int cap_file_restore_security(struct file *file, void *stored)
+{
+	return 0;
+}
+
 static void cap_file_free_security(struct file *file)
 {
 }
@@ -976,6 +981,7 @@ void security_fixup_ops(struct security_operations *ops)
 #endif
 	set_to_cap_if_null(ops, file_permission);
 	set_to_cap_if_null(ops, file_alloc_security);
+	set_to_cap_if_null(ops, file_restore_security);
 	set_to_cap_if_null(ops, file_free_security);
 	set_to_cap_if_null(ops, file_ioctl);
 	set_to_cap_if_null(ops, file_mmap);
diff --git a/security/security.c b/security/security.c
index 26e7989..0006e9c 100644
--- a/security/security.c
+++ b/security/security.c
@@ -628,6 +628,11 @@ int security_file_alloc(struct file *file)
 	return security_ops->file_alloc_security(file);
 }
 
+int security_file_restore(struct file *file, void *stored)
+{
+	return security_ops->file_restore_security(file, stored);
+}
+
 void security_file_free(struct file *file)
 {
 	security_ops->file_free_security(file);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index ba24808..4b8c636 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2973,6 +2973,16 @@ static int selinux_file_alloc_security(struct file *file)
 	return file_alloc_security(file);
 }
 
+static int selinux_file_restore_security(struct file *file,
+				void *stored)
+{
+	/*
+	 * TODO - actually restore from 'stored' subject to authorization
+	 */
+	kfree(stored);
+	return file_alloc_security(file);
+}
+
 static void selinux_file_free_security(struct file *file)
 {
 	file_free_security(file);
@@ -5566,6 +5576,7 @@ static struct security_operations selinux_ops = {
 
 	.file_permission =		selinux_file_permission,
 	.file_alloc_security =		selinux_file_alloc_security,
+	.file_restore_security =	selinux_file_restore_security,
 	.file_free_security =		selinux_file_free_security,
 	.file_ioctl =			selinux_file_ioctl,
 	.file_mmap =			selinux_file_mmap,
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index dfc0f7a..7bcdfde 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -831,6 +831,30 @@ static int smack_file_alloc_security(struct file *file)
 }
 
 /**
+ * smack_file_restore_security - assign a file security blob
+ * @file: the object
+ * @stored: the label stored in the checkpoint file
+ *
+ * Returns 0
+ */
+static int smack_file_restore_security(struct file *file, void *stored)
+{
+	char *str = smk_import(stored, 0);
+
+	if (str == NULL)
+		return -EINVAL;
+
+	file->f_security = current_security();
+	if (current_security() != str) {
+		if (!capable(CAP_MAC_ADMIN))
+			return -EPERM;
+		file->f_security = str;
+	}
+
+	return 0;
+}
+
+/**
  * smack_file_free_security - clear a file security blob
  * @file: the object
  *
@@ -1630,7 +1654,6 @@ static int smack_msg_msg_restore_security(struct msg_msg *msg,
 		msg->security = str;
 	}
 	return 0;
-	return 0;
 }
 
 /**
@@ -2996,6 +3019,7 @@ struct security_operations smack_ops = {
 
 	.file_permission = 		smack_file_permission,
 	.file_alloc_security = 		smack_file_alloc_security,
+	.file_restore_security =	smack_file_restore_security,
 	.file_free_security = 		smack_file_free_security,
 	.file_ioctl = 			smack_file_ioctl,
 	.file_lock = 			smack_file_lock,
-- 
1.6.1
