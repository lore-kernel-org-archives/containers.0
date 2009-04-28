From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 22/54] Checkpoint open pipes
Date: Tue, 28 Apr 2009 19:23:52 -0400
Message-ID: <1240961064-13991-23-git-send-email-orenl@cs.columbia.edu>
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

A pipe is essentially a double-headed inode with a buffer attached to
it. We checkpoint the pipe buffer only once, as soon as we hit one
side of the pipe, regardless whether it is read- or write- end.

To checkpoint a file descriptor that refers to a pipe (either end), we
first lookup the inode in the hash table:

If not found, it is the first encounter of this pipe. Besides the file
descriptor, we also (a) save the pipe data, and (b) register the pipe
inode in the hash. We save the 'objref' of the inode 'in ->fd_objref'
of the file descriptor. The file descriptor type becomes CKPT_FD_PIPE.

If found, it is the second encounter of this pipe, namely, as we hit
the other end of the same pipe. In this case we need only record the
reference ('objref') to the inode that we had saved before, and the
file descriptor type is changed to CKPT_FD_OBJREF.

The type CKPT_FD_PIPE will indicate to the kernel to create a new pipe;
since both ends are created at the same time, one end will be used,
and the other end will be deposited in the hash table for later use.
The type CKPT_FD_OBJREF will indicate that the corresponding file
descriptor is already setup and registered in the hash using the
'->fd_objref' that it had been assigned.

The format of the pipe data is as follows:

struct ckpt_hdr_fd_pipe {
       __u32 nr_bufs;
}

ckpt_hdr + ckpt_hdr_fd_ent
	ckpt_hdr + ckpt_hdr_fd_data
		ckpt_hdr + ckpt_hdr_fd_pipe		-> # buffers
			ckpt_hdr + ckpt_hdr_buffer	-> 1st buffer
			ckpt_hdr + ckpt_hdr_buffer	-> 2nd buffer
			ckpt_hdr + ckpt_hdr_buffer	-> 3rd buffer
			...

Changelog[v14]:
  - Revert change to pr_debug(), back to ckpt_debug()
  - Test that a pipe's inode != ctx->file's inode to prevent deadlock
  - Discard the 'h.parent' field

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c               |    4 +-
 checkpoint/objhash.c             |   30 ++++++++++
 fs/pipe.c                        |  111 ++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h   |   13 +++++
 include/linux/checkpoint_types.h |    3 +
 include/linux/fs.h               |    2 +
 6 files changed, 161 insertions(+), 2 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 80e1c02..835e39c 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -373,8 +373,8 @@ int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 	return ret;
 }
 
-static struct file *generic_file_restore(struct ckpt_ctx *ctx,
-					 struct ckpt_hdr_file *ptr)
+struct file *generic_file_restore(struct ckpt_ctx *ctx,
+				  struct ckpt_hdr_file *ptr)
 {
 	struct file *file;
 	int ret;
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 5476b0a..8e43432 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -42,10 +42,21 @@ struct ckpt_obj_hash {
 	int next_free_objref;
 };
 
+int checkpoint_bad(struct ckpt_ctx *ctx, void *ptr)
+{
+	BUG();
+}
+
+void *restore_bad(struct ckpt_ctx *ctx)
+{
+	return ERR_PTR(-EINVAL);
+}
+
 /*
  * helper grab/drop functions:
  *   obj_no_{drop,grab}: for objects ignored/skipped
  *   obj_file_{drop,grab}: for file objects
+ *   obj_inode_{drop,grab}: for inode objects
  */
 
 static void obj_no_drop(void *ptr)
@@ -70,6 +81,16 @@ static void obj_file_drop(void *ptr)
 	fput((struct file *) ptr);
 }
 
+static int obj_inode_grab(void *ptr)
+{
+	return (igrab((struct inode *) ptr) ? 0 : -EBADF);
+}
+
+static void obj_inode_drop(void *ptr)
+{
+	iput((struct inode *) ptr);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -87,6 +108,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_file,
 		.restore = restore_file,
 	},
+	/* inode object */
+	{
+		.obj_name = "INODE",
+		.obj_type = CKPT_OBJ_INODE,
+		.ref_drop = obj_inode_drop,
+		.ref_grab = obj_inode_grab,
+		.checkpoint = checkpoint_bad,	/* no c/r at inode level */
+		.restore = restore_bad,		/* no c/r at inode level */
+	},
 };
 
 
