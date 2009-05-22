From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 34/38] C/R: checkpoint/restore struct user
Date: Fri, 22 May 2009 08:55:28 +0400
Message-ID: <1242968132-1044-34-git-send-email-adobriyan__48437.4485364698$1242970661$gmane$org@gmail.com>
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

Note, user_namespace is in next patch as well as ->creator loop issue.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |    8 +++
 include/linux/kstate.h         |    5 ++
 kernel/cred.c                  |   28 +++++++++-
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    5 ++
 kernel/kstate/kstate-object.c  |    3 +
 kernel/user.c                  |  121 ++++++++++++++++++++++++++++++++++++++++
 7 files changed, 174 insertions(+), 2 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index dfd71ea..605a2b5 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -51,6 +51,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_NET_NS	11
 #define KSTATE_OBJ_CRED		12
 #define KSTATE_OBJ_GROUP_INFO	13
+#define KSTATE_OBJ_USER_STRUCT	14
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -277,6 +278,7 @@ struct kstate_image_cred {
 	kstate_cap_t	cap_bset;
 
 	kstate_ref_t	ref_group_info;
+	kstate_ref_t	ref_user;
 } __packed;
 
 struct kstate_image_group_info {
@@ -285,4 +287,10 @@ struct kstate_image_group_info {
 	__u32		ngroups;
 	/* __u32	gid[ngroups]; */
 } __packed;
+
+struct kstate_image_user_struct {
+	struct kstate_object_header hdr;
+
+	__u32		uid;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 4df3bfa..dd6b982 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -35,6 +35,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_PID_NS,
 	KSTATE_CTX_TASK_STRUCT,
+	KSTATE_CTX_USER_STRUCT,
 	KSTATE_CTX_UTS_NS,
 	NR_KSTATE_CTX_TYPES
 };
@@ -134,6 +135,10 @@ int kstate_collect_all_group_info(struct kstate_context *ctx);
 int kstate_dump_all_group_info(struct kstate_context *ctx);
 int kstate_restore_group_info(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_user_struct(struct kstate_context *ctx);
+int kstate_dump_all_user_struct(struct kstate_context *ctx);
+int kstate_restore_user_struct(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/cred.c b/kernel/cred.c
index 8543360..a16f357 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -687,6 +687,8 @@ static int dump_cred(struct kstate_context *ctx, struct kstate_object *obj)
 
 	tmp = find_kstate_obj_by_ptr(ctx, cred->group_info, KSTATE_CTX_GROUP_INFO);
 	i->ref_group_info = tmp->o_ref;
+	tmp = find_kstate_obj_by_ptr(ctx, cred->user, KSTATE_CTX_USER_STRUCT);
+	i->ref_user = tmp->o_ref;
 
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
@@ -726,6 +728,25 @@ static int restore_group_info(struct kstate_context *ctx, kstate_ref_t *ref, str
 	return 0;
 }
 
+static int restore_user(struct kstate_context *ctx, kstate_ref_t *ref, struct cred *cred)
+{
+	struct user_struct *user;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_USER_STRUCT);
+	if (!tmp) {
+		rv = kstate_restore_user_struct(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_USER_STRUCT);
+	}
+	user = tmp->o_obj;
+
+	cred->user = get_uid(user);
+	return 0;
+}
+
 int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_cred *i;
@@ -761,8 +782,9 @@ int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
 	rv = restore_group_info(ctx, &i->ref_group_info, cred);
 	if (rv < 0)
 		goto out_group_info;
-	/* FIXME */
-	cred->user = get_uid(&root_user);
+	rv = restore_user(ctx, &i->ref_user, cred);
+	if (rv < 0)
+		goto out_user;
 	kfree(i);
 
 	rv = kstate_restore_object(ctx, cred, KSTATE_CTX_CRED, ref);
@@ -771,6 +793,8 @@ int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore cred %p: ref {%llu, %u}, rv %d\n", cred, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_user:
+	put_group_info(cred->group_info);
 out_group_info:
 	kmem_cache_free(cred_jar, cred);
 out_free_image:
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 1b352c8..a409577 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -95,6 +95,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_group_info(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_user_struct(ctx);
+	if (rv < 0)
+		return rv;
 	return 0;
 }
 
@@ -148,6 +151,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_pid_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_user_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_group_info(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 51b28c0..854f971 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -90,6 +90,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_USER_STRUCT) {
+		free_uid((struct user_struct *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_UTS_NS) {
 		put_uts_ns((struct uts_namespace *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index f6ce7a2..75facda 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -69,6 +69,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_TASK_STRUCT:
 		get_task_struct((struct task_struct *)obj->o_obj);
 		break;
+	case KSTATE_CTX_USER_STRUCT:
+		get_uid((struct user_struct *)obj->o_obj);
+		break;
 	case KSTATE_CTX_UTS_NS:
 		get_uts_ns((struct uts_namespace *)obj->o_obj);
 		break;
diff --git a/kernel/user.c b/kernel/user.c
index 850e0ba..9fda1f0 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -2,6 +2,7 @@
  * The "user cache".
  *
  * (C) Copyright 1991-2000 Linus Torvalds
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  *
  * We have a per-user structure to keep track of how many
  * processes, files etc the user has claimed, in order to be
@@ -497,3 +498,123 @@ static int __init uid_cache_init(void)
 }
 
 module_init(uid_cache_init);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_user_struct(struct user_struct *user)
+{
+#ifdef CONFIG_INOTIFY_USER
+	if (atomic_read(&user->inotify_watches) != 0) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (atomic_read(&user->inotify_devs) != 0) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+#ifdef CONFIG_EPOLL
+	if (atomic_read(&user->epoll_watches) != 0) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+#ifdef CONFIG_KEYS
+	if (user->uid_keyring || user->session_keyring) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static int collect_user_struct(struct kstate_context *ctx, struct user_struct *user)
+{
+	int rv;
+
+	rv = check_user_struct(user);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, user, KSTATE_CTX_USER_STRUCT);
+	pr_debug("collect user_struct %p: rv %d\n", user, rv);
+	return rv;
+}
+
+int kstate_collect_all_user_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+
+		rv = collect_user_struct(ctx, cred->user);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int dump_user_struct(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct user_struct *user = obj->o_obj;
+	struct kstate_image_user_struct *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_USER_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->uid = user->uid;
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump user_struct %p: ref {%llu, %u}, rv %d\n", user, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_user_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_USER_STRUCT) {
+		rv = dump_user_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_user_struct(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_user_struct *i;
+	struct user_struct *user;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_USER_STRUCT, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	/* FIXME */
+	user = alloc_uid(&init_user_ns, i->uid);
+	if (!user) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, user, KSTATE_CTX_USER_STRUCT, ref);
+	if (rv < 0)
+		free_uid(user);
+	pr_debug("restore user_struct %p: ref {%llu, %u}, rv %d\n", user, (unsigned long long)ref->pos, ref->id, rv);
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
