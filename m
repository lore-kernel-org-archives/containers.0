From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 1/2] c/r: compute hrtimer remaining time relative to
	ktime_begin
Date: Mon,  2 Aug 2010 17:55:08 -0400
Message-ID: <1280786108-17820-1-git-send-email-orenl@cs.columbia.edu>
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

The rule for time values in c/r is: all time measurements in
the checkpoint image are saved as relative values, using the
start-of-checkpoint as the reference point in time.

This patch fixes how hrtimer delta is calculated to make it
really follow this rule.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 kernel/signal.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index de76729..0ec4a46 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3151,7 +3151,8 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	/* real/virt/prof itimers */
 	if (hrtimer_active(&signal->real_timer)) {
 		/* For an active timer compute the time delta */
-		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
+		ktime_t delta = ktime_sub(ctx->ktime_begin,
+					  signal->real_timer._expires);
 		/*
 		 * If the timer expired after the the test above, then
 		 * set the expire to the minimum possible (because by
-- 
1.7.0.4
