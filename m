From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 4/4] c/r: support for real/virt/prof itimers (v2)
Date: Tue,  4 Aug 2009 05:09:16 -0400
Message-ID: <1249376956-27555-5-git-send-email-orenl@librato.com>
References: <1249376956-27555-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249376956-27555-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
Cc: Luis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds support for real/virt/prof itimers.
Expiry and the interval values are both saved in nanoseconds.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/signal.c            |   72 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    6 +++
 2 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index c9da06b..18b3e2d 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -15,6 +15,7 @@
 #include <linux/signal.h>
 #include <linux/errno.h>
 #include <linux/resource.h>
+#include <linux/timer.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -264,6 +265,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct signal_struct *signal;
 	struct sigpending shared_pending;
 	struct rlimit *rlim;
+	struct timeval tval;
 	unsigned long flags;
 	int i, ret;
 
@@ -299,6 +301,49 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
 		h->rlim[i].rlim_max = rlim[i].rlim_max;
 	}
+
+	/* real/virt/prof itimers */
+	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
+	/*
+	 * (a) If the timer is now active (did not expire), compute
+	 * the time delta.
+	 * (b) If the timer expired, and delivered the signal already,
+	 * then set the expire (value) to the interval
+	 * (c) If the timer expired but did not yet deliver the
+	 * signal, then set the expire to the minimum possible, so it
+	 * will expire immediately after restart succeeds.
+	 */
+	if (hrtimer_active(&signal->real_timer)) {
+		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
+		/*
+		 * If the timer expired after the the test above, then
+		 * set the expire to the minimum possible (because by
+		 * now the pending signals have been saved already, but
+		 * without the signal from this very expiry).
+		 */
+		ckpt_debug("active ! %lld\n", delta.tv64);
+		if (delta.tv64 <= 0)
+			delta.tv64 = NSEC_PER_USEC;
+		h->it_real_value = ktime_to_ns(delta);
+	} else if (sigismember(&signal->shared_pending.signal, SIGALRM)) {
+		/* case (b) */
+		h->it_real_value = h->it_real_incr;
+	} else {
+		/* case (c) */
+		h->it_real_value =
+			ktime_to_ns((ktime_t) { .tv64 = NSEC_PER_USEC });
+	}
+
+	cputime_to_timeval(signal->it_virt_expires, &tval);
+	h->it_virt_value = timeval_to_ns(&tval);
+	cputime_to_timeval(signal->it_virt_incr, &tval);
+	h->it_virt_incr = timeval_to_ns(&tval);
+
+	cputime_to_timeval(signal->it_prof_expires, &tval);
+	h->it_prof_value = timeval_to_ns(&tval);
+	cputime_to_timeval(signal->it_prof_incr, &tval);
+	h->it_prof_incr = timeval_to_ns(&tval);
+
 	unlock_task_sighand(t, &flags);
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -416,6 +461,7 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_signal *h;
 	struct sigpending new_pending;
 	struct sigpending *pending;
+	struct itimerval itimer;
 	struct rlimit rlim;
 	int i, ret;
 
@@ -436,12 +482,38 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	/*
+	 * Reset real/virt/prof itimer (in case they were set), to
+	 * prevent unwanted signals after flushing current signals
+	 * and before restoring original real/virt/prof itimer.
+	 */
+	itimer.it_value = (struct timeval) { .tv_sec = 0, .tv_usec = 0 };
+	itimer.it_interval =  (struct timeval) { .tv_sec = 0, .tv_usec = 0 };
+	do_setitimer(ITIMER_REAL, &itimer, NULL);
+	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
+	do_setitimer(ITIMER_PROF, &itimer, NULL);
+
 	spin_lock_irq(&current->sighand->siglock);
 	pending = &current->signal->shared_pending;
 	flush_sigqueue(pending);
 	pending->signal = new_pending.signal;
 	list_splice_init(&new_pending.list, &pending->list);
 	spin_unlock_irq(&current->sighand->siglock);
+
+	/* real/virt/prof itimers */
+	itimer.it_value = ns_to_timeval(h->it_real_value);
+	itimer.it_interval = ns_to_timeval(h->it_real_incr);
+	ret = do_setitimer(ITIMER_REAL, &itimer, NULL);
+	if (ret < 0)
+		goto out;
+	itimer.it_value = ns_to_timeval(h->it_virt_value);
+	itimer.it_interval = ns_to_timeval(h->it_virt_incr);
+	ret = do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
+	if (ret < 0)
+		goto out;
+	itimer.it_value = ns_to_timeval(h->it_prof_value);
+	itimer.it_interval = ns_to_timeval(h->it_prof_incr);
+	ret = do_setitimer(ITIMER_PROF, &itimer, NULL);
  out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 9dcb160..a0ec25f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -472,6 +472,12 @@ struct ckpt_hdr_rlimit {
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
 	struct ckpt_hdr_rlimit rlim[CKPT_RLIM_NLIMITS];
+	__u64 it_real_value;
+	__u64 it_real_incr;
+	__u64 it_virt_value;
+	__u64 it_virt_incr;
+	__u64 it_prof_value;
+	__u64 it_prof_incr;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
-- 
1.6.0.4
