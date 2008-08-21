From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 9/9] File descriprtors (restore)
Date: Wed, 20 Aug 2008 23:07:47 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0808202307270.17436@takamine.ncl.cs.columbia.edu>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202251500.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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


Restore open file descriptors: for each FD read 'struct cr_hdr_fd_ent'
and lookup tag in the hash table; if not found (first occurence), read
in 'struct cr_hdr_fd_data', create a new FD and register in the hash.
Otherwise attach the file pointer from the hash as an FD.

This patch only handles basic FDs - regular files, directories and also
symbolic links.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
  checkpoint/Makefile     |    2 +-
  checkpoint/checkpoint.c |    3 +
  checkpoint/ckpt.h       |    6 +-
  checkpoint/restart.c    |    3 +
  checkpoint/rstr_file.c  |  202 +++++++++++++++++++++++++++++++++++++++++++++++
  5 files changed, 213 insertions(+), 3 deletions(-)
  create mode 100644 checkpoint/rstr_file.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 179175b..fd073cd 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -1,3 +1,3 @@
  obj-y += sys.o checkpoint.o restart.o objhash.o \
-	ckpt_mem.o rstr_mem.o ckpt_file.o
+	ckpt_mem.o rstr_mem.o ckpt_file.o rstr_file.o
  obj-$(CONFIG_X86) += ckpt_x86.o rstr_x86.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index bf868ae..fe30ebb 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -172,6 +172,9 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
  		ret = cr_write_mm(ctx, t);
  	cr_debug("memory: ret %d\n", ret);
  	if (!ret)
+		ret = cr_write_files(ctx, t);
+	cr_debug("files: ret %d\n", ret);
+	if (!ret)
  		ret = cr_write_thread(ctx, t);
  	cr_debug("thread: ret %d\n", ret);
  	if (!ret)
diff --git a/checkpoint/ckpt.h b/checkpoint/ckpt.h
index ef2f74d..b83dea1 100644
--- a/checkpoint/ckpt.h
+++ b/checkpoint/ckpt.h
@@ -83,11 +83,13 @@ int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
  int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
  int cr_read_str(struct cr_ctx *ctx, void *str, int n);

+int do_checkpoint(struct cr_ctx *ctx);
  int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
-int cr_read_mm(struct cr_ctx *ctx);
+int cr_write_files(struct cr_ctx *ctx, struct task_struct *t);

-int do_checkpoint(struct cr_ctx *ctx);
  int do_restart(struct cr_ctx *ctx);
