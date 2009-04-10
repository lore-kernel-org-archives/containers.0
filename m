From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 21/30] cr: deal with pid/pidns
Date: Fri, 10 Apr 2009 06:38:38 +0400
Message-ID: <20090410023838.GV27788__42438.7112529532$1239331986$gmane$org@x200.localdomain>
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

C/R struct pid and struct pid_namespace.

Userspace should see same pids as before.

->last_pid is visible though /proc/loadavg, so it needs to be dumped too, sigh.

FIXME: restoration of pidns is recursive.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/linux/cr.h            |   26 +++
 include/linux/pid.h           |    2 
 include/linux/pid_namespace.h |    2 
 kernel/cr/Kconfig             |    1 
 kernel/cr/Makefile            |    1 
 kernel/cr/cpt-sys.c           |   12 +
 kernel/cr/cr-file.c           |   10 +
 kernel/cr/cr-nsproxy.c        |   15 +
 kernel/cr/cr-pid.c            |  363 ++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-task.c           |   18 ++
 kernel/cr/cr.h                |    8 
 kernel/fork.c                 |    2 
 kernel/pid.c                  |   39 ++++
 kernel/pid_namespace.c        |    4 
 14 files changed, 496 insertions(+), 7 deletions(-)

--- a/include/linux/cr.h
+++ b/include/linux/cr.h
@@ -37,6 +37,8 @@ struct cr_object_header {
 #define CR_OBJ_VMA_VDSO		6
 #define CR_OBJ_NSPROXY		7
 #define CR_OBJ_UTS_NS		8
+#define CR_OBJ_PID_NS		9
+#define CR_OBJ_PID		10
 	__u32	cr_type;	/* object type */
 	__u32	cr_len;		/* object length in bytes including header */
 } __packed;
