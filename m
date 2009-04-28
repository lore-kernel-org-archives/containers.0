From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 12/54] Dump open file descriptors
Date: Tue, 28 Apr 2009 19:23:42 -0400
Message-ID: <1240961064-13991-13-git-send-email-orenl@cs.columbia.edu>
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

Dump the files_struct of a task with 'struct ckpt_hdr_files', followed by
all open file descriptors. Because the 'struct file' corresponding to an
FD can be shared, each they are assigned an objref and registered in the
object hash. A reference to the 'file *' is kept for as long as it lives
in the hash (the hash is only cleaned up at the end of the checkpoint).

For each open FD there is a 'struct ckpt_hdr_fd_ent' with the FD, its
close-on-exec property, and the objref of the corresponding 'file *'.
If the FD is to be saved (first time) then this is followed by a
'struct ckpt_hdr_fd_data' with the FD state. Then will come the next FD
and so on.

Recall that it is assumed that all tasks possibly sharing the file table
are frozen. If this assumption breaks, then the behavior is *undefined*:
checkpoint may fail, or restart from the resulting image file will fail.

This patch provides generic_checkpoint_file(), which is good for
normal files and directories. It does not support yet unlinked files
or directories.

Changelog[v14]:
  - File objects are dumped/restored prior to the first reference
  - Introduce a per file-type restore() callback
  - Use struct file_operations->checkpoint()
  - Put code for generic file descriptors in a separate function
  - Use one CKPT_FILE_GENERIC for both regular files and dirs
  - Revert change to pr_debug(), back to ckpt_debug()
  - Use only unsigned fields in checkpoint headers
  - Rename:  ckpt_write_files() => checkpoint_fd_table()
  - Rename:  ckpt_write_fd_data() => checkpoint_file()
  - Discard field 'h->parent'

Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()

Changelog[v11]:
  - Discard handling of opened symlinks (there is no such thing)
  - ckpt_scan_fds() retries from scratch if hits size limits

Changelog[v9]:
  - Fix a couple of leaks in ckpt_write_files()
  - Drop useless kfree from ckpt_scan_fds()

Changelog[v8]:
  - initialize 'coe' to workaround gcc false warning

Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c             |  210 +++++++++++++++++++++++++++++++++++++++-
 checkpoint/objhash.c           |   23 ++++-
 checkpoint/process.c           |    4 +
 include/linux/checkpoint.h     |   10 ++-
 include/linux/checkpoint_hdr.h |   39 ++++++++
 include/linux/fs.h             |    4 +
 6 files changed, 285 insertions(+), 5 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index a7cf6c3..47e5f61 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -8,9 +8,13 @@
  *  distribution for more details.
  */
 
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DFILE
+
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/file.h>
+#include <linux/fdtable.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -82,9 +86,211 @@ static int dump_fname(struct ckpt_ctx *ctx,
 	return ret;
 }
 
