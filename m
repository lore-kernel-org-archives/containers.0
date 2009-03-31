From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 09/29] Dump open file descriptors
Date: Tue, 31 Mar 2009 01:28:49 -0400
Message-ID: <1238477349-11029-10-git-send-email-orenl@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477349-11029-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Dump the files_struct of a task with 'struct cr_hdr_files', followed by
all open file descriptors. Because the 'struct file' corresponding to an
FD can be shared, each they are assigned an objref and registered in the
object hash. A reference to the 'file *' is kept for as long as it lives
in the hash (the hash is only cleaned up at the end of the checkpoint).

For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its
close-on-exec property, and the objref of the corresponding 'file *'.
If the FD is to be saved (first time) then this is followed by a
'struct cr_hdr_fd_data' with the FD state. Then will come the next FD
and so on.

Recall that it is assumed that all tasks possibly sharing the file table
are frozen. If this assumption breaks, then the behavior is *undefined*:
checkpoint may fail, or restart from the resulting image file will fail.

This patch only handles basic FDs - regular files, directories.

Changelog[v14]:
  - Revert change to pr_debug(), back to cr_debug()
  - Use only unsigned fields in checkpoint headers
  - Rename:  cr_write_files() => cr_write_fd_table()
  - Rename:  cr_write_fd_data() => cr_write_file()
  - Discard field 'h->parent'
  - Check whether calls to cr_hbuf_get() fail
  - Use one CR_FD_GENERIC for both regular files and dirs
  - Put code for generic file descriptors in a separate function

Changelog[v12]:
  - Replace obsolete cr_debug() with pr_debug()

Changelog[v11]:
  - Discard handling of opened symlinks (there is no such thing)
  - cr_scan_fds() retries from scratch if hits size limits

Changelog[v9]:
  - Fix a couple of leaks in cr_write_files()
  - Drop useless kfree from cr_scan_fds()

Changelog[v8]:
  - initialize 'coe' to workaround gcc false warning

