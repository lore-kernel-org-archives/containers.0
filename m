From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH pm-freezer 1/4] cgroup_freezer: fix freezer->state
	setting bug in freezer_change_state()
Date: Fri, 2 Sep 2011 19:30:39 +0200
Message-ID: <20110902173039.GA9039@redhat.com>
References: <20110831102100.GA2828@mtj.dyndns.org>
	<20110902004231.GF1919@count0.beaverton.ibm.com>
	<20110902165839.GA7478@redhat.com>
	<20110902170844.GJ2752@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110902170844.GJ2752-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/03, Tejun Heo wrote:
>
> Can you please wait a bit?

Sure. But just in case, I mean the simple patch below.

Feel free to incorporate into 4/4, or I can resend it later.

Oleg.

------------------------------------------------------------------------------
[PATCH] freezer: remove the pointless/unsafe __thaw_task()->recalc_sigpending_and_wake()

Remove __thaw_task()->recalc_sigpending_and_wake(). It was copied from
cancel_freezing() recently, but it was always wrong.

It is pointless, contary to the comment it can't clear TIF_SIGPENDING.
Not to mention, we must never do this with !current task, this is wrong.

The usage of ->sighand is not safe if the caller is cgroup_freezer, we
can racw with exit.

Signed-off-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

 kernel/freezer.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

--- 3.1/kernel/freezer.c~kill_rspaw	2011-09-02 18:52:46.000000000 +0200
+++ 3.1/kernel/freezer.c	2011-09-02 19:03:30.000000000 +0200
@@ -150,18 +150,10 @@ void __thaw_task(struct task_struct *p)
 	 * be visible to @p as waking up implies wmb.  Waking up inside
 	 * freezer_lock also prevents wakeups from leaking outside
 	 * refrigerator.
-	 *
-	 * If !FROZEN, @p hasn't reached refrigerator, recalc sigpending to
-	 * avoid leaving dangling TIF_SIGPENDING behind.
 	 */
 	spin_lock_irqsave(&freezer_lock, flags);
-	if (frozen(p)) {
+	if (frozen(p))
 		wake_up_process(p);
-	} else {
-		spin_lock(&p->sighand->siglock);
-		recalc_sigpending_and_wake(p);
-		spin_unlock(&p->sighand->siglock);
-	}
 	spin_unlock_irqrestore(&freezer_lock, flags);
 }
