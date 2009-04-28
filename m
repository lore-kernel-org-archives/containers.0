From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 14/54] Restore open file descriptors
Date: Tue, 28 Apr 2009 19:23:44 -0400
Message-ID: <1240961064-13991-15-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Restore open file descriptors: for each FD read 'struct ckpt_hdr_fd_ent'
and lookup objref in the hash table; if not found (first occurence), read
in 'struct ckpt_hdr_fd_data', create a new FD and register in the hash.
Otherwise attach the file pointer from the hash as an FD.

This patch only handles basic FDs - regular files, directories and also
symbolic links.

Changelog[v14]:
  - Introduce a per file-type restore() callback
  - Revert change to pr_debug(), back to ckpt_debug()
  - Rename:  restore_files() => restore_fd_table()
  - Rename:  ckpt_read_fd_data() => restore_file()
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'hh->parent'

Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c             |  221 +++++++++++++++++++++++++++++++++++++++-
 checkpoint/objhash.c           |    2 +
 checkpoint/process.c           |    4 +
 checkpoint/restart.c           |    2 +-
 include/linux/checkpoint.h     |    7 +-
 include/linux/checkpoint_hdr.h |    3 +-
 mm/filemap.c                   |    1 -
 7 files changed, 232 insertions(+), 8 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 47e5f61..80e1c02 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -15,10 +15,11 @@
 #include <linux/sched.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/fsnotify.h>
+#include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
-
 /**************************************************************************
  * Checkpoint
  */
@@ -320,8 +321,220 @@ static struct file *read_open_fname(struct ckpt_ctx *ctx, int flags, int mode)
 	return file;
 }
 
-struct file *restore_file(struct ckpt_ctx *ctx)
+static int close_all_fds(struct files_struct *files)
+{
+	int *fdtable;
+	int nfds;
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0)
+		return nfds;
+	while (nfds--)
+		sys_close(fdtable[nfds]);
+	kfree(fdtable);
+	return 0;
+}
+
+/**
+ * attach_file - attach a lonely file ptr to a file descriptor
+ * @file: lonely file pointer
+ */
+static int attach_file(struct file *file)
+{
+	int fd = get_unused_fd_flags(0);
+
+	if (fd >= 0) {
+		get_file(file);
+		fsnotify_open(file->f_path.dentry);
+		fd_install(fd, file);
+	}
+	return fd;
+}
+
+#define CKPT_SETFL_MASK  \
+	(O_APPEND | O_NONBLOCK | O_NDELAY | FASYNC | O_DIRECT | O_NOATIME)
+
+int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			struct ckpt_hdr_file *h)
+{
+	int ret;
+
+	/* FIX: need to restore uid, gid, owner etc */
+
+	/* safe to set 1st arg (fd) to 0, as command is F_SETFL */
+	ret = vfs_fcntl(0, F_SETFL, h->f_flags & CKPT_SETFL_MASK, file);
+	if (ret < 0)
+		goto out;
+
+	ret = vfs_llseek(file, h->f_pos, SEEK_SET);
+	if (ret == -ESPIPE)	/* ignore error on non-seekable files */
+		ret = 0;
+ out:
+	return ret;
+}
+
+static struct file *generic_file_restore(struct ckpt_ctx *ctx,
+					 struct ckpt_hdr_file *ptr)
+{
+	struct file *file;
+	int ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
+		return ERR_PTR(-EINVAL);
+
+	file = read_open_fname(ctx, ptr->f_flags, ptr->f_mode);
+	if (IS_ERR(file))
+		return file;
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+	return file;
+}
+
+struct restore_file_ops {
+	char *file_name;
+	enum file_type file_type;
+	struct file * (*restore) (struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_file *ptr);
+};
+
+static struct restore_file_ops restore_file_ops[] = {
+	/* ignored file */
+	{
+		.file_name = "IGNORE",
+		.file_type = CKPT_FILE_IGNORE,
+		.restore = NULL,
+	},
+	/* regular file/directory */
+	{
+		.file_name = "GENERIC",
+		.file_type = CKPT_FILE_GENERIC,
+		.restore = generic_file_restore,
+	},
+};
+
+static struct file *do_restore_file(struct ckpt_ctx *ctx)
+{
+	struct restore_file_ops *ops;
+	struct ckpt_hdr_file *h;
+	struct file *file = ERR_PTR(-EINVAL);
+
+	/*
+	 * All 'struct ckpt_hdr_file_...' begin with ckpt_hdr_file,
+	 * but the actual object depends on the file type. The length
+	 * should never be more than page.
+	 */
+	h = ckpt_read_buf_type(ctx, PAGE_SIZE, CKPT_HDR_FILE);
+	if (IS_ERR(h))
+		return (struct file *) h;
+	ckpt_debug("flags %#x mode %#x type %d\n",
+		 h->f_flags, h->f_mode, h->f_type);
+
+	if (h->f_type >= CKPT_FILE_MAX)
+		goto out;
+
+	ops = &restore_file_ops[h->f_type];
+	BUG_ON(ops->file_type != h->f_type);
+
+	if (file)
+		file = ops->restore(ctx, h);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return file;
+}
+
+void *restore_file(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_file(ctx);
+}
+
+/**
+ * ckpt_read_fd_ent - restore the state of a given file descriptor
+ * @ctx: checkpoint context
+ *
+ * Restores the state of a file descriptor; looks up the objref (in the
+ * header) in the hash table, and if found picks the matching file and
+ * use it; otherwise calls restore_file to restore the file too.
+ */
+static int restore_fd_ent(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_fd_ent *h;
+	struct file *file;
+	int newfd, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FD_ENT);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	ckpt_debug("ref %d fd %d c.o.e %d\n",
+		 h->fd_objref, h->fd_descriptor, h->fd_close_on_exec);
+
+	ret = -EINVAL;
+	if (h->fd_objref <= 0 || h->fd_descriptor < 0)
+		goto out;
+
+	file = ckpt_obj_fetch(ctx, h->fd_objref, CKPT_OBJ_FILE);
+	if (!file)
+		goto out;
+	else if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto out;
+	}
+
+	newfd = attach_file(file);
+	if (newfd < 0) {
+		ret = newfd;
+		goto out;
+	}
+
+	ckpt_debug("newfd got %d wanted %d\n", newfd, h->fd_descriptor);
+
+	/* reposition if newfd isn't desired fd */
+	if (newfd != h->fd_descriptor) {
+		ret = sys_dup2(newfd, h->fd_descriptor);
+		if (ret < 0)
+			goto out;
+		sys_close(newfd);
+	}
+
+	if (h->fd_close_on_exec)
+		set_close_on_exec(h->fd_descriptor, 1);
+
+	ret = 0;
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_fd_table(struct ckpt_ctx *ctx)
 {
-	/* currently only called for mapped files; O_RDONLY works */
-	return read_open_fname(ctx, O_RDONLY, 0);
+	struct ckpt_hdr_fd_table *h;
+	int i, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FD_TABLE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("nfds %d\n", h->fdt_nfds);
+
+	ret = -EMFILE;
+	if (h->fdt_nfds < 0 || h->fdt_nfds > sysctl_nr_open)
+		goto out;
+
+	/* point of no return -- close all file descriptors */
+	ret = close_all_fds(current->files);
+	if (ret < 0)
+		goto out;
+
+	for (i = 0; i < h->fdt_nfds; i++) {
+		ret = restore_fd_ent(ctx);
+		if (ret < 0)
+			break;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
 }
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 9565bcb..5476b0a 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -85,9 +85,11 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_file_drop,
 		.ref_grab = obj_file_grab,
 		.checkpoint = checkpoint_file,
+		.restore = restore_file,
 	},
 };
 