+int cr_read_mm(struct cr_ctx *ctx);
+int cr_read_files(struct cr_ctx *ctx);

  #define cr_debug(fmt, args...)  \
  	pr_debug("[CR:%s] " fmt, __func__, ## args)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 81ce0a4..4c2ef32 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -186,6 +186,9 @@ static int cr_read_task(struct cr_ctx *ctx)
  		ret = cr_read_mm(ctx);
  	cr_debug("memory: ret %d\n", ret);
  	if (!ret)
+		ret = cr_read_files(ctx);
+	cr_debug("files: ret %d\n", ret);
+	if (!ret)
  		ret = cr_read_thread(ctx);
  	cr_debug("thread: ret %d\n", ret);
  	if (!ret)
diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
new file mode 100644
index 0000000..a30d65d
--- /dev/null
+++ b/checkpoint/rstr_file.c
@@ -0,0 +1,202 @@
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
+#include <linux/fsnotify.h>
+#include <linux/syscalls.h>
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+#include "ckpt_file.h"
+
+static int cr_close_all_fds(struct files_struct *files)
+{
+	int *fdtable;
+	int n;
+
+	do {
+		n = cr_scan_fds(files, &fdtable);
+		if (n < 0)
+			return n;
+		while (n--)
+			sys_close(fdtable[n]);
+		kfree(fdtable);
+	} while (n != -1);
+
+	return 0;
+}
+
+/**
+ * cr_attach_file - attach a lonely file ptr to a file descriptor
+ * @file: lonely file pointer
+ */
+static int cr_attach_file(struct file *file)
+{
+	int fd = get_unused_fd_flags(0);
+
+	if (fd >= 0) {
+		fsnotify_open(file->f_path.dentry);
+		fd_install(fd, file);
+	}
+	return fd;
+}
+
+#define CR_SETFL_MASK (O_APPEND|O_NONBLOCK|O_NDELAY|FASYNC|O_DIRECT|O_NOATIME)
+
+/* cr_read_fd_data - restore the state of a given file pointer */
+static int
+cr_read_fd_data(struct cr_ctx *ctx, struct files_struct *files, int ptag)
+{
+	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file;
+	char *fname = NULL;
+	int fd, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_DATA);
+	cr_debug("ret %d ptag %d flags %#x mode %#x how %d\n",
+		 ret, ptag, hh->f_flags, hh->f_mode, hh->how);
+	if (ret < 0)
+		return ret;
+	if (ret != ptag)
+		return -EINVAL;
+	/* FIX: more sanity checks on f_flags, f_mode etc */
+
+	switch (hh->how) {
+	case CR_FD_FILE:
+	case CR_FD_DIR:
+	case CR_FD_LINK:
+		fname = ctx->tbuf;
+		ret = cr_read_str(ctx, fname, PAGE_SIZE);
+		if (ret < 0)
+			return ret;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	cr_debug("open '%s' flags %#lx\n", fname, (unsigned long)hh->f_flags);
+	file = filp_open(fname, hh->f_flags, hh->f_mode);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	/* FIX: need to restore uid, gid, owner etc */
+
+	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
+	if (fd < 0) {
+		filp_close(file, NULL);
+		return fd;
+	}
+
+	/* register new <tag, file> tuple in hash table */
+	ret = cr_obj_add_tag(ctx, (void *) file, ptag, CR_OBJ_FILE, 0);
+
+	if (!ret)
+		ret = sys_fcntl(fd, F_SETFL, hh->f_flags & CR_SETFL_MASK);
+	if (ret >= 0)
+		ret = vfs_llseek(file, hh->f_pos, SEEK_SET);
+	if (ret == -ESPIPE)	/* ignore error on non-seekable files */
+		ret = 0;
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return (ret < 0 ? ret : fd);
+}
+
+/**
+ * cr_read_fd_ent - restore the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @ptag: parent tag
+ * 
+ * Restore the state of a file descriptor; look up the tag (in the header)
+ * in the hash table, and if found pick the matching file pointer and use
+ * it; otherwise call cr_read_fd_data to restore the file pointer too.
+ */
+static int
+cr_read_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int ptag)
+{
+	struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct file *file;
+	int newfd, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_ENT);
+	cr_debug("ret %d ptag %d tag %d fd %d\n", ret, ptag, hh->tag, hh->fd);
+	if (ret < 0)
+		return ret;
+	if (ret != ptag)
+		return -EINVAL;
+	cr_debug("tag %d close_on_exec %d\n", hh->tag, hh->close_on_exec);
+	if (hh->tag <= 0)
+		return -EINVAL;
+
+	file = cr_obj_get_by_tag(ctx, hh->tag, CR_OBJ_FILE);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	if (file) {
+		newfd = cr_attach_file(file);
+		if (newfd < 0)
+			return newfd;
+		get_file(file);
+	} else {
+		/* create new file pointer (and register in hash table) */
+		newfd = cr_read_fd_data(ctx, files, hh->tag);
+		if (newfd < 0)
+			return newfd;
+	}
+
+	cr_debug("newfd got %d wanted %d\n", newfd, hh->fd);
+
+	/* if newfd isn't desired fd, use dup2() to relocated it */
+	if (newfd != hh->fd) {
+		ret = sys_dup2(newfd, hh->fd);
+		sys_close(newfd);
+	}
+
+	if (ret >= 0 && hh->close_on_exec)
+		set_close_on_exec(hh->fd, 1);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return (ret < 0 ? ret : 0);
+}
+
+int cr_read_files(struct cr_ctx *ctx)
+{
+	struct cr_hdr_files *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct files_struct *files = current->files;
+	int n, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FILES);
+	if (ret < 0)
+		return ret;
+#if 0	/* activate when containers are used */
+	if (ret != task_pid_vnr(current))
+		return -EINVAL;
+#endif
+	cr_debug("tag %d nfds %d\n", hh->tag, hh->nfds);
+	if (hh->tag < 0 || hh->nfds < 0)
+		return -EINVAL;
+
+	/* point of no return -- close all file descriptors */
+	ret = cr_close_all_fds(files);
+	if (ret < 0)
+		return ret;
+
+	for (n = 0; n < hh->nfds; n++) {
+		ret = cr_read_fd_ent(ctx, files, hh->tag);
+		if (ret < 0)
+			break;
+	}
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
-- 
1.5.4.3
