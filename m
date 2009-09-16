From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/9] fix trivial build breaks in compat code
Date: Wed, 16 Sep 2009 03:56:51 -0500
Message-ID: <1253091418-14807-3-git-send-email-ntl@pobox.com>
References: <1253091418-14807-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253091418-14807-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

---
 checkpoint/process.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index b7f4a43..41c1c85 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -308,7 +308,7 @@ int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
 #ifdef CONFIG_COMPAT
 	} else if (fn == compat_nanosleep_restart) {
 
-		h->function_type = CKPT_RESTART_BLOCK_NANOSLEEP;
+		h->function_type = CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP;
 		h->arg_0 = restart_block->nanosleep.index;
 		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
 		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
@@ -670,7 +670,7 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 		restart_block.nanosleep.compat_rmtp =
 			(struct compat_timespec __user *)
 				(unsigned long) h->arg_2;
-		resatrt_block.nanosleep.expires = expire;
+		restart_block.nanosleep.expires = expire;
 		break;
 	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
 		clockid = h->arg_0;
@@ -683,7 +683,7 @@ int restore_restart_block(struct ckpt_ctx *ctx)
 		restart_block.nanosleep.compat_rmtp =
 			(struct compat_timespec __user *)
 				(unsigned long) h->arg_2;
-		resatrt_block.nanosleep.expires = expire;
+		restart_block.nanosleep.expires = expire;
 		break;
 #endif
 	case CKPT_RESTART_BLOCK_FUTEX:
-- 
1.6.0.6
