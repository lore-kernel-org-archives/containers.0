From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 09/17] ckpt_write_err update checkpoint/signal.c
Date: Tue, 27 Oct 2009 17:46:19 -0500
Message-ID: <1256683587-23961-10-git-send-email-serge@us.ibm.com>
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
 checkpoint/signal.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index cdfb142..3eed685 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -287,7 +287,7 @@ static int checkpoint_sigpending(struct ckpt_ctx *ctx,
 	list_for_each_entry(q, &pending->list, list) {
 		/* TODO: remove after adding support for posix-timers */
 		if ((q->info.si_code & __SI_MASK) == __SI_TIMER) {
-			ckpt_write_err(ctx, "TE", "signal SI_TIMER", -ENOTSUPP);
+			ckpt_write_err(ctx, "%(T)%(E)signal SI_TIMER", -ENOTSUPP);
 			return -ENOTSUPP;
 		}
 		nr_pending++;
@@ -341,7 +341,8 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	/* TODO: remove after adding support for posix-timers */
 	if (!list_empty(&signal->posix_timers)) {
-		ckpt_write_err(ctx, "TEP", "posix-timers\n", -ENOTSUPP, signal);
+		ckpt_write_err(ctx, "%(T)%(E)%(P)posix-timers\n", -ENOTSUPP,
+				signal);
 		unlock_task_sighand(t, &flags);
 		ret = -ENOTSUPP;
 		goto out;
@@ -653,7 +654,7 @@ int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	/* temporarily borrow signal queue - see chekcpoint_sigpending() */
 	if (!lock_task_sighand(t, &flags)) {
-		ckpt_write_err(ctx, "TE", "signand missing", -EBUSY);
+		ckpt_write_err(ctx, "%(T)%(E)signand missing", -EBUSY);
 		return -EBUSY;
 	}
 	list_splice_init(&t->pending.list, &pending.list);
@@ -664,7 +665,7 @@ int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	/* re-attach the borrowed queue */
 	if (!lock_task_sighand(t, &flags)) {
-		ckpt_write_err(ctx, "TE", "signand missing", -EBUSY);
+		ckpt_write_err(ctx, "%(T)%(E)sighand missing", -EBUSY);
 		return -EBUSY;
 	}
 	list_splice(&pending.list, &t->pending.list);
-- 
1.6.1
