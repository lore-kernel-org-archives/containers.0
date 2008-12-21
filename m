From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 5/6][v3] Protect cinit from unblocked SIG_DFL signals
Date: Sat, 20 Dec 2008 16:54:54 -0800
Message-ID: <20081221005454.GE5025@us.ibm.com>
References: <20081221005106.GA4912@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755691AbYLUA4X@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081221005106.GA4912@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Date: Sat, 20 Dec 2008 13:25:24 -0800
Subject: [RFC][PATCH 5/6][v3] Protect cinit from unblocked SIG_DFL signals

Drop early any SIG_DFL or SIG_IGN signals to container-init from within
the same container. But queue SIGSTOP and SIGKILL to the container-init
if they are from an acnestor container.

Blocked, fatal signals (i.e when SIG_DFL is to terminate) from within the
container can still terminate the container-init. That will be addressed
in the next patch.

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   43 ++++++++++++++++++++++++++++++++++---------
 1 files changed, 34 insertions(+), 9 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 058b4c0..2dfca62 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -53,20 +53,39 @@ static int sig_handler_ignored(void __user *handler, int sig)
 		(handler == SIG_DFL && sig_kernel_ignore(sig));
 }
 
-static int sig_task_ignored(struct task_struct *t, int sig)
+/*
+ *
+ * Return 1 if task @t is either the global init or the container-init
+ * of the sender's container. Return 0 otherwise.
+ *
+ * @same_ns = 1 indicates that sender of signal is in same pid namespace
+ * as sender.
+ */
+static int sig_task_unkillable(struct task_struct *t, int same_ns)
+{
+	int flags = t->signal->flags;
+
+	if (unlikely(flags & SIGNAL_UNKILLABLE) ||
+			(same_ns && (flags & SIGNAL_UNKILLABLE_FROM_NS)))
+		return 1;
+
+	return 0;
+}
+
+static int sig_task_ignored(struct task_struct *t, int sig, int same_ns)
 {
 	void __user *handler;
 
 	handler = sig_handler(t, sig);
 
-	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
+	if (sig_task_unkillable(t, same_ns) &&
 			(handler == SIG_IGN || handler == SIG_DFL))
 		return 1;
-	
+
 	return sig_handler_ignored(handler, sig);
 }
 
-static int sig_ignored(struct task_struct *t, int sig)
+static int sig_ignored(struct task_struct *t, int sig, int same_ns)
 {
 	/*
 	 * Blocked signals are never ignored, since the
@@ -76,7 +95,7 @@ static int sig_ignored(struct task_struct *t, int sig)
 	if (sigismember(&t->blocked, sig) || sigismember(&t->real_blocked, sig))
 		return 0;
 
-	if (!sig_task_ignored(t, sig))
+	if (!sig_task_ignored(t, sig, same_ns))
 		return 0;
 
 	/*
@@ -632,7 +651,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
  * Returns true if the signal should be actually delivered, otherwise
  * it should be dropped.
  */
-static int prepare_signal(int sig, struct task_struct *p)
+static int prepare_signal(int sig, struct task_struct *p, int same_ns)
 {
 	struct signal_struct *signal = p->signal;
 	struct task_struct *t;
@@ -716,7 +735,7 @@ static int prepare_signal(int sig, struct task_struct *p)
 		}
 	}
 
-	return !sig_ignored(p, sig);
+	return !sig_ignored(p, sig, same_ns);
 }
 
 /*
@@ -867,11 +886,17 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
+	int same_ns;
 
 	trace_sched_signal_send(sig, t);
 
 	assert_spin_locked(&t->sighand->siglock);
-	if (!prepare_signal(sig, t))
+
+	same_ns = 1;
+	if (siginfo_from_ancestor_ns(t, info))
+		same_ns = 0;
+
+	if (!prepare_signal(sig, t, same_ns))
 		return 0;
 
 	pending = group ? &t->signal->shared_pending : &t->pending;
@@ -1366,7 +1391,7 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
 		goto ret;
 
 	ret = 1; /* the signal is ignored */
-	if (!prepare_signal(sig, t))
+	if (!prepare_signal(sig, t, 1))
 		goto out;
 
 	ret = 0;
-- 
1.5.2.5
