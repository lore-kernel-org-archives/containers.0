From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 25/30] cr: deal with credentials
Date: Fri, 10 Apr 2009 06:39:50 +0400
Message-ID: <20090410023950.GZ27788__24760.1351621144$1239332006$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Dump/restore struct cred, struct user, struct user_namespace, struct group_info

FIXME: restore struct user
FIXME: restore struct file::f_cred

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h   |   46 ++++
 include/linux/cred.h |    1 
 kernel/cr/Kconfig    |    1 
 kernel/cr/Makefile   |    1 
 kernel/cr/cpt-sys.c  |   24 ++
 kernel/cr/cr-cred.c  |  514 +++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-file.c  |    2 
 kernel/cr/cr-task.c  |    8 
 kernel/cr/cr.h       |   14 +
 kernel/cred.c        |    2 
 10 files changed, 612 insertions(+), 1 deletion(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -44,6 +44,10 @@ struct cr_object_header {
 #define CR_OBJ_FS_STRUCT	13
 #define CR_OBJ_SIGNAL_STRUCT	14
 #define CR_OBJ_SIGHAND_STRUCT	15
+#define CR_OBJ_CRED		16
+#define CR_OBJ_GROUP_INFO	17
+#define CR_OBJ_USER_STRUCT	18
+#define CR_OBJ_USER_NS		19
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -74,6 +78,9 @@ struct cr_image_task_struct {
 	__u8		cr_real_blocked[16];
 	__u8		cr_saved_sigmask[16];
 
+	cr_pos_t	cr_pos_real_cred;
+	cr_pos_t	cr_pos_cred;
+
 	__u8		cr_comm[16];
 
 	/* Native arch of task, one of CR_ARCH_*. */
@@ -288,6 +295,7 @@ struct cr_image_file {
 		__u32	cr_euid;
 		__u32	cr_signum;
 	} cr_f_owner;
+	cr_pos_t	cr_pos_f_cred;
 	__u32		cr_name_len;
 	/* __u8	cr_name[cr_name_len] */
 } __packed;
@@ -301,6 +309,44 @@ struct cr_image_fd {
 	__u32		cr_fd_flags;
 } __packed;
 
+struct cr_image_cred {
+	struct cr_object_header cr_hdr;
+
+	__u32		cr_uid;
+	__u32		cr_gid;
+	__u32		cr_suid;
+	__u32		cr_sgid;
+	__u32		cr_euid;
+	__u32		cr_egid;
+	__u32		cr_fsuid;
+	__u32		cr_fsgid;
+	__u32		cr_securebits;
+	__u64		cr_cap_inheritable;
+	__u64		cr_cap_permitted;
+	__u64		cr_cap_effective;
+	__u64		cr_cap_bset;
+	cr_pos_t	cr_pos_user;
+	cr_pos_t	cr_pos_group_info;
+} __packed;
+
+struct cr_image_group_info {
+	struct cr_object_header cr_hdr;
+
+	__u32		cr_ngroups;
+	/* __u32 cr_gid[cr_ngroups]; */
+} __packed;
+
+struct cr_image_user_struct {
+	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_user_ns;
+	__u32		cr_uid;
+} __packed;
+
+struct cr_image_user_ns {
+	struct cr_object_header cr_hdr;
+} __packed;
+
 struct cr_image_pid {
 	struct cr_object_header cr_hdr;
 
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -142,6 +142,7 @@ struct cred {
 	struct rcu_head	rcu;		/* RCU deletion hook */
 };
 
+extern struct kmem_cache *cred_jar;
 extern void __put_cred(struct cred *);
 extern int copy_creds(struct task_struct *, unsigned long);
 extern struct cred *prepare_creds(void);
--- a/kernel/cr/Kconfig
+++ b/kernel/cr/Kconfig
@@ -1,6 +1,7 @@
 config CR
 	bool "Container checkpoint/restart"
 	depends on PID_NS
+	depends on USER_NS
 	depends on UTS_NS
 	select FREEZER
 	help
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_CR) += cr.o
 cr-y := cpt-sys.o rst-sys.o
 cr-y += cr-context.o
+cr-y += cr-cred.o
 cr-y += cr-file.o
 cr-y += cr-fs.o
 cr-y += cr-mm.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -92,6 +92,18 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_sighand_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_cred(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_all_group_info(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_all_user_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_all_user_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_pid(ctx);
 	if (rv < 0)
 		return rv;
@@ -134,6 +146,18 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_pid(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_user_ns(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_user_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_group_info(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_cred(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-cred.c
@@ -0,0 +1,514 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/cred.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/user_namespace.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_collect_group_info(struct cr_context *ctx, struct group_info *gi)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, gi, CR_CTX_GROUP_INFO);
+	printk("collect group_info %p: rv %d\n", gi, rv);
+	return rv;
+}
+
+int cr_collect_all_group_info(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+
+		rv = cr_collect_group_info(ctx, cred->group_info);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_GROUP_INFO) {
+		struct group_info *gi = obj->o_obj;
+		unsigned int cnt = atomic_read(&gi->usage);
+
+		if (obj->o_count != cnt) {
+			printk("%s: group_info %p has external references %lu:%u\n", __func__, gi, obj->o_count, cnt);
+			/* return -EINVAL; */
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_group_info(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct group_info *gi = obj->o_obj;
+	struct cr_image_group_info *i;
+	__u32 *cr_gid;
+	size_t image_len;
+	int n;
+	int rv;
+
+	printk("dump group_info %p: ngroups %d\n", gi, gi->ngroups);
+
+	image_len = sizeof(*i) + gi->ngroups * sizeof(__u32);
+	i = cr_prepare_image(CR_OBJ_GROUP_INFO, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_ngroups = gi->ngroups;
+	cr_gid = (__u32 *)(i + 1);
+	for (n = 0; n < gi->ngroups; n++)
+		cr_gid[n] = GROUP_AT(gi, n);
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, image_len);
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_group_info(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_GROUP_INFO) {
+		rv = cr_dump_group_info(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_restore_group_info(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_group_info *i, *tmp;
+	struct group_info *gi;
+	struct cr_object *obj;
+	size_t image_len;
+	__u32 *cr_gid;
+	int n;
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_GROUP_INFO) {
+		kfree(i);
+		return -EINVAL;
+	}
+	/* struct cr_image_group_info is variable-sized. */
+	image_len = sizeof(*i) + i->cr_ngroups * sizeof(__u32);
+	tmp = i;
+	i = krealloc(i, image_len, GFP_KERNEL);
+	if (!i) {
+		kfree(tmp);
+		return -ENOMEM;
+	}
+	rv = cr_pread(ctx, i + 1, image_len - sizeof(*i), pos + sizeof(*i));
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+
+	gi = groups_alloc(i->cr_ngroups);
+	if (!gi) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	cr_gid = (__u32 *)(i + 1);
+	for (n = 0; n < gi->ngroups; n++)
+		GROUP_AT(gi, n) = cr_gid[n];
+	kfree(i);
+
+	obj = cr_object_create(gi);
+	if (!obj) {
+		groups_free(gi);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_GROUP_INFO]);
+	printk("restore group_info %p, pos %lld\n", gi, (long long)pos);
+	return 0;
+}
+
+static int cr_check_user_struct(struct user_struct *user)
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
+static int cr_collect_user_struct(struct cr_context *ctx, struct user_struct *user)
+{
+	int rv;
+
+	rv = cr_check_user_struct(user);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, user, CR_CTX_USER_STRUCT);
+	printk("collect user_struct %p: rv %d\n", user, rv);
+	return rv;
+}
+
+int cr_collect_all_user_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+
+		rv = cr_collect_user_struct(ctx, cred->user);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_USER_STRUCT) {
+		struct user_struct *user = obj->o_obj;
+		unsigned int cnt = atomic_read(&user->__count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: user_struct %p/%d has external references %lu:%u\n", __func__, user, user->uid, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_user_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct user_struct *user = obj->o_obj;
+	struct cr_image_user_struct *i;
+	struct cr_object *tmp;
+	int rv;
+
+	printk("dump user_struct %p: uid %d\n", user, user->uid);
+
+	i = cr_prepare_image(CR_OBJ_USER_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, user->user_ns, CR_CTX_USER_NS);
+	i->cr_pos_user_ns = tmp->o_pos;
+	i->cr_uid = user->uid;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_user_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_USER_STRUCT) {
+		rv = cr_dump_user_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int cr_collect_user_ns(struct cr_context *ctx, struct user_namespace *user_ns)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, user_ns, CR_CTX_USER_NS);
+	printk("collect user_ns %p: rv %d\n", user_ns, rv);
+	return rv;
+}
+
+int cr_collect_all_user_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_USER_STRUCT) {
+		struct user_struct *user = obj->o_obj;
+
+		rv = cr_collect_user_ns(ctx, user->user_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_USER_NS) {
+		struct user_namespace *user_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&user_ns->kref.refcount);
+
+		if (obj->o_count != cnt) {
+			printk("%s: user_ns %p has external references %lu:%u\n", __func__, user_ns, obj->o_count, cnt);
+			/* return -EINVAL; */
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_user_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct user_namespace *user_ns = obj->o_obj;
+	struct cr_image_user_ns *i;
+	int rv;
+
+	printk("dump user_ns %p\n", user_ns);
+
+	i = cr_prepare_image(CR_OBJ_USER_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_user_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_USER_NS) {
+		rv = cr_dump_user_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int cr_check_cred(struct cred *cred)
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
+static int cr_collect_cred(struct cr_context *ctx, struct cred *cred)
+{
+	int rv;
+
+	rv = cr_check_cred(cred);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, cred, CR_CTX_CRED);
+	printk("collect cred %p: rv %d\n", cred, rv);
+	return rv;
+}
+
+int cr_collect_all_cred(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_collect_cred(ctx, (struct cred *)tsk->real_cred);
+		if (rv < 0)
+			return rv;
+		rv = cr_collect_cred(ctx, (struct cred *)tsk->cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+
+		rv = cr_collect_cred(ctx, (struct cred *)file->f_cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+		unsigned int cnt = atomic_read(&cred->usage);
+
+		if (obj->o_count != cnt) {
+			printk("%s: cred %p has external references %lu:%u\n", __func__, cred, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_cred(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct cred *cred = obj->o_obj;
+	struct cr_image_cred *i;
+	struct cr_object *tmp;
+	int rv;
+
+	printk("dump cred %p\n", cred);
+
+	i = cr_prepare_image(CR_OBJ_CRED, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_uid = cred->uid;
+	i->cr_gid = cred->gid;
+	i->cr_suid = cred->suid;
+	i->cr_sgid = cred->sgid;
+	i->cr_euid = cred->euid;
+	i->cr_egid = cred->egid;
+	i->cr_fsuid = cred->fsuid;
+	i->cr_fsgid = cred->fsgid;
+	i->cr_securebits = cred->securebits;
+	BUILD_BUG_ON(sizeof(cred->cap_inheritable) != 8);
+	memcpy(&i->cr_cap_inheritable, &cred->cap_inheritable, 8);
+	memcpy(&i->cr_cap_permitted, &cred->cap_permitted, 8);
+	memcpy(&i->cr_cap_effective, &cred->cap_effective, 8);
+	memcpy(&i->cr_cap_bset, &cred->cap_bset, 8);
+	tmp = cr_find_obj_by_ptr(ctx, cred->user, CR_CTX_USER_STRUCT);
+	i->cr_pos_user = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, cred->group_info, CR_CTX_GROUP_INFO);
+	i->cr_pos_group_info = tmp->o_pos;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_cred(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		rv = cr_dump_cred(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int __cr_restore_cred(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_cred *i;
+	struct cred *cred;
+	struct group_info *gi;
+	struct cr_object *obj, *tmp;
+	int rv;
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_CRED) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	cred = kmem_cache_zalloc(cred_jar, GFP_KERNEL);
+	if (!cred) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	atomic_set(&cred->usage, 1);
+
+	cred->uid = i->cr_uid;
+	cred->gid = i->cr_gid;
+	cred->suid = i->cr_suid;
+	cred->sgid = i->cr_sgid;
+	cred->euid = i->cr_euid;
+	cred->egid = i->cr_egid;
+	cred->fsuid = i->cr_fsuid;
+	cred->fsgid = i->cr_fsgid;
+	cred->securebits = i->cr_securebits;
+	memcpy(&cred->cap_inheritable, &i->cr_cap_inheritable, 8);
+	memcpy(&cred->cap_permitted, &i->cr_cap_permitted, 8);
+	memcpy(&cred->cap_effective, &i->cr_cap_effective, 8);
+	memcpy(&cred->cap_bset, &i->cr_cap_bset, 8);
+	atomic_inc(&root_user.__count);
+	cred->user = &root_user;	/* FIXME */
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_group_info, CR_CTX_GROUP_INFO);
+	if (!tmp) {
+		rv = cr_restore_group_info(ctx, i->cr_pos_group_info);
+		if (rv < 0) {
+			free_uid(cred->user);
+			kmem_cache_free(cred_jar, cred);
+			return rv;
+		}
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_group_info, CR_CTX_GROUP_INFO);
+	}
+	gi = tmp->o_obj;
+	cred->group_info = get_group_info(gi);
+	kfree(i);
+
+	obj = cr_object_create(cred);
+	if (!obj) {
+		put_cred(cred);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_CRED]);
+	printk("restore cred %p, pos %lld\n", cred, (long long)pos);
+	return 0;
+}
+
+int cr_restore_cred(struct cr_context *ctx, struct cr_image_task_struct *i)
+{
+	struct task_struct *tsk = current;
+	struct cred *cred;
+	struct cr_object *tmp;
+	int rv;
+
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_cred, CR_CTX_CRED);
+	if (!tmp) {
+		rv = __cr_restore_cred(ctx, i->cr_pos_cred);
+		if (rv < 0)
+			return rv;
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_cred, CR_CTX_CRED);
+	}
+	cred = tmp->o_obj;
+	put_cred(tsk->cred);
+	tsk->cred = get_cred(cred);
+
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_real_cred, CR_CTX_CRED);
+	if (!tmp) {
+		rv = __cr_restore_cred(ctx, i->cr_pos_real_cred);
+		if (rv < 0)
+			return rv;
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_real_cred, CR_CTX_CRED);
+	}
+	cred = tmp->o_obj;
+	put_cred(tsk->real_cred);
+	tsk->real_cred = get_cred(cred);
+	return 0;
+}
--- a/kernel/cr/cr-file.c
+++ b/kernel/cr/cr-file.c
@@ -133,6 +133,8 @@ int generic_file_checkpoint(struct file *file, struct cr_context *ctx)
 	i->cr_f_owner.cr_uid = file->f_owner.uid;
 	i->cr_f_owner.cr_euid = file->f_owner.euid;
 	i->cr_f_owner.cr_signum = file->f_owner.signum;
+	tmp = cr_find_obj_by_ptr(ctx, file->f_cred, CR_CTX_CRED);
+	i->cr_pos_f_cred = tmp->o_pos;
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf) {
--- a/kernel/cr/cr-task.c
+++ b/kernel/cr/cr-task.c
@@ -140,6 +140,11 @@ static int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
 	cr_dump_sigset(i->cr_real_blocked, &tsk->real_blocked);
 	cr_dump_sigset(i->cr_saved_sigmask, &tsk->saved_sigmask);
 
+	tmp = cr_find_obj_by_ptr(ctx, tsk->real_cred, CR_CTX_CRED);
+	i->cr_pos_real_cred = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->cred, CR_CTX_CRED);
+	i->cr_pos_cred = tmp->o_pos;
+
 	BUILD_BUG_ON(TASK_COMM_LEN != 16);
 	strlcpy((char *)i->cr_comm, (const char *)tsk->comm, sizeof(i->cr_comm));
 
@@ -210,6 +215,9 @@ static int task_struct_restorer(void *_tsk_ctx)
 	cr_restore_sigset(&tsk->blocked, i->cr_blocked);
 	cr_restore_sigset(&tsk->real_blocked, i->cr_real_blocked);
 	cr_restore_sigset(&tsk->saved_sigmask, i->cr_saved_sigmask);
+	rv = cr_restore_cred(ctx, i);
+	if (rv < 0)
+		goto out;
 
 	rv = 0;
 out:
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -22,9 +22,11 @@ struct cr_object {
 
 /* Not visible to userspace! */
 enum cr_context_obj_type {
+	CR_CTX_CRED,
 	CR_CTX_FILE,
 	CR_CTX_FILES_STRUCT,
 	CR_CTX_FS_STRUCT,
+	CR_CTX_GROUP_INFO,
 	CR_CTX_MM_STRUCT,
 	CR_CTX_NSPROXY,
 	CR_CTX_PID,
@@ -32,6 +34,8 @@ enum cr_context_obj_type {
 	CR_CTX_SIGHAND_STRUCT,
 	CR_CTX_SIGNAL_STRUCT,
 	CR_CTX_TASK_STRUCT,
+	CR_CTX_USER_NS,
+	CR_CTX_USER_STRUCT,
 	CR_CTX_UTS_NS,
 	NR_CR_CTX_TYPES
 };
@@ -85,9 +89,11 @@ static inline void cr_restore_sigset(sigset_t *sig, __u8 *cr_image_sigset)
 	memcpy(sig, cr_image_sigset, sizeof(sigset_t));
 }
 
+int cr_collect_all_cred(struct cr_context *ctx);
 int cr_collect_all_files_struct(struct cr_context *ctx);
 int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_fs_struct(struct cr_context *ctx);
+int cr_collect_all_group_info(struct cr_context *ctx);
 int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_nsproxy(struct cr_context *ctx);
 int cr_collect_all_pid_ns(struct cr_context *ctx);
@@ -95,11 +101,15 @@ int cr_collect_all_pid(struct cr_context *ctx);
 int cr_collect_all_sighand_struct(struct cr_context *ctx);
 int cr_collect_all_signal_struct(struct cr_context *ctx);
 int cr_collect_all_task_struct(struct cr_context *ctx);
+int cr_collect_all_user_ns(struct cr_context *ctx);
+int cr_collect_all_user_struct(struct cr_context *ctx);
 int cr_collect_all_uts_ns(struct cr_context *ctx);
 
+int cr_dump_all_cred(struct cr_context *ctx);
 int cr_dump_all_files_struct(struct cr_context *ctx);
 int cr_dump_all_file(struct cr_context *ctx);
 int cr_dump_all_fs_struct(struct cr_context *ctx);
+int cr_dump_all_group_info(struct cr_context *ctx);
 int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_nsproxy(struct cr_context *ctx);
 int cr_dump_all_pid_ns(struct cr_context *ctx);
@@ -107,11 +117,15 @@ int cr_dump_all_pid(struct cr_context *ctx);
 int cr_dump_all_sighand_struct(struct cr_context *ctx);
 int cr_dump_all_signal_struct(struct cr_context *ctx);
 int cr_dump_all_task_struct(struct cr_context *ctx);
+int cr_dump_all_user_ns(struct cr_context *ctx);
+int cr_dump_all_user_struct(struct cr_context *ctx);
 int cr_dump_all_uts_ns(struct cr_context *ctx);
 
+int cr_restore_cred(struct cr_context *ctx, struct cr_image_task_struct *i);
 int cr_restore_files_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_fs_struct(struct cr_context *ctx, loff_t pos);
+int cr_restore_group_info(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
 int cr_restore_pid_ns(struct cr_context *ctx, loff_t pos);
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -18,7 +18,7 @@
 #include <linux/cn_proc.h>
 #include "cred-internals.h"
 
-static struct kmem_cache *cred_jar;
+struct kmem_cache *cred_jar;
 
 /*
  * The common credentials for the initial task's thread group
