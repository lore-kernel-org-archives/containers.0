From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 28 Feb 2011 17:40:27 -0600
Message-ID: <1298936432-29607-6-git-send-email-ntl__26492.2804235995$1298937066$gmane$org@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Add a pair of system calls to save and restore the state of an
isolated (via clone/unshare) set of tasks and resources:

long checkpoint(int fd, unsigned int flags);
long restart(int fd, unsigned int flags);

Only a pid namespace init task - the child process produced by a call
to clone(2) with CLONE_NEWPID - is allowed to call these.  The state
of the calling task itself is not saved or altered by these system
calls.  Checkpoint dumps the state (CPU registers, open files, memory
map) of the tasks in the pid namespace to the supplied file
descriptor.  Restart is intended to be called by a pidns init in an
otherwise unpopulated pid namespace; it repopulates the caller's pidns
from the stream supplied by the file descriptor argument.

The flags argument to both syscalls must be zero at this time.  The
file descriptor argument may refer to a pipe or socket, i.e. it need
not be seekable.

On success both checkpoint and restart return 0.

Restart operations use the kthread API to restore tasks[1].  This
necessarily involves some ugly stuff like messing with task->parent,
real_parent, signal disposition etc. but provides a known consistent
state to start with.

This patch is based on original code written by Oren Laadan.

NOTE: This version of the code supports C/R of a single task only.
Pid 1 can call checkpoint while there is a single other task in its
pidns.  Restart can restore just one task into the caller's pidns.

