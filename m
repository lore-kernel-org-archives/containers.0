From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 6 Jan 2010 00:28:09 -0600
Message-ID: <20100106062809.GA17064@us.ibm.com>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

So i was thinking about how to safely but incrementally introduce
targeted capabilities - which we decided was a prereq to making VFS
handle user namespaces - and the following seemed doable.  My main
motivations were (in order):

        1. don't make any unconverted capable() checks unsafe
        2. minimize performance impact on non-container case
        3. minimize performance impact on containers

This patch adds a per-task inherited securebit SECURE_CONTAINERIZED.
The capable() call is considered unconverted.  Therefore any call
to capable() by a task which is SECURE_CONTAINERIZED returns -EPERM.

A new syscall capable_to() is the container-aware version of capable().

int capable_to(int cap, enum ns_type type, void *src, void *dest);

meaning a task which owns 'src' wants 'cap' access to an object
in namespace 'dest'.

In a case like setting hostname, there is no way to try to set the
hostname in another container, so the check is converted in this patch to

        capable_to(CAP_SYS_ADMIN, NS_TYPE_NONE, NULL, NULL);

capable_to() will act like the old capable(), meaning grant permission
if CAP_SYS_ADMIN is in pE.

The check for sending a signal depends on a user namespace, so I
converted an instance to

        capable_to(CAP_KILL, NS_TYPE_USERNS, current_userns(),
                        target->user_ns);

The NS_TYPE_USERNS check checks whether target->userns is the same
as or a descendent of target->user_ns.  If not, then -EPERM is
returned even if the task has CAP_KILL.

To test, compile a program (call it 'containerize_cap') that does

	prctl(PR_SET_SECUREBITS, 1 << 6 | 1 << 7);
	execl("/bin/bash", "bash", NULL);

Run that in a container (say, do 'ns_exec -cmpuU /bin/bash' and
run screen there).  Notice you can set hostname, but you can't
for instance read user's directories which don't have world write
perms, and can't mount.  You can also kill processes which are
either in your own or a child user namespace, but not in a parent
user namespace.

Purely for discussion.  Comments?

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/capability.h     |    5 +++
 include/linux/securebits.h     |   15 ++++++++++-
 include/linux/user_namespace.h |    9 ++++++
 kernel/capability.c            |   55 ++++++++++++++++++++++++++++++++++++++++
 kernel/signal.c                |    3 +-
 kernel/sys.c                   |    2 +-
 kernel/user_namespace.c        |   20 ++++++++++++++
 7 files changed, 106 insertions(+), 3 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 39e5ff5..f618804 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -110,6 +110,10 @@ struct cpu_vfs_cap_data {
 
 #endif
 
+enum ns_type {
+	NS_TYPE_NONE = 0,
+	NS_TYPE_USERNS,
+};
 
 /**
  ** POSIX-draft defined capabilities.
@@ -561,6 +565,7 @@ extern const kernel_cap_t __cap_init_eff_set;
 	(security_real_capable_noaudit((t), (cap)) == 0)
 
 extern int capable(int cap);
+extern int capable_to(int cap, enum ns_type type, void *src, void *dest);
 
 /* audit system wants to get cap info from files as well */
 struct dentry;
diff --git a/include/linux/securebits.h b/include/linux/securebits.h
index 3340617..8cc2329 100644
--- a/include/linux/securebits.h
+++ b/include/linux/securebits.h
@@ -43,12 +43,25 @@
 #define SECURE_KEEP_CAPS		4
 #define SECURE_KEEP_CAPS_LOCKED		5  /* make bit-4 immutable */
 
+/* When set, capable() will always return -EPERM.  Capability checks
+   which make sense with respect to a container, or are safe to grant
+   in a container, can be converted to capable_to().
+   Note this is not a part of SECURE_ALL_BITS because it is not
+   related to locking a task in a pure POSIX capability environment. */
+#define SECURE_CONTAINERIZED		6
+#define SECURE_CONTAINERIZED_LOCKED	7
+
+#define SECBIT_CONTAINERIZED (issecure_mask(SECURE_CONTAINERIZED))
+#define SECBIT_CONTAINERIZED_LOCKED \
+			(issecure_mask(SECBIT_CONTAINERIZED_LOCKED))
+
 #define SECBIT_KEEP_CAPS	(issecure_mask(SECURE_KEEP_CAPS))
 #define SECBIT_KEEP_CAPS_LOCKED (issecure_mask(SECURE_KEEP_CAPS_LOCKED))
 
 #define SECURE_ALL_BITS		(issecure_mask(SECURE_NOROOT) | \
 				 issecure_mask(SECURE_NO_SETUID_FIXUP) | \
-				 issecure_mask(SECURE_KEEP_CAPS))
+				 issecure_mask(SECURE_KEEP_CAPS) | \
+				 issecure_mask(SECURE_CONTAINERIZED))
 #define SECURE_ALL_LOCKS	(SECURE_ALL_BITS << 1)
 
 #endif /* !_LINUX_SECUREBITS_H */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index cc4f453..e05d06a 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -20,6 +20,9 @@ extern struct user_namespace init_user_ns;
 
 #ifdef CONFIG_USER_NS
 
