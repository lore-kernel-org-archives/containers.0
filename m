From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 18/38] C/R: core stuff
Date: Fri, 22 May 2009 08:55:12 +0400
Message-ID: <1242968132-1044-18-git-send-email-adobriyan__3848.51296335018$1242970671$gmane$org@gmail.com>
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

Introduction
------------
Checkpoint/restart (C/R from now) allows to dump group of processes to disk
for various reasons like saving process state in case of box failure or
restoration of group of processes on another or same machine later.

Unlike, let's say, hypervisor C/R style which only needs to freeze guest kernel
and dump more or less raw pages, proposed C/R doesn't require hypervisor.
For that C/R code needs to know about all little and big intimate kernel details.

The good thing is that not all details needs to be serialized and saved
like, say, readahead state. The bad things is still quite a few things
need to be.

How C/R works
-------------
User passes to system call pid of process which is the root of process hierarchy
to be saved. Hierarchy is formed wrt ->real_parent.

Processes which belong to this hierarchy are frozen.

C/R code walks in-kernel datastructures starting from task_structs and collects
references to them in one place for a dump. This includes at least mm_struct,
nsproxy and it's belongings, opened files, CPU registers, etc. More or less
anything which is userspace-visible must be dumped on one form or another.

Collected data structures are checked for sanity wrt several things:
- still unsupported features (hugetlb mappings) in which case
  checkpointing is aborted
- structure "leaks" to outside of selected group of processes.

  This is done by maintaining mirror refcount from structures collected and
  comparing it with real refcount. If discrepancy is noticed, structure is
  used by someone else who is not frozen and thus we're trying to checkpoint
  live data structure. Depending on what data structure is dumping live data
  structure can be pretty easy (uts_namespace requires only uts_sem)
  to pretty hard (net_namespace sockets requires... actually nobody knows
  what net_namespace will require).

  Note! There re multiple levels of correct operation implied:
	- kernel shouldn't oops by dumping live data structure
	- kernel shouldn't write inconsistent state by dumping live data structure

If all checks for all data structures are OK, C/R code walks
collected references in certain order and does actual serializing and
writes image to passed file descriptor.

This results in a file which is believed to contain enough information
to restore group of process to exactly same user-visible state as before
checkpointing module inevitable issues like time.

Image format design
-------------------
Image consists of image header, object images one after another and
terminator which is formally an object.

Image header consists of magic ("LinuxC/R") and image version (__le32).
This is immutable part of an image. The rest is defined strictly by image
version even the rest of image header.

	Nobody is making guarantees that image format is immutable!

Once again, image format will change, however it's guaranteed that
magic+version part will remain and image version will be bumped.

So far, image header consists of
a) arch of kernel which dumped image to signalize that you can't restore
   powerpc image on i386 kernel and hint code in case of restoring i386
   image on x86_64 kernel.

b) kernel version as found in utsname.

   This is done for distributions who eventually may want to support C/R.
   While the expected way to maintain migrating from older kernels is
   to write userspace converter which knows everything about two image
   formats, distro kernels may want to maintain all backward-caompat code
   in kernel which can be small or big depending on the amount of changes
   they pull into their kernel.

   Just image version isn't realistically sufficient, distributions are
   expected to leave image version alone and demultiplex backward-compat
   code depending on utsname which is in case of distro kernels is pretty
   well known.

Object image
------------
Object images are direct projection of in-kernel data structures which
can be shared inside kernel to disk :-) Example: struct mm_struct is
dumped to an object of KSTATE_OBJ_MM_STRUCT type, struct cred is dumped
to KSTATE_OBJ_CRED type.

There are so far 3 exceptions: VMA, page content and fd. These are formal
objects with type and length to simplify reading and restoration of VMAs
and file descriptors, respectively. VMA and pages attributed are even
variable-sized.

Any object image starts with object header which is object type,
object lenth including header and globally unique object id (per-image,
of course). Type and length are used in verifying that image is not
malformed and object id is used in references of objects to another objects
and also verifying.

VMA, pages and file descriptors don't get object id, because they aren't
directly collected. But this is fine, as they get invalid object id (0)
which is not checked.

Relations in image
------------------
To serialize reference of object A to object B (task_struct::mm) image of
object a gets a field of kstate_ref_t type:

	struct kstate_image_a {
		struct kstate_object_header hdr;

		kstate_ref_t	ref_b;
	};

which corresponds to a->b pointer.

Reference consists of position in a dumpfile (if it's known by the time B
is dumped and object id of B (which _is_ known).

If there is a loop in pointers A => B => A, position is dumped as 0 and attention
is required at restore time. In each loop case it will be dealt individually.
(so far, there is one loop: user->user_ns->creator)

C/R dump code tries hard to maintaint streamable property of dump process --
if dumpfile is opened with O_APPEND, it should work).


Changes in kernel internals:
- add struct file_operations::checkpoint hook

  Code which operated file knows better what information needs to be saved
  to allow successful restoration. For usual files on on-disk filesystem
  add generic_file_checkpoint().

  Add ext3 opened regular files and directories for start.

  If opened or references file doesn't have ->checkpoint hook, checkpointing
  is aborted -- this is deny-by-default policy.

- add struct vm_operations_struct::checkpoint

  Same as for files. Will be used more by vDSO code.

checkpoint(2), restart(2)
-------------------------
Exact number and semantics of system calls is WIP, it was correctly noticed,
that 'freeze' and 'dump' parts needs to be split apart to allow filesystem
sync after freeze. For now leave 2 syscalls for people to play with.

Splitting freeze/dump implies persistent C/R context state BTW which is not
the case now.

Checkpoint semantics
--------------------
Checkpointing is done on per-container level without "leaks" to outside.
In this kernel can provide promises to dump coherent start and to do it
without major games with data structures locking.

Works to allow reliable checkpoint on live data structures has been started
however it's unclear what the result will be because of even more thing one
has to keep inside head simultaneously.

As a semi-direct consequence checkpkointing is not allowed for ordinary
users. While it's a nice feature to allow it, they formally can't even
create container for themselves (CAP_SYS_ADMIN during nsproxy tweaks).

Regadless, once enabled this will present several security risks:
- anything in image is controlled by untrusted user who will try to check
  how well checking code on restart(2) is written.

  And, yes, nobody is hiding that restart(2) involves honest parsing of
  slightly more complex that string file format inside kernel.

- user who effectively can turn off ASLR randomization, because
  he controls VMA boundaries.

These two directions (checkpointing live and restart(2) for everyone)
aren't explored in this patchset because they are artificially not
independent right now and each one is hard enough for already hard C/R work.

Sorry.

However, code is kept good enough to add each of feature later.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/ext3/dir.c                  |    3 +
 fs/ext3/file.c                 |    3 +
 include/linux/Kbuild           |    1 +
 include/linux/fs.h             |   12 +-
 include/linux/kstate-image.h   |  118 +++++++++
 include/linux/kstate.h         |  144 ++++++++++
 include/linux/mm.h             |    4 +
 include/linux/syscalls.h       |    3 +
 init/Kconfig                   |    2 +
 kernel/Makefile                |    1 +
 kernel/kstate/Kconfig          |    7 +
 kernel/kstate/Makefile         |    8 +
 kernel/kstate/cpt-sys.c        |  196 ++++++++++++++
 kernel/kstate/kstate-context.c |   49 ++++
 kernel/kstate/kstate-file.c    |  204 +++++++++++++++
 kernel/kstate/kstate-image.c   |  116 ++++++++
 kernel/kstate/kstate-mm.c      |  563 ++++++++++++++++++++++++++++++++++++++++
 kernel/kstate/kstate-object.c  |  100 +++++++
 kernel/kstate/kstate-task.c    |  287 ++++++++++++++++++++
 kernel/kstate/rst-sys.c        |   91 +++++++
 kernel/sys_ni.c                |    3 +
 mm/filemap.c                   |    3 +
 22 files changed, 1916 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/kstate-image.h
 create mode 100644 include/linux/kstate.h
 create mode 100644 kernel/kstate/Kconfig
 create mode 100644 kernel/kstate/Makefile
 create mode 100644 kernel/kstate/cpt-sys.c
 create mode 100644 kernel/kstate/kstate-context.c
 create mode 100644 kernel/kstate/kstate-file.c
 create mode 100644 kernel/kstate/kstate-image.c
 create mode 100644 kernel/kstate/kstate-mm.c
 create mode 100644 kernel/kstate/kstate-object.c
 create mode 100644 kernel/kstate/kstate-task.c
 create mode 100644 kernel/kstate/rst-sys.c

diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
index 3d724a9..ee4d4df 100644
--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -48,6 +48,9 @@ const struct file_operations ext3_dir_operations = {
 #endif
 	.fsync		= ext3_sync_file,	/* BKL held */
 	.release	= ext3_release_dir,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 
diff --git a/fs/ext3/file.c b/fs/ext3/file.c
index 5b49704..6cc26f5 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -126,6 +126,9 @@ const struct file_operations ext3_file_operations = {
 	.fsync		= ext3_sync_file,
 	.splice_read	= generic_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= generic_file_checkpoint,
+#endif
 };
 
 const struct inode_operations ext3_file_inode_operations = {
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 3f0eaa3..353a218 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -50,6 +50,7 @@ header-y += coff.h
 header-y += comstats.h
 header-y += const.h
 header-y += cgroupstats.h
+header-y += kstate-image.h
 header-y += cramfs_fs.h
 header-y += cycx_cfm.h
 header-y += dcbnl.h
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3b534e5..e4f33e0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -387,6 +387,7 @@ struct poll_table_struct;
 struct kstatfs;
 struct vm_area_struct;
 struct vfsmount;
+struct kstate_context;
 struct cred;
 
 extern void __init inode_init(void);
@@ -1508,6 +1509,9 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+#ifdef CONFIG_CHECKPOINT
+	int (*checkpoint)(struct file *file, struct kstate_context *ctx);
+#endif
 };
 
 struct inode_operations {
@@ -2079,7 +2083,9 @@ extern int __filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end, int sync_mode);
 extern int filemap_fdatawrite_range(struct address_space *mapping,
 				loff_t start, loff_t end);
-
+#ifdef CONFIG_CHECKPOINT
+int filemap_checkpoint(struct vm_area_struct *vma, struct kstate_context *ctx);
+#endif
 extern int vfs_fsync(struct file *file, struct dentry *dentry, int datasync);
 extern void sync_supers(void);
 extern void sync_filesystems(int wait);
@@ -2201,7 +2207,9 @@ extern ssize_t do_sync_read(struct file *filp, char __user *buf, size_t len, lof
 extern ssize_t do_sync_write(struct file *filp, const char __user *buf, size_t len, loff_t *ppos);
 extern int generic_segment_checks(const struct iovec *iov,
 		unsigned long *nr_segs, size_t *count, int access_flags);
-
+#ifdef CONFIG_CHECKPOINT
+int generic_file_checkpoint(struct file *file, struct kstate_context *ctx);
+#endif
 /* fs/splice.c */
 extern ssize_t generic_file_splice_read(struct file *, loff_t *,
 		struct pipe_inode_info *, size_t, unsigned int);
diff --git a/include/linux/kstate-image.h b/include/linux/kstate-image.h
new file mode 100644
index 0000000..ac3c81d
--- /dev/null
+++ b/include/linux/kstate-image.h
@@ -0,0 +1,118 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#ifndef __INCLUDE_LINUX_KSTATE_IMAGE_H
+#define __INCLUDE_LINUX_KSTATE_IMAGE_H
+#include <linux/compiler.h>
+#include <linux/types.h>
+
+typedef __u64 kstate_pos_t;	/* position of another object in a dumpfile */
+typedef __u32 kstate_id_t;	/* object id */
+struct kstate_ref {
+	kstate_pos_t	pos;
+	kstate_id_t	id;
+} __packed;
+typedef struct kstate_ref kstate_ref_t;
+
+#define KSTATE_REF_UNDEF	((kstate_ref_t){ .pos = 0, .id = 0 })
+static inline int kstate_ref_undefined(kstate_ref_t *ref)
+{
+	return ref->pos == 0 && ref->id == 0;
+}
+
+struct kstate_image_header {
+	/* Immutable part except version bumps. */
+#define KSTATE_IMAGE_MAGIC	"LinuxC/R"
+	__u8	image_magic[8];
+#define KSTATE_IMAGE_VERSION	1
+	__le32	image_version;
+
+	/* Mutable part. */
+	/* Arch of the kernel which dumped the image. */
+	__le32	kernel_arch;
+	/*
+	 * Distributions are expected to leave image version alone and
+	 * demultiplex by this field on restart.
+	 */
+	__u8	uts_release[64];
+} __packed;
+
+#define KSTATE_OBJ_TERMINATOR	0
+#define KSTATE_OBJ_TASK_STRUCT	1
+#define KSTATE_OBJ_MM_STRUCT	2
+#define KSTATE_OBJ_FILE		3
+#define KSTATE_OBJ_VMA		4
+#define KSTATE_OBJ_PAGE		5
+
+struct kstate_object_header {
+	__u32		obj_type;
+	__u32		obj_len;	/* in bytes including this header */
+	kstate_id_t	obj_id;
+} __packed;
+
+/*
+ * 1. struct kstate_object_header MUST start object image.
+ * 2. Every member which refers to position of another object image in
+ *    a dumpfile MUST have kstate_ref_t type and SHOULD additionally use
+ *    'ref_' prefix.
+ * 3. Size and layout of every object type image MUST be the same on all
+ *    architectures.
+ */
+
+struct kstate_image_task_struct {
+	struct kstate_object_header hdr;
+
+	kstate_ref_t	ref_mm;
+
+	__u8		comm[16];
+
+	/* Native arch of task, one of KSTATE_ARCH_*. */
+	__u32		tsk_arch;
+} __packed;
+
+struct kstate_image_mm_struct {
+	struct kstate_object_header hdr;
+
+	__u64		def_flags;
+	__u64		start_code;
+	__u64		end_code;
+	__u64		start_data;
+	__u64		end_data;
+	__u64		start_brk;
+	__u64		brk;
+	__u64		start_stack;
+	__u64		arg_start;
+	__u64		arg_end;
+	__u64		env_start;
+	__u64		env_end;
+	__u64		flags;
+	__u8		saved_auxv[416];
+} __packed;
+
+struct kstate_image_vma {
+	struct kstate_object_header hdr;
+
+	__u64		vm_start;
+	__u64		vm_end;
+	__u64		vm_page_prot;
+	__u64		vm_flags;
+	__u64		vm_pgoff;
+	kstate_ref_t	ref_vm_file;
+} __packed;
+
+struct kstate_image_page {
+	struct kstate_object_header hdr;
+
+	__u64		start_addr;
+	__u32		page_size;
+	/* __u8 data[page_size]; */
+} __packed;
+
+struct kstate_image_file {
+	struct kstate_object_header hdr;
+
+	__u32		i_mode;
+	__u32		f_flags;
+	__u64		f_pos;
+	__u32		name_len;	/* including NUL */
+	/* __u8	name[name_len] */
+} __packed;
+#endif
diff --git a/include/linux/kstate.h b/include/linux/kstate.h
new file mode 100644
index 0000000..3ae9e28
--- /dev/null
+++ b/include/linux/kstate.h
@@ -0,0 +1,144 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#ifndef __INCLUDE_LINUX_KSTATE_H
+#define __INCLUDE_LINUX_KSTATE_H
+#include <linux/list.h>
+
+#include <linux/kstate-image.h>
+
+struct file;
+struct mm_struct;
+struct task_struct;
+
+struct kstate_object {
+	/* entry in struct kstate_context::obj lists */
+	struct list_head	o_list;
+	/* number of references from collected objects */
+	unsigned long		o_count;
+	kstate_ref_t		o_ref;
+	/* pointer to object being collected/dumped */
+	void			*o_obj;
+};
+
+/* Not visible to userspace! */
+enum kstate_context_obj_type {
+	KSTATE_CTX_FILE,
+	KSTATE_CTX_MM_STRUCT,
+	KSTATE_CTX_TASK_STRUCT,
+	NR_KSTATE_CTX_TYPES
+};
+
+struct kstate_context {
+	struct task_struct	*init_tsk;
+	struct file		*dump_file;
+	struct list_head	obj[NR_KSTATE_CTX_TYPES];
+};
+
+#define for_each_kstate_object(ctx, obj, type)				\
+	list_for_each_entry(obj, &ctx->obj[type], o_list)
+#define for_each_kstate_object_safe(ctx, obj, tmp, type)		\
+	list_for_each_entry_safe(obj, tmp, &ctx->obj[type], o_list)
+struct kstate_object *find_kstate_obj_by_ptr(struct kstate_context *ctx, const void *ptr, enum kstate_context_obj_type type);
+struct kstate_object *find_kstate_obj_by_ref(struct kstate_context *ctx, kstate_ref_t *ref, enum kstate_context_obj_type type);
+struct kstate_object *find_kstate_obj_by_id(struct kstate_context *ctx, kstate_ref_t *ref, enum kstate_context_obj_type type);
+
+int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_context_obj_type type);
+int kstate_restore_object(struct kstate_context *ctx, void *p, enum kstate_context_obj_type type, kstate_ref_t *ref);
+
+struct kstate_context *kstate_context_create(struct task_struct *tsk, struct file *file);
+void kstate_context_destroy(struct kstate_context *ctx);
+
+int kstate_pread(struct kstate_context *ctx, void *buf, unsigned int count, kstate_pos_t pos);
+int kstate_write(struct kstate_context *ctx, const void *buf, unsigned int count);
+
+void *kstate_prepare_image(__u32 type, unsigned int len);
+void *kstate_read_image(struct kstate_context *ctx, kstate_ref_t *ref, __u32 type, unsigned int len);
+int kstate_write_image(struct kstate_context *ctx, void *i, unsigned int len, struct kstate_object *obj);
+
+int kstate_collect_all_task_struct(struct kstate_context *ctx);
+int kstate_dump_all_task_struct(struct kstate_context *ctx);
+int kstate_restore_task_struct(struct kstate_context *ctx, kstate_ref_t *ref);
+
+int kstate_collect_all_mm_struct(struct kstate_context *ctx);
+int kstate_dump_all_mm_struct(struct kstate_context *ctx);
+int kstate_restore_mm_struct(struct kstate_context *ctx, kstate_ref_t *ref, unsigned int *len);
+int kstate_restore_vma(struct kstate_context *ctx, kstate_pos_t pos);
+
+int kstate_collect_all_file(struct kstate_context *ctx);
+int kstate_dump_all_file(struct kstate_context *ctx);
+int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref);
+
+#if 0
+extern const __u32 kstate_kernel_arch;
+int kstate_arch_check_image_header(struct kstate_image_header *i);
+
+__u32 kstate_task_struct_arch(struct task_struct *tsk);
+int kstate_arch_check_image_task_struct(struct kstate_image_task_struct *i);
+
+unsigned int kstate_arch_len_task_struct(struct task_struct *tsk);
+int kstate_arch_check_task_struct(struct task_struct *tsk);
+int kstate_arch_dump_task_struct(struct kstate_context *ctx, struct task_struct *tsk, void *arch_i);
+int kstate_arch_restore_task_struct(struct task_struct *tsk, struct kstate_image_task_struct *i);
+
+unsigned int kstate_arch_len_mm_struct(struct mm_struct *mm);
+int kstate_arch_check_mm_struct(struct mm_struct *mm);
+int kstate_arch_dump_mm_struct(struct kstate_context *ctx, struct mm_struct *mm, void *arch_i);
+int kstate_arch_restore_mm_struct(struct kstate_context *ctx, struct kstate_image_mm_struct *i);
+#else
+#define kstate_kernel_arch 0
+
+static inline int kstate_arch_check_image_header(struct kstate_image_header *i)
+{
+	return -ENOSYS;
+}
+
+static inline __u32 kstate_task_struct_arch(struct task_struct *tsk)
+{
+	return 0;
+}
+
+static inline int kstate_arch_check_image_task_struct(struct kstate_image_task_struct *i)
+{
+	return -ENOSYS;
+}
+
+static inline unsigned int kstate_arch_len_task_struct(struct task_struct *tsk)
+{
+	return 0;
+}
+
+static inline int kstate_arch_check_task_struct(struct task_struct *tsk)
+{
+	return -ENOSYS;
+}
+
+static inline int kstate_arch_dump_task_struct(struct kstate_context *ctx, struct task_struct *tsk, void *arch_i)
+{
+	return -ENOSYS;
+}
+
+static inline int kstate_arch_restore_task_struct(struct task_struct *tsk, struct kstate_image_task_struct *i)
+{
+	return -ENOSYS;
+}
+
+static inline unsigned int kstate_arch_len_mm_struct(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline int kstate_arch_check_mm_struct(struct mm_struct *mm)
+{
+	return -ENOSYS;
+}
+
+static inline int kstate_arch_dump_mm_struct(struct kstate_context *ctx, struct mm_struct *mm, void *arch_i)
+{
+	return -ENOSYS;
+}
+
+static inline int kstate_arch_restore_mm_struct(struct kstate_context *ctx, struct kstate_image_mm_struct *i)
+{
+	return -ENOSYS;
+}
+#endif
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b3b61a6..96c206b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -16,6 +16,7 @@
 
 struct mempolicy;
 struct anon_vma;
+struct kstate_context;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
@@ -220,6 +221,9 @@ struct vm_operations_struct {
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
+#ifdef CONFIG_CHECKPOINT
+	int (*checkpoint)(struct vm_area_struct *vma, struct kstate_context *ctx);
+#endif
 };
 
 struct mmu_gather;
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3052084..eddd210 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -753,6 +753,9 @@ asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 asmlinkage long sys_pipe2(int __user *, int);
 asmlinkage long sys_pipe(int __user *);
 
+asmlinkage long sys_checkpoint(pid_t pid, int fd, int flags);
+asmlinkage long sys_restart(int fd, int flags);
+
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index 7be4d38..bc3b7cb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -608,6 +608,8 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
 endif # CGROUPS
 
+source "kernel/kstate/Kconfig"
+
 config MM_OWNER
 	bool
 
diff --git a/kernel/Makefile b/kernel/Makefile
index 705ad3d..9e0d9e9 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -56,6 +56,7 @@ obj-$(CONFIG_FREEZER) += power/
 obj-$(CONFIG_BSD_PROCESS_ACCT) += acct.o
 obj-$(CONFIG_KEXEC) += kexec.o
 obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
+obj-$(CONFIG_CHECKPOINT) += kstate/
 obj-$(CONFIG_COMPAT) += compat.o
 obj-$(CONFIG_CGROUPS) += cgroup.o
 obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
diff --git a/kernel/kstate/Kconfig b/kernel/kstate/Kconfig
new file mode 100644
index 0000000..6155043
--- /dev/null
+++ b/kernel/kstate/Kconfig
@@ -0,0 +1,7 @@
+config CHECKPOINT
+	bool "Container checkpoint/restart"
+	select FREEZER
+	help
+	  Container checkpoint/restart.
+
+	  Say N.
diff --git a/kernel/kstate/Makefile b/kernel/kstate/Makefile
new file mode 100644
index 0000000..eacd3cf
--- /dev/null
+++ b/kernel/kstate/Makefile
@@ -0,0 +1,8 @@
+obj-$(CONFIG_CHECKPOINT) += kstate.o
+kstate-y := cpt-sys.o rst-sys.o
+kstate-y += kstate-context.o
+kstate-y += kstate-file.o
+kstate-y += kstate-image.o
+kstate-y += kstate-mm.o
+kstate-y += kstate-object.o
+kstate-y += kstate-task.o
diff --git a/kernel/kstate/cpt-sys.c b/kernel/kstate/cpt-sys.c
new file mode 100644
index 0000000..6bc1d0a
--- /dev/null
+++ b/kernel/kstate/cpt-sys.c
@@ -0,0 +1,196 @@
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
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
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
+static int freeze_tasks(struct task_struct *init_tsk)
+{
+	struct task_struct *tmp, *tsk;
+
+	read_lock(&tasklist_lock);
+	do_each_thread(tmp, tsk) {
+		if (child_of(init_tsk, tsk)) {
+			if (!freeze_task(tsk, 1)) {
+				pr_err("%s: freezing '%s' failed\n", __func__, tsk->comm);
+				read_unlock(&tasklist_lock);
+				return -EBUSY;
+			}
+		}
+	} while_each_thread(tmp, tsk);
+	read_unlock(&tasklist_lock);
+	return 0;
+}
+
+static void thaw_tasks(struct task_struct *init_tsk)
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
+static int kstate_collect(struct kstate_context *ctx)
+{
+	int rv;
+
+	rv = kstate_collect_all_task_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_all_mm_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_all_file(ctx);
+	if (rv < 0)
+		return rv;
+	return 0;
+}
+
+static void kstate_assign_object_ids(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	kstate_id_t id;
+	int type;
+
+	/* 0 means 'undefined'. */
+	id = 1;
+	for (type = 0; type < NR_KSTATE_CTX_TYPES; type++) {
+		for_each_kstate_object(ctx, obj, type) {
+			obj->o_ref.id = id;
+			id++;
+		}
+	}
+}
+
+static int kstate_dump_image_header(struct kstate_context *ctx)
+{
+	struct kstate_image_header hdr;
+
+	memset(&hdr, 0, sizeof(hdr));
+
+	memcpy(hdr.image_magic, KSTATE_IMAGE_MAGIC, 8);
+	hdr.image_version = cpu_to_le32(KSTATE_IMAGE_VERSION);
+	hdr.kernel_arch = cpu_to_le32(kstate_kernel_arch);
+	strlcpy((char *)&hdr.uts_release, (const char *)init_uts_ns.name.release, sizeof(hdr.uts_release));
+	return kstate_write(ctx, &hdr, sizeof(hdr));
+}
+
+static int kstate_dump_terminator(struct kstate_context *ctx)
+{
+	struct kstate_object_header hdr;
+
+	memset(&hdr, 0, sizeof(hdr));
+
+	hdr.obj_type = KSTATE_OBJ_TERMINATOR;
+	hdr.obj_len = sizeof(hdr);
+	return kstate_write(ctx, &hdr, sizeof(hdr));
+}
+
+static int kstate_dump(struct kstate_context *ctx)
+{
+	int rv;
+
+	rv = kstate_dump_image_header(ctx);
+	if (rv < 0)
+		return rv;
+	rv = kstate_dump_all_file(ctx);
+	if (rv < 0)
+		return rv;
+	rv = kstate_dump_all_mm_struct(ctx);
+	if (rv < 0)
+		return rv;
+	rv = kstate_dump_all_task_struct(ctx);
+	if (rv < 0)
+		return rv;
+	return kstate_dump_terminator(ctx);
+}
+
+SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, int, flags)
+{
+	struct kstate_context *ctx;
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
+	ctx = kstate_context_create(init_tsk, file);
+	if (!ctx) {
+		rv = -ENOMEM;
+		goto out_ctx_create;
+	}
+
+	rv = freeze_tasks(init_tsk);
+	if (rv < 0)
+		goto out_freeze;
+	rv = kstate_collect(ctx);
+	if (rv < 0)
+		goto out_collect;
+	kstate_assign_object_ids(ctx);
+	rv = kstate_dump(ctx);
+
+out_collect:
+	/* FIXME: kill_tasks() */
+	thaw_tasks(init_tsk);
+out_freeze:
+	kstate_context_destroy(ctx);
+out_ctx_create:
+	put_task_struct(init_tsk);
+out_no_init_tsk:
+	fput(file);
+	return rv;
+}
diff --git a/kernel/kstate/kstate-context.c b/kernel/kstate/kstate-context.c
new file mode 100644
index 0000000..85d1514
--- /dev/null
+++ b/kernel/kstate/kstate-context.c
@@ -0,0 +1,49 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/file.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+
+#include <linux/kstate.h>
+
+/*
+ * During checkpoint ->init_tsk is root of process hierarchy.
+ * During restart ->init_tsk is task which does restart(2).
+ */
+struct kstate_context *kstate_context_create(struct task_struct *tsk, struct file *file)
+{
+	struct kstate_context *ctx;
+
+	ctx = kmalloc(sizeof(struct kstate_context), GFP_KERNEL);
+	if (ctx) {
+		int type;
+
+		ctx->init_tsk = tsk;
+		ctx->dump_file = file;
+		for (type = 0; type < NR_KSTATE_CTX_TYPES; type++)
+			INIT_LIST_HEAD(&ctx->obj[type]);
+	}
+	return ctx;
+}
+
+void kstate_context_destroy(struct kstate_context *ctx)
+{
+	struct kstate_object *obj, *tmp;
+
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_FILE) {
+		fput((struct file *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_MM_STRUCT) {
+		mmput((struct mm_struct *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
+	for_each_kstate_object_safe(ctx, obj, tmp, KSTATE_CTX_TASK_STRUCT) {
+		put_task_struct((struct task_struct *)obj->o_obj);
+		list_del(&obj->o_list);
+		kfree(obj);
+	}
+	kfree(ctx);
+}
diff --git a/kernel/kstate/kstate-file.c b/kernel/kstate/kstate-file.c
new file mode 100644
index 0000000..8f678cd
--- /dev/null
+++ b/kernel/kstate/kstate-file.c
@@ -0,0 +1,204 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fdtable.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/stat.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_file(struct file *file)
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
+static int collect_file(struct kstate_context *ctx, struct file *file)
+{
+	int rv;
+
+	rv = check_file(file);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, file, KSTATE_CTX_FILE);
+	pr_debug("collect file %p: rv %d\n", file, rv);
+	return rv;
+}
+
+int kstate_collect_all_file(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_MM_STRUCT) {
+		struct mm_struct *mm = obj->o_obj;
+		struct vm_area_struct *vma;
+
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			if (vma->vm_file) {
+				rv = collect_file(ctx, vma->vm_file);
+				if (rv < 0)
+					return rv;
+			}
+		}
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		unsigned long cnt = atomic_long_read(&file->f_count);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("file %p/%pS has external references %lu:%lu\n", file, file->f_op, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+int generic_file_checkpoint(struct file *file, struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	struct kstate_image_file *i;
+	struct kstat stat;
+	char *buf, *name;
+	int rv;
+
+	i = kstate_prepare_image(KSTATE_OBJ_FILE, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	rv = vfs_getattr(file->f_path.mnt, file->f_path.dentry, &stat);
+	if (rv < 0)
+		goto out_free_image;
+	i->i_mode = stat.mode;
+	i->f_flags = file->f_flags;
+	/* Assume seeking over file doesn't have history. */
+	i->f_pos = file->f_pos;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	name = d_path(&file->f_path, buf, PAGE_SIZE);
+	if (IS_ERR(name)) {
+		rv = PTR_ERR(name);
+		goto out_free_buf;
+	}
+	i->name_len = buf + PAGE_SIZE - name - 1;
+	i->hdr.obj_len += i->name_len + 1;
+
+	obj = find_kstate_obj_by_ptr(ctx, file, KSTATE_CTX_FILE);
+	rv = kstate_write_image(ctx, i, sizeof(*i), obj);
+	if (rv == 0)
+		rv = kstate_write(ctx, name, i->name_len);
+	if (rv == 0)
+		rv = kstate_write(ctx, &rv, 1);	/* write NUL */
+	pr_debug("dump file %p: name_len %u, '%.*s', ->f_op %pS\n", file, i->name_len, i->name_len, name, file->f_op);
+
+out_free_buf:
+	kfree(buf);
+out_free_image:
+	kfree(i);
+	return rv;
+}
+EXPORT_SYMBOL_GPL(generic_file_checkpoint);
+
+static int dump_file(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct file *file = obj->o_obj;
+	int rv;
+
+	rv = file->f_op->checkpoint(file, ctx);
+	pr_debug("dump file %p: ref {%llu, %u}, rv %d\n", file, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_file(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_FILE) {
+		rv = dump_file(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_file(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_file *i;
+	struct file *file;
+	char *name;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_FILE, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+	if (i->hdr.obj_len < sizeof(*i) + i->name_len) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	name = (char *)(i + 1);
+	if (name[i->name_len] != '\0') {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	file = filp_open(name, i->f_flags, 0);
+	if (IS_ERR(file)) {
+		rv = PTR_ERR(file);
+		goto out_free_image;
+	}
+	if (file->f_dentry->d_inode->i_mode != i->i_mode) {
+		rv = -EINVAL;
+		goto out_fput;
+	}
+	/* Assume seeking over file doesn't have history. */
+	if (vfs_llseek(file, i->f_pos, SEEK_SET) != i->f_pos) {
+		rv = -EINVAL;
+		goto out_fput;
+	}
+
+	rv = kstate_restore_object(ctx, file, KSTATE_CTX_FILE, ref);
+	if (rv < 0)
+		fput(file);
+	pr_debug("restore file %p: ref {%llu, %u}, rv %d: '%s'\n", file, (unsigned long long)ref->pos, ref->id, rv, name);
+	kfree(i);
+	return rv;
+
+out_fput:
+	fput(file);
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
diff --git a/kernel/kstate/kstate-image.c b/kernel/kstate/kstate-image.c
new file mode 100644
index 0000000..b04cafc
--- /dev/null
+++ b/kernel/kstate/kstate-image.c
@@ -0,0 +1,116 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <asm/uaccess.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+int kstate_pread(struct kstate_context *ctx, void *buf, unsigned int count, kstate_pos_t pos)
+{
+	struct file *file = ctx->dump_file;
+	mm_segment_t old_fs;
+	ssize_t rv;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	BUILD_BUG_ON(sizeof(kstate_pos_t) != sizeof(loff_t));
+	rv = vfs_read(file, (char __user *)buf, count, (loff_t *)&pos);
+	set_fs(old_fs);
+	if (rv != count)
+		return (rv < 0) ? rv : -EIO;
+	return 0;
+}
+
+int kstate_write(struct kstate_context *ctx, const void *buf, unsigned int count)
+{
+	struct file *file = ctx->dump_file;
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
+void *kstate_prepare_image(__u32 type, unsigned int len)
+{
+	void *p;
+
+	p = kzalloc(len, GFP_KERNEL);
+	if (p) {
+		/* Any image must start with header. */
+		struct kstate_object_header *hdr = p;
+
+		hdr->obj_type = type;
+		hdr->obj_len = len;
+		hdr->obj_id = 0;
+	}
+	return p;
+}
+
+void *kstate_read_image(struct kstate_context *ctx, kstate_ref_t *ref, __u32 type, unsigned int len)
+{
+	struct kstate_object_header hdr;
+	void *i;
+	int rv;
+
+	/* Image header is not restorable object. */
+	if (ref->pos < sizeof(struct kstate_image_header))
+		return ERR_PTR(-EINVAL);
+
+	rv = kstate_pread(ctx, &hdr, sizeof(hdr), ref->pos);
+	if (rv < 0)
+		return ERR_PTR(rv);
+
+	if (hdr.obj_type != type) {
+		pr_debug("%s: object {%u, %u, %u} at %llu of wrong type, expected {%u, >=%u, %u}\n",
+			 __func__,
+			 hdr.obj_type, hdr.obj_len, hdr.obj_id,
+			 (unsigned long long)ref->pos,
+			 type, len, ref->id);
+		return ERR_PTR(-EINVAL);
+	}
+	if (hdr.obj_len < sizeof(hdr) || hdr.obj_len < len) {
+		pr_debug("%s: object {%u, %u, %u} at %llu too small, expected {%u, >=%u, %u}\n",
+			 __func__,
+			 hdr.obj_type, hdr.obj_len, hdr.obj_id,
+			 (unsigned long long)ref->pos,
+			 type, len, ref->id);
+		return ERR_PTR(-EINVAL);
+	}
+	if (hdr.obj_id != ref->id) {
+		pr_debug("%s: object {%u, %u, %u} at %llu has incorrect id, expected {%u, >=%u, %u}\n",
+			 __func__,
+			 hdr.obj_type, hdr.obj_len, hdr.obj_id,
+			 (unsigned long long)ref->pos,
+			 type, len, ref->id);
+		return ERR_PTR(-EINVAL);
+	}
+
+	i = kzalloc(hdr.obj_len, GFP_KERNEL);
+	if (!i)
+		return ERR_PTR(-ENOMEM);
+	rv = kstate_pread(ctx, i, hdr.obj_len, ref->pos);
+	if (rv < 0) {
+		kfree(i);
+		return ERR_PTR(rv);
+	}
+	return i;
+}
+
+int kstate_write_image(struct kstate_context *ctx, void *i, unsigned int len, struct kstate_object *obj)
+{
+	/* Object image must start with header. */
+	((struct kstate_object_header *)i)->obj_id = obj->o_ref.id;
+	obj->o_ref.pos = ctx->dump_file->f_pos;
+	return kstate_write(ctx, i, len);
+}
diff --git a/kernel/kstate/kstate-mm.c b/kernel/kstate/kstate-mm.c
new file mode 100644
index 0000000..d3045f3
--- /dev/null
+++ b/kernel/kstate/kstate-mm.c
@@ -0,0 +1,563 @@
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
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_vma(struct vm_area_struct *vma)
+{
+	unsigned long vm_flags;
+
+	if (vma->vm_ops && !vma->vm_ops->checkpoint) {
+		WARN(1, "vma %08lx-%08lx %pS isn't checkpointable\n",
+			vma->vm_start, vma->vm_end, vma->vm_ops);
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
+		WARN(1, "vma %08lx-%08lx %pS has uncheckpointable flags %08lx\n",
+			vma->vm_start, vma->vm_end, vma->vm_ops, vm_flags);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int dump_vma_pages(struct kstate_context *ctx, struct vm_area_struct *vma)
+{
+	unsigned long addr;
+	int rv;
+
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
+		struct page *page;
+
+again:
+		cond_resched();
+		page = follow_page(vma, addr, FOLL_ANON|FOLL_GET);
+		if (IS_ERR(page))
+			return PTR_ERR(page);
+		if (page == ZERO_PAGE(0)) {
+			put_page(page);
+			continue;
+		}
+		if (!page) {
+			rv = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+			if (rv & VM_FAULT_ERROR) {
+				if (rv & VM_FAULT_OOM)
+					return -ENOMEM;
+				if (rv & VM_FAULT_SIGBUS)
+					return -EFAULT;
+				BUG();
+			}
+			goto again;
+		}
+
+		if (PageAnon(page) || (!PageAnon(page) && !page_mapping(page))) {
+			struct kstate_image_page i;
+			void *data;
+
+			pr_debug("dump vma %p: addr %08lx, page %p\n",
+				 vma, addr, page);
+
+			i.hdr.obj_type = KSTATE_OBJ_PAGE;
+			i.hdr.obj_len = sizeof(i) + PAGE_SIZE;
+			i.hdr.obj_id = 0;
+
+			i.start_addr = addr;
+			i.page_size = PAGE_SIZE;
+			rv = kstate_write(ctx, &i, sizeof(i));
+			if (rv < 0) {
+				put_page(page);
+				return rv;
+			}
+
+			data = kmap(page);
+			rv = kstate_write(ctx, data, PAGE_SIZE);
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
+static int dump_anonvma(struct kstate_context *ctx, struct vm_area_struct *vma)
+{
+	struct kstate_image_vma *i;
+	int rv;
+
+	pr_debug("dump vma %p: %08lx-%08lx %c%c%c%c vm_flags %08lx, vm_pgoff %08lx\n",
+		vma, vma->vm_start, vma->vm_end,
+		vma->vm_flags & VM_READ ? 'r' : '-',
+		vma->vm_flags & VM_WRITE ? 'w' : '-',
+		vma->vm_flags & VM_EXEC ? 'x' : '-',
+		vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
+		vma->vm_flags,
+		vma->vm_pgoff);
+
+	i = kstate_prepare_image(KSTATE_OBJ_VMA, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+	/*
+	 * VMA doesn't get id because it can't be shared by itself,
+	 * only mm_struct can. Assign some deterministic id.
+	 */
+	i->hdr.obj_id = 0;
+
+	i->vm_start = vma->vm_start;
+	i->vm_end = vma->vm_end;
+	i->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	i->vm_flags = vma->vm_flags;
+	i->vm_pgoff = vma->vm_pgoff;
+	i->ref_vm_file = KSTATE_REF_UNDEF;
+
+	rv = kstate_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+	return dump_vma_pages(ctx, vma);
+}
+
+int filemap_checkpoint(struct vm_area_struct *vma, struct kstate_context *ctx)
+{
+	struct kstate_image_vma *i;
+	struct kstate_object *tmp;
+	int rv;
+
+	pr_debug("dump vma %p: %08lx-%08lx %c%c%c%c vm_flags %08lx, vm_pgoff %08lx, vm_ops %pS\n",
+		vma, vma->vm_start, vma->vm_end,
+		vma->vm_flags & VM_READ ? 'r' : '-',
+		vma->vm_flags & VM_WRITE ? 'w' : '-',
+		vma->vm_flags & VM_EXEC ? 'x' : '-',
+		vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
+		vma->vm_flags,
+		vma->vm_pgoff,
+		vma->vm_ops);
+
+	i = kstate_prepare_image(KSTATE_OBJ_VMA, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+	/*
+	 * VMA doesn't get id because it can't be shared by itself,
+	 * only mm_struct can. Assign some deterministic id.
+	 */
+	i->hdr.obj_id = 0;
+
+	i->vm_start = vma->vm_start;
+	i->vm_end = vma->vm_end;
+	i->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	i->vm_flags = vma->vm_flags;
+	i->vm_pgoff = vma->vm_pgoff;
+	tmp = find_kstate_obj_by_ptr(ctx, vma->vm_file, KSTATE_CTX_FILE);
+	i->ref_vm_file = tmp->o_ref;
+
+	rv = kstate_write(ctx, i, sizeof(*i));
+	kfree(i);
+	if (rv < 0)
+		return rv;
+	return dump_vma_pages(ctx, vma);
+}
+
+static int dump_vma(struct kstate_context *ctx, struct vm_area_struct *vma)
+{
+	if (!vma->vm_ops)
+		return dump_anonvma(ctx, vma);
+	if (vma->vm_ops->checkpoint)
+		return vma->vm_ops->checkpoint(vma, ctx);
+	BUG();
+}
+
+static int dump_all_vma(struct kstate_context *ctx, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	int rv;
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		rv = dump_vma(ctx, vma);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int restore_page(struct kstate_context *ctx, kstate_pos_t pos)
+{
+	struct kstate_image_page i;
+	struct page *page;
+	void *addr;
+	int rv;
+
+	rv = kstate_pread(ctx, &i, sizeof(i), pos);
+	if (rv < 0)
+		return rv;
+	if (i.hdr.obj_type != KSTATE_OBJ_PAGE)
+		return -EINVAL;
+	if (i.hdr.obj_len != sizeof(i) + PAGE_SIZE)
+		return -EINVAL;
+
+	rv = get_user_pages(current, current->mm, i.start_addr, 1, 1, 1, &page, NULL);
+	if (rv != 1)
+		return (rv < 0) ? rv : -EFAULT;
+	addr = kmap(page);
+	rv = kstate_pread(ctx, addr, PAGE_SIZE, pos + sizeof(i));
+	set_page_dirty_lock(page);
+	kunmap(page);
+	put_page(page);
+	return rv;
+}
+
+static int restore_pages(struct kstate_context *ctx, kstate_pos_t pos)
+{
+	while (1) {
+		struct kstate_object_header hdr;
+		int rv;
+
+		rv = kstate_pread(ctx, &hdr, sizeof(hdr), pos);
+		if (rv < 0)
+			return rv;
+		switch (hdr.obj_type) {
+		case KSTATE_OBJ_PAGE:
+			rv = restore_page(ctx, pos);
+			if (rv < 0)
+				return rv;
+			break;
+		default:
+			return 0;
+		}
+		pos += hdr.obj_len;
+	}
+}
+
+static int make_prot(struct kstate_image_vma *i)
+{
+	unsigned long prot = PROT_NONE;
+
+	if (i->vm_flags & VM_READ)
+		prot |= PROT_READ;
+	if (i->vm_flags & VM_WRITE)
+		prot |= PROT_WRITE;
+	if (i->vm_flags & VM_EXEC)
+		prot |= PROT_EXEC;
+	return prot;
+}
+
+static int make_flags(struct kstate_image_vma *i)
+{
+	unsigned long flags = MAP_FIXED;
+
+	flags |= MAP_PRIVATE;
+	if (kstate_ref_undefined(&i->ref_vm_file))
+		flags |= MAP_ANONYMOUS;
+
+	if (i->vm_flags & VM_GROWSDOWN)
+		flags |= MAP_GROWSDOWN;
+#ifdef MAP_GROWSUP
+	if (i->vm_flags & VM_GROWSUP)
+		flags |= MAP_GROWSUP;
+#endif
+	if (i->vm_flags & VM_EXECUTABLE)
+		flags |= MAP_EXECUTABLE;
+	if (i->vm_flags & VM_DENYWRITE)
+		flags |= MAP_DENYWRITE;
+	return flags;
+}
+
+int kstate_restore_vma(struct kstate_context *ctx, kstate_pos_t pos)
+{
+	kstate_ref_t ref = { .pos = pos, .id = 0 };
+	struct kstate_image_vma *i;
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	struct file *file;
+	unsigned long addr, prot, flags;
+	int rv;
+
+	i = kstate_read_image(ctx, &ref, KSTATE_OBJ_VMA, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	if (kstate_ref_undefined(&i->ref_vm_file))
+		file = NULL;
+	else {
+		struct kstate_object *tmp;
+
+		tmp = find_kstate_obj_by_ref(ctx, &i->ref_vm_file, KSTATE_CTX_FILE);
+		if (!tmp) {
+			rv = kstate_restore_file(ctx, &i->ref_vm_file);
+			if (rv < 0)
+				goto out_free_image;
+			tmp = find_kstate_obj_by_ref(ctx, &i->ref_vm_file, KSTATE_CTX_FILE);
+		}
+		file = tmp->o_obj;
+	}
+
+	prot = make_prot(i);
+	flags = make_flags(i);
+	addr = do_mmap_pgoff(file, i->vm_start, i->vm_end - i->vm_start, prot, flags, i->vm_pgoff);
+	if (addr != i->vm_start) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	vma = find_vma(mm, addr);
+	if (!vma) {
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	if (vma->vm_start != i->vm_start || vma->vm_end != i->vm_end) {
+		pr_debug("%s: vma %08lx-%08lx should be %08lx-%08lx\n",
+			 __func__, vma->vm_start, vma->vm_end,
+			 (unsigned long)i->vm_start, (unsigned long)i->vm_end);
+		rv = -EINVAL;
+		goto out_free_image;
+	}
+	pr_debug("restore vma: %08lx-%08lx, vm_flags %08lx, pgprot %016llx, vm_pgoff 0x%lx, vm_file {%llu, %u}\n",
+		 vma->vm_start, vma->vm_end, vma->vm_flags,
+		 (unsigned long long)pgprot_val(vma->vm_page_prot),
+		 vma->vm_pgoff,
+		 (unsigned long long)i->ref_vm_file.pos, i->ref_vm_file.id);
+	if (vma->vm_flags != i->vm_flags)
+		pr_debug("restore vma: vm_flags %08lx, i->vm_flags %08lx\n",
+			 vma->vm_flags, (unsigned long)i->vm_flags);
+	if (pgprot_val(vma->vm_page_prot) != i->vm_page_prot)
+		pr_debug("restore vma: prot %016llx, i->vm_page_prot %016llx\n",
+			 (unsigned long long)pgprot_val(vma->vm_page_prot),
+			 (unsigned long long)i->vm_page_prot);
+	kfree(i);
+	return restore_pages(ctx, pos + sizeof(*i));
+
+out_free_image:
+	kfree(i);
+	return rv;
+}
+
+static int check_mm_struct(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	int rv;
+
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
+	rv = kstate_arch_check_mm_struct(mm);
+	if (rv < 0)
+		return rv;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		rv = check_vma(vma);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int collect_mm_struct(struct kstate_context *ctx, struct mm_struct *mm)
+{
+	int rv;
+
+	rv = check_mm_struct(mm);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, mm, KSTATE_CTX_MM_STRUCT);
+	pr_debug("collect mm_struct %p: rv %d\n", mm, rv);
+	return rv;
+}
+
+int kstate_collect_all_mm_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = collect_mm_struct(ctx, tsk->mm);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_MM_STRUCT) {
+		struct mm_struct *mm = obj->o_obj;
+		unsigned int cnt = atomic_read(&mm->mm_users);
+
+		if (obj->o_count + 1 != cnt) {
+			pr_err("mm_struct %p has external references %lu:%u\n", mm, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int dump_mm_struct(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct mm_struct *mm = obj->o_obj;
+	struct kstate_image_mm_struct *i;
+	unsigned int image_len;
+	int rv;
+
+	image_len = sizeof(*i) + kstate_arch_len_mm_struct(mm);
+	i = kstate_prepare_image(KSTATE_OBJ_MM_STRUCT, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	down_read(&mm->mmap_sem);
+	i->def_flags = mm->def_flags;
+	i->start_code = mm->start_code;
+	i->end_code = mm->end_code;
+	i->start_data = mm->start_data;
+	i->end_data = mm->end_data;
+	i->start_brk = mm->start_brk;
+	i->brk = mm->brk;
+	i->start_stack = mm->start_stack;
+	i->arg_start = mm->arg_start;
+	i->arg_end = mm->arg_end;
+	i->env_start = mm->env_start;
+	i->env_end = mm->env_end;
+	i->flags = mm->flags;
+	BUILD_BUG_ON(sizeof(i->saved_auxv) < sizeof(mm->saved_auxv));
+	memcpy(i->saved_auxv, mm->saved_auxv, sizeof(mm->saved_auxv));
+
+	rv = kstate_arch_dump_mm_struct(ctx, mm, i + 1);
+	up_read(&mm->mmap_sem);
+	if (rv == 0)
+		rv = kstate_write_image(ctx, i, image_len, obj);
+	kfree(i);
+	pr_debug("dump mm_struct %p: ref {%llu, %u}, rv %d\n", mm, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv);
+	return rv;
+}
+
+int kstate_dump_all_mm_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_MM_STRUCT) {
+		struct mm_struct *mm = obj->o_obj;
+
+		rv = dump_mm_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+		rv = dump_all_vma(ctx, mm);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+int kstate_restore_mm_struct(struct kstate_context *ctx, kstate_ref_t *ref, unsigned int *len)
+{
+	struct kstate_image_mm_struct *i;
+	struct mm_struct *mm;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_MM_STRUCT, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	mm = mm_alloc();
+	if (!mm) {
+		rv = -ENOMEM;
+		goto out_free_image;
+	}
+	rv = init_new_context(current, mm);
+	if (rv < 0)
+		goto out_mm_put;
+
+	mm->get_unmapped_area = arch_get_unmapped_area_topdown;
+	mm->unmap_area = arch_unmap_area_topdown;
+
+	mm->def_flags = i->def_flags;
+	mm->start_code = i->start_code;
+	mm->end_code = i->end_code;
+	mm->start_data = i->start_data;
+	mm->end_data = i->end_data;
+	mm->start_brk = i->start_brk;
+	mm->brk = i->brk;
+	mm->start_stack = i->start_stack;
+	mm->arg_start = i->arg_start;
+	mm->arg_end = i->arg_end;
+	mm->env_start = i->env_start;
+	mm->env_end = i->env_end;
+	mm->flags = i->flags;
+	memcpy(mm->saved_auxv, i->saved_auxv, sizeof(mm->saved_auxv));
+
+	*len = i->hdr.obj_len;
+	kfree(i);
+
+	rv = kstate_restore_object(ctx, mm, KSTATE_CTX_MM_STRUCT, ref);
+	if (rv < 0)
+		mmdrop(mm);
+	pr_debug("restore mm_struct %p: ref {%llu, %u}, rv %d\n", mm, (unsigned long long)ref->pos, ref->id, rv);
+	return rv;
+
+out_mm_put:
+	mmdrop(mm);
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
diff --git a/kernel/kstate/kstate-object.c b/kernel/kstate/kstate-object.c
new file mode 100644
index 0000000..f9f2f33
--- /dev/null
+++ b/kernel/kstate/kstate-object.c
@@ -0,0 +1,100 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/fs.h>
+#include <linux/mm_types.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+int kstate_collect_object(struct kstate_context *ctx, void *p, enum kstate_context_obj_type type)
+{
+	struct kstate_object *obj;
+
+	BUG_ON(type >= NR_KSTATE_CTX_TYPES);
+
+	obj = find_kstate_obj_by_ptr(ctx, p, type);
+	if (obj) {
+		obj->o_count++;
+		return 0;
+	}
+	obj = kzalloc(sizeof(struct kstate_object), GFP_KERNEL);
+	if (!obj)
+		return -ENOMEM;
+	obj->o_count = 1;
+	obj->o_ref.pos = 0;	/* not yet dumped */
+	obj->o_ref.id = 0;	/* not yet assigned */
+	obj->o_obj = p;
+	list_add(&obj->o_list, &ctx->obj[type]);
+
+	switch (type) {
+	case KSTATE_CTX_FILE:
+		get_file((struct file *)obj->o_obj);
+		break;
+	case KSTATE_CTX_MM_STRUCT:
+		atomic_inc(&((struct mm_struct *)obj->o_obj)->mm_users);
+		break;
+	case KSTATE_CTX_TASK_STRUCT:
+		get_task_struct((struct task_struct *)obj->o_obj);
+		break;
+	default:
+		BUG();
+	}
+	return 0;
+}
+
+int kstate_restore_object(struct kstate_context *ctx, void *p, enum kstate_context_obj_type type, kstate_ref_t *ref)
+{
+	struct kstate_object *obj;
+
+	obj = kzalloc(sizeof(struct kstate_object), GFP_KERNEL);
+	if (!obj)
+		return -ENOMEM;
+	/* ->o_count isn't used on restart. */
+	obj->o_ref = *ref;
+	obj->o_obj = p;
+	list_add(&obj->o_list, &ctx->obj[type]);
+
+	if (type == KSTATE_CTX_TASK_STRUCT)
+		get_task_struct((struct task_struct *)obj->o_obj);
+	return 0;
+}
+
+struct kstate_object *find_kstate_obj_by_ptr(struct kstate_context *ctx, const void *ptr, enum kstate_context_obj_type type)
+{
+	struct kstate_object *obj;
+
+	BUG_ON(type >= NR_KSTATE_CTX_TYPES);
+
+	for_each_kstate_object(ctx, obj, type) {
+		if (obj->o_obj == ptr)
+			return obj;
+	}
+	return NULL;
+}
+
+struct kstate_object *find_kstate_obj_by_ref(struct kstate_context *ctx, kstate_ref_t *ref, enum kstate_context_obj_type type)
+{
+	struct kstate_object *obj;
+
+	BUG_ON(type >= NR_KSTATE_CTX_TYPES);
+
+	for_each_kstate_object(ctx, obj, type) {
+		if (obj->o_ref.pos == ref->pos && obj->o_ref.id == ref->id)
+			return obj;
+	}
+	return NULL;
+}
+
+struct kstate_object *find_kstate_obj_by_id(struct kstate_context *ctx, kstate_ref_t *ref, enum kstate_context_obj_type type)
+{
+	struct kstate_object *obj;
+
+	BUG_ON(type >= NR_KSTATE_CTX_TYPES);
+
+	for_each_kstate_object(ctx, obj, type) {
+		if (obj->o_ref.id == ref->id)
+			return obj;
+	}
+	return NULL;
+}
diff --git a/kernel/kstate/kstate-task.c b/kernel/kstate/kstate-task.c
new file mode 100644
index 0000000..aec97c2
--- /dev/null
+++ b/kernel/kstate/kstate-task.c
@@ -0,0 +1,287 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+#include <linux/kthread.h>
+#include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
+#include <linux/sched.h>
+#include <asm/mmu_context.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int check_task_struct(struct task_struct *tsk)
+{
+	read_lock_irq(&tasklist_lock);
+	if (!list_empty(&tsk->children)) {
+		read_unlock_irq(&tasklist_lock);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (!list_empty(&tsk->thread_group)) {
+		read_unlock_irq(&tasklist_lock);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	/* ptrace */
+	if (tsk->parent != tsk->real_parent) {
+		read_unlock_irq(&tasklist_lock);
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	read_unlock_irq(&tasklist_lock);
+	if (tsk->exit_state) {
+		WARN(1, "exit_state %08x\n", tsk->exit_state);
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
+	return kstate_arch_check_task_struct(tsk);
+}
+
+static int collect_task_struct(struct kstate_context *ctx, struct task_struct *tsk)
+{
+	int rv;
+
+	/* task_struct is never shared. */
+	BUG_ON(find_kstate_obj_by_ptr(ctx, tsk, KSTATE_CTX_TASK_STRUCT));
+
+	rv = check_task_struct(tsk);
+	if (rv < 0)
+		return rv;
+	rv = kstate_collect_object(ctx, tsk, KSTATE_CTX_TASK_STRUCT);
+	pr_debug("collect task_struct %p: rv %d, '%s'\n", tsk, rv, tsk->comm);
+	return rv;
+}
+
+int kstate_collect_all_task_struct(struct kstate_context *ctx)
+{
+	/* Seed task list. */
+	return collect_task_struct(ctx, ctx->init_tsk);
+}
+
+static int dump_task_struct(struct kstate_context *ctx, struct kstate_object *obj)
+{
+	struct task_struct *tsk = obj->o_obj;
+	struct kstate_image_task_struct *i;
+	unsigned int image_len;
+	struct kstate_object *tmp;
+	int rv;
+
+	image_len = sizeof(*i) + kstate_arch_len_task_struct(tsk);
+	i = kstate_prepare_image(KSTATE_OBJ_TASK_STRUCT, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	tmp = find_kstate_obj_by_ptr(ctx, tsk->mm, KSTATE_CTX_MM_STRUCT);
+	i->ref_mm = tmp->o_ref;
+
+	BUILD_BUG_ON(sizeof(i->comm) != sizeof(tsk->comm));
+	strlcpy((char *)i->comm, (const char *)tsk->comm, sizeof(i->comm));
+
+	i->tsk_arch = kstate_task_struct_arch(tsk);
+
+	rv = kstate_arch_dump_task_struct(ctx, tsk, i + 1);
+	if (rv == 0)
+		rv = kstate_write_image(ctx, i, image_len, obj);
+	kfree(i);
+	pr_debug("dump task_struct %p: ref {%llu, %u}, rv %d: '%s'\n", tsk, (unsigned long long)obj->o_ref.pos, obj->o_ref.id, rv, tsk->comm);
+	return rv;
+}
+
+int kstate_dump_all_task_struct(struct kstate_context *ctx)
+{
+	struct kstate_object *obj;
+	int rv;
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		rv = dump_task_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	return 0;
+}
+
+static int task_restore_all_vma(struct kstate_context *ctx, kstate_pos_t pos)
+{
+	while (1) {
+		struct kstate_object_header hdr;
+		int rv;
+
+		rv = kstate_pread(ctx, &hdr, sizeof(hdr), pos);
+		if (rv < 0)
+			return rv;
+		if (hdr.obj_len < sizeof(hdr))
+			return -EINVAL;
+
+		switch (hdr.obj_type) {
+		case KSTATE_OBJ_VMA:
+			down_write(&current->mm->mmap_sem);
+			rv = kstate_restore_vma(ctx, pos);
+			up_write(&current->mm->mmap_sem);
+			if (rv < 0)
+				return rv;
+			break;
+		case KSTATE_OBJ_PAGE:
+			break;
+		default:
+			return 0;
+		}
+		pos += hdr.obj_len;
+	}
+}
+
+static int restore_mm(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct task_struct *tsk = current;
+	struct mm_struct *mm, *prev_mm;
+	unsigned int len = 0;
+	int restore_vma;
+	struct kstate_object *tmp;
+	int rv;
+
+	tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_MM_STRUCT);
+	if (!tmp) {
+		rv = kstate_restore_mm_struct(ctx, ref, &len);
+		if (rv < 0)
+			return rv;
+		tmp = find_kstate_obj_by_ref(ctx, ref, KSTATE_CTX_MM_STRUCT);
+		restore_vma = 1;
+	} else
+		restore_vma = 0;
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
+	if (restore_vma)
+		return task_restore_all_vma(ctx, ref->pos + len);
+	return 0;
+}
+
+struct task_struct_restore_context {
+	struct kstate_context *ctx;
+	struct kstate_image_task_struct *i;
+	struct completion c;
+	int rv;
+};
+
+/*
+ * Restore is done in current context. Put unneeded pieces and read/create or
+ * get already created ones. Registers are restored in context of a task which
+ * did restart(2).
+ */
+static int task_struct_restorer(void *_tsk_ctx)
+{
+	struct task_struct_restore_context *tsk_ctx = _tsk_ctx;
+	struct kstate_image_task_struct *i = tsk_ctx->i;
+	struct kstate_context *ctx = tsk_ctx->ctx;
+	/* In the name of symmetry. */
+	struct task_struct *tsk = current, *real_parent;
+	int rv;
+
+	pr_debug("%s: ENTER tsk %p/%s\n", __func__, tsk, tsk->comm);
+
+	write_lock_irq(&tasklist_lock);
+	real_parent = ctx->init_tsk->nsproxy->pid_ns->child_reaper;
+	tsk->real_parent = tsk->parent = real_parent;
+	list_move_tail(&tsk->sibling, &tsk->real_parent->sibling);
+	write_unlock_irq(&tasklist_lock);
+
+	rv = restore_mm(ctx, &i->ref_mm);
+	if (rv < 0)
+		goto out;
+
+out:
+	tsk_ctx->rv = rv;
+	complete(&tsk_ctx->c);
+	__set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule();
+	pr_debug("%s: return %d\n", __func__, rv);
+	return rv;
+}
+
+int kstate_restore_task_struct(struct kstate_context *ctx, kstate_ref_t *ref)
+{
+	struct kstate_image_task_struct *i;
+	struct task_struct_restore_context tsk_ctx;
+	struct task_struct *tsk;
+	int rv;
+
+	i = kstate_read_image(ctx, ref, KSTATE_OBJ_TASK_STRUCT, sizeof(*i));
+	if (IS_ERR(i))
+		return PTR_ERR(i);
+
+	rv = kstate_arch_check_image_task_struct(i);
+	if (rv < 0)
+		goto out_free_image;
+
+	tsk_ctx.ctx = ctx;
+	tsk_ctx.i = i;
+	init_completion(&tsk_ctx.c);
+	/* Restore ->comm for free. */
+	tsk = kthread_run(task_struct_restorer, &tsk_ctx, "%.*s", (int)sizeof(i->comm) - 1, i->comm);
+	if (IS_ERR(tsk)) {
+		rv = PTR_ERR(tsk);
+		goto out_free_image;
+	}
+	wait_for_completion(&tsk_ctx.c);
+	wait_task_inactive(tsk, 0);
+	if (tsk_ctx.rv < 0) {
+		rv = tsk_ctx.rv;
+		goto out_kill;
+	}
+
+	rv = kstate_arch_restore_task_struct(tsk, i);
+	if (rv < 0)
+		goto out_kill;
+
+#ifdef CONFIG_PREEMPT
+	task_thread_info(tsk)->preempt_count--;
+#endif
+
+	rv = kstate_restore_object(ctx, tsk, KSTATE_CTX_TASK_STRUCT, ref);
+	if (rv < 0)
+		goto out_kill;
+
+	kfree(i);
+
+	pr_debug("restore task_struct %p: ref {%llu, %u}, rv %d: '%s'\n", tsk, (unsigned long long)ref->pos, ref->id, rv, tsk->comm);
+	return 0;
+
+out_kill:
+	send_sig(SIGKILL, tsk, 1);
+	spin_lock_irq(&tsk->sighand->siglock);
+	sigfillset(&tsk->blocked);
+	sigdelsetmask(&tsk->blocked, sigmask(SIGKILL));
+	set_tsk_thread_flag(tsk, TIF_SIGPENDING);
+	spin_unlock_irq(&tsk->sighand->siglock);
+	wake_up_process(tsk);
+out_free_image:
+	kfree(i);
+	pr_debug("%s: return %d, ref {%llu, %u}\n", __func__, rv, (unsigned long long)ref->pos, ref->id);
+	return rv;
+}
diff --git a/kernel/kstate/rst-sys.c b/kernel/kstate/rst-sys.c
new file mode 100644
index 0000000..4c88716
--- /dev/null
+++ b/kernel/kstate/rst-sys.c
@@ -0,0 +1,91 @@
+/* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
+/* restart(2) */
+#include <linux/capability.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+
+#include <linux/kstate.h>
+#include <linux/kstate-image.h>
+
+static int kstate_check_image_header(struct kstate_context *ctx)
+{
+	struct kstate_image_header hdr;
+	int rv;
+
+	rv = kstate_pread(ctx, &hdr, sizeof(hdr), 0);
+	if (rv < 0)
+		return rv;
+	pr_debug("%s: image version %u, arch %u\n", __func__, hdr.image_version, hdr.kernel_arch);
+	if (memcmp(hdr.image_magic, KSTATE_IMAGE_MAGIC, 8) != 0)
+		return -EINVAL;
+	if (hdr.image_version != cpu_to_le32(KSTATE_IMAGE_VERSION))
+		return -EINVAL;
+	return kstate_arch_check_image_header(&hdr);
+}
+
+static int kstate_restart(struct kstate_context *ctx)
+{
+	kstate_pos_t pos;
+	struct kstate_object *obj;
+	int rv;
+
+	rv = kstate_check_image_header(ctx);
+	if (rv < 0)
+		return rv;
+	pos = sizeof(struct kstate_image_header);
+	do {
+		struct kstate_object_header hdr;
+		kstate_ref_t ref;
+
+		rv = kstate_pread(ctx, &hdr, sizeof(hdr), pos);
+		if (rv < 0)
+			return rv;
+		if (hdr.obj_type == KSTATE_OBJ_TERMINATOR)
+			break;
+
+		ref.pos = pos;
+		ref.id = hdr.obj_id;
+		if (hdr.obj_type == KSTATE_OBJ_TASK_STRUCT) {
+			rv = kstate_restore_task_struct(ctx, &ref);
+			if (rv < 0)
+				return rv;
+		}
+		pos += hdr.obj_len;
+	} while (rv == 0);
+
+	for_each_kstate_object(ctx, obj, KSTATE_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		pr_debug("%s: wake up task %p/%s\n", __func__, tsk, tsk->comm);
+		wake_up_process(tsk);
+	}
+
+	return 0;
+}
+
+SYSCALL_DEFINE2(restart, int, fd, int, flags)
+{
+	struct kstate_context *ctx;
+	struct file *file;
+	int rv;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	file = fget(fd);
+	if (!file)
+		return -EBADF;
+	ctx = kstate_context_create(current, file);
+	if (!ctx) {
+		rv = -ENOMEM;
+		goto out_ctx_create;
+	}
+
+	rv = kstate_restart(ctx);
+
+	kstate_context_destroy(ctx);
+out_ctx_create:
+	fput(file);
+	return rv;
+}
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 27dad29..da4fbf6 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -175,3 +175,6 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..ec6889d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1627,6 +1627,9 @@ EXPORT_SYMBOL(filemap_fault);
 
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */
-- 
1.5.6.5
