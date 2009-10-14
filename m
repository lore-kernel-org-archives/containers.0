From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] Cleanup pre_restore_task comments
Date: Tue, 13 Oct 2009 17:53:06 -0700
Message-ID: <1255481585-32625-2-git-send-email-matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

We don't need to include the name of the function in the comment unless
it's a kerneldoc comment -- it's redundant. Also the comment before
post_restore_task() was copy-pasted without modification.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index c51e036..17c08e8 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -814,7 +814,7 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 	return ret;
 }
 
-/* pre_restore_task - prepare the task for restore */
+/* prepare the task for restore */
 int pre_restore_task(struct ckpt_ctx *ctx)
 {
 	sigset_t sigset;
@@ -844,7 +844,6 @@ int pre_restore_task(struct ckpt_ctx *ctx)
 	return 0;
 }
 
-/* pre_restore_task - prepare the task for restore */
 void post_restore_task(struct ckpt_ctx *ctx)
 {
 	/* can happen if restart failed early */
-- 
1.5.6.3
