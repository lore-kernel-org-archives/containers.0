From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 28/38] C/R: formally checkpoint/restore struct ipc_namespace
Date: Fri, 22 May 2009 08:55:22 +0400
Message-ID: <1242968132-1044-28-git-send-email-adobriyan__35856.832835316$1242970279$gmane$org@gmail.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1242968132-1044-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

No IPC objects are done yet, only struct ipc_namespace itself and
tsk->nsproxy->ipc_ns skeleton.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/ipc_namespace.h  |    3 +
 include/linux/kstate-image.h   |    6 ++
 include/linux/kstate.h         |   19 ++++++++
 ipc/namespace.c                |  101 +++++++++++++++++++++++++++++++++++++++-
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    8 +++
 kernel/kstate/kstate-object.c  |    6 ++
 kernel/nsproxy.c               |   66 +++++++++++++++++++++++---
 8 files changed, 206 insertions(+), 9 deletions(-)

diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index e408722..2f75a2d 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -94,6 +94,7 @@ static inline int mq_init_ns(struct ipc_namespace *ns) { return 0; }
 #endif
 
 #if defined(CONFIG_IPC_NS)
+extern struct ipc_namespace *create_ipc_ns(void);
 extern struct ipc_namespace *copy_ipcs(unsigned long flags,
 				       struct ipc_namespace *ns);
 static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
@@ -105,6 +106,8 @@ static inline struct ipc_namespace *get_ipc_ns(struct ipc_namespace *ns)
 
 extern void put_ipc_ns(struct ipc_namespace *ns);
 #else
