From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/7] files.c: ckpt_err() during restore
Date: Thu,  5 Nov 2009 18:00:16 -0600
Message-ID: <1257465619-1777-5-git-send-email-serue@us.ibm.com>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 checkpoint/files.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 14ccfd6..9686b0b 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -649,6 +649,9 @@ static struct file *do_restore_file(struct ckpt_ctx *ctx)
 	if (ops->restore)
 		file = ops->restore(ctx, h);
  out:
+	if (IS_ERR(file))
+		ckpt_err(ctx, PTR_ERR(file), "file restore\n");
+
 	ckpt_hdr_put(ctx, h);
 	return file;
 }
@@ -738,8 +741,10 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
 
 	/* point of no return -- close all file descriptors */
 	ret = close_all_fds(current->files);
-	if (ret < 0)
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "closing fds\n");
 		goto out;
+	}
 
 	for (i = 0; i < h->fdt_nfds; i++) {
 		ret = restore_file_desc(ctx);
@@ -757,6 +762,7 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
 		files = current->files;
 		atomic_inc(&files->count);
 	} else {
+		ckpt_err(ctx, ret, "restoring file table\n");
 		files = ERR_PTR(ret);
 	}
 	return files;
-- 
1.6.1
