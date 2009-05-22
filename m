From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 33/38] C/R: checkpoint/restore aux groups (structy group_info)
Date: Fri, 22 May 2009 08:55:27 +0400
Message-ID: <1242968132-1044-33-git-send-email-adobriyan__41984.7288089388$1242969887$gmane$org@gmail.com>
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
 include/linux/kstate-image.h   |   10 +++
 include/linux/kstate.h         |    5 ++
 kernel/cred.c                  |   30 +++++++++-
 kernel/groups.c                |  125 ++++++++++++++++++++++++++++++++++++++++
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    5 ++
 kernel/kstate/kstate-object.c  |    3 +
 7 files changed, 182 insertions(+), 2 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 3e768ca..dfd71ea 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -50,6 +50,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_PID_NS	10
 #define KSTATE_OBJ_NET_NS	11
 #define KSTATE_OBJ_CRED		12
+#define KSTATE_OBJ_GROUP_INFO	13
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -274,5 +275,14 @@ struct kstate_image_cred {
 	kstate_cap_t	cap_permitted;
 	kstate_cap_t	cap_effective;
 	kstate_cap_t	cap_bset;
+
+	kstate_ref_t	ref_group_info;
+} __packed;
+
+struct kstate_image_group_info {
+	struct kstate_object_header hdr;
+
+	__u32		ngroups;
+	/* __u32	gid[ngroups]; */
 } __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index bbed87b..4df3bfa 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -23,6 +23,7 @@ struct kstate_object {
 enum kstate_context_obj_type {
 	KSTATE_CTX_CRED,
 	KSTATE_CTX_FILE,
+	KSTATE_CTX_GROUP_INFO,
 #ifdef CONFIG_IPC_NS
 	KSTATE_CTX_IPC_NS,
 #endif
@@ -129,6 +130,10 @@ int kstate_collect_all_cred(struct kstate_context *ctx);
 int kstate_dump_all_cred(struct kstate_context *ctx);
 int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref);
 
+int kstate_collect_all_group_info(struct kstate_context *ctx);
+int kstate_dump_all_group_info(struct kstate_context *ctx);
+int kstate_restore_group_info(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/cred.c b/kernel/cred.c
index 9152c90..8543360 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -662,6 +662,7 @@ static int dump_cred(struct kstate_context *ctx, struct kstate_object *obj)
 {
 	struct cred *cred = obj->o_obj;
 	struct kstate_image_cred *i;
+	struct kstate_object *tmp;
 	int rv;
 
 	i = kstate_prepare_image(KSTATE_OBJ_CRED, sizeof(*i));
@@ -684,6 +685,9 @@ static int dump_cred(struct kstate_context *ctx, struct kstate_object *obj)
 	memcpy(&i->cap_effective, &cred->cap_effective, sizeof(kstate_cap_t));
 	memcpy(&i->cap_bset, &cred->cap_bset, sizeof(kstate_cap_t));
 
+	tmp = find_kstate_obj_by_ptr(ctx, cred->group_info, KSTATE_CTX_GROUP_INFO);
+	i->ref_group_info = tmp->o_ref;
+
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
 	pr_debug("dump cred %p: ref {%llu, %u}, rv %d\n", cred, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
@@ -703,6 +707,25 @@ int kstate_dump_all_cred(struct kstate_context *ctx)
 	return 0;
 }
 
+static int restore_group_info(struct kstate_context *ctx, kstate_ref_t *ref, struct cred *cred)
+{
+	struct group_info *gi;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_GROUP_INFO);
+	if (!tmp) {
+		rv = kstate_restore_group_info(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_GROUP_INFO);
+	}
+	gi = tmp->o_obj;
+
+	cred->group_info = get_group_info(gi);
+	return 0;
+}
+
 int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_cred *i;
@@ -735,8 +758,9 @@ int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
 	memcpy(&cred->cap_effective, &i->cap_effective, sizeof(i->cap_effective));
 	memcpy(&cred->cap_bset, &i->cap_bset, sizeof(i->cap_bset));
 
-	/* FIXME */
-	cred->group_info = get_group_info(&init_groups);
+	rv = restore_group_info(ctx, &i->ref_group_info, cred);
+	if (rv < 0)
+		goto out_group_info;
 	/* FIXME */
 	cred->user = get_uid(&root_user);
 	kfree(i);
@@ -747,6 +771,8 @@ int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore cred %p: ref {%llu, %u}, rv %d\n", cred, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_group_info:
+	kmem_cache_free(cred_jar, cred);
 out_free_image:
 	kfree(i);
 	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
diff --git a/kernel/groups.c b/kernel/groups.c
index 1b95b2f..706681a 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -1,5 +1,6 @@
 /*
  * Supplementary group IDs
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  */
 #include <linux/cred.h>
 #include <linux/module.h>
@@ -286,3 +287,127 @@ int in_egroup_p(gid_t grp)
 }
 
 EXPORT_SYMBOL(in_egroup_p);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int collect_group_info(struct kstate_context *ctx, struct group_info *gi)
+{
+	int rv;
+
+	rv = kstate_collect_object(ctx, gi, KSTATE_CTX_GROUP_INFO);
+	pr_debug("collect group_info %p: rv %d\n", gi, rv);
+	return rv;
+}
+
+int kstate_collect_all_group_info(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+
+		rv = collect_group_info(ctx, cred->group_info);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_GROUP_INFO) {
+		struct group_info *gi = obj->o_obj;
+		unsigned int cnt = atomic_read(&gi->usage);
+
+		if (obj->o_count + 1 != cnt && gi != &init_groups) {
+			pr_err("group_info %p has external references %lu:%u\n", gi, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_group_info(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct group_info *gi = obj->o_obj;
+	struct kstate_image_group_info *i;
+	__u32 *gid;
+	unsigned int image_len;
+	int n;
+	int rv;
+
+	image_len = sizeof(*i) + gi->ngroups * sizeof(__u32);
+	i = kstate_prepare_image(KSTATE_OBJ_GROUP_INFO, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	i->ngroups = gi->ngroups;
+	gid = (__u32 *)(i + 1);
+	for (n = 0; n < gi->ngroups; n++)
+		gid[n] = GROUP_AT(gi, n);
+
+	rv = kstate_write_image(ctx, i, image_len, obj);
+	kfree(i);
+	pr_debug("dump group_info %p: ref {%llu, %u}, rv %d\n", gi, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_group_info(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_GROUP_INFO) {
+		rv = dump_group_info(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_group_info(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_group_info *i;
+	struct group_info *gi;
+	__u32 *gid;
+	int n;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_GROUP_INFO, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+	if (i->ngroups > NGROUPS_MAX) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	if (i->hdr.obj_len != sizeof(*i) + i->ngroups * sizeof(__u32)) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	gid = (__u32 *)(i + 1);
+	for (n = 1; n < i->ngroups; n++) {
+		if (gid[n - 1] >= gid[n]) {
+			rv = -EINVAL;
+			goto out_free_image;
+		}
+	}
+
+	gi = groups_alloc(i->ngroups);
+	if (!gi) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	for (n = 0; n < i->ngroups; n++)
+		GROUP_AT(gi, n) = gid[n];
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, gi, KSTATE_CTX_GROUP_INFO, ref);
+	if (rv < 0)
+		put_group_info(gi);
+	pr_debug("restore group_info %p: ref {%llu, %u}, rv %d\n", gi, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %d}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
+#endif
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index b990fd3..1b352c8 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -92,6 +92,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_cred(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_group_info(ctx);
+	if (rv < 0)
+		return rv;
 	return 0;
 }
 
@@ -145,6 +148,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_pid_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_group_info(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_cred(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 01b6e5f..51b28c0 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -46,6 +46,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_GROUP_INFO) {
+		put_group_info((struct group_info *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 #ifdef CONFIG_IPC_NS
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_IPC_NS) {
 		put_ipc_ns((struct ipc_namespace *)obj->o_obj);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 8000124..f6ce7a2 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -41,6 +41,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_FILE:
 		get_file((struct file *)obj->o_obj);
 		break;
+	case KSTATE_CTX_GROUP_INFO:
+		get_group_info((struct group_info *)obj->o_obj);
+		break;
 #ifdef CONFIG_IPC_NS
 	case KSTATE_CTX_IPC_NS:
 		get_ipc_ns((struct ipc_namespace *)obj->o_obj);
-- 
1.5.6.5
