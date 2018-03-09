From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH v2 1/3] ima: extend clone() with IMA namespace support
Date: Fri,  9 Mar 2018 15:14:19 -0500
Message-ID: <20180309201421.6150-2-stefanb__29464.0778367922$1520626399$gmane$org@linux.vnet.ibm.com>
References: <20180309201421.6150-1-stefanb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180309201421.6150-1-stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

From: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Add new CONFIG_IMA_NS config option.  Let clone() create a new IMA
namespace upon CLONE_NEWNS flag. Add ima_ns data structure in nsproxy.
ima_ns is allocated and freed upon IMA namespace creation and exit.
Currently, the ima_ns contains no useful IMA data but only a dummy
interface. This patch creates the framework for namespacing the different
aspects of IMA (eg. IMA-audit, IMA-measurement, IMA-appraisal).

Changelog:
* Use CLONE_NEWNS instead of a new CLONE_NEWIMA flag
* Use existing ima.h headers
* Move the ima_namespace.c to security/integrity/ima/ima_ns.c
* Fix typo INFO->INO
* Each namespace free's itself, removed recursively free'ing
  until init_ima_ns from free_ima_ns()
* Moved ima_init_ns and related functions into own file that is
  always compiled
* Fixed putting of imans->parent
* Move IMA namespace creation from nsproxy into mount namespace
  code

Signed-off-by: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mehmet Kayaalp <mkayaalp-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/mount.h                               | 14 -----
 fs/namespace.c                           | 29 ++++++++--
 include/linux/ima.h                      | 67 +++++++++++++++++++++++
 include/linux/mount.h                    | 20 ++++++-
 init/Kconfig                             |  8 +++
 kernel/nsproxy.c                         |  1 +
 security/integrity/ima/Makefile          |  3 +-
 security/integrity/ima/ima.h             |  4 ++
 security/integrity/ima/ima_init.c        |  4 ++
 security/integrity/ima/ima_init_ima_ns.c | 38 +++++++++++++
 security/integrity/ima/ima_ns.c          | 91 ++++++++++++++++++++++++++++++++
 11 files changed, 260 insertions(+), 19 deletions(-)
 create mode 100644 security/integrity/ima/ima_init_ima_ns.c
 create mode 100644 security/integrity/ima/ima_ns.c

diff --git a/fs/mount.h b/fs/mount.h
index f39bc9da4d73..e19ebde97756 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -5,20 +5,6 @@
 #include <linux/ns_common.h>
 #include <linux/fs_pin.h>
 
