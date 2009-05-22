From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 35/38] C/R: checkpoint/restore struct user_namespace
Date: Fri, 22 May 2009 08:55:29 +0400
Message-ID: <1242968132-1044-35-git-send-email-adobriyan__17273.7716268331$1242969960$gmane$org@gmail.com>
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

We have first loop -- user->user_ns->creator (which is struct user_struct)

user_ns image references ->creator image but only partially because
user_namespaces are dumped before user_structs.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |   12 +++
 include/linux/kstate.h         |    5 ++
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    6 ++
 kernel/kstate/kstate-object.c  |    4 +
 kernel/user.c                  |   21 +++++-
 kernel/user_namespace.c        |  146 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 198 insertions(+), 2 deletions(-)
 delete mode 100644 kernel/kstate/kstate-uts_ns.c

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 605a2b5..a573833 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -52,6 +52,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_CRED		12
 #define KSTATE_OBJ_GROUP_INFO	13
 #define KSTATE_OBJ_USER_STRUCT	14
+#define KSTATE_OBJ_USER_NS	15
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -291,6 +292,17 @@ struct kstate_image_group_info {
 struct kstate_image_user_struct {
 	struct kstate_object_header hdr;
 
+	kstate_ref_t	ref_user_ns;
 	__u32		uid;
 } __packed;
+
+struct kstate_image_user_ns {
+	struct kstate_object_header hdr;
+
+	/*
+	 * KSTATE_REF_UNDEF if user_ns creator user was outside of container,
+	 * otherwise partial {0, id} reference.
+	 */
+	kstate_ref_t	ref_creator;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index dd6b982..f0c8e09 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -35,6 +35,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_PID_NS,
 	KSTATE_CTX_TASK_STRUCT,
+	KSTATE_CTX_USER_NS,
 	KSTATE_CTX_USER_STRUCT,
 	KSTATE_CTX_UTS_NS,
 	NR_KSTATE_CTX_TYPES
@@ -139,6 +140,10 @@ int kstate_collect_all_user_struct(struct kstate_context *ctx);
 int kstate_dump_all_user_struct(struct kstate_context *ctx);
 int kstate_restore_user_struct(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_user_ns(struct kstate_context *ctx);
+int kstate_dump_all_user_ns(struct kstate_context *ctx);
+int kstate_restore_user_ns(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index a409577..3df776e 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -98,6 +98,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_user_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_user_ns(ctx);
+	if (rv < 0)
+		return rv;
 	return 0;
 }
 
@@ -151,6 +154,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_pid_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_user_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_user_struct(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 854f971..f8168cc 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -7,6 +7,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/user_namespace.h>
 #include <linux/utsname.h>
 #include <net/net_namespace.h>
 
@@ -90,6 +91,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_USER_NS) {
+		put_user_ns((struct user_namespace *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_USER_STRUCT) {
 		free_uid((struct user_struct *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 75facda..eb77027 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -7,6 +7,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/user_namespace.h>
 #include <linux/utsname.h>
 #include <net/net_namespace.h>
 
@@ -69,6 +70,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_TASK_STRUCT:
 		get_task_struct((struct task_struct *)obj->o_obj);
 		break;
+	case KSTATE_CTX_USER_NS:
+		get_user_ns((struct user_namespace *)obj->o_obj);
+		break;
 	case KSTATE_CTX_USER_STRUCT:
 		get_uid((struct user_struct *)obj->o_obj);
 		break;
diff --git a/kernel/kstate/kstate-uts_ns.c b/kernel/kstate/kstate-uts_ns.c
deleted file mode 100644
index e69de29..0000000
diff --git a/kernel/user.c b/kernel/user.c
index 9fda1f0..508c05d 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -554,6 +554,10 @@ int kstate_collect_all_user_struct(struct kstate_context *ctx)
 		if (rv < 0)
 			return rv;
 	}
+	/*
+	 * Don't check refcounts here, user_ns->creator references weren't
+	 * accounted yet, it will fire every time CLONE_NEWUSER is used.
+	 */
 	return 0;
 }
 
@@ -561,12 +565,15 @@ static int dump_user_struct(struct kstate_context *ctx, struct kstate_object *ob
 {
 	struct user_struct *user = obj->o_obj;
 	struct kstate_image_user_struct *i;
+	struct kstate_object *tmp;
 	int rv;
 
 	i = kstate_prepare_image(KSTATE_OBJ_USER_STRUCT, sizeof(*i));
 	if (!i)
 		return -ENOMEM;
 
+	tmp = find_kstate_obj_by_ptr(ctx, user->user_ns, KSTATE_CTX_USER_NS);
+	i->ref_user_ns = tmp->o_ref;
 	i->uid = user->uid;
 
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
@@ -592,14 +599,24 @@ int kstate_restore_user_struct(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_user_struct *i;
 	struct user_struct *user;
+	struct user_namespace *user_ns;
+	struct kstate_object *tmp;
 	int rv;
 
 	i = kstate_read_image(ctx, ref, KSTATE_OBJ_USER_STRUCT, sizeof(*i));
 	if (IS_ERR(i))
 		return PTR_ERR(i);
 
-	/* FIXME */
-	user = alloc_uid(&init_user_ns, i->uid);
+	tmp = find_kstate_obj_by_ref(ctx, &i->ref_user_ns, KSTATE_CTX_USER_NS);
+	if (!tmp) {
+		rv = kstate_restore_user_ns(ctx, &i->ref_user_ns);
+		if (rv < 0)
+			goto out_free_image;
+		tmp = find_kstate_obj_by_ref(ctx, &i->ref_user_ns, KSTATE_CTX_USER_NS);
+	}
+	user_ns = tmp->o_obj;
+
+	user = alloc_uid(user_ns, i->uid);
 	if (!user) {
 		rv = -ENOMEM;
 		goto out_free_image;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 076c7c8..04ef11d 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -1,4 +1,6 @@
 /*
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
+ *
  *  This program is free software; you can redistribute it and/or
  *  modify it under the terms of the GNU General Public License as
  *  published by the Free Software Foundation, version 2 of the
@@ -82,3 +84,147 @@ void free_user_ns(struct kref *kref)
 	schedule_work(&ns->destroyer);
 }
 EXPORT_SYMBOL(free_user_ns);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_user_ns(struct kstate_context *ctx, struct user_namespace *user_ns)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, user_ns, KSTATE_CTX_USER_NS);
+	pr_debug("collect user_ns %p: rv %d\n", user_ns, rv);
+	return rv;
+}
+
+int kstate_collect_all_user_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_USER_STRUCT) {
+		struct user_struct *user = obj->o_obj;
+
+		rv = collect_user_ns(ctx, user->user_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_USER_NS) {
+		struct user_namespace *user_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&user_ns->kref.refcount);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("user_ns %p has external references %lu:%u\n", user_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	/*
+	 * user pins user_ns which pins user_ns->creator, that's why we don't
+	 * check for user refcount leaks right after user collecting.
+	 * Do it here after counting user_ns creators one more time except
+	 * those which are legitimately outside of container.
+	 */
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_USER_NS) {
+		struct user_namespace *user_ns = obj->o_obj;
+		struct kstate_object *tmp;
+
+		tmp = find_kstate_obj_by_ptr(ctx, user_ns->creator, KSTATE_CTX_USER_STRUCT);
+		if (tmp)
+			tmp->o_count++;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_USER_STRUCT) {
+		struct user_struct *user = obj->o_obj;
+		unsigned int cnt = atomic_read(&user->__count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("user_struct %p has external references %lu:%u\n", user, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_user_ns(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct user_namespace *user_ns = obj->o_obj;
+	struct kstate_image_user_ns *i;
+	struct kstate_object *tmp;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_USER_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = find_kstate_obj_by_ptr(ctx, user_ns->creator, KSTATE_CTX_USER_STRUCT);
+	if (!tmp)
+		i->ref_creator = KSTATE_REF_UNDEF;
+	else
+		i->ref_creator = tmp->o_ref;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump user_ns %p: ref {%llu, %u}, rv %d\n", user_ns, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_user_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_USER_NS) {
+		rv = dump_user_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_user_ns(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_user_ns *i;
+	struct user_namespace *user_ns;
+	int n;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_USER_NS, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	user_ns = kmalloc(sizeof(struct user_namespace), GFP_KERNEL);
+	if (!user_ns) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	kref_init(&user_ns->kref);
+	for (n = 0; n < UIDHASH_SZ; ++n)
+		INIT_HLIST_HEAD(user_ns->uidhash_table + n);
+	user_ns->creator = NULL;
+
+	if (kstate_ref_undefined(&i->ref_creator)) {
+		user_ns->creator = ctx->init_tsk->cred->user;
+	} else {
+		struct kstate_object *tmp;
+
+		tmp = find_kstate_obj_by_id(ctx, &i->ref_creator, KSTATE_CTX_USER_STRUCT);
+		if (!tmp) {
+			rv = -EINVAL;
+			goto out_free_image;
+		}
+		user_ns->creator = tmp->o_obj;
+	}
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, user_ns, KSTATE_CTX_USER_NS, ref);
+	if (rv < 0)
+		kfree(user_ns);
+	pr_debug("restore user_ns %p: ref {%llu, %u}, rv %d\n", user_ns, (unsigned long long)ref->pos, ref->id, rv);
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
