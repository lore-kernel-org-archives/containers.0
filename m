From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 14/17] ckpt_error in checkpoint/process.c
Date: Tue, 27 Oct 2009 17:46:24 -0500
Message-ID: <1256683587-23961-15-git-send-email-serge@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256683587-23961-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index e84683f..9f46769 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -581,14 +581,14 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
 
 	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(realcred)) {
-		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
+		ckpt_error(ctx, "%(T)Error %ld fetching realcred (ref %(O))\n",
 			PTR_ERR(realcred), h->cred_ref);
 		ret = PTR_ERR(realcred);
 		goto out;
 	}
 	ecred = ckpt_obj_fetch(ctx, h->ecred_ref, CKPT_OBJ_CRED);
 	if (IS_ERR(ecred)) {
-		ckpt_debug("Error %ld fetching ecred (ref %d)\n",
+		ckpt_error(ctx, "%(T)Error %ld fetching ecred (ref %(O))\n",
 			PTR_ERR(ecred), h->ecred_ref);
 		ret = PTR_ERR(ecred);
 		goto out;
@@ -614,18 +614,18 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	 */
 	ret = restore_task_creds(ctx);
 	if (ret < 0) {
-		ckpt_debug("restore_task_creds returned %d\n", ret);
+		ckpt_error(ctx, "%(T)restore_task_creds returned %d\n", ret);
 		return ret;
 	}
 	ret = restore_task_ns(ctx);
 	if (ret < 0) {
-		ckpt_debug("restore_task_ns returned %d\n", ret);
+		ckpt_error(ctx, "%(T)restore_task_ns returned %d\n", ret);
 		return ret;
 	}
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (IS_ERR(h)) {
-		ckpt_debug("Error fetching task obj\n");
+		ckpt_error(ctx, "%(T)Error %d fetching task obj\n", PTR_ERR(h));
 		return PTR_ERR(h);
 	}
 
-- 
1.6.1
