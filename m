From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] Add post-file deferqueue
Date: Wed,  2 Sep 2009 11:22:39 -0700
Message-ID: <1251915760-20118-3-git-send-email-danms@us.ibm.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251915760-20118-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This is the deferq bit of Matt's patch, which is needed by the subsequent
socket patch.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/files.c               |   28 ++++++++++++++++++++++++++++
 include/linux/checkpoint_types.h |    1 +
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/checkpoint/files.c b/checkpoint/files.c
index 204055b..784793c 100644
--- a/checkpoint/files.c
+++ b/checkpoint/files.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
+#include <linux/deferqueue.h>
 #include <net/sock.h>
 
 
@@ -289,11 +290,25 @@ static int do_checkpoint_file_table(struct ckpt_ctx *ctx,
 		goto out;
 
 	ckpt_debug("nfds %d\n", nfds);
+	ctx->files_deferq = deferqueue_create();
+	if (!ctx->files_deferq) {
+		ret = -ENOMEM;
+		goto out;
+	}
 	for (n = 0; n < nfds; n++) {
 		ret = checkpoint_file_desc(ctx, files, fdtable[n]);
 		if (ret < 0)
 			break;
 	}
+	if (!ret) {
+		ret = deferqueue_run(ctx->files_deferq);
+		if (ret > 0) {
+			pr_warning("c/r: files deferqueue had %d entries\n",
+				   ret);
+			ret = 0;
+		}
+	}
+	deferqueue_destroy(ctx->files_deferq);
  out:
 	kfree(fdtable);
 	return ret;
@@ -692,11 +707,24 @@ static struct files_struct *do_restore_file_table(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	ret = -ENOMEM;
+	ctx->files_deferq = deferqueue_create();
+	if (!ctx->files_deferq)
+		goto out;
 	for (i = 0; i < h->fdt_nfds; i++) {
 		ret = restore_file_desc(ctx);
 		if (ret < 0)
 			break;
 	}
+	if (!ret) {
+		ret = deferqueue_run(ctx->files_deferq);
+		if (ret > 0) {
+			pr_warning("c/r: files deferqueue had %d entries\n",
+				   ret);
+			ret = 0;
+		}
+	}
+	deferqueue_destroy(ctx->files_deferq);
  out:
 	ckpt_hdr_put(ctx, h);
 	if (!ret) {
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index a18846f..b6f130c 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -48,6 +48,7 @@ struct ckpt_ctx {
 
 	struct ckpt_obj_hash *obj_hash;	/* repository for shared objects */
 	struct deferqueue_head *deferqueue;	/* queue of deferred work */
+	struct deferqueue_head *files_deferq;
 
 	struct path fs_mnt;     /* container root (FIXME) */
 
-- 
1.6.2.5
