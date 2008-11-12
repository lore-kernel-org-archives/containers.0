From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/3] Set si_pid to 0 for signals from ancestor namespace
Date: Tue, 11 Nov 2008 22:48:19 -0800
Message-ID: <20081112064819.GC27806@us.ibm.com>
References: <20081112064139.GA27806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081112064139.GA27806-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 11 Nov 2008 17:00:36 -0800
Subject: [PATCH 3/3] sig: Handle pid namespace crossing when sending signals.

Setting si_pid correctly in the context of pid namespaces is tricky.
Currently with the special cases in do_notify_parent and
do_notify_parent_cldstop we handle all of the day to day cases
properly except sending a signal to a task in a child pid namespace.
For that case we need to pretend to be the kernel and set si_pid to 0.

There are also a few theoretical cases where we can trigger sending a
signal from a task in one pid namespace to a task in another pid
namespace.  With no necessary correlation between one or the other.
In those cases when the source pid namespace is a child of the
destination pid namespace we actually have a valid pid value
we can and should report to user space.

This patch modifies the code to handle the full general case for
setting si_pid.  The code is a little longer but occurs only once and
making it some easier to understand and verify it is correct.

I add a struct pid sender parameter to __group_send_sig_info, as that is
the only function called with si_pid != task_tgid_vnr(current).  So we can
correctly handle the sending of a signal to the parent of an arbitrary
task.

Changelog[v2]:
	- Port to 2.6.28-rc3
	- Add in_interrupt() check in set_sigqueue_pid() (for SIGIO)

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/char/tty_io.c     |    4 +-
 include/linux/signal.h    |    3 +-
 ipc/mqueue.c              |    2 +-
 kernel/posix-cpu-timers.c |   12 +++---
 kernel/signal.c           |   88 +++++++++++++++++++++++++++-----------------
 5 files changed, 65 insertions(+), 44 deletions(-)

diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 59f4721..51ab382 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -615,8 +615,8 @@ static void do_tty_hangup(struct work_struct *work)
 				spin_unlock_irq(&p->sighand->siglock);
 				continue;
 			}
-			__group_send_sig_info(SIGHUP, SEND_SIG_PRIV, p);
-			__group_send_sig_info(SIGCONT, SEND_SIG_PRIV, p);
+			__group_send_sig_info(SIGHUP, SEND_SIG_PRIV, p, NULL);
+			__group_send_sig_info(SIGCONT, SEND_SIG_PRIV, p, NULL);
 			put_pid(p->signal->tty_old_pgrp);  /* A noop */
 			spin_lock_irqsave(&tty->ctrl_lock, flags);
 			if (tty->pgrp)
diff --git a/include/linux/signal.h b/include/linux/signal.h
index 84f997f..a576de8 100644
--- a/include/linux/signal.h
+++ b/include/linux/signal.h
@@ -234,7 +234,8 @@ static inline int valid_signal(unsigned long sig)
 
 extern int next_signal(struct sigpending *pending, sigset_t *mask);
 extern int group_send_sig_info(int sig, struct siginfo *info, struct task_struct *p);
-extern int __group_send_sig_info(int, struct siginfo *, struct task_struct *);
+extern int __group_send_sig_info(int, struct siginfo *, struct task_struct *,
+				 struct pid *sender);
 extern long do_sigpending(void __user *, unsigned long);
 extern int sigprocmask(int, sigset_t *, sigset_t *);
 extern int show_unhandled_signals;
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 68eb857..8968a4c 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -506,7 +506,7 @@ static void __do_notify(struct mqueue_inode_info *info)
 			sig_i.si_errno = 0;
 			sig_i.si_code = SI_MESGQ;
 			sig_i.si_value = info->notify.sigev_value;
-			sig_i.si_pid = task_tgid_vnr(current);
+			sig_i.si_pid = 0;	/* Uses default current tgid */
 			sig_i.si_uid = current->uid;
 
 			kill_pid_info(info->notify.sigev_signo,
diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
index 153dcb2..c72efb1 100644
--- a/kernel/posix-cpu-timers.c
+++ b/kernel/posix-cpu-timers.c
@@ -1014,7 +1014,7 @@ static void check_thread_timers(struct task_struct *tsk,
 			 * At the hard limit, we just die.
 			 * No need to calculate anything else now.
 			 */
-			__group_send_sig_info(SIGKILL, SEND_SIG_PRIV, tsk);
+			__group_send_sig_info(SIGKILL, SEND_SIG_PRIV, tsk, NULL);
 			return;
 		}
 		if (tsk->rt.timeout > DIV_ROUND_UP(*soft, USEC_PER_SEC/HZ)) {
@@ -1029,7 +1029,7 @@ static void check_thread_timers(struct task_struct *tsk,
 			printk(KERN_INFO
 				"RT Watchdog Timeout: %s[%d]\n",
 				tsk->comm, task_pid_nr(tsk));
-			__group_send_sig_info(SIGXCPU, SEND_SIG_PRIV, tsk);
+			__group_send_sig_info(SIGXCPU, SEND_SIG_PRIV, tsk, NULL);
 		}
 	}
 }
