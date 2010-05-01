From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 061/100] c/r: capabilities: define checkpoint and restore
	fns
Date: Sat,  1 May 2010 10:15:43 -0400
Message-ID: <1272723382-19470-62-git-send-email-orenl__47688.4118667387$1272728550$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[ Andrew: I am punting on dealing with the subsystem cooperation
issues in this version, in favor of trying to get LSM issues
straightened out ]

An application checkpoint image will store capability sets
(and the bounding set) as __u64s.  Define checkpoint and
restart functions to translate between those and kernel_cap_t's.

Define a common function do_capset_tocred() which applies capability
set changes to a passed-in struct cred.

The restore function uses do_capset_tocred() to apply the restored
capabilities to the struct cred being crafted, subject to the
current task's (task executing sys_restart()) permissions.

Changelog [v21]:
  - [Serge Hallyn] CONFIG_SECURITY_FILE_CAPABILITIES has been gone awhile
Changelog [v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums

Changelog:
	Jun 09: Can't choose securebits or drop bounding set if
		file capabilities aren't compiled into the kernel.
		Also just store caps in __u32s (looks cleaner).
	Jun 01: Made the checkpoint and restore functions and the
		ckpt_hdr_capabilities struct more opaque to the
		rest of the c/r code, as suggested by Andrew Morgan,
		and using naming suggested by Oren.
	Jun 01: Add commented BUILD_BUG_ON() to point out that the
		current implementation depends on 64-bit capabilities.
		(Andrew Morgan and Alexey Dobriyan).
	May 28: add helpers to c/r securebits

Cc: Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 include/linux/capability.h     |    6 ++
 include/linux/checkpoint_hdr.h |   12 +++
 kernel/capability.c            |  148 +++++++++++++++++++++++++++++++++++++---
 security/commoncap.c           |   19 +-----
 4 files changed, 157 insertions(+), 28 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 39e5ff5..5abd86c 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -566,6 +566,12 @@ extern int capable(int cap);
 struct dentry;
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
 
+struct cred;
+int apply_securebits(unsigned securebits, struct cred *new);
+struct ckpt_capabilities;
+int restore_capabilities(struct ckpt_capabilities *h, struct cred *new);
+void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred * cred);
+
 #endif /* __KERNEL__ */
 
 #endif /* !_LINUX_CAPABILITY_H */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 8f81da1..9d725db 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -90,6 +90,8 @@ enum {
 #define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
 	CKPT_HDR_IPC_NS,
 #define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
+	CKPT_HDR_CAPABILITIES,
+#define CKPT_HDR_CAPABILITIES CKPT_HDR_CAPABILITIES
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -254,6 +256,16 @@ struct ckpt_hdr_task {
 	__u64 clear_child_tid;
 } __attribute__((aligned(8)));
 
+/* Posix capabilities */
+struct ckpt_capabilities {
+	__u32 cap_i_0, cap_i_1; /* inheritable set */
+	__u32 cap_p_0, cap_p_1; /* permitted set */
+	__u32 cap_e_0, cap_e_1; /* effective set */
+	__u32 cap_b_0, cap_b_1; /* bounding set */
+	__u32 securebits;
+	__u32 padding;
+} __attribute__((aligned(8)));
+
 /* namespaces */
 struct ckpt_hdr_task_ns {
 	struct ckpt_hdr h;
diff --git a/kernel/capability.c b/kernel/capability.c
index 9e4697e..c39d6b0 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -14,6 +14,8 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/pid_namespace.h>
+#include <linux/securebits.h>
+#include <linux/checkpoint.h>
 #include <asm/uaccess.h>
 #include "cred-internals.h"
 
@@ -215,6 +217,45 @@ SYSCALL_DEFINE2(capget, cap_user_header_t, header, cap_user_data_t, dataptr)
 	return ret;
 }
 
