From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 26/38] C/R: nsproxy
Date: Fri, 22 May 2009 08:55:20 +0400
Message-ID: <1242968132-1044-26-git-send-email-adobriyan__37620.6570691012$1242971309$gmane$org@gmail.com>
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

It can't be argued, that nsproxy shouldn't even be dumped,
because pointers inside nsproxy are interesting. This is correct,
however this creates addtitional code on restart and frankly
more that several nsproxies are rare, so nobody cares.

Current algorithm is simplest:
- dump all namespaces
- dump nsproxy as KSTATE_OBJ_NSPROXY type filled with references
- on restore, read reference, read and restore namespace if needed,
  bump refcount, glue namespace to nsproxy.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |    6 ++
 include/linux/kstate.h         |    5 ++
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    6 ++
 kernel/kstate/kstate-object.c  |    4 +
 kernel/kstate/kstate-task.c    |   26 ++++++++
 kernel/nsproxy.c               |  129 +++++++++++++++++++++++++++++++++++++++-
 7 files changed, 181 insertions(+), 1 deletions(-)
 create mode 100644 kernel/kstate/kstate-nsproxy.c

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index d956d05..b8263c8 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -43,6 +43,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_FILE		3
 #define KSTATE_OBJ_VMA		4
 #define KSTATE_OBJ_PAGE		5