-int checkpoint_file(struct ckpt_ctx *ctx, struct file *file)
+#define CKPT_DEFAULT_FDTABLE  256		/* an initial guess */
+
+/**
+ * scan_fds - scan file table and construct array of open fds
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
+static int scan_fds(struct files_struct *files, int **fdtable)
+{
+	struct fdtable *fdt;
+	int *fds = NULL;
+	int i = 0, n = 0;
+	int tot = CKPT_DEFAULT_FDTABLE;
+
+	/*
+	 * We assume that all tasks possibly sharing the file table are
+	 * frozen (or we are a single process and we checkpoint ourselves).
+	 * Therefore, we can safely proceed after krealloc() from where we
+	 * left off. Otherwise the file table may be modified by another
+	 * task after we scan it. The behavior is this case is undefined,
+	 * and either checkpoint or restart will likely fail.
+	 */
+ retry:
+	fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
+	if (!fds)
+		return -ENOMEM;
+
+	spin_lock(&files->file_lock);
+	rcu_read_lock();
+	fdt = files_fdtable(files);
+	for (/**/; i < fdt->max_fds; i++) {
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
+int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+			   struct ckpt_hdr_file *h)
+{
+	h->f_flags = file->f_flags;
+	h->f_mode = file->f_mode;
+	h->f_pos = file->f_pos;
+	h->f_version = file->f_version;
+
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+
+	return 0;
+}
+
+int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_generic *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	/*
+	 * FIXME: when we'll add support for unlinked files/dirs, we'll
+	 * need to distinguish between unlinked filed and unlinked dirs.
+	 */
+	h->common.f_type = CKPT_FILE_GENERIC;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+	ret = dump_fname(ctx, &file->f_path, &ctx->fs_mnt);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+/* checkpoint_file - dump the state of a given file pointer */
+int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct file *file = (struct file *) ptr;
+
+	if (!file->f_op->checkpoint)
+		return -EBADF;
+	return file->f_op->checkpoint(ctx, file);
+}
+
+/**
+ * ckpt_write_fd_ent - dump the state of a given file descriptor
+ * @ctx: checkpoint context
+ * @files: files_struct pointer
+ * @fd: file descriptor
+ *
+ * Saves the state of the file descriptor; looks up the actual file
+ * pointer in the hash table, and if found saves the matching objref,
+ * otherwise calls ckpt_write_file to dump the file pointer too.
+ */
+static int
+checkpoint_fd_ent(struct ckpt_ctx *ctx, struct files_struct *files, int fd)
+{
+	struct ckpt_hdr_fd_ent *h;
+	struct file *file = NULL;
+	struct fdtable *fdt;
+	int objref, ret;
+	int coe = 0;	/* avoid gcc warning */
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FD_ENT);
+	if (!h)
+		return -ENOMEM;
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
+	ret = -EBADF;
+	if (!file)
+		goto out;
+
+	/*
+	 * if seen first time, this will add 'file' to the objhash, keep
+	 * a reference to it, dump its state while at it.
+	 */
+	objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
+	ckpt_debug("fd %d objref %d file %p coe %d)\n", fd, objref, file, coe);
+	if (objref < 0) {
+		ret = objref;
+		goto out;
+	}
+
+	h->fd_objref = objref;
+	h->fd_descriptor = fd;
+	h->fd_close_on_exec = coe;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+out:
+	ckpt_hdr_put(ctx, h);
+	if (file)
+		fput(file);
+	return ret;
+}
+
+int checkpoint_fd_table(struct ckpt_ctx *ctx, struct task_struct *t)
 {
-	return dump_fname(ctx, &file->f_path, &ctx->fs_mnt);
+	struct ckpt_hdr_fd_table *h;
+	struct files_struct *files;
+	int *fdtable = NULL;
+	int nfds, n, ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FD_TABLE);
+	if (!h)
+		return -ENOMEM;
+
+	files = get_files_struct(t);
+
+	nfds = scan_fds(files, &fdtable);
+	if (nfds < 0) {
+		ret = nfds;
+		goto out;
+	}
+
+	h->fdt_nfds = nfds;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ckpt_debug("nfds %d\n", nfds);
+	for (n = 0; n < nfds; n++) {
+		ret = checkpoint_fd_ent(ctx, files, fdtable[n]);
+		if (ret < 0)
+			break;
+	}
+
+ out:
+	kfree(fdtable);
+	put_files_struct(files);
+	return ret;
 }
 
 /**************************************************************************
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 076a3a3..9565bcb 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -13,6 +13,7 @@
 
 #include <linux/kernel.h>
 #include <linux/hash.h>
+#include <linux/file.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -44,6 +45,7 @@ struct ckpt_obj_hash {
 /*
  * helper grab/drop functions:
  *   obj_no_{drop,grab}: for objects ignored/skipped
+ *   obj_file_{drop,grab}: for file objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -56,6 +58,18 @@ static int obj_no_grab(void *ptr)
 	return 0;
 }
 
+/* helper drop/grab functions */
+static int obj_file_grab(void *ptr)
+{
+	get_file((struct file *) ptr);
+	return 0;
+}
+
+static void obj_file_drop(void *ptr)
+{
+	fput((struct file *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -64,9 +78,16 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_no_drop,
 		.ref_grab = obj_no_grab,
 	},
+	/* file object */
+	{
+		.obj_name = "FILE",
+		.obj_type = CKPT_OBJ_FILE,
+		.ref_drop = obj_file_drop,
+		.ref_grab = obj_file_grab,
+		.checkpoint = checkpoint_file,
+	},
 };
 
-
 #define CKPT_OBJ_HASH_NBITS  10
 #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 7adb842..640a27c 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -61,6 +61,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("memory: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = checkpoint_fd_table(ctx, t);
+	ckpt_debug("files: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_thread(ctx, t);
 	ckpt_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7845172..d6644f0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -79,9 +79,14 @@ extern int restore_mm(struct ckpt_ctx *ctx);
 	 VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 /* files */
-extern int checkpoint_file(struct ckpt_ctx *ctx, struct file *file);
+extern int checkpoint_file(struct ckpt_ctx *ctx, void *ptr);
 extern struct file *restore_file(struct ckpt_ctx *ctx);
 
+extern int checkpoint_fd_table(struct ckpt_ctx *ctx, struct task_struct *t);
+
+extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
+				  struct ckpt_hdr_file *h);
+
 
 /* debugging flags */
 #define CKPT_DBASE	0x1		/* anything */
@@ -90,8 +95,9 @@ extern struct file *restore_file(struct ckpt_ctx *ctx);
 #define CKPT_DMEM	0x8		/* memory state */
 #define CKPT_DPAGE	0x10		/* memory pages */
 #define CKPT_DOBJ	0x20		/* shared objects */
+#define CKPT_DFILE	0x40		/* files and filesystem */
 
-#define CKPT_DDEFAULT	0xf		/* default debug level */
+#define CKPT_DDEFAULT	0x4f		/* default debug level */
 
 #ifndef CKPT_DFLAG
 #define CKPT_DFLAG	0x0		/* nothing */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0eb4acb..a957e6c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -56,6 +56,10 @@ enum {
 	CKPT_HDR_PGARR,
 	CKPT_HDR_MM_CONTEXT,
 
+	CKPT_HDR_FD_TABLE = 301,
+	CKPT_HDR_FD_ENT,
+	CKPT_HDR_FILE,
+
 	CKPT_HDR_TAIL = 5001
 };
 