Changelog[v6]:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (even though it's not really needed)

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 arch/x86/include/asm/checkpoint_hdr.h |    2 +-
 checkpoint/Makefile                   |    2 +-
 checkpoint/checkpoint.c               |    4 +
 checkpoint/checkpoint_file.h          |   17 +++
 checkpoint/ckpt_file.c                |  247 +++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h            |    3 +-
 include/linux/checkpoint_hdr.h        |   30 ++++-
 7 files changed, 301 insertions(+), 4 deletions(-)
 create mode 100644 checkpoint/checkpoint_file.h
 create mode 100644 checkpoint/ckpt_file.c

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index e9eb40c..1efdf24 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -15,7 +15,7 @@
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
- * __attribute__ ((aligned (8))) for the entire structure.
+ * __attribute__((aligned (8))) for the entire structure.
  *
  * Quoting Arnd Bergmann:
  *   "This structure has an odd multiple of 32-bit members, which means
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 8368a03..1d92ed2 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT) += sys.o checkpoint.o restart.o objhash.o \
-		ckpt_mem.o rstr_mem.o
+		ckpt_mem.o rstr_mem.o ckpt_file.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 422e1a3..d4e0007 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -250,6 +250,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	cr_debug("memory: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_fd_table(ctx, t);
+	cr_debug("files: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_thread(ctx, t);
 	cr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/checkpoint_file.h b/checkpoint/checkpoint_file.h
new file mode 100644
index 0000000..9dc3eba
--- /dev/null
+++ b/checkpoint/checkpoint_file.h
@@ -0,0 +1,17 @@
+#ifndef _CHECKPOINT_CKPT_FILE_H_
+#define _CHECKPOINT_CKPT_FILE_H_
+/*
+ *  Checkpoint file descriptors
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/fdtable.h>
+
+int cr_scan_fds(struct files_struct *files, int **fdtable);
+
+#endif /* _CHECKPOINT_CKPT_FILE_H_ */
diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
new file mode 100644
index 0000000..9c344c7
--- /dev/null
+++ b/checkpoint/ckpt_file.c
@@ -0,0 +1,247 @@
+/*
+ *  Checkpoint file descriptors
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "checkpoint_file.h"
+
+#define CR_DEFAULT_FDTABLE  256		/* an initial guess */
+
+/**
+ * cr_scan_fds - scan file table and construct array of open fds
+ * @files: files_struct pointer
+ * @fdtable: (output) array of open fds
+ *
+ * Returns the number of open fds found, and also the file table
+ * array via *fdtable. The caller should free the array.
+ *
+ * The caller must validate the file descriptors collected in the
+ * array before using them, e.g. by using fcheck_files(), in case
+ * the task's fdtable changes in the meantime.
+ */
+int cr_scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fds = NULL;
+	int i, n;
+	int tot = CR_DEFAULT_FDTABLE;
+
+	/*
+	 * We assume that all tasks possibly sharing the file table are
+	 * frozen (or we our a single process and we checkpoint ourselves).
+	 * Therefore, we can safely proceed after krealloc() from where we
+	 * left off. Otherwise the file table may be modified by another
+	 * task after we scan it. The behavior is this case is undefined,
+	 * and either and either checkpoint or restart will likely fail.
+	 */
+ retry:
+	fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
+	if (!fds)
+		return -ENOMEM;
+
+	spin_lock(&files->file_lock);
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	for (n = 0, i = 0; i < fdt->max_fds; i++) {
+		if (!fcheck_files(files, i))
+			continue;
+		if (n == tot) {
+			spin_unlock(&files->file_lock);
+			rcu_read_unlock();
+			tot *= 2;	/* won't overflow: kmalloc will fail */
+			goto retry;
+		}
+		fds[n++] = i;
+	}
+	rcu_read_unlock();
+	spin_unlock(&files->file_lock);
+
+	*fdtable = fds;
+	return n;
+}
+
+static int cr_write_file_generic(struct cr_ctx *ctx, struct file *file,
+				 struct cr_hdr_file *hh)
+{
+	struct cr_hdr h;
+	int ret;
+
+	/*
+	 * FIX: check if the file/dir/link is unlinked
+	 *
+	 * Or, pass up somthing like in hh->flags to tell
+	 * the higher-level code that it needs to bring
+	 * along the file contents too.
+	 */
+
+	h.type = CR_HDR_FILE;
+	h.len = sizeof(*hh);
+
+	hh->fd_type = CR_FD_GENERIC;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		return ret;
+
+	return cr_write_fname(ctx, &file->f_path, &ctx->fs_mnt);
+}
+
+/* cr_write_file - dump the state of a given file pointer */
+static int cr_write_file(struct cr_ctx *ctx, struct file *file)
+{
+	struct cr_hdr_file *hh;
+	struct dentry *dent = file->f_dentry;
+	struct inode *inode = dent->d_inode;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	hh->f_flags = file->f_flags;
+	hh->f_mode = file->f_mode;
+	hh->f_pos = file->f_pos;
+	hh->f_version = file->f_version;
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+
+	/*
+	 * FIXME: when we'll add support for unlinked files/dirs, we'll
+	 * need to distinguish between unlinked filed and unlinked dirs.
+	 */
+	switch (inode->i_mode & S_IFMT) {
+	case S_IFREG:
+	case S_IFDIR:
+		ret = cr_write_file_generic(ctx, file, hh);
+		break;
+	default:
+		ret = -EBADF;
+		break;
+	}
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+/**
+ * cr_write_fd_ent - dump the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @fd: file descriptor
+ *
+ * Saves the state of the file descriptor; looks up the actual file
+ * pointer in the hash table, and if found saves the matching objref,
+ * otherwise calls cr_write_file to dump the file pointer too.
+ */
+static int
+cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_ent *hh;
+	struct file *file;
+	struct fdtable *fdt;
+	int objref, new, ret;
+	int coe = 0;	/* avoid gcc warning */
+
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	file = fcheck_files(files, fd);
+	if (file) {
+		coe = FD_ISSET(fd, fdt->close_on_exec);
+		get_file(file);
+	}
+	rcu_read_unlock();
+
+	/* sanity check (although this shouldn't happen) */
+	if (!file)
+		return -EBADF;
+
+	/* adding 'file' to the hash will keep a reference to it */
+	new = cr_obj_add_ptr(ctx, file, &objref, CR_OBJ_FILE, 0);
+	cr_debug("fd %d objref %d file %p c-o-e %d)\n", fd, objref, file, coe);
+
+	if (new < 0)
+		return new;
+
+	h.type = CR_HDR_FD_ENT;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh) {
+		fput(file);
+		return -ENOMEM;
+	}
+
+	hh->objref = objref;
+	hh->fd = fd;
+	hh->close_on_exec = coe;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	/* new==1 if-and-only-if file was newly added to hash */
+	if (new)
+		ret = cr_write_file(ctx, file);
+
+out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (file)
+		fput(file);
+	return ret;
+}
+
+int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_table *hh;
+	struct files_struct *files;
+	int *fdtable = NULL;
+	int nfds, n, ret;
+
+	h.type = CR_HDR_FD_TABLE;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	files = get_files_struct(t);
+
+	nfds = cr_scan_fds(files, &fdtable);
+	if (nfds < 0) {
+		ret = nfds;
+		goto out;
+	}
+
+	hh->objref = 0;	/* will be meaningful with multiple processes */
+	hh->nfds = nfds;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto out;
+
+	cr_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = cr_write_fd_ent(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+
+ out:
+	kfree(fdtable);
+	put_files_struct(files);
+	return ret;
+}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 88854a9..9489ea5 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -13,7 +13,7 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 
-#define CR_VERSION  1
+#define CR_VERSION  2
 
 struct cr_ctx {
 	int crid;		/* unique checkpoint id */
@@ -85,6 +85,7 @@ extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 
 extern int do_checkpoint(struct cr_ctx *ctx, pid_t pid);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_fd_table(struct cr_ctx *ctx, struct task_struct *t);
 
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
 extern int cr_read_mm(struct cr_ctx *ctx);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2a06a2f..a6b6dce 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -17,7 +17,7 @@
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
- * __attribute__ ((aligned (8))) for the entire structure.
+ * __attribute__((aligned (8))) for the entire structure.
  *
  * Quoting Arnd Bergmann:
  *   "This structure has an odd multiple of 32-bit members, which means
@@ -53,6 +53,10 @@ enum {
 	CR_HDR_PGARR,
 	CR_HDR_MM_CONTEXT,
 
+	CR_HDR_FD_TABLE = 301,
+	CR_HDR_FD_ENT,
+	CR_HDR_FILE,
+
 	CR_HDR_TAIL = 5001
 };
 
@@ -123,4 +127,28 @@ struct cr_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+struct cr_hdr_fd_table {
+	__s32 objref;		/* identifier for shared objects */
+	__s32 nfds;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_fd_ent {
+	__s32 objref;		/* identifier for shared objects */
+	__s32 fd;
+	__u32 close_on_exec;
+} __attribute__((aligned(8)));
+
+/* fd types */
+enum  fd_type {
+	CR_FD_GENERIC = 1
+};
+
+struct cr_hdr_file {
+	__u16 fd_type;
+	__u16 f_mode;
+	__u32 f_flags;
+	__u64 f_pos;
+	__u64 f_version;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.4.3
