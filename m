From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/12] Move checkpoint/restart of signals into kernel/signal.c
Date: Fri, 26 Feb 2010 00:45:08 -0800
Message-ID: <6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/Makefile    |    1 -
 checkpoint/signal.c    |  732 ------------------------------------------------
 include/linux/signal.h |   17 +-
 kernel/signal.c        |  723 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 738 insertions(+), 735 deletions(-)
 delete mode 100644 checkpoint/signal.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 02e66b6..5bc8468 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -10,4 +10,3 @@ obj-$(CONFIG_CHECKPOINT) += \
 	process.o \
 	namespace.o \
 	memory.o \
-	signal.o
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
deleted file mode 100644
index 9d0e9c3..0000000
--- a/checkpoint/signal.c
+++ /dev/null
@@ -1,732 +0,0 @@
-/*
- *  Checkpoint task signals
- *
- *  Copyright (C) 2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DSYS
-
-#include <linux/sched.h>
-#include <linux/signal.h>
-#include <linux/errno.h>
-#include <linux/resource.h>
-#include <linux/timer.h>
-#include <linux/posix-timers.h>
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-
-static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
-{
-	memcpy(&h->sigset, sigset, sizeof(*sigset));
-}
-
-static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
-{
-	memcpy(sigset, &h->sigset, sizeof(*sigset));
-}
-
-/***********************************************************************
- * sighand checkpoint/collect/restart
- */
-
-static int do_checkpoint_sighand(struct ckpt_ctx *ctx,
-				 struct sighand_struct *sighand)
-{
-	struct ckpt_hdr_sighand *h;
-	struct ckpt_sigaction *hh;
-	struct sigaction *sa;
-	int i, ret;
-
-	h = ckpt_hdr_get_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
-			      CKPT_HDR_SIGHAND);
-	if (!h)
-		return -ENOMEM;
-
-	hh = h->action;
-	spin_lock_irq(&sighand->siglock);
-	for (i = 0; i < _NSIG; i++) {
-		sa = &sighand->action[i].sa;
-		hh[i]._sa_handler = (unsigned long) sa->sa_handler;
-		hh[i].sa_flags = sa->sa_flags;
-		hh[i].sa_restorer = (unsigned long) sa->sa_restorer;
-		fill_sigset(&hh[i].sa_mask, &sa->sa_mask);
-	}
-	spin_unlock_irq(&sighand->siglock);
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	return ret;
-}
-
-int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr)
-{
-	return do_checkpoint_sighand(ctx, (struct sighand_struct *) ptr);
-}
-
-int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct sighand_struct *sighand;
-	int objref;
-
-	read_lock(&tasklist_lock);
-	sighand = rcu_dereference(t->sighand);
-	atomic_inc(&sighand->count);
-	read_unlock(&tasklist_lock);
-
-	objref = checkpoint_obj(ctx, sighand, CKPT_OBJ_SIGHAND);
-	__cleanup_sighand(sighand);
-
-	return objref;
-}
-
-int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct sighand_struct *sighand;
-	int ret;
-
-	read_lock(&tasklist_lock);
-	sighand = rcu_dereference(t->sighand);
-	atomic_inc(&sighand->count);
-	read_unlock(&tasklist_lock);
-
-	ret = ckpt_obj_collect(ctx, sighand, CKPT_OBJ_SIGHAND);
-	__cleanup_sighand(sighand);
-
-	return ret;
-}
-
-static struct sighand_struct *do_restore_sighand(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_sighand *h;
-	struct ckpt_sigaction *hh;
-	struct sighand_struct *sighand;
-	struct sigaction *sa;
-	int i;
-
-	h = ckpt_read_obj_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
-			       CKPT_HDR_SIGHAND);
-	if (IS_ERR(h))
-		return ERR_PTR(PTR_ERR(h));
-
-	sighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
-	if (!sighand) {
-		sighand = ERR_PTR(-ENOMEM);
-		goto out;
-	}
-	atomic_set(&sighand->count, 1);
-
-	hh = h->action;
-	for (i = 0; i < _NSIG; i++) {
-		sa = &sighand->action[i].sa;
-		sa->sa_handler = (void *) (unsigned long) hh[i]._sa_handler;
-		sa->sa_flags = hh[i].sa_flags;
-		sa->sa_restorer = (void *) (unsigned long) hh[i].sa_restorer;
-		load_sigset(&sa->sa_mask, &hh[i].sa_mask);
-	}
- out:
-	ckpt_hdr_put(ctx, h);
-	return sighand;
-}
-
-void *restore_sighand(struct ckpt_ctx *ctx)
-{
-	return (void *) do_restore_sighand(ctx);
-}
-
-int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
-{
-	struct sighand_struct *sighand;
-	struct sighand_struct *old_sighand;
-
-	sighand = ckpt_obj_fetch(ctx, sighand_objref, CKPT_OBJ_SIGHAND);
-	if (IS_ERR(sighand))
-		return PTR_ERR(sighand);
-
-	if (sighand == current->sighand)
-		return 0;
-
-	atomic_inc(&sighand->count);
-
-	/* manipulate tsk->sighand with tasklist lock write-held */
-	write_lock_irq(&tasklist_lock);
-	old_sighand = rcu_dereference(current->sighand);
-	spin_lock(&old_sighand->siglock);
-	rcu_assign_pointer(current->sighand, sighand);
-	spin_unlock(&old_sighand->siglock);
-	write_unlock_irq(&tasklist_lock);
-	__cleanup_sighand(old_sighand);
-
-	return 0;
-}
-
-/***********************************************************************
- * signal checkpoint/restart
- */
-
-static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
-{
-	si->signo = info->si_signo;
-	si->_errno = info->si_errno;
-	si->code = info->si_code;
-
-	/* TODO: convert info->si_uid to uid_objref */
-
-	switch (info->si_code & __SI_MASK) {
-	case __SI_TIMER:
-		si->pid = info->si_tid;
-		si->uid = info->si_overrun;
-		si->sigval_int = info->si_int;
-		si->utime = info->si_sys_private;
-		break;
-	case __SI_POLL:
-		si->pid = info->si_band;
-		si->sigval_int = info->si_fd;
-		break;
-	case __SI_FAULT:
-		si->sigval_ptr = (unsigned long) info->si_addr;
-#ifdef __ARCH_SI_TRAPNO
-		si->sigval_int = info->si_trapno;
-#endif
-		break;
-	case __SI_CHLD:
-		si->pid = info->si_pid;
-		si->uid = info->si_uid;
-		si->sigval_int = info->si_status;
-		si->stime = info->si_stime;
-		si->utime = info->si_utime;
-		break;
-	case __SI_KILL:
-	case __SI_RT:
-	case __SI_MESGQ:
-		si->pid = info->si_pid;
-		si->uid = info->si_uid;
-		si->sigval_ptr = (unsigned long) info->si_ptr;
-		break;
-	default:
-		BUG();
-	}
-}
-
-static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
-{
-	if (!valid_signal(si->signo))
-		return -EINVAL;
-	if (!ckpt_validate_errno(si->_errno))
-		return -EINVAL;
-
-	info->si_signo = si->signo;
-	info->si_errno = si->_errno;
-	info->si_code = si->code;
-
-	/* TODO: validate remaining signal fields */
-
-	switch (info->si_code & __SI_MASK) {
-	case __SI_TIMER:
-		info->si_tid = si->pid;
-		info->si_overrun = si->uid;
-		info->si_int = si->sigval_int;
-		info->si_sys_private = si->utime;
-		break;
-	case __SI_POLL:
-		info->si_band = si->pid;
-		info->si_fd = si->sigval_int;
-		break;
-	case __SI_FAULT:
-		info->si_addr = (void __user *) (unsigned long) si->sigval_ptr;
-#ifdef __ARCH_SI_TRAPNO
-		info->si_trapno = si->sigval_int;
-#endif
-		break;
-	case __SI_CHLD:
-		info->si_pid = si->pid;
-		info->si_uid = si->uid;
-		info->si_status = si->sigval_int;
-		info->si_stime = si->stime;
-		info->si_utime = si->utime;
-		break;
-	case __SI_KILL:
-	case __SI_RT:
-	case __SI_MESGQ:
-		info->si_pid = si->pid;
-		info->si_uid = si->uid;
-		info->si_ptr = (void __user *) (unsigned long) si->sigval_ptr;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-/*
- * To checkpoint pending signals (private/shared) the caller moves the
- * signal queue (and copies the mask) to a separate struct sigpending,
- * therefore we can iterate through it without locking.
- * After we return, the caller re-attaches (prepends) the original
- * signal queue to the original struct sigpending. Thus, signals that
- * arrive(d) in the meantime will be suitably queued after these.
- * Finally, repeated non-realtime signals will not be queued because
- * they will already be marked in the pending mask, that remains as is.
- * This is the expected behavior of non-realtime signals.
- */
-static int checkpoint_sigpending(struct ckpt_ctx *ctx,
-				 struct sigpending *pending)
-{
-	struct ckpt_hdr_sigpending *h;
-	struct ckpt_siginfo *si;
-	struct sigqueue *q;
-	int nr_pending = 0;
-	int ret;
-
-	list_for_each_entry(q, &pending->list, list) {
-		/* TODO: remove after adding support for posix-timers */
-		if ((q->info.si_code & __SI_MASK) == __SI_TIMER) {
-			ckpt_err(ctx, -ENOTSUPP, "%(T)signal SI_TIMER\n");
-			return -ENOTSUPP;
-		}
-		nr_pending++;
-	}
-
-	h = ckpt_hdr_get_type(ctx, nr_pending * sizeof(*si) + sizeof(*h),
-			      CKPT_HDR_SIGPENDING);
-	if (!h)
-		return -ENOMEM;
-
-	h->nr_pending = nr_pending;
-	fill_sigset(&h->signal, &pending->signal);
-
-	si = h->siginfo;
-	list_for_each_entry(q, &pending->list, list)
-		fill_siginfo(si++, &q->info);
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-
-	return ret;
-}
-
-static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct ckpt_hdr_signal *h;
-	struct signal_struct *signal;
-	struct sigpending shared_pending;
-	struct tty_struct *tty = NULL;
-	struct rlimit *rlim;
-	struct timeval tval;
-	struct cpu_itimer *it;
-	cputime_t cputime;
-	unsigned long flags;
-	int i, ret = 0;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
-	if (!h)
-		return -ENOMEM;
-
-	signal = t->signal;
-	rlim = signal->rlim;
-
-	INIT_LIST_HEAD(&shared_pending.list);
-
-	/* temporarily borrow signal queue - see chekcpoint_sigpending() */
-	if (!lock_task_sighand(t, &flags)) {
-		ckpt_err(ctx, -EBUSY, "%(T)c/r: [pid %d] without sighand\n",
-			 task_pid_vnr(t));
-		ret = -EBUSY;
-		goto out;
-	}
-
-	/* TODO: remove after adding support for posix-timers */
-	if (!list_empty(&signal->posix_timers)) {
-		unlock_task_sighand(t, &flags);
-		ckpt_err(ctx, -ENOTSUPP, "%(T)%(P)posix-timers\n", signal);
-		ret = -ENOTSUPP;
-		goto out;
-	}
-
-	list_splice_init(&signal->shared_pending.list, &shared_pending.list);
-	shared_pending.signal = signal->shared_pending.signal;
-
-	/* rlimit */
-	for (i = 0; i < RLIM_NLIMITS; i++) {
-		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
-		h->rlim[i].rlim_max = rlim[i].rlim_max;
-	}
-
-	/* real/virt/prof itimers */
-	if (hrtimer_active(&signal->real_timer)) {
-		/* For an active timer compute the time delta */
-		ktime_t delta = hrtimer_get_remaining(&signal->real_timer);
-		/*
-		 * If the timer expired after the the test above, then
-		 * set the expire to the minimum possible (because by
-		 * now the pending signal have been saved already, but
-		 * the signal from this very expiry won't be sent before
-		 * we release t->sighand->siglock).
-		 */
-		ckpt_debug("active ! %lld\n", delta.tv64);
-		if (delta.tv64 <= 0)
-			delta.tv64 = NSEC_PER_USEC;
-		h->it_real_value = ktime_to_ns(delta);
-	} else {
-		/*
-		 * Timer is inactive; if @it_real_incr is 0 the timer
-		 * will not be re-armed. Beacuse we hold siglock, if
-		 * @it_real_incr > 0, the timer must have just expired
-		 * but not yet re-armed, and we have a SIGALRM pending
-		 * - that will trigger timer re-arm after restart.
-		 */
-		h->it_real_value = 0;
-	}
-	h->it_real_incr = ktime_to_ns(signal->it_real_incr);
-
-	/* for prof/virt, ignore error and incr_error */
-	it = &signal->it[CPUCLOCK_VIRT];
-	cputime = it->expires;
-	if (!cputime_eq(cputime, cputime_zero))
-		cputime = cputime_sub(it->expires, virt_ticks(t));
-	cputime_to_timeval(cputime, &tval);
-	h->it_virt_value = timeval_to_ns(&tval);
-	cputime_to_timeval(it->incr, &tval);
-	h->it_virt_incr = timeval_to_ns(&tval);
-
-	it = &signal->it[CPUCLOCK_PROF];
-	cputime = it->expires;
-	if (!cputime_eq(cputime, cputime_zero))
-		cputime = cputime_sub(it->expires, prof_ticks(t));
-	cputime_to_timeval(cputime, &tval);
-	h->it_prof_value = timeval_to_ns(&tval);
-	cputime_to_timeval(it->incr, &tval);
-	h->it_prof_incr = timeval_to_ns(&tval);
-
-	/* tty */
-	if (signal->leader) {
-		h->tty_old_pgrp = ckpt_pid_nr(ctx, signal->tty_old_pgrp);
-		tty = tty_kref_get(signal->tty);
-		if (tty) {
-			/* irq is already disabled */
-			spin_lock(&tty->ctrl_lock);
-			h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
-			spin_unlock(&tty->ctrl_lock);
-			tty_kref_put(tty);
-		}
-	}
-
-	unlock_task_sighand(t, &flags);
-
-	/*
-	 * If the session is in an ancestor namespace, skip this tty
-	 * and set tty_objref = 0. It will not be explicitly restored,
-	 * but rather inherited from parent pid-ns at restart time.
-	 */
-	if (tty && ckpt_pid_nr(ctx, tty->session) > 0) {
-		h->tty_objref = checkpoint_obj(ctx, tty, CKPT_OBJ_TTY);
-		if (h->tty_objref < 0)
-			ret = h->tty_objref;
-	}
-
-	if (!ret)
-		ret = ckpt_write_obj(ctx, &h->h);
-	if (!ret)
-		ret = checkpoint_sigpending(ctx, &shared_pending);
-
-	/* return the borrowed queue */
-	if (!lock_task_sighand(t, &flags)) {
-		pr_warning("c/r: [%d] sighand disappeared\n", task_pid_vnr(t));
-		goto out;
-	}
-	list_splice(&shared_pending.list, &signal->shared_pending.list);
-	unlock_task_sighand(t, &flags);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	BUG_ON(t->flags & PF_EXITING);
-	return checkpoint_signal(ctx, t);
-}
-
-static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *pending)
-{
-	struct ckpt_hdr_sigpending *h;
-	struct ckpt_siginfo *si;
-	struct sigqueue *q;
-	int ret = 0;
-
-	h = ckpt_read_buf_type(ctx, 0, CKPT_HDR_SIGPENDING);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	if (h->h.len != h->nr_pending * sizeof(*si) + sizeof(*h)) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	INIT_LIST_HEAD(&pending->list);
-	load_sigset(&pending->signal, &h->signal);
-
-	si = h->siginfo;
-	while (h->nr_pending--) {
-		q = sigqueue_alloc();
-		if (!q) {
-			ret = -ENOMEM;
-			break;
-		}
-
-		ret = load_siginfo(&q->info, si++);
-		if (ret < 0) {
-			sigqueue_free(q);
-			break;
-		}
-
-		q->flags &= ~SIGQUEUE_PREALLOC;
-		list_add_tail(&pending->list, &q->list);
-	}
-
-	if (ret < 0)
-		flush_sigqueue(pending);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-static int restore_signal(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_signal *h;
-	struct sigpending new_pending;
-	struct sigpending *pending;
-	struct tty_struct *tty = NULL;
-	struct itimerval itimer;
-	struct rlimit rlim;
-	struct pid *pgrp = NULL;
-	int i, ret;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	/* rlimit */
-	for (i = 0; i < RLIM_NLIMITS; i++) {
-		rlim.rlim_cur = h->rlim[i].rlim_cur;
-		rlim.rlim_max = h->rlim[i].rlim_max;
-		ret = do_setrlimit(i, &rlim);
-		if (ret < 0)
-			goto out;
-	}
-
-	ret = restore_sigpending(ctx, &new_pending);
-	if (ret < 0)
-		goto out;
-
-	/* tty - session */
-	if (h->tty_objref) {
-		tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
-		if (IS_ERR(tty)) {
-			ret = PTR_ERR(tty);
-			goto out;
-		}
-		/* this will fail unless we're the session leader */
-		ret = tiocsctty(tty, 0);
-		if (ret < 0)
-			goto out;
-		/* now restore the foreground group (job control) */
-		if (h->tty_pgrp) {
-			/*
-			 * If tty_pgrp == CKPT_PID_NULL, below will
-			 * fail, so no need for explicit test
-			 */
-			ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
-					   h->tty_pgrp);
-			if (ret < 0)
-				goto out;
-		}
-	} else {
-		/*
-		 * If tty_objref isn't set, we _keep_ whatever tty we
-		 * already have as a ctty. Why does this make sense ?
-		 * - If our session is "within" the restart context,
-		 * then that session has no controlling terminal.
-		 * - If out session is "outside" the restart context,
-		 * then we're like to keep whatever we inherit from
-		 * the parent pid-ns.
-		 */
-	}
-
-	/*
-	 * Reset real/virt/prof itimer (in case they were set), to
-	 * prevent unwanted signals after flushing current signals
-	 * and before restoring original real/virt/prof itimer.
-	 */
-	itimer.it_value = (struct timeval) { .tv_sec = 0, .tv_usec = 0 };
-	itimer.it_interval =  (struct timeval) { .tv_sec = 0, .tv_usec = 0 };
-	do_setitimer(ITIMER_REAL, &itimer, NULL);
-	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
-	do_setitimer(ITIMER_PROF, &itimer, NULL);
-
-	/* tty - tty_old_pgrp */
-	if (current->signal->leader && h->tty_old_pgrp != CKPT_PID_NULL) {
-		rcu_read_lock();
-		pgrp = get_pid(_ckpt_find_pgrp(ctx, h->tty_old_pgrp));
-		rcu_read_unlock();
-		if (!pgrp)
-			goto out;
-	}
-
-	spin_lock_irq(&current->sighand->siglock);
-	/* tty - tty_old_pgrp */
-	put_pid(current->signal->tty_old_pgrp);
-	current->signal->tty_old_pgrp = pgrp;
-	/* pending signals */
-	pending = &current->signal->shared_pending;
-	flush_sigqueue(pending);
-	pending->signal = new_pending.signal;
-	list_splice_init(&new_pending.list, &pending->list);
-	spin_unlock_irq(&current->sighand->siglock);
-
-	/* real/virt/prof itimers */
-	itimer.it_value = ns_to_timeval(h->it_real_value);
-	itimer.it_interval = ns_to_timeval(h->it_real_incr);
-	ret = do_setitimer(ITIMER_REAL, &itimer, NULL);
-	if (ret < 0)
-		goto out;
-	/*
-	 * If expire is 0 but incr > 0 then we have a SIGALRM pending.
-	 * It should re-arm the timer when handled. But do_setitimer()
-	 * above already ignored @it_real_incr because @it_real_value
-	 * that was zero. So we set it manually. (This is safe against
-	 * malicious input, because in the worst case will generate an
-	 * unexpected SIGALRM to this process).
-	 */
-	if (!h->it_real_value && h->it_real_incr)
-		current->signal->it_real_incr = ns_to_ktime(h->it_real_incr);
-
-	itimer.it_value = ns_to_timeval(h->it_virt_value);
-	itimer.it_interval = ns_to_timeval(h->it_virt_incr);
-	ret = do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
-	if (ret < 0)
-		goto out;
-	itimer.it_value = ns_to_timeval(h->it_prof_value);
-	itimer.it_interval = ns_to_timeval(h->it_prof_incr);
-	ret = do_setitimer(ITIMER_PROF, &itimer, NULL);
- out:
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
-{
-	struct signal_struct *signal;
-	int ret = 0;
-
-	signal = ckpt_obj_try_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
-	if (!IS_ERR(signal)) {
-		/*
-		 * signal_struct is already shared properly as it is
-		 * tied to thread groups. Since thread relationships
-		 * are already restore now, t->signal must match.
-		 */
-		if (signal != current->signal)
-			ret = -EINVAL;
-	} else if (PTR_ERR(signal) == -EINVAL) {
-		/* first timer: add to hash and restore our t->signal */
-		ret = ckpt_obj_insert(ctx, current->signal,
-				      signal_objref, CKPT_OBJ_SIGNAL);
-		if (ret >= 0)
-			ret = restore_signal(ctx);
-	} else {
-		ret = PTR_ERR(signal);
-	}
-
-	return ret;
-}
-
-int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
-{
-	struct ckpt_hdr_signal_task *h;
-	struct sigpending pending;
-	unsigned long flags;
-	int ret;
-
-	INIT_LIST_HEAD(&pending.list);
-
-	/* temporarily borrow signal queue - see chekcpoint_sigpending() */
-	if (!lock_task_sighand(t, &flags)) {
-		ckpt_err(ctx, -EBUSY, "%(T)signand missing\n");
-		return -EBUSY;
-	}
-	list_splice_init(&t->pending.list, &pending.list);
-	pending.signal = t->pending.signal;
-	unlock_task_sighand(t, &flags);
-
-	ret = checkpoint_sigpending(ctx, &pending);
-
-	/* re-attach the borrowed queue */
-	if (!lock_task_sighand(t, &flags)) {
-		ckpt_err(ctx, -EBUSY, "%(T)signand missing\n");
-		return -EBUSY;
-	}
-	list_splice(&pending.list, &t->pending.list);
-	unlock_task_sighand(t, &flags);
-
-	if (ret < 0)
-		return ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
-	if (!h)
-		return -ENOMEM;
-
-	if (task_has_saved_sigmask(t))
-		fill_sigset(&h->blocked, &t->saved_sigmask);
-	else
-		fill_sigset(&h->blocked, &t->blocked);
-
-	ret = ckpt_write_obj(ctx, &h->h);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-int restore_task_signal(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_signal_task *h;
-	struct sigpending new_pending;
-	struct sigpending *pending;
-	sigset_t blocked;
-	int ret;
-
-	ret = restore_sigpending(ctx, &new_pending);
-	if (ret < 0)
-		return ret;
-
-	spin_lock_irq(&current->sighand->siglock);
-	pending = &current->pending;
-	flush_sigqueue(pending);
-	pending->signal = new_pending.signal;
-	list_splice_init(&new_pending.list, &pending->list);
-	spin_unlock_irq(&current->sighand->siglock);
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
-	if (IS_ERR(h))
-		return PTR_ERR(h);
-
-	load_sigset(&blocked, &h->blocked);
-	/* silently remove SIGKILL, SIGSTOP */
-	sigdelset(&blocked, SIGKILL);
-	sigdelset(&blocked, SIGSTOP);
-
-	/*
-	 * Unblocking signals now may affect us in wait_task_sync().
-	 * Instead, save blocked mask in current->saved_sigmaks for
-	 * post_restore_task().
-	 */
-	current->saved_sigmask = blocked;
-
-	ckpt_hdr_put(ctx, h);
-	return 0;
-}
diff --git a/include/linux/signal.h b/include/linux/signal.h
index af6cac3..4a19f62 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -374,11 +374,24 @@ int unhandled_signal(struct task_struct *tsk, int sig);
 	(!siginmask(signr, SIG_KERNEL_IGNORE_MASK|SIG_KERNEL_STOP_MASK) && \
 	 (t)->sighand->action[(signr)-1].sa.sa_handler == SIG_DFL)
 
-void signals_init(void);
-
+#ifdef CONFIG_CHECKPOINT
 /* [arch] checkpoint: should saved_sigmask be used in place of blocked */
 int task_has_saved_sigmask(struct task_struct *task);
 
+struct ckpt_ctx;
+int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
+int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr);
+int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t);
+int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t);
+void *restore_sighand(struct ckpt_ctx *ctx);
+int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref);
+int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref);
+int restore_task_signal(struct ckpt_ctx *ctx);
+#endif /* CONFIG_CHECKPOINT */
+
+void signals_init(void);
+
 #endif /* __KERNEL__ */
 
 #endif /* _LINUX_SIGNAL_H */
