From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/30] cr: core stuff
Date: Fri, 10 Apr 2009 06:35:39 +0400
Message-ID: <20090410023539.GK27788__43188.1521748894$1239331283$gmane$org@x200.localdomain>
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

* add struct file_operations::checkpoint

  The point of hook is to serialize enough information to allow restoration
  of an opened file.

  The idea (good one!) is that the code which supplies struct file_operations
  know better what to do with file.

  Hook gets C/R context (a cookie more or less) on which dump code can
  cr_write() and small restrictions on what to write: globally unique object id
  and correct object length to allow jumping through objects.

  For usual files on on-disk filesystem add generic_file_checkpoint()

  Add ext3 opened regular files and directories for start.

  No ->checkpoint, checkpointing is aborted -- deny by default.

FIXME: unlinked, but opened files aren't supported yet.

* C/R image design

  The thing should be flexible -- kernel internals changes every day, so we can't
  really afford a format with much enforced structure.

  Image consists of header, object images and terminator.

  Image header consists of immutable part and mutable part (for future).

  Immutable header part is magic and image version: "LinuxC/R" + __le32

  Image version determines everything including image header's mutable part.
  Image version is going to be bumped at earliest opportunity following changes
  in kernel internals.

  So far image header mutable part consists of arch of the kernel which dumped
  the image (i386, x86_64, ...) and kernel version as found in utsname.

  Kernel version as string is for distributions. Distro can support C/R for
  their own kernels, but can't realistically be expected to bump image version --
  this will conflict with mainline kernels having used same version. We also don't
  want requests for private parts of image version space.

  Distro expected to keep image version alone and on restart(2) check utsname
  version and compare it against previously release kernel versions and based
  on that turn on compatibility code.

  Object image is very flexible, the only required parts are a) object type (u32)
  and b) object total length (u32, [knocks wood]) which must be at the beginning
  of an image. The rest is not generic C/R code problem.

  Object images follow one another without holes. Holes are in theory possible but
  unneeded.

  Image ends with terminator object. This is mostly to be sure, that, yes, image
  wasn't truncated for some reason.


* Objects subject to C/R

  The idea is to not be very smart but directly dump core kernel data structures
  related to processes. This includes in this patch:

	struct task_struct
	struct mm_struct
	VMAs
	dirty pages
	struct file

  Relations between objects (task_struct has pointer to mm_struct) are fullfilled
  by dumping pointed to object first, keeping it's position in dumpfile and saving
  position in a image of pointe? object:

	struct cr_image_task_struct {
		cr_pos_t	cr_pos_mm;
			...
	};

  Code so far tries hard to dump objects in certain order so there won't be any loops.
  This property of process that dumpfile can in theory be O_APPEND, will likely be
  sacrifised (read: child can ptrace parent)

* add struct vm_operations_struct::checkpoint

  just like with files, code that creates special VMAs should know what to do with them
  used.

  just like with files, deny checkpointing by default

  So far used to install vDSO to same place.

* add checkpoint(2)

  Done by determining which tasks are subject to checkpointing, freezeing them,
  collecting pointers to necessary kernel internals (task_struct, mm_struct, ...),
  doing that checking supported/unsupported status and aborting if necessary,
  actual dumping, unfreezeing/killing set of tasks.

  Also in-checkpoint refcount is maintained to abort on possible invisible changes.
  Now it works:

	For every collected object (mm_struct) keep numbers of references from
	other collected objects. It should match object's own refcount.
	If there is a mismatch, something is likely pinning object, which means
	there is "leak" to outside which means checkpoint(2) can't realistically and
	without consequences proceed.

	This is in some sense independent check. It's designed to protect from internals
	change when C/R code was forgotten to be updated.

  Userpsace supplies pid of root task and opened file descriptor of future dump file.
  Kernel reports 0/-E as usual.

  Runtime tracking of "checkpointable" property is explicitly not done.
  This introduces overhead even if checkpoint(2) is not done as shown by proponents.
  Instead any check is done at checkpoint(2) time and -E is returned if something is
  suspicious or known to be unsupported.

  FIXME: more checks especially in cr_check_task_struct().

* add restart(2)

  Recreate tasks and evething dumped by checkpoint(2) as if nothing happened.

  The focus is on correct recreating, checking every possibility that target kernel
  can be on different arch (i386 => x86_64) and target kernel can be very different
  from source kernel by mistake (i386 => x86_64 COMPAT=n) kernel.

  restart(2) is done first by creating kernel thread and that demoting it to usual
  process by adding mm_struct, VMAs, et al. This saves time against method when
  userspace does fork(2)+restart(2) -- forked mm_struct will be thrown out anyway
  or at least everything will be unmapped in any case.

  Restoration is done in current context except CPU registers at last stage.
  This is because "creation is done by current" is in many, many places,
   e.g. mmap(2) code.

  It's expected that filesystem state will be the same. Kernel can't do anything
  about it expect probably virtual filesystems. If a file is not there anymore,
  it's not kernel fault, -E will be returned, restart aborted.

  FIXME: errors aren't propagated correctly out of kernel thread context

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 fs/ext3/dir.c            |    3 
 fs/ext3/file.c           |    3 
 include/linux/Kbuild     |    1 
 include/linux/cr.h       |  112 ++++++++
 include/linux/fs.h       |   12 
 include/linux/mm.h       |    4 
 include/linux/syscalls.h |    3 
 init/Kconfig             |    2 
 kernel/Makefile          |    1 
 kernel/cr/Kconfig        |    7 
 kernel/cr/Makefile       |    6 
 kernel/cr/cpt-sys.c      |  178 ++++++++++++++
 kernel/cr/cr-context.c   |  139 +++++++++++
 kernel/cr/cr-file.c      |  221 +++++++++++++++++
 kernel/cr/cr-mm.c        |  590 +++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cr/cr-task.c      |  252 ++++++++++++++++++++
 kernel/cr/cr.h           |  158 ++++++++++++
 kernel/cr/rst-sys.c      |   87 ++++++
 kernel/sys_ni.c          |    3 
 mm/filemap.c             |    3 
 20 files changed, 1783 insertions(+), 2 deletions(-)

