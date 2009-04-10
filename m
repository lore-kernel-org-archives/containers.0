From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 24/30] cr: deal with signals
Date: Fri, 10 Apr 2009 06:39:28 +0400
Message-ID: <20090410023928.GY27788__48130.7834190831$1239332004$gmane$org@x200.localdomain>
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

Dump signal_struct, sighand_struct.

FIXME: correstly restore, check everything

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h     |   28 ++++
 include/linux/signal.h |    1 
 kernel/cr/Makefile     |    1 
 kernel/cr/cpt-sys.c    |   12 +
 kernel/cr/cr-signal.c  |  301 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-task.c    |   14 ++
 kernel/cr/cr.h         |   19 +++
 kernel/fork.c          |    2 
 8 files changed, 377 insertions(+), 1 deletion(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -42,6 +42,8 @@ struct cr_object_header {
 #define CR_OBJ_FILES_STRUCT	11
 #define CR_OBJ_FD		12
 #define CR_OBJ_FS_STRUCT	13
+#define CR_OBJ_SIGNAL_STRUCT	14
+#define CR_OBJ_SIGHAND_STRUCT	15
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -66,6 +68,12 @@ struct cr_image_task_struct {
 	cr_pos_t	cr_pos_files;
 	cr_pos_t	cr_pos_nsproxy;
 
+	cr_pos_t	cr_pos_signal;
+	cr_pos_t	cr_pos_sighand;
+	__u8		cr_blocked[16];
+	__u8		cr_real_blocked[16];
+	__u8		cr_saved_sigmask[16];
+
 	__u8		cr_comm[16];
 
 	/* Native arch of task, one of CR_ARCH_*. */
@@ -233,6 +241,26 @@ struct cr_image_vma_content {
 	/* __u8 cr_data[cr_nr_pages * cr_page_size]; */
 } __packed;
 
+struct cr_image_signal_struct {
+	struct cr_object_header cr_hdr;
+
+	struct {
+		__u64	cr_rlim_cur;
+		__u64	cr_rlim_max;
+	} cr_rlim[16];
+} __packed;
+
+struct cr_image_sighand_struct {
+	struct cr_object_header cr_hdr;
+
+	struct {
+		__u64	cr_sa_handler;
+		__u64	cr_sa_flags;
+		__u64	cr_sa_restorer;
+		__u8	cr_sa_mask[16];
+	} cr_sa[128];
+} __packed;
+
 struct cr_image_fs_struct {
 	struct cr_object_header cr_hdr;
 
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -243,6 +243,7 @@ struct pt_regs;
 extern int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka, struct pt_regs *regs, void *cookie);
 extern void exit_signals(struct task_struct *tsk);
 
+extern struct kmem_cache *signal_cachep;
 extern struct kmem_cache *sighand_cachep;
 
 int unhandled_signal(struct task_struct *tsk, int sig);
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -6,6 +6,7 @@ cr-y += cr-fs.o
 cr-y += cr-mm.o
 cr-y += cr-nsproxy.o
 cr-y += cr-pid.o
+cr-y += cr-signal.o
 cr-y += cr-task.o
 cr-y += cr-uts.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -86,6 +86,12 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_fs_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_signal_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_all_sighand_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_pid(ctx);
 	if (rv < 0)
 		return rv;
@@ -140,6 +146,12 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_sighand_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_signal_struct(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-signal.c
@@ -0,0 +1,301 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_signal_struct(struct signal_struct *signal)
+{
+	/* FIXME locking */
+	if (!list_empty(&signal->posix_timers)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int cr_collect_signal_struct(struct cr_context *ctx, struct signal_struct *signal)
+{
+	int rv;
+
+	rv = cr_check_signal_struct(signal);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, signal, CR_CTX_SIGNAL_STRUCT);
+	printk("collect signal_struct %p: rv %d\n", signal, rv);
+	return rv;
+}
+
+int cr_collect_all_signal_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_collect_signal_struct(ctx, tsk->signal);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_SIGNAL_STRUCT) {
+		struct signal_struct *signal = obj->o_obj;
+		unsigned int cnt = atomic_read(&signal->count);
+
+		if (obj->o_count != cnt) {
+			printk("signal_struct %p has external references %lu:%u\n", signal, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_signal_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct signal_struct *signal = obj->o_obj;
+	struct cr_image_signal_struct *i;
+	int n;
+	int rv;
+
+	printk("dump signal_struct %p\n", signal);
+
+	i = cr_prepare_image(CR_OBJ_SIGNAL_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	BUILD_BUG_ON(RLIM_NLIMITS != 16);
+	for (n = 0; n < RLIM_NLIMITS; n++) {
+		i->cr_rlim[n].cr_rlim_cur = signal->rlim[n].rlim_cur;
+		i->cr_rlim[n].cr_rlim_max = signal->rlim[n].rlim_max;
+	}
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_signal_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_SIGNAL_STRUCT) {
+		rv = cr_dump_signal_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_restore_signal_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_signal_struct *i;
+	struct signal_struct *signal;
+	struct cr_object *obj;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_SIGNAL_STRUCT) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	signal = kmem_cache_zalloc(signal_cachep, GFP_KERNEL);
+	if (!signal) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	atomic_set(&signal->count, 1);
+	atomic_set(&signal->live, 1);
+
+	for (n = 0; n < RLIM_NLIMITS; n++) {
+		signal->rlim[n].rlim_cur = i->cr_rlim[n].cr_rlim_cur;
+		signal->rlim[n].rlim_max = i->cr_rlim[n].cr_rlim_max;
+	}
+	kfree(i);
+
+	obj = cr_object_create(signal);
+	if (!obj) {
+		kmem_cache_free(signal_cachep, signal);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_SIGNAL_STRUCT]);
+	printk("restore signal_struct %p, pos %lld\n", signal, (long long)pos);
+	return 0;
+
+}
+
+static int cr_check_sighand_struct(struct sighand_struct *sighand)
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
+static int cr_collect_sighand_struct(struct cr_context *ctx, struct sighand_struct *sighand)
+{
+	int rv;
+
+	rv = cr_check_sighand_struct(sighand);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, sighand, CR_CTX_SIGHAND_STRUCT);
+	printk("collect sighand_struct %p: rv %d\n", sighand, rv);
+	return rv;
+}
+
+int cr_collect_all_sighand_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_collect_sighand_struct(ctx, tsk->sighand);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_SIGHAND_STRUCT) {
+		struct sighand_struct *sighand = obj->o_obj;
+		unsigned int cnt = atomic_read(&sighand->count);
+
+		if (obj->o_count != cnt) {
+			printk("sighand_struct %p has external references %lu:%u\n", sighand, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_sighand_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct sighand_struct *sighand = obj->o_obj;
+	struct cr_image_sighand_struct *i;
+	int sig;
+	int rv;
+
+	printk("dump sighand_struct %p\n", sighand);
+
+	i = cr_prepare_image(CR_OBJ_SIGHAND_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	BUILD_BUG_ON(_NSIG > ARRAY_SIZE(i->cr_sa));
+	for (sig = 0; sig < _NSIG; sig++) {
+		struct sigaction *sa = &sighand->action[sig].sa;
+
+		i->cr_sa[sig].cr_sa_handler = cr_dump_ptr(sa->sa_handler);
+		i->cr_sa[sig].cr_sa_flags = sa->sa_flags;
+#if !defined(CONFIG_ALPHA) && !defined(CONFIG_IA64) && !defined(CONFIG_MIPS)
+		i->cr_sa[sig].cr_sa_restorer = cr_dump_ptr(sa->sa_restorer);
+#endif
+		cr_dump_sigset(i->cr_sa[sig].cr_sa_mask, &sa->sa_mask);
+	}
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_sighand_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_SIGHAND_STRUCT) {
+		rv = cr_dump_sighand_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int __cr_restore_sighand_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_sighand_struct *i;
+	struct sighand_struct *sighand;
+	struct cr_object *obj;
+	int sig;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_SIGHAND_STRUCT) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	sighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+	if (!sighand) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	atomic_set(&sighand->count, 1);
+
+	for (sig = 0; sig < _NSIG; sig++) {
+		struct sigaction *sa = &sighand->action[sig].sa;
+
+		sa->sa_handler = cr_restore_ptr(i->cr_sa[sig].cr_sa_handler);
+		sa->sa_flags = i->cr_sa[sig].cr_sa_flags;
+#if !defined(CONFIG_ALPHA) && !defined(CONFIG_IA64) && !defined(CONFIG_MIPS)
+		sa->sa_restorer = cr_restore_ptr(i->cr_sa[sig].cr_sa_restorer);
+#endif
+		cr_restore_sigset(&sa->sa_mask, i->cr_sa[sig].cr_sa_mask);
+	}
+	kfree(i);
+
+	obj = cr_object_create(sighand);
+	if (!obj) {
+		kmem_cache_free(sighand_cachep, sighand);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_SIGHAND_STRUCT]);
+	printk("restore sighand_struct %p, pos %lld\n", sighand, (long long)pos);
+	return 0;
+}
+
+int cr_restore_sighand_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct task_struct *tsk = current;
+	struct sighand_struct *sighand;
+	struct cr_object *tmp;
+	int rv;
+
+	tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_SIGHAND_STRUCT);
+	if (!tmp) {
+		rv = __cr_restore_sighand_struct(ctx, pos);
+		if (rv < 0)
+			return rv;
+		tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_SIGHAND_STRUCT);
+	}
+	sighand = tmp->o_obj;
+	__cleanup_sighand(tsk->sighand);
+	atomic_inc(&sighand->count);
+	tsk->sighand = sighand;
+	return 0;
+}
--- a/kernel/cr/cr-task.c
+++ b/kernel/cr/cr-task.c
@@ -132,6 +132,14 @@ static int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
 	tmp = cr_find_obj_by_ptr(ctx, tsk->files, CR_CTX_FILES_STRUCT);
 	i->cr_pos_files = tmp->o_pos;
 
+	tmp = cr_find_obj_by_ptr(ctx, tsk->signal, CR_CTX_SIGNAL_STRUCT);
+	i->cr_pos_signal = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->sighand, CR_CTX_SIGHAND_STRUCT);
+	i->cr_pos_sighand = tmp->o_pos;
+	cr_dump_sigset(i->cr_blocked, &tsk->blocked);
+	cr_dump_sigset(i->cr_real_blocked, &tsk->real_blocked);
+	cr_dump_sigset(i->cr_saved_sigmask, &tsk->saved_sigmask);
+
 	BUILD_BUG_ON(TASK_COMM_LEN != 16);
 	strlcpy((char *)i->cr_comm, (const char *)tsk->comm, sizeof(i->cr_comm));
 