[1] credit to A. Dobriyan for this technique; all bugs are ntl's

Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
[ntl: aggregated various C/R patches from Oren]
[ntl: removed deferqueue]
[ntl: clean up CKPT_VMA_NOT_SUPPORTED]
[ntl: remove logfd argument from syscalls]
[ntl: bugfix: correct locking when looking up task by pid]
[ntl: remove superfluous #define CKPT_FOO CKPT_FOO]
[ntl: decouple various objhash APIs from checkpoint context]
[ntl: s/ckpt_err/ckpt_debug/]
[ntl: remove ckpt_msg and associated APIs]
[ntl: remove pid argument from syscalls]
[ntl: make sys_restart freeze current's pidns]
[ntl: make C/R constrained to containers/pidns]
[ntl: implement task restore entirely in-kernel]
[ntl: remove CONFIG_CHECKPOINT_DEBUG; just use #define DEBUG]
[ntl: remove various non-essential APIs]
[ntl: consolidate related headers into checkpoint.h]
[ntl: remove various unneeded symbol exports]
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint.h     |  347 +++++++++++++++++++++
 include/linux/magic.h          |    3 +
 init/Kconfig                   |    2 +
 kernel/Makefile                |    1 +
 kernel/checkpoint/Kconfig      |   15 +
 kernel/checkpoint/Makefile     |    9 +
 kernel/checkpoint/checkpoint.c |  437 +++++++++++++++++++++++++++
 kernel/checkpoint/objhash.c    |  368 +++++++++++++++++++++++
 kernel/checkpoint/restart.c    |  651 ++++++++++++++++++++++++++++++++++++++++
 kernel/checkpoint/sys.c        |  208 +++++++++++++
 kernel/sys_ni.c                |    4 +
 11 files changed, 2045 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/checkpoint.h
 create mode 100644 kernel/checkpoint/Kconfig
 create mode 100644 kernel/checkpoint/Makefile
 create mode 100644 kernel/checkpoint/checkpoint.c
 create mode 100644 kernel/checkpoint/objhash.c
 create mode 100644 kernel/checkpoint/restart.c
 create mode 100644 kernel/checkpoint/sys.c

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
new file mode 100644
index 0000000..9129860
--- /dev/null
+++ b/include/linux/checkpoint.h
@@ -0,0 +1,347 @@
+#ifndef _LINUX_CHECKPOINT_H_
+#define _LINUX_CHECKPOINT_H_
+/*
+ *  Generic checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/list.h>
+#include <linux/path.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+
+/*
+ * header format: 'struct ckpt_hdr' must prefix all other
+ * headers. Therefore when a header is passed around, the information
+ * about it (type, size) is readily available. Structs that include a
+ * struct ckpt_hdr are named struct ckpt_hdr_* by convention (usually
+ * the struct ckpt_hdr is the first member).
+ */
+struct ckpt_hdr {
+	__u32 type;
+	__u32 len;
+};
+
+/* header types */
+enum {
+	CKPT_HDR_HEADER = 1,
+	CKPT_HDR_HEADER_ARCH,
+	CKPT_HDR_BUFFER,
+	CKPT_HDR_STRING,
+	CKPT_HDR_OBJREF,
+
+	CKPT_HDR_TASK = 101,
+	CKPT_HDR_TASK_OBJS,
+	CKPT_HDR_THREAD,
+	CKPT_HDR_CPU,
+
+	/* 201-299: reserved for arch-dependent */
+
+	CKPT_HDR_FILE_TABLE = 301,
+	CKPT_HDR_FILE_DESC,
+	CKPT_HDR_FILE_NAME,
+	CKPT_HDR_FILE,
+
+	CKPT_HDR_MM = 401,
+	CKPT_HDR_VMA,
+	CKPT_HDR_MM_CONTEXT,
+	CKPT_HDR_PAGE,
+
+	CKPT_HDR_TAIL = 9001,
+};
+
+/* architecture */
+enum {
+	CKPT_ARCH_X86_32 = 1,
+};
+
+/* shared objrects (objref) */
+struct ckpt_hdr_objref {
+	struct ckpt_hdr h;
+	__u32 objtype;
+	__s32 objref;
+};
+
+/* shared objects types */
+enum obj_type {
+	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_FILE_TABLE,
+	CKPT_OBJ_FILE,
+	CKPT_OBJ_MM,
+	CKPT_OBJ_MAX
+};
+
+/* kernel constants */
+struct ckpt_const {
+	/* task */
+	__u16 task_comm_len;
+	/* mm */
+	__u16 at_vector_size;
+	/* uts */
+	__u16 uts_release_len;
+	__u16 uts_version_len;
+	__u16 uts_machine_len;
+};
+
+/* checkpoint image header */
+struct ckpt_hdr_header {
+	struct ckpt_hdr h;
+	__u64 magic;
+
+	__u16 arch_id;
+
+	__u16 major;
+	__u16 minor;
+	__u16 patch;
+
+	struct ckpt_const constants;
+
+	__u64 time;	/* when checkpoint taken */
+	__u64 uflags;	/* uflags from checkpoint */
+
+	/*
+	 * the header is followed by three strings:
+	 *   char release[const.uts_release_len];
+	 *   char version[const.uts_version_len];
+	 *   char machine[const.uts_machine_len];
+	 */
+};
+
+/* checkpoint image trailer */
+struct ckpt_hdr_tail {
+	struct ckpt_hdr h;
+	__u64 magic;
+};
+
+/* task data */
+struct ckpt_hdr_task {
+	struct ckpt_hdr h;
+	__u32 state;
+	__u32 exit_state;
+	__u32 exit_code;
+	__u32 exit_signal;
+
+	__u64 set_child_tid;
+	__u64 clear_child_tid;
+};
+
+/* task's shared resources */
+struct ckpt_hdr_task_objs {
+	struct ckpt_hdr h;
+	__s32 files_objref;
+	__s32 mm_objref;
+};
+
+/* file system */
+struct ckpt_hdr_file_table {
+	struct ckpt_hdr h;
+	__s32 fdt_nfds;
+};
+
+/* file descriptors */
+struct ckpt_hdr_file_desc {
+	struct ckpt_hdr h;
+	__s32 fd_objref;
+	__s32 fd_descriptor;
+	__u32 fd_close_on_exec;
+};
+
+enum file_type {
+	CKPT_FILE_IGNORE = 0,
+	CKPT_FILE_GENERIC,
+	CKPT_FILE_MAX
+};
+
+/* file objects */
+struct ckpt_hdr_file {
+	struct ckpt_hdr h;
+	__u32 f_type;
+	__u32 f_mode;
+	__u32 f_flags;
+	__u32 _padding;
+	__u64 f_pos;
+	__u64 f_version;
+};
+
+struct ckpt_hdr_file_generic {
+	struct ckpt_hdr_file common;
+};
+
+/* memory layout */
+struct ckpt_hdr_mm {
+	struct ckpt_hdr h;
+	__u32 map_count;
+	__s32 exe_objref;
+
+	__u64 def_flags;
+	__u64 flags;
+
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+};
+
+/* vma subtypes - index into restore_vma_dispatch[] */
+enum vma_type {
+	CKPT_VMA_IGNORE = 0,
+	CKPT_VMA_VDSO,		/* special vdso vma */
+	CKPT_VMA_ANON,		/* private anonymous */
+	CKPT_VMA_FILE,		/* private mapped file */
+	CKPT_VMA_MAX
+};
+
+/* vma descriptor */
+struct ckpt_hdr_vma {
+	struct ckpt_hdr h;
+	__u32 vma_type;
+	__s32 vma_objref;	/* objref of backing file */
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+};
+
+/* page */
+struct ckpt_hdr_page {
+	struct ckpt_hdr hdr;
+#define CKPT_VMA_LAST_PAGE (~0UL)
+	__u64 vaddr;
+};
+
+struct ckpt_ctx {
+	struct ckpt_obj_hash *obj_hash; /* repository for shared objects */
+	struct task_struct *root_task;  /* pidns init and caller */
+	struct path root_fs_path;       /* container root */
+	struct task_struct *tsk;        /* checkpoint: current target task */
+	struct file *file;              /* input/output file */
+};
+
+extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, size_t count);
+extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, size_t count);
+
+extern void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int n, int type);
+
+extern int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h);
+extern int ckpt_write_obj_type(struct ckpt_ctx *ctx,
+			       void *ptr, size_t len, int type);
+extern int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, size_t len);
+extern int ckpt_write_string(struct ckpt_ctx *ctx, char *str, size_t len);
+
+extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
+			       void *ptr, size_t len, int type);
+extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, size_t len);
+extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, size_t len);
+extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, size_t len, int type);
+extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, size_t max, int type);
+extern int ckpt_read_payload(struct ckpt_ctx *ctx,
+			     void **ptr, size_t max, int type);
+extern char *ckpt_fill_fname(struct path *path, struct path *root,
+			     char *buf, int *len);
+
+/* obj_hash */
+extern void ckpt_obj_hash_free(struct ckpt_obj_hash *obj_hash);
+extern struct ckpt_obj_hash *ckpt_obj_hash_alloc(void);
+
+extern int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h);
+extern int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr,
+			  enum obj_type type);
+extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
+			       enum obj_type type, int *first);
+extern void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref,
+				enum obj_type type);
+extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
+			    enum obj_type type);
+
+extern int do_checkpoint(struct ckpt_ctx *ctx);
+extern int do_restart(struct ckpt_ctx *ctx);
+
+/* arch hooks */
+extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
+extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
+
+extern int restore_read_header_arch(struct ckpt_ctx *ctx);
+extern int restore_thread(struct ckpt_ctx *ctx);
+extern int restore_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
+
+/* file table */
+extern int checkpoint_obj_file_table(struct ckpt_ctx *ctx,
+				     struct task_struct *t);
+extern int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref);
+
+/* files */
+extern int checkpoint_fname(struct ckpt_ctx *ctx,
+			    struct path *path, struct path *root);
+extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags);
+
+extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+				  struct ckpt_hdr_file *h);
+extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			       struct ckpt_hdr_file *h);
+
+/* memory */
+struct vm_area_struct;
+extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type,
+				  int vma_objref);
+
+extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
+
+#define CKPT_VMA_NOT_SUPPORTED (		\
+		VM_HUGETLB |			\
+		VM_INSERTPAGE |			\
+		VM_IO |				\
+		VM_MAPPED_COPY |		\
+		VM_MAYSHARE |			\
+		VM_MIXEDMAP |			\
+		VM_NONLINEAR |			\
+		VM_NORESERVE |			\
+		VM_PFNMAP |			\
+		VM_RESERVED |			\
+		VM_SAO |			\
+		VM_SHARED |			\
+		0)
+
+#define __ckpt_debug(fmt, args...)					\
+	do {								\
+		pr_devel("[%d:%d:c/r:%s:%d] " fmt,			\
+			 current->pid,					\
+			 current->nsproxy ?				\
+			 task_pid_vnr(current) : -1,			\
+			 __func__, __LINE__, ## args);			\
+	} while (0)
+
+#define ckpt_debug(fmt, args...)  \
+	__ckpt_debug(fmt, ## args)
+
+/* object operations */
+struct ckpt_obj_ops {
+	char *obj_name;
+	int obj_type;
+	void (*ref_drop)(void *ptr, int lastref);
+	int (*ref_grab)(void *ptr);
+	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
+	void *(*restore)(struct ckpt_ctx *ctx);
+};
+
+#ifdef CONFIG_CHECKPOINT
+extern int register_checkpoint_obj(const struct ckpt_obj_ops *ops);
+#else /* CONFIG_CHECKPOINT */
+static inline int register_checkpoint_obj(const struct ckpt_obj_ops *ops)
+{
+	return 0;
+}
+#endif /* CONFIG_CHECKPOINT */
+
+#endif /* _LINUX_CHECKPOINT_H_ */
diff --git a/include/linux/magic.h b/include/linux/magic.h
index ff690d0..30cd986 100644
--- a/include/linux/magic.h
+++ b/include/linux/magic.h
@@ -59,4 +59,7 @@
 #define SOCKFS_MAGIC		0x534F434B
 #define V9FS_MAGIC		0x01021997
 
+#define CHECKPOINT_MAGIC_HEAD  0x00feed0cc0a2d200LL
+#define CHECKPOINT_MAGIC_TAIL  0x002d2a0cc0deef00LL
+
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/init/Kconfig b/init/Kconfig
index c972899..cf6ce1f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -793,6 +793,8 @@ config RELAY
 
 	  If unsure, say N.
 
+source "kernel/checkpoint/Kconfig"
+
 config BLK_DEV_INITRD
 	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
 	depends on BROKEN || !FRV
diff --git a/kernel/Makefile b/kernel/Makefile
index 0b5ff08..3f6238c 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -106,6 +106,7 @@ obj-$(CONFIG_PERF_EVENTS) += perf_event.o
 obj-$(CONFIG_HAVE_HW_BREAKPOINT) += hw_breakpoint.o
 obj-$(CONFIG_USER_RETURN_NOTIFIER) += user-return-notifier.o
 obj-$(CONFIG_PADATA) += padata.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint/
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan-HpYC8cTCicIJY7gZg3T8ig@public.gmane.org>, the -fno-omit-frame-pointer is
diff --git a/kernel/checkpoint/Kconfig b/kernel/checkpoint/Kconfig
new file mode 100644
index 0000000..21fc86b
--- /dev/null
+++ b/kernel/checkpoint/Kconfig
@@ -0,0 +1,15 @@
+# Architectures should define CHECKPOINT_SUPPORT when they have
+# implemented the hooks for processor state etc. needed by the
+# core checkpoint/restart code.
+
+config CHECKPOINT
+	bool "Checkpoint/restart (EXPERIMENTAL)"
+	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	depends on CGROUP_FREEZER
+	help
+	  Application checkpoint/restart is the ability to save the
+	  state of a running application so that it can later resume
+	  its execution from the time at which it was checkpointed.
+
+	  Turning this option on will enable checkpoint and restart
+	  functionality in the kernel.
diff --git a/kernel/checkpoint/Makefile b/kernel/checkpoint/Makefile
new file mode 100644
index 0000000..3431310
--- /dev/null
+++ b/kernel/checkpoint/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for linux checkpoint/restart.
+#
+
+obj-$(CONFIG_CHECKPOINT) += \
+	sys.o \
+	objhash.o \
+	checkpoint.o \
+	restart.o
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
new file mode 100644
index 0000000..bef1d30
--- /dev/null
+++ b/kernel/checkpoint/checkpoint.c
@@ -0,0 +1,437 @@
+/*
+ *  Checkpoint logic and helpers
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define DEBUG
+
+#include <linux/checkpoint.h>
+#include <linux/dcache.h>
+#include <linux/file.h>
+#include <linux/freezer.h>
+#include <linux/fs.h>
+#include <linux/fs_struct.h>
+#include <linux/magic.h>
+#include <linux/module.h>
+#include <linux/mount.h>
+#include <linux/pid_namespace.h>
+#include <linux/ptrace.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/time.h>
+#include <linux/version.h>
+#include <linux/utsname.h>
+
+#include <asm/checkpoint.h>
+
+/**
+ * ckpt_write_obj - write an object
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ */
+int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	ckpt_debug("type %d len %d\n", h->type, h->len);
+	return ckpt_kwrite(ctx, h, h->len);
+}
+
+/**
+ * ckpt_write_obj_type - write an object (from a pointer)
+ * @ctx: checkpoint context
+ * @ptr: buffer pointer
+ * @len: buffer size
+ * @type: desired type
+ *
+ * If @ptr is NULL, then write only the header (payload to follow)
+ */
+int ckpt_write_obj_type(struct ckpt_ctx *ctx, void *ptr, size_t len, int type)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = kzalloc(sizeof(*h), GFP_KERNEL);
+	if (!h)
+		return -ENOMEM;
+
+	h->type = type;
+	h->len = len + sizeof(*h);
+
+	ckpt_debug("type %d len %d\n", h->type, h->len);
+	ret = ckpt_kwrite(ctx, h, sizeof(*h));
+	if (ret < 0)
+		goto out;
+	if (ptr)
+		ret = ckpt_kwrite(ctx, ptr, len);
+ out:
+	kfree(h);
+	return ret;
+}
+
+/**
+ * ckpt_write_buffer - write an object of type buffer
+ * @ctx: checkpoint context
+ * @ptr: buffer pointer
+ * @len: buffer size
+ */
+int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, size_t len)
+{
+	return ckpt_write_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
+}
+
+/**
+ * ckpt_write_string - write an object of type string
+ * @ctx: checkpoint context
+ * @str: string pointer
+ * @len: string length
+ */
+int ckpt_write_string(struct ckpt_ctx *ctx, char *str, size_t len)
+{
+	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
+}
+
+/***********************************************************************
+ * Checkpoint
+ */
+
+static void fill_kernel_const(struct ckpt_const *h)
+{
+	struct task_struct *tsk;
+	struct new_utsname *uts;
+
+	/* task */
+	h->task_comm_len = sizeof(tsk->comm);
+	/* mm->saved_auxv size */
+	h->at_vector_size = AT_VECTOR_SIZE;
+	/* uts */
+	h->uts_release_len = sizeof(uts->release);
+	h->uts_version_len = sizeof(uts->version);
+	h->uts_machine_len = sizeof(uts->machine);
+}
+
+/* write the checkpoint header */
+static int checkpoint_write_header(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header *h;
+	struct new_utsname *uts;
+	struct timeval ktv;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
+	if (!h)
+		return -ENOMEM;
+
+	do_gettimeofday(&ktv);
+	uts = utsname();
+
+	h->arch_id = cpu_to_le16(CKPT_ARCH_ID);
+
+	h->magic = CHECKPOINT_MAGIC_HEAD;
+	h->major = (LINUX_VERSION_CODE >> 16) & 0xff;
+	h->minor = (LINUX_VERSION_CODE >> 8) & 0xff;
+	h->patch = (LINUX_VERSION_CODE) & 0xff;
+
+	h->time = ktv.tv_sec;
+
+	fill_kernel_const(&h->constants);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+	if (ret < 0)
+		return ret;
+
+	down_read(&uts_sem);
+	ret = ckpt_write_buffer(ctx, uts->release, sizeof(uts->release));
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_buffer(ctx, uts->version, sizeof(uts->version));
+	if (ret < 0)
+		goto up;
+	ret = ckpt_write_buffer(ctx, uts->machine, sizeof(uts->machine));
+ up:
+	up_read(&uts_sem);
+	if (ret < 0)
+		return ret;
+
+	return checkpoint_write_header_arch(ctx);
+}
+
+/* write the checkpoint trailer */
+static int checkpoint_write_tail(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tail *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
+	if (!h)
+		return -ENOMEM;
+
+	h->magic = CHECKPOINT_MAGIC_TAIL;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+	return ret;
+}
+
+/* dump the task_struct of a given task */
+static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	h->state = t->state;
+	h->exit_state = t->exit_state;
+	h->exit_code = t->exit_code;
+	h->exit_signal = t->exit_signal;
+
+	h->set_child_tid = (unsigned long) t->set_child_tid;
+	h->clear_child_tid = (unsigned long) t->clear_child_tid;
+
+	/* FIXME: save remaining relevant task_struct fields */
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+	if (ret < 0)
+		return ret;
+
+	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
+}
+
+/* dump the task_struct of a given task */
+static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_task_objs *h;
+	int files_objref;
+	int mm_objref;
+	int ret;
+
+	files_objref = checkpoint_obj_file_table(ctx, t);
+	ckpt_debug("files: objref %d\n", files_objref);
+	if (files_objref < 0)
+		return files_objref;
+
+	mm_objref = checkpoint_obj_mm(ctx, t);
+	ckpt_debug("mm: objref %d\n", mm_objref);
+	if (mm_objref < 0)
+		return mm_objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (!h)
+		return -ENOMEM;
+	h->files_objref = files_objref;
+	h->mm_objref = mm_objref;
+	ret = ckpt_write_obj(ctx, &h->h);
+	kfree(h);
+
+	return ret;
+}
+
+static bool task_is_descendant(struct task_struct *tsk)
+{
+	while (tsk != &init_task) {
+		if (tsk == current)
+			return true;
+		tsk = tsk->real_parent;
+	}
+	return false;
+}
+
+static bool task_checkpointable(struct task_struct *tsk)
+{
+	if (is_container_init(tsk)) {
+		pr_err("checkpoint of nested namespaces not supported\n");
+		return false;
+	}
+
+	if (!task_is_descendant(tsk)) {
+		pr_err("checkpoint of unrelated tasks not supported\n");
+		return false;
+	}
+
+	if (get_nr_threads(tsk) > 1) {
+		pr_err("checkpoint of multithreaded tasks not yet supported\n");
+		return false;
+	}
+
+	return true;
+}
+
+/* dump the entire state of a given task */
+static int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	int ret;
+
+	if (!task_checkpointable(t))
+		return -ENOSYS;
+
+	ctx->tsk = t;
+
+	ret = checkpoint_task_struct(ctx, t);
+	ckpt_debug("task %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_thread(ctx, t);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_task_objs(ctx, t);
+	ckpt_debug("objs %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_cpu(ctx, t);
+	ckpt_debug("cpu %d\n", ret);
+ out:
+	ctx->tsk = NULL;
+	return ret;
+}
+
+/**
+ * freeze_pidns() - freeze all other tasks in current pid namespace
+ *
+ * Attempts to freeze all other tasks in the caller's pid namespace.
+ * Only the init process of the pid namespace is allowed to call this.
+ * Will busy-loop trying to freeze tasks unless interrupted by a
+ * signal.
+ *
+ * Returns 0 on success, -EINTR if interrupted.  In all cases, the
+ * caller must call thaw_pidns() to ensure that the current pid
+ * namespace is completely unfrozen.
+ */
+static int freeze_pidns(void)
+{
+	struct task_struct *t, *p;
+	bool try_again;
+	int rc = 0;
+
+	BUG_ON(!is_container_init(current));
+	ckpt_debug("\n");
+again:
+	cond_resched();
+	if (signal_pending(current))
+		return -EINTR;
+	try_again = false;
+
+	read_lock(&tasklist_lock);
+
+	do_each_thread(t, p) {
+		if (p == current)
+			continue;
+
+		if (!task_is_descendant(p))
+			continue;
+
+		freeze_task(p, true);
+		try_again |= !frozen(p);
+	} while_each_thread(t, p);
+
+	read_unlock(&tasklist_lock);
+
+	if (try_again)
+		goto again;
+
+	return rc;
+}
+
+/**
+ * thaw_pidns() - unfreeze all other tasks in the current pid namespace
+ *
+ * Unfreeze all other processes in caller's pid namespace.  Only the
+ * init process of the pid namespace is allowed to call this.
+ */
+static void thaw_pidns(void)
+{
+	struct task_struct *t, *p;
+
+	BUG_ON(!is_container_init(current));
+
+	read_lock(&tasklist_lock);
+
+	do_each_thread(t, p) {
+		if (p == current)
+			continue;
+
+		if (!task_is_descendant(p))
+			continue;
+
+		if (!frozen(p))
+			continue;
+
+		thaw_process(p);
+
+	} while_each_thread(t, p);
+
+	read_unlock(&tasklist_lock);
+}
+
+/**
+ * do_checkpoint() - checkpoint the caller's pid namespace
+ * @ctx: checkpoint context
+ *
+ * Freeze, checkpoint, and thaw the current pid namespace.  The
+ * checkpoint image is written to @ctx->file.  Only the init process
+ * of the pid namespace is allowed to call this.
+ */
+int do_checkpoint(struct ckpt_ctx *ctx)
+{
+	struct task_struct *target = NULL;
+	struct task_struct *child;
+	unsigned int nr;
+	int err;
+
+	if (!is_container_init(current))
+		return -EPERM;
+
+	err = freeze_pidns();
+	if (err)
+		goto thaw;
+
+	err = checkpoint_write_header(ctx);
+	if (err)
+		goto thaw;
+
+	nr = 0;
+	read_lock(&tasklist_lock);
+	list_for_each_entry(child, &current->children, sibling) {
+		nr++;
+		if (target) /* more than one process; abort */
+			break;
+		target = child;
+		get_task_struct(target);
+	}
+	read_unlock(&tasklist_lock);
+
+	if (nr == 0) {
+		err = -ESRCH;
+		goto thaw;
+	}
+
+	if (nr > 1) {
+		pr_err("checkpoint of >1 process not yet implemented\n");
+		err = -EBUSY;
+		goto thaw;
+	}
+
+	err = checkpoint_task(ctx, target);
+	if (err)
+		goto thaw;
+
+	err = checkpoint_write_tail(ctx);
+thaw:
+	/* Thaw regardless of status; some tasks could be frozen even
+	 * if freeze_pidns return error.
+	 */
+	thaw_pidns();
+
+	if (target)
+		put_task_struct(target);
+
+	return err;
+}
diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
new file mode 100644
index 0000000..45d4e67
--- /dev/null
+++ b/kernel/checkpoint/objhash.c
@@ -0,0 +1,368 @@
+/*
+ *  Checkpoint-restart - object hash infrastructure to manage shared objects
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define DEBUG
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/hash.h>
+#include <linux/checkpoint.h>
+
+struct ckpt_obj {
+	int objref;
+	int flags;
+	void *ptr;
+	const struct ckpt_obj_ops *ops;
+	struct hlist_node hash;
+};
+
+/* object internal flags */
+#define CKPT_OBJ_CHECKPOINTED		0x1   /* object already checkpointed */
+
+struct ckpt_obj_hash {
+	struct hlist_head *head;
+	int next_free_objref;
+};
+
+/* ignored object */
+static const struct ckpt_obj_ops ckpt_obj_ignored_ops = {
+	.obj_name = "IGNORED",
+	.obj_type = CKPT_OBJ_IGNORE,
+	.ref_drop = NULL,
+	.ref_grab = NULL,
+};
+
+static const struct ckpt_obj_ops *ckpt_obj_ops[CKPT_OBJ_MAX] = {
+	[CKPT_OBJ_IGNORE] = &ckpt_obj_ignored_ops,
+};
+
+int register_checkpoint_obj(const struct ckpt_obj_ops *ops)
+{
+	if (ops->obj_type < 0 || ops->obj_type >= CKPT_OBJ_MAX)
+		return -EINVAL;
+	if (ckpt_obj_ops[ops->obj_type] != NULL)
+		return -EINVAL;
+	ckpt_obj_ops[ops->obj_type] = ops;
+	return 0;
+}
+
+#define CKPT_OBJ_HASH_NBITS  10
+#define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
+
+static void obj_hash_clear(struct ckpt_obj_hash *obj_hash)
+{
+	struct hlist_head *h = obj_hash->head;
+	struct hlist_node *n, *t;
+	struct ckpt_obj *obj;
+	int i;
+
+	for (i = 0; i < CKPT_OBJ_HASH_TOTAL; i++) {
+		hlist_for_each_entry_safe(obj, n, t, &h[i], hash) {
+			if (obj->ops->ref_drop)
+				obj->ops->ref_drop(obj->ptr, 1);
+			kfree(obj);
+		}
+	}
+}
+
+void ckpt_obj_hash_free(struct ckpt_obj_hash *obj_hash)
+{
+	obj_hash_clear(obj_hash);
+	kfree(obj_hash->head);
+	kfree(obj_hash);
+}
+
+struct ckpt_obj_hash *ckpt_obj_hash_alloc(void)
+{
+	size_t size = CKPT_OBJ_HASH_TOTAL * sizeof(struct hlist_head);
+	struct ckpt_obj_hash *obj_hash;
+
+	obj_hash = kzalloc(sizeof(*obj_hash), GFP_KERNEL);
+	if (!obj_hash)
+		return NULL;
+
+	obj_hash->head = kzalloc(size, GFP_KERNEL);
+	if (!obj_hash->head) {
+		kfree(obj_hash);
+		obj_hash = NULL;
+	} else {
+		obj_hash->next_free_objref = 1;
+	}
+
+	return obj_hash;
+}
+
+static struct ckpt_obj *obj_find_by_ptr(const struct ckpt_obj_hash *obj_hash, void *ptr)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct ckpt_obj *obj;
+
+	h = &obj_hash->head[hash_ptr(ptr, CKPT_OBJ_HASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->ptr == ptr)
+			return obj;
+	return NULL;
+}
+
+static struct ckpt_obj *obj_find_by_objref(const struct ckpt_obj_hash *obj_hash, int objref)
+{
+	struct hlist_head *h;
+	struct hlist_node *n;
+	struct ckpt_obj *obj;
+
+	h = &obj_hash->head[hash_long((unsigned long)objref,
+					   CKPT_OBJ_HASH_NBITS)];
+	hlist_for_each_entry(obj, n, h, hash)
+		if (obj->objref == objref)
+			return obj;
+	return NULL;
+}
+
+static int obj_alloc_objref(struct ckpt_obj_hash *obj_hash)
+{
+	return obj_hash->next_free_objref++;
+}
+
+/**
+ * ckpt_obj_new - add an object to the obj_hash
+ * @ptr: pointer to object
+ * @objref: object unique id
+ * @ops: object operations
+ *
+ * Add the object to the obj_hash. If @objref is zero, assign a unique
+ * object id and use @ptr as a hash key [checkpoint]. Else use @objref
+ * as a key [restart].
+ */
+static struct ckpt_obj *obj_new(struct ckpt_obj_hash *obj_hash, void *ptr,
+				int objref, enum obj_type type)
+{
+	const struct ckpt_obj_ops *ops = ckpt_obj_ops[type];
+	struct ckpt_obj *obj;
+	int i, ret;
+
+	if (WARN_ON_ONCE(!ptr))
+		return ERR_PTR(-EINVAL);
+
+	/* make sure we don't change this accidentally */
+	if (WARN_ON_ONCE(ops->obj_type != type))
+		return ERR_PTR(-EINVAL);
+
+	obj = kzalloc(sizeof(*obj), GFP_KERNEL);
+	if (!obj)
+		return ERR_PTR(-ENOMEM);
+
+	obj->ptr = ptr;
+	obj->ops = ops;
+
+	if (!objref) {
+		/* use @obj->ptr to index, assign objref (checkpoint) */
+		obj->objref = obj_alloc_objref(obj_hash);
+		i = hash_ptr(ptr, CKPT_OBJ_HASH_NBITS);
+	} else {
+		/* use @obj->objref to index (restart) */
+		obj->objref = objref;
+		i = hash_long((unsigned long) objref, CKPT_OBJ_HASH_NBITS);
+	}
+
+	ret = ops->ref_grab ? ops->ref_grab(obj->ptr) : 0;
+	if (ret < 0) {
+		kfree(obj);
+		obj = ERR_PTR(ret);
+	} else {
+		hlist_add_head(&obj->hash, &obj_hash->head[i]);
+	}
+
+	return obj;
+}
+
+/**************************************************************************
+ * Checkpoint
+ */
+
+/**
+ * obj_lookup_add - lookup object and add if not in objhash
+ * @ptr: pointer to object
+ * @type: object type
+ * @first: [output] first encounter (added to table)
+ *
+ * Look up the object pointed to by @ptr in the hash table. If it isn't
+ * already found there, add the object, and allocate a unique object
+ * id. Grab a reference to every object that is added, and maintain the
+ * reference until the entire hash is freed.
+ */
+static struct ckpt_obj *obj_lookup_add(struct ckpt_obj_hash *obj_hash, void *ptr,
+				       enum obj_type type, int *first)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_ptr(obj_hash, ptr);
+	if (!obj) {
+		obj = obj_new(obj_hash, ptr, 0, type);
+		*first = 1;
+	} else {
+		BUG_ON(obj->ops->obj_type != type);
+		*first = 0;
+	}
+	return obj;
+}
+
+/**
+ * checkpoint_obj - if not already in hash, add object and checkpoint
+ * @ctx: checkpoint context
+ * @ptr: pointer to object
+ * @type: object type
+ *
+ * Use obj_lookup_add() to lookup (and possibly add) the object to the
+ * hash table. If the CKPT_OBJ_CHECKPOINTED flag isn't set, then also
+ * save the object's state using its ops->checkpoint().
+ *
+ * [This is used during checkpoint].
+ * Returns: objref
+ */
+int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
+{
+	struct ckpt_hdr_objref *h;
+	struct ckpt_obj *obj;
+	int new, ret = 0;
+
+	obj = obj_lookup_add(ctx->obj_hash, ptr, type, &new);
+	if (IS_ERR(obj))
+		return PTR_ERR(obj);
+
+	if (!(obj->flags & CKPT_OBJ_CHECKPOINTED)) {
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_OBJREF);
+		if (!h)
+			return -ENOMEM;
+
+		h->objtype = type;
+		h->objref = obj->objref;
+		ret = ckpt_write_obj(ctx, &h->h);
+		kfree(h);
+
+		if (ret < 0)
+			return ret;
+
+		/* invoke callback to actually dump the state */
+		if (obj->ops->checkpoint)
+			ret = obj->ops->checkpoint(ctx, ptr);
+
+		obj->flags |= CKPT_OBJ_CHECKPOINTED;
+	}
+	return (ret < 0 ? ret : obj->objref);
+}
+
+/**************************************************************************
+ * Restart
+ */
+
+/**
+ * restore_obj - read in and restore a (first seen) shared object
+ * @ctx: checkpoint context
+ * @h: ckpt_hdr of shared object
+ *
+ * Read in the header payload (struct ckpt_hdr_objref). Lookup the
+ * object to verify it isn't there.  Then restore the object's state
+ * and add it to the objash. No need to explicitly grab a reference -
+ * we hold the initial instance of this object. (Object maintained
+ * until the entire hash is free).
+ *
+ * [This is used during restart].
+ */
+int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
+{
+	const struct ckpt_obj_ops *ops;
+	struct ckpt_obj *obj;
+	void *ptr = ERR_PTR(-EINVAL);
+
+	ckpt_debug("len %d ref %d type %d\n", h->h.len, h->objref, h->objtype);
+	if (h->objtype >= CKPT_OBJ_MAX)
+		return -EINVAL;
+	if (h->objref <= 0)
+		return -EINVAL;
+
+	ops = ckpt_obj_ops[h->objtype];
+	if (!ops)
+		return -ENOSYS;
+
+	BUG_ON(ops->obj_type != h->objtype);
+
+	if (ops->restore)
+		ptr = ops->restore(ctx);
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
+
+	obj = obj_find_by_objref(ctx->obj_hash, h->objref);
+	if (!obj) {
+		obj = obj_new(ctx->obj_hash, ptr, h->objref, h->objtype);
+		/*
+		 * Drop an extra reference to the object returned by
+		 * ops->restore to balance the one taken by obj_new()
+		 */
+		if (!IS_ERR(obj) && ops->ref_drop)
+			ops->ref_drop(ptr, 0);
+	} else if ((obj->ptr != ptr) || (obj->ops->obj_type != h->objtype)) {
+		/* Normally, we expect an object to not already exist
+		 * in the hash.  However, for some special scenarios
+		 * where we're restoring sets of objects that must be
+		 * co-allocated (such, as veth netdev pairs) we need
+		 * to tolerate this case if the second restore returns
+		 * the correct type and pointer, as specified in the
+		 * existing object.  If either of those don't match,
+		 * we fail.
+		 */
+		obj = ERR_PTR(-EINVAL);
+	}
+
+	if (IS_ERR(obj)) {
+		/* This releases our final reference on the object
+		 * returned by ops->restore()
+		 */
+		if (ops->ref_drop)
+			ops->ref_drop(ptr, 1);
+		return PTR_ERR(obj);
+	}
+	return obj->objref;
+}
+
+/**
+ * ckpt_obj_try_fetch - fetch an object by its identifier
+ * @ctx: checkpoint context
+ * @objref: object id
+ * @type: object type
+ *
+ * Lookup the objref identifier by @objref in the hash table. Return
+ * an error not found.
+ *
+ * [This is used during restart].
+ */
+void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	struct ckpt_obj *obj;
+
+	obj = obj_find_by_objref(ctx->obj_hash, objref);
+	if (!obj)
+		return ERR_PTR(-EINVAL);
+	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
+	if (obj->ops->obj_type == type)
+		return obj->ptr;
+	return ERR_PTR(-ENOMSG);
+}
+
+void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	void *ret = ckpt_obj_try_fetch(ctx, objref, type);
+
+	if (unlikely(IS_ERR(ret)))
+		ckpt_debug("objref=%d type=%u ret=%ld\n",
+			   objref, type, PTR_ERR(ret));
+	return ret;
+}
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
new file mode 100644
index 0000000..51f580f
--- /dev/null
+++ b/kernel/checkpoint/restart.c
@@ -0,0 +1,651 @@
+/*
+ *  Restart logic and helpers
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define DEBUG
+
+#include <linux/checkpoint.h>
+#include <linux/completion.h>
+#include <linux/elf.h>
+#include <linux/err.h>
+#include <linux/file.h>
+#include <linux/kernel.h>
+#include <linux/kthread.h>
+#include <linux/magic.h>
+#include <linux/mm_types.h>
+#include <linux/mmu_context.h>
+#include <linux/module.h>
+#include <linux/nsproxy.h>
+#include <linux/pid.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/syscalls.h>
+#include <linux/utsname.h>
+#include <linux/version.h>
+
+#include <asm/checkpoint.h>
+#include <asm/mmu_context.h>
+#include <asm/syscall.h>
+
+/**
+ * _ckpt_read_objref - dispatch handling of a shared object
+ * @ctx: checkpoint context
+ * @hh: objrect descriptor
+ */
+static int _ckpt_read_objref(struct ckpt_ctx *ctx, struct ckpt_hdr *hh)
+{
+	struct ckpt_hdr *h;
+	int ret;
+
+	h = kzalloc(hh->len, GFP_KERNEL);
+	if (!h)
+		return -ENOMEM;
+
+	*h = *hh;	/* yay ! */
+
+	ckpt_debug("shared len %d type %d\n", h->len, h->type);
+	ret = ckpt_kread(ctx, (h + 1), hh->len - sizeof(struct ckpt_hdr));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_obj(ctx, (struct ckpt_hdr_objref *) h);
+ out:
+	kfree(h);
+	return ret;
+}
+
+/**
+ * ckpt_read_obj_dispatch - dispatch ERRORs and OBJREFs; don't return them
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ */
+static int ckpt_read_obj_dispatch(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
+{
+	int ret;
+
+	while (1) {
+		ret = ckpt_kread(ctx, h, sizeof(*h));
+		if (ret < 0)
+			return ret;
+		ckpt_debug("type %d len %d\n", h->type, h->len);
+		if (h->len < sizeof(*h))
+			return -EINVAL;
+
+		if (h->type == CKPT_HDR_OBJREF) {
+			ret = _ckpt_read_objref(ctx, h);
+			if (ret < 0)
+				return ret;
+		} else
+			return 0;
+	}
+}
+
+/**
+ * _ckpt_read_obj - read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: desired ckpt_hdr
+ * @ptr: desired buffer
+ * @len: desired object length (if 0, flexible)
+ * @max: maximum object length (if 0, flexible)
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+static int _ckpt_read_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h,
+			  void *ptr, int len, int max)
+{
+	int ret;
+
+	ret = ckpt_read_obj_dispatch(ctx, h);
+	if (ret < 0)
+		return ret;
+	ckpt_debug("type %d len %d(%d,%d)\n", h->type, h->len, len, max);
+
+	/* if len specified, enforce, else if maximum specified, enforce */
+	if ((len && h->len != len) || (!len && max && h->len > max))
+		return -EINVAL;
+
+	if (ptr)
+		ret = ckpt_kread(ctx, ptr, h->len - sizeof(struct ckpt_hdr));
+	return ret;
+}
+
+/**
+ * _ckpt_read_obj_type - read an object of some type
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ * @type: buffer type
+ *
+ * If @ptr is NULL, then read only the header (payload to follow).
+ * @len specifies the expected buffer length (ignored if set to 0).
+ * Returns: actual _payload_ length
+ */
+int _ckpt_read_obj_type(struct ckpt_ctx *ctx, void *ptr, size_t len, int type)
+{
+	struct ckpt_hdr h;
+	int ret;
+
+	if (len)
+		len += sizeof(struct ckpt_hdr);
+	ret = _ckpt_read_obj(ctx, &h, ptr, len, len);
+	if (ret < 0)
+		return ret;
+	if (h.type != type)
+		return -EINVAL;
+	return h.len - sizeof(h);
+}
+
+/**
+ * _ckpt_read_buffer - read an object of type buffer (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: buffer length
+ *
+ * If @ptr is NULL, then read only the header (payload to follow).
+ * @len specifies the expected buffer length (ignored if set to 0).
+ * Returns: _payload_ length.
+ */
+int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, size_t len)
+{
+	BUG_ON(!len);
+	return _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
+}
+
+/**
+ * _ckpt_read_string - read an object of type string (set length)
+ * @ctx: checkpoint context
+ * @ptr: provided buffer
+ * @len: string length (including '\0')
+ *
+ * If @ptr is NULL, then read only the header (payload to follow)
+ */
+int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, size_t len)
+{
+	int ret;
+
+	BUG_ON(!len);
+	ret = _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_STRING);
+	if (ret < 0)
+		return ret;
+	if (ptr)
+		((char *) ptr)[len - 1] = '\0';	/* always play it safe */
+	return 0;
+}
+
+/**
+ * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
+ * @ctx: checkpoint context
+ * @h: object descriptor
+ * @len: desired total length (if 0, flexible)
+ * @max: maximum total length
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+static void *ckpt_read_obj(struct ckpt_ctx *ctx, int len, int max)
+{
+	struct ckpt_hdr hh;
+	struct ckpt_hdr *h;
+	int ret;
+
+	ret = ckpt_read_obj_dispatch(ctx, &hh);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	ckpt_debug("type %d len %d(%d,%d)\n", hh.type, hh.len, len, max);
+
+	/* if len specified, enforce, else if maximum specified, enforce */
+	if ((len && hh.len != len) || (!len && max && hh.len > max))
+		return ERR_PTR(-EINVAL);
+
+	h = kzalloc(hh.len, GFP_KERNEL);
+	if (!h)
+		return ERR_PTR(-ENOMEM);
+
+	*h = hh;	/* yay ! */
+
+	ret = ckpt_kread(ctx, (h + 1), hh.len - sizeof(struct ckpt_hdr));
+	if (ret < 0) {
+		kfree(h);
+		h = ERR_PTR(ret);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_obj_type - allocate and read an object of some type
+ * @ctx: checkpoint context
+ * @len: desired object length
+ * @type: desired object type
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_obj_type(struct ckpt_ctx *ctx, size_t len, int type)
+{
+	struct ckpt_hdr *h;
+
+	BUG_ON(!len);
+
+	h = ckpt_read_obj(ctx, len, len);
+	if (IS_ERR(h)) {
+		ckpt_debug("len=%d type=%d ret=%ld\n", len, type, PTR_ERR(h));
+		return h;
+	}
+
+	if (h->type != type) {
+		kfree(h);
+		ckpt_debug("expected type %d but got %d\n", h->type, type);
+		h = ERR_PTR(-EINVAL);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_buf_type - allocate and read an object of some type (flxible)
+ * @ctx: checkpoint context
+ * @max: maximum payload length
+ * @type: desired object type
+ *
+ * This differs from ckpt_read_obj_type() in that the length of the
+ * incoming object is flexible (up to the maximum specified by @max;
+ * unlimited if @max is 0), as determined by the ckpt_hdr data.
+ *
+ * NOTE: for symmetry with checkpoint, @max is the maximum _payload_
+ * size, excluding the header.
+ *
+ * Return: new buffer allocated on success, error pointer otherwise
+ */
+void *ckpt_read_buf_type(struct ckpt_ctx *ctx, size_t max, int type)
+{
+	struct ckpt_hdr *h;
+
+	if (max)
+		max += sizeof(struct ckpt_hdr);
+
+	h = ckpt_read_obj(ctx, 0, max);
+	if (IS_ERR(h))
+		return h;
+
+	if (h->type != type) {
+		kfree(h);
+		h = ERR_PTR(-EINVAL);
+	}
+
+	return h;
+}
+
+/**
+ * ckpt_read_payload - allocate and read the payload of an object
+ * @ctx: checkpoint context
+ * @max: maximum payload length
+ * @str: pointer to buffer to be allocated (caller must free)
+ * @type: desired object type
+ *
+ * This can be used to read a variable-length _payload_ from the checkpoint
+ * stream. @max limits the size of the resulting buffer.
+ *
+ * Return: actual _payload_ length
+ */
+int ckpt_read_payload(struct ckpt_ctx *ctx, void **ptr, size_t max, int type)
+{
+	int len, ret;
+
+	len = _ckpt_read_obj_type(ctx, NULL, 0, type);
+	if (len < 0)
+		return len;
+	else if (len > max)
+		return -EINVAL;
+
+	*ptr = kmalloc(len, GFP_KERNEL);
+	if (!*ptr)
+		return -ENOMEM;
+
+	ret = ckpt_kread(ctx, *ptr, len);
+	if (ret < 0) {
+		kfree(*ptr);
+		return ret;
+	}
+
+	return len;
+}
+
+/***********************************************************************
+ * Restart
+ */
+
+static int check_kernel_const(struct ckpt_const *h)
+{
+	struct task_struct *tsk;
+	struct new_utsname *uts;
+
+	/* task */
+	if (h->task_comm_len != sizeof(tsk->comm))
+		return -EINVAL;
+	/* mm->saved_auxv size */
+	if (h->at_vector_size != AT_VECTOR_SIZE)
+		return -EINVAL;
+	/* uts */
+	if (h->uts_release_len != sizeof(uts->release))
+		return -EINVAL;
+	if (h->uts_version_len != sizeof(uts->version))
+		return -EINVAL;
+	if (h->uts_machine_len != sizeof(uts->machine))
+		return -EINVAL;
+
+	return 0;
+}
+
+/* read the checkpoint header */
+static int restore_read_header(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_header *h;
+	struct new_utsname *uts = NULL;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_HEADER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (le16_to_cpu(h->arch_id) != CKPT_ARCH_ID) {
+		ckpt_debug("incompatible architecture id");
+		goto out;
+	}
+	if (h->magic != CHECKPOINT_MAGIC_HEAD ||
+	    h->major != ((LINUX_VERSION_CODE >> 16) & 0xff) ||
+	    h->minor != ((LINUX_VERSION_CODE >> 8) & 0xff) ||
+	    h->patch != ((LINUX_VERSION_CODE) & 0xff)) {
+		ckpt_debug("incompatible kernel version");
+		goto out;
+	}
+	if (h->uflags) {
+		ckpt_debug("incompatible restart user flags");
+		goto out;
+	}
+
+	ret = check_kernel_const(&h->constants);
+	if (ret < 0) {
+		ckpt_debug("incompatible kernel constants");
+		goto out;
+	}
+
+	ret = -ENOMEM;
+	uts = kmalloc(sizeof(*uts), GFP_KERNEL);
+	if (!uts)
+		goto out;
+
+	ret = _ckpt_read_buffer(ctx, uts->release, sizeof(uts->release));
+	if (ret < 0)
+		goto out;
+	ret = _ckpt_read_buffer(ctx, uts->version, sizeof(uts->version));
+	if (ret < 0)
+		goto out;
+	ret = _ckpt_read_buffer(ctx, uts->machine, sizeof(uts->machine));
+	if (ret < 0)
+		goto out;
+
+	ret = restore_read_header_arch(ctx);
+ out:
+	kfree(uts);
+	kfree(h);
+	return ret;
+}
+
+/* read the checkpoint trailer */
+static int restore_read_tail(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_tail *h;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TAIL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->magic != CHECKPOINT_MAGIC_TAIL)
+		ret = -EINVAL;
+
+	kfree(h);
+	return ret;
+}
+
+/* setup restart-specific parts of ctx */
+static int init_restart_ctx(struct ckpt_ctx *ctx)
+{
+	ctx->root_task = current;
+	return 0;
+}
+
+/* read the task_struct into the current task */
+static int restore_task_struct(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task *h;
+	struct task_struct *t = current;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	memset(t->comm, 0, TASK_COMM_LEN);
+	ret = _ckpt_read_string(ctx, t->comm, TASK_COMM_LEN);
+	if (ret < 0)
+		goto out;
+
+	t->set_child_tid = (int __user *) (unsigned long) h->set_child_tid;
+	t->clear_child_tid = (int __user *) (unsigned long) h->clear_child_tid;
+	/* return 1 for zombie, 0 otherwise */
+	ret = (h->state == TASK_DEAD ? 1 : 0);
+ out:
+	kfree(h);
+	return ret;
+}
+
+static int restore_task_objs(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_task_objs *h;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = restore_obj_file_table(ctx, h->files_objref);
+	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
+
+	ret = restore_obj_mm(ctx, h->mm_objref);
+	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+
+	kfree(h);
+	return ret;
+}
+
+/* read the entire state of the current task */
+static int restore_task(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	ret = restore_task_struct(ctx);
+	ckpt_debug("task %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_thread(ctx);
+	ckpt_debug("thread %d\n", ret);
+	if (ret < 0)
+		goto out;
+	ret = restore_task_objs(ctx);
+	ckpt_debug("objs %d\n", ret);
+ out:
+	return ret;
+}
+
+struct task_restart_info {
+	struct ckpt_ctx *ctx;
+	struct completion completion;
+	int status;
+};
+
+static void task_restart_info_init(struct task_restart_info *info, struct ckpt_ctx *ctx)
+{
+	info->ctx = ctx;
+	init_completion(&info->completion);
+	info->status = 0;
+}
+
+static int restore_task_fn(void *work)
+{
+	struct task_restart_info *info;
+	struct mm_struct *prev_mm;
+	struct mm_struct *new_mm;
+	struct ckpt_ctx *ctx;
+
+	info = work;
+	ctx = info->ctx;
+
+	/* FIXME: Move this stuff into a helper in kernel/fork.c so we
+	 * can correctly handle errors (free_mm, mm_free_pgd).
+	 */
+	BUG_ON(!(current->flags & PF_KTHREAD));
+	BUG_ON(current->mm);
+
+	info->status = sys_unshare(CLONE_FILES | CLONE_FS);
+	if (info->status)
+		return info->status;
+
+	current->flags &= ~(PF_KTHREAD | PF_NOFREEZE | PF_FREEZER_NOSIG);
+
+	info->status = -ENOMEM;
+	new_mm = mm_alloc();
+	if (!new_mm)
+		return info->status;
+
+	prev_mm = current->active_mm;
+	current->mm = new_mm;
+	current->active_mm = new_mm;
+
+	/* activate_mm/switch_mm need to execute atomically */
+	preempt_disable();
+	activate_mm(prev_mm, new_mm);
+	preempt_enable();
+
+	arch_pick_mmap_layout(new_mm);
+
+	if (init_new_context(current, new_mm))
+		goto err_out;
+
+	info->status = restore_task(ctx);
+	if (info->status < 0)
+		pr_err("restore task failed (%i)\n", info->status);
+
+	spin_lock_irq(&current->sighand->siglock);
+	flush_signal_handlers(current, 1);
+	spin_unlock_irq(&current->sighand->siglock);
+
+	__set_current_state(TASK_UNINTERRUPTIBLE);
+	info->status = 0;
+	complete(&info->completion);
+
+	/* vfork_done points to stack data which will no longer be valid;
+	 * see kthread.c:kthread().
+	 */
+	current->vfork_done = NULL;
+
+	schedule();
+	WARN_ON(true);
+	return info->status;
+err_out:
+	WARN_ONCE(true, "Leaking mm, sorry");
+	return info->status;
+}
+
+static int restore_task_tree(struct ckpt_ctx *ctx)
+{
+	struct task_restart_info *info;
+	struct task_struct *tsk;
+	struct pid *pid;
+	int err;
+
+	err = -ENOMEM;
+	info = kmalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		goto err_out;
+
+	task_restart_info_init(info, ctx);
+
+	tsk = kthread_run(restore_task_fn, info, "krestart");
+	if (IS_ERR(tsk))
+		goto err_out;
+
+	wait_for_completion(&info->completion);
+	wait_task_inactive(tsk, 0);
+	err = info->status;
+	if (err != 0) {
+		kthread_stop(tsk);
+		goto err_out;
+	}
+	err = restore_cpu(ctx, tsk);
+	ckpt_debug("cpu %d\n", err);
+	if (WARN_ON_ONCE(err < 0)) {
+		/* FIXME: kicking the task at this point is not a good
+		 * idea as its register state may have been changed.
+		 */
+		/* kthread_stop(); */
+		goto err_out;
+	}
+	write_lock_irq(&tasklist_lock);
+	tsk->parent = tsk->real_parent = ctx->root_task; /* this is current */
+	list_move_tail(&tsk->sibling, &tsk->parent->children);
+	write_unlock_irq(&tasklist_lock);
+#ifdef CONFIG_PREEMPT
+	task_thread_info(tsk)->preempt_count--;
+#endif
+	get_nsproxy(current->nsproxy);
+	switch_task_namespaces(tsk, current->nsproxy);
+	pid = alloc_pid(tsk->nsproxy->pid_ns);
+	if (WARN_ON_ONCE(!pid))
+		goto err_out;
+	ckpt_debug("new pid: level=%u, nr=%d, vnr=%d\n", pid->level,
+		   pid_nr(pid), pid_vnr(pid));
+	tsk->pid = pid_nr(pid);
+	tsk->tgid = tsk->pid;
+	detach_pid(tsk, PIDTYPE_PID);
+	attach_pid(tsk, PIDTYPE_PID, pid);
+	wake_up_process(tsk);
+err_out:
+	kfree(info);
+	return err;
+}
+
+/**
+ * do_restart() - restore the caller's pid namespace
+ * @ctx: checkpoint context
+ *
+ * The checkpoint image is read from @ctx->file.  Only the init
+ * process of the pid namespace is allowed to call this, and only when
+ * the caller is the sole task in the pid namespace.
+ */
+int do_restart(struct ckpt_ctx *ctx)
+{
+	int ret;
+
+	ret = init_restart_ctx(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = restore_read_header(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = restore_task_tree(ctx);
+	if (ret < 0)
+		return ret;
+
+	ret = restore_read_tail(ctx);
+
+	return ret;
+}
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
new file mode 100644
index 0000000..11ed6fd
--- /dev/null
+++ b/kernel/checkpoint/sys.c
@@ -0,0 +1,208 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+
+#include <linux/sched.h>
+#include <linux/module.h>
+#include <linux/nsproxy.h>
+#include <linux/kernel.h>
+#include <linux/cgroup.h>
+#include <linux/syscalls.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/uaccess.h>
+#include <linux/capability.h>
+#include <linux/checkpoint.h>
+
+/*
+ * Helpers to write(read) from(to) kernel space to(from) the checkpoint
+ * image file descriptor (similar to how a core-dump is performed).
+ *
+ *   _ckpt_kwrite() - write a kernel-space buffer to a file
+ *   _ckpt_kread() - read from a file to a kernel-space buffer
+ *
+ *   ckpt_kread() - read from the checkpoint image to a kernel-space buffer
+ *   ckpt_kwrite() - write a kernel-space buffer to the checkpoint image
+ *
+ * They latter two succeed only if the entire read or write succeeds,
+ * and return 0, or negative error otherwise.
+ */
+
+static ssize_t _ckpt_kwrite(struct file *file, void *addr, size_t count)
+{
+	mm_segment_t old_fs;
+	ssize_t ret;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = vfs_write(file, (void __user *)addr, count, &file->f_pos);
+	set_fs(old_fs);
+
+	/* Catch unhandled short writes */
+	if (WARN_ON_ONCE(ret >= 0 && ret < count))
+		ret = -EIO;
+
+	return ret;
+}
+
+/* returns 0 on success */
+int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, size_t count)
+{
+	int ret;
+
+	ret = _ckpt_kwrite(ctx->file, addr, count);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static ssize_t _ckpt_kread(struct file *file, void *addr, size_t count)
+{
+	mm_segment_t old_fs;
+	ssize_t ret;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	ret = vfs_read(file, (void __user *)addr, count, &file->f_pos);
+	set_fs(old_fs);
+
+	return ret;
+}
+
+/* returns 0 on success */
+int ckpt_kread(struct ckpt_ctx *ctx, void *addr, size_t count)
+{
+	int ret;
+
+	ret = _ckpt_kread(ctx->file, addr, count);
+	if (ret < 0)
+		return ret;
+	if (ret != count)
+		return -EPIPE;
+
+	return 0;
+}
+
+/**
+ * ckpt_hdr_get_type - get a hdr of certain size
+ * @ctx: checkpoint context
+ * @len: number of bytes to reserve
+ *
+ * Returns pointer to reserved space on hbuf
+ */
+void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
+{
+	struct ckpt_hdr *h;
+
+	h = kzalloc(len, GFP_KERNEL);
+	if (!h)
+		return NULL;
+
+	h->type = type;
+	h->len = len;
+	return h;
+}
+
+/*
+ * Helpers to manage c/r contexts: allocated for each checkpoint and/or
+ * restart operation, and persists until the operation is completed.
+ */
+
+static void ckpt_ctx_free(struct ckpt_ctx *ctx)
+{
+	if (ctx->file)
+		fput(ctx->file);
+
+	if (ctx->obj_hash)
+		ckpt_obj_hash_free(ctx->obj_hash);
+
+	path_put(&ctx->root_fs_path);
+
+	kfree(ctx);
+}
+
+static struct ckpt_ctx *ckpt_ctx_alloc(int fd)
+{
+	struct ckpt_ctx *ctx;
+	int err;
+
+	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
+	if (!ctx)
+		return ERR_PTR(-ENOMEM);
+
+	err = -EBADF;
+	ctx->file = fget(fd);
+	if (!ctx->file)
+		goto err;
+
+	err = -ENOMEM;
+	ctx->obj_hash = ckpt_obj_hash_alloc();
+	if (!ctx->obj_hash)
+		goto err;
+
+	return ctx;
+ err:
+	ckpt_ctx_free(ctx);
+	return ERR_PTR(err);
+}
+
+/**
+ * sys_checkpoint - checkpoint the caller's pidns and associated resources
+ * @fd: destination for the checkpoint image; need not be seekable
+ * @flags: checkpoint operation flags (no flags defined yet)
+ *
+ * Returns 0 on success, negated errno value otherwise.
+ */
+SYSCALL_DEFINE2(checkpoint, int, fd, unsigned int, flags)
+{
+	struct ckpt_ctx *ctx;
+	int err;
+
+	if (flags)
+		return -EINVAL;
+
+	ctx = ckpt_ctx_alloc(fd);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	err = do_checkpoint(ctx);
+
+	ckpt_ctx_free(ctx);
+
+	return err;
+}
+
+/**
+ * sys_restart - restore a pidns from a checkpoint image
+ * @fd: source for checkpoint image; need not be seekable
+ * @flags: restart operation flags (no flags defined yet)
+ *
+ * Returns 0 on success, negated errno value otherwise.
+ */
+SYSCALL_DEFINE2(restart, int, fd, unsigned int, flags)
+{
+	struct ckpt_ctx *ctx;
+	int err;
+
+	if (flags)
+		return -EINVAL;
+
+	ctx = ckpt_ctx_alloc(fd);
+	if (IS_ERR(ctx))
+		return PTR_ERR(ctx);
+
+	err = do_restart(ctx);
+
+	ckpt_ctx_free(ctx);
+
+	return err;
+}
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index c782fe9..b73a106 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -186,3 +186,7 @@ cond_syscall(sys_perf_event_open);
 /* fanotify! */
 cond_syscall(sys_fanotify_init);
 cond_syscall(sys_fanotify_mark);
+
+/* checkpoint/restart */
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
-- 
1.7.4
