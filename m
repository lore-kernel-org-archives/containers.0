From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 23/54] Restore open pipes
Date: Tue, 28 Apr 2009 19:23:53 -0400
Message-ID: <1240961064-13991-24-git-send-email-orenl@cs.columbia.edu>
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

When seeing a CKPT_FD_PIPE file type, we create a new pipe and thus
have two file pointers (read- and write- ends). We only use one of
them, depending on which side was checkpointed first. We register the
file pointer of the other end in the hash table, with the 'objref'
given for this pipe from the checkpoint, deposited for later use. At
this point we also restore the contents of the pipe buffers.

When the other end arrives, it will have file type CKPT_FD_OBJREF. We
will then use the corresponding 'objref' to retrieve the file pointer
from the hash table, and attach it to the process.

Note the difference from the checkpoint logic: during checkpoint we
placed the _inode_ of the pipe in the hash table, while during restart
we place the resulting _file_ in the hash table.

We restore the pipe contents we manually allocation and attaching
buffers to the pipe; (alternatively we could read the data from the
image file and then write it into the pipe, or use splice() syscall).

Changelog[v14]:
  - Discard the 'h.parent' field
  - Check whether calls to ckpt_hbuf_get() fail

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/files.c        |    7 ++
 fs/pipe.c                 |  136 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pipe_fs_i.h |    9 +++
 3 files changed, 152 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 835e39c..c6a946b 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -17,6 +17,7 @@
 #include <linux/fdtable.h>
 #include <linux/fsnotify.h>
 #include <linux/syscalls.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -415,6 +416,12 @@ static struct restore_file_ops restore_file_ops[] = {
 		.file_type = CKPT_FILE_GENERIC,
 		.restore = generic_file_restore,
 	},
+	/* pipe */
+	{
+		.file_name = "PIPE",
+		.file_type = CKPT_FILE_PIPE,
+		.restore = pipe_file_restore,
+	},
 };
 
 static struct file *do_restore_file(struct ckpt_ctx *ctx)
diff --git a/fs/pipe.c b/fs/pipe.c
index 651a7fc..ab2de3c 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -899,6 +899,142 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+
+/* restore_pipebuf - restore contents of a pipe/fifo (assume i_mutex taken) */
+static int restore_pipebuf(struct ckpt_ctx *ctx,
+			   struct pipe_inode_info *pipe, int nbufs)
+{
+	void *kbuf, *addr;
+	int i, len, ret = 0;
+
+	kbuf = (void *) __get_free_page(GFP_KERNEL);
+	if (!kbuf)
+		return -ENOMEM;
+
+	for (i = 0; i < nbufs; i++) {
+		struct pipe_buffer *pbuf = pipe->bufs + i;
+		struct page *page;
+
+		len = _ckpt_read_nbuffer(ctx, kbuf, PAGE_SIZE);
+		if (len < 0) {
+			ret = len;
+			break;
+		}
+		page = alloc_page(GFP_HIGHUSER);
+		if (!page) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		addr = kmap_atomic(page, KM_USER0);
+		memcpy(addr, kbuf, len);
+		kunmap_atomic(addr, KM_USER0);
+
+		pbuf->page = page;
+		pbuf->ops = &anon_pipe_buf_ops;
+		pbuf->offset = 0;
+		pbuf->len = len;
+		pipe->nrbufs++;
+		pipe->tmp_page = NULL;
+	}
+
+	free_page((unsigned long) kbuf);
+	return ret;
+}
+
+/* restore_pipe - restore pipe (assume i_mutex taken) */
+static int restore_pipe(struct ckpt_ctx *ctx, struct file *file)
+{
+	struct ckpt_hdr_file_pipe_state *h;
+	struct inode *inode;
+	int nbufs, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_FILE_PIPE);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	nbufs = h->pipe_nrbufs;
+	ckpt_hdr_put(ctx, h);
+
+	if (nbufs < 0 || nbufs > PIPE_BUFFERS)
+		return -EINVAL;
+
+	inode = file->f_dentry->d_inode;
+	mutex_lock(&inode->i_mutex);
+	ret = restore_pipebuf(ctx, inode->i_pipe, nbufs);
+	mutex_unlock(&inode->i_mutex);
+
+	return ret;
+}
+
+/* restore a pipe */
+struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
+{
+	struct ckpt_hdr_file_pipe *h = (struct ckpt_hdr_file_pipe *) ptr;
+	struct file *file;
+	int fds[2], which, ret;
+
+	if (ptr->h.type != CKPT_HDR_FILE  ||
+	    ptr->h.len != sizeof(*h) || ptr->f_type != CKPT_FILE_PIPE)
+		return ERR_PTR(-EINVAL);
+
+	if (h->pipe_objref <= 0)
+		return ERR_PTR(-EINVAL);
+
+	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file))
+		return file;
+	/*
+	 * If ckpt_obj_fetch() returned NULL, then this is the first
+	 * time we see this pipe so need to restore the contents.
+	 * Otherwise, use the file pointer skip forward.
+	 */
+	if (!file) {
+		/* first encounter of this pipe: create it */
+		ret = do_pipe_flags(fds, 0);
+		if (ret < 0)
+			return file;
+
+		which = (ptr->f_flags & O_WRONLY ? 1 : 0);
+
+		/*
+		 * Below we return the file corersponding to one side
+		 * of the pipe for our caller to use. Now insert the
+		 * other side of the pipe to the hash, to be picked up
+		 * when that side is restored.
+		 */
+		file = fget(fds[1-which]);	/* the 'other' side */
+		if (!file)	/* this should _never_ happen ! */
+			return ERR_PTR(-EBADF);
+		ret = ckpt_obj_insert(ctx, file,
+				      h->pipe_objref, CKPT_OBJ_FILE);
+		if (ret < 0) {
+			fput(file);
+			return ERR_PTR(ret);
+		}
+
+		ret = restore_pipe(ctx, file);
+		fput(file);
+		if (ret < 0)
+			return ERR_PTR(ret);
+
+		file = fget(fds[which]);	/* 'this' side */
+		if (!file)	/* this should _never_ happen ! */
+			return ERR_PTR(-EBADF);
+
+		/* get rid of the file descriptors (caller sets that) */
+		sys_close(fds[which]);
+		sys_close(fds[1-which]);
+	}
+
+	ret = restore_file_common(ctx, file, ptr);
+	if (ret < 0) {
+		fput(file);
+		file = ERR_PTR(ret);
+	}
+
+	return file;
+}
 #else
 #define pipe_file_checkpoint  NULL
 #endif /* CONFIG_CHECKPOINT */
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index c8f0385..453d048 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_PIPE_FS_I_H
 #define _LINUX_PIPE_FS_I_H
 
+#include <linux/checkpoint_hdr.h>
+
 #define PIPEFS_MAGIC 0x50495045
 
 #define PIPE_BUFFERS (16)
@@ -153,4 +155,11 @@ void generic_pipe_buf_get(struct pipe_inode_info *, struct pipe_buffer *);
 int generic_pipe_buf_confirm(struct pipe_inode_info *, struct pipe_buffer *);
 int generic_pipe_buf_steal(struct pipe_inode_info *, struct pipe_buffer *);
 
+/* checkpoint/restart */
+#ifdef CONFIG_CHECKPOINT
+extern struct file *pipe_file_restore(struct ckpt_ctx *ctx,
+				      struct ckpt_hdr_file *ptr);
+#endif
+
 #endif
+
-- 
1.5.4.3
