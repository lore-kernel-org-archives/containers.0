From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/10] Enable c/r of unlinked fifos
Date: Mon, 28 Feb 2011 20:05:11 -0800
Message-ID: <dbe36642be44152833a63e8173e8f0490dc1573f.1298952288.git.matthltc@us.ibm.com>
References: <1298952316-15763-1-git-send-email-matthltc@us.ibm.com>
	<a6df3726c48b6f9e2422e9c12a32c4991bc53a25.1298952288.git.matthltc@us.ibm.com>
	<cbc5f629ca02554497bcb385039a2a300ef897f0.1298952288.git.matthltc@us.ibm.com>
	<6f547f7b0dd12d409f993dba3fbc899dc52f2a78.1298952288.git.matthltc@us.ibm.com>
	<1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1a7a344ddd1d68ac862ec2248be77f2dd9f138c8.1298952288.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Unlinked fifos are special files which share some of their
checkpoint/restart code with pipes. Re-use the code for normal
unlinked files for unlinked fifos too.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/pipe.c                  |    5 ++++-
 include/linux/checkpoint.h |    1 +
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index e66ba97..e9f3e64 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -917,6 +917,9 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
 		if (ret < 0)
 			goto out;
+		ret = checkpoint_file_links(ctx, file);
+		if (ret < 0)
+			goto out;
 	}
 
 	if (first)
@@ -1053,7 +1056,7 @@ struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	 * To avoid blocking, always open the fifo with O_RDWR;
 	 * then fix flags below.
 	 */
-	file = restore_open_fname(ctx, 0, (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
+	file = restore_open_fname(ctx, !!(ptr->f_restart_flags & CKPT_RESTART_FILE_F_UNLINK), (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
 	if (IS_ERR(file))
 		return file;
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8686ce7..f31671f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -109,6 +109,7 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
+extern int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file);
 
 extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
 extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
-- 
1.6.3.3