+
 #define CKPT_OBJ_HASH_NBITS  10
 #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 640a27c..a0e8163 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -116,6 +116,10 @@ int restore_task(struct ckpt_ctx *ctx)
 	ckpt_debug("memory: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = restore_fd_table(ctx);
+	ckpt_debug("files: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = restore_thread(ctx);
 	ckpt_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 06224fd..ecf2cf0 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -251,7 +251,7 @@ void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type)
 
 	BUG_ON(!len);
 
-	h = ckpt_read_obj(ctx, len, len);
+	h = ckpt_read_obj(ctx, 0, len);
 	if (IS_ERR(h))
 		return h;
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d6644f0..527a84f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,6 +10,8 @@
  *  distribution for more details.
  */
 
+struct ckpt_ctx;
+
 #include <linux/checkpoint_types.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -80,12 +82,15 @@ extern int restore_mm(struct ckpt_ctx *ctx);
 
 /* files */
 extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
-extern struct file *restore_file(struct ckpt_ctx *ctx);
+extern void *restore_file(struct ckpt_ctx *ctx);
 
 extern int checkpoint_fd_table(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_fd_table(struct ckpt_ctx *ctx);
 
 extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 				  struct ckpt_hdr_file *h);
+extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
+			       struct ckpt_hdr_file *h);
 
 
 /* debugging flags */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index a957e6c..7c87bf8 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -176,7 +176,8 @@ struct ckpt_hdr_fd_ent {
 } __attribute__((aligned(8)));
 
 enum file_type {
-	CKPT_FILE_GENERIC = 1,
+	CKPT_FILE_IGNORE = 0,
+	CKPT_FILE_GENERIC,
 	CKPT_FILE_MAX
 };
 
diff --git a/mm/filemap.c b/mm/filemap.c
index ef5680b..f51b537 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1658,7 +1658,6 @@ int filemap_restore(struct ckpt_ctx *ctx,
 	struct file *file;
 	int ret;
 
-	/* for private mapping using 'read-only' is sufficient */
 	file = restore_file(ctx);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
-- 
1.5.4.3