@@ -56,6 +58,7 @@ struct cr_image_task_struct {
 
 	cr_pos_t	cr_pos_real_parent;
 	cr_pos_t	cr_pos_mm;
+	cr_pos_t	cr_pos_pids[3];
 	cr_pos_t	cr_pos_nsproxy;
 
 	__u8		cr_comm[16];
@@ -153,6 +156,7 @@ struct cr_image_nsproxy {
 	struct cr_object_header cr_hdr;
 
 	cr_pos_t	cr_pos_uts_ns;
+	cr_pos_t	cr_pos_pid_ns;
 } __packed;
 
 struct cr_image_uts_ns {
@@ -166,6 +170,13 @@ struct cr_image_uts_ns {
 	__u8		cr_domainname[64];
 } __packed;
 
+struct cr_image_pid_ns {
+	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_parent;	/* CR_POS_UNDEF if root pid_ns */
+	__u32		cr_last_pid;
+} __packed;
+
 struct cr_image_mm_struct {
 	struct cr_object_header cr_hdr;
 
@@ -223,7 +234,22 @@ struct cr_image_file {
 	__u32		cr_i_mode;
 	__u32		cr_f_flags;
 	__u64		cr_f_pos;
+	struct {
+		cr_pos_t	cr_pos_pid;
+		__u32	cr_pid_type;
+		__u32	cr_uid;
+		__u32	cr_euid;
+		__u32	cr_signum;
+	} cr_f_owner;
 	__u32		cr_name_len;
 	/* __u8	cr_name[cr_name_len] */
 } __packed;
+
+struct cr_image_pid {
+	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_pid_ns;	/* position of last pid_ns */
+	__u32		cr_level;
+	__u32		cr_nr[1];	/* cr_nr[cr_level + 1] */
+} __packed;
 #endif
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -119,7 +119,7 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, int last);
 
-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns, int *cr_nr, unsigned int cr_level);
 extern void free_pid(struct pid *pid);
 
 /*
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -42,6 +42,8 @@ static inline struct pid_namespace *get_pid_ns(struct pid_namespace *ns)
 	return ns;
 }
 
+struct pid_namespace *create_pid_namespace(unsigned int level);
+void destroy_pid_namespace(struct pid_namespace *pid_ns);
 extern struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *ns);
 extern void free_pid_ns(struct kref *kref);
 extern void zap_pid_ns_processes(struct pid_namespace *pid_ns);
--- a/kernel/cr/Kconfig
+++ b/kernel/cr/Kconfig
@@ -1,5 +1,6 @@
 config CR
 	bool "Container checkpoint/restart"
+	depends on PID_NS
 	depends on UTS_NS
 	select FREEZER
 	help
--- a/kernel/cr/Makefile
+++ b/kernel/cr/Makefile
@@ -4,6 +4,7 @@ cr-y += cr-context.o
 cr-y += cr-file.o
 cr-y += cr-mm.o
 cr-y += cr-nsproxy.o
+cr-y += cr-pid.o
 cr-y += cr-task.o
 cr-y += cr-uts.o
 cr-$(CONFIG_X86_32) += cr-x86_32.o
--- a/kernel/cr/cpt-sys.c
+++ b/kernel/cr/cpt-sys.c
@@ -71,12 +71,18 @@ static int cr_collect(struct cr_context *ctx)
 	rv = cr_collect_all_uts_ns(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_pid_ns(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_collect_all_mm_struct(ctx);
 	if (rv < 0)
 		return rv;
 	rv = cr_collect_all_file(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_collect_all_pid(ctx);
+	if (rv < 0)
+		return rv;
 	return 0;
 }
 
@@ -110,6 +116,12 @@ static int cr_dump(struct cr_context *ctx)
 	rv = cr_dump_image_header(ctx);
 	if (rv < 0)
 		return rv;
+	rv = cr_dump_all_pid_ns(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_pid(ctx);
+	if (rv < 0)
+		return rv;
 	rv = cr_dump_all_file(ctx);
 	if (rv < 0)
 		return rv;
--- a/kernel/cr/cr-file.c
+++ b/kernel/cr/cr-file.c
@@ -92,6 +92,7 @@ int generic_file_checkpoint(struct file *file, struct cr_context *ctx)
 {
 	struct cr_object *obj;
 	struct cr_image_file *i;
+	struct cr_object *tmp;
 	struct kstat stat;
 	char *buf, *name;
 	int rv;
@@ -109,6 +110,15 @@ int generic_file_checkpoint(struct file *file, struct cr_context *ctx)
 	i->cr_i_mode = stat.mode;
 	i->cr_f_flags = file->f_flags;
 	i->cr_f_pos = file->f_pos;
+	if (file->f_owner.pid) {
+		tmp = cr_find_obj_by_ptr(ctx, file->f_owner.pid, CR_CTX_PID);
+		i->cr_f_owner.cr_pos_pid = tmp->o_pos;
+	} else
+		i->cr_f_owner.cr_pos_pid = CR_POS_UNDEF;
+	i->cr_f_owner.cr_pid_type = file->f_owner.pid_type;
+	i->cr_f_owner.cr_uid = file->f_owner.uid;
+	i->cr_f_owner.cr_euid = file->f_owner.euid;
+	i->cr_f_owner.cr_signum = file->f_owner.signum;
 
 	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf) {
--- a/kernel/cr/cr-nsproxy.c
+++ b/kernel/cr/cr-nsproxy.c
@@ -59,6 +59,8 @@ static int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
 
 	tmp = cr_find_obj_by_ptr(ctx, nsproxy->uts_ns, CR_CTX_UTS_NS);
 	i->cr_pos_uts_ns = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->pid_ns, CR_CTX_PID_NS);
+	i->cr_pos_pid_ns = tmp->o_pos;
 
 	obj->o_pos = ctx->cr_dump_file->f_pos;
 	rv = cr_write(ctx, i, sizeof(*i));
@@ -84,6 +86,7 @@ static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
 	struct cr_image_nsproxy *i;
 	struct nsproxy *nsproxy;
 	struct uts_namespace *uts_ns;
+	struct pid_namespace *pid_ns;
 	struct cr_object *obj, *tmp;
 	int rv;
 
@@ -127,7 +130,17 @@ static int __cr_restore_nsproxy(struct cr_context *ctx, loff_t pos)
 	get_mnt_ns(init_nsproxy.mnt_ns);
 	nsproxy->mnt_ns = init_nsproxy.mnt_ns;
 
-	nsproxy->pid_ns = get_pid_ns(&init_pid_ns);
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_pid_ns, CR_CTX_PID_NS);
+	if (!tmp) {
+		rv = cr_restore_pid_ns(ctx, i->cr_pos_pid_ns);
+		if (rv < 0) {
+			kfree(i);
+			return rv;
+		}
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_pid_ns, CR_CTX_PID_NS);
+	}
+	pid_ns = tmp->o_obj;
+	nsproxy->pid_ns = get_pid_ns(pid_ns);
 
 #ifdef CONFIG_NET
 	nsproxy->net_ns = get_net(&init_net);
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-pid.c
@@ -0,0 +1,363 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
+#include <linux/proc_fs.h>
+#include <linux/sched.h>
+#include <linux/tty.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_pid_ns(struct pid_namespace *pid_ns)
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
+static int cr_collect_pid_ns(struct cr_context *ctx, struct pid_namespace *pid_ns)
+{
+	int rv;
+
+	rv = cr_check_pid_ns(pid_ns);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, pid_ns, CR_CTX_PID_NS);
+	printk("collect pid_ns %p: rv %d\n", pid_ns, rv);
+	return rv;
+}
+
+int cr_collect_all_pid_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = cr_collect_pid_ns(ctx, nsproxy->pid_ns);
+		if (rv < 0)
+			return rv;
+	}
+	/*
+	 * FIXME: check for external pid_ns references
+	 * 1. struct pid pins pid_ns
+	 * 2. struct pid_namespace pins pid_ns, but only parent one
+	 */
+	return 0;
+}
+
+static int cr_dump_pid_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct pid_namespace *pid_ns = obj->o_obj;
+	struct cr_image_pid_ns *i;
+	struct cr_object *tmp;
+	int rv;
+
+	printk("dump pid_ns %p\n", pid_ns);
+
+	i = cr_prepare_image(CR_OBJ_PID_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_last_pid = pid_ns->last_pid;
+	if (pid_ns == ctx->cr_init_tsk->nsproxy->pid_ns)
+		i->cr_pos_parent = CR_POS_UNDEF;
+	else {
+		tmp = cr_find_obj_by_ptr(ctx, pid_ns->parent, CR_CTX_PID_NS);
+		i->cr_pos_parent = tmp->o_pos;
+	}
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_pid_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	unsigned int level, nr_found;
+	int rv;
+
+	/*
+	 * Unlike other namespaces, pid_ns have direct hierarchy via ->parent.
+	 * To not create problems on dump with missing references and seeking
+	 * through dumpfile, dump pid_ns in certain order: lower ->level one
+	 * goes first.
+	 *
+	 * On restart, for every pid_ns being restored (except root one),
+	 * it's parent pid_ns will be already restored and reachable
+	 * via lookup by file position.
+	 *
+	 * pid_ns pins parent one, so there are no holes in hierarchy
+	 * wrt ->level which means loop is finite.
+	 */
+	level = ctx->cr_init_tsk->nsproxy->pid_ns->level;
+	do {
+		nr_found = 0;
+		for_each_cr_object(ctx, obj, CR_CTX_PID_NS) {
+			struct pid_namespace *pid_ns = obj->o_obj;
+
+			if (pid_ns->level != level)
+				continue;
+			rv = cr_dump_pid_ns(ctx, obj);
+			if (rv < 0)
+				return rv;
+			nr_found++;
+		}
+		level++;
+	} while (nr_found != 0);
+	return 0;
+}
+
+int cr_restore_pid_ns(struct cr_context *ctx, loff_t pos)
+{
+	struct pid_namespace *parent_pid_ns, *pid_ns;
+	struct cr_image_pid_ns *i;
+	struct cr_object *obj, *tmp;
+	int rv;
+
+	i = kzalloc(sizeof(struct cr_image_pid_ns), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	rv = cr_pread(ctx, i, sizeof(*i), pos);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	if (i->cr_hdr.cr_type != CR_OBJ_PID_NS) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	if (i->cr_pos_parent != CR_POS_UNDEF) {
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_parent, CR_CTX_PID_NS);
+		if (!tmp) {
+			/* FIXME recursion */
+			rv = cr_restore_pid_ns(ctx, i->cr_pos_parent);
+			if (rv < 0)
+				return rv;
+			tmp = cr_find_obj_by_pos(ctx, i->cr_pos_parent, CR_CTX_PID_NS);
+		}
+		parent_pid_ns = tmp->o_obj;
+	} else
+		parent_pid_ns = ctx->cr_init_tsk->nsproxy->pid_ns;
+	pid_ns = create_pid_namespace(parent_pid_ns->level + 1);
+	if (IS_ERR(pid_ns)) {
+		kfree(i);
+		return PTR_ERR(pid_ns);
+	}
+	rv = pid_ns_prepare_proc(pid_ns);
+	if (rv < 0) {
+		destroy_pid_namespace(pid_ns);
+		return rv;
+	}
+	pid_ns->parent = get_pid_ns(parent_pid_ns);
+
+	pid_ns->last_pid = i->cr_last_pid;
+	pid_ns->child_reaper = current;
+	kfree(i);
+
+	obj = cr_object_create(pid_ns);
+	if (!obj) {
+		put_pid_ns(pid_ns->parent);
+		pid_ns_release_proc(pid_ns);
+		destroy_pid_namespace(pid_ns);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_PID_NS]);
+	printk("restore pid_ns %p, pos %lld\n", pid_ns, (long long)pos);
+	return 0;
+}
+
+static int cr_collect_pid(struct cr_context *ctx, struct pid *pid)
+{
+	int rv;
+
+	rv = cr_collect_object(ctx, pid, CR_CTX_PID);
+	printk("collect pid %p: rv %d\n", pid, rv);
+	return rv;
+}
+
+int cr_collect_all_pid(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	unsigned int level0;
+	int rv;
+
+	level0 = ctx->cr_init_tsk->nsproxy->pid_ns->level;
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+		struct pid *pid;
+
+		BUILD_BUG_ON(PIDTYPE_MAX != 3);
+		pid = tsk->pids[PIDTYPE_PID].pid;
+		BUG_ON(pid->level < level0);
+		rv = cr_collect_pid(ctx, pid);
+		if (rv < 0)
+			return rv;
+		pid = tsk->pids[PIDTYPE_PGID].pid;
+		if (pid->level >= level0) {
+			rv = cr_collect_pid(ctx, pid);
+			if (rv < 0)
+				return rv;
+		}
+		pid = tsk->pids[PIDTYPE_SID].pid;
+		if (pid->level >= level0) {
+			rv = cr_collect_pid(ctx, pid);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		struct pid *pid = file->f_owner.pid;
+
+		if (pid) {
+			rv = cr_collect_pid(ctx, pid);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	/* FIXME pid refcount check should account references from proc inodes */
+	return 0;
+}
+
+static int cr_dump_pid(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct pid *pid = obj->o_obj;
+	struct cr_image_pid *i;
+	struct cr_object *tmp;
+	size_t image_len;
+	unsigned int level0, level;
+	int rv;
+
+	printk("dump pid %p\n", pid);
+
+	level0 = ctx->cr_init_tsk->nsproxy->pid_ns->level;
+	BUG_ON(pid->level < level0);
+	image_len = sizeof(*i) + (pid->level - level0) * sizeof(__u32);
+
+	i = cr_prepare_image(CR_OBJ_PID, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, pid->numbers[pid->level].ns, CR_CTX_PID_NS);
+	i->cr_pos_pid_ns = tmp->o_pos;
+	i->cr_level = pid->level - level0;
+	for (level = level0; level <= pid->level; level++)
+		i->cr_nr[level - level0] = pid->numbers[level].nr;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, image_len);
+	kfree(i);
+	return rv;
+}
+
+int cr_dump_all_pid(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_PID) {
+		rv = cr_dump_pid(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int __cr_restore_pid(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_pid *i, *tmpi;
+	struct pid_namespace *pid_ns;
+	struct pid *pid;
+	struct cr_object *obj, *tmp;
+	size_t image_len;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_PID) {
+		kfree(i);
+		return -EINVAL;
+	}
+	/* Image of struct pid is variable-sized. */
+	image_len = sizeof(*i) + i->cr_level * sizeof(__u32);
+	tmpi = i;
+	i = krealloc(i, image_len, GFP_KERNEL);
+	if (!i) {
+		kfree(tmpi);
+		return -ENOMEM;
+	}
+	rv = cr_pread(ctx, &i->cr_nr[1], image_len - sizeof(*i), pos + sizeof(*i));
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+
+	tmp = cr_find_obj_by_pos(ctx, i->cr_pos_pid_ns, CR_CTX_PID_NS);
+	if (!tmp) {
+		rv = cr_restore_pid_ns(ctx, i->cr_pos_pid_ns);
+		if (rv < 0) {
+			kfree(i);
+			return rv;
+		}
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_pid_ns, CR_CTX_PID_NS);
+	}
+	pid_ns = tmp->o_obj;
+
+	pid = alloc_pid(pid_ns, i->cr_nr, i->cr_level);
+	kfree(i);
+	if (!pid)
+		return -ENOMEM;
+
+	obj = cr_object_create(pid);
+	if (!obj) {
+		put_pid(pid);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_PID]);
+	printk("restore pid %p, pos %lld\n", pid, (long long)pos);
+	return 0;
+}
+
+int cr_restore_pid(struct cr_context *ctx, struct cr_image_task_struct *i)
+{
+	struct task_struct *tsk = current;
+	struct pid *pid;
+	struct cr_object *tmp;
+	int rv;
+
+	if (i->cr_pos_pids[0] != CR_POS_UNDEF) {
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_pids[0], CR_CTX_PID);
+		if (!tmp) {
+			rv = __cr_restore_pid(ctx, i->cr_pos_pids[0]);
+			if (rv < 0)
+				return rv;
+			tmp = cr_find_obj_by_pos(ctx, i->cr_pos_pids[0], CR_CTX_PID);
+		}
+		pid = tmp->o_obj;
+		write_lock(&tasklist_lock);
+		change_pid(tsk, PIDTYPE_PID, get_pid(pid));
+		tsk->pid = tsk->tgid = pid_nr(pid);
+		write_unlock(&tasklist_lock);
+	}
+	/* FIXME PIDTYPE_PGID */
+	/* FIXME PIDTYPE_SID */
+	return 0;
+}
--- a/kernel/cr/cr-task.c
+++ b/kernel/cr/cr-task.c
@@ -2,6 +2,7 @@
 #include <linux/fs.h>
 #include <linux/kthread.h>
 #include <linux/nsproxy.h>
