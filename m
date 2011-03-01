From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 04/10] Checkpoint/restart unlinked files
Date: Mon, 28 Feb 2011 20:05:10 -0800
Message-ID: <1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Implement checkpoint of unlinked files by relinking them into their
filesystem at:

	<fs root>/lost+found/checkpoint/<file>

Relinking offers many advantages over other means of checkpointing unlinked
files. It's offers substantial performance improvements by leveraging the
snapshotting capabilities of various linux block devices, filesystems, or
differential copying tools like rsync.

In addition to the original path of the file we save the newly-linked
path. This newly-linked path is opened during restart instead of the
original path.

To understand why relinking is extremely useful for checkpoint/restart
consider this simple pseudocode program and a specific example checkpoint
of it:

	a_fd = open("a"); /* example: size of the file at "a" is 1GB */
	link("a", "b");
	unlink("a");
	creat("a");
	             <---- example: checkpoint happens here
	write(a_fd, "bar");

The file "a" is unlinked and a different file has been placed at that
path. a_fd still refers to the inode shared with "b". When we restart
we must re-open the files such that writes to files opened via different
paths are visible. Using links makes this easy.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Cc: Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>
Cc: Aneesh Kumar <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
---
 fs/checkpoint.c                  |   85 ++++++++++++++++++----
 fs/namei.c                       |  148 ++++++++++++++++++++++++++++++++++++++
 fs/pipe.c                        |    2 +-
 include/linux/checkpoint.h       |    3 +-
 include/linux/checkpoint_hdr.h   |    3 +
 include/linux/checkpoint_types.h |    6 ++
 kernel/checkpoint/sys.c          |   12 +++
 7 files changed, 243 insertions(+), 16 deletions(-)

diff --git a/fs/checkpoint.c b/fs/checkpoint.c
index fd539c5..94a2eb4 100644
--- a/fs/checkpoint.c
+++ b/fs/checkpoint.c
@@ -16,6 +16,7 @@
 #include <linux/sched.h>
 #include <linux/file.h>
 #include <linux/namei.h>
+#include <linux/mount.h>
 #include <linux/fs_struct.h>
 #include <linux/fs.h>
 #include <linux/fdtable.h>
@@ -27,6 +28,7 @@
 #include <linux/checkpoint.h>
 #include <linux/eventpoll.h>
 #include <linux/eventfd.h>
+#include <linux/sys-wrapper.h>
 #include <net/sock.h>
 
 /**************************************************************************
@@ -173,6 +175,9 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 	h->f_pos = file->f_pos;
 	h->f_version = file->f_version;
 
+	if (d_unlinked(file->f_dentry))
+		/* Perform post-checkpoint and post-restart unlink() */
+		h->f_restart_flags |= CKPT_RESTART_FILE_F_UNLINK;
 	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
 	if (h->f_credref < 0)
 		return h->f_credref;
@@ -196,16 +201,6 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	struct ckpt_hdr_file_generic *h;
 	int ret;
 
-	/*
-	 * FIXME: when we'll add support for unlinked files/dirs, we'll
-	 * need to distinguish between unlinked filed and unlinked dirs.
-	 */
-	if (d_unlinked(file->f_dentry)) {
-		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
-			 file);
-		return -EBADF;
-	}
-
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
 	if (!h)
 		return -ENOMEM;
@@ -219,6 +214,9 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	if (ret < 0)
 		goto out;
 	ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_file_links(ctx, file);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
@@ -566,12 +564,45 @@ static int ckpt_read_fname(struct ckpt_ctx *ctx, char **fname)
 	return len;
 }
 
+struct dq_unlink_entry {
+	struct ckpt_ctx *ctx;
+	char *fname;
+	bool do_rmdir;
+};
+
+/* Restart failed -- don't unlink fs contents */
+static int restore_dq_dont_unlink(void *dq_data)
+{
+	struct dq_unlink_entry *entry = dq_data;
+
+	kfree(entry->fname);
+	return 0;
+}
+
+/* Restart succeeded -- unlink fd contents */
+static int restore_dq_unlink(void *dq_data)
+{
+	struct dq_unlink_entry *entry = dq_data;
+	int ret;
+
+	if (entry->do_rmdir)
+		ret = kernel_sys_rmdir(entry->fname);
+	else
+		ret = kernel_sys_unlink(entry->fname);
+	if (ret < 0)
+		ckpt_err(entry->ctx, ret, "Could not unlink \"%s\"\n", entry->fname);
+	kfree(entry->fname);
+	return 0;
+}
+
 /**
  * restore_open_fname - read a file name and open a file
  * @ctx: checkpoint context
+ * @do_unlink: unlink the opened file
  * @flags: file flags
  */
-struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
+struct file *restore_open_fname(struct ckpt_ctx *ctx,
+				int do_unlink, int flags)
 {
 	struct file *file;
 	char *fname;
@@ -585,9 +616,35 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
 	if (len < 0)
 		return ERR_PTR(len);
 	ckpt_debug("fname '%s' flags %#x\n", fname, flags);
-
+	if (do_unlink) {
+		kfree(fname);
+		fname = NULL;
+		len = ckpt_read_payload(ctx, (void **)&fname, PATH_MAX,
+					CKPT_HDR_BUFFER);
+		if (len < 0)
+			return ERR_PTR(len);
+		fname[len] = '\0';
+	}
 	file = filp_open(fname, flags, 0);
-	kfree(fname);
+	if (IS_ERR(file)) {
+		ckpt_err(ctx, PTR_ERR(file), "Could not open file \"%s\"\n", fname);
+
+		goto out;
+	}
+	if (do_unlink) {
+		struct dq_unlink_entry entry;
+
+		/* Don't unlink if restart fails. Conversely, only unlink
+		 * if restart succeeds. */
+		ckpt_debug("deferring unlinking of \"%s\"\n", fname);
+		entry.ctx = ctx;
+		entry.do_rmdir = S_ISDIR(file->f_mapping->host->i_mode);
+		entry.fname = fname;
+		deferqueue_add(ctx->err_deferq, &entry, sizeof(entry),
+			       restore_dq_dont_unlink, restore_dq_unlink);
+	} else
+out:
+		kfree(fname);
 
 	return file;
 }
@@ -691,7 +748,7 @@ static struct file *generic_file_restore(struct ckpt_ctx *ctx,
 	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_GENERIC)
 		return ERR_PTR(-EINVAL);
 
-	file = restore_open_fname(ctx, ptr->f_flags);
+	file = restore_open_fname(ctx, !!(ptr->f_restart_flags & CKPT_RESTART_FILE_F_UNLINK), ptr->f_flags);
 	if (IS_ERR(file))
 		return file;
 
diff --git a/fs/namei.c b/fs/namei.c
index 52aa274..6dea3b1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -32,6 +32,11 @@
 #include <linux/fcntl.h>
 #include <linux/device_cgroup.h>
 #include <linux/fs_struct.h>
+#ifdef CONFIG_CHECKPOINT
+#include <linux/sys-wrapper.h>
+#include <linux/deferqueue.h>
+#include <linux/checkpoint.h>
+#endif
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -2527,6 +2532,149 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
 	return sys_linkat(AT_FDCWD, oldname, AT_FDCWD, newname, 0);
 }
 
+#ifdef CONFIG_CHECKPOINT
+
+/* Path relative to the mounted filesystem's root -- not a "global" root or even a namespace root. The unique_name_count is unique for the entire checkpoint. */
+#define CKPT_RELINKAT_FMT "lost+found/checkpoint-%d/relinked-%u"
+
+static int checkpoint_fill_relink_fname(struct ckpt_ctx *ctx,
+					struct file *for_file,
+					char relink_dir_pathname[PATH_MAX],
+					int *lenp)
+{
+	struct path relink_dir_path;
+	char *tmp;
+	int len;
+
+	/* Find path to mount */
+	relink_dir_path.mnt = for_file->f_path.mnt;
+	relink_dir_path.dentry = relink_dir_path.mnt->mnt_root;
+	tmp = d_path(&relink_dir_path, relink_dir_pathname, PATH_MAX);
+	if (IS_ERR(tmp))
+		return PTR_ERR(tmp);
+
+	/* Append path to relinked file. */
+	len = strlen(tmp);
+	if (len <= 0)
+		return -ENOENT;
+	memmove(relink_dir_pathname, tmp, len);
+	tmp = relink_dir_pathname + len - 1;
+	/* Ensure we've got a single dir separator */
+	if (*tmp == '/')
+		tmp++;
+	else {
+		tmp++;
+		*tmp = '/';
+		tmp++;
+		len++;
+	}
+	len += snprintf(tmp, PATH_MAX - len, CKPT_RELINKAT_FMT,
+			ctx->crid, ++ctx->unique_name_count);
+	relink_dir_pathname[len] = '\0';
+	*lenp = len;
+	return 0;
+}
+
+/*
+ * Transform path to path with last element removed. Changes contents of path.
+ */
+static void mkdirname(char *path, char **delim_p)
+{
+	char *p = path;
+
+	if (delim_p)
+		*delim_p = NULL;
+	while (*p)
+		p++;
+	while (p > path && *p != '/')
+		p--;
+	if (*p == '/') {
+		*p = '\0';
+		if (delim_p)
+			*delim_p = p;
+	}
+}
+
+/*
+ * Make the directory used to collect all of the links in. Remove it
+ * if checkpoint fails.
+ */
+static int checkpoint_make_relink_collection(struct ckpt_ctx *ctx,
+					     char *new_path,
+					     int len)
+{
+	char *delim;
+	int ret;
+
+	mkdirname(new_path, &delim);
+	if (!delim || (strlen(new_path) < 2)) /* Need a non-empty dirname */
+		return -ENOENT;
+	ret = kernel_sys_mkdir(new_path, S_IRWXU & ~current_umask());
+	if (delim)
+		*delim = '/';
+	if (ret == -EEXIST) /* already created the collection dir */
+		ret = 0;
+	return ret;
+}
+
+static int checkpoint_file_relink(struct ckpt_ctx *ctx,
+				  struct file *file,
+				  char new_path[PATH_MAX])
+{
+	int ret, len;
+
+	/* 
+	 * Relinking arbitrary files without searching a path
+	 * (which is non-existent if the file is unlinked) requires
+	 * special privileges.
+	 */
+	if (!capable(CAP_DAC_OVERRIDE|CAP_DAC_READ_SEARCH)) {
+		ckpt_err(ctx, -EPERM, "%(T)Relinking unlinked files requires CAP_DAC_{OVERRIDE,READ_SEARCH}\n");
+		return -EPERM;
+	}
+	ret = checkpoint_fill_relink_fname(ctx, file, new_path, &len);
+	if (ret)
+		return ret;
+	ret = checkpoint_make_relink_collection(ctx, new_path, len);
+	if (ret)
+		return ret;
+	ret = do_kern_linkat(&file->f_path, file->f_dentry,
+			     AT_FDCWD, new_path, 0);
+	if (ret)
+		ckpt_err(ctx, ret, "%(T)%(P)%(V)Failed to relink unlinked file.\n", file, file->f_op);
+	return ret;
+}
+
+int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file)
+{
+	char *new_link_path;
+	int ret, len;
+
+	if (!d_unlinked(file->f_dentry))
+		return 0;
+
+	/*
+	 * Unlinked files need at least one hardlink for the post-sys_checkpoint
+	 * filesystem backup/snapshot.
+	 */
+	new_link_path = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!new_link_path)
+		return -ENOMEM;
+	ret = checkpoint_file_relink(ctx, file, new_link_path);
+	if (ret < 0)
+		goto out_free;
+	len = strlen(new_link_path);
+	ret = ckpt_write_obj_type(ctx, NULL, len + 1, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		goto out_free;
+	ret = ckpt_kwrite(ctx, new_link_path, len + 1);
+out_free:
+	kfree(new_link_path);
+
+	return ret;
+}
+#endif /* CONFIG_CHECKPOINT */
+
 /*
  * The worst of all namespace operations - renaming directory. "Perverted"
  * doesn't even start to describe it. Somebody in UCB had a heck of a trip...
diff --git a/fs/pipe.c b/fs/pipe.c
index d79ad44..e66ba97 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1053,7 +1053,7 @@ struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	 * To avoid blocking, always open the fifo with O_RDWR;
 	 * then fix flags below.
 	 */
