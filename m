From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v3][PATCH 8/9] File descriprtors (dump)
Date: Thu, 4 Sep 2008 04:05:50 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0809040405250.5982__34947.1796224408$1220516142$gmane$org@takamine.ncl.cs.columbia.edu>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040354440.460-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org


Dump the files_struct of a task with 'struct cr_hdr_files', followed by
all open file descriptors. Since FDs can be shared, they are assigned a
tag and registered in the object hash.

For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its tag
and its close-on-exec property. If the FD is to be saved (first time)
then this is followed by a 'struct cr_hdr_fd_data' with the FD state.
Then will come the next FD and so on.

This patch only handles basic FDs - regular files, directories and also
symbolic links.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  checkpoint/Makefile      |    2 +-
  checkpoint/checkpoint.c  |    4 +
  checkpoint/ckpt_file.c   |  224 ++++++++++++++++++++++++++++++++++++++++++++++
  checkpoint/ckpt_file.h   |   17 ++++
  include/linux/ckpt.h     |    7 +-
  include/linux/ckpt_hdr.h |   34 +++++++-
  6 files changed, 283 insertions(+), 5 deletions(-)
  create mode 100644 checkpoint/ckpt_file.c
  create mode 100644 checkpoint/ckpt_file.h

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 9843fb9..7496695 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
  #

  obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o objhash.o \
-		ckpt_mem.o rstr_mem.o
+		ckpt_mem.o rstr_mem.o ckpt_file.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 4dae775..aebbf22 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -217,6 +217,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
  	cr_debug("memory: ret %d\n", ret);
  	if (ret < 0)
  		goto out;
+	ret = cr_write_files(ctx, t);
+	cr_debug("files: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
  	ret = cr_write_thread(ctx, t);
  	cr_debug("thread: ret %d\n", ret);
  	if (ret < 0)
diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
new file mode 100644
index 0000000..34df371
--- /dev/null
+++ b/checkpoint/ckpt_file.c
@@ -0,0 +1,224 @@
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
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/file.h>
+#include <linux/fdtable.h>
+#include <linux/ckpt.h>
+#include <linux/ckpt_hdr.h>
+
+#include "ckpt_file.h"
+
+#define CR_DEFAULT_FDTABLE  256
+
+/**
+ * cr_scan_fds - scan file table and construct array of open fds
+ * @files: files_struct pointer
+ * @fdtable: (output) array of open fds
+ * @return: the number of open fds found
+ *
+ * Allocates the file descriptors array (*fdtable), caller should free
+ */
+int cr_scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fdlist;
+	int i, n, max;
+
+	max = CR_DEFAULT_FDTABLE;
+
+ repeat:
+	n = 0;
+	fdlist = kmalloc(max * sizeof(*fdlist), GFP_KERNEL);
+	if (!fdlist)
+		return -ENOMEM;
+
+	spin_lock(&files->file_lock);
+	fdt = files_fdtable(files);
+	for (i = 0; i < fdt->max_fds; i++) {
+		if (fcheck_files(files, i)) {
+			if (n == max) {
+				spin_unlock(&files->file_lock);
+				kfree(fdlist);
+				max *= 2;
+				if (max < 0) {	/* overflow ? */
+					n = -EMFILE;
+					break;
+				}
+				goto repeat;
+			}
+			fdlist[n++] = i;
+		}
+	}
+	spin_unlock(&files->file_lock);
+
+	*fdtable = fdlist;
+	return n;
+}
+
+/* cr_write_fd_data - dump the state of a given file pointer */
+static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct dentry *dent = file->f_dentry;
+	struct inode *inode = dent->d_inode;
+	enum fd_type fd_type;
+	int ret;
+
+	h.type = CR_HDR_FD_DATA;
+	h.len = sizeof(*hh);
+	h.parent = parent;
+
+	BUG_ON(!inode);
+
+	hh->f_flags = file->f_flags;
+	hh->f_mode = file->f_mode;
+	hh->f_pos = file->f_pos;
+	hh->f_uid = file->f_uid;
+	hh->f_gid = file->f_gid;
+	hh->f_version = file->f_version;
+	/* FIX: need also file->f_owner */
+
+	switch (inode->i_mode & S_IFMT) {
+	case S_IFREG:
+		fd_type = CR_FD_FILE;
+		break;
+	case S_IFDIR:
+		fd_type = CR_FD_DIR;
+		break;
+	case S_IFLNK:
+		fd_type = CR_FD_LINK;
+		break;
+	default:
+		return -EBADF;
+	}
+
+	/* FIX: check if the file/dir/link is unlinked */
+	hh->fd_type = fd_type;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	return cr_write_fname(ctx, &file->f_path, ctx->vfsroot);
+}
+
+/**
+ * cr_write_fd_ent - dump the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @fd: file descriptor
+ *
+ * Save the state of the file descriptor; look up the actual file pointer
+ * in the hash table, and if found save the matching objref, otherwise call
+ * cr_write_fd_data to dump the file pointer too.
+ */
+static int
+cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file = NULL;
+	struct fdtable *fdt;
+	int coe, objref, ret;
+
+	/* make sure hh->fd (that is of type __u16) doesn't overflow */
+	if (fd > USHORT_MAX) {
+		pr_warning("CR: open files table too big (%d)\n", USHORT_MAX);
+		return -EMFILE;
+	}
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
+	ret = cr_obj_add_ptr(ctx, (void *) file, &objref, CR_OBJ_FILE, 0);
+	cr_debug("fd %d objref %d file %p c-o-e %d)\n", fd, objref, file, coe);
+
+	if (ret >= 0) {
+		int new = ret;
+
+		h.type = CR_HDR_FD_ENT;
+		h.len = sizeof(*hh);
+		h.parent = 0;
+
+		hh->objref = objref;
+		hh->fd = fd;
+		hh->close_on_exec = coe;
+
+		ret = cr_write_obj(ctx, &h, hh);
+		cr_hbuf_put(ctx, sizeof(*hh));
+		if (ret < 0)
+			return ret;
+
+		/* new==1 if-and-only-if file was new and added to hash */
+		if (new)
+			ret = cr_write_fd_data(ctx, file, objref);
+	}
+
+	fput(file);
+	return ret;
+}
+
+int cr_write_files(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_files *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct files_struct *files;
+	int *fdtable;
+	int nfds, n, ret;
+
+	h.type = CR_HDR_FILES;
+	h.len = sizeof(*hh);
+	h.parent = task_pid_vnr(t);
+
+	files = get_files_struct(t);
+
+	hh->objref = 0;	/* will be meaningful with multiple processes */
+
+	nfds = cr_scan_fds(files, &fdtable);
+	if (nfds < 0) {
+		ret = nfds;
+		goto out;
+	}
+
+	hh->nfds = nfds;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto clean;
+
+	cr_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = cr_write_fd_ent(ctx, files, n);
+		if (ret < 0)
+			break;
+	}
+
+ clean:
+	kfree(fdtable);
+ out:
+	put_files_struct(files);
+
+	return ret;
+}
diff --git a/checkpoint/ckpt_file.h b/checkpoint/ckpt_file.h
new file mode 100644
index 0000000..9dc3eba
--- /dev/null
+++ b/checkpoint/ckpt_file.h
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
diff --git a/include/linux/ckpt.h b/include/linux/ckpt.h
index e8be58c..ea57fe6 100644
--- a/include/linux/ckpt.h
+++ b/include/linux/ckpt.h
@@ -13,7 +13,7 @@
  #include <linux/path.h>
  #include <linux/fs.h>