--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -48,6 +48,9 @@ const struct file_operations ext3_dir_operations = {
 #endif
 	.fsync		= ext3_sync_file,	/* BKL held */
 	.release	= ext3_release_dir,
+#ifdef CONFIG_CR
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -126,6 +126,9 @@ const struct file_operations ext3_file_operations = {
 	.fsync		= ext3_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+#ifdef CONFIG_CR
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ext3_file_inode_operations = {
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -50,6 +50,7 @@ header-y += coff.h
 header-y += comstats.h
 header-y += const.h
 header-y += cgroupstats.h
+header-y += cr.h
 header-y += cramfs_fs.h
 header-y += cycx_cfm.h
 header-y += dcbnl.h
new file mode 100644
--- /dev/null
+++ b/include/linux/cr.h
@@ -0,0 +1,112 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#ifndef __INCLUDE_LINUX_CR_H
+#define __INCLUDE_LINUX_CR_H
+
+#include <linux/compiler.h>
+#include <linux/types.h>
+
+#define CR_POS_UNDEF	(~0ULL)
+typedef __u64 cr_pos_t;	/* position of another object in a dumpfile */
+
+struct cr_image_header {
+	/* Immutable part except version bumps. */
+#define CR_IMAGE_MAGIC	"LinuxC/R"
+	__u8	cr_image_magic[8];
+#define CR_IMAGE_VERSION	1
+	__le32	cr_image_version;
+
+	/* Mutable part. */
+	/* Arch of the kernel which dumped the image. */
+	__le32	cr_arch;
+	/*
+	 * Distributions are expected to leave image version alone and
+	 * demultiplex by this field on restart.
+	 */
+	__u8	cr_uts_release[64];
+} __packed;
+
+struct cr_object_header {
+#define CR_OBJ_TERMINATOR	0xFFFFFFFFu
+#define CR_OBJ_TASK_STRUCT	1
+#define CR_OBJ_MM_STRUCT	2
+#define CR_OBJ_FILE		3
+#define CR_OBJ_VMA		4
+#define CR_OBJ_VMA_CONTENT	5
+	__u32	cr_type;	/* object type */
+	__u32	cr_len;		/* object length in bytes including header */
+} __packed;
+
+/*
+ * 1. struct cr_object_header MUST start object's image.
+ * 2. Every member SHOULD start with 'cr_' prefix.
+ * 3. Every member which refers to position of another object image in
+ *    a dumpfile MUST have cr_pos_t type and SHOULD additionally use 'pos_'
+ *    prefix.
+ * 4. Size and layout of every object type image MUST be the same on all
+ *    architectures.
+ */
+
+struct cr_image_task_struct {
+	struct cr_object_header cr_hdr;
+
+	cr_pos_t	cr_pos_real_parent;
+	cr_pos_t	cr_pos_mm;
+
+	__u8		cr_comm[16];
+
+	/* Native arch of task, one of CR_ARCH_*. */
+	__u32		cr_tsk_arch;
+	__u32		cr_len_arch;
+} __packed;
+
+struct cr_image_mm_struct {
+	struct cr_object_header cr_hdr;
+
+	__u64		cr_def_flags;
+	__u64		cr_start_code;
+	__u64		cr_end_code;
+	__u64		cr_start_data;
+	__u64		cr_end_data;
+	__u64		cr_start_brk;
+	__u64		cr_brk;
+	__u64		cr_start_stack;
+	__u64		cr_arg_start;
+	__u64		cr_arg_end;
+	__u64		cr_env_start;
+	__u64		cr_env_end;
+	__u8		cr_saved_auxv[416];
+	__u64		cr_flags;
+
+	__u32		cr_len_arch;
+} __packed;
+
+struct cr_image_vma {
+	struct cr_object_header cr_hdr;
+
+	__u64		cr_vm_start;
+	__u64		cr_vm_end;
+	__u64		cr_vm_page_prot;
+	__u64		cr_vm_flags;
+	__u64		cr_vm_pgoff;
+	cr_pos_t	cr_pos_vm_file;
+} __packed;
+
+struct cr_image_vma_content {
+	struct cr_object_header cr_hdr;
+
+	__u64		cr_start_addr;
+	__u32		cr_nr_pages;
+	__u32		cr_page_size;
+	/* __u8 cr_data[cr_nr_pages * cr_page_size]; */
+} __packed;
+
+struct cr_image_file {
+	struct cr_object_header cr_hdr;
+
+	__u32		cr_i_mode;
+	__u32		cr_f_flags;
+	__u64		cr_f_pos;
+	__u32		cr_name_len;
+	/* __u8	cr_name[cr_name_len] */
+} __packed;
+#endif
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -328,6 +328,7 @@ struct poll_table_struct;
 struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
+struct cr_context;
 struct cred;
 
 extern void __init inode_init(void);
@@ -1452,6 +1453,9 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+#ifdef CONFIG_CR
+	int (*checkpoint)(struct file *file, struct cr_context *ctx);
+#endif
 };
 
 struct inode_operations {
@@ -2022,7 +2026,9 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end, int sync_mode);
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
-
+#ifdef CONFIG_CR
+int filemap_checkpoint(struct vm_area_struct *vma, struct cr_context *ctx);
+#endif
 extern int vfs_fsync(struct file *file, struct dentry *dentry, int datasync);
 extern void sync_supers(void);
 extern void sync_filesystems(int wait);
@@ -2144,7 +2150,9 @@ extern ssize_t do_sync_read(struct file *filp, char __user *buf, size_t len, lof
 extern ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, loff_t *ppos);
 extern int generic_segment_checks(const struct iovec *iov,
 		unsigned long *nr_segs, size_t *count, int access_flags);
-
+#ifdef CONFIG_CR
+int generic_file_checkpoint(struct file *file, struct cr_context *ctx);
+#endif
 /* fs/splice.c */
 extern ssize_t generic_file_splice_read(struct file *, loff_t *,
 		struct pipe_inode_info *, size_t, unsigned int);
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -16,6 +16,7 @@
 
 struct mempolicy;
 struct anon_vma;
+struct cr_context;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
@@ -220,6 +221,9 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
+#ifdef CONFIG_CR
+	int (*checkpoint)(struct vm_area_struct *vma, struct cr_context *ctx);
+#endif
 };
 
 struct mmu_gather;
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -752,6 +752,9 @@ asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 asmlinkage long sys_pipe2(int __user *, int);
 asmlinkage long sys_pipe(int __user *);
 
+asmlinkage long sys_checkpoint(pid_t pid, int fd, int flags);
+asmlinkage long sys_restart(int fd, int flags);
+
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
 #endif
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -608,6 +608,8 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
 endif # CGROUPS
 
+source "kernel/cr/Kconfig"
+
 config MM_OWNER
 	bool
 
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_FREEZER) += power/
 obj-$(CONFIG_BSD_PROCESS_ACCT) += acct.o
 obj-$(CONFIG_KEXEC) += kexec.o
 obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
