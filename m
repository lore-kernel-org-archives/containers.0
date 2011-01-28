From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Fix restoring pipes with full buffers
Date: Fri, 28 Jan 2011 10:45:11 -0800
Message-ID: <1296240311-5050-1-git-send-email-danms@us.ibm.com>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

While this fixes restoring pipes that were completely full, it actually
corrects a potential issue with restoring any pipe buffers.  By using
splice() to do this work when we are reading the image from another pipe,
we depend on userspace setting up the buffers in the pipe perfectly
such that the data to be restored is oriented in the pipe in the same
way as it is expected (or required) to be in the restored pipe.  The
"full" case is the hardest to get right, but userspace could break things
if it loaded up the inbound pipe with lots of small buffers which would
cause splice() to hit the PIPE_BUFFERS limit before having read the
requested amount of data.

Instead, drop the optimization and just read() and write() data into
the pipe.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/pipe.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 9664e4f..0da1e3a 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -926,17 +926,60 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 	return ret;
 }
 
+static int restore_pipe_buffer(struct ckpt_ctx *ctx,
+			       struct file *dest,
+			       int len)
+{
+	char *buf;
+	int ret;
+	int nread;
+	int nwrote;
+	int nleft = len;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	for (nleft = len; nleft > 0; nleft -= nread) {
+		int size = nleft < PAGE_SIZE ? nleft : PAGE_SIZE;
+		loff_t pos;
+
+		pos = file_pos_read(ctx->file);
+		nread = kernel_read(ctx->file, pos, buf, size);
+		if (nread < 0) {
+			ret = nread;
+			goto out;
+		}
+		file_pos_write(ctx->file, pos + nread);
+
+		pos = file_pos_read(dest);
+		nwrote = kernel_write(dest, pos, buf, nread);
+		if (nwrote < 0) {
+			ret = nwrote;
+			goto out;
+		}
+		file_pos_write(dest, pos + nwrote);
+
+		if (nwrote != nread) {
+			ret = -EPIPE;
+			goto out;
+		}
+	}
+	ret = len;
+ out:
+	kfree(buf);
+	return ret;
+}
+
 static int restore_pipe(struct ckpt_ctx *ctx, struct file *file)
 {
-	struct pipe_inode_info *pipe;
 	int len, ret;
 
 	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_PIPE_BUF);
 	if (len <= 0)
 		return len;
 
-	pipe = file->f_dentry->d_inode->i_pipe;
-	ret = do_splice_to(ctx->file, &ctx->file->f_pos, pipe, len, 0);
+	ret = restore_pipe_buffer(ctx, file, len);
 
 	if (ret >= 0 && ret != len)
 		ret = -EPIPE;  /* can occur due to an error in source file */
-- 
1.7.2.2
