From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 19/36] Checkpoint open pipes
Date: Tue,  7 Apr 2009 08:27:27 -0400
Message-ID: <1239107264-21775-20-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

A pipe is essentially a double-headed inode with a buffer attached to
it. We checkpoint the pipe buffer only once, as soon as we hit one
side of the pipe, regardless whether it is read- or write- end.

To checkpoint a file descriptor that refers to a pipe (either end), we
first lookup the inode in the hash table:

If not found, it is the first encounter of this pipe. Besides the file
descriptor, we also (a) save the pipe data, and (b) register the pipe
inode in the hash. We save the 'objref' of the inode 'in ->fd_objref'
of the file descriptor. The file descriptor type becomes CR_FD_PIPE.

If found, it is the second encounter of this pipe, namely, as we hit
the other end of the same pipe. In this case we need only record the
reference ('objref') to the inode that we had saved before, and the
file descriptor type is changed to CR_FD_OBJREF.

The type CR_FD_PIPE will indicate to the kernel to create a new pipe;
since both ends are created at the same time, one end will be used,
and the other end will be deposited in the hash table for later use.
The type CR_FD_OBJREF will indicate that the corresponding file
descriptor is already setup and registered in the hash using the
'->fd_objref' that it had been assigned.

The format of the pipe data is as follows:

struct cr_hdr_fd_pipe {
       __u32 nr_bufs;
}

cr_hdr + cr_hdr_fd_ent
	cr_hdr + cr_hdr_fd_data
		cr_hdr + cr_hdr_fd_pipe		-> # buffers
			cr_hdr + cr_hdr_buffer	-> 1st buffer
			cr_hdr + cr_hdr_buffer	-> 2nd buffer
			cr_hdr + cr_hdr_buffer	-> 3rd buffer
			...

Changelog[v14]:
  - Use 'fd_type' instead of 'hh->fd_objref' in cr_write_fd_data()
  - Revert change to pr_debug(), back to cr_debug()
  - Discard the 'h.parent' field
  - Check whether calls to cr_hbuf_get() fail
  - Test that a pipe's inode != ctx->file's inode to prevent deadlock

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/ckpt_file.c         |    2 +
 fs/pipe.c                      |  119 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    8 ++-
 3 files changed, 128 insertions(+), 1 deletions(-)

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index f813d02..688cff7 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -12,6 +12,7 @@
 #include <linux/sched.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -72,6 +73,7 @@ int cr_scan_fds(struct files_struct *files, int **fdtable)
 	return n;
 }
 
+
 static int cr_write_file_generic(struct cr_ctx *ctx, struct file *file,
 				 struct cr_hdr_file *hh)
 {
diff --git a/fs/pipe.c b/fs/pipe.c
index 14f502b..c2a2ff1 100644
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
@@ -771,6 +774,119 @@ pipe_rdwr_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+/* cr_write_pipebuf - dump contents of a pipe/fifo (assume i_mutex taken) */
+static int cr_write_pipebuf(struct cr_ctx *ctx, struct pipe_inode_info *pipe)
+{
+	struct cr_hdr h;
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
+		h.type = CR_HDR_BUFFER;
+		h.len = pbuf->len;
+
+		ret = cr_write_obj(ctx, &h, kbuf);
+		if (ret < 0)
+			break;
+	}
+
+	free_page((unsigned long) kbuf);
+	return ret;
+}
+
+/* cr_write_pipe - dump pipe (assume i_mutex taken) */
+static int cr_write_pipe(struct cr_ctx *ctx, struct inode *inode)
+{
+	struct cr_hdr h;
+	struct cr_hdr_fd_pipe *hh;
+	struct pipe_inode_info *pipe = inode->i_pipe;
+	int ret;
+
+	h.type = CR_HDR_FD_PIPE;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	hh->nr_bufs = pipe->nrbufs;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	return cr_write_pipebuf(ctx, pipe);
+}
+
+static int pipe_file_checkpoint(struct cr_ctx *ctx,
+				struct file *file, struct cr_hdr_file *hh)
+{
+	struct cr_hdr h;
+	struct inode *inode = file->f_dentry->d_inode;
+	int new, objref;
+	int ret;
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
+	h.type = CR_HDR_FILE;
+	h.len = sizeof(*hh);
+
+	new = cr_obj_add_ptr(ctx, inode, &objref, CR_OBJ_INODE, 0);
+	cr_debug("objref %d inode %p new %d\n", objref, inode, new);
+	if (new < 0)
+		return new;
+
+	/*
+	 * On the first instance save this end as CR_FD_PIPE together
+	 * with the state of the pipe. On the second instance skip the
+	 * state and save the other end as CR_FD_OBJREF (to indicate
+	 * on restart that the corresponding pipe has been created).
+	 */
+	hh->fd_type = (new ? CR_FD_PIPE : CR_FD_OBJREF);
+	hh->fd_objref = objref;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		return ret;
+
+	if (new) {
+		mutex_lock(&inode->i_mutex);
+		ret = cr_write_pipe(ctx, inode);
+		mutex_unlock(&inode->i_mutex);
+	}
+
+	return ret;
+}
+
+
 /*
  * The file_operations structs are not static because they
  * are also used in linux/fs/fifo.c to do operations on FIFOs.
@@ -787,6 +903,7 @@ const struct file_operations read_pipefifo_fops = {
 	.open		= pipe_read_open,
 	.release	= pipe_read_release,
 	.fasync		= pipe_read_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations write_pipefifo_fops = {
@@ -799,6 +916,7 @@ const struct file_operations write_pipefifo_fops = {
 	.open		= pipe_write_open,
 	.release	= pipe_write_release,
 	.fasync		= pipe_write_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 const struct file_operations rdwr_pipefifo_fops = {
@@ -812,6 +930,7 @@ const struct file_operations rdwr_pipefifo_fops = {
 	.open		= pipe_rdwr_open,
 	.release	= pipe_rdwr_release,
 	.fasync		= pipe_rdwr_fasync,
+	.checkpoint	= pipe_file_checkpoint,
 };
 
 struct pipe_inode_info * alloc_pipe_info(struct inode *inode)
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 1bf1509..d61f0b4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -58,6 +58,7 @@ enum {
 	CR_HDR_FD_TABLE = 301,
 	CR_HDR_FD_ENT,
 	CR_HDR_FILE,
+	CR_HDR_FD_PIPE,
 
 	CR_HDR_TAIL = 5001
 };
@@ -175,7 +176,8 @@ struct cr_hdr_fd_ent {
 /* fd types */
 enum  fd_type {
 	CR_FD_OBJREF = 1,
-	CR_FD_GENERIC
+	CR_FD_GENERIC,
+	CR_FD_PIPE,
 };
 
 struct cr_hdr_file {
@@ -188,4 +190,8 @@ struct cr_hdr_file {
 	__u64 f_version;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_fd_pipe {
+	__s32 nr_bufs;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.4.3
