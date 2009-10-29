From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 04/17] ckpt_write_err update checkpoint/files.c
Date: Thu, 29 Oct 2009 15:54:29 -0500
Message-ID: <1256849682-858-5-git-send-email-serue@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 440b7a9..1f2ab07 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -88,7 +88,7 @@ int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path, struct path *root)
 					  CKPT_HDR_FILE_NAME);
 	} else {
 		ret = PTR_ERR(fname);
-		ckpt_write_err(ctx, "TEP", "obtain filename (file)", ret);
+		ckpt_write_err(ctx, "%(T)%(E)%(P)obtain filename (file)", ret);
 	}
 
 	kfree(buf);
@@ -204,20 +204,21 @@ int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
 	int ret;
 
 	if (!file->f_op || !file->f_op->checkpoint) {
-		ckpt_write_err(ctx, "TEPS", "f_op lacks checkpoint",
+		ckpt_write_err(ctx, "%(T)%(E)%(P)%(S)f_op lacks checkpoint",
 			       -EBADF, file, file->f_op);
 		ckpt_debug("f_op lacks checkpoint handler: %pS\n", file->f_op);
 		return -EBADF;
 	}
 	if (d_unlinked(file->f_dentry)) {
-		ckpt_write_err(ctx, "TEP", "unlinked file", -EBADF, file);
+		ckpt_write_err(ctx, "%(T)%(E)%(P)unlinked file", -EBADF, file);
 		ckpt_debug("unlinked files are unsupported\n");
 		return -EBADF;
 	}
 
 	ret = file->f_op->checkpoint(ctx, file);
 	if (ret < 0)
-		ckpt_write_err(ctx, "TEP", "file checkpoint failed", ret, file);
+		ckpt_write_err(ctx, "%(T)%(E)%(P)file checkpoint failed", ret,
+			       file);
 	return ret;
 }
 
@@ -257,7 +258,7 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
 	ret = -EBADF;
 	if (!file) {
 		pr_warning("c/r: file descriptor gone?");
-		ckpt_write_err(ctx, "TEP", "file gone? (%d)", ret, file, fd);
+		ckpt_write_err(ctx, "%(T)%(E)%(P)file gone? (%d)", ret, file, fd);
 		goto out;
 	}
 
@@ -360,7 +361,7 @@ int ckpt_collect_file(struct ckpt_ctx *ctx, struct file *file)
 	if (file->f_op->collect)
 		ret = file->f_op->collect(ctx, file);
 	if (ret < 0)
-		ckpt_write_err(ctx, "TEP", "file collect", ret, file);
+		ckpt_write_err(ctx, "%(T)%(E)%(P)file collect", ret, file);
 	return ret;
 }
 
@@ -379,7 +380,7 @@ static int collect_file_desc(struct ckpt_ctx *ctx,
 	rcu_read_unlock();
 
 	if (!file) {
-		ckpt_write_err(ctx, "TE", "file removed", -EBUSY, file);
+		ckpt_write_err(ctx, "%(T)%(E)file removed", -EBUSY, file);
 		return -EBUSY;
 	}
 
@@ -422,7 +423,7 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	files = get_files_struct(t);
 	if (!files) {
-		ckpt_write_err(ctx, "TE", "files_struct missing", -EBUSY);
+		ckpt_write_err(ctx, "%(T)%(E)files_struct missing", -EBUSY);
 		return -EBUSY;
 	}
 	ret = collect_file_table(ctx, files);
-- 
1.6.1
