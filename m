From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] Move ckpt_objhash_free() to before we destroy the
	deferqueues
Date: Tue,  9 Feb 2010 09:30:04 -0800
Message-ID: <1265736604-24194-3-git-send-email-danms@us.ibm.com>
References: <1265736604-24194-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265736604-24194-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This makes the deferqueue cleanup function run after all the objects
have been purged from the hash and thus gives us an opportunity to cleanup
things that *must* happen after the last reference is dropped (such as
unregister_netdev()).

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index f04b8b0..f739932 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -223,6 +223,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->kflags & CKPT_CTX_RESTART)
 		restore_debug_free(ctx);
 
+	ckpt_obj_hash_free(ctx);
+
 	if (ctx->deferqueue)
 		deferqueue_destroy(ctx->deferqueue);
 
@@ -234,7 +236,6 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->logfile)
 		fput(ctx->logfile);
 
-	ckpt_obj_hash_free(ctx);
 	path_put(&ctx->root_fs_path);
 	ckpt_pgarr_free(ctx);
 
-- 
1.6.2.5