+extern int userns_is_ancestor(struct user_namespace *src,
+				struct user_namespace *dest);
+
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	if (ns)
@@ -38,6 +41,12 @@ static inline void put_user_ns(struct user_namespace *ns)
 
 #else
 
+static inline int userns_is_ancestor(struct user_namespace *src,
+				struct user_namespace *dest)
+{
+	return 1;
+}
+
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 {
 	return &init_user_ns;
diff --git a/kernel/capability.c b/kernel/capability.c
index 7f876e6..0efd0e7 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -14,6 +14,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/pid_namespace.h>
+#include <linux/securebits.h>
 #include <asm/uaccess.h>
 #include "cred-internals.h"
 
@@ -307,6 +308,9 @@ int capable(int cap)
 		BUG();
 	}
 
+	if (issecure(SECURE_CONTAINERIZED))
+		return 0;
+
 	if (security_capable(cap) == 0) {
 		current->flags |= PF_SUPERPRIV;
 		return 1;
@@ -314,3 +318,54 @@ int capable(int cap)
 	return 0;
 }
 EXPORT_SYMBOL(capable);
+
+/* defined in kernel/user_namespace.c */
+extern int userns_is_ancestor(struct user_namespace *src,
+				struct user_namespace *dest);
+
+/**
+ * capable_to - Determine if the current task has capability applicable to the
+ * target namespace
+ * 
+ * @cap: The capability to be tested for
+ * @type: type of namespace
+ * @src: user's namespace
+ * @dest: object's namespace
+ *
+ * Return true if the current task has the given superior capability currently
+ * available for use, false if not.
+ *
+ * This sets PF_SUPERPRIV on the task if the capability is available on the
+ * assumption that it's about to be used.
+ */
+int capable_to(int cap, enum ns_type type, void *src, void *dest)
+{
+	if (unlikely(!cap_valid(cap))) {
+		printk(KERN_CRIT "capable() called with invalid cap=%u\n", cap);
+		BUG();
+	}
+
+	if (!issecure(SECURE_CONTAINERIZED))
+		goto check_capable;
+
+	switch(type) {
+	case NS_TYPE_NONE:
+		goto check_capable;
+	case NS_TYPE_USERNS:
+		if (!userns_is_ancestor(src, dest))
+			return 0;
+		goto check_capable;
+	default:
+		printk(KERN_CRIT "capable_to() called with invalid type=%d\n",
+			type);
+		BUG();
+		return 0;
+	}
+
+check_capable:
+	if (security_capable(cap) == 0) {
+		current->flags |= PF_SUPERPRIV;
+		return 1;
+	}
+	return 0;
+}
diff --git a/kernel/signal.c b/kernel/signal.c
index d09692b..9600028 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -644,7 +644,8 @@ static int check_kill_permission(int sig, struct siginfo *info,
 	    (cred->euid ^ tcred->uid) &&
 	    (cred->uid  ^ tcred->suid) &&
 	    (cred->uid  ^ tcred->uid) &&
-	    !capable(CAP_KILL)) {
+	    !capable_to(CAP_KILL, NS_TYPE_USERNS, cred->user->user_ns,
+				tcred->user->user_ns)) {
 		switch (sig) {
 		case SIGCONT:
 			sid = task_session(t);
diff --git a/kernel/sys.c b/kernel/sys.c
index 26a6b73..5c40837 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1134,7 +1134,7 @@ SYSCALL_DEFINE2(sethostname, char __user *, name, int, len)
 	int errno;
 	char tmp[__NEW_UTS_LEN];
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!capable_to(CAP_SYS_ADMIN, NS_TYPE_NONE, NULL, NULL))
 		return -EPERM;
 	if (len < 0 || len > __NEW_UTS_LEN)
 		return -EINVAL;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 076c7c8..49944fb 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -82,3 +82,23 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+/*
+ * userns_is_ancestor: return true if src is equal to or an ancestor
+ * of dest
+ */
+int userns_is_ancestor(struct user_namespace *src, struct user_namespace *dest)
+{
+	struct user_struct *u;
+	struct user_namespace *ns = dest;
+
+	if (dest == src)
+		return 1;
+	while (ns != &init_user_ns && ns != src) {
+		u = ns->creator;
+		ns = u->user_ns;
+	}
+	if (ns == src)
+		return 1;
+	return 0;
+}
-- 
1.6.1