+static int do_capset_tocred(kernel_cap_t *effective, kernel_cap_t *inheritable,
+			kernel_cap_t *permitted, struct cred *new)
+{
+	int ret;
+
+	ret = security_capset(new, current_cred(),
+			      effective, inheritable, permitted);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * for checkpoint-restart, do we want to wait until end of restart?
+	 * not sure we care */
+	audit_log_capset(current->pid, new, current_cred());
+
+	return 0;
+}
+
+static int do_capset(kernel_cap_t *effective, kernel_cap_t *inheritable,
+			kernel_cap_t *permitted)
+{
+	struct cred *new;
+	int ret;
+
+	new = prepare_creds();
+	if (!new)
+		return -ENOMEM;
+
+	ret = do_capset_tocred(effective, inheritable, permitted, new);
+	if (ret < 0)
+		goto error;
+
+	return commit_creds(new);
+
+error:
+	abort_creds(new);
+	return ret;
+}
+
 /**
  * sys_capset - set capabilities for a process or (*) a group of processes
  * @header: pointer to struct that contains capability version and
@@ -238,7 +279,6 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 	struct __user_cap_data_struct kdata[_KERNEL_CAPABILITY_U32S];
 	unsigned i, tocopy, copybytes;
 	kernel_cap_t inheritable, permitted, effective;
-	struct cred *new;
 	int ret;
 	pid_t pid;
 
@@ -272,23 +312,109 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 		i++;
 	}
 
-	new = prepare_creds();
-	if (!new)
-		return -ENOMEM;
+	return do_capset(&effective, &inheritable, &permitted);
 
-	ret = security_capset(new, current_cred(),
-			      &effective, &inheritable, &permitted);
+}
+
+int apply_securebits(unsigned securebits, struct cred *new)
+{
+	if ((((new->securebits & SECURE_ALL_LOCKS) >> 1)
+	     & (new->securebits ^ securebits))				/*[1]*/
+	    || ((new->securebits & SECURE_ALL_LOCKS & ~securebits))	/*[2]*/
+	    || (securebits & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS))	/*[3]*/
+	    || (cap_capable(current, current_cred(), CAP_SETPCAP,
+			    SECURITY_CAP_AUDIT) != 0)			/*[4]*/
+		/*
+		 * [1] no changing of bits that are locked
+		 * [2] no unlocking of locks
+		 * [3] no setting of unsupported bits
+		 * [4] doing anything requires privilege (go read about
+		 *     the "sendmail capabilities bug")
+		 */
+	    )
+		/* cannot change a locked bit */
+		return -EPERM;
+	new->securebits = securebits;
+	return 0;
+}
+
+static void do_capbset_drop(struct cred *cred, int cap)
+{
+	cap_lower(cred->cap_bset, cap);
+}
+
+static inline int restore_cap_bset(kernel_cap_t bset, struct cred *cred)
+{
+	int i, may_dropbcap = capable(CAP_SETPCAP);
+
+	for (i = 0; i < CAP_LAST_CAP; i++) {
+		if (cap_raised(bset, i))
+			continue;
+		if (!cap_raised(current_cred()->cap_bset, i))
+			continue;
+		if (!may_dropbcap)
+			return -EPERM;
+		do_capbset_drop(cred, i);
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_CHECKPOINT
+static int do_restore_caps(struct ckpt_capabilities *h, struct cred *cred)
+{
+	kernel_cap_t effective, inheritable, permitted, bset;
+	int ret;
+
+	effective.cap[0] = h->cap_e_0;
+	effective.cap[1] = h->cap_e_1;
+	inheritable.cap[0] = h->cap_i_0;
+	inheritable.cap[1] = h->cap_i_1;
+	permitted.cap[0] = h->cap_p_0;
+	permitted.cap[1] = h->cap_p_1;
+	bset.cap[0] = h->cap_b_0;
+	bset.cap[1] = h->cap_b_1;
+
+	ret = do_capset_tocred(&effective, &inheritable, &permitted, cred);
 	if (ret < 0)
-		goto error;
+		return ret;
 
-	audit_log_capset(pid, new, current_cred());
+	ret = restore_cap_bset(bset, cred);
+	return ret;
+}
 
-	return commit_creds(new);
+void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred * cred)
+{
+	BUILD_BUG_ON(CAP_LAST_CAP >= 64);
+	h->securebits = cred->securebits;
+	h->cap_i_0 = cred->cap_inheritable.cap[0];
+	h->cap_i_1 = cred->cap_inheritable.cap[1];
+	h->cap_p_0 = cred->cap_permitted.cap[0];
+	h->cap_p_1 = cred->cap_permitted.cap[1];
+	h->cap_e_0 = cred->cap_effective.cap[0];
+	h->cap_e_1 = cred->cap_effective.cap[1];
+	h->cap_b_0 = cred->cap_bset.cap[0];
+	h->cap_b_1 = cred->cap_bset.cap[1];
+}
+
+/*
+ * restore_capabilities: called by restore_creds() to set the
+ * restored capabilities (if permitted) in a new struct cred which
+ * will be attached at the end of the sys_restart().
+ * struct cred *new is prepared by caller (using prepare_creds())
+ * (and aborted by caller on error)
+ * return 0 on success, < 0 on error
+ */
+int restore_capabilities(struct ckpt_capabilities *h, struct cred *new)
+{
+	int ret = do_restore_caps(h, new);
+
+	if (!ret)
+		ret = apply_securebits(h->securebits, new);
 
-error:
-	abort_creds(new);
 	return ret;
 }
+#endif /* CONFIG_CHECKPOINT */
 
 /**
  * capable - Determine if the current task has a superior capability in effect
diff --git a/security/commoncap.c b/security/commoncap.c
index 6166973..532b971 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -828,24 +828,9 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 	 * capability-based-privilege environment.
 	 */
 	case PR_SET_SECUREBITS:
-		error = -EPERM;
-		if ((((new->securebits & SECURE_ALL_LOCKS) >> 1)
-		     & (new->securebits ^ arg2))			/*[1]*/
-		    || ((new->securebits & SECURE_ALL_LOCKS & ~arg2))	/*[2]*/
-		    || (arg2 & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS))	/*[3]*/
-		    || (cap_capable(current, current_cred(), CAP_SETPCAP,
-				    SECURITY_CAP_AUDIT) != 0)		/*[4]*/
-			/*
-			 * [1] no changing of bits that are locked
-			 * [2] no unlocking of locks
-			 * [3] no setting of unsupported bits
-			 * [4] doing anything requires privilege (go read about
-			 *     the "sendmail capabilities bug")
-			 */
-		    )
-			/* cannot change a locked bit */
+		error = apply_securebits(arg2, new);
+		if (error)
 			goto error;
-		new->securebits = arg2;
 		goto changed;
 
 	case PR_GET_SECUREBITS:
-- 
1.6.3.3
