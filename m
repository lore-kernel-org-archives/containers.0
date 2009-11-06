From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/7] process.c: use ckpt_err at restart
Date: Thu,  5 Nov 2009 18:00:15 -0600
Message-ID: <1257465619-1777-4-git-send-email-serue@us.ibm.com>
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
 checkpoint/process.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 5bc8ccc..9a56f68 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -581,16 +581,15 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 
 	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(realcred)) {
-		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
-			PTR_ERR(realcred), h->cred_ref);
 		ret = PTR_ERR(realcred);
+		ckpt_err(ctx, ret, "%(O)Error fetching realcred\n",
+			 h->cred_ref);
 		goto out;
 	}
 	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(ecred)) {
-		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
-			PTR_ERR(ecred), h->ecred_ref);
 		ret = PTR_ERR(ecred);
+		ckpt_err(ctx, ret, "%(O)Error fetching ecred\n", h->ecred_ref);
 		goto out;
 	}
 	ctx->realcred = realcred;
@@ -614,19 +613,20 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 */
 	ret = restore_task_creds(ctx);
 	if (ret < 0) {
-		ckpt_debug("restore_task_creds returned %d\n", ret);
+		ckpt_err(ctx, ret, "restore_task_creds\n");
 		return ret;
 	}
 	ret = restore_task_ns(ctx);
 	if (ret < 0) {
-		ckpt_debug("restore_task_ns returned %d\n", ret);
+		ckpt_err(ctx, ret, "restore_task_ns\n");
 		return ret;
 	}
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (IS_ERR(h)) {
-		ckpt_debug("Error fetching task obj\n");
-		return PTR_ERR(h);
+		ret = PTR_ERR(h);
+		ckpt_err(ctx, ret, "fetching task obj\n");
+		return ret;
 	}
 
 	ret = restore_obj_file_table(ctx, h->files_objref);
-- 
1.6.1
