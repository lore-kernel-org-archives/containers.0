From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH v21 078/100] c/r: support for controlling terminal and job
	control
Date: Sat,  1 May 2010 10:16:00 -0400
Message-ID: <1272723382-19470-79-git-send-email-orenl__40596.2404831827$1272727896$gmane$org@cs.columbia.edu>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Add checkpoint/restart of controlling terminal: current->signal->tty.
This is only done for session leaders.

If the session leader belongs to the ancestor pid-ns, then checkpoint
skips this tty; On restart, it will not be restored, and whatever tty
is in place from parent pid-ns (at restart) will be inherited.

Chagnelog [v1]:
  - Don't restore tty_old_pgrp it pgid is CKPT_PID_NULL
  - Initialize pgrp to NULL in restore_signal

Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/tty_io.c          |   33 +++++++++++++----
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    6 +++
 include/linux/tty.h            |    5 +++
 kernel/signal.c                |   79 +++++++++++++++++++++++++++++++++++++++-
 5 files changed, 115 insertions(+), 9 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 093f522..d264000 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2175,7 +2175,7 @@ static int fionbio(struct file *file, int __user *p)
  *		Takes ->siglock() when updating signal->tty
  */
 
-static int tiocsctty(struct tty_struct *tty, int arg)
+int tiocsctty(struct tty_struct *tty, int arg)
 {
 	int ret = 0;
 	if (current->signal->leader && (task_session(current) == tty->session))
@@ -2264,10 +2264,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
 }
 
 /**
- *	tiocspgrp		-	attempt to set process group
+ *	do_tiocspgrp		-	attempt to set process group
  *	@tty: tty passed by user
  *	@real_tty: tty side device matching tty passed by user
- *	@p: pid pointer
+ *	@pid: pgrp_nr
  *
  *	Set the process group of the tty to the session passed. Only
  *	permitted where the tty session is our session.
@@ -2275,10 +2275,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
  *	Locking: RCU, ctrl lock
  */
 
-static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
+int do_tiocspgrp(struct tty_struct *tty,
+		 struct tty_struct *real_tty, pid_t pgrp_nr)
 {
 	struct pid *pgrp;
-	pid_t pgrp_nr;
 	int retval = tty_check_change(real_tty);
 	unsigned long flags;
 
@@ -2290,8 +2290,6 @@ static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
 	    (current->signal->tty != real_tty) ||
 	    (real_tty->session != task_session(current)))
 		return -ENOTTY;
-	if (get_user(pgrp_nr, p))
-		return -EFAULT;
 	if (pgrp_nr < 0)
 		return -EINVAL;
 	rcu_read_lock();
@@ -2313,6 +2311,27 @@ out_unlock:
 }
 
 /**
+ *	tiocspgrp		-	attempt to set process group
+ *	@tty: tty passed by user
+ *	@real_tty: tty side device matching tty passed by user
+ *	@p: pid pointer
+ *
+ *	Set the process group of the tty to the session passed. Only
+ *	permitted where the tty session is our session.
+ *
+ *	Locking: RCU, ctrl lock
+ */
+
+static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
+{
+	pid_t pgrp_nr;
+
+	if (get_user(pgrp_nr, p))
+		return -EFAULT;
+	return do_tiocspgrp(tty, real_tty, pgrp_nr);
+}
+
+/**
  *	tiocgsid		-	get session id
  *	@tty: tty passed by user
  *	@real_tty: tty side of the tty pased by the user if a pty else the tty
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index adf5ca6..09fbb59 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -99,6 +99,7 @@ extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 
 /* pids */
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
+extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
 
 /* socket functions */
 extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 50138a0..79e8e2d 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -816,13 +816,19 @@ struct ckpt_rlimit {
 
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
+	/* rlimit */
 	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
+	/* itimer */
 	__u64 it_real_value;
 	__u64 it_real_incr;
 	__u64 it_virt_value;
 	__u64 it_virt_incr;
 	__u64 it_prof_value;
 	__u64 it_prof_incr;
+	/* tty */
+	__s32 tty_objref;
+	__s32 tty_pgrp;
+	__s32 tty_old_pgrp;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 3b7d8eb..b511c7f 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -513,6 +513,11 @@ extern void tty_ldisc_begin(void);
 /* This last one is just for the tty layer internals and shouldn't be used elsewhere */
 extern void tty_ldisc_enable(struct tty_struct *tty);
 
+/* These are for checkpoint/restart */
+extern int tiocsctty(struct tty_struct *tty, int arg);
+extern int do_tiocspgrp(struct tty_struct *tty,
+			struct tty_struct *real_tty, pid_t pgrp_nr);
+
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
 struct ckpt_hdr_file;
diff --git a/kernel/signal.c b/kernel/signal.c
index 1d511e7..e4ca9a6 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3063,9 +3063,10 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct timeval tval;
 	struct rlimit *rlim;
 	struct cpu_itimer *it;
+	struct tty_struct *tty = NULL;
 	cputime_t cputime;
 	unsigned long flags;
-	int i, ret;
+	int i, ret = 0;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (!h)
@@ -3147,9 +3148,34 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	cputime_to_timeval(it->incr, &tval);
 	h->it_prof_incr = timeval_to_ns(&tval);
 
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
 	unlock_task_sighand(t, &flags);
 
-	ret = ckpt_write_obj(ctx, &h->h);
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
 	if (!ret)
 		ret = checkpoint_sigpending(ctx, &shared_pending);
 
@@ -3221,6 +3247,8 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_signal *h;
 	struct sigpending new_pending;
 	struct sigpending *pending;
+	struct tty_struct *tty = NULL;
+	struct pid *pgrp = NULL;
 	struct rlimit rlim;
 	int i, ret;
 
@@ -3241,6 +3269,40 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
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
 	/*
 	 * Reset real/virt/prof itimer (in case they were set), to
 	 * prevent unwanted signals after flushing current signals
@@ -3252,7 +3314,20 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
 	do_setitimer(ITIMER_PROF, &itimer, NULL);
 
+	/* tty - tty_old_pgrp */
+	if (current->signal->leader && h->tty_old_pgrp != CKPT_PID_NULL) {
+		rcu_read_lock();
+		pgrp = get_pid(_ckpt_find_pgrp(ctx, h->tty_old_pgrp));
+		rcu_read_unlock();
+		if (!pgrp)
+			goto out;
+	}
+
 	spin_lock_irq(&current->sighand->siglock);
+	/* tty - tty_old_pgrp */
+	put_pid(current->signal->tty_old_pgrp);
+	current->signal->tty_old_pgrp = pgrp;
+	/* pending signals */
 	pending = &current->signal->shared_pending;
 	flush_sigqueue(pending);
 	pending->signal = new_pending.signal;
-- 
1.6.3.3
