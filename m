From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] checkpoint: remove unbuildable compat code
Date: Mon, 06 Jul 2009 14:50:49 -0500
Message-ID: <m3r5wtvbdy.fsf@pobox.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

The code bracketed in CONFIG_COMPAT in checkpoint/process.c refers to
symbols that are static in kernel/compat.c (compat_nanosleep_restart,
compat_clock_nanosleep_restart).  This causes builds with
CONFIG_COMPAT=y to fail.

Just remove the offending code, it seems unlikely to have been tested.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 checkpoint/process.c |   50 --------------------------------------------------
 1 files changed, 0 insertions(+), 50 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index b59c7db..0d6c144 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -230,28 +230,6 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
 			 expire, base);
 
-#ifdef CONFIG_COMPAT
-	} else if (fn == compat_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
-		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat expire %lld now %lld\n",
-			 expire, base);
-
-	} else if (fn == compat_clock_nanosleep_restart) {
-
-		h->function_type = CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
-		h->arg_0 = restart_block->nanosleep.index;
-		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
-		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
-		expire = restart_block->nanosleep.expires;
-		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
-			 expire, base);
-
-#endif
 	} else if (fn == futex_wait_restart) {
 
 		h->function_type = CKPT_RESTART_BLOCK_FUTEX;
@@ -572,34 +550,6 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 		restart_block.arg2 = ts.tv_sec;
 		restart_block.arg3 = ts.tv_nsec;
 		break;
-#ifdef CONFIG_COMPAT
-	case CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = compat_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.compat_rmtp =
-			(struct compat_timespec __user *)
-				(unsigned long) h->arg_2;
-		resatrt_block.nanosleep.expires = expire;
-		break;
-	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
-		clockid = h->arg_0;
-		if (clockid < 0 || invalid_clockid(clockid))
-			break;
-		restart_block.fn = compat_clock_nanosleep_restart;
-		restart_block.nanosleep.index = clockid;
-		restart_block.nanosleep.rmtp =
-			(struct timespec __user *) (unsigned long) h->arg_1;
-		restart_block.nanosleep.compat_rmtp =
-			(struct compat_timespec __user *)
-				(unsigned long) h->arg_2;
-		resatrt_block.nanosleep.expires = expire;
-		break;
-#endif
 	case CKPT_RESTART_BLOCK_FUTEX:
 		restart_block.fn = futex_wait_restart;
 		restart_block.futex.uaddr = (u32 *) (unsigned long) h->arg_0;
-- 
1.6.0.6
