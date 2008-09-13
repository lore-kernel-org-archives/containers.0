From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v5][PATCH 8/8] Dump open file descriptors
Date: Sat, 13 Sep 2008 19:06:06 -0400
Message-ID: <1221347167-9956-9-git-send-email-orenl@cs.columbia.edu>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221347167-9956-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
all open file descriptors. Since FDs can be shared, they are assigned an
objref and registered in the object hash.

For each open FD there is a 'struct cr_hdr_fd_ent' with the FD, its objref
and its close-on-exec property. If the FD is to be saved (first time)
then this is followed by a 'struct cr_hdr_fd_data' with the FD state.
Then will come the next FD and so on.

This patch only handles basic FDs - regular files, directories and also
symbolic links.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/Makefile            |    2 +-
 checkpoint/checkpoint.c        |    4 +
 checkpoint/checkpoint_file.h   |   17 +++
 checkpoint/ckpt_file.c         |  221 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint.h     |    7 +-
 include/linux/checkpoint_hdr.h |   32 ++++++-
 6 files changed, 278 insertions(+), 5 deletions(-)
 create mode 100644 checkpoint/checkpoint_file.h
 create mode 100644 checkpoint/ckpt_file.c

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
index d4c1b31..87420dc 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -203,6 +203,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
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
index 0000000..bf049d1
--- /dev/null
+++ b/checkpoint/ckpt_file.c
@@ -0,0 +1,221 @@
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
+ */
+int cr_scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fds;
+	int i, n, tot;
+
+	n = 0;
+	tot = CR_DEFAULT_FDTABLE;
+
+	fds = kmalloc(tot * sizeof(*fds), GFP_KERNEL);
+	if (!fds)
+		return -ENOMEM;
+
+	spin_lock(&files->file_lock);
+	fdt = files_fdtable(files);
+	for (i = 0; i < fdt->max_fds; i++) {
+		if (!fcheck_files(files, i))
+			continue;
+		if (n == tot) {
+			/*
+			 * fcheck_files() is safe with drop/re-acquire
+			 * of the lock, because it tests:  fd < max_fds
+			 */
+			spin_unlock(&files->file_lock);
+			tot *= 2;
+			if (tot < 0) {		/* overflow ? */
+				kfree(fds);
+				return -EMFILE;
+			}
+			fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
+			if (!fds)
+				return -ENOMEM;
+			spin_lock(&files->file_lock);
+		}
+		fds[n++] = i;
+	}
+	spin_unlock(&files->file_lock);
+
+	*fdtable = fds;
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
+	hh->f_flags = file->f_flags;
+	hh->f_mode = file->f_mode;
+	hh->f_pos = file->f_pos;
+	hh->f_version = file->f_version;
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
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
+ * Saves the state of the file descriptor; looks up the actual file
+ * pointer in the hash table, and if found saves the matching objref,
+ * otherwise calls cr_write_fd_data to dump the file pointer too.
+ */
+static int
+cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file = NULL;
+	struct fdtable *fdt;
+	int coe, objref, new, ret;
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
+	new = cr_obj_add_ptr(ctx, (void *) file, &objref, CR_OBJ_FILE, 0);
+	cr_debug("fd %d objref %d file %p c-o-e %d)\n", fd, objref, file, coe);
+
+	if (new < 0) {
+		ret = new;
+		goto out;
+	}
+
+	h.type = CR_HDR_FD_ENT;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->objref = objref;
+	hh->fd = fd;
+	hh->close_on_exec = coe;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto out;
+
+	/* new==1 if-and-only-if file was newly added to hash */
+	if (new)
+		ret = cr_write_fd_data(ctx, file, objref);
+
+out:
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
+		ret = cr_write_fd_ent(ctx, files, fdtable[n]);
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
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 9990bb1..a202c54 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -13,7 +13,7 @@
 #include <linux/path.h>
 #include <linux/fs.h>
 
-#define CR_VERSION  1
+#define CR_VERSION  2
 
 struct cr_ctx {
 	pid_t pid;		/* container identifier */
@@ -83,11 +83,12 @@ extern int cr_read_fname(struct cr_ctx *ctx, void *fname, int n);
 extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
 				       int flags, int mode);
 
+extern int do_checkpoint(struct cr_ctx *ctx);
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
-extern int cr_read_mm(struct cr_ctx *ctx);
+extern int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);
 
-extern int do_checkpoint(struct cr_ctx *ctx);
 extern int do_restart(struct cr_ctx *ctx);
+extern int cr_read_mm(struct cr_ctx *ctx);
 
 #define cr_debug(fmt, args...)  \
 	pr_debug("[CR:%s] " fmt, __func__, ## args)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2b110f1..cbb920f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -17,7 +17,7 @@
 /*
  * To maintain compatibility between 32-bit and 64-bit architecture flavors,
  * keep data 64-bit aligned: use padding for structure members, and use
- * __attribute__ ((aligned (8))) for the entire structure.
+ * __attribute__((aligned(8))) for the entire structure.
  */
 
 /* records: generic header */
@@ -43,6 +43,10 @@ enum {
 	CR_HDR_PGARR,
 	CR_HDR_MM_CONTEXT,
 
+	CR_HDR_FILES = 301,
+	CR_HDR_FD_ENT,
+	CR_HDR_FD_DATA,
+
 	CR_HDR_TAIL = 5001
 };
 
@@ -105,4 +109,30 @@ struct cr_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+struct cr_hdr_files {
+	__u32 objref;		/* identifier for shared objects */
+	__u32 nfds;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_fd_ent {
+	__u32 objref;		/* identifier for shared objects */
+	__s32 fd;
+	__u32 close_on_exec;
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
+	__u64 f_pos;
+	__u64 f_version;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.4.3
