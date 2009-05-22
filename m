From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 27/38] C/R: checkpoint/restore struct uts_namespace
Date: Fri, 22 May 2009 08:55:21 +0400
Message-ID: <1242968132-1044-27-git-send-email-adobriyan__39252.9025594287$1242969312$gmane$org@gmail.com>
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

The simplest thing.

Note, no locking is done, because we know:
a) tasks are frozen and thus can't change it
b) number of collected references is correct, so nobody else
   is using uts_namespace and thus can't change it under dump

If live checkpointing will be done, code will be changed
to something like:

	if (ctx->dump_live)
		down_read(&uts_sem);
		...
	if (ctx->dump_live)
		up_read(&uts_sem);

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |   14 +++++
 include/linux/kstate.h         |    5 ++
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    6 ++
 kernel/kstate/kstate-object.c  |    4 ++
 kernel/nsproxy.c               |   33 +++++++++++--
 kernel/utsname.c               |  106 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 170 insertions(+), 4 deletions(-)
 delete mode 100644 kernel/kstate/kstate-nsproxy.c
 create mode 100644 kernel/kstate/kstate-uts_ns.c

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index b8263c8..2eef50b 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -44,6 +44,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_VMA		4
 #define KSTATE_OBJ_PAGE		5
 #define KSTATE_OBJ_NSPROXY	6
+#define KSTATE_OBJ_UTS_NS	7
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -208,5 +209,18 @@ struct kstate_image_file {
 
 struct kstate_image_nsproxy {
 	struct kstate_object_header hdr;
+
+	kstate_ref_t	ref_uts_ns;
+} __packed;
+
+struct kstate_image_uts_ns {
+	struct kstate_object_header hdr;
+
+	__u8		sysname[64];
+	__u8		nodename[64];
+	__u8		release[64];
+	__u8		version[64];
+	__u8		machine[64];
+	__u8		domainname[64];
 } __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index bd5c9f1..dba4803 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -25,6 +25,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_MM_STRUCT,
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_TASK_STRUCT,
+	KSTATE_CTX_UTS_NS,
 	NR_KSTATE_CTX_TYPES
 };
 
@@ -72,6 +73,10 @@ int kstate_collect_all_nsproxy(struct kstate_context *ctx);
 int kstate_dump_all_nsproxy(struct kstate_context *ctx);
 int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_uts_ns(struct kstate_context *ctx);
+int kstate_dump_all_uts_ns(struct kstate_context *ctx);
+int kstate_restore_uts_ns(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 1d5e79d..7d4681a 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -68,6 +68,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_nsproxy(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_uts_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -130,6 +133,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_uts_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_nsproxy(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 8c728f5..98dc0c0 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -4,6 +4,7 @@
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/utsname.h>
 
 #include <linux/kstate.h>
 
@@ -51,5 +52,10 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_UTS_NS) {
+		put_uts_ns((struct uts_namespace *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	kfree(ctx);
 }
diff --git a/kernel/kstate/kstate-nsproxy.c b/kernel/kstate/kstate-nsproxy.c
deleted file mode 100644
index e69de29..0000000
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 078bd36..aeadd95 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -4,6 +4,7 @@
 #include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/utsname.h>
 
 #include <linux/kstate.h>
 #include <linux/kstate-image.h>
@@ -42,6 +43,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_TASK_STRUCT:
 		get_task_struct((struct task_struct *)obj->o_obj);
 		break;
+	case KSTATE_CTX_UTS_NS:
+		get_uts_ns((struct uts_namespace *)obj->o_obj);
+		break;
 	default:
 		BUG();
 	}
diff --git a/kernel/kstate/kstate-uts_ns.c b/kernel/kstate/kstate-uts_ns.c
new file mode 100644
index 0000000..e69de29
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b7ccd68..b2a7ed3 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -271,12 +271,16 @@ static int dump_nsproxy(struct kstate_context *ctx, struct kstate_object *obj)
 {
 	struct nsproxy *nsproxy = obj->o_obj;
 	struct kstate_image_nsproxy *i;
+	struct kstate_object *tmp;
 	int rv;
 
 	i = kstate_prepare_image(KSTATE_OBJ_NSPROXY, sizeof(*i));
 	if (!i)
 		return -ENOMEM;
 
+	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->uts_ns, KSTATE_CTX_UTS_NS);
+	i->ref_uts_ns = tmp->o_ref;
+
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
 	pr_debug("dump nsproxy %p: ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
@@ -296,11 +300,30 @@ int kstate_dump_all_nsproxy(struct kstate_context *ctx)
 	return 0;
 }
 
+static int restore_uts_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	struct uts_namespace *uts_ns;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_UTS_NS);
+	if (!tmp) {
+		rv = kstate_restore_uts_ns(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_UTS_NS);
+	}
+	uts_ns = tmp->o_obj;
+
+	get_uts_ns(uts_ns);
+	nsproxy->uts_ns = uts_ns;
+	return 0;
+}
+
 int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_nsproxy *i;
 	struct nsproxy *nsproxy;
-	struct uts_namespace *uts_ns;
 #ifdef CONFIG_IPC_NS
 	struct ipc_namespace *ipc_ns;
 #endif
@@ -321,9 +344,9 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 		goto out_free_image;
 	}
 