+obj-$(CONFIG_CR) += cr/
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
new file mode 100644
--- /dev/null
+++ b/kernel/cr/Kconfig
@@ -0,0 +1,7 @@
+config CR
+	bool "Container checkpoint/restart"
+	select FREEZER
+	help
+	  Container checkpoint/restart.
+
+	  Say N.
new file mode 100644
--- /dev/null
+++ b/kernel/cr/Makefile
@@ -0,0 +1,6 @@
+obj-$(CONFIG_CR) += cr.o
+cr-y := cpt-sys.o rst-sys.o
+cr-y += cr-context.o
+cr-y += cr-file.o
+cr-y += cr-mm.o
+cr-y += cr-task.o
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cpt-sys.c
@@ -0,0 +1,178 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+/* checkpoint(2) */
+#include <linux/capability.h>
+#include <linux/file.h>
+#include <linux/freezer.h>
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
+#include <linux/rcupdate.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/utsname.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+/* 'tsk' is child of 'parent' in some generation. */
+static int child_of(struct task_struct *parent, struct task_struct *tsk)
+{
+	struct task_struct *tmp = tsk;
+
+	while (tmp != &init_task) {
+		if (tmp == parent)
+			return 1;
+		tmp = tmp->real_parent;
+	}
+	/* In case 'parent' is 'init_task'. */
+	return tmp == parent;
+}
+
+static int cr_freeze_tasks(struct task_struct *init_tsk)
+{
+	struct task_struct *tmp, *tsk;
+
+	read_lock(&tasklist_lock);
+	do_each_thread(tmp, tsk) {
+		if (child_of(init_tsk, tsk)) {
+			if (!freeze_task(tsk, 1)) {
+				printk("%s: freezing '%s' failed\n", __func__, tsk->comm);
+				read_unlock(&tasklist_lock);
+				return -EBUSY;
+			}
+		}
+	} while_each_thread(tmp, tsk);
+	read_unlock(&tasklist_lock);
+	return 0;
+}
+
+static void cr_thaw_tasks(struct task_struct *init_tsk)
+{
+	struct task_struct *tmp, *tsk;
+
+	read_lock(&tasklist_lock);
+	do_each_thread(tmp, tsk) {
+		if (child_of(init_tsk, tsk))
+			thaw_process(tsk);
+	} while_each_thread(tmp, tsk);
+	read_unlock(&tasklist_lock);
+}
+
+static int cr_collect(struct cr_context *ctx)
+{
+	int rv;
+
+	rv = cr_collect_all_task_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_all_mm_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_all_file(ctx);
+	if (rv < 0)
+		return rv;
+	return 0;
+}
+
+static int cr_dump_image_header(struct cr_context *ctx)
+{
+	struct cr_image_header i;
+
+	memset(&i, 0, sizeof(struct cr_image_header));
+	memcpy(i.cr_image_magic, CR_IMAGE_MAGIC, 8);
+	i.cr_image_version = cpu_to_le32(CR_IMAGE_VERSION);
+
+	i.cr_arch = cpu_to_le32(cr_image_header_arch());
+	strlcpy((char *)&i.cr_uts_release, (const char *)init_uts_ns.name.release, sizeof(i.cr_uts_release));
+
+	return cr_write(ctx, &i, sizeof(i));
+}
+
+static int cr_dump_terminator(struct cr_context *ctx)
+{
+	struct cr_object_header i;
+
+	i.cr_type = CR_OBJ_TERMINATOR;
+	i.cr_len = sizeof(i);
+	return cr_write(ctx, &i, sizeof(i));
+}
+
+static int cr_dump(struct cr_context *ctx)
+{
+	int rv;
+
+	rv = cr_dump_image_header(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_file(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_mm_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_dump_all_task_struct(ctx);
+	if (rv < 0)
+		return rv;
+	return cr_dump_terminator(ctx);
+}
+
+SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, int, flags)
+{
+	struct cr_context *ctx;
+	struct file *file;
+	struct task_struct *init_tsk = NULL, *tsk;
+	int rv = 0;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	file = fget(fd);
+	if (!file)
+		return -EBADF;
+
+	/* Determine root of hierarchy to be checkpointed. */
+	rcu_read_lock();
+	tsk = find_task_by_vpid(pid);
+	if (tsk) {
+		struct nsproxy *nsproxy;
+
+		nsproxy = task_nsproxy(tsk);
+		if (nsproxy) {
+			init_tsk = nsproxy->pid_ns->child_reaper;
+			if (init_tsk != tsk)
+				init_tsk = NULL;
+		} else
+			init_tsk = NULL;
+		if (init_tsk)
+			get_task_struct(init_tsk);
+	}
+	rcu_read_unlock();
+	if (!init_tsk) {
+		rv = -ESRCH;
+		goto out_no_init_tsk;
+	}
+
+	ctx = cr_context_create(init_tsk, file);
+	if (!ctx) {
+		rv = -ENOMEM;
+		goto out_ctx_create;
+	}
+
+	rv = cr_freeze_tasks(init_tsk);
+	if (rv < 0)
+		goto out_freeze;
+	rv = cr_collect(ctx);
+	if (rv < 0)
+		goto out_collect;
+	rv = cr_dump(ctx);
+
+out_collect:
+	/* FIXME: cr_kill_tasks() */
+	cr_thaw_tasks(init_tsk);
+out_freeze:
+	cr_context_destroy(ctx);
+out_ctx_create:
+	put_task_struct(init_tsk);
+out_no_init_tsk:
+	fput(file);
+	return rv;
+}
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-context.c
@@ -0,0 +1,139 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/cr.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <asm/processor.h>
+#include <asm/uaccess.h>
+#include "cr.h"
+
+void *cr_prepare_image(unsigned int type, size_t len)
+{
+	void *p;
+
+	p = kzalloc(len, GFP_KERNEL);
+	if (p) {
+		/* Any image must start with header. */
+		struct cr_object_header *cr_hdr = p;
+
+		cr_hdr->cr_type = type;
+		cr_hdr->cr_len = len;
+	}
+	return p;
+}
+
+int cr_pread(struct cr_context *ctx, void *buf, size_t count, loff_t pos)
+{
+	struct file *file = ctx->cr_dump_file;
+	mm_segment_t old_fs;
+	ssize_t rv;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	rv = vfs_read(file, (char __user *)buf, count, &pos);
+	set_fs(old_fs);
+	if (rv != count)
+		return (rv < 0) ? rv : -EIO;
+	return 0;
+}
+
+int cr_write(struct cr_context *ctx, const void *buf, size_t count)
+{
+	struct file *file = ctx->cr_dump_file;
+	mm_segment_t old_fs;
+	ssize_t rv;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+write_more:
+	rv = vfs_write(file, (const char __user *)buf, count, &file->f_pos);
+	if (rv > 0 && rv < count) {
+		buf += rv;
+		count -= rv;
+		goto write_more;
+	}
+	set_fs(old_fs);
+	return (rv < 0) ? rv : 0;
+}
+
+struct cr_object *cr_object_create(void *data)
+{
+	struct cr_object *obj;
+
+	obj = kmalloc(sizeof(struct cr_object), GFP_KERNEL);
+	if (obj) {
+		obj->o_count = 1;
+		obj->o_obj = data;
+	}
+	return obj;
+}
+
+int cr_collect_object(struct cr_context *ctx, void *p, enum cr_context_obj_type type)
+{
+	struct cr_object *obj;
+
+	obj = cr_find_obj_by_ptr(ctx, p, type);
+	if (obj) {
+		obj->o_count++;
+		return 0;
+	}
+	obj = cr_object_create(p);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[type]);
+	return 0;
+}
+
+struct cr_context *cr_context_create(struct task_struct *tsk, struct file *file)
+{
+	struct cr_context *ctx;
+
+	ctx = kmalloc(sizeof(struct cr_context), GFP_KERNEL);
+	if (ctx) {
+		int i;
+
+		ctx->cr_init_tsk = tsk;
+		ctx->cr_dump_file = file;
+		for (i = 0; i < NR_CR_CTX_TYPES; i++)
+			INIT_LIST_HEAD(&ctx->cr_obj[i]);
+	}
+	return ctx;
+}
+
+void cr_context_destroy(struct cr_context *ctx)
+{
+	struct cr_object *obj, *tmp;
+	int i;
+
+	for (i = 0; i < NR_CR_CTX_TYPES; i++) {
+		for_each_cr_object_safe(ctx, obj, tmp, i) {
+			list_del(&obj->o_list);
+			cr_object_destroy(obj);
+		}
+	}
+	kfree(ctx);
+}
+
+struct cr_object *cr_find_obj_by_ptr(struct cr_context *ctx, const void *ptr, enum cr_context_obj_type type)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, type) {
+		if (obj->o_obj == ptr)
+			return obj;
+	}
+	return NULL;
+}
+
+struct cr_object *cr_find_obj_by_pos(struct cr_context *ctx, loff_t pos, enum cr_context_obj_type type)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, type) {
+		if (obj->o_pos == pos)
+			return obj;
+	}
+	return NULL;
+}
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-file.c
@@ -0,0 +1,221 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fdtable.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/major.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/stat.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static inline int d_unlinked(struct dentry *dentry)
+{
+	return !IS_ROOT(dentry) && d_unhashed(dentry);
+}
+
+static int cr_check_file(struct file *file)
+{
+	if (!file->f_op) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (file->f_op && !file->f_op->checkpoint) {
+		WARN(1, "file %pS isn't checkpointable\n", file->f_op);
+		return -EINVAL;
+	}
+	if (d_unlinked(file->f_path.dentry)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#ifdef CONFIG_SECURITY
+	if (file->f_security) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+#ifdef CONFIG_EPOLL
+	spin_lock(&file->f_lock);
+	if (!list_empty(&file->f_ep_links)) {
+		spin_unlock(&file->f_lock);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	spin_unlock(&file->f_lock);
+#endif
+	return 0;
+}
+
+static int cr_collect_file(struct cr_context *ctx, struct file *file)
+{
+	int rv;
+
+	rv = cr_check_file(file);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, file, CR_CTX_FILE);
+	printk("collect file %p: rv %d\n", file, rv);
+	return rv;
+}
+
+int cr_collect_all_file(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
+		struct mm_struct *mm = obj->o_obj;
+		struct vm_area_struct *vma;
+
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (vma->vm_file) {
+				rv = cr_collect_file(ctx, vma->vm_file);
+				if (rv < 0)
+					return rv;
+			}
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		unsigned long cnt = atomic_long_read(&file->f_count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: file %p/%pS has external references %lu:%lu\n", __func__, file, file->f_op, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+int generic_file_checkpoint(struct file *file, struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	struct cr_image_file *i;
+	struct kstat stat;
+	char *buf, *name;
+	int rv;
+
+	obj = cr_find_obj_by_ptr(ctx, file, CR_CTX_FILE);
+	i = cr_prepare_image(CR_OBJ_FILE, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = vfs_getattr(file->f_path.mnt, file->f_path.dentry, &stat);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+	i->cr_i_mode = stat.mode;
+	i->cr_f_flags = file->f_flags;
+	i->cr_f_pos = file->f_pos;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	name = d_path(&file->f_path, buf, PAGE_SIZE);
+	if (IS_ERR(name)) {
+		kfree(buf);
+		kfree(i);
+		return PTR_ERR(name);
+	}
+	i->cr_name_len = buf + PAGE_SIZE - 1 - name;
+	i->cr_hdr.cr_len += i->cr_name_len;
+
+	printk("dump file %p: '%.*s', ->f_op = %pS\n", file, i->cr_name_len, name, file->f_op);
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	if (rv == 0)
+		rv = cr_write(ctx, name, i->cr_name_len);
+	kfree(buf);
+	kfree(i);
+	return rv;
+}
+EXPORT_SYMBOL_GPL(generic_file_checkpoint);
+
+static int cr_dump_file(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct file *file = obj->o_obj;
+
+	return file->f_op->checkpoint(file, ctx);
+}
+
+int cr_dump_all_file(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		rv = cr_dump_file(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_restore_file(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_file *i, *tmp;
+	struct file *file;
+	struct cr_object *obj;
+	char *cr_name;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_FILE) {
+		kfree(i);
+		return -EINVAL;
+	}
+	/* Image of struct file is variable-sized. */
+	tmp = i;
+	i = krealloc(i, i->cr_hdr.cr_len + 1, GFP_KERNEL);
+	if (!i) {
+		kfree(tmp);
+		return -ENOMEM;
+	}
+	cr_name = (char *)(i + 1);
+	rv = cr_pread(ctx, cr_name, i->cr_name_len, pos + sizeof(*i));
+	if (rv < 0) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	cr_name[i->cr_name_len] = '\0';
+
+	file = filp_open(cr_name, i->cr_f_flags, 0);
+	if (IS_ERR(file)) {
+		kfree(i);
+		return PTR_ERR(file);
+	}
+	if (file->f_dentry->d_inode->i_mode != i->cr_i_mode) {
+		fput(file);
+		kfree(i);
+		return -EINVAL;
+	}
+	if (vfs_llseek(file, i->cr_f_pos, SEEK_SET) != i->cr_f_pos) {
+		fput(file);
+		kfree(i);
+		return -EINVAL;
+	}
+
+	obj = cr_object_create(file);
+	if (!obj) {
+		fput(file);
+		kfree(i);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_FILE]);
+	printk("restore file %p, pos %lld: '%s'\n", file, (long long)pos, cr_name);
+	kfree(i);
+	return 0;
+}
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-mm.c
@@ -0,0 +1,590 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/highmem.h>
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+#include <linux/sched.h>
+#include <asm/elf.h>
+#include <asm/mman.h>
+#include <asm/mmu_context.h>
+#include <asm/pgalloc.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_vma(struct vm_area_struct *vma)
+{
+	unsigned long vm_flags;
+
+	if (vma->vm_ops && !vma->vm_ops->checkpoint) {
+		WARN(1, "vma %08lx-%08lx %pS isn't checkpointable\n", vma->vm_start, vma->vm_end, vma->vm_ops);
+		return -EINVAL;
+	}
+
+	vm_flags = vma->vm_flags;
+	/* Known good and unknown bad flags. */
+	vm_flags &= ~VM_READ;
+	vm_flags &= ~VM_WRITE;
+	vm_flags &= ~VM_EXEC;
+//	vm_flags &= ~VM_SHARED;
+	vm_flags &= ~VM_MAYREAD;
+	vm_flags &= ~VM_MAYWRITE;
+	vm_flags &= ~VM_MAYEXEC;
+//	vm_flags &= ~VM_MAYSHARE;
+	vm_flags &= ~VM_GROWSDOWN;
+//	vm_flags &= ~VM_GROWSUP;
+//	vm_flags &= ~VM_PFNMAP;
+	vm_flags &= ~VM_DENYWRITE;
+	vm_flags &= ~VM_EXECUTABLE;
+//	vm_flags &= ~VM_LOCKED;
+//	vm_flags &= ~VM_IO;
+//	vm_flags &= ~VM_SEQ_READ;
+//	vm_flags &= ~VM_RAND_READ;
+//	vm_flags &= ~VM_DONTCOPY;
+	vm_flags &= ~VM_DONTEXPAND;
+//	vm_flags &= ~VM_RESERVED;
+	vm_flags &= ~VM_ACCOUNT;
+//	vm_flags &= ~VM_NORESERVE;
+//	vm_flags &= ~VM_HUGETLB;
+//	vm_flags &= ~VM_NONLINEAR;
+//	vm_flags &= ~VM_MAPPED_COPY;
+//	vm_flags &= ~VM_INSERTPAGE;
+	vm_flags &= ~VM_ALWAYSDUMP;
+	vm_flags &= ~VM_CAN_NONLINEAR;
+//	vm_flags &= ~VM_MIXEDMAP;
+//	vm_flags &= ~VM_SAO;
+//	vm_flags &= ~VM_PFN_AT_MMAP;
+
+	if (vm_flags) {
+		WARN(1, "vma %08lx-%08lx %pS uses uncheckpointable flags 0x%08lx\n", vma->vm_start, vma->vm_end, vma->vm_ops, vm_flags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int cr_dump_vma_pages(struct cr_context *ctx, struct vm_area_struct *vma)
+{
+	unsigned long addr;
+	int rv;
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		struct page *page;
+
+		page = follow_page(vma, addr, FOLL_ANON|FOLL_GET);
+		if (!page || IS_ERR(page))
+			return PTR_ERR(page);
+		if (page == ZERO_PAGE(0)) {
+			put_page(page);
+			continue;
+		}
+
+		if (PageAnon(page) || (!PageAnon(page) && !page_mapping(page))) {
+			struct cr_image_vma_content i;
+			void *data;
+
+			printk("dump addr %p, page %p\n", (void *)addr, page);
+
+			i.cr_hdr.cr_type = CR_OBJ_VMA_CONTENT;
+			i.cr_hdr.cr_len = sizeof(i) + 1 * PAGE_SIZE;
+
+			i.cr_start_addr = addr;
+			i.cr_nr_pages = 1;
+			i.cr_page_size = PAGE_SIZE;
+			rv = cr_write(ctx, &i, sizeof(i));
+			if (rv < 0) {
+				put_page(page);
+				return rv;
+			}
+
+			data = kmap(page);
+			rv = cr_write(ctx, data, 1 * PAGE_SIZE);
+			kunmap(page);
+			if (rv < 0) {
+				put_page(page);
+				return rv;
+			}
+		}
+		put_page(page);
+	}
+	return 0;
+}
+
+static int cr_dump_anonvma(struct cr_context *ctx, struct vm_area_struct *vma)
+{
+	struct cr_image_vma *i;
+	int rv;
+
+	printk("dump vma %p: %08lx-%08lx %c%c%c%c vm_flags 0x%08lx, vm_pgoff = 0x%08lx\n",
+		vma, vma->vm_start, vma->vm_end,
+		vma->vm_flags & VM_READ ? 'r' : '-',
+		vma->vm_flags & VM_WRITE ? 'w' : '-',
+		vma->vm_flags & VM_EXEC ? 'x' : '-',
+		vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
+		vma->vm_flags,
+		vma->vm_pgoff);
+
+	i = cr_prepare_image(CR_OBJ_VMA, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_vm_start = vma->vm_start;
+	i->cr_vm_end = vma->vm_end;
+	i->cr_vm_page_prot = pgprot_val(vma->vm_page_prot);
+	i->cr_vm_flags = vma->vm_flags;
+	i->cr_vm_pgoff = vma->vm_pgoff;
+	i->cr_pos_vm_file = CR_POS_UNDEF;
+
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+	return cr_dump_vma_pages(ctx, vma);
+}
+
+int filemap_checkpoint(struct vm_area_struct *vma, struct cr_context *ctx)
+{
+	struct cr_image_vma *i;
+	struct cr_object *tmp;
+	int rv;
+
+	printk("dump vma %p: %08lx-%08lx %c%c%c%c vm_flags 0x%08lx, ->vm_ops = %pS, vm_pgoff = 0x%08lx\n",
+		vma, vma->vm_start, vma->vm_end,
+		vma->vm_flags & VM_READ ? 'r' : '-',
+		vma->vm_flags & VM_WRITE ? 'w' : '-',
+		vma->vm_flags & VM_EXEC ? 'x' : '-',
+		vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
+		vma->vm_flags,
+		vma->vm_ops,
+		vma->vm_pgoff);
+
+	i = cr_prepare_image(CR_OBJ_VMA, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_vm_start = vma->vm_start;
+	i->cr_vm_end = vma->vm_end;
+	i->cr_vm_page_prot = pgprot_val(vma->vm_page_prot);
+	i->cr_vm_flags = vma->vm_flags;
+	i->cr_vm_pgoff = vma->vm_pgoff;
+	tmp = cr_find_obj_by_ptr(ctx, vma->vm_file, CR_CTX_FILE);
+	i->cr_pos_vm_file = tmp->o_pos;
+
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+	return cr_dump_vma_pages(ctx, vma);
+}
+
+static int cr_dump_vma(struct cr_context *ctx, struct vm_area_struct *vma)
+{
+	if (!vma->vm_ops)
+		return cr_dump_anonvma(ctx, vma);
+	if (vma->vm_ops->checkpoint)
+		return vma->vm_ops->checkpoint(vma, ctx);
+	BUG();
+}
+
+static int __cr_restore_vma_content(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_vma_content i;
+	struct page *page;
+	void *addr;
+	int rv;
+
+	rv = cr_pread(ctx, &i, sizeof(i), pos);
+	if (rv < 0)
+		return rv;
+//	printk("%s: cr_start_addr = 0x%08lx, nr_pages = %u, page_size = %u\n", __func__, (unsigned long)i.cr_start_addr, i.cr_nr_pages, i.cr_page_size);
+	if (i.cr_hdr.cr_type != CR_OBJ_VMA_CONTENT || i.cr_nr_pages != 1 || i.cr_page_size != PAGE_SIZE)
+		return -EINVAL;
+
+	rv = get_user_pages(current, current->mm, i.cr_start_addr, 1, 1, 1, &page, NULL);
+//	printk("%s: get_user_pages => %d\n", __func__, rv);
+	if (rv != 1)
+		return (rv < 0) ? rv : -EFAULT;
+	addr = kmap(page);
+	rv = cr_pread(ctx, addr, PAGE_SIZE, pos + sizeof(i));
+	set_page_dirty_lock(page);
+	kunmap(page);
+	put_page(page);
+//	printk("%s: return %d\n", __func__, rv);
+	return rv;
+}
+
+static int cr_restore_vma_content(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_object_header cr_hdr;
+	int rv;
+
+	while (1) {
+		rv = cr_pread(ctx, &cr_hdr, sizeof(cr_hdr), pos);
+		if (rv < 0)
+			return rv;
+		switch (cr_hdr.cr_type) {
+		case CR_OBJ_VMA_CONTENT:
+			rv = __cr_restore_vma_content(ctx, pos);
+			if (rv < 0)
+				return rv;
+			break;
+		default:
+			return 0;
+		}
+		pos += cr_hdr.cr_len;
+	}
+	return 0;
+}
+
+static int make_prot(struct cr_image_vma *i)
+{
+	unsigned long prot = PROT_NONE;
+
+	if (i->cr_vm_flags & VM_READ)
+		prot |= PROT_READ;
+	if (i->cr_vm_flags & VM_WRITE)
+		prot |= PROT_WRITE;
+	if (i->cr_vm_flags & VM_EXEC)
+		prot |= PROT_EXEC;
+	return prot;
+}
+
+static int make_flags(struct cr_image_vma *i)
+{
+	unsigned long flags = MAP_FIXED;
+
+	flags |= MAP_PRIVATE;
+	if (i->cr_pos_vm_file != CR_POS_UNDEF)
+		flags |= MAP_ANONYMOUS;
+
+	if (i->cr_vm_flags & VM_GROWSDOWN)
+		flags |= MAP_GROWSDOWN;
+#ifdef MAP_GROWSUP
+	if (i->cr_vm_flags & VM_GROWSUP)
+		flags |= MAP_GROWSUP;
+#endif
+	if (i->cr_vm_flags & VM_EXECUTABLE)
+		flags |= MAP_EXECUTABLE;
+	if (i->cr_vm_flags & VM_DENYWRITE)
+		flags |= MAP_DENYWRITE;
+	return flags;
+}
+
+static int cr_restore_vma(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_vma *i;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	struct file *file;
+	unsigned long addr, prot, flags;
+	struct cr_object *tmp;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_VMA) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	if (i->cr_pos_vm_file != CR_POS_UNDEF) {
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_vm_file, CR_CTX_FILE);
+		if (!tmp) {
+			rv = cr_restore_file(ctx, i->cr_pos_vm_file);
+			if (rv < 0)
+				return rv;
+			tmp = cr_find_obj_by_pos(ctx, i->cr_pos_vm_file, CR_CTX_FILE);
+		}
+		file = tmp->o_obj;
+	} else
+		file = NULL;
+
+	prot = make_prot(i);
+	flags = make_flags(i);
+	addr = do_mmap_pgoff(file, i->cr_vm_start, i->cr_vm_end - i->cr_vm_start, prot, flags, i->cr_vm_pgoff);
+	if (addr != i->cr_vm_start) {
+//		printk("%s: addr = 0x%08lx\n", __func__, addr);
+		kfree(i);
+		return -EINVAL;
+	}
+	vma = find_vma(mm, addr);
+	if (!vma) {
+		kfree(i);
+		return -EINVAL;
+	}
+	if (vma->vm_start != i->cr_vm_start || vma->vm_end != i->cr_vm_end) {
+		printk("%s: vma %08lx-%08lx should be %08lx-%08lx\n", __func__, vma->vm_start, vma->vm_end, (unsigned long)i->cr_vm_start, (unsigned long)i->cr_vm_end);
+		kfree(i);
+		return -EINVAL;
+	}
+	printk("restore vma: %08lx-%08lx, vm_flags 0x%08lx, pgprot 0x%llx, vm_pgoff 0x%lx, pos_vm_file %lld\n", vma->vm_start, vma->vm_end, vma->vm_flags, (unsigned long long)pgprot_val(vma->vm_page_prot), vma->vm_pgoff, (long long)i->cr_pos_vm_file);
+	if (vma->vm_flags != i->cr_vm_flags)
+		printk("restore vma: ->vm_flags = 0x%08lx, ->cr_vm_flags = 0x%08lx\n", vma->vm_flags, (unsigned long)i->cr_vm_flags);
+	if (pgprot_val(vma->vm_page_prot) != i->cr_vm_page_prot)
+		printk("restore vma: ->prot = 0x%llx, ->cr_vm_flags = 0x%llx\n", (unsigned long long)pgprot_val(vma->vm_page_prot), (unsigned long long)i->cr_vm_page_prot);
+	kfree(i);
+	return cr_restore_vma_content(ctx, pos + sizeof(*i));
+}
+
+static int cr_restore_all_vma(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_object_header cr_hdr;
+	int rv;
+
+	while (1) {
+		rv = cr_pread(ctx, &cr_hdr, sizeof(cr_hdr), pos);
+		if (rv < 0)
+			return rv;
+		switch (cr_hdr.cr_type) {
+		case CR_OBJ_VMA:
+			rv = cr_restore_vma(ctx, pos);
+			if (rv < 0)
+				return rv;
+			break;
+		case CR_OBJ_VMA_CONTENT:
+			break;
+		default:
+			return 0;
+		}
+		pos += cr_hdr.cr_len;
+	}
+	return 0;
+}
+
+static int cr_check_mm_struct(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	int rv;
+
+	rv = cr_arch_check_mm_struct(mm);
+	if (rv < 0)
+		return rv;
+	down_read(&mm->mmap_sem);
+	if (mm->core_state) {
+		up_read(&mm->mmap_sem);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	up_read(&mm->mmap_sem);
+#ifdef CONFIG_AIO
+	spin_lock(&mm->ioctx_lock);
+	if (!hlist_empty(&mm->ioctx_list)) {
+		spin_unlock(&mm->ioctx_lock);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	spin_unlock(&mm->ioctx_lock);
+#endif
+#ifdef CONFIG_MMU_NOTIFIER
+	down_read(&mm->mmap_sem);
+	if (mm_has_notifiers(mm)) {
+		up_read(&mm->mmap_sem);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	up_read(&mm->mmap_sem);
+#endif
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		rv = cr_check_vma(vma);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int cr_collect_mm_struct(struct cr_context *ctx, struct mm_struct *mm)
+{
+	int rv;
+
+	rv = cr_check_mm_struct(mm);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, mm, CR_CTX_MM_STRUCT);
+	printk("collect mm_struct %p: rv %d\n", mm, rv);
+	return rv;
+}
+
+int cr_collect_all_mm_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_collect_mm_struct(ctx, tsk->mm);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
+		struct mm_struct *mm = obj->o_obj;
+		unsigned int cnt = atomic_read(&mm->mm_users);
+
+		if (obj->o_count != cnt) {
+			printk("%s: mm_struct %p has external references %lu:%u\n", __func__, mm, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_mm_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct mm_struct *mm = obj->o_obj;
+	struct cr_image_mm_struct *i;
+	struct vm_area_struct *vma;
+	int rv;
+
+	i = cr_prepare_image(CR_OBJ_MM_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_def_flags = mm->def_flags;
+	i->cr_start_code = mm->start_code;
+	i->cr_end_code = mm->end_code;
+	i->cr_start_data = mm->start_data;
+	i->cr_end_data = mm->end_data;
+	i->cr_start_brk = mm->start_brk;
+	i->cr_brk = mm->brk;
+	i->cr_start_stack = mm->start_stack;
+	i->cr_arg_start = mm->arg_start;
+	i->cr_arg_end = mm->arg_end;
+	i->cr_env_start = mm->env_start;
+	i->cr_env_end = mm->env_end;
+	BUILD_BUG_ON(sizeof(mm->saved_auxv) > sizeof(i->cr_saved_auxv));
+	memcpy(i->cr_saved_auxv, mm->saved_auxv, sizeof(mm->saved_auxv));
+	i->cr_flags = mm->flags;
+
+	i->cr_len_arch = cr_arch_len_mm_struct(mm);
+	i->cr_hdr.cr_len += i->cr_len_arch;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+	printk("dump mm_struct %p, pos %lld\n", mm, (long long)obj->o_pos);
+
+	rv = cr_arch_dump_mm_struct(ctx, mm);
+	if (rv < 0)
+		return rv;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		rv = cr_dump_vma(ctx, vma);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int cr_dump_all_mm_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
+		rv = cr_dump_mm_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int __cr_restore_mm_struct(struct cr_context *ctx, loff_t pos, unsigned int *len)
+{
+	struct cr_image_mm_struct *i;
+	struct mm_struct *mm;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_MM_STRUCT) {
+		kfree(i);
+		return -EINVAL;
+	}
+
+	mm = mm_alloc();
+	if (!mm) {
+		kfree(i);
+		return -ENOMEM;
+	}
+	rv = init_new_context(current, mm);
+	if (rv < 0) {
+		mmdrop(mm);
+		kfree(i);
+		return rv;
+	}
+
+	mm->get_unmapped_area = arch_get_unmapped_area_topdown;
+	mm->unmap_area = arch_unmap_area_topdown;
+
+	mm->def_flags = i->cr_def_flags;
+	mm->start_code = i->cr_start_code;
+	mm->end_code = i->cr_end_code;
+	mm->start_data = i->cr_start_data;
+	mm->end_data = i->cr_end_data;
+	mm->start_brk = i->cr_start_brk;
+	mm->brk = i->cr_brk;
+	mm->start_stack = i->cr_start_stack;
+	mm->arg_start = i->cr_arg_start;
+	mm->arg_end = i->cr_arg_end;
+	mm->env_start = i->cr_env_start;
+	mm->env_end = i->cr_env_end;
+	memcpy(mm->saved_auxv, i->cr_saved_auxv, sizeof(mm->saved_auxv));
+	mm->flags = i->cr_flags;
+
+	*len = i->cr_hdr.cr_len;
+	kfree(i);
+
+	obj = cr_object_create(mm);
+	if (!obj) {
+		mmdrop(mm);
+		return -ENOMEM;
+	}
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_MM_STRUCT]);
+	printk("restore mm_struct %p, pos %lld\n", mm, (long long)pos);
+	return 0;
+}
+
+int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct task_struct *tsk = current;
+	struct mm_struct *mm, *prev_mm;
+	unsigned int len;
+	struct cr_object *tmp;
+	int rv;
+
+	tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_MM_STRUCT);
+	if (tmp) {
+		/* FIXME: LDT */
+		return 0;
+	}
+	rv = __cr_restore_mm_struct(ctx, pos, &len);
+	if (rv < 0)
+		return rv;
+	tmp = cr_find_obj_by_pos(ctx, pos, CR_CTX_MM_STRUCT);
+	mm = tmp->o_obj;
+
+	atomic_inc(&mm->mm_users);
+	task_lock(tsk);
+	prev_mm = tsk->active_mm;
+	tsk->mm = tsk->active_mm = mm;
+	activate_mm(prev_mm, mm);
+	tsk->flags &= ~PF_KTHREAD;
+	task_unlock(tsk);
+
+	return cr_restore_all_vma(ctx, pos + len);
+}
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr-task.c
@@ -0,0 +1,252 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/kthread.h>
+#include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
+#include <linux/sched.h>
+#include <linux/tty.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_task_struct(struct task_struct *tsk)
+{
+	int rv;
+
+	rv = cr_arch_check_task_struct(tsk);
+	if (rv < 0)
+		return rv;
+	if (tsk->exit_state) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (!tsk->mm || !tsk->active_mm || tsk->mm != tsk->active_mm) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#ifdef CONFIG_MM_OWNER
+	if (tsk->mm && tsk->mm->owner != tsk) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+#endif
+	if (!tsk->nsproxy) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (!tsk->sighand) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (!tsk->signal) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int cr_collect_task_struct(struct cr_context *ctx, struct task_struct *tsk)
+{
+	int rv;
+
+	/* task_struct is never shared. */
+	BUG_ON(cr_find_obj_by_ptr(ctx, tsk, CR_CTX_TASK_STRUCT));
+
+	rv = cr_check_task_struct(tsk);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_object(ctx, tsk, CR_CTX_TASK_STRUCT);
+	printk("collect task_struct %p: '%s' rv %d\n", tsk, tsk->comm, rv);
+	return rv;
+}
+
+int cr_collect_all_task_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	/* Seed task list. */
+	rv = cr_collect_task_struct(ctx, ctx->cr_init_tsk);
+	if (rv < 0)
+		return rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj, *child;
+
+		if (thread_group_leader(tsk)) {
+			struct task_struct *thread = tsk;
+
+			while ((thread = next_thread(thread)) != tsk) {
+				rv = cr_collect_task_struct(ctx, thread);
+				if (rv < 0)
+					return rv;
+			}
+		}
+		list_for_each_entry(child, &tsk->children, sibling) {
+			rv = cr_collect_task_struct(ctx, child);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	return 0;
+}
+
+static int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct task_struct *tsk = obj->o_obj;
+	struct cr_image_task_struct *i;
+	struct cr_object *tmp;
+	int rv;
+
+	i = cr_prepare_image(CR_OBJ_TASK_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, tsk->real_parent, CR_CTX_TASK_STRUCT);
+	if (tmp)
+		i->cr_pos_real_parent = tmp->o_pos;
+	else
+		i->cr_pos_real_parent = CR_POS_UNDEF;
+
+	tmp = cr_find_obj_by_ptr(ctx, tsk->mm, CR_CTX_MM_STRUCT);
+	i->cr_pos_mm = tmp->o_pos;
+
+	BUILD_BUG_ON(TASK_COMM_LEN != 16);
+	strlcpy((char *)i->cr_comm, (const char *)tsk->comm, sizeof(i->cr_comm));
+
+	i->cr_tsk_arch = cr_task_struct_arch(tsk);
+	i->cr_len_arch = cr_arch_len_task_struct(tsk);
+	i->cr_hdr.cr_len += i->cr_len_arch;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	rv = cr_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+	printk("dump task_struct %p/%s, pos %lld\n", tsk, tsk->comm, (long long)obj->o_pos);
+
+	return cr_arch_dump_task_struct(ctx, tsk);
+}
+
+int cr_dump_all_task_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		rv = cr_dump_task_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+struct cr_context_task_struct {
+	struct cr_context *ctx;
+	struct cr_image_task_struct *i;
+	struct completion c;
+};
+
+/*
+ * Restore is done in current context. Put unneeded pieces and read/create or
+ * get already created ones. Registers are restored in context of a task which
+ * did restart(2).
+ */
+static int task_struct_restorer(void *_tsk_ctx)
+{
+	struct cr_context_task_struct *tsk_ctx = _tsk_ctx;
+	struct cr_image_task_struct *i = tsk_ctx->i;
+	struct cr_context *ctx = tsk_ctx->ctx;
+	/* In the name of symmetry. */
+	struct task_struct *tsk = current;
+	int rv;
+
+	printk("%s: ENTER tsk = %p/%s\n", __func__, tsk, tsk->comm);
+
+	rv = cr_restore_mm_struct(ctx, i->cr_pos_mm);
+	if (rv < 0)
+		goto out;
+
+out:
+	printk("%s: schedule rv %d\n", __func__, rv);
+	complete(&tsk_ctx->c);
+	__set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	return rv;
+}
+
+int cr_restore_task_struct(struct cr_context *ctx, loff_t pos)
+{
+	struct cr_image_task_struct *i, *tmpi;
+	struct cr_context_task_struct tsk_ctx;
+	struct task_struct *tsk, *real_parent;
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
+	if (i->cr_hdr.cr_type != CR_OBJ_TASK_STRUCT) {
+		kfree(i);
+		return -EINVAL;
+	}
+	tmpi = i;
+	i = krealloc(i, sizeof(*i) + i->cr_len_arch, GFP_KERNEL);
+	if (!i) {
+		kfree(tmpi);
+		return -ENOMEM;
+	}
+	rv = cr_pread(ctx, i + 1, i->cr_len_arch, pos + sizeof(*i));
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+
+	rv = cr_arch_check_image_task_struct(i);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+
+	tsk_ctx.ctx = ctx;
+	tsk_ctx.i = i;
+	init_completion(&tsk_ctx.c);
+	/* Restore ->comm for free. */
+	tsk = kthread_run(task_struct_restorer, &tsk_ctx, "%s", i->cr_comm);
+	wait_for_completion(&tsk_ctx.c);
+	wait_task_inactive(tsk, 0);
+
+	rv = cr_arch_restore_task_struct(tsk, i);
+	if (rv < 0) {
+		kfree(i);
+		return rv;
+	}
+
+	write_lock_irq(&tasklist_lock);
+	if (i->cr_pos_real_parent == CR_POS_UNDEF) {
+		real_parent = ctx->cr_init_tsk->nsproxy->pid_ns->child_reaper;
+	} else {
+		tmp = cr_find_obj_by_pos(ctx, i->cr_pos_real_parent, CR_CTX_TASK_STRUCT);
+		real_parent = tmp->o_obj;
+	}
+	tsk->real_parent = tsk->parent = real_parent;
+	list_move_tail(&tsk->sibling, &tsk->real_parent->sibling);
+	write_unlock_irq(&tasklist_lock);
+	kfree(i);
+
+#ifdef CONFIG_PREEMPT
+	task_thread_info(tsk)->preempt_count--;
+#endif
+
+	obj = cr_object_create(tsk);
+	if (!obj)
+		return -ENOMEM;
+	obj->o_pos = pos;
+	list_add(&obj->o_list, &ctx->cr_obj[CR_CTX_TASK_STRUCT]);
+	return 0;
+}
new file mode 100644
--- /dev/null
+++ b/kernel/cr/cr.h
@@ -0,0 +1,158 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#ifndef __KERNEL_CR_CR_H
+#define __KERNEL_CR_CR_H
+#include <linux/list.h>
+#include <linux/slab.h>
+
+#include <linux/cr.h>
+
+struct cr_image_task_struct;
+struct mm_struct;
+
+struct cr_object {
+	/* entry in ->cr_* lists */
+	struct list_head	o_list;
+	/* number of references from collected objects */
+	unsigned long		o_count;
+	/* position in dumpfile, or CR_POS_UNDEF if not yet dumped */
+	loff_t			o_pos;
+	/* pointer to object being collected/dumped */
+	void			*o_obj;
+};
+
+/* Not visible to userspace! */
+enum cr_context_obj_type {
+	CR_CTX_FILE,
+	CR_CTX_MM_STRUCT,
+	CR_CTX_TASK_STRUCT,
+	NR_CR_CTX_TYPES
+};
+
+struct cr_context {
+	struct task_struct	*cr_init_tsk;
+	struct file		*cr_dump_file;
+	struct list_head	cr_obj[NR_CR_CTX_TYPES];
+};
+
+#define for_each_cr_object(ctx, obj, type)				\
+	list_for_each_entry(obj, &ctx->cr_obj[type], o_list)
+#define for_each_cr_object_safe(ctx, obj, tmp, type)			\
+	list_for_each_entry_safe(obj, tmp, &ctx->cr_obj[type], o_list)
+struct cr_object *cr_find_obj_by_ptr(struct cr_context *ctx, const void *ptr, enum cr_context_obj_type type);
+struct cr_object *cr_find_obj_by_pos(struct cr_context *ctx, loff_t pos, enum cr_context_obj_type type);
+
+struct cr_object *cr_object_create(void *data);
+int cr_collect_object(struct cr_context *ctx, void *p, enum cr_context_obj_type type);
+static inline void cr_object_destroy(struct cr_object *obj)
+{
+	kfree(obj);
+}
+
+struct cr_context *cr_context_create(struct task_struct *tsk, struct file *file);
+void cr_context_destroy(struct cr_context *ctx);
+
+int cr_pread(struct cr_context *ctx, void *buf, size_t count, loff_t pos);
+int cr_write(struct cr_context *ctx, const void *buf, size_t count);
+
+void *cr_prepare_image(unsigned int type, size_t len);
+
+static inline __u64 cr_dump_ptr(const void __user *ptr)
+{
+	return (unsigned long)ptr;
+}
+
+static inline void __user *cr_restore_ptr(__u64 ptr)
+{
+	return (void __user *)(unsigned long)ptr;
+}
+
+int cr_collect_all_file(struct cr_context *ctx);
+int cr_collect_all_mm_struct(struct cr_context *ctx);
+int cr_collect_all_task_struct(struct cr_context *ctx);
+
+int cr_dump_all_file(struct cr_context *ctx);
+int cr_dump_all_mm_struct(struct cr_context *ctx);
+int cr_dump_all_task_struct(struct cr_context *ctx);
+
+int cr_restore_file(struct cr_context *ctx, loff_t pos);
+int cr_restore_mm_struct(struct cr_context *ctx, loff_t pos);
+int cr_restore_task_struct(struct cr_context *ctx, loff_t pos);
+
+#if 0
+__u32 cr_image_header_arch(void);
+int cr_arch_check_image_header(struct cr_image_header *i);
+
+__u32 cr_task_struct_arch(struct task_struct *tsk);
+int cr_arch_check_image_task_struct(struct cr_image_task_struct *i);
+
+unsigned int cr_arch_len_task_struct(struct task_struct *tsk);
+int cr_arch_check_task_struct(struct task_struct *tsk);
+int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk);
+int cr_arch_restore_task_struct(struct task_struct *tsk, struct cr_image_task_struct *i);
+
+unsigned int cr_arch_len_mm_struct(struct mm_struct *mm);
+int cr_arch_check_mm_struct(struct mm_struct *mm);
+int cr_arch_dump_mm_struct(struct cr_context *ctx, struct mm_struct *mm);
+int cr_arch_restore_mm_struct(struct cr_context *ctx, loff_t pos, __u32 len, struct mm_struct *mm);
+#else
+static inline __u32 cr_image_header_arch(void)
+{
+	return 0;
+}
+
+static inline int cr_arch_check_image_header(struct cr_image_header *i)
+{
+	return -ENOSYS;
+}
+
+static inline __u32 cr_task_struct_arch(struct task_struct *tsk)
+{
+	return 0;
+}
+
+static inline int cr_arch_check_image_task_struct(struct cr_image_task_struct *i)
+{
+	return -ENOSYS;
+}
+
+static inline unsigned int cr_arch_len_task_struct(struct task_struct *tsk)
+{
+	return 0;
+}
+
+static inline int cr_arch_check_task_struct(struct task_struct *tsk)
+{
+	return -ENOSYS;
+}
+
+static inline int cr_arch_dump_task_struct(struct cr_context *ctx, struct task_struct *tsk)
+{
+	return -ENOSYS;
+}
+
+static inline int cr_arch_restore_task_struct(struct task_struct *tsk, struct cr_image_task_struct *i)
+{
+	return -ENOSYS;
+}
+
+static inline unsigned int cr_arch_len_mm_struct(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline int cr_arch_check_mm_struct(struct mm_struct *mm)
+{
+	return -ENOSYS;
+}
+
+static inline int cr_arch_dump_mm_struct(struct cr_context *ctx, struct mm_struct *mm)
+{
+	return -ENOSYS;
+}
+
+static inline int cr_arch_restore_mm_struct(struct cr_context *ctx, loff_t pos, __u32 len, struct mm_struct *mm)
+{
+	return -ENOSYS;
+}
+#endif
+#endif
new file mode 100644
--- /dev/null
+++ b/kernel/cr/rst-sys.c
@@ -0,0 +1,87 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+/* restart(2) */
+#include <linux/capability.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+
+#include <linux/cr.h>
+#include "cr.h"
+
+static int cr_check_image_header(struct cr_context *ctx)
+{
+	struct cr_image_header i;
+	int rv;
+
+	rv = cr_pread(ctx, &i, sizeof(i), 0);
+	if (rv < 0)
+		return rv;
+	printk("%s: image version %u, arch %u\n", __func__, i.cr_image_version, i.cr_arch);
+	if (memcmp(i.cr_image_magic, CR_IMAGE_MAGIC, 8) != 0)
+		return -EINVAL;
+	if (i.cr_image_version != cpu_to_le32(CR_IMAGE_VERSION))
+		return -EINVAL;
+	return cr_arch_check_image_header(&i);
+}
+
+static int cr_restart(struct cr_context *ctx)
+{
+	struct cr_object_header i;
+	loff_t pos;
+	struct cr_object *obj;
+	int rv;
+
+	rv = cr_check_image_header(ctx);
+	if (rv < 0)
+		return rv;
+	pos = sizeof(struct cr_image_header);
+	do {
+		rv = cr_pread(ctx, &i, sizeof(i), pos);
+		if (rv < 0)
+			return rv;
+		if (i.cr_type == CR_OBJ_TERMINATOR && i.cr_len == sizeof(i))
+			break;
+
+		if (i.cr_type == CR_OBJ_TASK_STRUCT) {
+			rv = cr_restore_task_struct(ctx, pos);
+			if (rv < 0)
+				return rv;
+		}
+		pos += i.cr_len;
+	} while (rv == 0);
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		printk("%s: wake up tsk %p/%s\n", __func__, tsk, tsk->comm);
+		wake_up_process(tsk);
+	}
+
+	return 0;
+}
+
+SYSCALL_DEFINE2(restart, int, fd, int, flags)
+{
+	struct cr_context *ctx;
+	struct file *file;
+	int rv;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	file = fget(fd);
+	if (!file)
+		return -EBADF;
+	ctx = cr_context_create(current, file);
+	if (!ctx) {
+		rv = -ENOMEM;
+		goto out_ctx_create;
+	}
+
+	rv = cr_restart(ctx);
+
+	cr_context_destroy(ctx);
+out_ctx_create:
+	fput(file);
+	return rv;
+}
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -175,3 +175,6 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1626,6 +1626,9 @@ EXPORT_SYMBOL(filemap_fault);
 
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_CR
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */
