From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: [ckpt_msg][PATCH 1/1] c/r: Fix trivial bug in ckpt_msg macro
Date: Sun, 21 Mar 2010 19:24:46 -0400
Message-ID: <1269213886-22543-1-git-send-email-christofferdall@christofferdall.dk>
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
To: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Id: containers.vger.kernel.org

Fixing the typo "ftm->fmt" in checkpoint/restart log macro.

Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
---
 include/linux/checkpoint.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 792b523..4f25992 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -443,7 +443,7 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
  * Must be called with ckpt_msg_lock held.
  */
 #define _ckpt_msg(ctx, fmt, args...) do {	\
-	_do_ckpt_msg(ctx, 0, ftm, ##args);	\
+	_do_ckpt_msg(ctx, 0, fmt, ##args);	\
 } while (0)
 
 /*
@@ -456,7 +456,7 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
  * Must not be called under spinlock.
  */
 #define ckpt_msg(ctx, fmt, args...) do {	\
-	do_ckpt_msg(ctx, 0, ftm, ##args);	\
+	do_ckpt_msg(ctx, 0, fmt, ##args);	\
 } while (0)
 
 /*
-- 
1.5.6.5