diff --git a/fs/pipe.c b/fs/pipe.c
index 13414ec..651a7fc 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -22,6 +22,9 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
 /*
  * We use a start+len construction, which provides full use of the 
  * allocated memory.
@@ -795,6 +798,111 @@ pipe_rdwr_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT
+/* checkpoint_pipebuf - dump contents of a pipe/fifo (assume i_mutex taken) */
+static int checkpoint_pipebuf(struct ckpt_ctx *ctx,
+			      struct pipe_inode_info *pipe)
+{
+	void *kbuf, *addr;
+	int i, ret = 0;
+
+	kbuf = (void *) __get_free_page(GFP_KERNEL);
+	if (!kbuf)
+		return -ENOMEM;
+
+	/* this is a simplified pipe_read() */
+
+	for (i = 0; i < pipe->nrbufs; i++) {
+		int nn = (pipe->curbuf + i) & (PIPE_BUFFERS-1);
+		struct pipe_buffer *pbuf = pipe->bufs + nn;
+		const struct pipe_buf_operations *ops = pbuf->ops;
+
+		ret = ops->confirm(pipe, pbuf);
+		if (ret < 0)
+			break;
+
+		addr = ops->map(pipe, pbuf, 1);
+		memcpy(kbuf, addr + pbuf->offset, pbuf->len);
+		ops->unmap(pipe, pbuf, addr);
+
+		ret = ckpt_write_buffer(ctx, kbuf, pbuf->len);
+		if (ret < 0)
+			break;
+	}
+
+	free_page((unsigned long) kbuf);
+	return ret;
+}
+
+/* checkpoint_pipe - dump pipe (assume i_mutex taken) */
+static int checkpoint_pipe(struct ckpt_ctx *ctx, struct inode *inode)
+{
+	struct ckpt_hdr_file_pipe_state *h;
+	struct pipe_inode_info *pipe = inode->i_pipe;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_PIPE);
+	if (!h)
+		return -ENOMEM;
+
+	h->pipe_nrbufs = pipe->nrbufs;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	return checkpoint_pipebuf(ctx, pipe);
+}
+
+static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_pipe *h;
+	struct inode *inode = file->f_dentry->d_inode;
+	int objref, first, ret;
+
+	/*
+	 * We take the inode's mutex and later will call vfs_write(),
+	 * which also takes an inode's mutex. To avoid deadlock, make
+	 * sure that the two inodes are distinct.
+	 */
+	if (ctx->file->f_dentry->d_inode == inode) {
+		pr_warning("c/r: writing to pipe that is checkpointed "
+			   "may result in a deadlock ... aborting\n");
+		return -EDEADLK;
+	}
+
+	objref = ckpt_obj_lookup_add(ctx, inode, CKPT_OBJ_INODE, &first);
+	if (objref < 0)
+		return objref;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
+	if (!h)
+		return -ENOMEM;
+
+	h->common.f_type = CKPT_FILE_PIPE;
+	h->pipe_objref = objref;
+
+	ret = checkpoint_file_common(ctx, file, &h->common);
+	if (ret < 0)
+		goto out;
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	if (first) {
+		mutex_lock(&inode->i_mutex);
+		ret = checkpoint_pipe(ctx, inode);
+		mutex_unlock(&inode->i_mutex);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+#else
+#define pipe_file_checkpoint  NULL
+#endif /* CONFIG_CHECKPOINT */
+
 /*
  * The file_operations structs are not static because they
  * are also used in linux/fs/fifo.c to do operations on FIFOs.
@@ -811,6 +919,7 @@ const struct file_operations read_pipefifo_fops = {
 	.open		= pipe_read_open,
 	.release	= pipe_read_release,
 	.fasync		= pipe_read_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations write_pipefifo_fops = {
@@ -823,6 +932,7 @@ const struct file_operations write_pipefifo_fops = {
 	.open		= pipe_write_open,
 	.release	= pipe_write_release,
 	.fasync		= pipe_write_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations rdwr_pipefifo_fops = {
@@ -836,6 +946,7 @@ const struct file_operations rdwr_pipefifo_fops = {
 	.open		= pipe_rdwr_open,
 	.release	= pipe_rdwr_release,
 	.fasync		= pipe_rdwr_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 struct pipe_inode_info * alloc_pipe_info(struct inode *inode)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 03846ca..555bbf3 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -61,6 +61,7 @@ enum {
 	CKPT_HDR_FD_TABLE = 301,
 	CKPT_HDR_FD_ENT,
 	CKPT_HDR_FILE,
+	CKPT_HDR_FILE_PIPE,
 
 	CKPT_HDR_TAIL = 5001
 };
@@ -76,6 +77,7 @@ struct ckpt_hdr_objref {
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
 	CKPT_OBJ_FILE,
+	CKPT_OBJ_INODE,
 	CKPT_OBJ_MAX
 };
 
@@ -214,6 +216,7 @@ struct ckpt_hdr_fd_ent {
 enum file_type {
 	CKPT_FILE_IGNORE = 0,
 	CKPT_FILE_GENERIC,
+	CKPT_FILE_PIPE,
 	CKPT_FILE_MAX
 };
 
@@ -232,4 +235,14 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_file_pipe {
+	struct ckpt_hdr_file common;
+	__s32 pipe_objref;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_file_pipe_state {
+	struct ckpt_hdr h;
+	__s32 pipe_nrbufs;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 09d3238..a8dc5b3 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -18,6 +18,9 @@
 #ifdef __KERNEL__
 
 struct ckpt_ctx;
+struct ckpt_hdr;
+struct ckpt_hdr_vma;
+struct ckpt_hdr_file;
 
 #include <linux/list.h>
 #include <linux/path.h>
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2c9ff62..8db8b8e 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2311,6 +2311,8 @@ void inode_set_bytes(struct inode *inode, loff_t bytes);
 
 #ifdef CONFIG_CHECKPOINT
 extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
+extern struct file *generic_file_restart(struct ckpt_ctx *ctx,
+					 struct ckpt_hdr_file *ptr);
 #else
 #define generic_file_checkpoint NULL
 #endif
-- 
1.5.4.3