-	file = restore_open_fname(ctx, (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
+	file = restore_open_fname(ctx, 0, (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
 	if (IS_ERR(file))
 		return file;
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6c0ccfd..8686ce7 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -257,7 +257,8 @@ extern int restore_obj_file_table(struct ckpt_ctx *ctx, int files_objref);
 /* files */
 extern int checkpoint_fname(struct ckpt_ctx *ctx,
 			    struct path *path, struct path *root);
-extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags);
+extern int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file);
+extern struct file *restore_open_fname(struct ckpt_ctx *ctx, int restore_unlinked, int flags);
 
 extern int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file);
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index bb5a749..fdc4884 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -607,6 +607,9 @@ struct ckpt_hdr_file {
 	__u64 f_pos;
 	__u64 f_version;
 	__s32 f_secref;
+
+	__u32 f_restart_flags;
+#define CKPT_RESTART_FILE_F_UNLINK (1<<0)
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_file_generic {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index cf74d3e..7d14676 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -61,6 +61,12 @@ struct ckpt_ctx {
 	struct completion errno_sync;	/* protect errno setting */
 	int errno;			/* errno that caused failure */
 
+	/* relink unlinked files to <mnt_root>/<unique_name> */
+	unsigned int unique_name_count;
+	struct deferqueue_head *err_deferq; /* Deferred cleanup if hit error.
+					     * Run after finalize.
+					     */
+
 	struct list_head pgarr_list;	/* page array to dump VMA contents */
 	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
 	void *scratch_page;             /* scratch buffer for page I/O */
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index 2383db9..a15d37a 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -258,6 +258,13 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	sock_listening_list_free(&ctx->listen_sockets);
 #endif
 
+	/* cleanup after error(s) */
+	if (ctx->err_deferq) {
+		if (ckpt_test_error(ctx))
+			deferqueue_run(ctx->err_deferq);
+		deferqueue_destroy(ctx->err_deferq);
+	}
+
 	kfree(ctx);
 }
 
@@ -306,8 +313,13 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 
  nolog:
 	err = -ENOMEM;
+	ctx->err_deferq = deferqueue_create();
+	if (!ctx->err_deferq)
+		goto err;
+
 	if (ckpt_obj_hash_alloc(ctx) < 0)
 		goto err;
+
 	ctx->deferqueue = deferqueue_create();
 	if (!ctx->deferqueue)
 		goto err;
-- 
1.6.3.3