-struct mnt_namespace {
-	atomic_t		count;
-	struct ns_common	ns;
-	struct mount *	root;
-	struct list_head	list;
-	struct user_namespace	*user_ns;
-	struct ucounts		*ucounts;
-	u64			seq;	/* Sequence number to prevent loops */
-	wait_queue_head_t poll;
-	u64 event;
-	unsigned int		mounts; /* # of mounts in the namespace */
-	unsigned int		pending_mounts;
-} __randomize_layout;
-
 struct mnt_pcp {
 	int mnt_count;
 	int mnt_writers;
diff --git a/fs/namespace.c b/fs/namespace.c
index 9d1374ab6e06..7f886c02278b 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -26,6 +26,7 @@
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
 #include <linux/sched/task.h>
+#include <linux/ima.h>
 
 #include "pnode.h"
 #include "internal.h"
@@ -2858,6 +2859,7 @@ static void dec_mnt_namespaces(struct ucounts *ucounts)
 
 static void free_mnt_ns(struct mnt_namespace *ns)
 {
+	put_ima_ns(ns->ima_ns);
 	ns_free_inum(&ns->ns);
 	dec_mnt_namespaces(ns->ucounts);
 	put_user_ns(ns->user_ns);
@@ -2873,11 +2875,13 @@ static void free_mnt_ns(struct mnt_namespace *ns)
  */
 static atomic64_t mnt_ns_seq = ATOMIC64_INIT(1);
 
-static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
+static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns,
+					  struct ima_namespace *ima_ns)
 {
 	struct mnt_namespace *new_ns;
 	struct ucounts *ucounts;
 	int ret;
+	int err;
 
 	ucounts = inc_mnt_namespaces(user_ns);
 	if (!ucounts)
@@ -2894,6 +2898,20 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
 		dec_mnt_namespaces(ucounts);
 		return ERR_PTR(ret);
 	}
+
+	if (ima_ns == NULL) {
+		new_ns->ima_ns = get_ima_ns(&init_ima_ns);
+	} else {
+		new_ns->ima_ns = copy_ima(user_ns, ima_ns);
+		if (IS_ERR(new_ns->ima_ns)) {
+			err = PTR_ERR(new_ns->ima_ns);
+			ns_free_inum(&new_ns->ns);
+			kfree(new_ns);
+			dec_mnt_namespaces(ucounts);
+			return ERR_PTR(err);
+		}
+	}
+
 	new_ns->ns.ops = &mntns_operations;
 	new_ns->seq = atomic64_add_return(1, &mnt_ns_seq);
 	atomic_set(&new_ns->count, 1);
@@ -2920,6 +2938,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	int copy_flags;
 
 	BUG_ON(!ns);
+	BUG_ON(!ns->ima_ns);
 
 	if (likely(!(flags & CLONE_NEWNS))) {
 		get_mnt_ns(ns);
@@ -2928,7 +2947,7 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 
 	old = ns->root;
 
-	new_ns = alloc_mnt_ns(user_ns);
+	new_ns = alloc_mnt_ns(user_ns, ns->ima_ns);
 	if (IS_ERR(new_ns))
 		return new_ns;
 
@@ -2989,7 +3008,8 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
  */
 static struct mnt_namespace *create_mnt_ns(struct vfsmount *m)
 {
-	struct mnt_namespace *new_ns = alloc_mnt_ns(&init_user_ns);
+	struct mnt_namespace *new_ns = alloc_mnt_ns(&init_user_ns,
+						    NULL);
 	if (!IS_ERR(new_ns)) {
 		struct mount *mnt = real_mount(m);
 		mnt->mnt_ns = new_ns;
@@ -3497,6 +3517,9 @@ static int mntns_install(struct nsproxy *nsproxy, struct ns_common *ns)
 	set_fs_root(fs, &root);
 
 	path_put(&root);
+
+	imans_install(nsproxy, ns);
+
 	return 0;
 }
 
diff --git a/include/linux/ima.h b/include/linux/ima.h
index 0e4647e0eb60..fd150dfde277 100644
--- a/include/linux/ima.h
+++ b/include/linux/ima.h
@@ -12,6 +12,7 @@
 
 #include <linux/fs.h>
 #include <linux/kexec.h>
+#include <linux/mount.h>
 struct linux_binprm;
 
 #ifdef CONFIG_IMA
@@ -105,4 +106,70 @@ static inline int ima_inode_removexattr(struct dentry *dentry,
 	return 0;
 }
 #endif /* CONFIG_IMA_APPRAISE */
+
+struct ima_namespace {
+	struct kref kref;
+	struct user_namespace *user_ns;
+	struct ima_namespace *parent;
+};
+
+extern struct ima_namespace init_ima_ns;
+
+void imans_install(struct nsproxy *nsproxy, struct ns_common *new);
+
+static inline struct ima_namespace *to_ima_ns(struct ns_common *ns)
+{
+	return container_of(ns, struct mnt_namespace, ns)->ima_ns;
+}
+
+#ifdef CONFIG_IMA_NS
+
+void free_ima_ns(struct kref *kref);
+
+static inline struct ima_namespace *get_ima_ns(struct ima_namespace *ns)
+{
+	BUG_ON(!ns);
+	if (ns)
+		kref_get(&ns->kref);
+	return ns;
+}
+
+static inline void put_ima_ns(struct ima_namespace *ns)
+{
+	BUG_ON(!ns);
+	if (ns)
+		kref_put(&ns->kref, free_ima_ns);
+}
+
+struct ima_namespace *copy_ima(struct user_namespace *user_ns,
+			       struct ima_namespace *old_ns);
+
+static inline struct ima_namespace *get_current_ns(void)
+{
+	return current->nsproxy->mnt_ns->ima_ns;
+}
+
+#else
+
+static inline struct ima_namespace *get_ima_ns(struct ima_namespace *ns)
+{
+	return ns;
+}
+
+static inline void put_ima_ns(struct ima_namespace *ns)
+{
+	return;
+}
+
+static inline struct ima_namespace *copy_ima(struct user_namespace *user_ns,
+					     struct ima_namespace *old_ns)
+{
+	return old_ns;
+}
+
+static inline struct ima_namespace *get_current_ns(void)
+{
+	return NULL;
+}
+#endif /* CONFIG_IMA_NS */
 #endif /* _LINUX_IMA_H */
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 45b1f56c6c2f..361c962ebd3d 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -16,11 +16,29 @@
 #include <linux/spinlock.h>
 #include <linux/seqlock.h>
 #include <linux/atomic.h>
+#include <linux/ns_common.h>
+#include <linux/wait.h>
 
 struct super_block;
 struct vfsmount;
 struct dentry;
-struct mnt_namespace;
+struct ima_namespace;
+
+struct mnt_namespace {
+	atomic_t		count;
+	struct ns_common	ns;
+	struct mount *	root;
+	struct list_head	list;
+	struct user_namespace	*user_ns;
+	struct ucounts		*ucounts;
+	u64			seq;	/* Sequence number to prevent loops */
+	wait_queue_head_t poll;
+	u64 event;
+	unsigned int		mounts; /* # of mounts in the namespace */
+	unsigned int		pending_mounts;
+	struct ima_namespace    *ima_ns;
+} __randomize_layout;
+
 
 #define MNT_NOSUID	0x01
 #define MNT_NODEV	0x02
diff --git a/init/Kconfig b/init/Kconfig
index a9a2e2c86671..a1ad5384e081 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -931,6 +931,14 @@ config NET_NS
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
+config IMA_NS
+	bool "IMA namespace"
+	depends on IMA
+	default y
+	help
+	  Allow the creation of IMA namespaces for each mount namespace.
+	  Namespaced IMA data enables having IMA features work separately
+	  for each mount namespace.
 
 endif # NAMESPACES
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f6c5d330059a..7d1a35362186 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -27,6 +27,7 @@
 #include <linux/syscalls.h>
 #include <linux/cgroup.h>
 #include <linux/perf_event.h>
+#include <linux/ima.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
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
index d52b487ad259..e98c11c7cf75 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -291,6 +291,10 @@ static inline int ima_read_xattr(struct dentry *dentry,
 
 #endif /* CONFIG_IMA_APPRAISE */
 
+int ima_ns_init(void);
+struct ima_namespace;
+int ima_init_namespace(struct ima_namespace *ns);
+
 /* LSM based policy rules require audit */
 #ifdef CONFIG_IMA_LSM_RULES
 
diff --git a/security/integrity/ima/ima_init.c b/security/integrity/ima/ima_init.c
index 2967d497a665..7f884a71fa1c 100644
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
index 000000000000..4b081dbfac07
--- /dev/null
+++ b/security/integrity/ima/ima_init_ima_ns.c
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2016-2018 IBM Corporation
+ * Author: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, version 2 of the License.
+ */
+
+#include <linux/export.h>
+#include <linux/user_namespace.h>
+#include <linux/ima.h>
+
+int ima_init_namespace(struct ima_namespace *ns)
+{
+	return 0;
+}
+
+int __init ima_ns_init(void)
+{
+	return ima_init_namespace(&init_ima_ns);
+}
+
+struct ima_namespace init_ima_ns = {
+	.kref = KREF_INIT(2),
+	.user_ns = &init_user_ns,
+	.parent = NULL,
+};
+EXPORT_SYMBOL(init_ima_ns);
+
+void imans_install(struct nsproxy *nsproxy, struct ns_common *new)
+{
+	struct ima_namespace *ns = to_ima_ns(new);
+
+	get_ima_ns(ns);
+	put_ima_ns(nsproxy->mnt_ns->ima_ns);
+	nsproxy->mnt_ns->ima_ns = ns;
+}
diff --git a/security/integrity/ima/ima_ns.c b/security/integrity/ima/ima_ns.c
new file mode 100644
index 000000000000..7ab4322c88ae
--- /dev/null
+++ b/security/integrity/ima/ima_ns.c
@@ -0,0 +1,91 @@
+/*
+ * Copyright (C) 2016-2018 IBM Corporation
+ * Author: Yuqiong Sun <suny-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, version 2 of the License.
+ */
+
+#include <linux/user_namespace.h>
+#include <linux/kref.h>
+#include <linux/slab.h>
+#include <linux/ima.h>
+#include <linux/mount.h>
+
+#include "ima.h"
+
+static struct ima_namespace *create_ima_ns(void)
+{
+	struct ima_namespace *ima_ns;
+
+	ima_ns = kmalloc(sizeof(*ima_ns), GFP_KERNEL);
+	if (ima_ns)
+		kref_init(&ima_ns->kref);
+
+	return ima_ns;
+}
+
+/**
+ * Clone a new ns copying an original ima namespace, setting refcount to 1
+ *
+ * @old_ns: old ima namespace to clone
+ * @user_ns: user namespace that current task runs in
+ * Return ERR_PTR(-ENOMEM) on error (failure to kmalloc), new ns otherwise
+ */
+static struct ima_namespace *clone_ima_ns(struct user_namespace *user_ns,
+					  struct ima_namespace *old_ns)
+{
+	struct ima_namespace *ns;
+
+	ns = create_ima_ns();
+	if (!ns)
+		return ERR_PTR(-ENOMEM);
+
+	get_ima_ns(old_ns);
+	ns->parent = old_ns;
+	ns->user_ns = get_user_ns(user_ns);
+
+	ima_init_namespace(ns);
+
+	return ns;
+}
+
+/**
+ * Copy task's ima namespace, or clone it if flags specifies CLONE_NEWNS.
+ *
+ * @flags: flags used in the clone syscall
+ * @user_ns: user namespace that current task runs in
+ * @old_ns: old ima namespace to clone
+ */
+
+struct ima_namespace *copy_ima(struct user_namespace *user_ns,
+			       struct ima_namespace *old_ns)
+{
+	struct ima_namespace *new_ns;
+
+	BUG_ON(!old_ns);
+	get_ima_ns(old_ns);
+
+	new_ns = clone_ima_ns(user_ns, old_ns);
+	put_ima_ns(old_ns);
+
+	return new_ns;
+}
+
+static void destroy_ima_ns(struct ima_namespace *ns)
+{
+	put_user_ns(ns->user_ns);
+	put_ima_ns(ns->parent);
+	kfree(ns);
+}
+
+void free_ima_ns(struct kref *kref)
+{
+	struct ima_namespace *ns;
+
+	ns = container_of(kref, struct ima_namespace, kref);
+	BUG_ON(ns == &init_ima_ns);
+
+	destroy_ima_ns(ns);
+}
-- 
2.13.6