-	uts_ns = ctx->init_tsk->nsproxy->uts_ns;
-	get_uts_ns(uts_ns);
-	nsproxy->uts_ns = uts_ns;
+	rv = restore_uts_ns(ctx, &i->ref_uts_ns, nsproxy);
+	if (rv < 0)
+		goto out_uts_ns;
 
 #ifdef CONFIG_IPC_NS
 	ipc_ns = ctx->init_tsk->nsproxy->ipc_ns;
@@ -349,6 +372,8 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore nsproxy %p, ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_uts_ns:
+	kmem_cache_free(nsproxy_cachep, nsproxy);
 out_free_image:
 	kfree(i);
 	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
diff --git a/kernel/utsname.c b/kernel/utsname.c
index 8a82b4b..5b25e8d 100644
--- a/kernel/utsname.c
+++ b/kernel/utsname.c
@@ -1,5 +1,6 @@
 /*
  *  Copyright (C) 2004 IBM Corporation
+ *  Copyright (C) 2009 Parallels Holdings, Ltd.
  *
  *  Author: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
  *
@@ -73,3 +74,108 @@ void free_uts_ns(struct kref *kref)
 	ns = container_of(kref, struct uts_namespace, kref);
 	kfree(ns);
 }
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_uts_ns(struct kstate_context *ctx, struct uts_namespace *uts_ns)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, uts_ns, KSTATE_CTX_UTS_NS);
+	pr_debug("collect uts_ns %p: rv %d\n", uts_ns, rv);
+	return rv;
+}
+
+int kstate_collect_all_uts_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = collect_uts_ns(ctx, nsproxy->uts_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_UTS_NS) {
+		struct uts_namespace *uts_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&uts_ns->kref.refcount);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("uts_ns %p has external references %lu:%u\n", uts_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_uts_ns(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct uts_namespace *uts_ns = obj->o_obj;
+	struct kstate_image_uts_ns *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_UTS_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	strncpy(i->sysname, (const char *)uts_ns->name.sysname, 64);
+	strncpy(i->nodename, (const char *)uts_ns->name.nodename, 64);
+	strncpy(i->release, (const char *)uts_ns->name.release, 64);
+	strncpy(i->version, (const char *)uts_ns->name.version, 64);
+	strncpy(i->machine, (const char *)uts_ns->name.machine, 64);
+	strncpy(i->domainname, (const char *)uts_ns->name.domainname, 64);
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump uts_ns %p: ref {%llu, %u}, rv %d\n", uts_ns, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_uts_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_UTS_NS) {
+		rv = dump_uts_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_uts_ns(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_uts_ns *i;
+	struct uts_namespace *uts_ns;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_UTS_NS, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	uts_ns = create_uts_ns();
+	if (!uts_ns) {
+		kfree(i);
+		return -ENOMEM;
+	}
+
+	strlcpy(uts_ns->name.sysname, i->sysname, sizeof(uts_ns->name.sysname));
+	strlcpy(uts_ns->name.nodename, i->nodename, sizeof(uts_ns->name.nodename));
+	strlcpy(uts_ns->name.release, i->release, sizeof(uts_ns->name.release));
+	strlcpy(uts_ns->name.version, i->version, sizeof(uts_ns->name.version));
+	strlcpy(uts_ns->name.machine, i->machine, sizeof(uts_ns->name.machine));
+	strlcpy(uts_ns->name.domainname, i->domainname, sizeof(uts_ns->name.domainname));
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, uts_ns, KSTATE_CTX_UTS_NS, ref);
+	if (rv < 0)
+		put_uts_ns(uts_ns);
+	pr_debug("restore uts_ns %p: ref {%llu, %u}, rv %d\n", uts_ns, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+}
+#endif
-- 
1.5.6.5