+#include <linux/pid.h>
 #include <linux/pid_namespace.h>
 #include <linux/sched.h>
 #include <linux/tty.h>
@@ -113,6 +114,20 @@ static int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
 	tmp = cr_find_obj_by_ptr(ctx, tsk->nsproxy, CR_CTX_NSPROXY);
 	i->cr_pos_nsproxy = tmp->o_pos;
 
+	BUILD_BUG_ON(PIDTYPE_MAX != 3);
+	tmp = cr_find_obj_by_ptr(ctx, tsk->pids[PIDTYPE_PID].pid, CR_CTX_PID);
+	i->cr_pos_pids[0] = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->pids[PIDTYPE_PGID].pid, CR_CTX_PID);
+	if (tmp)
+		i->cr_pos_pids[1] = tmp->o_pos;
+	else
+		i->cr_pos_pids[1] = CR_POS_UNDEF;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->pids[PIDTYPE_SID].pid, CR_CTX_PID);
+	if (tmp)
+		i->cr_pos_pids[2] = tmp->o_pos;
+	else
+		i->cr_pos_pids[2] = CR_POS_UNDEF;
+
 	BUILD_BUG_ON(TASK_COMM_LEN != 16);
 	strlcpy((char *)i->cr_comm, (const char *)tsk->comm, sizeof(i->cr_comm));
 
