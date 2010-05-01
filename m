From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 052/100] c/r: support for UTS namespace
Date: Sat,  1 May 2010 10:15:34 -0400
Message-ID: <1272723382-19470-53-git-send-email-orenl__36202.0702720203$1272727721$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This patch adds a "phase" of checkpoint that saves out information about any
namespaces the task(s) may have.  Do this by tracking the namespace objects
of the tasks and making sure that tasks with the same namespace that follow
get properly referenced in the checkpoint stream.

Changes[v21]:
  - Do not include checkpoint_hdr.h explicitly
  - Move utsns c/r code from checkpoint/namespace.c to kernel/utsname*.c
  - [Serge Hallyn] Remove namespace.o from kernel/checkpoint/Makefile
Changes[v20]:
  - Make uts_ns=n compile
Changes[v19]:
  - Restart to handle checkpoint images lacking {uts,ipc}-ns
Changes[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changes[v17]:
  - Collect nsproxy->uts_ns
  - Save uts string lengths once in ckpt_hdr_const
  - Save and restore all fields of uts-ns
  - Don't overwrite global uts-ns if !CONFIG_UTS_NS
  - Replace sys_unshare() with create_uts_ns()
  - Take uts_sem around access to uts data
Changes:
  - Remove the kernel restore path
  - Punt on nested namespaces
  - Use __NEW_UTS_LEN in nodename and domainname buffers
  - Add a note to Documentation/checkpoint/internals.txt to indicate where
    in the save/restore process the UTS information is kept
  - Store (and track) the objref of the namespace itself instead of the
    nsproxy (based on comments from Dave on IRC)
  - Remove explicit check for non-root nsproxy
  - Store the nodename and domainname lengths and use ckpt_write_string()
    to store the actual name strings
  - Catch failure of ckpt_obj_add_ptr() in ckpt_write_namespaces()
  - Remove "types" bitfield and use the "is this new" flag to determine
    whether or not we should write out a new ns descriptor
  - Replace kernel restore path
  - Move the namespace information to be directly after the task
    information record
  - Update Documentation to reflect new location of namespace info
  - Support checkpoint and restart of nested UTS namespaces

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h   |   29 ++++++++-
 include/linux/checkpoint_types.h |    6 ++
 include/linux/utsname.h          |    1 +
 kernel/checkpoint/checkpoint.c   |    5 +-
 kernel/checkpoint/process.c      |    2 +
 kernel/checkpoint/restart.c      |    6 ++
 kernel/nsproxy.c                 |   19 +++++-
 kernel/utsname.c                 |    3 +-
 kernel/utsname_sysctl.c          |  130 ++++++++++++++++++++++++++++++++++++++
 9 files changed, 195 insertions(+), 6 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f119991..b97217f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -24,8 +24,6 @@
 
 #endif
 
-#include <linux/utsname.h>
-
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
@@ -88,6 +86,8 @@ enum {
 #define CKPT_HDR_CPU CKPT_HDR_CPU
 	CKPT_HDR_NS,
 #define CKPT_HDR_NS CKPT_HDR_NS
+	CKPT_HDR_UTS_NS,
+#define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -147,6 +147,8 @@ enum obj_type {
 #define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_NS,
 #define CKPT_OBJ_NS CKPT_OBJ_NS
+	CKPT_OBJ_UTS_NS,
+#define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -158,9 +160,12 @@ struct ckpt_const {
 	/* mm */
 	__u16 at_vector_size;
 	/* uts */
+	__u16 uts_sysname_len;
+	__u16 uts_nodename_len;
 	__u16 uts_release_len;
 	__u16 uts_version_len;
 	__u16 uts_machine_len;
+	__u16 uts_domainname_len;
 } __attribute__((aligned(8)));
 
 /* checkpoint image header */
@@ -239,6 +244,26 @@ struct ckpt_hdr_task_ns {
 
 struct ckpt_hdr_ns {
 	struct ckpt_hdr h;
+	__s32 uts_objref;
+} __attribute__((aligned(8)));
+
+/* cannot include <linux/tty.h> from userspace, so define: */
+#define CKPT_NEW_UTS_LEN  64
+#ifdef __KERNEL__
+#include <linux/utsname.h>
+#if CKPT_NEW_UTS_LEN != __NEW_UTS_LEN
+#error CKPT_NEW_UTS_LEN size is wrong per linux/utsname.h
+#endif
+#endif
+
+struct ckpt_hdr_utsns {
+	struct ckpt_hdr h;
+	char sysname[CKPT_NEW_UTS_LEN + 1];
+	char nodename[CKPT_NEW_UTS_LEN + 1];
+	char release[CKPT_NEW_UTS_LEN + 1];
+	char version[CKPT_NEW_UTS_LEN + 1];
+	char machine[CKPT_NEW_UTS_LEN + 1];
+	char domainname[CKPT_NEW_UTS_LEN + 1];
 } __attribute__((aligned(8)));
 
 /* task's shared resources */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index e150182..86f3a06 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -22,6 +22,10 @@
 #include <linux/ktime.h>
 #include <linux/wait.h>
 
+struct ckpt_stats {
+	int uts_ns;
+};
+
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
@@ -71,6 +75,8 @@ struct ckpt_ctx {
 	struct completion complete;	/* container root and other tasks on */
 	wait_queue_head_t waitq;	/* start, end, and restart ordering */
 
+	struct ckpt_stats stats;	/* statistics */
+
 #define CKPT_MSG_LEN 1024
 	char fmt[CKPT_MSG_LEN];
 	char msg[CKPT_MSG_LEN];
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 69f3997..774001d 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -49,6 +49,7 @@ static inline void get_uts_ns(struct uts_namespace *ns)
 	kref_get(&ns->kref);
 }
 
+extern struct uts_namespace *create_uts_ns(void);
 extern struct uts_namespace *copy_utsname(unsigned long flags,
 					struct uts_namespace *ns);
 extern void free_uts_ns(struct kref *kref);
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index ab1081c..3736475 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -114,9 +114,12 @@ static void fill_kernel_const(struct ckpt_const *h)
 	/* mm->saved_auxv size */
 	h->at_vector_size = AT_VECTOR_SIZE;
 	/* uts */
+	h->uts_sysname_len = sizeof(uts->sysname);
+	h->uts_nodename_len = sizeof(uts->nodename);
 	h->uts_release_len = sizeof(uts->release);
 	h->uts_version_len = sizeof(uts->version);
 	h->uts_machine_len = sizeof(uts->machine);
+	h->uts_domainname_len = sizeof(uts->domainname);
 }
 
 /* write the checkpoint header */
@@ -262,8 +265,6 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	rcu_read_lock();
 	nsproxy = task_nsproxy(t);
-	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns)
-		ret = -EPERM;
 	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns)
 		ret = -EPERM;
 	/* no support for >1 private mntns */
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index 22fb938..68539bd 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -17,6 +17,8 @@
 #include <linux/futex.h>
 #include <linux/compat.h>
 #include <linux/poll.h>
