From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH v4 1/5] ima: Add IMA namespace support
Date: Fri, 11 May 2018 10:42:26 -0400
Message-ID: <20180511144230.75384-2-stefanb@linux.vnet.ibm.com>
References: <20180511144230.75384-1-stefanb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180511144230.75384-1-stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Add a new CONFIG_IMA_NS config option that enables one to create a new IMA
namespace. We do this by writing a file into IMA's new securityfs 'unshare'
file, which will have a new child process get the IMA namespace. We create
the IMA namespace when a user writes a boolean '1' into this file and
we cache the IMA namespace on the task_struct and take it from there upon
the next clone().

Currently, the iam_ns contains no useful IMA data but only a dummy inter-
face. This patch creates the framework for namespacing the different as-
pects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).

At this point one can create and activate a new IMA namespace by writing
a '1' into IMA's unshare file and subsequently creating a new process.
The 'ls -l' shows that the IMA namespace inode number temporarily changes
while the new IMA namespace is active after it was set up.

ls -l /proc/self/ns/ima
echo 1 > /sys/kernel/security/ima/unshare
ls -l /proc/self/ns/ima
ls -l /proc/self/ns/ima

Changelog:
v4:
* Use IMA's securityfs to spawn a new namespace using unshare file

v3:
* Use CLONE_NEWUSER instead of CLONE_NEWNS flag

v2:
* Moved ima_init_ns and related functions into own file that is
  always compiled; init_ima_ns will always be there
* Fixed putting of imans->parent
* Move IMA namespace creation from nsproxy into mount namespace
  code; get rid of procfs operations for IMA namespace

v1:
* Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
* Use existing ima.h headers
* Move the ima_namespace.c to security/integrity/ima/ima_ns.c
* Fix typo INFO->INO
* Each namespace free's itself, removed recursively free'ing
  until init_ima_ns from free_ima_ns()

Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/proc/namespaces.c                     |   3 +
 include/linux/ima.h                      |  50 ++++++++++
 include/linux/nsproxy.h                  |   2 +
 include/linux/proc_ns.h                  |   1 +
 include/linux/sched.h                    |   6 ++
 include/linux/user_namespace.h           |   1 +
 init/Kconfig                             |   8 ++
 kernel/fork.c                            |   5 +
 kernel/nsproxy.c                         |  25 ++++-
 kernel/ucount.c                          |   1 +
 security/integrity/ima/Makefile          |   3 +-
 security/integrity/ima/ima.h             |  32 ++++++
 security/integrity/ima/ima_fs.c          |  55 +++++++++++
 security/integrity/ima/ima_init.c        |   4 +
 security/integrity/ima/ima_init_ima_ns.c |  40 ++++++++
 security/integrity/ima/ima_ns.c          | 162 +++++++++++++++++++++++++++++++
 16 files changed, 396 insertions(+), 2 deletions(-)
 create mode 100644 security/integrity/ima/ima_init_ima_ns.c
 create mode 100644 security/integrity/ima/ima_ns.c

