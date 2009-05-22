From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 31/38] C/R: formally checkpoint/restore struct net_namespace
Date: Fri, 22 May 2009 08:55:25 +0400
Message-ID: <1242968132-1044-31-git-send-email-adobriyan__43487.3360711665$1242969452$gmane$org@gmail.com>
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
 include/linux/kstate-image.h   |    6 ++
 include/linux/kstate.h         |   19 +++++++
 include/net/net_namespace.h    |    1 +
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    8 +++
 kernel/kstate/kstate-object.c  |    6 ++
 kernel/nsproxy.c               |   66 +++++++++++++++++++++++---
 net/core/net_namespace.c       |  102 +++++++++++++++++++++++++++++++++++++++-
 8 files changed, 205 insertions(+), 9 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 64328e1..8119f2b 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -48,6 +48,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_IPC_NS	8
 #define KSTATE_OBJ_MNT_NS	9
 #define KSTATE_OBJ_PID_NS	10
+#define KSTATE_OBJ_NET_NS	11
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -217,6 +218,7 @@ struct kstate_image_nsproxy {
 	kstate_ref_t	ref_ipc_ns;	/* KSTATE_REF_UNDEF if IPC_NS=n */
 	kstate_ref_t	ref_mnt_ns;
 	kstate_ref_t	ref_pid_ns;
+	kstate_ref_t	ref_net_ns;	/* KSTATE_REF_UNDEF if NET_NS=n */
 } __packed;
 
 struct kstate_image_uts_ns {
@@ -244,4 +246,8 @@ struct kstate_image_pid_ns {
 	kstate_ref_t	ref_parent;	/* KSTATE_REF_UNDEF if root pid_ns */
 	__u32		last_pid;
 } __packed;
+
+struct kstate_image_net_ns {
+	struct kstate_object_header hdr;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index c925cef..a2bea1a 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -27,6 +27,9 @@ enum kstate_context_obj_type {
 #endif
 	KSTATE_CTX_MM_STRUCT,
 	KSTATE_CTX_MNT_NS,
+#ifdef CONFIG_NET_NS
+	KSTATE_CTX_NET_NS,
+#endif
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_PID_NS,
 	KSTATE_CTX_TASK_STRUCT,
@@ -105,6 +108,22 @@ int kstate_collect_all_pid_ns(struct kstate_context *ctx);
 int kstate_dump_all_pid_ns(struct kstate_context *ctx);
 int kstate_restore_pid_ns(struct kstate_context *ctx, kstate_ref_t *ref);
 
+#ifdef CONFIG_NET_NS
+int kstate_collect_all_net_ns(struct kstate_context *ctx);
+int kstate_dump_all_net_ns(struct kstate_context *ctx);
+int kstate_restore_net_ns(struct kstate_context *ctx, kstate_ref_t *ref);
+#else
+static inline int kstate_collect_all_net_ns(struct kstate_context *ctx)
+{
+	return 0;
+}
+
+static inline int kstate_dump_all_net_ns(struct kstate_context *ctx)
+{
+	return 0;
+}
+#endif
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index ded434b..a48e765 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -107,6 +107,7 @@ static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
 extern struct list_head net_namespace_list;
 
 #ifdef CONFIG_NET_NS
+extern struct net *net_create(void);
 extern void __put_net(struct net *net);
 
 static inline struct net *get_net(struct net *net)
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index cbaf038..620998a 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -80,6 +80,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_pid_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_net_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -145,6 +148,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_net_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_mnt_ns(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 7cd1f45..423b45b 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -8,6 +8,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/utsname.h>
+#include <net/net_namespace.h>
 
 #include <linux/kstate.h>
 
@@ -57,6 +58,13 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+#ifdef CONFIG_NET_NS
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_NET_NS) {
+		put_net((struct net *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
+#endif
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_NSPROXY) {
 		put_nsproxy((struct nsproxy *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 13bb75c..d9b36fa 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -8,6 +8,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/utsname.h>
+#include <net/net_namespace.h>
 
 #include <linux/kstate.h>
 #include <linux/kstate-image.h>
@@ -48,6 +49,11 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_MNT_NS:
 		get_mnt_ns((struct mnt_namespace *)obj->o_obj);
 		break;
+#ifdef CONFIG_NET_NS
+	case KSTATE_CTX_NET_NS:
+		get_net((struct net *)obj->o_obj);
+		break;
+#endif
 	case KSTATE_CTX_NSPROXY:
 		get_nsproxy((struct nsproxy *)obj->o_obj);
 		break;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 0b1f66d..85c6677 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -290,6 +290,12 @@ static int dump_nsproxy(struct kstate_context *ctx, struct kstate_object *obj)
 	i->ref_mnt_ns = tmp->o_ref;
 	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->pid_ns, KSTATE_CTX_PID_NS);
 	i->ref_pid_ns = tmp->o_ref;
+#ifdef CONFIG_NET_NS
+	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->net_ns, KSTATE_CTX_NET_NS);
+	i->ref_net_ns = tmp->o_ref;
+#else
+	i->ref_net_ns = KSTATE_REF_UNDEF;
+#endif
 
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
@@ -408,13 +414,57 @@ static int restore_pid_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct
 	return 0;
 }
 
+#ifdef CONFIG_NET_NS
+static int restore_net_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	struct net *net_ns;
+	struct kstate_object *tmp;
+	int rv;
+
+	if (kstate_ref_undefined(ref)) {
+		/*
+		 * NET_NS=n => NET_NS=y case: hope nobody is crazy enough
+		 * to depend on NET_NS absence.
+		 */
+		net_ns = net_create();
+		if (IS_ERR(net_ns))
+			return PTR_ERR(net_ns);
+		rv = kstate_restore_object(ctx, net_ns, KSTATE_CTX_NET_NS, ref);
+		if (rv < 0) {
+			put_net(net_ns);
+			return rv;
+		}
+		nsproxy->net_ns = net_ns;
+		return 0;
+	}
+	/* NET_NS=y => NET_NS=y case. */
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_NET_NS);
+	if (!tmp) {
+		rv = kstate_restore_net_ns(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_NET_NS);
+	}
+	net_ns = tmp->o_obj;
+
+	nsproxy->net_ns = get_net(net_ns);
+	return 0;
+}
+#else
+static int restore_net_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	/* NET_NS=n => NET_NS=n case. */
+	if (kstate_ref_undefined(ref))
+		return 0;
+	/* NET_NS=y => NET_NS=n case. */
+	return -EINVAL;
+}
+#endif
+
 int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_nsproxy *i;
 	struct nsproxy *nsproxy;
-#ifdef CONFIG_NET_NS
-	struct net *net_ns;
-#endif
 	int rv;
 
 	i = kstate_read_image(ctx, ref,  KSTATE_OBJ_NSPROXY, sizeof(*i));
@@ -439,11 +489,9 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	rv = restore_pid_ns(ctx, &i->ref_pid_ns, nsproxy);
 	if (rv < 0)
 		goto out_pid_ns;
-
-#ifdef CONFIG_NET_NS
-	net_ns = ctx->init_tsk->nsproxy->net_ns;
-	nsproxy->net_ns = get_net(net_ns);
-#endif
+	rv = restore_net_ns(ctx, &i->ref_net_ns, nsproxy);
+	if (rv < 0)
+		goto out_net_ns;
 	kfree(i);
 
 	rv = kstate_restore_object(ctx, nsproxy, KSTATE_CTX_NSPROXY, ref);
@@ -452,6 +500,8 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore nsproxy %p, ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_net_ns:
+	put_pid_ns(nsproxy->pid_ns);
 out_pid_ns:
 	put_mnt_ns(nsproxy->mnt_ns);
 out_mnt_ns:
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6b3edc9..f0073db 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -1,8 +1,10 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/workqueue.h>
 #include <linux/rtnetlink.h>
 #include <linux/cache.h>
 #include <linux/slab.h>
 #include <linux/list.h>
+#include <linux/nsproxy.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/idr.h>
@@ -115,7 +117,7 @@ static void net_free(struct net *net)
 	kmem_cache_free(net_cachep, net);
 }
 
-static struct net *net_create(void)
+struct net *net_create(void)
 {
 	struct net *net;
 	int rv;
@@ -500,3 +502,101 @@ assign:
 	return 0;
 }
 EXPORT_SYMBOL_GPL(net_assign_generic);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_net_ns(struct kstate_context *ctx, struct net *net_ns)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, net_ns, KSTATE_CTX_NET_NS);
+	pr_debug("collect net_ns %p: rv %d\n", net_ns, rv);
+	return rv;
+}
+
+int kstate_collect_all_net_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = collect_net_ns(ctx, nsproxy->net_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NET_NS) {
+		struct net *net_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&net_ns->count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("net_ns %p has external references %lu:%u\n", net_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_net_ns(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct net *net_ns = obj->o_obj;
+	struct kstate_image_net_ns *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_NET_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump net_ns %p: ref {%llu, %u}, rv %d\n", net_ns, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_net_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NET_NS) {
+		rv = dump_net_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_net_ns(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_net_ns *i;
+	struct net *net_ns;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_NET_NS, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	net_ns = net_create();
+	if (!net_ns) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+
+	/* FIXME */
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, net_ns, KSTATE_CTX_NET_NS, ref);
+	if (rv < 0)
+		put_net(net_ns);
+	pr_debug("restore net_ns %p: ref {%llu, %u}, rv %d\n", net_ns, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
+#endif
-- 
1.5.6.5
