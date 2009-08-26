From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Rename some struct ckpt_hdr_* to struct ckpt_*
Date: Wed, 26 Aug 2009 05:12:04 -0700
Message-ID: <20090826121204.GK8078@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

    Rename some struct ckpt_hdr_* to struct ckpt_*
    
    These structures don't actually contain a struct ckpt_hdr so
    they don't have "hdr" as part of their prefix anymore.
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/mktree.c b/mktree.c
index e42407f..63be82d 100644
--- a/mktree.c
+++ b/mktree.c
@@ -160,8 +160,8 @@ struct ckpt_ctx {
 	int pipe_child[2];	/* for children to report status */
 	int pipe_feed[2];	/* for feeder to provide input */
 
-	struct ckpt_hdr_pids *pids_arr;
-	struct ckpt_hdr_pids *copy_arr;
+	struct ckpt_pids *pids_arr;
+	struct ckpt_pids *copy_arr;
 
 	struct task *tasks_arr;
 	int tasks_nr;
@@ -1556,7 +1556,7 @@ static int ckpt_adjust_pids(struct ckpt_ctx *ctx)
 	 *    but correct should be: [][][B][][A][]...
 	 */
 
-	len = sizeof(struct ckpt_hdr_pids) * ctx->pids_nr;
+	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
 
 	memcpy(ctx->copy_arr, ctx->pids_arr, len);
 
@@ -1777,7 +1777,7 @@ static int ckpt_read_tree(struct ckpt_ctx *ctx)
 
 	ctx->pids_nr = h->nr_tasks;
 
-	len = sizeof(struct ckpt_hdr_pids) * ctx->pids_nr;
+	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
 
 	ctx->pids_arr = malloc(len);
 	ctx->copy_arr = malloc(len);
@@ -1835,7 +1835,7 @@ static int ckpt_write_tree(struct ckpt_ctx *ctx)
 	if (ckpt_write_obj(ctx, (struct ckpt_hdr *) h) < 0)
 		ckpt_abort(ctx, "write tree");
 
-	len = sizeof(struct ckpt_hdr_pids) * ctx->pids_nr;
+	len = sizeof(struct ckpt_pids) * ctx->pids_nr;
 	if (ckpt_write_obj_ptr(ctx, ctx->pids_arr, len, CKPT_HDR_BUFFER) < 0)
 		ckpt_abort(ctx, "write pids");
