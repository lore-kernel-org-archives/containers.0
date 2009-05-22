From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 29/38] C/R: formally checkpoint/restore struct mnt_namespace
Date: Fri, 22 May 2009 08:55:23 +0400
Message-ID: <1242968132-1044-29-git-send-email-adobriyan__11996.1947588765$1242969386$gmane$org@gmail.com>
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

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/namespace.c                 |   70 ++++++++++++++++++++++++++++++++++++++++
 include/linux/kstate-image.h   |    6 +++
 include/linux/kstate.h         |    4 ++
 kernel/kstate/cpt-sys.c        |    6 +++
 kernel/kstate/kstate-context.c |    6 +++
 kernel/kstate/kstate-object.c  |    4 ++
 kernel/nsproxy.c               |   24 +++++++++++---
 7 files changed, 115 insertions(+), 5 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index be33bfc..ccd7b54 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3,6 +3,7 @@
  *
  * (C) Copyright Al Viro 2000, 2001
  *	Released under GPL v2.
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  *
  * Based on code from fs/super.c, copyright Linus Torvalds and others.
  * Heavily rewritten.
@@ -2309,3 +2310,72 @@ void __put_mnt_ns(struct mnt_namespace *ns)
 	release_mounts(&umount_list);
 	kfree(ns);
 }
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_mnt_ns(struct kstate_context *ctx, struct mnt_namespace *mnt_ns)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, mnt_ns, KSTATE_CTX_MNT_NS);
+	pr_debug("collect mnt_ns %p: rv %d\n", mnt_ns, rv);
+	return rv;
+}
+
+int kstate_collect_all_mnt_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = collect_mnt_ns(ctx, nsproxy->mnt_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_MNT_NS) {
+		struct mnt_namespace *mnt_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&mnt_ns->count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("mnt_ns %p has external references %lu:%u\n", mnt_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_mnt_ns(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct mnt_namespace *mnt_ns = obj->o_obj;
+	struct kstate_image_mnt_ns *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_MNT_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump mnt_ns %p: ref {%llu, %u}, rv %d\n", mnt_ns, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_mnt_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_MNT_NS) {
+		rv = dump_mnt_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+/* FIXME kstate_restore_mnt_ns() */
+#endif
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 43a1458..fa4921b 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -46,6 +46,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_NSPROXY	6
 #define KSTATE_OBJ_UTS_NS	7
 #define KSTATE_OBJ_IPC_NS	8
+#define KSTATE_OBJ_MNT_NS	9
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -213,6 +214,7 @@ struct kstate_image_nsproxy {
 
 	kstate_ref_t	ref_uts_ns;
 	kstate_ref_t	ref_ipc_ns;	/* KSTATE_REF_UNDEF if IPC_NS=n */
+	kstate_ref_t	ref_mnt_ns;
 } __packed;
 
 struct kstate_image_uts_ns {
@@ -229,4 +231,8 @@ struct kstate_image_uts_ns {
 struct kstate_image_ipc_ns {
 	struct kstate_object_header hdr;
 } __packed;
+
+struct kstate_image_mnt_ns {
+	struct kstate_object_header hdr;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 61bed98..43e2556 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -26,6 +26,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_IPC_NS,
 #endif
 	KSTATE_CTX_MM_STRUCT,
+	KSTATE_CTX_MNT_NS,
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_TASK_STRUCT,
 	KSTATE_CTX_UTS_NS,
@@ -96,6 +97,9 @@ static inline int kstate_dump_all_ipc_ns(struct kstate_context *ctx)
 }
 #endif
 
+int kstate_collect_all_mnt_ns(struct kstate_context *ctx);
+int kstate_dump_all_mnt_ns(struct kstate_context *ctx);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 1b03de5..0e3c74c 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -74,6 +74,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_ipc_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_mnt_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -136,6 +139,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_mnt_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_ipc_ns(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index c2449d5..700c0f4 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -2,6 +2,7 @@
 #include <linux/file.h>
 #include <linux/ipc_namespace.h>
 #include <linux/list.h>
+#include <linux/mnt_namespace.h>
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -50,6 +51,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_MNT_NS) {
+		put_mnt_ns((struct mnt_namespace *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_NSPROXY) {
 		put_nsproxy((struct nsproxy *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 0056572..6b1ab4a 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -2,6 +2,7 @@
 #include <linux/fs.h>
 #include <linux/ipc_namespace.h>
 #include <linux/mm_types.h>
+#include <linux/mnt_namespace.h>
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -43,6 +44,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_MM_STRUCT:
 		atomic_inc(&((struct mm_struct *)obj->o_obj)->mm_users);
 		break;
+	case KSTATE_CTX_MNT_NS:
+		get_mnt_ns((struct mnt_namespace *)obj->o_obj);
+		break;
 	case KSTATE_CTX_NSPROXY:
 		get_nsproxy((struct nsproxy *)obj->o_obj);
 		break;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 7cb82e3..4e22ec4 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -286,6 +286,8 @@ static int dump_nsproxy(struct kstate_context *ctx, struct kstate_object *obj)
 #else
 	i->ref_ipc_ns = KSTATE_REF_UNDEF;
 #endif
+	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->mnt_ns, KSTATE_CTX_MNT_NS);
+	i->ref_mnt_ns = tmp->o_ref;
 
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
@@ -373,11 +375,22 @@ static int restore_ipc_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct
 }
 #endif
 
+static int restore_mnt_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	struct mnt_namespace *mnt_ns;
+
+	/* FIXME */
+	mnt_ns = ctx->init_tsk->nsproxy->mnt_ns;
+
+	get_mnt_ns(mnt_ns);
+	nsproxy->mnt_ns = mnt_ns;
+	return 0;
+}
+
 int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_nsproxy *i;
 	struct nsproxy *nsproxy;
-	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
 #ifdef CONFIG_NET_NS
 	struct net *net_ns;
@@ -400,10 +413,9 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	rv = restore_ipc_ns(ctx, &i->ref_ipc_ns, nsproxy);
 	if (rv < 0)
 		goto out_ipc_ns;
-
-	mnt_ns = ctx->init_tsk->nsproxy->mnt_ns;
-	get_mnt_ns(mnt_ns);
-	nsproxy->mnt_ns = mnt_ns;
+	rv = restore_mnt_ns(ctx, &i->ref_mnt_ns, nsproxy);
+	if (rv < 0)
+		goto out_mnt_ns;
 
 	pid_ns = ctx->init_tsk->nsproxy->pid_ns;
 	nsproxy->pid_ns = get_pid_ns(pid_ns);
@@ -420,6 +432,8 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore nsproxy %p, ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_mnt_ns:
+	put_ipc_ns(nsproxy->ipc_ns);
 out_ipc_ns:
 	put_uts_ns(nsproxy->uts_ns);
 out_uts_ns:
-- 
1.5.6.5
