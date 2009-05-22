From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 38/38] C/R: checkpoint/restart struct sighand_struct
Date: Fri, 22 May 2009 08:55:32 +0400
Message-ID: <1242968132-1044-38-git-send-email-adobriyan__49601.2423107915$1242970881$gmane$org@gmail.com>
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
 arch/x86/include/asm/signal.h  |    2 +
 include/linux/kstate-image.h   |   17 +++++
 include/linux/kstate.h         |   29 ++++++++
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    5 ++
 kernel/kstate/kstate-object.c  |    3 +
 kernel/kstate/kstate-task.c    |   32 +++++++++
 kernel/signal.c                |  140 ++++++++++++++++++++++++++++++++++++++++
 8 files changed, 234 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/signal.h b/arch/x86/include/asm/signal.h
index 7761a5d..f7c9040 100644
--- a/arch/x86/include/asm/signal.h
+++ b/arch/x86/include/asm/signal.h
@@ -140,6 +140,7 @@ struct sigaction {
 	__sigrestore_t sa_restorer;
 	sigset_t sa_mask;		/* mask last for extensibility */
 };
+#define sa_restorer sa_restorer
 
 struct k_sigaction {
 	struct sigaction sa;
@@ -170,6 +171,7 @@ struct sigaction {
 	__sigrestore_t sa_restorer;
 	sigset_t sa_mask;		/* mask last for extensibility */
 };
+#define sa_restorer sa_restorer
 
 struct k_sigaction {
 	struct sigaction sa;
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index 700fc62..38fb1a4 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -18,6 +18,9 @@ static inline int kstate_ref_undefined(kstate_ref_t *ref)
 	return ref->pos == 0 && ref->id == 0;
 }
 
+typedef __u8 kstate_sigset_t[16];
+typedef __u64 kstate_ptr_t;
+
 struct kstate_image_header {
 	/* Immutable part except version bumps. */
 #define KSTATE_IMAGE_MAGIC	"LinuxC/R"
@@ -56,6 +59,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_PID		16
 #define KSTATE_OBJ_FILES_STRUCT	17
 #define KSTATE_OBJ_FD		18
+#define KSTATE_OBJ_SIGHAND_STRUCT	19
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -88,6 +92,8 @@ struct kstate_image_task_struct {
 	kstate_ref_t	ref_pgid;
 	kstate_ref_t	ref_sid;
 
+	kstate_ref_t	ref_sighand;
+
 	__u8		comm[16];
 
 	/* Native arch of task, one of KSTATE_ARCH_*. */
@@ -334,4 +340,15 @@ struct kstate_image_fd {
 #define KSTATE_FD_FLAGS_CLOEXEC		(1 << 0)
 	__u32		fd_flags;
 } __packed;
+
+struct kstate_image_sighand_struct {
+	struct kstate_object_header hdr;
+
+	struct {
+		kstate_ptr_t	sa_handler;
+		__u64		sa_flags;
+		kstate_ptr_t	sa_restorer;
+		kstate_sigset_t	sa_mask;
+	} sa[128];
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 2473381..c958d1d 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -1,7 +1,9 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #ifndef __INCLUDE_LINUX_KSTATE_H
 #define __INCLUDE_LINUX_KSTATE_H
+#include <linux/compiler.h>
 #include <linux/list.h>
+#include <asm/signal.h>
 
 #include <linux/kstate-image.h>
 
@@ -36,6 +38,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_NSPROXY,
 	KSTATE_CTX_PID,
 	KSTATE_CTX_PID_NS,
+	KSTATE_CTX_SIGHAND_STRUCT,
 	KSTATE_CTX_TASK_STRUCT,
 	KSTATE_CTX_USER_NS,
 	KSTATE_CTX_USER_STRUCT,
@@ -70,6 +73,28 @@ void *kstate_prepare_image(__u32 type, unsigned int len);
 void *kstate_read_image(struct kstate_context *ctx, kstate_ref_t *ref, __u32 type, unsigned int len);
 int kstate_write_image(struct kstate_context *ctx, void *i, unsigned int len, struct kstate_object *obj);
 
+static inline kstate_ptr_t kstate_export_ptr(const void __user *ptr)
+{
+	BUILD_BUG_ON(sizeof(kstate_ptr_t) < sizeof(ptr));
+	return (unsigned long)ptr;
+}
+
+static inline const void __user *kstate_import_ptr(kstate_ptr_t i)
+{
+	return (const void __user *)(unsigned long)i;
+}
+
+static inline void kstate_dump_sigset(kstate_sigset_t *i, sigset_t *sig)
+{
+	BUILD_BUG_ON(sizeof(sigset_t) > sizeof(kstate_sigset_t));
+	memcpy(i, sig, sizeof(sigset_t));
+}
+
+static inline void kstate_restore_sigset(sigset_t *sig, kstate_sigset_t *i)
+{
+	memcpy(sig, i, sizeof(sigset_t));
+}
+
 int kstate_collect_all_task_struct(struct kstate_context *ctx);
 int kstate_dump_all_task_struct(struct kstate_context *ctx);
 int kstate_restore_task_struct(struct kstate_context *ctx, kstate_ref_t *ref);
@@ -155,6 +180,10 @@ int kstate_dump_all_files_struct(struct kstate_context *ctx);
 int kstate_restore_files_struct(struct kstate_context *ctx, kstate_ref_t *ref);
 int kstate_restore_fd(struct kstate_context *ctx, kstate_pos_t pos);
 
+int kstate_collect_all_sighand_struct(struct kstate_context *ctx);
+int kstate_dump_all_sighand_struct(struct kstate_context *ctx);
+int kstate_restore_sighand_struct(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 05fc9d8..8225804 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -104,6 +104,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_user_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_sighand_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_pid(ctx);
 	if (rv < 0)
 		return rv;
@@ -163,6 +166,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_all_pid(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_sighand_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_user_ns(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 3e1589f..44111d1 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -97,6 +97,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_SIGHAND_STRUCT) {
+		__cleanup_sighand((struct sighand_struct *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_TASK_STRUCT) {
 		put_task_struct((struct task_struct *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index bc27985..f871463 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -74,6 +74,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_PID_NS:
 		get_pid_ns((struct pid_namespace *)obj->o_obj);
 		break;
+	case KSTATE_CTX_SIGHAND_STRUCT:
+		atomic_inc(&((struct sighand_struct *)obj->o_obj)->count);
+		break;
 	case KSTATE_CTX_TASK_STRUCT:
 		get_task_struct((struct task_struct *)obj->o_obj);
 		break;
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
index 101fcb8..2cfcb8f 100644
--- a/kernel/kstate/kstate-task.c
+++ b/kernel/kstate/kstate-task.c
@@ -139,6 +139,9 @@ static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *ob
 	tmp = find_kstate_obj_by_ptr(ctx, tsk->files, KSTATE_CTX_FILES_STRUCT);
 	i->ref_files = tmp->o_ref;
 
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->sighand, KSTATE_CTX_SIGHAND_STRUCT);
+	i->ref_sighand = tmp->o_ref;
+
 	BUILD_BUG_ON(sizeof(i->comm) != sizeof(tsk->comm));
 	strlcpy((char *)i->comm, (const char *)tsk->comm, sizeof(i->comm));
 
@@ -402,6 +405,32 @@ static int restore_files(struct kstate_context *ctx, kstate_ref_t *ref)
 	return 0;
 }
 
+static int restore_sighand(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct sighand_struct *sighand;
+	struct kstate_object *tmp;
+	struct sighand_struct *old_sighand;
+	unsigned long flags;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_SIGHAND_STRUCT);
+	if (!tmp) {
+		rv = kstate_restore_sighand_struct(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_SIGHAND_STRUCT);
+	}
+	sighand = tmp->o_obj;
+
+	atomic_inc(&sighand->count);
+	old_sighand = current->sighand;
+	spin_lock_irqsave(&old_sighand->siglock, flags);
+	current->sighand = sighand;
+	spin_unlock_irqrestore(&old_sighand->siglock, flags);
+	__cleanup_sighand(old_sighand);
+	return 0;
+}
+
 struct task_struct_restore_context {
 	struct kstate_context *ctx;
 	struct kstate_image_task_struct *i;
@@ -468,6 +497,9 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = restore_files(ctx, &i->ref_files);
 	if (rv < 0)
 		goto out;
+	rv = restore_sighand(ctx, &i->ref_sighand);
+	if (rv < 0)
+		goto out;
 
 out:
 	tsk_ctx->rv = rv;
diff --git a/kernel/signal.c b/kernel/signal.c
index d803473..5d5dc13 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2,6 +2,7 @@
  *  linux/kernel/signal.c
  *
  *  Copyright (C) 1991, 1992  Linus Torvalds
+ *  Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  *
  *  1997-11-02  Modified for POSIX.1b signals by Richard Henderson
  *
@@ -2656,3 +2657,142 @@ void __init signals_init(void)
 {
 	sigqueue_cachep = KMEM_CACHE(sigqueue, SLAB_PANIC);
 }
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_sighand_struct(struct sighand_struct *sighand)
+{
+#ifdef CONFIG_SIGNALFD
+	if (waitqueue_active(&sighand->signalfd_wqh)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static int collect_sighand_struct(struct kstate_context *ctx, struct sighand_struct *sighand)
+{
+	int rv;
+
+	rv = check_sighand_struct(sighand);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, sighand, KSTATE_CTX_SIGHAND_STRUCT);
+	pr_debug("collect sighand_struct %p: rv %d\n", sighand, rv);
+	return rv;
+}
+
+int kstate_collect_all_sighand_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = collect_sighand_struct(ctx, tsk->sighand);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_SIGHAND_STRUCT) {
+		struct sighand_struct *sighand = obj->o_obj;
+		unsigned int cnt = atomic_read(&sighand->count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("sighand_struct %p has external references %lu:%u\n", sighand, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_sighand_struct(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct sighand_struct *sighand = obj->o_obj;
+	struct kstate_image_sighand_struct *i;
+	unsigned long flags;
+	int sig;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_SIGHAND_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	BUILD_BUG_ON(_NSIG > ARRAY_SIZE(i->sa));
+	spin_lock_irqsave(&sighand->siglock, flags);
+	for (sig = 0; sig < _NSIG; sig++) {
+		struct sigaction *sa = &sighand->action[sig].sa;
+
+		i->sa[sig].sa_handler = kstate_export_ptr(sa->sa_handler);
+		i->sa[sig].sa_flags = sa->sa_flags;
+#ifdef sa_restorer
+		i->sa[sig].sa_restorer = kstate_export_ptr(sa->sa_restorer);
+#endif
+		kstate_dump_sigset(&i->sa[sig].sa_mask, &sa->sa_mask);
+	}
+	spin_unlock_irqrestore(&sighand->siglock, flags);
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump sighand_struct %p: ref {%llu, %u}, rv %d\n", sighand, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_sighand_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_SIGHAND_STRUCT) {
+		rv = dump_sighand_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_sighand_struct(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_sighand_struct *i;
+	struct sighand_struct *sighand;
+	int sig;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_SIGHAND_STRUCT, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	sighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+	if (!sighand) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	atomic_set(&sighand->count, 1);
+
+	for (sig = 0; sig < _NSIG; sig++) {
+		struct sigaction *sa = &sighand->action[sig].sa;
+
+		sa->sa_handler = kstate_import_ptr(i->sa[sig].sa_handler);
+		sa->sa_flags = i->sa[sig].sa_flags;
+#ifdef sa_restorer
+		sa->sa_restorer = kstate_import_ptr(i->sa[sig].sa_restorer);
+#endif
+		kstate_restore_sigset(&sa->sa_mask, &i->sa[sig].sa_mask);
+	}
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, sighand, KSTATE_CTX_SIGHAND_STRUCT, ref);
+	if (rv < 0)
+		kmem_cache_free(sighand_cachep, sighand);
+	pr_debug("restore sighand_struct %p: ref {%llu, %u}, rv %d\n", sighand, (unsigned long long)ref->pos, ref->id, rv);
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
