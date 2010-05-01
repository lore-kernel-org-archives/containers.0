From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 067/100] c/r: [signal 3/4] pending signals (private,
	shared)
Date: Sat,  1 May 2010 10:15:49 -0400
Message-ID: <1272723382-19470-68-git-send-email-orenl__7807.08772731504$1272728046$gmane$org@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This patch adds checkpoint and restart of pending signals queues:
struct sigpending, both per-task t->sigpending and shared (per-
thread-group) t->signal->shared_sigpending.

To checkpoint pending signals (private/shared) we first detach the
signal queue (and copy the mask) to a separate struct sigpending.
This separate structure can be iterated through without locking.

Once the state is saved, we re-attaches (prepends) the original signal
queue back to the original struct sigpending.

Signals that arrive(d) in the meantime will be suitably queued after
these (for real-time signals). Repeated non-realtime signals will not
be queued because they will already be marked in the pending mask,
that remains as is. This is the expected behavior of non-realtime
signals.

Changelog[v21]:
  - [Matt Helsley] Move the signal c/r changes to kernel/signal.c
Changelog [v19-rc1]:
  - Switch to ckpt_obj_try_fetch()
  - [Matt Helsley] Add cpp definitions for enums
Changelog [v4]:
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*
Changelog [v3]:
  - [Dan Smith] Sanity check for number of pending signals in buffer
Changelog [v2]:
  - Validate si_errno from checkpoint image
Changelog [v1]:
  - Fix compilation warnings
  - [Louis Rilling] Remove SIGQUEUE_PREALLOC flag from queued signals
  - [Louis Rilling] Fail if task has posix-timers or SI_TIMER signal

Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |   24 ++++
 kernel/signal.c                |  279 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 301 insertions(+), 2 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 0320bfa..3e6b49b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -142,6 +142,8 @@ enum {
 #define CKPT_HDR_SIGNAL CKPT_HDR_SIGNAL
 	CKPT_HDR_SIGNAL_TASK,
 #define CKPT_HDR_SIGNAL_TASK CKPT_HDR_SIGNAL_TASK
+	CKPT_HDR_SIGPENDING,
+#define CKPT_HDR_SIGPENDING CKPT_HDR_SIGPENDING
 
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
@@ -545,6 +547,28 @@ struct ckpt_hdr_sighand {
 	struct ckpt_sigaction action[0];
 } __attribute__((aligned(8)));
 
+#ifndef HAVE_ARCH_SIGINFO_T
+struct ckpt_siginfo {
+	__u32 signo;
+	__u32 _errno;
+	__u32 code;
+
+	__u32 pid;
+	__s32 uid;
+	__u32 sigval_int;
+	__u64 sigval_ptr;
+	__u64 utime;
+	__u64 stime;
+} __attribute__((aligned(8)));
+#endif
+
+struct ckpt_hdr_sigpending {
+	struct ckpt_hdr h;
+	__u32 nr_pending;
+	struct ckpt_sigset signal;
+	struct ckpt_siginfo siginfo[0];
+} __attribute__((aligned(8)));
+
 struct ckpt_rlimit {
 	__u64 rlim_cur;
 	__u64 rlim_max;
diff --git a/kernel/signal.c b/kernel/signal.c
index aae1f73..11f54ad 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2911,11 +2911,155 @@ static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
  * signal checkpoint/restart
  */
 
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
 static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_signal *h;
 	struct signal_struct *signal;
+	struct sigpending shared_pending;
 	struct rlimit *rlim;
+	unsigned long flags;
 	int i, ret;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
@@ -2925,13 +3069,46 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	signal = t->signal;
 	rlim = signal->rlim;
 
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
 	/* rlimit */
 	for (i = 0; i < RLIM_NLIMITS; i++) {
 		h->rlim[i].rlim_cur = rlim[i].rlim_cur;
 		h->rlim[i].rlim_max = rlim[i].rlim_max;
 	}
+	unlock_task_sighand(t, &flags);
 
 	ret = ckpt_write_obj(ctx, &h->h);
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
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -2942,9 +3119,55 @@ int checkpoint_obj_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	return checkpoint_signal(ctx, t);
 }
 
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
 static int restore_signal(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_signal *h;
+	struct sigpending new_pending;
+	struct sigpending *pending;
 	struct rlimit rlim;
 	int i, ret;
 
@@ -2958,8 +3181,20 @@ static int restore_signal(struct ckpt_ctx *ctx)
 		rlim.rlim_max = h->rlim[i].rlim_max;
 		ret = do_setrlimit(i, &rlim);
 		if (ret < 0)
-			break;
+			goto out;
 	}
+
+	ret = restore_sigpending(ctx, &new_pending);
+	if (ret < 0)
+		goto out;
+
+	spin_lock_irq(&current->sighand->siglock);
+	pending = &current->signal->shared_pending;
+	flush_sigqueue(pending);
+	pending->signal = new_pending.signal;
+	list_splice_init(&new_pending.list, &pending->list);
+	spin_unlock_irq(&current->sighand->siglock);
+out:
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
@@ -2969,7 +3204,7 @@ int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
 	struct signal_struct *signal;
 	int ret = 0;
 
-	signal = ckpt_obj_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	signal = ckpt_obj_try_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
 	if (!IS_ERR(signal)) {
 		/*
 		 * signal_struct is already shared properly as it is
@@ -2994,8 +3229,34 @@ int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
 int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_signal_task *h;
+	struct sigpending pending;
+	unsigned long flags;
 	int ret;
 
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
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
 	if (!h)
 		return -ENOMEM;
@@ -3013,7 +3274,21 @@ int checkpoint_task_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 int restore_task_signal(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_signal_task *h;
+	struct sigpending new_pending;
+	struct sigpending *pending;
 	sigset_t blocked;
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
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL_TASK);
 	if (IS_ERR(h))
-- 
1.6.3.3
