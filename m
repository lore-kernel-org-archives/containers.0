From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: get rid of ckpt_hdr_vpids - can be inferred at restart
Date: Tue, 30 Mar 2010 02:32:13 -0400
Message-ID: <1269930734-6887-1-git-send-email-orenl@cs.columbia.edu>
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
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c        |   11 -----------
 checkpoint/restart.c           |   12 ++++--------
 include/linux/checkpoint_hdr.h |    8 --------
 3 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 76687f7..7bcc51d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -542,7 +542,6 @@ static int build_tree(struct ckpt_ctx *ctx)
 static int checkpoint_tree(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_tree *h;
-	struct ckpt_hdr_vpids *hvpids;
 	int ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TREE);
@@ -560,16 +559,6 @@ static int checkpoint_tree(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
-	hvpids = ckpt_hdr_get_type(ctx, sizeof(*hvpids), CKPT_HDR_VPIDS);
-	if (!hvpids)
-		return -ENOMEM;
-
-	hvpids->nr_vpids = ctx->nr_vpids;
-
-	ret = ckpt_write_obj(ctx, &hvpids->h);
-	ckpt_hdr_put(ctx, hvpids);
-	if (ret < 0)
-		return ret;
 	if (ctx->nr_vpids == 0)
 		return 0;
 
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index c25ce88..2102028 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -767,16 +767,12 @@ static int restore_read_tree(struct ckpt_ctx *ctx)
  */
 static int restore_slurp_vpids(struct ckpt_ctx *ctx)
 {
-	struct ckpt_hdr_vpids *h;
-	int size, ret;
+	int size, ret, i;
 
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_VPIDS);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-	ctx->nr_vpids = h->nr_vpids;
-	ckpt_hdr_put(ctx, h);
+	for (i = 0; i < ctx->nr_pids; i++)
+		ctx->nr_vpids += ctx->pids_arr[i].depth;
 
-	if (!ctx->nr_vpids)
+	if (ctx->nr_vpids == 0)
 		return 0;
 
 	size = sizeof(__s32) * ctx->nr_vpids;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 21624d7..36386ad 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -117,8 +117,6 @@ enum {
 #define CKPT_HDR_GROUPINFO CKPT_HDR_GROUPINFO
 	CKPT_HDR_TASK_CREDS,
 #define CKPT_HDR_TASK_CREDS CKPT_HDR_TASK_CREDS
-	CKPT_HDR_VPIDS,
-#define CKPT_HDR_VPIDS CKPT_HDR_VPIDS
 
 	/* 201-299: reserved for arch-dependent */
 
@@ -348,12 +346,6 @@ struct ckpt_pids {
 	__s32 depth; /* pid namespace depth relative to container init */
 } __attribute__((aligned(8)));
 
-/* number of vpids */
-struct ckpt_hdr_vpids {
-	struct ckpt_hdr h;
-	__s32 nr_vpids;
-} __attribute__((aligned(8)));
-
 /* pids */
 #define CKPT_PID_NULL  -1
 
-- 
1.6.3.3
