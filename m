From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 32/38] C/R: checkpoint/restore struct cred
Date: Fri, 22 May 2009 08:55:26 +0400
Message-ID: <1242968132-1044-32-git-send-email-adobriyan__17849.8839879923$1242970155$gmane$org@gmail.com>
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

->group_info, ->user will be done in next patches

FIXME: insufficient checks for capabilities at least.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |   25 ++++++
 include/linux/kstate.h         |    5 +
 kernel/cred.c                  |  164 ++++++++++++++++++++++++++++++++++++++++
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    5 +
 kernel/kstate/kstate-file.c    |   30 +++++++
 kernel/kstate/kstate-object.c  |    3 +
 kernel/kstate/kstate-task.c    |   55 +++++++++++++
 8 files changed, 293 insertions(+), 0 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 8119f2b..3e768ca 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -49,6 +49,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_MNT_NS	9
 #define KSTATE_OBJ_PID_NS	10
 #define KSTATE_OBJ_NET_NS	11
+#define KSTATE_OBJ_CRED		12
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -73,6 +74,9 @@ struct kstate_image_task_struct {
 	kstate_ref_t	ref_mm;
 	kstate_ref_t	ref_nsproxy;
 
+	kstate_ref_t	ref_real_cred;
+	kstate_ref_t	ref_cred;
+
 	__u8		comm[16];
 
 	/* Native arch of task, one of KSTATE_ARCH_*. */
@@ -207,6 +211,7 @@ struct kstate_image_file {
 	__u32		i_mode;
 	__u32		f_flags;
 	__u64		f_pos;
+	kstate_ref_t	ref_f_cred;
 	__u32		name_len;	/* including NUL */
 	/* __u8	name[name_len] */
 } __packed;
@@ -250,4 +255,24 @@ struct kstate_image_pid_ns {
 struct kstate_image_net_ns {
 	struct kstate_object_header hdr;
 } __packed;
+
+typedef __u64 kstate_cap_t;
+struct kstate_image_cred {
+	struct kstate_object_header hdr;
+
+	__u32		uid;
+	__u32		gid;
+	__u32		suid;
+	__u32		sgid;
+	__u32		euid;
+	__u32		egid;
+	__u32		fsuid;
+	__u32		fsgid;
+	__u32		securebits;
+
+	kstate_cap_t	cap_inheritable;
+	kstate_cap_t	cap_permitted;
+	kstate_cap_t	cap_effective;
+	kstate_cap_t	cap_bset;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index a2bea1a..bbed87b 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -21,6 +21,7 @@ struct kstate_object {
 
 /* Not visible to userspace! */
 enum kstate_context_obj_type {
+	KSTATE_CTX_CRED,
 	KSTATE_CTX_FILE,
 #ifdef CONFIG_IPC_NS
 	KSTATE_CTX_IPC_NS,
@@ -124,6 +125,10 @@ static inline int kstate_dump_all_net_ns(struct kstate_context *ctx)
 }
 #endif
 
+int kstate_collect_all_cred(struct kstate_context *ctx);
+int kstate_dump_all_cred(struct kstate_context *ctx);
+int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/cred.c b/kernel/cred.c
index 3a03918..9152c90 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -2,6 +2,7 @@
  *
  * Copyright (C) 2008 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public Licence
@@ -589,3 +590,166 @@ int set_create_files_as(struct cred *new, struct inode *inode)
 	return security_kernel_create_files_as(new, inode);
 }
 EXPORT_SYMBOL(set_create_files_as);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_cred(struct cred *cred)
+{
+#ifdef CONFIG_KEYS
+	if (cred->thread_keyring || cred->request_key_auth || cred->tgcred) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+#ifdef CONFIG_SECURITY
+	if (cred->security) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static int collect_cred(struct kstate_context *ctx, struct cred *cred)
+{
+	int rv;
+
+	rv = check_cred(cred);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, cred, KSTATE_CTX_CRED);
+	pr_debug("collect cred %p: rv %d\n", cred, rv);
+	return rv;
+}
+
+int kstate_collect_all_cred(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = collect_cred(ctx, (struct cred *)tsk->real_cred);
+		if (rv < 0)
+			return rv;
+		rv = collect_cred(ctx, (struct cred *)tsk->cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_FILE) {
+		struct file *file = obj->o_obj;
+
+		rv = collect_cred(ctx, (struct cred *)file->f_cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+		unsigned int cnt = atomic_read(&cred->usage);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("cred %p has external references %lu:%u\n", cred, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_cred(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct cred *cred = obj->o_obj;
+	struct kstate_image_cred *i;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_CRED, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->uid = cred->uid;
+	i->gid = cred->gid;
+	i->suid = cred->suid;
+	i->sgid = cred->sgid;
+	i->euid = cred->euid;
+	i->egid = cred->egid;
+	i->fsuid = cred->fsuid;
+	i->fsgid = cred->fsgid;
+	i->securebits = cred->securebits;
+
+	BUILD_BUG_ON(sizeof(kstate_cap_t) != sizeof(kernel_cap_t));
+	memcpy(&i->cap_inheritable, &cred->cap_inheritable, sizeof(kstate_cap_t));
+	memcpy(&i->cap_permitted, &cred->cap_permitted, sizeof(kstate_cap_t));
+	memcpy(&i->cap_effective, &cred->cap_effective, sizeof(kstate_cap_t));
+	memcpy(&i->cap_bset, &cred->cap_bset, sizeof(kstate_cap_t));
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump cred %p: ref {%llu, %u}, rv %d\n", cred, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_cred(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_CRED) {
+		rv = dump_cred(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_cred *i;
+	struct cred *cred;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_CRED, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	cred = kmem_cache_zalloc(cred_jar, GFP_KERNEL);
+	if (!cred) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	atomic_set(&cred->usage, 1);
+
+	cred->uid = i->uid;
+	cred->gid = i->gid;
+	cred->suid = i->suid;
+	cred->sgid = i->sgid;
+	cred->euid = i->euid;
+	cred->egid = i->egid;
+	cred->fsuid = i->fsuid;
+	cred->fsgid = i->fsgid;
+	cred->securebits = i->securebits;
+
+	memcpy(&cred->cap_inheritable, &i->cap_inheritable, sizeof(i->cap_inheritable));
+	memcpy(&cred->cap_permitted, &i->cap_permitted, sizeof(i->cap_permitted));
+	memcpy(&cred->cap_effective, &i->cap_effective, sizeof(i->cap_effective));
+	memcpy(&cred->cap_bset, &i->cap_bset, sizeof(i->cap_bset));
+
+	/* FIXME */
+	cred->group_info = get_group_info(&init_groups);
+	/* FIXME */
+	cred->user = get_uid(&root_user);
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, cred, KSTATE_CTX_CRED, ref);
+	if (rv < 0)
+		put_cred(cred);
+	pr_debug("restore cred %p: ref {%llu, %u}, rv %d\n", cred, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
+#endif
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 620998a..b990fd3 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -89,6 +89,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_cred(ctx);
+	if (rv < 0)
+		return rv;
 	return 0;
 }
 
@@ -142,6 +145,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_pid_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_cred(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 423b45b..01b6e5f 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -36,6 +36,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 {
 	struct kstate_object *obj, *tmp;
 
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_CRED) {
+		put_cred((struct cred *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_FILE) {
 		fput((struct file *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-file.c b/kernel/kstate/kstate-file.c
index 8f678cd..f378be3 100644
--- a/kernel/kstate/kstate-file.c
+++ b/kernel/kstate/kstate-file.c
@@ -86,6 +86,7 @@ int generic_file_checkpoint(struct file *file, struct kstate_context *ctx)
 {
 	struct kstate_object *obj;
 	struct kstate_image_file *i;
+	struct kstate_object *tmp;
 	struct kstat stat;
 	char *buf, *name;
 	int rv;
@@ -102,6 +103,9 @@ int generic_file_checkpoint(struct file *file, struct kstate_context *ctx)
 	/* Assume seeking over file doesn't have history. */
 	i->f_pos = file->f_pos;
 
+	tmp = find_kstate_obj_by_ptr(ctx, file->f_cred, KSTATE_CTX_CRED);
+	i->ref_f_cred = tmp->o_ref;
+
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf) {
 		rv = -ENOMEM;
@@ -154,6 +158,28 @@ int kstate_dump_all_file(struct kstate_context *ctx)
 	return 0;
 }
 
+static int file_restore_cred(struct kstate_context *ctx, kstate_ref_t *ref, struct file *file)
+{
+	struct cred *cred;
+	const struct cred *old_cred;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_CRED);
+	if (!tmp) {
+		rv = kstate_restore_cred(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_CRED);
+	}
+	cred = tmp->o_obj;
+
+	old_cred = file->f_cred;
+	rcu_assign_pointer(file->f_cred, get_cred(cred));
+	put_cred(old_cred);
+	return 0;
+}
+
 int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_file *i;
@@ -182,6 +208,10 @@ int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref)
 		rv = -EINVAL;
 		goto out_fput;
 	}
+
+	rv = file_restore_cred(ctx, &i->ref_f_cred, file);
+	if (rv < 0)
+		goto out_fput;
 	/* Assume seeking over file doesn't have history. */
 	if (vfs_llseek(file, i->f_pos, SEEK_SET) != i->f_pos) {
 		rv = -EINVAL;
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index d9b36fa..8000124 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -35,6 +35,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	list_add_tail(&obj->o_list, &ctx->obj[type]);
 
 	switch (type) {
+	case KSTATE_CTX_CRED:
+		get_cred((struct cred *)obj->o_obj);
+		break;
 	case KSTATE_CTX_FILE:
 		get_file((struct file *)obj->o_obj);
 		break;
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index de876fe..dc2387b 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -123,6 +123,11 @@ static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *ob
 	tmp = find_kstate_obj_by_ptr(ctx, tsk->nsproxy, KSTATE_CTX_NSPROXY);
 	i->ref_nsproxy = tmp->o_ref;
 
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->real_cred, KSTATE_CTX_CRED);
+	i->ref_real_cred = tmp->o_ref;
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->cred, KSTATE_CTX_CRED);
+	i->ref_cred = tmp->o_ref;
+
 	BUILD_BUG_ON(sizeof(i->comm) != sizeof(tsk->comm));
 	strlcpy((char *)i->comm, (const char *)tsk->comm, sizeof(i->comm));
 
@@ -149,6 +154,50 @@ int kstate_dump_all_task_struct(struct kstate_context *ctx)
 	return 0;
 }
 
+static int restore_real_cred(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct cred *cred;
+	const struct cred *old_cred;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_CRED);
+	if (!tmp) {
+		rv = kstate_restore_cred(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_CRED);
+	}
+	cred = tmp->o_obj;
+
+	old_cred = current->real_cred;
+	rcu_assign_pointer(current->real_cred, get_cred(cred));
+	put_cred(old_cred);
+	return 0;
+}
+
+static int restore_cred(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct cred *cred;
+	const struct cred *old_cred;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_CRED);
+	if (!tmp) {
+		rv = kstate_restore_cred(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_CRED);
+	}
+	cred = tmp->o_obj;
+
+	old_cred = current->cred;
+	rcu_assign_pointer(current->cred, get_cred(cred));
+	put_cred(old_cred);
+	return 0;
+}
+
 static int task_restore_all_vma(struct kstate_context *ctx, kstate_pos_t pos)
 {
 	while (1) {
@@ -279,6 +328,12 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = restore_nsproxy(ctx, &i->ref_nsproxy);
 	if (rv < 0)
 		goto out;
+	rv = restore_real_cred(ctx, &i->ref_real_cred);
+	if (rv < 0)
+		goto out;
+	rv = restore_cred(ctx, &i->ref_cred);
+	if (rv < 0)
+		goto out;
 
 out:
 	tsk_ctx->rv = rv;
-- 
1.5.6.5
