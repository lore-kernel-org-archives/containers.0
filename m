From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc][PATCH 15/23] Checkpoint open pipes
Date: Fri, 20 Mar 2009 14:47:40 -0400
Message-ID: <1237574868-3371-16-git-send-email-orenl@cs.columbia.edu>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237574868-3371-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
---
 checkpoint/ckpt_file.c         |  119 +++++++++++++++++++++++++++++++++++++++-
 include/linux/checkpoint_hdr.h |    6 ++
 2 files changed, 124 insertions(+), 1 deletions(-)

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index bb9f96f..7444402 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -12,6 +12,7 @@
 #include <linux/sched.h>
 #include <linux/file.h>
 #include <linux/fdtable.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -72,6 +73,93 @@ int cr_scan_fds(struct files_struct *files, int **fdtable)
 	return n;
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
+	/* this is a simplified fs/pipe.c:read_pipe() */
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
+/* cr_write_fd_fifo - for pipe */
+static int cr_write_fd_pipe(struct cr_ctx *ctx, struct file *file)
+{
+	struct inode *inode = file->f_dentry->d_inode;
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
+	mutex_lock(&inode->i_mutex);
+	ret = cr_write_pipe(ctx, inode);
+	mutex_unlock(&inode->i_mutex);
+
+	return ret;
+}
+
 /* cr_write_fd_file - for regular files, directories, symbolic links */
 static int cr_write_fd_file(struct cr_ctx *ctx, struct file *file)
 {
@@ -86,11 +174,32 @@ static inline enum fd_type cr_inode_to_fdtype(struct inode *inode)
 		return CR_FD_FILE;
 	case S_IFDIR:
 		return CR_FD_DIR;
+	case S_IFIFO:
+		if (inode->i_sb->s_magic == PIPEFS_MAGIC)
+			return CR_FD_PIPE;	/* pipe */
 	}
 	/* file type unsupported */
 	return -EBADF;
 }
 
+static int
+cr_inode_to_objref(struct cr_ctx *ctx, struct inode *inode, int type, int *new)
+{
+	int objref = 0;
+	int newobj = 1;
+
+	if (type == CR_FD_PIPE) {
+		newobj = cr_obj_add_ptr(ctx, inode, &objref, CR_OBJ_INODE, 0);
+		pr_debug("objref %d inode %p new %d\n", objref, inode, newobj);
+	}
+
+	if (newobj < 0)
+		return newobj;
+
+	*new = newobj;
+	return objref;
+}
+
 /* cr_write_file - dump the state of a given file pointer */
 static int cr_write_file(struct cr_ctx *ctx, struct file *file)
 {
@@ -98,6 +207,7 @@ static int cr_write_file(struct cr_ctx *ctx, struct file *file)
 	struct cr_hdr_file *hh;
 	struct inode *inode = file->f_dentry->d_inode;
 	enum fd_type fd_type;
+	int new = 0;  /* pacitfy gcc */
 	int ret;
 
 	h.type = CR_HDR_FILE;
@@ -119,8 +229,12 @@ static int cr_write_file(struct cr_ctx *ctx, struct file *file)
 		return fd_type;
 	}
 
+	hh->fd_objref = cr_inode_to_objref(ctx, inode, hh->fd_type, &new);
+	pr_debug("type %d objref %d (%d)\n", hh->fd_type, hh->fd_objref, new);
+	if (!new)
+		fd_type = CR_FD_OBJREF;
+
 	hh->fd_type = fd_type;
-	hh->fd_objref = 0;
 
 	/* FIX: check if the inode is unlinked */
 
@@ -137,6 +251,9 @@ static int cr_write_file(struct cr_ctx *ctx, struct file *file)
 	case CR_FD_DIR:
 		ret = cr_write_fd_file(ctx, file);
 		break;
+	case CR_FD_PIPE:
+		ret = cr_write_fd_pipe(ctx, file);
+		break;
 	default:
 		BUG();
 	}
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index d16e371..68c1f6b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -57,6 +57,7 @@ enum {
 	CR_HDR_FD_TABLE = 301,
 	CR_HDR_FD_ENT,
 	CR_HDR_FILE,
+	CR_HDR_FD_PIPE,
 
 	CR_HDR_TAIL = 5001
 };
@@ -151,6 +152,7 @@ enum  fd_type {
 	CR_FD_OBJREF = 1,
 	CR_FD_FILE,
 	CR_FD_DIR,
+	CR_FD_PIPE,
 };
 
 struct cr_hdr_file {
@@ -163,4 +165,8 @@ struct cr_hdr_file {
 	__u64 f_version;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_fd_pipe {
+	__s32 nr_bufs;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
-- 
1.5.4.3
