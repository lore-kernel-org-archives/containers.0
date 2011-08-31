From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH pm-freezer 3/4] freezer: restructure __refrigerator()
Date: Wed, 31 Aug 2011 12:22:10 +0200
Message-ID: <20110831102210.GC2828__24390.133310999$1314908880$gmane$org@mtj.dyndns.org>
References: <20110831102100.GA2828@mtj.dyndns.org>
	<20110831102143.GB2828@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110831102143.GB2828-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


If another freeze happens before all tasks leave FROZEN state after
being thawed, the freezer can see the existing FROZEN and consider the
tasks to be frozen but they can clear FROZEN without checking the new
freezing().

Oleg suggested restructuring __refrigerator() such that there's single
condition check section inside freezer_lock and sigpending is cleared
afterwards, which fixes the problem and simplifies the code.
Restructure accordingly.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Reported-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
---
 kernel/freezer.c |   33 ++++++++++++++-------------------
 1 file changed, 14 insertions(+), 19 deletions(-)

Index: work/kernel/freezer.c
===================================================================
--- work.orig/kernel/freezer.c
+++ work/kernel/freezer.c
@@ -52,36 +52,31 @@ bool __refrigerator(bool check_kthr_stop
 	/* Hmm, should we be allowed to suspend when there are realtime
 	   processes around? */
 	bool was_frozen = false;
-	long save;
+	long save = current->state;
 
-	/*
-	 * No point in checking freezing() again - the caller already did.
-	 * Proceed to enter FROZEN.
-	 */
-	spin_lock_irq(&freezer_lock);
-	current->flags |= PF_FROZEN;
-	spin_unlock_irq(&freezer_lock);
-
-	save = current->state;
 	pr_debug("%s entered refrigerator\n", current->comm);
 
-	spin_lock_irq(&current->sighand->siglock);
-	recalc_sigpending(); /* We sent fake signal, clean it up */
-	spin_unlock_irq(&current->sighand->siglock);
-
 	for (;;) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
+
+		spin_lock_irq(&freezer_lock);
+		current->flags |= PF_FROZEN;
 		if (!freezing(current) ||
-		    (check_kthr_stop && kthread_should_stop()))
+		    (check_kthr_stop && kthread_should_stop())) {
+			current->flags &= ~PF_FROZEN;
+			break;
+		}
+		spin_unlock_irq(&freezer_lock);
+
+		if (!(current->flags & PF_FROZEN))
 			break;
 		was_frozen = true;
 		schedule();
 	}
 
-	/* leave FROZEN */
-	spin_lock_irq(&freezer_lock);
-	current->flags &= ~PF_FROZEN;
-	spin_unlock_irq(&freezer_lock);
+	spin_lock_irq(&current->sighand->siglock);
+	recalc_sigpending(); /* We sent fake signal, clean it up */
+	spin_unlock_irq(&current->sighand->siglock);
 
 	pr_debug("%s left refrigerator\n", current->comm);