+#include <linux/utsname.h>
+#include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 
 
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index c0fe147..e43c300 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -569,12 +569,18 @@ static int check_kernel_const(struct ckpt_const *h)
 	if (h->at_vector_size != AT_VECTOR_SIZE)
 		return -EINVAL;
 	/* uts */
+	if (h->uts_sysname_len != sizeof(uts->sysname))
+		return -EINVAL;
+	if (h->uts_nodename_len != sizeof(uts->nodename))
+		return -EINVAL;
 	if (h->uts_release_len != sizeof(uts->release))
 		return -EINVAL;
 	if (h->uts_version_len != sizeof(uts->version))
 		return -EINVAL;
 	if (h->uts_machine_len != sizeof(uts->machine))
 		return -EINVAL;
+	if (h->uts_domainname_len != sizeof(uts->domainname))
+		return -EINVAL;
 
 	return 0;
 }
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 7082283..84693e9 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -257,6 +257,10 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	if (ret < 0 || exists)
 		goto out;
 
+	ret = ckpt_obj_collect(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
+	if (ret < 0)
+		goto out;
+
 	/* TODO: collect other namespaces here */
  out:
 	put_nsproxy(nsproxy);
@@ -273,9 +277,14 @@ static int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr)
 	if (!h)
 		return -ENOMEM;
 