+#define KSTATE_OBJ_NSPROXY	6
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -65,6 +66,7 @@ struct kstate_image_task_struct {
 	kstate_ref_t	ref_real_parent;
 
 	kstate_ref_t	ref_mm;
+	kstate_ref_t	ref_nsproxy;
 
 	__u8		comm[16];
 
@@ -203,4 +205,8 @@ struct kstate_image_file {
 	__u32		name_len;	/* including NUL */
 	/* __u8	name[name_len] */
 } __packed;
+
+struct kstate_image_nsproxy {
+	struct kstate_object_header hdr;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 95898ec..bd5c9f1 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -23,6 +23,7 @@ struct kstate_object {
 enum kstate_context_obj_type {
 	KSTATE_CTX_FILE,
 	KSTATE_CTX_MM_STRUCT,
+	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_TASK_STRUCT,
 	NR_KSTATE_CTX_TYPES
 };
@@ -67,6 +68,10 @@ int kstate_collect_all_file(struct kstate_context *ctx);
 int kstate_dump_all_file(struct kstate_context *ctx);
 int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_nsproxy(struct kstate_context *ctx);
+int kstate_dump_all_nsproxy(struct kstate_context *ctx);
+int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 6bc1d0a..1d5e79d 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -65,6 +65,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_task_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_nsproxy(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -127,6 +130,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_nsproxy(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_task_struct(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 85d1514..8c728f5 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -1,6 +1,7 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/file.h>
 #include <linux/list.h>
+#include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 
@@ -40,6 +41,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_NSPROXY) {
+		put_nsproxy((struct nsproxy *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_TASK_STRUCT) {
 		put_task_struct((struct task_struct *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-nsproxy.c b/kernel/kstate/kstate-nsproxy.c
new file mode 100644
index 0000000..e69de29
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 60ba70d..078bd36 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -1,6 +1,7 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/fs.h>
 #include <linux/mm_types.h>
+#include <linux/nsproxy.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 
@@ -35,6 +36,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_MM_STRUCT:
 		atomic_inc(&((struct mm_struct *)obj->o_obj)->mm_users);
 		break;
+	case KSTATE_CTX_NSPROXY:
+		get_nsproxy((struct nsproxy *)obj->o_obj);
+		break;
 	case KSTATE_CTX_TASK_STRUCT:
 		get_task_struct((struct task_struct *)obj->o_obj);
 		break;
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index 4f48c32..de876fe 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -120,6 +120,9 @@ static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *ob
 	tmp = find_kstate_obj_by_ptr(ctx, tsk->mm, KSTATE_CTX_MM_STRUCT);
 	i->ref_mm = tmp->o_ref;
 
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->nsproxy, KSTATE_CTX_NSPROXY);
+	i->ref_nsproxy = tmp->o_ref;
+
 	BUILD_BUG_ON(sizeof(i->comm) != sizeof(tsk->comm));
 	strlcpy((char *)i->comm, (const char *)tsk->comm, sizeof(i->comm));
 
@@ -208,6 +211,26 @@ static int restore_mm(struct kstate_context *ctx, kstate_ref_t *ref)
 	return 0;
 }
 
+static int restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct nsproxy *nsproxy;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_NSPROXY);
+	if (!tmp) {
+		rv = kstate_restore_nsproxy(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_NSPROXY);
+	}
+	nsproxy = tmp->o_obj;
+
+	get_nsproxy(nsproxy);
+	switch_task_namespaces(current, nsproxy);
+	return 0;
+}
+
 struct task_struct_restore_context {
 	struct kstate_context *ctx;
 	struct kstate_image_task_struct *i;
@@ -253,6 +276,9 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = restore_mm(ctx, &i->ref_mm);
 	if (rv < 0)
 		goto out;
+	rv = restore_nsproxy(ctx, &i->ref_nsproxy);
+	if (rv < 0)
+		goto out;
 
 out:
 	tsk_ctx->rv = rv;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 09b4ff9..b7ccd68 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -1,5 +1,6 @@
 /*
  *  Copyright (C) 2006 IBM Corporation
+ *  Copyright (C) 2009 Parallels Holdings, Ltd.
  *
  *  Author: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
  *
@@ -26,7 +27,7 @@ static struct kmem_cache *nsproxy_cachep;
 
 struct nsproxy init_nsproxy = INIT_NSPROXY(init_nsproxy);
 
-static inline struct nsproxy *create_nsproxy(void)
+static struct nsproxy *create_nsproxy(void)
 {
 	struct nsproxy *nsproxy;
 
@@ -228,3 +229,129 @@ static int __init nsproxy_cache_init(void)
 }
 
 module_init(nsproxy_cache_init);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_nsproxy(struct kstate_context *ctx, struct nsproxy *nsproxy)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, nsproxy, KSTATE_CTX_NSPROXY);
+	pr_debug("collect nsproxy %p: rv %d\n", nsproxy, rv);
+	return rv;
+}
+
+int kstate_collect_all_nsproxy(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = collect_nsproxy(ctx, tsk->nsproxy);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+		unsigned int cnt = atomic_read(&nsproxy->count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("nsproxy %p has external references %lu:%u\n", nsproxy, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_nsproxy(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct nsproxy *nsproxy = obj->o_obj;
+	struct kstate_image_nsproxy *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_NSPROXY, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump nsproxy %p: ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_nsproxy(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		rv = dump_nsproxy(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_nsproxy *i;
+	struct nsproxy *nsproxy;
+	struct uts_namespace *uts_ns;
+#ifdef CONFIG_IPC_NS
+	struct ipc_namespace *ipc_ns;
+#endif
+	struct mnt_namespace *mnt_ns;
+	struct pid_namespace *pid_ns;
+#ifdef CONFIG_NET_NS
+	struct net *net_ns;
+#endif
+	int rv;
+
+	i = kstate_read_image(ctx, ref,  KSTATE_OBJ_NSPROXY, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	nsproxy = create_nsproxy();
+	if (!nsproxy) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+
+	uts_ns = ctx->init_tsk->nsproxy->uts_ns;
+	get_uts_ns(uts_ns);
+	nsproxy->uts_ns = uts_ns;
+
+#ifdef CONFIG_IPC_NS
+	ipc_ns = ctx->init_tsk->nsproxy->ipc_ns;
+	nsproxy->ipc_ns = get_ipc_ns(ipc_ns);
+#endif
+
+	mnt_ns = ctx->init_tsk->nsproxy->mnt_ns;
+	get_mnt_ns(mnt_ns);
+	nsproxy->mnt_ns = mnt_ns;
+
+	pid_ns = ctx->init_tsk->nsproxy->pid_ns;
+	nsproxy->pid_ns = get_pid_ns(pid_ns);
+
+#ifdef CONFIG_NET_NS
+	net_ns = ctx->init_tsk->nsproxy->net_ns;
+	nsproxy->net_ns = get_net(net_ns);
+#endif
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, nsproxy, KSTATE_CTX_NSPROXY, ref);
+	if (rv < 0)
+		put_nsproxy(nsproxy);
+	pr_debug("restore nsproxy %p, ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)ref->pos, ref->id, rv);
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