diff --git a/fs/proc/namespaces.c b/fs/proc/namespaces.c
index 59b17e509f46..cc5e8e217412 100644
--- a/fs/proc/namespaces.c
+++ b/fs/proc/namespaces.c
@@ -33,6 +33,9 @@ static const struct proc_ns_operations *ns_entries[] = {
 #ifdef CONFIG_CGROUPS
 	&cgroupns_operations,
 #endif
+#ifdef CONFIG_IMA_NS
+	&imans_operations,
+#endif
 };
 
 static const char *proc_ns_get_link(struct dentry *dentry,
diff --git a/include/linux/ima.h b/include/linux/ima.h
index 0e4647e0eb60..27a332cd0438 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -105,4 +105,54 @@ static inline int ima_inode_removexattr(struct dentry *dentry,
 	return 0;
 }
 #endif /* CONFIG_IMA_APPRAISE */
+
+struct ima_namespace {
+	struct kref kref;
+	struct user_namespace *user_ns;
+	struct ucounts *ucounts;
+	struct ns_common ns;
+	struct ima_namespace *parent;
+};
+
+extern struct ima_namespace init_ima_ns;
+
+#ifdef CONFIG_IMA_NS
+
+struct ima_namespace *copy_ima_ns(bool copy, struct user_namespace *user_ns,
+				  struct ima_namespace *old_ns);
+
+void free_ima_ns(struct kref *kref);
+
+static inline struct ima_namespace *get_ima_ns(struct ima_namespace *ns)
+{
+	if (ns)
+		kref_get(&ns->kref);
+	return ns;
+}
+
+static inline void put_ima_ns(struct ima_namespace *ns)
+{
+	if (ns)
+		kref_put(&ns->kref, free_ima_ns);
+}
+
+#else
+
+static inline struct ima_namespace *copy_ima_ns(bool copy,
+						struct user_namespace *user_ns,
+						struct ima_namespace *old_ns)
+{
+	return old_ns;
+}
+
+static inline struct ima_namespace *get_ima_ns(struct ima_namespace *ns)
+{
+	return ns;
+}
+
+static inline void put_ima_ns(struct ima_namespace *ns)
+{
+}
+
+#endif /* CONFIG_IMA_NS */
 #endif /* _LINUX_IMA_H */
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 2ae1b1a4d84d..9d49f0a0cc97 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -10,6 +10,7 @@ struct uts_namespace;
 struct ipc_namespace;
 struct pid_namespace;
 struct cgroup_namespace;
+struct ima_namespace;
 struct fs_struct;
 
 /*
@@ -36,6 +37,7 @@ struct nsproxy {
 	struct pid_namespace *pid_ns_for_children;
 	struct net 	     *net_ns;
 	struct cgroup_namespace *cgroup_ns;
+	struct ima_namespace *ima_ns;
 };
 extern struct nsproxy init_nsproxy;
 
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index d31cb6215905..5be4411ecccc 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -32,6 +32,7 @@ extern const struct proc_ns_operations pidns_for_children_operations;
 extern const struct proc_ns_operations userns_operations;
 extern const struct proc_ns_operations mntns_operations;
 extern const struct proc_ns_operations cgroupns_operations;
+extern const struct proc_ns_operations imans_operations;
 
 /*
  * We always define these enumerators
diff --git a/include/linux/sched.h b/include/linux/sched.h
index b161ef8a902e..8a1f1b60959d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -53,6 +53,7 @@ struct sighand_struct;
 struct signal_struct;
 struct task_delay_info;
 struct task_group;
+struct ima_namespace;
 
 /*
  * Task state bitmask. NOTE! These bits are also
@@ -1100,6 +1101,11 @@ struct task_struct {
 	void				*security;
 #endif
 
+#ifdef CONFIG_IMA_NS
+	/* child process will spawn a new IMA namespace */
+	bool                            ima_ns_for_child;
+#endif
+
 	/*
 	 * New fields for task_struct should be added above here, so that
 	 * they are included in the randomized portion of task_struct.
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index d6b74b91096b..d6def79eb0d1 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -49,6 +49,7 @@ enum ucount_type {
 	UCOUNT_INOTIFY_INSTANCES,
 	UCOUNT_INOTIFY_WATCHES,
 #endif
+	UCOUNT_IMA_NAMESPACES,
 	UCOUNT_COUNTS,
 };
 
diff --git a/init/Kconfig b/init/Kconfig
index e37f4b2a6445..2ae532aa12a0 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -932,6 +932,14 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config IMA_NS
+	bool "IMA namespace"
+	depends on IMA
+	default n
+	help
+	  Allow the creation of IMA namespaces. Namespaced IMA data
+          enables having IMA features work separately in each IMA namespace.
+
 endif # NAMESPACES
 
 config SCHED_AUTOGROUP
diff --git a/kernel/fork.c b/kernel/fork.c
index e5d9d405ae4e..a0715ccf897e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -91,6 +91,7 @@
 #include <linux/kcov.h>
 #include <linux/livepatch.h>
 #include <linux/thread_info.h>
+#include <linux/ima.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -834,6 +835,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 	tsk->fail_nth = 0;
 #endif
 
+#ifdef CONFIG_IMA_NS
+	orig->ima_ns_for_child = false;
+#endif
+
 	return tsk;
 
 free_stack:
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f6c5d330059a..495f4a561d2a 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -27,6 +27,7 @@
 #include <linux/syscalls.h>
 #include <linux/cgroup.h>
 #include <linux/perf_event.h>
+#include <linux/ima.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -44,6 +45,9 @@ struct nsproxy init_nsproxy = {
 #ifdef CONFIG_CGROUPS
 	.cgroup_ns		= &init_cgroup_ns,
 #endif
+#ifdef CONFIG_IMA_NS
+	.ima_ns			= &init_ima_ns,
+#endif
 };
 
 static inline struct nsproxy *create_nsproxy(void)
@@ -67,6 +71,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 {
 	struct nsproxy *new_nsp;
 	int err;
+	bool copy_ima = false;
 
 	new_nsp = create_nsproxy();
 	if (!new_nsp)
@@ -110,8 +115,21 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		goto out_net;
 	}
 
+#ifdef CONFIG_IMA_NS
+	copy_ima = tsk->ima_ns_for_child;
+	tsk->ima_ns_for_child = false;
+#endif
+	new_nsp->ima_ns = copy_ima_ns(copy_ima, user_ns,
+				      tsk->nsproxy->ima_ns);
+	if (IS_ERR(new_nsp->ima_ns)) {
+		err = PTR_ERR(new_nsp->ima_ns);
+		goto out_ima;
+	}
+
 	return new_nsp;
 
+out_ima:
+	put_net(new_nsp->net_ns);
 out_net:
 	put_cgroup_ns(new_nsp->cgroup_ns);
 out_cgroup:
@@ -143,7 +161,11 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 
 	if (likely(!(flags & (CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
 			      CLONE_NEWPID | CLONE_NEWNET |
-			      CLONE_NEWCGROUP)))) {
+			      CLONE_NEWCGROUP)))
+#ifdef CONFIG_IMA_NS
+	    && likely(!tsk->ima_ns_for_child)
+#endif
+	) {
 		get_nsproxy(old_ns);
 		return 0;
 	}
@@ -182,6 +204,7 @@ void free_nsproxy(struct nsproxy *ns)
 		put_pid_ns(ns->pid_ns_for_children);
 	put_cgroup_ns(ns->cgroup_ns);
 	put_net(ns->net_ns);
+	put_ima_ns(ns->ima_ns);
 	kmem_cache_free(nsproxy_cachep, ns);
 }
 
diff --git a/kernel/ucount.c b/kernel/ucount.c
index b4eeee03934f..bdd02e2e36cf 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -79,6 +79,7 @@ static struct ctl_table user_table[] = {
 	UCOUNT_ENTRY("max_inotify_instances"),
 	UCOUNT_ENTRY("max_inotify_watches"),
 #endif
+	UCOUNT_ENTRY("max_ima_namespaces"),
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
diff --git a/security/integrity/ima/Makefile b/security/integrity/ima/Makefile
index d921dc4f9eb0..cc60f726e651 100644
--- a/security/integrity/ima/Makefile
+++ b/security/integrity/ima/Makefile
@@ -7,7 +7,8 @@
 obj-$(CONFIG_IMA) += ima.o
 
 ima-y := ima_fs.o ima_queue.o ima_init.o ima_main.o ima_crypto.o ima_api.o \
-	 ima_policy.o ima_template.o ima_template_lib.o
+	 ima_policy.o ima_template.o ima_template_lib.o ima_init_ima_ns.o
 ima-$(CONFIG_IMA_APPRAISE) += ima_appraise.o
+ima-$(CONFIG_IMA_NS) += ima_ns.o
 ima-$(CONFIG_HAVE_IMA_KEXEC) += ima_kexec.o
 obj-$(CONFIG_IMA_BLACKLIST_KEYRING) += ima_mok.o
diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index d52b487ad259..f999328e5b49 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -24,6 +24,7 @@
 #include <linux/hash.h>
 #include <linux/tpm.h>
 #include <linux/audit.h>
+#include <linux/ima.h>
 #include <crypto/hash_info.h>
 
 #include "../integrity.h"
@@ -291,6 +292,10 @@ static inline int ima_read_xattr(struct dentry *dentry,
 
 #endif /* CONFIG_IMA_APPRAISE */
 
+int ima_ns_init(void);
+struct ima_namespace;
+int ima_init_namespace(struct ima_namespace *ns);
+
 /* LSM based policy rules require audit */
 #ifdef CONFIG_IMA_LSM_RULES
 
@@ -313,6 +318,33 @@ static inline int security_filter_rule_match(u32 secid, u32 field, u32 op,
 }
 #endif /* CONFIG_IMA_LSM_RULES */
 
+static inline struct ima_namespace *to_ima_ns(struct ns_common *ns)
+{
+	return container_of(ns, struct ima_namespace, ns);
+}
+
+#ifdef CONFIG_IMA_NS
+
+extern const struct proc_ns_operations imans_operations;
+
+struct ima_namespace *copy_ima(struct user_namespace *user_ns,
+			       struct ima_namespace *old_ns);
+
+
+static inline struct ima_namespace *get_current_ns(void)
+{
+	return current->nsproxy->ima_ns;
+}
+
+#else
+
+static inline struct ima_namespace *get_current_ns(void)
+{
+	return &init_ima_ns;
+}
+
+#endif /* CONFIG_IMA_NS */
+
 #ifdef	CONFIG_IMA_READ_POLICY
 #define	POLICY_FILE_FLAGS	(S_IWUSR | S_IRUSR)
 #else
diff --git a/security/integrity/ima/ima_fs.c b/security/integrity/ima/ima_fs.c
index fa540c0469da..9ebf97e29344 100644
--- a/security/integrity/ima/ima_fs.c
+++ b/security/integrity/ima/ima_fs.c
@@ -361,6 +361,9 @@ static struct dentry *ascii_runtime_measurements;
 static struct dentry *runtime_measurements_count;
 static struct dentry *violations;
 static struct dentry *ima_policy;
+#ifdef CONFIG_IMA_NS
+static struct dentry *unshare;
+#endif
 
 enum ima_fs_flags {
 	IMA_FS_BUSY,
@@ -446,6 +449,47 @@ static const struct file_operations ima_measure_policy_ops = {
 	.llseek = generic_file_llseek,
 };
 
+#ifdef CONFIG_IMA_NS
+static int ima_open_unshare(struct inode *inode, struct file *filp)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
+static ssize_t ima_write_unshare(struct file *file, const char __user *buf,
+				 size_t count, loff_t *ppos)
+{
+	ssize_t length;
+	char *page;
+	bool set;
+
+	if (count >= PAGE_SIZE)
+		return -ENOMEM;
+
+	page = memdup_user_nul(buf, count);
+	if (IS_ERR(page))
+		return PTR_ERR(page);
+
+	length = -EINVAL;
+	if (kstrtobool(page, &set))
+		goto out;
+
+	current->ima_ns_for_child = set;
+
+	length = count;
+out:
+	kfree(page);
+
+	return length;
+}
+
+static const struct file_operations ima_unshare_ops = {
+	.open = ima_open_unshare,
+	.write = ima_write_unshare,
+};
+#endif
+
 int __init ima_fs_init(void)
 {
 	ima_dir = securityfs_create_dir("ima", NULL);
@@ -485,6 +529,14 @@ int __init ima_fs_init(void)
 	if (IS_ERR(ima_policy))
 		goto out;
 
+#ifdef CONFIG_IMA_NS
+	unshare = securityfs_create_file("unshare", 0200,
+					 ima_dir, NULL,
+					 &ima_unshare_ops);
+	if (IS_ERR(unshare))
+		goto out;
+#endif
+
 	return 0;
 out:
 	securityfs_remove(violations);
@@ -493,5 +545,8 @@ int __init ima_fs_init(void)
 	securityfs_remove(binary_runtime_measurements);
 	securityfs_remove(ima_dir);
 	securityfs_remove(ima_policy);
+#ifdef CONFIG_IMA_NS
+	securityfs_remove(unshare);
+#endif
 	return -1;
 }
diff --git a/security/integrity/ima/ima_init.c b/security/integrity/ima/ima_init.c
index 29b72cd2502e..091e5fdee5fc 100644
--- a/security/integrity/ima/ima_init.c
+++ b/security/integrity/ima/ima_init.c
@@ -137,5 +137,9 @@ int __init ima_init(void)
 
 	ima_init_policy();
 
+	rc = ima_ns_init();
+	if (rc != 0)
+		return rc;
+
 	return ima_fs_init();
 }
diff --git a/security/integrity/ima/ima_init_ima_ns.c b/security/integrity/ima/ima_init_ima_ns.c
new file mode 100644
index 000000000000..0bd6c418b8e3
--- /dev/null
+++ b/security/integrity/ima/ima_init_ima_ns.c
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2016-2018 IBM Corporation
+ * Author:
+ *   Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *   Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, version 2 of the License.
+ */
+
+#include <linux/export.h>
+#include <linux/user_namespace.h>
+#include <linux/proc_ns.h>
+#include <linux/ima.h>
+
+#include "ima.h"
+
+int ima_init_namespace(struct ima_namespace *ns)
+{
+#ifdef CONFIG_IMA_NS
+	ns->ns.ops = &imans_operations;
+	return ns_alloc_inum(&ns->ns);
+#else
+	return 0;
+#endif
+}
+
+int __init ima_ns_init(void)
+{
+	return ima_init_namespace(&init_ima_ns);
+}
+
+struct ima_namespace init_ima_ns = {
+	.kref = KREF_INIT(1),
+	.user_ns = &init_user_ns,
+	.ucounts = NULL,
+	.parent = NULL,
+};
+EXPORT_SYMBOL(init_ima_ns);
diff --git a/security/integrity/ima/ima_ns.c b/security/integrity/ima/ima_ns.c
new file mode 100644
index 000000000000..8e37d7ac5d34
--- /dev/null
+++ b/security/integrity/ima/ima_ns.c
@@ -0,0 +1,162 @@
+/*
+ * Copyright (C) 2016-2018 IBM Corporation
+ * Author:
+ *  Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *  Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, version 2 of the License.
+ */
+
+#include <linux/user_namespace.h>
+#include <linux/proc_ns.h>
+#include <linux/kref.h>
+#include <linux/slab.h>
+#include <linux/ima.h>
+
+#include "ima.h"
+
+static struct ucounts *inc_ima_namespaces(struct user_namespace *ns)
+{
+	return inc_ucount(ns, current_euid(), UCOUNT_IMA_NAMESPACES);
+}
+
+static void dec_ima_namespaces(struct ucounts *ucounts)
+{
+	return dec_ucount(ucounts, UCOUNT_IMA_NAMESPACES);
+}
+
+/**
+ * Clone a new ns copying an original ima namespace, setting refcount to 1
+ *
+ * @user_ns: user namespace that current task runs in
+ * @old_ns: old ima namespace to clone
+ * Return ERR_PTR(-ENOMEM) on error (failure to kmalloc), new ns otherwise
+ */
+static struct ima_namespace *create_ima_ns(struct user_namespace *user_ns,
+					   struct ima_namespace *old_ns)
+{
+	struct ima_namespace *ns;
+	struct ucounts *ucounts;
+	int err;
+
+	err = -ENOSPC;
+	ucounts = inc_ima_namespaces(user_ns);
+	if (!ucounts)
+		goto fail;
+
+	err = -ENOMEM;
+	ns = kmalloc(sizeof(*ns), GFP_KERNEL);
+	if (!ns)
+		goto fail_dec;
+
+	err = ima_init_namespace(ns);
+	if (err)
+		goto fail_free;
+
+	kref_init(&ns->kref);
+	ns->ns.ops = &imans_operations;
+	ns->parent = get_ima_ns(old_ns);
+	ns->user_ns = get_user_ns(user_ns);
+	ns->ucounts = ucounts;
+
+	return ns;
+
+fail_free:
+	kfree(ns);
+fail_dec:
+	dec_ima_namespaces(ucounts);
+fail:
+	return ERR_PTR(err);
+}
+
+/**
+ * Copy task's ima namespace, or clone it if flags specifies CLONE_NEWNS.
+ *
+ * @bool: whether to copy or just get a reference to it
+ * @user_ns: user namespace that current task runs in
+ * @old_ns: old ima namespace to clone
+ */
+
+struct ima_namespace *copy_ima_ns(bool copy,
+				  struct user_namespace *user_ns,
+				  struct ima_namespace *old_ns)
+{
+	struct ima_namespace *new_ns;
+
+	get_ima_ns(old_ns);
+	if (!copy)
+		return old_ns;
+
+	new_ns = create_ima_ns(user_ns, old_ns);
+	put_ima_ns(old_ns);
+
+	return new_ns;
+}
+
+static void destroy_ima_ns(struct ima_namespace *ns)
+{
+	put_ima_ns(ns->parent);
+	put_user_ns(ns->user_ns);
+	ns_free_inum(&ns->ns);
+	dec_ima_namespaces(ns->ucounts);
+	kfree(ns);
+}
+
+void free_ima_ns(struct kref *kref)
+{
+	struct ima_namespace *ns;
+
+	ns = container_of(kref, struct ima_namespace, kref);
+
+	destroy_ima_ns(ns);
+}
+
+static struct ns_common *imans_get(struct task_struct *task)
+{
+	struct ima_namespace *ns = NULL;
+	struct nsproxy *nsproxy;
+
+	task_lock(task);
+	nsproxy = task->nsproxy;
+	if (nsproxy) {
+		ns = nsproxy->ima_ns;
+		get_ima_ns(ns);
+	}
+	task_unlock(task);
+
+	return ns ? &ns->ns : NULL;
+}
+
+static void imans_put(struct ns_common *ns)
+{
+	put_ima_ns(to_ima_ns(ns));
+}
+
+static int imans_install(struct nsproxy *nsproxy, struct ns_common *new)
+{
+	struct ima_namespace *ns = to_ima_ns(new);
+
+	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN) ||
+	    !ns_capable(current_user_ns(), CAP_SYS_ADMIN))
+		return -EPERM;
+
+	put_ima_ns(nsproxy->ima_ns);
+	nsproxy->ima_ns = get_ima_ns(ns);
+
+	return 0;
+}
+
+static struct user_namespace *imans_owner(struct ns_common *ns)
+{
+	return to_ima_ns(ns)->user_ns;
+}
+
+const struct proc_ns_operations imans_operations = {
+	.name = "ima",
+	.get = imans_get,
+	.put = imans_put,
+	.install = imans_install,
+	.owner = imans_owner,
+};
-- 
2.14.3