@@ -69,6 +73,7 @@ struct ckpt_hdr_objref {
 /* shared objects types */
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_FILE,
 	CKPT_OBJ_MAX
 };
 
@@ -156,4 +161,38 @@ struct ckpt_hdr_pgarr {
 	__u64 nr_pages;		/* number of pages to saved */
 } __attribute__((aligned(8)));
 
+/* file system */
+struct ckpt_hdr_fd_table {
+	struct ckpt_hdr h;
+	__s32 fdt_nfds;
+} __attribute__((aligned(8)));
+
+/* file descriptors */
+struct ckpt_hdr_fd_ent {
+	struct ckpt_hdr h;
+	__s32 fd_objref;
+	__s32 fd_descriptor;
+	__u32 fd_close_on_exec;
+} __attribute__((aligned(8)));
+
+enum file_type {
+	CKPT_FILE_GENERIC = 1,
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
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_generic {
+	struct ckpt_hdr_file common;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8ff37b3..2c9ff62 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2309,7 +2309,11 @@ void inode_sub_bytes(struct inode *inode, loff_t bytes);
 loff_t inode_get_bytes(struct inode *inode);
 void inode_set_bytes(struct inode *inode, loff_t bytes);
 
+#ifdef CONFIG_CHECKPOINT
+extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+#else
 #define generic_file_checkpoint NULL
+#endif
 
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
-- 
1.5.4.3