diff --git a/kernel/signal.c b/kernel/signal.c
index ce8d404..b5b5abb 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -31,6 +31,13 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
 
+#include <linux/errno.h>
+#include <linux/resource.h>
+#include <linux/timer.h>
+#include <linux/posix-timers.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
 #include <asm/param.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -2718,6 +2725,722 @@ __attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
+#ifdef CONFIG_CHECKPOINT
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DSYS
+
+static inline void fill_sigset(struct ckpt_sigset *h, sigset_t *sigset)
+{
+	memcpy(&h->sigset, sigset, sizeof(*sigset));
+}
+
+static inline void load_sigset(sigset_t *sigset, struct ckpt_sigset *h)
+{
+	memcpy(sigset, &h->sigset, sizeof(*sigset));
+}
+
+/***********************************************************************
+ * sighand checkpoint/collect/restart
+ */
+
+static int do_checkpoint_sighand(struct ckpt_ctx *ctx,
+				 struct sighand_struct *sighand)
+{
+	struct ckpt_hdr_sighand *h;
+	struct ckpt_sigaction *hh;
+	struct sigaction *sa;
+	int i, ret;
+
+	h = ckpt_hdr_get_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
+			      CKPT_HDR_SIGHAND);
+	if (!h)
+		return -ENOMEM;
+
+	hh = h->action;
+	spin_lock_irq(&sighand->siglock);
+	for (i = 0; i < _NSIG; i++) {
+		sa = &sighand->action[i].sa;
+		hh[i]._sa_handler = (unsigned long) sa->sa_handler;
+		hh[i].sa_flags = sa->sa_flags;
+		hh[i].sa_restorer = (unsigned long) sa->sa_restorer;
+		fill_sigset(&hh[i].sa_mask, &sa->sa_mask);
+	}
+	spin_unlock_irq(&sighand->siglock);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+int checkpoint_sighand(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_sighand(ctx, (struct sighand_struct *) ptr);
+}
+
+int checkpoint_obj_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sighand_struct *sighand;
+	int objref;
+
+	read_lock(&tasklist_lock);
+	sighand = rcu_dereference(t->sighand);
+	atomic_inc(&sighand->count);
+	read_unlock(&tasklist_lock);
+
+	objref = checkpoint_obj(ctx, sighand, CKPT_OBJ_SIGHAND);
+	__cleanup_sighand(sighand);
+
+	return objref;
+}
+
+int ckpt_collect_sighand(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct sighand_struct *sighand;
+	int ret;
+
+	read_lock(&tasklist_lock);
+	sighand = rcu_dereference(t->sighand);
+	atomic_inc(&sighand->count);
+	read_unlock(&tasklist_lock);
+
+	ret = ckpt_obj_collect(ctx, sighand, CKPT_OBJ_SIGHAND);
+	__cleanup_sighand(sighand);
+
+	return ret;
+}
+
+static struct sighand_struct *do_restore_sighand(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_sighand *h;
+	struct ckpt_sigaction *hh;
+	struct sighand_struct *sighand;
+	struct sigaction *sa;
+	int i;
+
+	h = ckpt_read_obj_type(ctx, _NSIG * sizeof(*hh) + sizeof(*h),
+			       CKPT_HDR_SIGHAND);
+	if (IS_ERR(h))
+		return ERR_PTR(PTR_ERR(h));
+
+	sighand = kmem_cache_alloc(sighand_cachep, GFP_KERNEL);
+	if (!sighand) {
+		sighand = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	atomic_set(&sighand->count, 1);
+
+	hh = h->action;
+	for (i = 0; i < _NSIG; i++) {
+		sa = &sighand->action[i].sa;
+		sa->sa_handler = (void *) (unsigned long) hh[i]._sa_handler;
+		sa->sa_flags = hh[i].sa_flags;
+		sa->sa_restorer = (void *) (unsigned long) hh[i].sa_restorer;
+		load_sigset(&sa->sa_mask, &hh[i].sa_mask);
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return sighand;
+}
+
+void *restore_sighand(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_sighand(ctx);
+}
+
+int restore_obj_sighand(struct ckpt_ctx *ctx, int sighand_objref)
+{
+	struct sighand_struct *sighand;
+	struct sighand_struct *old_sighand;
+
+	sighand = ckpt_obj_fetch(ctx, sighand_objref, CKPT_OBJ_SIGHAND);
+	if (IS_ERR(sighand))
+		return PTR_ERR(sighand);
+
+	if (sighand == current->sighand)
+		return 0;
+
+	atomic_inc(&sighand->count);
+
+	/* manipulate tsk->sighand with tasklist lock write-held */
+	write_lock_irq(&tasklist_lock);
+	old_sighand = rcu_dereference(current->sighand);
+	spin_lock(&old_sighand->siglock);
+	rcu_assign_pointer(current->sighand, sighand);
+	spin_unlock(&old_sighand->siglock);
+	write_unlock_irq(&tasklist_lock);
+	__cleanup_sighand(old_sighand);
+
+	return 0;
+}
+
+/***********************************************************************
+ * signal checkpoint/restart
+ */
+
+static void fill_siginfo(struct ckpt_siginfo *si, siginfo_t *info)
+{
+	si->signo = info->si_signo;
+	si->_errno = info->si_errno;
+	si->code = info->si_code;
+
+	/* TODO: convert info->si_uid to uid_objref */
+
+	switch (info->si_code & __SI_MASK) {
+	case __SI_TIMER:
+		si->pid = info->si_tid;
+		si->uid = info->si_overrun;
+		si->sigval_int = info->si_int;
+		si->utime = info->si_sys_private;
+		break;
+	case __SI_POLL:
+		si->pid = info->si_band;
+		si->sigval_int = info->si_fd;
+		break;
+	case __SI_FAULT:
+		si->sigval_ptr = (unsigned long) info->si_addr;
+#ifdef __ARCH_SI_TRAPNO
+		si->sigval_int = info->si_trapno;
+#endif
+		break;
+	case __SI_CHLD:
+		si->pid = info->si_pid;
+		si->uid = info->si_uid;
+		si->sigval_int = info->si_status;
+		si->stime = info->si_stime;
+		si->utime = info->si_utime;
+		break;
+	case __SI_KILL:
+	case __SI_RT:
+	case __SI_MESGQ:
+		si->pid = info->si_pid;
+		si->uid = info->si_uid;
+		si->sigval_ptr = (unsigned long) info->si_ptr;
+		break;
+	default:
+		BUG();
+	}
+}
+
+static int load_siginfo(siginfo_t *info, struct ckpt_siginfo *si)
+{
+	if (!valid_signal(si->signo))
+		return -EINVAL;
+	if (!ckpt_validate_errno(si->_errno))
+		return -EINVAL;
+
+	info->si_signo = si->signo;
+	info->si_errno = si->_errno;
+	info->si_code = si->code;
+
+	/* TODO: validate remaining signal fields */
+
+	switch (info->si_code & __SI_MASK) {
+	case __SI_TIMER:
+		info->si_tid = si->pid;
+		info->si_overrun = si->uid;
+		info->si_int = si->sigval_int;
+		info->si_sys_private = si->utime;
+		break;
+	case __SI_POLL:
+		info->si_band = si->pid;
+		info->si_fd = si->sigval_int;
+		break;
+	case __SI_FAULT:
+		info->si_addr = (void __user *) (unsigned long) si->sigval_ptr;
+#ifdef __ARCH_SI_TRAPNO
+		info->si_trapno = si->sigval_int;
+#endif
+		break;
+	case __SI_CHLD:
+		info->si_pid = si->pid;
+		info->si_uid = si->uid;
+		info->si_status = si->sigval_int;
+		info->si_stime = si->stime;
+		info->si_utime = si->utime;
+		break;
+	case __SI_KILL:
+	case __SI_RT:
+	case __SI_MESGQ:
+		info->si_pid = si->pid;
+		info->si_uid = si->uid;
+		info->si_ptr = (void __user *) (unsigned long) si->sigval_ptr;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/*
+ * To checkpoint pending signals (private/shared) the caller moves the
+ * signal queue (and copies the mask) to a separate struct sigpending,
+ * therefore we can iterate through it without locking.
+ * After we return, the caller re-attaches (prepends) the original
+ * signal queue to the original struct sigpending. Thus, signals that
+ * arrive(d) in the meantime will be suitably queued after these.
+ * Finally, repeated non-realtime signals will not be queued because
+ * they will already be marked in the pending mask, that remains as is.
+ * This is the expected behavior of non-realtime signals.
+ */
+static int checkpoint_sigpending(struct ckpt_ctx *ctx,
+				 struct sigpending *pending)
+{
+	struct ckpt_hdr_sigpending *h;
+	struct ckpt_siginfo *si;
+	struct sigqueue *q;
+	int nr_pending = 0;
+	int ret;
+
+	list_for_each_entry(q, &pending->list, list) {
+		/* TODO: remove after adding support for posix-timers */
+		if ((q->info.si_code & __SI_MASK) == __SI_TIMER) {
+			ckpt_err(ctx, -ENOTSUPP, "%(T)signal SI_TIMER\n");
+			return -ENOTSUPP;
+		}
+		nr_pending++;
+	}
+
+	h = ckpt_hdr_get_type(ctx, nr_pending * sizeof(*si) + sizeof(*h),
+			      CKPT_HDR_SIGPENDING);
+	if (!h)
+		return -ENOMEM;
+
+	h->nr_pending = nr_pending;
+	fill_sigset(&h->signal, &pending->signal);
+
+	si = h->siginfo;
+	list_for_each_entry(q, &pending->list, list)
+		fill_siginfo(si++, &q->info);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal *h;
+	struct signal_struct *signal;
+	struct sigpending shared_pending;
+	struct tty_struct *tty = NULL;
+	struct rlimit *rlim;
+	struct timeval tval;
+	struct cpu_itimer *it;
+	cputime_t cputime;
+	unsigned long flags;
+	int i, ret = 0;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (!h)
+		return -ENOMEM;
+
+	signal = t->signal;
+	rlim = signal->rlim;
+
+	INIT_LIST_HEAD(&shared_pending.list);
+
+	/* temporarily borrow signal queue - see chekcpoint_sigpending() */
+	if (!lock_task_sighand(t, &flags)) {
+		ckpt_err(ctx, -EBUSY, "%(T)c/r: [pid %d] without sighand\n",
+			 task_pid_vnr(t));
+		ret = -EBUSY;
+		goto out;
+	}
+
+	/* TODO: remove after adding support for posix-timers */
+	if (!list_empty(&signal->posix_timers)) {
+		unlock_task_sighand(t, &flags);
+		ckpt_err(ctx, -ENOTSUPP, "%(T)%(P)posix-timers\n", signal);
+		ret = -ENOTSUPP;
+		goto out;
+	}
+
+	list_splice_init(&signal->shared_pending.list, &shared_pending.list);
+	shared_pending.signal = signal->shared_pending.signal;
+
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
+		h->rlim[i].rlim_max = rlim[i].rlim_max;
+	}
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
+	/* for prof/virt, ignore error and incr_error */
+	it = &signal->it[CPUCLOCK_VIRT];
+	cputime = it->expires;
+	if (!cputime_eq(cputime, cputime_zero))
+		cputime = cputime_sub(it->expires, virt_ticks(t));
+	cputime_to_timeval(cputime, &tval);
+	h->it_virt_value = timeval_to_ns(&tval);
+	cputime_to_timeval(it->incr, &tval);
+	h->it_virt_incr = timeval_to_ns(&tval);
+
+	it = &signal->it[CPUCLOCK_PROF];
+	cputime = it->expires;
+	if (!cputime_eq(cputime, cputime_zero))
+		cputime = cputime_sub(it->expires, prof_ticks(t));
+	cputime_to_timeval(cputime, &tval);
+	h->it_prof_value = timeval_to_ns(&tval);
+	cputime_to_timeval(it->incr, &tval);
+	h->it_prof_incr = timeval_to_ns(&tval);
+
+	/* tty */
+	if (signal->leader) {
+		h->tty_old_pgrp = ckpt_pid_nr(ctx, signal->tty_old_pgrp);
+		tty = tty_kref_get(signal->tty);
+		if (tty) {
+			/* irq is already disabled */
+			spin_lock(&tty->ctrl_lock);
+			h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
+			spin_unlock(&tty->ctrl_lock);
+			tty_kref_put(tty);
+		}
+	}
+
+	unlock_task_sighand(t, &flags);
+
+	/*
+	 * If the session is in an ancestor namespace, skip this tty
+	 * and set tty_objref = 0. It will not be explicitly restored,
+	 * but rather inherited from parent pid-ns at restart time.
+	 */
+	if (tty && ckpt_pid_nr(ctx, tty->session) > 0) {
+		h->tty_objref = checkpoint_obj(ctx, tty, CKPT_OBJ_TTY);
+		if (h->tty_objref < 0)
+			ret = h->tty_objref;
+	}
+
+	if (!ret)
+		ret = ckpt_write_obj(ctx, &h->h);
+	if (!ret)
+		ret = checkpoint_sigpending(ctx, &shared_pending);
+
+	/* return the borrowed queue */
+	if (!lock_task_sighand(t, &flags)) {
+		pr_warning("c/r: [%d] sighand disappeared\n", task_pid_vnr(t));
+		goto out;
+	}
+	list_splice(&shared_pending.list, &signal->shared_pending.list);
+	unlock_task_sighand(t, &flags);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	BUG_ON(t->flags & PF_EXITING);
+	return checkpoint_signal(ctx, t);
+}
+
+static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *pending)
+{
+	struct ckpt_hdr_sigpending *h;
+	struct ckpt_siginfo *si;
+	struct sigqueue *q;
+	int ret = 0;
+
+	h = ckpt_read_buf_type(ctx, 0, CKPT_HDR_SIGPENDING);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	if (h->h.len != h->nr_pending * sizeof(*si) + sizeof(*h)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	INIT_LIST_HEAD(&pending->list);
+	load_sigset(&pending->signal, &h->signal);
+
+	si = h->siginfo;
+	while (h->nr_pending--) {
+		q = sigqueue_alloc();
+		if (!q) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		ret = load_siginfo(&q->info, si++);
+		if (ret < 0) {
+			sigqueue_free(q);
+			break;
+		}
+
+		q->flags &= ~SIGQUEUE_PREALLOC;
+		list_add_tail(&pending->list, &q->list);
+	}
+
+	if (ret < 0)
+		flush_sigqueue(pending);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int restore_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal *h;
+	struct sigpending new_pending;
+	struct sigpending *pending;
+	struct tty_struct *tty = NULL;
+	struct itimerval itimer;
+	struct rlimit rlim;
+	struct pid *pgrp = NULL;
+	int i, ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	/* rlimit */
+	for (i = 0; i < RLIM_NLIMITS; i++) {
+		rlim.rlim_cur = h->rlim[i].rlim_cur;
+		rlim.rlim_max = h->rlim[i].rlim_max;
+		ret = do_setrlimit(i, &rlim);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = restore_sigpending(ctx, &new_pending);
+	if (ret < 0)
+		goto out;
+
+	/* tty - session */
+	if (h->tty_objref) {
+		tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
+		if (IS_ERR(tty)) {
+			ret = PTR_ERR(tty);
+			goto out;
+		}
+		/* this will fail unless we're the session leader */
+		ret = tiocsctty(tty, 0);
+		if (ret < 0)
+			goto out;
+		/* now restore the foreground group (job control) */
+		if (h->tty_pgrp) {
+			/*
+			 * If tty_pgrp == CKPT_PID_NULL, below will
+			 * fail, so no need for explicit test
+			 */
+			ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
+					   h->tty_pgrp);
+			if (ret < 0)
+				goto out;
+		}
+	} else {
+		/*
+		 * If tty_objref isn't set, we _keep_ whatever tty we
+		 * already have as a ctty. Why does this make sense ?
+		 * - If our session is "within" the restart context,
+		 * then that session has no controlling terminal.
+		 * - If out session is "outside" the restart context,
+		 * then we're like to keep whatever we inherit from
+		 * the parent pid-ns.
+		 */
+	}
+
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
+	/* tty - tty_old_pgrp */
+	if (current->signal->leader && h->tty_old_pgrp != CKPT_PID_NULL) {
+		rcu_read_lock();
+		pgrp = get_pid(_ckpt_find_pgrp(ctx, h->tty_old_pgrp));
+		rcu_read_unlock();
+		if (!pgrp)
+			goto out;
+	}
+
+	spin_lock_irq(&current->sighand->siglock);
+	/* tty - tty_old_pgrp */
+	put_pid(current->signal->tty_old_pgrp);
+	current->signal->tty_old_pgrp = pgrp;
+	/* pending signals */
+	pending = &current->signal->shared_pending;
+	flush_sigqueue(pending);
+	pending->signal = new_pending.signal;
+	list_splice_init(&new_pending.list, &pending->list);
+	spin_unlock_irq(&current->sighand->siglock);
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
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
+{
+	struct signal_struct *signal;
+	int ret = 0;
+
+	signal = ckpt_obj_try_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	if (!IS_ERR(signal)) {
+		/*
+		 * signal_struct is already shared properly as it is
+		 * tied to thread groups. Since thread relationships
+		 * are already restore now, t->signal must match.
+		 */
+		if (signal != current->signal)
+			ret = -EINVAL;
+	} else if (PTR_ERR(signal) == -EINVAL) {
+		/* first timer: add to hash and restore our t->signal */
+		ret = ckpt_obj_insert(ctx, current->signal,
+				      signal_objref, CKPT_OBJ_SIGNAL);
+		if (ret >= 0)
+			ret = restore_signal(ctx);
+	} else {
+		ret = PTR_ERR(signal);
+	}
+
+	return ret;
+}
+
+int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_signal_task *h;
+	struct sigpending pending;
+	unsigned long flags;
+	int ret;
+
+	INIT_LIST_HEAD(&pending.list);
+
+	/* temporarily borrow signal queue - see chekcpoint_sigpending() */
+	if (!lock_task_sighand(t, &flags)) {
+		ckpt_err(ctx, -EBUSY, "%(T)signand missing\n");
+		return -EBUSY;
+	}
+	list_splice_init(&t->pending.list, &pending.list);
+	pending.signal = t->pending.signal;
+	unlock_task_sighand(t, &flags);
+
+	ret = checkpoint_sigpending(ctx, &pending);
+
+	/* re-attach the borrowed queue */
+	if (!lock_task_sighand(t, &flags)) {
+		ckpt_err(ctx, -EBUSY, "%(T)signand missing\n");
+		return -EBUSY;
+	}
+	list_splice(&pending.list, &t->pending.list);
+	unlock_task_sighand(t, &flags);
+
+	if (ret < 0)
+		return ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (!h)
+		return -ENOMEM;
+
+	if (task_has_saved_sigmask(t))
+		fill_sigset(&h->blocked, &t->saved_sigmask);
+	else
+		fill_sigset(&h->blocked, &t->blocked);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int restore_task_signal(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_signal_task *h;
+	struct sigpending new_pending;
+	struct sigpending *pending;
+	sigset_t blocked;
+	int ret;
+
+	ret = restore_sigpending(ctx, &new_pending);
+	if (ret < 0)
+		return ret;
+
+	spin_lock_irq(&current->sighand->siglock);
+	pending = &current->pending;
+	flush_sigqueue(pending);
+	pending->signal = new_pending.signal;
+	list_splice_init(&new_pending.list, &pending->list);
+	spin_unlock_irq(&current->sighand->siglock);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	load_sigset(&blocked, &h->blocked);
+	/* silently remove SIGKILL, SIGSTOP */
+	sigdelset(&blocked, SIGKILL);
+	sigdelset(&blocked, SIGSTOP);
+
+	/*
+	 * Unblocking signals now may affect us in wait_task_sync().
+	 * Instead, save blocked mask in current->saved_sigmaks for
+	 * post_restore_task().
+	 */
+	current->saved_sigmask = blocked;
+
+	ckpt_hdr_put(ctx, h);
+	return 0;
+}
+#endif /* CONFIG_CHECKPOINT */
+
 void __init signals_init(void)
 {
 	sigqueue_cachep = KMEM_CACHE(sigqueue, SLAB_PANIC);
-- 
1.6.3.3
