From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] [RFC] Enable c/r of unlinked fifos
Date: Thu, 23 Sep 2010 14:53:32 -0700
Message-ID: <4f74388463f017fd62fa826aafb3087288ab8c69.1285278339.git.matthltc@us.ibm.com>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
	<6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
	<d91e3660266d3a2956c4d1aebc9cb618081b21ef.1285278339.git.matthltc@us.ibm.com>
	<59e9d9fe9db11c6e06ef314541b1112f2b720a59.1285278339.git.matthltc@us.ibm.com>
	<9eade1f1ec10c23dae296feda8af9fe87085e843.1285278339.git.matthltc@us.ibm.com>
	<7da8a050193a91b69ecb3899ce2eda541ecd2473.1285278339.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7da8a050193a91b69ecb3899ce2eda541ecd2473.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Unlinked fifos are special files which share some of their
checkpoint/restart code with pipes. Re-use the code for normal
unlinked files for unlinked fifos too.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 fs/pipe.c                  |    5 ++++-
 include/linux/checkpoint.h |    1 +
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 1325e84..8240fa9 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -898,6 +898,9 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
 		ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
 		if (ret < 0)
 			goto out;
+		ret = checkpoint_file_links(ctx, file);
+		if (ret < 0)
+			goto out;
 	}
 
 	if (first)
@@ -1021,7 +1024,7 @@ struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	 * To avoid blocking, always open the fifo with O_RDWR;
 	 * then fix flags below.
 	 */
-	file = restore_open_fname(ctx, 0, (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
+	file = restore_open_fname(ctx, !!(ptr->f_restart_flags & RESTART_FILE_F_UNLINK), (ptr->f_flags & ~O_ACCMODE) | O_RDWR);
 	if (IS_ERR(file))
 		return file;
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 6ca7b24..ac43914 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -108,6 +108,7 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
+extern int checkpoint_file_links(struct ckpt_ctx *ctx, struct file *file);
 
 extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
 extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
-- 
1.6.3.3