@@ -171,6 +186,9 @@ static int task_struct_restorer(void *_tsk_ctx)
 	rv = cr_restore_nsproxy(ctx, i->cr_pos_nsproxy);
 	if (rv < 0)
 		goto out;
+	rv = cr_restore_pid(ctx, i);
+	if (rv < 0)
+		goto out;
 
 	rv = 0;
 out:
--- a/kernel/cr/cr.h
+++ b/kernel/cr/cr.h
@@ -25,6 +25,8 @@ enum cr_context_obj_type {
 	CR_CTX_FILE,
 	CR_CTX_MM_STRUCT,
 	CR_CTX_NSPROXY,
+	CR_CTX_PID,
+	CR_CTX_PID_NS,
 	CR_CTX_TASK_STRUCT,
 	CR_CTX_UTS_NS,
 	NR_CR_CTX_TYPES
@@ -71,18 +73,24 @@ static inline void __user *cr_restore_ptr(__u64 ptr)
 int cr_collect_all_file(struct cr_context *ctx);
 int cr_collect_all_mm_struct(struct cr_context *ctx);
 int cr_collect_all_nsproxy(struct cr_context *ctx);
+int cr_collect_all_pid_ns(struct cr_context *ctx);
+int cr_collect_all_pid(struct cr_context *ctx);
 int cr_collect_all_task_struct(struct cr_context *ctx);
 int cr_collect_all_uts_ns(struct cr_context *ctx);
 
 int cr_dump_all_file(struct cr_context *ctx);
 int cr_dump_all_mm_struct(struct cr_context *ctx);
 int cr_dump_all_nsproxy(struct cr_context *ctx);
+int cr_dump_all_pid_ns(struct cr_context *ctx);
+int cr_dump_all_pid(struct cr_context *ctx);
 int cr_dump_all_task_struct(struct cr_context *ctx);
 int cr_dump_all_uts_ns(struct cr_context *ctx);
 
 int cr_restore_file(struct cr_context *ctx, loff_t pos);
 int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_nsproxy(struct cr_context *ctx, loff_t pos);
+int cr_restore_pid_ns(struct cr_context *ctx, loff_t pos);
+int cr_restore_pid(struct cr_context *ctx, struct cr_image_task_struct *i);
 int cr_restore_task_struct(struct cr_context *ctx, loff_t pos);
 int cr_restore_uts_ns(struct cr_context *ctx, loff_t pos);
 
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1112,7 +1112,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	if (pid != &init_struct_pid) {
 		retval = -ENOMEM;
-		pid = alloc_pid(p->nsproxy->pid_ns);
+		pid = alloc_pid(p->nsproxy->pid_ns, NULL, 0);
 		if (!pid)
 			goto bad_fork_cleanup_io;
 
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -182,6 +182,36 @@ static int alloc_pidmap(struct pid_namespace *pid_ns)
 	return -1;
 }
 
+#ifdef CONFIG_CR
+static int set_pidmap(struct pid_namespace *pid_ns, pid_t pid)
+{
+	int offset;
+	struct pidmap *map;
+
+	offset = pid & BITS_PER_PAGE_MASK;
+	map = &pid_ns->pidmap[pid/BITS_PER_PAGE];
+	if (!map->page) {
+		void *page = kzalloc(PAGE_SIZE, GFP_KERNEL);
+		/*
+		 * Free the page if someone raced with us
+		 * installing it:
+		 */
+		spin_lock_irq(&pidmap_lock);
+		if (map->page)
+			kfree(page);
+		else
+			map->page = page;
+		spin_unlock_irq(&pidmap_lock);
+		if (unlikely(!map->page))
+			return -ENOMEM;
+	}
+	if (test_and_set_bit(offset, map->page))
+		return -EBUSY;
+	atomic_dec(&map->nr_free);
+	return pid;
+}
+#endif
+
 int next_pidmap(struct pid_namespace *pid_ns, int last)
 {
 	int offset;
@@ -239,7 +269,7 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
-struct pid *alloc_pid(struct pid_namespace *ns)
+struct pid *alloc_pid(struct pid_namespace *ns, int *cr_nr, unsigned int cr_level)
 {
 	struct pid *pid;
 	enum pid_type type;
@@ -253,7 +283,12 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 
 	tmp = ns;
 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp);
+#ifdef CONFIG_CR
+		if (cr_nr && ns->level - i <= cr_level)
+			nr = set_pidmap(tmp, cr_nr[ns->level - i]);
+		else
+#endif
+			nr = alloc_pidmap(tmp);
 		if (nr < 0)
 			goto out_free;
 
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -67,7 +67,7 @@ err_alloc:
 	return NULL;
 }
 
-static struct pid_namespace *create_pid_namespace(unsigned int level)
+struct pid_namespace *create_pid_namespace(unsigned int level)
 {
 	struct pid_namespace *ns;
 	int i;
@@ -103,7 +103,7 @@ out:
 	return ERR_PTR(-ENOMEM);
 }
 
-static void destroy_pid_namespace(struct pid_namespace *ns)
+void destroy_pid_namespace(struct pid_namespace *ns)
 {
 	int i;