-#define CR_VERSION  1
+#define CR_VERSION  2

  struct cr_ctx {
  	pid_t pid;		/* container identifier */
@@ -80,11 +80,12 @@ int cr_read_string(struct cr_ctx *ctx, void *str, int len);
  int cr_read_fname(struct cr_ctx *ctx, void *fname, int n);
  struct file *cr_read_open_fname(struct cr_ctx *ctx, int flags, int mode);

+int do_checkpoint(struct cr_ctx *ctx);
  int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
-int cr_read_mm(struct cr_ctx *ctx);
+int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);

-int do_checkpoint(struct cr_ctx *ctx);
  int do_restart(struct cr_ctx *ctx);
+int cr_read_mm(struct cr_ctx *ctx);

  #define cr_debug(fmt, args...)  \
  	pr_debug("[CR:%s] " fmt, __func__, ## args)
diff --git a/include/linux/ckpt_hdr.h b/include/linux/ckpt_hdr.h
index 322ade5..1ce1dbc 100644
--- a/include/linux/ckpt_hdr.h
+++ b/include/linux/ckpt_hdr.h
@@ -17,7 +17,7 @@
  /*
   * To maintain compatibility between 32-bit and 64-bit architecture flavors,
   * keep data 64-bit aligned: use padding for structure members, and use
- * __attribute__ ((aligned (8))) for the entire structure.
+ * __attribute__((aligned(8))) for the entire structure.
   */

  /* records: generic header */
@@ -42,6 +42,10 @@ enum {
  	CR_HDR_VMA,
  	CR_HDR_MM_CONTEXT,

+	CR_HDR_FILES = 301,
+	CR_HDR_FD_ENT,
+	CR_HDR_FD_DATA,
+
  	CR_HDR_TAIL = 5001
  };

@@ -110,4 +114,32 @@ struct cr_hdr_vma {

  } __attribute__((aligned(8)));

+struct cr_hdr_files {
+	__u32 objref;		/* identifier for shared objects */
+	__u32 nfds;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_fd_ent {
+	__u32 objref;		/* identifier for shared objects */
+	__u16 fd;
+	__u16 close_on_exec;
+} __attribute__((aligned(8)));
+
+/* fd types */
+enum  fd_type {
+	CR_FD_FILE = 1,
+	CR_FD_DIR,
+	CR_FD_LINK
+};
+
+struct cr_hdr_fd_data {
+	__u16 fd_type;
+	__u16 f_mode;
+	__u32 f_flags;
+	__u32 f_uid;
+	__u32 f_gid;
+	__u64 f_pos;
+	__u64 f_version;
+} __attribute__((aligned(8)));
+
  #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.4.3
