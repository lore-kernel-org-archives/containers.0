From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] use simpler test_task_thread to test current ti flags
Date: Thu, 28 Jan 2010 17:33:11 -0600
Message-ID: <20100128233311.GA9890@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This ought to be folded into the 
	'fix 31-bit s390 checkpoint/restart wrappers'
patch which I sent earlier today.  Not a bug without it, just
not as nice.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/checkpoint.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
index 8ec12c6..60ba04d 100644
--- a/arch/s390/kernel/checkpoint.c
+++ b/arch/s390/kernel/checkpoint.c
@@ -148,7 +148,8 @@ int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
 
 int restore_thread(struct ckpt_ctx *ctx)
 {
-	if (test_tsk_thread_flag(current, TIF_31BIT)) {
+	/* a 31-bit task cannot call sys_restart right now */
+	if (test_thread_flag(TIF_31BIT)) {
 		ckpt_err(ctx, -EINVAL, "restart from 31-bit task\n");
 		return -EINVAL;
 	}
-- 
1.6.1
