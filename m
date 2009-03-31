From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc2][PATCH 18/29] Restore open pipes
Date: Tue, 31 Mar 2009 01:28:58 -0400
Message-ID: <1238477349-11029-19-git-send-email-orenl@cs.columbia.edu>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1238477349-11029-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

When seeing a CR_FD_PIPE file type, we create a new pipe and thus
have two file pointers (read- and write- ends). We only use one of
them, depending on which side was checkpointed first. We register the
file pointer of the other end in the hash table, with the 'objref'
given for this pipe from the checkpoint, deposited for later use. At
this point we also restore the contents of the pipe buffers.

When the other end arrives, it will have file type CR_FD_OBJREF. We
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
  - Check whether calls to cr_hbuf_get() fail

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint_file.h |    2 +
 checkpoint/rstr_file.c       |  124 +++++++++++++++++++++++++++++++++++++++++-
 fs/pipe.c                    |    2 +-
 3 files changed, 125 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint_file.h b/checkpoint/checkpoint_file.h
index 9dc3eba..cac1a5d 100644
--- a/checkpoint/checkpoint_file.h
+++ b/checkpoint/checkpoint_file.h
@@ -14,4 +14,6 @@
 
 int cr_scan_fds(struct files_struct *files, int **fdtable);
 
+extern const struct pipe_buf_operations anon_pipe_buf_ops;
+
 #endif /* _CHECKPOINT_CKPT_FILE_H_ */
diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
index af9756b..db2fcf2 100644
--- a/checkpoint/rstr_file.c
+++ b/checkpoint/rstr_file.c
@@ -14,6 +14,8 @@
 #include <linux/file.h>
 #include <linux/fdtable.h>
 #include <linux/fsnotify.h>
+#include <linux/pagemap.h>
+#include <linux/pipe_fs_i.h>
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -86,6 +88,121 @@ static struct file *cr_obj_add_file(struct cr_ctx *ctx, int fd, int objref)
 	return (ret < 0 ? ERR_PTR(ret) : file);
 }
 
+/* cr_read_pipebuf - restore contents of a pipe/fifo (assume i_mutex taken) */
+static int
+cr_read_pipebuf(struct cr_ctx *ctx, struct pipe_inode_info *pipe, int nbufs)
+{
+	void *kbuf, *addr;
+	int i, ret = 0;
+
+	kbuf = (void *) __get_free_page(GFP_KERNEL);
+	if (!kbuf)
+		return -ENOMEM;
+
+	for (i = 0; i < nbufs; i++) {
+		struct pipe_buffer *pbuf = pipe->bufs + i;
+		struct page *page;
+		int len = PAGE_SIZE;
+
+		ret = cr_read_buffer(ctx, kbuf, &len);
+		if (ret < 0)
+			break;
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
+/* cr_read_pipe - restore pipe (assume i_mutex taken) */
+static int cr_read_pipe(struct cr_ctx *ctx, int pipefd)
+{
+	struct cr_hdr_fd_pipe *hh;
+	struct file *file;
+	struct inode *inode;
+	int nbufs, ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_FD_PIPE);
+	nbufs = hh->nr_bufs;
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	if (ret < 0)
+		return ret;
+	if (nbufs < 0 || nbufs > PIPE_BUFFERS)
+		return -EINVAL;
+
+	file = fget(pipefd);
+	if (!file)
+		return -EIO;
+
+	inode = file->f_dentry->d_inode;
+	mutex_lock(&inode->i_mutex);
+	ret = cr_read_pipebuf(ctx, inode->i_pipe, nbufs);
+	mutex_unlock(&inode->i_mutex);
+
+	fput(file);
+	return ret;
+}
+
+/* restore a pipe */
+static int cr_read_fd_pipe(struct cr_ctx *ctx, struct cr_hdr_file *hh)
+{
+	struct file *file;
+	int fds[2], which, ret;
+
+	file = cr_obj_get_by_ref(ctx, hh->fd_objref, CR_OBJ_FILE);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+	else if (file)
+		return cr_attach_get_file(file);
+
+	/* first encounter of this pipe: create it */
+	ret = do_pipe(fds);
+	if (ret < 0)
+		return ret;
+
+	which = (hh->f_flags & O_WRONLY ? 1 : 0);
+
+	/*
+	 * Below we return the fd corersponding to one side of the pipe
+	 * for our caller to use. Now register the other side of the pipe
+	 * in the hash, to be picked up when that side is to be restored.
+	 */
+	file = cr_obj_add_file(ctx, fds[1-which], hh->fd_objref);
+	if (IS_ERR(file)) {
+		ret = PTR_ERR(file);
+		goto out;
+	}
+
+	ret = cr_read_pipe(ctx, fds[which]);
+ out:
+	sys_close(fds[1-which]);	/* this side isn't used anymore */
+	if (ret < 0)
+		sys_close(fds[which]);
+	else
+		ret = fds[which];
+	return ret;
+}
+
 /* return a new fd associated with a the file referenced by @hh->objref */
 static int cr_read_fd_objref(struct cr_ctx *ctx, struct cr_hdr_file *hh)
 {
@@ -138,11 +255,14 @@ static int cr_read_file(struct cr_ctx *ctx, int objref)
 	/* FIX: more sanity checks on f_flags, f_mode etc */
 
 	switch (hh->fd_type) {
+	case CR_FD_OBJREF:
+		fd = cr_read_fd_objref(ctx, hh);
+		break;
 	case CR_FD_GENERIC:
 		fd = cr_read_fd_generic(ctx, hh);
 		break;
-	case CR_FD_OBJREF:
-		fd = cr_read_fd_objref(ctx, hh);
+	case CR_FD_PIPE:
+		fd = cr_read_fd_pipe(ctx, hh);
 		break;
 	default:
 		goto out;
diff --git a/fs/pipe.c b/fs/pipe.c
index 0c3f391..0636f5f 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -271,7 +271,7 @@ int generic_pipe_buf_confirm(struct pipe_inode_info *info,
 	return 0;
 }
 
-static const struct pipe_buf_operations anon_pipe_buf_ops = {
+const struct pipe_buf_operations anon_pipe_buf_ops = {
 	.can_merge = 1,
 	.map = generic_pipe_buf_map,
 	.unmap = generic_pipe_buf_unmap,
-- 
1.5.4.3