@@ -1122,7 +1122,7 @@ static void check_process_timers(struct task_struct *tsk,
 				sig->it_prof_expires = cputime_add(
 					sig->it_prof_expires, ptime);
 			}
-			__group_send_sig_info(SIGPROF, SEND_SIG_PRIV, tsk);
+			__group_send_sig_info(SIGPROF, SEND_SIG_PRIV, tsk, NULL);
 		}
 		if (!cputime_eq(sig->it_prof_expires, cputime_zero) &&
 		    (cputime_eq(prof_expires, cputime_zero) ||
@@ -1138,7 +1138,7 @@ static void check_process_timers(struct task_struct *tsk,
 				sig->it_virt_expires = cputime_add(
 					sig->it_virt_expires, utime);
 			}
-			__group_send_sig_info(SIGVTALRM, SEND_SIG_PRIV, tsk);
+			__group_send_sig_info(SIGVTALRM, SEND_SIG_PRIV, tsk, NULL);
 		}
 		if (!cputime_eq(sig->it_virt_expires, cputime_zero) &&
 		    (cputime_eq(virt_expires, cputime_zero) ||
@@ -1154,14 +1154,14 @@ static void check_process_timers(struct task_struct *tsk,
 			 * At the hard limit, we just die.
 			 * No need to calculate anything else now.
 			 */
-			__group_send_sig_info(SIGKILL, SEND_SIG_PRIV, tsk);
+			__group_send_sig_info(SIGKILL, SEND_SIG_PRIV, tsk, NULL);
 			return;
 		}
 		if (psecs >= sig->rlim[RLIMIT_CPU].rlim_cur) {
 			/*
 			 * At the soft limit, send a SIGXCPU every second.
 			 */
-			__group_send_sig_info(SIGXCPU, SEND_SIG_PRIV, tsk);
+			__group_send_sig_info(SIGXCPU, SEND_SIG_PRIV, tsk, NULL);
 			if (sig->rlim[RLIMIT_CPU].rlim_cur
 			    < sig->rlim[RLIMIT_CPU].rlim_max) {
 				sig->rlim[RLIMIT_CPU].rlim_cur++;
diff --git a/kernel/signal.c b/kernel/signal.c
index 4530fc6..28a48ee 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -28,6 +28,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/nsproxy.h>
 #include <trace/sched.h>
+#include <linux/hardirq.h>
 
 #include <asm/param.h>
 #include <asm/uaccess.h>
@@ -798,8 +799,40 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
 
+static void set_sigqueue_pid(struct sigqueue *q, struct task_struct *t,
+                           struct pid *sender)
+{
+	struct pid_namespace *ns;
+
+	/* Set si_pid to the pid number of sender in the pid namespace of
+	 * our destination task for all siginfo types that support it.
+	 */
+	switch(q->info.si_code & __SI_MASK) {
+		/* siginfo without si_pid */
+		case __SI_TIMER:
+		case __SI_POLL:
+		case __SI_FAULT:
+			break;
+			/* siginfo with si_pid */
+		case __SI_KILL:
+		case __SI_CHLD:
+		case __SI_RT:
+		case __SI_MESGQ:
+		default:
+			/* si_pid for SI_KERNEL is always 0 */
+			if (q->info.si_code == SI_KERNEL || in_interrupt())
+				break;
+			/* Is current not the sending task? */
+			if (!sender)
+				sender = task_tgid(current);
+			ns = task_active_pid_ns(t);
+			q->info.si_pid = pid_nr_ns(sender, ns);
+			break;
+	}
+}
+
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
-			int group)
+		int group, struct pid *sender)
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
@@ -843,7 +876,7 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			q->info.si_signo = sig;
 			q->info.si_errno = 0;
 			q->info.si_code = SI_USER;
-			q->info.si_pid = task_pid_vnr(current);
+			q->info.si_pid = 0;	/* Uses current tgid */
 			q->info.si_uid = current->uid;
 			break;
 		case (unsigned long) SEND_SIG_PRIV:
@@ -857,6 +890,7 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			copy_siginfo(&q->info, info);
 			break;
 		}
+		set_sigqueue_pid(q, t, sender);
 	} else if (!is_si_special(info)) {
 		if (sig >= SIGRTMIN && info->si_code != SI_USER)
 		/*
@@ -906,15 +940,16 @@ static int __init setup_print_fatal_signals(char *str)
 __setup("print-fatal-signals=", setup_print_fatal_signals);
 
 int
-__group_send_sig_info(int sig, struct siginfo *info, struct task_struct *p)
+__group_send_sig_info(int sig, struct siginfo *info, struct task_struct *p,
+		      struct pid *sender)
 {
-	return send_signal(sig, info, p, 1);
+	return send_signal(sig, info, p, 1, sender);
 }
 
 static int
 specific_send_sig_info(int sig, struct siginfo *info, struct task_struct *t)
 {
-	return send_signal(sig, info, t, 0);
+	return send_signal(sig, info, t, 0, NULL);
 }
 
 /*
@@ -1018,7 +1053,7 @@ int group_send_sig_info(int sig, struct siginfo *info, struct task_struct *p)
 	if (!ret && sig) {
 		ret = -ESRCH;
 		if (lock_task_sighand(p, &flags)) {
-			ret = __group_send_sig_info(sig, info, p);
+			ret = __group_send_sig_info(sig, info, p, NULL);
 			unlock_task_sighand(p, &flags);
 		}
 	}
@@ -1108,7 +1143,7 @@ int kill_pid_info_as_uid(int sig, struct siginfo *info, struct pid *pid,
 	if (sig && p->sighand) {
 		unsigned long flags;
 		spin_lock_irqsave(&p->sighand->siglock, flags);
-		ret = __group_send_sig_info(sig, info, p);
+		ret = __group_send_sig_info(sig, info, p, NULL);
 		spin_unlock_irqrestore(&p->sighand->siglock, flags);
 	}
 out_unlock:
@@ -1344,6 +1379,7 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 	struct sighand_struct *psig;
 	struct task_cputime cputime;
 	int ret = sig;
+	struct pid *sender;
 
 	BUG_ON(sig == -1);
 
@@ -1353,24 +1389,11 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 	BUG_ON(!tsk->ptrace &&
 	       (tsk->group_leader != tsk || !thread_group_empty(tsk)));
 
+	/* We are under tasklist_lock so no need to call get_pid */
+	sender = task_pid(tsk);
 	info.si_signo = sig;
 	info.si_errno = 0;
-	/*
-	 * we are under tasklist_lock here so our parent is tied to
-	 * us and cannot exit and release its namespace.
-	 *
-	 * the only it can is to switch its nsproxy with sys_unshare,
-	 * bu uncharing pid namespaces is not allowed, so we'll always
-	 * see relevant namespace
-	 *
-	 * write_lock() currently calls preempt_disable() which is the
-	 * same as rcu_read_lock(), but according to Oleg, this is not
-	 * correct to rely on this
-	 */
-	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
-	rcu_read_unlock();
-
+	info.si_pid = 0;	/* Filled in later from sender */
 	info.si_uid = tsk->uid;
 
 	thread_group_cputime(tsk, &cputime);
@@ -1412,7 +1435,7 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 			sig = -1;
 	}
 	if (valid_signal(sig) && sig > 0)
-		__group_send_sig_info(sig, &info, tsk->parent);
+		__group_send_sig_info(sig, &info, tsk->parent, sender);
 	__wake_up_parent(tsk, tsk->parent);
 	spin_unlock_irqrestore(&psig->siglock, flags);
 
@@ -1425,6 +1448,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
 	unsigned long flags;
 	struct task_struct *parent;
 	struct sighand_struct *sighand;
+	struct pid *sender;
 
 	if (tsk->ptrace & PT_PTRACED)
 		parent = tsk->parent;
@@ -1433,15 +1457,11 @@ static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
 		parent = tsk->real_parent;
 	}
 
