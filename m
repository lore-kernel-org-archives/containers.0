From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 19/30] cr: deal with nsproxy
Date: Fri, 10 Apr 2009 06:38:09 +0400
Message-ID: <20090410023809.GT27788__39277.3325126202$1239331977$gmane$org@x200.localdomain>
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

To save nsproxy, or to not save nsproxy?

Don't think much, save it.

I argue that nsproxy should be removed totally, if someone thinks otherwise. ;-)

The idea is that relations between in-kernel data structures close map
relations in dumpfile.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h      |    6 +
 include/linux/nsproxy.h |    1 
 kernel/cr/Makefile      |    1 
 kernel/cr/cpt-sys.c     |    6 +
 kernel/cr/cr-nsproxy.c  |  152 ++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-task.c     |    6 +
 kernel/cr/cr.h          |    4 +
 kernel/nsproxy.c        |    2 
 8 files changed, 177 insertions(+), 1 deletion(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -35,6 +35,7 @@ struct cr_object_header {
 #define CR_OBJ_VMA		4
 #define CR_OBJ_VMA_CONTENT	5
 #define CR_OBJ_VMA_VDSO		6
+#define CR_OBJ_NSPROXY		7
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -54,6 +55,7 @@ struct cr_image_task_struct {
 
 	cr_pos_t	cr_pos_real_parent;
 	cr_pos_t	cr_pos_mm;
+	cr_pos_t	cr_pos_nsproxy;
 
 	__u8		cr_comm[16];
 
@@ -146,6 +148,10 @@ struct cr_image_arch_x86_64 {
 	/* __u8	cr_xstate[cr_len_xstate]; */
 } __packed;
 
+struct cr_image_nsproxy {
+	struct cr_object_header cr_hdr;
+} __packed;
+
 struct cr_image_mm_struct {
 	struct cr_object_header cr_hdr;
 
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -62,6 +62,7 @@ static inline struct nsproxy *task_nsproxy(struct task_struct *tsk)
 	return rcu_dereference(tsk->nsproxy);
 }
 
+struct nsproxy *create_nsproxy(void);
 int copy_namespaces(unsigned long flags, struct task_struct *tsk);
 void exit_task_namespaces(struct task_struct *tsk);
 void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -3,6 +3,7 @@ cr-y := cpt-sys.o rst-sys.o
 cr-y += cr-context.o
 cr-y += cr-file.o
 cr-y += cr-mm.o
+cr-y += cr-nsproxy.o
 cr-y += cr-task.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
 cr-$(CONFIG_X86_64) += cr-x86_64.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -65,6 +65,9 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_task_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_nsproxy(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
@@ -110,6 +113,9 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_nsproxy(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_task_struct(ctx);
 	if (rv < 0)
 		return rv;
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-nsproxy.c
@@ -0,0 +1,152 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/ipc_namespace.h>
+#include <linux/kref.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include <linux/pid_namespace.h>
+#include <linux/utsname.h>
+#include <net/net_namespace.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_collect_nsproxy(struct cr_context *ctx, struct nsproxy *nsproxy)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, nsproxy, CR_CTX_NSPROXY);
+	printk("collect nsproxy %p: rv %d\n", nsproxy, rv);
+	return rv;
+}
+
+int cr_collect_all_nsproxy(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_collect_nsproxy(ctx, tsk->nsproxy);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+		unsigned int cnt = atomic_read(&nsproxy->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: nsproxy %p has external references %lu:%u\n", __func__, nsproxy, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct nsproxy *nsproxy = obj->o_obj;
+	struct cr_image_nsproxy	*i;
+	int rv;
+
+	printk("dump nsproxy %p\n", nsproxy);
+
+	i = cr_prepare_image(CR_OBJ_NSPROXY, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_nsproxy(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		rv = cr_dump_nsproxy(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_nsproxy *i;
+	struct nsproxy *nsproxy;
+	struct cr_object *obj;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_NSPROXY) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	nsproxy = create_nsproxy();
+	if (!nsproxy) {
+		kfree(i);
+		return -ENOMEM;
+	}
+
+	get_uts_ns(&init_uts_ns);
+	nsproxy->uts_ns = &init_uts_ns;
+
+#ifdef CONFIG_SYSVIPC
+	get_ipc_ns(&init_ipc_ns);
+	nsproxy->ipc_ns = &init_ipc_ns;
+#endif
+
+	get_mnt_ns(init_nsproxy.mnt_ns);
+	nsproxy->mnt_ns = init_nsproxy.mnt_ns;
+
+	nsproxy->pid_ns = get_pid_ns(&init_pid_ns);
+
+#ifdef CONFIG_NET
+	nsproxy->net_ns = get_net(&init_net);
+#endif
+	kfree(i);
+
+	obj = cr_object_create(nsproxy);
+	if (!obj) {
+		free_nsproxy(nsproxy);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_NSPROXY]);
+	printk("restore nsproxy %p, pos %lld\n", nsproxy, (long long)pos);
+	return 0;
+}
+
+int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
+{
+	struct task_struct *tsk = current;
+	struct nsproxy *nsproxy;
+	struct cr_object *tmp;
+	int rv;
+
+	tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_NSPROXY);
+	if (!tmp) {
+		rv = __cr_restore_nsproxy(ctx, pos);
+		if (rv < 0)
+			return rv;
+		tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_NSPROXY);
+	}
+	nsproxy = tmp->o_obj;
+	put_nsproxy(tsk->nsproxy);
+	get_nsproxy(nsproxy);
+	tsk->nsproxy = nsproxy;
+	return 0;
+}
--- a/kernel/cr/cr-task.c
+++ b/kernel/cr/cr-task.c
@@ -110,6 +110,8 @@ static int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
 
 	tmp = cr_find_obj_by_ptr(ctx, tsk->mm, CR_CTX_MM_STRUCT);
 	i->cr_pos_mm = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->nsproxy, CR_CTX_NSPROXY);
+	i->cr_pos_nsproxy = tmp->o_pos;
 
 	BUILD_BUG_ON(TASK_COMM_LEN != 16);
 	strlcpy((char *)i->cr_comm, (const char *)tsk->comm, sizeof(i->cr_comm));
@@ -166,7 +168,11 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = cr_restore_mm_struct(ctx, i->cr_pos_mm);
 	if (rv < 0)
 		goto out;
+	rv = cr_restore_nsproxy(ctx, i->cr_pos_nsproxy);
+	if (rv < 0)
+		goto out;
 
+	rv = 0;
 out:
 	printk("%s: schedule rv %d\n", __func__, rv);
 	complete(&tsk_ctx->c);
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -24,6 +24,7 @@ struct cr_object {
 enum cr_context_obj_type {
 	CR_CTX_FILE,
 	CR_CTX_MM_STRUCT,
+	CR_CTX_NSPROXY,
 	CR_CTX_TASK_STRUCT,
 	NR_CR_CTX_TYPES
 };
@@ -68,14 +69,17 @@ static inline void __user *cr_restore_ptr(__u64 ptr)
 
 int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_mm_struct(struct cr_context *ctx);
+int cr_collect_all_nsproxy(struct cr_context *ctx);
 int cr_collect_all_task_struct(struct cr_context *ctx);
 
 int cr_dump_all_file(struct cr_context *ctx);
 int cr_dump_all_mm_struct(struct cr_context *ctx);
+int cr_dump_all_nsproxy(struct cr_context *ctx);
 int cr_dump_all_task_struct(struct cr_context *ctx);
 
 int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
+int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
 int cr_restore_task_struct(struct cr_context *ctx, loff_t pos);
 
 #if defined(CONFIG_X86_32) || defined(CONFIG_X86_64)
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -26,7 +26,7 @@ static struct kmem_cache *nsproxy_cachep;
 
 struct nsproxy init_nsproxy = INIT_NSPROXY(init_nsproxy);
 
-static inline struct nsproxy *create_nsproxy(void)
+struct nsproxy *create_nsproxy(void)
 {
 	struct nsproxy *nsproxy;
