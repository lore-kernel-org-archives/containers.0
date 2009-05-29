From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 5/9] cr: capabilities: define checkpoint and restore fns
Date: Fri, 29 May 2009 17:33:19 -0500
Message-ID: <20090529223319.GE14602@us.ibm.com>
References: <20090529223229.GA14536@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090529223229.GA14536@us.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>, David Howells <dhowells@redhat.com>, linux-security-module@vger.kernel.org
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
	May 28: add helpers to c/r securebits

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/capability.h |    7 +++
 kernel/capability.c        |   94 +++++++++++++++++++++++++++++++++++++------
 security/commoncap.c       |   51 ++++++++++++++++--------
 3 files changed, 122 insertions(+), 30 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index c302110..b3853ca 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -536,6 +536,13 @@ extern const kernel_cap_t __cap_empty_set;
 extern const kernel_cap_t __cap_full_set;
 extern const kernel_cap_t __cap_init_eff_set;
 
+extern void checkpoint_save_cap(__u64 *dest, kernel_cap_t src);
+struct cred;
+extern int checkpoint_restore_cap(__u64 e, __u64 i, __u64 p, __u64 x,
+				struct cred *cred);
+extern void checkpoint_save_securebits(unsigned *, unsigned);
+extern int checkpoint_restore_securebits(unsigned, struct cred *);
+
 /**
  * has_capability - Determine if a task has a superior capability available
  * @t: The task in question
diff --git a/kernel/capability.c b/kernel/capability.c
index 4e17041..d2c9bb3 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -217,6 +217,45 @@ SYSCALL_DEFINE2(capget, cap_user_header_t, header, cap_user_data_t, dataptr)
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
@@ -240,7 +279,6 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 	struct __user_cap_data_struct kdata[_KERNEL_CAPABILITY_U32S];
 	unsigned i, tocopy;
 	kernel_cap_t inheritable, permitted, effective;
-	struct cred *new;
 	int ret;
 	pid_t pid;
 
@@ -271,22 +309,52 @@ SYSCALL_DEFINE2(capset, cap_user_header_t, header, const cap_user_data_t, data)
 		i++;
 	}
 
-	new = prepare_creds();
-	if (!new)
-		return -ENOMEM;
+	return do_capset(&effective, &inheritable, &permitted);
 
-	ret = security_capset(new, current_cred(),
-			      &effective, &inheritable, &permitted);
-	if (ret < 0)
-		goto error;
+}
 
-	audit_log_capset(pid, new, current_cred());
 
-	return commit_creds(new);
+void checkpoint_save_cap(__u64 *dest, kernel_cap_t src)
+{
+	*dest = src.cap[0] | (src.cap[1] << sizeof(__u32));
+}
 
-error:
-	abort_creds(new);
-	return ret;
+static void do_capbset_drop(struct cred *cred, int cap)
+{
+	cap_lower(cred->cap_bset, cap);
+}
+
+int checkpoint_restore_cap(__u64 newe, __u64 newi, __u64 newp, __u64 newx,
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
+	if (ret < 0)
+		return ret;
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
 }
 
 /**
diff --git a/security/commoncap.c b/security/commoncap.c
index beac025..8054a07 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -804,6 +804,28 @@ int cap_task_setnice (struct task_struct *p, int nice)
 }
 #endif
 
+int cap_set_securebits(struct cred *new, unsigned securebits)
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
 /**
  * cap_task_prctl - Implement process control functions for this security module
  * @option: The process control function requested
@@ -861,24 +883,9 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
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
+		error = cap_set_securebits(new, arg2);
+		if (error)
 			goto error;
-		new->securebits = arg2;
 		goto changed;
 
 	case PR_GET_SECUREBITS:
@@ -921,6 +928,16 @@ error:
 	return error;
 }
 
+void checkpoint_save_securebits(unsigned *b, unsigned cred_securebits)
+{
+	*b = cred_securebits;
+}
+
+int checkpoint_restore_securebits(unsigned b, struct cred *cred)
+{
+	return cap_set_securebits(cred, b);
+}
+
 /**
  * cap_syslog - Determine whether syslog function is permitted
  * @type: Function requested
-- 
1.6.1

