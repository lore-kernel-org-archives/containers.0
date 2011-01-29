From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Fix restoring pipes with full buffers
Date: Sat, 29 Jan 2011 00:45:58 -0500
Message-ID: <4D43A996.3020202@cs.columbia.edu>
References: <1296240311-5050-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296240311-5050-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


From 7d3f62995ed4e83bb43deafa362c78624099e495 Mon Sep 17 00:00:00 2001
From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date: Fri, 28 Jan 2011 19:23:17 -0500
Subject: [PATCH] c/r: fix restoring pipes with full buffers

Dan Smith pointed out a problem with the use of splice to restore a
pipe's contents: since a pipe can have at most PIPE_BUFFERs buffers,
if it happens that the input fed through the userspace feeder is split
into more pieces, the splice will eventually block. This bad behavior
is more likely to occur if the pipe buffer had been nearly full when
checkpointed.

Dan's patch fixes the problem by dropping the optimization (we don't
expect pipe buffers to be a dominant component of the image), but is
inocorrect for cases when the read-end of the pipe was saved first
during checkpoint. This version fixes that problem and makes use of
c/r's ckpt_kread() helpers.

Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/pipe.c                  |   49 +++++++++++++++++++++++++++----------------
 include/linux/checkpoint.h |    2 +
 kernel/checkpoint/sys.c    |    4 +-
 3 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 9ca956d..0d049a3 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -928,20 +928,27 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 
 static int restore_pipe(struct ckpt_ctx *ctx, struct file *file)
 {
-	struct pipe_inode_info *pipe;
-	int len, ret;
+	int n, len, ret;
 
 	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_PIPE_BUF);
 	if (len < 0)
 		return len;
 
-	pipe = file->f_dentry->d_inode->i_pipe;
-	ret = do_splice_to(ctx->file, &ctx->file->f_pos, pipe, len, 0);
-
-	if (ret >= 0 && ret != len)
-		ret = -EPIPE;  /* can occur due to an error in source file */
+	while (len) {
+		n = min(len, (int) PAGE_SIZE);
+		ret = ckpt_kread(ctx, ctx->scratch_page, n);
+		if (ret < 0)
+			return ret;
+		ret = _ckpt_kwrite(file, ctx->scratch_page, n);
+		if (ret < 0)
+			return ret;
+		/* this should not happen normally ! */
+		if (ret != n)
+			return -EPIPE;
+		len -= n;
+	}
 
-	return ret;
+	return 0;
 }
 
 struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
@@ -971,6 +978,14 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		if (ret < 0)
 			return file;
 
+		/* use the "write" side to restore the pipe's contents */
+		file = fget(fds[1]);
+		if (!file)	/* this should _never_ happen ! */
+			return ERR_PTR(-EBADF);
+		ret = restore_pipe(ctx, file);
+		if (ret < 0)
+			goto out;
+
 		which = (ptr->f_flags & O_WRONLY ? 1 : 0);
 		/*
 		 * Below we return the file corersponding to one side
@@ -978,25 +993,23 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		 * other side of the pipe to the hash, to be picked up
 		 * when that side is restored.
 		 */
-		file = fget(fds[1-which]);	/* the 'other' side */
-		if (!file)	/* this should _never_ happen ! */
-			return ERR_PTR(-EBADF);
+		if (which == 1) {	/* the 'other' size */
+			fput(file);
+			file = fget(fds[0]);
+			if (!file)	/* this should _never_ happen ! */
+				return ERR_PTR(-EBADF);
+		}
 		ret = ckpt_obj_insert(ctx, file, h->pipe_objref, CKPT_OBJ_FILE);
 		if (ret < 0)
 			goto out;
 
-		ret = restore_pipe(ctx, file);
-		fput(file);
-		if (ret < 0)
-			return ERR_PTR(ret);
-
 		file = fget(fds[which]);	/* 'this' side */
 		if (!file)	/* this should _never_ happen ! */
 			return ERR_PTR(-EBADF);
 
 		/* get rid of the file descriptors (caller sets that) */
-		sys_close(fds[which]);
-		sys_close(fds[1-which]);
+		sys_close(fds[0]);
+		sys_close(fds[1]);
 	} else {
 		return file;
 	}
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c015106..adaf6af 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -76,6 +76,8 @@ extern int walk_task_subtree(struct task_struct *task,
 			     void *data);
 extern void exit_checkpoint(struct task_struct *tsk);
 
+extern ssize_t _ckpt_kwrite(struct file *file, void *buf, size_t count);
+extern ssize_t _ckpt_kread(struct file *file, void *buf, size_t count);
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, size_t count);
 extern int ckpt_kread(struct ckpt_ctx *ctx, void *buf, size_t count);
 
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index e9a377b..2383db9 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -51,7 +51,7 @@ int ckpt_unpriv_allowed = 1;	/* default: unpriv checkpoint not restart */
  * and return 0, or negative error otherwise.
  */
 
-static ssize_t _ckpt_kwrite(struct file *file, void *addr, size_t count)
+ssize_t _ckpt_kwrite(struct file *file, void *addr, size_t count)
 {
 	loff_t pos;
 	int ret;
@@ -82,7 +82,7 @@ int ckpt_kwrite(struct ckpt_ctx *ctx, void *addr, size_t count)
 	return 0;
 }
 
-static ssize_t _ckpt_kread(struct file *file, void *addr, size_t count)
+ssize_t _ckpt_kread(struct file *file, void *addr, size_t count)
 {
 	loff_t pos;
 	int ret;
-- 
1.7.1
