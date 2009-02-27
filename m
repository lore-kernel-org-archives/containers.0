From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 5/8] add f_op for checkpointability
Date: Fri, 27 Feb 2009 12:34:31 -0800
Message-ID: <20090227203431.D1E697CB@kernel>
References: <20090227203425.F3B51176@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090227203425.F3B51176@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


We have set up sane defaults for how filesystems should
be checkpointed.  However, as usual in the VFS, there
are specialized places that will always need an ability
to override these defaults.

This adds a new 'file_operations' function for
checkpointing a file.  I did this under the assumption
that we should have a dirt-simple way to make something
(un)checkpointable that fits in with current code.

As you can see in the /dev/null patch in a second, all
that we have to do to make something like /dev/null
supported is add a single "generic" f_op entry.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/checkpoint/ckpt_file.c     |   77 ++++++++++++++++----------
 linux-2.6.git-dave/include/linux/checkpoint.h |    6 ++
 linux-2.6.git-dave/include/linux/fs.h         |    4 +
 3 files changed, 60 insertions(+), 27 deletions(-)

diff -puN checkpoint/ckpt_file.c~f_op-for-checkpointability checkpoint/ckpt_file.c
--- linux-2.6.git/checkpoint/ckpt_file.c~f_op-for-checkpointability	2009-02-27 12:07:39.000000000 -0800
+++ linux-2.6.git-dave/checkpoint/ckpt_file.c	2009-02-27 12:07:39.000000000 -0800
@@ -104,56 +104,79 @@ int cr_explain_file(struct file *file, c
 	return 0;
 }
 
-int cr_file_supported(struct file *file)
+typedef int (do_checkpoint_t)(struct file *, struct cr_ctx *,
+			      struct cr_hdr_fd *);
+
+int generic_file_checkpoint(struct file *file, struct cr_ctx *ctx,
+			 struct cr_hdr_fd *hh)
+{
+	/*
+	 * A NULL hh means to make a trial run not
+	 * actually writing data.  Just determine
+	 * if the file is checkpointable.
+	 */
+	if (!hh)
+		return 0;
+
+	hh->f_flags = file->f_flags;
+	hh->f_mode = file->f_mode;
+	hh->f_pos = file->f_pos;
+	hh->f_version = file->f_version;
+	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
+
+	return 0;
+}
+
+do_checkpoint_t *cr_file_get_func(struct file *file)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct file_system_type *fs_type = inode->i_sb->s_type;
 
-	if (fs_is_cr_able(fs_type))
-		return 0;
+	if (file->f_op->checkpoint)
+		return file->f_op->checkpoint;
+
+	if (!fs_is_cr_able(fs_type))
+		return NULL;
 
 	if (special_file(inode->i_mode))
-		return 0;
+		return NULL;
 
-	return 1;
+	return generic_file_checkpoint;
+}
+
+int cr_file_supported(struct file *file)
+{
+	do_checkpoint_t *func = cr_file_get_func(file);
+
+	if (func)
+		return !func(file, NULL, NULL);
+
+	return 0;
 }
 
 /* cr_write_fd_data - dump the state of a given file pointer */
 static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 {
+	do_checkpoint_t *ckpt_func;
 	struct cr_hdr h;
 	struct cr_hdr_fd *hh = cr_hbuf_get(ctx, sizeof(*hh));
-	struct dentry *dent = file->f_dentry;
-	struct inode *inode = dent->d_inode;
-	enum fd_type fd_type;
 	int ret;
 
 	h.type = CR_HDR_FD_DATA;
 	h.len = sizeof(*hh);
 	h.parent = parent;
 
-	hh->f_flags = file->f_flags;
-	hh->f_mode = file->f_mode;
-	hh->f_pos = file->f_pos;
-	hh->f_version = file->f_version;
-	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
-
-	switch (inode->i_mode & S_IFMT) {
-	case S_IFREG:
-		fd_type = CR_FD_FILE;
-		break;
-	case S_IFDIR:
-		fd_type = CR_FD_DIR;
-		break;
-	default:
-		cr_hbuf_put(ctx, sizeof(*hh));
-		return -EBADF;
-	}
+	ckpt_func = cr_file_get_func(file);
+	ret = -EBADF;
+	if (!ckpt_func)
+		goto out;
 
-	/* FIX: check if the file/dir/link is unlinked */
-	hh->fd_type = fd_type;
+	ret = ckpt_func(file, ctx, hh);
+	if (ret)
+		goto out;
 
 	ret = cr_write_obj(ctx, &h, hh);
+out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	if (ret < 0)
 		return ret;
diff -puN include/linux/checkpoint.h~f_op-for-checkpointability include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~f_op-for-checkpointability	2009-02-27 12:07:39.000000000 -0800
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2009-02-27 12:07:39.000000000 -0800
@@ -70,6 +70,7 @@ extern int cr_obj_add_ref(struct cr_ctx 
 			  unsigned short type, unsigned short flags);
 
 struct cr_hdr;
+struct cr_hdr_fd;
 
 extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
 extern int cr_write_buffer(struct cr_ctx *ctx, void *buf, int len);
@@ -103,9 +104,14 @@ extern int cr_read_files(struct cr_ctx *
 
 int cr_explain_file(struct file *file, char *explain, int left);
 int cr_file_supported(struct file *file);
+int generic_file_checkpoint(struct file *, struct cr_ctx *, struct cr_hdr_fd *);
 
 #else /* !CONFIG_CHECKPOINT_RESTART */
 
+struct cr_hdr_fd;
+
+#define generic_file_checkpoint NULL
+
 static inline int cr_explain_file(struct file *file, char *explain, int left)
 {
 	return 0;
diff -puN include/linux/fs.h~f_op-for-checkpointability include/linux/fs.h
--- linux-2.6.git/include/linux/fs.h~f_op-for-checkpointability	2009-02-27 12:07:39.000000000 -0800
+++ linux-2.6.git-dave/include/linux/fs.h	2009-02-27 12:07:39.000000000 -0800
@@ -1303,6 +1303,9 @@ struct block_device_operations;
 #define HAVE_COMPAT_IOCTL 1
 #define HAVE_UNLOCKED_IOCTL 1
 
+struct cr_ctx;
+struct cr_hdr_fd;
+
 /*
  * NOTE:
  * read, write, poll, fsync, readv, writev, unlocked_ioctl and compat_ioctl
@@ -1335,6 +1338,7 @@ struct file_operations {
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
 	int (*setlease)(struct file *, long, struct file_lock **);
+	int (*checkpoint)(struct file *, struct cr_ctx *, struct cr_hdr_fd *);
 };
 
 struct inode_operations {
_