@@ -196,6 +204,12 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = cr_restore_pid(ctx, i);
 	if (rv < 0)
 		goto out;
+	rv = cr_restore_sighand_struct(ctx, i->cr_pos_sighand);
+	if (rv < 0)
+		goto out;
+	cr_restore_sigset(&tsk->blocked, i->cr_blocked);
+	cr_restore_sigset(&tsk->real_blocked, i->cr_real_blocked);
+	cr_restore_sigset(&tsk->saved_sigmask, i->cr_saved_sigmask);
 
 	rv = 0;
 out:
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -29,6 +29,8 @@ enum cr_context_obj_type {
 	CR_CTX_NSPROXY,
 	CR_CTX_PID,
 	CR_CTX_PID_NS,
+	CR_CTX_SIGHAND_STRUCT,
+	CR_CTX_SIGNAL_STRUCT,
 	CR_CTX_TASK_STRUCT,
 	CR_CTX_UTS_NS,
 	NR_CR_CTX_TYPES
@@ -72,6 +74,17 @@ static inline void __user *cr_restore_ptr(__u64 ptr)
 	return (void __user *)(unsigned long)ptr;
 }
 
+static inline void cr_dump_sigset(__u8 *cr_image_sigset, sigset_t *sig)
+{
+	BUILD_BUG_ON(sizeof(sigset_t) > 16);
+	memcpy(cr_image_sigset, sig, sizeof(sigset_t));
+}
+
+static inline void cr_restore_sigset(sigset_t *sig, __u8 *cr_image_sigset)
+{
+	memcpy(sig, cr_image_sigset, sizeof(sigset_t));
+}
+
 int cr_collect_all_files_struct(struct cr_context *ctx);
 int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_fs_struct(struct cr_context *ctx);