+	ret = checkpoint_obj(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
+	if (ret <= 0)
+		goto out;
+	h->uts_objref = ret;
 	/* TODO: Write other namespaces here */
 
 	ret = ckpt_write_obj(ctx, &h->h);
+ out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -294,7 +303,15 @@ static void *restore_ns(struct ckpt_ctx *ctx)
 	if (IS_ERR(h))
 		return (void *) h;
 
-	uts_ns = ctx->root_nsproxy->uts_ns;
+	if (h->uts_objref == 0)
+		uts_ns = ctx->root_nsproxy->uts_ns;
+	else
+		uts_ns = ckpt_obj_fetch(ctx, h->uts_objref, CKPT_OBJ_UTS_NS);
+	if (IS_ERR(uts_ns)) {
+		ret = PTR_ERR(uts_ns);
+		goto out;
+	}
+
 	ipc_ns = ctx->root_nsproxy->ipc_ns;
 	mnt_ns = ctx->root_nsproxy->mnt_ns;
 	net_ns = ctx->root_nsproxy->net_ns;
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 8a82b4b..c82ed83 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -14,8 +14,9 @@
 #include <linux/utsname.h>
 #include <linux/err.h>
 #include <linux/slab.h>
+#include <linux/checkpoint.h>
 
-static struct uts_namespace *create_uts_ns(void)
+struct uts_namespace *create_uts_ns(void)
 {
 	struct uts_namespace *uts_ns;
 
diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index a2cd77e..f29c1d4 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -14,6 +14,10 @@
 #include <linux/utsname.h>
 #include <linux/sysctl.h>
 
+#define CKPT_DFLAG  CKPT_DSYS
+#include <linux/nsproxy.h>
+#include <linux/checkpoint.h>
+
 static void *get_uts(ctl_table *table, int write)
 {
 	char *which = table->data;
@@ -105,9 +109,135 @@ static struct ctl_table uts_root_table[] = {
 	{}
 };
 
+#ifdef CONFIG_CHECKPOINT
+/*
+ * uts_ns  -  this needs to compile even for !CONFIG_UTS_NS, so
+ *   the code may not reside in kernel/utsname.c (which wouldn't
+ *   compile then).
+ */
+static int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct uts_namespace *uts_ns = ptr;
+	struct ckpt_hdr_utsns *h;
+	struct new_utsname *name;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(h->sysname, name->sysname, sizeof(name->sysname));
+	memcpy(h->nodename, name->nodename, sizeof(name->nodename));
+	memcpy(h->release, name->release, sizeof(name->release));
+	memcpy(h->version, name->version, sizeof(name->version));
+	memcpy(h->machine, name->machine, sizeof(name->machine));
+	memcpy(h->domainname, name->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+#ifdef CONFIG_UTS_NS
+static inline struct uts_namespace *ckpt_do_copy_uts_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_utsns *h)
+{
+	struct new_utsname *name = NULL;
+	struct uts_namespace *uts_ns;
+
+	uts_ns = create_uts_ns();
+	if (!uts_ns)
+		return ERR_PTR(-ENOMEM);
+
+	down_read(&uts_sem);
+	name = &uts_ns->name;
+	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
+	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
+	memcpy(name->release, h->release, sizeof(name->release));
+	memcpy(name->version, h->version, sizeof(name->version));
+	memcpy(name->machine, h->machine, sizeof(name->machine));
+	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
+	up_read(&uts_sem);
+	return uts_ns;
+}
+#else
+static inline struct uts_namespace *ckpt_do_copy_uts_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_utsns *h)
+{
+	struct uts_namespace *uts_ns;
+
+	/* complain if image contains multiple namespaces */
+	if (ctx->stats.uts_ns)
+		return ERR_PTR(-EEXIST);
+
+	uts_ns = current->nsproxy->uts_ns;
+	get_uts_ns(uts_ns);
+	return uts_ns;
+}
+#endif
+
+static void *restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *uts_ns;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return (void *) h;
+
+	uts_ns = ckpt_do_copy_uts_ns(ctx, h);
+	if (IS_ERR(uts_ns))
+		goto out;
+
+	ctx->stats.uts_ns++;
+out:
+	ckpt_hdr_put(ctx, h);
+	return (void *)uts_ns;
+}
+
+
+static int obj_uts_ns_grab(void *ptr)
+{
+	get_uts_ns((struct uts_namespace *) ptr);
+	return 0;
+}
+
+static void obj_uts_ns_drop(void *ptr, int lastref)
+{
+	put_uts_ns((struct uts_namespace *) ptr);
+}
+
+static int obj_uts_ns_users(void *ptr)
+{
+	return atomic_read(&((struct uts_namespace *) ptr)->kref.refcount);
+}
+
+/* uts_ns object */
+static struct ckpt_obj_ops ckpt_obj_utsns_ops = {
+	.obj_name = "UTS_NS",
+	.obj_type = CKPT_OBJ_UTS_NS,
+	.ref_drop = obj_uts_ns_drop,
+	.ref_grab = obj_uts_ns_grab,
+	.ref_users = obj_uts_ns_users,
+	.checkpoint = checkpoint_uts_ns,
+	.restore = restore_uts_ns,
+};
+
+static int __init checkpoint_register_utsname(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_utsns_ops);
+}
+#endif
+
 static int __init utsname_sysctl_init(void)
 {
 	register_sysctl_table(uts_root_table);
+#ifdef CONFIG_CHECKPOINT
+	checkpoint_register_utsname();
+#endif
 	return 0;
 }
 
-- 
1.6.3.3
