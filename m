From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] c/r: checkpoint and restore FIFOs
Date: Wed, 22 Jul 2009 23:52:05 -0400
Message-ID: <1248321125-10105-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

FIFOs are almost like pipes.

Checkpoints adds the FIFO pathname. The first time the FIFO is found
it also assigns an @objref and dumps the contents in the buffers.

To restore, use the @objref only to determine whether a particular
FIFO has already been restored earlier. Note that it ignores the file
pointer that matches that @objref (unlike with pipes, where that file
corresponds to the other end of the pipe). Instead, it creates a new
FIFO using the saved pathname.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c             |    6 +++
 fs/pipe.c                      |   82 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |    1 +
 include/linux/pipe_fs_i.h      |    2 +
 4 files changed, 89 insertions(+), 2 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index bcdc774..0642649 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -548,6 +548,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_PIPE,
 		.restore = pipe_file_restore,
 	},
+	/* fifo */
+	{
+		.file_name = "FIFO",
+		.file_type = CKPT_FILE_FIFO,
+		.restore = fifo_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/pipe.c b/fs/pipe.c
index 550de0b..00ef5a2 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -811,6 +811,8 @@ pipe_rdwr_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+static struct vfsmount *pipe_mnt __read_mostly;
+
 #ifdef CONFIG_CHECKPOINT
 static int checkpoint_pipe(struct ckpt_ctx *ctx, struct inode *inode)
 {
@@ -858,7 +860,11 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	if (!h)
 		return -ENOMEM;
 
-	h->common.f_type = CKPT_FILE_PIPE;
+	/* fifo and pipe are similar at checkpoint, differ on restore */
+	if (inode->i_sb == pipe_mnt->mnt_sb)
+		h->common.f_type = CKPT_FILE_PIPE;
+	else
+		h->common.f_type = CKPT_FILE_FIFO;
 	h->pipe_objref = objref;
 
 	ret = checkpoint_file_common(ctx, file, &h->common);
@@ -868,6 +874,13 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	if (ret < 0)
 		goto out;
 
+	/* FIFO also needs a file name */
+	if (h->common.f_type == CKPT_FILE_FIFO) {
+		ret = checkpoint_fname(ctx, &file->f_path, &ctx->fs_mnt);
+		if (ret < 0)
+			goto out;
+	}
+
 	if (first)
 		ret = checkpoint_pipe(ctx, inode);
  out:
@@ -959,8 +972,74 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 
 	return file;
 }
+
+struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_pipe *h = (struct ckpt_hdr_file_pipe *) ptr;
+	struct file *file;
+	int first, ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*h) || ptr->f_type != CKPT_FILE_FIFO)
+		return ERR_PTR(-EINVAL);
+
+	if (h->pipe_objref <= 0)
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * If ckpt_obj_fetch() returned ERR_PTR(-EINVAL), this is the
+	 * first time for this fifo.
+	 */
+	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
+	if (!IS_ERR(file))
+		first = 0;
+	else if (PTR_ERR(file) == -EINVAL)
+		first = 1;
+	else
+		return file;
+
+	/*
+	 * To avoid blocking, always open the fifo with O_RDWR;
+	 * then fix flags below.
+	 */
+	file = restore_open_fname(ctx, (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
+	if (IS_ERR(file))
+		return file;
+
+	if ((ptr->f_flags & O_ACCMODE) == O_RDONLY) {
+		file->f_flags = (file->f_flags & ~O_ACCMODE) | O_RDONLY;
+		file->f_mode &= ~FMODE_WRITE;
+	} else if ((ptr->f_flags & O_ACCMODE) == O_WRONLY) {
+		file->f_flags = (file->f_flags & ~O_ACCMODE) | O_WRONLY;
+		file->f_mode &= ~FMODE_READ;
+	} else if ((ptr->f_flags & O_ACCMODE) != O_RDWR) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* first time: add to objhash and restore fifo's contents */
+	if (first) {
+		ret = ckpt_obj_insert(ctx, file, h->pipe_objref, CKPT_OBJ_FILE);
+		if (ret < 0)
+			goto out;
+
+		ret = restore_pipe(ctx, file);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = restore_file_common(ctx, file, ptr);
+ out:
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+
+	return file;
+}
 #else
 #define pipe_file_checkpoint  NULL
+#define fifo_file_checkpoint  NULL
 #endif /* CONFIG_CHECKPOINT */
 
 /*
@@ -1043,7 +1122,6 @@ void free_pipe_info(struct inode *inode)
 	inode->i_pipe = NULL;
 }
 
-static struct vfsmount *pipe_mnt __read_mostly;
 static int pipefs_delete_dentry(struct dentry *dentry)
 {
 	/*
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index e37fa72..4b85956 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -326,6 +326,7 @@ enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
 	CKPT_FILE_PIPE,
+	CKPT_FILE_FIFO,
 	CKPT_FILE_MAX
 };
 
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index e526a12..596403e 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -160,6 +160,8 @@ struct ckpt_ctx;
 struct ckpt_hdr_file;
 extern struct file *pipe_file_restore(struct ckpt_ctx *ctx,
 				      struct ckpt_hdr_file *ptr);
+extern struct file *fifo_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *ptr);
 #endif
 
 #endif
-- 
1.6.0.4
