From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v18 66/80] c/r: [signal 4/4] support for real/virt/prof itimers
Date: Wed, 23 Sep 2009 19:51:46 -0400
Message-ID: <1253749920-18673-67-git-send-email-orenl__40986.9913397872$1253755642$gmane$org@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds support for real/virt/prof itimers.
Expiry and the interval values are both saved in nanoseconds.

Changelog[v1]:
  - [Louis Rilling] Fix saving of signal->it_real_incr if not expired
  - Fix restoring of signal->it_real_incr if expire is zero
  - Save virt/prof expire relative to process accumulated time

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
---
 checkpoint/signal.c            |   86 ++++++++++++++++++++++++++++++++++++++++
 include/linux/checkpoint_hdr.h |    6 +++
 include/linux/posix-timers.h   |    9 ++++
 kernel/posix-cpu-timers.c      |    9 ----
 4 files changed, 101 insertions(+), 9 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 27e0f10..5ff0734 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -15,6 +15,8 @@
 #include <linux/signal.h>
 #include <linux/errno.h>
 #include <linux/resource.h>
+#include <linux/timer.h>
+#include <linux/posix-timers.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -315,6 +317,8 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct signal_struct *signal;
 	struct sigpending shared_pending;
 	struct rlimit *rlim;
+	struct timeval tval;
+	cputime_t cputime;
 	unsigned long flags;
 	int i, ret;
 
@@ -350,6 +354,50 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
 		h->rlim[i].rlim_max = rlim[i].rlim_max;
 	}
+
+	/* real/virt/prof itimers */
+	if (hrtimer_active(&signal->real_timer)) {
+		/* For an active timer compute the time delta */
+		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
+		/*
+		 * If the timer expired after the the test above, then
+		 * set the expire to the minimum possible (because by
+		 * now the pending signal have been saved already, but
+		 * the signal from this very expiry won't be sent before
+		 * we release t->sighand->siglock).
+		 */
+		ckpt_debug("active ! %lld\n", delta.tv64);
+		if (delta.tv64 <= 0)
+			delta.tv64 = NSEC_PER_USEC;
+		h->it_real_value = ktime_to_ns(delta);
+	} else {
+		/*
+		 * Timer is inactive; if @it_real_incr is 0 the timer
+		 * will not be re-armed. Beacuse we hold siglock, if
+		 * @it_real_incr > 0, the timer must have just expired
+		 * but not yet re-armed, and we have a SIGALRM pending
+		 * - that will trigger timer re-arm after restart.
+		 */
+		h->it_real_value = 0;
+	}
+	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
+
+	cputime = signal->it_virt_expires;
+	if (!cputime_eq(cputime, cputime_zero))
+		cputime = cputime_sub(signal->it_virt_expires, virt_ticks(t));
+	cputime_to_timeval(cputime, &tval);
+	h->it_virt_value = timeval_to_ns(&tval);
+	cputime_to_timeval(signal->it_virt_incr, &tval);
+	h->it_virt_incr = timeval_to_ns(&tval);
+
+	cputime = signal->it_prof_expires;
+	if (!cputime_eq(cputime, cputime_zero))
+		cputime = cputime_sub(signal->it_prof_expires, prof_ticks(t));
+	cputime_to_timeval(cputime, &tval);
+	h->it_prof_value = timeval_to_ns(&tval);
+	cputime_to_timeval(signal->it_prof_incr, &tval);
+	h->it_prof_incr = timeval_to_ns(&tval);
+
 	unlock_task_sighand(t, &flags);
 
 	ret = ckpt_write_obj(ctx, &h->h);
@@ -423,6 +471,7 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_signal *h;
 	struct sigpending new_pending;
 	struct sigpending *pending;
+	struct itimerval itimer;
 	struct rlimit rlim;
 	int i, ret;
 
@@ -443,12 +492,49 @@ static int restore_signal(struct ckpt_ctx *ctx)
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
+	/*
+	 * If expire is 0 but incr > 0 then we have a SIGALRM pending.
+	 * It should re-arm the timer when handled. But do_setitimer()
+	 * above already ignored @it_real_incr because @it_real_value
+	 * that was zero. So we set it manually. (This is safe against
+	 * malicious input, because in the worst case will generate an
+	 * unexpected SIGALRM to this process).
+	 */
+	if (!h->it_real_value && h->it_real_incr)
+		current->signal->it_real_incr = ns_to_ktime(h->it_real_incr);
+
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
index fd2836e..e4dfbd7 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -482,6 +482,12 @@ struct ckpt_rlimit {
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
 	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
+	__u64 it_real_value;
+	__u64 it_real_incr;
+	__u64 it_virt_value;
+	__u64 it_virt_incr;
+	__u64 it_prof_value;
+	__u64 it_prof_incr;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index d0d6a66..7dd69c3 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -125,4 +125,13 @@ void update_rlimit_cpu(unsigned long rlim_new);
 
 int invalid_clockid(const clockid_t which_clock);
 
+static inline cputime_t prof_ticks(struct task_struct *p)
+{
+	return cputime_add(p->utime, p->stime);
+}
+static inline cputime_t virt_ticks(struct task_struct *p)
+{
+	return p->utime;
+}
+
 #endif
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index e33a21c..a3491e6 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -167,15 +167,6 @@ static void bump_cpu_timer(struct k_itimer *timer,
 	}
 }
 
-static inline cputime_t prof_ticks(struct task_struct *p)
-{
-	return cputime_add(p->utime, p->stime);
-}
-static inline cputime_t virt_ticks(struct task_struct *p)
-{
-	return p->utime;
-}
-
 int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *tp)
 {
 	int error = check_clock(which_clock);
-- 
1.6.0.4
