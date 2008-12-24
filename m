From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 4/7][v4] Protect cinit from unblocked SIG_DFL signals
Date: Wed, 24 Dec 2008 03:51:58 -0800
Message-ID: <20081224115158.GD8020@us.ibm.com>
References: <20081224114414.GA7879@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752731AbYLXLxm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224114414.GA7879@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org
Cc: daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: [RFC][PATCH 4/7][v4] Protect cinit from unblocked SIG_DFL signals

Drop early any SIG_DFL or SIG_IGN signals to container-init from within
the same container. But queue SIGSTOP and SIGKILL to the container-init
if they are from an ancestor container.

Blocked, fatal signals (i.e when SIG_DFL is to terminate) from within the
container can still terminate the container-init. That will be addressed
in the next patch.

Note:	To be bisect-safe, SIGNAL_UNKILLABLE will be set for container-inits
   	in a follow-on patch. Until then, this patch is just a preparatory
	setp.

Changelog[v2]:
	- (Oleg Nesterov) Remove SIGNAL_UNKILLABLE_FROM_NS and rename
	  'same_ns' to 'from_ancestor_ns'.
	- SIGNAL_UNKILLABLE is not yet set for container-inits (will be
	  set in follow-on patch).

Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 kernel/signal.c |   36 +++++++++++++++++++++++++++---------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index 0011f99..5c4374f 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -53,20 +53,34 @@ static int sig_handler_ignored(void __user *handler, int sig)
 		(handler == SIG_DFL && sig_kernel_ignore(sig));
 }
 
-static int sig_task_ignored(struct task_struct *t, int sig)
+/*
+ * Return 1 if task @t is either the global init or the container-init
+ * of the sender's container. Return 0 otherwise.
+ */
+static int sig_task_unkillable(struct task_struct *t, int from_ancestor_ns)
+{
+	int flags = t->signal->flags;
+
+	if (unlikely(flags & SIGNAL_UNKILLABLE) && !from_ancestor_ns)
+		return 1;
+
+	return 0;
+}
+
+static int sig_task_ignored(struct task_struct *t, int sig, int from_ancestor_ns)
 {
 	void __user *handler;
 
 	handler = sig_handler(t, sig);
 
-	if (unlikely(t->signal->flags & SIGNAL_UNKILLABLE) &&
+	if (sig_task_unkillable(t, from_ancestor_ns) &&
 			(handler == SIG_IGN || handler == SIG_DFL))
 		return 1;
-	
+
 	return sig_handler_ignored(handler, sig);
 }
 
-static int sig_ignored(struct task_struct *t, int sig)
+static int sig_ignored(struct task_struct *t, int sig, int from_ancestor_ns)
 {
 	/*
 	 * Blocked signals are never ignored, since the
@@ -76,7 +90,7 @@ static int sig_ignored(struct task_struct *t, int sig)
 	if (sigismember(&t->blocked, sig) || sigismember(&t->real_blocked, sig))
 		return 0;
 
-	if (!sig_task_ignored(t, sig))
+	if (!sig_task_ignored(t, sig, from_ancestor_ns))
 		return 0;
 
 	/*
@@ -632,7 +646,7 @@ static int check_kill_permission(int sig, struct siginfo *info,
  * Returns true if the signal should be actually delivered, otherwise
  * it should be dropped.
  */
-static int prepare_signal(int sig, struct task_struct *p)
+static int prepare_signal(int sig, struct task_struct *p, int from_ancestor_ns)
 {
 	struct signal_struct *signal = p->signal;
 	struct task_struct *t;
@@ -716,7 +730,7 @@ static int prepare_signal(int sig, struct task_struct *p)
 		}
 	}
 
-	return !sig_ignored(p, sig);
+	return !sig_ignored(p, sig, from_ancestor_ns);
 }
 
 /*
@@ -876,11 +890,15 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
+	int from_ancestor_ns;
 
 	trace_sched_signal_send(sig, t);
 
 	assert_spin_locked(&t->sighand->siglock);
-	if (!prepare_signal(sig, t))
+
+	from_ancestor_ns = siginfo_from_ancestor_ns(t, info);
+
+	if (!prepare_signal(sig, t, from_ancestor_ns))
 		return 0;
 
 	pending = group ? &t->signal->shared_pending : &t->pending;
@@ -1375,7 +1393,7 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
 		goto ret;
 
 	ret = 1; /* the signal is ignored */
-	if (!prepare_signal(sig, t))
+	if (!prepare_signal(sig, t, 1))
 		goto out;
 
 	ret = 0;
-- 
1.5.2.5
