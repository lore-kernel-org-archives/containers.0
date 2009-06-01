From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 6/8] cr: capabilities: define checkpoint and restore fns
Date: Mon, 1 Jun 2009 17:22:23 -0500
Message-ID: <20090601222223.GF29460@us.ibm.com>
References: <20090601222119.GB29164@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090601222119.GB29164@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

An application checkpoint image will store capability sets
(and the bounding set) as __u64s.  Define checkpoint and
restart functions to translate between those and kernel_cap_t's.

Define a common function do_capset_tocred() which applies capability
set changes to a passed-in struct cred.

The restore function uses do_capset_tocred() to apply the restored
capabilities to the struct cred being crafted, subject to the
current task's (task executing sys_restart()) permissions.

Changelog:
	Jun 01: Made the checkpoint and restore functions and the
		ckpt_hdr_capabilities struct more opaque to the
		rest of the c/r code, as suggested by Andrew Morgan,
		and using naming suggested by Oren.
	Jun 01: Add commented BUILD_BUG_ON() to point out that the
		current implementation depends on 64-bit capabilities.
		(Andrew Morgan and Alexey Dobriyan).
	May 28: add helpers to c/r securebits

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/capability.h     |    6 ++
 include/linux/checkpoint_hdr.h |    9 +++
 kernel/capability.c            |  153 +++++++++++++++++++++++++++++++++++++---
 security/commoncap.c           |   19 +-----
 4 files changed, 159 insertions(+), 28 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index c302110..3a74655 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -568,6 +568,12 @@ extern int capable(int cap);
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
index 57d29c1..b67db6b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -56,6 +56,7 @@ enum {
 	CKPT_HDR_NS,
 	CKPT_HDR_UTS_NS,
 	CKPT_HDR_IPC_NS,
+	CKPT_HDR_CAPABILITIES,
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -166,6 +167,14 @@ struct ckpt_hdr_task {
 	__u32 task_comm_len;
 } __attribute__((aligned(8)));
 
+/* Posix capabilities */
+struct ckpt_capabilities {
+	__u32 securebits;
+	__u64 cap_i, cap_p, cap_e;
+	__u64 cap_x;  /* bounding set ('X') */
+	__u32 padding;
+} __attribute__((aligned(8)));
+
 /* namespaces */
 struct ckpt_hdr_task_ns {
 	struct ckpt_hdr h;
diff --git a/kernel/capability.c b/kernel/capability.c
index 4e17041..09af1a8 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -14,6 +14,8 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/pid_namespace.h>
+#include <linux/securebits.h>
+#include <linux/checkpoint_hdr.h>
 #include <asm/uaccess.h>
 #include "cred-internals.h"
 
@@ -217,6 +219,45 @@ SYSCALL_DEFINE2(capget, cap_user_header_t, header, cap_user_data_t, dataptr)
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
@@ -240,7 +281,6 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 	struct __user_cap_data_struct kdata[_KERNEL_CAPABILITY_U32S];
 	unsigned i, tocopy;
 	kernel_cap_t inheritable, permitted, effective;
-	struct cred *new;
 	int ret;
 	pid_t pid;
 
@@ -271,21 +311,112 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
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
+
+static void save_capability(__u64 *dest, kernel_cap_t src)
+{
+
+	/*
+	 * If the following triggers, then capabilities no longer fit into
+	 * 64 bits, and the checkpoint and restart code needs to be tweaked.
+	 */
+	BUILD_BUG_ON(CAP_LAST_CAP >= 64);
+
+	*dest = src.cap[0] | (src.cap[1] << sizeof(__u32));
+}
+
+static void do_capbset_drop(struct cred *cred, int cap)
+{
+	cap_lower(cred->cap_bset, cap);
+}
+
+static int do_restore_caps(__u64 newe, __u64 newi, __u64 newp, __u64 newx,
+			struct cred *cred)
+{
+	kernel_cap_t effective, inheritable, permitted, bset;
+	int may_dropbcap = capable(CAP_SETPCAP);
+	int ret, i;
+
+	effective.cap[0] = newe;
+	effective.cap[1] = (newe >> sizeof(__u32));
+	inheritable.cap[0] = newi;
+	inheritable.cap[1] = (newi >> sizeof(__u32));
+	permitted.cap[0] = newp;
+	permitted.cap[1] = (newp >> sizeof(__u32));
+	bset.cap[0] = newx;
+	bset.cap[1] = (newx >> sizeof(__u32));
+
+	ret = do_capset_tocred(&effective, &inheritable, &permitted, cred);
 	if (ret < 0)
-		goto error;
+		return ret;
 
-	audit_log_capset(pid, new, current_cred());
+	for (i = 0; i < CAP_LAST_CAP; i++) {
+		if (cap_raised(bset, i))
+			continue;
+		if (!cap_raised(current_cred()->cap_bset, i))
+			continue;
+		if (!may_dropbcap)
+			return -EPERM;
+		do_capbset_drop(cred, i);
+	}
 
-	return commit_creds(new);
+	return 0;
+}
+
+static void save_securebits(unsigned *bits, unsigned cred_securebits)
+{
+	*bits = cred_securebits;
+}
+
+void checkpoint_capabilities(struct ckpt_capabilities *h, struct cred * cred)
+{
+	save_securebits(&h->securebits, cred->securebits);
+	save_capability(&h->cap_i, cred->cap_inheritable);
+	save_capability(&h->cap_p, cred->cap_permitted);
+	save_capability(&h->cap_e, cred->cap_effective);
+	save_capability(&h->cap_x, cred->cap_bset);
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
+	int ret = do_restore_caps(h->cap_e, h->cap_i, h->cap_p, h->cap_x, new);
+
+	if (!ret)
+		ret = apply_securebits(h->securebits, new);
 
-error:
-	abort_creds(new);
 	return ret;
 }
 
diff --git a/security/commoncap.c b/security/commoncap.c
index beac025..528da3b 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -861,24 +861,9 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
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
1.6.1