+#include <linux/sched.h>
+
 static inline struct ipc_namespace *copy_ipcs(unsigned long flags,
 		struct ipc_namespace *ns)
 {
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 2eef50b..43a1458 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -45,6 +45,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_PAGE		5
 #define KSTATE_OBJ_NSPROXY	6
 #define KSTATE_OBJ_UTS_NS	7
+#define KSTATE_OBJ_IPC_NS	8
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -211,6 +212,7 @@ struct kstate_image_nsproxy {
 	struct kstate_object_header hdr;
 
 	kstate_ref_t	ref_uts_ns;
+	kstate_ref_t	ref_ipc_ns;	/* KSTATE_REF_UNDEF if IPC_NS=n */
 } __packed;
 
 struct kstate_image_uts_ns {
@@ -223,4 +225,8 @@ struct kstate_image_uts_ns {
 	__u8		machine[64];
 	__u8		domainname[64];
 } __packed;
+
+struct kstate_image_ipc_ns {
+	struct kstate_object_header hdr;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index dba4803..61bed98 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -22,6 +22,9 @@ struct kstate_object {
 /* Not visible to userspace! */
 enum kstate_context_obj_type {
 	KSTATE_CTX_FILE,
+#ifdef CONFIG_IPC_NS
+	KSTATE_CTX_IPC_NS,
+#endif
 	KSTATE_CTX_MM_STRUCT,
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_TASK_STRUCT,
@@ -77,6 +80,22 @@ int kstate_collect_all_uts_ns(struct kstate_context *ctx);
 int kstate_dump_all_uts_ns(struct kstate_context *ctx);
 int kstate_restore_uts_ns(struct kstate_context *ctx, kstate_ref_t *ref);
 
+#ifdef CONFIG_IPC_NS
+int kstate_collect_all_ipc_ns(struct kstate_context *ctx);
+int kstate_dump_all_ipc_ns(struct kstate_context *ctx);
+int kstate_restore_ipc_ns(struct kstate_context *ctx, kstate_ref_t *ref);
+#else
+static inline int kstate_collect_all_ipc_ns(struct kstate_context *ctx)
+{
+	return 0;
+}
+
+static inline int kstate_dump_all_ipc_ns(struct kstate_context *ctx)
+{
+	return 0;
+}
+#endif
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/ipc/namespace.c b/ipc/namespace.c
index a1094ff..bfdc3dc 100644
--- a/ipc/namespace.c
+++ b/ipc/namespace.c
@@ -1,6 +1,7 @@
 /*
  * linux/ipc/namespace.c
  * Copyright (C) 2006 Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> OpenVZ, SWsoft Inc.
+ * Copyright (C) 2009 Parallels Holdings, Ltd.
  */
 
 #include <linux/ipc.h>
@@ -14,7 +15,7 @@
 
 #include "util.h"
 
-static struct ipc_namespace *create_ipc_ns(void)
+struct ipc_namespace *create_ipc_ns(void)
 {
 	struct ipc_namespace *ns;
 	int err;
@@ -132,3 +133,101 @@ void put_ipc_ns(struct ipc_namespace *ns)
 		free_ipc_ns(ns);
 	}
 }
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_ipc_ns(struct kstate_context *ctx, struct ipc_namespace *ipc_ns)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, ipc_ns, KSTATE_CTX_IPC_NS);
+	pr_debug("collect ipc_ns %p: rv %d\n", ipc_ns, rv);
+	return rv;
+}
+
+int kstate_collect_all_ipc_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = collect_ipc_ns(ctx, nsproxy->ipc_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_IPC_NS) {
+		struct ipc_namespace *ipc_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&ipc_ns->count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("ipc_ns %p has external references %lu:%u\n", ipc_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_ipc_ns(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct ipc_namespace *ipc_ns = obj->o_obj;
+	struct kstate_image_ipc_ns *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_IPC_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump ipc_ns %p: ref {%llu, %u}, rv %d\n", ipc_ns, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_ipc_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_IPC_NS) {
+		rv = dump_ipc_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_ipc_ns(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_ipc_ns *i;
+	struct ipc_namespace *ipc_ns;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_IPC_NS, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	ipc_ns = create_ipc_ns();
+	if (!ipc_ns) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+
+	/* FIXME */
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, ipc_ns, KSTATE_CTX_IPC_NS, ref);
+	if (rv < 0)
+		put_ipc_ns(ipc_ns);
+	pr_debug("restore ipc_ns %p: ref {%llu, %u}, rv %d\n", ipc_ns, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
+#endif
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 7d4681a..1b03de5 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -71,6 +71,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_ipc_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -133,6 +136,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_ipc_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 98dc0c0..c2449d5 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -1,5 +1,6 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/file.h>
+#include <linux/ipc_namespace.h>
 #include <linux/list.h>
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
@@ -37,6 +38,13 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+#ifdef CONFIG_IPC_NS
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_IPC_NS) {
+		put_ipc_ns((struct ipc_namespace *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
+#endif
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_MM_STRUCT) {
 		mmput((struct mm_struct *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index aeadd95..0056572 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -1,5 +1,6 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/fs.h>
+#include <linux/ipc_namespace.h>
 #include <linux/mm_types.h>
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
@@ -34,6 +35,11 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_FILE:
 		get_file((struct file *)obj->o_obj);
 		break;
+#ifdef CONFIG_IPC_NS
+	case KSTATE_CTX_IPC_NS:
+		get_ipc_ns((struct ipc_namespace *)obj->o_obj);
+		break;
+#endif
 	case KSTATE_CTX_MM_STRUCT:
 		atomic_inc(&((struct mm_struct *)obj->o_obj)->mm_users);
 		break;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b2a7ed3..7cb82e3 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -280,6 +280,12 @@ static int dump_nsproxy(struct kstate_context *ctx, struct kstate_object *obj)
 
 	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->uts_ns, KSTATE_CTX_UTS_NS);
 	i->ref_uts_ns = tmp->o_ref;
+#ifdef CONFIG_IPC_NS
+	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->ipc_ns, KSTATE_CTX_IPC_NS);
+	i->ref_ipc_ns = tmp->o_ref;
+#else
+	i->ref_ipc_ns = KSTATE_REF_UNDEF;
+#endif
 
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
@@ -320,13 +326,57 @@ static int restore_uts_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct
 	return 0;
 }
 
+#ifdef CONFIG_IPC_NS
+static int restore_ipc_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	struct ipc_namespace *ipc_ns;
+	struct kstate_object *tmp;
+	int rv;
+
+	if (kstate_ref_undefined(ref)) {
+		/*
+		 * IPC_NS=n => IPC_NS=y case: hope nobody is crazy enough
+		 * to depend on IPC_NS absence.
+		 */
+		ipc_ns = create_ipc_ns();
+		if (IS_ERR(ipc_ns))
+			return PTR_ERR(ipc_ns);
+		rv = kstate_restore_object(ctx, ipc_ns, KSTATE_CTX_IPC_NS, ref);
+		if (rv < 0) {
+			put_ipc_ns(ipc_ns);
+			return rv;
+		}
+		nsproxy->ipc_ns = ipc_ns;
+		return 0;
+	}
+	/* IPC_NS=y => IPC_NS=y case. */
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_IPC_NS);
+	if (!tmp) {
+		rv = kstate_restore_ipc_ns(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_IPC_NS);
+	}
+	ipc_ns = tmp->o_obj;
+
+	nsproxy->ipc_ns = get_ipc_ns(ipc_ns);
+	return 0;
+}
+#else
+static int restore_ipc_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	/* IPC_NS=n => IPC_NS=n case. */
+	if (kstate_ref_undefined(ref))
+		return 0;
+	/* IPC_NS=y => IPC_NS=n case. */
+	return -EINVAL;
+}
+#endif
+
 int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_nsproxy *i;
 	struct nsproxy *nsproxy;
-#ifdef CONFIG_IPC_NS
-	struct ipc_namespace *ipc_ns;
-#endif
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
 #ifdef CONFIG_NET_NS
@@ -347,11 +397,9 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	rv = restore_uts_ns(ctx, &i->ref_uts_ns, nsproxy);
 	if (rv < 0)
 		goto out_uts_ns;
-
-#ifdef CONFIG_IPC_NS
-	ipc_ns = ctx->init_tsk->nsproxy->ipc_ns;
-	nsproxy->ipc_ns = get_ipc_ns(ipc_ns);
-#endif
+	rv = restore_ipc_ns(ctx, &i->ref_ipc_ns, nsproxy);
+	if (rv < 0)
+		goto out_ipc_ns;
 
 	mnt_ns = ctx->init_tsk->nsproxy->mnt_ns;
 	get_mnt_ns(mnt_ns);
@@ -372,6 +420,8 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore nsproxy %p, ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_ipc_ns:
+	put_uts_ns(nsproxy->uts_ns);
 out_uts_ns:
 	kmem_cache_free(nsproxy_cachep, nsproxy);
 out_free_image:
-- 
1.5.6.5
