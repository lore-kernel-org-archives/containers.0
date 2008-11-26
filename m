From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 3/5] Determine if sender is from ancestor ns
Date: Tue, 25 Nov 2008 19:46:11 -0800
Message-ID: <20081126034611.GC23238@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754435AbYKZDqk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081126034242.GA23120@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


From 95ae5f7dfaa77158b07d2cbdc8e5df0a81c93194 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Tue, 18 Nov 2008 16:55:06 -0800
Subject: [PATCH 3/5] Determine if sender is from ancestor ns

To implement container-init semantics, send_signal() must compute the pid
namespace of the sender, but since signals may originate in workqueues/
interrupt handlers, computing the namespace of sender is not always
possible/safe.

Define a flag, SIG_FROM_USER and set this flag when a signal originates
from user-space (i.e in kill(), tkill(), rt_sigqueueinfo()). When this
flag is set, send_signal() can safely compute the pid namespace of the
sender.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   35 ++++++++++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index d8d20d6..45aebf0 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -793,14 +793,42 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
 
+/*
+ * Return 1 if this signal originated directly from a user process (i.e via
+ * kill(), tkill(), sigqueue()) that is in an ancestor pid namespace of @t.
+ * Return 0 otherwise.
+ */
+#ifdef CONFIG_PID_NS
+#define SIG_FROM_USER  INT_MIN         /* MSB */
+static inline int siginfo_from_ancestor_ns(struct task_struct *t,
+			siginfo_t *info)
+{
+	if (!is_si_special(info) && (info->si_signo & SIG_FROM_USER)) {
+		/* if t can't see us we are from parent ns */
+		if (task_pid_nr_ns(current, task_active_pid_ns(t)) <= 0)
+			return 1;
+	}
+	return 0;
+}
+#else
+static inline int siginfo_from_ancestor_ns(struct task_struct *t,
+			siginfo_t *info)
+{
+	return 0;
+}
+#endif
+
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
+	int from_ancestor_ns;
 
 	trace_sched_signal_send(sig, t);
 
+	from_ancestor_ns = siginfo_from_ancestor_ns(t, info);
+
 	assert_spin_locked(&t->sighand->siglock);
 	if (!prepare_signal(sig, t))
 		return 0;
@@ -850,6 +878,7 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			break;
 		default:
 			copy_siginfo(&q->info, info);
+			q->info.si_signo &= ~SIG_FROM_USER;
 			break;
 		}
 	} else if (!is_si_special(info)) {
@@ -2202,7 +2231,7 @@ sys_kill(pid_t pid, int sig)
 {
 	struct siginfo info;
 
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 	info.si_errno = 0;
 	info.si_code = SI_USER;
 	info.si_pid = task_tgid_vnr(current);
@@ -2219,7 +2248,7 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
 	unsigned long flags;
 
 	error = -ESRCH;
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 	info.si_errno = 0;
 	info.si_code = SI_TKILL;
 	info.si_pid = task_tgid_vnr(current);
@@ -2291,7 +2320,7 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, siginfo_t __user *uinfo)
 	   Nor can they impersonate a kill(), which adds source info.  */
 	if (info.si_code >= 0)
 		return -EPERM;
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 
 	/* POSIX.1b doesn't mention process groups.  */
 	return kill_proc_info(sig, &info, pid);
-- 
1.5.2.5