@@ -79,6 +92,8 @@ int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_nsproxy(struct cr_context *ctx);
 int cr_collect_all_pid_ns(struct cr_context *ctx);
 int cr_collect_all_pid(struct cr_context *ctx);
+int cr_collect_all_sighand_struct(struct cr_context *ctx);
+int cr_collect_all_signal_struct(struct cr_context *ctx);
 int cr_collect_all_task_struct(struct cr_context *ctx);
 int cr_collect_all_uts_ns(struct cr_context *ctx);
 
@@ -89,6 +104,8 @@ int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_nsproxy(struct cr_context *ctx);
 int cr_dump_all_pid_ns(struct cr_context *ctx);
 int cr_dump_all_pid(struct cr_context *ctx);
+int cr_dump_all_sighand_struct(struct cr_context *ctx);
+int cr_dump_all_signal_struct(struct cr_context *ctx);
 int cr_dump_all_task_struct(struct cr_context *ctx);
 int cr_dump_all_uts_ns(struct cr_context *ctx);
 
@@ -99,6 +116,8 @@ int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
 int cr_restore_pid_ns(struct cr_context *ctx, loff_t pos);
 int cr_restore_pid(struct cr_context *ctx, struct cr_image_task_struct *i);
+int cr_restore_sighand_struct(struct cr_context *ctx, loff_t pos);
+int cr_restore_signal_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_task_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_uts_ns(struct cr_context *ctx, loff_t pos);
 
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -120,7 +120,7 @@ static inline void free_thread_info(struct thread_info *ti)
 #endif
 
 /* SLAB cache for signal_struct structures (tsk->signal) */
-static struct kmem_cache *signal_cachep;
+struct kmem_cache *signal_cachep;
 
 /* SLAB cache for sighand_struct structures (tsk->sighand) */
 struct kmem_cache *sighand_cachep;
