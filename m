From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 30/38] C/R: checkpoint/restore struct pid_namespace
Date: Fri, 22 May 2009 08:55:24 +0400
Message-ID: <1242968132-1044-30-git-send-email-adobriyan__25610.2565130734$1242969461$gmane$org@gmail.com>
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

pidns are hierarchical, so we dump parent pidns first.
On restore, parent task is restored first and restores parent pidns
for itself, which means that when child restores its pidns,
parent pidns already exists.

This fullfills loop protection and, given, every pidns has init task
which pins it even works reliably. :-)

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/kstate-image.h   |    9 ++
 include/linux/kstate.h         |    5 +
 kernel/kstate/cpt-sys.c        |    6 ++
 kernel/kstate/kstate-context.c |    6 ++
 kernel/kstate/kstate-object.c  |    4 +
 kernel/nsproxy.c               |   30 ++++++-
 kernel/pid_namespace.c         |  168 +++++++++++++++++++++++++++++++++++++++-
 7 files changed, 223 insertions(+), 5 deletions(-)

diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
index fa4921b..64328e1 100644
--- a/include/linux/kstate-image.h
+++ b/include/linux/kstate-image.h
@@ -47,6 +47,7 @@ struct kstate_image_header {
 #define KSTATE_OBJ_UTS_NS	7
 #define KSTATE_OBJ_IPC_NS	8
 #define KSTATE_OBJ_MNT_NS	9
+#define KSTATE_OBJ_PID_NS	10
 
 struct kstate_object_header {
 	__u32		obj_type;
@@ -215,6 +216,7 @@ struct kstate_image_nsproxy {
 	kstate_ref_t	ref_uts_ns;
 	kstate_ref_t	ref_ipc_ns;	/* KSTATE_REF_UNDEF if IPC_NS=n */
 	kstate_ref_t	ref_mnt_ns;
+	kstate_ref_t	ref_pid_ns;
 } __packed;
 
 struct kstate_image_uts_ns {
@@ -235,4 +237,11 @@ struct kstate_image_ipc_ns {
 struct kstate_image_mnt_ns {
 	struct kstate_object_header hdr;
 } __packed;
+
+struct kstate_image_pid_ns {
+	struct kstate_object_header hdr;
+
+	kstate_ref_t	ref_parent;	/* KSTATE_REF_UNDEF if root pid_ns */
+	__u32		last_pid;
+} __packed;
 #endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
index 43e2556..c925cef 100644
--- a/include/linux/kstate.h
+++ b/include/linux/kstate.h
@@ -28,6 +28,7 @@ enum kstate_context_obj_type {
 	KSTATE_CTX_MM_STRUCT,
 	KSTATE_CTX_MNT_NS,
 	KSTATE_CTX_NSPROXY,
+	KSTATE_CTX_PID_NS,
 	KSTATE_CTX_TASK_STRUCT,
 	KSTATE_CTX_UTS_NS,
 	NR_KSTATE_CTX_TYPES
@@ -100,6 +101,10 @@ static inline int kstate_dump_all_ipc_ns(struct kstate_context *ctx)
 int kstate_collect_all_mnt_ns(struct kstate_context *ctx);
 int kstate_dump_all_mnt_ns(struct kstate_context *ctx);
 
+int kstate_collect_all_pid_ns(struct kstate_context *ctx);
+int kstate_dump_all_pid_ns(struct kstate_context *ctx);
+int kstate_restore_pid_ns(struct kstate_context *ctx, kstate_ref_t *ref);
+
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
 extern const __u32 kstate_kernel_arch;
 int kstate_arch_check_image_header(struct kstate_image_header *i);
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
index 0e3c74c..cbaf038 100644
--- a/kernel/kstate/cpt-sys.c
+++ b/kernel/kstate/cpt-sys.c
@@ -77,6 +77,9 @@ static int kstate_collect(struct kstate_context *ctx)
 	rv = kstate_collect_all_mnt_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_collect_all_pid_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -133,6 +136,9 @@ static int kstate_dump(struct kstate_context *ctx)
 	rv = kstate_dump_image_header(ctx);
 	if (rv < 0)
 		return rv;
+	rv = kstate_dump_all_pid_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = kstate_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
index 700c0f4..7cd1f45 100644
--- a/kernel/kstate/kstate-context.c
+++ b/kernel/kstate/kstate-context.c
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/mnt_namespace.h>
 #include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/utsname.h>
@@ -61,6 +62,11 @@ void kstate_context_destroy(struct kstate_context *ctx)
 		list_del(&obj->o_list);
 		kfree(obj);
 	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_PID_NS) {
+		put_pid_ns((struct pid_namespace *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
 	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_TASK_STRUCT) {
 		put_task_struct((struct task_struct *)obj->o_obj);
 		list_del(&obj->o_list);
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
index 6b1ab4a..13bb75c 100644
--- a/kernel/kstate/kstate-object.c
+++ b/kernel/kstate/kstate-object.c
@@ -4,6 +4,7 @@
 #include <linux/mm_types.h>
 #include <linux/mnt_namespace.h>
 #include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/utsname.h>
@@ -50,6 +51,9 @@ int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_conte
 	case KSTATE_CTX_NSPROXY:
 		get_nsproxy((struct nsproxy *)obj->o_obj);
 		break;
+	case KSTATE_CTX_PID_NS:
+		get_pid_ns((struct pid_namespace *)obj->o_obj);
+		break;
 	case KSTATE_CTX_TASK_STRUCT:
 		get_task_struct((struct task_struct *)obj->o_obj);
 		break;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 4e22ec4..0b1f66d 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -288,6 +288,8 @@ static int dump_nsproxy(struct kstate_context *ctx, struct kstate_object *obj)
 #endif
 	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->mnt_ns, KSTATE_CTX_MNT_NS);
 	i->ref_mnt_ns = tmp->o_ref;
+	tmp = find_kstate_obj_by_ptr(ctx, nsproxy->pid_ns, KSTATE_CTX_PID_NS);
+	i->ref_pid_ns = tmp->o_ref;
 
 	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
 	kfree(i);
@@ -387,11 +389,29 @@ static int restore_mnt_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct
 	return 0;
 }
 
+static int restore_pid_ns(struct kstate_context *ctx, kstate_ref_t *ref, struct nsproxy *nsproxy)
+{
+	struct pid_namespace *pid_ns;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID_NS);
+	if (!tmp) {
+		rv = kstate_restore_pid_ns(ctx, ref);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_PID_NS);
+	}
+	pid_ns = tmp->o_obj;
+
+	nsproxy->pid_ns = get_pid_ns(pid_ns);
+	return 0;
+}
+
 int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 {
 	struct kstate_image_nsproxy *i;
 	struct nsproxy *nsproxy;
-	struct pid_namespace *pid_ns;
 #ifdef CONFIG_NET_NS
 	struct net *net_ns;
 #endif
@@ -416,9 +436,9 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	rv = restore_mnt_ns(ctx, &i->ref_mnt_ns, nsproxy);
 	if (rv < 0)
 		goto out_mnt_ns;
-
-	pid_ns = ctx->init_tsk->nsproxy->pid_ns;
-	nsproxy->pid_ns = get_pid_ns(pid_ns);
+	rv = restore_pid_ns(ctx, &i->ref_pid_ns, nsproxy);
+	if (rv < 0)
+		goto out_pid_ns;
 
 #ifdef CONFIG_NET_NS
 	net_ns = ctx->init_tsk->nsproxy->net_ns;
@@ -432,6 +452,8 @@ int kstate_restore_nsproxy(struct kstate_context *ctx, kstate_ref_t *ref)
 	pr_debug("restore nsproxy %p, ref {%llu, %u}, rv %d\n", nsproxy, (unsigned long long)ref->pos, ref->id, rv);
 	return rv;
 
+out_pid_ns:
+	put_mnt_ns(nsproxy->mnt_ns);
 out_mnt_ns:
 	put_ipc_ns(nsproxy->ipc_ns);
 out_ipc_ns:
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 821722a..104bccb 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -5,11 +5,12 @@
  *    (C) 2007 Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, OpenVZ, SWsoft Inc.
  *    (C) 2007 Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, IBM
  *     Many thanks to Oleg Nesterov for comments and help
- *
+ * Copyright (C) 2000-2009 Parallels Holdings, Ltd.
  */
 
 #include <linux/pid.h>
 #include <linux/pid_namespace.h>
+#include <linux/proc_fs.h>
 #include <linux/syscalls.h>
 #include <linux/err.h>
 #include <linux/acct.h>
@@ -191,3 +192,168 @@ static __init int pid_namespaces_init(void)
 }
 
 __initcall(pid_namespaces_init);
+
+#ifdef CONFIG_CHECKPOINT
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_pid_ns(struct pid_namespace *pid_ns)
+{
+#ifdef CONFIG_BSD_PROCESS_ACCT
+	if (pid_ns->bacct) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	return 0;
+}
+
+static int collect_pid_ns(struct kstate_context *ctx, struct pid_namespace *pid_ns)
+{
+	int rv;
+
+	rv = check_pid_ns(pid_ns);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, pid_ns, KSTATE_CTX_PID_NS);
+	pr_debug("collect pid_ns %p: rv %d\n", pid_ns, rv);
+	return rv;
+}
+
+int kstate_collect_all_pid_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = collect_pid_ns(ctx, nsproxy->pid_ns);
+		if (rv < 0)
+			return rv;
+	}
+	/* FIXME check for external references */
+	return 0;
+}
+
+static int dump_pid_ns(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct pid_namespace *pid_ns = obj->o_obj;
+	struct kstate_image_pid_ns *i;
+	struct kstate_object *tmp;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_PID_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	if (pid_ns == ctx->init_tsk->nsproxy->pid_ns)
+		i->ref_parent = KSTATE_REF_UNDEF;
+	else {
+		tmp = find_kstate_obj_by_ptr(ctx, pid_ns->parent, KSTATE_CTX_PID_NS);
+		i->ref_parent = tmp->o_ref;
+	}
+	i->last_pid = pid_ns->last_pid;	/* see /proc/loadavg */
+
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	kfree(i);
+	pr_debug("dump pid_ns %p: ref {%llu, %u}, rv %d\n", pid_ns, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_pid_ns(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	unsigned int level, nr_dumped;
+	int rv;
+
+	/*
+	 * Unlike other namespaces, pid_ns are hierarchical via ->parent.
+	 *
+	 * Dump pid_ns in certain order to check for loops on restore cheaply:
+	 * lower ->level one goes first. For every pid_ns being restored
+	 * (except root one), it's parent pid_ns was restored already.
+	 * Unresolved ->ref_parent reference is treated like invalid image.
+	 *
+	 * pid_ns pins parent one, which means there are no holes in hierarchy
+	 * wrt ->level, which means loop is finite.
+	 */
+	level = ctx->init_tsk->nsproxy->pid_ns->level;
+	do {
+		nr_dumped = 0;
+		for_each_kstate_object(ctx, obj, KSTATE_CTX_PID_NS) {
+			struct pid_namespace *pid_ns = obj->o_obj;
+
+			if (pid_ns->level != level)
+				continue;
+			rv = dump_pid_ns(ctx, obj);
+			if (rv < 0)
+				return rv;
+			nr_dumped++;
+		}
+		level++;
+	} while (nr_dumped > 0);
+	return 0;
+}
+
+int kstate_restore_pid_ns(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_pid_ns *i;
+	struct pid_namespace *parent_pid_ns, *pid_ns;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_PID_NS, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	if (kstate_ref_undefined(&i->ref_parent))
+		parent_pid_ns = ctx->init_tsk->nsproxy->pid_ns;
+	else {
+		struct kstate_object *tmp;
+
+		/*
+		 * Every pid_ns had child reaper alive. Otherwise restore
+		 * includes restore of parent pid_ns, check for loops,
+		 * fighting recursion...
+		 */
+		tmp = find_kstate_obj_by_ref(ctx, &i->ref_parent, KSTATE_CTX_PID_NS);
+		if (!tmp) {
+			rv = -EINVAL;
+			goto out_free_image;
+		}
+		parent_pid_ns = tmp->o_obj;
+	}
+
+	pid_ns = create_pid_namespace(parent_pid_ns);
+	if (IS_ERR(pid_ns)) {
+		rv = PTR_ERR(pid_ns);
+		goto out_free_image;
+	}
+	rv = pid_ns_prepare_proc(pid_ns);
+	if (rv < 0)
+		goto out_put_pid_ns;
+
+	pid_ns->last_pid = i->last_pid;
+	/*
+	 * Depend on child reaper being the first task restoring pid_ns and
+	 * pid_ns restore being done in current context.
+	 */
+	pid_ns->child_reaper = current;
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, pid_ns, KSTATE_CTX_PID_NS, ref);
+	if (rv < 0)
+		goto out_release_proc;
+	pr_debug("restore pid_ns %p: ref {%llu, %u}, rv %d\n", pid_ns, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_release_proc:
+	pid_ns_release_proc(pid_ns);
+out_put_pid_ns:
+	put_pid_ns(pid_ns);
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
+#endif
-- 
1.5.6.5