+	/* We are under tasklist_lock so no need to call get_pid */
+	sender = task_pid(tsk);
 	info.si_signo = SIGCHLD;
 	info.si_errno = 0;
-	/*
-	 * see comment in do_notify_parent() abot the following 3 lines
-	 */
-	rcu_read_lock();
-	info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
-	rcu_read_unlock();
-
+	info.si_pid = 0;	/* Filled in later from sender */
 	info.si_uid = tsk->uid;
 
 	info.si_utime = cputime_to_clock_t(tsk->utime);
@@ -1466,7 +1486,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk, int why)
 	spin_lock_irqsave(&sighand->siglock, flags);
 	if (sighand->action[SIGCHLD-1].sa.sa_handler != SIG_IGN &&
 	    !(sighand->action[SIGCHLD-1].sa.sa_flags & SA_NOCLDSTOP))
-		__group_send_sig_info(SIGCHLD, &info, parent);
+		__group_send_sig_info(SIGCHLD, &info, parent, sender);
 	/*
 	 * Even if SIGCHLD is not generated, we must wake up wait4 calls.
 	 */
@@ -2210,7 +2230,7 @@ sys_kill(pid_t pid, int sig)
 	info.si_signo = sig;
 	info.si_errno = 0;
 	info.si_code = SI_USER;
-	info.si_pid = task_tgid_vnr(current);
+	info.si_pid = 0;	/* Uses default current tgid */
 	info.si_uid = current->uid;
 
 	return kill_something_info(sig, &info, pid);
@@ -2227,7 +2247,7 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
 	info.si_signo = sig;
 	info.si_errno = 0;
 	info.si_code = SI_TKILL;
-	info.si_pid = task_tgid_vnr(current);
+	info.si_pid = 0;	/* Uses default current tgid */
 	info.si_uid = current->uid;
 
 	rcu_read_lock();
-- 
1.5.2.5
