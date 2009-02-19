From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [PATCH 4/7][v8] Protect cinit from unblocked SIG_DFL signals
Date: Wed, 18 Feb 2009 19:06:37 -0800
Message-ID: <20090219030637.GD18990@us.ibm.com>
References: <20090219030207.GA18783@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758356AbZBSDHM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090219030207.GA18783@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Wed, 24 Dec 2008 14:03:57 -0800
Subject: [PATCH 4/7][v8] Protect cinit from unblocked SIG_DFL signals

Drop early any SIG_DFL or SIG_IGN signals to container-init from within
the same container. But queue SIGSTOP and SIGKILL to the container-init
if they are from an ancestor container.

Blocked, fatal signals (i.e when SIG_DFL is to terminate) from within the
container can still terminate the container-init. That will be addressed
in the next patch.

Note:	To be bisect-safe, SIGNAL_UNKILLABLE will be set for container-inits
   	in a follow-on patch. Until then, this patch is just a preparatory
	step.

Changelog[v7]:
	- (Oleg Nesterov) Bugfix: send_sigqueue() should use from_ancestor_ns=0
	- siginfo_from_user(), siginfo_from_ancestor_ns() are needed in only
	  one place.  Remove them and move their logic into send_signal().
	  Seems to make code more easier to read :-)

Changelog[v6]:
	- (Roland McGrath) Remove unnecessary helper signal_task_unkillable()
	  and fold checks into sig_task_ignored().

Changelog[v4]:
	- (Oleg Nesterov) Remove SIGNAL_UNKILLABLE_FROM_NS and rename
	  'same_ns' to 'from_ancestor_ns'.
	- SIGNAL_UNKILLABLE is not yet set for container-inits (will be
	  set in follow-on patch).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index ff1dff9..a3a1304 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -55,20 +55,21 @@ static int sig_handler_ignored(void __user *handler, int sig)
 		(handler == SIG_DFL && sig_kernel_ignore(sig));
 }
 
-static int sig_task_ignored(struct task_struct *t, int sig)
+static int sig_task_ignored(struct task_struct *t, int sig,
+		int from_ancestor_ns)
 {
 	void __user *handler;
 
 	handler = sig_handler(t, sig);
 
 	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
-			handler == SIG_DFL)
+			handler == SIG_DFL && !from_ancestor_ns)
 		return 1;
 
 	return sig_handler_ignored(handler, sig);
 }
 
-static int sig_ignored(struct task_struct *t, int sig)
+static int sig_ignored(struct task_struct *t, int sig, int from_ancestor_ns)
 {
 	/*
 	 * Blocked signals are never ignored, since the
@@ -78,7 +79,7 @@ static int sig_ignored(struct task_struct *t, int sig)
 	if (sigismember(&t->blocked, sig) || sigismember(&t->real_blocked, sig))
 		return 0;
 
-	if (!sig_task_ignored(t, sig))
+	if (!sig_task_ignored(t, sig, from_ancestor_ns))
 		return 0;
 
 	/*
@@ -634,7 +635,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
  * Returns true if the signal should be actually delivered, otherwise
  * it should be dropped.
  */
-static int prepare_signal(int sig, struct task_struct *p)
+static int prepare_signal(int sig, struct task_struct *p, int from_ancestor_ns)
 {
 	struct signal_struct *signal = p->signal;
 	struct task_struct *t;
@@ -718,7 +719,7 @@ static int prepare_signal(int sig, struct task_struct *p)
 		}
 	}
 
-	return !sig_ignored(p, sig);
+	return !sig_ignored(p, sig, from_ancestor_ns);
 }
 
 /*
@@ -832,7 +833,8 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
 	trace_sched_signal_send(sig, t);
 
 	assert_spin_locked(&t->sighand->siglock);
-	if (!prepare_signal(sig, t))
+
+	if (!prepare_signal(sig, t, from_ancestor_ns))
 		return 0;
 
 	pending = group ? &t->signal->shared_pending : &t->pending;
@@ -902,7 +904,15 @@ out_set:
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
 {
-	return __send_signal(sig, info, t, group, 0);
+	int from_ancestor_ns = 0;
+
+#ifdef CONFIG_PID_NS
+	if (!is_si_special(info) && SI_FROMUSER(info) &&
+			task_pid_nr_ns(current, task_active_pid_ns(t)) <= 0)
+		from_ancestor_ns = 1;
+#endif
+
+	return __send_signal(sig, info, t, group, from_ancestor_ns);
 }
 
 int print_fatal_signals;
@@ -1336,7 +1346,7 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
 		goto ret;
 
 	ret = 1; /* the signal is ignored */
-	if (!prepare_signal(sig, t))
+	if (!prepare_signal(sig, t, 0))
 		goto out;
 
 	ret = 0;
-- 
1.5.2.5
